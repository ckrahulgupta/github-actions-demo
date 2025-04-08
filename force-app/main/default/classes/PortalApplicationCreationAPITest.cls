/**
 * @description       : Test Class for PortalApplcationCreationAPI
 * @author            : Simran
 * @last modified on  : 01-12-2025
 * @last modified by  : Rakesh Saraf
**/

@isTest
public with sharing class PortalApplicationCreationAPITest {
    @testSetup
    static void setup(){
        ApplicationOriginationSetupTestHelper.createTestSetup();

        genesis__Department__c departmentObj =  ApplicationOriginationTestHelper.createDepartmentByName(ConstantValues.PROFILE_CREDIT);
        Database.insert(departmentObj,true);

        genesis__Task_Setup__c taskSetupObj = ApplicationOriginationTestHelper.createTaskSetup(PortalConstants.ADDITIONAL_INFO_TASK);
        Database.insert(taskSetupObj,true);

    }

    /**
    * @description test for an application of sole prop
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testSaveAndContinueSolePropApplication() {
        User userObj;
        Map<String, Object> requestMap = new Map<String, Object>();

        Account sAAccount=ApplicationOriginationTestHelper.getSalesAgentAccount();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                            FROM clcommon__Legal_Entity__c
                                                            WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'
                                                            LIMIT 1];

        List<genesis__Applications__c> applicationList=[SELECT Id,
                                                                Certified_Lender__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Stage__c
                                                        FROM genesis__Applications__c 
                                                        WHERE Internal_Reference_Code__c = 'testApp001'
                                                        LIMIT 1];

        applicationList[0].Stage__c=PortalConstants.APPLICANT_INFORMATION;
        Database.update(applicationList,true);

        List<Account> accountList=[SELECT ID, genesis__Business_Information__c from Account WHERE ID=: applicationList[0].genesis__Account__c];

        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME AND genesis__Application__c=:applicationList[0].id LIMIT 1];
        List<Account> coBorrowerAccount = [SELECT Id,genesis__Business_Information__c FROM Account Where Id =: partyList[0].clcommon__Account__c Limit 1];
        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];

        userObj=ApplicationOriginationTestHelper.getBorrowerUser('Albin');

        Map<String,Object> applicationMap=new Map<String,Object>{
            'Id'=>applicationList[0].id ,
            'Sales_Agent__c'=>sAAccount.id,
            'genesis__Loan_Amount__c'=>100000,
            'Internal_Reference_Code__c'=>'43242341234'
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'Id'=> applicationList[0].genesis__Account__c, 
            'Work_Number__c'=> '2328452475', 
            'Home_Number__c'=> '2424952947', 
            'Phone'=> '1782548528', 
            'clcommon__Email__c'=> 'nick.pope@yopmail.com', 
            'Billing_County__c'=> 'Philadelphia County', 
            'BillingPostalCode'=> '90339', 
            'BillingState'=> 'PA', 
            'BillingCity'=> 'Philadelphia', 
            'BillingStreet'=> 'Kelly Drive', 
            'clcommon__Legal_Entity_Type__c'=> legalEntityList[0].id, 
            'Year_Began_Farming__c'=> '2014'
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'Id'=>accountList[0].genesis__Business_Information__c,
            'genesis__Total_Assets__c'=>10000000,
            'genesis__Total_Liabilities__c'=>0,
            'Gross_Farm_Income__c'=>50000

        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Id'=>applicationList[0].genesis__Contact__c,
            'FirstName'=>'Nick',
            'ints__Middle_Name__c'=>'De Silva',
            'LastName'=>'Pope',
            'Suffix__c'=>'Sr.',
            'MailingStreet'=>'Kelly Drive',
            'MailingCity'=>'Philadelphia',
            'MailingState'=>'PA',
            'Confirm_Email__c'=>'nick.pope@yopmail.com',
            'Confirm_SSN__c'=>'913242110',
            'clcommon__Marital_Status__c'=>'Unmarried',
            'MailingPostalCode'=>'90339',
            'Mailing_County__c'=>'Philadelphia County',
            'MobilePhone'=>'1782548528',
            'HomePhone'=>'2424952947',
            'Phone'=>'2328452475',
            'genesis__SSN__c'=>'913242110',
            'Birthdate'=>'2000-05-19',
            'Email'=>'nick.pope@yopmail.com'
        };

        Map<String,Object> coapplicantMap=new Map<String,Object>{
            'id'=>partyList[0].id,
            'Street__c'=>'Yellow Spring Road',
            'clcommon__Contact__r.Masked_Confirm_SSN__c'=>'XXX-XX-2111',
            'clcommon__Contact__r.Masked_SSN__c'=>'XXX-XX-2111',
            'Postal_Code__c'=>'38341',
            'clcommon__Contact__r.Id'=>coBorrowerContact[0].id,
            'Total_Assets__c'=>10000000,
            'clcommon__Contact__r.Birthdate'=>'1990-09-18',
            'Marital_Status__c'=>'Unmarried',
            'clcommon__Contact__r.LastName'=>'Magnussen',
            'Title__c'=>'Co-Applicant',
            'Work_Number__c'=>'1313242424',
            'clcommon__Contact__r.Confirm_Email__c'=>'kmag12@yopmail.com',
            'clcommon__Account__r.Id'=>coBorrowerAccount[0].id,
            'Is_SSN_Entered__c'=>true,
            'State__c'=>'TN',
            'clcommon__Account__r.Year_Began_Farming__c'=>'2014'
            ,'Suffix__c'=>'II',
            'Total_Liabilities__c'=>1,
            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=>9999999
            ,'clcommon__Contact__r.FirstName'=>'Kevin',
            'clcommon__Contact__r.Email'=>'kmag12@yopmail.com',
            'clcommon__Contact__r.genesis__SSN__c'=>'992922111',
            'clcommon__Account__r.genesis__Business_Information__r.Id'=>coBorrowerAccount[0].genesis__Business_Information__c,
            'City__c'=>'Philly',
            'County__c'=>'Decatur County',
            'Home_Number__c'=>'0180381308',
            'clcommon__Contact__r.ints__Middle_Name__c'=>'KMag',
            'Id'=>partyList[0].id,'clcommon__Contact__r.Confirm_SSN__c'=>'992922111',
            'Mobile_Number__c'=>'4294729472'
        };
        List<Map<String,Object>> coApplicantMapList=new List<Map<String,Object>>{coapplicantMap};


        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        requestMap.put('coapplicant',JSON.serialize(coApplicantMapList));

        System.runAs(userObj) {
            Test.startTest();
            PortalApplicationCreationAPI testApi = new PortalApplicationCreationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    }
    
    /**
    * @description save the application without sending any coApplicant record
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testSaveAndContinueSolePropApplicationWithoutCoApplicant() {
        User userObj;
        Map<String, Object> requestMap = new Map<String, Object>();

        Account sAAccount=ApplicationOriginationTestHelper.getSalesAgentAccount();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                            FROM clcommon__Legal_Entity__c
                                                            WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'
                                                            LIMIT 1];

        List<genesis__Applications__c> applicationList=[SELECT Id,
                                                                Certified_Lender__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                        FROM genesis__Applications__c 
                                                        WHERE Internal_Reference_Code__c = 'testApp001'
                                                        LIMIT 1];

        List<Account> accountList=[SELECT ID, genesis__Business_Information__c from Account WHERE ID=: applicationList[0].genesis__Account__c];

        userObj=ApplicationOriginationTestHelper.getBorrowerUser('Albin');

        Map<String,Object> applicationMap=new Map<String,Object>{
            'Id'=>applicationList[0].id ,
            'Sales_Agent__c'=>sAAccount.id,
            'genesis__Loan_Amount__c'=>100000,
            'Internal_Reference_Code__c'=>'43242341234'
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'Id'=> applicationList[0].genesis__Account__c, 
            'Work_Number__c'=> '2328452475', 
            'Home_Number__c'=> '2424952947', 
            'Phone'=> '1782548528', 
            'clcommon__Email__c'=> 'nick.pope@yopmail.com', 
            'Billing_County__c'=> 'Philadelphia County', 
            'BillingPostalCode'=> '90339', 
            'BillingState'=> 'PA', 
            'BillingCity'=> 'Philadelphia', 
            'BillingStreet'=> 'Kelly Drive', 
            'clcommon__Legal_Entity_Type__c'=> legalEntityList[0].id, 
            'Year_Began_Farming__c'=> '2014'
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'Id'=>accountList[0].genesis__Business_Information__c,
            'genesis__Total_Assets__c'=>10000000,
            'genesis__Total_Liabilities__c'=>0,
            'Gross_Farm_Income__c'=>50000

        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Id'=>applicationList[0].genesis__Contact__c,
            'FirstName'=>'Nick',
            'ints__Middle_Name__c'=>'De Silva',
            'LastName'=>'Pope',
            'Suffix__c'=>'Sr.',
            'MailingStreet'=>'Kelly Drive',
            'MailingCity'=>'Philadelphia',
            'MailingState'=>'PA',
            'Confirm_Email__c'=>'nick.pope@yopmail.com',
            'Confirm_SSN__c'=>'913242110',
            'clcommon__Marital_Status__c'=>'Unmarried',
            'MailingPostalCode'=>'90339',
            'Mailing_County__c'=>'Philadelphia County',
            'MobilePhone'=>'1782548528',
            'HomePhone'=>'2424952947',
            'Phone'=>'2328452475',
            'genesis__SSN__c'=>'913242110',
            'Birthdate'=>'2000-05-19',
            'Email'=>'nick.pope@yopmail.com'
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');

        System.runAs(userObj) {
            Test.startTest();
            PortalApplicationCreationAPI testApi = new PortalApplicationCreationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    }
    
    /**
    * @description test for save and continue for a corporation
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testSaveAndContinueCorpApplication() {
        User userObj;
        Map<String, Object> requestMap = new Map<String, Object>();

        Account sAAccount=ApplicationOriginationTestHelper.getSalesAgentAccount();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                            FROM clcommon__Legal_Entity__c
                                                            WHERE clcommon__Legal_Entity_Type__c = 'Corporation'
                                                            LIMIT 1];

        List<genesis__Applications__c> applicationList=[SELECT Id,
                                                                Certified_Lender__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                        FROM genesis__Applications__c 
                                                        WHERE Internal_Reference_Code__c = 'testApp002'
                                                        LIMIT 1];

        List<Account> accountList=[SELECT ID, genesis__Business_Information__c from Account WHERE ID=: applicationList[0].genesis__Account__c];

        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME AND genesis__Application__c=:applicationList[0].id LIMIT 1];
        List<Account> coBorrowerAccount = [SELECT Id,genesis__Business_Information__c FROM Account Where Id =: partyList[0].clcommon__Account__c Limit 1];
        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];

        userObj= ApplicationOriginationTestHelper.createBorrowerUser(coBorrowerContact[0].id);
        userObj.UserName='corp.principal@yopmail.com';
        Database.insert(userObj);

        Map<String,Object> applicationMap=new Map<String,Object>{
            'Id'=>applicationList[0].id ,
            'Sales_Agent__c'=>sAAccount.id,
            'genesis__Loan_Amount__c'=>100000,
            'Internal_Reference_Code__c'=>'43242341234'
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'Id'=> applicationList[0].genesis__Account__c, 
            'Work_Number__c'=> '2328452475', 
            'Home_Number__c'=> '2424952947', 
            'Phone'=> '1782548528', 
            'clcommon__Email__c'=> 'nick.pope@yopmail.com', 
            'Confirm_Email__c'=> 'nick.pope@yopmail.com', 
            'Billing_County__c'=> 'Philadelphia County', 
            'BillingPostalCode'=> '90339', 
            'BillingState'=> 'PA', 
            'BillingCity'=> 'Philadelphia', 
            'BillingStreet'=> 'Kelly Drive', 
            'clcommon__Legal_Entity_Type__c'=> legalEntityList[0].id,
            'Name'=>'Royal Companies'
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'Id'=>accountList[0].genesis__Business_Information__c,
            'genesis__Total_Assets__c'=>10000000,
            'genesis__Total_Liabilities__c'=>0,
            'Gross_Farm_Income__c'=>50000,
            'genesis__Tax_Identification_Number__c'=>'121739173',
            'Confirm_Tax_Identification_Number__c'=>'121739173',
            'genesis__State_of_Incorporation__c'=>'IN'

        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'karl.jarvis12@yopmail.com'
        };

        Map<String,Object> coapplicantMap=new Map<String,Object>{
            'id'=>partyList[0].id,
            'Street__c'=>'Yellow Spring Road',
            'clcommon__Contact__r.Masked_Confirm_SSN__c'=>'XXX-XX-2111',
            'clcommon__Contact__r.Masked_SSN__c'=>'XXX-XX-2111',
            'Postal_Code__c'=>'38341',
            'clcommon__Contact__r.Id'=>coBorrowerContact[0].id,
            'Total_Assets__c'=>10000000,
            'clcommon__Contact__r.Birthdate'=>'1990-09-18',
            'Marital_Status__c'=>'Unmarried',
            'clcommon__Contact__r.LastName'=>'Magnussen',
            'Title__c'=>'Co-Applicant',
            'Work_Number__c'=>'1313242424',
            'clcommon__Contact__r.Confirm_Email__c'=>'kmag12@yopmail.com',
            'clcommon__Account__r.Id'=>coBorrowerAccount[0].id,
            'Is_SSN_Entered__c'=>true,
            'State__c'=>'TN',
            'clcommon__Account__r.Year_Began_Farming__c'=>'2014'
            ,'Suffix__c'=>'II',
            'Total_Liabilities__c'=>1,
            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=>9999999
            ,'clcommon__Contact__r.FirstName'=>'Kevin',
            'clcommon__Contact__r.Email'=>'kmag12@yopmail.com',
            'clcommon__Contact__r.genesis__SSN__c'=>'992922111',
            'clcommon__Account__r.genesis__Business_Information__r.Id'=>coBorrowerAccount[0].genesis__Business_Information__c,
            'City__c'=>'Philly',
            'County__c'=>'Decatur County',
            'Home_Number__c'=>'0180381308',
            'clcommon__Contact__r.ints__Middle_Name__c'=>'KMag',
            'Id'=>partyList[0].id,'clcommon__Contact__r.Confirm_SSN__c'=>'992922111',
            'Mobile_Number__c'=>'4294729472'
        };
        
        List<Map<String,Object>> coApplicantMapList=new List<Map<String,Object>>{coapplicantMap};

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        requestMap.put('coapplicant',JSON.serialize(coApplicantMapList));

        System.runAs(userObj) {
            Test.startTest();
            PortalApplicationCreationAPI testApi = new PortalApplicationCreationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    } 

    /**
    * @description test for creating an application of a corp without a co applicant
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testSaveAndContinueForCorpWithoutCoApplicant() {
        User userObj;
        Map<String, Object> requestMap = new Map<String, Object>();

        Account sAAccount=ApplicationOriginationTestHelper.getSalesAgentAccount();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                            FROM clcommon__Legal_Entity__c
                                                            WHERE clcommon__Legal_Entity_Type__c = 'Corporation'
                                                            LIMIT 1];

        List<genesis__Applications__c> applicationList=[SELECT Id,
                                                                Certified_Lender__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                        FROM genesis__Applications__c 
                                                        WHERE Internal_Reference_Code__c = 'testApp002'
                                                        LIMIT 1];

        List<Account> accountList=[SELECT ID, genesis__Business_Information__c from Account WHERE ID=: applicationList[0].genesis__Account__c];

        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME AND genesis__Application__c=:applicationList[0].id LIMIT 1];

        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];

        userObj= ApplicationOriginationTestHelper.createBorrowerUser(coBorrowerContact[0].id);
        userObj.UserName='corp.principal@yopmail.com';
        Database.insert(userObj);

        Map<String,Object> applicationMap=new Map<String,Object>{
            'Id'=>applicationList[0].id ,
            'Sales_Agent__c'=>sAAccount.id,
            'genesis__Loan_Amount__c'=>100000,
            'Internal_Reference_Code__c'=>'43242341234'
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'Id'=> applicationList[0].genesis__Account__c, 
            'Work_Number__c'=> '2328452475', 
            'Home_Number__c'=> '2424952947', 
            'Phone'=> '1782548528', 
            'clcommon__Email__c'=> 'nick.pope@yopmail.com', 
            'Confirm_Email__c'=> 'nick.pope@yopmail.com', 
            'Billing_County__c'=> 'Philadelphia County', 
            'BillingPostalCode'=> '90339', 
            'BillingState'=> 'PA', 
            'BillingCity'=> 'Philadelphia', 
            'BillingStreet'=> 'Kelly Drive', 
            'clcommon__Legal_Entity_Type__c'=> legalEntityList[0].id,
            'Name'=>'Royal Companies'
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'Id'=>accountList[0].genesis__Business_Information__c,
            'genesis__Total_Assets__c'=>10000000,
            'genesis__Total_Liabilities__c'=>0,
            'Gross_Farm_Income__c'=>50000,
            'genesis__Tax_Identification_Number__c'=>'121739173',
            'Confirm_Tax_Identification_Number__c'=>'121739173',
            'genesis__State_of_Incorporation__c'=>'IN'

        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Email'=>'karl.jarvis12@yopmail.com'
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');

        System.runAs(userObj) {
            Test.startTest();
            PortalApplicationCreationAPI testApi = new PortalApplicationCreationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    } 

    /**
    * @description test for save and continue for a dba
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testSaveAndContinueDBAApplication() {
        User userObj;
        Map<String, Object> requestMap = new Map<String, Object>();

        Account sAAccount=ApplicationOriginationTestHelper.getSalesAgentAccount();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                            FROM clcommon__Legal_Entity__c
                                                            WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) with DBA'
                                                            LIMIT 1];

        List<genesis__Applications__c> applicationList=[SELECT Id,
                                                                Certified_Lender__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                        FROM genesis__Applications__c 
                                                        WHERE Internal_Reference_Code__c = 'testApp002'
                                                        LIMIT 1];

        List<Account> accountList=[SELECT ID, genesis__Business_Information__c from Account WHERE ID=: applicationList[0].genesis__Account__c];

        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME AND genesis__Application__c=:applicationList[0].id LIMIT 1];
        List<Account> coBorrowerAccount = [SELECT Id,genesis__Business_Information__c FROM Account Where Id =: partyList[0].clcommon__Account__c Limit 1];
        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];

        userObj= ApplicationOriginationTestHelper.createBorrowerUser(coBorrowerContact[0].id);
        userObj.UserName='dba.principal@yopmail.com';
        Database.insert(userObj);

        Map<String,Object> applicationMap=new Map<String,Object>{
            'Id'=>applicationList[0].id ,
            'Sales_Agent__c'=>sAAccount.id,
            'genesis__Loan_Amount__c'=>100000,
            'Internal_Reference_Code__c'=>'43242341234'
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'Id'=> applicationList[0].genesis__Account__c, 
            'clcommon__Legal_Entity_Type__c'=> legalEntityList[0].id,
            'Name'=>'Royal Companies'
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'Id'=>accountList[0].genesis__Business_Information__c
        };
        

        Map<String,Object> coapplicantMap=new Map<String,Object>{
            'id'=>partyList[0].id,
            'Street__c'=>'Yellow Spring Road',
            'clcommon__Contact__r.Masked_Confirm_SSN__c'=>'XXX-XX-2111',
            'clcommon__Contact__r.Masked_SSN__c'=>'XXX-XX-2111',
            'Postal_Code__c'=>'38341',
            'clcommon__Contact__r.Id'=>coBorrowerContact[0].id,
            'Total_Assets__c'=>10000000,
            'clcommon__Contact__r.Birthdate'=>'1990-09-18',
            'Marital_Status__c'=>'Unmarried',
            'clcommon__Contact__r.LastName'=>'Magnussen',
            'Title__c'=>'Co-Applicant',
            'Work_Number__c'=>'1313242424',
            'clcommon__Contact__r.Confirm_Email__c'=>'kmag12@yopmail.com',
            'clcommon__Account__r.Id'=>coBorrowerAccount[0].id,
            'Is_SSN_Entered__c'=>true,
            'State__c'=>'TN',
            'clcommon__Account__r.Year_Began_Farming__c'=>'2014'
            ,'Suffix__c'=>'II',
            'Total_Liabilities__c'=>1,
            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=>9999999
            ,'clcommon__Contact__r.FirstName'=>'Kevin',
            'clcommon__Contact__r.Email'=>'kmag12@yopmail.com',
            'clcommon__Contact__r.genesis__SSN__c'=>'992922111',
            'clcommon__Account__r.genesis__Business_Information__r.Id'=>coBorrowerAccount[0].genesis__Business_Information__c,
            'City__c'=>'Philly',
            'County__c'=>'Decatur County',
            'Home_Number__c'=>'0180381308',
            'clcommon__Contact__r.ints__Middle_Name__c'=>'KMag',
            'Id'=>partyList[0].id,'clcommon__Contact__r.Confirm_SSN__c'=>'992922111',
            'Mobile_Number__c'=>'4294729472'
        };

        List<Map<String,Object>> coApplicantMapList=new List<Map<String,Object>>{coapplicantMap};

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        requestMap.put('coapplicant',JSON.serialize(coApplicantMapList));

        System.runAs(userObj) {
            Test.startTest();
            PortalApplicationCreationAPI testApi = new PortalApplicationCreationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    } 

    /**
    * @description test for save and continue for a dba without a principal
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testSaveAndContinueDBAApplicationNoCoApp() {
        User userObj;
        Map<String, Object> requestMap = new Map<String, Object>();

        Account sAAccount=ApplicationOriginationTestHelper.getSalesAgentAccount();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                            FROM clcommon__Legal_Entity__c
                                                            WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) with DBA'
                                                            LIMIT 1];

        List<genesis__Applications__c> applicationList=[SELECT Id,
                                                                Certified_Lender__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                        FROM genesis__Applications__c 
                                                        WHERE Internal_Reference_Code__c = 'testApp002'
                                                        LIMIT 1];

        List<Account> accountList=[SELECT ID, genesis__Business_Information__c from Account WHERE ID=: applicationList[0].genesis__Account__c];

        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME AND genesis__Application__c=:applicationList[0].id LIMIT 1];
        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];

        userObj= ApplicationOriginationTestHelper.createBorrowerUser(coBorrowerContact[0].id);
        userObj.UserName='dba.principal@yopmail.com';
        Database.insert(userObj);

        Map<String,Object> applicationMap=new Map<String,Object>{
            'Id'=>applicationList[0].id ,
            'Sales_Agent__c'=>sAAccount.id,
            'genesis__Loan_Amount__c'=>100000,
            'Internal_Reference_Code__c'=>'43242341234'
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'Id'=> applicationList[0].genesis__Account__c, 
            'clcommon__Legal_Entity_Type__c'=> legalEntityList[0].id,
            'Name'=>'Royal Companies'
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'Id'=>accountList[0].genesis__Business_Information__c
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');

        System.runAs(userObj) {
            Test.startTest();
            PortalApplicationCreationAPI testApi = new PortalApplicationCreationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    } 

    /**
    * @description TEST CASE WITHOUT ACCOUNT ID
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testExistingApplicantWithoutAccountId() {
        User userObj;
        Map<String, Object> requestMap = new Map<String, Object>();

        Account sAAccount=ApplicationOriginationTestHelper.getSalesAgentAccount();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                            FROM clcommon__Legal_Entity__c
                                                            WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'
                                                            LIMIT 1];

        List<genesis__Applications__c> applicationList=[SELECT Id,
                                                                Certified_Lender__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                        FROM genesis__Applications__c 
                                                        WHERE Internal_Reference_Code__c = 'testApp001'
                                                        LIMIT 1];

        List<Account> accountList=[SELECT ID, genesis__Business_Information__c from Account WHERE ID=: applicationList[0].genesis__Account__c];

        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME AND genesis__Application__c=:applicationList[0].id LIMIT 1];
        List<Account> coBorrowerAccount = [SELECT Id,genesis__Business_Information__c FROM Account Where Id =: partyList[0].clcommon__Account__c Limit 1];
        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];

        userObj=ApplicationOriginationTestHelper.getBorrowerUser('Albin');

        Map<String,Object> applicationMap=new Map<String,Object>{
            'Id'=>applicationList[0].id ,
            'Sales_Agent__c'=>sAAccount.id,
            'genesis__Loan_Amount__c'=>100000,
            'Internal_Reference_Code__c'=>'43242341234'
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'Work_Number__c'=> '2328452475', 
            'Home_Number__c'=> '2424952947', 
            'Phone'=> '1782548528', 
            'clcommon__Email__c'=> 'nick.pope@yopmail.com', 
            'Billing_County__c'=> 'Philadelphia County', 
            'BillingPostalCode'=> '90339', 
            'BillingState'=> 'PA', 
            'BillingCity'=> 'Philadelphia', 
            'BillingStreet'=> 'Kelly Drive', 
            'clcommon__Legal_Entity_Type__c'=> legalEntityList[0].id, 
            'Year_Began_Farming__c'=> '2014'
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'Id'=>accountList[0].genesis__Business_Information__c,
            'genesis__Total_Assets__c'=>10000000,
            'genesis__Total_Liabilities__c'=>0,
            'Gross_Farm_Income__c'=>50000

        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Id'=>applicationList[0].genesis__Contact__c,
            'FirstName'=>'Nick',
            'ints__Middle_Name__c'=>'De Silva',
            'LastName'=>'Pope',
            'Suffix__c'=>'Sr.',
            'MailingStreet'=>'Kelly Drive',
            'MailingCity'=>'Philadelphia',
            'MailingState'=>'PA',
            'Confirm_Email__c'=>'nick.pope@yopmail.com',
            'Confirm_SSN__c'=>'913242110',
            'clcommon__Marital_Status__c'=>'Unmarried',
            'MailingPostalCode'=>'90339',
            'Mailing_County__c'=>'Philadelphia County',
            'MobilePhone'=>'1782548528',
            'HomePhone'=>'2424952947',
            'Phone'=>'2328452475',
            'genesis__SSN__c'=>'913242110',
            'Birthdate'=>'2000-05-19',
            'Email'=>'nick.pope@yopmail.com'
        };

        Map<String,Object> coapplicantMap=new Map<String,Object>{
            'id'=>partyList[0].id,
            'Street__c'=>'Yellow Spring Road',
            'clcommon__Contact__r.Masked_Confirm_SSN__c'=>'XXX-XX-2111',
            'clcommon__Contact__r.Masked_SSN__c'=>'XXX-XX-2111',
            'Postal_Code__c'=>'38341',
            'clcommon__Contact__r.Id'=>coBorrowerContact[0].id,
            'Total_Assets__c'=>10000000,
            'clcommon__Contact__r.Birthdate'=>'1990-09-18',
            'Marital_Status__c'=>'Unmarried',
            'clcommon__Contact__r.LastName'=>'Magnussen',
            'Title__c'=>'Co-Applicant',
            'Work_Number__c'=>'1313242424',
            'clcommon__Contact__r.Confirm_Email__c'=>'kmag12@yopmail.com',
            'clcommon__Account__r.Id'=>coBorrowerAccount[0].id,
            'Is_SSN_Entered__c'=>true,
            'State__c'=>'TN',
            'clcommon__Account__r.Year_Began_Farming__c'=>'2014'
            ,'Suffix__c'=>'II',
            'Total_Liabilities__c'=>1,
            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=>9999999
            ,'clcommon__Contact__r.FirstName'=>'Kevin',
            'clcommon__Contact__r.Email'=>'kmag12@yopmail.com',
            'clcommon__Contact__r.genesis__SSN__c'=>'992922111',
            'clcommon__Account__r.genesis__Business_Information__r.Id'=>coBorrowerAccount[0].genesis__Business_Information__c,
            'City__c'=>'Philly',
            'County__c'=>'Decatur County',
            'Home_Number__c'=>'0180381308',
            'clcommon__Contact__r.ints__Middle_Name__c'=>'KMag',
            'Id'=>partyList[0].id,'clcommon__Contact__r.Confirm_SSN__c'=>'992922111',
            'Mobile_Number__c'=>'4294729472'
        };

        List<Map<String,Object>> coApplicantMapList=new List<Map<String,Object>>{coapplicantMap};

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        requestMap.put('coapplicant',JSON.serialize(coApplicantMapList));

        System.runAs(userObj) {
            Test.startTest();
            PortalApplicationCreationAPI testApi = new PortalApplicationCreationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Application Creation Failed');
            Test.stopTest();
        }
    }
    
    /**
    * @description test for an application of sole prop without dealer coop type
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testSolePropApplicationWithoutCoopType() {
        User userObj;
        Map<String, Object> requestMap = new Map<String, Object>();

        Account sAAccount=ApplicationOriginationTestHelper.getSalesAgentAccount();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                            FROM clcommon__Legal_Entity__c
                                                            WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'
                                                            LIMIT 1];

        Account dealerAcc=[SELECT ID,
                                   Coop_Type__c
                            FROM Account
                            WHERE Name = 'Kisan Loan'
                            LIMIT 1];
        dealerAcc.Coop_Type__c=PortalConstants.EMPTY_STRING;
        Database.update(dealerAcc,true);

        List<genesis__Applications__c> applicationList=[SELECT Id,
                                                                Certified_Lender__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Stage__c
                                                        FROM genesis__Applications__c 
                                                        WHERE Internal_Reference_Code__c = 'testApp001'
                                                        LIMIT 1];

        applicationList[0].Stage__c=PortalConstants.APPLICANT_INFORMATION;
        Database.update(applicationList,true);

        List<Account> accountList=[SELECT ID, genesis__Business_Information__c from Account WHERE ID=: applicationList[0].genesis__Account__c];

        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME AND genesis__Application__c=:applicationList[0].id LIMIT 1];
        List<Account> coBorrowerAccount = [SELECT Id,genesis__Business_Information__c FROM Account Where Id =: partyList[0].clcommon__Account__c Limit 1];
        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];

        userObj=ApplicationOriginationTestHelper.getBorrowerUser('Albin');

        Map<String,Object> applicationMap=new Map<String,Object>{
            'Id'=>applicationList[0].id ,
            'Sales_Agent__c'=>sAAccount.id,
            'genesis__Loan_Amount__c'=>100000,
            'Internal_Reference_Code__c'=>'43242341234'
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'Id'=> applicationList[0].genesis__Account__c, 
            'Work_Number__c'=> '2328452475', 
            'Home_Number__c'=> '2424952947', 
            'Phone'=> '1782548528', 
            'clcommon__Email__c'=> 'nick.pope@yopmail.com', 
            'Billing_County__c'=> 'Philadelphia County', 
            'BillingPostalCode'=> '90339', 
            'BillingState'=> 'PA', 
            'BillingCity'=> 'Philadelphia', 
            'BillingStreet'=> 'Kelly Drive', 
            'clcommon__Legal_Entity_Type__c'=> legalEntityList[0].id, 
            'Year_Began_Farming__c'=> '2014'
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'Id'=>accountList[0].genesis__Business_Information__c,
            'genesis__Total_Assets__c'=>10000000,
            'genesis__Total_Liabilities__c'=>0,
            'Gross_Farm_Income__c'=>50000

        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Id'=>applicationList[0].genesis__Contact__c,
            'FirstName'=>'Nick',
            'ints__Middle_Name__c'=>'De Silva',
            'LastName'=>'Pope',
            'Suffix__c'=>'Sr.',
            'MailingStreet'=>'Kelly Drive',
            'MailingCity'=>'Philadelphia',
            'MailingState'=>'PA',
            'Confirm_Email__c'=>'nick.pope@yopmail.com',
            'Confirm_SSN__c'=>'913242110',
            'clcommon__Marital_Status__c'=>'Unmarried',
            'MailingPostalCode'=>'90339',
            'Mailing_County__c'=>'Philadelphia County',
            'MobilePhone'=>'1782548528',
            'HomePhone'=>'2424952947',
            'Phone'=>'2328452475',
            'genesis__SSN__c'=>'913242110',
            'Birthdate'=>'2000-05-19',
            'Email'=>'nick.pope@yopmail.com'
        };

        Map<String,Object> coapplicantMap=new Map<String,Object>{
            'id'=>partyList[0].id,
            'Street__c'=>'Yellow Spring Road',
            'clcommon__Contact__r.Masked_Confirm_SSN__c'=>'XXX-XX-2111',
            'clcommon__Contact__r.Masked_SSN__c'=>'XXX-XX-2111',
            'Postal_Code__c'=>'38341',
            'clcommon__Contact__r.Id'=>coBorrowerContact[0].id,
            'Total_Assets__c'=>10000000,
            'clcommon__Contact__r.Birthdate'=>'1990-09-18',
            'Marital_Status__c'=>'Unmarried',
            'clcommon__Contact__r.LastName'=>'Magnussen',
            'Title__c'=>'Co-Applicant',
            'Work_Number__c'=>'1313242424',
            'clcommon__Contact__r.Confirm_Email__c'=>'kmag12@yopmail.com',
            'clcommon__Account__r.Id'=>coBorrowerAccount[0].id,
            'Is_SSN_Entered__c'=>true,
            'State__c'=>'TN',
            'clcommon__Account__r.Year_Began_Farming__c'=>'2014'
            ,'Suffix__c'=>'II',
            'Total_Liabilities__c'=>1,
            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=>9999999
            ,'clcommon__Contact__r.FirstName'=>'Kevin',
            'clcommon__Contact__r.Email'=>'kmag12@yopmail.com',
            'clcommon__Contact__r.genesis__SSN__c'=>'992922111',
            'clcommon__Account__r.genesis__Business_Information__r.Id'=>coBorrowerAccount[0].genesis__Business_Information__c,
            'City__c'=>'Philly',
            'County__c'=>'Decatur County',
            'Home_Number__c'=>'0180381308',
            'clcommon__Contact__r.ints__Middle_Name__c'=>'KMag',
            'Id'=>partyList[0].id,'clcommon__Contact__r.Confirm_SSN__c'=>'992922111',
            'Mobile_Number__c'=>'4294729472'
        };
        List<Map<String,Object>> coApplicantMapList=new List<Map<String,Object>>{coapplicantMap};

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        requestMap.put('coapplicant',JSON.serialize(coApplicantMapList));

        System.runAs(userObj) {
            Test.startTest();
            PortalApplicationCreationAPI testApi = new PortalApplicationCreationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    }

    /**
    * @description test to get exception thrown
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testToGetException() {
        User userObj;
        Map<String, Object> requestMap = new Map<String, Object>();

        Account sAAccount=ApplicationOriginationTestHelper.getSalesAgentAccount();

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id
                                                            FROM clcommon__Legal_Entity__c
                                                            WHERE clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship'
                                                            LIMIT 1];

        List<genesis__Applications__c> applicationList=[SELECT Id,
                                                                Certified_Lender__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Stage__c
                                                        FROM genesis__Applications__c 
                                                        WHERE Internal_Reference_Code__c = 'testApp001'
                                                        LIMIT 1];

        applicationList[0].Stage__c=PortalConstants.APPLICANT_INFORMATION;
        Database.update(applicationList,true);

        List<Account> accountList=[SELECT ID, genesis__Business_Information__c from Account WHERE ID=: applicationList[0].genesis__Account__c];

        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME AND genesis__Application__c=:applicationList[0].id LIMIT 1];
        List<Account> coBorrowerAccount = [SELECT Id,genesis__Business_Information__c FROM Account Where Id =: partyList[0].clcommon__Account__c Limit 1];
        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];

        userObj=ApplicationOriginationTestHelper.getBorrowerUser('Albin');

        Map<String,Object> applicationMap=new Map<String,Object>{
            'Id'=>applicationList[0].id ,
            'Sales_Agent__c'=>sAAccount.id,
            'genesis__Loan_Amount__c'=>100000,
            'Internal_Reference_Code__c'=>'43242341234'
        };
        Map<String,Object> primaryApplicantAccMap=new Map<String,Object>{
            'Id'=> applicationList[0].genesis__Account__c, 
            'Work_Number__c'=> '2328452475', 
            'Home_Number__c'=> '2424952947', 
            'Phone'=> '1782548528', 
            'clcommon__Email__c'=> 'nick.pope@yopmail.com', 
            'Billing_County__c'=> 'Philadelphia County', 
            'BillingPostalCode'=> '90339', 
            'BillingState'=> 'PA', 
            'BillingCity'=> 'Philadelphia', 
            'BillingStreet'=> 'Kelly Drive', 
            'clcommon__Legal_Entity_Type__c'=> legalEntityList[0].id, 
            'Year_Began_Farming__c'=> '2014'
        };
        Map<String,Object> priAppBInfoMap=new Map<String,Object>{
            'Id'=>accountList[0].genesis__Business_Information__c,
            'genesis__Total_Assets__c'=>10000000,
            'genesis__Total_Liabilities__c'=>0,
            'Gross_Farm_Income__c'=>50000

        };
        Map<String,Object> primaryApplicantConMap=new Map<String,Object>{
            'Id'=>applicationList[0].genesis__Contact__c,
            'FirstName'=>'Nick',
            'ints__Middle_Name__c'=>'De Silva',
            'LastName'=>'Pope',
            'Suffix__c'=>'Sr.',
            'MailingStreet'=>'Kelly Drive',
            'MailingCity'=>'Philadelphia',
            'MailingState'=>'PA',
            'Confirm_Email__c'=>'nick.pope@yopmail.com',
            'Confirm_SSN__c'=>'913242110',
            'clcommon__Marital_Status__c'=>'Unmarried',
            'MailingPostalCode'=>'90339',
            'Mailing_County__c'=>'Philadelphia County',
            'MobilePhone'=>'1782548528',
            'HomePhone'=>'2424952947',
            'Phone'=>'2328452475',
            'genesis__SSN__c'=>'913242110',
            'Birthdate'=>'2000-05-19',
            'Email'=>'nick.pope@yopmail.com'
        };

        Map<String,Object> coapplicantMap=new Map<String,Object>{
            'id'=>partyList[0].id,
            'Street__c'=>'Yellow Spring Road',
            'clcommon__Contact__r.Masked_Confirm_SSN__c'=>'XXX-XX-2111',
            'clcommon__Contact__r.Masked_SSN__c'=>'XXX-XX-2111',
            'Postal_Code__c'=>'38341',
            'clcommon__Contact__r.Id'=>coBorrowerContact[0].id,
            'Total_Assets__c'=>10000000,
            'clcommon__Contact__r.Birthdate'=>'1990-09-18',
            'Marital_Status__c'=>'Unmarried',
            'clcommon__Contact__r.LastName'=>'Magnussen',
            'Title__c'=>'Co-Applicant',
            'Work_Number__c'=>'1313242424',
            'clcommon__Contact__r.Confirm_Email__c'=>'kmag12@yopmail.com',
            'clcommon__Account__r.Id'=>coBorrowerAccount[0].id,
            'Is_SSN_Entered__c'=>true,
            'State__c'=>'TN',
            'clcommon__Account__r.Year_Began_Farming__c'=>'2014'
            ,'Suffix__c'=>'II',
            'Total_Liabilities__c'=>1,
            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=>9999999
            ,'clcommon__Contact__r.FirstName'=>'Kevin',
            'clcommon__Contact__r.Email'=>'kmag12@yopmail.com',
            'clcommon__Contact__r.genesis__SSN__c'=>'992922111',
            'clcommon__Account__r.genesis__Business_Information__r.Id'=>coBorrowerAccount[0].genesis__Business_Information__c,
            'City__c'=>'Philly',
            'County__c'=>'Decatur County',
            'Home_Number__c'=>'0180381308',
            'clcommon__Contact__r.ints__Middle_Name__c'=>'KMag',
            'Id'=>partyList[0].id,'clcommon__Contact__r.Confirm_SSN__c'=>'992922111',
            'Mobile_Number__c'=>'4294729472'
        };

        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount', JSON.serialize(primaryApplicantAccMap));
        requestMap.put('primaryApplicantBusinessInformation', JSON.serialize(priAppBInfoMap));
        requestMap.put('primaryApplicantContact', JSON.serialize(primaryApplicantConMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        requestMap.put('coapplicant',JSON.serialize(coapplicantMap));

        System.runAs(userObj) {
            Test.startTest();
            PortalApplicationCreationAPI testApi = new PortalApplicationCreationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    }
    
}