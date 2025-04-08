/**
 * @description       : Schedulable class for NLSChildPayoffDetailsDayCalloutBatch
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  :  Pritam Roy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   08-02-2023   Subham Nandi   Initial Version
**/
public with sharing class NLSGetChildLoanDetailsDaySchedule implements Schedulable {
    /**
    * @description : Schecule NLSChildPayoffDetailsDayCallout Batch
    * @author  Pritam Roy | 03-11-2024 
    * @param ctx 
    **/
    public void execute(SchedulableContext ctx) {
        NLSChildPayoffDetailsDayCalloutBatch getChildPayOff = new NLSChildPayoffDetailsDayCalloutBatch();
        Database.executeBatch(getChildPayOff , 40);
    }
}