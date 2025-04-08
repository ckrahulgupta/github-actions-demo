/**
* @description       :
* @author            : Rahul Gupta
* @group             :
* @last modified on  : 17-10-2024
* @last modified by  : Soumik Pattanayak
**/
 
@IsTest
public with sharing class ReportImportBatchTest {
    
    /**
    * @description - Creating Test Data
    * @author Sk Minsar | 09-24-2024 
    **/
    @TestSetup
    static void makeData() {
        
        // get the CL Portal folder for test purpose
        List<Folder> dir = [SELECT Id FROM Folder WHERE Name = 'CL Portal' LIMIT 1];
 
        // create the csv document
        String csvContent = 'Loan #,Interest Balance,Monthly Interest,Principal Balance,\n336657003-C,-42429.4398114085,0,0,\n329181007-B,-37663.7493222414,-4616.980866669,598959.68,\n';
 
        Document doc = new Document();
        doc.Name = 'Success.csv';
        doc.Body = Blob.valueOf(csvContent);
        doc.folderId = dir[0].Id;
 
        Database.insert(doc, true);
 
        csvContent = 'Loan #,Interest Balance,Monthly Interest,Principal Balance,\n336657003-C,null,0,0,\n329181007-B,-37663.7493222414,-4616.980866669,598959.68,\n';
 
        doc = new Document();
        doc.Name = 'Failure.csv';
        doc.Body = Blob.valueOf(csvContent);
        doc.folderId = dir[0].Id;
 
        Database.insert(doc, true);
 
        //created another file to check edge case
        csvContent = 'Loan #,Interest Balance,Monthly Interest,Principal Balance,\n336659001-C,-42429.4398114085,0,0,\n';
 
        doc = new Document();
        doc.Name = 'Success2.csv';
        doc.Body = Blob.valueOf(csvContent);
        doc.folderId = dir[0].Id;
 
        Database.insert(doc, true);

        //another file that has duplicate rows
        csvContent = 'Loan #,Interest Balance,Monthly Interest,Principal Balance,\n336659001-C,-42429.4398114085,0,0,\n336659001-C,-42429.4398114085,0,0,\n';

        doc = new Document();
        doc.Name = 'DuplicateRows.csv';
        doc.Body = Blob.valueOf(csvContent);
        doc.folderId = dir[0].Id;
 
        Database.insert(doc, true);

        csvContent = '';

        doc = new Document();
        doc.Name = 'Empty.csv';
        doc.Body = Blob.valueOf(csvContent);
        doc.folderId = dir[0].Id;
 
        Database.insert(doc, true);
 
        genesis__Applications__c application = TestClassHelper.createApplication();
        
        //created another application
        genesis__Applications__c anotherApplication = TestClassHelper.createApplication();
 
        Account dealerAccount = TestClassHelper.createAccount(TestClassHelper.createBusinessInfo());
 
        genesis__Rate_Card_Setup_Header__c myProgram = TestClassHelper.createCurrYearRateCardHeader(dealerAccount);
        Database.upsert(myProgram, true);
        
        //created another setup header
        genesis__Rate_Card_Setup_Header__c anotherMyProgram = TestClassHelper.createCurrYearRateCardHeader(dealerAccount);
        Database.upsert(anotherMyProgram, true);
 
        genesis__Rate_Card_Setup_Detail__c setupDetail = TestClassHelper.createRateCardSetupDetailOne(myProgram);
        setupDetail.Start_Date__c = Date.newInstance(2022, 07, 01);
        setupDetail.End_Date__c = Date.newInstance(2023, 11, 30);
        
        //creted another setup detail
        genesis__Rate_Card_Setup_Detail__c anotherSetupDetail = TestClassHelper.createRateCardSetupDetailOne(anotherMyProgram);
        anotherSetupDetail.Start_Date__c = Date.newInstance(2024, 06, 01);
        anotherSetupDetail.End_Date__c = Date.newInstance(2024, 07, 31);
 
 
        Database.upsert(anotherSetupDetail, true);
 
        // create the pricings
        List<genesis__Application_Pricing_Detail__c> pricings = new List<genesis__Application_Pricing_Detail__c>{
            new genesis__Application_Pricing_Detail__c(
                Loan_Number__c = '336657003-C',
                genesis__Application__c = application.Id
 
            ),
            new genesis__Application_Pricing_Detail__c(
                Loan_Number__c = '329181007-B',
                genesis__Application__c = application.Id,
                genesis__Rate_Card_Setup_Detail__c = setupDetail.Id
 
            )
        };
 
        Database.insert(pricings, true);
        
        // created separate pricings
        List<genesis__Application_Pricing_Detail__c> anotherPricings = new List<genesis__Application_Pricing_Detail__c>{
            new genesis__Application_Pricing_Detail__c(
                Loan_Number__c = '336659001-C',
                genesis__Application__c = anotherApplication.Id,
                genesis__Enabled_Flag__c = true
 
            ),
            new genesis__Application_Pricing_Detail__c(
                Loan_Number__c = '336659001-C',
                genesis__Application__c = anotherApplication.Id,
                genesis__Rate_Card_Setup_Detail__c = anotherSetupDetail.Id,
                genesis__Enabled_Flag__c = false
            )
        };
 
        Database.insert(anotherPricings, true);
 
    }
 
    /**
    * @description - Test ReportImportBatch for Success Scenario
    * @author Sk Minsar | 09-24-2024 
    **/
    @IsTest
    private static void testCaseDefaultSuccess() {
 
        List<Document> doc = [SELECT Id FROM Document WHERE Name = 'Success.csv' LIMIT 1];
 
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0]) {
            Test.startTest();
            ReportImportBatch obj = new ReportImportBatch(doc[0].Id, 11, 2023);
            Database.executeBatch(obj, 80);
            Test.stopTest();
 
            System.assertEquals(2, [SELECT Id FROM genesis__Application_Fee_Payment__c WHERE Month__c = 11 AND Year__c = 2023 AND Record_Type__c = 'PARTICIPANT DAILY'].size(), 'Test Failed');
 
            
        }
        
    }

    /**
    * @description - Test ReportImportBatch for Empty Doc
    * @author Sk Minsar | 09-24-2024 
    **/
    @IsTest
    private static void testEmptyDoc() {
 
        List<Document> doc = [SELECT Id FROM Document WHERE Name = 'Empty.csv' LIMIT 1];
 
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0]) {
            Test.startTest();
            ReportImportBatch obj = new ReportImportBatch(doc[0].Id, 11, 2023);
            Id batchProcessId=Database.executeBatch(obj, 80);
            Test.stopTest();
 
            System.assert(batchProcessId!=null, 'Test Failed');
 
            
        }
        
    }
 
    /**
    * @description - Test ReportImportBatch for Failure Scenario
    * @author Sk Minsar | 09-24-2024 
    **/
    @IsTest
    private static void testCaseDefaultFailure() {
 
        List<Document> doc = [SELECT Id FROM Document WHERE Name = 'Failure.csv' LIMIT 1];
 
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0]) {
            Test.startTest();
            ReportImportBatch obj = new ReportImportBatch(doc[0].Id, 11, 2023);
            Database.executeBatch(obj, 80);
            Test.stopTest();
 
            System.assertEquals(0, [SELECT Id FROM genesis__Application_Fee_Payment__c WHERE Month__c = 11 AND Year__c = 2023 AND Record_Type__c = 'PARTICIPANT DAILY'].size(), 'Test Failed');
 
            
        }
        
    }
 
    /**
    * @description to test whether the pricing details id is correctly populated in fee payment obj or not
    * @author Kabir Pramanik | 09-09-2024 
    **/
    @IsTest
    private static void testCaseIncorrectFeePaymentUpdate() {
 
        List<Document> doc = [SELECT Id FROM Document WHERE Name = 'Success2.csv' LIMIT 1];
 
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0]) {
            Test.startTest();
            ReportImportBatch obj = new ReportImportBatch(doc[0].Id, 07, 2024);
            Database.executeBatch(obj, 80);
            Test.stopTest();

            List<genesis__Application_Fee_Payment__c> feePaymentObj = [SELECT Id,
                                                                                Pricing_Detail__c, 
                                                                                Pricing_Detail__r.Loan_Number__c 
                                                                            FROM genesis__Application_Fee_Payment__c 
                                                                            WHERE Month__c = 07 
                                                                            AND Year__c = 2024 
                                                                            AND Record_Type__c = 'PARTICIPANT DAILY' 
                                                                            AND Pricing_Detail__r.Loan_Number__c = '336659001-C'];
            List<genesis__Application_Pricing_Detail__c> pricingObj = [SELECT Id 
                                                                            FROM genesis__Application_Pricing_Detail__c 
                                                                            WHERE CALENDAR_MONTH(genesis__Rate_Card_Setup_Detail__r.End_Date__c) = :Integer.valueOf('07')
                                                                            AND CALENDAR_YEAR(genesis__Rate_Card_Setup_Detail__r.End_Date__c) = :Integer.valueOf('2024') 
                                                                            AND Loan_Number__c = '336659001-C' and genesis__Enabled_Flag__c = false];

            System.assertEquals(pricingObj[0].id,feePaymentObj[0].Pricing_Detail__c,  'Test Failed');
        }
        
    }

    /**
    * @description to test whether duplicate rows in excel file will bo handled properly or not
    * @author Kabir Pramanik | 09-09-2024 
    **/
    @isTest
    private static void testCaseDuplicateRowOnFile(){
        List<Document> doc = [SELECT Id FROM Document WHERE Name = 'DuplicateRows.csv' LIMIT 1];
 
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0]) {
            Test.startTest();
            ReportImportBatch obj = new ReportImportBatch(doc[0].Id, 07, 2024);
            Database.executeBatch(obj, 80);
            Test.stopTest();
 
            System.assertEquals(1, [SELECT Id FROM genesis__Application_Fee_Payment__c WHERE Month__c = 07 AND Year__c = 2024 AND Record_Type__c = 'PARTICIPANT DAILY'].size(), 'Test Failed');
 
            
        }
    }
}