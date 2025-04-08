/**
 * @description       : This API is use to Download the CBR Report. 
 * @author            : Simran
 * @group             : 
 * @last modified on  : 08-10-2024
 * @last modified by  : Soumik Pattanayak
**/
global without sharing class PortalDownloadCBRReportAPI implements clcommon.PortalCustomRemoteAPI1 {
    private static final String URL_TO_DOWNLOAD='contentDocumentURL';
    private static final String ACCOUNT_ID='accountId';
    private static final String ACCOUNT_NAME='accountName';
    private static final String EDIT = 'edit';
    private static final String NONE = 'None';
    String applicationId;
    String url;
    /**
    * @description method call by portal to download the Score Summary Report.
    * @author Simran | 06-07-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames,Map<String,Object> request){
        Map<String, Object> fieldsMap = new Map<String, Object>();
        List<clcommon.PortalCustomRemoteActionRecord> responseData= new List<clcommon.PortalCustomRemoteActionRecord>();
        SavePoint dbSavePoint = Database.setSavePoint();
        clcommon.Response response= new clcommon.Response();
        try{
            applicationId= String.valueOf(request.get(PortalConstants.APPLICATION_ID));
            if(String.isEmpty(applicationId)){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            validatePortalUser(applicationId);
            List<clcommon__Party__c> partyList=[SELECT Id, 
                                                    genesis__Application__r.FICO_Score__c,
                                                    genesis__Application__r.SBSS_70_Score__c,
                                                    clcommon__Account__r.Score_1__c,
                                                    clcommon__Account__r.SBSS70_Score__c,
                                                    clcommon__Account__r.Name,
                                                    clcommon__Party_Types__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c =:applicationId
                                                AND clcommon__Party_Types__c 
                                                IN (:PortalConstants.CERTIFIED_LENDER,
                                                    :PortalConstants.CERTIFIED_LENDER_PLUS,
                                                    :PortalConstants.PRINCIPAL_PARTY_NAME,
                                                    :PortalConstants.BORROWER_PARTY_NAME,
                                                    :PortalConstants.FIELD_STAFF_AGENT)];

            String downloadUrl = getDownloadUrl(createSharingRecord(partyList));
            if(downloadUrl == null){
                response.status = clcommon.Constants.PENDING;
                return response;
            }
            genesis__Applications__c updateApplication=[SELECT Id,CBR_Report_Downloaded_On__c FROM genesis__Applications__c WHERE Id=:applicationId];
            updateApplication.CBR_Report_Downloaded_On__c=System.now();
            Database.update(updateApplication,true);

            fieldsMap.put(URL_TO_DOWNLOAD, downloadUrl);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(fieldsMap));
            response.content = null;
            response.response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData).response;
            response.status = clcommon.Constants.SUCCESS;
        }
        catch (CustomException objCustomException){
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            PortalHelper.saveExceptionLog(objCustomException, PortalDownloadCBRReportAPI.class.getName());
        }
        catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            PortalHelper.saveExceptionLog(objException, PortalDownloadCBRReportAPI.class.getName());
        }
        return response;

    }
    /**
    * @description This method is use to get the download url for FICO Summary Report.
    * @author Simran | 06-07-2024 
    * @param accountId
    * @return String 
    **/
    private static String getDownloadUrl(String accountId) {
        String urlToDownloadReport = 'sfc/servlet.shepherd/document/download';
        String templateName='%Credit Bureau Summary.pdf';
        List<String> contentDocumentIds = new List<String>();

        List<ContentDocumentLink> contentDocumentLinkList = [SELECT ContentDocumentId,Visibility,
                                                                        linkedEntityId
                                                                FROM ContentDocumentLink
                                                                WHERE linkedEntityId =:accountId];
        if(contentDocumentLinkList.size()<= 0){
            throw new CustomException(PortalConstants.CONTENT_DOC_LINK_EXP);
        }
        for (ContentDocumentLink objContentLink : contentDocumentLinkList) {
            contentDocumentIds.add(objContentLink.ContentDocumentId);
        } 
        // Query on Content Document
        List<ContentDocument> contentDocumentList = [
                        SELECT Id,
                                Title
                        FROM ContentDocument
                        WHERE Id IN :contentDocumentIds
                        AND Title LIKE :templateName
                        ORDER BY CreatedDate DESC LIMIT 1];

        if (contentDocumentList.size() < 1) {
            return null;
        } 
        for (ContentDocument objContent : contentDocumentList) {
            urlToDownloadReport = urlToDownloadReport + PortalConstants.SLASH_STRING + objContent.Id;
        }
        return urlToDownloadReport;
    }

    /**
    * @description Method to validate the user access
    * @author Simran | 06-07-2024 
    * @param applicationId 
    **/
    private static void validatePortalUser(Id applicationId){
        Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationId);
        if (!isValidUser) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }
    }
   
    
    /**
    * @description Method is used to create the sharing record
    * @author Simran | 06-13-2024 
    * @param partyList 
    * @return Map<Id, String> 
    **/
    private static String createSharingRecord(List<clcommon__Party__c> partyList) {
        Map<Id, Id> userMap = new Map<Id, Id>();
        List<Id> dealerConAccIdList = new List<Id>();
        List<AccountShare> newAccShareList = new List<AccountShare>();
        String applicantId;
        for(clcommon__Party__c party:partyList){
            if(party.clcommon__Party_Types__c== PortalConstants.CERTIFIED_LENDER || party.clcommon__Party_Types__c== PortalConstants.CERTIFIED_LENDER_PLUS || party.clcommon__Party_Types__c == PortalConstants.FIELD_STAFF_AGENT){
                dealerConAccIdList.add(party.clcommon__Account__c);
            }
            else if(party.genesis__Application__r.FICO_Score__c == party.clcommon__Account__r.Score_1__c 
            && party.genesis__Application__r.SBSS_70_Score__c == party.clcommon__Account__r.SBSS70_Score__c){
                applicantId=party.clcommon__Account__c;
            }
        }
        userMap = CFAOriginationHelperClass.getUserListFromAccountList(dealerConAccIdList);
        for (Id clAccountId : dealerConAccIdList) {
            // create sharing records
            AccountShare newAccShare = new AccountShare();
            newAccShare.AccountAccessLevel = EDIT;
            newAccShare.AccountId = applicantId;
            newAccShare.UserOrGroupId = userMap.get(clAccountId);
            newAccShare.OpportunityAccessLevel = NONE;
            newAccShareList.add(newAccShare);
        }
        Database.upsert(newAccShareList, false); 
        return applicantId;
    }
}