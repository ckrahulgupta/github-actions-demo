/**
 * 
 * @author      Rahul Gupta
 * @description Used to fetch the end of month and end of year interest 
 *              from NLS for each loan
 * @created     28-09-2022
 * @updated     22-06-2023
 */

 global without sharing class NLSGetLoanStatisticsAdapter extends intframework.BaseIntegrationAdapter {

    private static final String KEY_LOANS = 'loans';
    private static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    // private static final String CLASS_NAME = 'NLSGetLoanStatisticsAdapter';
    private static final String FAILED_TO_FETCH = 'Failed to fetch data.';
    private static final String ACTIVE_LOAN_DAILY = 'ACTIVE LOAN DAILY';

    List<Map<String, Object>> loans = new List<Map<String, Object>>();
    List<String> errorList = new List<String>();
    
    
    /**
    * @description : Generate Request Body
    * @author  Pritam Roy | 03-11-2024 
    * @param requestBody 
    * @return String 
    **/
    global override String generateRequestBody(Map<String, Object> requestBody) {

        loans = (List<Map<String, Object>>) requestBody.get(KEY_LOANS);

        return null;
    }

    
    /**
    * @description : Make callout and Update Application Fee Payment
    * @author  Pritam Roy | 03-11-2024 
    * @param request 
    * @return System.HttpResponse 
    **/
    global override System.HttpResponse sendRequest(System.HttpRequest request) {
        
        HttpResponse response = new HttpResponse();
        AccessTokenNLSWrapper tokenWrapper = new AccessTokenNLSWrapper();

        List<Map<Id, Object>> failures = new List<Map<Id, Object>>();
        List<Id> successes = new List<Id>();

        try {

            Http http = new Http();
            
            String token;
            String unmaskedEndpoint;
            String maskedEndpoint;
            Integer count = 0;

            // get the access token
            while (count < MAX_ACCESS_TOKEN_GENERATION_LIMIT) {
                token = AccessTokenGenerator.getAccessToken();
                if (token != null) {
                	break;
            	}
                count++;
            }

            if (token == null) {
                throw new CustomException(ConstantValues.ACCESS_TOKEN_NULL);
            }

            tokenWrapper = AccessTokenNLSWrapper.parse(token);

            request.setHeader(ConstantValues.AUTHORIZATION, 
                                  tokenWrapper.token_type + ' ' + 
                                  tokenWrapper.access_token);

            unmaskedEndpoint = request.getEndpoint();

            List<genesis__Application_Fee_Payment__c> feePayments = 
                                        new List<genesis__Application_Fee_Payment__c>();
            genesis__Application_Fee_Payment__c feePayment;

            // for child
            for (Map<String, Object> requestMap : loans) {
                String currLoanId = (String) requestMap.get('loanId');
                String currApplicationId = (String) requestMap.get('parentId');
                String currPricingDetailId = (String) requestMap.get('childId');

                if (currLoanId == null) {
                    failures.add(new Map<Id, Object> {
                        currPricingDetailId => 'No loan id'
                    });
                    continue;
                }
                
                maskedEndpoint = unmaskedEndpoint;
                maskedEndpoint = maskedEndpoint.replace(ConstantValues.LOAN_ID, currLoanId);

                request.setEndpoint(maskedEndpoint);
                response = http.send(request);
 

                if (response.getStatusCode() != 200) {
                    failures.add(new Map<Id, Object> {
                        currPricingDetailId => response.getBody()
                    });
                    errorList.add(String.valueOf(currPricingDetailId));
                    continue;
                }
    
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> payload = (Map<String, Object>) responseBody.get(ConstantValues.PAYLOAD);
    
                List<Object> dataList = (List<Object>) payload.get(ConstantValues.DATA);

  
                Map<String, Object> statistics;
                String month = null;

                for (Object data : dataList) {

                    statistics = (Map<String, Object>) data;

                    if (statistics.get('Month_Number') != null) {
                        month = String.valueOf(statistics.get('Month_Number'));

                        if (String.isNotBlank(month)) {
                            if (month.length() == 6) {
                                month = month.substring(4);
                            } else {
                                month = '00';
                            }
                        }
                    }

                    feePayment = new genesis__Application_Fee_Payment__c();
                    
                    feePayment.genesis__Application__c = currApplicationId;
                    feePayment.Pricing_Detail__c = currPricingDetailId;
                    feePayment.Month__c = Integer.valueOf(month);
                    feePayment.Year__c = Integer.valueOf(statistics.get('Year_Number'
                    ));
                    feePayment.Record_Type__c = ACTIVE_LOAN_DAILY;
                    feePayment.Interest_Paid__c = (Decimal) statistics.get('Interest_Paid');
                    feePayment.External_Id__c = 
                                currPricingDetailId + '-' 
                                + String.valueOf(statistics.get('Year_Number')) + '-'
                                + String.valueOf(statistics.get('Month_Number'));

                    feePayments.add(feePayment);
                }
            }

            AccessTokenGenerator.revokeAccessToken(tokenWrapper.access_token);

            Database.UpsertResult[] results = 
                    Database.upsert(feePayments, genesis__Application_Fee_Payment__c.External_Id__c, false);

            for (Database.UpsertResult result : results) {
                if (result.isSuccess()) {
                    successes.add(result.getId());
                } else {
                    failures.add(new Map<Id, Object> {
                        result.getId() => String.join(result.getErrors(), ', ')
                    });
                }
            }
            if (failures.size() > 0) {
                AsyncHelper.AsyncLogWrapper objAsyncLogWrapper = 
                                    AsyncHelper.getAsyncLogWrapperInstance(NLSGetLoanStatisticsAdapter.class);
                objAsyncLogWrapper.logString = 'Failed records - ' + JSON.serialize(failures);
                AsyncHelper.logAsyncJobException(objAsyncLogWrapper);
                List<CFA_Configuration__c> errorLog = [SELECT Id, GetLoanStatisticsCallout_Error_Log__c FROM CFA_Configuration__c];
                if(String.isBlank(errorLog[0].GetLoanStatisticsCallout_Error_Log__c)){
                    errorLog[0].GetLoanStatisticsCallout_Error_Log__c = String.join(errorList, ', ');
                } else {
                    errorLog[0].GetLoanStatisticsCallout_Error_Log__c += ', ' + String.join(errorList, ', ');
                }
                Database.update(errorLog, true);
            }

        } catch (CustomException objCustomException) {
            
            AccessTokenGenerator.revokeAccessToken(tokenWrapper.access_token);

            AsyncHelper.AsyncLogWrapper objAsyncLogWrapper = 
                                    AsyncHelper.getAsyncLogWrapperInstance(
                                                NLSGetLoanStatisticsAdapter.class, 
                                                objCustomException
                                            );
            objAsyncLogWrapper.logString = 'Failed records - ' + JSON.serialize(failures);
            AsyncHelper.logAsyncJobException(objAsyncLogWrapper);
            List<CFA_Configuration__c> errorLog = [SELECT Id, GetLoanStatisticsCallout_Error_Log__c FROM CFA_Configuration__c];
            if(String.isBlank(errorLog[0].GetLoanStatisticsCallout_Error_Log__c)){
                errorLog[0].GetLoanStatisticsCallout_Error_Log__c += String.join(errorList, ', ');
            } else {
                errorLog[0].GetLoanStatisticsCallout_Error_Log__c += ', ' + String.join(errorList, ', ');
            }
            Database.update(errorLog, true);

        } catch (Exception objException) {

            AccessTokenGenerator.revokeAccessToken(tokenWrapper.access_token);

            AsyncHelper.AsyncLogWrapper objAsyncLogWrapper = 
                                    AsyncHelper.getAsyncLogWrapperInstance(
                                                NLSGetLoanStatisticsAdapter.class, 
                                                objException
                                            );
            objAsyncLogWrapper.logString = 'Failed records - ' + JSON.serialize(failures);
            AsyncHelper.logAsyncJobException(objAsyncLogWrapper);
            List<CFA_Configuration__c> errorLog = [SELECT Id, GetLoanStatisticsCallout_Error_Log__c FROM CFA_Configuration__c];
            if(String.isBlank(errorLog[0].GetLoanStatisticsCallout_Error_Log__c)){
                errorLog[0].GetLoanStatisticsCallout_Error_Log__c += String.join(errorList, ', ');
            } else {
                errorLog[0].GetLoanStatisticsCallout_Error_Log__c += ', ' + String.join(errorList, ', ');
            }
            Database.update(errorLog, true);
        }

        return response;
    }
}