/**
 * @description       : This batch is use to fetch the participant id by calling the integration framework.
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 08-10-2024
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   19-10-2022   Subham Nandi   Initial Version
**/
global without sharing class NLSFetchParticipantIdBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    String loanIdQuery;
    Boolean isParent;
    String childAppId;
    public static final String ACTIVE_STATUS = ConstantValues.ACTIVE;
    public static final String CLASS_NAME = 'NLSFetchParticipantIdBatch';
    public static final String LOAN_TYPE_KEY = 'loanType';
    public static final String PARENT_KEY = 'Parent';
    public static final String CHILD_KEY = 'Child';
    public static final String PRICING_ID_KEY = 'pricingId';

    
    String applicationId;
    /**
    * @description Constructor to fetch all the id of the application's pricing detail whose app status is closed or active
    * @author Subham Nandi 
    * @param isParentLoan 
    **/
    public NLSFetchParticipantIdBatch(Boolean isParentLoan) {
        this.isParent = isParentLoan;
        if(isParentLoan){
            loanIdQuery = 'SELECT Id '+
                            'FROM genesis__Application_Pricing_Detail__c '+
                            'WHERE genesis__Application__r.genesis__Status__c IN (\'ACTIVE\', \'CLOSED\') AND '+
                                    'genesis__Application__r.Participant_Id__c = null AND '+
                                    'genesis__Application__r.Loan_Id__c != null';
        }
        else{
            loanIdQuery = 'SELECT Id '+
                            'FROM genesis__Application_Pricing_Detail__c '+
                            'WHERE genesis__Application__r.genesis__Status__c IN (\'ACTIVE\', \'CLOSED\') AND '+
                            'Participant_Id__c = null AND '+
                            'Loan_Id__c != null';
        }
    }

    /**
    * @description This start method is use to return all the loanIdQuery
    * @author Subham Nandi 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext bc){
        //queries the principals
        return Database.getQueryLocator(loanIdQuery);
    }

    /**
    * @description This execute method is used to call integration framework.
    * @author Subham Nandi 
    * @param bc 
    * @param loanIdList 
    **/
    global void execute(Database.BatchableContext bc, List<genesis__Application_Pricing_Detail__c> loanIdList){
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
    * @description Calling AccrualStatus Batch for Parent or LoanDetails batch for child loans
    * @author Subham Nandi | 26-03-2024 
    * @param bc 
    **/
    global void finish(Database.BatchableContext bc){
        if(isParent){
            //Get the Accrual Status for the Parent Applications
            NLSLoanStatusesCalloutBatch getAccrualStatus = new NLSLoanStatusesCalloutBatch();
            Database.executeBatch(getAccrualStatus , 1);
        }
        else{
            //Calls the loans/{loanId} API to get the status and parent loan details.
            NLSGetLoanCalloutBatch objParentLoanStatus = new NLSGetLoanCalloutBatch();
            Database.executeBatch(objParentLoanStatus , 40);
        }
    }
}