/**
 * @description       : Used to fetch the end of month and end of year interest from NLS for each loan
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 04-08-2025
 * @last modified by  : Tuhin Bhunia
**/

public with sharing class NLSGetLoanStatisticsCalloutBatch 
                        implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    // private static final String CLASS_NAME = 'NLSGetLoanStatisticsCalloutBatch';
    private static final String API_TYPE = 'Loan Statistics API Type';

    // class variables
    private List<Id> ids;
    private Type idsType;
    private String errorIds;
    private Boolean isChaining;

    /**
     * @description Default constructor
     * @author Simran | 02-05-2024 
     */
    public NLSGetLoanStatisticsCalloutBatch() {
        this.ids = null;
        this.idsType = null;
        this.isChaining = true;
    }

    /**
     * @description parameterized constructor
     * @author Simran | 02-05-2024 
     * @param ids 
     * @param idsType 
     * @param isChaining 
     */
    public NLSGetLoanStatisticsCalloutBatch(List<Id> ids, Type idsType, Boolean isChaining) {
        this.ids = ids;
        this.idsType = idsType;
        this.isChaining = isChaining;
    }
    
    /**
    * @description It returns the application pricing detail record
    * @author Simran | 03-14-2024 
    * @param batchableContext 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        if (ids != null && idsType != null) {
            if (idsType.equals(genesis__Applications__c.class)) {

                return Database.getQueryLocator(
                    [
                        SELECT Id, 
                               genesis__Application__c,
                               genesis__Application__r.Pricing_Count__c,
                               Participant_Id__c,
                               genesis__Application__r.Participant_Id__c
                        FROM genesis__Application_Pricing_Detail__c
                        WHERE genesis__Application__c IN :ids
                    ]
                );

            } else if (idsType.equals(genesis__Application_Pricing_Detail__c.class)) {

                return Database.getQueryLocator(
                    [
                        SELECT Id, 
                               genesis__Application__c,
                               genesis__Application__r.Pricing_Count__c,
                               Participant_Id__c,
                               genesis__Application__r.Participant_Id__c
                        FROM genesis__Application_Pricing_Detail__c
                        WHERE Id IN :ids
                    ]
                );

            } else {
                throw new CustomException('Operation not supported');
            }
        }

        return Database.getQueryLocator(
                [
                    SELECT Id, 
                           genesis__Application__c,
                           genesis__Application__r.Pricing_Count__c,
                           Participant_Id__c,
                           genesis__Application__r.Participant_Id__c
                    FROM genesis__Application_Pricing_Detail__c
                    WHERE genesis__Enabled_Flag__c = true
                    AND Loan_Id__c != null
                    AND genesis__Application__r.genesis__Loan_Number__c IN ('350277002', '347356001')
                    AND genesis__Application__r.Loan_Id__c != null
                    AND (genesis__Application__r.genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                    OR genesis__Application__r.Pay_Off_Date__c = LAST_MONTH)
                ]
            );
    }

    /**
    * @description It fetch the end of month and end of year interest by calling the integration framework.
    * @author Simran | 03-14-2024 
    * @param batchableContext 
    * @param chunk 
    **/
    public void execute(
                Database.BatchableContext batchableContext, 
                List<genesis__Application_Pricing_Detail__c> chunk
            ) {
        
        List<Id> chunkIds = new List<Id>();
       
        try {


            chunkIds = new List<Id>(new Map<Id, genesis__Application_Pricing_Detail__c>(chunk).keySet());

            Map<String, Object> queryIdMap = new Map<String, Object> {
                'loanIdList' => chunkIds
            };
            
            // Calling the integration framework
            intframework.AbstractIntegrationService baseIntegrationService = 
                                        intframework.IntegrationServiceFactory.getBaseIntegrationService();
            baseIntegrationService.runSynchronousIntegrationService(
                                                        ConstantValues.NLS_INTEGRATION_FAMILY,
                                                        API_TYPE,
                                                        queryIdMap,
                                                        new Map<String, Object>()
                                                );
                                        
        } catch (Exception objException) {
            AsyncHelper.AsyncLogWrapper objAsyncLogWrapper = 
                                    AsyncHelper.getAsyncLogWrapperInstance(
                                                NLSGetLoanStatisticsCalloutBatch.class, 
                                                batchableContext.getJobId(), 
                                                objException
                                            );

            objAsyncLogWrapper.logString = String.join(chunkIds, ', ');
            
            AsyncHelper.logBatchJobException(objAsyncLogWrapper);
            errorIds = String.join(chunkIds, ', ');
        }
    }

    /**
    * @description Finish method of batchable class
    * @author Simran | 03-14-2024 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {
        if(isChaining) {
            NLSGetLoanDetailsMonthlyCalloutBatch obj = new NLSGetLoanDetailsMonthlyCalloutBatch();
            Database.executeBatch(obj, 20);
        }
    }
}