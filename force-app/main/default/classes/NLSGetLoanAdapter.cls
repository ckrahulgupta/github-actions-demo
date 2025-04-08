/**
 * @description       : 
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 11-26-2024
 * @last modified by  : Ayan Bhowmik
**/
global with sharing class NLSGetLoanAdapter extends intframework.BaseIntegrationAdapter{
    
    // parameters specific for this class [start]
    private static final Integer MAX_ACCESS_TOKEN_GENERATION_LIMIT = 2;
    private static final String CLASS_NAME = 'NLSGetLoanAdapter';
    private static final String KEY_APPLICATION = 'Application';
    private static final String FIELD_STATUS_CODE_NO = 'Status_Code_No';
    private static final String FIELD_CURRENT_INTEREST_RATE = 'Current_Interest_Rate';
    private static final String FIELD_CURRENT_MATURITY_DATE = 'Curr_Maturity_Date';
    private static final String FIELD_CURRENT_PRINCIPAL_BALANCE = 'Current_Principal_Balance';
    private static final String FIELD_CURRENT_SUSPENSE = 'Current_Suspense';
    private static final String FIELD_CURRENT_PERDIEM = 'Current_Perdiem';
    private static final String FIELD_CURRENT_FEES_BALANCE = 'Current_Fees_Balance';
    private static final String FIELD_PAST_DUE_BALANCE = 'Total_Past_Due_Balance';
    private static final String FIELD_INTEREST_ACCRUED_DATE = 'Interest_Accrued_Thru_Date';
    private static final String FIELD_ID = 'ID';
    private static final Integer STATUSCODE_0 = 0;
    private static final Integer STATUSCODE_1 = 1;
    private static final Integer STATUSCODE_18 = 18;
    private static final Integer STATUSCODE_20 = 20;
    private static final Integer STATUSCODE_200 = 200;
    // parameters specific for this class [end]

    /*******************************Declaration of global variables*******************************************/
    String requestBody;
    List<Map<String, Object>> activeApplicationList = new List<Map<String, Object>>();
    Map<String, Object> response = new Map<String, Object>();
    List<genesis__Applications__c> objApplicationList  = new List<genesis__Applications__c>();
    
    /**
    * @description 
    * @author Arka Jyoti Deb | 04-28-2022 
    * @param requestMap 
    * @return String 
    **/
    public override String generateRequestBody(Map<String, Object> requestMap){
        activeApplicationList = (List<Map<String, Object>>)requestMap.get(KEY_APPLICATION);
        return requestBody; 
    }
    
    
    /**
    * @description - This method is responsible for performing the third party call-out 
    * @author Arka Jyoti Deb | 04-28-2022 
    * @param httpRequest 
    * @return System.HttpResponse 
    **/
    public override System.HttpResponse sendRequest(System.HttpRequest httpRequest){
        
        //Instantiating a new http request and new data types
        String endpointUrl;
        String newEndpointUrl;
        String accessToken;
        String loanStatus;
        Http http = new Http();
        HttpResponse objHttpResponse;
        Attachment attachmentObj = new Attachment();
        AccessTokenNLSWrapper objAccessTokenNLSWrapper = new AccessTokenNLSWrapper();
        try{
            for(Integer count=0;count<MAX_ACCESS_TOKEN_GENERATION_LIMIT;count++){
                accessToken = AccessTokenGenerator.getAccessToken();
                if(accessToken != null){
                	break;
            	}
            }
            if(accessToken == null){
                throw new CustomException(ConstantValues.ACCESS_TOKEN_NULL);
            }
            objAccessTokenNLSWrapper = AccessTokenNLSWrapper.parse(accessToken);
            httpRequest.setHeader(  ConstantValues.AUTHORIZATION, 
                                    objAccessTokenNLSWrapper.token_type + ' ' + 
                                    objAccessTokenNLSWrapper.access_token );
            endpointUrl = httpRequest.getEndpoint();
            //Get the Non Accrual Application
            List<String> parentApplicationIdList = new List<String>();
            for(Map<String, Object> objApplicationMap: activeApplicationList){
                parentApplicationIdList.add(String.valueOf(objApplicationMap.get(FIELD_ID)));
            }
            Map<String,boolean> parentLoanToAccrualStatusMap = new Map<String,Boolean>();
            //Query the Non Accrual field
            List<genesis__Applications__c> objParentLoans = [SELECT Id, 
                                                                    Non_Accrual__c 
                                                            FROM genesis__Applications__c 
                                                            WHERE Id IN :parentApplicationIdList];
            for(genesis__Applications__c eachApplication : objParentLoans){
                parentLoanToAccrualStatusMap.put(eachApplication.Id,eachApplication.Non_Accrual__c);
            }
            for(Map<String, Object> objApplicationMap: activeApplicationList){
                if(String.valueOf(objApplicationMap.get(ConstantValues.LOAN_ID)) != null){

                    newEndpointUrl = endpointUrl.replace(ConstantValues.LOAN_ID, String.valueOf(objApplicationMap.get(ConstantValues.LOAN_ID)));
                    httpRequest.setEndpoint(newEndpointUrl);
                    objHttpResponse = http.send(httpRequest);
                    Map<String, Object> mainResponseMap = (Map<String, Object>) JSON.deserializeUntyped(objHttpResponse.getBody());
                    Map<String, Object> subResponseMap = (Map<String, Object>) mainResponseMap.get(ConstantValues.PAYLOAD);
                    if(subResponseMap != null){
                        Map<String, Object> fieldResponseMap = (Map<String, Object>) subResponseMap.get(ConstantValues.DATA);
                        if(Integer.valueOf(fieldResponseMap.get(FIELD_STATUS_CODE_NO)) == STATUSCODE_0){
                            loanStatus = ConstantValues.ACTIVE;
                        }
                        else if(Integer.valueOf(fieldResponseMap.get(FIELD_STATUS_CODE_NO)) == STATUSCODE_1){
                            loanStatus = ConstantValues.CLOSED;
                        }
                        else if(Integer.valueOf(fieldResponseMap.get(FIELD_STATUS_CODE_NO)) == STATUSCODE_18){
                            loanStatus = ConstantValues.NON_ACCRUAL;
                        }
                        else if(Integer.valueOf(fieldResponseMap.get(FIELD_STATUS_CODE_NO)) == STATUSCODE_20){
                            loanStatus = ConstantValues.IMPORTED;
                        }
                        genesis__Applications__c objApplication = new genesis__Applications__c();
                        objApplication.Id = String.valueOf(objApplicationMap.get(FIELD_ID));
                        objApplication.genesis__Interest_Rate__c = Decimal.valueOf(String.valueOf(fieldResponseMap.get(FIELD_CURRENT_INTEREST_RATE)));
                        if(!parentLoanToAccrualStatusMap.get(objApplication.Id)){
                            objApplication.genesis__Maturity_Date__c = Date.valueOf(Datetime.valueOf(String.valueOf(fieldResponseMap.get(FIELD_CURRENT_MATURITY_DATE)).replace('T', ' ')));
                        }
                        objApplication.Interest_Per_Diem__c = Decimal.valueOf(String.valueOf(fieldResponseMap.get(FIELD_CURRENT_PERDIEM)));
                        objApplication.genesis__Status__c = loanStatus;
                        objApplication.genesis__Fees_Amount__c = Decimal.valueOf(String.valueOf(fieldResponseMap.get(FIELD_CURRENT_FEES_BALANCE)));
                        // objApplication.Past_Due_Balance__c = Decimal.valueOf(String.valueOf(fieldResponseMap.get(FIELD_PAST_DUE_BALANCE)));
                        // objApplication.Interest_Accrued_Thru_Date__c = Datetime.valueOf(String.valueOf(fieldResponseMap.get(FIELD_INTEREST_ACCRUED_DATE)).replace('T', ' '));
                        //Check if the Parent Loan is closed, i.e there is a payoff date 'Payoff_Date'
                        if(String.valueOf(fieldResponseMap.get('Payoff_Date')) != null){
                            //The Loan is closed - change the status of the loan to Closed
                            objApplication.genesis__Status__c = ConstantValues.CLOSED;
                            //Populate the Pay Off Date in the application
                            objApplication.Pay_Off_Date__c = Date.valueOf(Datetime.valueOf(String.valueOf(fieldResponseMap.get('Payoff_Date')).replace('T', ' ')));
                            objApplication.Pay_Off__c = 'Yes';
                        }
                        objApplicationList.add(objApplication);

                    }
                }
            }
            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);
            Database.update(objApplicationList,true);
            return objHttpResponse;
        }
        catch (Exception objException) {
            AccessTokenGenerator.revokeAccessToken(objAccessTokenNLSWrapper.access_token);
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            return null;
        }
    }
}