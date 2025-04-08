/**
 * @description       :  Test Class for My Program Helper
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 09-10-2024
**/
@isTest
private class MyProgramHelperTest {
    /**
    * @description : Test Setup
    * @author  Pritam Roy | 04-03-2024 
    **/
    @TestSetup
    static void setup(){
        //Creating Product
        clcommon__CL_Product__c productForRate = ApplicationOriginationTestHelper.createLoanProduct();
        Database.insert(productForRate, true);

        //Creating Business Information
        genesis__Business_Information__c businessInfoDealer = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoDealer, true);

        //Creating the dealer parent account
        Account dealerCompany = ApplicationOriginationTestHelper.createDealerAccount(businessInfoDealer.Id);
        Database.insert(dealerCompany, true);

        //Creating the CL Account
        Account dealerUserAccount = ApplicationOriginationTestHelper.createCLAccount(businessInfoDealer.Id,dealerCompany.id);
        Database.insert(dealerUserAccount,true);

        //Creating the CL Contact
        Contact dealerContact = ApplicationOriginationTestHelper.createCLContact(dealerUserAccount.Id);
        Database.insert(dealerContact,true);
        
        //Creating a test user
        User testUser = ApplicationOriginationTestHelper.createCLUser(dealerContact.Id);
        Database.insert(testUser,true);
        
