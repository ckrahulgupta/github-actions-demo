/**
 * @description       : 
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 12-28-2024
 * @last modified by  : Rahul Gupta
**/
@isTest
public class DealerReportsControllerTest {

    /**
    * @description 
    * @author Rahul Gupta | 12-28-2024 
    **/
    @TestSetup
    static void makeData() {
        ApplicationOriginationSetupTestHelper.createTestSetup();
    }

    /**
    * @description 
    * @author Rahul Gupta | 12-28-2024 
    **/
    @isTest
    public static void testSuccess() {
        
        System.runAs([SELECT Id FROM User WHERE Username = 'ross.geller@yopmail.com'][0]) {

            Test.startTest();
            PageReference pageRef = Page.dealerPortalReports;
            Test.setCurrentPage(pageRef);
            System.currentPageReference().getParameters().put('reportName', 'Past_Due_Report');

            DealerReportsController controller = new DealerReportsController();

            System.assertEquals('Coop_Type', controller.reportData.coopTypeField, 'Test Failed');
            Test.stopTest();
        }
    }
}