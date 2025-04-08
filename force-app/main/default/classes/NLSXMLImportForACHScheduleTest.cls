/**
 * @description       : Test class for NLSXMLImportForACHSchedule
 * @author            : Simran
 * @group             : 
 * @last modified on  : 01-17-2025
 * @last modified by  : Kabir Pramanik
**/
@istest
public class NLSXMLImportForACHScheduleTest{
    /**
    * @description Test method for NLSXMLImportForACHSchedule class
    * @author Kabir Pramanik | 01-03-2025 
    **/
    @isTest
    private static void testACHScheduledClassSuccess() {
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
            NLSXMLImportForACHSchedule testACHSchedule = new NLSXMLImportForACHSchedule();
            String jobId = System.schedule( 'Test Scheduling of NLSXMLImportForACHSchedule', '0 0 23 * * ?', testACHSchedule );
            Test.stopTest();
            System.assertEquals(ConstantValues.TRUE_VALUE, jobId != null, 'Job was not scheduled');
        }
	}
}