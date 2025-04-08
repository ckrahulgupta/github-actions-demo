/**
 * @description       : 
 * @author            : Ayan Bhowmik
 * @group             : 
 * @last modified on  : 05-16-2024
 * @last modified by  : Ayan Bhowmik
**/
@IsTest
public with sharing class PortalScorePollingAPITest {
    @TestSetup
    static void makeData(){
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(legalEntityObj,true);

        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);

        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c principalPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        clcommon__Party_Type__c dealerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('DEALER');
        Database.insert(new List<clcommon__Party_Type__c>{clPartyTypeObj, borrowerPartyTypeObj, principalPartyTypeObj, dealerPartyTypeObj},true);

        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c businessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj, businessInfoObj},true);

        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.id);
        dealerAccountObj.Enable_ERP_Id__c = true;
        Account accountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(businessInfoObj.id,dealerAccountObj.id);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Database.insert(new List<Account>{dealerAccountObj, accountObj, clAccountObj},true);

        Contact contactObj = ApplicationOriginationTestHelper.createSalesAgentContact(accountObj.id);
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
        Database.insert(new List<Contact>{contactObj, clContactObj},true);

        User userObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.id);
        Database.insert(userObj,true);
    
        clcommon__Reciprocal_Role__c clRole = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(clRole,true);

        clcommon__Relationship__c clRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(clRole,dealerAccountObj.id,clAccountObj.id);
        Database.insert(clRelationship,true);

        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);

        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        borrowerAccountObj.CIF_Number__c = '123456';
        borrowerAccountObj.Coop_Type__c = 'CFA';
        Database.insert(borrowerAccountObj,true);

        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        borrowerContactObj.genesis__SSN__c = '324242424';
        borrowerContactObj.Confirm_SSN__c = '324242424';
        Database.insert(borrowerContactObj,true);

        genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(coBorrowerBusinessInfoObj,true);

        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(legalEntityObj,coBorrowerBusinessInfoObj.id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        Database.insert(coBorrowerAccountObj,true);

        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        Database.insert(coBorrowerContactObj,true);

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(new Map<String, Id>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'saAccountObjId' => accountObj.id
        });
        applicationObj.genesis__Product_Type__c ='Package';
        applicationObj.genesis__Loan_Amount__c = 82400;
        applicationObj.FICO_Score__c = '600';
        applicationObj.SBSS_70_Score__c = '150';
        Database.insert(applicationObj,true); 

        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => borrowerPartyTypeObj.id,
            'applicationId' => applicationObj.id
        });
        partyObj.clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;

        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
            'accountId' => clAccountObj.id,
            'contactId' => clContactObj.id,
            'partyTypeId' => clPartyTypeObj.id,
            'applicationId' => applicationObj.id
        });

        clcommon__Party__c coPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
            'accountId' => coBorrowerAccountObj.id,
            'contactId' => coBorrowerContactObj.id,
            'partyTypeId' => principalPartyTypeObj.id,
            'applicationId' => applicationObj.id
        });
        coPartyObj.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;
        Database.insert(new List<clcommon__Party__c>{partyObj, clPartyObj, coPartyObj},true);

        CFA_Configuration__c cifObj = ApplicationOriginationTestHelper.createCIFNumber();
        Database.insert(cifObj,true);

        List<genesis__Credit_Rating_Matrix__c> creditMatrixList = FICOCalloutTestHelper.createAllCreditRatingMatrix();
        Database.insert(creditMatrixList, true);
    }
    @isTest
    static void testPollingApiforTierOne(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 82400 AND FICO_Score__c = '600' AND SBSS_70_Score__c = '150' LIMIT 1];
        genesis__Credit_Rating_Matrix__c creditRates = [SELECT Id,Name FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 1' LIMIT 1];
        applicationObj.genesis__Credit_Rating__c = creditRates.Id;
        Database.upsert(applicationObj,false);
        requestMap.put('application', Json.serialize(applicationObj));
        Test.startTest();
        System.runAs(userObj){
            PortalScorePollingAPI callPollingApi = new PortalScorePollingAPI();
            clcommon.Response resp = callPollingApi.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'Assertion Failed'); 
        }
        Test.stopTest();
    }
    @isTest
    static void testPollingApiforNullTier(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 82400 AND FICO_Score__c = '600' AND SBSS_70_Score__c = '150' LIMIT 1];
        requestMap.put('application', Json.serialize(applicationObj));
        Test.startTest();
        System.runAs(userObj){
            PortalScorePollingAPI callPollingApi = new PortalScorePollingAPI();
            clcommon.Response resp = callPollingApi.invokeAction('',new List<String>(), requestMap);
            System.assertEquals('PENDING', resp.status, 'Assertion Failed');
        }
        Test.stopTest(); 
    }
    @isTest
    static void testNullApplicationId(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('application', null);
        Test.startTest();
        System.runAs(userObj){
            PortalScorePollingAPI callPollingApi = new PortalScorePollingAPI();
            clcommon.Response resp = callPollingApi.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(null, resp,'Assertion Failed');
        }
    }
    @isTest
    static void testInvalidUser(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 82400 AND FICO_Score__c = '600' AND SBSS_70_Score__c = '150' LIMIT 1];
        requestMap.put('application', Json.serialize(applicationObj));
        Account clAccountObj = [SELECT Id FROM Account WHERE Name =: 'Ross Geller'];
        Database.delete([SELECT Id FROM clcommon__Party__c WHERE clcommon__Account__c =: clAccountObj.Id], true);
        Test.startTest();
        System.runAs(userObj){
            PortalScorePollingAPI callPollingApi = new PortalScorePollingAPI();
            clcommon.Response resp = callPollingApi.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(null, resp, 'Assertion Failed');
        }
        Test.stopTest(); 
    }
    @isTest
    static void testInvalidApplicationId(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('application', Json.serialize('nmsdbjhf3874923hr'));
        Test.startTest();
        System.runAs(userObj){
            PortalScorePollingAPI callPollingApi = new PortalScorePollingAPI();
            clcommon.Response resp = callPollingApi.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(null, resp, 'Assertion Failed');
        }
        Test.stopTest(); 
    }
}