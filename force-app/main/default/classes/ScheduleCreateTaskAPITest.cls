/**
 * @description       : Test Class to cover ScheduleCreateTaskAPI
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 01-29-2024
 * @last modified by  : Rahul Gupta
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   06-10-2023   Subham Nandi   Initial Version
**/
@isTest
public class ScheduleCreateTaskAPITest {
    @TestSetup
    static void makeData(){
        //Create Application without tasks
        genesis__Applications__c objApplication = TestClassHelper.createApplication();
        //Create task setup
        String taskSetupName = 'Signed Credit Agreement';
        genesis__Task_Setup__c taskSetup = ApplicationOriginationTestHelper.createTaskSetup(taskSetupName);
        Database.insert(taskSetup,true);
        String departmentName = 'Credit';
        genesis__Department__c objDepartment = ApplicationOriginationTestHelper.createDepartmentByName(departmentName);
        Database.insert(objDepartment,true);

        //Create CFA Admin User
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User cfaAdminUser = ApplicationOriginationTestHelper.createCFAUserByProfile(adminProfile.Id);
        Database.insert(cfaAdminUser,true);

        //Create Standard User
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User standardUser = ApplicationOriginationTestHelper.createCFAUserByProfile(standardUserProfile.Id);
        standardUser.UserName = 'testStandardUser@yopmail.com.test';
        Database.insert(standardUser,true);
    }

    @isTest
    static void createTaskSuccess(){
        Test.startTest();
        User systemAdminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(systemAdminUser){
            ScheduleCreateTaskAPI createTasksForApp = new ScheduleCreateTaskAPI();
            createTasksForApp.execute(null);
        }
        Test.stopTest();
        List<Task> createdTasks = [SELECT Id FROM Task];
        //Since there is 1 task setup in the test scenario, so there will be 1 task created for the application
        System.assertEquals(createdTasks.size(),1, 'Success');
    }

    @isTest
    static void createTaskFailure(){
        Test.startTest();
        User standardUser = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND Createddate = TODAY LIMIT 1];
        System.runAs(standardUser){
            ScheduleCreateTaskAPI createTasksForApp = new ScheduleCreateTaskAPI();
            createTasksForApp.execute(null);
        }
        Test.stopTest();
        List<Task> createdTasks = [SELECT Id FROM Task];
        System.assertEquals(createdTasks.size(),0, 'Success');
    }


}