/**
 * @description       : 
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 27-11-2024
 * @last modified by  : Subham Nandi
**/

global with sharing class NLSChildPayoffDetailsAdapter extends intframework.BaseIntegrationAdapter{
    
    String requestBody;
    public static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    public static final String NLS_PAYOFF_DETAILS_ADAPTER = 'NLSChildPayoffDetailsAdapter';
    List<Map<String, Object>> activeApplicationList = new List<Map<String, Object>>();
    Map<String, Object> response = new Map<String, Object>();
    List<genesis__Application_Pricing_Detail__c> objChildApplicationList  = new List<genesis__Application_Pricing_Detail__c>();
    
    public override String generateRequestBody(Map<String, Object> requestMapping){

        activeApplicationList = (List<Map<String, Object>>)requestMapping.get('Pricing Details');
        return requestBody; 
    }
    
    //This method is responsible for performing the third party call-out 
    public override System.HttpResponse sendRequest(System.HttpRequest httpRequest){
        
        //Instantiating a new http request and new data types
        String endpointUrl;
        String newEndpointUrl;
        String accessToken;
        Date currentDate = PortalHelper.getNextWorkingDay(System.now().addDays(1));
        String month = currentDate.month()<10 ? '0'+ String.valueOf(currentDate.month()): String.valueOf(currentDate.month());
        string Day = currentDate.day()<10 ? '0'+ String.valueOf(currentDate.day()): String.valueOf(currentDate.day());
        String payoffDate = String.valueOf(currentDate.year()) + month + day ;
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
            for(Map<String, Object> objChildApplicationMap: activeApplicationList){
                newEndpointUrl = endpointUrl.replace(ConstantValues.LOAN_ID, String.valueOf(objChildApplicationMap.get(ConstantValues.LOAN_ID)));
                newEndpointUrl = newEndpointUrl + payoffDate;
                httpRequest.setEndpoint(newEndpointUrl);
                httpResponse = http.send(httpRequest);
                
                if(httpResponse.getStatusCode() == 200){
                    Map<String, Object> mainResponse = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                    Map<String, Object> subResponse = (Map<String, Object>) mainResponse.get(ConstantValues.PAYLOAD);
                    Map<String, Object> fieldResponse = (Map<String, Object>) subResponse.get(ConstantValues.DATA);
                    genesis__Application_Pricing_Detail__c objChildApplication = new genesis__Application_Pricing_Detail__c();
                    objChildApplication.Id = String.valueOf(objChildApplicationMap.get('ID'));
                    objChildApplication.Payoff_Amount_via_Mobile__c = Decimal.valueOf(String.valueOf(fieldResponse.get('PayoffAmount')));
                    objChildApplication.Fees__c = Decimal.valueOf(String.valueOf(fieldResponse.get('FeesDue')));
                    objChildApplication.Accrued_Interest__c = Decimal.valueOf(String.valueOf(fieldResponse.get('AccruedInterest')));
                    objChildApplicationList.add(objChildApplication);
                }
                
            }
            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);
            Database.update(objChildApplicationList,true);
            return httpResponse;
        }
        catch (Exception objException) {
            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);
            Database.insert(new clcommon__Log__c(Name = NLS_PAYOFF_DETAILS_ADAPTER ,
                    clcommon__Message__c = NLS_PAYOFF_DETAILS_ADAPTER
                    + objException.getStackTraceString()
                    + objException.getMessage(),
                    clcommon__Time__c = System.Now()), false);
                    return null;
        }
    }
}