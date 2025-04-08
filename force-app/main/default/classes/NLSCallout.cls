/**
 * @description       : This is a NLS Callout Class which sends the account Id to the Integration framework and get all the 
*				          active-loan, loan-details in return as response from different methods .
 * @author            :  Arka
 * @group             : 
 * @last modified on  : 03-21-2024
 * @last modified by  :  Pritam Roy
**/

global without Sharing class NLSCallout {//Inherited Sharing
    
    public static final String PAYLOAD = 'payload';
    public static final String DATA = 'data';
    public static final String CLOSED_LOANS = 'closedLoans';
    public static final String ACTIVE_LOANS = 'activeLoans';
    
    
    /**
    * @description : This method will call NLS loan search API Configuration Integration framework.
    * @author  Pritam Roy | 03-07-2024 
    * @param accountId 
    * @param partyType 
    * @param statusCode 
    * @param loanType 
    * @param masterAcctrefno 
    * @return List<Object> 
    **/
    public static List<Object> nlsSearchLoanCalloutMethod(String accountId, String partyType , String statusCode, String loanType, String masterAcctrefno) {
		
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        List<Object> fieldResponse = new List<Object>();
        try {
            queryIdMap.put(ConstantValues.ACCOUNT_ID,accountId);
            requestParamMap.put(ConstantValues.PARTY_TYPE, partyType);
            requestParamMap.put(ConstantValues.STATUS_CODE, statusCode);
            requestParamMap.put(ConstantValues.LOAN_TYPE, loanType);
            requestParamMap.put(ConstantValues.MASTER_ACCTREFNO, masterAcctrefno);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService( ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                ConstantValues.INTEGRATION_API_TYPE_SEARCH_LOAN,
                                                                                                                                queryIdMap, requestParamMap);
            if(responseObject.getBody() == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            if(statusCode == '1'){
                Map<String, Object> mainResponse = (Map<String, Object>) JSON.deserializeUntyped(responseObject.getBody());
                Map<String, Object> closedLoanResponse = (Map<String, Object>) mainResponse.get(CLOSED_LOANS);
                Map<String, Object> activeLoanResponse = (Map<String, Object>) mainResponse.get(ACTIVE_LOANS);
                Map<String, Object> closedLoanPayload = (Map<String, Object>) closedLoanResponse.get(PAYLOAD);
                Map<String, Object> activeLoanPayload = (Map<String, Object>) activeLoanResponse.get(PAYLOAD);
                fieldResponse.addAll((List<Object>) closedLoanPayload.get(DATA));
                fieldResponse.addAll((List<Object>) activeLoanPayload.get(DATA));
            }
            else{
                Map<String, Object> mainResponse = (Map<String, Object>) JSON.deserializeUntyped(responseObject.getBody());
                Map<String, Object> subResponse = (Map<String, Object>) mainResponse.get(PAYLOAD);
                fieldResponse = (List<Object>) subResponse.get(DATA);
            }
            return fieldResponse;
        } catch (Exception objException) {
            Database.insert(new clcommon__Log__c(Name = ConstantValues.NLS_CALLOUT ,
                    clcommon__Message__c = ConstantValues.NLS_CALLOUT  
                    + objException.getStackTraceString()
                    + objException.getMessage(),
                    clcommon__Time__c = System.Now()), false);
            return null;
        }
    }

    ////This method will call NLS loan search API Configuration Integration framework.---------------------------
    // public static String nlsGetLoanId(String loanNumber, String applicationId) {
		
    //     Map<String, Object> requestParamMap = new Map<String, Object>();
    //     Map<String, Object> queryIdMap = new Map<String, Object>();
    //     try {
    //         /* queryIdMap.put(ConstantValues.ACCOUNT_ID,'');
    //         requestParamMap.put(ConstantValues.PARTY_TYPE, '');
    //         requestParamMap.put(ConstantValues.STATUS_CODE, '');
    //         requestParamMap.put(ConstantValues.LOAN_TYPE, '');
    //         requestParamMap.put(ConstantValues.MASTER_ACCTREFNO, '');
    //          */
    //         requestParamMap.put(ConstantValues.LOAN_NUMBER, loanNumber);
    //         //Calling the integration framework
    //         intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
    //         intframework.BaseIntegrationResponse responseObject;
	// 		responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService( ConstantValues.NLS_INTEGRATION_FAMILY,
    //                                                                                                                             ConstantValues.INTEGRATION_API_TYPE_SEARCH_LOAN,
    //                                                                                                                             queryIdMap, requestParamMap);
    //         if(responseObject.getBody() == null){
    //             throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
    //         }
    //         genesis__Applications__c objApplication = [SELECT id,
    //                                                         Loan_Id__c
    //                                                     FROM genesis__Applications__c
    //                                                     WHERE id=: applicationId];
    //         Map<String, Object> mainResponse = (Map<String, Object>) JSON.deserializeUntyped(responseObject.getBody());
    //         Map<String, Object> subResponse = (Map<String, Object>) mainResponse.get(PAYLOAD);
    //         Map<String, Object> fieldResponse = (Map<String, Object>) subResponse.get(DATA);
    //         return String.valueOf(fieldResponse.get('Acctrefno'));
            
    //     } catch (Exception objException) {
    //         Database.insert(new clcommon__Log__c(Name = ConstantValues.NLS_CALLOUT ,
    //                 clcommon__Message__c = ConstantValues.NLS_CALLOUT  
    //                 + objException.getStackTraceString()
    //                 + objException.getMessage(),
    //                 clcommon__Time__c = System.Now()), false);
    //         return null;
    //     }
    // }
    
   
    /**
    * @description : This method will call NLS Get Loan API Configuration Integration framework.
    * @author  Pritam Roy | 03-07-2024 
    * @param accountId 
    * @param loanId 
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> nlsGetLoanCalloutMethod(String accountId, String loanId) {
		
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        try {
            requestParamMap.put(ConstantValues.ACCOUNT_ID, accountId);
            requestParamMap.put(ConstantValues.LOAN_ID, loanId);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                ConstantValues.INTEGRATION_API_TYPE_GET_LOAN,
                                                                                                                                queryIdMap, requestParamMap);
            if(responseObject.getBody() == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            Map<String, Object> mainResponse = (Map<String, Object>) JSON.deserializeUntyped(responseObject.getBody());
            Map<String, Object> subResponse = (Map<String, Object>) mainResponse.get(PAYLOAD);
            Map<String, Object> fieldResponse = (Map<String, Object>) subResponse.get(DATA);
            return fieldResponse;
        } catch (Exception objException) {
            Database.insert(new clcommon__Log__c(Name = ConstantValues.NLS_CALLOUT ,
                    clcommon__Message__c = ConstantValues.NLS_CALLOUT  
                    + objException.getStackTraceString()
                    + objException.getMessage(),
                    clcommon__Time__c = System.Now()), false);
            return null;
        }
    }

    
    /**
    * @description : This method will call NLS Loan Transactions API Configuration Integration framework.
    * @author  Pritam Roy | 03-07-2024 
    * @param accountId 
    * @param loanId 
    * @return List<Object> 
    **/
    public static List<Object> nlsGetLoanTransactionsCalloutMethod(String accountId, String loanId) {
		
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        try {
            requestParamMap.put(ConstantValues.ACCOUNT_ID, accountId);
            requestParamMap.put(ConstantValues.LOAN_ID, loanId);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                ConstantValues.INTEGRATION_API_TYPE_LOAN_TRANSACTION,
                                                                                                                                queryIdMap, requestParamMap);
            if(responseObject.getBody() == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            Map<String, Object> mainResponse = (Map<String, Object>) JSON.deserializeUntyped(responseObject.getBody());
            Map<String, Object> subResponse = (Map<String, Object>) mainResponse.get(PAYLOAD);
            List<Object> fieldResponse = (List<Object>) subResponse.get(DATA);
            return fieldResponse;
        } catch (Exception objException) {
            Database.insert(new clcommon__Log__c(Name = ConstantValues.NLS_CALLOUT ,
                    clcommon__Message__c = ConstantValues.NLS_CALLOUT  
                    + objException.getStackTraceString()
                    + objException.getMessage(),
                    clcommon__Time__c = System.Now()), false);
            return null;
        }
    }
    
    /**
    * @description : This method will call NLS Loan Statement API Configuration Integration framework.
    * @author  Pritam Roy | 03-07-2024 
    * @param accountId 
    * @param loanId 
    * @param statementType 
    * @return List<Object> 
    **/
    public static List<Object> nlsGetLoanStatementsCalloutMethod(String accountId, String loanId, String statementType) {
		
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        try {
            requestParamMap.put(ConstantValues.ACCOUNT_ID, accountId);
            requestParamMap.put(ConstantValues.LOAN_ID, loanId);
            requestParamMap.put(ConstantValues.STATEMENT_TYPE, statementType);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                ConstantValues.INTEGRATION_API_TYPE_LOAN_STATEMENTS,
                                                                                                                                queryIdMap, requestParamMap);
            if(responseObject.getBody() == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            Map<String, Object> mainResponse = (Map<String, Object>) JSON.deserializeUntyped(responseObject.getBody());
            Map<String, Object> subResponse = (Map<String, Object>) mainResponse.get(PAYLOAD);
            List<Object> fieldResponse = (List<Object>) subResponse.get(DATA);
            return fieldResponse;
        } catch (Exception objException) {
            Database.insert(new clcommon__Log__c(Name = ConstantValues.NLS_CALLOUT ,
                    clcommon__Message__c = ConstantValues.NLS_CALLOUT  
                    + objException.getStackTraceString()
                    + objException.getMessage(),
                    clcommon__Time__c = System.Now()), false);
            return null;
        }
    }
    
    /**
    * @description : This method will call NLS Loan Statement File API Configuration Integration framework.
    * @author  Pritam Roy | 03-07-2024 
    * @param accountId 
    * @param statementId 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> nlsGetLoanStatementsFileCalloutMethod(String accountId, String statementId) {
		
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        try {
            requestParamMap.put(ConstantValues.ACCOUNT_ID, accountId);
            requestParamMap.put(ConstantValues.STATEMENT_ID, statementId);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                ConstantValues.INTEGRATION_API_TYPE_LOAN_STATEMENTS_FILE,
                                                                                                                                queryIdMap, requestParamMap);
            if(responseObject.getBody() == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            Map<String, Object> mainResponse = (Map<String, Object>) JSON.deserializeUntyped(responseObject.getBody());
            Map<String, Object> subResponse = (Map<String, Object>) mainResponse.get(PAYLOAD);
            Map<String, Object> fieldResponse = (Map<String, Object>) subResponse.get(DATA);
            return fieldResponse;
        } catch (Exception objException) {
            Database.insert(new clcommon__Log__c(Name = ConstantValues.NLS_CALLOUT ,
                    clcommon__Message__c = ConstantValues.NLS_CALLOUT  
                    + objException.getStackTraceString()
                    + objException.getMessage(),
                    clcommon__Time__c = System.Now()), false);
            return null;
        }
    }
   
    /**
    * @description : This method will call NLS XML IMPORT API Configuration Integration framework
    * @author  Pritam Roy | 03-07-2024 
    * @param type 
    **/
    @InvocableMethod(label = 'InitiateACHForPosting')
    public static void nlsXmlImportCalloutMethod(List<String> type) {
		
        try {
            if(type[0] == ConstantValues.ACH){
                NLSXMLImportForACHSchedule postACH = new NLSXMLImportForACHSchedule();
                postACH.execute(null);
            }
            else if(type[0] == ConstantValues.DRAFT){
                NLSXMLImportForDraftSchedule postDraft = new NLSXMLImportForDraftSchedule();
                postDraft.execute(null);
            }
            else if(type[0] == ConstantValues.PAYMENT){
                NLSXMLImportForPaymentSchedule postPayment = new NLSXMLImportForPaymentSchedule();
                postPayment.execute(null);
            }
            else if(type[0] == ConstantValues.MOBILE_DEPOSIT){
                NLSXMLImportForMobileDepositScheduleable postMobileDeposit = new NLSXMLImportForMobileDepositScheduleable();
                postMobileDeposit.execute(null);
            }
            else if(type[0] == ConstantValues.PRODUCT_RETURN){
                NLSXMLImportForProductReturnSchedule postProductReturn = new NLSXMLImportForProductReturnSchedule();
                postProductReturn.execute(null);
            }
            
        } catch (Exception objException) {
            Database.insert(new clcommon__Log__c(Name = ConstantValues.NLS_CALLOUT ,
                    clcommon__Message__c = ConstantValues.NLS_CALLOUT  
                    + objException.getStackTraceString()
                    + objException.getMessage(),
                    clcommon__Time__c = System.Now()), false);
        }
    }
}