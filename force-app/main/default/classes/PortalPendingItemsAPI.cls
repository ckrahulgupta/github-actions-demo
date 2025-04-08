/**
 * @description       : Purpose of this class is to fetch the generated conga template document Id
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 03-12-2024
 * @last modified by  :  Pritam Roy
**/

global without sharing class PortalPendingItemsAPI implements clcommon.PortalCustomRemoteAPI1 {

    // constants specific for this class [start]
    private static final String KEY_APPLICATION_ID = 'applicationId';
    private static final String KEY_FETCH_TYPE = 'fetchType';
    private static final String FETCH_TYPE_PENDING_ITEMS = 'pendingItems';
    private static final String FETCH_TYPE_ADDITIONAL_ITEMS = 'additionalItems';
    private static final String TASK_STATUS_COMPLETED = 'COMPLETED';
    private static final String TASK_STATUS_OPEN = 'OPEN';
    private static final String RESP_KEY_TASK_ID = 'task_id';
    private static final String RESP_KEY_TASK_SUBJECT = 'task_subject';
    private static final String RESP_KEY_TASK_COMMENTS = 'task_comments';
    private static final String RESP_KEY_TASK_STATUS = 'task_status';
    private static final String RESP_KEY_TASK_DOC_NEEDED = 'task_document_needed';
    private static final String RESP_KEY_TASK_COMPLETED_DATE = 'task_completed_date';
    private static final String RESP_KEY_DOC_CAT_ID = 'document_category_id';
    private static final String RESP_KEY_DOC_CAT_NAME = 'document_category_name';
    private static final String RESP_KEY_DOC_CAT_DESCRIPTION = 'document_category_description';
    private static final String RESP_KEY_DOC_CAT_STATUS = 'document_category_status';
    private static final String DOC_CAT_MISCELLANEOUS = 'Miscellaneous';
    private static final String RESP_KEY_DOC_CAT_ATTACHMENT_COUNT = 'document_category_attachment_count';
    private static final String SHOW_IN_PORTAL_VALUE = 'UPLOAD_VIA_PORTAL';
    private static final String CLASS_NAME = 'PortalPendingItemsAPI';
    // constants specific for this class [end]

    List<clcommon.PortalCustomRemoteActionRecord> responseData = 
                                                new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();

    String applicationId = null;
    String fetchType = null;

    /**
    * @description : Method called from portal to fetch conga document Id
    * @author  Pritam Roy | 03-12-2024 
    * @param componentStructureName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStructureName,
                                            String[] disclosureNames,
                                            Map<String, Object> request) {
        
        SavePoint dbSavePoint = Database.setSavepoint();  
        List<clcommon__Document_Category__c> objDocumentCategoryList;
        List<Task> objTaskList;
        Map<String, Object> responseMap;

        try { 
            if (String.isBlank((String) request.get(KEY_APPLICATION_ID)) 
                || String.isBlank((String) request.get(KEY_FETCH_TYPE))) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }

            applicationId = (String) request.get(KEY_APPLICATION_ID);
            fetchType = (String) request.get(KEY_FETCH_TYPE);
           
            Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationId); 
            if (!isValidUser) {
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }

            objDocumentCategoryList = [SELECT Id, 
                                              clcommon__Category_Name__c, 
                                              Attachment_Count__c, 
                                              clcommon__Show_In_Portal__c, 
                                              clcommon__Status__c, 
                                              genesis__Application__c, 
                                              clcommon__Description__c, 
                                              CreatedDate, 
                                              LastModifiedDate 
                                        FROM clcommon__Document_Category__c 
                                        WHERE clcommon__Show_In_Portal__c = :SHOW_IN_PORTAL_VALUE
                                        AND genesis__Application__c = :applicationId];

            objTaskList = [SELECT Id, 
                                  Is_Document_Needed__c, 
                                  Comments__c, 
                                  Completed_Date__c, 
                                  Subject,
                                  genesis__Task_Setup__c,
                                  Status 
                            FROM Task
                            WHERE genesis__Application__c = :applicationId];


            if (fetchType.equals(FETCH_TYPE_PENDING_ITEMS)) {
                
                Map<String, clcommon__Document_Category__c> objDocumentCategoryMap = 
                                                new Map<String, clcommon__Document_Category__c>();

                for (clcommon__Document_Category__c objDocumentCategory : objDocumentCategoryList) {
                    if(objDocumentCategory.clcommon__Category_Name__c == 'Notice of Security Interest'){
                        objDocumentCategoryMap.put('Notice of Security Interest (CFA Action)', objDocumentCategory);
                    }
                    else if(objDocumentCategory.clcommon__Category_Name__c == 'Lien Search'){
                        objDocumentCategoryMap.put('Lien Search (CFA Action)', objDocumentCategory); 
                    }
                    else{
                        objDocumentCategoryMap.put(objDocumentCategory.clcommon__Category_Name__c, objDocumentCategory);
                    }
                }
            
                for (Task objTask : objTaskList) {
 
                    if (((String) objTask.Status).equalsIgnoreCase(TASK_STATUS_COMPLETED)) {
                        
                        responseMap = new Map<String, Object>();

                        responseMap.put(RESP_KEY_TASK_ID, objTask.Id);
                        responseMap.put(RESP_KEY_TASK_SUBJECT, objTask.Subject);
                        responseMap.put(RESP_KEY_TASK_COMMENTS, objTask.Comments__c);
                        responseMap.put(RESP_KEY_TASK_STATUS, objTask.Status);
                        responseMap.put(RESP_KEY_TASK_DOC_NEEDED, objTask.Is_Document_Needed__c);
                        responseMap.put(RESP_KEY_TASK_COMPLETED_DATE, objTask.Completed_Date__c);
                        
                        if (objTask.Is_Document_Needed__c && objDocumentCategoryMap.containsKey(objTask.Subject)) {
                            responseMap.put(RESP_KEY_DOC_CAT_ID, objDocumentCategoryMap.get(objTask.Subject).Id);
                            responseMap.put(RESP_KEY_DOC_CAT_NAME, objDocumentCategoryMap.get(objTask.Subject).clcommon__Category_Name__c);
                            responseMap.put(RESP_KEY_DOC_CAT_DESCRIPTION, objDocumentCategoryMap.get(objTask.Subject).clcommon__Description__c);
                            responseMap.put(RESP_KEY_DOC_CAT_STATUS, objDocumentCategoryMap.get(objTask.Subject).clcommon__Status__c);
                            responseMap.put(RESP_KEY_DOC_CAT_ATTACHMENT_COUNT, objDocumentCategoryMap.get(objTask.Subject).Attachment_Count__c);
                        }

                        // for exception tasks 
                        else if (objTask.genesis__Task_Setup__c == null && objDocumentCategoryMap.containsKey(DOC_CAT_MISCELLANEOUS)) {
                            responseMap.put(RESP_KEY_TASK_DOC_NEEDED, true);
                            responseMap.put(RESP_KEY_DOC_CAT_ID, objDocumentCategoryMap.get(DOC_CAT_MISCELLANEOUS).Id);
                            responseMap.put(RESP_KEY_DOC_CAT_NAME, objDocumentCategoryMap.get(DOC_CAT_MISCELLANEOUS).clcommon__Category_Name__c);
                            responseMap.put(RESP_KEY_DOC_CAT_DESCRIPTION, objDocumentCategoryMap.get(DOC_CAT_MISCELLANEOUS).clcommon__Description__c);
                            responseMap.put(RESP_KEY_DOC_CAT_STATUS, objDocumentCategoryMap.get(DOC_CAT_MISCELLANEOUS).clcommon__Status__c);
                            responseMap.put(RESP_KEY_DOC_CAT_ATTACHMENT_COUNT, objDocumentCategoryMap.get(DOC_CAT_MISCELLANEOUS).Attachment_Count__c);
                        }
                        
                        responseData.add(new clcommon.PortalCustomRemoteActionRecord(responseMap));  
                    }      
                }

            } else if (fetchType.equals(FETCH_TYPE_ADDITIONAL_ITEMS)) {

                Map<String, Task> objTaskMap = new Map<String, Task>();

                for (Task objTask : objTaskList) {
                    objTaskMap.put(objTask.Subject, objTask);
                }

            
                for (clcommon__Document_Category__c objDocumentCategory : objDocumentCategoryList) {

                    responseMap = new Map<String, Object>();

                    String catName = '';
                    if(objDocumentCategory.clcommon__Category_Name__c == 'Notice of Security Interest'){
                        catName = 'Notice of Security Interest (CFA Action)';
                    }
                    else if(objDocumentCategory.clcommon__Category_Name__c == 'Lien Search'){
                        catName = 'Lien Search (CFA Action)';
                    }
                    else{
                        catName = objDocumentCategory.clcommon__Category_Name__c;
                    }

                    if (!objTaskMap.containsKey(catName) 
                            || (objTaskMap.containsKey(catName) 
                                && !((String) objTaskMap.get(catName).Status).equalsIgnoreCase(TASK_STATUS_COMPLETED))) {
                        responseMap.put(RESP_KEY_DOC_CAT_ID, objDocumentCategory.Id);
                        responseMap.put(RESP_KEY_DOC_CAT_NAME, objDocumentCategory.clcommon__Category_Name__c);
                        responseMap.put(RESP_KEY_DOC_CAT_DESCRIPTION, objDocumentCategory.clcommon__Description__c);
                        responseMap.put(RESP_KEY_DOC_CAT_STATUS, objDocumentCategory.clcommon__Status__c);
                        responseMap.put(RESP_KEY_DOC_CAT_ATTACHMENT_COUNT, objDocumentCategory.Attachment_Count__c);

                        responseData.add(new clcommon.PortalCustomRemoteActionRecord(responseMap));  
                    }

                    // if (!objTaskMap.containsKey(objDocumentCategory.clcommon__Category_Name__c)) {
                    //     responseMap.put(RESP_KEY_DOC_CAT_ID, objDocumentCategory.Id);
                    //     responseMap.put(RESP_KEY_DOC_CAT_NAME, objDocumentCategory.clcommon__Category_Name__c);
                    //     responseMap.put(RESP_KEY_DOC_CAT_DESCRIPTION, objDocumentCategory.clcommon__Description__c);
                    //     responseMap.put(RESP_KEY_DOC_CAT_STATUS, objDocumentCategory.clcommon__Status__c);
                    //     responseMap.put(RESP_KEY_DOC_CAT_ATTACHMENT_COUNT, objDocumentCategory.Attachment_Count__c);

                    //     responseData.add(new clcommon.PortalCustomRemoteActionRecord(responseMap));  
                    // }
                }

                // for (Task objTask : objTaskList) {
 
                //     if (!((String) objTask.Status).equalsIgnoreCase(TASK_STATUS_COMPLETED)) {
                        
                //         responseMap = new Map<String, Object>();
                        
                //         if (objTask.Is_Document_Needed__c && objDocumentCategoryMap.containsKey(objTask.Subject)) {
                //             responseMap.put(RESP_KEY_TASK_ID, objTask.Id);
                //             responseMap.put(RESP_KEY_TASK_SUBJECT, objTask.Subject);
                //             responseMap.put(RESP_KEY_TASK_COMMENTS, objTask.Comments__c);
                //             responseMap.put(RESP_KEY_TASK_STATUS, objTask.Status);
                //             responseMap.put(RESP_KEY_TASK_DOC_NEEDED, objTask.Is_Document_Needed__c);
                //             responseMap.put(RESP_KEY_TASK_COMPLETED_DATE, objTask.Completed_Date__c);

                //             responseMap.put(RESP_KEY_DOC_CAT_ID, objDocumentCategoryMap.get(objTask.Subject).Id);
                //             responseMap.put(RESP_KEY_DOC_CAT_NAME, objDocumentCategoryMap.get(objTask.Subject).clcommon__Category_Name__c);
                //             responseMap.put(RESP_KEY_DOC_CAT_DESCRIPTION, objDocumentCategoryMap.get(objTask.Subject).clcommon__Description__c);

                //             if (!String.isBlank(objTask.Comments__c)) {
                //                 responseMap.put(RESP_KEY_DOC_CAT_DESCRIPTION, objTask.Comments__c);
                //             }
                //             responseMap.put(RESP_KEY_DOC_CAT_STATUS, objDocumentCategoryMap.get(objTask.Subject).clcommon__Status__c);
                //             responseMap.put(RESP_KEY_DOC_CAT_ATTACHMENT_COUNT, objDocumentCategoryMap.get(objTask.Subject).Attachment_Count__c);

                //             responseData.add(new clcommon.PortalCustomRemoteActionRecord(responseMap));  
                //         }
                        
                        
                //     }      
                // }

            } else {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }

            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS; 

        } catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, CLASS_NAME);
            
        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }

        return response;

    }

}


/**
 * 
 * SELECT Id, clcommon__Category_Name__c, Attachment_Count__c, clcommon__Show_In_Portal__c, clcommon__Status__c, genesis__Application__c, clcommon__Description__c, CreatedDate, LastModifiedDate FROM clcommon__Document_Category__c WHERE (clcommon__Show_In_Portal__c = 'UPLOAD_VIA_PORTAL' AND genesis__Application__c = 'a6z74000000GoFs') 
 * 
 * 
 * SELECT Id, Status, Subject, genesis__Application__c FROM Task where genesis__Application__c = 'a6z74000000GoFs'
 */