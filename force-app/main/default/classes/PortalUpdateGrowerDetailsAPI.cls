/**
 * @description       : purpose of this class is to initiate email change process
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 02-16-2025
 * @last modified by  : Ayush Kumar Singh
**/
global without sharing class PortalUpdateGrowerDetailsAPI implements clcommon.PortalCustomRemoteAPI1 {

    private final String CLASS_NAME = PortalUpdateGrowerDetailsAPI.class.getName();
    private static final String NEW_EMAIL ='newEmail';
    private static final String CONTACT_ID ='contactId';
    private static final String OLD_EMAIL_TEMPLATE_NAME ='Email Change Alert';
    private static final String NEW_EMAIL_TEMPLATE_NAME ='Email Change Alert to New Email';
    private static final String FIELD_FINANCE_SENDER ='FIELD FINANCE';
    private static final String TOKEN ='token=';
    private static final String GROWER_NAME_KEY = '{!GrowerName}';
    private static final String BUTTON_BACKGROUND = '{!buttonBGColor}';
    private static final String CONTACT_INFO_KEY = '{!ContactInfo}';
    private static final String OLD_EMAIL_KEY = '{!oldEmail}';
    private static final String NEW_EMAIL_KEY = '{!newEmail}';
    private static final String VERIFICATION_LINK = '{!verificationLink}';
    private static final String LANDUS = 'landus';
    private static final String CFA = 'cfa';
    private static final String KEY_IS_EVERGREEN_ALLOWED = 'isEvergreenAllowed';
    private static final String KEY_UPDATE_REQUEST = 'updateRequest';
    private static final String KEY_EVERGREEN_ELIGIBILITY = 'Evergreen Eligibility';
    private static final String KEY_EMAIL = 'Email';
    private static final String KEY_PREVIOUS_EMAIL = 'prev_email';
    private static final String KEY_NEW_EMAIL = 'new_email';
    private static final String KEY_LEGAL_ENTITY = 'legalEntityType';
    private static final String ATTEMPT_NUMBER = 'attemptNum';

    String growerName = PortalConstants.EMPTY_STRING;

    List<clcommon.PortalCustomRemoteActionRecord> responseDataList = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();
    private List<User> loggedInUser=new List<User>();

    private static final String GROWER_EMAIL_VERIFICATION_LINK = System.Label.Grower_Email_Change_Verification_Page;
    private static final String GROWER_EMAIL_VERIFICATION_LINK_GMK = System.Label.Grower_Email_Change_Verification_Page_for_Growmark;

    /**
    * @description default constructor
    * @author Rakesh Saraf | 12-20-2024 
    **/
    global PortalUpdateGrowerDetailsAPI(){
        this.loggedInUser=PortalApplicationOriginationHelper.getLoggedInUser();
    }
  
    /**
    * @description : this methid is used to initiate the email change procedure
    * @author Krishanu Chinya | 04-05-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames,Map<String, Object> argumentsFromPortal){
        SavePoint dbSavePoint = Database.setSavepoint();
        try{
            String newEmail = String.valueOf(argumentsFromPortal.get(NEW_EMAIL));
            String contactId = String.valueOf(argumentsFromPortal.get(CONTACT_ID));
            String isEvergreenAllowed = String.valueOf(argumentsFromPortal.get(KEY_IS_EVERGREEN_ALLOWED));
            String updateRequest = String.valueOf(argumentsFromPortal.get(KEY_UPDATE_REQUEST));

            PortalApplicationOriginationHelper.checkForBlankParameter(contactId);
            PortalApplicationOriginationHelper.checkForBlankParameter(updateRequest);
            PortalSecurityUtil.validateGrowerWithDealer(contactId);
            if(updateRequest.equals(KEY_EVERGREEN_ELIGIBILITY)){
                PortalApplicationOriginationHelper.checkForBlankParameter(isEvergreenAllowed);
                changeGrowerEvergreenEligibility(EvergreenCheckHandler.convertEvergreenStatusToBoolean(isEvergreenAllowed),contactId);
            }else{
                PortalApplicationOriginationHelper.checkForBlankParameter(newEmail);
                updateGrowerEmail(newEmail,contactId);
            }

            response.status = clcommon.Constants.SUCCESS;

        }catch (CustomException CustomExceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = CustomExceptionObj.getMessage();
            PortalHelper.saveExceptionLog(CustomExceptionObj, CLASS_NAME);
        } catch (Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(exceptionObj, CLASS_NAME);
        }
        return response;
    }

    
    /**
    * @description - This method is use to initiate the Evergreen Eligibility change
    * @author Sk Minsar | 05-10-2024 
    * @param isEvergreenAllowed 
    * @param contactId 
    **/
    private void changeGrowerEvergreenEligibility(boolean isEvergreenAllowed, String contactId){
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList=[  SELECT ID,
                                                                                Is_Evergreen_Eligible__c,
                                                                                Applicant__c
                                                                        FROM Dealer_Applicant_Relationship__c
                                                                        WHERE Applicant_Contact__c= :contactId 
                                                                        AND Dealer__c=:loggedInUser[0].Account.ParentId];

        PortalApplicationOriginationHelper.checkEmptyList(dealerApplicantRelList, PortalConstants.SOMETHING_WENT_WRONG);
        
        if((dealerApplicantRelList[0].Is_Evergreen_Eligible__c).equals(isEvergreenAllowed)){
            throw new CustomException(PortalConstants.EVERGREEN_ELIGIBILITY_DUPLICATE_EXCEPTION);
        }

        dealerApplicantRelList[0].Is_Evergreen_Eligible__c=isEvergreenAllowed;
        Database.update(dealerApplicantRelList, PortalConstants.TRUE_VALUE);
        

        UpdateEvergreenEligibilityBatch updateEvergreenBatch = new UpdateEvergreenEligibilityBatch(isEvergreenAllowed, dealerApplicantRelList[0].id);
        Database.executeBatch(updateEvergreenBatch , Integer.valueOf(PortalConstants.GROWER_EVERGREEN_ELIGIBILITY_BATCH_SIZE));
    }

    
    
    /**
    * @description - this method is used to initiate the Email change procedure
    * @author Sk Minsar | 05-10-2024 
    * @param newEmail 
    * @param contactId 
    **/
    private void updateGrowerEmail(String newEmail, String contactId){
        //assigning the new email to the contact
        List<Contact> contactList = [SELECT Id,
                                            Email,
                                            Confirm_Email__c,
                                            genesis__SSN__c,
                                            FirstName,
                                            LastName,
                                            New_Email__c,
                                            AccountId,
                                            Account.Name,
                                            Account.genesis__Business_Information__r.genesis__Tax_Identification_Number__c,
                                            Account.clcommon__Legal_Entity_Type__r.Name,
                                            Verification_Attempt__c,
                                            (SELECT Id, 
                                                Dealer__c,
                                                Dealer__r.Name,
                                                Dealer__r.CFA_Partner_Program__r.Dealer_Portal_Primary_Color_Pallatte__c,
                                                Dealer__r.CFA_Partner_Program__r.Short_Name__c,
                                                Dealer__r.Coop_Type__c 
                                                FROM Dealer_Applicant_Relationships__r WHERE Dealer__c =: loggedInUser[0].Account.ParentId
                                                LIMIT 1)
                                        FROM Contact
                                        WHERE Id =: contactId];
        PortalApplicationOriginationHelper.checkEmptyList(contactList, PortalConstants.SOMETHING_WENT_WRONG);
        //if the contact didn't had email earlier, simply update the email
        if(String.isBlank(contactList[0].Email) || contactList[0].Email == null){
            contactList[0].Email = newEmail;
            contactList[0].Confirm_Email__c = newEmail;

            Database.update(contactList[0], PortalConstants.TRUE_VALUE);
            
            List<Account> accountList = [SELECT Id,
                                            clcommon__Email__c,
                                            Confirm_Email__c
                                        FROM Account 
                                        WHERE Id =: contactList[0].AccountId];
            PortalApplicationOriginationHelper.checkEmptyList(accountList, PortalConstants.SOMETHING_WENT_WRONG);
            accountList[0].clcommon__Email__c = newEmail;
            //Updating by Krishanu Chinya
            accountList[0].Confirm_Email__c = newEmail;
            Database.update(accountList[0], PortalConstants.TRUE_VALUE);
            return;
        }

        PortalValidationUtil.checkIfSSNorTINisPresent(contactList[0]);
        //setting the grower name according to legal entity type 
        if(contactList[0].Account.clcommon__Legal_Entity_Type__r.Name == PortalConstants.SOLE_PROP_ENTITY){
            growerName = contactList[0].FirstName;
        }else{
            growerName = contactList[0].LastName;
        }

        if(contactList[0].Email == newEmail){
            throw new CustomException(PortalConstants.SAME_NEW_EMAIL_AND_OLD_EMAIL);
        }
        contactList[0].New_Email__c = newEmail;
        Database.update(contactList[0], PortalConstants.TRUE_VALUE);

        sendNotificationtoOldEmail(contactList[0]);
        sendVerificationLinkToNewEmail(contactList[0]);
    }

    /**
    * @description : this method is used to send email change notification to the old email
    * @author Krishanu Chinya | 04-05-2024 
    * @param contactObj 
    **/
    private void sendNotificationtoOldEmail(Contact contactObj){
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> senderAddressList = new List<OrgWideEmailAddress>();
        EmailTemplate emailTemplate = EmailUtil.getEmailTemplate(OLD_EMAIL_TEMPLATE_NAME);
        Messaging.SingleEmailMessage email = new  Messaging.SingleEmailMessage();
        Messaging.SendEmailResult[] result;
        String emailStatus = PortalConstants.EMPTY_STRING;

        String emailIdToSend = contactObj.Email;
        emailIdToSend = String.valueOf(emailIdToSend);
        String dealerId = contactObj.Dealer_Applicant_Relationships__r[0].Dealer__c;
        if(String.isBlank(dealerId)){
            throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
        }
        String emailBody = PortalConstants.EMPTY_STRING;
        emailBody = emailTemplate.HtmlValue;
        emailBody = emailBody.replace(GROWER_NAME_KEY,growerName);
        emailBody = emailBody.replace(PortalConstants.REPLACE_DEALER_NAME,contactObj.Dealer_Applicant_Relationships__r[0].Dealer__r.Name);
        emailBody = emailBody.replace(CONTACT_INFO_KEY, EmailUtil.setContactInfo(dealerId));
        emailBody = emailBody.replace(ConstantValues.REPLACE_LOGO_URL, EmailUtil.setLogoURL(dealerId));
        email.subject = emailTemplate.Subject;        
        senderAddressList = EmailUtil.getOrgWideEmailAddress(FIELD_FINANCE_SENDER); 

        email.setHtmlBody(emailBody);
        email.setTemplateId(emailTemplate.Id); 
        email.setToAddresses(new String[] {emailIdToSend});
        email.setOrgWideEmailAddressId(senderAddressList[ConstantValues.ZERO_VALUE].Id); 
        emailsToSend.add(email);

        result = Messaging.sendEmail(emailsToSend);
        emailStatus = result[0].isSuccess()?ConstantValues.SUCCESS_STATUS : ConstantValues.FAILURE_STATUS;
        Map<String,Object> emailLogMap = new Map<String,Object>{
                                                            ConstantValues.KEY_FROM_ADDRESS => senderAddressList[0].Address,
                                                            ConstantValues.KEY_TO_ADDRESS => emailIdToSend,
                                                            ConstantValues.KEY_EMAIL_TEMPLATE => emailTemplate.Name,
                                                            ConstantValues.KEY_MESSAGE => emailBody,
                                                            ConstantValues.KEY_CLASS_NAME => CLASS_NAME,
                                                            ConstantValues.KEY_EMAIL_STATUS => emailStatus
        };
        if(emailStatus == ConstantValues.FAILURE_STATUS){
            emailLogMap.put(ConstantValues.KEY_ERROR_MESSAGE,result[0].getErrors()[0].getMessage());
                                                        }
        clcommon__Notification__c notificationObj = EmailUtil.getEmailLog(emailLogMap);
        if(notificationObj != null){
            Database.insert(notificationObj, PortalConstants.TRUE_VALUE);
        }
    }

    /**
    * @description : this method is used to send the verification link to the new email
    * @author Krishanu Chinya | 04-05-2024 
    * @param contactObj 
    **/
    private void sendVerificationLinkToNewEmail(Contact contactObj){
        String verificationLink = generateVerificationLink(contactObj);

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> senderAddressList = new List<OrgWideEmailAddress>();
        Messaging.SendEmailResult[] result;
        String emailStatus = PortalConstants.EMPTY_STRING;

        EmailTemplate emailTemplate = EmailUtil.getEmailTemplate(NEW_EMAIL_TEMPLATE_NAME);
        Messaging.SingleEmailMessage email = new  Messaging.SingleEmailMessage();
        String emailIdToSend = contactObj.New_Email__c;
        String coopType = contactObj.Dealer_Applicant_Relationships__r[0].Dealer__r.Coop_Type__c;
        String dealerId = contactObj.Dealer_Applicant_Relationships__r[0].Dealer__c;
        if(String.isBlank(dealerId)){
            throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
        }
        String colorName = ConstantValues.EMPTY_STRING;
        if(coopType != ConstantValues.GROWMARK_COOP_TYPE){
            colorName = contactObj.Dealer_Applicant_Relationships__r[0].Dealer__r.CFA_Partner_Program__r.Dealer_Portal_Primary_Color_Pallatte__c;
        }
        String emailBody = PortalConstants.EMPTY_STRING;
        emailIdToSend = String.valueOf(emailIdToSend);
        emailBody = emailTemplate.HtmlValue;

        emailBody = emailBody.replace(PortalConstants.REPLACE_DEALER_NAME,contactObj.Dealer_Applicant_Relationships__r[0].Dealer__r.Name);
        emailBody = emailBody.replace(BUTTON_BACKGROUND,
                                        (coopType == PortalConstants.GROWMARK_COOP_TYPE ?
                                            EmailUtil.getColorByCoop(coopType) :
                                            colorName
                                        )
                                    );

        emailBody = emailBody.replace(OLD_EMAIL_KEY,contactObj.Email);
        emailBody = emailBody.replace(NEW_EMAIL_KEY,contactObj.New_Email__c);
        emailBody = emailBody.replace(VERIFICATION_LINK,verificationLink);

        senderAddressList = EmailUtil.getOrgWideEmailAddress(FIELD_FINANCE_SENDER); 


        emailBody = emailBody.replace(ConstantValues.REPLACE_LOGO_URL, EmailUtil.setLogoURL(dealerId));
        email.subject = emailTemplate.Subject;        
        email.setHtmlBody(emailBody);
        email.setTemplateId(emailTemplate.Id); 
        email.setToAddresses(new String[] {emailIdToSend});
        email.setOrgWideEmailAddressId(senderAddressList[ConstantValues.ZERO_VALUE].Id); 
        emailsToSend.add(email);
        result = Messaging.sendEmail(emailsToSend);
        emailStatus = result[0].isSuccess()?ConstantValues.SUCCESS_STATUS : ConstantValues.FAILURE_STATUS;

        Map<String,Object> emailLogMap = new Map<String,Object>{
                                                                ConstantValues.KEY_FROM_ADDRESS => senderAddressList[0].Address,
                                                                ConstantValues.KEY_TO_ADDRESS => emailIdToSend,
                                                                ConstantValues.KEY_EMAIL_TEMPLATE => emailTemplate.Name,
                                                                ConstantValues.KEY_MESSAGE => emailBody,
                                                                ConstantValues.KEY_CLASS_NAME => CLASS_NAME,
                                                                ConstantValues.KEY_EMAIL_STATUS => emailStatus
        };
        if(emailStatus == ConstantValues.FAILURE_STATUS){
            emailLogMap.put(ConstantValues.KEY_ERROR_MESSAGE,result[0].getErrors()[0].getMessage());
                                                            }
        clcommon__Notification__c notificationObj = EmailUtil.getEmailLog(emailLogMap);
        if(notificationObj != null){
            Database.insert(notificationObj, PortalConstants.TRUE_VALUE);
        }
    }

    /**
    * @description : this method is used to generate the email verification link
    * @author Krishanu Chinya | 04-05-2024 
    * @param contactObj 
    * @return String 
    **/
    private String generateVerificationLink(Contact contactObj){
        String verificationLink = PortalConstants.EMPTY_STRING;
        Map<String, String> payloadMap = new Map<String, String> {
            KEY_PREVIOUS_EMAIL => contactObj.Email,
            KEY_NEW_EMAIL => contactObj.New_Email__c,
            CONTACT_ID => contactObj.Id,
            PortalConstants.COOP_TYPE_KEY => contactObj.Dealer_Applicant_Relationships__r[0].Dealer__r.Coop_Type__c,
            KEY_LEGAL_ENTITY => contactObj.Account.clcommon__Legal_Entity_Type__r.Name,
            ATTEMPT_NUMBER => String.valueOf(contactObj.Verification_Attempt__c)
        };
        String jwtToken = JWTUtil.generateEmailVerificationToken(payloadMap);
        if(contactObj.Dealer_Applicant_Relationships__r[0].Dealer__r.Coop_Type__c == PortalConstants.GROWMARK_COOP_TYPE){
            verificationLink = GROWER_EMAIL_VERIFICATION_LINK_GMK + PortalConstants.QUESTION_MARK_STRING + TOKEN + jwtToken;
        }else{
            String coopShortName = contactObj.Dealer_Applicant_Relationships__r[0].Dealer__r.CFA_Partner_Program__r.Short_Name__c;
            verificationLink = GROWER_EMAIL_VERIFICATION_LINK + coopShortName.toLowerCase() + PortalConstants.AMPERSAND_STRING + TOKEN + jwtToken;
        }
        return verificationLink;
    }
}