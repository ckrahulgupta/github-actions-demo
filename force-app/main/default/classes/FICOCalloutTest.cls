/**
 * @description       : Test Class for FICOCallout
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : Ayan Bhowmik
**/
@isTest
private class FICOCalloutTest {  
@testSetup
    static void setup(){
        // Creating sole-prop, corporation, dba legal entities
        clcommon__Legal_Entity__c solePropLegalEntityObj  = FICOCalloutTestHelper.createSolePropLegalEntity();
        clcommon__Legal_Entity__c corpLegalEntityObj  = FICOCalloutTestHelper.createCorporationLegalEntity();
        clcommon__Legal_Entity__c dbaLegalEntityObj  = FICOCalloutTestHelper.createDBALegalEntity();
        Database.insert(new List<clcommon__Legal_Entity__c>{solePropLegalEntityObj, corpLegalEntityObj, dbaLegalEntityObj}, true);

        // Creating cl product
        clcommon__CL_Product__c clProductObj = FICOCalloutTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        // Creating cl purpose
        clcommon__CL_Purpose__c  clPurposeObj = FICOCalloutTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj,true);

        // Creating CL, Borrower, Principal, Dealer Party Types
        clcommon__Party_Type__c clPartyTypeObj = FICOCalloutTestHelper.createPartyType('CERTIFIED LENDER');
        clcommon__Party_Type__c borrowerPartyTypeObj = FICOCalloutTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c principalPartyTypeObj = FICOCalloutTestHelper.createPartyType('PRINCIPAL');
        clcommon__Party_Type__c dealerPartyTypeObj = FICOCalloutTestHelper.createPartyType('DEALER');
        Database.insert(new List<clcommon__Party_Type__c>{clPartyTypeObj, borrowerPartyTypeObj, principalPartyTypeObj, dealerPartyTypeObj}, true);

