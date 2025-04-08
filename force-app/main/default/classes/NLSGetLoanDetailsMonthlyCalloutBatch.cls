/**
 * @description       : Used to fetch the loan details from NLS for each loan
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 04-08-2025
 * @last modified by  : Tuhin Bhunia
**/
public with sharing class NLSGetLoanDetailsMonthlyCalloutBatch 
                    implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    // public static final String CLASS_NAME = 'NLSGetLoanDetailsMonthlyCalloutBatch';
    public static final String API_TYPE = 'NLS Get Loan Details Monthly API Type';
    
    // class variables
    private List<Id> ids;
    private Type idsType;
    private String errorIds;

    /**
     * @description Default constructor
     * @author Simran | 02-05-2024 
     */
    public NLSGetLoanDetailsMonthlyCalloutBatch() {
        this.ids = null;
        this.idsType = null;
    }

    /**
     * @description parameterized constructor
     * @author Simran | 02-05-2024 
     * @param ids 
     * @param idsType 
     */
    public NLSGetLoanDetailsMonthlyCalloutBatch(List<Id> ids, Type idsType) {
        this.ids = ids;
        this.idsType = idsType;
    }
    
    /**
    * @description It returns the application pricing detail records
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
                    AND genesis__Application__r.Loan_Id__c != null
                    AND genesis__Application__r.genesis__Loan_Number__c IN ('350277002', '347356001')
                    AND (genesis__Application__r.genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                    OR genesis__Application__r.Pay_Off_Date__c = LAST_MONTH
                    OR (Dealer_Interest_Accrued__c != 0))
                ]
            );
    }

    /**
    * @description To fetch all the loan details by calling the integration framework.
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
                                                NLSGetLoanDetailsMonthlyCalloutBatch.class, 
                                                batchableContext.getJobId(), 
                                                objException
                                            );

            objAsyncLogWrapper.logString = String.join(chunkIds, ', ');
            
            AsyncHelper.logBatchJobException(objAsyncLogWrapper);
            errorIds = String.join(chunkIds, ', ');
        }
    }

    /**
    * @description finish method of batchable class
    * @author Simran | 03-14-2024 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc) {
    }
}