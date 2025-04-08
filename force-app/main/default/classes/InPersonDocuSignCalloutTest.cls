/**
 * @description       : 
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 06-28-2024
 * @last modified by  : Krishanu Chinya
**/
@isTest
public class InPersonDocuSignCalloutTest {
    @testSetup
    static void setup() {
        
        genesis__Business_Information__c businessInfo = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(businessInfo,true);        
        genesis__Business_Information__c businessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoObj,true);
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoObj.id);
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProduct();
        Database.insert(clProductObj,true);
        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(legalEntityObj,true);
        clcommon__Legal_Entity__c corpLegalEntityObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(corpLegalEntityObj,true);
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        Account principalAccount = ApplicationOriginationTestHelper.createSolePropAccount(corpLegalEntityObj,businessInfo.id);
        Contact principalContact = ApplicationOriginationTestHelper.createBorrowerContact(principalAccount.id);
        principalContact.Email = 'abc@yopmail.com';

        Database.insert(new List<Account>{
            dealerAccountObj,
            borrowerAccountObj,
            principalAccount
        },true);
        Database.insert(new List<Contact>{
            borrowerContactObj,
            principalContact
        },true);
        
        Map<String,Object> applicationDataMap = new Map<String,Object>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'saAccountObjId' => null
        };
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(applicationDataMap);
        applicationObj.Signing_Method__c = 'In Person - Docusign';
        Database.insert(applicationObj,true); 
    
        clcommon__Party_Type__c objPartyType = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(objPartyType,true);

        clcommon__Party_Type__c objPrincipalPartyType = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        Database.insert(objPrincipalPartyType,true);
     
        Map<String,Id> partyBorrowerParamMap = new Map<String,Id>{
            'accountId' =>  borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => objPartyType.Id,
            'applicationId' =>  applicationObj.Id
        };
        clcommon__Party__c objBorrowerparty = ApplicationOriginationTestHelper.createParty(partyBorrowerParamMap);
        objBorrowerparty.Total_Assets__c = 10000;
        objBorrowerparty.Total_Liabilities__c = 1000;
        
        Map<String,Id> partyPrincipalParamMap = new Map<String,Id>{
            'accountId' =>  principalAccount.Id,
            'contactId' => principalContact.Id,
            'partyTypeId' => objPrincipalPartyType.Id,
            'applicationId' =>  applicationObj.Id
        };
        clcommon__Party__c objPrincipalParty = ApplicationOriginationTestHelper.createParty(partyPrincipalParamMap);
        objPrincipalParty.Total_Assets__c = 10000;
        objPrincipalParty.Total_Liabilities__c = 1000;
        Database.insert(new List<clcommon__Party__c>{
            objBorrowerparty,
            objPrincipalParty
        },true);

        createDSRecord(applicationObj.id,principalContact.id);

        // Integration framework Setup Data 
        //Inserting Integration Family
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily(
            'DocuSign Integration');
        
        intframework__Integration_Provider__c getDSProvider = IntegrationTestInitHelper.getIntegrationProvider(
           family.Id, 'In-Person DocuSign Provider');
           getDSProvider.intframework__Provider_Name__c = 'DocuSign Integration Provider';
           getDSProvider.intframework__Support_Type__c = 'Out-of-the-Box';

        intframework__Integration_Provider__c getDSSetStatusProvider = IntegrationTestInitHelper.getIntegrationProvider(
                family.Id, 'In-Person DocuSign Set Status');
                getDSSetStatusProvider.intframework__Provider_Name__c = 'DocuSign Integration Provider';
                getDSSetStatusProvider.intframework__Support_Type__c = 'Out-of-the-Box';

        intframework__Integration_Provider__c getDSGetURLProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'In-Person DocuSign Get URL');
            getDSGetURLProvider.intframework__Provider_Name__c = 'DocuSign Integration Provider';
            getDSGetURLProvider.intframework__Support_Type__c = 'Out-of-the-Box';

        Database.update(new List<intframework__Integration_Provider__c>{
            getDSProvider,
            getDSSetStatusProvider,
            getDSGetURLProvider
        },true);

        //Inserting Integration API Type for 1st 
        intframework__Integration_API_Type__c getDSApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'DocuSign Update Recipient Integration API Type');
        Database.upsert(getDSApiType,true);
        //Inserting Integration API Type for 2nd 
        intframework__Integration_API_Type__c getSetStatusApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'DocuSign Set Status Integration API Type');
        Database.upsert(getSetStatusApiType,true);

        //Inserting Integration API Type for 3rd
        intframework__Integration_API_Type__c getURLApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'DocuSign Get URL Integration API Type');
        Database.upsert(getURLApiType,true);

        //Inserting Integration Configuration for 1st
        intframework__Integration_Configuration__c getDSConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            getDSProvider.Id,'DocuSign Update Recipient Integration Configuration','DocuSign');
        Database.upsert(getDSConfig,true);
        //Inserting Integration Configuration for 2nd
        intframework__Integration_Configuration__c getDSSetStatusConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            getDSSetStatusProvider.Id,'DocuSign Set Status Integration Configuration','DocuSign');
        Database.upsert(getDSSetStatusConfig,true);
        //Inserting Integration Configuration for 3rd
        intframework__Integration_Configuration__c getDSGetUrlConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            getDSGetURLProvider.Id,'DocuSign Get URL Integration Configuration','DocuSign');
        Database.upsert(getDSGetUrlConfig,true);

    
        //Inserting Integration API Configuration for 1st
        intframework__Integration_API_Configuration__c getDSApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            getDSApiType.Id,
            getDSProvider.Id,
            getDSConfig.Id,
            false,
            'InPersonDSUpdateRecipientAdapter',
            'PUT',
            'DocuSign',
            'restapi/v2.1/accounts/updateRecipients',
            '{"thirdPartySystem": {"name": "InPersonDocuSign","filters": [{"objectAPI": "dfsle__Envelope__c","objectAlias": "Envelope","fields": [{"externalField": "ID","fieldAPI": "Id"},{"externalField": "docuSignId","fieldAPI": "dfsle__DocuSignId__c"}],"whereClause": "Id IN :docuSignList"},{"objectAPI": "dfsle__Recipient__c","objectAlias": "Recipient","fields": [{"externalField": "ID","fieldAPI": "Id"},{"externalField": "recipientId","fieldAPI": "dfsle__SourceId__c"},{"externalField": "emailId","fieldAPI": "dfsle__Email__c"}],"whereClause": "dfsle__Envelope__c IN :docuSignList"}]}}',
            'application/json',
            1
        );
        getDSApiConfig.Name = 'InPersonDocuSignUpdateRecipientConfiguration';
        Database.update(getDSApiConfig);

        //Inserting Integration API Configuration for 2nd
        intframework__Integration_API_Configuration__c getDSSetStatusApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            getSetStatusApiType.Id,
            getDSSetStatusProvider.Id,
            getDSConfig.Id,
            false,
            'InPersonDSUpdateStatusAdapter',
            'PUT',
            'DocuSign',
            'restapi/v2.1/accounts/updateStatus',
            '{"thirdPartySystem": {"name": "InPersonDocuSign","filters": [{"objectAPI": "dfsle__Envelope__c","objectAlias": "Envelope","fields": [{"externalField": "ID","fieldAPI": "Id"},{"externalField": "docuSignId","fieldAPI": "dfsle__DocuSignId__c"}],"whereClause": "Id IN :docuSignList"}]}}',
            'application/json',
            1
        );
        getDSSetStatusApiConfig.Name = 'InPersonDocuSignSetStatusConfiguration';
        Database.update(getDSSetStatusApiConfig,true);
         

        //Inserting Integration API Configuration for 3rd
        intframework__Integration_API_Configuration__c getDSGetUrlApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            getURLApiType.Id,
            getDSGetURLProvider.Id,
            getDSConfig.Id,
            false,
            'InPersonDSGetURLAdapter',
            'POST',
            'DocuSign',
            'restapi/v2.1/accounts/getURL',
            '{"thirdPartySystem": {"name": "InPersonDocuSign","filters": [{"objectAPI": "dfsle__Envelope__c","objectAlias": "Envelope","fields": [{"externalField": "ID","fieldAPI": "Id"},{"externalField": "docuSignId","fieldAPI": "dfsle__DocuSignId__c"}],"whereClause": "Id IN :docuSignList"},{"objectAPI": "dfsle__Recipient__c","objectAlias": "Recipient","fields": [{"externalField": "ID","fieldAPI": "Id"},{"externalField": "email","fieldAPI": "dfsle__Email__c"},{"externalField": "recipientName","fieldAPI": "Name"},{"externalField": "recipientId","fieldAPI": "dfsle__SourceId__c"}],"whereClause": "dfsle__Envelope__c IN :docuSignList and dfsle__Role__c IN :roleList"},{"objectAPI": "clcommon__Party__c","objectAlias": "Party","fields": [{"externalField": "ID","fieldAPI": "Id"},{"externalField": "CoopType","fieldAPI": "genesis__Application__r.Coop_Type__c"}],"whereClause": "genesis__Application__c IN :appIdList and clcommon__Contact__c IN :contactList"}]}}',
            'application/json',
            1
        );
        getDSGetUrlApiConfig.Name = 'InPersonDocuSignGetURLConfiguration';
        Database.update(getDSGetUrlApiConfig,true);

        CFA_Configuration__c dsConfigParams = ApplicationOriginationTestHelper.createDocusignParameterConfig();
        Database.insert(dsConfigParams,true);
    } 

    /**
     * @description Create Docusign Object Record
     * @param applicationId 
     * @param principalContactId 
     */
    private static void createDSRecord(String applicationId, String principalContactId){
        dfsle__Envelope__c envelope = ApplicationOriginationTestHelper.createEnvelope(applicationId);
        Database.insert(envelope,true);
        dfsle__EnvelopeStatus__c dsStatus = ApplicationOriginationTestHelper.createEnvelopeStatus(applicationId);
        Database.insert(dsStatus,true);
        dfsle__Recipient__c dsRecipient = ApplicationOriginationTestHelper.createEnvelopeRecipient(principalContactId, envelope.id);
        Database.insert(dsRecipient,true);
        dfsle__RecipientStatus__c recipient = ApplicationOriginationTestHelper.createEnvelopeRecipientStatus(principalContactId, dsStatus.id);
        Database.insert(recipient,true);
    }
    /**
     * @description This class is used to create mock request
     */
    public class DocuSignMock implements HttpCalloutMock {
        /**
         * @description This method is used to create mock response
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            // For DocuSign Integrations
            if(request.getEndpoint().contains('callout:DocuSign/restapi/v2.1/accounts/updateRecipients')) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"recipientUpdateResults":[{"recipientId":"1"}]}');
                res.setStatusCode(200);
            }
            if(request.getEndpoint().contains('callout:DocuSign/restapi/v2.1/accounts/updateStatus')) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"envelopeId":"d14211e6-33c6-436a-8a16-5f77c2c8a3ff"}');
                res.setStatusCode(200);
            }
            if(request.getEndpoint().contains('callout:DocuSign/restapi/v2.1/accounts/getURL')) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"url":"https://demo.docusign-d14211e6-33c6-436a-8a16-5f77c2c8a3ff"}');
                res.setStatusCode(201);
            }                
            return res;
        }
    }

    /**
     * @description This class is used to create error mock request
     */
    public class DocuSignErrorMock implements HttpCalloutMock {
        /**
         * @description This method is used to error mock request
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            // For DocuSign Integrations
            if(request.getEndpoint().contains('callout:DocuSign/restapi/v2.1/accounts/updateRecipients')) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"recipientUpdateResults":[{"recipientId":"1"}]}');
                res.setStatusCode(400);
            }
            if(request.getEndpoint().contains('callout:DocuSign/restapi/v2.1/accounts/updateStatus')) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"envelopeId":"d14211e6-33c6-436a-8a16-5f77c2c8a3ff"}');
                res.setStatusCode(400);
            }
            if(request.getEndpoint().contains('callout:DocuSign/restapi/v2.1/accounts/getURL')) {
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"url":"https://demo.docusign-d14211e6-33c6-436a-8a16-5f77c2c8a3ff"}');
                res.setStatusCode(401);
            }                
            return res;
        }
    }
    @isTest
    public static void  testInPersonDocuSignCorporation() {
        // Mock the DocuSign eSignature API
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock());
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];  
        System.runAs(adminUser) { 
            // Create test data
            clcommon__Legal_Entity__c clEntity = [Select Id, Name FROM clcommon__Legal_Entity__c clEntity WHERE Name='Corporation'];

            Account objAccount=[Select Name FROM Account WHERE RecordType.Name = 'Grower'];
            objAccount.clcommon__Legal_Entity_Type__c=clEntity.Id;
            Database.upsert(objAccount);
             
            Contact objContact=TestClassHelper.createContact();
    
            genesis__Applications__c objApplication=[Select Id, Signing_Method__c FROM genesis__Applications__c WHERE Signing_Method__c='In Person - Docusign'];


            ContentVersion objContent = TestClassHelper.createContentVersion('Credit Application Agreement.pdf');
            Database.upsert(objContent,true);


            ContentDocument contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
            Id conDocId =[SELECT ContentDocumentId FROM ContentVersion WHERE Id =:objContent.Id].ContentDocumentId;  
          
            TestClassHelper.createContentDocumentLink(objApplication,contentDocumentObj);
            dfsle.Envelope objEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(objApplication.Id))
                                    .withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(),
                                    new Set<Id> {conDocId}));
                       
            objEnvelope=objEnvelope.withRecipients(new List<dfsle.Recipient> {
                        dfsle.Recipient.fromSource(
                        objContact.FirstName + ' ' + objContact.LastName,
                        objContact.Email,
                        objContact.Phone,
                        'Signer 1',
                        new dfsle.Entity(objContact.Id))
                    });
            System.assertNotEquals(null, objEnvelope,'Assertion Failed');
        }
    }
    @isTest
    public static void  testInPersonDocuSignIndividual() {
        // Mock the DocuSign eSignature API
        dfsle.TestUtils.setMock(new dfsle.ESignatureAPIMock()); 
        // Run the test as a DocuSign Sender. This is required by dfsle.EnvelopeService.sendEnvelope
        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        System.runAs(adminUser) {
             // Create test data
            clcommon__Legal_Entity__c clEntity = [Select Id, Name FROM clcommon__Legal_Entity__c clEntity WHERE Name='Corporation'];
            clEntity.Name='Individual';
            Database.upsert(clEntity,true);

            Account objAccount=[Select Id, Name FROM Account WHERE  RecordType.Name = 'Grower'];
            objAccount.clcommon__Legal_Entity_Type__c=clEntity.Id;
            Database.upsert(objAccount,true);
            
            Contact objContact=TestClassHelper.createContact();
            
            genesis__Applications__c objApplication=[Select Id,Signing_Method__c FROM genesis__Applications__c WHERE Signing_Method__c='In Person - Docusign'];
            objApplication.DocuSign_Credit_Agreement_Initiated__c=false;
            Database.update(objApplication,true);

            ContentVersion objContent = TestClassHelper.createContentVersion('Credit Application Agreement.pdf');
            Database.upsert(objContent,true);
            
            ContentDocument contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];

            TestClassHelper.createContentDocumentLink(objApplication,contentDocumentObj);  


            Id conDocId =[SELECT ContentDocumentId FROM ContentVersion WHERE Id =:objContent.Id].ContentDocumentId;  
               
            dfsle.Envelope objEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(objApplication.Id));
            objEnvelope  = objEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(),
                                    new Set<Id> {conDocId}));
                       
            objEnvelope=objEnvelope.withRecipients(new List<dfsle.Recipient> {
                        dfsle.Recipient.fromSource(
                        objContact.FirstName + ' ' + objContact.LastName,
                        objContact.Email,
                        objContact.Phone,
                        'Signer 1',
                        new dfsle.Entity(objContact.Id))
                    });
             System.assertNotEquals(null, objEnvelope,'Assertion Failed');
        }
    } 
    @isTest
    public static void inpersonDSpdateRecipientTest(){
        Test.setMock(HttpCalloutMock.class, new DocuSignMock());
        Test.startTest();
        genesis__Applications__c objApplication=[Select Id, Signing_Method__c FROM genesis__Applications__c WHERE Signing_Method__c='In Person - Docusign'];
        List<dfsle__Envelope__c> envelope = [Select id,dfsle__DocuSignId__c from dfsle__Envelope__c];

        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        System.runAs(adminUser){
            System.enqueueJob(new InPersonDSUpdateRecipientCalloutAPI(envelope[0].id,objApplication.id, objApplication.Signing_Method__c)); 
        }
        System.assertEquals(true,envelope.size() > 0, 'No Envelope found ');
        Test.stopTest();
    }     
    @isTest
    private static void testCreateRequestBodyToUpdateEnvelopeForInPersonHybrid() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Map<String,Object> recipientDetailsMap = new Map<String,String>{
            'ID' => 'aAHO1000000CPCLOA4',
            'emailId' => 'jay1808@yopmail.com',
            'recipientId' => '003O100000Iz8nxIAB'
        };


        List<Map<String,Object>> requestListRecipient = new List <Map<String,Object>>();
        requestListRecipient.add(recipientDetailsMap);

        String expectedBody = '{"signers": [{"recipientId": "1","clientUserId": "003O100000Iz8nxIAB"},]}';

        System.runAs(userObj) {
            Test.startTest();
            String body = DocusignUtil.createRequestBodyToUpdateEnvelopeForInPersonHybrid(requestListRecipient);
            System.assertEquals(expectedBody, body, 'Assertion Failed');
            Test.stopTest();
        }
    }
    @isTest
    public static void inpersonDSpdateRecipientExceptionTest(){
        Test.setMock(HttpCalloutMock.class, new DocuSignErrorMock());
        Test.startTest();
        genesis__Applications__c objApplication=[Select Id, Signing_Method__c FROM genesis__Applications__c WHERE Signing_Method__c='In Person - Docusign'];
        List<dfsle__Envelope__c> envelope = [Select id,dfsle__DocuSignId__c from dfsle__Envelope__c];
        
        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        System.runAs(adminUser){
            System.enqueueJob(new InPersonDSUpdateRecipientCalloutAPI(envelope[0].id,objApplication.id, objApplication.Signing_Method__c)); 
        }
        System.assertEquals(true,envelope.size() > 0, 'No Envelope found ');
        Test.stopTest();
    } 
    @isTest 
    public static void inpersonDSUpdateRecipientWithoutEnvelope(){
        Test.setMock(HttpCalloutMock.class, new DocuSignErrorMock());
        Test.startTest();
        List<dfsle__Envelope__c> envelope =[Select id,dfsle__DocuSignId__c,dfsle__SourceId__c from dfsle__Envelope__c];
        
        genesis__Applications__c objApplication=[Select Id, Signing_Method__c FROM genesis__Applications__c WHERE Signing_Method__c='In Person - Docusign'];
        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        System.runAs(adminUser){     
            dfsle__Envelope__c recipientEnevelope = [SELECT Id FROM dfsle__Envelope__c Where Id =: envelope[0].id LIMIT 1];
            Database.delete(recipientEnevelope,true);
            System.enqueueJob(new InPersonDSUpdateRecipientCalloutAPI(envelope[0].id,objApplication.id, objApplication.Signing_Method__c)); 
        }
        List<dfsle__EnvelopeStatus__c> envelopeStatus = [SELECT Id,dfsle__DocuSignId__c FROM dfsle__EnvelopeStatus__c LIMIT 1];
        List<dfsle__Envelope__c> envelopeList = [SELECT Id FROM dfsle__Envelope__c WHERE dfsle__DocuSignId__c =: envelopeStatus[0].dfsle__DocuSignId__c];
        System.assertEquals(true,envelopeList.isEmpty(), 'Envelope Found');
        Test.stopTest();
    } 
    @isTest
    public static void testNullEnvelopeId(){
        Test.setMock(HttpCalloutMock.class, new DocuSignMock());
        Test.startTest();
        genesis__Applications__c objApplication=[Select Id, Signing_Method__c FROM genesis__Applications__c WHERE Signing_Method__c='In Person - Docusign'];
        List<dfsle__Envelope__c> envelope = [Select id,dfsle__DocuSignId__c from dfsle__Envelope__c];

        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        System.runAs(adminUser){
            System.enqueueJob(new InPersonDSUpdateRecipientCalloutAPI(null,objApplication.id, objApplication.Signing_Method__c)); 
        }
        System.assertEquals(true,envelope.size() > 0, 'No Envelope found ');
        Test.stopTest();
    }  
    @isTest
    public static void testInvalidAppId(){
        Test.setMock(HttpCalloutMock.class, new DocuSignMock());
        Test.startTest();
        genesis__Applications__c objApplication=[Select Id, Signing_Method__c FROM genesis__Applications__c WHERE Signing_Method__c='In Person - Docusign'];
        List<dfsle__Envelope__c> envelope = [Select id,dfsle__DocuSignId__c from dfsle__Envelope__c];

        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        System.runAs(adminUser){
            System.enqueueJob(new InPersonDSUpdateRecipientCalloutAPI(envelope[0].id,null, objApplication.Signing_Method__c)); 
        }
        System.assertEquals(true,envelope.size() > 0, 'No Envelope found ');
        Test.stopTest();
    } 
    @isTest
    public static void testNullSigningMethod(){
        Test.setMock(HttpCalloutMock.class, new DocuSignMock());
        Test.startTest();
        genesis__Applications__c objApplication=[Select Id, Signing_Method__c FROM genesis__Applications__c WHERE Signing_Method__c='In Person - Docusign'];
        List<dfsle__Envelope__c> envelope = [Select id,dfsle__DocuSignId__c from dfsle__Envelope__c];

        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        System.runAs(adminUser){
            System.enqueueJob(new InPersonDSUpdateRecipientCalloutAPI(envelope[0].id,objApplication.id, null)); 
        }
        System.assertEquals(true,envelope.size() > 0, 'No Envelope found ');
        Test.stopTest();
    } 
    @isTest
    public static void inpersonDSUpdateStatusTest(){
        Test.setMock(HttpCalloutMock.class, new DocuSignMock());
        Test.startTest();
        genesis__Applications__c objApplication=[Select Id, Signing_Method__c FROM genesis__Applications__c WHERE Signing_Method__c='In Person - Docusign'];
        List<dfsle__Envelope__c> envelope =[Select id from dfsle__Envelope__c];
       
        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        System.runAs(adminUser){
            System.enqueueJob(new InPersonDSUpdateStatusCallout(envelope[0].id,objApplication.id)); 
        }
        List<dfsle__EnvelopeStatus__c> status = [SELECT Id,dfsle__Status__c FROM dfsle__EnvelopeStatus__c WHERE dfsle__SourceId__c	=: objApplication.id LIMIT 1];

        System.assertEquals(true,status != null, 'Envelope not found ');
        Test.stopTest();
    }
    @isTest
    public static void inpersonDSUpdateStatusErrorTest(){
        Test.setMock(HttpCalloutMock.class, new DocuSignErrorMock());
        Test.startTest();
        genesis__Applications__c objApplication=[Select Id, Signing_Method__c FROM genesis__Applications__c WHERE Signing_Method__c='In Person - Docusign'];
        List<dfsle__Envelope__c> envelope =[Select id from dfsle__Envelope__c];
       
        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        System.runAs(adminUser){
            System.enqueueJob(new InPersonDSUpdateStatusCallout(envelope[0].id,objApplication.id));
        }
        System.assertEquals(true,envelope.size() > 0, 'Envelope not found ');
        Test.stopTest();
    }
    @isTest 
    public static void inpersonDSUpdateStatusLWithoutEnvelope(){
        Test.setMock(HttpCalloutMock.class, new DocuSignErrorMock());
        Test.startTest();
        List<dfsle__Envelope__c> envelope =[Select id,dfsle__DocuSignId__c,dfsle__SourceId__c from dfsle__Envelope__c];
        
        genesis__Applications__c objApplication=[Select Id, Signing_Method__c FROM genesis__Applications__c WHERE Signing_Method__c='In Person - Docusign'];
        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        System.runAs(adminUser){     
            dfsle__Envelope__c recipientEnevelope = [SELECT Id FROM dfsle__Envelope__c Where Id =: envelope[0].id LIMIT 1];
            Database.delete(recipientEnevelope,true);
            System.enqueueJob(new InPersonDSUpdateStatusCallout(envelope[0].id,objApplication.id)); 
        }
        List<dfsle__EnvelopeStatus__c> envelopeStatus = [SELECT Id,dfsle__DocuSignId__c FROM dfsle__EnvelopeStatus__c LIMIT 1];
        List<dfsle__Envelope__c> envelopeList = [SELECT Id FROM dfsle__Envelope__c WHERE dfsle__DocuSignId__c =: envelopeStatus[0].dfsle__DocuSignId__c];
        System.assertEquals(true,envelopeList.isEmpty(), 'Envelope Found');
        Test.stopTest();
    } 
    @isTest 
    public static void inpersonDSGetURLForCFATest(){
        Test.setMock(HttpCalloutMock.class, new DocuSignMock());
        Test.startTest();
        List<dfsle__Recipient__c> dsRecipientList = [SELECT Id,
                                                        dfsle__Email__c,
                                                        dfsle__SourceId__c,
                                                        dfsle__Role__c 
                                                    FROM dfsle__Recipient__c ];
        List<dfsle__Envelope__c> envelope =[Select id,dfsle__SourceId__c from dfsle__Envelope__c];
        
        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        System.runAs(adminUser){
            Map<String,String> paramMap = new Map<String,String>{
                'envelopeId' => envelope[0].id,
                'appId' => envelope[0].dfsle__SourceId__c,
                'contactId' =>dsRecipientList[0].dfsle__SourceId__c
            };
            System.enqueueJob(new InPersonDSGetURLCallout(paramMap,dsRecipientList[0].dfsle__Role__c)); 
        }
        Test.stopTest();
        clcommon__party__c recipientparty = [SELECT Id,DocuSign_URL__c FROM clcommon__Party__c Where clcommon__Contact__c =: dsRecipientList[0].dfsle__SourceId__c LIMIT 1];
        System.assertEquals(true,recipientparty.DocuSign_URL__c != null, 'URL not found ');
    } 
    @isTest 
    public static void inpersonDSGetURLForGrowmarkTest(){
        Test.setMock(HttpCalloutMock.class, new DocuSignMock());
        Test.startTest();
        List<dfsle__Recipient__c> dsRecipientList = [SELECT Id,
                                                        dfsle__Email__c,
                                                        dfsle__SourceId__c,
                                                        dfsle__Role__c 
                                                    FROM dfsle__Recipient__c ];
        List<dfsle__Envelope__c> envelope =[Select id,dfsle__SourceId__c from dfsle__Envelope__c];
        List<genesis__Applications__c> appList = [SELECT Id,Dealer_Name__c FROM genesis__Applications__c WHERE id =: envelope[0].dfsle__SourceId__c];
        Account dealerAccount = [SELECT Id,Coop_Type__c FROM Account WHERE Id =: appList[0].Dealer_Name__c];
        dealerAccount.Coop_Type__c = 'Growmark';
        Database.update(dealerAccount,true);
        
        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        clcommon__party__c recipientparty;
        System.runAs(adminUser){
            Map<String,String> paramMap = new Map<String,String>{
                'envelopeId' => envelope[0].id,
                'appId' => envelope[0].dfsle__SourceId__c,
                'contactId' =>dsRecipientList[0].dfsle__SourceId__c
            };
            System.enqueueJob(new InPersonDSGetURLCallout(paramMap,dsRecipientList[0].dfsle__Role__c)); 
        }
        Test.stopTest();
        recipientparty = [SELECT Id,DocuSign_URL__c FROM clcommon__Party__c Where clcommon__Contact__c =: dsRecipientList[0].dfsle__SourceId__c LIMIT 1];
        System.assertEquals(true,recipientparty.DocuSign_URL__c != null, 'URL not found ');
    } 
    @isTest 
    public static void inpersonDSGetURLForLandusTest(){
        Test.setMock(HttpCalloutMock.class, new DocuSignMock());
        Test.startTest();
        List<dfsle__Recipient__c> dsRecipientList = [SELECT Id,
                                                        dfsle__Email__c,
                                                        dfsle__SourceId__c,
                                                        dfsle__Role__c 
                                                    FROM dfsle__Recipient__c ];
        List<dfsle__Envelope__c> envelope =[Select id,dfsle__SourceId__c from dfsle__Envelope__c];
        List<genesis__Applications__c> appList = [SELECT Id,Dealer_Name__c FROM genesis__Applications__c WHERE id =: envelope[0].dfsle__SourceId__c];
        Account dealerAccount = [SELECT Id,Coop_Type__c FROM Account WHERE Id =: appList[0].Dealer_Name__c];
        dealerAccount.Coop_Type__c = 'Landus';
        Database.update(dealerAccount,true);
        
        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        System.runAs(adminUser){
            Map<String,String> paramMap = new Map<String,String>{
                'envelopeId' => envelope[0].id,
                'appId' => envelope[0].dfsle__SourceId__c,
                'contactId' =>dsRecipientList[0].dfsle__SourceId__c
            };
            System.enqueueJob(new InPersonDSGetURLCallout(paramMap,dsRecipientList[0].dfsle__Role__c)); 
        }
        Test.stopTest();
        clcommon__party__c recipientparty = [SELECT Id,DocuSign_URL__c FROM clcommon__Party__c Where clcommon__Contact__c =: dsRecipientList[0].dfsle__SourceId__c LIMIT 1];
        System.assertEquals(true,recipientparty.DocuSign_URL__c != null, 'URL not found ');
    } 
    @isTest 
    public static void inpersonDSGetURLInvalidRequestTest(){
        Test.setMock(HttpCalloutMock.class, new DocuSignErrorMock());
        Test.startTest();
        List<dfsle__Recipient__c> dsRecipientList = [SELECT Id,
                                                        dfsle__Email__c,
                                                        dfsle__SourceId__c,
                                                        dfsle__Role__c 
                                                    FROM dfsle__Recipient__c ];
        List<dfsle__Envelope__c> envelope =[Select id,dfsle__SourceId__c from dfsle__Envelope__c];
        

        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        System.runAs(adminUser){
            Map<String,String> paramMap = new Map<String,String>{
                'envelopeId' => envelope[0].id,
                'appId' => envelope[0].dfsle__SourceId__c,
                'contactId' =>dsRecipientList[0].dfsle__SourceId__c
            };
            System.enqueueJob(new InPersonDSGetURLCallout(paramMap,dsRecipientList[0].dfsle__Role__c)); 
        }
        clcommon__party__c recipientparty = [SELECT Id,DocuSign_URL__c FROM clcommon__Party__c Where clcommon__Contact__c =: dsRecipientList[0].dfsle__SourceId__c LIMIT 1];
        System.assertEquals(null,recipientparty.DocuSign_URL__c, 'URL found ');
        Test.stopTest();
    } 
    @isTest 
    public static void inpersonDSGetURLWithoutEnvelope(){
        Test.setMock(HttpCalloutMock.class, new DocuSignErrorMock());
        Test.startTest();
        List<dfsle__Recipient__c> dsRecipientList = [SELECT Id,
                                                        dfsle__Email__c,
                                                        dfsle__SourceId__c,
                                                        dfsle__Role__c 
                                                    FROM dfsle__Recipient__c ];
        List<dfsle__Envelope__c> envelope =[Select id,dfsle__SourceId__c from dfsle__Envelope__c];
        

        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        System.runAs(adminUser){
            Map<String,String> paramMap = new Map<String,String>{
                'envelopeId' => envelope[0].id,
                'appId' => envelope[0].dfsle__SourceId__c,
                'contactId' => dsRecipientList[0].dfsle__SourceId__c
            };
            dfsle__Envelope__c recipientEnevelope = [SELECT Id FROM dfsle__Envelope__c Where Id =: envelope[0].id LIMIT 1];
            Database.delete(recipientEnevelope,true);
            System.enqueueJob(new InPersonDSGetURLCallout(paramMap,dsRecipientList[0].dfsle__Role__c)); 
        }
        clcommon__party__c recipientparty = [SELECT Id,DocuSign_URL__c FROM clcommon__Party__c Where clcommon__Contact__c =: dsRecipientList[0].dfsle__SourceId__c LIMIT 1];
        System.assertEquals(null,recipientparty.DocuSign_URL__c, 'URL found ');
        Test.stopTest();
    } 

    @isTest
    public static void docuSignCreateAccessTokenTest(){
        String token;
        Test.startTest();
        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        System.runAs(adminUser){
            token = DocuSignCreateAccessToken.getAccessToken();
        }
        System.assertEquals(true,token != null, 'Unable to generate token ');
        Test.stopTest();
    }
    @isTest
    public static void docuSignCreateAccessTokenWithNullUserIdException(){
        String token;
        Test.startTest();
        User adminUser = [SELECT Id,Name FROM USER Where Profile.Name = 'System Administrator' and IsActive = true order by createddate asc Limit 1];
        CFA_Configuration__c docusignConfig = [SELECT Docusign_User_Id__c FROM CFA_Configuration__c LIMIT 1];
        docusignConfig.Docusign_User_Id__c = null;
        Database.update(docusignConfig,true);
        System.runAs(adminUser){
            token = DocuSignCreateAccessToken.getAccessToken();
        }
        System.assertEquals(ConstantValues.CREDENTIAL_ERROR,token, 'Unable to generate token ');
        Test.stopTest();
    }
    
}