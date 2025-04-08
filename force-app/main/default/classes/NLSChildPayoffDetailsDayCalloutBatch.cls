/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-07-2024
 * @last modified by  :  Pritam Roy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   08-02-2023   Subham Nandi   Initial Version
**/
global with sharing class NLSChildPayoffDetailsDayCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.stateful{

    public static final String CLASS_NAME = 'NLSChildPayoffDetailsDayCalloutBatch';
    public static final String API_TYPE = 'Get Child Payoff Day API Type';
    public static final String APP_ID_LIST = 'applicationIdList';
    global List<String> childLoanNumberList = new List<String>();
    /**
    * @description : Batch Query to pick Active Applications
    * @author  Pritam Roy | 03-07-2024 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT id, Loan_Number__c, Principal_Advanced__c 
                                            FROM genesis__Application_Pricing_Detail__c
                                            WHERE genesis__Application__r.genesis__Status__c = :ConstantValues.ACTIVE AND
                                            Loan_ID__c != null AND
                                            genesis__Enabled_Flag__c = true AND Principal_Advanced__c != null AND 
                                            Principal_Advanced__c > 0]);
    }
    /**
    * @description : Call the Integration Framework
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
                childLoanNumberList.add(application.Loan_Number__c);
            }
            queryIdMap.put(APP_ID_LIST, applicationIdList);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                API_TYPE,
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
    * @description : Finish method to update funding transaction and pricing details
    * @author  Pritam Roy | 03-07-2024 
    * @param bc 
    **/
    global void finish(Database.BatchableContext bc){
        //Query all the Initiated Payments for the current batch and update the child loan details
        Map<String, Decimal> childLoanToInterestPaid = new Map<String,Decimal>();
        Map<String, Decimal> childLoanToInterestAccrued = new Map<String,Decimal>();
        List<String> updateChildLoanList = new List<String>();
        List<genesis__Application_pricing_Detail__c> childLoanListToUpdate = new List<genesis__Application_pricing_Detail__c>();
        List<genesis__Funding_Transaction__c> initiatedPaymentList = [SELECT Id,
                                                                            Interest_Paid__c,
                                                                            Pricing_Detail__c,
                                                                            Pricing_Detail__r.Accrued_Interest__c
                                                                        FROM genesis__Funding_Transaction__c 
                                                                        WHERE Pricing_Detail__r.Loan_Number__c IN :childLoanNumberList
                                                                        AND genesis__Cleared__c = true
                                                                        AND Posted_To_NLS__c = false
                                                                        AND genesis__Payment_Mode__r.Name = :ConstantValues.PAYMENT];
        if(initiatedPaymentList.size() > 0){
            for(genesis__Funding_Transaction__c eachPayment : initiatedPaymentList){
                if(childLoanToInterestPaid.containsKey(eachPayment.Pricing_Detail__c)){
                    //add the interest paid
                    Decimal interestPaidTemp = childLoanToInterestPaid.get(eachPayment.Pricing_Detail__c) + eachPayment.Interest_Paid__c;
                    childLoanToInterestPaid.put(eachPayment.Pricing_Detail__c,  interestPaidTemp);
                }
                else{
                    childLoanToInterestPaid.put(eachPayment.Pricing_Detail__c, eachPayment.Interest_Paid__c);
                    updateChildLoanList.add(eachPayment.Pricing_Detail__c);
                    childLoanToInterestAccrued.put(eachPayment.Pricing_Detail__c,eachPayment.Pricing_Detail__r.Accrued_Interest__c);
                }
            }
            for(String eachChildLoan : updateChildLoanList){
                genesis__Application_pricing_Detail__c childLoan = new genesis__Application_pricing_Detail__c(Id = eachChildLoan);
                childLoan.Accrued_Interest__c = childLoanToInterestAccrued.get(eachChildLoan) -  childLoanToInterestPaid.get(eachChildLoan);
                childLoanListToUpdate.add(childLoan);
            }
            Database.update(childLoanListToUpdate,true);
        }
    }
}