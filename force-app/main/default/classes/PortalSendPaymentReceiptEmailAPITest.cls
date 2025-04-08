/**
 * @description       : Test class for PortalSendPaymentReceiptEmailAPI
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 04-08-2025
 * @last modified by  : Sk Minsar
**/
@isTest
public without sharing class PortalSendPaymentReceiptEmailAPITest {

    /**
    * @description : Creating Test Data
    * @author Suraj Kumar | 11-19-2024 
    **/
    @TestSetup
    static void setup(){
        //create application, party, roles, relationships
        ApplicationOriginationSetupTestHelper.createTestSetup();
        List<genesis__Applications__c> applicationList = getApplicationList();        

        //create invoice
        clcommon__Consolidated_Invoice__c invoiceObj = LoanServicingTestHelper.createInvoice(applicationList[0].Id);
        Database.insert(invoiceObj,true);

        //create payment mode
        clcommon__Payment_Mode__c payment = ApplicationOriginationTestHelper.createPaymentMode('Payment');
        Database.insert(payment, true);

        //create pricing details
        genesis__Application_Pricing_Detail__c pricingA = LoanServicingTestHelper.createPricingDetail(applicationList[0].Id);
        pricingA.genesis__Enabled_Flag__c = true;
        Database.insert(pricingA, true);

        //payment transaction
        genesis__Funding_Transaction__c paymentTransaction = ApplicationOriginationTestHelper.createFundingTransaction(payment.Id, pricingA.Id, applicationList[0].Id);
        paymentTransaction.Paid_By_Dealer__c = true;
        paymentTransaction.Invoice__c = invoiceObj.Id;
        Database.insert(paymentTransaction, true);

        //create accounts
        Account fsaAccountObj = ApplicationOriginationTestHelper.createFSAgentAccount(applicationList[0].Dealer_Name__r.genesis__Business_Information__c, applicationList[0].Dealer_Name__C);
        Account paAccountObj = ApplicationOriginationTestHelper.createPaymentAdministratorAccount(applicationList[0].Dealer_Name__r.genesis__Business_Information__c, applicationList[0].Dealer_Name__C);
        Account clPlusAccountObj = ApplicationOriginationTestHelper.createCLPlusAccount(applicationList[0].Dealer_Name__r.genesis__Business_Information__c, applicationList[0].Dealer_Name__C);
        List<Account> accountList = new List<Account>{
            fsaAccountObj,paAccountObj,clPlusAccountObj
        };
        Database.insert(accountList,true);

        //create contacts
        Contact fsaContactObj = ApplicationOriginationTestHelper.createFSAgentContact(fsaAccountObj.Id);
        Contact paContactObj = ApplicationOriginationTestHelper.createPaymentAdministratorContact(paAccountObj.Id);
        Contact clPlusContactObj = ApplicationOriginationTestHelper.createCLPlusContact(clPlusAccountObj.Id);
        List<Contact> contactList = new List<Contact>{
            fsaContactObj,paContactObj,clPlusContactObj
        };
        Database.insert(contactList,true);

        //create users
        List<User> userList = new List<User>{
            ApplicationOriginationTestHelper.createFSAgentUser(fsaContactObj.Id),
            ApplicationOriginationTestHelper.createPaymentAdministratorUser(paContactObj.Id),
            ApplicationOriginationTestHelper.createClPlusUser(clPlusContactObj.Id)
        };
        Database.insert(userList,true);

        //create party type
        Map<String, clcommon__Party_Type__c> partyTypeMap = ApplicationOriginationTestHelper.createMultiplePartyType();
        List<clcommon__Party_Type__c> partyTypeList = new List<clcommon__Party_Type__c>{
            partyTypeMap.get(PortalConstants.CL_PLUS_PARTY_NAME),
            partyTypeMap.get(PortalConstants.PAYMENT_ADMINISTRATOR_PARTY),
            partyTypeMap.get(PortalConstants.FIELD_STAFF_AGENT_PARTY)
        };
        Database.Insert(partyTypeList, true);

        //create party
        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        clcommon__Party__c fsaPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                        'accountId' => fsaAccountObj.Id,
                                                                                        'contactId' => fsaContactObj.Id,
                                                                                        'partyTypeId' => partyTypeMap.get(PortalConstants.FIELD_STAFF_AGENT_PARTY).Id,
                                                                                        'applicationId' => applicationList[0].Id
                                                                                    });
        partyList.add(fsaPartyObj);

        clcommon__Party__c paPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                            'accountId' => paAccountObj.Id,
                                                                                            'contactId' => paContactObj.Id,
                                                                                            'partyTypeId' => partyTypeMap.get(PortalConstants.PAYMENT_ADMINISTRATOR_PARTY).Id,
                                                                                            'applicationId' => applicationList[0].Id
                                                                                        });
        partyList.add(paPartyObj);

        clcommon__Party__c clPlusPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                            'accountId' => clPlusAccountObj.Id,
                                                                                            'contactId' => clPlusContactObj.Id,
                                                                                            'partyTypeId' => partyTypeMap.get(PortalConstants.CL_PLUS_PARTY_NAME).Id,
                                                                                            'applicationId' => applicationList[0].Id
                                                                                        });
        partyList.add(clPlusPartyObj);
        Database.Insert(partyList,true);
    }

    /**
    * @description : Method to get application
    * @author Suraj Kumar | 11-19-2024 
    * @return List<genesis__Applications__c> 
    **/
    private static List<genesis__Applications__c> getApplicationList(){
        return [SELECT Id,
                        Dealer_Name__c,
                        Dealer_Name__r.genesis__Business_Information__c
                FROM genesis__Applications__c
                WHERE genesis__Account__r.Name = 'Jasmine Albin' 
                LIMIT 1];
    }
   
    /**
    * @description : Method to get request map
    * @author Suraj Kumar | 11-25-2024 
    * @param userId 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> getRequestMap(String userId){
        List<genesis__Applications__c> applicationList = getApplicationList();
        clcommon__Consolidated_Invoice__c invoiceObj = [SELECT Id, OwnerId, Email__c
                                                        FROM clcommon__Consolidated_Invoice__c
                                                        WHERE Application__c = :applicationList[0].Id
                                                        LIMIT 1];
        invoiceObj.OwnerId = userId;
        Database.update(invoiceObj,true);
        return new Map<String,Object>{
            PortalConstants.INVOICE_ID_KEY => invoiceObj.Id,
            PortalConstants.EMAIL_KEY => 'test.invoice@yopmail.com'
        };
    }

    /**
    * @description - Get PartyList
    * @author Sk Minsar | 04-08-2025 
    * @return List<clcommon__Party__c> 
    **/
    private static List<clcommon__Party__c> getPatyList(){
        return [SELECT Id, genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Party_Types__c = 'CERTIFIED LENDER' AND clcommon__Account__r.Name = 'Ross Geller' LIMIT :PortalConstants.TEN_VALUE];
    }

    /**
    * @description - Get invoice list
    * @author Sk Minsar | 04-08-2025 
    * @param applicationId 
    * @return List<clcommon__Consolidated_Invoice__c> 
    **/
    private static List<clcommon__Consolidated_Invoice__c> getInvoiceList(String applicationId){
        return [SELECT Id, Comment__c, Email__c FROM clcommon__Consolidated_Invoice__c WHERE Application__c = :applicationId LIMIT :PortalConstants.TEN_VALUE];
    }

    /**
    * @description - Get email log list
    * @author Sk Minsar | 04-08-2025 
    * @return List<clcommon__Notification__c> 
    **/
    private static List<clcommon__Notification__c> getEmailLogList(){
        return [SELECT Id, Email_Status__c FROM clcommon__Notification__c WHERE Recipient_Address__c = 'test.invoice@yopmail.com' LIMIT 1];
    }  
    
    /**
    * @description - Get profile by name
    * @author Sk Minsar | 04-08-2025 
    * @param profileName 
    * @return List<Profile> 
    **/
    private static List<Profile> getProfileByName(String profileName){
        return [SELECT Id FROM Profile WHERE Name =: profileName LIMIT :PortalConstants.ONE_VALUE];
    }

    /**
    * @description - Get user list by account name
    * @author Sk Minsar | 04-08-2025 
    * @param accountName 
    * @return List<User> 
    **/
    private static List<User> getUserByAccoountName(String accountName){
        return [SELECT Id, ProfileId FROM User WHERE AccountId IN (SELECT Id FROM Account WHERE Name = :accountName) LIMIT 1];
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
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
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
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
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
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), new Map<String,Object>{
                PortalConstants.EMAIL_KEY => 'test.invoice@yopmail.com'
            });
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test without email key in request map
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testWithoutEmailKey(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        System.runAs(userObj) {
            Test.startTest();
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
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
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
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
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
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
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for Email is null
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testForNullEmail(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String,Object> requestMap = getRequestMap(userObj.Id);
        requestMap.put(PortalConstants.EMAIL_KEY,null);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for email is blank
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testForBlankEmail(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String,Object> requestMap = getRequestMap(userObj.Id);
        requestMap.put(PortalConstants.EMAIL_KEY,'');
        System.runAs(userObj) {
            Test.startTest();
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for email is invalid
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testForInvalidEmail(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String,Object> requestMap = getRequestMap(userObj.Id);
        requestMap.put(PortalConstants.EMAIL_KEY,'test');
        System.runAs(userObj) {
            Test.startTest();
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
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
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Tony Stark');
        Map<String,Object> requestMap = getRequestMap(ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller').Id);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
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
        List<clcommon__Party__c> clPartyList = getPatyList();
        for(clcommon__Party__c clPartyObj: clPartyList){
            clPartyObj.genesis__Application__c = null;
        }
        Database.update(clPartyList,true);
        Map<String,Object> requestMap = getRequestMap(userObj.Id);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test Success even if the comment is null for that invoice
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testSuccesForNullComment(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = getApplicationList();
        List<clcommon__Consolidated_Invoice__c> invoiceList = getInvoiceList(applicationList[0].Id);
        invoiceList[0].Comment__c = null;
        Database.update(invoiceList[0],true);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userObj.Id));
            List<clcommon__Consolidated_Invoice__c> updatedInvoiceList = getInvoiceList(applicationList[0].Id);
            List<clcommon__Notification__c> emailLogList = getEmailLogList();
            System.assertEquals('test.invoice@yopmail.com', updatedInvoiceList[0].Email__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SUCCESS_STATUS, emailLogList[0].Email_Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test Success even if the comment is blank for that invoice
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testSuccesForBlankComment(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = getApplicationList();
        List<clcommon__Consolidated_Invoice__c> updatedInvoiceList = getInvoiceList(applicationList[0].Id);
        updatedInvoiceList[0].Comment__c = '';
        Database.update(updatedInvoiceList[0],true);
        System.runAs(userObj) {
            Test.startTest();
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userObj.Id));
            updatedInvoiceList = getInvoiceList(applicationList[0].Id);
            List<clcommon__Notification__c> emailLogList = getEmailLogList();
            System.assertEquals('test.invoice@yopmail.com', updatedInvoiceList[0].Email__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SUCCESS_STATUS, emailLogList[0].Email_Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
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
        List<genesis__Applications__c> applicationList = getApplicationList();        
        System.runAs(userObj) {
            Test.startTest();
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userObj.Id));
            List<clcommon__Consolidated_Invoice__c> updatedInvoiceList = getInvoiceList(applicationList[0].Id);
           

            List<clcommon__Notification__c> emailLogList = getEmailLogList();
            System.assertEquals('test.invoice@yopmail.com', updatedInvoiceList[0].Email__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SUCCESS_STATUS, emailLogList[0].Email_Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test Success for Gmk CL user 
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testSuccessWithGmkClUser(){
        List<Profile> profileList = getProfileByName('Growmark Certified Lender');
        List<User> userList = getUserByAccoountName('Ross Geller');
        userList[0].ProfileId = profileList[0].Id;
        Database.update(userList[0],true);
        List<genesis__Applications__c> applicationList = getApplicationList();        
        System.runAs(userList[0]) {
            Test.startTest();
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userList[0].Id));
            List<clcommon__Consolidated_Invoice__c> updatedInvoiceList = getInvoiceList(applicationList[0].Id);
            List<clcommon__Notification__c> emailLogList = getEmailLogList();
            System.assertEquals('test.invoice@yopmail.com', updatedInvoiceList[0].Email__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SUCCESS_STATUS, emailLogList[0].Email_Status__c, PortalConstants.ASSERTION_FAILED);
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
        List<genesis__Applications__c> applicationList = getApplicationList();        
        System.runAs(userObj) {
            Test.startTest();
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userObj.Id));
            List<clcommon__Consolidated_Invoice__c> updatedInvoiceList = getInvoiceList(applicationList[0].Id);
            List<clcommon__Notification__c> emailLogList = getEmailLogList();
            System.assertEquals('test.invoice@yopmail.com', updatedInvoiceList[0].Email__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SUCCESS_STATUS, emailLogList[0].Email_Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test Success for Gmk CL Plus user 
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testSuccessWithGmkClPlusUser(){
        List<Profile> profileList = getProfileByName('Growmark Certified Lender Plus');
        List<User> userList = getUserByAccoountName('Peter Geller');
        userList[0].ProfileId = profileList[0].Id;
        Database.update(userList[0],true);
        List<genesis__Applications__c> applicationList = getApplicationList();        
        System.runAs(userList[0]) {
            Test.startTest();
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userList[0].Id));
            List<clcommon__Consolidated_Invoice__c> updatedInvoiceList = getInvoiceList(applicationList[0].Id);
            List<clcommon__Notification__c> emailLogList = getEmailLogList();
            System.assertEquals('test.invoice@yopmail.com', updatedInvoiceList[0].Email__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SUCCESS_STATUS, emailLogList[0].Email_Status__c, PortalConstants.ASSERTION_FAILED);
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
        List<Profile> profileList = getProfileByName('Field Staff Agent');
        List<User> userList = getUserByAccoountName('Ross FieldStaff');
        userList[0].ProfileId = profileList[0].Id;
        Database.update(userList[0],true);
        List<genesis__Applications__c> applicationList = getApplicationList();        
        System.runAs(userList[0]) {
            Test.startTest();
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userList[0].Id));
            List<clcommon__Consolidated_Invoice__c> updatedInvoiceList = getInvoiceList(applicationList[0].Id);
            List<clcommon__Notification__c> emailLogList = getEmailLogList();
            System.assertEquals('test.invoice@yopmail.com', updatedInvoiceList[0].Email__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SUCCESS_STATUS, emailLogList[0].Email_Status__c, PortalConstants.ASSERTION_FAILED);
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
        List<genesis__Applications__c> applicationList = getApplicationList();        
        System.runAs(userObj) {
            Test.startTest();
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userObj.Id));
            List<clcommon__Consolidated_Invoice__c> updatedInvoiceList = getInvoiceList(applicationList[0].Id);
            List<clcommon__Notification__c> emailLogList = getEmailLogList();
            System.assertEquals('test.invoice@yopmail.com', updatedInvoiceList[0].Email__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SUCCESS_STATUS, emailLogList[0].Email_Status__c, PortalConstants.ASSERTION_FAILED);
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
        List<Profile> profileList = getProfileByName('Payment Administrator');
        List<User> userList = getUserByAccoountName('Alexa Aston');
        userList[0].ProfileId = profileList[0].Id;
        Database.update(userList[0],true);
        List<genesis__Applications__c> applicationList = getApplicationList();        
        System.runAs(userList[0]) {
            Test.startTest();
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userList[0].Id));
            List<clcommon__Consolidated_Invoice__c> updatedInvoiceList = getInvoiceList(applicationList[0].Id);
            List<clcommon__Notification__c> emailLogList = getEmailLogList();
            System.assertEquals('test.invoice@yopmail.com', updatedInvoiceList[0].Email__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SUCCESS_STATUS, emailLogList[0].Email_Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test Success for Gmk Payment Admin user 
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testSuccessWithGmkPAUser(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Alexa Aston');
        List<genesis__Applications__c> applicationList = getApplicationList();        
        System.runAs(userObj) {
            Test.startTest();
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userObj.Id));
            List<clcommon__Consolidated_Invoice__c> updatedInvoiceList = getInvoiceList(applicationList[0].Id);
            List<clcommon__Notification__c> emailLogList = getEmailLogList();
            System.assertEquals('test.invoice@yopmail.com', updatedInvoiceList[0].Email__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SUCCESS_STATUS, emailLogList[0].Email_Status__c, PortalConstants.ASSERTION_FAILED);
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
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        List<genesis__Applications__c> applicationList = getApplicationList();        
        System.runAs(userObj) {
            Test.startTest();
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userObj.Id));
            List<clcommon__Consolidated_Invoice__c> updatedInvoiceList = getInvoiceList(applicationList[0].Id);
            List<clcommon__Notification__c> emailLogList = getEmailLogList();
            System.assertEquals('test.invoice@yopmail.com', updatedInvoiceList[0].Email__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SUCCESS_STATUS, emailLogList[0].Email_Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test Success for Gmk Borrower user 
    * @author Suraj Kumar | 11-20-2024 
    **/
    @isTest 
    private static void testSuccessWithGmkBorrowerUser(){
        List<Profile> profileList = getProfileByName('Growmark Grower');
        List<User> userList = getUserByAccoountName('Jasmine Albin');
        userList[0].ProfileId = profileList[0].Id;
        Database.update(userList[0],true);
        List<genesis__Applications__c> applicationList = getApplicationList();        
        System.runAs(userList[0]) {
            Test.startTest();
            PortalSendPaymentReceiptEmailAPI testApi = new PortalSendPaymentReceiptEmailAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), getRequestMap(userList[0].Id));
            List<clcommon__Consolidated_Invoice__c> updatedInvoiceList = getInvoiceList(applicationList[0].Id);
            List<clcommon__Notification__c> emailLogList = getEmailLogList();
            System.assertEquals('test.invoice@yopmail.com', updatedInvoiceList[0].Email__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SUCCESS_STATUS, emailLogList[0].Email_Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

}