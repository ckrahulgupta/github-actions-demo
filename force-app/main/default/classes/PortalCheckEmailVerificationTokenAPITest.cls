/**
 * @description       : 
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 10-01-2025
 * @last modified by  : Soumik Pattanayak
**/
@isTest
public without sharing class PortalCheckEmailVerificationTokenAPITest {
    
    @testSetup
    static void setup(){
        // creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);
    
        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);
    
        // creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);

        // creating user for certified lender
        User clUser = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        Database.insert(clUser, true);

        clcommon__Reciprocal_Role__c clRole = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(clRole,true);

        clcommon__Relationship__c clRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(clRole,dealerAccountObj.id,clAccountObj.id);
        Database.insert(clRelationship,true);

        //CREATING BORROWER
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(legalEntityObj,true);

        //creating business information of the borrower
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);

        //creating a borrower account
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        borrowerAccountObj.CIF_Number__c = '123456';
        borrowerAccountObj.ParentId = dealerAccountObj.Id;
        borrowerAccountObj.Coop_Type__c = 'CFA';
        Database.insert(borrowerAccountObj,true);

        //creating a borrower contact
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        borrowerContactObj.New_Email__c = 'albin.jasmine@yopmail.com';
        borrowerContactObj.genesis__SSN__c = '867017636';
        borrowerContactObj.Verification_Attempt__c = 0;
        Database.insert(borrowerContactObj,true);

        //creating a borrower user
        User borrowerUser = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(borrowerUser,true);

        //creating cl product for application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        //creating cl purpose for the application
        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);

        Dealer_Applicant_Relationship__c relationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Database.insert(relationObj,true);

        //creating application
        Map<String,Id> applicationDataMap = new Map<String,Id>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'clAccountObjId' => clAccountObj.id,
            'dealerApplicantRelationshipId' => relationObj.Id
        };
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(applicationDataMap);
        applicationObj.genesis__Product_Type__c ='Package';
        Database.insert(applicationObj,true); 

        //creating parties in the application
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(clPartyTypeObj,true);

        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(borrowerPartyTypeObj,true);

        Map<String,Id> partyParamMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => borrowerPartyTypeObj.id,
            'applicationId' => applicationObj.id,
            'dealerApplicantRelationshipId' => relationObj.Id
        };
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(partyParamMap);
        Database.insert(partyObj,true);

        Map<String,Id> clpartyParamMap = new Map<String,Id>{
            'accountId' => clAccountObj.id,
            'contactId' => clContactObj.id,
            'partyTypeId' => clPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(clpartyParamMap);
        clPartyObj.clcommon__Party_Types__c = PortalConstants.CERTIFIED_LENDER;
        Database.insert(clPartyObj,true);

        clcommon__Legal_Entity__c corpLegalEntityObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(corpLegalEntityObj,true);

        CFA_Configuration__c credentialParameter = ApplicationOriginationTestHelper.createEmailChangeDecryptionConfig();
        Database.insert(credentialParameter,true);

    }

    /**
    * @description : generates the jwt token for email verification
    * @author Krishanu Chinya | 04-11-2024 
    * @param ssn 
    * @return String 
    **/
    private static String generateToken(String ssn){
        List<Contact> testContactList = [SELECT Id,
                                        Email,
                                        New_Email__c,
                                        Account.Coop_Type__c,
                                        Verification_Attempt__c,
                                        Account.clcommon__Legal_Entity_Type__r.Name
                                    FROM Contact
                                    WHERE genesis__SSN__c =: ssn];
        //creating the token
        Map<String, String> payloadMap = new Map<String, String> {
            'prev_email' => testContactList[0].Email,
            'new_email' => testContactList[0].New_Email__c,
            'contactId' => testContactList[0].Id,
            'coopType' => testContactList[0].Account.Coop_Type__c,
            'legalEntityType' => testContactList[0].Account.clcommon__Legal_Entity_Type__r.Name,
            'attemptNum' => String.valueOf(testContactList[0].Verification_Attempt__c)
        };
        String jwtToken = JWTUtil.generateEmailVerificationToken(payloadMap);
        return jwtToken;
    }

    /**
    * @description : trying to verify the email change of an individual
    * @author Krishanu Chinya | 04-11-2024 
    **/
    @isTest
    static void testForAValidToken() {
        User guestGrowerUser = ApplicationOriginationTestHelper.fetchGrowerPortalGuestUser();

        String token = generateToken('867017636');

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'token' => token
        };

        System.runAs(guestGrowerUser) {
            Test.startTest();
            PortalCheckEmailVerificationTokenAPI api = new PortalCheckEmailVerificationTokenAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : if email values are changed from backend after sending email verification link
    * @author Krishanu Chinya | 04-11-2024 
    **/
    @isTest
    static void testForExhaustedAttempt() {
        User guestGrowerUser = ApplicationOriginationTestHelper.fetchGrowerPortalGuestUser();

        String token = generateToken('867017636');

        List<Contact> testContactList = [SELECT Id,
                                        AccountId,
                                        Verification_Attempt__c,
                                        Account.clcommon__Legal_Entity_Type__r.Name
                                    FROM Contact
                                    WHERE genesis__SSN__c = '867017636'];
        testContactList[0].Verification_Attempt__c = 20;
        Database.update(testContactList[0], true);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'token' => token
        };

        System.runAs(guestGrowerUser) {
            Test.startTest();
            PortalCheckEmailVerificationTokenAPI api = new PortalCheckEmailVerificationTokenAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    @isTest
    static void testWithTamperedToken() {
        User guestGrowerUser = ApplicationOriginationTestHelper.fetchGrowerPortalGuestUser();

        //String token = generateToken('867017636');
        //token = token + 'randomString';

        List<Contact> testContactList = [SELECT Id,
                                        Email,
                                        New_Email__c,
                                        Account.Coop_Type__c,
                                        Verification_Attempt__c,
                                        Account.clcommon__Legal_Entity_Type__r.Name
                                    FROM Contact
                                    WHERE genesis__SSN__c =  '867017636'];
        //creating the token
        Map<String, String> payloadMap = new Map<String, String> {
            'prev_email' => testContactList[0].Email,
            'new_email' => testContactList[0].New_Email__c,
            'contactId' => '976453khihisfiu',
            'coopType' => testContactList[0].Account.Coop_Type__c,
            'legalEntityType' => testContactList[0].Account.clcommon__Legal_Entity_Type__r.Name,
            'attemptNum' => String.valueOf(testContactList[0].Verification_Attempt__c)
        };
        String token = JWTUtil.generateEmailVerificationToken(payloadMap);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'token' => token
        };

        System.runAs(guestGrowerUser) {
            Test.startTest();
            PortalCheckEmailVerificationTokenAPI api = new PortalCheckEmailVerificationTokenAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    @isTest
    static void testWithNullArgument(){
        User guestGrowerUser = ApplicationOriginationTestHelper.fetchGrowerPortalGuestUser();

        String token = generateToken('867017636');
        token = token + 'randomString';

        System.runAs(guestGrowerUser) {
            Test.startTest();
            PortalCheckEmailVerificationTokenAPI api = new PortalCheckEmailVerificationTokenAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, null);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }
}