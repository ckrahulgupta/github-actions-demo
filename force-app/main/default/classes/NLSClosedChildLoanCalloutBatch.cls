/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-07-2024
 * @last modified by  :  Pritam Roy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   02-03-2023   Subham Nandi   Initial Version
**/
global with sharing class NLSClosedChildLoanCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public static final String CLASS_NAME = 'NLSClosedChildLoanCalloutBatch';
    public static final String APPLICATION_ID_STRING = 'applicationIdList';
    /**
    * @description : Batch Query to pick Closed Applications
    * @author  Pritam Roy | 03-07-2024 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT id 
                                            FROM genesis__Application_Pricing_Detail__c 
                                            WHERE genesis__Application__r.genesis__Status__c = :ConstantValues.CLOSED AND
                                            Loan_Id__c != null]);
    }
    /**
    * @description : Calling the Integration Framework
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
    * @description : Finish method to call NLSClosedParticipantIdBatch
    * @author  Pritam Roy | 03-07-2024 
    * @param bc 
    **/
    global void finish(Database.BatchableContext bc){
        //fetch Participant Id for Closed Child Loans
        NLSClosedParticipantIdBatch getParticipantIdForChildLoans = new NLSClosedParticipantIdBatch( false );
        Database.executeBatch(getParticipantIdForChildLoans, 40);
    }
}