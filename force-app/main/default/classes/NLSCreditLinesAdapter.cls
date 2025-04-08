/**********************************************************************************************************************
 * @description       : 
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 27-11-2024
 * @last modified by  : Subham Nandi
**********************************************************************************************************************/

global with sharing class NLSCreditLinesAdapter extends intframework.BaseIntegrationAdapter{
    
    String requestBody;
    public static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    public static final String NLS_CREDIT_LINES_ADAPTER = 'NLSCreditLinesAdapter';
    public static final String KEY_TOTAL_PRODUCT_RETURN_AMOUNT = 'totalProductReturnAmount';
    List<Map<String, Object>> activeApplicationList = new List<Map<String, Object>>();
    List<genesis__Applications__c> objApplicationList  = new List<genesis__Applications__c>();
    //This method is responsible for generating the request body through RequestBodyGeneratorHelper class.
    public override String generateRequestBody(Map<String, Object> requestMapping){

        activeApplicationList = (List<Map<String, Object>>)requestMapping.get('Application');
        return requestBody; 
    }
    
    //This method is responsible for performing the third party call-out 
    public override System.HttpResponse sendRequest(System.HttpRequest httpRequest){
        
        //Instantiating a new http request and new data types
        String endpointUrl;
        String newEndpointUrl;
        String accessToken;
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
            for(Map<String, Object> objApplicationMap: activeApplicationList){
                if(String.valueOf(objApplicationMap.get(ConstantValues.LOAN_ID)) != null){
                    newEndpointUrl = endpointUrl.replace(ConstantValues.LOAN_ID, String.valueOf(objApplicationMap.get(ConstantValues.LOAN_ID)));
                    httpRequest.setEndpoint(newEndpointUrl);
                    httpResponse = http.send(httpRequest);
                    Map<String, Object> mainResponse = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                    Map<String, Object> subResponse = (Map<String, Object>) mainResponse.get(ConstantValues.PAYLOAD);
                    if(subResponse != null && Integer.valueOf(subResponse.get('count')) > 0 ){
                        List<Object> responseList = (List<Object>) subResponse.get(ConstantValues.DATA);
                        if(responseList.size() > 0){
                            Map<String, Object> fieldResponse = (Map<String, Object>) responseList[0];
                            genesis__Applications__c objApplication = new genesis__Applications__c();
                            objApplication.Id = String.valueOf(objApplicationMap.get('ID'));
                            objApplication.genesis__Loan_Amount__c = (Decimal)fieldResponse.get('Credit_Line_Limit');
                            objApplication.Reserved_Amount__c = (Decimal)fieldResponse.get('Credit_Line_Limit') - (Decimal)fieldResponse.get('Credit_Total_Draw_Limit') + (Decimal)objApplicationMap.get(KEY_TOTAL_PRODUCT_RETURN_AMOUNT);
                            if(objApplication.Reserved_Amount__c < 0){
                                objApplication.Reserved_Amount__c = 0;
                            }
                            objApplicationList.add(objApplication);
                        }
                    }
                }
            }
            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);
            Database.update(objApplicationList,true);
            return httpResponse;
        }
        catch (Exception objException) {
            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);
            PortalHelper.saveExceptionLog(objException, NLS_CREDIT_LINES_ADAPTER);
            return null;
        }
    }
}