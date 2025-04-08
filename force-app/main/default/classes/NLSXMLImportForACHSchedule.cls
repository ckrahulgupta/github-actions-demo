/**
 * @description       : This is a schedulable class which schedule a batch class for posting ACH and then DRAFT
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  : Simran
**/
public with sharing class NLSXMLImportForACHSchedule implements Schedulable {
    
    /**
    * @description This execute method is used to run NLSXMLImportACHCalloutBatch class
    * @author Simran | 03-11-2024 
    * @param ctx 
    **/
    public void execute(SchedulableContext ctx) {
        if(PortalHelper.isTodayAWorkingDay(System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF))){
            Integer batchSize = Integer.valueOf(ConstantValues.NLS_IMPORT_BATCH_SIZE);
            NLSXMLImportACHCalloutBatch xmlimportACHBatch = new NLSXMLImportACHCalloutBatch();
            Database.executeBatch(xmlimportACHBatch , batchSize);
        }
    }
}