/**
 * @description       : Test class for PortalScoreApplicationAPI
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 04-08-2025
 * @last modified by  : Sk Minsar
**/
@isTest
public without sharing class PortalScoreApplicationAPITest {

    private static final String INDIVIDUAL_ENTITY = 'Individual(s) with DBA';
    private static final String ASSERTION_FAILED = 'Assertion Failed';
    private static final String CL_USER_NAME = 'Ross Geller';
    private static final String KEY_APPLICATION = 'application';
    private static final String KEY_APPLICATION_LIST = 'applicationList';
    private static final String KEY_BORROWER_ACCOUNT_LIST = 'borrowerAccountList';
    private static final String KEY_BORROWER_CONTACT_LIST = 'borrowerContactList';
    private static final String KEY_PARTY_LIST = 'partyList';
    private static final String DUPLICATE_SSN = '982763493';
    private static final String KEY_FICO_SCORE = 'ficoScore';
    private static final String KEY_SBSS_SCORE = 'sbssScore';
    private static final String KEY_FICO_RECORDED = 'ficoRecorded';

    /**
    * @description - Creating test data
    * @author Sk Minsar | 04-04-2025 
    **/
    @testSetup
    static void setup(){

        Map<String, Id> partyTypeMap = new Map<String, Id>();

        //Creating Legal entity
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(legalEntityObj,true);
        
        //Creating Borrower business info 
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);
        
        //Creating application, party, roles, relationships ---------------------------------------------------------------------------------------------
        ApplicationOriginationSetupTestHelper.createTestSetup();

        List<genesis__Applications__c> applicationList = [SELECT Id, genesis__CL_Product__c, genesis__CL_Purpose__c, genesis__Account__c, genesis__Contact__c, Dealer_Name__c, Certified_Lender__c, Dealer_Applicant_Relationship__c, Is_Evergreen__c FROM genesis__Applications__c WHERE genesis__Account__r.clcommon__Legal_Entity_Type__r.name = :ConstantValues.SOLE_PROP_ENTITY LIMIT :PortalConstants.TEN_VALUE];
        List<Contact> dbaContactList = [SELECT id, name, accountId FROM Contact WHERE Account.clcommon__Legal_Entity_Type__r.name = :INDIVIDUAL_ENTITY LIMIT :PortalConstants.TEN_VALUE];
        List<clcommon__Party_Type__c> partyTypeList = [SELECT id, name FROM clcommon__Party_Type__c WHERE Name In (:ConstantValues.BORROWER_PARTY, :ConstantValues.PRINCIPAL_PARTY) LIMIT :PortalConstants.TEN_VALUE];
        for(clcommon__Party_Type__c partyType: partyTypeList){
            partyTypeMap.put(partyType.name, partyType.Id);
        }

        //Creating dealer applicant relationship ---------------------------------------------------------------------------------------------
        Dealer_Applicant_Relationship__c relationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(dbaContactList[0], applicationList[0].Dealer_Name__c);
        Database.insert(relationObj,true);

        //Creating application ---------------------------------------------------------------------------------------------
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(new Map<String,Id>{
            'dealerAccountObjId' => applicationList[0].Dealer_Name__c,
            'clProductObjId' => applicationList[0].genesis__CL_Product__c,
            'clPurposeObjId' => applicationList[0].genesis__CL_Purpose__c,
            'borrowerAccountObjId' => dbaContactList[0].AccountId,
            'borrowerContactObjId' => dbaContactList[0].Id,
            'clAccountObjId' => applicationList[0].Certified_Lender__c,
            'dealerApplicantRelationshipId' => relationObj.Id
        });
        applicationObj.Dealer_Applicant_Relationship__c = relationObj.Id;
        Database.insert(applicationObj, true);

        //Creating required party --------------------------------------------------------------------------------------------- 
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
            'accountId' => dbaContactList[0].AccountId,
            'contactId' =>dbaContactList[0].Id,
            'partyTypeId' => partyTypeMap.get(ConstantValues.BORROWER_PARTY),
            'applicationId' =>applicationObj.Id,
            'dealerApplicantRelationshipId' => relationObj.Id
        });
        clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
            'accountId' => applicationList[0].genesis__Account__c,
            'contactId' => applicationList[0].genesis__Contact__c,
            'partyTypeId' => partyTypeMap.get(ConstantValues.PRINCIPAL_PARTY),
            'applicationId' =>applicationObj.Id,
            'dealerApplicantRelationshipId' => applicationList[0].Dealer_Applicant_Relationship__c
        });
        Database.insert(new List<clcommon__Party__c>{borrowerPartyObj, principalPartyObj}, true);

        List<genesis__Credit_Rating_Matrix__c> creditMatrixList = FICOCalloutTestHelper.createAllCreditRatingMatrix();
        Database.insert(creditMatrixList, true);

    }

    /**
    * @description - This method queries and returns all the necessary data
    * @author Sk Minsar | 03-24-2025 
    * @param entityTypeList 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getDataMap(List<String> entityTypeList){
        List<genesis__Applications__c> applicationList = [SELECT Id, genesis__Contact__c, genesis__Account__c, Dealer_Applicant_Relationship__c, genesis__Credit_Rating__r.Name, Net_Worth__c, FICO_Score__c, SBSS_70_Score__c, genesis__Loan_Amount__c FROM genesis__Applications__c WHERE genesis__Account__r.clcommon__Legal_Entity_Type__r.Name In :entityTypeList LIMIT :PortalConstants.TEN_VALUE];
        List<Account> borrowerAccountList = [SELECT Id, Name, Phone, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c FROM Account WHERE Id =:applicationList[0].genesis__Account__c LIMIT 1];
        List<Contact> borrowerContactList = [SELECT Id, genesis__SSN__c FROM Contact WHERE AccountId =: borrowerAccountList[0].Id LIMIT 1];
        List<clcommon__Party__c> partyList = [SELECT Total_Assets__c, Total_Liabilities__c, Net_Worth__c, clcommon__Account__c, clcommon__Party_Types__c, clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name FROM clcommon__Party__c WHERE clcommon__Party_Types__c In (:ConstantValues.BORROWER_PARTY, :ConstantValues.PRINCIPAL_PARTY) AND genesis__Application__c In :applicationList];
        return new Map<String, Object>{
            KEY_APPLICATION_LIST => applicationList,
            KEY_BORROWER_ACCOUNT_LIST => borrowerAccountList,
            KEY_BORROWER_CONTACT_LIST => borrowerContactList,
            KEY_PARTY_LIST => partyList
        };
    }

    /**
    * @description - Delete CL Party
    * @author Sk Minsar | 04-04-2025 
    **/
    private static void deleteCLParty(){
        Account clAccountObj = [SELECT Id FROM Account WHERE Name =: CL_USER_NAME];
        Database.delete([SELECT Id FROM clcommon__Party__c WHERE clcommon__Account__c =: clAccountObj.Id LIMIT :PortalConstants.TEN_VALUE], true);
    }

    /**
    * @description - Get contact by entity type list
    * @author Sk Minsar | 04-07-2025 
    * @param entityTypeList 
    * @return List<Contact> 
    **/
    private static List<Contact> getContactByEntity(List<String> entityTypeList){
        return [SELECT Id, Name, genesis__SSN__c, Confirm_SSN__c FROM Contact WHERE Account.clcommon__Legal_Entity_Type__r.name = :entityTypeList LIMIT :PortalConstants.TEN_VALUE];
    }

    /**
    * @description - Get account by entity type list
    * @author Sk Minsar | 04-07-2025 
    * @param entityTypeList 
    * @return List<Account> 
    **/
    private static List<Account> getAccountByEntity(List<String> entityTypeList){
        return [SELECT Id, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c FROM Account WHERE clcommon__Legal_Entity_Type__r.name =:entityTypeList LIMIT :PortalConstants.TEN_VALUE];
    }
    
    /**
    * @description - Update networth
    * @author Sk Minsar | 04-04-2025 
    * @param partyList 
    * @param totalAssets 
    * @param totalLiabilities 
    **/
    private static void updateNetWorth(List<clcommon__Party__c> partyList, Decimal totalAssets, Decimal totalLiabilities){
        for(clcommon__Party__c partyObj: partyList){
            if(partyObj.clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name != INDIVIDUAL_ENTITY){
                partyObj.Total_Assets__c = totalAssets;
                partyObj.Total_Liabilities__c = totalLiabilities;
            }
        }
        Database.update(partyList, true);
    }

    
    /**
    * @description - Update score
    * @author Sk Minsar | 04-08-2025 
    * @param borrowerAccountList 
    * @param updateScoreMap 
    **/
    private static void updateScore(List<Account> borrowerAccountList, Map<String, Object> updateScoreMap){
        for(Account accountObj: borrowerAccountList){
            accountObj.Score_1__c = (String)updateScoreMap.get(KEY_FICO_SCORE);
            accountObj.SBSS70_Score__c = (String)updateScoreMap.get(KEY_SBSS_SCORE);
            accountObj.FICO_Recorded_On__c = (Datetime)updateScoreMap.get(KEY_FICO_RECORDED);
        }
        Database.update(borrowerAccountList, true);
    }

    /**
    * @description - Update application to Evergreen
    * @author Sk Minsar | 04-08-2025 
    * @param applicationList 
    **/
    private static void updateToEvergreen(List<genesis__Applications__c> applicationList){
        for(genesis__Applications__c applicationObj :applicationList){
            applicationObj.Is_Evergreen__c = PortalConstants.TRUE_VALUE;
        }
        Database.update(applicationList, true);
    }

    /**
    * @description - Test for sole prop application tier one
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForSolePropApplicationTierOne(){
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, applicationList[0].genesis__Loan_Amount__c * 5, PortalConstants.ZERO_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => ConstantValues.FICO_MAX_TIER_1,
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_1 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for sole prop application tier two
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForSolePropApplicationTierTwo(){
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, Integer.valueOf(applicationList[0].genesis__Loan_Amount__c) + PortalConstants.TEN_VALUE, PortalConstants.ZERO_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_2) + PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_2 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for sole prop application tier three
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForSolePropApplicationTierThree(){
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, Integer.valueOf(applicationList[0].genesis__Loan_Amount__c + PortalConstants.TEN_VALUE), PortalConstants.ZERO_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) + PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for sole prop application tier four negative net worth
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForSolePropApplicationTierFourNegativeNetWorth(){
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, PortalConstants.ZERO_VALUE, applicationList[0].genesis__Loan_Amount__c + PortalConstants.TEN_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) + PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for sole prop application tier four with fico score less than fico tier 3
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForSolePropApplicationTierFourLessFico(){
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, PortalConstants.ZERO_VALUE, applicationList[0].genesis__Loan_Amount__c + PortalConstants.TEN_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) - PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for sole prop application tier four with fico score less than sbss tier 3
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForSolePropApplicationTierFourLessSbss(){
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, PortalConstants.ZERO_VALUE, applicationList[0].genesis__Loan_Amount__c + PortalConstants.TEN_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) + PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3) - PortalConstants.TEN_VALUE),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for sole prop application with no existing scored borrower
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForSolePropApplicationWithNoScore(){
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, applicationList[0].genesis__Loan_Amount__c * 5, PortalConstants.ZERO_VALUE);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for duplicate sole prop account having score
    * @author Sk Minsar | 04-07-2025 
    **/
    @isTest
    static void testForDuplicateSolePropApplication(){
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        for(clcommon__Party__c party: partyList){
            if(party.clcommon__Party_Types__c == ConstantValues.PRINCIPAL_PARTY){
                party.genesis__Application__c = null;
            }
        }
        updateNetWorth(partyList, applicationList[0].genesis__Loan_Amount__c * 5, PortalConstants.ZERO_VALUE);
        List<Account> accountList = getAccountByEntity(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        updateScore(accountList, new Map<String, Object> {
            KEY_FICO_SCORE => ConstantValues.FICO_MAX_TIER_1,
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_1 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });
        List<Contact> contactList = getContactByEntity(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        for(Contact contactObj: contactList){
            contactObj.genesis__SSN__c = DUPLICATE_SSN;
            contactObj.Confirm_SSN__c = DUPLICATE_SSN;
        }
        Database.update(contactList, true);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for corporation application tier one
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForCorporationApplicationTierOne(){
        Map<String, Object> dataMap = getDataMap(new List<String>{PortalConstants.CORPORATION});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, applicationList[0].genesis__Loan_Amount__c * 5, PortalConstants.ZERO_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => ConstantValues.FICO_MAX_TIER_1,
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_1 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for corporation application tier two
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForCorporationApplicationTierTwo(){
        Map<String, Object> dataMap = getDataMap(new List<String>{PortalConstants.CORPORATION});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, Integer.valueOf(applicationList[0].genesis__Loan_Amount__c) + PortalConstants.TEN_VALUE, PortalConstants.ZERO_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_2) + PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_2 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });
        
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for corporation application tier three
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForCorporationApplicationTierThree(){
        Map<String, Object> dataMap = getDataMap(new List<String>{PortalConstants.CORPORATION});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, Integer.valueOf(applicationList[0].genesis__Loan_Amount__c + PortalConstants.TEN_VALUE), PortalConstants.ZERO_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) + PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for corporation application tier four negative net worth
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForCorporationApplicationTierFourNegativeNetWorth(){
        Map<String, Object> dataMap = getDataMap(new List<String>{PortalConstants.CORPORATION});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, PortalConstants.ZERO_VALUE, applicationList[0].genesis__Loan_Amount__c + PortalConstants.TEN_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) + PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for corporation application tier four with fico score less than fico tier 3
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForCorporationApplicationTierFourLessFico(){
        Map<String, Object> dataMap = getDataMap(new List<String>{PortalConstants.CORPORATION});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, PortalConstants.ZERO_VALUE, applicationList[0].genesis__Loan_Amount__c + PortalConstants.TEN_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) - PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for corporation application tier four with fico score less than sbss tier 3
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForCorporationApplicationTierFourLessSbss(){
        Map<String, Object> dataMap = getDataMap(new List<String>{PortalConstants.CORPORATION});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, PortalConstants.ZERO_VALUE, applicationList[0].genesis__Loan_Amount__c + PortalConstants.TEN_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) + PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3) - PortalConstants.TEN_VALUE),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for corporation application with no existing scored borrower
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForCorporationApplicationWithNoScore(){
        Map<String, Object> dataMap = getDataMap(new List<String>{PortalConstants.CORPORATION});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, applicationList[0].genesis__Loan_Amount__c * 5, PortalConstants.ZERO_VALUE);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for dba application tier one
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForDBAApplicationTierOne(){
        Map<String, Object> dataMap = getDataMap(new List<String>{INDIVIDUAL_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, applicationList[0].genesis__Loan_Amount__c * 5, PortalConstants.ZERO_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => ConstantValues.FICO_MAX_TIER_1,
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_1 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for dba application tier two
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForDBAApplicationTierTwo(){
        Map<String, Object> dataMap = getDataMap(new List<String>{INDIVIDUAL_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, Integer.valueOf(applicationList[0].genesis__Loan_Amount__c) + PortalConstants.TEN_VALUE, PortalConstants.ZERO_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_2) + PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_2 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for dba application tier three
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForDBAApplicationTierThree(){
        Map<String, Object> dataMap = getDataMap(new List<String>{INDIVIDUAL_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, Integer.valueOf(applicationList[0].genesis__Loan_Amount__c + PortalConstants.TEN_VALUE), PortalConstants.ZERO_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) + PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for dba application tier four negative net worth
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForDBAApplicationTierFourNegativeNetWorth(){
        Map<String, Object> dataMap = getDataMap(new List<String>{INDIVIDUAL_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, 0, applicationList[0].genesis__Loan_Amount__c + PortalConstants.TEN_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) + PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for dba application tier four with fico score less than fico tier 3
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForDBAApplicationTierFourLessFico(){
        Map<String, Object> dataMap = getDataMap(new List<String>{INDIVIDUAL_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, PortalConstants.ZERO_VALUE, applicationList[0].genesis__Loan_Amount__c + PortalConstants.TEN_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) - PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for dba application tier four for fico score less than sbss tier 3
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForDBAApplicationTierFourLessSbss(){
        Map<String, Object> dataMap = getDataMap(new List<String>{INDIVIDUAL_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, PortalConstants.ZERO_VALUE, applicationList[0].genesis__Loan_Amount__c + PortalConstants.TEN_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) + PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3) - PortalConstants.TEN_VALUE),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });
        
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for dba application with no existing scored borrower 
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForDBAApplicationWithNoScore(){
        Map<String, Object> dataMap = getDataMap(new List<String>{INDIVIDUAL_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, applicationList[0].genesis__Loan_Amount__c * 5, PortalConstants.ZERO_VALUE);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for Evergreen application tier one
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForEvergreenTierOne(){
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateToEvergreen(applicationList);
        updateNetWorth(partyList, applicationList[0].genesis__Loan_Amount__c * 5, PortalConstants.ZERO_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => ConstantValues.FICO_MAX_TIER_1,
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_1 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for Evergreen application tier two
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForEvergreenTierTwo(){
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateToEvergreen(applicationList);
        updateNetWorth(partyList, Integer.valueOf(applicationList[0].genesis__Loan_Amount__c) + PortalConstants.TEN_VALUE, PortalConstants.ZERO_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_2) + PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_2 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for evergreen application tier three
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForEvergreenTierThree(){
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateToEvergreen(applicationList);
        updateNetWorth(partyList, Integer.valueOf(applicationList[0].genesis__Loan_Amount__c + PortalConstants.TEN_VALUE), PortalConstants.ZERO_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) + PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for evergreen application tier four negative net worth
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForEvergreenTierFourNegativeNetWorth(){
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateToEvergreen(applicationList);
        updateNetWorth(partyList, PortalConstants.ZERO_VALUE, applicationList[0].genesis__Loan_Amount__c + PortalConstants.TEN_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) + PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for evergreen application tier four for fico score less than fico tier 3
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForEvergreenTierFourLessFico(){
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateToEvergreen(applicationList);
        updateNetWorth(partyList, PortalConstants.ZERO_VALUE, applicationList[0].genesis__Loan_Amount__c + PortalConstants.TEN_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) - PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for evergreen application tier four with fico score less than sbss tier 3
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForEvergreenTierFourLessSbss(){
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateToEvergreen(applicationList);
        updateNetWorth(partyList, PortalConstants.ZERO_VALUE, applicationList[0].genesis__Loan_Amount__c + PortalConstants.TEN_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => String.valueOf(Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) + PortalConstants.TEN_VALUE),
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3) - PortalConstants.TEN_VALUE),
            KEY_FICO_RECORDED => Date.today().addMonths(-1)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for sole prop application with seven month older scored
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForSolePropApplicatioForOlderScore(){
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        updateNetWorth(partyList, applicationList[0].genesis__Loan_Amount__c * 5, PortalConstants.ZERO_VALUE);
        List<Account> borrowerAccountList = (List<Account>)dataMap.get(KEY_BORROWER_ACCOUNT_LIST);
        updateScore(borrowerAccountList, new Map<String, Object>{
            KEY_FICO_SCORE => ConstantValues.FICO_MAX_TIER_1,
            KEY_SBSS_SCORE => String.valueOf(Integer.valueOf(ConstantValues.SBSS_MIN_TIER_1 + PortalConstants.TEN_VALUE)),
            KEY_FICO_RECORDED => Date.today().addMonths(-7)
        });

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for invalid application id
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testForInvalidApplicationId(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser(CL_USER_NAME);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize('klbdivh8r80whrvb9whvub')};

        System.runAs(userObj) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(null, response, ASSERTION_FAILED);
        }
    }

    /**
    * @description Test for missing application id
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testMissingAplicationId(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser(CL_USER_NAME);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => null};

        System.runAs(userObj) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(null, response, ASSERTION_FAILED);
        }
    }
    
    /**
    * @description - Test for invalid user 
    * @author Sk Minsar | 04-04-2025 
    **/
    @isTest
    public static void testInvalidUser(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser(CL_USER_NAME);
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        Map<String,Object> requestMap = new Map<String,Object>{KEY_APPLICATION => JSON.serialize(applicationList[0])};
        deleteCLParty();

        System.runAs(userObj) {
            Test.startTest();
                PortalScoreApplicationAPI testApi = new PortalScoreApplicationAPI();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(null, response, ASSERTION_FAILED);
        }
    }

}