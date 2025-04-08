/**
 * @description       : Test Class to cover PortalPrePrintApplicationAPI
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 13-07-2022
 * @last modified by  : Subham Nandi
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   13-07-2022   Subham Nandi   Initial Version
**/
@isTest
public with sharing class TestPortalPrePrintApplicationAPI {
    @isTest 
    public static void testPrePrintApplication1(){
        Map<String,Object> request = new Map<String,Object>();
        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        clcommon__Party_Type__c objPartyTypeSalesAgent = new clcommon__Party_Type__c(Name = 'SALES AGENT');
        Database.insert(objPartyTypeSalesAgent, false);
        Profile profile = [SELECT Id FROM Profile WHERE Name='Sales Agent'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        List<String> applicationIdList = new List<String>();
        for(Integer i = 0; i < 3; i++){
            genesis__Applications__c objApplication = TestClassHelper.createApplication();
            applicationIdList.add(objApplication.Id);
            Contact objContact = [SELECT Id,Email, accountId FROM Contact WHERE Id =:objUser.ContactId];
            Account objAccount = [SELECT Id, Name FROM Account WHERE Id =:objContact.accountId];
            clcommon__Party__c objDealerParty = new clcommon__Party__c(clcommon__Account__c = objAccount.Id ,
                                                                        clcommon__Contact__c = objContact.Id, 
                                                                        clcommon__User__c = objUser.Id,
                                                                        clcommon__Type__c = objPartyTypeSalesAgent.Id,
                                                                        genesis__Application__c = objApplication.Id);
            partyList.add(objDealerParty);
        }
        Database.insert(partyList , false);
        request.put('applicationIdList',Json.Serialize(applicationIdList));
        Test.startTest();
        System.runAs(objUser){
            PortalPrePrintApplicationAPI testAPI = new PortalPrePrintApplicationAPI();
            clcommon.Response response = testAPI.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status);
        }
        Test.stopTest();

    }
    //Custom Exception of invalid user
    @isTest
    public static void testPrePrintApplicationError1(){
        Map<String,Object> request = new Map<String,Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Sales Agent'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        List<String> applicationIdList = new List<String>();
        for(Integer i = 0; i < 3; i++){
            genesis__Applications__c objApplication = TestClassHelper.createApplication();
            applicationIdList.add(objApplication.Id);
        }
        request.put('applicationIdList',Json.Serialize(applicationIdList));
        Test.startTest();
        System.runAs(objUser){
            PortalPrePrintApplicationAPI testAPI = new PortalPrePrintApplicationAPI();
            clcommon.Response response = testAPI.invokeAction('', new List<String>(), request);
        }
        Test.stopTest();

    }
    //System Exception of invalid user
    @isTest
    public static void testPrePrintApplicationError2(){
        Map<String,Object> request = new Map<String,Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Sales Agent'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        request.put('applicationIdList','{92u30r8u2498uyr9,2398hr9h}');
        Test.startTest();
        System.runAs(objUser){
            PortalPrePrintApplicationAPI testAPI = new PortalPrePrintApplicationAPI();
            clcommon.Response response = testAPI.invokeAction('', new List<String>(), request);
        }
        Test.stopTest();

    }
}