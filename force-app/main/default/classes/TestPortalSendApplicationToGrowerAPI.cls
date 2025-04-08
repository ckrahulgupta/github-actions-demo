/**
 * @description       : Test class for PortalSendApplicationToGrowerAPI
 * @author            : Arka Jyoti Debi
 * @group             : 
 * @last modified on  : 02-13-2025
 * @last modified by  : Rakesh Saraf
**/

@isTest
private with sharing class TestPortalSendApplicationToGrowerAPI {
    @testSetup
    static void setup(){
        genesis__Business_Information__c businessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();

        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{businessInfoObj,borrowerBusinessInfoObj},true);

        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoObj.id);
        dealerAccountObj.Enable_ERP_Id__c = true;
        Database.insert(dealerAccountObj,true);

        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);

        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        
        clcommon__Legal_Entity__c indlLegalEntityObj  = ApplicationOriginationTestHelper.createIndividualLegalEntity();

        clcommon__Legal_Entity__c corpLegalEntityObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();

        clcommon__Legal_Entity__c dbaLegalEntityObj  = ApplicationOriginationTestHelper.createDBALegalEntity();
        Database.insert(new List<clcommon__Legal_Entity__c>{legalEntityObj,indlLegalEntityObj,corpLegalEntityObj,dbaLegalEntityObj},true);

        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.ParentId = dealerAccountObj.Id;
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        borrowerAccountObj.CIF_Number__c = '123456';
        Database.insert(borrowerAccountObj,true);

        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        borrowerContactObj.genesis__SSN__c = '324242424';
        borrowerContactObj.Confirm_SSN__c = '324242424';

        //create dba account 
        Account dbaBorrowerAccountObj = ApplicationOriginationTestHelper.createDBAccount(dbaLegalEntityObj,borrowerBusinessInfoObj.id);
        dbaBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();

        Account accountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(businessInfoObj.id,dealerAccountObj.id);
        Database.insert(new List<Account>{dbaBorrowerAccountObj,accountObj},true);

        Contact contactObj = ApplicationOriginationTestHelper.createSalesAgentContact(accountObj.id);
        Database.insert(new List<Contact>{borrowerContactObj,contactObj},true);

        User salsAgentUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(contactObj.id);

        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInfoObj.id,dealerAccountObj.id);
        Database.insert(clAccountObj,true);

        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
        Database.insert(clContactObj,true);

        User userObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.id);
        Database.insert(new List<User>{salsAgentUserObj,userObj},true);

        genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(coBorrowerBusinessInfoObj,true);

        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(legalEntityObj,coBorrowerBusinessInfoObj.id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        coBorrowerAccountObj.CIF_Number__c = '385793';
        Database.insert(coBorrowerAccountObj,true);

        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        Database.insert(coBorrowerContactObj,true);

        Dealer_Applicant_Relationship__c dealerGrowerRel = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.id);
        Dealer_Applicant_Relationship__c dealerPrincipalRel = ApplicationOriginationTestHelper.createDealerApplicantRelationship(coBorrowerContactObj,dealerAccountObj.id);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{dealerPrincipalRel,dealerGrowerRel},true);

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(new Map<String,Object>{
                                                                                                                        'dealerAccountObjId' => dealerAccountObj.id,
                                                                                                                        'clProductObjId' => clProductObj.id,
                                                                                                                        'clPurposeObjId' => clPurposeObj.id,
                                                                                                                        'borrowerAccountObjId' => borrowerAccountObj.id,
                                                                                                                        'borrowerContactObjId' => borrowerContactObj.id,
                                                                                                                        'saAccountObjId' => accountObj.id
                                                                                                                    });
        applicationObj.Certified_Lender__c = clAccountObj.id;
        applicationObj.genesis__Product_Type__c ='Package';
        applicationObj.Dealer_Applicant_Relationship__c= dealerGrowerRel.id;
        Database.insert(applicationObj,true); 

        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');

        clcommon__Party_Type__c prPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');

        clcommon__Party_Type__c boPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(new List<clcommon__Party_Type__c>{clPartyTypeObj,prPartyTypeObj,boPartyTypeObj},true);

        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                                            'accountId' => borrowerAccountObj.id,
                                                                                                            'contactId' => borrowerContactObj.id,
                                                                                                            'partyTypeId' => boPartyTypeObj.id,
                                                                                                            'applicationId' => applicationObj.id
                                                                                                        });
        borrowerPartyObj.Dealer_Applicant_Relationship__C=dealerGrowerRel.id;
        borrowerPartyObj.clcommon__Party_Types__c='BORROWER';

        clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                                            'accountId' => coBorrowerAccountObj.id,
                                                                                                            'contactId' => coBorrowerContactObj.id,
                                                                                                            'partyTypeId' => prPartyTypeObj.id,
                                                                                                            'applicationId' => applicationObj.id
                                                                                                        });

        principalPartyObj.Dealer_Applicant_Relationship__c=dealerPrincipalRel.id;

        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                                    'accountId' => clAccountObj.id,
                                                                                                    'contactId' => clContactObj.id,
                                                                                                    'partyTypeId' => clPartyTypeObj.id,
                                                                                                    'applicationId' => applicationObj.id
                                                                                                });
        Database.insert(new List<clcommon__Party__c>{borrowerpartyObj,principalPartyObj,clPartyObj},true);

        clcommon__Reciprocal_Role__c saRoleObj = ApplicationOriginationTestHelper.createSalesAgentRole();

        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(new List<clcommon__Reciprocal_Role__c>{saRoleObj,clRoleObj}, true);
        
        //cl dealer relationship
        clcommon__Relationship__c clDealerRealtionObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj,dealerAccountObj.Id,
                                                                                                                                   clAccountObj.Id);

        //create sa dealer relationship
        clcommon__Relationship__c saDealerRealtionObj = ApplicationOriginationTestHelper.createSalesAgentDealerRelationship(saRoleObj,dealerAccountObj.Id,
                                                                                                                                                accountObj.Id);
        Database.insert(new List<clcommon__Relationship__c>{clDealerRealtionObj,saDealerRealtionObj}, true);

        createSecondGrower(legalEntityObj,borrowerBusinessInfoObj,businessInfoObj);
    
    }

    /**
    * @description create another borrower who has not any application
    * @author Rakesh Saraf | 12-17-2024 
    * @param legalEntityObj 
    * @param borrowerBusinessInfoObj 
    * @param businessInfoObj 
    **/
    private static void createSecondGrower(clcommon__Legal_Entity__c legalEntityObj,genesis__Business_Information__c borrowerBusinessInfoObj,genesis__Business_Information__c businessInfoObj){
        CFA_Configuration__c configurationObj = ApplicationOriginationTestHelper.createCIFNumber();
        configurationObj.CIF_Number__c = '1234567';
        configurationObj.Growmark_CIF_Number__c = '1234567';
        Database.insert(configurationObj, true);

        Account dealerAccountObj=[SELECT ID FROM ACCOUNT WHERE Name = 'Kisan Loan'];
        clcommon__Reciprocal_Role__c clRoleObj=[SELECT ID FROM clcommon__Reciprocal_Role__c WHERE Name = 'Certified Lender'];

        // create another borrower who has not any application
        Account growerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        growerAccountObj.clcommon__Email__c = 'skminsar@yopmail.com';
        growerAccountObj.ParentId = dealerAccountObj.Id;
        growerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        growerAccountObj.CIF_Number__c = '123466';
        Database.insert(growerAccountObj,true);

        Contact growerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(growerAccountObj.id);
        growerContactObj.Email = 'jasmin.albin001@yopmail.com';
        growerContactObj.Phone = '7453647284';
        growerContactObj.genesis__SSN__c = '324242496';
        growerContactObj.Confirm_SSN__c = '324242496';
        Database.insert(growerContactObj,true);

        //creating another dealer and cl 
        Account secondDealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoObj.id);
        secondDealerAccountObj.Name = 'Agrmi Loan';
        secondDealerAccountObj.Enable_ERP_Id__c = true;
        Database.insert(secondDealerAccountObj,true);
        
        //create cl
        Account secondClAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInfoObj.id,secondDealerAccountObj.id);
        secondClAccountObj.clcommon__Email__c = 'test.cfa@yopmail.com';
        Database.insert(secondClAccountObj,true);

        Contact secondClContactObj = ApplicationOriginationTestHelper.createCLContact(secondClAccountObj.id);
        Database.insert(secondClContactObj,true);

        User secondUserObj = ApplicationOriginationTestHelper.createCLUser(secondClContactObj.id);
        secondUserObj.UserName = 'test.cfa@yopmail.com';
        Database.insert(secondUserObj,true);

        //cl dealer relationship
        clcommon__Relationship__c secondClDealerRealtionObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj,secondDealerAccountObj.Id,
                                                                                                                                            secondClAccountObj.Id);
        Database.insert(secondClDealerRealtionObj, true);
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 08-01-2025 
    * @return clcommon__Legal_Entity__c 
    **/
    private static clcommon__Legal_Entity__c getLegalEntity(){
        return [SELECT Id 
                FROM clcommon__Legal_Entity__c 
                WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship' 
                LIMIT 1];
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 08-01-2025 
    * @return clcommon__Legal_Entity__c 
    **/
    private static clcommon__Legal_Entity__c getLegalEntityDBA(){
        return [SELECT Id 
                FROM clcommon__Legal_Entity__c 
                WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) with DBA' 
                LIMIT 1];
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 08-01-2025 
    * @return clcommon__Legal_Entity__c 
    **/
    private static clcommon__Legal_Entity__c getLegalEntityCorporation(){
        return [SELECT Id 
                FROM clcommon__Legal_Entity__c 
                WHERE clcommon__Legal_Entity_Type__c = 'Corporation' 
                LIMIT 1];
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 08-01-2025 
    * @return Account 
    **/
    private static Account getBorrowerAccount(){
        return [SELECT Id,
                        clcommon__Legal_Entity_Type__c,
                        genesis__business_information__r.genesis__Tax_Identification_Number__c,
                        Non_Accrual__c,
                        Has_Past_Due__c
                FROM Account 
                WHERE clcommon__Email__c ='jasmin.albin@yopmail.com' 
                LIMIT 1];
    }

    /**
    * @description Success scenario for new grower for sole prop entity
    * @author Ravi Ranjan | 04-02-2024 
    **/
    @isTest
    private static void testNewGrowerForSoleProp() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntity();
        requestMap.put('email', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Email__c', 'david.tom@yopmail.com');
        requestMap.put('Confirm_SSN__c', '885679210');
        requestMap.put('MobilePhone', '1111111111');
        requestMap.put('clcommon__email__c', 'david.tom@yopmail.com');
        requestMap.put('firstName', 'Tom');
        requestMap.put('lastName', 'David');
        requestMap.put('loanAmount', 100000);
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Tom');
        requestMap.put('genesis__SSN__c','885679210');
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description Success scenario for Growmark grower for sole prop entity
    * @author Ravi Ranjan | 04-03-2024 
    **/
    @isTest
    private static void testNewGrowerForGrowmarkSoleProp() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Account dealeraccObj = [SELECT Id, 
                                       Coop_Type__c
                                FROM Account
                                WHERE Name = 'Kisan Loan'
                                LIMIT 1];
        dealeraccObj.Coop_Type__c = 'Growmark';
        Database.update(dealeraccObj, true);
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntity();
        requestMap.put('email', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Email__c', 'david.tom@yopmail.com');
        requestMap.put('Confirm_SSN__c', '885679210');
        requestMap.put('MobilePhone', '1111111111');
        requestMap.put('clcommon__email__c', 'david.tom@yopmail.com');
        requestMap.put('firstName', 'Tom');
        requestMap.put('lastName', 'David');
        requestMap.put('loanAmount', 100000);
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Tom');
        requestMap.put('genesis__SSN__c','885679210');
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description check exception when a grower is created with same ssn
    * @author Ravi Ranjan | 04-02-2024 
    **/
    @isTest
    private static void checkExceptionWithExistingSSNSoleProp() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = [SELECT Id,UserName
                        FROM User
                        WHERE UserName = 'ross.geller@yopmail.com'];
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntity();
        requestMap.put('email', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Email__c', 'david.tom@yopmail.com');
        requestMap.put('Confirm_SSN__c', '324242424');
        requestMap.put('MobilePhone', '1111111111');
        requestMap.put('clcommon__email__c', 'david.tom@yopmail.com');
        requestMap.put('firstName', 'Tom');
        requestMap.put('lastName', 'David');
        requestMap.put('loanAmount', 100000);
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Tom');
        requestMap.put('genesis__SSN__c','324242424');
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description Creating a new application for a new dba with new primary applicant
    * @author Ravi Ranjan | 04-02-2024 
    **/
    @isTest
    private static void testNewGrowerForDBA() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntityDBA();
        requestMap.put('email', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Email__c', 'david.tom@yopmail.com');
        requestMap.put('Confirm_SSN__c', '885679211');
        requestMap.put('DBAName', 'Cosmus');
        requestMap.put('MobilePhone', '1111111111');
        requestMap.put('clcommon__email__c', 'david.tom@yopmail.com');
        requestMap.put('firstName', 'Tom');
        requestMap.put('lastName', 'David');
        requestMap.put('loanAmount', 100000);
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Tom');
        requestMap.put('genesis__SSN__c','885679211');
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description Creating a new application for Gorowmark for a new dba with new primary applicant
    * @author Ravi Ranjan | 04-03-2024 
    **/
    @isTest
    private static void testNewGrowerForGrowmarkDBA() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Account dealeraccObj = [SELECT Id, 
                                       Coop_Type__c
                                FROM Account
                                WHERE Name = 'Kisan Loan'
                                LIMIT 1];
        dealeraccObj.Coop_Type__c = 'Growmark';
        Database.update(dealeraccObj, true);
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntityDBA();
        requestMap.put('email', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Email__c', 'david.tom@yopmail.com');
        requestMap.put('Confirm_SSN__c', '885679211');
        requestMap.put('DBAName', 'Cosmus');
        requestMap.put('MobilePhone', '1111111111');
        requestMap.put('clcommon__email__c', 'david.tom@yopmail.com');
        requestMap.put('firstName', 'Tom');
        requestMap.put('lastName', 'David');
        requestMap.put('loanAmount', 100000);
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Tom');
        requestMap.put('genesis__SSN__c','885679211');
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description  Creating a new application for a new DBA with existing primary applicant in same dealer,same coop
    * @author Ravi Ranjan | 04-02-2024 
    **/
    @isTest
    private static void testNewGrowerForDBAWithExistingApplicant() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntityDBA();
        requestMap.put('email', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Email__c', 'david.tom@yopmail.com');
        requestMap.put('Confirm_SSN__c', '982983834');
        requestMap.put('DBAName', 'Cosmus');
        requestMap.put('MobilePhone', '1111111111');
        requestMap.put('clcommon__email__c', 'david.tom@yopmail.com');
        requestMap.put('firstName', 'Tom');
        requestMap.put('lastName', 'David');
        requestMap.put('loanAmount', 100000);
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Tom');
        requestMap.put('genesis__SSN__c','982983834');
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description Creating a new application for a new DBA with existing primary applicant in different dealer,same coop
    * @author Ravi Ranjan | 04-02-2024 
    **/
    @isTest
    private static void testNewGrowerForDBAWithExistingApplicantDifferentDealer() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = [SELECT Id
                        FROM User
                        WHERE UserName = 'test.cfa@yopmail.com'];
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntityDBA();
        requestMap.put('email', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Email__c', 'david.tom@yopmail.com');
        requestMap.put('Confirm_SSN__c', '982983834');
        requestMap.put('DBAName', 'Cosmus');
        requestMap.put('MobilePhone', '1111111111');
        requestMap.put('clcommon__email__c', 'david.tom@yopmail.com');
        requestMap.put('firstName', 'Tom');
        requestMap.put('lastName', 'David');
        requestMap.put('loanAmount', 100000);
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Tom');
        requestMap.put('genesis__SSN__c','982983834');
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description Creating a new application for new DBA with existing primary applicant in different coop 
    * @author Ravi Ranjan | 04-02-2024 
    **/
    @isTest
    private static void testNewGrowerForDBAWithExistingApplicantDifferentDealerAndCoop() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Account dealeraccObj = [SELECT Id, 
                                       Coop_Type__c
                                FROM Account
                                WHERE Name = 'Kisan Loan'
                                LIMIT 1];
        dealeraccObj.Coop_Type__c = 'Growmark';
        Database.update(dealeraccObj, true);   
        User userObj = [SELECT Id
                        FROM User
                        WHERE UserName = 'test.cfa@yopmail.com'];
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntityDBA();
        requestMap.put('email', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Email__c', 'david.tom@yopmail.com');
        requestMap.put('Confirm_SSN__c', '982983834');
        requestMap.put('DBAName', 'Cosmus');
        requestMap.put('MobilePhone', '1111111111');
        requestMap.put('clcommon__email__c', 'david.tom@yopmail.com');
        requestMap.put('firstName', 'Tom');
        requestMap.put('lastName', 'David');
        requestMap.put('loanAmount', 100000);
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Tom');
        requestMap.put('genesis__SSN__c','982983834');
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description Creating a new application for an existing DBA in different dealer, same coop with a new primary applicant
    * @author Ravi Ranjan | 04-02-2024 
    **/
    @isTest
    private static void testExistingGrowerForDBAWithNewApplicantDifferentDealerAndCoop() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Account dealeraccObj = [SELECT Id, 
                                       Coop_Type__c
                                FROM Account
                                WHERE Name = 'Agrmi Loan'
                                LIMIT 1];
        dealeraccObj.Coop_Type__c = 'Growmark';
        Database.update(dealeraccObj, true);   
        User userObj = [SELECT Id
                        FROM User
                        WHERE UserName = 'test.cfa@yopmail.com'];
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntityDBA();
        requestMap.put('email', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Email__c', 'david.tom@yopmail.com');
        requestMap.put('Confirm_SSN__c', '345673456');
        requestMap.put('DBAName', 'Warner Farms');
        requestMap.put('MobilePhone', '1111111111');
        requestMap.put('clcommon__email__c', 'david.tom@yopmail.com');
        requestMap.put('firstName', 'Tom');
        requestMap.put('lastName', 'David');
        requestMap.put('loanAmount', 100000);
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Tom');
        requestMap.put('genesis__SSN__c','345673456');
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description Creating an application for an existing individual (i.e, using the same SSN) in same dealer, same coop from 'Add new grower'
    * @author Ravi Ranjan | 04-02-2024 
    **/
    @isTest
    private static void testExistingGrowerSoleProp() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntity();
        Account borrowerAccountObj = getBorrowerAccount();
        requestMap.put('email', 'akash.das@yopmail.com');
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Akash');
        requestMap.put('lastName', 'Das');
        requestMap.put('loanAmount', 2000);
        requestMap.put('companyName','ABY XYZ');
        requestMap.put('accountId',borrowerAccountObj.id);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description Creating an application for an existing individual (i.e, using the same SSN) in same dealer, who don't have any application
    * @author Ravi Ranjan | 04-02-2024 
    **/
    @isTest
    private static void testExistingGrowerSolePropWithoutApplication() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntity();
        Account borrowerAccountObj = [SELECT ID 
                                      FROM ACCOUNT 
                                      WHERE clcommon__Email__c ='skminsar@yopmail.com' 
                                      LIMIT 1];
        requestMap.put('email', 'akash.das@yopmail.com');
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Akash');
        requestMap.put('lastName', 'Das');
        requestMap.put('loanAmount', 2000);
        requestMap.put('companyName','ABY XYZ');
        requestMap.put('accountId',borrowerAccountObj.id);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description Creating an application for an existing individual (i.e, using the same SSN) in different coop 
    * @author Ravi Ranjan | 04-02-2024 
    **/
    @isTest
    private static void testExistingGrowerSolePropForDifferentCoop() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Account dealeraccObj = [SELECT Id, 
                                       Coop_Type__c
                                FROM Account
                                WHERE Name = 'Kisan Loan'
                                LIMIT 1];
        dealeraccObj.Coop_Type__c = 'Growmark';
        Database.update(dealeraccObj, true);   
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntity();
        Account borrowerAccountObj = getBorrowerAccount();
        requestMap.put('email', 'akash.das@yopmail.com');
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Akash');
        requestMap.put('lastName', 'Das');
        requestMap.put('loanAmount', 2000);
        requestMap.put('companyName','ABY XYZ');
        requestMap.put('accountId',borrowerAccountObj.id);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description Creating an application for an existing individual (i.e, using the same SSN) in different dealer, same coop
    * @author Ravi Ranjan | 04-02-2024 
    **/
    @isTest
    private static void testExistingGroweDifferentDealerSoleProp() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntity();
        Contact borrowerContactObj = [SELECT Id,
                                                genesis__SSN__c
                                        FROM Contact
                                        WHERE genesis__SSN__c = '324242424'];                            
        requestMap.put('email', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Email__c', 'david.tom@yopmail.com');
        requestMap.put('Confirm_SSN__c', borrowerContactObj.genesis__SSN__c);
        requestMap.put('DBAName', 'Warner Farms');
        requestMap.put('MobilePhone', '1111111111');
        requestMap.put('clcommon__email__c', 'david.tom@yopmail.com');
        requestMap.put('firstName', 'Tom');
        requestMap.put('lastName', 'David');
        requestMap.put('loanAmount', 100000);
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Tom');
        requestMap.put('genesis__SSN__c',borrowerContactObj.genesis__SSN__c);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
   
    /**
    * @description Success scenario for sole prop active application for existing grower
    * @author Ravi Ranjan | 04-02-2024 
    **/
    @isTest
    private static void testExistingGrowerActiveApplicationSoleProp() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntity();
        genesis__Applications__c applicationObj  = [SELECT ID,
                                                           genesis__Status__c 
                                                    FROM genesis__Applications__c
                                                    WHERE genesis__Loan_Number__c = '398762543' 
                                                    LIMIT 1];
        applicationObj.genesis__Status__c = 'ACTIVE';
        Database.update(applicationObj,true);
        Account borrowerAccountObj = getBorrowerAccount();
        requestMap.put('email', 'akash.das@yopmail.com');
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Akash');
        requestMap.put('lastName', 'Das');
        requestMap.put('loanAmount', 2000);
        requestMap.put('companyName','ABY XYZ');
        requestMap.put('accountId',borrowerAccountObj.id);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description Creating a new application for a new corporation and new primary applicant
    * @author Ravi Ranjan | 04-02-2024 
    **/
    @isTest
    private static void testNewGrowerCorporation() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntityCorporation();
        requestMap.put('email', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Email__c', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Tax_Identification_Number__c', '838828789');
        requestMap.put('companyName', 'conjuct');
        requestMap.put('Confirm_SSN__c', '938478478');
        requestMap.put('genesis__Tax_Identification_Number__c', '838828789');
        requestMap.put('DBAName', 'Warner Farms');
        requestMap.put('MobilePhone', '1111111111');
        requestMap.put('clcommon__email__c', 'david.tom@yopmail.com');
        requestMap.put('firstName', 'Tom');
        requestMap.put('lastName', 'David');
        requestMap.put('loanAmount', 100000);
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Tom');
        requestMap.put('genesis__SSN__c','938478478');
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description Creating a new application for Growmark for a new corporation and new primary applicant
    * @author Ravi Ranjan | 04-03-2024 
    **/
    @isTest
    private static void testNewGrowmarkGrowerCorporation() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Account dealeraccObj = [SELECT Id,
                                      Coop_Type__c
                                FROM Account
                                WHERE Name = 'Kisan Loan'
                                LIMIT 1];
        dealeraccObj.Coop_Type__c = 'Growmark';
        Database.update(dealeraccObj, true);
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntityCorporation();
        requestMap.put('email', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Email__c', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Tax_Identification_Number__c', '838828789');
        requestMap.put('companyName', 'conjuct');
        requestMap.put('Confirm_SSN__c', '938478478');
        requestMap.put('genesis__Tax_Identification_Number__c', '838828789');
        requestMap.put('DBAName', 'Warner Farms');
        requestMap.put('MobilePhone', '1111111111');
        requestMap.put('clcommon__email__c', 'david.tom@yopmail.com');
        requestMap.put('firstName', 'Tom');
        requestMap.put('lastName', 'David');
        requestMap.put('loanAmount', 100000);
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Tom');
        requestMap.put('genesis__SSN__c','938478478');
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description check exception when a grower is created with same TIN
    * @author Ravi Ranjan | 04-03-2024 
    **/
    @isTest
    private static void testExceptionSameDelaerCorporation() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Business_Information__c borrowerbussinessInfoObj = [SELECT Id,
                                                                         genesis__Tax_Identification_Number__c
                                                                    FROM genesis__Business_Information__c
                                                                    WHERE genesis__Tax_Identification_Number__c = '122334556'
                                                                    LIMIT 1];
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntityCorporation();
        Account borrowerAccountObj = getBorrowerAccount();
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = legalEntityObj.Id;
        Database.update(borrowerAccountObj, true);
        requestMap.put('email', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Email__c', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Tax_Identification_Number__c', borrowerbussinessInfoObj.genesis__Tax_Identification_Number__c);
        requestMap.put('companyName', 'conjuct');
        requestMap.put('Confirm_SSN__c', '938478470');
        requestMap.put('genesis__Tax_Identification_Number__c', borrowerbussinessInfoObj.genesis__Tax_Identification_Number__c);
        requestMap.put('DBAName', 'Warner Farms');
        requestMap.put('MobilePhone', '1111111111');
        requestMap.put('clcommon__email__c', 'david.tom@yopmail.com');
        requestMap.put('firstName', 'Tom');
        requestMap.put('lastName', 'David');
        requestMap.put('loanAmount', 100000);
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Tom');
        requestMap.put('genesis__SSN__c','938478470');
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description Creating an application for and existing corporation in same dealer, same coop
    * @author Ravi Ranjan | 04-02-2024 
    **/
    @isTest
    private static void testExistingCorporationSameCoop() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntityCorporation();
        Account borrowerAccountObj = getBorrowerAccount();
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = legalEntityObj.Id;
        Database.update(borrowerAccountObj, true);                               
        requestMap.put('email', 'akash.das@yopmail.com');
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Akash');
        requestMap.put('lastName', 'Das');
        requestMap.put('loanAmount', 2000);
        requestMap.put('companyName','ABY XYZ');
        requestMap.put('accountId',borrowerAccountObj.id);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description Test Exception for corporation grower having existing Account not associated to any application
    * @author Ravi Ranjan | 04-03-2024 
    **/
    @isTest
    private static void testExceptionForCorporationWithoutApplication() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntityCorporation();
        Account borrowerAccountObj = [SELECT Id,
                                             clcommon__Legal_Entity_Type__c
                                      FROM Account 
                                      WHERE clcommon__Email__c ='skminsar@yopmail.com' 
                                      LIMIT 1];
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = legalEntityObj.Id;
        Database.update(borrowerAccountObj, true);                               
        requestMap.put('email', 'akash.das@yopmail.com');
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Akash');
        requestMap.put('lastName', 'Das');
        requestMap.put('loanAmount', 2000);
        requestMap.put('companyName','ABY XYZ');
        requestMap.put('accountId',borrowerAccountObj.id);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description Creating an application for and existing corporation in different dealer, same coop
    * @author Ravi Ranjan | 04-02-2024 
    **/
    @isTest
    private static void testExistingCorporationDifferentDealerSameCoop() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = [SELECT Id
                        FROM User
                        WHERE UserName = 'test.cfa@yopmail.com'];

        List<Account> dealerAcc=[select id,Coop_Type__c from account where name='Kisan Loan' limit 1];
        
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntityCorporation();
        genesis__Business_Information__c businessInfoList = [SELECT Id,
                                                                  genesis__Tax_Identification_Number__c
                                                            FROM genesis__Business_Information__c
                                                            WHERE genesis__Tax_Identification_Number__c = '122334556'
                                                            LIMIT 1];

        genesis__Business_Information__c businessInfoObj=ApplicationOriginationTestHelper.createBusinessInfoForPrincipal();
        businessInfoObj.genesis__Tax_Identification_Number__c='122334556';
        businessInfoObj.Confirm_Tax_Identification_Number__c='122334556';
        Database.insert(businessInfoObj);

        Account accountObj=ApplicationOriginationTestHelper.createAccount();
        accountObj.genesis__Business_Information__c=businessInfoObj.id;
        accountObj.ParentId=dealerAcc[0].id;
        Database.insert(accountObj,true);

        Contact contactObj=ApplicationOriginationTestHelper.createContact();
        contactObj.AccountId=accountObj.id;
        Database.insert(contactObj,true);
        Account borrowerAccountObj = getBorrowerAccount();
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = legalEntityObj.Id;
        Database.update(borrowerAccountObj, true);                               
        requestMap.put('email', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Email__c', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Tax_Identification_Number__c', businessInfoList.genesis__Tax_Identification_Number__c);
        requestMap.put('companyName', 'conjuct');
        requestMap.put('Confirm_SSN__c', '938478478');
        requestMap.put('genesis__Tax_Identification_Number__c', businessInfoList.genesis__Tax_Identification_Number__c);
        requestMap.put('DBAName', 'Warner Farms');
        requestMap.put('MobilePhone', '1111111111');
        requestMap.put('clcommon__email__c', 'david.tom@yopmail.com');
        requestMap.put('firstName', 'Tom');
        requestMap.put('lastName', 'David');
        requestMap.put('loanAmount', 100000);
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Tom');
        requestMap.put('genesis__SSN__c','938478478');
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
      /**
    * @description  Creating and application for a new corporation with existing primary applicant in same dealer, same coop
    * @author Ravi Ranjan | 04-02-2024 
    **/
    @isTest
    private static void testnewCorporationExistingPrimaryApplicantSameDealer() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntityCorporation();
        Contact borrowerContactObj = [SELECT Id,
                                            genesis__SSN__c
                                      FROM Contact
                                      WHERE genesis__SSN__c = '324242424'];
        requestMap.put('email', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Email__c', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Tax_Identification_Number__c', '838828789');
        requestMap.put('companyName', 'conjuct');
        requestMap.put('Confirm_SSN__c', borrowerContactObj.genesis__SSN__c);
        requestMap.put('genesis__Tax_Identification_Number__c', '838828789');
        requestMap.put('DBAName', 'Warner Farms');
        requestMap.put('MobilePhone', '1111111111');
        requestMap.put('clcommon__email__c', 'david.tom@yopmail.com');
        requestMap.put('firstName', 'Tom');
        requestMap.put('lastName', 'David');
        requestMap.put('loanAmount', 100000);
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Tom');
        requestMap.put('genesis__SSN__c',borrowerContactObj.genesis__SSN__c);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description Creating and application for a new corporation with existing primary applicant in different dealer, same coop
    * @author Ravi Ranjan | 04-03-2024 
    **/
    @isTest
    private static void testnewCorporationExistingPrimaryApplicantDifferentDealer() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = [SELECT Id
                        FROM User
                        WHERE UserName = 'test.cfa@yopmail.com'];
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntityCorporation();
        Contact borrowerContactObj = [SELECT Id,
                                                genesis__SSN__c
                                      FROM Contact
                                      WHERE genesis__SSN__c = '324242424'];
        Account borrowerAccountObj = getBorrowerAccount();
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = legalEntityObj.Id;
        Database.update(borrowerAccountObj, true);                               
        requestMap.put('email', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Email__c', 'david.tom@yopmail.com');
        requestMap.put('Confirm_Tax_Identification_Number__c', '838828789');
        requestMap.put('companyName', 'conjuct');
        requestMap.put('Confirm_SSN__c', borrowerContactObj.genesis__SSN__c);
        requestMap.put('genesis__Tax_Identification_Number__c', '838828789');
        requestMap.put('DBAName', 'Warner Farms');
        requestMap.put('MobilePhone', '1111111111');
        requestMap.put('clcommon__email__c', 'david.tom@yopmail.com');
        requestMap.put('firstName', 'Tom');
        requestMap.put('lastName', 'David');
        requestMap.put('loanAmount', 100000);
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Tom');
        requestMap.put('genesis__SSN__c',borrowerContactObj.genesis__SSN__c);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description Success scenario for corporation active application for existing grower
    * @author Ravi Ranjan | 04-02-2024 
    **/
    @isTest
    private static void testPortalSendApplicationToGrowerAPISuccessForCorporation() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntityCorporation();
        genesis__Applications__c applicationObj  = [SELECT ID,
                                                           genesis__Status__c 
                                                    FROM genesis__Applications__c
                                                    WHERE genesis__Loan_Number__c = '398762543' 
                                                    LIMIT 1];
        applicationObj.genesis__Status__c = 'ACTIVE';
        Database.update(applicationObj,true);
        Account borrowerAccountObj = getBorrowerAccount();
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = legalEntityObj.Id;
        Database.update(borrowerAccountObj, true);                              
        requestMap.put('email', 'akash.das@yopmail.com');
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Akash');
        requestMap.put('lastName', 'Das');
        requestMap.put('loanAmount', 2000);
        requestMap.put('companyName','ABY XYZ');
        requestMap.put('accountId',borrowerAccountObj.id);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description Success scenario for individual existing grower
    * @author Ravi Ranjan | 04-02-2024 
    **/
    @isTest
    private static void testPortalSendApplicationToGrowerAPISuccessForIndividual() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = [SELECT Id 
                                                    FROM clcommon__Legal_Entity__c 
                                                    WHERE clcommon__Legal_Entity_Type__c = 'Individual' 
                                                    LIMIT 1];
        genesis__Applications__c applicationObj  = [SELECT ID,
                                                           genesis__Status__c 
                                                    FROM genesis__Applications__c 
                                                    LIMIT 1];
        Account borrowerAccountObj = getBorrowerAccount();
        requestMap.put('email', 'akash.das@yopmail.com');
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Akash');
        requestMap.put('lastName', 'Das');
        requestMap.put('loanAmount', 2000);
        requestMap.put('companyName','ABY XYZ');
        requestMap.put('accountId',borrowerAccountObj.id);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            PortalApplicationOriginationHelper.sendEmailToGrower(borrowerAccountObj.Id, 'testcldealer@yopmail.com',applicationObj);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description check exception under sales agent user for new grower creation
    * @author Ravi Ranjan | 04-03-2024 
    **/
    @isTest
    private static void testExceptionNewGrowerSolePropSalesAgentUser() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = [SELECT Id 
                        FROM User
                        WHERE UserName = 'tony.stark@yopmail.com' 
                        LIMIT 1];
        clcommon__Legal_Entity__c legalEntityObj = [SELECT Id 
                                                    FROM clcommon__Legal_Entity__c 
                                                    WHERE clcommon__Legal_Entity_Type__c = 'Individual' 
                                                    LIMIT 1];
        legalEntityObj.clcommon__Legal_Entity_Type__c = 'C Corporation';
        Database.update(legalEntityObj, true);
        Account borrowerAccountObj = getBorrowerAccount();
        requestMap.put('email', 'akash.das@yopmail.com');
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('companyName', 'Apple');
        requestMap.put('loanAmount', 2000);
        requestMap.put('accountId',borrowerAccountObj.Id);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    
    /**
    * @description check exception under sales agent user for existing grower creation
    * @author Ravi Ranjan | 04-03-2024 
    **/
    @isTest
    private static void testExceptionExistingGrowerSoleProp() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = [SELECT Id,
                               ContactId
                        FROM User
                        WHERE UserName = 'tony.stark@yopmail.com' 
                        LIMIT 1];
        clcommon__Legal_Entity__c legalEntityObj = [SELECT Id 
                                                    FROM clcommon__Legal_Entity__c 
                                                    WHERE clcommon__Legal_Entity_Type__c = 'Individual' 
                                                    LIMIT 1];
        Contact contactObj = [SELECT Id, accountId FROM Contact WHERE Id =:userObj.ContactId];
        contactObj.Email='absh@yopmail.com';
        Database.update(contactObj,true);
        Account borrowerAccountObj = getBorrowerAccount();
        requestMap.put('email', 'akash.das@yopmail.com');
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('companyName', 'Apple');
        requestMap.put('loanAmount', 2000);
        requestMap.put('accountId',borrowerAccountObj.Id);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description check exception when required parameter missing
    * @author Ravi Ranjan | 04-03-2024 
    **/
    @isTest
    private static void testPortalParamMissingApiException() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('email', 'akash.das@yopmail.com');
        requestMap.put('entityType', 'saas113');
        requestMap.put('firstName', 'Akash');
        requestMap.put('lastName', 'Das');
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }

    @isTest
    private static void testExistingGrowerWithNonAccrual() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntity();
        Account borrowerAccountObj = getBorrowerAccount();
        Dealer_Applicant_Relationship__c dealerGrowerRel=[SELECT ID ,
                                                                 Is_Non_Accrual__c
                                                            FROM Dealer_Applicant_Relationship__c 
                                                            WHERE Applicant__c=:borrowerAccountObj.id];
        dealerGrowerRel.Is_Non_Accrual__c=true;
        Database.update(dealerGrowerRel,true);

        requestMap.put('email', 'akash.das@yopmail.com');
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Akash');
        requestMap.put('lastName', 'Das');
        requestMap.put('loanAmount', 2000);
        requestMap.put('companyName','ABY XYZ');
        requestMap.put('accountId',borrowerAccountObj.id);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }

    @isTest
    private static void testExistingGrowerWithPastDue() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntity();
        Account borrowerAccountObj = getBorrowerAccount();
        clcommon__Party__c borrowerParty=[select id,clcommon__Account__c,dealer_applicant_relationship__c from clcommon__Party__c where clcommon__Account__c= :borrowerAccountObj.id];
        
        List<Dealer_Applicant_Relationship__c> dealerGrowerRel =[SELECT ID,
                                                                        Is_Non_Accrual__c,
                                                                        Has_Past_Due__c
                                                                FROM Dealer_Applicant_Relationship__c
                                                                WHERE id=:borrowerParty.dealer_applicant_relationship__c];

        dealerGrowerRel[0].Has_Past_Due__c = true;
        Database.update(dealerGrowerRel,true);

        requestMap.put('email', 'akash.das@yopmail.com');
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Akash');
        requestMap.put('lastName', 'Das');
        requestMap.put('loanAmount', 2000);
        requestMap.put('companyName','ABY XYZ');
        requestMap.put('accountId',borrowerParty.clcommon__Account__c);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
    
    /**
    * @description Creating an application for an existing individual (i.e, using the same SSN) in same dealer, same coop from 'Add new grower' but one of the principals dont have a dar.
    * @author Rakesh Saraf | 12-12-2024 
    **/
    @isTest
    private static void testExistingGrowerNoDAR() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c legalEntityObj = getLegalEntity();
        Account borrowerAccountObj = getBorrowerAccount();

        Dealer_Applicant_Relationship__C dealerAppREl=[SELECT ID
                                                        FROM Dealer_Applicant_Relationship__c
                                                        WHERE Applicant__c != :borrowerAccountObj.id];
        Database.delete(dealerAppREl,true);

        requestMap.put('email', 'akash.das@yopmail.com');
        requestMap.put('entityType', legalEntityObj.Id);
        requestMap.put('firstName', 'Akash');
        requestMap.put('lastName', 'Das');
        requestMap.put('loanAmount', 2000);
        requestMap.put('companyName','ABY XYZ');
        requestMap.put('accountId',borrowerAccountObj.id);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendApplicationToGrowerAPI testApi = new PortalSendApplicationToGrowerAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
            Test.stopTest();
        }
    }
}