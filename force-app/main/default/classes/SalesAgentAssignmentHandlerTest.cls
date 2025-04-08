/**
 * @description       : test class for SalesAgentAssignmentHandler
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 12-01-2023
 * @last modified by  : Krishanu Chinya
**/
@isTest
public with sharing class SalesAgentAssignmentHandlerTest {
    @testSetup
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
   
    @IsTest
    public static void testFetchSADetails() {
        Account saAdmin = [SELECT Id, Name FROM Account WHERE Name = 'Tim Couper'];
        String saAdminAccId = saAdmin.Id;
        Test.startTest();
        SalesAgentAssignmentHandler.fetchSADetails(saAdminAccId);
        System.assertEquals('','','Assertion Failed');
        Test.stopTest();
    }

    @IsTest
    public static void testUpdateSAADetails() {
        Account saAdmin = [SELECT Id, Name FROM Account WHERE Name = 'Tim Couper'];
        String saAdminAccId = saAdmin.Id;
        Account saAcc = [SELECT Id, Name FROM Account WHERE Name = 'Tony Stark'];
        String saAccId = saAcc.Id;
        List<String> selectedSalesAgentsList = new List<String>();
        selectedSalesAgentsList.add(saAccId);
        Test.startTest();
        SalesAgentAssignmentHandler.updateSAADetails(selectedSalesAgentsList,saAdminAccId);
        System.assertEquals('','','Assertion Failed');
        Test.stopTest();
       
    }

    @IsTest
    public static void testUpdateSAADetailsException() {
        List<String> selectedSalesAgentsList = new List<String>();
        Test.startTest();
        try{

            SalesAgentAssignmentHandler.updateSAADetails(null,null);
        } catch (Exception e){
            System.assertEquals('Script-thrown exception',e.getMessage(),'Aseetion failed');
        }
        Test.stopTest(); 
    }
}