/**
 * @description       : Test class for NLSGetParticipantInterestCalloutBatch and NLSGetParticipantInterestAdapter
 * @author            : Simran
 * @group             : 
 * @last modified on  : 11-29-2024
 * @last modified by  : Ayan Bhowmik
**/

@isTest
global without sharing class TestNLSGetParticipantInterest{

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
                                'Participant Get Loan Interest API Type'
                            );
        intframework__Integration_Provider__c provider = 
                        IntegrationTestInitHelper.getIntegrationProvider(
                                family.Id, 
                                'Participant Get Loan Interest Provider'
                            );
        intframework__Integration_Configuration__c config = 
                        IntegrationTestInitHelper.getIntegrationConfiguration(
                                provider.Id,
                                'Participant Get Loan Interest Configuration',
                                'NLS'
                            );
        IntegrationTestInitHelper.getIntegrationAPIConfiguration(
                                family.Id,
                                apiType.Id,
                                provider.Id,
                                config.Id,
                                false,
                                'NLSGetParticipantInterestAdapter',
                                'GET',
                                'NLS',
                                '/loans/participants/participantId',
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
        objApplication.Pay_Off_Date__c = Date.today().toStartOfMonth().addDays(-1);
        
        Database.insert(objApplication,true);

        genesis__Application_Pricing_Detail__c appPricingDetailObj = TestClassHelper.createPricingDetail(objApplication.Id);// new genesis__Application_Pricing_Detail__c();
        appPricingDetailObj.Loan_Id__c = '13901';
        appPricingDetailObj.Participant_Id__c='67854';
        appPricingDetailObj.genesis__Enabled_Flag__c = true;
        Database.update(appPricingDetailObj,true);

        Map<String, Object> monthAndYearMap = getMonthAndYear();
        List<genesis__Application_Fee_Payment__c> applicationFeePaymentList = TestClassHelper.createApplicationFeePaymentList(objApplication.Id,appPricingDetailObj.Id);
        genesis__Application_Fee_Payment__c objFeePayment= applicationFeePaymentList[0];
        objFeePayment.External_Id__c=appPricingDetailObj.Id + '-' 
        + String.valueOf(monthAndYearMap.get('year')) + '-'
        + String.valueOf(monthAndYearMap.get('year')) 
        + monthAndYearMap.get('month');
        
        Database.insert(applicationFeePaymentList,true);
    }
    /**
     * @description This class implements an interface method which return the mock response of NLS
     */
    public class NLSGetParticipantInterestHttpCalloutMock implements HttpCalloutMock {
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
            else{
                response.setBody('{"status":{"code":200,"message":"string"},"payload":{"versionHash":"string","data":{"Participantrefno":0,"Acctrefno":0,"Loan_Group_No":0,"Participant_Type":0,"Participant_Number":"string","Cifno":0,"Vendor_Id":0,"Shortname":"string","Name":"string","Input_Date":"2022-10-26T12:08:07.738Z","Status_Code_No":0,"Last_Activity_Date":"2022-10-26T12:08:07.738Z","Original_Note_Amount":0,"Current_Note_Amount":0,"Notes":"string","Current_Principal_Balance":0,"Current_Interest_Balance":0,"Current_Def_Interest_Balance":0,"Current_Fees_Balance":0,"Current_Late_Charge_Balance":0,"Current_Udf1_Balance":0,"Current_Payoff_Balance":0,"Current_Udf2_Balance":0,"Current_Perdiem":0,"Current_Udf3_Balance":0,"Current_Suspense":0,"Current_Udf4_Balance":0,"Current_Interest_Rate":0,"Current_Udf5_Balance":0,"Current_Udf6_Balance":0,"Starting_Interest_Rate":0,"Starting_Year_Interest_Rate":0,"Current_Def_Perdiem":0,"Current_Udf7_Balance":0,"Last_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Current_Udf8_Balance":0,"Current_Udf9_Balance":0,"Current_Ao_Interest_Rate":0,"Current_Udf10_Balance":0,"Next_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Interest_Step_Date":"2022-10-26T12:08:07.738Z","Default_Interest_Indicator":0,"Compound_Interest_Balance":0,"Starting_Year_Def_Int_Rate":0,"Starting_Def_Interest_Rate":0,"Current_Def_Interest_Rate":0,"Last_Def_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Def_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Def_Interest_Step_Date":"2022-10-26T12:08:07.738Z","Default_Def_Interest_Indicator":0,"Last_Ao_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Ao_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Ao_Interest_Step_Date":"2022-10-26T12:08:07.738Z","Starting_Ao_Interest_Rate":0,"Starting_Ao_Year_Rate":0,"Default_Ao_Interest_Indicator":0,"Current_Ol1_Balance":0,"Current_Ol2_Balance":0,"Current_Ol3_Balance":0,"Current_Impound_Balance":0,"Last_Def_Ao_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Def_Ao_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Def_Ao_Interest_Step_Date":"2022-10-26T12:08:07.738Z","Starting_Def_Ao_Interest_Rate":0,"Starting_Def_Ao_Year_Rate":0,"Current_Def_Ao_Interest_Rate":0,"Current_Servicing_Balance":0,"Current_Reserve_Balance":0,"Next_Recurring_Trans_Date":"2022-10-26T12:08:07.738Z","Addonint_Remaining":0,"Addonint_Total":0,"Current_Adb_Interest_Balance":0,"Current_TierRateNo":0,"Current_Def_TierRateNo":0}}}');
            }
            return response;
        }
    }

    /**
    * @description This class implements an interface method which return the wrong mock response of NLS
    */
    public class NLSGetParticipantInterestRequestErrorHttpCalloutMock implements HttpCalloutMock {
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
            else{
                response.setBody('{"status":{"code":200,"message":"string"},"payload":{"versionHash":"string","data":{"Participantrefno":0,"Acctrefno":0,"Loan_Group_No":0,"Participant_Type":0,"Participant_Number":"string","Cifno":0,"Vendor_Id":0,"Shortname":"string","Name":"string","Input_Date":"2022-10-26T12:08:07.738Z","Status_Code_No":0,"Last_Activity_Date":"2022-10-26T12:08:07.738Z","Original_Note_Amount":0,"Current_Note_Amount":0,"Notes":"string","Current_Principal_Balance":0,"Current_Interest_Balance":"abc","Current_Def_Interest_Balance":0,"Current_Fees_Balance":0,"Current_Late_Charge_Balance":0,"Current_Udf1_Balance":0,"Current_Payoff_Balance":0,"Current_Udf2_Balance":0,"Current_Perdiem":0,"Current_Udf3_Balance":0,"Current_Suspense":0,"Current_Udf4_Balance":0,"Current_Interest_Rate":0,"Current_Udf5_Balance":0,"Current_Udf6_Balance":0,"Starting_Interest_Rate":0,"Starting_Year_Interest_Rate":0,"Current_Def_Perdiem":0,"Current_Udf7_Balance":0,"Last_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Current_Udf8_Balance":0,"Current_Udf9_Balance":0,"Current_Ao_Interest_Rate":0,"Current_Udf10_Balance":0,"Next_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Interest_Step_Date":"2022-10-26T12:08:07.738Z","Default_Interest_Indicator":0,"Compound_Interest_Balance":0,"Starting_Year_Def_Int_Rate":0,"Starting_Def_Interest_Rate":0,"Current_Def_Interest_Rate":0,"Last_Def_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Def_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Def_Interest_Step_Date":"2022-10-26T12:08:07.738Z","Default_Def_Interest_Indicator":0,"Last_Ao_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Ao_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Ao_Interest_Step_Date":"2022-10-26T12:08:07.738Z","Starting_Ao_Interest_Rate":0,"Starting_Ao_Year_Rate":0,"Default_Ao_Interest_Indicator":0,"Current_Ol1_Balance":0,"Current_Ol2_Balance":0,"Current_Ol3_Balance":0,"Current_Impound_Balance":0,"Last_Def_Ao_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Def_Ao_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Def_Ao_Interest_Step_Date":"2022-10-26T12:08:07.738Z","Starting_Def_Ao_Interest_Rate":0,"Starting_Def_Ao_Year_Rate":0,"Current_Def_Ao_Interest_Rate":0,"Current_Servicing_Balance":0,"Current_Reserve_Balance":0,"Next_Recurring_Trans_Date":"2022-10-26T12:08:07.738Z","Addonint_Remaining":0,"Addonint_Total":0,"Current_Adb_Interest_Balance":0,"Current_TierRateNo":0,"Current_Def_TierRateNo":0}}}');
            }
            return response;
        }
    }

    /**
     * @description This class implements an interface method which return the mock response of NLS but different status code
     */
    public class NLSGetParticipantInterestFailHttpCalloutMock implements HttpCalloutMock {
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
            else{
                response.setStatusCode(201);
                response.setBody('{"status":{"code":201,"message":"string"},"payload":{"versionHash":"string","data":{"Participantrefno":0,"Acctrefno":0,"Loan_Group_No":0,"Participant_Type":0,"Participant_Number":"string","Cifno":0,"Vendor_Id":0,"Shortname":"string","Name":"string","Input_Date":"2022-10-26T12:08:07.738Z","Status_Code_No":0,"Last_Activity_Date":"2022-10-26T12:08:07.738Z","Original_Note_Amount":0,"Current_Note_Amount":0,"Notes":"string","Current_Principal_Balance":0,"Current_Interest_Balance":0,"Current_Def_Interest_Balance":0,"Current_Fees_Balance":0,"Current_Late_Charge_Balance":0,"Current_Udf1_Balance":0,"Current_Payoff_Balance":0,"Current_Udf2_Balance":0,"Current_Perdiem":0,"Current_Udf3_Balance":0,"Current_Suspense":0,"Current_Udf4_Balance":0,"Current_Interest_Rate":0,"Current_Udf5_Balance":0,"Current_Udf6_Balance":0,"Starting_Interest_Rate":0,"Starting_Year_Interest_Rate":0,"Current_Def_Perdiem":0,"Current_Udf7_Balance":0,"Last_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Current_Udf8_Balance":0,"Current_Udf9_Balance":0,"Current_Ao_Interest_Rate":0,"Current_Udf10_Balance":0,"Next_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Interest_Step_Date":"2022-10-26T12:08:07.738Z","Default_Interest_Indicator":0,"Compound_Interest_Balance":0,"Starting_Year_Def_Int_Rate":0,"Starting_Def_Interest_Rate":0,"Current_Def_Interest_Rate":0,"Last_Def_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Def_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Def_Interest_Step_Date":"2022-10-26T12:08:07.738Z","Default_Def_Interest_Indicator":0,"Last_Ao_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Ao_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Ao_Interest_Step_Date":"2022-10-26T12:08:07.738Z","Starting_Ao_Interest_Rate":0,"Starting_Ao_Year_Rate":0,"Default_Ao_Interest_Indicator":0,"Current_Ol1_Balance":0,"Current_Ol2_Balance":0,"Current_Ol3_Balance":0,"Current_Impound_Balance":0,"Last_Def_Ao_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Def_Ao_Rate_Change_Date":"2022-10-26T12:08:07.738Z","Next_Def_Ao_Interest_Step_Date":"2022-10-26T12:08:07.738Z","Starting_Def_Ao_Interest_Rate":0,"Starting_Def_Ao_Year_Rate":0,"Current_Def_Ao_Interest_Rate":0,"Current_Servicing_Balance":0,"Current_Reserve_Balance":0,"Next_Recurring_Trans_Date":"2022-10-26T12:08:07.738Z","Addonint_Remaining":0,"Addonint_Total":0,"Current_Adb_Interest_Balance":0,"Current_TierRateNo":0,"Current_Def_TierRateNo":0}}}');
            }
            return response;
        }
    }

    /**
    * @description returns the month and year
    * @author Soumik Pattanayak | 11-09-2024 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getMonthAndYear() {
        Integer yearNumber = Date.today().year();
        Integer monthNumber = Date.today().month() - 1;

        if (monthNumber <= 0) {
            monthNumber = 12;
            yearNumber -= 1;
        }

        String month = (monthNumber / 10 == 0) ? '0' + monthNumber : '' + monthNumber;

        return new Map<String, Object> {
            'month' => month,
            'year' => yearNumber
        };
    }

    /**
    * @description calls the batch class with no parameter
    * @author Soumik Pattanayak | 12-09-2024 
    **/
    @isTest
    public static void testNLSGetParticipantInterestAll() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new NLSGetParticipantInterestHttpCalloutMock());
        System.runAs(userObj){
            test.startTest();
            NLSGetParticipantInterestCalloutBatch obj = new NLSGetParticipantInterestCalloutBatch();
            Id batchId=Database.executeBatch(obj, 50);
            test.stopTest();
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
        Test.setMock(HttpCalloutMock.class, new NLSGetParticipantInterestHttpCalloutMock());
        System.runAs(userObj){
            test.startTest();
            NLSGetParticipantInterestCalloutBatch obj = new NLSGetParticipantInterestCalloutBatch(idList, genesis__Application_Pricing_Detail__c.class);
            Id batchId=Database.executeBatch(obj, 50);
            test.stopTest();
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
        Test.setMock(HttpCalloutMock.class, new NLSGetParticipantInterestHttpCalloutMock());
        System.runAs(userObj){
            test.startTest();
            NLSGetParticipantInterestAdapter nslAdapterClass = new NLSGetParticipantInterestAdapter();
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
        Test.setMock(HttpCalloutMock.class, new NLSGetParticipantInterestHttpCalloutMock());
        System.runAs(userObj){
            test.startTest();
            NLSGetParticipantInterestAdapter nslAdapterClass = new NLSGetParticipantInterestAdapter();
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
    public static void testCustomDataNochildId() {
        
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
        Test.setMock(HttpCalloutMock.class, new NLSGetParticipantInterestHttpCalloutMock());
        System.runAs(userObj){
            test.startTest();
            NLSGetParticipantInterestAdapter nslAdapterClass = new NLSGetParticipantInterestAdapter();
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
    * @description calls the batch class with wrong response body
    * @author Soumik Pattanayak | 12-09-2024 
    **/
    @isTest
    public static void testCustomDataWrongResponseBody() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
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
        Test.setMock(HttpCalloutMock.class, new NLSGetParticipantInterestRequestErrorHttpCalloutMock());
        System.runAs(userObj){
            test.startTest();
            NLSGetParticipantInterestCalloutBatch obj = new NLSGetParticipantInterestCalloutBatch(idList, genesis__Application_Pricing_Detail__c.class);
            Id batchId=Database.executeBatch(obj, 50);
            test.stopTest();
            System.assert(batchId!=null,'fail');
        }
    }

    /**
    * @description calls the batch class with 201 as status code
    * @author Soumik Pattanayak | 12-09-2024 
    **/
    @isTest
    public static void testCustomDataFailure() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];

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
        Test.setMock(HttpCalloutMock.class, new NLSGetParticipantInterestFailHttpCalloutMock());
        System.runAs(userObj){
            test.startTest();
            NLSGetParticipantInterestCalloutBatch obj = new NLSGetParticipantInterestCalloutBatch(idList, genesis__Application_Pricing_Detail__c.class);
            Id batchId=Database.executeBatch(obj, 50);
            test.stopTest();
            System.assert(batchId!=null,'fail');
        }

    }

    /**
    * @description calls the batch class with application Id list as parameter
    * @author Soumik Pattanayak | 12-09-2024 
    **/
    @isTest
    public static void testCustomDataSuccessApplication() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        List<Id> idList = new List<Id>(
                            (new Map<Id, genesis__Applications__c>(
                                    [
                                        SELECT Id, 
                                                Participant_Id__c
                                        FROM genesis__Applications__c
                                        WHERE Participant_Id__c != null
                                        AND (genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                                        OR Pay_Off_Date__c = THIS_MONTH
                                        OR Pay_Off_Date__c != null)
                                    ]
                                )).keySet()
                            );
        Test.setMock(HttpCalloutMock.class, new NLSGetParticipantInterestHttpCalloutMock());
        System.runAs(userObj){
            test.startTest();
            NLSGetParticipantInterestCalloutBatch obj = new NLSGetParticipantInterestCalloutBatch(idList, genesis__Applications__c.class);
            Id batchId=Database.executeBatch(obj, 50);
            test.stopTest();
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
        Database.delete([SELECT Id FROM intframework__Integration_Configuration__c WHERE Name = 'Participant Get Loan Interest Configuration'], true);
        Test.setMock(HttpCalloutMock.class, new NLSGetParticipantInterestHttpCalloutMock());
        System.runAs(userObj){
            test.startTest();
            NLSGetParticipantInterestCalloutBatch obj = new NLSGetParticipantInterestCalloutBatch();
            Id batchId=Database.executeBatch(obj, 50);
            test.stopTest();
            System.assert(batchId!=null,'fail');
        }
    }
    /**
    * @description calling the schedule class
    * @author Soumik Pattanayak | 12-09-2024 
    **/
    @IsTest
    public static void testNLSGetParticipantSchedule() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            System.schedule('Schedule NLS Participant Batch' , '0 1 * * * ? *',  new NLSGetParticipantInterestBatchSchedule());
            NLSGetParticipantInterestBatchSchedule classSchedule = new NLSGetParticipantInterestBatchSchedule();
            classSchedule.execute(null);
            Test.stopTest();
            AsyncApexJob schedule = [SELECT Id, Status, JobType, ApexClass.Name FROM AsyncApexJob WHERE ApexClass.Name = 'NLSGetParticipantInterestBatchSchedule'];
            System.Assert.areEqual('Queued', schedule.Status, 'JobStatus');
            //System.assert(scheduleId!=null,'fail');
        }
    }
}