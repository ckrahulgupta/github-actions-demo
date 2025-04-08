/**
 * @description       : Test Class for PortalDealerPersonalizeControllerExt
 * @author            : Rahul Gupta | 22-04-2022
 * @group             : 
 * @last modified on  : 08-21-2024
 * @last modified by  :  Pritam Roy
**/
@isTest
public class TestPortalDealerPersonalizeControllerExt {

    /**
    * @description : Test Setup
    * @author  Pritam Roy | 05-30-2024 
    **/
    @TestSetup
    static void makeData(){
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(legalEntityObj,true);

        clcommon__Legal_Entity__c legalEntityDbaObj  = ApplicationOriginationTestHelper.createDBALegalEntity();
        Database.insert(legalEntityDbaObj,true);

        clcommon__Legal_Entity__c legalEntityCorpObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(legalEntityCorpObj,true);

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
        applicationObj.FICO_Score__c = '680';
        applicationObj.SBSS_70_Score__c = '160';
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
    // providing all valid inputs
    @isTest
    public static void testPortalDealerController() {

        // genesis__Business_Information__c dealerBusinessInformation = new genesis__Business_Information__c(
        //                                                                     genesis__Business_Country__c='India'
        //                                                                 );
        // Database.insert(dealerBusinessInformation);

        // Account dealerAccount = new Account(
        //                     Name='Test Dealer'
        //                 );
        // Database.insert(dealerAccount);
       
        // // creating user for certified lender
        // Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User clUser = [SELECT Id,contactId FROM user WHERE username = 'ross.geller@yopmail.com'];
        // Contact clUserContact = [SELECT Id, AccountId FROM Contact WHERE Id = :clUser.ContactId];
        // Account clUserAccount = [SELECT Id, Name FROM Account WHERE Id = :clUserContact.AccountId];

        // clUserAccount.ParentId = dealerAccount.Id;
        // clUserAccount.Coop_Type__c = 'CFA';

        // Database.update(clUserAccount);

        // clcommon__Reciprocal_Role__c role = new clcommon__Reciprocal_Role__c(Name='Certified Lender');
        // Database.insert(role, false);
        // clcommon__Relationship__c relationship = new clcommon__Relationship__c(clcommon__Entity__c = dealerAccount.Id, clcommon__Related_Entity__c = clUserAccount.Id ,clcommon__Relationship__c = role.Id);
        // Database.insert(relationship , false);

        System.runAs(clUser) {
            Test.startTest();

            PortalDealerPersonalizeControllerExt objPersonalizeControllerExt = new PortalDealerPersonalizeControllerExt(null);

            Object result = PortalDealerPersonalizeControllerExt.getCoopTypeFromLoggedInUser();
            System.assertNotEquals(true, result != null, 'Assertion Failed'); 

            Test.stopTest();
        }
    }
    @isTest
    public static void testCase2() {

        genesis__Business_Information__c dealerBusinessInformation = new genesis__Business_Information__c(
                                                                            genesis__Business_Country__c='India'
                                                                        );
        Database.insert(dealerBusinessInformation);

        Account dealerAccount = new Account(
                            Name='Test Dealer',
                            Coop_Type__c='CFA'
                        );
        Database.insert(dealerAccount);
       
        // creating user for certified lender
        RecordType clRecordType = [SELECT ID FROM RecordType WHERE Name = 'Payment Administrator'];
        Profile profile = [SELECT Id FROM Profile WHERE Name='Payment Administrator'];
        User clUser = IntegrationTestInitHelper.createUser(profile.Id);
        Contact clUserContact = [SELECT Id, AccountId FROM Contact WHERE Id = :clUser.ContactId];
        Account clUserAccount = [SELECT Id, RecordTypeId, RecordType.name, Name FROM Account WHERE Id = :clUserContact.AccountId];

        clUserAccount.ParentId = dealerAccount.Id;
        clUserAccount.Coop_Type__c = 'CFA';
        clUserAccount.RecordTypeID = clRecordType.Id;
        System.debug(clUserAccount.RecordType);

        Database.update(clUserAccount);

        clcommon__Reciprocal_Role__c role = new clcommon__Reciprocal_Role__c(Name='Payment Administrator');
        Database.insert(role, false);
        clcommon__Relationship__c relationship = new clcommon__Relationship__c(clcommon__Entity__c = dealerAccount.Id, clcommon__Related_Entity__c = clUserAccount.Id ,clcommon__Relationship__c = role.Id);
        Database.insert(relationship , false);

        System.runAs(clUser) {
            Test.startTest();

            PortalDealerPersonalizeControllerExt objPersonalizeControllerExt = new PortalDealerPersonalizeControllerExt(null);

            Object result = PortalDealerPersonalizeControllerExt.getCoopTypeFromLoggedInUser();
            System.assertEquals(result, 'CFA', 'Assertion Failed'); 

            Test.stopTest();
        }
    }
    @isTest
    public static void testCase3() {
        String coop = 'cfa';
        Test.startTest();
        PageReference pageRef = Page.growerLogin;
        pageRef.getParameters().put('coop', coop);
        Test.setCurrentPage(pageRef);
        String res = PortalDealerPersonalizeControllerExt.getCoopTypeFromURL();
        System.assertEquals(coop, res, 'Assertion Failed');
    }
}