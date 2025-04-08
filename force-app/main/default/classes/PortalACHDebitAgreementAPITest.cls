/**********************************************************************************************************************
 * @description       : Test Class for Portal ACH Debit Agreement API
 * @author            : Pritam
 * @group             : 
 * @last modified on  : 01-23-2025
 * @last modified by  : Ayan Khanra
**********************************************************************************************************************/
@isTest
private without sharing class PortalACHDebitAgreementAPITest {
    /**
    * @description : This method is to prepare data for the test class
    * @author Ayan Khanra | 01-12-2025 
    **/
    @TestSetup
    static void makeData(){
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);
        //Create Standard User
        User prodAgUserObj = ApplicationOriginationTestHelper.createStandardUser();
        Database.insert(prodAgUserObj,true);
        //Create Dealer Account
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.ACH_Debit_Agreement_Status__c = 'Not Submitted';
        dealerAccountObj.Production_Ag_Loan_Officer__c = prodAgUserObj.Id;
        Database.insert(dealerAccountObj, true);
        //Create Certified Lender Account
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);
        //Create Cerfied Lender Contact
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);
        //Create Certified Lender Resiprocal Role
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(clRoleObj,true);
        //Create Certifid Lender Dealer Relation 
        clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj, dealerAccountObj.Id, clAccountObj.Id);
        Database.insert(clDealerRelationshipObj,true);
        //Create Certified Lender User
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        Database.insert(clUserObj,true);
        //Create Content Version
        ContentVersion contentVersionObj = ApplicationOriginationTestHelper.createContentVersion();
        Database.insert(contentVersionObj,true);
        //Create Content Documnt
        ContentDocument contentDocumentList = [SELECT ID FROM ContentDocument WHERE Title=:contentVersionObj.Title];
        //Create Content Document Link
        ContentDocumentLink contentDocumentClLinkObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocumentList.Id,clAccountObj.Id);
        Database.insert(contentDocumentClLinkObj,true);
        createMultipleUser(dealerBusinessInfoObj.Id,dealerAccountObj);      
    }

    /**
    * @description : This method creates Diffrent Account
    * @author Ayan Khanra | 01-06-2025 
    * @param dealerBusinessInfoId 
    * @param dealerAccountObj 
    **/
    private static void createMultipleUser(Id dealerBusinessInfoId,Account dealerAccountObj){
        //account
        Account clPlusAccountObj = ApplicationOriginationTestHelper.createCLPlusAccount(dealerBusinessInfoId,dealerAccountObj.id);
        Account fsaAccountObj = ApplicationOriginationTestHelper.createFSAgentAccount(dealerBusinessInfoId,dealerAccountObj.id);
        Account saAdminAccountObj = ApplicationOriginationTestHelper.createSAAdminAccount(dealerBusinessInfoId,dealerAccountObj.id);
        List<Account> accountToInsertList = new List<Account>{clPlusAccountObj,fsaAccountObj,saAdminAccountObj};
        Database.insert(accountToInsertList,true);
        //contact
        Contact clPlusContactObj = ApplicationOriginationTestHelper.createCLPlusContact(clPlusAccountObj.Id);
        Contact fsaContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(fsaAccountObj.Id);
        Contact saAdminContactObj = ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccountObj.Id);
        List<Contact> contactToInsertList = new List<Contact>{clPlusContactObj,fsaContactObj,saAdminContactObj};
        Database.insert(contactToInsertList,true);
        //User
        User fsaUserObj = ApplicationOriginationTestHelper.createFSAgentUser(fsaContactObj.Id);
        User saAdminUerObj = ApplicationOriginationTestHelper.createSAAdminUser(saAdminContactObj.Id);
        User clPlusObj = createclPlusUser(clPlusContactObj.Id);
        Database.insert(new List <User>{fsaUserObj,saAdminUerObj,clPlusObj},true);
    }

    /**
    * @description : This method returns Certified lender plus user
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
        clUserObj.UserName='peter.geller@yopmail.com';
        return clUserObj;
    }

    /**
    * @description : This method checks for received success response for saAdmin User
    * @author Ayan Khanra | 01-06-2025 
    **/
    @isTest
    private static void testForSaAdminSuccess(){
        List<ContentDocumentLink> contentDocumentLinkList = getContenDocumentLink();
        Map<String, String> requestMap = new Map<String, String>();
        requestMap.put('documentId',contentDocumentLinkList[0].Id);
        List<User> userList = getUser('tim.couper@yopmail.com');                       
        System.runAs(userList[0]){
            Test.startTest();
            PortalACHDebitAgreementAPI achDebitAgreementAPIInst = new PortalACHDebitAgreementAPI();
            clcommon.Response response  = achDebitAgreementAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.Status, 'Success message not received');
            Test.stopTest();                                                                          
        }
    }

    /**
    * @description : This method checks for received success response for clPlus User
    * @author Ayan Khanra | 01-06-2025 
    **/
    @isTest
    private static void testForclPlusSuccess(){
        List<ContentDocumentLink> contentDocumentLinkList = getContenDocumentLink();
        Map<String, String> requestMap = new Map<String, String>();
        requestMap.put('documentId',contentDocumentLinkList[0].Id);
        List<User> userList = getUser('peter.geller@yopmail.com');                        
        System.runAs(userList[0]){
            Test.startTest();
            PortalACHDebitAgreementAPI achDebitAgreementAPIInst = new PortalACHDebitAgreementAPI();
            clcommon.Response response  = achDebitAgreementAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.Status, 'Success message not received');
            Test.stopTest();                                                                          
        }
    }

    /**
    * @description : This method Tests for Successful Category Attachment creation
    * @author Ayan Khanra | 01-06-2025 
    **/
    @isTest
    private static void testDocCategoryAndCategoryAttachmentCreationSuccess(){
        List<ContentDocumentLink> contentDocumentLinkList = getContenDocumentLink();
        Map<String, String> requestMap = new Map<String, String>();
        requestMap.put('documentId',contentDocumentLinkList[0].Id);
        List<User> clUserList =  getUser();                       
        System.runAs(clUserList[0]){
            Test.startTest();
            PortalACHDebitAgreementAPI achDebitAgreementAPIInst = new PortalACHDebitAgreementAPI();
            clcommon.Response response  = achDebitAgreementAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.Status, 'Success message not received');
            List<clcommon__Document_Category__c> categoryList =  getDocumentCategory(clUserList[0]);
            System.assertEquals(1,categoryList.size(),'New Document Category Should Have created');
            List<clcommon__Category_Attachment_Association__c> categoryAttachmentList =[SELECT Id,
                                                                                                Name,
                                                                                                Account__c,
                                                                                                clcommon__Content_Document_Id__c
                                                                                        FROM clcommon__Category_Attachment_Association__c 
                                                                                        WHERE clcommon__Document_Category__r.clcommon__Category_Name__c = : 'ACH Debit Agreement'  
                                                                                        AND Account__c =: clUserList[0].Account.ParentId
                                                                                        AND Name = 'ACH Debit Agreement V1'];
            System.assertEquals(1,categoryAttachmentList.size(),'Catgory Attachment Association record should have created'); 
            Test.stopTest();                                                                                                                       
        }
    }

    /**
    * @description : This method Tests Successful Status change and  creates document category share 
    * @author Ayan Khanra | 01-06-2025 
    **/
    @isTest
    private static void testAchStatusChangeSuccess(){
        List<ContentDocumentLink> contentDocumentLinkList = getContenDocumentLink();
        Map<String, String> requestMap = new Map<String, String>();
        requestMap.put('documentId',contentDocumentLinkList[0].Id);
        List<User> clUserList =  getUser();                       
        System.runAs(clUserList[0]){
            Test.startTest();
            PortalACHDebitAgreementAPI achDebitAgreementAPIInst = new PortalACHDebitAgreementAPI();
            clcommon.Response response  = achDebitAgreementAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.Status, 'Success message not received');
            List<clcommon__Document_Category__c> categoryList =  getDocumentCategory(clUserList[0]);
            List<clcommon__Document_Category__Share> categoryShareList = [SELECT Id  
                                                                        FROM clcommon__Document_Category__Share 
                                                                        WHERE ParentId =: categoryList[0].Id
                                                                        AND UserOrGroupId = :clUserList[0].Id];
            System.assertEquals(1,categoryShareList.size(),'New Document Category not created'); 
            Test.stopTest();                                                                      
        }
        List<Account> dealerAccountList = [SELECT Id,
                                                    Name,
                                                    ACH_Debit_Agreement_Status__c
                                        FROM Account 
                                        WHERE Id = : clUserList[0].Account.ParentId];
        System.assertEquals('In Review',dealerAccountList[0].ACH_Debit_Agreement_Status__c,'Status did not changed');
    } 

    /**
    * @description : This method Tests for new category Attachment creation
    * @author Ayan Khanra | 12-30-2024 
    **/
    @isTest
    private static void testNewCategoryAttachmentAssociationSuccess(){
        List<User> clUserList = getUser();
        List<ContentDocumentLink> contentDocumentLinkList = getContenDocumentLink();
        Map<String, String> requestMap = new Map<String, String>();
        requestMap.put('documentId',contentDocumentLinkList[0].Id);
        clcommon__Document_Category__c documentCategoryObj = ApplicationOriginationTestHelper.createAccDocumentCategory(clUserList[0].Account.ParentId);
        documentCategoryObj.clcommon__Category_Name__c = 'ACH Debit Agreement';
        Database.upsert(documentCategoryObj,true);
        clcommon__Category_Attachment_Association__c categoryAssociationObj = ApplicationOriginationTestHelper.createAttachmentAssociation(documentCategoryObj,clUserList[0].Account.ParentId);
        categoryAssociationObj.clcommon__Content_Document_Id__c = contentDocumentLinkList[0].ContentDocumentId;
        categoryAssociationObj.Name = 'ACH Debit Agreement V1';
        Database.upsert(categoryAssociationObj,true);
        System.runAs(clUserList[0]){
            PortalACHDebitAgreementAPI achDebitAgreementAPIInst = new PortalACHDebitAgreementAPI();
            Test.startTest();
            clcommon.Response response  = achDebitAgreementAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.Status, 'Success message not received');
            List<clcommon__Category_Attachment_Association__c> categoryAttachmentList =[SELECT Id,
                                                                                                Name,
                                                                                                Account__c,
                                                                                                clcommon__Content_Document_Id__c
                                                                                        FROM clcommon__Category_Attachment_Association__c 
                                                                                        WHERE clcommon__Document_Category__r.clcommon__Category_Name__c = : 'ACH Debit Agreement'  
                                                                                        AND Account__c =: clUserList[0].Account.ParentId
                                                                                        AND Name = 'ACH Debit Agreement V2'];
            System.assertEquals(1,categoryAttachmentList.size(),'New category attachment not created');
            Test.stopTest();
        }
    } 

    /**
    * @description : This method Tests exception for no 'documentId' in request
    * @author Ayan Khanra | 12-30-2024 
    **/
    @IsTest
    private static void testDocumentIdMissingException(){    
        List<User> clUserList = getUser();
        Map<String, String> requestMap = new Map<String, String>();
        requestMap.put('documentId',null);
        System.runAs(clUserList[0]){
            Test.startTest();
            PortalACHDebitAgreementAPI achDebitAgreementAPIInst = new PortalACHDebitAgreementAPI();
            clcommon.Response response  = achDebitAgreementAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.Status, PortalConstants.ASSERTION_FAILED);
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Exception Log not inserted');
            Test.stopTest();
        }                        
    }

    /**
    * @description : This method Tests for missing content documnet Key exception 
    * @author Ayan Khanra | 12-30-2024 
    **/
    @IsTest
    private static void testContentDocumentKeyExceptionAndLogInsertion(){    
        List<User> clUserList = getUser();
        List<ContentDocumentLink> contentDocumentLinkList =  getContenDocumentLink(); 
        Map<String, String> requestMap = new Map<String, String>();
        requestMap.put('',contentDocumentLinkList[0].Id);  
        System.runAs(clUserList[0]){
            Test.startTest();
            PortalACHDebitAgreementAPI achDebitAgreementAPIInst = new PortalACHDebitAgreementAPI();
            clcommon.Response response  = achDebitAgreementAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.Status, PortalConstants.ASSERTION_FAILED);
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'exception Log not inserted');
            Test.stopTest();
        }                        
    }

    /**
    * @description : This method Tests exception for no contentDocument present 
    * @author Ayan Khanra | 12-30-2024 
    **/
    @isTest
    private static void  testContentDocumentMissingException(){
        List<User> clUserList = getUser();                                                    
        List<ContentDocument> contentDocumentList = getContenDocument();
        List<ContentDocumentLink> contentDocumentLinkList =  getContenDocumentLink();                                             
        Database.delete(contentDocumentList,true);
        Map<String, String> requestMap = new Map<String, String>();
        requestMap.put('documentId',contentDocumentLinkList[0].Id);                                                                       
        System.runAs(clUserList[0]){
            Test.startTest();
            PortalACHDebitAgreementAPI achDebitAgreementAPIInst = new PortalACHDebitAgreementAPI();
            clcommon.Response response  = achDebitAgreementAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.Status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }                        
    }

    /**
    * @description : Query Util function for contenDocumentLink
    * @author Ayan Khanra | 01-05-2025 
    * @return ContentDocumentLink 
    **/
    private static List<ContentDocumentLink> getContenDocumentLink(){
        return  [SELECT Id,
                        ContentDocumentId 
                FROM ContentDocumentLink 
                WHERE ContentDocument.Title =: PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
    }
    /**
    * @description : Query util function to get contentDocument
    * @author Ayan Khanra | 01-05-2025 
    * @return ContentDocument 
    **/
    private static List<contentDocument> getContenDocument(){
        return [SELECT Id 
                FROM ContentDocument 
                WHERE Title =: PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
    }
    /**
    * @description : Query util function to get cl User
    * @author Ayan Khanra | 01-06-2025 
    * @return List<User> 
    **/
    private static List<User> getUser(){
        return [SELECT Id, 
                        Name, 
                        Username,
                        Account.ParentId
                FROM User
                WHERE Username = 'ross.geller@yopmail.com' LIMIT 1];
    }
    /**
    * @description : Query Util function to get Document Category
    * @author Ayan Khanra | 01-06-2025 
    * @param clUserObj 
    * @return List<clcommon__Document_Category__c> 
    **/
    private static List<clcommon__Document_Category__c> getDocumentCategory(User clUserObj){
        return [SELECT Id, 
                        clcommon__Category_Name__c
                FROM clcommon__Document_Category__c 
                WHERE clcommon__Account__c =: clUserObj.Account.ParentId
                AND clcommon__Category_Name__c = 'ACH Debit Agreement'];
    }

    /**
    * @description : Returns User based on userName
    * @author Ayan Khanra | 01-07-2025 
    * @param name 
    * @return List<User> 
    **/
    private static List<User> getUser(String name){
        return [SELECT ID 
                FROM User 
                WHERE UserName =: name Limit 1];
    }
    
    /**
    * @description : This method returns inserted logs
    * @author Ayan Khanra | 01-07-2025 
    * @return List<clcommon__Log__c> 
    **/
    private static List<clcommon__Log__c> getInsertedLog(){
        return [SELECT ID
                FROM clcommon__Log__c 
                WHERE Name = 'PortalACHDebitAgreementAPI' Limit 1];
    }

}