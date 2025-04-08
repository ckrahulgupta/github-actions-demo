/**
 * @description       :  Test Class for PortalCloneMyProgramAPI
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 01-15-2025
 * @last modified by  : Shristy Kumari
**/

@isTest
private class PortalCloneMyProgramAPITest{
    /**
    * @description : Test Setup
    * @author  Pritam Roy | 03-29-2024 
    **/
    @TestSetup
    static void setup(){
        //Creating Product
        clcommon__CL_Product__c productObj = LoanServicingTestHelper.createLoanProduct();
        Database.insert(productObj, true);

        //creating borrower legal entity
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createDBALegalEntity();
        Database.insert(entityObj, true);

        //Creating Dealer Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);

        //Creating the dealer account
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);

        //Creating the CL Account
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id,dealerAccountObj.id);
        //Creating Account for Borrower
        Account borrowerAccObj = ApplicationOriginationTestHelper.createDBAccount(entityObj, dealerBusinessInfoObj.Id);
        //Creating Account for sales agent
        Account saAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        //Creating Account for sales agent admin
        Account saAdminAccObj = ApplicationOriginationTestHelper.createSAAdminAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(new List<Account>{clAccountObj,saAccountObj,saAdminAccObj, borrowerAccObj}, true);

        //Creating the Contact for CL,sales agent,sales agent admin and borrower
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Contact saContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(saAccountObj.Id);
        Contact saAdminContactObj=ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccObj.Id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccObj.Id);
        Database.insert(new List<Contact>{clContactObj, saContactObj, saAdminContactObj, borrowerContactObj},true);

        //Creating a CL user
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        //Creating a Standard User
        User standardUserObj = ApplicationOriginationTestHelper.createStandardUser();
        User saUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(saContactObj.Id);
        // Creating User for Borrower
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        User saAdminUserObj = ApplicationOriginationTestHelper.createSAAdminUser(saAdminContactObj.Id);
        Database.insert(new List<User>{clUserObj, standardUserObj,saUserObj,saAdminUserObj,borrowerUserObj}, true);
        
        //Creating Loan Product
        clcommon__CL_Product__c loanProductObj = ApplicationOriginationTestHelper.createLoanProduct();
        Database.insert(loanProductObj, true);

        //Creating Rate Card Setup Header
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerAccountObj);
        Database.insert(rateCardHeaderObj,true);

        //Creating Product Rate Card Association
        genesis__Product_Rate_Card_Association__c rateProductObj = ApplicationOriginationTestHelper.createRateToProductAssociation(loanProductObj,rateCardHeaderObj);
        Database.insert(rateProductObj, true);

        //Additional Determing Factor for Program
        genesis__Additional_Determining_Factor__c additionalFactorObj = ApplicationOriginationTestHelper.createAdditionalFactorForProgram(rateCardHeaderObj);
        //Additional Factor for Dealer
        genesis__Additional_Determining_Factor__c additionalFactorDealerObj = ApplicationOriginationTestHelper.createAdditionalFactorForDealer(rateCardHeaderObj);
        Database.insert(new List<genesis__Additional_Determining_Factor__c>{additionalFactorObj, additionalFactorDealerObj}, true);

        //Creating Rate Card Setup Detail
        genesis__Rate_Card_Setup_Detail__c rateCardDetailObj = ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        Database.insert(rateCardDetailObj, true);

        //Creating Application with Flex Rate
        genesis__Applications__c flexApplicationObj = ApplicationOriginationTestHelper.createApplicationForFlex(loanProductObj,borrowerAccObj);
        Database.insert(flexApplicationObj, true);   
    }
    /**
    * @description : Generic Method to create all Tranches for My Program
    * @author  Pritam Roy | 03-27-2024 
    * @param requestMap 
    * @param objRateCardHeader 
    * @return Map<String, Object> 
    **/
    static Map<String,Object> createMyProgramAllTranches(Map<String,Object> requestMap,genesis__Rate_Card_Setup_Header__c objRateCardHeader){
        Map<String, Object> subTrancheMap = new Map<String, Object>();
        subTrancheMap.put('description','Summer Crops');

        List<Map<String,Object>> subTrancheInfoList = new List<Map<String,Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_Dealer_Subsidy__c' => 2.5999999999999996,
                'Participation_Percentage_CFA__c' => 1.5,
                'Start_Date__c' => '2022-07-14',
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
                'Start_Date__c' => '2022-07-14',
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
                'Start_Date__c' => '2022-07-14',
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
                'Participation_Percentage_Dealer_Subsidy__c' => 4.75,
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
    * @description Method to fetch the cl user
    * @author Shristy Kumari | 01-14-2025 
    * @return User 
    **/
    private static User getClUser(){
        List<User> objUserList = [SELECT Id 
                                    FROM User 
                                    WHERE AccountId IN (
                                        SELECT Id 
                                        FROM Account 
                                        WHERE Name = 'Ross Geller')];          
        if(objUserList.size() == 1){
            return objUserList[0];
        } 
        return null;
    }
    /**
    * @description Method to fetch rate card header
    * @author Shristy Kumari | 01-06-2025 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    private static genesis__Rate_Card_Setup_Header__c getRateCardHeader(){
        List<genesis__Rate_Card_Setup_Header__c> rateCardSetupHeaderList = [SELECT Id, 
                                                                                   Name, 
                                                                                   Account__c, 
                                                                                   CFA_Advantage_Rate__c, 
                                                                                   Field_Finance_Rate__c,
                                                                                   genesis__Description__c, 
                                                                                   Crop_Year__c, 
                                                                                   Closing_Fee__c , 
                                                                                   genesis__End_Date__c
                                                                            FROM genesis__Rate_Card_Setup_Header__c 
                                                                            WHERE Name = 'My Test Program 99'];
        if(rateCardSetupHeaderList.size() == 1){
            return rateCardSetupHeaderList[0];
        } 
        return null;
    }
    /**
    * @description : Method to test Portal Clone My Program Success
    * @author  Pritam Roy | 03-29-2024 
    **/
    @isTest
    static void testCloneMyProgramAPISuccess(){
        clcommon.Response responseObj;
        User clUser = getClUser();
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = getRateCardHeader();
        rateCardHeaderObj.Crop_Year__c = String.valueOf(System.today().Year());
        rateCardHeaderObj.Field_Finance_Rate__c = 9.5;
        String endDateStr = '12/15/'+String.valueOf(System.today().Year());
        Date endDate = Date.parse(endDateStr);
        rateCardHeaderObj.genesis__End_Date__c = endDate;
        Database.update(rateCardHeaderObj);
        System.runAs(clUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderObj));
            requestMap = createMyProgramAllTranches(requestMap,rateCardHeaderObj);
            Test.startTest();
            PortalCloneMyProgramAPI cloneMyProgramAPIObj = new PortalCloneMyProgramAPI();
            responseObj = cloneMyProgramAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, responseObj.status, 'My Program is not cloned successfully');
            List<genesis__Rate_Card_Setup_Header__c> clonedRateCardHeadersList = [SELECT Id, Name 
                                                                                  FROM genesis__Rate_Card_Setup_Header__c 
                                                                                  WHERE Name = :rateCardHeaderObj.Name];
            List<genesis__Rate_Card_Setup_Detail__c> clonedRateCardDetailsList = [SELECT Id 
                                                                                  FROM genesis__Rate_Card_Setup_Detail__c 
                                                                                  WHERE genesis__Rate_Card_Setup_Header__c IN :clonedRateCardHeadersList];
            System.assertEquals(clonedRateCardDetailsList.size(),1, 'Expected cloned rate card details to be created.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test Wrong Logged in User Exception
    * @author  Pritam Roy | 03-29-2024 
    **/
    @isTest
    static void testWrongLoggedInUserException(){
        clcommon.Response responseObj;
        User standardUserObj = [SELECT Id FROM User WHERE Username = 'std.user@yopmail.com'];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = getRateCardHeader();
        rateCardHeaderObj.Crop_Year__c = String.valueOf(System.today().Year());
        rateCardHeaderObj.Field_Finance_Rate__c = 9.5;
        String endDateStr = '12/15/'+String.valueOf(System.today().Year());
        Date endDate = Date.parse(endDateStr);
        rateCardHeaderObj.genesis__End_Date__c = endDate;
        Database.update(rateCardHeaderObj,true);
        System.runAs(standardUserObj){
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderObj));
            requestMap = createMyProgramAllTranches(requestMap,rateCardHeaderObj);
            Test.startTest();
            PortalCloneMyProgramAPI cloneMyProgramAPI = new PortalCloneMyProgramAPI();
            responseObj = cloneMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(PortalConstants.USER_NOT_AUTHORISED, responseObj.errorMessage, 'Exception expected for wrong logged in user');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test success scenerio when My Program is associated with a Loan Product 
    * @author  Pritam Roy | 03-29-2024 
    **/
    @isTest
    static void testWithLoanProductSuccess(){
        clcommon.Response responseObj;
        User clUser = getClUser();
        clcommon__CL_Product__c productObj = [SELECT Id FROM clcommon__CL_Product__c LIMIT 1];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = getRateCardHeader();
        rateCardHeaderObj.Crop_Year__c = String.valueOf(System.today().Year());
        rateCardHeaderObj.Field_Finance_Rate__c = 9.5;
        rateCardHeaderObj.genesis__CL_Product__c = productObj.id;
        String endDateStr = '12/15/'+String.valueOf(System.today().Year());
        Date endDate = Date.parse(endDateStr);
        rateCardHeaderObj.genesis__End_Date__c = endDate;
        Database.update(rateCardHeaderObj);
        System.runAs(clUser){
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderObj));
            requestMap = createMyProgramAllTranches(requestMap,rateCardHeaderObj);
            Test.startTest();
            PortalCloneMyProgramAPI cloneMyProgramAPIObj = new PortalCloneMyProgramAPI();
            responseObj = cloneMyProgramAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, responseObj.status, 'My Program is not cloned successfully');
            List<genesis__Rate_Card_Setup_Header__c> clonedRateCardHeadersList = [SELECT Id, Name 
                                                                                  FROM genesis__Rate_Card_Setup_Header__c 
                                                                                  WHERE Name = :rateCardHeaderObj.Name];
            List<genesis__Rate_Card_Setup_Detail__c> clonedRateCardDetailsList = [SELECT Id 
                                                                                  FROM genesis__Rate_Card_Setup_Detail__c 
                                                                                  WHERE genesis__Rate_Card_Setup_Header__c IN :clonedRateCardHeadersList];
            System.assertEquals(clonedRateCardDetailsList.size(),1, 'Expected cloned rate card details to be created.');
            Test.stopTest();
        }
    }
    /**
    * @description : Wrong My Program Name
    * @author  Pritam Roy | 03-29-2024 
    **/
    @isTest
    static void testWrongMyProgramNameException(){
        clcommon.Response responseObj;
        User clUser = getClUser();
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = getRateCardHeader();
        rateCardHeaderObj.Crop_Year__c = String.valueOf(System.today().Year());
        rateCardHeaderObj.Field_Finance_Rate__c = 9.5;
        rateCardHeaderObj.name = '#MY PROGRAM';
        String endDateStr = '12/15/'+String.valueOf(System.today().Year());
        Date endDate = Date.parse(endDateStr);
        rateCardHeaderObj.genesis__End_Date__c = endDate;
        Database.update(rateCardHeaderObj);
        System.runAs(clUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderObj));
            requestMap = createMyProgramAllTranches(requestMap,rateCardHeaderObj);
            Test.startTest();
            PortalCloneMyProgramAPI cloneMyProgramAPI = new PortalCloneMyProgramAPI();
            responseObj = cloneMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(PortalConstants.WRONG_MY_PROGRAM_NAME, responseObj.errorMessage, 'Exception Expected for wrong my program name');
            Test.stopTest();
        }
    }
     /**
    * @description : My Program with no crop year exception
    * @author  Pritam Roy | 03-29-2024 
    **/
    @isTest
    static void testNoCropYearException(){
        clcommon.Response responseObj;
        User clUser = getClUser();
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = getRateCardHeader();
    
        rateCardHeaderObj.Crop_Year__c = NULL;
        rateCardHeaderObj.Field_Finance_Rate__c = 9.5;
        String endDateStr = '12/15/'+String.valueOf(System.today().Year());
        Date endDate = Date.parse(endDateStr);
        rateCardHeaderObj.genesis__End_Date__c = endDate;
        Database.update(rateCardHeaderObj);
        System.runAs(clUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderObj));
            requestMap = createMyProgramAllTranches(requestMap,rateCardHeaderObj);
            Test.startTest();
            PortalCloneMyProgramAPI cloneMyProgramAPIObj = new PortalCloneMyProgramAPI();
            responseObj = cloneMyProgramAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(PortalConstants.CROP_YEAR_NULL_ERROR,responseObj.errorMessage, 'Exception expected for no crop year');
            Test.stopTest();
        }
    }

    /**
    * @description : Portal Clone Blank Program Exception
    * @author  Pritam Roy | 03-29-2024 
    **/
    @isTest
    static void testWithBlankProgramException(){
        clcommon.Response responseObj;
        User clUser = getClUser();
        System.runAs(clUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize('blank'));
            Test.startTest();
            PortalCloneMyProgramAPI cloneMyProgramAPIObj = new PortalCloneMyProgramAPI();
            responseObj = cloneMyProgramAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(PortalConstants.SOMETHING_WENT_WRONG, responseObj.errorMessage, 'Exception expected for wrong my program');
            Test.stopTest();
        }
    }
    /**
    * @description : Portal Clone Blank Program No Header Exception
    * @author  Pritam Roy | 03-29-2024 
    **/
    @isTest
    static void testNoHeaderException(){
        String objMessage;
        clcommon.Response responseObj;
        User clUser = getClUser();
        System.runAs(clUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            Test.startTest();
            Try{
               PortalCloneMyProgramAPI cloneMyProgramAPI = new PortalCloneMyProgramAPI();
               responseObj = cloneMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            }catch(Exception exceptionObj){
               objMessage = exceptionObj.getMessage();
            }
            System.assertEquals(PortalConstants.SOMETHING_WENT_WRONG,objMessage, 'No Exception');
            Test.stopTest();
        }
    }

    /**
    * @description : Tes Portal Clone My Program API Wrong End Date Exception
    * @author  Pritam Roy | 03-29-2024 
    **/
    @isTest
    static void testWrongEndDateException(){
        clcommon.Response responseObj;
        User clUser = getClUser();
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = getRateCardHeader();
        
        rateCardHeaderObj.Crop_Year__c = '2023';
        String endDateStr = '05/15/2024';
        Date endDate = Date.parse(endDateStr);
        rateCardHeaderObj.genesis__End_Date__c = endDate;
        System.runAs(clUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderObj));
            Test.startTest();
            PortalCloneMyProgramAPI cloneMyProgramAPIObj = new PortalCloneMyProgramAPI();
            responseObj = cloneMyProgramAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(PortalConstants.CROP_YEAR_ELIGIBLE_ERROR_JAN_MAY, responseObj.errorMessage, 'Exception expected for wrong end date');
            Test.stopTest();
        }
    }
    /**
    * @description : Portal Clone My Program API Payer as Dealer Wrong End Date Exception
    * @author  Pritam Roy | 03-29-2024 
    **/
    @isTest
    static void testDealerAsPayerWrongEndDateException(){
        clcommon.Response responseObj;
        User clUser = getClUser();
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = getRateCardHeader();
        
        rateCardHeaderObj.Crop_Year__c = '2023';
        String endDateStr = '05/15/2024';
        Date endDate = Date.parse(endDateStr);
        rateCardHeaderObj.genesis__End_Date__c = endDate;
        rateCardHeaderObj.Payer_of_Loan_Closing_Fee__c = 'Dealer';
        Database.update(rateCardHeaderObj);

        System.runAs(clUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderObj));
            Test.startTest();
            PortalCloneMyProgramAPI cloneMyProgramAPIObj = new PortalCloneMyProgramAPI();
            responseObj = cloneMyProgramAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(PortalConstants.CROP_YEAR_ELIGIBLE_ERROR_JAN_MAY, responseObj.errorMessage, 'Exception expected for wrong end date for payer as a dealer');
            Test.stopTest();
        }
    }

    /**
    * @description : Portal Clone My Program API End Year Less than Crop Year
    * @author  Pritam Roy | 03-29-2024 
    **/
    @isTest
    static void testEndYearLessThanCropYearException(){
        clcommon.Response responseObj;
        User clUser = getClUser();
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = getRateCardHeader();
        rateCardHeaderObj.Crop_Year__c = String.valueOf(System.today().Year());
        String endDateStr = '05/15/2024';
        Date endDate = Date.parse(endDateStr);
        rateCardHeaderObj.genesis__End_Date__c = endDate;
        rateCardHeaderObj.Payer_of_Loan_Closing_Fee__c = 'Dealer';
        Database.update(rateCardHeaderObj);
        System.runAs(clUser){
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderObj));
            Test.startTest();
            PortalCloneMyProgramAPI cloneMyProgramAPIObj = new PortalCloneMyProgramAPI();
            responseObj = cloneMyProgramAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(PortalConstants.CLONE_MATURITY_DATE_ERROR,responseObj.errorMessage, 'Exception expected for wrong end year');
            Test.stopTest();
        }
    }
    /**
    * @description : Test Portal Clone My Program Success by sales agent user
    * @author  Shristy Kumari | 01-15-2025 
    **/
    @isTest
    static void testCloneMyProgramAPISuccessBySaUser(){
        clcommon.Response responseObj;
        User saUser = [SELECT Id,UserName FROM User WHERE UserName='tony.stark@yopmail.com' LIMIT 1];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = getRateCardHeader();
        rateCardHeaderObj.Crop_Year__c = String.valueOf(System.today().Year());
        rateCardHeaderObj.Field_Finance_Rate__c = 9.5;
        String endDateStr = '12/15/'+String.valueOf(System.today().Year());
        Date endDate = Date.parse(endDateStr);
        rateCardHeaderObj.genesis__End_Date__c = endDate;
        Database.update(rateCardHeaderObj);
        System.runAs(saUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderObj));
            requestMap = createMyProgramAllTranches(requestMap,rateCardHeaderObj);
            Test.startTest();
            PortalCloneMyProgramAPI cloneMyProgramAPIObj = new PortalCloneMyProgramAPI();
            responseObj = cloneMyProgramAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, responseObj.status, 'My Program is not cloned successfully by sales agent user');
            List<genesis__Rate_Card_Setup_Header__c> clonedRateCardHeadersList = [SELECT Id, Name 
                                                                                  FROM genesis__Rate_Card_Setup_Header__c 
                                                                                  WHERE Name = :rateCardHeaderObj.Name];
            List<genesis__Rate_Card_Setup_Detail__c> clonedRateCardDetailsList = [SELECT Id 
                                                                                  FROM genesis__Rate_Card_Setup_Detail__c 
                                                                                  WHERE genesis__Rate_Card_Setup_Header__c IN :clonedRateCardHeadersList];
            System.assertEquals(clonedRateCardDetailsList.size(),1, 'Expected cloned rate card details to be created.');
            Test.stopTest();
        }
    }
    /**
    * @description : Test Portal Clone My Program Success by sales agent admin user
    * @author  Shristy Kumari | 01-15-2025 
    **/
    @isTest
    static void testCloneMyProgramAPISuccessBySaAdminUser(){
        clcommon.Response responseObj;
        User saUser = [SELECT Id,UserName FROM User WHERE UserName='tim.couper@yopmail.com' LIMIT 1];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = getRateCardHeader();
        rateCardHeaderObj.Crop_Year__c = String.valueOf(System.today().Year());
        rateCardHeaderObj.Field_Finance_Rate__c = 9.5;
        String endDateStr = '12/15/'+String.valueOf(System.today().Year());
        Date endDate = Date.parse(endDateStr);
        rateCardHeaderObj.genesis__End_Date__c = endDate;
        Database.update(rateCardHeaderObj);
        System.runAs(saUser) {
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderObj));
            requestMap = createMyProgramAllTranches(requestMap,rateCardHeaderObj);
            Test.startTest();
            PortalCloneMyProgramAPI cloneMyProgramAPIObj = new PortalCloneMyProgramAPI();
            responseObj = cloneMyProgramAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, responseObj.status, 'My Program is not cloned successfully by sales agent admin user');
            List<genesis__Rate_Card_Setup_Header__c> clonedRateCardHeadersList = [SELECT Id, Name 
                                                                                  FROM genesis__Rate_Card_Setup_Header__c 
                                                                                  WHERE Name = :rateCardHeaderObj.Name];
            List<genesis__Rate_Card_Setup_Detail__c> clonedRateCardDetailsList = [SELECT Id 
                                                                                  FROM genesis__Rate_Card_Setup_Detail__c 
                                                                                  WHERE genesis__Rate_Card_Setup_Header__c IN :clonedRateCardHeadersList];
            System.assertEquals(clonedRateCardDetailsList.size(),1, 'Expected cloned rate card details to be created.');
            Test.stopTest();
        }
    }
    /**
    * @description : Test Portal Clone My Program by Borrower user exception
    * @author  Shristy Kumari | 01-15-2025 
    **/
    @isTest
    static void testCloneMyProgramAPIExceptionBorrowerUser(){
        clcommon.Response responseObj;
        User borrowerUser = [SELECT Id,UserName FROM User WHERE UserName='star.lord@yopmail.com' LIMIT 1];
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = getRateCardHeader();
        rateCardHeaderObj.Crop_Year__c = String.valueOf(System.today().Year());
        rateCardHeaderObj.Field_Finance_Rate__c = 9.5;
        String endDateStr = '12/15/'+String.valueOf(System.today().Year());
        Date endDate = Date.parse(endDateStr);
        rateCardHeaderObj.genesis__End_Date__c = endDate;
        Database.update(rateCardHeaderObj);
        System.runAs(borrowerUser){
            Map<String,Object> requestMap = new Map<String,Object>();
            requestMap.put('program', Json.serialize(rateCardHeaderObj));
            requestMap = createMyProgramAllTranches(requestMap,rateCardHeaderObj);
            Test.startTest();
            PortalCloneMyProgramAPI cloneMyProgramAPI = new PortalCloneMyProgramAPI();
            responseObj = cloneMyProgramAPI.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(PortalConstants.USER_NOT_AUTHORISED, responseObj.errorMessage, 'Exception expected for wrong logged in user');
            Test.stopTest();
        }
    }
}