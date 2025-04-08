/**
 * @description       : This batch get  called from EOMEmailNotificationToGrowerBatch which update the app field when Email is sent to grower
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 04-04-2024
 * @last modified by  : Ayush Kumar Singh
**/
public with sharing class EOMUpdateApplicationFieldBatch implements Database.Batchable<genesis__Applications__c>, Database.AllowsCallouts {
    List<genesis__Applications__c> applicationList;

    /**
     * @description : This constructor recieves the application list which need to be updated
     * @param appList 
     */
    public EOMUpdateApplicationFieldBatch(List<genesis__Applications__c> appList) {
        this.applicationList = appList;
    }

    /**
     * @description This method return the list of application
     * @param batchableContext 
     * @return  `Iterable<String>`
     */
    public Iterable<genesis__Applications__c> start(Database.BatchableContext batchableContext){
        return applicationList;
    }

    /**
     * @description This method update the application field Monthly_Statement_Sent__c when monthly email statement
     * @param batchableContext 
     * @param applicationList 
     */
    public void execute(Database.BatchableContext batchableContext, List<genesis__Applications__c> applicationList){
        try{
            Date todayDate = System.today();
            String currentYear = String.valueOf(todayDate.year());
            String currentMonth = String.valueOf(todayDate.month());
            String currentDate = currentYear + currentMonth;
            for(genesis__Applications__c app : applicationList){
                app.Monthly_Statement_Sent__c = currentDate;
            }
            Database.update(applicationList,true);
        }
        catch (Exception objException) {
            LoggingUtility.saveExceptionLogging(objException, EOMUpdateApplicationFieldBatch.class.getName());
        }
    }

   
    /**
    * @description This is finish method after the code get executed
    * @param batchableContext 
    **/
    public void finish(Database.BatchableContext batchableContext) {}
}