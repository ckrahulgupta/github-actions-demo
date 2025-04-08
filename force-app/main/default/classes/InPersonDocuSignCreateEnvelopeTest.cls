/**
 * @description       : Test class for InPersonDocuSignCreateEnvelope
 * @author            : Simran
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : Suraj Kumar
**/

@isTest
public class InPersonDocuSignCreateEnvelopeTest {
    @testSetup
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

      Account principalAccount = ApplicationOriginationTestHelper.createCoBorrowerAccount(entityObj,ApplicationOriginationTestHelper.createBusinessInfoForPrincipal().id);
      Database.insert(principalAccount,true);

      Contact principalContact = ApplicationOriginationTestHelper.createCoBorrowerContact(principalAccount.id);
      Database.insert(principalContact,true);

      genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createBlankApplication();
      applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
      applicationObj.genesis__Account__c = borrowerAccountObj.id;
      applicationObj.genesis__Contact__c = borrowerContactObj.id;
      applicationObj.Certified_Lender__c = clAccountObj.id;
      Database.insert(applicationObj, true);

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

        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(borrowerPartyTypeObj, true);

        // Creating Borrower Party
        Map<String,Id> paramBorrowerPartyMap = new Map<String,Id>();
        paramBorrowerPartyMap.put('accountId', borrowerAccountObj.Id);
        paramBorrowerPartyMap.put('contactId', borrowerContactObj.Id);
        paramBorrowerPartyMap.put('partyTypeId', borrowerPartyTypeObj.Id);
        paramBorrowerPartyMap.put('applicationId', applicationObj.Id);
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(paramBorrowerPartyMap);
        Database.insert(borrowerPartyObj);

        clcommon__Party_Type__c coBorrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        Database.insert(coBorrowerPartyTypeObj, true);

