/**
 * @description       : Test Class for PortalPayoffCalculatorAPI
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 01-24-2025
 * @last modified by  : Ayan Khanra
**/
@isTest
private without sharing class PortalPayoffCalculatorAPITest {
    /**
    * @description : This method is to prepare data for the test class
    * @author Ayan Khanra | 01-12-2025 
    **/
    @TestSetup
    static void setup(){
        Map<String,String> integrationFrameworkMap=new Map<String,String>();
        intframework__Integration_Family__c familyObj = IntegrationTestInitHelper.getFamily(ConstantValues.NLS_INTEGRATION_FAMILY);
        intframework__Integration_API_Type__c modifyFieldAPITypeObj = IntegrationTestInitHelper.getIntegrationAPIType(familyObj.id, ConstantValues.INTEGRATION_API_TYPE_PAYOFF_CALCULATOR);
        intframework__Integration_Provider__c fieldProviderObj = IntegrationTestInitHelper.getIntegrationProvider(familyObj.id,'Payoff Details');
        intframework__Integration_Configuration__c fieldConfigurationObj = IntegrationTestInitHelper.getIntegrationConfiguration(fieldProviderObj.id,'NLS Payoff Details Integration Configuration','NLS');
        integrationFrameworkMap.put('adapterName','NLSLoanPayoffCalculatorAdapter');
        integrationFrameworkMap.put('method','GET');
        integrationFrameworkMap.put('endpoint','loans/loanId/payoff-details?payoffDate=');
        integrationFrameworkMap.put('priority','1');
        integrationFrameworkMap.put('longRunningOperation','NLSLoanPayoffCalculatorAdapter');
        integrationFrameworkMap.put('contentType','application/json');
        integrationFrameworkMap.put('requestMappingJSON','{"thirdPartySystem":{"name":"Payoff Details","filters":[],"dynamicDataParameters":[{"externalField":"loanIdList"},{"externalField":"payoffDate"}]}}');
        integrationFrameworkMap.put('familyId',familyObj.id);
        integrationFrameworkMap.put('apiTypeId',modifyFieldAPITypeObj.id);
        integrationFrameworkMap.put('providerId',fieldProviderObj.id);
        integrationFrameworkMap.put('configId',fieldConfigurationObj.id);
        IntegrationTestInitHelper.getIntegrationAPIConfigurationV2(integrationFrameworkMap);
        ApplicationOriginationSetupTestHelper.createTestSetup();
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                    Name,
                                                                    CreatedById,
                                                                    CreatedBy.Account.Name, 
                                                                    Internal_Reference_Code__c,
                                                                    Dealer_Name__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE Internal_Reference_Code__c ='testApp001'];
        List<Account> dealerAccountList = [SELECT ID,
                                                    Name, 
                                                    genesis__Business_Information__c 
                                                    FROM Account 
                                                    WHERE Name='Kisan Loan' 
                                                    LIMIT 1];                                                     
        applicationList[0].genesis__Loan_Number__c = '300023456'; 
        applicationList[0].genesis__Status__c = ConstantValues.ACTIVE;
        applicationList[0].Reserved_Amount__c = 15000;
        applicationList[0].DocuSign_Credit_Agreement_Initiated__c = true;
        Integer currentMonth = System.today().month();
        if(currentMonth >= 6){
            applicationList[0].Crop_Year__c = String.valueOf(System.today().addYears(1).year());
        } else {
            applicationList[0].Crop_Year__c = String.valueOf(System.today().year());
        }
        Database.update(applicationList[0],true);
        ApplicationOriginationSetupTestHelper.createAdditionalTestData(applicationList[0],dealerAccountList[0]);
        List<Contact> borrContactlist = [SELECT ID,
                                                AccountId
                                        FROM Contact
                                        WHERE Email = 'jasmin.albin@yopmail.com' Limit 1];
        Dealer_Applicant_Relationship__c dealerAppRelationObj= ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrContactlist[0],applicationList[0].Dealer_Name__c);
        Database.insert(dealerAppRelationObj,true);
        createMultipleUser(dealerAccountList[0].genesis__Business_Information__c,dealerAccountList[0]);                                                  
    }

    /**
    * @description : Mock callout for success
    * @author  Pritam Roy | 03-06-2024
    **/
    public class NLSPayoffCalculatorHttpCalloutMock implements HttpCalloutMock {
        /**
       * @description : create mock success response
       * @author  Pritam Roy | 03-06-2024 
       * @param request 
       * @return HTTPResponse 
       **/
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(PortalConstants.TWO_HUNDRED_VALUE);
            response.setStatus(ExternalConstants.SUCCESS_VALUE);
            response.setHeader(ConstantValues.CONTENT_TYPE, ExternalConstants.APPLICATION_JSON);
            if(request.getEndpoint().contains('token')){
                String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
            }
            else{
                response.setBody('{"status":{"code":200,"message":"Success"},"payload":{"data":{"LoanNumber":"344073005-A","ShortName":"JIAN, AROHI","LoanGroup":"PARTICIPATION","InterestPaidThrough":"11/26/2023","PrincipalPaidThrough":"11/26/2023","LoanDate":"11/27/2023","FeesDue":200,"LateCharges":0,"MaturityDate":"12/15/2024","PayoffDate":"12/12/2023","InterestRate":12,"PerDiem":0.6266000001,"PrincipalBalance":1879.8,"AccruedInterest":7.93,"PayoffAmount":2087.73,"Suspense":0,"ServicingFee":0,"UserDefinedLoanBalances":{"UserDefinedLoanBalance1":0,"UserDefinedLoanBalance2":0,"UserDefinedLoanBalance3":0,"UserDefinedLoanBalance4":0,"UserDefinedLoanBalance5":0,"UserDefinedLoanBalance6":0,"UserDefinedLoanBalance7":0,"UserDefinedLoanBalance8":0,"UserDefinedLoanBalance9":0,"UserDefinedLoanBalance10":0}}}}');
            }
            return response;
        }
    }

    /**
    * @description : Mock callout for success for bad data
    * @author  Ayan Khanra | 03-06-2024
    **/
    public class NLSPayoffCalculatorHttpCalloutBadDataMock implements HttpCalloutMock {
        private String mockResponse;

        /**
        * @description 
        * @author Ayan Khanra | 01-12-2025 
        * @param mockResponse 
        **/
        public NLSPayoffCalculatorHttpCalloutBadDataMock(String mockResponse){
            this.mockResponse = mockResponse;
        }
        /**
        * @description : create mock success response
        * @author  Pritam Roy | 03-06-2024 
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(PortalConstants.TWO_HUNDRED_VALUE);
            response.setStatus(ExternalConstants.SUCCESS_VALUE);
            response.setHeader(ConstantValues.CONTENT_TYPE, ExternalConstants.APPLICATION_JSON);
            if(request.getEndpoint().contains('token')){
                String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
            }
            else{
                response.setBody(mockResponse);
            }
            return response;
        }
    }

    /**
    * @description : Mock callout for exception
    * @author  Pritam Roy | 03-06-2024
    **/
    public class NLSPayoffCalculatorHttpCalloutExceptionMock implements HttpCalloutMock {
        /**
        * @description : create mock exception
        * @author  Pritam Roy | 03-06-2024 
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(PortalConstants.TWO_HUNDRED_VALUE);
            response.setStatus(ExternalConstants.SUCCESS_VALUE);
            response.setHeader(ConstantValues.CONTENT_TYPE, ExternalConstants.APPLICATION_JSON);
            if(request.getEndpoint().contains('token')){
                String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
            }
            else{
                response.setBody('{ "status": { "code": 401, "message": "Fail" }, "payload": { "data": "" }}');
            }
            return response;
        }
    }

    /**
    * @description : This method returns Certified lender plus user
    * @author Ayan Khanra | 01-06-2025 
    * @param contactID 
    * @return User 
    **/
    private static User createclPlusUser(Id contactID){
        Profile clProfileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name =: PortalConstants.CERTIFIED_LENDER_PLUS
                                    LIMIT 1];
        User clUserObj = new User();
        clUserObj.Alias = 'newUser';
        clUserObj.Email='peter.geller@yopmail.com';
        clUserObj.EmailEncodingKey='UTF-8';
        clUserObj.LastName='Testing';
        clUserObj.LanguageLocaleKey='en_US';
        clUserObj.LocaleSidKey='en_US';
        clUserObj.ProfileId = clProfileObj.Id;
        clUserObj.ContactId = contactID;
        clUserObj.TimeZoneSidKey='America/Los_Angeles';
        clUserObj.UserName='peter.geller@yopmail.com';
        return clUserObj;
    }

    /**
    * @description : This method creates Diffrent Users
    * @author Ayan Khanra | 01-06-2025 
    * @param dealerBusinessInfoId 
    * @param dealerAccountObj 
    **/
    private static void createMultipleUser(Id dealerBusinessInfoId,Account dealerAccountObj){
        //create account
        Account clPlusAccountObj = ApplicationOriginationTestHelper.createCLPlusAccount(dealerBusinessInfoId,dealerAccountObj.id);
        Account saAdminAccountObj = ApplicationOriginationTestHelper.createSAAdminAccount(dealerBusinessInfoId,dealerAccountObj.id);
        List<Account> accountToInsertList = new List<Account>{clPlusAccountObj,saAdminAccountObj};
        Database.insert(accountToInsertList,true);
        //create contact
        Contact clPlusContactObj = ApplicationOriginationTestHelper.createCLPlusContact(clPlusAccountObj.Id);
        Contact saAdminContactObj = ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccountObj.Id);
        List<Contact> contactToInsertList = new List<Contact>{clPlusContactObj,saAdminContactObj};
        Database.insert(contactToInsertList,true);
        //create User
        User saAdminUerObj = ApplicationOriginationTestHelper.createSAAdminUser(saAdminContactObj.Id);
        User clPlusObj = createclPlusUser(clPlusContactObj.Id);
        Database.insert(new List<User>{saAdminUerObj,clPlusObj},true);
    }
    
    /**
    * @description : This method tests for success response
    * @author  Pritam Roy | 03-06-2024 
    **/
    @isTest
    private static void testPayoffCalculatorResponseSuccess(){
        Map<String,Object> loanDetailVsValueMap = new Map<String,Object>();
        loanDetailVsValueMap.put('loanNumber','300023456');
        loanDetailVsValueMap.put('payoffDate','2025-1-1');
        Test.setMock(HttpCalloutMock.class, new NLSPayoffCalculatorHttpCalloutMock());
        User userObj = getLoggedInUser();
        System.runAs(userObj){
            Test.startTest();
            PortalPayoffCalculatorAPI payoffCalculatorApiInst = new PortalPayoffCalculatorAPI();
            clcommon.Response response = payoffCalculatorApiInst.invokeAction('', new List<String>(), loanDetailVsValueMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'No Success message in response');     
            Test.stopTest();
        }
    }

    /**
    * @description : This method tests for success response for SAAdmin context
    * @author  Ayan Khanra | 03-06-2024 
    **/
    @isTest
    private static void testForSAAdminSuccess(){
        Map<String,Object> loanDetailVsValueMap = new Map<String,Object>();
        loanDetailVsValueMap.put('loanNumber','300023456');
        loanDetailVsValueMap.put('payoffDate','2025-1-1');
        Test.setMock(HttpCalloutMock.class, new NLSPayoffCalculatorHttpCalloutMock());
        List<User> userList = getUser('tim.couper@yopmail.com');
        System.runAs(userList[0]){
            Test.startTest();
            PortalPayoffCalculatorAPI payoffCalculatorApiInst = new PortalPayoffCalculatorAPI();
            clcommon.Response response = payoffCalculatorApiInst.invokeAction('', new List<String>(), loanDetailVsValueMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'No Success message in response');     
            Test.stopTest();
        }
    }
    
    /**
    * @description : This method tests for success response for cl Plus context
    * @author  Ayan Khanra | 03-06-2024 
    **/
    @isTest
    private static void testForClPlusSuccess(){
        Map<String,Object> loanDetailVsValueMap = new Map<String,Object>();
        loanDetailVsValueMap.put('loanNumber','300023456');
        loanDetailVsValueMap.put('payoffDate','2025-1-1');
        Test.setMock(HttpCalloutMock.class, new NLSPayoffCalculatorHttpCalloutMock());
        List<User> userList = getUser('peter.geller@yopmail.com'); 
        System.runAs(userList[0]){
            Test.startTest();
            PortalPayoffCalculatorAPI payoffCalculatorApiInst = new PortalPayoffCalculatorAPI();
            clcommon.Response response = payoffCalculatorApiInst.invokeAction('', new List<String>(), loanDetailVsValueMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'No Success message in response');     
            Test.stopTest();
        }
    }

    /**
    * @description : This test method  gives exception for loan number that is not present
    * @author  Pritam Roy | 03-06-2024 
    **/
    @isTest
    private static void testInvalidLoanNumberException(){
        Map<String,Object> loanDetailVsValueMap = new Map<String,Object>();
        loanDetailVsValueMap.put('loanNumber','864443926');
        loanDetailVsValueMap.put('payoffDate','2025-1-1');
        Test.setMock(HttpCalloutMock.class, new NLSPayoffCalculatorHttpCalloutExceptionMock());
        User userObj = getLoggedInUser();
        System.runAs(userObj){
            Test.startTest();
            PortalPayoffCalculatorAPI payoffCalculatorApiInst = new PortalPayoffCalculatorAPI();
            clcommon.Response response = payoffCalculatorApiInst.invokeAction('', new List<String>(), loanDetailVsValueMap); 
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Test Failed for Invalid lonan number');
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Log not inserted');    
            Test.stopTest();
        }
    }

    /**
    * @description :  This method tests for missing Loan Number key in request body
    * @author Ayan Khanra | 01-02-2025 
    **/
    @isTest
    private static void testMissingLoanNumberKeyException(){
        Map<String,Object> loanDetailVsValueMap = new Map<String,Object>();
        loanDetailVsValueMap.put('','300023456');
        loanDetailVsValueMap.put('payoffDate','2025-1-1');
        Test.setMock(HttpCalloutMock.class, new NLSPayoffCalculatorHttpCalloutExceptionMock());
        User userObj = getLoggedInUser();
        System.runAs(userObj){
            Test.startTest();
            PortalPayoffCalculatorAPI payoffCalculatorApiInst = new PortalPayoffCalculatorAPI();
            clcommon.Response response = payoffCalculatorApiInst.invokeAction('', new List<String>(), loanDetailVsValueMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Test Failed for missing Loan number Key');     
            Test.stopTest();
        }
    }

    /**
    * @description : This method tests for missing pay off date key in request body
    * @author Ayan Khanra | 01-02-2025 
    **/
    @isTest
    private static void testMissingPayoffDateKeyException(){
        Map<String,Object> loanDetailVsValueMap = new Map<String,Object>();
        loanDetailVsValueMap.put('loanNumber','300023456');
        loanDetailVsValueMap.put('','2025-1-1');
        Test.setMock(HttpCalloutMock.class, new NLSPayoffCalculatorHttpCalloutExceptionMock());
        User userObj = getLoggedInUser();
        System.runAs(userObj){
            Test.startTest();
            PortalPayoffCalculatorAPI payoffCalculatorApiInst = new PortalPayoffCalculatorAPI();
            clcommon.Response response = payoffCalculatorApiInst.invokeAction('', new List<String>(), loanDetailVsValueMap);  
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Test Failed for missing payoff key');   
            Test.stopTest();
        }
    }

    /**
    * @description : This method tests for null Loan Number coming from request body
    * @author Ayan Khanra | 01-02-2025 
    **/
    @isTest
    private static void testNullLoanNumberException(){
        Map<String,Object> loanDetailVsValueMap = new Map<String,Object>();
        loanDetailVsValueMap.put('loanNumber',null);
        loanDetailVsValueMap.put('payoffDate','2025-1-1');
        Test.setMock(HttpCalloutMock.class, new NLSPayoffCalculatorHttpCalloutExceptionMock());
        User userObj = getLoggedInUser();
        System.runAs(userObj){
            Test.startTest();
            PortalPayoffCalculatorAPI payoffCalculatorApiInst = new PortalPayoffCalculatorAPI();
            clcommon.Response response = payoffCalculatorApiInst.invokeAction('', new List<String>(), loanDetailVsValueMap);    
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Test Failed for loanNumber Null value'); 
            Test.stopTest();
        }
    }

    /**
    * @description : This method tests for null payoffDate value from request body
    * @author Ayan Khanra | 01-02-2025 
    **/
    @isTest
    private static void testNullPayOffDateException(){
        Map<String,Object> loanDetailVsValueMap = new Map<String,Object>();
        loanDetailVsValueMap.put('loanNumber','300023456');
        loanDetailVsValueMap.put('payoffDate',null);
        Test.setMock(HttpCalloutMock.class, new NLSPayoffCalculatorHttpCalloutExceptionMock());
        User userObj = getLoggedInUser();
        System.runAs(userObj){
            Test.startTest();
            PortalPayoffCalculatorAPI payoffCalculatorApiInst = new PortalPayoffCalculatorAPI();
            clcommon.Response response = payoffCalculatorApiInst.invokeAction('', new List<String>(), loanDetailVsValueMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Test Failed for null payoff date value');
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Log not inserted');     
            Test.stopTest();
        } 
    }

    /**
    * @description : This method tests for invalid fees due value  that cannot be converted to decimal value 
    * @author Ayan Khanra | 01-02-2025 
    **/
    @isTest
    private static void testInvalidFeesDueException(){
        Map<String,Object> loanDetailVsValueMap = new Map<String,Object>();
        loanDetailVsValueMap.put('loanNumber','300023456');
        loanDetailVsValueMap.put('payoffDate','2025-1-1');
        Test.setMock(HttpCalloutMock.class, new  NLSPayoffCalculatorHttpCalloutBadDataMock('{"status":{"code":200,"message":"Success"},"payload":{"data":{"LoanNumber":"344073005-A","ShortName":"JIAN, AROHI","LoanGroup":"PARTICIPATION","InterestPaidThrough":"11/26/2023","PrincipalPaidThrough":"11/26/2023","LoanDate":"11/27/2023","FeesDue":ABC,"LateCharges":0,"MaturityDate":"12/15/2024","PayoffDate":"12/12/2023","InterestRate":12,"PerDiem":0.6266000001,"PrincipalBalance":1879.8,"AccruedInterest":7.93,"PayoffAmount":2087.73,"Suspense":0,"ServicingFee":0,"UserDefinedLoanBalances":{"UserDefinedLoanBalance1":0,"UserDefinedLoanBalance2":0,"UserDefinedLoanBalance3":0,"UserDefinedLoanBalance4":0,"UserDefinedLoanBalance5":0,"UserDefinedLoanBalance6":0,"UserDefinedLoanBalance7":0,"UserDefinedLoanBalance8":0,"UserDefinedLoanBalance9":0,"UserDefinedLoanBalance10":0}}}}'));
        User userObj = getLoggedInUser();
        System.runAs(userObj){
            Test.startTest();
            PortalPayoffCalculatorAPI payoffCalculatorApiInst = new PortalPayoffCalculatorAPI();
            clcommon.Response response = payoffCalculatorApiInst.invokeAction('', new List<String>(), loanDetailVsValueMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Test Failed for invalid Fees due value');
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Log not inserted');     
            Test.stopTest();
        } 
    }

    /**
    * @description : This method tests for invalid principal value coming from portal that cannot be converted to decimal value 
    * @author Ayan Khanra | 01-02-2025 
    **/
    @isTest
    private static void testInvalidPrincipalValueException(){
        Map<String,Object> loanDetailVsValueMap = new Map<String,Object>();
        loanDetailVsValueMap.put('loanNumber','300023456');
        loanDetailVsValueMap.put('payoffDate','2025-1-1');
        Test.setMock(HttpCalloutMock.class, new  NLSPayoffCalculatorHttpCalloutBadDataMock('{"status":{"code":200,"message":"Success"},"payload":{"data":{"LoanNumber":"344073005-A","ShortName":"JIAN, AROHI","LoanGroup":"PARTICIPATION","InterestPaidThrough":"11/26/2023","PrincipalPaidThrough":"11/26/2023","LoanDate":"11/27/2023","FeesDue":200,"LateCharges":0,"MaturityDate":"12/15/2024","PayoffDate":"12/12/2023","InterestRate":12,"PerDiem":0.6266000001,"PrincipalBalance":ABC,"AccruedInterest":7.93,"PayoffAmount":2087.73,"Suspense":0,"ServicingFee":0,"UserDefinedLoanBalances":{"UserDefinedLoanBalance1":0,"UserDefinedLoanBalance2":0,"UserDefinedLoanBalance3":0,"UserDefinedLoanBalance4":0,"UserDefinedLoanBalance5":0,"UserDefinedLoanBalance6":0,"UserDefinedLoanBalance7":0,"UserDefinedLoanBalance8":0,"UserDefinedLoanBalance9":0,"UserDefinedLoanBalance10":0}}}}'));
        User userObj = getLoggedInUser();
        System.runAs(userObj){
            Test.startTest();
            PortalPayoffCalculatorAPI payoffCalculatorApiInst = new PortalPayoffCalculatorAPI();
            clcommon.Response response = payoffCalculatorApiInst.invokeAction('', new List<String>(), loanDetailVsValueMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Test Failed for invalid Principal value');
            Test.stopTest();
        } 
    }
    /**
    * @description : This method tests for invalid Accrude value coming from portal that cannot be converted to decimal value 
    * @author Ayan Khanra | 01-02-2025 
    **/
    @isTest
    private static void testInvalidAccrudeInterestException(){
        Map<String,Object> loanDetailVsValueMap = new Map<String,Object>();
        loanDetailVsValueMap.put('loanNumber','300023456');
        loanDetailVsValueMap.put('payoffDate','2025-1-1');
        Test.setMock(HttpCalloutMock.class, new  NLSPayoffCalculatorHttpCalloutBadDataMock('{"status":{"code":200,"message":"Success"},"payload":{"data":{"LoanNumber":"344073005-A","ShortName":"JIAN, AROHI","LoanGroup":"PARTICIPATION","InterestPaidThrough":"11/26/2023","PrincipalPaidThrough":"11/26/2023","LoanDate":"11/27/2023","FeesDue":200,"LateCharges":0,"MaturityDate":"12/15/2024","PayoffDate":"12/12/2023","InterestRate":12,"PerDiem":0.6266000001,"PrincipalBalance":1879.8,"AccruedInterest":,"PayoffAmount":2087.73,"Suspense":0,"ServicingFee":0,"UserDefinedLoanBalances":{"UserDefinedLoanBalance1":0,"UserDefinedLoanBalance2":0,"UserDefinedLoanBalance3":0,"UserDefinedLoanBalance4":0,"UserDefinedLoanBalance5":0,"UserDefinedLoanBalance6":0,"UserDefinedLoanBalance7":0,"UserDefinedLoanBalance8":0,"UserDefinedLoanBalance9":0,"UserDefinedLoanBalance10":0}}}}'));
        User userObj = getLoggedInUser();
        System.runAs(userObj){
            Test.startTest();
            PortalPayoffCalculatorAPI payoffCalculatorApiInst = new PortalPayoffCalculatorAPI();
            clcommon.Response response = payoffCalculatorApiInst.invokeAction('', new List<String>(), loanDetailVsValueMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Test Failed for invalid Accrude interest value');
            Test.stopTest();
        } 
    }

    /**
    * @description : This method returns loggedIn user
    * @author Ayan Khanra | 01-07-2025 
    * @return User 
    **/
    private static User getLoggedInUser(){
        return [SELECT Id
                FROM USER 
                WHERE Id = :UserInfo.getUserId() 
                LIMIT 1];
    }
    /**
    * @description : This method returns inserted logs
    * @author Ayan Khanra | 01-07-2025 
    * @return List<clcommon__Log__c> 
    **/
    private static List<clcommon__Log__c> getInsertedLog(){
        return [SELECT ID
                FROM clcommon__Log__c 
                WHERE Name = 'PortalPayoffCalculatorAPI' Limit 1];
    }
    /**
    * @description : Returns User based on userName
    * @author Ayan Khanra | 01-07-2025 
    * @param name 
    * @return List<User> 
    **/
    private static List<User> getUser(String name){
        return [SELECT ID 
                FROM User 
                WHERE UserName =: name Limit 1];
    }
}