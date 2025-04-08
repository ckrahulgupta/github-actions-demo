/**
 * @description       : 
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  :  Pritam Roy
**/

global with sharing class NLSGetChildLoanCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public static final String CLASS_NAME = 'NLSGetChildLoanCalloutBatch';
    public static final String APPLICATION_ID_STRING = 'applicationIdList';
    /**
    * @description : Batch query to pick active applications
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
                                                                                                                                ConstantValues.INTEGRATION_API_TYPE_GET_CHILD_LOAN,
                                                                                                                                queryIdMap, requestParamMap);
        } catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
    }
    /**
    * @description : Finish method calls NLSGetChildLoanPayoffViaMailBatch
    * @author  Pritam Roy | 03-11-2024 
    * @param bc 
    **/
    global void finish(Database.BatchableContext bc){
        //will call another batch to store Pay Via US Mail, with a payoff date as 10 days ahead
        NLSGetChildLoanPayoffViaMailBatch getChildLoanbatch = new NLSGetChildLoanPayoffViaMailBatch();
        Database.executeBatch(getChildLoanbatch , 40);
    }
}