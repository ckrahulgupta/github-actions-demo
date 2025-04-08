/**
 * Batch job enables cleanup 
 */
@SuppressWarnings('PMD.EmptyStatementBlock')
public without sharing class LogCleanupBatch Implements Database.batchable<sObject> {
    private Integer retentionDays = -7;

    public LogCleanupBatch(Integer inputDays) {
        retentionDays = -(inputDays);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        DateTime latestRetentionTime = System.now().addDays(retentionDays);
        String dtstring = latestRetentionTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''); 
        return Database.getQueryLocator('SELECT Id FROM LogEntry__c WHERE CreatedTime__c < ' + dtstring);
    }
    
    public  void execute(Database.BatchableContext bc, List<LogEntry__c> scope) {
         delete scope;
    }

    public void finish(Database.BatchableContext bc){
        //DO nothing
    }
}