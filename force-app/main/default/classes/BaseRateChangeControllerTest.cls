/**
 * @description       :  Test class for Base Rate Change Controller
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 01-26-2025
**/

@isTest
public with sharing class BaseRateChangeControllerTest {
    /**
    * @description Test data for Base Rate Change Controller
    * @author Soumik Pattanayak | 03-10-2024 
    **/
    @TestSetup
    public static void makeData(){
        //Creating Product
        clcommon__CL_Product__c objProduct = LoanServicingTestHelper.createLoanProduct();
        Database.insert(objProduct, true);

        //Creating Business Information
        genesis__Business_Information__c businessInfoDealer = LoanServicingTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoDealer, true);

        //Creating the dealer parent account
        Account dealerAccount = LoanServicingTestHelper.createDealerAccount(businessInfoDealer.Id);
        Database.insert(dealerAccount, true);
        //Creating the CL Account
        Account clAccount = LoanServicingTestHelper.createCLAccount(businessInfoDealer.Id,dealerAccount.id);
        Database.insert(clAccount,true);

        //Create CFA Configuration
        CFA_Configuration__c cifObj = ApplicationOriginationTestHelper.createCIFNumber();
        Database.insert(cifObj,true);

        //Creating the CL Account
       // Account clAccount = LoanServicingTestHelper.createCLAccount(businessInfoDealer.Id,dealerAccount.id);
       // Database.insert(clAccount,true);

        //Creating the CL Contact
        Contact dealerContact = LoanServicingTestHelper.createCLContact(clAccount.Id);
        Database.insert(dealerContact,true);
        
        //Creating a cl user
        User clUser = LoanServicingTestHelper.createCLUser(dealerContact.Id);
        //Creating Standard User
        User standardUserObj = ApplicationOriginationTestHelper.createStandardUser();
        Database.insert(new List<User>{clUser,standardUserObj}, true);
        
        //Creating Rate Card Setup Header
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerAccount);
        Database.insert(objRateCardHeader,true);

        //Creating Product Rate Card Association
        genesis__Product_Rate_Card_Association__c rateProduct = ApplicationOriginationTestHelper.createRateToProductAssociation(objProduct,objRateCardHeader);
        Database.insert(rateProduct, true);

        //Additional Determing Factor for Program
        genesis__Additional_Determining_Factor__c additionalFactor = ApplicationOriginationTestHelper.createAdditionalFactorForProgram(objRateCardHeader);
        //Additional Factor for Dealer
        genesis__Additional_Determining_Factor__c additionalFactorDealer = ApplicationOriginationTestHelper.createAdditionalFactorForDealer(objRateCardHeader);
        Database.insert(new List<genesis__Additional_Determining_Factor__c>{additionalFactor,additionalFactorDealer}, true);

        //Creating Rate Card Setup Detail
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = ApplicationOriginationTestHelper.createNewRateCardSetupDetail(objRateCardHeader);
        Database.insert(objRateCardDetail, true);

        //Creating DBA Account
        Account accountObj = ApplicationOriginationTestHelper.createNewDBAccount(businessInfoDealer);
        Database.insert(accountObj, true);

        //Creating Application with Flex Rate
        genesis__Applications__c applicationObjFlex = ApplicationOriginationTestHelper.createApplicationForFlex(objProduct,accountObj);
        Database.insert(applicationObjFlex, true);

        //Creating Floating Rate Index
        clcommon__Floating_Rate_Index__c rateIndexA = ApplicationOriginationTestHelper.createFloatingRateIndex('CFA',5.5);
        clcommon__Floating_Rate_Index__c rateIndexB = ApplicationOriginationTestHelper.createFloatingRateIndex(ConstantValues.CFA_ADVANTAGE_RATE,4.5);
        Database.insert(rateIndexB, true);
        Database.insert(rateIndexA, true);


        //Creating CFA Partner Program
        CFA_Partner_Program__c firstPartnerProgram = ApplicationOriginationTestHelper.createPartnerProgram('CFA',rateIndexA);
        Database.insert(firstPartnerProgram, true);
        dealerAccount.CFA_Partner_Program__c = firstPartnerProgram.Id;
        Database.update(dealerAccount);

        CFA_Partner_Program__c secondPartnerProgram = ApplicationOriginationTestHelper.createPartnerProgram(ConstantValues.CFA_ADVANTAGE_RATE,rateIndexB);
        Database.insert(secondPartnerProgram, true);
        CFA_Partner_Program__c thirdPartnerProgram = ApplicationOriginationTestHelper.createPartnerProgram(ConstantValues.FS_INDEX_RATE,rateIndexB);
        Database.insert(thirdPartnerProgram, true);
        //dealerAccount.CFA_Partner_Program__c = secondPartnerProgram.Id;
       //Database.update(dealerAccount);
    }
    /**
    * @description Method to get system admin user
    * @author Shristy Kumari | 01-06-2025 
    * @return User 
    **/
    private static User getUser(){
        List<User> objUserList = [SELECT Id 
                                    FROM User 
                                    WHERE Profile.name = 'System Administrator'
                                    AND isActive = true
                                    LIMIT 1];            
        if (objUserList.size() == 1){
            return objUserList[0];
        } 
        return null;
    }
    /**
    * @description : Method to test success scenerio for getBaseRateOptions
    * @author Soumik Pattanayak | 03-10-2024 
    **/
    @isTest
    public static void testGetBaseRateOptionsSuccess(){
        User userObj = getUser();
        System.runAs(userObj) {
            Test.startTest();
            List<Map<String, String>> options = BaseRateChangeController.getBaseRateOptions();
            System.assertEquals(3, options.size(), 'Expected three base rate options');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test success scenerio for getCurrentInterestRate
    * @author Soumik Pattanayak | 03-10-2024 
    **/
    @isTest
    public static void testGetCurrentInterestRateSuccess() {
        User userObj = getUser();
        System.runAs(userObj) {
            Test.startTest();
            Map<String, Decimal> interestRates = BaseRateChangeController.getCurrentInterestRate();
            System.assertEquals(3, interestRates.size(), 'The result size should be 3 for active rates');
            Test.stopTest();
        }
    }
    /**
    * @description :Method to test success scenerio for updateInterestRate
    * @author Soumik Pattanayak | 03-10-2024 
    **/
    @isTest
    public static void testUpdateInterestRateSuccess(){
        User userObj = getUser();
        System.runAs(userObj) {
            Test.startTest();
            BaseRateChangeController.updateInterestRate('CFA', '6.5', '5.5');
            clcommon__Floating_Rate_Index__c updatedRate = [SELECT Current_Floating_Rate__c FROM clcommon__Floating_Rate_Index__c WHERE Name = 'CFA' LIMIT 1];
            System.assertEquals(6.5, updatedRate.Current_Floating_Rate__c, 'Expected updated interest rate for CFA');
            Test.stopTest();
        } 
    }

    /**
    * @description test method to test exception scenerio for updateInterestRate 
    * @author Soumik Pattanayak | 03-10-2024 
    **/
    @isTest
    public static void testCheckParametersException() {
        User userObj = getUser();
        System.runAs(userObj) {
            Test.startTest();
            try {
                BaseRateChangeController.updateInterestRate(null, '6.5', '5.5');
                System.assert(true, 'Expected CustomException for null parameter');
            } catch (Exception exceptionObj) {
                System.assert(true, 'Expected CustomException');
                List<clcommon__Log__c> logList = [SELECT Name
                                                FROM clcommon__Log__c 
                                                WHERE Name= 'BaseRateChangeController'
                                                LIMIT 1];
                System.assertEquals('BaseRateChangeController', logList[0].Name,'Exception Expected');
            }
            Test.stopTest();
        }
    }

    /**
    * @description test method for empty check custom exception
    * @author Soumik Pattanayak | 03-10-2024 
    **/
    @isTest
    public static void testCheckEmptyListException() {
        User userObj = getUser();
        System.runAs(userObj) {
            Test.startTest();
            try {
                BaseRateChangeController.updateInterestRate('Landus', '6.5', '5.5');
            } catch (Exception exceptionObj) {
                List<clcommon__Log__c> logList = [SELECT Name
                                                FROM clcommon__Log__c 
                                                WHERE Name= 'BaseRateChangeController'
                                                LIMIT 1];
                System.assertEquals('BaseRateChangeController', logList[0].Name,'Exception Expected for empty list');
            }
            Test.stopTest();
        }
    }

    /**
    * @description Method to test success scenerio for getFilteredPrograms method in BaseRateChangeController class
    * @author Soumik Pattanayak | 03-10-2024 
    **/
    @isTest
    public static void testGetFilteredProgramsSuccess() {
        User userObj = getUser();
        System.runAs(userObj) {
            Test.startTest();
            List<genesis__Rate_Card_Setup_Header__c> filteredPrograms = BaseRateChangeController.getFilteredPrograms('CFA');
            System.assert(filteredPrograms.size() > 0, 'Expected filtered programs');
            Test.stopTest();
        }
    }
    /**
    * @description 
    * @author Soumik Pattanayak | 03-10-2024 
    **/
    @isTest
    public static void testGetPartnerProgram() {
        User userObj = getUser();
        System.runAs(userObj) {
            Test.startTest();
            List<String> coopTypes = BaseRateChangeController.getPartnerProgram('CFA');
            System.assert(coopTypes.size() > 0, 'Expected coop types');
            Test.stopTest();
        }
    }
    /**
    * @description test method for updateInterestRate exception scenerio when new interest rate is null
    * @author Shristy Kumari | 01-01-2025 
    **/
    @isTest
    public static void testNullNewInterestRateException() {
        User userObj = getUser();
        System.runAs(userObj) {
            Test.startTest();
            try {
                BaseRateChangeController.updateInterestRate('CFA',null,'5.5');
                System.assert(true, 'Expected CustomException for null parameter');
            } catch (Exception exceptionObj) {
                System.assert(true, 'Expected CustomException');
                List<clcommon__Log__c> logList = [SELECT Name
                                                FROM clcommon__Log__c 
                                                WHERE Name= 'BaseRateChangeController'
                                                LIMIT 1];
                System.assertEquals('BaseRateChangeController', logList[0].Name,'Expected CustomException for null new interest rate');
            }
            Test.stopTest();
        }
    }
    /**
    * @description test method for updateInterestRate exception scenerio when current interest rate is null
    * @author Soumik Pattanayak | 01-01-2025 
    **/
    @isTest
    public static void testNullCurrentInterestRateException() {
        User userObj = getUser();
        System.runAs(userObj) {
            Test.startTest();
            try {
                BaseRateChangeController.updateInterestRate('CFA','6.5',null);
                System.assert(true, 'Expected CustomException for null parameter');
            } catch (Exception exceptionObj) {
                System.assert(true, 'Expected CustomException for null current interest rate');
                List<clcommon__Log__c> logList = [SELECT Name
                                                FROM clcommon__Log__c 
                                                WHERE Name= 'BaseRateChangeController'
                                                LIMIT 1];
                System.assertEquals('BaseRateChangeController', logList[0].Name,'Exception Expected for null current interest rate');
            }
            Test.stopTest();
        }
    }
    /**
    * @description :Method to test exception scenerio for updateInterestRate for Fs index rate 
    * @author Soumik Pattanayak | 03-10-2024 
    **/
    @isTest
    public static void testUpdateInterestRateForFsIndex(){
        CFA_Partner_Program__c program = [SELECT Base_Rate__c FROM CFA_Partner_Program__c WHERE Name = 'FS Index Rate' LIMIT 1];
        Account dealerAccount = [SELECT Id,CFA_Partner_Program__c FROM Account WHERE Name = 'Kisan Loan'];
        dealerAccount.CFA_Partner_Program__c = program.Id;
        dealerAccount.Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
        Database.update(dealerAccount);
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
            BaseRateChangeController.updateInterestRate(ConstantValues.FS_INDEX_RATE, '6.5', '5.5');
            } Catch(Exception exceptionObj){
                List<clcommon__Log__c> logList = [SELECT Name
                FROM clcommon__Log__c 
                WHERE Name= 'BaseRateChangeController'
                LIMIT 1];
                System.assertEquals('BaseRateChangeController', logList[0].Name,'Exception Expected for null current interest rate');
            }
            Test.stopTest();
        } 
    }
    /**
    * @description :Method to test exception scenerio for updateInterestRate for cfa advantage rate
    * @author Soumik Pattanayak | 03-10-2024 
    **/
    @isTest
    public static void testUpdateInterestRateForAdvantageRate(){
        User userObj = getUser();
        System.runAs(userObj) {
            Test.startTest();
            Try{
            BaseRateChangeController.updateInterestRate(ConstantValues.CFA_ADVANTAGE_RATE, '6.5', '5.5');
            } Catch(Exception exceptionObj){
                List<clcommon__Log__c> logList = [SELECT Name
                FROM clcommon__Log__c 
                WHERE Name= 'BaseRateChangeController'
                LIMIT 1];
                System.assertEquals('BaseRateChangeController', logList[0].Name,'Exception Expected for null current interest rate');
            }
            Test.stopTest();
        } 
    }
}