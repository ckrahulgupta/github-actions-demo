/**********************************************************************************************************************
 * @description       : 
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 25-01-2023
 * @last modified by  : Subham Nandi
**********************************************************************************************************************/

global with sharing class NLSLoanDetailsAdapter extends intframework.BaseIntegrationAdapter{
    
    String requestBody;
    public static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    public static final String NLS_LOAN_DETAILS_ADAPTER = 'NLSLoanDetailsAdapter';
    List<Map<String, Object>> activeApplicationList = new List<Map<String, Object>>();
    Map<String, Object> response = new Map<String, Object>();
    List<genesis__Applications__c> objApplicationList  = new List<genesis__Applications__c>();
    
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
        String creditRating = '';
        String TIER_1 = 'TIER 1';
        String TIER_2 = 'TIER 2';
        String TIER_3 = 'TIER 3';
        String STREAMLINE = 'STREAMLINE';
        String STANDARD = 'STANDARD';
        String UNSECURED = 'UNSECURED';
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
                    if(subResponse != null){
                        
                        Map<String, Object> fieldResponse = (Map<String, Object>) subResponse.get(ConstantValues.DATA);
                        System.debug('Field Response --- '+fieldResponse);
                        if(String.valueOf(fieldResponse.get('Userdef03')) == TIER_1 || String.valueOf(fieldResponse.get('Userdef03')) == UNSECURED){
                            genesis__Credit_Rating_Matrix__c objCreditRating = [SELECT Id, Name FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 1'];
                            creditRating = objCreditRating.Id;
                        }
                        else if(String.valueOf(fieldResponse.get('Userdef03')) == TIER_3 || String.valueOf(fieldResponse.get('Userdef03')) == STANDARD){
                            genesis__Credit_Rating_Matrix__c objCreditRating = [SELECT Id, Name FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];
                            creditRating = objCreditRating.Id;
                        }
                        else if(String.valueOf(fieldResponse.get('Userdef03')) == TIER_2 || String.valueOf(fieldResponse.get('Userdef03')) == STREAMLINE){
                            genesis__Credit_Rating_Matrix__c objCreditRating = [SELECT Id, Name FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 2'];
                            creditRating = objCreditRating.Id;
                        }
                        else{
                            genesis__Credit_Rating_Matrix__c objCreditRating = [SELECT Id, Name FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 4'];
                            creditRating = objCreditRating.Id;
                        }
                        genesis__Applications__c objApplication = new genesis__Applications__c();
                        objApplication.Id = String.valueOf(objApplicationMap.get('ID'));
                        //objApplication.genesis__Credit_Rating__c = fieldResponse.get('Credit_Line_Limit');
                        objApplication.Guarantee__c = Decimal.valueOf(String.valueOf(fieldResponse.get('Userdef02')).replace('%', ''));
                        objApplication.Crop_Year__c = String.valueOf(fieldResponse.get('Userdef01'));
                        objApplication.genesis__Credit_Rating__c = creditRating;
                        objApplicationList.add(objApplication);
                    }
                }
            }
            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);
            Database.update(objApplicationList,true);
            return httpResponse;
        }
        catch (Exception objException) {
            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);
            PortalHelper.saveExceptionLog(objException, NLS_LOAN_DETAILS_ADAPTER);
            return null;
        }
    }
}