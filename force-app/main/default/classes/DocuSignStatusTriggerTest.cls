/**
 * @description       : Test class for DocuSignRecipientStatusTriggerTest
 * @author            : Simran
 * @group             : 
 * @last modified on  : 06-28-2024
 * @last modified by  : Krishanu Chinya
**/

@isTest
public class DocuSignStatusTriggerTest {

    @TestSetup
    static void makeData(){
     clcommon__Legal_Entity__c clEntity= ApplicationOriginationTestHelper.createCorporationLegalEntity();
     Database.insert(clEntity, true);
     
     // Creating Business Information
     genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
     Database.insert(dealerBusinessInfoObj, true);
 
     // Creating Account for Dealer
     Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
     Database.insert(dealerAccountObj, true);
 
     // Creating Account for Certified Lender
     Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
     Database.insert(clAccountObj, true);
 
     // Creating Contact for Certified Lender
     Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
     Database.insert(clContactObj,true);
 
     User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
     Database.insert(clUserObj, true);
 
     // Creating Legal Entity for Borrower
     clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
     Database.insert(entityObj, true);
 
     // Creating Account for Borrower
     Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, ApplicationOriginationTestHelper.createBusinessInfoForBorrower().Id);
     Database.insert(borrowerAccountObj, true);
 
     // Creating Contact for Borrower
     Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
     Database.insert(borrowerContactObj,true);
 
     // Creating User for Borrower
     User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
     Database.insert(borrowerUserObj, true);
 
     // Creating CL Purpose of Application
     clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
     Database.insert(clPurposeObj, true);
 
     // Creating Cl Product of Application
     clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
     Database.insert(clProductObj, true);
 
     // Creating map for Application
     Map<String,Id> paramForApplicationMap = new Map<String,Id>();
     paramForApplicationMap.put('dealerAccountId', dealerAccountObj.Id);
     paramForApplicationMap.put('clProductId', clProductObj.Id);
     paramForApplicationMap.put('clPurposeId', clPurposeObj.Id);
     paramForApplicationMap.put('borrowerAccountId', borrowerAccountObj.Id);
     paramForApplicationMap.put('borrowerContactId', borrowerContactObj.Id);
     paramForApplicationMap.put('clAccountId', clAccountObj.Id);
 
     // Creating Application
     genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
     applicationObj.DocuSign_Credit_Agreement_Initiated__c = false;
     applicationObj.Signing_Method__c = PortalConstants.EMAIL_DOCUSIGN;
     Database.insert(applicationObj, true);
 
     // Creating Reciprocal Role 
     clcommon__Reciprocal_Role__c roleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
     Database.insert(roleObj, true);
 
