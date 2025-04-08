/**
 * Created by Riadh Mankai on 1/12/24.
 * Test class for LoggingDataCleaningScheduler class and LoggingDataCleaningBatch class
 */

@IsTest
public class LoggingDataCleaningSchedulerTest {
	static final Integer iterationCount = 200;

	@TestSetup
	static void setupTestData() {
		// Prepare test data
		List<intframework__Integration_Log__c> intLogs = new List<intframework__Integration_Log__c>();
		List<clcommon__Execution_Criteria_Result__c> execResults = new List<clcommon__Execution_Criteria_Result__c>();
		List<clcommon__Log__c> logs = new List<clcommon__Log__c>();

		for (Integer i = 0; i < iterationCount; i++) {
			intLogs.add(new intframework__Integration_Log__c());
			execResults.add(new clcommon__Execution_Criteria_Result__c());
			logs.add(new clcommon__Log__c(Name = 'TestLog' + i));
		}

		insert intLogs;
		insert execResults;
		insert logs;

		// Set the created date on the records
		Datetime createdDateTime = Datetime.now().addDays(-40);
		for (Integer i = 0; i < iterationCount; i++) {
			Test.setCreatedDate(intLogs[i].Id, createdDateTime);
			Test.setCreatedDate(execResults[i].Id, createdDateTime);
			Test.setCreatedDate(logs[i].Id, createdDateTime);
		}
	}

	@IsTest static void testSchedulerWithNoParameter() {
		Test.startTest();

		// Run the scheduler with no parameters
		LoggingDataCleaningScheduler cleaningScheduler = new LoggingDataCleaningScheduler();
		cleaningScheduler.execute(null);

		Test.stopTest();

		// Verify the records have been deleted
		Integer intLogCount = [SELECT COUNT() FROM intframework__Integration_Log__c];
		Integer execResultCount = [SELECT COUNT() FROM clcommon__Execution_Criteria_Result__c];
		Integer logCount = [SELECT COUNT() FROM clcommon__Log__c];

		System.assertEquals(0, intLogCount);
		System.assertEquals(0, execResultCount);
		System.assertEquals(0, logCount);
	}

	@IsTest static void testSchedulerWithOneParameter() {
		Test.startTest();

		// Run the scheduler with 1 parameter
		List<String> objectNames = LoggingDataCleaningBatch.defaultObjectNames;
		LoggingDataCleaningScheduler cleaningScheduler = new LoggingDataCleaningScheduler(objectNames);
		cleaningScheduler.execute(null);

		Test.stopTest();

		// Verify the records have been deleted
		Integer intLogCount = [SELECT COUNT() FROM intframework__Integration_Log__c];
		Integer execResultCount = [SELECT COUNT() FROM clcommon__Execution_Criteria_Result__c];
		Integer logCount = [SELECT COUNT() FROM clcommon__Log__c];

		System.assertEquals(0, intLogCount);
		System.assertEquals(0, execResultCount);
		System.assertEquals(0, logCount);
	}
}