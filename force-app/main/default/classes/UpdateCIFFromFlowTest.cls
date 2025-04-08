/**
 * @description       : Test class for UpdateCIFNumber
 * @author            : Simran
 * @group             : 
 * @last modified on  : 05-26-2022
 * @last modified by  : Simran
**/
@isTest
global  class UpdateCIFFromFlowTest {
    @isTest
    global static void UpdateCIFFromFlowTest() {
        CFA_Configuration__c cfaConfig = new CFA_Configuration__c();
        cfaConfig.CIF_Number__c='67732';
        Database.insert(cfaConfig);
        Account objaccount= new Account();
        objaccount.Name='TestAccount';
        objaccount.CIF_Number__c='12345';
        Database.insert(objaccount);
        List<String> idList = new List<String>();
        idList.add(String.valueOf(objaccount.Id));
        UpdateCIFFromFlow.updateCIFNumber(idList); 
        System.assert(true);

    }
    @isTest
    global static void UpdateCIFFromFlowTest1() {
        CFA_Configuration__c cfaConfig = new CFA_Configuration__c();
        Database.insert(cfaConfig);
        Account objaccount= new Account();
        objaccount.Name='TestAccount';
        objaccount.CIF_Number__c='12345';
        Database.insert(objaccount);
        List<String> idList = new List<String>();
        idList.add(String.valueOf(objaccount.Id));
        UpdateCIFFromFlow.updateCIFNumber(idList);    
    }
    @isTest
    global static void UpdateCIFFromFlowTest2() {
        UpdateCIFFromFlow.updateCIFNumber(null);    
    }
}