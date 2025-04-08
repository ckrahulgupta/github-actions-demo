/**
 * @description       : The purpose of the API is to update the checkbox "Preprint Application" which will fire conga 
 *                      and generate documents based on the selection
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-12-2024
 * @last modified by  :  Pritam Roy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   07-07-2022   Subham Nandi   Initial Version
**/
global without sharing class PortalPrePrintApplicationAPI implements clcommon.PortalCustomRemoteAPI1 {

    private static final String KEY_APPLICATIONS = 'applicationIdList';
    private static final String CLASSNAME = 'PortalPrePrintApplicationAPI';

    
    /**
    * @description : Update Application
    * @author  Pritam Roy | 03-12-2024 
    * @param applications 
    **/
    private static void updatePreprintedApplications(List<genesis__Applications__c> applications) {
        
        // resetting the preprinted flag to false for regeneration
        for (genesis__Applications__c application : applications) {
            if (application.Preprint_Application__c == true) {
                application.Preprint_Application__c = false;
            }
        }
        Database.update(applications, true);
        
        // updating the preprint flag of applications
        for (genesis__Applications__c application : applications) {
            application.Preprint_Application__c = true;
        }
        Database.update(applications, true);
    }

    
    /**
    * @description : Delete Content Document
    * @author  Pritam Roy | 03-12-2024 
    * @param applicationIds 
    **/
    private static void deleteContentDocuments(List<Id> applicationIds) {

        if (!Schema.sObjectType.ContentDocumentLink.isAccessible() || 
            !Schema.sObjectType.ContentDocument.isAccessible() || 
            !Schema.sObjectType.ContentDocument.isDeletable()) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }

        List<ContentDocumentLink> contentDocumentLinks = [
                            SELECT ContentDocumentId 
                            FROM ContentDocumentLink
                            WHERE LinkedEntityId IN :applicationIds
                        ];

        List<Id> contentDocumentLinkIds = new List<Id>();

        for (ContentDocumentLink objContentDocumentLink : contentDocumentLinks) {
            contentDocumentLinkIds.add(objContentDocumentLink.ContentDocumentId);
        }

        List<ContentDocument> contentDocuments = [
                            SELECT Id 
                            FROM ContentDocument 
                            WHERE Id IN :contentDocumentLinkIds
                            AND Title = :ConstantValues.PRE_PRINTED
                        ];

        Database.delete(contentDocuments, true);
    }

    /**
    * @description : Get Logged in User
    * @author  Pritam Roy | 03-12-2024 
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
    * @description : Filter Application Ids
    * @author  Pritam Roy | 03-12-2024 
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
    * @description : Method called from portal to generate Preprint Application
    * @author  Pritam Roy | 03-12-2024 
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
        
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        try {

            List<Id> applicationIds = filterApplicationIds(request);
            Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationIds);

            if (!isValidUser || 
                !Schema.sObjectType.genesis__Applications__c.isAccessible() || 
                !Schema.sObjectType.ContentDocumentLink.isAccessible() || 
                !Schema.sObjectType.ContentDocument.isAccessible() || 
                !Schema.sObjectType.genesis__Applications__c.isUpdateable()) {
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }

            List<genesis__Applications__c> applications = [
                            SELECT Id,
                                   Preprint_Application__c
                            FROM genesis__Applications__c
                            WHERE Id IN :applicationIds
                        ];

            deleteContentDocuments(applicationIds);

            updatePreprintedApplications(applications);

            response.status = clcommon.Constants.SUCCESS;
        } catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            PortalHelper.saveExceptionLog(objCustomException, CLASSNAME);
        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            PortalHelper.saveExceptionLog(objException, CLASSNAME);
        }
        return response;
    }
}