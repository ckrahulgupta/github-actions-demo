/**
 * @description       : Test class for PortalApplicationSubmissionAPI to test submit scenarios
 * @author            : Suraj Kumar | 01-16-2025
 * @group             : 
 * @last modified on  : 01-20-2025
 * @last modified by  : Suraj Kumar
**/
@isTest
public with sharing class PortalApplicationSubmissionAPISubmitTest {
  /**
    * @description : Setup method to create test data
    * @author Suraj Kumar | 01-16-2025 
    **/
    @TestSetup
    static void setup() {
        ApplicationOriginationSetupTestHelper.createSubmissionAPITestData();
    }

    /**
    * @description : Testing application submission with my program and Credit_Application_And_Agreement_Process__c Customized , Lien options unSecured
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testCustomizedUnsecuredSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Lien_Options__c',PortalConstants.UNSECURED_LIEN);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            List<Note>  dealerNoteList = [SELECT Id FROM Note WHERE ParentId = :applicationObj.Id];
            System.assertEquals('Customize', updatedAppObj.Credit_Application_And_Agreement_Process__c, 'Assertion Failed');
            System.assertEquals('Unsecured', updatedAppObj.Lien_Options__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            System.assertEquals(1, dealerNoteList.size(), 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission with my program and Credit_Application_And_Agreement_Process__c Customized , secured, first Lien
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testCustomizedSecuredFirstLienSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Lien_Options__c','Secured');
        applicationDetailsMap.put('Crops_Lien__c', 'First Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Crops');
        applicationDetailsMap.put('Other_Additional_Requirements_Needed__c',true);
        applicationDetailsMap.put('Spousal_Consent__c',true);
        applicationDetailsMap.put('Other_Additional_Requirements__c', 'additional info');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('Customize', updatedAppObj.Credit_Application_And_Agreement_Process__c, 'Assertion Failed');
            System.assertEquals('Secured', updatedAppObj.Lien_Options__c, 'Assertion Failed');
            System.assertEquals('First Lien', updatedAppObj.Crops_Lien__c, 'Assertion Failed');
            System.assertEquals('Crops', updatedAppObj.Lien_Position__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Spousal_Consent__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Assignment_Of_Insurance__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Jointly_Payable_Proceeds_Checks__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Other_Additional_Requirements_Needed__c, 'Assertion Failed');
            System.assertEquals('additional info', updatedAppObj.Other_Additional_Requirements__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission with my program and Credit_Application_And_Agreement_Process__c Customized , secured, Second Lien
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testCustomizedSecuredSecondLienSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Lien_Options__c','Secured');
        applicationDetailsMap.put('Lien_Position__c', 'Crops');
        applicationDetailsMap.put('Other_Additional_Requirements_Needed__c',true);
        applicationDetailsMap.put('Spousal_Consent__c',true);
        applicationDetailsMap.put('Other_Additional_Requirements__c', 'additional info');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('Customize', updatedAppObj.Credit_Application_And_Agreement_Process__c, 'Assertion Failed');
            System.assertEquals('Secured', updatedAppObj.Lien_Options__c, 'Assertion Failed');
            System.assertEquals('Second Lien', updatedAppObj.Crops_Lien__c, 'Assertion Failed');
            System.assertEquals('Crops', updatedAppObj.Lien_Position__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Spousal_Consent__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Assignment_Of_Insurance__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Jointly_Payable_Proceeds_Checks__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Other_Additional_Requirements_Needed__c, 'Assertion Failed');
            System.assertEquals('additional info', updatedAppObj.Other_Additional_Requirements__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission with my program and Credit_Application_And_Agreement_Process__c Customized , secured, Best Lien
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testCustomizedSecuredBestLienSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Crops_Lien__c', 'Best Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Crops');
        applicationDetailsMap.put('Lien_Options__c','Secured');
        applicationDetailsMap.put('Other_Additional_Requirements_Needed__c',true);
        applicationDetailsMap.put('Spousal_Consent__c',true);
        applicationDetailsMap.put('Other_Additional_Requirements__c', 'additional info');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('Customize', updatedAppObj.Credit_Application_And_Agreement_Process__c, 'Assertion Failed');
            System.assertEquals('Secured', updatedAppObj.Lien_Options__c, 'Assertion Failed');
            System.assertEquals('Best Lien', updatedAppObj.Crops_Lien__c, 'Assertion Failed');
            System.assertEquals('Crops', updatedAppObj.Lien_Position__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Spousal_Consent__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Assignment_Of_Insurance__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Jointly_Payable_Proceeds_Checks__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Other_Additional_Requirements_Needed__c, 'Assertion Failed');
            System.assertEquals('additional info', updatedAppObj.Other_Additional_Requirements__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission with my program and Credit_Application_And_Agreement_Process__c Customized , secured, blanket second Lien
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testCustomizedSecuredBlanketSecondLienSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Blanket_Lien__c', 'Second Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Blanket');
        applicationDetailsMap.put('Lien_Options__c','Secured');
        applicationDetailsMap.put('Other_Additional_Requirements_Needed__c',true);
        applicationDetailsMap.put('Spousal_Consent__c',true);
        applicationDetailsMap.put('Other_Additional_Requirements__c', 'additional info');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('Customize', updatedAppObj.Credit_Application_And_Agreement_Process__c, 'Assertion Failed');
            System.assertEquals('Secured', updatedAppObj.Lien_Options__c, 'Assertion Failed');
            System.assertEquals('Second Lien', updatedAppObj.Blanket_Lien__c, 'Assertion Failed');
            System.assertEquals('Blanket', updatedAppObj.Lien_Position__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Spousal_Consent__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Assignment_Of_Insurance__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Jointly_Payable_Proceeds_Checks__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Other_Additional_Requirements_Needed__c, 'Assertion Failed');
            System.assertEquals('additional info', updatedAppObj.Other_Additional_Requirements__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission with my program and Credit_Application_And_Agreement_Process__c Customized , secured, blanket Best Lien
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testCustomizedSecuredBlanketBestLienSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Blanket_Lien__c', 'Best Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Blanket');
        applicationDetailsMap.put('Lien_Options__c','Secured');
        applicationDetailsMap.put('Other_Additional_Requirements_Needed__c',true);
        applicationDetailsMap.put('Spousal_Consent__c',true);
        applicationDetailsMap.put('Other_Additional_Requirements__c', 'additional info');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('Customize', updatedAppObj.Credit_Application_And_Agreement_Process__c, 'Assertion Failed');
            System.assertEquals('Secured', updatedAppObj.Lien_Options__c, 'Assertion Failed');
            System.assertEquals('Best Lien', updatedAppObj.Blanket_Lien__c, 'Assertion Failed');
            System.assertEquals('Blanket', updatedAppObj.Lien_Position__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Spousal_Consent__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Assignment_Of_Insurance__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Jointly_Payable_Proceeds_Checks__c, 'Assertion Failed');
            System.assertEquals(true, updatedAppObj.Other_Additional_Requirements_Needed__c, 'Assertion Failed');
            System.assertEquals('additional info', updatedAppObj.Other_Additional_Requirements__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission with my program and Credit_Application_And_Agreement_Process__c Customized , secured, first Lien without any additional document
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testSecuredFirstLienWithoutAdditionalDocsSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Lien_Options__c','Secured');
        applicationDetailsMap.put('Crops_Lien__c', 'First Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Crops');
        applicationDetailsMap.put('Spousal_Consent__c',false);
        applicationDetailsMap.put('Assignment_Of_Insurance__c',false);
        applicationDetailsMap.put('Jointly_Payable_Proceeds_Checks__c',false);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('Customize', updatedAppObj.Credit_Application_And_Agreement_Process__c, 'Assertion Failed');
            System.assertEquals('Secured', updatedAppObj.Lien_Options__c, 'Assertion Failed');
            System.assertEquals('First Lien', updatedAppObj.Crops_Lien__c, 'Assertion Failed');
            System.assertEquals('Crops', updatedAppObj.Lien_Position__c, 'Assertion Failed');
            System.assertEquals(false, updatedAppObj.Spousal_Consent__c, 'Assertion Failed');
            System.assertEquals(false, updatedAppObj.Assignment_Of_Insurance__c, 'Assertion Failed');
            System.assertEquals(false, updatedAppObj.Jointly_Payable_Proceeds_Checks__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : Testing application submission with my program and Credit_Application_And_Agreement_Process__c Customized , secured, Second Lien without any additional document
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testSecuredSecondLienWithoutAdditionalDocsSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Lien_Options__c','Secured');
        applicationDetailsMap.put('Crops_Lien__c', 'Second Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Crops');
        applicationDetailsMap.put('Spousal_Consent__c',false);
        applicationDetailsMap.put('Assignment_Of_Insurance__c',false);
        applicationDetailsMap.put('Jointly_Payable_Proceeds_Checks__c',false);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('Customize', updatedAppObj.Credit_Application_And_Agreement_Process__c, 'Assertion Failed');
            System.assertEquals('Secured', updatedAppObj.Lien_Options__c, 'Assertion Failed');
            System.assertEquals('Second Lien', updatedAppObj.Crops_Lien__c, 'Assertion Failed');
            System.assertEquals('Crops', updatedAppObj.Lien_Position__c, 'Assertion Failed');
            System.assertEquals(false, updatedAppObj.Spousal_Consent__c, 'Assertion Failed');
            System.assertEquals(false, updatedAppObj.Assignment_Of_Insurance__c, 'Assertion Failed');
            System.assertEquals(false, updatedAppObj.Jointly_Payable_Proceeds_Checks__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission with my program and Credit_Application_And_Agreement_Process__c Customized , secured, Best Lien without any additional document
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testSecuredBestLienWithoutAdditionalDocsSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Lien_Options__c','Secured');
        applicationDetailsMap.put('Crops_Lien__c', 'Best Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Crops');
        applicationDetailsMap.put('Spousal_Consent__c',false);
        applicationDetailsMap.put('Assignment_Of_Insurance__c',false);
        applicationDetailsMap.put('Jointly_Payable_Proceeds_Checks__c',false);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('Customize', updatedAppObj.Credit_Application_And_Agreement_Process__c, 'Assertion Failed');
            System.assertEquals('Secured', updatedAppObj.Lien_Options__c, 'Assertion Failed');
            System.assertEquals('Best Lien', updatedAppObj.Crops_Lien__c, 'Assertion Failed');
            System.assertEquals('Crops', updatedAppObj.Lien_Position__c, 'Assertion Failed');
            System.assertEquals(false, updatedAppObj.Spousal_Consent__c, 'Assertion Failed');
            System.assertEquals(false, updatedAppObj.Assignment_Of_Insurance__c, 'Assertion Failed');
            System.assertEquals(false, updatedAppObj.Jointly_Payable_Proceeds_Checks__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission with my program and Credit_Application_And_Agreement_Process__c Customized , secured, Blanket, second Lien without any additional document
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testSecuredBlanketSecondLienWithoutAdditionalDocsSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Blanket_Lien__c', 'Second Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Blanket');
        applicationDetailsMap.put('Lien_Options__c','Secured');
        applicationDetailsMap.put('Spousal_Consent__c',false);
        applicationDetailsMap.put('Assignment_Of_Insurance__c',false);
        applicationDetailsMap.put('Jointly_Payable_Proceeds_Checks__c',false);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('Customize', updatedAppObj.Credit_Application_And_Agreement_Process__c, 'Assertion Failed');
            System.assertEquals('Secured', updatedAppObj.Lien_Options__c, 'Assertion Failed');
            System.assertEquals('Second Lien', updatedAppObj.Blanket_Lien__c, 'Assertion Failed');
            System.assertEquals('Blanket', updatedAppObj.Lien_Position__c, 'Assertion Failed');
            System.assertEquals(false, updatedAppObj.Spousal_Consent__c, 'Assertion Failed');
            System.assertEquals(false, updatedAppObj.Assignment_Of_Insurance__c, 'Assertion Failed');
            System.assertEquals(false, updatedAppObj.Jointly_Payable_Proceeds_Checks__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission with my program and Credit_Application_And_Agreement_Process__c Customized , secured, Blanket, Best Lien without any additional document
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testSecuredBlanketBestLienWithoutAdditionalDocsSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Blanket_Lien__c', 'Second Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Blanket');
        applicationDetailsMap.put('Lien_Options__c','Secured');
        applicationDetailsMap.put('Spousal_Consent__c',false);
        applicationDetailsMap.put('Assignment_Of_Insurance__c',false);
        applicationDetailsMap.put('Jointly_Payable_Proceeds_Checks__c',false);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('Customize', updatedAppObj.Credit_Application_And_Agreement_Process__c, 'Assertion Failed');
            System.assertEquals('Secured', updatedAppObj.Lien_Options__c, 'Assertion Failed');
            System.assertEquals('Second Lien', updatedAppObj.Blanket_Lien__c, 'Assertion Failed');
            System.assertEquals('Blanket', updatedAppObj.Lien_Position__c, 'Assertion Failed');
            System.assertEquals(false, updatedAppObj.Spousal_Consent__c, 'Assertion Failed');
            System.assertEquals(false, updatedAppObj.Assignment_Of_Insurance__c, 'Assertion Failed');
            System.assertEquals(false, updatedAppObj.Jointly_Payable_Proceeds_Checks__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission with my program and credit rating Tier 4 , success
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testSubmitTierFourSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 4')[0].Id;
        Database.update(applicationObj, true);

        List<clcommon__Collateral__c> collateralObjList = ApplicationOriginationTestHelper.getCollateralList(applicationObj.Id);
        collateralObjList[0].Price__c = 50000;
        Database.update(collateralObjList,true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing scored application submission with my program and Credit_Application_And_Agreement_Process__c Customized , Lien options unSecured, success
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testScoredCustomizedUnsecuredSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Lien_Options__c',PortalConstants.UNSECURED_LIEN);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('Customize', updatedAppObj.Credit_Application_And_Agreement_Process__c, 'Assertion Failed');
            System.assertEquals('Unsecured', updatedAppObj.Lien_Options__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing scored application submission with my program and Credit_Application_And_Agreement_Process__c Customized , Lien options Secured, success
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testScoredCustomizedSecuredSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Blanket_Lien__c', 'Second Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Blanket');
        applicationDetailsMap.put('Lien_Options__c','Secured');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('Customize', updatedAppObj.Credit_Application_And_Agreement_Process__c, 'Assertion Failed');
            System.assertEquals('Secured', updatedAppObj.Lien_Options__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission with flex rate, Tier 4 , success
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testSubmitTierFourFlexRateSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 4')[0].Id;
        Database.update(applicationObj, true);
        List<clcommon__Collateral__c> collateralObjList = ApplicationOriginationTestHelper.getCollateralList(applicationObj.Id);
        collateralObjList[0].Price__c = 50000;
        Database.update(collateralObjList,true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

        Map<String, Object> flexRateProgramDetails = ApplicationOriginationTestHelper.getFlexRateProgramDetails();
        Map<String, Object> flexRatePricingDetails = ApplicationOriginationTestHelper.getFlexRatePricingDetails();

        Map<String, Object> flexRateDetails = new Map<String, Object> {
            'flexRateProgram' => flexRateProgramDetails,
            'ratePricing' => flexRatePricingDetails
        };

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!',
            'flexPricing' => JSON.serialize(flexRateDetails)
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission with flex rate , do not recommened success
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testScoredFlexRateNotRecommenedSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        Database.update(applicationObj, true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('Do_You_Recommend_This_Applicant__c','No');

        Map<String, Object> flexRateProgramDetails = ApplicationOriginationTestHelper.getFlexRateProgramDetails();
        Map<String, Object> flexRatePricingDetails = ApplicationOriginationTestHelper.getFlexRatePricingDetails();

        Map<String, Object> flexRateDetails = new Map<String, Object> {
            'flexRateProgram' => flexRateProgramDetails,
            'ratePricing' => flexRatePricingDetails
        };

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!',
            'flexPricing' => JSON.serialize(flexRateDetails)
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals(PortalConstants.REJECTED_APPLICATION_STATUS, updatedAppObj.genesis__Status__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission with flex rate , scored , customized unsecured
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testScoredFlexRateUnsecuredSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        Database.update(applicationObj, true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);
        applicationDetailsMap.put('Lien_Options__c',PortalConstants.UNSECURED_LIEN);

        Map<String, Object> flexRateProgramDetails = ApplicationOriginationTestHelper.getFlexRateProgramDetails();
        Map<String, Object> flexRatePricingDetails = ApplicationOriginationTestHelper.getFlexRatePricingDetails();

        Map<String, Object> flexRateDetails = new Map<String, Object> {
            'flexRateProgram' => flexRateProgramDetails,
            'ratePricing' => flexRatePricingDetails
        };

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!',
            'flexPricing' => JSON.serialize(flexRateDetails)
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('Customize', updatedAppObj.Credit_Application_And_Agreement_Process__c, 'Assertion Failed');
            System.assertEquals('Unsecured', updatedAppObj.Lien_Options__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission with flex rate , scored , customized Secured
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testScoredFlexRateSecuredSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        Database.update(applicationObj, true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);
        applicationDetailsMap.put('Blanket_Lien__c', 'Second Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Blanket');
        applicationDetailsMap.put('Lien_Options__c','Secured');

        Map<String, Object> flexRateProgramDetails = ApplicationOriginationTestHelper.getFlexRateProgramDetails();
        Map<String, Object> flexRatePricingDetails = ApplicationOriginationTestHelper.getFlexRatePricingDetails();

        Map<String, Object> flexRateDetails = new Map<String, Object> {
            'flexRateProgram' => flexRateProgramDetails,
            'ratePricing' => flexRatePricingDetails
        };

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!',
            'flexPricing' => JSON.serialize(flexRateDetails)
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('Customize', updatedAppObj.Credit_Application_And_Agreement_Process__c, 'Assertion Failed');
            System.assertEquals('Secured', updatedAppObj.Lien_Options__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

     /**
    * @description : Testing application submission with flex rate , Unscored , customized unsecured
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testUnScoredFlexRateUnsecuredSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);
        applicationDetailsMap.put('Lien_Options__c',PortalConstants.UNSECURED_LIEN);

        Map<String, Object> flexRateProgramDetails = ApplicationOriginationTestHelper.getFlexRateProgramDetails();
        Map<String, Object> flexRatePricingDetails = ApplicationOriginationTestHelper.getFlexRatePricingDetails();

        Map<String, Object> flexRateDetails = new Map<String, Object> {
            'flexRateProgram' => flexRateProgramDetails,
            'ratePricing' => flexRatePricingDetails
        };

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!',
            'flexPricing' => JSON.serialize(flexRateDetails)
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('Customize', updatedAppObj.Credit_Application_And_Agreement_Process__c, 'Assertion Failed');
            System.assertEquals('Unsecured', updatedAppObj.Lien_Options__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission autobook for evergreen application 
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenAutobookSuccess() {
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        Database.update(applicationObj, true);

        List<Task> entityTaskList = [SELECT Id,
                                    Status
                                FROM Task 
                                WHERE Subject = :PortalConstants.ENTITY_DOC_TASK
                                AND genesis__Application__c = :applicationObj.Id];

        entityTaskList[0].Status = PortalConstants.OPEN_TASK_STATUS;
        Database.update(entityTaskList[0], true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for evergreen application tier 1
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenTierOneSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        existingApplicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        Database.update(existingApplicationObj,true);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for evergreen application Tier 1 customized unsecured
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenTierOneUnsecuredSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        existingApplicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        Database.update(existingApplicationObj,true);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Lien_Options__c',PortalConstants.UNSECURED_LIEN);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for evergreen application Tier 1 customized Secured
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenTierOneSecuredSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        existingApplicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        Database.update(existingApplicationObj,true);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Blanket_Lien__c', 'Second Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Blanket');
        applicationDetailsMap.put('Lien_Options__c','Secured');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for evergreen application tier 2
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenTierTwoSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        existingApplicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2')[0].Id;
        Database.update(existingApplicationObj,true);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        applicationObj.Evergreen_Tier_Two_Business_Info_Status__c = PortalConstants.EVERGREEN_BIZ_STATUS_PROVIDED;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for evergreen application Tier 2 customized unsecured
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenTierTwoUnsecuredSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        existingApplicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2')[0].Id;
        Database.update(existingApplicationObj,true);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        applicationObj.Evergreen_Tier_Two_Business_Info_Status__c = PortalConstants.EVERGREEN_BIZ_STATUS_PROVIDED;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Lien_Options__c',PortalConstants.UNSECURED_LIEN);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for evergreen application Tier 2 customized Secured
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenTierTwoSecuredSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        existingApplicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2')[0].Id;
        Database.update(existingApplicationObj,true);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        applicationObj.Evergreen_Tier_Two_Business_Info_Status__c = PortalConstants.EVERGREEN_BIZ_STATUS_PROVIDED;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Blanket_Lien__c', 'Second Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Blanket');
        applicationDetailsMap.put('Lien_Options__c','Secured');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for evergreen application tier 3
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenTierThreeSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        existingApplicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        Database.update(existingApplicationObj,true);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        Database.update(applicationObj, true);

        List<clcommon__Collateral__c> collateralObjList = ApplicationOriginationTestHelper.getCollateralList(applicationObj.Id);
        collateralObjList[0].Price__c = 50000;
        Database.update(collateralObjList,true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for evergreen application Tier 3 customized unsecured
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenTierThreeUnsecuredSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        existingApplicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        Database.update(existingApplicationObj,true);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Lien_Options__c',PortalConstants.UNSECURED_LIEN);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for evergreen application Tier 3 customized Secured
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenTierThreeSecuredSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        existingApplicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        Database.update(existingApplicationObj,true);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Blanket_Lien__c', 'Second Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Blanket');
        applicationDetailsMap.put('Lien_Options__c','Secured');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for evergreen application tier 1 , failure
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenTierOneException() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        existingApplicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        existingApplicationObj.Crop_Year__c = '2022';
        Database.update(existingApplicationObj,true);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for evergreen application Tier 1 customized unsecured, failure
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenTierOneUnsecuredException() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        existingApplicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        existingApplicationObj.Crop_Year__c = '2022';
        Database.update(existingApplicationObj,true);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Lien_Options__c',PortalConstants.UNSECURED_LIEN);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for evergreen application Tier 1 customized Secured, failure
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenTierOneSecuredException() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        existingApplicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        existingApplicationObj.Crop_Year__c = '2022';
        Database.update(existingApplicationObj,true);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Blanket_Lien__c', 'Second Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Blanket');
        applicationDetailsMap.put('Lien_Options__c','Secured');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for evergreen application tier 2, failure
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenTierTwoException() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        existingApplicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2')[0].Id;
        existingApplicationObj.Crop_Year__c = '2022';
        Database.update(existingApplicationObj,true);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        applicationObj.Evergreen_Tier_Two_Business_Info_Status__c = PortalConstants.EVERGREEN_BIZ_STATUS_PROVIDED;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for evergreen application Tier 2 customized unsecured, failure
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenTierTwoUnsecuredException() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        existingApplicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2')[0].Id;
        existingApplicationObj.Crop_Year__c = '2022';
        Database.update(existingApplicationObj,true);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        applicationObj.Evergreen_Tier_Two_Business_Info_Status__c = PortalConstants.EVERGREEN_BIZ_STATUS_PROVIDED;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Lien_Options__c',PortalConstants.UNSECURED_LIEN);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for evergreen application Tier 2 customized Secured, failure
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenTierTwoSecuredException() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        existingApplicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2')[0].Id;
        existingApplicationObj.Crop_Year__c = '2022';
        Database.update(existingApplicationObj,true);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        applicationObj.Evergreen_Tier_Two_Business_Info_Status__c = PortalConstants.EVERGREEN_BIZ_STATUS_PROVIDED;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Blanket_Lien__c', 'Second Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Blanket');
        applicationDetailsMap.put('Lien_Options__c','Secured');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for evergreen application tier 3, failure
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenTierThreeException() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        existingApplicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        existingApplicationObj.Crop_Year__c = '2022';
        Database.update(existingApplicationObj,true);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for evergreen application Tier 3 customized unsecured, exception
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenTierThreeUnsecuredException() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        existingApplicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        existingApplicationObj.Crop_Year__c = '2022';
        Database.update(existingApplicationObj,true);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Lien_Options__c',PortalConstants.UNSECURED_LIEN);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for evergreen application Tier 3 customized Secured, Exception
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testEvergreenTierThreeSecuredException() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.getExistingApplication();
        existingApplicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        existingApplicationObj.Crop_Year__c = '2022';
        Database.update(existingApplicationObj,true);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        applicationObj.genesis__Parent_Application__c = existingApplicationObj.Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Blanket_Lien__c', 'Second Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Blanket');
        applicationDetailsMap.put('Lien_Options__c','Secured');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description The purpose of this method is to test for a no score applicant. When the application with a no score primary applicant is scored, the fico score on the application is null. Hence when the cl not chooses request second look in the credit agreement and application process, the additional info must be required.
    * @author Suraj Kumar | 01-15-2025 
    **/
    @IsTest
    private static void testTierThreeAppSubmitNoScoreApplicantSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        Database.update(applicationObj, true);
        List<clcommon__Collateral__c> collateralObjList = ApplicationOriginationTestHelper.getCollateralList(applicationObj.Id);
        collateralObjList[0].Price__c = 50000;
        Database.update(collateralObjList,true);

        Account principalAccount=ApplicationOriginationTestHelper.getPrincipalAccount();
        principalAccount.Score_1__c='9003';
        Database.update(principalAccount,true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI submissionApi = new PortalApplicationSubmissionAPI();
            clcommon.Response response = submissionApi.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion success!');
            Test.stopTest();
        }
        
    }

    /**
    * @description : Testing application submission unsecured to secured
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testUnsecuredToSecuredSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2')[0].Id;
        applicationObj.Lien_Options__c = 'Unsecured';
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Blanket_Lien__c', 'Second Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Blanket');
        applicationDetailsMap.put('Lien_Options__c','Secured');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('Customize', updatedAppObj.Credit_Application_And_Agreement_Process__c, 'Assertion Failed');
            System.assertEquals('Secured', updatedAppObj.Lien_Options__c, 'Assertion Failed');
            System.assertEquals('Second Lien', updatedAppObj.Blanket_Lien__c, 'Assertion Failed');
            System.assertEquals('Blanket', updatedAppObj.Lien_Position__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission existing MyProgram to flex rate
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testExistingMyprogramToFlexRateSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.My_Program__c = rateCardObj.Id;
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2')[0].Id;
        Database.update(applicationObj, true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

        Map<String, Object> flexRateProgramDetails = ApplicationOriginationTestHelper.getFlexRateProgramDetails();
        Map<String, Object> flexRatePricingDetails = ApplicationOriginationTestHelper.getFlexRatePricingDetails();

        Map<String, Object> flexRateDetails = new Map<String, Object> {
            'flexRateProgram' => flexRateProgramDetails,
            'ratePricing' => flexRatePricingDetails
        };

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!',
            'flexPricing' => JSON.serialize(flexRateDetails)
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission existing SA to another SA
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testExistingSAToNewSASuccess() {
        String newSalesAgentId = '';
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<clcommon__party__c> saPartyList = [SELECT Id, clcommon__Account__c, genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c = 'SALES AGENT'];
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2')[0].Id;

        saPartyList[0].genesis__Application__c = applicationObj.Id;
        applicationObj.Sales_Agent__c = saPartyList[0].clcommon__Account__c;
        Database.update(applicationObj, true);
        Database.update(saPartyList[0],true);

        List<Account> newSaAccountList = [SELECT Id FROM Account WHERE Name = 'Marcus SA' LIMIT 1];
        newSalesAgentId = newSaAccountList[0].Id;
        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('Sales_Agent__c',newSaAccountList[0].Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals(newSalesAgentId, updatedAppObj.Sales_Agent__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission Secured to Unsecured
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testSecuredToUnsecuredSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2')[0].Id;
        applicationObj.Lien_Options__c = 'Secured';
        applicationObj.Blanket_Lien__c = 'Second Lien';
        applicationObj.Lien_Position__c = 'Blanket';
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Lien_Options__c','Unsecured');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('Customize', updatedAppObj.Credit_Application_And_Agreement_Process__c, 'Assertion Failed');
            System.assertEquals('Unsecured', updatedAppObj.Lien_Options__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for adding unique identifier for gmk 
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testAddingUniqueIdentifierGmkSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        Database.update(applicationObj, true);

        Account dealerAccObj = ApplicationOriginationTestHelper.getAccountById(applicationObj.Dealer_Name__c);
        dealerAccObj.Coop_Type__c='Growmark';
        dealerAccObj.CFA_Partner_Program__c = null;
        Database.update(dealerAccObj,true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('Growmark_Unique_Identifier__c', 'test gmk unique identifier');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('test gmk unique identifier', updatedAppObj.Growmark_Unique_Identifier__c, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for removing existing Note on application
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testExistingNoteToNullSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        Database.update(applicationObj, true);

        Note dealerNote = ApplicationOriginationTestHelper.createDealerNote(applicationObj.Id,'This is a test note');
        dealerNote.OwnerId = clUserObj.Id;
        Database.insert(dealerNote,true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            List<Note> updatedDealerNoteList = [SELECT Id, ParentId FROM Note WHERE Title = 'Dealer Note' AND ParentId = :applicationObj.Id];
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            System.assertEquals(0, updatedDealerNoteList.size(), 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for existing flexrate to my program
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testExistingFlexRateToMyProgramSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Rate_Card_Setup_Header__c> flexRateList = [SELECT Id, Name FROM genesis__Rate_Card_Setup_Header__c WHERE Name = 'My Program Test 2'];
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        flexRateList[0].Name = applicationObj.Name + ' Flex Price';
        Database.update(flexRateList[0],true);
        applicationObj.My_Program__c = flexRateList[0].Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        rateCardObj.OwnerId = clUserObj.Id;
        Database.update(rateCardObj,true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('My Test Program 99', updatedAppObj.My_Program__r.Name, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for existing flexrate to new flex rate success
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testExistingFlexRateToNewFlexRateSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Rate_Card_Setup_Header__c flexRateObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        flexRateObj.Name = applicationObj.Name + ' Flex Price test';
        Database.update(flexRateObj,true);
        applicationObj.My_Program__c = flexRateObj.Id;
        Database.update(applicationObj, true);
        
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

        Map<String, Object> flexRateProgramDetails = ApplicationOriginationTestHelper.getFlexRateProgramDetails();
        Map<String, Object> flexRatePricingDetails = ApplicationOriginationTestHelper.getFlexRatePricingDetails();

        Map<String, Object> flexRateDetails = new Map<String, Object> {
            'flexRateProgram' => flexRateProgramDetails,
            'ratePricing' => flexRatePricingDetails
        };

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!',
            'flexPricing' => JSON.serialize(flexRateDetails)
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for existing my program to my another program
    * @author Suraj Kumar | 01-16-2025 
    **/
    @IsTest
    private static void testExistingMyProgramToNewMyProgramSuccess() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Rate_Card_Setup_Header__c> myProgramList = [SELECT Id, Name FROM genesis__Rate_Card_Setup_Header__c WHERE Name = 'My Program Test 2'];
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        applicationObj.My_Program__c = myProgramList[0].Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCurrentMyProgram();
        rateCardObj.OwnerId = clUserObj.Id;
        Database.update(rateCardObj,true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            genesis__Applications__c updatedAppObj = ApplicationOriginationTestHelper.getUpdatedApplication(applicationObj.Id);
            System.assertEquals('My Test Program 99', updatedAppObj.My_Program__r.Name, 'Assertion Failed');
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }
}