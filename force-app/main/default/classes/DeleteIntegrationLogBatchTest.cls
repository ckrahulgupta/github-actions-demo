/**
 * @description       : Test class for DeleteIntegrationLogBatch
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 10-04-2024
 * @last modified by  : Suraj Kumar
**/
@isTest
public with sharing class DeleteIntegrationLogBatchTest {
    /**
    * @description : Test Setup
    * @author  Pritam Roy | 08-16-2024 
    **/
    @TestSetup
    static void makeData(){
        intframework__Integration_Log__c integrationlog = new intframework__Integration_Log__c(intframework__Processing_Status__c='ERROR');
        Database.insert(integrationlog,true);
        
        DateTime testCreatedDateObj = DateTime.now().addDays(-15);
        Test.setCreatedDate(integrationlog.Id, testCreatedDateObj);
    }

    /**
    * @description : Test Delete Logs
    * @author  Pritam Roy | 08-16-2024 
    **/
    @isTest
    private static void testCaseToDeleteLogs(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Test.startTest();
        System.runAs(objAdmin){
            DeleteIntegrationLogBatch deleteLog = new DeleteIntegrationLogBatch(0);
            database.executeBatch(deleteLog,10);
            List<intframework__Integration_Log__c> intLogList= [SELECT Id FROM intframework__Integration_Log__c WHERE intframework__Processing_Status__c = 'ERROR'];
            System.assertEquals(false, intLogList.isEmpty(), 'Exception');
        }
        Test.stopTest();
    }

    /**
    * @description : Test Schedule Delete Job
    * @author  Pritam Roy | 08-16-2024 
    **/
    @isTest
    private static void testScheduledDeleteLogJob(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Test.startTest();
        System.runAs(objAdmin){
            DeleteIntegrationLogsJob calljob = new DeleteIntegrationLogsJob();
            calljob.execute(null);
            List<intframework__Integration_Log__c> intLogList= [SELECT Id FROM intframework__Integration_Log__c WHERE intframework__Processing_Status__c = 'ERROR'];
            System.assertEquals(false, intLogList.isEmpty(), 'Exception');
        }
        Test.stopTest();
    }

}