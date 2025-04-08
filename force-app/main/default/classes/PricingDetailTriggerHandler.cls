/**
 * Created by Muhammed Sargin, December 2022
 * Last Modified By Riadh Mankai, January 3 2024
 */
public class PricingDetailTriggerHandler {
	public static final Map<String, String> cfaToGrowmarkSuffix = new Map<String, String> {
		  'A' => '001',
		  'B' => '002',
		  'C' => '003',
		  'D' => '004',
		  'E' => '005',
		  'F' => '006',
		  'G' => '007',
		  'H' => '008',
		  'I' => '009',
		  'J' => '010',
		  'K' => '011',
		  'L' => '012',
		  'M' => '013',
		  'N' => '014',
		  'O' => '015',
		  'P' => '016',
		  'Q' => '017',
		  'R' => '018',
		  'S' => '019',
		  'T' => '020',
		  'U' => '021',
		  'V' => '022',
		  'W' => '023',
		  'X' => '024',
		  'Y' => '025',
		  'Z' => '026'
	};
	public static void mapParentToChild(List<genesis__Application_Pricing_Detail__c> pricingDetailTriggerOld, List<genesis__Application_Pricing_Detail__c> pricingDetailTriggerNew) {
		Boolean isInsertContext = pricingDetailTriggerOld == null || pricingDetailTriggerOld.isEmpty();
		Boolean isUpdateContext = !isInsertContext;
		Set<Id> applicationsIds = new Set<Id>();
		Map<Id, genesis__Applications__c> applicationsMap = new Map<Id, genesis__Applications__c>();
//		collect parent application IDs
		for (genesis__Application_Pricing_Detail__c eachPricingDetail : pricingDetailTriggerNew) {
			applicationsIds.add(eachPricingDetail.genesis__Application__c);
		}
		for (genesis__Applications__c eachApplication : [SELECT Id, Pricing_Count__c FROM genesis__Applications__c WHERE Id IN :applicationsIds]) {
			applicationsMap.put(eachApplication.Id, eachApplication);
		}
		Integer size = pricingDetailTriggerNew.size();
		for (Integer i = 0; i < size; i++) {
			// If we are in an update scenario
			if (isUpdateContext) {
//				If the CFA Loan_Number__c didn't change, then do nothing, there is no need to update anything. Exist the loop
				if (pricingDetailTriggerOld[i].Loan_Number__c == pricingDetailTriggerNew[i].Loan_Number__c) {
					continue;
				}
			}
//			If we are in an Insert scenario or an Update scenario
//			If the new CFA loan number is empty or null, then the Growmark Loan number should be empty as well
			if (String.isBlank(pricingDetailTriggerNew[i].Loan_Number__c)) {
				pricingDetailTriggerNew[i].Growmark_Loan_Number__c = '';
				continue;
			}
//			If Loan_Number__c contains a dash
			String cfaLoanNumberSuffixToReplace = pricingDetailTriggerNew[i].Loan_Number__c.substringAfter('-');
			if (String.isNotEmpty(cfaLoanNumberSuffixToReplace) && cfaToGrowmarkSuffix.containsKey(cfaLoanNumberSuffixToReplace)) {
				String growmarkLoanNumberSuffix = cfaToGrowmarkSuffix.get(cfaLoanNumberSuffixToReplace);
				pricingDetailTriggerNew[i].Growmark_Loan_Number__c = pricingDetailTriggerNew[i].Loan_Number__c.substringBefore('-') + growmarkLoanNumberSuffix;
			} else {
//				If we don't find a dash and if the parent application is a single loan application, then append 001 to the single child loan Growmark_Loan_Number__c
				Decimal pricingCount = applicationsMap.get(pricingDetailTriggerNew[i].genesis__Application__c).Pricing_Count__c;
				if (pricingCount != null && pricingCount == 1) {
					pricingDetailTriggerNew[i].Growmark_Loan_Number__c = pricingDetailTriggerNew[i].Loan_Number__c + '001';
//				Else, default the Growmark_Loan_Number__c to Loan_Number__c
				} else {
					pricingDetailTriggerNew[i].Growmark_Loan_Number__c = pricingDetailTriggerNew[i].Loan_Number__c;
				}
			}
		}
	}
}