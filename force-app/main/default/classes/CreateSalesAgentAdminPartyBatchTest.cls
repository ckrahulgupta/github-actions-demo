/**
 * @description       : 
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 11-01-2025
 * @last modified by  : Soumik Pattanayak
**/
@IsTest
private with sharing class CreateSalesAgentAdminPartyBatchTest {
    @testSetup
    static void setup() {
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

        // creating relationship of certified lender
        clcommon__Reciprocal_Role__c clRoleObj = TestClassHelper.createReciprocalRole('Certified Lender');
        Database.insert(clRoleObj, true);
        clcommon__Relationship__c objRelationship = TestClassHelper.createCLDealerRelationship(clRoleObj, 
                                                                                                    dealerAccountObj.Id, 
                                                                                                    clAccountObj.Id);
        Database.insert(objRelationship, true);
        

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

        // Creating CL Product for Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProduct();
        Database.insert(clProductObj,true);

        // Creating CL Purpose for Application
        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);

        // creating borrower
        clcommon__Legal_Entity__c entityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(entityObj,true);

        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj,dealerBusinessInfoObj.id);
        //borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.insert(borrowerAccountObj,true);

        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        Database.insert(borrowerContactObj,true);

        //creating dealer applicant relationship
        Dealer_Applicant_Relationship__c relationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,borrowerAccountObj.Id);
        Database.insert(relationObj, true);

        // creating application
        Map<String, Id> paramForApplicationMap = new Map<String, Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'clAccountId' => clAccountObj.Id,
            'dealerApplicantRelationshipId' => relationObj.Id
        };

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(paramForApplicationMap);
        applicationObj.Sales_Agent__c = saAccObj.Id;
        Database.insert(applicationObj,true); 
      
        clcommon__Document_Category__c docCatagory = ApplicationOriginationTestHelper.createDocCategory(applicationObj.Id, null);
        Database.insert(docCatagory, true);

    }

    /**
    * @description 
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @IsTest
    private static void testBatch() {
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        List<Account> saAdminList = [SELECT Id, Name FROM Account WHERE Name = 'Tim Couper'];
        String saAdminAccId = saAdminList[0].Id;

        List<Account> saAccountList = [SELECT Id, Name FROM Account WHERE Name = 'Tony Stark'];
        List<Account> saAccList = [SELECT Id, Name FROM Account WHERE Name = 'Robert Brown'];
        List<Id> saAccountIdList = new List<Id>();
        saAccountIdList.add(saAccountList[0].Id);
        saAccountIdList.add(saAccList[0].Id);
        
        System.runAs(userObj){
            Test.startTest();
            CreateSalesAgentAdminPartyBatch batchObj = new CreateSalesAgentAdminPartyBatch(saAccountIdList, saAdminAccId);
            Database.executeBatch(batchObj, 20);
            Test.stopTest();
        }
        System.assertEquals(0, [SELECT Id FROM clcommon__Log__c WHERE Name =: PortalFetchSalesAgentsAPITest.class.getName()].size(), PortalConstants.ASSERTION_FAILED);
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @IsTest
    private static void testBatchforException() {
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        Integer partyCount=[SELECT Id FROM clcommon__Party__c].size();
        System.runAs(userObj){
            Test.startTest();
            CreateSalesAgentAdminPartyBatch batchObj = new CreateSalesAgentAdminPartyBatch(null, null);
            Database.executeBatch(batchObj, 20);
            Test.stopTest();
        }
        System.assertEquals(false, [SELECT Id FROM clcommon__Party__c].size()>partyCount, PortalConstants.ASSERTION_FAILED);

    }
}