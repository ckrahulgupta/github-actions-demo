/**
 * Created by riadhmankai on 8/3/23.
 */

@IsTest
global class PricingDetailTriggerTestHelper {
	public static genesis__Applications__c createApplication(Account objAccount, clcommon__CL_Product__c clProduct, clcommon__CL_Purpose__c clPurpose) {
		genesis__Applications__c applicationObj = new genesis__Applications__c();
		applicationObj.genesis__Product_Type__c = 'Loan';
		applicationObj.genesis__Term__c = 12;
		applicationObj.genesis__Interest_Rate__c = 1;
		applicationObj.genesis__Loan_Amount__c = 35000;
		applicationObj.Peak_Loan_Volume__c = 15000;
		applicationObj.genesis__Maturity_Date__c = Date.today().addYears(1);
		applicationObj.Loan_Id__c = '139000';
		applicationObj.genesis__Loan_Number__c = '398762543';
		applicationObj.Dealer_Name__c = objAccount.Id;
		applicationObj.genesis__CL_Product__c = clProduct.Id;
		applicationObj.genesis__CL_Purpose__c = clPurpose.Id;
		return applicationObj;
	}

	public static genesis__Application_Pricing_Detail__c createPricingDetail(
		  String applicationId,
		  String loanNumber
	) {
		genesis__Application_Pricing_Detail__c newPricingDetails = new genesis__Application_Pricing_Detail__c();
		newPricingDetails.genesis__Maximum_Financed_Amount__c = 15000;
		newPricingDetails.genesis__Rate_Factor_Based_On_Amount__c = 100;
		newPricingDetails.genesis__Rate_Factor__c = 0.00;
		newPricingDetails.genesis__Term__c = 12;
		newPricingDetails.genesis__Yield_Percent__c = 0.00;
		newPricingDetails.genesis__Application__c = applicationId;
		newPricingDetails.Loan_Number__c = loanNumber;
		newPricingDetails.Loan_Id__c = '139001';
		newPricingDetails.Maturity_Date__c = Date.today().addYears(1);
		newPricingDetails.genesis__Enabled_Flag__c = true;
		return newPricingDetails;
	}
}