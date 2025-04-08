/**
 * @description       : 
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 03-05-2024
 * @last modified by  : Krishanu Chinya
**/

@isTest
public with sharing class PortalFetchCoApplicantsAPITest {
    @testSetup
    static void setup(){
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(legalEntityObj,true);

        clcommon__Legal_Entity__c corpLegalEntityObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(corpLegalEntityObj,true);

        // clcommon__Legal_Entity__c dbaLegalEntityObj  = ApplicationOriginationTestHelper.createDBALegalEntity();
        // Database.insert(dbaLegalEntityObj,true);

        // clcommon__Legal_Entity__c trustLegalEntityObj  = ApplicationOriginationTestHelper.createTrustLegalEntity();
        // Database.insert(trustLegalEntityObj,true);

        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);

        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(clPartyTypeObj,true);

        // clcommon__Party_Type__c saPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('SALES AGENT');
        // Database.insert(saPartyTypeObj,true);

        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(borrowerPartyTypeObj,true);

        clcommon__Party_Type__c principalPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        Database.insert(principalPartyTypeObj,true);

        // clcommon__Party_Type__c clPlusPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER PLUS');
        // Database.insert(clPlusPartyTypeObj,true);

        // clcommon__Party_Type__c iqPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('INQUIRY');
        // Database.insert(iqPartyTypeObj,true);

        // clcommon__Party_Type__c iqPlusPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('INQUIRY PLUS');
        // Database.insert(iqPlusPartyTypeObj,true);

        // clcommon__Party_Type__c dealerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('DEALER');
        // Database.insert(dealerPartyTypeObj,true);

        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj,true);

        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.id);
        dealerAccountObj.Enable_ERP_Id__c = true;
        Database.insert(dealerAccountObj,true);

        genesis__Business_Information__c businessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(businessInfoObj,true);

        Account accountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(businessInfoObj.id,dealerAccountObj.id);
        Database.insert(accountObj,true);

        Contact contactObj = ApplicationOriginationTestHelper.createSalesAgentContact(accountObj.id);
        Database.insert(contactObj,true);

        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Database.insert(clAccountObj,true);

        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
        Database.insert(clContactObj,true);

        // Account clPlusAccountObj = ApplicationOriginationTestHelper.createCLPlusAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        // Database.insert(clPlusAccountObj,true);

        // Contact clPlusContactObj = ApplicationOriginationTestHelper.createCLPlusContact(clPlusAccountObj.id);
        // Database.insert(clPlusContactObj,true);

        // Account iqAccountObj = ApplicationOriginationTestHelper.createInquiryAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        // Database.insert(iqAccountObj,true);

        // Contact iqContactObj = ApplicationOriginationTestHelper.createInquiryContact(iqAccountObj.id);
        // Database.insert(iqContactObj,true);

        // Account iqPlusAccountObj = ApplicationOriginationTestHelper.createInquiryPlusAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        // Database.insert(iqPlusAccountObj,true);

        // Contact iqPlusContactObj = ApplicationOriginationTestHelper.createInquiryPlusContact(iqPlusAccountObj.id);
        // Database.insert(iqPlusContactObj,true);

        User userObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.id);
        Database.insert(userObj,true);

        // clcommon__Reciprocal_Role__c clPlusRole = ApplicationOriginationTestHelper.createCertifiedLenderPlusRole();
        // Database.insert(clPlusRole,true);

        // clcommon__Reciprocal_Role__c iqRole = ApplicationOriginationTestHelper.createInquiryRole();
        // Database.insert(iqRole,true);

        // clcommon__Reciprocal_Role__c iqPlusRole = ApplicationOriginationTestHelper.createInquiryPlusRole();
        // Database.insert(iqPlusRole,true);

        clcommon__Reciprocal_Role__c role = ApplicationOriginationTestHelper.createSalesAgentRole();
        Database.insert(role,true);

        clcommon__Relationship__c relationship = ApplicationOriginationTestHelper.createSalesAgentDealerRelationship(role,dealerAccountObj.id,accountObj.id);
        Database.insert(relationship,true);
    
        clcommon__Reciprocal_Role__c clRole = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(clRole,true);

        //creating related sales agent  role
        clcommon__Reciprocal_Role__c rsaRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.RELATED_SALES_AGENT);
        Database.insert(rsaRoleObj, true);

        clcommon__Relationship__c clRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(clRole,dealerAccountObj.id,clAccountObj.id);
        Database.insert(clRelationship,true);

        // clcommon__Relationship__c clPlusRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(clPlusRole,dealerAccountObj.id,clPlusAccountObj.id);
        // Database.insert(clPlusRelationship,true);

        // clcommon__Relationship__c iqRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(iqRole,dealerAccountObj.id,iqAccountObj.id);
        // Database.insert(iqRelationship,true);

        // clcommon__Relationship__c iqPlusRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(iqPlusRole,dealerAccountObj.id,iqPlusAccountObj.id);
        // Database.insert(iqPlusRelationship,true);

        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);

        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        borrowerAccountObj.CIF_Number__c = '123456';
        Database.insert(borrowerAccountObj,true);

        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        Database.insert(borrowerContactObj,true);

        genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(coBorrowerBusinessInfoObj,true);

        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(legalEntityObj,coBorrowerBusinessInfoObj.id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        Database.insert(coBorrowerAccountObj,true);

        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        Database.insert(coBorrowerContactObj,true);

        Map<String,Id> applicationDataMap = new Map<String,Id>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'saAccountObjId' => accountObj.id
        };
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(applicationDataMap);
        applicationObj.genesis__Product_Type__c ='Package';
        Database.insert(applicationObj,true); 

        Map<String,Id> partyParamMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => borrowerPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(partyParamMap);
        partyObj.clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;
        partyObj.clcommon__Account__c = null;
        Database.insert(partyObj,true);

        Map<String,Id> clpartyParamMap = new Map<String,Id>{
            'accountId' => clAccountObj.id,
            'contactId' => clContactObj.id,
            'partyTypeId' => clPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(clpartyParamMap);
        clPartyObj.clcommon__Party_Types__c = PortalConstants.CERTIFIED_LENDER;
        Database.insert(clPartyObj,true);
        // Map<String,Id> sapartyParamMap = new Map<String,Id>{
        //     'accountId' => accountObj.id,
        //     'contactId' => contactObj.id,
        //     'partyTypeId' => saPartyTypeObj.id,
        //     'applicationId' => applicationObj.id
        // };
        // clcommon__Party__c saPartyObj = ApplicationOriginationTestHelper.createParty(sapartyParamMap);
        // Database.insert(saPartyObj,true);

        Map<String,Id> coPartyParamMap = new Map<String,Id>{
            'accountId' => coBorrowerAccountObj.id,
            'contactId' => coBorrowerContactObj.id,
            'partyTypeId' => principalPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c coPartyObj = ApplicationOriginationTestHelper.createParty(coPartyParamMap);
        coPartyObj.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;
        Database.insert(coPartyObj,true);

        CFA_Configuration__c cifObj = ApplicationOriginationTestHelper.createCIFNumber();
        Database.insert(cifObj,true);

        clcommon__document_category__c docCategory = ApplicationOriginationTestHelper.createDocCategory(applicationObj.id, PortalConstants.DRIVING_LICENSE_TASK);
        Database.insert(docCategory,true);

        ContentVersion contentVersion = ApplicationOriginationTestHelper.createContentVersion();
        Database.insert(contentVersion,true);

        ContentDocument contentDocObj = [SELECT Id FROM ContentDocument WHERE Title =: contentVersion.Title];
        ContentDocumentLink contentDocumentLink = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocObj.id,borrowerAccountObj.id);
        Database.insert(contentDocumentLink,true);

        //Create Task for the Application
        genesis__Department__c objDepartment =  ApplicationOriginationTestHelper.createDepartmentByName(ConstantValues.PROFILE_CREDIT);
        Database.insert(objDepartment,true);

        genesis__Task_Setup__c objTaskSetup = ApplicationOriginationTestHelper.createTaskSetup(PortalConstants.ADDITIONAL_INFO_TASK);
        Database.insert(objTaskSetup,true);
    }

    @isTest
    public static void testPortalFetchCoApplicantsAPI() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

        if(objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
               Test.startTest();
               PortalFetchCoApplicantsAPI  obj= new PortalFetchCoApplicantsAPI();
               clcommon.Response response = obj.invokeAction('', new List<String>(), requestMap);  
               Test.stopTest();
               System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
           }
       }

    }

}