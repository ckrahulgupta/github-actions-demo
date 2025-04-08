/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 11-29-2024
 * @last modified by  : Ayan Bhowmik
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   08-02-2023   Subham Nandi   Initial Version
**/
@isTest
public with sharing class TestNLSGetChildLoanDayBatch {
    @testSetup
    static void setup(){
        //Setting up the Integration Framework to fetch the child pay off details
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily('NLS Integration');
        intframework__Integration_API_Type__c getChildPayoffDetailsAPIType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Get Child Payoff Day API Type');
        intframework__Integration_Provider__c getChildPayoffDetailsProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Payoff Details');
        intframework__Integration_Configuration__c getChildPayoffDetailsConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            getChildPayoffDetailsProvider.Id,'NLS Payoff Details Integration Configuration','NLS');
        intframework__Integration_API_Configuration__c getChildPayoffDetailsApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            getChildPayoffDetailsAPIType.Id,
            getChildPayoffDetailsProvider.Id,
            getChildPayoffDetailsConfig.Id,
            false,
            'NLSChildPayoffDetailsDayAdapter',
            'GET',
            'NLS',
            'loans/loanId/payoff-details?payoffDate=',
            '{ "thirdPartySystem": {  "name": "Payoff Details",  "filters": [   {    "objectAPI": "genesis__Application_Pricing_Detail__c",    "objectAlias": "Pricing Details",    "fields": [     {      "externalField": "ID",      "fieldAPI": "Id"     },     {      "externalField": "loanId",      "fieldAPI": "Loan_Id__c"     }    ],    "whereClause": "Id IN :applicationIdList"   }  ] }}',
            'application/json',
            1);
        
        genesis__Applications__c objApplicationToFetchLoanDetails = TestClassHelper.createApplication();
        Account objDealerAccount = new Account(Id = (Id)objApplicationToFetchLoanDetails.Dealer_Name__c);
        genesis__Business_Information__c objDealerBusinessInfo = new genesis__Business_Information__c ( Approved_Loan_Amount__c = 0,
                                                                                                        Contract_Loan_Limit__c = 1000000,  
                                                                                                        Customised_Loan_Limit__c = 500000, 
                                                                                                        Customised_Individual_Limit__c = 250000, 
                                                                                                        Remaining_Customised_Limit__c = 500000);
        Database.insert(objDealerBusinessInfo,true);
        objDealerAccount.genesis__Business_Information__c = objDealerBusinessInfo.Id;
        Database.update(objDealerAccount,true);
        objApplicationToFetchLoanDetails.genesis__Status__c = 'ACTIVE';
        Database.update(objApplicationToFetchLoanDetails,true);
        genesis__Application_Pricing_Detail__c objPricing = TestClassHelper.createPricingDetail(objApplicationToFetchLoanDetails.Id);
        objPricing.Loan_ID__c = '167543';
        objPricing.genesis__Enabled_Flag__c = true;
        objPricing.Accrued_Interest__c = 10;
        objPricing.Principal_Advanced__c = 100;
        Database.update(objPricing,true);

        //Create Pending Payment to update the amounts
        clcommon__Payment_Mode__c paymentMode = new clcommon__Payment_Mode__c(Name = 'PAYMENT');
        insert paymentMode;
        genesis__Funding_Transaction__c pendingPayment = new genesis__Funding_Transaction__c(Interest_Paid__c = 0.1, Principal_Paid__c = 0.1, Fees_Paid__c = 0.1, genesis__Payment_Mode__c = paymentMode.Id, Pricing_Detail__c = objPricing.Id, genesis__Cleared__c = true, Posted_to_NLS__c = false);
        insert pendingPayment;

        //Setting up the Integration Framework to fetch the Payoff Via Mail Rates
        intframework__Integration_API_Type__c getChildPayoffViaMailAPIType = IntegrationTestInitHelper.getIntegrationAPIType(family.Id, 
                                                                                                                    'Get Child Mail Payoff Day API Type');
        //Int Family family
        //Int Provider getChildPayoffDetailsProvider
        //Int Config getChildPayoffDetailsConfig
        intframework__Integration_API_Configuration__c getChildPayoffViaMailDetailsApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            getChildPayoffViaMailAPIType.Id,
            getChildPayoffDetailsProvider.Id,
            getChildPayoffDetailsConfig.Id,
            false,
            'NLSChildPayoffViaMailDayAdapter',
            'GET',
            'NLS',
            'loans/{!loan_id}/payoff-details?payoffDate={!payoffDate}',
            '{ "thirdPartySystem": {  "name": "Payoff Details",  "filters": [   {    "objectAPI": "genesis__Application_Pricing_Detail__c",    "objectAlias": "Pricing Details",    "fields": [     {      "externalField": "ID",      "fieldAPI": "Id"     },     {      "externalField": "loanId",      "fieldAPI": "Loan_Id__c"     }    ],    "whereClause": "Id IN :applicationIdList"   }  ] }}',
            'application/json',
            1);
        
        
    }


    
    /**
     * @description This class implements a interface method which return a mock response of NLS to get child loan details
     */
    public class NLSGetChildPayOffHttpCalloutMock implements HttpCalloutMock {
        // Implement this interface method
        /**
         * @description This method returns mock response of NLS to get child loan details
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('SUCCESS');
            response.setHeader('Content-Type', 'application/json');
            if(request.getEndpoint().contains('token')){
                String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
            }
            else{
                response.setBody('{"status":{"code":200,"message":"Success"},'+
                '"payload":{"data":{"LoanNumber":"343066041-A","ShortName":"BOOKINGTOCORELLC",'+
                    '"LoanGroup":"INPUT","InterestPaidThrough":"05/18/2022","PrincipalPaidThrough":"05/18/2022",'+
                    '"LoanDate":"05/19/2022","FeesDue":0.0,"LateCharges":0.0,"MaturityDate":"05/15/2023","PayoffDate":"06/10/2022",'+
                    '"InterestRate":7.0,"PerDiem":0.8166666667,"PrincipalBalance":4200.0,"AccruedInterest":15.51,"PayoffAmount":4215.51,'+
                    '"Suspense":0.0,"ServicingFee":0.0,"UserDefinedLoanBalances":{"UserDefinedLoanBalance1":0.0,"UserDefinedLoanBalance2":0.0,'+
                        '"UserDefinedLoanBalance3":0.0,"UserDefinedLoanBalance4":0.0,"UserDefinedLoanBalance5":0.0,"UserDefinedLoanBalance6":0.0,'+
                        '"UserDefinedLoanBalance7":0.0,"UserDefinedLoanBalance8":0.0,"UserDefinedLoanBalance9":0.0,"UserDefinedLoanBalance10":0.0}}}}');
            }
            return response;
        }
    }

    

    @isTest
    public static void testChildPayOff(){
        NLSGetChildLoanDetailsDaySchedule childLoanDetails = new NLSGetChildLoanDetailsDaySchedule();
        String cronExpression = '0 0 23 * * ?';
        System.schedule('Test Get Child Loan', cronExpression, childLoanDetails);
    }
    //Test Class to cover exception in the callout class
    @isTest
    public static void testChildPayOff2(){
        List<intframework__Integration_API_Configuration__c> intFrameList = new List<intframework__Integration_API_Configuration__c>();
        intframework__Integration_API_Configuration__c loanDetailsIntFrameWork = [SELECT Id FROM intframework__Integration_API_Configuration__c WHERE intframework__Adapter_Class_Name__c = 'NLSChildPayoffViaMailDayAdapter'];
        intFrameList.add(loanDetailsIntFrameWork);
        intframework__Integration_API_Configuration__c creditLinesIntFrameWork = [SELECT Id FROM intframework__Integration_API_Configuration__c WHERE intframework__Adapter_Class_Name__c = 'NLSChildPayoffDetailsDayAdapter'];
        intFrameList.add(creditLinesIntFrameWork);
        Database.delete(intFrameList);
        NLSChildPayoffDetailsDayCalloutBatch getChildPayOff = new NLSChildPayoffDetailsDayCalloutBatch();
        Database.executeBatch(getChildPayOff , 200);
    }

    //Success scenario for the callout to happen
    @isTest
    public static void testChildPayOff3(){
        NLSChildPayoffDetailsDayCalloutBatch getChildPayOff = new NLSChildPayoffDetailsDayCalloutBatch();
        Database.executeBatch(getChildPayOff , 200);
    }

    //Success scenario for the callout to happen
    //Callout For Child Payoff --> Fees , Accrued Interest, Payoff_Amount_via_Mobile__c
    @isTest
    public static void testChildPayOff4(){
        Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffHttpCalloutMock());
        NLSChildPayoffDetailsDayCalloutBatch getChildPayOff = new NLSChildPayoffDetailsDayCalloutBatch();
        Database.executeBatch(getChildPayOff , 200);
    }
    
}