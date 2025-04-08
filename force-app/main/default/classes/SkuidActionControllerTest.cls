/**
 * @description       : This class is for testing purpose
/*                      for all the webserice methods called from Skuid
 * @author            : Ayan Bhowmik
 * @group             : 
 * @last modified on  : 03-12-2024
 * @last modified by  : Suraj Kumar
**/

@isTest
public with sharing class SkuidActionControllerTest {

    @TestSetup
    static void setup() {

        // creating business information
        genesis__Business_Information__c dealerBusinessInformationObj = TestClassHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInformationObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = TestClassHelper.createDealerAccount(dealerBusinessInformationObj.Id);
        Database.insert(dealerAccountObj, true);

        // Creating Contact for Dealer
        Contact dealerContactObj = TestClassHelper.createDealerContact(dealerAccountObj.Id);
        Database.insert(dealerContactObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = TestClassHelper.createCLAccount(dealerBusinessInformationObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = TestClassHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);

        // Creating Individual(s) - Sole Proprietorship legal Entity
        clcommon__Legal_Entity__c entityObj = TestClassHelper.createLegalEntity('Individual(s) - Sole Proprietorship');
        Database.insert(entityObj, true);

        // Creating Borrower Account
        Account borrowerAccountObj = TestClassHelper.createSolePropAccount(entityObj,
                                                                                TestClassHelper.createBusinessInfoForBorrower().Id);
        Database.insert(borrowerAccountObj, true);

        // Creating borrower Contact
        Contact borrowerContactObj = TestClassHelper.createBorrowerContact(borrowerAccountObj.Id);    
        Database.insert(borrowerContactObj, true);

        // Creating CL Product for Application
        clcommon__CL_Product__c clProductObj = TestClassHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating CL Purpose for Application
        clcommon__CL_Purpose__c clPurposeObj = TestClassHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating map for Application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>();
        paramForApplicationMap.put('dealerAccountId', dealerAccountObj.Id);
        paramForApplicationMap.put('clProductId', clProductObj.Id);
        paramForApplicationMap.put('clPurposeId', clPurposeObj.Id);
        paramForApplicationMap.put('borrowerAccountId', borrowerAccountObj.Id);
        paramForApplicationMap.put('borrowerContactId', borrowerContactObj.Id);
        paramForApplicationMap.put('clAccountId', clAccountObj.Id);

        // Creating Application
        genesis__Applications__c applicationObj = TestClassHelper.createCurrCropYearApplication(paramForApplicationMap);
        Database.insert(applicationObj, true);

        //create borrower party
        clcommon__Party_Type__c borrowerPartyTypeObj = TestClassHelper.createPartyType('BORROWER');
        Database.insert(borrowerPartyTypeObj, true);
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>();
        paramForBorrowerPartyMap.put('accountId', borrowerAccountObj.Id);
        paramForBorrowerPartyMap.put('contactId', borrowerContactObj.Id);
        paramForBorrowerPartyMap.put('partyTypeId', borrowerPartyTypeObj.Id);
        paramForBorrowerPartyMap.put('applicationId', applicationObj.Id);

        // Creating Borrower Party
        clcommon__Party__c borrowerPartyObj = TestClassHelper.createParty(paramForBorrowerPartyMap);
        Database.insert(borrowerPartyObj, true);
        
        // create certified lender Party Type
        clcommon__Party_Type__c clPartyTypeObj = TestClassHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(clPartyTypeObj, true);
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>();
        paramForCLPartyMap.put('accountId', clAccountObj.Id);
        paramForCLPartyMap.put('contactId', clContactObj.Id);
        paramForCLPartyMap.put('partyTypeId', clPartyTypeObj.Id);
        paramForCLPartyMap.put('applicationId', applicationObj.Id);

        // Create Certified Lender Party
        clcommon__Party__c certifiedLenderPartyObj = TestClassHelper.createParty(paramForCLPartyMap);
        Database.insert(certifiedLenderPartyObj, true);
    
        // create Dealer party Type
        clcommon__Party_Type__c dealerPartyType = TestClassHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(dealerPartyType, true);
        Map<String,Id> paramForDealerPartyMap = new Map<String,Id>();
        paramForDealerPartyMap.put('accountId', dealerAccountObj.Id);
        paramForDealerPartyMap.put('contactId', dealerContactObj.Id);
        paramForDealerPartyMap.put('partyTypeId', dealerPartyType.Id);
        paramForDealerPartyMap.put('applicationId', applicationObj.Id);

        // Creating Dealer Party
        clcommon__Party__c objDealerParty = TestClassHelper.createParty(paramForDealerPartyMap);
        Database.insert(objDealerParty, true);
    }
    
    @isTest
    public static void testCaseResendingDocuSign() {
        
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c
                                                        WHERE Signing_Method__c = 'Email - Docusign'];
        Test.startTest();
        String message = SkuidActionController.reSendingDocuSignWS(applicationObj.Id);
        Test.stopTest();
        
        System.assertEquals(clcommon.constants.SUCCESS, message, 'SUCCESS');
    }
    
    @isTest
    public static void testCaseResendingDocuSignException1() {
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            DocuSign_Credit_Agreement_Initiated__c, 
                                                            genesis__Status__c
                                                        FROM genesis__Applications__c
                                                        WHERE Signing_Method__c = 'Email - Docusign'];
        applicationObj.genesis__Status__c = 'WITHDRAWN';
        Database.update(applicationObj, true);
        Test.startTest();
        String message = SkuidActionController.reSendingDocuSignWS(applicationObj.Id);
        Test.stopTest();
        
        System.assertNotEquals(clcommon.constants.SUCCESS, message, 'ERROR');
    }

    @isTest
    public static void testCaseResendingDocuSignException2() {
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            DocuSign_Credit_Agreement_Initiated__c, 
                                                            genesis__Status__c
                                                        FROM genesis__Applications__c
                                                        WHERE Signing_Method__c = 'Email - Docusign'];
        applicationObj.Signing_Method__c = 'In Person - Docusign';
        Database.update(applicationObj, true);
        Test.startTest();
        String message = SkuidActionController.reSendingDocuSignWS(applicationObj.Id);
        Test.stopTest();
        
        System.assertNotEquals(clcommon.constants.SUCCESS, message, 'ERROR');
    }

    @isTest
    public static void testCaseResendingDocuSignException3() {
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            DocuSign_Credit_Agreement_Initiated__c, 
                                                            genesis__Status__c
                                                        FROM genesis__Applications__c
                                                        WHERE Signing_Method__c = 'Email - Docusign'];
        applicationObj.Signing_Method__c = null;
        Database.update(applicationObj, true);
        Test.startTest();
        String message = SkuidActionController.reSendingDocuSignWS(applicationObj.Id);
        Test.stopTest();
        
        System.assertNotEquals(clcommon.constants.SUCCESS, message, 'ERROR');
    }

    @isTest
    public static void testCaseResendingDocuSignException4() {
        Test.startTest();
        String message = SkuidActionController.reSendingDocuSignWS(null);
        Test.stopTest();

        System.assertNotEquals(clcommon.constants.SUCCESS, message, 'ERROR');
    }

    @isTest
    public static void testCaseResendingDocuSignException6() {
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            DocuSign_Credit_Agreement_Initiated__c, 
                                                            genesis__Status__c
                                                        FROM genesis__Applications__c
                                                        WHERE Signing_Method__c = 'Email - Docusign'];
        Test.startTest();
        String message = SkuidActionController.reSendingDocuSignWS(applicationObj.id + 'test');
        Test.stopTest();

        System.assertNotEquals(clcommon.constants.SUCCESS, message, 'ERROR');
    }
}