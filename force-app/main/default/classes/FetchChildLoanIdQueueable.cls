/**
 * @description       : This class is used to fetch the child loan ids from NLS and update on field fiinance
 * @author            : iAyush
 * @group             : 
 * @last modified on  : 03-25-2025
 * @last modified by  : Ayan Khanra
**/
global without sharing class FetchChildLoanIdQueueable implements Queueable , Database.AllowsCallouts{
    
    private static final String CLASS_NAME = FetchChildLoanIdQueueable.class.getName();
    String loanNumber;
    String applicationId;
    String loanId = '';
    Boolean doNotSendEmail;
    public static final String PAYLOAD = 'payload';
    public static final String DATA = 'data';
    public static final String LOAN_ID = 'loanId';
    private static final String EMAIL_TEMPLATE = 'Loan Booked Notification';
    private static final String LANDUS_SHARED_EMAIL = System.Label.Landus_Shared_Email;
    private static final String REPLACE_GROWER_NAME = '{!GrowerName}';
    private static final String REPLACE_LOAN_ID = '{!Loan ID}';   
    private static final String REPLACE_MATURITY_DATE = '{!Maturity Date}';
    private static final String REPLACE_IRC = '{!InternalReferenceCode}';
    private static final String REPLACE_SALES_AGENT = '{!SalesAgentName}';
    private static final String FIELD_STAFF_AGENT = 'Field Staff Agent';
    private static final String CL_OR_FSA = '{!clOrFsa}';
    private static final String CL_OR_FSA_NAME = '{!CertifiedLenderName}';
    private static final String SA_NOT_ASSIGNED = 'Sales Agent Not Assigned';
    private static final String REPLACE_CL = 'Certified Lender Name:';
    private static final String REPLACE_FSA = 'Field Staff Name:';
    private static final String LOAN_NUMBER = 'Loan_Number';
    private static final String ACCT_REF_NO = 'Acctrefno';
    genesis__Applications__c applicationObj = new genesis__Applications__c();

    /**
     * @description Constructor to assign the laon number and app id.
     * @param loanNumber 
     * @param applicationId 
     * @param doNotSendEmail
     */
    global FetchChildLoanIdQueueable(String loanNumber, String applicationId,Boolean doNotSendEmail){
        this.loanNumber = loanNumber;
        this.applicationId = applicationId;
        this.doNotSendEmail = doNotSendEmail;
    }
    /**
     * @description This method execute the integration framework cheks the evergreen eligibility.
     * @param context 
     */
    public void execute(QueueableContext context) {
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        genesis__Applications__c applicationToUpdate = new genesis__Applications__c();
        Map<String, Object> mainResponse = new Map<String, Object>();
        Map<String, Object> subResponse = new Map<String, Object>();
        List<Object> fieldResponse = new List<Object>();
        List<genesis__Application_Pricing_Detail__c> applicationChildLoans = new List<genesis__Application_Pricing_Detail__c>();
        List<genesis__Application_Pricing_Detail__c> updatedPricingList = new List<genesis__Application_Pricing_Detail__c>();
        try{
            requestParamMap.put(LOAN_ID, loanNumber);
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService( ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                ConstantValues.INTEGRATION_API_TYPE_GET_CHILD_LOANID,
                                                                                                                                queryIdMap, requestParamMap);
            if(responseObject.getBody() == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            mainResponse = (Map<String, Object>) JSON.deserializeUntyped(responseObject.getBody());
            subResponse = (Map<String, Object>) mainResponse.get(PAYLOAD);
            fieldResponse = (List<Object>) subResponse.get(DATA);
            getApplicationDetails();
            applicationChildLoans.addAll(applicationObj.genesis__Pricing_Details__r);
            PortalApplicationOriginationHelper.checkEmptyList(applicationChildLoans,PortalConstants.SOMETHING_WENT_WRONG);
            
            updatedPricingList = updateLoanNumberForTranche(applicationChildLoans, fieldResponse);
            applicationToUpdate = checkEvergreenEligibility();
            Database.Update(updatedPricingList, PortalConstants.TRUE_VALUE);
            Database.Update(applicationToUpdate, PortalConstants.TRUE_VALUE);
            if(!doNotSendEmail){
                sendEmail();
            }
        }
        catch (Exception exceptionObj) {
            PortalHelper.saveExceptionLog(exceptionObj, CLASS_NAME);
        }
    }
    /**
     * @description This method will update the loan number in child loan.
     * @param applicationChildLoans 
     * @param fieldResponse 
     * @return  `List<genesis__Application_Pricing_Detail__c>`
     */
    private List<genesis__Application_Pricing_Detail__c> updateLoanNumberForTranche(List<genesis__Application_Pricing_Detail__c> applicationChildLoans,
                                                                                        List<Object> fieldResponse){
        
        List<genesis__Application_Pricing_Detail__c> updatedPricingList = new List<genesis__Application_Pricing_Detail__c>();
        Map<String, String> loanNumberToLoanIdMap = new Map<String, String>();

        for(Object childLoan : fieldResponse){
            Map<String, Object> mapResponse = new Map<String, Object>();
            mapResponse = (Map<String,Object>) childLoan;
            if(mapResponse.get(LOAN_NUMBER) != null){
                loanNumberToLoanIdMap.put(String.valueOf(mapResponse.get(LOAN_NUMBER)), String.valueOf(mapResponse.get(ACCT_REF_NO)));
            }
        }
        for(genesis__Application_Pricing_Detail__c tranche : applicationChildLoans){
            if(tranche.Loan_Number__c != null && loanNumberToLoanIdMap.containsKey(tranche.Loan_Number__c)){
                tranche.Loan_Id__c = loanNumberToLoanIdMap.get(tranche.Loan_Number__c);
                updatedPricingList.add(tranche);
            }
        }
        return updatedPricingList;
    }
    
    /**
    * @description This method will check evergreen for user and update accordingly.
    * @return genesis__Applications__c 
    **/
    private genesis__Applications__c checkEvergreenEligibility(){
        if(applicationObj.genesis__Credit_Rating__c != null &&
            (applicationObj.genesis__Credit_Rating__r.Name != ConstantValues.CREDIT_RATE_4)){
                applicationObj = EvergreenCheckHandler.checkIsEvergreenEligible(applicationObj);
        }
        return applicationObj;
    }
    /**
     * @description This method will send the email to cl and sa that application has been booked
     */
    private void sendEmail(){
        String loanNumber = applicationObj.genesis__Loan_Number__c;
        String loanAmount = formatAmount(applicationObj.genesis__Loan_Amount__c.format());
        String maturityDate = applicationObj.genesis__Maturity_Date__c.format();
        String irc = ConstantValues.EMPTY_STRING;
        String salesAgent = SA_NOT_ASSIGNED;
        String clOrFsa = ConstantValues.EMPTY_STRING;
        String clOrFsaName = ConstantValues.EMPTY_STRING;
        String growerName = ConstantValues.EMPTY_STRING;
        String coopType = applicationObj.Dealer_Name__r.Coop_Type__c;
        String dealerId = applicationObj.Dealer_Name__r.Id;
        String emailSubject =  ConstantValues.EMPTY_STRING;
        String emailBody = ConstantValues.EMPTY_STRING;
        Contact contactObj = new Contact();
        List<String> toAddresses = new List<String>();
        List<OrgWideEmailAddress> senderAddressList = new List<OrgWideEmailAddress>();
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
        Map<String, String> dealerCIFToCoopMap = new Map<String, String>();
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        contactObj = [SELECT Id, 
                                Name 
                            FROM Contact 
                            WHERE AccountId = :applicationObj.genesis__Account__c];
        
        growerName = contactObj.Name;
        emailTemplateList = PortalHelper.getEmailTemplateList(EMAIL_TEMPLATE);
        senderAddressList = CFAOriginationHelperClass.getOrgWideEmailAddress();                                                       
        if(emailTemplateList.isEmpty()){
            throw new CustomException(PortalConstants.EMAIL_TEMPLATE_ERROR);
        }
        if(applicationObj.CreatedBy.Account.RecordType.Name == FIELD_STAFF_AGENT){
            clOrFsaName = applicationObj.CreatedBy.Account.Name;
            clOrFsa = REPLACE_FSA;
            toAddresses.add(applicationObj.CreatedBy.Email);
        }else{
            clOrFsaName = applicationObj.Certified_Lender__r.Name;
            clOrFsa = REPLACE_CL;
        }
        if(applicationObj.Certified_Lender__r.clcommon__Email__c != null){
            toAddresses.add(applicationObj.Certified_Lender__r.clcommon__Email__c);
        }
        if(applicationObj.Sales_Agent__c != null){
            salesAgent = applicationObj.Sales_Agent__r.Name;
            if(applicationObj.Sales_Agent__r.clcommon__Email__c != null){
                toAddresses.add(applicationObj.Sales_Agent__r.clcommon__Email__c);
            }
        }
        if(applicationObj.Internal_Reference_Code__c != null){
            irc = applicationObj.Internal_Reference_Code__c;
        }
        if(coopType == PortalConstants.LANDUS_COOP_TYPE){
            toAddresses.add(LANDUS_SHARED_EMAIL);
        }
        dealerCIFToCoopMap.put(applicationObj.Dealer_Name__r.CIF_Number__c, coopType);

        CFAOriginationHelperClass.getAdditionalRecipientEmailForSingleTransaction(dealerCIFToCoopMap,
                                                                                    EMAIL_TEMPLATE,
                                                                                    toAddresses);
        emailSubject = emailTemplateList[ConstantValues.ZERO_VALUE].subject;
        email.setOrgWideEmailAddressId(senderAddressList[ConstantValues.ZERO_VALUE].Id);                                           
        emailSubject = emailSubject.replace(REPLACE_GROWER_NAME, growerName);
        email.subject = emailSubject;
        emailBody = emailTemplateList[ConstantValues.ZERO_VALUE].HtmlValue;
        emailBody = emailBody.replace(REPLACE_GROWER_NAME, growerName);
        emailBody = emailBody.replace(REPLACE_LOAN_ID, loanNumber);
        emailBody = emailBody.replace(ConstantValues.REPLACE_LOAN_AMOUNT, String.valueOf(loanAmount));
        emailBody = emailBody.replace(REPLACE_MATURITY_DATE, String.valueOf(maturityDate));
        emailBody = emailBody.replace(REPLACE_IRC, irc);
        emailBody = emailBody.replace(REPLACE_SALES_AGENT, salesAgent);
        emailBody = emailBody.replace(CL_OR_FSA, clOrFsa);
        emailBody = emailBody.replace(CL_OR_FSA_NAME, clOrFsaName);
        emailBody = emailBody.replace(ConstantValues.REPLACE_LOGO_URL, EmailUtil.setLogoURL(dealerId));
        email.setHtmlBody(emailBody);
        email.setToAddresses(toAddresses);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    } 

    /**
    * @description Formats Amount
    * @author  Pritam Roy | 11-22-2023 
    * @param objAmount 
    * @return String 
    **/
    private String formatAmount(String objAmount) {
        Integer decimalPosition;
        objAmount = ConstantValues.DOLLAR_STRING + objAmount;
        if (!objAmount.contains(ConstantValues.PERIOD_STRING)) {
            objAmount += ConstantValues.FORMAT_TO_DECIMAL_STRING;
        } else {
          decimalPosition = objAmount.indexOf(ConstantValues.PERIOD_STRING);
          if (objAmount.length() - decimalPosition < 3){ 
              objAmount += ConstantValues.FORMAT_STRING;
            }   
        }
        return objAmount; 
    }

    /**
    * @description : this method is to get the application details 
    * @author Kabir Pramanik | 12-20-2024 
    **/
    private void getApplicationDetails(){
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                    Is_Evergreen_Eligible__c,
                                    genesis__Credit_Rating__r.Name,
                                    genesis__Account__c,
                                    Signing_Method__c,
                                    genesis__Loan_Number__c,
                                    genesis__Loan_Amount__c,
                                    genesis__Maturity_Date__c,
                                    Internal_Reference_Code__c,
                                    Sales_Agent__r.Name,
                                    Sales_Agent__r.clcommon__Email__c,
                                    CreatedBy.Account.Name,
                                    CreatedBy.Account.RecordType.Name,
                                    CreatedBy.Email,
                                    Certified_Lender__r.Name,
                                    Certified_Lender__r.clcommon__Email__c,
                                    Dealer_Name__r.Coop_Type__c,
                                    Dealer_Name__r.CIF_Number__c,
                                    Dealer_Name__r.Id,
                                    (SELECT Id, 
                                            Name,
                                            genesis__Application__c, 
                                            Description__c, 
                                            Loan_Number__c,
                                            Loan_id__c,
                                            genesis__Application__r.Loan_id__c,
                                            genesis__Application__r.genesis__Credit_Rating__r.Name,
                                            genesis__Application__r.Signing_Method__c,
                                            genesis__Application__r.Non_Accrual__c,
                                            genesis__Application__r.genesis__Account__c
                                    FROM genesis__Pricing_Details__r)
                            FROM genesis__Applications__c
                            WHERE Id = :applicationId
                            LIMIT 1];
        PortalApplicationOriginationHelper.checkEmptyList(applicationList,PortalConstants.SOMETHING_WENT_WRONG);
        applicationObj = applicationList[0];                         
    }
}