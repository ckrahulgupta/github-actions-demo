/**
 * @description       : Test class for PortalSaveAccountDetails
 * @author            : Simran
 * @group             : 
 * @last modified on  : 02-15-2025
 * @last modified by  : Sk Minsar
**/
@isTest
public without sharing class PortalSaveAccountDetailsTest {

    private static final String BORROWER_LAST_NAME = 'Albin';
    private static final String CONTACT_KEY = 'contact';
    
    /**
    * @description - Create Test Data
    * @author Sk Minsar | 02-15-2025 
    **/
    @TestSetup
    static void setup(){

        //CREATING BUSINESS INFORMATION ---------------------------------------------------------------------------------------------
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{borrowerBusinessInfoObj, dealerBusinessInfoObj}, true);

        //CREATING REQUIRED LEGAL ENTITIES --------------------------------------------------------------------------------------
        clcommon__Legal_Entity__c solePropEntityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(solePropEntityObj, true);
        
        //CREATING FLOATING RATE INDEX ---------------------------------------------------------------------------------------------
        clcommon__Floating_Rate_Index__c floatingRateIndex = ApplicationOriginationTestHelper.createFloatingRateIndex('CFA_Advantage_Rate',11);
        Database.insert(floatingRateIndex, true);

        //CREATING PARTNER PROGRAM ---------------------------------------------------------------------------------------------
        CFA_Partner_Program__c partnerProgram = ApplicationOriginationTestHelper.createPartnerProgram(PortalConstants.LANDUS_COOP_TYPE,floatingRateIndex);
        partnerProgram.Short_Name__c = PortalConstants.CFA_COOP_TYPE;
        Database.insert(partnerProgram, true);

        //CREATING REQUIRED ACCOUNTS ---------------------------------------------------------------------------------------------
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id, partnerProgram.id);
        Database.insert(dealerAccountObj, true);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(solePropEntityObj,dealerBusinessInfoObj.Id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId();
        Database.insert(borrowerAccountObj, true);

        //CREATING REQUIRED CONTACTS ---------------------------------------------------------------------------------------------
        Contact dealerContactObj = ApplicationOriginationTestHelper.createDealerContact(dealerAccountObj.Id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);    
        Database.insert(new List<Contact>{dealerContactObj, borrowerContactObj},true);

        //CREATING DEALER APPLICANT RELATIONSHIPS ---------------------------------------------------------------------------------------------
        Dealer_Applicant_Relationship__c borrowerRealtionObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Database.insert(borrowerRealtionObj);

        //CREATING REQUIRED USERS ---------------------------------------------------------------------------------------------
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(borrowerUserObj, true);
    }

    /**
    * @description - Get Contact By Name
    * @author Sk Minsar | 02-15-2025 
    * @param contactName 
    * @return List<Contact> 
    **/
    private static List<Contact> getContactByName(String contactName){
        return [SELECT Id, 
                        Phone,
                        MobilePhone,
                        HomePhone,
                        FirstName,
                        ints__Middle_Name__c,
                        MailingStreet,
                        MailingCity,
                        MailingState,
                        MailingPostalCode,
                        Mailing_County__c,
                        Suffix__c,
                        clcommon__Marital_Status__c,
                        Email,
                        Confirm_Email__c,
                        genesis__SSN__c,
                        Confirm_SSN__c,
                        AccountId,
                        LastName
                FROM Contact 
                WHERE LastName = :contactName LIMIT 1];
    }

    /**
    * @description - Exception scenario
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @isTest
    public static void portalSaveAccountDetailsTestException() {
        User userObj = ApplicationOriginationTestHelper.getBorrowerUser(BORROWER_LAST_NAME);
        Map<String, Object>  requestMap= new Map<String, Object>();
        requestMap.put(CONTACT_KEY,null);
        
        System.runAs(userObj) {
            Test.startTest();
                PortalSaveAccountDetails testApi = new PortalSaveAccountDetails();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
        
    }
    /**
    * @description - Success scenario
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @isTest
    public static void portalSaveAccountDetailsTestSuccess() {
        User userObj = ApplicationOriginationTestHelper.getBorrowerUser(BORROWER_LAST_NAME);
        List<Contact> objContact = getContactByName(BORROWER_LAST_NAME);
        Map<String, Object>  requestMap= new Map<String, Object>();
        requestMap.put(CONTACT_KEY, JSON.serialize(objContact[0]));
        System.runAs(userObj) {
            Test.startTest();
                PortalSaveAccountDetails testApi = new PortalSaveAccountDetails();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test setAccountName for empty first and middle name
    * @author Sk Minsar | 02-15-2025 
    **/
    @isTest
    public static void testSetAccountNameEmptyName(){
        Map<String, Object>  requestMap= new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getBorrowerUser(BORROWER_LAST_NAME);
        List<Contact> objContact = getContactByName(BORROWER_LAST_NAME);
        objContact[0].FirstName = PortalConstants.EMPTY_STRING;
        objContact[0].ints__Middle_Name__c = PortalConstants.EMPTY_STRING;
        requestMap.put(CONTACT_KEY, JSON.serialize(objContact[0]));
        System.runAs(userObj){
            Test.startTest();
                PortalSaveAccountDetails testApi = new PortalSaveAccountDetails();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test setAccountName for not null first name, middle name and last name
    * @author Sk Minsar | 02-15-2025 
    **/
    @isTest
    public static void testSetAccountName(){
        Map<String, Object>  requestMap= new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getBorrowerUser(BORROWER_LAST_NAME);
        List<Contact> objContact = getContactByName(BORROWER_LAST_NAME);
        objContact[0].FirstName = BORROWER_LAST_NAME;
        objContact[0].ints__Middle_Name__c = BORROWER_LAST_NAME;
        requestMap.put(CONTACT_KEY, JSON.serialize(objContact[0]));
        System.runAs(userObj){
            Test.startTest();
                PortalSaveAccountDetails testApi = new PortalSaveAccountDetails();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test setAccountName for empty middle name
    * @author Sk Minsar | 02-15-2025 
    **/
    @isTest
    public static void testSetAccountNameEmptyMiddleName(){
        Map<String, Object>  requestMap= new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getBorrowerUser(BORROWER_LAST_NAME);
        List<Contact> objContact = getContactByName(BORROWER_LAST_NAME);
        objContact[0].ints__Middle_Name__c = PortalConstants.EMPTY_STRING;
        requestMap.put(CONTACT_KEY, JSON.serialize(objContact[0]));
        System.runAs(userObj){
            Test.startTest();
                PortalSaveAccountDetails testApi = new PortalSaveAccountDetails();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test setAccountName for empty first name
    * @author Sk Minsar | 02-15-2025 
    **/
    @isTest
    public static void testSetAccountNameEmptyFristName(){
        Map<String, Object>  requestMap= new Map<String, Object>();
        User userObj = ApplicationOriginationTestHelper.getBorrowerUser(BORROWER_LAST_NAME);
        List<Contact> objContact = getContactByName(BORROWER_LAST_NAME);
        objContact[0].FirstName = PortalConstants.EMPTY_STRING;
        objContact[0].ints__Middle_Name__c = BORROWER_LAST_NAME;
        requestMap.put(CONTACT_KEY, JSON.serialize(objContact[0]));
        System.runAs(userObj){
            Test.startTest();
                PortalSaveAccountDetails testApi = new PortalSaveAccountDetails();
                clcommon.Response response = testApi.invokeAction(PortalConstants.EMPTY_STRING, new List<String>(), requestMap);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
}