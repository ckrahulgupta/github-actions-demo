/**
 * @description       : This is the test class for PortalFetchGrowerDetailsAPI.
 * @author            : Tuhin Bhunia
 * @group             : 
 * @last modified on  : 02-07-2025
 * @last modified by  : Sk Minsar
**/

@IsTest
public without sharing class PortalFetchGrowerDetailsAPITest {
    
    private static final String GROWER_SSN = 'GHFB6766';
    private static final String CFA_CL_NAME = 'Ross Geller';
    private static final String GMK_CL_NAME = 'Ross Geller GMK';
    private static final String CFA_SA_NAME = 'Tony Stark';
    private static final String KEY_MASKED_TIN = 'masked_tin';
    private static final String SSN_MISMATCH = 'Masked SSN should match for Sole Proprietorship entity.';
    
    /**
    * @description : Purpose of this method is to create the test data
    * @author Tuhin Bhunia | 04-11-2024 
    **/
    @TestSetup
    static void makeData(){

        // Creating Legal Entity
        Map<String, clcommon__Legal_Entity__c> legalEntityMap = ApplicationOriginationTestHelper.createMultipleLegalEntity();
        Database.Insert(new List<clcommon__Legal_Entity__c> {legalEntityMap.get(PortalConstants.INDIVIDUAL_ENTITY),legalEntityMap.get(PortalConstants.SOLE_PROP_ENTITY),legalEntityMap.get(PortalConstants.CORPORATION),legalEntityMap.get(PortalConstants.LIMITED_LIABILITY_COMPANY),legalEntityMap.get(PortalConstants.GENERAL_PARTNERSHIP),legalEntityMap.get(PortalConstants.LIMITED_PARTNERSHIP),legalEntityMap.get(PortalConstants.JOINT_VENTURE),legalEntityMap.get(PortalConstants.TRUST)}, true);

        // Creating Grower business info
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Map<String, genesis__Business_Information__c> businessInfoMap = ApplicationOriginationTestHelper.createMultipleBusinessInfo();
        Database.Insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj,businessInfoMap.get('individualBusinessInfoObj'),businessInfoMap.get('corporationBusinessInfoObj'),businessInfoMap.get('llcBusinessInfoObj'),businessInfoMap.get('jointVentureBusinessInfoObj'),businessInfoMap.get('trustBusinessInfoObj'),businessInfoMap.get('generalPartnerBusinessInfoObj'),businessInfoMap.get('limitedPartnerBusinessInfoObj'),businessInfoMap.get('dbaBusinessInfoObj')}, true);

        // Creating Accounts
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Account gmkDealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        gmkDealerAccountObj.Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.Insert(new List<Account>{dealerAccountObj, gmkDealerAccountObj}, true);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(null, dealerAccountObj.Id);
        Account gmkClAccountObj = ApplicationOriginationTestHelper.createCLAccount(null, dealerAccountObj.Id);
        Account saAccountObj= ApplicationOriginationTestHelper.createSalesAgentAccount(null,dealerAccountObj.Id);
        Account coApplicantAccount = ApplicationOriginationTestHelper.createCoBorrowerAccount(legalEntityMap.get(PortalConstants.SOLE_PROP_ENTITY),null);
        coApplicantAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.CO_APPLICATION_RECORD_TYPE).getRecordTypeId();
        coApplicantAccount.ParentId = dealerAccountObj.Id;
        gmkClAccountObj.Name = GMK_CL_NAME;
        Map<String, Account> accountMap = ApplicationOriginationTestHelper.createDifferentGrowerAccounts(legalEntityMap, businessInfoMap, dealerAccountObj.Id);
        Database.Insert(new List<Account> {clAccountObj, gmkClAccountObj, saAccountObj,coApplicantAccount, accountMap.get('solePropAccountObj'),accountMap.get('corporationAccountObj'),accountMap.get('llcAccountObj'),accountMap.get('generalPartnershipAccountObj'),accountMap.get('limitedPartnershipAccountObj'),accountMap.get('jointVentureAccountObj'),accountMap.get('trustAccountObj'),accountMap.get('dbaAccountObj')}, true);

        // Creating Contacts
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Contact gmkClContactObj = ApplicationOriginationTestHelper.createCLContact(gmkClAccountObj.Id);
        Contact saContactObj= ApplicationOriginationTestHelper.createSalesAgentContact(saAccountObj.Id);
        Contact coApplicantContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coApplicantAccount.Id);
        Contact solePropContactObj = ApplicationOriginationTestHelper.createBorrowerContact(accountMap.get('solePropAccountObj').Id);
        Contact dbaContactObj = ApplicationOriginationTestHelper.createContactForNonIndividuals(accountMap.get('dbaAccountObj'));
        Contact corporationContactObj = ApplicationOriginationTestHelper.createContactForNonIndividuals(accountMap.get('corporationAccountObj'));
        Contact llcContactObj = ApplicationOriginationTestHelper.createContactForNonIndividuals(accountMap.get('llcAccountObj'));
        Contact generalPartnerContactObj = ApplicationOriginationTestHelper.createContactForNonIndividuals(accountMap.get('generalPartnershipAccountObj'));
        Contact limitedPartnerContactObj = ApplicationOriginationTestHelper.createContactForNonIndividuals(accountMap.get('limitedPartnershipAccountObj'));
        Contact jointVentureContactObj = ApplicationOriginationTestHelper.createContactForNonIndividuals(accountMap.get('jointVentureAccountObj'));
        Contact trustContactObj = ApplicationOriginationTestHelper.createContactForNonIndividuals(accountMap.get('trustAccountObj'));
        trustContactObj.New_Email__c = 'lawrence.foundation150@yopmail.com'; 
        Database.Insert(new List<Contact> {gmkClContactObj, clContactObj,saContactObj,coApplicantContactObj,solePropContactObj,dbaContactObj,corporationContactObj,llcContactObj,generalPartnerContactObj,limitedPartnerContactObj,jointVentureContactObj,trustContactObj}, true);

        // Creating Reciprocal Roles
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.CERTIFIED_LENDER);
        Database.Insert(clRoleObj, true);

        // Creating Relationships
        clcommon__Relationship__c clDealerRealtionshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.Insert(clDealerRealtionshipObj, true);

        Dealer_Applicant_Relationship__c coApplicantRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(coApplicantContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c soleRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(solePropContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c gmkSoleRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(solePropContactObj,gmkDealerAccountObj.Id);
        Dealer_Applicant_Relationship__c dbaRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(dbaContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c corporationRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(corporationContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c llcRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(llcContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c gpRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(generalPartnerContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c lpRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(limitedPartnerContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c jvRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(jointVentureContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c trusRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(trustContactObj,dealerAccountObj.Id);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{coApplicantRelationObj, soleRelationObj, gmkSoleRelationObj, dbaRelationObj, corporationRelationObj, llcRelationObj, gpRelationObj, lpRelationObj, jvRelationObj, trusRelationObj });

        // Creating User
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        User gmkClUserObj = ApplicationOriginationTestHelper.createCLUser(gmkClContactObj.Id);
        User saUserObj=ApplicationOriginationTestHelper.createSalesAgentUser(saContactObj.Id);
        gmkClUserObj.UserName='ross.gellergmk@yopmail.com';
        Database.insert(new List<User>{gmkClUserObj, clUserObj,saUserObj},true);
    }

    /**
    * @description : This method deletes account and contacts of all growers except the one given in the where clause
    * @author Tuhin Bhunia | 04-16-2024 
    * @param accName
    **/
    private static void deleteAllGrowerExcept(String accName){
        
        List<Contact> contactList = [SELECT Id
                                    FROM Contact
                                    WHERE Account.RecordType.Name IN   (:PortalConstants.GROWER_PROFILE, 
                                                                        :PortalConstants.CO_APPLICATION_RECORD_TYPE)
                                    AND Account.Name != :accName];
        Database.Delete(contactList, true);

        List<Account> accountList =    [SELECT Id 
                                        FROM Account
                                        WHERE RecordType.Name IN (:PortalConstants.GROWER_PROFILE, 
                                                                :PortalConstants.CO_APPLICATION_RECORD_TYPE)
                                        AND Name != :accName];
        Database.Delete(accountList, true);
    }
    
    /**
    * @description Retrieves a list of grower contacts based on the provided SSN.
    * @author Rahul Gorai | 01-10-2025 
    * @param ssn 
    * @return List<Contact> 
    **/
    private static List<Contact> getGrowerContact(String ssn) {
        
        return  [SELECT Id, 
                         Email, 
                         New_Email__c,
                         MobilePhone,
                         Account.CIF_Number__c,
                         Account.Name,
                         Account.clcommon__Legal_Entity_Type__c,
                         Account.clcommon__Legal_Entity_Type__r.Name,
                         (SELECT Id,
                                 Is_Evergreen_Eligible__c
                         FROM Dealer_Applicant_Relationships__r
                         LIMIT 1)
                FROM Contact
                WHERE genesis__SSN__c = :ssn
                LIMIT 1];
    }

    /**
    * @description Retrieves a list of Sole Prop grower contacts based on the provided SSN.
    * @author Sk Minsar | 02-07-2025 
    * @param ssn 
    * @return List<Contact> 
    **/
    private static List<Contact> getSolePropContact(String ssn){
        return [SELECT Id, 
                        Email, 
                        New_Email__c,
                        MobilePhone,
                        Account.CIF_Number__c,
                        Account.Name,
                        Account.clcommon__Legal_Entity_Type__r.Name,
                        Masked_SSN__c,
                        (SELECT Id,
                            Is_Evergreen_Eligible__c
                        FROM Dealer_Applicant_Relationships__r
                        LIMIT 1)
                FROM Contact
                WHERE genesis__SSN__c = :ssn
                AND (Account.clcommon__Legal_Entity_Type__r.Name = :PortalConstants.SOLE_PROP_ENTITY)
                LIMIT 1];
    }

    /**
    * @description : Success scenario - Fetching all the growers.
    * @author Tuhin Bhunia | 04-11-2024 
    **/
    @isTest
    private static void fetchAllGrowersWithSuccess(){

        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser(CFA_CL_NAME);
        
        if(clUserObj != null){
            System.runAs(clUserObj){
                Test.startTest();
                PortalFetchGrowerDetailsAPI fetchGrowerDetailsAPIInst = new PortalFetchGrowerDetailsAPI();
                clcommon.Response response = fetchGrowerDetailsAPIInst.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), new Map<String, Object>());
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
                
            }
        }
    }

    /**
    * @description : Success Scenario - Returns empty response if there is no grower under a particular dealer.
    * @author Tuhin Bhunia | 04-16-2024 
    **/
    @isTest
    private static void noGrowerFoundScenarioSuccess(){

    User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser(CFA_CL_NAME);

        List<Contact> allGrowerContactList =   [SELECT Id
                                                FROM Contact
                                                WHERE Account.RecordType.Name = :PortalConstants.GROWER_PROFILE];
        Database.Delete(allGrowerContactList, true);

        List<Account> allGrowerAccountList =   [SELECT Id 
                                                FROM Account
                                                WHERE RecordType.Name = :PortalConstants.GROWER_PROFILE];
        Database.Delete(allGrowerAccountList, true);

        if(clUserObj != null){
            System.runAs(clUserObj){
                Test.startTest();
                PortalFetchGrowerDetailsAPI fetchGrowerDetailsAPIInst = new PortalFetchGrowerDetailsAPI();
                clcommon.Response response = fetchGrowerDetailsAPIInst.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), new Map<String, Object>());
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Success Scenario - Fetching Individual Entity type Grower.
    * @author Tuhin Bhunia | 04-16-2024 
    **/
    @isTest
    private static void fetchIndividualEntityGrowerWithSuccess(){

        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser(CFA_CL_NAME);

        deleteAllGrowerExcept('Jasmine Albin'); 

        if(clUserObj != null){
            System.runAs(clUserObj){
                Test.startTest();
                PortalFetchGrowerDetailsAPI fetchGrowerDetailsAPIInst = new PortalFetchGrowerDetailsAPI();
                clcommon.Response response = fetchGrowerDetailsAPIInst.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), new Map<String, Object>());
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Success Scenario - Trying to Fetch DBA Entity type Grower. It'll return empty response.
    * @author Tuhin Bhunia | 04-16-2024 
    **/
    @isTest
    private static void fetchDBAEntityGrowerWithSuccess(){

        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser(CFA_CL_NAME);

        deleteAllGrowerExcept('Farm to table'); // deleting all grower's contact and account Except the DBA entity type grower

        if(clUserObj != null){
            System.runAs(clUserObj){
                Test.startTest();
                PortalFetchGrowerDetailsAPI fetchGrowerDetailsAPIInst = new PortalFetchGrowerDetailsAPI();
                clcommon.Response response = fetchGrowerDetailsAPIInst.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), new Map<String, Object>());
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Success Scenario - Fetching Trust Entity type Grower.
    * @author Tuhin Bhunia | 04-16-2024 
    **/
    @isTest
    private static void fetchTrustEntityGrowerWithSuccess(){
        
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser(CFA_CL_NAME);

        deleteAllGrowerExcept('Johny Lawrence Foundation'); // deleting all grower's contact and account Except the Trust entity type grower

        if(clUserObj != null){
            System.runAs(clUserObj){
                Test.startTest();
                PortalFetchGrowerDetailsAPI fetchGrowerDetailsAPIInst = new PortalFetchGrowerDetailsAPI();
                clcommon.Response response = fetchGrowerDetailsAPIInst.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), new Map<String, Object>());
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Success Scenario - Fetching Co-Applicants.
    * @author Tuhin Bhunia | 04-16-2024 
    **/
    @isTest
    private static void fetchCoApplicantWithSuccess(){

        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser(CFA_CL_NAME);

        deleteAllGrowerExcept('Mike Johnson'); // deleting all grower's contact and account Except the CoApplicant

        if(clUserObj != null){
            System.runAs(clUserObj){
                Test.startTest();
                PortalFetchGrowerDetailsAPI fetchGrowerDetailsAPIInst = new PortalFetchGrowerDetailsAPI();
                clcommon.Response response = fetchGrowerDetailsAPIInst.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), new Map<String, Object>());
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Success Scenario - Fetching Corporation type Grower.
    * @author Tuhin Bhunia | 04-16-2024 
    **/
    @isTest
    private static void fetchCorporationEntityGrowerWithSuccess(){

        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser(CFA_CL_NAME);

        deleteAllGrowerExcept('Green Crops Pvt. Ltd.'); // deleting all grower's contact and account Except the Corporation entity type grower

        if(clUserObj != null){
            System.runAs(clUserObj){
                Test.startTest();
                PortalFetchGrowerDetailsAPI fetchGrowerDetailsAPIInst = new PortalFetchGrowerDetailsAPI();
                clcommon.Response response = fetchGrowerDetailsAPIInst.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), new Map<String, Object>());
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Exception Scenario - Logged In User's Parent ID is null.
    * @author Tuhin Bhunia | 04-16-2024 
    **/
    @isTest
    private static void parentIdMissingExceptionScenario(){

        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser(CFA_CL_NAME);

        List<Account> clAccountList = [SELECT Id, 
                                                Name,
                                                ParentId
                                        FROM Account 
                                        WHERE Id IN (SELECT AccountId 
                                                    FROM User 
                                                    WHERE Id = :clUserObj.Id)
                                        LIMIT 1];
        clAccountList[0].ParentId = null;
        Database.Update(clAccountList[0], true);
        if(clUserObj!=null){
            System.runAs(clUserObj){
                Test.startTest();
                PortalFetchGrowerDetailsAPI fetchGrowerDetailsAPIInst = new PortalFetchGrowerDetailsAPI();
                clcommon.Response response = fetchGrowerDetailsAPIInst.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), new Map<String, Object>());
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }
    /**
    * @description Exception Scenario - Logged In User's Account ID is null.
    * @author Rahul Gorai | 01-08-2025 
    **/
    @isTest
    private static void accountIdMissingExceptionScenario(){

        User userObj = [SELECT AccountId 
                        FROM User 
                        WHERE AccountId=null 
                        LIMIT 1];
        
        if(userObj!=null){
            System.runAs(userObj){
                Test.startTest();
                PortalFetchGrowerDetailsAPI fetchGrowerDetailsAPIInst = new PortalFetchGrowerDetailsAPI();
                clcommon.Response response = fetchGrowerDetailsAPIInst.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), new Map<String, Object>());
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
                
            }
        }
            
    }
    /**
    * @description  Success Scenario- Validating Email Change in Progress for different email of Borrower
    * @author Rahul Gorai | 01-08-2025 
    **/
    @isTest
    private static void testBorrowerDifferentEmailSuccessScenario(){
        
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser(CFA_CL_NAME);
        
        List<Contact> borrowerContactList = getGrowerContact(GROWER_SSN);
        borrowerContactList[0].Email = 'originalemail@example.com';
        borrowerContactList[0].New_Email__c= 'newemail@example.com';

        Database.Update(borrowerContactList[0], true);
        
        if(clUserObj != null){
                System.runAs(clUserObj){
                    Test.startTest();
                    Map<String, Object> growerDetailsMap = PortalFetchGrowerDetailsAPI.createCommonGrowerDataMap(borrowerContactList[0]);
                    System.assertEquals(PortalConstants.EMAIL_CHANGE_IN_PROGRESS_STATUS, growerDetailsMap.get(PortalConstants.KEY_STATUS), 'The status should be EMAIL_CHANGE_IN_PROGRESS_STATUS when New_Email__c is not null and differs from Email.');
                    Test.stopTest();
                    
                }
        }
    }
    /**
    * @description Exception Scenario- Validating Blank Status  for Same Email of Borrower
    * @author Rahul Gorai | 01-08-2025 
    **/
    @isTest
    private static void testBorrowerSameEmailExceptionScenario(){

        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser(CFA_CL_NAME);
        
        List<Contact> borrowerContactList = getGrowerContact(GROWER_SSN);
        borrowerContactList[0].Email = 'originalemail1@example.com';
        borrowerContactList[0].New_Email__c= 'originalemail1@example.com';

        Database.Update(borrowerContactList[0], true);
        
        if(clUserObj != null){
                System.runAs(clUserObj){
                    Test.startTest();
                    Map<String, Object> growerDetailsMap = PortalFetchGrowerDetailsAPI.createCommonGrowerDataMap(borrowerContactList[0]);
                    System.assertEquals(PortalConstants.EMPTY_STRING, growerDetailsMap.get(PortalConstants.KEY_STATUS), 'Status should be blank when New_Email__c equals Email.');
                    Test.stopTest();
                    
                }
        }
    }
    /**
    * @description Success Scenario- Validating No Pending Action for Null New Email of Borrower
    * @author Rahul Gorai | 01-08-2025 
    **/
    @isTest
    private static void testBorrowerNullNewEmailSuccessScenario() {
        
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser(CFA_CL_NAME);
        List<Contact> borrowerContactList = getGrowerContact(GROWER_SSN);   
        borrowerContactList[0].New_Email__c= null;
        Database.Update(borrowerContactList[0], true);
        if(clUserObj != null){
            System.runAs(clUserObj){
                Test.startTest();
                Map<String, Object> growerDetailsMap = PortalFetchGrowerDetailsAPI.createCommonGrowerDataMap(borrowerContactList[0]);
                System.assertEquals(PortalConstants.NO_PENDING_ACTION, growerDetailsMap.get(PortalConstants.KEY_STATUS), 
                'The status should be NO_PENDING_ACTION when New_Email__c is null.');
                Test.stopTest();
                
            }
        }
    }

    
    /**
    * @description Success Scenario- Verify that createGrowerDetailsMap correctly sets masked tin for Sole Proprietorship growers.
    * @author Rahul Gorai | 01-09-2025 
    **/
    @isTest
    private static void testSuccessMappingSoleProp() {

        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser(CFA_CL_NAME);
        List<Contact> solePropContactList = getSolePropContact(GROWER_SSN);

        if(clUserObj != null){
            System.runAs(clUserObj){                       
                Test.startTest();
                Map<String, Object> solePropDetailsMap = PortalFetchGrowerDetailsAPI.createGrowerDetailsMap(solePropContactList[0]);
                System.assertEquals(
                    solePropContactList[0].Masked_SSN__c, 
                    solePropDetailsMap.get(KEY_MASKED_TIN), SSN_MISMATCH
                );
                Test.stopTest();
                
            }
        }
    }


    /**
    * @description Success Scenario- Verify that createGrowerDetailsMap correctly sets masked tin for Growmark Sole Proprietorship growers.
    * @author Sk Minsar | 02-07-2025 
    **/
    @isTest
    private static void testSuccessMappingGmkSoleProp() {

        User gmkClUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser(GMK_CL_NAME);  
        List<Contact> solePropContactList = getSolePropContact(GROWER_SSN);

        if(gmkClUserObj != null){
            System.runAs(gmkClUserObj){                       
                Test.startTest();
                Map<String, Object> solePropDetailsMap = PortalFetchGrowerDetailsAPI.createGrowerDetailsMap(solePropContactList[0]);
                System.assertEquals(
                    solePropContactList[0].Masked_SSN__c, 
                    solePropDetailsMap.get(KEY_MASKED_TIN), SSN_MISMATCH
                );
                Test.stopTest();
                
            }
        }
    }
    
    /**
    * @description Success scenario - Fetching all the growers for sales agent
    * @author Rahul Gorai | 01-09-2025 
    **/
    @isTest
    private static void fetchGrowerDetailsForSalesAgentWithSuccess(){
        
        User saUserObj = ApplicationOriginationTestHelper.getUserByUserName(CFA_SA_NAME); 
        
        if(saUserObj != null){
            System.runAs(saUserObj){
                Test.startTest();
                PortalFetchGrowerDetailsAPI fetchGrowerDetailsAPIInst = new PortalFetchGrowerDetailsAPI();
                clcommon.Response response = fetchGrowerDetailsAPIInst.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), new Map<String, Object>());
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
                
            }
        }
    }
}