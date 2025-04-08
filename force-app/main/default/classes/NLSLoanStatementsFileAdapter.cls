/**********************************************************************************************************************
 * @description       : This is a NLSLoanStatementFileAdapter class which sends a request to NLS and 
 *                      gets a Base64 encoded PDF File for a given Loan Statement Id.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 25-11-2024
 * @last modified by  : Subham Nandi
**********************************************************************************************************************/

global with sharing class NLSLoanStatementsFileAdapter extends intframework.BaseIntegrationAdapter{
    
    //parameters specific for this class [start]
    String accountId;
    String statementId;
    String requestBody = '';
    public static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    public static final String CLASS_NAME = 'NLSLoanStatementsFileAdapter';
    public static final String ATTACHMENT_LOAN_STATEMENTS = 'Response from NLS Loan-Statements-File';
    // parameters specific for this class [end]
    
    /**
    * @description - This method helps in storing the dynamic data parameters which is recived from the requestMap.
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param requestMap 
    * @return String 
    **/
    public override String generateRequestBody(Map<String, Object> requestMap){
    	accountId = (String)requestMap.get(ConstantValues.ACCOUNT_ID);
		statementId = (String)requestMap.get(ConstantValues.STATEMENT_ID);
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
        HttpResponse objHttpResponse;
        Attachment objAttachment = new Attachment();
        AccessTokenNLSWrapper objAccessTokenNLSWrapper = new AccessTokenNLSWrapper();
        try{
            //if(statementId == null) {
              //  throw new CustomException(ConstantValues.PARAMETER_MISSING);
            //}    
            for(Integer count=0; count<MAX_ACCESS_TOKEN_GENERATION_LIMIT; count++){
                accessTokenString = AccessTokenGenerator.getAccessToken();
                if(accessTokenString != null){
                	break;
            	}
            }
            if(accessTokenString == null){
                throw new CustomException(ConstantValues.ACCESS_TOKEN_NULL);
            }
            objAccessTokenNLSWrapper = AccessTokenNLSWrapper.parse(accessTokenString);
            objHttpRequest.setHeader(  ConstantValues.AUTHORIZATION, 
                                    objAccessTokenNLSWrapper.token_type + 
                                    ' ' + 
                                    objAccessTokenNLSWrapper.access_token );
        	endpointUrl = objHttpRequest.getEndpoint();
            //endpointUrl = endpointUrl.replace(ConstantValues.REPLACE_STATEMENT_ID, statementId);
        	objHttpRequest.setEndpoint(endpointUrl);  
            objHttpResponse = http.send(objHttpRequest);
            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);
            if(Attachment.SObjectType.getDescribe().isCreateable() && objHttpResponse.getBody()!= null){
                Blob blobObj = Blob.valueOf(objHttpResponse.getBody());
                objAttachment.Body = blobObj;
                objAttachment.ParentId = accountId;
                objAttachment.Name = ATTACHMENT_LOAN_STATEMENTS;
                Database.Insert(objAttachment, false);
            }
            return objHttpResponse;
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);   
            return null;
        }
    }
}