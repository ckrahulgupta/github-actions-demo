/**
 * @description       : Batch class for NLSPayoffDetailsCallout
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  : Simran
**/
global with sharing class NLSPayoffDetailsCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public static final String CLASS_NAME = 'NLSPayoffDetailsCalloutBatch';

    /**
    * @description This start method is used to get all the ids of active applications.
    * @author Simran | 03-11-2024 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT id 
                                            FROM genesis__Applications__c 
                                            WHERE genesis__Status__c = 'ACTIVE']);
    }

    /**
    * @description This execute method is used to call the NLS integration framework
    * @author Simran | 03-11-2024 
    * @param bc 
    * @param activeApplicationList 
    **/
    global void execute(Database.BatchableContext bc, List<genesis__Applications__c> activeApplicationList){
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        List<Id> applicationIdList = new List<Id>();
        try {
            for(genesis__Applications__c application: activeApplicationList){
                applicationIdList.add(application.Id);
            }
            queryIdMap.put('applicationIdList', applicationIdList);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                ConstantValues.INTEGRATION_API_TYPE_PAYOFF_DETAILS,
                                                                                                                                queryIdMap, requestParamMap);
        } catch (Exception objException) {
            Database.insert(new clcommon__Log__c(Name = CLASS_NAME ,
                    clcommon__Message__c = CLASS_NAME 
                    + objException.getStackTraceString()
                    + objException.getMessage(),
                    clcommon__Time__c = System.Now()), false);
        }
    }

    /**
    * @description This finish method is used to call the NLSGetLoanCalloutBatch class
    * @author Simran | 03-11-2024 
    * @param bc 
    **/
    global void finish(Database.BatchableContext bc){
        NLSGetLoanCalloutBatch getLoanbatch = new NLSGetLoanCalloutBatch();
        Database.executeBatch(getLoanbatch,40);
    }
}