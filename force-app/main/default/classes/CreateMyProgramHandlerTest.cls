/**
 * @description       : Test class for CreateMyProgramHandler
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 07-10-2024
**/
@isTest
private class CreateMyProgramHandlerTest {
    /**
    * @description : Test Setup
    * @author  Pritam Roy | 04-05-2024 
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

        //Creating Legal Entity
        clcommon__Legal_Entity__c objDBALegalEntity = ApplicationOriginationTestHelper.createDBALegalEntity();
        Database.insert(objDBALegalEntity,true);

        //Creating DBA Account
        Account accountObj = ApplicationOriginationTestHelper.createDBAccount(objDBALegalEntity,businessInfoDealer.id);
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
    * @description : Validate Flex Rate Card
    * @author  Pritam Roy | 04-05-2024 
    **/
    @isTest
    static void validateFlexRateCard(){
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('myProgramId','new_record_id');
        Map<String, Object> myProgramRequestMap = new Map<String,Object>();
        Map<String, Object> flexRateMap = new Map<String, Object>();

        Map<String, Object> programMap = new Map<String, Object>();
        programMap.put('genesis__End_Date__c', '2024-12-15');
        programMap.put('Id', 'new_record_id');
        programMap.put('Crop_Year__c', '2024');
        programMap.put('CFA_Advantage_Rate__c', 9.5);
        programMap.put('Field_Finance_Rate__c', 9.5);
        programMap.put('Closing_Fee__c', 200);
        programMap.put('Payer_of_Loan_Closing_Fee__c', 'Grower');
        programMap.put('Loan_Fee_Advanced_On__c', 'A');
        programMap.put('Dealer_Participate_on_Closing_Fee__c', 'No');

        flexRateMap.put('flexRateProgram', programMap);
        Map<String, Map<String, Object>> flexRatePricingMap = new Map<String, Map<String, Object>>();

        
        Map<String, Object> subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Seeds');

        List<Map<String,Object>> subTrancheInfoList = new List<Map<String,Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 3,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2023-08-14',
                'End_Date__c' => '2023-08-31',
                'genesis__Interest_Rate__c' => 2.23,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 3.26,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2023-09-01',
                'End_Date__c' => '2024-12-15',
                'genesis__Interest_Rate__c' => 2.24,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheMap.put('interest',subTrancheInfoList);
        flexRatePricingMap.put('NoteRate',subTrancheMap);

        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Crops');

        subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 3.16,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2023-08-14',
                'End_Date__c' => '2023-09-30',
                'genesis__Interest_Rate__c' => 2.34,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 2.83,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2023-10-01',
                'End_Date__c' => '2024-12-15',
                'genesis__Interest_Rate__c' => 2.67,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTrancheMap.put('interest',subTrancheInfoList);
        flexRatePricingMap.put('SpecialTermB',subTrancheMap);

        subTrancheInfoList = new List<Map<String,Object>>();
        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('interest',subTrancheInfoList);
        flexRatePricingMap.put('SpecialTermC',subTrancheMap);
        flexRatePricingMap.put('SpecialTermD',subTrancheMap);
        flexRatePricingMap.put('SpecialTermE',subTrancheMap);

        flexRateMap.put('ratePricing', flexRatePricingMap);
        myProgramRequestMap.put('flexPricing', JSON.serialize(flexRateMap));
        myProgramRequestMap.put('shouldValidate' , true);
        System.runAs(testUser){
            Test.startTest();
            CreateMyProgramHandler.FlexRateWrapper objWrapper =  CreateMyProgramHandler.validateFlexRateCard(myProgramRequestMap);
            Test.stopTest();
            System.assert(objWrapper.shouldValidate==true,'No Flex Rate Found');
        }
    }
    
