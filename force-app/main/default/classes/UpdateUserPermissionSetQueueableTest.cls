/**
 * @description       : 
 * @author            : Soumik Pattanayak
 * @group             : 
 * @last modified on  : 09-01-2025
 * @last modified by  : Soumik Pattanayak
**/
@Istest
private class UpdateUserPermissionSetQueueableTest {
    @TestSetup
    static void makeData(){
        //Create Account contact grower
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createAccount();
        borrowerAccountObj.Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.insert(borrowerAccountObj, true);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        borrowerContactObj.genesis__SSN__c = '123456789';
        Database.insert(borrowerContactObj, true);
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        borrowerUserObj.isActive = true;
        Database.insert(borrowerUserObj, true);
    }

    /**
    * @description get admin user
    * @author Soumik Pattanayak | 08-01-2025 
    * @return User 
    **/
    private static User getUser(){
        return [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true AND id != :UserInfo.getUserId() LIMIT 1];
    }

    /**
    * @description get the grower user
    * @author Soumik Pattanayak | 08-01-2025 
    * @return User 
    **/
    private static User getGrowerUser(){
        return [SELECT Id FROM User WHERE userName = 'star.lord@yopmail.com' LIMIT 1];
    }

    /**
    * @description assign permission set to the user
    * @author Soumik Pattanayak | 08-01-2025 
    * @param userObj 
    * @param permissionSetName 
    **/
    private static void permissionSetAssignment(User userObj, String permissionSetName){
        User userObjj = getUser();
        System.runAs(userObjj){
            PermissionSetAssignment psa = ApplicationOriginationTestHelper.createPermissionSetAssignment(permissionSetName, userObj.Id);
            Database.insert(psa, true);
        }
    }

    /**
    * @description check permission set size of the user
    * @author Soumik Pattanayak | 09-01-2025 
    * @param userObj 
    * @return boolean 
    **/
    private static Integer checkPermissionSetAssignment(User userObj){
        List<PermissionSet> psList = [SELECT id FROM PermissionSet WHERE name IN (:PortalConstants.GREY_LABEL_COOP_TYPE, :PortalConstants.WHITE_LABEL_COOP_TYPE)];
        List<PermissionSetAssignment> psaObj = [SELECT id FROM PermissionSetAssignment WHERE PermissionSetId IN :psList AND AssigneeId = :userObj.Id];
        return psaObj.size();
    }

    /**
    * @description test when no permission set is assigned
    * @author Soumik Pattanayak | 09-01-2025 
    **/
    @IsTest
    private static void testUserWithNoPermissionSet(){
        User userObj = getUser();
        User growerUser = getGrowerUser();
        System.runAs(userObj){
            Test.startTest();
            System.enqueueJob(new UpdateUserPermissionSetQueueable(growerUser.Id, new List<String>{PortalConstants.WHITE_LABEL_COOP_TYPE}));
            Test.stopTest();
            System.assertEquals(1, checkPermissionSetAssignment(growerUser), PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description test when no permission set is assigned for both portals
    * @author Soumik Pattanayak | 09-01-2025 
    **/
    @IsTest
    private static void testUserWithNoPermissionSetBothPortal(){
        User userObj = getUser();
        User growerUser = getGrowerUser();
        System.runAs(userObj){
            Test.startTest();
            System.enqueueJob(new UpdateUserPermissionSetQueueable(growerUser.Id, new List<String>{PortalConstants.WHITE_LABEL_COOP_TYPE,PortalConstants.GREY_LABEL_COOP_TYPE}));
            Test.stopTest();
            System.assertEquals(2, checkPermissionSetAssignment(growerUser), PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description test with permission set assigned
    * @author Soumik Pattanayak | 09-01-2025 
    **/
    @IsTest
    private static void testUserWithPermissionSet(){
        User userObj = getUser();
        User growerUser = getGrowerUser();
        permissionSetAssignment(growerUser, PortalConstants.GREY_LABEL_COOP_TYPE);
        System.runAs(userObj){
            Test.startTest();
            System.enqueueJob(new UpdateUserPermissionSetQueueable(growerUser.Id, new List<String>{PortalConstants.GREY_LABEL_COOP_TYPE}));
            Test.stopTest();
            System.assertEquals(1, checkPermissionSetAssignment(growerUser), PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description test with permission set assigned for both portals
    * @author Soumik Pattanayak | 09-01-2025 
    **/
    @IsTest
    private static void testUserWithPermissionSetBothPortal(){
        User userObj = getUser();
        User growerUser = getGrowerUser();
        permissionSetAssignment(growerUser, PortalConstants.GREY_LABEL_COOP_TYPE);
        permissionSetAssignment(growerUser, PortalConstants.WHITE_LABEL_COOP_TYPE);
        System.runAs(userObj){
            Test.startTest();
            System.enqueueJob(new UpdateUserPermissionSetQueueable(growerUser.Id, new List<String>{PortalConstants.GREY_LABEL_COOP_TYPE, PortalConstants.WHITE_LABEL_COOP_TYPE}));
            Test.stopTest();
            System.assertEquals(2, checkPermissionSetAssignment(growerUser), PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description test with one permission set assigned for both portal
    * @author Soumik Pattanayak | 09-01-2025 
    **/
    @IsTest
    private static void testUserWithOnePermissionSetBothPortal(){
        User userObj = getUser();
        User growerUser = getGrowerUser();
        permissionSetAssignment(growerUser, PortalConstants.WHITE_LABEL_COOP_TYPE);
        System.runAs(userObj){
            Test.startTest();
            System.enqueueJob(new UpdateUserPermissionSetQueueable(growerUser.Id, new List<String>{PortalConstants.GREY_LABEL_COOP_TYPE, PortalConstants.WHITE_LABEL_COOP_TYPE}));
            Test.stopTest();
            System.assertEquals(2, checkPermissionSetAssignment(growerUser), PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description when user id is null
    * @author Soumik Pattanayak | 09-01-2025 
    **/
    @IsTest
    private static void testUserNullException(){
        User userObj = getUser();
        User growerUser = getGrowerUser();
        System.runAs(userObj){
            Test.startTest();
            System.enqueueJob(new UpdateUserPermissionSetQueueable(null, new List<String>{PortalConstants.WHITE_LABEL_COOP_TYPE}));
            Test.stopTest();
            System.assertEquals(0, checkPermissionSetAssignment(growerUser), PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description when permission set name list is null
    * @author Soumik Pattanayak | 09-01-2025 
    **/
    @IsTest
    private static void testPermissionSetNullException(){
        User userObj = getUser();
        User growerUser = getGrowerUser();
        System.runAs(userObj){
            Test.startTest();
            System.enqueueJob(new UpdateUserPermissionSetQueueable(growerUser.Id, null));
            Test.stopTest();
            System.assertEquals(0, checkPermissionSetAssignment(growerUser), PortalConstants.ASSERTION_FAILED);
        }
    }
}