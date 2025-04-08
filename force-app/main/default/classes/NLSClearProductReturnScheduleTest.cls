/**
 * @description       : Test class for NLSClearProductReturnSchedule
 * @author            : Simran
 * @last modified on  : 01-09-2024
 * @last modified by  :  Pritam Roy
**/
@isTest
public with sharing class NLSClearProductReturnScheduleTest {
    @isTest(seeAllData = true)
    public static void testNLSClearProductReturnSchedule(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
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

        // creating ach funding transaction Without Properties Batch
        Map<String, Id> paramForProductRtnFTMap = new Map<String, Id>();
        paramForProductRtnFTMap.put('applicationId', applicationObj.Id);
        paramForProductRtnFTMap.put('pricingDetailId', appPricingDetail.Id);
        paramForProductRtnFTMap.put('paymentModeId', productRtnPaymentModeObj.Id);

        // Creating First ACH Funding Transaction
        genesis__Funding_Transaction__c productRtnFTFirstObj = TestClassHelper.createProductReturnWithoutPropertiesBatch(paramForProductRtnFTMap);
        Database.insert(productRtnFTFirstObj, true);

        // Creating Second ACH Funding Transaction 
        genesis__Funding_Transaction__c productRtnFTSecondObj = TestClassHelper.createProductReturnWithoutPropertiesBatch(paramForProductRtnFTMap);
        Database.insert(productRtnFTSecondObj, true);
        System.runAs(objAdmin){
            Test.startTest();
            System.schedule('testNLSClearACHSchedule','0 55 * * * ? *', new NLSClearProductReturnSchedule());
            Test.stopTest();
        }
        List<genesis__Funding_Transaction__c> fundingTransactionList = [SELECT Id,
                                                                                genesis__Cleared__c
                                                                            FROM genesis__Funding_Transaction__c
                                                                            WHERE genesis__Application__r.genesis__Status__c = 'ACTIVE'
                                                                            AND genesis__Cleared__c = true];
        System.assertEquals(true, fundingTransactionList[0].genesis__Cleared__c, 'SUCCESS');
    }
}