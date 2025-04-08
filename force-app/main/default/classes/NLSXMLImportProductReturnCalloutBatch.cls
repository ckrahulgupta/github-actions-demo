/**
 * @description       : Callout class to fetch all the Product Return request and post them to the NLS.
 * @author            : Simran
 * @group             : 
 * @last modified on  : 02-04-2025
 * @last modified by  : Shruti Tamakhuwala
**/
public with sharing class NLSXMLImportProductReturnCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts,Database.Stateful{
    //Constants specific to the class
    private static final String CLASS_NAME = 'NLSXMLImportProductReturnCalloutBatch';
    private static final String APPROVED_LIST ='approvedList';
    //Constants specific to the class

    List<genesis__Funding_Transaction__c> fundingTransactionsList = new List<genesis__Funding_Transaction__c>();

    /**
     * @description This method used to query all the product return funding transaction
     * @param bc 
     * @return  `Database.QueryLocator`
     */
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,Status__c,genesis__Application__c
                                            FROM genesis__Funding_Transaction__c 
                                            WHERE genesis__cleared__c=true 
                                            AND Posted_to_NLS__c=false 
                                            AND Status__c != :ConstantValues.VOIDED_STATUS
                                            AND genesis__Payment_Mode__r.Name=:ConstantValues.PRODUCT_RETURN]);
    }

    /**
     * @description This method used to do callout to post the funding transaction to NLS
     * @param bc 
     * @param objProductReturnList 
     * @exception 
     */
    public void execute(Database.BatchableContext bc, List<genesis__Funding_Transaction__c> objProductReturnList){
        Map<String,Object> requestParamMap= new Map<String,Object>();
        Map<String,Object> queryIdMap= new Map<String,Object>();
        List<Id> approvedProductReturnId= new List<Id>();
        try{
            for(genesis__Funding_Transaction__c productReturnId:objProductReturnList){
                approvedProductReturnId.add(productReturnId.Id);
            }
            queryIdMap.put(APPROVED_LIST,approvedProductReturnId);
            requestParamMap.put(ConstantValues.PAYMENT_TYPE,ConstantValues.PRODUCT_RETURN);
            //Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject= (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                            ConstantValues.INTEGRATION_API_TYPE_XML_IMPORT,
                                                                                                                            queryIdMap,
                                                                                                                            requestParamMap);
            if(responseObject.getBody()==null){
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            }
            for(genesis__Funding_Transaction__c productReturn:objProductReturnList){
                fundingTransactionsList.add(productReturn);
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
     * @description This method used to update credit total draw limit of  pplication 
     * @param bc 
     */
    public void finish(Database.BatchableContext bc){
        List<String> fundingTransactionIdList = new List<String>();
        for(genesis__Funding_Transaction__c fundingTransaction : this.fundingTransactionsList){
            fundingTransactionIdList.add(fundingTransaction.id);
        }
        if(!Test.isRunningTest()){
            NLSUpdateCreditDrawLimitCalloutBatch creditDrawLimit = new NLSUpdateCreditDrawLimitCalloutBatch(fundingTransactionIdList);
            Database.executeBatch(creditDrawLimit,1);
        }
    }
    
}