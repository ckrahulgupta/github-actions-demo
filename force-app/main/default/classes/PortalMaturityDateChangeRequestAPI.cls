/**********************************************************************************************************************
 * @description       : This API is called from portal, requesting to change the maturity date for a particular loan
 *                      and send an email to the CFA team.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 02-15-2025
 * @last modified by  : Ayan Bhowmik
**********************************************************************************************************************/
global without sharing class PortalMaturityDateChangeRequestAPI implements clcommon.PortalCustomRemoteAPI1  {
    
    // parameters specific for this class [start]
    private static final String CLASS_NAME = PortalMaturityDateChangeRequestAPI.class.getName();
    private static final String DATE_FORMAT = 'MMMM d, yyyy';
    private static final String KEY_MATURITY_DATE = 'maturityDate';
    private static final String KEY_CURRENT_MATURITY_DATE = 'currentMaturityDate';
    private static final String APPLICATION_NOTE_DESCRIPTION='Maturity Date Modification Request \n Current Maturity Date : ';
    private static final String MODIFIED_MATURITY_DATE = '\n Modified Maturity Date : ';
    private static final String CERTIFIED_LENDER = '{!CertifiedLender}';
    String dateOutput;
    String loanNumber;
    String growerName;
    String applicationId;
    // parameters specific for this class [end]

    /** 
    * @description - Purpose of this method is to send email to the CFA team, requesting for a maturity date modification.
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames, 
                                                Map<String, Object> argumentsFromPortal) {
        
        Date oldDate;
        Datetime newDate;
        String newMaturityDate;
        String currentMaturityDate;
        clcommon.Response response = new clcommon.Response();
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        genesis__Application_Note__c updateNoteObj = new genesis__Application_Note__c();
        try {
            checkArguments(argumentsFromPortal);
            growerName = (String)argumentsFromPortal.get(PortalConstants.GROWER_NAME);
            loanNumber = String.valueOf(argumentsFromPortal.get(PortalConstants.LOAN_NUMBER));
            applicationId = String.valueOf(argumentsFromPortal.get(PortalConstants.APPLICATION_ID));
            newMaturityDate = (String)argumentsFromPortal.get(KEY_MATURITY_DATE);
            newMaturityDate = newMaturityDate.substring(PortalConstants.FIVE_VALUE,PortalConstants.SEVEN_VALUE)+PortalConstants.SLASH_STRING+newMaturityDate.substring(PortalConstants.EIGHT_VALUE,PortalConstants.TEN_VALUE)+PortalConstants.SLASH_STRING+newMaturityDate.substring(PortalConstants.ZERO_VALUE,PortalConstants.FOUR_VALUE);
            newDate = Date.parse(newMaturityDate);
            currentMaturityDate = (String)argumentsFromPortal.get(KEY_CURRENT_MATURITY_DATE);
            currentMaturityDate = currentMaturityDate.substring(PortalConstants.FIVE_VALUE,PortalConstants.SEVEN_VALUE)+PortalConstants.SLASH_STRING+currentMaturityDate.substring(PortalConstants.EIGHT_VALUE,PortalConstants.TEN_VALUE)+PortalConstants.SLASH_STRING+currentMaturityDate.substring(PortalConstants.ZERO_VALUE,PortalConstants.FOUR_VALUE);
            oldDate = Date.parse(currentMaturityDate);
            if(oldDate.daysBetween(Date.parse(newMaturityDate)) > PortalConstants.SIXTY_FIVE_VALUE){
                throw new CustomException(PortalConstants.NEW_MATURITY_DATE_IS_BEYOND_SIXTY_DAYS);
            }
            else if(oldDate.daysBetween(Date.parse(newMaturityDate)) < PortalConstants.ONE_VALUE){
                throw new CustomException(PortalConstants.NEW_MATURITY_IS_PAST_DATE);
            }
            if(Date.parse(newMaturityDate).day() != PortalConstants.FIFTEEN_VALUE){
                throw new CustomException(PortalConstants.NEW_MATURITY_DATE_IS_NOT_FIFTEENTH);
            } 
            dateOutput = newDate.formatGMT(DATE_FORMAT);
            applicationList = [SELECT Id, 
                                    genesis__Maturity_Date__c,
                                    Dealer_Name__r.Name,
                                    Dealer_Name__r.Coop_Type__c,
                                    Certified_Lender__r.Name,
                                    Dealer_Name__r.BillingCity,
                                    Dealer_Name__r.BillingState,
                                    Dealer_Name__c,
                                    (SELECT Id,
                                            City__c,
                                            State__c
                                    FROM genesis__Parties__r)
                                FROM genesis__Applications__c
                                WHERE Id =: applicationId
                                AND genesis__Status__c =:PortalConstants.ACTIVE_APPLICATION_STATUS
                                LIMIT 1];
            updateNoteObj.genesis__Application__c = applicationList[0].Id;
            updateNoteObj.Modified_Maturity_Date__c = Date.parse(newMaturityDate);
            updateNoteObj.Current_Maturity_Date__c = applicationList[0].genesis__Maturity_Date__c;
            updateNoteObj.genesis__Note__c = APPLICATION_NOTE_DESCRIPTION
                                            + applicationList[0].genesis__Maturity_Date__c
                                            + MODIFIED_MATURITY_DATE
                                            + Date.parse(newMaturityDate);
            Database.insert(updateNoteObj, true);
            sendEmail(applicationList[0]);
            response.status = clcommon.Constants.SUCCESS;

        }catch (CustomException customExceptionObj) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customExceptionObj.getMessage();
            PortalHelper.saveExceptionLog(customExceptionObj, PortalMaturityDateChangeRequestAPI.class.getName());
        }catch (Exception exceptionObj) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(exceptionObj, PortalMaturityDateChangeRequestAPI.class.getName());
        }  
        return response;
    }

    /**
     * @description Purpose of this method is to get email template.
     * @param argumentsFromPortal 
     * @exception 
     */
    private void checkArguments(Map<String, Object> argumentsFromPortal){

        List<User> currentUserList = new List<User>();
        currentUserList = [SELECT Id, 
                                    accountId 
                                FROM User 
                                WHERE Id =: UserInfo.getUserId()];
        
        if(currentUserList.isEmpty()){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        
        //Check required params.
        if (null == argumentsFromPortal.get(PortalConstants.GROWER_NAME) 
                || null == argumentsFromPortal.get(PortalConstants.LOAN_NUMBER) 
                || null == argumentsFromPortal.get(KEY_MATURITY_DATE)
                || null == argumentsFromPortal.get(KEY_CURRENT_MATURITY_DATE)) { 
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING); 
        }
    }    

    /**
     * @description Purpose of this method is to get email template.
     * @param dealerId 
     * @return  `EmailTemplate`
     * @exception 
     */
    private EmailTemplate getEmailTemplate(String dealerId){
        EmailTemplate emailTemplate = CFAOriginationHelperClass.emailTemplateMappingMetadata(EmailUtil.getLabelType(dealerId),
                                                                                                PortalConstants.MATURITY_DATE_MODIFICATION_EMAIL);

        if(emailTemplate == null){
            throw new CustomException(PortalConstants.EMAIL_TEMPLATE_ERROR);
        }
        return emailTemplate;
    }
    
    /**
     * @description Purpose of this method is to create email and set the addresses according to coop type.
     * @param applicationObj 
     * @exception 
     */
    private void sendEmail(genesis__Applications__c applicationObj){

        String clName;
        String plainBody;
        String dealerName;
        String dealerCity = PortalConstants.EMPTY_STRING;
        String growerCity = PortalConstants.EMPTY_STRING;
        String dealerState = PortalConstants.EMPTY_STRING;
        String growerState = PortalConstants.EMPTY_STRING;
        EmailTemplate emailTemplate = new EmailTemplate();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<OrgWideEmailAddress> senderAddressList = new List<OrgWideEmailAddress>();

        clName = UserInfo.getName();
        dealerName = applicationObj.Dealer_Name__r.Name; 
        if(applicationObj.Dealer_Name__c != null && applicationObj.Dealer_Name__r.BillingCity != null){
            dealerCity = applicationObj.Dealer_Name__r.BillingCity;
        }
        if(applicationObj.Dealer_Name__c != null && applicationObj.Dealer_Name__r.BillingState != null){
            dealerState = applicationObj.Dealer_Name__r.BillingState;
        }
        if(applicationObj.genesis__Parties__r[0].City__c != null){
            growerCity = applicationObj.genesis__Parties__r[0].City__c;
        }
        if(applicationObj.genesis__Parties__r[0].State__c != null){
            growerState = applicationObj.genesis__Parties__r[0].State__c;
        }
        emailTemplate = getEmailTemplate(applicationObj.Dealer_Name__c);
        email = EmailUtil.createEmail(applicationObj.Dealer_Name__r.Coop_Type__c);
        email.subject = emailTemplate.Subject.replace(PortalConstants.REPLACE_GROWER_NAME , growerName);
        email.setTemplateId(emailTemplate.Id);
        senderAddressList = PortalApplicationOriginationHelper.getOrgWideEmailAddress(ConstantValues.ORG_WIDE_NO_REPLY_EMAIL_ADDRESS);
        email.setOrgWideEmailAddressId(senderAddressList[0].Id);
        plainBody = emailTemplate.HtmlValue;
        plainBody = plainBody.replace(PortalConstants.REPLACE_LOGO_URL,
                                        EmailUtil.setLogoURL(applicationObj.Dealer_Name__c));
        plainBody = plainBody.replace(PortalConstants.REPLACE_LOAN_NUMBER, loanNumber);
        plainBody = plainBody.replace(PortalConstants.REPLACE_MATURITY_DATE, dateOutput);
        plainBody = plainBody.replace(PortalConstants.REPLACE_GROWER_NAME, growerName);
        plainBody = plainBody.replace(PortalConstants.REPLACE_DEALER_NAME, dealerName);
        plainBody = plainBody.replace(CERTIFIED_LENDER, clName);
        plainBody = plainBody.replace(PortalConstants.GROWER_CITY, growerCity);
        plainBody = plainBody.replace(PortalConstants.GROWER_STATE, growerState);
        plainBody = plainBody.replace(PortalConstants.REPLACE_DEALER_CITY, dealerCity);
        plainBody = plainBody.replace(PortalConstants.REPLACE_DEALER_STATE, dealerState);    
        email.setHtmlBody(plainBody);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}, false);
        if (!results[PortalConstants.ZERO_VALUE].success) {
            throw new CustomException(PortalConstants.EMAIL_SEND_FAILED); 
        }
    }
}