/**
 * @description       : API to generate the url required in the portal to download the zip file
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 01-20-2025
 * @last modified by  : Ayan Khanra
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   08-07-2022   Subham Nandi   Initial Version
**/
global without sharing class PortalDownloadPrePrintApplicationAPI implements clcommon.PortalCustomRemoteAPI1 {

    // constants
    private static final String KEY_APPLICATIONS = 'applicationIdList';
    private static final String CLASS_NAME = 'PortalDownloadPrePrintApplicationAPI';
    private static final String URL_TO_DOWNLOAD = 'contentDocumentURL';
    private static final String DOCUMENT_NAME = 'Pre Printed Application.pdf';

    /**
    * @description This method is used to get the url to Download the zip file.
    * @author Rahul Gupta | 08-16-2023 
    * @param contentDocumentLinkList 
    * @param applicationIds
    * @return String 
    **/
    private static String getDownloadUrl(List<ContentDocumentLink> contentDocumentLinkList, List<Id> applicationIds) {
        String urlToDownloadZip = 'sfc/servlet.shepherd/document/download';
        List<String> contentDocumentIds = new List<String>();

        for (ContentDocumentLink objContentLink : contentDocumentLinkList) {
            contentDocumentIds.add(objContentLink.ContentDocumentId);
        }   

        // Query on Content Document
        List<ContentDocument> contentDocumentList = [
                        SELECT Id,
                                Title
                        FROM ContentDocument
                        WHERE Id IN :contentDocumentIds
                        AND Title = :DOCUMENT_NAME
                        ORDER BY CreatedDate DESC
                    ];

        if (contentDocumentList.size() < applicationIds.size()) {
            return null;
        } 
        for (ContentDocument objContent : contentDocumentList) {
            urlToDownloadZip = urlToDownloadZip + '/' + objContent.Id;
        }
        
        return urlToDownloadZip;
    }

    /**
    * @description This method is used to get Recordtype name of loggedin user
    * @author Simran | 03-07-2024 
    * @return String 
    **/
    private static String getLoggedInUserRecordType(){
        List<User> loggedInUser = [SELECT Id, Name, Account.RecordType.Name
                                    FROM User
                                    WHERE Id =: UserInfo.getUserId()
                                ];
        return loggedInUser[0].Account.RecordType.Name;
    }

    /**
    * @description This method is used to filter out the applications based on the RecordType Name of loggedin user.
    * @author Simran | 03-07-2024 
    * @param request 
    * @return List<Id> 
    **/
    private static List<Id> filterApplicationIds(Map<String, Object> request){

        List<Id> applicationIds = new List<Id>();

        if(getLoggedInUserRecordType().equals(PortalConstants.SALES_AGENT_ADMIN)){
                
            List<Id> requestIds = (List<Id>) JSON.deserialize(String.valueOf(request.get(KEY_APPLICATIONS)), List<Id>.class);

            List<clcommon__party__c> partyList = [SELECT id, genesis__Application__c 
                                                FROM clcommon__party__c
                                                WHERE Id IN :requestIds]; 

            for(clcommon__party__c objParty : partyList){
                applicationIds.add(objParty.genesis__Application__c);
            }
        }else{
            applicationIds = 
                    (List<Id>) JSON.deserialize(String.valueOf(request.get(KEY_APPLICATIONS)), List<Id>.class);
        }
        return applicationIds;
    }

    /**
    * @description This method is called from portal to generate the url to download the zip file
    * @author Rahul Gupta | 08-16-2023 
    * @param componentStrName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(
                String componentStrName,
                String[] disclosureNames,
                Map<String, Object> request
            ) {

        // Declaration---------------
        Map<String, Object> fieldsMap = new Map<String, Object>();
        List<clcommon.PortalCustomRemoteActionRecord> responseData = 
                    new List<clcommon.PortalCustomRemoteActionRecord>();
        

        // Declaration---------------
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        try {

            List<Id> applicationIds = filterApplicationIds(request);
            Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationIds);

            if (!isValidUser){
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }
            
            // Query the Content Documentd and check whether all of them have the conga documents generated or not
            List<ContentDocumentLink> contentDocumentLinkList = [
                        SELECT ContentDocumentId,
                                linkedEntityId
                        FROM ContentDocumentLink
                        WHERE linkedEntityId IN :applicationIds
                        ORDER BY SystemModstamp DESC
                    ];

            String downloadUrl = getDownloadUrl(contentDocumentLinkList, applicationIds);

            if (downloadUrl == null) {
                response.status = clcommon.Constants.PENDING;
                return response;
            }

            fieldsMap.put(URL_TO_DOWNLOAD, downloadUrl);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(fieldsMap));
            response.content = null;
            response.response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData).response;
            response.status = clcommon.Constants.SUCCESS;
        } 
        catch (CustomException objCustomException){
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            PortalHelper.saveExceptionLog(objCustomException, CLASS_NAME);
        }
        catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response;
    }
}