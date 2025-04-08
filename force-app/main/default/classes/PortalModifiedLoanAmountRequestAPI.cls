/**********************************************************************************************************************
 * @description       : This API is called from portal, requesting to change the loan amount for a particular loan
 *                      and send an email to the CFA team.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 02-15-2025
 * @last modified by  : Ayan Bhowmik
**********************************************************************************************************************/
global without sharing class PortalModifiedLoanAmountRequestAPI implements clcommon.PortalCustomRemoteAPI1  {
    
    private static final String REPLACE_CERTIFIED_LENDER = '{!CertifiedLender}';
    private static final String GROWER_CITY='{!GrowerCity}';
    private static final String APPLICATION_NOTE_DESCRIPTION='Loan Amount Modification Request \n Current Loan Amount : ';
    private static final String MODIFIED_LOAN_AMOUNT='\n Modified Loan Amount : ';
    private static final String CFA_PRODUCTION_AG_EMAIL = System.label.Production_AG_Email;
    private static final String GMK_PRODUCTION_AG_EMAIL = System.label.GMK_Production_AG_Email;
    private static String loanAmount;
    private static String loanNumber;
    private static String growerName;
    private static String applicationId;

   /**
    * @description Purpose of this method is to check and all the required parameter.
    * @param argumentsFromPortal 
    * @return  `List<User>`
    * @exception 
    */
    private List<User> checkParameter(Map<String, Object> argumentsFromPortal) {
        List<User> currentUserList = new List<User>();
        currentUserList = [SELECT Id,Email,
                                    accountId 
                                FROM User 
                                WHERE Id =:UserInfo.getUserId()];

        if(currentUserList.isEmpty()){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        if (null == argumentsFromPortal.get(PortalConstants.GROWER_NAME) 
                    || null == argumentsFromPortal.get(PortalConstants.LOAN_AMOUNT)
                    || null == argumentsFromPortal.get(PortalConstants.LOAN_NUMBER)) { 
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING); 
        }
        if(Integer.valueOf(argumentsFromPortal.get(PortalConstants.LOAN_AMOUNT))<=PortalConstants.ZERO_VALUE){
            throw new CustomException(PortalConstants.INVALID_LOAN_AMOUNT);
        }
        return currentUserList;
    }

    /**
     * @description Validate logged in user permission
     * @param applicationId 
     * @exception 
     */
    private static void validateUser(String applicationId){
        Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationId);
        if (!isValidUser) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }
    }

    /**
    * @description - Purpose of this method is to send email to the CFA team, requesting for a a loan amount modification.
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames, 
                                                Map<String, Object> argumentsFromPortal) {
        genesis__Application_Note__c updateNoteObj = new genesis__Application_Note__c();
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        clcommon.Response response = new clcommon.Response();
        try {
            List<User> userObjList = checkParameter(argumentsFromPortal);       
            //Check required params.
            growerName = (String)argumentsFromPortal.get(PortalConstants.GROWER_NAME);
            loanAmount = String.valueOf(argumentsFromPortal.get(PortalConstants.LOAN_AMOUNT));
            loanNumber = String.valueOf(argumentsFromPortal.get(PortalConstants.LOAN_NUMBER));
            applicationId = String.valueOf(argumentsFromPortal.get(PortalConstants.APPLICATION_ID));
            applicationList = [SELECT Id, 
                                      genesis__loan_amount__c,
                                      Dealer_Name__r.id, 
                                      Dealer_Name__r.Name,
                                      Dealer_Name__r.Coop_Type__c,
                                      Dealer_Name__r.BillingState,
                                      Dealer_Name__r.BillingCity,
                                      Certified_Lender__r.Name,
                                      (SELECT Id,
                                              City__c,
                                              State__c
                                      FROM genesis__Parties__r)
                                FROM genesis__Applications__c
                                WHERE Id =:applicationId
                                AND genesis__Status__c =:PortalConstants.ACTIVE_APPLICATION_STATUS
                                LIMIT 1];
            if(applicationList.isEmpty()){
                throw new CustomException(PortalConstants.APPLICATION_ERROR);
            }
           
            validateUser(applicationList[PortalConstants.ZERO_VALUE].id);

            updateNoteObj.genesis__Application__c = applicationList[PortalConstants.ZERO_VALUE].Id;
            updateNoteObj.Updated_Loan_Amount__c = Decimal.valueOf(loanAmount);
            updateNoteObj.Current_Loan_Amount__c = applicationList[PortalConstants.ZERO_VALUE].genesis__loan_amount__c;
            updateNoteObj.genesis__Note__c = APPLICATION_NOTE_DESCRIPTION 
                                            + applicationList[PortalConstants.ZERO_VALUE].genesis__loan_amount__c 
                                            + MODIFIED_LOAN_AMOUNT 
                                            + loanAmount;
            Database.insert(updateNoteObj, true);
            Map<String,Object> emailLogMap = new Map<String,Object>{
                ConstantValues.KEY_CLASS_NAME => PortalModifiedLoanAmountRequestAPI.class.getName(),
                ConstantValues.KEY_FROM_ADDRESS => userObjList[0].Email
            };
            Messaging.SingleEmailMessage email = createEmailForAgLoanOfficer(applicationList,emailLogMap);
            Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}, true);
            String emailStatus = results[0].isSuccess()?ConstantValues.SUCCESS_STATUS : ConstantValues.FAILURE_STATUS;
            
            emailLogMap.put(ConstantValues.KEY_EMAIL_STATUS, emailStatus);
            emailLogMap.put(ConstantValues.KEY_EMAIL_TEMPLATE, email.getTemplateName());
            if(emailStatus == ConstantValues.FAILURE_STATUS){
                emailLogMap.put(ConstantValues.KEY_ERROR_MESSAGE,results[0].getErrors()[0].getMessage());
            }
            saveEmailLog(emailLogMap);
            if (!results[PortalConstants.ZERO_VALUE].success) {
                throw new CustomException(PortalConstants.EMAIL_SEND_FAILED); 
            }
            response.status = clcommon.Constants.SUCCESS;
        }catch (CustomException customExceptionObj) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customExceptionObj.getMessage();
            PortalHelper.saveExceptionLog(customExceptionObj, PortalModifiedLoanAmountRequestAPI.class.getName());
        }catch (Exception exceptionObj) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(exceptionObj, PortalModifiedLoanAmountRequestAPI.class.getName());
        }
        return response;
    }

     /**
     * @description Purpose of this is to save email log im salesforce
     * @param emailLogMap 
     */
    private static void saveEmailLog(Map<String,Object> emailLogMap){
        clcommon__Notification__c notificationObj = EmailUtil.getEmailLog(emailLogMap);
        List<clcommon__Notification__c> resultLogList = new List<clcommon__Notification__c>();
        resultLogList.add(notificationObj);
        if(resultLogList != null){
            Database.insert(resultLogList,true);
        }
    }
   
    /**
     * @description Purpose of this method is to send out email to AG Loan Officer when loan amount modification is requested.
     * @param applicationList 
     * @param emailLogMap 
     * @return  `Messaging.SingleEmailMessage`
     */
    private Messaging.SingleEmailMessage createEmailForAgLoanOfficer(List<genesis__Applications__c> applicationList,Map<String,Object> emailLogMap){
        String plainBody;
        List<OrgWideEmailAddress> senderAddressList = new List<OrgWideEmailAddress>();
        EmailTemplate emailTemplate = getEmailTemplate(EmailUtil.getLabelType(applicationList[PortalConstants.ZERO_VALUE].Dealer_Name__r.id));
        Messaging.SingleEmailMessage email = createEmail(EmailUtil.getLabelType(applicationList[PortalConstants.ZERO_VALUE].Dealer_Name__r.id),emailLogMap);
        email.subject = emailTemplate.Subject.replace(PortalConstants.REPLACE_GROWER_NAME , growerName);
        senderAddressList = PortalApplicationOriginationHelper.getOrgWideEmailAddress(ConstantValues.ORG_WIDE_NO_REPLY_EMAIL_ADDRESS);
        email.setOrgWideEmailAddressId(senderAddressList[0].Id);
        email.setTemplateId(emailTemplate.Id);
        plainBody = emailTemplate.HtmlValue;
        plainBody = plainBody.replace(PortalConstants.REPLACE_LOAN_NUMBER, loanNumber);
        plainBody = plainBody.replace(PortalConstants.REPLACE_LOAN_AMOUNT, loanAmount);
        plainBody = plainBody.replace(PortalConstants.REPLACE_GROWER_NAME, growerName);
        plainBody = plainBody.replace(REPLACE_CERTIFIED_LENDER, UserInfo.getName());
        plainBody = plainBody.replace(PortalConstants.REPLACE_LOGO_URL, EmailUtil.setLogoURL(applicationList[PortalConstants.ZERO_VALUE].Dealer_Name__r.id));
        if(applicationList[0].genesis__Parties__r[0].City__c != null){
            plainBody = plainBody.replace(GROWER_CITY, applicationList[0].genesis__Parties__r[0].City__c );
        }else{
            plainBody = plainBody.replace(GROWER_CITY, PortalConstants.EMPTY_STRING);
        }
        if(applicationList[0].genesis__Parties__r[0].State__c != null){
            plainBody = plainBody.replace(PortalConstants.GROWER_STATE, applicationList[0].genesis__Parties__r[0].State__c );
        }else{   
            plainBody = plainBody.replace(PortalConstants.GROWER_STATE, PortalConstants.EMPTY_STRING);
        }
        plainBody = plainBody.replace(REPLACE_CERTIFIED_LENDER, UserInfo.getName());
        if(applicationList[PortalConstants.ZERO_VALUE].Dealer_Name__c != null){
            plainBody = plainBody.replace(PortalConstants.REPLACE_DEALER_NAME,
                                            applicationList[PortalConstants.ZERO_VALUE].Dealer_Name__r.Name);
        }
        if(applicationList[PortalConstants.ZERO_VALUE].Dealer_Name__c != null 
                && applicationList[PortalConstants.ZERO_VALUE].Dealer_Name__r.BillingCity != null){
            plainBody = plainBody.replace(PortalConstants.REPLACE_DEALER_CITY,
                                            applicationList[PortalConstants.ZERO_VALUE].Dealer_Name__r.BillingCity);
        }
        if(applicationList[PortalConstants.ZERO_VALUE].Dealer_Name__c != null 
                && applicationList[PortalConstants.ZERO_VALUE].Dealer_Name__r.BillingState != null){
            plainBody = plainBody.replace(PortalConstants.REPLACE_DEALER_STATE,
                                            applicationList[PortalConstants.ZERO_VALUE].Dealer_Name__r.BillingState);    
        }
        email.setHtmlBody(plainBody);
        emailLogMap.put(ConstantValues.KEY_MESSAGE,plainBody);
        return email;
    }

    /**
     * @description Purpose of this method is to get email template.
     * @param coopType 
     * @return  `EmailTemplate`
     * @exception 
     */
    private EmailTemplate getEmailTemplate(String coopType){
        EmailTemplate emailTemplate = CFAOriginationHelperClass.emailTemplateMappingMetadata(coopType,
                                                                                                PortalConstants.LOAN_AMOUNT_MODIFICATION_EMAIL);

        if(emailTemplate == null){
            throw new CustomException(PortalConstants.EMAIL_TEMPLATE_ERROR);
        }
        return emailTemplate;
    }

   /**
    * @description Purpose of this method is to create email and set the addresses according to coop type.
    * @param coopType 
    * @param emailLogMap 
    * @return  `Messaging.SingleEmailMessage`
    */
    private Messaging.SingleEmailMessage createEmail(String coopType,Map<String,Object> emailLogMap){
        Messaging.SingleEmailMessage email = new  Messaging.SingleEmailMessage();
        if (coopType == PortalConstants.GROWMARK_COOP_TYPE) {
            email.setToAddresses(new String[] {GMK_PRODUCTION_AG_EMAIL});
            emailLogMap.put(ConstantValues.KEY_TO_ADDRESS,GMK_PRODUCTION_AG_EMAIL);
        }else{
            email.setToAddresses(new String[] {CFA_PRODUCTION_AG_EMAIL});
            emailLogMap.put(ConstantValues.KEY_TO_ADDRESS,CFA_PRODUCTION_AG_EMAIL);
        }
        return email;
    }
}