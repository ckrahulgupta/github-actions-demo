/**
 * @description       : Test class of NLSClosedParticipantIdBatch
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 03-21-2025
 * @last modified by  : Sk Minsar
**/
@isTest
public with sharing class NLSClosedParticipantIdBatchTest {

    private static final String ASSERTION_FAILED = 'Assertion Failed';
    private static final String KEY_APPLICATION_LIST = 'applicationList';
    private static final String KEY_DEALER_ACCOUNT_LIST = 'dealerAccountList';
    private static final String PROFILE_CFA_USER = 'CFA User';
    private static final String CLASS_NAME = NLSClosedChildLoanCalloutBatch.class.getName();
    private static final String GET_PARTICIPANTS_ID_API_CONFIG = 'NLS Get Participant Id Configuration';
    private static final String PARTICIPANT_ID = '284836';
    private static final Integer RECORDS_COUNT = 10;
    private static final Integer BATCH_SIZE = 40;
    private static final Integer LOAN_ID = 139000;

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

        //creating new partner program
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

        //creating relationship between dealer and certified lender
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

        //Create multi tranche loan
        createMultiTranceLoan(dealerAccountObj, pricingDetailsList);

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

        //Setting up the Integration Framework to fetch the Pariticipants Id
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily('NLS Integration 2');
        intframework__Integration_API_Type__c participantsIdAPIType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Participants Id Integration API Type');
        intframework__Integration_Provider__c getParticipantsIdProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Get Participants ID');
        intframework__Integration_Configuration__c getParticipantsIdConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            getParticipantsIdProvider.Id,GET_PARTICIPANTS_ID_API_CONFIG,'NLS');
        intframework__Integration_API_Configuration__c apiConfigObj = IntegrationTestInitHelper.getIntegrationAPIConfigurationInst(new map<String,Object>{
            'adapterName' => 'NLSFetchParticipantIdAdapter',
            'method' => 'GET',
            'endpoint' => 'loans/loanId/participants',
            'longRunningOperation' => false,
            'priority' => 1,
            'contentType' => 'application/json',
            'requestMappingJSON' => '{"thirdPartySystem":{"name":"p","filters":[{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"pricing","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"loanId","fieldAPI":"Loan_Id__c"},{"externalField":"ParentLoanId","fieldAPI":"genesis__Application__r.Loan_Id__c"},{"externalField":"ParentId","fieldAPI":"genesis__Application__c"}],"whereClause":"Id IN :pricingId"}],"dynamicDataParameters":[{"externalField":"loanType"}]}}',
            'familyId' => family.Id,
            'apiTypeId' =>  participantsIdAPIType.Id,
            'providerId' => getParticipantsIdProvider.Id,
            'configId' => getParticipantsIdConfig.Id
            });
        Database.insert(apiConfigObj,true);
        
    }

    /**
    * @description - Create multi tranche loan
    * @author Sk Minsar | 03-28-2025 
    * @param dealerAccountObj 
    * @param pricingDetailsList 
    **/
    private static void createMultiTranceLoan(Account dealerAccountObj, List<genesis__Application_Pricing_Detail__c> pricingDetailsList){
        Integer counter = 0; 
        //Create rate card setup header
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerAccountObj);
        rateCardHeaderObj.Name = 'Test Rate Card Header With Two Tranches';
        Database.Insert(rateCardHeaderObj, true);

        //Create rate card setup details
        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailsObjAA =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        rateCardSetupDetailsObjAA.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_A;
        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailsObjAB =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        rateCardSetupDetailsObjAB.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_B;
        Database.Insert(new List<genesis__Rate_Card_Setup_Detail__c>{
            rateCardSetupDetailsObjAA,
            rateCardSetupDetailsObjAB
        }, true);

        //Query in the application list
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);

        //Create pricing details
        List<genesis__Application_Pricing_Detail__c> multipleTranchePricings = LoanServicingTestHelper.createPricingDetailsForMultipleTranche(rateCardHeaderObj, applicationList[1]);
        multipleTranchePricings.addAll(pricingDetailsList);
        for(genesis__Application_Pricing_Detail__c pricingObj: multipleTranchePricings){
            counter += 10;
            pricingObj.Loan_Id__c = String.valueOf(LOAN_ID - counter);
        }
        Database.Insert(multipleTranchePricings, true);
    }

    /**
     * @description       : Setting up the Mock Response of SUCCESS status for NLSClosedParticipantIdBatch
     * @author            : Sk Minsar
     * @last modified on  : 03-25-2025
     * @last modified by  : Sk Minsar
    **/
    public class NLSGetParticipantsIdHttpCalloutMock implements HttpCalloutMock {
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
                StaticResource staticResourceObj = getStaticResource('NLSGetParticipantsId200SuccessMockResponse');
                Blob resourceContent = staticResourceObj.Body;
                String textData = resourceContent.toString();
                response.setBody(textData);
            }
            return response;
        }
    }

    /**
     * @description       : Setting up the Mock Response of SUCCESS status for NLSClosedParticipantIdBatch
     * @author            : Sk Minsar
     * @last modified on  : 03-25-2025
     * @last modified by  : Sk Minsar
    **/
    public class NLSGetParticipantsIdHttpCalloutNullResponseMock implements HttpCalloutMock {
        // Implement this interface method
        /**
        * @description : returns the Mock Response for null
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
     * @description       : Setting up the Mock Response of Failure status, Bad Request for NLSClosedParticipantIdBatch
     * @author            : Sk Minsar
     * @last modified on  : 03-25-2025
     * @last modified by  : Sk Minsar
    **/
    public class NLSGetParticipantsIdBadRequestResponseMock implements HttpCalloutMock {
        
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
     * @description       : Setting up the Mock Response of Failure status, Access Denied for NLSClosedParticipantIdBatch
     * @author            : Sk Minsar
     * @last modified on  : 03-25-2025
     * @last modified by  : Sk Minsar
    **/
    public class NLSGetParticipantsIdAccessDeniedResponseMock implements HttpCalloutMock {
        
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
     * @description       : Setting up the Mock Response of Failure status, Loan Not Found for NLSClosedParticipantIdBatch
     * @author            : Sk Minsar
     * @last modified on  : 03-25-2025
     * @last modified by  : Sk Minsar
    **/
    public class NLSGetParticipantsIdNoLoanFoundResponseMock implements HttpCalloutMock {
        
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
     * @description       : Setting up the Mock Response of Failure status, Internal Server Error for NLSClosedParticipantIdBatch
     * @author            : Sk Minsar
     * @last modified on  : 03-25-2025
     * @last modified by  : Sk Minsar
    **/
    public class NLSGetParticipantsIdServerErrorResponseMock implements HttpCalloutMock {
        
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
    * @description - This method queries and returns all the necessary data
    * @author Sk Minsar | 03-05-2025 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getDataMap(){
        List<genesis__Applications__c> applicationList = [SELECT Id, Participant_Id__c, Loan_Id__c, genesis__Loan_Number__c FROM genesis__Applications__c WHERE genesis__Status__c =: ConstantValues.ACTIVE ORDER BY genesis__Loan_Number__c LIMIT: RECORDS_COUNT];
        List<Account> dealerAccountList = [SELECT Id, Name, Coop_Type__c FROM Account WHERE RecordType.Name = :ConstantValues.DEALER LIMIT 1];

        return new Map<String, Object>{
            KEY_APPLICATION_LIST => applicationList,
            KEY_DEALER_ACCOUNT_LIST => dealerAccountList
        };
    }

    /**
    * @description : This method returns static resource record
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
    * @description - Return pricing details list for list of application
    * @author Sk Minsar | 03-20-2025 
    * @param applicationList 
    * @return List<genesis__Application_Pricing_Detail__c> 
    **/
    private static List<genesis__Application_Pricing_Detail__c> getPricingList(List<genesis__Applications__c> applicationList){
        return [SELECT ID, Participant_Id__c, genesis__Application__r.Participant_Id__c, Loan_Id__c FROM genesis__Application_Pricing_Detail__c WHERE genesis__application__c In :applicationList];
    }

    /**
    * @description - Get integration api configuration for get participants id api config
    * @author Sk Minsar | 03-28-2025 
    * @return List<intframework__Integration_API_Configuration__c> 
    **/
    private static List<intframework__Integration_API_Configuration__c> getIntegrationAPIConfig(){
        return [SELECT id, intframework__Integration_Family__c FROM intframework__Integration_API_Configuration__c WHERE intframework__Integration_Configuration__r.Name = :GET_PARTICIPANTS_ID_API_CONFIG];
    }

    /**
    * @description - Test with Parent closed loan
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testParentClosedLoan(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.TRUE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].genesis__Application__r.Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with chhild closed loan
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testChildClosedLoan(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.FALSE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with multiple parent closed loan
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testMultipleParentClosedLoan(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        for(genesis__Applications__c application: applicationList){
            application.genesis__Status__c = ConstantValues.CLOSED;
        }
        Database.update(applicationList, true); 
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.TRUE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(applicationList);
            for(genesis__Application_Pricing_Detail__c pricingObj: pricingList){
                System.assertEquals(PARTICIPANT_ID, pricingObj.genesis__Application__r.Participant_Id__c, ASSERTION_FAILED);
            }
        }
    }

    /**
    * @description - Test with multiple parent closed loan
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testMultipleChildClosedLoan(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        for(genesis__Applications__c application: applicationList){
            application.genesis__Status__c = ConstantValues.CLOSED;
        } 
        Database.update(applicationList, true); 

        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.FALSE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(applicationList);
            for(genesis__Application_Pricing_Detail__c pricingObj: pricingList){
                System.assertEquals(PARTICIPANT_ID, pricingObj.Participant_Id__c, ASSERTION_FAILED);
            }
        }
    }

    /**
    * @description - Test with Parent Active loan
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testParentActiveLoan(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.TRUE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(null, pricingList[0].genesis__Application__r.Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Parent Active loan
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testChildActiveLoan(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.FALSE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(null, pricingList[0].Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Parent closed loan with null loan Id
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testParentClosedNullLoanId(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        applicationList[0].Loan_Id__c = null;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.TRUE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(null, pricingList[0].genesis__Application__r.Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with child closed loan with null loan Id
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testChildClosedNullLoanId(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        applicationList[0].Loan_Id__c = null;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.FALSE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Parent closed loan with not null participants Id
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testParentClosedNotNullParticipantsId(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        applicationList[0].Participant_Id__c = PARTICIPANT_ID;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.TRUE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].genesis__Application__r.Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with child closed loan with not null participants Id
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testChildClosedNotNullParticipantsId(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        applicationList[0].Participant_Id__c = PARTICIPANT_ID;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.FALSE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Parent closed loan with null response
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testParentClosedLoanNullResponse(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutNullResponseMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.TRUE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(null, pricingList[0].genesis__Application__r.Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Parent closed loan with bad request response
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testParentClosedLoanBadRequest(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdBadRequestResponseMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.TRUE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(null, pricingList[0].genesis__Application__r.Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Parent closed loan with access denied response
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testParentClosedLoanAccessDenied(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdAccessDeniedResponseMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.TRUE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(null, pricingList[0].genesis__Application__r.Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Parent closed loan with no loan found response
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testParentClosedLoanNoLoanFound(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdNoLoanFoundResponseMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.TRUE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(null, pricingList[0].genesis__Application__r.Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Parent closed loan with server error response
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testParentClosedLoanServerError(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdServerErrorResponseMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.TRUE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(null, pricingList[0].genesis__Application__r.Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Child closed loan with null response
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testChildClosedLoanNullResponse(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutNullResponseMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.FALSE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(null, pricingList[0].Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Child closed loan with bad request response
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testChildClosedLoanBadRequest(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdBadRequestResponseMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.FALSE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(null, pricingList[0].Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Child closed loan with access denied response
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testChildClosedLoanAccessDenied(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdAccessDeniedResponseMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.FALSE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(null, pricingList[0].Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Child closed loan with no loan found response
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testChildClosedLoanNoLoanFound(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdNoLoanFoundResponseMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.FALSE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(null, pricingList[0].Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Child closed loan with server error response
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testChildClosedLoanServerError(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdServerErrorResponseMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.FALSE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(null, pricingList[0].Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Parent closed loan with Executive Profile
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testParentClosedLoanWithExcutiveProfile(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_EXECUTIVE)[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.TRUE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].genesis__Application__r.Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Parent closed loan with Loan Accounting profile
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testParentClosedLoanWithLoanAccountingProfile(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_LOAN_ACCOUNTING)[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.TRUE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].genesis__Application__r.Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Parent closed loan with Field Staff profile
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testParentClosedLoanWithFieldStaffProfile(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_FIELD_STAFF)[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.TRUE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].genesis__Application__r.Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Parent closed loan with CFA user profile
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testParentClosedLoanWithCFAUserProfile(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getUserByProfileName(PROFILE_CFA_USER)[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.TRUE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].genesis__Application__r.Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Parent closed loan with CFA Admin profile
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testParentClosedLoanWithCFAAdminUserProfile(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_CFA_ADMIN)[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.TRUE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].genesis__Application__r.Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Parent closed loan with Credit profile
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testParentClosedLoanWithCreditProfile(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_CREDIT)[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.TRUE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].genesis__Application__r.Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Parent closed loan with Master Credit profile
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testParentClosedLoanWithMasterCreditProfile(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_MASTER_CREDIT)[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.TRUE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].genesis__Application__r.Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Child closed loan with Executive Profile
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testChildClosedLoanWithExcutiveProfile(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_EXECUTIVE)[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.FALSE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Child closed loan with Loan Accounting profile
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testChildClosedLoanWithLoanAccountingProfile(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_LOAN_ACCOUNTING)[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.FALSE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Child closed loan with Field Staff profile
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testChildClosedLoanWithFieldStaffProfile(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_FIELD_STAFF)[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.FALSE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Child closed loan with CFA user profile
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testChildClosedLoanWithCFAUserProfile(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getUserByProfileName(PROFILE_CFA_USER)[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.FALSE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Child closed loan with CFA Admin profile
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testChildClosedLoanWithCFAAdminUserProfile(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_CFA_ADMIN)[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.FALSE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Child closed loan with Credit profile
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testChildClosedLoanWithCreditProfile(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_CREDIT)[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.FALSE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].Participant_Id__c, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Child closed loan with Master Credit profile
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testChildClosedLoanWithMasterCreditProfile(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_MASTER_CREDIT)[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.FALSE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(PARTICIPANT_ID, pricingList[0].Participant_Id__c, ASSERTION_FAILED);
        }
    }


    /**
    * @description - Test with Parent closed loan for Null Integration Family
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testParentClosedLoanForNullIntegrationFamily(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[0], true); 
        List<intframework__Integration_API_Configuration__c> integrationAPIConfig = getIntegrationAPIConfig();
        integrationAPIConfig[0].intframework__Integration_Family__c = null;
        Database.update(integrationAPIConfig[0], true);
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.TRUE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[0]});
            System.assertEquals(null, pricingList[0].genesis__Application__r.Participant_Id__c, ASSERTION_FAILED);
        }
    }
    
    /**
    * @description - Test with child closed loan for multi tranche loan
    * @author Sk Minsar | 03-18-2025 
    **/
    @isTest
    public static void testMultiTrancheClosedLoan(){
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[1].genesis__Status__c = ConstantValues.CLOSED;
        Database.update(applicationList[1], true); 
        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsIdHttpCalloutMock());
                NLSClosedParticipantIdBatch getChildLoanbatch = new NLSClosedParticipantIdBatch(ConstantValues.FALSE_VALUE);
                Database.executeBatch(getChildLoanbatch , BATCH_SIZE);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = getPricingList(new List<genesis__Applications__c>{applicationList[1]});
            for(genesis__Application_Pricing_Detail__c pricingObj: pricingList) {
                System.assertEquals(PARTICIPANT_ID, pricingList[0].Participant_Id__c, ASSERTION_FAILED);
            }
        }
    }

}