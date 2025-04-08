/**
 * @description       : Test class for PortalExportAllTransactionsAPI
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 03-19-2024
 * @last modified by  : Sk Minsar
**/
@isTest
public with sharing class PortalExportAllTransactionsAPITest {
    
    /**
    * @description - reuturn the cl user
    * @author Sk Minsar | 03-17-2024 
    * @return User 
    **/
    private static User createUser(){
        genesis__Business_Information__c dealerBusinessInformation = new genesis__Business_Information__c(genesis__Business_Country__c='India');
        Database.insert(dealerBusinessInformation);

        Account dealerAccount = new Account(Name='Test Dealer');
        Database.insert(dealerAccount);
       
        // creating user for certified lender
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User clUser = IntegrationTestInitHelper.createUser(profile.Id);
        Contact clUserContact = [SELECT Id, AccountId FROM Contact WHERE Id = :clUser.ContactId];
        Account clUserAccount = [SELECT Id, Name FROM Account WHERE Id = :clUserContact.AccountId];

        clUserAccount.ParentId = dealerAccount.Id;

        Database.update(clUserAccount);

        clcommon__Reciprocal_Role__c role = new clcommon__Reciprocal_Role__c(Name='Certified Lender');
        Database.insert(role, false);
        clcommon__Relationship__c relationship = new clcommon__Relationship__c(clcommon__Entity__c = dealerAccount.Id, clcommon__Related_Entity__c = clUserAccount.Id ,clcommon__Relationship__c = role.Id);
        Database.insert(relationship , false);

        return clUser;
    }
    
    @isTest
    public static void testCaseCsvSuccess() {
        Object res = '[{\"id\":\"6d7a\",\"rate\":6,\"created_date\":\"2024-03-15\",\"grower_name\":\"Das, Seema\",\"status\":\"Pending\",\"amount\":123,\"loan_number\":\"344448001\",\"transaction_type\":\"ACH\",\"description\":\"Note Rate\",\"purpose\":\"Need Seeds\"}]';
        Object exp = 'csv';
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('transactions', res);
        requestMap.put('exportType', exp);
        User clUser = createUser();

        System.runAs(clUser) {
            Test.startTest();

            // Calling  the API
            PortalExportAllTransactionsAPI saveApi = new PortalExportAllTransactionsAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);

            System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'SUCCESS'); 

            Test.stopTest();
        }
    }
     
    @isTest
    public static void testCasePdfSuccess() {
        Object res = '[{\"id\":\"6d7a\",\"rate\":6,\"created_date\":\"2024-03-15\",\"grower_name\":\"Das, Seema\",\"status\":\"Pending\",\"amount\":123,\"loan_number\":\"344448001\",\"transaction_type\":\"ACH\",\"description\":\"Note Rate\",\"purpose\":\"Need Seeds\"}]';
        Object exp = 'pdf';
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('transactions', res);
        requestMap.put('exportType', exp);
        User clUser = createUser();

        System.runAs(clUser) {
            Test.startTest();

            // Calling  the API
            PortalExportAllTransactionsAPI saveApi = new PortalExportAllTransactionsAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);

            System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'SUCCESS'); 

            Test.stopTest();
        }
    }
    @isTest
    public static void testCaseException() {
        Object res = '[{\"id\":\"6d7a\",\"rate\":6,\"created_date\":\"2024-03-15\",\"grower_name\":\"Das, Seema\",\"status\":\"Pending\",\"amount\":123,\"loan_number\":\"344448001\",\"transaction_type\":\"ACH\",\"description\":\"Note Rate\",\"purpose\":\"Need Seeds\"}]';
        Object exp = '';
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('transactions', res);
        requestMap.put('exportType', exp);
        User clUser = createUser();

        System.runAs(clUser) {
            Test.startTest();

            // Calling  the API
            PortalExportAllTransactionsAPI saveApi = new PortalExportAllTransactionsAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);

            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'EXCEPTION'); 

            Test.stopTest();
        }
    }
    @isTest
    public static void testCaseNoDataException() {
        Object res = '';
        Object exp = 'csv';
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('transactions', res);
        requestMap.put('exportType', exp);
        User clUser = createUser();

        System.runAs(clUser) {
            Test.startTest();

            // Calling  the API
            PortalExportAllTransactionsAPI saveApi = new PortalExportAllTransactionsAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);

            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'EXCEPTION'); 

            Test.stopTest();
        }
    }
    @isTest
    public static void testCaseNullException() {
        Object res = null;
        Object exp = 'csv';
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('transactions', res);
        requestMap.put('exportType', exp);
        User clUser = createUser();

        System.runAs(clUser) {
            Test.startTest();

            // Calling  the API
            PortalExportAllTransactionsAPI saveApi = new PortalExportAllTransactionsAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);

            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'EXCEPTION'); 

            Test.stopTest();
        }
    } 
    @isTest
    public static void testCaseDescriptionEmptySuccess() {
        Object res = '[{\"id\":\"6d7a\",\"rate\":6,\"created_date\":\"2024-03-15\",\"grower_name\":\"Das, Seema\",\"status\":\"Pending\",\"amount\":123,\"loan_number\":\"344448001\",\"transaction_type\":\"ACH\",\"description\":null,\"purpose\":\"Need Seeds\"}]';
        Object exp = 'pdf';
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('transactions', res);
        requestMap.put('exportType', exp);
        User clUser = createUser();

        System.runAs(clUser) {
            Test.startTest();

            // Calling  the API
            PortalExportAllTransactionsAPI saveApi = new PortalExportAllTransactionsAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);

            System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'SUCCESS'); 

            Test.stopTest();
        }
    } 
    @isTest
    public static void testCasetypeEmptySuccess() {
        Object res = '[{\"id\":\"3982\",\"rate\":6,\"created_date\":\"2024-03-15\",\"grower_name\":\"Das, Seema\",\"status\":\"Pending\",\"amount\":444,\"loan_number\":\"344448001\",\"transaction_type\":null,\"description\":\"Note Rate\",\"purpose\":\"More Seeds\"}]';
        Object exp = 'csv';
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('transactions', res);
        requestMap.put('exportType', exp);
        User clUser = createUser();

        System.runAs(clUser) {
            Test.startTest();

            // Calling  the API
            PortalExportAllTransactionsAPI saveApi = new PortalExportAllTransactionsAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);

            System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'SUCCESS'); 

            Test.stopTest();
        }
    } 
}