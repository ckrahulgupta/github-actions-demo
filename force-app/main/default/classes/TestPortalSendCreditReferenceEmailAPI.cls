/**
 * @description       : Test class for PortalSendCreditReferenceEmailAPI
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 01-24-2025
 * @last modified by  : Rakesh Saraf
**/

@isTest
global without sharing class TestPortalSendCreditReferenceEmailAPI {

    @TestSetup
    static void makeData(){
        // Creating floating rate index
        clcommon__Floating_Rate_Index__c floatingRateIndexObj = ApplicationOriginationTestHelper.createFloatingRateIndex(
            New Map<String, Object>{ 'Name' => 'CFA Advantage Rate',
                                        'Base Rate Name' => '4-CFA ADVANTAGE',
                                        'Current Floating Rate' => 11,
                                        'Base Rate Adjuster' => 5.5
        });
        Database.insert(floatingRateIndexObj, true);

        // Creating floating rate
        clcommon__Floating_Rate__c floatingRateObj = ApplicationOriginationTestHelper.createFloatingRate(floatingRateIndexObj);
        Database.insert(floatingRateObj, true);

        // Creating new partner program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);

        //creating a new business info record
        genesis__Business_Information__c businessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoObj,true);

        //creating dealer account
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoObj.id, newPartnerProgramObj.id);

        //creating a new cl product
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProduct();
        Database.insert(clProductObj,true);

        //creating a new cl purpose
        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);

        //creating individual sole prop legal entity
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();

        //creating a corporation legal entity
        clcommon__Legal_Entity__c corpLegalEntityObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(new List<clcommon__Legal_Entity__c>{legalEntityObj,corpLegalEntityObj},true);

        //creating business info for borrower
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);

        //creating the borrower account
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.insert(new List<Account>{dealerAccountObj,borrowerAccountObj},true);

        //creating a borrower contact
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);

        //creating a new sales agent account
        Account accountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(businessInfoObj.id,dealerAccountObj.id);
        Database.insert(accountObj,true);

        //creating a sales agent contact
        Contact contactObj = ApplicationOriginationTestHelper.createSalesAgentContact(accountObj.id);

        //creating a new sales agent admin account
        Account saAdminAccountObj = ApplicationOriginationTestHelper.createSAAdminAccount(businessInfoObj.id,dealerAccountObj.id);
        Database.insert(saAdminAccountObj,true);

        //creating a sales agent admin contact
        Contact saAdminContactObj = ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccountObj.id);

        //creating a cl account
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInfoObj.id,dealerAccountObj.id);
        Database.insert(clAccountObj,true);

        //creating the cl contact
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
        Database.insert(new List<Contact>{borrowerContactObj,contactObj,clContactObj,saAdminContactObj},true);

        //creating various users
        User borrowerUser = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.id);
        User clUser = ApplicationOriginationTestHelper.createCLUser(clContactObj.id);
        User saAdminUser = ApplicationOriginationTestHelper.createSAAdminUser(saAdminContactObj.id);
        User userObj = ApplicationOriginationTestHelper.createSalesAgentUser(contactObj.id);

        //inserting the users in the db
        Database.insert(new List<User>{borrowerUser,userObj,clUser,saAdminUser},true);

        //creating an application data map
        Map<String,Object> applicationDataMap = new Map<String,Object>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'saAccountObjId' => accountObj.id
        };

        //creating a new application
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(applicationDataMap);
        applicationObj.Sales_Agent__C = accountObj.id;
        applicationObj.Dealer_Name__c = dealerAccountObj.id;
        applicationObj.Internal_Reference_Code__c = '12131313';

        //creating a new Dealer Applicant Relationship for the Application
        Dealer_Applicant_Relationship__c dealerGrowerRelation = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.id);
        Database.insert(dealerGrowerRelation,true);

        //updating the dealer applicant look up on the application
        applicationObj.Dealer_Applicant_Relationship__c=dealerGrowerRelation.id;
        Database.insert(applicationObj,true);

        //creating various party type
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        clcommon__Party_Type__c saAdminPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('SALES AGENT ADMIN');
        clcommon__Party_Type__c prPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        clcommon__Party_Type__c boPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c saPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('SALES AGENT');

        Database.insert(new List<clcommon__Party_Type__c>{clPartyTypeObj,prPartyTypeObj,boPartyTypeObj,saPartyTypeObj,saAdminPartyTypeObj},true);

        //creating the sales agent party and the borrower party of the application
        Map<String,Id> partyParamMap = new Map<String,Id>{
            'accountId' => accountObj.id,
            'contactId' => contactObj.id,
            'partyTypeId' => saPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c saPartyObj = ApplicationOriginationTestHelper.createParty(partyParamMap);

        Map<String,Id> clPartyParamMap = new Map<String,Id>{
            'accountId' => clAccountObj.id,
            'contactId' => clContactObj.id,
            'partyTypeId' => clPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(clPartyParamMap);

        Map<String,Id> borrowerPartyParamMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => boPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(borrowerPartyParamMap);
        borrowerPartyObj.Dealer_Applicant_Relationship__c=dealerGrowerRelation.id;
        borrowerPartyObj.State__c='PH';
        borrowerPartyObj.City__c='Philadelphia';

        Map<String,Id> saAdminPartyTypeMap = new Map<String,Id>{
            'accountId' => saAdminAccountObj.id,
            'contactId' => saAdminContactObj.id,
            'partyTypeId' => saAdminPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c saAdminPartyObj = ApplicationOriginationTestHelper.createParty(saAdminPartyTypeMap);

        Database.insert(new List<clcommon__Party__c>{saPartyObj,borrowerpartyObj,saAdminPartyObj,clPartyObj},true);
    }

    /**
    * @description method to get the application
    * @author Rakesh Saraf | 01-13-2025 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c getApplication(){
        return [SELECT Id,
                        Internal_Reference_Code__c
                FROM genesis__Applications__c
                LIMIT 1][0];
    }

    /**
    * @description method to get the cl account
    * @author Rakesh Saraf | 01-13-2025 
    * @return Account 
    **/
    private static Account getCLAccount(){
        return [SELECT Id
                FROM Account
                WHERE Name='Ross Geller'
                LIMIT 1][0];
    }
    
    /**
    * @description method to get the sa user
    * @author Rakesh Saraf | 01-13-2025 
    * @return User 
    **/
    private static User getSalesAgentUser(){
        return [SELECT ID,contactId
                FROM User
                WHERE UserName='tony.stark@yopmail.com'
                LIMIT 1][0];
    }

    /**
    * @description test for default success
    * @author Rakesh Saraf | 11-22-2024 
    **/
    @isTest
    public static void testDefaultSuccess() {
        Map<String, Object> requestMap = new Map<String, Object>();
        
        genesis__Applications__c applicationObj=getApplication();

        Account clAccount=getCLAccount();

        User saUser=getSalesAgentUser();

        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('accountId', clAccount.Id);
        System.runAs(saUser) {
            Test.startTest();
                //Calling the API
                PortalSendCreditReferenceEmailAPI saveApi = new PortalSendCreditReferenceEmailAPI();
                clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description test case for when the borrower is a corporation
    * @author Rakesh Saraf | 11-22-2024 
    **/
    @isTest
    public static void testDefaultSuccessForCorp() {
        Map<String, Object> requestMap = new Map<String, Object>();
        
        genesis__Applications__c applicationObj=getApplication();

        Account clAccount=getCLAccount();

        List<clcommon__Legal_Entity__c> entityList = [SELECT Id
                                                    FROM clcommon__Legal_Entity__c
                                                    WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'];
        entityList[0].clcommon__Legal_Entity_Type__c = 'Corporation';
        entityList[0].Name = 'Corporation';
        Database.update(entityList, true);

        User saUser=getSalesAgentUser();

        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('accountId', clAccount.Id);
        Test.startTest();
        System.runAs(saUser) {
            //Calling the API
            PortalSendCreditReferenceEmailAPI saveApi = new PortalSendCreditReferenceEmailAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }

    /**
    * @description test case for when the cl contact is missing
    * @author Rakesh Saraf | 11-22-2024 
    **/
    @isTest
    public static void testCLContactMissingException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        
        genesis__Applications__c applicationObj=getApplication();

        Account clAccount=getCLAccount();

        List<Contact> clContactList=[ SELECT Id,
                                   Email
                            FROM Contact
                            WHERE LastName='Geller'
                            LIMIT 1];
        clContactList[0].Email=null;
        Database.update(clContactList,true);

        User saUser=getSalesAgentUser();

        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('accountId', clAccount.Id);
        Test.startTest();
        System.runAs(saUser) {
            //Calling the API
            PortalSendCreditReferenceEmailAPI saveApi = new PortalSendCreditReferenceEmailAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }

    /**
    * @description test for when nothing is sent from the portal
    * @author Rakesh Saraf | 11-22-2024 
    **/
    @isTest
    public static void testParameterMissingException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<Profile> profile = [SELECT Id FROM Profile WHERE Name='Sales Agent'];

        User userObj = IntegrationTestInitHelper.createUser(profile[0].Id);
        Test.startTest();
        System.runAs(userObj) {
            //Calling the API
            PortalSendCreditReferenceEmailAPI saveApi = new PortalSendCreditReferenceEmailAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }

    /**
    * @description test case for when the dealer applicant relationship does not have the city and state
    * @author Rakesh Saraf | 11-22-2024 
    **/
    @isTest
    public static void testMissingDealerApplicantRelDetails() {
        Map<String, Object> requestMap = new Map<String, Object>();
        
        genesis__Applications__c applicationObj=getApplication();

        Account clAccount=getCLAccount();

        User saUser=getSalesAgentUser();

        List<clcommon__Party__c> borrowerPrtyList=[SELECT Id,
                                                          City__c,
                                                          State__c
                                                    FROM clcommon__Party__c
                                                    WHERE clcommon__Party_Types__c =: 'BORROWER'
                                                    LIMIT 1];
        borrowerPrtyList[0].city__c=null;
        borrowerPrtyList[0].State__c=null;
        Database.update(borrowerPrtyList,true);

        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('accountId', clAccount.Id);
        Test.startTest();
        System.runAs(saUser) {
            //Calling the API
            PortalSendCreditReferenceEmailAPI saveApi = new PortalSendCreditReferenceEmailAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }

    /**
    * @description test for when we do not send an account id as arg from the portal
    * @author Rakesh Saraf | 11-22-2024 
    **/
    @isTest
    public static void testMissingAccountId() {
        Map<String, Object> requestMap = new Map<String, Object>();
        
        genesis__Applications__c applicationObj=getApplication();

        User saUser=getSalesAgentUser();

        requestMap.put('applicationId', applicationObj.Id);

        Test.startTest();
        System.runAs(saUser) {
            //Calling the API
            PortalSendCreditReferenceEmailAPI saveApi = new PortalSendCreditReferenceEmailAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    
    /**
    * @description test for sa admin log in
    * @author Rakesh Saraf | 11-22-2024 
    **/
    @isTest
    public static void testSAAdminLogin() {
        Map<String, Object> requestMap = new Map<String, Object>();
        
        genesis__Applications__c applicationObj=getApplication();

        applicationObj.Internal_Reference_Code__c=null;
        Database.update(applicationObj,true);

        Account clAccount=getCLAccount();
                                                                    
        List<User> saAdminUser=[SELECT ID,contactId
                                FROM User
                                WHERE UserName='tim.couper@yopmail.com'
                                LIMIT 1];

        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('accountId', clAccount.Id);

        Test.startTest();
        System.runAs(saAdminUser[0]) {
            //Calling the API
            PortalSendCreditReferenceEmailAPI saveApi = new PortalSendCreditReferenceEmailAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    
}