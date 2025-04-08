/**
 * @description       : 
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 03-27-2023
 * @last modified by  : Ayush Kumar Singh
**/
@isTest
public with sharing class TestPortalExportLoanPayoff {
    @isTest
    public static void testPortalPayoffAPI() {
        Test.startTest();
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Grower'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        genesis__Applications__c objApplication = TestClassHelper.createApplication();
        Contact objContact = [SELECT Id,Email, accountId FROM Contact WHERE Id =:objUser.ContactId];
        Account objAccount = [SELECT Id, Name FROM Account WHERE Id =:objContact.accountId];
        genesis__Application_Pricing_Detail__c newPricingDetails = TestClassHelper.createPricingDetail(objApplication.Id);
        newPricingDetails.Principal_Advanced__c = 500;
        newPricingDetails.Fees__c = 200;
        newPricingDetails.Accrued_Interest__c = 250;
        Database.update(newPricingDetails,true);
        objApplication.genesis__Account__c = objAccount.Id;
        Database.update(objApplication,false);
        
        requestMap.put('applicationId', objApplication.id);
        
        System.runAs(objUser) {
            PortalExportLoanPayoff testApi = new PortalExportLoanPayoff();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    @isTest
    public static void testPortalPayoffAPI2() {
        Test.startTest();
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Grower'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        genesis__Applications__c objApplication = TestClassHelper.createApplication();
        Contact objContact = [SELECT Id,Email, accountId FROM Contact WHERE Id =:objUser.ContactId];
        Account objAccount = [SELECT Id, Name FROM Account WHERE Id =:objContact.accountId];
        genesis__Application_Pricing_Detail__c newPricingDetails = TestClassHelper.createPricingDetail(objApplication.Id);
        newPricingDetails.Principal_Advanced__c = 500;
        newPricingDetails.Fees__c = 200;
        newPricingDetails.Accrued_Interest__c = 250;
        Database.update(newPricingDetails,true);
        objApplication.genesis__Account__c = objAccount.Id;
        Database.update(objApplication,false);
        
        requestMap.put('applicationId', null);
        
        System.runAs(objUser) {
            PortalExportLoanPayoff testApi = new PortalExportLoanPayoff();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    @isTest
    public static void testPortalPayoffAPI3() {
        Test.startTest();
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Grower'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        genesis__Applications__c objApplication = TestClassHelper.createApplication();
        Contact objContact = [SELECT Id,Email, accountId FROM Contact WHERE Id =:objUser.ContactId];
        Account objAccount = [SELECT Id, Name FROM Account WHERE Id =:objContact.accountId];
        genesis__Application_Pricing_Detail__c newPricingDetails = TestClassHelper.createPricingDetail(objApplication.Id);
        newPricingDetails.Principal_Advanced__c = 500;
        newPricingDetails.Fees__c = 200;
        newPricingDetails.Accrued_Interest__c = 250;
        Database.update(newPricingDetails,true);
        objApplication.genesis__Account__c = objAccount.Id;
        Database.update(objApplication,false);
        
        requestMap.put('applicationId', 'a45bbjhjhbnbbbn');
        
        System.runAs(objUser) {
            PortalExportLoanPayoff testApi = new PortalExportLoanPayoff();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    @isTest
    public static void testPortalPayoffAPI4() {
        Test.startTest();
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Grower'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        genesis__Applications__c objApplication = TestClassHelper.createApplication();
        Contact objContact = [SELECT Id,Email, accountId FROM Contact WHERE Id =:objUser.ContactId];
        Account objAccount = [SELECT Id, Name FROM Account WHERE Id =:objContact.accountId];
        genesis__Application_Pricing_Detail__c newPricingDetails = TestClassHelper.createPricingDetail(objApplication.Id);
        newPricingDetails.Principal_Advanced__c = 500;
        newPricingDetails.Fees__c = 200;
        newPricingDetails.Accrued_Interest__c = 250;
        Database.update(newPricingDetails,true);
        objApplication.genesis__Account__c = objAccount.Id;
        objApplication.genesis__Loan_Number__c = null;
        Database.update(objApplication,false);
        
        requestMap.put('applicationId', null);
        System.runAs(objUser) {
            PortalExportLoanPayoff testApi = new PortalExportLoanPayoff();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    @isTest
    public static void testPortalPayoffAPI5() {
        Test.startTest();
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Grower'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        genesis__Applications__c objApplication = TestClassHelper.createApplication();
        Contact objContact = [SELECT Id,Email, accountId FROM Contact WHERE Id =:objUser.ContactId];
        Account objAccount = [SELECT Id, Name FROM Account WHERE Id =:objContact.accountId];
        genesis__Application_Pricing_Detail__c newPricingDetails = TestClassHelper.createPricingDetail(objApplication.Id);
        newPricingDetails.Principal_Advanced__c = 500;
        newPricingDetails.Fees__c = 200;
        newPricingDetails.Accrued_Interest__c = 250;
        Database.update(newPricingDetails,true);
        objApplication.genesis__Account__c = objAccount.Id;
        objApplication.genesis__Maturity_Date__c = null;
        Database.update(objApplication,false);
        
        requestMap.put('applicationId', null);
        System.runAs(objUser) {
            PortalExportLoanPayoff testApi = new PortalExportLoanPayoff();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }

}