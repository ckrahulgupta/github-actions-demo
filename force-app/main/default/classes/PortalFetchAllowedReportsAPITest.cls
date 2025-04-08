/**
 * @description       : 
 * @author            : Swapnamoy Chakraborty
 * @group             : 
 * @last modified on  : 07-11-2024
 * @last modified by  : Swapnamoy Chakraborty
**/

@IsTest
public with sharing class PortalFetchAllowedReportsAPITest {

    @TestSetup
    static void makeData(){
        // Creating business info for dealer
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.Insert(dealerBusinessInfoObj, true);

        // Creating business information for borrower
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.Insert(borrowerBusinessInfoObj, true);

        CFA_Partner_Program__c programObj = new CFA_Partner_Program__c(Name = 'Test Program', Reports__c = 'Product Return Summary;IFP Active Loan Report');
        Database.Insert(programObj);
        //Adding Partner Program to the DealerAccountObj
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.CFA_Partner_Program__c = programObj.Id;
        Database.Insert(dealerAccountObj, true);

        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(null, dealerAccountObj.Id);
        Database.Insert(clAccountObj, true);

        // Creating Contacts
        Contact dealerContactObj = ApplicationOriginationTestHelper.createDealerContact(dealerAccountObj.Id);
        Database.Insert(dealerContactObj, true);

        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.Insert(clContactObj, true);
        //Creating Users
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        Database.Insert(clUserObj, true);
    }

    @IsTest
    static void testCaseSuccessScenario()
    {
        User clUser;
        List<User> clUserList = [SELECT Id, Name, Email, ProfileId, ContactId, UserName, Alias
                                FROM USER 
                                WHERE Email = 'cfanewus5er@yopmail.com'
                                LIMIT 1];
        
        if (clUserList.size() == 1) {
            for(User user : clUserList){
                clUser = user;
            }
        }
        Map<String, Object> request = new Map<String, Object>();
        System.runAs(clUser)
        {
            Test.startTest();
            PortalFetchAllowedReportsAPI fetchAllowedReportsAPI = new PortalFetchAllowedReportsAPI();
            clcommon.Response response = fetchAllowedReportsAPI.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
            Test.stopTest();
        }

    }
    @IsTest
    public static void testCaseExceptionScenario() {

        Id dealerAccountId;
        Account clAccountObj;
        User clUser;
        
        // Fetching accounts
        List<Account> dealerAccountList = [SELECT Id, name,
        CFA_Partner_Program__c
                                        FROM Account
                                        WHERE Name = 'Kisan Loan'
                                        LIMIT 1];
        if(dealerAccountList.size() == 1){
            for(Account acc : dealerAccountList){
                acc.CFA_Partner_Program__c = null;
                dealerAccountId = acc.Id;
            }
        }
        Database.Update(dealerAccountList);
        List<Account> clAccountList = [SELECT Id, name, ParentId, Parent.Name, clcommon__Legal_Entity_Type__c, clcommon__Legal_Entity_Type__r.name
                                        FROM Account 
                                        WHERE name = 'Ross Geller'
                                        LIMIT 1];
        if(clAccountList.size() == 1){
            for(Account acc : clAccountList){
                clAccountObj = acc;
            }
        }
        clAccountObj.ParentId = dealerAccountId; // attaching dealer account
        Database.Update(clAccountObj, true);

        // Fetching user
        List<User> clUserList = [SELECT Id, Name, Email, ProfileId, ContactId, UserName, Alias
                                FROM USER 
                                WHERE Email = 'cfanewus5er@yopmail.com'
                                LIMIT 1];
        if (clUserList.size() == 1) {
            for(User user : clUserList){
                clUser = user;
            }
        }

        Map<String, Object> request = new Map<String, Object>();

        System.runAs(clUser) {
            Test.startTest();
            // Calling  the API
            PortalFetchAllowedReportsAPI fetchAllowedReportsAPI = new PortalFetchAllowedReportsAPI();
            clcommon.Response response = fetchAllowedReportsAPI.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed'); 
            Test.stopTest();
        }
    }
   
}