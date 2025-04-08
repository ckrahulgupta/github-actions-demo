/**
 * @description       : Test class for ExternalAdditionalInformationAPI to test request from single authorised user
 * @author            : Kabir Pramanik
 * @group             : 
 * @last modified on  : 01-28-2025
 * @last modified by  : Shristy Kumari
**/
@isTest
private with sharing class ExternalAdditionalInformationAPIAuthTest {
    /**
    * @description : test setup
    * @author Kabir Pramanik | 09-25-2024 
    **/
    @TestSetup
    private static void setup(){
        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);
        // Creating Account for Dealer
        Account dealerAccountObj = ExternalAPITestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.CIF_Number__c = '102555';
        dealerAccountObj.Enable_ERP_Id__c = true;
        dealerAccountObj.Unique_Id__c = 'abc123#@!';
        Database.insert(dealerAccountObj, true);
        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ExternalAPITestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);
        //creating business info for borrower
        genesis__Business_Information__c borrowerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);
        clcommon__CL_Purpose__c clPurposeObj = ExternalAPITestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);
        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ExternalAPITestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);
        List<clcommon__Party__c> addInfoPartyObjList = new List<clcommon__Party__c>();
        Account borrowerAccountObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        borrowerAccountObj.Unique_Id__c = 'TestBorrUniqueId';
        Account buyerAccountObj = ExternalAPITestHelper.createBuyerAccount(entityObj, borrowerBusinessInfoObj.Id);
        buyerAccountObj.Unique_Id__c = 'TestBAUniqueId001';
        Account loAccountObj = ExternalAPITestHelper.createLandOwnerAccount(entityObj,borrowerBusinessInfoObj.Id);
        loAccountObj.Unique_Id__c = 'TestLOUniqueId001';
        Account iaAccountObj = ExternalAPITestHelper.createInsuranceAgentAccount(entityObj,borrowerBusinessInfoObj.Id);
        iaAccountObj.Unique_Id__c = 'TestIAUniqueId001';
        Account spAccountObj = ExternalAPITestHelper.createAccount();
        spAccountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        spAccountObj.genesis__Business_Information__c = borrowerBusinessInfoObj.Id;
        spAccountObj.Unique_Id__c = 'TestSPUniqueId001';
        Account coBorrowerAccObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        coBorrowerAccObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        coBorrowerAccObj.Unique_Id__c = 'TestCoBorrUniqueId001';
        Account clAccountObj = ExternalAPITestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);

        Database.insert(new List<Account>{
            buyerAccountObj,
            loAccountObj,
            iaAccountObj,
            spAccountObj,
            coBorrowerAccObj,
            borrowerAccountObj,
            clAccountObj
        }, true);

        Contact borrowerContactObj = ExternalAPITestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Contact buyerContactObj = ExternalAPITestHelper.createBuyerContact(buyerAccountObj.Id);
        Contact loContactObj = ExternalAPITestHelper.createLandOwnerContact(loAccountObj.Id);
        Contact iaContactObj = ExternalAPITestHelper.createInsuranceAgentContact(iaAccountObj.Id);
        Contact spContactObj = ExternalAPITestHelper.createContact();
        spContactObj.accountId = spAccountObj.Id;
        Contact coBorrowerContactObj = ExternalAPITestHelper.createBorrowerContact(coBorrowerAccObj.Id);
        Contact clContactObj = ExternalAPITestHelper.createCLContact(clAccountObj.Id);

        Database.insert(new List<Contact>{
            buyerContactObj,
            loContactObj,
            iaContactObj,
            spContactObj,
            coBorrowerContactObj,
            borrowerContactObj,
            clContactObj
        }, true);

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
        genesis__Applications__c applicationObj = ExternalAPITestHelper.createCurrCropYearApplication(paramForApplicationMap);
        Database.insert(applicationObj, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ExternalAPITestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ExternalAPITestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);
        clcommon__Collateral_Category__c collateralCategoryObj = ExternalAPITestHelper.createCollateralCategory();
        Database.insert(collateralCategoryObj,true);
        // Creating DealerApplicant relationship
        Dealer_Applicant_Relationship__c borrowerDealerRelObj = ExternalAPITestHelper.createApplicantDealerRelationship(borrowerAccountObj, borrowerContactObj, dealerAccountObj);
        Dealer_Applicant_Relationship__c coBorrowerDealerRelObj = ExternalAPITestHelper.createApplicantDealerRelationship(coBorrowerAccObj, coBorrowerContactObj, dealerAccountObj);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{borrowerDealerRelObj,coBorrowerDealerRelObj},true);

        clcommon__Party_Type__c spPartyTypeObj = ExternalAPITestHelper.createPartyType('SPOUSE');
        clcommon__Party_Type__c loPartyTypeObj = ExternalAPITestHelper.createPartyType('LANDOWNER');
        clcommon__Party_Type__c iaPartyTypeObj = ExternalAPITestHelper.createPartyType('INSURANCE AGENT');
        clcommon__Party_Type__c buPartyTypeObj = ExternalAPITestHelper.createPartyType('BUYER');
        clcommon__Party_Type__c principalPartyTypeObj = ExternalAPITestHelper.createPartyType('PRINCIPAL');
        clcommon__Party_Type__c borrowerPartyTypeObj = ExternalAPITestHelper.createPartyType('BORROWER');

        Database.insert(new List<clcommon__Party_Type__c>{
            spPartyTypeObj,
            loPartyTypeObj,
            iaPartyTypeObj,
            buPartyTypeObj,
            principalPartyTypeObj,
            borrowerPartyTypeObj
        }, true);

        Map<String,Id> paramForSpPartyMap = new Map<String,Id>{
            'accountId' => spAccountObj.Id,
            'contactId' => spContactObj.Id,
            'partyTypeId' => spPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        addInfoPartyObjList.add(ExternalAPITestHelper.createParty(paramForSpPartyMap));

        Map<String,Id> paramForLoPartyMap = new Map<String,Id>{
            'accountId' => loAccountObj.Id,
            'contactId' => loContactObj.Id,
            'partyTypeId' => loPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        addInfoPartyObjList.add(ExternalAPITestHelper.createParty(paramForLoPartyMap));

        Map<String,Id> paramForIAPartyMap = new Map<String,Id>{
            'accountId' => iaAccountObj.Id,
            'contactId' => iaContactObj.Id,
            'partyTypeId' => iaPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        addInfoPartyObjList.add(ExternalAPITestHelper.createParty(paramForIAPartyMap));

        Map<String,Id> paramForBuPartyMap = new Map<String,Id>{
            'accountId' => buyerAccountObj.Id,
            'contactId' => buyerContactObj.Id,
            'partyTypeId' => buPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        addInfoPartyObjList.add(ExternalAPITestHelper.createParty(paramForBuPartyMap));

        // Creating Principal Party for current application
        Map<String,Id> paramForPrincipalPartyMap = new Map<String,Id>{
            'accountId' => coBorrowerAccObj.Id,
            'contactId' => coBorrowerContactObj.Id,
            'partyTypeId' => principalPartyTypeObj.Id,
            'applicationId' => applicationObj.Id,
            'dealerApplicantRelId' => coBorrowerDealerRelObj.Id
        };
        clcommon__Party__c principalPartyObj = ExternalAPITestHelper.createApplicantParty(paramForPrincipalPartyMap);
        principalPartyObj.Principal_Number__c = 1;
        addInfoPartyObjList.add(principalPartyObj);
        
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id,
            'dealerApplicantRelId' => borrowerDealerRelObj.Id
        };
        clcommon__Party__c borrowerPartyObj = ExternalAPITestHelper.createApplicantParty(paramForBorrowerPartyMap);
        addInfoPartyObjList.add(borrowerPartyObj);
        Database.insert(addInfoPartyObjList,true);
        List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList = ExternalAPITestHelper.createCreditRatingMatrix();
        Database.insert(creditRatingMatrixList,true);  
    }
    /**
    * @description : get collaterals details map
    * @author Kabir Pramanik | 09-25-2024 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> getCollaterals(){
        return new Map<String,Object>{
            'commodity' => 'Millet',
            'total_acres'=> 600,
            'producer_share_percent'=> 100,
            'approved_yield'=> 600,
            'insurance_plan'=> 'RP',
            'coverage_level_percent'=> 80
        };
    }
    /**
    * @description : get Insurance agent details map
    * @author Kabir Pramanik | 09-25-2024 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> getInsuranceDetails(){
        return new Map<String,Object>{
            'name' => 'Acko Birla',
            'street' => '123 Melrose Street',
            'city' => 'Adelade',
            'state' => 'WA',
            'postal_code' => '12205',
            'email' => 'aditya.insurance@yopmail.com',
            'phone' => '1890871256'
        };
    }
    /**
    * @description : get buyers details map
    * @author Kabir Pramanik | 09-25-2024 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> getBuyersDetails(){
        return new Map<String,Object>{
            'name' => 'David Warner',
            'street' => '123 Melrose Street',
            'city' => 'Adelade',
            'state' => 'WA',
            'postal_code' => '12205',
            'email' => 'david.warner@yopmail.com',
            'phone' => '1890871256'
        };
    }
    /**
    * @description : get landowners details map
    * @author Kabir Pramanik | 09-25-2024 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> getLandownersDetails(){
        return new Map<String,Object>{
            'name' => 'Lee Richie',
            'state' => 'WA',
            'county' => 'Adelade'
        };
    }
    /**
    * @description : get spouse details map
    * @author Kabir Pramanik | 09-25-2024 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> getSpouseDetails(){
        return new Map<String,Object>{
            'first_name' => 'Richie',
            'middle_name' => 'waley',
            'last_name' => 'Henry',
            'ssn' => '123456789',
            'email' => 'eva.james@yopmail.com'
        };
    }
    /**
    * @description Method to get system admin user
    * @author Shristy Kumari | 01-06-2025 
    * @return User 
    **/
    private static User getUser(){
        List<User> objUserList = [SELECT Id 
                                    FROM User 
                                    WHERE Profile.name = 'System Administrator'
                                    AND isActive = true
                                    LIMIT 1];
        if (objUserList.size() == 1){
            return objUserList[0];
        } 
        return null;
    }
     /**
    * @description Method to get application
    * @author Shristy Kumari | 01-06-2025 
    * @return User 
    **/
    private static genesis__Applications__c getApplication(){
        List<genesis__Applications__c> applicationObjList = [SELECT Id,
                                                                      genesis__Account__c,
                                                                      genesis__Account__r.Unique_Id__c
                                                                FROM genesis__Applications__c  
                                                                WHERE genesis__Loan_Number__c = '300023456'
                                                                LIMIT 1];
        if (applicationObjList.size() == 1){
             return applicationObjList[0];
        } 
        return null;
    }
     /**
    * @description : method to get request map
    * @author Shristy Kumari | 01-06-2025
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> getRequestMap(){
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            genesis__Account__c,
                                                            genesis__Account__r.Unique_Id__c
                                                    FROM genesis__Applications__c  
                                                    WHERE genesis__Loan_Number__c = '300023456'
                                                    LIMIT 1];
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> collateralsMap = getCollaterals(); 
        Map<String,Object> cropDetailsMap = new Map<String,Object>{
            'do_feed_collateral' => false,
            'collaterals' => new List<Object>{collateralsMap}
        };

        Map<String,Object> insuranceDetailMap = getInsuranceDetails();
        List<Object> insuranceAgentDetailList = new List<Object>{insuranceDetailMap};

        Map<String,Object> buyerDetailMap = getBuyersDetails();
        List<Object> buyersDetailsList =  new List<Object>{ buyerDetailMap };
        
        Map<String,Object> landownerDetailMap = getLandownersDetails();
        List<Object> landownersDetailsList = new List<Object>{ landownerDetailMap };

        Map<String,Object> spouseDetailMap = getSpouseDetails();
        List<Object> spouseDetailsList = new List<Object>{spouseDetailMap };

        Map<String,Object> requestMap = new Map<String,Object>{
            'application_details' => applicationDetailsMap,
            'borrower_details' => userDetailsMap,
            'crop_details' => cropDetailsMap,
            'insurance_agent_details' => insuranceAgentDetailList,
            'buyer_details' => buyersDetailsList,
            'landowner_details' =>landownersDetailsList,
            'spouse_details' => spouseDetailsList
        };
        return requestMap;
    }
    /**
    * @description : Method to test exception scenario when Dealer Cif key is missing
    * @author Kabir Pramanik | 09-25-2024 
    **/
    @isTest 
    private static void testDealerCifMissingException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(new User(Id=UserInfo.getUserId())){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            String message = (String)responseContentMap.get('message');
            System.assertEquals(message, ExternalConstants.DEALER_CIF_MISSING, 'Failed to test exception when Dealer Cif key is missing');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception Expected');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception scenario when Dealer Token is missing
    * @author Kabir Pramanik | 09-25-2024 
    **/
    @isTest 
    private static void testDealerTokenMissingException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(new User(Id=UserInfo.getUserId())){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            String message = (String)responseContentMap.get('message');
            System.assertEquals(message, ExternalConstants.DEALER_TOKEN_MISSING, 'Failed to test exception when Dealer Token is missing');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception Expected');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test scenario when Dealer CIF value is missing
    * @author Kabir Pramanik | 09-25-2024 
    **/
    @isTest 
    private static void testDealeCifValueMissingException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(new User(Id=UserInfo.getUserId())){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            String message = (String)responseContentMap.get('message');
            System.assertEquals(message, ExternalConstants.DEALER_CIF_MISSING, 'Failed to test exception when Dealer CIF value is missing.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception Expected');
            Test.stopTest();
        }
    }
    /**
    * @description : method to test exception scenario when Dealer Token value is missing
    * @author Kabir Pramanik | 09-25-2024 
    **/
    @isTest 
    private static void testDealerTokenValueMissingException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, '');
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(new User(Id=UserInfo.getUserId())){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            String message = (String)responseContentMap.get('message');
            System.assertEquals(message, ExternalConstants.DEALER_TOKEN_MISSING, 'Failed to test exception when Dealer Token value is missing.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception Expected');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception scenario when Dealer CIF value is invalid
    * @author Kabir Pramanik | 09-25-2024 
    **/
    @isTest 
    private static void testInvalidDealerCifException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555543');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(new User(Id=UserInfo.getUserId())){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            String message = (String)responseContentMap.get('message');
            System.assertEquals(message, ExternalConstants.DEALER_CIF_INVALID, 'Failed to test exception when Dealer CIF value is invalid.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception Expected');
            Test.stopTest();
        }
    }
    /**
    * @description : method to test exception scenario when Dealer Token value is invalid
    * @author Kabir Pramanik | 09-25-2024 
    **/
    @isTest 
    private static void testInvalidDealerTokenException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!//');
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(new User(Id=UserInfo.getUserId())){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            String message = (String)responseContentMap.get('message');
            System.assertEquals(message, ExternalConstants.DEALER_TOKEN_INVALID, 'Failed to test exception when Dealer Token value is invalid.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception Expected');
            Test.stopTest();
        }
    }
    /**
    * @description : method to test successful authorization
    * @author Shristy Kumari | 01-09-2025 
    **/
    @isTest 
    private static void testSuccesfulAuthorization(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(new User(Id=UserInfo.getUserId())){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE,RestContext.response.statusCode, 'user is not authorized');
            Test.stopTest();  
        }
    }
}