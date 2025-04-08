/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 06-28-2024
 * @last modified by  : Suraj Kumar
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   03-08-2023   Subham Nandi   Initial Version
**/
public with sharing class CreateApplicationSharingRecordHandler {

    /**
    * @description Creating Application Sharing Record for all relationsip of a dealer.
    * @author Ayan Bhowmik | 02-27-2024 
    * @param applicationId 
    * @param accountId 
    **/
    public static void handler(String applicationId, String accountId) {
        String delaerAccountId = [SELECT Dealer_Name__c 
                                    FROM genesis__Applications__c 
                                    WHERE Id = :applicationId ].Dealer_Name__c;
        If(!String.isBlank(delaerAccountId)){
            List<String> relationIdList = new List<String>();
            List<genesis__Applications__Share> applicationSharingRecords = new List<genesis__Applications__Share>();
            List<clcommon__Document_Category__Share> documentSharingRecords = new List<clcommon__Document_Category__Share>();
            List<AccountShare> accountListShare = new List<AccountShare>();
            List<clcommon__Relationship__c> dealerRelations = [SELECT Id, 
                                                                clcommon__Entity__c,
                                                                clcommon__Related_Entity__c, 
                                                                clcommon__Relationship__r.Name
                                                        FROM clcommon__Relationship__c
                                                        WHERE clcommon__Entity__c = :delaerAccountId
                                                        AND clcommon__Relationship__r.Name IN (
                                                                :PortalConstants.CERTIFIED_LENDER, 
                                                                :PortalConstants.CERTIFIED_LENDER_PLUS,
                                                                :PortalConstants.INQUIRY,
                                                                :PortalConstants.INQUIRY_PLUS,
                                                                :PortalConstants.FIELD_STAFF_AGENT
                                                            )];
            for (clcommon__Relationship__c relation : dealerRelations) {
                // getting all the certified lenders account id in a list  
                relationIdList.add(relation.clcommon__Related_Entity__c);
            }
            //Query the CL, inquiry Users related to the dealer
            List<User> clUsers = [SELECT Id,
                                        Account.RecordType.Name 
                                    FROM User 
                                    WHERE AccountId IN :relationIdList];
            //Query the Document category of the application
            List<clcommon__Document_Category__c> documentCategories = [SELECT Id, OwnerId 
                                                                        FROM clcommon__Document_Category__c 
                                                                        WHERE genesis__Application__c = :applicationId];
            CreateApplicationSharingRecordHandler.changeOwner(documentCategories);
            //Database.update(documentCategories,true);
            for (User clUser : clUsers) {
                //
                AccountShare eachAccountShare = new AccountShare();
                eachAccountShare.AccountId = accountId;
                eachAccountShare.UserOrGroupId = clUser.Id;
                eachAccountShare.AccountAccessLevel = ConstantValues.ACCESS_LABEL_EDIT;
                eachAccountShare.OpportunityAccessLevel = ConstantValues.ACCESS_LABEL_READ;
                eachAccountShare.CaseAccessLevel = ConstantValues.ACCESS_LABEL_READ;
                accountListShare.add(eachAccountShare);
                //
                genesis__Applications__Share applicationSharingRecord = new genesis__Applications__Share();
                applicationSharingRecord.AccessLevel = ConstantValues.ACCESS_LABEL_EDIT;
                applicationSharingRecord.ParentId = applicationId;
                applicationSharingRecord.UserOrGroupId = clUser.Id;
                applicationSharingRecords.add(applicationSharingRecord);
                //Create Document Sharing Records
                documentSharingRecords = CreateApplicationSharingRecordHandler.getAllDocumentSharing(documentCategories,clUser, documentSharingRecords);
            }
            Database.upsert(applicationSharingRecords, true);
            Database.upsert(documentSharingRecords, true);
            Database.upsert(accountListShare,false);
        }                            
    }

    /**
    * @description Creating List of all document sharing record.
    * @author Ayan Bhowmik | 02-27-2024 
    * @param documentCategories 
    * @param clUser 
    * @param documentSharingRecords
    * @return List<clcommon__Document_Category__Share> 
    **/
    private static List<clcommon__Document_Category__Share> getAllDocumentSharing(List<clcommon__Document_Category__c> documentCategories, 
                                                                            User clUser, List<clcommon__Document_Category__Share> documentSharingRecords){
        // List<clcommon__Document_Category__Share> documentSharingRecords = new List<clcommon__Document_Category__Share>();                                                                        
        for (clcommon__Document_Category__c documentCategory : documentCategories) {
            clcommon__Document_Category__Share documentSharingRecord = new clcommon__Document_Category__Share();
            documentSharingRecord.AccessLevel = ConstantValues.ACCESS_LABEL_EDIT;
            documentSharingRecord.ParentId = documentCategory.Id;
            documentSharingRecord.UserOrGroupId = clUser.Id;
            documentSharingRecords.add(documentSharingRecord);
        }
        return documentSharingRecords;
    }

    /**
    * @description Changing the owner of all document categories
    * @author Ayan Bhowmik | 02-27-2024 
    * @param documentCategories 
    **/
    private static void changeOwner(List<clcommon__Document_Category__c> documentCategories){
        User objUser = [SELECT Id FROM User WHERE Profile.Name = :ConstantValues.PROFILE_ADMIN AND IsActive = true AND Name = :ConstantValues.ADMIN_ADMIN_USER_NAME];
        for(clcommon__Document_Category__c eachDoc : documentCategories){
            eachDoc.OwnerID = objUser.Id;
        }
        Database.update(documentCategories,true);
    }
}