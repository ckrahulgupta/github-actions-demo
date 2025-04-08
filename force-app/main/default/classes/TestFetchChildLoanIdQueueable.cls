/**
 * @description       : Test class for FetchChildLoanIdQueueable class
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-25-2025
 * @last modified by  : Ayan Khanra
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   02-06-2022   Subham Nandi   Initial Version
**/
@isTest
public with sharing class TestFetchChildLoanIdQueueable {
    
    /**
    * @description test setup date
    * @author Tuhin Bhunia | 05-08-2024 
    **/
    @TestSetup
    static void makeData(){

        createIntFrameWorkData();

        // Creating Test Data applcation, account contact.

        List<clcommon__Party_Type__c> partyTypeList;

        // create legal entity
        clcommon__Legal_Entity__c individualSolePropEntity = LoanServicingTestHelper.createLegalEntity(PortalConstants.SOLE_PROP_ENTITY);
        Database.insert(individualSolePropEntity, true);

        clcommon__CL_Product__c clProductObj = LoanServicingTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating CL Purpose for Application
        clcommon__CL_Purpose__c clPurposeObj = LoanServicingTestHelper.createCLPurposeForApplication();
        Database.Insert(clPurposeObj, true);

        genesis__Credit_Rating_Matrix__c rating = LoanServicingTestHelper.getCreditRatingMatrix(PortalConstants.TIER_2_CREDIT);
        Database.insert(rating, true);

        // Creating Party Types
        clcommon__Party_Type__c borrowerPartyTypeObj = LoanServicingTestHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);

        clcommon__Party_Type__c dealerPartyTypeObj = LoanServicingTestHelper.createPartyType(PortalConstants.DEALER_PARTY_NAME);

        clcommon__Party_Type__c clPartyTypeObj = LoanServicingTestHelper.createPartyType(PortalConstants.CERTIFIED_LENDER);

        clcommon__Party_Type__c principalPartyTypeObj = LoanServicingTestHelper.createPartyType(PortalConstants.PRINCIPAL_PARTY_NAME);

        partyTypeList = new List<clcommon__Party_Type__c>{
            borrowerPartyTypeObj,
            dealerPartyTypeObj,
            clPartyTypeObj,
            principalPartyTypeObj
        };
        Database.Insert(partyTypeList, true);

        clcommon__Reciprocal_Role__c clRole = LoanServicingTestHelper.createReciprocalRole(PortalConstants.CERTIFIED_LENDER);
        Database.insert(clRole, true);

        User adminUser = LoanServicingTestHelper.createAdminUser('testadminuser45@yopmail.com');
        Database.Insert(adminUser, true);

        // CFA dealer test data
        genesis__Business_Information__c dealerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForDealer();

        genesis__Business_Information__c borrowerBusinessInfo = LoanServicingTestHelper.createBusinessInfoForBorrower();

        genesis__Business_Information__c principalBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForBorrower();

        Database.insert(new List<genesis__Business_Information__c>{
            dealerBusinessInfoObj,
            borrowerBusinessInfo,
            principalBusinessInfoObj
        }, true);

        clcommon__Floating_Rate_Index__c floatingRateIndex = ApplicationOriginationTestHelper.createFloatingRateIndex('CFA_Advantage_Rate',12);
        floatingRateIndex.Base_Rate_Adjuster__c = 5.5;
        floatingRateIndex.Base_Rate_Name__c = '7-FIELD FINANCE';
        Database.insert(floatingRateIndex, true);

        CFA_Partner_Program__c partnerProgram = ApplicationOriginationTestHelper.createPartnerProgram('CFA',floatingRateIndex);
        Database.insert(partnerProgram, true);

        Account dealerAccountObj = LoanServicingTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.Coop_Type__c = 'CFA';
        dealerAccountObj.Name = 'Mark Binge';
        dealerAccountObj.PortfolioManager__c = adminUser.Id;
        dealerAccountObj.Production_Ag_Loan_Officer__c = adminUser.Id;
        dealerAccountObj.CFA_Partner_Program__c = partnerProgram.Id;
        Database.insert(dealerAccountObj, true);

        Account clAccountObj = LoanServicingTestHelper.createCLAccount(null, dealerAccountObj.Id);

        Account saAccountObj = LoanServicingTestHelper.createSalesAgentAccount(null, dealerAccountObj.Id);

        // create borrower account
        Account borrowerAccountObj = LoanServicingTestHelper.createSolePropAccount(individualSolePropEntity, (Id) borrowerBusinessInfo.Id);
        borrowerAccountObj.CIF_Number__c = '332211';
        borrowerAccountObj.Name = 'Green Goblin';

        // create principal account
        Account principalAccountObj = LoanServicingTestHelper.createSolePropAccount(individualSolePropEntity, principalBusinessInfoObj.Id);
        principalAccountObj.Name = 'Rishi Bose';

        Database.insert(new List<Account>{
            clAccountObj,
            saAccountObj,
            borrowerAccountObj,
            principalAccountObj
        }, true);

        // creating contacts
        Contact clContactObj = LoanServicingTestHelper.createCLContact(clAccountObj.Id);

        Contact saContactObj = LoanServicingTestHelper.createCLContact(saAccountObj.Id);
        saContactObj.genesis__SSN__c = '998283722';
        saContactObj.Confirm_SSN__c = '998283722';

        // create borrower contact
        Contact borrowerContactObj = LoanServicingTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        borrowerContactObj.FirstName = 'Green';
        borrowerContactObj.LastName = 'Goblin';

        // create principal contact
        Contact principalContactObj = LoanServicingTestHelper.createBorrowerContact(principalAccountObj.Id);
        principalContactObj.FirstName = 'Rishi';
        principalContactObj.LastName = 'Bose';

        Database.insert(new List<Contact>{
            clContactObj,
            saContactObj,
            borrowerContactObj,
            principalContactObj
        }, true);


        clcommon__Relationship__c dealerClRelationObj = LoanServicingTestHelper.createCLDealerRelationship(clRole,
                                                                dealerAccountObj.Id,
                                                                clAccountObj.Id);

        Database.insert(dealerClRelationObj, true);

        Database.Insert(LoanServicingTestHelper.createTestDataForCFAMyProgram(dealerAccountObj.Id));
        Database.Insert(LoanServicingTestHelper.createSingleChildLoanFlexRate(dealerAccountObj.Id));
        
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = [SELECT Id,
                                                                    genesis__End_Date__c,
                                                                    Crop_Year__c
                                                                FROM genesis__Rate_Card_Setup_Header__c 
                                                                WHERE Name = 'CFA My Program - 110'
                                                                AND Account__c = :dealerAccountObj.Id
                                                            ];  

        genesis__Rate_Card_Setup_Header__c rateCardHeaderObjTwo = [SELECT Id,
                                                                    genesis__End_Date__c,
                                                                    Crop_Year__c
                                                                FROM genesis__Rate_Card_Setup_Header__c 
                                                                WHERE Name = 'Test Flex Rate Program'
                                                                AND Account__c = :dealerAccountObj.Id
                                                            ];  
        
        // Creating Application
        Map<String,Id> applicationDataMap = new Map<String,Id>{
            'dealerAccountId'=> dealerAccountObj.Id,
            'clProductId'=> clProductObj.Id,
            'clPurposeId'=> clPurposeObj.Id,
            'borrowerAccountId'=> borrowerAccountObj.Id,
            'borrowerContactId'=> borrowerContactObj.Id,
            'clAccountId'=> clAccountObj.Id
        };
        genesis__Applications__c applicationObj = LoanServicingTestHelper.createCurrCropYearApplication(applicationDataMap);
        applicationObj.Sales_Agent__c = saAccountObj.Id;
        applicationObj.genesis__Maturity_Date__c = rateCardHeaderObj.genesis__End_Date__c;
        applicationObj.My_Program__c = rateCardHeaderObj.Id;
        applicationObj.genesis__Status__c = PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS;
        applicationObj.Crop_Year__c = rateCardHeaderObj.Crop_Year__c;
        applicationObj.Internal_Reference_Code__c = '834920';
        applicationObj.genesis__Credit_Rating__c = rating.Id;
        applicationObj.Signing_Method__c = PortalConstants.EMAIL_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        applicationObj.genesis__Loan_Number__c = '11223344';
        applicationObj.Loan_Id__c = '';
        Database.Insert(applicationObj, true);

        Map<String, Id> partyDetailsMap = new Map<String, Id>{
            'dealerAccountId' =>  dealerAccountObj.Id,
            'clAccountId' =>  clAccountObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'principalAccountId' => principalAccountObj.Id,
            'clContactId' =>  clContactObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'principalContactId' => principalContactObj.Id,
            'dealerPartyTypeId' =>  dealerPartyTypeObj.Id,
            'clPartyTypeId' =>  clPartyTypeObj.Id,
            'borrowerPartyTypeId' => borrowerPartyTypeObj.Id,
            'principalPartyTypeId' => principalPartyTypeObj.Id,
            'applicationId' =>  applicationObj.Id
        };

        List<clcommon__party__c> partyList = createPartyForApplication(partyDetailsMap);
        Database.Insert(partyList, true);

        genesis__Applications__c applicationObjTwo = LoanServicingTestHelper.createCurrCropYearApplication(applicationDataMap);
        applicationObjTwo.Sales_Agent__c = saAccountObj.Id;
        applicationObjTwo.genesis__Maturity_Date__c = rateCardHeaderObjTwo.genesis__End_Date__c;
        applicationObjTwo.My_Program__c = rateCardHeaderObjTwo.Id;
        applicationObjTwo.genesis__Status__c = PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS;
        applicationObjTwo.Crop_Year__c = rateCardHeaderObjTwo.Crop_Year__c;
        applicationObjTwo.Internal_Reference_Code__c = '834920';
        applicationObjTwo.genesis__Credit_Rating__c = rating.Id;
        applicationObjTwo.Signing_Method__c = PortalConstants.EMAIL_DOCUSIGN;
        applicationObjTwo.Agreement_Sign__c = true;
        applicationObjTwo.genesis__Loan_Number__c = '11223344';
        applicationObjTwo.genesis__Loan_Amount__c = 9905.770001;
        applicationObjTwo.Loan_Id__c = '';
        Database.Insert(applicationObjTwo, true);

        partyDetailsMap.put('applicationId',  applicationObjTwo.Id);

        partyList = createPartyForApplication(partyDetailsMap);
        Database.Insert(partyList, true);

        Database.Insert(LoanServicingTestHelper.createSeedDataForPricingDetail(applicationObj));
        Database.Insert(LoanServicingTestHelper.createSeedDataForPricingDetail(applicationObjTwo));
    }

    /**
    * @description creation of party for application
    * @author Tuhin Bhunia | 05-07-2024 
    * @param partyDetailsMap 
    * @return List<clcommon__party__c> 
    **/
    private static List<clcommon__party__c> createPartyForApplication(Map<String, Id> partyDetailsMap){

        // Creating Dealer Party
        Map<String,Id> paramForDealerPartyMap = new Map<String,Id>{
            'accountId' =>  partyDetailsMap.get('dealerAccountId'),
            'contactId' =>  null,
            'partyTypeId' =>  partyDetailsMap.get('dealerPartyTypeId'),
            'applicationId' =>  partyDetailsMap.get('applicationId')
        };
        clcommon__Party__c dealerPartyObj = ApplicationOriginationTestHelper.createParty(paramForDealerPartyMap);

        // Creating Certified Lender Party
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
            'accountId' =>  partyDetailsMap.get('clAccountId'),
            'contactId' =>  partyDetailsMap.get('clContactId'),
            'partyTypeId' =>  partyDetailsMap.get('clPartyTypeId'),
            'applicationId' =>  partyDetailsMap.get('applicationId')
        };
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(paramForCLPartyMap);

        // Creating Borrower Party
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId' => partyDetailsMap.get('borrowerAccountId'),
            'contactId' => partyDetailsMap.get('borrowerContactId'),
            'partyTypeId' => partyDetailsMap.get('borrowerPartyTypeId'),
            'applicationId' => partyDetailsMap.get('applicationId')
        };
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(paramForBorrowerPartyMap);

        // Creating Principal Party
        Map<String,Id> paramForPrincipalPartyMap = new Map<String,Id>{
            'accountId' => partyDetailsMap.get('principalAccountId'),
            'contactId' => partyDetailsMap.get('principalContactId'),
            'partyTypeId' => partyDetailsMap.get('principalPartyTypeId'),
            'applicationId' => partyDetailsMap.get('applicationId')
        };
        clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createParty(paramForPrincipalPartyMap);

        return new List<clcommon__party__c>{
            dealerPartyObj,
            clPartyObj,
            borrowerPartyObj,
            principalPartyObj
        };
    }

    /**
    * @description Integration frameword creation
    * @author Tuhin Bhunia | 05-07-2024 
    **/
    private static void createIntFrameWorkData(){
        //Make the integration framework
        //Inserting Integration Family
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamilyInst('NLS Integration');
        Database.Insert(family, true);

        //Inserting Integration API Type
        intframework__Integration_API_Type__c getChildLoanIdAPIType = IntegrationTestInitHelper.getIntegrationAPITypeInst(
            family.Id, ConstantValues.INTEGRATION_API_TYPE_GET_CHILD_LOANID);
        Database.Insert(getChildLoanIdAPIType, true);

        //Inserting Integration Provider
        intframework__Integration_Provider__c getChildLoanIdProvider = IntegrationTestInitHelper.getIntegrationProviderInst(
            family.Id, 'Search Loans');
        Database.Insert(getChildLoanIdProvider, true);

        //Inserting Integration Configuration
        intframework__Integration_Configuration__c getChildLoanIdIntegConfig = IntegrationTestInitHelper.getIntegrationConfigurationInst(
            getChildLoanIdProvider.Id, 'NLS Search Loans Integration Configuration','NLS');
        Database.Insert(getChildLoanIdIntegConfig, true);

        //Inserting Integration API Configuration
        Map<String, Object> apiConfigMap = new Map<String, Object>{
            'familyId' => family.Id,
            'apiTypeId' => getChildLoanIdAPIType.Id,
            'providerId' => getChildLoanIdProvider.Id,
            'configId' => getChildLoanIdIntegConfig.Id,
            'longRunningOperation' => false,
            'adapterName' => 'NLSLoanSearchAdapter',
            'method' => 'POST',
            'apiNamedCred' => 'NLS',
            'endpoint' => '/loans/search',
            'requestMappingJSON' => '{"thirdPartySystem": {"name": "Test","filters": [],"dynamicDataParameters": [{"externalField": "loanId"}]}}',
            'contentType' => 'application/xml',
            'priority' => 1
        };

        intframework__Integration_API_Configuration__c getChildLoanIdApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfigurationInst(apiConfigMap);
        Database.Insert(getChildLoanIdApiConfig);
    }

    /**
     * @description This mock for loan id.
     */
    public class NLSFetchGetLoanIDMock implements HttpCalloutMock {
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
                String token = '{"access_token":"944dfe344a845487314d9kio0lpokiu8","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
            }
            else{
                response.setBody('{"status":{"code":200,"message":"Success"},"payload":{"totalCount":1,"count":1,"data":[{"Acctrefno":176614,"Loan_Type":3,"Portfolio_Code_Id":0,"Loan_Number":"11223344-A","Cifno":39379,"Loan_Group_No":4,"Shortname":"PARK AVENUE","Name":"PARK AVENUE","Loan_Class1_No":68,"Loan_Class2_No":0,"Risk_Rating_No":3,"Entity":"LIMITED LIABILITY COMPANY","Branch_Cifno":null,"Status_Code_No":0,"Loan_Officer_No":0,"Collection_Officer_No":0,"Dealer_Cifno":null,"Master_Acctrefno":0,"Pool_Acctrefno":0,"Shadow_Loan_Exists":false,"Curr_Maturity_Date":"2023-12-15T00:00:00","Interest_Accrued_Thru_Date":"2022-05-28T00:00:00","Current_Note_Amount":0.00,"Current_Payoff_Balance":0.0000000000,"Days_Past_Due":0,"Closed_Date":null}]}}');
            }
            return response;
        }
    }
    /**
     * @description Mock Response for status code 1
     */
    public class NLSFetchGetLoanIDStatusMock implements HttpCalloutMock {
        /**
         * @description Implement this interface method.
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
                String token = '{"access_token":"944dfe344a845487314d9kio0lpokiu8","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
            }
            else{
                response.setBody('{"status":{"code":200,"message":"Success"},"payload":{"totalCount":1,"count":1,"data":[{"Acctrefno":176614,"Loan_Type":3,"Portfolio_Code_Id":0,"Loan_Number":"11223344-A","Cifno":39379,"Loan_Group_No":4,"Shortname":"PARK AVENUE","Name":"PARK AVENUE","Loan_Class1_No":68,"Loan_Class2_No":0,"Risk_Rating_No":3,"Entity":"LIMITED LIABILITY COMPANY","Branch_Cifno":null,"Status_Code_No":0,"Loan_Officer_No":0,"Collection_Officer_No":0,"Dealer_Cifno":null,"Master_Acctrefno":0,"Pool_Acctrefno":0,"Shadow_Loan_Exists":false,"Curr_Maturity_Date":"2023-12-15T00:00:00","Interest_Accrued_Thru_Date":"2022-05-28T00:00:00","Current_Note_Amount":0.00,"Current_Payoff_Balance":0.0000000000,"Days_Past_Due":0,"Closed_Date":null}]}}');
            }
            return response;
        }
    }
    /**
     * @description This method sends the admin user id.
     * @return  `User`
     */
    private static User getAdminUser() {
        return [
            SELECT Id 
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ][0];
    }
    
    /**
    * @description : Test for the response as status code 0
    * @author Tuhin Bhunia | 05-07-2024 
    **/
    @isTest
    public static void testGetChildLoanIdForStatusCodeZero(){
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            genesis__Loan_Number__c
                                                        FROM genesis__Applications__c
                                                        WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
                                                        LIMIT 1];

        System.runAs(getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSFetchGetLoanIDMock());
            Test.startTest();
            FetchChildLoanIdQueueable fetchChildLoanCallout = new FetchChildLoanIdQueueable(applicationObj.genesis__Loan_Number__c , applicationObj.Id,false);
            fetchChildLoanCallout.execute(null);
            Test.stopTest();
        }
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = [SELECT Id,
                                                                                    Loan_Id__c
                                                                                FROM genesis__Application_Pricing_Detail__c
                                                                                WHERE genesis__Application__c = :applicationObj.Id];
        System.assertEquals('176614', pricingDetailsList[0].Loan_Id__c, PortalConstants.ASSERTION_FAILED);
    }
    
    /**
    * @description : Test for the response as status code 1
    * @author Tuhin Bhunia | 05-07-2024 
    **/
    @isTest
    public static void testGetChildLoanIdForStatusCodeOne(){
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            genesis__Loan_Number__c 
                                                    FROM genesis__Applications__c
                                                    WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
                                                    LIMIT 1];

        System.runAs(getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSFetchGetLoanIDStatusMock());
            Test.startTest();
            FetchChildLoanIdQueueable fetchChildLoanCallout = new FetchChildLoanIdQueueable(applicationObj.genesis__Loan_Number__c , applicationObj.Id,false);
            fetchChildLoanCallout.execute(null);
            Test.stopTest();
        }
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = [SELECT Id,
                                                                                    Loan_Id__c
                                                                                FROM genesis__Application_Pricing_Detail__c
                                                                                WHERE genesis__Application__c = :applicationObj.Id];
        System.assertEquals('176614', pricingDetailsList[0].Loan_Id__c, PortalConstants.ASSERTION_FAILED);
    }

    /**
    * @description : Test for error in child loan id search
    * @author Tuhin Bhunia | 05-07-2024 
    **/
    @isTest
    public static void testGetChildLoanIdErrorCallout(){
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            genesis__Loan_Number__c
                                                        FROM genesis__Applications__c
                                                        WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
                                                        LIMIT 1];
        System.runAs(getAdminUser()){
            Test.startTest();
            FetchChildLoanIdQueueable fetchChildLoanCallout = new FetchChildLoanIdQueueable(applicationObj.genesis__Loan_Number__c , applicationObj.Id,false);
            fetchChildLoanCallout.execute(null);
            Test.stopTest();
        }
        clcommon__Log__c logObj = [SELECT Id, 
                                            Name 
                                        FROM clcommon__Log__c 
                                        WHERE Name = 'FetchChildLoanIdQueueable'];
        System.assertEquals(true, (logObj != null), PortalConstants.ASSERTION_FAILED);
    }

    /**
    * @description : Test for error in child loan id search adapter
    * @author Tuhin Bhunia | 05-07-2024 
    **/
    @isTest
    public static void testNLSLoanSearchAdapter(){
        Map<String,Object> requestMapping = new Map<String, Object>();
        requestMapping.put(ConstantValues.LOAN_NUMBER,null);
        requestMapping.put('loanId',null);
        requestMapping.put(ConstantValues.LOAN_TYPE, '3');
        requestMapping.put(ConstantValues.PARTY_TYPE, ConstantValues.BORROWER_PARTY);
        requestMapping.put(ConstantValues.STATUS_CODE, '0');
        requestMapping.put(ConstantValues.MASTER_ACCTREFNO, '177624');
        List<Account> objAccountList = [SELECT Id, CIF_Number__c FROM Account WHERE Name = 'Green Goblin' LIMIT 1];
        List<Map<String,Object>> accountMapList = new List<Map<String,Object>>();
        Map<String,Object> accountMap = new Map<String,Object>();
        accountMap.put('ID',String.valueOf(objAccountList[0].Id));
        accountMap.put('CIF',String.valueOf(objAccountList[0].CIF_Number__c));
        accountMapList.add(accountMap);
        requestMapping.put('Account',accountMapList);
        System.runAs(getAdminUser()){
            Test.startTest();
            NLSLoanSearchAdapter callAdapter = new NLSLoanSearchAdapter();
            callAdapter.generateRequestBody(requestMapping);
            Test.stopTest();
        }
        System.assertEquals(clcommon.Constants.SUCCESS, clcommon.Constants.SUCCESS, PortalConstants.ASSERTION_FAILED);
    }

    /**
    * @description : Test for success in child loan id search adapter
    * @author Tuhin Bhunia | 05-07-2024 
    **/
    @isTest
    public static void testNLSLoanSearchAdapterSucces(){
        Map<String,Object> requestMapping = new Map<String, Object>();
        requestMapping.put(ConstantValues.LOAN_NUMBER,null);
        requestMapping.put('loanId',null);
        requestMapping.put(ConstantValues.LOAN_TYPE, '3');
        requestMapping.put(ConstantValues.PARTY_TYPE, 'GROWER');
        requestMapping.put(ConstantValues.STATUS_CODE, '0');
        requestMapping.put(ConstantValues.MASTER_ACCTREFNO, '177624');
        List<Account> objAccountList = [SELECT Id, CIF_Number__c FROM Account WHERE Name = 'Green Goblin' LIMIT 1];
        List<Map<String,Object>> accountMapList = new List<Map<String,Object>>();
        Map<String,Object> accountMap = new Map<String,Object>();
        accountMap.put('ID',String.valueOf(objAccountList[0].Id));
        accountMap.put('CIF',String.valueOf(objAccountList[0].CIF_Number__c));
        accountMapList.add(accountMap);
        requestMapping.put('Account',accountMapList);
        System.runAs(getAdminUser()){
            Test.startTest();
            NLSLoanSearchAdapter callAdapter = new NLSLoanSearchAdapter();
            callAdapter.generateRequestBody(requestMapping);
            Test.stopTest();
        }
        System.assertEquals(clcommon.Constants.SUCCESS, clcommon.Constants.SUCCESS, PortalConstants.ASSERTION_FAILED);

    }

    /**
    * @description : Test for error in child loan id search adapter
    * @author Tuhin Bhunia | 05-07-2024 
    **/
    @isTest
    public static void testNLSLoanSearchAdapterError(){

        Map<String,Object> requestMapping = new Map<String, Object>();
        requestMapping.put(ConstantValues.LOAN_NUMBER,null);
        requestMapping.put('loanId',null);
        requestMapping.put(ConstantValues.LOAN_TYPE, '3');
        requestMapping.put(ConstantValues.PARTY_TYPE, ConstantValues.BORROWER_PARTY);
        requestMapping.put(ConstantValues.STATUS_CODE, '0');
        requestMapping.put(ConstantValues.MASTER_ACCTREFNO, '177624');
        System.runAs(getAdminUser()){
            Test.startTest();
            NLSLoanSearchAdapter callAdapter = new NLSLoanSearchAdapter();
            callAdapter.generateRequestBody(requestMapping);
            Test.stopTest();
        }
        clcommon__Log__c logObj = [SELECT Id, 
                                            Name 
                                        FROM clcommon__Log__c 
                                        WHERE Name = 'NLSLoanSearchAdapter'];
        System.assertEquals(true, (logObj != null), PortalConstants.ASSERTION_FAILED);
    }

    
    /**
    * @description : Test with Evergreen
    * @author Tuhin Bhunia | 05-07-2024 
    **/
    @isTest
    public static void testGetChildLoanIdForEvergreen(){
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            genesis__Loan_Number__c 
                                                        FROM genesis__Applications__c
                                                        WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
                                                        LIMIT 1];
        System.runAs(getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSFetchGetLoanIDMock());
            Test.startTest();
            FetchChildLoanIdQueueable fetchChildLoanCallout = new FetchChildLoanIdQueueable(applicationObj.genesis__Loan_Number__c , applicationObj.Id,false);
            fetchChildLoanCallout.execute(null);
            Test.stopTest();
        }
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = [SELECT Id,
                                                                                    Loan_Id__c
                                                                                FROM genesis__Application_Pricing_Detail__c
                                                                                WHERE genesis__Application__c = :applicationObj.Id];
        System.assertEquals('176614', pricingDetailsList[0].Loan_Id__c, PortalConstants.ASSERTION_FAILED);
    }

    /**
    * @description : Test Single Rate Loan Id fetch success 
    * @author Tuhin Bhunia | 05-07-2024 
    **/
    @isTest
    public static void testGetChildLoanIdForSingleRateLoans(){

        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = [SELECT Id,
                                                                    genesis__End_Date__c,
                                                                    Crop_Year__c
                                                                FROM genesis__Rate_Card_Setup_Header__c 
                                                                WHERE Name = 'Test Flex Rate Program'];

        genesis__Applications__c applicationObj = [SELECT Id,
                                                            Dealer_Name__c,
                                                            genesis__Loan_Number__c 
                                                    FROM genesis__Applications__c
                                                    WHERE My_Program__c = :rateCardHeaderObj.Id
                                                    LIMIT 1];

        applicationObj.Loan_Id__c = '176613';
        Database.Update(applicationObj, true);

        Account dealerAccountObj = [SELECT id, name, Coop_Type__c
                                    FROM Account
                                    WHERE Id = :applicationObj.Dealer_Name__c
                                    ];
        dealerAccountObj.Coop_Type__c = 'CFA';
        Database.Update(dealerAccountObj, true);

        System.runAs(getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSFetchGetLoanIDStatusMock());
            Test.startTest();
            FetchChildLoanIdQueueable fetchChildLoanCallout = new FetchChildLoanIdQueueable(applicationObj.genesis__Loan_Number__c , applicationObj.Id,false);
            fetchChildLoanCallout.execute(null);
            Test.stopTest();
        }
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = [SELECT Id,
                                                                                    Loan_Id__c
                                                                                FROM genesis__Application_Pricing_Detail__c
                                                                                WHERE genesis__Application__c = :applicationObj.Id];
        System.assertEquals('176614', pricingDetailsList[0].Loan_Id__c, PortalConstants.ASSERTION_FAILED);
    }
}