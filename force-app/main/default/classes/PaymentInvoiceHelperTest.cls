/**
 * @description       : Test class for PaymentInvoiceHelper
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 01-31-2025
 * @last modified by  : Ayush Kumar Singh
**/
@isTest
public without sharing class PaymentInvoiceHelperTest {

    /**
    * @description - Create test data
    * @author Sk Minsar | 12-16-2024 
    **/
    @testSetup
	static void makeData() {
        clcommon__Floating_Rate_Index__c floatingRateIndex = ApplicationOriginationTestHelper.createFloatingRateIndex('CFA_Advantage_Rate',11);
        Database.insert(floatingRateIndex, true);

        CFA_Partner_Program__c partnerProgram = ApplicationOriginationTestHelper.createPartnerProgram('Test Partner Program',floatingRateIndex);
        Database.insert(partnerProgram, true);

        // create legal entity
		clcommon__Legal_Entity__c legalEntity = TestClassHelper.createLegalEntity('Individual(s) - Sole Proprietorship');

        // create business information
        genesis__Business_Information__c dealerBusinessInfoObj = TestClassHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c businessInfoObj = TestClassHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj, businessInfoObj},true);

        // create dealer account
        Account dealerAccountObj = TestClassHelper.createDealerAccount(dealerBusinessInfoObj.id);
        dealerAccountObj.CFA_Partner_Program__c = partnerProgram.Id;
        Database.insert(dealerAccountObj,true);
                    
        // creating Accounts
        Account clUserAccount = TestClassHelper.createCLAccount(dealerBusinessInfoObj.id, dealerAccountObj.id);
        Account borrowerAccountObj = TestClassHelper.createSolePropAccount(legalEntity,businessInfoObj.id); 
        Database.insert(new List<Account>{clUserAccount, borrowerAccountObj},true);

        //Create Contacts
        Contact clUserContact = TestClassHelper.createCLContact(clUserAccount.id);
        Contact borrowerContact = TestClassHelper.createBorrowerContact(borrowerAccountObj.id);
        Database.insert(new List<Contact>{clUserContact, borrowerContact}, true);

        User clUser = TestClassHelper.createCLUser(clUserContact.id);
        Database.insert(clUser, true);

        clcommon__Reciprocal_Role__c role  = TestClassHelper.createReciprocalRole('Certified Lender');
        Database.insert(role,true);

        clcommon__Relationship__c relationship = TestClassHelper.createCLDealerRelationship(role,dealerAccountObj.id,clUserAccount.id);
        Database.insert(relationship,true);

        clcommon__Bank_Account__c bankAccount = TestClassHelper.createBankAccount(dealerAccountObj.id);
        Database.insert(bankAccount,true);

        // create loan product
        clcommon__CL_Product__c clProductobj = TestClassHelper.createCLProductForApplication();
        Database.insert(clProductobj,true);

        clcommon__CL_Purpose__c clPurpose = TestClassHelper.createCLPurposeForApplication();
        Database.insert(clPurpose,true);

        //Create application
        genesis__Applications__c applicationObj = TestClassHelper.createCurrCropYearApplication(new Map<String,Id>{
            'dealerAccountId' => dealerAccountObj.id,
            'clProductId' => clProductobj.id,
            'clPurposeId' => clPurpose.id,
            'borrowerAccountId' => borrowerAccountObj.id,
            'borrowerContactId' => borrowerContact.id,
            'clAccountId' => clUserAccount.id
        });
        Database.insert(applicationObj,true);

        // Creating ACH funding transaction properties
        clcommon__Funding_Transactions_Properties__c achfundingPropertiesObj = LoanServicingTestHelper.createAchFundingTransactionProperties();
        Database.insert(achfundingPropertiesObj,true);

        Map<String, clcommon__Payment_Mode__c> paymentModeMap = LoanServicingTestHelper.createPaymentMode();
         // Create ACH Payment Mode
 
         Database.insert(new List<clcommon__Payment_Mode__c>{
            paymentModeMap.get('DRAFT'),
             paymentModeMap.get('ACH'),
             paymentModeMap.get('PAYMENT'),
             paymentModeMap.get('MOBILE DEPOSIT')
         },true);
         
        // create rate card and pricing detail
        genesis__Rate_Card_Setup_Header__c rateCardSetupHeaderObj = TestClassHelper.createCurrYearRateCardHeader(dealerAccountObj);
        Database.insert(rateCardSetupHeaderObj, true);
        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailObj = TestClassHelper.createRateCardSetupDetailOne(rateCardSetupHeaderObj);
        Database.insert(rateCardSetupDetailObj, true);
         genesis__Application_Pricing_Detail__c appPricingDetailObj = TestClassHelper.createEnabledPricingDetail(applicationObj, rateCardSetupDetailObj.Id);
         Database.insert(appPricingDetailObj, true);
        //Create invoice
        clcommon__Consolidated_Invoice__c achInvoiceObj = LoanServicingTestHelper.createInvoice(applicationObj.Id,  paymentModeMap.get('ACH').id);
        clcommon__Consolidated_Invoice__c draftInvoiceObj = LoanServicingTestHelper.createInvoice(applicationObj.Id, paymentModeMap.get('DRAFT').Id);
        clcommon__Consolidated_Invoice__c paymentInvoiceObj = LoanServicingTestHelper.createInvoice(applicationObj.Id, paymentModeMap.get('PAYMENT').Id);
        clcommon__Consolidated_Invoice__c mobileDepositInvoiceObj = LoanServicingTestHelper.createInvoice(applicationObj.Id, paymentModeMap.get('MOBILE DEPOSIT').Id);
        achInvoiceObj.OwnerId = clUser.Id;
        achInvoiceObj.Invoice_Date__c = System.now();
        draftInvoiceObj.OwnerId = clUser.Id;
        draftInvoiceObj.Invoice_Date__c = System.now();
        paymentInvoiceObj.OwnerId = clUser.Id;
        paymentInvoiceObj.Invoice_Date__c = System.now();
        mobileDepositInvoiceObj.OwnerId = clUser.Id;
        mobileDepositInvoiceObj.Invoice_Date__c = System.now();
        Database.insert(new List<clcommon__Consolidated_Invoice__c>{
            achInvoiceObj,
            draftInvoiceObj,
            paymentInvoiceObj,
            mobileDepositInvoiceObj
        }, true);

        // Creating ACH funding transaction
        genesis__Funding_Transaction__c achfundingTransactionObj = LoanServicingTestHelper.createFundingTransaction(paymentModeMap.get('ACH').Id, achfundingPropertiesObj.Id, applicationObj.Id);
        achfundingTransactionObj.Pricing_Detail__c = appPricingDetailObj.Id;
        achfundingTransactionObj.invoice__c = achInvoiceObj.Id;

        genesis__Funding_Transaction__c paymentfundingTransacForA = LoanServicingTestHelper.createFundingTransaction(paymentModeMap.get('PAYMENT').Id, achfundingPropertiesObj.Id, applicationObj.Id);
        paymentfundingTransacForA.Pricing_Detail__c = appPricingDetailObj.Id;
        paymentfundingTransacForA.invoice__c = paymentInvoiceObj.Id;

        genesis__Funding_Transaction__c paymentfundingTransacForB = LoanServicingTestHelper.createFundingTransaction(paymentModeMap.get('PAYMENT').Id, achfundingPropertiesObj.Id, applicationObj.Id);
        paymentfundingTransacForB.Pricing_Detail__c = appPricingDetailObj.Id;
        paymentfundingTransacForB.invoice__c = paymentInvoiceObj.Id;

        genesis__Funding_Transaction__c paymentfundingTransacForC = LoanServicingTestHelper.createFundingTransaction(paymentModeMap.get('PAYMENT').Id, achfundingPropertiesObj.Id, applicationObj.Id);
        paymentfundingTransacForB.Pricing_Detail__c = appPricingDetailObj.Id;
        paymentfundingTransacForB.invoice__c = paymentInvoiceObj.Id;

        genesis__Funding_Transaction__c paymentfundingTransacForD = LoanServicingTestHelper.createFundingTransaction(paymentModeMap.get('MOBILE DEPOSIT').Id, achfundingPropertiesObj.Id, applicationObj.Id);
        paymentfundingTransacForD.Pricing_Detail__c = appPricingDetailObj.Id;
        paymentfundingTransacForD.invoice__c = mobileDepositInvoiceObj.Id;
        Database.insert(new List<genesis__Funding_Transaction__c> {paymentfundingTransacForA,paymentfundingTransacForB,paymentfundingTransacForC,achfundingTransactionObj,paymentfundingTransacForD},true);

        //Updating total amount in invoice
        achInvoiceObj.Total_Amount__c = achfundingTransactionObj.genesis__Amount__c;
        paymentInvoiceObj.Total_Amount__c = paymentfundingTransacForA.genesis__Amount__c + paymentfundingTransacForB.genesis__Amount__c + paymentfundingTransacForC.genesis__Amount__c;
        Database.update(new List<clcommon__Consolidated_Invoice__c>{achInvoiceObj,paymentInvoiceObj}, true);
    }
 
    /**
    * @description - Returns the cl User
    * @author Suraj Kumar | 11-24-2023 
    * @return User 
    **/
    private static User getCertifiedLenderUser() {
		List<User> userList = [SELECT Id
                                    FROM User 
                                    WHERE AccountId IN (
                                        SELECT Id 
                                        FROM Account 
                                        WHERE Name = 'Ross Geller')];
                                    
        if (userList.size() == 1) {
            return userList[0];
        } 
        
        return null;
    }

    /**
    * @description - Returns the Admin User
    * @author Sk Minsar | 12-18-2024 
    * @return User 
    **/
    private static User getAdminUser(){
        return [
            SELECT Id 
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ][0];
    }

    /**
    * @description - returns the payment mode Id
    * @author Sk Minsar | 12-17-2024 
    * @param paymentMode 
    * @return clcommon__Payment_Mode__c 
    **/
    private static String getPaymentMode(String paymentMode){
        List<clcommon__Payment_Mode__c> paymentModeList = [SELECT Id FROM clcommon__Payment_Mode__c WHERE Name =:paymentMode LIMIT 1 ];
        return String.valueOf(paymentModeList[0].Id);
    }

    /**
    * @description - This method return the parameter map which is used in invoking the class
    * @author Sk Minsar | 12-16-2024 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getParamMap(){
         List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                    genesis__Loan_Number__c 
                                                      FROM genesis__Applications__c 
                                                      WHERE genesis__Loan_Number__c = '300023456'];

        List<clcommon__Bank_Account__c> bankAccountList = [SELECT Id 
                                                       FROM clcommon__Bank_Account__c 
                                                       WHERE clcommon__Bank_Account_Name__c = 'Sam Grower'];

        List<genesis__Application_Pricing_Detail__c> pricingsList = [SELECT id, 
                                                                        Loan_Number__c,
                                                                        genesis__Interest_Rate__c, 
                                                                        Principal_Advanced__c, 
                                                                        Accrued_Interest__c, 
                                                                        Fees__c, 
                                                                        Principal_To_Be_Paid__c, 
                                                                        Interest_To_Be_Paid__c, 
                                                                        Fees_To_Be_Paid__c, 
                                                                        Payment__c,
                                                                        genesis__Application__c 
                                                                FROM genesis__Application_Pricing_Detail__c 
                                                                WHERE genesis__Enabled_Flag__c = true
                                                                ORDER BY genesis__Interest_Rate__c DESC,
                                                                Loan_Number__c ASC];

        List<clcommon__Consolidated_Invoice__c> invoiceList = [SELECT Id, 
                                                                    Total_Amount__c,
                                                                    Total_Fees__c,
                                                                    Total_Interest__c,
                                                                    Total_Principal__c,
                                                                    clcommon__status__c,
                                                                    Payment_Mode__c,
                                                                    Payment_Mode__r.Name 
                                                                FROM clcommon__Consolidated_Invoice__c 
                                                                WHERE Payment_Mode__r.Name = :PortalConstants.ACH
                                                                LIMIT 1];
        List<genesis__Funding_Transaction__c> fundingTransactionList = [SELECT Id,
                                                                            genesis__Amount__c,
                                                                            Posted_to_NLS__c,
                                                                            genesis__cleared__c,
                                                                            Status__c,
                                                                            Principal_Paid__c,
                                                                            Interest_Paid__c,
                                                                            Fees_Paid__c,
                                                                            genesis__Payment_Mode__c,
                                                                            Invoice__c
                                                                        FROM genesis__Funding_Transaction__c 
                                                                        WHERE genesis__Application__c = :applicationList[0].Id
                                                                        LIMIT 1];
        return new Map<String, Object>{
            'applicationList' => applicationList,
            'bankAccountList' => bankAccountList,
            'pricingsList' => pricingsList,
            'invoiceList' => invoiceList,
            'fundingTransactionList' => fundingTransactionList
        };
    }

    /**
    * @description - This method test the createInvoice method
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testCreateInvoice(){
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)paramMap.get('applicationList');
        String paymentMode = getPaymentMode(ConstantValues.ACH);
        System.runAs(getAdminUser()) {
            Test.startTest();
            clcommon__Consolidated_Invoice__c responseInvoiceObj = PaymentInvoiceHelper.createInvoice(String.valueOf(applicationList[0].Id), paymentMode);
            System.assertEquals(responseInvoiceObj!=null, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - This method test the createInvoice method
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testCreateInvoiceWithTotalAmount(){
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)paramMap.get('applicationList');
        String paymentMode = getPaymentMode(ConstantValues.ACH);
        System.runAs(getAdminUser()) {
            Test.startTest();
            clcommon__Consolidated_Invoice__c responseInvoiceObj = PaymentInvoiceHelper.createInvoice(String.valueOf(applicationList[0].Id), paymentMode, 200.00);
            System.assertEquals(responseInvoiceObj!=null, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
        
    }

     /**
    * @description - This method test the createInvoice method
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testUpdateInvoice(){
        Map<String, Object> paramMap = getParamMap();
        List<clcommon__Consolidated_Invoice__c> invoiceList = (List<clcommon__Consolidated_Invoice__c>)paramMap.get('invoiceList');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PaymentInvoiceHelper.updateInvoice(invoiceList[0].Id, 200.20);
            List<clcommon__Consolidated_Invoice__c> responseInvoiceList = [SELECT Id, Total_Amount__c FROM clcommon__Consolidated_Invoice__c WHERE Id = :invoiceList[0].Id];
            System.assertEquals(responseInvoiceList[0].Total_Amount__c, 200.20, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test update or delete invoice
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void updateOrDeleteInvoiceForACH(){
        Map<String, Object> paramMap = getParamMap();
        List<clcommon__Consolidated_Invoice__c> invoiceList = (List<clcommon__Consolidated_Invoice__c>)paramMap.get('invoiceList');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PaymentInvoiceHelper.updateOrDeleteInvoice(invoiceList[0].Id,'ACH',200.20);
            List<clcommon__Consolidated_Invoice__c> responseInvoiceList = [SELECT Id, Total_Amount__c FROM clcommon__Consolidated_Invoice__c WHERE Id = :invoiceList[0].Id];
            System.assertEquals(responseInvoiceList.size()==0, true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    
    /**
    * @description - Test update or delete invoice
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void updateOrDeleteInvoiceForProductReturn(){
        Map<String, Object> paramMap = getParamMap();
        List<clcommon__Consolidated_Invoice__c> invoiceList = (List<clcommon__Consolidated_Invoice__c>)paramMap.get('invoiceList');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PaymentInvoiceHelper.updateOrDeleteInvoice(invoiceList[0].Id,'PRODUCT RETURN',200.20);
            List<clcommon__Consolidated_Invoice__c> responseInvoiceList = [SELECT Id, Total_Amount__c FROM clcommon__Consolidated_Invoice__c WHERE Id = :invoiceList[0].Id];
            System.assertEquals(responseInvoiceList.size()==0, true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description - Test update or delete invoice
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void updateOrDeleteInvoiceForPayment(){
         List<clcommon__Consolidated_Invoice__c> invoiceList = [SELECT Id, 
                                                                    Total_Amount__c,
                                                                    Total_Fees__c,
                                                                    Total_Interest__c,
                                                                    Total_Principal__c,
                                                                    clcommon__status__c,
                                                                    Payment_Mode__c,
                                                                    Payment_Mode__r.Name 
                                                                FROM clcommon__Consolidated_Invoice__c 
                                                                WHERE Payment_Mode__r.Name = 'PAYMENT'
                                                                LIMIT 1];
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PaymentInvoiceHelper.updateOrDeleteInvoice(invoiceList[0].Id,'PAYMENT',200.20);
            List<clcommon__Consolidated_Invoice__c> responseInvoiceList = [SELECT Id, Total_Amount__c FROM clcommon__Consolidated_Invoice__c WHERE Id = :invoiceList[0].Id];
            System.assertEquals(responseInvoiceList.size()==0, true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test createInvoiceForImportedCSV method
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    public static void testCreateInvoiceForImportedCSVForPayment(){
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)paramMap.get('applicationList');
        clcommon__Payment_Mode__c paymentTypePaymentMode = [SELECT Id FROM clcommon__Payment_Mode__c WHERE Name = 'Payment' LIMIT 1];
        Map<String, Map<String,String>> loanDetailsMap = new Map<String, Map<String, String>>{
            applicationList[0].genesis__Loan_Number__c => new Map<String, String>{
                PortalConstants.APPLICATION_ID_KEY =>  applicationList[0].Id,
                PortalConstants.KEY_AMOUNT => '200'
            }
        };
        System.runAs(getAdminUser()) {
            Test.startTest();
            Map<String, String> invoiceLoanMap = PaymentInvoiceHelper.createInvoiceForImportedCSV(String.valueOf(paymentTypePaymentMode.Id), loanDetailsMap);
            System.assertEquals(invoiceLoanMap.size()>0, true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
     /**
    * @description - Test createInvoiceForImportedCSV method
    * @author Ayush Kumar Singh | 12-18-2024 
    **/
    @isTest
    public static void testCreateInvoiceForImportedCSVForMobileDeposit(){
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)paramMap.get('applicationList');
        clcommon__Payment_Mode__c paymentTypePaymentMode = [SELECT Id FROM clcommon__Payment_Mode__c WHERE Name = 'MOBILE DEPOSIT' LIMIT 1];
        Map<String, Map<String,String>> loanDetailsMap = new Map<String, Map<String, String>>{
            applicationList[0].genesis__Loan_Number__c => new Map<String, String>{
                PortalConstants.APPLICATION_ID_KEY =>  applicationList[0].Id,
                PortalConstants.KEY_AMOUNT => '200'
            }
        };
        System.runAs(getAdminUser()) {
            Test.startTest();
            Map<String, String> invoiceLoanMap = PaymentInvoiceHelper.createInvoiceForImportedCSV(String.valueOf(paymentTypePaymentMode.Id), loanDetailsMap);
            System.assertEquals(invoiceLoanMap.size()>0, true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test updateInvoiceStatus method for status cleared
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    public static void testUpdateInvoiceStatusCleared(){
        Map<String, Object> paramMap = getParamMap();
        List<clcommon__Consolidated_Invoice__c> invoiceList = (List<clcommon__Consolidated_Invoice__c>)paramMap.get('invoiceList');
        List <genesis__Funding_Transaction__c> fundingTransactionList = (List<genesis__Funding_Transaction__c>)paramMap.get('fundingTransactionList');
        fundingTransactionList[0].Status__c = PortalConstants.STATUS_INITIATED;
        fundingTransactionList[0].genesis__cleared__c = true;
        Database.Update(fundingTransactionList[0], true);
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PaymentInvoiceHelper.updateInvoiceStatus(new List<Id>{invoiceList[0].Id}, PortalConstants.STATUS_INITIATED);
            List<clcommon__Consolidated_Invoice__c> responseInvoiceList = [SELECT Id, clcommon__status__c FROM clcommon__Consolidated_Invoice__c WHERE Id = :invoiceList[0].Id];
            System.assertEquals(responseInvoiceList[0].clcommon__status__c, PortalConstants.STATUS_PENDING, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test updateInvoiceStatus method for status cleared
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    public static void testUpdateInvoiceStatusPost(){
        Map<String, Object> paramMap = getParamMap();
        List<clcommon__Consolidated_Invoice__c> invoiceList = (List<clcommon__Consolidated_Invoice__c>)paramMap.get('invoiceList');
        List <genesis__Funding_Transaction__c> fundingTransactionList = (List<genesis__Funding_Transaction__c>)paramMap.get('fundingTransactionList');
        fundingTransactionList[0].Status__c = PortalConstants.STATUS_POSTED;
        fundingTransactionList[0].Posted_to_NLS__c = true;
        Database.Update(fundingTransactionList[0], true);
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PaymentInvoiceHelper.updateInvoiceStatus(new List<Id>{invoiceList[0].Id}, PortalConstants.STATUS_POSTED);
            List<clcommon__Consolidated_Invoice__c> responseInvoiceList = [SELECT Id, clcommon__status__c FROM clcommon__Consolidated_Invoice__c WHERE Id = :invoiceList[0].Id];
            System.assertEquals(responseInvoiceList[0].clcommon__status__c, PortalConstants.STATUS_PENDING, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test getClearOrPostTransactionList method for post status
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    public static void testGetPostTransactionList(){
        Map<String, Object> paramMap = getParamMap();
        List<clcommon__Consolidated_Invoice__c> invoiceList = (List<clcommon__Consolidated_Invoice__c>)paramMap.get('invoiceList');
        List <genesis__Funding_Transaction__c> fundingTransactionList = (List<genesis__Funding_Transaction__c>)paramMap.get('fundingTransactionList');
        fundingTransactionList[0].Status__c = PortalConstants.STATUS_POSTED;
        fundingTransactionList[0].Posted_to_NLS__c = true;
        Database.Update(fundingTransactionList[0], true);
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            List<AggregateResult> responseList = PaymentInvoiceHelper.getClearOrPostTransactionList(new List<Id>{invoiceList[0].Id}, PortalConstants.STATUS_POSTED);
            System.assertEquals(responseList.size()==0, true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description - Test getClearOrPostTransactionList method for cleared status
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    public static void testGetClearedTransactionList(){
        Map<String, Object> paramMap = getParamMap();
        List<clcommon__Consolidated_Invoice__c> invoiceList = (List<clcommon__Consolidated_Invoice__c>)paramMap.get('invoiceList');
        List <genesis__Funding_Transaction__c> fundingTransactionList = (List<genesis__Funding_Transaction__c>)paramMap.get('fundingTransactionList');
        fundingTransactionList[0].Status__c = PortalConstants.STATUS_INITIATED;
        fundingTransactionList[0].genesis__cleared__c = true;
        Database.Update(fundingTransactionList[0], true);
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            List<AggregateResult> responseList = PaymentInvoiceHelper.getClearOrPostTransactionList(new List<Id> {invoiceList[0].Id}, PortalConstants.STATUS_INITIATED);
            System.assertEquals(responseList.size()==0, true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test AddInvoiceIdSet Method
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    public static void testAddInvoiceIdSet(){
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)paramMap.get('applicationList');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            Set<Id> responseSet = PaymentInvoiceHelper.addInvoiceIdSet(applicationList[0].Id,new Set<Id>{});
            System.assertEquals(responseSet.size()>0, true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test updateInvoiceTotalAmounts method for ACH transactions
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    public static void testUpdateACHInvoiceTotalAmounts(){
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)paramMap.get('applicationList');
        List<clcommon__Consolidated_Invoice__c> invoiceList = (List<clcommon__Consolidated_Invoice__c>)paramMap.get('invoiceList');
        invoiceList[0].Total_Amount__c = 80;
        Database.Update(invoiceList[0], true);
        List<genesis__Funding_Transaction__c> fundingTransactionList = [SELECT Id,
                                                                            genesis__Amount__c,
                                                                            Posted_to_NLS__c,
                                                                            genesis__cleared__c,
                                                                            Status__c,
                                                                            Principal_Paid__c,
                                                                            Interest_Paid__c,
                                                                            Fees_Paid__c,
                                                                            genesis__Payment_Mode__c,
                                                                            Invoice__c
                                                                        FROM genesis__Funding_Transaction__c 
                                                                        WHERE genesis__Application__c = :applicationList[0].Id
                                                                        AND Invoice__c = :invoiceList[0].id
                                                                        LIMIT 1];
        fundingTransactionList[0].genesis__Amount__c = 100;
        Database.Update(fundingTransactionList[0], true);
        System.runAs(getAdminUser()) {
            Test.startTest();
            PaymentInvoiceHelper.updateInvoiceTotalAmounts(invoiceList);
            List<clcommon__Consolidated_Invoice__c> responseInvoiceList = [SELECT Id, Total_Amount__c FROM clcommon__Consolidated_Invoice__c WHERE Id = :invoiceList[0].Id];
            System.assertEquals(responseInvoiceList[0].Total_Amount__c, 100, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test updateInvoiceTotalAmounts method for payment transactions
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    public static void testUpdatePaymentInvoiceTotalAmounts(){
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)paramMap.get('applicationList');
        List<clcommon__Consolidated_Invoice__c> invoiceList = (List<clcommon__Consolidated_Invoice__c>)paramMap.get('invoiceList');
        clcommon__Payment_Mode__c paymentTypePaymentMode = [SELECT Id FROM clcommon__Payment_Mode__c WHERE Name = 'PAYMENT' LIMIT 1];
        invoiceList[0].Total_Amount__c = 80;
        invoiceList[0].Payment_Mode__c = paymentTypePaymentMode.Id;
        Database.Update(invoiceList[0], true);
        List<genesis__Funding_Transaction__c> fundingTransactionList = [SELECT Id,
                                                                            genesis__Amount__c,
                                                                            Posted_to_NLS__c,
                                                                            genesis__cleared__c,
                                                                            Status__c,
                                                                            Principal_Paid__c,
                                                                            Interest_Paid__c,
                                                                            Fees_Paid__c,
                                                                            genesis__Payment_Mode__c,
                                                                            Invoice__c
                                                                        FROM genesis__Funding_Transaction__c 
                                                                        WHERE genesis__Application__c = :applicationList[0].Id
                                                                        AND Invoice__c = :invoiceList[0].id
                                                                        LIMIT 1];
        fundingTransactionList[0].Principal_Paid__c = 20;
        fundingTransactionList[0].Interest_Paid__c = 30;
        fundingTransactionList[0].Fees_Paid__c = 50;
        fundingTransactionList[0].genesis__Amount__c = 100;
        fundingTransactionList[0].genesis__Payment_Mode__c = paymentTypePaymentMode.Id;
        Database.Update(fundingTransactionList[0], true);
        System.runAs(getAdminUser()) {
            Test.startTest();
            PaymentInvoiceHelper.updateInvoiceTotalAmounts(invoiceList);
            List<clcommon__Consolidated_Invoice__c> responseInvoiceList = [SELECT Id, Total_Amount__c FROM clcommon__Consolidated_Invoice__c WHERE Id = :invoiceList[0].Id];
            System.assertEquals(responseInvoiceList[0].Total_Amount__c, 100, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
     /**
    * @description - Test updateInvoiceTotalAmounts method for payment transactions
    * @author Ayush Kumar Singh | 12-18-2024 
    **/
    @isTest
    public static void testExportInvoiceAsPDFForPayment(){
        Map<String, Object> paramMap = getParamMap();
        List<clcommon__Consolidated_Invoice__c> invoiceList = [SELECT Id, 
                                                                    Total_Amount__c,
                                                                    Total_Fees__c,
                                                                    Total_Interest__c,
                                                                    Total_Principal__c,
                                                                    clcommon__status__c,
                                                                    Payment_Mode__c,
                                                                    Payment_Mode__r.Name 
                                                                FROM clcommon__Consolidated_Invoice__c 
                                                                WHERE Payment_Mode__r.Name = 'PAYMENT'
                                                                LIMIT 1];
        clcommon__Payment_Mode__c paymentTypePaymentMode = [SELECT Id FROM clcommon__Payment_Mode__c WHERE Name = 'PAYMENT' LIMIT 1];
        invoiceList[0].Total_Amount__c = 80;
        invoiceList[0].Payment_Mode__c = paymentTypePaymentMode.Id;
        Database.Update(invoiceList[0], true);
        List <genesis__Funding_Transaction__c> fundingTransactionList = (List<genesis__Funding_Transaction__c>)paramMap.get('fundingTransactionList');
        fundingTransactionList[0].Principal_Paid__c = 20;
        fundingTransactionList[0].Interest_Paid__c = 30;
        fundingTransactionList[0].Fees_Paid__c = 50;
        fundingTransactionList[0].genesis__Amount__c = 100;
        fundingTransactionList[0].genesis__Payment_Mode__c = paymentTypePaymentMode.Id;
        fundingTransactionList[0].Invoice__c = invoiceList[0].id;
        Database.Update(fundingTransactionList[0], true);
        System.runAs(getAdminUser()) {
            Test.startTest();
            PageReference pageObj = PaymentInvoiceHelper.exportInvoiceAsPDF(invoiceList[0].Id);
            System.assertEquals(pageObj != null,true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    @isTest
    public static void testExportInvoiceAsPDFForMobileDeposit(){
        Map<String, Object> paramMap = getParamMap();
        List<clcommon__Consolidated_Invoice__c> invoiceList = [SELECT Id, 
                                                                    Total_Amount__c,
                                                                    Total_Fees__c,
                                                                    Total_Interest__c,
                                                                    Total_Principal__c,
                                                                    clcommon__status__c,
                                                                    Payment_Mode__c,
                                                                    Payment_Mode__r.Name 
                                                                FROM clcommon__Consolidated_Invoice__c 
                                                                WHERE Payment_Mode__r.Name = 'MOBILE DEPOSIT'
                                                                LIMIT 1];
        clcommon__Payment_Mode__c paymentTypePaymentMode = [SELECT Id FROM clcommon__Payment_Mode__c WHERE Name = 'MOBILE DEPOSIT' LIMIT 1];
        invoiceList[0].Total_Amount__c = 80;
        invoiceList[0].Payment_Mode__c = paymentTypePaymentMode.Id;
        Database.Update(invoiceList[0], true);
        List <genesis__Funding_Transaction__c> fundingTransactionList = (List<genesis__Funding_Transaction__c>)paramMap.get('fundingTransactionList');
        fundingTransactionList[0].Principal_Paid__c = 20;
        fundingTransactionList[0].Interest_Paid__c = 30;
        fundingTransactionList[0].Fees_Paid__c = 50;
        fundingTransactionList[0].genesis__Amount__c = 100;
        fundingTransactionList[0].genesis__Payment_Mode__c = paymentTypePaymentMode.Id;
        fundingTransactionList[0].Invoice__c = invoiceList[0].id;
        Database.Update(fundingTransactionList[0], true);
        System.runAs(getAdminUser()) {
            Test.startTest();
            PageReference pageObj = PaymentInvoiceHelper.exportInvoiceAsPDF(invoiceList[0].Id);
            System.assertEquals(pageObj != null,true, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

}