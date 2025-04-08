/**
 * @description       : This shcedulable class makes callout at EOD and syncs up all the active parent loans
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  :  Pritam Roy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   19-05-2022   Subham Nandi   Initial Version
**/
public with sharing class NLSGetParentLoanDetailsSchedule implements Schedulable {
    /**
    * @description : Schedule NLSLoanDetailsCallout Batch
    * @author  Pritam Roy | 03-11-2024 
    * @param ctx 
    **/
    public void execute(SchedulableContext ctx) {
        NLSLoanDetailsCalloutBatch getParentLoanDetails = new NLSLoanDetailsCalloutBatch ();
        Database.executeBatch(getParentLoanDetails , 40);
    }
}