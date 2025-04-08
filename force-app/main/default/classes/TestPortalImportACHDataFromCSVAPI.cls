/**
 * @description       : Test class for PortalImportACHDataFromCSVAPI
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 12-17-2024
 * @last modified by  : Sk Minsar
**/

@isTest
public with sharing class TestPortalImportACHDataFromCSVAPI {

    /**
    * @description - Creating test data
    * @author Sk Minsar | 12-17-2024 
    **/
    @testSetup
    static void setup() {
        clcommon__Payment_Mode__c achPaymentMode = new clcommon__Payment_Mode__c(Name='ACH');
        Database.insert(achPaymentMode, false);
        clcommon__Party_Type__c objPartyTypeSalesAgent = new clcommon__Party_Type__c(Name = 'SALES AGENT');
        Database.Insert(objPartyTypeSalesAgent, false);

        // creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = TestClassHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = TestClassHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);

        // Creating Contact for Dealer
        Contact dealerContactObj = TestClassHelper.createDealerContact(dealerAccountObj.Id);
        Database.insert(dealerContactObj, true);

        // creating Account for Certified Lender
        Account clAccountObj = TestClassHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = TestClassHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);

        // creating user for certified lender
        User clUser = TestClassHelper.createCLUser(clContactObj.Id);
        Database.insert(clUser, true);

        // creating relationship of certified lender
        clcommon__Reciprocal_Role__c clRoleObj = TestClassHelper.createReciprocalRole('Certified Lender');
        Database.insert(clRoleObj, true);
        clcommon__Relationship__c objRelationship = TestClassHelper.createCLDealerRelationship(clRoleObj,
                                                                                                    dealerAccountObj.Id, 
                                                                                                    clAccountObj.Id);
        Database.insert(objRelationship, true);

        genesis__Applications__c objApplication = TestClassHelper.createApplication(dealerAccountObj.Id);
        Database.upsert(objApplication,true);
        genesis__Application_Pricing_Detail__c newPricingDetails = TestClassHelper.createPricingDetail(objApplication.Id);
        genesis__Application_Pricing_Detail__c secondPricing = TestClassHelper.createPricingDetail(objApplication.Id);
        secondPricing.Loan_Number__c = '123234345-B';
        Database.update(new List<genesis__Application_Pricing_Detail__c>{newPricingDetails, secondPricing},true);
    }

    /**
    * @description - Get the content link for request param
    * @author Sk Minsar | 12-17-2024 
    * @param csvString 
    * @return String 
    **/
    private static String getContentLink(String csvString){
        User clUser = getCertifiedLenderUser();
        Contact objContact = [SELECT Id,Email, accountId FROM Contact WHERE Id =:clUser.ContactId LIMIT 1];
        Account objAccount = [SELECT Id, Name FROM Account WHERE Id =:objContact.accountId LIMIT 1];
        Blob bodyBlob = Blob.valueOf(csvString);   
        ContentVersion firstContentVersion = new ContentVersion(
            Title='TestTitle', 
            PathOnClient ='TestACH.csv',
            VersionData = bodyBlob, 
            origin = 'C'
        );
        Database.insert(firstContentVersion,true);
        ContentVersion secondContentVersion = [SELECT Id, Title, ContentDocumentId 
                        FROM ContentVersion WHERE Id = :firstContentVersion.Id LIMIT 1];
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = objAccount.Id;
        contentlink.contentdocumentid = secondContentVersion.contentDocumentId;
        contentlink.ShareType = 'V';
        contentlink.Visibility = 'AllUsers';
        Database.insert(contentlink,true);
        return String.valueOf(contentlink.Id);
    }

    /**
    * @description - Returns Certified Lender user
    * @author Sk Minsar | 12-17-2024 
    * @return User 
    **/
    private static User getCertifiedLenderUser(){
        return [SELECT Id, Name, AccountId, Account.ParentId, ContactId FROM User WHERE UserName='ross.geller@yopmail.com' LIMIT 1];
    }
    
    /**
    * @description - Returns Sal
    * @author Sk Minsar | 12-17-2024 
    * @return User 
    **/
    private static User getSalesAgentUser(){
        Profile profile = [SELECT Id FROM Profile WHERE Name='Sales Agent' LIMIT 1];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        objUser.UserName = String.valueOf(TestPortalImportACHDataFromCSVAPI.class.getName()) + objUser.UserName;
        return objUser;
    }

    /**
    * @description - Import ACH CSV as a Certified Lender
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testImportACHDataFromCSVSuccess() {
        Map<String, Object> requestMap = new Map<String, Object>();
        String contentLinkId = getContentLink('FullLoanNumber,Purpose,Amount\n123234345-A,Test1,500\n123234345-A,Test2,1000');
        requestMap.put('Id', contentLinkId);
        Test.startTest();
        System.runAs(getCertifiedLenderUser()) {
            PortalImportACHDataFromCSVAPI testApi = new PortalImportACHDataFromCSVAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }

    /**
    * @description - Import ACH CSV with new line character
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testImportACHWithNewLineData() {
        Map<String, Object> requestMap = new Map<String, Object>();
        String contentLinkId = getContentLink('FullLoanNumber,Purpose,Amount\n123234345-A,Test1,500\n123234345-B,Test2,1000\n');
        requestMap.put('Id', contentLinkId);
        Test.startTest();
        System.runAs(getCertifiedLenderUser()) {
            PortalImportACHDataFromCSVAPI testApi = new PortalImportACHDataFromCSVAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }

    /**
    * @description - content document link missing
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testImportACHDataFromCSVExceptionAsSalesAgentNoAccountData() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Test.startTest();
        System.runAs(getSalesAgentUser()) {
            PortalImportACHDataFromCSVAPI testApi = new PortalImportACHDataFromCSVAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }

    /**
    * @description - loan number invalid
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testImportACHDataFromCSVSuccessWithDecimal() {
        Map<String, Object> requestMap = new Map<String, Object>();
        String contentLinkId = getContentLink('FullLoanNumber,Purpose,Amount\n123234345-A,Test1,500.10\n123234345-A,Test2,1000.4');
        requestMap.put('Id', contentLinkId);
        Test.startTest();
        System.runAs(getCertifiedLenderUser()) {
            PortalImportACHDataFromCSVAPI testApi = new PortalImportACHDataFromCSVAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }

    /**
    * @description - loan number missing
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testImportACHDataFromCSVExceptionWithData() {
        Map<String, Object> requestMap = new Map<String, Object>();
        String contentLinkId = getContentLink('FullLoanNumber,Purpose,Amount\n,Test1,500\n123234345-A,Test2,1000');
        requestMap.put('Id', contentLinkId);
        Test.startTest();
        System.runAs(getSalesAgentUser()) {
            PortalImportACHDataFromCSVAPI testApi = new PortalImportACHDataFromCSVAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }

    /**
    * @description - amount is zero
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testImportACHDataFromCSVExceptionWithCSV() {

        Map<String, Object> requestMap = new Map<String, Object>();
        String contentLinkId = getContentLink('FullLoanNumber,Purpose,Amount\n123234345-A,Test1,0\n123234345-A,Test2,1000');
        requestMap.put('Id', contentLinkId);
        Test.startTest();
        System.runAs(getSalesAgentUser()) {
            PortalImportACHDataFromCSVAPI testApi = new PortalImportACHDataFromCSVAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }

    /**
    * @description - amount greater then available
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testImportACHDataFromCSVExceptionWithDecimal() {
        Map<String, Object> requestMap = new Map<String, Object>();
        String contentLinkId = getContentLink('FullLoanNumber,Purpose,Amount\n123234345-A,Test1,150000.00\n123234345-A,Test2,1000');
        requestMap.put('Id', contentLinkId);
        Test.startTest();
        System.runAs(getSalesAgentUser()) {
            PortalImportACHDataFromCSVAPI testApi = new PortalImportACHDataFromCSVAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }

    /**
    * @description - file type not equal to CSV
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testImportACHDataFromCSVExceptionWithExcel() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User objUser = getSalesAgentUser();
        Contact objContact = [SELECT Id,Email, accountId FROM Contact WHERE Id =:objUser.ContactId LIMIT 1];
        Account objAccount = [SELECT Id, Name FROM Account WHERE Id =:objContact.accountId LIMIT 1];
        Blob bodyBlob = Blob.valueOf('FullLoanNumber,Purpose,Amount\n123234345-A,Test1,150000\n123234345-A,Test2,1000');   
        ContentVersion firstContentVersion = new ContentVersion(
            Title='TestTitle', 
            PathOnClient ='TestACH.xlsx',
            VersionData = bodyBlob, 
            origin = 'C'
        );
        Database.insert(firstContentVersion,true);
        ContentVersion secondContentVersion = [SELECT Id, Title, ContentDocumentId 
                        FROM ContentVersion WHERE Id = :firstContentVersion.Id LIMIT 1];
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = objAccount.Id;
        contentlink.contentdocumentid = secondContentVersion.contentDocumentId;
        contentlink.ShareType = 'V';
        contentlink.Visibility = 'AllUsers';
        Database.insert(contentlink,true);
        requestMap.put('Id', contentlink.Id);

        Test.startTest();
        System.runAs(objUser) {
            PortalImportACHDataFromCSVAPI testApi = new PortalImportACHDataFromCSVAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }

    /**
    * @description - test Suspended Loan
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testSuspendedLoan(){
        genesis__Applications__c objApplication = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        objApplication.genesis__Maturity_Date__c = Date.today();
        Database.update(objApplication,false);
        Map<String, Object> requestMap = new Map<String, Object>();
        String contentLinkId = getContentLink('FullLoanNumber,Purpose,Amount\n123234345-A,Test1,500\n123234345-A,Test2,1000');
        requestMap.put('Id', contentLinkId);
        Test.startTest();
        System.runAs(getSalesAgentUser()) {
            PortalImportACHDataFromCSVAPI testApi = new PortalImportACHDataFromCSVAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    
    /**
    * @description - Test with no csv
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testImportACHDataFromCSVExceptionWithNoCSV() {
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c objApplication = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        objApplication.genesis__Maturity_Date__c = Date.today();
        Database.Update(objApplication, true);

        Test.startTest();
        System.runAs(getSalesAgentUser()) {
            PortalImportACHDataFromCSVAPI testApi = new PortalImportACHDataFromCSVAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
}