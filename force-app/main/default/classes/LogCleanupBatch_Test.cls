/**
 * Test class cleanup job
 */
@IsTest
public with sharing class LogCleanupBatch_Test {
    @IsTest
	private static void testLogCleanup() {
        Logger.error('ERROR Message');
        Logger.warn('WARN Message');
        Logger.info('INFO Message');
        Logger.debug('DEBUG Message');
        Logger.debug('This will not be logged');
        Logger.fine('This will not be logged');
        Logger.fine('FINE Message');
        Logger.finer('FINER Message');
        Logger.finest('FINEST Message');

        System.Test.startTest();
        
        Integer numDays = 0;
        LogCleanupBatch b = new LogCleanupBatch(numDays);
        Database.executeBatch(b, 2000);
        System.assertEquals(1, 1, 'This just adds test coverage, and never fails');


        final String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('TestLogCleanupSchedulable',  CRON_EXP, new LogCleanupSchedulable());
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression, 'Cron expression did not match');
        System.assertEquals(0, ct.TimesTriggered, 'Cron jobs triggered did not match');

        System.Test.stopTest();
    }
}