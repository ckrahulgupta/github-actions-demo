/**
 * @description       : Test Class to cover PortalDownloadPrePrintApplicationAPI
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 01-24-2025
 * @last modified by  : Ayan Khanra
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   14-07-2022   Subham Nandi   Initial Version
**/
@isTest
private without sharing class TestPortalDownloadPrePrintApplicationAPI {
    /**
    * @description : This method is used to prepare test data
    * @author Ayan Khanra | 01-18-2025 
    **/
    @TestSetup
    static void makeData() {
        ApplicationOriginationSetupTestHelper.createTestSetup();
        List<genesis__Applications__c>  applicationList= [SELECT ID,
                                                                genesis__Loan_Number__c,
                                                                Dealer_Name__c,
                                                                Dealer_Name__r.genesis__Business_Information__c 
                                                            FROM genesis__Applications__c 
                                                            WHERE Internal_Reference_Code__c = 'testApp001'];                                    
        ContentVersion contentVersionObj = ApplicationOriginationTestHelper.createContentVersion(new Map<String,String>{
                                                                                                'Title' => 'Pre Printed Application.pdf' },
                                                                                                'Test content for pre printed Application');
        Database.insert(contentVersionObj,true);
        createSaAdminUser(applicationList[0].Dealer_Name__r.genesis__Business_Information__c,applicationList[0].Dealer_Name__c,applicationList[0]);
        List<ContentDocument> contentDocumentList = getContentDocument();
        ContentDocumentLink contentDocumentLinkObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocumentList[0].Id,applicationList[0].Id);
        Database.insert(contentDocumentLinkObj,true);
        List<Contact> borrowerContactlist = [SELECT ID,
                                                    AccountId
                                                FROM Contact
                                                WHERE Email = 'jasmin.albin@yopmail.com' Limit 1];
        Dealer_Applicant_Relationship__c dealerAppRelationObj= ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactlist[0],applicationList[0].Dealer_Name__c);
        Database.insert(dealerAppRelationObj,true);
    }

    /**
    * @description : This method creates sa admin user
    * @author Ayan Khanra | 01-23-2025 
    * @param dealerBusinessInfoId 
    * @param dealerAccountId 
    * @param applicationObj 
    **/
    private static void createSaAdminUser(Id dealerBusinessInfoId,Id dealerAccountId,genesis__Applications__c applicationObj){ 
        //create account     
        Account salesAgentAdminAccountObj = ApplicationOriginationTestHelper.createSAAdminAccount(dealerBusinessInfoId,dealerAccountId);
        Database.insert(salesAgentAdminAccountObj,true);
        //create contact
        Contact salesAgentAdminContactObj = ApplicationOriginationTestHelper.createSAAdminContact(salesAgentAdminAccountObj.Id);
        Database.insert(salesAgentAdminContactObj,true);
        //create User
        User salesAgentAdminUserObj = ApplicationOriginationTestHelper.createSAAdminUser(salesAgentAdminContactObj.Id);
        Database.insert(salesAgentAdminUserObj,true);
        //create party type 
        clcommon__Party_Type__c saAdminPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('SALES AGENT ADMIN');
        Database.insert(saAdminPartyTypeObj,true);
        //create party
        Map<String,Id>  saAdminPartyMap = new Map<String,Id>{
            'accountId' => salesAgentAdminAccountObj.Id,
            'contactId' => salesAgentAdminContactObj.Id,
            'partyTypeId' => saAdminPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__Party__c sadminPartyObj = ApplicationOriginationTestHelper.createParty(saAdminPartyMap); 
        Database.insert(sadminPartyObj,true);
    }

    /**
    * @description This method is used to get the CL user record
    * @author Simran | 03-07-2024 
    * @return User 
    **/
    private static User getCertifiedLenderUser() {
        List<User> userList = [SELECT Id, 
                                        Contact.FirstName
                                FROM User
                                WHERE Username = 'ross.geller@yopmail.com'
                                LIMIT 1];
        return userList[0];      
    }

    /**
    * @description : This method is user to get application
    * @author Ayan Khanra | 01-18-2025 
    * @return List<genesis__Applications__c> 
    **/
    private static List<genesis__Applications__c> getApplication(){
        return [SELECT Id
                FROM genesis__Applications__c 
                WHERE Internal_Reference_Code__c ='testApp001' 
                LIMIT 1];
    }

    /**
    * @description : This method is used to get sales agent admin
    * @author Ayan Khanra | 01-18-2025 
    * @return User 
    **/
    private static User getSalesAgentAdminUser() {
        List<User> userList = [SELECT Id
                                FROM User
                                WHERE Username = 'tim.couper@yopmail.com'
                                LIMIT 1];
        return userList[0];      
    }

    /**
    * @description : This method is used to get sales agent admin party
    * @author Ayan Khanra | 01-18-2025 
    * @return List<clcommon__Party__c> 
    **/
    private static List<clcommon__Party__c> getSaAdminParty(){
        return [SELECT ID 
                FROM clcommon__party__c 
                WHERE clcommon__Type__r.Name = 'SALES AGENT ADMIN' LIMIT 1];
    }

    /**
    * @description : This method is to get content document
    * @author Ayan Khanra | 01-18-2025 
    * @return List<ContentDocument> 
    **/
    private static List<ContentDocument> getContentDocument(){
        return [SELECT ID 
                FROM ContentDocument 
                WHERE Title = 'Pre Printed Application.pdf' LIMIT 1];
    }

    /**
    * @description : This method returns inserted logs
    * @author Ayan Khanra | 01-16-2025  
    * @return List<clcommon__Log__c> 
    **/
    private static List<clcommon__Log__c> getInsertedLog(){
        return [SELECT ID
                FROM clcommon__Log__c 
                WHERE Name = 'PortalDownloadPrePrintApplicationAPI' Limit 1];
    }

    /**
    * @description Test success scenario by providing correct application id
    * @author Simran | 08-19-2024 
    **/
    @IsTest
    private static void testUrlSendSuccess() {
        List<genesis__Applications__c> applicationList = getApplication();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('applicationIdList', JSON.serialize(new List<Id>{applicationList[0].Id}));
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PortalDownloadPrePrintApplicationAPI downloadPrePrintAPIInst  = new PortalDownloadPrePrintApplicationAPI();
            clcommon.Response response = downloadPrePrintAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Exception occured while generation url');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method gives exception when the logged in user is sales agent admin and application id sent from portal instead party id.
    * @author Ayan Khanra | 01-18-2025 
    **/
    @IsTest
    private static void testForInvalidRequestParameterException(){
        List<genesis__Applications__c> applicationList = getApplication();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('applicationIdList', JSON.serialize(new List<Id>{applicationList[0].Id}));
        System.runAs(getSalesAgentAdminUser()) {
            Test.startTest();
            PortalDownloadPrePrintApplicationAPI downloadPrePrintAPIInst  = new PortalDownloadPrePrintApplicationAPI();
            clcommon.Response response = downloadPrePrintAPIInst.invokeAction('', new List<String>{}, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received although app id is passed instead party id');
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Log not inserted'); 
            Test.stopTest();
        }
    }

    /**
    * @description : Test exception scenario for not having valid application id
    * @author Ayan Khanra | 01-18-2025 
    **/
    @IsTest
    private static void testUrlSendException() {
        List<genesis__Applications__c> applicationList = getApplication();
        Database.delete(applicationList,true);
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('applicationIdList', JSON.serialize(new List<Id>{applicationList[0].Id}));
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PortalDownloadPrePrintApplicationAPI downloadPrePrintAPIInst  = new PortalDownloadPrePrintApplicationAPI();
            clcommon.Response response = downloadPrePrintAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received although application id is not valid');
            Test.stopTest();
        }
    }

    /**
    * @description : Success Scenario for SA Admin
    * @author Ayan Khanra | 01-18-2025 
    **/
    @IsTest
    private static void testUrlSendSuccessForSaAdminUser() {
        List<clcommon__party__c> saAdminpartyList = getSaAdminParty();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('applicationIdList', JSON.serialize(new List<Id>{saAdminpartyList[0].Id}));
        System.runAs(getSalesAgentAdminUser()) {
            Test.startTest();
            PortalDownloadPrePrintApplicationAPI downloadPrePrintAPIInst  = new PortalDownloadPrePrintApplicationAPI();
            clcommon.Response response = downloadPrePrintAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Success messge not received for sales agent admin user');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method gives exception for sales agent admin user for not having party
    * @author Ayan Khanra | 01-18-2025 
    **/
    @IsTest
    private static void testUrlSendExceptionForSaAdminUser() {
        List<clcommon__party__c> saAdminpartyList = getSaAdminParty();
        Database.delete(saAdminpartyList,true);                                            
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('applicationIdList', JSON.serialize(new List<Id>{saAdminpartyList[0].Id}));
        System.runAs(getSalesAgentAdminUser()) {
            Test.startTest();
            PortalDownloadPrePrintApplicationAPI downloadPrePrintAPIInst  = new PortalDownloadPrePrintApplicationAPI();
            clcommon.Response response = downloadPrePrintAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success response received although party of sa Admin not exist');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method sends pending status for if not having contentdocument(pre printed) for any of the application
    * @author Ayan Khanra | 01-18-2025 
    **/
    @IsTest
    private static void testPendingStatus() {
        List<genesis__Applications__c> applicationList = getApplication();
        List<ContentDocument> contentDocumentList = getContentDocument();
        ContentDocument contentDocumentObj = new contentDocument(Id = contentDocumentList[0].Id);
        contentDocumentObj.Title= 'Loan Amount Maturity.pdf'; 
        Database.update(contentDocumentObj,true);
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('applicationIdList', JSON.serialize(new List<Id>{applicationList[0].Id}));
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PortalDownloadPrePrintApplicationAPI downloadPrePrintAPIInst  = new PortalDownloadPrePrintApplicationAPI();
            clcommon.Response response = downloadPrePrintAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.PENDING, response.status, 'Response status is not pending');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method gives exception for no application id passed from portal and logs exception
    * @author Ayan Khanra | 01-18-2025 
    **/
    @IsTest
    private static void testForEmptyApplicationAndLogException(){
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('applicationIdList', JSON.serialize(new List<Id>()));
        System.runAs(getCertifiedLenderUser()) {
            Test.startTest();
            PortalDownloadPrePrintApplicationAPI downloadPrePrintAPIInst  = new PortalDownloadPrePrintApplicationAPI();
            clcommon.Response response = downloadPrePrintAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received although application id is missing');
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Log not inserted'); 
            Test.stopTest();
        }
    }
}