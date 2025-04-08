/**
 * @description       : This the test class of FICORequestGeneratorHelper
 * @author            : Ayan Bhowmik
 * @group             : 
 * @last modified on  : 01-05-2025
 * @last modified by  : Ayush Kumar Singh
**/
@IsTest
public with sharing class FICORequestGeneratorHelperTest {
    @TestSetup
    static void makeData(){
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
        borrowerBusinessInfoObj.genesis__Tax_Identification_Number__c = '';
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
        borrowerAccountObj.BillingPostalCode = '77777';
        Account coBorrowerAccountObj = FICOCalloutTestHelper.createCoBorrowerAccount(solePropLegalEntityObj,coBorrowerBusinessInfoObj.id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        Database.insert(new List<Account>{dealerAccountObj, clAccountObj, borrowerAccountObj, coBorrowerAccountObj},true);
        
        // Creating CL, Borrower, Coapplicant Contact
        Contact clContactObj = FICOCalloutTestHelper.createCLContact(clAccountObj.id);
        Contact borrowerContactObj = FICOCalloutTestHelper.createBorrowerContact(borrowerAccountObj.id);
        borrowerContactObj.genesis__SSN__c = '324242424';
        borrowerContactObj.Confirm_SSN__c = '324242424';
        Contact coBorrowerContactObj = FICOCalloutTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        coBorrowerContactObj.genesis__SSN__c = '666714588';
        coBorrowerContactObj.Confirm_SSN__c = '666714588';
        coBorrowerContactObj.ints__Middle_Name__c = 'Kumar';
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

        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(partyParamMap);
        partyObj.clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;
        partyObj.Street__c = borrowerAccountObj.BillingStreet;
        partyObj.City__c = borrowerAccountObj.BillingCity;
        partyObj.State__c = borrowerAccountObj.BillingState;
        partyObj.Postal_Code__c = borrowerAccountObj.BillingPostalCode;
        Database.insert(partyObj,true);

        Map<String,Id> coPartyParamMap = new Map<String,Id>{
            'accountId' => coBorrowerAccountObj.id,
            'contactId' => coBorrowerContactObj.id,
            'partyTypeId' => principalPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };

        clcommon__Party__c coPartyObj = ApplicationOriginationTestHelper.createParty(coPartyParamMap);
        coPartyObj.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;
        coPartyObj.Street__c = coBorrowerAccountObj.BillingStreet;
        coPartyObj.City__c = coBorrowerAccountObj.BillingCity;
        coPartyObj.State__c = coBorrowerAccountObj.BillingState;
        coPartyObj.Postal_Code__c = coBorrowerAccountObj.BillingPostalCode;
        coPartyObj.Principal_Number__c = 1;
        Database.insert(coPartyObj,true);

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
    @IsTest
    static void testSuccessRequestForSoleProp(){
        List<User> clUserList = FICOCalloutTestHelper.getCLUserList('Ross Geller');
        List<genesis__Applications__c> applicationObj = [SELECT Id,
                                                         genesis__Loan_Amount__c, 
                                                         genesis__CL_Purpose__r.Name 
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 824001];
                                
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    Net_Worth__c,
                                                    Street__c,
                                                    City__c,
                                                    State__c,
                                                    Mobile_Number__c,
                                                    clcommon__Account__c,
                                                    Principal_Number__c,
                                                    Postal_Code__c,
                                                    clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c,
                                                    clcommon__Account__r.genesis__Business_Information__r.genesis__Tax_Identification_Number__c,
                                                    clcommon__Contact__r.FirstName,
                                                    clcommon__Contact__r.ints__Middle_Name__c,
                                                    clcommon__Contact__r.LastName,
                                                    clcommon__Account__r.Name,
                                                    clcommon__Contact__r.Birthdate,
                                                    clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                    genesis__Application__r.genesis__Loan_Amount__c,
                                                    genesis__Application__r.genesis__CL_Purpose__r.Name,
                                                    clcommon__Contact__c,
                                                    clcommon__Party_Types__c,
                                                    genesis__Application__r.id,
                                                    clcommon__Contact__r.genesis__SSN__c
                                                FROM clcommon__Party__c
                                                WHERE genesis__Application__c = :applicationObj[0].id
                                                AND (clcommon__Account__r.FICO_Recorded_On__c != LAST_N_DAYS:182
                                                AND (clcommon__Party_Types__c = :ConstantValues.BORROWER_PARTY
                                                OR  clcommon__Party_Types__c = :ConstantValues.PRINCIPAL_PARTY))
                                                ORDER BY CreatedDate
                                                LIMIT 1];
        List<Map<String, Object>> borrowerPartyReqList = new List<Map<String, Object>>();
        Map<String, Object> partyMap;
        for(clcommon__Party__c partyObj : partyList){
            partyMap = new Map<String, Object>{'Id' => partyObj.Id,
                                                'Networth' => partyObj.Net_Worth__c,
                                                'AccountId' => partyObj.clcommon__Account__c,
                                                'ContactId' => partyObj.clcommon__Contact__c,
                                                'borrowerContactSSN' => partyObj.clcommon__Contact__r.genesis__SSN__c,
                                                'Name' => partyObj.clcommon__Account__r.Name,
                                                'Street' => partyObj.Street__c,
                                                'City' => partyObj.City__c,
                                                'State' => partyObj.State__C,
                                                'Phone' => partyObj.Mobile_Number__c,
                                                'PostalCode' => partyObj.Postal_Code__c,
                                                'LegalEntity' => partyObj.clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                'PrincipalNumber' => partyObj.Principal_Number__c,
                                                'BusinessInfoNetWorth' => partyObj.clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c,
                                                'TaxIDNumber' => partyObj.clcommon__Account__r.genesis__Business_Information__r.genesis__Tax_Identification_Number__c,
                                                'FirstName' => partyObj.clcommon__Contact__r.FirstName,
                                                'MiddleName' => partyObj.clcommon__Contact__r.ints__Middle_Name__c,
                                                'LastName' => partyObj.clcommon__Contact__r.LastName,
                                                'Birthdate' => partyObj.clcommon__Contact__r.Birthdate,
                                                'SSN' => partyObj.clcommon__Contact__r.genesis__SSN__c,
                                                'LoanAmount' => partyObj.genesis__Application__r.genesis__Loan_Amount__c,
                                                'LoanPurpose' => partyObj.genesis__Application__r.genesis__CL_Purpose__r.Name,
                                                'PartyTypes' => partyObj.clcommon__Party_Types__c,
                                                'ApplicationId' => partyObj.genesis__Application__r.id
                                            };
            borrowerPartyReqList.add(partyMap);
        }
       
        
        Map<String, Object> requestMap = new Map<String, Object>{'PartyInfo' => borrowerPartyReqList};

        
        System.runAs(clUserList[0]){
            Test.startTest();
            String req = FICORequestGeneratorHelper.generateFICORequestBody(requestMap);
            System.assertEquals(true, req != null, 'Assertion Failed');
            Test.stopTest();
        }
        
    }
    @IsTest
    static void testSuccessRequestForDBA(){
        List<User> clUserList = FICOCalloutTestHelper.getCLUserList('Ross Geller');
        List<genesis__Applications__c> applicationObj = [SELECT Id,
                                                            genesis__Account__c,
                                                         genesis__Loan_Amount__c, 
                                                         genesis__CL_Purpose__r.Name 
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 824001];

        List<clcommon__Legal_Entity__c> legalEntity = [SELECT Id,
                                                                Name
                                                                FROM clcommon__Legal_Entity__c
                                                                WHERE Name = 'Individual(s) with DBA'];
        List<Account> borrowerAccount = [SELECT ID,
                                        clcommon__Legal_Entity_Type__c
                                        FROM Account
                                        WHERE Id =: applicationObj[0].genesis__Account__c];
        borrowerAccount[0].clcommon__Legal_Entity_Type__c = legalEntity[0].id;
        Database.update(borrowerAccount,true);

        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    Net_Worth__c,
                                                    Street__c,
                                                    City__c,
                                                    State__c,
                                                    Mobile_Number__c,
                                                    Postal_Code__c,
                                                    clcommon__Account__c,
                                                    Principal_Number__c,
                                                    clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c,
                                                    clcommon__Account__r.genesis__Business_Information__r.genesis__Tax_Identification_Number__c,
                                                    clcommon__Contact__r.FirstName,
                                                    clcommon__Contact__r.ints__Middle_Name__c,
                                                    clcommon__Contact__r.LastName,
                                                    clcommon__Account__r.Name,
                                                    clcommon__Contact__r.Birthdate,
                                                    clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                    genesis__Application__r.genesis__Loan_Amount__c,
                                                    genesis__Application__r.genesis__CL_Purpose__r.Name,
                                                    clcommon__Contact__c,
                                                    clcommon__Party_Types__c,
                                                    genesis__Application__r.id,
                                                    clcommon__Contact__r.genesis__SSN__c
                                                FROM clcommon__Party__c
                                                WHERE genesis__Application__c = :applicationObj[0].id
                                                AND (clcommon__Account__r.FICO_Recorded_On__c != LAST_N_DAYS:182
                                                AND (clcommon__Party_Types__c = :ConstantValues.BORROWER_PARTY
                                                OR  clcommon__Party_Types__c = :ConstantValues.PRINCIPAL_PARTY))
                                                ORDER BY CreatedDate
                                                LIMIT 1];

        List<Map<String, Object>> borrowerPartyReqList = new List<Map<String, Object>>();
        for(clcommon__Party__c partyObj : partyList){
            Map<String, Object> partyMap = new Map<String, Object>{'Id' => partyObj.Id,
                                                'Networth' => partyObj.Net_Worth__c,
                                                'AccountId' => partyObj.clcommon__Account__c,
                                                'ContactId' => partyObj.clcommon__Contact__c,
                                                'borrowerContactSSN' => partyObj.clcommon__Contact__r.genesis__SSN__c,
                                                'Name' => partyObj.clcommon__Account__r.Name,
                                                'Street' => partyObj.Street__c,
                                                'City' => partyObj.City__c,
                                                'State' => partyObj.State__C,
                                                'Phone' => partyObj.Mobile_Number__c,
                                                'PostalCode' => partyObj.Postal_Code__c,
                                                'LegalEntity' => partyObj.clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                'PrincipalNumber' => partyObj.Principal_Number__c,
                                                'BusinessInfoNetWorth' => partyObj.clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c,
                                                'TaxIDNumber' => partyObj.clcommon__Account__r.genesis__Business_Information__r.genesis__Tax_Identification_Number__c,
                                                'FirstName' => partyObj.clcommon__Contact__r.FirstName,
                                                'MiddleName' => partyObj.clcommon__Contact__r.ints__Middle_Name__c,
                                                'LastName' => partyObj.clcommon__Contact__r.LastName,
                                                'Birthdate' => partyObj.clcommon__Contact__r.Birthdate,
                                                'SSN' => partyObj.clcommon__Contact__r.genesis__SSN__c,
                                                'LoanAmount' => partyObj.genesis__Application__r.genesis__Loan_Amount__c,
                                                'LoanPurpose' => partyObj.genesis__Application__r.genesis__CL_Purpose__r.Name,
                                                'PartyTypes' => partyObj.clcommon__Party_Types__c,
                                                'ApplicationId' => partyObj.genesis__Application__r.id
                                            };
            borrowerPartyReqList.add(partyMap);  
        }
        Map<String, Object> requestMap = new Map<String, Object>{'PartyInfo' => borrowerPartyReqList};
        
        System.runAs(clUserList[0]){
            Test.startTest();
            String req = FICORequestGeneratorHelper.generateFICORequestBody(requestMap);
            System.assertEquals(true, req != null, 'Assertion Failed');
            Test.stopTest();
        }
        
    }
    @IsTest
    static void testSuccessAdressMissing(){
        List<User> clUserList = FICOCalloutTestHelper.getCLUserList('Ross Geller');
        List<genesis__Applications__c> applicationObj = [SELECT Id,
                                                         genesis__Loan_Amount__c, 
                                                         genesis__CL_Purpose__r.Name 
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 824001];
        
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    Net_Worth__c,
                                                    Street__c,
                                                    City__c,
                                                    State__c,
                                                    Mobile_Number__c,
                                                    Postal_Code__c,
                                                    clcommon__Account__c,
                                                    Principal_Number__c,
                                                    clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c,
                                                    clcommon__Account__r.genesis__Business_Information__r.genesis__Tax_Identification_Number__c,
                                                    clcommon__Contact__r.FirstName,
                                                    clcommon__Contact__r.ints__Middle_Name__c,
                                                    clcommon__Contact__r.LastName,
                                                    clcommon__Account__r.Name,
                                                    clcommon__Contact__r.Birthdate,
                                                    clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                    genesis__Application__r.genesis__Loan_Amount__c,
                                                    genesis__Application__r.genesis__CL_Purpose__r.Name,
                                                    clcommon__Contact__c,
                                                    clcommon__Party_Types__c,
                                                    genesis__Application__r.id,
                                                    clcommon__Contact__r.genesis__SSN__c
                                                FROM clcommon__Party__c
                                                WHERE genesis__Application__c = :applicationObj[0].id
                                                AND (clcommon__Account__r.FICO_Recorded_On__c != LAST_N_DAYS:182
                                                AND (clcommon__Party_Types__c = :ConstantValues.BORROWER_PARTY
                                                OR  clcommon__Party_Types__c = :ConstantValues.PRINCIPAL_PARTY))
                                                ORDER BY CreatedDate
                                                LIMIT 1];
        List<Map<String, Object>> borrowerPartyReqList = new List<Map<String, Object>>();
        Map<String, Object> partyMap;
        for(clcommon__Party__c partyObj : partyList){
            partyMap = new Map<String, Object>{'Id' => partyObj.Id,
                                                'Networth' => partyObj.Net_Worth__c,
                                                'AccountId' => partyObj.clcommon__Account__c,
                                                'ContactId' => partyObj.clcommon__Contact__c,
                                                'borrowerContactSSN' => partyObj.clcommon__Contact__r.genesis__SSN__c,
                                                'Name' => partyObj.clcommon__Account__r.Name,
                                                'Street' => null,
                                                'City' => null,
                                                'State' => null,
                                                'Phone' => partyObj.Mobile_Number__c,
                                                'PostalCode' => null,
                                                'LegalEntity' => partyObj.clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                'PrincipalNumber' => partyObj.Principal_Number__c,
                                                'BusinessInfoNetWorth' => partyObj.clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c,
                                                'TaxIDNumber' => partyObj.clcommon__Account__r.genesis__Business_Information__r.genesis__Tax_Identification_Number__c,
                                                'FirstName' => partyObj.clcommon__Contact__r.FirstName,
                                                'MiddleName' => partyObj.clcommon__Contact__r.ints__Middle_Name__c,
                                                'LastName' => partyObj.clcommon__Contact__r.LastName,
                                                'Birthdate' => partyObj.clcommon__Contact__r.Birthdate,
                                                'SSN' => partyObj.clcommon__Contact__r.genesis__SSN__c,
                                                'LoanAmount' => partyObj.genesis__Application__r.genesis__Loan_Amount__c,
                                                'LoanPurpose' => partyObj.genesis__Application__r.genesis__CL_Purpose__r.Name,
                                                'PartyTypes' => partyObj.clcommon__Party_Types__c,
                                                'ApplicationId' => partyObj.genesis__Application__r.id
                                            };
        borrowerPartyReqList.add(partyMap);
        }
        
        Map<String, Object> requestMap = new Map<String, Object>{'PartyInfo' => borrowerPartyReqList};

        
        System.runAs(clUserList[0]){
            Test.startTest();
            String req = FICORequestGeneratorHelper.generateFICORequestBody(requestMap);
            System.assertEquals(true, req != null, 'Assertion Failed');
            Test.stopTest();
        }
       
    }
    @IsTest
    static void testSuccessRequestForCorporation(){
        List<User> clUserList = FICOCalloutTestHelper.getCLUserList('Ross Geller');
        List<genesis__Applications__c> applicationObj = [SELECT Id,
                                                            genesis__Account__c,
                                                         genesis__Loan_Amount__c, 
                                                         genesis__CL_Purpose__r.Name 
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 824001];

        List<clcommon__Legal_Entity__c> legalEntity = [SELECT Id,
                                                                Name
                                                                FROM clcommon__Legal_Entity__c
                                                                WHERE Name = 'CORPORATION'];
        List<Account> borrowerAccount = [SELECT ID,
                                        clcommon__Legal_Entity_Type__c
                                        FROM Account
                                        WHERE Id =: applicationObj[0].genesis__Account__c];
        borrowerAccount[0].clcommon__Legal_Entity_Type__c = legalEntity[0].id;
        Database.update(borrowerAccount,true);
       
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    Net_Worth__c,
                                                    Street__c,
                                                    City__c,
                                                    State__c,
                                                    Mobile_Number__c,
                                                    Postal_Code__c,
                                                    clcommon__Account__c,
                                                    Principal_Number__c,
                                                    clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c,
                                                    clcommon__Account__r.genesis__Business_Information__r.genesis__Tax_Identification_Number__c,
                                                    clcommon__Contact__r.FirstName,
                                                    clcommon__Contact__r.ints__Middle_Name__c,
                                                    clcommon__Contact__r.LastName,
                                                    clcommon__Account__r.Name,
                                                    clcommon__Contact__r.Birthdate,
                                                    clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                    genesis__Application__r.genesis__Loan_Amount__c,
                                                    genesis__Application__r.genesis__CL_Purpose__r.Name,
                                                    clcommon__Contact__c,
                                                    clcommon__Party_Types__c,
                                                    genesis__Application__r.id,
                                                    clcommon__Contact__r.genesis__SSN__c
                                                FROM clcommon__Party__c
                                                WHERE genesis__Application__c = :applicationObj[0].id
                                                AND (clcommon__Account__r.FICO_Recorded_On__c != LAST_N_DAYS:182
                                                AND (clcommon__Party_Types__c = :ConstantValues.BORROWER_PARTY
                                                OR  clcommon__Party_Types__c = :ConstantValues.PRINCIPAL_PARTY))
                                                ORDER BY CreatedDate
                                                LIMIT 1];
        List<Map<String, Object>> borrowerPartyReqList = new List<Map<String, Object>>();
        Map<String, Object> partyMap;
        for(clcommon__Party__c partyObj : partyList){
            partyMap = new Map<String, Object>{'Id' => partyObj.Id,
                                                'Networth' => partyObj.Net_Worth__c,
                                                'AccountId' => partyObj.clcommon__Account__c,
                                                'ContactId' => partyObj.clcommon__Contact__c,
                                                'borrowerContactSSN' => partyObj.clcommon__Contact__r.genesis__SSN__c,
                                                'Name' => partyObj.clcommon__Account__r.Name,
                                                'Street' => partyObj.Street__c,
                                                'City' => partyObj.City__c,
                                                'State' => partyObj.State__C,
                                                'Phone' => partyObj.Mobile_Number__c,
                                                'PostalCode' => partyObj.Postal_Code__c,
                                                'LegalEntity' => partyObj.clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                'PrincipalNumber' => partyObj.Principal_Number__c,
                                                'BusinessInfoNetWorth' => partyObj.clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c,
                                                'TaxIDNumber' => partyObj.clcommon__Account__r.genesis__Business_Information__r.genesis__Tax_Identification_Number__c,
                                                'FirstName' => partyObj.clcommon__Contact__r.FirstName,
                                                'MiddleName' => partyObj.clcommon__Contact__r.ints__Middle_Name__c,
                                                'LastName' => partyObj.clcommon__Contact__r.LastName,
                                                'Birthdate' => partyObj.clcommon__Contact__r.Birthdate,
                                                'SSN' => partyObj.clcommon__Contact__r.genesis__SSN__c,
                                                'LoanAmount' => partyObj.genesis__Application__r.genesis__Loan_Amount__c,
                                                'LoanPurpose' => partyObj.genesis__Application__r.genesis__CL_Purpose__r.Name,
                                                'PartyTypes' => partyObj.clcommon__Party_Types__c,
                                                'ApplicationId' => partyObj.genesis__Application__r.id
                                            };
            borrowerPartyReqList.add(partyMap);
        }
       
        Map<String, Object> requestMap = new Map<String, Object>{'PartyInfo' => borrowerPartyReqList};

        
        System.runAs(clUserList[0]){
            Test.startTest();
            String req = FICORequestGeneratorHelper.generateFICORequestBody(requestMap);
            System.assertEquals(true, req != null, 'Assertion Failed');
            Test.stopTest();
        }
       
    }
    @IsTest
    static void testExceptionNullRequest(){
        List<User> clUserList = FICOCalloutTestHelper.getCLUserList('Ross Geller');
        
        System.runAs(clUserList[0]){
            Test.startTest();
            String req = FICORequestGeneratorHelper.generateFICORequestBody(null);
            System.assertEquals(false, req != null, 'Assertion Failed');
            Test.stopTest();
        }
       
    }
}