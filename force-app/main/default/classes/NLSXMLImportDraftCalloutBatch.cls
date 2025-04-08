/**
 * @description       : This callout class is called from scheduled class which runs at 1130 am
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 12-23-2024
 * @last modified by  : Sk Minsar
**/

global with sharing class NLSXMLImportDraftCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    public static final String APPROVED_LIST ='approvedList';
    /**
    * @description selects funding transaction whos status is not voided and mode of payment is draft
    * @author Soumik Pattanayak | 08-10-2024 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT id,Status__c,
                                                genesis__Amount__c 
                                            FROM genesis__Funding_Transaction__c
                                            WHERE Posted_to_NLS__c = :ConstantValues.FALSE_VALUE
                                            AND Status__c != :ConstantValues.VOIDED_STATUS
                                            AND genesis__Payment_Mode__r.Name = :ConstantValues.DRAFT]);
    }
    /**
    * @description calls the integration framework to send the request
    * @author Soumik Pattanayak | 08-10-2024 
    * @param bc 
    * @param draftFundingTransacList 
    **/
    global void execute(Database.BatchableContext bc, List<genesis__Funding_Transaction__c> draftFundingTransacList){
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        List<Id> approvedDraftList = new List<Id>();
        List<genesis__Funding_Transaction__c> updateDraftFundToClrList = new List<genesis__Funding_Transaction__c>();
        try {
            for(genesis__Funding_Transaction__c objDraftFundTransac: draftFundingTransacList){
                approvedDraftList.add(objDraftFundTransac.Id);
                objDraftFundTransac.genesis__Cleared__c = ConstantValues.TRUE_VALUE;
                updateDraftFundToClrList.add(objDraftFundTransac);
            }
            if(approvedDraftList.size() > ConstantValues.ZERO_VALUE){
                queryIdMap.put(APPROVED_LIST, approvedDraftList);
            }
            requestParamMap.put(ConstantValues.PAYMENT_TYPE, ConstantValues.DRAFT);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                ConstantValues.INTEGRATION_API_TYPE_XML_IMPORT,
                                                                                                                                queryIdMap,
                                                                                                                                requestParamMap);
            if(responseObject.getBody()==null){
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            }
            Database.update(updateDraftFundToClrList,ConstantValues.TRUE_VALUE);
        } 
        catch (CustomException objCustomException) {
            PortalHelper.saveExceptionLog(objCustomException, NLSXMLImportDraftCalloutBatch.class.getName()); 
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, NLSXMLImportDraftCalloutBatch.class.getName());
        }
    }
    /**
    * @description Generate the Batch Record which relates to this Draft
    * @author Soumik Pattanayak | 08-10-2024 
    * @param bc 
    **/
    global void finish(Database.BatchableContext bc){
        List<genesis__Funding_Transaction__c> updateBatchList = new List<genesis__Funding_Transaction__c>();
        Set<Id> invoiceIdSet = new Set<Id>();
        List<genesis__Funding_Transaction__c> fundingTransactionDraft = [SELECT Id, 
                                                                                Batch__c,
                                                                                Posted_to_NLS__c,
                                                                                genesis__Amount__c,
                                                                                Posted_Date__c,
                                                                                Invoice__c,
                                                                                Status__c
                                                                                FROM genesis__Funding_Transaction__c
                                                                        WHERE genesis__Cleared__c = :ConstantValues.TRUE_VALUE 
                                                                        AND Posted_to_NLS__c = :ConstantValues.FALSE_VALUE 
                                                                        AND Status__c != :ConstantValues.VOIDED_STATUS
                                                                        AND genesis__Payment_Mode__r.Name = :ConstantValues.DRAFT];

        clcommon__Funding_Transactions_Properties__c objFundingPropertiesBatch = new clcommon__Funding_Transactions_Properties__c();
        objFundingPropertiesBatch.name = ConstantValues.DRAFT + ConstantValues.HYPHEN_STRING + System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF);
        objFundingPropertiesBatch.Payment_Mode__c = ConstantValues.DRAFT;
        objFundingPropertiesBatch.Batch_Total_Amount__c = ConstantValues.ZERO_VALUE;
        Database.insert(objFundingPropertiesBatch,ConstantValues.TRUE_VALUE);
        for(genesis__Funding_Transaction__c objDraftFundTransac : fundingTransactionDraft){
            objDraftFundTransac.Batch__c = objFundingPropertiesBatch.Id;
            objDraftFundTransac.Posted_to_NLS__c = ConstantValues.TRUE_VALUE;
            objDraftFundTransac.Status__c = ConstantValues.STATUS_POSTED;
            objDraftFundTransac.Posted_Date__c = System.now();
            //Populating the sum of all the Amount for each Draft in the batch as a total Amount
            objFundingPropertiesBatch.Batch_Total_Amount__c = objFundingPropertiesBatch.Batch_Total_Amount__c + objDraftFundTransac.genesis__Amount__c;
            updateBatchList.add(objDraftFundTransac);
            invoiceIdSet = PaymentInvoiceHelper.addInvoiceIdSet(objDraftFundTransac.Invoice__c, invoiceIdSet);
        }
        Database.update(objFundingPropertiesBatch,ConstantValues.TRUE_VALUE);
        Database.update(updateBatchList,ConstantValues.TRUE_VALUE);
        PaymentInvoiceHelper.updateInvoiceStatus(new List<Id>(invoiceIdSet), ConstantValues.STATUS_POSTED);
    }
}