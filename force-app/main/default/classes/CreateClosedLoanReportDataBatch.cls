/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 02-27-2024
 * @last modified by  : Ayan Bhowmik
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   03-03-2023   Subham Nandi   Initial Version
**/
global without sharing class CreateClosedLoanReportDataBatch implements Database.Batchable<sObject> {

    private String batchType;


    /**
    * @description Fetching data
    * @author Ayan Bhowmik | 02-27-2024 
    * @param batchableContext 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext batchableContext) {

        return Database.getQueryLocator([SELECT Id, 
                                                Pricing_Detail__c, 
                                                Month__c, 
                                                Year__c,
                                                External_Id__c,
                                                genesis__Application__c
                                        FROM genesis__Application_Fee_Payment__c 
                                        WHERE Pricing_Detail__c != null 
                                        AND genesis__Application__r.Pricing_Count__c > 1
                                        AND Record_Type__c = 'ACTIVE LOAN DAILY']);
        
    }


    /**
    * @description creating missing parent records for old child records
    * @author Ayan Bhowmik | 02-27-2024 
    * @param batchableContext 
    * @param childFeeRecords 
    **/
    global void execute(Database.BatchableContext batchableContext, List<genesis__Application_Fee_Payment__c> childFeeRecords) {

        try {

            Set<genesis__Application_Fee_Payment__c> newParentRecords = new Set<genesis__Application_Fee_Payment__c>();            

            for (genesis__Application_Fee_Payment__c childFeeRecord : childFeeRecords) {
                
                String parentExternalId = childFeeRecord.genesis__Application__c 
                                            + String.valueOf(childFeeRecord.External_Id__c)
                                                            .substring(String.valueOf(childFeeRecord.External_Id__c).indexOf('-'));
                genesis__Application_Fee_Payment__c parentFeeRecord = new genesis__Application_Fee_Payment__c();
                parentFeeRecord.External_Id__c = parentExternalId;
                parentFeeRecord.Month__c = childFeeRecord.Month__c;
                parentFeeRecord.Year__c = childFeeRecord.Year__c;
                parentFeeRecord.genesis__Application__c = childFeeRecord.genesis__Application__c;
                parentFeeRecord.Record_Type__c = 'ACTIVE LOAN DAILY';
                newParentRecords.add(parentFeeRecord);

            }
            Database.upsert(new List<genesis__Application_Fee_Payment__c>(newParentRecords), 
                            genesis__Application_Fee_Payment__c.External_Id__c,
                            false);
            
        } catch (DmlException objDmlException) {

            objDmlException.getDmlMessage(0);

        } catch (Exception objExcetion) {

        }

    }

    /**
    * @description Closed loans Monthly Callout batch from finish
    * @author Ayan Bhowmik | 02-27-2024 
    * @param batchableContext 
    **/
    global void finish(Database.BatchableContext batchableContext){
        NLSClosedLoanDetailsMonthlyCalloutBatch callMonthlyBatch = new NLSClosedLoanDetailsMonthlyCalloutBatch();
        Database.executeBatch(callMonthlyBatch, 40);

    }

    
}