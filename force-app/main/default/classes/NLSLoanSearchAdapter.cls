/**
 * @description       : This is a NLS Loan Search Adapter Class which sends a request to the third party 
 *                      and get all the application details in return as response.
 * @author            : Arka Jyoti Deb
 * @CreatedDate       : 13-12-2021
 * @last modified on  : 03-11-2024
 * @last modified by  : Tuhin Bhunia
**/

global with sharing class NLSLoanSearchAdapter extends intframework.BaseIntegrationAdapter{
    
    String accountId;
    String loanStatus;
    public static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    public static final String ACCOUNT = 'Account';
    public static final String ID = 'ID';
    public static final String CIF = 'CIF';
    public static final String NLS_LOAN_SEARCH_ADAPTER = 'NLSLoanSearchAdapter';
    public static final String ATTACHMENT_LOAN_SEARCH = 'Response from NLS - /loan/seach';
    public static final String STATUS_ACTIVE = '0';
    public static final String STATUS_CLOSED = '1';
    public static final String KEY_NULL = 'null';
    public static final String LOAN_ID = 'loanId';

    
    /**
     * @description : This method is responsible for generating the request body through RequestBodyGeneratorHelper class.
     * @param requestMapping 
     * @return  `String`
     * @exception 
     */
    public override String generateRequestBody(Map<String, Object> requestMapping){
        String cifNumber ;
        String requestBody;
        String accountPartyType;
        String loanType;
        String loanNumber;
        String loanId;
        String masterAcctrefno;
        String payoffDate = '""';
        List<Map<String, Object>> accounts;
        RequestBodyGeneratorHelper requestBodyGenerator = new RequestBodyGeneratorHelper();
        if(requestMapping.get(ACCOUNT) != null){
            accounts = (List<Map<String, Object>>)requestMapping.get(ACCOUNT);
        }
        try{
            loanNumber = (String)requestMapping.get(ConstantValues.LOAN_NUMBER);
            loanId = (String)requestMapping.get(LOAN_ID);
            if(loanNumber != null){
                requestBody = requestBodyGenerator.generateRequestForLoanId(loanNumber);
            }
            else if(loanId != null){
                requestBody = requestBodyGenerator.generateRequestForChildLoanId(loanId);
            }
            else{
                if(accounts.size() == 0 ){
                    throw new CustomException(ConstantValues.LIST_ACCOUNT_IS_EMPTY);
                }
                if(accounts[0].get(ID) == Null ){
                    throw new CustomException(ConstantValues.ACCOUNT_ID_MISSING);
                }
                if(accounts[0].get(CIF) == Null ){
                    throw new CustomException(ConstantValues.CIF_IS_EMPTY);                                      
                }
                accountId = (String) accounts[0].get(ID);
                cifNumber = (String) accounts[0].get(CIF);
                loanType = (String)requestMapping.get(ConstantValues.LOAN_TYPE);
                accountPartyType = (String)requestMapping.get(ConstantValues.PARTY_TYPE);
                loanStatus = (String)requestMapping.get(ConstantValues.STATUS_CODE);
                masterAcctrefno = (String)requestMapping.get(ConstantValues.MASTER_ACCTREFNO);
                if(loanStatus == STATUS_ACTIVE){
                    payoffDate = KEY_NULL;
                }
                
                requestBody = requestBodyGenerator.generateRequestbody(accountPartyType, cifNumber, loanStatus, loanType, masterAcctrefno, payoffDate);
            }
            return requestBody;   
        }catch (Exception objException) {
            Database.insert(new clcommon__Log__c(Name = NLS_LOAN_SEARCH_ADAPTER,
                    clcommon__Message__c = NLS_LOAN_SEARCH_ADAPTER 
                    + objException.getStackTraceString()
                    + objException.getMessage(),
                    clcommon__Time__c = System.Now()), false);    
            return null;
        }
    }
    
    //This method is responsible for performing the third party call-out 
    public override System.HttpResponse sendRequest(System.HttpRequest httpRequest){
        
        //Instantiating a new http request and new data types
        String endpointUrl;
        String accessToken;
        string closeLoanBody;
        String requestBody;
        String responseBody;
        Http http = new Http();
        HttpResponse httpResponse;
        Attachment attachmentObj = new Attachment();
        AccessTokenNLSWrapper objAccessTokenNLSWrapper = new AccessTokenNLSWrapper();
        try{
            for(Integer count=0;count<MAX_ACCESS_TOKEN_GENERATION_LIMIT;count++){
                accessToken = AccessTokenGenerator.getAccessToken();
                if(accessToken != null){
                	break;
            	}
            }
            if(accessToken == null){
                throw new CustomException(ConstantValues.ACCESS_TOKEN_NULL);
            }
            objAccessTokenNLSWrapper = AccessTokenNLSWrapper.parse(accessToken);
            httprequest.setHeader(ConstantValues.AUTHORIZATION, objAccessTokenNLSWrapper.token_type 
                                    + ' ' + objAccessTokenNLSWrapper.access_token );
            endpointUrl = httpRequest.getEndpoint();
            httpRequest.setEndpoint(endpointUrl + ConstantValues.CALLOUT_LIMIT);
            System.debug(httpRequest.getBody());
            httpResponse = http.send(httpRequest);
            System.debug(httpResponse);
            if(loanStatus == STATUS_CLOSED){
                closeLoanBody = httpResponse.getBody();
                requestBody = httpRequest.getBody();
                requestBody = requestBody.replace(ConstantValues.REPLACE_STATUS_CODE, ConstantValues.ACTIVE_STATUS_CODE);
                requestBody = requestBody.replace(ConstantValues.REPLACE_PAYOFF_DATE, ConstantValues.ACTIVE_PAYOFF_DATE);
                httpRequest.setBody(requestBody);
                httpResponse = http.send(httpRequest);
                responseBody = ConstantValues.CLOSED_LOAN_RESPONSE_BODY;
                responseBody = responseBody.replace(ConstantValues.REPLACE_CLOSE_LOAN,closeLoanBody);
                responseBody = responseBody.replace(ConstantValues.REPLACE_ACTIVE_LOAN,httpResponse.getBody());
                httpResponse.setBody(responseBody);
            }
            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);
            if(Attachment.SObjectType.getDescribe().isCreateable() && httpResponse.getBody()!= null){
                Blob blobObj = Blob.valueOf(httpResponse.getBody());
                attachmentObj.Body = blobObj;
                attachmentObj.ParentId = accountId;
                attachmentObj.Name = ATTACHMENT_LOAN_SEARCH;
                Database.insert(attachmentObj, false);
            }
            return httpResponse;
        }
        catch (Exception objException) {
            Database.insert(new clcommon__Log__c(Name = NLS_LOAN_SEARCH_ADAPTER ,
                    clcommon__Message__c = NLS_LOAN_SEARCH_ADAPTER  
                    + objException.getStackTraceString()
                    + objException.getMessage(),
                    clcommon__Time__c = System.Now()), false);   
            return null;
        }
    }
}