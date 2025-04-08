/**
 * @description       : Batch class for NLSClosedParticipant
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-08-2024
 * @last modified by  :  Pritam Roy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   03-03-2023   Subham Nandi   Initial Version
**/
global without sharing class NLSClosedParticipantIdBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    String loanIdQuery;
    Boolean isParent;
    String childAppId;
    public static final String CLOSE_STATUS = ConstantValues.CLOSED;
    public static final String CLASS_NAME = 'NLSFetchParticipantIdBatch';
    public static final String LOAN_TYPE_KEY = 'loanType';
    public static final String PARENT_KEY = 'Parent';
    public static final String CHILD_KEY = 'Child';
    public static final String PRICING_ID_KEY = 'pricingId';

    
    String applicationId;
    /**
    * @description : Change query based on Parent and Child loan
    * @author  Pritam Roy | 03-08-2024 
    * @param isParentLoan 
    **/
    public NLSClosedParticipantIdBatch(Boolean isParentLoan) {
        this.isParent = isParentLoan;
        if(isParentLoan){
            loanIdQuery = 'SELECT Id '+
                            'FROM genesis__Application_Pricing_Detail__c '+
                            'WHERE genesis__Application__r.genesis__Status__c = :CLOSE_STATUS AND '+
                                    'genesis__Application__r.Participant_Id__c = null AND '+
                                    'genesis__Application__r.Loan_Id__c != null';
        }
        else{
            loanIdQuery = 'SELECT Id '+
                            'FROM genesis__Application_Pricing_Detail__c '+
                            'WHERE genesis__Application__r.genesis__Status__c = :CLOSE_STATUS AND '+
                            'Participant_Id__c = null AND '+
                            'Loan_Id__c != null';
        }
    }

    /**
    * @description : Batch Query to pick closed applications
    * @author  Pritam Roy | 03-08-2024 
    * @param BC 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext BC){
        //queries the principals
        return Database.getQueryLocator(loanIdQuery);
    }

    /**
    * @description : Calling the Integration Framework
    * @author  Pritam Roy | 03-08-2024 
    * @param BC 
    * @param loanIdList 
    **/
    global void execute(Database.BatchableContext BC, List<genesis__Application_Pricing_Detail__c> loanIdList){
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        List<String> applictionIdList = new List<String>();
        try {
            if(isParent){
                for(genesis__Application_Pricing_Detail__c application: loanIdList){
                    applictionIdList.add(application.Id);
                }
                requestParamMap.put(LOAN_TYPE_KEY,PARENT_KEY);
            }
            else{
                for(genesis__Application_Pricing_Detail__c application: loanIdList){
                    applictionIdList.add(application.Id);
                }
                requestParamMap.put(LOAN_TYPE_KEY,CHILD_KEY);
            }
            queryIdMap.put(PRICING_ID_KEY, applictionIdList);
            //Calling the integration framework 
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService('NLS Integration 2',
                                                                                                                            'Participants Id Integration API Type',
                                                                                                                            queryIdMap, 
                                                                                                                            requestParamMap);
        } catch (Exception objException) {
            Portalhelper.saveExceptionLog(objException, CLASS_NAME);
        }
    }

    /**
    * @description : Finish method to class batch based on parent and child loan
    * @author  Pritam Roy | 03-08-2024 
    * @param bc 
    **/
    global void finish(Database.BatchableContext bc){
        if(isParent){
            //Call the child Batch
            // Start Child Loans Batch
            NLSClosedChildPayoffCalloutBatch getChildLoans = new NLSClosedChildPayoffCalloutBatch();
            Database.executeBatch(getChildLoans, 40);
        }
        else{
            //Closed Child Loan Sync has ended
            //Call the Statistics endpoint for All Closed Loans
            NLSClosedLoanStatisticsCalloutBatch getLoanStatistics = new NLSClosedLoanStatisticsCalloutBatch();
            Database.executeBatch(getLoanStatistics, 40);
        }
    }
}