/**
 * @description       : This class is called when draft is Cleared manually from global buttons
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-07-2024
 * @last modified by  :  Pritam Roy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   14-06-2022   Subham Nandi   Initial Version
**/
global with sharing class NLSClearDrafts {
    /**
    * @description : Invocable method called from Clear Draft Global Action
    * @author  Pritam Roy | 03-07-2024 
    **/
    @invocableMethod(label = 'InitiateDRAFTForClearing')
    global static void clearAllDRAFTS(){
        List<genesis__Funding_Transaction__c> updatedFundingTransactionList = new List<genesis__Funding_Transaction__c>();
        List<genesis__Funding_Transaction__c> fundingTransactionList = [SELECT  Id,
                                                                                genesis__Amount__c
                                                                        FROM genesis__Funding_Transaction__c
                                                                        WHERE genesis__Cleared__c = false
                                                                        AND Posted_to_NLS__c = false
                                                                        AND genesis__Payment_Mode__r.Name =:ConstantValues.DRAFT];
            //Create the batch for the list of ACH that will get posted after this class clears all the ACH
            clcommon__Funding_Transactions_Properties__c objFundingPropertiesBatch = new clcommon__Funding_Transactions_Properties__c();
            objFundingPropertiesBatch.name = ConstantValues.DRAFT + '-' + System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF);
            objFundingPropertiesBatch.Payment_Mode__c = ConstantValues.DRAFT;
            objFundingPropertiesBatch.Batch_Total_Amount__c = 0;
            Database.insert(objFundingPropertiesBatch,true);
        for(genesis__Funding_Transaction__c objFundingTransaction: fundingTransactionList){
            objFundingTransaction.genesis__Cleared__c = true;
            objFundingTransaction.Batch__c = objFundingPropertiesBatch.Id;
            objFundingPropertiesBatch.Batch_Total_Amount__c = objFundingPropertiesBatch.Batch_Total_Amount__c + objFundingTransaction.genesis__Amount__c;
            updatedFundingTransactionList.add(objFundingTransaction);
        }
        Database.update(objFundingPropertiesBatch,true);
        if(updatedFundingTransactionList.size() > 0){
            Database.update(updatedFundingTransactionList,false);
        }
    }
}