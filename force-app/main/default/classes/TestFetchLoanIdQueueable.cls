/**
 * @description       : Test class for FetchLoanIdQueueable
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-14-2024
 * @last modified by  : Suraj Kumar
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   01-06-2022   Subham Nandi   Initial Version
**/
@isTest
public with sharing class TestFetchLoanIdQueueable {
    @TestSetup
    static void makeData(){
        //Make the integration framework
        //Inserting Integration Family
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily(
            'NLS Integration');
        //Inserting Integration API Type
        intframework__Integration_API_Type__c GetLoanAPIType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, ConstantValues.INTEGRATION_API_TYPE_GET_LOANID);
        //Inserting Integration Provider
        intframework__Integration_Provider__c GetLoanIdProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Search Loans');
        //Inserting Integration Configuration
        intframework__Integration_Configuration__c GetLoanIdIntegrationConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            GetLoanIdProvider.Id,'NLS Search Loans Integration Configuration','NLS');
        //Inserting Integration API Configuration
        intframework__Integration_API_Configuration__c getLoanIdApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            GetLoanAPIType.Id,
            GetLoanIdProvider.Id,
            GetLoanIdIntegrationConfig.Id,
            false,
            'NLSLoanSearchAdapter',
            'POST',
            'NLS',
            '/loans/search',
            '{"thirdPartySystem": {"name": "Test","filters": [],"dynamicDataParameters": [{"externalField": "loanNumber"}]}}',
            'application/xml',
            1
        );
    }
     /**
 * @description       : Setting up the Mock Response of SUCCESS status
 * @author            : Suraj kumar
 * @last modified on  : 03-14-2024
 * @last modified by  : Suraj Kumar
**/
    public class NLSFetchGetLoanID implements HttpCalloutMock {
        // Implement this interface method
        /**
        * @description : returns the Mock Response of SUCCESS status
        * @author Suraj Kumar | 03-14-2024 
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            System.debug('---2>');
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('SUCCESS');
            response.setHeader('Content-Type', 'application/json');
            if(request.getEndpoint().contains('token')){
                String token = '{"access_token":"944dfe344a845487314d9kio0lpokiu8","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
            }
            else{
                response.setBody('{"status":{"code":200,"message":"Success"},"payload":{"totalCount":1,"count":1,"data":[{"Acctrefno":176614,"Loan_Type":3,"Portfolio_Code_Id":0,"Loan_Number":"34306625001","Cifno":39379,"Loan_Group_No":4,"Shortname":"PARK AVENUE","Name":"PARK AVENUE","Loan_Class1_No":68,"Loan_Class2_No":0,"Risk_Rating_No":3,"Entity":"LIMITED LIABILITY COMPANY","Branch_Cifno":null,"Status_Code_No":0,"Loan_Officer_No":0,"Collection_Officer_No":0,"Dealer_Cifno":null,"Master_Acctrefno":0,"Pool_Acctrefno":0,"Shadow_Loan_Exists":false,"Curr_Maturity_Date":"2023-12-15T00:00:00","Interest_Accrued_Thru_Date":"2022-05-28T00:00:00","Current_Note_Amount":0.00,"Current_Payoff_Balance":0.0000000000,"Days_Past_Due":0,"Closed_Date":null}]}}');
            }
            return response;
        }
    }
    @isTest
    public static void testGetLoanId(){
        Test.setMock(HttpCalloutMock.class, new NLSFetchGetLoanID());

        //Insert Application and Application Pricing Detail
        genesis__Applications__c objApplication = TestClassHelper.createApplication();
        Account objDealerAccount = new Account(Id = (Id)objApplication.Dealer_Name__c);
        genesis__Business_Information__c objDealerBusinessInfo = new genesis__Business_Information__c ( Approved_Loan_Amount__c = 0,
                                                                                                        Contract_Loan_Limit__c = 1000000,  
                                                                                                        Customised_Loan_Limit__c = 500000, 
                                                                                                        Customised_Individual_Limit__c = 250000, 
                                                                                                        Remaining_Customised_Limit__c = 500000);
        Database.insert(objDealerBusinessInfo,true);
        objDealerAccount.genesis__Business_Information__c = objDealerBusinessInfo.Id;
        Database.update(objDealerAccount,true);
        Test.startTest();
        FetchLoanIdQueueable fetchLoanCalloutClass = new FetchLoanIdQueueable(objApplication.genesis__Loan_Number__c , objApplication.Id);
        fetchLoanCalloutClass.execute(null);
        Test.stopTest();
    }

    @isTest
    public static void testGetLoanIdErrorCallout(){
        //Test.setMock(HttpCalloutMock.class, new NLSFetchGetLoanID());
        genesis__Applications__c objApplication = TestClassHelper.createApplication();
        Test.startTest();
        FetchLoanIdQueueable fetchLoanCalloutClass = new FetchLoanIdQueueable(objApplication.genesis__Loan_Number__c , objApplication.Id);
        fetchLoanCalloutClass.execute(null);
        Test.stopTest();
    }

    @isTest
    public static void testGetLoanIdForNoAccrual(){
        Test.setMock(HttpCalloutMock.class, new NLSFetchGetLoanID());

        //Insert Application and Application Pricing Detail
        genesis__Applications__c objApplication = TestClassHelper.createApplication();
        objApplication.genesis__Loan_Number__c = '9' + objApplication.genesis__Loan_Number__c;
        genesis__Application_Pricing_Detail__c objChildLoan = new genesis__Application_Pricing_Detail__c();
        objChildLoan.genesis__Application__c = objApplication.Id;
        Database.insert(objChildLoan,true);
        Account objDealerAccount = new Account(Id = (Id)objApplication.Dealer_Name__c);
        genesis__Business_Information__c objDealerBusinessInfo = new genesis__Business_Information__c ( Approved_Loan_Amount__c = 0,
                                                                                                        Contract_Loan_Limit__c = 1000000,  
                                                                                                        Customised_Loan_Limit__c = 500000, 
                                                                                                        Customised_Individual_Limit__c = 250000, 
                                                                                                        Remaining_Customised_Limit__c = 500000);
        Database.insert(objDealerBusinessInfo,true);
        objDealerAccount.genesis__Business_Information__c = objDealerBusinessInfo.Id;
        Database.update(objDealerAccount,true);
        Database.update(objApplication,true);
        Test.startTest();
        FetchLoanIdQueueable fetchLoanCalloutClass = new FetchLoanIdQueueable(objApplication.genesis__Loan_Number__c , objApplication.Id,true);
        fetchLoanCalloutClass.execute(null);
        Test.stopTest();
    }
}