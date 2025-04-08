/**
 * @description       : Sync Loans statuses
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-25-2025
 * @last modified by  : Ayan Khanra
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   14-01-2023   Subham Nandi   Initial Version
**/
global with sharing class NLSGetLoanStatusesAdapter extends intframework.BaseIntegrationAdapter{
    
    // parameters specific for this class [start]
    private static final String CLASS_NAME = NLSGetLoanStatusesAdapter.class.getName();
    private static final String KEY_APPLICATION = 'Application';
    private static final String FIELD_STATUS_CODE_NO = 'Status_Code_No';
    private static final String FIELD_ID = 'ID';
    private static final Integer STATUSCODE_EIGHTEEN = 18;
    private static final String NINE = '9';
    private static final String SPECIAL_TERM_REFERENCE = 'Special Term Sub-Tranche (A)';
    // parameters specific for this class [end]

    /*******************************Declaration of global variables*******************************************/
    String requestBody;
    List<String> applicationIdList = new List<String>();
    Map<String, Object> response = new Map<String, Object>();
    List<Map<String, Object>> activeApplicationList = new List<Map<String, Object>>();
    List<genesis__Applications__c> applicationList  = new List<genesis__Applications__c>();

    /**
     * @description Checking access object for current user
     * @exception 
     */
    private static void checkAccessOnObjects(){
        if((!Schema.sObjectType.clcommon__Party__c.isUpdateable())
                || (!Schema.sObjectType.genesis__Application_Pricing_Detail__c.isUpdateable())
                || (!Schema.sObjectType.genesis__Applications__c.isUpdateable())
                || (!Schema.sObjectType.Dealer_Applicant_Relationship__c.isUpdateable())
                ){
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
        }
    }
    
    /**
    * @description Method for generating request body based on the reuqest coming from int framework
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
        Http http = new Http();
        HttpResponse httpResponse;
        AccessTokenNLSWrapper accessTokenNLSWrapperObj = new AccessTokenNLSWrapper();
        try{
            accessToken = LoanServicingHelper.getNLSAccessToken();
            accessTokenNLSWrapperObj = AccessTokenNLSWrapper.parse(accessToken);
            httpRequest.setHeader(ConstantValues.AUTHORIZATION, 
                                    accessTokenNLSWrapperObj.token_type 
                                    + ConstantValues.SPACE_STRING 
                                    + accessTokenNLSWrapperObj.access_token);
            endpointUrl = httpRequest.getEndpoint();
            for(Map<String, Object> applicationMap: activeApplicationList){
                if(applicationMap.get(ConstantValues.LOAN_ID) == null){
                    continue;
                }
                genesis__Applications__c applicationObj = new genesis__Applications__c();
                newEndpointUrl = endpointUrl.replace(ConstantValues.LOAN_ID, String.valueOf(applicationMap.get(ConstantValues.LOAN_ID)));
                httpRequest.setEndpoint(newEndpointUrl);
                httpResponse = http.send(httpRequest);
                Map<String, Object> mainResponseMap = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                Map<String, Object> subResponseMap = (Map<String, Object>) mainResponseMap.get(ConstantValues.PAYLOAD);
                if(subResponseMap == null){
                    continue;
                }
                    
                List<Object> fieldResponseList = (List<Object>) subResponseMap.get(ConstantValues.DATA);
                if(fieldResponseList.isEmpty()){
                    continue;
                }

                //Getting the status of the loan based on the status in NLS
                Map<String, Object> fieldRessponseMap = (Map<String, Object>)fieldResponseList[0];
                
                //Mark the loan as Non Accrual if the status code is 18
                if(Integer.valueOf(fieldRessponseMap.get(FIELD_STATUS_CODE_NO)) == STATUSCODE_EIGHTEEN){
                    //The loan is non accrual
                    applicationObj.Non_Accrual__c = true;
                    //Since the Loan is non Accrual, It is no longer evergreen eligible
                    applicationObj.Is_Evergreen_Eligible__c = false;
                }
                applicationObj.Id = String.valueOf(applicationMap.get(FIELD_ID));

                applicationList.add(applicationObj);
                applicationIdList.add(applicationObj.Id);
            }
            AccessTokenGenerator.revokeAccessToken(accessTokenNLSWrapperObj.access_token);
            checkAccessOnObjects();
            Database.update(applicationList,true);

            updateNonAccrualOnAccount(applicationIdList);

            //Update Loan Number based on the Non Accrual flag
            updateLoanNumber(applicationIdList);
            return httpResponse;
        }
        catch (Exception objException) {
            AccessTokenGenerator.revokeAccessToken(accessTokenNLSWrapperObj.access_token);
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            return null;
        }
    }

     

    /**
    * @description : updating the Non_Accrual__c on Account of borrower and principal when their application gets non accrual.
    * @author Suraj Kumar | 02-05-2024 
    * @param applicationIdList 
    **/
    private static void updateNonAccrualOnAccount(List<String> applicationIdList){
        List<Id> partyDealerApplicantId = new List<Id>();
        if(applicationIdList.isEmpty()){
            return;
        }
        List<clcommon__Party__c> nonAccrualAppPartyList = [SELECT Id,
                                                                    Dealer_Applicant_Relationship__c 
                                                                FROM clcommon__Party__c 
                                                                WHERE clcommon__Party_Types__c IN (:ConstantValues.BORROWER_PARTY, :ConstantValues.PRINCIPAL_PARTY) 
                                                                AND genesis__Application__r.Non_Accrual__c = True
                                                                AND genesis__Application__c IN :applicationIdList
                                                                WITH SECURITY_ENFORCED];
        for(clcommon__Party__c partyObj: nonAccrualAppPartyList){
            partyDealerApplicantId.add(partyObj.Dealer_Applicant_Relationship__c);
        }
        if(!partyDealerApplicantId.isEmpty()){
            List<Dealer_Applicant_Relationship__c> partyDealerApplicantList = [SELECT Id,
                                                                                        Is_Non_Accrual__c
                                                                                    FROM Dealer_Applicant_Relationship__c
                                                                                    WHERE Id IN :partyDealerApplicantId
                                                                                    WITH SECURITY_ENFORCED];
            for(Dealer_Applicant_Relationship__c dealerApplicantRelObj: partyDealerApplicantList){
                dealerApplicantRelObj.Is_Non_Accrual__c = True;
                dealerApplicantRelObj.Is_Evergreen_Eligible__c = false;
            }
            Database.update(partyDealerApplicantList,true);
        }
    }

    /**
    * @description Method to update parent loan number
    * @author Suraj Kumar | 02-05-2024 
    * @param applicationIdList 
    **/
    private static void updateLoanNumber(List<String> applicationIdList){
        List<String> updatedLoanNumberIdList = new List<String>();
        List<genesis__Applications__c> appListToUpdate = [SELECT Id,
                                                                genesis__Loan_Number__c,
                                                                Non_Accrual__c,
                                                                genesis__Status__c
                                                            FROM genesis__Applications__c
                                                            WHERE genesis__Loan_Number__c != NULL
                                                            AND Non_Accrual__c = True
                                                            AND Id IN : applicationIdList
                                                            WITH SECURITY_ENFORCED];
        for(genesis__Applications__c eachApplication : appListToUpdate ){
            //Non Accrual Loan 
            //Check if the loan number is an Active Number
            if(String.valueOf(eachApplication.genesis__Loan_Number__c).substring(0,1) != NINE){
                //Update the loan number and append 9 at front
                eachApplication.genesis__Loan_Number__c = NINE + eachApplication.genesis__Loan_Number__c;
                updatedLoanNumberIdList.add(eachApplication.Id);
            }
        }
        Database.update(appListToUpdate,true);
        //Query the Child Loans and update the loan numbers
        updateChildLoanNumber(updatedLoanNumberIdList);

        //Update the loan Id for the non accrual loans

        for(genesis__Applications__c eachApplication : appListToUpdate ){
            //Non Accrual Loan 
            //Check if the loan number is an Active Number
            if(String.valueOf(eachApplication.genesis__Loan_Number__c).substring(0,1) == NINE){
                 //update loan id
                 System.enqueueJob(new FetchLoanIdQueueable( eachApplication.genesis__Loan_Number__c, eachApplication.Id));
            }
        }
    }

    /**
    * @description Method to update child loan number
    * @author Suraj Kumar | 02-05-2024 
    * @param updatedLoanNumberIdList 
    **/
    private static void updateChildLoanNumber(List<String> updatedLoanNumberIdList){
        if(updatedLoanNumberIdList.isEmpty()){
            return;
        }
        List<genesis__Application_Pricing_Detail__c> childLoanList = [SELECT Id, 
                                                                            loan_Number__c,
                                                                            genesis__Application__r.Non_Accrual__c,
                                                                            genesis__Enabled_Flag__c,
                                                                            genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c,
                                                                            genesis__Rate_Card_Setup_Detail__r.Special_Term_Order__c,
                                                                            genesis__Rate_Card_Setup_Detail__r.Start_Date__c,
                                                                            genesis__Rate_Card_Setup_Detail__r.End_Date__c,
                                                                            Payoff_Amount_via_Mobile__c, 
                                                                            Fees__c,
                                                                            Accrued_Interest__c,  
                                                                            Principal_Advanced__c, 
                                                                            Credit_Balance__c, 
                                                                            Interest_Per_Diem__c, 
                                                                            Payoff_Amount_via_US_Mail__c,
                                                                            Dealer_Interest_Accrued__c , 
                                                                            Dealer_Interest_Per_Diem__c,
                                                                            genesis__Application__r.genesis__Loan_Number__c
                                                                    FROM genesis__Application_Pricing_Detail__c 
                                                                    WHERE genesis__Application__c IN : updatedLoanNumberIdList
                                                                    WITH SECURITY_ENFORCED];
        for(genesis__Application_Pricing_Detail__c eachChildLoan : childLoanList){
            if(eachChildLoan.genesis__Application__r.Non_Accrual__c){
                //Changed to Non Accrual
                eachChildLoan.Loan_Number__c = eachChildLoan.genesis__Application__r.genesis__Loan_Number__c;
                
                //de-avticate all the loans except for the 1st sub tranche loan
                if(eachChildLoan.genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c == SPECIAL_TERM_REFERENCE
                            && eachChildLoan.genesis__Rate_Card_Setup_Detail__r.Special_Term_Order__c == 1){
                    eachChildLoan.genesis__Enabled_Flag__c = true;
                }
                else{
                    eachChildLoan.genesis__Enabled_Flag__c = false;
                    eachChildLoan.Payoff_Amount_via_Mobile__c = 0;
                    eachChildLoan.Fees__c = 0;
                    eachChildLoan.Accrued_Interest__c = 0;
                    eachChildLoan.Principal_Advanced__c = 0;
                    eachChildLoan.Credit_Balance__c = 0;
                    eachChildLoan.Interest_Per_Diem__c = 0;
                    eachChildLoan.Payoff_Amount_via_US_Mail__c = 0;
                }
            }
        }                                                            
        Database.update(childLoanList,true);
    }
}