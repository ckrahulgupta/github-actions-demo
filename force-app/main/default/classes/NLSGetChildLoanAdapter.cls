/**
 * @description       : Sync Child Loans
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 02-26-2025
 * @last modified by  : Shruti Tamakhuwala
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   10-03-2023   Subham Nandi   Initial Version
**/


global with sharing class NLSGetChildLoanAdapter  extends intframework.BaseIntegrationAdapter{
    //Constants specific to this class starts
    private static final String FIELD_CURRENT_INTEREST_RATE = 'Current_Interest_Rate';
    private static final String FIELD_CURRENT_MATURITY_DATE = 'Curr_Maturity_Date';
    private static final String FIELD_CURRENT_PRINCIPAL_BALANCE = 'Current_Principal_Balance';
    private static final String FIELD_CURRENT_SUSPENSE = 'Current_Suspense';
    private static final String FIELD_CURRENT_PERDIEM = 'Current_Perdiem';
    private static final String FIELD_INTEREST_BALANCE = 'Current_Interest_Balance';
    private static final String FIELD_INTEREST_ACCRUED_DATE = 'Interest_Accrued_Thru_Date';
    private static final String FIELD_PAST_DUE_BALANCE = 'Total_Past_Due_Balance'; 
    private static final String FIELD_LOAN_NUMBER = 'Loan_Number';
    private static final String KEY_ID = 'ID';
    private static final String KEY_PRICING_DETAILS = 'Pricing Details';
    private static final String KEY_T = 'T';
    //constants specific to this class ends

    String requestBody = ConstantValues.EMPTY_STRING;
    Map<String, Object> response = new Map<String, Object>();
    Map<String,String> childAppVsParentMap = new Map<String,String>();
    Map<String,boolean> childLoanAccrualStatusMap = new Map<String,Boolean>();
    List<Map<String, Object>> activeApplicationList = new List<Map<String, Object>>();
    List<genesis__Application_Pricing_Detail__c> childApplicationObjList  = new List<genesis__Application_Pricing_Detail__c>();
    
    /**
    * @description Method for generating request body based on the reuqest coming from int framework
    * @author Ayan Bhowmik | 01-16-2025 
    * @param requestMapping 
    * @return String 
    **/
    public override String generateRequestBody(Map<String, Object> requestMapping){
        activeApplicationList = (List<Map<String, Object>>)requestMapping.get(KEY_PRICING_DETAILS);
        return requestBody; 
    }

   
    /**
    * @description Checking access object for current user
    * @author Tuhin Bhunia | 05-12-2024 
    **/
    private static void checkAccessOnObjects(){
        if((!Schema.sObjectType.genesis__Application_Pricing_Detail__c.isUpdateable())
                || (!Schema.sObjectType.Dealer_Applicant_Relationship__c.isUpdateable())
                ){
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
        }
    }
    /**
    * @description : Update Past Due in User Account
    * @author  Pritam Roy | 06-16-2024 
    * @param appSet 
    **/
    private static void updateAccounts(Set<Id> appSet){
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList = new List<Dealer_Applicant_Relationship__c>();
        List<clcommon__party__c> appPartiesList = [SELECT Id,
                                                            clcommon__Account__c,
                                                            Dealer_Applicant_Relationship__c,
                                                            clcommon__Account__r.Has_Past_Due__c 
                                                        FROM clcommon__party__c 
                                                        WHERE clcommon__Type__r.Name IN (:ConstantValues.BORROWER_PARTY,
                                                                                                :ConstantValues.PRINCIPAL_PARTY)
                                                        AND Dealer_Applicant_Relationship__r.Has_Past_Due__c != true
                                                        AND genesis__Application__c IN :appSet 
                                                        WITH SECURITY_ENFORCED];
        for(clcommon__Party__c eachParty : appPartiesList){
            Dealer_Applicant_Relationship__c dealerApplicantRelation = new Dealer_Applicant_Relationship__c(Id = eachParty.Dealer_Applicant_Relationship__c);
            dealerApplicantRelation.Has_Past_Due__c = true;
            dealerApplicantRelation.Is_Evergreen_Eligible__c = false;
            dealerApplicantRelList.add(dealerApplicantRelation);
        }
        Database.update(dealerApplicantRelList, true);
    }

    /**
    * @description : Get Child Loan Details and store in Map
    * @author  Pritam Roy | 06-16-2024 
    **/
    public void getChildLoan(){
        List<String> childApplicationIdList = new List<String>();
        for(Map<String, Object> childApplicationMap: activeApplicationList){
            childApplicationIdList.add(String.valueOf(childApplicationMap.get(KEY_ID)));
        }
        //Fetch the Child Applications and Accrual Status
        List<genesis__Application_Pricing_Detail__c> childApplicationList = [SELECT Id,
                                                                                    genesis__Application__c, 
                                                                                    genesis__Application__r.Non_Accrual__c 
                                                                            FROM genesis__Application_Pricing_Detail__c
                                                                            WHERE Id IN :childApplicationIdList
                                                                            WITH SECURITY_ENFORCED];
        for(genesis__Application_Pricing_Detail__c eachChildLoan : childApplicationList){
            childLoanAccrualStatusMap.put(eachChildLoan.Id,eachChildLoan.genesis__Application__r.Non_Accrual__c);
            childAppVsParentMap.put(eachChildLoan.Id,eachChildLoan.genesis__Application__c);
        }
    }
    
    /**
    * @description : This method is responsible for performing the third party call-out 
    * @author  Pritam Roy | 06-16-2024 
    * @param httpRequest 
    * @return System.HttpResponse 
    **/
    public override System.HttpResponse sendRequest(System.HttpRequest httpRequest){
        
        //Instantiating a new http request and new data types
        String endpointUrl;
        String newEndpointUrl;
        String accessToken;
        Http http = new Http();
        HttpResponse httpResponse;
        Set<Id> appSet = new Set<Id>();
        Map<String, Object> mainResponse;
        Map<String, Object> subResponse;
        Map<String, Object> fieldResponse;

        AccessTokenNLSWrapper accessTokenNLSWrapperObj = new AccessTokenNLSWrapper();
        try{
            accessToken = LoanServicingHelper.getNLSAccessToken();
            accessTokenNLSWrapperObj = AccessTokenNLSWrapper.parse(accessToken);
            httprequest.setHeader(ConstantValues.AUTHORIZATION, accessTokenNLSWrapperObj.token_type 
                                    + ConstantValues.SPACE_STRING + accessTokenNLSWrapperObj.access_token );
            endpointUrl = httpRequest.getEndpoint();
            getChildLoan();

            for(Map<String, Object> childApplicationMap: activeApplicationList){
                genesis__Application_Pricing_Detail__c childApplicationObj = new genesis__Application_Pricing_Detail__c();
                if(childApplicationMap.get(ConstantValues.LOAN_ID) == null){
                    continue;
                }
                newEndpointUrl = endpointUrl.replace(ConstantValues.LOAN_ID, String.valueOf(childApplicationMap.get(ConstantValues.LOAN_ID)));
                httpRequest.setEndpoint(newEndpointUrl);
                httpResponse = http.send(httpRequest);
                if(httpResponse.getStatusCode() != 200){
                    continue;
                }
                mainResponse = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                subResponse = (Map<String, Object>) mainResponse.get(ConstantValues.PAYLOAD);
                fieldResponse = (Map<String, Object>) subResponse.get(ConstantValues.DATA);
                childApplicationObj.Id = String.valueOf(childApplicationMap.get(KEY_ID));
                childApplicationObj.genesis__Interest_Rate__c = Decimal.valueOf(String.valueOf(fieldResponse.get(FIELD_CURRENT_INTEREST_RATE)));
                childApplicationObj.Maturity_Date__c = Date.valueOf(Datetime.valueOf(String.valueOf(fieldResponse.get(FIELD_CURRENT_MATURITY_DATE)).replace(KEY_T,ConstantValues.SPACE_STRING)));
                childApplicationObj.Principal_Advanced__c = Decimal.valueOf(String.valueOf(fieldResponse.get(FIELD_CURRENT_PRINCIPAL_BALANCE)));
                childApplicationObj.Credit_Balance__c = Decimal.valueOf(String.valueOf(fieldResponse.get(FIELD_CURRENT_SUSPENSE)));
                childApplicationObj.Interest_Per_Diem__c = Decimal.valueOf(String.valueOf(fieldResponse.get(FIELD_CURRENT_PERDIEM)));
                childApplicationObj.genesis__Total_Interest__c = Decimal.valueOf(String.valueOf(fieldResponse.get(FIELD_INTEREST_BALANCE)));
                childApplicationObj.Interest_Accrued_Thru_Date__c = Datetime.valueOf(String.valueOf(fieldResponse.get(FIELD_INTEREST_ACCRUED_DATE)).replace(KEY_T, ConstantValues.SPACE_STRING));
                if(!childLoanAccrualStatusMap.get(childApplicationObj.Id)){
                    childApplicationObj.Loan_Number__c = String.valueOf(fieldResponse.get(FIELD_LOAN_NUMBER));
                }
                childApplicationObj.Past_Due_Balance__c = Decimal.valueOf(String.valueOf(fieldResponse.get(FIELD_PAST_DUE_BALANCE)));
                childApplicationObjList.add(childApplicationObj);
                if(childApplicationObj.Past_Due_Balance__c > 0){
                    appSet.add(childAppVsParentMap.get(childApplicationObj.Id));
                }
            }
            AccessTokenGenerator.revokeAccessToken(accessTokenNLSWrapperObj.access_token);
            checkAccessOnObjects();
            updateAccounts(appSet);
            Database.update(childApplicationObjList,true);
            return httpResponse;
        }
        catch (Exception exceptionObj) {
            AccessTokenGenerator.revokeAccessToken(accessTokenNLSWrapperObj.access_token);
            LoggingUtility.saveExceptionLogging(exceptionObj , NLSGetChildLoanAdapter.class.getName());
            return null;
        }
    }
}