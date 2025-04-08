/***************************************************************************
 * @description       : Test class for PortalApplicationWithdrawnAPI
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 01-24-2025
 * @last modified by  : Rakesh Saraf
****************************************************************************/

@isTest
public without sharing class TestPortalApplicationWithdrawnAPI {

    @testSetup
    static void setup() {
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

        // Creating new partner program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);

        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);
        
        //creating the dealer account
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.id, newPartnerProgramObj.id);
        Database.Insert(dealerAccountObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj,true);

        //creating a user for the certified lender
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);

        // Creating Account for Borrower
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, ApplicationOriginationTestHelper.createBusinessInfoForBorrower().Id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.insert(borrowerAccountObj, true);

        // Creating Contact for Borrower
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(borrowerContactObj,true);

        // Creating User for Borrower
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(new List<User>{clUserObj,borrowerUserObj}, true);

        Account salesAgentAcc=ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.id, dealerAccountObj.id);
        Database.insert(salesAgentAcc,true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating Application
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(new Map<String,Id>{
                                                                                                                                'dealerAccountId'=> dealerAccountObj.Id,
                                                                                                                                'clProductId'=> clProductObj.Id,
                                                                                                                                'clPurposeId'=> clPurposeObj.Id,
                                                                                                                                'borrowerAccountId'=> borrowerAccountObj.Id,
                                                                                                                                'borrowerContactId'=> borrowerContactObj.Id,
                                                                                                                                'clAccountId'=> clAccountObj.Id});
        applicationObj.Dealer_Name__c = dealerAccountObj.id;
        applicationObj.Sales_Agent__c = salesAgentAcc.id;
        applicationObj.genesis__Status__c = 'NEW - ENTERED';

        //creating a new Dealer Applicant Relationship for the Application
        Dealer_Applicant_Relationship__c dealerGrowerRelation = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.id);
        Database.insert(dealerGrowerRelation,true);

        applicationObj.Dealer_Applicant_Relationship__c=dealerGrowerRelation.id;
        Database.insert(applicationObj,true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,clAccountObj.Id,borrowerAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        // Creating Certified Lender Party Type
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');

        // Create Borrower Party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');

        Database.insert(new List<clcommon__Party_Type__c>{clPartyTypeObj,borrowerPartyTypeObj}, true);

        // Creating Certified Lender Party
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                                    'accountId'=> clAccountObj.Id,
                                                                                                    'contactId'=> clContactObj.Id,
                                                                                                    'partyTypeId'=> clPartyTypeObj.Id,
                                                                                                    'applicationId'=> applicationObj.Id});

        // Creating Borrower Party
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                                            'accountId'=> borrowerAccountObj.Id,
                                                                                                            'contactId'=> borrowerContactObj.Id,
                                                                                                            'partyTypeId'=> borrowerPartyTypeObj.Id,
                                                                                                            'applicationId'=> applicationObj.Id});
        borrowerPartyObj.Dealer_Applicant_Relationship__c=dealerGrowerRelation.id;
        borrowerPartyObj.State__c='PH';
        borrowerPartyObj.City__c='PHILLY';
        Database.insert(new List<clcommon__Party__c>{clPartyObj,borrowerPartyObj},true);
    }

   
    /**
    * @description test case where a borrower withraws an application
    * @author Rakesh Saraf | 11-21-2024 
    **/
    @isTest
    private static void testwWithdrawFromBorrower() {
        User borrowerUserObj = ApplicationOriginationTestHelper.getBorrowerUser('Albin');
        List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                            genesis__Status__c,
                                                            Sales_Agent__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];

        Map<String, Object> request = new Map<String,Object>();
        request.put('applicationId', applicationList[0].Id);
        System.runAs(borrowerUserObj) {
            Test.startTest();
            PortalApplicationWithdrawnAPI portalApplWithdrawnAPIObj = new PortalApplicationWithdrawnAPI();
            clcommon.Response response = portalApplWithdrawnAPIObj.invokeAction(null, null, request);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS');
        }
    }

    /**
    * @description test case where a cl withraws an application
    * @author Rakesh Saraf | 11-21-2024 
    **/
    @isTest
    private static void testWithdrawFromCL() {
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                            genesis__Status__c,
                                                            Sales_Agent__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];

        Map<String, Object> request = new Map<String,Object>();
        request.put('applicationId', applicationList[0].Id);
        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
                PortalApplicationWithdrawnAPI portalApplWithdrawnAPIObj = new PortalApplicationWithdrawnAPI();
                clcommon.Response response = portalApplWithdrawnAPIObj.invokeAction(null, null, request);
            Test.stopTest();
            
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Falied');
        }
        List<genesis__Applications__c> newApplicationObj=[SELECT Id,
                                                                genesis__Status__c
                                                        FROM genesis__Applications__c
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        System.assertEquals('PENDING WITHDRAWAL',newApplicationObj[0].genesis__Status__c,'Failure');
    }

    
    /**
    * @description test case when the address is not present in the dealer applicant relationhip record
    * @author Rakesh Saraf | 11-21-2024 
    **/
    @isTest
    private static void testNoAddressForBorrower() {
        User borrowerUserObj = ApplicationOriginationTestHelper.getBorrowerUser('Albin');
        List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                            genesis__Status__c,
                                                            Sales_Agent__c,
                                                            genesis__Contact__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];        

        List<clcommon__Party__c> borrowerPrtyList=[SELECT Id,
                                                          City__c,
                                                          State__c
                                                    FROM clcommon__Party__c
                                                    WHERE clcommon__Party_Types__c =: 'BORROWER'
                                                    LIMIT 1];
        borrowerPrtyList[0].city__c=null;
        borrowerPrtyList[0].State__c=null;
        Database.update(borrowerPrtyList,true);
        
        Map<String, Object> request = new Map<String,Object>();
        request.put('applicationId', applicationList[0].Id);
        System.runAs(borrowerUserObj) {
            Test.startTest();
            PortalApplicationWithdrawnAPI portalApplWithdrawnAPIObj = new PortalApplicationWithdrawnAPI();
            clcommon.Response response = portalApplWithdrawnAPIObj.invokeAction(null, null, request);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS');
        }
    }

    /**
    * @description test case for a sales agent
    * @author Rakesh Saraf | 11-22-2024 
    **/
    @isTest
    private static void testCaseSalesAgent() {
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                            genesis__Status__c,
                                                            Sales_Agent__c 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        
         Map<String, Object> request = new Map<String,Object>();
         request.put('applicationId', applicationList[0].Id);
        if (certifiedLenderUserObj != null) {
             System.runAs(certifiedLenderUserObj) {
                 Test.startTest();
                 PortalApplicationWithdrawnAPI portalApplWithdrawnAPIObj = new PortalApplicationWithdrawnAPI();
                 clcommon.Response response = portalApplWithdrawnAPIObj.invokeAction(null, null, request);
                 Test.stopTest();
                 System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS');
            }
        }
    }

    /**
    * @description test case for when the application id is not returned from the portal
    * @author Rakesh Saraf | 11-21-2024 
    **/
    @isTest
    private static void apllicationIdNullException() {
        User certifiedLenderObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String,Object>();
        request.put('applicationId', null);
        System.runAs(certifiedLenderObj) {
            Test.startTest();
            PortalApplicationWithdrawnAPI portalApplWithdrawnAPIObj = new PortalApplicationWithdrawnAPI();
            clcommon.Response response = portalApplWithdrawnAPIObj.invokeAction(null, null, request);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'ERROR'); 
            Test.stopTest();
        }
    }

    
    /** 
    * @description test case for when the application is active
    * @author Rakesh Saraf | 11-21-2024 
    **/
    @isTest
    private static void activeStatusException() {
        User certifiedLenderObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                            genesis__Status__c 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];

        applicationList[0].genesis__Status__c='ACTIVE';
        Database.update(applicationList,true);

        Map<String, Object> request = new Map<String,Object>();
        request.put('applicationId', applicationList[0].Id);
        System.runAs(certifiedLenderObj) {
            Test.startTest();
            PortalApplicationWithdrawnAPI portalApplWithdrawnAPIObj = new PortalApplicationWithdrawnAPI();
            clcommon.Response response = portalApplWithdrawnAPIObj.invokeAction(null, null, request);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Error not thrown'); 
            Test.stopTest();
        }
    }
    
    /**
    * @description test to throw an exception from the main class
    * @author Rakesh Saraf | 11-21-2024 
    **/
    @isTest
    private static void checkException(){
        User certifiedLenderObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                            genesis__Status__c 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        List<Id> applicationIdList = new List<Id>();
        applicationIdList.add(applicationList[0].Id);                                                
        Map<String, Object> request = new Map<String,Object>();
        request.put('applicationId', applicationIdList);
        System.runAs(certifiedLenderObj) {
            Test.startTest();
            PortalApplicationWithdrawnAPI portalApplWithdrawnAPIObj = new PortalApplicationWithdrawnAPI();
            clcommon.Response response = portalApplWithdrawnAPIObj.invokeAction(null, null, request);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'ERROR'); 
            Test.stopTest();
        }
    }
    /**
    * @description test case for when the borrower is a corporation
    * @author Rakesh Saraf | 11-22-2024 
    **/
    @isTest
    private static void testBillingAddressOfBorrowerSec() {
        User borrowerUserObj = [SELECT Id, 
                                        Name,
                                        ProfileId,
                                        Profile.Name
                                    FROM User 
                                    WHERE UserName = 'star.lord@yopmail.com'];
        clcommon__Legal_Entity__c entityObj = [SELECT Id
                                                    FROM clcommon__Legal_Entity__c
                                                    WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'];
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj, true);
        List<genesis__Applications__c> applicationList = [ SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Number__c = '300023456'
                                                    LIMIT 1];                                             
        
        Map<String, Object> request = new Map<String,Object>();
        request.put('applicationId', applicationList[0].Id);
        System.runAs(borrowerUserObj) {
            Test.startTest();
            PortalApplicationWithdrawnAPI portalApplWithdrawnAPIObj = new PortalApplicationWithdrawnAPI();
            clcommon.Response response = portalApplWithdrawnAPIObj.invokeAction(null, null, request);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS');
        }
    }

    /**
    * @description send email for application withdrawal but the borrowr address is missing
    * @author Rakesh Saraf | 12-19-2024 
    **/
    @isTest
    private static void testWithdrawFromCLWithoutAddress() {
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                            genesis__Status__c,
                                                            Sales_Agent__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];

        clcommon__Party__c borrowerParty=[SELECT ID,
                                                 City__c,
                                                 State__c
                                          FROM clcommon__Party__c
                                          WHERE genesis__Application__c =: applicationList[0].Id
                                          AND clcommon__Type__r.Name = 'BORROWER'];

        borrowerParty.State__c=PortalConstants.EMPTY_STRING;
        borrowerParty.City__c=PortalConstants.EMPTY_STRING;
        Database.update(borrowerParty,true);
        
        Map<String, Object> request = new Map<String,Object>();
        request.put('applicationId', applicationList[0].Id);
        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
                PortalApplicationWithdrawnAPI portalApplWithdrawnAPIObj = new PortalApplicationWithdrawnAPI();
                clcommon.Response response = portalApplWithdrawnAPIObj.invokeAction(null, null, request);
            Test.stopTest();
            
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Falied');
        }
        List<genesis__Applications__c> newApplicationObj=[SELECT Id,
                                                                genesis__Status__c
                                                        FROM genesis__Applications__c
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        System.assertEquals('PENDING WITHDRAWAL',newApplicationObj[0].genesis__Status__c,'Failure');
    }

    @isTest
    private static void testWithdrawFromCLGMK() {
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                            genesis__Status__c,
                                                            Sales_Agent__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];

        Account dealerAccObj=[SELECT ID,
                                     Coop_Type__c
                              FROM ACCOUNT
                              WHERE Name='Kisan Loan'];
        dealerAccObj.Coop_Type__c='Growmark';
        Database.update(dealerAccObj,true);

        Map<String, Object> request = new Map<String,Object>();
        request.put('applicationId', applicationList[0].Id);
        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
                PortalApplicationWithdrawnAPI portalApplWithdrawnAPIObj = new PortalApplicationWithdrawnAPI();
                clcommon.Response response = portalApplWithdrawnAPIObj.invokeAction(null, null, request);
            Test.stopTest();
            
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Falied');
        }
        List<genesis__Applications__c> newApplicationObj=[SELECT Id,
                                                                genesis__Status__c
                                                        FROM genesis__Applications__c
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        System.assertEquals('PENDING WITHDRAWAL',newApplicationObj[0].genesis__Status__c,'Failure');
    }
}