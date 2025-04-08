/**********************************************************************************************************************
 * @description       : The purpose of this batch class is to fetch all the unposted ACH requests and post them to NLS.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 04-02-2025
 * @last modified by  : Soumik Pattanayak
**********************************************************************************************************************/
public with sharing class NLSXMLImportACHCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    // parameters specific for this class [start]
    private static final String CLASS_NAME = 'NLSXMLImportACHCalloutBatch';
    private static final String APPROVED_LIST ='approvedList';
    private static final Integer BATCH_SIZE = Integer.valueOf(ConstantValues.NLS_IMPORT_BATCH_SIZE);
    // parameters specific for this class [end]
    
    /**
    * @description - Purpose of this method is to return all the ACH funding transactions which are not yet posted to NLS. 
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,Status__c 
                                         FROM genesis__Funding_Transaction__c
                                         WHERE genesis__Cleared__c = True 
                                         AND Posted_to_NLS__c = false
                                         AND Status__c != :ConstantValues.VOIDED_STATUS
                                         AND genesis__Payment_Mode__r.Name =: ConstantValues.ACH]);
    }
    /**
    * @description - This method acts as a callout method for NLS XML Import Integration.
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param bc 
    * @param achTransactionList 
    **/
    public void execute(Database.BatchableContext bc, List<genesis__Funding_Transaction__c> achTransactionList){
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        List<Id> approvedAchList = new List<Id>();
        try {
            for(genesis__Funding_Transaction__c achFundingTransaction: achTransactionList){
                approvedAchList.add(achFundingTransaction.Id);
            }
            queryIdMap.put(APPROVED_LIST, approvedAchList);
            requestParamMap.put(ConstantValues.PAYMENT_TYPE, ConstantValues.ACH);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService 
                    = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
			responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                            ConstantValues.INTEGRATION_API_TYPE_XML_IMPORT,
                                                                                                                            queryIdMap,
                                                                                                                            requestParamMap);
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
    * @description - Purpose of this method is to update all the ACH funding transactions which got posted to NLS, after that
    *                it calls the NLSXMLImportDraftCalloutBatch.
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc){
        
    }
}