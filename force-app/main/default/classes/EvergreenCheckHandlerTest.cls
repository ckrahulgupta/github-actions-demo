/**
 * @description       :  Test Class for Evergreen Handler
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 11-01-2025
 * @last modified by  : Soumik Pattanayak
**/
@isTest
public with sharing class EvergreenCheckHandlerTest {
    /**
    * @description Test Setup
    * @author  Pritam Roy | 05-13-2024 
    **/
    @TestSetup
    static void makeData(){
        // Object List declarations
        List<clcommon__Party_Type__c> partyTypeList;
        List<Account> accountList;
        List<Contact> contactList;
        List<genesis__Business_Information__c> businsessInfoList;
        List<clcommon__party__c> partyList;
        List<clcommon__Legal_Entity__c> entityObj;

        // Creating Legal Entity
        clcommon__Legal_Entity__c individualEntityObj = LoanServicingTestHelper.createLegalEntity(PortalConstants.SOLE_PROP_ENTITY);

        clcommon__Legal_Entity__c corpEntityObj = LoanServicingTestHelper.createLegalEntity(PortalConstants.CORPORATION);

        clcommon__Legal_Entity__c dbaEntityObj = LoanServicingTestHelper.createLegalEntity(PortalConstants.INDIVIDUAL_ENTITY);

        entityObj = new  List<clcommon__Legal_Entity__c>{
            individualEntityObj,
            corpEntityObj,
            dbaEntityObj
        };
        Database.insert(entityObj);
        // Creating Party Types
        clcommon__Party_Type__c borrowerPartyTypeObj = LoanServicingTestHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);

        clcommon__Party_Type__c dealerPartyTypeObj = LoanServicingTestHelper.createPartyType(PortalConstants.DEALER_PARTY_NAME);

        partyTypeList = new List<clcommon__Party_Type__c>{
            borrowerPartyTypeObj,
            dealerPartyTypeObj
        };
        Database.insert(partyTypeList, true);

        // Creating CL Product for Application
        clcommon__CL_Product__c clProductObj = LoanServicingTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating CL Purpose for Application
        clcommon__CL_Purpose__c clPurposeObj = LoanServicingTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForDealer();

        genesis__Business_Information__c borrowerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForBorrower();

        businsessInfoList = new List<genesis__Business_Information__c>{
            dealerBusinessInfoObj,
            borrowerBusinessInfoObj
        };
        Database.insert(businsessInfoList, true);

        // Creating Accounts
        Account dealerAccountObj = LoanServicingTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);

        Account borrowerAccountObj = LoanServicingTestHelper.createSolePropAccount(individualEntityObj, borrowerBusinessInfoObj.Id);
        accountList = new List<Account>{
            borrowerAccountObj
        };
        Database.insert(accountList, true);

        // Creating Contact

        Contact borrowerContactObj = LoanServicingTestHelper.createBorrowerContact(borrowerAccountObj.Id);    
        contactList = new List<Contact>{
            borrowerContactObj
        };
        Database.insert(contactList, true);

        // Creating Dealer_Applicant_Relationship__c
        Dealer_Applicant_Relationship__c dealerAppRelationObj = LoanServicingTestHelper.createDealerApplicantRelationship(borrowerContactObj, dealerAccountObj.Id);
        Database.insert(dealerAppRelationObj, true);

        // Creating Application
        Map<String,Id> applicationDataMap = new Map<String,Id>{
            'dealerAccountId'=> dealerAccountObj.Id,
            'clProductId'=> clProductObj.Id,
            'clPurposeId'=> clPurposeObj.Id,
            'borrowerAccountId'=> borrowerAccountObj.Id,
            'borrowerContactId'=> borrowerContactObj.Id,
            //'clAccountId'=> clAccountObj.Id
            'dealerApplicantRelationshipId'=> dealerAppRelationObj.Id
        };
        genesis__Applications__c applicationObj = LoanServicingTestHelper.createPrevCropYearApplication(applicationDataMap);
        Database.insert(applicationObj,true);

        //Creating Parties

        // Creating Dealer Party
        Map<String,Id> dealerPartyMapData = new Map<String,Id>{
            'accountId'=> dealerAccountObj.Id,
            'partyTypeId'=> dealerPartyTypeObj.Id,
            'applicationId'=> applicationObj.Id
        };
        clcommon__Party__c dealerPartyObj = LoanServicingTestHelper.createParty(dealerPartyMapData);

        // Creating Borrower Party
        Map<String,Id> borrowerPartyMapData = new Map<String,Id>{
            'accountId'=> borrowerAccountObj.Id,
            'contactId'=> borrowerContactObj.Id,
            'partyTypeId'=> borrowerPartyTypeObj.Id,
            'applicationId'=> applicationObj.Id,
            'dealerApplicantRelationshipId'=> dealerAppRelationObj.Id
        };
        clcommon__Party__c borrowerPartyObj = LoanServicingTestHelper.createParty(borrowerPartyMapData);

        partyList = new List<clcommon__Party__c>{
            dealerPartyObj,
            borrowerPartyObj
        };
        Database.insert(partyList, true);

        List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList = ApplicationOriginationTestHelper.createCreditRatingMatrix();
        Database.insert(creditRatingMatrixList,true);
    }

    /**
    * @description : Check Evergreen Eligibility failure
    * @author  Soumik Pattanayak | 12-04-2024 
    **/
    @isTest
    private static void checkEvergreenEligibilityFailure(){
        User userObj = [SELECT Id 
                            FROM User 
                            WHERE Profile.name = 'System Administrator' 
                            AND isActive = true 
                            LIMIT 1];
        List<genesis__Applications__c> appList = [SELECT Id,
                                                    Dealer_Applicant_Relationship__c
                                            FROM genesis__Applications__c
                                            WHERE genesis__Loan_Number__c = '300023457'
                                            LIMIT 1];
                                            
        Dealer_Applicant_Relationship__c relationObj = new Dealer_Applicant_Relationship__c(Id = appList[0].Dealer_Applicant_Relationship__c);
        relationObj.Is_Evergreen_Eligible__c = false;
        relationObj.Has_Past_Due__c = false;
        relationObj.Is_Non_Accrual__c = false;
        Database.update(relationObj,true);

        System.runAs(userObj){
            Test.startTest();
            genesis__Applications__c restultAppObj = EvergreenCheckHandler.checkIsEvergreenEligible(appList[0]);
            Test.stopTest();
            System.assertEquals(false ,restultAppObj.Is_Evergreen_Eligible__c, 'Assertion Failed');
        }
    }

    /**
    * @description : Check Evergreen Eligibility failure
    * @author  Soumik Pattanayak | 12-04-2024 
    **/
    @isTest
    private static void checkEvergreenEligibilityFailureForPastDue(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
 
        List<genesis__Applications__c> appList = [SELECT Id,
                                                    Dealer_Applicant_Relationship__c
                                            FROM genesis__Applications__c
                                            WHERE genesis__Loan_Number__c = '300023457'
                                            LIMIT 1];
                                            
        Dealer_Applicant_Relationship__c relationObj = new Dealer_Applicant_Relationship__c(Id = appList[0].Dealer_Applicant_Relationship__c);
        relationObj.Is_Evergreen_Eligible__c = true;
        relationObj.Has_Past_Due__c = true;
        relationObj.Is_Non_Accrual__c = false;
        Database.update(relationObj,true);

        System.runAs(userObj){
            Test.startTest();
            genesis__Applications__c restultAppObj = EvergreenCheckHandler.checkIsEvergreenEligible(appList[0]);
            Test.stopTest();
            System.assertEquals(false ,restultAppObj.Is_Evergreen_Eligible__c, 'Assertion Failed');
        }
    }

    /**
    * @description : Check Evergreen Eligibility failure
    * @author  Soumik Pattanayak | 12-04-2024 
    **/
    @isTest
    private static void checkEvergreenEligibilityFailureNonAccrual(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
 
        List<genesis__Applications__c> appList = [SELECT Id,
                                                    Dealer_Applicant_Relationship__c
                                            FROM genesis__Applications__c
                                            WHERE genesis__Loan_Number__c = '300023457'
                                            LIMIT 1];
                                            
        Dealer_Applicant_Relationship__c relationObj = new Dealer_Applicant_Relationship__c(Id = appList[0].Dealer_Applicant_Relationship__c);
        relationObj.Is_Evergreen_Eligible__c = true;
        relationObj.Has_Past_Due__c = false;
        relationObj.Is_Non_Accrual__c = true;
        Database.update(relationObj,true);

        System.runAs(userObj){
            Test.startTest();
            genesis__Applications__c restultAppObj = EvergreenCheckHandler.checkIsEvergreenEligible(appList[0]);
            Test.stopTest();
            System.assertEquals(false ,restultAppObj.Is_Evergreen_Eligible__c, 'Assertion Failed');
        }
    }

    /**
    * @description : Check Evergreen Eligibility Success
    * @author  Pritam Roy | 05-13-2024 
    **/
    @isTest
    private static void checkEvergreenEligibilitySuccess(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
 
        List<genesis__Applications__c> appList = [SELECT Id,
                                                    Dealer_Applicant_Relationship__c
                                            FROM genesis__Applications__c
                                            WHERE genesis__Loan_Number__c = '300023457'
                                            LIMIT 1];
                    
        Dealer_Applicant_Relationship__c relationObj = new Dealer_Applicant_Relationship__c(Id = appList[0].Dealer_Applicant_Relationship__c);
        relationObj.Is_Evergreen_Eligible__c = true;
        relationObj.Has_Past_Due__c = false;
        relationObj.Is_Non_Accrual__c = false;
        Database.update(relationObj,true);
        System.runAs(userObj){
            Test.startTest();
            genesis__Applications__c restultAppObj = EvergreenCheckHandler.checkIsEvergreenEligible(appList[0]);
            Test.stopTest();
            System.assertEquals(true ,restultAppObj.Is_Evergreen_Eligible__c, 'Assertion Failed');
        }
    }
    
    /**
    * @description : Update Evergreen Eligibility - Success
    * @author Sk Minsar | 05-15-2024 
    **/
    @isTest
    private static void updateEvergreenStatusForAllowed(){
        genesis__Applications__c objApplication = new genesis__Applications__c();
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
 
        List<genesis__Credit_Rating_Matrix__c> objCreditRatingTiersLists = [SELECT  Id, 
                                                                                    Name 
                                                                            FROM genesis__Credit_Rating_Matrix__c 
                                                                            WHERE Name =: 'Tier 1'];
        List<genesis__Applications__c> appList = [SELECT Id,
                                                  genesis__Credit_Rating__c,   
                                                  genesis__Credit_Rating__r.name
                                FROM genesis__Applications__c
                                WHERE genesis__Loan_Number__c = '300023457'
                                LIMIT 1];
        appList[0].genesis__Credit_Rating__c = objCreditRatingTiersLists[0].id;
        Database.update(appList[0], true);

        System.runAs(userObj){
        Test.startTest();
        objApplication = EvergreenCheckHandler.updateEvergreenStatusForAllowed(appList[0],true);
        Test.stopTest();
        System.assertEquals(objApplication.Is_Evergreen_Eligible__c, true, 'Assertion Failed');
        }
    }
    /**
    * @description : Handler Evergreen Denied - Success
    * @author  Pritam Roy | 05-13-2024 
    **/
    @isTest
    private static void handleEvergreenDenied(){
        genesis__Applications__c objApplication = new genesis__Applications__c();
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
 
        List<genesis__Applications__c> appList = [SELECT Id,Is_Evergreen__c
                                FROM genesis__Applications__c
                                WHERE genesis__Loan_Number__c = '300023457'
                                LIMIT 1];
        System.runAs(userObj){
        Test.startTest();
        objApplication = EvergreenCheckHandler.updateEvergreenStatusForNotAllowed(appList[0],false);
        Test.stopTest();
        System.assertEquals(objApplication.Is_Evergreen__c, false, 'Assertion Failed');
        }
    }
    /**
    * @description : Is Evergreen Allowerd to True
    * @author  Pritam Roy | 05-13-2024 
    **/
    @isTest
    private static void isEvergreenAllowedToTrue(){
        Boolean objString;
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
 
        System.runAs(userObj){
        Test.startTest();
        objString = EvergreenCheckHandler.convertEvergreenStatusToBoolean('Allowed');
        Test.stopTest();
        System.assertEquals(objString, true, 'Assertion Failed');
        }
    }
    /**
    * @description : Is Evergreen Allowed to False
    * @author  Pritam Roy | 05-13-2024 
    **/
    @isTest
    private static void isEvergreenAllowedToFalse(){
        Boolean objString;
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
 
        System.runAs(userObj){
            Test.startTest();
            objString = EvergreenCheckHandler.convertEvergreenStatusToBoolean('Not Allowed');
            Test.stopTest();
            System.assertEquals(objString, false, 'Assertion Failed');
        }

    }

    /**
    * @description : With allowed value
    * @author  Pritam Roy | 05-13-2024 
    **/
    @isTest
    private static void testconvertEvergreenStatusToString(){
        String objString;
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
 
        System.runAs(userObj){
        Test.startTest();
        objString = EvergreenCheckHandler.convertEvergreenStatusToString(true);
        Test.stopTest();
        System.assertEquals(objString, 'Allowed', 'Assertion Failed');
        }
    }
    /**
    * @description : With not Allowed value
    * @author  Pritam Roy | 05-13-2024 
    **/
    @isTest
    private static void testCheckEvergreenNotAllowed(){
        String objString;
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
 
        System.runAs(userObj){
        Test.startTest();
        objString = EvergreenCheckHandler.convertEvergreenStatusToString(false);
        Test.stopTest();
        System.assertEquals(objString, 'Not Allowed', 'Assertion Failed');
        }
    }
}