/**
 * @description       : Test class for NLSXMLImportMobileDepositCalloutBatch class
 * @author            : Kabir Pramanik
 * @group             : 
 * @last modified on  : 12-18-2024
 * @last modified by  : Kabir Pramanik
**/
@isTest
public with sharing class NlsXmlImportMobileDepositCalloutTest {
    /**
    * @description : test setup for creating test data
    * @author Kabir Pramanik | 09-10-2024 
    **/
    @TestSetup
    static void setup(){
        //Inserting Integration Family
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily(
            'NLS Integration');
        //Inserting Integration API Type
        intframework__Integration_API_Type__c xMLImportApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Post NLS XML Import Integration API Type');
        //Inserting Integration Provider
        intframework__Integration_Provider__c xMLImportProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'XML Import');
        //Inserting Integration Configuration
        intframework__Integration_Configuration__c xMLImportConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            XMLImportProvider.Id,'NLS XML Import Integration Configuration','NLS');
        //Inserting Integration API Configuration
        intframework__Integration_API_Configuration__c xMLImportApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            xMLImportApiType.Id,
            xMLImportProvider.Id,
            xMLImportConfig.Id,
            false,
            'NLSXMLImportAdapter',
            'POST',
            'NLS',
            'nls/xml-import',
            '{"thirdPartySystem":{"name":"test","filters":[{"objectAPI":"genesis__Funding_Transaction__c","objectAlias":"FundingTransaction","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"Amount","fieldAPI":"genesis__Amount__c"},{"externalField":"LoanNumber","fieldAPI":"Pricing_Detail__r.Loan_Number__c"},{"externalField":"InterestPaid","fieldAPI":"Interest_Paid__c"},{"externalField":"FeesPaid","fieldAPI":"Fees_Paid__c"},{"externalField":"CoopType","fieldAPI":"genesis__Application__r.Coop_Type__c"},{"externalField":"PrincipalPaid","fieldAPI":"Principal_Paid__c"},{"externalField":"Reference","fieldAPI":"genesis__Reference__c"},{"externalField":"EffectiveDate","fieldAPI":"genesis__Funding_Date__c"},{"externalField":"GrowerName","fieldAPI":"Grower_Name__c"},{"externalField":"DealerName","fieldAPI":"genesis__Application__r.Dealer_Name__r.Name"},{"externalField":"ParentLoanNumber","fieldAPI":"genesis__Application__r.genesis__Loan_Number__c"},{"externalField":"Payee","fieldAPI":"Payee__c"},{"externalField":"DraftNumber","fieldAPI":"Draft_Number__c"},{"externalField":"Total","fieldAPI":"Total__c"},{"externalField":"ApplicationId","fieldAPI":"genesis__Application__r.Id"},{"externalField":"IsPayOff","fieldAPI":"Pay_Off__c"},{"externalField":"IsClearingSuspense","fieldAPI":"Is_Clearing_Suspense__c"}],"whereClause":"Id IN :approvedList"}],"dynamicDataParameters":[{"externalField":"paymentType"}]}}',
            'application/json',
            1
        );

        System.assertEquals(xMLImportApiConfig.intframework__Adapter_Class_Name__c,'NLSXMLImportAdapter','Wring adapter class');
        // ----------------------------------------------------------
        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c gmkDealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(new List<genesis__Business_Information__c> {dealerBusinessInfoObj, gmkDealerBusinessInfoObj}, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Account gmkDealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(gmkDealerBusinessInfoObj.Id);
        gmkDealerAccountObj.Coop_type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.insert(new List<Account> {dealerAccountObj, gmkDealerAccountObj}, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Account gmkClAccountObj = ApplicationOriginationTestHelper.createCLAccount(gmkDealerBusinessInfoObj.Id, gmkDealerAccountObj.Id);
        Database.insert(new List<Account> {clAccountObj, gmkClAccountObj}, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Contact gmkClContactObj = ApplicationOriginationTestHelper.createCLContact(gmkClAccountObj.Id);
        Database.insert(new List<Contact> {clContactObj, gmkClContactObj},true);

        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        User gmkClUserObj = ApplicationOriginationTestHelper.createCLUser(gmkClContactObj.Id);
        gmkClUserObj.username = 'gmkcluser.test@yopmail.com';
        Database.insert(new List<User> {clUserObj, gmkClUserObj}, true);

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);

        // Creating Account for Borrower
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, ApplicationOriginationTestHelper.createBusinessInfoForBorrower().Id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Account gmkBorrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, ApplicationOriginationTestHelper.createBusinessInfoForBorrower().Id);
        gmkBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.insert(new List<Account> {borrowerAccountObj, gmkBorrowerAccountObj}, true);

        // Creating Contact for Borrower
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Contact gmkBorrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(gmkBorrowerAccountObj.Id);
        Database.insert(new List<Contact> {borrowerContactObj, gmkBorrowerContactObj},true);

        // Creating User for Borrower
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        User gmkBorrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(gmkBorrowerContactObj.Id);
        gmkBorrowerUserObj.username = 'gmkborroweruser.test@yopmail.com';
        Database.insert(new List<User> {borrowerUserObj, gmkBorrowerUserObj}, true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        Map<String, Id> paramForApplicationMap = new Map<String, Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'clAccountId' => clAccountObj.Id
        };
        
        Map<String, Id> paramForApplicationMapGmk = new Map<String, Id>{
            'dealerAccountId' => gmkDealerAccountObj.Id, 
            'clProductId' => clProductObj.Id, 
            'clPurposeId' => clPurposeObj.Id, 
            'borrowerAccountId' => gmkBorrowerAccountObj.Id, 
            'borrowerContactId' => gmkBorrowerContactObj.Id, 
            'clAccountId' => gmkClAccountObj.Id
        };

        // Creating Application
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        genesis__Applications__c gmkApplicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMapGmk);
        gmkApplicationObj.Loan_Id__c = '1576000';
        gmkApplicationObj.genesis__Loan_Number__c = '300023500';
        Database.insert(new List<genesis__Applications__c> {applicationObj, gmkApplicationObj}, true);

        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerAccountObj);
        genesis__Rate_Card_Setup_Header__c gmkRateCardHeaderObj = ApplicationOriginationTestHelper.createRateCardSetupHeader(gmkDealerAccountObj);
        Database.insert(new List<genesis__Rate_Card_Setup_Header__c> {rateCardHeaderObj, gmkRateCardHeaderObj},true);

        genesis__Rate_Card_Setup_Detail__c aRateCardSetupDetails =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        genesis__Rate_Card_Setup_Detail__c aRateCardSetupDetailsGmk =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(gmkRateCardHeaderObj);
        
        genesis__Rate_Card_Setup_Detail__c bRateCardSetupDetails =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        bRateCardSetupDetails.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_B;
        
        Database.insert(new List<genesis__Rate_Card_Setup_Detail__c> {aRateCardSetupDetails, aRateCardSetupDetailsGmk, bRateCardSetupDetails},true);

        genesis__Application_Pricing_Detail__c pricingDetailsObj = ApplicationOriginationTestHelper.createPricingDetail(applicationObj.id);
        genesis__Application_Pricing_Detail__c gmkPricingDetailsObj = ApplicationOriginationTestHelper.createPricingDetail(gmkApplicationObj.id);
        Database.insert(new List<genesis__Application_Pricing_Detail__c> {pricingDetailsObj, gmkPricingDetailsObj},true);

        clcommon__Payment_Mode__c paymentMode = ApplicationOriginationTestHelper.createPaymentMode(ConstantValues.MOBILE_DEPOSIT);
        Database.insert(paymentMode,true);

        genesis__Funding_Transaction__c fundingTransacObj = ApplicationOriginationTestHelper.createFundingTransaction(paymentMode.id,pricingDetailsObj.id,applicationObj.id);
        fundingTransacObj.Principal_Paid__c = 1000;
        fundingTransacObj.genesis__Amount__c = 150;
        fundingTransacObj.genesis__Cleared__c = true;
        fundingTransacObj.Posted_to_NLS__c = false;

        genesis__Funding_Transaction__c fundingTransacObjTwo = ApplicationOriginationTestHelper.createFundingTransaction(paymentMode.id,pricingDetailsObj.id,applicationObj.id);
        fundingTransacObj.Principal_Paid__c = 1000;
        fundingTransacObj.genesis__Amount__c = 150;
        fundingTransacObj.genesis__Cleared__c = true;
        fundingTransacObj.Posted_to_NLS__c = false;

        genesis__Funding_Transaction__c gmkFundingTransacObj = ApplicationOriginationTestHelper.createFundingTransaction(paymentMode.id,gmkPricingDetailsObj.id,gmkApplicationObj.id);
        gmkFundingTransacObj.Principal_Paid__c = 1000;
        gmkFundingTransacObj.genesis__Amount__c = 150;
        gmkFundingTransacObj.genesis__Cleared__c = true;
        gmkFundingTransacObj.Is_Clearing_Suspense__c = true;
        gmkFundingTransacObj.Posted_to_NLS__c = false;
        Database.insert(new List<genesis__Funding_Transaction__c> {fundingTransacObj, fundingTransacObjTwo, gmkFundingTransacObj}, true);
    }
    
    /**
     * @description This class implements a interface method which return mock response of NLS
     */
     /**
    * @description       : This class implements a interface method which return mock response of NLS
    * @author            : Kabir Pramanik
    * @last modified on  : 12-18-2024
    * @last modified by  : Kabir Pramanik
    **/
    public class NLSXMLImportHttpCalloutMock implements HttpCalloutMock {
        
        /**
        * @description : method to get mock response of NLS
        * @author Kabir Pramanik | 09-10-2024 
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
                response.setBody('{"status":{"code":200,"message":"Success"},"payload":{"data":""}}');
            }
            return response;
        }
    }

     /**
    * @description       : Setting up the Mock Response of FAILED status
    * @author            : Kabir Pramanik
    * @last modified on  : 12-18-2024
    * @last modified by  : Kabir Pramanik
    **/
    public class NLSXMLImportHttpCalloutFailureMock implements HttpCalloutMock {
        // Implement this interface method
        /**
        * @description : return the mock response of FAILED status
        * @author Kabir Pramanik | 12-17-2024
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setStatus('FAILED');
            response.setHeader('Content-Type', 'application/json');
            return response;
        }
    }

    /**
    * @description : test default success
    * @author Kabir Pramanik | 12-17-2024 
    **/
    @isTest
    public static void testMobileDepositCleared(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        
        System.runAs(adminUserObj){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutMock());
            Test.startTest();
            NLSXMLImportMobileDepositCalloutBatch obj = new NLSXMLImportMobileDepositCalloutBatch();
            DataBase.executeBatch(obj); 
            Test.stopTest();
            List<clcommon__Log__c> logList = [SELECT Id
                                                FROM clcommon__Log__c 
                                                WHERE Name = 'NLSXMLImportMobileDepositCalloutBatch'
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1]; 
            System.assertEquals(0,logList.size(), PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : Test Mobile Deposit overpayment
    * @author Kabir Pramanik | 12-17-2024 
    **/
    @isTest
    public static void testMobileDepositOverpayment(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        List<genesis__Funding_Transaction__c> fundingTransacObjList = [SELECT Id FROM genesis__Funding_Transaction__c];
        fundingTransacObjList[0].genesis__Amount__c = 4000;
        fundingTransacObjList[0].Principal_Paid__c = 1000;
        fundingTransacObjList[0].Pay_Off__c = 'Yes';
        Database.update(fundingTransacObjList[0],true);
        fundingTransacObjList.remove(0);
        Database.delete(fundingTransacObjList);
        System.runAs(adminUserObj){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutMock());
            Test.startTest();
            NLSXMLImportMobileDepositCalloutBatch obj = new NLSXMLImportMobileDepositCalloutBatch();
            DataBase.executeBatch(obj); 
            Test.stopTest();
            List<clcommon__Log__c> logList = [SELECT Id
                                                FROM clcommon__Log__c 
                                                WHERE Name = 'NLSXMLImportMobileDepositCalloutBatch'
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1]; 
            System.assertEquals(0,logList.size(), PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description :Test default failure for no response from nls
    * @author Simran | 09-24-2024 
    **/
    @isTest
    public static void testMobileDepositNotCleared(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAS(adminUserObj){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutFailureMock());
            Test.startTest();
            NLSXMLImportMobileDepositCalloutBatch obj = new NLSXMLImportMobileDepositCalloutBatch();
            DataBase.executeBatch(obj);
            Test.stopTest();
            List<clcommon__Log__c> logList = [SELECT Id
                                                    FROM clcommon__Log__c 
                                                    WHERE Name = 'NLSXMLImportMobileDepositCalloutBatch'
                                                    ORDER BY CreatedDate DESC 
                                                    LIMIT 1];   
            System.assertEquals(1,logList.size(), PortalConstants.ASSERTION_FAILED);
        }     
    }
}