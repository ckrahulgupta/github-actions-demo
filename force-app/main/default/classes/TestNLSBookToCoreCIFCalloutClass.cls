/**
 * @description       : Test class for NLSBookToCoreCIFCalloutClass and NLSBookToCoreCIFCalloutAdapter
 * @author            : E. Shalini
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : Ayush Kumar Singh
**/
@isTest
public with sharing class TestNLSBookToCoreCIFCalloutClass {
   
    @testSetup
    static void setup() {
            // Creating floating rate index
            clcommon__Floating_Rate_Index__c floatingRateIndexObj = ApplicationOriginationTestHelper.createFloatingRateIndex(new Map<String, Object>{ 'Name' => 'CFA Advantage Rate',
                                                                                                                                                            'Base Rate Name' => '4-CFA ADVANTAGE',
                                                                                                                                                            'Current Floating Rate' => 11,
                                                                                                                                                            'Base Rate Adjuster' => 5.5
                                                                                                                                });
            Database.insert(floatingRateIndexObj, true);
    
            // Creating floating rate
            clcommon__Floating_Rate__c floatingRateObj = ApplicationOriginationTestHelper.createFloatingRate(floatingRateIndexObj);
            Database.insert(floatingRateObj, true);
    
            // Creating new partnert program
            CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
            Database.insert(newPartnerProgramObj, true);
    
            // Creating Business Information
            genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
    
            //creating business info for borrower and principal
            genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
            borrowerBusinessInfoObj.genesis__Tax_Identification_Number__c = '333333333';
            genesis__Business_Information__c principalBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
    
            Database.insert(new List<genesis__Business_Information__c>{
            dealerBusinessInfoObj,
            borrowerBusinessInfoObj,
            principalBusinessInfoObj
            }, true);


            User adminUserObj = ApplicationOriginationTestHelper.createAdminUser('testdealerprodadportfoliomgr@yopmail.com');
            Database.Insert(adminUserObj, true);

            // Creating Account for Dealer
            Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
            dealerAccountObj.CFA_Partner_Program__c = newPartnerProgramObj.Id;
            dealerAccountObj.Production_Ag_loan_officer__c = adminUserObj.id;
            Database.insert(dealerAccountObj, true);
    
            // Creating Legal Entity for Borrower

            clcommon__Legal_Entity__c entityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
            clcommon__Legal_Entity__c corpLegalEntityObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
            clcommon__Legal_Entity__c dbaLegalEntityObj  = ApplicationOriginationTestHelper.createDBALegalEntity();
            Database.insert(new List<clcommon__Legal_Entity__c>{entityObj, corpLegalEntityObj, dbaLegalEntityObj}, true);
    
            // Creating Account for Certified Lender
            Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
    
            // Creating Account for Borrower
            Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
            borrowerAccountObj.BillingStreet = 'Action area 1';
            borrowerAccountObj.BillingPostalCode = '24234';
            borrowerAccountObj.CIF_Number__c = '349872';

            // Creating CoApplicant Account
            Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(entityObj,principalBusinessInfoObj.Id);
            coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
    
            //Creating Co-Applicant contact
           
            Database.insert(new List<Account>{
                clAccountObj,
                borrowerAccountObj,
                coBorrowerAccountObj
            }, true);
    
            // Creating Contact for Certified Lender
            Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
    
            // Creating Contact for Borrower
            Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
            borrowerContactObj.genesis__SSN__c = '333333333';
            borrowerContactObj.Confirm_SSN__c = '333333333';

            Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.Id);
            borrowerContactObj.genesis__SSN__c = '444444444';
            borrowerContactObj.Confirm_SSN__c = '444444444';
    
            Database.insert(new List<Contact>{
                clContactObj,
                borrowerContactObj,
                coBorrowerContactObj
            },true);
    
            User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
            User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
            Database.insert(new List<User>{
                clUserObj,
                borrowerUserObj
            },true);
    
            // Creating CL Purpose of Application
            clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
            Database.insert(clPurposeObj, true);
    
            // Creating Cl Product of Application
            clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
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
            genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
            applicationObj.Agreement_Sign__c = true;
            Database.insert(applicationObj, true);
    
            // Creating Reciprocal Role 
            clcommon__Reciprocal_Role__c roleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
            Database.insert(roleObj, true);
    
            // Creating Relationship between Dealer and Certified Lender
            clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
            Database.insert(clDealerRelationshipObj, true);
    
            // Creating Certified Lender Party Type
            clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
    
            // Create Borrower Party Type
            clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
            clcommon__Party_Type__c coBorrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
            Database.insert(new List<clcommon__Party_Type__c>{
                clPartyTypeObj,
                borrowerPartyTypeObj,
                coBorrowerPartyTypeObj
            }, true);
    
            // Creating Certified Lender Party
            Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
                'accountId' => clAccountObj.Id,
                'contactId' => clContactObj.Id,
                'partyTypeId' => clPartyTypeObj.Id,
                'applicationId' => applicationObj.Id
            };
    
            List<clcommon__Party__c> partyObjList = new List<clcommon__Party__c>();
    
            partyObjList.add(ApplicationOriginationTestHelper.createParty(paramForCLPartyMap));
    
            Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
                'accountId' => borrowerAccountObj.Id,
                'contactId' => borrowerContactObj.Id,
                'partyTypeId' => borrowerPartyTypeObj.Id,
                'applicationId' => applicationObj.Id
            };
            clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createApplicantParty(paramForBorrowerPartyMap,borrowerAccountObj);
            borrowerPartyObj.clcommon__Party_Types__c = ConstantValues.BORROWER_PARTY;
            partyObjList.add(borrowerPartyObj);
    
            ApplicationOriginationSetupTestHelper.createSaSaAdminTestData(dealerBusinessInfoObj,dealerAccountObj);
            ApplicationOriginationSetupTestHelper.createAdditionalTestData(applicationObj,dealerAccountObj);
    
            ApplicationOriginationSetupTestHelper.createAdditionalInfoParty(applicationObj, entityObj,borrowerBusinessInfoObj);

    
            Map<String,Id> coBorrowerPartyMap = new Map<String,Id>{
                'accountId' => coBorrowerAccountObj.Id,
                'contactId' => coBorrowerContactObj.Id,
                'partyTypeId' => borrowerPartyTypeObj.Id,
                'applicationId' => applicationObj.Id
            };
            clcommon__Party__c coBorrowerPartyObj = ApplicationOriginationTestHelper.createApplicantParty(coBorrowerPartyMap,coBorrowerAccountObj);
            coBorrowerPartyObj.clcommon__Party_Types__c = 'PRINCIPAL';
            partyObjList.add(coBorrowerPartyObj);
            Database.insert(partyObjList,true);

            createIntegrationFramework();

    }

    /**
     * @description Create Integration framework
     */
    private static void createIntegrationFramework(){
        //Inserting Integration Family
        intframework__Integration_Family__c integrationFamilyObj = IntegrationTestInitHelper.getFamily(
            'NLS Integration');
        //Inserting Integration API Type
        intframework__Integration_API_Type__c integrationApiTypeObj = IntegrationTestInitHelper.getIntegrationAPIType(
            integrationFamilyObj.Id, 'Post CIF Book To Core NLS Integration API Type');
        //Inserting Integration Provider
        intframework__Integration_Provider__c integrationtProviderObj = IntegrationTestInitHelper.getIntegrationProvider(
            integrationFamilyObj.Id, 'XML Import');
        //Inserting Integration Configuration
        intframework__Integration_Configuration__c integrationConfigObj = IntegrationTestInitHelper.getIntegrationConfiguration(
            integrationtProviderObj.Id,'NLS XML Import Integration Configuration','NLS');
        //Inserting Integration API Configuration
        intframework__Integration_API_Configuration__c integrationApiConfigObj = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            integrationFamilyObj.Id,
            integrationApiTypeObj.Id,
            integrationtProviderObj.Id,
            integrationConfigObj.Id,
            false,
            'NLSCifBookToCoreImportAdapter',
            'POST',
            'NLS',
            'nls/xml-import',
            '{"thirdPartySystem": {"name": "CIFBookToCore","filters": [{"objectAPI": "genesis__Applications__c","objectAlias": "Application","fields": [{"externalField": "ID","fieldAPI": "Id"},{"externalField": "GrowerCIF","fieldAPI": "genesis__Account__r.CIF_Number__c"},{"externalField": "DealerPortfolioManager","fieldAPI": "Dealer_Name__r.PortfolioManager__r.User_Number__c"},{"externalField": "DealerProdAgOfficer","fieldAPI": "Dealer_Name__r.Production_Ag_loan_officer__r.User_Number__c"},{"externalField": "Entity","fieldAPI": "genesis__Account__r.clcommon__Legal_Entity_Type__r.Name"},{"externalField": "SSN","fieldAPI": "genesis__Contact__r.genesis__SSN__c"},{"externalField": "TaxId","fieldAPI": "genesis__Account__r.genesis__Business_Information__r.genesis__Tax_Identification_Number__c"},{"externalField": "ShortName","fieldAPI": "genesis__Account__r.Short_Name__c"},{"externalField": "AccountName","fieldAPI": "genesis__Account__r.Name"},{"externalField": "LastName","fieldAPI": "genesis__Contact__r.LastName"},{"externalField": "FirstName","fieldAPI": "genesis__Contact__r.FirstName"},{"externalField": "Email","fieldAPI": "genesis__Contact__r.Email"},{"externalField": "DoNotCall","fieldAPI": "genesis__Contact__r.DoNotCall"},{"externalField": "MiddleName","fieldAPI": "genesis__Contact__r.ints__Middle_Name__c"},{"externalField": "Description","fieldAPI": "genesis__Contact__r.Description"}],"whereClause": "Id = :applicationId"},{"objectAPI": "clcommon__party__c","objectAlias": "BorrowerDetails","fields": [{"externalField": "Id","fieldAPI": "Id"},{"externalField": "PrimaryApplicantFirstName","fieldAPI": "clcommon__contact__r.FirstName"},{"externalField": "PrimaryApplicantLastName","fieldAPI": "clcommon__contact__r.LastName"},{"externalField": "Street","fieldAPI": "Street__c"},{"externalField": "State","fieldAPI": "State__c"},{"externalField": "City","fieldAPI": "City__c"},{"externalField": "PartyTypes","fieldAPI": "clcommon__Party_Types__c"},{"externalField": "PostalCode","fieldAPI": "Postal_Code__c"},{"externalField": "Suffix","fieldAPI": "Suffix__c"},{"externalField": "Title","fieldAPI": "Title__c"},{"externalField": "Phone","fieldAPI": "Mobile_Number__c"},{"externalField": "SSN","fieldAPI": "clcommon__contact__r.genesis__SSN__c"}],"whereClause": "genesis__Application__c = :applicationId and clcommon__Party_Types__c IN :principalParty order By CreatedDate"}]}}',
            'application/xml',
            1
        );
        Database.upsert(integrationApiConfigObj,true);
    }
  /**
     * @description This class implements a interface method which return the mock response for unauthorized scenario or Failure scenario
     */
    public class HttpCalloutFailureMock implements HttpCalloutMock {
        // Implement this interface method

        /**
        * @description This method is for the unauthorized scenario or Failure scenario
        * @author Rahul Gupta | 12-10-2022
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatus('SUCCESS');
            response.setHeader('Content-Type', 'application/json');
            if(request.getEndpoint().contains('token')){
                String token = '{"access_token":"null","expires_in":300,"token_type":"Bearer"}';
                response.setStatusCode(401);
                response.setStatus('Unauthorized');
                response.setBody(token);
            }
            else{
                response.setStatusCode(400);
                response.setBody('{"status":{"code":400,"message":"string"}}');
            }
            return response;
        }
    }
  /**
     * @description This class implements a interface method which return mock response of NLS
     */
    public class HttpCalloutFailureStatusCodeMock implements HttpCalloutMock {
        /**
        * @description This method is used to return the mock response of NLS for the scenario where the status code will be failure with the token being generated 
        * @author Rakesh Saraf | 09-09-2024 
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatus('SUCCESS');
            response.setHeader('Content-Type', 'application/json');
            if(request.getEndpoint().contains('token')){
                response.setStatusCode(200);
                String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
            }
            else{
                response.setStatusCode(400);
                response.setBody('{"status":{"code":400,"message":"string"}');
                response.setStatus('Bad Request');
            }
            return response;
        }
    }

    /**
 * @description       : Setting up the Mock Response of SUCCESS status
 * @author            : Suraj kumar
 * @last modified on  : 01-27-2025
 * @last modified by  : Ayush Kumar Singh
**/
    public class NLSCIFMock implements HttpCalloutMock {
        // Implement this interface method
        /**
        * @description : return the mock response of SUCCESS status
        * @author Suraj Kumar | 03-12-2024 
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('SUCCESS');
            response.setHeader('Content-Type', 'application/json');
            if(request.getEndpoint().contains('token')){
                String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
            }
            else{
                response.setBody('{ "status": { "code": 200, "message": "string" }, "payload": { "data": "string" } }');
            }
            return response;
        }
    }
     /**
    * @description 
    * @return  `List<clcommon__Log__c>`
    */
    private static List<clcommon__Log__c> getRequestLog(){
        List<clcommon__Log__c> requestlogs = [SELECT Id, clcommon__Message__c 
                                                FROM clcommon__Log__c 
                                                WHERE Name IN ('Request Body - Book To Core CIF', 'Response Body - Book To Core CIF')];
        if(requestlogs.isEmpty()){
            return new List<clcommon__Log__c>();
        }
        return requestlogs;
   }
   /**
    * @description 
    * @return  `List<clcommon__Log__c>`
    */
    private static List<clcommon__Log__c> getExceptionLog(){
        List<clcommon__Log__c> exceptionLogsList = [SELECT Id, clcommon__Message__c 
                                                    FROM clcommon__Log__c 
                                                    WHERE Name IN ('NLSCifBookToCoreImportAdapter')];
        if(exceptionLogsList.isEmpty()){
            return new List<clcommon__Log__c>();
        }
        return exceptionLogsList;
   }
   @isTest
   private static void testBookCIFForIndividual() {
       List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
      
       List<genesis__Credit_Rating_Matrix__c> tierOneMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1');

       genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
       applicationObj.genesis__Credit_Rating__c = tierOneMatrix[0].Id;
       applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
       applicationObj.Agreement_Sign__c = true;
       applicationObj.genesis__Status__c = 'PENDING APPROVAL';
       Database.update(applicationObj, true); 

       System.runAs(userObj[0]){
           Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSCIFMock());
                NLSBookToCoreCIFCalloutClass.bookToCoreCIFFromBackEnd(applicationObj.id);
                List<clcommon__Log__c> requestlogs = getRequestLog();
                List<clcommon__Log__c> exceptionLogsList = getExceptionLog();
                System.assertEquals(true,requestlogs.size()==2,PortalConstants.ASSERTION_FAILED);
                System.assertEquals(true, exceptionLogsList.size()==0,PortalConstants.ASSERTION_FAILED);
           Test.stopTest();
           
       }
   }

   @isTest
   private static void testBookCIFForCorporation() {
        List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
        
        List<genesis__Credit_Rating_Matrix__c> tierOneMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tierOneMatrix[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        applicationObj.genesis__Status__c = 'PENDING APPROVAL';
        Database.update(applicationObj, true); 

        List<clcommon__Legal_Entity__c> corpLegalEntityList  = [SELECT Id 
                                                                        FROM clcommon__Legal_Entity__c 
                                                                        WHERE clcommon__Legal_Entity_Type__c = :PortalConstants.CORPORATION];

        List<Account> borrowerAccountList = [SELECT Id, 
                                                    clcommon__Legal_Entity_Type__c 
                                                FROM Account 
                                                WHERE id = :applicationObj.genesis__Account__c];
        borrowerAccountList[0].clcommon__Legal_Entity_Type__c = corpLegalEntityList[0].id;
        Database.update(borrowerAccountList, true);

        System.runAs(userObj[0]){
            Test.startTest();
                    Test.setMock(HttpCalloutMock.class, new NLSCIFMock());
                    NLSBookToCoreCIFCalloutClass.bookToCoreCIFFromBackEnd(applicationObj.id);
                    List<clcommon__Log__c> requestlogs = getRequestLog();
                    List<clcommon__Log__c> exceptionLogsList = getExceptionLog();
                    System.assertEquals(true,requestlogs.size()==2,PortalConstants.ASSERTION_FAILED);
                    System.assertEquals(true, exceptionLogsList.size()==0,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
           
       }
   }

   @isTest
   private static void testBookCIFForDBA() {
        List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
        
        List<genesis__Credit_Rating_Matrix__c> tierOneMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tierOneMatrix[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        applicationObj.genesis__Status__c = 'PENDING APPROVAL';
        Database.update(applicationObj, true); 

        List<clcommon__Legal_Entity__c> dbaLegalEntityList  = [SELECT Id 
                                                                        FROM clcommon__Legal_Entity__c 
                                                                        WHERE clcommon__Legal_Entity_Type__c = :PortalConstants.INDIVIDUAL_ENTITY];

        List<Account> borrowerAccountList = [SELECT Id, 
                                                    clcommon__Legal_Entity_Type__c 
                                                FROM Account 
                                                WHERE id = :applicationObj.genesis__Account__c];
        borrowerAccountList[0].clcommon__Legal_Entity_Type__c = dbaLegalEntityList[0].id;
        Database.update(borrowerAccountList, true);

        System.runAs(userObj[0]){
            Test.startTest();
                    Test.setMock(HttpCalloutMock.class, new NLSCIFMock());
                    NLSBookToCoreCIFCalloutClass.bookToCoreCIFFromBackEnd(applicationObj.id);
                    List<clcommon__Log__c> requestlogs = getRequestLog();
                    List<clcommon__Log__c> exceptionLogsList = getExceptionLog();
                    System.assertEquals(true,requestlogs.size()==2,PortalConstants.ASSERTION_FAILED);
                    System.assertEquals(true, exceptionLogsList.size()==0,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
           
       }
   }

   @isTest
   private static void testBookCIFForIndividualWithCLUserForTierOne() {
        Test.setMock(HttpCalloutMock.class, new NLSCIFMock());
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       
        List<genesis__Credit_Rating_Matrix__c> tierOneMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tierOneMatrix[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        applicationObj.genesis__Status__c = 'PENDING APPROVAL';
        Database.update(applicationObj, true);

        
        System.runAs(clUserObj){
            ID jobID;
            Test.startTest();
                jobID = System.enqueueJob(new NLSBookToCoreCIFCalloutClass(applicationObj.id));
            Test.stopTest();
            List<clcommon__Log__c> requestlogs = getRequestLog();
            List<clcommon__Log__c> exceptionLogsList = getExceptionLog();

            System.assertEquals(true, jobID!=null,PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true,requestlogs.size()==2,PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, exceptionLogsList.size()==0,PortalConstants.ASSERTION_FAILED);
            
        }
    }

    @isTest
    private static void testBookCIFForCorporationWithCLUserForTierOne() {
        Test.setMock(HttpCalloutMock.class, new NLSCIFMock());
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Credit_Rating_Matrix__c> tierOneMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tierOneMatrix[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        applicationObj.genesis__Status__c = 'PENDING APPROVAL';
        Database.update(applicationObj, true); 

        List<clcommon__Legal_Entity__c> corpLegalEntityList  = [SELECT Id 
                                                                        FROM clcommon__Legal_Entity__c 
                                                                        WHERE clcommon__Legal_Entity_Type__c = :PortalConstants.CORPORATION];

        List<Account> borrowerAccountList = [SELECT Id, 
                                                    clcommon__Legal_Entity_Type__c 
                                                FROM Account 
                                                WHERE id = :applicationObj.genesis__Account__c];
        borrowerAccountList[0].clcommon__Legal_Entity_Type__c = corpLegalEntityList[0].id;
        Database.update(borrowerAccountList, true);

        System.runAs(clUserObj){
            ID jobID;
            Test.startTest();
                jobID = System.enqueueJob(new NLSBookToCoreCIFCalloutClass(applicationObj.id));
            Test.stopTest();
            List<clcommon__Log__c> requestlogs = getRequestLog();
            List<clcommon__Log__c> exceptionLogsList = getExceptionLog();

            System.assertEquals(true, jobID!=null,PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true,requestlogs.size()==2,PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, exceptionLogsList.size()==0,PortalConstants.ASSERTION_FAILED);
        }
    }

    @isTest
    private static void testBookCIFForDBAWithCLUserForTierOne() {
        Test.setMock(HttpCalloutMock.class, new NLSCIFMock());
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Credit_Rating_Matrix__c> tierOneMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tierOneMatrix[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        applicationObj.genesis__Status__c = 'PENDING APPROVAL';
        Database.update(applicationObj, true); 

        List<clcommon__Legal_Entity__c> dbaLegalEntityList  = [SELECT Id 
                                                                        FROM clcommon__Legal_Entity__c 
                                                                        WHERE clcommon__Legal_Entity_Type__c = :PortalConstants.INDIVIDUAL_ENTITY];

        List<Account> borrowerAccountList = [SELECT Id, 
                                                    clcommon__Legal_Entity_Type__c 
                                                FROM Account 
                                                WHERE id = :applicationObj.genesis__Account__c];
        borrowerAccountList[0].clcommon__Legal_Entity_Type__c = dbaLegalEntityList[0].id;
        Database.update(borrowerAccountList, true);

        System.runAs(clUserObj){
            ID jobID;
            Test.startTest();
                jobID = System.enqueueJob(new NLSBookToCoreCIFCalloutClass(applicationObj.id));
            Test.stopTest();
            List<clcommon__Log__c> requestlogs = getRequestLog();
            List<clcommon__Log__c> exceptionLogsList = getExceptionLog();

            System.assertEquals(true, jobID!=null,PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true,requestlogs.size()==2,PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, exceptionLogsList.size()==0,PortalConstants.ASSERTION_FAILED);
        }
    }

    @isTest
    private static void testBookCIFForIndividualWithCLUserForTierTwo() {
        Test.setMock(HttpCalloutMock.class, new NLSCIFMock());
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       
        List<genesis__Credit_Rating_Matrix__c> tierTwoMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tierTwoMatrix[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        applicationObj.genesis__Status__c = 'PENDING APPROVAL';
        Database.update(applicationObj, true);

        
        System.runAs(clUserObj){
            ID jobID;
            Test.startTest();
                jobID = System.enqueueJob(new NLSBookToCoreCIFCalloutClass(applicationObj.id));
            Test.stopTest();
            List<clcommon__Log__c> requestlogs = getRequestLog();
            List<clcommon__Log__c> exceptionLogsList = getExceptionLog();
            System.assertEquals(true, jobID!=null,PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true,requestlogs.size()==2,PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, exceptionLogsList.size()==0,PortalConstants.ASSERTION_FAILED);
            
        }
    }

    @isTest
    private static void testBookCIFForCorporationWithCLUserForTierTwo() {
        Test.setMock(HttpCalloutMock.class, new NLSCIFMock());
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Credit_Rating_Matrix__c> tierTwoMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tierTwoMatrix[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        applicationObj.genesis__Status__c = 'PENDING APPROVAL';
        Database.update(applicationObj, true); 

        List<clcommon__Legal_Entity__c> corpLegalEntityList  = [SELECT Id 
                                                                        FROM clcommon__Legal_Entity__c 
                                                                        WHERE clcommon__Legal_Entity_Type__c = :PortalConstants.CORPORATION];

        List<Account> borrowerAccountList = [SELECT Id, 
                                                    clcommon__Legal_Entity_Type__c 
                                                FROM Account 
                                                WHERE id = :applicationObj.genesis__Account__c];
        borrowerAccountList[0].clcommon__Legal_Entity_Type__c = corpLegalEntityList[0].id;
        Database.update(borrowerAccountList, true);

        System.runAs(clUserObj){
            ID jobID;
            Test.startTest();
                jobID = System.enqueueJob(new NLSBookToCoreCIFCalloutClass(applicationObj.id));
            Test.stopTest();
            List<clcommon__Log__c> requestlogs = getRequestLog();
            List<clcommon__Log__c> exceptionLogsList = getExceptionLog();

            System.assertEquals(true, jobID!=null,PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true,requestlogs.size()==2,PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, exceptionLogsList.size()==0,PortalConstants.ASSERTION_FAILED);
        }
    }

    @isTest
    private static void testBookCIFForDBAWithCLUserForTierTwo() {
        Test.setMock(HttpCalloutMock.class, new NLSCIFMock());
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Credit_Rating_Matrix__c> tierTwoMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tierTwoMatrix[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        applicationObj.genesis__Status__c = 'PENDING APPROVAL';
        Database.update(applicationObj, true); 

        List<clcommon__Legal_Entity__c> dbaLegalEntityList  = [SELECT Id 
                                                                        FROM clcommon__Legal_Entity__c 
                                                                        WHERE clcommon__Legal_Entity_Type__c = :PortalConstants.INDIVIDUAL_ENTITY];

        List<Account> borrowerAccountList = [SELECT Id, 
                                                    clcommon__Legal_Entity_Type__c 
                                                FROM Account 
                                                WHERE id = :applicationObj.genesis__Account__c];
        borrowerAccountList[0].clcommon__Legal_Entity_Type__c = dbaLegalEntityList[0].id;
        Database.update(borrowerAccountList, true);

        System.runAs(clUserObj){
            ID jobID;
            Test.startTest();
                jobID = System.enqueueJob(new NLSBookToCoreCIFCalloutClass(applicationObj.id));
            Test.stopTest();
            List<clcommon__Log__c> requestlogs = getRequestLog();
            List<clcommon__Log__c> exceptionLogsList = getExceptionLog();

            System.assertEquals(true, jobID!=null,PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true,requestlogs.size()==2,PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, exceptionLogsList.size()==0,PortalConstants.ASSERTION_FAILED);
        }
    }
    @isTest
    private static void testBookToCoreCIFWithoutAppId() {
        Test.setMock(HttpCalloutMock.class, new NLSCIFMock());
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        System.runAs(clUserObj){
            Test.startTest();
                ID jobID = System.enqueueJob(new NLSBookToCoreCIFCalloutClass(null));
                NLSBookToCoreCIFCalloutClass.bookToCoreCIFFromBackEnd(null);
                List<clcommon__Log__c> logList = [SELECT Id,
                                                Name 
                                            FROM clcommon__Log__c 
                                            WHERE Name =: 'NLSBookToCoreCIFCalloutClass'
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];
                System.assertEquals(1, logList.size(), PortalConstants.ASSERTION_FAILED);
                System.assertEquals(true, jobID!=null,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    @isTest
    private static void testBookCIFForUnauthorizedToken() {
       List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
      
       List<genesis__Credit_Rating_Matrix__c> tierOneMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1');

       genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
       applicationObj.genesis__Credit_Rating__c = tierOneMatrix[0].Id;
       applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
       applicationObj.Agreement_Sign__c = true;
       applicationObj.genesis__Status__c = 'PENDING APPROVAL';
       Database.update(applicationObj, true); 

       System.runAs(userObj[0]){
           Test.startTest();
                Test.setMock(HttpCalloutMock.class, new HttpCalloutFailureMock());
                NLSBookToCoreCIFCalloutClass.bookToCoreCIFFromBackEnd(applicationObj.id);
                List<clcommon__Log__c> requestlogs = getRequestLog();
                List<clcommon__Log__c> exceptionLogsList = getExceptionLog();
                System.assertEquals(true,requestlogs.size()==0,PortalConstants.ASSERTION_FAILED);
                System.assertEquals(true, exceptionLogsList.size()>0,PortalConstants.ASSERTION_FAILED);
           Test.stopTest();
           
       }
   }

   @isTest
   private static void testBookCIFForBadRequest() {
       List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
      
       List<genesis__Credit_Rating_Matrix__c> tierOneMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1');
       genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
       applicationObj.genesis__Credit_Rating__c = tierOneMatrix[0].Id;
       applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
       applicationObj.Agreement_Sign__c = true;
       applicationObj.genesis__Status__c = 'PENDING APPROVAL';
       Database.update(applicationObj, true); 

       System.runAs(userObj[0]){
           Test.startTest();
                Test.setMock(HttpCalloutMock.class, new HttpCalloutFailureStatusCodeMock());
                NLSBookToCoreCIFCalloutClass.bookToCoreCIFFromBackEnd(applicationObj.id);
                List<clcommon__Log__c> requestlogs = getRequestLog();
                List<clcommon__Log__c> exceptionLogsList = getExceptionLog();
                System.assertEquals(true,requestlogs.size()==2,PortalConstants.ASSERTION_FAILED);
                System.assertEquals(true, exceptionLogsList.size()>0,PortalConstants.ASSERTION_FAILED);
           Test.stopTest();
           
       }
   }
}