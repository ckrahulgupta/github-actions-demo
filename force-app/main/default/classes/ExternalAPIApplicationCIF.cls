/**********************************************************************************************
* @className         : ExternalAPIApplicationCIF
* @description       : This class is used to fetch data from application by taking CIF as parameter.
* @author            : simran
* @created Date      : 02-28-2022
* @last modified on  : 03-19-2025
* @last modified by  : Kabir Pramanik
**********************************************************************************************/
 
@RestResource(urlMapping='/SearchLoan/*')
global without sharing class ExternalAPIApplicationCIF {
  global static String CIF_NUMBER;
  private static final String CLASS_NAME = ExternalAPIApplicationCIF.class.getName();
 
  /**
   * @description This method is used to return application records by taking CIF as parameter
   * @param objCif 
   * @exception 
   */
	@HttpPost
	global static void applicationRecordCIF(String objCif){
		RestResponse response = RestContext.response;
		List<genesis__Applications__c> objApplicationList = new List<genesis__Applications__c>();
		List<Id> appIdList = new List<Id>();
		List<User> loggedInUser = new List<User>();
		try{
			response.addHeader(ExternalConstants.CONTENT_TYPE, ExternalConstants.APPLICATION_JSON);
			ExternalApplicationOriginationUtil.checkForEmptyString(objCif,PortalConstants.REQUIRED_PARAMETERS_MISSING);
			ExternalAPIApplicationCIFHandler.validateExternalUser(objCif);
			loggedInUser = ExternalSecurityUtil.getLoggedInUser();

			if(JSON.serialize(System.Label.AgVend_External_User_Profile_Label).contains(loggedInUser[0].Profile.Name)){
				objApplicationList = ExternalAPIApplicationCIFHandler.getApplicationByCIF(objCif);
			}
			else{
				objApplicationList = ExternalAPIApplicationCIFHandler.getApplicationByParty();
			}
			for(genesis__Applications__c app: objApplicationList){
				appIdList.add(app.Id);
				if (String.isBlank(app.ERP_Id__c)) {
					app.ERP_Id__c = ExternalConstants.EMPTY_STRING; 
				}
				if(app.genesis__Maturity_Date__c == null){
					app.genesis__Maturity_Date__c = null;
				}
			}

			Map<Id, List<genesis__Application_Pricing_Detail__c>> updatedPricingDetailMap = ExternalAPIApplicationCIFHandler.getUpdatedPricingMap(appIdList);

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
		catch(CustomException objCustomException) {
			PortalHelper.saveExceptionLog(objCustomException, CLASS_NAME);
			response.responseBody = Blob.valueOf(JSON.serialize(new List<genesis__Applications__c>()));
		} 
		catch (Exception objException) {
			PortalHelper.saveExceptionLog(objException, CLASS_NAME);
			response.responseBody = Blob.valueOf(JSON.serialize(new List<genesis__Applications__c>()));
		}
	}

 
  /**
   * @description a list of loans and their associated records a flat a structure. CIF number should be passed by parameter as the only HTTP GET parameter
   * @return  `List<genesis__Applications__c>`
   */
  @HttpGet
  global static List<genesis__Applications__c> getLoansByCIFNumber() {
    RestRequest getRequest = RestContext.request;
    CIF_NUMBER = String.isBlank(CIF_NUMBER)
            ? getRequest.requestURI.split('/')[2]
            : CIF_NUMBER;
    ExternalAPIUtilities.LoanAPIReturnedResultWrapper loansWrapper = ExternalAPIUtilities.getLoansByCIFNumber(ExternalAPIApplicationCIF.CIF_NUMBER);
    return loansWrapper.LoansInHierarchyStructure;
  }
}