/**
 * @description       : Test class for PortalSaveApplicantInformationAPI
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 03-02-2025
 * @last modified by  : Rakesh Saraf
**/

@isTest
public with sharing class PortalSaveApplicantInformationAPITest {
    
    @testSetup
    static void setup(){

        ApplicationOriginationSetupTestHelper.createTestSetup();

        genesis__Applications__c applicationObj=[SELECT ID FROM genesis__Applications__c WHERE Internal_Reference_Code__c = 'testApp001'];

        //creating a document category for the application
        clcommon__document_category__c docCategory = ApplicationOriginationTestHelper.createDocCategory(applicationObj.id, PortalConstants.DRIVING_LICENSE_TASK);
        Database.insert(docCategory,true);

        Account borrowerAccountObj=ApplicationOriginationTestHelper.getBorrowerAccount();

        ContentVersion contentVersion = ApplicationOriginationTestHelper.createContentVersion();
        Database.insert(contentVersion,true);

        ContentDocument contentDocObj = [SELECT Id FROM ContentDocument WHERE Title =: contentVersion.Title];
        ContentDocumentLink contentDocumentLink = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocObj.id,borrowerAccountObj.id);
        Database.insert(contentDocumentLink,true);

        //Create Task for the Application
        genesis__Department__c separtmentObj =  ApplicationOriginationTestHelper.createDepartmentByName(ConstantValues.PROFILE_CREDIT);
        Database.insert(separtmentObj,true);

        genesis__Task_Setup__c taskSetupObj = ApplicationOriginationTestHelper.createTaskSetup(PortalConstants.ADDITIONAL_INFO_TASK);
        Database.insert(taskSetupObj,true);
    }

    /**
     * @description Return the entity type
     * @param type 
     * @return  `clcommon__Legal_Entity__c`
     */
    private static clcommon__Legal_Entity__c getLegalEntityList(String type){
        return [SELECT Id
                FROM clcommon__Legal_Entity__c 
                WHERE clcommon__Legal_Entity_Type__c =: type][0];
    }

    /**
     * @description Return the User
     * @param contactId 
     * @return  `User`
     */
    private static User getUser(String contactId){
        return [SELECT Id 
                FROM User 
                WHERE ContactId =: contactId][0];

    }

    /**
     * @description Return Sales Agent Contact
     * @param accountId 
     * @return  `Contact`
     */
    private static Contact getSalesAgentContact(String accountId){
        return [SELECT Id 
                FROM CONTACT 
                WHERE AccountId =: accountId][0];
    }

    /**
    * @description test method to create a new application with a sales agent as the one creating it
    * @author Rakesh Saraf | 12-15-2024 
    **/
    @isTest
    private static void testCreateSolePropAppForNewApplicantWithSA() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,genesis__Account__c,genesis__Contact__c FROM genesis__Applications__c WHERE Internal_Reference_Code__c = 'testApp001' LIMIT 1];
        List<Account> borrowerAccount = [Select Id,genesis__Business_Information__c From Account Where Id =: applicationList[0].genesis__Account__c LIMIT 1];
        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME LIMIT 1];
        List<Account> coBorrowerAccount = [SELECT Id,genesis__Business_Information__c FROM Account Where Id =: partyList[0].clcommon__Account__c Limit 1];
        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];
        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        applicationList[0].Sales_Agent__c = accountObj.id;
        Database.update(applicationList, true);

        Contact sAContact=getSalesAgentContact(accountObj.id);
        clcommon__Party_Type__c sAPartyType=[SELECT ID, Name from clcommon__Party_Type__c WHERE Name='SALES AGENT'];
        clcommon__Party__c sAPartyObj=ApplicationOriginationTestHelper.createParty(new Map<String,Id>{'accountId' =>accountObj.id ,
                                                                                                      'contactId' => sAContact.id,
                                                                                                      'partyTypeId' => sAPartyType.id,
                                                                                                      'applicationId' => applicationList[0].id});

        Database.insert(sAPartyObj,true);
        
        userObj = [SELECT Id,Account.ParentId FROM User WHERE userName='tony.stark@yopmail.com'];

        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'clcommon__Contact__r.Id'=> coBorrowerContact[0].id,
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'clcommon__Account__r.Id'=> coBorrowerAccount[0].id,
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'clcommon__Account__r.genesis__Business_Information__r.Id'=> coBorrowerAccount[0].genesis__Business_Information__c,
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].genesis__Account__c,
                                                                'Year_Began_Farming__c' => '1999',
                                                                'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                'Work_Number__c' => '2328452475',
                                                                'Home_Number__c' => '2424952947',
                                                                'Phone' => '1782548528',
                                                                'clcommon__Email__c' => 'test.cfa@yopmail.com',
                                                                'Billing_County__c' => 'Philadelphia County',
                                                                'BillingPostalCode' => '90339',
                                                                'BillingState' => 'PA',
                                                                'BillingCity' => 'Philadelphia',
                                                                'BillingStreet' => 'Kelly Drive'
                                                            };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccount[0].genesis__Business_Information__c,
                                                                    'genesis__Total_Liabilities__c' => '412333',
                                                                    'genesis__Total_Assets__c' => '456000',
                                                                    'Gross_Farm_Income__c' => '76000'
                                                                };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].genesis__Contact__c,
                                                                'Email' => 'anirbandas1234321@mailinator.com',
                                                                'Birthdate' => '1966-01-31',
                                                                'genesis__SSN__c' => '324242424',
                                                                'MobilePhone' => '4342343432',
                                                                'Mailing_County__c' => 'West Bengal',
                                                                'MailingPostalCode' => '70011',
                                                                'MailingState' => 'AL',
                                                                'MailingCity' => 'Kolkata',
                                                                'MailingStreet' => 'S.S. Temple Road',
                                                                'Confirm_SSN__c' => '324242424',
                                                                'LastName' => 'Sharma',
                                                                'FirstName' => 'Abhishake',
                                                                'clcommon__Marital_Status__c'=>'Married'
                                                            };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    }

    /**
    * @description test to create a sole prop application for a new applicant
    * @author Rakesh Saraf | 12-16-2024 
    **/
    @isTest
    private static void testCreateIndivudualSolePropTypeApplicationForNewApplicant() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,genesis__Account__c,genesis__Contact__c FROM genesis__Applications__c WHERE Internal_Reference_Code__c = 'testApp001' LIMIT 1];
        List<Account> borrowerAccount = [Select Id,genesis__Business_Information__c From Account Where Id =: applicationList[0].genesis__Account__c LIMIT 1];
        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME LIMIT 1];
        List<Account> coBorrowerAccount = [SELECT Id,genesis__Business_Information__c FROM Account Where Id =: partyList[0].clcommon__Account__c Limit 1];
        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];
        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'clcommon__Contact__r.Id'=> coBorrowerContact[0].id,
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'clcommon__Account__r.Id'=> coBorrowerAccount[0].id,
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'clcommon__Account__r.genesis__Business_Information__r.Id'=> coBorrowerAccount[0].genesis__Business_Information__c,
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Account__c,
                                                                    'Year_Began_Farming__c' => '1999',
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'Work_Number__c' => '2328452475',
                                                                    'Home_Number__c' => '2424952947',
                                                                    'Phone' => '1782548528',
                                                                    'clcommon__Email__c' => 'test.cfa@yopmail.com',
                                                                    'Billing_County__c' => 'Philadelphia County',
                                                                    'BillingPostalCode' => '90339',
                                                                    'BillingState' => 'PA',
                                                                    'BillingCity' => 'Philadelphia',
                                                                    'BillingStreet' => 'Kelly Drive'
                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccount[0].genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'Gross_Farm_Income__c' => '76000'
                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].genesis__Contact__c,
                                                                'Email' => 'anirbandas1234321@mailinator.com',
                                                                'Birthdate' => '1966-01-31',
                                                                'genesis__SSN__c' => '324242424',
                                                                'MobilePhone' => '4342343432',
                                                                'Mailing_County__c' => 'West Bengal',
                                                                'MailingPostalCode' => '70011',
                                                                'MailingState' => 'AL',
                                                                'MailingCity' => 'Kolkata',
                                                                'MailingStreet' => 'S.S. Temple Road',
                                                                'Confirm_SSN__c' => '324242424',
                                                                'LastName' => 'Sharma',
                                                                'FirstName' => 'Abhishake',
                                                                'clcommon__Marital_Status__c'=>'Married'
                                                            };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    }


    /**
    * @description test a new application for a corporation with a  new account
    * @author Rakesh Saraf | 12-16-2024 
    **/
    @isTest
    private static void testCorporationWithNewAccount() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,genesis__Account__c,genesis__Contact__c FROM genesis__Applications__c WHERE Internal_Reference_Code__c = 'testApp002' LIMIT 1];
        List<Account> borrowerAccount = [Select Id,genesis__Business_Information__c From Account Where Id =: applicationList[0].genesis__Account__c LIMIT 1];
        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME AND genesis__Application__c=:applicationList[0].id LIMIT 1];
        List<Account> coBorrowerAccount = [SELECT Id,genesis__Business_Information__c FROM Account Where Id =: partyList[0].clcommon__Account__c Limit 1];
        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];
        
        
        legalEntityObj = getLegalEntityList('Corporation');
        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'clcommon__Contact__r.Id'=> coBorrowerContact[0].id,
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'clcommon__Account__r.Id'=> coBorrowerAccount[0].id,
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'clcommon__Account__r.genesis__Business_Information__r.Id'=> coBorrowerAccount[0].genesis__Business_Information__c,
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => accountObj.Id,
                                                                    'Year_Began_Farming__c' => '1999',
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'Name' => 'TestAccount12345',
                                                                    'Work_Number__c' => '2328452475',
                                                                    'Home_Number__c' => '2424952947',
                                                                    'Phone' => '1782548528',
                                                                    'clcommon__Email__c' => 'test.cfa@yopmail.com',
                                                                    'Billing_County__c' => 'Philadelphia County',
                                                                    'BillingPostalCode' => '90339',
                                                                    'BillingState' => 'PA',
                                                                    'BillingCity' => 'Philadelphia',
                                                                    'BillingStreet' => 'Kelly Drive'
                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccount[0].genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765',
                                                                        'Gross_Farm_Income__c' => '76000'
                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].genesis__Contact__c,
                                                                'Email' => 'anirbandas1234321@mailinator.com',
                                                                'Birthdate' => '1966-01-31',
                                                                'genesis__SSN__c' => '324242424',
                                                                'MobilePhone' => '4342343432',
                                                                'Mailing_County__c' => 'West Bengal',
                                                                'MailingPostalCode' => '70011',
                                                                'MailingState' => 'AL',
                                                                'MailingCity' => 'Kolkata',
                                                                'MailingStreet' => 'S.S. Temple Road',
                                                                'Confirm_SSN__c' => '324242424',
                                                                'LastName' => 'Sharma',
                                                                'FirstName' => 'Abhishake'
                                                            };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    }
    
    /**
    * @description testSolePropWithNewContactAndAccount
    * @author Rakesh Saraf | 12-16-2024 
    **/
    @isTest
    private static void testSolePropWithNewContactAndAccount() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,genesis__Account__c,genesis__Contact__c FROM genesis__Applications__c WHERE Internal_Reference_Code__c = 'testApp001' LIMIT 1];
        List<Account> borrowerAccount = [Select Id,genesis__Business_Information__c From Account Where Id =: applicationList[0].genesis__Account__c LIMIT 1];
        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME LIMIT 1];
        List<Account> coBorrowerAccount = [SELECT Id,genesis__Business_Information__c FROM Account Where Id =: partyList[0].clcommon__Account__c Limit 1];
        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];

        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');
       
        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();

        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'clcommon__Contact__r.Id'=> coBorrowerContact[0].id,
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'clcommon__Account__r.Id'=> coBorrowerAccount[0].id,
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'clcommon__Account__r.genesis__Business_Information__r.Id'=> coBorrowerAccount[0].genesis__Business_Information__c,
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Account__c,
                                                                    'Year_Began_Farming__c' => '',
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'Name' => 'TestAccount12345',
                                                                    'Work_Number__c' => '2328452475',
                                                                    'Home_Number__c' => '2424952947',
                                                                    'Phone' => '1782548528',
                                                                    'clcommon__Email__c' => 'test.cfa@yopmail.com',
                                                                    'Billing_County__c' => 'Philadelphia County',
                                                                    'BillingPostalCode' => '90339',
                                                                    'BillingState' => 'PA',
                                                                    'BillingCity' => 'Philadelphia',
                                                                    'BillingStreet' => 'Kelly Drive'
                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccount[0].genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765',
                                                                        'Gross_Farm_Income__c' => ''
                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].genesis__Contact__c,
                                                                'Email' => 'anirbandas1234321@mailinator.com',
                                                                'Birthdate' => '1966-01-31',
                                                                'genesis__SSN__c' => '780780780',
                                                                'MobilePhone' => '780780780',
                                                                'Mailing_County__c' => 'West Bengal',
                                                                'MailingPostalCode' => '70011',
                                                                'MailingState' => 'AL',
                                                                'MailingCity' => 'Kolkata',
                                                                'MailingStreet' => 'S.S. Temple Road',
                                                                'Confirm_SSN__c' => '780780780',
                                                                'LastName' => 'Sharma',
                                                                'FirstName' => 'Abhishake',
                                                                'AccountId' => applicationList[0].genesis__Account__c,
                                                                'clcommon__Marital_Status__c'=>'Married'
                                                            };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    }

    
    /**
    * @description test method for createPrimaryApplicant
    * @author Rakesh Saraf | 12-21-2024 
    **/
    @isTest
    private static void testApplicationForNewCorporationApplicant() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,genesis__Account__c,genesis__Contact__c FROM genesis__Applications__c WHERE Internal_Reference_Code__c = 'testApp002' LIMIT 1];
        List<Account> borrowerAccount = [Select Id,genesis__Business_Information__c From Account Where Id =: applicationList[0].genesis__Account__c LIMIT 1];
        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME AND genesis__Application__c=:applicationList[0].id LIMIT 1];
        List<Account> coBorrowerAccount = [SELECT Id,genesis__Business_Information__c FROM Account Where Id =: partyList[0].clcommon__Account__c Limit 1];
        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];
        

        legalEntityObj = getLegalEntityList('Corporation');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        accountObj.Is_Individual__c = false;
        Database.update(accountObj,true);

        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                            'Id' => applicationList[0].Id,
                                                            'Sales_Agent__c' => accountObj.Id,
                                                            'genesis__Loan_Amount__c' => '100000',
                                                            'Internal_Reference_Code__c' => 'testApp002'
                                                        };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'clcommon__Contact__r.Id'=> coBorrowerContact[0].id,
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'clcommon__Account__r.Id'=> coBorrowerAccount[0].id,
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'clcommon__Account__r.genesis__Business_Information__r.Id'=> coBorrowerAccount[0].genesis__Business_Information__c,
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].genesis__Account__c,
                                                                'Year_Began_Farming__c' => '',
                                                                'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                'Name' => 'TestAccount12345',
                                                                'Work_Number__c' => '2328452475',
                                                                'Home_Number__c' => '2424952947',
                                                                'Phone' => '1782548528',
                                                                'clcommon__Email__c' => 'test.cfa@yopmail.com',
                                                                'Billing_County__c' => 'Philadelphia County',
                                                                'BillingPostalCode' => '90339',
                                                                'BillingState' => 'PA',
                                                                'BillingCity' => 'Philadelphia',
                                                                'BillingStreet' => 'Kelly Drive'
                                                            };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccount[0].genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765',
                                                                        'Gross_Farm_Income__c' => '76000'
                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].genesis__Contact__c,
                                                                'Email' => 'anirbandas1234321@mailinator.com',
                                                                'Birthdate' => '1966-01-31',
                                                                'genesis__SSN__c' => '324242424',
                                                                'MobilePhone' => '4342343432',
                                                                'Mailing_County__c' => 'West Bengal',
                                                                'MailingPostalCode' => '70011',
                                                                'MailingState' => 'AL',
                                                                'MailingCity' => 'Kolkata',
                                                                'MailingStreet' => 'S.S. Temple Road',
                                                                'Confirm_SSN__c' => '324242424',
                                                                'LastName' => 'Sharma',
                                                                'FirstName' => 'Abhishake'
                                                            };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    } 

    /**
    * @description test case where application record is not sent as a response from the portal
    * @author Rakesh Saraf | 12-21-2024 
    **/
    @isTest
    private static void testWithoutApplicationRecord() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        User userObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,genesis__Account__c,genesis__Contact__c FROM genesis__Applications__c LIMIT 1];
        List<Account> borrowerAccount = [Select Id,genesis__Business_Information__c From Account Where Id =: applicationList[0].genesis__Account__c LIMIT 1];
        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME LIMIT 1];
        List<Account> coBorrowerAccount = [SELECT Id,genesis__Business_Information__c FROM Account Where Id =: partyList[0].clcommon__Account__c Limit 1];
        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];
        
        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'clcommon__Contact__r.Id'=> coBorrowerContact[0].id,
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'clcommon__Account__r.Id'=> coBorrowerAccount[0].id,
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'clcommon__Account__r.genesis__Business_Information__r.Id'=> coBorrowerAccount[0].genesis__Business_Information__c,
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Account__c,
                                                                    'Year_Began_Farming__c' => '1999',
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'Name' => 'TestAccount12345',
                                                                    'Work_Number__c' => '2328452475',
                                                                    'Home_Number__c' => '2424952947',
                                                                    'Phone' => '1782548528',
                                                                    'clcommon__Email__c' => 'test.cfa@yopmail.com',
                                                                    'Billing_County__c' => 'Philadelphia County',
                                                                    'BillingPostalCode' => '90339',
                                                                    'BillingState' => 'PA',
                                                                    'BillingCity' => 'Philadelphia',
                                                                    'BillingStreet' => 'Kelly Drive'
                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccount[0].genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765',
                                                                        'Gross_Farm_Income__c' => ''
                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].genesis__Contact__c,
                                                                'Email' => 'anirbandas1234321@mailinator.com',
                                                                'Birthdate' => '1966-01-31',
                                                                'genesis__SSN__c' => '324242424',
                                                                'MobilePhone' => '4342343432',
                                                                'Mailing_County__c' => 'West Bengal',
                                                                'MailingPostalCode' => '70011',
                                                                'MailingState' => 'AL',
                                                                'MailingCity' => 'Kolkata',
                                                                'MailingStreet' => 'S.S. Temple Road',
                                                                'Confirm_SSN__c' => '324242424',
                                                                'LastName' => 'Sharma',
                                                                'FirstName' => 'Abhishake'
                                                            };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created');
            Test.stopTest();
        }
    }

    
    /**
    * @description test for a new application for a dba with the coop type as GMK
    * @author Rakesh Saraf | 12-21-2024 
    **/
    @isTest
    private static void testCreateApplicationForNewDBAApplicantGMK() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        Account dealerAccount;
        User userObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,genesis__Account__c,genesis__Contact__c FROM genesis__Applications__c WHERE Internal_Reference_Code__c = 'testApp002' LIMIT 1];
        List<Account> borrowerAccount = [Select Id,genesis__Business_Information__c From Account Where Id =: applicationList[0].genesis__Account__c LIMIT 1];
        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME AND genesis__Application__c=:applicationList[0].id LIMIT 1];
        List<Account> coBorrowerAccount = [SELECT Id,genesis__Business_Information__c FROM Account Where Id =: partyList[0].clcommon__Account__c Limit 1];
        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];

        legalEntityObj = getLegalEntityList(PortalConstants.INDIVIDUAL_ENTITY);

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        accountObj.Is_Individual__c = false;
        Database.update(accountObj,true);

        dealerAccount = ApplicationOriginationTestHelper.getDealerAccoount();
 
        dealerAccount.Coop_type__c = 'Growmark';

        Database.update(dealerAccount,true);

        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'clcommon__Contact__r.Id'=> coBorrowerContact[0].id,
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'clcommon__Account__r.Id'=> coBorrowerAccount[0].id,
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'clcommon__Account__r.genesis__Business_Information__r.Id'=> coBorrowerAccount[0].genesis__Business_Information__c,
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Account__c,
                                                                    'Year_Began_Farming__c' => '1999',
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'Name' => 'TestAccount12345',
                                                                    'Work_Number__c' => '2328452475',
                                                                    'Home_Number__c' => '2424952947',
                                                                    'Phone' => '1782548528',
                                                                    'clcommon__Email__c' => 'test.cfa@yopmail.com',
                                                                    'Billing_County__c' => 'Philadelphia County',
                                                                    'BillingPostalCode' => '90339',
                                                                    'BillingState' => 'PA',
                                                                    'BillingCity' => 'Philadelphia',
                                                                    'BillingStreet' => 'Kelly Drive'
                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccount[0].genesis__Business_Information__c,
                                                                    'genesis__Total_Liabilities__c' => '412333',
                                                                    'genesis__Total_Assets__c' => '456000',
                                                                    'genesis__Tax_Identification_Number__c' => '5678765',
                                                                    'Gross_Farm_Income__c' => '76000'
                                                                };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].genesis__Contact__c,
                                                                'Email' => 'anirbandas1234321@mailinator.com',
                                                                'Birthdate' => '1966-01-31',
                                                                'genesis__SSN__c' => '324242424',
                                                                'MobilePhone' => '4342343432',
                                                                'Mailing_County__c' => 'West Bengal',
                                                                'MailingPostalCode' => '70011',
                                                                'MailingState' => 'AL',
                                                                'MailingCity' => 'Kolkata',
                                                                'MailingStreet' => 'S.S. Temple Road',
                                                                'Confirm_SSN__c' => '324242424',
                                                                'LastName' => 'Sharma',
                                                                'FirstName' => 'Abhishake'
                                                            };

        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    } 
    
    /**
    * @description test for application where the applicant is an existing applicant
    * @author Rakesh Saraf | 12-21-2024 
    **/
    @isTest
    private static void testCreateAppForExistingIndividualApplicant() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        
        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();

        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            genesis__CL_Product__c,
                                                            genesis__CL_Purpose__c,
                                                            genesis__Account__c,
                                                            genesis__Contact__c,
                                                            ERP_Id__c,
                                                            genesis__Status__c 
                                                        FROM genesis__Applications__c
                                                        WHERE Internal_Reference_Code__c = 'testApp001'];

        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME AND genesis__Application__c=:applicationList[0].id LIMIT 1];
        List<Account> coBorrowerAccount = [SELECT Id,genesis__Business_Information__c FROM Account Where Id =: partyList[0].clcommon__Account__c Limit 1];
        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];

        applicationList[0].ERP_Id__c = 'Test1234';
        applicationList[0].genesis__Status__c = 'ACTIVE';
        Database.update(applicationList,true);
    
        List<Account> borrowerAccountList = [SELECT Id,
                                                genesis__Business_Information__c 
                                            FROM Account 
                                            WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        
        borrowerAccountObj = borrowerAccountList[0];    
        
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'clcommon__Contact__r.Id'=> coBorrowerContact[0].id,
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'clcommon__Account__r.Id'=> coBorrowerAccount[0].id,
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'clcommon__Account__r.genesis__Business_Information__r.Id'=> coBorrowerAccount[0].genesis__Business_Information__c,
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.Id,
                                                                    'Year_Began_Farming__c' => '1999',
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'Name' => 'TestAccount12345',
                                                                    'Work_Number__c' => '2328452475',
                                                                    'Home_Number__c' => '2424952947',
                                                                    'Phone' => '1782548528',
                                                                    'clcommon__Email__c' => 'test.cfa@yopmail.com',
                                                                    'Billing_County__c' => 'Philadelphia County',
                                                                    'BillingPostalCode' => '90339',
                                                                    'BillingState' => 'PA',
                                                                    'BillingCity' => 'Philadelphia',
                                                                    'BillingStreet' => 'Kelly Drive'
        };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765',
                                                                        'Gross_Farm_Income__c' => '76000'
                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].genesis__Contact__c,
                                                                'Email' => 'anirbandas1234321@mailinator.com',
                                                                'Birthdate' => '1966-01-31',
                                                                'genesis__SSN__c' => '324242424',
                                                                'MobilePhone' => '4342343432',
                                                                'Mailing_County__c' => 'West Bengal',
                                                                'MailingPostalCode' => '70011',
                                                                'MailingState' => 'AL',
                                                                'MailingCity' => 'Kolkata',
                                                                'MailingStreet' => 'S.S. Temple Road',
                                                                'Confirm_SSN__c' => '324242424',
                                                                'LastName' => 'Sharma',
                                                                'FirstName' => 'Abhishake',
                                                                'clcommon__Marital_Status__c'=>'Married'
                                                            };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    } 

    /**
    * @description test for save and exit application
    * @author Rakesh Saraf | 12-21-2024 
    **/
    @isTest
    private static void testSaveAndExitApplication() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;

        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();

        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__CL_Product__c,
                                                                genesis__CL_Purpose__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c 
                                                            FROM genesis__Applications__c
                                                            WHERE Internal_Reference_Code__c = 'testApp001'];

        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME AND genesis__Application__c=:applicationList[0].id LIMIT 1];
        List<Account> coBorrowerAccount = [SELECT Id,genesis__Business_Information__c FROM Account Where Id =: partyList[0].clcommon__Account__c Limit 1];
        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];
        

        List<Account> borrowerAccountList = [SELECT Id,
                                                genesis__Business_Information__c 
                                            FROM Account 
                                            WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
         
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'clcommon__Contact__r.Id'=> coBorrowerContact[0].id,
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'clcommon__Account__r.Id'=> coBorrowerAccount[0].id,
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'clcommon__Account__r.genesis__Business_Information__r.Id'=> coBorrowerAccount[0].genesis__Business_Information__c,
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountList[0].Id,
                                                                    'Year_Began_Farming__c' => '1999',
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'Name' => 'TestAccount12345',
                                                                    'Work_Number__c' => '2328452475',
                                                                    'Home_Number__c' => '2424952947',
                                                                    'Phone' => '1782548528',
                                                                    'clcommon__Email__c' => 'test.cfa@yopmail.com',
                                                                    'Billing_County__c' => 'Philadelphia County',
                                                                    'BillingPostalCode' => '90339',
                                                                    'BillingState' => 'PA',
                                                                    'BillingCity' => 'Philadelphia',
                                                                    'BillingStreet' => 'Kelly Drive'
                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountList[0].genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765',
                                                                        'Gross_Farm_Income__c' => '76000'
                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Contact__c,
                                                                    'Email' => 'anirbandas1234321@mailinator.com',
                                                                    'Birthdate' => '1966-01-31',
                                                                    'genesis__SSN__c' => '324242424',
                                                                    'MobilePhone' => '4342343432',
                                                                    'Mailing_County__c' => 'West Bengal',
                                                                    'MailingPostalCode' => '70011',
                                                                    'MailingState' => 'AL',
                                                                    'MailingCity' => 'Kolkata',
                                                                    'MailingStreet' => 'S.S. Temple Road',
                                                                    'Confirm_SSN__c' => '324242424',
                                                                    'LastName' => 'Sharma',
                                                                    'FirstName' => 'Abhishake'
                                                                };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndExit');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    }
   

    /**
    * @description test case where the application is evergreen of an individual sole prop
    * @author Rakesh Saraf | 12-21-2024 
    **/
    @isTest
    private static void testForEvergreenTrueIndivudualApplication() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;

        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');
    
        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                        genesis__CL_Product__c,
                                                        genesis__CL_Purpose__c,genesis__Account__c,
                                                        genesis__Contact__c,
                                                        Is_Evergreen__c 
                                                    FROM genesis__Applications__c
                                                    WHERE Internal_Reference_Code__c = 'testApp001'];
        
        applicationList[0].Is_Evergreen__c = true;      
        Database.update(applicationList,true);

        List<Account> borrowerAccountList = [SELECT Id,genesis__Business_Information__c,Name 
                                                FROM Account 
                                                WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];

        Map<String,Object> applicationMap = new Map<String,Object>{
                                                            'Id' => applicationList[0].Id,
                                                            'Sales_Agent__c' => accountObj.Id,
                                                            'genesis__Loan_Amount__c' => '100000',
                                                            'Internal_Reference_Code__c' => '43242341234'
                                                        };
        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountList[0].Id,
                                                                    'Year_Began_Farming__c' => '1999',
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'Name' => 'TestAccount12345',
                                                                    'Work_Number__c' => '2328452475',
                                                                    'Home_Number__c' => '2424952947',
                                                                    'Phone' => '1782548528',
                                                                    'clcommon__Email__c' => 'test.cfa@yopmail.com',
                                                                    'Billing_County__c' => 'Philadelphia County',
                                                                    'BillingPostalCode' => '90339',
                                                                    'BillingState' => 'PA',
                                                                    'BillingCity' => 'Philadelphia',
                                                                    'BillingStreet' => 'Kelly Drive'
        };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountList[0].genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765',
                                                                        'Gross_Farm_Income__c' => '76000'
                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Contact__c,
                                                                    'Email' => 'anirbandas1234321@mailinator.com',
                                                                    'Birthdate' => '1966-01-31',
                                                                    'genesis__SSN__c' => '324242424',
                                                                    'MobilePhone' => '4342343432',
                                                                    'Mailing_County__c' => 'West Bengal',
                                                                    'MailingPostalCode' => '70011',
                                                                    'MailingState' => 'AL',
                                                                    'MailingCity' => 'Kolkata',
                                                                    'MailingStreet' => 'S.S. Temple Road',
                                                                    'Confirm_SSN__c' => '324242424',
                                                                    'LastName' => 'Sharma',
                                                                    'FirstName' => 'Abhishake',
                                                                    'Mailing_County__c' => 'uiuytg'
                                                                };
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    }

    /**
    * @description test case where the application is evergreen of a corporation
    * @author Rakesh Saraf | 12-21-2024 
    **/
    @isTest
    private static void testForEvergreenTrueCorporationApplication() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList('Corporation');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                        genesis__CL_Product__c,
                                                        genesis__CL_Purpose__c,genesis__Account__c,
                                                        genesis__Contact__c,
                                                        Is_Evergreen__c 
                                                    FROM genesis__Applications__c
                                                    WHERE Internal_Reference_Code__c = 'testApp002'];

        applicationList[0].Is_Evergreen__c = true;
       
        Database.update(applicationList,true);

        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                            FROM Account 
                                            WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
                                            
        borrowerAccountObj = borrowerAccountList[0];                
                                                                  
        List<clcommon__Party__c> partyList = [SELECT id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName FROM clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.Id,
                                                                    'Year_Began_Farming__c' => '1999',
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'Name' => borrowerAccountObj.Name,
                                                                    'BillingState' => borrowerAccountObj.BillingState,
                                                                    'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                                    'BillingCity' => borrowerAccountObj.BillingCity,
                                                                    'BillingPostalCode' => '70011',
                                                                    'Billing_County__c' => 'uiuytg',
                                                                    'Work_Number__c' => borrowerAccountObj.Work_Number__c,
                                                                    'Home_Number__c' => '2424952947',
                                                                    'Phone' => '1782548528'
                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765',
                                                                        'Gross_Farm_Income__c' => '76000'
                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].genesis__Contact__c,
                                                                'Email' => 'anirbandas1234321@mailinator.com',
                                                                'Birthdate' => '1966-01-31',
                                                                'genesis__SSN__c' => '324242424',
                                                                'MobilePhone' => '4342343432',
                                                                'Mailing_County__c' => 'West Bengal',
                                                                'MailingPostalCode' => '70011',
                                                                'MailingState' => 'AL',
                                                                'MailingCity' => 'Kolkata',
                                                                'MailingStreet' => 'S.S. Temple Road',
                                                                'Confirm_SSN__c' => '324242424',
                                                                'LastName' => 'Sharma',
                                                                'FirstName' => 'Abhishake'
                                                            };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }

    /**
    * @description test for evergreen application for a dba grower 
    * @author Rakesh Saraf | 12-21-2024 
    **/
    @isTest
    private static void testForEvergreenTrueDBAApplication() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList(PortalConstants.INDIVIDUAL_ENTITY);

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                        genesis__CL_Product__c,
                                                        genesis__CL_Purpose__c,genesis__Account__c,
                                                        genesis__Contact__c,
                                                        Is_Evergreen__c 
                                                    FROM genesis__Applications__c
                                                    WHERE Internal_Reference_Code__c = 'testApp002'];
        
        applicationList[0].Is_Evergreen__c = true;
        
        Database.update(applicationList,true);
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                    
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                'Id' => borrowerAccountObj.Id,
                                                                'Year_Began_Farming__c' => '1999',
                                                                'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                'Name' => borrowerAccountObj.Name,
                                                                'BillingState' => borrowerAccountObj.BillingState,
                                                                'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                                'BillingCity' => borrowerAccountObj.BillingCity,
                                                                'BillingPostalCode' => '70011',
                                                                'Billing_County__c' => 'uiuytg',
                                                                'Work_Number__c' => borrowerAccountObj.Work_Number__c
                                                            };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765',
                                                                        'Gross_Farm_Income__c' => '76000'
                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Contact__c,
                                                                    'Email' => 'anirbandas1234321@mailinator.com',
                                                                    'Birthdate' => '1966-01-31',
                                                                    'genesis__SSN__c' => '324242424',
                                                                    'MobilePhone' => '4342343432',
                                                                    'Mailing_County__c' => 'West Bengal',
                                                                    'MailingPostalCode' => '70011',
                                                                    'MailingState' => 'AL',
                                                                    'MailingCity' => 'Kolkata',
                                                                    'MailingStreet' => 'S.S. Temple Road',
                                                                    'Confirm_SSN__c' => '324242424',
                                                                    'LastName' => 'Sharma',
                                                                    'FirstName' => 'Abhishake'
                                                                };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }

    /**
    * @description test case for missing mailing street
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingMailingStreet() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                        genesis__CL_Product__c,
                                                        genesis__CL_Purpose__c,genesis__Account__c,
                                                        genesis__Contact__c,
                                                        Is_Evergreen__c 
                                                    FROM genesis__Applications__c
                                                    WHERE Internal_Reference_Code__c = 'testApp001'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                    
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.Id,
                                                                    'Year_Began_Farming__c' => '1999',
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'Name' => borrowerAccountObj.Name,
                                                                    'BillingState' => borrowerAccountObj.BillingState,
                                                                    'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                                    'BillingCity' => borrowerAccountObj.BillingCity,
                                                                    'BillingPostalCode' => '70011',
                                                                    'Billing_County__c' => 'uiuytg',
                                                                    'Work_Number__c' => borrowerAccountObj.Work_Number__c

                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765',
                                                                        'Gross_Farm_Income__c' => '76000'

                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].genesis__Contact__c,
                                                                'Email' => 'anirbandas1234321@mailinator.com',
                                                                'Birthdate' => '1966-01-31',
                                                                'genesis__SSN__c' => '324242424',
                                                                'MobilePhone' => '4342343432',
                                                                'Mailing_County__c' => 'West Bengal',
                                                                'MailingPostalCode' => '70011',
                                                                'MailingState' => 'AL',
                                                                'MailingCity' => 'Kolkata',
                                                                'Confirm_SSN__c' => '324242424',
                                                                'LastName' => 'Sharma',
                                                                'FirstName' => 'Abhisekh'
                                                            };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }

    /**
    * @description test for missing mailing city case
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingMailingCity() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                        genesis__CL_Product__c,
                                                        genesis__CL_Purpose__c,genesis__Account__c,
                                                        genesis__Contact__c,
                                                        Is_Evergreen__c 
                                                    FROM genesis__Applications__c
                                                    WHERE Internal_Reference_Code__c = 'testApp001'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                            'Id' => borrowerAccountObj.Id,
                                                            'Year_Began_Farming__c' => '1999',
                                                            'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                            'Name' => borrowerAccountObj.Name,
                                                            'BillingState' => borrowerAccountObj.BillingState,
                                                            'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                            'BillingCity' => borrowerAccountObj.BillingCity,
                                                            'BillingPostalCode' => '70011',
                                                            'Billing_County__c' => 'uiuytg',
                                                            'Work_Number__c' => borrowerAccountObj.Work_Number__c

                                                        };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765',
                                                                        'Gross_Farm_Income__c' => '76000'

                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].genesis__Contact__c,
                                                                'Email' => 'anirbandas1234321@mailinator.com',
                                                                'Birthdate' => '1966-01-31',
                                                                'genesis__SSN__c' => '324242424',
                                                                'MobilePhone' => '4342343432',
                                                                'Mailing_County__c' => 'West Bengal',
                                                                'MailingPostalCode' => '70011',
                                                                'MailingState' => 'AL',
                                                                'MailingStreet' => 'S.S. Temple Road',
                                                                'Confirm_SSN__c' => '324242424',
                                                                'LastName' => 'Sharma',
                                                                'FirstName' => 'Abhisekh'
                                                            };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }
    
    /**
    * @description test for missing state 
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingMailingState() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                        genesis__CL_Product__c,
                                                        genesis__CL_Purpose__c,genesis__Account__c,
                                                        genesis__Contact__c,
                                                        Is_Evergreen__c 
                                                    FROM genesis__Applications__c
                                                    WHERE Internal_Reference_Code__c = 'testApp001'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                            'Id' => applicationList[0].Id,
                                                            'Sales_Agent__c' => accountObj.Id,
                                                            'genesis__Loan_Amount__c' => '100000',
                                                            'Internal_Reference_Code__c' => '43242341234'
                                                        };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                'Id' => borrowerAccountObj.Id,
                                                                'Year_Began_Farming__c' => '1999',
                                                                'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                'Name' => borrowerAccountObj.Name,
                                                                'BillingState' => borrowerAccountObj.BillingState,
                                                                'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                                'BillingCity' => borrowerAccountObj.BillingCity,
                                                                'BillingPostalCode' => '70011',
                                                                'Billing_County__c' => 'uiuytg',
                                                                'Work_Number__c' => borrowerAccountObj.Work_Number__c

                                                            };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765',
                                                                        'Gross_Farm_Income__c' => '76000'

                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Contact__c,
                                                                    'Email' => 'anirbandas1234321@mailinator.com',
                                                                    'Birthdate' => '1966-01-31',
                                                                    'genesis__SSN__c' => '324242424',
                                                                    'MobilePhone' => '4342343432',
                                                                    'Mailing_County__c' => 'West Bengal',
                                                                    'MailingPostalCode' => '70011',
                                                                    'MailingCity' => 'Kolkata',
                                                                    'MailingStreet' => 'S.S. Temple Road',
                                                                    'Confirm_SSN__c' => '324242424',
                                                                    'LastName' => 'Sharma',
                                                                    'FirstName' => 'Abhisekh'
                                                                };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }
    
    /**
    * @description test for missing mailing county
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingMailingCounty() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                        genesis__CL_Product__c,
                                                        genesis__CL_Purpose__c,genesis__Account__c,
                                                        genesis__Contact__c,
                                                        Is_Evergreen__c 
                                                    FROM genesis__Applications__c
                                                    WHERE Internal_Reference_Code__c = 'testApp001'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                'Id' => borrowerAccountObj.Id,
                                                                'Year_Began_Farming__c' => '1999',
                                                                'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                'Name' => borrowerAccountObj.Name,
                                                                'BillingState' => borrowerAccountObj.BillingState,
                                                                'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                                'BillingCity' => borrowerAccountObj.BillingCity,
                                                                'BillingPostalCode' => '70011',
                                                                'Billing_County__c' => 'uiuytg',
                                                                'Work_Number__c' => borrowerAccountObj.Work_Number__c

                                                            };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                    'genesis__Total_Liabilities__c' => '412333',
                                                                    'genesis__Total_Assets__c' => '456000',
                                                                    'genesis__Tax_Identification_Number__c' => '5678765',
                                                                    'Gross_Farm_Income__c' => '76000'

                                                                };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Contact__c,
                                                                    'Email' => 'anirbandas1234321@mailinator.com',
                                                                    'Birthdate' => '1966-01-31',
                                                                    'genesis__SSN__c' => '324242424',
                                                                    'MobilePhone' => '4342343432',
                                                                    'MailingPostalCode' => '70011',
                                                                    'MailingState' => 'AL',
                                                                    'MailingCity' => 'Kolkata',
                                                                    'MailingStreet' => 'S.S. Temple Road',
                                                                    'Confirm_SSN__c' => '324242424',
                                                                    'LastName' => 'Sharma',
                                                                    'FirstName' => 'Abhisekh'
                                                                };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }
    
    /**
    * @description test for missing mailing postal code
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingMailingPostalCode() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                        genesis__CL_Product__c,
                                                        genesis__CL_Purpose__c,genesis__Account__c,
                                                        genesis__Contact__c,
                                                        Is_Evergreen__c 
                                                    FROM genesis__Applications__c
                                                    WHERE Internal_Reference_Code__c = 'testApp001'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.Id,
                                                                    'Year_Began_Farming__c' => '1999',
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'Name' => borrowerAccountObj.Name,
                                                                    'BillingState' => borrowerAccountObj.BillingState,
                                                                    'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                                    'BillingCity' => borrowerAccountObj.BillingCity,
                                                                    'BillingPostalCode' => '70011',
                                                                    'Billing_County__c' => 'uiuytg',
                                                                    'Work_Number__c' => borrowerAccountObj.Work_Number__c

                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765',
                                                                        'Gross_Farm_Income__c' => '76000'

                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].genesis__Contact__c,
                                                                'Email' => 'anirbandas1234321@mailinator.com',
                                                                'Birthdate' => '1966-01-31',
                                                                'genesis__SSN__c' => '324242424',
                                                                'MobilePhone' => '4342343432',
                                                                'Mailing_County__c' => 'West Bengal',
                                                                'MailingState' => 'AL',
                                                                'MailingCity' => 'Kolkata',
                                                                'MailingStreet' => 'S.S. Temple Road',
                                                                'Confirm_SSN__c' => '324242424',
                                                                'LastName' => 'Sharma',
                                                                'FirstName' => 'Abhisekh'
                                                            };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }
    
    /**
    * @description test  missing ssn
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingSSN() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                        genesis__CL_Product__c,
                                                        genesis__CL_Purpose__c,genesis__Account__c,
                                                        genesis__Contact__c,
                                                        Is_Evergreen__c 
                                                    FROM genesis__Applications__c
                                                    WHERE Internal_Reference_Code__c = 'testApp001'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];


       
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                            'Id' => applicationList[0].Id,
                                                            'Sales_Agent__c' => accountObj.Id,
                                                            'genesis__Loan_Amount__c' => '100000',
                                                            'Internal_Reference_Code__c' => '43242341234'
                                                        };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.Id,
                                                                    'Year_Began_Farming__c' => '1999',
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'Name' => borrowerAccountObj.Name,
                                                                    'BillingState' => borrowerAccountObj.BillingState,
                                                                    'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                                    'BillingCity' => borrowerAccountObj.BillingCity,
                                                                    'BillingPostalCode' => '70011',
                                                                    'Billing_County__c' => 'uiuytg',
                                                                    'Work_Number__c' => borrowerAccountObj.Work_Number__c

                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                    'genesis__Total_Liabilities__c' => '412333',
                                                                    'genesis__Total_Assets__c' => '456000',
                                                                    'genesis__Tax_Identification_Number__c' => '5678765',
                                                                    'Gross_Farm_Income__c' => '76000'

                                                                };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Contact__c,
                                                                    'Email' => 'anirbandas1234321@mailinator.com',
                                                                    'Birthdate' => '1966-01-31',
                                                                    'MobilePhone' => '4342343432',
                                                                    'Mailing_County__c' => 'West Bengal',
                                                                    'MailingPostalCode' => '70011',
                                                                    'MailingState' => 'AL',
                                                                    'MailingCity' => 'Kolkata',
                                                                    'MailingStreet' => 'S.S. Temple Road',
                                                                    'LastName' => 'Sharma',
                                                                    'FirstName' => 'Abhisekh'
                                                                };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }
    
    /**
    * @description test missing confirm ssn
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingConfirmSSN() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                        genesis__CL_Product__c,
                                                        genesis__CL_Purpose__c,genesis__Account__c,
                                                        genesis__Contact__c,
                                                        Is_Evergreen__c 
                                                    FROM genesis__Applications__c
                                                    WHERE Internal_Reference_Code__c = 'testApp001'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];
       
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.Id,
                                                                    'Year_Began_Farming__c' => '1999',
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'Name' => borrowerAccountObj.Name,
                                                                    'BillingState' => borrowerAccountObj.BillingState,
                                                                    'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                                    'BillingCity' => borrowerAccountObj.BillingCity,
                                                                    'BillingPostalCode' => '70011',
                                                                    'Billing_County__c' => 'uiuytg',
                                                                    'Work_Number__c' => borrowerAccountObj.Work_Number__c

                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__C,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765',
                                                                        'Gross_Farm_Income__c' => '76000'

                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Contact__c,
                                                                    'Email' => 'anirbandas1234321@mailinator.com',
                                                                    'Birthdate' => '1966-01-31',
                                                                    'MobilePhone' => '4342343432',
                                                                    'Mailing_County__c' => 'West Bengal',
                                                                    'MailingPostalCode' => '70011',
                                                                    'MailingState' => 'AL',
                                                                    'MailingCity' => 'Kolkata',
                                                                    'MailingStreet' => 'S.S. Temple Road',
                                                                    'LastName' => 'Sharma',
                                                                    'FirstName' => 'Abhisekh'
                                                                };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }
    
    /**
    * @description test for missing birthday date
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingBirthDate() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                        genesis__CL_Product__c,
                                                        genesis__CL_Purpose__c,genesis__Account__c,
                                                        genesis__Contact__c,
                                                        Is_Evergreen__c 
                                                    FROM genesis__Applications__c
                                                    WHERE Internal_Reference_Code__c = 'testApp001'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];
       
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.Id,
                                                                    'Year_Began_Farming__c' => '1999',
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'Name' => borrowerAccountObj.Name,
                                                                    'BillingState' => borrowerAccountObj.BillingState,
                                                                    'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                                    'BillingCity' => borrowerAccountObj.BillingCity,
                                                                    'BillingPostalCode' => '70011',
                                                                    'Billing_County__c' => 'uiuytg',
                                                                    'Work_Number__c' => borrowerAccountObj.Work_Number__c

                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__C,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765',
                                                                        'Gross_Farm_Income__c' => '76000'

                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Contact__c,
                                                                    'Email' => 'anirbandas1234321@mailinator.com',
                                                                    'genesis__SSN__c' => '324242424',
                                                                    'MobilePhone' => '4342343432',
                                                                    'Mailing_County__c' => 'West Bengal',
                                                                    'MailingPostalCode' => '70011',
                                                                    'MailingState' => 'AL',
                                                                    'MailingCity' => 'Kolkata',
                                                                    'MailingStreet' => 'S.S. Temple Road',
                                                                    'Confirm_SSN__c' => '324242424',
                                                                    'LastName' => 'Sharma',
                                                                    'FirstName' => 'Abhisekh'
                                                                };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }
    
    /**
    * @description test case where neither of the numbers have been entered
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingNumber() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                        genesis__CL_Product__c,
                                                        genesis__CL_Purpose__c,genesis__Account__c,
                                                        genesis__Contact__c,
                                                        Is_Evergreen__c 
                                                    FROM genesis__Applications__c
                                                    WHERE Internal_Reference_Code__c = 'testApp001'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                'Id' => borrowerAccountObj.Id,
                                                                'Year_Began_Farming__c' => '1999',
                                                                'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                'Name' => borrowerAccountObj.Name,
                                                                'BillingState' => borrowerAccountObj.BillingState,
                                                                'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                                'BillingCity' => borrowerAccountObj.BillingCity,
                                                                'BillingPostalCode' => '70011',
                                                                'Billing_County__c' => 'uiuytg',
                                                                'Work_Number__c' => borrowerAccountObj.Work_Number__c

                                                            };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                    'genesis__Total_Liabilities__c' => '412333',
                                                                    'genesis__Total_Assets__c' => '456000',
                                                                    'genesis__Tax_Identification_Number__c' => '5678765',
                                                                    'Gross_Farm_Income__c' => '76000'

                                                                };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].genesis__Contact__c,
                                                                'Email' => 'anirbandas1234321@mailinator.com',
                                                                'Birthdate' => '1966-01-31',
                                                                'genesis__SSN__c' => '324242424',
                                                                'Mailing_County__c' => 'West Bengal',
                                                                'MailingPostalCode' => '70011',
                                                                'MailingState' => 'AL',
                                                                'MailingCity' => 'Kolkata',
                                                                'MailingStreet' => 'S.S. Temple Road',
                                                                'Confirm_SSN__c' => '324242424',
                                                                'LastName' => 'Sharma',
                                                                'FirstName' => 'Abhisekh'
                                                            };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }
    
    /**
    * @description test case for missing first name
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingFirstName() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                        genesis__CL_Product__c,
                                                        genesis__CL_Purpose__c,genesis__Account__c,
                                                        genesis__Contact__c,
                                                        Is_Evergreen__c 
                                                    FROM genesis__Applications__c
                                                    WHERE Internal_Reference_Code__c = 'testApp001'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                'Id' => borrowerAccountObj.Id,
                                                                'Year_Began_Farming__c' => '1999',
                                                                'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                'Name' => borrowerAccountObj.Name,
                                                                'BillingState' => borrowerAccountObj.BillingState,
                                                                'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                                'BillingCity' => borrowerAccountObj.BillingCity,
                                                                'BillingPostalCode' => '70011',
                                                                'Billing_County__c' => 'uiuytg',
                                                                'Work_Number__c' => borrowerAccountObj.Work_Number__c

                                                            };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765',
                                                                        'Gross_Farm_Income__c' => '76000'

                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Contact__c,
                                                                    'Email' => 'anirbandas1234321@mailinator.com',
                                                                    'Birthdate' => '1966-01-31',
                                                                    'genesis__SSN__c' => '324242424',
                                                                    'Mailing_County__c' => 'West Bengal',
                                                                    'MailingPostalCode' => '70011',
                                                                    'MailingState' => 'AL',
                                                                    'MailingCity' => 'Kolkata',
                                                                    'MailingStreet' => 'S.S. Temple Road',
                                                                    'Confirm_SSN__c' => '324242424',
                                                                    'LastName' => 'Sharma'
                                                                };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }

    /**
    * @description test case for missing account name of the dba
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingAccountNameForDBA() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList(PortalConstants.INDIVIDUAL_ENTITY);

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__CL_Product__c,
                                                                genesis__CL_Purpose__c,genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Is_Evergreen__c 
                                                            FROM genesis__Applications__c
                                                            WHERE Internal_Reference_Code__c = 'testApp002'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.Id,
                                                                    'Year_Began_Farming__c' => '1999',
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id
                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765',
                                                                        'Gross_Farm_Income__c' => '76000'

                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Contact__c,
                                                                    'Email' => 'anirbandas1234321@mailinator.com',
                                                                    'Birthdate' => '1966-01-31',
                                                                    'genesis__SSN__c' => '324242424',
                                                                    'Mailing_County__c' => 'West Bengal',
                                                                    'MailingPostalCode' => '70011',
                                                                    'MailingState' => 'AL',
                                                                    'MailingCity' => 'Kolkata',
                                                                    'MailingStreet' => 'S.S. Temple Road',
                                                                    'Confirm_SSN__c' => '324242424',
                                                                    'LastName' => 'Sharma',
                                                                    'FirstName' => 'Abhisekh'
                                                                };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }
    
    /**
    * @description test for missing postal code
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingPostalCode() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__CL_Product__c,
                                                                genesis__CL_Purpose__c,genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Is_Evergreen__c 
                                                            FROM genesis__Applications__c
                                                            WHERE Internal_Reference_Code__c = 'testApp001'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];


       
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.Id,
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'BillingState' => borrowerAccountObj.BillingState,
                                                                    'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                                    'BillingCity' => borrowerAccountObj.BillingCity,
                                                                    'BillingPostalCode' => '70011',
                                                                    'Billing_County__c' => 'uiuytg',
                                                                    'Work_Number__c' => borrowerAccountObj.Work_Number__c

                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765'

                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].genesis__Contact__c,
                                                                'Email' => 'anirbandas1234321@mailinator.com',
                                                                'Birthdate' => '1966-01-31',
                                                                'genesis__SSN__c' => '324242424',
                                                                'Mailing_County__c' => 'West Bengal',
                                                                'MailingState' => 'AL',
                                                                'MailingCity' => 'Kolkata',
                                                                'MailingStreet' => 'S.S. Temple Road',
                                                                'Confirm_SSN__c' => '324242424',
                                                                'LastName' => 'Sharma',
                                                                'FirstName' => 'Abhisekh'
                                                            };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }
    /**
    * @description invalid postal code error
    * @author Rakesh Saraf | 01-12-2025 
    **/
    @isTest
    private static void testInvalidPostalCode() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__CL_Product__c,
                                                                genesis__CL_Purpose__c,genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Is_Evergreen__c 
                                                            FROM genesis__Applications__c
                                                            WHERE Internal_Reference_Code__c = 'testApp001'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.Id,
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'BillingState' => borrowerAccountObj.BillingState,
                                                                    'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                                    'BillingCity' => borrowerAccountObj.BillingCity,
                                                                    'BillingPostalCode' => '70011',
                                                                    'Billing_County__c' => 'uiuytg',
                                                                    'Work_Number__c' => borrowerAccountObj.Work_Number__c

                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765'

                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Contact__c,
                                                                    'Email' => 'anirbandas1234321@mailinator.com',
                                                                    'Birthdate' => '1966-01-31',
                                                                    'genesis__SSN__c' => '324242424',
                                                                    'Mailing_County__c' => 'West Bengal',
                                                                    'MailingState' => 'AL',
                                                                    'MailingCity' => 'Kolkata',
                                                                    'MailingPostalCode' => '7782640011',
                                                                    'MailingStreet' => 'S.S. Temple Road',
                                                                    'Confirm_SSN__c' => '324242424',
                                                                    'LastName' => 'Sharma',
                                                                    'FirstName' => 'Abhisekh'
                                                                };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }
    
    /**
    * @description test missing name for company
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingNameForCompany() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList('Corporation');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__CL_Product__c,
                                                                genesis__CL_Purpose__c,genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Is_Evergreen__c 
                                                            FROM genesis__Applications__c
                                                            WHERE Internal_Reference_Code__c = 'testApp002'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.Id,
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'BillingState' => borrowerAccountObj.BillingState,
                                                                    'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                                    'BillingCity' => borrowerAccountObj.BillingCity,
                                                                    'BillingPostalCode' => '70011',
                                                                    'Billing_County__c' => 'uiuytg',
                                                                    'Work_Number__c' => borrowerAccountObj.Work_Number__c

                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765'

                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Contact__c,
                                                                    'Email' => 'anirbandas1234321@mailinator.com',
                                                                    'Birthdate' => '1966-01-31',
                                                                    'genesis__SSN__c' => '324242424',
                                                                    'Mailing_County__c' => 'West Bengal',
                                                                    'MailingState' => 'AL',
                                                                    'MailingCity' => 'Kolkata',
                                                                    'MailingPostalCode' => '7782640011',
                                                                    'MailingStreet' => 'S.S. Temple Road',
                                                                    'Confirm_SSN__c' => '324242424',
                                                                    'LastName' => 'Sharma',
                                                                    'FirstName' => 'Abhisekh'
                                                                };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }

    /**
    * @description test missing billling state for corp
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingBillingStateForCompany() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList(PortalConstants.CORPORATION);

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__CL_Product__c,
                                                                genesis__CL_Purpose__c,genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Is_Evergreen__c 
                                                            FROM genesis__Applications__c
                                                            WHERE Internal_Reference_Code__c = 'testApp002'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.Id,
                                                                    'Name' => 'Gardner Cakes Ltd',
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                                    'BillingCity' => borrowerAccountObj.BillingCity,
                                                                    'BillingPostalCode' => '70011',
                                                                    'Billing_County__c' => 'uiuytg',
                                                                    'Work_Number__c' => borrowerAccountObj.Work_Number__c

                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765'

                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Contact__c,
                                                                    'Email' => 'anirbandas1234321@mailinator.com',
                                                                    'Birthdate' => '1966-01-31',
                                                                    'genesis__SSN__c' => '324242424',
                                                                    'Mailing_County__c' => 'West Bengal',
                                                                    'MailingState' => 'AL',
                                                                    'MailingCity' => 'Kolkata',
                                                                    'MailingPostalCode' => '7782640011',
                                                                    'MailingStreet' => 'S.S. Temple Road',
                                                                    'Confirm_SSN__c' => '324242424',
                                                                    'LastName' => 'Sharma',
                                                                    'FirstName' => 'Abhisekh'
                                                                };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }

    /**
    * @description test missing tax id for company
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingTaxIdForCompany() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList('Corporation');

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__CL_Product__c,
                                                                genesis__CL_Purpose__c,genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Is_Evergreen__c 
                                                            FROM genesis__Applications__c
                                                            WHERE Internal_Reference_Code__c = 'testApp002'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.Id,
                                                                    'Name' => borrowerAccountObj.Name,
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'BillingState' => borrowerAccountObj.BillingState,
                                                                    'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                                    'BillingCity' => borrowerAccountObj.BillingCity,
                                                                    'BillingPostalCode' => '70011',
                                                                    'Billing_County__c' => 'uiuytg',
                                                                    'Work_Number__c' => borrowerAccountObj.Work_Number__c

                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000'
                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Contact__c,
                                                                    'Email' => 'anirbandas1234321@mailinator.com',
                                                                    'Birthdate' => '1966-01-31',
                                                                    'genesis__SSN__c' => '324242424',
                                                                    'Mailing_County__c' => 'West Bengal',
                                                                    'MailingState' => 'AL',
                                                                    'MailingCity' => 'Kolkata',
                                                                    'MailingPostalCode' => '7782640011',
                                                                    'MailingStreet' => 'S.S. Temple Road',
                                                                    'Confirm_SSN__c' => '324242424',
                                                                    'LastName' => 'Sharma',
                                                                    'FirstName' => 'Abhisekh'
                                                                };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }
    
    /**
    * @description test for missing billing street
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingBillingStreetForCompany() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList(PortalConstants.CORPORATION);

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__CL_Product__c,
                                                                genesis__CL_Purpose__c,genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Is_Evergreen__c 
                                                            FROM genesis__Applications__c
                                                            WHERE Internal_Reference_Code__c = 'testApp002'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.Id,
                                                                    'Name' => borrowerAccountObj.Name,
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'BillingState' => borrowerAccountObj.BillingState,
                                                                    'BillingCity' => borrowerAccountObj.BillingCity,
                                                                    'BillingPostalCode' => '70011',
                                                                    'Billing_County__c' => 'uiuytg',
                                                                    'Work_Number__c' => borrowerAccountObj.Work_Number__c

                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765'

                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Contact__c,
                                                                    'Email' => 'anirbandas1234321@mailinator.com',
                                                                    'Birthdate' => '1966-01-31',
                                                                    'genesis__SSN__c' => '324242424',
                                                                    'Mailing_County__c' => 'West Bengal',
                                                                    'MailingState' => 'AL',
                                                                    'MailingCity' => 'Kolkata',
                                                                    'MailingPostalCode' => '7782640011',
                                                                    'MailingStreet' => 'S.S. Temple Road',
                                                                    'Confirm_SSN__c' => '324242424',
                                                                    'LastName' => 'Sharma',
                                                                    'FirstName' => 'Abhisekh'
                                                                };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }
    
    /**
    * @description test for missing billing city for company
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingBillingCityForCompany() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList(PortalConstants.CORPORATION);

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__CL_Product__c,
                                                                genesis__CL_Purpose__c,genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Is_Evergreen__c 
                                                            FROM genesis__Applications__c
                                                            WHERE Internal_Reference_Code__c = 'testApp002'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
            'Id' => applicationList[0].Id,
            'Sales_Agent__c' => accountObj.Id,
            'genesis__Loan_Amount__c' => '100000',
            'Internal_Reference_Code__c' => '43242341234'
        };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
            'id'=> partyList[0].Id,
            'Street__c'=> 'Port Angeles Ferry Terminal',
            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
            'Postal_Code__c'=> '98362',
            'Total_Assets__c'=> 10000000,
            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
            'Marital_Status__c'=> 'Unmarried',
            'clcommon__Contact__r.LastName'=> 'Buck',
            'Title__c'=> 'Co-Applicant',
            'Work_Number__c'=> '1318912849',
            'Gross_Farm_Income__c'=> 1000000,
            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
            'Is_SSN_Entered__c'=> true,
            'State__c'=> 'WA',
            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
            'Suffix__c'=> 'IV',
            'Total_Liabilities__c'=> 1,
            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
            'clcommon__Contact__r.FirstName'=> 'Salman',
            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
            'City__c'=> 'Port Angeles',
            'County__c'=> 'Clallam County',
            'Home_Number__c'=> '2429748278',
            'Id'=> partyList[0].Id,
            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
            'Mobile_Number__c'=> '3974927492'
        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
            'Id' => borrowerAccountObj.Id,
            'Name' => borrowerAccountObj.Name,
            'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
            'BillingState' => borrowerAccountObj.BillingState,
            'BillingStreet' => borrowerAccountObj.BillingStreet,
            'BillingPostalCode' => '70011',
            'Billing_County__c' => 'uiuytg',
            'Work_Number__c' => borrowerAccountObj.Work_Number__c

        };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
            'Id' => borrowerAccountObj.genesis__Business_Information__c,
            'genesis__Total_Liabilities__c' => '412333',
            'genesis__Total_Assets__c' => '456000',
            'genesis__Tax_Identification_Number__c' => '5678765'

        };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
            'Id' => applicationList[0].genesis__contact__c,
            'Email' => 'anirbandas1234321@mailinator.com',
            'Birthdate' => '1966-01-31',
            'genesis__SSN__c' => '324242424',
            'Mailing_County__c' => 'West Bengal',
            'MailingState' => 'AL',
            'MailingCity' => 'Kolkata',
            'MailingPostalCode' => '7782640011',
            'MailingStreet' => 'S.S. Temple Road',
            'Confirm_SSN__c' => '324242424',
            'LastName' => 'Sharma',
            'FirstName' => 'Abhisekh'
        };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }

    /**
    * @description test missing billing postal code for company
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingBillingPostalCodeForCompany() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList(PortalConstants.CORPORATION);

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__CL_Product__c,
                                                                genesis__CL_Purpose__c,genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Is_Evergreen__c 
                                                            FROM genesis__Applications__c
                                                            WHERE Internal_Reference_Code__c = 'testApp002'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.Id,
                                                                    'Name' => borrowerAccountObj.Name,
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'BillingState' => borrowerAccountObj.BillingState,
                                                                    'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                                    'BillingCity' => borrowerAccountObj.BillingCity,
                                                                    'Billing_County__c' => 'uiuytg',
                                                                    'Work_Number__c' => borrowerAccountObj.Work_Number__c

                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765'

                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Contact__c,
                                                                    'Email' => 'anirbandas1234321@mailinator.com',
                                                                    'Birthdate' => '1966-01-31',
                                                                    'genesis__SSN__c' => '324242424',
                                                                    'Mailing_County__c' => 'West Bengal',
                                                                    'MailingState' => 'AL',
                                                                    'MailingCity' => 'Kolkata',
                                                                    'MailingPostalCode' => '7782640011',
                                                                    'MailingStreet' => 'S.S. Temple Road',
                                                                    'Confirm_SSN__c' => '324242424',
                                                                    'LastName' => 'Sharma',
                                                                    'FirstName' => 'Abhisekh'
                                                                };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }
    
    /**
    * @description test invalid postal code for company
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingInvalidPostalCodeForCompany() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList(PortalConstants.CORPORATION);

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__CL_Product__c,
                                                                genesis__CL_Purpose__c,genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Is_Evergreen__c 
                                                            FROM genesis__Applications__c
                                                            WHERE Internal_Reference_Code__c = 'testApp002'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => borrowerAccountObj.Id,
                                                                    'Name' => borrowerAccountObj.Name,
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'BillingState' => borrowerAccountObj.BillingState,
                                                                    'BillingStreet' => borrowerAccountObj.BillingStreet,
                                                                    'BillingCity' => borrowerAccountObj.BillingCity,
                                                                    'BillingPostalCode' => '7078264011',
                                                                    'Billing_County__c' => 'uiuytg',
                                                                    'Work_Number__c' => borrowerAccountObj.Work_Number__c

                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccountObj.genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'genesis__Tax_Identification_Number__c' => '5678765'

                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Contact__c,
                                                                    'Email' => 'anirbandas1234321@mailinator.com',
                                                                    'Birthdate' => '1966-01-31',
                                                                    'genesis__SSN__c' => '324242424',
                                                                    'Mailing_County__c' => 'West Bengal',
                                                                    'MailingState' => 'AL',
                                                                    'MailingCity' => 'Kolkata',
                                                                    'MailingPostalCode' => '7782640011',
                                                                    'MailingStreet' => 'S.S. Temple Road',
                                                                    'Confirm_SSN__c' => '324242424',
                                                                    'LastName' => 'Sharma',
                                                                    'FirstName' => 'Abhisekh'
                                                                };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }
    
    /**
    * @description test mssing billing county for company
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingBillingCountyorCompany() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList(PortalConstants.CORPORATION);

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__CL_Product__c,
                                                                genesis__CL_Purpose__c,genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Is_Evergreen__c 
                                                            FROM genesis__Applications__c
                                                            WHERE Internal_Reference_Code__c = 'testApp002'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
            'Id' => applicationList[0].Id,
            'Sales_Agent__c' => accountObj.Id,
            'genesis__Loan_Amount__c' => '100000',
            'Internal_Reference_Code__c' => '43242341234'
        };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
            'id'=> partyList[0].Id,
            'Street__c'=> 'Port Angeles Ferry Terminal',
            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
            'Postal_Code__c'=> '98362',
            'Total_Assets__c'=> 10000000,
            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
            'Marital_Status__c'=> 'Unmarried',
            'clcommon__Contact__r.LastName'=> 'Buck',
            'Title__c'=> 'Co-Applicant',
            'Work_Number__c'=> '1318912849',
            'Gross_Farm_Income__c'=> 1000000,
            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
            'Is_SSN_Entered__c'=> true,
            'State__c'=> 'WA',
            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
            'Suffix__c'=> 'IV',
            'Total_Liabilities__c'=> 1,
            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
            'clcommon__Contact__r.FirstName'=> 'Salman',
            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
            'City__c'=> 'Port Angeles',
            'County__c'=> 'Clallam County',
            'Home_Number__c'=> '2429748278',
            'Id'=> partyList[0].Id,
            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
            'Mobile_Number__c'=> '3974927492'
        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
            'Id' => borrowerAccountObj.Id,
            'Name' => borrowerAccountObj.Name,
            'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
            'BillingState' => borrowerAccountObj.BillingState,
            'BillingStreet' => borrowerAccountObj.BillingStreet,
            'BillingCity' => borrowerAccountObj.BillingCity,
            'BillingPostalCode' => '70011',
            'Work_Number__c' => borrowerAccountObj.Work_Number__c

        };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
            'Id' => borrowerAccountObj.genesis__Business_Information__c,
            'genesis__Total_Liabilities__c' => '412333',
            'genesis__Total_Assets__c' => '456000',
            'genesis__Tax_Identification_Number__c' => '5678765'

        };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
            'Id' => applicationList[0].genesis__contact__c,
            'Email' => 'anirbandas1234321@mailinator.com',
            'Birthdate' => '1966-01-31',
            'genesis__SSN__c' => '324242424',
            'Mailing_County__c' => 'West Bengal',
            'MailingState' => 'AL',
            'MailingCity' => 'Kolkata',
            'MailingPostalCode' => '7782640011',
            'MailingStreet' => 'S.S. Temple Road',
            'Confirm_SSN__c' => '324242424',
            'LastName' => 'Sharma',
            'FirstName' => 'Abhisekh'
        };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }

    /**
    * @description test mssing number for company
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testMissingNumberForCompany() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList(PortalConstants.CORPORATION);

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__CL_Product__c,
                                                                genesis__CL_Purpose__c,genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Is_Evergreen__c 
                                                            FROM genesis__Applications__c
                                                            WHERE Internal_Reference_Code__c = 'testApp002'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                  
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
            'Id' => applicationList[0].Id,
            'Sales_Agent__c' => accountObj.Id,
            'genesis__Loan_Amount__c' => '100000',
            'Internal_Reference_Code__c' => '43242341234'
        };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
            'id'=> partyList[0].Id,
            'Street__c'=> 'Port Angeles Ferry Terminal',
            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
            'Postal_Code__c'=> '98362',
            'Total_Assets__c'=> 10000000,
            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
            'Marital_Status__c'=> 'Unmarried',
            'clcommon__Contact__r.LastName'=> 'Buck',
            'Title__c'=> 'Co-Applicant',
            'Work_Number__c'=> '1318912849',
            'Gross_Farm_Income__c'=> 1000000,
            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
            'Is_SSN_Entered__c'=> true,
            'State__c'=> 'WA',
            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
            'Suffix__c'=> 'IV',
            'Total_Liabilities__c'=> 1,
            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
            'clcommon__Contact__r.FirstName'=> 'Salman',
            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
            'City__c'=> 'Port Angeles',
            'County__c'=> 'Clallam County',
            'Home_Number__c'=> '2429748278',
            'Id'=> partyList[0].Id,
            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
            'Mobile_Number__c'=> '3974927492'
        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
            'Id' => borrowerAccountObj.Id,
            'Name' => borrowerAccountObj.Name,
            'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
            'BillingState' => borrowerAccountObj.BillingState,
            'BillingStreet' => borrowerAccountObj.BillingStreet,
            'BillingCity' => borrowerAccountObj.BillingCity,
            'BillingPostalCode' => '70011',
            'Billing_County__c' => 'uiuytg'

        };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
            'Id' => borrowerAccountObj.genesis__Business_Information__c,
            'genesis__Total_Liabilities__c' => '412333',
            'genesis__Total_Assets__c' => '456000',
            'genesis__Tax_Identification_Number__c' => '5678765'

        };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
            'Id' => applicationList[0].genesis__Contact__c,
            'Email' => 'anirbandas1234321@mailinator.com',
            'Birthdate' => '1966-01-31',
            'genesis__SSN__c' => '324242424',
            'Mailing_County__c' => 'West Bengal',
            'MailingState' => 'AL',
            'MailingCity' => 'Kolkata',
            'MailingPostalCode' => '7782640011',
            'MailingStreet' => 'S.S. Temple Road',
            'Confirm_SSN__c' => '324242424',
            'LastName' => 'Sharma',
            'FirstName' => 'Abhisekh'
        };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }
    
    /**
    * @description test negative total assets
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testNegativeTotalAsset() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList(PortalConstants.CORPORATION);

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__CL_Product__c,
                                                                genesis__CL_Purpose__c,genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Is_Evergreen__c 
                                                            FROM genesis__Applications__c
                                                            WHERE Internal_Reference_Code__c = 'testApp002'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                    
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
            'Id' => applicationList[0].Id,
            'Sales_Agent__c' => accountObj.Id,
            'genesis__Loan_Amount__c' => '100000',
            'Internal_Reference_Code__c' => '43242341234'
        };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
            'id'=> partyList[0].Id,
            'Street__c'=> 'Port Angeles Ferry Terminal',
            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
            'Postal_Code__c'=> '98362',
            'Total_Assets__c'=> 10000000,
            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
            'Marital_Status__c'=> 'Unmarried',
            'clcommon__Contact__r.LastName'=> 'Buck',
            'Title__c'=> 'Co-Applicant',
            'Work_Number__c'=> '1318912849',
            'Gross_Farm_Income__c'=> 1000000,
            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
            'Is_SSN_Entered__c'=> true,
            'State__c'=> 'WA',
            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
            'Suffix__c'=> 'IV',
            'Total_Liabilities__c'=> 1,
            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
            'clcommon__Contact__r.FirstName'=> 'Salman',
            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
            'City__c'=> 'Port Angeles',
            'County__c'=> 'Clallam County',
            'Home_Number__c'=> '2429748278',
            'Id'=> partyList[0].Id,
            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
            'Mobile_Number__c'=> '3974927492'
        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
            'Id' => borrowerAccountObj.Id,
            'Name' => borrowerAccountObj.Name,
            'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
            'BillingState' => borrowerAccountObj.BillingState,
            'BillingStreet' => borrowerAccountObj.BillingStreet,
            'BillingCity' => borrowerAccountObj.BillingCity,
            'BillingPostalCode' => '70011',
            'Billing_County__c' => 'uiuytg',
            'Work_Number__c' => borrowerAccountObj.Work_Number__c

        };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
            'Id' => borrowerAccountObj.genesis__Business_Information__c,
            'genesis__Total_Liabilities__c' => '412333',
            'genesis__Total_Assets__c' => '-456000',
            'genesis__Tax_Identification_Number__c' => '5678765'

        };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
            'Id' => applicationList[0].genesis__Contact__c,
            'Email' => 'anirbandas1234321@mailinator.com',
            'Birthdate' => '1966-01-31',
            'genesis__SSN__c' => '324242424',
            'Mailing_County__c' => 'West Bengal',
            'MailingState' => 'AL',
            'MailingCity' => 'Kolkata',
            'MailingPostalCode' => '7782640011',
            'MailingStreet' => 'S.S. Temple Road',
            'Confirm_SSN__c' => '324242424',
            'LastName' => 'Sharma',
            'FirstName' => 'Abhisekh'
        };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }

    /**
    * @description test negative total liabilities
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testNegativeTotalLiabilities() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        Account borrowerAccountObj;
        legalEntityObj = getLegalEntityList(PortalConstants.CORPORATION);

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__CL_Product__c,
                                                                genesis__CL_Purpose__c,genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Is_Evergreen__c 
                                                            FROM genesis__Applications__c
                                                            WHERE Internal_Reference_Code__c = 'testApp002'];
        
        List<Account> borrowerAccountList = [SELECT Id,
                                                    genesis__Business_Information__c,
                                                    Name,
                                                    BillingState,
                                                    BillingStreet,
                                                    BillingCity,
                                                    Work_Number__c,
                                                    clcommon__Legal_Entity_Type__c 
                                                    FROM Account 
                                                    WHERE Id =: applicationList[0].genesis__Account__c LIMIT 1];
        borrowerAccountObj = borrowerAccountList[0];
                                                                    
        List<clcommon__Party__c> partyList = [Select id,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName From clcommon__Party__c WHERE clcommon__Type__r.Name = 'PRINCIPAL' and genesis__Application__c =: applicationList[0].id];

       
        Map<String,Object> applicationMap = new Map<String,Object>{
            'Id' => applicationList[0].Id,
            'Sales_Agent__c' => accountObj.Id,
            'genesis__Loan_Amount__c' => '100000',
            'Internal_Reference_Code__c' => '43242341234'
        };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
            'id'=> partyList[0].Id,
            'Street__c'=> 'Port Angeles Ferry Terminal',
            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
            'Postal_Code__c'=> '98362',
            'Total_Assets__c'=> 10000000,
            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
            'Marital_Status__c'=> 'Unmarried',
            'clcommon__Contact__r.LastName'=> 'Buck',
            'Title__c'=> 'Co-Applicant',
            'Work_Number__c'=> '1318912849',
            'Gross_Farm_Income__c'=> 1000000,
            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
            'Is_SSN_Entered__c'=> true,
            'State__c'=> 'WA',
            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
            'Suffix__c'=> 'IV',
            'Total_Liabilities__c'=> 1,
            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
            'clcommon__Contact__r.FirstName'=> 'Salman',
            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
            'City__c'=> 'Port Angeles',
            'County__c'=> 'Clallam County',
            'Home_Number__c'=> '2429748278',
            'Id'=> partyList[0].Id,
            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
            'Mobile_Number__c'=> '3974927492'
        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
            'Id' => borrowerAccountObj.Id,
            'Name' => borrowerAccountObj.Name,
            'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
            'BillingState' => borrowerAccountObj.BillingState,
            'BillingStreet' => borrowerAccountObj.BillingStreet,
            'BillingCity' => borrowerAccountObj.BillingCity,
            'BillingPostalCode' => '70011',
            'Billing_County__c' => 'uiuytg',
            'Work_Number__c' => borrowerAccountObj.Work_Number__c

        };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
            'Id' => borrowerAccountObj.genesis__Business_Information__c,
            'genesis__Total_Liabilities__c' => '-412333',
            'genesis__Total_Assets__c' => '456000',
            'genesis__Tax_Identification_Number__c' => '5678765'

        };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
            'Id' => applicationList[0].genesis__contact__c,
            'Email' => 'anirbandas1234321@mailinator.com',
            'Birthdate' => '1966-01-31',
            'genesis__SSN__c' => '324242424',
            'Mailing_County__c' => 'West Bengal',
            'MailingState' => 'AL',
            'MailingCity' => 'Kolkata',
            'MailingPostalCode' => '7782640011',
            'MailingStreet' => 'S.S. Temple Road',
            'Confirm_SSN__c' => '324242424',
            'LastName' => 'Sharma',
            'FirstName' => 'Abhisekh'
        };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Created Succefully');
            Test.stopTest();
        }
    }

    /**
    * @description test exception while creating a sole prop application
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testCreateIndivudualSolePropTypeApplicationException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,genesis__Account__c,genesis__Contact__c FROM genesis__Applications__c WHERE Internal_Reference_Code__c = 'testApp001' LIMIT 1];
        List<Account> borrowerAccount = [Select Id,Non_Accrual__c,Has_Past_Due__c,genesis__Business_Information__c From Account Where Id =: applicationList[0].genesis__Account__c LIMIT 1];
        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME LIMIT 1];
        List<Account> coBorrowerAccount = [SELECT Id,genesis__Business_Information__c FROM Account Where Id =: partyList[0].clcommon__Account__c Limit 1];
        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];
        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');

        List<Dealer_Applicant_Relationship__c> dealerGrowerRel=[SELECT ID, Has_Past_Due__c, Is_Non_Accrual__c FROM Dealer_Applicant_Relationship__c WHERE Applicant__c=:borrowerAccount[0].id];
        dealerGrowerRel[0].Has_Past_Due__c=true;
        dealerGrowerRel[0].Is_Non_Accrual__c=true;
        Database.update(dealerGrowerRel,true);
        
        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Map<String,Object> applicationMap = new Map<String,Object>{
            'Id' => applicationList[0].Id,
            'Sales_Agent__c' => accountObj.Id,
            'genesis__Loan_Amount__c' => '100000',
            'Internal_Reference_Code__c' => '43242341234'
        };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
            'id'=> partyList[0].Id,
            'Street__c'=> 'Port Angeles Ferry Terminal',
            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
            'Postal_Code__c'=> '98362',
            'clcommon__Contact__r.Id'=> coBorrowerContact[0].id,
            'Total_Assets__c'=> 10000000,
            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
            'Marital_Status__c'=> 'Unmarried',
            'clcommon__Contact__r.LastName'=> 'Buck',
            'Title__c'=> 'Co-Applicant',
            'Work_Number__c'=> '1318912849',
            'Gross_Farm_Income__c'=> 1000000,
            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
            'clcommon__Account__r.Id'=> coBorrowerAccount[0].id,
            'Is_SSN_Entered__c'=> true,
            'State__c'=> 'WA',
            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
            'Suffix__c'=> 'IV',
            'Total_Liabilities__c'=> 1,
            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
            'clcommon__Contact__r.FirstName'=> 'Salman',
            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
            'clcommon__Account__r.genesis__Business_Information__r.Id'=> coBorrowerAccount[0].genesis__Business_Information__c,
            'City__c'=> 'Port Angeles',
            'County__c'=> 'Clallam County',
            'Home_Number__c'=> '2429748278',
            'Id'=> partyList[0].Id,
            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
            'Mobile_Number__c'=> '3974927492'
        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
            'Id' => applicationList[0].genesis__Account__c,
            'Year_Began_Farming__c' => '1999',
            'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id
        };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
            'Id' => borrowerAccount[0].genesis__Business_Information__c,
            'genesis__Total_Liabilities__c' => '412333',
            'genesis__Total_Assets__c' => '456000',
            'Gross_Farm_Income__c' => '76000'
        };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
            'Id' => applicationList[0].genesis__Contact__c,
            'Email' => 'anirbandas1234321@mailinator.com',
            'Birthdate' => '1966-01-31',
            'genesis__SSN__c' => '324242424',
            'MobilePhone' => '4342343432',
            'Mailing_County__c' => 'West Bengal',
            'MailingPostalCode' => '70011',
            'MailingState' => 'AL',
            'MailingCity' => 'Kolkata',
            'MailingStreet' => 'S.S. Temple Road',
            'Confirm_SSN__c' => '324242424',
            'LastName' => 'Sharma',
            'FirstName' => 'Abhishake'
        };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    }

    /**
    * @description test to create a sole prop application for a an applicant which has the same ssn as an existing applicant but since the grrower already has a user, there an exception will be thrown
    * @author Rakesh Saraf | 12-16-2024 
    **/
    @isTest
    private static void testApplicationForIndividualWithExistingSSN() {
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__Legal_Entity__c legalEntityObj;
        Account accountObj;
        User userObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,genesis__Account__c,genesis__Contact__c FROM genesis__Applications__c WHERE Internal_Reference_Code__c = 'testApp001' LIMIT 1];
        List<Account> borrowerAccount = [Select Id,genesis__Business_Information__c From Account Where Id =: applicationList[0].genesis__Account__c LIMIT 1];
        List<clcommon__Party__c> partyList = [SELECT Id,clcommon__Account__c,clcommon__Contact__c,genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c =: PortalConstants.PRINCIPAL_PARTY_NAME LIMIT 1];
        List<Account> coBorrowerAccount = [SELECT Id,genesis__Business_Information__c FROM Account Where Id =: partyList[0].clcommon__Account__c Limit 1];
        List<Contact> coBorrowerContact = [SELECT Id FROM Contact Where Id =: partyList[0].clcommon__Contact__c Limit 1];
        legalEntityObj = getLegalEntityList('Individual(s) - Sole Proprietorship');

        genesis__Business_Information__c borrowerBInfo=ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBInfo,true);

        Account borrowerAcc=ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBInfo.id);
        Database.insert(borrowerAcc,true);

        Contact borrowerCon=ApplicationOriginationTestHelper.createBorrowerContact(borrowerAcc.id);
        borrowerCon.genesis__SSN__c='324242424';
        borrowerCon.Confirm_SSN__c='324242424';
        Database.insert(borrowerCon,true);

        accountObj = ApplicationOriginationTestHelper.getSalesAgentAccount();
        
        userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Map<String,Object> applicationMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].Id,
                                                                'Sales_Agent__c' => accountObj.Id,
                                                                'genesis__Loan_Amount__c' => '100000',
                                                                'Internal_Reference_Code__c' => '43242341234'
                                                            };
        Map<String,Object> coApplicantMap = new Map<String,Object>{
                                                            'id'=> partyList[0].Id,
                                                            'Street__c'=> 'Port Angeles Ferry Terminal',
                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-4243',
                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-4243',
                                                            'Postal_Code__c'=> '98362',
                                                            'clcommon__Contact__r.Id'=> coBorrowerContact[0].id,
                                                            'Total_Assets__c'=> 10000000,
                                                            'clcommon__Contact__r.Birthdate'=> '2000-09-18',
                                                            'Marital_Status__c'=> 'Unmarried',
                                                            'clcommon__Contact__r.LastName'=> 'Buck',
                                                            'Title__c'=> 'Co-Applicant',
                                                            'Work_Number__c'=> '1318912849',
                                                            'Gross_Farm_Income__c'=> 1000000,
                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'salman23@yopmail.com',
                                                            'clcommon__Account__r.Id'=> coBorrowerAccount[0].id,
                                                            'Is_SSN_Entered__c'=> true,
                                                            'State__c'=> 'WA',
                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                            'Suffix__c'=> 'IV',
                                                            'Total_Liabilities__c'=> 1,
                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 9999999,
                                                            'clcommon__Contact__r.FirstName'=> 'Salman',
                                                            'clcommon__Contact__r.Email'=> 'salman23@yopmail.com',
                                                            'clcommon__Contact__r.genesis__SSN__c'=> '102424243',
                                                            'clcommon__Account__r.genesis__Business_Information__r.Id'=> coBorrowerAccount[0].genesis__Business_Information__c,
                                                            'City__c'=> 'Port Angeles',
                                                            'County__c'=> 'Clallam County',
                                                            'Home_Number__c'=> '2429748278',
                                                            'Id'=> partyList[0].Id,
                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '102424243',
                                                            'Mobile_Number__c'=> '3974927492'
                                                        };

        Map<String,Object> borrowerAccountMap = new Map<String,Object>{
                                                                    'Id' => applicationList[0].genesis__Account__c,
                                                                    'Year_Began_Farming__c' => '1999',
                                                                    'clcommon__Legal_Entity_Type__c' => legalEntityObj.Id,
                                                                    'Work_Number__c' => '2328452475',
                                                                    'Home_Number__c' => '2424952947',
                                                                    'Phone' => '1782548528',
                                                                    'clcommon__Email__c' => 'test.cfa@yopmail.com',
                                                                    'Billing_County__c' => 'Philadelphia County',
                                                                    'BillingPostalCode' => '90339',
                                                                    'BillingState' => 'PA',
                                                                    'BillingCity' => 'Philadelphia',
                                                                    'BillingStreet' => 'Kelly Drive'
                                                                };
        Map<String,Object> borrowerBusinessInfoMap = new Map<String,Object>{
                                                                        'Id' => borrowerAccount[0].genesis__Business_Information__c,
                                                                        'genesis__Total_Liabilities__c' => '412333',
                                                                        'genesis__Total_Assets__c' => '456000',
                                                                        'Gross_Farm_Income__c' => '76000'
                                                                    };
        Map<String,Object> borrowerContactMap = new Map<String,Object>{
                                                                'Id' => applicationList[0].genesis__Contact__c,
                                                                'Email' => 'anirbandas1234321@mailinator.com',
                                                                'Birthdate' => '1966-01-31',
                                                                'genesis__SSN__c' => '324242424',
                                                                'MobilePhone' => '4342343432',
                                                                'Mailing_County__c' => 'West Bengal',
                                                                'MailingPostalCode' => '70011',
                                                                'MailingState' => 'AL',
                                                                'MailingCity' => 'Kolkata',
                                                                'MailingStreet' => 'S.S. Temple Road',
                                                                'Confirm_SSN__c' => '324242424',
                                                                'LastName' => 'Sharma',
                                                                'FirstName' => 'Abhishake',
                                                                'clcommon__Marital_Status__c'=>'Married'
                                                            };
        List<Map<String,Object>> coApplicantList = new List<Map<String,Object>>();
        coApplicantList.add(coApplicantMap);
        requestMap.put('application',JSON.serialize(applicationMap));
        requestMap.put('coapplicant',JSON.serialize(coApplicantList));
        requestMap.put('primaryApplicantAccount',JSON.serialize(borrowerAccountMap));
        requestMap.put('primaryApplicantBusinessInformation',JSON.serialize(borrowerBusinessInfoMap));
        requestMap.put('primaryApplicantContact',JSON.serialize(borrowerContactMap));
        requestMap.put('shouldValidate', 'SaveAndContinue');
        System.runAs(userObj) {
            Test.startTest();
            PortalSaveApplicantInformationAPI testApi = new PortalSaveApplicantInformationAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Application Creation Failed');
            Test.stopTest();
        }
    }
}