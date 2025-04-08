/**
 * @description       : Batch class to Fetch Loan Details
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 02-04-2025
 * @last modified by  : Ayan Bhowmik
**/
global with sharing class NLSGetLoanCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public static final String CLASS_NAME = 'NLSGetLoanCalloutBatch';
    public static final String APPLICATION_KEY = 'applicationIdList';
    /**
    * @description : Batch Query for Active Applications
    * @author  Pritam Roy | 03-11-2024 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT id 
                                            FROM genesis__Applications__c 
                                            WHERE genesis__Status__c = :ConstantValues.ACTIVE
                                            AND Loan_Id__c != null]);
    }
    /**
    * @description : Calling the Integration Framework
    * @author  Pritam Roy | 03-11-2024 
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
            queryIdMap.put(APPLICATION_KEY, applicationIdList);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                ConstantValues.INTEGRATION_API_TYPE_GET_LOAN,
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
    * @description : Finish method calls NLSFetchParticipantIdBatch
    * @author  Pritam Roy | 03-11-2024 
    * @param bc 
    **/
    global void finish(Database.BatchableContext bc){
        //The Sync of the Parent and Child Loans end here.
        NLSEvaluatePastDueBatch objEvaluatePastDueAccount = new NLSEvaluatePastDueBatch();
        Database.executeBatch(objEvaluatePastDueAccount , 40);
    }
}