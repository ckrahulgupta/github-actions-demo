/**
 * @description       : This is the Test Class for ContentDocumentLinkTrigger Trigger
 * @author            : simranjha
 * created Date       : 06-04-2022
 * @group             : 
 * @last modified on  : 10-23-2024
 * @last modified by  : Suraj Kumar
**/

@isTest
public with sharing class ContentDocumentLinkTriggerTest {
    @testSetup
    static void setup(){
        clcommon__Legal_Entity__c clEntity= ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(clEntity, true);
        
        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj,true);

        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        Database.insert(clUserObj, true);

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);

        // Creating Account for Borrower
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, ApplicationOriginationTestHelper.createBusinessInfoForBorrower().Id);
        Database.insert(borrowerAccountObj, true);

        // Creating Contact for Borrower
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(borrowerContactObj,true);

        // Creating User for Borrower
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(borrowerUserObj, true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating map for Application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>();
        paramForApplicationMap.put('dealerAccountId', dealerAccountObj.Id);
        paramForApplicationMap.put('clProductId', clProductObj.Id);
        paramForApplicationMap.put('clPurposeId', clPurposeObj.Id);
        paramForApplicationMap.put('borrowerAccountId', borrowerAccountObj.Id);
        paramForApplicationMap.put('borrowerContactId', borrowerContactObj.Id);
        paramForApplicationMap.put('clAccountId', clAccountObj.Id);

        // Creating Application
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        applicationObj.DocuSign_Credit_Agreement_Initiated__c = false;
        Database.insert(applicationObj, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,clAccountObj.Id,borrowerAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        // Creating Certified Lender Party Type
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(clPartyTypeObj, true);

        // Creating Certified Lender Party
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>();
        paramForCLPartyMap.put('accountId', clAccountObj.Id);
        paramForCLPartyMap.put('contactId', clContactObj.Id);
        paramForCLPartyMap.put('partyTypeId', clPartyTypeObj.Id);
        paramForCLPartyMap.put('applicationId', applicationObj.Id);
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(paramForCLPartyMap);
        Database.insert(clPartyObj, true);

        // Create Borrower Party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(borrowerPartyTypeObj, true);

        // Creating Borrower Party
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>();
        paramForBorrowerPartyMap.put('accountId', borrowerAccountObj.Id);
        paramForBorrowerPartyMap.put('contactId', borrowerContactObj.Id);
        paramForBorrowerPartyMap.put('partyTypeId', borrowerPartyTypeObj.Id);
        paramForBorrowerPartyMap.put('applicationId', applicationObj.Id);
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(paramForBorrowerPartyMap);
        Database.insert(borrowerPartyObj);
        testSetupContentdocument(applicationObj.id,borrowerAccountObj.Id);
        testSetUpDocCategory(applicationObj.id);
    } 
    
    /**
    * @description : Method to create contet document for test setup
    * @author Simran | 06-13-2024 
    * @param applicationId 
    * @param borrowerId 
    **/
    private static void testSetupContentdocument(String applicationId, String borrowerId){
        ContentVersion contentVersionSpousalObj = ApplicationOriginationTestHelper.createContentVersion(PortalConstants.SPOUSAL_CONSENT_TASK);
        Database.insert(contentVersionSpousalObj,true);
    
            // creating content Document
        ContentDocument contentDocSpousalObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.SPOUSAL_CONSENT_TASK LIMIT 1];

        // creating ContentDocumentLink
        ContentDocumentLink contentDocLinkSpousalObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocSpousalObj.id,applicationId);
        Database.insert(contentDocLinkSpousalObj,true);
        //creating content version
        ContentVersion contentVerAgreementObj = ApplicationOriginationTestHelper.createContentVersion(PortalConstants.AGREEMENT_FILE_NAME);
        Database.insert(contentVerAgreementObj,true);
 
        // creating content Document
        ContentDocument contentDocAgreementObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
 
        // creating ContentDocumentLink
        ContentDocumentLink contentDocLinkAgrmttObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocAgreementObj.id,applicationId);
        Database.insert(contentDocLinkAgrmttObj,true);
        ContentVersion contentVersionLoanObj = ApplicationOriginationTestHelper.createContentVersion(PortalConstants.LOAN_COMMITMENT_LETTER_FILE_NAME);
        Database.insert(contentVersionLoanObj,true);
    
        // creating content Document
        ContentDocument contentDocLoanObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.LOAN_COMMITMENT_LETTER_FILE_NAME LIMIT 1];

        // creating ContentDocumentLink
        ContentDocumentLink contentDocLinkLoanObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocLoanObj.id,applicationId);
        Database.insert(contentDocLinkLoanObj,true);
        //creating content version
        ContentVersion contentVersionModiObj = ApplicationOriginationTestHelper.createContentVersion(PortalConstants.MODIFICATION_AGREEMENT);
        Database.insert(contentVersionModiObj,true);

        // creating content Document
        ContentDocument contentDocModiObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.MODIFICATION_AGREEMENT LIMIT 1];

        // creating ContentDocumentLink
        ContentDocumentLink contentDocLinkModiObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocModiObj.id,applicationId);
        Database.insert(contentDocLinkModiObj,true);
        ContentVersion contentVersionLienObj = ApplicationOriginationTestHelper.createContentVersion(PortalConstants.LIEN_SUBORDINATE);
        Database.insert(contentVersionLienObj,true);
    
        // creating content Document
        ContentDocument contentDocLienObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.LIEN_SUBORDINATE LIMIT 1];

        // creating ContentDocumentLink
        ContentDocumentLink contentDocLienLinkObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocLienObj.id,applicationId);
        Database.insert(contentDocLienLinkObj,true);
        //creating content version
        ContentVersion contentVersionCustObj = ApplicationOriginationTestHelper.createContentVersion(PortalConstants.CUSTOMIZED_LOAN_TASK);
        Database.insert(contentVersionCustObj,true);

        // creating content Document
        ContentDocument contentDocCustObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.CUSTOMIZED_LOAN_TASK LIMIT 1];

        // creating ContentDocumentLink
        ContentDocumentLink contentDocLinkCustObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocCustObj.id,applicationId);
        Database.insert(contentDocLinkCustObj,true);
        //creating content version
        ContentVersion contentVersionAOIObj = ApplicationOriginationTestHelper.createContentVersion(PortalConstants.AOI_CROP);
        Database.insert(contentVersionAOIObj,true);

        // creating content Document
        ContentDocument contentDocAOIObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.AOI_CROP LIMIT 1];

        // creating ContentDocumentLink
        ContentDocumentLink contentDocLinkAOIObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocAOIObj.id,applicationId);
        Database.insert(contentDocLinkAOIObj,true);
        //creating content version
        ContentVersion contentVersionNTBObj = ApplicationOriginationTestHelper.createContentVersion(PortalConstants.NTB_LETTER);
        Database.insert(contentVersionNTBObj,true);

        // creating content Document
        ContentDocument contentDocNTBObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.NTB_LETTER LIMIT 1];

        // creating ContentDocumentLink
        ContentDocumentLink contentDocLinkNTBObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocNTBObj.id,applicationId);
        Database.insert(contentDocLinkNTBObj,true);
        //creating content version
        ContentVersion contentVerWithdrawlObj = ApplicationOriginationTestHelper.createContentVersion(PortalConstants.WITHDRAWAL_FORM);
        Database.insert(contentVerWithdrawlObj,true);

        // creating content Document
        ContentDocument contentDocWithdrawObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.WITHDRAWAL_FORM LIMIT 1];

        // creating ContentDocumentLink
        ContentDocumentLink contentDocLinkWithdrawl = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocWithdrawObj.id,applicationId);
        Database.insert(contentDocLinkWithdrawl,true);
        
        ContentVersion contentObj= ApplicationOriginationTestHelper.createContentVersion();
        contentObj.Title='Jasmine Albin Summary.pdf';
        contentObj.PathOnClient='/'+contentObj.Title+'.pdf';
        Database.insert(contentObj,true);
        List<ContentDocument> contentDocumentsObj = [SELECT Id 
                                                    FROM ContentDocument 
                                                    WHERE Title = 'Jasmine Albin Summary.pdf' 
                                                    LIMIT 1];
        ContentDocumentLink conDocLinkObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocumentsObj[0].Id, borrowerId);
        Database.insert(conDocLinkObj,true);

    }

    /**
    * @description : Method to create document category for test setup
    * @author Simran | 06-12-2024 
    * @param appId 
    **/
    private static void  testSetUpDocCategory(String appId){
        clcommon__document_category__c docCategorySigned = ApplicationOriginationTestHelper.createDocCategory(appId,PortalConstants.SIGNED_AGREEMENT_TASK);
        Database.insert(docCategorySigned,true);

        clcommon__document_category__c docCategoryLoanCommitment = ApplicationOriginationTestHelper.createDocCategory(appId,PortalConstants.LOAN_COMMITMENT_LETTER);
        Database.insert(docCategoryLoanCommitment,true);

        clcommon__document_category__c docCategoryLien = ApplicationOriginationTestHelper.createDocCategory(appId,PortalConstants.LIEN_SUBORDINATION_TASK);
        Database.insert(docCategoryLien,true);

        clcommon__document_category__c docCategoryCustomizedLoan = ApplicationOriginationTestHelper.createDocCategory(appId,PortalConstants.CUSTOMIZED_LOAN_TASK);
        Database.insert(docCategoryCustomizedLoan,true);

        clcommon__document_category__c docCategoryAOI = ApplicationOriginationTestHelper.createDocCategory(appId,PortalConstants.AOI_TASK);
        Database.insert(docCategoryAOI,true);

        clcommon__document_category__c docCategorySpousalConsent = ApplicationOriginationTestHelper.createDocCategory(appId,PortalConstants.SPOUSAL_CONSENT_TASK);
        Database.insert(docCategorySpousalConsent,true);

        clcommon__document_category__c docCategoryNTBTask = ApplicationOriginationTestHelper.createDocCategory(appId,PortalConstants.NTB_TASK);
        Database.insert(docCategoryNTBTask,true);

        clcommon__document_category__c docCategoryWithdrawal = ApplicationOriginationTestHelper.createDocCategory(appId,PortalConstants.WITHDRAWAL_FORM_TASK);
        Database.insert(docCategoryWithdrawal,true);

        clcommon__document_category__c docCategoryCollateral = ApplicationOriginationTestHelper.createDocCategory(appId,PortalConstants.COLLATERAL_REPORT_TASK);
        Database.insert(docCategoryCollateral,true);   
    }
    /**
    * @description : Method to create the credit agreement document
    * @author Suraj Kumar | 10-23-2024 
    * @param applicationId 
    **/
    private static void testSetUpCreditAgreementDoc(String applicationId){
        ContentVersion contentVerAgreementObj = ApplicationOriginationTestHelper.createContentVersion(PortalConstants.AGREEMENT_FILE_NAME);
        Database.insert(contentVerAgreementObj,true);
        ContentDocument contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME ORDER BY CreatedDate DESC LIMIT 1];
        ContentDocumentLink contentDocLinkAgrmttObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocumentObj.id,applicationId);
        Database.Insert(contentDocLinkAgrmttObj,true);
    }
    /**
    * @description : Testing the success scenario of credit application agreement document
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  successCreditApplicationAgreement() {
       
        User userObj = [SELECT Id
                        FROM USER 
                        WHERE Id = :UserInfo.getUserId() 
                        LIMIT 1];
        System.runAs(userObj){  
        genesis__Applications__c applicationObj = [SELECT Id,
                                                                Signing_Method__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        
        applicationObj.DocuSign_Credit_Agreement_Initiated__c=false;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        Database.update(applicationObj,true);
        ContentDocument contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(applicationObj.Id, contentDocumentLinkObj[0].LinkedEntityId,'Success');
        Test.stopTest();
        }
            
    }
    /**
    * @description : Testing the failure scenario of credit application agreement document
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  failureCreditApplicationAgreement() {
       
        User userObj = [SELECT Id
                        FROM USER 
                        WHERE Id = :UserInfo.getUserId() 
                        LIMIT 1];
        System.runAs(userObj){  
        genesis__Applications__c applicationObj = [SELECT Id,
                                                                Signing_Method__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        
        applicationObj.DocuSign_Credit_Agreement_Initiated__c=false;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        Database.update(applicationObj,true);
        ContentDocument contentDocumentObj = [SELECT Id,Title FROM ContentDocument WHERE Title != :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(true, contentDocumentObj.Title !=PortalConstants.AGREEMENT_FILE_NAME,'Success');
        Test.stopTest();
        }
            
    }

    /**
    * @description : Testing the success scenario of spousal consent
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  successSpousalConsent() {
        User userObj = [SELECT Id
                FROM USER 
                WHERE Id = :UserInfo.getUserId() 
                LIMIT 1];
        System.runAs(userObj){  
        genesis__Applications__c applicationObj = [SELECT Id,
                                                                Signing_Method__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.SPOUSAL_CONSENT_TASK LIMIT 1];
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(applicationObj.Id, contentDocumentLinkObj[0].LinkedEntityId,'Success');
        Test.stopTest();
        }
    }

    /**
    * @description : Testing the failure scenario of spousal consent
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  failureSpousalConsent() {
        User userObj = [SELECT Id
                FROM USER 
                WHERE Id = :UserInfo.getUserId() 
                LIMIT 1];
        System.runAs(userObj){  
        genesis__Applications__c applicationObj = [SELECT Id,
                                                                Signing_Method__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id,Title FROM ContentDocument WHERE Title != :PortalConstants.SPOUSAL_CONSENT_TASK LIMIT 1];
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(true, contentDocumentObj.Title !=PortalConstants.SPOUSAL_CONSENT_TASK,'Success');
        Test.stopTest();
        }
    }

    /**
    * @description : Testing for a document, which is not linked with any application
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  checkNullApplication() {
        User userObj = [SELECT Id
                        FROM USER 
                        WHERE Id = :UserInfo.getUserId() 
                        LIMIT 1];
        System.runAs(userObj){  
        Account borrowerAccount=[SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title = 'Jasmine Albin Summary.pdf' LIMIT 1];
        
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:borrowerAccount.Id AND ContentDocumentId=:contentDocumentObj.ID LIMIT 1];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(borrowerAccount.Id, contentDocumentLinkObj[0].LinkedEntityId,'Success');
        Test.stopTest();
        }     
    }
    /**
    * @description : Testing the user access for a document
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  testUserAccess() {
        genesis__Applications__c applicationObj = [SELECT Id,genesis__Contact__c
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE ContactId = :applicationObj.genesis__Contact__c 
                            LIMIT 1];
        System.runAs(userObj){  
        List<ContentDocument> contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.LOAN_COMMITMENT_LETTER_FILE_NAME LIMIT 1];
        Test.startTest();
        if(contentDocumentObj.size()<=0){
            System.assertEquals(true, contentDocumentObj.size()<=0,'Insufficient Access');
        }
        else{
            List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj[0].ID LIMIT 1];
            ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
            System.assertEquals(applicationObj.Id, contentDocumentLinkObj[0].LinkedEntityId,'Success');

        }
        Test.stopTest();
        }     
    }

    /**
    * @description : Testing the success scenario of loan commitment letter
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  successLoanCommitment() {
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        System.runAs(userObj){        
        genesis__Applications__c applicationObj = [SELECT Id,
                                                                Signing_Method__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.LOAN_COMMITMENT_LETTER_FILE_NAME LIMIT 1];
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(applicationObj.Id, contentDocumentLinkObj[0].LinkedEntityId,'Success');
        Test.stopTest();
        }

    }

    /**
    * @description : Testing the failure scenario of loan commitment letter
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  failureLoanCommitment() {
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        System.runAs(userObj){        
        genesis__Applications__c applicationObj = [SELECT Id,
                                                                Signing_Method__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id,Title FROM ContentDocument WHERE Title != :PortalConstants.LOAN_COMMITMENT_LETTER_FILE_NAME LIMIT 1];
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(true, contentDocumentObj.Title !=PortalConstants.LOAN_COMMITMENT_LETTER_FILE_NAME,'Success');
        Test.stopTest();
        }

    }

    /**
    * @description : Testing the success scenario of Lien Subordinate
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  successLienSubordination() {
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        System.runAs(userObj){                       
        genesis__Applications__c applicationObj = [SELECT Id,
                                                                Signing_Method__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        
        ContentDocument contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.LIEN_SUBORDINATE LIMIT 1];
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(applicationObj.Id, contentDocumentLinkObj[0].LinkedEntityId,'Success');
        Test.stopTest();
        }
    }

    /**
    * @description : Testing the failure scenario of Lien Subordinate
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  failureLienSubordination() {
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        System.runAs(userObj){                       
        genesis__Applications__c applicationObj = [SELECT Id,
                                                                Signing_Method__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        
        ContentDocument contentDocumentObj = [SELECT Id,Title FROM ContentDocument WHERE Title != :PortalConstants.LIEN_SUBORDINATE LIMIT 1];
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(true, contentDocumentObj.Title !=PortalConstants.LIEN_SUBORDINATE ,'Success');
        Test.stopTest();
        }
    }

    /**
    * @description : Testing the success scenario of customized loan task
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  successCustomizedLoanTask() {
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        System.runAs(userObj){     
        genesis__Applications__c applicationObj = [SELECT Id,
                                                                Signing_Method__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id,title FROM ContentDocument WHERE Title = :PortalConstants.CUSTOMIZED_LOAN_TASK LIMIT 1];
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(applicationObj.Id, contentDocumentLinkObj[0].LinkedEntityId,'Success');
        Test.stopTest();
        }
    }

    /**
    * @description : Testing the failure scenario of customized loan task
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  failureCustomizedLoanTask() {
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        System.runAs(userObj){     
        genesis__Applications__c applicationObj = [SELECT Id,
                                                                Signing_Method__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id,Title FROM ContentDocument WHERE Title != :PortalConstants.CUSTOMIZED_LOAN_TASK LIMIT 1];
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(true, contentDocumentObj.Title!=PortalConstants.CUSTOMIZED_LOAN_TASK,'Success');
        Test.stopTest();
        }
    }

    /**
    * @description : Testing the success scenario of AOI crop
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  successAOICrop() {
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        System.runAs(userObj){     
        genesis__Applications__c applicationObj = [SELECT Id,
                                                                Signing_Method__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        
        ContentDocument contentDocumentObj = [SELECT Id,Title FROM ContentDocument WHERE Title = :PortalConstants.AOI_CROP LIMIT 1];
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(applicationObj.Id, contentDocumentLinkObj[0].LinkedEntityId,'Success');
        Test.stopTest();
        }
    }

    /**
    * @description : Testing the failure scenario of AOI crop
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  failureAOICrop() {
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        System.runAs(userObj){     
        genesis__Applications__c applicationObj = [SELECT Id,
                                                                Signing_Method__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        
        ContentDocument contentDocumentObj = [SELECT Id,Title FROM ContentDocument WHERE Title != :PortalConstants.AOI_CROP LIMIT 1];
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(true, contentDocumentObj.Title !=PortalConstants.AOI_CROP ,'Success');
        Test.stopTest();
        }
    }

    /**
    * @description : Testing the success scenario of NTB letter
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  successNTBLetter() {
        User userObj = [SELECT Id
                        FROM USER 
                        WHERE Id = :UserInfo.getUserId() 
                        LIMIT 1];
        System.runAs(userObj){     
        genesis__Applications__c applicationObj = [SELECT Id,
                                                        Signing_Method__c 
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.NTB_LETTER LIMIT 1];
        
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(applicationObj.Id, contentDocumentLinkObj[0].LinkedEntityId,'Success');
        Test.stopTest();
        }
    }

    /**
    * @description : Testing the failure scenario of NTB letter
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  failureNTBLetter() {
        User userObj = [SELECT Id
                        FROM USER 
                        WHERE Id = :UserInfo.getUserId() 
                        LIMIT 1];
        System.runAs(userObj){     
        genesis__Applications__c applicationObj = [SELECT Id,
                                                        Signing_Method__c 
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id,Title FROM ContentDocument WHERE Title != :PortalConstants.NTB_LETTER LIMIT 1];
        
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(true, contentDocumentObj.Title !=PortalConstants.NTB_LETTER,'Success');
        Test.stopTest();
        }
    }

    /**
    * @description : Testing the success scenario of withdrawl form
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  successWithdrawalForm() {
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        System.runAs(userObj){     
        genesis__Applications__c applicationObj = [SELECT Id,
                                                                Signing_Method__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.WITHDRAWAL_FORM LIMIT 1];
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(applicationObj.Id, contentDocumentLinkObj[0].LinkedEntityId,'Success');
        Test.stopTest();
        }
    }

    /**
    * @description : Testing the failure scenario of withdrawl form
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  failureWithdrawalForm() {
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        System.runAs(userObj){     
        genesis__Applications__c applicationObj = [SELECT Id,
                                                                Signing_Method__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id,Title FROM ContentDocument WHERE Title != :PortalConstants.WITHDRAWAL_FORM LIMIT 1];
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(true, contentDocumentObj.Title !=PortalConstants.WITHDRAWAL_FORM ,'Success');
        Test.stopTest();
        }
    }

    /**
    * @description : Testing the success scenario of modification agreement
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  successModificationAgreement() {
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        System.runAs(userObj){     
        genesis__Applications__c applicationObj = [SELECT Id,
                                                        Signing_Method__c 
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.MODIFICATION_AGREEMENT LIMIT 1];
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(applicationObj.Id, contentDocumentLinkObj[0].LinkedEntityId,'Success');
        Test.stopTest();
        }
    }

    /**
    * @description : Testing the failure scenario of modification agreement
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void  failureModificationAgreement() {
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        System.runAs(userObj){     
        genesis__Applications__c applicationObj = [SELECT Id,
                                                        Signing_Method__c 
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id,Title FROM ContentDocument WHERE Title != :PortalConstants.MODIFICATION_AGREEMENT LIMIT 1];
        List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID];
        Test.startTest();
        ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
        System.assertEquals(true, contentDocumentObj.Title !=PortalConstants.MODIFICATION_AGREEMENT ,'Success');
        Test.stopTest();
        }
    }

    /**
    * @description : Method to test resend Docusign hybrid 
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void testResendDocusignHybrid() {
        User userObj = [SELECT Id
                        FROM USER 
                        WHERE Id = :UserInfo.getUserId() 
                        LIMIT 1];
        System.runAs(userObj){  
            genesis__Applications__c applicationObj = [SELECT Id,
                                                                    Signing_Method__c,
                                                                    Resend_Docusign__c
                                                                    FROM genesis__Applications__c 
                                                                    WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
            
            applicationObj.DocuSign_Credit_Agreement_Initiated__c=false;
            applicationObj.Signing_Method__c = ConstantValues.IN_PERSON_HYBRID;
            applicationObj.Resend_Docusign__c = true;
            Database.update(applicationObj,true);

            //creating another document for this scenario
            testSetUpCreditAgreementDoc(applicationObj.Id);

            List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocument.Title=:PortalConstants.AGREEMENT_FILE_NAME];
            Test.startTest();
            ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
            System.assertEquals(applicationObj.Id, contentDocumentLinkObj[0].LinkedEntityId,'Success');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test resend Email Docusign 
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void testResendEmailDocusign() {
        User userObj = [SELECT Id
                        FROM USER 
                        WHERE Id = :UserInfo.getUserId() 
                        LIMIT 1];
        System.runAs(userObj){  
            genesis__Applications__c applicationObj = [SELECT Id,
                                                                Signing_Method__c,
                                                                Resend_Docusign__c
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
            
            applicationObj.DocuSign_Credit_Agreement_Initiated__c=false;
            applicationObj.Signing_Method__c = ConstantValues.EMAIL_DOCUSIGN;
            Database.update(applicationObj,true);

            //creating another document for this scenario
            testSetUpCreditAgreementDoc(applicationObj.Id);

            List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocument.Title=:PortalConstants.AGREEMENT_FILE_NAME];
            Test.startTest();
            ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
            System.assertEquals(applicationObj.Id, contentDocumentLinkObj[0].LinkedEntityId,'Success');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test resend Docusign hybrid for agreement sign true
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void testDocusignHybridForAlreadySigned() {
        User userObj = [SELECT Id
                        FROM USER 
                        WHERE Id = :UserInfo.getUserId() 
                        LIMIT 1];
        System.runAs(userObj){  
            genesis__Applications__c applicationObj = [SELECT Id,
                                                                Signing_Method__c,
                                                                Resend_Docusign__c,
                                                                Agreement_Sign__c
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
            
            applicationObj.DocuSign_Credit_Agreement_Initiated__c=false;
            applicationObj.Signing_Method__c = ConstantValues.IN_PERSON_HYBRID;
            applicationObj.Agreement_Sign__c = true;
            applicationObj.Resend_Docusign__c = true;
            Database.update(applicationObj,true);

            //creating another document for this scenario
            testSetUpCreditAgreementDoc(applicationObj.Id);

            List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocument.Title=:PortalConstants.AGREEMENT_FILE_NAME];
            Test.startTest();
            ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
            System.assertEquals(applicationObj.Id, contentDocumentLinkObj[0].LinkedEntityId,'Success');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test resend Docusign hybrid for failed scenario
    * @author Suraj Kumar | 10-22-2024 
    **/
    @isTest
    private static void testResendDocusignHybridFailure() {
        User userObj = [SELECT Id
                        FROM USER 
                        WHERE Id = :UserInfo.getUserId() 
                        LIMIT 1];
        System.runAs(userObj){  
            genesis__Applications__c applicationObj = [SELECT Id,
                                                                Signing_Method__c,
                                                                Resend_Docusign__c,
                                                                Agreement_Sign__c
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
            
            applicationObj.DocuSign_Credit_Agreement_Initiated__c=false;
            applicationObj.Signing_Method__c = ConstantValues.IN_PERSON_HYBRID;
            applicationObj.Resend_Docusign__c = false;
            Database.update(applicationObj,true);

            //creating another document for this scenario
            testSetUpCreditAgreementDoc(applicationObj.Id);

            List<ContentDocumentLink> contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocument.Title=:PortalConstants.AGREEMENT_FILE_NAME];
            Test.startTest();
            ContentDocumentLinkTriggerHandler.afterInsert(contentDocumentLinkObj);
            System.assertEquals(applicationObj.Id, contentDocumentLinkObj[0].LinkedEntityId,'Success');
            Test.stopTest();
        }
    }
    
}