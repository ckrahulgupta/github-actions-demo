/**
 * @description       : Test class for PortalSaveAdditionalInfoPollingAPI class
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 05-01-2025
 * @last modified by  : Soumik Pattanayak
**/
@isTest
public with sharing class PortalSaveAdditionalInfoPollingAPITest {
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

        Dealer_Applicant_Relationship__c relationshipObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj, dealerAccountObj.Id);
        Database.insert(relationshipObj,true);

        Database.insert(borrowerContactObj,true);
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
            'dealerApplicantRelationshipId' => relationshipObj.Id
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
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @isTest
    public static void testApiSuccess() {
        Map<String, Object> requestMap = new Map<String,Object>();
        Map<String, String> batchRequestMap = new Map<String, String>();
        genesis__Applications__c applicationObj;
        User userObj; 
        clcommon__Collateral_Category__c collateralCategoryObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                Sales_Agent__c 
                                                            FROM genesis__Applications__c LIMIT 1];
        for(genesis__Applications__c appObj : applicationList){
            applicationObj = appObj;
        }
        List<User> userList = [SELECT Id 
                                FROM USER 
                                WHERE Contact.AccountId = : applicationObj.Sales_Agent__c 
                                AND Profile.Name = 'Sales Agent'];

        for(User newUser : userList){
            userObj = newUser;
        }

        List<clcommon__Collateral_Category__c> collateralCategoryList = [SELECT Id 
                                                                            FROM clcommon__Collateral_Category__c];

        for(clcommon__Collateral_Category__c collateralCategory : collateralCategoryList){
            collateralCategoryObj = collateralCategory;
        }
        batchRequestMap.put('shouldValidate', String.valueOf(true));
        batchRequestMap.put('applicationId', applicationObj.Id);
        batchRequestMap.put('potentialBuyerdetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        batchRequestMap.put('cropInsuranceDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        batchRequestMap.put('additionalCropDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        batchRequestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        batchRequestMap.put('partyType', PortalConstants.INSURANCE_AGENT_PARTY_NAME);
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoBatch batchObject = new PortalSaveAdditionalInfoBatch(batchRequestMap);
            Id batchId = Database.executeBatch(batchObject,20);
           
            List<Id> batchIdsList = new List<id>();
            batchIdsList.add(batchId);
            String jsonString = JSON.serialize(batchIdsList);
            requestMap.put('batchIds',jsonString);
            PortalSaveAdditionalInfoPollingAPI testApi = new PortalSaveAdditionalInfoPollingAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(true, response.status == clcommon.Constants.PENDING | response.status == clcommon.Constants.SUCCESS,'Assertion Failed');
        }
        
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @isTest
    public static void testCustomExceptionRequiredParameterMissing() {
        Map<String, Object> requestMap = new Map<String,Object>();
        Map<String, String> batchRequestMap = new Map<String, String>();
        genesis__Applications__c applicationObj;
        User userObj; 
        clcommon__Collateral_Category__c collateralCategoryObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                Sales_Agent__c 
                                                            FROM genesis__Applications__c LIMIT 1];
        for(genesis__Applications__c appObj : applicationList){
            applicationObj = appObj;
        }
        List<User> userList = [SELECT Id 
                                FROM USER 
                                WHERE Contact.AccountId = : applicationObj.Sales_Agent__c 
                                AND Profile.Name = 'Sales Agent'];

        for(User newUser : userList){
            userObj = newUser;
        }

        List<clcommon__Collateral_Category__c> collateralCategoryList = [SELECT Id 
                                                                            FROM clcommon__Collateral_Category__c];

        for(clcommon__Collateral_Category__c collateralCategory : collateralCategoryList){
            collateralCategoryObj = collateralCategory;
        }
        batchRequestMap.put('shouldValidate', String.valueOf(true));
        batchRequestMap.put('applicationId', applicationObj.Id);
        batchRequestMap.put('potentialBuyerdetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        batchRequestMap.put('cropInsuranceDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        batchRequestMap.put('additionalCropDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        batchRequestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        batchRequestMap.put('partyType', PortalConstants.INSURANCE_AGENT_PARTY_NAME);
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoPollingAPI testApi = new PortalSaveAdditionalInfoPollingAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
        }
        
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @isTest
    public static void testApiFailure() {
        Map<String, Object> requestMap = new Map<String,Object>();
        Map<String, String> batchRequestMap = new Map<String, String>();
        genesis__Applications__c applicationObj;
        User userObj; 
        clcommon__Collateral_Category__c collateralCategoryObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                Sales_Agent__c 
                                                            FROM genesis__Applications__c LIMIT 1];
        for(genesis__Applications__c appObj : applicationList){
            applicationObj = appObj;
        }
        List<User> userList = [SELECT Id 
                                FROM USER 
                                WHERE Contact.AccountId = : applicationObj.Sales_Agent__c 
                                AND Profile.Name = 'Sales Agent'];

        for(User newUser : userList){
            userObj = newUser;
        }

        List<clcommon__Collateral_Category__c> collateralCategoryList = [SELECT Id 
                                                                            FROM clcommon__Collateral_Category__c];

        for(clcommon__Collateral_Category__c collateralCategory : collateralCategoryList){
            collateralCategoryObj = collateralCategory;
        }
        batchRequestMap.put('shouldValidate', String.valueOf(true));
        batchRequestMap.put('applicationId', applicationObj.Id);
        batchRequestMap.put('potentialBuyerdetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        batchRequestMap.put('cropInsuranceDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        batchRequestMap.put('additionalCropDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        batchRequestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        batchRequestMap.put('partyType', PortalConstants.INSURANCE_AGENT_PARTY_NAME);
        
        System.runAs(userObj) {
            Test.startTest();
            requestMap.put('batchIds', '12546789');
            PortalSaveAdditionalInfoPollingAPI testApi = new PortalSaveAdditionalInfoPollingAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
        }
        
    }
}