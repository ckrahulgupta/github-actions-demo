/**********************************************************************************************
 * @className         : PortalFetchDocusignConfirmationTest
 * @description       : Test Class for PortalFetchDocusignConfirmationTest
 * @author            : simran
 * @created Date      : 05-23-2022
 * @last modified on  : 01-08-2025
 * @last modified by  : Shruti Tamakhuwala
 **********************************************************************************************/
@isTest
public  class PortalFetchDocusignConfirmationTest {
    @testSetup
   static void makeData(){

    // creating application setup
    ApplicationOriginationSetupTestHelper.createTestSetup(); 
    List<genesis__Applications__c> applicationObjList = [SELECT Id,
                                                                 Name,                                                                
                                                                 Internal_Reference_Code__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Internal_Reference_Code__c ='testApp002' 
                                                          LIMIT 1];
    applicationObjList[0].Signing_Method__c = PortalConstants.EMAIL_DOCUSIGN;
    Database.update(applicationObjList[0], true);
    
    //creating content version
    ContentVersion contentObj = ApplicationOriginationTestHelper.createContentVersion();
    contentObj.Title = 'Credit Application Agreement.pdf';
    contentObj.PathOnClient ='/'+contentObj.Title+'.pdf';
    Database.insert(contentObj,true);
    // creating content Document
    ContentDocument contentDocAgreementObj = [SELECT Id 
                                               FROM ContentDocument 
                                               WHERE Title = 'Credit Application Agreement.pdf' 
                                               LIMIT 1];
    // creating ContentDocumentLink
    ContentDocumentLink contentDocLinkAgrmttObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocAgreementObj.id,applicationObjList[0].Id);
    Database.insert(contentDocLinkAgrmttObj,true);
   
   }  
    /**
    * @description To get User to run test
    * @author Shruti Tamakhuwala | 01-07-2025 
    * @param profileName 
    * @return User 
    **/
    private static User getUser(String profileName){
        User userObj = [SELECT Id,
                                Name 
                         FROM USER 
                         WHERE Profile.Name =: profileName 
                         AND IsActive = true 
                         ORDER BY createddate ASC 
                         LIMIT 1];
        return userObj;
    }        
    /**
    * @description Testing success scenario
    * @author Simran | 08-28-2024 
    **/
    @isTest
    public static void testPortalFetchDocusignConfirmationSuccess() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationObjList = [SELECT Id,
                                                                    genesis__Account__c  
                                                              FROM genesis__Applications__c 
                                                              WHERE Signing_Method__c =: PortalConstants.EMAIL_DOCUSIGN 
                                                              LIMIT 1];
        applicationObjList[0].Agreement_Sign__c = true;
        Database.update(applicationObjList[0],true);
        User adminUser = PortalFetchDocusignConfirmationTest.getUser('System Administrator');
        System.runAs(adminUser) {
            Test.startTest();
            requestMap.put('application', Json.serialize(applicationObjList[0]));
            PortalFetchDocusignConfirmation fetchDocuSignInst = new PortalFetchDocusignConfirmation();
            clcommon.Response response = fetchDocuSignInst.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS,response.status, 'Assertion failed for Success scenario');
            Test.stopTest();
        }
    } 
    /**
    * @description Testing exception scenario
    * @author Simran | 08-28-2024 
    **/
    @isTest
    public static void testDocusignConfirmationException(){
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('application', Json.serialize(null));
        User adminUser = PortalFetchDocusignConfirmationTest.getUser('System Administrator');
        System.runAs(adminUser) {
            Test.startTest();
            PortalFetchDocusignConfirmation fetchDocuSignInst = new PortalFetchDocusignConfirmation();
            clcommon.Response response = fetchDocuSignInst.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION,response.status, 'Exception expected for null value in request map key value');
            Test.stopTest();
        }
    }

    /**
    * @description Testing custom exception scenario
    * @author Shruti | 12-26-2024 
    **/
    @isTest
    public static void testDocusignConfirmationCustomException(){
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('application', '');
        User adminUser = PortalFetchDocusignConfirmationTest.getUser('System Administrator');
        System.runAs(adminUser) {
            Test.startTest();
            PortalFetchDocusignConfirmation fetchDocuSignInst = new PortalFetchDocusignConfirmation();
            clcommon.Response response = fetchDocuSignInst.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION,response.status, 'Custom Exception expected for missing value for request map key');
            Test.stopTest();
        }
    }

    /**
    * @description Testing for status pending
    * @author Simran | 08-28-2024 
    **/
    @isTest
    public static void testDocusignPendingStatus(){
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj = [SELECT Id,
                                                          genesis__Account__c  
                                                    FROM genesis__Applications__c 
                                                    WHERE Signing_Method__c=:PortalConstants.EMAIL_DOCUSIGN];
        applicationObj.Agreement_Sign__c = false;
        Database.update(applicationObj,true);
        requestMap.put('application', Json.serialize(applicationObj));
        User adminUser = PortalFetchDocusignConfirmationTest.getUser('System Administrator');
        System.runAs(adminUser) {
            Test.startTest();
            PortalFetchDocusignConfirmation fetchDocuSignInst = new PortalFetchDocusignConfirmation();
            clcommon.Response response = fetchDocuSignInst.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.PENDING,response.status, 'Assertion Failed for Pending Status check');
            Test.stopTest();
        }
    }

    /**
    * @description Testing portal user
    * @author Simran | 08-28-2024 
    **/
    @isTest
    public static void testPortalUser() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationObjList = [SELECT Id,
                                                                    genesis__Account__c 
                                                             FROM genesis__Applications__c 
                                                             WHERE Signing_Method__c=:PortalConstants.EMAIL_DOCUSIGN];
        applicationObjList[0].Agreement_Sign__c = true;
        Database.update(applicationObjList[0],true);
        User clUser = PortalFetchDocusignConfirmationTest.getUser(PortalConstants.CERTIFIED_LENDER);
        System.runAs(clUser) {
            Test.startTest();
            requestMap.put('application', Json.serialize(applicationObjList[0]));
            PortalFetchDocusignConfirmation fetchDocuSignInst = new PortalFetchDocusignConfirmation();
            clcommon.Response response = fetchDocuSignInst.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS,response.status, 'Assertion failed for Portal User');
            Test.stopTest();
        }
    } 
}