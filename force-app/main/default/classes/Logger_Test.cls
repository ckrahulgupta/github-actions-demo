/**
 * Test class for core logging framework
 */
@IsTest
public with sharing class Logger_Test {
    @IsTest
	private static void testAllLogLevels() {
        Logger.error('ERROR Message');
        Logger.warn('WARN Message');
        Logger.info('INFO Message');
        Logger.debug('DEBUG Message');
        Logger.pause();
        Logger.debug('This will not be logged');
        Logger.fine('This will not be logged');
        Logger.resume();
        Logger.fine('FINE Message');
        Logger.finer('FINER Message');
        Logger.finest('FINEST Message');
        
        Integer logCount = [SELECT COUNT() FROM LogEntry__c];
        Integer expectedLogCount = 0;
        LoggingLevel currentLogLevel = Logger.getCurrentLogLevel();
        switch on currentLogLevel {
            when ERROR {
                expectedLogCount = 1;
            }
            when WARN {
                expectedLogCount = 2;
            }
            when INFO {
                expectedLogCount = 3;
            }
            when DEBUG {
                expectedLogCount = 4;
            }
            when FINE {
                expectedLogCount = 5;
            }
            when FINER {
                expectedLogCount = 6;
            }
            when FINEST {
                expectedLogCount = 7;
            }
            when else {
                expectedLogCount = 0;
            }
        }
        System.assertEquals(expectedLogCount, logCount, 'Expected log messages count does not match with actual' + logCount);
    }       
}