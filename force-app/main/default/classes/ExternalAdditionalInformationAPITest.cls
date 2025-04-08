/**
 * @description       : Test class for ExternalAdditionalInformationAPI
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 01-19-2025
 * @last modified by  : Shristy Kumari
**/
@isTest
public with sharing class ExternalAdditionalInformationAPITest{
    @TestSetup
    static void setup(){
        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForDealer();
        //creating business info for borrower
        genesis__Business_Information__c borrowerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj,borrowerBusinessInfoObj},true);

        // Creating Account for Dealer
        Account dealerAccountObj = ExternalAPITestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.CIF_Number__c = '102555';
        dealerAccountObj.Enable_ERP_Id__c = true;
        dealerAccountObj.Unique_Id__c = 'abc123#@!';
        Database.insert(dealerAccountObj, true);

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ExternalAPITestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);
        
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

        // Creating DealerApplicant relationship
        Dealer_Applicant_Relationship__c borrowerDealerRelObj = ExternalAPITestHelper.createApplicantDealerRelationship(borrowerAccountObj, borrowerContactObj, dealerAccountObj);
        Dealer_Applicant_Relationship__c coBorrowerDealerRelObj = ExternalAPITestHelper.createApplicantDealerRelationship(coBorrowerAccObj, coBorrowerContactObj, dealerAccountObj);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{borrowerDealerRelObj,coBorrowerDealerRelObj},true);

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
    * @author Suraj Kumar | 05-21-2024 
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> getCollaterals(){
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
    * @author Suraj Kumar | 05-21-2024 
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> getInsuranceDetails(){
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
    * @author Suraj Kumar | 05-21-2024 
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> getBuyersDetails(){
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
    * @author Suraj Kumar | 05-21-2024 
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> getLandownersDetails(){
        return new Map<String,Object>{
            'name' => 'Lee Richie',
            'state' => 'WA',
            'county' => 'Adelade'
        };
    }
    /**
    * @description : get spouse details map
    * @author Suraj Kumar | 05-21-2024 
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> getSpouseDetails(){
        return new Map<String,Object>{
            'first_name' => 'Richie',
            'middle_name' => 'waley',
            'last_name' => 'Henry',
            'ssn' => '123456789',
            'email' => 'eva.james@yopmail.com'
        };
    }
     /**
    * @description Method to create system admin user
    * @author Shristy Kumari | 01-06-2025 
    * @return User 
    **/
    private static User getUser(){
        List<User> objUserList = [SELECT Id 
                                    FROM User 
                                    WHERE Profile.name = 'System Administrator'
                                    AND isActive = true
                                    LIMIT 1];
        return objUserList[0];
    }
     /**
    * @description Method to create application
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
        return applicationObjList[0];  
    }
    /**
    * @description : Method to test success scenerio to add additional information
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testDoAddAdditionalInfoSuccess(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE,RestContext.response.statusCode, 'Expected additional information to be added to the application');
            Test.stopTest();  
        }
    }

    /**
    * @description : Method to test unauthorized user exception
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testUnAuthorizeUserException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c+'66'
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_ONE_STATUS_CODE,RestContext.response.statusCode, 'Exception expected for unauthorized user.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for unauthorized user.');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test exception for empty request body
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testEmptyRequestBodyException(){
        User userObj = getUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
       
        request.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>()));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE,RestContext.response.statusCode,'Exception expected for empty request body');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for empty request body');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test required parameter missing exception
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testRequiredkeyMissingException(){
        User userObj = getUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');

        Map<String,Object> requestMap = new Map<String,Object>{
            'test' => 'required parameter missing'
        };
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for missing required parameters.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing required parameters.');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test exception for invalid application id 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testInvalidApplicationIdException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id+'67'
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c+'66'
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for invalid application id');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for invalid application id');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for blank add additional info details
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testBlankAdditionalInfoDetails(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> cropDetailsMap = new Map<String,Object>{
            'do_feed_collateral' => false,
            'collaterals' => new List<Object>()
        };

        Map<String,Object> requestMap = new Map<String,Object>{
            'application_details' => applicationDetailsMap,
            'borrower_details' => userDetailsMap,
            'crop_details' => cropDetailsMap,
            'insurance_agent_details' => new List<Object>(),
            'buyer_details' => new List<Object>(),
            'landowner_details' => new List<Object>(),
            'spouse_details' => new List<Object>()
        };
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE,RestContext.response.statusCode,'Failure');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test exception for missing feed collateral 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testFeedCollateralsMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> cropDetailsMap = new Map<String,Object>{
            'collaterals' => new List<Object>()
        };

        Map<String,Object> requestMap = new Map<String,Object>{
            'application_details' => applicationDetailsMap,
            'borrower_details' => userDetailsMap,
            'crop_details' => cropDetailsMap,
            'insurance_agent_details' => new List<Object>(),
            'buyer_details' => new List<Object>(),
            'landowner_details' => new List<Object>(),
            'spouse_details' => new List<Object>()
        };
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for missing feed collateral.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing feed collateral.');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test exception for missing collateral 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testCollateralsMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> cropDetailsMap = new Map<String,Object>{
            'do_feed_collateral' => false
        };

        Map<String,Object> requestMap = new Map<String,Object>{
            'application_details' => applicationDetailsMap,
            'borrower_details' => userDetailsMap,
            'crop_details' => cropDetailsMap,
            'insurance_agent_details' => new List<Object>(),
            'buyer_details' => new List<Object>(),
            'landowner_details' => new List<Object>(),
            'spouse_details' => new List<Object>()
        };
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals( ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE,RestContext.response.statusCode, ' Exception expected for missing collateral.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing collateral');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception for missing commodity 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testCommodityMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> collateralsMap = getCollaterals(); 
        collateralsMap.remove('commodity');
        Map<String,Object> cropDetailsMap = new Map<String,Object>{
            'do_feed_collateral' => false,
            'collaterals' => new List<Object>{collateralsMap}
        };

        Map<String,Object> requestMap = new Map<String,Object>{
            'application_details' => applicationDetailsMap,
            'borrower_details' => userDetailsMap,
            'crop_details' => cropDetailsMap,
            'insurance_agent_details' => new List<Object>(),
            'buyer_details' => new List<Object>(),
            'landowner_details' => new List<Object>(),
            'spouse_details' => new List<Object>()
        };
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for missing commodity.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing commodity.');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test exception for missing total acres 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testTotalAcresMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> collateralsMap = getCollaterals(); 
        collateralsMap.remove('total_acres');
        Map<String,Object> cropDetailsMap = new Map<String,Object>{
            'do_feed_collateral' => false,
            'collaterals' => new List<Object>{collateralsMap}
        };

        Map<String,Object> requestMap = new Map<String,Object>{
            'application_details' => applicationDetailsMap,
            'borrower_details' => userDetailsMap,
            'crop_details' => cropDetailsMap,
            'insurance_agent_details' => new List<Object>(),
            'buyer_details' => new List<Object>(),
            'landowner_details' => new List<Object>(),
            'spouse_details' => new List<Object>()
        };
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE,RestContext.response.statusCode, 'Exception expected for missing total acres.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing total acres.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception for missing producer share percent 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testProducerShareMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> collateralsMap = getCollaterals(); 
        collateralsMap.remove('producer_share_percent');
        Map<String,Object> cropDetailsMap = new Map<String,Object>{
            'do_feed_collateral' => false,
            'collaterals' => new List<Object>{collateralsMap}
        };

        Map<String,Object> requestMap = new Map<String,Object>{
            'application_details' => applicationDetailsMap,
            'borrower_details' => userDetailsMap,
            'crop_details' => cropDetailsMap,
            'insurance_agent_details' => new List<Object>(),
            'buyer_details' => new List<Object>(),
            'landowner_details' => new List<Object>(),
            'spouse_details' => new List<Object>()
        };
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for missing producer share percent.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing producer share percent.');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test exception for missing approved yeild 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testApprovedYeildMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> collateralsMap = getCollaterals(); 
        collateralsMap.remove('approved_yield');
        Map<String,Object> cropDetailsMap = new Map<String,Object>{
            'do_feed_collateral' => false,
            'collaterals' => new List<Object>{collateralsMap}
        };

        Map<String,Object> requestMap = new Map<String,Object>{
            'application_details' => applicationDetailsMap,
            'borrower_details' => userDetailsMap,
            'crop_details' => cropDetailsMap,
            'insurance_agent_details' => new List<Object>(),
            'buyer_details' => new List<Object>(),
            'landowner_details' => new List<Object>(),
            'spouse_details' => new List<Object>()
        };
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for missing approved yeild.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing approved yeild.');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test exception for missing insurance plan 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testInsurancePlanMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> collateralsMap = getCollaterals(); 
        collateralsMap.remove('insurance_plan');
        Map<String,Object> cropDetailsMap = new Map<String,Object>{
            'do_feed_collateral' => false,
            'collaterals' => new List<Object>{collateralsMap}
        };

        Map<String,Object> requestMap = new Map<String,Object>{
            'application_details' => applicationDetailsMap,
            'borrower_details' => userDetailsMap,
            'crop_details' => cropDetailsMap,
            'insurance_agent_details' => new List<Object>(),
            'buyer_details' => new List<Object>(),
            'landowner_details' => new List<Object>(),
            'spouse_details' => new List<Object>()
        };
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for missing insurance plan.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing insurance plan.');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test coverage level percent missing exception
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testCoverageLevelMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> collateralsMap = getCollaterals(); 
        collateralsMap.remove('coverage_level_percent');
        Map<String,Object> cropDetailsMap = new Map<String,Object>{
            'do_feed_collateral' => false,
            'collaterals' => new List<Object>{collateralsMap}
        };

        Map<String,Object> requestMap = new Map<String,Object>{
            'application_details' => applicationDetailsMap,
            'borrower_details' => userDetailsMap,
            'crop_details' => cropDetailsMap,
            'insurance_agent_details' => new List<Object>(),
            'buyer_details' => new List<Object>(),
            'landowner_details' => new List<Object>(),
            'spouse_details' => new List<Object>()
        };
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,'Exception expected for missing coverage level percent.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing coverage level percent.');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test feed collateral missing exception
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testCollateralFeedMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> collateralsMap = getCollaterals(); 
        Map<String,Object> cropDetailsMap = new Map<String,Object>{
            'do_feed_collateral' => true,
            'collaterals' => new List<Object>{collateralsMap}
        };

        Map<String,Object> requestMap = new Map<String,Object>{
            'application_details' => applicationDetailsMap,
            'borrower_details' => userDetailsMap,
            'crop_details' => cropDetailsMap,
            'insurance_agent_details' => new List<Object>(),
            'buyer_details' => new List<Object>(),
            'landowner_details' => new List<Object>(),
            'spouse_details' => new List<Object>()
        };
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Exception expected for missing feed collateral.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing feed collateral');
            Test.stopTest();
        }
    }


    /**
    * @description : Method to test buyer name missing exception
    * @author Shristy Kumari | 12-26-2024 
    **/
    @isTest 
    public static void testBuyerNameMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        buyerDetailMap.remove('name');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for missing buyers name.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing buyers name.');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test landowner Name missing exception
    * @author Shristy Kumari | 12-26-2024 
    **/
    @isTest 
    public static void testLandownerNameMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        landownerDetailMap.remove('name');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Success');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception Expected');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test spouse detail missing exception
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testSpouseDetailMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        spouseDetailMap.remove('first_name');
        spouseDetailMap.remove('last_name');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            Test.stopTest();
            System.assertEquals(RestContext.response.statusCode, ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, 'Exception expected for missing spouse details.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing spouse details.');
        }
    }
    /**
    * @description : Method to test invalid total acres exception
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testInvalidTotalAcersException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> collateralsMap = getCollaterals(); 
        collateralsMap.put('total_acres','ahgagjga');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for invalid total acres.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for invalid total acres.');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test invalid producer share percent exception
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testInvalidProducerShareException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> collateralsMap = getCollaterals(); 
        collateralsMap.put('producer_share_percent','ahgagjga');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for invalid producer share percent.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for invalid producer share percent.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test invalid approve yeild exception
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testInvalidApprovedYeildException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> collateralsMap = getCollaterals(); 
        collateralsMap.put('approved_yield','ahgagjga');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for invalid approve yeild.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for invalid approve yeild.');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test invalid insurance plan exception
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testInvalidInsurancePlanException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> collateralsMap = getCollaterals(); 
        collateralsMap.put('insurance_plan','ahgagjga');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for invalid insurance plan.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for invalid insurance plan.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test invalid coverage level percent exception
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testInvalidCoverageLevelPercentException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> collateralsMap = getCollaterals(); 
        collateralsMap.put('coverage_level_percent','ahgagjga');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for invalid coverage level percent.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for invalid coverage level percent.');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test invalid feed percent exception
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testInvalidFeedPercentException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> collateralsMap = getCollaterals(); 
        collateralsMap.put('collateral_fed_percent','ahgagjga');
        Map<String,Object> cropDetailsMap = new Map<String,Object>{
            'do_feed_collateral' => true,
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for invalid feed percent.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for invalid feed percent.');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test invalid ssn exception for spouse
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testInvalidSpouseSsnException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        spouseDetailMap.put('ssn','9811');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for invalid SSN for spouse.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for invalid SSN for spouse.');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test invalid email format exception
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testInvalidEmailFormatException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        insuranceDetailMap.put('email','abajb');
        List<Object> insuranceAgentDetailList = new List<Object>{insuranceDetailMap};

        Map<String,Object> buyerDetailMap = getBuyersDetails();
        buyerDetailMap.put('email','ajhabhjva');
        List<Object> buyersDetailsList =  new List<Object>{ buyerDetailMap };
        
        Map<String,Object> landownerDetailMap = getLandownersDetails();
        List<Object> landownersDetailsList = new List<Object>{ landownerDetailMap };

        Map<String,Object> spouseDetailMap = getSpouseDetails();
        spouseDetailMap.put('email','9811');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for invalid email.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for invalid email.');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test invalid phone number exception for buyer
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testInvalidBuyerPhoneNumberException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        buyerDetailMap.put('phone','1234');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for invalid phone number for buyer.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for invalid phone number for buyer.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test invalid commodity exception
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testInvalidCommodityException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> collateralsMap = getCollaterals(); 
        collateralsMap.put('commodity','ahgagjga');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for invalid commodity.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for invalid commodity.');
            Test.stopTest();
            
        }
    }

    /**
    * @description : Method to test invalid state exception for Insurance agent
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testInvalidInsAgentStateException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        insuranceDetailMap.put('state','Kolkata');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            Test.stopTest();
            System.assertEquals(RestContext.response.statusCode, ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, 'Exception expected for invalid insurance agent state.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for invalid insurance agent state.');
        }
    }

    /**
    * @description : Method to test invalid postal code exception for insurance agent
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testInvalidInsAgentPostalCodeException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        insuranceDetailMap.put('postal_code','1234');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE,RestContext.response.statusCode, 'Exception expected for invalid postal code for insurance agent.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for invalid postal code for insurance agent.');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test success scenerio to add additional info for corporation
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testAdditionalInfoCorporationSuccess(){
        User userObj = getUser();
        clcommon__Legal_Entity__c entityObj = [SELECT Id, 
                                                        clcommon__Legal_Entity_Type__c,
                                                        Name 
                                                    FROM clcommon__Legal_Entity__c];
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyTypeList = [SELECT Id,
                                                                    clcommon__Type__r.name,
                                                                    clcommon__Account__r.Unique_Id__c 
                                                                FROM clcommon__Party__c 
                                                                WHERE genesis__Application__c = :applicationObj.Id
                                                                AND clcommon__Type__r.name = :ExternalConstants.BORROWER_PARTY
                                                                ];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> userDetailsMap = new Map<String,Object>{
            'user_id' => borrowerPartyTypeList[0].clcommon__Account__r.Unique_Id__c 
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals( ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE,RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test success scenerio to add additional info for Tier 3
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    public static void testAdditionalInfoTierThreeSuccess(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c tier = [SELECT Id 
                                                        FROM genesis__Credit_Rating_Matrix__c 
                                                        WHERE Name = 'Tier 3'];
        applicationObj.genesis__Credit_Rating__c = tier.Id;
        applicationObj.genesis__loan_amount__c = 10000000;
        Database.update(applicationObj, true);
        Double requestedLoanAmount = applicationObj.genesis__loan_amount__c;
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            genesis__Applications__c updatedApplicationObj = [SELECT Id,
                                                                    genesis__loan_amount__c
                                                                FROM genesis__Applications__c 
                                                                WHERE Id = :applicationObj.Id];
            System.assert(updatedApplicationObj.genesis__loan_amount__c < requestedLoanAmount, 'Failure');
            Test.stopTest();
            
        }
    }
    /**
    * @description : Method to test invalid state exception for landowner
    * @author Shristy Kumari | 12-26-2024 
    **/
    @isTest 
    public static void testInvalidLandownerStateException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        landownerDetailMap.put('state','Kolkata');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            Test.stopTest();
            System.assertEquals(RestContext.response.statusCode, ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, 'Exception expected for invalid state for land owner.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for invalid state for land owner.');
        }
    }
    /**
    * @description : Method to test invalid state exception for Buyer
    * @author Shristy Kumari | 12-26-2024 
    **/
    @isTest 
    public static void testInvalidBuyerStateException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        buyerDetailMap.put('state','Kolkata');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            Test.stopTest();
            System.assertEquals(RestContext.response.statusCode, ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, 'Exception expected for invalid state for buyer.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for invalid state for buyer.');
        }
    }
    /**
    * @description : Method to test invalid email format exception for buyer
    * @author Shristy Kumari | 12-26-2024 
    **/
    @isTest 
    public static void testInvalidBuyerEmailFormatException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        buyerDetailMap.put('email','ajhabhjva');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for invalid email for buyer.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for invalid email for buyer.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test invalid email format exception for insurance agent
    * @author Shristy Kumari | 09-30-2024 
    **/
    @isTest 
    public static void testInvalidInsAgentEmailFormatException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformationn';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        insuranceDetailMap.put('email','abajb');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for invalid email for insurance agent.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for invalid email for insurance agent.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test invalid phone number exception for insurance agent
    * @author Shristy Kumari | 12-26-2024 
    **/
    @isTest 
    public static void testInvalidInsAgentPhoneNumberException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        insuranceDetailMap.put('phone','abajb');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for invalid phone number for insurance agent.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for invalid phone number for insurance agent.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception for invalid postal code for buyer
    * @author Shristy Kumari | 12-26-2024 
    **/
    @isTest 
    public static void testInvalidbuyerPostalCodeException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        buyerDetailMap.put('postal_code','Kolkata');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE,RestContext.response.statusCode, 'Exception expected for missing postal code for buyer.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing postal code for buyer.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception for missing insurance agent name 
    * @author Shristy Kumari | 12-26-2024 
    **/
    @isTest 
    public static void testInsuranceAgentNameMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        insuranceDetailMap.remove('name');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for missing insurance agent name.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing insurance agent name.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception for missing insurance agent city 
    * @author Shristy Kumari | 12-26-2024 
    **/
    @isTest 
    public static void testInsuranceAgentCityMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        insuranceDetailMap.remove('city');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for missing city for insurance agent.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing city for insurance agent.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception for missing insurance agent state 
    * @author Shristy Kumari | 12-26-2024 
    **/
    @isTest 
    public static void testInsuranceAgentStateMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        insuranceDetailMap.remove('state');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for missing state for insurance agent.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing state for insurance agent.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception for missing insurance agent postalcode 
    * @author Shristy Kumari | 12-26-2024 
    **/
    @isTest 
    public static void testInsuranceAgentPostalCodeMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        insuranceDetailMap.remove('postal_code');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for missing postal code for insurance agent.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing postal code for insurance agent.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test buyer city missing
    * @author Shristy Kumari | 12-26-2024 
    **/
    @isTest 
    public static void testBuyerCityMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        buyerDetailMap.remove('city');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for missing city for buyer.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing city for buyer.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test buyer State missing exception
    * @author Shristy Kumari | 12-26-2024 
    **/
    @isTest 
    public static void testBuyerStateMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        buyerDetailMap.remove('state');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for missing state for buyer.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing state for buyer.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test buyer postalCode missing
    * @author Shristy Kumari | 12-26-2024 
    **/
    @isTest 
    public static void testBuyerPostalCodeMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        buyerDetailMap.remove('postal_code');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for missing postal code for buyer.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing postal code for buyer.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception for landowner state missing
    * @author Shristy Kumari | 12-26-2024 
    **/
    @isTest 
    public static void testLandownerStateMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        landownerDetailMap.remove('state');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for missing state for land owner.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing state for land owner.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test landowner county missing exception
    * @author Shristy Kumari | 12-26-2024 
    **/
    @isTest 
    public static void testLandownerCountyMissingException(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/applications/{application_id}/saveAdditionalInformation';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc123#@!');
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
        landownerDetailMap.remove('county');
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
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationAPI.doAddAdditionalInformation();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Exception expected for missing county for land owner.');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'ExternalAdditionalInformationAPI'
                                              LIMIT 1];
            System.assertEquals('ExternalAdditionalInformationAPI', logList[0].Name,'Exception expected for missing county for land owner.');
            Test.stopTest();
        }
    }
}