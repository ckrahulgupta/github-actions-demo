/**
 * @description Adapter class for UpdateStatementCode
 * Author: Rahul Gupta
 * Created At: 15-02-2023
 * Updated At: 21-02-2023
 */
global with sharing class UpdateStatementCodeAdapter extends intframework.BaseIntegrationAdapter {

    // Constants
    private static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    private static final String KEY_LOANS = 'loans';
    private static final String CLASS_NAME = 'UpdateStatementCodeAdapter';
    private static final String FAILED_TO_UPDATE = 'Failed to update statement code.';
    private static final String KEY_ID = 'id';
    private static final String KEY_LOAN_NUM = 'loanNumber';
    private static final String KEY_PRICING_COUNT = 'pricingCount';

    List<Map<String, Object>> loans;
    Map<String, Object> statementCodesMap;
    
    /**
    * @description Check access on object
    * @author Ayan Bhowmik | 07-19-2024 
    **/
    private static void checkAccessOnObjects(){
        if((!Schema.sObjectType.genesis__Applications__c.isUpdateable())){
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
        }
    }
    /**
     * @description This method is used to get the xml for update statement code
     * @param requestBody 
     * @return String
     */
    public override String generateRequestBody(Map<String, Object> requestBody) {
        try {
            loans = (List<Map<String, Object>>) requestBody.get(KEY_LOANS);
            System.debug('--------> loan list from adapter ' + loans);
            statementCodesMap = StatementCodeHelper.getAllStatementCodeDetailsWtihSecurity(loans);
        } catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return RequestBodyGeneratorHelper.generateXmlDocument(loans, statementCodesMap);
    }

    /**
     * @description This method is used to send the http request and get the response
     * @param request System.HttpRequest
     * @return System.HttpResponse
     */
    public override System.HttpResponse sendRequest(System.HttpRequest request) {
        
        HttpResponse response = new HttpResponse();
        AccessTokenNLSWrapper tokenWrapper = new AccessTokenNLSWrapper();

        try {
            Http http = new Http();
            
            String token;

            // get the access token
            token = checkAccessToken();

            tokenWrapper = AccessTokenNLSWrapper.parse(token);

            request.setHeader(ConstantValues.AUTHORIZATION, 
                              tokenWrapper.token_type + ' ' + 
                              tokenWrapper.access_token);

            response = http.send(request);

            if (response.getStatusCode() != 200) {
                throw new CustomException(FAILED_TO_UPDATE + ' | ' + request.getBody());
            }

            AccessTokenGenerator.revokeAccessToken(tokenWrapper.access_token);

            // update the statement code salesforce after successful update in NLS
            List<Id> loanIdList = new List<Id>();

            for (Map<String, Object> activeLoan : loans) {
                loanIdList.add((Id) activeLoan.get(KEY_ID));
            }
            updateStatementCode(loanIdList);
        } catch (CustomException objCustomException) {
            AccessTokenGenerator.revokeAccessToken(tokenWrapper.access_token);
            PortalHelper.saveExceptionLog(objCustomException, CLASS_NAME);
        } catch (Exception objException) {
            AccessTokenGenerator.revokeAccessToken(tokenWrapper.access_token);
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response;
    }
    /**
     * @description Generating Access Token
     * @return
     * @exception 
     */
    private String checkAccessToken(){
        String accessTokenString;
        Integer count = 0;
        while (count < MAX_ACCESS_TOKEN_GENERATION_LIMIT) {
            accessTokenString = AccessTokenGenerator.getAccessToken();
            if (accessTokenString != null) {
                break;
            }
            count++;
        }

        if (accessTokenString == null) {
            throw new CustomException(ConstantValues.ACCESS_TOKEN_NULL);
        }
        return accessTokenString;
    }
    /**
    * @description Update Statement Codes on loans
    * @author Ayan Bhowmik | 07-19-2024 
    * @param loanIdList 
    **/
    private void updateStatementCode(List<Id> loanIdList){
        String statementCodeLabel;
        List<genesis__Applications__c> activeLoans = [SELECT Id, 
                                                            Pricing_Count__c,
                                                            Statement_Code__c,
                                                            Coop_Type__c,
                                                            Dealer_Name__r.CFA_Partner_Program__r.Name
                                                        FROM genesis__Applications__c 
                                                        WHERE Id IN :loanIdList];

        for (genesis__Applications__c activeLoan : activeLoans) {
            if (activeLoan.Pricing_Count__c > 1) {
                // update the statement code for multi rate loans
                if(activeLoan.Coop_Type__c == ConstantValues.GROWMARK_COOP_TYPE){
                    statementCodeLabel = ((String) activeLoan.Coop_Type__c).toUpperCase() + ConstantValues.COMMITMENT_STATEMENT_CODE_SUFFIX;
                    // update the statement code for multi rate loans
                    activeLoan.Statement_Code__c = ((Statement_Code__mdt)statementCodesMap.get(statementCodeLabel)).Opt_In_Code__c;
                } else {
                    statementCodeLabel = String.valueOf(activeLoan.Dealer_Name__r.CFA_Partner_Program__r.Name).toUpperCase() + ConstantValues.COMMITMENT_STATEMENT_CODE_SUFFIX;
                    // update the statement code for multi rate loans
                    activeLoan.Statement_Code__c = ((CFA_Partner_Program__c)statementCodesMap.get(statementCodeLabel)).Statement_Code_Multi_Rate_Opt_In__c;
                }
                
            } else {
                if(activeLoan.Coop_Type__c == ConstantValues.GROWMARK_COOP_TYPE){
                    statementCodeLabel = String.valueOf(activeLoan.Coop_Type__c).toUpperCase() + ConstantValues.MONTHLY_STATEMENT_CODE_SUFFIX;
                    // update the statement code for single rate loans
                    activeLoan.Statement_Code__c = ((Statement_Code__mdt)statementCodesMap.get(statementCodeLabel)).Opt_In_Code__c;
                } else {
                    statementCodeLabel = String.valueOf(activeLoan.Dealer_Name__r.CFA_Partner_Program__r.Name).toUpperCase() + ConstantValues.MONTHLY_STATEMENT_CODE_SUFFIX;
                    // update the statement code for single rate loans
                    activeLoan.Statement_Code__c = ((CFA_Partner_Program__c)statementCodesMap.get(statementCodeLabel)).Statement_Code_Single_Rate_Opt_In__c;
                }
            }
        }

        Database.update(activeLoans, true);
    }
}