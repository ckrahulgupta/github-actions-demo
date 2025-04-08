/**
 * @description       : 
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 01-11-2025
 * @last modified by  : Ayush Kumar Singh
**/
global with sharing class NLSCifBookToCoreImportAdapter extends intframework.BaseIntegrationAdapter{
    
    String requestBody;
    public static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    public static final String CLASS_NAME = NLSCifBookToCoreImportAdapter.class.getName();
    public static final String KEY_APPLICATION = 'Application';
    public static final String KEY_APPLICANT = 'BorrowerDetails';
    public static final String KEY_PARTY_TYPES = 'PartyTypes';
    public static final String KEY_REQUEST = 'Request Body - Book To Core CIF';
    public static final String KEY_RESPONSE = 'Response Body - Book To Core CIF';
    List<Map<String, Object>> applicationDetailsList = new List<Map<String, Object>>();
    List<Map<String, Object>> primaryApplicantMapList = new List<Map<String, Object>>();
    List<Map<String,Object>> borrowerDetailsMapList = new List<Map<String, Object>>();
    List<Map<String,Object>> coApplicantDetailMapList = new List<Map<String, Object>>();
    
    //This method is responsible for generating the request body through RequestBodyGeneratorHelper class.
    public override String generateRequestBody(Map<String, Object> requestMapping){

        RequestBodyGeneratorHelper requestBodyGenerator = new RequestBodyGeneratorHelper();
        try{
            applicationDetailsList = (List<Map<String, Object>>)requestMapping.get(KEY_APPLICATION);
            primaryApplicantMapList = (List<Map<String, Object>>)requestMapping.get(KEY_APPLICANT);
            for(Map<String,Object> applicantMap : primaryApplicantMapList){
                if(applicantMap.get(KEY_PARTY_TYPES) == ConstantValues.BORROWER_PARTY){
                    borrowerDetailsMapList.add(applicantMap);
                }else{
                    coApplicantDetailMapList.add(applicantMap);
                }
            }
            requestBody = requestBodyGenerator.bookToCoreCIFXMLRequestbody(applicationDetailsList, coApplicantDetailMapList, borrowerDetailsMapList);
            return requestBody;   
        }catch (Exception exceptionObj) {
            PortalHelper.saveExceptionLog(exceptionObj, CLASS_NAME);
            return null;
        }
    }
    
    //This method is responsible for performing the third party call-out 
    public override System.HttpResponse sendRequest(System.HttpRequest httpRequest){
        
        String accessToken;
        Http http = new Http();
        HttpResponse httpResponse;
        AccessTokenNLSWrapper accessTokenNLSWrapperObj = new AccessTokenNLSWrapper();
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
            accessTokenNLSWrapperObj = AccessTokenNLSWrapper.parse(accessToken);
            httprequest.setHeader(ConstantValues.AUTHORIZATION, accessTokenNLSWrapperObj.token_type 
                                    + ' ' + accessTokenNLSWrapperObj.access_token );
            httpResponse = http.send(httpRequest);
            AccessTokenGenerator.revokeAccessToken(accessTokenNLSWrapperObj.access_token);

            LoggingUtility.saveRequestLogging(KEY_REQUEST, KEY_REQUEST + httpRequest.getBody());

            LoggingUtility.saveResponseLogging(KEY_RESPONSE, KEY_RESPONSE + httpResponse.getBody());

            if(httpResponse.getStatusCode() != 200) {
                throw new CustomException(ConstantValues.CALLOUT_EXCEPTION);
            }
            return httpResponse;
        }
        catch (Exception exceptionObj) {
            PortalHelper.saveExceptionLog(exceptionObj, CLASS_NAME);
            return null;
        }
    }
}