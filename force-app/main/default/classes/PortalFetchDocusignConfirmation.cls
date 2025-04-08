/**
 * @description       : This class is used to determine Agreement Sign is true or not in Portal.
 * @author            : iAyush
 * @group             : 
 * @last modified on  : 01-08-2025
 * @last modified by  : Shruti Tamakhuwala
**/
global without sharing class PortalFetchDocusignConfirmation implements clcommon.PortalCustomRemoteAPI1{
    private static final String KEY_APPLICATION = 'application';
    String applicationRecord = '';
    genesis__Applications__c fetchApplicationObj = new genesis__Applications__c();

    /**
     * @description : This method takes and validates the portal request and return the response.
     * @param componentStrName 
     * @param disclosureNames 
     * @param argumentsFromPortal 
     * @return  `clcommon.Response`
     * @exception 
     */
    global clcommon.Response invokeAction(String componentStrName,
                                          String[] disclosureNames,
                                          Map<String, Object> argumentsFromPortal) {
        clcommon.Response response = new clcommon.Response();
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        Map<String,Object> field = new Map<String,Object>();
        try{
            applicationRecord = String.valueOf(argumentsFromPortal.get(KEY_APPLICATION));
            if (String.isBlank(applicationRecord)) {
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            fetchApplicationObj = (genesis__Applications__c) Json.deserialize(applicationRecord, genesis__Applications__c.class);

            genesis__Applications__c applicationObj = [SELECT Id,
                                                            Agreement_Sign__c 
                                                       FROM genesis__Applications__c 
                                                       WHERE Id =:fetchApplicationObj.Id
                                                       LIMIT 1];
            if(applicationObj.Agreement_Sign__c == true){   
                    response.status = clcommon.Constants.SUCCESS;
                    field.put('Agreement_Sign__c',applicationObj.Agreement_Sign__c);
                    responseData.add( new clcommon.PortalCustomRemoteActionRecord(field));
                    response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
                    response.content = null;       
            }
            else{
                response.status = clcommon.Constants.PENDING;
            }
        }
        catch (CustomException mce) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = mce.getMessage();
        }
        catch (Exception ex) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
        }
        return response;
    }
}