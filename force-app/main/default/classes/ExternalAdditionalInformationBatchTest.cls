/**
 * @description       : Test class for ExternalAdditionalInformationBatch
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 01-23-2025
 * @last modified by  : Shristy Kumari
**/
@isTest
private with sharing class ExternalAdditionalInformationBatchTest {
    /**
    * @description Test setup
    * @author Shristy Kumari | 01-13-2025 
    **/
    @TestSetup
    static void setup(){
     // Creating Business Information
    genesis__Business_Information__c dealerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForDealer();
    Database.insert(dealerBusinessInfoObj, true);

     // Creating Account for Dealer
    Account dealerAccountObj = ExternalAPITestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
    Database.insert(dealerAccountObj, true);

    // Creating Account for Certified Lender
    Account clAccountObj = ExternalAPITestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
    Database.insert(clAccountObj, true);

    // Creating Contact for Certified Lender
    Contact clContactObj = ExternalAPITestHelper.createCLContact(clAccountObj.Id);
    Database.insert(clContactObj,true);

    // Creating Legal Entity for Borrower
    clcommon__Legal_Entity__c entityObj = ExternalAPITestHelper.createSolePropLegalEntity();
    Database.insert(entityObj, true);
    
    //creating business info for borrower
    genesis__Business_Information__c borrowerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForBorrower();
    Database.insert(borrowerBusinessInfoObj,true);

    // Creating Account for Borrower
    Account borrowerAccountObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
    //  borrowerAccountObj.Unique_Id__c = '001O100000E5kzvIAB';
    borrowerAccountObj.Unique_Id__c = 'TestBorrUniqueId002';
    Database.insert(borrowerAccountObj, true);

    // Creating Contact for Borrower
    Contact borrowerContactObj = ExternalAPITestHelper.createBorrowerContact(borrowerAccountObj.Id);
    Database.insert(borrowerContactObj,true);

    // Creating CL Purpose of Application
    clcommon__CL_Purpose__c clPurposeObj = ExternalAPITestHelper.createCLPurposeForApplication();
    Database.insert(clPurposeObj, true);

    // Creating Cl Product of Application
    clcommon__CL_Product__c clProductObj = ExternalAPITestHelper.createCLProductForApplication();
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

    List<clcommon__Party__c> addInfoPartyObjList = new List<clcommon__Party__c>();

    Account buyerAccountObj = ExternalAPITestHelper.createBuyerAccount(entityObj, borrowerBusinessInfoObj.Id);
    buyerAccountObj.Unique_Id__c = 'TestBAUniqueId002';
    Account loAccountObj = ExternalAPITestHelper.createLandOwnerAccount(entityObj,borrowerBusinessInfoObj.Id);
    loAccountObj.Unique_Id__c = 'TestLOUniqueId002';
    Account iaAccountObj = ExternalAPITestHelper.createInsuranceAgentAccount(entityObj,borrowerBusinessInfoObj.Id);
    iaAccountObj.Unique_Id__c = 'TestIAUniqueId002';
    Account spAccountObj = ExternalAPITestHelper.createAccount();
    spAccountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
    spAccountObj.genesis__Business_Information__c = borrowerBusinessInfoObj.Id;
    spAccountObj.Unique_Id__c = 'TestSPUniqueId002';

    Account coBorrowerAccObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
    coBorrowerAccObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
    coBorrowerAccObj.Unique_Id__c = 'TestCoBorrUniqueId002';


    Database.insert(new List<Account>{
            buyerAccountObj,
            loAccountObj,
            iaAccountObj,
            spAccountObj,
        coBorrowerAccObj
    }, true);

    Contact buyerContactObj = ExternalAPITestHelper.createBuyerContact(buyerAccountObj.Id);
    Contact loContactObj = ExternalAPITestHelper.createLandOwnerContact(loAccountObj.Id);
    Contact iaContactObj = ExternalAPITestHelper.createInsuranceAgentContact(iaAccountObj.Id);
    Contact spContactObj = ExternalAPITestHelper.createContact();
    spContactObj.accountId = spAccountObj.Id;
    Contact coBorrowerContactObj = ExternalAPITestHelper.createBorrowerContact(coBorrowerAccObj.Id);

    Database.insert(new List<Contact>{
        buyerContactObj,
        loContactObj,
        iaContactObj,
        spContactObj,
        coBorrowerContactObj
    }, true);
    
    // Creating DealerApplicant relationship
    Dealer_Applicant_Relationship__c borrowerDealerRelObj = ExternalAPITestHelper.createApplicantDealerRelationship(borrowerAccountObj, borrowerContactObj, dealerAccountObj);
    Dealer_Applicant_Relationship__c coBorrowerDealerRelObj = ExternalAPITestHelper.createApplicantDealerRelationship(coBorrowerAccObj, coBorrowerContactObj, dealerAccountObj);
    Database.insert(new List<Dealer_Applicant_Relationship__c>{borrowerDealerRelObj,coBorrowerDealerRelObj},true);

    clcommon__Party_Type__c spPartyTypeObj = ExternalAPITestHelper.createPartyType('SPOUSE');
    clcommon__Party_Type__c loPartyTypeObj = ExternalAPITestHelper.createPartyType('LANDOWNER');
    clcommon__Party_Type__c iaPartyTypeObj = ExternalAPITestHelper.createPartyType('INSURANCE AGENT');
    clcommon__Party_Type__c buPartyTypeObj = ExternalAPITestHelper.createPartyType('BUYER');
    clcommon__Party_Type__c principalPartyTypeObj = ExternalAPITestHelper.createPartyType('PRINCIPAL');

    Database.insert(new List<clcommon__Party_Type__c>{
        spPartyTypeObj,
        loPartyTypeObj,
        iaPartyTypeObj,
        buPartyTypeObj,
        principalPartyTypeObj
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
    Database.insert(addInfoPartyObjList,true);
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
    * @description : method to get request map
    * @author Suraj Kumar | 05-21-2024 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> getRequestMap(){
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            genesis__Account__c,
                                                            genesis__Account__r.Unique_Id__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        Map<String,Object> insuranceDetailMap = getInsuranceDetails();
        List<Object> insuranceAgentDetailList = new List<Object>{insuranceDetailMap};

        Map<String,Object> buyerDetailMap = getBuyersDetails();
        List<Object> buyersDetailsList =  new List<Object>{ buyerDetailMap };
        
        Map<String,Object> landownerDetailMap = getLandownersDetails();
        List<Object> landownersDetailsList = new List<Object>{ landownerDetailMap };

        Map<String,Object> spouseDetailMap = getSpouseDetails();
        List<Object> spouseDetailsList = new List<Object>{spouseDetailMap };

        Map<String,Object> requestMap = new Map<String,Object>{
            ExternalConstants.SPOUSE_KEY => spouseDetailsList,
            ExternalConstants.LANDOWNER_KEY => landownersDetailsList,
            ExternalConstants.BUYER_KEY => buyersDetailsList,
            ExternalConstants.INSURANCE_AGENT_KEY => insuranceAgentDetailList,
            ExternalConstants.APPLICATION_KEY => applicationObj.Id
        };
        return requestMap;
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
    * @description : Method to test success scenerio for adding spouse details
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    private static void testAddSpouseDetailsSuccess(){
        User userObj = getUser();
        Map<String,Object> requestMap = getRequestMap();
        requestMap.put(ExternalConstants.PARTY_TYPE , ExternalConstants.SPOUSE_PARTY_NAME);
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationBatch batchObj = new ExternalAdditionalInformationBatch(requestMap);
            Id jobId = Database.executeBatch(batchObj,1);
            Test.stopTest();
            AsyncApexJob jobObj = [SELECT Id, 
                                            JobType 
                                        FROM AsyncApexJob 
                                        WHERE Id = :jobId];
            System.assertEquals(jobObj.JobType, 'BatchApex', 'Failed to execute batchJob for adding spouse details.');
            List<Account> spouseAccountList = [SELECT Id, Name FROM Account WHERE clcommon__Email__c = 'eva.james@yopmail.com' LIMIT 1];
            System.assertNotEquals(spouseAccountList.size(), 0, 'No Account records found for spouse party type.');
            System.assertEquals(spouseAccountList[0].Name, 'Richie Henry', 'Spouse account name does not match expected value.');
        }
    }
    /**
    * @description : Method to test success scenerio for adding land owner details
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    private static void testAddLandownersDetailsSuccess(){
        User userObj = getUser();
        Map<String,Object> requestMap = getRequestMap();
        requestMap.put(ExternalConstants.PARTY_TYPE , ExternalConstants.LANDOWNER_PARTY_NAME);
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationBatch batchObj = new ExternalAdditionalInformationBatch(requestMap);
            Id jobId = Database.executeBatch(batchObj,1);
            Test.stopTest();
            AsyncApexJob jobObj = [SELECT Id, 
                                            JobType 
                                        FROM AsyncApexJob 
                                        WHERE Id = :jobId];
            System.assertEquals(jobObj.JobType, 'BatchApex', 'Failed to execute batchJob for adding Land owner details.');
            List<Account> landOwnerAccountList = [SELECT Id, Name FROM Account WHERE Name = 'Lee Richie' LIMIT 1];
            System.assertNotEquals(landOwnerAccountList.size(), 0, 'No Account records found for land owner party type.');
            System.assertEquals(landOwnerAccountList[0].Name, 'Lee Richie', 'land owner account name does not match expected value.');
        }
    }
    /**
    * @description : Method to test success scenerio for adding buyer details
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    private static void testAddBuyerDetailsSuccess(){
        User userObj = getUser();
        Map<String,Object> requestMap = getRequestMap();
        requestMap.put(ExternalConstants.PARTY_TYPE , ExternalConstants.BUYER_PARTY_NAME);
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationBatch batchObj = new ExternalAdditionalInformationBatch(requestMap);
            Id jobId = Database.executeBatch(batchObj,1);
            Test.stopTest();
            AsyncApexJob jobObj = [SELECT Id, 
                                            JobType 
                                        FROM AsyncApexJob 
                                        WHERE Id = :jobId];
            System.assertEquals(jobObj.JobType, 'BatchApex', 'Failed to execute batchJob for adding Land owner details.');
            List<Account> buyersAccountList = [SELECT Id, Name FROM Account WHERE Name = 'David Warner' LIMIT 1];
            System.assertNotEquals(buyersAccountList.size(), 0, 'No Account records found for buyer party type.');
            System.assertEquals(buyersAccountList[0].Name, 'David Warner', 'buyer account name does not match expected value.');
        }
    }
    /**
    * @description : Method to test success scenerio for adding insurance agent details
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    private static void testAddInsuranceAgentDetailsSuccess(){
        User userObj = getUser();
        Map<String,Object> requestMap = getRequestMap();
        requestMap.put(ExternalConstants.PARTY_TYPE , ExternalConstants.INSURANCE_AGENT_PARTY_NAME);
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationBatch batchObj = new ExternalAdditionalInformationBatch(requestMap);
            Id jobId = Database.executeBatch(batchObj,1);
            Test.stopTest();
            AsyncApexJob jobObj = [SELECT Id, 
                                            JobType,
                                            Status
                                        FROM AsyncApexJob 
                                        WHERE Id = :jobId];
            System.assertEquals(jobObj.JobType, 'BatchApex', 'Failed to execute batchJob for adding insurance agent details.'); 
            List<Account> insuranceAgentAccountList = [SELECT Id, Name FROM Account WHERE Name = 'Acko Birla' LIMIT 1];
            System.assertNotEquals(insuranceAgentAccountList.size(), 0, 'No Account records found for insurance agent party type.');
            System.assertEquals(insuranceAgentAccountList[0].Name, 'Acko Birla', 'Insurance agent account name does not match expected value.');
        }
    }

    /**
    * @description : Method to test exception scenerio when party type is missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    private static void testPartyTypeMissingException(){
        User userObj = getUser();
        Map<String,Object> requestMap = getRequestMap();
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationBatch batchObj = new ExternalAdditionalInformationBatch(requestMap);
            Test.stopTest();
            try{
                Database.executeBatch(batchObj,1);
            }
            catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.REQUIRED_PARAMETERS_MISSING, exceptionObj.getMessage(), 'Failed to execute batchJob to test exception scenerio when party type is missing');
                List<clcommon__Log__c> logList = [SELECT Name
                                                FROM clcommon__Log__c 
                                                WHERE Name= 'ExternalAdditionalInformationBatch'
                                                LIMIT 1];
                System.assertEquals('ExternalAdditionalInformationBatch', logList[0].Name,'Exception Expected');
            }
        }
    }
    /**
    * @description : Method to test exception scenerio when spouse key is missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    private static void testSpouseKeyMissingException(){
        User userObj = getUser();
        Map<String,Object> requestMap = getRequestMap();
        requestMap.remove(ExternalConstants.SPOUSE_KEY);
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationBatch batchObj = new ExternalAdditionalInformationBatch(requestMap);
            Test.stopTest();
            try{
                Database.executeBatch(batchObj,1);
            }
            catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.REQUIRED_PARAMETERS_MISSING, exceptionObj.getMessage(), 'Failed to execute batchJob for testing exception scenerio when spouse key is missing');
                List<clcommon__Log__c> logList = [SELECT Name
                                                FROM clcommon__Log__c 
                                                WHERE Name= 'ExternalAdditionalInformationBatch'
                                                LIMIT 1];
                System.assertEquals('ExternalAdditionalInformationBatch', logList[0].Name,'Exception Expected');
            }
        }
    }

    /**
    * @description : Method to test exception scenerio when buyer key is missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    private static void testBuyerKeyMissingException(){
        User userObj = getUser();
        Map<String,Object> requestMap = getRequestMap();
        requestMap.remove(ExternalConstants.BUYER_KEY);
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationBatch batchObj = new ExternalAdditionalInformationBatch(requestMap);
            Test.stopTest();
            try{
                Database.executeBatch(batchObj,1);
            }
            catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.REQUIRED_PARAMETERS_MISSING, exceptionObj.getMessage(), 'Failed to execute batchJob for testing exception scenerio when buyer key is missing');
                List<clcommon__Log__c> logList = [SELECT Name
                                                FROM clcommon__Log__c 
                                                WHERE Name= 'ExternalAdditionalInformationBatch'
                                                LIMIT 1];
                System.assertEquals('ExternalAdditionalInformationBatch', logList[0].Name,'Exception Expected');
            }
        }
    }
    /**
    * @description : Method to test exception scenerio when landowner key is missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    private static void testLandownerKeyMissingException(){
        User userObj = getUser();
        Map<String,Object> requestMap = getRequestMap();
        requestMap.remove(ExternalConstants.LANDOWNER_KEY);
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationBatch batchObj = new ExternalAdditionalInformationBatch(requestMap);
            Test.stopTest();
            try{
                Database.executeBatch(batchObj,1);
            }
            catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.REQUIRED_PARAMETERS_MISSING, exceptionObj.getMessage(), 'Failed to execute batchJob for testing exception scenerio when landowner key is missing');
                List<clcommon__Log__c> logList = [SELECT Name
                                                FROM clcommon__Log__c 
                                                WHERE Name= 'ExternalAdditionalInformationBatch'
                                                LIMIT 1];
                System.assertEquals('ExternalAdditionalInformationBatch', logList[0].Name,'Exception Expected');
            }
        }
    }
    /**
    * @description : Method to test exception scenerio when insurance key missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest 
    private static void testInsuranceKeyMissingException(){
        User userObj = getUser();
        Map<String,Object> requestMap = getRequestMap();
        requestMap.remove(ExternalConstants.INSURANCE_AGENT_KEY);
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationBatch batchObj = new ExternalAdditionalInformationBatch(requestMap);
            Test.stopTest();
            try{
                Database.executeBatch(batchObj,1);
            }
            catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.REQUIRED_PARAMETERS_MISSING, exceptionObj.getMessage(), 'Failed to execute batchJob for testing exception scenerio when insurance key is missing');
                List<clcommon__Log__c> logList = [SELECT Name
                                                FROM clcommon__Log__c 
                                                WHERE Name= 'ExternalAdditionalInformationBatch'
                                                LIMIT 1];
                System.assertEquals('ExternalAdditionalInformationBatch', logList[0].Name,'Exception Expected');
            }
        }
    }
    /**
    * @description : Method to test exception scenerio when Application key missing
    * @author Shristy Kumari | 12-31-2024 
    **/
    @isTest 
    private static void testApplicationKeyMissingException(){
        User userObj = getUser();
        Map<String,Object> requestMap = getRequestMap();
        requestMap.remove(ExternalConstants.APPLICATION_KEY);
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInformationBatch batchObj = new ExternalAdditionalInformationBatch(requestMap);
            Test.stopTest();
            try{
                Database.executeBatch(batchObj,1);
            }
            catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.REQUIRED_PARAMETERS_MISSING, exceptionObj.getMessage(), 'Failed to execute batchJob for testing exception scenerio when Application key is missing');
                List<clcommon__Log__c> logList = [SELECT Name
                                                FROM clcommon__Log__c 
                                                WHERE Name= 'ExternalAdditionalInformationBatch'
                                                LIMIT 1];
                System.assertEquals('ExternalAdditionalInformationBatch', logList[0].Name,'Exception Expected');
            }    
        }
    }
}