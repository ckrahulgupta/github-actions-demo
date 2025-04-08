/**
 * @description       : Handler classes for ExternalSaveSigningMethodAPI
 * @author            : Suraj Kumar | 05-29-2024
 * @group             : 
 * @last modified on  : 03-01-2025
 * @last modified by  : Krishanu Chinya
**/
public inherited sharing class ExternalSaveSigningMethodHandler {
    
    /**
    * @description : If there is existing document present then need to delete that first and then procees with signing method
    * @author Suraj Kumar | 05-29-2024 
    * @param applicationObj 
    * @param applicantPartyList
    **/
    private static void deleteExistingDocument(genesis__Applications__c applicationObj, List<clcommon__Party__c> applicantPartyList){
        List<String> contentDocumentIdList = new List<String>();

        if (applicationObj.Signing_Method__c!= null && applicationObj.Agreement_Sign__c == false) {
            List<clcommon__document_category__c> docCategoryList = [SELECT Id 
                                                                        FROM clcommon__document_category__c 
                                                                        WHERE genesis__Application__c =: applicationObj.Id 
                                                                        AND clcommon__Category_Name__c =: ExternalConstants.SIGNING_TASK];
            ExternalApplicationOriginationUtil.checkEmptyList(docCategoryList,ExternalConstants.DOC_CATEGORY_MISSING);

            List<clcommon__Category_Attachment_Association__c> docAttachmentList = [SELECT Id, 
                                                                                            Name, 
                                                                                            clcommon__Document_Category__c, 
                                                                                            clcommon__Content_Document_Id__c 
                                                                                        FROM clcommon__Category_Attachment_Association__c 
                                                                                        WHERE clcommon__Document_Category__c = :docCategoryList[0].Id];
            
            for (clcommon__Category_Attachment_Association__c docAttachmentObj : docAttachmentList) {
                contentDocumentIdList.add(docAttachmentObj.clcommon__Content_Document_Id__c);
            }

            for (clcommon__party__c applicantPartyObj : applicantPartyList) {
                if (applicantPartyObj.DocuSign_URL__c != null) {
                    applicantPartyObj.DocuSign_URL__c = null;
                    applicantPartyObj.Sent_Url__c = false;
                    applicantPartyObj.DocuSign_Generation_Time__c = null;
                }
            }

            applicationObj.Signing_Method__c = null;

            Database.update(applicantPartyList,true);
            Database.delete(docAttachmentList,true);

            if (!contentDocumentIdList.isEmpty()) {
                List<ContentDocumentLink> contentDocumentLinkList = [SELECT Id, 
                                                                            LinkedEntityId, 
                                                                            ContentDocumentId 
                                                                        FROM ContentDocumentLink 
                                                                        WHERE LinkedEntityId = :applicationObj.Id
                                                                        AND ContentDocumentId IN :contentDocumentIdList];

                List<ContentDocument> contentDocumentList = [SELECT Id 
                                                                    FROM ContentDocument 
                                                                    WHERE Id IN :contentDocumentIdList];

                Database.delete(contentDocumentLinkList,true);
                Database.delete(contentDocumentList,true);
            }
            Database.update(applicationObj,true);
        }
    }

    /**
    * @description : Method to save the signing method 
    * @author Suraj Kumar | 10-08-2024 
    * @param applicationObj 
    * @param signingMethod 
    * @param applicantPartyList
    **/
    public static void handleSaveSigningMethod(genesis__Applications__c applicationObj, String signingMethod, List<clcommon__Party__c> applicantPartyList){
        deleteExistingDocument(applicationObj,applicantPartyList);

        updateKYC(applicantPartyList);

        //Query the task for Signing
        List<Task> signedAgreementTaskList = [SELECT Id, 
                                                        Subject,
                                                        Status
                                                    FROM Task
                                                    WHERE Subject = :ExternalConstants.SIGNING_TASK 
                                                    AND genesis__Application__c = :applicationObj.Id];
        ExternalApplicationOriginationUtil.checkEmptyList(signedAgreementTaskList,ExternalConstants.UNEXPECTED_ERROR);
        signedAgreementTaskList[0].Status = ExternalConstants.OPEN_TASK_STATUS;
        Database.update(signedAgreementTaskList,true);

        applicationObj.Signing_Method__c = signingMethod;
        applicationObj.genesis__Status__c = ExternalConstants.E_SIGN_PENDING_APPLICATION_STATUS;
        applicationObj.DocuSign_Credit_Agreement_Initiated__c = false;
        Database.update(applicationObj,true);
    }

    /**
    * @description : Method to perform resend Docusign
    * @author Suraj Kumar | 10-09-2024 
    * @param applicationObj 
    * @param signingMethod 
    * @param applicantPartyList
    **/
    public static void handleResendDocusign(genesis__Applications__c applicationObj, String signingMethod, List<clcommon__Party__c> applicantPartyList){
        for (clcommon__Party__c applicantPartyObj: applicantPartyList) {
            applicantPartyObj.DocuSign_Signing_Status__c = ExternalConstants.EMPTY_STRING;
            applicantPartyObj.Sent_Url__c = false;
            applicantPartyObj.DocuSign_URL__c = null;
            applicantPartyObj.DocuSign_Generation_Time__c = null;
        }
        Database.update(applicantPartyList,true);
        
        applicationObj.Signing_Method__c = null;
        applicationObj.Stage__c = ExternalConstants.APPLICANT_SIGNATURE;
        applicationObj.DocuSign_Credit_Agreement_Initiated__c = false;
        applicationObj.genesis__Status__c = ExternalConstants.E_SIGN_PENDING_APPLICATION_STATUS;
        applicationObj.Agreement_Sign__c = false;
        Database.update(applicationObj,true);
        
        applicationObj.Signing_Method__c = signingMethod;
        applicationObj.Resend_Docusign__c = true;
        Database.update(applicationObj,true);
    }

    /**
    * @description : update the KYC flag on the applicants account
    * @author Krishanu Chinya | 03-01-2025 
    * @param partyList 
    **/
    private static void updateKYC(List<clcommon__Party__c> partyList) {

        List<Account> applicantAccountList = new List<Account>();
        for(clcommon__Party__c partyObj : partyList) {
            Account accountObj=new Account(Id=partyObj.clcommon__Account__c);
            accountObj.Kyc_Verified__c= true;
            applicantAccountList.add(accountObj);
        }
        Database.update(applicantAccountList, true);
    }
}