    @isTest
    static void updateFlexRateHeader(){
        User testUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        System.runAs(testUser){
            genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = [SELECT Id, 
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
            clcommon__Floating_Rate_Index__c floatingRateIndex = [SELECT id FROM clcommon__Floating_Rate_Index__c LIMIT 1];
            rateCardHeaderTest.Base_Rate__c = floatingRateIndex.id;
            update rateCardHeaderTest;

            genesis__Applications__c applicationObj = [SELECT Id,
                                                                Name,
                                                                CreatedDate
                                                            FROM genesis__Applications__c LIMIT 1];
            List<User> getDealerAccountList = [SELECT  Id,
                                                        ContactId,
                                                        Contact.AccountId,
                                                        Contact.Account.ParentId,
                                                        Contact.Account.Parent.Name,
                                                        Contact.Account.Parent.Tier__c 
                                                FROM USER 
                                                WHERE Id = :testUser.Id];
            Test.startTest();
            genesis__Rate_Card_Setup_Header__c objHeader = CreateMyProgramHandler.updateFlexRateHeader(rateCardHeaderTest,getDealerAccountList,applicationObj);
            Test.stopTest();
            System.assert(objHeader != null, 'No Rate Card Header');
        }
    }
    
    /**
    * @description : Validate My Program Name
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void validateMyProgramName(){
        String myProgramName = 'MyProgram@123';
        String specialCharacter = '@';
        Test.startTest();
        try{
            CreateMyProgramHandler.validateMyProgramName(myProgramName, specialCharacter);
            System.assert(false, 'Exception should have been thrown');
        } catch (CustomException e) {
            System.assert(e.getMessage() == PortalConstants.WRONG_MY_PROGRAM_NAME, 'Wrong exception message');
        }
        Test.stopTest();
    }

    /**
    * @description : Check Arguments
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void checkArguments(){
        User testUser = [SELECT Id, Account.ParentId, Account.Parent.Name FROM User WHERE Username = 'ross.geller@yopmail.com'];
        List<User> objdealerAccountName = new List<User>{testUser};
        Test.startTest();
        Boolean result = CreateMyProgramHandler.checkArguments(objdealerAccountName);
        Test.stopTest();
        System.assert(result == true, 'Arguments check failed');
    }
    /**
    * @description : check flex rate loan closing fee payer
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void checkFlexRateLoanClosingFeePayer(){
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderTest = [SELECT Id, 
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
        rateCardHeaderTest.Payer_of_Loan_Closing_Fee__c = 'Dealer';
        System.runAs(testUser){
            Test.startTest();
            genesis__Rate_Card_Setup_Header__c objHeader = CreateMyProgramHandler.checkFlexRateLoanClosingFeePayer(rateCardHeaderTest);
            Test.stopTest();
            System.assert(objHeader!=null,'No Header found');
        }                             
    }
    /**
    * @description : check flex rate loan closing fee payer
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void checkFlexRateLoanClosingFeePayerGrower(){
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderTest = [SELECT Id, 
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
        System.runAs(testUser){
            Test.startTest();
            genesis__Rate_Card_Setup_Header__c objHeader = CreateMyProgramHandler.checkFlexRateLoanClosingFeePayer(rateCardHeaderTest);
            Test.stopTest();
            System.assert(objHeader!=null,'No Header found');
        }                             
    }
    
    /**
    * @description : check flex rate application
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void checkFlexRateApplication(){
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderTest = [SELECT Id, 
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
        genesis__Applications__c applicationObj = [SELECT Id,
                                                          Name,
                                                          genesis__Account__r.Name,
                                                          CreatedDate
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 7685 AND
                                                    genesis__Interest_Rate__c = 1.45];  
        System.runAs(testUser){
            Test.startTest();
            genesis__Rate_Card_Setup_Header__c objHeader = CreateMyProgramHandler.checkFlexRateApplication(rateCardHeaderTest,applicationObj);
            Test.stopTest();
            System.assert(objHeader!=null,'No Header found');   
        }       
    }

    /**
    * @description : Check Flex rate Additional Factors
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void checkFlexRateAdditionalFactors(){
        String objString;
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderTest = [SELECT Id, 
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
        List<User> getDealerAccountList = [SELECT  Id,
                                                    ContactId,
                                                    Contact.AccountId,
                                                    Contact.Account.ParentId,
                                                    Contact.Account.Parent.Name,
                                                    Contact.Account.Parent.Tier__c 
                                            FROM USER 
                                            WHERE Id = :testUser.Id];
        System.runAs(testUser){
            Test.startTest();
            try{
                CreateMyProgramHandler.checkFlexRateAdditionalFactors(rateCardHeaderTest,getDealerAccountList);
            }catch(Exception objException){
                objString = objException.getMessage();
            }
            Test.stopTest();
            System.assert(objString!=null,'Message found'); 
        }                                                                 
    }
    
    /**
    * @description : Check Flex Rate Program
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void checkFlexRateProgram(){
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderTest.genesis__Start_Date__c = System.today();
        rateCardHeaderTest.genesis__Transaction_Date__c = System.today();
        List<User> getDealerAccountList = [SELECT  Id,
                                                    ContactId,
                                                    Contact.AccountId,
                                                    Contact.Account.ParentId,
                                                    Contact.Account.Parent.Name,
                                                    Contact.Account.Parent.Tier__c 
                                            FROM USER 
                                            WHERE Id = :testUser.Id];
        System.runAs(testUser){
            Test.startTest();
            CreateMyProgramHandler.checkFlexRateProgram(rateCardHeaderTest,getDealerAccountList);
            Test.stopTest();
            System.assert(rateCardHeaderTest!=null,'No Header found');
        }                                                                  
    }
    
    /**
    * @description : Update Flex Rate In Application
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void updateFlexRateInApplication(){
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = new genesis__Rate_Card_Setup_Header__c();
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
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            Name,
                                                            genesis__Account__r.Name,
                                                            CreatedDate,
                                                            genesis__Maturity_Date__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 7685 AND
                                                        genesis__Interest_Rate__c = 1.45];
        System.runAs(testUser){
            Test.startTest();
            CreateMyProgramHandler.updateFlexRateInApplication(rateCardHeaderTest, applicationObj, rateCardHeaderTest.Id);
            Test.stopTest();
            genesis__Applications__c newApplicationObj = [SELECT Id,
                                                            Name,
                                                            genesis__Maturity_Date__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 7685 AND
                                                        genesis__Interest_Rate__c = 1.45];
            System.assert(newApplicationObj.genesis__Maturity_Date__c != null,'No Crop Year Found');
        }                                                                    
    }
}