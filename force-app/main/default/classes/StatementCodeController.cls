/**
 * @description Controller class for updating statement codes.
 * 
 * @author      Rahul Gupta
 * @created     14-02-2023 
 * @updated     02-08-2023
 */
public with sharing class StatementCodeController {
    // constants
    // private static final String STATEMENT_CODE_1 = 'statement_code_1';
    // private static final String STATEMENT_CODE_6 = 'statement_code_6';
    // private static final String STATEMENT_CODE_7 = 'statement_code_7';
    // private static final String STATEMENT_CODE_8 = 'statement_code_8';
    private static final String STATEMENT_CODE_OTHER = 'Others';
    private static final String CLASS_NAME = 'StatementCodeController';
    private static final Integer MAX_BATCH_SIZE = 50;
    
    /**
     * @description getStatementCodeCount Method to fetch the statement code count 
     * for all the loans for a particular maturity date.
     * 
     * @author Rahul Gupta | 08-02-2023 
     * @param   maturityDate To take the maturity date.
     * @return  Map<String, Integer> returns the map of counts.
     * @throws  AuraHandledException
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getStatementCodeCount(Date maturityDate) {

        Map<String, Integer> statementCodeFrequencyMap = new Map<String, Integer> {
            STATEMENT_CODE_OTHER => 0
        };

        try {
            List<genesis__Applications__c> activeApplications = [
                            SELECT Id, 
                                   Statement_Code__c,
                                   Dealer_Name__r.CFA_Partner_Program__c,
                                   Coop_Type__c 
                            FROM genesis__Applications__c 
                            WHERE genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                            AND Loan_Id__c != null
                            AND genesis__Maturity_Date__c = :maturityDate
                            WITH SECURITY_ENFORCED
                        ];
            List<String> programIdList = new List<String>();
            for(genesis__Applications__c eachApp : activeApplications){
                programIdList.add(eachApp.Dealer_Name__r.CFA_Partner_Program__c);
                System.debug('---------> getStatementCode' + eachApp.Dealer_Name__r.CFA_Partner_Program__c);
            }
            Set<String> statementCodes = StatementCodeHelper.getAllStatementCodes(programIdList);

            // initialize the statement code frequencies with 0
            for (String statementCode : statementCodes) {
                statementCodeFrequencyMap.put(statementCode, 0);
            }

            for (genesis__Applications__c activeApplication : activeApplications) {

                if (statementCodeFrequencyMap.containsKey(String.valueOf(activeApplication.Statement_Code__c))) {
                    statementCodeFrequencyMap.put(
                            String.valueOf(activeApplication.Statement_Code__c), 
                            statementCodeFrequencyMap.get(String.valueOf(activeApplication.Statement_Code__c)) + 1
                        );
                } else {
                    statementCodeFrequencyMap.put(
                            STATEMENT_CODE_OTHER, 
                            statementCodeFrequencyMap.get(STATEMENT_CODE_OTHER) + 1
                        );
                }
            }
        } catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            throw new AuraHandledException(objException.getMessage());
        }
        System.debug('-----> check other statement code ' + statementCodeFrequencyMap);
        return statementCodeFrequencyMap;
    }
    
    /**
     * @description getLoansForMaturityDate Fetch the active loans under a particular maturity date.
     * 
     * @author Rahul Gupta | 08-02-2023 
     * @param   maturityDate To take the maturity date.
     * @return  List<genesis__Applications__c> List of active applications under that particular maturity date
     * @throws  AuraHandledException
     */
    @AuraEnabled(cacheable=true)
    public static List<genesis__Applications__c> getLoansForMaturityDate(Date maturityDate) {
        List<genesis__Applications__c> activeApplications;

        try {
            activeApplications = [SELECT Id, 
                                         Statement_Code__c,
                                         genesis__Loan_Number__c,
                                         genesis__Account__r.Name 
                                  FROM genesis__Applications__c 
                                  WHERE genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                                  AND Loan_Id__c != null
                                  AND genesis__Maturity_Date__c = :maturityDate
                                  ORDER BY Statement_Code__c ASC];
            
        } catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            throw new AuraHandledException(objException.getMessage());
        }

        return activeApplications;
    }
       
    /**
    * @description : updateLoanStatementCodeForMaturityDate Updates the statement codes of the loans 
    *                under the particular maturity date in Salesforce & NLS.
    * @author Rahul Gupta | 02-08-2023 
    * @param maturityDate 
    * @return String 
    **/
    @AuraEnabled
    public static String updateLoanStatementCodeForMaturityDate(Date maturityDate) {
        String jobId;

        try {
            UpdateStatementCodeCalloutBatch batchable = new UpdateStatementCodeCalloutBatch(maturityDate);
            jobId = Database.executeBatch(batchable, MAX_BATCH_SIZE);
            
        } catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            throw new AuraHandledException(objException.getMessage());
        }

        return jobId;
    }
}