/**
 * @description       : Test class for LateNoticeToBuyer
 * @author            : Simran
 * @group             : 
 * @last modified on  : 27-01-2025
 * @last modified by  : Soumik Pattanayak
**/

@isTest
public without sharing class LateNoticeToBuyerTest {
    /**
    * @description : This is the test setup method where test data are being created
    * @author Simran | 08-16-2024
    **/
    @TestSetup
    static void makeData(){
        genesis__Business_Information__c businessInformationObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInformationObj,true);
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInformationObj.Id);
        Database.insert(dealerAccountObj, true);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInformationObj.Id,dealerAccountObj.Id);
        Database.insert(clAccountObj, true);
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);
        User clUser = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        Database.insert(clUser, true);
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createReciprocalRole('Certified Lender');
        Database.insert(clRoleObj, true);
        clcommon__Relationship__c objRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj, 
                                                                                                dealerAccountObj.Id, 
                                                                                                clAccountObj.Id);
        Database.insert(objRelationship, true);
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createLegalEntity(PortalConstants.SOLE_PROP_ENTITY);
        Database.insert(entityObj, true);
        clcommon__CL_Product__c clProductObj=ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);
        clcommon__CL_Purpose__c clPurposeObj=ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj,true);
        Account accountObj=ApplicationOriginationTestHelper.createSolePropAccount(entityObj,businessInformationObj.Id);
        Database.insert(accountObj,true);
        Contact contactObj=ApplicationOriginationTestHelper.createBorrowerContact(accountObj.Id);
        Database.insert(contactObj,true);

        // creating dealer applicant relationship
        Dealer_Applicant_Relationship__c relationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(contactObj, dealerAccountObj.Id);
        Database.insert(relationObj, true);

        Map<String, Id> paramForApplicationMap = new Map<String, Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => accountObj.Id,
            'borrowerContactId' => contactObj.Id,
            'clAccountId' => clAccountObj.Id,
            'dealerApplicantRelationshipId' => relationObj.Id
        };
        
        genesis__Applications__c currApplicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        Database.insert(currApplicationObj,true);
        clcommon__Party_Type__c buyerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BUYER');
        Database.insert(buyerPartyTypeObj, true);
        Map<String, Id> paramForBuyerPartyMap = new Map<String, Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => buyerPartyTypeObj.Id,
            'applicationId' => currApplicationObj.Id,
            'dealerApplicantRelationshipId' => relationObj.Id
        };
        clcommon__Party__c buyerPartyObj = ApplicationOriginationTestHelper.createParty(paramForBuyerPartyMap);
        Database.insert(buyerPartyObj, true);
        Task taskObj =  ApplicationOriginationTestHelper.createTask(currApplicationObj.Id,'Notice of Security Interest (CFA Action)');
        Database.insert(taskObj,true);
        
    }
 
    /**
    * @description : This method is used to check success scenario of Adhoc NTB
    * @author Simran | 08-16-2024
    **/
    @istest
    public static void checkAdhocNTB(){
        Account dealerAccount=[SELECT Id,Phone FROM  Account WHERE Phone = '1234567890' LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c
                                                    WHERE Dealer_Name__c = :dealerAccount.Id LIMIT 1];
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(objAdmin){
            Test.startTest();
            String response = LateNoticeToBuyers.adhocNTB(applicationObj.Id);
            System.assertEquals('Document Generated Successfully', response, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : This method is used to check success scenario of Adhoc NTB Release
    * @author Simran | 08-16-2024
    **/
    @istest
    public static void checkAdhocNTBRelease(){
        Account dealerAccount=[SELECT Id,Phone FROM  Account WHERE Phone = '1234567890' LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c
                                                    WHERE Dealer_Name__c = :dealerAccount.Id LIMIT 1];
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(objAdmin){
            Test.startTest();
            String response = LateNoticeToBuyers.adhocNTBRelease(applicationObj.Id);
            System.assertEquals('Document Generated Successfully', response, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        } 
    }

    /**
    * @description : check failure scenario by passing wrong parameter
    * @author Simran | 08-16-2024
    **/
    @istest
    public static void checkInvalidApplicationId(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(objAdmin){
            Test.startTest();
            LateNoticeToBuyers.lateNotices();
            LateNoticeToBuyers.adhocNTB('bscgsg');
            String response = LateNoticeToBuyers.adhocNTBRelease('vsyhnsn');
            System.assertEquals('Document Generated Successfully', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : check SendLateNotice method for Admin User
    * @author Simran | 08-16-2024
    **/
    @istest
    public static void checkSendLateNoticeForAdmin(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(objAdmin){
            Test.startTest();
            PageReference res = LateNoticeToBuyers.sendLateNotice();
            System.assertEquals(true, res!=null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : check SendLateNotice method for CFA Admin User
    * @author Simran | 08-16-2024 
    **/
    @istest
    public static void checkSendLateNoticeForCFA(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'CFA Admin User' AND isActive = true LIMIT 1];
        System.runAs(objAdmin){
            Test.startTest();
            PageReference res = LateNoticeToBuyers.sendLateNotice();
            System.assertEquals(true, res!=null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description : check SendLateNotice method for CFA Credit User
    * @author Simran | 08-16-2024
    **/
    @istest
    public static void checkSendLateNoticeForCreditUser(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'Credit' AND isActive = true LIMIT 1];
        System.runAs(objAdmin){
            Test.startTest();
            PageReference res = LateNoticeToBuyers.sendLateNotice();
            LateNoticeToBuyers.lateNotices();
            System.assertEquals(true, res!=null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
        
    }

    /**
    * @description : check SendLateNotice method for CFA loan Accounting Team
    * @author Simran | 04-04-2024 
    **/
    @istest
    public static void checkSendLateNoticeForLoanAccounting(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'Loan Accounting' AND isActive = true LIMIT 1];
        System.runAs(objAdmin){
            Test.startTest();
            PageReference res = LateNoticeToBuyers.sendLateNotice();
            System.assertEquals(true, res==null, 'You do not have sufficient permission to call the method');
            Test.stopTest();
        }
        
    }

    /**
    * @description This method is used to check Buyer 
    * @author Simran | 04-04-2024 
    **/
    @istest
    public static void checkBuyer(){
        Account dealerAccount=[SELECT Id,Phone FROM  Account WHERE Phone = '1234567890' LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id,genesis__status__c
                                                    FROM genesis__Applications__c
                                                    WHERE Dealer_Name__c = :dealerAccount.Id LIMIT 1];
        Task taskObj = [SELECT genesis__Application__c 
                            FROM Task 
                            WHERE Subject = 'Notice of Security Interest (CFA Action)' 
                            AND genesis__Application__c=:applicationObj.Id];
        taskObj.Status = 'Completed';
        Database.update(taskObj,true);
        clcommon__Party__c partyObj = [SELECT Id,genesis__Application__r.genesis__status__c,NTB_Generated__c,genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c = :applicationObj.Id 
                                                AND clcommon__Party_Types__c = 'BUYER' LIMIT 1];
        partyObj.NTB_Generated__c = false;
        Database.update(partyObj,true);
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'Credit' AND isActive = true LIMIT 1];
        System.runAs(objAdmin){
            Test.startTest();
            LateNoticeToBuyers.lateNotices();
            List<clcommon__party__c> buyersPartyObj = [SELECT NTB_Generated__c FROM clcommon__party__c WHERE clcommon__Party_Types__c = 'BUYER'];
            System.assertEquals(true, buyersPartyObj[0].NTB_Generated__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : check Notice of Security Interest (CFA Action) task
    * @author Simran | 04-04-2024 
    **/
    @istest
    public static void checkNoticeOfSecurityInterest(){
        Account dealerAccount=[SELECT Id,Phone FROM  Account WHERE Phone = '1234567890' LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c
                                                    WHERE Dealer_Name__c = :dealerAccount.Id LIMIT 1];
        Task taskObj = [SELECT genesis__Application__c 
                        FROM Task 
                        WHERE Subject = 'Notice of Security Interest (CFA Action)' 
                        AND genesis__Application__c=:applicationObj.Id];
        taskObj.Status = 'Completed';
        Database.update(taskObj,true);
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(objAdmin){
            Test.startTest();
            LateNoticeToBuyers.lateNotices();
            List<clcommon__party__c> buyersPartyObj = [SELECT NTB_Generated__c FROM clcommon__party__c WHERE clcommon__Party_Types__c = 'BUYER'];
            System.assertEquals(true, buyersPartyObj[0].NTB_Generated__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
}