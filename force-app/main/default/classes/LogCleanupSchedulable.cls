/**
 * Logs Cleanup Scheudler
 * 
 * Note: All the ApexCRUDViolation rules are explicitly turned off intententionally
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public without sharing class LogCleanupSchedulable implements Schedulable {
    public void execute(SchedulableContext sc) {
        Integer numDays = 7;
        LogSetting__mdt logSettings = LogSetting__mdt.getInstance('System');
        if(logSettings != null) {
            if(logSettings.RetentionPeriodInDays__c != null) {
                numDays = logSettings.RetentionPeriodInDays__c.round().intValue();
            }
        }
        LogCleanupBatch b = new LogCleanupBatch(numDays);
        database.executebatch(b,2000);
    }
}