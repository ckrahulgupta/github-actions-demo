/**
 * @description       : This scheduled class runs every day at 11:30 AM and cut off/clear the Funding transaction for Product Return 
 * @author            : Simran
 * @group             : 
 * @last modified on  : 01-15-2024
 * @last modified by  :  Pritam Roy
**/
public with sharing class NLSClearProductReturnSchedule implements Schedulable{
    // Parameters specific to this class.
    private static final String CLASS_NAME = NLSClearProductReturnSchedule.class.getName();
    private static final String CFA_ORGANISATION = System.Label.CFA_Sender_Name;
    private static final Integer GMT_TO_CDT_HOUR_DIFF = -5;
    private static final String REPORT_NAME = ConstantValues.PRODUCT_RETURN_PENDING;
    private static final String FOLDER_NAME = ConstantValues.PRODUCT_RETURN_REPORTS;
    private static final String FOLDER_TYPE = 'Document';
    private static final String PRODUCT_RETURN_SUBJECT = 'Product Return Initiated Report';
    private static final String REPORT_ID = 'reportID';
    private static final String FOLDER_ID = 'folderID';
    // Parameters specific to this class.

    /**
     * @description This method clear all the Product Return Funding Transaction and send email notification to the cls.
     * @param ctx 
     */
    public void execute(SchedulableContext ctx) {
        /* SCHEDULING SNIPPET
        NLSClearProductReturnSchedule clearProductReturn = new NLSClearProductReturnSchedule();
        String cronExpression = '0 55 * * * ? *';
        String jobID = system.schedule('Schedule NLS Clear Product Return', cronExpression, clearProductReturn);

        NLSClearProductReturnSchedule clearProdRtnFromButton = new NLSClearProductReturnSchedule();
        clearProdRtnFromButton.execute(null);
        */
        if(PortalHelper.isTodayAWorkingDay(System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF))){
            clearAllProductReturn();
        }
    }
    /**
     * @description This method check crud permissions.
     */
    private static void checkAccessOnObjects(){
        if((!Schema.sObjectType.genesis__Funding_Transaction__c.isAccessible())
                | (!Schema.sObjectType.clcommon__Funding_Transactions_Properties__c.isCreateable())
                | (!Schema.sObjectType.OrgWideEmailAddress.isAccessible())
                | (!Schema.sObjectType.Report.isAccessible())
                | (!Schema.sObjectType.Folder.isAccessible())
                | (!Schema.sObjectType.clcommon__Funding_Transactions_Properties__c.isUpdateable())
                | (!Schema.sObjectType.genesis__Funding_Transaction__c.isUpdateable())){
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
        }
    }
    /**
     * @description This method clear all the ach and create properties batch for a day and send emails to cls.
     */
    @invocableMethod(label = 'InitiateProductReturnForClearing')
    public static void clearAllProductReturn(){
        try {
            checkAccessOnObjects();
            Map<String,Id> typeVsIdMap = new Map<String,Id>();

            List<Report> reportList =  [SELECT  Id,
                                                    Name 
                                            FROM Report 
                                            WHERE Name = :REPORT_NAME
                                            LIMIT 1];

            List<Folder> folderList =   [SELECT Id,
                                                 Name 
                                            FROM Folder 
                                            WHERE Name = :FOLDER_NAME
                                            AND Type =: FOLDER_TYPE
                                            LIMIT 1];

            typeVsIdMap.put(REPORT_ID,(Id) String.valueOf(reportList[0].Id));
            typeVsIdMap.put(FOLDER_ID,(Id) String.valueOf(folderList[0].Id));

            System.enqueueJob(new GenerateProductReturnHandler(typeVsIdMap,true,PRODUCT_RETURN_SUBJECT));     
        }catch(Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
    }
}