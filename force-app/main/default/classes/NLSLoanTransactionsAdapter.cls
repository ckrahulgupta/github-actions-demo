/**
 * @description       : This is a NLSLoanTransactionsAdapter Class which sends a request to the third party and get all the 
*				        Loan Transactions details in return as response.
 * @author            : Arka Jyoti Deb
 * @createdDate       : 19/12/2021
 * @last modified on  : 03-26-2024
 * @last modified by  : Tuhin Bhunia
**/

global with sharing class NLSLoanTransactionsAdapter extends intframework.BaseIntegrationAdapter{
    
    //parameters specific for this class [start]
    String accountId;
    String loanId;
    String requestBody = '';
    public static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    public static final String TRANSACTIONS = '/transactions';
    public static final String CLASS_NAME = 'NLSLoanTransactionsAdapter';
    public static final String ATTACHMENT_LOAN_TRANSACTIONS = 'Response from NLS loan/Transactions';
    //parameters specific for this class [end]

    /**
    * @description - This method helps in storing the dynamic data parameters which is recived from the requestMap.
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param requestMap 
    * @return String 
    **/
    public override String generateRequestBody(Map<String, Object> requestMap){
    	accountId = (String)requestMap.get(ConstantValues.ACCOUNT_ID);
		loanId = (String)requestMap.get(ConstantValues.LOAN_ID);
        return requestBody;
    }


    /**
    * @description - This method is responsible for performing the call-out to NLS.
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param objHttpRequest 
    * @return System.HttpResponse 
    **/
    public override System.HttpResponse sendRequest(System.HttpRequest objHttpRequest){
        
        // Variable declaration 
        String endpointUrl;
        String accessTokenString;
        Http http = new Http();
        HttpResponse httpResponse;
        Attachment objAttachment = new Attachment();
        AccessTokenNLSWrapper objAccessTokenNLSWrapper = new AccessTokenNLSWrapper();
        try{ 
            if(accountId == null || loanId == null ) {
                throw new CustomException(ConstantValues.PARAMETER_MISSING);
            }    
            for(Integer count=0;count<MAX_ACCESS_TOKEN_GENERATION_LIMIT;count++){
                accessTokenString = AccessTokenGenerator.getAccessToken();
                if(accessTokenString != null){
                	break;
            	}
            }
            if(accessTokenString == null){
                throw new CustomException(ConstantValues.ACCESS_TOKEN_NULL);
            }
            objAccessTokenNLSWrapper = AccessTokenNLSWrapper.parse(accessTokenString);
            objHttpRequest.setHeader(   ConstantValues.AUTHORIZATION, 
                                        objAccessTokenNLSWrapper.token_type 
                                        + ' ' + 
                                        objAccessTokenNLSWrapper.access_token );
            if(objHttpRequest.getEndpoint() != null){
                endpointUrl = objHttpRequest.getEndpoint();
            }                            
        	objHttpRequest.setEndpoint(endpointUrl + loanId + TRANSACTIONS + ConstantValues.CALLOUT_LIMIT);  
            httpResponse = http.send(objHttpRequest);
            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);
            if(Attachment.SObjectType.getDescribe().isCreateable() && httpResponse.getBody()!= null){
                Blob objBlob = Blob.valueOf(httpResponse.getBody());
                objAttachment.Body = objBlob;
                objAttachment.ParentId = accountId;
                objAttachment.Name = ATTACHMENT_LOAN_TRANSACTIONS;
                Database.insert(objAttachment, false);
            }
            return httpResponse;
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);   
            return null;
        }
    }
}