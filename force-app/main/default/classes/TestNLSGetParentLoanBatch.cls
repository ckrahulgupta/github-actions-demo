/**
 * @description       : 
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 11-29-2024
 * @last modified by  : Ayan Bhowmik
**/

@isTest 
public with sharing class TestNLSGetParentLoanBatch {
    @testSetup
    static void setup() {
        //Inserting Integration Family
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily(
            'NLS Integration');
        //Inserting Integration API Type
        intframework__Integration_API_Type__c getLoanApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Get loan Integration API Type');
        intframework__Integration_API_Type__c getLoanDetailsApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Get Loan Details Integration API Type');
        intframework__Integration_API_Type__c getCreditLinesApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Get Credit Lines Integration API Type');
        intframework__Integration_API_Type__c getPayoffDetailsApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Get Payoff Details Integration API Type');
        //Inserting Integration Provider
        intframework__Integration_Provider__c getLoanProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Get Loan');
        intframework__Integration_Provider__c getLoanDetailsProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Loan Details');
        intframework__Integration_Provider__c getCreditLinesProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Credit Lines');
        intframework__Integration_Provider__c getPayoffDetailsProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Payoff Details');
        //Inserting Integration Configuration
        intframework__Integration_Configuration__c getLoanConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            getLoanProvider.Id,'NLS Get Loan Integration Configuration','NLS');
        intframework__Integration_Configuration__c getLoanDetailsConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            getLoanDetailsProvider.Id,'NLS Loan Details Integration Configuration','NLS');
        intframework__Integration_Configuration__c getCreditLinesConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            getCreditLinesProvider.Id,'NLS Credit Lines Integration Configuration','NLS');
        intframework__Integration_Configuration__c getPayoffDetailsConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            getPayoffDetailsProvider.Id,'NLS Payoff Details Integration Configuration','NLS');
        //Inserting Integration API Configuration
        intframework__Integration_API_Configuration__c getLoanApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            getLoanApiType.Id,
            getLoanProvider.Id,
            getLoanConfig.Id,
            false,
            'NLSGetLoanAdapter',
            'GET',
            'NLS',
            'loans/loanId',
            '{"thirdPartySystem": {"name": "Get Loan","filters": [{"objectAPI": "genesis__Applications__c","objectAlias": "Application","fields": [{"externalField": "ID","fieldAPI": "Id"},{"externalField": "loanId","fieldAPI": "Loan_Id__c"}],"whereClause": "Id IN :applicationIdList"}]}}',
            'application/json',
            1
        );
        intframework__Integration_API_Configuration__c getLoanDetailsApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            getLoanDetailsApiType.Id,
            getLoanDetailsProvider.Id,
            getLoanDetailsConfig.Id,
            false,
            'NLSLoanDetailsAdapter',
            'GET',
            'NLS',
            'loans/loanId/detail1',
            '{ "thirdPartySystem": {  "name": "Loan Details",  "filters": [   {    "objectAPI": "genesis__Applications__c",    "objectAlias": "Application",    "fields": [     {      "externalField": "ID",      "fieldAPI": "Id"     },     {      "externalField": "loanId",      "fieldAPI": "Loan_Id__c"     }    ],    "whereClause": "Id IN :applicationIdList"   }  ] }}',
            'application/json',
            1
        );
        intframework__Integration_API_Configuration__c getCreditLinesApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            getCreditLinesApiType.Id,
            getCreditLinesProvider.Id,
            getCreditLinesConfig.Id,
            false,
            'NLSCreditLinesAdapter',
            'GET',
            'NLS',
            'loans/loanId/credit-lines',
            '{"thirdPartySystem": {"name": "Get Credit Lines","filters": [{"objectAPI": "genesis__Applications__c","objectAlias": "Application","fields": [{"externalField": "ID","fieldAPI": "Id"},{"externalField": "loanId","fieldAPI": "Loan_Id__c"}],"whereClause": "Id IN :applicationIdList"}]}}',
            'application/json',
            1
        );
        intframework__Integration_API_Configuration__c getPayoffDetailsApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            getPayoffDetailsApiType.Id,
            getPayoffDetailsProvider.Id,
            getPayoffDetailsConfig.Id,
            false,
            'NLSPayoffDetailsAdapter',
            'GET',
            'NLS',
            'loans/{!loan_id}/payoff-details?payoffDate={!payoffDate}',
            '{"thirdPartySystem": {"name": "Get Payoff Details","filters": [{"objectAPI": "genesis__Applications__c","objectAlias": "Application","fields": [{"externalField": "ID","fieldAPI": "Id"},{"externalField": "loanId","fieldAPI": "Loan_Id__c"}],"whereClause": "Id IN :applicationIdList"}]}}',
            'application/json',
            1
        );
        genesis__Credit_Rating_Matrix__c objCreditRating = new genesis__Credit_Rating_Matrix__c(Name = 'Tier 4');
        Database.insert(objCreditRating);
    }
    /**
     * @description This class implements a interface method which return the mock response of NLS
     */
    public class NLSGetLoanHttpCalloutMock implements HttpCalloutMock {
        // Implement this interface method
        /**
         * @description This method return a mock response of NLS
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
            else if(request.getEndpoint().contains('detail1')){
                response.setBody('{"status":{"code":200,"message":"Success"},'+
                                '"payload":{"data":{"Acctrefno":176493,'+
                                '"Userdef01":"2022","Userdef02":"0%","Userdef03":"TIER 4","Userdef04":null,"Userdef05":"114618",'+
                                '"Userdef06":"KHARDAH","Userdef07":"QR","Userdef08":"0000000000000.00000","Userdef09":"APP-0000002775",'+
                                '"Userdef10":null,"Userdef11":null,"Userdef12":null,"Userdef13":null,"Userdef14":null,"Userdef15":null,'+
                                '"Userdef16":null,"Userdef17":null,"Userdef18":null,"Userdef19":null,"Userdef20":null,"Userdef21":null,'+
                                '"Userdef22":null,"Userdef23":null,"Userdef24":null,"Userdef25":null,"Userdef26":null,"Userdef27":null,'+
                                '"Userdef28":null,"Userdef29":null,"Userdef30":null,"Userdef31":null,"Userdef32":null,"Userdef33":null,'+
                                '"Userdef34":null,"Userdef35":"0000000012000.00000","Userdef36":"NO","Userdef37":"0000000000000.00000",'+
                                '"Userdef38":"E-DOC","Userdef39":null,"Userdef40":null,"Userdef41":null,"Userdef42":null,"Userdef43":null,'+
                                '"Userdef44":null,"Userdef45":null,"Userdef46":null,"Userdef47":null,"Userdef48":null,"Userdef49":null,'+
                                '"Userdef50":null,"Userdef51":null,"Userdef52":null,"Userdef53":null,"Userdef54":null,"Userdef55":null,'+
                                '"Userdef56":null,"Userdef57":null,"Userdef58":null,"Userdef59":null,"Userdef60":null,"Userdef61":null,'+
                                '"Userdef62":null,"Userdef63":null,"Userdef64":null,"Userdef65":null,"Userdef66":null,"Userdef67":null,'+
                                '"Userdef68":null,"Userdef69":null,"Userdef70":null,"Userdef71":null,"Userdef72":null,"Userdef73":null,'+
                                '"Userdef74":null,"Userdef75":null,"Userdef76":null,"Userdef77":null,"Userdef78":null,"Userdef79":null,"Userdef80":null}}}');
            }
            else if(request.getEndpoint().contains('credit-lines')){
                response.setBody('{"status":{"code":200,"message":"Success"},' +
                                '"payload":{"totalCount":1,"count":1,"data":[{"Creditline_Id":83541,' +
                                '"Credit_Line_Limit":12000.00,"Min_Draw_Amount":0.00,'+
                                '"Name":"Main Credit Line","Credit_Total_Draw_Limit":12000.00,"Description":"",'+
                                '"Max_Draw_Amount":0.00,"Max_Number_Of_Draws":0,"Draw_Until_Type":0,"Draw_Until_Period":"NA",'+
                                '"Draw_Until_Days":0,"Draw_Until_Dayvalue":1,"Overdraw_Threshold_Attribute":0,"Overdraw_Threshold_Amount":0.00,'+
                                '"Draw_Until_Date":null,"Overdraw_Threshold_Percentage":0.00000,"Fee_Per_Draw_Attribute":0,'+
                                '"Fee_Per_Draw_Amount":0.00,"Fee_Per_Draw_Percentage":0.00000,"Fee_Per_Draw_Transaction_Code":152,'+
                                '"Overdraw_Fee_Attribute":0,"Overdraw_Fee_Amount":0.00,"Overdraw_Fee_Percentage":0.00000,"Overdraw_Fee_Transaction_Code":154,'+
                                '"Option_Flags":0,"Acctrefno":176493}]}}');
            }
            else if(request.getEndpoint().contains('payoff-details')){
                response.setBody('{"status":{"code":200,"message":"Success"},'+
                                '"payload":{"data":{"LoanNumber":"343066028","ShortName":"BOOKINGTOCORELLC",'+
                                '"LoanGroup":"INPUT","InterestPaidThrough":"05/15/2022",'+
                                '"PrincipalPaidThrough":"05/15/2022","LoanDate":"05/16/2022",'+
                                '"FeesDue":0.0,"LateCharges":0.0,"MaturityDate":"05/15/2023",'+
                                '"PayoffDate":"06/10/2022","InterestRate":0.0,"PerDiem":0.0,"PrincipalBalance":0.0,'+
                                '"AccruedInterest":0.0,"PayoffAmount":0.0,"Suspense":0.0,"ServicingFee":0.0,'+
                                '"UserDefinedLoanBalances":{"UserDefinedLoanBalance1":0.0,"UserDefinedLoanBalance2":0.0,'+
                                '"UserDefinedLoanBalance3":0.0,"UserDefinedLoanBalance4":0.0,"UserDefinedLoanBalance5":0.0,'+
                                '"UserDefinedLoanBalance6":0.0,"UserDefinedLoanBalance7":0.0,"UserDefinedLoanBalance8":0.0,'+
                                '"UserDefinedLoanBalance9":0.0,"UserDefinedLoanBalance10":0.0}}}}');
            }
            else{
                response.setBody('{"status":{"code":200,"message":"Success"},'+
                                '"payload":{"data":{"Acctrefno":176493,"Loan_Type":3,"Portfolio_Code_Id":0,'+
                                '"Loan_Group_No":4,"Master_Acctrefno":0,"Pool_Acctrefno":0,"Restructured_Acctrefno":0,'+
                                '"Shadow_Loan_Exists":false,"Cifno":39368,"Loan_Class1_No":68,"Name":"BOOKINGTOCORELLC",'+
                                '"Loan_Class2_No":0,"Shortname":"BOOKINGTOCORELLC","Risk_Rating_No":3,"Loan_Number":"343066028",'+
                                '"Tin":"21-3129381","Entity":"LIMITED LIABILITY COMPANY","Input_Date":"2022-05-16T00:00:00","Loan_Officer_No":0,'+
                                '"Open_Date":"2022-05-16T00:00:00","Collection_Officer_No":0,"Curr_Date":"2022-05-16T00:00:00","Open_Maturity_Date":"2023-05-15T00:00:00",'+
                                '"Curr_Maturity_Date":"2023-05-15T00:00:00","Payoff_Date":null,"Last_Activity_Date":null,"Processing_Start_Date":"2022-05-16T00:00:00",'+
                                '"Interest_Paid_Thru_Date":"2022-05-15T00:00:00","Principal_Paid_Thru_Date":"2022-05-15T00:00:00","Interest_Accrued_Thru_Date":"2022-05-15T00:00:00",'+
                                '"Original_Note_Amount":0.00,"Current_Note_Amount":0.00,"Current_Principal_Balance":0.00,"Current_Interest_Balance":0.0000000000,'+
                                '"Current_Fees_Balance":0.00000,"Current_Def_Interest_Balance":0.0000000000,"Current_Late_Charge_Balance":0.00,'+
                                '"Current_Payoff_Balance":0.0000000000,"Current_Udf1_Balance":0.00000,"Current_Perdiem":0.0000000000,'+
                                '"Current_Suspense":0.00,"Current_Udf2_Balance":0.00000,"Current_Interest_Rate":0.00000000,"Current_Udf3_Balance":0.00000,'+
                                '"Total_Past_Due_Balance":0.00,"Current_Udf4_Balance":0.00000,"Total_Current_Due_Balance":0.00,"Current_Udf5_Balance":0.00000,'+
                                '"Current_Udf6_Balance":0.00000,"Starting_Interest_Rate":0.00000000,"Times_Renewed":0,"Current_Def_Perdiem":0.0000000000,'+
                                '"Current_Impound_Balance":0.00,"Current_Ol1_Balance":0.00000,"Current_Udf7_Balance":0.00000,"Current_Ol2_Balance":0.00000,'+
                                '"Starting_Year_Interest_Rate":0.00000000,"Current_Ol3_Balance":0.00000,"Current_Udf8_Balance":0.00000,"Last_Rate_Change_Date":null,'+
                                '"Current_Udf9_Balance":0.00000,"Times_Extended":0,"Current_Udf10_Balance":0.00000,"Next_Rate_Change_Date":null,'+
                                '"Next_Interest_Step_Date":null,"Default_Interest_Indicator":0,"Addonint_Total":0.0000000000,"Addonint_Remaining":0.0000000000,'+
                                '"Starting_Year_Def_Int_Rate":0.00000000,"Starting_Def_Interest_Rate":0.00000000,"Next_Rate_Change_Notice_Date":null,'+
                                '"Compound_Interest_Balance":0.0000000000,"Current_Def_Interest_Rate":0.00000000,"Next_Accrual_Cutoff":"2022-06-15T00:00:00",'+
                                '"Last_Def_Rate_Change_Date":null,"Next_Def_Rate_Change_Date":null,"Next_Billing_Date":"2022-06-01T00:00:00",'+
                                '"Next_Recurring_Trans_Date":null,"Next_Def_Interest_Step_Date":null,"Next_Statement1_Date":"2022-05-31T00:00:00",'+
                                '"Next_Def_Rate_Change_Notice":null,"Days_In_Current_Period":31,"Default_Def_Interest_Indicator":0,"Next_Statement2_Date":null,'+
                                '"Next_Amort_Fees_Date":null,"Amortized_Fees_Eim_Flag":false,"Days_Past_Due":0,"Compound_Def_Interest_Balance":0.0000000000,'+
                                '"Compound_Interest_Indicator":0,"Compound_Def_Int_Indicator":0,"Current_Servicing_Balance":0.00,"Current_Reserve_Balance":0.00,'+
                                '"Dealer_Cifno":null,"SAC_Expiration_Date":null,"SAC_Ineligible_Date":null,"Closed_Date":null,"Input_Gl_Date":"2022-05-16T00:00:00",'+
                                '"CurrencyID":0,"Intro_Interest_Expiration":null,"Intro_Def_Interest_Expiration":null,"Tin_Hash":"q6z8gyeRoMvE1V24218xCwvPkodCnO7cUr0QRo7ZZh8=",'+
                                '"Current_Adb_Interest_Balance":0.0000000000,"Branch_Cifno":null,"Statement1_Billing_End_Date":"2022-05-15T00:00:00",'+
                                '"Statement2_Billing_End_Date":null,"Current_TierRateNo":0,"Current_Def_TierRateNo":0,"Non_Accrual_Start_Date":null,'+
                                '"Charge_Off_Start_Date":null,"Status_Code_No":0,"Last_Billing_Date":"2022-05-15T00:00:00","LCGUID":null,"LCGUIDDate":null,'+
                                '"Funded_Date":null,"Borrower_Loan_Nickname":null,"ContractualJurisdiction":""}}}');
            }
            return response;
        }
    }
    /**
     * @description This class implements a interface method which return a mock response when there access token is null
     */
    public class NLSGetNullAccessTokenMock implements HttpCalloutMock {
        // Implement this interface method
        /**
         * @description This method return a mock response when access token is null
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setStatus('FAILED');
            response.setHeader('Content-Type', 'application/json');
            return response;
        }
    }
    //Error on callout classes--> covers 100
    @isTest
    public static void testNLSLoanDetailsCalloutBatch(){
        Test.setMock(HttpCalloutMock.class, new NLSGetLoanHttpCalloutMock());
        Test.startTest();
        List<intframework__Integration_API_Configuration__c> intFrameList = new List<intframework__Integration_API_Configuration__c>();
        intframework__Integration_API_Configuration__c loanDetailsIntFrameWork = [SELECT Id FROM intframework__Integration_API_Configuration__c WHERE intframework__Adapter_Class_Name__c = 'NLSLoanDetailsAdapter'];
        intFrameList.add(loanDetailsIntFrameWork);
        intframework__Integration_API_Configuration__c creditLinesIntFrameWork = [SELECT Id FROM intframework__Integration_API_Configuration__c WHERE intframework__Adapter_Class_Name__c = 'NLSCreditLinesAdapter'];
        intFrameList.add(creditLinesIntFrameWork);
        intframework__Integration_API_Configuration__c payOffIntFrameWork = [SELECT Id FROM intframework__Integration_API_Configuration__c WHERE intframework__Adapter_Class_Name__c = 'NLSPayoffDetailsAdapter'];
        intFrameList.add(payOffIntFrameWork);
        intframework__Integration_API_Configuration__c getLoanIntFrameWork = [SELECT Id FROM intframework__Integration_API_Configuration__c WHERE intframework__Adapter_Class_Name__c = 'NLSGetLoanAdapter'];
        intFrameList.add(getLoanIntFrameWork);
        Database.delete(intFrameList,true);
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
        Database.update(objApplicationToFetchLoanDetails);
        NLSGetParentLoanDetailsSchedule schedulePricing = new NLSGetParentLoanDetailsSchedule();
        String cronExpression = '0 0 23 * * ?';
        System.schedule('Test Get Parent Loan', cronExpression, schedulePricing);
        Test.stopTest();
    }

    //Su
    @isTest
    public static void testNLSLoanDetailsCalloutBatch2(){
        Test.setMock(HttpCalloutMock.class, new NLSGetLoanHttpCalloutMock());
        //Test.startTest();
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
        Database.update(objApplicationToFetchLoanDetails);
        NLSLoanDetailsCalloutBatch getParentLoanDetails = new NLSLoanDetailsCalloutBatch ();
        Database.executeBatch(getParentLoanDetails , 200);
        //Test.stopTest();
    }

    //Sync Closed Loans Batch
    @isTest
    public static void testSyncClosedLoans(){
        Test.setMock(HttpCalloutMock.class, new NLSGetLoanHttpCalloutMock());
        //Test.startTest();
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
        objApplicationToFetchLoanDetails.genesis__Status__c = 'CLOSED';
        objApplicationToFetchLoanDetails.Loan_Id__c = '232312';
        Database.update(objApplicationToFetchLoanDetails);
        
        SyncAllClosedLoans.callBatchForClosedLoans();
        
        //Test.stopTest();
    }

    //Error on callout classes--> covers 100
    @isTest
    public static void testSyncClosedLoansError(){
        Test.setMock(HttpCalloutMock.class, new NLSGetLoanHttpCalloutMock());
        Test.startTest();
        List<intframework__Integration_API_Configuration__c> intFrameList = new List<intframework__Integration_API_Configuration__c>();
        intframework__Integration_API_Configuration__c loanDetailsIntFrameWork = [SELECT Id FROM intframework__Integration_API_Configuration__c WHERE intframework__Adapter_Class_Name__c = 'NLSLoanDetailsAdapter'];
        intFrameList.add(loanDetailsIntFrameWork);
        intframework__Integration_API_Configuration__c creditLinesIntFrameWork = [SELECT Id FROM intframework__Integration_API_Configuration__c WHERE intframework__Adapter_Class_Name__c = 'NLSCreditLinesAdapter'];
        intFrameList.add(creditLinesIntFrameWork);
        intframework__Integration_API_Configuration__c payOffIntFrameWork = [SELECT Id FROM intframework__Integration_API_Configuration__c WHERE intframework__Adapter_Class_Name__c = 'NLSPayoffDetailsAdapter'];
        intFrameList.add(payOffIntFrameWork);
        intframework__Integration_API_Configuration__c getLoanIntFrameWork = [SELECT Id FROM intframework__Integration_API_Configuration__c WHERE intframework__Adapter_Class_Name__c = 'NLSGetLoanAdapter'];
        intFrameList.add(getLoanIntFrameWork);
        Database.delete(intFrameList,true);
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
        objApplicationToFetchLoanDetails.genesis__Status__c = 'CLOSED';
        Database.update(objApplicationToFetchLoanDetails);
        SyncAllClosedLoans.callBatchForClosedLoans();
        Test.stopTest();
    }


    // @isTest 
    // public static void testNlsGetLoanCalloutMethod1() {
    //     Map<String, Object> requestMap = new Map<String, Object>();
    //     Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
    //     User objUser = IntegrationTestInitHelper.createUser(profile.Id);
    //     requestMap.put(ConstantValues.LOAN_ID, 123456 );
    //     // Set mock callout class 
    //     Test.setMock(HttpCalloutMock.class, new NLSGetLoanHttpCalloutMock());
    //     Test.startTest();
    //     System.runAs(objUser) {
    //         PortalNLSLoanDetailsAPI testApi = new PortalNLSLoanDetailsAPI();
    //         clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
    //         System.assertEquals(clcommon.Constants.SUCCESS, response.status);
    //     }
    //     Test.stopTest();
    // }
    // @isTest 
    // public static void testNlsGetLoanCalloutMethod3() {
    //     Map<String, Object> requestMap = new Map<String, Object>();
    //     Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
    //     User objUser = IntegrationTestInitHelper.createUser(profile.Id);
    //     requestMap.put(ConstantValues.LOAN_ID, 123456);
    //     // Set mock callout class 
    //     Test.setMock(HttpCalloutMock.class, new NLSGetNullAccessTokenMock());
    //     Test.startTest();
    //     System.runAs(objUser) {
    //         PortalNLSLoanDetailsAPI testApi = new PortalNLSLoanDetailsAPI();
    //         clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
    //         System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status);
    //     }
    //     Test.stopTest();
    // }
}