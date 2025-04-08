/**
 * @description       : Test class for PortalSaveAdditionalInfoAPI
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 12-01-2025
 * @last modified by  : Soumik Pattanayak
**/

@isTest
public with sharing class TestPortalSaveAdditionalInfoAPI {

    @testSetup
    static void setup(){
        genesis__Business_Information__c businessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoObj,true);
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoObj.id);
        Database.insert(dealerAccountObj,true);
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProduct();
        Database.insert(clProductObj,true);
        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(legalEntityObj,true);
        clcommon__Legal_Entity__c corpLegalEntityObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(corpLegalEntityObj,true);
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.insert(borrowerAccountObj,true);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        Database.insert(borrowerContactObj,true);

        Dealer_Applicant_Relationship__c relationshipObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Database.insert(relationshipObj,true);

        Account accountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(businessInfoObj.id,dealerAccountObj.id);
        Database.insert(accountObj,true);
        Contact contactObj = ApplicationOriginationTestHelper.createSalesAgentContact(accountObj.id);
        Database.insert(contactObj,true);
        User userObj = ApplicationOriginationTestHelper.createSalesAgentUser(contactObj.id);
        Database.insert(userObj,true);
        Map<String,Object> applicationDataMap = new Map<String,Object>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'saAccountObjId' => accountObj.id,
            'dealerApplicantRelationshipId' =>relationshipObj.Id
        };
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(applicationDataMap);
        Database.insert(applicationObj,true); 
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(clPartyTypeObj,true);
        clcommon__Party_Type__c spPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('SPOUSE');
        Database.insert(spPartyTypeObj,true);
        clcommon__Party_Type__c loPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('LANDOWNER');
        Database.insert(loPartyTypeObj,true);
        clcommon__Party_Type__c iaPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('INSURANCE AGENT');
        Database.insert(iaPartyTypeObj,true);
        clcommon__Party_Type__c buPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BUYER');
        Database.insert(buPartyTypeObj,true);
        clcommon__Party_Type__c saPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('SALES AGENT');
        Database.insert(saPartyTypeObj,true);
        Map<String,Id> partyParamMap = new Map<String,Id>{
            'accountId' => accountObj.id,
            'contactId' => contactObj.id,
            'partyTypeId' => saPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(partyParamMap);
        partyObj.clcommon__User__c = userObj.id;
        Database.insert(partyObj,true);
        clcommon__Collateral_Category__c collateralCategoryObj = ApplicationOriginationTestHelper.createCollateralCategory();
        Database.insert(collateralCategoryObj,true);

       List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList = ApplicationOriginationTestHelper.createCreditRatingMatrix();
       Database.insert(creditRatingMatrixList,true);

    }

    /**
    * @description 
    * @author Soumik Pattanayak | 12-01-2025 
    * @return List<User> 
    **/
    private static List<User> getUser(){
        genesis__Applications__c applicationObj = getApplications()[0];
        return [SELECT Id 
                FROM USER 
                WHERE Contact.AccountId = : applicationObj.Sales_Agent__c 
                AND Profile.Name = 'Sales Agent'];
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 12-01-2025 
    * @return List<genesis__Applications__c> 
    **/
    private static List<genesis__Applications__c> getApplications(){
        return [SELECT Id,
                    genesis__Credit_Rating__c,
                    Sales_Agent__c 
                FROM genesis__Applications__c LIMIT 1];
    }

    //SUCCESS
    @isTest
    public static void testShouldValidateAsTrue() {
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        clcommon__Collateral_Category__c collateralCategoryObj;
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        List<clcommon__Collateral_Category__c> collateralCategoryList = [SELECT Id 
                                                                            FROM clcommon__Collateral_Category__c];

        for(clcommon__Collateral_Category__c collateralCategory : collateralCategoryList){
            collateralCategoryObj = collateralCategory;
        }
        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Unchecked');
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('collateralZero', true);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingState\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        requestMap.put('cropDetails', '[{\"Total_Acres__c\":1000,\"Producer_Share_Percent__c\":100,\"clcommon__Collateral_Category__c\":\"'+collateralCategoryObj.Id+'\",\"Insurance_Plan__c\":\"None\",\"Id\":\"new_record_id\",\"Percent_Coverage_Level__c\":\"\",\"Approved_Yield__c\":100}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
        
    }

     /**
     * @description 
     * @author Soumik Pattanayak | 05-01-2025 
     **/
    @isTest
     static void testShouldValidateAsTrueWithoutAgreementProcessAsCustomized() {
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        clcommon__Collateral_Category__c collateralCategoryObj;
        genesis__Credit_Rating_Matrix__c creditRatingMatrixObj;
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList = [SELECT Id 
                                                                            FROM genesis__Credit_Rating_Matrix__c 
                                                                            WHERE Name = 'Tier 3'];
        for(genesis__Credit_Rating_Matrix__c crMatrix : creditRatingMatrixList){
            creditRatingMatrixObj = crMatrix;
        }
        applicationObj.genesis__Credit_Rating__c = creditRatingMatrixObj.id;
        applicationObj.Credit_Application_And_Agreement_Process__c = 'Proceed with the requirements for the tier';
        Database.update(applicationObj,true);
        
        List<User> userList = getUser();
        userObj = userList[0];

        List<clcommon__Collateral_Category__c> collateralCategoryList = [SELECT Id 
                                                                            FROM clcommon__Collateral_Category__c];

        for(clcommon__Collateral_Category__c collateralCategory : collateralCategoryList){
            collateralCategoryObj = collateralCategory;
        }
        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Unchecked');
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('collateralZero', true);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingState\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        requestMap.put('cropDetails', '[{\"Total_Acres__c\":1000,\"Producer_Share_Percent__c\":100,\"clcommon__Collateral_Category__c\":\"'+collateralCategoryObj.Id+'\",\"Insurance_Plan__c\":\"None\",\"Id\":\"new_record_id\",\"Percent_Coverage_Level__c\":\"\",\"Approved_Yield__c\":100}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
     /**
     * @description 
     * @author Soumik Pattanayak | 05-01-2025 
     **/
    @isTest
     static void testShouldValidateAsFalse() {
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        clcommon__Collateral_Category__c collateralCategoryObj;
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        List<clcommon__Collateral_Category__c> collateralCategoryList = [SELECT Id 
                                                                            FROM clcommon__Collateral_Category__c];

        for(clcommon__Collateral_Category__c collateralCategory : collateralCategoryList){
            collateralCategoryObj = collateralCategory;
        }
        requestMap.put('shouldValidate', false);
        requestMap.put('shouldAdjustLoanAmount', false);
        requestMap.put('feedCollateral', 'Unchecked');
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('collateralZero', true);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        requestMap.put('cropDetails', '[{\"Total_Acres__c\":1000,\"Producer_Share_Percent__c\":100,\"clcommon__Collateral_Category__c\":\"'+collateralCategoryObj.Id+'\",\"Insurance_Plan__c\":\"None\",\"Id\":\"new_record_id\",\"Percent_Coverage_Level__c\":\"\",\"Approved_Yield__c\":100}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }

     /**
     * @description 
     * @author Soumik Pattanayak | 05-01-2025 
     **/
    @isTest
     static void testFeedCollateralChecked() {

        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        clcommon__Collateral_Category__c collateralCategoryObj;
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        List<clcommon__Collateral_Category__c> collateralCategoryList = [SELECT Id 
                                                                            FROM clcommon__Collateral_Category__c];

        for(clcommon__Collateral_Category__c collateralCategory : collateralCategoryList){
            collateralCategoryObj = collateralCategory;
        }
        requestMap.put('shouldValidate', true);
        requestMap.put('shouldAdjustLoanAmount', true);
        requestMap.put('feedCollateral', 'Checked');
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('collateralZero', true);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        requestMap.put('cropDetails', '[{\"Total_Acres__c\":1000,\"Producer_Share_Percent__c\":100,\"clcommon__Collateral_Category__c\":\"'+collateralCategoryObj.Id+'\",\"Insurance_Plan__c\":\"None\",\"Id\":\"new_record_id\",\"Percent_Coverage_Level__c\":\"\",\"Approved_Yield__c\":100}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }

     /**
     * @description 
     * @author Soumik Pattanayak | 05-01-2025 
     **/
    @isTest
     static void testFeedCollateralUnChecked() {

        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        requestMap.put('shouldValidate', false);
        requestMap.put('shouldValidateCropInfo', true);
        requestMap.put('feedCollateral', 'Unhecked');
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('collateralZero', true);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertNotEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }

    // Exceptionsss @tuhin
    @isTest
     static void testLoanConfirmationFalseAndCropDetailsBlank(){// laon confirmation false and cropDetails blank
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        requestMap.put('shouldValidate', false);
        requestMap.put('shouldValidateCropInfo', true);
        requestMap.put('feedCollateral', 'Unchecked');
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('collateralZero', true);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        requestMap.put('cropDetails', '');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertNotEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
        
    }

    /**
    * @description blank app id
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @isTest
    public static void testBlankApplicationId(){ // blank app id
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        clcommon__Collateral_Category__c collateralCategoryObj;
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        List<clcommon__Collateral_Category__c> collateralCategoryList = [SELECT Id 
                                                                            FROM clcommon__Collateral_Category__c];

        for(clcommon__Collateral_Category__c collateralCategory : collateralCategoryList){
            collateralCategoryObj = collateralCategory;
        }

        requestMap.put('shouldValidate', false);
        requestMap.put('shouldValidateCropInfo', true);
        requestMap.put('feedCollateral', 'Unchecked');
        requestMap.put('applicationId', '');
        requestMap.put('collateralZero', true);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        requestMap.put('cropDetails', '[{\"Total_Acres__c\":1000,\"Producer_Share_Percent__c\":100,\"clcommon__Collateral_Category__c\":\"'+collateralCategoryObj.Id+'\",\"Insurance_Plan__c\":\"None\",\"Id\":\"new_record_id\",\"Percent_Coverage_Level__c\":\"\",\"Approved_Yield__c\":100}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertNotEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
        
    }
    /**
    * @description 
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @isTest
    public static void testWithoutApplicationParam(){ // blank app id
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        clcommon__Collateral_Category__c collateralCategoryObj;
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        List<clcommon__Collateral_Category__c> collateralCategoryList = [SELECT Id 
                                                                            FROM clcommon__Collateral_Category__c];

        for(clcommon__Collateral_Category__c collateralCategory : collateralCategoryList){
            collateralCategoryObj = collateralCategory;
        }
    
        requestMap.put('shouldValidate', false);
        requestMap.put('shouldValidateCropInfo', true);
        requestMap.put('feedCollateral', 'Unchecked');
        requestMap.put('collateralZero', true);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        requestMap.put('cropDetails', '[{\"Total_Acres__c\":1000,\"Producer_Share_Percent__c\":100,\"clcommon__Collateral_Category__c\":\"'+collateralCategoryObj.Id+'\",\"Insurance_Plan__c\":\"None\",\"Id\":\"new_record_id\",\"Percent_Coverage_Level__c\":\"\",\"Approved_Yield__c\":100}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertNotEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
        
    }
    /**
    * @description 
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @isTest
    public static void testWihoutSpouseParam() {
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        clcommon__Collateral_Category__c collateralCategoryObj;
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        List<clcommon__Collateral_Category__c> collateralCategoryList = [SELECT Id 
                                                                            FROM clcommon__Collateral_Category__c];

        for(clcommon__Collateral_Category__c collateralCategory : collateralCategoryList){
            collateralCategoryObj = collateralCategory;
        }

        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Unchecked');
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('collateralZero', true);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('cropDetails', '[{\"Total_Acres__c\":1000,\"Producer_Share_Percent__c\":100,\"clcommon__Collateral_Category__c\":\"'+collateralCategoryObj.Id+'\",\"Insurance_Plan__c\":\"None\",\"Id\":\"new_record_id\",\"Percent_Coverage_Level__c\":\"\",\"Approved_Yield__c\":100}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description 
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @isTest
    public static void testWithoutCropDetailsParam() {
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        requestMap.put('shouldValidate', true);
        requestMap.put('feedCollateral', 'Unchecked');
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('collateralZero', true);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @isTest
    public static void testWrongApplicationId(){ // wrong app id
        Map<String, Object> requestMap = new Map<String, Object>();

        genesis__Applications__c applicationObj;
        User userObj; 
        clcommon__Collateral_Category__c collateralCategoryObj;
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        List<clcommon__Collateral_Category__c> collateralCategoryList = [SELECT Id 
                                                                            FROM clcommon__Collateral_Category__c];

        for(clcommon__Collateral_Category__c collateralCategory : collateralCategoryList){
            collateralCategoryObj = collateralCategory;
        }

        requestMap.put('shouldValidate', false);
        requestMap.put('shouldValidateCropInfo', true);
        requestMap.put('feedCollateral', 'Unchecked');
        requestMap.put('applicationId', 'jhd73s28fg');
        requestMap.put('collateralZero', true);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        requestMap.put('cropDetails', '[{\"Total_Acres__c\":1000,\"Producer_Share_Percent__c\":100,\"clcommon__Collateral_Category__c\":\"'+collateralCategoryObj.Id+'\",\"Insurance_Plan__c\":\"None\",\"Id\":\"new_record_id\",\"Percent_Coverage_Level__c\":\"\",\"Approved_Yield__c\":100}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertNotEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
        
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @isTest
    public static void testWithoutCropInfoAndCheckedFeedCollateral(){
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        requestMap.put('shouldValidate', false);
        requestMap.put('shouldValidateCropInfo', true);
        requestMap.put('feedCollateral', 'Checked');
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        requestMap.put('cropDetails', '[{}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
        
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @isTest
    public static void testWithoutCropInfoAndUncheckedFeedCollateral(){
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        requestMap.put('shouldValidate', false);
        requestMap.put('shouldValidateCropInfo', true);
        requestMap.put('feedCollateral', 'Unchecked');
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        requestMap.put('cropDetails', '[{}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
        
    }

//------------------------------------------------------------------------------------------


    //Wrong JSON Format to throw Exception
    @isTest
    public static void testPortalSaveAdditionalInfoAPIWithoutInfo() {
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        requestMap.put('shouldValidate', true);
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('buyerDetails', '[\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\","clcommon__Account__r.BillingPostalCode\":\"12312\"]');
        requestMap.put('insuranceAgentDetails', '[{}]');
        requestMap.put('landownersDetails', '[{}]');
        requestMap.put('spouseDetails', '[{}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    //Custom exception for Insurance Agent on email missing
    @isTest
    public static void testWithoutInsuranceAgentEmail() {
        Map<String, Object> requestMap = new Map<String, Object>();

        genesis__Applications__c applicationObj;
        User userObj; 
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        requestMap.put('shouldValidate', true);
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    
    //Custom exception for insurance agent with name missing
    @isTest
    public static void testWithoutInsuranceAgentName() {
        Map<String, Object> requestMap = new Map<String, Object>();

        genesis__Applications__c applicationObj;
        User userObj; 
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        requestMap.put('shouldValidate', true);
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }

    //Custom exception for buyer with email missing
    @isTest
    public static void testWithoutBuyerEmail() {
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        requestMap.put('shouldValidate', true);
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    //Custom exception for buyer with name missing
    @isTest
    public static void testWithoutBuyerName() {
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        requestMap.put('shouldValidate', true);
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    //Custom exception for Landowner with County missing
    @isTest
    public static void testWithoutLandOwnerCounty() {
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        requestMap.put('shouldValidate', true);
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    //Custom exception for Landowner with Name missing
    @isTest
    public static void testWithoutLandOwnerName() {
        Map<String, Object> requestMap = new Map<String, Object>();

        genesis__Applications__c applicationObj;
        User userObj; 
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        requestMap.put('shouldValidate', true);
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.BillingCountry\":\"us\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    //Custom exception for Spouse with SSN missing
    @isTest
    public static void testWithoutSpouseSSN() {
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        requestMap.put('shouldValidate', true);
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.BillingCountry\":\"us\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\"}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    //Custom exception for Spouse with SSN missing
    @isTest
    public static void testWithoutSpouseLastNameAndSSN() {
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];

        requestMap.put('shouldValidate', true);
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.BillingCountry\":\"us\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\"}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    
    /**
    * @description 
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @isTest
    public static void testWithoutApplicationInfo() {
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj; 
        List<genesis__Applications__c> applicationList = getApplications();
        applicationObj = applicationList[0];
        List<User> userList = getUser();
        userObj = userList[0];
        
        requestMap.put('shouldValidate', true);
        requestMap.put('applicationId', '');
        requestMap.put('buyerDetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('insuranceAgentDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('landownersDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoAPI testApi = new PortalSaveAdditionalInfoAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
        
}