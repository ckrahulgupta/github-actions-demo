/**
 * @description       : Test class of NLSClosedChildPayoffCalloutBatch
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 03-24-2025
 * @last modified by  : Sk Minsar
**/
@isTest
public with sharing class NLSClosedChildPayoffCalloutBatchTest {

    private static final String ASSERTION_FAILED = 'Assertion Failed';
    private static final String KEY_APPLICATION_LIST = 'applicationList';
    private static final String KEY_DEALER_ACCOUNT_LIST = 'dealerAccountList';
    private static final String PROFILE_CFA_USER = 'CFA User';
    private static final String CLASS_NAME = NLSClosedChildPayoffCalloutBatch.class.getName();
    private static final Integer RECORDS_COUNT = 10;
    private static final Integer BATCH_SIZE = 40;

    /**
    * @description - Creating test data
    * @author Sk Minsar | 03-17-2025 
    **/
    @testSetup
    static void setup(){    
     
        //creating legal entity 
        clcommon__Legal_Entity__c entityObj= LoanServicingTestHelper.createLegalEntity(ConstantValues.SOLE_PROP_ENTITY);
        Database.insert(entityObj,true);

        //creating floating rate index
        clcommon__Floating_Rate_Index__c floatingRateIndexObj = LoanServicingTestHelper.createFloatingRateIndex(
            New Map<String, Object>{'Name' => 'Field Finance Rate',
                                    'Base Rate Name' => '4-CFA ADVANTAGE',
                                    'Current Floating Rate' => 11,
                                    'Base Rate Adjuster' => 5.5
            });
        Database.insert(floatingRateIndexObj, true);

        //creating new partnert program
        CFA_Partner_Program__c newPartnerProgramObj = LoanServicingTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);

        //creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForDealer();
        dealerBusinessInfoObj.Approved_Loan_Amount__c = 0;
        dealerBusinessInfoObj.Contract_Loan_Limit__c = 1000000;  
        dealerBusinessInfoObj.Customised_Loan_Limit__c = 500000; 
        dealerBusinessInfoObj.Customised_Individual_Limit__c = 250000; 
        dealerBusinessInfoObj.Remaining_Customised_Limit__c = 500000;
        Database.insert(dealerBusinessInfoObj,true);

        //creating dealer account
        Account dealerAccountObj = LoanServicingTestHelper.createDealerAccount(dealerBusinessInfoObj.Id, newPartnerProgramObj.Id);
        Database.insert(dealerAccountObj, true);

        //creating accounts
        Account clAccountObj = LoanServicingTestHelper.createCLAccount(dealerBusinessInfoObj.Id,dealerAccountObj.Id);
        Account borrowerAccountObj=LoanServicingTestHelper.createSolePropAccount(entityObj,LoanServicingTestHelper.createBusinessInfoForBorrower().Id);
        Database.insert(new List<Account>{clAccountObj, borrowerAccountObj}, true);

        //creating contacts
        Contact clContactObj = LoanServicingTestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj=LoanServicingTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(new List<Contact>{clContactObj, borrowerContactObj}, true);

        //creating reciprocal role
        clcommon__Reciprocal_Role__c roleObj = LoanServicingTestHelper.createReciprocalRole(ConstantValues.CERTIFIED_LENDER);
        Database.insert(roleObj,true);

        //creating Relationship between dealer and certified lender
        clcommon__Relationship__c clDealerRelationshipObj = LoanServicingTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        //creating cl product
        clcommon__CL_Product__c clProductObj=LoanServicingTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        //creating cl purpose
        clcommon__CL_Purpose__c clPurposeObj=LoanServicingTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj,true);

        //creating dealer applicant relationship
        Dealer_Applicant_Relationship__c relationObj = LoanServicingTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Database.insert(relationObj,true);
       
        Map<String,Id> paramIdMap=new Map<String,Id>();
        paramIdMap.put('dealerAccountId',dealerAccountObj.Id);
        paramIdMap.put('clProductId',clProductObj.Id);
        paramIdMap.put('clPurposeId',clPurposeObj.Id);
        paramIdMap.put('borrowerAccountId',borrowerAccountObj.Id);
        paramIdMap.put('borrowerContactId',borrowerContactObj.Id);
        paramIdMap.put('clAccountId',clAccountObj.Id);
        paramIdMap.put('dealerApplicantRelationshipId',relationObj.Id);

        //creating applications
        List<genesis__Applications__c> applicationList = LoanServicingTestHelper.createCurrCropYearApplicationList(paramIdMap, RECORDS_COUNT);
        Database.insert(applicationList, true);

        List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList = ApplicationOriginationTestHelper.createCreditRatingMatrix();
        Database.insert(creditRatingMatrixList,true);
        //creating pricingdetails
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = LoanServicingTestHelper.createPricingDetailList(applicationList, ConstantValues.TRUE_VALUE, RECORDS_COUNT);
        Database.insert(pricingDetailsList, true);

        //creating users
        User adminUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_ADMIN, 'testadminuser445@yopmail.com')[0];
        User cfaUser = LoanServicingTestHelper.createUserByProfileName(PROFILE_CFA_USER, 'test1cfa.user112@yopmail.com')[0];
        User executiveUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_EXECUTIVE, 'test2cfa.user113@yopmail.com')[0];
        User fieldStaffUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_FIELD_STAFF, 'test3cfa.user114@yopmail.com')[0];
        User creditUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_CREDIT, 'test4cfa.user115@yopmail.com')[0];
        User masterCreditUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_MASTER_CREDIT, 'test6cfa.user117@yopmail.com')[0];
        User loanAccountingUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_LOAN_ACCOUNTING, 'test8cfa.user119@yopmail.com')[0];
        User cfaAdminUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_CFA_ADMIN, 'test01cfa.user103@yopmail.com')[0];
        User clUser = LoanServicingTestHelper.createCLUser(clContactObj.Id);
        Database.insert(new List<User>{cfaUser, clUser, executiveUser, fieldStaffUser, creditUser, masterCreditUser, loanAccountingUser, cfaAdminUser, adminUser}, true);

        //Setting up the Integration Framework to fetch the child pay off details
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily('NLS Integration');
        intframework__Integration_API_Type__c childPayoffDetailsAPIType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, ConstantValues.INTEGRATION_API_TYPE_CHILD_PAYOFF_DETAILS);
        intframework__Integration_Provider__c childPayoffProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Payoff Details');
        intframework__Integration_Configuration__c childPayoffDetailsConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            childPayoffProvider.Id,'NLS Payoff Details Integration Configuration','NLS');

        intframework__Integration_API_Configuration__c apiConfigObj = IntegrationTestInitHelper.getIntegrationAPIConfigurationInst(new map<String,Object>{
            'adapterName' => 'NLSChildPayoffDetailsAdapter',
            'method' => 'GET',
            'endpoint' => 'loans/loanId/payoff-details?payoffDate=',
            'longRunningOperation' => false,
            'priority' => 1,
            'contentType' => 'application/json',
            'requestMappingJSON' => '{ "thirdPartySystem": {  "name": "Payoff Details",  "filters": [   {    "objectAPI": "genesis__Application_Pricing_Detail__c",    "objectAlias": "Pricing Details",    "fields": [     {      "externalField": "ID",      "fieldAPI": "Id"     },     {      "externalField": "loanId",      "fieldAPI": "Loan_Id__c"     }    ],    "whereClause": "Id IN :applicationIdList"   }  ] }}',
            'familyId' => family.Id,
            'apiTypeId' =>  childPayoffDetailsAPIType.Id,
            'providerId' => childPayoffProvider.Id,
            'configId' => childPayoffDetailsConfig.Id
            });
        Database.insert(apiConfigObj,true);
        
    }

    /**
     * @description       : Setting up the Mock Response of SUCCESS status for NLSClosedChildPayoffCalloutBatch
     * @author            : Sk Minsar
     * @last modified on  : 03-24-2025
     * @last modified by  : Sk Minsar
    **/
    public class NLSGetChildPayOffHttpCalloutMock implements HttpCalloutMock {
        // Implement this interface method
        /**
        * @description : returns the Mock Response of SUCCESS status
        * @author Sk Minsar | 03-17-2025  
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
                StaticResource staticResourceObj = getStaticResource('NLSAccessToken200SuccessResponse');
                Blob resourceContent = staticResourceObj.Body;
                String textData = resourceContent.toString();
                response.setBody(textData);
            }
            else{
                StaticResource staticResourceObj = getStaticResource('NLSLoanPayoffDetails200SuccessMockResponse');
                Blob resourceContent = staticResourceObj.Body;
                String textData = resourceContent.toString();
                response.setBody(textData);
            }
            return response;
        }
    }

    /**
     * @description       : Setting up the Mock Response of Null for NLSClosedChildPayoffCalloutBatch
     * @author            : Sk Minsar
     * @last modified on  : 03-24-2025
     * @last modified by  : Sk Minsar
    **/
    public class NLSGetChildPayOffNullResponseMock implements HttpCalloutMock {
        // Implement this interface method
        /**
        * @description : returns the Mock Response of SUCCESS status
        * @author Sk Minsar | 03-17-2025  
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
                StaticResource staticResourceObj = getStaticResource('NLSAccessToken200SuccessResponse');
                Blob resourceContent = staticResourceObj.Body;
                String textData = resourceContent.toString();
                response.setBody(textData);
            }
            else{
                response.setBody(null);
            }
            return response;
        }
    }

    /**
     * @description       : Setting up the Mock Response of Failure status, Access Denied for NLSClosedChildPayoffCalloutBatch
     * @author            : Sk Minsar
     * @last modified on  : 03-24-2025
     * @last modified by  : Sk Minsar
    **/
    public class NLSGetChildPayOffBadRequestResponseMock implements HttpCalloutMock {
        
        // Implement this interface method
        /**
        * @description : returns the Mock Response of Bad Request status
        * @author Sk Minsar | 03-17-2025  
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setStatus('FAILURE');
            response.setHeader('Content-Type', 'application/json');
            StaticResource staticResourceObj = getStaticResource('NLSLoanPayoffDetails400BadRequestMockResponse');
            Blob resourceContent = staticResourceObj.Body;
            String textData = resourceContent.toString();
            response.setBody(textData);
            return response;
        }
    }

    /**
     * @description       : Setting up the Mock Response of Failure status, Access Denied for NLSClosedChildPayoffCalloutBatch
     * @author            : Sk Minsar
     * @last modified on  : 03-24-2025
     * @last modified by  : Sk Minsar
    **/
    public class NLSGetChildPayOffAccessDeniedResponseMock implements HttpCalloutMock {
        
        // Implement this interface method
        /**
        * @description : returns the Mock Response of Access Denied status
        * @author Sk Minsar | 03-17-2025  
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(403);
            response.setStatus('FAILURE');
            response.setHeader('Content-Type', 'application/json');
            StaticResource staticResourceObj = getStaticResource('NLSLoanPayoffDetails403AccessDeniedMockResponse');
            Blob resourceContent = staticResourceObj.Body;
            String textData = resourceContent.toString();
            response.setBody(textData);
            return response;
        }
    }

    /**
     * @description       : Setting up the Mock Response of Failure status, Loan Not Found for NLSClosedChildPayoffCalloutBatch
     * @author            : Sk Minsar
     * @last modified on  : 03-24-2025
     * @last modified by  : Sk Minsar
    **/
    public class NLSGetChildPayOffNoLoanFoundResponseMock implements HttpCalloutMock {
        
        // Implement this interface method
        /**
        * @description : returns the Mock Response of No Loan Found status
        * @author Sk Minsar | 03-17-2025  
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(404);
            response.setStatus('FAILURE');
            response.setHeader('Content-Type', 'application/json');
            StaticResource staticResourceObj = getStaticResource('NLSLoanPayoffDetails404NoLoanFoundResponse');
            Blob resourceContent = staticResourceObj.Body;
            String textData = resourceContent.toString();
            response.setBody(textData);
            return response;
        }
    }

    /**
     * @description       : Setting up the Mock Response of Failure status, Internal Server Error for NLSClosedChildPayoffCalloutBatch
     * @author            : Sk Minsar
     * @last modified on  : 03-24-2025
     * @last modified by  : Sk Minsar
    **/
    public class NLSGetChildPayOffServerErrorResponseMock implements HttpCalloutMock {
        
        // Implement this interface method
        /**
        * @description : returns the Mock Response of Server Error status
        * @author Sk Minsar | 03-17-2025  
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(500);
            response.setStatus('FAILURE');
            response.setHeader('Content-Type', 'application/json');
            return response;
        }
    }


    /**
    * @description : This method returns static resource
    * @author Sk Minsar | 03-18-2025 
    * @param resourceName 
    * @return StaticResource 
    **/
    private static StaticResource getStaticResource(String resourceName){
        return [SELECT Id,
                        Name,
                        Body 
                FROM StaticResource WHERE Name =: resourceName LIMIT 1];
    }

    /**
    * @description - This method queries and returns all the necessary data
    * @author Sk Minsar | 03-05-2025 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getDataMap(){
        List<genesis__Applications__c> applicationList = [SELECT Id, Reserved_Amount__c, genesis__Maturity_Date__c, genesis__Loan_Number__c, genesis__Account__c, Dealer_name__r.CFA_Partner_Program__c, Loan_Id__c FROM genesis__Applications__c WHERE genesis__Status__c =: ConstantValues.ACTIVE ORDER BY genesis__Loan_Number__c LIMIT :RECORDS_COUNT];
        List<Account> dealerAccountList = [SELECT Id, Name, Coop_Type__c FROM Account WHERE RecordType.Name = :ConstantValues.DEALER LIMIT 1];

        return new Map<String, Object>{
            KEY_APPLICATION_LIST => applicationList,
            KEY_DEALER_ACCOUNT_LIST => dealerAccountList
        };
    }

    /**
    * @description - Return logs
    * @author Sk Minsar | 03-20-2025 
    * @return List<clcommon__Log__c> 
    **/
    private static List<clcommon__Log__c> getLogs(){
        return [SELECT Name, clcommon__Message__c, clcommon__Time__c 
                                        FROM clcommon__Log__c LIMIT :PortalConstants.TWO_HUNDRED_VALUE];
    }

    /**
    * @description - Return pricing details list for list of application
    * @author Sk Minsar | 03-20-2025 
    * @param applicationList 
    * @return List<genesis__Application_Pricing_Detail__c> 
    **/
    private static List<genesis__Application_Pricing_Detail__c> getPricingList(List<genesis__Applications__c> applicationList){
        return [SELECT ID, Payoff_Amount_via_Mobile__c, Fees__c, Accrued_Interest__c FROM genesis__Application_Pricing_Detail__c WHERE genesis__application__c In :applicationList];
    }
    
    /**
    * @description - Return AysncApexJobList
    * @author Sk Minsar | 03-24-2025 
    * @return List<AsyncApexJob> 
    **/
    private static List<AsyncApexJob> getAsyncJobList(){
        List<ApexClass> calloutBatchList = [SELECT Id FROM ApexClass WHERE Name = :CLASS_NAME LIMIT 1];
        return [SELECT Id, ApexClassId, Status FROM AsyncApexJob WHERE ApexClassId =:calloutBatchList[0].Id LIMIT 1];
    }
    
    /**
    * @description - Test with close loan
    * @author Sk Minsar | 03-17-2025 
    **/
    @isTest
    public static void testClosedChildLoanPayoffDetailsBatch() {
        Map<String, Object> dataMap = getDataMap();
        List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 

        System.runAs(userObj[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffHttpCalloutMock());
                NLSClosedChildPayoffCalloutBatch getChildLoans = new NLSClosedChildPayoffCalloutBatch();
                Database.executeBatch(getChildLoans, BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(0.0, pricingList[0].Fees__c, ASSERTION_FAILED);
            System.assertEquals(4215.51, pricingList[0].Payoff_Amount_via_Mobile__c, ASSERTION_FAILED);
            System.assertEquals(15.51, pricingList[0].Accrued_Interest__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with close loan with null response
    * @author Sk Minsar | 03-17-2025 
    **/
    @isTest
    public static void testClosedChildWithNullResponse() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 

        System.runAs(userObj[0]){
            Test.startTest();
                try{
                    Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffNullResponseMock());
                    NLSClosedChildPayoffCalloutBatch getChildLoans = new NLSClosedChildPayoffCalloutBatch();
                    Database.executeBatch(getChildLoans, BATCH_SIZE);
                } catch (Exception e){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                }
            Test.stopTest();
            List<clcommon__Log__c> logList = getLogs();
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
            System.assertEquals(ConstantValues.TRUE_VALUE, logList.size()>0, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with multiple closed loans
    * @author Sk Minsar | 03-17-2025 
    **/
    @isTest
    public static void testMultipleClosedLoanSuccess() {
        Map<String, Object> dataMap = getDataMap();
        List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        for(genesis__Applications__c application: applicationList){
            application.genesis__Status__c = ConstantValues.CLOSED;
        }
        Database.update(applicationList, true); 

        System.runAs(userObj[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffHttpCalloutMock());
                NLSClosedChildPayoffCalloutBatch getChildLoans = new NLSClosedChildPayoffCalloutBatch();
                Database.executeBatch(getChildLoans, BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(applicationList);
            for(genesis__Application_Pricing_Detail__c pricingObj: pricingList){
                System.assertEquals(0.0, pricingObj.Fees__c, ASSERTION_FAILED);
                System.assertEquals(4215.51, pricingObj.Payoff_Amount_via_Mobile__c, ASSERTION_FAILED);
                System.assertEquals(15.51, pricingObj.Accrued_Interest__c, ASSERTION_FAILED);
            }
        }
    }

    /**
    * @description - Test with active loans
    * @author Sk Minsar | 03-17-2025 
    **/
    @isTest
    public static void testActiveLoanSuccess() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();

        System.runAs(userObj[0]){
            Test.startTest();
                try{
                    Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffHttpCalloutMock());
                    NLSClosedChildPayoffCalloutBatch getChildLoans = new NLSClosedChildPayoffCalloutBatch();
                    Database.executeBatch(getChildLoans, BATCH_SIZE);
                } catch(Exception objException){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                }
            Test.stopTest();
            List<clcommon__Log__c> logList = getLogs();
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
            System.assertEquals(ConstantValues.ZERO_VALUE, logList.size(), ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with null loan Id
    * @author Sk Minsar | 03-17-2025 
    **/
    @isTest
    private static void testNullLoanId() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        applicationList[0].Loan_Id__c = null;
        Database.update(applicationList[0], true); 

        System.runAs(userObj[0]){
            Test.startTest();
                try{
                    Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffHttpCalloutMock());
                    NLSClosedChildPayoffCalloutBatch getChildLoans = new NLSClosedChildPayoffCalloutBatch();
                    Database.executeBatch(getChildLoans, BATCH_SIZE);
                } catch(Exception objException){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                }
            Test.stopTest();
            List<clcommon__Log__c> logList = getLogs();
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
            System.assertEquals(ConstantValues.TRUE_VALUE, logList.size()>0, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test closed loan with executive profile
    * @author Sk Minsar | 03-17-2025 
    **/
    @isTest
    public static void testClosedLoanWithExecutiveProfile() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 

        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_EXECUTIVE)[0]){
            Test.startTest();
                try{
                    Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffHttpCalloutMock());
                    NLSClosedChildPayoffCalloutBatch getChildLoans = new NLSClosedChildPayoffCalloutBatch();
                    Database.executeBatch(getChildLoans, BATCH_SIZE);
                } catch(Exception objException){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                }
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
            System.assertEquals(0.0, pricingList[0].Fees__c, ASSERTION_FAILED);
            System.assertEquals(4215.51, pricingList[0].Payoff_Amount_via_Mobile__c, ASSERTION_FAILED);
            System.assertEquals(15.51, pricingList[0].Accrued_Interest__c, ASSERTION_FAILED);
            
        }
    }

    /**
    * @description - Test closed loan with Loan Accounting profile
    * @author Sk Minsar | 03-17-2025 
    **/
    @isTest
    public static void testClosedLoanWithLoanAccountingProfile() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 

        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_LOAN_ACCOUNTING)[0]){
            Test.startTest();
                try{
                    Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffHttpCalloutMock());
                    NLSClosedChildPayoffCalloutBatch getChildLoans = new NLSClosedChildPayoffCalloutBatch();
                    Database.executeBatch(getChildLoans, BATCH_SIZE);
                } catch(Exception objException){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                }
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
            System.assertEquals(0.0, pricingList[0].Fees__c, ASSERTION_FAILED);
            System.assertEquals(4215.51, pricingList[0].Payoff_Amount_via_Mobile__c, ASSERTION_FAILED);
            System.assertEquals(15.51, pricingList[0].Accrued_Interest__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test closed loan with Field Staff profile
    * @author Sk Minsar | 03-17-2025 
    **/
    @isTest
    public static void testClosedLoanWithFieldStaffProfile() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 

        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_FIELD_STAFF)[0]){
            Test.startTest();
                try{
                    Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffHttpCalloutMock());
                    NLSClosedChildPayoffCalloutBatch getChildLoans = new NLSClosedChildPayoffCalloutBatch();
                    Database.executeBatch(getChildLoans, BATCH_SIZE);
                } catch(Exception objException){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                }
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
            System.assertEquals(0.0, pricingList[0].Fees__c, ASSERTION_FAILED);
            System.assertEquals(4215.51, pricingList[0].Payoff_Amount_via_Mobile__c, ASSERTION_FAILED);
            System.assertEquals(15.51, pricingList[0].Accrued_Interest__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test closed loan with CFA USER profile
    * @author Sk Minsar | 03-17-2025 
    **/
    @isTest
    public static void testClosedLoanWithCFAUserProfile() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 

        System.runAs(LoanServicingTestHelper.getUserByProfileName(PROFILE_CFA_USER)[0]){
            Test.startTest();
                try{
                    Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffHttpCalloutMock());
                    NLSClosedChildPayoffCalloutBatch getChildLoans = new NLSClosedChildPayoffCalloutBatch();
                    Database.executeBatch(getChildLoans, BATCH_SIZE);
                } catch(Exception objException){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                }
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
            System.assertEquals(0.0, pricingList[0].Fees__c, ASSERTION_FAILED);
            System.assertEquals(4215.51, pricingList[0].Payoff_Amount_via_Mobile__c, ASSERTION_FAILED);
            System.assertEquals(15.51, pricingList[0].Accrued_Interest__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test closed loan with CFA Admin profile
    * @author Sk Minsar | 03-17-2025 
    **/
    @isTest
    public static void testClosedLoanWithCFAAdminProfile() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 

        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_CFA_ADMIN)[0]){
            Test.startTest();
                try{
                    Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffHttpCalloutMock());
                    NLSClosedChildPayoffCalloutBatch getChildLoans = new NLSClosedChildPayoffCalloutBatch();
                    Database.executeBatch(getChildLoans, BATCH_SIZE);
                } catch(Exception objException){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                }
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
            System.assertEquals(0.0, pricingList[0].Fees__c, ASSERTION_FAILED);
            System.assertEquals(4215.51, pricingList[0].Payoff_Amount_via_Mobile__c, ASSERTION_FAILED);
            System.assertEquals(15.51, pricingList[0].Accrued_Interest__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test closed loan with Credit profile
    * @author Sk Minsar | 03-17-2025 
    **/
    @isTest
    public static void testClosedLoanWithCrditProfile() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 

        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_CREDIT)[0]){
            Test.startTest();
                try{
                    Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffHttpCalloutMock());
                    NLSClosedChildPayoffCalloutBatch getChildLoans = new NLSClosedChildPayoffCalloutBatch();
                    Database.executeBatch(getChildLoans, BATCH_SIZE);
                } catch(Exception objException){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                }
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
            System.assertEquals(0.0, pricingList[0].Fees__c, ASSERTION_FAILED);
            System.assertEquals(4215.51, pricingList[0].Payoff_Amount_via_Mobile__c, ASSERTION_FAILED);
            System.assertEquals(15.51, pricingList[0].Accrued_Interest__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test closed loan with Master Credit profile
    * @author Sk Minsar | 03-17-2025 
    **/
    @isTest
    public static void testClosedLoanWithMasterCreditProfile() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 

        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_MASTER_CREDIT)[0]){
            Test.startTest();
                try{
                    Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffHttpCalloutMock());
                    NLSClosedChildPayoffCalloutBatch getChildLoans = new NLSClosedChildPayoffCalloutBatch();
                    Database.executeBatch(getChildLoans, BATCH_SIZE);
                } catch(Exception objException){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                }
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
            System.assertEquals(0.0, pricingList[0].Fees__c, ASSERTION_FAILED);
            System.assertEquals(4215.51, pricingList[0].Payoff_Amount_via_Mobile__c, ASSERTION_FAILED);
            System.assertEquals(15.51, pricingList[0].Accrued_Interest__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test closed loan for Bad Request response
    * @author Sk Minsar | 03-24-2025 
    **/
    @isTest
    public static void testClosedLoanForBadRequest() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 

        System.runAs(ApplicationOriginationTestHelper.getAdminUser()[0]){
            Test.startTest();
                try{
                    Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffBadRequestResponseMock());
                    NLSClosedChildPayoffCalloutBatch getChildLoans = new NLSClosedChildPayoffCalloutBatch();
                    Database.executeBatch(getChildLoans, BATCH_SIZE);
                } catch(Exception objException){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                }
            Test.stopTest();
            List<AsyncApexJob> asyncJobList = getAsyncJobList();
            System.assertEquals(ConstantValues.TRUE_VALUE, asyncJobList[0].Status != null, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test closed loan for access denied
    * @author Sk Minsar | 03-24-2025 
    **/
    @isTest
    public static void testClosedLoanForAccessDenied() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 

        System.runAs(ApplicationOriginationTestHelper.getAdminUser()[0]){
            Test.startTest();
                try{
                    Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffAccessDeniedResponseMock());
                    NLSClosedChildPayoffCalloutBatch getChildLoans = new NLSClosedChildPayoffCalloutBatch();
                    Database.executeBatch(getChildLoans, BATCH_SIZE);
                } catch(Exception objException){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                }
            Test.stopTest();
            List<AsyncApexJob> asyncJobList = getAsyncJobList();
            System.assertEquals(ConstantValues.TRUE_VALUE, asyncJobList[0].Status != null, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test closed loan for No Loan Found response
    * @author Sk Minsar | 03-24-2025 
    **/
    @isTest
    public static void testClosedLoanForNoLoanFound() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 

        System.runAs(ApplicationOriginationTestHelper.getAdminUser()[0]){
            Test.startTest();
                try{
                    Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffNoLoanFoundResponseMock());
                    NLSClosedChildPayoffCalloutBatch getChildLoans = new NLSClosedChildPayoffCalloutBatch();
                    Database.executeBatch(getChildLoans, BATCH_SIZE);
                } catch(Exception objException){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                }
            Test.stopTest();
            List<AsyncApexJob> asyncJobList = getAsyncJobList();
            System.assertEquals(ConstantValues.TRUE_VALUE, asyncJobList[0].Status != null, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test closed loan for Server Error response
    * @author Sk Minsar | 03-24-2025 
    **/
    @isTest
    public static void testClosedLoanForServerError() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 

        System.runAs(ApplicationOriginationTestHelper.getAdminUser()[0]){
            Test.startTest();
                try{
                    Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffServerErrorResponseMock());
                    NLSClosedChildPayoffCalloutBatch getChildLoans = new NLSClosedChildPayoffCalloutBatch();
                    Database.executeBatch(getChildLoans, BATCH_SIZE);
                } catch(Exception objException){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                }
            Test.stopTest();
            List<AsyncApexJob> asyncJobList = getAsyncJobList();
            System.assertEquals(ConstantValues.TRUE_VALUE, asyncJobList[0].Status != null, ASSERTION_FAILED);
        }
    }

}