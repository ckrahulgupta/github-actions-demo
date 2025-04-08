/**
 * @description       : This Adapter class is used by 'NLS Get Loan Integration Configuration' to send a request to the NLS and get the Loan details.
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 26-11-2024
 * @last modified by  : Subham Nandi
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   02-06-2022   Subham Nandi   Initial Version
**/
global with sharing class NLSParticipantsGetLoanAdapter extends intframework.BaseIntegrationAdapter{

    // parameters specific for this class [start]
    public static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    public static final String KEY_APPLICATION = 'Application';
    public static final String CLASS_NAME = 'NLSParticipantsGetLoanApadter';
    public static final String FIELD_STATUS_CODE_NO = 'Status_Code_No';
    public static final String FIELD_CURRENT_INTEREST_BALANCE = 'Current_Interest_Balance';
    public static final String FIELD_CURRENT_PER_DIEM = 'Current_Perdiem';
    public static final String FIELD_ID = 'ID';

    /*******************************Declaration of global variables*******************************************/
    String requestBody='';
    List<Map<String, Object>> loanId;
    Decimal currentInterestBalance;
    Decimal currentPerdiem;
    List<Map<String, Object>> activeApplicationList = new List<Map<String, Object>>();
    Map<String, Object> response = new Map<String, Object>();
    List<genesis__Applications__c> objApplicationList  = new List<genesis__Applications__c>();
    
    /**
    * @description This method is used to generate the request body for NLS callout.
    * @author Subham Nandi 
    * @param requestMap 
    * @return String 
    **/
    public override String generateRequestBody(Map<String, Object> requestMap){
        loanId = (List<Map<String, Object>>)requestMap.get('pricing');
        return requestBody; 
    }


    /**
    * @description This method is used to send the request to NLS and perform the callout operation.
    * @author Subham Nandi 
    * @param httpRequest 
    * @return System.HttpResponse 
    **/
    public override System.HttpResponse sendRequest(System.HttpRequest httpRequest){
        //Instantiating a new http request and new data types
        String endpointUrl;
        String newEndpointUrl;
        String accessToken;
        Http http = new Http();
        HttpResponse objHttpResponse;
        List<genesis__Application_Pricing_Detail__c> pricingList = new List<genesis__Application_Pricing_Detail__c>();
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
                newEndpointUrl = endpointUrl.replace(ConstantValues.LOAN_ID,  String.valueOf(loan.get('loanId')));
                httpRequest.setEndpoint(newEndpointUrl);
                objHttpResponse = http.send(httpRequest);
                if(objHttpResponse.getStatusCode() == 200){
                    Map<String, Object> mainResponseMap = (Map<String, Object>) JSON.deserializeUntyped(objHttpResponse.getBody());
                    Map<String, Object> subResponseMap = (Map<String, Object>) mainResponseMap.get(ConstantValues.PAYLOAD);
                    List<Object> fieldResponseList = (List<Object>) subResponseMap.get(ConstantValues.DATA);
                    for(Object objFieldResponse : fieldResponseList){
                        if(((Map<String,Object>) objFieldResponse) !=null &&
                        (Integer)((Map<String,Object>) objFieldResponse).get('Participant_Type') == 1){
                            currentInterestBalance = (Decimal) ((Map<String,Object>) objFieldResponse).get(FIELD_CURRENT_INTEREST_BALANCE);
                            currentPerdiem = (Decimal) ((Map<String,Object>) objFieldResponse).get(FIELD_CURRENT_PER_DIEM);
                            genesis__Application_Pricing_Detail__c objPricingList = new genesis__Application_Pricing_Detail__c();
                            objPricingList.Id = String.valueOf(loan.get('Id'));
                            objPricingList.Dealer_Interest_Accrued__c = currentInterestBalance;
                            objPricingList.Dealer_Interest_Per_Diem__c = currentPerdiem;
                            pricingList.add(objPricingList);
                        }    
                    }  
                }
            } 

            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);

            Database.Update(pricingList, true);
            
            return objHttpResponse;
        }
        catch (Exception objException) {
            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            return null;
        }
    }   
}