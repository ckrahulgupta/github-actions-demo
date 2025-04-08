/**
 * @description       : this class is used to delete and create party and sharing records for the sales agent admin
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 12-08-2023
 * @last modified by  : Krishanu Chinya
**/
global without sharing class PortalGrantSalesAgentAdminPermissionAPI implements clcommon.PortalCustomRemoteAPI1{

    private final String CLASS_NAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));  
    private final String SA_ACC_ID_LIST = 'saAccountIdList';
    private final String SA_ADMIN_KEY = 'saAdminAccountId';  
    private final String SA_ASSIGNED_KEY = 'SA_Assigned';  
    private final String SA_ID_KEY = 'SA_Id';  

    /**
     * @description : this method is used to craft the sa acc id list from the arguments received
     * @param saAccountIds 
     * @return  `List<Id>`
     */
    private List<Id> getSelectedSAAccIdList(String saAccountIds){
        List<Object> allSelectedSADetailList = new List<Object>();
            List<Id> saAccountIdList = new List<Id>();
            allSelectedSADetailList = (List<Object>) JSON.deserializeUntyped (saAccountIds);

             // processing the details
             for(Object eachSelectedSADetail : allSelectedSADetailList){
                Map<String, Object> selectedSADetailsMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(eachSelectedSADetail));

                if(selectedSADetailsMap.get(SA_ASSIGNED_KEY)==true){
                    Id saAccountId = (Id)selectedSADetailsMap.get(SA_ID_KEY);
                    saAccountIdList.add(saAccountId);
                }
            }
        return saAccountIdList;
    }

    /**
     * @description : this method deletes and creates relationships, parties and sharing records
     * @param componentStructureName 
     * @param disclosureNames 
     * @param request 
     * @return  `clcommon.Response`
     * @exception 
     */
    global clcommon.Response invokeAction(String componentStructureName,String[] disclosureNames,Map<String, Object> request){
        
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();

        try{
            String saAccountIds = (request.containsKey(SA_ACC_ID_LIST)) ? String.valueOf(request.get(SA_ACC_ID_LIST)) : null;
            List<Id> saAccountIdList = new List<Id>();
            saAccountIdList = getSelectedSAAccIdList(saAccountIds);

            //fetching selected sa admin id from request
            String saAdminAccId = (request.containsKey(SA_ADMIN_KEY)) ? String.valueOf(request.get(SA_ADMIN_KEY)) : null;

            if (saAdminAccId == null) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }

            //Delete relationship of selected sales agents and the admin
            List<clcommon__Relationship__c> relToDelete = [SELECT Id,
                                                                clcommon__Entity__c,
                                                                clcommon__Relationship__r.Name
                                                                FROM clcommon__Relationship__c
                                                                WHERE clcommon__Relationship__r.Name =: PortalConstants.RELATED_SALES_AGENT
                                                                AND clcommon__Entity__c=:saAdminAccId];
            
            Database.delete(relToDelete, true);
 
            //create relationship of selected sales agents and the admin
            List<clcommon__Relationship__c> relToCreate = new List<clcommon__Relationship__c>();
            List<clcommon__Reciprocal_Role__c> clRoleObj = [SELECT Id,
                                                        Name
                                                        FROM clcommon__Reciprocal_Role__c
                                                        WHERE Name =: PortalConstants.RELATED_SALES_AGENT];
 
            for(Id saAccId:saAccountIdList){
                clcommon__Relationship__c relationshipObj = new clcommon__Relationship__c();
                relationshipObj.clcommon__Relationship__c = clRoleObj[0].Id;
                relationshipObj.clcommon__Entity__c = saAdminAccId;
                relationshipObj.clcommon__Related_Entity__c = saAccId;
                relToCreate.add(relationshipObj);
            }
 
            Database.insert(relToCreate, true);

            DeleteSalesAgentAdminPartyBatch batchObj = new DeleteSalesAgentAdminPartyBatch(saAccountIdList, saAdminAccId);
            Database.executeBatch(batchObj, 20);

            response.status = clcommon.Constants.SUCCESS;

        }catch (Exception objException) {
            Database.rollback(dbSavePoint);
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objException.getMessage();
        }
        return response;
    }
}