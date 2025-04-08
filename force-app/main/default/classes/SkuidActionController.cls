/**
 * @description       : This class is for all the webserice methods called from Skuid
 * @author            : Ayan Bhowmik
 * @group             : 
 * @last modified on  : 03-12-2024
 * @last modified by  : Suraj Kumar
**/

global with sharing class SkuidActionController {
    /**
    * @description : Purpose of this method is to update the fields on applications, Borrower and Principal party so that 
    *               ContentDocumentLinkTrigger will fire for Re-Sending
    *               Docusign via Email
    * @author Suraj Kumar | 03-12-2024 
    * @param applicationId 
    * @return String 
    **/

    webservice static String reSendingDocuSignWS(String applicationId){
        try {
            List<clcommon__Party__c> borrowerPrncplPartyList = new List<clcommon__party__c>();
            genesis__Applications__c applicationObj = new genesis__Applications__c();

            if(applicationId == null) {
                throw new CustomException(PortalConstants.APPL_ID_FIELD_MISSING);
            }
            applicationObj = [SELECT Signing_Method__c, 
                                        DocuSign_Credit_Agreement_Initiated__c,
                                        Stage__c,
                                        genesis__Status__c
                                    FROM genesis__Applications__c
                                    WHERE Id = :applicationId
                                    LIMIT 1];
            checkArguments(applicationObj);
            borrowerPrncplPartyList = [SELECT Id,
                                                DocuSign_Signing_Status__c
                                            FROM clcommon__Party__c
                                            WHERE genesis__Application__c = :applicationId
                                            AND (clcommon__Type__r.Name = :PortalConstants.BORROWER_PARTY_NAME
                                            OR clcommon__Type__r.Name = :PortalConstants.PRINCIPAL_PARTY_NAME)];
            
            if(borrowerPrncplPartyList.isEmpty()) {
                throw new CustomException(PortalConstants.NO_PARTY_FOUND);
            }
            applicationObj.Signing_Method__c = null;
            applicationObj.genesis__Status__c = PortalConstants.E_SIGN_PENDING_APPLICATION_STATUS;
            applicationObj.DocuSign_Credit_Agreement_Initiated__c = false;
            applicationObj.Stage__c = PortalConstants.APPLICANT_SIGNATURE;
            borrowerPrncplPartyList[0].DocuSign_Signing_Status__c = '';

            Database.update(applicationObj, true);
            Database.update(borrowerPrncplPartyList, true);
            
            applicationObj.Signing_Method__c = PortalConstants.EMAIL_DOCUSIGN;
            Database.update(applicationObj, true);
        } catch(CustomException objCustomException) {
            return objCustomException.getMessage();
        } catch(Exception objException) {
            return objException.getMessage();
        }
        return clcommon.constants.Success;
    }

    /**
    * @description : this method is used for null checks and validate the application
    * @author Suraj Kumar | 03-12-2024 
    * @param applicationObj 
    **/
    private static void checkArguments(genesis__Applications__c applicationObj){
        if(applicationObj.Signing_Method__c == null) {
            throw new CustomException(PortalConstants.SIGNING_METHOD_MISSING);
        }
        if (applicationObj.Signing_Method__c != PortalConstants.EMAIL_DOCUSIGN) {
            throw new CustomException(PortalConstants.SIGNING_METHOD_IS_NOT_EMAIL_DOCUSIGN);
        }
        if((applicationObj.genesis__Status__c == PortalConstants.REJECTED_APPLICATION_STATUS)
                | (applicationObj.genesis__Status__c == PortalConstants.EXPIRED_APPLICATION_STATUS)
                | (applicationObj.genesis__Status__c == PortalConstants.WITHDRAWN_APPLICATION_STATUS)
                | (applicationObj.genesis__Status__c == PortalConstants.PENDING_WITHDRAWAL_APPLICATION_STATUS)) {
            throw new CustomException(PortalConstants.INVALID_DOCUSIGN_EMAIL_REQUEST);
        }
    }
}