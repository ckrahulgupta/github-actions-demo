/**
 * @description       : Test class for PortalFetchLoanAPI
 * @author            : E. Shalini
 * @group             : 
 * @last modified on  : 03-11-2025
 * @last modified by  : Rahul Gorai
**/
@isTest
public class TestPortalFetchLoansAPI {

  @TestSetup
    static void setup(){

        // Creating Business information
        genesis__Business_Information__c dealerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj,true);
        // Creating dealer account
        Account dealerAccountObj = LoanServicingTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);

        // creating certified lender account
        Account clAccountObj = LoanServicingTestHelper.createCLAccount(dealerBusinessInfoObj.Id,dealerAccountObj.Id);
        Database.insert(clAccountObj, true);
        // creating certified lender contact
        Contact clContactObj = LoanServicingTestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);
        // creating cl user
        User clUserObj = LoanServicingTestHelper.createCLUser(clContactObj.Id);
        Database.insert(clUserObj, true);

        // creating Reciprocal role
        clcommon__Reciprocal_Role__c roleObj = LoanServicingTestHelper.createReciprocalRole('Certified Lender');
        Database.insert(roleObj,true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = LoanServicingTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        // creating cl product
        clcommon__CL_Product__c clProductObj=LoanServicingTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);
        // creating cl purpose
        clcommon__CL_Purpose__c clPurposeObj=LoanServicingTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj,true);
        // creating legal entity 
        clcommon__Legal_Entity__c entityObj= LoanServicingTestHelper.createLegalEntity('Individual(s) - Sole Proprietorship');
        Database.insert(entityObj,true);

        //creating borrower account
        Account borrowerAccountObj=LoanServicingTestHelper.createSolePropAccount(entityObj,LoanServicingTestHelper.createBusinessInfoForBorrower().Id);
        Database.insert(borrowerAccountObj,true);
        //creating borrower contact
        Contact borrowerContactObj=LoanServicingTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(borrowerContactObj,true);
        // Creating borrower user
        User borrowerUserObj = LoanServicingTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(borrowerUserObj,true);

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

  
  /**
  * @description  Current crop year loans for ACTIVE status
  * @author Rahul Gorai | 03-10-2025 
  **/
  @isTest
  public static void testApiForCurrentCropYearActiveStatus(){
    List<User> userList =  [SELECT Id 
                            FROM User 
                            WHERE UserName='ross.geller@yopmail.com'
                            LIMIT 1];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList =  [SELECT Id, 
                                                                genesis__Status__c, 
                                                                Dealer_Applicant_Relationship__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Loan_Id__c = '139000' 
                                                          LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.ACTIVE_APPLICATION_STATUS;
    Dealer_Applicant_Relationship__c dealerApplicantRelation =  new Dealer_Applicant_Relationship__c(Id = applicationObjList[0].Dealer_Applicant_Relationship__c);
    dealerApplicantRelation.Is_Evergreen_Eligible__c = true;
    Database.update(applicationObjList[0],true);
    Database.update(dealerApplicantRelation,true);

    List<Account> accountObjList = [SELECT Id 
                                    FROM Account 
                                    WHERE Name = 'Jasmine Albin' 
                                    LIMIT 1];
    requestMap.put('filter','CURRENT CROP YEAR');
    requestMap.put('accountId',accountObjList[0].Id);
    if(userList[0] != null){
      System.runAs(userList[0]){
        Test.startTest();
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  
  /**
  * @description  Current crop year loans for CLOSED status 
  * @author Rahul Gorai | 03-10-2025 
  **/
  @isTest
  public static void testApiForCurrentCropYearClosedStatus(){
    List<User> userList =  [SELECT Id 
                            FROM User 
                            WHERE UserName='ross.geller@yopmail.com'
                            LIMIT 1];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList =  [SELECT Id, 
                                                                genesis__Status__c, 
                                                                Dealer_Applicant_Relationship__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Loan_Id__c = '139000' 
                                                          LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.CLOSED_APPLICATION_STATUS;
    Database.update(applicationObjList[0],true);

    List<Account> accountObjList = [SELECT Id 
                                    FROM Account 
                                    WHERE Name = 'Jasmine Albin' 
                                    LIMIT 1];

    requestMap.put('filter','CURRENT CROP YEAR');
    requestMap.put('accountId',accountObjList[0].Id);
    if(userList[0] != null){
      System.runAs(userList[0]){
        Test.startTest();
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  
  /**
  * @description  Current crop year loans for APPROVED status 
  * @author Rahul Gorai | 03-10-2025 
  **/
  @isTest
  public static void testApiForCurrentCropYearApprovedStatus(){
    List<User> userList =  [SELECT Id 
                            FROM User 
                            WHERE UserName='ross.geller@yopmail.com'
                            LIMIT 1];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList =  [SELECT Id, 
                                                                genesis__Status__c, 
                                                                Dealer_Applicant_Relationship__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Loan_Id__c = '139000' 
                                                          LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.APPROVED_APPLICATION_STATUS;
    Database.update(applicationObjList[0],true);

    List<Account> accountObjList = [SELECT Id 
                                    FROM Account 
                                    WHERE Name = 'Jasmine Albin' 
                                    LIMIT 1];
    requestMap.put('filter','CURRENT CROP YEAR');
    requestMap.put('accountId',accountObjList[0].Id);
    if(userList[0] != null){
      System.runAs(userList[0]){
        Test.startTest();
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  
  /**
  * @description  Prior crop year loans For ACTIVE status  
  * @author Rahul Gorai | 03-10-2025 
  **/
  @isTest
  public static void testApiForPriorCropYearActiveStatus(){
    List<User> userList =  [SELECT Id 
                            FROM User 
                            WHERE UserName='ross.geller@yopmail.com'
                            LIMIT 1];
    Map<String,Object> requestMap = new Map<String,Object>();
    List<genesis__Applications__c> applicationObjList =  [SELECT Id, 
                                                                genesis__Status__c, 
                                                                Dealer_Applicant_Relationship__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Loan_Id__c = '139000' 
                                                          LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.ACTIVE_APPLICATION_STATUS;
    Dealer_Applicant_Relationship__c dealerApplicantRelation =  new Dealer_Applicant_Relationship__c(Id = applicationObjList[0].Dealer_Applicant_Relationship__c);
    dealerApplicantRelation.Is_Evergreen_Eligible__c = false;
    Database.update(applicationObjList[0],true);
    Database.update(dealerApplicantRelation,true);

    List<Account> accountObjList = [SELECT Id   
                                    FROM Account
                                    WHERE Name = 'Jasmine Albin' 
                                    LIMIT 1];
    requestMap.put('filter','PRIOR CROP YEAR');
    requestMap.put('accountId',accountObjList[0].Id);
    if(userList[0] != null){
      System.runAs(userList[0]){
        Test.startTest();
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  
  /**
  * @description  Prior crop year loans For CLOSED status  
  * @author Rahul Gorai | 03-10-2025 
  **/
  @isTest
  public static void testApiForPriorCropYearClosedStatus(){
    List<User> userList =  [SELECT Id 
                            FROM User 
                            WHERE UserName='ross.geller@yopmail.com'
                            LIMIT 1];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList =  [SELECT Id, 
                                                                genesis__Status__c, 
                                                                Dealer_Applicant_Relationship__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Loan_Id__c = '139000' 
                                                          LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.CLOSED_APPLICATION_STATUS;
    Database.update(applicationObjList[0],true);

    List<Account> accountObjList = [SELECT Id 
                                    FROM Account 
                                    WHERE Name = 'Jasmine Albin' 
                                    LIMIT 1];
    requestMap.put('filter','PRIOR CROP YEAR');
    requestMap.put('accountId',accountObjList[0].Id);
    if(userList[0] != null){
      System.runAs(userList[0]){
        Test.startTest();
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  
  /**
  * @description Prior crop year loans For APPROVED status  
  * @author Rahul Gorai | 03-10-2025 
  **/
  @isTest
  public static void testApiForPriorCropYearApprovedStatus(){
    List<User> userList =  [SELECT Id 
                            FROM User 
                            WHERE UserName='ross.geller@yopmail.com'
                            LIMIT 1];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList =  [SELECT Id, 
                                                                genesis__Status__c, 
                                                                Dealer_Applicant_Relationship__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Loan_Id__c = '139000' 
                                                          LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.APPROVED_APPLICATION_STATUS;
    Database.update(applicationObjList[0],true);

    List<Account> accountObjList = [SELECT Id 
                                    FROM Account 
                                    WHERE Name = 'Jasmine Albin' 
                                    LIMIT 1];
    requestMap.put('filter','PRIOR CROP YEAR');
    requestMap.put('accountId',accountObjList[0].Id);
    if(userList[0] != null){
      System.runAs(userList[0]){
        Test.startTest();
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  
  /**
  * @description  Past Due loans of active application
  * @author Rahul Gorai | 03-10-2025 
  **/
  @isTest
  public static void testApiForFilterEqualsPASTDUE(){
    List<User> userList =  [SELECT Id 
                            FROM User 
                            WHERE UserName='ross.geller@yopmail.com'
                            LIMIT 1];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList =  [SELECT Id, 
                                                                genesis__Status__c, 
                                                                Dealer_Applicant_Relationship__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Loan_Id__c = '139000' 
                                                          LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.ACTIVE_APPLICATION_STATUS;
    Database.update(applicationObjList[0],true);

    List<Account> accountObjList = [SELECT Id 
                                    FROM Account 
                                    WHERE Name = 'Jasmine Albin' 
                                    LIMIT 1];
    requestMap.put('filter','PAST DUE');
    requestMap.put('accountId',accountObjList[0].Id);
    if(userList[0] != null){
      System.runAs(userList[0]){
        Test.startTest();
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  
  /**
  * @description Fetch all the loans 
  * @author Rahul Gorai | 03-10-2025 
  **/
  @isTest
  public static void testApiForFilterEqualsALL(){
    List<User> userList =  [SELECT Id 
                            FROM User 
                            WHERE UserName='ross.geller@yopmail.com'
                            LIMIT 1];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<Account> accountObjList = [SELECT Id 
                                    FROM Account 
                                    WHERE Name = 'Jasmine Albin' 
                                    LIMIT 1];
    requestMap.put('filter','ALL');
    requestMap.put('accountId',accountObjList[0].Id);
    if(userList[0] != null){
      System.runAs(userList[0]){
        Test.startTest();
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }
  
  /**
  * @description Fetch all the active loans
  * @author Rahul Gorai | 03-10-2025 
  **/
  @isTest
  public static void testApiForFilterEqualsACTIVE(){
    List<User> userList =  [SELECT Id 
                            FROM User 
                            WHERE UserName='ross.geller@yopmail.com'
                            LIMIT 1];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList =  [SELECT Id, 
                                                                genesis__Status__c, 
                                                                Dealer_Applicant_Relationship__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Loan_Id__c = '139000' 
                                                          LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.ACTIVE_APPLICATION_STATUS;
    Dealer_Applicant_Relationship__c dealerApplicantRelation =  new Dealer_Applicant_Relationship__c(Id = applicationObjList[0].Dealer_Applicant_Relationship__c);
    dealerApplicantRelation.Is_Evergreen_Eligible__c = true;
    Database.update(applicationObjList[0],true);
    Database.update(dealerApplicantRelation,true);

    List<Account> accountObjList = [SELECT Id 
                                    FROM Account 
                                    WHERE Name = 'Jasmine Albin' 
                                    LIMIT 1];
    requestMap.put('filter',PortalConstants.ACTIVE_APPLICATION_STATUS);
    requestMap.put('accountId',accountObjList[0].Id);
    if(userList[0] != null){
      System.runAs(userList[0]){
        Test.startTest();
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }
  
  /**
  * @description Fetch all evergreen active loans
  * @author Rahul Gorai | 03-10-2025 
  **/
  @isTest
  public static void testApiForFilterEqualsEvergreenEligible(){
    List<User> userList =  [SELECT Id 
                            FROM User 
                            WHERE UserName='ross.geller@yopmail.com'
                            LIMIT 1];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList =  [SELECT Id, 
                                                                genesis__Status__c, 
                                                                Dealer_Applicant_Relationship__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Loan_Id__c = '139000' 
                                                          LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.ACTIVE_APPLICATION_STATUS;
    applicationObjList[0].Is_Evergreen_Eligible__c = true;
    Dealer_Applicant_Relationship__c dealerApplicantRelation =  new Dealer_Applicant_Relationship__c(Id = applicationObjList[0].Dealer_Applicant_Relationship__c);
    dealerApplicantRelation.Is_Evergreen_Eligible__c = true;
    Database.update(applicationObjList[0],true);
    Database.update(dealerApplicantRelation,true);

    List<Account> accountObjList = [SELECT Id 
                                    FROM Account 
                                    WHERE Name = 'Jasmine Albin' 
                                    LIMIT 1];
    requestMap.put('filter',PortalConstants.KEY_EVERGREEN_ELIGIBLE);
    requestMap.put('accountId',accountObjList[0].Id);
    if(userList[0] != null){
      System.runAs(userList[0]){
        Test.startTest();
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  
  /**
  * @description Fetch all the closed loans 
  * @author Rahul Gorai | 03-10-2025 
  **/
  @isTest
  public static void testApiForFilterEqualsCLOSED(){
    List<User> userList =  [SELECT Id 
                            FROM User 
                            WHERE UserName='ross.geller@yopmail.com'
                            LIMIT 1];
    Map<String,Object> requestMap = new Map<String,Object>();

    List<genesis__Applications__c> applicationObjList =  [SELECT Id, 
                                                                genesis__Status__c, 
                                                                Dealer_Applicant_Relationship__c 
                                                          FROM genesis__Applications__c 
                                                          WHERE Loan_Id__c = '139000' 
                                                          LIMIT 1];
    applicationObjList[0].genesis__Status__c = PortalConstants.CLOSED_APPLICATION_STATUS;
    Dealer_Applicant_Relationship__c dealerApplicantRelation =  new Dealer_Applicant_Relationship__c(Id = applicationObjList[0].Dealer_Applicant_Relationship__c);
    dealerApplicantRelation.Is_Evergreen_Eligible__c = false;
    Database.update(applicationObjList[0],true);
    Database.update(dealerApplicantRelation,true);

    List<Account> accountObjList = [SELECT Id 
                                    FROM Account 
                                    WHERE Name = 'Jasmine Albin' 
                                    LIMIT 1];
    requestMap.put('filter',PortalConstants.CLOSED_APPLICATION_STATUS);
    requestMap.put('accountId',accountObjList[0].Id);
    if(userList[0] != null){
      System.runAs(userList[0]){
        Test.startTest();
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  
  /**
  * @description Filter condition is null
  * @author Rahul Gorai | 03-10-2025 
  **/
  @isTest
  public static void testApiForFilterEqualNull(){
    List<User> userList =  [SELECT Id 
                            FROM User 
                            WHERE UserName='ross.geller@yopmail.com'
                            LIMIT 1];
    Map<String,Object> requestMap = new Map<String,Object>();
    requestMap.put('filter',null);
    if(userList[0] != null){
      System.runAs(userList[0]){
        Test.startTest();
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }

  /**
  * @description Account Id is null
  * @author Rahul Gorai | 03-10-2025 
  **/
  @isTest
  public static void testApiForAccountIdNull(){
    List<User> userList =  [SELECT Id 
                            FROM User 
                            WHERE UserName='ross.geller@yopmail.com'
                            LIMIT 1];
    Map<String,Object> requestMap = new Map<String,Object>();
    requestMap.put('accountId',null);
    if(userList[0] != null){
      System.runAs(userList[0]){
        Test.startTest();
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success'); 
      }
    }
  }
  
  /**
  * @description requestMap is null 
  * @author Rahul Gorai | 03-10-2025 
  **/
  @isTest
  public static void testApiException(){
    List<User> userList =  [SELECT Id 
                            FROM User 
                            WHERE UserName='ross.geller@yopmail.com'
                            LIMIT 1];
    if(userList[0] != null){
      System.runAs(userList[0]){
        Test.startTest();
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), null);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success'); 
      }
    }
  }

  
  /**
  * @description CustomException-User not authorised 
  * @author Rahul Gorai | 03-10-2025 
  **/
  @isTest
  public static void testApiCustomException(){
    List<User> userList =  [SELECT Id, 
                                  AccountId
                            FROM User 
                            WHERE UserName='ross.geller@yopmail.com'
                            LIMIT 1];
    Account objAccount = [SELECT Id, 
                                  ParentId 
                          FROM Account 
                          WHERE Id = :userList[0].AccountId
                          LIMIT 1];
    objAccount.ParentId =null;
    Database.update(objAccount,true);
    Map<String,Object> requestMap = new Map<String,Object>();

    List<Account> accountObjList = [SELECT Id 
                                    FROM Account 
                                    WHERE Name = 'Jasmine Albin' 
                                    LIMIT 1];
    requestMap.put('filter','ALL');
    requestMap.put('accountId',accountObjList[0].Id);

    if(userList[0] != null){
      System.runAs(userList[0]){
        Test.startTest();
        PortalFetchLoansAPI saveApi = new PortalFetchLoansAPI();
        clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
        Test.stopTest();
        System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success'); 
      }
    }
  }
  

}