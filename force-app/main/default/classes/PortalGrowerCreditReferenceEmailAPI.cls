/**********************************************************************************************************************
 * @description       : This class sends an email to the respective certified lender,on request by a grower for  
 *                      completing the Credit reference of an application.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 02-28-2025
 * @last modified by  : Shristy Kumari
**********************************************************************************************************************/

global without sharing class PortalGrowerCreditReferenceEmailAPI  implements clcommon.PortalCustomRemoteAPI1 {
    
    // parameters specific for this class [start]
    
    private static final String REPLACE_APP = 'APP-';
    private static final String LANDUS_SHARED_EMAIL =System.Label.Landus_Shared_Email;
    private static final String CLASS_NAME = PortalGrowerCreditReferenceEmailAPI.class.getName();
    // parameters specific for this class [end]

    /**
    * @description - Purpose of this method is to send email to the respective certified lender for Credit 
    *                reference of an application.
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                                String[] disclosureNames, 
                                                Map<String, Object> argumentsFromPortal) {
        String plainBody;
        String growerName;
        String applicationId;
        String growerCity = PortalConstants.EMPTY_STRING;
        String growerState = PortalConstants.EMPTY_STRING;
        String applicationNumber;
        String emailSubject = PortalConstants.EMPTY_STRING;
        List<Contact> clSaContactList = new List<Contact>();
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        List<String> receiverAddressList = new List<String>();
        Map<String, String> growerDetailsMap = new Map<String, String>();
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
        Map<String, String> dealerCIFToCoopMap = new Map<String, String>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        List<OrgWideEmailAddress> senderAddressList = new List<OrgWideEmailAddress>();
        
        try {
            applicationId = checkArguments(argumentsFromPortal);

            applicationList = [SELECT Id,
                                     Name, 
                                     Coop_Type__c,
                                     Sales_Agent__c,
                                     Sales_Agent__r.Name,
                                     Certified_Lender__c,
                              		 Certified_Lender__r.Name,
                                     Internal_Reference_Code__c,
                                     Dealer_Name__r.Coop_Type__c,
                                     Dealer_Name__r.CIF_Number__c,
                                     genesis__Contact__r.Name,
                                     genesis__Account__r.Name,
                                     genesis__Account__r.clcommon__Legal_Entity_Type__c,
                                     genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                     Dealer_Applicant_Relationship__r.Applicant__c,
                                     Dealer_Applicant_Relationship__r.Applicant_Contact__c,
                                     (SELECT ID,
                                             City__c,
                                             State__c
                                     FROM genesis__Parties__r 
                                     WHERE clcommon__Type__r.Name=:PortalConstants.BORROWER_PARTY_NAME)
                              FROM genesis__Applications__c
                              WHERE Id=:applicationId
                              LIMIT 1];

            CFAOriginationHelperClass.checkEmptyList(applicationList, PortalConstants.SOMETHING_WENT_WRONG);

            growerDetailsMap = getGrowerDetails(applicationList[0]);
            growerName = growerDetailsMap.get(PortalConstants.GROWER_NAME);
            growerCity = growerDetailsMap.get(PortalConstants.KEY_GROWER_CITY);
            growerState = growerDetailsMap.get(PortalConstants.KEY_GROWER_STATE);
        
            clSaContactList = getClOrSaContact(applicationList[0]);
            receiverAddressList.add(clSaContactList[0].Email);
            if(applicationList[0].Coop_Type__c == PortalConstants.LANDUS_COOP_TYPE){
                receiverAddressList.add(LANDUS_SHARED_EMAIL);
            }
            dealerCIFToCoopMap.put(applicationList[0].Dealer_Name__r.CIF_Number__c, applicationList[0].Dealer_Name__r.Coop_Type__c);

            CFAOriginationHelperClass.getAdditionalRecipientEmailForSingleTransaction(dealerCIFToCoopMap,
                                                                                        PortalConstants.GROWER_CREDIT_REFERENCE_EMAIL_TEMPLATE,
                                                                                        receiverAddressList);
            applicationNumber = applicationList[0].Name;
            emailTemplateList = PortalHelper.getEmailTemplateList(PortalConstants.GROWER_CREDIT_REFERENCE_EMAIL_TEMPLATE);
            CFAOriginationHelperClass.checkEmptyList(emailTemplateList, PortalConstants.EMAIL_TEMPLATE_ERROR);

            email.setToAddresses(receiverAddressList);
            senderAddressList = PortalApplicationOriginationHelper.getOrgWideEmailAddress(ConstantValues.ORG_WIDE_NO_REPLY_EMAIL_ADDRESS);
            email.setOrgWideEmailAddressId(senderAddressList[0].Id);

            emailSubject = emailTemplateList[0].Subject;
            emailSubject = emailSubject.replace(PortalConstants.REPLACE_GROWER_NAME , growerName);
            emailSubject = emailSubject.replace(PortalConstants.REPLACE_GROWER_CITY , growerCity);
            emailSubject = emailSubject.replace(PortalConstants.REPLACE_GROWER_STATE , growerState);
            email.subject = emailSubject;

            email.setTemplateId(emailTemplateList[0].Id);
            plainBody = emailTemplateList[0].HtmlValue;
            plainBody = plainBody.replace(PortalConstants.REPLACE_APPLICATION_ID, applicationNumber.replace(REPLACE_APP,PortalConstants.EMPTY_STRING));
            plainBody = plainBody.replace(PortalConstants.REPLACE_GROWER_NAME , growerName);
            plainBody = plainBody.replace(PortalConstants.REPLACE_LOGO_URL,EmailUtil.setLogoURL(applicationList[0].Dealer_Name__c));
            if (applicationList[0].Sales_Agent__c != null && applicationList[0].Sales_Agent__r.Name != null) {
                 plainBody = plainBody.replace(PortalConstants.REPLACE_SALES_AGENT_NAME, applicationList[0].Sales_Agent__r.Name);
            } 
            else {
                plainBody = plainBody.replace(PortalConstants.REPLACE_SALES_AGENT_NAME, PortalConstants.EMPTY_STRING);
            }
        
            if (applicationList[0].Internal_Reference_Code__c != null) {
                plainBody = plainBody.replace(PortalConstants.REPLACE_INTERNAL_REFERENCE_CODE, applicationList[0].Internal_Reference_Code__c);
            } else {
                plainBody = plainBody.replace(PortalConstants.REPLACE_INTERNAL_REFERENCE_CODE, PortalConstants.EMPTY_STRING);
            }
            email.setHtmlBody(plainBody);
            sendEmail(email);
            response.status = clcommon.Constants.SUCCESS;
        }catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, CLASS_NAME);
        }catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response;
    }
    /**
     * @description This method check the arguments are valid or not.
     * @param argumentsFromPortal 
     * @return  `String`
     */
    private String checkArguments(Map<String, Object> argumentsFromPortal){
        if (null == argumentsFromPortal.get(PortalConstants.APPLICATION_ID)) { 
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG); 
        }

        String applicationId=String.valueOf(argumentsFromPortal.get(PortalConstants.APPLICATION_ID));

        Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationId); 
        if (!isValidUser) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }

        return applicationId;
    }
    /**
     * @description This method send the grower details.
     * @param applicationObj 
     * @return  `Map<String, String>`
     */
    private Map<String, String> getGrowerDetails(genesis__Applications__c applicationObj){

        if(applicationObj.Certified_Lender__c == null 
                    & applicationObj.Sales_Agent__c == null 
                    & applicationObj.Dealer_Applicant_Relationship__r.Applicant__c == null
                    & applicationObj.Dealer_Applicant_Relationship__r.Applicant_Contact__c == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG); 
        }
        
        return PortalApplicationOriginationHelper.getDealerSpecificGrowerDetails(applicationObj);
    }
    /**
     * @description This method will send cl contact. If cl contact is not present then it wll send sa contact.
     * @param applicationObj 
     * @return  `Contact`
     */
    private List<Contact> getClOrSaContact(genesis__Applications__c applicationObj){
        List<Contact> clSaContactList = new List<Contact>();
        if(applicationObj.Certified_Lender__c != null){
            clSaContactList = [SELECT Id,
                                    Email,
                                    AccountId
                                FROM Contact
                                WHERE AccountId=:applicationObj.Certified_Lender__c];

        }
        else if(applicationObj.Sales_Agent__c != null){
            clSaContactList = [SELECT Id,
                                    Email,
                                    AccountId
                                FROM Contact
                                WHERE AccountId=:applicationObj.Sales_Agent__c];            
        }
        CFAOriginationHelperClass.checkEmptyList(clSaContactList, PortalConstants.NO_CL_OR_SA_FOUND);
        if(clSaContactList[0].Email == null 
                    | String.isBlank(clSaContactList[0].Email)){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        return clSaContactList;
    }
    /**
     * @description This method will send the email.
     * @param email 
     */
    private void sendEmail(Messaging.SingleEmailMessage email){
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}, false);
        if (!results[0].success) {
            throw new CustomException(ConstantValues.EMAIL_SEND_FAILED);
        }
    }
}