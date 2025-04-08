/**
 * 
 * @author      Rahul Gupta
 * @description Used to fetch the end of month and end of year interest 
 *              from NLS for each loan
 * @created     21-10-2022
 * @updated     31-07-2023
 */

 global without sharing class NLSGetLoanDetailsMonthlyAdapter extends intframework.BaseIntegrationAdapter {

    private static final String KEY_LOANS = 'loans';
    // private static final String KEY_PARENT_LOANS = 'parentLoans';
    private static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    // private static final String CLASS_NAME = 'NLSGetLoanDetailsMonthlyAdapter';
    private static final String FAILED_TO_FETCH = 'Failed to fetch data.';
    private static final String ACTIVE_LOAN_DAILY = 'ACTIVE LOAN DAILY';

    // List<Map<String, Object>> parentList = new List<Map<String, Object>>();
    List<Map<String, Object>> loans = new List<Map<String, Object>>();
    List<String> errorList = new List<String>();
    
    
    /**
    * @description : Generate request body
    * @author  Pritam Roy | 03-11-2024 
    * @param requestBody 
    * @return String 
    **/
    global override String generateRequestBody(Map<String, Object> requestBody) {
        loans = (List<Map<String, Object>>) requestBody.get(KEY_LOANS);
        // parentList = (List<Map<String, Object>>) requestBody.get(KEY_PARENT_LOANS);

        return null;
    }

    /**
    * @description : Get Month ad Year
    * @author  Pritam Roy | 03-11-2024 
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
    * @description : Update Applicant Fee Payment Fields
    * @author  Pritam Roy | 03-11-2024 
    * @param data 
    * @param feePayment 
    * @return genesis__Application_Fee_Payment__c 
    **/
    private genesis__Application_Fee_Payment__c setRequiredFields(
                Map<String, Object> data, 
                genesis__Application_Fee_Payment__c feePayment
            ) {
        Map<String, Object> monthAndYearMap = getMonthAndYear();

        feePayment.Record_Type__c = ACTIVE_LOAN_DAILY;
        feePayment.Month__c = Integer.valueOf(monthAndYearMap.get('month'));
        feePayment.Year__c = Integer.valueOf(monthAndYearMap.get('year'));
        feePayment.Past_Due_Balance__c = (Decimal) data.get('Total_Past_Due_Balance');
        feePayment.Interest_Earned__c = (Decimal) data.get('Current_Interest_Balance');
        feePayment.Principal_Balance__c = (Decimal) data.get('Current_Principal_Balance');

        return feePayment;
    }

    /**
    * @description : Make Callout and Handle Fee Payment for Child Loans
    * @author  Pritam Roy | 03-11-2024 
    * @param request 
    * @param successes 
    * @param failures 
    * @return List<genesis__Application_Fee_Payment__c> 
    **/
    private List<genesis__Application_Fee_Payment__c> 
            handleChildLoanFeePaymentRecordGeneration(
                        System.HttpRequest request, 
                        List<Id> successes, 
                        List<Map<Id, Object>> failures
                    ) {

        List<genesis__Application_Fee_Payment__c> feePayments = 
                                        new List<genesis__Application_Fee_Payment__c>();

        genesis__Application_Fee_Payment__c feePayment;

        String maskedEndpoint;

        String unmaskedEndpoint = request.getEndpoint();

        HttpResponse response = new HttpResponse();

        Map<String, Object> monthAndYearMap = getMonthAndYear();

        Http http = new Http();

        // working with the child loans
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
                errorList.add(currPricingDetailId);
                continue;
            }

            Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object> payload = (Map<String, Object>) responseBody.get(ConstantValues.PAYLOAD);


            Map<String, Object> data = (Map<String, Object>) payload.get(ConstantValues.DATA);

            feePayment = new genesis__Application_Fee_Payment__c();
            
            feePayment = setRequiredFields(data, feePayment);

            
            feePayment.Interest_Rate__c = (Decimal) data.get('Current_Interest_Rate');
            feePayment.Per_Diem__c = (Decimal) data.get('Current_Perdiem');
            feePayment.Fees__c = (Decimal) data.get('Current_Fees_Balance');

            if (feePayment.Past_Due_Balance__c != null) {

                if (feePayment.Past_Due_Balance__c < 0) {
                    feePayment.Past_Due_Balance__c = 
                                                -1 * feePayment.Past_Due_Balance__c;
                }

                feePayment.Past_Due_Balance__c = 
                                                feePayment.Past_Due_Balance__c.setScale(2);
            }

            feePayment.Pricing_Detail__c = currPricingDetailId;
            feePayment.genesis__Application__c = currApplicationId;

            feePayment.External_Id__c = 
                        currPricingDetailId + '-' 
                        + String.valueOf(monthAndYearMap.get('year')) + '-'
                        + String.valueOf(monthAndYearMap.get('year')) 
                        + monthAndYearMap.get('month');
            
            feePayments.add(feePayment);
            
        }   
        
        return feePayments;
    }

    // private List<genesis__Application_Fee_Payment__c> 
    //                 handleParentLoanFeePaymentRecordGeneration(System.HttpRequest request, String unmaskedEndpoint) {

    //     List<genesis__Application_Fee_Payment__c> feePayments = 
    //                                     new List<genesis__Application_Fee_Payment__c>();

    //     genesis__Application_Fee_Payment__c feePayment;

    //     String maskedEndpoint;

    //     HttpResponse response = new HttpResponse();

    //     Map<String, Object> monthAndYearMap = getMonthAndYear();

    //     Http http = new Http();

    //     // working with the parent loans
    //     for (Map<String, Object> requestMap : parentList) {
    //         String currLoanId = (String) requestMap.get('loanId');
    //         String currApplicationId = (String) requestMap.get('parentId');

    //         if (currLoanId == null) {
    //             continue;
    //         }
            
    //         maskedEndpoint = unmaskedEndpoint;
    //         maskedEndpoint = maskedEndpoint.replace(ConstantValues.REPLACE_LOAN_ID, currLoanId);

    //         request.setEndpoint(maskedEndpoint);
    //         response = http.send(request);


    //         if (response.getStatusCode() != 200) {
    //             continue;
    //         }

    //         Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    //         Map<String, Object> payload = (Map<String, Object>) responseBody.get(ConstantValues.PAYLOAD);

    //         Map<String, Object> data = (Map<String, Object>) payload.get(ConstantValues.DATA);

    //         feePayment = new genesis__Application_Fee_Payment__c();
           
    //         feePayment = setRequiredFields(data, feePayment);
            
     
    //         if (feePayment.Past_Due_Balance__c != null) {

    //             if (feePayment.Past_Due_Balance__c < 0) {
    //                 feePayment.Past_Due_Balance__c = -1 * feePayment.Past_Due_Balance__c;
    //             }

    //             feePayment.Past_Due_Balance__c = feePayment.Past_Due_Balance__c.setScale(2);
    //         }

    //         feePayment.genesis__Application__c = currApplicationId;
    //         feePayment.External_Id__c = 
    //                     currApplicationId + '-' 
    //                     + String.valueOf(monthAndYearMap.get('year')) + '-'
    //                     + String.valueOf(monthAndYearMap.get('year')) 
    //                     + monthAndYearMap.get('month');
            
    //         feePayments.add(feePayment);
            
    //     }

    //     return feePayments;
    // }

    
    /**
    * @description : Make callout Request and update Fee Payment
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

            // Http http = new Http();
            
            String token;
            // String unmaskedEndpoint;
            // String maskedEndpoint;
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

            // String unmaskedEndpoint = request.getEndpoint();

            List<genesis__Application_Fee_Payment__c> feePayments;

            if (loans != null && loans.size() > 0) {
                feePayments = handleChildLoanFeePaymentRecordGeneration(request, successes, failures);
                // feePayments = setRequiredApplicationFeePaymentFields(feePayments);
            }

            // if (parentList != null && parentList.size() > 0) {
            //     feePayments.addAll(handleParentLoanFeePaymentRecordGeneration(request, unmaskedEndpoint));
            //     // feePayments = setRequiredApplicationFeePaymentFields(feePayments);
            // }

            
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
                                    AsyncHelper.getAsyncLogWrapperInstance(NLSGetLoanDetailsMonthlyAdapter.class);
                objAsyncLogWrapper.logString = 'Failed records - ' + JSON.serialize(failures);
                AsyncHelper.logAsyncJobException(objAsyncLogWrapper);
                List<CFA_Configuration__c> errorLog = [SELECT Id, GetLoanDetailsMonthlyCallout_Error_Log__c FROM CFA_Configuration__c LIMIT 1];
                if(String.isBlank(errorLog[0].GetLoanDetailsMonthlyCallout_Error_Log__c)){
                    errorLog[0].GetLoanDetailsMonthlyCallout_Error_Log__c = String.join(errorList, ', ');
                } else {
                    errorLog[0].GetLoanDetailsMonthlyCallout_Error_Log__c += ', ' + String.join(errorList, ', ');
                }
                Database.update(errorLog, true);
            }

        } catch (CustomException objCustomException) {
            
            AccessTokenGenerator.revokeAccessToken(tokenWrapper.access_token);

            AsyncHelper.AsyncLogWrapper objAsyncLogWrapper = 
                                    AsyncHelper.getAsyncLogWrapperInstance(
                                                NLSGetLoanDetailsMonthlyAdapter.class, 
                                                objCustomException
                                            );
            objAsyncLogWrapper.logString = 'Failed records - ' + JSON.serialize(failures);
            AsyncHelper.logAsyncJobException(objAsyncLogWrapper);
            List<CFA_Configuration__c> errorLog = [SELECT Id, GetLoanDetailsMonthlyCallout_Error_Log__c FROM CFA_Configuration__c LIMIT 1];
            if(String.isBlank(errorLog[0].GetLoanDetailsMonthlyCallout_Error_Log__c)){
                errorLog[0].GetLoanDetailsMonthlyCallout_Error_Log__c = String.join(errorList, ', ');
            } else {
                errorLog[0].GetLoanDetailsMonthlyCallout_Error_Log__c += ', ' + String.join(errorList, ', ');
            }
            Database.update(errorLog, true);

        } catch (Exception objException) {

            AccessTokenGenerator.revokeAccessToken(tokenWrapper.access_token);

            AsyncHelper.AsyncLogWrapper objAsyncLogWrapper = 
                                    AsyncHelper.getAsyncLogWrapperInstance(
                                                NLSGetLoanDetailsMonthlyAdapter.class, 
                                                objException
                                            );
            objAsyncLogWrapper.logString = 'Failed records - ' + JSON.serialize(failures);
            AsyncHelper.logAsyncJobException(objAsyncLogWrapper);
            List<CFA_Configuration__c> errorLog = [SELECT Id, GetLoanDetailsMonthlyCallout_Error_Log__c FROM CFA_Configuration__c LIMIT 1];
            if(String.isBlank(errorLog[0].GetLoanDetailsMonthlyCallout_Error_Log__c)){
                errorLog[0].GetLoanDetailsMonthlyCallout_Error_Log__c = String.join(errorList, ', ');
            } else {
                errorLog[0].GetLoanDetailsMonthlyCallout_Error_Log__c += ', ' + String.join(errorList, ', ');
            }
            Database.update(errorLog, true);
        }

        return response;
    }
}