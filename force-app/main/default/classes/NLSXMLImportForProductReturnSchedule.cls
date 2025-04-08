/**
 * @description       : Schedule class for NLSXMLImportForProductReturnSchedule and NLSXMLImportProductReturnCalloutBatch
 * @author            : Simran
 * @group             : 
 * @last modified on  : 03-12-2024
 * @last modified by  : Simran
**/

public with sharing class NLSXMLImportForProductReturnSchedule implements Schedulable{
    
    /**
    * @description Execute method to call NLSXMLImportProductReturnCalloutBatch class
    * @author Simran | 03-12-2024 
    * @param ctx 
    **/
    public void execute(SchedulableContext ctx){
        if(PortalHelper.isTodayAWorkingDay(System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF))){
            Integer batchSize = 1;
            NLSXMLImportProductReturnCalloutBatch xmlImportProductReturnBatch = new NLSXMLImportProductReturnCalloutBatch();
            Database.executeBatch(xmlImportProductReturnBatch , batchSize);
        }
    }
}