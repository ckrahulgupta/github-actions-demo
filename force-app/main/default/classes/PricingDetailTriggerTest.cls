/**
 * Created by Muhammed Sargin, December 2022
 * LastModified By Riadh Mankai, January 5 2023
 */
@IsTest
public class PricingDetailTriggerTest {
	public static Map<String, String> testSuffixMap = PricingDetailTriggerHandler.cfaToGrowmarkSuffix;

	@TestSetup
	static void setupTestData() {
		Account objAccount = new Account(
			  Name = 'Test dealer',
			  CIF_Number__c = '115282',
			  BillingCity = 'aaaa',
			  BillingState = 'bbbb'
		);
		Database.insert(objAccount, false);

		clcommon__CL_Product__c clProduct = new clcommon__CL_Product__c();
		clProduct.clcommon__Product_Name__c = 'SimpliFy';
		insert clProduct;

		clcommon__CL_Purpose__c clPurposes = new clcommon__CL_Purpose__c();
		clPurposes.Name = 'Crop';
		insert clPurposes;
	}

	@IsTest
	static void testGrowmarkLoanNumBuildingOnUpdate() {
		Account objAccount = [SELECT Id FROM Account WHERE CIF_Number__c = '115282' LIMIT 1];
		clcommon__CL_Product__c clProduct = [SELECT Id FROM clcommon__CL_Product__c WHERE clcommon__Product_Name__c = 'SimpliFy' LIMIT 1];
		clcommon__CL_Purpose__c clPurpose = [SELECT Id FROM clcommon__CL_Purpose__c WHERE Name = 'CROP' LIMIT 1];

		genesis__Applications__c parentApplication = PricingDetailTriggerTestHelper.createApplication(objAccount, clProduct, clPurpose);
		insert parentApplication;

		List<genesis__Application_Pricing_Detail__c> pricingDetails = new List<genesis__Application_Pricing_Detail__c>();
		for (String eachCFASuffix : testSuffixMap.keySet()) {
			genesis__Application_Pricing_Detail__c recPAD = PricingDetailTriggerTestHelper.createPricingDetail(parentApplication.Id, null);
			pricingDetails.add(recPAD);
		}
		insert pricingDetails;

//		simulating an update with the loan numbers once they are calculated
		Test.startTest();
		Integer counter = 0;
		for (String eachCFASuffix : testSuffixMap.keySet()) {
			pricingDetails[counter].Loan_Number__c = '12345689-' + eachCFASuffix;
			counter = counter + 1;
		}
		update pricingDetails;
		Test.stopTest();

		// Verify that the Growmark_Loan_Number__c field was populated correctly
		List<genesis__Application_Pricing_Detail__c> updatedRecList = [
			  SELECT Growmark_Loan_Number__c, Loan_Number__c
			  FROM genesis__Application_Pricing_Detail__c
		];
		for (genesis__Application_Pricing_Detail__c rec : updatedRecList) {
			String expectedValue = rec.Loan_Number__c.substringBefore('-') + testSuffixMap.get(rec.Loan_Number__c.substringAfter('-'));
			System.assertEquals(expectedValue, rec.Growmark_Loan_Number__c);
		}
	}

	@IsTest
	static void testGrowmarkLoanNumBuildingOnInsert() {
		Account objAccount = [SELECT Id FROM Account WHERE CIF_Number__c = '115282' LIMIT 1];
		clcommon__CL_Product__c clProduct = [SELECT Id FROM clcommon__CL_Product__c WHERE clcommon__Product_Name__c = 'SimpliFy' LIMIT 1];
		clcommon__CL_Purpose__c clPurpose = [SELECT Id FROM clcommon__CL_Purpose__c WHERE Name = 'CROP' LIMIT 1];

		genesis__Applications__c parentApplication = PricingDetailTriggerTestHelper.createApplication(objAccount, clProduct, clPurpose);
		insert parentApplication;

		List<genesis__Application_Pricing_Detail__c> pricingDetails = new List<genesis__Application_Pricing_Detail__c>();
		for (String eachCFASuffix : testSuffixMap.keySet()) {
			genesis__Application_Pricing_Detail__c recPAD = PricingDetailTriggerTestHelper.createPricingDetail(parentApplication.Id, '12345689-' + eachCFASuffix);
			pricingDetails.add(recPAD);
		}

		Test.startTest();
		insert pricingDetails;
		Test.stopTest();

		// Verify that the Growmark_Loan_Number__c field was populated correctly
		List<genesis__Application_Pricing_Detail__c> updatedRecList = [
			  SELECT Growmark_Loan_Number__c, Loan_Number__c
			  FROM genesis__Application_Pricing_Detail__c
		];
		for (genesis__Application_Pricing_Detail__c rec : updatedRecList) {
			String expectedValue = rec.Loan_Number__c.substringBefore('-') + testSuffixMap.get(rec.Loan_Number__c.substringAfter('-'));
			System.assertEquals(expectedValue, rec.Growmark_Loan_Number__c);
		}
	}

	@IsTest
	static void testGrowmarkLoanNumBuildingWhenSingleLoan() {
		Account objAccount = [SELECT Id FROM Account WHERE CIF_Number__c = '115282' LIMIT 1];
		clcommon__CL_Product__c clProduct = [SELECT Id FROM clcommon__CL_Product__c WHERE clcommon__Product_Name__c = 'SimpliFy' LIMIT 1];
		clcommon__CL_Purpose__c clPurpose = [SELECT Id FROM clcommon__CL_Purpose__c WHERE Name = 'CROP' LIMIT 1];

		genesis__Applications__c parentApplication = PricingDetailTriggerTestHelper.createApplication(objAccount, clProduct, clPurpose);
		insert parentApplication;

//		insert a single child loan
		genesis__Application_Pricing_Detail__c singleChildLoan = PricingDetailTriggerTestHelper.createPricingDetail(parentApplication.Id, '12345689-A');

//		insert the child loan and then remove the dash part to simulate an NLS pull
		insert singleChildLoan;
		Test.startTest();
		singleChildLoan.Loan_Number__c = '12345689';
		update singleChildLoan;
		Test.stopTest();

		// Verify that the Growmark_Loan_Number__c field was populated correctly
		singleChildLoan = [
			  SELECT Growmark_Loan_Number__c, Loan_Number__c, genesis__Application__c, genesis__Enabled_Flag__c
			  FROM genesis__Application_Pricing_Detail__c
			  WHERE Id = :singleChildLoan.Id
			  LIMIT 1
		];
		String expectedValue = '12345689' + '001';
		System.assertEquals(expectedValue, singleChildLoan.Growmark_Loan_Number__c);
	}

}