/**
 * @description       : 
 * @author            : Ayan Bhowmik
 * @group             : 
 * @last modified on  : 04-12-2024
 * @last modified by  : Ayan Bhowmik
**/
@isTest
public with sharing class CreateDealerContactUserQueueableTest {
    @TestSetup
    static void makeData(){

        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj,true);

        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.id);
        dealerAccountObj.Enable_ERP_Id__c = true;
        Database.insert(dealerAccountObj,true);

        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Database.insert(clAccountObj,true);

        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
        Database.insert(clContactObj,true);

        Account clPlusAccountObj = ApplicationOriginationTestHelper.createCLPlusAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Database.insert(clPlusAccountObj,true);

        Contact clPlusContactObj = ApplicationOriginationTestHelper.createCLPlusContact(clPlusAccountObj.id);
        Database.insert(clPlusContactObj,true);

        Account iqAccountObj = ApplicationOriginationTestHelper.createInquiryAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Database.insert(iqAccountObj,true);

        Contact iqContactObj = ApplicationOriginationTestHelper.createInquiryContact(iqAccountObj.id);
        Database.insert(iqContactObj,true);

        Account iqPlusAccountObj = ApplicationOriginationTestHelper.createInquiryPlusAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Database.insert(iqPlusAccountObj,true);

        Contact iqPlusContactObj = ApplicationOriginationTestHelper.createInquiryPlusContact(iqPlusAccountObj.id);
        Database.insert(iqPlusContactObj,true);

        Account saAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Database.insert(saAccountObj,true);

        Contact saContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(saAccountObj.id);
        Database.insert(saContactObj,true);
    }

    /**
    * @description Creating CL User
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createCLUser(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Ross Geller'];
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.CERTIFIED_LENDER},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating CL Plus User
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createCLPlusUser(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Peter Geller'
                                                    LIMIT 1];
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.CERTIFIED_LENDER_PLUS},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating CL SA User
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createSAUser(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.SALES_AGENT},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating SA Plus User
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createSAPlusUser(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.SALES_AGENT).getRecordTypeId();
        Database.update(dealerContactAccountList, true);
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.SALES_AGENT_PLUS},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating SA Admin User
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createSAAUser(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.SALES_AGENT_ADMIN).getRecordTypeId();
        Database.update(dealerContactAccountList, true);
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.SALES_AGENT_ADMIN},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating Inquiry User
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createInqUser(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.INQUIRY).getRecordTypeId();
        Database.update(dealerContactAccountList, true);
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.INQUIRY},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating Inquiry Plus User
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createInqPlusUser(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.INQUIRY_PLUS).getRecordTypeId();
        Database.update(dealerContactAccountList, true);
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.INQUIRY_PLUS},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating FSA User For Growmark
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createFSAUserForGrowmark(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.FIELD_STAFF_AGENT).getRecordTypeId();
        dealerContactAccountList[0].Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
        Database.update(dealerContactAccountList, true);
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.FIELD_STAFF_AGENT},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating PA User For Growmark
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createPAUser(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.PAYMENT_ADMINISTRATOR).getRecordTypeId();
        Database.update(dealerContactAccountList, true);
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.PAYMENT_ADMINISTRATOR},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating AgriBusiness User 
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createAgriBusinessUser(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.AGRIBUSINESS).getRecordTypeId();
        Database.update(dealerContactAccountList, true);
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.AGRIBUSINESS},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating AgriBusiness User For Growmark
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createAgriBusinessUserForGrowmark(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.AGRIBUSINESS).getRecordTypeId();
        dealerContactAccountList[0].Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
        Database.update(dealerContactAccountList, true);
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.AGRIBUSINESS},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating PA User For Growmark
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createPAUserForGrowmark(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.PAYMENT_ADMINISTRATOR).getRecordTypeId();
        dealerContactAccountList[0].Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
        Database.update(dealerContactAccountList, true);
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.PAYMENT_ADMINISTRATOR},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating CL User For Growmark
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createCLUserForGrowmark(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.CERTIFIED_LENDER).getRecordTypeId();
        dealerContactAccountList[0].Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
        Database.update(dealerContactAccountList, true);
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.CERTIFIED_LENDER},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating CL Plus User For Growmark
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createCLPlusUserForGrowmark(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.CERTIFIED_LENDER_PLUS).getRecordTypeId();
        dealerContactAccountList[0].Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
        Database.update(dealerContactAccountList, true);
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.CERTIFIED_LENDER_PLUS},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating SA User For Growmark
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createSAUserForGrowmark(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.SALES_AGENT).getRecordTypeId();
        dealerContactAccountList[0].Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
        Database.update(dealerContactAccountList, true);
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.SALES_AGENT},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating SA Plus User For Growmark
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createSAPlusUserForGrowmark(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.SALES_AGENT_PLUS).getRecordTypeId();
        dealerContactAccountList[0].Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
        Database.update(dealerContactAccountList, true);
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.SALES_AGENT_PLUS},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating SA Admin User For Growmark
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createSAAUserForGrowmark(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.SALES_AGENT_ADMIN).getRecordTypeId();
        dealerContactAccountList[0].Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
        Database.update(dealerContactAccountList, true);
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.SALES_AGENT_ADMIN},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating Inquiry User For Growmark
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createInquiryUserForGrowmark(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.INQUIRY).getRecordTypeId();
        dealerContactAccountList[0].Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
        Database.update(dealerContactAccountList, true);
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.INQUIRY},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating Inquiry Plus User For Growmark
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createInquiryPlusUserForGrowmark(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.INQUIRY_PLUS).getRecordTypeId();
        dealerContactAccountList[0].Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
        Database.update(dealerContactAccountList, true);
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.INQUIRY_PLUS},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(1, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Giving new list of contact without any data
    * @author Ayan Bhowmik | 04-12-2024 
    **/
    @isTest
    private static void contactFetchError(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.PAYMENT_ADMINISTRATOR).getRecordTypeId();
        dealerContactAccountList[0].Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
        Database.update(dealerContactAccountList, true);
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.PAYMENT_ADMINISTRATOR},
                                                                        ConstantValues.DEALER_CONTACT_LIST => new List<Contact>()};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(0, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Giving null parameters
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void nullParameterError(){
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => null,
                                                                        ConstantValues.DEALER_ID => null,
                                                                        ConstantValues.RECORD_TYPE_NAME => null,
                                                                        ConstantValues.DEALER_CONTACT_LIST => null};
        User clUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(clUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(0, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating FSA User for CFA
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createFSAUserException(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.FIELD_STAFF_AGENT).getRecordTypeId();
        dealerContactAccountList[0].Coop_Type__c = ConstantValues.CFA_COOP_TYPE;
        Database.update(dealerContactAccountList, true);
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];

        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.FIELD_STAFF_AGENT},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(0, userList.size(), 'User Creation Failed');
        }
    }
    /**
    * @description Creating Non Permissioned User
    * @author Ayan Bhowmik | 04-10-2024 
    **/
    @isTest
    private static void createNonPermissionedUserException(){
        List<Account> dealerAccountList = [SELECT Id
                                            FROM Account
                                            WHERE Name = 'Kisan Loan'
                                            LIMIT 1];
        List<Account> dealerContactAccountList = [SELECT Id
                                                    FROM Account
                                                    WHERE Name = 'Tony Stark'
                                                    LIMIT 1];
        dealerContactAccountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ConstantValues.AUTHORIZED_PERSON).getRecordTypeId();
        dealerContactAccountList[0].Coop_Type__c = 'CFA';
        Database.update(dealerContactAccountList, true);
        List<Contact> dealerContactList = [SELECT Id,
                                                FirstName,
                                                LastName,
                                                Email,
                                                Account.RecordType.Name,
                                                Account.Coop_Type__c
                                            FROM Contact
                                            WHERE AccountId =: dealerContactAccountList[0].Id];

        Map<String, Object> recordDetailsMap = new Map<String, Object>{ConstantValues.DEALER_CONTACT_ID => dealerContactAccountList[0].Id,
                                                                        ConstantValues.DEALER_ID => dealerAccountList[0].Id,
                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{ConstantValues.AUTHORIZED_PERSON},
                                                                        ConstantValues.DEALER_CONTACT_LIST => dealerContactList};
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];

        System.runAs(adminUserObj){
            Test.startTest();
            System.enqueueJob(new CreateDealerContactUserQueueable(recordDetailsMap));
            Test.stopTest();
            List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId =: dealerContactAccountList[0].Id];
            System.assertEquals(0, userList.size(), 'User Creation Failed');
        }
    }
}