/**********************************************************************************************************************
 * @description       : This is the handler class of ContentDocumentLinkTrigger 
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : Suraj Kumar
**********************************************************************************************************************/
public with sharing class ContentDocumentLinkTriggerHandler{

    private static final String CONTENT_DOCUMENT_ID = 'contentDocumentId';
    private static final String LINKED_ENTITY_ID = 'linkedEntityId';
    private static final String SIZE_OF_CONTENT_DOC_LINK = 'sizeOfContentDocLink';

    /**
    * @description This method is defined for before insert trigger
    * @author Ayan Bhowmik | 02-27-2024 
    * @param events 
    **/
    public static void beforeInsert(List<ContentDocumentLink> events){
        clcommon.Response responseObj = new clcommon.Response();
        try {
            for (ContentDocumentLink event : events) {
                if (event.LinkedEntityId.getSObjectType().getDescribe(SObjectDescribeOptions.FULL).getName().equalsIgnoreCase(PortalConstants.APPLICATION_API_NAME) 
                        || event.LinkedEntityId.getSObjectType().getDescribe(SObjectDescribeOptions.FULL).getName().equalsIgnoreCase(ConstantValues.ACCOUNT)) {
                    event.Visibility = PortalConstants.USER;
                }
            }
        } catch (Exception objException) {
            responseObj.status = clcommon.Constants.API_EXCEPTION;
            responseObj.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, ContentDocumentLinkTriggerHandler.class.getName());
        }
    }

    /**
    * @description This method is defined for after insert trigger
    * @author Ayan Bhowmik | 02-27-2024 
    * @param events 
    **/
    public static void afterInsert(List<ContentDocumentLink> events){
        clcommon.Response responseObj = new clcommon.Response();
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        List<Id> linkedEntityIdList = new List<Id>();
        List<Id> contentDocumentIdList = new List<Id>();

        try {
            for (ContentDocumentLink event : events) {
                linkedEntityIdList.add(event.LinkedEntityId);
                contentDocumentIdList.add(event.ContentDocumentId);
            }
            if (!linkedEntityIdList.isEmpty() & Schema.sObjectType.genesis__Applications__c.isAccessible()) {
                applicationList = [SELECT Id,
                                            DocuSign_Credit_Agreement_Initiated__c,
                                            Agreement_Sign__c,
                                            Signing_Method__c,
                                            Resend_Docusign__c
                                        FROM genesis__Applications__c 
                                        WHERE Id IN :linkedEntityIdList];
            }
            if (applicationList.size()>=1) {
                processContentDocLink(applicationList,contentDocumentIdList,events);
            }
        } catch (Exception objException) {
            responseObj.status = clcommon.Constants.API_EXCEPTION;
            responseObj.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, ContentDocumentLinkTriggerHandler.class.getName());
        }
    }

    /**
    * @description This method is use to process the ContentDocumentLink
    * @author Simran | 06-12-2024 
    * @param applicationList 
    * @param contentDocumentIdList 
     * @param events 
    **/
    private static void processContentDocLink(List<genesis__Applications__c> applicationList,List<Id> contentDocumentIdList,List<ContentDocumentLink> events){
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
        Map<Id, genesis__Applications__c> eventLinkedIdVsAppMap = new Map<Id, genesis__Applications__c>();
        Map<Id, ContentVersion> conDocIdVsConVersionMap = new Map<Id, ContentVersion>();
        Map<Id, Integer> lEntityIdVsConDocLinkMap = new Map<Id, Integer>();
        Map<String, Object> paramMap = new Map<String, Object>();

        for (genesis__Applications__c applicationObj : applicationList) {
            eventLinkedIdVsAppMap.put(applicationObj.Id, applicationObj);
        }
        if (!contentDocumentIdList.isEmpty() & Schema.sObjectType.ContentVersion.isAccessible()) {
            contentVersionList =  [SELECT Id, 
                                            Title,
                                            ContentDocumentId 
                                        FROM ContentVersion 
                                        WHERE ContentDocumentId IN :contentDocumentIdList];
        }
        for (ContentVersion contentVersion : contentVersionList) {
            conDocIdVsConVersionMap.put(contentVersion.ContentDocumentId, contentVersion);
        }
        if (!eventLinkedIdVsAppMap.isEmpty() & Schema.sObjectType.ContentDocumentLink.isAccessible()) {
            contentDocumentLinkList = [SELECT Id, 
                                                ContentDocumentId,
                                                ContentDocument.Title, 
                                                LinkedEntityId 
                                            FROM ContentDocumentLink 
                                            WHERE LinkedEntityId IN :eventLinkedIdVsAppMap.keySet()
                                            AND ContentDocument.Title =: PortalConstants.AGREEMENT_FILE_NAME];
        }
        for (ContentDocumentLink contentDocumentLinkObj : contentDocumentLinkList) {
            if (lEntityIdVsConDocLinkMap.containsKey(contentDocumentLinkObj.LinkedEntityId)) {
                Integer contentDocumentLinkSize = lEntityIdVsConDocLinkMap.get(contentDocumentLinkObj.LinkedEntityId);
                lEntityIdVsConDocLinkMap.put(contentDocumentLinkObj.LinkedEntityId, ++contentDocumentLinkSize);
            } else {
                lEntityIdVsConDocLinkMap.put(contentDocumentLinkObj.LinkedEntityId, PortalConstants.ONE_VALUE);
            }
        }
        for (ContentDocumentLink event : events) {
            if (event.LinkedEntityId.getSObjectType().getDescribe(SObjectDescribeOptions.FULL).getName().equalsIgnoreCase(PortalConstants.APPLICATION_API_NAME)) {
                paramMap.put(LINKED_ENTITY_ID, eventLinkedIdVsAppMap.get(event.LinkedEntityId));
                paramMap.put(CONTENT_DOCUMENT_ID, conDocIdVsConVersionMap.get(event.ContentDocumentId));
                paramMap.put(SIZE_OF_CONTENT_DOC_LINK, lEntityIdVsConDocLinkMap.get(event.LinkedEntityId));
                contentDocumentAfterInsert(event, paramMap);
            }
        }
    }

    /**
    * @description This method is defined for solving after insert trigger
    * @author Ayan Bhowmik | 02-27-2024 
    * @param event 
    * @param paramMap 
    **/
    private static void contentDocumentAfterInsert(ContentDocumentLink event, Map<String, Object> paramMap){
        ContentVersion contentVersionObj = (ContentVersion)paramMap.get(CONTENT_DOCUMENT_ID);
        genesis__Applications__c applicationObj = (genesis__Applications__c)paramMap.get(LINKED_ENTITY_ID);

        if (contentVersionObj != null && contentVersionObj.Title == PortalConstants.AGREEMENT_FILE_NAME) {
            CFAOriginationHelperClass.createDocCategoryAttachment(new Map<String,String>{
                PortalConstants.TITLE_KEY => contentVersionObj.Title,
                PortalConstants.CONTENT_VERSION_ID_KEY => contentVersionObj.Id,
                PortalConstants.CONTENT_DOC_ID_KEY => event.ContentDocumentId,
                PortalConstants.APPLICATION_ID_KEY => event.LinkedEntityId,
                PortalConstants.NAME_KEY => PortalConstants.SIGNED_AGREEMENT_TASK
            });
        }
        categorizeContentDocumentTitles(event,contentVersionObj);
        if (applicationObj == null) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        if (applicationObj.DocuSign_Credit_Agreement_Initiated__c == false) { 
            if (applicationObj.Signing_Method__c == PortalConstants.EMAIL_DOCUSIGN) {
                System.enqueueJob(new DocuSignviaEmail(event.ContentDocumentId,event.LinkedEntityId));
            }
            else if ((applicationObj.Signing_Method__c == PortalConstants.IN_PERSON_DOCUSIGN 
                    | applicationObj.Signing_Method__c == ConstantValues.IN_PERSON_HYBRID) 
                    & applicationObj.Agreement_Sign__c == false ) {
                System.enqueueJob(new InPersonDocuSignCreateEnvelope(event.ContentDocumentId,event.LinkedEntityId)); 
            } 
        }
    }

    /**
    * @description Method is used to categorizing the Content Document 
    * @author Simran | 06-11-2024 
    * @param event 
    * @param contentVersionObj 
    **/
    private static void categorizeContentDocumentTitles(ContentDocumentLink event, ContentVersion contentVersionObj){
        Map<String, String> conVersionTitleVsTaskMap = new Map<String, String>{
            PortalConstants.LIEN_SUBORDINATE => PortalConstants.LIEN_SUBORDINATION_TASK,
            PortalConstants.LOAN_COMMITMENT_LETTER_FILE_NAME => PortalConstants.LOAN_COMMITMENT_LETTER,
            PortalConstants.CUSTOMISED_FORM => PortalConstants.CUSTOMIZED_LOAN_TASK,
            PortalConstants.AOI_CROP => PortalConstants.AOI_TASK,
            PortalConstants.SPOUSAL_CONSENT => PortalConstants.SPOUSAL_CONSENT_TASK,
            PortalConstants.NTB_LETTER => PortalConstants.NTB_TASK,
            PortalConstants.WITHDRAWAL_FORM => PortalConstants.WITHDRAWAL_FORM_TASK,
            PortalConstants.MODIFICATION_AGREEMENT => PortalConstants.COLLATERAL_REPORT_TASK
        };
        for (String contentVersionTitle : conVersionTitleVsTaskMap.keySet()) {
            if (contentVersionObj.Title.contains(contentVersionTitle)) {
                CFAOriginationHelperClass.createDocCategoryAttachment(new Map<String,String>{
                    PortalConstants.TITLE_KEY => contentVersionObj.Title,
                    PortalConstants.CONTENT_VERSION_ID_KEY => contentVersionObj.Id,
                    PortalConstants.CONTENT_DOC_ID_KEY => event.ContentDocumentId,
                    PortalConstants.APPLICATION_ID_KEY => event.LinkedEntityId,
                    PortalConstants.NAME_KEY => conVersionTitleVsTaskMap.get(contentVersionTitle)
                });                                       
                break; 
            }
        }
    }
}