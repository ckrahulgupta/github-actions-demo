/**
 * @description       : Batch class to send Email notification to CFA Grower to see the monthly statement.
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 04-07-2025
 * @last modified by  : Shruti Tamakhuwala
**/
public with sharing class EOMEmailNotificationToGrowerBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful{
    private static final String GROWER_LOGIN_LINK = '{!growerLogInLink}';
    private static final String PHONE = '{!phone}';
    private static final String FIRST_MONTH = '1';
    private static final String MONTH = '01';
    private static final String COOP_NAME = '{!coopType}';
    private static final String COOP_KEY = '?coop=';
    private static final Integer EOM_EMAIL_LIMIT = Integer.valueOf(System.Label.EOM_Monthly_Statement_Email_Limit);
    List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
    static List<String> growerContactIdList = new List<String>();
    /**
     * @description : This method is used to query all the Active Application
     * @param batchableContext
     * @return 'Database.QueryLocator'
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext){
        Date todayDate = System.today();
        String currentYear = String.valueOf(todayDate.year());
        String currentMonth = String.valueOf(todayDate.month());
        String previousMonth = String.valueOf(todayDate.addMonths(-1).month());
        String previousMonthYear;
        if(currentMonth.equals(FIRST_MONTH) || currentMonth.equals(MONTH)){
            previousMonthYear = String.valueOf(todayDate.addYears(-1).year());
        }else{
            previousMonthYear = currentYear;
        }
        String currentMonthDate = currentYear + currentMonth;
        String previousMonthDate = previousMonthYear + previousMonth;
        return Database.getQueryLocator([SELECT Id,
                                                genesis__Contact__r.Email,
                                                genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                Monthly_Statement_Sent__c,
                                                Note_Date__c,
                                                Coop_Type__c,
                                                Dealer_Name__r.CFA_Partner_Program__c,
                                                Dealer_Name__r.CFA_Partner_Program__r.Name,
                                                Dealer_Name__r.CFA_Partner_Program__r.Short_Name__c,
                                                Dealer_Name__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c,
                                                Dealer_Name__r.CFA_Partner_Program__r.Mobile__c,
                                                (SELECT Id,
                                                        clcommon__Contact__r.Email
                                                    FROM genesis__Parties__r
                                                    WHERE clcommon__Party_Types__c = :ConstantValues.PRINCIPAL_PARTY
                                                    AND genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name !=: ConstantValues.SOLE_PROP_ENTITY
                                                    ORDER BY CreatedDate ASC
                                                    LIMIT 1)
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Status__c = :ConstantValues.ACTIVE 
                                                AND Monthly_Statement_Sent__c != :currentMonthDate 
                                                AND (Monthly_Statement_Sent__c =: previousMonthDate 
                                                OR Note_Date__c = LAST_N_MONTHS:1)
                                                ORDER BY Note_Date__c ASC
                                                LIMIT :EOM_EMAIL_LIMIT]);
    }

    /**
     * @description : This method is used to add all the emails to the coreGrowerEmailMap Map
     * @param batchableContext
     * @param applicationList
     */
    public void execute(Database.BatchableContext batchableContext, List<genesis__Applications__c> applicationList){
        try{
            Map<String, Object> contactIdVsGreyCoopMapObj =  new Map<String, Object>();
            Map<String, Object> contactIdVsGmkCoopMapObj =  new Map<String, Object>();
            List<Contact> contactWithUserList = new List<Contact>();
            List<Contact> contactWithoutUserList = new List<Contact>();
            for(genesis__Applications__c app : applicationList){
                appList.add(app);
                updateCoopMaps(contactIdVsGreyCoopMapObj, contactIdVsGmkCoopMapObj, app);
            }
            // Create a Map of Maps to hold both maps
            Map<String, Map<String, Object>> coopMap = new Map<String, Map<String, Object>>();

            // Put the original maps into the new map with appropriate keys
            coopMap.put(ConstantValues.KEY_GREY_LABEL, contactIdVsGreyCoopMapObj);
            coopMap.put(ConstantValues.GROWMARK_COOP_TYPE, contactIdVsGmkCoopMapObj);
            // checking if growerContactIdList is Empty or not
            CFAOriginationHelperClass.checkEmptyList(growerContactIdList,ConstantValues.PARAMETER_MISSING);

            //getting list of users from contacts who has already a user
            contactWithUserList = getGrowerContactWithUser(growerContactIdList);
            //get contacts of growers who don't have any user
            contactWithoutUserList = getGrowerContactWithoutUser(growerContactIdList);
            //Send  EOM Email to grower for existing user
            sendEmailToGrower(contactWithUserList, contactWithoutUserList, coopMap);
        }
        catch (Exception objException) {
            LoggingUtility.saveExceptionLogging(objException, EOMEmailNotificationToGrowerBatch.class.getName());
        }
    }

     /**
     * @description 
     * @param batchableContext
     */
    public void finish(Database.BatchableContext batchableContext) {
        EOMUpdateApplicationFieldBatch updateApplicationField = new EOMUpdateApplicationFieldBatch(this.appList);
        Database.executeBatch(updateApplicationField,40);
    }
   
    /**
    * @description Send email to grower
    * @author Ravi Ranjan | 03-06-2024 
    * @param contactWithUserList 
    * @param contactWithoutUserList 
    * @param coopMap 
    **/
    private static void sendEmailToGrower(List<Contact> contactWithUserList, List<Contact> contactWithoutUserList, 
                                                                                Map<String, Map<String, Object>> coopMap){
        Map<String, Object> contactIdVsGreyCoopMapObj = coopMap.get(ConstantValues.KEY_GREY_LABEL);
        Map<String, Object> contactIdVsGmkCoopMapObj = coopMap.get(ConstantValues.GROWMARK_COOP_TYPE);
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        List<String> greyLabelcontactList = getGreyContactWithPermissionSetList(PortalConstants.GREY_LABEL_COOP_TYPE);
        List<String> whiteLabelcontactList = getGreyContactWithPermissionSetList(PortalConstants.WHITE_LABEL_COOP_TYPE);
        if(!contactWithUserList.isEmpty()){
            OrgWideEmailAddress senderAddress = getSenderAddress();
            for(Contact contactObj: contactWithUserList){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(contactIdVsGreyCoopMapObj.containsKey(contactObj.Id) && greyLabelcontactList.contains(contactObj.Id)){
                    email = sendEmailForWithUser((genesis__Applications__c)contactIdVsGreyCoopMapObj.get(contactObj.Id), contactObj, senderAddress);
                    // adding email in list
                    addEmails(emailsToSend, email);
                }else if(contactIdVsGreyCoopMapObj.containsKey(contactObj.Id)){
                    email = sendEmailForWithoutUser((genesis__Applications__c)contactIdVsGreyCoopMapObj.get(contactObj.Id), contactObj, senderAddress);
                    // adding email in list
                    addEmails(emailsToSend, email);
                }
                if(contactIdVsGmkCoopMapObj.containsKey(contactObj.Id) && whiteLabelcontactList.contains(contactObj.Id)){
                    email = sendEmailForWithUser((genesis__Applications__c)contactIdVsGmkCoopMapObj.get(contactObj.Id), contactObj, senderAddress);
                    // adding email in list
                    addEmails(emailsToSend, email);
                }else if(contactIdVsGmkCoopMapObj.containsKey(contactObj.Id)){
                    email = sendEmailForWithoutUser((genesis__Applications__c)contactIdVsGmkCoopMapObj.get(contactObj.Id), contactObj, senderAddress);
                    // adding email in list
                    addEmails(emailsToSend, email);
                }
            }
        }
        sendEmailToGrowerWithoutUser(emailsToSend, contactWithoutUserList, coopMap);
        
		PostmarkMessaging postmarkMessaging = new PostmarkMessaging(emailsToSend, true);
		postmarkMessaging.sendEmails();

    }

    /**
    * @description 
    * @author Soumik Pattanayak | 02-26-2025 
    * @param applicationObj 
    * @param contactObj 
    * @param senderAddress 
    * @return Messaging.SingleEmailMessage 
    **/
    private static Messaging.SingleEmailMessage sendEmailForWithoutUser(genesis__Applications__c applicationObj, Contact contactObj, OrgWideEmailAddress senderAddress){
        EmailTemplate eomEmailTemplate = CFAOriginationHelperClass.getEmailTemplate(ConstantValues.EOM_EMAIL_TO_CFA_GROWER);
        String coopName = ConstantValues.EMPTY_STRING;
        String coopShortName = ConstantValues.EMPTY_STRING;
        String mobileNumber = ConstantValues.EMPTY_STRING;

        if(applicationObj.Coop_Type__c != ConstantValues.GROWMARK_COOP_TYPE && applicationObj.Dealer_Name__r.CFA_Partner_Program__c != null){
            coopName = applicationObj.Dealer_Name__r.CFA_Partner_Program__r.Name;
            coopShortName = applicationObj.Dealer_Name__r.CFA_Partner_Program__r.Short_Name__c;
            mobileNumber = applicationObj.Dealer_Name__r.CFA_Partner_Program__r.Mobile__c ;
        }

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String emailBody = eomEmailTemplate.HtmlValue;
        String growerEmail = contactObj.Email;
        email.subject = eomEmailTemplate.Subject;

        if(applicationObj.Coop_Type__c == ConstantValues.GROWMARK_COOP_TYPE){
            emailBody = emailBody.replace(GROWER_LOGIN_LINK, ConstantValues.GMK_REGISTRATION_URL);
            emailBody = emailBody.replace(PHONE, ConstantValues.GMK_PHONE);
            emailBody = emailBody.replace(COOP_NAME, ConstantValues.GMK_NAME);
        }else{
            emailBody = emailBody.replace(GROWER_LOGIN_LINK, ConstantValues.GROWER_REGISTRATION_URL + COOP_KEY + coopShortName.toLowerCase());
            if(!String.isBlank(mobileNumber)){
                emailBody = emailBody.replace(PHONE, mobileNumber);
            }
            emailBody = emailBody.replace(COOP_NAME, coopName);
        }

        email.setHtmlBody(emailBody);
        email.setTemplateId(eomEmailTemplate.Id);
        email.setOrgWideEmailAddressId(senderAddress.Id);
        if(growerEmail != null){
            email.setToAddresses(new String[] {growerEmail});
            return email;
        }return null;
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 02-26-2025 
    * @param applicationObj 
    * @param contactObj 
    * @param senderAddress 
    * @return Messaging.SingleEmailMessage 
    **/
    private static Messaging.SingleEmailMessage sendEmailForWithUser(genesis__Applications__c applicationObj, Contact contactObj, OrgWideEmailAddress senderAddress){
        //OrgWideEmailAddress senderAddress = getSenderAddress();
        EmailTemplate eomEmailTemplate = CFAOriginationHelperClass.getEmailTemplate(ConstantValues.EOM_EMAIL_TO_CFA_GROWER);
        String coopName = ConstantValues.EMPTY_STRING;
        String coopShortName = ConstantValues.EMPTY_STRING;
        String mobileNumber = ConstantValues.EMPTY_STRING;

        if(applicationObj.Coop_Type__c != ConstantValues.GROWMARK_COOP_TYPE && applicationObj.Dealer_Name__r.CFA_Partner_Program__c != null){
            coopName = applicationObj.Dealer_Name__r.CFA_Partner_Program__r.Name;
            coopShortName = applicationObj.Dealer_Name__r.CFA_Partner_Program__r.Short_Name__c; 
            mobileNumber = applicationObj.Dealer_Name__r.CFA_Partner_Program__r.Mobile__c;
        }

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String emailBody = eomEmailTemplate.HtmlValue;
        String growerEmail = contactObj.Email;
        email.subject = eomEmailTemplate.Subject;

        if(applicationObj.Coop_Type__c == ConstantValues.GROWMARK_COOP_TYPE){
            emailBody = emailBody.replace(GROWER_LOGIN_LINK, ConstantValues.GMK_GROWER_URL);
            emailBody = emailBody.replace(PHONE, ConstantValues.GMK_PHONE);
            emailBody = emailBody.replace(COOP_NAME, ConstantValues.GMK_NAME);
        }else{
            emailBody = emailBody.replace(GROWER_LOGIN_LINK, ConstantValues.GROWER_URL + COOP_KEY + coopShortName.toLowerCase());
            if(!String.isBlank(mobileNumber)){
                emailBody = emailBody.replace(PHONE, mobileNumber);
            }
            emailBody = emailBody.replace(COOP_NAME, coopName);
        }
        email.setHtmlBody(emailBody);
        email.setTemplateId(eomEmailTemplate.Id);
        email.setOrgWideEmailAddressId(senderAddress.Id);
        if(growerEmail != null){
            email.setToAddresses(new String[] {growerEmail});
            return email;
        }return null;
    }

    /**
    * @description Send Email to grower who doesn't have user
    * @author Ravi Ranjan | 03-06-2024 
    * @param emailsToSend 
    * @param contactWithoutUserList 
    * @param coopMap 
    **/
    private static void sendEmailToGrowerWithoutUser(List<Messaging.SingleEmailMessage> emailsToSend, List<Contact> contactWithoutUserList, 
                                                                                                                Map<String, Map<String, Object>> coopMap){
        Map<String, Object> contactIdVsGreyCoopMapObj = coopMap.get(ConstantValues.KEY_GREY_LABEL);
        Map<String, Object> contactIdVsGmkCoopMapObj = coopMap.get(ConstantValues.GROWMARK_COOP_TYPE);
        if(!contactWithoutUserList.isEmpty()){
            OrgWideEmailAddress senderAddress = getSenderAddress();
            for(Contact contactObj : contactWithoutUserList){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(contactIdVsGreyCoopMapObj.containsKey(contactObj.Id)){
                    email = sendEmailForWithoutUser((genesis__Applications__c)contactIdVsGreyCoopMapObj.get(contactObj.Id), contactObj, senderAddress);
                    // adding email in list
                    addEmails(emailsToSend, email);
                }
                if(contactIdVsGmkCoopMapObj.containsKey(contactObj.Id)){
                    email = sendEmailForWithoutUser((genesis__Applications__c)contactIdVsGmkCoopMapObj.get(contactObj.Id), contactObj, senderAddress);
                    // adding email in list
                    addEmails(emailsToSend, email);
                }
            }
        }
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 02-01-2025 
    * @param emailsToSend 
    * @param email 
    **/
    private static void addEmails(List<Messaging.SingleEmailMessage> emailsToSend, Messaging.SingleEmailMessage email){
        if(email!=null){
            emailsToSend.add(email);
        }
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 02-01-2025 
    * @param contactIdVsGreyCoopMapObj 
    * @param contactIdVsGmkCoopMapObj 
    * @param app 
    **/
    private static void updateCoopMaps(Map<String, Object> contactIdVsGreyCoopMapObj, Map<String, Object> contactIdVsGmkCoopMapObj, genesis__Applications__c app){
        if(app.genesis__Account__c != null &&
                        app.genesis__Account__r.clcommon__Legal_Entity_Type__c != null &&
                        (app.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name.equalsIgnoreCase(ConstantValues.SOLE_PROP_ENTITY)) &&
                        app.genesis__Contact__c != null){
                            growerContactIdList.add(app.genesis__Contact__c);
                            if(app.Coop_Type__c == ConstantValues.GROWMARK_COOP_TYPE){
                                    contactIdVsGmkCoopMapObj.put(app.genesis__Contact__c, app);
                            }else{
                                    contactIdVsGreyCoopMapObj.put(app.genesis__Contact__c, app);
                            }
        }
        else if(app.genesis__Parties__r.size()>0 &&
                    app.genesis__Parties__r[0].clcommon__Contact__c != null){
                        growerContactIdList.add(app.genesis__Parties__r[0].clcommon__Contact__c);
                        if(app.Coop_Type__c == ConstantValues.GROWMARK_COOP_TYPE){
                                    contactIdVsGmkCoopMapObj.put(app.genesis__Parties__r[0].clcommon__Contact__c, app);
                        }else{
                            contactIdVsGreyCoopMapObj.put(app.genesis__Parties__r[0].clcommon__Contact__c,app);
                        }
        } 
    }

    /**
    * @description : Get Sender Address
    * @author Ravi Ranjan | 03-07-2024 
    * @return OrgWideEmailAddress 
    **/
    private static OrgWideEmailAddress getSenderAddress(){
        return  [SELECT Id,
                        Address,
                        DisplayName
                        FROM OrgWideEmailAddress 
                        WHERE DisplayName =:ConstantValues.ORG_WIDE_NO_REPLY_EMAIL_ADDRESS];
    }
   
    /**
     * @description : Get a list of user from the contactIdList
     * @author Ravi Ranjan | 02-15-2024 
     * @param growerContactIdList 
     * @return  List<User>
     **/
    private static List<Contact> getGrowerContactWithUser(List<String> growerContactIdList){
        List<Contact> contactIdList = [SELECT Id, 
                                                AccountId,
                                                Account.Coop_Type__c, 
                                                Email, 
                                                FirstName, 
                                                LastName,
                                                Account.ParentId,
                                                Account.Parent.CFA_Partner_Program__c,
                                                Account.Parent.CFA_Partner_Program__r.Short_Name__c,
                                                Account.Parent.CFA_Partner_Program__r.Dealer_Portal_logo__c,
                                                Account.Parent.CFA_Partner_Program__r.Name,
                                                Account.Parent.CFA_Partner_Program__r.Mobile__c
                                        FROM Contact
                                        WHERE Id IN (SELECT ContactId 
                                                    FROM User
                                                    WHERE ContactId IN : growerContactIdList)];

        return contactIdList;
    }

   /**
    * @description : Get a list of contacts who don't have user
    * @author Ravi Ranjan | 03-13-2024 
    * @param growerContactIdList 
    * @return List<Contact> 
    **/
    private static List<Contact> getGrowerContactWithoutUser(List<String> growerContactIdList){
        return [SELECT Id, 
                        AccountId,
                        Account.Coop_Type__c, 
                        Email, 
                        FirstName, 
                        LastName,
                        Account.ParentId,
                        Account.Parent.CFA_Partner_Program__c,
                        Account.Parent.CFA_Partner_Program__r.Short_Name__c,
                        Account.Parent.CFA_Partner_Program__r.Dealer_Portal_logo__c,
                        Account.Parent.CFA_Partner_Program__r.Name,
                        Account.Parent.CFA_Partner_Program__r.Mobile__c
                FROM Contact 
                WHERE Id IN :growerContactIdList
                AND Id NOT IN (SELECT ContactId 
                               FROM User 
                               WHERE ContactId IN :growerContactIdList)];
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 03-01-2025 
    * @param psName 
    * @return List<String> 
    **/
    private static List<String> getGreyContactWithPermissionSetList(String psName){
        List<PermissionSetAssignment> psaList = [SELECT Id, Assignee.ContactId 
                                                    FROM PermissionSetAssignment
                                                    WHERE PermissionSet.Name = :psName 
                                                    AND Assignee.ContactId IN : growerContactIdList];
        List<String> contactList = new List<String>();
        for(PermissionSetAssignment psa : psaList){
            contactList.add(psa.Assignee.ContactId);
        }
        return contactList;
    }
}