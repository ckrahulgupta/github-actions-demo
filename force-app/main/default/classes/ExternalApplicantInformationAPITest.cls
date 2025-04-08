/**
 * @description       : Test class for ExternalApplicantInformationAPI
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 04-02-2025
 * @last modified by  : Rakesh Saraf
**/
@IsTest
public with sharing class ExternalApplicantInformationAPITest {
    /**
    * @description : setup method for test data
    * @author Suraj Kumar | 12-10-2024 
    **/
    @TestSetup
    static void setup(){
        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj,borrowerBusinessInfoObj},true);

        // Creating Account for Dealer
        Account dealerAccountObj = ExternalAPITestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.CIF_Number__c = '102555';
        dealerAccountObj.Unique_Id__c = 'testd001';
        dealerAccountObj.Enable_ERP_Id__c = true;
        Database.insert(dealerAccountObj, true);

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

        // Creating Legal Entity for Borrower
        List<clcommon__Legal_Entity__c> solePropEntityList = [SELECT Id, Name FROM clcommon__Legal_Entity__c WHERE Name = 'Individual(s) - Sole Proprietorship'];

        // Creating Account for Certified Lender
        Account clAccountObj = ExternalAPITestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        // Creating Account for Borrower
        Account borrowerAccountObj = ExternalAPITestHelper.createSolePropAccount(solePropEntityList[0], borrowerBusinessInfoObj.Id);
        borrowerAccountObj.Unique_Id__c = 'test00085';

        Account coBorrowerAccObj = ExternalAPITestHelper.createSolePropAccount(solePropEntityList[0], borrowerBusinessInfoObj.Id);
        coBorrowerAccObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();

        Database.insert(new List<Account>{clAccountObj,borrowerAccountObj,coBorrowerAccObj}, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ExternalAPITestHelper.createCLContact(clAccountObj.Id);
        // Creating Contact for Borrower
        Contact borrowerContactObj = ExternalAPITestHelper.createBorrowerContact(borrowerAccountObj.Id);
        borrowerContactObj.MailingStreet = null;
        borrowerContactObj.MailingState = null;
        borrowerContactObj.MailingCity = null;
        borrowerContactObj.MailingPostalCode = null;
        borrowerContactObj.Mailing_County__c = null;
        borrowerContactObj.Birthdate = null;
        borrowerContactObj.clcommon__Marital_Status__c = null;

        Contact coBorrowerContactObj = ExternalAPITestHelper.createBorrowerContact(coBorrowerAccObj.Id);
        Database.insert(new List<contact>{clContactObj,borrowerContactObj,coBorrowerContactObj},true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ExternalAPITestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ExternalAPITestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating map for Application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'certifiedLender' =>  clAccountObj.Id
        };

        // Creating Application
        genesis__Applications__c applicationObj = ExternalAPITestHelper.createCurrCropYearApplication(paramForApplicationMap);
        Database.insert(applicationObj, true);

        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c principalPartyTypeObj = ExternalAPITestHelper.createPartyType('PRINCIPAL');
        Database.insert(new List<clcommon__Party_Type__c>{borrowerPartyTypeObj,principalPartyTypeObj},true);

        Map<String,Id> partyParamMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => borrowerPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(partyParamMap);

        // Creating Principal Party for current application
        Map<String,Id> paramForPrincipalPartyMap = new Map<String,Id>{
            'accountId' => coBorrowerAccObj.Id,
            'contactId' => coBorrowerContactObj.Id,
            'partyTypeId' => principalPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__Party__c principalPartyObj = ExternalAPITestHelper.createParty(paramForPrincipalPartyMap);
        principalPartyObj.Principal_Number__c = 1;

        Database.insert(new List<clcommon__Party__c>{partyObj,principalPartyObj},true);


        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ExternalAPITestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ExternalAPITestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);
    }

    /**
    * @description : Method to get application 
    * @author Suraj Kumar | 01-09-2025 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c getApplication(){
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Account__c,
                                                                genesis__Contact__c,
                                                                genesis__Account__r.Unique_Id__c
                                                            FROM genesis__Applications__c 
                                                            WHERE genesis__Loan_Number__c = '300023456'
                                                            LIMIT 1];
        return applicationList[0];
    }
    /**
    * @description : Method to get corporation legal entity
    * @author Suraj Kumar | 01-09-2025 
    * @return clcommon__Legal_Entity__c 
    **/
    private static clcommon__Legal_Entity__c getCorporationEntity(){
        List<clcommon__Legal_Entity__c> corpEntityList = [SELECT Id, 
                                                                    Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE Name = 'Corporation' 
                                                                LIMIT 1];
        return corpEntityList[0];
    }

    /**
    * @description : Method to get Borrower Account
    * @author Suraj Kumar | 01-09-2025 
    * @param applicationObj 
    * @return Account 
    **/
    private static Account getBorrowerAccount(genesis__Applications__c applicationObj){
        List<Account> borrowerAccountList = [SELECT Id, 
                                                        Name, 
                                                        clcommon__Legal_Entity_Type__c 
                                                    FROM Account    
                                                    WHERE Id =: applicationObj.genesis__Account__c];
        return borrowerAccountList[0];
    }

    /**
    * @description : Method to get borrower contact
    * @author Suraj Kumar | 01-09-2025 
    * @param applicationObj 
    * @return Contact 
    **/
    private static Contact getBorrowerContact(genesis__Applications__c applicationObj){
        List<Contact> borrowerContactList = [SELECT Id,
                                                        Name,
                                                        Email,
                                                        MobilePhone,
                                                        HomePhone,
                                                        Phone
                                                FROM Contact
                                                WHERE Id =: applicationObj.genesis__Contact__c];
        return borrowerContactList[0];
    }

    /**
    * @description : Method to get borrower party 
    * @author Suraj Kumar | 01-09-2025 
    * @param applicationObj 
    * @return List<clcommon__party__c> 
    **/
    private static List<clcommon__party__c> getBorrowerParty(genesis__Applications__c applicationObj){
        List<clcommon__party__c> borrowerPartyList = [SELECT Id,
                                                                Total_Assets__c,
                                                                Total_Liabilities__c,
                                                                Street__c,
                                                                City__c,
                                                                State__c,
                                                                Postal_Code__c,
                                                                County__c,
                                                                Mobile_Number__c,
                                                                Work_Number__c,
                                                                Home_Number__c,
                                                                Marital_Status__c,
                                                                Suffix__c
                                                            FROM clcommon__party__c
                                                            WHERE genesis__Application__c =: applicationObj.Id
                                                            AND clcommon__Type__r.Name =: ExternalConstants.BORROWER_PARTY];
        return borrowerPartyList;
    }

    /**
    * @description : Test method to test for sole prop
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testForSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            List<clcommon__party__c> borrowerPartyList = getBorrowerParty(applicationObj);
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            System.assertEquals(2346,borrowerPartyList[0].Total_Assets__c, 'Assertion Failed');
            System.assertEquals(2423433,borrowerPartyList[0].Total_Liabilities__c, 'Assertion Failed');
            System.assertEquals('256 Walls Street',borrowerPartyList[0].Street__c, 'Assertion Failed');
            System.assertEquals('Kansas',borrowerPartyList[0].City__c, 'Assertion Failed');
            System.assertEquals('IL',borrowerPartyList[0].State__c, 'Assertion Failed');
            System.assertEquals('10036',borrowerPartyList[0].Postal_Code__c, 'Assertion Failed');
            System.assertEquals('New York County',borrowerPartyList[0].County__c, 'Assertion Failed');
            System.assertEquals('7354637843',borrowerPartyList[0].Mobile_Number__c, 'Assertion Failed');
            System.assertEquals('9364527364',borrowerPartyList[0].Work_Number__c, 'Assertion Failed');
            System.assertEquals('9984637475',borrowerPartyList[0].Home_Number__c, 'Assertion Failed');
            System.assertEquals('Unmarried',borrowerPartyList[0].Marital_Status__c, 'Assertion Failed');
            System.assertEquals('Sr.',borrowerPartyList[0].Suffix__c, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for Corporation
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testForCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        Account borrowerAccountObj = getBorrowerAccount(applicationObj);
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = getCorporationEntity().Id;
        Database.update(borrowerAccountObj, true);

        String reqString = '{ "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 100000, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085", "street": "650 Capitol Mall",  "city": "Kansas",  "state": "IL",  "postal_code": "78364",  "county": "New York",  "email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com", "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "state_of_incorporation": "AZ", "total_assets": 1000000, "total_liabilities": 90000 } } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            List<clcommon__party__c> borrowerPartyList = getBorrowerParty(applicationObj);
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            System.assertEquals(2346,borrowerPartyList[0].Total_Assets__c, 'Assertion Failed');
            System.assertEquals(2423433,borrowerPartyList[0].Total_Liabilities__c, 'Assertion Failed');
            System.assertEquals('650 Capitol Mall',borrowerPartyList[0].Street__c, 'Assertion Failed');
            System.assertEquals('Kansas',borrowerPartyList[0].City__c, 'Assertion Failed');
            System.assertEquals('IL',borrowerPartyList[0].State__c, 'Assertion Failed');
            System.assertEquals('78364',borrowerPartyList[0].Postal_Code__c, 'Assertion Failed');
            System.assertEquals('New York',borrowerPartyList[0].County__c, 'Assertion Failed');
            System.assertEquals('7354637843',borrowerPartyList[0].Mobile_Number__c, 'Assertion Failed');
            System.assertEquals('9364527364',borrowerPartyList[0].Work_Number__c, 'Assertion Failed');
            System.assertEquals('9984637475',borrowerPartyList[0].Home_Number__c, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for DBA
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testForDBA(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Legal_Entity__c> dbaEntityList = [SELECT Id, Name FROM clcommon__Legal_Entity__c WHERE Name = 'Individual(s) with DBA'];
        Account borrowerAccountObj = getBorrowerAccount(applicationObj);
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = dbaEntityList[0].id;
        Database.update(borrowerAccountObj, true);

        String reqString = '{ "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 100000,  "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085"} } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for invalid user id
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testInvalidUserId(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00876085", "email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(401,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for invalid birthdate
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testInvalidBirthdate(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085", "email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-18-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for invalid postal code
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testInvalidPostalCode(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085", "email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10087636", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for invalid marital status
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testInvalidMaritalStatus(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085", "email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unknown", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for invalid state
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testInvalidState(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085", "email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "Bengal", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for invalid suffix
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testInvalidSuffix(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085", "email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Senior", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for total libalities missing
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testMissingTotalLiabilities(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085", "email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000}  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for total asset missing
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testMisisngTotalAssets(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085", "email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for invalid state of incorporation
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testInvalidSOI(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        Account borrowerAccountObj = getBorrowerAccount(applicationObj);
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = getCorporationEntity().Id;
        Database.update(borrowerAccountObj, true);

        String reqString = '{ "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 100000, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085", "street": "650 Capitol Mall",  "city": "Kansas",  "state": "IL",  "postal_code": "78364",  "county": "New York",  "email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com", "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "state_of_incorporation": "AZUS", "total_assets": 1000000, "total_liabilities": 90000 } } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for setting up the contact number
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testSetEmailAndNumbers(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        Contact borrowerContactObj = getBorrowerContact(applicationObj);
        borrowerContactObj.Email = null;
        borrowerContactObj.MobilePhone = null;
        borrowerContactObj.HomePhone = null;
        borrowerContactObj.Phone = null;
        Database.update(borrowerContactObj, true);

        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for app id invalid
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testInvalidAppId(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{  "application_details": {  "id": "", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }


    /**
    * @description : Test method to test for dealer cif missing
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testDealerCifMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for dealer cif invalid
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testInvalidDealerCif(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '1025');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for dealer token missing
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testDealerTokenMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for dealer token invalid
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testInvalidDealerToken(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for dealer detail missing
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testDealerDetailsMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for request body null
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testRequestBodyNull(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

     /**
    * @description : Test method to test for application detail missing
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testAppDetailMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "borrower_details": {  "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for Borrower detail missing
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testBorrowerDetailMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" }} ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for user id null
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testUserIdNull(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.Id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test not to throw exception if the email of the grower is missing
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testApplicantContactEmailMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        Contact borrowerContactObj = getBorrowerContact(applicationObj);
        borrowerContactObj.Email = null;
        Database.update(borrowerContactObj, true);
        
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085", "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for Invalid Email
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testInvalidEmail(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.Id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085","email": "daniel.jamesyopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for Email Confirm email mismatch
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testEmailMismatch(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.Id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "danieljames@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for birthdate missing for soleprop
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testMissingBirthDate(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.Id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for applicant contact number missing 
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testApplicantContactNumberMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__party__c> borrowerPartyList = getBorrowerParty(applicationObj);
        borrowerPartyList[0].Mobile_Number__c = null;
        borrowerPartyList[0].Work_Number__c = null;
        borrowerPartyList[0].Home_Number__c = null;
        Database.update(borrowerPartyList[0],true);

        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for existing phone number and request parameter does not have any phone number
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testApplicantHasExistingNumber(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__party__c> borrowerPartyList = getBorrowerParty(applicationObj);
        borrowerPartyList[0].Mobile_Number__c = '1234567890';
        Database.update(borrowerPartyList[0],true);

        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for marital status missing for sole prop
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testMaritalStatusMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085", "email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description ; Test method to test for Street missing
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testStreetMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085", "email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "suffix": "Sr.", "middle_name": "H.", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for City missing
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testCityMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085", "email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for state missing
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testStateMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

     /**
    * @description : Test method to test for postal code missing
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testPostalCodeMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

     /**
    * @description : Test method to test for county missing
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testCountyMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for total asset invalid
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testTotalAssetInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": -1000000, "total_liabilities": 90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : Test method to test for total libalities invalid
    * @author Suraj Kumar | 12-10-2024 
    **/
    @isTest 
    private static void testTotalLibalitiesInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{  "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 123456, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": -90000 }  } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test for state of incorporation missing
    * @author Suraj Kumar | 01-09-2025 
    **/
    @isTest 
    private static void testStateOfIncorporationMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        Account borrowerAccountObj = getBorrowerAccount(applicationObj);
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = getCorporationEntity().Id;
        Database.update(borrowerAccountObj, true);

        String reqString = '{ "application_details": {  "id": "'+applicationObj.id+'", "loan_amount": 100000, "internal_reference_code": "863HJU" },  "borrower_details": {  "user_id": "test00085", "street": "650 Capitol Mall",  "city": "Kansas",  "state": "IL",  "postal_code": "78364",  "county": "New York",  "email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com", "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "total_assets": 1000000, "total_liabilities": 90000 } } ';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveApplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicantInformationAPI.doSaveApplicantInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }
}