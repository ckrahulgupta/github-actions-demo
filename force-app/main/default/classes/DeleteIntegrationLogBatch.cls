/**
 * @description       : Purpose of this Class is to delete IntegrationLogs
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 08-10-2024
 * @last modified by  : Soumik Pattanayak
**/
public with sharing class DeleteIntegrationLogBatch implements Database.Batchable<sObject> {
    /**
     * DeleteIntegrationLogBatch deleteLog = new DeleteIntegrationLogBatch(7);
        database.executeBatch(deleteLog,2000);
     */
    private Integer daysBefore;
    /**
    * @description Constructor for assigning the number of days, all the logs before that day will be deleted
    * @author Soumik Pattanayak | 08-10-2024 
    * @param numberOfDays 
    **/
    public DeleteIntegrationLogBatch(integer numberOfDays){
        this.daysBefore = numberOfDays;
    }
    /**
    * @description Query the integration logs before a week
    * @author Subham Nandi | 05-06-2024 
    * @param batchableContext 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext batchableContext){ 
        Datetime dateBefore = System.today().addDays(-1*daysBefore);
        return Database.getQueryLocator([SELECT Id, CreatedDate 
                                        FROM intframework__Integration_Log__c 
                                        WHERE createddate <= :dateBefore]);
    }

    /**
    * @description Delete the Integration Logs
    * @author Subham Nandi | 05-06-2024 
    * @param batchableContext 
    * @param chunk 
    **/
    public void execute(Database.BatchableContext batchableContext, List<intframework__Integration_Log__c> chunk) { 
        Database.delete(chunk,true);
    }

    /**
    * @description 
    * @author Subham Nandi | 05-06-2024 
    * @param batchableContext 
    **/
    public void finish(Database.BatchableContext batchableContext){}
}