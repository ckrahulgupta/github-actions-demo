/**
 * @description       : Fetches The Loan Accrual Status for the parent loans
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  : Tuhin Bhunia
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   14-01-2023   Subham Nandi   Initial Version
**/
global with sharing class NLSLoanStatusesCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public static final String CLASS_NAME = 'NLSLoanStatusesCalloutBatch';
    public static final String API_TYPE = 'NLSGetLoanStatusesAPIType';

    /**
     * @description : NLSLoanStatusesCalloutBatch start method.
     * @param bc 
     * @return  `Database.QueryLocator`
     */
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT id 
                                            FROM genesis__Applications__c 
                                            WHERE genesis__Status__c = 'ACTIVE'
                                            AND Loan_Id__c != null]);
    }

    /**
     * @description : NLSLoanStatusesCalloutBatch execute method.
     * @param bc 
     * @param activeApplicationList 
     */
    global void execute(Database.BatchableContext bc, List<genesis__Applications__c> activeApplicationList){
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        List<Id> applicationIdList = new List<Id>();
        try {
            for(genesis__Applications__c application: activeApplicationList){
                applicationIdList.add(application.Id);
            }
            queryIdMap.put('applicationIdList', applicationIdList);
            System.debug('===============> ' + queryIdMap);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                API_TYPE,
                                                                                                                                queryIdMap, requestParamMap);
            System.debug('=========> ' + responseObject);
        } catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
    }

    /**
     * @description : NLSLoanStatusesCalloutBatch finish method.
     * @param bc 
     */
    global void finish(Database.BatchableContext bc){
        
    }
}