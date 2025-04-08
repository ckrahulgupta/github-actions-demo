/**
 * @description       : Test class for ScheduleEOMEmailToCFAGrowerAPI
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 04-04-2024
 * @last modified by  : Ayush Kumar Singh
**/

@isTest
public with sharing class EOMUpdateApplicationFieldBatchTest {
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

        Date todayDate = System.today();
        String currentYear = String.valueOf(todayDate.year());
        String currentMonth = String.valueOf(todayDate.month());
        String previousMonth = String.valueOf(todayDate.addMonths(-1).month());
        String previousMonthYear;
        if(currentMonth.equals('1') || currentMonth.equals('01')){
            previousMonthYear = String.valueOf(todayDate.addYears(-1).year());
        }else{
            previousMonthYear = currentYear;
        }
        String previousMonthDate = previousMonthYear + previousMonth;

        // Creating Application
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        applicationObj.Monthly_Statement_Sent__c = previousMonthDate;
        Database.insert(applicationObj, true);
    }

    @isTest
    public static void testEOMUpdateApplicationFieldForCFA(){
        genesis__Applications__c appObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,Dealer_Name__c,Monthly_Statement_Sent__c FROM genesis__Applications__c LIMIT 1];
        User adminUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(adminUser){
            Test.startTest();
            EOMUpdateApplicationFieldBatch updateApplicationField = new EOMUpdateApplicationFieldBatch(applicationList);
            Database.executeBatch(updateApplicationField,1);
            Test.stopTest();
            Date todayDate = System.today();
            String currentYear = String.valueOf(todayDate.year());
            String currentMonth = String.valueOf(todayDate.month());
            String currentDate = currentYear + currentMonth;
            appObj = [SELECT Id,Dealer_Name__c,Monthly_Statement_Sent__c FROM genesis__Applications__c where id = :applicationList[0].id LIMIT 1];
            System.assertEquals(appObj.Monthly_Statement_Sent__c,currentDate, 'Assertion Failed');
        }
       
    }

    @isTest
    public static void testEOMUpdateApplicationFieldForGrowmark(){
        genesis__Applications__c appObj;
        Account dealerAccount;
        List<genesis__Applications__c> applicationList = [SELECT Id,Dealer_Name__c,Monthly_Statement_Sent__c FROM genesis__Applications__c LIMIT 1];
        List<Account> dealerAccountList = [SELECT Id,Coop_Type__c FROM Account Where Id =: applicationList[0].Dealer_Name__c];
        User adminUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        if(dealerAccountList.size()==1){
            dealerAccount = dealerAccountList[0];
            dealerAccount.Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
            Database.update(dealerAccount,true);
        }
        System.runAs(adminUser){
            Test.startTest();
            EOMUpdateApplicationFieldBatch updateApplicationField = new EOMUpdateApplicationFieldBatch(applicationList);
            Database.executeBatch(updateApplicationField,1);
            Test.stopTest();
            Date todayDate = System.today();
            String currentYear = String.valueOf(todayDate.year());
            String currentMonth = String.valueOf(todayDate.month());
            String currentDate = currentYear + currentMonth;
            appObj = [SELECT Id,Dealer_Name__c,Monthly_Statement_Sent__c FROM genesis__Applications__c where id = :applicationList[0].id LIMIT 1];
            System.assertEquals(appObj.Monthly_Statement_Sent__c,currentDate, 'Assertion Failed');
        }
         
    }
    @isTest
    public static void testEOMUpdateApplicationFieldForLandus(){
        genesis__Applications__c appObj;
        Account dealerAccount;
        List<genesis__Applications__c> applicationList = [SELECT Id,Dealer_Name__c,Monthly_Statement_Sent__c FROM genesis__Applications__c LIMIT 1];
        List<Account> dealerAccountList = [SELECT Id,Coop_Type__c FROM Account Where Id =: applicationList[0].Dealer_Name__c];
        User adminUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        if(dealerAccountList.size()==1){
            dealerAccount = dealerAccountList[0];
            dealerAccount.Coop_Type__c =  ConstantValues.LANDUS_COOP_TYPE;
            Database.update(dealerAccount,true);
        }
        System.runAs(adminUser){
            Test.startTest();
            EOMUpdateApplicationFieldBatch updateApplicationField = new EOMUpdateApplicationFieldBatch(applicationList);
            Database.executeBatch(updateApplicationField,1);
            Test.stopTest();
            Date todayDate = System.today();
            String currentYear = String.valueOf(todayDate.year());
            String currentMonth = String.valueOf(todayDate.month());
            String currentDate = currentYear + currentMonth;
            appObj = [SELECT Id,Dealer_Name__c,Monthly_Statement_Sent__c FROM genesis__Applications__c where id = :applicationList[0].id LIMIT 1];
            System.assertEquals(appObj.Monthly_Statement_Sent__c,currentDate, 'Assertion Failed');
            
        }      
    }
    @isTest
    public static void testEOMUpdateApplicationFieldForGrowmarkCorporation(){
        genesis__Applications__c appObj;
        Account dealerAccount;
        List<genesis__Applications__c> applicationList = [SELECT Id,Dealer_Name__c,Monthly_Statement_Sent__c FROM genesis__Applications__c LIMIT 1];
        List<Account> dealerAccountList = [SELECT Id,Coop_Type__c FROM Account Where Id =: applicationList[0].Dealer_Name__c];
        User adminUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        clcommon__Legal_Entity__c legalEntityObj=[SELECT Id,Name,clcommon__Legal_Entity_Type__c FROM clcommon__Legal_Entity__c WHERE Name='Individual(s) - Sole Proprietorship'];
        legalEntityObj.Name='Corporation';
        legalEntityObj.clcommon__Legal_Entity_Type__c='Corporation';
        Database.update(legalEntityObj,true);
        if(dealerAccountList.size()==1){
            dealerAccount = dealerAccountList[0];
            dealerAccount.Coop_Type__c =  ConstantValues.LANDUS_COOP_TYPE;
            Database.update(dealerAccount,true);
        }
        System.runAs(adminUser){
            Test.startTest();
            EOMUpdateApplicationFieldBatch updateApplicationField = new EOMUpdateApplicationFieldBatch(applicationList);
            Database.executeBatch(updateApplicationField,1);
            Test.stopTest();
            Date todayDate = System.today();
            String currentYear = String.valueOf(todayDate.year());
            String currentMonth = String.valueOf(todayDate.month());
            String currentDate = currentYear + currentMonth;
            appObj = [SELECT Id,Dealer_Name__c,Monthly_Statement_Sent__c FROM genesis__Applications__c where id = :applicationList[0].id LIMIT 1];
            System.assertEquals(appObj.Monthly_Statement_Sent__c,currentDate, 'Assertion Failed');
            
        } 
    }  
    @isTest
    public static void testEOMUpdateApplicationFieldForLandusCorporation(){
        genesis__Applications__c appObj;
        Account dealerAccount;
        List<genesis__Applications__c> applicationList = [SELECT Id,Dealer_Name__c,Monthly_Statement_Sent__c FROM genesis__Applications__c LIMIT 1];
        List<Account> dealerAccountList = [SELECT Id,Coop_Type__c FROM Account Where Id =: applicationList[0].Dealer_Name__c];
        User adminUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        clcommon__Legal_Entity__c legalEntityObj=[SELECT Id,Name,clcommon__Legal_Entity_Type__c FROM clcommon__Legal_Entity__c WHERE Name='Individual(s) - Sole Proprietorship'];
        legalEntityObj.Name='Corporation';
        legalEntityObj.clcommon__Legal_Entity_Type__c='Corporation';
        Database.update(legalEntityObj,true);
        if(dealerAccountList.size()==1){
            dealerAccount = dealerAccountList[0];
            dealerAccount.Coop_Type__c =  ConstantValues.LANDUS_COOP_TYPE;
            Database.update(dealerAccount,true);
        }
        System.runAs(adminUser){
            Test.startTest();
            EOMUpdateApplicationFieldBatch updateApplicationField = new EOMUpdateApplicationFieldBatch(applicationList);
            Database.executeBatch(updateApplicationField,1);
            Test.stopTest();
            Date todayDate = System.today();
            String currentYear = String.valueOf(todayDate.year());
            String currentMonth = String.valueOf(todayDate.month());
            String currentDate = currentYear + currentMonth;
            appObj = [SELECT Id,Dealer_Name__c,Monthly_Statement_Sent__c FROM genesis__Applications__c where id = :applicationList[0].id LIMIT 1];
            System.assertEquals(appObj.Monthly_Statement_Sent__c,currentDate, 'Assertion Failed');
            
        }      
    }
    @isTest
    public static void testEOMUpdateApplicationFieldWithoutApplication(){
        genesis__Applications__c appObj = new genesis__Applications__c();
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        applicationList.add(appObj);
        User adminUser = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(adminUser){
            Test.startTest();
            EOMUpdateApplicationFieldBatch updateApplicationField = new EOMUpdateApplicationFieldBatch(applicationList);
            Database.executeBatch(updateApplicationField,1);
            Test.stopTest();
            System.assertEquals(appObj.Monthly_Statement_Sent__c,null, 'Assertion Failed');
        }      
    }
}