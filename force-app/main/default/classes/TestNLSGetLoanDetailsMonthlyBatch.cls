/**
 * @description       : Test class for NLSGetLoanDetailsMonthlyCalloutBatch
 * @author            : Simran
 * @group             : 
 * @last modified on  : 11-29-2024
 * @last modified by  : Ayan Bhowmik
**/
@isTest
global without sharing class TestNLSGetLoanDetailsMonthlyBatch {
    /**
    * @description Test Setup
    * @author Simran | 09-24-2024 
    **/
    @TestSetup
    static void makeData(){
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily('NLS Integration');
        intframework__Integration_API_Type__c apiType = 
                        IntegrationTestInitHelper.getIntegrationAPIType(
                                family.Id, 
                                'NLS Get Loan Details Monthly API Type'
                            );
        intframework__Integration_Provider__c provider = 
                        IntegrationTestInitHelper.getIntegrationProvider(
                                family.Id, 
                                'NLS Get Loan Details Monthly Provider'
                            );
        intframework__Integration_Configuration__c config = 
                        IntegrationTestInitHelper.getIntegrationConfiguration(
                                provider.Id,
                                'NLS Get Loan Details Monthly Configuration',
                                'NLS'
                            );
        intframework__Integration_API_Configuration__c apiConfig = 
                        IntegrationTestInitHelper.getIntegrationAPIConfiguration(
                                family.Id,
                                apiType.Id,
                                provider.Id,
                                config.Id,
                                false,
                                'NLSGetLoanDetailsMonthlyAdapter',
                                'GET',
                                'NLS',
                                'loans/loanId',
                                '{"thirdPartySystem":{"name":"Get Loan","filters":[{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"loans","fields":[{"externalField":"childId","fieldAPI":"Id"},{"externalField":"parentId","fieldAPI":"genesis__Application__c"},{"externalField":"loanId","fieldAPI":"Loan_Id__c"}],"whereClause":"Id IN :loanIdList"}]}}',
                                'application/json',
                                1
                            );
        System.assertEquals(apiConfig.intframework__Adapter_Class_Name__c, 'NLSGetLoanDetailsMonthlyAdapter','integration framework is not working');
        genesis__Applications__c objApplication = new genesis__Applications__c();
        objApplication.genesis__Product_Type__c ='Loan';
        objApplication.genesis__Term__c = 12;
        objApplication.Participant_Id__c='67858';
        objApplication.genesis__Interest_Rate__c = 1;
        objApplication.genesis__Loan_Amount__c = 35000;
        objApplication.Crop_Year__c = '2022';
        objApplication.Peak_Loan_Volume__c = 15000;
        objApplication.genesis__Maturity_Date__c = Date.today().addYears(1);
        objApplication.Loan_Id__c = '13900';
        objApplication.genesis__Loan_Number__c = '3HH98762543';
        objApplication.genesis__Status__c = 'ACTIVE';
        
        Database.insert(objApplication,true);

        genesis__Application_Pricing_Detail__c objApplicationPricingOne = TestClassHelper.createPricingDetail(objApplication.Id);// new genesis__Application_Pricing_Detail__c();
        objApplicationPricingOne.Loan_Id__c = '13901';
        objApplicationPricingOne.Participant_Id__c='67854';
        objApplicationPricingOne.genesis__Enabled_Flag__c = true;
        Database.update(objApplicationPricingOne,true);

        genesis__Application_Pricing_Detail__c objApplicationPricingTwo =  new genesis__Application_Pricing_Detail__c();
        objApplicationPricingTwo.Loan_Id__c = '13902';
        objApplicationPricingTwo.Participant_Id__c='67859';
        objApplicationPricingTwo.genesis__Application__c =objApplication.Id;
        objApplicationPricingTwo.genesis__Enabled_Flag__c = true;
        Database.insert(objApplicationPricingTwo,true);

        genesis__Application_Pricing_Detail__c applicationPricingThree =  new genesis__Application_Pricing_Detail__c();
        applicationPricingThree.Loan_Id__c = null;
        applicationPricingThree.Participant_Id__c='67859';
        applicationPricingThree.genesis__Application__c =objApplication.Id;
        applicationPricingThree.genesis__Enabled_Flag__c = true;
        Database.insert(applicationPricingThree,true);
    }
    /**
     * @description This class implements a interface method which return mock response of NLS for monthly loan details
     */
    public class HttpCalloutSuccessMock implements HttpCalloutMock {
        // Implement this interface method
        /**
         * @description This method return mock response of NLS to get monthly loan-details
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
                response.setBody('{"status":{"code":200,"message":"string"},"payload":{"data":{"Acctrefno":0,"Loan_Type":0,"Portfolio_Code_Id":0,"Loan_Group_No":0,"Master_Acctrefno":0,"Pool_Acctrefno":0,"Restructured_Acctrefno":0,"Shadow_Loan_Exists":true,"Cifno":0,"Loan_Class1_No":0,"Name":"string","Loan_Class2_No":0,"Shortname":"string","Risk_Rating_No":0,"Loan_Number":"string","Tin":"string","Entity":"string","Input_Date":"2022-10-28T16:32:13.725Z","Loan_Officer_No":0,"Open_Date":"2022-10-28T16:32:13.725Z","Collection_Officer_No":0,"Curr_Date":"2022-10-28T16:32:13.725Z","Open_Maturity_Date":"2022-10-28T16:32:13.725Z","Curr_Maturity_Date":"2022-10-28T16:32:13.725Z","Payoff_Date":"2022-10-28T16:32:13.725Z","Last_Activity_Date":"2022-10-28T16:32:13.725Z","Processing_Start_Date":"2022-10-28T16:32:13.725Z","Interest_Paid_Thru_Date":"2022-10-28T16:32:13.725Z","Principal_Paid_Thru_Date":"2022-10-28T16:32:13.725Z","Interest_Accrued_Thru_Date":"2022-10-28T16:32:13.725Z","Original_Note_Amount":0,"Current_Note_Amount":0,"Current_Principal_Balance":0,"Current_Interest_Balance":0,"Current_Fees_Balance":0,"Current_Def_Interest_Balance":0,"Current_Late_Charge_Balance":0,"Current_Payoff_Balance":0,"Current_Udf1_Balance":0,"Current_Perdiem":0,"Current_Suspense":0,"Current_Udf2_Balance":0,"Current_Interest_Rate":0,"Current_Udf3_Balance":0,"Total_Past_Due_Balance":0,"Current_Udf4_Balance":0,"Total_Current_Due_Balance":0,"Current_Udf5_Balance":0,"Current_Udf6_Balance":0,"Starting_Interest_Rate":0,"Times_Renewed":0,"Current_Def_Perdiem":0,"Current_Impound_Balance":0,"Current_Ol1_Balance":0,"Current_Udf7_Balance":0,"Current_Ol2_Balance":0,"Starting_Year_Interest_Rate":0,"Current_Ol3_Balance":0,"Current_Udf8_Balance":0,"Last_Rate_Change_Date":"2022-10-28T16:32:13.725Z","Current_Udf9_Balance":0,"Times_Extended":0,"Current_Udf10_Balance":0,"Next_Rate_Change_Date":"2022-10-28T16:32:13.725Z","Next_Interest_Step_Date":"2022-10-28T16:32:13.725Z","Default_Interest_Indicator":0,"Addonint_Total":0,"Addonint_Remaining":0,"Starting_Year_Def_Int_Rate":0,"Starting_Def_Interest_Rate":0,"Next_Rate_Change_Notice_Date":"2022-10-28T16:32:13.725Z","Compound_Interest_Balance":0,"Current_Def_Interest_Rate":0,"Next_Accrual_Cutoff":"2022-10-28T16:32:13.725Z","Last_Def_Rate_Change_Date":"2022-10-28T16:32:13.725Z","Next_Def_Rate_Change_Date":"2022-10-28T16:32:13.725Z","Next_Billing_Date":"2022-10-28T16:32:13.725Z","Next_Recurring_Trans_Date":"2022-10-28T16:32:13.725Z","Next_Def_Interest_Step_Date":"2022-10-28T16:32:13.725Z","Next_Statement1_Date":"2022-10-28T16:32:13.726Z","Next_Def_Rate_Change_Notice":"2022-10-28T16:32:13.726Z","Days_In_Current_Period":0,"Default_Def_Interest_Indicator":0,"Next_Statement2_Date":"2022-10-28T16:32:13.726Z","Next_Amort_Fees_Date":"2022-10-28T16:32:13.726Z","Amortized_Fees_Eim_Flag":true,"Days_Past_Due":0,"Compound_Def_Interest_Balance":0,"Compound_Interest_Indicator":0,"Compound_Def_Int_Indicator":0,"Current_Servicing_Balance":0,"Current_Reserve_Balance":0,"Dealer_Cifno":0,"SAC_Expiration_Date":"2022-10-28T16:32:13.726Z","SAC_Ineligible_Date":"2022-10-28T16:32:13.726Z","Closed_Date":"2022-10-28T16:32:13.726Z","Input_Gl_Date":"2022-10-28T16:32:13.726Z","CurrencyID":0,"Intro_Interest_Expiration":"2022-10-28T16:32:13.726Z","Intro_Def_Interest_Expiration":"2022-10-28T16:32:13.726Z","Tin_Hash":"string","Current_Adb_Interest_Balance":0,"Branch_Cifno":0,"Statement1_Billing_End_Date":"2022-10-28T16:32:13.726Z","Statement2_Billing_End_Date":"2022-10-28T16:32:13.726Z","Current_TierRateNo":0,"Current_Def_TierRateNo":0,"Non_Accrual_Start_Date":"2022-10-28T16:32:13.726Z","Charge_Off_Start_Date":"2022-10-28T16:32:13.726Z","Status_Code_No":0,"Last_Billing_Date":"2022-10-28T16:32:13.726Z","LCGUID":"string","LCGUIDDate":"2022-10-28T16:32:13.726Z","Funded_Date":"2022-10-28T16:32:13.726Z","Borrower_Loan_Nickname":"string","ContractualJurisdiction":"string"}}}');
            }
            return response;
        }
    }

    /**
     * @description This class implements a interface method which return mock response of NLS for monthly loan details where status code should not be 200
     */
    public class HttpCalloutFailureStatusCodeMock implements HttpCalloutMock {

        /**
        * @description This method return mock response of NLS to get monthly loan-details where status code should not be 200
        * @author Rakesh Saraf | 09-11-2024 
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatus('SUCCESS');
            response.setHeader('Content-Type', 'application/json');
            if(request.getEndpoint().contains('token')){
                response.setStatusCode(200);
                String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
            }
            else{
                response.setBody('{"status":{"code":400,"message":"string"}');
            }
            return response;
        }
    }


    /**
     * @description This class implements a interface method which return mock response of NLS for monthly loan details without a payload to throw exception
     */
    public class HttpCalloutWithoutPayloadMock implements HttpCalloutMock {

        /**
        * @description This method return mock response of NLS to get monthly loan-details with no payload
        * @author Rakesh Saraf | 09-11-2024 
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
                response.setBody('{"status":{"code":200,"message":"string"}');
            }
            return response;
        }
    }

    /**
     * @description This class implements a interface method which return mock response of NLS for monthly loan details with past dues being negative
     */
    public class HttpCalloutHasPastDueNegativeMock implements HttpCalloutMock {

        /**
        * @description This method return mock response of NLS to get monthly loan-details with past dues being negative
        * @author Rakesh Saraf | 09-11-2024 
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
                response.setBody('{"status":{"code":200,"message":"string"},"payload":{"data":{"Acctrefno":0,"Loan_Type":0,"Portfolio_Code_Id":0,"Loan_Group_No":0,"Master_Acctrefno":0,"Pool_Acctrefno":0,"Restructured_Acctrefno":0,"Shadow_Loan_Exists":true,"Cifno":0,"Loan_Class1_No":0,"Name":"string","Loan_Class2_No":0,"Shortname":"string","Risk_Rating_No":0,"Loan_Number":"string","Tin":"string","Entity":"string","Input_Date":"2022-10-28T16:32:13.725Z","Loan_Officer_No":0,"Open_Date":"2022-10-28T16:32:13.725Z","Collection_Officer_No":0,"Curr_Date":"2022-10-28T16:32:13.725Z","Open_Maturity_Date":"2022-10-28T16:32:13.725Z","Curr_Maturity_Date":"2022-10-28T16:32:13.725Z","Payoff_Date":"2022-10-28T16:32:13.725Z","Last_Activity_Date":"2022-10-28T16:32:13.725Z","Processing_Start_Date":"2022-10-28T16:32:13.725Z","Interest_Paid_Thru_Date":"2022-10-28T16:32:13.725Z","Principal_Paid_Thru_Date":"2022-10-28T16:32:13.725Z","Interest_Accrued_Thru_Date":"2022-10-28T16:32:13.725Z","Original_Note_Amount":0,"Current_Note_Amount":0,"Current_Principal_Balance":0,"Current_Interest_Balance":0,"Current_Fees_Balance":0,"Current_Def_Interest_Balance":0,"Current_Late_Charge_Balance":0,"Current_Payoff_Balance":0,"Current_Udf1_Balance":0,"Current_Perdiem":0,"Current_Suspense":0,"Current_Udf2_Balance":0,"Current_Interest_Rate":0,"Current_Udf3_Balance":0,"Total_Past_Due_Balance":-100,"Current_Udf4_Balance":0,"Total_Current_Due_Balance":0,"Current_Udf5_Balance":0,"Current_Udf6_Balance":0,"Starting_Interest_Rate":0,"Times_Renewed":0,"Current_Def_Perdiem":0,"Current_Impound_Balance":0,"Current_Ol1_Balance":0,"Current_Udf7_Balance":0,"Current_Ol2_Balance":0,"Starting_Year_Interest_Rate":0,"Current_Ol3_Balance":0,"Current_Udf8_Balance":0,"Last_Rate_Change_Date":"2022-10-28T16:32:13.725Z","Current_Udf9_Balance":0,"Times_Extended":0,"Current_Udf10_Balance":0,"Next_Rate_Change_Date":"2022-10-28T16:32:13.725Z","Next_Interest_Step_Date":"2022-10-28T16:32:13.725Z","Default_Interest_Indicator":0,"Addonint_Total":0,"Addonint_Remaining":0,"Starting_Year_Def_Int_Rate":0,"Starting_Def_Interest_Rate":0,"Next_Rate_Change_Notice_Date":"2022-10-28T16:32:13.725Z","Compound_Interest_Balance":0,"Current_Def_Interest_Rate":0,"Next_Accrual_Cutoff":"2022-10-28T16:32:13.725Z","Last_Def_Rate_Change_Date":"2022-10-28T16:32:13.725Z","Next_Def_Rate_Change_Date":"2022-10-28T16:32:13.725Z","Next_Billing_Date":"2022-10-28T16:32:13.725Z","Next_Recurring_Trans_Date":"2022-10-28T16:32:13.725Z","Next_Def_Interest_Step_Date":"2022-10-28T16:32:13.725Z","Next_Statement1_Date":"2022-10-28T16:32:13.726Z","Next_Def_Rate_Change_Notice":"2022-10-28T16:32:13.726Z","Days_In_Current_Period":0,"Default_Def_Interest_Indicator":0,"Next_Statement2_Date":"2022-10-28T16:32:13.726Z","Next_Amort_Fees_Date":"2022-10-28T16:32:13.726Z","Amortized_Fees_Eim_Flag":true,"Days_Past_Due":0,"Compound_Def_Interest_Balance":0,"Compound_Interest_Indicator":0,"Compound_Def_Int_Indicator":0,"Current_Servicing_Balance":0,"Current_Reserve_Balance":0,"Dealer_Cifno":0,"SAC_Expiration_Date":"2022-10-28T16:32:13.726Z","SAC_Ineligible_Date":"2022-10-28T16:32:13.726Z","Closed_Date":"2022-10-28T16:32:13.726Z","Input_Gl_Date":"2022-10-28T16:32:13.726Z","CurrencyID":0,"Intro_Interest_Expiration":"2022-10-28T16:32:13.726Z","Intro_Def_Interest_Expiration":"2022-10-28T16:32:13.726Z","Tin_Hash":"string","Current_Adb_Interest_Balance":0,"Branch_Cifno":0,"Statement1_Billing_End_Date":"2022-10-28T16:32:13.726Z","Statement2_Billing_End_Date":"2022-10-28T16:32:13.726Z","Current_TierRateNo":0,"Current_Def_TierRateNo":0,"Non_Accrual_Start_Date":"2022-10-28T16:32:13.726Z","Charge_Off_Start_Date":"2022-10-28T16:32:13.726Z","Status_Code_No":0,"Last_Billing_Date":"2022-10-28T16:32:13.726Z","LCGUID":"string","LCGUIDDate":"2022-10-28T16:32:13.726Z","Funded_Date":"2022-10-28T16:32:13.726Z","Borrower_Loan_Nickname":"string","ContractualJurisdiction":"string"}}}');
            }
            return response;
        }
    }


    /**
    * @description Test default success
    * @author Simran | 09-24-2024 
    **/
    @isTest
    public static void testNLSGetParticipantInterest() {
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        Test.startTest();
        System.runAs(objAdmin){
            NLSGetLoanDetailsMonthlyCalloutBatch obj = new NLSGetLoanDetailsMonthlyCalloutBatch();
            Id batchProcessId=Database.executeBatch(obj, 50);
            System.assert(batchProcessId!=null,'Batch Process did not run');
        }
        Test.stopTest();
    }

    /**
    * @description Test default success for schedule class
    * @author Simran | 09-24-2024 
    **/
    @IsTest
    public static void testNLSGetLoanDetailsMonthlySchedule() {
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Test.startTest();
        System.runAs(objAdmin){
            String jobId = System.schedule('Schedule NLS Loan Details Batch' , '0 1 * * * ? *',  new NLSGetLoanDetailsMonthlySchedule());
            NLSGetLoanDetailsMonthlySchedule classSchedule = new NLSGetLoanDetailsMonthlySchedule();
            classSchedule.execute(null);
            System.assert(jobId!=null,'Schdule class not working');
        }
        Test.stopTest();
    }

    /**
    * @description Test default failure
    * @author Simran | 09-24-2024 
    **/
    @isTest
    static void testFailureStatusCode(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new HttpCalloutFailureStatusCodeMock());
        Test.startTest();
        System.runAs(objAdmin){
            NLSGetLoanDetailsMonthlyCalloutBatch obj = new NLSGetLoanDetailsMonthlyCalloutBatch();
            Id batchProcessId=Database.executeBatch(obj, 50);
            System.assert(batchProcessId!=null,'Batch Process did not run');
        }
        Test.stopTest();
    }

    /**
    * @description test with no payload to generate an exception
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testNoPayload(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new HttpCalloutWithoutPayloadMock());
        Test.startTest();
        System.runAs(objAdmin){
            NLSGetLoanDetailsMonthlyCalloutBatch obj = new NLSGetLoanDetailsMonthlyCalloutBatch();
            Id batchProcessId=Database.executeBatch(obj, 50);
            System.assert(batchProcessId!=null,'Batch Process did not run');
        }
    }

    /**
    * @description test with past dues being negative
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testNegativeHasPastDue(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new HttpCalloutHasPastDueNegativeMock());
        Test.startTest();
        System.runAs(objAdmin){
            NLSGetLoanDetailsMonthlyCalloutBatch obj = new NLSGetLoanDetailsMonthlyCalloutBatch();
            Id batchProcessId=Database.executeBatch(obj, 50);
            System.assert(batchProcessId!=null,'Batch Process did not run');
        }
        Test.stopTest();
    }

    /**
    * @description Test default success for custom data
    * @author Simran | 09-24-2024 
    **/
    @isTest
    public static void testCustomDataSuccess() {
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<Id> idList = new List<Id>(
                            (new Map<Id, genesis__Application_Pricing_Detail__c>(
                                    [
                                        SELECT Id 
                                        FROM genesis__Application_Pricing_Detail__c
                                        WHERE genesis__Enabled_Flag__c = true
                                        AND Loan_Id__c != null
                                        AND genesis__Application__r.Loan_Id__c != null
                                        AND (genesis__Application__r.genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                                        OR genesis__Application__r.Pay_Off_Date__c = THIS_MONTH
                                        OR (Dealer_Interest_Accrued__c != 0 AND genesis__Application__r.Pay_Off_Date__c != null))
                                    ]
                                )).keySet()
                            );
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        Test.startTest();
        System.runAs(objAdmin){
            NLSGetLoanDetailsMonthlyCalloutBatch obj = new NLSGetLoanDetailsMonthlyCalloutBatch(idList, genesis__Application_Pricing_Detail__c.class);
            Id batchProcessId=Database.executeBatch(obj, 50);
            System.assert(batchProcessId!=null,'Batch Process did not run');
        }
        Test.stopTest();
    }

    /**
    * @description test with the current loan id as null
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    public static void testCurrLonIdNull() {
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<Id> idList = new List<Id>(
                            (new Map<Id, genesis__Applications__c>(
                                    [
                                        SELECT Id 
                                        FROM genesis__Applications__c
                                        WHERE genesis__Loan_Number__c = '3HH98762543'
                                    ]
                                )).keySet()
                            );
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        Test.startTest();
        System.runAs(objAdmin){
            NLSGetLoanDetailsMonthlyCalloutBatch obj = new NLSGetLoanDetailsMonthlyCalloutBatch(idList, genesis__Applications__c.class);
            Id batchProcessId=Database.executeBatch(obj, 50);
            System.Assert(batchProcessId!=null,'Batch Process did not run');
        }
        Test.stopTest();
    }

    /**
    * @description Test error due to missing config
    * @author Simran | 09-24-2024 
    **/
    @isTest
    public static void testMissingConfigError() {
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Database.delete([SELECT Id FROM intframework__Integration_Configuration__c WHERE Name = 'NLS Get Loan Details Monthly Configuration'], true);
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        Test.startTest();
        System.runAs(objAdmin){
            NLSGetLoanDetailsMonthlyCalloutBatch obj = new NLSGetLoanDetailsMonthlyCalloutBatch();
            Id batchProcessId=Database.executeBatch(obj, 50);
            System.assert(batchProcessId!=null,'Batch process did not run');
        }
        Test.stopTest();

    }
}