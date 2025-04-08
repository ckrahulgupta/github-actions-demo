/**
 * @description       : Test class for SaveRateCardDetailsHandler
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 09-09-2024
 * @last modified by  : Sk Minsar
**/
@isTest
public inherited sharing class SaveRateCardDetailsHandlerTest {
    /**
    * @description - Creating Data
    * @author Sk Minsar | 09-05-2024 
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

        clcommon__Floating_Rate_Index__c floatingRateIndex = ApplicationOriginationTestHelper.createFloatingRateIndex('CFA_Advantage_Rate',11);
        Database.insert(floatingRateIndex, true);

        CFA_Partner_Program__c partnerProgram = ApplicationOriginationTestHelper.createPartnerProgram('Test Partner Program',floatingRateIndex);
        Database.insert(partnerProgram, true);

        Account account = ApplicationOriginationTestHelper.createPartnerAccount('Test Account',partnerProgram);
        Database.insert(account, true);
    }
   
    /**
    * @description : Generic Method for All Tranches My Program
    * @author Sk Minsar | 09-05-2024 
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
    * @author Sk Minsar | 09-05-2024 
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
    * @description 
    * @author Sk Minsar | 09-05-2024 
    **/
    @isTest
    public static void testupdateRateCardDetail(){

        // User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String, List<Object>>();
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<String> descriptionList = new List<String>();
        List<String> objDealerNameList = new List<String>();
        List<Tier_Participation_Rate__mdt> objTierParticipationList = new List<Tier_Participation_Rate__mdt>();
        Map<String,Object> rateCardMap = new Map<String,Object>();
        objRateCardHeaderList = [ SELECT Id,
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
                                        Portion_of_Fee_to_Cover__c,
                                        Account__r.Name,
                                        Account__r.Tier__c
                                    FROM genesis__Rate_Card_Setup_Header__c 
                                    WHERE Name = 'My Test Program 99'];
        objRateCardHeaderList[0].genesis__End_Date__c = Date.newInstance(2025, 04, 15);
        objRateCardHeaderList[0].Crop_Year__c = '2025';
        objRateCardHeaderList[0].Field_Finance_Rate__c = 9.5;
        clcommon__Floating_Rate_Index__c floatingRateIndex = [SELECT id FROM clcommon__Floating_Rate_Index__c LIMIT 1];
        objRateCardHeaderList[0].Base_Rate__c = floatingRateIndex.id;
        Database.update(objRateCardHeaderList[0], true);    
        
        objDealerNameList.add(objRateCardHeaderList[0].Account__r.Name);

        objProgramList =  [SELECT  Id, 
                                   genesis__Field_Value__c 
                                FROM genesis__Additional_Determining_Factor__c 
                                WHERE genesis__Field_Value__c = 'My Test Program 99'
                                LIMIT 1];
        objDealerList =  [SELECT Id, 
                                 genesis__Field_Value__c 
                                 FROM genesis__Additional_Determining_Factor__c 
                                 WHERE Name =: PortalConstants.DEALER_PROFILE
                                 LIMIT 1];
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
        objRateCardDetailList.add(tempRate);
        objRateCardDetailList.add(objNextRate);
        
        descriptionList.add(tempRate.Description__c);

        // rate card header 
        rateCardDetailInfoMap.put('header',objRateCardHeaderList);
        // additional determining factor for program
        rateCardDetailInfoMap.put('program',objProgramList);
        //addition determining factor for Dealer
        rateCardDetailInfoMap.put('dealer', objDealerList); 

        rateCardDetailInfoMap.put('detail',objRateCardDetailList);
        rateCardDetailInfoMap.put('dealerName',objDealerNameList);
        rateCardDetailInfoMap.put('description',descriptionList);
        rateCardDetailInfoMap.put(PortalConstants.ASSIGN_BILLING_DATE,new List<Boolean>{true});
        rateCardDetailInfoMap.put(PortalConstants.BILLING_DATE,new List<Date>{System.today()});

        objTierParticipationList = [SELECT Id,
                                            Label,
                                            DeveloperName,
                                            Start_Date__c,
                                            End_Date__c,
                                            CFA_Participation_Rate__c,
                                            Crop_Year__c
                                    FROM Tier_Participation_Rate__mdt
                                    WHERE Label =: objRateCardHeaderList[0].Account__r.Tier__c
                                    AND Crop_Year__c =: objRateCardHeaderList[0].Crop_Year__c
                                    ORDER BY Start_Date__c ];
        PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper objRateCardDateWrapper = new PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper();
        objRateCardDateWrapper.startDate = objTierParticipationList[0].Start_Date__c;
        objRateCardDateWrapper.endDate = objTierParticipationList[0].End_Date__c;
        objRateCardDateWrapper.defaultRateCard = true;
        objRateCardDateWrapper.rateCardDetailInfoMap = rateCardDetailInfoMap;

        rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objRateCardDetailList[0]));
        Test.startTest();
        System.runAs(testUser) {        
            List<genesis__Rate_Card_Setup_Detail__c> resultList = SaveRateCardDetailsHandler.updateRateCardDetail(objRateCardDateWrapper,rateCardMap,objTierParticipationList);
            System.assertEquals(resultList.size()!=null, true, 'Assertion Failed');
        }
        Test.stopTest();
        
    }

    /**
    * @description 
    * @author Sk Minsar | 09-05-2024 
    **/
    @isTest
    public static void testCreateMasterRateCardDetail(){

        // User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String, List<Object>>();
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<String> descriptionList = new List<String>();
        List<String> objDealerNameList = new List<String>();
        Map<String,Object> rateCardMap = new Map<String,Object>();
        objRateCardHeaderList = [ SELECT Id,
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
                                        Portion_of_Fee_to_Cover__c,
                                        Account__r.Name,
                                        Account__r.Tier__c
                                    FROM genesis__Rate_Card_Setup_Header__c 
                                    WHERE Name = 'My Test Program 99'];
        objRateCardHeaderList[0].genesis__End_Date__c = Date.newInstance(2025, 04, 15);
        objRateCardHeaderList[0].Crop_Year__c = '2025';
        objRateCardHeaderList[0].Field_Finance_Rate__c = 9.5;
        clcommon__Floating_Rate_Index__c floatingRateIndex = [SELECT id FROM clcommon__Floating_Rate_Index__c LIMIT 1];
        objRateCardHeaderList[0].Base_Rate__c = floatingRateIndex.id;
        Database.update(objRateCardHeaderList[0], true);    
        
        objDealerNameList.add(objRateCardHeaderList[0].Account__r.Name);

        // Map<String,Object> requestMap = new Map<String,Object>();
        // String programStr = Json.serialize(objRateCardHeader);
        // String subString = programStr.substringBetween('sobjects/genesis__Rate_Card_Setup_Header__c/', '"},"Name":"');
        // requestMap.put('program', programStr.replace(subString,'new_record_id'));
        // requestMap = createMyProgramAllTranches(requestMap,objRateCardHeader);

        objProgramList =  [SELECT  Id, 
                                   genesis__Field_Value__c 
                                FROM genesis__Additional_Determining_Factor__c 
                                WHERE genesis__Field_Value__c = 'My Test Program 99'
                                LIMIT 1];
        objDealerList =  [SELECT Id, 
                                 genesis__Field_Value__c 
                                 FROM genesis__Additional_Determining_Factor__c 
                                 WHERE Name =: PortalConstants.DEALER_PROFILE
                                 LIMIT 1];
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
        objRateCardDetailList.add(tempRate);
        objRateCardDetailList.add(objNextRate);
        
        descriptionList.add(tempRate.Description__c);

        // rate card header 
        rateCardDetailInfoMap.put('header',objRateCardHeaderList);
        // additional determining factor for program
        rateCardDetailInfoMap.put('program',objProgramList);
        //addition determining factor for Dealer
        rateCardDetailInfoMap.put('dealer', objDealerList); 

        rateCardDetailInfoMap.put('detail',objRateCardDetailList);
        rateCardDetailInfoMap.put('dealerName',objDealerNameList);
        rateCardDetailInfoMap.put('description',descriptionList);
        rateCardDetailInfoMap.put(PortalConstants.ASSIGN_BILLING_DATE,new List<Boolean>{true});
        rateCardDetailInfoMap.put(PortalConstants.BILLING_DATE,new List<Date>{System.today()});

        PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper objRateCardDateWrapper = new PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper();
        objRateCardDateWrapper.startDate = System.today();
        objRateCardDateWrapper.endDate = System.today().addMonths(3);
        objRateCardDateWrapper.defaultRateCard = true;
        objRateCardDateWrapper.rateCardDetailInfoMap = rateCardDetailInfoMap;

        rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objRateCardDetailList[0]));
        Test.startTest();
        System.runAs(testUser) {        
            genesis__Rate_Card_Setup_Detail__c result = SaveRateCardDetailsHandler.createMasterRateCardDetail(objRateCardDateWrapper,rateCardMap);
            System.assertEquals(result != null, true, 'Assertion Failed');
        }
        Test.stopTest();
        
    }

    /**
    * @description 
    * @author Sk Minsar | 09-05-2024 
    **/
    @isTest
    static void testCreateMasterDefaultDetail(){

        // User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String, List<Object>>();
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<String> descriptionList = new List<String>();
        List<String> objDealerNameList = new List<String>();
        Map<String,Object> rateCardMap = new Map<String,Object>();
        objRateCardHeaderList = [ SELECT Id,
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
                                        Portion_of_Fee_to_Cover__c,
                                        Account__r.Name,
                                        Account__r.Tier__c
                                    FROM genesis__Rate_Card_Setup_Header__c 
                                    WHERE Name = 'My Test Program 99'];
        objRateCardHeaderList[0].genesis__End_Date__c = Date.newInstance(2025, 04, 15);
        objRateCardHeaderList[0].Crop_Year__c = '2025';
        objRateCardHeaderList[0].Field_Finance_Rate__c = 9.5;
        clcommon__Floating_Rate_Index__c floatingRateIndex = [SELECT id FROM clcommon__Floating_Rate_Index__c LIMIT 1];
        objRateCardHeaderList[0].Base_Rate__c = floatingRateIndex.id;
        Database.update(objRateCardHeaderList[0], true);    
        
        objDealerNameList.add(objRateCardHeaderList[0].Account__r.Name);



        objProgramList =  [SELECT  Id, 
                                   genesis__Field_Value__c 
                                FROM genesis__Additional_Determining_Factor__c 
                                WHERE genesis__Field_Value__c = 'My Test Program 99'
                                LIMIT 1];
        objDealerList =  [SELECT Id, 
                                 genesis__Field_Value__c 
                                 FROM genesis__Additional_Determining_Factor__c 
                                 WHERE Name =: PortalConstants.DEALER_PROFILE
                                 LIMIT 1];
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
        objRateCardDetailList.add(tempRate);
        objRateCardDetailList.add(objNextRate);
        
        descriptionList.add(tempRate.Description__c);

        // rate card header 
        rateCardDetailInfoMap.put('header',objRateCardHeaderList);
        // additional determining factor for program
        rateCardDetailInfoMap.put('program',objProgramList);
        //addition determining factor for Dealer
        rateCardDetailInfoMap.put('dealer', objDealerList); 

        rateCardDetailInfoMap.put('detail',objRateCardDetailList);
        rateCardDetailInfoMap.put('dealerName',objDealerNameList);
        rateCardDetailInfoMap.put('description',descriptionList);
        rateCardDetailInfoMap.put(PortalConstants.ASSIGN_BILLING_DATE,new List<Boolean>{true});
        rateCardDetailInfoMap.put(PortalConstants.BILLING_DATE,new List<Date>{System.today()});

        PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper objRateCardDateWrapper = new PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper();
        objRateCardDateWrapper.startDate = System.today();
        objRateCardDateWrapper.endDate = System.today().addMonths(3);
        objRateCardDateWrapper.defaultRateCard = true;
        objRateCardDateWrapper.rateCardDetailInfoMap = rateCardDetailInfoMap;

        rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objRateCardDetailList[0]));
        Test.startTest();
        System.runAs(testUser) {        
            genesis__Rate_Card_Setup_Detail__c result = SaveRateCardDetailsHandler.createMasterDefaultDetail(objRateCardDateWrapper,rateCardMap);
            System.assertEquals(result != null, true, 'Assertion Failed');
        }
        Test.stopTest();
    }
    /**
    * @description 
    * @author Sk Minsar | 09-05-2024 
    **/
    @isTest
    static void testcreateRateCardBeforeLastRange(){

        // User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String, List<Object>>();
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<String> descriptionList = new List<String>();
        List<String> objDealerNameList = new List<String>();
        List<Tier_Participation_Rate__mdt> objTierParticipationList = new List<Tier_Participation_Rate__mdt>();
        Map<String,Object> rateCardMap = new Map<String,Object>();
        objRateCardHeaderList = [ SELECT Id,
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
                                        Portion_of_Fee_to_Cover__c,
                                        Account__r.Name,
                                        Account__r.Tier__c
                                    FROM genesis__Rate_Card_Setup_Header__c 
                                    WHERE Name = 'My Test Program 99'];
        objRateCardHeaderList[0].genesis__End_Date__c = Date.newInstance(2025, 04, 15);
        objRateCardHeaderList[0].Crop_Year__c = '2025';
        objRateCardHeaderList[0].Field_Finance_Rate__c = 9.5;
        clcommon__Floating_Rate_Index__c floatingRateIndex = [SELECT id FROM clcommon__Floating_Rate_Index__c LIMIT 1];
        objRateCardHeaderList[0].Base_Rate__c = floatingRateIndex.id;
        Database.update(objRateCardHeaderList[0], true);    
        
        objDealerNameList.add(objRateCardHeaderList[0].Account__r.Name);

        objProgramList =  [SELECT  Id, 
                                   genesis__Field_Value__c 
                                FROM genesis__Additional_Determining_Factor__c 
                                WHERE genesis__Field_Value__c = 'My Test Program 99'
                                LIMIT 1];
        objDealerList =  [SELECT Id, 
                                 genesis__Field_Value__c 
                                 FROM genesis__Additional_Determining_Factor__c 
                                 WHERE Name =: PortalConstants.DEALER_PROFILE
                                 LIMIT 1];
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
        objRateCardDetailList.add(tempRate);
        objRateCardDetailList.add(objNextRate);
        
        descriptionList.add(tempRate.Description__c);

        // rate card header 
        rateCardDetailInfoMap.put('header',objRateCardHeaderList);
        // additional determining factor for program
        rateCardDetailInfoMap.put('program',objProgramList);
        //addition determining factor for Dealer
        rateCardDetailInfoMap.put('dealer', objDealerList); 

        rateCardDetailInfoMap.put('detail',objRateCardDetailList);
        rateCardDetailInfoMap.put('dealerName',objDealerNameList);
        rateCardDetailInfoMap.put('description',descriptionList);
        rateCardDetailInfoMap.put(PortalConstants.ASSIGN_BILLING_DATE,new List<Boolean>{true});
        rateCardDetailInfoMap.put(PortalConstants.BILLING_DATE,new List<Date>{System.today()});

        objTierParticipationList = [SELECT Id,
                                            Label,
                                            DeveloperName,
                                            Start_Date__c,
                                            End_Date__c,
                                            CFA_Participation_Rate__c,
                                            Crop_Year__c
                                    FROM Tier_Participation_Rate__mdt
                                    WHERE Label =: objRateCardHeaderList[0].Account__r.Tier__c
                                    AND Crop_Year__c =: objRateCardHeaderList[0].Crop_Year__c
                                    ORDER BY Start_Date__c ];
        PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper objRateCardDateWrapper = new PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper();
        objRateCardDateWrapper.startDate = (objTierParticipationList[0].Start_Date__c).addDays(-2);
        objRateCardDateWrapper.endDate = objTierParticipationList[0].End_Date__c;
        objRateCardDateWrapper.defaultRateCard = true;
        objRateCardDateWrapper.rateCardDetailInfoMap = rateCardDetailInfoMap;

        rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objRateCardDetailList[0]));
        Test.startTest();
        System.runAs(testUser) {        
            List<genesis__Rate_Card_Setup_Detail__c> resultList = SaveRateCardDetailsHandler.updateRateCardDetail(objRateCardDateWrapper,rateCardMap,objTierParticipationList);
            System.assertEquals(resultList.size()!=null, true, 'Assertion Failed');
        }
        Test.stopTest();
       }
    /**
    * @description - Test createRateCardWhenInRange method
    * @author Sk Minsar | 09-05-2024 
    **/
    @isTest
    static void testcreateRateCardWhenInRange(){

        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String, List<Object>>();
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<String> descriptionList = new List<String>();
        List<String> objDealerNameList = new List<String>();
        List<Tier_Participation_Rate__mdt> objTierParticipationList = new List<Tier_Participation_Rate__mdt>();
        Map<String,Object> rateCardMap = new Map<String,Object>();
        // Account accountObj = [SELECT Id, Tier__c FROM Account WHERE RecordType.Name = 'Dealer'];
        // accountObj.Tier__c = 'Gold';
        // Database.update(accountObj);
        objRateCardHeaderList = [ SELECT Id,
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
                                        Portion_of_Fee_to_Cover__c,
                                        Account__r.Name,
                                        Account__r.Tier__c
                                    FROM genesis__Rate_Card_Setup_Header__c 
                                    WHERE Name = 'My Test Program 99'];
        objRateCardHeaderList[0].genesis__End_Date__c = Date.newInstance(2025, 04, 15);
        objRateCardHeaderList[0].Crop_Year__c = '2024';
        objRateCardHeaderList[0].Field_Finance_Rate__c = 9.5;
        clcommon__Floating_Rate_Index__c floatingRateIndex = [SELECT id FROM clcommon__Floating_Rate_Index__c LIMIT 1];
        objRateCardHeaderList[0].Base_Rate__c = floatingRateIndex.id;
        Database.update(objRateCardHeaderList[0], true);    
        
        objDealerNameList.add(objRateCardHeaderList[0].Account__r.Name);

        objProgramList =  [SELECT  Id, 
                                   genesis__Field_Value__c 
                                FROM genesis__Additional_Determining_Factor__c 
                                WHERE genesis__Field_Value__c = 'My Test Program 99'
                                LIMIT 1];
        objDealerList =  [SELECT Id, 
                                 genesis__Field_Value__c 
                                 FROM genesis__Additional_Determining_Factor__c 
                                 WHERE Name =: PortalConstants.DEALER_PROFILE
                                 LIMIT 1];
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
        objRateCardDetailList.add(tempRate);
        objRateCardDetailList.add(objNextRate);
        
        descriptionList.add(tempRate.Description__c);

        // rate card header 
        rateCardDetailInfoMap.put('header',objRateCardHeaderList);
        // additional determining factor for program
        rateCardDetailInfoMap.put('program',objProgramList);
        //addition determining factor for Dealer
        rateCardDetailInfoMap.put('dealer', objDealerList); 

        rateCardDetailInfoMap.put('detail',objRateCardDetailList);
        rateCardDetailInfoMap.put('dealerName',objDealerNameList);
        rateCardDetailInfoMap.put('description',descriptionList);
        rateCardDetailInfoMap.put(PortalConstants.ASSIGN_BILLING_DATE,new List<Boolean>{true});
        rateCardDetailInfoMap.put(PortalConstants.BILLING_DATE,new List<Date>{System.today()});

        objTierParticipationList = [SELECT Id,
                                            Label,
                                            DeveloperName,
                                            Start_Date__c,
                                            End_Date__c,
                                            CFA_Participation_Rate__c,
                                            Crop_Year__c
                                    FROM Tier_Participation_Rate__mdt
                                    WHERE Label =: objRateCardHeaderList[0].Account__r.Tier__c
                                    AND Crop_Year__c =: objRateCardHeaderList[0].Crop_Year__c
                                    ORDER BY Start_Date__c ];
        PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper objRateCardDateWrapper = new PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper();
        objRateCardDateWrapper.startDate = objTierParticipationList[0].Start_Date__c;
        objRateCardDateWrapper.endDate = objTierParticipationList[objTierParticipationList.size()-1].End_Date__c;
        objRateCardDateWrapper.defaultRateCard = true;
        objRateCardDateWrapper.rateCardDetailInfoMap = rateCardDetailInfoMap;

        rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objRateCardDetailList[0]));
        Test.startTest();
        System.runAs(testUser) {        
            List<genesis__Rate_Card_Setup_Detail__c> resultList = SaveRateCardDetailsHandler.updateRateCardDetail(objRateCardDateWrapper,rateCardMap,objTierParticipationList);
            System.assertEquals(resultList.size()!=null, true, 'Assertion Failed');
        }
        Test.stopTest();
       }
    /**
    * @description 
    * @author Sk Minsar | 09-05-2024 
    **/
    @isTest
    static void testcreateRateCardInMidRange(){
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String, List<Object>>();
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<String> descriptionList = new List<String>();
        List<String> objDealerNameList = new List<String>();
        List<Tier_Participation_Rate__mdt> objTierParticipationList = new List<Tier_Participation_Rate__mdt>();
        Map<String,Object> rateCardMap = new Map<String,Object>();
        objRateCardHeaderList = [ SELECT Id,
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
                                        Portion_of_Fee_to_Cover__c,
                                        Account__r.Name,
                                        Account__r.Tier__c
                                    FROM genesis__Rate_Card_Setup_Header__c 
                                    WHERE Name = 'My Test Program 99'];
        objRateCardHeaderList[0].genesis__End_Date__c = Date.newInstance(2025, 04, 15);
        objRateCardHeaderList[0].Crop_Year__c = '2025';
        objRateCardHeaderList[0].Field_Finance_Rate__c = 9.5;
        clcommon__Floating_Rate_Index__c floatingRateIndex = [SELECT id FROM clcommon__Floating_Rate_Index__c LIMIT 1];
        objRateCardHeaderList[0].Base_Rate__c = floatingRateIndex.id;
        Database.update(objRateCardHeaderList[0], true);    
        
        objDealerNameList.add(objRateCardHeaderList[0].Account__r.Name);

        objProgramList =  [SELECT  Id, 
                                   genesis__Field_Value__c 
                                FROM genesis__Additional_Determining_Factor__c 
                                WHERE genesis__Field_Value__c = 'My Test Program 99'
                                LIMIT 1];
        objDealerList =  [SELECT Id, 
                                 genesis__Field_Value__c 
                                 FROM genesis__Additional_Determining_Factor__c 
                                 WHERE Name =: PortalConstants.DEALER_PROFILE
                                 LIMIT 1];
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
        objRateCardDetailList.add(tempRate);
        objRateCardDetailList.add(objNextRate);
        
        descriptionList.add(tempRate.Description__c);

        // rate card header 
        rateCardDetailInfoMap.put('header',objRateCardHeaderList);
        // additional determining factor for program
        rateCardDetailInfoMap.put('program',objProgramList);
        //addition determining factor for Dealer
        rateCardDetailInfoMap.put('dealer', objDealerList); 

        rateCardDetailInfoMap.put('detail',objRateCardDetailList);
        rateCardDetailInfoMap.put('dealerName',objDealerNameList);
        rateCardDetailInfoMap.put('description',descriptionList);
        rateCardDetailInfoMap.put(PortalConstants.ASSIGN_BILLING_DATE,new List<Boolean>{true});
        rateCardDetailInfoMap.put(PortalConstants.BILLING_DATE,new List<Date>{System.today()});

        objTierParticipationList = [SELECT Id,
                                            Label,
                                            DeveloperName,
                                            Start_Date__c,
                                            End_Date__c,
                                            CFA_Participation_Rate__c,
                                            Crop_Year__c
                                    FROM Tier_Participation_Rate__mdt
                                    WHERE Label =: objRateCardHeaderList[0].Account__r.Tier__c
                                    AND Crop_Year__c =: objRateCardHeaderList[0].Crop_Year__c
                                    ORDER BY Start_Date__c ];
        PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper objRateCardDateWrapper = new PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper();
        objRateCardDateWrapper.startDate = objTierParticipationList[0].Start_Date__c;
        objRateCardDateWrapper.endDate = (objTierParticipationList[0].End_Date__c).addMonths(3);
        objRateCardDateWrapper.defaultRateCard = true;
        objRateCardDateWrapper.rateCardDetailInfoMap = rateCardDetailInfoMap;

        rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objRateCardDetailList[0]));
        Test.startTest();
        System.runAs(testUser) {        
            List<genesis__Rate_Card_Setup_Detail__c> resultList = SaveRateCardDetailsHandler.updateRateCardDetail(objRateCardDateWrapper,rateCardMap,objTierParticipationList);
            System.assertEquals(resultList.size()!=null, true, 'Assertion Failed');
        }
        Test.stopTest();
    }
    /**
    * @description - Test CreateRateCardInCurrentRange method
    * @author Sk Minsar | 09-05-2024 
    **/
    @isTest
    static void testCreateRateCardInCurrentRange(){

        // User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String, List<Object>>();
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<String> descriptionList = new List<String>();
        List<String> objDealerNameList = new List<String>();
        List<Tier_Participation_Rate__mdt> objTierParticipationList = new List<Tier_Participation_Rate__mdt>();
        Map<String,Object> rateCardMap = new Map<String,Object>();
        objRateCardHeaderList = [ SELECT Id,
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
                                        Portion_of_Fee_to_Cover__c,
                                        Account__r.Name,
                                        Account__r.Tier__c
                                    FROM genesis__Rate_Card_Setup_Header__c 
                                    WHERE Name = 'My Test Program 99'];
        objRateCardHeaderList[0].genesis__End_Date__c = Date.newInstance(2025, 04, 15);
        objRateCardHeaderList[0].Crop_Year__c = '2025';
        objRateCardHeaderList[0].Field_Finance_Rate__c = 9.5;
        clcommon__Floating_Rate_Index__c floatingRateIndex = [SELECT id FROM clcommon__Floating_Rate_Index__c LIMIT 1];
        objRateCardHeaderList[0].Base_Rate__c = floatingRateIndex.id;
        Database.update(objRateCardHeaderList[0], true);    
        
        objDealerNameList.add(objRateCardHeaderList[0].Account__r.Name);

        objProgramList =  [SELECT  Id, 
                                   genesis__Field_Value__c 
                                FROM genesis__Additional_Determining_Factor__c 
                                WHERE genesis__Field_Value__c = 'My Test Program 99'
                                LIMIT 1];
        objDealerList =  [SELECT Id, 
                                 genesis__Field_Value__c 
                                 FROM genesis__Additional_Determining_Factor__c 
                                 WHERE Name =: PortalConstants.DEALER_PROFILE
                                 LIMIT 1];
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
        objRateCardDetailList.add(tempRate);
        objRateCardDetailList.add(objNextRate);
        
        descriptionList.add(tempRate.Description__c);

        // rate card header 
        rateCardDetailInfoMap.put('header',objRateCardHeaderList);
        // additional determining factor for program
        rateCardDetailInfoMap.put('program',objProgramList);
        //addition determining factor for Dealer
        rateCardDetailInfoMap.put('dealer', objDealerList); 

        rateCardDetailInfoMap.put('detail',objRateCardDetailList);
        rateCardDetailInfoMap.put('dealerName',objDealerNameList);
        rateCardDetailInfoMap.put('description',descriptionList);
        rateCardDetailInfoMap.put(PortalConstants.ASSIGN_BILLING_DATE,new List<Boolean>{true});
        rateCardDetailInfoMap.put(PortalConstants.BILLING_DATE,new List<Date>{System.today()});

        objTierParticipationList = [SELECT Id,
                                            Label,
                                            DeveloperName,
                                            Start_Date__c,
                                            End_Date__c,
                                            CFA_Participation_Rate__c,
                                            Crop_Year__c
                                    FROM Tier_Participation_Rate__mdt
                                    WHERE Label =: objRateCardHeaderList[0].Account__r.Tier__c
                                    AND Crop_Year__c =: objRateCardHeaderList[0].Crop_Year__c
                                    ORDER BY Start_Date__c ];
        PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper objRateCardDateWrapper = new PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper();
        objRateCardDateWrapper.startDate = objTierParticipationList[0].Start_Date__c;
        objRateCardDateWrapper.endDate = objTierParticipationList[0].End_Date__c;
        objRateCardDateWrapper.defaultRateCard = true;
        objRateCardDateWrapper.rateCardDetailInfoMap = rateCardDetailInfoMap;

        rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objRateCardDetailList[0]));
        Test.startTest();
        System.runAs(testUser) {        
            List<genesis__Rate_Card_Setup_Detail__c> resultList = SaveRateCardDetailsHandler.updateRateCardDetail(objRateCardDateWrapper,rateCardMap,objTierParticipationList);
            System.assertEquals(resultList.size()!=null, true, 'Assertion Failed');
        }
        Test.stopTest();
    }
    /**
    * @description - Test CreateRateCardInCurrentRange method for Wrapper EndDate Not In Range
    * @author Sk Minsar | 09-05-2024 
    **/
    @isTest
    static void testCreateRateCardInCurrentRangeEndDateNotInRange(){

        // User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String, List<Object>>();
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<String> descriptionList = new List<String>();
        List<String> objDealerNameList = new List<String>();
        List<Tier_Participation_Rate__mdt> objTierParticipationList = new List<Tier_Participation_Rate__mdt>();
        Map<String,Object> rateCardMap = new Map<String,Object>();
        objRateCardHeaderList = [ SELECT Id,
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
                                        Portion_of_Fee_to_Cover__c,
                                        Account__r.Name,
                                        Account__r.Tier__c
                                    FROM genesis__Rate_Card_Setup_Header__c 
                                    WHERE Name = 'My Test Program 99'];
        objRateCardHeaderList[0].genesis__End_Date__c = Date.newInstance(2025, 04, 15);
        objRateCardHeaderList[0].Crop_Year__c = '2025';
        objRateCardHeaderList[0].Field_Finance_Rate__c = 9.5;
        clcommon__Floating_Rate_Index__c floatingRateIndex = [SELECT id FROM clcommon__Floating_Rate_Index__c LIMIT 1];
        objRateCardHeaderList[0].Base_Rate__c = floatingRateIndex.id;
        Database.update(objRateCardHeaderList[0], true);    
        
        objDealerNameList.add(objRateCardHeaderList[0].Account__r.Name);

        objProgramList =  [SELECT  Id, 
                                   genesis__Field_Value__c 
                                FROM genesis__Additional_Determining_Factor__c 
                                WHERE genesis__Field_Value__c = 'My Test Program 99'
                                LIMIT 1];
        objDealerList =  [SELECT Id, 
                                 genesis__Field_Value__c 
                                 FROM genesis__Additional_Determining_Factor__c 
                                 WHERE Name =: PortalConstants.DEALER_PROFILE
                                 LIMIT 1];
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
        objRateCardDetailList.add(tempRate);
        objRateCardDetailList.add(objNextRate);
        
        descriptionList.add(tempRate.Description__c);

        // rate card header 
        rateCardDetailInfoMap.put('header',objRateCardHeaderList);
        // additional determining factor for program
        rateCardDetailInfoMap.put('program',objProgramList);
        //addition determining factor for Dealer
        rateCardDetailInfoMap.put('dealer', objDealerList); 

        rateCardDetailInfoMap.put('detail',objRateCardDetailList);
        rateCardDetailInfoMap.put('dealerName',objDealerNameList);
        rateCardDetailInfoMap.put('description',descriptionList);
        rateCardDetailInfoMap.put(PortalConstants.ASSIGN_BILLING_DATE,new List<Boolean>{true});
        rateCardDetailInfoMap.put(PortalConstants.BILLING_DATE,new List<Date>{System.today()});

        objTierParticipationList = [SELECT Id,
                                            Label,
                                            DeveloperName,
                                            Start_Date__c,
                                            End_Date__c,
                                            CFA_Participation_Rate__c,
                                            Crop_Year__c
                                    FROM Tier_Participation_Rate__mdt
                                    WHERE Label =: objRateCardHeaderList[0].Account__r.Tier__c
                                    AND Crop_Year__c =: objRateCardHeaderList[0].Crop_Year__c
                                    ORDER BY Start_Date__c ];
        PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper objRateCardDateWrapper = new PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper();
        objRateCardDateWrapper.startDate = objTierParticipationList[0].Start_Date__c;
        objRateCardDateWrapper.endDate = (objTierParticipationList[0].End_Date__c).addDays(2);
        objRateCardDateWrapper.defaultRateCard = true;
        objRateCardDateWrapper.rateCardDetailInfoMap = rateCardDetailInfoMap;

        rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objRateCardDetailList[0]));
        Test.startTest();
        System.runAs(testUser) {        
            List<genesis__Rate_Card_Setup_Detail__c> resultList = SaveRateCardDetailsHandler.updateRateCardDetail(objRateCardDateWrapper,rateCardMap,objTierParticipationList);
            System.assertEquals(resultList.size()!=null, true, 'Assertion Failed');
        }
        Test.stopTest();
    }

    /**
    * @description - Test CreateRateCardInCurrentRange method for Wrapper Start Date Not In Range
    * @author Sk Minsar | 09-05-2024 
    **/
    @isTest
    static void testCreateRateCardInCurrentRangeStartDateNotInRange(){

        // User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String, List<Object>>();
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<String> descriptionList = new List<String>();
        List<String> objDealerNameList = new List<String>();
        List<Tier_Participation_Rate__mdt> objTierParticipationList = new List<Tier_Participation_Rate__mdt>();
        Map<String,Object> rateCardMap = new Map<String,Object>();
        objRateCardHeaderList = [ SELECT Id,
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
                                        Portion_of_Fee_to_Cover__c,
                                        Account__r.Name,
                                        Account__r.Tier__c
                                    FROM genesis__Rate_Card_Setup_Header__c 
                                    WHERE Name = 'My Test Program 99'];
        objRateCardHeaderList[0].genesis__End_Date__c = Date.newInstance(2025, 04, 15);
        objRateCardHeaderList[0].Crop_Year__c = '2025';
        objRateCardHeaderList[0].Field_Finance_Rate__c = 9.5;
        clcommon__Floating_Rate_Index__c floatingRateIndex = [SELECT id FROM clcommon__Floating_Rate_Index__c LIMIT 1];
        objRateCardHeaderList[0].Base_Rate__c = floatingRateIndex.id;
        Database.update(objRateCardHeaderList[0], true);    
        
        objDealerNameList.add(objRateCardHeaderList[0].Account__r.Name);

        objProgramList =  [SELECT  Id, 
                                   genesis__Field_Value__c 
                                FROM genesis__Additional_Determining_Factor__c 
                                WHERE genesis__Field_Value__c = 'My Test Program 99'
                                LIMIT 1];
        objDealerList =  [SELECT Id, 
                                 genesis__Field_Value__c 
                                 FROM genesis__Additional_Determining_Factor__c 
                                 WHERE Name =: PortalConstants.DEALER_PROFILE
                                 LIMIT 1];
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
        objRateCardDetailList.add(tempRate);
        objRateCardDetailList.add(objNextRate);
        
        descriptionList.add(tempRate.Description__c);

        // rate card header 
        rateCardDetailInfoMap.put('header',objRateCardHeaderList);
        // additional determining factor for program
        rateCardDetailInfoMap.put('program',objProgramList);
        //addition determining factor for Dealer
        rateCardDetailInfoMap.put('dealer', objDealerList); 

        rateCardDetailInfoMap.put('detail',objRateCardDetailList);
        rateCardDetailInfoMap.put('dealerName',objDealerNameList);
        rateCardDetailInfoMap.put('description',descriptionList);
        rateCardDetailInfoMap.put(PortalConstants.ASSIGN_BILLING_DATE,new List<Boolean>{true});
        rateCardDetailInfoMap.put(PortalConstants.BILLING_DATE,new List<Date>{System.today()});

        objTierParticipationList = [SELECT Id,
                                            Label,
                                            DeveloperName,
                                            Start_Date__c,
                                            End_Date__c,
                                            CFA_Participation_Rate__c,
                                            Crop_Year__c
                                    FROM Tier_Participation_Rate__mdt
                                    WHERE Label =: objRateCardHeaderList[0].Account__r.Tier__c
                                    AND Crop_Year__c =: objRateCardHeaderList[0].Crop_Year__c
                                    ORDER BY Start_Date__c ];
        PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper objRateCardDateWrapper = new PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper();
        objRateCardDateWrapper.startDate = (objTierParticipationList[0].Start_Date__c).addDays(-2);
        objRateCardDateWrapper.endDate = objTierParticipationList[0].End_Date__c;
        objRateCardDateWrapper.defaultRateCard = true;
        objRateCardDateWrapper.rateCardDetailInfoMap = rateCardDetailInfoMap;

        rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objRateCardDetailList[0]));
        Test.startTest();
        System.runAs(testUser) {        
            List<genesis__Rate_Card_Setup_Detail__c> resultList = SaveRateCardDetailsHandler.updateRateCardDetail(objRateCardDateWrapper,rateCardMap,objTierParticipationList);
            System.assertEquals(resultList.size()!=null, true, 'Assertion Failed');
        }
        Test.stopTest();
    }
    /**
    * @description - Test CreateRateCardInCurrentRange method for Wrapper Start Date Not In Range
    * @author Sk Minsar | 09-05-2024 
    **/
    @isTest
    static void testCreateRateCardInCurrentRangeStartAndEndDateNotInRange(){

        // User testUser = [SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'];
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String, List<Object>>();
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<String> descriptionList = new List<String>();
        List<String> objDealerNameList = new List<String>();
        List<Tier_Participation_Rate__mdt> objTierParticipationList = new List<Tier_Participation_Rate__mdt>();
        Map<String,Object> rateCardMap = new Map<String,Object>();
        objRateCardHeaderList = [ SELECT Id,
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
                                        Portion_of_Fee_to_Cover__c,
                                        Account__r.Name,
                                        Account__r.Tier__c
                                    FROM genesis__Rate_Card_Setup_Header__c 
                                    WHERE Name = 'My Test Program 99'];
        objRateCardHeaderList[0].genesis__End_Date__c = Date.newInstance(2025, 04, 15);
        objRateCardHeaderList[0].Crop_Year__c = '2025';
        objRateCardHeaderList[0].Field_Finance_Rate__c = 9.5;
        clcommon__Floating_Rate_Index__c floatingRateIndex = [SELECT id FROM clcommon__Floating_Rate_Index__c LIMIT 1];
        objRateCardHeaderList[0].Base_Rate__c = floatingRateIndex.id;
        Database.update(objRateCardHeaderList[0], true);    
        
        objDealerNameList.add(objRateCardHeaderList[0].Account__r.Name);

        objProgramList =  [SELECT  Id, 
                                   genesis__Field_Value__c 
                                FROM genesis__Additional_Determining_Factor__c 
                                WHERE genesis__Field_Value__c = 'My Test Program 99'
                                LIMIT 1];
        objDealerList =  [SELECT Id, 
                                 genesis__Field_Value__c 
                                 FROM genesis__Additional_Determining_Factor__c 
                                 WHERE Name =: PortalConstants.DEALER_PROFILE
                                 LIMIT 1];
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
        objRateCardDetailList.add(tempRate);
        objRateCardDetailList.add(objNextRate);
        
        descriptionList.add(tempRate.Description__c);

        // rate card header 
        rateCardDetailInfoMap.put('header',objRateCardHeaderList);
        // additional determining factor for program
        rateCardDetailInfoMap.put('program',objProgramList);
        //addition determining factor for Dealer
        rateCardDetailInfoMap.put('dealer', objDealerList); 

        rateCardDetailInfoMap.put('detail',objRateCardDetailList);
        rateCardDetailInfoMap.put('dealerName',objDealerNameList);
        rateCardDetailInfoMap.put('description',descriptionList);
        rateCardDetailInfoMap.put(PortalConstants.ASSIGN_BILLING_DATE,new List<Boolean>{true});
        rateCardDetailInfoMap.put(PortalConstants.BILLING_DATE,new List<Date>{System.today()});

        objTierParticipationList = [SELECT Id,
                                            Label,
                                            DeveloperName,
                                            Start_Date__c,
                                            End_Date__c,
                                            CFA_Participation_Rate__c,
                                            Crop_Year__c
                                    FROM Tier_Participation_Rate__mdt
                                    WHERE Label =: objRateCardHeaderList[0].Account__r.Tier__c
                                    AND Crop_Year__c =: objRateCardHeaderList[0].Crop_Year__c
                                    ORDER BY Start_Date__c ];
        PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper objRateCardDateWrapper = new PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper();
        objRateCardDateWrapper.startDate = objTierParticipationList[0].Start_Date__c;
        objRateCardDateWrapper.endDate = (objTierParticipationList[0].End_Date__c).addDays(-2);
        objRateCardDateWrapper.defaultRateCard = true;
        objRateCardDateWrapper.rateCardDetailInfoMap = rateCardDetailInfoMap;

        rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objRateCardDetailList[0]));
        Test.startTest();
        System.runAs(testUser) {        
            List<genesis__Rate_Card_Setup_Detail__c> resultList = SaveRateCardDetailsHandler.updateRateCardDetail(objRateCardDateWrapper,rateCardMap,objTierParticipationList);
            System.assertEquals(resultList.size()!=null, true, 'Assertion Failed');
        }
        Test.stopTest();
    }
    /**
    * @description 
    * @author Sk Minsar | 09-05-2024 
    **/
    @isTest
    static void testupdateRateCardDetailStartDateNotFound(){
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String, List<Object>>();
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<String> descriptionList = new List<String>();
        List<String> objDealerNameList = new List<String>();
        List<Tier_Participation_Rate__mdt> objTierParticipationList = new List<Tier_Participation_Rate__mdt>();
        Map<String,Object> rateCardMap = new Map<String,Object>();
        objRateCardHeaderList = [ SELECT Id,
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
                                        Portion_of_Fee_to_Cover__c,
                                        Account__r.Name,
                                        Account__r.Tier__c
                                    FROM genesis__Rate_Card_Setup_Header__c 
                                    WHERE Name = 'My Test Program 99'];
        objRateCardHeaderList[0].genesis__End_Date__c = Date.newInstance(2025, 04, 15);
        objRateCardHeaderList[0].Crop_Year__c = '2024';
        objRateCardHeaderList[0].Field_Finance_Rate__c = 9.5;
        clcommon__Floating_Rate_Index__c floatingRateIndex = [SELECT id FROM clcommon__Floating_Rate_Index__c LIMIT 1];
        objRateCardHeaderList[0].Base_Rate__c = floatingRateIndex.id;
        Database.update(objRateCardHeaderList[0], true);    
        
        objDealerNameList.add(objRateCardHeaderList[0].Account__r.Name);

        objProgramList =  [SELECT  Id, 
                                   genesis__Field_Value__c 
                                FROM genesis__Additional_Determining_Factor__c 
                                WHERE genesis__Field_Value__c = 'My Test Program 99'
                                LIMIT 1];
        objDealerList =  [SELECT Id, 
                                 genesis__Field_Value__c 
                                 FROM genesis__Additional_Determining_Factor__c 
                                 WHERE Name =: PortalConstants.DEALER_PROFILE
                                 LIMIT 1];
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
        objRateCardDetailList.add(tempRate);
        objRateCardDetailList.add(objNextRate);
        
        descriptionList.add(tempRate.Description__c);

        // rate card header 
        rateCardDetailInfoMap.put('header',objRateCardHeaderList);
        // additional determining factor for program
        rateCardDetailInfoMap.put('program',objProgramList);
        //addition determining factor for Dealer
        rateCardDetailInfoMap.put('dealer', objDealerList); 

        rateCardDetailInfoMap.put('detail',objRateCardDetailList);
        rateCardDetailInfoMap.put('dealerName',objDealerNameList);
        rateCardDetailInfoMap.put('description',descriptionList);
        rateCardDetailInfoMap.put(PortalConstants.ASSIGN_BILLING_DATE,new List<Boolean>{true});
        rateCardDetailInfoMap.put(PortalConstants.BILLING_DATE,new List<Date>{System.today()});

        objTierParticipationList = [SELECT Id,
                                            Label,
                                            DeveloperName,
                                            Start_Date__c,
                                            End_Date__c,
                                            CFA_Participation_Rate__c,
                                            Crop_Year__c
                                    FROM Tier_Participation_Rate__mdt
                                    WHERE Label =: objRateCardHeaderList[0].Account__r.Tier__c
                                    AND Crop_Year__c =: objRateCardHeaderList[0].Crop_Year__c
                                    ORDER BY Start_Date__c ];
        PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper objRateCardDateWrapper = new PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper();
        objRateCardDateWrapper.startDate = (objTierParticipationList[0].Start_Date__c).addMonths(-3);
        objRateCardDateWrapper.endDate = objTierParticipationList[objTierParticipationList.size()-1].End_Date__c;
        objRateCardDateWrapper.defaultRateCard = true;
        objRateCardDateWrapper.rateCardDetailInfoMap = rateCardDetailInfoMap;

        rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objRateCardDetailList[0]));
        Test.startTest();
        System.runAs(testUser) {        
            List<genesis__Rate_Card_Setup_Detail__c> resultList = SaveRateCardDetailsHandler.updateRateCardDetail(objRateCardDateWrapper,rateCardMap,objTierParticipationList);
            System.assertEquals(resultList.size()!=null, true, 'Assertion Failed');
        }
        Test.stopTest();
    }
    /**
    * @description 
    * @author Sk Minsar | 09-05-2024 
    **/
    @isTest
    static void testupdateRateCardDetailEndDateNotFound(){
        User testUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String, List<Object>>();
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList = new List<genesis__Rate_Card_Setup_Header__c>();
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<String> descriptionList = new List<String>();
        List<String> objDealerNameList = new List<String>();
        List<Tier_Participation_Rate__mdt> objTierParticipationList = new List<Tier_Participation_Rate__mdt>();
        Map<String,Object> rateCardMap = new Map<String,Object>();
        objRateCardHeaderList = [ SELECT Id,
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
                                        Portion_of_Fee_to_Cover__c,
                                        Account__r.Name,
                                        Account__r.Tier__c
                                    FROM genesis__Rate_Card_Setup_Header__c 
                                    WHERE Name = 'My Test Program 99'];
        objRateCardHeaderList[0].genesis__End_Date__c = Date.newInstance(2025, 04, 15);
        objRateCardHeaderList[0].Crop_Year__c = '2024';
        objRateCardHeaderList[0].Field_Finance_Rate__c = 9.5;
        clcommon__Floating_Rate_Index__c floatingRateIndex = [SELECT id FROM clcommon__Floating_Rate_Index__c LIMIT 1];
        objRateCardHeaderList[0].Base_Rate__c = floatingRateIndex.id;
        Database.update(objRateCardHeaderList[0], true);    
        
        objDealerNameList.add(objRateCardHeaderList[0].Account__r.Name);

        objProgramList =  [SELECT  Id, 
                                   genesis__Field_Value__c 
                                FROM genesis__Additional_Determining_Factor__c 
                                WHERE genesis__Field_Value__c = 'My Test Program 99'
                                LIMIT 1];
        objDealerList =  [SELECT Id, 
                                 genesis__Field_Value__c 
                                 FROM genesis__Additional_Determining_Factor__c 
                                 WHERE Name =: PortalConstants.DEALER_PROFILE
                                 LIMIT 1];
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
        objRateCardDetailList.add(tempRate);
        objRateCardDetailList.add(objNextRate);
        
        descriptionList.add(tempRate.Description__c);

        // rate card header 
        rateCardDetailInfoMap.put('header',objRateCardHeaderList);
        // additional determining factor for program
        rateCardDetailInfoMap.put('program',objProgramList);
        //addition determining factor for Dealer
        rateCardDetailInfoMap.put('dealer', objDealerList); 

        rateCardDetailInfoMap.put('detail',objRateCardDetailList);
        rateCardDetailInfoMap.put('dealerName',objDealerNameList);
        rateCardDetailInfoMap.put('description',descriptionList);
        rateCardDetailInfoMap.put(PortalConstants.ASSIGN_BILLING_DATE,new List<Boolean>{true});
        rateCardDetailInfoMap.put(PortalConstants.BILLING_DATE,new List<Date>{System.today()});

        objTierParticipationList = [SELECT Id,
                                            Label,
                                            DeveloperName,
                                            Start_Date__c,
                                            End_Date__c,
                                            CFA_Participation_Rate__c,
                                            Crop_Year__c
                                    FROM Tier_Participation_Rate__mdt
                                    WHERE Label =: objRateCardHeaderList[0].Account__r.Tier__c
                                    AND Crop_Year__c =: objRateCardHeaderList[0].Crop_Year__c
                                    ORDER BY Start_Date__c ];
        PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper objRateCardDateWrapper = new PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper();
        objRateCardDateWrapper.startDate = objTierParticipationList[0].Start_Date__c;
        objRateCardDateWrapper.endDate = (objTierParticipationList[objTierParticipationList.size()-1].End_Date__c).addMonths(3);
        objRateCardDateWrapper.defaultRateCard = true;
        objRateCardDateWrapper.rateCardDetailInfoMap = rateCardDetailInfoMap;

        rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objRateCardDetailList[0]));
        Test.startTest();
        System.runAs(testUser) {        
            List<genesis__Rate_Card_Setup_Detail__c> resultList = SaveRateCardDetailsHandler.updateRateCardDetail(objRateCardDateWrapper,rateCardMap,objTierParticipationList);
            System.assertEquals(resultList.size()!=null, true, 'Assertion Failed');
        }
        Test.stopTest();
    }
}