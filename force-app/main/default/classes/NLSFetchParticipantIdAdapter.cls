/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 25-11-2024
 * @last modified by  : Subham Nandi
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   19-10-2022   Subham Nandi   Initial Version
 * 1.1   17-11-2022   Rahul Gupta    Updated Version
**/
global with sharing class NLSFetchParticipantIdAdapter extends intframework.BaseIntegrationAdapter{
    public static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    public static final String PRICING_KEY = 'pricing';
    public static final String LOAN_TYPE_KEY = 'loanType';
    public static final String LOAN_ID_KEY = 'loanId';
    public static final String PARTICIPANT_TYPE_KEY = 'Participant_Type';
    public static final String PARTICIPANT_ID_KEY = 'Participantrefno';
    public static final String PARENT_LOAN_TYPE = 'Parent';
    public static final String PARENT_ID_KEY = 'ParentId';
    public static final String ID_KEY = 'Id';
    public static final String PARENT_LOAN_ID_KEY = 'ParentLoanId';


    
    List<Map<String, Object>> loanId;
    String loanType;
    String CLASS_NAME = 'NLSFetchParticipantIdAdapter';

    String requestBody='';

    public override String generateRequestBody(Map<String, Object> requestMap){
        loanId = (List<Map<String, Object>>)requestMap.get(PRICING_KEY);
        loanType = String.valueOf(requestMap.get(LOAN_TYPE_KEY));
        return requestBody; 
    }

    public override System.HttpResponse sendRequest(System.HttpRequest httpRequest){
        //Instantiating a new http request and new data types
        String endpointUrl;
        String newEndpointUrl;
        String accessToken;
        String loanStatus;
        Http http = new Http();
        HttpResponse objHttpResponse;
        Attachment objAttachment = new Attachment();
        List<genesis__Application_Pricing_Detail__c> pricingList = new List<genesis__Application_Pricing_Detail__c>();
        List<genesis__Applications__c> objApplicationList = new List<genesis__Applications__c>();
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
            
            httpRequest.setHeader(  ConstantValues.AUTHORIZATION, 
                                    objAccessTokenNLSWrapper.token_type + ' ' + 
                                    objAccessTokenNLSWrapper.access_token);
            endpointUrl = httpRequest.getEndpoint();
            for(Map<String, Object> loan: loanId){
                if(loanType == PARENT_LOAN_TYPE){
                    newEndpointUrl = endpointUrl.replace(ConstantValues.LOAN_ID,  String.valueOf(loan.get(PARENT_LOAN_ID_KEY)));
                }
                else{
                    newEndpointUrl = endpointUrl.replace(ConstantValues.LOAN_ID,  String.valueOf(loan.get(LOAN_ID_KEY)));
                }
                httpRequest.setEndpoint(newEndpointUrl);
                objHttpResponse = http.send(httpRequest);
                if(objHttpResponse.getStatusCode() == 200){
                    Map<String, Object> mainResponseMap = (Map<String, Object>) JSON.deserializeUntyped(objHttpResponse.getBody());
                    Map<String, Object> subResponseMap = (Map<String, Object>) mainResponseMap.get(ConstantValues.PAYLOAD);
                    List<Object> fieldResponseList = (List<Object>) subResponseMap.get(ConstantValues.DATA);
                    for(Object objFieldResponse : fieldResponseList){
                        if(((Map<String,Object>) objFieldResponse) !=null &&
                        (Integer)((Map<String,Object>) objFieldResponse).get(PARTICIPANT_TYPE_KEY) == 1){
                            if(loanType == PARENT_LOAN_TYPE){
                                //When the Parent Application Participant Id is fetched
                                genesis__Applications__c objApplication = new genesis__Applications__c(Id = String.valueOf(loan.get(PARENT_ID_KEY)));
                                objApplication.Participant_Id__c = String.valueOf(((Map<String,Object>) objFieldResponse).get(PARTICIPANT_ID_KEY));
                                objApplicationList.add(objApplication);
                            }
                            else{
                                //When the Child Application Participant Id is fetched
                                genesis__Application_Pricing_Detail__c objPricingList = new genesis__Application_Pricing_Detail__c();
                                objPricingList.Id = String.valueOf(loan.get(ID_KEY));
                                objPricingList.Participant_Id__c = String.valueOf(((Map<String,Object>) objFieldResponse).get(PARTICIPANT_ID_KEY));
                                pricingList.add(objPricingList);
                            }
                        }    
                    }  
                }
            } 

            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);

            Set<genesis__Applications__c> objApplicationSet = new Set<genesis__Applications__c>();
            List<genesis__Applications__c> objApplicationListWODuplicate = new List<genesis__Applications__c>();
            if(loanType == PARENT_LOAN_TYPE){
                objApplicationSet.addAll(objApplicationList);
                objApplicationListWODuplicate.addAll(objApplicationSet);
                Database.update(objApplicationListWODuplicate,true);
            }
            else{
                Database.Update(pricingList, true);
            }
            return objHttpResponse;
        }
        catch (Exception objException) {
            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            return null;
        }
    }
}