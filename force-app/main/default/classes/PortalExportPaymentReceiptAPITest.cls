/**
 * @description       : Test class for PortalExportPaymentReceiptAPI
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 01-19-2025
 * @last modified by  : Rahul Gupta
**/
@isTest
public without sharing class PortalExportPaymentReceiptAPITest {

    /**
    * @description - Test setup for the test class
    * @author Sk Minsar | 12-16-2024 
    **/
    @TestSetup
    static void makeData(){
        
        ApplicationOriginationSetupTestHelper.createTestSetup();

        // add payment mode
        clcommon__Payment_Mode__c ach = ApplicationOriginationTestHelper.createPaymentMode('ACH');
        clcommon__Payment_Mode__c draft = ApplicationOriginationTestHelper.createPaymentMode('Draft');
        clcommon__Payment_Mode__c productReturn = ApplicationOriginationTestHelper.createPaymentMode('Product Return');
        clcommon__Payment_Mode__c payment = ApplicationOriginationTestHelper.createPaymentMode('Payment');
        clcommon__Payment_Mode__c mobileDeposit = ApplicationOriginationTestHelper.createPaymentMode('Mobile Deposit');

        Database.upsert(new List<clcommon__Payment_Mode__c>{ach, draft, productReturn, payment, mobileDeposit}, true);

        List<genesis__Applications__c> individualApplications = [
            SELECT Id
            FROM genesis__Applications__c
            WHERE Loan_Id__c = '139000'
            LIMIT 1
        ];
        individualApplications[0].genesis__Status__c = 'ACTIVE';
        Database.update(individualApplications, true);

        // create pricing details
        genesis__Application_Pricing_Detail__c pricingA = LoanServicingTestHelper.createPricingDetail(individualApplications[0].Id);
        pricingA.genesis__Enabled_Flag__c = true;
        Database.insert(pricingA, true);

        clcommon__Consolidated_Invoice__c invoiceACH = LoanServicingTestHelper.createInvoice(individualApplications[0].Id, ach.Id);
        invoiceACH.clcommon__Status__c = 'Pending';


        clcommon__Consolidated_Invoice__c invoiceDraft = LoanServicingTestHelper.createInvoice(individualApplications[0].Id, draft.Id);
        invoiceDraft.clcommon__Status__c = 'Pending';


        clcommon__Consolidated_Invoice__c invoiceProductReturn = LoanServicingTestHelper.createInvoice(individualApplications[0].Id, productReturn.Id);
        invoiceProductReturn.clcommon__Status__c = 'Pending';


        clcommon__Consolidated_Invoice__c invoicePayment = LoanServicingTestHelper.createInvoice(individualApplications[0].Id, payment.Id);
        invoicePayment.clcommon__Status__c = 'Pending';


        clcommon__Consolidated_Invoice__c invoiceMobileDeposit = LoanServicingTestHelper.createInvoice(individualApplications[0].Id, mobileDeposit.Id);
        invoiceMobileDeposit.clcommon__Status__c = 'Pending';

        Database.upsert(new List<clcommon__Consolidated_Invoice__c> {invoiceACH, invoiceDraft, invoiceProductReturn, invoicePayment, invoiceMobileDeposit}, true);

        // ACH transaction
        genesis__Funding_Transaction__c achTransaction = ApplicationOriginationTestHelper.createFundingTransaction(ach.Id, pricingA.Id, individualApplications[0].Id);
        achTransaction.Paid_By_Dealer__c = true;
        achTransaction.Invoice__c = invoiceACH.Id;

        // draft transaction
        genesis__Funding_Transaction__c draftTransaction = ApplicationOriginationTestHelper.createFundingTransaction(draft.Id, pricingA.Id, individualApplications[0].Id);
        draftTransaction.Paid_By_Dealer__c = true;
        draftTransaction.Invoice__c = invoiceDraft.Id;

        // product return transaction
        genesis__Funding_Transaction__c productReturnTransaction = ApplicationOriginationTestHelper.createFundingTransaction(productReturn.Id, pricingA.Id, individualApplications[0].Id);
        productReturnTransaction.Paid_By_Dealer__c = true;
        productReturnTransaction.Invoice__c = invoiceProductReturn.Id;

        // payment transaction
        genesis__Funding_Transaction__c paymentTransaction = ApplicationOriginationTestHelper.createFundingTransaction(ach.Id, pricingA.Id, individualApplications[0].Id);
        paymentTransaction.Paid_By_Dealer__c = true;
        paymentTransaction.Invoice__c = invoicePayment.Id;

        // mobile deposit transaction
        genesis__Funding_Transaction__c mobileDepositTransaction = ApplicationOriginationTestHelper.createFundingTransaction(ach.Id, pricingA.Id, individualApplications[0].Id);
        mobileDepositTransaction.Paid_By_Dealer__c = true;
        mobileDepositTransaction.Invoice__c = invoiceMobileDeposit.Id;

        Database.upsert(new List<genesis__Funding_Transaction__c>{achTransaction, draftTransaction, productReturnTransaction, paymentTransaction, mobileDepositTransaction}, true);

    }

    /**
    * @description - Returns the param Map for test methods
    * @author Sk Minsar | 12-16-2024 
    * @return Map<String, sObject> 
    **/
    private static Map<String, sObject> getContextMap() {

        List<User> clUsers = [
                    SELECT Id, 
                           AccountId, 
                           ContactId
                    FROM User 
                    WHERE Username = 'ross.geller@yopmail.com'
                    LIMIT 1
                ];

        List<User> growerUsers = [
                    SELECT Id, 
                           AccountId, 
                           ContactId
                    FROM User 
                    WHERE Username = 'star.lord@yopmail.com'
                    LIMIT 1
                ];

        List<genesis__Applications__c> applications = [
                    SELECT Id,
                           Dealer_Name__c
                    FROM genesis__Applications__c
                    WHERE genesis__Status__c = 'ACTIVE'
                    AND Loan_Id__c = '139000'
                    LIMIT 1
                ];

        Map<String, sObject> context = new Map<String, sObject> {
            'cl_user' => clUsers[0],
            'grower_user' => growerUsers[0],
            'application' => applications[0]
        };

        List<clcommon__Consolidated_Invoice__c> invoices = [
                    SELECT Id, 
                           Payment_Mode__r.Name
                    FROM clcommon__Consolidated_Invoice__c
                    LIMIT 10
                ];
        
        for (clcommon__Consolidated_Invoice__c invoice : invoices) {
            if (invoice.Payment_Mode__r.Name == 'ACH') {
                context.put('ach_invoice', invoice);
            }

            if (invoice.Payment_Mode__r.Name == 'Draft') {
                context.put('draft_invoice', invoice);
            }

            if (invoice.Payment_Mode__r.Name == 'Product Return') {
                context.put('product_return_invoice', invoice);
            }

            if (invoice.Payment_Mode__r.Name == 'Payment') {
                context.put('payment_invoice', invoice);
            }

            if (invoice.Payment_Mode__r.Name == 'Mobile Deposit') {
                context.put('mobile_deposit_invoice', invoice);
            }
        }

        return context;
    }


    /**
    * @description - success scenario - export ACH invoice by CL
    * @author Sk Minsar | 12-16-2024 
    **/
    @IsTest
    public static void testCertifiedLenderACHExportSuccess() {

        Map<String, Object> context = getContextMap();

        User clUser = (User) context.get('cl_user');
        clcommon__Consolidated_Invoice__c invoice = (clcommon__Consolidated_Invoice__c) context.get('ach_invoice');

        Map<String,Object> request = new Map<String,Object> {
            PortalConstants.INVOICE_ID_KEY => invoice.Id
        };

        System.runAs(clUser) {

            Test.startTest();
            PortalExportPaymentReceiptAPI exportApi = new PortalExportPaymentReceiptAPI();
            clcommon.Response response = exportApi.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }


    /**
    * @description - success scenario - export draft invoice by CL
    * @author Sk Minsar | 12-16-2024 
    **/
    @IsTest
    public static void testCertifiedLenderDraftExportSuccess() {

        Map<String, Object> context = getContextMap();

        User clUser = (User) context.get('cl_user');
        clcommon__Consolidated_Invoice__c invoice = (clcommon__Consolidated_Invoice__c) context.get('draft_invoice');

        Map<String,Object> request = new Map<String,Object> {
            PortalConstants.INVOICE_ID_KEY => invoice.Id
        };

        System.runAs(clUser) {

            Test.startTest();
            PortalExportPaymentReceiptAPI exportApi = new PortalExportPaymentReceiptAPI();
            clcommon.Response response = exportApi.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }


    /**
    * @description - success scenario - export product return invoice by CL
    * @author Sk Minsar | 12-16-2024 
    **/
    @IsTest
    public static void testCertifiedLenderProductReturnExportSuccess() {

        Map<String, Object> context = getContextMap();

        User clUser = (User) context.get('cl_user');
        clcommon__Consolidated_Invoice__c invoice = (clcommon__Consolidated_Invoice__c) context.get('product_return_invoice');

        Map<String,Object> request = new Map<String,Object> {
            PortalConstants.INVOICE_ID_KEY => invoice.Id
        };

        System.runAs(clUser) {

            Test.startTest();
            PortalExportPaymentReceiptAPI exportApi = new PortalExportPaymentReceiptAPI();
            clcommon.Response response = exportApi.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }


    /**
    * @description - success scenario - export payment invoice by CL
    * @author Sk Minsar | 12-16-2024 
    **/
    @IsTest
    public static void testCertifiedLenderPaymentExportSuccess() {

        Map<String, Object> context = getContextMap();

        User clUser = (User) context.get('cl_user');
        clcommon__Consolidated_Invoice__c invoice = (clcommon__Consolidated_Invoice__c) context.get('payment_invoice');

        Map<String,Object> request = new Map<String,Object> {
            PortalConstants.INVOICE_ID_KEY => invoice.Id
        };

        System.runAs(clUser) {

            Test.startTest();
            PortalExportPaymentReceiptAPI exportApi = new PortalExportPaymentReceiptAPI();
            clcommon.Response response = exportApi.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }


    /**
    * @description - success scenario - export mobile deposit invoice by CL
    * @author Sk Minsar | 12-16-2024 
    **/
    @IsTest
    public static void testCertifiedLenderMobileDepositExportSuccess() {

        Map<String, Object> context = getContextMap();

        User clUser = (User) context.get('cl_user');
        clcommon__Consolidated_Invoice__c invoice = (clcommon__Consolidated_Invoice__c) context.get('mobile_deposit_invoice');

        Map<String,Object> request = new Map<String,Object> {
            PortalConstants.INVOICE_ID_KEY => invoice.Id
        };

        System.runAs(clUser) {

            Test.startTest();
            PortalExportPaymentReceiptAPI exportApi = new PortalExportPaymentReceiptAPI();
            clcommon.Response response = exportApi.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - success scenario - export payment invoice by grower
    * @author Sk Minsar | 12-16-2024 
    **/
    @IsTest
    public static void testGrowerPaymentExportSuccess() {

        Map<String, Object> context = getContextMap();

        User growerUser = (User) context.get('grower_user');
        clcommon__Consolidated_Invoice__c invoice = (clcommon__Consolidated_Invoice__c) context.get('payment_invoice');

        Map<String,Object> request = new Map<String,Object> {
            PortalConstants.INVOICE_ID_KEY => invoice.Id
        };

        System.runAs(growerUser) {

            Test.startTest();
            PortalExportPaymentReceiptAPI exportApi = new PortalExportPaymentReceiptAPI();
            clcommon.Response response = exportApi.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - success scenario - export payment invoice by grower when working with different dealer
    * @author Sk Minsar | 12-16-2024 
    **/
    @IsTest
    public static void testGrowerPaymentExportDifferetDealerSuccess() {

        Map<String, Object> context = getContextMap();

        User growerUser = (User) context.get('grower_user');
        clcommon__Consolidated_Invoice__c invoice = (clcommon__Consolidated_Invoice__c) context.get('payment_invoice');

        List<Account> growerAccounts = [
            SELECT Id, ParentId
            FROM Account
            WHERE Id = :growerUser.AccountId
            LIMIT 1
        ];

        Account differentDealerAccount = ApplicationOriginationTestHelper.createDealerAccount(null);
        Database.insert(differentDealerAccount, true);

        growerAccounts[0].ParentId = differentDealerAccount.Id;
        Database.update(growerAccounts, true);


        Map<String,Object> request = new Map<String,Object> {
            PortalConstants.INVOICE_ID_KEY => invoice.Id
        };

        System.runAs(growerUser) {

            Test.startTest();
            PortalExportPaymentReceiptAPI exportApi = new PortalExportPaymentReceiptAPI();
            clcommon.Response response = exportApi.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - failure scenario - export payment invoice by grower where there is no party
    * @author Sk Minsar | 12-16-2024 
    **/
    @IsTest
    public static void testGrowerPaymentExportAccessFailure() {

        Map<String, Object> context = getContextMap();

        User growerUser = (User) context.get('grower_user');
        clcommon__Consolidated_Invoice__c invoice = (clcommon__Consolidated_Invoice__c) context.get('payment_invoice');

        List<clcommon__Party__c> growerParties = [
            SELECT Id
            FROM clcommon__Party__c
            WHERE clcommon__Account__c = :growerUser.AccountId
            LIMIT 10
        ];

        Database.delete(growerParties, true);

        Map<String,Object> request = new Map<String,Object> {
            PortalConstants.INVOICE_ID_KEY => invoice.Id
        };

        System.runAs(growerUser) {

            Test.startTest();
            PortalExportPaymentReceiptAPI exportApi = new PortalExportPaymentReceiptAPI();
            clcommon.Response response = exportApi.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - failiure scenario - export payment invoice by grower with missing request body
    * @author Sk Minsar | 12-16-2024 
    **/
    @IsTest
    public static void testGrowerPaymentExportMissingRequestFailure() {

        Map<String, Object> context = getContextMap();

        User growerUser = (User) context.get('grower_user');

        Map<String,Object> request = new Map<String,Object>();

        System.runAs(growerUser) {

            Test.startTest();
            PortalExportPaymentReceiptAPI exportApi = new PortalExportPaymentReceiptAPI();
            clcommon.Response response = exportApi.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - failiure scenario - export payment invoice by grower with invalid invoice
    * @author Sk Minsar | 12-16-2024 
    **/
    @IsTest
    public static void testGrowerPaymentExportInvalidInvoiceFailure() {

        Map<String, Object> context = getContextMap();

        User growerUser = (User) context.get('grower_user');

        Map<String,Object> request = new Map<String,Object> {
            PortalConstants.INVOICE_ID_KEY => '123456'
        };

        System.runAs(growerUser) {

            Test.startTest();
            PortalExportPaymentReceiptAPI exportApi = new PortalExportPaymentReceiptAPI();
            clcommon.Response response = exportApi.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
}