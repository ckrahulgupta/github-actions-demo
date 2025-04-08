/**
 * @description       : Test Class for PortalExportTransactionAPI
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  : Suraj Kumar
**/
@isTest
public with sharing class TestPortalExportTransactionAPI {
    /**
    * @description : return the certified lender user
    * @author Suraj Kumar | 03-11-2024 
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
    public static void testCase1() {
        Object res = '[{\"id\":\"649e\",\"Transaction_Date\":\"2023-03-03\",\"Acctrefno\":195239,\"Transaction_Type\":\"LA DN  DPA DNA DNA DNA DX\",\"Transaction_Amount\":1000,\"Transaction_Description\":\"Principal Advance\",\"User_Reference\":\"ACH Cropsafe Ledger Finances - Seeds\"}]';
        Object exp = 'csv';
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('transactions', res);
        requestMap.put('exportType', exp);
        User clUser = createUser();

        System.runAs(clUser) {
            Test.startTest();

            // Calling  the API
            PortalExportTransactionAPI saveApi = new PortalExportTransactionAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);

            System.assertEquals(clcommon.Constants.SUCCESS, resp.status); 

            Test.stopTest();
        }
    }
     
    @isTest
    public static void testCase2() {
        Object res = '[{\"id\":\"649e\",\"Transaction_Date\":\"2023-03-03\",\"Acctrefno\":195239,\"Transaction_Type\":\"LA DN  DPA DNA DNA DNA DX\",\"Transaction_Amount\":1000,\"Transaction_Description\":\"Principal Advance\",\"User_Reference\":\"ACH Cropsafe Ledger Finances - Seeds\"}]';
        Object exp = 'pdf';
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('transactions', res);
        requestMap.put('exportType', exp);
        User clUser = createUser();

        System.runAs(clUser) {
            Test.startTest();

            // Calling  the API
            PortalExportTransactionAPI saveApi = new PortalExportTransactionAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);

            System.assertEquals(clcommon.Constants.SUCCESS, resp.status); 

            Test.stopTest();
        }
    }
    @isTest
    public static void testCase3() {
        Object res = '[{\"id\":\"649e\",\"Transaction_Date\":\"2023-03-03\",\"Acctrefno\":195239,\"Transaction_Type\":\"LA DN  DPA DNA DNA DNA DX\",\"Transaction_Amount\":1000,\"Transaction_Description\":\"Principal Advance\",\"User_Reference\":\"ACH Cropsafe Ledger Finances - Seeds\"}]';
        Object exp = '';
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('transactions', res);
        requestMap.put('exportType', exp);
        User clUser = createUser();

        System.runAs(clUser) {
            Test.startTest();

            // Calling  the API
            PortalExportTransactionAPI saveApi = new PortalExportTransactionAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);

            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 

            Test.stopTest();
        }
    }
    @isTest
    public static void testCase4() {
        Object res = '';
        Object exp = 'csv';
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('transactions', res);
        requestMap.put('exportType', exp);
        User clUser = createUser();

        System.runAs(clUser) {
            Test.startTest();

            // Calling  the API
            PortalExportTransactionAPI saveApi = new PortalExportTransactionAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);

            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 

            Test.stopTest();
        }
    }
    @isTest
    public static void testCase5() {
        Object res = null;
        Object exp = 'csv';
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('transactions', res);
        requestMap.put('exportType', exp);
        User clUser = createUser();

        System.runAs(clUser) {
            Test.startTest();

            // Calling  the API
            PortalExportTransactionAPI saveApi = new PortalExportTransactionAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);

            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status); 

            Test.stopTest();
        }
    } 
    @isTest
    public static void testCase6() {
        Object res = '[{\"id\":\"649e\",\"Transaction_Date\":\"2023-03-03\",\"Acctrefno\":195239,\"Transaction_Type\":\"LA DN  DPA DNA DNA DNA DX\",\"Transaction_Amount\":1000,\"Transaction_Description\":null,\"User_Reference\":\"ACH Cropsafe Ledger Finances - Seeds\"}]';
        Object exp = 'pdf';
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('transactions', res);
        requestMap.put('exportType', exp);
        User clUser = createUser();

        System.runAs(clUser) {
            Test.startTest();

            // Calling  the API
            PortalExportTransactionAPI saveApi = new PortalExportTransactionAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);

            System.assertEquals(clcommon.Constants.SUCCESS, resp.status); 

            Test.stopTest();
        }
    } 
    @isTest
    public static void testCase7() {
        Object res = '[{\"id\":\"649e\",\"Transaction_Date\":\"2023-03-03\",\"Acctrefno\":195239,\"Transaction_Type\":\"LA DN  DPA DNA DNA DNA DX\",\"Transaction_Amount\":1000,\"Transaction_Description\":null,\"User_Reference\":\"ACH Cropsafe Ledger Finances - Seeds\"}]';
        Object exp = 'csv';
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('transactions', res);
        requestMap.put('exportType', exp);
        User clUser = createUser();

        System.runAs(clUser) {
            Test.startTest();

            // Calling  the API
            PortalExportTransactionAPI saveApi = new PortalExportTransactionAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);

            System.assertEquals(clcommon.Constants.SUCCESS, resp.status); 

            Test.stopTest();
        }
    } 
}