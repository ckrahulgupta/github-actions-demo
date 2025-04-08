/**********************************************************************************************
* @className         : ExternalAPIApplication
* @description       : This class is used to fetch data from application by passing their loan number.
* @author            : Simran
* @created Date      : 02-24-2022
* @last modified on  : 09-09-2024
* @last modified by  : Suraj Kumar
**********************************************************************************************/
 
@RestResource(urlMapping='/LoanDetails/*')
global without sharing class ExternalAPIApplication {
    private static final String CLASS_NAME = ExternalAPIApplication.class.getName();
                           
    
    /**
    * @description : This method is used to return application records by taking id as parameter
    * @param loanNumberList 
    **/
    @HttpPost
    global static void applicationRecord(List<String> loanNumberList) {

        RestResponse response = RestContext.response;
 
        Boolean isValidUser=false;
        List<Id> objApplicationIdList = new List<Id>();
        List<genesis__Applications__c> objApplicationList = new List<genesis__Applications__c>();
        try{
            response.addHeader(ExternalConstants.CONTENT_TYPE, ExternalConstants.APPLICATION_JSON);
            if (loanNumberList == null) {
                ExternalExceptionUtil.throwCustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            ExternalApplicationOriginationUtil.checkEmptyList(loanNumberList,PortalConstants.REQUIRED_PARAMETERS_MISSING);
            
            objApplicationList = ExternalAPIApplicationHandler.getApplication(loanNumberList);

            for(genesis__Applications__c applicationObj : objApplicationList){
                objApplicationIdList.add((Id)applicationObj.Id);
            }
            isValidUser = ExternalAPIApplicationHandler.validateExternalUser(objApplicationIdList);
            if(!isValidUser){
                ExternalExceptionUtil.throwCustomException(PortalConstants.USER_NOT_AUTHORISED);
            }

            Map<Id, List<genesis__Application_Pricing_Detail__c>> updatedPricingDetailMap = ExternalAPIApplicationHandler.getUpdatedPricingMap(objApplicationIdList);

            List<Map<String,Object>> responseList =  new List<Map<String,Object>>();
            for(genesis__Applications__c appObj: objApplicationList){
                Map<String,Object> individualResponse =  (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(appObj));

                if(updatedPricingDetailMap.containsKey(appObj.Id)){
                    List<genesis__Application_Pricing_Detail__c> updatedPricingList = updatedPricingDetailMap.get(appObj.Id);
                    Map<String,Object> pricingResponseMap = new Map<String,Object>();
                    pricingResponseMap.put(ExternalConstants.RECORDS_KEY,updatedPricingList);
                    pricingResponseMap.put(ExternalConstants.DONE_KEY,true);
                    pricingResponseMap.put(ExternalConstants.TOTAL_SIZE_KEY,updatedPricingList.size());

                    individualResponse.put(ExternalConstants.PRICING_DETAIL_KEY,pricingResponseMap);
                }
                else{
                    individualResponse.put(ExternalConstants.PRICING_DETAIL_KEY,null);
                }
                responseList.add(individualResponse);
            }
            response.responseBody = Blob.valueOf(JSON.serialize(responseList));
            response.statusCode = ExternalConstants.TWO_HUNDRED_STATUS_CODE;
        }
        catch (CustomException objCustomException) {
            PortalHelper.saveExceptionLog(objCustomException, CLASS_NAME);
            response.responseBody = Blob.valueOf(JSON.serialize(new List<genesis__Applications__c>()));
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            response.responseBody = Blob.valueOf(JSON.serialize(new List<genesis__Applications__c>()));
        }
    }
}