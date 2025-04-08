/**
 * @description       : Test class for NLSGetParticipantStatisticsCalloutBatch
 * @author            : Simran
 * @group             : 
 * @last modified on  : 11-29-2024
 * @last modified by  : Ayan Bhowmik
**/
@isTest
global without sharing class TestNLSGetParticipantStatisticsBatch {
    /**
    * @description this method makes the test data
    * @author Soumik Pattanayak | 12-09-2024 
    **/
    @TestSetup
    static void makeData(){
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily('NLS Integration');
        intframework__Integration_API_Type__c apiType = 
                        IntegrationTestInitHelper.getIntegrationAPIType(
                                family.Id, 
                                'Participant Loan Statistics API Type'
                            );
        intframework__Integration_Provider__c provider = 
                        IntegrationTestInitHelper.getIntegrationProvider(
                                family.Id, 
                                'Participant Loan Statistics'
                            );
        intframework__Integration_Configuration__c config = 
                        IntegrationTestInitHelper.getIntegrationConfiguration(
                                provider.Id,
                                'Participant Loan Statistics Configuration',
                                'NLS'
                            );
        IntegrationTestInitHelper.getIntegrationAPIConfiguration(
                                family.Id,
                                apiType.Id,
                                provider.Id,
                                config.Id,
                                false,
                                'NLSGetParticipantStatisticsAdapter',
                                'GET',
                                'NLS',
                                '/loans/participants/participantId/statistics',
                                '{"thirdPartySystem":{"name":"Get Loan","filters":[{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"loans","fields":[{"externalField":"childId","fieldAPI":"Id"},{"externalField":"parentId","fieldAPI":"genesis__Application__c"},{"externalField":"participantId","fieldAPI":"Participant_Id__c"}],"whereClause":"Id IN :loanIdList"}]}}',
                                'application/json',
                                1
                            );
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

        genesis__Application_Pricing_Detail__c objAppPricingDetail = TestClassHelper.createPricingDetail(objApplication.Id);// new genesis__Application_Pricing_Detail__c();
        objAppPricingDetail.Loan_Id__c = '13901';
        objAppPricingDetail.Participant_Id__c='67854';
        objAppPricingDetail.genesis__Enabled_Flag__c = true;
        Database.update(objAppPricingDetail,true);
        genesis__Application_Pricing_Detail__c objApPricingDetail =  new genesis__Application_Pricing_Detail__c();
        objApPricingDetail.Loan_Id__c = '13902';
        objApPricingDetail.Participant_Id__c='67859';
        objApPricingDetail.genesis__Application__c =objApplication.Id;
        objApPricingDetail.genesis__Enabled_Flag__c = true;
        Database.insert(objApPricingDetail,true);
    }

    /**
     * @description This Class implement a interfce method which return mock response of NLS
     */
    public class NLSGetParticipantStatisticsHttpCalloutMock implements HttpCalloutMock {
        // Implement this interface method
        /**
         * @description This method return the mock response of NLS
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
                response.setBody('{"status":{"code":200,"message":"string"},"payload":{"totalCount":0,"count":0,"data":[{"Row_Id":0,"Year_Number":0,"Participantrefno":0,"Master_Record":0,"Month_Number":0,"Principal_Advanced":0,"Principal_Advanced_Num":0,"Principal_Advanced_Average":0,"Principal_Paid":0,"Interest_Earned":0,"Interest_Paid":0,"Interest_Waived":0,"Late_Charges_Earned":0,"Def_Interest_Earned":0,"Def_Interest_Paid":0,"Late_Charges_Paid":0,"Late_Charges_Waived":0,"Def_Interest_Waived":0,"Fees_Earned":0,"Fees_Paid":0,"Fees_Waived":0,"Escrow_Interest_Earned":0,"Escrow_Interest_Paid":0,"Loan_Balance_Total":0,"Loan_Balance_Days":0,"Loan_Balance_Average":0,"Loan_Balance_High":0,"Loan_Balance_Low":0,"Days_Late_10":0,"Days_Late_30":0,"Days_Late_60":0,"Days_Late_90":0,"Days_Late_Over":0,"Nsf_Payments":0,"User_Defined_1":0,"User_Defined_2":0,"User_Defined_3":0,"User_Defined_4":0,"User_Defined_5":0,"User_Defined_6":0,"User_Defined_7":0,"User_Defined_8":0,"User_Defined_9":0,"User_Defined_10":0,"User_Defined_11":0,"User_Defined_12":0,"User_Defined_13":0,"User_Defined_14":0,"User_Defined_15":0,"User_Defined_16":0,"User_Defined_17":0,"User_Defined_18":0,"User_Defined_19":0,"User_Defined_20":0,"User_Defined_21":0,"User_Defined_22":0,"User_Defined_23":0,"User_Defined_24":0,"User_Defined_25":0,"Actuarial_Interest_Earned":0,"Servicing_Fee_Earned":0,"Servicing_Fee_Paid":0}]}}');
            }
            return response;
        }
    }

    /**
     * @description This Class implement a interfce method which return mock response of NLS with different month number length
     */
    public class NLSGetParticipantStatisticsDifferentMonthNumberHttpCalloutMock implements HttpCalloutMock {
        // Implement this interface method
        /**
         * @description This method return the mock response of NLS
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
                response.setBody('{"status":{"code":200,"message":"string"},"payload":{"totalCount":0,"count":0,"data":[{"Row_Id":0,"Year_Number":0,"Participantrefno":0,"Master_Record":0,"Month_Number":202409,"Principal_Advanced":0,"Principal_Advanced_Num":0,"Principal_Advanced_Average":0,"Principal_Paid":0,"Interest_Earned":0,"Interest_Paid":0,"Interest_Waived":0,"Late_Charges_Earned":0,"Def_Interest_Earned":0,"Def_Interest_Paid":0,"Late_Charges_Paid":0,"Late_Charges_Waived":0,"Def_Interest_Waived":0,"Fees_Earned":0,"Fees_Paid":0,"Fees_Waived":0,"Escrow_Interest_Earned":0,"Escrow_Interest_Paid":0,"Loan_Balance_Total":0,"Loan_Balance_Days":0,"Loan_Balance_Average":0,"Loan_Balance_High":0,"Loan_Balance_Low":0,"Days_Late_10":0,"Days_Late_30":0,"Days_Late_60":0,"Days_Late_90":0,"Days_Late_Over":0,"Nsf_Payments":0,"User_Defined_1":0,"User_Defined_2":0,"User_Defined_3":0,"User_Defined_4":0,"User_Defined_5":0,"User_Defined_6":0,"User_Defined_7":0,"User_Defined_8":0,"User_Defined_9":0,"User_Defined_10":0,"User_Defined_11":0,"User_Defined_12":0,"User_Defined_13":0,"User_Defined_14":0,"User_Defined_15":0,"User_Defined_16":0,"User_Defined_17":0,"User_Defined_18":0,"User_Defined_19":0,"User_Defined_20":0,"User_Defined_21":0,"User_Defined_22":0,"User_Defined_23":0,"User_Defined_24":0,"User_Defined_25":0,"Actuarial_Interest_Earned":0,"Servicing_Fee_Earned":0,"Servicing_Fee_Paid":0}]}}');
            }
            return response;
        }
    }

    /**
     * @description This Class implement a interfce method which return mock response of NLS with wrong status code
     */
    public class NLSGetParticipantStatisticsFailHttpCalloutMock implements HttpCalloutMock {
        // Implement this interface method
        /**
         * @description This method return the mock response of NLS
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
                response.setStatusCode(201);
                response.setBody('{"status":{"code":200,"message":"string"},"payload":{"totalCount":0,"count":0,"data":[{"Row_Id":0,"Year_Number":0,"Participantrefno":0,"Master_Record":0,"Month_Number":0,"Principal_Advanced":0,"Principal_Advanced_Num":0,"Principal_Advanced_Average":0,"Principal_Paid":0,"Interest_Earned":0,"Interest_Paid":0,"Interest_Waived":0,"Late_Charges_Earned":0,"Def_Interest_Earned":0,"Def_Interest_Paid":0,"Late_Charges_Paid":0,"Late_Charges_Waived":0,"Def_Interest_Waived":0,"Fees_Earned":0,"Fees_Paid":0,"Fees_Waived":0,"Escrow_Interest_Earned":0,"Escrow_Interest_Paid":0,"Loan_Balance_Total":0,"Loan_Balance_Days":0,"Loan_Balance_Average":0,"Loan_Balance_High":0,"Loan_Balance_Low":0,"Days_Late_10":0,"Days_Late_30":0,"Days_Late_60":0,"Days_Late_90":0,"Days_Late_Over":0,"Nsf_Payments":0,"User_Defined_1":0,"User_Defined_2":0,"User_Defined_3":0,"User_Defined_4":0,"User_Defined_5":0,"User_Defined_6":0,"User_Defined_7":0,"User_Defined_8":0,"User_Defined_9":0,"User_Defined_10":0,"User_Defined_11":0,"User_Defined_12":0,"User_Defined_13":0,"User_Defined_14":0,"User_Defined_15":0,"User_Defined_16":0,"User_Defined_17":0,"User_Defined_18":0,"User_Defined_19":0,"User_Defined_20":0,"User_Defined_21":0,"User_Defined_22":0,"User_Defined_23":0,"User_Defined_24":0,"User_Defined_25":0,"Actuarial_Interest_Earned":0,"Servicing_Fee_Earned":0,"Servicing_Fee_Paid":0}]}}');
            }
            return response;
        }
    }

    /**
     * @description This Class implement a interfce method which return wrong mock response of NLS
     */
    public class NLSGetParticipantStatisticsExceptionHttpCalloutMock implements HttpCalloutMock {
        // Implement this interface method
        /**
         * @description This method return the mock response of NLS
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
                response.setBody('{"status":{"code":200,"message":"string"},"payload":{"totalCount":0,"count":0,"data":[{"Row_Id":0,"Year_Number":0,"Participantrefno":0,"Master_Record":0,"Month_Numbers":0,"Principal_Advanced":0,"Principal_Advanced_Num":0,"Principal_Advanced_Average":0,"Principal_Paid":0,"Interest_Earned":0,"Interest_Paid":0,"Interest_Waived":0,"Late_Charges_Earned":0,"Def_Interest_Earned":0,"Def_Interest_Paid":0,"Late_Charges_Paid":0,"Late_Charges_Waived":0,"Def_Interest_Waived":0,"Fees_Earned":0,"Fees_Paid":0,"Fees_Waived":0,"Escrow_Interest_Earned":0,"Escrow_Interest_Paid":0,"Loan_Balance_Total":0,"Loan_Balance_Days":0,"Loan_Balance_Average":0,"Loan_Balance_High":0,"Loan_Balance_Low":0,"Days_Late_10":0,"Days_Late_30":0,"Days_Late_60":0,"Days_Late_90":0,"Days_Late_Over":0,"Nsf_Payments":0,"User_Defined_1":0,"User_Defined_2":0,"User_Defined_3":0,"User_Defined_4":0,"User_Defined_5":0,"User_Defined_6":0,"User_Defined_7":0,"User_Defined_8":0,"User_Defined_9":0,"User_Defined_10":0,"User_Defined_11":0,"User_Defined_12":0,"User_Defined_13":0,"User_Defined_14":0,"User_Defined_15":0,"User_Defined_16":0,"User_Defined_17":0,"User_Defined_18":0,"User_Defined_19":0,"User_Defined_20":0,"User_Defined_21":0,"User_Defined_22":0,"User_Defined_23":0,"User_Defined_24":0,"User_Defined_25":0,"Actuarial_Interest_Earned":0,"Servicing_Fee_Earned":0,"Servicing_Fee_Paid":0}]}}');
            }
            return response;
        }
    }

    /**
    * @description calls the batch class with no parameter
    * @author Soumik Pattanayak | 12-09-2024 
    **/
    @isTest
    public static void testNLSGetParticipantStatisticsCalloutBatch() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){
            Test.setMock(HttpCalloutMock.class, new NLSGetParticipantStatisticsHttpCalloutMock());
            Test.startTest();
            NLSGetParticipantStatisticsCalloutBatch obj = new NLSGetParticipantStatisticsCalloutBatch();
            Id batchId = Database.executeBatch(obj, 50);
            Test.stopTest();
            System.assert(batchId!=null,'fail');
        }
    }

    /**
    * @description calls the batch class with different month number from NLS
    * @author Soumik Pattanayak | 12-09-2024 
    **/
    @isTest
    public static void testNLSGetParticipantStatisticsCalloutBatchDifferentMonthNumber() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){
            Test.setMock(HttpCalloutMock.class, new NLSGetParticipantStatisticsDifferentMonthNumberHttpCalloutMock());
            Test.startTest();
            NLSGetParticipantStatisticsCalloutBatch obj = new NLSGetParticipantStatisticsCalloutBatch();
            Id batchId = Database.executeBatch(obj, 50);
            Test.stopTest();
            System.assert(batchId!=null,'fail');
        }
    }

    /**
    * @description calls the Batch class with wrong response body from NLS
    * @author Soumik Pattanayak | 12-09-2024 
    **/
    @isTest
    public static void testNLSGetParticipantStatisticsCalloutBatchException() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){
            Test.setMock(HttpCalloutMock.class, new NLSGetParticipantStatisticsExceptionHttpCalloutMock());
            Test.startTest();
            NLSGetParticipantStatisticsCalloutBatch obj = new NLSGetParticipantStatisticsCalloutBatch();
            Id batchId = Database.executeBatch(obj, 50);
            Test.stopTest();
            System.assert(batchId!=null,'fail');
        }
    }

    /**
    * @description calls the batch class with wrong status code from NLS
    * @author Soumik Pattanayak | 12-09-2024 
    **/
    @isTest
    public static void testNLSGetParticipantStatisticsCalloutBatchFail() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){
            Test.setMock(HttpCalloutMock.class, new NLSGetParticipantStatisticsFailHttpCalloutMock());
            Test.startTest();
            NLSGetParticipantStatisticsCalloutBatch obj = new NLSGetParticipantStatisticsCalloutBatch();
            Id batchId = Database.executeBatch(obj, 50);
            Test.stopTest();
            System.assert(batchId!=null,'fail');
        }
    }

    /**
    * @description calls the batch class with pricing details Id list as parameter
    * @author Soumik Pattanayak | 12-09-2024 
    **/
    @isTest
    public static void testCustomDataSuccess() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){
            List<Id> idList = new List<Id>(
                                (new Map<Id, genesis__Application_Pricing_Detail__c>(
                                        [
                                            SELECT Id, 
                                                    genesis__Application__c,
                                                    Participant_Id__c,
                                                    genesis__Application__r.Participant_Id__c
                                            FROM genesis__Application_Pricing_Detail__c
                                            WHERE genesis__Enabled_Flag__c = true
                                            AND Participant_Id__c != null
                                            AND (genesis__Application__r.genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                                            OR genesis__Application__r.Pay_Off_Date__c = THIS_MONTH
                                            OR (Dealer_Interest_Accrued__c != 0 AND genesis__Application__r.Pay_Off_Date__c != null))
                                        ]
                                    )).keySet()
                                );
            Test.setMock(HttpCalloutMock.class, new NLSGetParticipantStatisticsHttpCalloutMock());
            Test.startTest();
            NLSGetParticipantStatisticsCalloutBatch obj = new NLSGetParticipantStatisticsCalloutBatch(idList, genesis__Application_Pricing_Detail__c.class);
            Id batchId = Database.executeBatch(obj, 50);
            Test.stopTest();
            System.assert(batchId!=null,'fail');
        }

    }

    /**
    * @description calls the batch class with no integration frame work
    * @author Soumik Pattanayak | 12-09-2024 
    **/
    @isTest
    public static void testMissingConfigError() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){
            Database.delete([SELECT Id FROM intframework__Integration_Configuration__c WHERE Name = 'Participant Loan Statistics Configuration'], true);

            Test.setMock(HttpCalloutMock.class, new NLSGetParticipantStatisticsHttpCalloutMock());
            Test.startTest();
            NLSGetParticipantStatisticsCalloutBatch obj = new NLSGetParticipantStatisticsCalloutBatch();
            Id batchId = Database.executeBatch(obj, 50);
            Test.stopTest();
            System.assert(batchId!=null,'fail');
        }

    }

    /**
    * @description calls the adapter class with participant Id as null
    * @author Soumik Pattanayak | 12-09-2024 
    **/
    @isTest
    public static void testCustomDataNoParticipantId() {
        
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];

        List<Map<String, String>> loanList = new List<Map<String, String>>();
        genesis__Application_Pricing_Detail__c appPricingObj = [SELECT Id, 
                                                                        genesis__Application__c, 
                                                                        Participant_Id__c 
                                                                FROM genesis__Application_Pricing_Detail__c 
                                                                LIMIT 1];

        String childId=appPricingObj.Id;
        String parentId=appPricingObj.genesis__Application__c;
        //String participantId=appPricingObj.Participant_Id__c;
        Map<String, String> loanRecord = new Map<String, String>();
        loanRecord.put('childId', childId);
        loanRecord.put('parentId', parentId);
        loanRecord.put('participantId', null);

        loanList.add(loanRecord);

        Map<String, List<Map<String, String>>> requestMap = new Map<String, List<Map<String, String>>>();
        requestMap.put('loans', loanList);
        Test.setMock(HttpCalloutMock.class, new NLSGetParticipantStatisticsHttpCalloutMock());
        System.runAs(userObj){
            test.startTest();
            NLSGetParticipantStatisticsAdapter nslAdapterClass = new NLSGetParticipantStatisticsAdapter();
            nslAdapterClass.generateRequestBody(requestMap);

            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://dev1.cfafs.com:8080/loans/participants/{!loan_id}');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            System.HttpResponse response=nslAdapterClass.sendRequest(request);
            test.stopTest();
            System.assert(response!=null,'fail');
        }

    }

    /**
    * @description calls the adapter class with parent Id as null
    * @author Soumik Pattanayak | 12-09-2024 
    **/
    @isTest
    public static void testCustomDataNoParentId() {
        
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];

        List<Map<String, String>> loanList = new List<Map<String, String>>();
        genesis__Application_Pricing_Detail__c appPricingObj = [SELECT Id, 
                                                                        genesis__Application__c, 
                                                                        Participant_Id__c 
                                                                FROM genesis__Application_Pricing_Detail__c 
                                                                LIMIT 1];

        String childId=appPricingObj.Id;
        //String parentId=appPricingObj.genesis__Application__c;
        String participantId=appPricingObj.Participant_Id__c;
        Map<String, String> loanRecord = new Map<String, String>();
        loanRecord.put('childId', childId);
        loanRecord.put('parentId', null);
        loanRecord.put('participantId', participantId);

        loanList.add(loanRecord);

        Map<String, List<Map<String, String>>> requestMap = new Map<String, List<Map<String, String>>>();
        requestMap.put('loans', loanList);
        Test.setMock(HttpCalloutMock.class, new NLSGetParticipantStatisticsHttpCalloutMock());
        System.runAs(userObj){
            test.startTest();
            NLSGetParticipantStatisticsAdapter nslAdapterClass = new NLSGetParticipantStatisticsAdapter();
            nslAdapterClass.generateRequestBody(requestMap);

            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://dev1.cfafs.com:8080/loans/participants/{!loan_id}');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            System.HttpResponse response=nslAdapterClass.sendRequest(request);
            test.stopTest();
            System.assert(response!=null,'fail');
        }

    }

    /**
    * @description calls the adapter class with child Id as null
    * @author Soumik Pattanayak | 12-09-2024 
    **/
    @isTest
    public static void testCustomDataNoChildId() {
        
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];

        List<Map<String, String>> loanList = new List<Map<String, String>>();
        genesis__Application_Pricing_Detail__c appPricingObj = [SELECT Id, 
                                                                        genesis__Application__c, 
                                                                        Participant_Id__c 
                                                                FROM genesis__Application_Pricing_Detail__c 
                                                                LIMIT 1];

        //String childId=appPricingObj.Id;
        String parentId=appPricingObj.genesis__Application__c;
        String participantId=appPricingObj.Participant_Id__c;
        Map<String, String> loanRecord = new Map<String, String>();
        loanRecord.put('childId', null);
        loanRecord.put('parentId', parentId);
        loanRecord.put('participantId', participantId);

        loanList.add(loanRecord);

        Map<String, List<Map<String, String>>> requestMap = new Map<String, List<Map<String, String>>>();
        requestMap.put('loans', loanList);
        Test.setMock(HttpCalloutMock.class, new NLSGetParticipantStatisticsHttpCalloutMock());
        System.runAs(userObj){
            test.startTest();
            NLSGetParticipantStatisticsAdapter nslAdapterClass = new NLSGetParticipantStatisticsAdapter();
            nslAdapterClass.generateRequestBody(requestMap);

            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://dev1.cfafs.com:8080/loans/participants/{!loan_id}');
            request.setMethod('GET');
            request.setHeader('Content-Type', 'application/json');
            System.HttpResponse response=nslAdapterClass.sendRequest(request);
            test.stopTest();
            System.assert(response!=null,'fail');
        }

    }

    /**
    * @description calls the schedule class
    * @author Soumik Pattanayak | 12-09-2024 
    **/
    @IsTest
    public static void testNLSGetParticipantStatisticsSchedule() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            String jobId = System.schedule('Schedule NLS Loan Details Batch' , '0 1 * * * ? *',  new NLSGetParticipantStatisticsSchedule());
            NLSGetParticipantStatisticsSchedule classSchedule = new NLSGetParticipantStatisticsSchedule();
            classSchedule.execute(null);
            Test.stopTest();
            System.Assert(jobId!=null,'fail');
        }
    }
}