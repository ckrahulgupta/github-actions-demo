/**********************************************************************************************************************
 * @description       : This class sends an email to the respective certified lender,on request by a sales agent for  
 *                      completing the Credit reference of an application.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 02-15-2025
 * @last modified by  : Ayan Bhowmik
**********************************************************************************************************************/

global without sharing class PortalSendCreditReferenceEmailAPI  implements clcommon.PortalCustomRemoteAPI1 {
    
    // parameters specific for this class [start]
    private static final String KEY_ACCOUNT_ID = 'accountId';
    private static final String SALES_AGENT_NAME = 'salesAgentName';
    private static final String REPLACE_APP = 'APP-';
    private static final String LANDUS_SHARED_EMAIL = System.Label.Landus_Shared_Email;
    private static final String CREDIT_REFERENCE_API = PortalSendCreditReferenceEmailAPI.class.getName();
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
        String clAccountId;
        String applicationId;
        String growerCity = PortalConstants.EMPTY_STRING;
        String growerState = PortalConstants.EMPTY_STRING;
        String applicationNumber;
        Contact clContactObj = new Contact();
        List<Contact> clContactList = new List<Contact>();
        List<User> loggedInUser = getLoggedInUser();
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        List<String> receiverAddressList = new List<String>();
        Map<String, String> portalArgumentsMap = new Map<String, String>();
        Map<String, String> growerDetailsMap = new Map<String, String>();
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
        Map<String, String> dealerCIFToCoopMap = new Map<String, String>();
        Map<String, String> emailSubjectParamMap = new Map<String, String>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<OrgWideEmailAddress> senderAddressList = new List<OrgWideEmailAddress>();
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();

        try {
            
            portalArgumentsMap = checkArguments(argumentsFromPortal);
            applicationId=portalArgumentsMap.get(PortalConstants.APPLICATION_ID);
            clAccountId=portalArgumentsMap.get(KEY_ACCOUNT_ID);

            applicationList =[SELECT Id,
                                    Name, 
                                    Certified_Lender__c,
                                    Sales_Agent__r.Name,
                                    Internal_Reference_Code__c,
                                    Coop_Type__c,
                                    Dealer_Name__r.Coop_Type__c,
                                    Dealer_Name__r.CIF_Number__c,
                                    genesis__Contact__r.Name,
                                    genesis__Account__r.Name,
                                    genesis__Account__r.clcommon__Legal_Entity_Type__c,
                                    genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                    Dealer_Applicant_Relationship__r.Applicant__c,
                                    Dealer_Applicant_Relationship__r.Applicant_Contact__c	,
                                    (SELECT ID,
                                            City__c,
                                            State__c
                                     FROM genesis__Parties__r
                                     WHERE clcommon__Type__r.Name= :PortalConstants.BORROWER_PARTY_NAME)
                              FROM genesis__Applications__c
                              WHERE Id=:applicationId
                              LIMIT 1];
            
            //This query fetch the applicant account details.
            growerDetailsMap = PortalApplicationOriginationHelper.getDealerSpecificGrowerDetails(applicationList[0]);
            growerName = growerDetailsMap.get(PortalConstants.GROWER_NAME);
            growerCity = growerDetailsMap.get(PortalConstants.KEY_GROWER_CITY);
            growerState = growerDetailsMap.get(PortalConstants.KEY_GROWER_STATE);
           
            //This query fetch the Certified Lender's contact details.
            clContactList = [SELECT Id,
                                Email,
                                AccountId 
                            FROM Contact
                            WHERE AccountId=:clAccountId];
            clContactObj=clContactList[0];
            if(clContactObj.Email == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            applicationNumber = applicationList[0].Name;
            
            applicationList[0].Certified_Lender__c = clContactObj.AccountId;
            Database.update(applicationList, true);

            receiverAddressList.add(clContactObj.Email);
            if(applicationList[0].Coop_Type__c == PortalConstants.LANDUS_COOP_TYPE){
                receiverAddressList.add(LANDUS_SHARED_EMAIL);
            }


            dealerCIFToCoopMap.put(applicationList[0].Dealer_Name__r.CIF_Number__c, applicationList[0].Dealer_Name__r.Coop_Type__c);

            CFAOriginationHelperClass.getAdditionalRecipientEmailForSingleTransaction(dealerCIFToCoopMap,
                                                                                        PortalConstants.CREDIT_REFERENCE_EMAIL_TEMPLATE,
                                                                                        receiverAddressList);

            emailTemplateList = PortalHelper.getEmailTemplateList(PortalConstants.CREDIT_REFERENCE_EMAIL_TEMPLATE);
            CFAOriginationHelperClass.checkEmptyList(emailTemplateList, PortalConstants.EMAIL_TEMPLATE_ERROR);

            email.setToAddresses(receiverAddressList);
            senderAddressList = PortalApplicationOriginationHelper.getOrgWideEmailAddress(ConstantValues.ORG_WIDE_NO_REPLY_EMAIL_ADDRESS);
            email.setOrgWideEmailAddressId(senderAddressList[0].Id);            
            emailSubjectParamMap.put(PortalConstants.GROWER_NAME, growerName);
            emailSubjectParamMap.put(PortalConstants.KEY_GROWER_CITY, growerCity);
            emailSubjectParamMap.put(PortalConstants.KEY_GROWER_STATE, growerState);

            //adding sa admin name if he submits for credit reference
            if(loggedInUser[0].Account.RecordType.Name == PortalConstants.SALES_AGENT_ADMIN){
                emailSubjectParamMap.put(SALES_AGENT_NAME, loggedInUser[0].Name);
            }else{
                emailSubjectParamMap.put(SALES_AGENT_NAME, applicationList[0].Sales_Agent__r.Name);
            }

            email.subject = createEmailSubject(emailSubjectParamMap, emailTemplateList);

            email.setTemplateId(emailTemplateList[0].Id);
            plainBody = emailTemplateList[0].HtmlValue;
            plainBody = plainBody.replace(PortalConstants.REPLACE_APPLICATION_ID, applicationNumber.replace(REPLACE_APP,PortalConstants.EMPTY_STRING));
            plainBody = plainBody.replace(PortalConstants.REPLACE_GROWER_NAME , growerName);
            plainBody = replaceSalesAgentAndIrc(applicationList[0], plainBody);
            plainBody = plainBody.replace(PortalConstants.REPLACE_LOGO_URL,EmailUtil.setLogoURL(applicationList[0].Dealer_Name__c));
            email.setHtmlBody(plainBody);
            sendEmail(email);
            
            response.status = clcommon.Constants.SUCCESS;
        }catch (CustomException customExceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customExceptionObj.getMessage();
            PortalHelper.saveExceptionLog(customExceptionObj, CREDIT_REFERENCE_API); 
        }catch (Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = exceptionObj.getMessage();
            PortalHelper.saveExceptionLog(exceptionObj, CREDIT_REFERENCE_API); 
        }
        return response;
    }

    /**
    * @description replacing sa, sa Admin, IRC in email body
    * @author Ravi Ranjan | 01-24-2024 
    * @param applicationObj 
    * @param plainBody 
    * @return String 
    **/
    private static String replaceSalesAgentAndIrc(genesis__Applications__c applicationObj, String plainBody){
        //put sa admin name 
        List<User> loggedInUser = getLoggedInUser();
        if(loggedInUser[0].Account.RecordType.Name == PortalConstants.SALES_AGENT_ADMIN){
            plainBody = plainBody.replace(PortalConstants.REPLACE_SALES_AGENT_NAME, loggedInUser[0].Name);
        }else{
            plainBody = plainBody.replace(PortalConstants.REPLACE_SALES_AGENT_NAME, applicationObj.Sales_Agent__r.Name);
        }

        if(applicationObj.Internal_Reference_Code__c != null){
            plainBody = plainBody.replace(PortalConstants.REPLACE_INTERNAL_REFERENCE_CODE, applicationObj.Internal_Reference_Code__c);
        }else{
            plainBody = plainBody.replace(PortalConstants.REPLACE_INTERNAL_REFERENCE_CODE, PortalConstants.EMPTY_STRING);
        }
        return plainBody;

    }

    /**
     * @description : fetches the current logged in user 
     * @return  `List<User>`
     * @exception 
     */
    private static List<User> getLoggedInUser() {
        List<User> loggedInUserList = [SELECT Id,
                                            Name,
                                            AccountId,
                                            ContactId,
                                            Account.ParentId,
                                            Account.Parent.Name,
                                            Account.RecordType.Name
                                        FROM User
                                        WHERE Id = :UserInfo.getUserId()];

        CFAOriginationHelperClass.checkEmptyList(loggedInUserList, PortalConstants.USER_NOT_AUTHORISED);

        return loggedInUserList;
    }

    
    /**
    * @description This method checks the arguments are valid or not ans also checks if it is a valid user
    * @author Rakesh Saraf | 11-21-2024 
    * @param argumentsFromPortal 
    * @return Map<String, String> 
    **/
    private Map<String,String> checkArguments(Map<String, Object> argumentsFromPortal){
        String applicationId;
        String clAccountId;

        if (null == argumentsFromPortal.get(PortalConstants.APPLICATION_ID)) { 
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING); 
        }
        applicationId = (String)argumentsFromPortal.get(PortalConstants.APPLICATION_ID);

        //This query fetch the details of certified lenders,the account and contact associated with the application.
        Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationId); 
        if (!isValidUser) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }

        if (null == argumentsFromPortal.get(KEY_ACCOUNT_ID)) { 
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING); 
        }
        clAccountId = (String)argumentsFromPortal.get(KEY_ACCOUNT_ID);

        return new Map<String,String>{
                PortalConstants.APPLICATION_ID=>applicationId,
                KEY_ACCOUNT_ID=>clAccountId      
            };
    }
    
    /**
     * @description This method creates the email body.
     * @param emailSubjectParamMap 
     * @param emailTemplateList 
     * @return  `String`
     */
    private String createEmailSubject(Map<String, String> emailSubjectParamMap, List<EmailTemplate> emailTemplateList){
        String emailSubject;
        String growerName = emailSubjectParamMap.get(PortalConstants.GROWER_NAME);
        String growerCity = emailSubjectParamMap.get(PortalConstants.KEY_GROWER_CITY);
        String growerState = emailSubjectParamMap.get(PortalConstants.KEY_GROWER_STATE);
        String salesAgentName = emailSubjectParamMap.get(SALES_AGENT_NAME);

        emailSubject = emailTemplateList[0].Subject;
        emailSubject = emailSubject.replace(PortalConstants.REPLACE_GROWER_NAME , growerName);
        emailSubject = emailSubject.replace(PortalConstants.REPLACE_SALES_AGENT_NAME , salesAgentName);
        if(!String.isBlank(growerCity)){
            emailSubject = emailSubject.replace(PortalConstants.REPLACE_GROWER_CITY , growerCity);
        }
        else{
            emailSubject = emailSubject.replace( PortalConstants.REMOVE_GROWER_CITY, PortalConstants.EMPTY_STRING);
        }
        if(!String.isBlank(growerState)){
            emailSubject = emailSubject.replace(PortalConstants.REPLACE_GROWER_STATE , growerState);
        }
        else{
            emailSubject = emailSubject.replace(PortalConstants.REMOVE_GROWER_STATE , PortalConstants.EMPTY_STRING);
        }
        return emailSubject;
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