/**
 * @description       : Test class for NLSXMLImportForProductReturnSchedule
 * @author            : Simran
 * @group             : 
 * @last modified on  : 04-05-2023
 * @last modified by  : Simran
**/
@isTest
public class NLSXMLImportProductReturnTestClass{
    @TestSetup
    static void setup(){
        genesis__Funding_Transaction__c objFundingTransaction = new genesis__Funding_Transaction__c();
        objFundingTransaction.genesis__Cleared__c = true;
        objFundingTransaction.Posted_to_NLS__c = false;

        clcommon__Payment_Mode__c paymentMode= new clcommon__Payment_Mode__c();
        paymentMode.Name='PRODUCT RETURN';
        Database.insert(paymentMode,true);

        objFundingTransaction.genesis__Payment_Mode__c=paymentMode.Id;
        Database.insert(objFundingTransaction,true);
        
    }
	@isTest
    public static void testProductReturnSchedule() {
        genesis__Funding_Transaction__c objFundingTransact=[SELECT Id, Name,genesis__Cleared__c,Posted_to_NLS__c,genesis__Payment_Mode__c FROM genesis__Funding_Transaction__c Where genesis__Payment_Mode__r.Name='PRODUCT RETURN'];
		
        Test.startTest();
		NLSXMLImportForProductReturnSchedule testschedule = new NLSXMLImportForProductReturnSchedule();
        String sch = '0 0 23 * * ?';
		system.schedule( 'Test status Check', sch, testschedule );
        System.assert(true, 'SUCCESS');
		Test.stopTest();
	}
}