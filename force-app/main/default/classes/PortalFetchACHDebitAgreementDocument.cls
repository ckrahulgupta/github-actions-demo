/**
 * @description       : Portal API to fetch ACH Debit Documents
 * @author            : Tuhin Bhunia
 * @group             : 
 * @last modified on  : 03-06-2024
 * @last modified by  :  Pritam Roy
**/
global without sharing class PortalFetchACHDebitAgreementDocument implements clcommon.PortalCustomRemoteAPI1{

    //Constants for this specific class starts
    private static final String TITLE = 'title';
    private static final String CREATED_DATE = 'createdDate';
    private static final String CONTENT_DOCUMENT_ID = 'contentDocumentId';
    private static final String STATUS = 'status';
    //Constants for this specific class ends

    private final String CLASS_NAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));

    /**
    * @description : user not authorized
    * @author  Pritam Roy | 03-06-2024 
    * @param objLoggedInUserList 
    **/
    private static void checkException(List<User> objLoggedInUserList){
        if(objLoggedInUserList.isEmpty() || objLoggedInUserList[0].Account.ParentId == null){
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }
    }
    /**
    * @description : fetch ACH Debit Documents to show in portal
    * @author  Pritam Roy | 03-06-2024 
    * @param componentStructureName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStructureName,
                                                String[] disclosureNames,
                                                Map<String, Object> request) {
        
        SavePoint dbSavePoint = Database.setSavepoint();

        List<clcommon__Category_Attachment_Association__c> categoryAssociationList = new List<clcommon__Category_Attachment_Association__c>();
        List<clcommon.PortalCustomRemoteActionRecord> responseDataList = new List<clcommon.PortalCustomRemoteActionRecord>();
        List<Map<String, Object>> documentList = new List<Map<String,Object>>();
        List<User> objLoggedInUserList = new List<User>();
        clcommon.Response response = new clcommon.Response();
        
        List<ContentDocument> contentDocumentList = new List<ContentDocument>();
        try{

            objLoggedInUserList = [SELECT  Id, Name, 
                                        ContactId,
                                        AccountId,
                                        Account.ParentId,
                                        Account.Parent.ACH_Debit_Agreement_Status__c
                                    FROM User
                                    WHERE Id =: UserInfo.getUserId()
                                    LIMIT 1];
                                    
            checkException(objLoggedInUserList);
            categoryAssociationList = [SELECT Id,
                                            clcommon__Content_Document_Id__c,
                                            Account__r.ACH_Debit_Agreement_Status__c
                                        FROM clcommon__Category_Attachment_Association__c 
                                        WHERE Account__c =: objLoggedInUserList[0].Account.ParentId
                                        ORDER BY CreatedDate DESC LIMIT 1];
            if(!categoryAssociationList.isEmpty()){
                contentDocumentList = [SELECT Id,
                                            Title,
                                            CreatedDate
                                        FROM ContentDocument 
                                        WHERE Id =: categoryAssociationList[0].clcommon__Content_Document_Id__c];
            }

            if(!categoryAssociationList.isEmpty() && !contentDocumentList.isEmpty()){
                
                Map<String, Object> responseDataMap = new Map<String, Object>();
                responseDataMap.put(TITLE, contentDocumentList[0].Title);
                responseDataMap.put(CREATED_DATE, contentDocumentList[0].CreatedDate);
                responseDataMap.put(CONTENT_DOCUMENT_ID, categoryAssociationList[0].clcommon__Content_Document_Id__c);
                responseDataMap.put(STATUS, categoryAssociationList[0].Account__r.ACH_Debit_Agreement_Status__c);
                documentList.add(responseDataMap);

                for(Map<String, Object> objMap : documentList){
                    responseDataList.add(new clcommon.PortalCustomRemoteActionRecord(objMap));
                }
            }

            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseDataList);
            response.status = clcommon.Constants.SUCCESS; 

        }catch(Exception objException){
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objException.getMessage();
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response;
    }
}