/**
 * @description       : Use to fetch the end of month and end of year interest from NLS for each loan
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 03-14-2024
 * @last modified by  : Simran
**/
public with sharing class NLSGetParticipantStatisticsCalloutBatch 
                    implements Database.Batchable<sObject>, Database.AllowsCallouts {

    // constants
    private static final String API_TYPE = 'Participant Loan Statistics API Type';
    
    // class variables
    private List<Id> ids;
    private Type idsType;

    /**
     * @description Default constructor
     * @author Simran | 02-05-2024 
     */
    public NLSGetParticipantStatisticsCalloutBatch() {
        this.ids = null;
        this.idsType = null;
    }

    /**
     * @description parameterized constructor
     * @author Simran | 02-05-2024 
     * @param ids 
     * @param idsType 
     */
    public NLSGetParticipantStatisticsCalloutBatch(List<Id> ids, Type idsType) {
        this.ids = ids;
        this.idsType = idsType;
    }
    
    /**
    * @description Sets the required ids of the sobject to be used for fetching the data
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
                            Participant_Id__c,
                            genesis__Application__r.Participant_Id__c
                    FROM genesis__Application_Pricing_Detail__c
                    WHERE genesis__Enabled_Flag__c = true
                    AND Participant_Id__c != null
                    AND (genesis__Application__r.genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                    OR genesis__Application__r.Pay_Off_Date__c = LAST_MONTH
                    OR (Dealer_Interest_Accrued__c != 0))
                ]
            );
    }
    
    /**
    * @description It is use to call the nls integration framework
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

            // for (genesis__Application_Pricing_Detail__c pricing : chunk) {
            //     chunkIds.add(pricing.Id);
            // }

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
                                                NLSGetParticipantStatisticsCalloutBatch.class, 
                                                batchableContext.getJobId(), 
                                                objException
                                            );

            objAsyncLogWrapper.logString = String.join(chunkIds, ', ');
            
            AsyncHelper.logBatchJobException(objAsyncLogWrapper);
        }
    }
    
    /**
    * @description Finish method of batchable class
    * @author Simran | 03-14-2024 
    * @param batchableContext 
    **/
    public void finish(Database.BatchableContext batchableContext) {}
}