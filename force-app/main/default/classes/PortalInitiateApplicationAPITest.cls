/**
 * @description       : testclass for PortalInitiateApplicationAPI
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 01-11-2025
 * @last modified by  : Rakesh Saraf
**/

@isTest
global without sharing class PortalInitiateApplicationAPITest {
    /**
    * @description - Creating Test Data
    * @author Sk Minsar | 09-24-2024 
    **/
    @testSetup
    static void setup(){
        ApplicationOriginationSetupTestHelper.createTestSetup();
    }

    /**
    * @description this method is used to create a new dealer acc.
    * @author Rakesh Saraf | 01-11-2025 
    * @return Account 
    **/
    private static Account createNewDealer(){
        genesis__Business_Information__c dealerBusinessInfo=ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfo,true);

        Account dealerAccObj=ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfo.id);
        Database.insert(dealerAccObj,true);

        return dealerAccObj;
    }

    /**
    * @description : creating a sole prop application
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testSolePropAppNewApplicant() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> requestMap = new Map<String, Object>();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                             FROM clcommon__Legal_Entity__c 
                                                             WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'];

        Map<String,Object> applicationMap=new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000

        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'Birthdate'=>'1966-01-31',
            'genesis__SSN__c'=>'324242424',
            'Confirm_SSN__c'=>'324242424',
            'MobilePhone'=>'4342343432',
            'Mailing_County__c'=>'West Bengal',
            'MailingPostalCode'=>'70011',
            'MailingState'=>'AL',
            'MailingCity'=>'Kolkata',
            'MailingStreet'=>'S.S. Temple Road',
            'LastName'=>'Sharma',
            'FirstName'=>'Abhishake'
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));

        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : creating a corporation application
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testCorporationAppNewApplicant() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> requestMap = new Map<String, Object>();
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE clcommon__Legal_Entity_Type__c = 'Corporation'];

        Map<String,Object> applicationMap=new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id,
            'Is_Individual__c'=>false,
            'Name'=>'TestAccount12345'
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000,
            'genesis__Tax_Identification_Number__c'=>'5678765'
        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'Birthdate'=>'1966-01-31',
            'genesis__SSN__c'=>'324242424',
            'Confirm_SSN__c'=>'324242424',
            'MobilePhone'=>'4342343432',
            'Mailing_County__c'=>'West Bengal',
            'MailingPostalCode'=>'70011',
            'MailingState'=>'AL',
            'MailingCity'=>'Kolkata',
            'MailingStreet'=>'S.S. Temple Road',
            'LastName'=>'Sharma',
            'FirstName'=>'Abhishake'
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));
        
        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    } 

    /**
    * @description : creating a new dba application
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testDBAAppNewApplicant() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> requestMap = new Map<String, Object>();
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id 
                                                            FROM clcommon__Legal_Entity__c 
                                                            WHERE clcommon__Legal_Entity_Type__c = : PortalConstants.INDIVIDUAL_ENTITY];

        Map<String,Object> applicationMap=new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id,
            'Is_Individual__c'=>false,
            'Name'=>'TestAccount12345'
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000,
            'genesis__Tax_Identification_Number__c'=>'5678765'
        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'Birthdate'=>'1966-01-31',
            'genesis__SSN__c'=>'324242424',
            'Confirm_SSN__c'=>'324242424',
            'MobilePhone'=>'4342343432',
            'Mailing_County__c'=>'West Bengal',
            'MailingPostalCode'=>'70011',
            'MailingState'=>'AL',
            'MailingCity'=>'Kolkata',
            'MailingStreet'=>'S.S. Temple Road',
            'LastName'=>'Sharma',
            'FirstName'=>'Abhishake'
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));
        
        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : creating a corporation application in growmark
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testCorporationAppNewApplicantGMK() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> requestMap = new Map<String, Object>();

        Account dealerAcc = [SELECT Id, Name FROM Account WHERE recordtype.name = 'Dealer'];
        dealerAcc.coop_type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.update(dealerAcc, true);

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE clcommon__Legal_Entity_Type__c = 'Corporation'];

        Map<String,Object> applicationMap=new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id,
            'Is_Individual__c'=>false,
            'Name'=>'TestAccount12345'
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000,
            'genesis__Tax_Identification_Number__c'=>'5678765'
        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'Birthdate'=>'1966-01-31',
            'genesis__SSN__c'=>'324242424',
            'Confirm_SSN__c'=>'324242424',
            'MobilePhone'=>'4342343432',
            'Mailing_County__c'=>'West Bengal',
            'MailingPostalCode'=>'70011',
            'MailingState'=>'AL',
            'MailingCity'=>'Kolkata',
            'MailingStreet'=>'S.S. Temple Road',
            'LastName'=>'Sharma',
            'FirstName'=>'Abhishake'
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));
                      
        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    } 

    /**
    * @description : creating an application for an existing sole prop applicant in same dealer, error because search feature should be used
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testDuplicateSolePropAppInSameDealer() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> requestMap = new Map<String, Object>();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                             FROM clcommon__Legal_Entity__c 
                                                             WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'];

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            genesis__Contact__c
                                                        FROM genesis__Applications__c
                                                        WHERE Internal_Reference_Code__c = 'testApp001'];
       
        List<Contact> borrowerContact = [SELECT Id,
                                                genesis__SSN__c
                                            FROM Contact 
                                            WHERE Id =: applicationList[0].genesis__Contact__c LIMIT 1];


        Map<String,Object> applicationMap=new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000
        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'Birthdate'=>'1966-01-31',
            'genesis__SSN__c'=>borrowerContact[0].genesis__SSN__c,
            'Confirm_SSN__c'=>borrowerContact[0].genesis__SSN__c,
            'MobilePhone'=>'4342343432',
            'Mailing_County__c'=>'West Bengal',
            'MailingPostalCode'=>'70011',
            'MailingState'=>'AL',
            'MailingCity'=>'Kolkata',
            'MailingStreet'=>'S.S. Temple Road',
            'LastName'=>'Sharma',
            'FirstName'=>'Abhishake'
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));
    
        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : creating an application for an existing sole prop applicant in other dealer
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testSolePropExistingApplicantOtherDealer() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> requestMap = new Map<String, Object>();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                             FROM clcommon__Legal_Entity__c 
                                                             WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'];
        Contact contactObj = [SELECT Id, Name, AccountId FROM Contact WHERE genesis__SSN__c = '982763493'];

        List<Account> borrowerAccountList = [SELECT Id,
                                                    ParentId,
                                                    genesis__Business_Information__c 
                                                FROM Account 
                                                WHERE Id =: contactObj.AccountId LIMIT 1];
        
        Account newDealerAcc=createNewDealer();

        borrowerAccountList[0].ParentId=newDealerAcc.id;
        Database.update(borrowerAccountList,true);

        List<Dealer_Applicant_Relationship__c> dealerAppRelList=[SELECT ID, Dealer__c 
                                                                 FROM Dealer_Applicant_Relationship__c 
                                                                 WHERE Applicant__c=:borrowerAccountList[0].id];
        dealerAppRelList[0].Dealer__c=newDealerAcc.id;
        Database.update(dealerAppRelList,true);

        Map<String,Object> applicationMap=new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000
        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'Birthdate'=>'1966-01-31',
            'genesis__SSN__c'=>'324242424',
            'Confirm_SSN__c'=>'324242424',
            'MobilePhone'=>'4342343432',
            'Mailing_County__c'=>'West Bengal',
            'MailingPostalCode'=>'70011',
            'MailingState'=>'AL',
            'MailingCity'=>'Kolkata',
            'MailingStreet'=>'S.S. Temple Road',
            'LastName'=>'Sharma',
            'FirstName'=>'Abhishake'
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));

        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : creating an application for an existing applicant in same dealer (using search grower feature)
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testSolePropExistingApplicant() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> requestMap = new Map<String, Object>();
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id 
                                                            FROM clcommon__Legal_Entity__c 
                                                            WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'];

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            genesis__CL_Product__c,
                                                            genesis__CL_Purpose__c,
                                                            genesis__Account__c,
                                                            genesis__Contact__c,
                                                            ERP_Id__c,
                                                            genesis__Status__c 
                                                        FROM genesis__Applications__c
                                                        WHERE Internal_Reference_Code__c = 'testApp001'];
       
        List<Account> borrowerAccountList = [SELECT Id,
                                                genesis__Business_Information__c 
                                            FROM Account 
                                            WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];


        List<Contact> borrowerContactList = [SELECT Id,
                                                    AccountId
                                                FROM Contact 
                                                WHERE Id =: applicationList[0].genesis__Contact__c LIMIT 1];

       
        List<genesis__Business_Information__c> borrowerBusinessInfoList = [SELECT Id 
                                                                            FROM genesis__Business_Information__c 
                                                                            WHERE id=: borrowerAccountList[0].genesis__Business_Information__c LIMIT 1];
                                                                    
        Map<String,Object> applicationMap=new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id,
            'Id'=>borrowerAccountList[0].Id
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000,
            'Id'=>borrowerBusinessInfoList[0].id
        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'Birthdate'=>'1966-01-31',
            'genesis__SSN__c'=>'324242424',
            'Confirm_SSN__c'=>'324242424',
            'MobilePhone'=>'4342343432',
            'Mailing_County__c'=>'West Bengal',
            'MailingPostalCode'=>'70011',
            'MailingState'=>'AL',
            'MailingCity'=>'Kolkata',
            'MailingStreet'=>'S.S. Temple Road',
            'LastName'=>'Sharma',
            'FirstName'=>'Abhishake',
            'Id'=>borrowerContactList[0].id
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));

        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    } 

    /**
    * @description : creating an application for an existing applicant who is non accrual in same dealer (using search grower feature)
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testSolePropExistingApplicantNonAccrual() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> requestMap = new Map<String, Object>();
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id 
                                                            FROM clcommon__Legal_Entity__c 
                                                            WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'];

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            genesis__CL_Product__c,
                                                            genesis__CL_Purpose__c,
                                                            genesis__Account__c,
                                                            genesis__Contact__c,
                                                            ERP_Id__c,
                                                            genesis__Status__c 
                                                        FROM genesis__Applications__c
                                                        WHERE Internal_Reference_Code__c = 'testApp001'];
       
        List<Account> borrowerAccountList = [SELECT Id,
                                                genesis__Business_Information__c 
                                            FROM Account 
                                            WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountList[0].Non_Accrual__c = true;
        Database.update(borrowerAccountList[0], true);


        List<Contact> borrowerContactList = [SELECT Id ,
                                                    AccountId
                                                FROM Contact 
                                                WHERE Id =: applicationList[0].genesis__Contact__c LIMIT 1];

        borrowerContactList[0].AccountId=borrowerAccountList[0].id;
        Database.update(borrowerContactList,true);

       
        List<genesis__Business_Information__c> borrowerBusinessInfoList = [SELECT Id 
                                                                            FROM genesis__Business_Information__c 
                                                                            WHERE id=: borrowerAccountList[0].genesis__Business_Information__c LIMIT 1];

         List<Dealer_Applicant_Relationship__c> dealerAppRelList=[SELECT ID, Is_Non_Accrual__c 
                                                                 FROM Dealer_Applicant_Relationship__c 
                                                                 WHERE Applicant__c=:borrowerAccountList[0].id];
        dealerAppRelList[0].Is_Non_Accrual__c=true;
        Database.update(dealerAppRelList,true);
                                                                      
        Map<String,Object> applicationMap=new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id,
            'Id'=>borrowerAccountList[0].Id
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000,
            'Id'=>borrowerBusinessInfoList[0].id
        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'Birthdate'=>'1966-01-31',
            'genesis__SSN__c'=>'324242424',
            'Confirm_SSN__c'=>'324242424',
            'MobilePhone'=>'4342343432',
            'Mailing_County__c'=>'West Bengal',
            'MailingPostalCode'=>'70011',
            'MailingState'=>'AL',
            'MailingCity'=>'Kolkata',
            'MailingStreet'=>'S.S. Temple Road',
            'LastName'=>'Sharma',
            'FirstName'=>'Abhishake',
            'Id'=>borrowerContactList[0].id
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));
        
        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    } 

    /**
    * @description : creating an application for an existing applicant who has past due in same dealer (using search grower feature)
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testSolePropExistingApplicantHasPastDue() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> requestMap = new Map<String, Object>();
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id 
                                                            FROM clcommon__Legal_Entity__c 
                                                            WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'];

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            genesis__CL_Product__c,
                                                            genesis__CL_Purpose__c,
                                                            genesis__Account__c,
                                                            genesis__Contact__c,
                                                            ERP_Id__c,
                                                            genesis__Status__c 
                                                        FROM genesis__Applications__c
                                                        WHERE Internal_Reference_Code__c = 'testApp001'];
       
        List<Account> borrowerAccountList = [SELECT Id,
                                                genesis__Business_Information__c 
                                            FROM Account 
                                            WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountList[0].Has_Past_Due__c = true;
        Database.update(borrowerAccountList[0], true);


        List<Contact> borrowerContactList = [SELECT Id ,
                                                    AccountId
                                                FROM Contact 
                                                WHERE Id =: applicationList[0].genesis__Contact__c LIMIT 1];

       
        List<genesis__Business_Information__c> borrowerBusinessInfoList = [SELECT Id 
                                                                            FROM genesis__Business_Information__c 
                                                                            WHERE id=: borrowerAccountList[0].genesis__Business_Information__c LIMIT 1];

        List<Dealer_Applicant_Relationship__c> dealerAppRelList=[SELECT ID,Has_Past_Due__c FROM Dealer_Applicant_Relationship__c WHERE Applicant__c=:borrowerAccountList[0].id];
        dealerAppRelList[0].Has_Past_Due__c=true;
        Database.update(dealerAppRelList,true);
                                                                      
        Map<String,Object> applicationMap=new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id,
            'Id'=>borrowerAccountList[0].Id
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000,
            'Id'=>borrowerBusinessInfoList[0].id
        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'Birthdate'=>'1966-01-31',
            'genesis__SSN__c'=>'324242424',
            'Confirm_SSN__c'=>'324242424',
            'MobilePhone'=>'4342343432',
            'Mailing_County__c'=>'West Bengal',
            'MailingPostalCode'=>'70011',
            'MailingState'=>'AL',
            'MailingCity'=>'Kolkata',
            'MailingStreet'=>'S.S. Temple Road',
            'LastName'=>'Sharma',
            'FirstName'=>'Abhishake',
            'Id'=>borrowerContactList[0].id
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));
        
        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    } 

    /**
    * @description : creating an application for an existing corporation applicant in same dealer (using search grower feature)
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testCorporationExistingApplicant() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> requestMap = new Map<String, Object>();
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE clcommon__Legal_Entity_Type__c = 'Corporation'];

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Account__c,
                                                                genesis__Contact__c,
                                                                genesis__Account__r.genesis__business_information__c
                                                        FROM genesis__Applications__c
                                                        WHERE Internal_Reference_Code__c = 'testApp002'];

        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c 
                                                FROM Account 
                                                WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];

        List<genesis__Business_Information__c> borrowerBusinessInfoList = [SELECT Id 
                                                                            FROM genesis__Business_Information__c 
                                                                            WHERE id=: borrowerAccountList[0].genesis__Business_Information__c LIMIT 1];

        Map<String,Object> applicationMap=new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id,
            'Id'=>borrowerAccountList[0].Id
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000,
            'Id'=>borrowerBusinessInfoList[0].id
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));

        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    } 

    /**
    * @description : creating an application for an existing corporation applicant in other dealer
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testCorpExistingApplicantOtherDealer() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> requestMap = new Map<String, Object>();
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE clcommon__Legal_Entity_Type__c = 'Corporation'];

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Account__c,
                                                                genesis__Contact__c,
                                                                genesis__Account__r.genesis__business_information__c
                                                        FROM genesis__Applications__c
                                                        WHERE Internal_Reference_Code__c = 'testApp002'];

        List<Account> borrowerAccountList = [SELECT Id,
                                                    ParentId,
                                                    genesis__Business_Information__c 
                                                FROM Account 
                                                WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        
        Account newDealerAcc=createNewDealer();

        borrowerAccountList[0].ParentId=newDealerAcc.id;
        Database.update(borrowerAccountList,true);

        List<Dealer_Applicant_Relationship__c> dealerAppRelList=[SELECT ID, Dealer__c 
                                                                 FROM Dealer_Applicant_Relationship__c 
                                                                 WHERE Applicant__c=:borrowerAccountList[0].id];
        dealerAppRelList[0].Dealer__c=newDealerAcc.id;
        Database.update(dealerAppRelList,true);
        
        Map<String,Object> applicationMap=new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id,
            'Is_Individual__c'=>false,
            'Name'=>'TestAccount12345'
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000,
            'genesis__Tax_Identification_Number__c'=>'927483938'
        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'Birthdate'=>'1966-01-31',
            'genesis__SSN__c'=>'324242424',
            'Confirm_SSN__c'=>'324242424',
            'MobilePhone'=>'4342343432',
            'Mailing_County__c'=>'West Bengal',
            'MailingPostalCode'=>'70011',
            'MailingState'=>'AL',
            'MailingCity'=>'Kolkata',
            'MailingStreet'=>'S.S. Temple Road',
            'LastName'=>'Sharma',
            'FirstName'=>'Abhishake'
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));

        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    } 

    /**
    * @description : invalid request body
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testInvalidRequestBody() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> requestMap = new Map<String, Object>();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                             FROM clcommon__Legal_Entity__c 
                                                             WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'];

        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000
        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'Birthdate'=>'1966-01-31',
            'genesis__SSN__c'=>'324242424',
            'Confirm_SSN__c'=>'324242424',
            'MobilePhone'=>'4342343432',
            'Mailing_County__c'=>'West Bengal',
            'MailingPostalCode'=>'70011',
            'MailingState'=>'AL',
            'MailingCity'=>'Kolkata',
            'MailingStreet'=>'S.S. Temple Road',
            'LastName'=>'Sharma',
            'FirstName'=>'Abhishake'
        };

        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));

        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : missing application details
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testNecessaryParamMissing() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> requestMap = new Map<String, Object>();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                             FROM clcommon__Legal_Entity__c 
                                                             WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'];

        
        Map<String,Object> applicationMap=new Map<String,Object>{};

        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000
        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'Birthdate'=>'1966-01-31',
            'genesis__SSN__c'=>'324242424',
            'Confirm_SSN__c'=>'324242424',
            'MobilePhone'=>'4342343432',
            'Mailing_County__c'=>'West Bengal',
            'MailingPostalCode'=>'70011',
            'MailingState'=>'AL',
            'MailingCity'=>'Kolkata',
            'MailingStreet'=>'S.S. Temple Road',
            'LastName'=>'Sharma',
            'FirstName'=>'Abhishake'
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));

        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : creating an application in growmark where logged in user is a sales agent
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testCreateSolePropAppAsSAInGMK() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Tony Stark');

        Account dealerAcc = [SELECT Id, Name FROM Account WHERE recordtype.name = 'Dealer'];
        dealerAcc.coop_type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.update(dealerAcc, true);

        Map<String, Object> requestMap = new Map<String, Object>();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                             FROM clcommon__Legal_Entity__c 
                                                             WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'];


        Map<String,Object> applicationMap=new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000
        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'Birthdate'=>'1966-01-31',
            'genesis__SSN__c'=>'324242424',
            'Confirm_SSN__c'=>'324242424',
            'MobilePhone'=>'4342343432',
            'Mailing_County__c'=>'West Bengal',
            'MailingPostalCode'=>'70011',
            'MailingState'=>'AL',
            'MailingCity'=>'Kolkata',
            'MailingStreet'=>'S.S. Temple Road',
            'LastName'=>'Sharma',
            'FirstName'=>'Abhishake'
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));

        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description : creating an application where logged in user is a sales agent plus
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testCreteAppAsSAPlus() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Tony Stark');
        Account saPlusAcc = [SELECT Id,Name FROM Account WHERE Name = 'Tony Stark'];
        saPlusAcc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sales Agent Plus').getRecordTypeId();
        Database.update(saPlusAcc);

        clcommon__Reciprocal_Role__c saPlusRole = [SELECT Id, Name from clcommon__Reciprocal_Role__c WHERE Name = 'Sales Agent Plus'];

        clcommon__Relationship__c dealerRelationship = [SELECT Id, Name FROM clcommon__Relationship__c WHERE clcommon__Related_Entity__c =: saPlusAcc.Id LIMIT 1];
        dealerRelationship.clcommon__Relationship__c = saPlusRole.Id;
        Database.update(dealerRelationship);
        Map<String, Object> requestMap = new Map<String, Object>();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                             FROM clcommon__Legal_Entity__c 
                                                             WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'];
                              
        Map<String,Object> applicationMap=new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000
        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'Birthdate'=>'1966-01-31',
            'genesis__SSN__c'=>'324242424',
            'Confirm_SSN__c'=>'324242424',
            'MobilePhone'=>'4342343432',
            'Mailing_County__c'=>'West Bengal',
            'MailingPostalCode'=>'70011',
            'MailingState'=>'AL',
            'MailingCity'=>'Kolkata',
            'MailingStreet'=>'S.S. Temple Road',
            'LastName'=>'Sharma',
            'FirstName'=>'Abhishake'
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));

        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description : creating an application where logged in user is a sales agent admin
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testCreteAppAsSAAdmin() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Tony Stark');
        Account saAdminAcc = [SELECT Id,Name FROM Account WHERE Name = 'Tony Stark'];
        saAdminAcc.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sales Agent Admin').getRecordTypeId();
        Database.update(saAdminAcc);

        clcommon__Reciprocal_Role__c saAdminRole = [SELECT Id, Name from clcommon__Reciprocal_Role__c WHERE Name = 'Sales Agent Admin'];

        clcommon__Relationship__c dealerRelationship = [SELECT Id, Name FROM clcommon__Relationship__c WHERE clcommon__Related_Entity__c =: saAdminAcc.Id LIMIT 1];
        dealerRelationship.clcommon__Relationship__c = saAdminRole.Id;
        Database.update(dealerRelationship);
        Map<String, Object> requestMap = new Map<String, Object>();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                             FROM clcommon__Legal_Entity__c 
                                                             WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'];
   
        Map<String,Object> applicationMap=new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000
        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'Birthdate'=>'1966-01-31',
            'genesis__SSN__c'=>'324242424',
            'Confirm_SSN__c'=>'324242424',
            'MobilePhone'=>'4342343432',
            'Mailing_County__c'=>'West Bengal',
            'MailingPostalCode'=>'70011',
            'MailingState'=>'AL',
            'MailingCity'=>'Kolkata',
            'MailingStreet'=>'S.S. Temple Road',
            'LastName'=>'Sharma',
            'FirstName'=>'Abhishake'
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));

        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : creating a sole prop application where legal entity is missing
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testMissingLegalEntity() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> requestMap = new Map<String, Object>();

        Map<String,Object> applicationMap=new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>''
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000
        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'Birthdate'=>'1966-01-31',
            'genesis__SSN__c'=>'324242424',
            'Confirm_SSN__c'=>'324242424',
            'MobilePhone'=>'4342343432',
            'Mailing_County__c'=>'West Bengal',
            'MailingPostalCode'=>'70011',
            'MailingState'=>'AL',
            'MailingCity'=>'Kolkata',
            'MailingStreet'=>'S.S. Temple Road',
            'LastName'=>'Sharma',
            'FirstName'=>'Abhishake'
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));

        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : creating a sole prop application where last name is missing
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testMissingLastName() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> requestMap = new Map<String, Object>();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                             FROM clcommon__Legal_Entity__c 
                                                             WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'];

        Map<String,Object> applicationMap=new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000
        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'Birthdate'=>'1966-01-31',
            'genesis__SSN__c'=>'324242424',
            'Confirm_SSN__c'=>'324242424',
            'MobilePhone'=>'4342343432',
            'Mailing_County__c'=>'West Bengal',
            'MailingPostalCode'=>'70011',
            'MailingState'=>'AL',
            'MailingCity'=>'Kolkata',
            'MailingStreet'=>'S.S. Temple Road',
            'FirstName'=>'Abhishake'
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));

        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : creating a sole prop application where ssn is missing
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testMissingSSN() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> requestMap = new Map<String, Object>();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                             FROM clcommon__Legal_Entity__c 
                                                             WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'];

        Map<String,Object> applicationMap=new Map<String,Object>{
            'genesis__Loan_Amount__c'=>100000
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000
        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'MobilePhone'=>'4342343432',
            'LastName'=>'Sharma',
            'FirstName'=>'Abhishake'
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));

        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
   

    /**
    * @description : creating a sole prop application where loan amount is missing
    * @author Krishanu Chinya | 09-03-2024 
    **/
    @isTest
    private static void testMissingloanAmount() {
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> requestMap = new Map<String, Object>();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                             FROM clcommon__Legal_Entity__c 
                                                             WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'];

        Map<String,Object> applicationMap=new Map<String,Object>{};

        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'clcommon__Legal_Entity_Type__c'=>legalEntityList[0].Id
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'genesis__Total_Liabilities__c'=>412333,
            'genesis__Total_Assets__c'=>456000
        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'anirbandas1234321@mailinator.com',
            'Birthdate'=>'1966-01-31',
            'genesis__SSN__c'=>'324242424',
            'Confirm_SSN__c'=>'324242424',
            'MobilePhone'=>'4342343432',
            'Mailing_County__c'=>'West Bengal',
            'MailingPostalCode'=>'70011',
            'MailingState'=>'AL',
            'MailingCity'=>'Kolkata',
            'MailingStreet'=>'S.S. Temple Road',
            'LastName'=>'Sharma',
            'FirstName'=>'Abhishake'
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));

        System.runAs(userObj) {
            Test.startTest();
            PortalInitiateApplicationAPI testApi = new PortalInitiateApplicationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

}