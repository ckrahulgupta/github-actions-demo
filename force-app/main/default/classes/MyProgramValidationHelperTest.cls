/**
 * @description       : Test Class for MyProgramValidationHelper
 * @author            : Pritam Roy
 * @group             : 
 * @last modified on  : 01-24-2025
**/
@isTest
private class MyProgramValidationHelperTest { 
    /**
    * @description : This method prepares data for test class
    * @author Ayan Khanra | 01-14-2025 
    **/
    @TestSetup
    static void setup(){
        //Creating Product
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createLoanProduct();
        Database.insert(clProductObj, true);
        //Creating Business Information
        genesis__Business_Information__c businessInfoDealerObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoDealerObj, true);
        //Creating the dealer account
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoDealerObj.Id);
        Database.insert(dealerAccountObj, true);
        //Creating the CL Account
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInfoDealerObj.Id,dealerAccountObj.id);
        //Creating DBA Account
        Account dbaAccountObj = ApplicationOriginationTestHelper.createNewDBAccount(businessInfoDealerObj);
        Database.insert(new List<Account>{dbaAccountObj,clAccountObj}, true);
        //Creating the CL Contact
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj,true);
        //Creating a test user
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        Database.insert(clUserObj,true);
        //Creating Rate Card Setup Header
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerAccountObj);
        Database.insert(rateCardHeaderObj,true);
        //Creating Product Rate Card Association
        genesis__Product_Rate_Card_Association__c rateCardAssociationObj = ApplicationOriginationTestHelper.createRateToProductAssociation(clProductObj,rateCardHeaderObj);
        Database.insert(rateCardAssociationObj, true);
        //Additional Determing Factor for Program
        genesis__Additional_Determining_Factor__c additionalFactorObj = ApplicationOriginationTestHelper.createAdditionalFactorForProgram(rateCardHeaderObj);
        Database.insert(additionalFactorObj, true);
        //Additional Factor for Dealer
        genesis__Additional_Determining_Factor__c additionalFactorDealerObj = ApplicationOriginationTestHelper.createAdditionalFactorForDealer(rateCardHeaderObj);
        Database.insert(additionalFactorDealerObj, true);
        //Creating Rate Card Setup Detail
        genesis__Rate_Card_Setup_Detail__c rateCardDetailObj = ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        Database.insert(rateCardDetailObj, true);
        //Creating Application with Flex Rate
        genesis__Applications__c applicationFlexObj = ApplicationOriginationTestHelper.createApplicationForFlex(clProductObj,dbaAccountObj);
        Database.insert(applicationFlexObj, true);
    }

    /**
    * @description : This Test method validates validateStringNullCheck() function, taking null value as input  and returns empty string 
    * @author Suraj Kumar | 10-04-2024 
    **/
    @isTest 
    private static void testValidateStringNullCheckForNullValue(){ 
        String emptyValue = null;
        System.runAs(getSystemAdmin()) {
            Test.startTest();
            String emptyStringValue = MyProgramValidationHelper.validateStringNullCheck(emptyValue);
            System.assertEquals('', emptyStringValue,'Expected empty string for null input');
            Test.stopTest();
        }
    }

    /**
    * @description : This Test method validates validateStringNullCheck() function, returning string value of input
    * @author Ayan Khanra | 01-14-2025 
    **/
    @isTest 
    private static void testValidateStringNullCheckForValidInput(){ 
        String parameter = 'test';
        System.runAs(getSystemAdmin()) {
            Test.startTest();
            String returnValue = MyProgramValidationHelper.validateStringNullCheck(parameter);
            System.assertEquals('test',returnValue,'Expected the string value of input to be returned');
            Test.stopTest();
        }
    }
    
    /**
    * @description : This test method gives exception for affirmative vlaue('Yes') and the object passsed into function is null
    * @author Ayan Khanra | 01-14-2025 
    **/
    @isTest 
    private static void testCheckAffirmativeException(){
        String affirmative = 'Yes';
        String dealerParticipation = null;
        Boolean flag = false;
        System.runAs(getSystemAdmin()) {
            Test.startTest();
            try {
                MyProgramValidationHelper.checkAffirmative(affirmative,dealerParticipation,'Exception occured');
            } catch (CustomException exceptionObj) {
                flag = true;
                System.assertEquals('Exception occured', exceptionObj.getMessage(),'Exception Message is not same'); 
            }
            System.assertEquals(true,flag,'Exception not occured for null value passed to function');  
            Test.stopTest();
        }
    }

    /**
    * @description : This test method tests for no Exception occurance for affirmative value and not null value of the object that is comparable
    * @author Ayan Khanra | 01-14-2025 
    **/
    @isTest 
    private static void testCheckAffirmativeNoException(){
        String affirmative = 'Yes';
        String dealerParticipation = '200';
        Boolean flag = false;
        System.runAs(getSystemAdmin()) {
            Test.startTest();
            try {
                MyProgramValidationHelper.checkAffirmative(affirmative,dealerParticipation,'Exception occured');
            } catch (CustomException exceptionObj) {
                flag = true;
            }
            System.assertEquals(false,flag,'Exception occured although valid parameter given in function');  
            Test.stopTest();
        }
    }

    /**
    * @description : This test method runs succesfully for valid description and setup detail record passed to the function parameter
    * @author Ayan Khanra | 01-14-2025 
    **/
    @isTest 
    private static void testCheckDescriptionNoException(){
        String description = 'Seeding month trunch';
        Boolean flag = false;
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = getSetUpDetail();
        System.runAs(getSystemAdmin()) {
            Test.startTest();
            try {
                MyProgramValidationHelper.checkDescription(description, rateCardDetailList);
            }catch (CustomException exceptionObj) {
                flag = true;
            }
            System.assertEquals(false,flag,'Exception ocuured');
            Test.stopTest();
        }
    }

    /**
    * @description : This Test method gives exception for empty description and set up detail record paeed to the function parameter
    * @author Suraj Kumar | 10-04-2024 
    **/
    @isTest 
    private static void testDescriptionException(){
        String description = '';
        Boolean flag = false;
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = getSetUpDetail();
        System.runAs(getSystemAdmin()) {
            Test.startTest();
            try{
                MyProgramValidationHelper.checkDescription(description, rateCardDetailList);
            }catch(Exception exceptionObj){
                flag = true;
                System.assertEquals(PortalConstants.DESCRIPTION_ERROR, exceptionObj.getMessage(),'Exception message is not same');
            }
            Test.stopTest();
            System.assertEquals(true, flag,'Exception not ocured although empty string passed as description');
        }
    }

     
    /**
    * @description : This method tests the returned value from function is empty string for null value passed to the function
    * @author Ayan Khanra | 01-22-2025 
    **/
    @isTest 
    private static void testCheckNullListForNullValue(){
        System.runAs(getSystemAdmin()){
            Test.startTest();
            String emptyStringValue = MyProgramValidationHelper.checkNullList(null);
            System.assertEquals('',emptyStringValue,'Expected empty string for null list input');
            Test.stopTest();
        }
    }

    /**
    * @description : This method tests the return string value of the first element of list
    * @author Ayan Khanra | 01-22-2025 
    **/
    @isTest 
    private static void testCheckNullListForValidListValue(){
        List<Object> stringList = new List<Object>{'1','2','3','4'};
        System.runAs(getSystemAdmin()){
            Test.startTest();
            String firstIndexValue = MyProgramValidationHelper.checkNullList(stringList);
            System.assertEquals('1',firstIndexValue,'Expected first element of the list to be returned');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method takes flexrate values in parameter, create rate card set up header with those values and return the Set up header
    * @author Suraj Kumar | 10-04-2024 
    **/
    @isTest
    private static void testFlexRateValuesSuccess(){
        Map<String, Object> flexRateProgramMap = new Map<String, Object>();
        Map<String,Object> requestMap = new Map<String,Object>();
        List<genesis__Applications__c> applicationList = [SELECT Id 
                                                            FROM genesis__Applications__c 
                                                            WHERE genesis__Loan_Amount__c = 7685 
                                                            AND genesis__Interest_Rate__c = 1.45 
                                                            LIMIT 1];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = [SELECT Id,
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
                                                                        WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account' LIMIT 1];
        List<genesis__Rate_Card_Setup_Header__c> rateCardHeaderList = [SELECT 
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
        rateCardDetailList[0].End_Date__c = rateCardHeaderList[0].genesis__End_Date__c;
        String rateCard = Json.serialize(rateCardHeaderList[0]);
        String subString = rateCard.substringBetween('sobjects/genesis__Rate_Card_Setup_Header__c/', '"},"Name":"');
        String finalString = rateCard.replace(subString,'new_record_id');
        genesis__Rate_Card_Setup_Header__c rateCardObj = (genesis__Rate_Card_Setup_Header__c) Json.deserialize(finalString, genesis__Rate_Card_Setup_Header__c.class);
        requestMap.put('flexRateProgram', rateCardObj);
        flexRateProgramMap = (Map<String, Object>) Json.deserializeUntyped(Json.serialize(requestMap.get('flexRateProgram')));
        Database.update(rateCardDetailList[0]);
        System.runAs(getSystemAdmin()) {
            Test.startTest();
            genesis__Rate_Card_Setup_Header__c rateCardSetUpHeaderObj = MyProgramValidationHelper.validateFlexRateHeader(applicationList[0].id,flexRateProgramMap);
            System.assertEquals(flexRateProgramMap != null,true,'something went wrong');
            System.assertEquals(rateCardHeaderList[0].Crop_Year__c , rateCardSetUpHeaderObj.Crop_Year__c,'Crop year not matched');
            System.assertEquals(rateCardHeaderList[0].Closing_Fee__c, rateCardSetUpHeaderObj.Closing_Fee__c, 'Closing fee value not matched');
            Test.stopTest();
        }
    }

    /**
    * @description : This test function gives exception for past billing date
    * @author Suraj Kumar | 10-04-2024 
    **/
    @isTest 
    private static void testPastBillingException(){
        Boolean flag = false;
        System.runAs(getSystemAdmin()) {
            Test.startTest();
            try{
                MyProgramValidationHelper.validateBillingDate(System.today().addDays(-5),System.today().addDays(90));
            }catch(Exception exceptionObj){
                flag = true;
                System.assertEquals(PortalConstants.BILLING_DATE_TODAYS_DATE_CHECK, exceptionObj.getMessage(),'Exception message is not same');
            }
            System.assertEquals(true, flag,'Exception not occured for past billing date');
            Test.stopTest();
        }
    }

    /**
    * @description : This test function give exception for billing date greater than maturity date
    * @author Suraj Kumar | 10-04-2024 
    **/
    @isTest 
    private static void testBillingDateGreaterThanMaturityDateException(){
        Boolean flag = false;
        System.runAs(getSystemAdmin()) {
            Test.startTest();
            try{
                MyProgramValidationHelper.validateBillingDate(System.today().addDays(60),System.today().addDays(5));
            }catch(Exception exceptionObj){
                flag = true;
                System.assertEquals(PortalConstants.BILLING_DATE_MATURITY_DATE_CHECK, exceptionObj.getMessage(),'Exception message is not same');
            }
            System.assertEquals(true, flag,'Exception not occured for billing date greater than maturity date');
            Test.stopTest();
        }
    }
    
    /**
    * @description : This test method gives exception fot last billing day of month
    * @author Ayan Khanra | 01-14-2025 
    **/
    @isTest 
    private static void testLastDayOfMonthBillingDateNoException(){
        Boolean flag = false;
        //create billing date that is last day of current month
        Date firstDayOfMonth = System.today().toStartOfMonth();
        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
        System.runAs(getSystemAdmin()) {
            Test.startTest();
            try{
                MyProgramValidationHelper.validateBillingDate(lastDayOfMonth,lastDayOfMonth.addDays(90));
            }catch(Exception exceptionObj){
                flag = true;
            }
            System.assertEquals(false,flag,'Exception occured for billing date that is last day of month');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method gives exception for a billing date that is not last day of the month
    * @author Ayan Khanra | 01-14-2025 
    **/
    @IsTest
    private static void testNotLastDayOfMonthBillingDateException(){
        Boolean flag = false;
        System.runAs(getSystemAdmin()) {
            Test.startTest();
            try{
                MyProgramValidationHelper.validateBillingDate(Date.newInstance(2027, 12, 13),Date.newInstance(2027, 12, 20));
            }catch(Exception exceptionObj){
                flag = true;
                System.assertEquals(PortalConstants.BILLING_DATE_IS_NOT_LAST_DAY, exceptionObj.getMessage(),'Exception message is not same');
            }
            System.assertEquals(true,flag,'Exception not occured for a billing date that is not last day of month');
            Test.stopTest();
        }
    }

    /**
    * @description : Returns admin user
    * @author Ayan Khanra | 01-14-2025 
    * @return List<User> 
    **/
    private static User getSystemAdmin(){
        return [SELECT Id 
                FROM User 
                WHERE Profile.Name = 'System Administrator' 
                AND IsActive = true 
                LIMIT 1];
    }  

    /**
    * @description : Returns rate card setup detail
    * @author Ayan Khanra | 01-14-2025 
    * @return List<genesis__Rate_Card_Setup_Detail__c> 
    **/
    private static  List<genesis__Rate_Card_Setup_Detail__c> getSetUpDetail(){
        return [SELECT Id,
                        Start_Date__c,
                        End_Date__c,
                        Interest_Rate_Type__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Participation_Percentage_Dealer__c
                FROM genesis__Rate_Card_Setup_Detail__c LIMIT 1];
    } 
}