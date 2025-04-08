/**
 * @description       : Test class for CreateReportLoanRecordsBatch and CreateReportLoanRecordsSchedule
 * @author            : Simran
 * @group             : 
 * @last modified on  : 08-16-2024
 * @last modified by  :  Pritam Roy
**/
@isTest
global without sharing class TestCreateReportLoanRecordsBatch {

    @TestSetup
    static void setup(){
        //Creating Product
        clcommon__CL_Product__c objProduct = LoanServicingTestHelper.createLoanProduct();
        Database.insert(objProduct, true);

        //Creating Business Information
        genesis__Business_Information__c businessInfoDealer = LoanServicingTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoDealer, true);

        //Creating the dealer parent account
        Account dealerCompany = LoanServicingTestHelper.createDealerAccount(businessInfoDealer.Id);
        Database.insert(dealerCompany, true);

        //Creating the CL Account
        Account dealerUserAccount = LoanServicingTestHelper.createCLAccount(businessInfoDealer.Id,dealerCompany.id);
        Database.insert(dealerUserAccount,true);

        //Creating the CL Contact
        Contact dealerContact = LoanServicingTestHelper.createCLContact(dealerUserAccount.Id);
        Database.insert(dealerContact,true);
        
        //Creating a test user
        User testUser = LoanServicingTestHelper.createCLUser(dealerContact.Id);
        Database.insert(testUser,true);
        
        //Creating Rate Card Setup Header
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerCompany);
        Database.insert(objRateCardHeader,true);

        //Creating Product Rate Card Association
        genesis__Product_Rate_Card_Association__c rateProduct = ApplicationOriginationTestHelper.createRateToProductAssociation(objProduct,objRateCardHeader);
        Database.insert(rateProduct, true);

        //Additional Determing Factor for Program
        genesis__Additional_Determining_Factor__c additionalFactor = ApplicationOriginationTestHelper.createAdditionalFactorForProgram(objRateCardHeader);
        Database.insert(additionalFactor, true);

        //Additional Factor for Dealer
        genesis__Additional_Determining_Factor__c additionalFactorDealer = ApplicationOriginationTestHelper.createAdditionalFactorForDealer(objRateCardHeader);
        Database.insert(additionalFactorDealer, true);

        //Creating Rate Card Setup Detail
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = ApplicationOriginationTestHelper.createNewRateCardSetupDetail(objRateCardHeader);
        Database.insert(objRateCardDetail, true);

        //Creating Rate Card Setup Detail
        genesis__Rate_Card_Setup_Detail__c objSecondRateCardDetail = ApplicationOriginationTestHelper.createNewRateCardSetupDetail(objRateCardHeader);
        Database.insert(objSecondRateCardDetail, true);

        //Creating DBA Account
        Account accountObj = ApplicationOriginationTestHelper.createNewDBAccount(businessInfoDealer);
        Database.insert(accountObj, true);

        //Creating Application with Flex Rate
        genesis__Applications__c applicationObjFlex = ApplicationOriginationTestHelper.createApplicationForFlex(objProduct,accountObj);
        Database.insert(applicationObjFlex, true);

        //Create Pricing Detail A
        genesis__Application_Pricing_Detail__c objPricingDetail = LoanServicingTestHelper.createEnabledPricingDetail(applicationObjFlex,objRateCardDetail.id);
        Database.insert(objPricingDetail, true);

        //Create Pricing Detail B
        genesis__Application_Pricing_Detail__c objSecondPricingDetail = LoanServicingTestHelper.createEnabledPricingDetail(applicationObjFlex,objSecondRateCardDetail.id);
        Database.insert(objSecondPricingDetail, true);

        //Fee Payment A
        genesis__Application_Fee_Payment__c objFeePayment = LoanServicingTestHelper.createApplicationFeePayment(applicationObjFlex.id,objPricingDetail.id);
        Database.insert(objFeePayment,true);
    }
    /**
    * @description : Create Loan Records Success
    * @author  Pritam Roy | 08-16-2024 
    **/
    @isTest
    public static void testCreateLoanRecordsSuccess() {
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c objApplication = [SELECT Id,Pricing_Count__c FROM genesis__Applications__c LIMIT 1];
        genesis__Application_Fee_Payment__c objFeePayment = [SELECT Id,Record_Type__c FROM genesis__Application_Fee_Payment__c LIMIT 1];
        objFeePayment.Record_Type__c = 'ACTIVE LOAN DAILY';
        objFeePayment.External_Id__c='participant-'+objApplication.Id+'-2022-202202';
        Database.update(objFeePayment,true);

       
        Test.startTest();
        // String batchType='vgsj';
        System.runAs(objAdmin){
            CreateReportLoanRecordsBatch objBatch = new CreateReportLoanRecordsBatch();
            Database.executeBatch(objBatch, 50);
            genesis__Application_Fee_Payment__c objFeePaymentCheck = [SELECT Id,External_Id__c FROM genesis__Application_Fee_Payment__c WHERE External_Id__c != NULL ];
            System.assertEquals(true, objFeePaymentCheck!=NULL,'Exception');
        }
        Test.stopTest();

    }

    /**
    * @description : Create Loan Records Exception
    * @author  Pritam Roy | 08-16-2024 
    **/
    @isTest
    public static void testLoanRecordsException() {
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Application_Fee_Payment__c objFeePayment = [SELECT Id,Record_Type__c FROM genesis__Application_Fee_Payment__c LIMIT 1];
        objFeePayment.Record_Type__c = 'ACTIVE LOAN DAILY';
        objFeePayment.External_Id__c = NULL;
        Database.update(objFeePayment,true);

       
        Test.startTest();
        // String batchType='vgsj';
        System.runAs(objAdmin){
            CreateReportLoanRecordsBatch objBatch = new CreateReportLoanRecordsBatch();
            Database.executeBatch(objBatch, 50);
            List<genesis__Application_Fee_Payment__c> objFeePaymentList = [SELECT Id,External_Id__c FROM genesis__Application_Fee_Payment__c WHERE External_Id__c != NULL ];
            System.assertEquals(true, objFeePaymentList.isEmpty(),'Exception');
        }
        Test.stopTest();

    }
    
    /**
    * @description : Scheddule CreateReportLoanRecords
    * @author  Pritam Roy | 08-16-2024 
    **/
    @IsTest
    public static void testCreateReportLoanRecordsSchedule() {
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c objApplication = [SELECT Id,Pricing_Count__c FROM genesis__Applications__c LIMIT 1];
        genesis__Application_Fee_Payment__c objFeePayment = [SELECT Id,Record_Type__c FROM genesis__Application_Fee_Payment__c LIMIT 1];
        objFeePayment.Record_Type__c = 'ACTIVE LOAN DAILY';
        objFeePayment.External_Id__c='participant-'+objApplication.Id+'-2022-202202';
        Database.update(objFeePayment,true);
        Test.startTest();
        System.runAs(objAdmin){
            CreateReportLoanRecordsSchedule classSchedule = new CreateReportLoanRecordsSchedule();
            classSchedule.execute(null);
            genesis__Application_Fee_Payment__c objFeePaymentCheck = [SELECT Id,External_Id__c FROM genesis__Application_Fee_Payment__c WHERE External_Id__c != NULL ];
            System.assertEquals(true, objFeePaymentCheck!=NULL,'Exception');
        }
        Test.stopTest();
    }
}