/**
 * @description       : Test Class For Create My Program API
 * @author            : Pritam Roy
 * @group             : 
 * @last modified on  : 09-16-2024
 * @last modified by  : Rahul Gupta
**/
@isTest
private class PortalCreateMyProgramAPITest {
    /**
    * @description : Test Setup
    * @author  Pritam Roy | 03-20-2024 
    **/
    @TestSetup
    static void setup(){
        //Creating Product
        clcommon__CL_Product__c objProduct = LoanServicingTestHelper.createLoanProduct();
        Database.insert(objProduct, true);

        //Creating Business Information
        genesis__Business_Information__c businessInfoDealer = LoanServicingTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoDealer, true);

        //Creating the dealer parent account
        Account dealerCompany = LoanServicingTestHelper.createDealerAccount(businessInfoDealer.Id);
        Database.insert(dealerCompany, true);

        //Creating the CL Account
        Account dealerUserAccount = LoanServicingTestHelper.createCLAccount(businessInfoDealer.Id,dealerCompany.id);
        Database.insert(dealerUserAccount,true);

        //Creating the CL Contact
        Contact dealerContact = LoanServicingTestHelper.createCLContact(dealerUserAccount.Id);
        Database.insert(dealerContact,true);
        
        //Creating a test user
        User testUser = LoanServicingTestHelper.createCLUser(dealerContact.Id);
        Database.insert(testUser,true);
        
