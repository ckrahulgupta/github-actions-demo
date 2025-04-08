/**
 * @description       : Purpose of this class is to Test ScheduledActivePricingDetailAPI
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 25-05-2022
 * @last modified by  : Subham Nandi
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   25-05-2022   Subham Nandi   Initial Version
**/
@isTest
global class TestScheduledActivePricingDetailAPI {
    @isTest 
    static void testScheduledPricing(){
        Test.startTest();
        genesis__Business_Information__c objBusiness = TestClassHelper.createBusinessInfo();
        Account objAccount = TestClassHelper.createAccount(objBusiness);
        genesis__Rate_Card_Setup_Header__c objMyProgram = TestClassHelper.createRateCardHeader(objAccount);
        objMyProgram.genesis__End_Date__c = System.today();
        Database.update(objMyProgram);
        //create application 
        genesis__Applications__c objApplication = TestClassHelper.createApplication();
        //Create Pricing to close
        genesis__Rate_Card_Setup_Detail__c objRateCardSetupToClose = TestClassHelper.createRateCardSetupDetail(objMyProgram);
        objRateCardSetupToClose.End_Date__c = System.today().addDays(-1);
        Database.update(objRateCardSetupToClose);
        genesis__Application_Pricing_Detail__c objPricingDetailToClose = TestClassHelper.createPricingDetail((String)objApplication.Id);
        objPricingDetailToClose.genesis__Rate_Card_Setup_Detail__c = objRateCardSetupToClose.Id;
        Database.update(objPricingDetailToClose);
        //Create Pricing to open
        genesis__Rate_Card_Setup_Detail__c objRateCardSetupToOpen = TestClassHelper.createRateCardSetupDetail(objMyProgram);
        objRateCardSetupToOpen.Start_Date__c = System.today();
        Database.update(objRateCardSetupToOpen);
        genesis__Application_Pricing_Detail__c objPricingDetailToOpen = TestClassHelper.createPricingDetail((String)objApplication.Id);
        objPricingDetailToOpen.genesis__Rate_Card_Setup_Detail__c = objRateCardSetupToOpen.Id;
        Database.update(objPricingDetailToOpen);
        ScheduledActivePricingDetailAPI schedulePricing = new ScheduledActivePricingDetailAPI();
        String cronExpression = '0 0 23 * * ?';
        System.schedule('Test Schedule Pricing Detail', cronExpression, schedulePricing);
        Test.stopTest();
    }

    @isTest 
    static void testScheduledPricingError(){
        Test.startTest();
        ScheduledActivePricingDetailAPI schedulePricing = new ScheduledActivePricingDetailAPI();
        String cronExpression = '0 0 23 * * ?';
        System.schedule('Test Schedule Pricing Detail', cronExpression, schedulePricing);
        Test.stopTest();
    }
}