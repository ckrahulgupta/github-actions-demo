/**
 * @description       : Batch Class for NLSClosedLoanDetailsCallout
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-08-2024
 * @last modified by  :  Pritam Roy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   02-03-2023   Subham Nandi   Initial Version
**/
global with sharing class NLSClosedLoanDetailsCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public static final String CLASS_NAME = 'NLSClosedLoanDetailsCalloutBatch';
    public static final String APPLICATION_ID_MAP = 'applicationIdList';
    /**
    * @description : Batch Query to Pick Closed Applications
    * @author  Pritam Roy | 03-08-2024 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT id 
                                            FROM genesis__Applications__c 
                                            WHERE genesis__Status__c = :ConstantValues.CLOSED AND 
                                            Loan_Id__c != null]);
    }
    /**
    * @description : Calling the Integration Framework
    * @author  Pritam Roy | 03-08-2024 
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
            queryIdMap.put(APPLICATION_ID_MAP, applicationIdList);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                ConstantValues.INTEGRATION_API_TYPE_LOAN_DETAILS,
                                                                                                                                queryIdMap, requestParamMap);
        } catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
    }
    /**
    * @description : Finish method calls NLSClosedCreditLinesCallout Batch
    * @author  Pritam Roy | 03-08-2024 
    * @param bc 
    **/
    global void finish(Database.BatchableContext bc){
        NLSClosedCreditLinesCalloutBatch creditLinesbatch = new NLSClosedCreditLinesCalloutBatch();
        Database.executeBatch(creditLinesbatch,40);
    }
}