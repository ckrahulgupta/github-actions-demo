/**********************************************************************************************************************
 * @description       : The purpose of this batch class is to fetch all the unposted PAYOFFS and post them to NLS.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 11-20-2023
 * @last modified by  :  Pritam Roy
**********************************************************************************************************************/

public with sharing class NLSXMLImportPayOffCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts
{

    // parameters specific for this class [start]
    private static final String CLASS_NAME = 'NLSXMLImportPayOffCalloutBatch';
    private static final String APPROVED_LIST ='approvedList';
    private static final String REPORT_NAME = ConstantValues.DEALER_ONLINE_PAYMENT_POSTED;
    private static final String FOLDER_NAME = ConstantValues.DEALER_ONLINE_PAYMENT_REPORTS;
    private static final String FOLDER_TYPE = 'Document';
    private static final String REPORT_EMAIL_SUBJECT = 'Dealer Online Payment Posted Report';
    // parameters specific for this class [end]

    /**
    * @description Purpose of this method is to return all the PAYMENT funding transactions which are not yet posted to NLS. 
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,Pay_Off__c,Status__c
                                        FROM genesis__Funding_Transaction__c
                                        WHERE genesis__Cleared__c = True 
                                        AND Posted_to_NLS__c = false 
                                        AND Status__c != :ConstantValues.VOIDED_STATUS
                                        AND genesis__Payment_Mode__r.Name =: ConstantValues.PAYMENT
                                        Order by createddate asc]);
    }
    /**
    * @description - This method acts as a callout method for NLS XML Import Integration.
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param bc 
    * @param fundingTransactionsList 
    **/
    public void execute(Database.BatchableContext bc, List<genesis__Funding_Transaction__c> fundingTransactionsList){
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        List<Id> approvedPaymentList = new List<Id>();
        try {
            for(genesis__Funding_Transaction__c paymentFundingTransaction: fundingTransactionsList){
                approvedPaymentList.add(paymentFundingTransaction.Id);
            }
            if(approvedPaymentList.size() > 0){
                queryIdMap.put(APPROVED_LIST, approvedPaymentList);
            }
            requestParamMap.put(ConstantValues.PAYMENT_TYPE, ConstantValues.PAYMENT);
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
        } catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
    }
    /**
    * @description - Purpose of this method is to update all the Payment funding transactions which got posted to NLS.
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc){
        //Query the report folder Id
        List<Report> reportList =  [SELECT  Id,
                                                Name 
                                        FROM Report 
                                        WHERE Name = :REPORT_NAME
                                        LIMIT 1];

        List<Folder> folderList =   [SELECT Id,
                                                Name 
                                        FROM Folder 
                                        WHERE Name = :FOLDER_NAME
                                        AND Type =: FOLDER_TYPE
                                        LIMIT 1];

        //Sending Daily Dealer Online Payment Posted Report
        GenerateDealerPaymentHandler.createDealerPaymentDocument((Id) String.valueOf(reportList[0].Id), (Id) String.valueOf(folderList[0].Id),REPORT_EMAIL_SUBJECT);
    }
}