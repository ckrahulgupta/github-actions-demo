/**
 * @description       : Test Class For PortalFetchACHDebitAgreementDocument
 * @author            : Tuhin Bhunia
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : Ayan Khanra
**/
@IsTest
private with sharing class PortalFetchACHDebitAgreementDocumentTest {
    
    /**
    * @description : This method is to prepare data for the test class
    * @author Ayan Khanra | 01-12-2025 
    **/
    @TestSetup
    static void makeData(){
        // Creating dealer business info
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.Insert(dealerBusinessInfoObj, true);
        // Creating dealer accounts
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.Insert(dealerAccountObj, true);
        //creating certified lender Account
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        //creating sales agent account
        Account saAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(null, null); // not linked with dealer
        Database.Insert(new List<Account>{clAccountObj,saAccountObj}, true);
        //creating sales agent contact
        Contact saContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(saAccountObj.Id);
        // Creating Contacts
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.Insert(new List<Contact>{clContactObj,saContactObj}, true);
        // Creating reciprocal roles
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(clRoleObj,true);
        // Creating  dealer relationship
        clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj, dealerAccountObj.id, clAccountObj.id);
        Database.insert(clDealerRelationshipObj,true);
        // Creating User 
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.id);
        Database.insert(clUserObj,true);
        // Sales agent user with no dealer for exception scenario
        User saUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(saContactObj.Id);
        Database.insert(saUserObj,true);
        ContentVersion contentVersionObj = ApplicationOriginationTestHelper.createContentVersion();
        Database.insert(contentVersionObj,true);
        ContentDocument contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title =: contentVersionObj.Title];
        ContentDocumentLink contentDocumentLinkObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocumentObj.id, dealerAccountObj.id);
        Database.insert(contentDocumentLinkObj,true);
        clcommon__Document_Category__c categoryObj = ApplicationOriginationTestHelper.createAccDocumentCategory(dealerAccountObj.id);
        Database.insert(categoryObj,true);
        clcommon__Category_Attachment_Association__c categoryAssociationObj = ApplicationOriginationTestHelper.createAttachmentAssociation(categoryObj,dealerAccountObj.id);
        categoryAssociationObj.clcommon__Content_Document_Id__c = contentDocumentObj.Id;
        Database.insert(categoryAssociationObj,true);
        createMultipleUser(dealerBusinessInfoObj.Id, dealerAccountObj);
    }
    /**
    * @description : This method Gives expected success response for contexr of cl user
    * @author Ayan Khanra | 01-05-2025 
    **/
    @isTest
    private static void testSuccessResponse(){
        List<User> clUserList = getUser('ross.geller@yopmail.com');
        Map<String, String> requestMap = new Map<String, String>();
        System.runAs(clUserList[0]){
            Test.startTest();
            PortalFetchACHDebitAgreementDocument achDebitAgreementAPIInst = new PortalFetchACHDebitAgreementDocument();
            clcommon.Response response  = achDebitAgreementAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.Status, 'Expected Success response not received');
            Test.stopTest();
        }
    }
    /**
    * @description : This Method gives exception upon no dealer linked with logged in user
    * @author Ayan Khanra | 01-06-2025 
    **/
    @isTest
    private static void testSalesAgentWithNoDealerException(){
        List<User> saUserList = getUser('tony.stark@yopmail.com');
        Map<String, String> requestMap = new Map<String, String>();
        System.runAs(saUserList[0]){
            Test.startTest();
            PortalFetchACHDebitAgreementDocument achDebitAgreementAPIInst = new PortalFetchACHDebitAgreementDocument();
            clcommon.Response response  = achDebitAgreementAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.Status, PortalConstants.ASSERTION_FAILED);
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'exception Log not inserted');
            Test.stopTest();
        }
    }
    /**
    * @description : This Method gives success response in sales agent Admin context 
    * @author Ayan Khanra | 01-06-2025 
    **/
    @IsTest
    private static void testSAAdminUserSuccess(){
        List<User> saAdminUserList = getUser('tim.couper@yopmail.com'); 
        Map<String, String> requestMap = new Map<String, String>();
        System.runAs(saAdminUserList[0]){
            Test.startTest();
            PortalFetchACHDebitAgreementDocument achDebitAgreementAPIInst = new PortalFetchACHDebitAgreementDocument();                                   
            clcommon.Response response  = achDebitAgreementAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.Status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }                      
    }
    /**
    * @description : This Method gives success response in Payment Admin context
    * @author Ayan Khanra | 01-06-2025 
    **/
    @IsTest
    private static void testPaymentAdminUserSuccess(){
        List<User> paymentAdminList = getUser('alexa.astonjZmdou9e1g@yopmail.com');  
        Map<String, String> requestMap = new Map<String, String>();
        System.runAs(paymentAdminList[0]){
            Test.startTest();
            PortalFetchACHDebitAgreementDocument achDebitAgreementAPIInst = new PortalFetchACHDebitAgreementDocument();              
            clcommon.Response response = achDebitAgreementAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.Status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }                    
    }
    /**
    * @description : This Method gives success response in certified lender context
    * @author Ayan Khanra | 01-06-2025 
    **/
    @Istest
    private static void testClplusUserSuccess(){
        List<User> clPlusUserList = getUser('peter.geller2983ue42435@yopmail.com');
        Map<String, String> requestMap = new Map<String, String>();
        System.runAs(clPlusUserList[0]){
            Test.startTest();
            PortalFetchACHDebitAgreementDocument achDebitAgreementAPIInst = new PortalFetchACHDebitAgreementDocument();
            clcommon.Response response  = achDebitAgreementAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.Status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }                               
    }
    /**
    * @description : Generic method to get User
    * @author Ayan Khanra | 01-06-2025 
    * @param name 
    * @return List<User> 
    **/
    private static List<User> getUser(String name){
        return [SELECT ID 
                FROM User 
                WHERE UserName =: name Limit 1];
    }
    /**
    * @description :This method creates Payment Admin User
    * @author Ayan Khanra | 01-06-2025 
    * @param contactID 
    * @return User 
    **/
    private static User createPaymentAdminUser(Id contactID){
        Profile clProfileObj = [SELECT Id
                                FROM Profile
                                WHERE Name =: PortalConstants.PAYMENT_ADMINISTRATOR
                                LIMIT 1];
        User clUserObj = new User();
        clUserObj.Alias = 'newUser';
        clUserObj.Email='alexa.aston@yopmail.com';
        clUserObj.EmailEncodingKey='UTF-8';
        clUserObj.LastName='Testing';
        clUserObj.LanguageLocaleKey='en_US';
        clUserObj.LocaleSidKey='en_US';
        clUserObj.ProfileId = clProfileObj.Id;
        clUserObj.ContactId = contactID;
        clUserObj.TimeZoneSidKey='America/Los_Angeles';
        clUserObj.UserName='alexa.astonjZmdou9e1g@yopmail.com';
        return clUserObj;
    }
    /**
    * @description : This Method Creates Cerfied Lender Plus User
    * @author Ayan Khanra | 01-06-2025 
    * @param contactID 
    * @return User 
    **/
    private static User createclPlusUser(Id contactID){
        Profile clProfileObj = [SELECT Id
                                FROM Profile
                                WHERE Name =: PortalConstants.CERTIFIED_LENDER_PLUS
                                LIMIT 1];
        User clUserObj = new User();
        clUserObj.Alias = 'newUser';
        clUserObj.Email='peter.geller@yopmail.com';
        clUserObj.EmailEncodingKey='UTF-8';
        clUserObj.LastName='Testing';
        clUserObj.LanguageLocaleKey='en_US';
        clUserObj.LocaleSidKey='en_US';
        clUserObj.ProfileId = clProfileObj.Id;
        clUserObj.ContactId = contactID;
        clUserObj.TimeZoneSidKey='America/Los_Angeles';
        clUserObj.UserName='peter.geller2983ue42435@yopmail.com';
        return clUserObj;
    }
    /**
    * @description : This method creates Multiple Users
    * @author Ayan Khanra | 01-06-2025 
    * @param dealerBusinessInfoId 
    * @param dealerAccountObj 
    **/
    private static void createMultipleUser(Id dealerBusinessInfoId,Account dealerAccountObj){
        //create account
        Account clPlusAccountObj = ApplicationOriginationTestHelper.createCLPlusAccount(dealerBusinessInfoId,dealerAccountObj.id);
        Account paAccountObj = ApplicationOriginationTestHelper.createPaymentAdministratorAccount(dealerBusinessInfoId,dealerAccountObj.id);
        Account saAdminAccountObj = ApplicationOriginationTestHelper.createSAAdminAccount(dealerBusinessInfoId,dealerAccountObj.id);
        List<Account> accountToInsertList = new List<Account>{clPlusAccountObj,paAccountObj,saAdminAccountObj};
        Database.insert(accountToInsertList,true);
        //create contact
        Contact clPlusContactObj = ApplicationOriginationTestHelper.createCLPlusContact(clPlusAccountObj.Id);
        Contact paContactObj = ApplicationOriginationTestHelper.createPaymentAdministratorContact(paAccountObj.Id);
        Contact saAdminContactObj = ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccountObj.Id);
        List<Contact> contactToInsertList = new List<Contact>{clPlusContactObj,paContactObj,saAdminContactObj};
        Database.insert(contactToInsertList,true);
        //create User
        User saAdminUerObj = ApplicationOriginationTestHelper.createSAAdminUser(saAdminContactObj.Id);
        User clPlusObj = createclPlusUser(clPlusContactObj.Id);
        User pauserObj = createPaymentAdminUser(paContactObj.Id);
        Database.insert(new List <User>{saAdminUerObj,clPlusObj,pauserObj},true);  
    }

    /**
    * @description : This method returns inserted logs
    * @author Ayan Khanra | 01-07-2025 
    * @return List<clcommon__Log__c> 
    **/
    private static List<clcommon__Log__c> getInsertedLog(){
        return [SELECT ID
                FROM clcommon__Log__c 
                WHERE Name = 'PortalFetchACHDebitAgreementDocument' Limit 1];
    }

}