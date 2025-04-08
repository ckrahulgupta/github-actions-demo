/**
 * @description       : This callout class is called from scheduled class which runs at 1130 am
 * @author            : Rahul
 * @group             : 
 * @last modified on  : 02-04-2025
 * @last modified by  : Shristy Kumari
**/

global with sharing class NLSXMLImportMobileDepositCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public static final String CLASS_NAME = 'NLSXMLImportMobileDepositCalloutBatch';
    public static final String APPROVED_LIST ='approvedList';
    /**
    * @description gets all the funding transaction whose status is not void and payment method is mobile deposit
    * @author Soumik Pattanayak | 08-10-2024 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT id,
                                                genesis__Amount__c 
                                            FROM genesis__Funding_Transaction__c
                                            WHERE Posted_to_NLS__c = false
                                            AND Status__c != :ConstantValues.VOIDED_STATUS
                                            AND genesis__Payment_Mode__r.Name = :ConstantValues.MOBILE_DEPOSIT
                                            Order by Createddate asc]);
    }
    /**
    * @description calls the integration framework to send the request
    * @author Soumik Pattanayak | 08-10-2024 
    * @param bc 
    * @param fundingTransactionList 
    **/
    global void execute(Database.BatchableContext bc, List<genesis__Funding_Transaction__c> fundingTransactionList){
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        List<Id> mobileDepositIdList = new List<Id>();
        try {
            for(genesis__Funding_Transaction__c fundingTransactionObj: fundingTransactionList){
                mobileDepositIdList.add(fundingTransactionObj.Id);
            }
            if(mobileDepositIdList.size() > 0){
                queryIdMap.put(APPROVED_LIST, mobileDepositIdList);
            }
            requestParamMap.put(ConstantValues.PAYMENT_TYPE, ConstantValues.MOBILE_DEPOSIT);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = 
                            (intframework.BaseIntegrationResponse) baseIntegrationService.runSynchronousIntegrationService(
                                    ConstantValues.NLS_INTEGRATION_FAMILY,
                                    ConstantValues.INTEGRATION_API_TYPE_XML_IMPORT,
                                    queryIdMap,
                                    requestParamMap
                                );
            if(responseObject.getBody()==null){
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            }
        } 
        catch (CustomException objCustomException) {
            PortalHelper.saveExceptionLog(objCustomException, CLASS_NAME); 
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
    }
    /**
    * @description Generate the Batch Record which relates to this Draft
    * @author Soumik Pattanayak | 08-10-2024 
    * @param bc 
    **/
    global void finish(Database.BatchableContext bc){
        List<genesis__Funding_Transaction__c> updateBatchList = new List<genesis__Funding_Transaction__c>();
        List<genesis__Funding_Transaction__c> fundingTransactionDraft = [SELECT Id, 
                                                                                Batch__c,
                                                                                Posted_to_NLS__c,
                                                                                genesis__Amount__c,
                                                                                Posted_Date__c
                                                                        FROM genesis__Funding_Transaction__c
                                                                        WHERE genesis__Cleared__c = true 
                                                                        AND Posted_to_NLS__c = false 
                                                                        AND Status__c != :ConstantValues.VOIDED_STATUS
                                                                        AND genesis__Payment_Mode__r.Name = :ConstantValues.MOBILE_DEPOSIT];
        clcommon__Funding_Transactions_Properties__c objFundingPropertiesBatch = new clcommon__Funding_Transactions_Properties__c();
        objFundingPropertiesBatch.name = ConstantValues.MOBILE_DEPOSIT + '-' + System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF);
        objFundingPropertiesBatch.Payment_Mode__c = ConstantValues.MOBILE_DEPOSIT;
        objFundingPropertiesBatch.Batch_Total_Amount__c = 0;
        Database.insert(objFundingPropertiesBatch,true);
        for(genesis__Funding_Transaction__c fundingTransactionObj : fundingTransactionDraft){
            fundingTransactionObj.Batch__c = objFundingPropertiesBatch.Id;
            fundingTransactionObj.Posted_Date__c = System.today();
            //Populating the sum of all the Amount for each Mobile Deposit in the batch as a total Amount
            objFundingPropertiesBatch.Batch_Total_Amount__c = objFundingPropertiesBatch.Batch_Total_Amount__c + fundingTransactionObj.genesis__Amount__c;
            updateBatchList.add(fundingTransactionObj);
        }
        Database.update(objFundingPropertiesBatch,true);
        Database.update(updateBatchList,true);
    }
}