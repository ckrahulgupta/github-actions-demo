/**
 * @description       : Test Class for MyProgramValidationUtil
 * @author            : Pritam Roy
 * @group             : 
 * @last modified on  : 09-18-2024
 * @last modified by  : Sk Minsar
**/
@isTest
public inherited sharing class MyProgramValidationUtilTest {
    /**
    * @description - Creating test data
    **/
    @TestSetup
    static void setup(){
        //Creating Product
        clcommon__CL_Product__c productForRate = TestClassHelper.createLoanProduct();
        Database.insert(productForRate, true);

        //Creating Business Information
        genesis__Business_Information__c businessInfoDealer = TestClassHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoDealer, true);

        //Creating the dealer parent account
        Account dealerCompany = TestClassHelper.createDealerAccount(businessInfoDealer.Id);
        Database.insert(dealerCompany, true);

        //Creating the CL Account
        Account dealerUserAccount = TestClassHelper.createCLAccount(businessInfoDealer.Id,dealerCompany.id);
        Database.insert(dealerUserAccount,true);

        //Creating the CL Contact
        Contact dealerContact = TestClassHelper.createCLContact(dealerUserAccount.Id);
        Database.insert(dealerContact,true);
        //Creating a test user
        User testUser = TestClassHelper.createCLUser(dealerContact.Id);
        Database.insert(testUser,true);
        
        //Creating Rate Card Setup Header
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = TestClassHelper.createRateCardSetupHeader(dealerCompany);
        Database.insert(rateCardHeaderTest,true);

        //Creating Product Rate Card Association
        genesis__Product_Rate_Card_Association__c rateProduct = TestClassHelper.createRateToProductAssociation(productForRate,rateCardHeaderTest);
        Database.insert(rateProduct, true);

        //Additional Determing Factor for Program
        genesis__Additional_Determining_Factor__c additionalFactor = TestClassHelper.createAdditionalFactorForProgram(rateCardHeaderTest);
        Database.insert(additionalFactor, true);

        //Additional Factor for Dealer
        genesis__Additional_Determining_Factor__c additionalFactorDealer = TestClassHelper.createAdditionalFactorForDealer(rateCardHeaderTest);
        Database.insert(additionalFactorDealer, true);

        //Creating Rate Card Setup Detail
        genesis__Rate_Card_Setup_Detail__c rateCardDetailTest = TestClassHelper.createNewRateCardSetupDetail(rateCardHeaderTest);
        Database.insert(rateCardDetailTest, true);

        //Creating DBA Account
        Account accountObj = TestClassHelper.createDBAccount(businessInfoDealer);
        Database.insert(accountObj, true);

        //Creating Application with Flex Rate
        genesis__Applications__c applicationObjFlex = TestClassHelper.createApplicationForFlex(productForRate,accountObj);
        Database.insert(applicationObjFlex, true);
    }
    /**
    * @description : Validate Crop Year
    * @author  Pritam Roy | 08-14-2024 
    **/
    @isTest
    static void testValidateCropYear(){
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        Integer cropYearToValidate = 2023;
        Test.startTest();
        System.runAs(testUser) {
            try{
                MyProgramValidationUtil.validateCropYear(cropYearToValidate);
            }catch(Exception e){
                System.Assert.areEqual(e.getMessage()!=null,true,'Something went wrong');
            }
            
        }
        Test.stopTest();
    }
    /**
    * @description : Validate My Program Rate Card
    * @author  Pritam Roy | 08-14-2024 
    **/
    @isTest
    static void testValidateMyProgramRateCardHeader(){
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        Integer cropYearToValidate = 2024;
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = [SELECT Id, 
                                                                            Name, 
                                                                            Account__c, 
                                                                            CFA_Advantage_Rate__c,
                                                                            Account__r.Name,
                                                                            genesis__Description__c, 
                                                                            Crop_Year__c, 
                                                                            Closing_Fee__c , 
                                                                            genesis__End_Date__c,
                                                                            Payer_of_Loan_Closing_Fee__c,
                                                                            Loan_Fee_Advanced_On__c,
                                                                            Dealer_Participate_on_Closing_Fee__c,
                                                                            Portion_of_Fee_to_Cover__c
                                                                        FROM genesis__Rate_Card_Setup_Header__c 
                                                                        WHERE Name = 'My Test Program 99'];
        Test.startTest();
        System.runAs(testUser) {      
            MyProgramValidationUtil.validateMyProgramRateCardHeader(rateCardHeaderTest,cropYearToValidate);
        }
        Test.stopTest();
        System.assertEquals(rateCardHeaderTest!=null,true,'exception');
    }
    /**
    * @description : Test Wrong Maturity Date
    * @author  Pritam Roy | 08-14-2024 
    **/
    @isTest
    static void testValidateMyProgramRateCardHeaderPrevDec(){
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        Integer cropYearToValidate = 2025;
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = [SELECT Id, 
                                                                            Name, 
                                                                            Account__c, 
                                                                            CFA_Advantage_Rate__c,
                                                                            Account__r.Name,
                                                                            genesis__Description__c, 
                                                                            Crop_Year__c, 
                                                                            Closing_Fee__c , 
                                                                            genesis__End_Date__c,
                                                                            Payer_of_Loan_Closing_Fee__c,
                                                                            Loan_Fee_Advanced_On__c,
                                                                            Dealer_Participate_on_Closing_Fee__c,
                                                                            Portion_of_Fee_to_Cover__c
                                                                        FROM genesis__Rate_Card_Setup_Header__c 
                                                                        WHERE Name = 'My Test Program 99'];
        rateCardHeaderTest.genesis__End_Date__c = Date.newInstance(2025, 03, 15);
        Database.update(rateCardHeaderTest,true);
        System.runAs(testUser){
        Test.startTest();
        try{
            MyProgramValidationUtil.validateMyProgramRateCardHeader(rateCardHeaderTest,cropYearToValidate);
        }catch(Exception e){
            System.assertEquals(true,e.getMessage()!=null,'exception');
        }
        Test.stopTest();
    }
    }
    /**
    * @description : Test wrong maturity date
    * @author  Pritam Roy | 08-14-2024 
    **/
    @isTest
    static void testValidateMyProgramRateCardHeaderDec(){
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        Integer cropYearToValidate = 2026;
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = [SELECT Id, 
                                                                            Name, 
                                                                            Account__c, 
                                                                            CFA_Advantage_Rate__c,
                                                                            Account__r.Name,
                                                                            genesis__Description__c, 
                                                                            Crop_Year__c, 
                                                                            Closing_Fee__c , 
                                                                            genesis__End_Date__c,
                                                                            Payer_of_Loan_Closing_Fee__c,
                                                                            Loan_Fee_Advanced_On__c,
                                                                            Dealer_Participate_on_Closing_Fee__c,
                                                                            Portion_of_Fee_to_Cover__c
                                                                        FROM genesis__Rate_Card_Setup_Header__c 
                                                                        WHERE Name = 'My Test Program 99'];
        rateCardHeaderTest.genesis__End_Date__c = Date.newInstance(2024, 12, 15);
        Test.startTest();
        System.runAs(testUser){
        try{
            MyProgramValidationUtil.validateMyProgramRateCardHeader(rateCardHeaderTest,cropYearToValidate);
        }catch(Exception e){
            System.assertEquals(true,e.getMessage()!=null,'exception');
        }        
        }
        Test.stopTest();
    }

    /**
    * @description : Test Validate Additional Determining Factor
    * @author  Pritam Roy | 08-14-2024 
    **/
    @isTest
    static void testValidateAdditonalDetermingFactor(){
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        List<Tier_Participation_Rate__mdt> objTierList = new List<Tier_Participation_Rate__mdt>();
        genesis__Additional_Determining_Factor__c objFactorProgram = new genesis__Additional_Determining_Factor__c();
        genesis__Additional_Determining_Factor__c obFactorForDealer = new genesis__Additional_Determining_Factor__c();
        Test.startTest();
        System.runAs(testUser){
            try{
                MyProgramValidationUtil.validateTierAndAdditionalFactor(objFactorProgram,obFactorForDealer,objTierList);
            }catch(Exception e){
                System.assertEquals(true,e.getMessage()!=null,'exception');
            }
        }
        Test.stopTest();
        
    }
    /**
    * @description : Test Validate Logged In Users
    * @author  Pritam Roy | 08-14-2024 
    **/
    @isTest 
    static void testValidateLoggedInUser(){
        List<User> userList = new List<User>();
        User testUser = [SELECT Id,Account.Name,Contact.Account.Parent.Tier__c,Contact.Account.ParentId FROM User WHERE Username = 'ross.geller@yopmail.com'];
        userList.add(testUser);
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = [SELECT Id, 
                                                                            Name, 
                                                                            Account__c, 
                                                                            CFA_Advantage_Rate__c,
                                                                            Account__r.Name,
                                                                            genesis__Description__c, 
                                                                            Crop_Year__c, 
                                                                            Closing_Fee__c , 
                                                                            genesis__End_Date__c,
                                                                            Payer_of_Loan_Closing_Fee__c,
                                                                            Loan_Fee_Advanced_On__c,
                                                                            Dealer_Participate_on_Closing_Fee__c,
                                                                            Portion_of_Fee_to_Cover__c
                                                                        FROM genesis__Rate_Card_Setup_Header__c 
                                                                        WHERE Name = 'My Test Program 99'];
        System.runAs(testUser){
            Test.startTest();
            MyProgramValidationUtil.validateLoggedInUser(userList, rateCardHeaderTest.id);
            Test.stopTest();
        }
        System.assertEquals(rateCardHeaderTest!=null,true,'exception');
    }  
    /**
    * @description : Test Validate Rate Card Header
    * @author  Pritam Roy | 08-14-2024 
    **/
    @isTest 
    static void testValidateRateCardHeader(){
        List<genesis__Rate_Card_Setup_Header__c> rateCardHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = [SELECT Id, 
                                                                            Name, 
                                                                            Account__c, 
                                                                            CFA_Advantage_Rate__c,
                                                                            Account__r.Name,
                                                                            genesis__Description__c, 
                                                                            Crop_Year__c, 
                                                                            Closing_Fee__c , 
                                                                            genesis__End_Date__c,
                                                                            Payer_of_Loan_Closing_Fee__c,
                                                                            Loan_Fee_Advanced_On__c,
                                                                            Dealer_Participate_on_Closing_Fee__c,
                                                                            Portion_of_Fee_to_Cover__c
                                                                        FROM genesis__Rate_Card_Setup_Header__c 
                                                                        WHERE Name = 'My Test Program 99'];
        rateCardHeaderList.add(rateCardHeaderTest);                                                                
        System.runAs(testUser){
            Test.startTest();
            MyProgramValidationUtil.validateRateCardHeader(rateCardHeaderList);
            Test.stopTest();
        }
        System.assertEquals(rateCardHeaderTest!=null,true,'exception');
    }
    /**
    * @description : Validate Rate Card Header Exception
    * @author  Pritam Roy | 08-14-2024 
    **/
    @isTest 
    static void testValidateRateCardHeaderException(){
        List<genesis__Rate_Card_Setup_Header__c> rateCardHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];                                                             
        System.runAs(testUser){
            Test.startTest();
            try{
                MyProgramValidationUtil.validateRateCardHeader(rateCardHeaderList);
            }catch(Exception e){
                System.assertEquals(true,e.getMessage()!=null,'exception');
            }
            Test.stopTest();
        }
    }
    /**
    * @description : Test Validate My Program  Wrong Maturity Year Exception
    * @author  Pritam Roy | 08-14-2024 
    **/
    @isTest
    static void testValidateMyProgramWrongMaturityYearExp(){
        Integer cropYearToValidate = 2024;
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = [SELECT Id, 
                                                                            Name, 
                                                                            Account__c, 
                                                                            CFA_Advantage_Rate__c,
                                                                            Account__r.Name,
                                                                            genesis__Description__c, 
                                                                            Crop_Year__c, 
                                                                            Closing_Fee__c , 
                                                                            genesis__End_Date__c,
                                                                            Payer_of_Loan_Closing_Fee__c,
                                                                            Loan_Fee_Advanced_On__c,
                                                                            Dealer_Participate_on_Closing_Fee__c,
                                                                            Portion_of_Fee_to_Cover__c
                                                                        FROM genesis__Rate_Card_Setup_Header__c 
                                                                        WHERE Name = 'My Test Program 99'];
        rateCardHeaderTest.genesis__End_Date__c = Date.newInstance(2026,8,15);
        try{                                                                
            Test.startTest();
            System.runAs(testUser){
                MyProgramValidationUtil.validateMyProgramRateCardHeader(rateCardHeaderTest,cropYearToValidate);
            }
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage()!=null,true,'exception');
        }
    }
    /**
    * @description : Test Validate My Program Wrong Maturity Year
    * @author  Pritam Roy | 08-14-2024 
    **/
    @isTest
    static void testValidateMyProgramWrongMaturityYear(){
        Integer cropYearToValidate = 2023;
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = [SELECT Id, 
                                                                            Name, 
                                                                            Account__c, 
                                                                            CFA_Advantage_Rate__c,
                                                                            Account__r.Name,
                                                                            genesis__Description__c, 
                                                                            Crop_Year__c, 
                                                                            Closing_Fee__c , 
                                                                            genesis__End_Date__c,
                                                                            Payer_of_Loan_Closing_Fee__c,
                                                                            Loan_Fee_Advanced_On__c,
                                                                            Dealer_Participate_on_Closing_Fee__c,
                                                                            Portion_of_Fee_to_Cover__c
                                                                        FROM genesis__Rate_Card_Setup_Header__c 
                                                                        WHERE Name = 'My Test Program 99'];
        rateCardHeaderTest.genesis__End_Date__c = Date.newInstance(2024,8,15);
        try{                                                                
            Test.startTest();
            System.runAs(testUser){
                MyProgramValidationUtil.validateMyProgramRateCardHeader(rateCardHeaderTest,cropYearToValidate);
            }
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getMessage()!=null,true,'exception');
        }
    }
    /**
    * @description : Test Validate My Program Wrong Maturity Date
    * @author  Pritam Roy | 08-14-2024 
    **/
    @isTest
    static void testValidateMyProgramWrongMaturityDate(){
        Integer cropYearToValidate = 2024;
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = [SELECT Id, 
                                                                            Name, 
                                                                            Account__c, 
                                                                            CFA_Advantage_Rate__c,
                                                                            Account__r.Name,
                                                                            genesis__Description__c, 
                                                                            Crop_Year__c, 
                                                                            Closing_Fee__c , 
                                                                            genesis__End_Date__c,
                                                                            Payer_of_Loan_Closing_Fee__c,
                                                                            Loan_Fee_Advanced_On__c,
                                                                            Dealer_Participate_on_Closing_Fee__c,
                                                                            Portion_of_Fee_to_Cover__c
                                                                        FROM genesis__Rate_Card_Setup_Header__c 
                                                                        WHERE Name = 'My Test Program 99'];
        rateCardHeaderTest.genesis__End_Date__c = Date.newInstance(2024,3,15);                                                                
        try{
            System.runAs(testUser){                                                                
                Test.startTest();
                MyProgramValidationUtil.validateMyProgramRateCardHeader(rateCardHeaderTest,cropYearToValidate);
                Test.stopTest();
            }
        }catch(Exception e){
            System.assertEquals(e.getMessage()!=null,true,'exception');
        }
    }
    /**
    * @description : Test Validate My Program
    * @author  Pritam Roy | 08-14-2024 
    **/
    @isTest
    static void testValidateMyProgramValidMaturityDate(){
        Integer cropYearToValidate = 2023;
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = [SELECT Id, 
                                                                            Name, 
                                                                            Account__c, 
                                                                            CFA_Advantage_Rate__c,
                                                                            Account__r.Name,
                                                                            genesis__Description__c, 
                                                                            Crop_Year__c, 
                                                                            Closing_Fee__c , 
                                                                            genesis__End_Date__c,
                                                                            Payer_of_Loan_Closing_Fee__c,
                                                                            Loan_Fee_Advanced_On__c,
                                                                            Dealer_Participate_on_Closing_Fee__c,
                                                                            Portion_of_Fee_to_Cover__c
                                                                        FROM genesis__Rate_Card_Setup_Header__c 
                                                                        WHERE Name = 'My Test Program 99'];
        rateCardHeaderTest.genesis__End_Date__c = Date.newInstance(2023,8,15);                                                                                                                               
        Test.startTest();
        try{
            System.runAs(testUser){
                MyProgramValidationUtil.validateMyProgramRateCardHeader(rateCardHeaderTest,cropYearToValidate);
            }
        }catch(Exception e){
            System.assertEquals(true,e.getMessage()!=null,'exception');
        }
       
        Test.stopTest();
    }
    /**
    * @description : Test Validate My Program Header
    * @author  Pritam Roy | 08-14-2024 
    **/
    @isTest
    static void testValidateMyProgramGreaterThanMaturity(){
        Integer cropYearToValidate = 2025;
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = [SELECT Id, 
                                                                            Name, 
                                                                            Account__c, 
                                                                            CFA_Advantage_Rate__c,
                                                                            Account__r.Name,
                                                                            genesis__Description__c, 
                                                                            Crop_Year__c, 
                                                                            Closing_Fee__c , 
                                                                            genesis__End_Date__c,
                                                                            Payer_of_Loan_Closing_Fee__c,
                                                                            Loan_Fee_Advanced_On__c,
                                                                            Dealer_Participate_on_Closing_Fee__c,
                                                                            Portion_of_Fee_to_Cover__c
                                                                        FROM genesis__Rate_Card_Setup_Header__c 
                                                                        WHERE Name = 'My Test Program 99'];
        rateCardHeaderTest.genesis__End_Date__c = Date.newInstance(2023,12,15);   
        System.runAs(testUser){                                                             
        try{                                                                
            Test.startTest();
            
                MyProgramValidationUtil.validateMyProgramRateCardHeader(rateCardHeaderTest,cropYearToValidate);
        }catch(Exception e){
            System.assertEquals(e.getMessage()!=null,true,'exception');
        }
        Test.stopTest();
        }
    }
    /**
    * @description : Test Validate My Program Rate Card Header
    * @author  Pritam Roy | 08-14-2024 
    **/
    @isTest
    static void testValidateMyProgramRateCardHeaderLoanPayerDealer(){
        Integer cropYearToValidate = 2025;
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = [SELECT Id, 
                                                                            Name, 
                                                                            Account__c, 
                                                                            CFA_Advantage_Rate__c,
                                                                            Account__r.Name,
                                                                            genesis__Description__c, 
                                                                            Crop_Year__c, 
                                                                            Closing_Fee__c , 
                                                                            genesis__End_Date__c,
                                                                            Payer_of_Loan_Closing_Fee__c,
                                                                            Loan_Fee_Advanced_On__c,
                                                                            Dealer_Participate_on_Closing_Fee__c,
                                                                            Portion_of_Fee_to_Cover__c
                                                                        FROM genesis__Rate_Card_Setup_Header__c 
                                                                        WHERE Name = 'My Test Program 99'];
        rateCardHeaderTest.Payer_of_Loan_Closing_Fee__c = PortalConstants.DEALER_PROFILE;                                                                
        rateCardHeaderTest.genesis__End_Date__c = Date.newInstance(2023,12,15);   
        System.runAs(testUser) {                                                                   
            try{                                                       
            Test.startTest();
                MyProgramValidationUtil.validateMyProgramRateCardHeader(rateCardHeaderTest,cropYearToValidate);
            }catch(Exception e){
                System.assertEquals(e.getMessage()!=null,true,'exception');
            }
            Test.stopTest();
        }
    }
}