/**
 * @description       : This is the test class of CreateAccountController
 * @author            : Ayan Bhowmik
 * @group             : 
 * @last modified on  : 07-09-2024
 * @last modified by  : Ayan Bhowmik
**/
@IsTest
public with sharing class CreateAccountControllerTest {
    @TestSetup
    static void makeData(){
         // Creating floating rate index
         clcommon__Floating_Rate_Index__c floatingRateIndexObj = ApplicationOriginationTestHelper.createFloatingRateIndex(
            New Map<String, Object>{ 'Name' => 'CFA Advantage Rate',
                                        'Base Rate Name' => '4-CFA ADVANTAGE',
                                        'Current Floating Rate' => 11,
                                        'Base Rate Adjuster' => 5.5
        });
        Database.insert(floatingRateIndexObj, true);

        // Creating floating rate
        clcommon__Floating_Rate__c floatingRateObj = ApplicationOriginationTestHelper.createFloatingRate(floatingRateIndexObj);
        Database.insert(floatingRateObj, true);

        // Creating new partnert program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);

        // creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id, newPartnerProgramObj.Id);
        Database.insert(dealerAccountObj, true);

        // creating business information
        genesis__Business_Information__c gmkDealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(gmkDealerBusinessInfoObj, true);

        // Creating Growmark Dealer
        Account gmkDealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(gmkDealerBusinessInfoObj.Id);
        gmkDealerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Certified Lender').getRecordTypeId();
        gmkDealerAccountObj.Coop_Type__c = 'Growmark';
        Database.insert(gmkDealerAccountObj, true);
    }
    @IsTest
    public static void testAllRecordTypesForGMK(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Coop_Type__c = 'Growmark'
                                            LIMIT 1];
        dealerAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        Database.update(dealerAccountList, true);
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Test.startTest();
            List<RecordType> recordTypeList = CreateAccountController.getRecordTypeList(dealerAccountList[0].Id);
            System.assertEquals(14, recordTypeList.size(), PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    @IsTest
    public static void testAllRecordTypes(){
        Map<String, RecordType> recordTypeMap = ApplicationOriginationTestHelper.getRecordTypeMap();
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE RecordType.Name = 'Dealer'
                                            LIMIT 1];
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Test.startTest();
            List<RecordType> recordTypeList = CreateAccountController.getRecordTypeList(dealerAccountList[0].Id);
            System.assertEquals(true, recordTypeList.contains(recordTypeMap.get('Payment Administrator')), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, recordTypeList.contains(recordTypeMap.get('Sales Agent Admin')), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, recordTypeList.contains(recordTypeMap.get('Field Staff Agent')), PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    @IsTest
    public static void testWithoutPA(){
        Map<String, RecordType> recordTypeMap = ApplicationOriginationTestHelper.getRecordTypeMap();
        List<Account> dealerAccountList = [SELECT Id,
                                                CFA_Partner_Program__c
                                            FROM Account
                                            WHERE RecordType.Name = 'Dealer'
                                            LIMIT 1];
        List<CFA_Partner_Program__c> partnerProgramList = [SELECT Id,
                                                                Allow_Payment_Admin__c,
                                                                Allow_Sales_Agent_Admin__c,
                                                                Allow_Field_Staff_Agents__c
                                                            FROM CFA_Partner_Program__c
                                                            WHERE Id =: dealerAccountList[0].CFA_Partner_Program__c
                                                            LIMIT 1];
        partnerProgramList[0].Allow_Payment_Admin__c = false;
        Database.update(partnerProgramList, true);
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Test.startTest();
            List<RecordType> recordTypeList = CreateAccountController.getRecordTypeList(dealerAccountList[0].Id);
            System.assertEquals(false, recordTypeList.contains(recordTypeMap.get('Payment Administrator')), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, recordTypeList.contains(recordTypeMap.get('Sales Agent Admin')), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, recordTypeList.contains(recordTypeMap.get('Field Staff Agent')), PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    @IsTest
    public static void testWithoutSAAdmin(){
        Map<String, RecordType> recordTypeMap = ApplicationOriginationTestHelper.getRecordTypeMap();
        List<Account> dealerAccountList = [SELECT Id,
                                                CFA_Partner_Program__c
                                            FROM Account
                                            WHERE RecordType.Name = 'Dealer'
                                            LIMIT 1];
        List<CFA_Partner_Program__c> partnerProgramList = [SELECT Id,
                                                                Allow_Payment_Admin__c,
                                                                Allow_Sales_Agent_Admin__c,
                                                                Allow_Field_Staff_Agents__c
                                                            FROM CFA_Partner_Program__c
                                                            WHERE Id =: dealerAccountList[0].CFA_Partner_Program__c
                                                            LIMIT 1];
        partnerProgramList[0].Allow_Sales_Agent_Admin__c = false;
        Database.update(partnerProgramList, true);
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Test.startTest();
            List<RecordType> recordTypeList = CreateAccountController.getRecordTypeList(dealerAccountList[0].Id);
            System.assertEquals(true, recordTypeList.contains(recordTypeMap.get('Payment Administrator')), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, recordTypeList.contains(recordTypeMap.get('Sales Agent Admin')), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, recordTypeList.contains(recordTypeMap.get('Field Staff Agent')), PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    @IsTest
    public static void testWithoutFSA(){
        Map<String, RecordType> recordTypeMap = ApplicationOriginationTestHelper.getRecordTypeMap();
        List<Account> dealerAccountList = [SELECT Id,
                                                CFA_Partner_Program__c
                                            FROM Account
                                            WHERE RecordType.Name = 'Dealer'
                                            LIMIT 1];
        List<CFA_Partner_Program__c> partnerProgramList = [SELECT Id,
                                                                Allow_Payment_Admin__c,
                                                                Allow_Sales_Agent_Admin__c,
                                                                Allow_Field_Staff_Agents__c
                                                            FROM CFA_Partner_Program__c
                                                            WHERE Id =: dealerAccountList[0].CFA_Partner_Program__c
                                                            LIMIT 1];
        partnerProgramList[0].Allow_Field_Staff_Agents__c = false;
        Database.update(partnerProgramList, true);
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Test.startTest();
            List<RecordType> recordTypeList = CreateAccountController.getRecordTypeList(dealerAccountList[0].Id);
            System.assertEquals(true, recordTypeList.contains(recordTypeMap.get('Payment Administrator')), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, recordTypeList.contains(recordTypeMap.get('Sales Agent Admin')), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, recordTypeList.contains(recordTypeMap.get('Field Staff Agent')), PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    @IsTest
    public static void testWithoutPASAAdmin(){
        Map<String, RecordType> recordTypeMap = ApplicationOriginationTestHelper.getRecordTypeMap();
        List<Account> dealerAccountList = [SELECT Id,
                                                CFA_Partner_Program__c
                                            FROM Account
                                            WHERE RecordType.Name = 'Dealer'
                                            LIMIT 1];
        List<CFA_Partner_Program__c> partnerProgramList = [SELECT Id,
                                                                Allow_Payment_Admin__c,
                                                                Allow_Sales_Agent_Admin__c,
                                                                Allow_Field_Staff_Agents__c
                                                            FROM CFA_Partner_Program__c
                                                            WHERE Id =: dealerAccountList[0].CFA_Partner_Program__c
                                                            LIMIT 1];
        partnerProgramList[0].Allow_Payment_Admin__c = false;
        partnerProgramList[0].Allow_Sales_Agent_Admin__c = false;
        Database.update(partnerProgramList, true);
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Test.startTest();
            List<RecordType> recordTypeList = CreateAccountController.getRecordTypeList(dealerAccountList[0].Id);
            System.assertEquals(false, recordTypeList.contains(recordTypeMap.get('Payment Administrator')), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, recordTypeList.contains(recordTypeMap.get('Sales Agent Admin')), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, recordTypeList.contains(recordTypeMap.get('Field Staff Agent')), PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    @IsTest
    public static void testWithoutPAFSA(){
        Map<String, RecordType> recordTypeMap = ApplicationOriginationTestHelper.getRecordTypeMap();
        List<Account> dealerAccountList = [SELECT Id,
                                                CFA_Partner_Program__c
                                            FROM Account
                                            WHERE RecordType.Name = 'Dealer'
                                            LIMIT 1];
        List<CFA_Partner_Program__c> partnerProgramList = [SELECT Id,
                                                                Allow_Payment_Admin__c,
                                                                Allow_Sales_Agent_Admin__c,
                                                                Allow_Field_Staff_Agents__c
                                                            FROM CFA_Partner_Program__c
                                                            WHERE Id =: dealerAccountList[0].CFA_Partner_Program__c
                                                            LIMIT 1];
        partnerProgramList[0].Allow_Payment_Admin__c = false;
        partnerProgramList[0].Allow_Field_Staff_Agents__c = false;
        Database.update(partnerProgramList, true);
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Test.startTest();
            List<RecordType> recordTypeList = CreateAccountController.getRecordTypeList(dealerAccountList[0].Id);
            System.assertEquals(false, recordTypeList.contains(recordTypeMap.get('Payment Administrator')), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, recordTypeList.contains(recordTypeMap.get('Sales Agent Admin')), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, recordTypeList.contains(recordTypeMap.get('Field Staff Agent')), PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    @IsTest
    public static void testWithoutSAAdminFSA(){
        Map<String, RecordType> recordTypeMap = ApplicationOriginationTestHelper.getRecordTypeMap();
        List<Account> dealerAccountList = [SELECT Id,
                                                CFA_Partner_Program__c
                                            FROM Account
                                            WHERE RecordType.Name = 'Dealer'
                                            LIMIT 1];
        List<CFA_Partner_Program__c> partnerProgramList = [SELECT Id,
                                                                Allow_Payment_Admin__c,
                                                                Allow_Sales_Agent_Admin__c,
                                                                Allow_Field_Staff_Agents__c
                                                            FROM CFA_Partner_Program__c
                                                            WHERE Id =: dealerAccountList[0].CFA_Partner_Program__c
                                                            LIMIT 1];
        partnerProgramList[0].Allow_Sales_Agent_Admin__c = false;
        partnerProgramList[0].Allow_Field_Staff_Agents__c = false;
        Database.update(partnerProgramList, true);
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Test.startTest();
            List<RecordType> recordTypeList = CreateAccountController.getRecordTypeList(dealerAccountList[0].Id);
            System.assertEquals(true, recordTypeList.contains(recordTypeMap.get('Payment Administrator')), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, recordTypeList.contains(recordTypeMap.get('Sales Agent Admin')), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, recordTypeList.contains(recordTypeMap.get('Field Staff Agent')), PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    @IsTest
    public static void testWithoutSAAdminFSAPA(){
        Map<String, RecordType> recordTypeMap = ApplicationOriginationTestHelper.getRecordTypeMap();
        List<Account> dealerAccountList = [SELECT Id,
                                                CFA_Partner_Program__c
                                            FROM Account
                                            WHERE RecordType.Name = 'Dealer'
                                            LIMIT 1];
        List<CFA_Partner_Program__c> partnerProgramList = [SELECT Id,
                                                                Allow_Payment_Admin__c,
                                                                Allow_Sales_Agent_Admin__c,
                                                                Allow_Field_Staff_Agents__c
                                                            FROM CFA_Partner_Program__c
                                                            WHERE Id =: dealerAccountList[0].CFA_Partner_Program__c
                                                            LIMIT 1];
        partnerProgramList[0].Allow_Payment_Admin__c = false;
        partnerProgramList[0].Allow_Sales_Agent_Admin__c = false;
        partnerProgramList[0].Allow_Field_Staff_Agents__c = false;
        Database.update(partnerProgramList, true);
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Test.startTest();
            List<RecordType> recordTypeList = CreateAccountController.getRecordTypeList(dealerAccountList[0].Id);
            System.assertEquals(false, recordTypeList.contains(recordTypeMap.get('Payment Administrator')), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, recordTypeList.contains(recordTypeMap.get('Sales Agent Admin')), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, recordTypeList.contains(recordTypeMap.get('Field Staff Agent')), PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    @IsTest
    public static void testPartnerProgramNotFoundException(){
        List<Account> dealerAccountList = [SELECT Id,
                                                CFA_Partner_Program__c
                                            FROM Account
                                            WHERE RecordType.Name = 'Dealer'
                                            LIMIT 1];
        dealerAccountList[0].CFA_Partner_Program__c = null;
        Database.update(dealerAccountList, true);
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Test.startTest();
            try{
                CreateAccountController.getRecordTypeList(dealerAccountList[0].Id);
            }catch(Exception exceptionObj){
                System.assertEquals(ConstantValues.PARTNER_PROGRAM_NOT_FOUND, exceptionObj.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
    @IsTest
    public static void testDealerNotFoundException(){
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Test.startTest();
            try{
                CreateAccountController.getRecordTypeList(null);
            }catch(Exception exceptionObj){
                System.assertEquals(ConstantValues.DEALER_NOT_FOUND, exceptionObj.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
}