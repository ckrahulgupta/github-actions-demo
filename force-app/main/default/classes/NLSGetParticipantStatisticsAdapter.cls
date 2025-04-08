/**
 * @description       : Use to fetch the end of month and end of year interest from NLS for each loan
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 26-11-2024
 * @last modified by  : Subham Nandi
**/

global without sharing class NLSGetParticipantStatisticsAdapter extends intframework.BaseIntegrationAdapter {

    private static final String KEY_LOANS = 'loans';
    private static final String FAILED_TO_FETCH = 'Failed to fetch data.';
    private static final String PARTICIPANT_DAILY = 'PARTICIPANT DAILY';
    private static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;

    List<Map<String, Object>> loans = new List<Map<String, Object>>();
    
    
    /**
    * @description Use to generate the request body for NLS callout.
    * @author Simran | 03-14-2024 
    * @param requestBody 
    * @return String 
    **/
    global override String generateRequestBody(Map<String, Object> requestBody) {

        loans = (List<Map<String, Object>>) requestBody.get(KEY_LOANS);

        return null;
    }

    
    /**
    * @description Send the request to the nls and get the response in back
    * @author Simran | 03-14-2024 
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

            // working with the child loans
            if (loans != null && loans.size() > 0) {
                for (Map<String, Object> requestMap : loans) {
                    String currParticipantId = (String) requestMap.get('participantId');
                    String currApplicationId = (String) requestMap.get('parentId');
                    String currPricingDetailId = (String) requestMap.get('childId');
    
                    if (currParticipantId == null) {
                        failures.add(new Map<Id, Object> {
                            currPricingDetailId => 'No participant id'
                        });
                        continue;
                    }
                    
                    maskedEndpoint = unmaskedEndpoint;
                    maskedEndpoint = maskedEndpoint.replace('participantId', currParticipantId);
    
                    request.setEndpoint(maskedEndpoint);
                    response = http.send(request);
    
                    if (response.getStatusCode() != 200) {
                        failures.add(new Map<Id, Object> {
                            currPricingDetailId => response.getBody()
                        });
                        continue;
                    }

                    successes.add(currPricingDetailId);
        
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
                        feePayment.Year__c = Integer.valueOf(statistics.get('Year_Number'));
                        feePayment.Interest_Earned__c = (Decimal) statistics.get('Interest_Earned');

    
                        // if (feePayment.Interest_Earned__c != null) {
                        //     feePayment.Interest_Earned__c = feePayment.Interest_Earned__c.setScale(4);
                        // } 
                        feePayment.External_Id__c = 
                                    'participant-' + currPricingDetailId + '-' 
                                    + String.valueOf(statistics.get('Year_Number')) + '-'
                                    + String.valueOf(statistics.get('Month_Number'));
                        feePayment.Record_Type__c = PARTICIPANT_DAILY;
                        feePayments.add(feePayment);
                    }
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
                                    AsyncHelper.getAsyncLogWrapperInstance(NLSGetParticipantStatisticsAdapter.class);
                objAsyncLogWrapper.logString = 'Failed records - ' + JSON.serialize(failures);
                AsyncHelper.logAsyncJobException(objAsyncLogWrapper);
            }

        } catch (CustomException objCustomException) {
            
            AccessTokenGenerator.revokeAccessToken(tokenWrapper.access_token);

            AsyncHelper.AsyncLogWrapper objAsyncLogWrapper = 
                                    AsyncHelper.getAsyncLogWrapperInstance(
                                                NLSGetParticipantStatisticsAdapter.class, 
                                                objCustomException
                                            );
            objAsyncLogWrapper.logString = 'Failed records - ' + JSON.serialize(failures);
            AsyncHelper.logAsyncJobException(objAsyncLogWrapper);

        } catch (Exception objException) {

            AccessTokenGenerator.revokeAccessToken(tokenWrapper.access_token);

            AsyncHelper.AsyncLogWrapper objAsyncLogWrapper = 
                                    AsyncHelper.getAsyncLogWrapperInstance(
                                                NLSGetParticipantStatisticsAdapter.class, 
                                                objException
                                            );
            objAsyncLogWrapper.logString = 'Failed records - ' + JSON.serialize(failures);
            AsyncHelper.logAsyncJobException(objAsyncLogWrapper);
        }

        return response;
    }
}