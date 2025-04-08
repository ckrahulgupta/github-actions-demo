/**
 * @description       : Test class for GenerateProductReturnHelper
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 12-18-2024
 * @last modified by  : Sk Minsar
**/
@isTest
public with sharing class GenerateProductReturnHelperTest {

	/**
	* @description - Create test data
	* @author Sk Minsar | 12-18-2024 
	**/
    @testSetup
	static void makeData() {
        // creating business information
        genesis__Business_Information__c dealerBusinessInfo = TestClassHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfo, true);

        // Creating Account for Dealer
        Account dealerAccountObj = TestClassHelper.createDealerAccount(dealerBusinessInfo.Id);
        Database.insert(dealerAccountObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = TestClassHelper.createCLAccount(dealerBusinessInfo.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Individual(s) - Sole Proprietorship legal Entity
        clcommon__Legal_Entity__c entityObj = TestClassHelper.createLegalEntity('Individual(s) - Sole Proprietorship');
        Database.insert(entityObj, true);

        // Creating Borrower Account
        Account borrowerAccountObj = TestClassHelper.createSolePropAccount(entityObj,
                                                                                TestClassHelper.createBusinessInfoForBorrower().Id);
        Database.insert(borrowerAccountObj, true);

        // Creating Borrower Contact
        Contact borrowerContactObj = TestClassHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(borrowerContactObj, true);

        // Creating CL Product for Application
        clcommon__CL_Product__c clProductObj = TestClassHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating CL Purpose for Application
        clcommon__CL_Purpose__c clPurposeObj = TestClassHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating map for Application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>();
        paramForApplicationMap.put('dealerAccountId', dealerAccountObj.Id);
        paramForApplicationMap.put('clProductId', clProductObj.Id);
        paramForApplicationMap.put('clPurposeId', clPurposeObj.Id);
        paramForApplicationMap.put('borrowerAccountId', borrowerAccountObj.Id);
        paramForApplicationMap.put('borrowerContactId', borrowerContactObj.Id);
        paramForApplicationMap.put('clAccountId', clAccountObj.Id);

        // Creating Application
        genesis__Applications__c applicationObj = TestClassHelper.createCurrCropYearApplication(paramForApplicationMap);
        Database.insert(applicationObj, true);

        // create rate card and pricing detail
        genesis__Rate_Card_Setup_Header__c rateCardSetupHeaderObj = TestClassHelper.createCurrYearRateCardHeader(dealerAccountObj);
        Database.insert(rateCardSetupHeaderObj, true);
        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailObj = TestClassHelper.createRateCardSetupDetailOne(rateCardSetupHeaderObj);
        Database.insert(rateCardSetupDetailObj, true);
        genesis__Application_Pricing_Detail__c appPricingDetail = TestClassHelper.createEnabledPricingDetail(applicationObj, rateCardSetupDetailObj.Id);
        Database.insert(appPricingDetail, true);

        // create payment mode
        clcommon__Payment_Mode__c productRtnPaymentModeObj = TestClassHelper.createPaymentMode().get('PRODUCT RETURN');
        Database.insert(productRtnPaymentModeObj, true);

         //Create invoice
         clcommon__Consolidated_Invoice__c productReturnInvoiceObj = LoanServicingTestHelper.createInvoice(applicationObj.Id, productRtnPaymentModeObj.Id);
         productReturnInvoiceObj.clcommon__status__c = PortalConstants.STATUS_INITIATED;
         Database.insert(productReturnInvoiceObj, true);

        // creating product return funding transaction Without Properties Batch
        Map<String, Id> paramForProductRtnFTMap = new Map<String, Id>();
        paramForProductRtnFTMap.put('applicationId', applicationObj.Id);
        paramForProductRtnFTMap.put('pricingDetailId', appPricingDetail.Id);
        paramForProductRtnFTMap.put('paymentModeId', productRtnPaymentModeObj.Id);

        // Creating first product return transaction
        genesis__Funding_Transaction__c productRtnFTFirstObj = TestClassHelper.createProductReturnWithoutPropertiesBatch(paramForProductRtnFTMap);
        productRtnFTFirstObj.invoice__c = productReturnInvoiceObj.Id;
        Database.insert(productRtnFTFirstObj, true);

        // Creating second product return transaction
        genesis__Funding_Transaction__c productRtnFTSecondObj = TestClassHelper.createProductReturnWithoutPropertiesBatch(paramForProductRtnFTMap);
        productRtnFTSecondObj.invoice__c = productReturnInvoiceObj.Id;
        Database.insert(productRtnFTSecondObj, true);
        productReturnInvoiceObj.Total_Amount__c = productRtnFTFirstObj.genesis__Amount__c;
        Database.Update(productReturnInvoiceObj, true);
    }

    /**
    * @description - Returns the admin user
    * @author Sk Minsar | 12-18-2024 
    * @return User 
    **/
    private static User getAdminUser(){
        return [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
    }

    /**
    * @description - Test update product Return method
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    public static void updateProductReturn(){
        System.runAs(getAdminUser()){
            Test.startTest();
            GenerateProductReturnHelper.updateFundingTransaction();
            Test.stopTest();
        }
        genesis__Funding_Transaction__c objFundingTransaction = [SELECT Id FROM genesis__Funding_Transaction__c WHERE genesis__Cleared__c = true LIMIT 1];
        System.assertEquals(objFundingTransaction.id != null,true,'No funding transaction found');
    }

    /**
    * @description - Test update product Return method
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    public static void validateInvoice(){
        System.runAs(getAdminUser()){
            Test.startTest();
            GenerateProductReturnHelper.updateFundingTransaction();
            Test.stopTest();
        }
        List<clcommon__Consolidated_Invoice__c> invoiceList = [SELECT Id FROM clcommon__Consolidated_Invoice__c LIMIT 1];
        System.assertEquals(invoiceList.size()>0, true, 'No Invoice found');
    }
}