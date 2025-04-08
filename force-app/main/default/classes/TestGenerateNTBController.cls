/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 06-12-2024
 * @last modified by  : Soumik Pattanayak
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   23-03-2023   Subham Nandi   Initial Version
**/
@isTest
public with sharing class TestGenerateNTBController {
    @TestSetup
    static void makeData(){


        // List<ContentVersion> listOfContentversion = new List<ContentVersion>();
        // List<ContentDocumentLink> listOfContentDocumentLink = new List<ContentDocumentLink>();
        //Dealer Business Info
        genesis__Business_Information__c businessInfo = new genesis__Business_Information__c(Approved_Loan_Amount__c = 0,
                                                                                            Contract_Loan_Limit__c = 1000000,
                                                                                            Customised_Loan_Limit__c = 500000,
                                                                                            Customised_Individual_Limit__c = 250000,
                                                                                            Remaining_Customised_Limit__c = 500000);
        Database.Insert(businessInfo,true);

        // List<Account> accountList = new List<Account>();
        //Dealer Account
        Account objAccount = new Account(Name='NTB Dealer Test' , 
                                        CIF_Number__c = '115282', 
                                        BillingCity = 'Seattle', 
                                        BillingState = 'AL');
        objAccount.genesis__Business_Information__c = businessInfo.Id;
        Database.insert(objAccount,true);
        //Borrower Account
        Account objBorrower = new Account(Name='Test Borrower' , 
                                        CIF_Number__c = '115283', 
                                        BillingCity = 'Seattle', 
                                        BillingState = 'AL');
        Database.insert(objBorrower,true);
        //Application
        genesis__Applications__c objApplication = new genesis__Applications__c();
        objApplication.Dealer_Name__c = objAccount.Id;
        objApplication.genesis__account__c = objBorrower.Id;
        objApplication.genesis__status__c = 'ACTIVE';
        objApplication.Crop_Year__c = '2023';
        Database.insert(objApplication,true);

        //Buyer Party
        clcommon__Party__c partyList = new clcommon__Party__c();
        // Buyer Party Type
        clcommon__Party_Type__c objPartyType = new clcommon__Party_Type__c(Name = 'BUYER');
        Database.insert(objPartyType, true);

        partyList.NTB_Report_Generated__c = false;
        partyList.NTB_Summary_Report_Generated__c = false;
        partyList.NTB_Label_Report_Generated__c =false;
        partyList.NTB_Generated__c = false;

        partyList.clcommon__Type__c = objPartyType.Id;
        partyList.clcommon__Party_Types__c='BUYER';
        partyList.genesis__Application__c=objApplication.Id;
        Database.insert(partyList, true);

        //Create Collatereal Category
        clcommon__Collateral_Category__c collateralCategory = new clcommon__Collateral_Category__c(Name = 'Wheat (HRW)');
        Database.insert(collateralCategory,true);
        clcommon__Collateral__c applicationCollateral = new clcommon__Collateral__c(genesis__Application__c = objApplication.Id,
                                                                                    clcommon__Collateral_Name__c = 'Wheat (HRW)',
                                                                                    clcommon__Collateral_Category__c = collateralCategory.Id);
        Database.insert(applicationCollateral,true);
    
        ContentVersion objContent=new ContentVersion();
        objContent.Title = 'NTB Annual Summary Report(Buyer%';
        objContent.PathOnClient = '/'+objContent.Title+'.pdf';
        //Blob b=Blob.valueOf('Test Content');
        objContent.VersionData=EncodingUtil.base64Decode('Test Content');
        objContent.IsMajorVersion = true;
        Database.insert(objContent,true);

        ContentDocument document = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        //Id conDocId =[SELECT ContentDocumentId FROM ContentVersion WHERE Id =:objContent.Id].ContentDocumentId;  
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = objApplication.Id;
        cdl.ContentDocumentId = document.Id;
        cdl.ShareType = 'V';
        Database.insert(cdl,true);


        //Create Task
        Task objTask = new Task(Subject=PortalConstants.NTB_TASK_CFA_ACTION,
                                Status=PortalConstants.COMPLETED_TASK_STATUS,
                                genesis__Application__c = objApplication.Id);
        Database.insert(objTask, true);


    }

    @isTest
    public static void testCaseOne(){
        Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Certified Lender' LIMIT 1];
        User objUser = IntegrationTestInitHelper.createUser(objProfile.Id);
        System.runAs(objUser){
            Test.startTest();
            GenerateNTBController callController = new GenerateNTBController();
            callController.searchApp();
            System.assert(true,clcommon.Constants.SUCCESS);
            Test.stopTest();
        }
    }

    @isTest
    public static void testCaseTwo(){
        Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Certified Lender' LIMIT 1];
        User objUser = IntegrationTestInitHelper.createUser(objProfile.Id);
        System.runAs(objUser){
            Test.startTest();
            PageReference pageRef = Page.EarlyLateNoticeFilterApp; 
            Test.setCurrentPage(pageref);
            GenerateNTBController callController = new GenerateNTBController();
            callController.cropYear = '2023';
            callController.searchApp();
            System.assert(true,clcommon.Constants.SUCCESS);
            Test.stopTest();
        }
    }

    @isTest
    public static void testCaseThree(){
        Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Certified Lender' LIMIT 1];
        User objUser = IntegrationTestInitHelper.createUser(objProfile.Id);
        System.runAs(objUser){
            Test.startTest();
            //processNTBAnnualSummary
            PageReference pageRef = Page.EarlyLateNoticeFilterApp; 
            Test.setCurrentPage(pageref);
            GenerateNTBController callController = new GenerateNTBController();
            callController.cropYear = '2023';
            callController.searchApp();
            callController.processNTB();
            System.assert(true,clcommon.Constants.SUCCESS);
            Test.stopTest();
        }
    }

    @isTest
    public static void testCaseFour(){
        Test.startTest();
        Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Certified Lender' LIMIT 1];
        User objUser = IntegrationTestInitHelper.createUser(objProfile.Id);
        System.runAs(objUser){
            PageReference pageRef = Page.EarlyLateNoticeFilterApp; 
            Test.setCurrentPage(pageref);
            GenerateNTBController callController = new GenerateNTBController();
            callController.cropYear = '2023';
            callController.searchApp();
            callController.processNTB();
            System.assert(true,clcommon.Constants.SUCCESS);
        }
        Test.stopTest();
    }

    @isTest
    public static void testCaseFive(){
        Test.startTest();
        Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Certified Lender' LIMIT 1];
        User objUser = IntegrationTestInitHelper.createUser(objProfile.Id);
        System.runAs(objUser){
            PageReference pageRef = Page.EarlyLateNoticeFilterApp; 
            Test.setCurrentPage(pageref);
            GenerateNTBController callController = new GenerateNTBController();
            callController.searchApp();
            callController.processNTB();
            System.assert(true,clcommon.Constants.SUCCESS);
        }
        Test.stopTest();
    }

}