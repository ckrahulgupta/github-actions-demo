/**
 * @description       : Test class for NLSXMLImportForDraftSchedule
 * @author            : Simran
 * @group             : 
 * @last modified on  : 01-14-2025
 * @last modified by  : Kabir Pramanik
**/
@istest
public class NLSXMLImportForDraftScheduleTest{
	
    /**
    * @description Test successful scheduling of NLSXMLImportForDraftSchedule class
    * @author Simran | 03-11-2024 
    **/
    @isTest
    private static void testsDraftScheduledClassSuccess() {
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
            NLSXMLImportForDraftSchedule draftScheduleObj = new NLSXMLImportForDraftSchedule();
            String jobId = System.schedule('Test Scheduling of NLSXMLImportForDraftSchedule', '0 0 23 * * ?', draftScheduleObj);
            Test.stopTest();
            System.assertEquals(ConstantValues.TRUE_VALUE, jobId != null, 'Job was not scheduled');
        }
	}
}