/**
 * @description       : Test Class for PortalExportTransactionAPI
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 03-06-2023
 * @last modified by  : Ayush Kumar Singh
**/
@isTest
public with sharing class PortalExportAnnualAmountPaidAPITest {
    
    @TestSetup
    static void makeData() {

        // create business information
        genesis__Business_Information__c dealerBusinessInfoObj = TestClassHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj,true);

        // create dealer account
        Account dealerAccountObj = TestClassHelper.createDealerAccount(dealerBusinessInfoObj.id);
        Database.insert(dealerAccountObj,true);
                    
        // creating user for certified lender

        Account clUserAccount = TestClassHelper.createCLAccount(dealerBusinessInfoObj.id, dealerAccountObj.id);
        Database.insert(clUserAccount,true);

        Contact clUserContact = TestClassHelper.createCLContact(clUserAccount.id);
        Database.insert(clUserContact, true);

        User clUser = TestClassHelper.createCLUser(clUserContact.id);
        Database.insert(clUser, true);

        clcommon__Reciprocal_Role__c role  = TestClassHelper.createReciprocalRole('Certified Lender');
        Database.insert(role,true);

        clcommon__Relationship__c relationship = TestClassHelper.createCLDealerRelationship(role,dealerAccountObj.id,clUserAccount.id);
        Database.insert(relationship,true);

        // create legal entity

        clcommon__Legal_Entity__c legalEntity = TestClassHelper.createLegalEntity('Individual(s) - Sole Proprietorship');
        Database.insert(legalEntity,true);

        // create borrower
        genesis__Business_Information__c businessInfoObj = TestClassHelper.createBusinessInfoForBorrower();
        Database.insert(businessInfoObj, true);

        Account borrowerAccountObj = TestClassHelper.createSolePropAccount(legalEntity,businessInfoObj.id);
        Database.insert(borrowerAccountObj,true);    

        Contact borrowerContact = TestClassHelper.createBorrowerContact(borrowerAccountObj.id);
        Database.insert(borrowerContact, true);

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

        // create borrower party type
        clcommon__Party_Type__c borrowerPartyType = TestClassHelper.createPartyType('BORROWER');
        Database.insert(borrowerPartyType,true);

        // create certified lender party
        
        clcommon__Party_Type__c certifiedLenderPartyType = TestClassHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(certifiedLenderPartyType,true);

        // create certified lender party
        clcommon__Party_Type__c dealerPartyType = TestClassHelper.createPartyType('DEALER');
        Database.insert(dealerPartyType,true);

        // create borrower party
        Map<String,Id> borrowerPartyMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContact.id,
            'partyTypeId' => borrowerPartyType.id,
            'applicationId' => applicationObj.id
        };

        clcommon__Party__c borrowerPartyObj = TestClassHelper.createParty(borrowerPartyMap);
        Database.insert(borrowerPartyObj,true);

        // create certified lender party


        Map<String,Id> clPartymap = new Map<String,Id>{
            'accountId' => clUserAccount .id,
            'contactId' => clUserContact.id,
            'partyTypeId' => certifiedLenderPartyType.id,
            'applicationId' => applicationObj.id
        };

        clcommon__Party__c certifiedLenderParty = TestClassHelper.createParty(clPartymap);
        Database.insert(certifiedLenderParty,true);
        // create dealer party

        Map<String,Id> dealerPartymap = new Map<String,Id>{
            'accountId' => dealerAccountObj.id,
            'contactId' => null,
            'partyTypeId' => dealerPartyType.id,
            'applicationId' => applicationObj.id
        };

        clcommon__Party__c dealerParty = TestClassHelper.createParty(dealerPartymap);
        Database.insert(dealerParty,true);


        // create rare card and pricing detail

        genesis__Rate_Card_Setup_Header__c ratecardSetupHeader = TestClassHelper.createPrevYearRateCardHeader(borrowerAccountObj);
        Database.insert(ratecardSetupHeader,true);

        genesis__Rate_Card_Setup_Detail__c ratecardSetupDetail = TestClassHelper.createRateCardSetupDetailOne(ratecardSetupHeader);
        ratecardSetupDetail.genesis__Interest_Rate__c = 7.7;
        ratecardSetupDetail.Participation_Percentage_Dealer__c = 0.2;
        ratecardSetupDetail.Participation_Percentage_Dealer_Subsidy__c = 0;
        Database.insert(ratecardSetupDetail,true);

       
        genesis__Application_Pricing_Detail__c applicationPricingDetail = TestClassHelper.createEnabledPricingDetail(applicationObj,ratecardSetupDetail.id);
        applicationPricingDetail.Loan_Number__c = applicationObj.genesis__Loan_Number__c + '-A';
        applicationPricingDetail.genesis__Interest_Rate__c = 7.7;
        applicationPricingDetail.Principal_Advanced__c = 15000;
        applicationPricingDetail.Accrued_Interest__c = 1000;
        applicationPricingDetail.Fees__c = 200;
        Database.insert(applicationPricingDetail,true);  

        genesis__Rate_Card_Setup_Detail__c ratecardDetail = TestClassHelper.createRateCardSetupDetailOne(ratecardSetupHeader);
        ratecardDetail.genesis__Interest_Rate__c = 2.5;
        ratecardDetail.Participation_Percentage_Dealer__c = 0;
        ratecardDetail.Participation_Percentage_Dealer_Subsidy__c = 3;
        Database.insert(ratecardDetail,true);


        genesis__Application_Pricing_Detail__c applicationPriceDetailObj = TestClassHelper.createDisabledPricingDetail(applicationObj,ratecardDetail.id);
        applicationPriceDetailObj.Loan_Number__c = applicationObj.genesis__Loan_Number__c + '-A';
        
        Database.insert(applicationPriceDetailObj,true);

        genesis__Rate_Card_Setup_Detail__c rcardDetail = TestClassHelper.createRateCardSetupDetailOne(ratecardSetupHeader);
        rcardDetail.genesis__Interest_Rate__c = 2.5;
        rcardDetail.Participation_Percentage_Dealer__c = 0;
        rcardDetail.Participation_Percentage_Dealer_Subsidy__c = 3;
        Database.insert(rcardDetail,true);


        genesis__Application_Pricing_Detail__c appPriceDetailObj = TestClassHelper.createEnabledPricingDetail(applicationObj,rcardDetail.id);
        appPriceDetailObj.Loan_Number__c = applicationObj.genesis__Loan_Number__c + '-B';
        appPriceDetailObj.genesis__Interest_Rate__c = 2.5;
        appPriceDetailObj.Principal_Advanced__c = 7000;
        appPriceDetailObj.Accrued_Interest__c = 1000;
        appPriceDetailObj.Fees__c = 50;
        Database.insert(appPriceDetailObj,true);
    
        // create payment mode
        Map<String, clcommon__Payment_Mode__c> paymentModeMap  = TestClassHelper.createPaymentMode();

        clcommon__Payment_Mode__c mobiledepositPaymentMode = paymentModeMap.get('MOBILE DEPOSIT');
        Database.insert (mobiledepositPaymentMode,true);

        clcommon__Payment_Mode__c paymentTypePaymentMode = paymentModeMap.get('PAYMENT');
        Database.insert(paymentTypePaymentMode,true); 
    }

    /**
     * @description 
     * @return  `User`
     */
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
    @isTest
    public static void testExportForCSV() {
        Object childRequest = '[{"id":"dummy_store_id","calendar_year":"2024","child_loan_number":"344522001","child_total_interest_paid":0.01,"child_total_interest_accrued":0.19}]';
        Object parentRequest = '[{"id":"dummy_store_id","parent_calendar_year":"2024","parent_loan_number":"344522001","parent_total_interest_paid":0.01,"parent_total_interest_accrued":0.19}]';
        Object exp = 'csv';
        genesis__Applications__c application = [Select Id From genesis__Applications__c LIMIT 1];
        String applicationId = application.id;
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('applicationId', applicationId);
        requestMap.put('exportType', exp);
        requestMap.put('childLoanList', childRequest);
        requestMap.put('parentLoanList', parentRequest);

        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();

            // Calling  the API
            PortalExportAnnualAmountPaidAPI saveApi = new PortalExportAnnualAmountPaidAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);

            System.assertEquals(clcommon.Constants.SUCCESS, resp.status,'Assertion Failed'); 

            Test.stopTest();
        }
    }
     
    @isTest
    public static void testExportForPDF() {
        Object childRequest = '[{"id":"dummy_store_id","calendar_year":"2024","child_loan_number":"344522001","child_total_interest_paid":0.01,"child_total_interest_accrued":0.19}]';
        Object parentRequest = '[{"id":"dummy_store_id","parent_calendar_year":"2024","parent_loan_number":"344522001","parent_total_interest_paid":0.01,"parent_total_interest_accrued":0.19}]';
        Object exp = 'pdf';
        genesis__Applications__c application = [Select Id From genesis__Applications__c LIMIT 1];
        String applicationId = application.id;
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('applicationId', applicationId);
        requestMap.put('exportType', exp);
        requestMap.put('childLoanList', childRequest);
        requestMap.put('parentLoanList', parentRequest);

        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();

            // Calling  the API
            PortalExportAnnualAmountPaidAPI saveApi = new PortalExportAnnualAmountPaidAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);

            System.assertEquals(clcommon.Constants.SUCCESS, resp.status,'Assertion Failed'); 

            Test.stopTest();
        }
    }
}