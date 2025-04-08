/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 05-12-2024
 * @last modified by  : Soumik Pattanayak
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   15-07-2022   Subham Nandi   Initial Version
**/
@isTest
public class TestPortalSavePotentialBuyerAPI {
    @TestSetup
    static void makeData(){
        genesis__Business_Information__c businessInfoDealer = new genesis__Business_Information__c();
        businessInfoDealer = TestClassHelper.createBusinessInfo();
        //Creating the dealer parent account
        Account dealerCompany = new Account();
        dealerCompany = TestClassHelper.createDealerParentAccount(businessInfoDealer);
        //Creating the a single user account of the dealer company
        Account dealerUserAccount = new Account();
        dealerUserAccount = TestClassHelper.createDealerChildAccount(businessInfoDealer,dealerCompany);
        //creating the dealer contact and associating the account
        Contact dealerContact = new Contact();
        dealerContact = TestClassHelper.createContact();
        dealerContact.AccountId = dealerUserAccount.Id;
        Database.update(dealerContact);
        //creating the user out of the two contact on whose context the test will run
        Profile dealerProfile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User testUser = new User(Alias = 'dbob', 
                            Email='dealer.bob@mailinator.com',
                            EmailEncodingKey='UTF-8', 
                            LastName='Bob', 
                            LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', 
                            ContactId = dealerContact.Id,
                            ProfileId = dealerProfile.Id,
                            TimeZoneSidKey='America/Los_Angeles', 
                            UserName='newuser@testorg.com');
        Database.insert(testUser,false);
        genesis__Applications__c objApplication = TestClassHelper.createApplication();
        Contact objContact = [SELECT Id,Email, accountId FROM Contact WHERE Id =:testUser.ContactId];
        Account objAccount = [SELECT Id, Name FROM Account WHERE Id =:objContact.accountId];
        objAccount.Billing_County__c= 'Kings';
        Database.update(objAccount);

        clcommon__Party_Type__c partyTypeCLObj = new clcommon__Party_Type__c(Name = 'CERTIFIED LENDER');
        Database.insert(partyTypeCLObj, false);
        clcommon__Party__c objDealerParty = new clcommon__Party__c(clcommon__Account__c = objAccount.Id ,
                                                                    clcommon__Contact__c = objContact.Id, 
                                                                    clcommon__User__c = testUser.Id,
                                                                    clcommon__Type__c = partyTypeCLObj.Id,
                                                                    genesis__Application__c = objApplication.Id);
        Database.insert(objDealerParty , false);
        objApplication.Dealer_Name__c = dealerCompany.Id;
        objApplication.Certified_Lender__c = dealerUserAccount.Id;
        Database.update(objApplication);
        clcommon__Party_Type__c objPartyTypeBuyer = new clcommon__Party_Type__c(Name = 'BUYER');
        Database.insert(objPartyTypeBuyer, false);  

    }
    //test for New Buyer - SUCCESS
    @isTest
    public static void testPortalSaveBuyer(){
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c objApplication = [ SELECT Id
                                                    FROM genesis__Applications__c];
        requestMap.put('isNewBuyer',true);
        requestMap.put('applicationId', objApplication.id);
        requestMap.put('buyerDetails','[{\"clcommon__Account__r.Name\":\"Lisa Amberis\",\"clcommon__Account__r.BillingStreet\":\"1 1/2 2nd Ave N \",\"clcommon__Account__r.BillingState\":\"AL\",\"clcommon__Account__r.clcommon__Email__c\":\"lisa.amberis@yopmail.com\",\"clcommon__Account__r.BillingCity\":\"Birmingham\",\"clcommon__Account__r.Phone\":\"7632874562\",\"Id\":\"new_record_id\",\"clcommon__Account__r.BillingPostalCode\":\"35204\"}]');
        User objUser = [SELECT Id FROM USER WHERE UserName = 'newuser@testorg.com'];
        System.runAs(objUser) {
            PortalSavePotentialBuyerAPI saveBuyer = new PortalSavePotentialBuyerAPI();
            clcommon.Response response = saveBuyer.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'assertion failed');
        }
    }
    //test for New Buyer - Error - Buyer Details Missing
    @isTest
    public static void testErrorMissingBuyerDetails(){
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c objApplication = [ SELECT Id
                                                    FROM genesis__Applications__c];
        requestMap.put('isNewBuyer',true);
        requestMap.put('applicationId', objApplication.id);
        requestMap.put('buyerDetails','[{\"clcommon__Account__r.BillingStreet\":\"1 1/2 2nd Ave N \",\"clcommon__Account__r.BillingState\":\"AL\",\"clcommon__Account__r.clcommon__Email__c\":\"lisa.amberis@yopmail.com\",\"clcommon__Account__r.BillingCity\":\"Birmingham\",\"clcommon__Account__r.Phone\":\"7632874562\",\"Id\":\"new_record_id\",\"clcommon__Account__r.BillingPostalCode\":\"35204\"}]');
        User objUser = [SELECT Id FROM USER WHERE UserName = 'newuser@testorg.com'];
        System.runAs(objUser) {
            PortalSavePotentialBuyerAPI saveBuyer = new PortalSavePotentialBuyerAPI();
            clcommon.Response response = saveBuyer.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'assertion failed');
        }
    }
    //test for New Buyer - Error - Application id is missing
    @isTest
    public static void testErrorMissingApplicationId(){
        Map<String,Object> requestMap = new Map<String,Object>();
        // genesis__Applications__c objApplication = [ SELECT Id
        //                                             FROM genesis__Applications__c];
        requestMap.put('isNewBuyer',true);
        requestMap.put('applicationId', '');
        requestMap.put('buyerDetails','[{\"clcommon__Account__r.BillingStreet\":\"1 1/2 2nd Ave N \",\"clcommon__Account__r.BillingState\":\"AL\",\"clcommon__Account__r.clcommon__Email__c\":\"lisa.amberis@yopmail.com\",\"clcommon__Account__r.BillingCity\":\"Birmingham\",\"clcommon__Account__r.Phone\":\"7632874562\",\"Id\":\"new_record_id\",\"clcommon__Account__r.BillingPostalCode\":\"35204\"}]');
        User objUser = [SELECT Id FROM USER WHERE UserName = 'newuser@testorg.com'];
        System.runAs(objUser) {
            PortalSavePotentialBuyerAPI saveBuyer = new PortalSavePotentialBuyerAPI();
            clcommon.Response response = saveBuyer.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'assertion failed');
        }
    }
    //test for Existing Buyer - SUCCESS
    @isTest
    public static void testExistingBuyerSuccess(){
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c objApplication = [ SELECT Id
                                                    FROM genesis__Applications__c];
        Account buyerAccount = new Account(Name = 'Billy Buyer');
        Database.insert(buyerAccount);
        Contact buyerContact = new Contact(Firstname = 'Billy', LastName = 'Buyer', AccountId = buyerAccount.Id);
        Database.insert(buyerContact);
        requestMap.put('isNewBuyer',false);
        requestMap.put('applicationId', objApplication.Id);
        requestMap.put('existingBuyerList','[\"'+buyerAccount.Id+'\"]');
        User objUser = [SELECT Id FROM USER WHERE UserName = 'newuser@testorg.com'];
        System.runAs(objUser) {
            PortalSavePotentialBuyerAPI saveBuyer = new PortalSavePotentialBuyerAPI();
            clcommon.Response response = saveBuyer.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'assertion failed');
        }
    }
    //test for Existing Buyer - ERROR
    @isTest
    public static void testExistingBuyerError(){
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c objApplication = [ SELECT Id
                                                    FROM genesis__Applications__c];
        Account buyerAccount = new Account(Name = 'Billy Buyer');
        Database.insert(buyerAccount);
        Contact buyerContact = new Contact(Firstname = 'Billy', LastName = 'Buyer', AccountId = buyerAccount.Id);
        Database.insert(buyerContact);
        requestMap.put('isNewBuyer',false);
        requestMap.put('applicationId', objApplication.Id);
        requestMap.put('existingBuyerList','{[\"'+buyerAccount.Id+'\"]}');
        User objUser = [SELECT Id FROM USER WHERE UserName = 'newuser@testorg.com'];
        System.runAs(objUser) {
            PortalSavePotentialBuyerAPI saveBuyer = new PortalSavePotentialBuyerAPI();
            clcommon.Response response = saveBuyer.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'assertion failed');
        }
    }
}