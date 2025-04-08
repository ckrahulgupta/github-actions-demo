/**
 * @description       : Schedulable class for NLSChildPayoffDetailsCalloutBatch
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  :  Pritam Roy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   20-05-2022   Subham Nandi   Initial Version
**/
public with sharing class NLSGetChildLoanDetailsSchedule implements Schedulable {
    /**
    * @description : Schedule NLSChildPayoffDetailsCallout Batch
    * @author  Pritam Roy | 03-11-2024 
    * @param ctx 
    **/
    public void execute(SchedulableContext ctx) {
        NLSChildPayoffDetailsCalloutBatch getChildPayOff = new NLSChildPayoffDetailsCalloutBatch();
        Database.executeBatch(getChildPayOff , 40);
    }
}