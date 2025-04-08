/**********************************************************************************************
 * @className         : PortalApplicationEmbeddedURLFieldAPITest
 * @description       : Test Class for PortalApplicationEmbeddedURLFieldAPI
 * @author            : simran
 * @created Date      : 04-05-2022
 * @last modified on  : 05-10-2023
 * @last modified by  : Ayush Kumar Singh
 **********************************************************************************************/
@isTest
public  class PortalApplicationEmbeddedURLFieldAPITest {
    @TestSetup
    static void makeData(){
        genesis__Applications__c objApplication = TestClassHelper.createApplication();

    
        clcommon__Party_Type__c objPartyType = new clcommon__Party_Type__c();
        objPartyType.Name='BORROWER';
        Database.insert(objPartyType);

        //Principal
        clcommon__Party_Type__c objPrincipalPartyType = new clcommon__Party_Type__c();
        objPrincipalPartyType.Name='PRINCIPAL';
        Database.insert(objPrincipalPartyType);

        Profile profile = [SELECT Id FROM Profile WHERE Name='Sales Agent'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        Contact objContact = [SELECT Id,Email, accountId FROM Contact WHERE Id =:objUser.ContactId];
        objContact.FirstName='Rohit';
        objContact.MailingStreet='nhgv';
        objContact.MailingCity='uhngt';
        objContact.MailingState='cdfgh';
        objContact.Mailing_County__c='county';
        objContact.MailingPostalCode='12345';
        objContact.genesis__SSN__c='123456789';
        objContact.Birthdate=System.today().addYears(-35);
        objContact.Phone = '1231233455';
        objContact.Email = null;
        Database.update(objContact, false);

        Contact objPrincipalContact = TestClassHelper.createContact();
        objPrincipalContact.MailingStreet='nhgv';
        objPrincipalContact.MailingCity='uhngt';
        objPrincipalContact.MailingState='cdfgh';
        objPrincipalContact.Mailing_County__c='county';
        objPrincipalContact.MailingPostalCode='12345';
        objPrincipalContact.genesis__SSN__c='123456789';
        objPrincipalContact.Birthdate=System.today().addYears(-35);
        objPrincipalContact.Phone = '1231233455';
        Database.update(objPrincipalContact, false);
        
        genesis__Business_Information__c objBorrowerBusinessInfo = new genesis__Business_Information__c();
        objBorrowerBusinessInfo.genesis__Tax_Identification_Number__c='1234543';
        objBorrowerBusinessInfo.genesis__Total_Liabilities__c=2346;
        objBorrowerBusinessInfo.genesis__Total_Assets__c=987683;
        Database.insert(objBorrowerBusinessInfo);
        clcommon__Legal_Entity__c clEntity = New clcommon__Legal_Entity__c();
        clEntity.Name='Corporation';
        Database.insert(clEntity);
        
        Account objAccount = [SELECT Id, Name FROM Account WHERE Id =:objContact.accountId];
        objAccount.genesis__Business_Information__c=objBorrowerBusinessInfo.Id;
        objAccount.clcommon__Legal_Entity_Type__c=clEntity.Id;
        objAccount.BillingStreet='Rohit';
        objAccount.BillingPostalCode='12345';
        objAccount.Billing_County__c='fghu';
        objAccount.Work_Number__c='098765678';
        Database.update(objAccount);
        clcommon__Party__c objparty = new clcommon__Party__c(clcommon__Account__c = objAccount.Id ,
                                                                clcommon__Contact__c = objContact.Id, 
                                                                clcommon__User__c = objUser.Id,
                                                                clcommon__Type__c = objPartyType.Id,
                                                                genesis__Application__c = objApplication.Id,
                                                                Total_Assets__c = 10000,
                                                                Total_Liabilities__c = 1000,
                                                                DocuSign_Generation_Time__c = System.today().addDays(-1));
        Database.insert(objparty , false);
        clcommon__Party__c objPrincipalParty = new clcommon__Party__c(clcommon__Account__c = objAccount.Id ,
                                                                clcommon__Contact__c = objPrincipalContact.Id, 
                                                                clcommon__User__c = objUser.Id,
                                                                clcommon__Type__c = objPrincipalPartyType.Id,
                                                                genesis__Application__c = objApplication.Id,
                                                                Total_Assets__c = 10000,
                                                                Total_Liabilities__c = 1000,
                                                                DocuSign_Generation_Time__c = System.today().addDays(-1));
        Database.insert(objPrincipalParty , false);
    
        List<clcommon__Party__c> partyAssertList = [SELECT Id FROM clcommon__Party__c WHERE genesis__Application__c =: objApplication.Id];
        System.assert(partyAssertList.size() > 0, 'Party insertion error ');
       
        dfsle__Envelope__c envelope = new dfsle__Envelope__c();
        envelope.dfsle__SourceId__c = objApplication.Id;
        envelope.dfsle__DocuSignId__c = 'd5f4f3be-fe59-4819-aab1-1ded04720sf';
        Database.insert(envelope);

        List<dfsle__Envelope__c> envelopeAssertList = [SELECT Id 
                                                        FROM dfsle__Envelope__c 
                                                        WHERE dfsle__SourceId__c =: objApplication.Id ];
        System.assert(envelopeAssertList.size() > 0, 'Envelope insertion failed ');

        dfsle__EnvelopeStatus__c dsStatus = new dfsle__EnvelopeStatus__c();
        dsStatus.dfsle__SourceId__c = objApplication.Id; 
        dsStatus.dfsle__DocuSignId__c = 'd5f4f3be-fe59-4819-aab1-1ded04720sf';
        Database.insert(dsStatus);

        List<dfsle__EnvelopeStatus__c> dsStatusAssertList = [SELECT Id 
                                                            FROM dfsle__EnvelopeStatus__c 
                                                            WHERE dfsle__SourceId__c =: objApplication.Id];
        System.assert(dsStatusAssertList.size() > 0, 'DocuSign Status record insertion failed ');


        dfsle__Recipient__c dsRecipient = new dfsle__Recipient__c();
        dsRecipient.dfsle__Role__c = 'Signer 1';
        dsRecipient.dfsle__Envelope__c = envelopeAssertList[0].id;
        dsRecipient.dfsle__Email__c = 'abc@yopmail.com';
        dsRecipient.dfsle__SourceId__c = objContact.Id;
        Database.insert(dsRecipient,true);
        List<dfsle__Recipient__c> dsRecipientList = [SELECT Id,
                                                        dfsle__Email__c,
                                                        dfsle__SourceId__c,
                                                        dfsle__Role__c 
                                                    FROM dfsle__Recipient__c ];
        System.assert(dsRecipientList.size() > 0, 'DocuSign Status record insertion failed ');

        dfsle__RecipientStatus__c recipient = new dfsle__RecipientStatus__c();
        recipient.dfsle__EnvelopeStatus__c = dsStatusAssertList[0].Id;
        recipient.dfsle__Status__c = 'Sent';
        recipient.dfsle__SourceId__c = objContact.Id;
        Database.insert(recipient);

        List<dfsle__RecipientStatus__c> recipientAssertList = [SELECT Id 
                                                                FROM dfsle__RecipientStatus__c 
                                                                WHERE dfsle__EnvelopeStatus__c =: dsStatusAssertList[0].Id];
   
        System.assert(recipientAssertList.size() > 0, 'Recipients insertion failed ');
       
        }


    //Passing test data
    @isTest
    public static void TestPortalApplicationEmbeddedURLFieldAPI() {
        Test.startTest();
        Map<String, Object> requestMap = new Map<String, Object>();
        //genesis__Applications__c objApplication = new genesis__Applications__c();
        List<clcommon__Party__c> objPartyList = [SELECT Id,DocuSign_URL__c,DocuSign_Generation_Time__c FROM clcommon__Party__c];
        objPartyList[0].DocuSign_URL__c='https://embeddedURLSigning.docusign';
        objPartyList[0].DocuSign_Generation_Time__c = System.now();
        Database.update(objPartyList);

        List<genesis__Applications__c> appAssertList = [SELECT Id FROM genesis__Applications__c];
        System.assert(appAssertList.size() > 0, 'Application updation failed ');

        requestMap.put('application', Json.serialize(appAssertList[0]));
        PortalApplicationEmbeddedURLFieldAPI saveApi = new PortalApplicationEmbeddedURLFieldAPI();
        clcommon.Response objResponse = saveApi.invokeAction('',new List<String>(), requestMap);
        System.assertEquals(clcommon.Constants.SUCCESS, objResponse.status);
        Test.stopTest();
    }
    //Passing nothing 
    @isTest
    public static void TestPortalApplicationEmbeddedURLFieldAPI1(){
        Test.startTest();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('application', Json.serialize(null));
        PortalApplicationEmbeddedURLFieldAPI saveApi = new PortalApplicationEmbeddedURLFieldAPI();
        clcommon.Response objResponse = saveApi.invokeAction('',new List<String>(), requestMap);
        System.assertEquals(clcommon.Constants.API_EXCEPTION, objResponse.status);
        Test.stopTest();
    }
    //Passing blank value
    @isTest
    public static void TestPortalApplicationEmbeddedURLFieldAPI2(){
        Test.startTest();
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c objApplication = new genesis__Applications__c();
        Database.insert(objApplication);
        requestMap.put('application', Json.serialize(objApplication));
        PortalApplicationEmbeddedURLFieldAPI saveApi = new PortalApplicationEmbeddedURLFieldAPI();
        clcommon.Response objResponse = saveApi.invokeAction('',new List<String>(), requestMap);
        //System.assertEquals(clcommon.Constants.PENDING, objResponse.status);
        Test.stopTest();
    }
    //Passing null field value
    @isTest
    public static void TestPortalApplicationEmbeddedURLFieldAPI3(){
        Test.startTest();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('application', '');
        PortalApplicationEmbeddedURLFieldAPI saveApi = new PortalApplicationEmbeddedURLFieldAPI();
        clcommon.Response objResponse = saveApi.invokeAction('',new List<String>(), requestMap);
        System.assertEquals(clcommon.Constants.API_EXCEPTION, objResponse.status);
        Test.stopTest();
    }
    @isTest
    public static void TestPortalApplicationEmbeddedURLFieldAPI4(){
        Test.startTest();
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> objApplicationList = [Select id,Agreement_Sign__c from genesis__Applications__c];
        List<clcommon__Party__c> objPartyList = [SELECT Id,DocuSign_URL__c,DocuSign_Generation_Time__c FROM clcommon__Party__c];
        for(clcommon__Party__c party : objPartyList){
            party.DocuSign_Generation_Time__c = null;
        }
        objApplicationList[0].Agreement_Sign__c = true;
        Database.update(objPartyList,true);
        Database.update(objApplicationList,true);
        requestMap.put('application', Json.serialize(objApplicationList[0]));
        PortalApplicationEmbeddedURLFieldAPI saveApi = new PortalApplicationEmbeddedURLFieldAPI();
        clcommon.Response objResponse = saveApi.invokeAction('',new List<String>(), requestMap);
        System.assertEquals(clcommon.Constants.SUCCESS, objResponse.status);
        Test.stopTest();
    }

    @isTest 
    public static void TestPlatformEvent() {
        List<genesis__Applications__c> applist = [SELECT Id FROM genesis__Applications__c ];
        System.assert(applist.size() > 0, 'No Application found ');
        
        Test.startTest();
        List<DocuSignPlatformEvent__e > docuSignEvents = new List<DocuSignPlatformEvent__e>();
        docuSignEvents.add(new DocuSignPlatformEvent__e(Application_Id__c = applist[0].id ));
        List<Database.SaveResult> results = EventBus.publish(docuSignEvents);
        Test.stopTest();
    }
}