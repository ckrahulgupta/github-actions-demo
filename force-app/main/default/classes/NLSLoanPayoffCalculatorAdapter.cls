/**
 * @class             : NLSLoanPayoffCalculatorAdapter
 * @description       : Adapter class for Payoff Calculator
 * @author            : Pritam Roy
 * @group             : 
 * @last modified on  : 12-02-2024
 * @last modified by  : Ayan Bhowmik
**/
global inherited sharing class NLSLoanPayoffCalculatorAdapter extends intframework.BaseIntegrationAdapter{

    //Constants specific to this class
    private static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    private static final String NLS_LOAN_PAYOFF_CALCULATOR_ADAPTER = 'NLSLoanPayoffCalculatorAdapter';
    private static final String LOAN_ID_PARAMETER = 'loanId';
    private static final String PAYOFF_DATE_PARAMETER = '?payoffDate=';
    private static final String CURRENT_DATE_STRING = 'currentDate';
    private static final String PAYOFF_DATE_STRING = 'expectedDate';
    private static final String PAYLOAD = 'payload';
    private static final String DATA = 'data';
    private static final String PAYOFF_DATE = 'payoffDate';
    private static final String LOAN_ID_LIST = 'loanIdList';
    private static final String PRINCIPAL_BALANCE = 'PrincipalBalance';
    private static final String ACCRUED_INTEREST = 'AccruedInterest';
    private static final String SERVICING_FEE = 'ServicingFee';
    private static final String LATE_CHARGES = 'LateCharges';
    private static final String PAYOFF_AMOUNT = 'PayoffAmount';
    private static final String PER_DIEM = 'PerDiem';
    private static final String FEES_DUE = 'FeesDue';
    //Constants specific to this class

    List<String> loanIdList = new List<String>();
    String requestBody;
    String payoffDate;

    /**
    * @description request from integration framework
    * @author  Pritam Roy | 12-11-2023 
    * @param requestMapping 
    * @return String 
    **/
    public override String generateRequestBody(Map<String, Object> requestMapping){
        payoffDate = String.valueOf(requestMapping.get(PAYOFF_DATE));
        loanIdList = (List<String>)requestMapping.get(LOAN_ID_LIST);
        return requestBody; 
    }

    /**
    * @description check null variable
    * @author  Pritam Roy | 12-11-2023 
    * @param objVariable 
    **/
    private static void checkVariable(Object objVariable){
        if(objVariable == null){
            throw new CustomException(PortalConstants.NULL_EXCEPTION);
        }
    }

    /**
    * @description check response from callout
    * @author  Pritam Roy | 12-11-2023 
    * @param responseMap 
    **/
    private static void checkResponseData(Map<String,Object> responseMap){
        if(responseMap.containsKey(PRINCIPAL_BALANCE)){
            checkVariable(responseMap.get(PRINCIPAL_BALANCE));
        }
        if(responseMap.containsKey(ACCRUED_INTEREST)){
            checkVariable(responseMap.get(ACCRUED_INTEREST));
        }
        if(responseMap.containsKey(FEES_DUE)){
            checkVariable(responseMap.get(FEES_DUE));
        }
        if(responseMap.containsKey(SERVICING_FEE)){
            checkVariable(responseMap.get(SERVICING_FEE));
        }
        if(responseMap.containsKey(LATE_CHARGES)){
            checkVariable(responseMap.get(LATE_CHARGES));
        }
        if(responseMap.containsKey(PAYOFF_AMOUNT)){
            checkVariable(responseMap.get(PAYOFF_AMOUNT));
        }
        if(responseMap.containsKey(PER_DIEM)){
            checkVariable(responseMap.get(PER_DIEM));
        }
    }
    
    /**
    * @description method responsible to perform NLS Callout
    * @author  Pritam Roy | 12-11-2023 
    * @param httpRequest 
    * @return System.HttpResponse 
    **/
    public override System.HttpResponse sendRequest(System.HttpRequest httpRequest){
        
        String endpointUrl;
        String newEndpointUrl;
        String accessToken;
        Http http = new Http();
        HttpResponse httpResponse;
        HttpResponse actualResponse = new HttpResponse();
        AccessTokenNLSWrapper objAccessTokenNLSWrapper = new AccessTokenNLSWrapper();
        Map<String,Object> currentDateResponseMap = new Map<String,Object>();
        Map<String,Object> payoffDateResponseMap = new Map<String,Object>();
        Map<String,Map<String,Object>> responseMap = new Map<String,Map<String,Object>>();

        try{
            for(Integer count=0;count<MAX_ACCESS_TOKEN_GENERATION_LIMIT;count++){
                accessToken = AccessTokenGenerator.getAccessToken();
                if(accessToken != null){
                    break;
                }
            }
            checkVariable(accessToken);
            objAccessTokenNLSWrapper = AccessTokenNLSWrapper.parse(accessToken);
            httprequest.setHeader(ConstantValues.AUTHORIZATION, objAccessTokenNLSWrapper.token_type 
                                    + ' ' + objAccessTokenNLSWrapper.access_token );
            endpointUrl = httpRequest.getEndpoint();

            //Current Date Callout
            for(String loanId : loanIdList){ //3
                Map<String,Object> perCurrentTrnMap = new Map<String,Object>();
                newEndpointUrl = endPointUrl;
                newEndpointUrl = endpointUrl.replace(LOAN_ID_PARAMETER, loanId);
                newEndpointUrl = newEndpointUrl + String.valueOf(System.today()).remove('-');
                httpRequest.setEndpoint(newEndpointUrl);
                httpResponse = http.send(httpRequest);
                if(httpResponse.getStatusCode() == 200){
                    Map<String, Object> mainResponse = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                    Map<String, Object> subResponse = (Map<String, Object>) mainResponse.get(PAYLOAD);
                    Map<String, Object> extractResponseMap = (Map<String, Object>)subResponse.get(DATA);
                    checkResponseData(extractResponseMap);
                    perCurrentTrnMap.put(PRINCIPAL_BALANCE,String.valueOf(extractResponseMap.get(PRINCIPAL_BALANCE)));
                    perCurrentTrnMap.put(ACCRUED_INTEREST,String.valueOf(extractResponseMap.get(ACCRUED_INTEREST)));
                    perCurrentTrnMap.put(FEES_DUE,String.valueOf(extractResponseMap.get(FEES_DUE)));
                    perCurrentTrnMap.put(SERVICING_FEE,String.valueOf(extractResponseMap.get(SERVICING_FEE)));
                    perCurrentTrnMap.put(LATE_CHARGES,String.valueOf(extractResponseMap.get(LATE_CHARGES)));
                    perCurrentTrnMap.put(PER_DIEM,String.valueOf(extractResponseMap.get(PER_DIEM)));
                    currentDateResponseMap.put(loanId,perCurrentTrnMap);
                }
            }

            //Expected Date Callout
            for(String loanId : loanIdList){
                Map<String,Object> perExpectedTrnMap = new Map<String,Object>();
                newEndpointUrl = endPointUrl;
                newEndpointUrl = endpointUrl.replace(LOAN_ID_PARAMETER, loanId);
                newEndpointUrl = newEndpointUrl + String.valueOf(String.valueOf(payoffDate));
                httpRequest.setEndpoint(newEndpointUrl);
                httpResponse = http.send(httpRequest);
                if(httpResponse.getStatusCode() == 200){
                    Map<String, Object> mainResponse = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                    Map<String, Object> subResponse = (Map<String, Object>) mainResponse.get(PAYLOAD);
                    Map<String, Object> extractResponseMap = (Map<String, Object>)subResponse.get(DATA);
                    checkResponseData(extractResponseMap);
                    perExpectedTrnMap.put(PRINCIPAL_BALANCE,String.valueOf(extractResponseMap.get(PRINCIPAL_BALANCE)));
                    perExpectedTrnMap.put(ACCRUED_INTEREST,String.valueOf(extractResponseMap.get(ACCRUED_INTEREST)));
                    perExpectedTrnMap.put(FEES_DUE,String.valueOf(extractResponseMap.get(FEES_DUE)));
                    perExpectedTrnMap.put(SERVICING_FEE,String.valueOf(extractResponseMap.get(SERVICING_FEE)));
                    perExpectedTrnMap.put(LATE_CHARGES,String.valueOf(extractResponseMap.get(LATE_CHARGES)));
                    perExpectedTrnMap.put(PER_DIEM,String.valueOf(extractResponseMap.get(PER_DIEM)));
                    payoffDateResponseMap.put(loanId,perExpectedTrnMap);
                }
            }
            
            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token); 

            responseMap.put(CURRENT_DATE_STRING,currentDateResponseMap);
            responseMap.put(PAYOFF_DATE_STRING,payoffDateResponseMap);

            actualResponse.setBody(String.valueOf(JSON.serialize(responseMap)));
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, NLS_LOAN_PAYOFF_CALCULATOR_ADAPTER);
        }
        return actualResponse;
    }
}