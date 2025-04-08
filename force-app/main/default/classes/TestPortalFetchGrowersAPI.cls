/**
 * @description       : Test class for PortalFetchGrowersAPI
 * @author            : Rahul Gupta | 26-01-2023
 * @group             : 
 * @last modified on  : 13-02-2025
 * @last modified by  : Soumik Pattanayak
**/
@IsTest
public with sharing class TestPortalFetchGrowersAPI{
    /**
    * @description Test Data Setup
    * @author Shristy Kumari | 01-20-2025 
    **/
    @TestSetup
    static void makeData(){

        // Creating CL Product for application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.Insert(clProductObj,true);

        // Creating CL Purpose for application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.Insert(clPurposeObj, true);

        // Creating legal entities 
        clcommon__Legal_Entity__c individualEntityObj = ApplicationOriginationTestHelper.createIndividualLegalEntity();
        individualEntityObj.Name = 'Individual(s) - Sole Proprietorship';
        Database.Insert(individualEntityObj, true);

        // Creating different Party types
        clcommon__Party_Type__c dealerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.DEALER_PARTY_NAME);
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.CERTIFIED_LENDER);
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);
        Database.Insert(new List<clcommon__Party_Type__c>{dealerPartyTypeObj, clPartyTypeObj, borrowerPartyTypeObj}, true);
        
        // Creating business info for dealer
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        // Creating business information for borrower
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.Insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj, borrowerBusinessInfoObj}, true);

        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.Insert(dealerAccountObj, true);
        //creating accounts
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Account saAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Account saAdminAccountObj = ApplicationOriginationTestHelper.createSAAdminAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(individualEntityObj,borrowerBusinessInfoObj.Id);
        Database.Insert(new List<Account>{clAccountObj, saAccountObj, saAdminAccountObj, borrowerAccountObj}, true);
        //creating contacts
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Contact saContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(saAccountObj.Id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Contact saAdminContactObj=ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccountObj.Id);
        Database.Insert(new List<Contact>{clContactObj, saContactObj, borrowerContactObj, saAdminContactObj}, true);

        Dealer_Applicant_Relationship__c darObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj, dealerAccountObj.Id);
        Database.Insert(darObj, true);

        // Creating Users
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        User saUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(saContactObj.Id);
        User standardUserObj = ApplicationOriginationTestHelper.createStandardUser();
        User saAdminUserObj = ApplicationOriginationTestHelper.createSAAdminUser(saAdminContactObj.Id);
        Database.Insert(new List<User>{clUserObj, saUserObj, standardUserObj, saAdminUserObj}, true);

        // Creating Reciprocal Roles
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.Insert(clRoleObj, true);

        // Creating Relationships
        clcommon__Relationship__c clDealerRealtionshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj,  dealerAccountObj.Id, clAccountObj.Id);
        Database.Insert(clDealerRealtionshipObj, true);

        // Creating Application
        Map<String, Id> applicationDataMap = new Map<String, Id>{
            'dealerAccountObjId' => dealerAccountObj.Id,
            'clProductObjId' => clProductObj.Id,
            'clPurposeObjId' => clPurposeObj.Id,
            'borrowerAccountObjId' => borrowerAccountObj.Id,
            'borrowerContactObjId' => borrowerContactObj.Id,
            'saAccountObjId' => saAccountObj.Id
        };
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(applicationDataMap);
        applicationObj.Dealer_Name__c = dealerAccountObj.Id;
        applicationObj.Certified_Lender__c = clAccountObj.Id;
        applicationObj.Crop_Year__c = '2022';
        applicationObj.genesis__Status__c = 'ACTIVE';
        Database.Insert(applicationObj, true);

        Map<String, Id> borrowerPartyMapData = new Map<String, Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(borrowerPartyMapData);
        Database.Insert(borrowerPartyObj, true);

        // Certified Lender Party
        Map<String, Id> clPartyMapData = new Map<String, Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__party__c clPartyObj = ApplicationOriginationTestHelper.createParty(clPartyMapData);
        Database.Insert(clPartyObj, true);
        
        genesis__Rate_Card_Setup_Header__c rateCardSetupHeaderObj = ApplicationOriginationTestHelper.createRateCardSetupHeader(clAccountObj);
        Database.Insert(rateCardSetupHeaderObj, true);

        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailObj = ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardSetupHeaderObj);
        rateCardSetupDetailObj.Start_Date__c = Date.newInstance(2022, 07, 01);
        rateCardSetupDetailObj.End_Date__c = Date.newInstance(2022, 9, 30);
        Database.Insert(rateCardSetupDetailObj, true);

        genesis__Application_Pricing_Detail__c enabledPricingObj = ApplicationOriginationTestHelper.createEnabledPricingDetail(applicationObj, rateCardSetupDetailObj.Id);
        Database.Insert(enabledPricingObj, true);

        genesis__Rate_Card_Setup_Detail__c newRateCardSetupDetailObj = ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardSetupHeaderObj);
        newRateCardSetupDetailObj.genesis__Interest_Rate__c = 9.5;
        newRateCardSetupDetailObj.Start_Date__c = Date.newInstance(2022, 10, 01);
        newRateCardSetupDetailObj.End_Date__c = Date.newInstance(2022, 12, 31);
        Database.Insert(newRateCardSetupDetailObj, true);
        
        genesis__Application_Pricing_Detail__c disabledPricingObj = ApplicationOriginationTestHelper.createDisabledPricingDetail(applicationObj, newRateCardSetupDetailObj.Id);
        Database.Insert(disabledPricingObj, true);

        genesis__Application_Pricing_Detail__c newEnabledPricingObj = ApplicationOriginationTestHelper.createEnabledPricingDetail(applicationObj, null);
        newEnabledPricingObj.Loan_Number__c = applicationObj.genesis__Loan_Number__c + '-B';
        Database.Insert(newEnabledPricingObj, true);
    }

    /**
    * @description Method to fetch dealer account 
    * @author Shristy Kumari | 01-06-2025 
    * @return Account 
    **/
    private static Account getDealerAccount(){
        List<Account> dealerAccountList = [SELECT Id,
                                                Name
                                            FROM Account 
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];  
            if(dealerAccountList.size() == 1){
                return dealerAccountList[0];
            } 
        return null;
    }

    /**
    * @description Method to fetch CL Account
    * @author Shristy Kumari | 01-06-2025 
    * @return Account 
    **/
    private static Account getClAccount(){
        List<Account> clAccountList = [SELECT Id,
                                                Name,
                                                ParentId,
                                                Parent.Name,
                                                clcommon__Legal_Entity_Type__c,
                                                clcommon__Legal_Entity_Type__r.name
                                        FROM  Account
                                        WHERE name = 'Ross Geller'
                                        LIMIT 1];
                                    
            if(clAccountList.size() == 1){
                return clAccountList[0];
            } 
        return null;
    }

    /**
    * @description Method to fetch the cl user
    * @author Shristy Kumari | 01-14-2025 
    * @param parentAccountId
    * @return User 
    **/
    private static User getClUser(Id parentAccountId){
        List<User> objUserList = [SELECT Id 
                                    FROM User 
                                    WHERE AccountId IN (
                                        SELECT Id 
                                        FROM Account 
                                        WHERE ParentId = :parentAccountId
                                        AND name = 'Ross Geller')
                                    LIMIT 1];          
        if(objUserList.size() == 1){
            return objUserList[0];
        } 
        return null;
    }

    /**
    * @description : Method to test success scenerio for PortalFetchGrowersAPI for CFA dealer
    * @author Shristy Kumari | 01-20-2025 
    **/
    @IsTest
    public static void testPortalFetchGrowerSuccessForCfa(){
        Map<String, Object> requestMap = new Map<String, Object>();
        Account dealerAccountObj = getDealerAccount();
        Account clAccountObj = getClAccount();
        clAccountObj.ParentId = dealerAccountObj.Id;
        Database.Update(clAccountObj, true);
        User clUserObj = getClUser(dealerAccountObj.Id);
        requestMap.put('query', 'Jasmine');
        System.runAs(clUserObj){
            Test.startTest();
            PortalFetchGrowersAPI portalFetchGrowersAPI = new PortalFetchGrowersAPI();
            clcommon.Response response = portalFetchGrowersAPI.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion failed to test PortalFetchGrowersAPI for CFA dealer by cl user.'); 
            Test.stopTest();    
        }
    }

    /**
    * @description : Method to test success scenerio for PortalFetchGrowersAPI for Growmark dealer
    * @author Shristy Kumari | 01-20-2025 
    **/
    @IsTest
    public static void testPortalFetchGrowerSuccessForGrowmark(){
        Map<String, Object> requestMap = new Map<String, Object>();
        Account dealerAccountObj = getDealerAccount();
        dealerAccountObj.Coop_Type__c = 'Growmark';
        Database.Update(dealerAccountObj, true);
        Account clAccountObj = getClAccount();
        clAccountObj.ParentId = dealerAccountObj.Id;
        clAccountObj.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId();
        Database.Update(clAccountObj, true);
        User clUserObj = getClUser(dealerAccountObj.Id);
        requestMap.put('query', 'Ross');
        System.runAs(clUserObj) {
            Test.startTest();
            PortalFetchGrowersAPI portalFetchGrowersAPI = new PortalFetchGrowersAPI();
            clcommon.Response response = portalFetchGrowersAPI.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion failed to test PortalFetchGrowersAPI for Growmark dealer by cl user.'); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test success scenerio for PortalFetchGrowersAPI for Landus dealer
    * @author Shristy Kumari | 01-20-2025 
    **/
    @IsTest
    public static void testPortalFetchGrowerSuccessForLandus(){
        Map<String, Object> requestMap = new Map<String, Object>();
        Account dealerAccountObj = getDealerAccount();
        dealerAccountObj.Coop_Type__c = 'Landus';
        Database.Update(dealerAccountObj, true);
        Account clAccountObj = getClAccount();
        clAccountObj.ParentId = dealerAccountObj.Id;
        clAccountObj.RecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId();
        Database.Update(clAccountObj, true);
        User clUserObj = getClUser(dealerAccountObj.Id);
        requestMap.put('query', 'Ross');
        System.runAs(clUserObj){
            Test.startTest();
            PortalFetchGrowersAPI portalFetchGrowersAPI = new PortalFetchGrowersAPI();
            clcommon.Response response = portalFetchGrowersAPI.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion failed to test PortalFetchGrowersAPI for landus dealer by cl user.'); 
            Test.stopTest();
        }
    }

    /**
    * @description Method to test empty request map exception for PortalFetchGrowersAPI
    * @author Shristy Kumari | 01-21-2025 
    **/
    @IsTest
    public static void testEmptyRequestMapException(){
        Map<String, Object> requestMap = new Map<String, Object>();
        Account dealerAccountObj = getDealerAccount();
        Account clAccountObj = getClAccount();
        clAccountObj.ParentId = dealerAccountObj.Id;
        Database.Update(clAccountObj, true);
        User clUserObj = getClUser(dealerAccountObj.Id);
        System.runAs(clUserObj){
            Test.startTest();
            PortalFetchGrowersAPI portalFetchGrowersAPI = new PortalFetchGrowersAPI();
            clcommon.Response response = portalFetchGrowersAPI.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(PortalConstants.REQUIRED_PARAMETERS_MISSING, response.errorMessage, 'Assertion failed test empty request map exception for PortalFetchGrowersAPI'); 
            Test.stopTest();    
        }
    }

    /**
    * @description : Method to test exception scenerio when parameter is null
    * @author Shristy Kumari | 01-21-2025 
    **/
    @IsTest
    public static void testNullParameterException(){
        Account dealerAccountObj = getDealerAccount();
        Database.Update(dealerAccountObj, true);
        Account clAccountObj = getClAccount();
        clAccountObj.ParentId = dealerAccountObj.Id;
        Database.Update(clAccountObj, true);
        User clUserObj = getClUser(dealerAccountObj.Id);
        System.runAs(clUserObj){
            Test.startTest();
            PortalFetchGrowersAPI portalFetchGrowersAPI = new PortalFetchGrowersAPI();
            clcommon.Response response = portalFetchGrowersAPI.invokeAction('', new List<String>(), null);
            System.assertEquals(PortalConstants.SOMETHING_WENT_WRONG, response.errorMessage, 'Assertion failed  to test exception scenerio when parameter is null.'); 
            Test.stopTest();    
        }
    }

    /**
    * @description : Method to test success scenerio for PortalFetchGrowersAPI for CFA dealer by sales agent user
    * @author Shristy Kumari | 01-20-2025 
    **/
    @IsTest
    public static void testPortalFetchGrowerSuccessBySaUser() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Account dealerAccountObj = getDealerAccount();
        Account salesAgentAccountObj = [SELECT Id,
                                        Name,
                                        ParentId,
                                        Parent.Name,
                                        clcommon__Legal_Entity_Type__c,
                                        clcommon__Legal_Entity_Type__r.name
                                FROM  Account
                                WHERE name = 'Tony Stark'
                                LIMIT 1];
        salesAgentAccountObj.ParentId = dealerAccountObj.Id;
        Database.Update(salesAgentAccountObj, true);
        User saUserObj = [SELECT Id 
                            FROM User 
                            WHERE AccountId IN (
                                SELECT Id 
                                FROM Account 
                                WHERE ParentId = :dealerAccountObj.Id 
                                AND name = 'Tony Stark')
                                LIMIT 1]; 
        requestMap.put('query', 'Jasmine');
        System.runAs(saUserObj){
            Test.startTest();
            PortalFetchGrowersAPI portalFetchGrowersAPI = new PortalFetchGrowersAPI();
            clcommon.Response response = portalFetchGrowersAPI.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion failed to test success scenerio for PortalFetchGrowersAPI for CFA dealer by sales agent user'); 
            Test.stopTest();    
        }
    }
    /**
    * @description : Method to test success scenerio for PortalFetchGrowersAPI for CFA dealer by sales agent admin
    * @author Shristy Kumari | 01-20-2025 
    **/
    @IsTest
    public static void testPortalFetchGrowerSuccessBySaAdmin(){
        Map<String, Object> requestMap = new Map<String, Object>();
        Account dealerAccountObj = getDealerAccount();
        Account saAdminAccountObj = [SELECT Id,
                                        Name,
                                        ParentId,
                                        Parent.Name,
                                        clcommon__Legal_Entity_Type__c,
                                        clcommon__Legal_Entity_Type__r.name
                                FROM  Account
                                WHERE name = 'Tim Couper'
                                LIMIT 1];
        saAdminAccountObj.ParentId = dealerAccountObj.Id;
        Database.Update(saAdminAccountObj, true);
        User saAdminUserObj = [SELECT Id 
                                FROM User 
                                WHERE AccountId IN (
                                                SELECT Id 
                                                FROM Account 
                                                WHERE ParentId = :dealerAccountObj.Id
                                                AND name = 'Tim Couper')
                                                LIMIT 1]; 
        requestMap.put('query', 'Jasmine');
        System.runAs(saAdminUserObj){
            Test.startTest();
            PortalFetchGrowersAPI portalFetchGrowersAPI = new PortalFetchGrowersAPI();
            clcommon.Response response = portalFetchGrowersAPI.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion failed to test success scenerio for PortalFetchGrowersAPI for CFA dealer by sales agent admin.'); 
            Test.stopTest();    
        }
    }

    /**
    * @description : Method to test success scenerio for PortalFetchGrowersAPI for CFA dealer by standard user
    * @author Shristy Kumari | 01-20-2025 
    **/
    @IsTest
    public static void testPortalFetchGrowerByStandardUser(){
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('query', 'Jasmine');
        User standardUserObj = [SELECT Id 
                                FROM User 
                                WHERE UserName='std.user@yopmail.com'
                                LIMIT 1];
        System.runAs(standardUserObj){
            Test.startTest();
            PortalFetchGrowersAPI portalFetchGrowersAPI = new PortalFetchGrowersAPI();
            clcommon.Response response = portalFetchGrowersAPI.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion failed to test success scenerio for PortalFetchGrowersAPI for CFA dealer by standard user.'); 
            Test.stopTest();    
        }
    }
    /**
    * @description : Method to test success scenerio for PortalFetchGrowersAPI for Growmark dealer by sales agent
    * @author Shristy Kumari | 01-20-2025 
    **/
    @IsTest
    public static void testByGrowmarkSaUser() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Account dealerAccountObj = getDealerAccount();
        dealerAccountObj.Coop_Type__c = 'Growmark';
        Database.Update(dealerAccountObj, true);
        Account salesAgentAccountObj = [SELECT Id,
                                        Name,
                                        ParentId,
                                        Parent.Name,
                                        clcommon__Legal_Entity_Type__c,
                                        clcommon__Legal_Entity_Type__r.name
                                FROM  Account
                                WHERE name = 'Tony Stark'
                                LIMIT 1];
        salesAgentAccountObj.ParentId = dealerAccountObj.Id;
        Database.Update(salesAgentAccountObj, true);
        User saUserObj = [SELECT Id 
                            FROM User 
                            WHERE AccountId IN (
                                SELECT Id 
                                FROM Account 
                                WHERE ParentId = :dealerAccountObj.Id 
                                AND name = 'Tony Stark')
                                LIMIT 1]; 
        requestMap.put('query', 'Jasmine');
        System.runAs(saUserObj){
            Test.startTest();
            PortalFetchGrowersAPI portalFetchGrowersAPI = new PortalFetchGrowersAPI();
            clcommon.Response response = portalFetchGrowersAPI.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion failed to test success scenerio for PortalFetchGrowersAPI for Growmark dealer by sales agent.'); 
            Test.stopTest();    
        }
    }
    /**
    * @description : Method to test success scenerio for PortalFetchGrowersAPI for growmark dealer by sales agent admin
    * @author Shristy Kumari | 01-20-2025 
    **/
    @IsTest
    public static void testByGrowmarkSaAdmin(){
        Map<String, Object> requestMap = new Map<String, Object>();
        Account dealerAccountObj = getDealerAccount();
        dealerAccountObj.Coop_Type__c = 'Growmark';
        Database.Update(dealerAccountObj, true);
        Account saAdminAccountObj = [SELECT Id,
                                        Name,
                                        ParentId,
                                        Parent.Name,
                                        clcommon__Legal_Entity_Type__c,
                                        clcommon__Legal_Entity_Type__r.name
                                FROM  Account
                                WHERE name = 'Tim Couper'
                                LIMIT 1];
        saAdminAccountObj.ParentId = dealerAccountObj.Id;
        Database.Update(saAdminAccountObj, true);
        User saAdminUserObj = [SELECT Id 
                                FROM User 
                                WHERE AccountId IN (
                                                SELECT Id 
                                                FROM Account 
                                                WHERE ParentId = :dealerAccountObj.Id
                                                AND name = 'Tim Couper')
                                                LIMIT 1]; 
        requestMap.put('query', 'Jeny');
        System.runAs(saAdminUserObj){
            Test.startTest();
            PortalFetchGrowersAPI portalFetchGrowersAPI = new PortalFetchGrowersAPI();
            clcommon.Response response = portalFetchGrowersAPI.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion failed to to test success scenerio for PortalFetchGrowersAPI for growmark dealer by sales agent admin.'); 
            Test.stopTest();    
        }
    }
}