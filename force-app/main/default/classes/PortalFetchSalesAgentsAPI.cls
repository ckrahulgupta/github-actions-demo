/**
 * @description       : This class is used to fetch all the Sales Agents and Sales Agent Plus
 * @author            : Tuhin Bhunia
 * @group             : 
 * @last modified on  : 03-12-2024
 * @last modified by  : Tuhin Bhunia
**/
global without sharing class PortalFetchSalesAgentsAPI implements clcommon.PortalCustomRemoteAPI1{
    
    private final String CLASSNAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    private final String KEY_SA_ADMIN_ID = 'saAdminAccountId';

    /**
     * @description : This method is used to get the dealer account id of current logged in Certified Lender.
     * @return  `Id`
     * @exception 
     */
    private static Id getDealerAccountId() {
        List<User> objLoggedInUserList = [SELECT Id,
                                                AccountId,
                                                Account.ParentId
                                                FROM USER
                                                WHERE Id = :UserInfo.getUserId()
                                                LIMIT 1];
        
        if (objLoggedInUserList.isEmpty() || objLoggedInUserList[0].Account.ParentId == null) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }

        return objLoggedInUserList[0].Account.ParentId;
    }

    /**
     * @description : This method is used to fetch all the sales agent and sales agent plus details and send it to the Portal.
     * @param componentStructureName 
     * @param disclosureNames 
     * @param request 
     * @return  `clcommon.Response`
     * @exception 
     */
    global clcommon.Response invokeAction(String componentStructureName,
                                                String[] disclosureNames,
                                                Map<String, Object> request) {

        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        clcommon.Response response = new clcommon.Response();

        String saAdminAccountId = '';

        List<Account> saAccountList = new List<Account>();
        List<clcommon__Relationship__c> saAdminRelationshipList = new List<clcommon__Relationship__c>();

        Set<Id> assignedSalesAgentIdSet = new Set<Id>();

        try{

            saAdminAccountId = String.valueOf(request.get(KEY_SA_ADMIN_ID));
            if(String.isBlank(saAdminAccountId) || saAdminAccountId == null) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }

            saAccountList = [SELECT Id, name, ParentId 
                            FROM Account
                            WHERE ParentId =: getDealerAccountId()
                            AND RecordType.Name IN (:PortalConstants.SALES_AGENT, 
                                              :PortalConstants.SALES_AGENT_PLUS
                                            )
                            ];
            
            saAdminRelationshipList = [SELECT Id,
                                          Name, 
                                          clcommon__Entity__c, 
                                          clcommon__Related_Entity__c, 
                                          clcommon__Relationship__r.Name
                                   FROM clcommon__Relationship__c
                                   WHERE clcommon__Related_Entity__c IN :saAccountList
                                   AND clcommon__Entity__c =: saAdminAccountId
                                   AND clcommon__Relationship__r.Name =: PortalConstants.RELATED_SALES_AGENT
                                ];
            for(clcommon__Relationship__c objRelationship : saAdminRelationshipList){
                assignedSalesAgentIdSet.add(objRelationship.clcommon__Related_Entity__c);
            }
            // createSalesAgentMap(saAccountList, assignedSalesAgentIdSet);
            for(Map<String, Object> resultMap : createSalesAgentMap(saAccountList, assignedSalesAgentIdSet)){
                responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap));
            }

            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS;

        }catch(Exception objException){
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objException.getMessage();
            PortalHelper.saveExceptionLog(objException, CLASSNAME);
        }
        return response;
    }

    /**
     * @description : This method is use to create the Sales agent map.
     * @param saAccountList 
     * @param assignedSalesAgentIds 
     * @return  `List<Map<String, Object>>`
     */
    public static List<Map<String, Object>> createSalesAgentMap(List<Account> saAccountList, Set<Id> assignedSalesAgentIds){

        List<Map<String, Object>> resultMapList = new List<Map<String, Object>>();

        for(Account objAccount : saAccountList){

            Map<String, Object> resultMap = new Map<String, Object>();
            if(assignedSalesAgentIds.contains(objAccount.Id)){
                resultMap.put('SA_Assigned', true);
            }else{
                resultMap.put('SA_Assigned', false);
            }
            resultMap.put('SA_Name', objAccount.Name);
            resultMap.put('SA_Id', objAccount.Id);

            resultMapList.add(resultMap);
        }
        return resultMapList;
    }
}