/**
 * @description       : Test class of CreateApplicationSharingRecordsTrigger
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 07-03-2024
 * @last modified by  : Suraj Kumar
**/
@isTest 
public with sharing class CreateAppSharingRecordsTriggerTest {
    @TestSetup
    static void setup(){
        
         // creating business information
         genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
         Database.insert(dealerBusinessInfoObj, true);
         // Creating Account for Dealer
         Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
         Database.insert(dealerAccountObj, true);
 
        // creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createDealerContactRecord(dealerAccountObj.Id,'Certified Lender');
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);

        // creating user for certified lender
        User clUser = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        Database.insert(clUser, true);

        // creating Account for Field Staff Agent
        Account fsAccountObj = ApplicationOriginationTestHelper.createDealerContactRecord(dealerAccountObj.Id,'Field Staff Agent');
        Database.insert(fsAccountObj, true);

        // Creating Contact for Field Staff Agent
        Contact fsContactObj = ApplicationOriginationTestHelper.createFSAgentContact(fsAccountObj.Id);
        Database.insert(fsContactObj, true);

        // Creating Fsa user
        User fsaUser = ApplicationOriginationTestHelper.createFSAUser(fsContactObj.Id);
        Database.insert(fsaUser,true);

        // creating relationship of field staff agent
        clcommon__Reciprocal_Role__c fsRoleObj = ApplicationOriginationTestHelper.createReciprocalRole('Field Staff Agent');
        Database.insert(fsRoleObj, true);
        clcommon__Relationship__c objFSRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(fsRoleObj, 
                                                                                                        dealerAccountObj.Id, 
                                                                                                    fsAccountObj.Id);
        Database.insert(objFSRelationship, true);
                
        // creating relationship of certified lender
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createReciprocalRole('Certified Lender');
        Database.insert(clRoleObj, true);
        clcommon__Relationship__c objRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj, 
                                                                                                    dealerAccountObj.Id, 
                                                                                                    clAccountObj.Id);
        Database.insert(objRelationship, true);

        // creating borrower
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createLegalEntity(PortalConstants.SOLE_PROP_ENTITY);
        Database.insert(entityObj, true);

        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.insert(borrowerAccountObj,true);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        Database.insert(borrowerContactObj,true);

        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.id);
        Database.insert(borrowerUserObj,true);

        // creating application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>();
        paramForApplicationMap.put('dealerAccountId', dealerAccountObj.Id);
        paramForApplicationMap.put('borrowerAccountId', null);
        paramForApplicationMap.put('borrowerContactId', null);
        paramForApplicationMap.put('clAccountId', clAccountObj.Id);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        Database.insert(applicationObj, true);


         // Creating Certified Lender Party Type
         clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
         Database.insert(clPartyTypeObj, true);

        // Creating Field Staff Agent Party Type
        clcommon__Party_Type__c fsPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('FIELD STAFF AGENT');
        Database.insert(fsPartyTypeObj, true);

         // Creating Certified Lender Party
         Map<String,Id> paramForCLPartyMap = new Map<String,Id>();
         paramForCLPartyMap.put('accountId', clAccountObj.Id);
         paramForCLPartyMap.put('contactId', clContactObj.Id);
         paramForCLPartyMap.put('partyTypeId', clPartyTypeObj.Id);
         paramForCLPartyMap.put('applicationId', applicationObj.Id);
         clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(paramForCLPartyMap);
         Database.insert(clPartyObj, true);

        clcommon__Document_Category__c docCategoryObj = ApplicationOriginationTestHelper.createDocCategory(applicationObj.Id,'Driving license');
        Database.insert(docCategoryObj, true);
    }


    @isTest
    static void testCreateSharingRecords() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id, Name, Dealer_Name__c FROM genesis__Applications__c LIMIT 1];
        Account accountObj = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
        Sharing_Record__e sharingRecordEvent = new Sharing_Record__e();
        sharingRecordEvent.ApplicationId__c = applicationObj.Id;
        sharingRecordEvent.UserAccountId__c = accountObj.Id;
        System.runAs(userObj){
            Test.startTest();
            EventBus.publish(sharingRecordEvent);
            Test.stopTest();
            List<clcommon__Relationship__c> dealerRelationsList = [SELECT Id, 
                                                                clcommon__Entity__c,
                                                                clcommon__Related_Entity__c, 
                                                                clcommon__Relationship__r.Name
                                                        FROM clcommon__Relationship__c
                                                        WHERE clcommon__Entity__c = :applicationObj.Dealer_Name__c
                                                        AND clcommon__Relationship__r.Name IN (
                                                                :PortalConstants.CERTIFIED_LENDER, 
                                                                :PortalConstants.CERTIFIED_LENDER_PLUS,
                                                                :PortalConstants.INQUIRY,
                                                                :PortalConstants.INQUIRY_PLUS,
                                                                :PortalConstants.FIELD_STAFF_AGENT
                                                            )];
            List<genesis__Applications__Share> appShareList = [SELECT Id, 
                                                                    ParentId 
                                                                    FROM genesis__Applications__Share 
                                                                    WHERE ParentId = :applicationObj.Id];
            System.assertEquals(dealerRelationsList.size(), appShareList.Size(), 'Failed');
        }
    }

    @isTest
    static void testSharingRecordsWithoutAccId() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id, Name, Dealer_Name__c FROM genesis__Applications__c LIMIT 1];
        Sharing_Record__e sharingRecordEvent = new Sharing_Record__e();
        sharingRecordEvent.ApplicationId__c = applicationObj.Id;
        System.runAs(userObj){
            Test.startTest();
            EventBus.publish(sharingRecordEvent);
            Test.stopTest();
            List<clcommon__Relationship__c> dealerRelationsList = [SELECT Id, 
                                                                clcommon__Entity__c,
                                                                clcommon__Related_Entity__c, 
                                                                clcommon__Relationship__r.Name
                                                        FROM clcommon__Relationship__c
                                                        WHERE clcommon__Entity__c = :applicationObj.Dealer_Name__c
                                                        AND clcommon__Relationship__r.Name IN (
                                                                :PortalConstants.CERTIFIED_LENDER, 
                                                                :PortalConstants.CERTIFIED_LENDER_PLUS,
                                                                :PortalConstants.INQUIRY,
                                                                :PortalConstants.INQUIRY_PLUS,
                                                                :PortalConstants.FIELD_STAFF_AGENT
                                                            )];
            List<genesis__Applications__Share> appShareList = [SELECT Id, 
                                                                    ParentId 
                                                                    FROM genesis__Applications__Share 
                                                                    WHERE ParentId = :applicationObj.Id];
            System.assertEquals(dealerRelationsList.size(), appShareList.Size(), 'Failed');
        }
    }

    @isTest
    static void testSharingRecordsWithoutAppId() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id, Name, Dealer_Name__c FROM genesis__Applications__c LIMIT 1];
        Account accountObj = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
        Sharing_Record__e sharingRecordEvent = new Sharing_Record__e();
        sharingRecordEvent.UserAccountId__c = accountObj.Id;
        System.runAs(userObj){
            Test.startTest();
            EventBus.publish(sharingRecordEvent);
            Test.stopTest();

            List<genesis__Applications__Share> appShareList = [SELECT Id, 
                                                                    ParentId 
                                                                    FROM genesis__Applications__Share 
                                                                    WHERE ParentId = :applicationObj.Id];
            System.assertEquals(0, appShareList.Size(), 'Failed');
        }
    }

    @isTest
    static void testSharingRecordsWithoutIds() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id, Name, Dealer_Name__c FROM genesis__Applications__c LIMIT 1];
        Sharing_Record__e sharingRecordEvent = new Sharing_Record__e();
        System.runAs(userObj){
            Test.startTest();
            EventBus.publish(sharingRecordEvent);
            Test.stopTest();
            
            List<genesis__Applications__Share> appShareList = [SELECT Id, 
                                                                    ParentId 
                                                                    FROM genesis__Applications__Share 
                                                                    WHERE ParentId = :applicationObj.Id];
            System.assertEquals(0, appShareList.Size(), 'Failed');
        }
    }

    @isTest
    static void testSharingRecordsWithoutDocCategory() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id, Name, Dealer_Name__c FROM genesis__Applications__c LIMIT 1];
        Account accountObj = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
        clcommon__Document_Category__c docCategoryList = [SELECT Id
                                                                FROM clcommon__Document_Category__c 
                                                                WHERE genesis__Application__c = :applicationObj.Id];
        Database.delete(docCategoryList,true);
        Sharing_Record__e sharingRecordEvent = new Sharing_Record__e();
        sharingRecordEvent.ApplicationId__c = applicationObj.Id;
        sharingRecordEvent.UserAccountId__c = accountObj.Id;
        System.runAs(userObj){
            Test.startTest();
            EventBus.publish(sharingRecordEvent);
            Test.stopTest();
            List<clcommon__Document_Category__Share> docCategoryShareList = [SELECT Id
                                                                                    FROM clcommon__Document_Category__Share];
            System.assertEquals(0, docCategoryShareList.Size(), 'Failed');
        }
    }

    @isTest
    static void testWithoutDealerRelations() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id, Name, Dealer_Name__c FROM genesis__Applications__c LIMIT 1];
        Account accountObj = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];

        List<clcommon__Relationship__c> dealerRelationsList = [SELECT Id, 
                                                                clcommon__Entity__c,
                                                                clcommon__Related_Entity__c, 
                                                                clcommon__Relationship__r.Name
                                                        FROM clcommon__Relationship__c
                                                        WHERE clcommon__Entity__c = :applicationObj.Dealer_Name__c
                                                        AND clcommon__Relationship__r.Name IN (
                                                                :PortalConstants.CERTIFIED_LENDER, 
                                                                :PortalConstants.CERTIFIED_LENDER_PLUS,
                                                                :PortalConstants.INQUIRY,
                                                                :PortalConstants.INQUIRY_PLUS,
                                                                :PortalConstants.FIELD_STAFF_AGENT
                                                            )];
        Database.delete(dealerRelationsList,true);
        Sharing_Record__e sharingRecordEvent = new Sharing_Record__e();
        sharingRecordEvent.ApplicationId__c = applicationObj.Id;
        sharingRecordEvent.UserAccountId__c = accountObj.Id;

        System.runAs(userObj){
            Test.startTest();
            EventBus.publish(sharingRecordEvent);
            Test.stopTest();
            List<genesis__Applications__Share> appShareList = [SELECT Id, 
                                                                    ParentId 
                                                                    FROM genesis__Applications__Share 
                                                                    WHERE ParentId = :applicationObj.Id];
            System.assertEquals(0, appShareList.Size(), 'Failed');
        }
    }

    @isTest
    static void testWithoutDealer() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id, Name, Dealer_Name__c FROM genesis__Applications__c LIMIT 1];
        applicationObj.Dealer_Name__c = null;
        Database.update(applicationObj,true);
        Account accountObj = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
        Sharing_Record__e sharingRecordEvent = new Sharing_Record__e();
        sharingRecordEvent.ApplicationId__c = applicationObj.Id;
        sharingRecordEvent.UserAccountId__c = accountObj.Id;

        System.runAs(userObj){
            Test.startTest();
            EventBus.publish(sharingRecordEvent);
            Test.stopTest();
            List<genesis__Applications__Share> appShareList = [SELECT Id, 
                                                                    ParentId 
                                                                    FROM genesis__Applications__Share 
                                                                    WHERE ParentId = :applicationObj.Id];
            System.assertEquals(0, appShareList.Size(), 'Failed');
        }
    }
}