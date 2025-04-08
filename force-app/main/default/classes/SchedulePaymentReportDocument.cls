/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-06-2024
 * @last modified by  :  Pritam Roy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   15-06-2022   Subham Nandi   Initial Version
**/
global without sharing class SchedulePaymentReportDocument implements Schedulable {
    //Class related Constants--------
    public static final String REPORT_NAME = ConstantValues.PAYMENT_PENDING_REPORT;
    public static final String FOLDER_NAME = ConstantValues.PAYMENT_PENDING_REPORT_FOLDER;
    //Class related Constants--------

    /**
    * @description : Schedule class for Pending Payment
    * @author  Pritam Roy | 03-06-2024 
    * @param sc 
    **/
    global void execute(SchedulableContext sc){

        if(PortalHelper.isTodayAWorkingDay(System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF))){
            //Query the report folder Id
            List<Report> reportList =  [SELECT  Id,
                                                Name 
                                        FROM Report 
                                        WHERE Name = :REPORT_NAME
                                        LIMIT 1];
                
            List<Folder> folderList =   [SELECT Id,
                                                Name 
                                        FROM Folder 
                                        WHERE Name = :FOLDER_NAME
                                        LIMIT 1];
            //Sending Daily NLS Payment Reports
            System.enqueueJob(new GeneratePaymentReportDocument((Id) String.valueOf(reportList[0].Id), (Id) String.valueOf(folderList[0].Id)));

        }
    }
}