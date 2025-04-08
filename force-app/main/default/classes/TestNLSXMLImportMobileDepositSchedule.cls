/**********************************************************************************************************************
 * @description       : This is a test class for NLSXMLImportForMobileDepositScheduleable
 * @author            : Sanjana De
 * @group             : 
 * @last modified on  : 01-17-2025
 * @last modified by  : Kabir Pramanik
**********************************************************************************************************************/
@isTest
public with sharing class TestNLSXMLImportMobileDepositSchedule {
    /**
    * @description test for successful scheculing of the class
    * @author Kabir Pramanik | 01-01-2025
    **/
    @isTest
    public static void testMobileDepositScheduleClassSuccess() {
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
            NLSXMLImportForMobileDepositScheduleable mobileDepositScheduleObj = new NLSXMLImportForMobileDepositScheduleable();
            String jobId = System.schedule( 'NLSXMLImportForMobileDepositScheduleable Job', '0 0 23 * * ?', mobileDepositScheduleObj );
            Test.stopTest();
            System.assertEquals(ConstantValues.TRUE_VALUE, jobId != null, 'Job was not scheduled');
        }
    }
}