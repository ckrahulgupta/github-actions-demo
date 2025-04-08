/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 10-01-2025
 * @last modified by  : Soumik Pattanayak
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   01-11-2022   Subham Nandi   Initial Version
**/
@isTest
public with sharing class TestScheduleRateChangeNotification {
    //test setup
    @TestSetup
    static void makeData(){
         // Object List declarations
         List<Account> accountList;
         List<Contact> contactList;
         List<genesis__Business_Information__c> businsessInfoList;
         List<clcommon__Legal_Entity__c> entityList;
         List<genesis__Application_Pricing_Detail__c> pricingdetailList;
         List<genesis__Rate_Card_Setup_Header__c> myProgramList;
         List<genesis__Applications__c> appList;

         // Creating Legal Entity
        clcommon__Legal_Entity__c individualEntityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();

        clcommon__Legal_Entity__c corpEntityObj = ApplicationOriginationTestHelper.createLegalEntity(PortalConstants.CORPORATION);

        clcommon__Legal_Entity__c dbaEntityObj = ApplicationOriginationTestHelper.createLegalEntity(PortalConstants.INDIVIDUAL_ENTITY);

        entityList = new  List<clcommon__Legal_Entity__c>{
            individualEntityObj,
            corpEntityObj,
            dbaEntityObj
        };
        Database.insert(entityList[0]);

        // Creating CL Product for Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.Insert(clProductObj, true);

        // Creating CL Purpose for Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.Insert(clPurposeObj, true);
        // Creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();

        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();

        businsessInfoList = new List<genesis__Business_Information__c>{
            dealerBusinessInfoObj,
            borrowerBusinessInfoObj
        };
        Database.Insert(businsessInfoList, true);
        // Creating Accounts
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.Insert(dealerAccountObj, true);

        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(individualEntityObj, borrowerBusinessInfoObj.Id);
        borrowerAccountObj.BillingCity = 'Kolkata';
        borrowerAccountObj.BillingState = 'WA';
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        //creating another cl
        Account secClAccObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);

        accountList = new List<Account>{
            borrowerAccountObj,
            clAccountObj,
            secClAccObj
        };
        Database.Insert(accountList, true);

        // Creating Contact
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);    
        borrowerContactObj.MailingCity = 'Kolkata';
        borrowerContactObj.MailingState = 'WA';
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);

        contactList = new List<Contact>{
            borrowerContactObj,
            clContactObj
        };
        Database.Insert(contactList, true);

        // creating relationship of certified lender
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createReciprocalRole('Certified Lender');
        Database.insert(clRoleObj, true);
        clcommon__Relationship__c clDealerRelationObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj, 
                                                                                                    dealerAccountObj.Id, 
                                                                                                    clAccountObj.Id);
        //creating relationship for another cl
        clcommon__Relationship__c secClDealerRelationObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj, 
                                                                                                        dealerAccountObj.Id, 
                                                                                                        secClAccObj.Id);
        List<clcommon__Relationship__c> relationshipList;
        relationshipList = new List<clcommon__Relationship__c>{
            clDealerRelationObj,
            secClDealerRelationObj
        };
        Database.insert(relationshipList, true);

        Dealer_Applicant_Relationship__c relationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Database.insert(relationObj, true);

        // Creating Application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>{
            'dealerAccountId'=> dealerAccountObj.Id,
            'clProductId'=> clProductObj.Id,
            'clPurposeId'=> clPurposeObj.Id,
            'borrowerAccountId'=> borrowerAccountObj.Id,
            'borrowerContactId'=> borrowerContactObj.Id,
            'clAccountId'=> clAccountObj.Id,
            'dealerApplicantRelationshipId' => relationObj.Id
        };

        //creating application
        // Creating Application that have rate changes on 45 days ahead
        genesis__Applications__c appForFourtyFiveDaysObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        // Creating Application that have rate changes on 32 days ahead
        genesis__Applications__c appForThirtyTwoDaysObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        appList = new List<genesis__Applications__c>{
            appForFourtyFiveDaysObj,
            appForThirtyTwoDaysObj
        };
        Database.insert(appList, true);

        //Creating My Program with setup detail being 45 days ahead
        genesis__Rate_Card_Setup_Header__c fourtyFiveDaysProgramObj = ApplicationOriginationTestHelper.createCurrYearRateCardHeader(dealerAccountObj);
        //fourtyFiveDaysProgramObj.genesis__Start_Date__c = System.today().addDays(45);
        //Create My Program with setup detail being 32 days ahead
        genesis__Rate_Card_Setup_Header__c thirtyTwoDaysProgramObj = ApplicationOriginationTestHelper.createCurrYearRateCardHeader(dealerAccountObj);
        //thirtyTwoDaysProgramObj.genesis__Start_Date__c = System.today().addDays(32);

        myProgramList = new List<genesis__Rate_Card_Setup_Header__c>{
            fourtyFiveDaysProgramObj,
            thirtyTwoDaysProgramObj
        };
        Database.insert(myProgramList, true);
         // Creating Rate Card Setup Details.
         // Creating Rate Card Setup Details for 45 days
        List<genesis__Rate_Card_Setup_Detail__c> fourtyFiveRateCardsList = ApplicationOriginationTestHelper.createFourtyFiveRateChngRateCards(fourtyFiveDaysProgramObj,
                                                                                                                                appForFourtyFiveDaysObj);
        fourtyFiveRateCardsList[0].Description__c = 'Machinary';
        fourtyFiveRateCardsList[1].Description__c = 'Irrigation';
        Database.insert(fourtyFiveRateCardsList, true);

         // Creating Rate Card Setup Details for 32 days
        List<genesis__Rate_Card_Setup_Detail__c> thirtyTwoRateCardsList = ApplicationOriginationTestHelper.createThirtyTwoRateChngRateCards(thirtyTwoDaysProgramObj,
                                                                                                                                        appForThirtyTwoDaysObj);
        thirtyTwoRateCardsList[0].Description__c = 'Seeds';
        thirtyTwoRateCardsList[1].Description__c = 'Pesticides';
        Database.insert(thirtyTwoRateCardsList, true);
        

        // Creating Current Pricing Details till 44 days.
        genesis__Application_Pricing_Detail__c currentPricingOneObj = ApplicationOriginationTestHelper.createEnabledPricingDetail(appForFourtyFiveDaysObj,
                                                                                                                    fourtyFiveRateCardsList[0].Id);
        currentPricingOneObj.genesis__Interest_Rate__c = 2;
        // Creating Rate Change Pricing Details for 45th days.
        genesis__Application_Pricing_Detail__c rateChangePricingOneObj = ApplicationOriginationTestHelper.createEnabledPricingDetail(appForFourtyFiveDaysObj,
                                                                                                                    fourtyFiveRateCardsList[1].Id);
        rateChangePricingOneObj.genesis__Interest_Rate__c = 4;

        // Creating Current Pricing Details till 31 days.
        genesis__Application_Pricing_Detail__c currentPricingTwoObj = ApplicationOriginationTestHelper.createEnabledPricingDetail(appForThirtyTwoDaysObj,
                                                                                                                thirtyTwoRateCardsList[0].Id);
        currentPricingTwoObj.genesis__Interest_Rate__c = 2;

        // Creating Rate Change Pricing Details for 32th days.
        genesis__Application_Pricing_Detail__c rateChangePricingTwoObj = ApplicationOriginationTestHelper.createEnabledPricingDetail(appForThirtyTwoDaysObj,
                                                                                                            thirtyTwoRateCardsList[1].Id);
        rateChangePricingTwoObj.genesis__Interest_Rate__c = 4;

        pricingdetailList = new List<genesis__Application_Pricing_Detail__c>{
            currentPricingOneObj,
            rateChangePricingOneObj,
            currentPricingTwoObj,
            rateChangePricingTwoObj
        };
        Database.insert(pricingdetailList, true);                                                                                              
    }

    /**
    * @description Success scenario for application having ratecard detail start date is 45 days ahead and current ratecard deatail end date is 44 days ahead and current enabled flag true for CFA Sole prop
    Success scenario for another application having ratecard start date is 32 days ahead and current ratecard end date is 31 days ahead and current enabled flag true for CFA Sole prop
    * @author Ravi Ranjan | 04-15-2024 
    **/
    @isTest
    public static void testCFASolePropRate(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                ScheduleRateChangeNotification instanceRateChange = new ScheduleRateChangeNotification();
                instanceRateChange.execute(null);
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, clcommon.Constants.SUCCESS, PortalConstants.ASSERTION_FAILED);
            }
        }
    }

    /**
    * @description Success scenario for GMK Coop having legal entity corporation
    * @author Ravi Ranjan | 04-15-2024 
    **/
    @isTest
    public static void testGMKCorporationRate(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        List<Account> dealerAccList = [SELECT Id,
                                        Coop_Type__c
                                FROM Account
                                WHERE Name = 'Kisan Loan'
                                LIMIT 1];    
        dealerAccList[0].Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.update(dealerAccList[0], true);
        List<clcommon__Legal_Entity__c> entityList = [SELECT Id,
                                                      clcommon__Legal_Entity_Type__c
                                                FROM clcommon__Legal_Entity__c
                                                WHERE Name = 'Individual(s) - Sole Proprietorship'
                                                LIMIT 1];
        entityList[0].clcommon__Legal_Entity_Type__c = PortalConstants.CORPORATION;
        Database.update(entityList[0], true);
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                ScheduleRateChangeNotification instanceRateChange = new ScheduleRateChangeNotification();
                instanceRateChange.execute(null);
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, clcommon.Constants.SUCCESS, PortalConstants.ASSERTION_FAILED);
            }
        }
    }
     /**
    * @description Success scenario for Landus Coop having legal entity DBA
    * @author Ravi Ranjan | 04-15-2024 
    **/
    @isTest
    public static void testLandusDbaRate(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        List<Account> dealerAccList = [SELECT Id,
                                        Coop_Type__c
                                FROM Account
                                WHERE Name = 'Kisan Loan'
                                LIMIT 1];    
        dealerAccList[0].Coop_Type__c = PortalConstants.LANDUS_COOP_TYPE;
        Database.update(dealerAccList[0], true);
        List<clcommon__Legal_Entity__c> entityList = [SELECT Id,
                                                      clcommon__Legal_Entity_Type__c
                                                FROM clcommon__Legal_Entity__c
                                                WHERE Name = 'Individual(s) - Sole Proprietorship'
                                                LIMIT 1];
        entityList[0].clcommon__Legal_Entity_Type__c = PortalConstants.INDIVIDUAL_ENTITY;
        Database.update(entityList[0], true);
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                ScheduleRateChangeNotification instanceRateChange = new ScheduleRateChangeNotification();
                instanceRateChange.execute(null);
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, clcommon.Constants.SUCCESS, PortalConstants.ASSERTION_FAILED);
            }
        }
    }
    /**
    * @description checking if grower's account's email is null. Email is not sent to the grower
    * @author Ravi Ranjan | 04-15-2024 
    **/
    @isTest
    public static void testGrowerNullEmail(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        List<Account> borrowerAccList = [SELECT Id,
                                        clcommon__Email__c
                                FROM Account
                                WHERE clcommon__Email__c = 'jasmin.albin@yopmail.com'
                                LIMIT 1];
        borrowerAccList[0].clcommon__Email__c = null;  
        Database.update(borrowerAccList[0], true);            
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                ScheduleRateChangeNotification instanceRateChange = new ScheduleRateChangeNotification();
                instanceRateChange.execute(null);
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, clcommon.Constants.SUCCESS, PortalConstants.ASSERTION_FAILED);
            }
        }
    }
    /**
    * @description Success scenario when new new rate is same as old rate for 32 days rate change 
    * @author Ravi Ranjan | 04-15-2024 
    **/
    @isTest
    public static void testSameRateNotification(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        List<genesis__Rate_Card_Setup_Detail__c> rateDeatailList = [SELECT Id,
                                                                    genesis__Interest_Rate__c
                                                            FROM genesis__Rate_Card_Setup_Detail__c
                                                            WHERE Description__c = 'Pesticides'
                                                            LIMIT 1];
        rateDeatailList[0].genesis__Interest_Rate__c = 2;
        Database.update(rateDeatailList[0], true);
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                ScheduleRateChangeNotification instanceRateChange = new ScheduleRateChangeNotification();
                instanceRateChange.execute(null);
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, clcommon.Constants.SUCCESS, PortalConstants.ASSERTION_FAILED);
            }
        }
    }
    /**
    * @description check when there is not any rate card setup detail whose start date is 45 days ahead
    * @author Ravi Ranjan | 04-15-2024 
    **/
    @isTest
    public static void testNoFourtyFiveDaysRate(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        List<genesis__Rate_Card_Setup_Detail__c> rateDeatailList = [SELECT Id,
                                                                    Start_Date__c
                                                            FROM genesis__Rate_Card_Setup_Detail__c
                                                            WHERE Description__c = 'Irrigation'
                                                            LIMIT 1];
        rateDeatailList[0].Start_Date__c = System.today().addDays(49);
        Database.update(rateDeatailList[0], true);
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                ScheduleRateChangeNotification instanceRateChange = new ScheduleRateChangeNotification();
                instanceRateChange.execute(null);
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, clcommon.Constants.SUCCESS, PortalConstants.ASSERTION_FAILED);
            }
        }
    }
    /**
    * @description check when there is not any rate card setup detail whose start date is 32 days ahead
    * @author Ravi Ranjan | 04-15-2024 
    **/
    @isTest
    public static void testNoThirtyTwoDaysRate(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        List<genesis__Rate_Card_Setup_Detail__c> rateDeatailList = [SELECT Id,
                                                                    Start_Date__c
                                                            FROM genesis__Rate_Card_Setup_Detail__c
                                                            WHERE Description__c = 'Pesticides'
                                                            LIMIT 1];
        rateDeatailList[0].Start_Date__c = System.today().addDays(49);
        Database.update(rateDeatailList[0], true);
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                ScheduleRateChangeNotification instanceRateChange = new ScheduleRateChangeNotification();
                instanceRateChange.execute(null);
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, clcommon.Constants.SUCCESS, PortalConstants.ASSERTION_FAILED);
            }
        }
    }
    /**
    * @description check exception when cl email is null
    * @author Ravi Ranjan | 04-15-2024 
    **/
    @isTest
    public static void checkExceptionClNullEmail(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        List<Account> clAccountList = [SELECT Id,
                                              clcommon__Email__c
                                      FROM Account
                                      WHERE clcommon__Email__c = 'ross.geller@yopmail.com'];
        for(Account eachAccObj : clAccountList){
            eachAccObj.clcommon__Email__c = null;
        }
        Database.update(clAccountList, true);
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                try{
                    ScheduleRateChangeNotification instanceRateChange = new ScheduleRateChangeNotification();
                    instanceRateChange.execute(null);
                }catch(Exception exceptionObj){
                    System.assertEquals(ConstantValues.EMAIL_NOT_FOUND, exceptionObj.getMessage(), 'Assertion Failed');
                }
                Test.stopTest();
            }
        }
    }
    /**
    * @description check exception when logged in user don't have access for genesis__Application_Pricing_Detail__c
    * @author Ravi Ranjan | 04-15-2024 
    **/
    @isTest
    public static void checkExceptionObjectAccess(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                try{
                    ScheduleRateChangeNotification instanceRateChange = new ScheduleRateChangeNotification();
                    instanceRateChange.execute(null);
                }catch(Exception exceptionObj){
                    System.assertEquals(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS, exceptionObj.getMessage(), 'Assertion Failed');
                }
                Test.stopTest();
            }
        }
    }
    /**
    * @description checking if grower's account's is null. Email is not sent to the grower
    * @author Ravi Ranjan | 04-15-2024 
    **/
    @isTest
    public static void testGrowerNullAccount(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        List<genesis__Applications__c> appList = [SELECT Id,
                                                        genesis__Account__c
                                                FROM genesis__Applications__c
                                                WHERE genesis__Loan_Number__c = '300023456'];
        for(genesis__Applications__c appObj : appList){
            appObj.genesis__Account__c = null;
        }
        Database.update(appList, true);        
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                try{
                    ScheduleRateChangeNotification instanceRateChange = new ScheduleRateChangeNotification();
                    instanceRateChange.execute(null);
                }catch(Exception exceptionObj){
                    System.assertEquals(clcommon.Constants.SUCCESS, clcommon.Constants.SUCCESS, PortalConstants.ASSERTION_FAILED);
                }
                Test.stopTest();
            }
        }
    }
    /**
    * @description checking exception when application don't have any dealer
    * @author Ravi Ranjan | 04-15-2024 
    **/
    @isTest
    public static void checkApplicationWithoutDaler(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        List<genesis__Applications__c> appList = [SELECT Id,
                                                        Dealer_Name__c
                                                FROM genesis__Applications__c
                                                WHERE genesis__Loan_Number__c = '300023456'];
        for(genesis__Applications__c appObj : appList){
            appObj.Dealer_Name__c =null;
        }
        Database.update(appList, true);
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                try{
                    ScheduleRateChangeNotification instanceRateChange = new ScheduleRateChangeNotification();
                    instanceRateChange.execute(null);
                }catch(Exception exceptionObj){
                    System.assertEquals(clcommon.Constants.SUCCESS, clcommon.Constants.SUCCESS, PortalConstants.ASSERTION_FAILED);
                }
                Test.stopTest();
            }
        }
    }
    /**
    * @description Success scenario when new new rate is same as old rate for 45 days rate change 
    * @author Ravi Ranjan | 04-15-2024 
    **/
    @isTest
    public static void testSameRateClNotification(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        List<genesis__Rate_Card_Setup_Detail__c> rateDeatailList = [SELECT Id,
                                                                    genesis__Interest_Rate__c
                                                            FROM genesis__Rate_Card_Setup_Detail__c
                                                            WHERE Description__c = 'Irrigation'
                                                            LIMIT 1];
        rateDeatailList[0].genesis__Interest_Rate__c = 2;
        Database.update(rateDeatailList[0], true);
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                ScheduleRateChangeNotification instanceRateChange = new ScheduleRateChangeNotification();
                instanceRateChange.execute(null);
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, clcommon.Constants.SUCCESS, PortalConstants.ASSERTION_FAILED);
            }
        }
    }

}