/**********************************************************************************************************************
 * @description       : This class changes ACH Debit Agreement Status to In Review
 * @author            : Pritam
 * @group             : 
 * @last modified on  : 01-12-2025
 * @last modified by  : Ayan Khanra
**********************************************************************************************************************/
global without sharing class PortalACHDebitAgreementAPI implements clcommon.PortalCustomRemoteAPI1{
    //Constants for the specific class starts
    private static final String USER_ERROR = 'No User found';
    private static final String CLASS_NAME = 'PortalACHDebitAgreementAPI';
    private static final String IN_REVIEW = 'In Review';
    private static final String DOCUMENT_NAME = 'ACH Debit Agreement';
    private static final String DOCUMENT_ID = 'documentId';
    private static final String VERSION = ' V';
    private static final String VERSION_ONE = ' V1';
    private static final String READ_OR_WRITE = 'edit';
    //Constants for the specific class ends

    /**
    * @description Checks request parameters
    * @author  Pritam Roy | 01-02-2024 
    * @param argumentsFromPortal 
    **/
    private static void checkRequestParam(Map<String, Object> argumentsFromPortal){
        if(!argumentsFromPortal.containsKey(DOCUMENT_ID)){
            throw new CustomException(PortalConstants.INVALID_PARAMS);
        }
        if(argumentsFromPortal.get(DOCUMENT_ID) == null){
            throw new CustomException(PortalConstants.DOCUMENT_ID_NULL);
        }
    }
    /**
    * @description checks list size
    * @author  Pritam Roy | 01-02-2024 
    * @param objList 
    * @param exceptionMsg 
    **/
    private static void listIsEmptyException(List<Object> objList,String exceptionMsg){
        if(objList.isEmpty()){
            throw new CustomException(exceptionMsg);
        }
    }

    /**
    * @description create Document Category Share
    * @author  Pritam Roy | 01-03-2024 
    * @param docCategoryId 
    * @param userId 
    **/
    private static void createDocumentCategoryShare(String docCategoryId,String userId){
        clcommon__Document_Category__Share objShare = new clcommon__Document_Category__Share();
        objShare.parentId = docCategoryId;
        objShare.AccessLevel = READ_OR_WRITE;
        objShare.UserOrGroupId = userId;
        Database.SaveResult srList = Database.insert(objShare, false);
    }
    /**
    * @description changes ACH debit status to trigger flow
    * @author  Pritam Roy | 11-15-2023 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                            String[] disclosureNames,
                                            Map<String, Object> argumentsFromPortal){  
        List<clcommon__Document_Category__Share> docCategoryShareList = new List<clcommon__Document_Category__Share>();
        List<clcommon__Category_Attachment_Association__c> categoryAttachmentList = new List<clcommon__Category_Attachment_Association__c>();
        List<clcommon__Document_Category__c> documentCatergoryList = new List<clcommon__Document_Category__c>();
        clcommon__Category_Attachment_Association__c objAssociation;
        clcommon__Document_Category__c objDocumentCategory;
        clcommon.Response response = new clcommon.Response();
        List<Account> dealerAccList = new List<Account>();
        List<User> userList = new List<User>();
        List<ContentDocumentLink> contentDocumentLinkList;
        String dealerId = '';
        String documentId = '';
        SavePoint dbSavePoint = Database.setSavepoint();

        try{
            userList = PortalLoanServicingHelper.getLoggedInUser();
            if(userList.isEmpty()){
                throw new CustomException(USER_ERROR);
            }
            dealerAccList = [SELECT Id, 
                                    ACH_Debit_Agreement_Comments__c, 
                                    ACH_Debit_Agreement_Status__c 
                            FROM Account 
                            WHERE Id =: userList[0].Account.ParentId];
            dealerId = String.valueOf(userList[0].Account.ParentId);
            checkRequestParam(argumentsFromPortal);
            documentId = String.valueOf(argumentsFromPortal.get(DOCUMENT_ID));
            contentDocumentLinkList = [SELECT Id,
                                            ContentDocumentId 
                                        FROM ContentDocumentLink 
                                        WHERE Id =: documentId];
            listIsEmptyException(contentDocumentLinkList,PortalConstants.CONTENT_DOC_LINK_EXP);
            documentCatergoryList = [SELECT Id,
                                            Name,
                                            Attachment_Count__c 
                                        FROM clcommon__Document_Category__c 
                                        WHERE clcommon__Account__c =: dealerId
                                        AND clcommon__Category_Name__c =: DOCUMENT_NAME];
            if(documentCatergoryList.isEmpty()){
                objDocumentCategory = new clcommon__Document_Category__c();
                objDocumentCategory.clcommon__Account__c = dealerId;
                objDocumentCategory.clcommon__Active__c = true;
                objDocumentCategory.clcommon__Category_Name__c = DOCUMENT_NAME;
                objDocumentCategory.OwnerId = userList[0].id;
                Database.insert(objDocumentCategory,true);

                objAssociation = new clcommon__Category_Attachment_Association__c();
                objAssociation.Name = DOCUMENT_NAME + VERSION_ONE;
                objAssociation.clcommon__Content_Document_Id__c = String.valueOf(contentDocumentLinkList[0].ContentDocumentId);
                objAssociation.Account__c = userList[0].Account.ParentId;
                objAssociation.clcommon__Document_Category__c = objDocumentCategory.Id;
                Database.insert(objAssociation, true);
                createDocumentCategoryShare(objDocumentCategory.Id,userList[0].id);

            }else{
                categoryAttachmentList = [SELECT Id 
                                            FROM 
                                        clcommon__Category_Attachment_Association__c WHERE
                                        clcommon__Document_Category__r.clcommon__Category_Name__c = : 'ACH Debit Agreement'  
                                        AND Account__c =: dealerId];
                listIsEmptyException(categoryAttachmentList,PortalConstants.CATEGORY_ATTACHMENT_EXP);
                docCategoryShareList = [SELECT Id 
                                                FROM 
                                            clcommon__Document_Category__Share 
                                            WHERE parentId =: documentCatergoryList[0].id 
                                            AND UserOrGroupId =:  userList[0].id];
                if(docCategoryShareList.isEmpty()){
                    createDocumentCategoryShare(documentCatergoryList[0].id,userList[0].id);
                }
                objAssociation = new clcommon__Category_Attachment_Association__c();
                objAssociation.Name = DOCUMENT_NAME + VERSION + String.valueOf(categoryAttachmentList.size() + 1);
                objAssociation.clcommon__Content_Document_Id__c = String.valueOf(contentDocumentLinkList[0].ContentDocumentId);
                objAssociation.clcommon__Document_Category__c = documentCatergoryList[0].Id;
                objAssociation.Account__c = dealerId;
                Database.insert(objAssociation, true);
            }
            dealerAccList[0].ACH_Debit_Agreement_Status__c = IN_REVIEW;
            dealerAccList[0].ACH_Debit_Agreement_Comments__c = '';
            Database.update(dealerAccList,true);
            response.status = clcommon.Constants.SUCCESS;  

        }catch(Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response;
    }
}