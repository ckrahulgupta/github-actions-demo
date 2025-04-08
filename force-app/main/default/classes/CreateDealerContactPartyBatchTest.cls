/**
 * @description       : Test class for CreateDealerContactPartyBatch
 * @author            : Simran
 * @group             : 
 * @last modified on  : 07-03-2024
 * @last modified by  : Suraj Kumar
**/
@isTest
public with sharing class CreateDealerContactPartyBatchTest {

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
        
        // Creating Account for GmkDealer
        Account gmkDealerAccountObj = TestClassHelper.createGMKDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(gmkDealerAccountObj, true);

        // creating Account for Gmk Certified Lender
        Account gmkClAccountObj = ApplicationOriginationTestHelper.createDealerContactRecord(gmkDealerAccountObj.Id,'Certified Lender');
        Database.insert(gmkClAccountObj, true);

        // Creating Account for Landus Dealer
        Account landusDealerAccountObj = TestClassHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        landusDealerAccountObj.Coop_Type__c = 'Landus';
        Database.insert(landusDealerAccountObj, true);

        // creating Account for Landus Certified Lender
        Account landusClAccountObj = ApplicationOriginationTestHelper.createDealerContactRecord(landusDealerAccountObj.Id,'Certified Lender');
        Database.insert(landusClAccountObj, true);

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
                                                                                                    gmkDealerAccountObj.Id, 
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

        // creating application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>();
        paramForApplicationMap.put('dealerAccountId', dealerAccountObj.Id);
        paramForApplicationMap.put('borrowerAccountId', null);
        paramForApplicationMap.put('borrowerContactId', null);
        paramForApplicationMap.put('clAccountId', clAccountObj.Id);
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        Database.insert(applicationObj, true);


        // creating gmk application
        Map<String,Id> paramForGmkAppMap = new Map<String,Id>{
            'dealerAccountId' => gmkDealerAccountObj.Id,
            'borrowerAccountId' => null,
            'borrowerContactId' => null,
            'clAccountId' => gmkClAccountObj.Id
        };
        genesis__Applications__c gmkApplicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForGmkAppMap);
        Database.insert(gmkApplicationObj, true);

        // creating Landus application
        Map<String,Id> paramForLandusAppMap = new Map<String,Id>{
            'dealerAccountId' => landusDealerAccountObj.Id,
            'borrowerAccountId' => null,
            'borrowerContactId' => null,
            'clAccountId' => landusClAccountObj.Id
        };
        genesis__Applications__c landusAppObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForLandusAppMap);
        Database.insert(landusAppObj, true);

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

         genesis__Applications__c blankApplicationObj= ApplicationOriginationTestHelper.createBlankApplicationRecord();
         Database.insert(blankApplicationObj,true);

        clcommon__Document_Category__c docCategoryObj = ApplicationOriginationTestHelper.createDocCategory(applicationObj.Id,'Driving license');
        Database.insert(docCategoryObj, true);
    }
    
    //cl party successfully linked with the application for CFA/Landus Coop type.
    @IsTest
    public static void clRecordType() {
        Account dealerAccount=[SELECT Id,Phone FROM  Account WHERE Phone = '1234567890' LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c
                                                    WHERE Dealer_Name__c = :dealerAccount.Id LIMIT 1];
        List<Id> paAccountIdList = new List<Id>();                                      
        Account paAccountObj = [SELECT Id ,
                                        RecordType.Name,
                                        ParentId
                                    FROM Account 
                                    WHERE RecordType.Name = 'Certified Lender' LIMIT 1];
        paAccountIdList.add(paAccountObj.Id);
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(objAdmin){
        Test.startTest();
        CreateDealerContactPartyBatch.createPartyForSpecificDealer(paAccountIdList);
        Test.stopTest();
        }
        List<clcommon__Party__c> partyObj = [SELECT Id
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c = :applicationObj.Id 
                                                AND clcommon__Account__r.RecordType.Name = 'Certified Lender' LIMIT 1];
        System.assertEquals(1, partyObj.size(), 'Success');
    }


    //No dealer's contact linked with the application for CFA/Landus Coop type.
    @IsTest
    public static void clRecordTypeInBlankApp() {
        genesis__Applications__c applicationObj = [SELECT Id,Dealer_Name__c
                                                    FROM genesis__Applications__c
                                                    WHERE genesis__Status__c = 'New Entered' LIMIT 1]; 
        List<Id> paAccountIdList = new List<Id>();                                      
        Account paAccountObj = [SELECT Id ,
                                        RecordType.Name,
                                        ParentId
                                    FROM Account 
                                    WHERE RecordType.Name = 'Certified Lender' LIMIT 1];
        paAccountIdList.add(paAccountObj.Id);
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(objAdmin){
        Test.startTest();
        CreateDealerContactPartyBatch.createPartyForSpecificDealer(paAccountIdList);
        Test.stopTest();
        }
        List<clcommon__Party__c> partyObj = [SELECT Id
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c = :applicationObj.Id 
                                                AND clcommon__Account__r.RecordType.Name = 'Certified Lender' LIMIT 1];
        System.assertEquals(0, partyObj.size(), 'Success');
    }

    //user access check
    @IsTest
    public static void checkUserAccess() {
        Account dealerAccount=[SELECT Id,Phone FROM  Account WHERE Coop_Type__c='CFA'];
        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c
                                                    WHERE Dealer_Name__c = :dealerAccount.Id LIMIT 1];
        List<Id> paAccountIdList = new List<Id>();                                      
        Account paAccountObj = [SELECT Id ,
                                        RecordType.Name,
                                        ParentId
                                    FROM Account 
                                    WHERE RecordType.Name = 'Certified Lender' LIMIT 1];
        paAccountIdList.add(paAccountObj.Id);
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'CFA Admin User' AND isActive = true LIMIT 1];
        System.runAs(objAdmin){
        Test.startTest();
        CreateDealerContactPartyBatch.createPartyForSpecificDealer(paAccountIdList);
        Test.stopTest();
        }
        List<clcommon__Party__c> partyObj = [SELECT Id
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c = :applicationObj.Id 
                                                AND clcommon__Account__r.RecordType.Name = 'Certified Lender' LIMIT 1];
        System.assertEquals(1, partyObj.size(), 'Success');
    }

   /**
    * @description : Adding FSA for CFA
    * @author Suraj Kumar | 07-02-2024 
    **/

    @IsTest
    public static void fsaRecordTypeCFA() {
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                    Dealer_Name__c
                                                                FROM genesis__Applications__c
                                                                WHERE Dealer_Name__r.Coop_Type__c = 'CFA'];  
        List<Id> paAccountIdList = new List<Id>();                                      
        Account paAccountObj = [SELECT Id ,
                                       RecordTypeId,
                                        RecordType.Name,
                                        ParentId
                                    FROM Account 
                                    WHERE RecordType.Name = 'Field Staff Agent' LIMIT 1];
        paAccountIdList.add(paAccountObj.Id);
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(objAdmin){
        Test.startTest();
        CreateDealerContactPartyBatch.createPartyForSpecificDealer(paAccountIdList);
        Test.stopTest();
        }
        List<clcommon__Party__c> partyList = [SELECT Id, genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Account__r.RecordType.Name = 'Field Staff Agent'
                                                AND genesis__Application__r.Dealer_Name__r.Coop_Type__c = 'CFA'];
        System.assertEquals(applicationList.size(), partyList.size(), 'Assertion Failed');
    }

    
    /**
    * @description : Adding FSA for Gmk
    * @author Suraj Kumar | 07-02-2024 
    **/
    @IsTest
    public static void fsaRecordTypeGmk() {
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                    Dealer_Name__c
                                                                FROM genesis__Applications__c
                                                                WHERE Dealer_Name__r.Coop_Type__c = 'Growmark'];  
        List<Id> paAccountIdList = new List<Id>();                                      
        Account paAccountObj = [SELECT Id ,
                                       RecordTypeId,
                                        RecordType.Name,
                                        ParentId
                                    FROM Account 
                                    WHERE RecordType.Name = 'Field Staff Agent' LIMIT 1];
        paAccountIdList.add(paAccountObj.Id);
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(objAdmin){
        Test.startTest();
        CreateDealerContactPartyBatch.createPartyForSpecificDealer(paAccountIdList);
        Test.stopTest();
        }
        List<clcommon__Party__c> partyList = [SELECT Id, genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Account__r.RecordType.Name = 'Field Staff Agent'];
        System.assertEquals(applicationList.size(), partyList.size(), 'Assertion Failed');
    }

    /**
    * @description : Adding FSA for Landus
    * @author Suraj Kumar | 07-02-2024 
    **/
    @IsTest
    public static void fsaRecordTypeLandus() {
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                    Dealer_Name__c
                                                                FROM genesis__Applications__c
                                                                WHERE Dealer_Name__r.Coop_Type__c = 'Landus'];  
        List<Id> paAccountIdList = new List<Id>();                                      
        Account paAccountObj = [SELECT Id ,
                                       RecordTypeId,
                                        RecordType.Name,
                                        ParentId
                                    FROM Account 
                                    WHERE RecordType.Name = 'Field Staff Agent' LIMIT 1];
        paAccountIdList.add(paAccountObj.Id);
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(objAdmin){
        Test.startTest();
        CreateDealerContactPartyBatch.createPartyForSpecificDealer(paAccountIdList);
        Test.stopTest();
        }
        List<clcommon__Party__c> partyList = [SELECT Id, genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Account__r.RecordType.Name = 'Field Staff Agent'];
        System.assertEquals(applicationList.size(), partyList.size(), 'Assertion Failed');
    }

    
    /**
    * @description : Testing for Blank application,  no dealer linked with this application.
    * @author Suraj Kumar | 07-03-2024 
    **/
    @IsTest
    public static void fsaRecordTypeInBlankApp() {
        genesis__Applications__c applicationObj = [SELECT Id,Dealer_Name__c
                                                    FROM genesis__Applications__c
                                                    WHERE genesis__Status__c = 'New Entered' LIMIT 1]; 
        List<Id> paAccountIdList = new List<Id>();                                      
        Account paAccountObj = [SELECT Id ,
                                        RecordType.Name,
                                        ParentId
                                    FROM Account 
                                    WHERE RecordType.Name = 'Field Staff Agent' LIMIT 1];
        paAccountIdList.add(paAccountObj.Id);
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(objAdmin){
        Test.startTest();
        CreateDealerContactPartyBatch.createPartyForSpecificDealer(paAccountIdList);
        Test.stopTest();
        }
        List<clcommon__Party__c> partyObj = [SELECT Id
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c = :applicationObj.Id 
                                                AND clcommon__Account__r.RecordType.Name = 'Field Staff Agent' LIMIT 1];
        System.assertEquals(0, partyObj.size(), 'Success');
    }

}