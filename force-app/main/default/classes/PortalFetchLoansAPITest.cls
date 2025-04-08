/**
 * @description       : Test class for PortalFetchLoanAPI
 * @author            : E. Shalini
 * @group             : 
 * @last modified on  : 03-10-2025
 * @last modified by  : Rahul Gorai
**/
@isTest
public class PortalFetchLoansAPITest {

  @TestSetup
    static void setup(){

        // Creating Business information
        genesis__Business_Information__c dealerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj,true);
        // creating cl product
        clcommon__CL_Product__c clProductObj=LoanServicingTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);
        // creating cl purpose
        clcommon__CL_Purpose__c clPurposeObj=LoanServicingTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj,true);
        // creating legal entity 
        clcommon__Legal_Entity__c entityObj= LoanServicingTestHelper.createLegalEntity('Individual(s) - Sole Proprietorship');
        Database.insert(entityObj,true);
        // Creating dealer account
        Account dealerAccountObj = LoanServicingTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        //creating borrower account
        Account borrowerAccountObj=LoanServicingTestHelper.createSolePropAccount(entityObj,LoanServicingTestHelper.createBusinessInfoForBorrower().Id);
        Account clAccountObj = LoanServicingTestHelper.createCLAccount(dealerBusinessInfoObj.Id,dealerAccountObj.Id);
        Database.insert(new List<Account>{dealerAccountObj,borrowerAccountObj, clAccountObj}, true);
        
        // creating certified lender contact
        Contact clContactObj = LoanServicingTestHelper.createCLContact(clAccountObj.Id);
        //creating borrower contact
        Contact borrowerContactObj=LoanServicingTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(new List<Contact>{clContactObj,borrowerContactObj}, true);
        // creating cl user
        User clUserObj = LoanServicingTestHelper.createCLUser(clContactObj.Id);
        // Creating borrower user
        User borrowerUserObj = LoanServicingTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(new List<User>{clUserObj,borrowerUserObj}, true);

        // creating Reciprocal role
        clcommon__Reciprocal_Role__c roleObj = LoanServicingTestHelper.createReciprocalRole('Certified Lender');
        Database.insert(roleObj,true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = LoanServicingTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        
        Dealer_Applicant_Relationship__c relationObj = LoanServicingTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Database.insert(relationObj,true);
      
        Map<String,Id> paramIdMap=new Map<String,Id>();
        paramIdMap.put('dealerAccountId',dealerAccountObj.Id);
        paramIdMap.put('clProductId',clProductObj.Id);
        paramIdMap.put('clPurposeId',clPurposeObj.Id);
        paramIdMap.put('borrowerAccountId',borrowerAccountObj.Id);
        paramIdMap.put('borrowerContactId',borrowerContactObj.Id);
        paramIdMap.put('clAccountId',clAccountObj.Id);
        //creating application obj
        genesis__Applications__c applicationObj = LoanServicingTestHelper.createCurrCropYearApplication(paramIdMap);
        applicationObj.Dealer_Applicant_Relationship__c = relationObj.Id;
        Database.insert(applicationObj,true);

        // Creating Borrower Party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = LoanServicingTestHelper.createPartyType(PortalConstants.PRINCIPAL_PARTY_NAME);
        Database.insert(borrowerPartyTypeObj, true);

        // Creating Borrower Party
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>();
        paramForBorrowerPartyMap.put('accountId', borrowerAccountObj.Id);
        paramForBorrowerPartyMap.put('contactId', borrowerContactObj.Id);
        paramForBorrowerPartyMap.put('partyTypeId', borrowerPartyTypeObj.Id);
        paramForBorrowerPartyMap.put('applicationId', applicationObj.Id);
        clcommon__Party__c borrowerPartyObj = LoanServicingTestHelper.createParty(paramForBorrowerPartyMap);
        borrowerPartyObj.Dealer_Applicant_Relationship__c = relationObj.Id;
        Database.insert(borrowerPartyObj);

        // Creating Certified Lender Party Type
        clcommon__Party_Type__c clPartyTypeObj = LoanServicingTestHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(clPartyTypeObj, true);

        // Creating Certified Lender Party
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>();
        paramForCLPartyMap.put('accountId', clAccountObj.Id);
        paramForCLPartyMap.put('contactId', clContactObj.Id);
        paramForCLPartyMap.put('partyTypeId', clPartyTypeObj.Id);
        paramForCLPartyMap.put('applicationId', applicationObj.Id);
        clcommon__Party__c clPartyObj = LoanServicingTestHelper.createParty(paramForCLPartyMap);
        Database.insert(clPartyObj, true);

    }

  //Test Method to cover the Current crop year loans for ACTIVE status
  @isTest
  public static void testApiForCurrentCropYearActiveStatus(){
    User objUser = [SELECT Id FROM User WHERE UserName='ross.geller@yopmail.com'];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList = [SELECT Id, genesis__Status__c, Dealer_Applicant_Relationship__c FROM genesis__Applications__c WHERE Loan_Id__c = '139000' LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.ACTIVE_APPLICATION_STATUS;
    Dealer_Applicant_Relationship__c dealerApplicantRelation =  new Dealer_Applicant_Relationship__c(Id = applicationObjList[0].Dealer_Applicant_Relationship__c);
    dealerApplicantRelation.Is_Evergreen_Eligible__c = true;
    Database.update(applicationObjList[0],true);
    Database.update(dealerApplicantRelation,true);

    List<Account> accountObjList = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
    // accountObjList[0].Is_Evergreen_Allowed__c = true;
    // Database.update(accountObjList[0], true);
    requestMap.put('filter','CURRENT CROP YEAR');
    requestMap.put('accountId',accountObjList[0].Id);
    if(objUser != null){
      System.runAs(objUser){
        Test.startTest();
        // calling the Api
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  //Test Method to cover the Current crop year loans for CLOSED status PortalConstants.CLOSED_APPLICATION_STATUS;
  @isTest
  public static void testApiForCurrentCropYearClosedStatus(){
    User objUser = [SELECT Id FROM User WHERE UserName='ross.geller@yopmail.com'];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList = [SELECT Id, genesis__Status__c FROM genesis__Applications__c WHERE Loan_Id__c = '139000' LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.CLOSED_APPLICATION_STATUS;
    Database.update(applicationObjList[0],true);

    List<Account> accountObjList = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];

    requestMap.put('filter','CURRENT CROP YEAR');
    requestMap.put('accountId',accountObjList[0].Id);
    if(objUser != null){
      System.runAs(objUser){
        Test.startTest();
        // calling the Api
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  //Test Method to cover the Current crop year loans for APPROVED status APPROVED_APPLICATION_STATUS
  @isTest
  public static void testApiForCurrentCropYearApprovedStatus(){
    User objUser = [SELECT Id FROM User WHERE UserName='ross.geller@yopmail.com'];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList = [SELECT Id, genesis__Status__c FROM genesis__Applications__c WHERE Loan_Id__c = '139000' LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.APPROVED_APPLICATION_STATUS;
    Database.update(applicationObjList[0],true);

    List<Account> accountObjList = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
    requestMap.put('filter','CURRENT CROP YEAR');
    requestMap.put('accountId',accountObjList[0].Id);
    if(objUser != null){
      System.runAs(objUser){
        Test.startTest();
        // calling the Api
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  //Test Method to cover the Prior crop year loans For ACTIVE status  ACTIVE_APPLICATION_STATUS PRIOR CROP YEAR
  @isTest
  public static void testApiForPriorCropYearActiveStatus(){
    User objUser = [SELECT Id FROM User WHERE UserName='ross.geller@yopmail.com'];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList = [SELECT Id, genesis__Status__c, Dealer_Applicant_Relationship__c FROM genesis__Applications__c WHERE Loan_Id__c = '139000' LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.ACTIVE_APPLICATION_STATUS;
    Dealer_Applicant_Relationship__c dealerApplicantRelation =  new Dealer_Applicant_Relationship__c(Id = applicationObjList[0].Dealer_Applicant_Relationship__c);
    dealerApplicantRelation.Is_Evergreen_Eligible__c = false;
    Database.update(applicationObjList[0],true);
    Database.update(dealerApplicantRelation,true);

    List<Account> accountObjList = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
    // accountObjList[0].Is_Evergreen_Allowed__c = false;
    // Database.update(accountObjList[0], true);
    requestMap.put('filter','PRIOR CROP YEAR');
    requestMap.put('accountId',accountObjList[0].Id);
    if(objUser != null){
      System.runAs(objUser){
        Test.startTest();
        // calling the Api
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  //Test Method to cover the Prior crop year loans For CLOSED status  CLOSED_APPLICATION_STATUS
  @isTest
  public static void testApiForPriorCropYearClosedStatus(){
    User objUser = [SELECT Id FROM User WHERE UserName='ross.geller@yopmail.com'];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList = [SELECT Id, genesis__Status__c FROM genesis__Applications__c WHERE Loan_Id__c = '139000' LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.CLOSED_APPLICATION_STATUS;
    Database.update(applicationObjList[0],true);

    List<Account> accountObjList = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
    requestMap.put('filter','PRIOR CROP YEAR');
    requestMap.put('accountId',accountObjList[0].Id);
    if(objUser != null){
      System.runAs(objUser){
        Test.startTest();
        // calling the Api
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  //Test Method to cover the Prior crop year loans For APPROVED status  APPROVED_APPLICATION_STATUS
  @isTest
  public static void testApiForPriorCropYearApprovedStatus(){
    User objUser = [SELECT Id FROM User WHERE UserName='ross.geller@yopmail.com'];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList = [SELECT Id, genesis__Status__c FROM genesis__Applications__c WHERE Loan_Id__c = '139000' LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.APPROVED_APPLICATION_STATUS;
    Database.update(applicationObjList[0],true);

    List<Account> accountObjList = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
    requestMap.put('filter','PRIOR CROP YEAR');
    requestMap.put('accountId',accountObjList[0].Id);
    if(objUser != null){
      System.runAs(objUser){
        Test.startTest();
        // calling the Api
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  //Test Method to cover the Past Due loans PAST DUE ACTIVE_APPLICATION_STATUS
  @isTest
  public static void testApiForFilterEqualsPASTDUE(){
    User objUser = [SELECT Id FROM User WHERE UserName='ross.geller@yopmail.com'];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList = [SELECT Id, genesis__Status__c FROM genesis__Applications__c WHERE Loan_Id__c = '139000' LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.ACTIVE_APPLICATION_STATUS;
    Database.update(applicationObjList[0],true);

    List<Account> accountObjList = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
    requestMap.put('filter','PAST DUE');
    requestMap.put('accountId',accountObjList[0].Id);
    if(objUser != null){
      System.runAs(objUser){
        Test.startTest();
        // calling the Api
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  //Test Method to fetch all the loans ALL
  @isTest
  public static void testApiForFilterEqualsALL(){
    User objUser = [SELECT Id FROM User WHERE UserName='ross.geller@yopmail.com'];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<Account> accountObjList = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
    requestMap.put('filter','ALL');
    requestMap.put('accountId',accountObjList[0].Id);
    if(objUser != null){
      System.runAs(objUser){
        Test.startTest();
        // calling the Api
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }
  //Test Method to fetch all the ACTIVE loans
  @isTest
  public static void testApiForFilterEqualsACTIVE(){
    User objUser = [SELECT Id FROM User WHERE UserName='ross.geller@yopmail.com'];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList = [SELECT Id, genesis__Status__c, Dealer_Applicant_Relationship__c FROM genesis__Applications__c WHERE Loan_Id__c = '139000' LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.ACTIVE_APPLICATION_STATUS;
    Dealer_Applicant_Relationship__c dealerApplicantRelation =  new Dealer_Applicant_Relationship__c(Id = applicationObjList[0].Dealer_Applicant_Relationship__c);
    dealerApplicantRelation.Is_Evergreen_Eligible__c = true;
    Database.update(applicationObjList[0],true);
    Database.update(dealerApplicantRelation,true);

    List<Account> accountObjList = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
    // accountObjList[0].Is_Evergreen_Allowed__c = true;
    // Database.update(accountObjList[0], true);
    requestMap.put('filter',PortalConstants.ACTIVE_APPLICATION_STATUS);
    requestMap.put('accountId',accountObjList[0].Id);
    if(objUser != null){
      System.runAs(objUser){
        Test.startTest();
        // calling the Api
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }
  //Test Method to fetch all the ACTIVE loans
  @isTest
  public static void testApiForFilterEqualsEvergreenEligible(){
    User objUser = [SELECT Id FROM User WHERE UserName='ross.geller@yopmail.com'];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList = [SELECT Id, genesis__Status__c, Dealer_Applicant_Relationship__c FROM genesis__Applications__c WHERE Loan_Id__c = '139000' LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.ACTIVE_APPLICATION_STATUS;
    applicationObjList[0].Is_Evergreen_Eligible__c = true;
    Dealer_Applicant_Relationship__c dealerApplicantRelation =  new Dealer_Applicant_Relationship__c(Id = applicationObjList[0].Dealer_Applicant_Relationship__c);
    dealerApplicantRelation.Is_Evergreen_Eligible__c = true;
    Database.update(applicationObjList[0],true);
    Database.update(dealerApplicantRelation,true);

    List<Account> accountObjList = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
    // accountObjList[0].Is_Evergreen_Allowed__c = true;
    // Database.update(accountObjList[0], true);
    requestMap.put('filter',PortalConstants.KEY_EVERGREEN_ELIGIBLE);
    requestMap.put('accountId',accountObjList[0].Id);
    if(objUser != null){
      System.runAs(objUser){
        Test.startTest();
        // calling the Api
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  //Test Method to fetch all the CLOSED loans CLOSED_APPLICATION_STATUS
  @isTest
  public static void testApiForFilterEqualsCLOSED(){
    User objUser = [SELECT Id FROM User WHERE UserName='ross.geller@yopmail.com'];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList = [SELECT Id, genesis__Status__c, Dealer_Applicant_Relationship__c FROM genesis__Applications__c WHERE Loan_Id__c = '139000' LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.CLOSED_APPLICATION_STATUS;
    Dealer_Applicant_Relationship__c dealerApplicantRelation =  new Dealer_Applicant_Relationship__c(Id = applicationObjList[0].Dealer_Applicant_Relationship__c);
    dealerApplicantRelation.Is_Evergreen_Eligible__c = false;
    Database.update(applicationObjList[0],true);
    Database.update(dealerApplicantRelation,true);

    List<Account> accountObjList = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
    // accountObjList[0].Is_Evergreen_Allowed__c = false;
    // Database.update(accountObjList[0], true);
    requestMap.put('filter',PortalConstants.CLOSED_APPLICATION_STATUS);
    requestMap.put('accountId',accountObjList[0].Id);
    if(objUser != null){
      System.runAs(objUser){
        Test.startTest();
        // calling the Api
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  // Test Method for only filter is present in map
  @isTest
  public static void testApiForFilterEqualNull(){
    User objUser = [SELECT Id FROM User WHERE UserName='ross.geller@yopmail.com'];
    Map<String,Object> requestMap = new Map<String,Object>();
    requestMap.put('filter',null);
    if(objUser != null){
      System.runAs(objUser){
        Test.startTest();
        // calling the Api
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  // Test method for only accountid is present in Map 
  @isTest
  public static void testApiForAccountIdNull(){
    User objUser = [SELECT Id FROM User WHERE UserName='ross.geller@yopmail.com'];
    Map<String,Object> requestMap = new Map<String,Object>();
    requestMap.put('accountId',null);
    if(objUser != null){
      System.runAs(objUser){
        Test.startTest();
        // calling the Api
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }
  
  // Test Method for exception
  @isTest
  public static void testApiException(){
    User objUser = [SELECT Id FROM User WHERE UserName='ross.geller@yopmail.com'];
    if(objUser != null){
      System.runAs(objUser){
        Test.startTest();
        // calling the Api
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), null);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success'); 
      }
    }
  }

  // Test Method for custom exception
  @isTest
  public static void testApiCustomException(){
    User objUser = [SELECT Id, AccountId FROM User WHERE UserName='ross.geller@yopmail.com'];
    Account objAccount = [SELECT Id, ParentId FROM Account WHERE Id = :objUser.AccountId];
    objAccount.ParentId =null;
    Database.update(objAccount,true);
    Map<String,Object> requestMap = new Map<String,Object>();

    List<Account> accountObjList = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
    requestMap.put('filter','ALL');
    requestMap.put('accountId',accountObjList[0].Id);

    if(objUser != null){
      System.runAs(objUser){
        Test.startTest();
        // calling the Api
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success'); 
      }
    }
  }
}