        //Creating Rate Card Setup Header
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerCompany);
        Database.insert(objRateCardHeader,true);

        //Creating Product Rate Card Association
        genesis__Product_Rate_Card_Association__c rateProduct = ApplicationOriginationTestHelper.createRateToProductAssociation(objProduct,objRateCardHeader);
        Database.insert(rateProduct, true);

        //Additional Determing Factor for Program
        genesis__Additional_Determining_Factor__c additionalFactor = ApplicationOriginationTestHelper.createAdditionalFactorForProgram(objRateCardHeader);
        Database.insert(additionalFactor, true);

        //Additional Factor for Dealer
        genesis__Additional_Determining_Factor__c additionalFactorDealer = ApplicationOriginationTestHelper.createAdditionalFactorForDealer(objRateCardHeader);
        Database.insert(additionalFactorDealer, true);

        //Creating Rate Card Setup Detail
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = ApplicationOriginationTestHelper.createNewRateCardSetupDetail(objRateCardHeader);
        Database.insert(objRateCardDetail, true);

        //Creating DBA Account
        Account accountObj = ApplicationOriginationTestHelper.createNewDBAccount(businessInfoDealer);
        Database.insert(accountObj, true);

        //Creating Application with Flex Rate
        genesis__Applications__c applicationObjFlex = ApplicationOriginationTestHelper.createApplicationForFlex(objProduct,accountObj);
        Database.insert(applicationObjFlex, true);
    }
    /**
    * @description : Generic Method for All Tranches My Program
    * @author  Pritam Roy | 03-27-2024 
    * @param requestMap 
    * @param objRateCardHeader 
    * @return Map<String, Object> 
    **/
    static Map<String,Object> createMyProgramAllTranches(Map<String,Object> requestMap,genesis__Rate_Card_Setup_Header__c objRateCardHeader){
        Map<String, Object> subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Summer Crops');
        subTrancheMap.put('assignBillingDate','false');
        List<Map<String,Object>> subTrancheInfoList = new List<Map<String,Object>>();

        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 2.2999999999999996,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-07-14',
                'End_Date__c' => objRateCardHeader.genesis__End_Date__c,
                'genesis__Interest_Rate__c' => 3.4,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheMap.put('interest',subTrancheInfoList);
        requestMap.put('SpecialTermH',JSON.serialize(subTrancheMap));

        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','DDT');
        subTrancheMap.put('assignBillingDate','false');

        subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 2.5999999999999996,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-07-14',
                'End_Date__c' => objRateCardHeader.genesis__End_Date__c,
                'genesis__Interest_Rate__c' => 3.4,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheMap.put('interest',subTrancheInfoList);
        requestMap.put('SpecialTermG',JSON.serialize(subTrancheMap));

        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','DDT');
        subTrancheMap.put('assignBillingDate','false');

        subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 2.5999999999999996,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-07-14',
                'End_Date__c' => '2024-08-31',
                'genesis__Interest_Rate__c' => 3.4,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 2.5999999999999996,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-09-01',
                'End_Date__c' => '2024-12-31',
                'genesis__Interest_Rate__c' => 3.4,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 2.5999999999999996,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2025-01-01',
                'End_Date__c' => objRateCardHeader.genesis__End_Date__c,
                'genesis__Interest_Rate__c' => 3.4,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheMap.put('interest',subTrancheInfoList);
        requestMap.put('SpecialTermF',JSON.serialize(subTrancheMap));

        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Machinery');
        subTrancheMap.put('assignBillingDate','false');

        subTrancheInfoList = new List<Map<String, Object>>();

        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 2.5999999999999996,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-07-14',
                'End_Date__c' => objRateCardHeader.genesis__End_Date__c,
                'genesis__Interest_Rate__c' => 3.4,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheMap.put('interest',subTrancheInfoList);
        requestMap.put('SpecialTermE',JSON.serialize(subTrancheMap));

        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','DDT');
        subTrancheMap.put('assignBillingDate','false');

        subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 3.5,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-07-14',
                'End_Date__c' => objRateCardHeader.genesis__End_Date__c,
                'genesis__Interest_Rate__c' => 2.5,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTrancheMap.put('interest',subTrancheInfoList);
        requestMap.put('SpecialTermD',JSON.serialize(subTrancheMap));

        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Pesticides');
        subTrancheMap.put('assignBillingDate','false');

        subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 3.5999999999999996,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-07-14',
                'End_Date__c' => objRateCardHeader.genesis__End_Date__c,
                'genesis__Interest_Rate__c' => 2.4,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheMap.put('interest',subTrancheInfoList);
        requestMap.put('SpecialTermC',JSON.serialize(subTrancheMap));

        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Fertilisers');
        subTrancheMap.put('assignBillingDate','false');

        subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 4.7,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-07-14',
                'End_Date__c' => objRateCardHeader.genesis__End_Date__c,
                'genesis__Interest_Rate__c' => 1.3,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheMap.put('interest',subTrancheInfoList);

        requestMap.put('SpecialTermB',JSON.serialize(subTrancheMap));

        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Seeds');
        subTrancheMap.put('assignBillingDate','false');

        subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 4.75,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-07-14',
                'End_Date__c' => objRateCardHeader.genesis__End_Date__c,
                'genesis__Interest_Rate__c' => 1.25,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTrancheMap.put('interest',subTrancheInfoList);

        requestMap.put('NoteRate',JSON.serialize(subTrancheMap));
        return requestMap;
    
    }
    /**
    * @description : Generic Method for Two Tranches My Program
    * @author  Pritam Roy | 03-27-2024 
    * @param requestMap 
    * @param objRateCardHeader 
    * @return Map<String, Object> 
    **/
    static Map<String,Object> createMyProgramForTwoTranches(Map<String,Object> requestMap,genesis__Rate_Card_Setup_Header__c objRateCardHeader){
        Map<String, Object> subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Fertilisers');

        List<Map<String,Object>> subTrancheInfoList = new List<Map<String,Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 4.7,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2022-07-14',
                'End_Date__c' => objRateCardHeader.genesis__End_Date__c,
                'genesis__Interest_Rate__c' => 1.3,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheMap.put('interest',subTrancheInfoList);
        requestMap.put('SpecialTermB',JSON.serialize(subTrancheMap));

        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Seeds');

        subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 4,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2022-07-14',
                'End_Date__c' => objRateCardHeader.genesis__End_Date__c,
                'genesis__Interest_Rate__c' => 1.25,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTrancheMap.put('interest',subTrancheInfoList);
        requestMap.put('NoteRate',JSON.serialize(subTrancheMap));
        return requestMap;
            
    }
    
    /**
    * @description : Create My Program
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPISuccess(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [SELECT Id, 
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
        objRateCardHeader.Field_Finance_Rate__c = 9.5;
        objRateCardHeader.genesis__End_Date__c = Date.newInstance(2025, 04, 15);
        objRateCardHeader.Crop_Year__c = '2025';
        Database.update(objRateCardHeader,true);
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('program', Json.serialize(objRateCardHeader));

        Map<String, Object> subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Summer Crops');

        List<Map<String,Object>> subTrancheInfoList = new List<Map<String,Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 2,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-07-14',
                'End_Date__c' => objRateCardHeader.genesis__End_Date__c,
                'genesis__Interest_Rate__c' => 3.4,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheMap.put('interest',subTrancheInfoList);
        requestMap.put('SpecialTermE',JSON.serialize(subTrancheMap));

        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','DDT');

        subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 3.5,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-07-14',
                'End_Date__c' => objRateCardHeader.genesis__End_Date__c,
                'genesis__Interest_Rate__c' => 2.5,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        
        subTrancheMap.put('interest',subTrancheInfoList);

        requestMap.put('SpecialTermD',JSON.serialize(subTrancheMap));

        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Pesticides');

        subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 3.5999999999999996,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-07-14',
                'End_Date__c' => objRateCardHeader.genesis__End_Date__c,
                'genesis__Interest_Rate__c' => 2.4,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheMap.put('interest',subTrancheInfoList);

        requestMap.put('SpecialTermC',JSON.serialize(subTrancheMap));

        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Fertilisers');

        subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 4.7,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-07-14',
                'End_Date__c' => objRateCardHeader.genesis__End_Date__c,
                'genesis__Interest_Rate__c' => 1.3,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheMap.put('interest',subTrancheInfoList);

        requestMap.put('SpecialTermB',JSON.serialize(subTrancheMap));

        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Seeds');

        subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 4.75,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-07-14',
                'End_Date__c' => objRateCardHeader.genesis__End_Date__c,
                'genesis__Interest_Rate__c' => 1.25,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTrancheMap.put('interest',subTrancheInfoList);

        requestMap.put('NoteRate',JSON.serialize(subTrancheMap));

        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Seeds');

        subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 4.75,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-07-14',
                'End_Date__c' => objRateCardHeader.genesis__End_Date__c,
                'genesis__Interest_Rate__c' => 1.25,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTrancheMap.put('interest',subTrancheInfoList);

        requestMap.put('SpecialTermF',JSON.serialize(subTrancheMap));

        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Seeds');

        subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 4.75,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-07-14',
                'End_Date__c' => objRateCardHeader.genesis__End_Date__c,
                'genesis__Interest_Rate__c' => 1.25,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTrancheMap.put('interest',subTrancheInfoList);

        requestMap.put('SpecialTermG',JSON.serialize(subTrancheMap));

        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Seeds');

        subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 4.75,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-07-14',
                'End_Date__c' => objRateCardHeader.genesis__End_Date__c,
                'genesis__Interest_Rate__c' => 1.25,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTrancheMap.put('interest',subTrancheInfoList);

        requestMap.put('SpecialTermH',JSON.serialize(subTrancheMap));
        
        System.runAs(testUser) {
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    /**
    * @description : Create Second My Program 
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testNewMyProgramAPISuccess(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [ SELECT  
                                        Name, 
                                        Account__c, 
                                        CFA_Advantage_Rate__c, 
                                        genesis__Description__c, 
                                        Crop_Year__c, 
                                        Closing_Fee__c , 
                                        Field_Finance_Rate__c,
                                        genesis__End_Date__c,
                                        Payer_of_Loan_Closing_Fee__c,
                                        Loan_Fee_Advanced_On__c,
                                        Dealer_Participate_on_Closing_Fee__c,
                                        Portion_of_Fee_to_Cover__c
                                FROM genesis__Rate_Card_Setup_Header__c 
                                WHERE Name = 'My Test Program 99'];
        objRateCardHeader.genesis__End_Date__c = Date.newInstance(2025, 04, 15);
        objRateCardHeader.Crop_Year__c = '2025';
        objRateCardHeader.Field_Finance_Rate__c = 9.5;
        Database.update(objRateCardHeader, true);                          
        Map<String,Object> requestMap = new Map<String,Object>();
        String programStr = Json.serialize(objRateCardHeader);
        String subString = programStr.substringBetween('sobjects/genesis__Rate_Card_Setup_Header__c/', '"},"Name":"');
        requestMap.put('program', programStr.replace(subString,'new_record_id'));
        requestMap = createMyProgramAllTranches(requestMap,objRateCardHeader);
        System.runAs(testUser) {        
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    /**
    * @description : Test My Program with dealer as payer
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testNewMyProgramAPIPayerDealerSuccess(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [ SELECT  
                                        Name, 
                                        Account__c, 
                                        CFA_Advantage_Rate__c, 
                                        genesis__Description__c, 
                                        Crop_Year__c, 
                                        Closing_Fee__c , 
                                        Field_Finance_Rate__c,
                                        genesis__End_Date__c,
                                        Payer_of_Loan_Closing_Fee__c,
                                        Loan_Fee_Advanced_On__c,
                                        Dealer_Participate_on_Closing_Fee__c,
                                        Portion_of_Fee_to_Cover__c
                                FROM genesis__Rate_Card_Setup_Header__c 
                                WHERE Name = 'My Test Program 99'];
        objRateCardHeader.Payer_of_Loan_Closing_Fee__c = 'Dealer';
        objRateCardHeader.genesis__End_Date__c = Date.newInstance(2025, 04, 15);
        objRateCardHeader.Crop_Year__c = '2025';
        objRateCardHeader.Field_Finance_Rate__c = 9.5;
        Database.update(objRateCardHeader,true);
        Map<String,Object> requestMap = new Map<String,Object>();
        String programStr = Json.serialize(objRateCardHeader);
        String subString = programStr.substringBetween('sobjects/genesis__Rate_Card_Setup_Header__c/', '"},"Name":"');
        requestMap.put('program', programStr.replace(subString,'new_record_id'));

        requestMap = createMyProgramAllTranches(requestMap,objRateCardHeader);
        System.runAs(testUser) {         
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    
    /**
    * @description : Maturity year same as crop year check and wrong maturity date
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIForWrongMaturityDateNovemberException(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [SELECT Id, 
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
        objRateCardHeader.genesis__End_Date__c = Date.newInstance(System.today().year(), 11, 15);
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(objRateCardHeader));
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    
    /**
    * @description : wrong maturity date
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIForWrongMaturityDateAprilException(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [SELECT Id, 
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
        objRateCardHeader.genesis__End_Date__c = Date.newInstance(System.today().year() + 1, 4, 15);
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(objRateCardHeader));
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    
    /**
    * @description : Wrong maturity date next year
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIForWrongMaturityDateNextYearException(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [SELECT Id, 
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
        objRateCardHeader.genesis__End_Date__c = Date.newInstance(System.today().year() + 2, 4, 15);
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(objRateCardHeader));
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    
    /**
    * @description : Wrong Maturity Date 14th of month
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIForWrongMaturityDateFourteenthOfTheMonthException(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [SELECT Id, 
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
        objRateCardHeader.genesis__End_Date__c = Date.newInstance(System.today().year(), 4, 14);
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(objRateCardHeader));
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    
    /**
    * @description : Wrong Maturity Date Previous Year
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIForWrongMaturityDatePreviousYearException(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [SELECT Id, 
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
        objRateCardHeader.genesis__End_Date__c = Date.newInstance(System.today().year() - 2, 4, 15);
        System.runAs(testUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(objRateCardHeader));
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    /**
    * @description : Test Exception
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIForException(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        System.runAs(testUser){
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize('blank'));
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    
    /**
    * @description : test the a new Flex Rate for subsidy
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIFlexRateCardSuccess(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 7685 AND
                                                        genesis__Interest_Rate__c = 1.45];
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetail = new List<genesis__Rate_Card_Setup_Detail__c>();
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
        objRateCardDetail.add(tempRate);
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeader = new List<genesis__Rate_Card_Setup_Header__c>();
        objRateCardHeader = [SELECT 
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
                                    Field_Finance_Rate__c

                                FROM genesis__Rate_Card_Setup_Header__c 
                                WHERE Name = 'My Test Program 99'];
        objRateCardHeader[0].Field_Finance_Rate__c = 9.5;
        objRateCardHeader[0].Crop_Year__c = '2025';
        Database.update(objRateCardHeader,true);                        
        tempRate.End_Date__c = objRateCardHeader[0].genesis__End_Date__c;
        Database.update(tempRate);
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('myProgramId','new_record_id');
        Map<String, Object> myProgramRequestMap = new Map<String,Object>();
        Map<String, Object> flexRateMap = new Map<String, Object>();

        Map<String, Object> programMap = new Map<String, Object>();
        programMap.put('genesis__End_Date__c', '2025-12-15');
        programMap.put('Id', 'new_record_id');
        programMap.put('Crop_Year__c', '2025');
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
                'Start_Date__c' => '2024-08-14',
                'End_Date__c' => '2024-08-31',
                'genesis__Interest_Rate__c' => 2.23,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 3.26,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-09-01',
                'End_Date__c' => '2025-12-15',
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
                'Start_Date__c' => '2024-08-14',
                'End_Date__c' => '2024-09-30',
                'genesis__Interest_Rate__c' => 2.34,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 2.83,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-10-01',
                'End_Date__c' => '2025-12-15',
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
        flexRatePricingMap.put('SpecialTermF',subTrancheMap);
        flexRatePricingMap.put('SpecialTermG',subTrancheMap);
        flexRatePricingMap.put('SpecialTermH',subTrancheMap);

        flexRateMap.put('ratePricing', flexRatePricingMap);
        myProgramRequestMap.put('flexPricing', JSON.serialize(flexRateMap));
        myProgramRequestMap.put('shouldValidate' , true);

        System.runAs(testUser){
            String flexRateCardId = PortalCreateMyProgramAPI.createFlexRateCard(applicationObj.Id,myProgramRequestMap);
            System.assertEquals(flexRateCardId!=null,true,'No Flex Rate Card Found');
        }
        Test.stopTest();
    }

    /**
    * @description : interest rate is present in D and E tranche
    * @author  Pritam Roy | 03-30-2024 
    **/
    @isTest
    static void testFlexRateCardSuccessRandomTranche(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 7685 AND
                                                        genesis__Interest_Rate__c = 1.45];
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetail = new List<genesis__Rate_Card_Setup_Detail__c>();
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
        objRateCardDetail.add(tempRate);
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeader = new List<genesis__Rate_Card_Setup_Header__c>();
        objRateCardHeader = [SELECT 
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
                                    Field_Finance_Rate__c

                                FROM genesis__Rate_Card_Setup_Header__c 
                                WHERE Name = 'My Test Program 99'];
        objRateCardHeader[0].Field_Finance_Rate__c = 9.5;
        objRateCardHeader[0].Crop_Year__c = '2025';
        Database.update(objRateCardHeader,true);                        
        tempRate.End_Date__c = objRateCardHeader[0].genesis__End_Date__c;
        Database.update(tempRate);
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('myProgramId','new_record_id');
        Map<String, Object> myProgramRequestMap = new Map<String,Object>();
        Map<String, Object> flexRateMap = new Map<String, Object>();

        Map<String, Object> programMap = new Map<String, Object>();
        programMap.put('genesis__End_Date__c', '2025-04-15');
        programMap.put('Id', 'new_record_id');
        programMap.put('Crop_Year__c', '2025');
        programMap.put('CFA_Advantage_Rate__c', 9.5);
        programMap.put('Field_Finance_Rate__c', 9.5);
        programMap.put('Closing_Fee__c', 200);
        programMap.put('Payer_of_Loan_Closing_Fee__c', 'Grower');
        programMap.put('Loan_Fee_Advanced_On__c', 'A');
        programMap.put('Dealer_Participate_on_Closing_Fee__c', 'No');

        flexRateMap.put('flexRateProgram', programMap);
        Map<String, Map<String, Object>> flexRatePricingMap = new Map<String, Map<String, Object>>();
        Map<String, Object> subTrancheMap = new Map<String, Object>();
        flexRatePricingMap.put('NoteRate',subTrancheMap);
        flexRatePricingMap.put('SpecialTermB',subTrancheMap);
        flexRatePricingMap.put('SpecialTermC',subTrancheMap);
        flexRatePricingMap.put('SpecialTermF',subTrancheMap);
        flexRatePricingMap.put('SpecialTermG',subTrancheMap);
        flexRatePricingMap.put('SpecialTermH',subTrancheMap);
        
        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Seeds');

        List<Map<String,Object>> subTrancheInfoList = new List<Map<String,Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 3,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-08-14',
                'End_Date__c' => '2024-08-31',
                'genesis__Interest_Rate__c' => 2.23,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 3.26,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-09-01',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 2.24,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheMap.put('interest',subTrancheInfoList);
        flexRatePricingMap.put('SpecialTermD',subTrancheMap);

        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Crops');

        subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 3.16,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-08-14',
                'End_Date__c' => '2024-09-30',
                'genesis__Interest_Rate__c' => 2.34,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 2.83,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-10-01',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 2.67,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTrancheMap.put('interest',subTrancheInfoList);
        flexRatePricingMap.put('SpecialTermE',subTrancheMap);

        subTrancheInfoList = new List<Map<String,Object>>();
        subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('interest',subTrancheInfoList);

        flexRateMap.put('ratePricing', flexRatePricingMap);
        myProgramRequestMap.put('flexPricing', JSON.serialize(flexRateMap));
        myProgramRequestMap.put('shouldValidate' , true);

        System.runAs(testUser){
            String flexRateCardId = PortalCreateMyProgramAPI.createFlexRateCard(applicationObj.Id,myProgramRequestMap);
            List<genesis__Rate_Card_Setup_Detail__c> objRateCardList = [SELECT Id,
                                                                                Special_Term_Reference__c 
                                                                            FROM genesis__Rate_Card_Setup_Detail__c 
                                                                            WHERE genesis__Rate_Card_Setup_Header__r.id =: flexRateCardId
                                                                            AND Special_Term_Reference__c = 'Special Term Sub-Tranche (B)'];
            
            System.assertEquals(objRateCardList.size()>0,true,'No Flex Rate Card Found');
        }
        Test.stopTest();
    }

    /**
    * @description : No Default Rate is Created
    * @author  Pritam Roy | 03-30-2024 
    **/
    @isTest
    static void testFlexRateCardSuccessNoInterestRate(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 7685 AND
                                                        genesis__Interest_Rate__c = 1.45];
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetail = new List<genesis__Rate_Card_Setup_Detail__c>();
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
        objRateCardDetail.add(tempRate);
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeader = new List<genesis__Rate_Card_Setup_Header__c>();
        objRateCardHeader = [SELECT 
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
                                    Field_Finance_Rate__c

                                FROM genesis__Rate_Card_Setup_Header__c 
                                WHERE Name = 'My Test Program 99'];
        objRateCardHeader[0].Field_Finance_Rate__c = 9.5;
        Database.update(objRateCardHeader,true);                        
        tempRate.End_Date__c = objRateCardHeader[0].genesis__End_Date__c;
        Database.update(tempRate);
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('myProgramId','new_record_id');
        Map<String, Object> myProgramRequestMap = new Map<String,Object>();
        Map<String, Object> flexRateMap = new Map<String, Object>();

        Map<String, Object> programMap = new Map<String, Object>();
        programMap.put('genesis__End_Date__c', '2026-03-15');
        programMap.put('Id', 'new_record_id');
        programMap.put('Crop_Year__c', '2025');
        programMap.put('CFA_Advantage_Rate__c', 9.5);
        programMap.put('Field_Finance_Rate__c', 9.5);
        programMap.put('Closing_Fee__c', 200);
        programMap.put('Payer_of_Loan_Closing_Fee__c', 'Grower');
        programMap.put('Loan_Fee_Advanced_On__c', 'A');
        programMap.put('Dealer_Participate_on_Closing_Fee__c', 'No');

        flexRateMap.put('flexRateProgram', programMap);
        Map<String, Map<String, Object>> flexRatePricingMap = new Map<String, Map<String, Object>>();
        Map<String, Object> subTrancheMap = new Map<String, Object>();
        flexRatePricingMap.put('NoteRate',subTrancheMap);
        flexRatePricingMap.put('SpecialTermB',subTrancheMap);
        flexRatePricingMap.put('SpecialTermC',subTrancheMap);
        flexRatePricingMap.put('SpecialTermD',subTrancheMap);
        flexRatePricingMap.put('SpecialTermE',subTrancheMap);
        flexRatePricingMap.put('SpecialTermF',subTrancheMap);
        flexRatePricingMap.put('SpecialTermG',subTrancheMap);
        flexRatePricingMap.put('SpecialTermH',subTrancheMap);

        

        flexRateMap.put('ratePricing', flexRatePricingMap);
        myProgramRequestMap.put('flexPricing', JSON.serialize(flexRateMap));
        myProgramRequestMap.put('shouldValidate' , true);

        System.runAs(testUser){
            String flexRateCardId = PortalCreateMyProgramAPI.createFlexRateCard(applicationObj.Id,myProgramRequestMap);
            List<genesis__Rate_Card_Setup_Detail__c> objRateCardList = [SELECT Id,
                                                                                Special_Term_Reference__c 
                                                                            FROM genesis__Rate_Card_Setup_Detail__c 
                                                                            WHERE genesis__Rate_Card_Setup_Header__r.id =: flexRateCardId 
                                                                            AND Special_Term_Reference__c = 'Special Term Sub-Tranche (A)'];
            
            System.assertEquals(objRateCardList.size()==0,true,'No Flex Rate Card Found');
        }
        Test.stopTest();
    }

    /**
    * @description : Blank My Program
    * @author  Pritam Roy | 03-20-2024 
    **/
	@isTest
    static void testMyProgramAPIBlankProgramException(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [SELECT Id, 
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
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('program', null);
        requestMap = createMyProgramAllTranches(requestMap,objRateCardHeader);
        System.runAs(testUser) {
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    /**
    * @description : My Program Wrong End Date
    * @author  Pritam Roy | 03-20-2024 
    **/
     @isTest
    static void testMyProgramAPIWrongEndDateException(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [SELECT Id, 
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
		objRateCardHeader.genesis__End_Date__c = Date.newInstance(2023, 07, 15);
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('program', json.serialize(objRateCardHeader));
        requestMap = createMyProgramForTwoTranches(requestMap,objRateCardHeader);

        System.runAs(testUser) {
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    /**
    * @description : Test My Program Default Rate Exception
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIDefaultRateException(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [SELECT Id, 
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
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('program', json.serialize(objRateCardHeader));
        requestMap.put('NoteRate', '{\"interest\":[]}');
                                
        System.runAs(testUser) {
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    /**
    * @description : Loan Fee Advanced Empty
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIExceptionLoanFeeAdvancedEmptyException(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [SELECT Id, 
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
        objRateCardHeader.Loan_Fee_Advanced_On__c = null;
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('program', json.serialize(objRateCardHeader));
        requestMap = createMyProgramForTwoTranches(requestMap,objRateCardHeader);

        System.runAs(testUser) {
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    /**
    * @description : Api Exception Empty End Date
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIExceptionEmptyEndDateException(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [SELECT Id, 
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
                                
        objRateCardHeader.genesis__End_Date__c = null;
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('program', json.serialize(objRateCardHeader));
        requestMap = createMyProgramForTwoTranches(requestMap,objRateCardHeader);

        System.runAs(testUser) {
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    /**
    * @description : Payer of Loan Closing Fee is Null
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIExceptionEmptyPayerOfLoanClosingFeeException(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [SELECT Id, 
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
                                
        objRateCardHeader.Payer_of_Loan_Closing_Fee__c = null;
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('program', json.serialize(objRateCardHeader));
        requestMap = createMyProgramForTwoTranches(requestMap,objRateCardHeader);

        System.runAs(testUser) {
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    /**
    * @description : Portion of Fee to Cover is Null
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIPortionFeeEmptyException(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [SELECT Id, 
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
                                
        objRateCardHeader.Portion_of_Fee_to_Cover__c = null;
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('program', json.serialize(objRateCardHeader));
        requestMap = createMyProgramForTwoTranches(requestMap,objRateCardHeader);

        System.runAs(testUser) {
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    /**
    * @description : Wrong Crop Year next year
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIWrongCropYearException(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [SELECT Id, 
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
                                
        objRateCardHeader.Crop_Year__c = String.valueOf((System.today().year()+1));
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('program', json.serialize(objRateCardHeader));
        requestMap = createMyProgramForTwoTranches(requestMap,objRateCardHeader);

        System.runAs(testUser) {
            
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    /**
    * @description : Excess Closing Fee
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIExcessClosingFeeException(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [SELECT Id, 
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
                                
        objRateCardHeader.Portion_of_Fee_to_Cover__c = objRateCardHeader.Closing_Fee__c + 10;
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('program', json.serialize(objRateCardHeader));
        requestMap = createMyProgramForTwoTranches(requestMap,objRateCardHeader);

        System.runAs(testUser) {
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    /**
    * @description : Wrong Crop Year previous year
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPWrongYearException(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [SELECT Id, 
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
                                
        objRateCardHeader.genesis__End_Date__c = Date.newInstance(System.today().year() - 1, 03, 15);
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('program', json.serialize(objRateCardHeader));
        requestMap = createMyProgramForTwoTranches(requestMap,objRateCardHeader);

        System.runAs(testUser) {
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    /**
    * @description : Wrong Date
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPITierNotFoundException(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [SELECT Id, 
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
                                
        objRateCardHeader.Crop_Year__c = String.valueOf((System.today().year()));
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('program', json.serialize(objRateCardHeader));
        requestMap = createMyProgramForTwoTranches(requestMap,objRateCardHeader);

        System.runAs(testUser) {
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    /**
    * @description : Wrong End Date
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIWrongDateNoTierFoundException(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardHeader = [SELECT Id, 
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
                                
        objRateCardHeader.genesis__End_Date__c = Date.newInstance(Integer.valueOf(objRateCardHeader.Crop_Year__c)-1, 03, 15);
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('program', json.serialize(objRateCardHeader));
        requestMap = createMyProgramForTwoTranches(requestMap,objRateCardHeader);

        System.runAs(testUser) {
            PortalCreateMyProgramAPI createMyProgramAPI = new PortalCreateMyProgramAPI();
            clcommon.Response resp = createMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'No Rate Card Found');
        }
        Test.stopTest();
    }
    /**
    * @description : Test Flex Rate Loan Closing Fee Grower
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIFlexRateLoanClosingFeeGrowerSuccess(){
        Test.startTest();
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 7685 AND
                                                        genesis__Interest_Rate__c = 1.45];
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetail = new List<genesis__Rate_Card_Setup_Detail__c>();
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
        objRateCardDetail.add(tempRate);
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeader = new List<genesis__Rate_Card_Setup_Header__c>();
        objRateCardHeader = [SELECT 
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
        objRateCardHeader[0].genesis__End_Date__c = Date.newInstance(2024, 04, 15);
        objRateCardHeader[0].Crop_Year__c = '2025';
        Database.update(objRateCardHeader, true);
        tempRate.End_Date__c = Date.newInstance(2024, 04, 15);
        Database.update(tempRate, true);
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('myProgramId','new_record_id');
        Map<String, Object> myProgramRequestMap = new Map<String,Object>();
        Map<String, Object> flexRateMap = new Map<String, Object>();

        Map<String, Object> programMap = new Map<String, Object>();
        programMap.put('genesis__End_Date__c', '2025-04-15');
        programMap.put('Id', 'new_record_id');
        programMap.put('Crop_Year__c', '2025');
        programMap.put('CFA_Advantage_Rate__c', 9.5);
        programMap.put('Field_Finance_Rate__c', 9.5);
        programMap.put('Closing_Fee__c', 200);
        programMap.put('Payer_of_Loan_Closing_Fee__c', 'Grower');
        programMap.put('Loan_Fee_Advanced_On__c', 'A');
        programMap.put('Dealer_Participate_on_Closing_Fee__c', 'Yes');
        programMap.put('Portion_of_Fee_to_Cover__c', 100);

        flexRateMap.put('flexRateProgram', programMap);
        Map<String, Map<String, Object>> flexRatePricingMap = new Map<String, Map<String, Object>>();

        
        Map<String, Object> subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Seeds');

        List<Map<String,Object>> subTrancheInfoList = new List<Map<String,Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 1.5,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2024-03-28',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 6,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );
        
        subTrancheMap.put('interest',subTrancheInfoList);
        flexRatePricingMap.put('NoteRate',subTrancheMap);

        subTrancheMap = new Map<String, Object>();
        flexRatePricingMap.put('SpecialTermB',subTrancheMap);
        flexRatePricingMap.put('SpecialTermC',subTrancheMap);
        flexRatePricingMap.put('SpecialTermD',subTrancheMap);
        flexRatePricingMap.put('SpecialTermE',subTrancheMap);
        flexRatePricingMap.put('SpecialTermF',subTrancheMap);
        flexRatePricingMap.put('SpecialTermG',subTrancheMap);
        flexRatePricingMap.put('SpecialTermH',subTrancheMap);

        flexRateMap.put('ratePricing', flexRatePricingMap);
        myProgramRequestMap.put('flexPricing', JSON.serialize(flexRateMap));
        myProgramRequestMap.put('shouldValidate' , true);

        System.runAs(testUser){
            String flexRateCardId = PortalCreateMyProgramAPI.createFlexRateCard(applicationObj.Id,myProgramRequestMap);
            System.assertEquals(flexRateCardId!=null,true,'No Flex Rate Found');
        }
        Test.stopTest();
    }
    /**
    * @description : Test Flex Rate Null Tranche
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIFlexRateNullTrancheException(){
        Test.startTest();
        String flexRateCardId;
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 7685 AND
                                                        genesis__Interest_Rate__c = 1.45];
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetail = new List<genesis__Rate_Card_Setup_Detail__c>();
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
        objRateCardDetail.add(tempRate);
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeader = new List<genesis__Rate_Card_Setup_Header__c>();
        objRateCardHeader = [SELECT 
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
        tempRate.End_Date__c = objRateCardHeader[0].genesis__End_Date__c;
        Database.update(tempRate);
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('myProgramId','new_record_id');
        Map<String, Object> myProgramRequestMap = new Map<String,Object>();
        Map<String, Object> flexRateMap = new Map<String, Object>();

        Map<String, Object> programMap = new Map<String, Object>();
        programMap.put('genesis__End_Date__c', '2025-03-15');
        programMap.put('Id', 'new_record_id');
        programMap.put('Crop_Year__c', '2024');
        programMap.put('CFA_Advantage_Rate__c', 9.5);
        programMap.put('Field_Finance_Rate__c', 9.5);
        programMap.put('Closing_Fee__c', 200);
        programMap.put('Payer_of_Loan_Closing_Fee__c', 'Grower');
        programMap.put('Loan_Fee_Advanced_On__c', 'A');
        programMap.put('Dealer_Participate_on_Closing_Fee__c', 'Yes');
        programMap.put('Portion_of_Fee_to_Cover__c', 100);

        flexRateMap.put('flexRateProgram', programMap);
        Map<String, Map<String, Object>> flexRatePricingMap = new Map<String, Map<String, Object>>();

        
        Map<String, Object> subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Seeds');

        List<Map<String,Object>> subTrancheInfoList = new List<Map<String,Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 1.5,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2023-03-28',
                'End_Date__c' => '2025-03-15',
                'genesis__Interest_Rate__c' => 6,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );
        
        subTrancheMap.put('interest',subTrancheInfoList);
        flexRatePricingMap.put('NoteRate',null);

        subTrancheMap = new Map<String, Object>();
        flexRatePricingMap.put('SpecialTermB',subTrancheMap);
        flexRatePricingMap.put('SpecialTermC',subTrancheMap);
        flexRatePricingMap.put('SpecialTermD',subTrancheMap);
        flexRatePricingMap.put('SpecialTermE',subTrancheMap);

        flexRateMap.put('ratePricing', flexRatePricingMap);
        myProgramRequestMap.put('flexPricing', JSON.serialize(flexRateMap));
        myProgramRequestMap.put('shouldValidate' , true);

        System.runAs(testUser){
            String exceptionString;
            try{
                flexRateCardId = PortalCreateMyProgramAPI.createFlexRateCard(applicationObj.Id,myProgramRequestMap);
            }catch(Exception objException){
                exceptionString = objException.getMessage();
            }
            System.assertEquals(exceptionString!=null,true,'No Exception');
        }
        Test.stopTest();
    }
    /**
    * @description : Test null flexpricing argument
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIFlexRateNullFlexPricingException(){
        Test.startTest();
        String flexRateCardId;
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 7685 AND
                                                        genesis__Interest_Rate__c = 1.45];
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetail = new List<genesis__Rate_Card_Setup_Detail__c>();
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
        objRateCardDetail.add(tempRate);
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeader = new List<genesis__Rate_Card_Setup_Header__c>();
        objRateCardHeader = [SELECT 
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
        tempRate.End_Date__c = objRateCardHeader[0].genesis__End_Date__c;
        Database.update(tempRate);
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('myProgramId','new_record_id');
        Map<String, Object> myProgramRequestMap = new Map<String,Object>();
        Map<String, Object> programMap = new Map<String, Object>();
        programMap.put('genesis__End_Date__c', '2025-03-15');
        programMap.put('Id', 'new_record_id');
        programMap.put('Crop_Year__c', '2024');
        programMap.put('CFA_Advantage_Rate__c', 9.5);
        programMap.put('Field_Finance_Rate__c', 9.5);
        programMap.put('Closing_Fee__c', 200);
        programMap.put('Payer_of_Loan_Closing_Fee__c', 'Grower');
        programMap.put('Loan_Fee_Advanced_On__c', 'A');
        programMap.put('Dealer_Participate_on_Closing_Fee__c', 'Yes');
        programMap.put('Portion_of_Fee_to_Cover__c', 100);

        myProgramRequestMap.put('flexPricing', null);
        myProgramRequestMap.put('shouldValidate' , true);

        System.runAs(testUser){
            String exceptionString;
            try{
                flexRateCardId = PortalCreateMyProgramAPI.createFlexRateCard(applicationObj.Id,myProgramRequestMap);
            }catch(Exception objException){
                exceptionString = objException.getMessage();
            }
            System.assertEquals(exceptionString!=null,true,'No Exception');
        }
        Test.stopTest();
    }

    /**
    * @description : test the a new Flex Rate Null ShouldValidate
    * @author  Pritam Roy | 03-20-2024 
    **/
    @isTest
    static void testMyProgramAPIFlexRateNullShouldValidate(){
        Test.startTest();
        String flexRateCardId;
        User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 7685 AND
                                                        genesis__Interest_Rate__c = 1.45];
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetail = new List<genesis__Rate_Card_Setup_Detail__c>();
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
        objRateCardDetail.add(tempRate);
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeader = new List<genesis__Rate_Card_Setup_Header__c>();
        objRateCardHeader = [SELECT 
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
                                    Field_Finance_Rate__c

                                FROM genesis__Rate_Card_Setup_Header__c 
                                WHERE Name = 'My Test Program 99'];
        objRateCardHeader[0].Field_Finance_Rate__c = 9.5;
        Database.update(objRateCardHeader,true);                        
        tempRate.End_Date__c = objRateCardHeader[0].genesis__End_Date__c;
        Database.update(tempRate);
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
        myProgramRequestMap.put('shouldValidate' , null);

        System.runAs(testUser){
            String exceptionString;
            try{
                flexRateCardId = PortalCreateMyProgramAPI.createFlexRateCard(applicationObj.Id,myProgramRequestMap);
            }catch(Exception objException){
                exceptionString = objException.getMessage();
            }
            System.assertEquals(exceptionString!=null,true,'No Exception');
        }
        Test.stopTest();
    }
}