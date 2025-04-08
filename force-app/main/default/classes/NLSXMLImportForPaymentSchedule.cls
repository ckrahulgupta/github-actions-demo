/**********************************************************************************************************************
 * @description       : This is a schedulable class which schedule a batch class for posting Payoffs to NLS
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 08-10-2024
 * @last modified by  : Soumik Pattanayak
**********************************************************************************************************************/
global with sharing class NLSXMLImportForPaymentSchedule implements Schedulable {
    /**
    * @description calls the batch class if the time is in working hours
    * @author Soumik Pattanayak | 08-10-2024 
    * @param ctx 
    **/
    global void execute(SchedulableContext ctx) {
        if(PortalHelper.isTodayAWorkingDay(System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF))){
            Integer batchSize = Integer.valueOf(ConstantValues.NLS_IMPORT_BATCH_SIZE);
            NLSXMLImportPayOffCalloutBatch xmlimportPaymentBatch = new NLSXMLImportPayOffCalloutBatch();
            Database.executeBatch(xmlimportPaymentBatch , batchSize);
        }
    }
}