     // Creating Relationship between Dealer and Certified Lender
     clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,clAccountObj.Id,borrowerAccountObj.Id);
     Database.insert(clDealerRelationshipObj, true);
 
     // Creating Certified Lender Party Type
     clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
     Database.insert(clPartyTypeObj, true);
 
     // Creating Certified Lender Party
     Map<String,Id> paramForCLPartyMap = new Map<String,Id>();
     paramForCLPartyMap.put('accountId', clAccountObj.Id);
     paramForCLPartyMap.put('contactId', clContactObj.Id);
     paramForCLPartyMap.put('partyTypeId', clPartyTypeObj.Id);
     paramForCLPartyMap.put('applicationId', applicationObj.Id);
     clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(paramForCLPartyMap);
     Database.insert(clPartyObj, true);
 
     // Create Borrower Party Type
     clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
     Database.insert(borrowerPartyTypeObj, true);
 
     // Creating Borrower Party
     Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>();
     paramForBorrowerPartyMap.put('accountId', borrowerAccountObj.Id);
     paramForBorrowerPartyMap.put('contactId', borrowerContactObj.Id);
     paramForBorrowerPartyMap.put('partyTypeId', borrowerPartyTypeObj.Id);
     paramForBorrowerPartyMap.put('applicationId', applicationObj.Id);
     clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(paramForBorrowerPartyMap);
     Database.insert(borrowerPartyObj);
 
     dfsle__Envelope__c envelopeObj = new dfsle__Envelope__c();
     envelopeObj.dfsle__DocuSignId__c = '396205a3-d81e-4dc3-a11c-248f93f9f188';
     Database.insert(envelopeObj,true);
 
     dfsle__Recipient__c recipientObj = new dfsle__Recipient__c();
     recipientObj.dfsle__Email__c = borrowerContactObj.Email;
     recipientObj.dfsle__Role__c = 'Signer 1';
     recipientObj.dfsle__Envelope__c = envelopeObj.id;
     recipientObj.dfsle__SourceId__c = borrowerContactObj.id;
     Database.insert(recipientObj,true);
 
     dfsle__EnvelopeStatus__c envelopeStatus = new dfsle__EnvelopeStatus__c();
     envelopeStatus.dfsle__SourceId__c = applicationObj.id;
     envelopeStatus.dfsle__DocuSignId__c = '396205a3-d81e-4dc3-a11c-248f93f9f188';
     Database.insert(envelopeStatus,true);
     
 
    }
 
    @isTest
    public static void testRecipientSignedSentStatusForEmailDS() {
     Id accountId;
     Contact borrowerContactObj;
     genesis__Applications__c applicationObj = [Select id,genesis__Account__c from genesis__Applications__c Limit 1];
 
     List<Account> accountList = [SELECT Id FROM Account WHERE Id =: applicationObj.genesis__Account__c LIMIT 1];
     if(accountList.size() == 1){
         accountId = accountList[0].id;
     }
     List<Contact> contactList = [SELECT Id,Email FROM Contact WHERE AccountId =:accountId];
     if(contactList.size()==1){
         borrowerContactObj = contactList[0];
     }
     User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
     System.runAs(userObj){
         dfsle__EnvelopeStatus__c envelopeStatus = [Select id from dfsle__EnvelopeStatus__c Limit 1];
         dfsle__RecipientStatus__c recipientStatus = new dfsle__RecipientStatus__c();
         recipientStatus.dfsle__Status__c = PortalConstants.ENVELOPE_STATUS;
         recipientStatus.dfsle__EnvelopeStatus__c = envelopeStatus.id;
         recipientStatus.dfsle__Email__c = borrowerContactObj.Email;
         recipientStatus.dfsle__SourceId__c = borrowerContactObj.Id;
         Database.insert(recipientStatus,true);
     }
 
     List<clcommon__Party__c> partyList = [SELECT Id FROM clcommon__Party__c WHERE DocuSign_Signing_Status__c =: PortalConstants.PARTY_STATUS_PENDING LIMIT 1 ];
     System.assertEquals(partyList.size()==1, true,'Assertion Failed');
 
    }
 
    @isTest
    public static void testRecipientSignedCompleteStatusForEmailDS() {
     Id accountId;
     Contact borrowerContactObj;
     genesis__Applications__c applicationObj = [Select id,genesis__Account__c,Stage__c from genesis__Applications__c Limit 1];
     applicationObj.Stage__c = PortalConstants.APPLICANT_SIGNATURE;
     Database.update(applicationObj,true);
 
     List<Account> accountList = [SELECT Id FROM Account WHERE Id =: applicationObj.genesis__Account__c LIMIT 1];
     if(accountList.size() == 1){
         accountId = accountList[0].id;
     }
     List<Contact> contactList = [SELECT Id,Email FROM Contact WHERE AccountId =:accountId];
     if(contactList.size()==1){
         borrowerContactObj = contactList[0];
     }
     User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
     System.runAs(userObj){
         dfsle__EnvelopeStatus__c envelopeStatus = [Select id from dfsle__EnvelopeStatus__c Limit 1];
         dfsle__RecipientStatus__c recipientStatus = new dfsle__RecipientStatus__c();
         recipientStatus.dfsle__Status__c = PortalConstants.ENVELOPE_STATUS_COMPLETED;
         recipientStatus.dfsle__EnvelopeStatus__c = envelopeStatus.id;
         recipientStatus.dfsle__Email__c = borrowerContactObj.Email;
         recipientStatus.dfsle__SourceId__c = borrowerContactObj.Id;
         Database.insert(recipientStatus,true);
     }
     List<clcommon__Party__c> partyList = [SELECT Id FROM clcommon__Party__c WHERE DocuSign_Signing_Status__c =: PortalConstants.PARTY_STATUS_COMPLETED LIMIT 1 ];
     System.assertEquals(partyList.size()==1, true,'Assertion Failed');
    }
 
    @isTest
    public static void testRecipientSignedWithdrawStatusForEmailDS() {
     Id accountId;
     Contact borrowerContactObj;
     genesis__Applications__c applicationObj = [Select id,genesis__Account__c from genesis__Applications__c Limit 1];
 
     List<Account> accountList = [SELECT Id FROM Account WHERE Id =: applicationObj.genesis__Account__c LIMIT 1];
     if(accountList.size() == 1){
         accountId = accountList[0].id;
     }
     List<Contact> contactList = [SELECT Id,Email FROM Contact WHERE AccountId =:accountId];
     if(contactList.size()==1){
         borrowerContactObj = contactList[0];
     }
     User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
     System.runAs(userObj){
         dfsle__EnvelopeStatus__c envelopeStatus = [Select id from dfsle__EnvelopeStatus__c Limit 1];
         dfsle__RecipientStatus__c recipientStatus = new dfsle__RecipientStatus__c();
         recipientStatus.dfsle__Status__c = 'Withdrawn';
         recipientStatus.dfsle__EnvelopeStatus__c = envelopeStatus.id;
         recipientStatus.dfsle__Email__c = borrowerContactObj.Email;
         recipientStatus.dfsle__SourceId__c = borrowerContactObj.Id;
         Database.insert(recipientStatus,true);
     }
     List<clcommon__Party__c> partyList = [SELECT Id FROM clcommon__Party__c WHERE DocuSign_Signing_Status__c =: 'Withdrawn' LIMIT 1 ];
     System.assertEquals(partyList.size()==1, true,'Assertion Failed');
    }

    @isTest
    public static void testWithoutRecipientException() {
     Id accountId;
     Contact borrowerContactObj;
     genesis__Applications__c applicationObj = [Select id,genesis__Account__c from genesis__Applications__c Limit 1];
 
     List<Account> accountList = [SELECT Id FROM Account WHERE Id =: applicationObj.genesis__Account__c LIMIT 1];
     if(accountList.size() == 1){
         accountId = accountList[0].id;
     }
     List<Contact> contactList = [SELECT Id,Email FROM Contact WHERE AccountId =:accountId];
     if(contactList.size()==1){
         borrowerContactObj = contactList[0];
     }
     User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
     System.runAs(userObj){
         dfsle__EnvelopeStatus__c envelopeStatusObj = new dfsle__EnvelopeStatus__c();
         Database.insert(envelopeStatusObj,true);
         dfsle__RecipientStatus__c recipientStatus = new dfsle__RecipientStatus__c();
         recipientStatus.dfsle__Status__c = PortalConstants.ENVELOPE_STATUS;
         recipientStatus.dfsle__EnvelopeStatus__c = envelopeStatusObj.id;
         recipientStatus.dfsle__Email__c = borrowerContactObj.Email;
         recipientStatus.dfsle__SourceId__c = borrowerContactObj.Id;
         Database.insert(recipientStatus,true);
     }
     List<clcommon__Party__c> partyList = [SELECT Id FROM clcommon__Party__c WHERE DocuSign_Signing_Status__c =: PortalConstants.PARTY_STATUS_PENDING LIMIT 1 ];
     System.assertEquals(partyList.isEmpty(), true,'Assertion Failed');
 
    }

    @isTest
    public static void testRecipientSignedSentStatusForHybridDS() {
     Id accountId;
     Contact borrowerContactObj;
     genesis__Applications__c applicationObj = [Select id,genesis__Account__c from genesis__Applications__c Limit 1];
     applicationObj.Signing_Method__c = ConstantValues.IN_PERSON_HYBRID;
     Database.update(applicationObj, true);

 
     List<Account> accountList = [SELECT Id FROM Account WHERE Id =: applicationObj.genesis__Account__c LIMIT 1];
     if(accountList.size() == 1){
         accountId = accountList[0].id;
     }
     List<Contact> contactList = [SELECT Id,Email FROM Contact WHERE AccountId =:accountId];
     if(contactList.size()==1){
         borrowerContactObj = contactList[0];
     }
     User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
     System.runAs(userObj){
         dfsle__EnvelopeStatus__c envelopeStatus = [Select id from dfsle__EnvelopeStatus__c Limit 1];
         dfsle__RecipientStatus__c recipientStatus = new dfsle__RecipientStatus__c();
         recipientStatus.dfsle__Status__c = PortalConstants.ENVELOPE_STATUS;
         recipientStatus.dfsle__EnvelopeStatus__c = envelopeStatus.id;
         recipientStatus.dfsle__Email__c = borrowerContactObj.Email;
         recipientStatus.dfsle__SourceId__c = borrowerContactObj.Id;
         Database.insert(recipientStatus,true);
     }
 
     List<clcommon__Party__c> partyList = [SELECT Id FROM clcommon__Party__c WHERE DocuSign_Signing_Status__c =: PortalConstants.PARTY_STATUS_PENDING LIMIT 1 ];
     System.assertEquals(partyList.size()==1, true,'Assertion Failed');
 
    }
 
    @isTest
    public static void testRecipientSignedCompleteStatusForHybridDS() {
     Id accountId;
     Contact borrowerContactObj;
     genesis__Applications__c applicationObj = [Select id,genesis__Account__c,Stage__c from genesis__Applications__c Limit 1];
     applicationObj.Stage__c = PortalConstants.APPLICANT_SIGNATURE;
     applicationObj.Signing_Method__c = ConstantValues.IN_PERSON_HYBRID;
     Database.update(applicationObj, true);
 
     List<Account> accountList = [SELECT Id FROM Account WHERE Id =: applicationObj.genesis__Account__c LIMIT 1];
     if(accountList.size() == 1){
         accountId = accountList[0].id;
     }
     List<Contact> contactList = [SELECT Id,Email FROM Contact WHERE AccountId =:accountId];
     if(contactList.size()==1){
         borrowerContactObj = contactList[0];
     }
     User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
     System.runAs(userObj){
         dfsle__EnvelopeStatus__c envelopeStatus = [Select id from dfsle__EnvelopeStatus__c Limit 1];
         dfsle__RecipientStatus__c recipientStatus = new dfsle__RecipientStatus__c();
         recipientStatus.dfsle__Status__c = PortalConstants.ENVELOPE_STATUS_COMPLETED;
         recipientStatus.dfsle__EnvelopeStatus__c = envelopeStatus.id;
         recipientStatus.dfsle__Email__c = borrowerContactObj.Email;
         recipientStatus.dfsle__SourceId__c = borrowerContactObj.Id;
         Database.insert(recipientStatus,true);
     }
     List<clcommon__Party__c> partyList = [SELECT Id FROM clcommon__Party__c WHERE DocuSign_Signing_Status__c =: PortalConstants.PARTY_STATUS_COMPLETED LIMIT 1 ];
     System.assertEquals(partyList.size()==1, true,'Assertion Failed');
    }
 
    @isTest
    public static void testRecipientSignedWithdrawStatusForHybridDS() {
     Id accountId;
     Contact borrowerContactObj;
     genesis__Applications__c applicationObj = [Select id,genesis__Account__c from genesis__Applications__c Limit 1];
     applicationObj.Signing_Method__c = ConstantValues.IN_PERSON_HYBRID;
     Database.update(applicationObj, true);
 
 
     List<Account> accountList = [SELECT Id FROM Account WHERE Id =: applicationObj.genesis__Account__c LIMIT 1];
     if(accountList.size() == 1){
         accountId = accountList[0].id;
     }
     List<Contact> contactList = [SELECT Id,Email FROM Contact WHERE AccountId =:accountId];
     if(contactList.size()==1){
         borrowerContactObj = contactList[0];
     }
     User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
     System.runAs(userObj){
         dfsle__EnvelopeStatus__c envelopeStatus = [Select id from dfsle__EnvelopeStatus__c Limit 1];
         dfsle__RecipientStatus__c recipientStatus = new dfsle__RecipientStatus__c();
         recipientStatus.dfsle__Status__c = 'Withdrawn';
         recipientStatus.dfsle__EnvelopeStatus__c = envelopeStatus.id;
         recipientStatus.dfsle__Email__c = borrowerContactObj.Email;
         recipientStatus.dfsle__SourceId__c = borrowerContactObj.Id;
         Database.insert(recipientStatus,true);
     }
     List<clcommon__Party__c> partyList = [SELECT Id FROM clcommon__Party__c WHERE DocuSign_Signing_Status__c =: 'Withdrawn' LIMIT 1 ];
     System.assertEquals(partyList.size()==1, true,'Assertion Failed');
    }

    @isTest
    public static void testRecipientSignedSentStatusForInPersonDS() {
     Id accountId;
     Contact borrowerContactObj;
     genesis__Applications__c applicationObj = [Select id,genesis__Account__c from genesis__Applications__c Limit 1];
     applicationObj.Signing_Method__c = ConstantValues.IN_PERSON_DOCUSIGN;
    Database.update(applicationObj, true);
 
     List<Account> accountList = [SELECT Id FROM Account WHERE Id =: applicationObj.genesis__Account__c LIMIT 1];
     if(accountList.size() == 1){
         accountId = accountList[0].id;
     }
     List<Contact> contactList = [SELECT Id,Email FROM Contact WHERE AccountId =:accountId];
     if(contactList.size()==1){
         borrowerContactObj = contactList[0];
     }
     User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
     System.runAs(userObj){
         dfsle__EnvelopeStatus__c envelopeStatus = [Select id from dfsle__EnvelopeStatus__c Limit 1];
         dfsle__RecipientStatus__c recipientStatus = new dfsle__RecipientStatus__c();
         recipientStatus.dfsle__Status__c = PortalConstants.ENVELOPE_STATUS;
         recipientStatus.dfsle__EnvelopeStatus__c = envelopeStatus.id;
         recipientStatus.dfsle__Email__c = borrowerContactObj.Email;
         recipientStatus.dfsle__SourceId__c = borrowerContactObj.Id;
         Database.insert(recipientStatus,true);
     }
 
     List<clcommon__Party__c> partyList = [SELECT Id FROM clcommon__Party__c WHERE DocuSign_Signing_Status__c =: PortalConstants.PARTY_STATUS_PENDING LIMIT 1 ];
     System.assertEquals(partyList.size()==1, true,'Assertion Failed');
 
    }
 
    @isTest
    public static void testRecipientSignedCompleteStatusForInPersonDS() {
     Id accountId;
     Contact borrowerContactObj;
     genesis__Applications__c applicationObj = [Select id,genesis__Account__c,Stage__c from genesis__Applications__c Limit 1];
     applicationObj.Stage__c = PortalConstants.APPLICANT_SIGNATURE;
     applicationObj.Signing_Method__c = ConstantValues.IN_PERSON_DOCUSIGN;
     Database.update(applicationObj,true);
 
     List<Account> accountList = [SELECT Id FROM Account WHERE Id =: applicationObj.genesis__Account__c LIMIT 1];
     if(accountList.size() == 1){
         accountId = accountList[0].id;
     }
     List<Contact> contactList = [SELECT Id,Email FROM Contact WHERE AccountId =:accountId];
     if(contactList.size()==1){
         borrowerContactObj = contactList[0];
     }
     User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
     System.runAs(userObj){
         dfsle__EnvelopeStatus__c envelopeStatus = [Select id from dfsle__EnvelopeStatus__c Limit 1];
         dfsle__RecipientStatus__c recipientStatus = new dfsle__RecipientStatus__c();
         recipientStatus.dfsle__Status__c = PortalConstants.ENVELOPE_STATUS_COMPLETED;
         recipientStatus.dfsle__EnvelopeStatus__c = envelopeStatus.id;
         recipientStatus.dfsle__Email__c = borrowerContactObj.Email;
         recipientStatus.dfsle__SourceId__c = borrowerContactObj.Id;
         Database.insert(recipientStatus,true);
     }
     List<clcommon__Party__c> partyList = [SELECT Id FROM clcommon__Party__c WHERE DocuSign_Signing_Status__c =: PortalConstants.PARTY_STATUS_COMPLETED LIMIT 1 ];
     System.assertEquals(partyList.size()==1, true,'Assertion Failed');
    }
 
    @isTest
    public static void testRecipientSignedWithdrawStatusForInPersonDS() {
     Id accountId;
     Contact borrowerContactObj;
     genesis__Applications__c applicationObj = [Select id,genesis__Account__c from genesis__Applications__c Limit 1];
     applicationObj.Signing_Method__c = ConstantValues.IN_PERSON_DOCUSIGN;
     Database.update(applicationObj, true);
 
     List<Account> accountList = [SELECT Id FROM Account WHERE Id =: applicationObj.genesis__Account__c LIMIT 1];
     if(accountList.size() == 1){
         accountId = accountList[0].id;
     }
     List<Contact> contactList = [SELECT Id,Email FROM Contact WHERE AccountId =:accountId];
     if(contactList.size()==1){
         borrowerContactObj = contactList[0];
     }
     User userObj = [SELECT Id FROM USER Where Profile.Name = 'System Administrator' and IsActive = true Limit 1];
     System.runAs(userObj){
         dfsle__EnvelopeStatus__c envelopeStatus = [Select id from dfsle__EnvelopeStatus__c Limit 1];
         dfsle__RecipientStatus__c recipientStatus = new dfsle__RecipientStatus__c();
         recipientStatus.dfsle__Status__c = 'Withdrawn';
         recipientStatus.dfsle__EnvelopeStatus__c = envelopeStatus.id;
         recipientStatus.dfsle__Email__c = borrowerContactObj.Email;
         recipientStatus.dfsle__SourceId__c = borrowerContactObj.Id;
         Database.insert(recipientStatus,true);
     }
     List<clcommon__Party__c> partyList = [SELECT Id FROM clcommon__Party__c WHERE DocuSign_Signing_Status__c =: 'Withdrawn' LIMIT 1 ];
     System.assertEquals(partyList.size()==1, true,'Assertion Failed');
    }

    
}