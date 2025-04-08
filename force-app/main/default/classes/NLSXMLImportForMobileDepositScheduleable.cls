/**
 * @description       : This is a schedulable class which schedule a batch class for posting Mobile Deposits
 * @author            : Sanjana De
 * @group             : 
 * @last modified on  : 01-14-2025
 * @last modified by  : Kabir Pramanik
**/
public with sharing class NLSXMLImportForMobileDepositScheduleable implements Schedulable {
    
    /**
    * @description Execute method to call NLSXMLImportMobileDepositCalloutBatch class
    * @author Simran | 03-11-2024 
    * @param sc 
    **/
    public void execute(SchedulableContext sc) {
        if(PortalHelper.isTodayAWorkingDay(System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF))){
            NLSXMLImportMobileDepositCalloutBatch xmlimportBatchObj = new NLSXMLImportMobileDepositCalloutBatch();
            Database.executeBatch(xmlimportBatchObj , 1);
        }
        
    }
}