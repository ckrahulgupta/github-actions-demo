/**
 * @description       : Test class for PortalDownloadCBRReportAPI
 * @author            : Simran
 * @group             : 
 * @last modified on  : 06-28-2024
 * @last modified by  : Simran
**/
@isTest
public without sharing class PortalDownloadCBRReportAPITest {
    @TestSetup
    static void makeData() {
        Map<String,Id> objectVsIdMap=new Map<String,Id>();
        genesis__Business_Information__c businessInformationObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInformationObj,true);
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInformationObj.Id);
        Database.insert(dealerAccountObj, true);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInformationObj.Id,dealerAccountObj.Id);
        Database.insert(clAccountObj, true);
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);
        User userObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        Database.insert(userObj,true);
        clcommon__CL_Product__c clProductObj=ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);
        clcommon__CL_Purpose__c clPurposeObj=ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj,true);
        clcommon__Legal_Entity__c entityObj= ApplicationOriginationTestHelper.createLegalEntity('Individual(s) - Sole Proprietorship');
        Database.insert(entityObj,true);
        Account accountObj=ApplicationOriginationTestHelper.createSolePropAccount(entityObj,businessInformationObj.Id);
        accountObj.Score_1__c='564';
        accountObj.SBSS70_Score__c='78';
        Database.insert(accountObj,true);
        Contact contactObj=ApplicationOriginationTestHelper.createBorrowerContact(accountObj.Id);
        Database.insert(contactObj,true);
        objectVsIdMap.put('dealerAccountId',dealerAccountObj.Id);
        objectVsIdMap.put('clProductId',clProductObj.Id);
        objectVsIdMap.put('clPurposeId',clPurposeObj.Id);
        objectVsIdMap.put('borrowerAccountId',accountObj.Id);
        objectVsIdMap.put('borrowerContactId',contactObj.Id);
        objectVsIdMap.put('clAccountId',clAccountObj.Id);
        genesis__Applications__c currApplicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(objectVsIdMap);
        currApplicationObj.FICO_Score__c='564';
        currApplicationObj.SBSS_70_Score__c='78';
        Database.insert(currApplicationObj,true);
        clcommon__Party_Type__c partyTypeObj=ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(partyTypeObj,true);
        clcommon__Party_Type__c clpartyTypeObj=ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(clpartyTypeObj,true);
        objectVsIdMap.put('accountId',accountObj.Id);
        objectVsIdMap.put('contactId',contactObj.Id);
        objectVsIdMap.put('partyTypeId',partyTypeObj.Id);
        objectVsIdMap.put('applicationId',currApplicationObj.Id);
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(objectVsIdMap);
        Database.insert(borrowerPartyObj,true);
        objectVsIdMap.put('accountId',clAccountObj.Id);
        objectVsIdMap.put('partyTypeId',clpartyTypeObj.Id);
        objectVsIdMap.put('contactId',clContactObj.Id);
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(objectVsIdMap);
        Database.insert(clPartyObj,true);
        genesis__Applications__c previousApplicationObj = ApplicationOriginationTestHelper.createApplicationForFlex(clProductObj,accountObj);
        Database.insert(previousApplicationObj,true);
        ContentVersion contentObj= ApplicationOriginationTestHelper.createContentVersion();
        contentObj.Title='Jasmine Albin Credit Bureau Summary.pdf';
        contentObj.PathOnClient='/'+contentObj.Title+'.pdf';
        Database.insert(contentObj,true);
        List<ContentDocument> contentDocumentsObj = [SELECT Id 
                                                    FROM ContentDocument 
                                                    WHERE Title = 'Jasmine Albin Credit Bureau Summary.pdf' 
                                                    LIMIT 1];
        ContentDocumentLink conDocLinkObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocumentsObj[0].Id, accountObj.Id);
        Database.insert(conDocLinkObj,true);
    }

    /**
    * @description This method is use to check the success scenario
    * @author Simran | 06-07-2024 
    **/
    @istest
    public static void checkDownloadURL(){
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        genesis__Applications__c appObj=[SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
        Map<String, Object> request = new Map<String, Object>();
        request.put('applicationId',appObj.Id);
        System.runAs(userObj){
            PortalDownloadCBRReportAPI api = new PortalDownloadCBRReportAPI();
            clcommon.Response response = api.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Success');
        }  
    }
    /**
    * @description This method is use to check the CL user
    * @author Simran | 06-07-2024 
    **/
    @istest
    public static void checkCLUser(){
        Contact contactObj = [SELECT Id,Name FROM Contact WHERE Email='ross.geller@yopmail.com' LIMIT 1];
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Profile.Name='Certified Lender'
                                AND Username = 'ross.geller@yopmail.com'
                                AND ContactId= :contactObj.Id
                                AND IsActive=true
                                LIMIT 1];
        genesis__Applications__c appObj=[SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
        Map<String, Object> request = new Map<String, Object>();
        request.put('applicationId',appObj.Id);
        System.runAs(userObj){
            PortalDownloadCBRReportAPI api = new PortalDownloadCBRReportAPI();
            clcommon.Response response = api.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Success');
        }  
    }
    /**
    * @description This method is use to check the Invalid User
    * @author Simran | 06-07-2024 
    **/
    @istest
    public static void checkInvalidUser(){
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Profile.Name='Certified Lender'
                                AND IsActive=true
                                LIMIT 1];
        genesis__Applications__c appObj=[SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
        Map<String, Object> request = new Map<String, Object>();
        request.put('applicationId',appObj.Id);
        System.runAs(userObj){
            PortalDownloadCBRReportAPI api = new PortalDownloadCBRReportAPI();
            clcommon.Response response = api.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'API Exception');
        }  
    }
    /**
    * @description This method is use to check the null application.
    * @author Simran | 06-07-2024 
    **/
    @istest
    public static void checkNullApplication(){
        Contact contactObj = [SELECT Id,Name FROM Contact WHERE Email='ross.geller@yopmail.com' LIMIT 1];
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Profile.Name='Certified Lender'
                                AND Username = 'ross.geller@yopmail.com'
                                AND ContactId= :contactObj.Id
                                AND IsActive=true
                                LIMIT 1];
        Map<String, Object> request = new Map<String, Object>();
        request.put('applicationId',null);
        System.runAs(userObj){
            PortalDownloadCBRReportAPI api = new PortalDownloadCBRReportAPI();
            clcommon.Response response = api.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'API Exception');
        }  
    }

    /**
    * @description This method is use to check the null url.
    * @author Simran | 06-07-2024 
    **/
    @istest
    public static void checkNullURL(){
        List<ContentDocument> contentDocumentsObj = [SELECT Id 
                                                    FROM ContentDocument 
                                                    WHERE Title = 'Jasmine Albin Credit Bureau Summary.pdf' 
                                                    LIMIT 1];
        contentDocumentsObj[0].Title= 'Jasmine K Albin Creditt Bureau Summary.pdf';
        Database.update(contentDocumentsObj[0],true);
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        genesis__Applications__c appObj=[SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
        Map<String, Object> request = new Map<String, Object>();
        request.put('applicationId',appObj.Id);
        System.runAs(userObj){
            PortalDownloadCBRReportAPI api = new PortalDownloadCBRReportAPI();
            clcommon.Response response = api.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.PENDING, response.status, 'Pending');
        }  
    }
    /**
    * @description This method is use to check exception by passing wrong application id.
    * @author Simran | 06-07-2024 
    **/
    @istest
    public static void checkException(){
        User userObj = [SELECT Id
                                FROM USER 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];
        genesis__Applications__c appObj=[SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 7685 LIMIT 1];
        Map<String, Object> request = new Map<String, Object>();
        request.put('applicationId',appObj.Id);
        System.runAs(userObj){
            PortalDownloadCBRReportAPI api = new PortalDownloadCBRReportAPI();
            clcommon.Response response = api.invokeAction('', new List<String>(), request);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'API Exception');
        }  
    }
}