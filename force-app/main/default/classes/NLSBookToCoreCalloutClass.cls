/**
 * @description       : Callout Class For Book to Core
 * @author            : Pritam Roy
 * @group             : 
 * @last modified on  : 02-13-2025
 * @last modified by  : Ayush Kumar Singh
**/


global without sharing class NLSBookToCoreCalloutClass implements Queueable , Database.AllowsCallouts{
    
    private static final String CLASS_NAME = NLSBookToCoreCalloutClass.class.getName();
    private static final String API_TYPE = 'Post Book To Core NLS Integration API Type';
    private static final String SUCCESS_TEXT = 'Success';
    private static final String KEY_APPLICATION_ID = 'applicationId';
    private static final String KEY_DEALER_ACCOUNT = 'dealerAccount';
    private static final String KEY_LOAN_A = 'loanA';
    private static final String KEY_LOAN_B = 'loanB';
    private static final String KEY_LOAN_C = 'loanC';
    private static final String KEY_LOAN_D = 'loanD';
    private static final String KEY_LOAN_E = 'loanE';
    private static final String KEY_LOAN_F = 'loanF';
    private static final String KEY_LOAN_G = 'loanG';
    private static final String KEY_LOAN_H = 'loanH';
    private static final String KEY_MY_PROGRAM_ID = 'myProgId';
    private static final String KEY_COOP_TYPE = 'coopType';
    private static final String HYPHEN_A = '-A';
    private static final String HYPHEN_B = '-B';
    private static final String HYPHEN_C = '-C';
    private static final String HYPHEN_D = '-D';
    private static final String HYPHEN_E = '-E';
    private static final String HYPHEN_F = '-F';
    private static final String HYPHEN_G = '-G';
    private static final String HYPHEN_H = '-H';

    string applicationId;

    /**
     * @description       : Constructor to initialize
     * @author            : Pritam Roy
     * @param applicationId
     **/
    global NLSBookToCoreCalloutClass(string applicationId){
        this.applicationId = applicationId;
    }
    /**
    * @description : Calling the Book to Core the Adapter
    * @author  Pritam Roy | 03-07-2024 
    * @param context 
    **/
    public void execute(QueueableContext context) {
        // Map<String, Object> requestParamMap = new Map<String, Object>();
        String coopType = PortalConstants.EMPTY_STRING;
        Map<String, Object> queryIdMap = new Map<String, Object>();
        try{
            genesis__Applications__c applicationObj = [SELECT Id,
                                                              Name,
                                                              Dealer_Name__c,
                                                              Dealer_Name__r.CFA_Partner_Program__r.Name,
                                                              Pricing_Count__c,
                                                              Credit_Application_And_Agreement_Process__c,
                                                              Dealer_Name__r.genesis__Business_Information__c,
                                                              Dealer_Name__r.genesis__Business_Information__r.Remaining_Customised_Limit__c,
                                                              Dealer_Name__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c,
                                                              genesis__Loan_Amount__c,
                                                              genesis__Loan_Number__c,
                                                              genesis__Status__c,
                                                              My_Program__c,
                                                              Coop_Type__c,
                                                              genesis__Account__c,
                                                              genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                              genesis__Contact__c,
                                                              genesis__Contact__r.Email
                                                       FROM genesis__Applications__c
                                                       WHERE Id = :applicationId];

            if(applicationObj.Coop_Type__c == ConstantValues.GROWMARK_COOP_TYPE 
                    & applicationObj.Dealer_Name__r.CFA_Partner_Program__c == null){
                coopType = ConstantValues.GROWMARK_COOP_TYPE;
            }else{
                coopType = applicationObj.Dealer_Name__r.CFA_Partner_Program__r.Name;
            }

            // Commenting the below validation based on the Support Ticket https://cfafs.atlassian.net/browse/CFAS-5506 -------------------------------------------
            // genesis__Business_Information__c objBusinessInfo = [SELECT Id,
            //                                                            Approved_Loan_Amount__c,
            //                                                            Customised_Individual_Limit__c,
            //                                                            Remaining_Customised_Limit__c,
            //                                                            Remaining_Contract_Limit__c
            //                                                     FROM genesis__Business_Information__c
            //                                                     WHERE Id = :applicationObj.Dealer_Name__r.genesis__Business_Information__c];
            // if(objBusinessInfo == null){
            //     throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            // }
            // if(objBusinessInfo.Remaining_Contract_Limit__c < 0){
            //     throw new CustomException(ConstantValues.INSUFFICIENT_DEALER_FUND);
            // }
            // if(objBusinessInfo.Remaining_Customised_Limit__c < 0 && applicationObj.Credit_Application_And_Agreement_Process__c == 'Customize'){
            //     throw new CustomException(ConstantValues.INSUFFICIENT_DEALER_FUND);
            // }
            // Commenting the above validation based on the Support Ticket https://cfafs.atlassian.net/browse/CFAS-5506 -------------------------------------------
            queryIdMap.put(KEY_APPLICATION_ID, applicationId);
            queryIdMap.put(KEY_DEALER_ACCOUNT, applicationObj.Dealer_Name__c);
            queryIdMap.put(KEY_LOAN_A, applicationObj.genesis__Loan_Number__c + HYPHEN_A);
            queryIdMap.put(KEY_LOAN_B, applicationObj.genesis__Loan_Number__c + HYPHEN_B);
            queryIdMap.put(KEY_LOAN_C, applicationObj.genesis__Loan_Number__c + HYPHEN_C);
            queryIdMap.put(KEY_LOAN_D, applicationObj.genesis__Loan_Number__c + HYPHEN_D);
            queryIdMap.put(KEY_LOAN_E, applicationObj.genesis__Loan_Number__c + HYPHEN_E);
            queryIdMap.put(KEY_LOAN_F, applicationObj.genesis__Loan_Number__c + HYPHEN_F);
            queryIdMap.put(KEY_LOAN_G, applicationObj.genesis__Loan_Number__c + HYPHEN_G);
            queryIdMap.put(KEY_LOAN_H, applicationObj.genesis__Loan_Number__c + HYPHEN_H);
            queryIdMap.put(KEY_MY_PROGRAM_ID, applicationObj.My_Program__c);
            queryIdMap.put(KEY_COOP_TYPE, coopType);
            //Calling the integration framework

            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
            responseObject = 
                (intframework.BaseIntegrationResponse)
                    baseIntegrationService.runSynchronousIntegrationService( 
                                ConstantValues.NLS_INTEGRATION_FAMILY,
                                API_TYPE,
                                queryIdMap, 
                                new Map<String, Object> {
                                    KEY_COOP_TYPE => coopType
                                });
            if(responseObject.getBody() == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }

            LoanServicingHelper.sendEmailToLandusGrower(applicationObj);
            
            System.enqueueJob(new FetchLoanIdQueueable(applicationObj.genesis__Loan_Number__c, applicationObj.Id));
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            
        }
    }

    /**
    * @description This method is called By A CFA User to book the loan to Core after booking the CIF
    * @author Subham Nandi | 10-08-2022 
    * @param applicationId 
    * @return String 
    **/
    webservice static String bookToCoreLoanFromBackEnd(String applicationId) {
        // Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        String coopType = PortalConstants.EMPTY_STRING;
        try{
            validateBookingForNonAccrualParties(applicationId);
            genesis__Applications__c applicationObj = [SELECT Id,
                                                              Name, 
                                                              Dealer_Name__c,
                                                              Dealer_Name__r.CFA_Partner_Program__r.Name,
                                                              Pricing_Count__c, 
                                                              Credit_Application_And_Agreement_Process__c,
                                                              Dealer_Name__r.genesis__Business_Information__c,
                                                              Dealer_Name__r.genesis__Business_Information__r.Remaining_Customised_Limit__c,
                                                              Dealer_Name__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c,
                                                              genesis__Loan_Amount__c,
                                                              genesis__Loan_Number__c,
                                                              genesis__Status__c,
                                                              My_Program__c,
                                                              Coop_Type__c,
                                                              genesis__Account__c,
                                                              genesis__Account__r.clcommon__Legal_Entity_Type__c,
                                                              genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                              genesis__Contact__c,
                                                              genesis__Contact__r.Email
                                                       FROM genesis__Applications__c
                                                       WHERE Id = :applicationId];          

            genesis__Business_Information__c objBusinessInfo = [SELECT Id,
                                                                       Approved_Loan_Amount__c,
                                                                       Customised_Individual_Limit__c,
                                                                       Remaining_Customised_Limit__c,
                                                                       Remaining_Contract_Limit__c
                                                                FROM genesis__Business_Information__c
                                                                WHERE Id = :applicationObj.Dealer_Name__r.genesis__Business_Information__c];
            if(objBusinessInfo == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }

            if(applicationObj.Coop_Type__c == ConstantValues.GROWMARK_COOP_TYPE 
                    & applicationObj.Dealer_Name__r.CFA_Partner_Program__c == null){
                coopType = ConstantValues.GROWMARK_COOP_TYPE;
            }else{
                coopType = applicationObj.Dealer_Name__r.CFA_Partner_Program__r.Name;
            }

            queryIdMap.put(KEY_APPLICATION_ID, applicationId);
            queryIdMap.put(KEY_DEALER_ACCOUNT, applicationObj.Dealer_Name__c);
            queryIdMap.put(KEY_LOAN_A, applicationObj.genesis__Loan_Number__c + HYPHEN_A);
            queryIdMap.put(KEY_LOAN_B, applicationObj.genesis__Loan_Number__c + HYPHEN_B);
            queryIdMap.put(KEY_LOAN_C, applicationObj.genesis__Loan_Number__c + HYPHEN_C);
            queryIdMap.put(KEY_LOAN_D, applicationObj.genesis__Loan_Number__c + HYPHEN_D);
            queryIdMap.put(KEY_LOAN_E, applicationObj.genesis__Loan_Number__c + HYPHEN_E);
            queryIdMap.put(KEY_LOAN_F, applicationObj.genesis__Loan_Number__c + HYPHEN_F);
            queryIdMap.put(KEY_LOAN_G, applicationObj.genesis__Loan_Number__c + HYPHEN_G);
            queryIdMap.put(KEY_LOAN_H, applicationObj.genesis__Loan_Number__c + HYPHEN_H);
            queryIdMap.put(KEY_MY_PROGRAM_ID, applicationObj.My_Program__c);
            queryIdMap.put(KEY_COOP_TYPE, coopType);
            //Calling the integration framework

            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
            responseObject = 
                (intframework.BaseIntegrationResponse)
                    baseIntegrationService.runSynchronousIntegrationService( 
                            ConstantValues.NLS_INTEGRATION_FAMILY,
                            API_TYPE,
                            queryIdMap, 
                            new Map<String, Object> {
                                KEY_COOP_TYPE => coopType
                            }
                        );
            if(responseObject.getBody() == null){
                throw new CustomException(responseObject.processingErrorMessage);
            }

            LoanServicingHelper.sendEmailToLandusGrower(applicationObj);
            System.enqueueJob(new FetchLoanIdQueueable(applicationObj.genesis__Loan_Number__c, applicationObj.Id));

        }
        catch (CustomException objCustomException){
            return objCustomException.getMessage();
        } 
        catch (Exception exceptionObj) {
            return exceptionObj.getMessage();
        } 
        return SUCCESS_TEXT;
    }
    /**
    * @description : This method is used to prevent the loan from booking 
    *                if Borrower or any principal party is associated with any other non accrual loan.
    * @author Ayush Kumar Singh | 01-31-2024 
    * @param applicationId 
    **/
    private static void validateBookingForNonAccrualParties(String applicationId){
        //List<Id> borrowerPrincipalIdList = new List<Id>();
        List<clcommon__Party__c> partyList = [SELECT Id, 
                                                    Name, 
                                                    Dealer_Applicant_Relationship__c,
                                                    clcommon__Account__c,
                                                    clcommon__Contact__r.genesis__SSN__c 
                                        FROM clcommon__Party__c 
                                        WHERE genesis__Application__c = :applicationId 
                                        AND clcommon__Party_Types__c IN (:ConstantValues.BORROWER_PARTY, :ConstantValues.PRINCIPAL_PARTY) 
                                        AND (Dealer_Applicant_Relationship__r.Is_Non_Accrual__c = true OR Dealer_Applicant_Relationship__r.Has_Past_Due__c = true)];

        if(!partyList.isEmpty()){ 
            throw new CustomException(ConstantValues.ASSOCIATED_WITH_NON_ACCRUAL);
        }
    }
}