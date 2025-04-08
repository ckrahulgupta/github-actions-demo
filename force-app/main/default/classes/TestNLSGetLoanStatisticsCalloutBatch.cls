/**
 * @description       : 
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 01-03-2025
 * @last modified by  : Ayush Kumar Singh
**/

@IsTest
global without sharing class TestNLSGetLoanStatisticsCalloutBatch{


    /**
    * @description : This method is to prepare data for the test class
    * @author Rahul Gupta | 12-10-2022
    **/
    @TestSetup
    static void makeData(){
    
            // Creating Business Information
            genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
    
            //creating business info for borrower and principal
            genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
            genesis__Business_Information__c principalBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
    
            Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj,
                                                                        borrowerBusinessInfoObj,
                                                                        principalBusinessInfoObj
                                                                        }, true);


            User adminUserObj = ApplicationOriginationTestHelper.createAdminUser('testdealerprodadportfoliomgr@yopmail.com');
            Database.Insert(adminUserObj, true);

            // Creating Account for Dealer
            Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
            dealerAccountObj.Production_Ag_loan_officer__c = adminUserObj.id;
            Database.insert(dealerAccountObj, true);

            genesis__Rate_Card_Setup_Header__c currRateCardHeader = ApplicationOriginationTestHelper.createCurrYearRateCardHeader(dealerAccountObj);
            Database.insert(currRateCardHeader,true);

            genesis__Rate_Card_Setup_Detail__c rateCardDetailObj = ApplicationOriginationTestHelper.createNewRateCardSetupDetail(currRateCardHeader);
            Database.insert(rateCardDetailObj, true);
    
            // Creating Legal Entity for Borrower

            clcommon__Legal_Entity__c entityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
            clcommon__Legal_Entity__c corpLegalEntityObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
            clcommon__Legal_Entity__c dbaLegalEntityObj  = ApplicationOriginationTestHelper.createDBALegalEntity();
            Database.insert(new List<clcommon__Legal_Entity__c>{entityObj, corpLegalEntityObj, dbaLegalEntityObj}, true);
    
            // Creating Account for Certified Lender
            Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
    
            // Creating Account for Borrower
            Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
            borrowerAccountObj.BillingStreet = 'Action area 1';
            borrowerAccountObj.BillingPostalCode = '24234';
            borrowerAccountObj.CIF_Number__c = '349872';

            // Creating CoApplicant Account
            Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(entityObj,principalBusinessInfoObj.Id);
            coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
    
            //Creating Co-Applicant contact
           
            Database.insert(new List<Account>{
                clAccountObj,
                borrowerAccountObj,
                coBorrowerAccountObj
            }, true);
    
            // Creating Contact for Certified Lender
            Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
    
            // Creating Contact for Borrower
            Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
            borrowerContactObj.Confirm_SSN__c = 'GHFB6766';

            Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.Id);
    
            Database.insert(new List<Contact>{
                clContactObj,
                borrowerContactObj,
                coBorrowerContactObj
            },true);
    
            User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
            User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
            Database.insert(new List<User>{
                clUserObj,
                borrowerUserObj
            },true);
    
            // Creating CL Purpose of Application
            clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
            Database.insert(clPurposeObj, true);
    
            // Creating Cl Product of Application
            clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
            Database.insert(clProductObj, true);
    
            // Creating map for Application
            Map<String,Id> paramForApplicationMap = new Map<String,Id>{
                'dealerAccountId' => dealerAccountObj.Id,
                'clProductId' => clProductObj.Id,
                'clPurposeId' => clPurposeObj.Id,
                'borrowerAccountId' => borrowerAccountObj.Id,
                'borrowerContactId' => borrowerContactObj.Id,
                'certifiedLender' =>  clAccountObj.Id
            };
    
            // Creating Application
            genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
            applicationObj.Agreement_Sign__c = true;
            applicationObj.my_program__c = currRateCardHeader.id;
            Database.insert(applicationObj, true);

            genesis__Application_Pricing_Detail__c createAppPricingForA = ApplicationOriginationTestHelper.createEnabledPricingDetail(applicationObj, rateCardDetailObj.id);
            genesis__Application_Pricing_Detail__c createAppPricingForB = ApplicationOriginationTestHelper.createEnabledPricingDetail(applicationObj, rateCardDetailObj.id);
            createAppPricingForB.Loan_Id__c = '139002';
            genesis__Application_Pricing_Detail__c createAppPricingForC = ApplicationOriginationTestHelper.createEnabledPricingDetail(applicationObj, rateCardDetailObj.id);
            createAppPricingForC.Loan_Id__c = null;
            Database.insert(new List<genesis__Application_Pricing_Detail__c>{createAppPricingForA,
                                                                                createAppPricingForB,
                                                                                createAppPricingForC
                                                                            },true);
    
            // Creating Reciprocal Role 
            clcommon__Reciprocal_Role__c roleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
            Database.insert(roleObj, true);
    
            // Creating Relationship between Dealer and Certified Lender
            clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
            Database.insert(clDealerRelationshipObj, true);
    
            // Creating Certified Lender Party Type
            clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
    
            // Create Borrower Party Type
            clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
            clcommon__Party_Type__c coBorrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
            Database.insert(new List<clcommon__Party_Type__c>{
                clPartyTypeObj,
                borrowerPartyTypeObj,
                coBorrowerPartyTypeObj
            }, true);

            Dealer_Applicant_Relationship__c dealerBorrRel = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.id);
            Dealer_Applicant_Relationship__c dealerPrincipalRel = ApplicationOriginationTestHelper.createDealerApplicantRelationship(coBorrowerContactObj,dealerAccountObj.id);
            Database.insert(new List<Dealer_Applicant_Relationship__c>{
                dealerBorrRel,
                dealerPrincipalRel
            },true);
    
            // Creating Certified Lender Party
            Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
                'accountId' => clAccountObj.Id,
                'contactId' => clContactObj.Id,
                'partyTypeId' => clPartyTypeObj.Id,
                'applicationId' => applicationObj.Id
            };
    
            List<clcommon__Party__c> partyObjList = new List<clcommon__Party__c>();
    
            partyObjList.add(ApplicationOriginationTestHelper.createParty(paramForCLPartyMap));
    
            Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
                'accountId' => borrowerAccountObj.Id,
                'contactId' => borrowerContactObj.Id,
                'partyTypeId' => borrowerPartyTypeObj.Id,
                'applicationId' => applicationObj.Id
            };

            clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createApplicantParty(paramForBorrowerPartyMap,borrowerAccountObj);
            borrowerPartyObj.clcommon__Party_Types__c = ConstantValues.BORROWER_PARTY;
            borrowerPartyObj.Dealer_Applicant_Relationship__c = dealerBorrRel.id;
            partyObjList.add(borrowerPartyObj);
    
            ApplicationOriginationSetupTestHelper.createSaSaAdminTestData(dealerBusinessInfoObj,dealerAccountObj);
            ApplicationOriginationSetupTestHelper.createAdditionalTestData(applicationObj,dealerAccountObj);
    
            ApplicationOriginationSetupTestHelper.createAdditionalInfoParty(applicationObj, entityObj,borrowerBusinessInfoObj);

    
            Map<String,Id> coBorrowerPartyMap = new Map<String,Id>{
                'accountId' => coBorrowerAccountObj.Id,
                'contactId' => coBorrowerContactObj.Id,
                'partyTypeId' => borrowerPartyTypeObj.Id,
                'applicationId' => applicationObj.Id
            };
            clcommon__Party__c coBorrowerPartyObj = ApplicationOriginationTestHelper.createApplicantParty(coBorrowerPartyMap,coBorrowerAccountObj);
            coBorrowerPartyObj.clcommon__Party_Types__c = 'PRINCIPAL';
            partyObjList.add(coBorrowerPartyObj);
            Database.insert(partyObjList,true);
        
            createIntegrationFramework();

    }

    /**
     * @description Creating Integration Framework.
     */
    private static void createIntegrationFramework(){

         // setup integration family
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily('NLS Integration');

        // setup integration API type
        intframework__Integration_API_Type__c apiType = 
                        IntegrationTestInitHelper.getIntegrationAPIType(
                                family.Id, 
                                'Loan Statistics API Type'
                            );

        // setup integration provider
        intframework__Integration_Provider__c provider = 
                        IntegrationTestInitHelper.getIntegrationProvider(
                                family.Id, 
                                'Loan Statistics'
                            );

        // setup integration configration
        intframework__Integration_Configuration__c config = 
                        IntegrationTestInitHelper.getIntegrationConfiguration(
                                provider.Id,
                                'Loan Statistics Integration Configuration',
                                'NLS'
                            );

        intframework__Integration_API_Configuration__c apiConfig = 
                        IntegrationTestInitHelper.getIntegrationAPIConfiguration(
                                family.Id,
                                apiType.Id,
                                provider.Id,
                                config.Id,
                                false,
                                'NLSGetLoanStatisticsAdapter',
                                'GET',
                                'NLS',
                                '/loans/loanId/statistics',
                                '{"thirdPartySystem":{"name":"Get Loan","filters":[{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"loans","fields":[{"externalField":"childId","fieldAPI":"Id"},{"externalField":"parentId","fieldAPI":"genesis__Application__c"},{"externalField":"participantId","fieldAPI":"Participant_Id__c"},{"externalField":"loanId","fieldAPI":"Loan_Id__c"}],"whereClause":"Id IN :loanIdList"}]}}',
                                'application/json',
                                1
                            );

        System.assertEquals(apiConfig.intframework__Adapter_Class_Name__c,'NLSGetLoanStatisticsAdapter','Integration api config not working');
    }


    /**
     * @description This class implements a interface method which return mock response of NLS
     */
    public class HttpCalloutSuccessMock implements HttpCalloutMock {
        // Implement this interface method
        /**
         * @description This method return mock response of NLS to get Loan Statistic 
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
                response.setBody('{"status":{"code":200,"message":"string"},"payload":{"totalCount":0,"count":0,"data":[{"Row_Id":0,"Year_Number":2022,"Master_Record":0,"Principal_Advanced":0,"Month_Number":202206,"Principal_Advanced_Num":0,"Principal_Advanced_Average":0,"Principal_Paid":0,"Interest_Earned":120,"Interest_Paid":100.00,"Interest_Waived":0,"Late_Charges_Earned":0,"Late_Charges_Paid":0,"Def_Interest_Earned":0,"Late_Charges_Waived":0,"Def_Interest_Paid":0,"Def_Interest_Waived":0,"Fees_Earned":0,"Fees_Paid":0,"Fees_Waived":0,"Escrow_Interest_Earned":0,"Escrow_Interest_Paid":0,"Loan_Balance_Total":0,"Loan_Balance_Days":0,"Loan_Balance_Average":0,"Loan_Balance_High":0,"Loan_Balance_Low":0,"Days_Late_10":0,"Days_Late_30":0,"Days_Late_60":0,"Days_Late_90":0,"Days_Late_Over":0,"Nsf_Payments":0,"User_Defined_1":0,"User_Defined_2":0,"User_Defined_3":0,"User_Defined_4":0,"User_Defined_5":0,"User_Defined_6":0,"User_Defined_7":0,"User_Defined_8":0,"User_Defined_9":0,"User_Defined_10":0,"User_Defined_11":0,"User_Defined_12":0,"User_Defined_13":0,"User_Defined_14":0,"User_Defined_15":0,"User_Defined_16":0,"User_Defined_17":0,"User_Defined_18":0,"User_Defined_19":0,"User_Defined_20":0,"User_Defined_21":0,"User_Defined_22":0,"User_Defined_23":0,"User_Defined_24":0,"User_Defined_25":0,"Kept_Promise_Counter":0,"Broken_Promise_Counter":0,"Made_Promise_Counter":0,"Actuarial_Interest_Earned":0,"Servicing_Fee_Earned":0,"Servicing_Fee_Paid":0,"Acctrefno":0,"Deferred_Payments_Counter":0}]}}');
            }
            return response;
        }
    }

    /**
     * @description This class implements a interface method which return mock response of NLS
     */
    public class HttpCalloutFailureStatusCodeMock implements HttpCalloutMock {
        /**
        * @description This method is used to return the mock response of NLS for the scenario where the status code will be failure with the token being generated 
        * @author Rakesh Saraf | 09-09-2024 
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
                response.setStatusCode(400);
                response.setBody('{"status":{"code":400,"message":"string"}');
            }
            // String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
            // response.setBody(token);
            return response;
        }
    }

    /**
     * @description This class implements a interface method which return the mock response for unauthorized scenario or Failure scenario
     */
    public class HttpCalloutFailureMock implements HttpCalloutMock {
        // Implement this interface method

        /**
        * @description This method is for the unauthorized scenario or Failure scenario
        * @author Rahul Gupta | 12-10-2022
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(00);
            response.setStatus('SUCCESS');
            response.setHeader('Content-Type', 'application/json');
            if(request.getEndpoint().contains('token')){
                String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
            }
            else{
                response.setBody('{"status":{"code":400,"message":"string"}}');
            }
            return response;
        }
    }

    /**
     * @description This class implements a interface method for the scenario where the month number length is not equal to 6.
     */
    public class HttpCalloutIncorrectMonthMock implements HttpCalloutMock {
        // Implement this interface method
        /**
         * @description This method return mock response of NLS to get Loan Statistic with the month number being of 5 digit instead of 6
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
                response.setBody('{"status":{"code":200,"message":"string"},"payload":{"totalCount":0,"count":0,"data":[{"Row_Id":0,"Year_Number":2022,"Master_Record":0,"Principal_Advanced":0,"Month_Number":20226,"Principal_Advanced_Num":0,"Principal_Advanced_Average":0,"Principal_Paid":0,"Interest_Earned":120,"Interest_Paid":100.00,"Interest_Waived":0,"Late_Charges_Earned":0,"Late_Charges_Paid":0,"Def_Interest_Earned":0,"Late_Charges_Waived":0,"Def_Interest_Paid":0,"Def_Interest_Waived":0,"Fees_Earned":0,"Fees_Paid":0,"Fees_Waived":0,"Escrow_Interest_Earned":0,"Escrow_Interest_Paid":0,"Loan_Balance_Total":0,"Loan_Balance_Days":0,"Loan_Balance_Average":0,"Loan_Balance_High":0,"Loan_Balance_Low":0,"Days_Late_10":0,"Days_Late_30":0,"Days_Late_60":0,"Days_Late_90":0,"Days_Late_Over":0,"Nsf_Payments":0,"User_Defined_1":0,"User_Defined_2":0,"User_Defined_3":0,"User_Defined_4":0,"User_Defined_5":0,"User_Defined_6":0,"User_Defined_7":0,"User_Defined_8":0,"User_Defined_9":0,"User_Defined_10":0,"User_Defined_11":0,"User_Defined_12":0,"User_Defined_13":0,"User_Defined_14":0,"User_Defined_15":0,"User_Defined_16":0,"User_Defined_17":0,"User_Defined_18":0,"User_Defined_19":0,"User_Defined_20":0,"User_Defined_21":0,"User_Defined_22":0,"User_Defined_23":0,"User_Defined_24":0,"User_Defined_25":0,"Kept_Promise_Counter":0,"Broken_Promise_Counter":0,"Made_Promise_Counter":0,"Actuarial_Interest_Earned":0,"Servicing_Fee_Earned":0,"Servicing_Fee_Paid":0,"Acctrefno":0,"Deferred_Payments_Counter":0}]}}');
            }
            return response;
        }
    }

    /**
     * @description This class implements a interface method for the scenario where no payload is sent with the response to generate an exception.
     */
    public class HttpCalloutNoPayloadMock implements HttpCalloutMock {
        // Implement this interface method
        /**
         * @description This method return mock response of NLS with no payload to send with the response to generate an exception.
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
                response.setBody('{"status":{"code":200,"message":"string"}');
            }
            return response;
        }
    }
    
    /**
    * @description Testing for default Success
    * @author Rahul Gupta | 09-24-2024 
    **/
    @IsTest
    public static void testDefaultSuccess() {

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];


        Test.startTest();
        System.runAS(objAdmin){
            NLSGetLoanStatisticsCalloutBatch obj = new NLSGetLoanStatisticsCalloutBatch();
            Id batchProcessId=Database.executeBatch(obj, 50);
            System.assert(batchProcessId!=null,'Batch process not running');
        }
        Test.stopTest();
    }

    /**
    * @description Testing for default failure
    * @author Rahul Gupta | 09-24-2024 
    **/
    @IsTest
    public static void testDefaultFailure() {

        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new HttpCalloutFailureMock());

        Test.startTest();
        System.runAS(objAdmin){
            NLSGetLoanStatisticsCalloutBatch obj = new NLSGetLoanStatisticsCalloutBatch();
            Id batchProcessId=Database.executeBatch(obj, 50);
            System.assert(batchProcessId!=null,'Batch process not running');
        }
        Test.stopTest();
    }

    /**
    * @description Testing for the status code to be 200 so that the batch process does not run
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    public static void testFailureStatusCode() {

        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new HttpCalloutFailureStatusCodeMock());

        Test.startTest();
        System.runAS(objAdmin){
            NLSGetLoanStatisticsCalloutBatch obj = new NLSGetLoanStatisticsCalloutBatch();
            Id batchProcessId=Database.executeBatch(obj, 50);
            System.assert(batchProcessId!=null,'Batch process not running');
        }
        Test.stopTest();
    }

    /**
    * @description testing without payload So, it throws an exception
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    public static void testNoPayload() {

        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Test.setMock(HttpCalloutMock.class, new HttpCalloutNoPayloadMock());

        Test.startTest();
        System.runAS(objAdmin){
            NLSGetLoanStatisticsCalloutBatch obj = new NLSGetLoanStatisticsCalloutBatch();
            Id batchProcessId=Database.executeBatch(obj, 50);
            System.assert(batchProcessId!=null,'Batch process not running');
        }
        Test.stopTest();
    }

    /**
    * @description Testing for default Success with custom data
    * @author Rahul Gupta | 09-24-2024 
    **/
    @IsTest
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
        System.runAS(objAdmin){
            NLSGetLoanStatisticsCalloutBatch obj = new NLSGetLoanStatisticsCalloutBatch(idList, genesis__Application_Pricing_Detail__c.class);
            Id batchProcessId=Database.executeBatch(obj, 50);
            System.assert(batchProcessId!=null,'Batch process not running');
        }
        Test.stopTest();
    }

    /**
    * @description Testing for default Failure for custom data
    * @author Rahul Gupta | 09-24-2024 
    **/
    @IsTest
    public static void testCustomDataFailure() {

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

        

        Test.setMock(HttpCalloutMock.class, new HttpCalloutFailureMock());

        Test.startTest();
        System.runAS(objAdmin){
            NLSGetLoanStatisticsCalloutBatch obj = new NLSGetLoanStatisticsCalloutBatch(idList, genesis__Application_Pricing_Detail__c.class);
            Id batchProcessId=Database.executeBatch(obj, 50);
            System.assert(batchProcessId!=null,'Batch process not running');
        }
        Test.stopTest();
    }

    /**
    * @description testing for currLoanId Null so that it throws a custom exception
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testWithcurrLoanIdNull(){

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
        System.runAS(objAdmin){
            NLSGetLoanStatisticsCalloutBatch obj = new NLSGetLoanStatisticsCalloutBatch(idList, genesis__Applications__c.class);
            Id batchProcessId=Database.executeBatch(obj, 50);
            // Database.executeBatch(obj, 50);
            System.assert(batchProcessId!=null,'Batch process not running');
        }
        Test.stopTest();
    }

    /**
    * @description test with the month number as a 5 digit string instead of a 6 digit string to throw custom exception
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testWithIncorrectMonthNumber(){

        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];        

        Test.setMock(HttpCalloutMock.class, new HttpCalloutIncorrectMonthMock());

        Test.startTest();
        System.runAS(objAdmin){
            NLSGetLoanStatisticsCalloutBatch obj = new NLSGetLoanStatisticsCalloutBatch();
            Id batchProcessId=Database.executeBatch(obj, 50);
            System.assert(batchProcessId!=null,'Batch process not running');
        }
        Test.stopTest();
    }

    /**
    * @description test with missing config
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @IsTest
    public static void testMissingConfigError() {

        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Database.delete([SELECT Id FROM intframework__Integration_Configuration__c WHERE Name = 'Loan Statistics Integration Configuration'], true);

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
        System.runAS(objAdmin){
            NLSGetLoanStatisticsCalloutBatch obj = new NLSGetLoanStatisticsCalloutBatch(idList,genesis__Application_Pricing_Detail__c.class);
            Id batchProcessId=Database.executeBatch(obj, 50);
            System.assert(batchProcessId!=null,'Batch process not running');
        }
        Test.stopTest();
    }
    

}