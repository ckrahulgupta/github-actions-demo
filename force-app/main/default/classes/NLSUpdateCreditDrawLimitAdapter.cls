/**
 * @description       : This class generate xml and post it to NLS
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 02-17-2024
 * @last modified by  : Ayush Kumar Singh
**/
global with sharing class NLSUpdateCreditDrawLimitAdapter extends intframework.BaseIntegrationAdapter{
    private static final String CLASS_NAME = 'NLSModifyFieldAdapter';
    private static final String KEY_GET_FIELD = 'getFundingTransactionField';
    private static final String TYPE = 'DRAW LIMIT';
    private static final String REQUEST_BODY = ' - Request Body';
    private static final String RESPONSE_BODY = ' - Response Body';
    private static final String XML_DOCTYPE = '<?xml version="1.0" encoding="UTF-8"?>'; 


    String requestBody;
    List<Map<String,Object>> requestList = new List<Map<String,Object>>();

    global override String generateRequestBody(Map<String, Object> requestMap) {
        try{
            if(requestMap.get(KEY_GET_FIELD)!=null){    
                requestList = (List<Map<String, Object>>)requestMap.get(KEY_GET_FIELD);
                requestBody = RequestBodyGeneratorHelper.generateXMLBodyForCreditDrawLimitUpdate(requestList);
                return requestBody;
            }
            else{
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
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
        try{
            accessToken = LoanServicingHelper.getNLSAccessToken();
            objNLSAccessTokenWrapper = AccessTokenNLSWrapper.parse(accessToken);
            request.setHeader(ConstantValues.AUTHORIZATION, 
                            objNLSAccessTokenWrapper.token_type + ' ' + 
                            objNLSAccessTokenWrapper.access_token);

            response = http.send(request);
            AccessTokenGenerator.revokeAccessToken(objNLSAccessTokenWrapper.access_token);
            LoanServicingHelper.storeGenericRequestBody(TYPE, REQUEST_BODY, request.getBody());
            LoanServicingHelper.storeGenericResponseBody(TYPE, RESPONSE_BODY, response.getBody());                        
            
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