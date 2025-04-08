/**
 * @description       : Test class for ExternalCoapplicantInformationAPI
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 04-02-2025
 * @last modified by  : Rakesh Saraf
**/
@IsTest
public with sharing class ExternalCoapplicantInformationAPITest {
    /**
    * @description : setup method for test data
    * @author Suraj Kumar | 12-12-2024 
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

        Account anotherDealerAccountObj = ExternalAPITestHelper.createDealerAccount(dealerBusinessInfoObj.id);
        anotherDealerAccountObj.CIF_Number__c = '102666';
        anotherDealerAccountObj.Enable_ERP_Id__c = true;
        anotherDealerAccountObj.Unique_Id__c = 'testd002';

        Database.insert(new List<Account>{dealerAccountObj,anotherDealerAccountObj},true);

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

        Account anotherClAccountObj = ExternalAPITestHelper.createCLAccount(dealerBusinessInfoObj.id,anotherDealerAccountObj.id);
        anotherClAccountObj.ParentId = anotherDealerAccountObj.Id;

        Account borrowerAccountObj = ExternalAPITestHelper.createSolePropAccount(solePropEntityList[0], borrowerBusinessInfoObj.Id);
        borrowerAccountObj.Unique_Id__c = 'krishanu-test-001';

        Account coBorrowerAccObj = ExternalAPITestHelper.createSolePropAccount(solePropEntityList[0], borrowerBusinessInfoObj.Id);
        coBorrowerAccObj.Unique_Id__c = 'testclass-principal001';
        coBorrowerAccObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();

        Account existingCoAppAccount = ExternalAPITestHelper.createSolePropAccount(solePropEntityList[0], borrowerBusinessInfoObj.Id);
        existingCoAppAccount.Unique_Id__c = 'testclass-principal0011';
        existingCoAppAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        
        Database.insert(new List<Account>{clAccountObj,anotherClAccountObj,borrowerAccountObj,coBorrowerAccObj,existingCoAppAccount},true);


        // Creating Contact for Certified Lender
        Contact clContactObj = ExternalAPITestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = ExternalAPITestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Contact coBorrowerContactObj = ExternalAPITestHelper.createBorrowerContact(coBorrowerAccObj.Id);

        Contact existingCoAppContact = ExternalAPITestHelper.createBorrowerContact(existingCoAppAccount.Id);
        existingCoAppContact.genesis__SSN__c = '764253426';

        Contact anotherClContactObj = ExternalAPITestHelper.createCLContact(anotherClAccountObj.id);
        Database.insert(new List<Contact>{clContactObj,borrowerContactObj,coBorrowerContactObj,existingCoAppContact,anotherClContactObj},true);

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
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(partyParamMap);

        Map<String,Id> paramForPrincipalPartyMap = new Map<String,Id>{
            'accountId' => coBorrowerAccObj.Id,
            'contactId' => coBorrowerContactObj.Id,
            'partyTypeId' => principalPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__Party__c principalPartyObj = ExternalAPITestHelper.createParty(paramForPrincipalPartyMap);
        principalPartyObj.Principal_Number__c = 1;

        Database.insert(new List<clcommon__Party__c>{borrowerPartyObj,principalPartyObj},true);


        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ExternalAPITestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ExternalAPITestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        clcommon__Relationship__c anotherClRelationship = ExternalAPITestHelper.createCLDealerRelationship(roleObj,anotherDealerAccountObj.Id,anotherClAccountObj.id);
        Database.insert(new List<clcommon__Relationship__c>{clDealerRelationshipObj,anotherClRelationship}, true);

        CFA_Configuration__c cifObj = ApplicationOriginationTestHelper.createCIFNumber();
        Database.insert(cifObj,true);

        //creating applicant dealer relationship
        Dealer_Applicant_Relationship__c applicantDealerRelObj = ExternalAPITestHelper.createApplicantDealerRelationship(existingCoAppAccount, existingCoAppContact, dealerAccountObj);
        Database.insert(applicantDealerRelObj,true);
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
    * @description : Method to get application
    * @author Suraj Kumar | 01-10-2025 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c getApplication(){
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                    genesis__Account__c,
                                                                    genesis__Account__r.Unique_Id__c
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Number__c = '300023456'
                                                                LIMIT 1];
        return applicationList[0];
    }

    /**
    * @description : Method to get legal entity 
    * @author Suraj Kumar | 01-10-2025 
    * @param legalEntityName 
    * @return clcommon__Legal_Entity__c 
    **/
    private static clcommon__Legal_Entity__c getLegalEntity(String legalEntityName){
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id, 
                                                                    Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE Name = :legalEntityName];
        return legalEntityList[0];
    }

    /**
    * @description : Method to get Borrower Account
    * @author Suraj Kumar | 01-09-2025 
    * @param uniqueId 
    * @return Account 
    **/
    private static Account getBorrowerAccount(String uniqueId){
        List<Account> borrowerAccountList = [SELECT Id, 
                                                        Name, 
                                                        clcommon__Legal_Entity_Type__c,
                                                        RecordTypeId
                                                    FROM Account    
                                                    WHERE Unique_Id__c = :uniqueId];
        return borrowerAccountList[0];
    }

    /**
    * @description : Method to get principal contact
    * @author Suraj Kumar | 01-10-2025 
    * @param accountUniqueId 
    * @return Contact 
    **/
    private static Contact getPrincipalContact(String accountUniqueId){
        List<Contact> principalContactList = [SELECT Id, 
                                                        Name,
                                                        Phone,
                                                        MobilePhone, 
                                                        HomePhone,
                                                        Email,
                                                        Birthdate
                                                    FROM Contact 
                                                    WHERE Account.Unique_Id__c = :accountUniqueId];
        return principalContactList[0];
    }



    /**
    * @description : test method to test for sole prop
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testForSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account dealerAccountObj = getDealerAccount('102555');
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList = getDealerApplicantRelation(dealerAccountObj.Id);
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},"borrower_details":{"user_id": "krishanu-test-001"},  "principal_details": [{  "user_id": "test00012","first_name": "Ashley", "last_name": "Rowley", "email": "ashley.rowley@yopmail.com",  "confirm_email": "ashley.rowley@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00013","first_name": "Bella", "last_name": "Abott", "email": "bella.abott@yopmail.com",  "confirm_email": "bella.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00014","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            List<Dealer_Applicant_Relationship__c> dealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            System.assertEquals(dealerApplicantRelList.size()+3, dealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : adding duplicate account for sole prop 
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testForSolePropDuplicate(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},"borrower_details":{"user_id": "krishanu-test-001"},  "principal_details": [{  "user_id": "test00012","first_name": "Ashley", "last_name": "Rowley", "email": "ashley.rowley@yopmail.com",  "confirm_email": "ashley.rowley@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00013","first_name": "Bella", "last_name": "Abott", "email": "bella.abott@yopmail.com",  "confirm_email": "bella.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "testclass-principal0011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "764253426","confirm_ssn": "764253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test method to test for DBA
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testForDBA(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account dealerAccountObj = getDealerAccount('102555');
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList = getDealerApplicantRelation(dealerAccountObj.Id);
        genesis__Applications__c applicationObj = getApplication();
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntity('Individual(s) with DBA');
        Account borrowerAccount = getBorrowerAccount('krishanu-test-001');
        borrowerAccount.clcommon__Legal_Entity_Type__c = legalEntityObj.id;
        Database.update(borrowerAccount, true);

        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},"borrower_details":{"user_id": "krishanu-test-001"},  "principal_details": [{  "user_id": "testclass-principal001","first_name": "Ashley", "last_name": "Rowley", "email": "ashley.rowley@yopmail.com",  "confirm_email": "ashley.rowley@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576832","confirm_ssn": "748576832","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00013","first_name": "Bella", "last_name": "Abott", "email": "bella.abott@yopmail.com",  "confirm_email": "bella.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576139","confirm_ssn": "748576139","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00014","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "148576839","confirm_ssn": "148576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            List<Dealer_Applicant_Relationship__c> dealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            System.assertEquals(dealerApplicantRelList.size()+2, dealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test method to test for Corporation
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testForCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account dealerAccountObj = getDealerAccount('102555');
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList = getDealerApplicantRelation(dealerAccountObj.Id);
        genesis__Applications__c applicationObj = getApplication();
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntity('Corporation');
        Account borrowerAccount = getBorrowerAccount('krishanu-test-001');
        borrowerAccount.clcommon__Legal_Entity_Type__c = legalEntityObj.id;
        Database.update(borrowerAccount, true);

        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},"borrower_details":{"user_id": "krishanu-test-001"},  "principal_details": [{  "user_id": "testclass-principal001","first_name": "Ashley", "last_name": "Rowley", "email": "ashley.rowley@yopmail.com",  "confirm_email": "ashley.rowley@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576832","confirm_ssn": "748576832","title" : "President","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00013","first_name": "Bella", "last_name": "Abott", "email": "bella.abott@yopmail.com",  "confirm_email": "bella.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576139","confirm_ssn": "748576139","title" : "President","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00014","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "148576839","confirm_ssn": "148576839","title" : "President","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            List<Dealer_Applicant_Relationship__c> dealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            System.assertEquals(dealerApplicantRelList.size()+2, dealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test for applicant all three number missing
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testForApplicantContactNumberMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntity('Individual(s) with DBA');
        Account borrowerAccount = getBorrowerAccount('krishanu-test-001');
        borrowerAccount.clcommon__Legal_Entity_Type__c = legalEntityObj.id;
        Database.update(borrowerAccount, true);

        Contact principalContactObj = getPrincipalContact('testclass-principal001');
        principalContactObj.Phone = null;
        principalContactObj.MobilePhone = null;
        principalContactObj.HomePhone = null;
        principalContactObj.Email = null;
        Database.update(principalContactObj, true);

        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},"borrower_details":{"user_id": "krishanu-test-001"},  "principal_details": [{  "user_id": "testclass-principal001","first_name": "Ashley", "last_name": "Rowley", "email": "ashley.rowley@yopmail.com",  "confirm_email": "ashley.rowley@yopmail.com", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00013","first_name": "Bella", "last_name": "Abott", "email": "bella.abott@yopmail.com",  "confirm_email": "bella.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00014","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test method for DBA without providing first principal detail
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testFirstPrincipalMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntity('Individual(s) with DBA');
        Account borrowerAccount = getBorrowerAccount('krishanu-test-001');
        borrowerAccount.clcommon__Legal_Entity_Type__c = legalEntityObj.id;
        Database.update(borrowerAccount, true);

        Contact principalContactObj = getPrincipalContact('testclass-principal001');
        principalContactObj.Email = null;
        principalContactObj.Phone = null;
        principalContactObj.MobilePhone = null;
        Database.update(principalContactObj, true);

        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},"borrower_details":{"user_id": "krishanu-test-001"},  "principal_details": [{  "user_id": "principal_missing","first_name": "Ashley", "last_name": "Rowley", "email": "ashley.rowley@yopmail.com",  "confirm_email": "ashley.rowley@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00013","first_name": "Bella", "last_name": "Abott", "email": "bella.abott@yopmail.com",  "confirm_email": "bella.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00014","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test method to request body null
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testMissingRequest(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test method for user not authorized
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testUnauthorisedAccess(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},"borrower_details":{"user_id": "usyafgiwfgwefw"},  "principal_details": [{  "user_id": "test00012","first_name": "Ashley", "last_name": "Rowley", "email": "ashley.rowley@yopmail.com",  "confirm_email": "ashley.rowley@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00013","first_name": "Bella", "last_name": "Abott", "email": "bella.abott@yopmail.com",  "confirm_email": "bella.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00014","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(401,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test method for invalid title
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testInvalidTitle(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntity('Individual(s) with DBA');
        Account borrowerAccount = getBorrowerAccount('krishanu-test-001');
        borrowerAccount.clcommon__Legal_Entity_Type__c = legalEntityObj.id;
        Database.update(borrowerAccount, true);

        Contact principalContactObj = getPrincipalContact('testclass-principal001');
        principalContactObj.Email = null;
        principalContactObj.Phone = null;
        principalContactObj.MobilePhone = null;
        Database.update(principalContactObj, true);

        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},"borrower_details":{"user_id": "krishanu-test-001"},  "principal_details": [{  "user_id": "testclass-principal001","first_name": "Ashley", "last_name": "Rowley", "email": "ashley.rowley@yopmail.com",  "confirm_email": "ashley.rowley@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "invalid","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00013","first_name": "Bella", "last_name": "Abott", "email": "bella.abott@yopmail.com",  "confirm_email": "bella.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00014","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test method for dealer cif missing
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testDealerCifMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},"borrower_details":{"user_id": "krishanu-test-001"},  "principal_details": [{  "user_id": "test00012","first_name": "Ashley", "last_name": "Rowley", "email": "ashley.rowley@yopmail.com",  "confirm_email": "ashley.rowley@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00013","first_name": "Bella", "last_name": "Abott", "email": "bella.abott@yopmail.com",  "confirm_email": "bella.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00014","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test method for invalid dealer cif
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testInvalidDealerCif(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},"borrower_details":{"user_id": "krishanu-test-001"},  "principal_details": [{  "user_id": "test00012","first_name": "Ashley", "last_name": "Rowley", "email": "ashley.rowley@yopmail.com",  "confirm_email": "ashley.rowley@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00013","first_name": "Bella", "last_name": "Abott", "email": "bella.abott@yopmail.com",  "confirm_email": "bella.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00014","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '1025');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test method for dealer token missing
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testDealerTokenMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},"borrower_details":{"user_id": "krishanu-test-001"},  "principal_details": [{  "user_id": "test00012","first_name": "Ashley", "last_name": "Rowley", "email": "ashley.rowley@yopmail.com",  "confirm_email": "ashley.rowley@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00013","first_name": "Bella", "last_name": "Abott", "email": "bella.abott@yopmail.com",  "confirm_email": "bella.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00014","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test method for invalid dealer token
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testInvalidDealerToken(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},"borrower_details":{"user_id": "krishanu-test-001"},  "principal_details": [{  "user_id": "test00012","first_name": "Ashley", "last_name": "Rowley", "email": "ashley.rowley@yopmail.com",  "confirm_email": "ashley.rowley@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00013","first_name": "Bella", "last_name": "Abott", "email": "bella.abott@yopmail.com",  "confirm_email": "bella.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 },{  "user_id": "test00014","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd00121');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test method for adding duplicate principal for same dealer
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testDuplicatePrincipalSameDealer(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account dealerAccountObj = getDealerAccount('102555');
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList = getDealerApplicantRelation(dealerAccountObj.Id);
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},"borrower_details":{"user_id": "krishanu-test-001"},  "principal_details": [{  "user_id": "testclass-principal0011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "764253426","confirm_ssn": "764253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            List<Dealer_Applicant_Relationship__c> dealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            System.assertEquals(dealerApplicantRelList.size(), dealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test method for adding duplicate principal for new dealer
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testDuplicatePrincipalNewDealer(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account anotherDealerAccountObj = getDealerAccount('102666');
        Account dealerAccountObj = getDealerAccount('102555');
        List<Dealer_Applicant_Relationship__c> anotherDealerRelList = getDealerApplicantRelation(dealerAccountObj.Id);
        anotherDealerRelList[0].Dealer__c = anotherDealerAccountObj.Id;
        Database.update(anotherDealerRelList,true);

        Contact principalContactObj = getPrincipalContact('testclass-principal0011');
        principalContactObj.Birthdate = null;
        Database.update(principalContactObj,true);

        List<Dealer_Applicant_Relationship__c> currDealerRelList = getDealerApplicantRelation(dealerAccountObj.Id);
        genesis__Applications__c applicationObj = getApplication();

        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},"borrower_details":{"user_id": "krishanu-test-001"},  "principal_details": [{  "user_id": "testclass-principal0011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "764253426","confirm_ssn": "764253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            List<Dealer_Applicant_Relationship__c> currDealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            System.assertEquals(currDealerRelList.size()+1, currDealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test method for adding duplicate principal, which is borrower in other application for same dealer 
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testExistingBorrowerSameDealer(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account dealerAccountObj = getDealerAccount('102555');
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList = getDealerApplicantRelation(dealerAccountObj.Id);
        genesis__Applications__c applicationObj = getApplication();

        Account existingAccObj = getBorrowerAccount('testclass-principal0011');
        existingAccObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.update(existingAccObj,true);
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},"borrower_details":{"user_id": "krishanu-test-001"},  "principal_details": [{  "user_id": "testclass-principal0011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "764253426","confirm_ssn": "764253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);

        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            List<Dealer_Applicant_Relationship__c> dealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            List<Account> principalAccountList = [SELECT Id, RecordType.Name FROM Account WHERE Id = :existingAccObj.Id LIMIT 1];
            System.assertEquals('Grower', principalAccountList[0].RecordType.Name, 'Assertion Failed');
            System.assertEquals(dealerApplicantRelList.size(), dealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test method for adding duplicate principal, which is borrower in other application for new dealer
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testExistingBorrowerNewDealer(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account anotherDealerAccountObj = getDealerAccount('102666');
        Account dealerAccountObj = getDealerAccount('102555');
        List<Dealer_Applicant_Relationship__c> anotherDealerRelList = getDealerApplicantRelation(dealerAccountObj.Id);
        anotherDealerRelList[0].Dealer__c = anotherDealerAccountObj.Id;
        Database.update(anotherDealerRelList,true);

        List<Dealer_Applicant_Relationship__c> currDealerRelList = getDealerApplicantRelation(dealerAccountObj.Id);
        genesis__Applications__c applicationObj = getApplication();

        Account existingAccObj = getBorrowerAccount('testclass-principal0011');
        existingAccObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.update(existingAccObj,true);
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},"borrower_details":{"user_id": "krishanu-test-001"},  "principal_details": [{  "user_id": "testclass-principal0011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "764253426","confirm_ssn": "764253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            List<Dealer_Applicant_Relationship__c> currDealerRelUpdatedList = getDealerApplicantRelation(dealerAccountObj.Id);
            List<Account> principalAccountList = [SELECT Id, RecordType.Name FROM Account WHERE Id = :existingAccObj.Id LIMIT 1];
            System.assertEquals('Grower', principalAccountList[0].RecordType.Name, 'Assertion Failed');
            System.assertEquals(currDealerRelList.size()+1, currDealerRelUpdatedList.size(), 'Assertion Failed');
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }


     /**
    * @description : test application detail missing
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testAppDetailMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '"borrower_details":{"user_id": "krishanu-test-001"},  "principal_details": [{  "user_id": "test00012","first_name": "Ashley", "last_name": "Rowley", "email": "ashley.rowley@yopmail.com",  "confirm_email": "ashley.rowley@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "748576839","confirm_ssn": "748576839","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test Borrower detail missing detail missing
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testBorrowerDetailMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},  "principal_details": [{  "user_id": "test00014","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "764253426","confirm_ssn": "764253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test Application id invalid
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testAppIdInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{"application_details": {  "id": ""},  "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "test00014","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "764253426","confirm_ssn": "764253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test user id null
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testUserIdNull(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},   "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "764253426","confirm_ssn": "764253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test not throwing error if principal email missing 
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testEmailMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},   "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "test091011","first_name": "Joe", "last_name": "Abott",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "124253426","confirm_ssn": "124253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(201,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }


     /**
    * @description : test principal email miss match
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testEmailMismatch(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},   "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "test091011","first_name": "Joe", "last_name": "Abott", "email": "joeabott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "ssn": "124253426","confirm_ssn": "124253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test principal Birthdate missing
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testBirthdateMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},   "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "test091011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364",  "ssn": "124253426","confirm_ssn": "124253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test principal Birthdate invalid
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testBirthdateInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},   "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "test091011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com", "birthdate": "1999-08-181",  "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364",  "ssn": "124253426","confirm_ssn": "124253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test principal Marital status invalid
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testMaritalStatusInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},   "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "test091011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com", "birthdate": "1999-08-18",  "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364",  "ssn": "124253426","confirm_ssn": "124253426","title" : "Co-Applicant","marital_status": "Unmarrieddd", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

     /**
    * @description : test principal Marital status missing
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testMaritalStatusMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},   "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "test091011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com", "birthdate": "1999-08-18",  "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364",  "ssn": "124253426","confirm_ssn": "124253426","title" : "Co-Applicant", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test principal Street missing
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testStreetMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},   "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "test091011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com", "birthdate": "1999-08-18",  "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364",  "ssn": "124253426","confirm_ssn": "124253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test principal State missing
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testStateMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},   "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "test091011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com", "birthdate": "1999-08-18",  "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364",  "ssn": "124253426","confirm_ssn": "124253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas",  "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test principal City missing
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testCityMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},   "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "test091011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com", "birthdate": "1999-08-18",  "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364",  "ssn": "124253426","confirm_ssn": "124253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : test principal County missing
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testCountyMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},   "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "test091011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com", "birthdate": "1999-08-18",  "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364",  "ssn": "124253426","confirm_ssn": "124253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test principal Postal code missing
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testPostalCodeMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},   "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "test091011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com", "birthdate": "1999-08-18",  "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364",  "ssn": "124253426","confirm_ssn": "124253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : test principal postal code invalid
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testPostalCodeInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},   "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "test091011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com", "birthdate": "1999-08-18",  "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364",  "ssn": "124253426","confirm_ssn": "124253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "100136", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : test principal total asset missing
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testTotalAssetMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},   "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "test091011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com", "birthdate": "1999-08-18",  "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364",  "ssn": "124253426","confirm_ssn": "124253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : test principal total asset invalid
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testTotalAssetInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},   "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "test091011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com", "birthdate": "1999-08-18",  "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364",  "ssn": "124253426","confirm_ssn": "124253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": -1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : test principal total libalities missing
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testTotalLibalitiesMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},   "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "test091011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com", "birthdate": "1999-08-18",  "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364",  "ssn": "124253426","confirm_ssn": "124253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000}]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : test principal total libalities invalid
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testTotalLibalitiesInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},   "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "test091011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com", "birthdate": "1999-08-18",  "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364",  "ssn": "124253426","confirm_ssn": "124253426","title" : "Co-Applicant","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": -90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : test principal titleinvalid
    * @author Suraj Kumar | 12-12-2024 
    **/
    @isTest 
    private static void testTitleInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        String reqString = '{"application_details": {  "id": "'+applicationObj.id+'"},   "borrower_details":{"user_id": "krishanu-test-001"}, "principal_details": [{  "user_id": "test091011","first_name": "Joe", "last_name": "Abott", "email": "joe.abott@yopmail.com",  "confirm_email": "joe.abott@yopmail.com", "birthdate": "1999-08-18",  "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364",  "ssn": "124253426","confirm_ssn": "124253426","title" : "Co-Applicantahaja","marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }]  }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/v1/external/saveCoapplicantInformation';
        req.httpMethod = 'POST';
        req.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        req.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        req.requestBody = Blob.valueOf(reqString);
        RestContext.request = req;
        RestContext.response = res;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalCoapplicantInformationAPI.doSaveCoapplicantsInformation();
            System.assertEquals(403,res.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }
}