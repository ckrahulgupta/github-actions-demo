/**
 * @description       : Purpose Of this class is to provide coverage of the PortalSaveRateCardDetailsAPI class
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 09-04-2024
 * @last modified by  : Sk Minsar
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   26-05-2022   Subham Nandi   Initial Version
**/
@isTest
global inherited sharing class TestPortalSaveRateCardDetailAPI {
    @TestSetup
    static void setup(){
        clcommon__CL_Product__c productForRate = new clcommon__CL_Product__c();
        productForRate = TestClassHelper.createProduct();
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
        
        //creating the rate card header with the dealer name on it
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderTest = TestClassHelper.createRateCardHeader(dealerCompany);
        System.assert(rateCardHeaderTest!=null,'No My Program data for test was set.');

        //Create Product Rate Card Association
        genesis__Product_Rate_Card_Association__c rateProduct = TestClassHelper.createRateToProduct(productForRate,rateCardHeaderTest);

        genesis__Additional_Determining_Factor__c additionalFactor = new genesis__Additional_Determining_Factor__c();
        additionalFactor = TestClassHelper.createAdditionalFactor(rateCardHeaderTest);
        
        //Additional Factor for dealer check
        genesis__Additional_Determining_Factor__c additionalFactorDealer = new genesis__Additional_Determining_Factor__c();
        additionalFactorDealer = TestClassHelper.createAdditionalFactorDealer(rateCardHeaderTest);

        genesis__Rate_Card_Setup_Detail__c rateCardDetailTest = new genesis__Rate_Card_Setup_Detail__c();
        rateCardDetailTest = TestClassHelper.createRateCardSetupDetail(rateCardHeaderTest);
        System.assert(rateCardDetailTest!=null,'No Rate card data for test was set.');

        //Creating application for Flex rate
        Account accountObj = TestClassHelper.createAccount(businessInfoDealer);
        genesis__Applications__c applicationObjFlex = new genesis__Applications__c();
        applicationObjFlex = TestClassHelper.createAppllicationForFlex(productForRate,accountObj);
        
    }
    @isTest
    static void testSaveRateCardDetailsAPI(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        Description__c,
                        Participation_Percentage_Dealer__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        tempRate.End_Date__c = Date.newInstance(2024, 12, 15);
        rateCardDetailTest.add(tempRate);
        System.runAs(testUser){
            String errorMessage;
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('interest', rateCardDetailTest);
            requestMap.put('programId',rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c);
            requestMap.put('description',rateCardDetailTest[0].Description__c);
            try {
                PortalSaveRateCardDetailsAPI.saveRateCardDetails(requestMap, String.valueOf(rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c), 'NoteRate');
            } catch (CustomException objCustomException) {
                errorMessage = objCustomException.getMessage();
            }
            System.assertEquals('The End Date of a Special Term Rate cannot pass the Maturity Date :3/15/2024', errorMessage);
            
        }
        Test.stopTest();
    } 
    // Test For Old Rate Card Success
    @isTest
    static void testSaveRateCardDetailsAPI3(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c,
                        Description__c,
                        Participation_Percentage_Dealer__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        tempRate.End_Date__c = Date.newInstance(2022, 12, 31);
        tempRate.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';
        tempRate.genesis__Interest_Rate__c = 3;
        Database.update(tempRate);
        genesis__Rate_Card_Setup_Header__c objRateHeader = new genesis__Rate_Card_Setup_Header__c(Id = tempRate.genesis__Rate_Card_Setup_Header__c);
        genesis__Rate_Card_Setup_Detail__c objNextRate = TestClassHelper.createRateCardSetupDetail(objRateHeader);
        objNextRate.Start_Date__c = tempRate.End_Date__c.addDays(1);
        objNextRate.End_Date__c = tempRate.genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c;
        Database.update(objNextRate);
        rateCardDetailTest.add(tempRate);
        rateCardDetailTest.add(objNextRate);
        System.runAs(testUser){
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('interest', rateCardDetailTest);
            requestMap.put('programId',rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c);
            requestMap.put('description',rateCardDetailTest[0].Description__c);
            PortalSaveRateCardDetailsAPI.saveRateCardDetails(requestMap, String.valueOf(rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c) ,'SpecialTermB');
        }
        Test.stopTest();
    }
    // Test For new Rate Card Success
    @isTest
    static void testSaveRateCardDetailsAPINewSuccess(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c,
                        Description__c,
                        Participation_Percentage_Dealer__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        tempRate.End_Date__c = Date.newInstance(2022, 12, 31);
        tempRate.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';
        tempRate.genesis__Interest_Rate__c = 5;
        Database.update(tempRate);
        genesis__Rate_Card_Setup_Header__c objRateHeader = new genesis__Rate_Card_Setup_Header__c(Id = tempRate.genesis__Rate_Card_Setup_Header__c);
        genesis__Rate_Card_Setup_Detail__c objNextRate = TestClassHelper.createRateCardSetupDetail(objRateHeader);
        objNextRate.Start_Date__c = tempRate.End_Date__c.addDays(1);
        objNextRate.End_Date__c = tempRate.genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c;
        Database.update(objNextRate);
        rateCardDetailTest.add(tempRate);
        rateCardDetailTest.add(objNextRate);
        System.runAs(testUser){
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('interest', rateCardDetailTest);
            requestMap.put('programId',rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c);
            requestMap.put('description','New Description!!');
            PortalSaveRateCardDetailsAPI.saveRateCardDetails(requestMap, String.valueOf(rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c),'SpecialTermC');
        }
        Test.stopTest();
    }
    // Test For Old Rate Card Error
    @isTest
    static void testSaveRateCardDetailsAPIError_1(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c,
                        Description__c,
                        Participation_Percentage_Dealer__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        tempRate.End_Date__c = Date.newInstance(2022, 12, 31);
        tempRate.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';
        tempRate.genesis__Interest_Rate__c = 3;
        Database.update(tempRate);
        genesis__Rate_Card_Setup_Header__c objRateHeader = new genesis__Rate_Card_Setup_Header__c(Id = tempRate.genesis__Rate_Card_Setup_Header__c);
        genesis__Rate_Card_Setup_Detail__c objNextRate = TestClassHelper.createRateCardSetupDetail(objRateHeader);
        objNextRate.Start_Date__c = tempRate.End_Date__c.addDays(2);
        objNextRate.End_Date__c = tempRate.genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c;
        Database.update(objNextRate);
        rateCardDetailTest.add(tempRate);
        rateCardDetailTest.add(objNextRate);
        System.runAs(testUser){
            String errorMessage;
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('interest', rateCardDetailTest);
            requestMap.put('programId',rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c);
            requestMap.put('description',rateCardDetailTest[0].Description__c);
            try{
                PortalSaveRateCardDetailsAPI.saveRateCardDetails(requestMap, String.valueOf(rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c),'SpecialTermE');
            }
            catch(CustomException objCustomException){
                errorMessage = objCustomException.getMessage();
            }
            System.assertEquals('The Start Date of an additional Special Term rate must begin the next day following the End Date of the previous Special Term', errorMessage);
            
        }
        Test.stopTest();
    }
    // Test For Old Rate Card Error
    @isTest
    static void testSaveRateCardDetailsAPIError_2(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c,
                        Description__c,
                        Participation_Percentage_Dealer__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        tempRate.End_Date__c = Date.newInstance(2022, 12, 30);
        tempRate.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';
        tempRate.genesis__Interest_Rate__c = 9;
        Database.update(tempRate);
        genesis__Rate_Card_Setup_Header__c objRateHeader = new genesis__Rate_Card_Setup_Header__c(Id = tempRate.genesis__Rate_Card_Setup_Header__c);
        genesis__Rate_Card_Setup_Detail__c objNextRate = TestClassHelper.createRateCardSetupDetail(objRateHeader);
        objNextRate.Start_Date__c = tempRate.End_Date__c.addDays(1);
        objNextRate.End_Date__c = tempRate.genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c;
        Database.update(objNextRate);
        rateCardDetailTest.add(tempRate);
        rateCardDetailTest.add(objNextRate);
        System.runAs(testUser){
            String errorMessage;
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('interest', rateCardDetailTest);
            requestMap.put('programId',rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c);
            requestMap.put('description',rateCardDetailTest[0].Description__c);
            try{
                PortalSaveRateCardDetailsAPI.saveRateCardDetails(requestMap, String.valueOf(rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c),'SpecialTermD');
            }
            catch(CustomException objCustomException){
                errorMessage = objCustomException.getMessage();
            }
            System.assertEquals('The End Date of a rate should be on the last day of a month', errorMessage);
        }
        Test.stopTest();
    }
    // Test For Old Rate Card Error
    @isTest
    static void testSaveRateCardDetailsAPIError_3(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c,
                        Description__c,
                        Participation_Percentage_Dealer__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c,
                        genesis__Interest_Rate__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        tempRate.End_Date__c = Date.newInstance(2024, 02, 29);
        tempRate.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';
        Database.update(tempRate);
        genesis__Rate_Card_Setup_Header__c objRateHeader = new genesis__Rate_Card_Setup_Header__c(Id = tempRate.genesis__Rate_Card_Setup_Header__c);
        genesis__Rate_Card_Setup_Detail__c objNextRate = TestClassHelper.createRateCardSetupDetail(objRateHeader);
        objNextRate.Start_Date__c = tempRate.End_Date__c.addDays(1);
        objNextRate.End_Date__c = tempRate.genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c;
        Database.update(objNextRate);
        rateCardDetailTest.add(tempRate);
        rateCardDetailTest.add(objNextRate);
        System.runAs(testUser){
            String errorMessage;
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('interest', rateCardDetailTest);
            requestMap.put('programId',rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c);
            requestMap.put('description',rateCardDetailTest[0].Description__c);
            try{
                PortalSaveRateCardDetailsAPI.saveRateCardDetails(requestMap, String.valueOf(rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c),'NoteRate');
            }
            catch(CustomException objCustomException){
                errorMessage = objCustomException.getMessage();
            }
            System.assertEquals('The End date of a Special Term Rate cannot be on the month prior to the maturity date', errorMessage);
        }
        Test.stopTest();
    }
    // Test For Old Rate Card Success Premium
    @isTest
    static void testSaveRateCardDetailsAPI4(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c,
                        Description__c,
                        Participation_Percentage_Dealer__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        tempRate.End_Date__c = tempRate.genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c;
        tempRate.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';
        tempRate.genesis__Interest_Rate__c = 3;
        Database.update(tempRate);
        rateCardDetailTest.add(tempRate);
        System.runAs(testUser){
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('interest', rateCardDetailTest);
            requestMap.put('programId',rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c);
            requestMap.put('description',rateCardDetailTest[0].Description__c);
            PortalSaveRateCardDetailsAPI.saveRateCardDetails(requestMap, String.valueOf(rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c),'NoteRate');
        }
        Test.stopTest();
    }

    //Save rate card details for interest rate less than the cfa advantage rate
    @isTest
    static void testSaveRateCardDetailsAPIForLessRate(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        Description__c,
                        Participation_Percentage_Dealer__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        tempRate.genesis__Interest_Rate__c = 3.5;
        tempRate.End_Date__c = Date.newInstance(2024, 03, 15);
        Database.update(tempRate,false);
        rateCardDetailTest.add(tempRate);
        System.runAs(testUser){
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('interest', rateCardDetailTest);
            requestMap.put('programId',rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c);
            requestMap.put('description',rateCardDetailTest[0].Description__c);
            PortalSaveRateCardDetailsAPI.saveRateCardDetails(requestMap, String.valueOf(rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c),'NoteRate');
        }
        Test.stopTest();
    }

    //rate card detail with equal cfa advantage rate
    //Save rate card details for interest rate less than the cfa advantage rate
    @isTest
    static void testSaveRateCardDetailsAPIForEqualRate(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c,
                        Description__c,
                        Participation_Percentage_Dealer__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        tempRate.genesis__Interest_Rate__c = 7;
        tempRate.End_Date__c = tempRate.genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c;
        Database.update(tempRate,false);
        rateCardDetailTest.add(tempRate);
        System.runAs(testUser){
            String errorMessage;
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('interest', rateCardDetailTest);
            requestMap.put('programId',rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c);
            requestMap.put('description',rateCardDetailTest[0].Description__c);
            try{
                PortalSaveRateCardDetailsAPI.saveRateCardDetails(requestMap, String.valueOf(rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c),'NoteRate');
            }
            Catch(CustomException objException){
                errorMessage = objException.getMessage();
            }
            //System.assertEquals('The End Date of a Special Term Rate cannot pass the Maturity Date: 3/15/2023', errorMessage);
        }
        Test.stopTest();
    }

    //PortalSaveRateCardDetails for adding a new rate card
    @isTest
    static void testSaveRateCardDetailsAPIForNewRate(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        Description__c,
                        Participation_Percentage_Dealer__c,
                        genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        tempRate.genesis__Interest_Rate__c = 9;
        tempRate.End_Date__c = tempRate.genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c;
        Database.update(tempRate);
        rateCardDetailTest.add(tempRate);
        System.runAs(testUser){
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('interest', rateCardDetailTest);
            requestMap.put('programId',rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c);
            requestMap.put('description','New Description');
            PortalSaveRateCardDetailsAPI.saveRateCardDetails(requestMap, String.valueOf(rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c),'NoteRate');
        }
        Test.stopTest();
    }

    //New Rate card details with less interest rate
    @isTest
    static void testSaveRateCardDetailsAPIForNewRateLess(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        Description__c,
                        Participation_Percentage_Dealer__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        tempRate.genesis__Interest_Rate__c = 0.1;
        tempRate.End_Date__c = tempRate.genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c;
        Database.update(tempRate,false);rateCardDetailTest.add(tempRate);
        System.runAs(testUser){
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('interest', rateCardDetailTest);
            requestMap.put('programId',rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c);
            requestMap.put('description','New Description');
            PortalSaveRateCardDetailsAPI.saveRateCardDetails(requestMap, String.valueOf(rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c),'NoteRate');
        }
        Test.stopTest();
    }

    //new rate card with interest rate equal to cfa advantage rate
    @isTest
    static void testSaveRateCardDetailsAPIForNewRateEqualCFA(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        Description__c,
                        Participation_Percentage_Dealer__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        tempRate.genesis__Interest_Rate__c = 7;
        tempRate.End_Date__c = tempRate.genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c;
        Database.update(tempRate,false);rateCardDetailTest.add(tempRate);
        System.runAs(testUser){
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('interest', rateCardDetailTest);
            requestMap.put('programId',rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c);
            requestMap.put('description','New Description');
            PortalSaveRateCardDetailsAPI.saveRateCardDetails(requestMap, String.valueOf(rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c),'NoteRate');
        }
        Test.stopTest();
    }

    //test save rate card detail to handle a custom error
    @isTest
    static void testSaveRateCardDetailsAPIForErrorEndDate(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        Description__c,
                        Participation_Percentage_Dealer__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        tempRate.genesis__Interest_Rate__c = 2;
        tempRate.End_Date__c = Date.newInstance(2022, 2, 2);
        Database.update(tempRate,false);rateCardDetailTest.add(tempRate);
        System.runAs(testUser){
            String errordMessage;
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('interest', rateCardDetailTest);
            requestMap.put('programId',rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c);
            requestMap.put('description','New Description');
            try{
                PortalSaveRateCardDetailsAPI.saveRateCardDetails(requestMap, String.valueOf(rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c),'NoteRate');
            }
            catch(CustomException objCustomException){
                errordMessage = objCustomException.getMessage();
            }
            System.assertEquals('End Date for the last Special Term Rate entered must match the Maturity Date: 3/15/2024', errordMessage);
            
        }
        Test.stopTest();
    }

    //test save rate card detail success
    @isTest
    static void testSaveRateCardDetailsAPI1(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c,
                        Description__c,
                        Participation_Percentage_Dealer__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        tempRate.genesis__Interest_Rate__c = 2;
        tempRate.End_Date__c = tempRate.genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c;
        Database.update(tempRate,false);rateCardDetailTest.add(tempRate);
        System.runAs(testUser){
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('interest', rateCardDetailTest);
            requestMap.put('programId',rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c);
            requestMap.put('description','New Description');
            PortalSaveRateCardDetailsAPI.saveRateCardDetails(requestMap, String.valueOf(rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c),'NoteRate');
        }
        Test.stopTest();
    }
    //test save rate card detail success premium
    @isTest
    static void testSaveRateCardDetailsAPI2(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c,
                        Description__c,
                        Participation_Percentage_Dealer__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        tempRate.genesis__Interest_Rate__c = 9;
        tempRate.End_Date__c = tempRate.genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c;
        Database.update(tempRate);
        genesis__Rate_Card_Setup_Header__c objRateCard = [SELECT Id, Special_Term_Number__c FROM genesis__Rate_Card_Setup_Header__c WHERE Id = :tempRate.genesis__Rate_Card_Setup_Header__c];
        objRateCard.Special_Term_Number__c = 'Special Term Sub-Tranche (A)';
        Database.update(objRateCard);
        rateCardDetailTest.add(tempRate);
        System.runAs(testUser){
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('interest', rateCardDetailTest);
            requestMap.put('programId',rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c);
            requestMap.put('description','New Description');
            PortalSaveRateCardDetailsAPI.saveRateCardDetails(requestMap, String.valueOf(rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c),'NoteRate');
        }
        Test.stopTest();
    }
    
    

    @isTest
    static void testSaveRateCardDetailsAPIForError(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        System.runAs(testUser){
            String errorMessage;
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('interest', 'Error Value');
            try{
                PortalSaveRateCardDetailsAPI.saveRateCardDetails(requestMap, '','NoteRate');
            }
            catch(CustomException objCustomException){
                errorMessage = objCustomException.getMessage();
            }
            System.assertEquals('User is not authorized to perform this operation.', errorMessage);
        }
        Test.stopTest();
    }

    @isTest
    static void testSaveRateCardDetailsAPIDefaultNote(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest2 = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c,
                        Description__c,
                        Participation_Percentage_Dealer__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        tempRate.genesis__Interest_Rate__c = 9;
        tempRate.End_Date__c = tempRate.genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c;
        Database.update(tempRate);
        genesis__Rate_Card_Setup_Header__c objRateCard = [SELECT Id, Special_Term_Number__c FROM genesis__Rate_Card_Setup_Header__c WHERE Id = :tempRate.genesis__Rate_Card_Setup_Header__c];
        objRateCard.Special_Term_Number__c = 'Special Term Sub-Tranche (A)';
        Database.update(objRateCard);

        rateCardDetailTest.add(tempRate);
        System.runAs(testUser){
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('interest', rateCardDetailTest2);
            requestMap.put('programId',rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c);
            requestMap.put('description','New Description');
            PortalSaveRateCardDetailsAPI.saveRateCardDetails(requestMap, String.valueOf(rateCardDetailTest[0].genesis__Rate_Card_Setup_Header__c),'NoteRate');
        }
        Test.stopTest();
    }

}