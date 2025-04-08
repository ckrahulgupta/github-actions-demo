/**
 * @description       : Schedule class to call at 11:30 am to post all drafts
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  : Simran
**/
public with sharing class NLSXMLImportForDraftSchedule implements Schedulable {
    
    /**
    * @description Execute method to run NLSXMLImportDraftCalloutBatch class
    * @author Simran | 03-11-2024 
    * @param ctx 
    **/
    public void execute(SchedulableContext ctx) {
        /**
         * Scheduling Clear and Post all the drafts
        NLSXMLImportForDraftSchedule clearACH = new NLSXMLImportForDraftSchedule();
        String cronExpression = '0 30 11 * * ?';
        String jobID = system.schedule('Schedule NLS Clear/Post Draft', cronExpression, clearACH);
         */
        if(PortalHelper.isTodayAWorkingDay(System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF))){
            NLSXMLImportDraftCalloutBatch xmlimportdraftBatch = new NLSXMLImportDraftCalloutBatch();
            Database.executeBatch(xmlimportdraftBatch , 1);
        }
    }
}