/**
 * @description       : scheduled class to create task for applications that don't have the task generated
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 01-29-2024
 * @last modified by  : Rahul Gupta
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   06-10-2023   Subham Nandi   Initial Version
**/
public with sharing class ScheduleCreateTaskAPI implements Schedulable{
    private static final String CLASSNAME = 'ScheduleCreateTaskAPI';
    /**
    * @description This execute method runs at a scheduled time, which checks whether there is any application without a task and creates the Task for the same.
    * @author Subham Nandi | 06-10-2023 
    * @param ctx 
    **/
    public void execute(SchedulableContext ctx){

        List<String> appListToCreateTask = new List<String>();
        
        try {
            if( !Task.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable() ||             
            !genesis__Department__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() ||
            !genesis__Applications__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() ||
            !genesis__Task_Setup__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
                throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
            }

            //Construct the Map of Task Setup
            List<genesis__Task_Setup__c> taskSetupList = [SELECT Id, 
                                                                genesis__Object_Type__c, 
                                                                genesis__Priority__c, 
                                                                genesis__Task_Name__c, 
                                                                genesis__Type__c 
                                                            FROM genesis__Task_Setup__c 
                                                            WHERE genesis__Object_Type__c = 'genesis__applications__c' AND 
                                                            (genesis__Task_name__c != 'Task Testing 1' AND 
                                                            genesis__Task_name__c != 'Task Testing 2' AND 
                                                            genesis__Task_name__c != 'Task Testing 3')];
            //Query all the application that was created after yesterday
            List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                                    genesis__Status__c, 
                                                                    Dealer_Name__r.Name, 
                                                                    (SELECT Subject FROM Tasks limit 1)  
                                                                FROM genesis__Applications__c 
                                                                WHERE createddate >= yesterday ORDER BY CreatedDate desc];
            for(genesis__Applications__c eachApp : applicationList){
                if(eachApp.Tasks.Size() == 0){
                    appListToCreateTask.add(eachApp.Id);
                }
            }

            //Call a method to create task
            createTask(taskSetupList,appListToCreateTask);

            
        } 
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASSNAME);
        }
    }

    /**
    * @description Helps in creating Task
    * @author Subham Nandi | 06-10-2023 
    * @param taskSetupList 
    * @param appListToCreateTask 
    **/
    private static void createTask( List<genesis__Task_Setup__c> taskSetupList, 
                                    List<String> appListToCreateTask){
        
        List<Task> masterTaskList = new List<Task>();
        //Get the Department Id 
        String departmentId = [SELECT Id FROM genesis__Department__c WHERE Name  = 'Credit'].Id;
        // appListToCreateTask contains all the applications that need to get their tasks created
        for(integer iterator = 0; iterator<appListToCreateTask.size(); iterator++){
            integer count = 1;
            for (genesis__Task_Setup__c eachTaskSetup : taskSetupList){
                Task eachTask = new Task();
                //DEPARTMENT - CREDIT
                eachTask.genesis__Department__c = departmentId;//Dev - a7R74000000GhxGEAS, Prod - a7R5f000000coIfEAI
                //APPLICATION
                eachTask.WhatId = appListToCreateTask[iterator];
                eachTask.genesis__Application__c = appListToCreateTask[iterator];

                //SUBJECT - Task Name
                eachTask.Subject = eachTaskSetup.genesis__Task_Name__c;
                eachtask.Description = eachTaskSetup.genesis__Task_Name__c;
                eachTask.genesis__Task_Setup__c = eachTaskSetup.Id;

                eachTask.genesis__Completion_Mandatory__c = false;
                eachTask.genesis__Is_Archived__c = false;
                eachTask.genesis__Is_Parallel__c = false;

                eachTask.genesis__Task_Order__c = count;
                count++;
                masterTaskList.add(eachTask);
            }
        }
        Database.insert(masterTaskList,true);
    }
}