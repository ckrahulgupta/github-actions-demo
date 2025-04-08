/**
 * @description       : Used to fetch the end of month and end of year interest from NLS for each loan
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 03-14-2024
 * @last modified by  : Simran
**/
global without sharing class NLSGetParticipantInterestAdapter extends intframework.BaseIntegrationAdapter {

    private static final String KEY_LOANS = 'loans';
    private static final String FAILED_TO_FETCH = 'Failed to fetch data.';
    private static final String PARTICIPANT_DAILY = 'PARTICIPANT DAILY';
    private static final String PARTICIPANT_STRING = 'participant-';
    private static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;

    List<Map<String, Object>> loans = new List<Map<String, Object>>();
    
    /**
    * @description It is use to generate the request body for NLS callout.
    * @author Simran | 03-14-2024 
    * @param requestBody 
    * @return String 
    **/
    global override String generateRequestBody(Map<String, Object> requestBody) {

        loans = (List<Map<String, Object>>) requestBody.get(KEY_LOANS);

        return null;
    }

    /**
    * @description It is use to get the FeePayment Record
    * @author Simran | 03-14-2024 
    * @param externalIds 
    * @return Map<String, genesis__Application_Fee_Payment__c> 
    **/
    private Map<String, genesis__Application_Fee_Payment__c> getFeePaymentRecordMap(List<String> externalIds) {
        List<genesis__Application_Fee_Payment__c> feePayments = [
            SELECT Id,
                   Principal_Balance__c,
                   External_Id__c
            FROM genesis__Application_Fee_Payment__c
            WHERE External_Id__c IN :externalIds
        ];

        Map<String, genesis__Application_Fee_Payment__c> feePaymentsMap = 
                            new Map<String, genesis__Application_Fee_Payment__c>();

        for (genesis__Application_Fee_Payment__c feePayment : feePayments) {
            if (String.isNotBlank((String) feePayment.External_Id__c) 
                && !feePaymentsMap.containsKey(feePayment.External_Id__c)) {
                
                feePaymentsMap.put(
                        String.valueOf(feePayment.External_Id__c), 
                        feePayment
                    );
            }
        }

        return feePaymentsMap;

    }

    /**
    * @description It is use to get the month and year in the form of map.
    * @author Simran | 03-14-2024 
    * @return Map<String, Object> 
    **/
    private Map<String, Object> getMonthAndYear() {
        Integer yearNumber = Date.today().year();
        Integer monthNumber = Date.today().month() - 1;

        if (monthNumber <= 0) {
            monthNumber = 12;
            yearNumber -= 1;
        }

        String month = (monthNumber / 10 == 0) ? '0' + monthNumber : '' + monthNumber;

        return new Map<String, Object> {
            'month' => month,
            'year' => yearNumber
        };
    }

    /**
    * @description To handle the fee payment record generation.
    * @author Simran | 03-14-2024 
    * @param request 
    * @param successes 
    * @param failures 
    * @return List<genesis__Application_Fee_Payment__c> 
    **/
    private List<genesis__Application_Fee_Payment__c> 
                            handleFeePaymentRecordGeneration(System.HttpRequest request, List<Id> successes, List<Map<Id, Object>> failures) {
        List<genesis__Application_Fee_Payment__c> feePayments = 
                                        new List<genesis__Application_Fee_Payment__c>();

        genesis__Application_Fee_Payment__c objApplicationFeePayment;

        String unmaskedEndpoint = request.getEndpoint();
        String maskedEndpoint;

        HttpResponse response = new HttpResponse();

        Map<String, Object> monthAndYearMap = getMonthAndYear();

        Http http = new Http();

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

            Map<String, Object> data = (Map<String, Object>) payload.get(ConstantValues.DATA);

            objApplicationFeePayment = new genesis__Application_Fee_Payment__c();
            
            objApplicationFeePayment.genesis__Application__c = currApplicationId;
            objApplicationFeePayment.Pricing_Detail__c = currPricingDetailId;
            objApplicationFeePayment.Month__c = Integer.valueOf(monthAndYearMap.get('month'));
            objApplicationFeePayment.Year__c = Integer.valueOf(monthAndYearMap.get('year'));
            objApplicationFeePayment.Dealer_Monthly_Interest__c = (Decimal) data.get('Current_Interest_Balance');
            // objApplicationFeePayment.Principal_Balance__c = (Decimal) data.get('Current_Principal_Balance');

            // if (objApplicationFeePayment.Dealer_Monthly_Interest__c != null) {

            //     // if (objApplicationFeePayment.Dealer_Monthly_Interest__c < 0) {
            //     //     objApplicationFeePayment.Dealer_Monthly_Interest__c = -1 * objApplicationFeePayment.Dealer_Monthly_Interest__c;
            //     // }

            //     objApplicationFeePayment.Dealer_Monthly_Interest__c = objApplicationFeePayment.Dealer_Monthly_Interest__c.setScale(4);
            // }

            objApplicationFeePayment.External_Id__c = 
                        PARTICIPANT_STRING + currPricingDetailId + '-' 
                        + String.valueOf(monthAndYearMap.get('year')) + '-'
                        + String.valueOf(monthAndYearMap.get('year')) 
                        + monthAndYearMap.get('month');
            objApplicationFeePayment.Record_Type__c = PARTICIPANT_DAILY;
            feePayments.add(objApplicationFeePayment);
        }

        return feePayments;
    }

    /**
    * @description To set the required application's fee payment field
    * @author Simran | 03-14-2024 
    * @param feePayments 
    * @return List<genesis__Application_Fee_Payment__c> 
    **/
    private List<genesis__Application_Fee_Payment__c> 
                setRequiredApplicationFeePaymentFields(List<genesis__Application_Fee_Payment__c> feePayments) {

        List<String> externalIds = new List<String>();

        String externalId = '';

        for (genesis__Application_Fee_Payment__c objApplicationFeePayment : feePayments) {
            externalId = String.valueOf(objApplicationFeePayment.External_Id__c);
            externalId = externalId.replace(PARTICIPANT_STRING, '');
            externalIds.add(externalId);
        }

        Map<String, genesis__Application_Fee_Payment__c> feePaymentsMap = getFeePaymentRecordMap(externalIds);

        for (genesis__Application_Fee_Payment__c objApplicationFeePayment : feePayments) {
            externalId = String.valueOf(objApplicationFeePayment.External_Id__c);
            externalId = externalId.replace(PARTICIPANT_STRING, '');

            if (feePaymentsMap.containsKey(externalId)) {
                objApplicationFeePayment.Principal_Balance__c = 
                                feePaymentsMap.get(externalId).Principal_Balance__c;
            }
        }
        return feePayments;
    }
    
    /**
    * @description To send the request to the nls and get the response in back
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

            String token;
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

            List<genesis__Application_Fee_Payment__c> feePayments;
            
            // working with the child loans
            if (loans != null && loans.size() > 0) {
                feePayments = handleFeePaymentRecordGeneration(request, successes, failures);
                feePayments = setRequiredApplicationFeePaymentFields(feePayments);
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
                                    AsyncHelper.getAsyncLogWrapperInstance(NLSGetParticipantInterestAdapter.class);
                objAsyncLogWrapper.logString = 'Failed records - ' + JSON.serialize(failures);
                AsyncHelper.logAsyncJobException(objAsyncLogWrapper);
            }

        } catch (CustomException objCustomException) {
            
            AccessTokenGenerator.revokeAccessToken(tokenWrapper.access_token);

            AsyncHelper.AsyncLogWrapper objAsyncLogWrapper = 
                                    AsyncHelper.getAsyncLogWrapperInstance(
                                                NLSGetParticipantInterestAdapter.class, 
                                                objCustomException
                                            );
            objAsyncLogWrapper.logString = 'Failed records - ' + JSON.serialize(failures);
            AsyncHelper.logAsyncJobException(objAsyncLogWrapper);

        } catch (Exception objException) {

            AccessTokenGenerator.revokeAccessToken(tokenWrapper.access_token);

            AsyncHelper.AsyncLogWrapper objAsyncLogWrapper = 
                                    AsyncHelper.getAsyncLogWrapperInstance(
                                                NLSGetParticipantInterestAdapter.class, 
                                                objException
                                            );
            objAsyncLogWrapper.logString = 'Failed records - ' + JSON.serialize(failures);
            AsyncHelper.logAsyncJobException(objAsyncLogWrapper);
        }

        return response;
    }
}