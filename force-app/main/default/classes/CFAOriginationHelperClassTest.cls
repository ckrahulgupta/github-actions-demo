/**
 * @description       : Test class for CFAOriginationHelperClass
 * @author            : Soumik Pattanayak
 * @group             : 
 * @last modified on  : 06-12-2024
 * @last modified by  : Soumik Pattanayak
**/
@IsTest
public inherited sharing class CFAOriginationHelperClassTest {
    /**
    * @description Method for making test data
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @TestSetup
    static void makeData(){
        // Creating sole-prop, corporation, dba legal entities
        clcommon__Legal_Entity__c solePropLegalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(new List<clcommon__Legal_Entity__c>{solePropLegalEntityObj}, true);

        // Creating cl product
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        // Creating cl purpose
        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj,true);

        // Creating CL, Borrower, Principal, Dealer Party Types
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c principalPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        clcommon__Party_Type__c dealerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('DEALER');
        Database.insert(new List<clcommon__Party_Type__c>{clPartyTypeObj, borrowerPartyTypeObj, principalPartyTypeObj, dealerPartyTypeObj}, true);

        // Creating Dealer, Borrower Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        borrowerBusinessInfoObj.genesis__Tax_Identification_Number__c = '';
        genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        coBorrowerBusinessInfoObj.genesis__Tax_Identification_Number__c = '';
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj, borrowerBusinessInfoObj, coBorrowerBusinessInfoObj}, true);

        // Creating dealer, CL, Borrower, Coapplicant Account
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.id);  
        dealerAccountObj.CIF_Number__c = '114618';
        Account landusDealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.id);
        landusDealerAccountObj.Coop_Type__c = 'Landus';
        Account gmkDealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.id);
        gmkDealerAccountObj.Coop_Type__c = 'Growmark';
        Database.insert(new List<Account>{dealerAccountObj, landusDealerAccountObj, gmkDealerAccountObj},true);

        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Account paAccountObj = ApplicationOriginationTestHelper.createPaymentAdministratorAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Account saAccObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.Id,dealerAccountObj.Id);
        Account saAdminAccObj = ApplicationOriginationTestHelper.createSAAdminAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);                
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(solePropLegalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        borrowerAccountObj.BillingStreet = '12th Road';
        borrowerAccountObj.CIF_Number__c = '123456';
        borrowerAccountObj.BillingPostalCode = '77777';
        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(solePropLegalEntityObj,coBorrowerBusinessInfoObj.id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        Database.insert(new List<Account>{clAccountObj, paAccountObj, saAccObj, saAdminAccObj, borrowerAccountObj, coBorrowerAccountObj},true);
        
        // Creating CL, Borrower, Coapplicant Contact
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
        Contact paContactObj = ApplicationOriginationTestHelper.createPaymentAdministratorContact(paAccountObj.Id);
        Contact saContactObj=ApplicationOriginationTestHelper.createSalesAgentContact(saAccObj.Id);
        Contact saAdminContactObj=ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccObj.Id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        borrowerContactObj.genesis__SSN__c = '324242424';
        borrowerContactObj.Confirm_SSN__c = '324242424';
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        coBorrowerContactObj.genesis__SSN__c = '666714588';
        coBorrowerContactObj.Confirm_SSN__c = '666714588';
        coBorrowerContactObj.ints__Middle_Name__c = 'Kumar';
        Database.insert(new List<Contact>{clContactObj, paContactObj, saContactObj, saAdminContactObj, borrowerContactObj, coBorrowerContactObj},true);

        Dealer_Applicant_Relationship__c borrowerRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c coBorrowerRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(coBorrowerContactObj,dealerAccountObj.Id);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{borrowerRelationObj, coBorrowerRelationObj},true);

        // Creating CL User
        User clUser = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        User paUser = ApplicationOriginationTestHelper.createPaymentAdministratorUser(paContactObj.Id);
        Database.insert(new List<User>{clUser, paUser}, true);

        // Creating Application
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(new Map<String,Id>{'dealerAccountObjId' => dealerAccountObj.id,
                                                                                                                        'clProductObjId' => clProductObj.id,
                                                                                                                        'clPurposeObjId' => clPurposeObj.id,
                                                                                                                        'borrowerAccountObjId' => borrowerAccountObj.id,
                                                                                                                        'borrowerContactObjId' => borrowerContactObj.id,
                                                                                                                        'saAccountObjId' => saAccObj.id,
                                                                                                                        'dealerApplicantRelationshipId' => borrowerRelationObj.id
                                                                                                                    });
        applicationObj.genesis__Product_Type__c ='Package';
        applicationObj.genesis__Loan_Amount__c = 824001;
        Database.insert(applicationObj,true); 

        // Creating Borrower Party
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{'accountId' => borrowerAccountObj.id,
                                                                                                        'contactId' => borrowerContactObj.id,
                                                                                                        'partyTypeId' => borrowerPartyTypeObj.id,
                                                                                                        'applicationId' => applicationObj.id,
                                                                                                        'dealerApplicantRelationshipId' => borrowerRelationObj.id
                                                                                                    });
        partyObj.clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;
        Database.insert(partyObj,true);

        clcommon__Reciprocal_Role__c paRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.PAYMENT_ADMINISTRATOR);
        clcommon__Reciprocal_Role__c rsaRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.RELATED_SALES_AGENT);
        clcommon__Reciprocal_Role__c fsaRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.FIELD_STAFF_AGENT);
        clcommon__Reciprocal_Role__c saRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.SALES_AGENT);
        Database.insert(new List<clcommon__Reciprocal_Role__c>{paRoleObj, rsaRoleObj, fsaRoleObj, saRoleObj}, true);

        clcommon__Relationship__c relationshipObject = ApplicationOriginationTestHelper.createRelWithDealer(rsaRoleObj,saAdminAccObj.Id,saAccObj.Id);
        clcommon__Relationship__c paDealerRelationObj = ApplicationOriginationTestHelper.createPADealerRelationship(paRoleObj, dealerAccountObj.Id, clAccountObj.Id);
        Database.insert(new List<clcommon__Relationship__c>{paDealerRelationObj, relationshipObject}, true);

        AccountShare accountShareObj = ApplicationOriginationTestHelper.createAccountShareRecord(clAccountObj.Id, clUser.Id);
        Database.insert(accountShareObj, true);

        genesis__Application_Pricing_Detail__c pricingDeailsObj = ApplicationOriginationTestHelper.createPricingDetail(applicationObj.Id);
        Database.insert(pricingDeailsObj, true);

        clcommon__Payment_Mode__c paymentModeObj = ApplicationOriginationTestHelper.createPaymentMode('PAYMENT');
        Database.insert(paymentModeObj, true);

        genesis__Funding_Transaction__c fundingTxnObj = ApplicationOriginationTestHelper.createFundingTransaction(paymentModeObj.Id, pricingDeailsObj.Id, applicationObj.Id);
        Database.insert(fundingTxnObj, true);

        testSetupContentdocument(applicationObj.id,borrowerAccountObj.Id);
    }

    /**
    * @description : Method to create contet document for test setup
    * @author Suraj Kumar | 10-25-2024 
    * @param applicationId 
    * @param borrowerId 
    **/
    private static void testSetupContentdocument(String applicationId, String borrowerId){
        //creating content version
        ContentVersion contentVerAgreementObj = ApplicationOriginationTestHelper.createContentVersion(PortalConstants.AGREEMENT_FILE_NAME);
        Database.insert(contentVerAgreementObj,true);
 
        // creating content Document
        ContentDocument contentDocAgreementObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
 
        // creating ContentDocumentLink
        ContentDocumentLink contentDocLinkAgrmttObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocAgreementObj.id,applicationId);
        Database.insert(contentDocLinkAgrmttObj,true);

        clcommon__document_category__c docCategorySigned = ApplicationOriginationTestHelper.createDocCategory(applicationId,PortalConstants.SIGNED_AGREEMENT_TASK);
        Database.insert(docCategorySigned,true); 
    }

    /**
    * @description Test method for emailTemplateMappingMetadata
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testEmailTemplateMapping() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            EmailTemplate emailTemplate = CFAOriginationHelperClass.emailTemplateMappingMetadata(ConstantValues.CFA_COOP_TYPE, PortalConstants.APP_WITHDRAW_BY_DEALER_NOTIFIC);
            System.assertEquals('CFA App Withdrawal by Dealer Notific', emailTemplate.Name, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for emailTemplateMappingMetadata Exception
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testEmailTemplateMappingException() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            EmailTemplate emailTemplate;
            try{
                emailTemplate = CFAOriginationHelperClass.emailTemplateMappingMetadata(ConstantValues.CFA_COOP_TYPE, PortalConstants.EMPTY_STRING);
            }catch(Exception exceptionObj){
                System.assertEquals(null, emailTemplate, PortalConstants.ASSERTION_FAILED);
            }
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getLogoURLbyCoopType CFA
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetCFALogUrl() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            String url = CFAOriginationHelperClass.getLogoURLbyCoopType(ConstantValues.CFA_COOP_TYPE);
            System.assertEquals(System.Label.CFA_Logo_Url, url, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getLogoURLbyCoopType GrowMark
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetGMKLogUrl() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            String url = CFAOriginationHelperClass.getLogoURLbyCoopType(ConstantValues.GROWMARK_COOP_TYPE);
            System.assertEquals(System.Label.GMK_Logo_Url, url, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getLogoURLbyCoopType Landus
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest 
    private static void testGetLandusLogUrl() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            String url = CFAOriginationHelperClass.getLogoURLbyCoopType(ConstantValues.LANDUS_COOP_TYPE);
            System.assertEquals(System.Label.Landus_Logo_Url, url, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getOrgWideEmailAddress
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetOrgWideEmailAddress() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            List<OrgWideEmailAddress> senderAddressList = CFAOriginationHelperClass.getOrgWideEmailAddress();
            System.assertEquals(1, senderAddressList.size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getUserListFromAccountList with No Account Id
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetUserListWithNoAccountId() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            Map<Id, Id> resultMap = CFAOriginationHelperClass.getUserListFromAccountList(new List<Id>{});
            System.assertEquals(0, resultMap.size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getUserListFromAccountList
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetUserList() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            Map<Id, Id> resultMap = CFAOriginationHelperClass.getUserListFromAccountList(new List<Id>{[SELECT Id FROM Account WHERE Name = 'Ross Geller' LIMIT 1][0].Id});
            System.assertEquals(1, resultMap.size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for checkEmptyList
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testCheckEmptyList() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            try{
                CFAOriginationHelperClass.checkEmptyList(new List<Object>(), 'Test');
            }catch(Exception exceptionObj){
                System.assertEquals('Test', exceptionObj.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
        }
        Test.stopTest();
    }
    /**
    * @description Test method for checkRequiredParameters
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testBlankString() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            try{
                CFAOriginationHelperClass.checkRequiredParameters('');
            }catch(Exception exceptionObj){
                System.assertEquals(ConstantValues.PARAMETER_MISSING, exceptionObj.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getPartyTypeId
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void getPartyTypeIdByRecordType() {
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            String partyTypeId = CFAOriginationHelperClass.getPartyTypeId(ConstantValues.CERTIFIED_LENDER);
            List<clcommon__Party_Type__c> clPartytype = [SELECT Id
                                                            FROM clcommon__Party_Type__c 
                                                            WHERE Name= 'Certified Lender'];
            System.assertEquals(clPartytype[0].Id, partyTypeId, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getPartyTypeId Exception
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void getPartyTypeIdByRecordTypeException() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            try{
                CFAOriginationHelperClass.getPartyTypeId(ConstantValues.CERTIFIED_LENDER);
            } catch (Exception exceptionObj){
                System.assertEquals('List has no rows for assignment to SObject', exceptionObj.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
        }
        Test.stopTest();
    }

    /**
    * @description Test method for throwAuraHandledException
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testThrowAuraHandledException() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            try{
                CFAOriginationHelperClass.throwAuraHandledException('Testing Aura Handled Exception');
            } catch (Exception exceptionObj){
                System.assertEquals('Testing Aura Handled Exception', exceptionObj.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
        }
        Test.stopTest();
    }
    /**
    * @description : Test Method for createDocCategoryAttachment for succes scenario
    * @author Suraj Kumar | 10-25-2024 
    **/
    @isTest
    private static void testCreateDocCategoryAttachment(){
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 824001 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id, Title FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID LIMIT 1];
        ContentVersion contentVersionObj =  [SELECT Id, 
                                                    Title,
                                                    ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId = :contentDocumentObj.Id LIMIT 1];
        Test.startTest();
        System.runAs(userObj){  
            CFAOriginationHelperClass.createDocCategoryAttachment(new Map<String,String>{
                PortalConstants.TITLE_KEY => contentVersionObj.Title,
                PortalConstants.CONTENT_VERSION_ID_KEY => contentVersionObj.Id,
                PortalConstants.CONTENT_DOC_ID_KEY => contentDocumentLinkObj.ContentDocumentId,
                PortalConstants.APPLICATION_ID_KEY => contentDocumentLinkObj.LinkedEntityId,
                PortalConstants.NAME_KEY => PortalConstants.SIGNED_AGREEMENT_TASK
            });  
            List<clcommon__Category_Attachment_Association__c> categoryAttachmentObj = [SELECT Id FROM clcommon__Category_Attachment_Association__c WHERE clcommon__Content_Document_Id__c = :contentDocumentObj.Id];
            System.assert(categoryAttachmentObj.size()>0, 'AssertionFailed');
        }
        Test.stopTest();
    }

    /**
    * @description : Test Method for createDocCategoryAttachment for failure scenario
    * @author Suraj Kumar | 10-25-2024 
    **/
    @isTest
    private static void testCreateDocCategoryAttachmentFailure(){
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 824001 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id, Title FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID LIMIT 1];
        ContentVersion contentVersionObj =  [SELECT Id, 
                                                    Title,
                                                    ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId = :contentDocumentObj.Id LIMIT 1];
        Test.startTest();
        System.runAs(userObj){  
            CFAOriginationHelperClass.createDocCategoryAttachment(new Map<String,String>{
                PortalConstants.TITLE_KEY => contentVersionObj.Title,
                PortalConstants.CONTENT_VERSION_ID_KEY => contentVersionObj.Id,
                PortalConstants.CONTENT_DOC_ID_KEY => contentDocumentLinkObj.ContentDocumentId,
                PortalConstants.APPLICATION_ID_KEY => contentDocumentLinkObj.LinkedEntityId,
                PortalConstants.NAME_KEY => PortalConstants.AGREEMENT_FILE_NAME
            });  
            List<clcommon__Category_Attachment_Association__c> categoryAttachmentObj = [SELECT Id FROM clcommon__Category_Attachment_Association__c WHERE clcommon__Content_Document_Id__c = :contentDocumentObj.Id];
            System.assert(categoryAttachmentObj.size()==0, 'AssertionFailed');
        }
        Test.stopTest();
    }

     /**
    * @description : Test Method for createDocCategoryAttachment empty parameter map
    * @author Suraj Kumar | 10-25-2024 
    **/
    @isTest
    private static void testCategoryAttachmentEmptyParameterMap(){
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        Test.startTest();
        System.runAs(userObj){  
            try{
                CFAOriginationHelperClass.createDocCategoryAttachment(new Map<String,String>());  
            } catch (Exception exceptionObj){
                List<clcommon__Category_Attachment_Association__c> categoryAttachmentObj = [SELECT Id FROM clcommon__Category_Attachment_Association__c];
                System.assert(categoryAttachmentObj.size()==0, 'AssertionFailed');
            }
        }
        Test.stopTest();
    }

    /**
    * @description : Test Method for createDocCategoryAttachment without Title Key
    * @author Suraj Kumar | 10-25-2024 
    **/
    @isTest
    private static void testCategoryAttachmentWithoutTitle(){
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 824001 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id, Title FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID LIMIT 1];
        ContentVersion contentVersionObj =  [SELECT Id, 
                                                    Title,
                                                    ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId = :contentDocumentObj.Id LIMIT 1];
        Test.startTest();
        System.runAs(userObj){  
            try{
                CFAOriginationHelperClass.createDocCategoryAttachment(new Map<String,String>{
                    PortalConstants.CONTENT_VERSION_ID_KEY => contentVersionObj.Id,
                    PortalConstants.CONTENT_DOC_ID_KEY => contentDocumentLinkObj.ContentDocumentId,
                    PortalConstants.APPLICATION_ID_KEY => contentDocumentLinkObj.LinkedEntityId,
                    PortalConstants.NAME_KEY => PortalConstants.SIGNED_AGREEMENT_TASK
                }); 
            } catch (Exception exceptionObj){
                List<clcommon__Category_Attachment_Association__c> categoryAttachmentObj = [SELECT Id FROM clcommon__Category_Attachment_Association__c];
                System.assert(categoryAttachmentObj.size()==0, 'AssertionFailed');
            } 
        }
        Test.stopTest();
    }

    /**
    * @description : Test Method for createDocCategoryAttachment without content version Key
    * @author Suraj Kumar | 10-25-2024 
    **/
    @isTest
    private static void testCategoryAttachmentWithoutConVersion(){
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 824001 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id, Title FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID LIMIT 1];
        ContentVersion contentVersionObj =  [SELECT Id, 
                                                    Title,
                                                    ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId = :contentDocumentObj.Id LIMIT 1];
        Test.startTest();
        System.runAs(userObj){  
            try{
                CFAOriginationHelperClass.createDocCategoryAttachment(new Map<String,String>{
                    PortalConstants.TITLE_KEY => contentVersionObj.Title,
                    PortalConstants.CONTENT_DOC_ID_KEY => contentDocumentLinkObj.ContentDocumentId,
                    PortalConstants.APPLICATION_ID_KEY => contentDocumentLinkObj.LinkedEntityId,
                    PortalConstants.NAME_KEY => PortalConstants.SIGNED_AGREEMENT_TASK
                }); 
            } catch (Exception exceptionObj){
                List<clcommon__Category_Attachment_Association__c> categoryAttachmentObj = [SELECT Id FROM clcommon__Category_Attachment_Association__c];
                System.assert(categoryAttachmentObj.size()==0, 'AssertionFailed');
            } 
        }
        Test.stopTest();
    }

    /**
    * @description : Test Method for createDocCategoryAttachment without content doc Key
    * @author Suraj Kumar | 10-25-2024 
    **/
    @isTest
    private static void testCategoryAttachmentWithoutConDoc(){
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 824001 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id, Title FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID LIMIT 1];
        ContentVersion contentVersionObj =  [SELECT Id, 
                                                    Title,
                                                    ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId = :contentDocumentObj.Id LIMIT 1];
        Test.startTest();
        System.runAs(userObj){  
            try{
                CFAOriginationHelperClass.createDocCategoryAttachment(new Map<String,String>{
                    PortalConstants.TITLE_KEY => contentVersionObj.Title,
                    PortalConstants.CONTENT_VERSION_ID_KEY => contentVersionObj.Id,
                    PortalConstants.APPLICATION_ID_KEY => contentDocumentLinkObj.LinkedEntityId,
                    PortalConstants.NAME_KEY => PortalConstants.SIGNED_AGREEMENT_TASK
                }); 
            } catch (Exception exceptionObj){
                List<clcommon__Category_Attachment_Association__c> categoryAttachmentObj = [SELECT Id FROM clcommon__Category_Attachment_Association__c];
                System.assert(categoryAttachmentObj.size()==0, 'AssertionFailed');
            } 
        }
        Test.stopTest();
    }

     /**
    * @description : Test Method for createDocCategoryAttachment without app Id Key
    * @author Suraj Kumar | 10-25-2024 
    **/
    @isTest
    private static void testCategoryAttachmentWithoutAppId(){
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 824001 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id, Title FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID LIMIT 1];
        ContentVersion contentVersionObj =  [SELECT Id, 
                                                    Title,
                                                    ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId = :contentDocumentObj.Id LIMIT 1];
        Test.startTest();
        System.runAs(userObj){  
            try{
                CFAOriginationHelperClass.createDocCategoryAttachment(new Map<String,String>{
                    PortalConstants.TITLE_KEY => contentVersionObj.Title,
                    PortalConstants.CONTENT_VERSION_ID_KEY => contentVersionObj.Id,
                    PortalConstants.CONTENT_DOC_ID_KEY => contentDocumentLinkObj.ContentDocumentId,
                    PortalConstants.NAME_KEY => PortalConstants.SIGNED_AGREEMENT_TASK
                }); 
            } catch (Exception exceptionObj){
                List<clcommon__Category_Attachment_Association__c> categoryAttachmentObj = [SELECT Id FROM clcommon__Category_Attachment_Association__c];
                System.assert(categoryAttachmentObj.size()==0, 'AssertionFailed');
            } 
        }
        Test.stopTest();
    }

    /**
    * @description : Test Method for createDocCategoryAttachment without Name Key
    * @author Suraj Kumar | 10-25-2024 
    **/
    @isTest
    private static void testCategoryAttachmentWithoutName(){
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 824001 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id, Title FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID LIMIT 1];
        ContentVersion contentVersionObj =  [SELECT Id, 
                                                    Title,
                                                    ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId = :contentDocumentObj.Id LIMIT 1];
        Test.startTest();
        System.runAs(userObj){  
            try{
                CFAOriginationHelperClass.createDocCategoryAttachment(new Map<String,String>{
                    PortalConstants.TITLE_KEY => contentVersionObj.Title,
                    PortalConstants.CONTENT_VERSION_ID_KEY => contentVersionObj.Id,
                    PortalConstants.CONTENT_DOC_ID_KEY => contentDocumentLinkObj.ContentDocumentId,
                    PortalConstants.APPLICATION_ID_KEY => contentDocumentLinkObj.LinkedEntityId
                }); 
            } catch (Exception exceptionObj){
                List<clcommon__Category_Attachment_Association__c> categoryAttachmentObj = [SELECT Id FROM clcommon__Category_Attachment_Association__c];
                System.assert(categoryAttachmentObj.size()==0, 'AssertionFailed');
            }
        }
        Test.stopTest();
    }
}