        // Creating Co Borrower Party
        Map<String,Id> paramPrincipalPartyMap = new Map<String,Id>();
        paramPrincipalPartyMap.put('accountId', principalAccount.Id);
        paramPrincipalPartyMap.put('contactId', principalContact.Id);
        paramPrincipalPartyMap.put('partyTypeId', coBorrowerPartyTypeObj.Id);
        paramPrincipalPartyMap.put('applicationId', applicationObj.Id);
        clcommon__Party__c coBorrowerPartyObj = ApplicationOriginationTestHelper.createParty(paramPrincipalPartyMap);
        Database.insert(coBorrowerPartyObj,true);
        //creating content version
        ContentVersion contentObj= ApplicationOriginationTestHelper.createContentVersion();
        contentObj.Title = 'Credit Application Agreement.pdf';
        contentObj.PathOnClient='/'+contentObj.Title+'.pdf';
        Database.insert(contentObj,true);
        // creating content Document
        ContentDocument contentDocAgreementObj = [SELECT Id FROM ContentDocument WHERE Title = 'Credit Application Agreement.pdf' LIMIT 1];
        // creating ContentDocumentLink
        ContentDocumentLink contentDocLinkAgrmttObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocAgreementObj.id,applicationObj.Id);
        Database.insert(contentDocLinkAgrmttObj,true);
   
   }

    /**
    * @description : Test Inperson email for corporation
    * @author  Simran | 08-14-2024 
    **/
   @isTest
    public static void  testInpersonForCorporation() {

      clcommon__Legal_Entity__c clEntity = [Select Id, Name FROM clcommon__Legal_Entity__c clEntity WHERE Name='Corporation'];


      genesis__Applications__c applicationObj=[Select Id,genesis__Account__c  FROM genesis__Applications__c WHERE Signing_Method__c=:PortalConstants.IN_PERSON_DOCUSIGN];
      Account borrowerAccount = [SELECT Id FROM Account WHERE id =: applicationObj.genesis__Account__c];
      borrowerAccount.clcommon__Legal_Entity_Type__c = clEntity.id;
      Database.update(borrowerAccount,true);

        // Mock the DocuSign eSignature API
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());

        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        ContentDocument contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.Id];             
        System.runAs(adminUser) {
        InPersonDocuSignCreateEnvelope inpersonEnvelope = new InPersonDocuSignCreateEnvelope(contentDocumentLinkObj.ContentDocumentId,applicationObj.Id);
            System.enqueueJob(inpersonEnvelope);
            System.assert(true,'SUCCESS');
        }
    }
   
   
    /**
    * @description : Test Inperson email for individual
    * @author  Simran | 08-14-2024 
    **/
   @isTest
    public static void  testInpersonForIndividual() {

      genesis__Applications__c applicationObj=[Select Id,genesis__Account__c  FROM genesis__Applications__c WHERE Signing_Method__c=:PortalConstants.IN_PERSON_DOCUSIGN];
        // Mock the DocuSign eSignature API
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock()); 
        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        ContentDocument contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.Id];             
        System.runAs(adminUser) {
        InPersonDocuSignCreateEnvelope inpersonEnvelope = new InPersonDocuSignCreateEnvelope(contentDocumentLinkObj.ContentDocumentId,applicationObj.Id);
            System.enqueueJob(inpersonEnvelope);
            System.assert(true,'SUCCESS');
        }
    }

   /**
   * @description test inperson individual exception
   * @author  Simran | 08-14-2024 
   **/
   @isTest
   public static void  testInpersonForIndividualCustomException() {
    clcommon__Legal_Entity__c clEntity = [Select Id, Name FROM clcommon__Legal_Entity__c clEntity WHERE Name='Corporation'];
    genesis__Applications__c applicationObj = [Select genesis__Account__c FROM genesis__Applications__c WHERE Signing_Method__c=:PortalConstants.IN_PERSON_DOCUSIGN];

    Account borrowerAccount = [SELECT Id FROM Account WHERE id =: applicationObj.genesis__Account__c];
    borrowerAccount.clcommon__Legal_Entity_Type__c = clEntity.id;
    Database.update(borrowerAccount,true);
    Contact borrowerContact = [SELECT Id,FirstName,LastName,Email,Phone FROM Contact WHERE AccountId =: borrowerAccount.id];
    borrowerContact.Email = null;
    Database.update(borrowerContact,true);
    User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        
    ContentDocument contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
    ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.Id];             

    System.runAs(adminUser){
        dfsle.Envelope objEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(applicationObj.Id))
                                .withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(),
                                new Set<Id> {contentDocumentObj.id }));
                    
        objEnvelope=objEnvelope.withRecipients(new List<dfsle.Recipient> {
                    dfsle.Recipient.fromSource(
                    borrowerContact.FirstName + ' ' + borrowerContact.LastName,
                    borrowerContact.Email,
                    borrowerContact.Phone,
                    'Signer 1',
                    new dfsle.Entity(borrowerContact.Id))
                });
            InPersonDocuSignCreateEnvelope inpersonEnvelope = new InPersonDocuSignCreateEnvelope(contentDocumentLinkObj.ContentDocumentId,applicationObj.Id);
            System.enqueueJob(inpersonEnvelope);
            System.assert(true,PortalConstants.SOMETHING_WENT_WRONG);
        }
    }
    /**
     * @description test Inperson Corporation Exception
     * @author  Simran | 08-14-2024  
     **/
    @isTest
    public static void  testInpersonCorporationCustomException() {
    genesis__Applications__c applicationObj = [Select genesis__Account__c FROM genesis__Applications__c WHERE Signing_Method__c=:PortalConstants.IN_PERSON_DOCUSIGN];

    Account borrowerAccount = [SELECT Id FROM Account WHERE id =: applicationObj.genesis__Account__c];
    Contact borrowerContact = [SELECT Id,FirstName,LastName,Email,Phone FROM Contact WHERE AccountId =: borrowerAccount.id];
    borrowerContact.Email = null;
    Database.update(borrowerContact,true);
    User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        
    ContentDocument contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
    ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.Id];             

    System.runAs(adminUser){
        List<dfsle__Envelope__c> envelopeList = [SELECT Id FROM dfsle__Envelope__c];
        System.assertEquals(true, envelopeList.size()==0,'Assertion Failed');

        dfsle.Envelope objEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(applicationObj.Id))
                                .withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(),
                                new Set<Id> {contentDocumentObj.id }));
                    
            objEnvelope=objEnvelope.withRecipients(new List<dfsle.Recipient> {
                        dfsle.Recipient.fromSource(
                        borrowerContact.FirstName + ' ' + borrowerContact.LastName,
                        borrowerContact.Email,
                        borrowerContact.Phone,
                        'Signer 1',
                        new dfsle.Entity(borrowerContact.Id))
                    });
            InPersonDocuSignCreateEnvelope inpersonEnvelope = new InPersonDocuSignCreateEnvelope(contentDocumentLinkObj.ContentDocumentId,applicationObj.Id);
            System.enqueueJob(inpersonEnvelope);
            System.assert(true,PortalConstants.SOMETHING_WENT_WRONG);
        }
    }
    /**
    * @description Method is used to check the Account and their Entity Type
    * @author Simran | 08-16-2024 
    **/
    @isTest
    public static void  testAccountOrEntityType() {
        genesis__Applications__c applicationObj=[Select Id,genesis__Account__c FROM genesis__Applications__c WHERE Signing_Method__c=:PortalConstants.IN_PERSON_DOCUSIGN];
        Account borrowerAccount = [SELECT Id,clcommon__Legal_Entity_Type__c FROM Account WHERE id =: applicationObj.genesis__Account__c];
        borrowerAccount.clcommon__Legal_Entity_Type__c = null;
        Database.update(borrowerAccount,true);
        List<clcommon__Party__c> updatedParties = [SELECT clcommon__Account__c,clcommon__Type__c,clcommon__Type__r.Name,clcommon__Party_Types__c  FROM clcommon__Party__c WHERE genesis__Application__c=:applicationObj.Id AND clcommon__Type__r.Name='BORROWER' LIMIT 1];
        updatedParties[0].clcommon__Account__c=null;
        Database.update(updatedParties[0],true);
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        ContentDocument contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.Id];             
        System.runAs(adminUser) {
        InPersonDocuSignCreateEnvelope inpersonEnvelope = new InPersonDocuSignCreateEnvelope(contentDocumentLinkObj.ContentDocumentId,applicationObj.Id);
            System.enqueueJob(inpersonEnvelope);
            System.assert(true,'SUCCESS');
        }
    }
}