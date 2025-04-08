/**********************************************************************************************************************
 * @description       : This is a schedulable class which schedule a batch class for clearing Mobile Deposits
 * @author            : Sanjana De
 * @group             : 
 * @last modified on  : 01-02-2025
 * @last modified by  : Kabir Pramanik
**********************************************************************************************************************/
global with sharing class ScheduleMobileDepositReportDocument implements Schedulable {
    //Class related Constants--------
    public static final String REPORT_NAME = ConstantValues.MOBILE_DEPOSIT_PENDING_REPORT;
    public static final String FOLDER_NAME = ConstantValues.MOBILE_DEPOSIT_PENDING_REPORT_FOLDER;
    
    /**
    * @description : Schedule method for Mobile Deposit Report Document
    * @author  Pritam Roy | 03-06-2024 
    * @param sc 
    **/
    global void execute(SchedulableContext sc){

        // if(PortalHelper.isTodayAWorkingDay(System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF))){
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
            //Sending Daily NLS Mobile Deposit Reports
            if(reportList.size() > 0 && folderList.size() > 0 ) {
                GenerateMobileDepositReportDocument.createDocument((Id) String.valueOf(reportList[0].Id), (Id) String.valueOf(folderList[0].Id));
            }
            
        // }
    }

    /**
    * @description : Invocable method for global actions
    * @author  Pritam Roy | 03-06-2024 
    **/
    @InvocableMethod(label = 'InitiateMobileDepositForClearing')
    public static void callMobileDepositReportGeneration() {
        // if(PortalHelper.isTodayAWorkingDay(System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF))){
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
            //Sending Daily NLS Mobile Deposit Reports
            if(reportList.size() > 0 && folderList.size() > 0 ) {
                GenerateMobileDepositReportDocument.createDocument((Id) String.valueOf(reportList[0].Id), (Id) String.valueOf(folderList[0].Id));
            }
        // }
    }
}