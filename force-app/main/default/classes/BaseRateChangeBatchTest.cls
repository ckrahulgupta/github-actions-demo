/**
 * @description       :  Test class for Base Rate Change Batch
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 01-23-2025
 * @last modified by  : Shristy Kumari
**/
@isTest
private with sharing class BaseRateChangeBatchTest{
    /**
    * @description Test data setup
    * @author Shristy Kumari | 01-12-2025 
    **/
    @TestSetup
    private static void makeData(){
        //Creating Product
        clcommon__CL_Product__c objProduct = LoanServicingTestHelper.createLoanProduct();
        Database.insert(objProduct, true);

        //Creating Business Information
        genesis__Business_Information__c businessInfoDealer = LoanServicingTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoDealer, true);

        //Creating the dealer parent account
        Account dealerAccount = LoanServicingTestHelper.createDealerAccount(businessInfoDealer.Id);
        //Creating the CL Account
        Account clAccount = LoanServicingTestHelper.createCLAccount(businessInfoDealer.Id,dealerAccount.id);
        //Creating DBA Account
        Account accountObj = ApplicationOriginationTestHelper.createNewDBAccount(businessInfoDealer);
        Database.insert(new List<Account>{dealerAccount,clAccount,accountObj}, true);

        //Create CFA Configuration
        CFA_Configuration__c cifObj = ApplicationOriginationTestHelper.createCIFNumber();
        Database.insert(cifObj,true);

        //Creating the CL Contact
        Contact clContact = LoanServicingTestHelper.createCLContact(clAccount.Id);
        Database.insert(clContact,true);
        
        //Creating Rate Card Setup Header
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerAccount);
        Database.insert(objRateCardHeader,true);

        //Creating Product Rate Card Association
        genesis__Product_Rate_Card_Association__c rateCardProdAssociation = ApplicationOriginationTestHelper.createRateToProductAssociation(objProduct,objRateCardHeader);
        Database.insert(rateCardProdAssociation, true);

        //Additional Determing Factor for Program
        genesis__Additional_Determining_Factor__c additionalFactor = ApplicationOriginationTestHelper.createAdditionalFactorForProgram(objRateCardHeader);
        //Additional determining Factor for Dealer
        genesis__Additional_Determining_Factor__c additionalFactorDealer = ApplicationOriginationTestHelper.createAdditionalFactorForDealer(objRateCardHeader);
        Database.insert(new List<genesis__Additional_Determining_Factor__c>{additionalFactor,additionalFactorDealer},true);

        //Creating Rate Card Setup Detail
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = ApplicationOriginationTestHelper.createNewRateCardSetupDetail(objRateCardHeader);
        Database.insert(objRateCardDetail, true);

        //Creating Application with Flex Rate
        genesis__Applications__c applicationObjFlex = ApplicationOriginationTestHelper.createApplicationForFlex(objProduct,accountObj);
        Database.insert(applicationObjFlex, true);
        //Creating a cl user
        User clUser = LoanServicingTestHelper.createCLUser(clContact.Id);
        //Creating Standard User
        User objStandardUser = ApplicationOriginationTestHelper.createStandardUser();
        Database.insert(new List<User>{clUser,objStandardUser}, true);
    }
    /**
    * @description Method to fetch system admin user
    * @author Shristy Kumari | 01-06-2025 
    * @return User 
    **/
    private static User getUser(){
        List<User> objUserList = [SELECT Id 
                                    FROM User 
                                    WHERE Profile.name = 'System Administrator'
                                    AND isActive = true
                                    LIMIT 1];
                                    
        if(objUserList.size() == 1) {
            return objUserList[0];
        } 
        return null;
    }
    /**
    * @description Method to fetch cfa configuration
    * @author Shristy Kumari | 01-06-2025 
    * @return User 
    **/
    private static CFA_Configuration__c getConfig(){
        List<CFA_Configuration__c> objConfigList = [SELECT Id,
                                                        CFA_Advantage_Rate__c,
                                                        Field_Finance_Rate__c,
                                                        FS_Index_Rate__c 
                                                    FROM CFA_Configuration__c 
                                                    LIMIT 1];              
        if (objConfigList.size() == 1){
            return objConfigList[0];
        } 
        return null;
    }

    /**
    * @description Method to fetch rate card header
    * @author Shristy Kumari | 01-06-2025 
    * @return User 
    **/
    private static genesis__Rate_Card_Setup_Header__c getRateCardHeader(){
        List<genesis__Rate_Card_Setup_Header__c> rateCardSetupHeaderList = [SELECT Id, 
                                                                                Name, 
                                                                                Account__c, 
                                                                                CFA_Advantage_Rate__c, 
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
        if(rateCardSetupHeaderList.size() == 1){
            return rateCardSetupHeaderList[0];
        } 
        return null;
    }
    /**
    * @description Method to fetch cfa configuration
    * @author Shristy Kumari | 01-06-2025 
    * @return User 
    **/
    private static genesis__Rate_Card_Setup_Detail__c getRateCardDetail(){
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = [SELECT Id,
                                                                                genesis__Enabled_Flag__c,
                                                                                Interest_Rate_Type__c,
                                                                                genesis__Interest_Rate__c,
                                                                                Participation_Percentage_CFA__c,
                                                                                Participation_Percentage_Dealer__c
                                                                            FROM genesis__Rate_Card_Setup_Detail__c
                                                                            LIMIT 1];       
        if (objRateCardDetailList.size() == 1){
            return objRateCardDetailList[0];
        } 
        return null;
    }
    /**
    * @description : test success scenerio to Check Advantage Rate change
    * @author  Pritam Roy | 04-15-2024 
    **/
    @isTest
    private static void testCheckAdvantageRateSuccess(){
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = getRateCardHeader();
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = new genesis__Rate_Card_Setup_Detail__c();
        User adminUserObj = getUser();
        CFA_Configuration__c configObj = getConfig();
        configObj.CFA_Advantage_Rate__c = 13;
        configObj.Field_Finance_Rate__c = 9.5;
        configObj.FS_Index_Rate__c = 9.75;
        Database.update(configObj, true);
        objRateCardHeader.Crop_Year__c = '2023';                    
        objRateCardHeader.Field_Finance_Rate__c = 9.5;
        objRateCardHeader.FS_Index_Rate__c = 9.75;
        objRateCardHeader.CFA_Advantage_Rate__c = 13;
        Database.update(objRateCardHeader, true);
        objRateCardDetail.genesis__Enabled_Flag__c = false;
        objRateCardDetail = [SELECT Id,
                                    genesis__Enabled_Flag__c,
                                    Interest_Rate_Type__c,
                                    genesis__Interest_Rate__c
                                FROM genesis__Rate_Card_Setup_Detail__c
                                LIMIT 1];
        objRateCardDetail.Interest_Rate_Type__c = 'Variable';
        Database.update(objRateCardDetail,true);

        List<genesis__Rate_Card_Setup_Header__c> objHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        objHeaderList.add(objRateCardHeader);

        BaseRateChangeController.RateInfoWrapper wrapperObj = new BaseRateChangeController.RateInfoWrapper();
        wrapperObj.currentInterestRate = '13';
        wrapperObj.newInterestRate = '10';
        wrapperObj.selectedRate = 'CFA Advantage Rate';

        System.runAs(adminUserObj){
            Test.startTest();
            BaseRateChangeBatch batchObj = new BaseRateChangeBatch(wrapperObj,objHeaderList);
            Database.executeBatch(batchObj,1);
            Test.stopTest();
        }
        objRateCardDetail = [SELECT Id,
                                        genesis__Enabled_Flag__c,
                                        Interest_Rate_Type__c,
                                        genesis__Interest_Rate__c,
                                        Participation_Percentage_Dealer_Subsidy__c,
                                        Participation_Percentage_Dealer__c,
                                        Participation_Percentage_CFA__c
                                    FROM genesis__Rate_Card_Setup_Detail__c
                                    LIMIT 1];
        Decimal expectedInterestRate = Decimal.valueOf(wrapperObj.newInterestRate) + objRateCardDetail.Participation_Percentage_Dealer__c - objRateCardDetail.Participation_Percentage_Dealer_Subsidy__c - objRateCardDetail.Participation_Percentage_CFA__c;
        System.assertEquals(objRateCardDetail.genesis__Interest_Rate__c,expectedInterestRate,'Failed to test success scenerio for advantage rate change when interest rate is variable');
    }
    /**
    * @description : Test success scenerio to Change Advantage Rate to equal Advantage and Interest 
    * @author  Pritam Roy | 04-15-2024 
    **/
    @isTest
    private static void testChangeAdvantageRateEqualInterest(){
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = getRateCardHeader();
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = getRateCardDetail();
        User adminUserObj = getUser();
        CFA_Configuration__c configObj = getConfig();
        configObj.CFA_Advantage_Rate__c = 13;
        configObj.Field_Finance_Rate__c = 9.5;
        configObj.FS_Index_Rate__c = 9.75;
        Database.update(configObj, true);
        objRateCardHeader.Crop_Year__c = '2023';                    
        objRateCardHeader.Field_Finance_Rate__c = 9.5;
        objRateCardHeader.FS_Index_Rate__c = 9.75;
        objRateCardHeader.CFA_Advantage_Rate__c = 13;
        Database.update(objRateCardHeader, true);
        objRateCardDetail.genesis__Interest_Rate__c = 10;
        objRateCardDetail.Participation_Percentage_CFA__c = 0;
        Database.update(objRateCardDetail,true);
        List<genesis__Rate_Card_Setup_Header__c> objHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        objHeaderList.add(objRateCardHeader);
        BaseRateChangeController.RateInfoWrapper wrapperObj = new BaseRateChangeController.RateInfoWrapper();
        wrapperObj.currentInterestRate = '13';
        wrapperObj.newInterestRate = '10';
        wrapperObj.selectedRate = 'CFA Advantage Rate';

        System.runAs(adminUserObj){
            Test.startTest();
            BaseRateChangeBatch batchObj = new BaseRateChangeBatch(wrapperObj,objHeaderList);
            Database.executeBatch(batchObj,1);
            Test.stopTest();
        }
        System.assertEquals(objRateCardDetail.Participation_Percentage_Dealer__c!=null,true,'Wrong Value');
    }
    /**
    * @description : test Change Field Finance Rate success
    * @author  Pritam Roy | 04-15-2024 
    **/
    @isTest
    private static void testChangeFFRate(){
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = getRateCardHeader();
        User adminUserObj = getUser();
        CFA_Configuration__c configObj = getConfig();
        configObj.CFA_Advantage_Rate__c = 13;
        configObj.Field_Finance_Rate__c = 9.5;
        configObj.FS_Index_Rate__c = 9.75;
        Database.update(configObj, true);
        objRateCardHeader.Field_Finance_Rate__c = 9.5;
        objRateCardHeader.FS_Index_Rate__c = 9.75;
        Database.update(objRateCardHeader, true);
        List<genesis__Rate_Card_Setup_Header__c> objHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        objHeaderList.add(objRateCardHeader);
        BaseRateChangeController.RateInfoWrapper wrapperObj = new BaseRateChangeController.RateInfoWrapper();
        wrapperObj.currentInterestRate = '9.5';
        wrapperObj.newInterestRate = '10';
        wrapperObj.selectedRate = 'Field Finance Rate';
        System.runAs(adminUserObj){
            Test.startTest();
            BaseRateChangeBatch batchObj = new BaseRateChangeBatch(wrapperObj,objHeaderList);
            Database.executeBatch(batchObj,1);
            Test.stopTest();
        }
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = getRateCardDetail();
        System.assertEquals(objRateCardDetail.Participation_Percentage_Dealer__c!=null,true,'Failed to test success for change in field finance rate');
    }
    /**
    * @description : test change FF Rate for Disabled Rates Success
    * @author  Pritam Roy | 04-15-2024 
    **/
    @isTest
    private static void testChangeFFRateForDisabledRates(){
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = getRateCardHeader();
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = getRateCardDetail();
        User adminUserObj = getUser();
        CFA_Configuration__c configObj = getConfig();
        configObj.CFA_Advantage_Rate__c = 13;
        configObj.Field_Finance_Rate__c = 9.5;
        configObj.FS_Index_Rate__c = 9.75;
        Database.update(configObj, true);
        objRateCardHeader.Field_Finance_Rate__c = 9.5;
        objRateCardHeader.FS_Index_Rate__c = 9.75;
        Database.update(objRateCardHeader, true);
        objRateCardDetail.genesis__Enabled_Flag__c = false;
        objRateCardDetail.Interest_Rate_Type__c = 'Variable';
        Database.update(objRateCardDetail,true);
        List<genesis__Rate_Card_Setup_Header__c> objHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        objHeaderList.add(objRateCardHeader);
        BaseRateChangeController.RateInfoWrapper wrapperObj = new BaseRateChangeController.RateInfoWrapper();
        wrapperObj.currentInterestRate = '9.5';
        wrapperObj.newInterestRate = '10';
        wrapperObj.selectedRate = 'Field Finance Rate';                 
        System.runAs(adminUserObj){
            Test.startTest();
            BaseRateChangeBatch batchObj = new BaseRateChangeBatch(wrapperObj,objHeaderList);
            Database.executeBatch(batchObj,1);
            Test.stopTest();
        }
        objRateCardDetail = [SELECT Id, genesis__Interest_Rate__c, Participation_Percentage_Dealer__c FROM genesis__Rate_Card_Setup_Detail__c LIMIT 1];
        Decimal expectedInterestRate = 7.00 ;
        System.assertEquals(objRateCardDetail.genesis__Interest_Rate__c, expectedInterestRate, 'Failed to update genesis__Interest_Rate__c for disabled rates');
    }
    /**
    * @description :Test  Change FF Rate success with Variable Rates 
    * @author  Pritam Roy | 04-15-2024 
    **/
    @isTest
    private static void testChangeFFRateForVariableRatesSuccess(){
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = getRateCardHeader();
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = new genesis__Rate_Card_Setup_Detail__c();
        User adminUserObj = getUser();
        CFA_Configuration__c configObj = getConfig();
        configObj.CFA_Advantage_Rate__c = 13;
        configObj.Field_Finance_Rate__c = 9.5;
        configObj.FS_Index_Rate__c = 9.75;
        Database.update(configObj, true);
        objRateCardHeader.Field_Finance_Rate__c = 9.5;
        objRateCardHeader.FS_Index_Rate__c = 9.75;
        Database.update(objRateCardHeader, true);

        objRateCardDetail = [SELECT Id,
                                    genesis__Enabled_Flag__c,
                                    Interest_Rate_Type__c,
                                    genesis__Interest_Rate__c
                                FROM genesis__Rate_Card_Setup_Detail__c
                                LIMIT 1];
        objRateCardDetail.Interest_Rate_Type__c = 'Variable';
        Database.update(objRateCardDetail,true);

        List<genesis__Rate_Card_Setup_Header__c> objHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        objHeaderList.add(objRateCardHeader);

        BaseRateChangeController.RateInfoWrapper wrapperObj = new BaseRateChangeController.RateInfoWrapper();
        wrapperObj.currentInterestRate = '9.5';
        wrapperObj.newInterestRate = '10';
        wrapperObj.selectedRate = 'Field Finance Rate';
                        
        System.runAs(adminUserObj){
            Test.startTest();
            BaseRateChangeBatch batchObj = new BaseRateChangeBatch(wrapperObj,objHeaderList);
            Database.executeBatch(batchObj,1);
            Test.stopTest();
        }
        objRateCardDetail = [SELECT Id,
                                        genesis__Enabled_Flag__c,
                                        Interest_Rate_Type__c,
                                        genesis__Interest_Rate__c,
                                        Participation_Percentage_Dealer_Subsidy__c,
                                        Participation_Percentage_Dealer__c,
                                        Participation_Percentage_CFA__c
                                    FROM genesis__Rate_Card_Setup_Detail__c
                                    LIMIT 1];
        Decimal expectedInterestRate = Decimal.valueOf(wrapperObj.newInterestRate) + objRateCardDetail.Participation_Percentage_Dealer__c - objRateCardDetail.Participation_Percentage_Dealer_Subsidy__c - objRateCardDetail.Participation_Percentage_CFA__c;
        System.assertEquals(objRateCardDetail.genesis__Interest_Rate__c,expectedInterestRate,'Failed to test success scenerio for field finance rate change when interest rate is variable');
    }
    /**
    * @description : test Change FS Index Rate success scenerio
    * @author  Pritam Roy | 04-15-2024 
    **/
    @isTest
    private static void testChangeFSIndexRate(){
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = getRateCardHeader();
        User adminUserObj = getUser();
        CFA_Configuration__c configObj = getConfig();
        configObj.CFA_Advantage_Rate__c = 13;
        configObj.Field_Finance_Rate__c = 9.5;
        configObj.FS_Index_Rate__c = 9.75;
        Database.update(configObj, true);

        Account dealerAccount =  [SELECT Id,Coop_Type__c FROM Account WHERE name =: 'Kisan Loan'];
        dealerAccount.Coop_Type__c = 'Growmark';
        Database.update(dealerAccount, true);

        objRateCardHeader.Field_Finance_Rate__c = 9.5;
        objRateCardHeader.FS_Index_Rate__c = 9.75;
        objRateCardHeader.Account__c = dealerAccount.id;
        Database.update(objRateCardHeader, true);

        List<genesis__Rate_Card_Setup_Header__c> objHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        objHeaderList.add(objRateCardHeader);

        BaseRateChangeController.RateInfoWrapper wrapperObj = new BaseRateChangeController.RateInfoWrapper();
        wrapperObj.currentInterestRate = '9.75';
        wrapperObj.newInterestRate = '10';
        wrapperObj.selectedRate = 'FS Index Rate';


        System.runAs(adminUserObj){
            Test.startTest();
            BaseRateChangeBatch batchObj = new BaseRateChangeBatch(wrapperObj,objHeaderList);
            Database.executeBatch(batchObj,1);
            Test.stopTest();
        }
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = getRateCardDetail();
        System.assertEquals(objRateCardDetail.Participation_Percentage_Dealer__c!=null,true,'failed to test success scenerio when FS index is changed');
    }
    /**
    * @description : Change FS Index Rate when Interest Rate is 3%
    * @author  Pritam Roy | 04-15-2024 
    **/
    @isTest
    private static void testChangeFSIndexLowInterest(){
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = getRateCardHeader();
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = getRateCardDetail();
        User adminUserObj = getUser();
        CFA_Configuration__c configObj = getConfig();
        configObj.CFA_Advantage_Rate__c = 13;
        configObj.Field_Finance_Rate__c = 9.5;
        configObj.FS_Index_Rate__c = 9.75;
        Database.update(configObj, true);

        Account dealerAccount =  [SELECT Id,Coop_Type__c FROM Account WHERE name =: 'Kisan Loan'];
        dealerAccount.Coop_Type__c = 'Growmark';
        Database.update(dealerAccount, true);

        objRateCardHeader.Field_Finance_Rate__c = 9.5;
        objRateCardHeader.FS_Index_Rate__c = 9.75;
        objRateCardHeader.Account__c = dealerAccount.id;
        Database.update(objRateCardHeader, true);

        objRateCardDetail.genesis__Interest_Rate__c = 3;
        Database.update(objRateCardDetail,true);

        List<genesis__Rate_Card_Setup_Header__c> objHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        objHeaderList.add(objRateCardHeader);

        BaseRateChangeController.RateInfoWrapper wrapperObj = new BaseRateChangeController.RateInfoWrapper();
        wrapperObj.currentInterestRate = '9.75';
        wrapperObj.newInterestRate = '10';
        wrapperObj.selectedRate = 'FS Index Rate';

        System.runAs(adminUserObj){
            Test.startTest();
            BaseRateChangeBatch batchObj = new BaseRateChangeBatch(wrapperObj,objHeaderList);
            Database.executeBatch(batchObj,1);
            Test.stopTest();
        }
        System.assertEquals(objRateCardDetail.Participation_Percentage_Dealer__c!=null,true,'Wrong Value');
    }
    /**
    * @description : test Invalid Current interest rate exception
    * @author  Pritam Roy | 04-15-2024 
    **/
    @isTest
    private static void testExceptionWrongInput(){
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = getRateCardHeader();
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = getRateCardDetail();
        User adminUserObj = getUser();
        CFA_Configuration__c configObj = getConfig();
        configObj.CFA_Advantage_Rate__c = 13;
        configObj.Field_Finance_Rate__c = 9.5;
        configObj.FS_Index_Rate__c = 9.75;
        Database.update(configObj, true);

        Account dealerAccount =  [SELECT Id,Coop_Type__c FROM Account WHERE name =: 'Kisan Loan'];
        dealerAccount.Coop_Type__c = 'Growmark';
        Database.update(dealerAccount, true);

        objRateCardHeader.Field_Finance_Rate__c = 9.5;
        objRateCardHeader.FS_Index_Rate__c = 9.75;
        objRateCardHeader.Account__c = dealerAccount.id;
        Database.update(objRateCardHeader, true);

        objRateCardDetail.genesis__Interest_Rate__c = 3;
        Database.update(objRateCardDetail,true);

        List<genesis__Rate_Card_Setup_Header__c> objHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        objHeaderList.add(objRateCardHeader);

        BaseRateChangeController.RateInfoWrapper wrapperObj = new BaseRateChangeController.RateInfoWrapper();
        wrapperObj.currentInterestRate = '$$fg';
        wrapperObj.newInterestRate = '10';
        wrapperObj.selectedRate = 'FS Index Rate';

        System.runAs(adminUserObj){
            Test.startTest();
            BaseRateChangeBatch batchObj = new BaseRateChangeBatch(wrapperObj,objHeaderList);
            Database.executeBatch(batchObj,1);
            Test.stopTest();
        }
        List<clcommon__Log__c> logList = [SELECT Name
                                        FROM clcommon__Log__c 
                                        WHERE Name= 'BaseRateChangeBatch'
                                        LIMIT 1];
        System.assertEquals('BaseRateChangeBatch', logList[0].Name,'Exception Expected');
    }
    /**
    * @description : test No Rate Card Header exception
    * @author  Pritam Roy | 04-15-2024 
    **/
    @isTest
    private static void testExceptionNoRateCardHeader(){
        String objExceptionString = '';
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = getRateCardDetail();
        User adminUserObj = getUser();
        CFA_Configuration__c configObj = getConfig();
        configObj.CFA_Advantage_Rate__c = 13;
        configObj.Field_Finance_Rate__c = 9.5;
        configObj.FS_Index_Rate__c = 9.75;
        Database.update(configObj, true);

        Account dealerAccount =  [SELECT Id,Coop_Type__c FROM Account WHERE name =: 'Kisan Loan'];
        dealerAccount.Coop_Type__c = 'Growmark';
        Database.update(dealerAccount, true);

        objRateCardDetail.genesis__Interest_Rate__c = 3;
        Database.update(objRateCardDetail,true);

        BaseRateChangeController.RateInfoWrapper wrapperObj = new BaseRateChangeController.RateInfoWrapper();
        wrapperObj.currentInterestRate = '';
        wrapperObj.newInterestRate = '';
        wrapperObj.selectedRate = '';

        List<genesis__Rate_Card_Setup_Header__c> objHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();

        System.runAs(adminUserObj){
            Test.startTest();
            try{
                BaseRateChangeBatch objBatch = new BaseRateChangeBatch(wrapperObj,objHeaderList);
                Database.executeBatch(objBatch,1);
            }catch(Exception objException){
                objExceptionString = objException.getMessage();
            }
            Test.stopTest();
        }
        System.assertEquals(objExceptionString!=null,true,'Wrong Value');
    }
    /**
    * @description : test No Rate Change Information exception
    * @author  Pritam Roy | 04-15-2024 
    **/
    @isTest
    static void testExceptionNoRateInfo(){
        String objExceptionString = '';
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = getRateCardHeader();
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = getRateCardDetail();
        User adminUserObj = getUser();
        CFA_Configuration__c configObj = getConfig();
        configObj.CFA_Advantage_Rate__c = 13;
        configObj.Field_Finance_Rate__c = 9.5;
        configObj.FS_Index_Rate__c = 9.75;
        Database.update(configObj, true);

        Account dealerAccount =  [SELECT Id,Coop_Type__c FROM Account WHERE name =: 'Kisan Loan'];
        dealerAccount.Coop_Type__c = 'Growmark';
        Database.update(dealerAccount, true);

        objRateCardHeader.Field_Finance_Rate__c = 9.5;
        objRateCardHeader.FS_Index_Rate__c = 9.75;
        objRateCardHeader.Account__c = dealerAccount.id;
        Database.update(objRateCardHeader, true);
        
        objRateCardDetail.genesis__Interest_Rate__c = 3;
        Database.update(objRateCardDetail,true);

        List<genesis__Rate_Card_Setup_Header__c> objHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();

        System.runAs(adminUserObj){
            Test.startTest();
            try{
                BaseRateChangeBatch objBatch = new BaseRateChangeBatch(null,objHeaderList);
                Database.executeBatch(objBatch,1);
            }catch(Exception objException){
                objExceptionString = objException.getMessage();
            }
            Test.stopTest();
        }
        System.assertEquals(objExceptionString!=null,true,'Wrong Value');
    }
    /**
    * @description : test Invalid New interest rate exception
    * @author  Shristy Kumari | 01-01-2025 
    **/
    @isTest
    private static void testInvalidNewInterestRateException(){
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = getRateCardHeader();
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = getRateCardDetail();
        User adminUserObj = getUser();
        CFA_Configuration__c configObj = getConfig();
        configObj.CFA_Advantage_Rate__c = 13;
        configObj.Field_Finance_Rate__c = 9.5;
        configObj.FS_Index_Rate__c = 9.75;
        Database.update(configObj, true);

        Account dealerAccount =  [SELECT Id,Coop_Type__c FROM Account WHERE name =: 'Kisan Loan'];
        dealerAccount.Coop_Type__c = 'Growmark';
        Database.update(dealerAccount, true);

        objRateCardHeader.Field_Finance_Rate__c = 9.5;
        objRateCardHeader.FS_Index_Rate__c = 9.75;
        objRateCardHeader.Account__c = dealerAccount.id;
        Database.update(objRateCardHeader, true);

        objRateCardDetail = [SELECT Id,
                                    genesis__Enabled_Flag__c,
                                    Interest_Rate_Type__c,
                                    genesis__Interest_Rate__c
                                FROM genesis__Rate_Card_Setup_Detail__c
                                LIMIT 1];
        objRateCardDetail.genesis__Interest_Rate__c = 3;
        Database.update(objRateCardDetail,true);

        List<genesis__Rate_Card_Setup_Header__c> objHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        objHeaderList.add(objRateCardHeader);

        BaseRateChangeController.RateInfoWrapper wrapperObj = new BaseRateChangeController.RateInfoWrapper();
        wrapperObj.currentInterestRate = '9.5';
        wrapperObj.newInterestRate = '//';
        wrapperObj.selectedRate = 'FS Index Rate';

        System.runAs(adminUserObj){
            Test.startTest();
            BaseRateChangeBatch batchObj = new BaseRateChangeBatch(wrapperObj,objHeaderList);
            Database.executeBatch(batchObj,1);
            Test.stopTest();
        }
        List<clcommon__Log__c> logList = [SELECT Name
                                        FROM clcommon__Log__c 
                                        WHERE Name= 'BaseRateChangeBatch'
                                        LIMIT 1];
        System.assertEquals('BaseRateChangeBatch', logList[0].Name,'Exception Expected');
    }
    /**
    * @description : test Empty New interest rate exception
    * @author  Shristy Kumari | 01-01-2025 
    **/
    @isTest
    private static void testEmptyNewInterestRateException(){
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = getRateCardHeader();
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = getRateCardDetail();
        User adminUserObj = getUser();
        CFA_Configuration__c configObj = getConfig();
        configObj.CFA_Advantage_Rate__c = 13;
        configObj.Field_Finance_Rate__c = 9.5;
        configObj.FS_Index_Rate__c = 9.75;
        Database.update(configObj, true);

        Account dealerAccount =  [SELECT Id,Coop_Type__c FROM Account WHERE name =: 'Kisan Loan'];
        dealerAccount.Coop_Type__c = 'Growmark';
        Database.update(dealerAccount, true);

        objRateCardHeader.Field_Finance_Rate__c = 9.5;
        objRateCardHeader.FS_Index_Rate__c = 9.75;
        objRateCardHeader.Account__c = dealerAccount.id;
        Database.update(objRateCardHeader, true);

        objRateCardDetail.genesis__Interest_Rate__c = 3;
        Database.update(objRateCardDetail,true);

        List<genesis__Rate_Card_Setup_Header__c> objHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        objHeaderList.add(objRateCardHeader);

        BaseRateChangeController.RateInfoWrapper wrapperObj = new BaseRateChangeController.RateInfoWrapper();
        wrapperObj.currentInterestRate = '9.5';
        wrapperObj.newInterestRate = '';
        wrapperObj.selectedRate = 'FS Index Rate';

        System.runAs(adminUserObj){
            Test.startTest();
            BaseRateChangeBatch batchObj = new BaseRateChangeBatch(wrapperObj,objHeaderList);
            Database.executeBatch(batchObj,1);
            Test.stopTest();
        }
        List<clcommon__Log__c> logList = [SELECT Name
                                        FROM clcommon__Log__c 
                                        WHERE Name= 'BaseRateChangeBatch'
                                        LIMIT 1];
        System.assertEquals('BaseRateChangeBatch', logList[0].Name,'Exception Expected');
    }
    /**
    * @description : test Empty Current interest rate exception
    * @author  Shristy Kumari | 01-01-2025 
    **/
    @isTest
    private static void testEmptyCurrentInterestRateException(){
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = getRateCardHeader();
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = getRateCardDetail();
        User adminUserObj = getUser();
        CFA_Configuration__c configObj = getConfig();
        configObj.CFA_Advantage_Rate__c = 13;
        configObj.Field_Finance_Rate__c = 9.5;
        configObj.FS_Index_Rate__c = 9.75;
        Database.update(configObj, true);

        Account dealerAccount =  [SELECT Id,Coop_Type__c FROM Account WHERE name =: 'Kisan Loan'];
        dealerAccount.Coop_Type__c = 'Growmark';
        Database.update(dealerAccount, true);

        objRateCardHeader.Field_Finance_Rate__c = 9.5;
        objRateCardHeader.FS_Index_Rate__c = 9.75;
        objRateCardHeader.Account__c = dealerAccount.id;
        Database.update(objRateCardHeader, true);

        objRateCardDetail.genesis__Interest_Rate__c = 3;
        Database.update(objRateCardDetail,true);

        List<genesis__Rate_Card_Setup_Header__c> objHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        objHeaderList.add(objRateCardHeader);

        BaseRateChangeController.RateInfoWrapper wrapperObj = new BaseRateChangeController.RateInfoWrapper();
        wrapperObj.currentInterestRate = '';
        wrapperObj.newInterestRate = '10';
        wrapperObj.selectedRate = 'FS Index Rate';

        System.runAs(adminUserObj){
            Test.startTest();
            BaseRateChangeBatch batchObj = new BaseRateChangeBatch(wrapperObj,objHeaderList);
            Database.executeBatch(batchObj,1);
            Test.stopTest();
        }  
        List<clcommon__Log__c> logList = [SELECT Name
                                        FROM clcommon__Log__c 
                                        WHERE Name= 'BaseRateChangeBatch'
                                        LIMIT 1];
        System.assertEquals('BaseRateChangeBatch', logList[0].Name,'Exception Expected');
    }
}