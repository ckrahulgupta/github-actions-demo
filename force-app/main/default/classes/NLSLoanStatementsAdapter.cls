/**********************************************************************************************************************
 * @description       : This is a NLSLoanStatementsAdapter class which sends a request to the third party and get all  
 *				        the Loan Statements details in return as response.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 25-11-2024
 * @last modified by  : Subham Nandi
*********************************************************************************************************************/

global with sharing class NLSLoanStatementsAdapter extends intframework.BaseIntegrationAdapter{
    
    // parameters specific for this class [start]
    String accountId;
    String loanId;
    String requestBody = '';
    String statementType = '';
    public static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    public static final String CLASS_NAME = 'NLSLoanStatementsAdapter';
    public static final String ATTACHMENT_LOAN_STATEMENTS = 'Response from NLS loan-Statements';
    public static final String CURRENT_YEAR = 'Statement for Current Year';
    public static final String LAST_YEAR = 'Statement for Last Year';
    // parameters specific for this class [end]

    /**
    * @description - This method helps in storing the dynamic data parameters which is recived from the requestMapping.
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param requestMap 
    * @return String 
    **/
    public override String generateRequestBody(Map<String, Object> requestMap){
    	accountId = (String)requestMap.get(ConstantValues.ACCOUNT_ID);
		loanId = (String)requestMap.get(ConstantValues.LOAN_ID);
        statementType = (String)requestMap.get(ConstantValues.STATEMENT_TYPE);
        return requestBody;
    }

     
    /**
    * @description - This method is responsible for performing the call-out to NLS.
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param httpRequest 
    * @return System.HttpResponse 
    **/
    public override System.HttpResponse sendRequest(System.HttpRequest httpRequest){
        
        // Variable declaration 
        String endpointUrl;
        String accessTokenString;
        String dateParams;
        Http http = new Http();
        HttpResponse httpResponse;
        Attachment objAttachment = new Attachment();
        AccessTokenNLSWrapper objAccessTokenNLSWrapper = new AccessTokenNLSWrapper();
        try{
            //if(loanId == null) {
              //  throw new CustomException(ConstantValues.PARAMETER_MISSING);
            //}  
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
            httpRequest.setHeader(  ConstantValues.AUTHORIZATION, 
                                    objAccessTokenNLSWrapper.token_type 
                                    + ' ' + 
                                    objAccessTokenNLSWrapper.access_token );
        	endpointUrl = httpRequest.getEndpoint();
            //endpointUrl = endpointUrl.replace(ConstantValues.REPLACE_LOAN_ID, loanId);
            if(statementType == CURRENT_YEAR){
                dateParams = ConstantValues.STATEMENT_PARAMS_FOR_THIS_YEAR;
                dateParams = dateParams.replace(ConstantValues.REPLACE_YEAR, String.valueOf(date.today().year()));
                dateParams = dateParams.replace(ConstantValues.REPLACE_MONTH, String.valueOf(date.today().month()));
                dateParams = dateParams.replace(ConstantValues.REPLACE_DAY, String.valueOf(date.today().day()));
                httpRequest.setEndpoint(endpointUrl+dateParams); 
            }
            else if(statementType == LAST_YEAR){
                dateParams = ConstantValues.STATEMENT_PARAMS_FOR_LAST_YEAR;
                dateParams = dateParams.replace(ConstantValues.REPLACE_YEAR, String.valueOf(date.today().year()-1));
                httpRequest.setEndpoint(endpointUrl+dateParams); 
            }
            else{
                httpRequest.setEndpoint(endpointUrl); 
            } 
            httpResponse = http.send(httpRequest);
            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);
            if(Attachment.SObjectType.getDescribe().isCreateable() && httpResponse.getBody()!= null){
                Blob objBlob = Blob.valueOf(httpResponse.getBody());
                objAttachment.Body = objBlob;
                objAttachment.ParentId = accountId;
                objAttachment.Name = ATTACHMENT_LOAN_STATEMENTS;
                Database.Insert(objAttachment, false);
            }
            return httpResponse;
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);   
            return null;
        }
    }
}