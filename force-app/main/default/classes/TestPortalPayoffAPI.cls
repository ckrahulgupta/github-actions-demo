/**
 * @description       : Test class for PortalPayoffAPI
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 12-17-2024
 * @last modified by  : Sk Minsar
**/

@isTest
public with sharing class TestPortalPayoffAPI {

    /**
    * @description - Creating test data
    * @author Sk Minsar | 12-16-2024 
    **/
    @testSetup
    static void setup() {
        //Set Payment Method, 
        clcommon__Payment_Mode__c paymentMode = new clcommon__Payment_Mode__c(Name='PAYMENT');
        Database.insert(paymentMode, false);

        clcommon__Bank_Account__c bankAccount = new clcommon__Bank_Account__c(clcommon__Bank_Account_Name__c = 'Test Bank Account', clcommon__Bank_Account_Number__c = '123123123');
        Database.insert(bankAccount, false);

        // Creating floating rate index
        clcommon__Floating_Rate_Index__c floatingRateIndexObj = ApplicationOriginationTestHelper.createFloatingRateIndex(
            New Map<String, Object>{ 'Name' => 'CFA Advantage Rate',
                                        'Base Rate Name' => '4-CFA ADVANTAGE',
                                        'Current Floating Rate' => 11,
                                        'Base Rate Adjuster' => 5.5
        });
        Database.insert(floatingRateIndexObj, true);

        // Creating floating rate
        clcommon__Floating_Rate__c floatingRateObj = ApplicationOriginationTestHelper.createFloatingRate(floatingRateIndexObj);
        Database.insert(floatingRateObj, true);

        // Creating new partner program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);

        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj,true);

        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.id, newPartnerProgramObj.id);
        Database.Insert(dealerAccountObj, true);

        genesis__Applications__c objApplication = TestClassHelper.createApplication();
        objApplication.Dealer_Name__c = dealerAccountObj.Id;
        Database.Update(objApplication, true);

        genesis__Application_Pricing_Detail__c firstPricingDetails = TestClassHelper.createPricingDetail(objApplication.Id);
        genesis__Application_Pricing_Detail__c secondPricingDetails = TestClassHelper.createPricingDetail(objApplication.Id);
        firstPricingDetails.Principal_Advanced__c = 500;
        firstPricingDetails.Fees__c = 200;
        firstPricingDetails.Accrued_Interest__c = 300;
        secondPricingDetails.Principal_Advanced__c = 1000;
        secondPricingDetails.Fees__c = 200;
        secondPricingDetails.Accrued_Interest__c = 500;
        Database.update(new List<genesis__Application_Pricing_Detail__c>{firstPricingDetails, secondPricingDetails},true);
    }

    /**
    * @description - Retruns the param map
    * @author Sk Minsar | 12-17-2024 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> getParamMap(){
        Profile profile = [SELECT Id FROM Profile WHERE Name='Grower'];
        User objCurrentUser = IntegrationTestInitHelper.createUser(profile.Id);
        List<genesis__Application_Pricing_Detail__c> objPricing = [SELECT Id,
                                                                    Principal_Advanced__c,
                                                                    Fees__c,
                                                                    Accrued_Interest__c,
                                                                    Total_PayOff__c,
                                                                    genesis__Application__c
                                                                FROM  genesis__Application_Pricing_Detail__c 
                                                                ORDER BY Total_PayOff__c ASC LIMIT 2];
        clcommon__Bank_Account__c bankAccount = [SELECT Id,clcommon__Bank_Account_Name__c FROM clcommon__Bank_Account__c WHERE clcommon__Bank_Account_Name__c = 'Test Bank Account'];
        Contact objContact = [SELECT Id,Email, accountId FROM Contact WHERE Id =:objCurrentUser.ContactId]; 
        Account objAccount = [SELECT Id, Name FROM Account WHERE Id =:objContact.accountId];
        objAccount.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.upsert(objAccount);
        genesis__Applications__c objApplication = [SELECT Id from genesis__Applications__c LIMIT 1];
        objApplication.genesis__Account__c = objAccount.Id;
        objApplication.genesis__Contact__c = objContact.Id;
        Database.update(objApplication);
        //Create party with Account and Contact of Borrower Party type
        clcommon__Party__c objBorrowerParty = TestClassHelper.createParty(objAccount,objContact);
        objBorrowerParty.genesis__Application__c = objApplication.Id;
        objBorrowerParty.clcommon__Party_Types__c = 'BORROWER';
        Database.update(objBorrowerParty,true);
        //Update bank account
        bankAccount.clcommon__Account__c = objAccount.Id;
        Database.update(bankAccount,true);
        return new Map<String, Object>{
            'objPricing' => objPricing,
            'bankAccount' => bankAccount,
            'objAccount' => objAccount,
            'objCurrentUser' => objCurrentUser
        };
    }

    //Loan - A ---  500  |   300  | 200
    //Loan - B --- 1000  |   500  | 200
    //Payment:
    //Loan - A ---  200  |   100  | 100
    //Loan - B ---  200  |   100  | 100
    
    /**
    * @description - Test payment spread
    * @author Sk Minsar | 12-16-2024 
    **/
    @isTest
    public static void testPaymentSpread(){
        Map<String, Object> paramMap = getParamMap();
        Account objAccount = (Account)paramMap.get('objAccount');
        List<genesis__Application_Pricing_Detail__c> objPricing = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('objPricing');
        clcommon__Bank_Account__c bankAccount = (clcommon__Bank_Account__c)paramMap.get('bankAccount');
        User objCurrentUser = (User)paramMap.get('objCurrentUser');
        Map<String, Object> requestMap = new Map<String, Object>();

        requestMap.put('accountId', objAccount.Id);
        requestMap.put('bankDetails', bankAccount.Id);
        requestMap.put('paymentMode', 'PAYMENT');
        requestMap.put('totalPaymentAmount','800');
        requestMap.put('isPayOff','false');
        requestMap.put('payoffDetails', 
                        '['+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[0].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[0].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[0].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[0].Fees__c+',\"Id\":\"'+objPricing[0].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":400,\"Principal_To_Be_Paid__c\":200,\"Interest_To_Be_Paid__c\":100,\"Fees_To_Be_Paid__c\":100},'+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[1].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[1].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[1].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[1].Fees__c+',\"Id\":\"'+objPricing[1].Id+'\",\"genesis__Application__c\":\"'+objPricing[1].genesis__Application__c+'\",\"Payment__c\":400,\"Principal_To_Be_Paid__c\":200,\"Interest_To_Be_Paid__c\":100,\"Fees_To_Be_Paid__c\":100}]');

        System.runAs(objCurrentUser) {
            Test.startTest();
            PortalPayoffAPI testApi = new PortalPayoffAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
        
    }


    //Loan - A ---  500  |   300  | 200
    //Loan - B --- 1000  |   500  | 200
    //Payment:
    //Loan - A ---  500  |   300  | 200
    //Loan - B --- 1000  |   500  | 200
    //paying off the loan
    
    /**
    * @description - Test payment spread payoff Loan
    * @author Sk Minsar | 12-16-2024 
    **/
    @isTest
    public static void testPaymentSpreadPayoffLoan(){
        Map<String, Object> paramMap = getParamMap();
        Account objAccount = (Account)paramMap.get('objAccount');
        List<genesis__Application_Pricing_Detail__c> objPricing = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('objPricing');
        clcommon__Bank_Account__c bankAccount = (clcommon__Bank_Account__c)paramMap.get('bankAccount');
        User objCurrentUser = (User)paramMap.get('objCurrentUser');
        Map<String, Object> requestMap = new Map<String, Object>();

        requestMap.put('accountId', objAccount.Id);
        requestMap.put('bankDetails', bankAccount.Id);
        requestMap.put('paymentMode', 'PAYMENT');
        requestMap.put('totalPaymentAmount','2700');
        requestMap.put('isPayOff','false');
        requestMap.put('payoffDetails', 
                        '['+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[0].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[0].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[0].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[0].Fees__c+',\"Id\":\"'+objPricing[0].Id+'\",\"Payment__c\":1000,\"Principal_To_Be_Paid__c\":500,\"Interest_To_Be_Paid__c\":300,\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Fees_To_Be_Paid__c\":200},'+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[1].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[1].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[1].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[1].Fees__c+',\"Id\":\"'+objPricing[1].Id+'\",\"Payment__c\":1700,\"Principal_To_Be_Paid__c\":1000,\"Interest_To_Be_Paid__c\":500,\"genesis__Application__c\":\"'+objPricing[1].genesis__Application__c+'\",\"Fees_To_Be_Paid__c\":200}]');
        System.runAs(objCurrentUser) {
            Test.startTest();
            PortalPayoffAPI testApi = new PortalPayoffAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }

    //Loan - A ---  500  |   300  | 200
    //Loan - B --- 1000  |   500  | 200
    //Payment:
    //Loan - A ---  500  |   300  | 200
    //Loan - B --- 0000  |   000  | 000
    
    /**
    * @description - Test with full payoff
    * @author Sk Minsar | 12-16-2024 
    **/
    @isTest
    public static void testPaymentSpreadFullPayoffLoan(){
        Map<String, Object> paramMap = getParamMap();
        Account objAccount = (Account)paramMap.get('objAccount');
        List<genesis__Application_Pricing_Detail__c> objPricing = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('objPricing');
        clcommon__Bank_Account__c bankAccount = (clcommon__Bank_Account__c)paramMap.get('bankAccount');
        User objCurrentUser = (User)paramMap.get('objCurrentUser');
        Map<String, Object> requestMap = new Map<String, Object>();

        requestMap.put('accountId', objAccount.Id);
        requestMap.put('bankDetails', bankAccount.Id);
        requestMap.put('paymentMode', 'PAYMENT');
        requestMap.put('totalPaymentAmount','1000');
        requestMap.put('isPayOff','false');
        requestMap.put('payoffDetails', 
                        '['+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[0].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[0].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[0].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[0].Fees__c+',\"Id\":\"'+objPricing[0].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":1000,\"Principal_To_Be_Paid__c\":500,\"Interest_To_Be_Paid__c\":300,\"Fees_To_Be_Paid__c\":200},'+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[1].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[1].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[1].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[1].Fees__c+',\"Id\":\"'+objPricing[1].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":0,\"Principal_To_Be_Paid__c\":0,\"Interest_To_Be_Paid__c\":0,\"Fees_To_Be_Paid__c\":0}]');
        
        System.runAs(objCurrentUser) {
            Test.startTest();
            PortalPayoffAPI testApi = new PortalPayoffAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }

    //Loan - A ---  500  |   300  | 200
    //Loan - B --- 1000  |   500  | 200
    //Payment:
    //Loan - A ---  200  |   100  | 100
    //Loan - B --- 0000  |   000  | 000
    
    /**
    * @description - Test with half pay off
    * @author Sk Minsar | 12-16-2024 
    **/
    @isTest
    public static void testPaymentSpreadHalfPayOff(){
        Map<String, Object> paramMap = getParamMap();
        Account objAccount = (Account)paramMap.get('objAccount');
        List<genesis__Application_Pricing_Detail__c> objPricing = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('objPricing');
        clcommon__Bank_Account__c bankAccount = (clcommon__Bank_Account__c)paramMap.get('bankAccount');
        User objCurrentUser = (User)paramMap.get('objCurrentUser');
        Map<String, Object> requestMap = new Map<String, Object>();

        requestMap.put('accountId', objAccount.Id);
        requestMap.put('bankDetails', bankAccount.Id);
        requestMap.put('paymentMode', 'PAYMENT');
        requestMap.put('totalPaymentAmount','1000');
        requestMap.put('isPayOff','false');
        requestMap.put('payoffDetails', 
                        '['+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[0].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[0].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[0].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[0].Fees__c+',\"Id\":\"'+objPricing[0].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":1000,\"Principal_To_Be_Paid__c\":200,\"Interest_To_Be_Paid__c\":100,\"Fees_To_Be_Paid__c\":100},'+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[1].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[1].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[1].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[1].Fees__c+',\"Id\":\"'+objPricing[1].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":0,\"Principal_To_Be_Paid__c\":0,\"Interest_To_Be_Paid__c\":0,\"Fees_To_Be_Paid__c\":0}]');
        
        System.runAs(objCurrentUser) {
            Test.startTest();
            PortalPayoffAPI testApi = new PortalPayoffAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    } 

    //Loan - A ---  500  |   300  | 200 = 1000
    //Loan - B --- 1000  |   500  | 200 = 1700
    //Payment:
    //Loan - A ---  600  |   300  | 000 = 900
    //Loan - B --- 0000  |   000  | 000 = 0000

    /**
    * @description  - Cannot make a payment -- Principal cannot be more than outstanding amount
    * @author Sk Minsar | 12-16-2024 
    **/
    @isTest
    public static void testPaymentSpreadPrincipalMore(){
        Map<String, Object> paramMap = getParamMap();
        Account objAccount = (Account)paramMap.get('objAccount');
        List<genesis__Application_Pricing_Detail__c> objPricing = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('objPricing');
        clcommon__Bank_Account__c bankAccount = (clcommon__Bank_Account__c)paramMap.get('bankAccount');
        User objCurrentUser = (User)paramMap.get('objCurrentUser');
        Map<String, Object> requestMap = new Map<String, Object>();

        requestMap.put('accountId', objAccount.Id);
        requestMap.put('bankDetails', bankAccount.Id);
        requestMap.put('paymentMode', 'PAYMENT'); 
        requestMap.put('totalPaymentAmount','1000');
        requestMap.put('isPayOff','false');
        requestMap.put('payoffDetails', 
                        '['+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[0].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[0].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[0].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[0].Fees__c+',\"id\":\"'+objPricing[0].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":1000,\"Principal_To_Be_Paid__c\":600,\"Interest_To_Be_Paid__c\":300,\"Fees_To_Be_Paid__c\":100},'+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[1].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[1].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[1].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[1].Fees__c+',\"id\":\"'+objPricing[1].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":0,\"Principal_To_Be_Paid__c\":0,\"Interest_To_Be_Paid__c\":0,\"Fees_To_Be_Paid__c\":0}]');
        
        System.runAs(objCurrentUser) {
            Test.startTest();
            PortalPayoffAPI testApi = new PortalPayoffAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }

    //Loan - A ---  500  |   300  | 200 = 1000
    //Loan - B --- 1000  |   500  | 200 = 1700
    //Payment:
    //Loan - A ---  600  |   300  | 400 = 1300
    //Loan - B ---  900  |   900  | 900 = 2700
    
    /**
    * @description - Cannot make a payment -- Principal cannot be more than outstanding amount
    * @author Sk Minsar | 12-16-2024 
    **/
    @isTest
    public static void testPaymentSpreadPrincipalInterestFeesMore(){
        Map<String, Object> paramMap = getParamMap();
        Account objAccount = (Account)paramMap.get('objAccount');
        List<genesis__Application_Pricing_Detail__c> objPricing = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('objPricing');
        clcommon__Bank_Account__c bankAccount = (clcommon__Bank_Account__c)paramMap.get('bankAccount');
        User objCurrentUser = (User)paramMap.get('objCurrentUser');
        Map<String, Object> requestMap = new Map<String, Object>();

        requestMap.put('accountId', objAccount.Id);
        requestMap.put('bankDetails', bankAccount.Id);
        requestMap.put('paymentMode', 'PAYMENT');
        requestMap.put('totalPaymentAmount','4000');
        requestMap.put('isPayOff','false');
        requestMap.put('payoffDetails', 
                        '['+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[0].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[0].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[0].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[0].Fees__c+',\"id\":\"'+objPricing[0].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":1300,\"Principal_To_Be_Paid__c\":600,\"Interest_To_Be_Paid__c\":300,\"Fees_To_Be_Paid__c\":400},'+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[1].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[1].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[1].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[1].Fees__c+',\"id\":\"'+objPricing[1].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":2700,\"Principal_To_Be_Paid__c\":900,\"Interest_To_Be_Paid__c\":900,\"Fees_To_Be_Paid__c\":900}]');
        
        System.runAs(objCurrentUser) {
            Test.startTest();
            PortalPayoffAPI testApi = new PortalPayoffAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }


    //Loan - A ---  500  |   300  | 200
    //Loan - B --- 1000  |   500  | 200
    //Payment:
    //Loan - A ---  300  |   600  | 100
    //Loan - B --- 0000  |   000  | 000
    
    /**
    * @description - Error due to Interest Paid > Accrued Interest
    * @author Sk Minsar | 12-16-2024 
    **/
    @isTest
    public static void testPaymentSpreadInterestMore(){
        Map<String, Object> paramMap = getParamMap();
        Account objAccount = (Account)paramMap.get('objAccount');
        List<genesis__Application_Pricing_Detail__c> objPricing = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('objPricing');
        clcommon__Bank_Account__c bankAccount = (clcommon__Bank_Account__c)paramMap.get('bankAccount');
        User objCurrentUser = (User)paramMap.get('objCurrentUser');
        Map<String, Object> requestMap = new Map<String, Object>();

        requestMap.put('accountId', objAccount.Id);
        requestMap.put('bankDetails', bankAccount.Id);
        requestMap.put('paymentMode', 'PAYMENT');
        requestMap.put('totalPaymentAmount','1000');
        requestMap.put('isPayOff','false');
        requestMap.put('payoffDetails', 
                        '['+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[0].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[0].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[0].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[0].Fees__c+',\"id\":\"'+objPricing[0].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":1000,\"Principal_To_Be_Paid__c\":200,\"Interest_To_Be_Paid__c\":1000,\"Fees_To_Be_Paid__c\":100},'+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[1].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[1].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[1].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[1].Fees__c+',\"id\":\"'+objPricing[1].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":0,\"Principal_To_Be_Paid__c\":0,\"Interest_To_Be_Paid__c\":0,\"Fees_To_Be_Paid__c\":0}]');
        
        System.runAs(objCurrentUser) {
            Test.startTest();
            PortalPayoffAPI testApi = new PortalPayoffAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    } 

    //Loan - A ---  500  |   300  | 200
    //Loan - B --- 1000  |   500  | 200
    //Payment:
    //Loan - A ---  200  |   100  | 1000
    //Loan - B --- 0000  |   000  | 000

    /**
    * @description - Error due to Fees Paid > Fees Remaining
    * @author Sk Minsar | 12-16-2024 
    **/
    @isTest
    public static void testPaymentSpreadFeesMore(){
        Map<String, Object> paramMap = getParamMap();
        Account objAccount = (Account)paramMap.get('objAccount');
        List<genesis__Application_Pricing_Detail__c> objPricing = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('objPricing');
        clcommon__Bank_Account__c bankAccount = (clcommon__Bank_Account__c)paramMap.get('bankAccount');
        User objCurrentUser = (User)paramMap.get('objCurrentUser');
        Map<String, Object> requestMap = new Map<String, Object>();
        
        requestMap.put('accountId', objAccount.Id);
        requestMap.put('bankDetails', bankAccount.Id);
        requestMap.put('paymentMode', 'PAYMENT');
        requestMap.put('totalPaymentAmount','1000');
        requestMap.put('isPayOff','false');
        requestMap.put('payoffDetails', 
                        '['+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[0].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[0].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[0].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[0].Fees__c+',\"id\":\"'+objPricing[0].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":1000,\"Principal_To_Be_Paid__c\":200,\"Interest_To_Be_Paid__c\":100,\"Fees_To_Be_Paid__c\":1000},'+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[1].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[1].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[1].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[1].Fees__c+',\"id\":\"'+objPricing[1].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":0,\"Principal_To_Be_Paid__c\":0,\"Interest_To_Be_Paid__c\":0,\"Fees_To_Be_Paid__c\":0}]');
        
        System.runAs(objCurrentUser) {
            Test.startTest();
            PortalPayoffAPI testApi = new PortalPayoffAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    } 

     //Loan - A ---  500  |   300  | 200
    //Loan - B --- 1000  |   500  | 200
    //Payment:
    //Loan - A ---  200  |   100  | 1000
    //Loan - B --- 0000  |   000  | 000
    //Error Payment mode is null
    
    /**
    * @description - Error due to Fees Paid > Fees Remaining
    * @author Sk Minsar | 12-16-2024 
    **/
    @isTest
    public static void testPaymentSpreadNullPaymentMode(){
        Map<String, Object> paramMap = getParamMap();
        Account objAccount = (Account)paramMap.get('objAccount');
        List<genesis__Application_Pricing_Detail__c> objPricing = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('objPricing');
        clcommon__Bank_Account__c bankAccount = (clcommon__Bank_Account__c)paramMap.get('bankAccount');
        User objCurrentUser = (User)paramMap.get('objCurrentUser');
        Map<String, Object> requestMap = new Map<String, Object>();

        requestMap.put('accountId', objAccount.Id);
        requestMap.put('bankDetails', bankAccount.Id);
        requestMap.put('paymentMode', null);
        requestMap.put('totalPaymentAmount','1000');
        requestMap.put('isPayOff','false');
        requestMap.put('payoffDetails', 
                        '['+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[0].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[0].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[0].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[0].Fees__c+',\"id\":\"'+objPricing[0].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":1000,\"Principal_To_Be_Paid__c\":200,\"Interest_To_Be_Paid__c\":100,\"Fees_To_Be_Paid__c\":1000},'+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[1].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[1].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[1].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[1].Fees__c+',\"id\":\"'+objPricing[1].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":0,\"Principal_To_Be_Paid__c\":0,\"Interest_To_Be_Paid__c\":0,\"Fees_To_Be_Paid__c\":0}]');
        
        System.runAs(objCurrentUser) {
            Test.startTest();
            PortalPayoffAPI testApi = new PortalPayoffAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    } 

    //Loan - A ---  500  |   300  | 200
    //Loan - B --- 1000  |   500  | 200
    //Payment:
    //Loan - A ---  200  |   100  | 1000
    //Loan - B --- 0000  |   000  | 000
    
    /**
    * @description - Error Payment mode is null
    * @author Sk Minsar | 12-16-2024 
    **/
    @isTest
    public static void testPaymentSpreadRandomPaymentMode(){
        Map<String, Object> paramMap = getParamMap();
        Account objAccount = (Account)paramMap.get('objAccount');
        List<genesis__Application_Pricing_Detail__c> objPricing = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('objPricing');
        clcommon__Bank_Account__c bankAccount = (clcommon__Bank_Account__c)paramMap.get('bankAccount');
        User objCurrentUser = (User)paramMap.get('objCurrentUser');
        Map<String, Object> requestMap = new Map<String, Object>();

        requestMap.put('accountId', objAccount.Id);
        requestMap.put('bankDetails', bankAccount.Id);
        requestMap.put('paymentMode', 'RandomValue');
        requestMap.put('totalPaymentAmount','1000');
        requestMap.put('isPayOff','false');
        requestMap.put('payoffDetails', 
                        '['+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[0].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[0].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[0].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[0].Fees__c+',\"id\":\"'+objPricing[0].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":1000,\"Principal_To_Be_Paid__c\":200,\"Interest_To_Be_Paid__c\":100,\"Fees_To_Be_Paid__c\":1000},'+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[1].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[1].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[1].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[1].Fees__c+',\"id\":\"'+objPricing[1].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":0,\"Principal_To_Be_Paid__c\":0,\"Interest_To_Be_Paid__c\":0,\"Fees_To_Be_Paid__c\":0}]');
        
        System.runAs(objCurrentUser) {
            Test.startTest();
            PortalPayoffAPI testApi = new PortalPayoffAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    } 

    //Loan - A ---  500  |   300  | 200
    //Loan - B --- 1000  |   500  | 200
    //Payment:
    //Loan - A ---  200  |   100  | 1000
    //Loan - B --- 0000  |   000  | 000
    
    /**
    * @description - Error in Payoff loan
    * @author Sk Minsar | 12-16-2024 
    **/
    @isTest
    public static void testPaymentSpreadPayoffLoanError(){
        Map<String, Object> paramMap = getParamMap();
        Account objAccount = (Account)paramMap.get('objAccount');
        List<genesis__Application_Pricing_Detail__c> objPricing = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('objPricing');
        clcommon__Bank_Account__c bankAccount = (clcommon__Bank_Account__c)paramMap.get('bankAccount');
        User objCurrentUser = (User)paramMap.get('objCurrentUser');
        Map<String, Object> requestMap = new Map<String, Object>();

        requestMap.put('accountId', objAccount.Id);
        requestMap.put('bankDetails', bankAccount.Id);
        requestMap.put('paymentMode', 'PAYMENT');
        requestMap.put('totalPaymentAmount','1000');
        requestMap.put('isPayOff','false');
        requestMap.put('payoffDetails', 
                        '['+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[0].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[0].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[0].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[0].Fees__c+',\"id\":\"'+objPricing[0].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":1000,\"Principal_To_Be_Paid__c\":200,\"Interest_To_Be_Paid__c\":100,\"Fees_To_Be_Paid__c\":1000},'+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[1].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[1].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[1].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[1].Fees__c+',\"id\":\"'+objPricing[1].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":0,\"Principal_To_Be_Paid__c\":0,\"Interest_To_Be_Paid__c\":0,\"Fees_To_Be_Paid__c\":0}]');
        
        System.runAs(objCurrentUser) {
            Test.startTest();
            PortalPayoffAPI testApi = new PortalPayoffAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    } 
    
    /**
    * @description - Required parameter missing, Principal Paid key is missing
    * @author Sk Minsar | 12-16-2024 
    **/
    @isTest
    public static void testPaymentSpreadPrincipalKeyMissing(){
        Map<String, Object> paramMap = getParamMap();
        Account objAccount = (Account)paramMap.get('objAccount');
        List<genesis__Application_Pricing_Detail__c> objPricing = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('objPricing');
        clcommon__Bank_Account__c bankAccount = (clcommon__Bank_Account__c)paramMap.get('bankAccount');
        User objCurrentUser = (User)paramMap.get('objCurrentUser');
        Map<String, Object> requestMap = new Map<String, Object>();

        requestMap.put('accountId', objAccount.Id);
        requestMap.put('bankDetails', bankAccount.Id);
        requestMap.put('paymentMode', 'PAYMENT');
        requestMap.put('totalPaymentAmount','100');
        requestMap.put('isPayOff','false');
        requestMap.put('payoffDetails', 
                        '['+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[0].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[0].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[0].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[0].Fees__c+',\"id\":\"'+objPricing[0].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":50,\"Interest_To_Be_Paid__c\":0,\"Fees_To_Be_Paid__c\":0},'+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[1].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[1].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[1].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[1].Fees__c+',\"id\":\"'+objPricing[1].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":50,\"Interest_To_Be_Paid__c\":0,\"Fees_To_Be_Paid__c\":0}]');
        
        System.runAs(objCurrentUser) {
            Test.startTest();
            PortalPayoffAPI testApi = new PortalPayoffAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }

    //Loan - A ---  500  |   300  | 200
    //Loan - B --- 1000  |   500  | 200
    //Payment:
    //Loan - A ---  100  |   100  | 100
    //Loan - B --- 100  |   100  | 100
    
    /**
    * @description - over payment is being made
    * @author Sk Minsar | 12-16-2024 
    **/
    @isTest
    public static void testPaymentSpreadOverPayment(){
        Map<String, Object> paramMap = getParamMap();
        Account objAccount = (Account)paramMap.get('objAccount');
        List<genesis__Application_Pricing_Detail__c> objPricing = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('objPricing');
        clcommon__Bank_Account__c bankAccount = (clcommon__Bank_Account__c)paramMap.get('bankAccount');
        User objCurrentUser = (User)paramMap.get('objCurrentUser');
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('accountId', objAccount.Id);
        requestMap.put('bankDetails', bankAccount.Id);
        requestMap.put('paymentMode', 'PAYMENT');
        requestMap.put('totalPaymentAmount','1000');
        requestMap.put('isPayOff','false');
        requestMap.put('payoffDetails', 
                        '['+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[0].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[0].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[0].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[0].Fees__c+',\"Id\":\"'+objPricing[0].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":1100,\"Principal_To_Be_Paid__c\":500,\"Interest_To_Be_Paid__c\":300,\"Fees_To_Be_Paid__c\":200},'+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[1].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[1].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[1].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[1].Fees__c+',\"Id\":\"'+objPricing[1].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":2100,\"Principal_To_Be_Paid__c\":0,\"Interest_To_Be_Paid__c\":0,\"Fees_To_Be_Paid__c\":0}]');
        
        System.runAs(objCurrentUser) {
            Test.startTest();
            PortalPayoffAPI testApi = new PortalPayoffAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description - Test with send email to CL
    * @author Sk Minsar | 12-16-2024 
    **/
    @isTest
    public static void testSendEmailToCL(){
        Map<String, Object> paramMap = getParamMap();
        Account objAccount = (Account)paramMap.get('objAccount');
        List<genesis__Application_Pricing_Detail__c> objPricing = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('objPricing');
        clcommon__Bank_Account__c bankAccount = (clcommon__Bank_Account__c)paramMap.get('bankAccount');
        User objCurrentUser = (User)paramMap.get('objCurrentUser');
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('accountId', objAccount.Id);
        requestMap.put('bankDetails', bankAccount.Id);
        requestMap.put('paymentMode', 'PAYMENT');
        requestMap.put('totalPaymentAmount','800');
        requestMap.put('isPayOff','false');
        requestMap.put('payoffDetails',
                       '['+
                       '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[0].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[0].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[0].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[0].Fees__c+',\"Id\":\"'+objPricing[0].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":400,\"Principal_To_Be_Paid__c\":200,\"Interest_To_Be_Paid__c\":100,\"Fees_To_Be_Paid__c\":100},'+
                       '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[1].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[1].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[1].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[1].Fees__c+',\"Id\":\"'+objPricing[1].Id+'\",\"genesis__Application__c\":\"'+objPricing[1].genesis__Application__c+'\",\"Payment__c\":400,\"Principal_To_Be_Paid__c\":200,\"Interest_To_Be_Paid__c\":100,\"Fees_To_Be_Paid__c\":100}]');
        requestMap.put('isPayOff', 'false');        
        System.runAs(objCurrentUser) {
            Test.startTest();
            PortalPayoffAPI testApi = new PortalPayoffAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');            
        }
        List<clcommon__Log__c> logs = [SELECT Id FROM clcommon__Log__c WHERE Name = 'PortalEmailToCLFail'];
        System.assertEquals(0, logs.size(),'Assertion Failed');
    }

    /**
    * @description - Test Full Payoff with small totalPaymentAmount
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testPaymentSpreadFullPayoffLoanException(){
        Map<String, Object> paramMap = getParamMap();
        Account objAccount = (Account)paramMap.get('objAccount');
        List<genesis__Application_Pricing_Detail__c> objPricing = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('objPricing');
        clcommon__Bank_Account__c bankAccount = (clcommon__Bank_Account__c)paramMap.get('bankAccount');
        User objCurrentUser = (User)paramMap.get('objCurrentUser');
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('accountId', objAccount.Id);
        requestMap.put('bankDetails', bankAccount.Id);
        requestMap.put('paymentMode', 'PAYMENT');
        requestMap.put('totalPaymentAmount','1000');
        requestMap.put('isPayOff','true');
        requestMap.put('payoffDetails', 
                        '['+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[0].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[0].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[0].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[0].Fees__c+',\"Id\":\"'+objPricing[0].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":1000,\"Principal_To_Be_Paid__c\":500,\"Interest_To_Be_Paid__c\":300,\"Fees_To_Be_Paid__c\":200},'+
                            '{\"Description__c\":\"Crop\",\"Total_PayOff__c\":'+objPricing[1].Total_PayOff__c+',\"Principal_Advanced__c\":'+objPricing[1].Principal_Advanced__c+',\"Accrued_Interest__c\":'+objPricing[1].Accrued_Interest__c+',\"genesis__Interest_Rate__c\":12,\"Fees__c\":'+objPricing[1].Fees__c+',\"Id\":\"'+objPricing[1].Id+'\",\"genesis__Application__c\":\"'+objPricing[0].genesis__Application__c+'\",\"Payment__c\":0,\"Principal_To_Be_Paid__c\":0,\"Interest_To_Be_Paid__c\":0,\"Fees_To_Be_Paid__c\":0}]');
        
        System.runAs(objCurrentUser) {
            Test.startTest();
            PortalPayoffAPI testApi = new PortalPayoffAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
}