/**
 * @description       : Its a pooling API which is called every n seconds to get the tier of the applicaiton
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 05-30-2024
 * @last modified by  :  Pritam Roy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   28-01-2022   Subham Nandi   Initial Version
**/
global without sharing class PortalScorePollingAPI implements clcommon.PortalCustomRemoteAPI1 {
    // Constant parameters specific for this class starts
    private static final String KEY_APPLICATION = 'application';
    private static final String CREDIT_RATING = 'CreditRating';
    private static final String EVERGREEN_BIZ_STATUS  = 'evergreenTierTwoBizInfoStatus';
    private static final String LOCKED_CREDIT  = 'lockedCredit';
    // Constant parameters specific for this class ends
    // Declarations specific to this class starts
    String applicationRecord = '';
    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
    Map<String, Object> fieldsMap = new Map<String, Object>();
    genesis__Applications__c objApplicationTocheckTier = new genesis__Applications__c();
    clcommon.Response response = new clcommon.Response();
    genesis__Applications__c objApplication = new genesis__Applications__c();
    clcommon.Response responseFormat;
    // Declarations specific to this class ends

    /**
    * @description : Method called from portal to fetch Application Tier
    * @author  Pritam Roy | 03-12-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                        String[] disclosureNames,
                                        Map<String, Object> argumentsFromPortal) {
        SavePoint dbSavePoint = Database.setSavepoint();
        try {
            if(argumentsFromPortal.get(KEY_APPLICATION) == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            applicationRecord = String.valueOf(argumentsFromPortal.get(KEY_APPLICATION));
            if(applicationRecord != null){
                objApplication = (genesis__Applications__c) Json.deserialize(applicationRecord, genesis__Applications__c.class);
            }
            //logged in user check
            Boolean isValidUser = PortalSecurityUtil.validateUserApplication(objApplication.Id); 
            if (!isValidUser) {
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }
            //query credit rating using the objApplication.Id
            objApplicationTocheckTier = [SELECT Id, 
                                                genesis__Credit_Rating__r.Name,
                                                genesis__Account__c,
                                                Evergreen_Tier_Two_Business_Info_Status__c
                                        FROM genesis__Applications__c 
                                        WHERE Id = :objApplication.Id];
            fieldsMap.put(CREDIT_RATING, objApplicationTocheckTier.genesis__Credit_Rating__r.Name);
            fieldsMap.put(EVERGREEN_BIZ_STATUS,objApplicationTocheckTier.Evergreen_Tier_Two_Business_Info_Status__c);
            //Testing for Frozen Credit Score -----------
            //query the borrower account and send the response of credit bureau flag along with it
            Account objBorrowerAccount = [SELECT Id,
                                                Score_1__c,
                                                Credit_Bureau_Locked__c
                                                FROM Account 
                                                WHERE Id= :objApplicationTocheckTier.genesis__Account__c];
            fieldsMap.put(LOCKED_CREDIT, objBorrowerAccount.Credit_Bureau_Locked__c);
            //Testing for Frozen Credit Score -----------
            if(fieldsMap.get(CREDIT_RATING)!= NULL){
                responseData.add(new clcommon.PortalCustomRemoteActionRecord(fieldsMap));
                if(responseData.size() > 0){
                    responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
                }
                response.content = null;
                response.response = responseFormat.response;
                response.status = clcommon.Constants.SUCCESS;
                return response;
            }
            else {
                response.status = clcommon.Constants.PENDING;
                return response;
            }
            
        } catch (CustomException ex) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = ex.getMessage();
        }catch (Exception ex) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
        }
        return null;
}
}