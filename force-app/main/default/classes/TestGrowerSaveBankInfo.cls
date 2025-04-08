/**
 * @description       : Test class for PortalGrowerSaveBankInformation API
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 29-03-2022
 * @last modified by  : Subham Nandi
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   29-03-2022   Subham Nandi   Initial Version
**/
@isTest
private class TestGrowerSaveBankInfo {
    //Setting up the test data for bank informationG
    @TestSetup
    static void setup(){
        //create account for the current grower/user
        Account growerAccount = TestClassHelper.createAccount(TestClassHelper.createBusinessInfo());
        //create contact for the current grower/user
        Contact growerContact = TestClassHelper.createContact();
        growerContact.AccountId = growerAccount.Id;
        Database.update(growerContact,true);
        //Querying the grower profile id
        Profile growerProfile = [SELECT Id FROM Profile WHERE Name='Grower'];
        //Creating the test grower to test the portal
        User testGrowerUser = new User(Alias = 'Sam', 
                            Email='sam.grower@mailinator.com',
                            EmailEncodingKey='UTF-8', 
                            LastName='Sam', 
                            LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', 
                            ContactId = growerContact.Id,
                            ProfileId = growerProfile.Id,
                            TimeZoneSidKey='America/Los_Angeles', 
                            UserName='sam.grower@mailinator.com');
        Database.insert(testGrowerUser,true);
        //creating a bank account to test
        clcommon__Bank_Account__c bankAccountInformation = TestClassHelper.createBankAccount();

    }


    //Testing A Success scenario 
    @isTest
    static void testGrowerSaveBankInformationApi(){
        User testUser = [SELECT Id FROM User WHERE Username = 'sam.grower@mailinator.com'];
        List<clcommon__Bank_Account__c> bankAccountListToTest = new List<clcommon__Bank_Account__c>();
        clcommon__Bank_Account__c testBank = [SELECT Id,
                                                    clcommon__Bank_Account_Number__c,
                                                    clcommon__Bank_Account_Name__c,
                                                    clcommon__Routing_Number__c
                                                    FROM clcommon__Bank_Account__c];
        bankAccountListToTest.add(testBank);
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('bankInformation', Json.serialize(bankAccountListToTest));
            PortalGrowerSaveBankInformationAPI callPortalSaveGrowerBank = new PortalGrowerSaveBankInformationAPI();
            clcommon.Response resp = callPortalSaveGrowerBank.invokeAction('',new List<String>(), requestMap);
        }
    }
    //Testing with null account number
    @isTest
    static void testGrowerSaveBankInformationApiWithNULLAccountNumber(){
        User testUser = [SELECT Id FROM User WHERE Username = 'sam.grower@mailinator.com'];
        List<clcommon__Bank_Account__c> bankAccountListToTest = new List<clcommon__Bank_Account__c>();
        clcommon__Bank_Account__c testBank = [SELECT Id,
                                                    clcommon__Bank_Account_Number__c,
                                                    clcommon__Bank_Account_Name__c,
                                                    clcommon__Routing_Number__c
                                                    FROM clcommon__Bank_Account__c];
        testBank.clcommon__Bank_Account_Number__c = null;
        bankAccountListToTest.add(testBank);
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('bankInformation', Json.serialize(bankAccountListToTest));
            PortalGrowerSaveBankInformationAPI callPortalSaveGrowerBank = new PortalGrowerSaveBankInformationAPI();
            clcommon.Response resp = callPortalSaveGrowerBank.invokeAction('',new List<String>(), requestMap);
        }
    }
    //Testing with null account name
    @isTest
    static void testGrowerSaveBankInformationApiWithNULLAccountName(){
        User testUser = [SELECT Id FROM User WHERE Username = 'sam.grower@mailinator.com'];
        List<clcommon__Bank_Account__c> bankAccountListToTest = new List<clcommon__Bank_Account__c>();
        clcommon__Bank_Account__c testBank = [SELECT Id,
                                                    clcommon__Bank_Account_Number__c,
                                                    clcommon__Bank_Account_Name__c,
                                                    clcommon__Routing_Number__c
                                                    FROM clcommon__Bank_Account__c];
        testBank.clcommon__Bank_Account_Name__c = null;
        bankAccountListToTest.add(testBank);
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('bankInformation', Json.serialize(bankAccountListToTest));
            PortalGrowerSaveBankInformationAPI callPortalSaveGrowerBank = new PortalGrowerSaveBankInformationAPI();
            clcommon.Response resp = callPortalSaveGrowerBank.invokeAction('',new List<String>(), requestMap);
        }
    }
    //Testing with null routing number
    @isTest
    static void testGrowerSaveBankInformationApiWithNULLAccountRounting(){
        User testUser = [SELECT Id FROM User WHERE Username = 'sam.grower@mailinator.com'];
        List<clcommon__Bank_Account__c> bankAccountListToTest = new List<clcommon__Bank_Account__c>();
        clcommon__Bank_Account__c testBank = [SELECT Id,
                                                    clcommon__Bank_Account_Number__c,
                                                    clcommon__Bank_Account_Name__c,
                                                    clcommon__Routing_Number__c
                                                    FROM clcommon__Bank_Account__c];
        testBank.clcommon__Routing_Number__c = null;
        bankAccountListToTest.add(testBank);
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('bankInformation', Json.serialize(bankAccountListToTest));
            PortalGrowerSaveBankInformationAPI callPortalSaveGrowerBank = new PortalGrowerSaveBankInformationAPI();
            clcommon.Response resp = callPortalSaveGrowerBank.invokeAction('',new List<String>(), requestMap);
        }
    }
    //Testing with blank request for error
    @isTest
    static void testGrowerSaveBankInformationApiWithERROR(){
        User testUser = [SELECT Id FROM User WHERE Username = 'sam.grower@mailinator.com'];
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('bankInformation', Json.serialize(''));
            PortalGrowerSaveBankInformationAPI callPortalSaveGrowerBank = new PortalGrowerSaveBankInformationAPI();
            clcommon.Response resp = callPortalSaveGrowerBank.invokeAction('',new List<String>(), requestMap);
        }
    }
}