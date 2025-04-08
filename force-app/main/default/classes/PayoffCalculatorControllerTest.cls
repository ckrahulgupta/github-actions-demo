/**
 * @description       : Test Class for PayoffCalculatorController
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 01-19-2025
 * @last modified by  : Ayan Khanra
**/
@isTest
private with sharing class PayoffCalculatorControllerTest {
    /**
    * @description : This method is to prepare data for the test class
    * @author Ayan Khanra | 01-12-2025 
    **/
    @TestSetup
    static void makeData(){
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.Insert(dealerBusinessInfoObj, true);  
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.Insert(dealerAccountObj, true);
        createMultipleUser(dealerBusinessInfoObj.Id,dealerAccountObj);
    }
    /**
    * @description : This method creates instance of Vf page
    * @author Ayan Khanra | 01-07-2025 
    * @return pageReference 
    **/
    private static pageReference createVfPageReference(){
        pageReference pageObj = Page.LoanPayoff;
        pageObj.getParameters().put('loanNumber','103000501');
        pageObj.getParameters().put('currentBalance','1000');
        pageObj.getParameters().put('currentInterest','3');
        pageObj.getParameters().put('currentCharges','0');
        pageObj.getParameters().put('currentTotalBalance','1003.56');
        pageObj.getParameters().put('accrualDailyFactor','1.910376');
        pageObj.getParameters().put('estimatedBalance','1000.1');
        pageObj.getParameters().put('estimatedInterest','32.0');
        pageObj.getParameters().put('accruedDays','10');
        pageObj.getParameters().put('estimatedCharges','0');
        pageObj.getParameters().put('estimatedTotalBalance','1005');
        pageObj.getParameters().put('maturityDate','2024-10-31');
        pageObj.getParameters().put('estimatedDate','2024-12-31');
        pageObj.getParameters().put('coopType','CFA');
        pageObj.getParameters().put('isSubTranche','True');
        pageObj.getParameters().put('cropYear','2024');
        pageObj.getParameters().put('growerName','Alex Ross');
        return pageObj;
    }

    /**
    * @description : This test method asserts valid datapoints of payoff calculator
    * @author Ayan Khanra | 01-07-2025 
    **/
    @isTest  
    private static void testPayoffController() {
        List<User> userList = getLoggedInUser(); 
        pageReference pageObj = createVfPageReference();
        Test.setCurrentPage(pageObj);  
        System.runAs(userList[0]) {
            Test.startTest();
            PayoffCalculatorController instance = new PayoffCalculatorController();
            System.assertEquals('103000501', instance.loanNumber, 'Test Failed');
            System.assertEquals('$1,000.00', instance.currentBalance, 'Current Balance should be formatted correctly');
            System.assertEquals('$3.00', instance.currentInterest, 'Current Interest should be formatted correctly');
            System.assertEquals('$0.00', instance.currentCharges, 'Current Charges should be formatted correctly');
            System.assertEquals('$1,003.56', instance.currentTotalBalance, 'Current Total Balance should be formatted correctly');
            System.assertEquals('$1.910', instance.accrualDailyFactor, 'Accrual Daily Factor should be formatted correctly');
            System.assertEquals('$1,000.10', instance.estimatedBalance, 'Estimated Balance should be formatted correctly');
            System.assertEquals('$32.00', instance.estimatedInterest, 'Estimated Interest should be formatted correctly');
            System.assertEquals('10', instance.accruedDays, 'Estimated Interest should be formatted correctly');
            System.assertEquals('$0.00', instance.estimatedCharges, 'Estimated Charges should be formatted correctly');
            System.assertEquals('$1,005.00', instance.estimatedTotalBalance, 'Estimated Total Balance should be formatted correctly');
            System.assertEquals('10/31/2024', instance.maturityDate, 'Maturity Date should be formatted correctly');
            System.assertEquals('12/31/2024', instance.estimatedDate, 'Estimated Date should be formatted correctly');
            System.assertEquals('CFA', instance.coopType, 'Cooperative Type should be CFA');
            System.assertEquals(true, instance.isSubTranche, 'isSubTranche should be true');
            System.assertEquals('2024', instance.cropYear, 'Crop Year should be 2024');
            System.assertEquals('Alex Ross', instance.growerName, 'Grower Name should be "Alex Ross"');
            Test.stopTest();
        } 
    }

    /**
    * @description : This Test method runs and validates in context of Certified Lender Plus
    * @author Ayan Khanra | 01-07-2025 
    **/
    @isTest  
    private static void testClPlusUserSuccess() {
        List<User> userList = getUser('peter.geller@yopmail.com'); 
        pageReference pageObj = createVfPageReference();
        Test.setCurrentPage(pageObj);  
        System.runAs(userList[0]) {
            Test.startTest();
            PayoffCalculatorController instance = new PayoffCalculatorController();
            System.assertEquals('103000501', instance.loanNumber, 'Test failed for certified lender plus User');
            Test.stopTest();
        } 
    }

    /**
    * @description : This method runs and validates for Sales agent Admin user
    * @author Ayan Khanra | 01-07-2025 
    **/
    @isTest  
    private static void testSAAdminUserSuccess() {
        List<User> userList = getUser('tim.couper@yopmail.com'); 
        pageReference pageObj = createVfPageReference();
        Test.setCurrentPage(pageObj);  
        System.runAs(userList[0]) {
            Test.startTest();
            PayoffCalculatorController instance = new PayoffCalculatorController();
            System.assertEquals('103000501', instance.loanNumber, 'Test failed for sales agent admin');
            Test.stopTest();
        } 
    }

    /**
    * @description : This test method gives exception for Invalid CurrentBalance
    * @author Ayan Khanra | 01-07-2025 
    **/
    @isTest  
    private static void testInvalidCurrentBalanceException() {
        List<User> userList = getLoggedInUser(); 
        pageReference pageObj = createVfPageReference();
        pageObj.getParameters().put('currentBalance','A11');
        Test.setCurrentPage(pageObj);  
        System.runAs(userList[0]) {
            Test.startTest();
            PayoffCalculatorController instance = new PayoffCalculatorController();
            System.assertEquals(null, instance.currentBalance, 'Currentbalance received from page');
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Log not inserted');
            Test.stopTest();
        }       
    }
    
    /**
    * @description : This test method gives exception for Invalid Maturity Date
    * @author Ayan Khanra | 01-07-2025 
    **/
    @isTest  
    private static void testInvalidMaturityDateException() {
        List<User> userList = getLoggedInUser(); 
        pageReference pageObj = createVfPageReference();
        pageObj.getParameters().put('maturityDate',null);
        Test.setCurrentPage(pageObj);  
        System.runAs(userList[0]) {
            Test.startTest();
            PayoffCalculatorController instance = new PayoffCalculatorController();
            System.assertEquals(null, instance.maturityDate, 'Maturity Date received page');
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Log not inserted');
            Test.stopTest();
        }       
    }
    /**
    * @description : This test method gives exception for Invalid 'accrualdailyfactor' 
    * @author Ayan Khanra | 01-07-2025 
    **/
    @isTest  
    private static void testAccrudeDailyFactorNullValueException(){
        List<User> userList = getLoggedInUser(); 
        pageReference pageObj = createVfPageReference();
        pageObj.getParameters().put('accrualDailyFactor',null);
        Test.setCurrentPage(pageObj);  
        System.runAs(userList[0]) {
            Test.startTest();
                PayoffCalculatorController instance = new PayoffCalculatorController();
                System.assertEquals(null, instance.accrualDailyFactor, 'AccrudeDailyfactor received from page');
                List<clcommon__Log__c> logList = getInsertedLog();
                System.assertEquals(1,logList.size(),'Log not inserted');
            Test.stopTest();
        }       
    }
    /**
    * @description : This test method gives exception for Invalid 'estimatedDate'
    * @author Ayan Khanra | 01-07-2025 
    **/
    @isTest  
    private static void testInvalidEstimatedDateException(){
        List<User> userList = getLoggedInUser(); 
        pageReference pageObj = createVfPageReference();
        pageObj.getParameters().put('estimatedDate',null);
        Test.setCurrentPage(pageObj);  
        System.runAs(userList[0]) {
            Test.startTest();
            PayoffCalculatorController instance = new PayoffCalculatorController();
            System.assertEquals(null, instance.estimatedDate, 'Estimated Date received from page');
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Log not inserted');
            Test.stopTest();
        }       
    }
    /**
    * @description : This method returns PaymentAdmin user
    * @author Ayan Khanra | 01-06-2025 
    * @param contactID 
    * @return User 
    **/
    private static User createPaymentAdminUser(Id contactID){
        Profile clProfileObj = [SELECT Id
                                FROM Profile
                                WHERE Name =: PortalConstants.PAYMENT_ADMINISTRATOR
                                LIMIT 1];
        User clUserObj = new User();
        clUserObj.Alias = 'newUser';
        clUserObj.Email='alexa.aston@yopmail.com';
        clUserObj.EmailEncodingKey='UTF-8';
        clUserObj.LastName='Testing';
        clUserObj.LanguageLocaleKey='en_US';
        clUserObj.LocaleSidKey='en_US';
        clUserObj.ProfileId = clProfileObj.Id;
        clUserObj.ContactId = contactID;
        clUserObj.TimeZoneSidKey='America/Los_Angeles';
        clUserObj.UserName='alexa.aston@yopmail.com';
        return clUserObj;
    }
    /**
    * @description : This method returns Certified lender plus user
    * @author Ayan Khanra | 01-06-2025 
    * @param contactID 
    * @return User 
    **/
    private static User createclPlusUser(Id contactID){
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
    * @description : This method creates Diffrent Account
    * @author Ayan Khanra | 01-06-2025 
    * @param dealerBusinessInfoId 
    * @param dealerAccountObj 
    **/
    private static void createMultipleUser(Id dealerBusinessInfoId,Account dealerAccountObj){
        //account
        Account clPlusAccountObj = ApplicationOriginationTestHelper.createCLPlusAccount(dealerBusinessInfoId,dealerAccountObj.id);
        Account paAccountObj = ApplicationOriginationTestHelper.createPaymentAdministratorAccount(dealerBusinessInfoId,dealerAccountObj.id);
        Account fsaAccountObj = ApplicationOriginationTestHelper.createFSAgentAccount(dealerBusinessInfoId,dealerAccountObj.id);
        Account saAdminAccountObj = ApplicationOriginationTestHelper.createSAAdminAccount(dealerBusinessInfoId,dealerAccountObj.id);
        List<Account> accountToInsertList = new List<Account>{clPlusAccountObj,paAccountObj,fsaAccountObj,saAdminAccountObj};
        Database.insert(accountToInsertList,true);
        //contact
        Contact clPlusContactObj = ApplicationOriginationTestHelper.createCLPlusContact(clPlusAccountObj.Id);
        Contact paContactObj = ApplicationOriginationTestHelper.createPaymentAdministratorContact(paAccountObj.Id);
        Contact fsaContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(fsaAccountObj.Id);
        Contact saAdminContactObj = ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccountObj.Id);
        List<Contact> contactToInsertList = new List<Contact>{clPlusContactObj,paContactObj,fsaContactObj,saAdminContactObj};
        Database.insert(contactToInsertList,true);
        //User
        User fsaUserObj = ApplicationOriginationTestHelper.createFSAgentUser(fsaContactObj.Id);
        User saAdminUerObj = ApplicationOriginationTestHelper.createSAAdminUser(saAdminContactObj.Id);
        User clPlusObj = createclPlusUser(clPlusContactObj.Id);
        User pauserObj = createPaymentAdminUser(paContactObj.Id);
        Database.insert(new List <User>{fsaUserObj,saAdminUerObj,clPlusObj,pauserObj},true);
    }
    /**
    * @description : Gives LoggedInUser
    * @author Ayan Khanra | 01-06-2025 
    * @return List<User> 
    **/
    private static List<User> getLoggedInUser(){
       return [SELECT Id
            FROM USER 
            WHERE Id = :UserInfo.getUserId() 
            LIMIT 1];
    }
    /**
    * @description : Returns User based on userName
    * @author Ayan Khanra | 01-07-2025 
    * @param name 
    * @return List<User> 
    **/
    private static List<User> getUser(String name){
        return [SELECT ID 
                FROM User 
                WHERE UserName =: name Limit 1];
    }
    /**
    * @description : This method returns inserted logs
    * @author Ayan Khanra | 01-07-2025 
    * @return List<clcommon__Log__c> 
    **/
    private static List<clcommon__Log__c> getInsertedLog(){
        return [SELECT ID
                FROM clcommon__Log__c 
                WHERE Name = 'PayoffCalculatorController' Limit 1];
    }

}