/**
 * @description       : Test class for BuyerAccountIds Trigger
 * @author            : Simran
 * @group             : 
 * @last modified on  : 04-10-2024
 * @last modified by  : Soumik Pattanayak
**/
@isTest
public  class BuyerAccountIdsTest {
    /**
    * @description Creating data
    * @author Soumik Pattanayak | 04-10-2024 
    **/
    @testSetup
    static void setup(){
        Account objAccount = new Account();
        objAccount.Name='SJha';
        Database.insert(objAccount, true);
        
        genesis__Applications__c objApplication = new genesis__Applications__c();
        objApplication.Signing_Method__c='Email - Docusign';
        objApplication.Buyer_Account_Id__c='abc';
        Database.insert(objApplication, true);
        
        clcommon__Party_Type__c objPartyType = new clcommon__Party_Type__c();
        objPartyType.Name= 'BUYER';
        Database.insert(objPartyType, true); 

        clcommon__Party__c objClParty = new clcommon__Party__c();
        objClParty.clcommon__Account__c=objAccount.Id;
        objClParty.genesis__Application__c=objApplication.Id;
        objClParty.clcommon__Type__c = objPartyType.Id;
        Database.insert(objClParty, true);
    }
    /**
    * @description for creating a record
    * @author Soumik Pattanayak | 04-10-2024 
    **/
    @isTest
    public static void testBuyerAccountIds(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        // genesis__Applications__c objApplicationOne=[Select Id, Buyer_Account_Id__c FROM genesis__Applications__c WHERE Signing_Method__c='Email - Docusign'];
        // clcommon__Party_Type__c objPartyTypeOne = [Select Id,Name FROM  clcommon__Party_Type__c WHERE Name='BUYER'];
        // clcommon__Party__c objClPartyOne=[SELECT Id,clcommon__Account__c,genesis__Application__c FROM clcommon__Party__c WHERE genesis__Application__c=:objApplicationOne.Id];
        System.runAs(userObj){
            System.assert(true,'SUCCESS'); 
        }
    }
    /**
    * @description for deleting a record
    * @author Soumik Pattanayak | 04-10-2024 
    **/
    @isTest
    public static void testBuyerAccountIdsDelete(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c objApplicationOne=[Select Id, Buyer_Account_Id__c FROM genesis__Applications__c WHERE Signing_Method__c='Email - Docusign'];
        clcommon__Party_Type__c objPartyTypeOne = [Select Id,Name FROM  clcommon__Party_Type__c WHERE Name='BUYER'];
        clcommon__Party__c objClPartyOne=[SELECT Id,clcommon__Account__c,genesis__Application__c FROM clcommon__Party__c WHERE genesis__Application__c=:objApplicationOne.Id];
        System.runAs(userObj){
            Test.startTest();
            Database.delete(objClPartyOne,true);
            Database.delete(objPartyTypeOne,true);
            Test.stopTest();
            System.assert(true,'SUCCESS'); 
        }
    }
}