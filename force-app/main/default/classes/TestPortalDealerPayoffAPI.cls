/**
 * @description       : Test class for PortalDealerPayoffAPI
 * @author            : Sanjana De
 * @group             : 
 * @last modified on  : 12-16-2024
 * @last modified by  : Sk Minsar
**/
@IsTest
public with sharing class TestPortalDealerPayoffAPI {

	/**
	* @description - Creating test data
	* @author Rahul Gupta | 09-16-2024 
	**/
    @TestSetup
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
		clUser.Username = 'TestPortalDealerPayoffAPI_' + clUser.Username;
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


         // create application
        Map<String,Id> applicationMap = new Map<String,Id>{
            'dealerAccountId' => dealerAccountObj.id,
            'clProductId' => clProductobj.id,
            'clPurposeId' => clPurpose.id,
            'borrowerAccountId' => borrowerAccountObj.id,
            'borrowerContactId' => borrowerContact.id,
            'clAccountId' => clUserAccount.id
        };
         
        genesis__Applications__c applicationObj = TestClassHelper.createCurrCropYearApplication(applicationMap);
        Database.insert(applicationObj,true);

        // create party type
        clcommon__Party_Type__c borrowerPartyType = TestClassHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c certifiedLenderPartyType = TestClassHelper.createPartyType('CERTIFIED LENDER');
        clcommon__Party_Type__c dealerPartyType = TestClassHelper.createPartyType('DEALER');

        Database.insert(new List<clcommon__Party_Type__c>{borrowerPartyType, certifiedLenderPartyType, dealerPartyType},true);


        //Create party
        clcommon__Party__c borrowerPartyObj = TestClassHelper.createParty(new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContact.id,
            'partyTypeId' => borrowerPartyType.id,
            'applicationId' => applicationObj.id
        });
        clcommon__Party__c certifiedLenderParty = TestClassHelper.createParty(new Map<String,Id>{
            'accountId' => clUserAccount .id,
            'contactId' => clUserContact.id,
            'partyTypeId' => certifiedLenderPartyType.id,
            'applicationId' => applicationObj.id
        });
        clcommon__Party__c dealerParty = TestClassHelper.createParty(new Map<String,Id>{
            'accountId' => dealerAccountObj.id,
            'contactId' => null,
            'partyTypeId' => dealerPartyType.id,
            'applicationId' => applicationObj.id
        });

        Database.insert(new List<clcommon__Party__c>{borrowerPartyObj, certifiedLenderParty, dealerParty},true);


        // create rare card and pricing detail
        genesis__Rate_Card_Setup_Header__c ratecardSetupHeader = TestClassHelper.createPrevYearRateCardHeader(borrowerAccountObj);
        Database.insert(ratecardSetupHeader,true);

        //Create rate card setup details
        genesis__Rate_Card_Setup_Detail__c ratecardSetupDetail = TestClassHelper.createRateCardSetupDetailOne(ratecardSetupHeader);
        genesis__Rate_Card_Setup_Detail__c ratecardDetail = TestClassHelper.createRateCardSetupDetailOne(ratecardSetupHeader);
        genesis__Rate_Card_Setup_Detail__c rcardDetail = TestClassHelper.createRateCardSetupDetailOne(ratecardSetupHeader);
        ratecardSetupDetail.genesis__Interest_Rate__c = 7.7;
        ratecardSetupDetail.Participation_Percentage_Dealer__c = 0.2;
        ratecardSetupDetail.Participation_Percentage_Dealer_Subsidy__c = 0;
        ratecardDetail.genesis__Interest_Rate__c = 2.5;
        ratecardDetail.Participation_Percentage_Dealer__c = 0;
        ratecardDetail.Participation_Percentage_Dealer_Subsidy__c = 3;
        rcardDetail.genesis__Interest_Rate__c = 2.5;
        rcardDetail.Participation_Percentage_Dealer__c = 0;
        rcardDetail.Participation_Percentage_Dealer_Subsidy__c = 3;
        Database.insert(new List<genesis__Rate_Card_Setup_Detail__c>{rcardDetail, ratecardDetail, ratecardSetupDetail},true);

        //Create pricing details
        genesis__Application_Pricing_Detail__c applicationPricingDetail = TestClassHelper.createEnabledPricingDetail(applicationObj,ratecardSetupDetail.id);
        genesis__Application_Pricing_Detail__c applicationPriceDetailObj = TestClassHelper.createDisabledPricingDetail(applicationObj,ratecardDetail.id);
        genesis__Application_Pricing_Detail__c appPriceDetailObj = TestClassHelper.createEnabledPricingDetail(applicationObj,rcardDetail.id);
        applicationPricingDetail.Loan_Number__c = applicationObj.genesis__Loan_Number__c + '-A';
        applicationPricingDetail.genesis__Interest_Rate__c = 7.7;
        applicationPricingDetail.Principal_Advanced__c = 15000;
        applicationPricingDetail.Accrued_Interest__c = 1000;
        applicationPricingDetail.Fees__c = 200;
        applicationPriceDetailObj.Loan_Number__c = applicationObj.genesis__Loan_Number__c + '-A';
        appPriceDetailObj.Loan_Number__c = applicationObj.genesis__Loan_Number__c + '-B';
        appPriceDetailObj.genesis__Interest_Rate__c = 2.5;
        appPriceDetailObj.Principal_Advanced__c = 7000;
        appPriceDetailObj.Accrued_Interest__c = 1000;
        appPriceDetailObj.Fees__c = 50;
        Database.insert(new List<genesis__Application_Pricing_Detail__c>{applicationPricingDetail, applicationPriceDetailObj, appPriceDetailObj},true);  

        //Create payment mode
        Database.upsert(TestClassHelper.createPaymentMode().values(), true);
    }

    /**
    * @description 
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
    * @description - This method return the parameter map which is used in invoking the class
    * @author Sk Minsar | 12-16-2024 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getParamMap(){
         List<genesis__Applications__c> applicationList = [SELECT Id 
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
        return new Map<String, Object>{
            'applicationList' => applicationList,
            'bankAccountList' => bankAccountList,
            'pricingsList' => pricingsList
        };
    }
    
    /**
    * @description 
    * @author Rahul Gupta | 09-16-2024 
    **/
    @IsTest
    public static void testPaymentWithEnabledPricingDetailAndPayoffFalse() {
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> application = (List<genesis__Applications__c>)paramMap.get('applicationList');
        List<clcommon__Bank_Account__c> bankAccount = (List<clcommon__Bank_Account__c>)paramMap.get('bankAccountList');
        List<genesis__Application_Pricing_Detail__c> pricings = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('pricingsList');
        if(pricings.size()==2){
            pricings[0].Principal_To_Be_Paid__c = 0;
            pricings[0].Interest_To_Be_Paid__c = 0;
            pricings[0].Fees_To_Be_Paid__c = 200;
            pricings[0].Payment__c = 200;
            pricings[1].Principal_To_Be_Paid__c = 0;
            pricings[1].Interest_To_Be_Paid__c = 0;
            pricings[1].Fees_To_Be_Paid__c = 0;
            pricings[1].Payment__c = 0;
        }
        String pricingString = JSON.serialize(pricings);
        Map<String, Object> request = new Map<String, Object>();
        request.put('applicationId', application[0].Id);
        request.put('bankDetails', bankAccount[0].Id);
        request.put('paymentOption', 'makePayment');
        request.put('applicationId', application[0].Id);
        request.put('paymentAmount', 200);
        request.put('payoffDetails', pricingString);
        request.put('isPayOff', 'false');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PortalDealerPayoffAPI api = new PortalDealerPayoffAPI();
            clcommon.Response response = api.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Rahul Gupta | 09-16-2024 
    **/
    @IsTest
    public static void testMobileDepositWithEnabledPricingDetailAndPayoffFalse() {
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> application = (List<genesis__Applications__c>)paramMap.get('applicationList');
        List<clcommon__Bank_Account__c> bankAccount = (List<clcommon__Bank_Account__c>)paramMap.get('bankAccountList');
        List<genesis__Application_Pricing_Detail__c> pricings = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('pricingsList');
        if(pricings.size()==2){
            pricings[0].Principal_To_Be_Paid__c = 0;
            pricings[0].Interest_To_Be_Paid__c = 0;
            pricings[0].Fees_To_Be_Paid__c = 200;
            pricings[0].Payment__c = 200;
            pricings[1].Principal_To_Be_Paid__c = 0;
            pricings[1].Interest_To_Be_Paid__c = 0;
            pricings[1].Fees_To_Be_Paid__c = 0;
            pricings[1].Payment__c = 0;
        }
        String pricingString = JSON.serialize(pricings);
        Map<String, Object> request = new Map<String, Object>();
        request.put('applicationId', application[0].Id);
        request.put('bankDetails', bankAccount[0].Id);
        request.put('paymentOption', 'mobileDeposit');
        request.put('applicationId', application[0].Id);
        request.put('paymentAmount', 200);
        request.put('payoffDetails', pricingString);
        request.put('isPayOff', 'false');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PortalDealerPayoffAPI api = new PortalDealerPayoffAPI();
            clcommon.Response response = api.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Rahul Gupta | 09-16-2024 
    **/
    @IsTest
    public static void testMobileDepositWithEnabledPricingDetailAndPayoffTrue() {
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> application = (List<genesis__Applications__c>)paramMap.get('applicationList');
        List<clcommon__Bank_Account__c> bankAccount = (List<clcommon__Bank_Account__c>)paramMap.get('bankAccountList');
        List<genesis__Application_Pricing_Detail__c> pricings = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('pricingsList');
        if(pricings.size()==2){
            pricings[0].Principal_To_Be_Paid__c = 15000;
            pricings[0].Interest_To_Be_Paid__c = 1000;
            pricings[0].Fees_To_Be_Paid__c = 200;
            pricings[0].Payment__c = 16200;
            pricings[1].Principal_To_Be_Paid__c = 7000;
            pricings[1].Interest_To_Be_Paid__c = 1000;
            pricings[1].Fees_To_Be_Paid__c = 50;
            pricings[1].Payment__c = 8050;
        }
        String pricingString = JSON.serialize(pricings);
        Map<String, Object> request = new Map<String, Object>();
        request.put('applicationId', application[0].Id);
        request.put('bankDetails', bankAccount[0].Id);
        request.put('paymentOption', 'mobileDeposit');
        request.put('applicationId', application[0].Id);
        request.put('paymentAmount', 24250);
        request.put('payoffDetails', pricingString);
        request.put('isPayOff', 'True');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PortalDealerPayoffAPI api = new PortalDealerPayoffAPI();
            clcommon.Response response = api.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
        

    }

    /**
    * @description 
    * @author Rahul Gupta | 09-16-2024 
    **/
    @IsTest
    public static void testMobileDepositWithEnabledPricingDetail() {
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> application = [SELECT Id,
                                                             Past_Due_Amount__c
                                                      FROM genesis__Applications__c 
                                                      WHERE genesis__Loan_Number__c = '300023456'];
        Database.upsert(application, true);
        List<clcommon__Bank_Account__c> bankAccount = (List<clcommon__Bank_Account__c>)paramMap.get('bankAccountList');
        List<genesis__Application_Pricing_Detail__c> pricings = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('pricingsList');
        if(pricings.size()==2){
            pricings[0].Principal_To_Be_Paid__c = 15000;
            pricings[0].Interest_To_Be_Paid__c = 1000;
            pricings[0].Fees_To_Be_Paid__c = 200;
            pricings[0].Payment__c = 16200;
            pricings[1].Principal_To_Be_Paid__c = 7000;
            pricings[1].Interest_To_Be_Paid__c = 1000;
            pricings[1].Fees_To_Be_Paid__c = 50;
            pricings[1].Payment__c = 8050;
        }
        String pricingString = JSON.serialize(pricings);
        Map<String, Object> request = new Map<String, Object>();
        request.put('applicationId', application[0].Id);
        request.put('bankDetails', bankAccount[0].Id);
        request.put('paymentOption', 'mobileDeposit');
        request.put('applicationId', application[0].Id);
        request.put('paymentAmount', 24250);
        request.put('payoffDetails', pricingString);
        request.put('isPayOff', 'True');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PortalDealerPayoffAPI api = new PortalDealerPayoffAPI();
            clcommon.Response response = api.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Rahul Gupta | 09-16-2024 
    **/
    @IsTest
    public static void testPaymentWithEnabledPricingDetailExceedPaymentException() {
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> application = (List<genesis__Applications__c>)paramMap.get('applicationList');
        List<clcommon__Bank_Account__c> bankAccount = (List<clcommon__Bank_Account__c>)paramMap.get('bankAccountList');
        List<genesis__Application_Pricing_Detail__c> pricings = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('pricingsList');
        if(pricings.size()==2){
            pricings[0].Principal_To_Be_Paid__c = 0;
            pricings[0].Interest_To_Be_Paid__c = 0;
            pricings[0].Fees_To_Be_Paid__c = 300;
            pricings[0].Payment__c = 300;
            pricings[1].Principal_To_Be_Paid__c = 0;
            pricings[1].Interest_To_Be_Paid__c = 0;
            pricings[1].Fees_To_Be_Paid__c = 0;
            pricings[1].Payment__c = 0;
        }
        String pricingString = JSON.serialize(pricings);
        Map<String, Object> request = new Map<String, Object>();
        request.put('applicationId', application[0].Id);
        request.put('bankDetails', bankAccount[0].Id);
        request.put('paymentOption', 'makePayment');
        request.put('applicationId', application[0].Id);
        request.put('paymentAmount', 300);
        request.put('payoffDetails', pricingString);
        request.put('isPayOff', 'false');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PortalDealerPayoffAPI api = new PortalDealerPayoffAPI();
            clcommon.Response response = api.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Rahul Gupta | 09-16-2024 
    **/
    @IsTest
    public static void testPaymentWithEnabledPricingDetailException() {
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> application = (List<genesis__Applications__c>)paramMap.get('applicationList');
        List<clcommon__Bank_Account__c> bankAccount = (List<clcommon__Bank_Account__c>)paramMap.get('bankAccountList');
        List<genesis__Application_Pricing_Detail__c> pricings = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('pricingsList');
        if(pricings.size()==2){
            pricings[0].Principal_To_Be_Paid__c = 0;
            pricings[0].Interest_To_Be_Paid__c = 0;
            pricings[0].Fees_To_Be_Paid__c = 300;
            pricings[0].Payment__c = 300;
            pricings[1].Principal_To_Be_Paid__c = 0;
            pricings[1].Interest_To_Be_Paid__c = 0;
            pricings[1].Fees_To_Be_Paid__c = 0;
            pricings[1].Payment__c = 0;
        }
        String pricingString = JSON.serialize(pricings);
        Map<String, Object> request = new Map<String, Object>();
        request.put('applicationId', application[0].Id);
        request.put('bankDetails', bankAccount[0].Id);
        request.put('paymentOption', 'makePayment');
        request.put('applicationId', application[0].Id);
        request.put('paymentAmount', 300);
        request.put('payoffDetails', pricingString);
        request.put('isPayOff', false);
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PortalDealerPayoffAPI api = new PortalDealerPayoffAPI();
            clcommon.Response response = api.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test with sending Email to CL
    * @author Rahul Gupta | 09-16-2024 
    **/
    @IsTest
    public static void testSendEmailToCL() {
        List<Account> objAccount = [SELECT Id from Account];
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> application = (List<genesis__Applications__c>)paramMap.get('applicationList');
        application[0].genesis__Account__c = objAccount[0].Id;
        application[0].genesis__Status__c = 'ACTIVE';            
        Database.upsert(application, true);
        List<clcommon__Bank_Account__c> bankAccount = (List<clcommon__Bank_Account__c>)paramMap.get('bankAccountList');
        List<genesis__Application_Pricing_Detail__c> pricings = [SELECT id, 
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
        if(pricings.size()==2){
            pricings[0].Principal_To_Be_Paid__c = 0;
            pricings[0].Interest_To_Be_Paid__c = 0;
            pricings[0].Fees_To_Be_Paid__c = 200;
            pricings[0].Payment__c = 200;
            pricings[1].Principal_To_Be_Paid__c = 0;
            pricings[1].Interest_To_Be_Paid__c = 0;
            pricings[1].Fees_To_Be_Paid__c = 0;
            pricings[1].Payment__c = 0;
        }
        String pricingString = JSON.serialize(pricings);
        Map<String, Object> request = new Map<String, Object>();
        request.put('applicationId', application[0].Id);
        request.put('bankDetails', bankAccount[0].Id);
        request.put('paymentOption', 'mobileDeposit');
        request.put('applicationId', application[0].Id);
        request.put('paymentAmount', 200);
        request.put('payoffDetails', pricingString);
        request.put('isPayOff', 'false');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PortalDealerPayoffAPI api = new PortalDealerPayoffAPI();
            clcommon.Response response = api.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
            Test.stopTest();
        }   
        List<clcommon__Log__c> logs = [SELECT Id FROM clcommon__Log__c WHERE Name = 'PortalEmailToCLFail'];
        System.assertEquals(0, logs.size(),'Assertion Failed');
    }

    
    /**
    * @description - This method checks the Total principal amount
    * @author Sk Minsar | 12-16-2024 
    **/
    @IsTest
    public static void testInvoicePrincipalAmount() {
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> application = (List<genesis__Applications__c>)paramMap.get('applicationList');
        List<clcommon__Bank_Account__c> bankAccount = (List<clcommon__Bank_Account__c>)paramMap.get('bankAccountList');
        List<genesis__Application_Pricing_Detail__c> pricings = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('pricingsList');
        if(pricings.size()==2){
            pricings[0].Principal_To_Be_Paid__c = 200;
            pricings[0].Interest_To_Be_Paid__c = 0;
            pricings[0].Fees_To_Be_Paid__c = 0;
            pricings[0].Payment__c = 200;
            pricings[1].Principal_To_Be_Paid__c = 0;
            pricings[1].Interest_To_Be_Paid__c = 0;
            pricings[1].Fees_To_Be_Paid__c = 0;
            pricings[1].Payment__c = 0;
        }
        String pricingString = JSON.serialize(pricings);
        Map<String, Object> request = new Map<String, Object>();
        request.put('applicationId', application[0].Id);
        request.put('bankDetails', bankAccount[0].Id);
        request.put('paymentOption', 'makePayment');
        request.put('applicationId', application[0].Id);
        request.put('paymentAmount', 200);
        request.put('payoffDetails', pricingString);
        request.put('isPayOff', 'false');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PortalDealerPayoffAPI api = new PortalDealerPayoffAPI();
            api.invokeAction('', new List<String>(), request);
            List<clcommon__Consolidated_Invoice__c> responseInvoiceList = [SELECT Id,
                                                                                    Total_Principal__c,
                                                                                    Total_Interest__c,
                                                                                    Total_Fees__c,
                                                                                    Total_Amount__c,
                                                                                    Payment_Mode__r.Name
                                                                            FROM clcommon__Consolidated_Invoice__c
                                                                            LIMIT 1];
            System.assertEquals(pricings[0].Payment__c, responseInvoiceList[0].Total_Principal__c, 'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description - This method checks the Total Interest amount
    * @author Sk Minsar | 12-16-2024 
    **/
    @IsTest
    public static void testInvoiceInterestAmount() {
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> application = (List<genesis__Applications__c>)paramMap.get('applicationList');
        List<clcommon__Bank_Account__c> bankAccount = (List<clcommon__Bank_Account__c>)paramMap.get('bankAccountList');
        List<genesis__Application_Pricing_Detail__c> pricings = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('pricingsList');
        if(pricings.size()==2){
            pricings[0].Principal_To_Be_Paid__c = 0;
            pricings[0].Interest_To_Be_Paid__c = 200;
            pricings[0].Fees_To_Be_Paid__c = 0;
            pricings[0].Payment__c = 200;
            pricings[1].Principal_To_Be_Paid__c = 0;
            pricings[1].Interest_To_Be_Paid__c = 0;
            pricings[1].Fees_To_Be_Paid__c = 0;
            pricings[1].Payment__c = 0;
        }
        String pricingString = JSON.serialize(pricings);
        Map<String, Object> request = new Map<String, Object>();
        request.put('applicationId', application[0].Id);
        request.put('bankDetails', bankAccount[0].Id);
        request.put('paymentOption', 'makePayment');
        request.put('applicationId', application[0].Id);
        request.put('paymentAmount', 200);
        request.put('payoffDetails', pricingString);
        request.put('isPayOff', 'false');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PortalDealerPayoffAPI api = new PortalDealerPayoffAPI();
            api.invokeAction('', new List<String>(), request);
            List<clcommon__Consolidated_Invoice__c> responseInvoiceList = [SELECT Id,
                                                                                    Total_Principal__c,
                                                                                    Total_Interest__c,
                                                                                    Total_Fees__c,
                                                                                    Total_Amount__c,
                                                                                    Payment_Mode__r.Name
                                                                            FROM clcommon__Consolidated_Invoice__c
                                                                            LIMIT 1];
            System.assertEquals(pricings[0].Interest_To_Be_Paid__c, responseInvoiceList[0].Total_Interest__c, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description - This method checks the Total Fees amount
    * @author Sk Minsar | 12-16-2024 
    **/
    @IsTest
    public static void testInvoiceFeesAmount() {
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> application = (List<genesis__Applications__c>)paramMap.get('applicationList');
        List<clcommon__Bank_Account__c> bankAccount = (List<clcommon__Bank_Account__c>)paramMap.get('bankAccountList');
        List<genesis__Application_Pricing_Detail__c> pricings = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('pricingsList');
        if(pricings.size()==2){
            pricings[0].Principal_To_Be_Paid__c = 0;
            pricings[0].Interest_To_Be_Paid__c = 0;
            pricings[0].Fees_To_Be_Paid__c = 200;
            pricings[0].Payment__c = 200;
            pricings[1].Principal_To_Be_Paid__c = 0;
            pricings[1].Interest_To_Be_Paid__c = 0;
            pricings[1].Fees_To_Be_Paid__c = 0;
            pricings[1].Payment__c = 0;
        }
        String pricingString = JSON.serialize(pricings);
        Map<String, Object> request = new Map<String, Object>();
        request.put('applicationId', application[0].Id);
        request.put('bankDetails', bankAccount[0].Id);
        request.put('paymentOption', 'makePayment');
        request.put('applicationId', application[0].Id);
        request.put('paymentAmount', 200);
        request.put('payoffDetails', pricingString);
        request.put('isPayOff', 'false');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PortalDealerPayoffAPI api = new PortalDealerPayoffAPI();
            api.invokeAction('', new List<String>(), request);
            List<clcommon__Consolidated_Invoice__c> responseInvoiceList = [SELECT Id,
                                                                                    Total_Principal__c,
                                                                                    Total_Interest__c,
                                                                                    Total_Fees__c,
                                                                                    Total_Amount__c,
                                                                                    Payment_Mode__r.Name
                                                                            FROM clcommon__Consolidated_Invoice__c
                                                                            LIMIT 1];
            System.assertEquals(pricings[0].Fees_To_Be_Paid__c, responseInvoiceList[0].Total_Fees__c, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description - This method checks the Total principal amount
    * @author Sk Minsar | 12-16-2024 
    **/
    @IsTest
    public static void testInvoiceTotalAmount() {
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> application = (List<genesis__Applications__c>)paramMap.get('applicationList');
        List<clcommon__Bank_Account__c> bankAccount = (List<clcommon__Bank_Account__c>)paramMap.get('bankAccountList');
        List<genesis__Application_Pricing_Detail__c> pricings = (List<genesis__Application_Pricing_Detail__c>)paramMap.get('pricingsList');
        if(pricings.size()==2){
            pricings[0].Principal_To_Be_Paid__c = 0;
            pricings[0].Interest_To_Be_Paid__c = 0;
            pricings[0].Fees_To_Be_Paid__c = 200;
            pricings[0].Payment__c = 200;
            pricings[1].Principal_To_Be_Paid__c = 0;
            pricings[1].Interest_To_Be_Paid__c = 0;
            pricings[1].Fees_To_Be_Paid__c = 0;
            pricings[1].Payment__c = 0;
        }
        String pricingString = JSON.serialize(pricings);
        Map<String, Object> request = new Map<String, Object>();
        request.put('applicationId', application[0].Id);
        request.put('bankDetails', bankAccount[0].Id);
        request.put('paymentOption', 'makePayment');
        request.put('applicationId', application[0].Id);
        request.put('paymentAmount', 200);
        request.put('payoffDetails', pricingString);
        request.put('isPayOff', 'false');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PortalDealerPayoffAPI api = new PortalDealerPayoffAPI();
            api.invokeAction('', new List<String>(), request);
            List<clcommon__Consolidated_Invoice__c> responseInvoiceList = [SELECT Id,
                                                                                    Total_Principal__c,
                                                                                    Total_Interest__c,
                                                                                    Total_Fees__c,
                                                                                    Total_Amount__c,
                                                                                    Payment_Mode__r.Name
                                                                            FROM clcommon__Consolidated_Invoice__c
                                                                            LIMIT 1];
            System.assertEquals(pricings[0].Fees_To_Be_Paid__c, responseInvoiceList[0].Total_Amount__c, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description - This method checks the Payment mode of the invoice
    * @author Sk Minsar | 12-16-2024 
    **/
    @IsTest
    public static void testInvoicePaymentModeAmount() {
        Map<String, Object> paramMap = getParamMap();
        List<genesis__Applications__c> application = (List<genesis__Applications__c>)paramMap.get('applicationList');
        List<clcommon__Bank_Account__c> bankAccount = (List<clcommon__Bank_Account__c>)paramMap.get('bankAccountList');
        List<genesis__Application_Pricing_Detail__c> pricings = [SELECT id, 
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
        if(pricings.size()==2){
            pricings[0].Principal_To_Be_Paid__c = 0;
            pricings[0].Interest_To_Be_Paid__c = 0;
            pricings[0].Fees_To_Be_Paid__c = 200;
            pricings[0].Payment__c = 200;
            pricings[1].Principal_To_Be_Paid__c = 0;
            pricings[1].Interest_To_Be_Paid__c = 0;
            pricings[1].Fees_To_Be_Paid__c = 0;
            pricings[1].Payment__c = 0;
        }
        String pricingString = JSON.serialize(pricings);
        Map<String, Object> request = new Map<String, Object>();
        request.put('applicationId', application[0].Id);
        request.put('bankDetails', bankAccount[0].Id);
        request.put('paymentOption', 'makePayment');
        request.put('applicationId', application[0].Id);
        request.put('paymentAmount', 200);
        request.put('payoffDetails', pricingString);
        request.put('isPayOff', 'false');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PortalDealerPayoffAPI api = new PortalDealerPayoffAPI();
            api.invokeAction('', new List<String>(), request);
            List<clcommon__Consolidated_Invoice__c> responseInvoiceList = [SELECT Id,
                                                                                    Total_Principal__c,
                                                                                    Total_Interest__c,
                                                                                    Total_Fees__c,
                                                                                    Total_Amount__c,
                                                                                    Payment_Mode__c,
                                                                                    Payment_Mode__r.Name
                                                                            FROM clcommon__Consolidated_Invoice__c
                                                                            LIMIT 1];
            System.assertEquals(null, responseInvoiceList[0].Payment_Mode__r.Name, 'Assertion Failed');
            Test.stopTest();
        }
    }
}