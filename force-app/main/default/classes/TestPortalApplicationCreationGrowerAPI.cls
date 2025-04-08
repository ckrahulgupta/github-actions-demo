/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 01-13-2025
 * @last modified by  : Rakesh Saraf
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   19-07-2023   Subham Nandi   Initial Version
**/
@isTest
public with sharing class TestPortalApplicationCreationGrowerAPI {
    @testSetup
    static void setup(){
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        clcommon__Party_Type__c saPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('SALES AGENT');
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c principalPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        Database.insert(new List<clcommon__Party_Type__c>{saPartyTypeObj,borrowerPartyTypeObj,principalPartyTypeObj},true);

        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        clcommon__Legal_Entity__c corpLegalEntityObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
        clcommon__Legal_Entity__c dbaLegalEntityObj  = ApplicationOriginationTestHelper.createDBALegalEntity();
        Database.insert(new List<clcommon__Legal_Entity__c>{legalEntityObj,corpLegalEntityObj,dbaLegalEntityObj},true);
        
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj,borrowerBusinessInfoObj},true);

        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.id);
        dealerAccountObj.CIF_Number__c = PortalConstants.LANDUS_DEALER_CIF;
        Database.insert(dealerAccountObj,true);

        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Account saAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.insert(new List<Account>{clAccountObj,saAccountObj,borrowerAccountObj},true);

        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
        Contact saContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(saAccountObj.id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        Database.insert(new List<Contact>{clContactObj,saContactObj,borrowerContactObj},true);


        User userObj = ApplicationOriginationTestHelper.createCLUser(borrowerContactObj.id);
        Database.insert(userObj,true);

        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        clcommon__Reciprocal_Role__c saRoleObj = ApplicationOriginationTestHelper.createSalesAgentRole();
        clcommon__Reciprocal_Role__c clPlusRole = ApplicationOriginationTestHelper.createCertifiedLenderPlusRole();
        clcommon__Reciprocal_Role__c iqRole = ApplicationOriginationTestHelper.createInquiryRole();
        clcommon__Reciprocal_Role__c iqPlusRole = ApplicationOriginationTestHelper.createInquiryPlusRole();
        clcommon__Reciprocal_Role__c fsaRole = ApplicationOriginationTestHelper.createReciprocalRole('Field Staff Agent');
        Database.insert(new List<clcommon__Reciprocal_Role__c>{fsaRole,clRoleObj,saRoleObj,clPlusRole,iqRole,iqPlusRole},true);

        clcommon__Relationship__c clRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj,dealerAccountObj.id,clAccountObj.id);
        Database.insert(clRelationshipObj,true);

        Account clPlusAccountObj = ApplicationOriginationTestHelper.createCLPlusAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Account iqAccountObj = ApplicationOriginationTestHelper.createInquiryAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Account iqPlusAccountObj = ApplicationOriginationTestHelper.createInquiryPlusAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Account fsaAccount = ApplicationOriginationTestHelper.createFSAgentAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);

        Database.insert(new List<Account>{clPlusAccountObj,iqAccountObj,iqPlusAccountObj,fsaAccount},true);

        Contact clPlusContactObj = ApplicationOriginationTestHelper.createCLPlusContact(clPlusAccountObj.id);
        Contact iqContactObj = ApplicationOriginationTestHelper.createInquiryContact(iqAccountObj.id);
        Contact iqPlusContactObj = ApplicationOriginationTestHelper.createInquiryPlusContact(iqPlusAccountObj.id);
        Contact fsaContact = ApplicationOriginationTestHelper.createFSAgentContact(fsaAccount.id);
        Database.insert(new List<Contact>{clPlusContactObj,iqContactObj,iqPlusContactObj,fsaContact},true);

        CFA_Configuration__c cfaConfig = ApplicationOriginationTestHelper.createCIFNumber();
        Database.insert(cfaConfig,true);

        clcommon__Relationship__c clPlusRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(clPlusRole,dealerAccountObj.id,clPlusAccountObj.id);
        clcommon__Relationship__c iqRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(iqRole,dealerAccountObj.id,iqAccountObj.id);
        clcommon__Relationship__c iqPlusRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(iqPlusRole,dealerAccountObj.id,iqPlusAccountObj.id);
        clcommon__Relationship__c fsaRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(fsaRole,dealerAccountObj.id,fsaAccount.id);
        Database.insert(new List<clcommon__Relationship__c>{clPlusRelationship,iqRelationship,iqPlusRelationship,fsaRelationship},true);
        
    }


    /**
    * @description test for sole prop applicationc creation
    * @author Rakesh Saraf | 12-23-2024 
    **/
    @isTest 
    public static void testSolePropApplicationCreation() {
        Map<String, Object> requestMap = new Map<String, Object>();

        List<Account> accountList = [SELECT Id FROM Account WHERE RecordType.Name = 'Grower'];
        
        List<Contact> contactList = [SELECT Id FROM Contact WHERE AccountId =: accountList[0].id];
        
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id FROM clcommon__Legal_Entity__c WHERE Name = :PortalConstants.SOLE_PROP_ENTITY];

        List<User> userList = [SELECT Id FROM User WHERE ContactId =: contactList[0].id];

        Map<String,Object> applicationMap = new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };

        Map<String,Object> primaryApplicantAccMap = new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id
        };

        Map<String,Object> primaryApplicantBIMap = new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000
        };

        requestMap.put('application', JSON.serialize(applicationMap));
        requestMap.put('dealerCIF', PortalConstants.LANDUS_DEALER_CIF);
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(primaryApplicantBIMap));
        requestMap.put('shouldValidate', 'newApplicant');
        Test.startTest();
        System.runAs(userList[0]) {
            PortalApplicationCreationGrowerAPI testApi = new PortalApplicationCreationGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application Creation Failed');
        }
        Test.stopTest();
    }


    /**
    * @description create a new application for a corporation
    * @author Rakesh Saraf | 12-23-2024 
    **/
    @isTest 
    public static void testCorporationApplicationCreation() {
        Map<String, Object> requestMap = new Map<String, Object>();
        
        List<Account> accountList = [SELECT Id FROM Account WHERE RecordType.Name = 'Grower'];
        
        List<Contact> contactList = [SELECT Id FROM Contact WHERE AccountId =: accountList[0].id];
        
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id FROM clcommon__Legal_Entity__c WHERE Name = :PortalConstants.CORPORATION];
        
        List<User> userList = [SELECT Id FROM User WHERE ContactId =: contactList[0].id];

        Map<String,Object> applicationMap = new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };

        Map<String,Object> primaryApplicantAccMap = new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id,
            'name'=>'Test Company'
        };

        Map<String,Object> primaryApplicantBIMap = new Map<String,Object>{
            'genesis__Tax_Identification_Number__c'=>123123123,
            'Confirm_Tax_Identification_Number__c'=>123123123
        };

        requestMap.put('application', JSON.serialize(applicationMap));
        requestMap.put('dealerCIF', PortalConstants.LANDUS_DEALER_CIF);
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(primaryApplicantBIMap));
        requestMap.put('shouldValidate', 'newApplicant');
        
        Test.startTest();
        System.runAs(userList[0]) {
            PortalApplicationCreationGrowerAPI testApi = new PortalApplicationCreationGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application Creation Failed');
        }
        Test.stopTest();
    }

    /**
    * @description test create application for a dba
    * @author Rakesh Saraf | 12-23-2024 
    **/
    @isTest 
    public static void testDBAApplicationCreation() {
        Map<String, Object> requestMap = new Map<String, Object>();

        List<Account> accountList = [SELECT Id FROM Account WHERE RecordType.Name = 'Grower'];
        
        List<Contact> contactList = [SELECT Id FROM Contact WHERE AccountId =: accountList[0].id];
        
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id FROM clcommon__Legal_Entity__c WHERE Name = :PortalConstants.INDIVIDUAL_ENTITY];
        
        List<User> userList = [SELECT Id FROM User WHERE ContactId =: contactList[0].id];

        Map<String,Object> applicationMap = new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };

        Map<String,Object> primaryApplicantAccMap = new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id,
            'name'=>'Test Company'
        };

        Map<String,Object> primaryApplicantBIMap = new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000
        };

        requestMap.put('application', JSON.serialize(applicationMap));
        requestMap.put('dealerCIF', PortalConstants.LANDUS_DEALER_CIF);
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(primaryApplicantBIMap));
        requestMap.put('shouldValidate', 'newApplicant');
        
        Test.startTest();
        System.runAs(userList[0]) {
            PortalApplicationCreationGrowerAPI testApi = new PortalApplicationCreationGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application Creation Failed');
        }
        Test.stopTest();
    }


    /**
    * @description test scenario where we do not send the dealer cif with the arg from portal
    * @author Rakesh Saraf | 12-23-2024 
    **/
    @isTest 
    public static void testWithoutLandusDealerCIF() {
        Map<String, Object> requestMap = new Map<String, Object>();

        List<Account> dealerAccountList = [SELECT Id,CIF_Number__c FROM Account WHERE RecordType.Name = 'Dealer'];

        dealerAccountList[0].CIF_Number__c = null;
        Database.update(dealerAccountList,true);

        List<Account> accountList = [SELECT Id FROM Account WHERE RecordType.Name = 'Grower'];

        List<Contact> contactList = [SELECT Id FROM Contact WHERE AccountId =: accountList[0].id];
 
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id FROM clcommon__Legal_Entity__c WHERE Name = :PortalConstants.INDIVIDUAL_ENTITY];

        List<User> userList = [SELECT Id FROM User WHERE ContactId =: contactList[0].id];

        Map<String,Object> applicationMap = new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };

        Map<String,Object> primaryApplicantAccMap = new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id,
            'name'=>'Test Company'
        };

        Map<String,Object> primaryApplicantBIMap = new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000
        };

        requestMap.put('application', JSON.serialize(applicationMap));
        requestMap.put('dealerCIF', PortalConstants.LANDUS_DEALER_CIF);
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(primaryApplicantBIMap));
        requestMap.put('shouldValidate', 'newApplicant');

        Test.startTest();
        System.runAs(userList[0]) {
            PortalApplicationCreationGrowerAPI testApi = new PortalApplicationCreationGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succesfully');
        }
        Test.stopTest();
    }
    
    /**
    * @description test scenaria after creating a relationship
    * @author Rakesh Saraf | 12-23-2024 
    **/
    @isTest
    public static void testWithSalesAgentDealer() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Relationship__c relationshipObj;
        
        List<Account> saAccountList = [SELECT Id FROM Account WHERE RecordType.Name = 'Sales Agent'];

        List<Account> accountList = [SELECT Id FROM Account WHERE RecordType.Name = 'Grower'];

        List<Contact> contactList = [SELECT Id FROM Contact WHERE AccountId =: accountList[0].id];

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id FROM clcommon__Legal_Entity__c WHERE Name = :PortalConstants.INDIVIDUAL_ENTITY];

        List<User> userList = [SELECT Id FROM User WHERE ContactId =: contactList[0].id];

        List<clcommon__Reciprocal_Role__c> roleList = [SELECT Id FROM clcommon__Reciprocal_Role__c WHERE Name = 'Sales Agent'];

        List<clcommon__Relationship__c> relationshipList = [SELECT Id,clcommon__Relationship__c,clcommon__Related_Entity__c FROM clcommon__Relationship__c];
        for(clcommon__Relationship__c reObj : relationshipList){
            relationshipObj = reObj;
            relationshipObj.clcommon__Relationship__c = roleList[0].id;
            relationshipObj.clcommon__Related_Entity__c = saAccountList[0].id;
        }
        Database.update(relationshipObj,true);

        Map<String,Object> applicationMap = new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };

        Map<String,Object> primaryApplicantAccMap = new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id,
            'name'=>'Test Company'
        };

        Map<String,Object> primaryApplicantBIMap = new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000
        };

        requestMap.put('application', JSON.serialize(applicationMap));
        requestMap.put('dealerCIF', PortalConstants.LANDUS_DEALER_CIF);
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(primaryApplicantBIMap));
        requestMap.put('shouldValidate', 'newApplicant');

        Test.startTest();
        System.runAs(userList[0]) {
            PortalApplicationCreationGrowerAPI testApi = new PortalApplicationCreationGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application Creation Failed');
        }
        Test.stopTest();
    }
    
    /**
    * @description test case when the application data is not provided
    * @author Rakesh Saraf | 12-23-2024 
    **/
    @isTest 
    public static void testWithoutApplicationData() {
        Map<String, Object> requestMap = new Map<String, Object>();

        List<Account> accountList = [SELECT Id FROM Account WHERE RecordType.Name = 'Grower'];

        List<Contact> contactList = [SELECT Id FROM Contact WHERE AccountId =: accountList[0].id];

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id FROM clcommon__Legal_Entity__c WHERE Name = :PortalConstants.INDIVIDUAL_ENTITY];

        List<User> userList = [SELECT Id FROM User WHERE ContactId =: contactList[0].id];

        Map<String,Object> applicationMap = new Map<String,Object>{};

        Map<String,Object> primaryApplicantAccMap = new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id,
            'name'=>'Test Company'
        };

        Map<String,Object> primaryApplicantBIMap = new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000
        };

        requestMap.put('application', JSON.serialize(applicationMap));
        requestMap.put('dealerCIF', PortalConstants.LANDUS_DEALER_CIF);
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(primaryApplicantBIMap));
        requestMap.put('shouldValidate', 'newApplicant');
        
        Test.startTest();
        System.runAs(userList[0]) {
            PortalApplicationCreationGrowerAPI testApi = new PortalApplicationCreationGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succesfully');
        }
        Test.stopTest();
    }

}