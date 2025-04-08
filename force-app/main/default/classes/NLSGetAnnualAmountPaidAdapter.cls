/**
 * @description       : This class used to get the amount paid per calendar year
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 11-26-2024
 * @last modified by  : Ayan Bhowmik
**/
global inherited sharing class NLSGetAnnualAmountPaidAdapter extends intframework.BaseIntegrationAdapter{
    
    private static final String KEY_LOANS = 'loans';
    private static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    private static final String LOAN_ID = 'loanId';
    private static final String CHILD_ID = 'childId';
    private static final String NO_LOAN_ID ='No loan id';
    private static final String FAILED_RECORD = 'Failed records - ';
    private static final String KEY_YEAR_NUMBER = 'Year_Number';
    private static final String KEY_MASTER_RECORD = 'Master_Record';
   

    List<Map<String, Object>> loans = new List<Map<String, Object>>();
    
   /**
    * @description 
    * @param requestBody 
    * @return  `String`
    */
    global override String generateRequestBody(Map<String, Object> requestBody) {

        loans = (List<Map<String, Object>>) requestBody.get(KEY_LOANS);

        return null;
    }

    /**
     * @description 
     * @param request 
     * @return  `System.HttpResponse`
     * @exception 
     */
    global override System.HttpResponse sendRequest(System.HttpRequest request) {
        
        HttpResponse response = new HttpResponse();
        HttpResponse actualResponse = new HttpResponse();
        AccessTokenNLSWrapper tokenWrapper = new AccessTokenNLSWrapper();

        List<Map<Id, Object>> failures = new List<Map<Id, Object>>();
        Map<String,Map<String,Map<String,Object>>> responseMap = new  Map<String,Map<String,Map<String,Object>>>();

        try {

            Http http = new Http();
            
            String token;
            String unmaskedEndpoint;
            String maskedEndpoint;
            
            token = getAccessToken();

            tokenWrapper = AccessTokenNLSWrapper.parse(token);

            request.setHeader(ConstantValues.AUTHORIZATION, 
                                  tokenWrapper.token_type + ' ' + 
                                  tokenWrapper.access_token);

            unmaskedEndpoint = request.getEndpoint(); 

            // for child
            for (Map<String, Object> requestMap : loans) {
                String currLoanId = (String) requestMap.get(LOAN_ID);
                String currPricingDetailId = (String) requestMap.get(CHILD_ID);

                if (currLoanId == null) {
                    failures.add(new Map<Id, Object> {
                        currPricingDetailId => NO_LOAN_ID
                    });
                    continue;
                }
                
                maskedEndpoint = unmaskedEndpoint;
                maskedEndpoint = maskedEndpoint.replace(LOAN_ID, currLoanId);

                request.setEndpoint(maskedEndpoint);
                response = http.send(request);
 

                if (response.getStatusCode() != 200) {
                    failures.add(new Map<Id, Object> {
                        currPricingDetailId => response.getBody()
                    });
                    continue;
                }
    
                Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> payload = (Map<String, Object>) responseBody.get(ConstantValues.PAYLOAD);
    
                List<Object> dataList = (List<Object>) payload.get(ConstantValues.DATA);
               

                getAnnualLoanStatisticsMap(dataList,responseMap,currLoanId);
            }

            AccessTokenGenerator.revokeAccessToken(tokenWrapper.access_token);
            actualResponse.setBody(String.valueOf(JSON.serialize(responseMap)));

        } catch (CustomException objCustomException) {
            
            AccessTokenGenerator.revokeAccessToken(tokenWrapper.access_token);

            AsyncHelper.AsyncLogWrapper objAsyncLogWrapper = 
                                    AsyncHelper.getAsyncLogWrapperInstance(
                                                NLSGetLoanStatisticsAdapter.class, 
                                                objCustomException
                                            );
            objAsyncLogWrapper.logString = FAILED_RECORD + JSON.serialize(failures);
            AsyncHelper.logAsyncJobException(objAsyncLogWrapper);

        } catch (Exception objException) {

            AccessTokenGenerator.revokeAccessToken(tokenWrapper.access_token);

            AsyncHelper.AsyncLogWrapper objAsyncLogWrapper = 
                                    AsyncHelper.getAsyncLogWrapperInstance(
                                                NLSGetLoanStatisticsAdapter.class, 
                                                objException
                                            );
            objAsyncLogWrapper.logString = FAILED_RECORD + JSON.serialize(failures);
            AsyncHelper.logAsyncJobException(objAsyncLogWrapper);
        }

        return actualResponse;
    }

    /**
     * @description This method used to get access token for callout
     * @return  `String`
     * @exception 
     */
    private static String getAccessToken(){
        Integer count = 0;
        String token;
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
        return token;
    }

  /**
   * @description This method used to filter all the return data of each year.
   * @param dataList 
   * @param responseMap 
   * @param currLoanId 
   */
    private static void getAnnualLoanStatisticsMap(List<Object> dataList,Map<String,Map<String,Map<String,Object>>> responseMap,String currLoanId){
        Map<String, Object> responseDataMap;

        for (Object data : dataList) {
            responseDataMap = (Map<String, Object>) data;

            if (responseDataMap.get(KEY_YEAR_NUMBER) != null && responseDataMap.get(KEY_YEAR_NUMBER) != 0 && responseDataMap.get(KEY_MASTER_RECORD) == 1) {
                if(!responseMap.containsKey(String.valueOf(responseDataMap.get(KEY_YEAR_NUMBER)))){
                    responseMap.put(String.valueOf(responseDataMap.get(KEY_YEAR_NUMBER)),new Map<String,Map<String,Object>>{
                        currLoanId => responseDataMap
                    });
                }
                else{
                    Map<String,Map<String,Object>> loanStatisticMap = responseMap.get(String.valueOf(responseDataMap.get(KEY_YEAR_NUMBER)));
                    if(!loanStatisticMap.containsKey(currLoanId)){
                        loanStatisticMap.put(currLoanId,responseDataMap);
                        responseMap.put(String.valueOf(responseDataMap.get(KEY_YEAR_NUMBER)),loanStatisticMap);
                    }

                }
            }
        }
    }
}