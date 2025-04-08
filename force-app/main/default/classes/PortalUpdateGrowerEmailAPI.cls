/**
 * @description       : purpose of this class is to initiate email change process
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 04-24-2024
 * @last modified by  : Krishanu Chinya
**/
global without sharing class PortalUpdateGrowerEmailAPI implements clcommon.PortalCustomRemoteAPI1 {

    private final String CLASS_NAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    private static final String NEW_EMAIL ='newEmail';
    private static final String CONTACT_ID ='contactId';
    private static final String OLD_EMAIL_TEMPLATE_NAME ='Email Change Alert';
    private static final String NEW_EMAIL_TEMPLATE_NAME ='Email Change Alert to New Email';
    private static final String FIELD_FINANCE_SENDER ='FIELD FINANCE';
    private static final String TOKEN ='token=';
    private static final String GROWER_NAME_KEY = '{!GrowerName}';
    private static final String DEALER_NAME_KEY = '{!DealerName}';  
    private static final String BUTTON_BACKGROUND = '{!buttonBGColor}';
    private static final String CONTACT_INFO_KEY = '{!ContactInfo}';
    private static final String OLD_EMAIL_KEY = '{!oldEmail}';
    private static final String NEW_EMAIL_KEY = '{!newEmail}';
    private static final String VERIFICATION_LINK = '{!verificationLink}';
    private static final String LANDUS = 'landus';
    private static final String CFA = 'cfa';
    String growerName = PortalConstants.EMPTY_STRING;

    List<clcommon.PortalCustomRemoteActionRecord> responseDataList = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();

    private static final String GROWER_EMAIL_VERIFICATION_LINK = System.Label.Grower_Email_Change_Verification_Page;
    private static final String GROWER_EMAIL_VERIFICATION_LINK_GMK = System.Label.Grower_Email_Change_Verification_Page_for_Growmark;
  
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

            PortalApplicationOriginationHelper.checkForBlankParameter(newEmail);
            PortalApplicationOriginationHelper.checkForBlankParameter(contactId);

            PortalSecurityUtil.validateGrowerWithDealer(contactId);

            //assigning the new email to the contact
            List<Contact> contactList = [SELECT Id,
                                                Email,
                                                genesis__SSN__c,
                                                FirstName,
                                                LastName,
                                                New_Email__c,
                                                AccountId,
                                                Account.Name,
                                                Account.Coop_Type__c,
                                                Account.Parent.Name,
                                                Account.genesis__Business_Information__r.genesis__Tax_Identification_Number__c,
                                                Account.clcommon__Legal_Entity_Type__r.Name,
                                                Verification_Attempt__c
                                            FROM Contact
                                            WHERE Id =: contactId];
            PortalApplicationOriginationHelper.checkEmptyList(contactList, PortalConstants.SOMETHING_WENT_WRONG);

            //if the contact didn't had email earlier, simply update the email
            if(String.isBlank(contactList[0].Email) || contactList[0].Email == null){
                contactList[0].Email = newEmail;
                Database.update(contactList[0], true);

                List<Account> accountList = [SELECT Id,
                                                clcommon__Email__c
                                            FROM Account 
                                            WHERE Id =: contactList[0].AccountId];
                PortalApplicationOriginationHelper.checkEmptyList(accountList, PortalConstants.SOMETHING_WENT_WRONG);

                accountList[0].clcommon__Email__c = newEmail;
                Database.update(accountList[0], true);
                response.status = clcommon.Constants.SUCCESS;
                return response;
            }

            checkIfSSNorTINisPresent(contactList[0]);

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
            Database.update(contactList[0], true);

            sendNotificationtoOldEmail(contactList[0]);
            sendVerificationLinkToNewEmail(contactList[0]);
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
    * @description : checks whether the grower has ssn or tin
    * @author Krishanu Chinya | 04-11-2024 
    * @param growerContact 
    **/
    private void checkIfSSNorTINisPresent(Contact growerContact){
        //if grower does not have ssn
        if(String.isBlank(growerContact.genesis__SSN__c) 
                    && growerContact.Account.clcommon__Legal_Entity_Type__r.Name == PortalConstants.SOLE_PROP_ENTITY){
            throw new CustomException(PortalConstants.MISSING_SSN_OR_TIN);
        }
        if(String.isBlank(growerContact.Account.genesis__Business_Information__r.genesis__Tax_Identification_Number__c) 
                && growerContact.Account.clcommon__Legal_Entity_Type__r.Name == PortalConstants.CORPORATION){
            throw new CustomException(PortalConstants.MISSING_SSN_OR_TIN); 
        }
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
        String emailIdToSend = contactObj.Email;
        emailIdToSend = String.valueOf(emailIdToSend);
        String coopType = contactObj.Account.Coop_Type__c;
        String emailBody = PortalConstants.EMPTY_STRING;
        emailBody = emailTemplate.HtmlValue;
        emailBody = emailBody.replace(GROWER_NAME_KEY,growerName);
        emailBody = emailBody.replace(DEALER_NAME_KEY,contactObj.Account.Parent.Name);
        emailBody = emailBody.replace(CONTACT_INFO_KEY,EmailUtil.getContactInfoByCoop(coopType));
        emailBody = emailBody.replace(ConstantValues.REPLACE_LOGO_URL, EmailUtil.getLogoURLbyCoopType(coopType));
        email.subject = emailTemplate.Subject;        
        senderAddressList = EmailUtil.getOrgWideEmailAddress(FIELD_FINANCE_SENDER); 

        email.setHtmlBody(emailBody);
        email.setTemplateId(emailTemplate.Id); 
        email.setToAddresses(new String[] {emailIdToSend});
        email.setOrgWideEmailAddressId(senderAddressList[ConstantValues.ZERO_VALUE].Id); 
        emailsToSend.add(email);
        Messaging.sendEmail(emailsToSend);

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

        EmailTemplate emailTemplate = EmailUtil.getEmailTemplate(NEW_EMAIL_TEMPLATE_NAME);
        Messaging.SingleEmailMessage email = new  Messaging.SingleEmailMessage();
        String emailIdToSend = contactObj.New_Email__c;
        String coopType = contactObj.Account.Coop_Type__c;
        String emailBody = PortalConstants.EMPTY_STRING;
        emailIdToSend = String.valueOf(emailIdToSend);
        emailBody = emailTemplate.HtmlValue;

        emailBody = emailBody.replace(DEALER_NAME_KEY,contactObj.Account.Parent.Name);
        emailBody = emailBody.replace(BUTTON_BACKGROUND,EmailUtil.getColorByCoop(coopType));

        emailBody = emailBody.replace(OLD_EMAIL_KEY,contactObj.Email);
        emailBody = emailBody.replace(NEW_EMAIL_KEY,contactObj.New_Email__c);
        emailBody = emailBody.replace(VERIFICATION_LINK,verificationLink);

        senderAddressList = EmailUtil.getOrgWideEmailAddress(FIELD_FINANCE_SENDER); 


        emailBody = emailBody.replace(ConstantValues.REPLACE_LOGO_URL, EmailUtil.getLogoURLbyCoopType(coopType));
        email.subject = emailTemplate.Subject;        
        email.setHtmlBody(emailBody);
        email.setTemplateId(emailTemplate.Id); 
        email.setToAddresses(new String[] {emailIdToSend});
        email.setOrgWideEmailAddressId(senderAddressList[ConstantValues.ZERO_VALUE].Id); 
        emailsToSend.add(email);
        Messaging.sendEmail(emailsToSend);

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
            'prev_email' => contactObj.Email,
            'new_email' => contactObj.New_Email__c,
            'contactId' => contactObj.Id,
            'coopType' => contactObj.Account.Coop_Type__c,
            'legalEntityType' => contactObj.Account.clcommon__Legal_Entity_Type__r.Name,
            'attemptNum' => String.valueOf(contactObj.Verification_Attempt__c)
        };
        String jwtToken = JWTUtil.generateEmailVerificationToken(payloadMap);
        if(contactObj.Account.Coop_Type__c == PortalConstants.GROWMARK_COOP_TYPE){
            verificationLink = GROWER_EMAIL_VERIFICATION_LINK_GMK + PortalConstants.QUESTION_MARK_STRING + TOKEN + jwtToken;
        }else if(contactObj.Account.Coop_Type__c == PortalConstants.LANDUS_COOP_TYPE){
            verificationLink = GROWER_EMAIL_VERIFICATION_LINK + LANDUS  + PortalConstants.AMPERSAND_STRING + TOKEN + jwtToken;
        }
        else{
            verificationLink = GROWER_EMAIL_VERIFICATION_LINK + CFA + PortalConstants.AMPERSAND_STRING + TOKEN + jwtToken;
        }
        return verificationLink;
    }
}