/**
 * @description       : Test class for PortalFetchCongaTemplateAPI
 * @author            : Rahul Gupta | 22-04-2022
 * @group             : 
 * @last modified on  : 11-01-2025
 * @last modified by  : Soumik Pattanayak
**/
@isTest
public class TestPortalFetchCongaTemplateAPI {

    @TestSetup
    static void makeData() {

        // create business information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj,true);

        // create dealer account
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj,true);
                    
        // creating user for certified lender
        genesis__Business_Information__c clBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(clBusinessInfoObj,true);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(clBusinessInfoObj.Id,dealerAccountObj.Id);
        Database.insert(clAccountObj,true);
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj,true);
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        Database.insert(clUserObj,true);

        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(clRoleObj, false);
        clcommon__Relationship__c dealerCLrelationObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj, dealerAccountObj.Id, clAccountObj.Id);
        Database.insert(dealerCLrelationObj, false);

        // create legal entity
        clcommon__Legal_Entity__c legalEntityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        //insert objEntity;
        Database.insert(legalEntityObj,true);

        // create borrower
        genesis__Business_Information__c borrowerBIObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBIObj,true);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBIObj.Id);
        Database.insert(borrowerAccountObj,true);
        
        //Contact objBorrowerContact = new Contact(FirstName='Rahul', LastName='Gupta');
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(borrowerContactObj,true);

        // create loan product
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);

        // dealer applicant relationship creation
        Dealer_Applicant_Relationship__c relationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj, dealerAccountObj.Id);
        Database.insert(relationObj,true);

        // create application
        Map<String,Id> applicationDataMap = new Map<String,Id>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'clAccountObjId' => clAccountObj.id,
            'dealerApplicantRelationshipId' => relationObj.Id
        };
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(applicationDataMap);
        Database.insert(applicationObj,true);

        // create borrower party type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);
        Database.insert(borrowerPartyTypeObj);

        // create certified lender party
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.CL_PARTY_NAME);
        Database.insert(clPartyTypeObj,true);

        // create certified lender party
        clcommon__Party_Type__c dealerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.DEALER_PARTY_NAME);
        Database.insert(dealerPartyTypeObj,true);

        // create borrower party
        Map<String,Id> partyParamMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => borrowerPartyTypeObj.id,
            'applicationId' => applicationObj.id,
            'dealerApplicantRelationshipId' => relationObj.Id
        };
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(partyParamMap);
        Database.insert(partyObj,true);

        // create certified lender party
        Map<String,Id> clpartyParamMap = new Map<String,Id>{
            'accountId' => clAccountObj.id,
            'contactId' => clContactObj.id,
            'partyTypeId' => clPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(clpartyParamMap);
        clPartyObj.clcommon__Party_Types__c = PortalConstants.CERTIFIED_LENDER;
        Database.insert(clPartyObj,true);

        // create dealer party
        Map<String,Id> dealerpartyParamMap = new Map<String,Id>{
            'accountId' => dealerAccountObj.id,
            'partyTypeId' => dealerPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c dealerPartyObj = ApplicationOriginationTestHelper.createParty(dealerpartyParamMap);
        Database.insert(dealerPartyObj,true);

        // create content version for agreement form template content version
        ContentVersion objAgreementFTCV = createContentVersion(PortalConstants.AGREEMENT_FILE_NAME);
        Database.insert(objAgreementFTCV,true);
    
        // create content version for customized form template content version
        ContentVersion objCustomizedFTCV = createContentVersion(PortalConstants.CUSTOMIZED_FORM_FILE_NAME);
        Database.insert(objCustomizedFTCV,true);

        // create content version for withdrawal form template content version
        ContentVersion objWithdrawalFTCV = createContentVersion(PortalConstants.WITHDRAWAL_FORM_FILE_NAME);
        Database.insert(objWithdrawalFTCV,true);

        // create content document for agreement form template content document
        ContentDocument objAgreementFTCD = createContentDocument(PortalConstants.AGREEMENT_FILE_NAME);
        //Database.insert(objAgreementFTCD,true);

        // create content document for customized form template content document
        ContentDocument objCustomizedFTCD = createContentDocument(PortalConstants.CUSTOMIZED_FORM_FILE_NAME);
        //Database.insert(objCustomizedFTCD,true);

        // create content document for withdrawal form template content document
        ContentDocument objWithdrawalFTCD = createContentDocument(PortalConstants.WITHDRAWAL_FORM_FILE_NAME);
        //Database.insert(objWithdrawalFTCD,true);

        // create content document link for agreement form template content document link
        ContentDocumentLink objAgreementFTCDL = createContentDocumentLink(applicationObj, objAgreementFTCD);
        //Database.insert(objAgreementFTCDL,true);

        // create content document link for customized form template content document link
        ContentDocumentLink objCustomizedFTCDL = createContentDocumentLink(applicationObj, objCustomizedFTCD);
        //Database.insert(objCustomizedFTCDL,true);

        // create content document link for withdrawal form template content document link
        ContentDocumentLink objWithdrawalFTCDL = createContentDocumentLink(applicationObj, objWithdrawalFTCD);
        Database.insert(new List<ContentDocumentLink>{objWithdrawalFTCDL, objCustomizedFTCDL, objAgreementFTCDL},true);

    }

    // Test data for contentDocument
    /**
    * @description : this method creates ContentDocument
    * @author Suraj Kumar | 03-14-2024 
    * @param fileName 
    * @return ContentDocument 
    **/
    public static ContentDocument createContentDocument(String fileName) {
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE Title = :fileName LIMIT 1];


        return contentDocuments[0];
    }

    // Test data for contentDocumentLink
    /**
    * @description : this method creates ContentDocumentLink
    * @author Suraj Kumar | 03-14-2024 
    * @param application 
    * @param contentDocument 
    * @return ContentDocumentLink 
    **/
    public static ContentDocumentLink createContentDocumentLink(genesis__Applications__c application, ContentDocument contentDocument) {
        

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.LinkedEntityId = application.Id;
        contentDocumentLink.ContentDocumentId = contentDocument.Id;
        contentDocumentLink.ShareType = 'V';
        contentDocumentLink.Visibility = 'AllUsers';

        return contentDocumentLink;
    }

    // Test data for contentVersion
    /**
    * @description : this method creates ContentVersion
    * @author Suraj Kumar | 03-14-2024 
    * @param fileName 
    * @return ContentVersion 
    **/
    public static ContentVersion createContentVersion(String fileName) {
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = fileName,
            PathOnClient   = fileName,
            VersionData    = Blob.valueOf('Test Credit Application Agreement Content'),
            IsMajorVersion = true);

        return contentVersion;
    }

    /**
    * @description : this method return certified lender user
    * @author Suraj Kumar | 03-14-2024 
    * @return User 
    **/
    private static User getCertifiedLenderUser() {
       
        List<User> objUserList = [SELECT Id 
                                    FROM User 
                                    WHERE AccountId IN (
                                        SELECT Id 
                                        FROM Account 
                                        WHERE Name = 'Ross Geller')];
                                    
        if (objUserList.size() == 1) {
            return objUserList[0];
        } 
        
        return null;
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 01-01-2025 
    **/
    @isTest
    public static void testGetAgreementTemplate() {
        clcommon.Response resp;
        User certifiedLenderUserObj = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        List<genesis__Applications__c> applicationList = [SELECT Id 
                                                    FROM genesis__Applications__c 
                                                    LIMIT 1];

        request.put('applicationId', applicationList[0].Id);
        request.put('templateName', 'agreementTemplate');

        if (certifiedLenderUserObj != null) {
            System.runAs(certifiedLenderUserObj) {
                Test.startTest();
    
                // Calling  the API
                PortalFetchCongaTemplateAPI saveApi = new PortalFetchCongaTemplateAPI();
                resp = saveApi.invokeAction('', new List<String>(), request);
                System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'assertion failed'); 
                Test.stopTest();
            }
        }

    }

    /**
    * @description 
    * @author Soumik Pattanayak | 01-01-2025 
    **/
    @isTest
    public static void testCustomizedFormTemplate() {
        clcommon.Response resp;
        User certifiedLenderUserObj = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        List<genesis__Applications__c> applicationList = [SELECT Id 
                                                    FROM genesis__Applications__c 
                                                    LIMIT 1];

        request.put('applicationId', applicationList[0].Id);
        request.put('templateName', 'customizedFormTemplate');

        if (certifiedLenderUserObj != null) {
            System.runAs(certifiedLenderUserObj) {
                Test.startTest();
    
                // Calling  the API
                PortalFetchCongaTemplateAPI saveApi = new PortalFetchCongaTemplateAPI();
                resp = saveApi.invokeAction('', new List<String>(), request); 
                System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'assertion failed');
    
                Test.stopTest();
            }

        }

    }

    /**
    * @description 
    * @author Soumik Pattanayak | 01-01-2025 
    **/
    @isTest
    public static void testWithdrawalFormTemplate() {
        clcommon.Response resp;
        User certifiedLenderUserObj = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        List<genesis__Applications__c> applicationList = [SELECT Id 
                                                    FROM genesis__Applications__c 
                                                    LIMIT 1];

        request.put('applicationId', applicationList[0].Id);
        request.put('templateName', 'withdrawalFormTemplate');

        if (certifiedLenderUserObj != null) {
            System.runAs(certifiedLenderUserObj) {
                Test.startTest();
    
                // Calling  the API
                PortalFetchCongaTemplateAPI saveApi = new PortalFetchCongaTemplateAPI();
                resp = saveApi.invokeAction('', new List<String>(), request);
                System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'assertion failed'); 
    
                Test.stopTest();
            }
        }
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 01-01-2025 
    **/
    @isTest
    public static void testInvalidTemplate() {
        clcommon.Response resp;
        User certifiedLenderUserObj = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        List<genesis__Applications__c> applicationList = [SELECT Id 
                                                    FROM genesis__Applications__c 
                                                    LIMIT 1];

        request.put('applicationId', applicationList[0].Id);
        request.put('templateName', 'abc');

        if (certifiedLenderUserObj != null) {
            System.runAs(certifiedLenderUserObj) {
                Test.startTest();
    
                // Calling  the API
                PortalFetchCongaTemplateAPI saveApi = new PortalFetchCongaTemplateAPI();
                resp = saveApi.invokeAction('', new List<String>(), request);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assertion failed'); 
    
                Test.stopTest();
            }
        }
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 01-01-2025 
    **/
    @isTest
    public static void testInvalidUser() {
        clcommon.Response resp;
        User userObj = [SELECT id FROM User WHERE id != :UserInfo.getUserId() AND isActive = true AND Profile.Name = 'Grower' LIMIT 1];

        Map<String, Object> request = new Map<String, Object>();

        request.put('applicationId', true);
        request.put('templateName', 'withdrawalFormTemplate');

        if (userObj != null) {
            System.runAs(userObj) {
                Test.startTest();
    
                // Calling  the API
                PortalFetchCongaTemplateAPI saveApi = new PortalFetchCongaTemplateAPI();
                resp = saveApi.invokeAction('', new List<String>(), request);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assertion failed'); 
    
                Test.stopTest();
            }
        }
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 01-01-2025 
    **/
    @isTest
    public static void testNoContentDocument() {
        clcommon.Response resp;
        User certifiedLenderUserObj = getCertifiedLenderUser();
        List<ContentDocumentLink> contentDocumentList = [SELECT id FROM ContentDocumentLink];
        Database.delete(contentDocumentList);
        Map<String, Object> request = new Map<String, Object>();

        List<genesis__Applications__c> applicationList = [SELECT Id 
                                                    FROM genesis__Applications__c 
                                                    LIMIT 1];

        request.put('applicationId', applicationList[0].Id);
        request.put('templateName', 'withdrawalFormTemplate');

        if (certifiedLenderUserObj != null) {
            System.runAs(certifiedLenderUserObj) {
                Test.startTest();
    
                // Calling  the API
                PortalFetchCongaTemplateAPI saveApi = new PortalFetchCongaTemplateAPI();
                resp = saveApi.invokeAction('', new List<String>(), request);
                System.assertEquals(clcommon.Constants.PENDING, resp.status, 'assertion failed'); 
    
                Test.stopTest();
            }
        }
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 11-01-2025 
    **/
    @isTest
    public static void testExceptionNoTemplateParam() {
        clcommon.Response resp;
        User certifiedLenderUserObj = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        List<genesis__Applications__c> applicationList = [SELECT Id 
                                                    FROM genesis__Applications__c 
                                                    LIMIT 1];

        request.put('applicationId', applicationList[0].Id);

        if (certifiedLenderUserObj != null) {
            System.runAs(certifiedLenderUserObj) {
                Test.startTest();
    
                // Calling  the API
                PortalFetchCongaTemplateAPI saveApi = new PortalFetchCongaTemplateAPI();
                resp = saveApi.invokeAction('', new List<String>(), request);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assertion failed'); 
    
                Test.stopTest();
            }
        }
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 11-01-2025 
    **/
    @isTest
    public static void testExceptionInvalidApplicationId() {
        clcommon.Response resp;
        User certifiedLenderUserObj = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('applicationId', true);

        if (certifiedLenderUserObj != null) {
            System.runAs(certifiedLenderUserObj) {
                Test.startTest();
    
                // Calling  the API
                PortalFetchCongaTemplateAPI saveApi = new PortalFetchCongaTemplateAPI();
                resp = saveApi.invokeAction('', new List<String>(), request);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'assertion failed'); 
    
                Test.stopTest();
            }

        }
    }
}