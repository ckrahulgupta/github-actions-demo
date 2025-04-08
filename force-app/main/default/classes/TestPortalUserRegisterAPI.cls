/**
 * @description       : 
 * @author            : Bijay Shaw
 * @group             : 
 * @last modified on  : 14-02-2025
 * @last modified by  : Soumik Pattanayak
**/
@isTest
private without sharing class TestPortalUserRegisterAPI {
    @testSetup 
    static void makeData() {
        genesis__Business_Information__c businessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoObj,true);
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoObj.id);
        dealerAccountObj.CIF_Number__c = '102555';
        dealerAccountObj.Enable_ERP_Id__c = true;
        Database.insert(dealerAccountObj,true);
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);
        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(legalEntityObj,true);

        // create borrower Account and contact
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.ParentId = dealerAccountObj.Id;
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId();
        borrowerAccountObj.CIF_Number__c = '123456';
        Database.insert(borrowerAccountObj,true);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        borrowerContactObj.genesis__SSN__c = '324242424';
        borrowerContactObj.Confirm_SSN__c = '324242424';
        Database.insert(borrowerContactObj,true);
        CFA_Configuration__c latestCIF = TestClassHelper.createCIFNumber();
        latestCIF.CIF_Number__c='324543';
        Database.Insert(latestCIF,true);
        //create another borrower Account , contact and their user
        Account secBorrowerAccObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        secBorrowerAccObj.ParentId = dealerAccountObj.Id;
        secBorrowerAccObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId();
        secBorrowerAccObj.CIF_Number__c = '654321';
        Database.insert(secBorrowerAccObj,true);
        Contact secBorrowerContObj = ApplicationOriginationTestHelper.createBorrowerContact(secBorrowerAccObj.id);
        secBorrowerContObj.genesis__SSN__c = '987654321';
        secBorrowerContObj.Confirm_SSN__c = '987654321';
        secBorrowerContObj.Email = 'minsar12@yopmail.com';
        Database.insert(secBorrowerContObj,true);
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(secBorrowerContObj.Id);
        Database.insert(borrowerUserObj, true);
        //create cl account, contact and user
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInfoObj.id,dealerAccountObj.id);
        Database.insert(clAccountObj,true);
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
        Database.insert(clContactObj,true);
        User userObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.id);
        Database.insert(userObj,true);
    }
    /**
    * @description Success scenario for new grower registration
    * @author Ravi Ranjan | 04-04-2024 
    **/
    @isTest
    private static void testNewGrowerSoleProp(){
        Map<String,Object> requestMap = new Map<String,Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        requestMap.put('firstName','Test');
        requestMap.put('lastName','Application');
        requestMap.put('phone','342134234');
        requestMap.put('ssn','GHFB6966');
        requestMap.put('email','testapplication222@gmail.com');
        requestMap.put('confirmEmail','testapplication222@gmail.com');
        System.runAs(userObj){
          Test.startTest();
          PortalUserRegisterAPI saveApi = new PortalUserRegisterAPI();
          clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
          Test.stopTest();
          System.assertEquals(clcommon.constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description check exception with null email and ssn of new grower
    * @author Ravi Ranjan | 04-04-2024 
    **/
    @isTest
    private static void testExceptionWithNullEmailAndSsn(){
      Map<String,Object> requestMap = new Map<String,Object>();
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      requestMap.put('firstName', 'Tom');
      requestMap.put('lastName','Latham');
      requestMap.put('phone','342134234');
      requestMap.put('ssn',null);
      requestMap.put('email',null);
      requestMap.put('confirmEmail',null);
      System.runAs(userObj){
        Test.startTest();
        PortalUserRegisterAPI saveApi = new PortalUserRegisterAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
      }
      
    }
    /**
    * @description Success scenario for existing grower without User
    * @author Ravi Ranjan | 04-04-2024 
    **/
    @isTest 
    private static void testExistingGrowerWithoutUser(){
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      List<Contact> contactList = [SELECT id,
                                  FirstName,
                                  LastName,
                                  MobilePhone,
                                  Email,
                                  genesis__SSN__c 
                            FROM Contact
                            WHERE Email = 'jasmin.albin@yopmail.com'
                            LIMIT 1];
      Map<String,Object> requestMap = new Map<String,Object>();
      requestMap.put('firstName', contactList[0].FirstName);
      requestMap.put('lastName',contactList[0].LastName);
      requestMap.put('phone',contactList[0].MobilePhone);
      requestMap.put('ssn',contactList[0].genesis__SSN__c);
      requestMap.put('email',contactList[0].Email);
      requestMap.put('confirmEmail',contactList[0].Email);
      System.runAs(userObj){
        Test.startTest();
        PortalUserRegisterAPI saveApi = new PortalUserRegisterAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
      }
    }
    /**
    * @description Exception scenario for existing grower ssn and non existing email. 
    * @author Ravi Ranjan | 04-04-2024 
    **/
    @isTest 
    private static void testExistingGrowerWithoutExistingEmail(){
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      List<Contact> contactList = [SELECT id,
                                  FirstName,
                                  LastName,
                                  MobilePhone,
                                  Email,
                                  genesis__SSN__c 
                            FROM Contact
                            WHERE Email = 'jasmin.albin@yopmail.com'
                            LIMIT 1];
      Map<String,Object> requestMap = new Map<String,Object>();
      requestMap.put('firstName', contactList[0].FirstName);
      requestMap.put('lastName',contactList[0].LastName);
      requestMap.put('phone',contactList[0].MobilePhone);
      requestMap.put('ssn',contactList[0].genesis__SSN__c);
      requestMap.put('email','vivianrichard@yopmail.com');
      requestMap.put('confirmEmail','vivianrichard@yopmail.com');
      System.runAs(userObj){
        Test.startTest();
        PortalUserRegisterAPI saveApi = new PortalUserRegisterAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
      }
      
    }
    /**
    * @description check exception for existing grower's email and non existing ssn
    * @author Ravi Ranjan | 04-04-2024 
    **/
    @isTest 
    private static void testExistingGrowerWithoutExistingSsn(){
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      List<Contact> contactList = [SELECT id,
                                  FirstName,
                                  LastName,
                                  MobilePhone,
                                  Email,
                                  genesis__SSN__c 
                            FROM Contact
                            WHERE Email = 'jasmin.albin@yopmail.com'
                            LIMIT 1];
      Map<String,Object> requestMap = new Map<String,Object>();
      requestMap.put('firstName', contactList[0].FirstName);
      requestMap.put('lastName',contactList[0].LastName);
      requestMap.put('phone',contactList[0].MobilePhone);
      requestMap.put('ssn','947847567');
      requestMap.put('email',contactList[0].Email);
      requestMap.put('confirmEmail',contactList[0].Email);
      System.runAs(userObj){
        Test.startTest();
        PortalUserRegisterAPI saveApi = new PortalUserRegisterAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
      }
      
    }
    /**
    * @description scenario for existing grower Having user
    * @author Ravi Ranjan | 04-04-2024 
    **/
    @isTest 
    private static void testForExistingGrowerHavingUser(){
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      List<Contact> contactList = [SELECT id,
                                  FirstName,
                                  LastName,
                                  MobilePhone,
                                  Email,
                                  genesis__SSN__c 
                            FROM Contact
                            WHERE genesis__SSN__c = '987654321'];
      Map<String,Object> requestMap = new Map<String,Object>();
      requestMap.put('firstName', contactList[0].FirstName);
      requestMap.put('lastName',contactList[0].LastName);
      requestMap.put('phone',contactList[0].MobilePhone);
      requestMap.put('ssn',contactList[0].genesis__SSN__c);
      requestMap.put('email',contactList[0].Email);
      requestMap.put('confirmEmail',contactList[0].Email);
      System.runAs(userObj){
        Test.startTest();
        PortalUserRegisterAPI saveApi = new PortalUserRegisterAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
      }
      
    }
    /**
    * @description scenario for existing grower Having user of growmark profile
    * @author Ravi Ranjan | 04-04-2024 
    **/
    @isTest 
    private static void testForExistingGrowerGrowmarkProfile(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Contact> contactList = [SELECT id,
                                    FirstName,
                                    LastName,
                                    MobilePhone,
                                    Email,
                                    genesis__SSN__c 
                              FROM Contact
                              WHERE genesis__SSN__c = '987654321'];
        List<Profile> borrowerProfileList = [SELECT Id,
                                              Name
                                      FROM Profile
                                      WHERE Name = :PortalConstants.GMK_GROWER_PROFILE];
        List<User> borrowerUserList = [SELECT Id,
                                      ProfileId
                                FROM User
                                WHERE Username = 'star.lord@yopmail.com'];
        borrowerUserList[0].ProfileId = borrowerProfileList[0].Id;
        Database.update(borrowerUserList, true);
        Map<String,Object> requestMap = new Map<String,Object>();
        requestMap.put('firstName', contactList[0].FirstName);
        requestMap.put('lastName',contactList[0].LastName);
        requestMap.put('phone',contactList[0].MobilePhone);
        requestMap.put('ssn',contactList[0].genesis__SSN__c);
        requestMap.put('email',contactList[0].Email);
        requestMap.put('confirmEmail',contactList[0].Email);
        System.runAs(userObj){
          Test.startTest();
          PortalUserRegisterAPI saveApi = new PortalUserRegisterAPI();
          clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
          Test.stopTest();
          System.assertEquals(clcommon.constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
      
    }
    /**
    * @description check for new user having growmark profile
    * @author Ravi Ranjan | 04-04-2024 
    **/
    @isTest
    private static void testNewGrowmarkProfileGrowerSoleProp(){
        Map<String,Object> requestMap = new Map<String,Object>();
        List<Profile> borrowerProfileList = [SELECT Id,
                                              Name
                                      FROM Profile
                                      WHERE Name = :PortalConstants.GMK_GROWER_PROFILE];
                
        List<User> userList = [SELECT Id,
                              ProfileId
                        FROM User
                        WHERE UserName = 'star.lord@yopmail.com'];
        userList[0].ProfileId = borrowerProfileList[0].Id;
        Database.update(userList, true);
        requestMap.put('firstName','Test');
        requestMap.put('lastName','Application');
        requestMap.put('phone','342134234');
        requestMap.put('ssn','GHFB6966');
        requestMap.put('email','testapplication222@gmail.com');
        requestMap.put('confirmEmail','testapplication222@gmail.com');
        System.runAs(userList[0]){
          Test.startTest();
          PortalUserRegisterAPI saveApi = new PortalUserRegisterAPI();
          clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
          Test.stopTest();
          System.assertEquals(clcommon.constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
      
    }

    /**
    * @description check exception when grower don't have Individual(s) - Sole Proprietorship legal entity
    * @author Ravi Ranjan | 04-04-2024 
    **/
    @isTest
    private static void testNewGrowerWithoutLegalEntity(){
        Map<String,Object> requestMap = new Map<String,Object>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id,
                                                          clcommon__Legal_Entity_Type__c
                                                    FROM clcommon__Legal_Entity__c
                                                    WHERE Name = :PortalConstants.SOLE_PROP_ENTITY];
        Database.delete(legalEntityList[0], true);
        requestMap.put('firstName','Test');
        requestMap.put('lastName','Application');
        requestMap.put('phone','342134234');
        requestMap.put('ssn','GHFB6966');
        requestMap.put('email','testapplication222@gmail.com');
        requestMap.put('confirmEmail','testapplication222@gmail.com');
        System.runAs(userObj){
            Test.startTest();
            PortalUserRegisterAPI saveApi = new PortalUserRegisterAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
      
    }

    /**
    * @description check exception for null request body
    * @author Soumik Pattanayak | 08-01-2025 
    **/
    @isTest
    private static void testPortalUserRegisterAPINullRequestParam(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        System.runAs(userObj){
            Test.startTest();
            PortalUserRegisterAPI saveApi = new PortalUserRegisterAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), null);
            Test.stopTest();
            System.assertEquals(clcommon.constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        } 
    } 
}