/**
 * @description       : Test class for PortalApplicationCloneAPI
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 01-13-2025
 * @last modified by  : Rakesh Saraf
**/

@isTest
public with sharing class TestPortalApplicationCloneAPI {

    @TestSetup
    static void makeData(){
        ApplicationOriginationSetupTestHelper.createTestSetup();

        Account salesAgentAcc=ApplicationOriginationTestHelper.getSalesAgentAccount();

        List<Contact> salesAgentContact=[SELECT ID FROM CONTACT WHERE AccountId=:salesAgentAcc.id];

        List<clcommon__Party_Type__c> salesAgentPartyType=[SELECT ID FROM clcommon__Party_Type__c WHERE Name=:PortalConstants.SALES_AGENT_PARTY_NAME];

        List<genesis__Applications__c> indApplication=[SELECT ID FROM genesis__Applications__c WHERE Internal_Reference_Code__c = 'testApp001'];

        List<genesis__Applications__c> corpApplication=[SELECT ID FROM genesis__Applications__c WHERE Internal_Reference_Code__c = 'testApp002'];

        // Sales Agent Party
        clcommon__party__c indAppSAParty = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
                                                                                                    'accountId' => salesAgentAcc.id,
                                                                                                    'contactId' => salesAgentContact[0].id,
                                                                                                    'partyTypeId' => salesAgentPartyType[0].Id,
                                                                                                    'applicationId' => indApplication[0].Id
                                                                                                });

        clcommon__party__c corpAppSAParty = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
                                                                                                    'accountId' => salesAgentAcc.id,
                                                                                                    'contactId' => salesAgentContact[0].id,
                                                                                                    'partyTypeId' => salesAgentPartyType[0].Id,
                                                                                                    'applicationId' => corpApplication[0].Id
                                                                                                });
        Database.Insert(new List<clcommon__party__c>{indAppSAParty,corpAppSAParty}, true);

        clcommon__document_category__c docCategory = ApplicationOriginationTestHelper.createDocCategory(indApplication[0].id, PortalConstants.DRIVING_LICENSE_TASK);
        Database.insert(docCategory,true);
        
    }
    
    /**
    * @description test case for individual sole prop
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testSolePropApplicationClone() {
        
        Map<String, Object> requestMap = new Map<String, Object>();
        
        User clUser=ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,genesis__Account__c,genesis__Contact__c FROM genesis__Applications__c WHERE Internal_Reference_Code__c = 'testApp001' LIMIT 1];

        requestMap.put('applicationId', applicationList[0].Id );
        requestMap.put('createEvergreenApplication', false);

        System.runAs(clUser) {
            Test.startTest();
            PortalApplicationCloneAPI testApi = new PortalApplicationCloneAPI();
            clcommon.Response response = testApi.invokeAction('ok', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.Success, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description test case for individual sole prop with sales agent
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testSolePropApplicationCloneWithSA() {
        
        Map<String, Object> requestMap = new Map<String, Object>();
        
        User clUser=ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Account sAAccountObj=ApplicationOriginationTestHelper.getSalesAgentAccount();

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                 genesis__Account__c,
                                                                 genesis__Contact__c,
                                                                 Sales_Agent__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Internal_Reference_Code__c = 'testApp001' 
                                                          LIMIT 1];

        applicationList[0].Sales_Agent__c=sAAccountObj.id;
        Database.update(applicationList,true);

        requestMap.put('applicationId', applicationList[0].Id );
        requestMap.put('createEvergreenApplication', false);

        System.runAs(clUser) {
            Test.startTest();
            PortalApplicationCloneAPI testApi = new PortalApplicationCloneAPI();
            clcommon.Response response = testApi.invokeAction('ok', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.Success, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    
    /**
    * @description Scenario where createEvergreenApplication is true and Is_Evergreen_Eligible__c = true
    * @author Rakesh Saraf | 12-22-2024 
    **/
    @isTest
    private static void testEligibleForEvergreenApp() {
        
        Map<String, Object> requestMap = new Map<String, Object>();
        
        User clUser=ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                 genesis__Account__c,
                                                                 genesis__Contact__c,
                                                                 Is_Evergreen_Eligible__c
                                                          FROM genesis__Applications__c 
                                                          WHERE Internal_Reference_Code__c = 'testApp001' 
                                                          LIMIT 1];
        applicationList[0].Is_Evergreen_Eligible__c=true;
        Database.update(applicationList,true);

        requestMap.put('applicationId', applicationList[0].Id );
        requestMap.put('createEvergreenApplication', true);

        System.runAs(clUser) {
            Test.startTest();
            PortalApplicationCloneAPI testApi = new PortalApplicationCloneAPI();
            clcommon.Response response = testApi.invokeAction('ok', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    
    /**
    * @description exception Scenario - createEvergreenApplication true and Is_Evergreen_Eligible__c = false 
    * @author Rakesh Saraf | 12-23-2024 
    **/
    @isTest
    private static void testExceptionForEvergreenApp() {
        
        Map<String, Object> requestMap = new Map<String, Object>();
        
        User clUser=ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                 genesis__Account__c,
                                                                 genesis__Contact__c,
                                                                 Is_Evergreen_Eligible__c
                                                          FROM genesis__Applications__c 
                                                          WHERE Internal_Reference_Code__c = 'testApp001' 
                                                          LIMIT 1];
        applicationList[0].Is_Evergreen_Eligible__c=false;
        Database.update(applicationList,true);

        requestMap.put('applicationId', applicationList[0].Id );
        requestMap.put('createEvergreenApplication', true);

        System.runAs(clUser) {
            Test.startTest();
            PortalApplicationCloneAPI testApi = new PortalApplicationCloneAPI();
            clcommon.Response response = testApi.invokeAction('ok', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description exception scenario with no application id
    * @author Rakesh Saraf | 12-23-2024 
    **/
    @isTest
    private static void blankApplicationIdException() {

        Map<String, Object> requestMap = new Map<String, Object>();
        // Fetching user
        List<User> saUserList = [SELECT Id, Name, Email, ProfileId, UserName
                                FROM USER 
                                WHERE UserName = 'tony.stark@yopmail.com'
                                LIMIT 1];
        

        requestMap.put('applicationId', '');

        System.runAs(saUserList[0]) {
            Test.startTest();
            PortalApplicationCloneAPI testApi = new PortalApplicationCloneAPI();
            clcommon.Response response = testApi.invokeAction('ok', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description test logging in with a user who does not have a party in the application
    * @author Rakesh Saraf | 12-23-2024 
    **/
    @isTest
    private static void testUnAuthorisedUserException() {

        Map<String, Object> requestMap = new Map<String, Object>();
        
        User saUser=[SELECT ID FROM User WHERE UserName='tony.stark@yopmail.com' LIMIT 1];

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                 genesis__Account__c,
                                                                 genesis__Contact__c,
                                                                 Is_Evergreen_Eligible__c
                                                          FROM genesis__Applications__c 
                                                          WHERE Internal_Reference_Code__c = 'testApp001' 
                                                          LIMIT 1];
        
        List<clcommon__Party__c> saPartyList=[SELECT ID FROM clcommon__Party__c WHERE genesis__Application__c=:applicationList[0].id AND clcommon__Type__r.Name= 'SALES AGENT' LIMIT 1];
        Database.delete(saPartyList,true);

        requestMap.put('applicationId', applicationList[0].Id );

        System.runAs(saUser) {
            Test.startTest();
            PortalApplicationCloneAPI testApi = new PortalApplicationCloneAPI();
            clcommon.Response response = testApi.invokeAction('ok', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description test case when the account does not have any business info linked to it
    * @author Rakesh Saraf | 12-23-2024 
    **/
    @isTest
    private static void testNoBusinessInformationException() {

        Map<String, Object> requestMap = new Map<String, Object>();
        
        User clUser=ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                 genesis__Account__c,
                                                                 genesis__Contact__c,
                                                                 Is_Evergreen_Eligible__c
                                                          FROM genesis__Applications__c 
                                                          WHERE Internal_Reference_Code__c = 'testApp001' 
                                                          LIMIT 1];
        
        List<Account> growerAccList=[SELECT ID,
                                        genesis__Business_Information__c
                                 FROM ACCOUNT 
                                 WHERE ID=: applicationList[0].genesis__Account__c
                                 LIMIT 1];

        growerAccList[0].genesis__Business_Information__c=null;
        Database.update(growerAccList,true);

        requestMap.put('applicationId', applicationList[0].Id );

        System.runAs(clUser) {
            Test.startTest();
            PortalApplicationCloneAPI testApi = new PortalApplicationCloneAPI();
            clcommon.Response response = testApi.invokeAction('ok', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description test case when the applicant has past due
    * @author Rakesh Saraf | 12-23-2024 
    **/
    @isTest
    private static void testHasPastDue() {
        
        Map<String, Object> requestMap = new Map<String, Object>();
        
        User clUser=ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                 genesis__Account__c,
                                                                 genesis__Contact__c,
                                                                 Is_Evergreen_Eligible__c
                                                          FROM genesis__Applications__c 
                                                          WHERE Internal_Reference_Code__c = 'testApp001' 
                                                          LIMIT 1];
        
        List<Dealer_Applicant_Relationship__c> dealerGrowerRelList=[SELECT ID,
                                                                           Has_Past_Due__c
                                                                    FROM Dealer_Applicant_Relationship__c
                                                                    WHERE Applicant__c =:applicationList[0].genesis__Account__c
                                                                    LIMIT 1];
        dealerGrowerRelList[0].Has_Past_Due__c=true;
        Database.update(dealerGrowerRelList,true);

        requestMap.put('applicationId', applicationList[0].Id );
        requestMap.put('createEvergreenApplication', false);

        System.runAs(clUser) {
            Test.startTest();
            PortalApplicationCloneAPI testApi = new PortalApplicationCloneAPI();
            clcommon.Response response = testApi.invokeAction('ok', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description test case when the applicant is non accrual
    * @author Rakesh Saraf | 12-23-2024 
    **/
    @isTest
    private static void testHasNonAccrual() {
        
        Map<String, Object> requestMap = new Map<String, Object>();
        
        User clUser=ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                 genesis__Account__c,
                                                                 genesis__Contact__c,
                                                                 Is_Evergreen_Eligible__c
                                                          FROM genesis__Applications__c 
                                                          WHERE Internal_Reference_Code__c = 'testApp001' 
                                                          LIMIT 1];
        
        List<Dealer_Applicant_Relationship__c> dealerGrowerRelList=[SELECT ID,
                                                                           Is_Non_Accrual__c
                                                                    FROM Dealer_Applicant_Relationship__c
                                                                    WHERE Applicant__c =:applicationList[0].genesis__Account__c
                                                                    LIMIT 1];
        dealerGrowerRelList[0].Is_Non_Accrual__c=true;
        Database.update(dealerGrowerRelList,true);

        requestMap.put('applicationId', applicationList[0].Id );
        requestMap.put('createEvergreenApplication', false);

        System.runAs(clUser) {
            Test.startTest();
            PortalApplicationCloneAPI testApi = new PortalApplicationCloneAPI();
            clcommon.Response response = testApi.invokeAction('ok', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }
}