        //Creating Rate Card Setup Header
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerCompany);
        Database.insert(rateCardHeaderTest,true);

        //Creating Product Rate Card Association
        genesis__Product_Rate_Card_Association__c rateProduct = ApplicationOriginationTestHelper.createRateToProductAssociation(productForRate,rateCardHeaderTest);
        Database.insert(rateProduct, true);

        //Additional Determing Factor for Program
        genesis__Additional_Determining_Factor__c additionalFactor = ApplicationOriginationTestHelper.createAdditionalFactorForProgram(rateCardHeaderTest);
        Database.insert(additionalFactor, true);

        //Additional Factor for Dealer
        genesis__Additional_Determining_Factor__c additionalFactorDealer = ApplicationOriginationTestHelper.createAdditionalFactorForDealer(rateCardHeaderTest);
        Database.insert(additionalFactorDealer, true);

        //Creating Rate Card Setup Detail
        genesis__Rate_Card_Setup_Detail__c rateCardDetailTest = ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderTest);
        Database.insert(rateCardDetailTest, true);

        //Creating Rate Card Setup Detail
        genesis__Rate_Card_Setup_Detail__c secondRateCardDetailTest = ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderTest);
        Database.insert(secondRateCardDetailTest, true);

        //Creating Legal Entity for DBA
        clcommon__Legal_Entity__c objLegalEntity = ApplicationOriginationTestHelper.createDBALegalEntity();
        Database.insert(objLegalEntity, true);

        //Creating DBA Account
        Account accountObj = ApplicationOriginationTestHelper.createDBAccount(objLegalEntity, businessInfoDealer.id);
        Database.insert(accountObj, true);

        //Creating Application with Flex Rate
        genesis__Applications__c applicationObjFlex = ApplicationOriginationTestHelper.createApplicationForFlex(productForRate,accountObj);
        Database.insert(applicationObjFlex, true);

        clcommon__Floating_Rate_Index__c floatingRateIndex = ApplicationOriginationTestHelper.createFloatingRateIndex('CFA_Advantage_Rate',11);
        Database.insert(floatingRateIndex, true);

        CFA_Partner_Program__c partnerProgram = ApplicationOriginationTestHelper.createPartnerProgram('Test Partner Program',floatingRateIndex);
        Database.insert(partnerProgram, true);

        Account account = ApplicationOriginationTestHelper.createPartnerAccount('Test Account',partnerProgram);
        Database.insert(account, true);
    }
    /**
    * @description : Get Dealer Account Success
    * @author  Pritam Roy | 04-02-2024 
    **/
    @isTest
    static void testGetDealerAccount(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        List<User> userList = new List<User>();
        System.runAs(testUser){
            userList = MyProgramHelper.getDealerAccount();
        }
        Test.stopTest();
        System.assertEquals(!userList.isEmpty(),true,'No user list found');
    }
    /**
    * @description : Get Rate Card Header Record Type
    * @author  Pritam Roy | 04-02-2024 
    **/
    @isTest
    static void testRateCardHeaderRecordType(){
        RecordType headerRecord;
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        Test.startTest();
        System.runAs(testUser){
            headerRecord = MyProgramHelper.getHeaderRecordType();
        }
        Test.stopTest();
        System.assertEquals(headerRecord!=null,true,'No header found');
    }
    /**
    * @description : Get My Program Application Id
    * @author  Pritam Roy | 04-02-2024 
    **/
    @isTest
    static void testApplicationById(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 7685 AND
                                                        genesis__Interest_Rate__c = 1.45];
        System.runAs(objAdmin){
            Test.startTest();
            genesis__Applications__c objApp = MyProgramHelper.getApplicationById(applicationObj.id);
            Test.stopTest();
            System.assertEquals(objApp!=null,true,'No application found');
        }
    }
        
    /**
    * @description : Null Application Id
    * @author  Pritam Roy | 04-02-2024 
    **/
    @isTest
    static void testNullApplicationById(){
        genesis__Applications__c objApp;
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        Test.startTest();
        System.runAs(testUser){
            objApp = MyProgramHelper.getApplicationById(NULL);
        }
        Test.stopTest();
        System.assertEquals(objApp==null,true,'Applcation found');
    }
    /**
    * @description : Validate Start Date Every Sub Tranche
    * @author  Pritam Roy | 04-02-2024 
    **/
    @isTest
    static void testValidateStartDateEverySubTranche(){
        List<genesis__Rate_Card_Setup_Header__c> rateCardHeaderTest = new List<genesis__Rate_Card_Setup_Header__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        rateCardHeaderTest = [SELECT 
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
                                    Portion_of_Fee_to_Cover__c,
                                    Base_Rate__c
                                FROM genesis__Rate_Card_Setup_Header__c];
        clcommon__Floating_Rate_Index__c floatingRateIndex = [SELECT id FROM clcommon__Floating_Rate_Index__c LIMIT 1];
        rateCardHeaderTest[0].Base_Rate__c = floatingRateIndex.id;
        update rateCardHeaderTest;
        System.runAs(testUser){
            Test.startTest();
            MyProgramHelper.validateStartDateEverySubTranche(rateCardHeaderTest[0]);
            Test.stopTest();
        }
        tempRate = [SELECT Id,
                            Name,
                            Special_Term_Reference__c
                        FROM genesis__Rate_Card_Setup_Detail__c
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account' LIMIT 1];

        System.assertEquals(tempRate.Special_Term_Reference__c!=null,true,'No Special Term Reference Found');
    }
    /**
    * @description : Different Start Date Every Sub Tranche
    * @author  Pritam Roy | 04-02-2024 
    **/
    @isTest
    static void testStartDateEveryWrongStartDateSubTranche(){
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        List<genesis__Rate_Card_Setup_Header__c> rateCardHeaderTest = new List<genesis__Rate_Card_Setup_Header__c>();
        rateCardHeaderTest = [SELECT 
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
                                    Portion_of_Fee_to_Cover__c,
                                    Base_Rate__c
                                FROM genesis__Rate_Card_Setup_Header__c LIMIT 1];
        Date objDate = Date.newInstance(2023,08,08);
        clcommon__Floating_Rate_Index__c floatingRateIndex = [SELECT id FROM clcommon__Floating_Rate_Index__c LIMIT 1];
        rateCardHeaderTest[0].Base_Rate__c = floatingRateIndex.id;
        update rateCardHeaderTest;
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = [SELECT Id FROM genesis__Rate_Card_Setup_Detail__c WHERE Start_Date__c =: objDate LIMIT 1];
        objRateCardDetail.Start_Date__c =  Date.newInstance(2023,10,08);
        Database.upsert(objRateCardDetail, true);
        System.runAs(testUser){
            Test.startTest();
            MyProgramHelper.validateStartDateEverySubTranche(rateCardHeaderTest[0]);
            Test.stopTest();
        }
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        Special_Term_Reference__c
                        FROM genesis__Rate_Card_Setup_Detail__c
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account' LIMIT 1];

        System.assertEquals(tempRate.Special_Term_Reference__c!=null,true,'No Special Term Reference Found');
    }
    /**
    * @description : Validate Loan Fee Advanced On
    * @author  Pritam Roy | 04-02-2024 
    **/
    @isTest
    static void testLoanFeeAdvancedOn(){
        List<genesis__Rate_Card_Setup_Header__c> rateCardHeaderTest = new List<genesis__Rate_Card_Setup_Header__c>();
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        rateCardHeaderTest = [SELECT 
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
        rateCardHeaderTest[0].Payer_of_Loan_Closing_Fee__c = 'Grower';
        Database.upsert(rateCardHeaderTest, true);
        System.runAs(testUser){
            Test.startTest();
            MyProgramHelper.validateLoanFeeAdvancedOn(rateCardHeaderTest[0]);
            Test.stopTest();
        }
        System.assertEquals(rateCardHeaderTest[0].Loan_Fee_Advanced_On__c!=null,true,'No Loan fee advanced on');
    }
    /**
    * @description : Validate Create Rate Card
    * @author  Pritam Roy | 04-02-2024 
    **/
    @isTest
    static void testCreateRateCardDetail(){
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        SaveRateCardDetailsHandler.TierWrapper objTierWrapper = new SaveRateCardDetailsHandler.TierWrapper();
        List<genesis__Rate_Card_Setup_Header__c> rateCardHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String,List<Object>>();
        Map<String, Object> rateCardMap = new Map<String, Object>();
        List<String> objDealerNameList = new List<String>();
        List<String> descriptionList = new List<String>();
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs(testUser){
            objTierWrapper.startDate = Date.newInstance(2023,1,1);
            objTierWrapper.endDate = Date.newInstance(2026,1,31);
            objTierWrapper.participationRate = 3;
            genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = [SELECT Id, 
                                                                                Name, 
                                                                                Account__c, 
                                                                                CFA_Advantage_Rate__c,
                                                                                Account__r.Name,
                                                                                genesis__Description__c, 
                                                                                Crop_Year__c,
                                                                                Field_Finance_Rate__c, 
                                                                                Closing_Fee__c , 
                                                                                genesis__End_Date__c,
                                                                                Payer_of_Loan_Closing_Fee__c,
                                                                                Loan_Fee_Advanced_On__c,
                                                                                Dealer_Participate_on_Closing_Fee__c,
                                                                                Portion_of_Fee_to_Cover__c
                                                                            FROM genesis__Rate_Card_Setup_Header__c];
            rateCardHeaderTest.Field_Finance_Rate__c = 9.5;
            Database.update(rateCardHeaderTest,true);
            clcommon__Floating_Rate_Index__c floatingRateIndex = [SELECT id FROM clcommon__Floating_Rate_Index__c LIMIT 1];
            rateCardHeaderTest.Base_Rate__c = floatingRateIndex.id;
            update rateCardHeaderTest;
            rateCardHeaderList.add(rateCardHeaderTest);
            genesis__Additional_Determining_Factor__c objFactorProgram =   [SELECT  Id, 
                                                                                        genesis__Field_Value__c 
                                                                                FROM genesis__Additional_Determining_Factor__c 
                                                                                WHERE genesis__Field_Value__c = :rateCardHeaderList[0].Name AND genesis__Rate_Card_Setup_Header__c = :rateCardHeaderList[0].Id
                                                                                LIMIT 1];
            genesis__Additional_Determining_Factor__c obFactorForDealer = [SELECT  Id, 
                                                                                        genesis__Field_Value__c 
                                                                                FROM genesis__Additional_Determining_Factor__c 
                                                                                WHERE genesis__Field_Value__c = :rateCardHeaderList[0].Account__r.Name AND genesis__Rate_Card_Setup_Header__c = :rateCardHeaderList[0].Id 
                                                                                LIMIT 1];
            List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = [SELECT Id,
                                                                                    Start_Date__c,
                                                                                    End_Date__c,
                                                                                    genesis__Interest_Rate__c,
                                                                                    Interest_Rate_Type__c,
                                                                                    Participation_Percentage_Dealer_Subsidy__c,
                                                                                    Participation_Percentage_Dealer__c
                                                                                FROM genesis__Rate_Card_Setup_Detail__c
                                                                                WHERE genesis__Rate_Card_Setup_Header__c =: rateCardHeaderList[0].Id LIMIT 1];
            objDealerNameList.add(rateCardHeaderList[0].Account__r.Name);
            String setupDescription = 'Seeds';
            rateCardDetailInfoMap.put('header',rateCardHeaderList);
            objProgramList.add(objFactorProgram);
            rateCardDetailInfoMap.put('program',objProgramList);
            objDealerList.add(obFactorForDealer);
            rateCardDetailInfoMap.put('dealer', objDealerList); 
            rateCardDetailInfoMap.put('detail',rateCardDetailList);
            rateCardDetailInfoMap.put('dealerName',objDealerNameList);
            descriptionList.add(setupDescription);
            rateCardDetailInfoMap.put('description',descriptionList);
            rateCardDetailInfoMap.put('assignBillingDate', new List<Boolean>{true});
            rateCardDetailInfoMap.put('billingDate', new List<Date>{Date.newInstance(2026,1,31)});
            rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(rateCardDetailList[0]));
            Test.startTest();
            MyProgramHelper.createRateCardDetail(objTierWrapper,rateCardMap,rateCardDetailInfoMap);
            Test.stopTest();
        }
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = [SELECT Id FROM genesis__Rate_Card_Setup_Detail__c];
        System.assertEquals(!objRateCardDetailList.isEmpty(),true,'No Rate Card Setup Details are created');
    }
    /**
    * @description : Interest Rate is greater than Field Finance Rate
    * @author  Pritam Roy | 04-02-2024 
    **/
    @isTest
    static void testCreateRateCardDetailInterestRateGreaterThanFieldFinanceRate(){
        
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        SaveRateCardDetailsHandler.TierWrapper objTierWrapper = new SaveRateCardDetailsHandler.TierWrapper();
        List<genesis__Rate_Card_Setup_Header__c> rateCardHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String,List<Object>>();
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(testUser){
            Map<String, Object> rateCardMap = new Map<String, Object>();
            List<String> objDealerNameList = new List<String>();
            List<String> descriptionList = new List<String>();
            objTierWrapper.startDate = Date.newInstance(2023,1,1);
            objTierWrapper.endDate = Date.newInstance(2026,1,31);
            objTierWrapper.participationRate = 3;
            genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = [SELECT Id, 
                                                                                Name, 
                                                                                Account__c, 
                                                                                CFA_Advantage_Rate__c,
                                                                                Account__r.Name,
                                                                                genesis__Description__c, 
                                                                                Crop_Year__c,
                                                                                Field_Finance_Rate__c, 
                                                                                Closing_Fee__c , 
                                                                                genesis__End_Date__c,
                                                                                Payer_of_Loan_Closing_Fee__c,
                                                                                Loan_Fee_Advanced_On__c,
                                                                                Dealer_Participate_on_Closing_Fee__c,
                                                                                Portion_of_Fee_to_Cover__c
                                                                            FROM genesis__Rate_Card_Setup_Header__c 
                                                                            WHERE Name = 'My Test Program 99'];
            rateCardHeaderTest.Field_Finance_Rate__c = 9.5;
            Database.update(rateCardHeaderTest,true);
            rateCardHeaderList.add(rateCardHeaderTest);
            genesis__Additional_Determining_Factor__c objFactorProgram =   [SELECT  Id, 
                                                                                        genesis__Field_Value__c 
                                                                                FROM genesis__Additional_Determining_Factor__c 
                                                                                WHERE genesis__Field_Value__c = :rateCardHeaderList[0].Name AND genesis__Rate_Card_Setup_Header__c = :rateCardHeaderList[0].Id
                                                                                LIMIT 1];
            genesis__Additional_Determining_Factor__c obFactorForDealer = [SELECT  Id, 
                                                                                        genesis__Field_Value__c 
                                                                                FROM genesis__Additional_Determining_Factor__c 
                                                                                WHERE genesis__Field_Value__c = :rateCardHeaderList[0].Account__r.Name AND genesis__Rate_Card_Setup_Header__c = :rateCardHeaderList[0].Id 
                                                                                LIMIT 1];
            List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = [SELECT Id,
                                                                                    Start_Date__c,
                                                                                    End_Date__c,
                                                                                    genesis__Interest_Rate__c,
                                                                                    Interest_Rate_Type__c,
                                                                                    Participation_Percentage_Dealer_Subsidy__c,
                                                                                    Participation_Percentage_Dealer__c
                                                                                FROM genesis__Rate_Card_Setup_Detail__c
                                                                                WHERE genesis__Rate_Card_Setup_Header__c =: rateCardHeaderList[0].Id LIMIT 1];
            rateCardDetailList[0].genesis__Interest_Rate__c = 15;                                                                   
            objDealerNameList.add(rateCardHeaderList[0].Account__r.Name);
            String setupDescription = 'Seeds';
            rateCardDetailInfoMap.put('header',rateCardHeaderList);
            objProgramList.add(objFactorProgram);
            rateCardDetailInfoMap.put('program',objProgramList);
            objDealerList.add(obFactorForDealer);
            rateCardDetailInfoMap.put('dealer', objDealerList); 
            rateCardDetailInfoMap.put('detail',rateCardDetailList);
            rateCardDetailInfoMap.put('dealerName',objDealerNameList);
            descriptionList.add(setupDescription);
            rateCardDetailInfoMap.put('description',descriptionList);
            rateCardDetailInfoMap.put('assignBillingDate', new List<Boolean>{true});
            rateCardDetailInfoMap.put('billingDate', new List<Date>{Date.newInstance(2026,1,31)});
            rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(rateCardDetailList[0]));
                Test.startTest();
                MyProgramHelper.createRateCardDetail(objTierWrapper,rateCardMap,rateCardDetailInfoMap);
                Test.stopTest();
        }
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = [SELECT Id FROM genesis__Rate_Card_Setup_Detail__c];
        System.assertEquals(!objRateCardDetailList.isEmpty(),true,'No Rate Card Setup Details are created');
    }
    /**
    * @description : Interest Rate is less than Field Finance Rate
    * @author  Pritam Roy | 04-02-2024 
    **/
    @isTest
    static void testCreateRateCardDetailInterestRateLessThanFieldFinanceRate(){
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(testUser){
            Map<String, List<Object>> rateCardDetailInfoMap = new Map<String,List<Object>>();
            SaveRateCardDetailsHandler.TierWrapper objTierWrapper = new SaveRateCardDetailsHandler.TierWrapper();
            List<genesis__Rate_Card_Setup_Header__c> rateCardHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
            Map<String, Object> rateCardMap = new Map<String, Object>();
            List<String> objDealerNameList = new List<String>();
            List<String> descriptionList = new List<String>();
            objTierWrapper.startDate = Date.newInstance(2023,1,1);
            objTierWrapper.endDate = Date.newInstance(2026,1,31);
            objTierWrapper.participationRate = 3;
            genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = [SELECT Id, 
                                                                                Name, 
                                                                                Account__c, 
                                                                                CFA_Advantage_Rate__c,
                                                                                Account__r.Name,
                                                                                genesis__Description__c, 
                                                                                Crop_Year__c,
                                                                                Field_Finance_Rate__c, 
                                                                                Closing_Fee__c , 
                                                                                genesis__End_Date__c,
                                                                                Payer_of_Loan_Closing_Fee__c,
                                                                                Loan_Fee_Advanced_On__c,
                                                                                Dealer_Participate_on_Closing_Fee__c,
                                                                                Portion_of_Fee_to_Cover__c
                                                                            FROM genesis__Rate_Card_Setup_Header__c 
                                                                            WHERE Name = 'My Test Program 99'];
            rateCardHeaderTest.Field_Finance_Rate__c = 9.5;
            Database.update(rateCardHeaderTest,true);
            rateCardHeaderList.add(rateCardHeaderTest);
            genesis__Additional_Determining_Factor__c objFactorProgram =   [SELECT  Id, 
                                                                                        genesis__Field_Value__c 
                                                                                FROM genesis__Additional_Determining_Factor__c 
                                                                                WHERE genesis__Field_Value__c = :rateCardHeaderList[0].Name AND genesis__Rate_Card_Setup_Header__c = :rateCardHeaderList[0].Id
                                                                                LIMIT 1];
            genesis__Additional_Determining_Factor__c obFactorForDealer = [SELECT  Id, 
                                                                                        genesis__Field_Value__c 
                                                                                FROM genesis__Additional_Determining_Factor__c 
                                                                                WHERE genesis__Field_Value__c = :rateCardHeaderList[0].Account__r.Name AND genesis__Rate_Card_Setup_Header__c = :rateCardHeaderList[0].Id 
                                                                                LIMIT 1];
            List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = [SELECT Id,
                                                                                    Start_Date__c,
                                                                                    End_Date__c,
                                                                                    genesis__Interest_Rate__c,
                                                                                    Interest_Rate_Type__c,
                                                                                    Participation_Percentage_Dealer_Subsidy__c,
                                                                                    Participation_Percentage_Dealer__c
                                                                                FROM genesis__Rate_Card_Setup_Detail__c
                                                                                WHERE genesis__Rate_Card_Setup_Header__c =: rateCardHeaderList[0].Id LIMIT 1];
            rateCardDetailList[0].genesis__Interest_Rate__c = 0;   
            //Database.upsert(rateCardDetailList,true);                                                                 
            objDealerNameList.add(rateCardHeaderList[0].Account__r.Name);
            String setupDescription = 'Seeds';
            rateCardDetailInfoMap.put('header',rateCardHeaderList);
            objProgramList.add(objFactorProgram);
            rateCardDetailInfoMap.put('program',objProgramList);
            objDealerList.add(obFactorForDealer);
            rateCardDetailInfoMap.put('dealer', objDealerList); 
            rateCardDetailInfoMap.put('detail',rateCardDetailList);
            rateCardDetailInfoMap.put('dealerName',objDealerNameList);
            descriptionList.add(setupDescription);
            rateCardDetailInfoMap.put('description',descriptionList);
            rateCardDetailInfoMap.put('assignBillingDate', new List<Boolean>{true});
            rateCardDetailInfoMap.put('billingDate', new List<Date>{Date.newInstance(2026,1,31)});
            rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(rateCardDetailList[0]));
                Test.startTest();
                MyProgramHelper.createRateCardDetail(objTierWrapper,rateCardMap,rateCardDetailInfoMap);
                Test.stopTest();
        }
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = [SELECT Id FROM genesis__Rate_Card_Setup_Detail__c];
        System.assertEquals(!objRateCardDetailList.isEmpty(),true,'No Rate Card Setup Details are created');
    }
    /**
    * @description : Create Default Rate Card 
    * @author  Pritam Roy | 04-02-2024 
    **/
    @isTest
    static void testCreateRateCardDefaultDetail(){
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String,List<Object>>();
        Map<String, Object> rateCardMap = new Map<String, Object>();
        List<String> objDealerNameList = new List<String>();
        List<String> descriptionList = new List<String>();
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(testUser){
            SaveRateCardDetailsHandler.TierWrapper objTierWrapper = new SaveRateCardDetailsHandler.TierWrapper();
            objTierWrapper.startDate = Date.newInstance(2023,1,1);
            objTierWrapper.endDate = Date.newInstance(2026,1,31);
            objTierWrapper.participationRate = 3;
            List<genesis__Rate_Card_Setup_Header__c> rateCardHeaderTest = [SELECT Id, 
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
                                                                            FROM genesis__Rate_Card_Setup_Header__c];
            genesis__Additional_Determining_Factor__c objFactorProgram =   [SELECT  Id, 
                                                                                        genesis__Field_Value__c 
                                                                                FROM genesis__Additional_Determining_Factor__c 
                                                                                WHERE genesis__Field_Value__c = :rateCardHeaderTest[0].Name AND genesis__Rate_Card_Setup_Header__c = :rateCardHeaderTest[0].Id
                                                                                LIMIT 1];
            genesis__Additional_Determining_Factor__c obFactorForDealer = [SELECT  Id, 
                                                                                        genesis__Field_Value__c 
                                                                                FROM genesis__Additional_Determining_Factor__c 
                                                                                WHERE genesis__Field_Value__c = :rateCardHeaderTest[0].Account__r.Name AND genesis__Rate_Card_Setup_Header__c = :rateCardHeaderTest[0].Id 
                                                                                LIMIT 1];
            List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = [SELECT Id,
                                                                                    Start_Date__c,
                                                                                    End_Date__c,
                                                                                    genesis__Interest_Rate__c,
                                                                                    Interest_Rate_Type__c,
                                                                                    Participation_Percentage_Dealer_Subsidy__c,
                                                                                    Participation_Percentage_Dealer__c
                                                                                FROM genesis__Rate_Card_Setup_Detail__c
                                                                                WHERE genesis__Rate_Card_Setup_Header__c =: rateCardHeaderTest[0].Id LIMIT 1];
            objDealerNameList.add(rateCardHeaderTest[0].Account__r.Name);
            String setupDescription = 'Seeds';
            rateCardDetailInfoMap.put('header',rateCardHeaderTest);
            objProgramList.add(objFactorProgram);
            rateCardDetailInfoMap.put('program',objProgramList);
            objDealerList.add(obFactorForDealer);
            rateCardDetailInfoMap.put('dealer', objDealerList); 
            rateCardDetailInfoMap.put('detail',rateCardDetailList);
            rateCardDetailInfoMap.put('dealerName',objDealerNameList);
            descriptionList.add(setupDescription);
            rateCardDetailInfoMap.put('description',descriptionList);
            rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(rateCardDetailList[0]));
                Test.startTest();
                MyProgramHelper.createDefaultRateCardDetail(objTierWrapper,rateCardDetailInfoMap);
                Test.stopTest();
        }
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = [SELECT Id FROM genesis__Rate_Card_Setup_Detail__c];
        System.assertEquals(!objRateCardDetailList.isEmpty(),true,'No Rate Card Setup Details are created');
    }
    /**
    * @description : Default Rate Interest rate is less than Finance Rate
    * @author  Pritam Roy | 04-02-2024 
    **/
    @isTest
    static void testCreateRateCardDefaultDetailInterestRateLessThanFieldFinanceRate(){
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String,List<Object>>();
        Map<String, Object> rateCardMap = new Map<String, Object>();
        List<String> objDealerNameList = new List<String>();
        List<String> descriptionList = new List<String>();
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(testUser){
            SaveRateCardDetailsHandler.TierWrapper objTierWrapper = new SaveRateCardDetailsHandler.TierWrapper();
            objTierWrapper.startDate = Date.newInstance(2023,1,1);
            objTierWrapper.endDate = Date.newInstance(2026,1,31);
            objTierWrapper.participationRate = 0;
            List<genesis__Rate_Card_Setup_Header__c> rateCardHeaderTest = [SELECT Id, 
                                                                                Name, 
                                                                                Account__c, 
                                                                                CFA_Advantage_Rate__c,
                                                                                Account__r.Name,
                                                                                genesis__Description__c,
                                                                                Field_Finance_Rate__c, 
                                                                                Crop_Year__c, 
                                                                                Closing_Fee__c , 
                                                                                genesis__End_Date__c,
                                                                                Payer_of_Loan_Closing_Fee__c,
                                                                                Loan_Fee_Advanced_On__c,
                                                                                Dealer_Participate_on_Closing_Fee__c,
                                                                                Portion_of_Fee_to_Cover__c
                                                                            FROM genesis__Rate_Card_Setup_Header__c 
                                                                            WHERE Name = 'My Test Program 99'];
            rateCardHeaderTest[0].Field_Finance_Rate__c = 9.5;
            Database.update(rateCardHeaderTest,true);
            genesis__Additional_Determining_Factor__c objFactorProgram =   [SELECT  Id, 
                                                                                        genesis__Field_Value__c 
                                                                                FROM genesis__Additional_Determining_Factor__c 
                                                                                WHERE genesis__Field_Value__c = :rateCardHeaderTest[0].Name AND genesis__Rate_Card_Setup_Header__c = :rateCardHeaderTest[0].Id
                                                                                LIMIT 1];
            genesis__Additional_Determining_Factor__c obFactorForDealer = [SELECT  Id, 
                                                                                        genesis__Field_Value__c 
                                                                                FROM genesis__Additional_Determining_Factor__c 
                                                                                WHERE genesis__Field_Value__c = :rateCardHeaderTest[0].Account__r.Name AND genesis__Rate_Card_Setup_Header__c = :rateCardHeaderTest[0].Id 
                                                                                LIMIT 1];
            List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = [SELECT Id,
                                                                                    Start_Date__c,
                                                                                    End_Date__c,
                                                                                    genesis__Interest_Rate__c,
                                                                                    Interest_Rate_Type__c,
                                                                                    Participation_Percentage_Dealer_Subsidy__c,
                                                                                    Participation_Percentage_Dealer__c
                                                                                FROM genesis__Rate_Card_Setup_Detail__c
                                                                                WHERE genesis__Rate_Card_Setup_Header__c =: rateCardHeaderTest[0].Id LIMIT 1];
            rateCardDetailList[0].genesis__Interest_Rate__c = 0;
            //Database.upsert(rateCardDetailList,true);
            objDealerNameList.add(rateCardHeaderTest[0].Account__r.Name);
            String setupDescription = 'Seeds';
            rateCardDetailInfoMap.put('header',rateCardHeaderTest);
            objProgramList.add(objFactorProgram);
            rateCardDetailInfoMap.put('program',objProgramList);
            objDealerList.add(obFactorForDealer);
            rateCardDetailInfoMap.put('dealer', objDealerList); 
            rateCardDetailInfoMap.put('detail',rateCardDetailList);
            rateCardDetailInfoMap.put('dealerName',objDealerNameList);
            descriptionList.add(setupDescription);
            rateCardDetailInfoMap.put('description',descriptionList);
            rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(rateCardDetailList[0]));
                Test.startTest();
                MyProgramHelper.createDefaultRateCardDetail(objTierWrapper,rateCardDetailInfoMap);
                Test.stopTest();
        }
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = [SELECT Id FROM genesis__Rate_Card_Setup_Detail__c];
        System.assertEquals(!objRateCardDetailList.isEmpty(),true,'No Rate Card Setup Details are created');
    }
    /**
    * @description : Negative Participation Rate
    * @author  Pritam Roy | 04-02-2024 
    **/
    @isTest
    static void testCreateRateCardDefaultDetailNegativeParticipationRate(){
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        SaveRateCardDetailsHandler.TierWrapper objTierWrapper = new SaveRateCardDetailsHandler.TierWrapper();
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String,List<Object>>();
        Map<String, Object> rateCardMap = new Map<String, Object>();
        List<String> objDealerNameList = new List<String>();
        List<String> descriptionList = new List<String>();
        objTierWrapper.startDate = Date.newInstance(2023,1,1);
        objTierWrapper.endDate = Date.newInstance(2026,1,31);
        objTierWrapper.participationRate = -1;
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(testUser){
            List<genesis__Rate_Card_Setup_Header__c> rateCardHeaderTest = [SELECT Id, 
                                                                                Name, 
                                                                                Account__c, 
                                                                                CFA_Advantage_Rate__c,
                                                                                Account__r.Name,
                                                                                genesis__Description__c,
                                                                                Field_Finance_Rate__c, 
                                                                                Crop_Year__c, 
                                                                                Closing_Fee__c , 
                                                                                genesis__End_Date__c,
                                                                                Payer_of_Loan_Closing_Fee__c,
                                                                                Loan_Fee_Advanced_On__c,
                                                                                Dealer_Participate_on_Closing_Fee__c,
                                                                                Portion_of_Fee_to_Cover__c
                                                                            FROM genesis__Rate_Card_Setup_Header__c 
                                                                            WHERE Name = 'My Test Program 99'];
            rateCardHeaderTest[0].Field_Finance_Rate__c = 9.5;
            Database.update(rateCardHeaderTest,true);
            genesis__Additional_Determining_Factor__c objFactorProgram =   [SELECT  Id, 
                                                                                        genesis__Field_Value__c 
                                                                                FROM genesis__Additional_Determining_Factor__c 
                                                                                WHERE genesis__Field_Value__c = :rateCardHeaderTest[0].Name AND genesis__Rate_Card_Setup_Header__c = :rateCardHeaderTest[0].Id
                                                                                LIMIT 1];
            genesis__Additional_Determining_Factor__c obFactorForDealer = [SELECT  Id, 
                                                                                        genesis__Field_Value__c 
                                                                                FROM genesis__Additional_Determining_Factor__c 
                                                                                WHERE genesis__Field_Value__c = :rateCardHeaderTest[0].Account__r.Name AND genesis__Rate_Card_Setup_Header__c = :rateCardHeaderTest[0].Id 
                                                                                LIMIT 1];
            List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = [SELECT Id,
                                                                                    Start_Date__c,
                                                                                    End_Date__c,
                                                                                    genesis__Interest_Rate__c,
                                                                                    Interest_Rate_Type__c,
                                                                                    Description__c,
                                                                                    Participation_Percentage_Dealer_Subsidy__c,
                                                                                    Participation_Percentage_Dealer__c
                                                                                FROM genesis__Rate_Card_Setup_Detail__c
                                                                                WHERE genesis__Rate_Card_Setup_Header__c =: rateCardHeaderTest[0].Id LIMIT 1];
            rateCardDetailList[0].Description__c = ' ';
            objDealerNameList.add(rateCardHeaderTest[0].Account__r.Name);
            String setupDescription = 'Seeds';
            rateCardDetailInfoMap.put('header',rateCardHeaderTest);
            objProgramList.add(objFactorProgram);
            rateCardDetailInfoMap.put('program',objProgramList);
            objDealerList.add(obFactorForDealer);
            rateCardDetailInfoMap.put('dealer', objDealerList); 
            rateCardDetailInfoMap.put('detail',rateCardDetailList);
            rateCardDetailInfoMap.put('dealerName',objDealerNameList);
            descriptionList.add(setupDescription);
            rateCardDetailInfoMap.put('description',descriptionList);
            rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(rateCardDetailList[0]));
                Test.startTest();
                MyProgramHelper.createDefaultRateCardDetail(objTierWrapper,rateCardDetailInfoMap);
                Test.stopTest();
        }
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = [SELECT Id FROM genesis__Rate_Card_Setup_Detail__c];
        System.assertEquals(!objRateCardDetailList.isEmpty(),true,'No Rate Card Setup Details are created');
    }
    /**
    * @description : 2023 crop year rate card header
    * @author  Pritam Roy | 04-03-2024 
    **/
    @isTest
    static void testCreateRateCardDefaultDetailPreviousCropYear(){
        Map<String, Object> rateCardMap = new Map<String, Object>();
        List<String> objDealerNameList = new List<String>();
        List<String> descriptionList = new List<String>();
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String,List<Object>>();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        SaveRateCardDetailsHandler.TierWrapper objTierWrapper = new SaveRateCardDetailsHandler.TierWrapper();
        objTierWrapper.startDate = Date.newInstance(2023,1,1);
        objTierWrapper.endDate = Date.newInstance(2026,1,31);
        objTierWrapper.participationRate = 3;
        List<genesis__Rate_Card_Setup_Header__c> rateCardHeaderTest = [SELECT Id, 
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
        rateCardHeaderTest[0].Crop_Year__c = '2023';
        rateCardHeaderTest[0].CFA_Advantage_Rate__c = 11.5;
        Database.update(rateCardHeaderTest,true);
        genesis__Additional_Determining_Factor__c objFactorProgram =   [SELECT  Id, 
                                                                                    genesis__Field_Value__c 
                                                                            FROM genesis__Additional_Determining_Factor__c 
                                                                            WHERE genesis__Field_Value__c = :rateCardHeaderTest[0].Name AND genesis__Rate_Card_Setup_Header__c = :rateCardHeaderTest[0].Id
                                                                            LIMIT 1];
        genesis__Additional_Determining_Factor__c obFactorForDealer = [SELECT  Id, 
                                                                                    genesis__Field_Value__c 
                                                                            FROM genesis__Additional_Determining_Factor__c 
                                                                            WHERE genesis__Field_Value__c = :rateCardHeaderTest[0].Account__r.Name AND genesis__Rate_Card_Setup_Header__c = :rateCardHeaderTest[0].Id 
                                                                            LIMIT 1];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = [SELECT Id,
                                                                                Start_Date__c,
                                                                                End_Date__c,
                                                                                genesis__Interest_Rate__c,
                                                                                Interest_Rate_Type__c,
                                                                                Participation_Percentage_Dealer_Subsidy__c,
                                                                                Participation_Percentage_Dealer__c
                                                                            FROM genesis__Rate_Card_Setup_Detail__c
                                                                            WHERE genesis__Rate_Card_Setup_Header__c =: rateCardHeaderTest[0].Id LIMIT 1];
        objDealerNameList.add(rateCardHeaderTest[0].Account__r.Name);
        String setupDescription = 'Seeds';
        rateCardDetailInfoMap.put('header',rateCardHeaderTest);
        objProgramList.add(objFactorProgram);
        rateCardDetailInfoMap.put('program',objProgramList);
        objDealerList.add(obFactorForDealer);
        rateCardDetailInfoMap.put('dealer', objDealerList); 
        rateCardDetailInfoMap.put('detail',rateCardDetailList);
        rateCardDetailInfoMap.put('dealerName',objDealerNameList);
        descriptionList.add(setupDescription);
        rateCardDetailInfoMap.put('description',descriptionList);
        rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(rateCardDetailList[0]));
        System.runAs(testUser){
            Test.startTest();
            MyProgramHelper.createDefaultRateCardDetail(objTierWrapper,rateCardDetailInfoMap);
            Test.stopTest();
        }

        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = [SELECT Id FROM genesis__Rate_Card_Setup_Detail__c];
        System.assertEquals(!objRateCardDetailList.isEmpty(),true,'No Rate Card Setup Details are created');
    }
}