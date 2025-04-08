/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 08-16-2024
 * @last modified by  :  Pritam Roy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   19-07-2022   Subham Nandi   Initial Version
**/
@isTest
public with sharing class TestCreateNewPortalUserTrigger {
    /**
    * @description : Test Setup
    * @author  Pritam Roy | 08-16-2024 
    **/
    @TestSetup
    static void makeData(){
        clcommon__Legal_Entity__c legalEntityObj = TestClassHelper.createLegalEntity(PortalConstants.SOLE_PROP_ENTITY);
        Database.Insert(legalEntityObj,true);
        genesis__Business_Information__c businessInfoObj = TestClassHelper.createBusinessInfoForBorrower();
        Database.Insert(businessInfoObj,true);
        Account accountObj = TestClassHelper.createSolePropAccount(legalEntityObj,businessInfoObj.id);
        Database.Insert(accountObj,true);
        Contact contactObj = TestClassHelper.createBorrowerContact(accountObj.id);
        Database.Insert(contactObj,true);
         
    }
    /**
    * @description : Create new User Success
    * @author  Pritam Roy | 08-16-2024 
    **/
    @isTest
    public static void testingSuccessScenario(){
        Contact contactObj = [SELECT id,FirstName,LastName,Email FROM Contact];
        Profile profileObj = [SELECT Id FROM Profile WHERE Name =: PortalConstants.GROWER_PROFILE];
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        New_Portal_User__e portalUserObj = new New_Portal_User__e(First_Name__c = contactObj.FirstName,Last_Name__c = contactObj.LastName, Email__c = contactObj.Email,Contact_Id__c = contactObj.id, Profile_Id__c = profileObj.id, Federation_Identifier__c = contactObj.LastName + contactObj.FirstName );
        Test.startTest();
        System.runAs(objAdmin){
            Database.SaveResult result = EventBus.publish(portalUserObj);
            System.assertEquals(true,result.isSuccess(), 'Invalid Exception');
        }
        Test.stopTest();
    }
    
    /**
    * @description : Create new User Failure
    * @author  Pritam Roy | 08-16-2024 
    **/
    @isTest
    public static void testingFailureScenario(){
        Contact contactObj = [SELECT id,FirstName,LastName,Email FROM Contact];
        Profile profileObj = [SELECT Id FROM Profile WHERE Name =: PortalConstants.GROWER_PROFILE];
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        New_Portal_User__e portalUserObj = new New_Portal_User__e(First_Name__c = contactObj.FirstName,Last_Name__c = contactObj.LastName, Email__c = 'InvalidEmail',Contact_Id__c = contactObj.id, Profile_Id__c = profileObj.id, Federation_Identifier__c = contactObj.LastName + contactObj.FirstName );
        Test.startTest();
        System.runAs(objAdmin){
            Database.SaveResult result = EventBus.publish(portalUserObj);
            System.assertEquals(true,result.isSuccess(),'Exception not thrown');
        }
        Test.stopTest(); 
    }

    /**
    * @description : Testing new User without First Name
    * @author  Pritam Roy | 08-16-2024 
    **/
    @isTest
    public static void testingWithoutFirstName(){
        Contact contactObj = [SELECT id,FirstName,LastName,Email FROM Contact];
        Profile profileObj = [SELECT Id FROM Profile WHERE Name =: PortalConstants.GROWER_PROFILE];
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        New_Portal_User__e portalUserObj = new New_Portal_User__e(Last_Name__c = contactObj.LastName, Email__c = contactObj.Email,Contact_Id__c = contactObj.id,Profile_Id__c = profileObj.id, Federation_Identifier__c = contactObj.LastName + contactObj.FirstName );
        Test.startTest();
        System.runAs(objAdmin){
            Database.SaveResult result = EventBus.publish(portalUserObj);
            System.assertEquals(true,result.isSuccess(), 'Invalid Exception');
        }
        Test.stopTest();
    }
    /**
    * @description : Testing new User with Long Lastname
    * @author  Pritam Roy | 08-16-2024 
    **/
    @isTest
    public static void testingLongLastName(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Contact contactObj = [SELECT id,FirstName,LastName,Email FROM Contact];
        contactObj.LastName = 'Voldemort';
        Database.upsert(contactObj, true);
        Profile profileObj = [SELECT Id FROM Profile WHERE Name =: PortalConstants.GROWER_PROFILE];
        New_Portal_User__e portalUserObj = new New_Portal_User__e(First_Name__c = contactObj.FirstName,Last_Name__c = contactObj.LastName, Email__c = contactObj.Email,Contact_Id__c = contactObj.id,Profile_Id__c = profileObj.id, Federation_Identifier__c = contactObj.LastName + contactObj.FirstName );
        Test.startTest();
        System.runAs(objAdmin){
            Database.SaveResult result = EventBus.publish(portalUserObj);
            System.assertEquals(true,result.isSuccess(), 'Invalid Exception');
        }
        
        Test.stopTest();
    }
}