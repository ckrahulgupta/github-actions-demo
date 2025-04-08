/**
 * @description       : This class is used to call the NLSClosedLoanDetailsCalloutBatch to Sync all the closed loans
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-12-2024
 * @last modified by  : Suraj Kumar
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   01-03-2023   Subham Nandi   Initial Version
**/
public with sharing class SyncAllClosedLoans {
    /**
    * @description : This method is used to call the NLSClosedLoanDetailsCalloutBatch to Sync all the closed loans
    * @author Suraj Kumar | 03-12-2024 
    * @return String 
    **/
    @AuraEnabled
    public static String callBatchForClosedLoans() {
        //Call the batch Classes
        //Call Closed Parent Loans Batch
        NLSClosedLoanDetailsCalloutBatch getParentLoans = new NLSClosedLoanDetailsCalloutBatch();
        Database.executeBatch(getParentLoans, 40);
        
        return 'Success';
    }
}