/**
 * @description       : Test class for PortalApplicationStatusCountAPI
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 03-12-2024
 * @last modified by  : Ayush Kumar Singh
**/

@isTest
public with sharing class TestPortalApplicationStatusCountAPI {

    @testSetup
    static void setup() {

        // Creating CIF number
        CFA_Configuration__c cfaConfig = ApplicationOriginationTestHelper.createCIFNumber();
        Database.Insert(cfaConfig, true);

        // Creating CL Product for application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.Insert(clProductObj,true);

        // Creating CL Purpose for application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.Insert(clPurposeObj, true);

        // Creating business information for dealer
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.Insert(dealerBusinessInfoObj,true);

        // Creating business information for borrower
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.Insert(borrowerBusinessInfoObj, true);

        // Creating Accounts
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.Insert(dealerAccountObj, true);

        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.Insert(clAccountObj, true);

        // Creating Contacts
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.Insert(clContactObj, true);

        // Creating party types
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.CL_PARTY_NAME);
        Database.Insert(clPartyTypeObj, true);

        // Creating Reciprocal Roles
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.Insert(clRoleObj, true);

        // Creating Relationships
        clcommon__Relationship__c clDealerRealtionshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj, 
                                                                                                                    dealerAccountObj.Id, 
                                                                                                                    clAccountObj.Id);
        Database.Insert(clDealerRealtionshipObj, true);

        // Creating Users
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        Database.Insert(clUserObj, true);

        List<clcommon__Party__c> objPartyList = new List<clcommon__Party__c>();

        Map<String, Id> applicationDataMap = new Map<String, Id>{
            'dealerAccountObjId' => dealerAccountObj.Id,
            'clProductObjId' => clProductObj.Id,
            'clPurposeObjId' => clPurposeObj.Id,
            'clAccountObjId' => clAccountObj.Id
        };
        
        {

            genesis__Applications__c objApplication = TestPortalApplicationStatusCountAPI.createApplication(applicationDataMap, 'NEW - ENTERED', '');
            Map<String, Id> createPartyDataMap = new Map<String, Id>{
                'accountId' => clAccountObj.Id, 
                'contactId' => clContactObj.Id, 
                'applicationId' => objApplication.Id, 
                'partyTypeId' => clPartyTypeObj.Id
            };
            objPartyList.add(ApplicationOriginationTestHelper.createParty(createPartyDataMap));
        }
        {
            
            genesis__Applications__c objApplication = TestPortalApplicationStatusCountAPI.createApplication(applicationDataMap, 'SIGNATURE PENDING', 'Email - Docusign');
            Map<String, Id> createPartyDataMap = new Map<String, Id>{
                'accountId' => clAccountObj.Id, 
                'contactId' => clContactObj.Id, 
                'applicationId' => objApplication.Id, 
                'partyTypeId' => clPartyTypeObj.Id
            };
            objPartyList.add(ApplicationOriginationTestHelper.createParty(createPartyDataMap));
        }
        {
            
            genesis__Applications__c objApplication = TestPortalApplicationStatusCountAPI.createApplication(applicationDataMap, 'SIGNATURE PENDING', 'Paper - Scanned');
            Map<String, Id> createPartyDataMap = new Map<String, Id>{                
                'accountId' => clAccountObj.Id, 
                'contactId' => clContactObj.Id, 
                'applicationId' => objApplication.Id, 
                'partyTypeId' => clPartyTypeObj.Id
            };
            objPartyList.add(ApplicationOriginationTestHelper.createParty(createPartyDataMap));
        }
        {
            
            genesis__Applications__c objApplication = TestPortalApplicationStatusCountAPI.createApplication(applicationDataMap, 'SIGNATURE COMPLETED', 'Email - Docusign');
            Map<String, Id> createPartyDataMap = new Map<String, Id>{
                'accountId' => clAccountObj.Id,                 
                'contactId' => clContactObj.Id, 
                'applicationId' => objApplication.Id, 
                'partyTypeId' => clPartyTypeObj.Id
            };
            objPartyList.add(ApplicationOriginationTestHelper.createParty(createPartyDataMap));
        }
        {
            
            genesis__Applications__c objApplication = TestPortalApplicationStatusCountAPI.createApplication(applicationDataMap, 'WITHDRAWN', 'In Person - Docusign');
            Map<String, Id> createPartyDataMap = new Map<String, Id>{
                'accountId' => clAccountObj.Id, 
                'contactId' => clContactObj.Id,                 
                'applicationId' => objApplication.Id, 
                'partyTypeId' => clPartyTypeObj.Id
            };
            objPartyList.add(ApplicationOriginationTestHelper.createParty(createPartyDataMap));
        }
        {
            
            genesis__Applications__c objApplication = TestPortalApplicationStatusCountAPI.createApplication(applicationDataMap, 'BOOKED TO CORE', 'Email - Docusign');
            Map<String, Id> createPartyDataMap = new Map<String, Id>{
                'accountId' => clAccountObj.Id, 
                'contactId' => clContactObj.Id, 
                'applicationId' => objApplication.Id,                 
                'partyTypeId' => clPartyTypeObj.Id
            };
            objPartyList.add(ApplicationOriginationTestHelper.createParty(createPartyDataMap));
        }
        {
            
            genesis__Applications__c objApplication = TestPortalApplicationStatusCountAPI.createApplication(applicationDataMap, 'EXPIRED', 'Email - Docusign');
            Map<String, Id> createPartyDataMap = new Map<String, Id>{
                'accountId' => clAccountObj.Id, 
                'contactId' => clContactObj.Id, 
                'applicationId' => objApplication.Id, 
                'partyTypeId' => clPartyTypeObj.Id            };
            objPartyList.add(ApplicationOriginationTestHelper.createParty(createPartyDataMap));
        }
        {
            
            genesis__Applications__c objApplication = TestPortalApplicationStatusCountAPI.createApplication(applicationDataMap, 'NEW-SUBMITTED', 'In Person - Docusign');
            Map<String, Id> createPartyDataMap = new Map<String, Id>{
                'accountId' => clAccountObj.Id, 
                'contactId' => clContactObj.Id, 
                'applicationId' => objApplication.Id, 
                'partyTypeId' => clPartyTypeObj.Id
            };            
            objPartyList.add(ApplicationOriginationTestHelper.createParty(createPartyDataMap));
        }

        {
            
            genesis__Applications__c objApplication = TestPortalApplicationStatusCountAPI.createApplication(applicationDataMap, 'NEW - SCORECARD GENERATED', 'In Person - Docusign');
            Map<String, Id> createPartyDataMap = new Map<String, Id>{
                'accountId' => clAccountObj.Id, 
                'contactId' => clContactObj.Id, 
                'applicationId' => objApplication.Id, 
                'partyTypeId' => clPartyTypeObj.Id
            };
            objPartyList.add(ApplicationOriginationTestHelper.createParty(createPartyDataMap));        
        }

        Database.Insert(objPartyList, true);
    }

    /**
     * @description This method create and return a new application
     * @param applicationDataMap 
     * @param status 
     * @param signingMethod 
     * @return  `genesis__Applications__c`
     */
    public static genesis__Applications__c createApplication(Map<String, Id> applicationDataMap, String status, String signingMethod){

        genesis__Applications__c objApplication = ApplicationOriginationTestHelper.createApplication(applicationDataMap);
        objApplication.genesis__Status__c = status;
        objApplication.Signing_Method__c = signingMethod;
        Database.Insert(objApplication, true);
        return objApplication;
    }
    @isTest
    public static void testApplicationStatusCountAPISuccess() {

        User clUser;
        // Fetching user
        List<User> clUserList = [SELECT Id, Name, AccountId, Account.ParentId, UserName
                                FROM USER 
                                WHERE UserName = 'ross.geller@yopmail.com'
                                LIMIT 1];
        for(User user : clUserList){
            clUser = user;
        }

        Test.startTest();
        System.runAs(clUser) {
            //Calling the API
            PortalApplicationStatusCountAPI saveApi = new PortalApplicationStatusCountAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), new Map<String, Object>());
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
        }
        Test.stopTest();
    } 
}