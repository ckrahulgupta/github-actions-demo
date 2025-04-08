/**
 * @description       : test Class to cover EnableGrowerPortal
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 08-01-2025
 * @last modified by  : Soumik Pattanayak
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   07-09-2022   Subham Nandi   Initial Version
**/
@isTest
private class TestEnableGrowerPortal {
    @TestSetup
    static void makeData(){
        //create dealer account
        Account dealerCFAAccountObj = ApplicationOriginationTestHelper.createDealerAccount(null);
        Database.insert(dealerCFAAccountObj, true);
        Account dealerGMKAccountObj = ApplicationOriginationTestHelper.createDealerAccount(null);
        dealerGMKAccountObj.Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.insert(dealerGMKAccountObj, true);

        //Create Account contact grower
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createAccount();
        borrowerAccountObj.Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        borrowerAccountObj.ParentId = dealerCFAAccountObj.Id;
        Database.insert(borrowerAccountObj, true);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        borrowerContactObj.genesis__SSN__c = '123456789';
        Database.insert(borrowerContactObj, true);
        Dealer_Applicant_Relationship__c cfaRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj, dealerCFAAccountObj.Id);
        Dealer_Applicant_Relationship__c gmkRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj, dealerGMKAccountObj.Id);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{cfaRelationObj, gmkRelationObj}, true);

        //Create Account contact for 2nd grower with user
        Account borrowerTwoAccountObj = ApplicationOriginationTestHelper.createAccount();
        borrowerTwoAccountObj.ParentId = dealerGMKAccountObj.Id;
        Database.insert(borrowerTwoAccountObj, true);
        Contact borrowerTwoContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerTwoAccountObj.Id);
        borrowerTwoContactObj.genesis__SSN__c = '987654321';
        Database.insert(borrowerTwoContactObj, true);
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(borrowerUserObj, true);
        User userObj = getUser();
        System.runAs(userObj){
            PermissionSetAssignment psa = ApplicationOriginationTestHelper.createPermissionSetAssignment(PortalConstants.WHITE_LABEL_COOP_TYPE, borrowerUserObj.Id);
            Database.insert(psa, true);
        }
        Dealer_Applicant_Relationship__c cfaRelationTwoObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerTwoContactObj, dealerCFAAccountObj.Id);
        Dealer_Applicant_Relationship__c gmkRelationTwoObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerTwoContactObj, dealerGMKAccountObj.Id);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{cfaRelationTwoObj, gmkRelationTwoObj}, true);

    }

    /**
    * @description 
    * @author Soumik Pattanayak | 08-01-2025 
    * @return User 
    **/
    private static User getUser(){
        return [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 08-01-2025 
    * @return Contact 
    **/
    private static Contact getContactWithUser(){
        return [SELECT id FROM Contact WHERE id IN (SELECT ContactId FROM User) LIMIT 1];
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 08-01-2025 
    * @return Contact 
    **/
    private static Contact getContactWithoutUser(){
        return [SELECT id FROM Contact WHERE id NOT IN (SELECT ContactId FROM User) LIMIT 1];
    }

    /**
    * @description test getPermissionSetList for no user
    * @author Soumik Pattanayak | 07-01-2025 
    **/
    @isTest
    static void testGetPermissionSetList() {
        User userObj = getUser();
        Contact contactObj = getContactWithoutUser();
        System.runAs(userObj){
            Test.startTest();
            Object testWrapper = EnableGrowerPortal.getPermissionSetList(contactObj.Id);
            System.assertEquals(true, testWrapper!=null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description test getPermissionSetList for with user
    * @author Soumik Pattanayak | 07-01-2025 
    **/
    @isTest
    static void testGetPermissionSetListWithUser() {
        User userObj = getUser();
        Contact contactObj = getContactWithUser();
        System.runAs(userObj){
            Test.startTest();
            Object permissionSetList = EnableGrowerPortal.getPermissionSetList(contactObj.Id);
            System.assertEquals(true, permissionSetList!=null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description updatePermissionSetBothPortal for both coop
    * @author Soumik Pattanayak | 07-01-2025 
    **/
    @isTest
    static void testUpdatePermissionSetBothPortal() {
        User userObj = getUser();
        Contact contactObj = getContactWithUser();
        System.runAs(userObj){
            Test.startTest();
            String response = EnableGrowerPortal.updatePermissionSet(new List<String>{PortalConstants.GREY_LABEL_COOP_TYPE,PortalConstants.WHITE_LABEL_COOP_TYPE},contactObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description updatePermissionSetBothPortal for gmk coop
    * @author Soumik Pattanayak | 07-01-2025 
    **/
    @isTest
    static void testUpdatePermissionSetGMKPortal() {
        User userObj = getUser();
        Contact contactObj = getContactWithUser();
        System.runAs(userObj){
            Test.startTest();
            String response = EnableGrowerPortal.updatePermissionSet(new List<String>{PortalConstants.WHITE_LABEL_COOP_TYPE},contactObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description updatePermissionSetBothPortal for gmk coop with no user
    * @author Soumik Pattanayak | 07-01-2025 
    **/
    @isTest
    static void testUpdatePermissionSetGMKPortalWithoutUser() {
        User userObj = getUser();
        Contact contactObj = getContactWithoutUser();
        System.runAs(userObj){
            Test.startTest();
            String response = EnableGrowerPortal.updatePermissionSet(new List<String>{PortalConstants.WHITE_LABEL_COOP_TYPE},contactObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description updatePermissionSetBothPortal exception
    * @author Soumik Pattanayak | 07-01-2025 
    **/
    @isTest
    static void testUpdatePermissionSetException() {
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            String response = EnableGrowerPortal.updatePermissionSet(new List<String>{PortalConstants.WHITE_LABEL_COOP_TYPE}, null);
            System.assertEquals(PortalConstants.SOMETHING_WENT_WRONG, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
}