/**
 * @description       : Batch class for NLSClosedParticipantStatsCallout
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-08-2024
 * @last modified by  :  Pritam Roy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   03-03-2023   Subham Nandi   Initial Version
**/
global with sharing class NLSClosedParticipantStatsCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    public static final String CLASS_NAME = 'NLSClosedParticipantStatsCalloutBatch';
    public static final String API_TYPE = 'Participant Loan Statistics API Type';
    
    /**
    * @description : Batch query to pick closed applications
    * @author  Pritam Roy | 03-08-2024 
    * @param batchableContext 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext batchableContext) {
  
        return Database.getQueryLocator([SELECT Id, 
                                                genesis__Application__c,
                                                Participant_Id__c,
                                                genesis__Application__r.Participant_Id__c
                                        FROM genesis__Application_Pricing_Detail__c
                                        WHERE genesis__Application__r.genesis__Status__c = :ConstantValues.CLOSED
                                        AND Loan_Id__c != null]);
    }
  
    /**
    * @description : Calling Integration Framework
    * @author  Pritam Roy | 03-08-2024 
    * @param batchableContext 
    * @param objApplicationPricingDetailList 
    **/
    global void execute(Database.BatchableContext batchableContext, List<genesis__Application_Pricing_Detail__c> objApplicationPricingDetailList){
        Map<String, Object> integrationConfigurationInput = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        List<Id> loanIdList = new List<Id>();
        try {
  
            Set<Id> childLoanIdList = new Set<Id>();
            Set<Id> parentLoanIdList = new Set<Id>();
  
            // create the child loan list
            for (genesis__Application_Pricing_Detail__c childLoan : objApplicationPricingDetailList) {
                if (childLoan.Participant_Id__c != null) {
                    childLoanIdList.add(childLoan.Id);
                }
                if (childLoan.genesis__Application__r.Participant_Id__c != null) {
                    parentLoanIdList.add(childLoan.genesis__Application__c);
                }
            }
            queryIdMap.put('childIdList', new List<Id>(childLoanIdList));
            queryIdMap.put('parentIdList', new List<Id>(childLoanIdList));
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
            responseObject = (intframework.BaseIntegrationResponse) 
                                baseIntegrationService.runSynchronousIntegrationService(
                                        ConstantValues.NLS_INTEGRATION_FAMILY,
                                        API_TYPE,
                                        queryIdMap,
                                        integrationConfigurationInput
                                );
            
                                        
        } catch (Exception objException) {
            // handle exception
            System.debug('--->>' + objException);
            // objException.printStackTrace();
        }
    }
    /**
    * @description : Finish method to call NLSClosedParticipantInterestCalloutBatch
    * @author  Pritam Roy | 03-08-2024 
    * @param bc 
    **/
    global void finish(Database.BatchableContext bc){
        // call Participant Interest Batch
        NLSClosedParticipantInterestCalloutBatch callparticipantInterest = new NLSClosedParticipantInterestCalloutBatch();
        Database.executeBatch(callparticipantInterest, 40);
    }
  }