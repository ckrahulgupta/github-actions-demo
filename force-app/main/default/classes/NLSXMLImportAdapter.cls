/**********************************************************************************************************************
 * @description       : The purpose of this class is to create post all the ACH, DRAFT and Payoff details to NLS
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 01-02-2025
 * @last modified by  : Kabir Pramanik
**********************************************************************************************************************/

global with sharing class NLSXMLImportAdapter extends intframework.BaseIntegrationAdapter{
    
    // parameters specific for this class [start]
    private static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    private static final String CLASS_NAME = 'NLSXMLImportAdapter';
    private static final String ATTACHMENT = 'Response from NLS - /xml/import';
    private static final String KEY_FUNDING_TRANSACTION = 'FundingTransaction';
    private static final String REQUEST_BODY = ' - Request Body';
    private static final String RESPONSE_BODY = ' - Response Body';
    private static final String KEY_ID = 'Id';
    private static final String AMOUNT = 'Amount';
    private static final String APPLICATION_ID = 'ApplicationId';
    private static final String RECORDED_STATUS = 'RECORDED';
    // parameters specific for this class [end]
    
    //Declaration of global variables
    String type;
    String requestBody;
    String applicationId;
    List<Map<String, Object>> responseList = new List<Map<String, Object>>();
    
    /**
     * @description 
     * @param type 
     * @exception 
     */
    private static void checkPaymentType(String type){
        if((!type.equalsIgnoreCase(ConstantValues.ACH) && 
                !type.equalsIgnoreCase(ConstantValues.PRODUCT_RETURN) && 
                !type.equalsIgnoreCase(ConstantValues.MOBILE_DEPOSIT) && 
                !type.equalsIgnoreCase(ConstantValues.DRAFT) && 
                !type.equalsIgnoreCase(ConstantValues.PAYMENT)) || 
                type==null){
                    throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
        }
    }
    /**
     * @description 
     * @exception 
     */
    private static void checkAccessOnObjects(){
        if((!Schema.sObjectType.genesis__Applications__c.isAccessible())
                || (!Schema.sObjectType.genesis__Funding_Transaction__c.isAccessible())
                || (!Schema.sObjectType.clcommon__Funding_Transactions_Properties__c.isAccessible())
                || (!Schema.sObjectType.clcommon__Funding_Transactions_Properties__c.isUpdateable())
                || (!Schema.sObjectType.genesis__Funding_Transaction__c.isAccessible())
                || (!Schema.sObjectType.genesis__Funding_Transaction__c.isUpdateable())
                || (!Schema.sObjectType.clcommon__Log__c.isCreateable())){
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
        }
    }

   /**
    * @description 
    * @param applicationId 
    * @param responseList 
    */
    private static void updateProductReturnAmount(String applicationId,List<Map<String, Object>> responseList){
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList = [SELECT Id, Product_Return_Amount__c 
                                        FROM genesis__Applications__c 
                                        WHERE Id =: applicationId];
        for(Map<String, Object> fundingTransactionMap  : responseList){
            applicationList[0].Product_Return_Amount__c += Decimal.valueOf(String.valueOf(fundingTransactionMap.get(AMOUNT)));
        }
        if(Schema.sObjectType.genesis__Applications__c.isUpdateable()){
            Database.update(applicationList,ConstantValues.TRUE_VALUE);
        }
    }


    
    /**
    * @description - Get Funding Transaction
    * @author Sk Minsar | 12-19-2024 
    * @param responseList 
    * @param type 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getFundingTransaction(List<Map<String, Object>> responseList, String type){
        List<genesis__Funding_Transaction__c> fundingTransactionList = new List<genesis__Funding_Transaction__c>();
        Set<Id> invoiceIdSet = new Set<Id>();
        for(Map<String, Object> responseMap: responseList){
            if(responseMap.get(KEY_ID) != null){
                genesis__Funding_Transaction__c objFundingTransaction = new genesis__Funding_Transaction__c(Id=String.ValueOf(responseMap.get(KEY_ID)));
                if(type != ConstantValues.DRAFT){
                    objFundingTransaction.Posted_to_NLS__c = ConstantValues.TRUE_VALUE;
                    objFundingTransaction.Posted_Date__c = System.now();
                    objFundingTransaction.Status__c = ConstantValues.STATUS_POSTED;
                    invoiceIdSet = PaymentInvoiceHelper.addInvoiceIdSet(String.valueOf(responseMap.get(ConstantValues.INVOICE_ID_KEY)), invoiceIdSet);
                }
                fundingTransactionList.add(objFundingTransaction);
            } 
        }
        return new Map<String, Object>{ConstantValues.KEY_FUNDING_TRANSACTION_LIST => fundingTransactionList,
            ConstantValues.KEY_INVOICE_ID_SET => invoiceIdSet
        };
    }

   
    /**
    * @description 
    * @param fundingTransactionList 
    * @param invoiceStatusIdSet 
    * @return List<String> 
    **/
    private static List<String> updateFundingTransaction(List<genesis__Funding_Transaction__c> fundingTransactionList, Set<Id> invoiceStatusIdSet){
        List<String> fundingTransacBatchList = new List<String>();
        List<genesis__Funding_Transaction__c> fundingTransacBatchObj = new List<genesis__Funding_Transaction__c>();
        if(fundingTransactionList.size() > ConstantValues.ZERO_VALUE){
            fundingTransacBatchObj = [SELECT Id, 
                                            Batch__c,
                                            Invoice__c 
                                            FROM genesis__Funding_Transaction__c
                                            WHERE Id In :fundingTransactionList 
                                            AND genesis__Payment_Mode__r.Name != : ConstantValues.DRAFT 
                                            AND Batch__c != null];
            for(genesis__Funding_Transaction__c objFundingId:fundingTransacBatchObj){
                fundingTransacBatchList.add(objFundingId.Batch__c);
            }
            Database.Update(fundingTransactionList,ConstantValues.TRUE_VALUE);
            PaymentInvoiceHelper.updateInvoiceStatus(new List<Id>(invoiceStatusIdSet), ConstantValues.STATUS_POSTED);
        }
        return fundingTransacBatchList;
    }
    
    /**
    * @description - This method is responsible for generating the request body through RequestBodyGeneratorHelper class.
    * @author Arka Jyoti Deb | 04-28-2022 
    * @param requestMap 
    * @return String 
    **/
    public override String generateRequestBody(Map<String, Object> requestMap){
        RequestBodyGeneratorHelper requestBodyGenerator = new RequestBodyGeneratorHelper();
        if(requestMap.get(KEY_FUNDING_TRANSACTION)!=null){    
            responseList = (List<Map<String, Object>>)requestMap.get(KEY_FUNDING_TRANSACTION);
        }
        try{
            if(requestMap.get(ConstantValues.PAYMENT_TYPE) != null){
                type = String.valueOf(requestMap.get(ConstantValues.PAYMENT_TYPE));
            }
            if(responseList[0].get(APPLICATION_ID)!= null){
                applicationId = String.valueOf(responseList[0].get(APPLICATION_ID));
            }
            checkPaymentType(type);
           
            requestBody = requestBodyGenerator.generateXMLRequestbody(type, responseList);
            return requestBody;   
        }catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, NLSXMLImportAdapter.class.getName());
            return null;
        }
    }
    
    
    /**
    * @description - This method is responsible for performing the third party call-out 
    * @author Arka Jyoti Deb | 04-28-2022 
    * @param objHttpRequest 
    * @return System.HttpResponse 
    **/
    public override System.HttpResponse sendRequest(System.HttpRequest objHttpRequest){
        
        //Instantiating a new http request and new data types
        String accessTokenString;
        Http http = new Http();
        HttpResponse objHttpResponse;
        AccessTokenNLSWrapper objAccessTokenNLSWrapper = new AccessTokenNLSWrapper();
        List<genesis__Funding_Transaction__c> fundingTransactionList = new List<genesis__Funding_Transaction__c>();
        List<String> fundingTransacBatchList = new List<String>();
        Map<String, Object> transactionMap = new Map<String, Object>();
        Set<Id> invoiceIdSet = new Set<Id>();
        try{
            checkAccessOnObjects();
            accessTokenString = LoanServicingHelper.getNLSAccessToken();
            
            objAccessTokenNLSWrapper = AccessTokenNLSWrapper.parse(accessTokenString);
            objHttpRequest.setHeader(   ConstantValues.AUTHORIZATION, 
                                        objAccessTokenNLSWrapper.token_type + 
                                        ConstantValues.SPACE_STRING + 
                                        objAccessTokenNLSWrapper.access_token );
            objHttpResponse = http.send(objHttpRequest);
            //Revoke Access token
            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);

            if(objHttpResponse.getStatusCode() == ConstantValues.TWO_HUNDRED_VALUE && type.equalsIgnoreCase(ConstantValues.PRODUCT_RETURN)){
                updateProductReturnAmount(applicationId,responseList);
             }
            
            Database.insert(new clcommon__Log__c(Name = type + REQUEST_BODY ,
                                        clcommon__Message__c = type + REQUEST_BODY 
                                        + objHttpRequest.getBody(),
                                        clcommon__Time__c = System.Now()), ConstantValues.FALSE_VALUE); 
        
            Database.insert(new clcommon__Log__c(Name = type + RESPONSE_BODY ,
                        clcommon__Message__c = type + RESPONSE_BODY
                        + objHttpResponse.getBody(),
                        clcommon__Time__c = System.Now()), ConstantValues.FALSE_VALUE);
            
            SavePoint dbSavePoint = Database.setSavepoint();
            transactionMap = getFundingTransaction(responseList, type);
            fundingTransactionList = (List<genesis__Funding_Transaction__c>)transactionMap.get(ConstantValues.KEY_FUNDING_TRANSACTION_LIST);
            invoiceIdSet = (Set<Id>)transactionMap.get(ConstantValues.KEY_INVOICE_ID_SET);

            fundingTransacBatchList = updateFundingTransaction(fundingTransactionList, invoiceIdSet);
            
            //Query the Batch and update the status
            List<clcommon__Funding_Transactions_Properties__c> objBatchesToUpdate = new List<clcommon__Funding_Transactions_Properties__c>();
            List<clcommon__Funding_Transactions_Properties__c> objBatchList = new List<clcommon__Funding_Transactions_Properties__c>();
                 objBatchList = [SELECT Id,
                                        Recorded_Date__c,
                                        Status__c
                                FROM clcommon__Funding_Transactions_Properties__c
                                WHERE Id IN :fundingTransacBatchList];
            

            for(clcommon__Funding_Transactions_Properties__c eachBatch : objBatchList){
                eachBatch.Status__c = RECORDED_STATUS;
                objBatchesToUpdate.add(eachBatch);
            } 
            Database.update(objBatchesToUpdate,ConstantValues.TRUE_VALUE);                                                          

            if(objHttpResponse.getStatusCode() != ConstantValues.TWO_HUNDRED_VALUE) {
                Database.rollback(dbSavePoint);
                throw new CustomException(ConstantValues.CALLOUT_EXCEPTION);
            }
            return objHttpResponse;
        }
        catch (Exception objException) {
            //Revoke Access Token
            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);
            PortalHelper.saveExceptionLog(objException, NLSXMLImportAdapter.class.getName());
            return null;
        }
    }
}