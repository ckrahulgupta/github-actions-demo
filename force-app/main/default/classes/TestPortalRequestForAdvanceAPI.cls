/**
 * @description       : Test class for PortalRequestForAdvanceAPI
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 12-10-2024
 * @last modified by  : Sk Minsar
**/

@isTest
public with sharing class TestPortalRequestForAdvanceAPI {

    /**
    * @description - Test setup
    * @author Sk Minsar | 12-09-2024 
    **/
    @testSetup
    static void setup() {
        // Creating floating rate index
        clcommon__Floating_Rate_Index__c floatingRateIndexObj = ApplicationOriginationTestHelper.createFloatingRateIndex(
            New Map<String, Object>{ 'Name' => 'CFA Advantage Rate',
                                        'Base Rate Name' => '4-CFA ADVANTAGE',
                                        'Current Floating Rate' => 11,
                                        'Base Rate Adjuster' => 5.5
        });
        Database.insert(floatingRateIndexObj, true);

        // Creating floating rate
        clcommon__Floating_Rate__c floatingRateObj = ApplicationOriginationTestHelper.createFloatingRate(floatingRateIndexObj);
        Database.insert(floatingRateObj, true);

        // Creating new partner program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);

        // Creating Business information
        genesis__Business_Information__c dealerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj,true);

        // creating Reciprocal role
        clcommon__Reciprocal_Role__c roleObj = LoanServicingTestHelper.createReciprocalRole('Certified Lender');
        Database.insert(roleObj,true);

        // creating cl product
        clcommon__CL_Product__c clProductObj=LoanServicingTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        // creating cl purpose
        clcommon__CL_Purpose__c clPurposeObj=LoanServicingTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj,true);

        // creating legal entity 
        clcommon__Legal_Entity__c entityObj= LoanServicingTestHelper.createLegalEntity('Individual(s) with DBA');
        Database.insert(entityObj,true);

        // Creating dealer account
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id, newPartnerProgramObj.id);
        Database.insert(dealerAccountObj, true);
        // creating certified lender account
        Account clAccountObj = LoanServicingTestHelper.createCLAccount(dealerBusinessInfoObj.Id,dealerAccountObj.Id);
    
        //creating borrower account
        Account borrowerAccountObj=LoanServicingTestHelper.createSolePropAccount(entityObj,LoanServicingTestHelper.createBusinessInfoForBorrower().Id);

        Database.insert(new  List<Account>{
            clAccountObj,
            borrowerAccountObj
        },true);

        // Creating Contact for Dealer
        Contact dealerContactObj = LoanServicingTestHelper.createDealerContact(dealerAccountObj);
        // creating certified lender contact
        Contact clContactObj = LoanServicingTestHelper.createCLContact(clAccountObj.Id);
        //creating borrower contact
        Contact borrowerContactObj=LoanServicingTestHelper.createBorrowerContact(borrowerAccountObj.Id);

        Database.insert(new List<Contact>{
            dealerContactObj,
            clContactObj,
            borrowerContactObj
        },true);

        // creating cl user
        User clUserObj = LoanServicingTestHelper.createCLUser(clContactObj.Id);

        // create borrower user
        User borrowerUserObj = LoanServicingTestHelper.createBorrowerUser(borrowerContactObj.Id);

        Database.insert(new List<User>{
            clUserObj,
            borrowerUserObj
        },true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = LoanServicingTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);


        //creating application obj
        genesis__Applications__c applicationObj = LoanServicingTestHelper.createCurrCropYearApplication(new Map<String,Id>{
            'dealerAccountId'=> dealerAccountObj.Id,
            'clProductId'=> clProductObj.Id,
            'clPurposeId'=> clPurposeObj.Id,
            'borrowerAccountId'=> borrowerAccountObj.Id,
            'borrowerContactId'=> borrowerContactObj.Id,
            'clAccountId'=> clAccountObj.Id
        });
        Database.insert(applicationObj,true);


        // Creating Party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = LoanServicingTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c clPartyTypeObj = LoanServicingTestHelper.createPartyType('CERTIFIED LENDER');
        clcommon__Party_Type__c dealerPartyTypeObj = LoanServicingTestHelper.createPartyType('DEALER');
        Database.insert(new List<clcommon__Party_Type__c>{
            borrowerPartyTypeObj,
            clPartyTypeObj,
            dealerPartyTypeObj
        }, true);
        
        // Creating Party
        clcommon__Party__c borrowerPartyObj = LoanServicingTestHelper.createParty(new Map<String,Id>{
            'accountId'=> borrowerAccountObj.Id,
            'contactId'=> borrowerContactObj.Id,
            'partyTypeId'=> borrowerPartyTypeObj.Id,
            'applicationId'=> applicationObj.Id
        });
        clcommon__Party__c clPartyObj = LoanServicingTestHelper.createParty(new Map<String,Id>{
            'accountId'=> clAccountObj.Id,
            'contactId'=> clContactObj.Id,
            'partyTypeId'=> clPartyTypeObj.Id,
            'applicationId'=> applicationObj.Id
        });
        clcommon__Party__c dealerPartyObj = LoanServicingTestHelper.createParty(new Map<String,Id>{
            'accountId'=> dealerAccountObj.Id,
            'contactId'=> dealerContactObj.Id,
            'partyTypeId'=> dealerPartyTypeObj.Id,
            'applicationId'=> applicationObj.Id
        });

        Database.insert(new List<clcommon__Party__c>{
            borrowerPartyObj,
            clPartyObj,
            dealerPartyObj
        },true);

        Map<String, clcommon__Payment_Mode__c> paymentModeMap = LoanServicingTestHelper.createPaymentMode();

        // Create ACH Payment Mode
        clcommon__Payment_Mode__c achPaymentModeObj = paymentModeMap.get('ACH');
        clcommon__Payment_Mode__c draftPaymentModeObj = paymentModeMap.get('DRAFT');

        Database.insert(new List<clcommon__Payment_Mode__c>{
            draftPaymentModeObj,
            achPaymentModeObj
        },true);

        // Creating ACH funding transaction properties
        clcommon__Funding_Transactions_Properties__c achfundingPropertiesObj = LoanServicingTestHelper.createAchFundingTransactionProperties();
        Database.insert(achfundingPropertiesObj,true);
       
        // Creating Rate card setup header
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = LoanServicingTestHelper.createRateCardHeader(borrowerAccountObj);
        Database.insert(rateCardHeaderObj,true);
        // Creating rate card setup detail
        genesis__Rate_Card_Setup_Detail__c rateCardDetailObj = LoanServicingTestHelper.createRateCardSetupDetail(rateCardHeaderObj);
        Database.insert(rateCardDetailObj,true);
        // Creating pricing detail
        genesis__Application_Pricing_Detail__c pricingDetailsObj = LoanServicingTestHelper.createEnabledPricingDetail(applicationObj,rateCardDetailObj.Id);
        pricingDetailsObj.Principal_Advanced__c = 0;
        Database.insert(pricingDetailsObj,true);
        
        //Create invoice
        clcommon__Consolidated_Invoice__c achInvoiceObj = LoanServicingTestHelper.createInvoice(applicationObj.Id, achPaymentModeObj.Id);
        clcommon__Consolidated_Invoice__c draftInvoiceObj = LoanServicingTestHelper.createInvoice(applicationObj.Id, draftPaymentModeObj.Id);
        Database.insert(new List<clcommon__Consolidated_Invoice__c>{
            achInvoiceObj,
            draftInvoiceObj
        }, true);

        // Creating ACH funding transaction
        genesis__Funding_Transaction__c achfundingTransactionObj = LoanServicingTestHelper.createFundingTransaction(achPaymentModeObj.Id, achfundingPropertiesObj.Id, applicationObj.Id);
        achfundingTransactionObj.Pricing_Detail__c = achfundingTransactionObj.id;
        achfundingTransactionObj.invoice__c = achInvoiceObj.Id;
        Database.insert(achfundingTransactionObj,true);

        //Updating total amount in invoice
        achInvoiceObj.Total_Amount__c = achfundingTransactionObj.genesis__Amount__c;
        Database.update(achInvoiceObj, true);
    }

    /**
    * @description - Request param map for test methods
    * @author Sk Minsar | 12-09-2024 
    * @return Map<String, String> 
    **/
    private static Map<String, String> getTestDataIdMap(){
        
        genesis__Applications__c applicationObj = [SELECT Id,Certified_Lender__c FROM genesis__Applications__c LIMIT 1];
        Account objAccount = [SELECT Id, Name FROM Account WHERE Id =:applicationObj.Certified_Lender__c];
        Contact objContact = [SELECT Id,Email, accountId FROM Contact WHERE AccountId =:objAccount.id];
        genesis__Application_Pricing_Detail__c newPricingDetails  = [SELECT Id,Credit_Balance__c FROM genesis__Application_Pricing_Detail__c WHERE genesis__Application__c =: applicationObj.id];

        return new Map<String, String>{
            'applicationId' => String.valueOf(applicationObj.Id),
            'accountId' => String.valueOf(objAccount.Id),
            'contactId' => String.valueOf(objContact.Id),
            'pricingDetailsId' => String.valueOf(newPricingDetails.Id)
        };
    }

    /**
    * @description - Returns certified lender user by contactId
    * @author Sk Minsar | 12-10-2024 
    * @param contactId 
    * @return User 
    **/
    private static User getCLUser(String contactId){
        return [SELECT Id,ContactId FROM USER WHERE Profile.Name = 'Certified Lender' and ContactId =: contactId LIMIT 1];
    }
    
    /**
    * @description - Test success scenario
    * @author Sk Minsar | 12-09-2024 
    **/
    @isTest
    public static void testRequestForAdvanceACH() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        requestMap.put('Id', 'new_record_id');
        requestMap.put('accountId', testDataIdMap.get('accountId'));
        requestMap.put('amount', 500);
        requestMap.put('paymentMode', 'ACH');
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', testDataIdMap.get('pricingDetailsId'));
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    
    /**
    * @description - Test success scenario
    * @author Sk Minsar | 12-09-2024 
    **/
    @isTest
    public static void testACHWithCreditBalance(){
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        genesis__Application_Pricing_Detail__c newPricingDetails  = [SELECT Id,Credit_Balance__c FROM genesis__Application_Pricing_Detail__c WHERE genesis__Application__c =: testDataIdMap.get('applicationId')];
        newPricingDetails.Credit_Balance__c = 200;
        Database.update(newPricingDetails,true);
        requestMap.put('Id', 'new_record_id');
        requestMap.put('accountId', testDataIdMap.get('accountId'));
        requestMap.put('amount', 500);
        requestMap.put('paymentMode', 'ACH');
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', testDataIdMap.get('pricingDetailsId'));
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }


    /**
    * @description - Passing Account Id null exception scenario
    * @author Sk Minsar | 12-09-2024 
    **/
    @isTest
    public static void testACHWithoutAccountId() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        requestMap.put('Id', 'new_record_id');
        requestMap.put('amount', 500);
        requestMap.put('paymentMode', 'ACH');
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', testDataIdMap.get('pricingDetailsId'));
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    
    /**
    * @description - Test success scenario
    * @author Sk Minsar | 12-09-2024 
    **/
    @isTest
    public static void testRequestForAdvanceForExistingACH() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        genesis__Funding_Transaction__c objFundingTransaction = [SELECT Id FROM genesis__Funding_Transaction__c WHERE genesis__Payment_Mode__r.Name = 'ACH' LIMIT 1];
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        requestMap.put('Id', objFundingTransaction.Id);
        requestMap.put('accountId', testDataIdMap.get('accountId'));
        requestMap.put('amount', 500);
        requestMap.put('paymentMode', 'ACH');
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', testDataIdMap.get('pricingDetailsId'));
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }


    /**
    * @description - insufficient available fund for ach amount exception scenario
    * @author Sk Minsar | 12-09-2024 
    **/
    @isTest
    public static void testeACHWithInsufficientBalance() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        requestMap.put('Id', 'new_record_id');
        requestMap.put('accountId', testDataIdMap.get('accountId'));
        requestMap.put('amount', 45000);
        requestMap.put('paymentMode', 'ACH');
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', testDataIdMap.get('pricingDetailsId'));
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }

    
    /**
    * @description - negative amount exception scenario
    * @author Sk Minsar | 12-09-2024 
    **/
    @isTest
    public static void testACHWithNegativeAmount() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        requestMap.put('Id', 'new_record_id');
        requestMap.put('accountId', testDataIdMap.get('accountId'));
        requestMap.put('amount', -5000);
        requestMap.put('paymentMode', 'ACH');
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', testDataIdMap.get('pricingDetailsId'));
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    
    /**
    * @description - Test success scenario
    * @author Sk Minsar | 12-09-2024 
    **/
   @isTest
    public static void testRequestForAdvanceDRAFT() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        requestMap.put('Id', 'new_record_id');
        requestMap.put('accountId', testDataIdMap.get('accountId'));
        requestMap.put('applicationId', testDataIdMap.get('applicationId'));
        requestMap.put('paymentMode', 'DRAFT');
        requestMap.put('payee', 'Test');
        requestMap.put('draftNumber', 12345);
        requestMap.put('draftChild', '[{\"Id\":\"'+ String.valueOf(testDataIdMap.get('pricingDetailsId')) +'\",\"genesis__Maximum_Financed_Amount__c\":2000,\"Description__c\":\"Decorations\"}]');
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }

    /**
    * @description - Test success scenario
    * @author Sk Minsar | 12-09-2024 
    **/
    @isTest
    public static void testDRAFTWithCreditBalance() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        genesis__Application_Pricing_Detail__c newPricingDetails  = [SELECT Id,Credit_Balance__c FROM genesis__Application_Pricing_Detail__c WHERE genesis__Application__c =: testDataIdMap.get('applicationId')];
        newPricingDetails.Credit_Balance__c = 100;
        Database.update(newPricingDetails,true);
        requestMap.put('Id', 'new_record_id');
        requestMap.put('accountId', testDataIdMap.get('accountId'));
        requestMap.put('applicationId', testDataIdMap.get('applicationId'));
        requestMap.put('paymentMode', 'DRAFT');
        requestMap.put('payee', 'Test');
        requestMap.put('draftNumber', 12345);
        requestMap.put('draftChild', '[{\"Id\":\"'+ String.valueOf(testDataIdMap.get('pricingDetailsId')) +'\",\"genesis__Maximum_Financed_Amount__c\":2000,\"Description__c\":\"Decorations\"}]');
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }

    /**
    * @description - Test success scenario
    * @author Sk Minsar | 12-09-2024 
    **/
    @isTest
    public static void testDRAFTWithCreditBalanceGreaterThanFinancedAmt() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        genesis__Application_Pricing_Detail__c newPricingDetails  = [SELECT Id,Credit_Balance__c FROM genesis__Application_Pricing_Detail__c WHERE genesis__Application__c =: testDataIdMap.get('applicationId')];
        newPricingDetails.Credit_Balance__c = 2200;
        Database.update(newPricingDetails,true);
        requestMap.put('Id', 'new_record_id');
        requestMap.put('accountId', testDataIdMap.get('accountId'));
        requestMap.put('applicationId', testDataIdMap.get('applicationId'));
        requestMap.put('paymentMode', 'DRAFT');
        requestMap.put('payee', 'Test');
        requestMap.put('draftNumber', 12345);
        requestMap.put('draftChild', '[{\"Id\":\"'+ String.valueOf(testDataIdMap.get('pricingDetailsId')) +'\",\"genesis__Maximum_Financed_Amount__c\":2000,\"Description__c\":\"Decorations\"}]');
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    
    /**
    * @description - Test success scenario
    * @author Sk Minsar | 12-09-2024 
    **/
    @isTest
    public static void testRequestForAdvanceForExistingDRAFT() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        genesis__Application_Pricing_Detail__c newPricingDetails  = [SELECT Id,Credit_Balance__c,Principal_Advanced__c FROM genesis__Application_Pricing_Detail__c WHERE genesis__Application__c =: testDataIdMap.get('applicationId')];
        newPricingDetails.Principal_Advanced__c = 0;
        Database.update(newPricingDetails,true);
        clcommon__Payment_Mode__c draftpaymentMode = [Select id from clcommon__Payment_Mode__c where name = 'DRAFT'];
        genesis__Funding_Transaction__c objFundingTransaction = [SELECT ID,genesis__Payment_Mode__c,Pricing_Detail__c FROM genesis__Funding_Transaction__c WHERE genesis__Application__c =: testDataIdMap.get('applicationId')];
        objFundingTransaction.genesis__Payment_Mode__c = draftpaymentMode.id;
        objFundingTransaction.Pricing_Detail__c = testDataIdMap.get('pricingDetailsId');
        Database.update(objFundingTransaction,true);
        requestMap.put('Id', objFundingTransaction.Id);
        requestMap.put('accountId', testDataIdMap.get('accountId'));
        requestMap.put('applicationId', testDataIdMap.get('applicationId'));
        requestMap.put('paymentMode', 'DRAFT');
        requestMap.put('payee', 'Test');
        requestMap.put('draftNumber', 12345);
        requestMap.put('genesis__Amount__c', 1000);
        requestMap.put('amount', 1000);
        requestMap.put('genesis__Reference__c', 'Test');
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    
    /**
    * @description - Test exception scenario
    * @author Sk Minsar | 12-09-2024 
    **/
    @isTest
    public static void testRequestForAdvanceDRAFTException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        requestMap.put('Id', 'new_record_id');
        requestMap.put('accountId', testDataIdMap.get('accountId'));
        requestMap.put('applicationId', testDataIdMap.get('applicationId'));
        requestMap.put('paymentMode', 'DRAFT');
        requestMap.put('payee', 'Test');
        requestMap.put('draftNumber', 12345);
        requestMap.put('draftChild', '[{\"Id\":\"a6t760000008S1TAAU\",\"genesis__Maximum_Financed_Amount__c\":45000,\"Description__c\":\"Decorations\"},{\"Id\":\"a6t760000008S1UAAU\",\"genesis__Maximum_Financed_Amount__c\":100,\"Description__c\":\"cold drinks\"},{\"Id\":\"a6t760000008S1VAAU\",\"genesis__Maximum_Financed_Amount__c\":350,\"Description__c\":\"extra\"},{\"Id\":\"a6t760000008S1WAAU\",\"genesis__Maximum_Financed_Amount__c\":0,\"Description__c\":\"none\"}]');
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    
    /**
    * @description - Test success scenario
    * @author Sk Minsar | 12-09-2024 
    **/
    @isTest
    public static void testRequestForAdvanceDRAFTWithNegativeFinancedAmt() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        requestMap.put('Id', 'new_record_id');
        requestMap.put('accountId', testDataIdMap.get('accountId'));
        requestMap.put('applicationId', testDataIdMap.get('applicationId'));
        requestMap.put('paymentMode', 'DRAFT');
        requestMap.put('payee', 'Test');
        requestMap.put('draftNumber', 12345);
        requestMap.put('draftChild', '[{\"Id\":\"a6t760000008S1TAAU\",\"genesis__Maximum_Financed_Amount__c\":-500,\"Description__c\":\"Decorations\"},{\"Id\":\"a6t760000008S1UAAU\",\"genesis__Maximum_Financed_Amount__c\":100,\"Description__c\":\"cold drinks\"},{\"Id\":\"a6t760000008S1VAAU\",\"genesis__Maximum_Financed_Amount__c\":350,\"Description__c\":\"extra\"},{\"Id\":\"a6t760000008S1WAAU\",\"genesis__Maximum_Financed_Amount__c\":0,\"Description__c\":\"none\"}]');
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    
    /**
    * @description - Test exception scenario
    * @author Sk Minsar | 12-09-2024 
    **/
    @isTest
    public static void testRequestForAdvanceDRAFTWithoutDraftChild() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        requestMap.put('Id', 'new_record_id');
        requestMap.put('accountId', testDataIdMap.get('accountId'));
        requestMap.put('applicationId', testDataIdMap.get('applicationId'));
        requestMap.put('paymentMode', 'DRAFT');
        requestMap.put('payee', 'Test');
        requestMap.put('draftChild', '[{\"Id\":\"a6t760000008S1TAAU\",\"genesis__Maximum_Financed_Amount__c\":500,\"Description__c\":\"Decorations\"},{\"Id\":\"a6t760000008S1UAAU\",\"genesis__Maximum_Financed_Amount__c\":100,\"Description__c\":\"cold drinks\"},{\"Id\":\"a6t760000008S1VAAU\",\"genesis__Maximum_Financed_Amount__c\":350,\"Description__c\":\"extra\"},{\"Id\":\"a6t760000008S1WAAU\",\"genesis__Maximum_Financed_Amount__c\":0,\"Description__c\":\"none\"}]');
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    
    /**
    * @description - Test exception scenario
    * @author Sk Minsar | 12-09-2024 
    **/
    @isTest
    public static void testACHSuspendedLoanWithPreviosDayAsMaturity() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        genesis__Applications__c applicationObj = [SELECT Id,Certified_Lender__c,genesis__Maturity_Date__c FROM genesis__Applications__c WHERE Id = :testDataIdMap.get('applicationId') LIMIT 1];
        applicationObj.genesis__Maturity_Date__c = Date.today().addDays(-1);
        Database.update(applicationObj,false);
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        requestMap.put('Id', 'new_record_id');
        requestMap.put('accountId', testDataIdMap.get('accountId'));
        requestMap.put('amount', 500);
        requestMap.put('paymentMode', 'ACH');
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', testDataIdMap.get('pricingDetailsId'));
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    
    /**
    * @description - Test exception scenario
    * @author Sk Minsar | 12-09-2024 
    **/
    @isTest
    public static void testACHSuspendedLoanWithPreviosMonthAsMaturity() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        genesis__Applications__c applicationObj = [SELECT Id,Certified_Lender__c,genesis__Maturity_Date__c FROM genesis__Applications__c WHERE Id = :testDataIdMap.get('applicationId')  LIMIT 1];
        applicationObj.genesis__Maturity_Date__c = Date.today().addMonths(-1);
        Database.update(applicationObj,false);
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        requestMap.put('Id', 'new_record_id');
        requestMap.put('accountId', testDataIdMap.get('accountId'));
        requestMap.put('amount', 500);
        requestMap.put('paymentMode', 'ACH');
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', testDataIdMap.get('pricingDetailsId'));
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    
    /**
    * @description - Test exception scenario
    * @author Sk Minsar | 12-09-2024 
    **/
    @isTest
    public static void testACHSuspendedLoanWithPreviosYearAsMaturity() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        genesis__Applications__c applicationObj = [SELECT Id,Certified_Lender__c,genesis__Maturity_Date__c FROM genesis__Applications__c WHERE Id = :testDataIdMap.get('applicationId')  LIMIT 1];
        applicationObj.genesis__Maturity_Date__c = Date.today().addMonths(-1);
        Database.update(applicationObj,false);
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        requestMap.put('Id', 'new_record_id');
        requestMap.put('accountId', testDataIdMap.get('accountId'));
        requestMap.put('amount', 500);
        requestMap.put('paymentMode', 'ACH');
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', testDataIdMap.get('pricingDetailsId'));
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }

    /**
    * @description - Test exception scenario
    * @author Sk Minsar | 12-09-2024 
    **/
    @isTest
    public static void testDRAFTSuspendedLoanWithPreviosYearAsMaturity() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        genesis__Applications__c applicationObj = [SELECT Id,Certified_Lender__c,genesis__Maturity_Date__c FROM genesis__Applications__c WHERE Id = :testDataIdMap.get('applicationId')  LIMIT 1];
        applicationObj.genesis__Maturity_Date__c = Date.today().addMonths(-1);
        Database.update(applicationObj,false);
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        requestMap.put('Id', 'new_record_id');
        requestMap.put('accountId', testDataIdMap.get('accountId'));
        requestMap.put('amount', 500);
        requestMap.put('paymentMode', 'DRAFT');
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', testDataIdMap.get('pricingDetailsId'));
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    
    /**
    * @description - Test exception scenario
    * @author Sk Minsar | 12-09-2024 
    **/
    @isTest
    public static void testDRAFTSuspendedLoanWithPreviosMonthAsMaturity() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        genesis__Applications__c applicationObj = [SELECT Id,Certified_Lender__c,genesis__Maturity_Date__c FROM genesis__Applications__c WHERE Id = :testDataIdMap.get('applicationId')  LIMIT 1];
        applicationObj.genesis__Maturity_Date__c = Date.today().addMonths(-1);
        Database.update(applicationObj,false);
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        requestMap.put('Id', 'new_record_id');
        requestMap.put('accountId', testDataIdMap.get('accountId'));
        requestMap.put('amount', 500);
        requestMap.put('paymentMode', 'DRAFT');
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', testDataIdMap.get('pricingDetailsId'));
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }

    /**
    * @description - Test exception scenario
    * @author Sk Minsar | 12-09-2024 
    **/
    @isTest
    public static void testDRAFTSuspendedLoanWithPreviosDayAsMaturity() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Map<String, String> testDataIdMap = getTestDataIdMap();
        genesis__Applications__c applicationObj = [SELECT Id,Certified_Lender__c,genesis__Maturity_Date__c FROM genesis__Applications__c WHERE Id = :testDataIdMap.get('applicationId')  LIMIT 1];
        applicationObj.genesis__Maturity_Date__c = Date.today().addDays(-1);
        Database.update(applicationObj,false);
        User clUser = getCLUser(testDataIdMap.get('contactId'));
        requestMap.put('Id', 'new_record_id');
        requestMap.put('accountId', testDataIdMap.get('accountId'));
        requestMap.put('amount', 500);
        requestMap.put('paymentMode', 'DRAFT');
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', testDataIdMap.get('pricingDetailsId'));
        Test.startTest();
        System.runAs(clUser) {
            PortalRequestForAdvanceAPI testApi = new PortalRequestForAdvanceAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
}