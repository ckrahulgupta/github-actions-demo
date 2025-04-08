/**
 * @description       : Test class for ExternalApplicationInitiationAPI
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 02-25-2025
 * @last modified by  : Krishanu Chinya
**/
@IsTest
public with sharing class ExternalApplicationInitiationAPITest {
    @testSetup
    static void setup(){

        Map<String, clcommon__Legal_Entity__c> legalEntityMap = ExternalAPITestHelper.createMultipleLegalEntity();
        // Creating Legal Entity
        List<clcommon__Legal_Entity__c> legalEntityList = new List<clcommon__Legal_Entity__c>{
            legalEntityMap.get(ExternalConstants.INDIVIDUAL_ENTITY),
            legalEntityMap.get(ExternalConstants.SOLE_PROP_ENTITY),
            legalEntityMap.get(ExternalConstants.CORPORATION),
            legalEntityMap.get(ExternalConstants.LIMITED_LIABILITY_COMPANY),
            legalEntityMap.get(ExternalConstants.GENERAL_PARTNERSHIP),
            legalEntityMap.get(ExternalConstants.LIMITED_PARTNERSHIP),
            legalEntityMap.get(ExternalConstants.JOINT_VENTURE),
            legalEntityMap.get(ExternalConstants.TRUST)
        };
        Database.Insert(legalEntityList, true);

        clcommon__Party_Type__c borrowerPartyTypeObj = ExternalAPITestHelper.createPartyType('BORROWER');
        Database.insert(borrowerPartyTypeObj,true);

        //creating businessInfo
        genesis__Business_Information__c dealerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c solePropBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForBorrower();
        genesis__Business_Information__c corpBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForBorrower();
        corpBusinessInfoObj.genesis__Tax_Identification_Number__c = '122334559';
        Database.insert(new List<genesis__Business_Information__c>{solePropBusinessInfoObj,corpBusinessInfoObj,dealerBusinessInfoObj},true);

        Account dealerAccountObj = ExternalAPITestHelper.createDealerAccount(dealerBusinessInfoObj.id);
        dealerAccountObj.CIF_Number__c = '102555';
        dealerAccountObj.Enable_ERP_Id__c = true;
        dealerAccountObj.Unique_Id__c = 'testd001';

        Account anotherDealerAccountObj = ExternalAPITestHelper.createDealerAccount(dealerBusinessInfoObj.id);
        anotherDealerAccountObj.CIF_Number__c = '102666';
        anotherDealerAccountObj.Enable_ERP_Id__c = true;
        anotherDealerAccountObj.Unique_Id__c = 'testd002';

        Database.insert(new List<Account>{dealerAccountObj, anotherDealerAccountObj},true);


        Account clAccountObj = ExternalAPITestHelper.createCLAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        clAccountObj.ParentId = dealerAccountObj.Id;

        Account anotherClAccountObj = ExternalAPITestHelper.createCLAccount(dealerBusinessInfoObj.id,anotherDealerAccountObj.id);
        anotherClAccountObj.ParentId = anotherDealerAccountObj.Id;

        Account borrowerAccountObj = ExternalAPITestHelper.createSolePropAccount(legalEntityMap.get(ExternalConstants.SOLE_PROP_ENTITY), solePropBusinessInfoObj.Id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();

        Account corporationAccountObj = ExternalAPITestHelper.createCorporationAccount(legalEntityMap.get(ExternalConstants.CORPORATION), corpBusinessInfoObj.Id, dealerAccountObj.Id);

        Database.insert(new List<Account>{clAccountObj, borrowerAccountObj, anotherClAccountObj, corporationAccountObj},true);

        Contact clContactObj = ExternalAPITestHelper.createCLContact(clAccountObj.id);
        Contact anotherClContactObj = ExternalAPITestHelper.createCLContact(anotherClAccountObj.id);
        // Creating Contact for Borrower
        Contact borrowerContactObj = ExternalAPITestHelper.createBorrowerContact(borrowerAccountObj.Id);
        borrowerContactObj.genesis__SSN__c = '786354624';

        Contact corporationContactObj = ExternalAPITestHelper.createCorporationContact(corporationAccountObj.Id);

        Database.insert(new List<Contact>{clContactObj, anotherClContactObj, borrowerContactObj, corporationContactObj},true);


        User userObj = ExternalAPITestHelper.createCLUser(clContactObj.id);
        Database.insert(userObj,true);


        clcommon__Reciprocal_Role__c clRole = ExternalAPITestHelper.createCertifiedLenderRole();
        Database.insert(clRole,true);


        clcommon__Relationship__c clRelationship = ExternalAPITestHelper.createCLDealerRelationship(clRole,dealerAccountObj.Id,clAccountObj.id);
        clcommon__Relationship__c anotherClRelationship = ExternalAPITestHelper.createCLDealerRelationship(clRole,anotherDealerAccountObj.Id,anotherClAccountObj.id);
        Database.insert(new List<clcommon__Relationship__c>{clRelationship,anotherClRelationship},true);

        clcommon__CL_Product__c clProductObj = ExternalAPITestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        CFA_Configuration__c cifObj = ExternalAPITestHelper.createCIFNumber();
        Database.insert(cifObj,true);

        // Creating department for task
        genesis__Department__c departmentObj = ExternalAPITestHelper.createDepartment('Credit');
        Database.insert(departmentObj,true);

        Dealer_Applicant_Relationship__c applicantDealerRelObj = ExternalAPITestHelper.createApplicantDealerRelationship(borrowerAccountObj, borrowerContactObj, dealerAccountObj);
        Dealer_Applicant_Relationship__c corpAppDealerRelObj = ExternalAPITestHelper.createApplicantDealerRelationship(corporationAccountObj, corporationContactObj, dealerAccountObj);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{applicantDealerRelObj,corpAppDealerRelObj},true);
    }

    /**
    * @description : Method to get dealer applicant relationship
    * @author Suraj Kumar | 01-10-2025 
    * @param dealerAccountId 
    * @return List<Dealer_Applicant_Relationship__c> 
    **/
    private static List<Dealer_Applicant_Relationship__c> getDealerApplicantRelation(String dealerAccountId){
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList = [SELECT Id 
                                                                            FROM Dealer_Applicant_Relationship__c 
                                                                            WHERE Dealer__c = :dealerAccountId];
        return dealerApplicantRelList;
    }

    /**
    * @description : Method to get dealer Account
    * @author Suraj Kumar | 01-10-2025 
    * @param cifNumber 
    * @return Account 
    **/
    private static Account getDealerAccount(String cifNumber){
        List<Account> dealerAccountList = [SELECT Id 
                                                FROM Account 
                                                WHERE CIF_Number__c = :cifNumber 
                                                LIMIT 1];
        return dealerAccountList[0];
    }

    /**
    * @description : Method to get principal Account
    * @author Suraj Kumar | 01-10-2025 
    * @return Account 
    **/
    private static Account getPrincipalAccount(){
        List<Account> principalAccountList = [SELECT Id, 
                                                        RecordTypeId,
                                                        RecordType.Name
                                                    FROM Account 
                                                    WHERE Name = 'Jasmine Albin' 
                                                    LIMIT 1];
        return principalAccountList[0];
    }
    /**
    * @description : test iniate application for sole prop
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testForSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "someUniqueId","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com","ssn": "736453287","confirm_ssn": "736453287","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test iniate application for sole prop duplicate
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testForSolePropDuplicate(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "kzBagk","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com","ssn": "786354624","confirm_ssn": "786354624","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test iniate application for corporation
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testForCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {     "loan_amount": 100000 }, "borrower_details": {     "name": "James Farms Ltd.",     "entity_type": "Corporation",     "tin": "749385674",     "confirm_tin": "749385674",     "user_id": "someUniqueId" }, "principal_details": {         "user_id": "someUniqueIdP1",         "first_name": "Daniel",         "last_name": "James",         "email": "daniel.james@yopmail.com",         "confirm_email": "daniel.james@yopmail.com",          "ssn": "736453287",         "confirm_ssn": "736453287",          "phone_number": "7354637843",         "home_phone_number": "9984637475",         "work_phone_number": "9364527364"  } } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test iniate application for DBA
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testForDBA(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {     "loan_amount": 100000 }, "borrower_details": {     "name": "Daniel Enterprize",     "entity_type": "Individual(s) with DBA",     "user_id": "someUniqueId" }, "principal_details": {"user_id": "someUniqueIdP1","first_name": "Daniel","last_name": "James","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com", "ssn": "736453287","confirm_ssn": "736453287", "phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test iniate application for invalid legal entity
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testInvalidLegalEntity(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "someUniqueId","first_name": "James","last_name": "Daniel","entity_type": "Invalid Legal Entity","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com","ssn": "736453287","confirm_ssn": "736453287","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();

            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test iniate application for invalid loan amount
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testInvalidLoanAmount(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {"loan_amount": -100000},"borrower_details": {"user_id": "someUniqueId","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com","ssn": "736453287","confirm_ssn": "736453287","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test iniate application without phone number
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testWithoutPhoneNum(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "someUniqueId","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com","ssn": "736453287","confirm_ssn": "736453287"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test iniate application without Email
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testWithoutEmail(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "someUniqueId","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","ssn": "736453287","confirm_ssn": "736453287","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){

            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test iniate application for Email mismatch
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testEmailMismatch(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "someUniqueId","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","email": "daniel.james@yopmail.com","confirm_email": "daniel.james2001@yopmail.com","ssn": "736453287","confirm_ssn": "736453287","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){

            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test iniate application invalid ssn length
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testInvalidSSNLength(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "someUniqueId","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com","ssn": "736453873287","confirm_ssn": "736453287","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){

            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test iniate application for ssn mismatch
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testSSNMismatch(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "someUniqueId","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com","ssn": "736453287","confirm_ssn": "700053287","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){

            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test iniate application for invalid TIN length
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testInvalidTinLength(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {     "loan_amount": 100000 }, "borrower_details": {     "name": "James Farms Ltd.",     "entity_type": "Corporation",     "tin": "7493856876874",     "confirm_tin": "749385674",     "user_id": "someUniqueId" }, "principal_details": {         "user_id": "someUniqueId",         "first_name": "Daniel",         "last_name": "James",         "email": "daniel.james@yopmail.com",         "confirm_email": "daniel.james@yopmail.com",          "ssn": "736453287",         "confirm_ssn": "736453287",          "phone_number": "7354637843",         "home_phone_number": "9984637475",         "work_phone_number": "9364527364"  } } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){

            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test iniate application for tin mismatch
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testTinMismatch(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {     "loan_amount": 100000 }, "borrower_details": {     "name": "James Farms Ltd.",     "entity_type": "Corporation",     "tin": "749385674",     "confirm_tin": "749000674",     "user_id": "someUniqueId" }, "principal_details": {         "user_id": "someUniqueId",         "first_name": "Daniel",         "last_name": "James",         "email": "daniel.james@yopmail.com",         "confirm_email": "daniel.james@yopmail.com",          "ssn": "736453287",         "confirm_ssn": "736453287",          "phone_number": "7354637843",         "home_phone_number": "9984637475",         "work_phone_number": "9364527364"  } } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){

            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test iniate application for dealer cif missing
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    public static void testDealerCifMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "someUniqueId","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com","ssn": "736453287","confirm_ssn": "736453287","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test iniate application for invalid dealer cif
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    public static void testInvalidDealerCif(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "someUniqueId","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com","ssn": "736453287","confirm_ssn": "736453287","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '10255');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test iniate application for dealer token missing
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    public static void testDealerTokenMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "someUniqueId","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com","ssn": "736453287","confirm_ssn": "736453287","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test iniate application for invalid dealer token
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    public static void testInvalidDealerToken(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "someUniqueId","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com","ssn": "736453287","confirm_ssn": "736453287","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'test');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test iniate application without dealer details
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    public static void testMissingDealerDetails(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "someUniqueId","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com","ssn": "736453287","confirm_ssn": "736453287","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test Dealer applicant relationship for new borrower sole prop
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testDRForSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account dealerAccountObj = getDealerAccount('102555');
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList = getDealerApplicantRelation(dealerAccountObj.Id);

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "someUniqueId","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com","ssn": "736453287","confirm_ssn": "736453287","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            List<Dealer_Applicant_Relationship__c> dealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            System.assertEquals(dealerApplicantRelList.size()+1, dealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test Dealer applicant relationship for new borrower DBA
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testDRForDBA(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account dealerAccountObj = getDealerAccount('102555');
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList = getDealerApplicantRelation(dealerAccountObj.Id);

        String reqString = '{"application_details": {     "loan_amount": 100000 }, "borrower_details": {     "name": "Daniel Enterprize",     "entity_type": "Individual(s) with DBA",     "user_id": "someUniqueId" }, "principal_details": {"user_id": "someUniqueIdP1","first_name": "Daniel","last_name": "James","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com", "ssn": "736453287","confirm_ssn": "736453287", "phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            List<Dealer_Applicant_Relationship__c> dealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            System.assertEquals(dealerApplicantRelList.size()+2, dealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test Dealer applicant relationship for new borrower Corporation
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testDRForCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account dealerAccountObj = getDealerAccount('102555');
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList = getDealerApplicantRelation(dealerAccountObj.Id);

        String reqString = '{"application_details": {     "loan_amount": 100000 }, "borrower_details": {     "name": "James Farms Ltd.",     "entity_type": "Corporation",     "tin": "749385674",     "confirm_tin": "749385674",     "user_id": "someUniqueId" }, "principal_details": {         "user_id": "someUniqueIdP1",         "first_name": "Daniel",         "last_name": "James",         "email": "daniel.james@yopmail.com",         "confirm_email": "daniel.james@yopmail.com",          "ssn": "736453287",         "confirm_ssn": "736453287",          "phone_number": "7354637843",         "home_phone_number": "9984637475",         "work_phone_number": "9364527364"  } } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            List<Dealer_Applicant_Relationship__c> dealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            System.assertEquals(dealerApplicantRelList.size()+2, dealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test Dealer applicant relationship for existing borrower sole prop with same dealer
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testDRExistingSolePropSameDealer(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account dealerAccountObj = getDealerAccount('102555');
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList = getDealerApplicantRelation(dealerAccountObj.Id);

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "kzBagk","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com","ssn": "786354624","confirm_ssn": "786354624","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            List<Dealer_Applicant_Relationship__c> dealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            System.assertEquals(dealerApplicantRelList.size(), dealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

     /**
    * @description : Test Dealer applicant relationship for existing borrower sole prop with new dealer
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testDRExistingSolePropNewDealer(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account dealerAccountObj = getDealerAccount('102555');
        Account anotherDealerAccountObj = getDealerAccount('102666');
        List<Dealer_Applicant_Relationship__c> prevDealerRelList = getDealerApplicantRelation(dealerAccountObj.Id);

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "kzBagk","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com","ssn": "786354624","confirm_ssn": "786354624","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102666');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd002');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            List<Dealer_Applicant_Relationship__c> prevDealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            List<Dealer_Applicant_Relationship__c> newDealerRelUpdatedList = getDealerApplicantRelation(anotherDealerAccountObj.Id);
            System.assertEquals(prevDealerRelList.size(), prevDealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(1, newDealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test Dealer applicant relationship for existing borrower sole prop with new dealer with a new unique id
    * @author Krishanu Chinya | 02-25-2025 
    **/
    @isTest 
    private static void testDRExistingSolePropNewDealerNewUserId(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "newUserId","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com","ssn": "786354624","confirm_ssn": "786354624","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102666');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd002');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test Dealer applicant relationship for existing borrower Corporation same dealer
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testDRExistingCorporationSameDealer(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account dealerAccountObj = getDealerAccount('102555');
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList = getDealerApplicantRelation(dealerAccountObj.Id);

        String reqString = '{"application_details": {     "loan_amount": 100000 }, "borrower_details": {     "name": "James Farms Ltd.",     "entity_type": "Corporation",     "tin": "122334559",     "confirm_tin": "122334559",     "user_id": "someUniqueId" }, "principal_details": {         "user_id": "someUniqueIdP1",         "first_name": "Daniel",         "last_name": "James",         "email": "daniel.james@yopmail.com",         "confirm_email": "daniel.james@yopmail.com",          "ssn": "736453287",         "confirm_ssn": "736453287",          "phone_number": "7354637843",         "home_phone_number": "9984637475",         "work_phone_number": "9364527364"  } } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            List<Dealer_Applicant_Relationship__c> dealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            System.assertEquals(dealerApplicantRelList.size()+1, dealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test Dealer applicant relationship for existing borrower Corporation new dealer
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testDRExistingCorporationNewDealer(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account dealerAccountObj = getDealerAccount('102555');
        Account anotherDealerAccountObj = getDealerAccount('102666');
        List<Dealer_Applicant_Relationship__c> prevDealerRelList = getDealerApplicantRelation(dealerAccountObj.Id);

        String reqString = '{"application_details": {     "loan_amount": 100000 }, "borrower_details": {     "name": "James Farms Ltd.",     "entity_type": "Corporation",     "tin": "122334559",     "confirm_tin": "122334559",     "user_id": "someUniqueId" }, "principal_details": {         "user_id": "someUniqueIdP1",         "first_name": "Daniel",         "last_name": "James",         "email": "daniel.james@yopmail.com",         "confirm_email": "daniel.james@yopmail.com",          "ssn": "736453287",         "confirm_ssn": "736453287",          "phone_number": "7354637843",         "home_phone_number": "9984637475",         "work_phone_number": "9364527364"  } } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102666');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd002');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            List<Dealer_Applicant_Relationship__c> prevDealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            List<Dealer_Applicant_Relationship__c> newDealerRelUpdatedList = getDealerApplicantRelation(anotherDealerAccountObj.Id);
            System.assertEquals(2, newDealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(prevDealerRelList.size(), prevDealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test Dealer applicant relationship for borrower DBA with existing principal same dealer
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testDRExistingPrincipalSameDealerDBA(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account dealerAccountObj = getDealerAccount('102555');
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList = getDealerApplicantRelation(dealerAccountObj.Id);

        String reqString = '{"application_details": {     "loan_amount": 100000 }, "borrower_details": {     "name": "Daniel Enterprize",     "entity_type": "Individual(s) with DBA",     "user_id": "someUniqueId" }, "principal_details": {"user_id": "kzBagk","first_name": "Daniel","last_name": "James","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com", "ssn": "786354624","confirm_ssn": "786354624", "phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            List<Dealer_Applicant_Relationship__c> dealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            System.assertEquals(dealerApplicantRelList.size()+1, dealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test Dealer applicant relationship for borrower DBA with existing principal new dealer
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testDRExistingPrincipalNewDealerDBA(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account dealerAccountObj = getDealerAccount('102555');
        Account anotherDealerAccountObj = getDealerAccount('102666');
        List<Dealer_Applicant_Relationship__c> prevDealerRelList = getDealerApplicantRelation(dealerAccountObj.Id);

        String reqString = '{"application_details": {     "loan_amount": 100000 }, "borrower_details": {     "name": "Daniel Enterprize",     "entity_type": "Individual(s) with DBA",     "user_id": "someUniqueId" }, "principal_details": {"user_id": "kzBagk","first_name": "Daniel","last_name": "James","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com", "ssn": "786354624","confirm_ssn": "786354624", "phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102666');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd002');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            List<Dealer_Applicant_Relationship__c> prevDealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            List<Dealer_Applicant_Relationship__c> newDealerRelUpdatedList = getDealerApplicantRelation(anotherDealerAccountObj.Id);
            System.assertEquals(2, newDealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(prevDealerRelList.size(), prevDealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test Dealer applicant relationship for Corporation borrower with existing principal same dealer
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testDRExistingPrincipalSameDealerCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account dealerAccountObj = getDealerAccount('102555');
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList = getDealerApplicantRelation(dealerAccountObj.Id);

        String reqString = '{"application_details": {     "loan_amount": 100000 }, "borrower_details": {     "name": "James Farms Ltd.",     "entity_type": "Corporation",     "tin": "749385674",     "confirm_tin": "749385674",     "user_id": "someUniqueId" }, "principal_details": {         "user_id": "kzBagk",         "first_name": "Daniel",         "last_name": "James",         "email": "daniel.james@yopmail.com",         "confirm_email": "daniel.james@yopmail.com",          "ssn": "786354624",         "confirm_ssn": "786354624",          "phone_number": "7354637843",         "home_phone_number": "9984637475",         "work_phone_number": "9364527364"  } } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            List<Dealer_Applicant_Relationship__c> dealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            Account principalAccountObj = getPrincipalAccount();
            System.assertEquals('Grower', principalAccountObj.RecordType.Name, 'Assertion Failed');
            System.assertEquals(dealerApplicantRelList.size()+1, dealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test Dealer applicant relationship for Corporation borrower with existing principal new dealer
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testDRExistingPrincipalNewDealerCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account dealerAccountObj = getDealerAccount('102555');
        Account anotherDealerAccountObj = getDealerAccount('102666');
        List<Dealer_Applicant_Relationship__c> prevDealerRelList = getDealerApplicantRelation(dealerAccountObj.Id);

        String reqString = '{"application_details": {     "loan_amount": 100000 }, "borrower_details": {     "name": "James Farms Ltd.",     "entity_type": "Corporation",     "tin": "749385674",     "confirm_tin": "749385674",     "user_id": "someUniqueId" }, "principal_details": {         "user_id": "kzBagk",         "first_name": "Daniel",         "last_name": "James",         "email": "daniel.james@yopmail.com",         "confirm_email": "daniel.james@yopmail.com",          "ssn": "786354624",         "confirm_ssn": "786354624",          "phone_number": "7354637843",         "home_phone_number": "9984637475",         "work_phone_number": "9364527364"  } } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102666');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd002');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            List<Dealer_Applicant_Relationship__c> prevDealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            Account principalAccountObj = getPrincipalAccount();
            List<Dealer_Applicant_Relationship__c> newDealerRelUpdatedList = getDealerApplicantRelation(anotherDealerAccountObj.Id);
            System.assertEquals(2, newDealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals('Grower', principalAccountObj.RecordType.Name, 'Assertion Failed');
            System.assertEquals(prevDealerRelList.size(), prevDealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test Dealer applicant relationship for existing borrower which is principal in other application sole prop with same dealer
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testDRExistingPrincipalSameDealerSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account dealerAccountObj = getDealerAccount('102555');
        Account principalAccountObj = getPrincipalAccount();
        principalAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ExternalConstants.CO_APPLICATION_RECORD_TYPE).getRecordTypeId();
        Database.update(principalAccountObj,true);
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList = getDealerApplicantRelation(dealerAccountObj.Id);

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "kzBagk","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com","ssn": "786354624","confirm_ssn": "786354624","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            List<Dealer_Applicant_Relationship__c> dealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            List<Account> borrowerAccountList = [SELECT Id, RecordType.Name FROM Account WHERE Id = :principalAccountObj.Id LIMIT 1];
            System.assertEquals(dealerApplicantRelList.size(), dealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals('Grower', borrowerAccountList[0].RecordType.Name, 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test Dealer applicant relationship for existing borrower which is principal in other application sole prop with New dealer
    * @author Suraj Kumar | 12-05-2024 
    **/
    @isTest 
    private static void testDRExistingPrincipalNewDealerSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account dealerAccountObj = getDealerAccount('102555');
        Account anotherDealerAccountObj = getDealerAccount('102666');
        Account principalAccountObj = getPrincipalAccount();
        principalAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ExternalConstants.CO_APPLICATION_RECORD_TYPE).getRecordTypeId();
        Database.update(principalAccountObj,true);
        List<Dealer_Applicant_Relationship__c> prevDealerRelList = getDealerApplicantRelation(dealerAccountObj.Id);

        String reqString = '{"application_details": {"loan_amount": 100000},"borrower_details": {"user_id": "kzBagk","first_name": "James","last_name": "Daniel","entity_type": "Individual(s) - Sole Proprietorship","email": "daniel.james@yopmail.com","confirm_email": "daniel.james@yopmail.com","ssn": "786354624","confirm_ssn": "786354624","phone_number": "7354637843","home_phone_number": "9984637475","work_phone_number": "9364527364"}}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/applications';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102666');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd002');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationInitiationAPI.doInitiateNewApplication();
            List<Dealer_Applicant_Relationship__c> prevDealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            List<Account> borrowerAccountList = [SELECT Id, RecordType.Name FROM Account WHERE Id = :principalAccountObj.Id LIMIT 1];
            List<Dealer_Applicant_Relationship__c> newDealerRelUpdatedList = getDealerApplicantRelation(anotherDealerAccountObj.Id);
            System.assertEquals(1, newDealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(prevDealerRelList.size(), prevDealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals('Grower', borrowerAccountList[0].RecordType.Name, 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }
}