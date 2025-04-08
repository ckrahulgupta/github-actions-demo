/**
 * @description       : Purpose of this class is to check the status of PortalSaveAdditionalInfoBatch and return response success when completed.
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 01-22-2024
 * @last modified by  : Suraj Kumar
**/
global without sharing class PortalSaveAdditionalInfoPollingAPI implements clcommon.PortalCustomRemoteAPI1 {

    private static final String CLASS_NAME =  PortalSaveAdditionalInfoPollingAPI.class.getName();
    private static final String BATCH_IDS = 'batchIds';
    private static final String COMPLETED_STATUS = 'Completed';

    /**
    * @description 
    * @author Suraj Kumar | 01-19-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                        String[] disclosureNames, 
                                        Map<String, Object> request) {

        clcommon.Response response = new clcommon.Response();
        Map<String, Object> responseFieldsMap = new Map<String, Object>();
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();

        try{
            validateRequiredParameters(request);
            String batchIdDetails = String.valueOf(request.get(BATCH_IDS));
            List<Object> batchObject = (List<Object>) JSON.deserializeUntyped (batchIdDetails);

            List<Id> batchIds = new List<Id>();
            for(Object obj: batchObject){
                batchIds.add((Id)String.valueOf(obj));
            }

            Boolean batchStatus = isBatchCompleted(batchIds);
            
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(responseFieldsMap));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData); 

            if(batchStatus){
                response.status = clcommon.Constants.SUCCESS;
            }else{
                response.status = clcommon.Constants.PENDING;
            }

        }catch (CustomException objCustomException) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, CLASS_NAME);
        } catch (Exception objException) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response;
    }

    /**
    * @description : purpose of this method is to check batch status and return true when batch status is completed.
    * @author Suraj Kumar | 01-19-2024 
    * @param batchIds 
    * @return Boolean 
    **/
    private static Boolean isBatchCompleted(List<Id> batchIds){
        List<AsyncApexJob> batchObjList = [SELECT Id, 
                                                    Status 
                                                FROM AsyncApexJob 
                                                WHERE Id IN :batchIds];
        for(AsyncApexJob batchObj: batchObjList){
            if(!batchObj.Status.equals(COMPLETED_STATUS)){
                return false;
            }
        }
        return true;
    }

    /**
    * @description 
    * @author Suraj Kumar | 01-22-2024 
    * @param request 
    **/
    private static void validateRequiredParameters(Map<String, Object> request){
        if(!request.containsKey(BATCH_IDS)){
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }
}