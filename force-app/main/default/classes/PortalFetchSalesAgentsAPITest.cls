/**
 * @description       : 
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 12-01-2023
 * @last modified by  : Krishanu Chinya
**/
@IsTest
global without sharing class PortalFetchSalesAgentsAPITest{
    @TestSetup
    static void setup(){
        // creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);
 
        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);
 
        // Creating Contact for Dealer
        Contact dealerContactObj = ApplicationOriginationTestHelper.createDealerContact(dealerAccountObj.Id);
        Database.insert(dealerContactObj, true);

        // creating Account for Certified Lender
        Account clAccountObj = TestClassHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = TestClassHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);

        // creating user for certified lender
        User clUser = TestClassHelper.createCLUser(clContactObj.Id);
        Database.insert(clUser, true);

        //creating a sales agent admin
        Account saAdminAccObj = ApplicationOriginationTestHelper.createSAAdminAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(saAdminAccObj, true);
 
        //createing sa admin contact
        Contact saAdminContactObj=ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccObj.Id);
        Database.insert(saAdminContactObj, true);
 
        //creating sa admin user
        User saAdminUserObj = ApplicationOriginationTestHelper.createSAAdminUser(saAdminContactObj.Id);
        Database.insert(saAdminUserObj, true);

        //creating a sales agent 
        Account saAccObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.Id,dealerAccountObj.Id);
        Database.insert(saAccObj, true);
  
        //createing sa contact
        Contact saContactObj=ApplicationOriginationTestHelper.createSalesAgentContact(saAccObj.Id);
        Database.insert(saContactObj, true);
  
        //creating sa user
        User saUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(saContactObj.Id);
        Database.insert(saUserObj, true);

        //creating sales agent role
        clcommon__Reciprocal_Role__c saRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.SALES_AGENT);
        Database.insert(saRoleObj, true);

        //creating sales agent relationship
        clcommon__Relationship__c saRelationship = ApplicationOriginationTestHelper.createRelWithDealer(saRoleObj, dealerAccountObj.Id, saAccObj.Id);
        Database.insert(saRelationship, true);

        //creating related sales agent  role
        clcommon__Reciprocal_Role__c rsaRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.RELATED_SALES_AGENT);
        Database.insert(rsaRoleObj, true);

        //creating related sales agent  relationship
        clcommon__Relationship__c relationshipObject = ApplicationOriginationTestHelper.createRelWithDealer(rsaRoleObj,saAdminAccObj.Id,saAccObj.Id);
        Database.insert(relationshipObject, true);

        //creating another sales agent 
        //creating a sales agent 
        saAccObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.Id,dealerAccountObj.Id);
        saAccObj.Name = 'Robert Brown';
        saAccObj.Phone = '993211590';
        saAccObj.CIF_Number__c = '000988';
        saAccObj.clcommon__Email__c = 'robert.brown@yopmail.com';
        Database.insert(saAccObj, true);
  
        //createing sa contact
        saContactObj=ApplicationOriginationTestHelper.createSalesAgentContact(saAccObj.Id);
        saContactObj.FirstName='Robert';
        saContactObj.LastName='Brown';
        saContactObj.Email='robert.brown@yopmail.com';
        saContactObj.Phone='993211590';
        Database.insert(saContactObj, true);
  
        //creating sa user
        saUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(saContactObj.Id);
        saUserObj.Email='robert.brown@yopmail.com';
        saUserObj.UserName='robert.brown@yopmail.com';
        Database.insert(saUserObj, true);

    }

    @isTest
     public static void testForSuccess() {
        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

        Account saAdmin = [SELECT Id, Name FROM Account WHERE Name = 'Tim Couper'];
        String saAdminAccId = saAdmin.Id;

        Map<String, Object> request = new Map<String, Object>();
        request.put('saAdminAccountId', saAdminAccId);  
        
        if(objCertifiedLenderUser != null) {
             System.runAs(objCertifiedLenderUser) {
                Test.startTest();
                PortalFetchSalesAgentsAPI  obj= new PortalFetchSalesAgentsAPI();
                clcommon.Response response = obj.invokeAction('', new List<String>(), request);  
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
            }
        }
    }

    @isTest
    public static void testForException() {
       User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

       Map<String, Object> request = new Map<String, Object>();
       request.put('saAdminAccountId', null);  
       
       if(objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
               Test.startTest();
               PortalFetchSalesAgentsAPI  obj= new PortalFetchSalesAgentsAPI();
               clcommon.Response response = obj.invokeAction('', new List<String>(), request);  
               Test.stopTest();
               System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'API_EXCEPTION'); 
           }
       }
    }
}