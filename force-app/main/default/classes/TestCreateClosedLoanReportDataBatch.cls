/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 09-03-2023
 * @last modified by  : Subham Nandi
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   09-03-2023   Subham Nandi   Initial Version
**/
@isTest
global without sharing class TestCreateClosedLoanReportDataBatch {
    @TestSetup
    static void makeData(){
        genesis__Applications__c objApplication = new genesis__Applications__c();
        objApplication.genesis__Product_Type__c ='Loan';
        objApplication.genesis__Term__c = 12;
        objApplication.Participant_Id__c='67858';
        objApplication.genesis__Interest_Rate__c = 1;
        objApplication.genesis__Loan_Amount__c = 35000;
        objApplication.Crop_Year__c = '2022';
        objApplication.Peak_Loan_Volume__c = 15000;
        objApplication.genesis__Maturity_Date__c = Date.today().addYears(1);
        objApplication.Loan_Id__c = '13900';
        objApplication.genesis__Loan_Number__c = '3HH98762543';
        objApplication.genesis__Status__c = 'CLOSED';
        
        Database.insert(objApplication,true);

        genesis__Application_Pricing_Detail__c objApplicationPricingDetail = TestClassHelper.createPricingDetail(objApplication.Id);// new genesis__Application_Pricing_Detail__c();
        objApplicationPricingDetail.Loan_Id__c = '13901';
        objApplicationPricingDetail.Participant_Id__c='67854';
        objApplicationPricingDetail.genesis__Enabled_Flag__c = true;
        Database.update(objApplicationPricingDetail,true);

        genesis__Application_Pricing_Detail__c objApplicationPricingDetail1 =  new genesis__Application_Pricing_Detail__c();
        objApplicationPricingDetail1.Loan_Id__c = '13902';
        objApplicationPricingDetail1.Participant_Id__c='67859';
        objApplicationPricingDetail1.genesis__Application__c =objApplication.Id;
        objApplicationPricingDetail1.genesis__Enabled_Flag__c = true;
        Database.insert(objApplicationPricingDetail1,true);

        genesis__Application_Fee_Payment__c objFeePayment=new genesis__Application_Fee_Payment__c();
        objFeePayment.Pricing_Detail__c = objApplicationPricingDetail.Id;
        objFeePayment.Record_Type__c = 'ACTIVE LOAN DAILY';
        objFeePayment.genesis__Application__c = objApplication.Id;
        objFeePayment.External_Id__c='participant-'+objApplication.Id+'-2022-202202';
        Database.insert(objFeePayment,true);
        
    }

    @isTest
    public static void testCreateClosedReportLoanRecordsBatch() {
        Test.startTest();
        CreateClosedLoanReportDataBatch obj = new CreateClosedLoanReportDataBatch();
        Database.executeBatch(obj, 50);
        Test.stopTest();

    }
}