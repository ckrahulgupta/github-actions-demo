/**
 * @description       : Test class for DocuSignviaEmail
 * @author            :  Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 03-11-2025
 * @last modified by  : Kabir Pramanik
**/

@isTest
public with sharing class DocuSignviaEmailTest {
  private static final String ASSERTION_FAILED = 'Assertion failed';
  /**
  * @description Creating test data
  * @author Kabir Pramanik | 03-10-2025 
  **/
  @testSetup
  static void makeData(){
    clcommon__Legal_Entity__c solePropLegalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
    clcommon__Legal_Entity__c corpLegalEntityObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
    clcommon__Legal_Entity__c dbaLegalEntityObj  = ApplicationOriginationTestHelper.createDBALegalEntity();
    Database.insert(new List<clcommon__Legal_Entity__c>{solePropLegalEntityObj, corpLegalEntityObj, dbaLegalEntityObj}, true);

    // Creating Business Information
    genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
    genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
    genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
    Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj, borrowerBusinessInfoObj, coBorrowerBusinessInfoObj}, true);

    // Creating Account for Dealer, CL, Borrower and Co-Applicants
    Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
    Database.insert(dealerAccountObj, true);
    Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
    Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(solePropLegalEntityObj, dealerBusinessInfoObj.Id);
    Account principalAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(solePropLegalEntityObj, dealerBusinessInfoObj.Id);
    Account principalAccountObjTwo = ApplicationOriginationTestHelper.createCoBorrowerAccount(solePropLegalEntityObj, dealerBusinessInfoObj.Id);
    Database.insert(new List<Account>{clAccountObj, borrowerAccountObj, principalAccountObj, principalAccountObjTwo},true);

    // Creating Contact for Certified Lender, Borrower and Coapplicant
    Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
    Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
    Contact principalContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(principalAccountObj.id);
    Contact principalContactObjTwo = ApplicationOriginationTestHelper.createCoBorrowerContact(principalAccountObjTwo.id);
    Database.insert(new List<Contact>{clContactObj, borrowerContactObj, principalContactObj, principalContactObjTwo}, true);

    User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
    Database.insert(clUserObj, true);

    // Creating CL Purpose of Application
    clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
    Database.insert(clPurposeObj, true);

    // Creating Cl Product of Application
    clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
    Database.insert(clProductObj, true);
    
    genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(new Map<String, Id>{
      'dealerAccountObjId' => dealerAccountObj.id,
      'clProductObjId' => clProductObj.id,
      'clPurposeObjId' => clPurposeObj.id,
      'borrowerAccountObjId' => borrowerAccountObj.id,
      'borrowerContactObjId' => borrowerContactObj.id
    });
    applicationObj.Signing_Method__c = ConstantValues.EMAIL_DOCUSIGN;
    Database.insert(applicationObj, true);

    clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(ConstantValues.CL_PARTY_NAME);
    clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(ConstantValues.BORROWER_PARTY);
    clcommon__Party_Type__c principalPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(ConstantValues.PRINCIPAL_PARTY);
    Database.insert(new List<clcommon__Party_Type__c>{clPartyTypeObj, borrowerPartyTypeObj, principalPartyTypeObj}, true);
    
    // Creating Certified Lender Party
    Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
      'accountId' => clAccountObj.Id,
      'contactId' => clContactObj.Id,
      'partyTypeId' => clPartyTypeObj.Id,
      'applicationId' => applicationObj.Id
    };
    clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(paramForCLPartyMap);

    // Creating Borrower Party
    Map<String,Id> paramBorrowerPartyMap = new Map<String,Id>{
      'accountId' => borrowerAccountObj.Id,
      'contactId' => borrowerContactObj.Id,
      'partyTypeId' => borrowerPartyTypeObj.Id,
      'applicationId' => applicationObj.Id
    };
    clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(paramBorrowerPartyMap);

    // Creating Co Borrower Party
    Map<String,Id> paramPrincipalPartyMap = new Map<String,Id>{
      'accountId' => principalAccountObj.Id,
      'contactId' => principalContactObj.Id,
      'partyTypeId' => principalPartyTypeObj.Id,
      'applicationId' => applicationObj.Id
    };
    clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createParty(paramPrincipalPartyMap);

    Map<String,Id> paramPrincipalPartyMapTwo = new Map<String,Id>{
      'accountId' => principalAccountObjTwo.Id,
      'contactId' => principalContactObjTwo.Id,
      'partyTypeId' => principalPartyTypeObj.Id,
      'applicationId' => applicationObj.Id
    };
    clcommon__Party__c principalPartyObjTwo = ApplicationOriginationTestHelper.createParty(paramPrincipalPartyMapTwo);
    Database.insert(new List<clcommon__Party__c>{clPartyObj, borrowerPartyObj, principalPartyObj, principalPartyObjTwo},true);
    
    ContentVersion contentVersionObj= ApplicationOriginationTestHelper.createContentVersion('Credit Application Agreement.pdf');
    Database.insert(contentVersionObj,true);
    ContentDocument contentDocumentObj = [SELECT Id 
                                          FROM ContentDocument 
                                          WHERE Title =: contentVersionObj.Title];
    ContentDocumentLink contentDocLinkAgrmttObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocumentObj.Id,applicationObj.Id);
    Database.insert(contentDocLinkAgrmttObj,true);
    clcommon__document_category__c documentCategoryObj = ApplicationOriginationTestHelper.createDocCategory(applicationObj.Id,'Signed Credit Agreement');
    Database.insert(documentCategoryObj,true);
    clcommon__Category_Attachment_Association__c attachmentAssociationObj = ApplicationOriginationTestHelper.createAttachmentAssociation(documentCategoryObj, applicationObj.Dealer_Name__c);
    attachmentAssociationObj.clcommon__Content_Document_Id__c = contentDocumentObj.Id;
    Database.insert(attachmentAssociationObj,true);
  }

  /**
  * @description This method is to test DocuSignViaEmail for application with legal entity being sole prop
  * @author Kabir Pramanik | 03-10-2025 
  **/
  @isTest
  static void testEmailDocusignForSoleProp(){
    List<genesis__Applications__c> appObjList = [SELECT Id FROM genesis__Applications__c where genesis__Loan_Number__c = '398762543'];
    ContentDocumentLink contentDocLinkObj = [SELECT Id, 
                                                      ContentDocumentId,
                                                      LinkedEntityId
                                              FROM ContentDocumentLink
                                              WHERE  LinkedEntityId = :appObjList[0].Id
                                              LIMIT 1];
    //// Mock the DocuSign eSignature API
    dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());

    // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
    System.runAs(dfsle.UserMock.createDocuSignSender()){
      Test.startTest();
      DocuSignviaEmail docusignQueueableClass = new DocuSignviaEmail(contentDocLinkObj.ContentDocumentId, contentDocLinkObj.LinkedEntityId);
      System.enqueueJob(docusignQueueableClass);
      Test.stopTest();
      List<genesis__Applications__c> updatedAppObjList = [SELECT Id,
                                                                    DocuSign_Credit_Agreement_Initiated__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Id = :contentDocLinkObj.LinkedEntityId];
      System.assertEquals(true, updatedAppObjList[0].DocuSign_Credit_Agreement_Initiated__c, ASSERTION_FAILED);
    }
  }
  /**
  * @description This method is to test DocuSignViaEmail for application with legal entity being corporation
  * @author  Pritam Roy | 03-06-2024 
  **/
  @isTest
  public static void  testEmailDocusignForCorporation() {
    List<clcommon__Legal_Entity__c> corpLegalEntityObj = [Select Id FROM clcommon__Legal_Entity__c clEntity WHERE Name = :PortalConstants.CORPORATION];
    List<genesis__Applications__c> applicationObj = [Select Id, 
                                                              genesis__Account__c  
                                                              FROM genesis__Applications__c 
                                                              WHERE genesis__Loan_Number__c = '398762543'];
    Account borrowerAccount = new Account(Id = applicationObj[0].genesis__Account__c,
                                          clcommon__Legal_Entity_Type__c = corpLegalEntityObj[0].Id);
    Database.upsert(borrowerAccount,true);
    ContentDocumentLink contentDocLinkObj = [SELECT Id, 
                                                      ContentDocumentId,
                                                      LinkedEntityId
                                              FROM ContentDocumentLink
                                              WHERE  LinkedEntityId = :applicationObj[0].Id
                                              LIMIT 1];
    // Mock the DocuSign eSignature API
    dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());

    // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
    System.runAs(dfsle.UserMock.createDocuSignSender()) {
      Test.startTest();
      DocuSignviaEmail docusignQueueableClass = new DocuSignviaEmail(contentDocLinkObj.ContentDocumentId, contentDocLinkObj.LinkedEntityId);
      System.enqueueJob(docusignQueueableClass);
      Test.stopTest();
      List<genesis__Applications__c> updatedAppObjList = [SELECT Id,
                                                                    DocuSign_Credit_Agreement_Initiated__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Id = :contentDocLinkObj.LinkedEntityId];
      System.assertEquals(true, updatedAppObjList[0].DocuSign_Credit_Agreement_Initiated__c, ASSERTION_FAILED);
    }
  }
  /**
  * @description This method is to test DocuSignViaEmail for application with legal entity being corporation and with single principal party
  * @author  Pritam Roy | 03-06-2024 
  **/
  @isTest
  public static void  testDocusignForCorporationSinglePrincipal() {
    List<clcommon__Legal_Entity__c> corpLegalEntityObj = [Select Id FROM clcommon__Legal_Entity__c clEntity WHERE Name = :PortalConstants.CORPORATION];
    List<genesis__Applications__c> applicationObj = [Select Id, 
                                                              genesis__Account__c  
                                                              FROM genesis__Applications__c 
                                                              WHERE genesis__Loan_Number__c = '398762543'];
    Account borrowerAccount = new Account(Id = applicationObj[0].genesis__Account__c,
                                          clcommon__Legal_Entity_Type__c = corpLegalEntityObj[0].Id);
    Database.upsert(borrowerAccount,true);
    List<clcommon__Party__c> principalPartyList = [SELECT Id 
                                                    FROM clcommon__Party__c 
                                                    WHERE clcommon__Type__c In (SELECT Id 
                                                                                  FROM clcommon__Party_Type__c
                                                                                  WHERE Name = :ConstantValues.PRINCIPAL_PARTY)
                                                                                  LIMIT 1];
    Database.delete(principalPartyList, true);
    ContentDocumentLink contentDocLinkObj = [SELECT Id, 
                                                      ContentDocumentId,
                                                      LinkedEntityId
                                              FROM ContentDocumentLink
                                              WHERE  LinkedEntityId = :applicationObj[0].Id
                                              LIMIT 1];
    // Mock the DocuSign eSignature API
    dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());

    // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
    System.runAs(dfsle.UserMock.createDocuSignSender()) {
      Test.startTest();
      DocuSignviaEmail docusignQueueableClass = new DocuSignviaEmail(contentDocLinkObj.ContentDocumentId, contentDocLinkObj.LinkedEntityId);
      System.enqueueJob(docusignQueueableClass);
      Test.stopTest();
      List<genesis__Applications__c> updatedAppObjList = [SELECT Id,
                                                                    DocuSign_Credit_Agreement_Initiated__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Id = :contentDocLinkObj.LinkedEntityId];
      System.assertEquals(true, updatedAppObjList[0].DocuSign_Credit_Agreement_Initiated__c, ASSERTION_FAILED);
    }
  }
  /**
  * @description This method is to test DocuSignViaEmail for application with legal entity being corporation
  * @author  Pritam Roy | 03-06-2024 
  **/
  @isTest
  public static void  testEmailDocusignForDBA() {
    List<clcommon__Legal_Entity__c> corpLegalEntityObj = [SELECT Id FROM clcommon__Legal_Entity__c WHERE Name = :PortalConstants.INDIVIDUAL_ENTITY];
    List<genesis__Applications__c> applicationObj = [SELECT Id, 
                                                              genesis__Account__c  
                                                      FROM genesis__Applications__c 
                                                      WHERE genesis__Loan_Number__c = '398762543'];
    Account borrowerAccount = new Account(Id = applicationObj[0].genesis__Account__c,
                                          clcommon__Legal_Entity_Type__c = corpLegalEntityObj[0].Id);
    Database.upsert(borrowerAccount,true);
    ContentDocumentLink contentDocLinkObj = [SELECT Id, 
                                                      ContentDocumentId,
                                                      LinkedEntityId
                                              FROM ContentDocumentLink
                                              WHERE  LinkedEntityId = :applicationObj[0].Id
                                              LIMIT 1];
    // Mock the DocuSign eSignature API
    dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());

    // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
    System.runAs(dfsle.UserMock.createDocuSignSender()) {
      Test.startTest();
      DocuSignviaEmail docusignQueueableClass = new DocuSignviaEmail(contentDocLinkObj.ContentDocumentId, contentDocLinkObj.LinkedEntityId);
      System.enqueueJob(docusignQueueableClass);
      Test.stopTest();
      List<genesis__Applications__c> updatedAppObjList = [SELECT Id,
                                                                    DocuSign_Credit_Agreement_Initiated__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Id = :contentDocLinkObj.LinkedEntityId];
      System.assertEquals(true, updatedAppObjList[0].DocuSign_Credit_Agreement_Initiated__c, ASSERTION_FAILED);
    }
  }
  /**
  * @description This method is to test docusign where there is no borrowe party present for the application
  * @author  Pritam Roy | 03-06-2024 
  **/
  @isTest
  public static void testBorrowerPartyMissingException() {
    List<genesis__Applications__c> appObjList = [SELECT Id FROM genesis__Applications__c where genesis__Loan_Number__c = '398762543'];
    List<clcommon__party__c> borrowerPartyList = [SELECT Id 
                                          FROM clcommon__Party__c 
                                          WHERE genesis__Application__c = :appObjList[0].Id 
                                          AND clcommon__Party_Types__c = :PortalConstants.BORROWER_PARTY_NAME];
    if(!borrowerPartyList.isEmpty()){
      Database.delete(borrowerPartyList, true);
    }
    ContentDocumentLink contentDocLinkObj = [SELECT Id, 
                                                      ContentDocumentId,
                                                      LinkedEntityId
                                              FROM ContentDocumentLink
                                              WHERE  LinkedEntityId = :appObjList[0].Id
                                              LIMIT 1];
    //// Mock the DocuSign eSignature API
    dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());

    // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
    System.runAs(dfsle.UserMock.createDocuSignSender()){
      Test.startTest();
      DocuSignviaEmail docusignQueueableClass = new DocuSignviaEmail(contentDocLinkObj.ContentDocumentId, contentDocLinkObj.LinkedEntityId);
      System.enqueueJob(docusignQueueableClass);
      Test.stopTest();
      List<clcommon__Log__c> logList = [SELECT Id
                                                FROM clcommon__Log__c 
                                                WHERE Name = :DocuSignviaEmail.class.getName()
                                                ORDER BY CreatedDate DESC
                                                LIMIT 1];
      System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
      List<genesis__Applications__c> updatedAppObjList = [SELECT Id,
                                                                    DocuSign_Credit_Agreement_Initiated__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Id = :contentDocLinkObj.LinkedEntityId];
      System.assertEquals(false, updatedAppObjList[0].DocuSign_Credit_Agreement_Initiated__c, ASSERTION_FAILED);
    }
  }
  /**
   * @description This method is to test email docusign for an application whose borrower party's legal entity type is not specified
   * @author  Pritam Roy | 03-06-2024 
   **/
  @isTest
  static void  testBorrowerLegalEntityTypeMissingException() {
    List<genesis__Applications__c> appObjList = [SELECT Id, genesis__Account__c FROM genesis__Applications__c where genesis__Loan_Number__c = '398762543'];
    Account borrowerAccObj = new Account(Id = appObjList[0].genesis__Account__c, 
                                        clcommon__Legal_Entity_Type__c = null);
    Database.upsert(borrowerAccObj, true);
    ContentDocumentLink contentDocLinkObj = [SELECT Id, 
                                                      ContentDocumentId,
                                                      LinkedEntityId
                                              FROM ContentDocumentLink
                                              WHERE  LinkedEntityId = :appObjList[0].Id
                                              LIMIT 1];
    //// Mock the DocuSign eSignature API
    dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());

    // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
    System.runAs(dfsle.UserMock.createDocuSignSender()){
      Test.startTest();
      DocuSignviaEmail docusignQueueableClass = new DocuSignviaEmail(contentDocLinkObj.ContentDocumentId, contentDocLinkObj.LinkedEntityId);
      System.enqueueJob(docusignQueueableClass);
      Test.stopTest();
      List<clcommon__Log__c> logList = [SELECT Id
                                                FROM clcommon__Log__c 
                                                WHERE Name = :DocuSignviaEmail.class.getName()
                                                ORDER BY CreatedDate DESC
                                                LIMIT 1];
      System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
      List<genesis__Applications__c> updatedAppObjList = [SELECT Id,
                                                                    DocuSign_Credit_Agreement_Initiated__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Id = :contentDocLinkObj.LinkedEntityId];
      System.assertEquals(false, updatedAppObjList[0].DocuSign_Credit_Agreement_Initiated__c, ASSERTION_FAILED);
    }
  }
  /**
   * @description This method is to test email docusign for an application where email of borrower's contact is not provided
   * @author  Pritam Roy | 03-06-2024 
   **/
  @isTest
  static void  testBorrowerEmailMissingException() {
    List<genesis__Applications__c> appObjList = [SELECT Id, genesis__Account__c FROM genesis__Applications__c where genesis__Loan_Number__c = '398762543'];
    List<Contact> borrowerContactList = [SELECT Id FROM Contact WHERE AccountId = :appObjList[0].genesis__Account__c LIMIT 1];
    borrowerContactList[0].Email = null;
    Database.update(borrowerContactList, true);
    ContentDocumentLink contentDocLinkObj = [SELECT Id, 
                                                      ContentDocumentId,
                                                      LinkedEntityId
                                              FROM ContentDocumentLink
                                              WHERE  LinkedEntityId = :appObjList[0].Id
                                              LIMIT 1];
    //// Mock the DocuSign eSignature API
    dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());

    // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
    System.runAs(dfsle.UserMock.createDocuSignSender()){
      Test.startTest();
      DocuSignviaEmail docusignQueueableClass = new DocuSignviaEmail(contentDocLinkObj.ContentDocumentId, contentDocLinkObj.LinkedEntityId);
      System.enqueueJob(docusignQueueableClass);
      Test.stopTest();
      List<clcommon__Log__c> logList = [SELECT Id
                                                FROM clcommon__Log__c 
                                                WHERE Name = :DocuSignviaEmail.class.getName()
                                                ORDER BY CreatedDate DESC
                                                LIMIT 1];
      System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
      List<genesis__Applications__c> updatedAppObjList = [SELECT Id,
                                                                    DocuSign_Credit_Agreement_Initiated__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Id = :contentDocLinkObj.LinkedEntityId];
      System.assertEquals(false, updatedAppObjList[0].DocuSign_Credit_Agreement_Initiated__c, ASSERTION_FAILED);
    }
  }
  /**
   * @description This method is to test email docusign for an application where email of principal's contact is not provided
   * @author  Pritam Roy | 03-06-2024 
   **/
  @isTest
  static void  testPrincipalEmailMissingException() {
    List<genesis__Applications__c> appObjList = [SELECT Id, genesis__Account__c FROM genesis__Applications__c where genesis__Loan_Number__c = '398762543'];
    List<clcommon__Party__c> principalPartyList = [SELECT Id,
                                                            clcommon__Contact__c 
                                                    FROM clcommon__Party__c 
                                                    WHERE clcommon__Type__c In (SELECT Id 
                                                                                  FROM clcommon__Party_Type__c
                                                                                  WHERE Name = :ConstantValues.PRINCIPAL_PARTY)];
    
    Contact principalContact = new Contact(Id = principalPartyList[0].clcommon__Contact__c,
                                           Email = null);
    Database.upsert(principalContact, true);
    ContentDocumentLink contentDocLinkObj = [SELECT Id, 
                                                      ContentDocumentId,
                                                      LinkedEntityId
                                              FROM ContentDocumentLink
                                              WHERE  LinkedEntityId = :appObjList[0].Id
                                              LIMIT 1];
    //// Mock the DocuSign eSignature API
    dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());

    // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
    System.runAs(dfsle.UserMock.createDocuSignSender()){
      Test.startTest();
      DocuSignviaEmail docusignQueueableClass = new DocuSignviaEmail(contentDocLinkObj.ContentDocumentId, contentDocLinkObj.LinkedEntityId);
      System.enqueueJob(docusignQueueableClass);
      Test.stopTest();
      List<clcommon__Log__c> logList = [SELECT Id
                                                FROM clcommon__Log__c 
                                                WHERE Name = :DocuSignviaEmail.class.getName()
                                                ORDER BY CreatedDate DESC
                                                LIMIT 1];
      System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
      List<genesis__Applications__c> updatedAppObjList = [SELECT Id,
                                                                    DocuSign_Credit_Agreement_Initiated__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Id = :contentDocLinkObj.LinkedEntityId];
      System.assertEquals(false, updatedAppObjList[0].DocuSign_Credit_Agreement_Initiated__c, ASSERTION_FAILED);
    }
  }
  /**
   * @description This method is to test email docusign for an application with legal entity Corporation where email of principal's contact is not provided
   * @author  Pritam Roy | 03-06-2024 
   **/
  @isTest
  static void  testCorpPrincipalEmailMissingException() {
    List<clcommon__Legal_Entity__c> corpLegalEntityObj = [Select Id FROM clcommon__Legal_Entity__c clEntity WHERE Name = :PortalConstants.CORPORATION];
    List<genesis__Applications__c> appObjList = [SELECT Id, genesis__Account__c FROM genesis__Applications__c where genesis__Loan_Number__c = '398762543'];
    Account borrowerAccount = new Account(Id = appObjList[0].genesis__Account__c,
                                          clcommon__Legal_Entity_Type__c = corpLegalEntityObj[0].Id);
    Database.upsert(borrowerAccount,true);
    List<clcommon__Party__c> principalPartyList = [SELECT Id,
                                                            clcommon__Contact__c 
                                                    FROM clcommon__Party__c 
                                                    WHERE clcommon__Type__c In (SELECT Id 
                                                                                  FROM clcommon__Party_Type__c
                                                                                  WHERE Name = :ConstantValues.PRINCIPAL_PARTY)];
    
    Contact principalContact = new Contact(Id = principalPartyList[0].clcommon__Contact__c,
                                           Email = null);
    Database.upsert(principalContact, true);
    ContentDocumentLink contentDocLinkObj = [SELECT Id, 
                                                      ContentDocumentId,
                                                      LinkedEntityId
                                              FROM ContentDocumentLink
                                              WHERE  LinkedEntityId = :appObjList[0].Id
                                              LIMIT 1];
    //// Mock the DocuSign eSignature API
    dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());

    // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
    System.runAs(dfsle.UserMock.createDocuSignSender()){
      Test.startTest();
      DocuSignviaEmail docusignQueueableClass = new DocuSignviaEmail(contentDocLinkObj.ContentDocumentId, contentDocLinkObj.LinkedEntityId);
      System.enqueueJob(docusignQueueableClass);
      Test.stopTest();
      List<clcommon__Log__c> logList = [SELECT Id
                                                FROM clcommon__Log__c 
                                                WHERE Name = :DocuSignviaEmail.class.getName()
                                                ORDER BY CreatedDate DESC
                                                LIMIT 1];
      System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
      List<genesis__Applications__c> updatedAppObjList = [SELECT Id,
                                                                    DocuSign_Credit_Agreement_Initiated__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Id = :contentDocLinkObj.LinkedEntityId];
      System.assertEquals(false, updatedAppObjList[0].DocuSign_Credit_Agreement_Initiated__c, ASSERTION_FAILED);
    }
  }
}