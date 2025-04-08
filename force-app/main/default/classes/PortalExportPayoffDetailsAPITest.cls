/**
 * @description       : Test class for PortalExportPayoffDetailsAPI
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 01-24-2025
 * @last modified by  : Ayan Khanra
**/
@isTest
private without sharing class PortalExportPayoffDetailsAPITest {
    /**
    * @description : This test method is used to prepare the test data
    * @author Ayan Khanra | 01-16-2025 
    **/
    @TestSetup
    static void makeData(){
        ApplicationOriginationSetupTestHelper.createTestSetup();
        List<genesis__Applications__c>  applicationList= [SELECT ID,
                                                                Dealer_Name__c,
                                                                genesis__Loan_Number__c,
                                                                Dealer_Name__r.genesis__Business_Information__c 
                                                            FROM genesis__Applications__c 
                                                            WHERE Internal_Reference_Code__c = 'testApp001'];
        //create multiple user (clplus,SaAdmin)                                               
        createMultipleUser(applicationList[0].Dealer_Name__r.genesis__Business_Information__c ,applicationList[0].Dealer_Name__c,applicationList[0]);
        //create dealer applicant relation
        List<Contact> borrowerContactList = [SELECT ID,
                                                    AccountId
                                            FROM Contact
                                            WHERE Email = 'jasmin.albin@yopmail.com' Limit 1];
        Dealer_Applicant_Relationship__c dealerAppRelationObj= ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactList[0],applicationList[0].Dealer_Name__c);
        Database.insert(dealerAppRelationObj,true);
    }

    /**
    * @description : This method returns Certified lender plus user
    * @author Ayan Khanra | 01-06-2025 
    * @param contactID 
    * @return User 
    **/
    private static User createClPlusUser(Id contactID){
        Profile clProfileObj = [SELECT Id
                                FROM Profile
                                WHERE Name =: PortalConstants.CERTIFIED_LENDER_PLUS
                                LIMIT 1];
        User clUserObj = new User();
        clUserObj.Alias = 'newUser';
        clUserObj.Email='peter.geller@yopmail.com';
        clUserObj.EmailEncodingKey='UTF-8';
        clUserObj.LastName='Testing';
        clUserObj.LanguageLocaleKey='en_US';
        clUserObj.LocaleSidKey='en_US';
        clUserObj.ProfileId = clProfileObj.Id;
        clUserObj.ContactId = contactID;
        clUserObj.TimeZoneSidKey='America/Los_Angeles';
        clUserObj.UserName='peter.geller@yopmail.com';
        return clUserObj;
    }
    
    
    /**
    * @description : This method creates cl plus and sa admin user
    * @author Ayan Khanra | 01-23-2025 
    * @param dealerBusinessInfoId 
    * @param dealerAccountId 
    * @param applicationObj 
    **/
    private static void createMultipleUser(Id dealerBusinessInfoId,Id dealerAccountId,genesis__Applications__c applicationObj){
        //create account
        Account clPlusAccountObj = ApplicationOriginationTestHelper.createCLPlusAccount(dealerBusinessInfoId,dealerAccountId);        
        Account saAdminAccountObj = ApplicationOriginationTestHelper.createSAAdminAccount(dealerBusinessInfoId,dealerAccountId);
        List<Account> accountToInsertList = new List<Account>{clPlusAccountObj,saAdminAccountObj};
        Database.insert(accountToInsertList,true);
        //create contact
        Contact clPlusContactObj = ApplicationOriginationTestHelper.createCLPlusContact(clPlusAccountObj.Id);
        Contact saAdminContactObj = ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccountObj.Id);
        List<Contact> contactToInsertList = new List<Contact>{clPlusContactObj,saAdminContactObj};
        Database.insert(contactToInsertList,true);
        //create User
        User clPlusObj = createClPlusUser(clPlusContactObj.Id);
        User saAdminUserObj = ApplicationOriginationTestHelper.createSAAdminUser(saAdminContactObj.Id);
        Database.insert(new List <User>{clPlusObj,saAdminUserObj},true);
        //create party type 
        clcommon__Party_Type__c clPlusPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER PLUS');
        clcommon__Party_Type__c saAdminPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('SALES AGENT ADMIN');
        //create party
        List<clcommon__Party__c>  multiplePartyList = new List<clcommon__Party__c>();
        Map<String,Id>  clPlusPartyMap = new Map<String,Id>{
            'accountId' => clPlusAccountObj.Id,
            'contactId' => clPlusContactObj.Id,
            'partyTypeId' => clPlusPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        multiplePartyList.add(ApplicationOriginationTestHelper.createParty(clPlusPartyMap));
        Map<String,Id>  saAdminPartyMap = new Map<String,Id>{
            'accountId' => saAdminAccountObj.Id,
            'contactId' => saAdminContactObj.Id,
            'partyTypeId' => saAdminPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        multiplePartyList.add(ApplicationOriginationTestHelper.createParty(saAdminPartyMap)); 
        Database.insert(multiplePartyList,true);
    }

    /**
    * @description : This method returns user
    * @author Ayan Khanra | 01-16-2025 
    * @param name 
    * @return List<User> 
    **/
    private static User getUser(String name){
        List<User> userList = [SELECT ID 
                            FROM User 
                            WHERE UserName =: name Limit 1];
        return userList[0];                    
    }

    /**
    * @description : This method returns application
    * @author Ayan Khanra | 01-16-2025 
    * @return List<genesis__Applications__c> 
    **/
    private static List<genesis__Applications__c> getApplication(){
            return [SELECT Id,
                    genesis__Loan_Number__c
                    FROM genesis__Applications__c
                    WHERE Internal_Reference_Code__c = 'testApp001' LIMIT 1];                                  
    }

    /**
    * @description : This method returns inserted logs
    * @author Ayan Khanra | 01-16-2025  
    * @return List<clcommon__Log__c> 
    **/
    private static List<clcommon__Log__c> getInsertedLog(){
        return [SELECT ID
                FROM clcommon__Log__c 
                WHERE Name = 'PortalExportPayoffDetailsAPI' Limit 1];
    }
    
    /**
    * @description : This test method gives success response
    * @author Ayan Khanra | 01-16-2025 
    **/
    @isTest
    private static void testExportPayoffCalculatorSuccess() {
        List<genesis__Applications__c> applicationList = getApplication();
        Map<String,Object> argumentsFromPortalMap = new Map<String,Object>();
        argumentsFromPortalMap.put('loanNumber','139000');
        argumentsFromPortalMap.put('currentBalance','1000');
        argumentsFromPortalMap.put('currentInterest','31.51');
        argumentsFromPortalMap.put('currentCharges','0.0');
        argumentsFromPortalMap.put('currentTotalBalance','1003');
        argumentsFromPortalMap.put('accrualDailyFactor','0.58');
        argumentsFromPortalMap.put('estimatedBalance','1000');
        argumentsFromPortalMap.put('estimatedInterest','5');
        argumentsFromPortalMap.put('accruedDays','10');
        argumentsFromPortalMap.put('estimatedCharges','0');
        argumentsFromPortalMap.put('estimatedTotalBalance','1005');
        argumentsFromPortalMap.put('isSubTranche',true);
        argumentsFromPortalMap.put('applicationId',applicationList[0].Id);
        argumentsFromPortalMap.put('estimatedDate','2025-04-30');
        System.runAs(getUser('ross.geller@yopmail.com')){
            Test.startTest();
            PortalExportPayoffDetailsAPI portalExportPayoffAPIInst = new PortalExportPayoffDetailsAPI();
            clcommon.Response response = portalExportPayoffAPIInst.invokeAction('', new List<String>(), argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Exception occured');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method runs in the context of cl plus 
    * @author Ayan Khanra | 01-16-2025 
    **/
    @isTest
    private static void testClPlusUserContextSuccess() {
        List<genesis__Applications__c> applicationList = getApplication();
        Map<String,Object> argumentsFromPortalMap = new Map<String,Object>();
        argumentsFromPortalMap.put('loanNumber','139000');
        argumentsFromPortalMap.put('currentTotalBalance','9497.89');
        argumentsFromPortalMap.put('isSubTranche',false);
        argumentsFromPortalMap.put('applicationId',applicationList[0].Id);
        System.runAs(getUser('peter.geller@yopmail.com')){
            Test.startTest();
            PortalExportPayoffDetailsAPI portalExportPayoffAPIInst = new PortalExportPayoffDetailsAPI();
            clcommon.Response response = portalExportPayoffAPIInst.invokeAction('', new List<String>(), argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Exception occured in the context of cl plus');
            Test.stopTest();
        }
    }

    /**
    * @description : This test for runs in the context of sales agent admin
    * @author Ayan Khanra | 01-16-2025 
    **/
    @isTest
    private static void testSaAdminUserContextSuccess() {
        List<genesis__Applications__c> applicationList = getApplication();
        Map<String,Object> argumentsFromPortalMap = new Map<String,Object>();
        argumentsFromPortalMap.put('loanNumber','139000');
        argumentsFromPortalMap.put('payoffDate','2024-12-15');
        argumentsFromPortalMap.put('isSubTranche',true);
        argumentsFromPortalMap.put('applicationId',applicationList[0].Id);
        System.runAs(getUser('tim.couper@yopmail.com')){
            Test.startTest();
            PortalExportPayoffDetailsAPI portalExportPayoffAPIInst = new PortalExportPayoffDetailsAPI();
            clcommon.Response response = portalExportPayoffAPIInst.invokeAction('', new List<String>(), argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Exception occured in the context of sa admin');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method gives exception for a logged in user whose party is not linked with the application
    * @author Ayan Khanra | 01-16-2025 
    **/
    @isTest
    private static void testInvalidUserAndLogException() {
        List<genesis__Applications__c> applicationList = getApplication();
        List<clcommon__Party__c> partyList = [SELECT ID 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Type__r.Name = 'CERTIFIED LENDER'];
        Database.delete(partyList,true);                                                
        Map<String,Object> argumentsFromPortalMap = new Map<String,Object>();
        argumentsFromPortalMap.put('loanNumber','139000');
        argumentsFromPortalMap.put('payoffDate','2024-12-15');
        argumentsFromPortalMap.put('isSubTranche',true);
        argumentsFromPortalMap.put('applicationId',applicationList[0].Id);
        System.runAs(getUser('ross.geller@yopmail.com')){
            Test.startTest();
            PortalExportPayoffDetailsAPI portalExportPayoffAPIInst = new PortalExportPayoffDetailsAPI();
            clcommon.Response response = portalExportPayoffAPIInst.invokeAction('', new List<String>(), argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success response received although loggedIn user is invalid');
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Log not inserted');
            Test.stopTest();
        }
    }

    /**
    * @description : This method gives exception for null value for a parameter
    * @author Ayan Khanra | 01-16-2025 
    **/
    @isTest
    private static void testMissingValueOfKeyException() {
        List<genesis__Applications__c> applicationList = getApplication();
        Map<String,Object> argumentsFromPortalMap = new Map<String,Object>();
        argumentsFromPortalMap.put('loanNumber','139000');
        argumentsFromPortalMap.put('currentBalance',null);
        argumentsFromPortalMap.put('isSubTranche',true);
        argumentsFromPortalMap.put('applicationId',applicationList[0].Id);
        System.runAs(getUser('ross.geller@yopmail.com')){
            Test.startTest();
            PortalExportPayoffDetailsAPI portalExportPayoffAPIInst = new PortalExportPayoffDetailsAPI();
            clcommon.Response response = portalExportPayoffAPIInst.invokeAction('', new List<String>(), argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success response received although currentBalance is null');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method give exception for Not having Loan number key
    * @author Ayan Khanra | 01-16-2025 
    **/
    @isTest
    private static void testLoanNumberKeyMissingException() {
        List<genesis__Applications__c> applicationList = getApplication();
        Map<String,Object> argumentsFromPortalMap = new Map<String,Object>();
        argumentsFromPortalMap.put('','139000');
        argumentsFromPortalMap.put('currentTotalBalance',1000);
        argumentsFromPortalMap.put('isSubTranche',true);
        argumentsFromPortalMap.put('applicationId',applicationList[0].Id);
        System.runAs(getUser('ross.geller@yopmail.com')){
            Test.startTest();
            PortalExportPayoffDetailsAPI portalExportPayoffAPIInst = new PortalExportPayoffDetailsAPI();
            clcommon.Response response = portalExportPayoffAPIInst.invokeAction('', new List<String>(), argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success response received although loan no key is missing');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method give exception for Not having valid application id
    * @author Ayan Khanra | 01-16-2025 
    **/
    @isTest
    private static void testInvalidApplicationIdException() {
        Map<String,Object> argumentsFromPortalMap = new Map<String,Object>();
        argumentsFromPortalMap.put('loanNumber','139000');
        argumentsFromPortalMap.put('currentTotalBalance',1000);
        argumentsFromPortalMap.put('isSubTranche',true);
        argumentsFromPortalMap.put('applicationId','2432');
        System.runAs(getUser('ross.geller@yopmail.com')){
            Test.startTest();
            PortalExportPayoffDetailsAPI portalExportPayoffAPIInst = new PortalExportPayoffDetailsAPI();
            clcommon.Response response = portalExportPayoffAPIInst.invokeAction('', new List<String>(), argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success response received although application id is not valid');
            Test.stopTest();
        }
    }
}