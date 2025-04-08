/**
 * @description       : This class generate xml and post it to NLS
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 11-01-2023
 * @last modified by  : Simran
**/
global with sharing class NLSModifyFieldAdapter extends intframework.BaseIntegrationAdapter {

    private static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    private static final String CLASS_NAME = 'NLSModifyFieldAdapter';
    private static final String FAILED_TO_FETCH = 'Failed to fetch data.';
    private static final String KEY_GET_FIELD = 'getAppField';
    private static final String REQUEST_BODY = ' - Request Body';
    private static final String RESPONSE_BODY = ' - Response Body';

    String requestBody;
    List<Map<String,Object>> requestList = new List<Map<String,Object>>();

    public override String generateRequestBody(Map<String, Object> requestMap){
       
        try{
            if(requestMap.get(KEY_GET_FIELD)!=null){    
                requestList = (List<Map<String, Object>>)requestMap.get(KEY_GET_FIELD);
                requestBody = RequestBodyGeneratorHelper.generateXMLBodyForLoanAmountUpdate(requestList);
                return requestBody;
            }
            else{
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);    
            return null;
        }     
    }

    public override System.HttpResponse sendRequest(System.HttpRequest request){
        HttpResponse response = new HttpResponse();
        String accessToken;
        Http http = new Http();
        AccessTokenNLSWrapper objNLSAccessTokenWrapper = new AccessTokenNLSWrapper();
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
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
            objNLSAccessTokenWrapper = AccessTokenNLSWrapper.parse(accessToken);
            request.setHeader(ConstantValues.AUTHORIZATION, 
                            objNLSAccessTokenWrapper.token_type + ' ' + 
                            objNLSAccessTokenWrapper.access_token);

            response = http.send(request);
            AccessTokenGenerator.revokeAccessToken(objNLSAccessTokenWrapper.access_token);
            LoanServicingHelper.storeGenericRequestBody(CLASS_NAME,  REQUEST_BODY , request.getBody());
            LoanServicingHelper.storeGenericResponseBody(CLASS_NAME, RESPONSE_BODY,response.getBody());
            // Database.insert(new clcommon__Log__c(Name = REQUEST_BODY ,
            //                 clcommon__Message__c =  REQUEST_BODY 
            //                 + request.getBody(),
            //                 clcommon__Time__c = System.Now()), false);
        
            // Database.insert(new clcommon__Log__c(Name = RESPONSE_BODY ,
            //                 clcommon__Message__c = RESPONSE_BODY
            //                 + response.getBody(),
            //                 clcommon__Time__c = System.Now()), false);
            //                 logger.info(RESPONSE_BODY + response.getBody());
            
            if(response.getStatusCode() != 200){
                throw new CustomException(ConstantValues.CALLOUT_EXCEPTION);
            }
            return response;
        }
        catch(Exception objException){
            AccessTokenGenerator.revokeAccessToken(objNLSAccessTokenWrapper.access_token);
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            return null;
        }
        
    }

   



}