/**
 * @description       : Test Class to cover NLSFetchParticipantIdBatch/NLSFetchParticipantIdAdapter
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 11-29-2024
 * @last modified by  : Ayan Bhowmik
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   20-10-2022   Subham Nandi   Initial Version
**/
@isTest
public with sharing class TestNLSFetchParticipantIdBatch {
    @TestSetup
    static void makeData(){
        //Inserting Integration Family
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily(
            'NLS Integration 2');
        //Inserting Integration API Type
        intframework__Integration_API_Type__c getLoanApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Participants Id Integration API Type');   
        //Inserting Integration Provider
        intframework__Integration_Provider__c getLoanProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Get Participant Id');
        //Inserting Integration Configuration
        intframework__Integration_Configuration__c getLoanConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            getLoanProvider.Id,'NLS Get Participant Id Configuration','NLS');
        //Inserting Integration API Configuration
        intframework__Integration_API_Configuration__c getLoanApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            getLoanApiType.Id,
            getLoanProvider.Id,
            getLoanConfig.Id,
            false,
            'NLSFetchParticipantIdAdapter',
            'GET',
            'NLS',
            'loans/loanId/participants',
            '{"thirdPartySystem":{"name":"p","filters":[{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"pricing","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"loanId","fieldAPI":"Loan_Id__c"},{"externalField":"ParentLoanId","fieldAPI":"genesis__Application__r.Loan_Id__c"},{"externalField":"ParentId","fieldAPI":"genesis__Application__c"}],"whereClause":"Id IN :pricingId"}],"dynamicDataParameters":[{"externalField":"loanType"}]}}',
            'application/json',
            1
        );

        //Insert Application and Application Pricing Detail
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
        Database.update(objPricing,true);
    }
    
    /**
     * @description       : This class is setting up the Mock Response for the Participants Id
     * @author            : Simran
     * @group             : 
     * @last modified on  : 11-29-2024
     * @last modified by  : Ayan Bhowmik
    **/
    public class NLSGetParticipantsIdHttpCalloutMock implements HttpCalloutMock {

        /**
        * @description Implement this interface method
        * @author Simran | 03-12-2024 
        * @param request 
        * @return HTTPResponse 
        **/
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
                response.setBody('{"status":{"code":200,"message":"string"},'+
                '"payload":'+
                    '{"totalCount":0,"count":0,"data":'+
                        '[{"Participantrefno":998761,"Loan_Group_No":0,"Participant_Type":1,"Participant_Number":"string",'+
                        '"Cifno":0,"Shortname":"string","Name":"string","Input_Date":"2022-09-27T05:16:32.067Z","Status_Code_No":0,'+
                        '"Last_Activity_Date":"2022-09-27T05:16:32.067Z","Original_Note_Amount":0,"Current_Note_Amount":0,'+
                        '"Current_Principal_Balance":0,"Current_Interest_Balance":0,"Current_Def_Interest_Balance":0,'+
                        '"Current_Late_Charge_Balance":0,"Current_Payoff_Balance":0,"Current_Perdiem":0,"Current_Suspense":0,'+
                        '"Current_Interest_Rate":0,"Compound_Interest_Balance":0,"Current_Impound_Balance":0,"Current_Servicing_Balance":0,'+
                        '"Vendor_Id":0,"Next_Recurring_Trans_Date":"2022-09-27T05:16:32.067Z","Current_Reserve_Balance":0,'+
                        '"Addonint_Remaining":0,"Addonint_Total":0,"Current_TierRateNo":0}]}}');
            }
            return response;
        }
    }

    @isTest
    public static void testFetchParticipantIdForParentLoan(){
        Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
        NLSFetchParticipantIdBatch getChildPayOff = new NLSFetchParticipantIdBatch(true);
        Database.executeBatch(getChildPayOff , 90);
    }

    @isTest
    public static void testFetchParticipantIdForChildLoan(){
        Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
        NLSFetchParticipantIdBatch getChildPayOff = new NLSFetchParticipantIdBatch(false);
        Database.executeBatch(getChildPayOff , 90);
    }
}