        // Creating Dealer, Borrower Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = FICOCalloutTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = FICOCalloutTestHelper.createBusinessInfoForBorrower();
        borrowerBusinessInfoObj.genesis__Tax_Identification_Number__c = '888999000';
        genesis__Business_Information__c coBorrowerBusinessInfoObj = FICOCalloutTestHelper.createBusinessInfoForBorrower();
        coBorrowerBusinessInfoObj.genesis__Tax_Identification_Number__c = '';
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj, borrowerBusinessInfoObj, coBorrowerBusinessInfoObj}, true);

        // Creating dealer, CL, Borrower, Coapplicant Account
        Account dealerAccountObj = FICOCalloutTestHelper.createDealerAccount(dealerBusinessInfoObj.id);        
        Account clAccountObj = FICOCalloutTestHelper.createCLAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Account borrowerAccountObj = FICOCalloutTestHelper.createSolePropAccount(solePropLegalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        borrowerAccountObj.BillingStreet = '12th Road';
        borrowerAccountObj.CIF_Number__c = '123456';
        borrowerAccountObj.SBSS70_Score__c = '489';
        borrowerAccountObj.Score_1__c = '489';
        borrowerAccountObj.FICO_Recorded_On__c = Date.newInstance(2023, 04, 01);
        Account coBorrowerAccountObj = FICOCalloutTestHelper.createCoBorrowerAccount(solePropLegalEntityObj,coBorrowerBusinessInfoObj.id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        coBorrowerAccountObj.FICO_Recorded_On__c = Date.newInstance(2023, 04, 01);
        coBorrowerAccountObj.SBSS70_Score__c = '200';
        coBorrowerAccountObj.Score_1__c = '200';
        Database.insert(new List<Account>{dealerAccountObj, clAccountObj, borrowerAccountObj, coBorrowerAccountObj},true);
        
        // Creating CL, Borrower, Coapplicant Contact
        Contact clContactObj = FICOCalloutTestHelper.createCLContact(clAccountObj.id);
        Contact borrowerContactObj = FICOCalloutTestHelper.createBorrowerContact(borrowerAccountObj.id);
        borrowerContactObj.genesis__SSN__c = '324242424';
        borrowerContactObj.Confirm_SSN__c = '324242424';
        Contact coBorrowerContactObj = FICOCalloutTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        coBorrowerContactObj.genesis__SSN__c = '666714588';
        coBorrowerContactObj.Confirm_SSN__c = '666714588';
        Database.insert(new List<Contact>{clContactObj, borrowerContactObj, coBorrowerContactObj},true);

        // Creating CL User
        User clUser = FICOCalloutTestHelper.createCLUser(clContactObj.Id);
        Database.insert(clUser, true);

        // Creating Application
        Map<String,Id> applicationDataMap = new Map<String,Id>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'saAccountObjId' => null
        };
        genesis__Applications__c applicationObj = FICOCalloutTestHelper.createApplication(applicationDataMap);
        applicationObj.genesis__Product_Type__c ='Package';
        applicationObj.genesis__Loan_Amount__c = 824001;
        Database.insert(applicationObj,true); 

        // Creating Borrower Party
        Map<String,Id> partyParamMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => borrowerPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c partyObj = FICOCalloutTestHelper.createParty(partyParamMap, borrowerAccountObj);
        partyObj.clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;
        Database.insert(partyObj,true);

        Map<String,Id> coPartyParamMap = new Map<String,Id>{
            'accountId' => coBorrowerAccountObj.Id,
            'contactId' => coBorrowerContactObj.Id,
            'partyTypeId' => principalPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__Party__c coPartyObj = FICOCalloutTestHelper.createParty(coPartyParamMap, coBorrowerAccountObj);
        coPartyObj.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;
        Database.insert(coPartyObj,true);

        intframework__Integration_Family__c integrationFamily = IntegrationTestInitHelper.getFamily('FICO');
        System.assert(integrationFamily!=null,'No Integration Family was set.');
        intframework__Integration_API_Type__c integrationAPIType = IntegrationTestInitHelper.getIntegrationAPIType(integrationFamily.Id,'Credit Score');
        System.assert(integrationAPIType!=null,'No Integration API Type was set.');
        intframework__Integration_Provider__c integrationProvider = IntegrationTestInitHelper.getIntegrationProvider(integrationFamily.Id,'FICO Score');
        System.assert(integrationProvider!=null,'No Integration Provider was set.');
        intframework__Integration_Configuration__c integrationConfig = IntegrationTestInitHelper.getIntegrationConfiguration(integrationProvider.Id, 'FICO score configuration','FICO');
        System.assert(integrationConfig!=null,'No Integration Configuration was set.');
        intframework__Integration_API_Configuration__c integrationAPIConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            integrationFamily.Id,
            integrationAPIType.Id,
            integrationProvider.Id,
            integrationConfig.Id,
            false,
            'FICOAdapter',
            'POST',
            'FICO',
            'liquidcredit/',
            '{"thirdPartySystem": {"dynamicDataParameters": [],"filters": [{"fields": [{"externalField": "Id","fieldAPI": "Id"},{"externalField": "Networth","fieldAPI": "Net_Worth__c"},{"externalField": "AccountId","fieldAPI": "clcommon__Account__r.id"},{"externalField": "ContactId","fieldAPI": "clcommon__Contact__r.id"},{"externalField": "borrowerContactSSN","fieldAPI": "clcommon__Contact__r.genesis__SSN__c"},{"externalField": "Street","fieldAPI": "Street__c"},{"externalField": "City","fieldAPI": "City__c"},{"externalField": "State","fieldAPI": "State__c"},{"externalField": "PostalCode","fieldAPI": "Postal_Code__c"},{"externalField": "LegalEntity","fieldAPI": "clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name"},{"externalField": "Name","fieldAPI": "clcommon__Account__r.Name"},{"externalField": "Phone","fieldAPI": "Mobile_Number__c"},{"externalField": "PrincipalNumber","fieldAPI": "Principal_Number__c"},{"externalField": "BusinessInfoNetworth","fieldAPI": "clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c"},{"externalField": "TaxIDNumber","fieldAPI": "clcommon__Account__r.genesis__Business_Information__r.genesis__Tax_Identification_Number__c"},{"externalField": "FirstName","fieldAPI": "clcommon__Contact__r.FirstName"},{"externalField": "MiddleName","fieldAPI": "clcommon__Contact__r.ints__Middle_Name__c"},{"externalField": "LastName","fieldAPI": "clcommon__Contact__r.LastName"},{"externalField": "Birthdate","fieldAPI": "clcommon__Contact__r.Birthdate"},{"externalField": "SSN","fieldAPI": "clcommon__Contact__r.genesis__SSN__c"},{"externalField": "LoanAmount","fieldAPI": "genesis__Application__r.genesis__Loan_Amount__c"},{"externalField": "LoanPurpose","fieldAPI": "genesis__Application__r.genesis__CL_Purpose__r.Name"},{"externalField": "PartyTypes","fieldAPI": "clcommon__Party_Types__c"},{"externalField": "ApplicationId","fieldAPI": "genesis__Application__r.id"}],"objectAlias": "PartyInfo","objectAPI": "clcommon__Party__c","whereClause": "Id IN :partyIdList"}],"name": "test"}}',
            'text/xml',
            1
        );
        System.assert(integrationAPIConfig!=null,'No Integration API Configuration was set.');

        //setting the data for credit rating
        List<genesis__Applications__c> allTierAppList = new List<genesis__Applications__c>();
        Map<String, genesis__Applications__c> allTierAppMap = FICOCalloutTestHelper.getAllTierApplications(borrowerAccountObj, clPurposeObj);
        for(String eachApp : allTierAppMap.keyset()){
            allTierAppList.add(allTierAppMap.get(eachApp));
        }
        Database.insert(allTierAppList, true);
        List<genesis__Credit_Rating_Matrix__c> creditMatrixList = FICOCalloutTestHelper.createAllCreditRatingMatrix();
        Database.insert(creditMatrixList, true);
    }


    /**
     * @description Generating Exception Mock for Fico
     */
    public class FICOExceptionMockResponseGenerator implements HttpCalloutMock{
        /**
        * @description Generates Mock Response
        * @author  Pritam Roy | 03-04-2024 
        * @param req 
        * @return HttpResponse 
        **/
        public HttpResponse respond(HttpRequest req){
            HttpResponse response = new HttpResponse();
            String ficoResponseBody = '<SOAP:Envelope xmlns:SOAP="http://schemas.xmlsoap.org/soap/envelope/"><SOAP:Header/><SOAP:Body><ns2:ObtainDecisionDataResponse xmlns:ns2="http://www.liquidCredit.com/"><ns2:ObtainDecisionDataResult><FI_LiquidCredit customer_id="TheCoopFinanceAssoc" submission_id="d19afe9d-49fc-46b2-9d61-6119430722d7" submission_xref_id="20211118094147" timestamp="20250106 161317237 GMT" transaction_id="7e30d747-c9c7-4359-8cb1-250c23cf60fb"><response_message_list transaction_status_code="300" transaction_status_text="Unsuccessful"><message_info><message_code>0x80042872</message_code><message_source>Authentication</message_source><message_text>User authentication failed.</message_text></message_info></response_message_list></FI_LiquidCredit></ns2:ObtainDecisionDataResult></ns2:ObtainDecisionDataResponse></SOAP:Body></SOAP:Envelope>';
            response.setBody(ficoResponseBody);
            response.setHeader('Content-Type', 'text/xml;charset=utf-8');
            response.setStatusCode(401);
            return response;
        }
    }
    /**
    * @description testing fico callout for principal party with score.
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void testForPrincipalPartyWithScore(){
        List<User> adminUserList = FICOCalloutTestHelper.getAdminUser();
        List<clcommon__Party__c> partyList = [SELECT Id, 
                                                    Name, 
                                                    clcommon__Contact__r.Name, 
                                                    clcommon__Party_Types__c 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Contact__r.genesis__SSN__c = '666714588' 
                                                AND clcommon__Contact__r.Name = 'Christopher Nolan'
                                                AND clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME];
       
        System.runAs(adminUserList[0]){
            Test.setMock(HttpCalloutMock.class, new FICOMockResponseGenerator());
            Test.startTest();
            FICOCallout.ficoCalloutMethodForParty(partyList[0].Id);
            List<clcommon__Log__c> logList = [SELECT Id,
                                                    Name 
                                                FROM clcommon__Log__c 
                                                WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1];
            System.assertEquals(false, logList.size()>0, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description testing fico callout for principal party without score.
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void tesPrincipalPartyWithoutScore(){
        List<User> adminUserList = FICOCalloutTestHelper.getAdminUser();
        List<clcommon__Party__c> partyList = [SELECT Id, 
                                                    Name, 
                                                    clcommon__Account__c,
                                                    clcommon__Contact__r.Name, 
                                                    clcommon__Party_Types__c 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Contact__r.genesis__SSN__c = '666714588' 
                                                AND clcommon__Contact__r.Name = 'Christopher Nolan'
                                                AND clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME];
        List<Account> principalAccountList = [SELECT Id, Name, FICO_Recorded_On__c FROM Account WHERE Id = :partyList[0].clcommon__Account__c];
        principalAccountList[0].FICO_Recorded_On__c = null;
        principalAccountList[0].SBSS70_Score__c = null;
        Database.update(principalAccountList, true);
    
        System.runAs(adminUserList[0]){
            Test.setMock(HttpCalloutMock.class, new FICOMockResponseGenerator());
            Test.startTest();
            FICOCallout.ficoCalloutMethodForParty(partyList[0].Id);
            List<clcommon__Log__c> logList = [SELECT Id,
                                                    Name 
                                                FROM clcommon__Log__c 
                                                WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1];
            System.assertEquals(false, logList.size()>0, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description testing fico callout for borrower party without score.
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void tesBorrowerPartyWithoutScore(){
        List<User> adminUserList = FICOCalloutTestHelper.getAdminUser();
        List<Account> borrowerAccountList = [SELECT Id, Name, FICO_Recorded_On__c FROM Account WHERE RecordType.Name = 'Grower'];
        borrowerAccountList[0].FICO_Recorded_On__c = null;
        borrowerAccountList[0].SBSS70_Score__c = null;
        Database.update(borrowerAccountList, true);
        List<clcommon__Party__c> partyList = [SELECT Id, 
                                                    Name, 
                                                    clcommon__Account__c,
                                                    clcommon__Contact__r.Name, 
                                                    clcommon__Party_Types__c 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Account__c = : borrowerAccountList[0].Id
                                                AND clcommon__Party_Types__c = :PortalConstants.BORROWER_PARTY_NAME];

        System.runAs(adminUserList[0]){
            Test.setMock(HttpCalloutMock.class, new FICOMockResponseGenerator());
            Test.startTest();
            FICOCallout.ficoCalloutMethodForParty(partyList[0].Id);
            List<clcommon__Log__c> logList = [SELECT Id,
                                                    Name 
                                                FROM clcommon__Log__c 
                                                WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1];
            System.assertEquals(false, logList.size()>0, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
     /**
    * @description testing fico callout for borrower party with score.
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void tesBorrowerPartyWithScore(){
        List<User> adminUserList = FICOCalloutTestHelper.getAdminUser();
        List<clcommon__Party__c> partyList = [SELECT Id, 
                                                    Name, 
                                                    clcommon__Account__c,
                                                    clcommon__Contact__r.Name, 
                                                    clcommon__Party_Types__c 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Contact__r.genesis__SSN__c = '324242424' 
                                                AND clcommon__Party_Types__c = :PortalConstants.BORROWER_PARTY_NAME];

        System.runAs(adminUserList[0]){
            Test.setMock(HttpCalloutMock.class, new FICOMockResponseGenerator());
            Test.startTest();
            FICOCallout.ficoCalloutMethodForParty(partyList[0].Id);
            List<clcommon__Log__c> logList = [SELECT Id,
                                                    Name 
                                                FROM clcommon__Log__c 
                                                WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1];
            System.assertEquals(false, logList.size()>0, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description testing fico callout for principal party with master credit user.
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void testPrincipalWithMasterCreditUser(){
        List<User> creditUserList = FICOCalloutTestHelper.getMasterCreditUser();
        List<clcommon__Party__c> partyList = [SELECT Id, 
                                                    Name, 
                                                    clcommon__Contact__r.Name, 
                                                    clcommon__Party_Types__c 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Contact__r.genesis__SSN__c = '666714588' 
                                                AND clcommon__Contact__r.Name = 'Christopher Nolan'
                                                AND clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME];
       
        System.runAs(creditUserList[0]){
            Test.setMock(HttpCalloutMock.class, new FICOMockResponseGenerator());
            Test.startTest();
            FICOCallout.ficoCalloutMethodForParty(partyList[0].Id);
            List<clcommon__Log__c> logList = [SELECT Id,
                                                    Name 
                                                FROM clcommon__Log__c 
                                                WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1];
            System.assertEquals(false, logList.size()>0, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description testing fico callout for principal party with cfa admin user.
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void testPrincipalWithCFAAdminUser(){
        List<User> creditUserList = FICOCalloutTestHelper.getCFAAdminUser();
        List<clcommon__Party__c> partyList = [SELECT Id, 
                                                    Name, 
                                                    clcommon__Contact__r.Name, 
                                                    clcommon__Party_Types__c 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Contact__r.genesis__SSN__c = '666714588' 
                                                AND clcommon__Contact__r.Name = 'Christopher Nolan'
                                                AND clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME];
       
        System.runAs(creditUserList[0]){
            Test.setMock(HttpCalloutMock.class, new FICOMockResponseGenerator());
            Test.startTest();
            FICOCallout.ficoCalloutMethodForParty(partyList[0].Id);
            List<clcommon__Log__c> logList = [SELECT Id,
                                                    Name 
                                                FROM clcommon__Log__c 
                                                WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1];
            System.assertEquals(false, logList.size()>0, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description testing fico callout for principal party with loan accounting user.
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void testPrincipalWithLoanAccountingUser(){
        List<User> creditUserList = FICOCalloutTestHelper.getLoanAccountingUser();
        List<clcommon__Party__c> partyList = [SELECT Id, 
                                                    Name, 
                                                    clcommon__Contact__r.Name, 
                                                    clcommon__Party_Types__c 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Contact__r.genesis__SSN__c = '666714588' 
                                                AND clcommon__Contact__r.Name = 'Christopher Nolan'
                                                AND clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME];
       
        System.runAs(creditUserList[0]){
            Test.setMock(HttpCalloutMock.class, new FICOMockResponseGenerator());
            Test.startTest();
            FICOCallout.ficoCalloutMethodForParty(partyList[0].Id);
            List<clcommon__Log__c> logList = [SELECT Id,
                                                    Name 
                                                FROM clcommon__Log__c 
                                                WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1];
            System.assertEquals(true, logList.size()>0, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description testing fico callout for principal party with credit user.
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void testFICOCalloutForPrincipalPartyWithCreditUser(){
        List<User> creditUserList = FICOCalloutTestHelper.getCreditUser();
        List<clcommon__Party__c> partyList = [SELECT Id, 
                                                    Name, 
                                                    clcommon__Contact__r.Name, 
                                                    clcommon__Party_Types__c 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Contact__r.genesis__SSN__c = '666714588' 
                                                AND clcommon__Contact__r.Name = 'Christopher Nolan'
                                                AND clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME];
       
        System.runAs(creditUserList[0]){
            Test.setMock(HttpCalloutMock.class, new FICOMockResponseGenerator());
            Test.startTest();
            FICOCallout.ficoCalloutMethodForParty(partyList[0].Id);
            List<clcommon__Log__c> logList = [SELECT Id,
                                                    Name 
                                                FROM clcommon__Log__c 
                                                WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1];
            System.assertEquals(false, logList.size()>0, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
        
    }
    /**
    * @description testing fico callout for orphan principal party.
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void testFICOCalloutForPrincipalPartyWithoutLinkedWithApp(){
        List<User> adminUserList = FICOCalloutTestHelper.getAdminUser();
        List<clcommon__Party__c> partyList = [SELECT Id, 
                                                    Name, 
                                                    genesis__Application__c,
                                                    clcommon__Contact__r.Name, 
                                                    clcommon__Party_Types__c 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Contact__r.genesis__SSN__c = '666714588' 
                                                AND clcommon__Contact__r.Name = 'Christopher Nolan'
                                                AND clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME];
        
        partyList[0].genesis__Application__c = null;
        Database.update(partyList,true);
        System.runAs(adminUserList[0]){
            Test.setMock(HttpCalloutMock.class, new FICOMockResponseGenerator());
            Test.startTest();
            FICOCallout.ficoCalloutMethodForParty(partyList[0].Id);
            List<clcommon__Log__c> logList = [SELECT Id,
                                                Name 
                                            FROM clcommon__Log__c 
                                            WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];
            System.assertEquals(true, logList.size()>0, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
        
    }


    /**
    * @description testing fico callout for unsuccessful authentication.
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void testFICOCalloutForUnsuccessfulAuthentication(){
        List<User> adminUserList = FICOCalloutTestHelper.getAdminUser();
        List<clcommon__Party__c> partyList = [SELECT Id, 
                                                    Name, 
                                                    clcommon__Contact__r.Name, 
                                                    clcommon__Party_Types__c 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Contact__r.genesis__SSN__c = '666714588' 
                                                AND clcommon__Contact__r.Name = 'Christopher Nolan'
                                                AND clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME];
       
        System.runAs(adminUserList[0]){
            Test.setMock(HttpCalloutMock.class, new FICOExceptionMockResponseGenerator());
            Test.startTest();
            FICOCallout.ficoCalloutMethodForParty(partyList[0].Id);
            List<clcommon__Log__c> logList = [SELECT Id,
                                                Name 
                                            FROM clcommon__Log__c 
                                            WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];
            System.assertEquals(false, logList.size()>0, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
        
    }

    /**
    * @description testing fico callout for principal party with invalid party id.
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @isTest
    static void testFICOCalloutclassForPrincipalError(){
        List<User> clUserList = FICOCalloutTestHelper.getCLUserList('Ross Geller');
        System.runAs(clUserList[0]){
            Test.startTest();
            FICOCallout.ficoCalloutMethodForParty('345t43kteg55');
           List<clcommon__Log__c> logList = [SELECT Id,
                                                Name 
                                            FROM clcommon__Log__c 
                                            WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];
            System.assertEquals(true, logList.size()>0, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description testing fico callout for principal party with blank party id.
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @isTest
    static void testForPrincipalWithBlankId(){
        List<User> clUserList = FICOCalloutTestHelper.getCLUserList('Ross Geller');
        System.runAs(clUserList[0]){
            Test.startTest();
            FICOCallout.ficoCalloutMethodForParty('');
           List<clcommon__Log__c> logList = [SELECT Id,
                                                Name 
                                            FROM clcommon__Log__c 
                                            WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];
            System.assertEquals(true, logList.size()>0, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description testing fico callout for sole prop borrower with score and principal w/o score
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void testBorrowerWithScorePrincipalWithoutScore(){
        List<User> clUserList = FICOCalloutTestHelper.getCLUserList('Ross Geller');
        List<Account> coApplicantAccountList = [SELECT Id, 
                                                        Name, 
                                                        FICO_Recorded_On__c 
                                                    FROM Account 
                                                    WHERE RecordType.Name = 'CoApplicant'];
        coApplicantAccountList[0].FICO_Recorded_On__c = null;
        coApplicantAccountList[0].SBSS70_Score__c = null;
        Database.update(coApplicantAccountList, true);
        List<genesis__Applications__c> applicationList = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 824001];
       
        System.runAs(clUserList[0]){
            Test.setMock(HttpCalloutMock.class, new FICOMockResponseGenerator());
            Test.startTest();
            FICOCallout ficoCallout = new FICOCallout(applicationList[0].Id);
            database.executeBatch(ficoCallout,ConstantValues.MAX_PRINCIPAL_FOR_CALLOUT);
            Test.stopTest();
            List<clcommon__Log__c> logList = [SELECT Id,
                                                Name 
                                            FROM clcommon__Log__c 
                                            WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];
            System.assertEquals(false, logList.size()>0, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description testing fico callout for sole prop borrower w/o score and principal with score
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void testPrincipalWithScoreBorrowerWithoutScore(){
        List<User> clUserList = FICOCalloutTestHelper.getCLUserList('Ross Geller');
        List<Account> borrowerAccountList = [SELECT Id, 
                                                    Name, 
                                                    FICO_Recorded_On__c
                                                FROM Account 
                                                WHERE RecordType.Name = 'Grower'];
        borrowerAccountList[0].FICO_Recorded_On__c = null;
        borrowerAccountList[0].SBSS70_Score__c = null;
        Database.update(borrowerAccountList, true);
        
        List<Account> coApplicantAccountList = [SELECT Id, 
                                                        Name, FICO_Recorded_On__c
                                                    FROM Account
                                                    WHERE RecordType.Name = 'CoApplicant'];
        coApplicantAccountList[0].FICO_Recorded_On__c = Date.newInstance(2024, 04, 01);
        Database.update(coApplicantAccountList, true);

        List<genesis__Applications__c> applicationList = [SELECT Id
                                                            FROM genesis__Applications__c 
                                                            WHERE genesis__Loan_Amount__c = 824001];
       
        System.runAs(clUserList[0]){
            Test.setMock(HttpCalloutMock.class, new FICOMockResponseGenerator());
            Test.startTest();
            FICOCallout ficoCallout = new FICOCallout(applicationList[0].Id);
            database.executeBatch(ficoCallout,ConstantValues.MAX_PRINCIPAL_FOR_CALLOUT);
            Test.stopTest();
        
            List<clcommon__Log__c> logList = [SELECT Id,
                                                Name 
                                            FROM clcommon__Log__c 
                                            WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];
            System.assertEquals(false, logList.size()>0, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description testing fico callout for sole prop borrower w/o score and principal w/o score
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void testPrincipalWithOutScoreBorrowerWithoutScore(){
        List<User> clUserList = FICOCalloutTestHelper.getCLUserList('Ross Geller');
        List<Account> borrowerAccountList = [SELECT Id, Name, FICO_Recorded_On__c FROM Account WHERE RecordType.Name = 'Grower'];
        borrowerAccountList[0].FICO_Recorded_On__c = null;
        borrowerAccountList[0].SBSS70_Score__c = null;
        Database.update(borrowerAccountList, true);
        List<Account> coApplicantAccountList = [SELECT Id, Name, FICO_Recorded_On__c FROM Account WHERE RecordType.Name = 'CoApplicant'];
        coApplicantAccountList[0].FICO_Recorded_On__c = null;
        coApplicantAccountList[0].SBSS70_Score__c = null;
        Database.update(coApplicantAccountList, true);
        List<genesis__Applications__c> applicationList = [SELECT Id
                                                            FROM genesis__Applications__c 
                                                            WHERE genesis__Loan_Amount__c = 824001];
       
        System.runAs(clUserList[0]){
            Test.setMock(HttpCalloutMock.class, new FICOMockResponseGenerator());
            Test.startTest();
            FICOCallout ficoCallout = new FICOCallout(applicationList[0].Id);
            database.executeBatch(ficoCallout,ConstantValues.MAX_PRINCIPAL_FOR_CALLOUT);
            Test.stopTest();
       
             List<clcommon__Log__c> logList = [SELECT Id,
                                                Name 
                                            FROM clcommon__Log__c 
                                            WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];
            System.assertEquals(false, logList.size()>0, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description testing fico callout for sole prop borrower with score and principal with score
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void testPrincipalWithScoreBorrowerWithScore(){
        Test.setMock(HttpCalloutMock.class, new FICOMockResponseGenerator());
        List<User> clUserList = FICOCalloutTestHelper.getCLUserList('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id
                                                            FROM genesis__Applications__c 
                                                            WHERE genesis__Loan_Amount__c = 824001];
        
        System.runAs(clUserList[0]){
            Test.startTest();
            FICOCallout ficoCallout = new FICOCallout(applicationList[0].Id);
            database.executeBatch(ficoCallout,ConstantValues.MAX_PRINCIPAL_FOR_CALLOUT);
            Test.stopTest();
        
            List<clcommon__Log__c> logList = [SELECT Id,
                                                Name 
                                            FROM clcommon__Log__c 
                                            WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];
            System.assertEquals(false, logList.size()>0, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description testing fico callout for borrower without score where no principal present on the application.
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void testOnlyScoreBorrowerWithOutScore(){
        Test.setMock(HttpCalloutMock.class, new FICOMockResponseGenerator());
        List<User> clUserList = FICOCalloutTestHelper.getCLUserList('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 824001];
        List<Account> borrowerAccountList = [SELECT Id, Name, FICO_Recorded_On__c FROM Account WHERE RecordType.Name = 'Grower'];
        borrowerAccountList[0].FICO_Recorded_On__c = null;
        borrowerAccountList[0].SBSS70_Score__c = null;
        Database.update(borrowerAccountList, true);
        Database.delete([SELECT Id 
                            FROM clcommon__Party__c 
                            WHERE genesis__Application__c =: applicationList[0].Id 
                            AND clcommon__Party_Types__c = 'Principal'], true);
        
        System.runAs(clUserList[0]){
            Test.startTest();
            FICOCallout ficoCallout = new FICOCallout(applicationList[0].Id);
            database.executeBatch(ficoCallout,ConstantValues.MAX_PRINCIPAL_FOR_CALLOUT);
            Test.stopTest();
        
            List<clcommon__Log__c> logList = [SELECT Id,
                                                Name 
                                            FROM clcommon__Log__c 
                                            WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];
            System.assertEquals(false, logList.size()>0, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description testing fico callout for blank application id.
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void testNullApplicationId(){
        List<User> clUserList = FICOCalloutTestHelper.getCLUserList('Ross Geller');
        
        System.runAs(clUserList[0]){
            Test.startTest();
                try{
                    FICOCallout ficoCallout = new FICOCallout(null);
                    database.executeBatch(ficoCallout,ConstantValues.MAX_PRINCIPAL_FOR_CALLOUT);
                }
                catch(CustomException customExceptionObj){
                    System.assertEquals(ConstantValues.SOMETHING_WENT_WRONG, customExceptionObj.getMessage(), 'Assertion Failed');
                }
            Test.stopTest();
        }
        
    }

    /**
    * @description testing fico callout for corporation borrower w/o score and principal w/o score
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void testCorporationBorrowerAndPrincipalWithoutScore(){
        List<User> clUserList = FICOCalloutTestHelper.getCLUserList('Ross Geller');
        List<Account> borrowerAccountList = [SELECT Id, 
                                                    Name,
                                                    clcommon__Legal_Entity_Type__c,
                                                    genesis__Business_Information__c, 
                                                    FICO_Recorded_On__c 
                                                FROM Account 
                                                WHERE RecordType.Name = 'Grower'];
        List<clcommon__Legal_Entity__c> corporationEntityList = [SELECT Id FROM clcommon__Legal_Entity__c WHERE Name = 'Corporation' LIMIT 1];
        borrowerAccountList[0].FICO_Recorded_On__c = null;
        borrowerAccountList[0].SBSS70_Score__c = null;
        borrowerAccountList[0].clcommon__Legal_Entity_Type__c = corporationEntityList[0].Id;
        Database.update(borrowerAccountList, true);
        List<genesis__Business_Information__c> borrBusinessInfoList = [Select id, genesis__Tax_Identification_Number__c from genesis__Business_Information__c Where id =: borrowerAccountList[0].genesis__Business_Information__c ];
        borrBusinessInfoList[0].genesis__Tax_Identification_Number__c = null;
        Database.update(borrBusinessInfoList[0],true);
        List<Account> coApplicantAccountlist = [SELECT Id, Name, FICO_Recorded_On__c FROM Account WHERE RecordType.Name = 'CoApplicant'];
        coApplicantAccountlist[0].FICO_Recorded_On__c = null;
        coApplicantAccountlist[0].SBSS70_Score__c = null;
        Database.update(coApplicantAccountlist, true);
        List<genesis__Applications__c> applicationList = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 824001];
       
        System.runAs(clUserList[0]){
            Test.setMock(HttpCalloutMock.class, new FICOMockResponseGenerator());
            Test.startTest();
            FICOCallout ficoCallout = new FICOCallout(applicationList[0].Id);
            database.executeBatch(ficoCallout,ConstantValues.MAX_PRINCIPAL_FOR_CALLOUT);
            Test.stopTest();
        
            List<clcommon__Log__c> logList = [SELECT Id,
                                                Name 
                                            FROM clcommon__Log__c 
                                            WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];
            System.assertEquals(false, logList.size()>0, PortalConstants.ASSERTION_FAILED);
        }
    }
    /**
    * @description testing fico callout for DBA borrower w/o score and principal w/o score
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void testDBABorrowerAndPrincipalWithoutScore(){
        List<User> clUserList = FICOCalloutTestHelper.getCLUserList('Ross Geller');
        List<Account> borrowerAccountList = [SELECT Id, 
                                                    Name,
                                                    clcommon__Legal_Entity_Type__c,
                                                    genesis__Business_Information__c, 
                                                    FICO_Recorded_On__c 
                                                FROM Account 
                                                WHERE RecordType.Name = 'Grower'];
        List<clcommon__Legal_Entity__c> corporationEntityList = [SELECT Id FROM clcommon__Legal_Entity__c WHERE Name = 'Individual(s) with DBA' LIMIT 1];
        borrowerAccountList[0].FICO_Recorded_On__c = null;
        borrowerAccountList[0].SBSS70_Score__c = null;
        borrowerAccountList[0].clcommon__Legal_Entity_Type__c = corporationEntityList[0].Id;
        Database.update(borrowerAccountList, true);
        List<genesis__Business_Information__c> borrBusinessInfoList = [Select id, genesis__Tax_Identification_Number__c from genesis__Business_Information__c Where id =: borrowerAccountList[0].genesis__Business_Information__c ];
        borrBusinessInfoList[0].genesis__Tax_Identification_Number__c = null;
        Database.update(borrBusinessInfoList[0],true);
        List<Account> coApplicantAccountlist = [SELECT Id, Name, FICO_Recorded_On__c FROM Account WHERE RecordType.Name = 'CoApplicant'];
        coApplicantAccountlist[0].FICO_Recorded_On__c = null;
        coApplicantAccountlist[0].SBSS70_Score__c = null;
        Database.update(coApplicantAccountlist, true);
        List<genesis__Applications__c> applicationList = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 824001];
       
        System.runAs(clUserList[0]){
            Test.setMock(HttpCalloutMock.class, new FICOMockResponseGenerator());
            Test.startTest();
            FICOCallout ficoCallout = new FICOCallout(applicationList[0].Id);
            database.executeBatch(ficoCallout,ConstantValues.MAX_PRINCIPAL_FOR_CALLOUT);
            Test.stopTest();
        
            List<clcommon__Log__c> logList = [SELECT Id,
                                                Name 
                                            FROM clcommon__Log__c 
                                            WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];
            System.assertEquals(false, logList.size()>0, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description testing for corporatiom borrower without score and principal with score
    * @author Ayan Bhowmik | 01-22-2025 
    **/
    @IsTest
    static void testCorpBorrowerAndPrincipalWithoutScore(){
        List<User> clUserList = FICOCalloutTestHelper.getCLUserList('Ross Geller');
        List<clcommon__Legal_Entity__c> corpLegalEntityList  = [SELECT Id 
                                                                        FROM clcommon__Legal_Entity__c 
                                                                        WHERE clcommon__Legal_Entity_Type__c = 'Corporation'];
        List<Account> borrowerAccountList = [SELECT Id, 
                                                    Name, 
                                                    FICO_Recorded_On__c 
                                                FROM Account 
                                                WHERE RecordType.Name = 'Grower'];
        borrowerAccountList[0].FICO_Recorded_On__c = null;
        borrowerAccountList[0].SBSS70_Score__c = null;
        borrowerAccountList[0].clcommon__Legal_Entity_Type__c = corpLegalEntityList[0].id;
        Database.update(borrowerAccountList, true);
        List<Account> coApplicantAccountList = [SELECT Id, 
                                                        Name, 
                                                        FICO_Recorded_On__c 
                                                    FROM Account 
                                                    WHERE RecordType.Name = 'CoApplicant'];
        coApplicantAccountList[0].FICO_Recorded_On__c = null;
        coApplicantAccountList[0].SBSS70_Score__c = null;
        Database.update(coApplicantAccountList, true);
        List<genesis__Applications__c> applicationList = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 824001];
        
        System.runAs(clUserList[0]){
            Test.setMock(HttpCalloutMock.class, new FICOMockResponseGenerator());
            Test.startTest();
            FICOCallout ficoCallout = new FICOCallout(applicationList[0].Id);
            database.executeBatch(ficoCallout,ConstantValues.MAX_PRINCIPAL_FOR_CALLOUT);
            Test.stopTest();
        
            List<clcommon__Log__c> logList = [SELECT Id,
                                                Name 
                                            FROM clcommon__Log__c 
                                            WHERE Name IN ('FICOCallout','FICORequestGeneratorHelper','FICOAdapter')
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];
            System.assertEquals(false, logList.size()>0, PortalConstants.ASSERTION_FAILED);
        }
    }
}