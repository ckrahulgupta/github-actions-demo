/**
 * @description       : Test class for PortalSaveSigningMethodAPI
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 01-24-2025
 * @last modified by  : Ayan Khanra
**/

@isTest
private with sharing class TestPortalSaveSigningMethodAPI {
    /**
    * @description : This test method is used to prepare test data
    * @author Ayan Khanra | 01-22-2025 
    **/
    @TestSetup
    static void makeData(){
        ApplicationOriginationSetupTestHelper.createTestSetup();
        List<genesis__Applications__c>  applicationList= [SELECT ID,
                                                                    genesis__Loan_Number__c,
                                                                    Dealer_Name__c 
                                                        FROM genesis__Applications__c 
                                                        WHERE Internal_Reference_Code__c = 'testApp001'];
        applicationList[0].Signing_Method__c ='In Person - Docusign';
        applicationList[0].Agreement_Sign__c = false;
        Database.update(applicationList,true);                                           
        ContentVersion contentVersionObj = ApplicationOriginationTestHelper.createContentVersion('Credit Application Agreement.pdf');
        Database.insert(contentVersionObj,true);
        ContentDocument contentDocumentObj = [SELECT Id 
                                            FROM ContentDocument 
                                            WHERE Title =: contentVersionObj.Title];
        ContentDocumentLink contentDocumentLinkObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocumentObj.id,applicationList[0].Id);
        Database.insert(contentDocumentLinkObj,true);
        clcommon__document_category__c documentCategoryObj = ApplicationOriginationTestHelper.createDocCategory(applicationList[0].Id,'Signed Credit Agreement');
        Database.insert(documentCategoryObj,true);
        clcommon__Category_Attachment_Association__c attachmentAssociationObj = ApplicationOriginationTestHelper.createAttachmentAssociation(documentCategoryObj,applicationList[0].Dealer_Name__c);
        attachmentAssociationObj.clcommon__Content_Document_Id__c = contentDocumentObj.Id;
        Database.insert(attachmentAssociationObj,true);
        List<clcommon__Party__c> partyList = [SELECT ID,
                                                    DocuSign_URL__c,
                                                    Sent_Url__c,DocuSign_Generation_Time__c 
                                            FROM clcommon__Party__c 
                                            WHERE genesis__Application__c=:applicationList[0].ID];
        for(clcommon__Party__c partyObj :partyList){
            partyObj.DocuSign_URL__c = 'www.example.com';
            partyObj.Sent_Url__c = true;
            partyObj.DocuSign_Generation_Time__c = Date.newInstance(2025, 1, 1);
        }
        Database.update(partyList,true);
        List<clcommon__Collateral_Category__c> collatralCategoryList = new List<clcommon__Collateral_Category__c>();
        collatralCategoryList.add(
            ApplicationOriginationTestHelper.createCollateralCategory()
        );
        Database.insert(collatralCategoryList,true);
        clcommon__collateral__c collateralObj = ApplicationOriginationTestHelper.createCollateral(new Map<String, String>{'collateralCategoryId' => collatralCategoryList[0].id});
        collateralObj.genesis__Application__c = applicationList[0].Id;
        collateralObj.Price__c = 100000;
        Database.insert(collateralObj,true);
        Task signingTaskObj = ApplicationOriginationTestHelper.createTask(applicationList[0].Id);
        Database.insert(signingTaskObj,true);
    }

    /**
    * @description : Returnes borrower party details map
    * @author Soumik Pattanayak | 13-01-2025 
    * @param borrowerPartyObj 
    * @return Map<String, String> 
    **/
    private static Map<String,String> getBorrowerPartyMap(clcommon__party__c borrowerPartyObj){
        return new Map<String,String>{'id'=> String.valueOf(borrowerPartyObj.Id),
                                    'clcommon__Account__r.Name'=>'Jasmine Albin',
                                    'clcommon__Contact__r.Email'=>'jasmin.albin@yopmail.com',
                                    'clcommon__Type__r.Name'=>'BORROWER',
                                    'clcommon__Account__r.Is_Individual__c'=>'true'};
    }

    /**
    * @description : Returnes principal party detail map
    * @author Soumik Pattanayak | 13-01-2025 
    * @param principalPartyObj 
    * @return Map<String, String> 
    **/
    private static Map<String,String> getPrincipalPartyMap(clcommon__party__c principalPartyObj){
        return new Map<String,String>{'id'=> String.valueOf(principalPartyObj.Id) ,
                                    'clcommon__Account__r.Name'=>'Mike Johnson',
                                    'clcommon__Contact__r.Email'=>'mike.johnson@yopmail.com',
                                    'clcommon__Type__r.Name'=>'PRINCIPAL',
                                    'clcommon__Account__r.Is_Individual__c'=>'true'};
    }

    /**
    * @description : Returnes application
    * @author Ayan Khanra | 01-22-2025 
    * @return genesis__Applications__c 
    **/
    private static List<genesis__Applications__c> getApplication(){
        return [SELECT ID,
                        genesis__Loan_Number__c,
                        Dealer_Name__c,
                        Signing_Method__c,
                        genesis__Status__c,
                        DocuSign_Credit_Agreement_Initiated__c,
                        Stage__c 
                FROM genesis__Applications__c 
                WHERE Internal_Reference_Code__c = 'testApp001' LIMIT 1];
    }

    /**
    * @description : Returnes party depending on party type and application id
    * @author Ayan Khanra | 01-22-2025 
    * @param partyType 
    * @param applicationId 
    * @return clcommon__party__c 
    **/
    private static clcommon__party__c getParty(String partyType,Id applicationId){
        return [SELECT id,
                        clcommon__Contact__c 
                FROM clcommon__Party__c 
                WHERE clcommon__Party_Types__c = :partyType
                AND genesis__Application__c = :applicationId LIMIT 1];
    }

    /**
    * @description : Returnes grower user
    * @author Ayan Khanra | 01-22-2025 
    * @return List<User> 
    **/
    private static List<User> getGrowerUser(){
        return [SELECT Id,
                        ContactId 
                FROM User 
                WHERE UserName = 'star.lord@yopmail.com' 
                LIMIT 1];
    }

    /**
    * @description : Returnes borrower account
    * @author Ayan Khanra | 01-22-2025 
    * @return List<Account> 
    **/
    private static List<Account> getBorrowerAccount(){
        return [SELECT ID,
                        genesis__Business_information__c,
                        clcommon__Legal_Entity_Type__r.Name 
                FROM Account 
                WHERE Name = 'Jasmine Albin' 
                LIMIT 1];
    }

    /**
    * @description : Returnes inserted logs
    * @author Ayan Khanra | 01-22-2025 
    * @return List<clcommon__Log__c> 
    **/
    private static List<clcommon__Log__c> getInsertedLog(){
        return [SELECT ID
                FROM clcommon__Log__c 
                WHERE Name = 'PortalSaveSigningMethodAPI' Limit 1];
    }

    /**
    * @description : This test method succcesfully deletes the existing contentdoument, category attachment if already signing method exist
    * @author Ayan Khanra | 01-22-2025 
    **/
    @isTest
    private static void testDeleteExistingDocumentSucesses(){
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        clcommon__party__c borrowerPartyObj = getParty(PortalConstants.BORROWER_PARTY_NAME,applicationList[0].Id);
        clcommon__party__c principalPartyObj = getParty(PortalConstants.PRINCIPAL_PARTY_NAME,applicationList[0].Id);
        Map <String, Object> principalPartyMap = getPrincipalPartyMap(principalPartyObj);
        Map <String, Object> borrowerPartyMap = getBorrowerPartyMap(borrowerPartyObj);
        List<User> growerUserList = getGrowerUser();
        requestMap.put('signingMethod', PortalConstants.PAPER_SCANNED);
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        requestMap.put('applicantDetails', JSON.serialize(new List<Map<String, Object>>{principalPartyMap, borrowerPartyMap}));
        System.runAs(growerUserList[0]){
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Exception occured');
            Test.stopTest();
        } 
        List<clcommon__document_category__c> documentCategoryList = [SELECT Id 
                                                                        FROM clcommon__document_category__c 
                                                                        WHERE clcommon__Category_Name__c ='Signed Credit Agreement'];
        List<clcommon__Category_Attachment_Association__c> categoryAttachmentList = [SELECT Id, 
                                                                                            Name, 
                                                                                            clcommon__Document_Category__c, 
                                                                                            clcommon__Content_Document_Id__c 
                                                                                        FROM clcommon__Category_Attachment_Association__c 
                                                                                        WHERE clcommon__Document_Category__c = :documentCategoryList[0].Id];
        List<ContentDocumentLink>  contentDocumentLinkList = [SELECT Id, 
                                                                    LinkedEntityId, 
                                                                    ContentDocumentId 
                                                                FROM ContentDocumentLink 
                                                                WHERE LinkedEntityId = :applicationList[0].Id];                                                    
        List<ContentDocument> contentDocumentList = [SELECT ID 
                                                        FROM ContentDocument 
                                                        WHERE Title='Credit Application Agreement.pdf']; 
        List<genesis__Applications__c> updatedApplicationList = getApplication();                                            
        System.assertEquals(0, contentDocumentList.size(),'Content document not deleted');    
        System.assertEquals(0, categoryAttachmentList.size(),'Category Attachment not deleted'); 
        System.assertEquals(0, contentDocumentLinkList.size(),'content document link not deleted');
        System.assertEquals(PortalConstants.PAPER_SCANNED,updatedApplicationList[0].Signing_Method__c,'Signing method value did not changed'); 
    }

    /**
    * @description This test method gives exception for Missing Signing method 
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest
    private static void testSigningMethodMissingException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        List<User> growerUserList = getGrowerUser();
        clcommon__party__c borrowerPartyObj = getParty(PortalConstants.BORROWER_PARTY_NAME,applicationList[0].Id);
        Map<String, Object> borrowerPartyMap = getBorrowerPartyMap(borrowerPartyObj);
        requestMap.put('applicantDetails', JSON.serialize(new List<Map<String, Object>>{borrowerPartyMap}));
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        System.runAs(growerUserList[0]) {
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method gives exception for Missing Application Id in request parameter and logs exception
    * @author Ayan Khanra | 01-22-2025 
    **/
    @isTest
    private static void testApplicationIdMissingAndLogException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<User> growerUserList = getGrowerUser();
        requestMap.put('applicantDetails', 'Send Party Details');
        requestMap.put('signingMethod', PortalConstants.PAPER_SCANNED);
        System.runAs(growerUserList[0]) {
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received');
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Log not inserted');
            Test.stopTest();
        }
    }

    /**
    * @description :  This test method gives exception for Missing 'applicantDetails' in req parameter
    * @author Ayan Khanra | 01-22-2025 
    **/
    @isTest
    private static void testApplicantDetailMissingException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        List<User> growerUserList = getGrowerUser();
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        requestMap.put('signingMethod', PortalConstants.PAPER_SCANNED);
        System.runAs(growerUserList[0]) {
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method gives exception as logged in user's party is not valid
    * @author Ayan Khanra | 01-22-2025 
    **/
    @isTest
    private static void testNotValidUserException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        clcommon__party__c borrowerPartyObj = getParty(PortalConstants.BORROWER_PARTY_NAME,applicationList[0].Id);
        clcommon__party__c principalPartyObj = getParty(PortalConstants.PRINCIPAL_PARTY_NAME,applicationList[0].Id);
        Map <String, Object> principalPartyMap = getPrincipalPartyMap(principalPartyObj);
        Map <String, Object> borrowerPartyMap = getBorrowerPartyMap(borrowerPartyObj);
        List<User> growerUserList = getGrowerUser();
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        requestMap.put('signingMethod', PortalConstants.PAPER_SCANNED);
        requestMap.put('applicantDetails', JSON.serialize(new List<Map<String, Object>>{principalPartyMap, borrowerPartyMap}));
        Database.delete([SELECT ID FROM clcommon__Party__c WHERE clcommon__Contact__c IN (SELECT ID FROM Contact WHERE Email = 'jasmin.albin@yopmail.com') LIMIT 1],true);
        System.runAs(growerUserList[0]) {
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method gives exception if borrower legal entity type not in sole prop or dba and total asset is null
    * @author Ayan Khanra | 01-22-2025 
    **/
    @isTest
    private static void testNullAssestsForCorporationBorrowerException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        List<Account> borrowerAccountList = getBorrowerAccount();
        borrowerAccountList[0].clcommon__Legal_Entity_Type__r.Name = PortalConstants.TRUST;
        Database.update(borrowerAccountList,true);
        clcommon__party__c borrowerPartyObj = getParty(PortalConstants.BORROWER_PARTY_NAME,applicationList[0].Id);
        borrowerPartyObj.Total_Assets__c = null;
        Database.update(borrowerPartyObj,true);
        clcommon__party__c principalPartyObj = getParty(PortalConstants.PRINCIPAL_PARTY_NAME,applicationList[0].Id);
        Map <String, Object> principalPartyMap = getPrincipalPartyMap(principalPartyObj);
        Map <String, Object> borrowerPartyMap = getBorrowerPartyMap(borrowerPartyObj);
        List<User> growerUserList = getGrowerUser();
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        requestMap.put('signingMethod', PortalConstants.PAPER_SCANNED);
        requestMap.put('applicantDetails', JSON.serialize(new List<Map<String, Object>>{principalPartyMap, borrowerPartyMap}));
        System.runAs(growerUserList[0]) {
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method checks for successfull task status update, Docuign credit agreement status update, application status update for Email Docusign
    * @author Ayan Khanra | 01-22-2025 
    **/
    @isTest
    private static void testEmailDocusignAndTaskStatusUpdateSucesses() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        clcommon__party__c borrowerPartyObj = getParty(PortalConstants.BORROWER_PARTY_NAME,applicationList[0].Id);
        clcommon__party__c principalPartyObj = getParty(PortalConstants.PRINCIPAL_PARTY_NAME,applicationList[0].Id);
        Map <String, Object> principalPartyMap = getPrincipalPartyMap(principalPartyObj);
        Map <String, Object> borrowerPartyMap = getBorrowerPartyMap(borrowerPartyObj);
        List<User> growerUserList = getGrowerUser();
        requestMap.put('signingMethod', ConstantValues.EMAIL_DOCUSIGN);
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        requestMap.put('applicantDetails', JSON.serialize(new List<Map<String, Object>>{principalPartyMap, borrowerPartyMap}));
        System.runAs(growerUserList[0]){
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Exception occured for Email docusign');                    
            Test.stopTest();
        }
        List<Task> signedAgreementTaskList = [SELECT Id, 
                                                    Subject,
                                                    Status
                                                FROM Task
                                                WHERE Subject = 'Signed Credit Agreement'
                                                AND genesis__Application__c = :applicationList[0].Id];
        System.assertEquals('OPEN', signedAgreementTaskList[0].Status,'Task status not updated');
        List<genesis__Applications__c> updatedApplicationList = getApplication();
        System.assertEquals(false, updatedApplicationList[0].DocuSign_Credit_Agreement_Initiated__c,'Docusign credit agreement status not updated'); 
        System.assertEquals(PortalConstants.E_SIGN_PENDING_APPLICATION_STATUS, updatedApplicationList[0].genesis__Status__c,'Application status not changed');         
    }

    /**
    * @description : This test method throws exception If only one party exist and that in not individual 
    * @author Ayan Khanra | 01-22-2025 
    **/
    @isTest
    private static void testForNotIndividualPartyException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        clcommon__party__c borrowerPartyObj = getParty(PortalConstants.BORROWER_PARTY_NAME,applicationList[0].Id);
        clcommon__party__c principalPartyObj = getParty(PortalConstants.PRINCIPAL_PARTY_NAME,applicationList[0].Id);
        Map <String, Object> principalPartyMap = getPrincipalPartyMap(principalPartyObj);
        Map <String, Object> borrowerPartyMap = getBorrowerPartyMap(borrowerPartyObj);
        List<clcommon__party__c> partyList = [SELECT Id, 
                                                        genesis__Application__c
                                            FROM clcommon__Party__c
                                            WHERE genesis__Application__r.Id=:applicationList[0].Id 
                                            AND clcommon__Type__r.Name !='BORROWER'];                           
        Database.delete(partyList,true);
        List<Account> borrowerAccountList = getBorrowerAccount();
        borrowerAccountList[0].clcommon__Legal_Entity_Type__r.Name = 'Corporation';
        Database.update(borrowerAccountList,true);                              
        List<User> growerUserList = getGrowerUser();
        requestMap.put('signingMethod', ConstantValues.EMAIL_DOCUSIGN);
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        requestMap.put('applicantDetails', JSON.serialize(new List<Map<String, Object>>{principalPartyMap, borrowerPartyMap}));
        System.runAs(growerUserList[0]){
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method gives exception if the account of borrower is not linked with the party
    * @author Ayan Khanra | 01-22-2025 
    **/
    @isTest
    private static void testBorrowerAccountMissingException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        clcommon__party__c borrowerPartyObj = getParty(PortalConstants.BORROWER_PARTY_NAME,applicationList[0].Id);
        clcommon__party__c principalPartyObj = getParty(PortalConstants.PRINCIPAL_PARTY_NAME,applicationList[0].Id);
        Map <String, Object> principalPartyMap = getPrincipalPartyMap(principalPartyObj);
        Map <String, Object> borrowerPartyMap = getBorrowerPartyMap(borrowerPartyObj);     
        List<User> growerUserList = getGrowerUser();
        borrowerPartyObj.clcommon__Account__c = null;
        Database.update(borrowerPartyObj,true);
        requestMap.put('signingMethod', ConstantValues.EMAIL_DOCUSIGN);
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        requestMap.put('applicantDetails', JSON.serialize(new List<Map<String, Object>>{principalPartyMap, borrowerPartyMap}));
        System.runAs(growerUserList[0]){
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method gives exception if the contact of borrower is not linked with the party
    * @author Ayan Khanra | 01-22-2025 
    **/
    @isTest
    private static void testBorrowerContactMissingException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        clcommon__party__c borrowerPartyObj = getParty(PortalConstants.BORROWER_PARTY_NAME,applicationList[0].Id);
        clcommon__party__c principalPartyObj = getParty(PortalConstants.PRINCIPAL_PARTY_NAME,applicationList[0].Id);
        Map <String, Object> principalPartyMap = getPrincipalPartyMap(principalPartyObj);
        Map <String, Object> borrowerPartyMap = getBorrowerPartyMap(borrowerPartyObj);     
        List<User> growerUserList = getGrowerUser();
        borrowerPartyObj.clcommon__Contact__c = null;
        Database.update(borrowerPartyObj,true);
        requestMap.put('signingMethod', ConstantValues.EMAIL_DOCUSIGN);
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        requestMap.put('applicantDetails', JSON.serialize(new List<Map<String, Object>>{principalPartyMap, borrowerPartyMap}));
        System.runAs(growerUserList[0]){
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method gives exception if the business info of borrower is missing  
    * @author Ayan Khanra | 01-22-2025 
    **/
    @isTest
    private static void testBorrowerBusinessInfoMissingException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        clcommon__party__c borrowerPartyObj = getParty(PortalConstants.BORROWER_PARTY_NAME,applicationList[0].Id);
        clcommon__party__c principalPartyObj = getParty(PortalConstants.PRINCIPAL_PARTY_NAME,applicationList[0].Id);
        Map <String, Object> principalPartyMap = getPrincipalPartyMap(principalPartyObj);
        Map <String, Object> borrowerPartyMap = getBorrowerPartyMap(borrowerPartyObj);     
        List<User> growerUserList = getGrowerUser();
        List<Account> borrowerAccountList = getBorrowerAccount();
        borrowerAccountList[0].genesis__Business_information__c = null;
        Database.update(borrowerAccountList,true);
        requestMap.put('signingMethod', ConstantValues.EMAIL_DOCUSIGN);
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        requestMap.put('applicantDetails', JSON.serialize(new List<Map<String, Object>>{principalPartyMap, borrowerPartyMap}));
        System.runAs(growerUserList[0]){
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method gives exception if the size partylist received from portal and the size of parties queried with application id are not same 
    * @author Ayan Khanra | 01-22-2025 
    **/
    @isTest
    private static void testInvalidPartySizeException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        List<Map<String,Object>> applicationDetailMapList = new List<Map<String, Object>>();
        clcommon__party__c borrowerPartyObj = getParty(PortalConstants.BORROWER_PARTY_NAME,applicationList[0].Id);
        clcommon__party__c principalPartyObj = getParty(PortalConstants.PRINCIPAL_PARTY_NAME,applicationList[0].Id);
        Map <String, Object> principalPartyMap = getPrincipalPartyMap(principalPartyObj);
        Map <String, Object> borrowerPartyMap = getBorrowerPartyMap(borrowerPartyObj);     
        List<User> growerUserList = getGrowerUser();
        applicationDetailMapList.add(principalPartyMap);
        applicationDetailMapList.add(borrowerPartyMap);
        Database.delete(principalPartyObj,true);
        requestMap.put('signingMethod', ConstantValues.EMAIL_DOCUSIGN);
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        requestMap.put('applicantDetails', JSON.serialize(applicationDetailMapList));
        System.runAs(growerUserList[0]){
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received');
            Test.stopTest();
        }                                      
    }

    /**
    * @description : This test method successfully updates the email 
    * @author Ayan Khanra | 01-22-2025 
    **/
    @isTest
    private static void testEmailChangeSuccess() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        clcommon__party__c borrowerPartyObj = getParty(PortalConstants.BORROWER_PARTY_NAME,applicationList[0].Id);
        clcommon__party__c principalPartyObj = getParty(PortalConstants.PRINCIPAL_PARTY_NAME,applicationList[0].Id);
        Map <String, Object> principalPartyMap = getPrincipalPartyMap(principalPartyObj);
        Map <String, Object> borrowerPartyMap = getBorrowerPartyMap(borrowerPartyObj);
        borrowerPartyMap.put('clcommon__Contact__r.Email','testborrower@yopmail.com');
        List<User> growerUserList = getGrowerUser();
        requestMap.put('signingMethod', ConstantValues.EMAIL_DOCUSIGN);
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        requestMap.put('applicantDetails', JSON.serialize(new List<Map<String, Object>>{principalPartyMap, borrowerPartyMap}));
        System.runAs(growerUserList[0]){
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Exception occured for Email change');
            Test.stopTest();
        }
        List<Contact> borrowerContactList = [SELECT ID,
                                                    Email 
                                            FROM Contact 
                                            WHERE Id =:borrowerPartyObj.clcommon__Contact__c];
        System.assertEquals('testborrower@yopmail.com', borrowerContactList[0].Email,'Email field value not changed');                                      
    }

    /**
    * @description : This test method gives exception if email field comes from portal is null
    * @author Ayan Khanra | 01-22-2025 
    **/
    @isTest
    private static void testEmailChangeException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        clcommon__party__c borrowerPartyObj = getParty(PortalConstants.BORROWER_PARTY_NAME,applicationList[0].Id);
        clcommon__party__c principalPartyObj = getParty(PortalConstants.PRINCIPAL_PARTY_NAME,applicationList[0].Id);
        Map <String, Object> principalPartyMap = getPrincipalPartyMap(principalPartyObj);
        Map <String, Object> borrowerPartyMap = getBorrowerPartyMap(borrowerPartyObj);
        borrowerPartyMap.put('clcommon__Contact__r.Email',null);
        List<User> growerUserList = getGrowerUser();
        requestMap.put('signingMethod', ConstantValues.EMAIL_DOCUSIGN);
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        requestMap.put('applicantDetails', JSON.serialize(new List<Map<String, Object>>{principalPartyMap, borrowerPartyMap}));
        System.runAs(growerUserList[0]){
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received');
            Test.stopTest();
        }                                     
    }

    /**
    * @description : This test method gives exception for Empty Task
    * @author Ayan Khanra | 01-22-2025 
    **/
    @isTest
    private static void testTaskEmptyException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        clcommon__party__c borrowerPartyObj = getParty(PortalConstants.BORROWER_PARTY_NAME,applicationList[0].Id);
        clcommon__party__c principalPartyObj = getParty(PortalConstants.PRINCIPAL_PARTY_NAME,applicationList[0].Id);
        Map <String, Object> principalPartyMap = getPrincipalPartyMap(principalPartyObj);
        Map <String, Object> borrowerPartyMap = getBorrowerPartyMap(borrowerPartyObj);
        List<User> growerUserList = getGrowerUser();
        requestMap.put('signingMethod', ConstantValues.EMAIL_DOCUSIGN);
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        requestMap.put('applicantDetails', JSON.serialize(new List<Map<String, Object>>{principalPartyMap, borrowerPartyMap}));
        List<Task> signedAgreementTaskList = [SELECT Id, 
                                                    Subject,
                                                    Status
                                            FROM Task
                                            WHERE Subject = 'Signed Credit Agreement' AND 
                                            genesis__Application__c = :applicationList[0].Id];
        Database.delete(signedAgreementTaskList,true);                                    
        System.runAs(growerUserList[0]){
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received');
            Test.stopTest();
        }                                     
    }

    /**
    * @description  : This test method gives exception for no grower party
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest
    private static void testNoGrowerPartyException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        clcommon__party__c borrowerPartyObj = getParty(PortalConstants.BORROWER_PARTY_NAME,applicationList[0].Id);
        borrowerPartyObj.genesis__Application__c = null;
        clcommon__party__c principalPartyObj = getParty(PortalConstants.PRINCIPAL_PARTY_NAME,applicationList[0].Id);
        principalPartyObj.genesis__Application__c = null;
        Database.update(new List<clcommon__party__c>{borrowerPartyObj,principalPartyObj},true);
        Map <String, Object> principalPartyMap = getPrincipalPartyMap(principalPartyObj);
        Map <String, Object> borrowerPartyMap = getBorrowerPartyMap(borrowerPartyObj);
        List<User> growerUserList = getGrowerUser();
        requestMap.put('signingMethod', ConstantValues.EMAIL_DOCUSIGN);
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        requestMap.put('applicantDetails', JSON.serialize(new List<Map<String, Object>>{principalPartyMap, borrowerPartyMap}));
        System.runAs(growerUserList[0]){
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received');
            Test.stopTest();
        }
    }

    /**
    * @description  : This test method gives excepion for invalid type of signing method
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest
    private static void testPortalSaveSigningMethodAPIException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        clcommon__party__c borrowerPartyObj = getParty(PortalConstants.BORROWER_PARTY_NAME,applicationList[0].Id);
        clcommon__party__c principalPartyObj = getParty(PortalConstants.PRINCIPAL_PARTY_NAME,applicationList[0].Id);
        Map <String, Object> principalPartyMap = getPrincipalPartyMap(principalPartyObj);
        Map <String, Object> borrowerPartyMap = getBorrowerPartyMap(borrowerPartyObj);
        List<User> growerUserList = getGrowerUser();
        requestMap.put('signingMethod', 123);
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        requestMap.put('applicantDetails', JSON.serialize(new List<Map<String, Object>>{principalPartyMap, borrowerPartyMap}));
        System.runAs(growerUserList[0]){
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method gives exception if no party id passed form portal
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest
    private static void testPartyIdMissingApiException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        List<User> growerUserList = getGrowerUser();
        requestMap.put('signingMethod', 'Email - Docusign');
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        requestMap.put('applicantDetails', JSON.serialize(new List<Map<String, Object>>{new Map<String, Object>{'clcommon__Account__r.Name' => 'Rohit', 'clcommon__Type__r.Name' => 'PRINCIPAL'},
                                                                                        new Map<String, Object>{'clcommon__Account__r.Name' => 'Sam', 'clcommon__Type__r.Name' => 'PRINCIPAL'}}));
        System.runAs(growerUserList[0]) {
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received');
            Test.stopTest();
        }
    }
    
    /**
    * @description : This test method gives success response for In person docusign
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest
    private static void testSigningMethodInPersonDocusign() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        clcommon__party__c borrowerPartyObj = getParty(PortalConstants.BORROWER_PARTY_NAME,applicationList[0].Id);
        clcommon__party__c principalPartyObj = getParty(PortalConstants.PRINCIPAL_PARTY_NAME,applicationList[0].Id);
        Map <String, Object> principalPartyMap = getPrincipalPartyMap(principalPartyObj);
        Map <String, Object> borrowerPartyMap = getBorrowerPartyMap(borrowerPartyObj);
        List<User> growerUserList = getGrowerUser();
        requestMap.put('signingMethod', 'In Person - Docusign');
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        requestMap.put('applicantDetails', JSON.serialize(new List<Map<String, Object>>{principalPartyMap, borrowerPartyMap}));
        System.runAs(growerUserList[0]){
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Exception occured for In person dousign');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method checks for successfull task status update, Docuign credit agreement status update, application status update for Email Docusign
    * @author Ayan Khanra | 01-22-2025 
    **/
    @isTest
    private static void testForClUserSuccess() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = getApplication();
        clcommon__party__c borrowerPartyObj = getParty(PortalConstants.BORROWER_PARTY_NAME,applicationList[0].Id);
        clcommon__party__c principalPartyObj = getParty(PortalConstants.PRINCIPAL_PARTY_NAME,applicationList[0].Id);
        Map <String, Object> principalPartyMap = getPrincipalPartyMap(principalPartyObj);
        Map <String, Object> borrowerPartyMap = getBorrowerPartyMap(borrowerPartyObj);
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        requestMap.put('signingMethod', ConstantValues.EMAIL_DOCUSIGN);
        requestMap.put('application', JSON.serialize(new Map<String, Object>{'Id' => String.valueOf(applicationList[0].Id)}));
        requestMap.put('applicantDetails', JSON.serialize(new List<Map<String, Object>>{principalPartyMap, borrowerPartyMap}));
        System.runAs(clUserObj){
            Test.startTest();
            PortalSaveSigningMethodAPI saveSigningAPIInst = new PortalSaveSigningMethodAPI();
            clcommon.Response response = saveSigningAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Exception occured for Email docusign');
            Test.stopTest();
        }                           
    }
}