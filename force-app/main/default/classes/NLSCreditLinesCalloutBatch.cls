/**
 * @description       : Batch class for NLSCreditLinesCallout
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 02-02-2025
 * @last modified by  : Rahul Gorai
**/
global with sharing class NLSCreditLinesCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public static final String CLASS_NAME = 'NLSCreditLinesCalloutBatch';
    public static final String APPLICATION_KEY = 'applicationIdList';
    /**
    * @description : Batch query to pick active applications
    * @author  Pritam Roy | 03-08-2024 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT id 
                                            FROM genesis__Applications__c 
                                            WHERE genesis__Status__c = 'ACTIVE']);
    }
    /**
    * @description : Calling Integration Framework
    * @author  Pritam Roy | 03-08-2024 
    * @param bc 
    * @param activeApplicationList 
    **/
    global void execute(Database.BatchableContext bc, List<genesis__Applications__c> activeApplicationList){
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        List<Id> applicationIdList = new List<Id>();
        Integer startCpuTime = Limits.getCpuTime();
        try {
            for(genesis__Applications__c application: activeApplicationList){
                applicationIdList.add(application.Id);
            }
            queryIdMap.put(APPLICATION_KEY, applicationIdList);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                ConstantValues.INTEGRATION_API_TYPE_CREDIT_LINES,
                                                                                                                                queryIdMap, requestParamMap);
        } catch (Exception objException) {
            Database.insert(new clcommon__Log__c(Name = CLASS_NAME ,
                    clcommon__Message__c = CLASS_NAME 
                    + objException.getStackTraceString()
                    + objException.getMessage(),
                    clcommon__Time__c = System.Now()), false);
        }
        Integer endCpuTime = Limits.getCpuTime();
        Integer elapsedCpuTime = endCpuTime - startCpuTime;
        System.debug('elapsed time' + elapsedCpuTime);
        
    }
    /**
    * @description : Finish method to call NLSPayoffDetailsCalloutBatch
    * @author  Pritam Roy | 03-08-2024 
    * @param bc 
    **/
    global void finish(Database.BatchableContext bc){
       //Get the Participant Id for the Parent Applications
        NLSFetchParticipantIdBatch getParticipantIds = new NLSFetchParticipantIdBatch( true );
        Database.executeBatch(getParticipantIds , 40);
    }
}