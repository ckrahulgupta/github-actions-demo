/**
 * @description       : This batch class is used to update the statement code.
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 03-07-2024
 * @last modified by  : Simran
**/
public with sharing class UpdateStatementCodeCalloutBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

    // constants
    private static final String LOAN_KEY = 'loanIdList';
    private static final String CLASS_NAME = 'UpdateStatementCodeCalloutBatch';
    private static final String API_TYPE = 'Statement Code API Type';
    private static final String ACTIVE = 'ACTIVE';
    private static final String NO_ACTIVE_LOANS = 'No active loans found under the maturity date.';

    private Date maturityDate;

    /**
    * @description Constructor for UpdateStatementCodeCalloutBatch
    * @author Rahul Gupta | 08-02-2023 
    * @param maturityDate //maturityDate Stores the maturity date passes from the UI
    **/
    public UpdateStatementCodeCalloutBatch(Date maturityDate) {
        this.maturityDate = maturityDate;
    }

    /**
    * @description This method return the application record.
    * @author Rahul Gupta | 08-02-2023 NLSXMLImportProductReturnCalloutBatchNLSXMLImportProductReturnCalloutBatch
    * @param batchableContext 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        try {
            Set<String> statementCodes = StatementCodeHelper.getOptOutStatementCodes();

            if (statementCodes == null || statementCodes.size() == 0) {
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }

            return Database.getQueryLocator([SELECT Id,
                                                    Pricing_Count__c
                                            FROM genesis__Applications__c 
                                            WHERE genesis__Status__c = :ACTIVE
                                            AND genesis__Loan_Number__c != null 
                                            AND Loan_Id__c != null
                                            AND genesis__Maturity_Date__c = :maturityDate
                                            AND Statement_Code__c IN :statementCodes]);

        } catch (Exception objException) {
            // handle exception
            AsyncHelper.AsyncLogWrapper objAsyncLogWrapper = 
                                    AsyncHelper.getAsyncLogWrapperInstance(
                                                UpdateStatementCodeCalloutBatch.class,
                                                batchableContext.getJobId(), 
                                                objException
                                            );
            
            AsyncHelper.logBatchJobException(objAsyncLogWrapper);
        }

        return null;
    }

    /**
    * @description This method is used to get application ids
    * @author Simran | 03-07-2024 
    * @param objApplications 
    * @return String 
    **/
    private static String getIdsFromApplications(List<genesis__Applications__c> objApplications) {
        String applicationIds = '';

        for (genesis__Applications__c objApplication : objApplications) {
            applicationIds += objApplication.Id + ', ';
        }

        return applicationIds;
    }

    /**
    * @description This execute method takes the application record and call the NLS integrations Framework to update the Statement code
    * @author Simran | 03-07-2024 
    * @param batchableContext 
    * @param objApplications 
    **/
    public void execute(Database.BatchableContext batchableContext, List<genesis__Applications__c> objApplications){
        Map<String, Object> queryIdMap = new Map<String, Object>();

        try {

            List<Id> loanIdList = new List<Id>();

            // create the child loan list
            for (genesis__Applications__c objApplication : objApplications) {
                loanIdList.add(objApplication.Id);
            }

            queryIdMap.put(LOAN_KEY, loanIdList);
            
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
            // handle exception
            AsyncHelper.AsyncLogWrapper objAsyncLogWrapper = 
                                    AsyncHelper.getAsyncLogWrapperInstance(
                                                UpdateStatementCodeCalloutBatch.class,
                                                batchableContext.getJobId(), 
                                                objException
                                            );
            objAsyncLogWrapper.logString = getIdsFromApplications(objApplications);
            
            AsyncHelper.logBatchJobException(objAsyncLogWrapper);
        }
    }

    /**
    * @description 
    * @author Simran | 03-07-2024 
    * @param batchableContext 
    **/
    public void finish(Database.BatchableContext batchableContext) {}
}