/**
 * @description       : Batch class for NLSParticipantsGetChildLoanCalloutBatch
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  : Simran
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   02-06-2022   Subham Nandi   Initial Version
**/
global with sharing class NLSParticipantsGetChildLoanCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public static final String CLASS_NAME = 'NLSParticipantsGetChildLoanCalloutBatch';

    /**
    * @description This start method is used to get all the application's pricing detail whose application status is active or closed and enabled flag is true.
    * @author Simran | 03-11-2024 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT id ,
                                                Loan_Id__c
                                            FROM genesis__Application_Pricing_Detail__c 
                                            WHERE genesis__Application__r.genesis__Status__c IN ('ACTIVE', 'CLOSED')
                                            AND genesis__Enabled_Flag__c = true
                                            AND Loan_Id__c != null]);
    }

    /**
    * @description This execute method is used to call the NLS integration 'Participants Get Loan Integration API Type'
    * @author Simran | 03-11-2024 
    * @param bc 
    * @param activeApplicationList 
    **/
    global void execute(Database.BatchableContext bc, List<genesis__Application_Pricing_Detail__c> activeApplicationList){
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        List<String> applicationIdList = new List<String>();
        try {
            for(genesis__Application_Pricing_Detail__c application: activeApplicationList){
                applicationIdList.add(application.id);
            }
            queryIdMap.put('pricingId', applicationIdList);
            System.debug('===============> ' + queryIdMap);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                'Participants Get Loan Integration API Type',
                                                                                                                                queryIdMap, requestParamMap);
            System.debug('=========> ' + responseObject);
        } catch (Exception objException) {
            Portalhelper.saveExceptionLog(objException, CLASS_NAME);
        }
    }

    /**
    * @description This finish method is used to call NLSFetchParticipantIdBatch class
    * @author Simran | 03-11-2024 
    * @param bc 
    **/
    global void finish(Database.BatchableContext bc){
        //Get the Participant Ids for all the Child Loans
        NLSFetchParticipantIdBatch getParticipantIds = new NLSFetchParticipantIdBatch( false );
        Database.executeBatch(getParticipantIds , 40);
    }
}