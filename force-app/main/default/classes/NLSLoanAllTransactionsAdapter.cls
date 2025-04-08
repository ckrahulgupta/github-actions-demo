/**
 * @description       : This is a NLSLoanAllTransactionsAdapter Class which sends a request to the third party and get all the 
*				        Loan Transactions details in return as response.
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 04-03-2024
 * @last modified by  : Sk Minsar
**/


global with sharing class NLSLoanAllTransactionsAdapter extends intframework.BaseIntegrationAdapter{
    String accountId;
    String loanId;
    List<String> loanIdList = new List<String>();
    String requestBody = '';
    private static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    private static final String TRANSACTIONS = '/transactions';
    private static final String CLASS_NAME = 'NLSLoanAllTransactionsAdapter';
    private static final String ATTACHMENT_LOAN_TRANSACTIONS = 'Response from NLS loan/Transactions';
    private static final String PAYLOAD = 'payload';
    private static final String DATA = 'data';

   
    public override String generateRequestBody(Map<String, Object> requestMap){
    	accountId = (String)requestMap.get(ConstantValues.ACCOUNT_ID);
		loanIdList = (List<String>)requestMap.get(PortalConstants.LOAN_ID_LIST);
        return requestBody;
    }


    public override System.HttpResponse sendRequest(System.HttpRequest objHttpRequest){
        String endpointUrl;
        String accessTokenString;
        Http http = new Http();
        HttpResponse httpResponse;
        HttpResponse actualResponse = new HttpResponse();
        Attachment objAttachment = new Attachment();
        AccessTokenNLSWrapper objAccessTokenNLSWrapper = new AccessTokenNLSWrapper();
        List<Object> responseMap = new List<Object>();
        Map<String,Object> actualResponsemap = new Map<String,Object>();
        try{
            LoanServicingHelper.checkEmptyString(accountId, ConstantValues.PARAMETER_MISSING);
            PortalApplicationOriginationHelper.checkEmptyList(loanIdList, ConstantValues.PARAMETER_MISSING);
            for(Integer count=0;count<MAX_ACCESS_TOKEN_GENERATION_LIMIT;count++){
                accessTokenString = AccessTokenGenerator.getAccessToken();
                if(accessTokenString != null){
                	break;
            	}
            }
            LoanServicingHelper.checkEmptyString(accessTokenString, ConstantValues.ACCESS_TOKEN_NULL);
            objAccessTokenNLSWrapper = AccessTokenNLSWrapper.parse(accessTokenString);
            objHttpRequest.setHeader(   ConstantValues.AUTHORIZATION, 
                                        objAccessTokenNLSWrapper.token_type 
                                        + PortalConstants.SPACE_STRING + 
                                        objAccessTokenNLSWrapper.access_token );
            if(objHttpRequest.getEndpoint() != null){
                endpointUrl = objHttpRequest.getEndpoint();
            }
            for(String loanId: loanIdList){
                objHttpRequest.setEndpoint(endpointUrl + loanId + TRANSACTIONS + ConstantValues.CALLOUT_LIMIT);  
                httpResponse = http.send(objHttpRequest);
                if(httpResponse.getStatusCode() == PortalConstants.TWO_HUNDRED_VALUE){
                    Map<String, Object> mainResponse = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                    Map<String, Object> subResponse = (Map<String, Object>) mainResponse.get(PAYLOAD);
                    List<Object> extractResponseMap = (List<Object>)subResponse.get(DATA);
                    responseMap.addAll(extractResponseMap);
                }
            }                            
            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);
            actualResponsemap.put(PortalConstants.KEY_POSTED_TRANSACTIONS, responseMap);
            actualResponse.setBody(String.valueOf(JSON.serialize(actualResponsemap)));
            return actualResponse;
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);   
            return null;
        }
    }
}