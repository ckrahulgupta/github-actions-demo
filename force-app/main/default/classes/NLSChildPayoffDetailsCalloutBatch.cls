/**
 * @description       : 
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 02-04-2025
 * @last modified by  : Kabir Pramanik
**/

global with sharing class NLSChildPayoffDetailsCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public static final String CLASS_NAME = 'NLSChildPayoffDetailsCalloutBatch';
    /**
    * @description : Batch Query for NLSChildPayoffDetail
    * @author  Pritam Roy | 03-07-2024 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT id 
                                            FROM genesis__Application_Pricing_Detail__c
                                            WHERE genesis__Application__r.genesis__Status__c = 'ACTIVE' AND
                                            Loan_ID__c != null AND
                                            genesis__Enabled_Flag__c = true]);
    }
    /**
    * @description : Call Integration Framework
    * @author  Pritam Roy | 03-07-2024 
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
            queryIdMap.put('applicationIdList', applicationIdList);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                ConstantValues.INTEGRATION_API_TYPE_CHILD_PAYOFF_DETAILS,
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
    * @description : Calling NLSGetChildLoanCalloutBatch in Finish method 
    * @author  Pritam Roy | 03-07-2024 
    * @param bc 
    **/
    global void finish(Database.BatchableContext bc){
        NLSGetChildLoanCalloutBatch getChildLoanbatch = new NLSGetChildLoanCalloutBatch();
        Database.executeBatch(getChildLoanbatch , 40);
    }
}