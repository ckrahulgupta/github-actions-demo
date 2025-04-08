/**********************************************************************************************************************
 * @description       : Test class for PortalSaveAdditionalInfoBatch
 * @author            : Suraj Kumar | 12-28-2023
 * @group             : 
 * @last modified on  : 06-01-2025
 * @last modified by  : Soumik Pattanayak
**********************************************************************************************************************/

@isTest
public with sharing class PortalSaveAdditionalInfoBatchTest {
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
        
        Dealer_Applicant_Relationship__c relationshipObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj, dealerAccountObj.Id);
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
    public static void testInsuranceAgentDetails() {
        Map<String, String> requestMap = new Map<String, String>();
        genesis__Applications__c applicationObj;
        User userObj; 
        clcommon__Collateral_Category__c collateralCategoryObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                Sales_Agent__c 
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationObj = applicationList[0];
        List<User> userList = [SELECT Id 
                                FROM USER 
                                WHERE Contact.AccountId = : applicationObj.Sales_Agent__c 
                                AND Profile.Name = 'Sales Agent'];
        userObj = userList[0];

        List<clcommon__Collateral_Category__c> collateralCategoryList = [SELECT Id 
                                                                            FROM clcommon__Collateral_Category__c];

        for(clcommon__Collateral_Category__c collateralCategory : collateralCategoryList){
            collateralCategoryObj = collateralCategory;
        }
        requestMap.put('shouldValidate', String.valueOf(true));
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('potentialBuyerdetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('cropInsuranceDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('additionalCropDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        requestMap.put('partyType', PortalConstants.INSURANCE_AGENT_PARTY_NAME);
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoBatch insuranceAgentBatchObject = new PortalSaveAdditionalInfoBatch(requestMap);
            Database.executeBatch(insuranceAgentBatchObject,20);
            Test.stopTest();
        }
        List<clcommon__Party__c> partyList = [SELECT id, clcommon__Party_Types__c FROM clcommon__Party__c];
        System.assertEquals(true,partyList.size()>1,'Failure');
        
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @isTest
    public static void testBuyersDetails() {
        Map<String, String> requestMap = new Map<String, String>();
        genesis__Applications__c applicationObj;
        User userObj; 
        clcommon__Collateral_Category__c collateralCategoryObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                Sales_Agent__c 
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationObj = applicationList[0];
        List<User> userList = [SELECT Id 
                                FROM USER 
                                WHERE Contact.AccountId = : applicationObj.Sales_Agent__c 
                                AND Profile.Name = 'Sales Agent'];
        userObj = userList[0];

        List<clcommon__Collateral_Category__c> collateralCategoryList = [SELECT Id 
                                                                            FROM clcommon__Collateral_Category__c];

        for(clcommon__Collateral_Category__c collateralCategory : collateralCategoryList){
            collateralCategoryObj = collateralCategory;
        }
        requestMap.put('shouldValidate', String.valueOf(true));
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('potentialBuyerdetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('cropInsuranceDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('additionalCropDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        requestMap.put('partyType', PortalConstants.BUYER_PARTY_NAME);
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoBatch insuranceAgentBatchObject = new PortalSaveAdditionalInfoBatch(requestMap);
            Database.executeBatch(insuranceAgentBatchObject,20);
            Test.stopTest();
        }
        List<clcommon__Party__c> partyList = [SELECT id, clcommon__Party_Types__c FROM clcommon__Party__c];
        System.assertEquals(true,partyList.size()>1,'Failure');
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @isTest
    public static void testLandownersDetails() {
        Map<String, String> requestMap = new Map<String, String>();
        genesis__Applications__c applicationObj;
        User userObj; 
        clcommon__Collateral_Category__c collateralCategoryObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                Sales_Agent__c 
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationObj = applicationList[0];
        List<User> userList = [SELECT Id 
                                FROM USER 
                                WHERE Contact.AccountId = : applicationObj.Sales_Agent__c 
                                AND Profile.Name = 'Sales Agent'];
        userObj = userList[0];

        List<clcommon__Collateral_Category__c> collateralCategoryList = [SELECT Id 
                                                                            FROM clcommon__Collateral_Category__c];

        for(clcommon__Collateral_Category__c collateralCategory : collateralCategoryList){
            collateralCategoryObj = collateralCategory;
        }
        requestMap.put('shouldValidate', String.valueOf(true));
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('potentialBuyerdetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('cropInsuranceDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('additionalCropDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        requestMap.put('partyType', PortalConstants.LANDOWNER_PARTY_NAME);
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoBatch insuranceAgentBatchObject = new PortalSaveAdditionalInfoBatch(requestMap);
            Database.executeBatch(insuranceAgentBatchObject,20);
            Test.stopTest();
        }
        List<clcommon__Party__c> partyList = [SELECT id, clcommon__Party_Types__c FROM clcommon__Party__c];
        System.assertEquals(true,partyList.size()>1,'Failure');
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @isTest
    public static void testSpouseDetails() {
        Map<String, String> requestMap = new Map<String, String>();
        genesis__Applications__c applicationObj;
        User userObj; 
        clcommon__Collateral_Category__c collateralCategoryObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                Sales_Agent__c 
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationObj = applicationList[0];
        List<User> userList = [SELECT Id 
                                FROM USER 
                                WHERE Contact.AccountId = : applicationObj.Sales_Agent__c 
                                AND Profile.Name = 'Sales Agent'];
        userObj = userList[0];

        List<clcommon__Collateral_Category__c> collateralCategoryList = [SELECT Id 
                                                                            FROM clcommon__Collateral_Category__c];

        for(clcommon__Collateral_Category__c collateralCategory : collateralCategoryList){
            collateralCategoryObj = collateralCategory;
        }
        requestMap.put('shouldValidate', String.valueOf(true));
        requestMap.put('applicationId', applicationObj.Id);
        requestMap.put('potentialBuyerdetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('cropInsuranceDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('additionalCropDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        requestMap.put('partyType', PortalConstants.SPOUSE_PARTY_NAME);
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoBatch insuranceAgentBatchObject = new PortalSaveAdditionalInfoBatch(requestMap);
            Database.executeBatch(insuranceAgentBatchObject,20);
            Test.stopTest();
        }
        List<clcommon__Party__c> partyList = [SELECT id, clcommon__Party_Types__c FROM clcommon__Party__c];
        System.assertEquals(true,partyList.size()>1,'Failure');
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @isTest
    public static void testApiException() {
        Map<String, String> requestMap = new Map<String, String>();
        genesis__Applications__c applicationObj;
        User userObj; 
        clcommon__Collateral_Category__c collateralCategoryObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                Sales_Agent__c 
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationObj = applicationList[0];
        List<User> userList = [SELECT Id 
                                FROM USER 
                                WHERE Contact.AccountId = : applicationObj.Sales_Agent__c 
                                AND Profile.Name = 'Sales Agent'];
        userObj = userList[0];

        List<clcommon__Collateral_Category__c> collateralCategoryList = [SELECT Id 
                                                                            FROM clcommon__Collateral_Category__c];

        for(clcommon__Collateral_Category__c collateralCategory : collateralCategoryList){
            collateralCategoryObj = collateralCategory;
        }
        requestMap.put('shouldValidate', String.valueOf(true));
        requestMap.put('potentialBuyerdetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        requestMap.put('cropInsuranceDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        requestMap.put('additionalCropDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingCountry\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        requestMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');
        requestMap.put('partyType', PortalConstants.SPOUSE_PARTY_NAME);
        
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveAdditionalInfoBatch insuranceAgentBatchObject = new PortalSaveAdditionalInfoBatch(requestMap);
            Database.executeBatch(insuranceAgentBatchObject,20);
            Test.stopTest();
        }
        List<clcommon__Party__c> partyList = [SELECT id, clcommon__Party_Types__c FROM clcommon__Party__c];
        System.assertEquals(true,partyList.size()==1,'Failure');
    }
}