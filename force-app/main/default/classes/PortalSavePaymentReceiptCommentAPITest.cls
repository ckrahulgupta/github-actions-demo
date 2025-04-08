/**
 * @description       : Test class for PortalSavePaymentReceiptCommentAPI
 * @author            : Suraj Kumar | 11-19-2024
 * @group             : 
 * @last modified on  : 11-25-2024
 * @last modified by  : Suraj Kumar
**/
@isTest
public without sharing class PortalSavePaymentReceiptCommentAPITest {
    /**
    * @description : Creating Test Data
    * @author Suraj Kumar | 11-19-2024 
    **/
    @TestSetup
    static void setup(){
        ApplicationOriginationSetupTestHelper.createTestSetup();
        genesis__Applications__c applicationObj = getApplication();        

        clcommon__Consolidated_Invoice__c invoiceObj = LoanServicingTestHelper.createInvoice(applicationObj.Id);
        Database.insert(invoiceObj,true);

        Account fsaAccountObj = ApplicationOriginationTestHelper.createFSAgentAccount(applicationObj.Dealer_Name__r.genesis__Business_Information__c, applicationObj.Dealer_Name__C);
        Account paAccountObj = ApplicationOriginationTestHelper.createPaymentAdministratorAccount(applicationObj.Dealer_Name__r.genesis__Business_Information__c, applicationObj.Dealer_Name__C);
        Account clPlusAccountObj = ApplicationOriginationTestHelper.createCLPlusAccount(applicationObj.Dealer_Name__r.genesis__Business_Information__c, applicationObj.Dealer_Name__C);
        List<Account> accountList = new List<Account>{
            fsaAccountObj,paAccountObj,clPlusAccountObj
        };
        Database.insert(accountList,true);

        Contact fsaContactObj = ApplicationOriginationTestHelper.createFSAgentContact(fsaAccountObj.Id);
        Contact paContactObj = ApplicationOriginationTestHelper.createPaymentAdministratorContact(paAccountObj.Id);
        Contact clPlusContactObj = ApplicationOriginationTestHelper.createCLPlusContact(clPlusAccountObj.Id);
        List<Contact> contactList = new List<Contact>{
            fsaContactObj,paContactObj,clPlusContactObj
        };
        Database.insert(contactList,true);

        List<User> userList = new List<User>{
            ApplicationOriginationTestHelper.createFSAgentUser(fsaContactObj.Id),
            ApplicationOriginationTestHelper.createPaymentAdministratorUser(paContactObj.Id),
            ApplicationOriginationTestHelper.createClPlusUser(clPlusContactObj.Id)
        };
        Database.insert(userList,true);

        Map<String, clcommon__Party_Type__c> partyTypeMap = ApplicationOriginationTestHelper.createMultiplePartyType();
        List<clcommon__Party_Type__c> partyTypeList = new List<clcommon__Party_Type__c>{
            partyTypeMap.get(PortalConstants.CL_PLUS_PARTY_NAME),
            partyTypeMap.get(PortalConstants.PAYMENT_ADMINISTRATOR_PARTY),
            partyTypeMap.get(PortalConstants.FIELD_STAFF_AGENT_PARTY)
        };
        Database.Insert(partyTypeList, true);

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();

        clcommon__Party__c fsaPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                        'accountId' => fsaAccountObj.Id,
                                                                                        'contactId' => fsaContactObj.Id,
                                                                                        'partyTypeId' => partyTypeMap.get(PortalConstants.FIELD_STAFF_AGENT_PARTY).Id,
                                                                                        'applicationId' => applicationObj.Id
                                                                                    });
        partyList.add(fsaPartyObj);

        clcommon__Party__c paPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                            'accountId' => paAccountObj.Id,
                                                                                            'contactId' => paContactObj.Id,
                                                                                            'partyTypeId' => partyTypeMap.get(PortalConstants.PAYMENT_ADMINISTRATOR_PARTY).Id,
                                                                                            'applicationId' => applicationObj.Id
                                                                                        });
        partyList.add(paPartyObj);


        clcommon__Party__c clPlusPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                            'accountId' => clPlusAccountObj.Id,
                                                                                            'contactId' => clPlusContactObj.Id,
                                                                                            'partyTypeId' => partyTypeMap.get(PortalConstants.CL_PLUS_PARTY_NAME).Id,
                                                                                            'applicationId' => applicationObj.Id
                                                                                        });
        partyList.add(clPlusPartyObj);
        Database.Insert(partyList,true);
    }

    /**
    * @description : Method to get application
    * @author Suraj Kumar | 11-19-2024 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c getApplication(){
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            Dealer_Name__c, 
                                                            Dealer_Name__r.genesis__Business_Information__c
                                                        FROM genesis__Applications__c
                                                        WHERE genesis__Account__r.Name = 'Jasmine Albin' 
                                                        LIMIT 1];
        return applicationObj;
    }
   
    /**
    * @description : Method to get request map
    * @author Suraj Kumar | 11-25-2024 
    * @param userId 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> getRequestMap(String userId){
        genesis__Applications__c applicationObj = getApplication();
        clcommon__Consolidated_Invoice__c invoiceObj = [SELECT Id,
                                                                OwnerId
                                                            FROM clcommon__Consolidated_Invoice__c
                                                            WHERE Application__c = :applicationObj.Id
                                                            LIMIT 1];
        invoiceObj.OwnerId = userId;
        Database.update(invoiceObj,true);
        return new Map<String,Object>{
            PortalConstants.INVOICE_ID_KEY => invoiceObj.Id,
            PortalConstants.COMMENT_KEY => 'Test Payment Comment'
        };
    }

    
    /**
    * @description : Method to test for null request map
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testRequestMapNull(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), null);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for blank request map
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testRequestMapBlank(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), new Map<String,Object>());
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test without invoice id key in request map
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testWithoutInvoiceIdKey(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), new Map<String,Object>{
                PortalConstants.COMMENT_KEY => 'Test Payment Comment'
            });
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test without comment key in request map
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testWithoutCommentKey(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), new Map<String,Object>{
                PortalConstants.INVOICE_ID_KEY => 'testInvoice'
            });
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for Invoive Id Null
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testInvoiceIdNull(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String,Object> requestMap = getRequestMap(userObj.Id);
        requestMap.put(PortalConstants.INVOICE_ID_KEY,null);
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for Invoive Id blank
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testInvoiceIdBlank(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String,Object> requestMap = getRequestMap(userObj.Id);
        requestMap.put(PortalConstants.INVOICE_ID_KEY,'');
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for Invoive Id has invalid value
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testInvoiceIdInvalid(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String,Object> requestMap = getRequestMap(userObj.Id);
        requestMap.put(PortalConstants.INVOICE_ID_KEY,'test');
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for comment is null
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testForNullComment(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String,Object> requestMap = getRequestMap(userObj.Id);
        requestMap.put(PortalConstants.COMMENT_KEY,null);
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for comment is blank
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testForBlankComment(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String,Object> requestMap = getRequestMap(userObj.Id);
        requestMap.put(PortalConstants.COMMENT_KEY,'');
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for unauthorized user Profile
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testForUnauthorizeUserProfile(){
        User saUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Tony Stark');
        Map<String,Object> requestMap = getRequestMap(ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller').Id);
        System.runAs(saUserObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for login user whose party is not present on application
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testWithoutLoginUserParty(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<clcommon__Party__c> clPartyList = [SELECT Id, 
                                                    genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Party_Types__c = 'CERTIFIED LENDER'
                                                AND clcommon__Account__r.Name = 'Ross Geller'];
        for(clcommon__Party__c clPartyObj: clPartyList){
            clPartyObj.genesis__Application__c = null;
        }
        Database.update(clPartyList,true);
        Map<String,Object> requestMap = getRequestMap(userObj.Id);
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test Success for CL user 
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testSuccessWithClUser(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = getApplication();   
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userObj.Id));
            clcommon__Consolidated_Invoice__c updatedInvoiceObj = [SELECT Id,
                                                                        Comment__c
                                                                    FROM clcommon__Consolidated_Invoice__c
                                                                    WHERE Application__c = :applicationObj.Id
                                                                    LIMIT 1];
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            System.assertEquals('Test Payment Comment', updatedInvoiceObj.Comment__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test Success for Gmk CL user 
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testSuccessWithGmkClUser(){
        Profile profileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'Growmark Certified Lender'
                                    LIMIT 1];
        User userObj =  [SELECT Id,
                                    ProfileId
                                FROM User
                                WHERE AccountId 
                                IN (SELECT Id
                                            FROM Account
                                            WHERE Name = 'Ross Geller')
                                LIMIT 1];
        userObj.ProfileId = profileObj.Id;
        Database.update(userObj,true);
        genesis__Applications__c applicationObj = getApplication();  
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userObj.Id));
            clcommon__Consolidated_Invoice__c updatedInvoiceObj = [SELECT Id,
                                                                        Comment__c
                                                                    FROM clcommon__Consolidated_Invoice__c
                                                                    WHERE Application__c = :applicationObj.Id
                                                                    LIMIT 1];
            System.assertEquals('Test Payment Comment', updatedInvoiceObj.Comment__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test Success for CL Plus user 
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testSuccessWithClPlusUser(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Peter Geller');
        genesis__Applications__c applicationObj = getApplication();   
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userObj.Id));
            clcommon__Consolidated_Invoice__c updatedInvoiceObj = [SELECT Id,
                                                                        Comment__c
                                                                    FROM clcommon__Consolidated_Invoice__c
                                                                    WHERE Application__c = :applicationObj.Id
                                                                    LIMIT 1];
            System.assertEquals('Test Payment Comment', updatedInvoiceObj.Comment__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test Success for CL Plus user 
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testSuccessWithGmkClPlusUser(){
        Profile profileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'Growmark Certified Lender Plus'
                                    LIMIT 1];
        User userObj =  [SELECT Id,
                                ProfileId
                            FROM User
                            WHERE AccountId 
                            IN (SELECT Id
                                        FROM Account
                                        WHERE Name = 'Peter Geller')
                            LIMIT 1];
        userObj.ProfileId = profileObj.Id;
        Database.update(userObj,true);
        genesis__Applications__c applicationObj = getApplication();  
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userObj.Id));
            clcommon__Consolidated_Invoice__c updatedInvoiceObj = [SELECT Id,
                                                                        Comment__c
                                                                    FROM clcommon__Consolidated_Invoice__c
                                                                    WHERE Application__c = :applicationObj.Id
                                                                    LIMIT 1];
            System.assertEquals('Test Payment Comment', updatedInvoiceObj.Comment__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test Success for FSA user 
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testSuccessWithFSAUser(){
        Profile profileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'Field Staff Agent'
                                    LIMIT 1];
        User userObj =  [SELECT Id,
                                ProfileId
                            FROM User
                            WHERE AccountId 
                            IN (SELECT Id
                                        FROM Account
                                        WHERE Name = 'Ross FieldStaff')
                            LIMIT 1];
        userObj.ProfileId = profileObj.Id;
        Database.update(userObj,true);
        genesis__Applications__c applicationObj = getApplication();   
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userObj.Id));
            clcommon__Consolidated_Invoice__c updatedInvoiceObj = [SELECT Id,
                                                                        Comment__c
                                                                    FROM clcommon__Consolidated_Invoice__c
                                                                    WHERE Application__c = :applicationObj.Id
                                                                    LIMIT 1];
            System.assertEquals('Test Payment Comment', updatedInvoiceObj.Comment__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description : Method to test Success for Gmk FSA user 
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testSuccessWithGmkFSAUser(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross FieldStaff');
        genesis__Applications__c applicationObj = getApplication();   
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userObj.Id));
            clcommon__Consolidated_Invoice__c updatedInvoiceObj = [SELECT Id,
                                                                        Comment__c
                                                                    FROM clcommon__Consolidated_Invoice__c
                                                                    WHERE Application__c = :applicationObj.Id
                                                                    LIMIT 1];
            System.assertEquals('Test Payment Comment', updatedInvoiceObj.Comment__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test Success for Payment Admin user 
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testSuccessWithPAUser(){
        Profile profileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'Payment Administrator'
                                    LIMIT 1];
        User userObj =  [SELECT Id,
                                ProfileId
                            FROM User
                            WHERE AccountId 
                            IN (SELECT Id
                                        FROM Account
                                        WHERE Name = 'Alexa Aston')
                            LIMIT 1];
        userObj.ProfileId = profileObj.Id;
        Database.update(userObj,true);
        genesis__Applications__c applicationObj = getApplication();   
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userObj.Id));
            clcommon__Consolidated_Invoice__c updatedInvoiceObj = [SELECT Id,
                                                                        Comment__c
                                                                    FROM clcommon__Consolidated_Invoice__c
                                                                    WHERE Application__c = :applicationObj.Id
                                                                    LIMIT 1];
            System.assertEquals('Test Payment Comment', updatedInvoiceObj.Comment__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test Success for Growmar Payment Admin user 
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testSuccessWithGmkPAUser(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Alexa Aston');
        genesis__Applications__c applicationObj = getApplication();   
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userObj.Id));
            clcommon__Consolidated_Invoice__c updatedInvoiceObj = [SELECT Id,
                                                                        Comment__c
                                                                    FROM clcommon__Consolidated_Invoice__c
                                                                    WHERE Application__c = :applicationObj.Id
                                                                    LIMIT 1];
            System.assertEquals('Test Payment Comment', updatedInvoiceObj.Comment__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description : Method to test Success for Borrower user 
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testSuccessWithBorrowerUser(){
        User borrowerUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        System.runAs(borrowerUserObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(borrowerUserObj.Id));
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    } 

    /**
    * @description : Method to test Success for GMK Borrower user 
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testSuccessWithGmkBorrowerUser(){
        Profile profileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'Growmark Grower'
                                    LIMIT 1];
        User userObj =  [SELECT Id,
                                    ProfileId
                                FROM User
                                WHERE AccountId 
                                IN (SELECT Id
                                            FROM Account
                                            WHERE Name = 'Jasmine Albin')
                                LIMIT 1];
        userObj.ProfileId = profileObj.Id;
        Database.update(userObj,true);
        System.runAs(userObj) {
            Test.startTest();
            PortalSavePaymentReceiptCommentAPI testApi = new PortalSavePaymentReceiptCommentAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userObj.Id));
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    } 
}