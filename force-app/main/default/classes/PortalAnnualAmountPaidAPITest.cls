/**
 * @description       : Test class for PortalAnnualAmountPaidAPI
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 01-24-2025
 * @last modified by  : Ayan Khanra
 * Modifications Log
 * Ver   Date         Author              Modification
 * 1.0   08-28-2024   Ayush Kumar Singh   Initial Version
**/

@IsTest
private without sharing class PortalAnnualAmountPaidAPITest {
    /**
    * @description - Creating Test Data
    * @author Sk Minsar | 09-24-2024 
    **/
    @TestSetup
    static void makeData(){
        ApplicationOriginationSetupTestHelper.createTestSetup();
        // setup integration famil
        intframework__Integration_Family__c familyObj = IntegrationTestInitHelper.getFamily('NLS Integration');
        // setup integration API type
        intframework__Integration_API_Type__c apiTypeObj = IntegrationTestInitHelper.getIntegrationAPIType(familyObj.Id,'NLS Annual Amount Paid API Type');
        // setup integration integrationProviderObj
        intframework__Integration_Provider__c integrationProviderObj = IntegrationTestInitHelper.getIntegrationProvider(familyObj.Id,'NLS Annual Amount Paid Provider');
        // setup integration configration
        intframework__Integration_Configuration__c configObj = IntegrationTestInitHelper.getIntegrationConfiguration(integrationProviderObj.Id,'NLS Annual Amount Paid Configuration','NLS');
        //set up intgration configaration 
        intframework__Integration_API_Configuration__c apiConfigObj = IntegrationTestInitHelper.getIntegrationAPIConfigurationInst(new map<String,Object>{
            'adapterName' => 'NLSGetAnnualAmountPaidAdapter',
            'method' => 'GET',
            'endpoint' => '/loans/loanId/statistics',
            'longRunningOperation' => false,
            'priority' => 1,
            'contentType' => 'application/json',
            'requestMappingJSON' => '{"thirdPartySystem": {"name": "Get Loan","filters": [{"objectAPI": "genesis__Application_Pricing_Detail__c","objectAlias": "loans","fields": [{"externalField": "childId","fieldAPI": "Id"},{"externalField": "loanId","fieldAPI": "Loan_Id__c"}],"whereClause": "Id IN :pricingIdList"}]}}',
            'familyId' => familyObj.Id,
            'apiTypeId' =>  apiTypeObj.Id,
            'providerId' => integrationProviderObj.Id,
            'configId' => configObj.Id
        });
        Database.insert(apiConfigObj,true);
        List<Account> dealerAccountList = [SELECT ID,
                                                    genesis__Business_Information__c
                                            FROM Account 
                                            WHERE Name = 'Kisan Loan' LIMIT 1];
        List<genesis__Applications__c>  applicationList= [SELECT ID,
                                                                    genesis__Loan_Number__c,
                                                                    Dealer_Name__c 
                                                            FROM genesis__Applications__c 
                                                            WHERE Internal_Reference_Code__c = 'testApp001'];
        //create addtion test data                                                
        ApplicationOriginationSetupTestHelper.createAdditionalTestData(applicationList[0],dealerAccountList[0]);
        //query set up header
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = ApplicationOriginationTestHelper.getCFAMyProgram();
        //create another set up detail
        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailsObj =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        rateCardSetupDetailsObj.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_B;
        Database.insert(rateCardSetupDetailsObj,true);
        //create another pricing detail
        genesis__Application_Pricing_Detail__c pricingDetailsObj = ApplicationOriginationTestHelper.createEnabledPricingDetail(applicationList[0],rateCardSetupDetailsObj.Id);
        pricingDetailsObj.Loan_Number__c = applicationList[0].genesis__Loan_Number__c + '-B';
        pricingDetailsObj.Loan_Id__c = '139002';
        Database.insert(pricingDetailsObj,true);
        //create multiple users
        createMultipleUser(dealerAccountList[0].genesis__Business_Information__c,dealerAccountList[0],applicationList[0]);
        // create payment mode
        clcommon__Payment_Mode__c mobileDepositObj = ApplicationOriginationTestHelper.createPaymentMode('MOBILE DEPOSIT');
        clcommon__Payment_Mode__c paymentTypeObj = ApplicationOriginationTestHelper.createPaymentMode('PAYMENT');
        Database.insert(new List<clcommon__Payment_Mode__c>{mobileDepositObj,paymentTypeObj},true);
        //create dealer applicant relation
        List<Contact> borrowerContactList = [SELECT ID,
                                                    AccountId
                                            FROM Contact
                                            WHERE Email = 'jasmin.albin@yopmail.com' Limit 1];
        Dealer_Applicant_Relationship__c dealerAppRelationObj= ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactList[0],applicationList[0].Dealer_Name__c);
        Database.insert(dealerAppRelationObj,true);
    }

    /**
    * @description : This method returns static resource record
    * @author Ayan Khanra | 01-20-2025 
    * @param resourceName 
    * @return StaticResource 
    **/
    private static StaticResource getStaticResource(String resourceName){
        return [SELECT Id,
                        Name,
                        Body 
                FROM StaticResource WHERE Name =: resourceName];
    }

    /**
     * @description Return Mock response for callout
     */
    public class NLSAnnualAmountPaidCalloutMock implements HttpCalloutMock {
        /**
         * @description Implement this interface method
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
                StaticResource staticResourceObj = getStaticResource('NLSAccessToken200SuccessResponse');
                Blob resourceContent = staticResourceObj.Body;
                String textData = resourceContent.toString();
                response.setBody(textData);
            }
            else{
                StaticResource staticResourceObj = getStaticResource('NLSLoanStatistics200SuccessMockResponse');
                Blob resourceContent = staticResourceObj.Body;
                String textData = resourceContent.toString();
                response.setBody(textData);
            }
            return response;
        }
    }

    /**
     * @description Return 400 Bad Request as the Mock response 
     */
    public class NLSAnnualAmountPaidCalloutExceptionMock implements HttpCalloutMock {
        /**
         * @description Implement this interface method
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
                StaticResource staticResourceObj = getStaticResource('NLSAccessToken200SuccessResponse');
                Blob resourceContent = staticResourceObj.Body;
                String textData = resourceContent.toString();
                response.setBody(textData);
            }
            else{
                response.setStatusCode(400);
                response.setStatus('BAD REQUEST');
                StaticResource staticResourceObj = getStaticResource('NLSLoanStatistics400ErrorMockResponse');
                Blob resourceContent = staticResourceObj.Body;
                String textData = resourceContent.toString();
                response.setBody(textData);
            }
            return response;
        }
    }

    /**
     * @description return mock response without token 
     */
    public class NLSAnnualAmountPaidCalloutNullTokenMock implements HttpCalloutMock {
        /**
         * @description Implement this interface method
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setStatus('SUCCESS');
            response.setHeader('Content-Type', 'application/json');
            if(request.getEndpoint().contains('token')){
                StaticResource staticResourceObj = getStaticResource('NLSAccessToken400ErrorResponse');
                Blob resourceContent = staticResourceObj.Body;
                String textData = resourceContent.toString();
                response.setBody(textData);
            }
            else{
                StaticResource staticResourceObj = getStaticResource('NLSLoanStatistics400ErrorMockResponse');
                Blob resourceContent = staticResourceObj.Body;
                String textData = resourceContent.toString();
                response.setBody(textData);
            }
            return response;
        }
    }

    /**
     * @description return null response
     */
    public class NLSAnnualAmountPaidNullResponseMock implements HttpCalloutMock {
        /**
         * @description Implement this interface method
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
                StaticResource staticResourceObj = getStaticResource('NLSAccessToken200SuccessResponse');
                Blob resourceContent = staticResourceObj.Body;
                String textData = resourceContent.toString();
                response.setBody(textData);
            }
            else{
                response.setStatusCode(200);
                response.setStatus('SUCCESS');
                response.setBody(null);
            }
            return response;
        }
    }

    /**
     * @description : This method Returns Certified Lender User
     * @return  `User`
     */
    private static User getCertifiedLenderUser() {
        List<User> userList = [SELECT Id,
                                        ContactId
                                FROM User 
                                WHERE AccountId IN (
                                                SELECT Id 
                                                FROM Account 
                                                WHERE Name = 'Ross Geller') LIMIT 1];
                                    
        return userList[0];
    }

    /**
    * @description :This method returns application
    * @author Ayan Khanra | 01-16-2025 
    * @return List<genesis__Applications__c> 
    **/
    private static List<genesis__Applications__c> getApplication(){
        return [SELECT Id,
                        genesis__Loan_Number__c 
                FROM genesis__Applications__c LIMIT 1];
    }

    /**
    * @description : This method returns inserted logs
    * @author Ayan Khanra | 01-16-2025  
    * @return List<clcommon__Log__c> 
    **/
    private static List<clcommon__Log__c> getInsertedLog(){
        return [SELECT ID
                FROM clcommon__Log__c 
                WHERE Name = 'PortalAnnualAmountPaidAPI' Limit 1];
    }

    /**
    * @description : This method returns Certified lender plus user
    * @author Ayan Khanra | 01-06-2025 
    * @param contactID 
    * @return User 
    **/
    private static User createClPlusUser(Id contactID){
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
    * @description : This method creates cl plus, sa admin user
    * @author Ayan Khanra | 01-16-2025 
    * @param dealerBusinessInfoId 
    * @param dealerAccountObj 
    * @param applicationObj 
    **/
    private static void createMultipleUser(Id dealerBusinessInfoId,Account dealerAccountObj,genesis__Applications__c applicationObj){
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
        User clPlusObj = createClPlusUser(clPlusContactObj.Id);
        User saAdminUerObj = ApplicationOriginationTestHelper.createSAAdminUser(saAdminContactObj.Id);
        Database.insert(new List <User>{clPlusObj,saAdminUerObj},true);
        //create party type 
        clcommon__Party_Type__c clPlusPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER PLUS');
        clcommon__Party_Type__c saAdminPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('SALES AGENT ADMIN');
        //create party
        List<clcommon__Party__c>  multiplePartyList = new List<clcommon__Party__c>();
        Map<String,Id>  clPlusPartyMap = new Map<String,Id>{
            'accountId' => clPlusAccountObj.Id,
            'contactId' => clPlusContactObj.Id,
            'partyTypeId' => clPlusPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        multiplePartyList.add(ApplicationOriginationTestHelper.createParty(clPlusPartyMap));
        Map<String,Id>  saAdminPartyMap = new Map<String,Id>{
            'accountId' => saAdminAccountObj.Id,
            'contactId' => saAdminContactObj.Id,
            'partyTypeId' => saAdminPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        multiplePartyList.add(ApplicationOriginationTestHelper.createParty(saAdminPartyMap)); 
        Database.insert(multiplePartyList,true);
    }
    
    /**
    * @description - Test Method to Check PortalAnnualAmountPaidAPI success
    * @author Sk Minsar | 09-24-2024 
    **/
    @IsTest
    private static void testPortalAnnualAmountPaidAPISuccess() {
        List<genesis__Applications__c> applicationList = getApplication();
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('loanNumber', applicationList[0].genesis__Loan_Number__c);
        requestMap.put('calendar_year', '2024');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new NLSAnnualAmountPaidCalloutMock());
            PortalAnnualAmountPaidAPI annualAmountPaidAPIInst = new PortalAnnualAmountPaidAPI();
            clcommon.Response response = annualAmountPaidAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Exception occured'); 
            Test.stopTest();
        }
    }

    /**
    * @description - This test method runs and gives success in the context of sales agent admin
    * @author  Ayan Khanra | 01-16-2025  
    **/
    @IsTest
    private static void testForSalesAgentAdminSuccess() {
        List<genesis__Applications__c> applicationList = getApplication();
        List<User> saAdminUserList = [SELECT ID 
                                        FROM User WHERE 
                                        UserName='tim.couper@yopmail.com' LIMIT 1];
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('loanNumber', applicationList[0].genesis__Loan_Number__c);
        requestMap.put('calendar_year', '2024');
        System.runAs(saAdminUserList[0]) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new NLSAnnualAmountPaidCalloutMock());
            PortalAnnualAmountPaidAPI annualAmountPaidAPIInst = new PortalAnnualAmountPaidAPI();
            clcommon.Response response = annualAmountPaidAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Exception occured for sales agent admin context'); 
            Test.stopTest();
        }
    }

    /**
    * @description - This test method runs and gives success in the context of certified lender
    * @author  Ayan Khanra | 01-16-2025 
    **/
    @IsTest
    private static void testForClPlusUserSuccess() {
        List<genesis__Applications__c> applicationList = getApplication();
        List<User> clPlusUserList = [SELECT ID 
                                    FROM User WHERE 
                                    UserName='peter.geller@yopmail.com' LIMIT 1];
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('loanNumber', applicationList[0].genesis__Loan_Number__c);
        requestMap.put('calendar_year', '2024');
        System.runAs(clPlusUserList[0]) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new NLSAnnualAmountPaidCalloutMock());
            PortalAnnualAmountPaidAPI annualAmountPaidAPIInst = new PortalAnnualAmountPaidAPI();
            clcommon.Response response = annualAmountPaidAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Exception occured for cl plus user context'); 
            Test.stopTest();
        }
    }

    /**
    * @description - This test method gives exception not having token and logs exception
    * @author Sk Minsar | 09-24-2024 
    **/
    @IsTest
    private static void testPortalAnnualAmountPaidAPIWithoutTokenException() {
        List<genesis__Applications__c> applicationList = getApplication();
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('loanNumber', applicationList[0].genesis__Loan_Number__c);
        requestMap.put('calendar_year', '2024');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new NLSAnnualAmountPaidCalloutNullTokenMock());
            // Calling  the API
            PortalAnnualAmountPaidAPI annualAmountPaidAPIInst = new PortalAnnualAmountPaidAPI();
            clcommon.Response response = annualAmountPaidAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Received success response although access token is missing');
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Log not inserted'); 
            Test.stopTest();
        }
    }

    /**
    * @description - This test method gives exception for having null loan number and logs exception
    * @author Sk Minsar | 09-24-2024 
    **/
    @IsTest
    private static void testPortalAnnualAmountPaidAPINullLoanNumberException() {
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('loanNumber', null);
        requestMap.put('calendar_year', '2024');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            // Calling  the API
            PortalAnnualAmountPaidAPI annualAmountPaidAPIInst = new PortalAnnualAmountPaidAPI();
            clcommon.Response response = annualAmountPaidAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Received success response although loan number is null');
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Log not inserted'); 
            Test.stopTest();
        }
    }

    /**
    * @description - This test method gives exception for having  a loan number that is inavlid
    * @author Sk Minsar | 09-24-2024 
    **/
    @IsTest
    private static void testPortalAnnualAmountPaidAPIWithInvalidLoanNumber() {
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('loanNumber', 'jhgj88999');
        requestMap.put('calendar_year', '2024');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            // Calling  the API
            Test.setMock(HttpCalloutMock.class, new NLSAnnualAmountPaidCalloutExceptionMock());
            PortalAnnualAmountPaidAPI annualAmountPaidAPIInst = new PortalAnnualAmountPaidAPI();
            clcommon.Response response = annualAmountPaidAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Received success response for invalid loan number'); 
            Test.stopTest();
        }
    }

    /**
    * @description - This test method gives success for even after Missing calender year value
    * @author Sk Minsar | 09-24-2024 
    **/
    @IsTest
    private static void testPortalAnnualAmountPaidAPIWithoutCalenderYear() {
        List<genesis__Applications__c> applicationList = getApplication();
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('loanNumber', applicationList[0].genesis__Loan_Number__c);
        requestMap.put('calendar_year', '');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            // Calling  the API
            Test.setMock(HttpCalloutMock.class, new NLSAnnualAmountPaidCalloutExceptionMock());
            PortalAnnualAmountPaidAPI annualAmountPaidAPIInst = new PortalAnnualAmountPaidAPI();
            clcommon.Response response = annualAmountPaidAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    @IsTest
    /**
    * @description : This test method gives exception for loan number key missing
    * @author Ayan Khanra | 01-16-2025 
    **/
    private static void testLoanNumberKeyMissingException() {
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('calendar_year', '2024');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            // Calling  the API
            PortalAnnualAmountPaidAPI annualAmountPaidAPIInst = new PortalAnnualAmountPaidAPI();
            clcommon.Response response = annualAmountPaidAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Received success response although required key missing'); 
            Test.stopTest();
        }
    }

    @IsTest
    /**
    * @description : This test method gives exception for calender year key missing
    * @author Ayan Khanra | 01-16-2025 
    **/
    private static void testCalenderYearKeyMissingException() {
        List<genesis__Applications__c> applicationList = getApplication();
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('loanNumber', applicationList[0].genesis__Loan_Number__c);
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            // Calling  the API
            PortalAnnualAmountPaidAPI annualAmountPaidAPIInst = new PortalAnnualAmountPaidAPI();
            clcommon.Response response = annualAmountPaidAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Received success response although required key missing'); 
            Test.stopTest();
        }
    }

    @IsTest
    /**
    * @description : This test method gives exception for loggin user not having liked with the application
    * @author Ayan Khanra | 01-16-2025 
    **/
    private static void testInvalidLoginUserException() {
        List<clcommon__Party__c> partyList = [SELECT ID 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Type__r.Name = 'CERTIFIED LENDER'];
        Database.delete(partyList,true);                                        
        List<genesis__Applications__c> applicationList = getApplication();
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('loanNumber', applicationList[0].genesis__Loan_Number__c);
        requestMap.put('calendar_year', '2024');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PortalAnnualAmountPaidAPI annualAmountPaidAPIInst = new PortalAnnualAmountPaidAPI();
            clcommon.Response response = annualAmountPaidAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Received success response although logged in user have no party'); 
            Test.stopTest();
        }
    }

    /**
    * @description - This test method throws exception for null response, that we got from callout
    * @author Ayan Khanra | 01-16-2025  
    **/
    @IsTest
    private static void testNullResponseException() {
        List<genesis__Applications__c> applicationList = getApplication();
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('loanNumber', applicationList[0].genesis__Loan_Number__c);
        requestMap.put('calendar_year', '2024');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new NLSAnnualAmountPaidNullResponseMock());
            PortalAnnualAmountPaidAPI annualAmountPaidAPIInst = new PortalAnnualAmountPaidAPI();
            clcommon.Response response = annualAmountPaidAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Received success response although response received from callout is null'); 
            Test.stopTest();
        }
    }

    @IsTest
    /**
    * @description : This test method gives success response although loan id of pricing detail is null
    * @author Ayan Khanra | 01-16-2025 
    **/
    private static void testNullPricingDetailLoanId() {
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = [SELECT ID,
                                                                                    Loan_Id__c
                                                                            FROM genesis__Application_Pricing_Detail__c 
                                                                            WHERE Loan_Id__c='139001'];
        pricingDetailsList[0].Loan_Id__c = null;
        Database.update(pricingDetailsList,true);                    
        List<genesis__Applications__c> applicationList = getApplication();
        Map<String, Object> requestmap = new Map<String, Object>();
        requestMap.put('loanNumber', applicationList[0].genesis__Loan_Number__c);
        requestMap.put('calendar_year', '2024');
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new NLSAnnualAmountPaidCalloutMock());
            PortalAnnualAmountPaidAPI annualAmountPaidAPIInst = new PortalAnnualAmountPaidAPI();
            clcommon.Response response = annualAmountPaidAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Exception occured for pricing detail loan id is null'); 
            Test.stopTest();
        }
    }
}