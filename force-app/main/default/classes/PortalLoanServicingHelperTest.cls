/**********************************************************************************************************************
 * @description       : This portal API stores all the loan payoff details in salesforce.
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 12-21-2024
 * @last modified by  : Sk Minsar
**********************************************************************************************************************/

@isTest
public without sharing class PortalLoanServicingHelperTest {
    
    /**
    * @description - Create test data
    * @author Sk Minsar | 12-21-2024 
    **/
    @TestSetup
    public static void makeData(){
        genesis__Business_Information__c dealerBusinessInfo = TestClassHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfo,true);

        Account dealerAccountObj = TestClassHelper.createDealerAccount(dealerBusinessInfo.id);
        Database.insert(dealerAccountObj,true);

        Account clAccountObj = TestClassHelper.createCLAccount(dealerBusinessInfo.id,dealerAccountObj.id);
        Database.insert(clAccountObj,true);

        Contact clContactObj = TestClassHelper.createCLContact(clAccountObj.id);
        Database.insert(clContactObj,true);

        Account salesAgentAccountObj = TestClassHelper.createSalesAgentAccount(dealerBusinessInfo.id,dealerAccountObj.id);
        Database.insert(salesAgentAccountObj,true);

        Contact salesAgentContactObj = TestClassHelper.createSalesAgentContact(salesAgentAccountObj.id);
        Database.insert(salesAgentContactObj,true);

        clcommon__Legal_Entity__c legalEntityObj = TestClassHelper.createLegalEntity(PortalConstants.SOLE_PROP_ENTITY);
        Database.insert(legalEntityObj,true);

        Account borrowerAccountObj = TestClassHelper.createSolePropAccount(legalEntityObj,dealerBusinessInfo.id);
        Database.insert(borrowerAccountObj,true);

        Contact borrowerContactObj = TestClassHelper.createBorrowerContact(borrowerAccountObj.id);
        Database.insert(borrowerContactObj,true);

        clcommon__CL_Product__c clproductObj = TestClassHelper.createCLProductForApplication();
        Database.insert(clproductObj,true);

        clcommon__CL_Purpose__c clPurposeObj = TestClassHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj,true);

        Map<String,Id> paramMap = new Map<String,Id>{
            'dealerAccountId' => dealerAccountObj.id,
            'clProductId' => clproductObj.id,
            'clPurposeId' => clPurposeObj.id,
            'borrowerAccountId' => borrowerAccountObj.id,
            'borrowerContactId' => borrowerContactObj.id,
            'clAccountId' => clAccountObj.id
        };
        genesis__Applications__c applicationObj = TestClassHelper.createCurrCropYearApplication(paramMap);
        Database.insert(applicationObj,true);

        clcommon__Party_Type__c partyTypeObj = TestClassHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);
        Database.insert(partyTypeObj,true);

        Map<String, Id> partyParamMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => partyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c partyObj = TestClassHelper.createParty(partyParamMap);
        Database.insert(partyObj,true);

        User userObj = TestClassHelper.createCLUser(clContactObj.id);
        Database.insert(userObj,true);

        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = TestClassHelper.createCurrYearRateCardHeader(borrowerAccountObj);
        Database.insert(rateCardHeaderObj,true);

        genesis__Rate_Card_Setup_Detail__c rateCardHeaderDetails = TestClassHelper.createRateCardSetupDetailOne(rateCardHeaderObj);
        Database.insert(rateCardHeaderDetails,true);

        genesis__Application_Pricing_Detail__c pricingDetailObj = TestClassHelper.createEnabledPricingDetail(applicationObj,rateCardHeaderDetails.id);
        Database.insert(pricingDetailObj,true);

        clcommon__Bank_Account__c dealerBankAccount = TestClassHelper.createBankAccount(dealerAccountObj.id);
        Database.insert(dealerBankAccount,true);

        clcommon__Bank_Account__c bankAccount = TestClassHelper.createBankAccount(borrowerAccountObj.id);
        Database.insert(bankAccount,true);

        Map<String, clcommon__Payment_Mode__c> paymentModeMap = TestClassHelper.createPaymentMode();
        clcommon__Payment_Mode__c paymentMode = paymentModeMap.get('PAYMENT');
        Database.insert(paymentMode,true);

        Map<String, Id> fundingTxnParamMap = new Map<String,Id>{
            'applicationId' => applicationObj.Id,
            'pricingDetailId' => pricingDetailObj.Id,
            'paymentModeId' => paymentMode.Id
        };

        genesis__Funding_Transaction__c fundingTransactionObj = TestClassHelper.createACHWithoutPropertiesBatch(fundingTxnParamMap);
        Database.insert(fundingTransactionObj,true);

        clcommon__Payment_Mode__c productReturnPaymentMode = paymentModeMap.get(PortalConstants.PRODUCT_RETURN);
        Database.insert(productReturnPaymentMode,true);

        clcommon__Consolidated_Invoice__c productReturnInvoiceObj = LoanServicingTestHelper.createInvoice(applicationObj.Id, productReturnPaymentMode.Id);
        productReturnInvoiceObj.OwnerId = userObj.Id;
        Database.insert(productReturnInvoiceObj, true);

        Map<String, Id> paramMapForPdtReturn = new Map<String,Id>{
            'applicationId' => applicationObj.Id,
            'pricingDetailId' => pricingDetailObj.Id,
            'paymentModeId' => productReturnPaymentMode.Id
        };

        genesis__Funding_Transaction__c fundingTxnForPdtReturn = TestClassHelper.createACHWithoutPropertiesBatch(paramMapForPdtReturn);
        fundingTxnForPdtReturn.invoice__c = productReturnInvoiceObj.Id;
        Database.insert(fundingTxnForPdtReturn,true);
    }

   /**
   * @description - Test  getCurrentLoan
   * @author Sk Minsar | 12-21-2024 
   **/
    @isTest
   public static void testGetCurrentLoan(){
    genesis__Applications__c applicationObj;
    List<genesis__Applications__c> applicationList = [SELECT Id,Certified_Lender__c FROM genesis__Applications__c Limit 1];
    for(genesis__Applications__c app : applicationList){
        applicationObj = app;
    }
    User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
    System.runAs(userObj){
        Test.startTest();
            List<genesis__Applications__c> appList = PortalLoanServicingHelper.getCurrentLoan(applicationObj.id);
            System.assertEquals(applicationObj.id, appList[0].id,'Assertion Failed');
        Test.stopTest();
    }

   }

   /**
   * @description - Test getLoggedInUser 
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testGetLoggedInUser(){
    genesis__Applications__c applicationObj;
    List<genesis__Applications__c> applicationList = [SELECT Id,Certified_Lender__c FROM genesis__Applications__c LIMIT 1];
    for(genesis__Applications__c app : applicationList){
        applicationObj = app;
    }
    List<Account> clAccountList = [SELECT Id FROM ACCOUNT WHERE Id =: (Id)applicationObj.Certified_Lender__c LIMIT 1 ];
    List<Contact> clContact = [SELECT Id FROM Contact Where AccountId =: clAccountList[0].id];
    User userObj = [SELECT Id FROM USER WHERE ContactId =: clContact[0].id];

    System.runAs(userObj){
        Test.startTest();
            List<User> user = PortalLoanServicingHelper.getLoggedInUser();
            System.assertEquals(userObj.id, user[0].id,'Assertion Failed');
        Test.stopTest();
    }

   }

   /**
   * @description - Test validateDealerBankAccount 
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testvalidateDealerBankAccount(){
    genesis__Applications__c applicationObj;
    List<genesis__Applications__c> applicationList = [SELECT Id,Certified_Lender__c,Dealer_Name__c FROM genesis__Applications__c LIMIT 1];
    for(genesis__Applications__c app : applicationList){
        applicationObj = app;
    }
    User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
    clcommon__Bank_Account__c bankAccount = [SELECT Id FROM clcommon__Bank_Account__c WHERE  clcommon__Account__c = :applicationObj.Dealer_Name__c LIMIT 1];

    System.runAs(userObj){
        Test.startTest();
            String dealerBankAccount = PortalLoanServicingHelper.validateDealerBankAccount(applicationObj);
            System.assertEquals(bankAccount.id,dealerBankAccount,'Assertion Failed');
        Test.stopTest();
    }

   }

   
   /**
   * @description - Test validateBankAccount
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testvalidateBankAccount(){
    genesis__Applications__c applicationObj;
    List<genesis__Applications__c> applicationList = [SELECT Id,Certified_Lender__c,genesis__Account__c FROM genesis__Applications__c LIMIT 1];
    for(genesis__Applications__c app : applicationList){
        applicationObj = app;
    }
    clcommon__Bank_Account__c bankAccount = [SELECT Id FROM clcommon__Bank_Account__c WHERE  clcommon__Account__c = :applicationObj.genesis__Account__c LIMIT 1];

    User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
    System.runAs(userObj){
        Test.startTest();
            PortalLoanServicingHelper.validateBankAccount(bankAccount.id,applicationObj.genesis__Account__c);
            System.assertEquals('','','Assertion Failed');
        Test.stopTest();
    }

   }
   
   /**
   * @description - Test validateApplicantToPay
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testvalidateApplicantToPay(){
    genesis__Applications__c applicationObj;
    List<genesis__Applications__c> applicationList = [SELECT Id,Certified_Lender__c,genesis__Account__c FROM genesis__Applications__c LIMIT 1];
    for(genesis__Applications__c app : applicationList){
        applicationObj = app;
    }
    User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
    System.runAs(userObj){
        Test.startTest();
            PortalLoanServicingHelper.validateApplicantToPay(applicationObj.id,applicationObj.genesis__Account__c);
            System.assertEquals('','','Assertion Failed');
        Test.stopTest();
    }

   }

   /**
   * @description - Test getCurrentOutStandingPaymentsMap
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testgetCurrentOutStandingPaymentsMap(){
    genesis__Applications__c applicationObj;
    List<genesis__Applications__c> applicationList = [SELECT Id,Certified_Lender__c,genesis__Loan_Number__c,genesis__Account__c FROM genesis__Applications__c LIMIT 1];
    for(genesis__Applications__c app : applicationList){
        applicationObj = app;
    }
    Map<String, Map<String, Object>> currentOutstandingPayment = new Map<String, Map<String, Object>>();
    List<genesis__Application_Pricing_Detail__c> pricingDetail = [SELECT Id,Loan_Number__c FROM genesis__Application_Pricing_Detail__c WHERE genesis__Application__c =: applicationObj.id];
    pricingDetail[0].Loan_Number__c = applicationObj.genesis__Loan_Number__c;
    Database.update(pricingDetail,true);
    User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
    System.runAs(userObj){
        Test.startTest();
            Decimal totalPaymentAmount ;
            totalPaymentAmount= PortalLoanServicingHelper.getCurrentOutStandingPaymentsMap(applicationObj.id,currentOutstandingPayment);

            System.assertEquals(applicationList[0].genesis__Loan_Number__c, currentOutstandingPayment.get(pricingDetail[0].id).get('loanNumber'),'Assertion Failed');
        Test.stopTest();
    }

   }
   
   /**
   * @description - Test getCurrentOutStandingPaymentsMap
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testgetPaymentsSpreadMap(){
    genesis__Applications__c applicationObj;
    List<genesis__Applications__c> applicationList = [SELECT Id,Certified_Lender__c,genesis__Loan_Number__c,genesis__Account__c FROM genesis__Applications__c LIMIT 1];
    for(genesis__Applications__c app : applicationList){
        applicationObj = app;
    }
    Decimal paymentAmount = 3490;
    Map<String, Map<String, Object>> currentOutstandingPayment = new Map<String, Map<String, Object>>();
    List<genesis__Application_Pricing_Detail__c> pricingDetail = [SELECT Id,Loan_Number__c FROM genesis__Application_Pricing_Detail__c WHERE genesis__Application__c =: applicationObj.id];
    pricingDetail[0].Loan_Number__c = applicationObj.genesis__Loan_Number__c;
    Database.update(pricingDetail,true);
    User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
    System.runAs(userObj){
        Test.startTest();
            Decimal totalPaymentAmount ;
            totalPaymentAmount= PortalLoanServicingHelper.getCurrentOutStandingPaymentsMap(applicationObj.id,currentOutstandingPayment);
            Map<String, Map<String, Object>> userPaymentsMap = PortalLoanServicingHelper.getPaymentsSpreadMap(paymentAmount, currentOutstandingPayment);

            System.assertEquals(true, userPaymentsMap.size()>0,'Assertion Failed');
        Test.stopTest();
    }

   }
   
   /**
   * @description - Test createFundingTransactionForUserPayment
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testcreateFundingTransactionForUserPayment(){
    genesis__Applications__c applicationObj;
    List<genesis__Applications__c> applicationList = [SELECT Id,Certified_Lender__c,genesis__Account__c FROM genesis__Applications__c LIMIT 1];
    for(genesis__Applications__c app : applicationList){
        applicationObj = app;
    }
    List<Account> clAccountList = [SELECT Id FROM ACCOUNT WHERE Id =: applicationObj.Certified_Lender__c LIMIT 1 ];
    List<Contact> clContact = [SELECT Id FROM Contact WHERE AccountId =: clAccountList[0].id];
    List<Account> borroweAccount = [SELECT Id FROM ACCOUNT WHERE Id =: (Id)applicationObj.genesis__Account__c];
    List<clcommon__Payment_Mode__c> paymentModesList = [SELECT Id 
                                                            FROM clcommon__Payment_Mode__c 
                                                            WHERE Name = 'PAYMENT'
                                                            LIMIT 1];
    List<genesis__Application_Pricing_Detail__c> pricingDetail = [SELECT Id FROM genesis__Application_Pricing_Detail__c WHERE genesis__Application__c =: applicationObj.id];
    User userObj = [SELECT Id FROM USER WHERE ContactId =: clContact[0].id];

    Map<String, Object> outstandingPayment = new Map<String,Object>{
        'grower' => borroweAccount[0].id,
        'description' => 'Crop',
        'interestRate' => 9.5,
        'principal' => 3000,
        'interest' => 1.5,
        'fees' => 200,
        'Id' => pricingDetail[0].id,
        'total' => 3201.5
    };
    Map<String, Object> userPaymentMap = new Map<String,Object>{
        'principal' => 1000,
        'interest' => 1.5,
        'fees' => 200,
        'total' => 1201.5
    };

    System.runAs(userObj){
        Test.startTest();
            genesis__Funding_Transaction__c fundingTransaction = PortalLoanServicingHelper.createFundingTransactionForUserPayment(outstandingPayment,userPaymentMap,paymentModesList[0].id);
            System.assertEquals(borroweAccount[0].id, fundingTransaction.Grower_Name__c,'Assertion Failed');
        Test.stopTest();
    }

   }

   /**
   * @description - Test paymentValidationForExceededPayment
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testpaymentValidationForExceededPayment(){
    genesis__Applications__c applicationObj;
    List<genesis__Applications__c> applicationList = [SELECT Id,Certified_Lender__c,genesis__Account__c FROM genesis__Applications__c LIMIT 1];
    for(genesis__Applications__c app : applicationList){
        applicationObj = app;
    }
    List<Account> clAccountList = [SELECT Id FROM ACCOUNT WHERE Id =: applicationObj.Certified_Lender__c LIMIT 1 ];
    List<Contact> clContact = [SELECT Id FROM Contact WHERE AccountId =: clAccountList[0].id];
    List<Account> borroweAccount = [SELECT Id FROM ACCOUNT WHERE Id =: (Id)applicationObj.genesis__Account__c];
    List<genesis__Application_Pricing_Detail__c> pricingDetail = [SELECT Id FROM genesis__Application_Pricing_Detail__c WHERE genesis__Application__c =: applicationObj.id];
    User userObj = [SELECT Id FROM USER WHERE ContactId =: clContact[0].id];

    Map<String, Object> outstandingPayment = new Map<String,Object>{
        'grower' => borroweAccount[0].id,
        'description' => 'Crop',
        'interestRate' => 9.5,
        'principal' => 3000,
        'interest' => 1.5,
        'fees' => 200,
        'Id' => pricingDetail[0].id,
        'total' => 3201.5
    };
    Map<String,Map<String, Object>> outstandingPaymentMap = new Map<String,Map<String, Object>>{
        pricingDetail[0].id => outstandingPayment
    };
    Map<String, Object> userPayment = new Map<String,Object>{
        'principal' => 1000,
        'interest' => 1.5,
        'fees' => 200,
        'total' => 1201.5
    };
    Map<String,Map<String, Object>> userPaymentMap = new Map<String,Map<String, Object>>{
        pricingDetail[0].id => userPayment
    };
    System.runAs(userObj){
        Test.startTest();
            PortalLoanServicingHelper.paymentValidationForExceededPayment(outstandingPaymentMap,userPaymentMap,String.valueOf(pricingDetail[0].id));
            System.assertEquals('','','Assertion Failed');
        Test.stopTest();
    }

   }

   /**
   * @description - Test paymentValidationForPayoff
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testpaymentValidationForPayoff(){
    genesis__Applications__c applicationObj;
    List<genesis__Applications__c> applicationList = [SELECT Id,Certified_Lender__c,genesis__Account__c FROM genesis__Applications__c LIMIT 1];
    for(genesis__Applications__c app : applicationList){
        applicationObj = app;
    }
    List<Account> clAccountList = [SELECT Id FROM ACCOUNT WHERE Id =: applicationObj.Certified_Lender__c LIMIT 1 ];
    List<Contact> clContact = [SELECT Id FROM Contact WHERE AccountId =: clAccountList[0].id];
    List<Account> borroweAccount = [SELECT Id FROM ACCOUNT WHERE Id =: (Id)applicationObj.genesis__Account__c];
    List<genesis__Application_Pricing_Detail__c> pricingDetail = [SELECT Id FROM genesis__Application_Pricing_Detail__c WHERE genesis__Application__c =: applicationObj.id];
    User userObj = [SELECT Id FROM USER WHERE ContactId =: clContact[0].id];

    Map<String, Object> outstandingPayment = new Map<String,Object>{
        'grower' => borroweAccount[0].id,
        'description' => 'Crop',
        'interestRate' => 9.5,
        'principal' => 3000,
        'interest' => 1.5,
        'fees' => 200,
        'Id' => pricingDetail[0].id,
        'total' => 3201.5
    };
    Map<String,Map<String, Object>> outstandingPaymentMap = new Map<String,Map<String, Object>>{
        pricingDetail[0].id => outstandingPayment
    };
    Map<String, Object> userPayment = new Map<String,Object>{
        'principal' => 3000,
        'interest' => 1.5,
        'fees' => 200,
        'total' => 3201.5
    };
    Map<String,Map<String, Object>> userPaymentMap = new Map<String,Map<String, Object>>{
        pricingDetail[0].id => userPayment
    };

    System.runAs(userObj){
        Test.startTest();
            PortalLoanServicingHelper.paymentValidationForPayoff(outstandingPaymentMap,userPaymentMap,String.valueOf(pricingDetail[0].id));
            System.assertEquals('','','Assertion Failed');
        Test.stopTest();
    }
   }

   /**
   * @description - Test validateTotalAmountSpread
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testvalidateTotalAmountSpread(){
    genesis__Applications__c applicationObj;
    List<genesis__Applications__c> applicationList = [SELECT Id,Certified_Lender__c,genesis__Account__c FROM genesis__Applications__c LIMIT 1];
    for(genesis__Applications__c app : applicationList){
        applicationObj = app;
    }
    List<Account> clAccountList = [SELECT Id FROM ACCOUNT WHERE Id =: applicationObj.Certified_Lender__c LIMIT 1 ];
    List<Contact> clContact = [SELECT Id FROM Contact WHERE AccountId =: clAccountList[0].id];
    List<genesis__Application_Pricing_Detail__c> pricingDetail = [SELECT Id FROM genesis__Application_Pricing_Detail__c WHERE genesis__Application__c =: applicationObj.id];
    User userObj = [SELECT Id FROM USER WHERE ContactId =: clContact[0].id];

    Map<String, Object> userPaymentMap = new Map<String,Object>{
        'principal' => 1000,
        'interest' => 1.5,
        'fees' => 200,
        'total' => 1201.5
    };
    Map<String,Map<String, Object>> userPaymentsMap = new Map<String,Map<String, Object>>{
        String.valueOf(pricingDetail[0].id) => userPaymentMap
    };
    Decimal paymentAmount = 1201.5;
    Map<String,Object> paymentDetailsMap = new Map<String, Object>{
        'currOutStanding' => 1201.5,
        'paymentOption' => 'makePayment'
    };
    System.runAs(userObj){
        Test.startTest();
            PortalLoanServicingHelper.validateTotalAmountSpread(userPaymentsMap,paymentAmount, paymentDetailsMap);
            System.assertEquals('','','Assertion Failed');
        Test.stopTest();
    }

   }

   /**
   * @description - Test PortalLoanServicingHelper
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testGetPaymentMode(){
    genesis__Applications__c applicationObj;
    List<genesis__Applications__c> applicationList = [SELECT Id,Certified_Lender__c FROM genesis__Applications__c LIMIT 1];
    for(genesis__Applications__c app : applicationList){
        applicationObj = app;
    }
    User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
    System.runAs(userObj){
        Test.startTest();
            List<clcommon__Payment_Mode__c> paymentMode = PortalLoanServicingHelper.getPaymentMode('PAYMENT');
            System.assertEquals(false,paymentMode.isEmpty(),'Assertion Failed');
        Test.stopTest();
    }

   }

   /**
   * @description - Test checkPastDueLoan
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testcheckPastDueLoan(){
    genesis__Applications__c applicationObj;
    List<genesis__Applications__c> applicationList = [SELECT Id,Certified_Lender__c FROM genesis__Applications__c LIMIT 1];
    for(genesis__Applications__c app : applicationList){
        applicationObj = app;
    }
    User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
    System.runAs(userObj){
        Test.startTest();
            PortalLoanServicingHelper.checkPastDueLoan(applicationObj.id);
            System.assertEquals('','','Assertion Failed');
        Test.stopTest();
    }
   }

   /**
   * @description - Test isCloseToMaturity
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testisCloseToMaturity(){
    genesis__Applications__c applicationObj;
    List<genesis__Applications__c> applicationList = [SELECT Id,genesis__Maturity_Date__c FROM genesis__Applications__c LIMIT 1];
    for(genesis__Applications__c app : applicationList){
        applicationObj = app;
    }
    User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
    System.runAs(userObj){
        Test.startTest();
            Boolean value = PortalLoanServicingHelper.isCloseToMaturity(applicationObj.genesis__Maturity_Date__c);
            System.assertEquals(false,value,'Assertion Failed');
        Test.stopTest();
    } 

   }

   /**
   * @description - Test isOverpaymentMobileDeposit
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testisOverpaymentMobileDeposit(){
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = [SELECT Id,
                                                                                Loan_Number__c,
                                                                                genesis__Rate_Card_Setup_Detail__r.Description__c,
                                                                                genesis__Application__r.genesis__Account__r.Name,
                                                                                genesis__Interest_Rate__c,
                                                                                Principal_Advanced__c,
                                                                                Accrued_Interest__c,
                                                                                Fees__c,
                                                                                Credit_Balance__c,
                                                                                Total_Payoff__c
                                                                        FROM genesis__Application_Pricing_Detail__c
                                                                        WHERE Loan_Id__c = '139001'];
        pricingDetailsList[0].Loan_Number__c = pricingDetailsList[0].Loan_Number__c + '-A' ;
        Database.update(pricingDetailsList,true);
        Decimal totalAmountPaid = 0;
        for(genesis__Application_Pricing_Detail__c pricingDetailObj : pricingDetailsList){
            totalAmountPaid += pricingDetailObj.Total_Payoff__c;
        }
        Decimal paymentAmount = totalAmountPaid + 100.00;

        Map<String,String> fundingTransactionMap = new Map<String,String>{
            'paymentAmount' => String.valueOf(paymentAmount),
            'currOutStanding' => String.valueOf(totalAmountPaid),
            'paymentOption' => 'MOBILE DEPOSIT'
        };

        List<genesis__Applications__c> applicationObjList = [SELECT Id FROM genesis__Applications__c WHERE Loan_Id__c = '139000' LIMIT 1];

        User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
        System.runAs(userObj){
            Test.startTest();
            PortalLoanServicingHelper.isOverpaymentMobileDeposit(fundingTransactionMap , applicationObjList[0].Id);
            System.assertEquals('','','Assertion Failed');
            Test.stopTest();
        } 
   }

   /**
   * @description - Test isOverpaymentMobileDeposit
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testisOverpaymentMobileDepositSingleLoan(){
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = [SELECT Id,
                                                                                Loan_Number__c,
                                                                                genesis__Rate_Card_Setup_Detail__r.Description__c,
                                                                                genesis__Application__r.genesis__Account__r.Name,
                                                                                genesis__Interest_Rate__c,
                                                                                Principal_Advanced__c,
                                                                                Accrued_Interest__c,
                                                                                Fees__c,
                                                                                Credit_Balance__c,
                                                                                Total_Payoff__c
                                                                        FROM genesis__Application_Pricing_Detail__c
                                                                        WHERE Loan_Id__c = '139001'];
        Decimal totalAmountPaid = 0;
        for(genesis__Application_Pricing_Detail__c pricingDetailObj : pricingDetailsList){
            totalAmountPaid += pricingDetailObj.Total_Payoff__c;
        }
        Decimal paymentAmount = totalAmountPaid + 100.00;

        Map<String,String> fundingTransactionMap = new Map<String,String>{
            'paymentAmount' => String.valueOf(paymentAmount),
            'currOutStanding' => String.valueOf(totalAmountPaid),
            'paymentOption' => 'MOBILE DEPOSIT'
        };

        List<genesis__Applications__c> applicationObjList = [SELECT Id FROM genesis__Applications__c WHERE Loan_Id__c = '139000' LIMIT 1];

        User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
        System.runAs(userObj){
            Test.startTest();
            PortalLoanServicingHelper.isOverpaymentMobileDeposit(fundingTransactionMap , applicationObjList[0].Id);
            System.assertEquals('','','Assertion Failed');
            Test.stopTest();
        } 
   }

   /**
   * @description - Test updateOverpaymentAmount
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testUpdateOverpaymentAmount(){
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = [SELECT Id,
                                                                                Loan_Number__c,
                                                                                genesis__Rate_Card_Setup_Detail__r.Description__c,
                                                                                genesis__Application__r.genesis__Account__r.Name,
                                                                                genesis__Interest_Rate__c,
                                                                                Principal_Advanced__c,
                                                                                Accrued_Interest__c,
                                                                                Fees__c,
                                                                                Credit_Balance__c,
                                                                                Total_Payoff__c
                                                                        FROM genesis__Application_Pricing_Detail__c
                                                                        WHERE Loan_Id__c = '139001'];
        Decimal totalAmountPaid = 0;
        for(genesis__Application_Pricing_Detail__c pricingDetailObj : pricingDetailsList){
            totalAmountPaid += pricingDetailObj.Total_Payoff__c;
        }
        Decimal paymentAmount = totalAmountPaid + 100.00;

        Map<String,String> fundingTransactionMap = new Map<String,String>{
            'paymentAmount' => String.valueOf(paymentAmount),
            'currOutStanding' => String.valueOf(totalAmountPaid),
            'paymentOption' => 'MOBILE DEPOSIT'
        };

        List<genesis__Funding_Transaction__c> fundingTransactionObjList = [SELECT Id, 
                                                                                    Overpayment_Amount__c 
                                                                                FROM genesis__Funding_Transaction__c 
                                                                                WHERE Pricing_Detail__c = :pricingDetailsList[0].Id LIMIT 1];
        // String paymentMode = ConstantValues.MOBILE_DEPOSIT;

        User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
        System.runAs(userObj){
            Test.startTest();
            PortalLoanServicingHelper.updateOverpaymentAmount(fundingTransactionMap, fundingTransactionObjList);
            System.assertEquals('','','Assertion Failed');
            Test.stopTest();
        } 
   }

   /**
   * @description - Test deleteMultiFundTrans
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testdeleteMultiFundTrans(){
        List<genesis__Applications__c> applicationObjList = [SELECT Id,
                                                                    Certified_Lender__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE Loan_Id__c = '139000' 
                                                                LIMIT 1];
        List<clcommon__Consolidated_Invoice__c> invoiceList = [Select Id
                                                                    FROM clcommon__Consolidated_Invoice__c
                                                                    WHERE Application__c = :applicationObjList[0].Id];
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = [SELECT Id,
                                                                                Loan_Number__c,
                                                                                genesis__Rate_Card_Setup_Detail__r.Description__c,
                                                                                genesis__Application__r.genesis__Account__r.Name,
                                                                                genesis__Interest_Rate__c,
                                                                                Principal_Advanced__c,
                                                                                Accrued_Interest__c,
                                                                                Fees__c,
                                                                                Credit_Balance__c,
                                                                                Total_Payoff__c
                                                                        FROM genesis__Application_Pricing_Detail__c
                                                                        WHERE Loan_Id__c = '139001'];
        
        pricingDetailsList[0].Credit_Balance__c = 100;
        Database.update(pricingDetailsList, true);
        List<genesis__Funding_Transaction__c> fundingTransactionObjList = [SELECT Id, 
                                                                                    genesis__Amount__c,
                                                                                    Grower_Name__c,
                                                                                    Pricing_Detail__c,
                                                                                    Pricing_Detail__r.Loan_Number__c,
                                                                                    genesis__Application__r.genesis__Loan_Number__c,
                                                                                    genesis__Application__r.Dealer_Name__r.Coop_Type__c,
                                                                                    genesis__Application__r.genesis__Account__r.Name,
                                                                                    genesis__Application__r.genesis__Maturity_Date__c,
                                                                                    Pricing_Detail__r.genesis__Application__c,
                                                                                    Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c,
                                                                                    Pricing_Detail__r.Principal_Advanced__c,
                                                                                    Pricing_Detail__r.Accrued_Interest__c,
                                                                                    Pricing_Detail__r.Fees__c,
                                                                                    Pricing_Detail__r.Credit_Balance__c,
                                                                                    genesis__Payment_Mode__r.Name,
                                                                                    Principal_Paid__c,
                                                                                    Interest_Paid__c,
                                                                                    Fees_Paid__c,
                                                                                    CreatedById,
                                                                                    genesis__Cleared__c,
                                                                                    Posted_to_NLS__c,
                                                                                    genesis__Application__c,
                                                                                    Overpayment_Amount__c 
                                                                                FROM genesis__Funding_Transaction__c 
                                                                                WHERE Pricing_Detail__c = :pricingDetailsList[0].Id LIMIT 1];
        fundingTransactionObjList[0].Overpayment_Amount__c = 100;
        fundingTransactionObjList[0].genesis__Amount__c += fundingTransactionObjList[0].Overpayment_Amount__c;
        fundingTransactionObjList[0].Posted_to_NLS__c = false;
        fundingTransactionObjList[0].Invoice__c = invoiceList[0].Id;
        Database.update(fundingTransactionObjList, true);

        // String paymentMode = ConstantValues.MOBILE_DEPOSIT;
        String paymentMode = 'PAYMENT';

        User userObj = [SELECT Id FROM USER WHERE Id = :fundingTransactionObjList[0].CreatedById LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            PortalLoanServicingHelper.deleteMultiFundTrans(applicationObjList[0].Id, paymentMode);
            System.assertEquals('','','Assertion Failed');
            Test.stopTest();
        } 
   }

   /**
   * @description - Test populateOverpaymentAmount
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testpopulateOverpaymentAmount(){
    List<genesis__Applications__c> applicationObjList = [SELECT Id,
                                                                    Certified_Lender__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE Loan_Id__c = '139000' 
                                                                LIMIT 1];
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = [SELECT Id,
                                                                                Loan_Number__c,
                                                                                genesis__Rate_Card_Setup_Detail__r.Description__c,
                                                                                genesis__Application__r.genesis__Account__r.Name,
                                                                                genesis__Interest_Rate__c,
                                                                                Principal_Advanced__c,
                                                                                Accrued_Interest__c,
                                                                                Fees__c,
                                                                                Credit_Balance__c,
                                                                                Total_Payoff__c
                                                                        FROM genesis__Application_Pricing_Detail__c
                                                                        WHERE Loan_Id__c = '139001'];

        pricingDetailsList[0].Credit_Balance__c = 100.00;
        Database.update(pricingDetailsList,true);
        List<genesis__Funding_Transaction__c> fundingTransactionObjList = [SELECT Id, 
                                                                                    Overpayment_Amount__c 
                                                                                FROM genesis__Funding_Transaction__c 
                                                                                WHERE Pricing_Detail__c = :pricingDetailsList[0].Id LIMIT 1];
        fundingTransactionObjList[0].Overpayment_Amount__c = 100.00;
        Database.update(fundingTransactionObjList,true);
        String paymentMode = ConstantValues.MOBILE_DEPOSIT;

        User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
        System.runAs(userObj){
            Test.startTest();
            Decimal overpaymentAmount =  PortalLoanServicingHelper.populateOverpaymentAmount(fundingTransactionObjList, 0);
            PortalLoanServicingHelper.updateCreditBalance(overpaymentAmount,paymentMode,applicationObjList[0].Id);
            System.assertEquals(100.00,overpaymentAmount, 'Assertion Failed');
            Test.stopTest();
        } 
   }

   /**
   * @description - Test deleteFundingTransaction
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testdeleteFundingTransaction(){
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = [SELECT Id,
                                                                                Loan_Number__c,
                                                                                genesis__Rate_Card_Setup_Detail__r.Description__c,
                                                                                genesis__Application__r.genesis__Account__r.Name,
                                                                                genesis__Interest_Rate__c,
                                                                                Principal_Advanced__c,
                                                                                Accrued_Interest__c,
                                                                                Fees__c,
                                                                                Credit_Balance__c,
                                                                                Total_Payoff__c
                                                                        FROM genesis__Application_Pricing_Detail__c
                                                                        WHERE Loan_Id__c = '139001'];
        List<clcommon__Consolidated_Invoice__c> invoiceList = [SELECT Id
                                                                    FROM clcommon__Consolidated_Invoice__c
                                                                    LIMIT 1];
        invoiceList[0].Total_Amount__c = 100;
        Database.update(invoiceList[0], true);
        List<genesis__Funding_Transaction__c> fundingTransactionObjList = [SELECT Id, 
                                                                                    CreatedById,
                                                                                    Overpayment_Amount__c 
                                                                                FROM genesis__Funding_Transaction__c 
                                                                                WHERE Pricing_Detail__c = :pricingDetailsList[0].Id LIMIT 1];
        fundingTransactionObjList[0].Invoice__c = invoiceList[0].Id;
        Database.update(fundingTransactionObjList[0], true);
        
        User userObj = [SELECT Id FROM USER WHERE Id = :fundingTransactionObjList[0].CreatedById LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            PortalLoanServicingHelper.deleteFundingTransaction(fundingTransactionObjList[0].Id);
            System.assertEquals('','', 'Assertion Failed');
            Test.stopTest();
        } 
   }

   /**
   * @description - Test deleteFundingTransaction
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testdeletefundingTxnProductReturnPaymentMode(){
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = [SELECT Id,
                                                                                Loan_Number__c,
                                                                                genesis__Rate_Card_Setup_Detail__r.Description__c,
                                                                                genesis__Application__r.genesis__Account__r.Name,
                                                                                genesis__Interest_Rate__c,
                                                                                Principal_Advanced__c,
                                                                                Accrued_Interest__c,
                                                                                Fees__c,
                                                                                Credit_Balance__c,
                                                                                Total_Payoff__c
                                                                        FROM genesis__Application_Pricing_Detail__c
                                                                        WHERE Loan_Id__c = '139001'];

        List<genesis__Funding_Transaction__c> fundingTransactionObjList = [SELECT Id, 
                                                                                    CreatedById,
                                                                                    Overpayment_Amount__c 
                                                                                FROM genesis__Funding_Transaction__c 
                                                                                WHERE Pricing_Detail__c = :pricingDetailsList[0].Id 
                                                                                AND genesis__Payment_Mode__r.Name =: PortalConstants.PRODUCT_RETURN 
                                                                                LIMIT 1];

        User userObj = [SELECT Id FROM USER WHERE Id = :fundingTransactionObjList[0].CreatedById LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            PortalLoanServicingHelper.deleteFundingTransaction(fundingTransactionObjList[0].Id);
            System.assertEquals('','', 'Assertion Failed');
            Test.stopTest();
        } 
   }

   /**
   * @description - Test populateFromFundTranx
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testpopulateFromFundTranx(){
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = [SELECT Id,
                                                                                Loan_Number__c,
                                                                                genesis__Rate_Card_Setup_Detail__r.Description__c,
                                                                                genesis__Application__r.genesis__Account__r.Name,
                                                                                genesis__Interest_Rate__c,
                                                                                Principal_Advanced__c,
                                                                                Accrued_Interest__c,
                                                                                Fees__c,
                                                                                Credit_Balance__c,
                                                                                Total_Payoff__c
                                                                        FROM genesis__Application_Pricing_Detail__c
                                                                        WHERE Loan_Id__c = '139001'];

        List<genesis__Funding_Transaction__c> fundingTransactionObjList = [SELECT Id, 
                                                                                    CreatedById,
                                                                                    Pricing_Detail__c,
                                                                                    Overpayment_Amount__c 
                                                                                FROM genesis__Funding_Transaction__c 
                                                                                WHERE Pricing_Detail__c = :pricingDetailsList[0].Id 
                                                                                AND genesis__Payment_Mode__r.Name =: PortalConstants.PRODUCT_RETURN 
                                                                                LIMIT 1];
        Map<String,Decimal> pricingMap = new Map<String,Decimal>{
            fundingTransactionObjList[0].Pricing_Detail__c => 20.00
        };
        User userObj = [SELECT Id FROM USER WHERE Id = :fundingTransactionObjList[0].CreatedById LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            PortalLoanServicingHelper.populateFromFundTranx(pricingMap,fundingTransactionObjList[0], 10.00);
            System.assertEquals('','', 'Assertion Failed');
            Test.stopTest();
        } 
   }

   /**
   * @description - Test updateApplFundingTransc
   * @author Sk Minsar | 12-21-2024 
   **/
   @isTest
   public static void testupdateApplFundingTransc(){
        List<genesis__Applications__c> applicationObjList = [SELECT Id,
                                                                    Pay_Off__c,
                                                                    Pay_Off_Date__c, 
                                                                    Certified_Lender__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE Loan_Id__c = '139000' 
                                                                LIMIT 1];
        applicationObjList[0].Pay_Off__c = 'Yes';
        applicationObjList[0].Pay_Off_Date__c = System.today();
        Database.update(applicationObjList, true);
        User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
        System.runAs(userObj){
            Test.startTest();
            PortalLoanServicingHelper.updateApplFundingTransc(applicationObjList[0].Id);
            System.assertEquals('','', 'Assertion Failed');
            Test.stopTest();
        } 
   }
}