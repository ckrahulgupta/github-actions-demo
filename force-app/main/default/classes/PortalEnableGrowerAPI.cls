/**
 * @description      : This API helps in sending email to grower
 * @author          : Ravi Ranjan
 * @group         
 * last modified on :
 * last modified by :
 **/
global without sharing class PortalEnableGrowerAPI implements clcommon.PortalCustomRemoteAPI1{
    private final String CLASS_NAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    private final String APP_ID = 'appId';
    private static final String EMAIL_TEMPLATE = 'eamilTemplate';
    private static final String SENDER_EMAIL = 'senderEmail';
    private static final String RECEIVER_EMAIL = 'receiverEmail';
    private static final String GROWER_FIRST_NAME = '{!FirstName}';
    private static final String LOGGED_IN_USER_NAME = '{!UserName}';
    private static final String GROWER_LINK = '{!growerLink}';
    private static final String COOP_EQUALS = '?coop=';
    
   
    /**
    * @description This is invoke action method
    * @author Ravi Ranjan | 12-20-2023 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                                String[] disclosureNames,
                                                Map<String, Object> argumentsFromPortal) {
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        Id contactId;
        String coopType;
        
        try{
            //fetching app id
            Id appId = (argumentsFromPortal.containsKey(APP_ID)) ? String.valueOf(argumentsFromPortal.get(APP_ID)) : null;
            //validating application
            if(appId == null){
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            //Validates if the user should be having access to view/update the Application or not
            PortalApplicationOriginationHelper.checkValidUser(PortalSecurityUtil.validateUserApplication(appId));
            //quering on application and party to get contact and email of borrower
            List<genesis__Applications__c> applicationList =[SELECT Id, 
                                                            genesis__Account__c,
                                                            genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                            Coop_Type__c,
                                                            genesis__Contact__c,
                                                            genesis__Contact__r.Email,
                                                            (SELECT Id,
                                                                    genesis__Application__c, 
                                                                    clcommon__Party_Types__c,
                                                                    Principal_Number__c,
                                                                    clcommon__Account__c,
                                                                    clcommon__Account__r.Name, 
                                                                    clcommon__Contact__c,
                                                                    clcommon__Contact__r.Email 
                                                            FROM genesis__parties__r
                                                            WHERE clcommon__Party_Types__c =:PortalConstants.PRINCIPAL_PARTY_NAME
                                                            AND Principal_Number__c = 1) 
                                                            FROM genesis__Applications__c
                                                            WHERE Id =: appId LIMIT 1];
            //checking if applicationList is empty or not
            PortalApplicationOriginationHelper.checkEmptyList(applicationList,PortalConstants.NO_APPLICATIONS_FOUND);
            //validating applicationList field 
            validateRequiredField(applicationList);
            //getting coop Type of grower
            coopType = applicationList[0].Coop_Type__c;
            //getting legal entity from account 
            String legalEntityObj = applicationList[0].genesis__Account__r.clcommon__Legal_Entity_Type__r.Name;
            if(legalEntityObj == PortalConstants.SOLE_PROP_ENTITY){
                contactId = applicationList[0].genesis__Contact__c;
            }else{
                contactId = applicationList[0].genesis__parties__r?.clcommon__Contact__c;
            }
            //Enable user for grower portal
            enableUserForGrowerPortal(contactId, coopType);
            response.status = clcommon.Constants.SUCCESS;

        } catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, CLASS_NAME);
        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response;

    }

    /**
    * @description 
    * @author Ravi Ranjan | 12-21-2023 
    * @param contactId 
    * @param coopType
    **/
    private static void enableUserForGrowerPortal(Id contactId, String coopType){
        //Update the Grower Account's Owner to the Admin User
        List<Contact> growerContactList = getContactById(String.valueOf(contactId));
        List<Account> growerAccOwnerChangeList = [SELECT Id, 
                                                    OwnerId 
                                                    FROM Account 
                                                    WHERE Id = :growerContactList[0].AccountId];
        growerAccOwnerChangeList[0].OwnerId = PortalSecurityUtil.getSiteAdmin();
        Database.update(growerAccOwnerChangeList, true);
        //create the user if there isn't grower user created and send welcome email and if user already exist then send login email to grower
        sendEmailToGrower(String.valueOf(growerContactList[0].Id), coopType);
        
    }
    /**
    * @description 
    * @author Ravi Ranjan | 12-21-2023 
    * @param contactId 
    * @param coopType
    **/
    private static void sendEmailToGrower(String contactId, String coopType){
        List<User> growerUserObj = getExistingUser(contactId);
        List<Profile> growerProfileObj;
        String coopTypeOfUser;
        
        if(coopType == PortalConstants.GROWMARK_COOP_TYPE){ 
            growerProfileObj =  getProfileByName(PortalConstants.GMK_GROWER_PROFILE);
            coopTypeOfUser = PortalConstants.WHITE_LABEL_COOP_TYPE;
        }
        else{
            growerProfileObj = getProfileByName(PortalConstants.GROWER_PROFILE);
            coopTypeOfUser = PortalConstants.GREY_LABEL_COOP_TYPE;
        }
        List<Contact> growerContactList = getContactById(contactId);
        if(growerUserObj.size() == 0){
            New_Portal_User__e newUserObj = new New_Portal_User__e(First_Name__c = growerContactList[0].FirstName ,
                                                    Last_Name__c = growerContactList[0].LastName, 
                                                    Email__c = growerContactList[0].Email, 
                                                    Contact_Id__c = growerContactList[0].Id, 
                                                    Coop_Type__c = coopTypeOfUser,
                                                    Profile_Id__c = growerProfileObj[0].id,
                                                    Account_Id__c = growerContactList[0].AccountId,
                                                    CIF_Number__c = growerContactList[0].Account.CIF_Number__c);

            Database.SaveResult result = EventBus.publish(newUserObj);
            if(!result.isSuccess()){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            //keeping grower email log
            if(coopType == PortalConstants.GROWMARK_COOP_TYPE){
                PortalApplicationOriginationHelper.saveEmailLog(
                                                    new Map<String,String>{
                                                        EMAIL_TEMPLATE => ConstantValues.GMK_EMAIL_TEMP_GROWER,
                                                        SENDER_EMAIL => ConstantValues.ORGWIDE_SENDER_EMAIL,
                                                        RECEIVER_EMAIL => growerContactList[0].Email
                                                    }
                                                );
            }else{
            
                PortalApplicationOriginationHelper.saveEmailLog(
                                                    new Map<String,String>{
                                                        EMAIL_TEMPLATE => ConstantValues.EMAIL_TEMP_GROWER,
                                                        SENDER_EMAIL => ConstantValues.ORGWIDE_SENDER_EMAIL,
                                                        RECEIVER_EMAIL => growerContactList[0].Email
                                                    }
                                                );
            }
        }
        else{
            //user alredy exist
            System.enqueueJob(new UpdateUserPermissionSetQueueable(growerUserObj[0].Id, new List<String>{coopTypeOfUser}));
            sendEmailToGrowerForExistingUser(growerUserObj, coopType);

        }
       
    }
    /**
    * @description 
    * @author Ravi Ranjan | 12-21-2023 
    * @param contactId 
    * @return List<User> 
    **/
    private static List<User> getExistingUser(String contactId){
        return [SELECT Id,
                        FirstName,
                        LastName,
                        Name,
                        Email,
                        ProfileId,
                        AccountId,
                        contactId,
                        Account.ParentId,
                        Account.Parent.CFA_Partner_Program__c,
                        Account.Parent.CFA_Partner_Program__r.Dealer_Portal_Logo__c,
                        Account.Parent.CFA_Partner_Program__r.Short_Name__c,
                        Account.Parent.CFA_Partner_Program__r.Name
                FROM User 
                WHERE ContactId = :contactId];
    }
    /**
    * @description 
    * @author Ravi Ranjan | 12-21-2023 
    * @param profileName 
    * @return Profile 
    **/
    private static List<Profile> getProfileByName(String profileName){
        return [SELECT Id
                FROM Profile 
                WHERE Name = :profileName];
    }

    /**
    * @description 
    * @author Ravi Ranjan | 12-21-2023 
    * @param contactId 
    * @return Contact 
    **/
    private static List<Contact> getContactById(String contactId){
        return [SELECT Id, 
                        AccountId,
                        Account.CIF_Number__c, 
                        Email, 
                        FirstName, 
                        LastName 
                FROM Contact 
                WHERE Id = :contactId];
    }
    
    /**
    * @description 
    * @author Ravi Ranjan | 12-28-2023 
    * @param growerUserObj 
    * @param coopType 
    **/
    public static void sendEmailToGrowerForExistingUser(List<User> growerUserObj, String coopType){
        String growerEmail = growerUserObj[0].Email;
        String firstName = growerUserObj[0].FirstName;
        String coopShortName = ConstantValues.EMPTY_STRING;
        String dealerId = growerUserObj[0].Account.ParentId;
        if(String.isBlank(dealerId)){
            throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
        }
        if(coopType != PortalConstants.GROWMARK_COOP_TYPE){
            coopShortName = growerUserObj[0].Account.Parent.CFA_Partner_Program__r.Short_Name__c;
        }
        
        String coopName = (coopType == PortalConstants.GROWMARK_COOP_TYPE ? ConstantValues.GMK_NAME : growerUserObj[0].Account.Parent.CFA_Partner_Program__r.Name);

        EmailTemplate emailTemplateList = new EmailTemplate();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();                                          
        Messaging.SingleEmailMessage email = new  Messaging.SingleEmailMessage();
        Messaging.SendEmailResult[] result;
        String emailIdToSend = ConstantValues.EMPTY_STRING;
        String emailBody = ConstantValues.EMPTY_STRING;

        emailTemplateList = [SELECT Id,
                                    Body,
                                    Name,
                                    Subject,
                                    HtmlValue
                                FROM EmailTemplate
                                WHERE Name =:ConstantValues.EMAIL_TEMP_EXIST_GROWER];
                                 
        emailIdToSend = String.valueOf(growerEmail);
        emailBody = emailTemplateList.HtmlValue;
        emailBody = emailBody.replace(GROWER_FIRST_NAME, firstName);
        emailBody = emailBody.replace(LOGGED_IN_USER_NAME,coopName);

        if(coopType == PortalConstants.GROWMARK_COOP_TYPE){
            emailbody = emailbody.replace(GROWER_LINK,ConstantValues.GMK_GROWER_URL);

        } else{
            emailBody = emailBody.replace(GROWER_LINK,ConstantValues.GROWER_URL + COOP_EQUALS + coopShortName.toLowerCase());
        }
        emailBody = emailBody.replace(PortalConstants.REPLACE_LOGO_URL, EmailUtil.setLogoURL(dealerId));
        List<OrgWideEmailAddress> senderAddressList = [SELECT Id,
                                                            Address, 
                                                            DisplayName 
                                                        FROM  OrgWideEmailAddress 
                                                        WHERE DisplayName = :ConstantValues.ORG_WIDE_NO_REPLY_EMAIL_ADDRESS];
        email.setOrgWideEmailAddressId(senderAddressList[0].Id);
        email.subject = emailTemplateList.Subject;
        email.setHtmlBody(emailBody);
        email.setTemplateId(emailTemplateList.Id);
        email.setToAddresses(new String[] {emailIdToSend});
        emailsToSend.add(email); 
        result = Messaging.sendEmail(emailsToSend);
        if(!result[0].isSuccess()){
            throw new CustomException(ConstantValues.EMAIL_SEND_FAILED);
        }
         //keeping email log 
        PortalApplicationOriginationHelper.saveEmailLog(
                                                new Map<String,String>{
                                                    EMAIL_TEMPLATE => emailTemplateList.Name,
                                                    SENDER_EMAIL => senderAddressList[0].Address,
                                                    RECEIVER_EMAIL => emailIdToSend
                                                }
                                            );
    }

    /**
    * @description 
    * @author Ravi Ranjan | 01-08-2024 
    * @param applicationList 
    **/
    private static void validateRequiredField(List<genesis__Applications__c> applicationList){
        if(applicationList[0].Coop_Type__c == null){
            throw new CustomException(PortalConstants.COOP_TYPE_MISSING);
        }
        if(applicationList[0].genesis__Account__r?.clcommon__Legal_Entity_Type__r?.Name == null){
            throw new CustomException(PortalConstants.LEGAL_ENTITY_MISSING);
        }
        validateContactAndEmail(applicationList);
    }
    /**
    * @description 
    * @author Ravi Ranjan | 01-08-2024 
    * @param applicationList 
    **/
    private static void validateContactAndEmail(List<genesis__Applications__c> applicationList){
        String legalEntityObj = applicationList[0].genesis__Account__r.clcommon__Legal_Entity_Type__r.Name;
        if(legalEntityObj == PortalConstants.SOLE_PROP_ENTITY){
            if(applicationList[0].genesis__Contact__c == null || applicationList[0].genesis__Contact__r.Email == null){
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
        }else{
            if(applicationList[0].genesis__parties__r?.clcommon__Contact__c == null || applicationList[0].genesis__parties__r?.clcommon__Contact__r?.Email == null){
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
       }
    }
}