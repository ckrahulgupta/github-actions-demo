/**
 * @description       : This batch fetches the Child Loan Pay off details for 10 days ahead
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  :  Pritam Roy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   30-08-2022   Subham Nandi   Initial Version
**/
global with sharing class NLSGetChildLoanPayoffViaMailBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public static final String CLASS_NAME = 'NLSGetChildLoanPayoffViaMailBatch';
    public static final String APPLICATION_ID_STRING = 'applicationIdList';
    public static final String INTEGRATION_API_TYPE = 'NLS Get Child Loan Payoff Mail API Type';
    /**
    * @description : Batch Query to pick Active Applications
    * @author  Pritam Roy | 03-11-2024 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT id 
                                            FROM genesis__Application_Pricing_Detail__c 
                                            WHERE genesis__Application__r.genesis__Status__c = 'ACTIVE' AND
                                            Loan_Id__c != null AND
                                            genesis__Enabled_Flag__c = true]);
    }
    /**
    * @description : Calling the Integration Framework
    * @author  Pritam Roy | 03-11-2024 
    * @param bc 
    * @param activeApplicationList 
    **/
    global void execute(Database.BatchableContext bc, List<genesis__Application_Pricing_Detail__c> activeApplicationList){
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        List<Id> applicationIdList = new List<Id>();
        try {
            for(genesis__Application_Pricing_Detail__c application: activeApplicationList){
                applicationIdList.add(application.Id);
            }
            queryIdMap.put(APPLICATION_ID_STRING, applicationIdList);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                INTEGRATION_API_TYPE,
                                                                                                                                queryIdMap, requestParamMap);
        } catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
    }
    /**
    * @description : Finish method calls NLSParticipantsGetChildLoanCalloutBatch
    * @author  Pritam Roy | 03-11-2024 
    * @param bc 
    **/
    global void finish(Database.BatchableContext bc){
        // fetch Dealer Interest Rates and Fees
        NLSParticipantsGetChildLoanCalloutBatch getChildPayOff = new NLSParticipantsGetChildLoanCalloutBatch();
        Database.executeBatch(getChildPayOff , 40);
    }
}