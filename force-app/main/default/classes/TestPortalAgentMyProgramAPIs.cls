/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 27-03-2023
 * @last modified by  : Tuhin Bhunia
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   09-02-2022   Subham Nandi   Initial Version
**/
@isTest
private class TestPortalAgentMyProgramAPIs {
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
    static void testPortalCreateMyProgramAPI(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
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
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderTest));
            requestMap.put('SpecialTermE', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":2.5999999999999996,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":3.4,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Summer Crops\"}');
            requestMap.put('SpecialTermD', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":3.5,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":2.5,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"DDT\"}');
            requestMap.put('SpecialTermC', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":3.5999999999999996,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":2.4,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Pesticides\"}');
            requestMap.put('SpecialTermB', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.7,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.3,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Fertilisers\"}');
            requestMap.put('NoteRate', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.75,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.25,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Seeds\"}');
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }

    @isTest
    static void testPortalCreateNewMyProgramAPI(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderTest = [ SELECT  
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
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            String programStr = Json.serialize(rateCardHeaderTest);
            String subString = programStr.substringBetween('sobjects/genesis__Rate_Card_Setup_Header__c/', '"},"Name":"');
            requestMap.put('program', programStr.replace(subString,'new_record_id'));
            requestMap.put('SpecialTermE', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":2.5999999999999996,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":3.4,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Summer Crops\"}');
            requestMap.put('SpecialTermD', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":3.5,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":2.5,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"DDT\"}');
            requestMap.put('SpecialTermC', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":3.5999999999999996,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":2.4,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Pesticides\"}');
            requestMap.put('SpecialTermB', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.7,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.3,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Fertilisers\"}');
            requestMap.put('NoteRate', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.75,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.25,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Seeds\"}');
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }

    //Test My Program with dealer as payer
    @isTest
    static void testPortalCreateNewMyProgramAPIPayerDealer(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderTest = [ SELECT  
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
        Database.update(rateCardHeaderTest);
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            String programStr = Json.serialize(rateCardHeaderTest);
            String subString = programStr.substringBetween('sobjects/genesis__Rate_Card_Setup_Header__c/', '"},"Name":"');
            requestMap.put('program', programStr.replace(subString,'new_record_id'));
            requestMap.put('SpecialTermE', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":2.5999999999999996,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":3.4,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Summer Crops\"}');
            requestMap.put('SpecialTermD', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":3.5,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":2.5,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"DDT\"}');
            requestMap.put('SpecialTermC', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":3.5999999999999996,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":2.4,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Pesticides\"}');
            requestMap.put('SpecialTermB', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.7,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.3,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Fertilisers\"}');
            requestMap.put('NoteRate', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.75,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.25,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Seeds\"}');
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }
    //Maturity year same as crop year check and wrong maturity date
    @isTest
    static void testPortalCreateMyProgramAPIForWrongMaturityDate1(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
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
        rateCardHeaderTest.genesis__End_Date__c = Date.newInstance(System.today().year(), 11, 15);
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderTest));
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }
    //Maturity year same as crop year check and wrong maturity date next year
    @isTest
    static void testPortalCreateMyProgramAPIForWrongMaturityDate2(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
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
        rateCardHeaderTest.genesis__End_Date__c = Date.newInstance(System.today().year() + 1, 4, 15);
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderTest));
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }
    //Maturity year same as crop year check and wrong maturity date next year
    @isTest
    static void testPortalCreateMyProgramAPIForWrongMaturityDate3(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
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
        rateCardHeaderTest.genesis__End_Date__c = Date.newInstance(System.today().year() + 2, 4, 15);
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderTest));
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }
    //Maturity year same as crop year check and wrong maturity date next year
    @isTest
    static void testPortalCreateMyProgramAPIForWrongMaturityDate4(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
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
        rateCardHeaderTest.genesis__End_Date__c = Date.newInstance(System.today().year(), 4, 14);
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderTest));
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }
    //Maturity year same as crop year check and wrong maturity date next year
    @isTest
    static void testPortalCreateMyProgramAPIForWrongMaturityDate5(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
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
        rateCardHeaderTest.genesis__End_Date__c = Date.newInstance(System.today().year() - 2, 4, 15);
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderTest));
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }
    @isTest
    static void testPortalCreateMyProgramAPIForError(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        System.runAs(testUser){
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize('blank'));
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }

    //test the a new Flex Rate for subsidy
    @isTest
    static void testFlexRateCard(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 7685 AND
                                                        genesis__Interest_Rate__c = 1.45];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        Description__c,
                        Participation_Percentage_CFA__c,
                        Participation_Percentage_Dealer__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c,
                        genesis__Interest_Rate__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        rateCardDetailTest.add(tempRate);
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
                                    Portion_of_Fee_to_Cover__c


                                FROM genesis__Rate_Card_Setup_Header__c 
                                WHERE Name = 'My Test Program 99'];
        tempRate.End_Date__c = rateCardHeaderTest[0].genesis__End_Date__c;
        Database.update(tempRate);
        System.runAs(testUser){
            Map<String,Object> requestMap = new Map<String,Object>();
            Map<String,Object> flexPriceMap = new Map<String,Object>();
            // String programStr = Json.serialize(rateCardDetailTest);
            // String subString = programStr.substringBetween('sobjects/genesis__Rate_Card_Setup_Header__c/', '"},"Name":"');
            String rateCard = Json.serialize(rateCardHeaderTest[0]);
            String subString = rateCard.substringBetween('sobjects/genesis__Rate_Card_Setup_Header__c/', '"},"Name":"');
            String finalString = rateCard.replace(subString,'new_record_id');
            genesis__Rate_Card_Setup_Header__c objRate = (genesis__Rate_Card_Setup_Header__c) Json.deserialize(finalString, genesis__Rate_Card_Setup_Header__c.class);
            requestMap.put('flexRateProgram', objRate);
            requestMap.put('myProgramId','new_record_id');
            Map<String, Object> request = new Map<String,Object>();
            request.put('flexPricing',  '{\"flexRateProgram\":{\"Dealer_Participate_on_Closing_Fee__c\":\"No\",\"Loan_Fee_Advanced_On__c\":\"A\",\"Payer_of_Loan_Closing_Fee__c\":\"Grower\",\"Closing_Fee__c\":200,\"CFA_Advantage_Rate__c\":7,\"Crop_Year__c\":\"2023\",\"Id\":\"new_record_id\",\"genesis__End_Date__c\":\"2023-12-15\"},\"ratePricing\":{\"NoteRate\":{\"description\":\"Seeds\",\"interest\":[{\"Participation_Percentage_Dealer_Subsidy__c\":3.2699999999999996,\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"2022-08-31\",\"genesis__Interest_Rate__c\":2.23,\"Interest_Rate_Type__c\":\"Variable\"},{\"Participation_Percentage_Dealer_Subsidy__c\":3.26,\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-09-01\",\"End_Date__c\":\"2023-12-15\",\"genesis__Interest_Rate__c\":2.24,\"Interest_Rate_Type__c\":\"Variable\"}]},\"SpecialTermB\":{\"description\":\"Crops\",\"interest\":[{\"Participation_Percentage_Dealer_Subsidy__c\":3.16,\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"2022-09-30\",\"genesis__Interest_Rate__c\":2.34,\"Interest_Rate_Type__c\":\"Variable\"},{\"Participation_Percentage_Dealer_Subsidy__c\":2.83,\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-10-01\",\"End_Date__c\":\"2023-12-15\",\"genesis__Interest_Rate__c\":2.67,\"Interest_Rate_Type__c\":\"Variable\"}]},\"SpecialTermC\":{\"interest\":[]},\"SpecialTermD\":{\"interest\":[]},\"SpecialTermE\":{\"interest\":[]}}}');
            request.put('shouldValidate' , true);
            PortalCreateMyProgramAPI.createFlexRateCard(applicationObj.Id,request);
        }
        Test.stopTest();
    }

    //Test Clone my program
    @isTest
    static void testPortalCloneMyProgramAPI(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderTest = [SELECT Id, 
                                    Name, 
                                    Account__c, 
                                    CFA_Advantage_Rate__c, 
                                    genesis__Description__c, 
                                    Crop_Year__c, 
                                    Closing_Fee__c , 
                                    genesis__End_Date__c 
                                FROM genesis__Rate_Card_Setup_Header__c 
                                WHERE Name = 'My Test Program 99'];
        rateCardHeaderTest.Crop_Year__c = '2023';
        String endDateStr = '01/15/2024';
        Date endDate = Date.parse(endDateStr);
        rateCardHeaderTest.genesis__End_Date__c = endDate;
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderTest));
            PortalCloneMyProgramAPI cloneMyProgramAPI = new PortalCloneMyProgramAPI();
            clcommon.Response resp = cloneMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }

    @isTest
    static void testPortalCloneMyProgramAPI2(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderTest = [SELECT Id, 
                                    Name, 
                                    Account__c, 
                                    CFA_Advantage_Rate__c, 
                                    genesis__Description__c, 
                                    Crop_Year__c, 
                                    Closing_Fee__c , 
                                    genesis__End_Date__c 
                                FROM genesis__Rate_Card_Setup_Header__c 
                                WHERE Name = 'My Test Program 99'];
        rateCardHeaderTest.Crop_Year__c = '2023';
        String endDateStr = '01/15/2024';
        Date endDate = Date.parse(endDateStr);
        rateCardHeaderTest.genesis__End_Date__c = endDate;
        rateCardHeaderTest.Payer_of_Loan_Closing_Fee__c = PortalConstants.DEALER_PROFILE;
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderTest));
            PortalCloneMyProgramAPI cloneMyProgramAPI = new PortalCloneMyProgramAPI();
            clcommon.Response resp = cloneMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }

    @isTest
    static void testPortalCloneMyProgramAPIError(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize('blank'));
            PortalCloneMyProgramAPI cloneMyProgramAPI = new PortalCloneMyProgramAPI();
            clcommon.Response resp = cloneMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }

    @isTest
    static void testPortalCloneMyProgramAPIError2(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderTest = [SELECT Id, 
                                    Name, 
                                    Account__c, 
                                    CFA_Advantage_Rate__c, 
                                    genesis__Description__c, 
                                    Crop_Year__c, 
                                    Closing_Fee__c , 
                                    genesis__End_Date__c 
                                FROM genesis__Rate_Card_Setup_Header__c 
                                WHERE Name = 'My Test Program 99'];
        rateCardHeaderTest.Crop_Year__c = '2023';
        String endDateStr = '05/15/2024';
        Date endDate = Date.parse(endDateStr);
        rateCardHeaderTest.genesis__End_Date__c = endDate;
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderTest));
            PortalCloneMyProgramAPI cloneMyProgramAPI = new PortalCloneMyProgramAPI();
            clcommon.Response resp = cloneMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }

    //test the approval process
    @isTest
    static void testPortalApproveMyProgram(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderTest = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderTest = [SELECT Id
                                FROM genesis__Rate_Card_Setup_Header__c 
                                WHERE Name = 'My Test Program 99'];
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('programId', rateCardHeaderTest.Id);
            PortalApproveAgentMyProgram approveMyProgram = new PortalApproveAgentMyProgram();
            clcommon.Response resp = approveMyProgram.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }
    //test the approval process Error
    @isTest
    static void testPortalApproveMyProgramError(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('programId', '');
            PortalApproveAgentMyProgram approveMyProgram = new PortalApproveAgentMyProgram();
            clcommon.Response resp = approveMyProgram.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }
    //test the approval process Error
    @isTest
    static void testPortalApproveMyProgramCustomError(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('programId', null);
            PortalApproveAgentMyProgram approveMyProgram = new PortalApproveAgentMyProgram();
            clcommon.Response resp = approveMyProgram.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }
    
	@isTest
    static void method1(){ // program is blank
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
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
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', null);
            requestMap.put('SpecialTermE', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":2.5999999999999996,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":3.4,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Summer Crops\"}');
            requestMap.put('SpecialTermD', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":3.5,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":2.5,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"DDT\"}');
            requestMap.put('SpecialTermC', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":3.5999999999999996,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":2.4,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Pesticides\"}');
            requestMap.put('SpecialTermB', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.7,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.3,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Fertilisers\"}');
            requestMap.put('NoteRate', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.75,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.25,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Seeds\"}');
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }
    
     @isTest
    static void method2(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
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

        System.debug(rateCardHeaderTest.genesis__End_Date__c);
		rateCardHeaderTest.genesis__End_Date__c = Date.newInstance(2023, 07, 15);
        System.debug(rateCardHeaderTest.genesis__End_Date__c);

        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', json.serialize(rateCardHeaderTest));
            requestMap.put('SpecialTermB', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.7,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.3,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Fertilisers\"}');
            requestMap.put('NoteRate', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.75,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.25,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Seeds\"}');
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }

    @isTest
    static void method5(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
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
                                
        System.debug(rateCardHeaderTest.Loan_Fee_Advanced_On__c);
        rateCardHeaderTest.Loan_Fee_Advanced_On__c = null;
        System.debug(rateCardHeaderTest.Loan_Fee_Advanced_On__c);

        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', json.serialize(rateCardHeaderTest));
            requestMap.put('SpecialTermB', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.7,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.3,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Fertilisers\"}');
            requestMap.put('NoteRate', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.75,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.25,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Seeds\"}');
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }

    @isTest
    static void method6(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
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
                                
        rateCardHeaderTest.genesis__End_Date__c = null;

        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', json.serialize(rateCardHeaderTest));
            requestMap.put('SpecialTermB', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.7,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.3,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Fertilisers\"}');
            requestMap.put('NoteRate', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.75,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.25,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Seeds\"}');
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }

    @isTest
    static void method7(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
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
                                
        rateCardHeaderTest.Payer_of_Loan_Closing_Fee__c = null;

        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', json.serialize(rateCardHeaderTest));
            requestMap.put('SpecialTermB', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.7,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.3,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Fertilisers\"}');
            requestMap.put('NoteRate', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.75,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.25,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Seeds\"}');
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }

    @isTest
    static void method8(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
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
                                
        rateCardHeaderTest.Portion_of_Fee_to_Cover__c = null;

        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', json.serialize(rateCardHeaderTest));
            requestMap.put('SpecialTermB', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.7,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.3,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Fertilisers\"}');
            requestMap.put('NoteRate', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.75,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.25,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Seeds\"}');
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }
    
    @isTest
    static void method9(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
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
                                
        rateCardHeaderTest.Crop_Year__c = String.valueOf((System.today().year()+1));

        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', json.serialize(rateCardHeaderTest));
            requestMap.put('SpecialTermB', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.7,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.3,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Fertilisers\"}');
            requestMap.put('NoteRate', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.75,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.25,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Seeds\"}');
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }

    @isTest
    static void method10(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
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
                                
        rateCardHeaderTest.Portion_of_Fee_to_Cover__c = rateCardHeaderTest.Closing_Fee__c + 10;

        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', json.serialize(rateCardHeaderTest));
            requestMap.put('SpecialTermB', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.7,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.3,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Fertilisers\"}');
            requestMap.put('NoteRate', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.75,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.25,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Seeds\"}');
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }
    @isTest
    static void method11(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
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
                                
        rateCardHeaderTest.genesis__End_Date__c = Date.newInstance(System.today().year() - 1, 03, 15);

        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', json.serialize(rateCardHeaderTest));
            requestMap.put('SpecialTermB', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.7,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.3,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Fertilisers\"}');
            requestMap.put('NoteRate', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.75,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.25,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Seeds\"}');
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }

    @isTest
    static void method12(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
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
                                
        rateCardHeaderTest.Crop_Year__c = String.valueOf((System.today().year()));

        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', json.serialize(rateCardHeaderTest));
            requestMap.put('SpecialTermB', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.7,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.3,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Fertilisers\"}');
            requestMap.put('NoteRate', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.75,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.25,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Seeds\"}');
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }

    @isTest
    static void method13(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
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
                                
        rateCardHeaderTest.genesis__End_Date__c = Date.newInstance(Integer.valueOf(rateCardHeaderTest.Crop_Year__c)-1, 03, 15);

        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', json.serialize(rateCardHeaderTest));
            requestMap.put('SpecialTermB', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.7,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.3,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Fertilisers\"}');
            requestMap.put('NoteRate', '{\"interest\":[{\"Participation_Percentage_Dealer__c\":0,\"Participation_Percentage_Dealer_Subsidy__c\":4.75,\"Participation_Percentage_CFA__c\":1.5,\"Start_Date__c\":\"2022-07-14\",\"End_Date__c\":\"'+rateCardHeaderTest.genesis__End_Date__c+'\",\"genesis__Interest_Rate__c\":1.25,\"Interest_Rate_Type__c\":\"Variable\"}],\"description\":\"Seeds\"}');
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
        }
        Test.stopTest();
    }

// flexrate coverage
    @isTest
    static void method14(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 7685 AND
                                                        genesis__Interest_Rate__c = 1.45];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        Description__c,
                        Participation_Percentage_CFA__c,
                        Participation_Percentage_Dealer__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c,
                        genesis__Interest_Rate__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        rateCardDetailTest.add(tempRate);
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
                                    Portion_of_Fee_to_Cover__c


                                FROM genesis__Rate_Card_Setup_Header__c 
                                WHERE Name = 'My Test Program 99'];
        tempRate.End_Date__c = rateCardHeaderTest[0].genesis__End_Date__c;
        Database.update(tempRate);
        System.runAs(testUser){
            Map<String,Object> requestMap = new Map<String,Object>();
            Map<String,Object> flexPriceMap = new Map<String,Object>();
            // String programStr = Json.serialize(rateCardDetailTest);
            // String subString = programStr.substringBetween('sobjects/genesis__Rate_Card_Setup_Header__c/', '"},"Name":"');
            String rateCard = Json.serialize(rateCardHeaderTest[0]);
            String subString = rateCard.substringBetween('sobjects/genesis__Rate_Card_Setup_Header__c/', '"},"Name":"');
            String finalString = rateCard.replace(subString,'new_record_id');
            genesis__Rate_Card_Setup_Header__c objRate = (genesis__Rate_Card_Setup_Header__c) Json.deserialize(finalString, genesis__Rate_Card_Setup_Header__c.class);
            requestMap.put('flexRateProgram', objRate);
            requestMap.put('myProgramId','new_record_id');
            Map<String, Object> request = new Map<String,Object>();
            request.put('flexPricing',  '{"flexRateProgram":{"Portion_of_Fee_to_Cover__c":100,"Dealer_Participate_on_Closing_Fee__c":"Yes","Loan_Fee_Advanced_On__c":"A","Payer_of_Loan_Closing_Fee__c":"Grower","Closing_Fee__c":200,"CFA_Advantage_Rate__c":9,"Crop_Year__c":"2023","Id":"new_record_id","genesis__End_Date__c":"2024-03-15"},"myProgramId":"a8y740000004OzwAAE","ratePricing":{"NoteRate":{"description":"Sample Description A","interest":[{"Participation_Percentage_Dealer_Subsidy__c":1.5,"Participation_Percentage_Dealer__c":0,"Participation_Percentage_CFA__c":1.5,"Start_Date__c":"2023-03-28","End_Date__c":"2024-03-15","genesis__Interest_Rate__c":6,"Interest_Rate_Type__c":"Fixed"}]},"SpecialTermB":{},"SpecialTermC":{},"SpecialTermD":{},"SpecialTermE":{}}}');
            request.put('shouldValidate' , true);
            PortalCreateMyProgramAPI.createFlexRateCard(applicationObj.Id,request);
        }
        Test.stopTest();
    }

    @isTest
    static void method16(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'newuser@testorg.com'];
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 7685 AND
                                                        genesis__Interest_Rate__c = 1.45];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailTest = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Rate_Card_Setup_Detail__c tempRate = new genesis__Rate_Card_Setup_Detail__c();
        tempRate = [SELECT Id,
                        Name,
                        genesis__Rate_Card_Setup_Header__c,
                        Description__c,
                        Participation_Percentage_CFA__c,
                        Participation_Percentage_Dealer__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Interest_Rate_Type__c,
                        Start_Date__c,
                        End_Date__c,
                        genesis__Interest_Rate__c
                        FROM genesis__Rate_Card_Setup_Detail__c 
                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        rateCardDetailTest.add(tempRate);
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
                                    Portion_of_Fee_to_Cover__c


                                FROM genesis__Rate_Card_Setup_Header__c 
                                WHERE Name = 'My Test Program 99'];
        tempRate.End_Date__c = rateCardHeaderTest[0].genesis__End_Date__c;
        Database.update(tempRate);
        System.runAs(testUser){
            Map<String,Object> requestMap = new Map<String,Object>();
            Map<String,Object> flexPriceMap = new Map<String,Object>();
            // String programStr = Json.serialize(rateCardDetailTest);
            // String subString = programStr.substringBetween('sobjects/genesis__Rate_Card_Setup_Header__c/', '"},"Name":"');
            String rateCard = Json.serialize(rateCardHeaderTest[0]);
            String subString = rateCard.substringBetween('sobjects/genesis__Rate_Card_Setup_Header__c/', '"},"Name":"');
            String finalString = rateCard.replace(subString,'new_record_id');
            genesis__Rate_Card_Setup_Header__c objRate = (genesis__Rate_Card_Setup_Header__c) Json.deserialize(finalString, genesis__Rate_Card_Setup_Header__c.class);
            requestMap.put('flexRateProgram', objRate);
            requestMap.put('myProgramId','new_record_id');
            Map<String, Object> request = new Map<String,Object>();
            request.put('flexPricing',  '{"flexRateProgram":{"Portion_of_Fee_to_Cover__c":100,"Dealer_Participate_on_Closing_Fee__c":"Yes","Loan_Fee_Advanced_On__c":"A","Payer_of_Loan_Closing_Fee__c":"Dealer","Closing_Fee__c":200,"CFA_Advantage_Rate__c":9,"Crop_Year__c":"2023","Id":"new_record_id","genesis__End_Date__c":"2024-03-15"},"myProgramId":"a8y740000004OzwAAE","ratePricing":{"NoteRate":{"description":"Sample Description A","interest":[{"Participation_Percentage_Dealer_Subsidy__c":1.5,"Participation_Percentage_Dealer__c":0,"Participation_Percentage_CFA__c":1.5,"Start_Date__c":"2023-03-28","End_Date__c":"2024-03-15","genesis__Interest_Rate__c":6,"Interest_Rate_Type__c":"Fixed"}]},"SpecialTermB":{},"SpecialTermC":{},"SpecialTermD":{},"SpecialTermE":{}}}');
            request.put('shouldValidate' , true);
            PortalCreateMyProgramAPI.createFlexRateCard(applicationObj.Id,request);
        }
        Test.stopTest();
    }

}