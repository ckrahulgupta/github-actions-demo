/**
 * @description       : Test class for PortalUpdateLoanAmountAPI
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 08-29-2024
 * @last modified by  : Sk Minsar
**/
@isTest
public with sharing class PortalUpdateLoanAmountAPITest {

  /**
  * @description - Seeding of Test Data
  * @author Sk Minsar | 08-23-2024 
  **/
  @testSetup
  static void setup(){
   clcommon__Legal_Entity__c solePropLegalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
   clcommon__Legal_Entity__c dbaLegalEntityObj  = ApplicationOriginationTestHelper.createDBALegalEntity();
   clcommon__Legal_Entity__c corporationEntityObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
   Database.insert(new List<clcommon__Legal_Entity__c>{solePropLegalEntityObj, dbaLegalEntityObj, corporationEntityObj},true);

   clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
   Database.insert(clProductObj,true);

   clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
   Database.insert(clPurposeObj,true);

   clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
   clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
   clcommon__Party_Type__c principalPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
   clcommon__Party_Type__c dealerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('DEALER');
   clcommon__Party_Type__c saPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('SALES AGENT');
   Database.insert(new List<clcommon__Party_Type__c>{clPartyTypeObj, borrowerPartyTypeObj, principalPartyTypeObj, dealerPartyTypeObj, saPartyTypeObj},true);

   genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
   genesis__Business_Information__c businessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
   Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj, businessInfoObj},true);

   Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.id);
   dealerAccountObj.Enable_ERP_Id__c = true;
   Account accountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(businessInfoObj.id,dealerAccountObj.id);
   Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
   Database.insert(new List<Account>{dealerAccountObj, accountObj, clAccountObj},true);

   Contact contactObj = ApplicationOriginationTestHelper.createSalesAgentContact(accountObj.id);
   Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
   Database.insert(new List<Contact>{contactObj, clContactObj},true);

   User userObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.id);
   User saUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(contactObj.id);
   Database.insert(new List<User>{userObj, saUserObj},true);

   clcommon__Reciprocal_Role__c clRole = ApplicationOriginationTestHelper.createCertifiedLenderRole();
   clcommon__Reciprocal_Role__c saRole = ApplicationOriginationTestHelper.createSalesAgentRole();
   Database.insert(new List<clcommon__Reciprocal_Role__c>{clRole, saRole},true);

   clcommon__Relationship__c clRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(clRole,dealerAccountObj.id,clAccountObj.id);
   clcommon__Relationship__c saRelationship = ApplicationOriginationTestHelper.createSalesAgentDealerRelationship(saRole,dealerAccountObj.id,accountObj.id);
   Database.insert(new List<clcommon__Relationship__c>{clRelationship, saRelationship},true);

   genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
   Database.insert(borrowerBusinessInfoObj,true);

   Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(solePropLegalEntityObj,borrowerBusinessInfoObj.id);
   borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
   borrowerAccountObj.CIF_Number__c = '123456';
   borrowerAccountObj.Coop_Type__c = 'CFA';
   Database.insert(borrowerAccountObj,true);

   Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
   borrowerContactObj.genesis__SSN__c = '324242424';
   borrowerContactObj.Confirm_SSN__c = '324242424';
   Database.insert(borrowerContactObj,true);

   genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
   Database.insert(coBorrowerBusinessInfoObj,true);

   Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(solePropLegalEntityObj,coBorrowerBusinessInfoObj.id);
   coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
   coBorrowerAccountObj.FICO_Recorded_On__c = Date.today().addDays(-1);
   coBorrowerAccountObj.Score_1__c = '580';
   coBorrowerAccountObj.SBSS70_Score__c = '140';
   Database.insert(coBorrowerAccountObj,true);

   Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
   Database.insert(coBorrowerContactObj,true);

   genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(new Map<String, Id>{
       'dealerAccountObjId' => dealerAccountObj.id,
       'clProductObjId' => clProductObj.id,
       'clPurposeObjId' => clPurposeObj.id,
       'borrowerAccountObjId' => borrowerAccountObj.id,
       'borrowerContactObjId' => borrowerContactObj.id,
       'saAccountObjId' => accountObj.id
   });
   applicationObj.genesis__Product_Type__c ='Package';
   applicationObj.genesis__Status__c = PortalConstants.NEW_SCORECARD_APPLICATION_STATUS;
   Database.insert(applicationObj,true); 

   clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
       'accountId' => borrowerAccountObj.id,
       'contactId' => borrowerContactObj.id,
       'partyTypeId' => borrowerPartyTypeObj.id,
       'applicationId' => applicationObj.id
   });
   partyObj.clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;

   clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
       'accountId' => clAccountObj.id,
       'contactId' => clContactObj.id,
       'partyTypeId' => clPartyTypeObj.id,
       'applicationId' => applicationObj.id
   });

   clcommon__Party__c coPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
       'accountId' => coBorrowerAccountObj.id,
       'contactId' => coBorrowerContactObj.id,
       'partyTypeId' => principalPartyTypeObj.id,
       'applicationId' => applicationObj.id
   });
   coPartyObj.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;
   Database.insert(new List<clcommon__Party__c>{partyObj, clPartyObj, coPartyObj},true);

   CFA_Configuration__c cifObj = ApplicationOriginationTestHelper.createCIFNumber();
   Database.insert(cifObj,true);

   List<genesis__Credit_Rating_Matrix__c> creditMatrixList = FICOCalloutTestHelper.createAllCreditRatingMatrix();
   Database.insert(creditMatrixList, true);
}

/**
* @description - This method is used to get the credit rating
* @author Sk Minsar | 08-28-2024 
* @param ratingName 
* @return genesis__Credit_Rating__c 
**/
public static Id getCreditRating(String ratingName){
   List<genesis__Credit_Rating_Matrix__c> objCreditRatingTiersLists = [SELECT Id, 
                                                                              Name 
                                                                        FROM genesis__Credit_Rating_Matrix__c 
                                                                        WHERE Name =: ratingName];

   return objCreditRatingTiersLists[0].id;
}

    /**
    * @description - This method is used to get the Legal Entity Id
    * @author Sk Minsar | 08-27-2024 
    * @param type 
    * @return Id 
    **/
    public static Id getLegalEntityId(String type){
      List<clcommon__Legal_Entity__c> legalEntity = [SELECT Id
                                                           FROM clcommon__Legal_Entity__c 
                                                           WHERE clcommon__Legal_Entity_Type__c =: type LIMIT 1];
      return legalEntity[0].Id;
  }

   /**
   * @description - Exception Scenario: Tier one application
   * @author Sk Minsar | 08-23-2024 
   **/
   @isTest
   static void testForTierOne(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 1');
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
       borrowerAccount.Score_1__c = '750';
       borrowerAccount.SBSS70_Score__c = '210';
       Database.update(borrowerAccount,true);

       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
       }
   }
   /**
   * @description - Exception Scenario: Tier two application
   * @author Sk Minsar | 08-23-2024 
   **/
   @isTest
   static void testForTierTwo(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 2');
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
       borrowerAccount.Score_1__c = '680';
       borrowerAccount.SBSS70_Score__c = '170';
       Database.update(borrowerAccount,true);

       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000.50};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
       }
   }
   /**
   * @description - Exception Scenario: Tier three application
   * @author Sk Minsar | 08-23-2024 
   **/
   @isTest
   static void testForTierThree(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 3');
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
       borrowerAccount.Score_1__c = '620';
       borrowerAccount.SBSS70_Score__c = '155';
       Database.update(borrowerAccount,true);

       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
       }
   }
   /**
   * @description - Exception Scenario: Tier Four application
   * @author Sk Minsar | 08-23-2024 
   **/
   @isTest
   static void testForTierFour(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 4');
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
       borrowerAccount.Score_1__c = '580';
       borrowerAccount.SBSS70_Score__c = '140';
       Database.update(borrowerAccount,true);

       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
       }
   }

   /**
   * @description - Success Scenario: Tier one Evergreen application
   * @author Sk Minsar | 08-23-2024 
   **/
   @isTest
   static void testForEvergreenTierOne(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 1');
       applicationObj.Is_Evergreen__c = true;
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c, clcommon__Legal_Entity_Type__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
       borrowerAccount.Score_1__c = '750';
       borrowerAccount.SBSS70_Score__c = '210';
       borrowerAccount.Is_Evergreen_Allowed__c = true;
       Database.update(borrowerAccount,true);

       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
       }
   }

   /**
   * @description - Exception Scenario: Tier one Evergreen application for Sales Agent
   * @author Sk Minsar | 08-23-2024 
   **/
  @isTest
  static void testForEvergreenTierOneWithSA(){
      User userObj = [SELECT Id,Account.ParentId FROM User WHERE Email='cfanewus5er@yopmail.com' LIMIT 1];
      genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
      applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 2');
      applicationObj.Is_Evergreen__c = true;
      Database.update(applicationObj, true);

      Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c, clcommon__Legal_Entity_Type__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
      borrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
      borrowerAccount.Score_1__c = '750';
      borrowerAccount.SBSS70_Score__c = '210';
      borrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(borrowerAccount,true);

      Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
      System.runAs(userObj) {
          Test.startTest();
          PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
          clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
          Test.stopTest();
          System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
      }
  }

   /**
   * @description - Success Scenario: Tier one Evergreen application for corporation
   * @author Sk Minsar | 08-27-2024 
   **/
   @isTest
   static void testForCorporationEvergreenTierOne(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 1');
       applicationObj.Is_Evergreen__c = true;
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, clcommon__Legal_Entity_Type__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.clcommon__Legal_Entity_Type__c = getLegalEntityId(PortalConstants.CORPORATION);
       borrowerAccount.Is_Evergreen_Allowed__c = true;
       Database.update(borrowerAccount,true);

       Account coBorrowerAccount = [SELECT id, name, Phone, Is_Evergreen_Allowed__c, clcommon__Legal_Entity_Type__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where clcommon__Email__c = 'mike.johnson@yopmail.com' LIMIT 1];
       coBorrowerAccount.Coop_Type__c = 'CFA';
       coBorrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
       coBorrowerAccount.Score_1__c = '750';
       coBorrowerAccount.SBSS70_Score__c = '210';
       coBorrowerAccount.Is_Evergreen_Allowed__c = true;
       Database.update(coBorrowerAccount,true);

       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
       }
   }

   @isTest
   static void testForDBAEvergreenTierOne(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 1');
       applicationObj.Is_Evergreen__c = true;
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, clcommon__Legal_Entity_Type__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.clcommon__Legal_Entity_Type__c = getLegalEntityId(PortalConstants.INDIVIDUAL_ENTITY);
       borrowerAccount.Is_Evergreen_Allowed__c = true;
       Database.update(borrowerAccount,true);
       
       Account coBorrowerAccount = [SELECT id, name, Phone, Is_Evergreen_Allowed__c, clcommon__Legal_Entity_Type__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where clcommon__Email__c = 'mike.johnson@yopmail.com' LIMIT 1];
       coBorrowerAccount.Coop_Type__c = 'CFA';
       coBorrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
       coBorrowerAccount.Score_1__c = '750';
       coBorrowerAccount.SBSS70_Score__c = '210';
       coBorrowerAccount.Is_Evergreen_Allowed__c = true;
       Database.update(coBorrowerAccount,true);

       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
       }
   }
   /**
   * @description - Exception Scenario: Tier two and tier 2 business info status Pending Evergreen application
   * @author Sk Minsar | 08-23-2024 
   **/
   @isTest
   static void testForEvergreenTierTwoPending(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, Evergreen_Tier_Two_Business_Info_Status__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.Evergreen_Tier_Two_Business_Info_Status__c = 'Pending';
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 2');
       applicationObj.Is_Evergreen__c = true;
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name, Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
       borrowerAccount.Score_1__c = '680';
       borrowerAccount.SBSS70_Score__c = '170';
       borrowerAccount.Is_Evergreen_Allowed__c = true;
       Database.update(borrowerAccount,true);

       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
       }
   }
   /**
   * @description - Exception Scenario: Tier two and tier 2 business info InProgress Ineligible Evergreen application
   * @author Sk Minsar | 08-23-2024 
   **/
   @isTest
   static void testForEvergreenTierTwoInprogress(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, Evergreen_Tier_Two_Business_Info_Status__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.Evergreen_Tier_Two_Business_Info_Status__c = 'In Progress';
       applicationObj.Is_Evergreen__c = true;
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 2');
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
       borrowerAccount.Score_1__c = '680';
       borrowerAccount.SBSS70_Score__c = '170';
       borrowerAccount.Is_Evergreen_Allowed__c = true;
       Database.update(borrowerAccount,true);

       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
       }
   }
   /**
   * @description - Sucess Scenario: Tier two and tier 2 business info status Provided Evergreen application
   * @author Sk Minsar | 08-23-2024 
   **/
   @isTest
   static void testForEvergreenTierTwoProvided(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, Evergreen_Tier_Two_Business_Info_Status__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.Is_Evergreen__c = true;
       applicationObj.Evergreen_Tier_Two_Business_Info_Status__c = 'Provided';
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 2');
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
       borrowerAccount.Score_1__c = '680';
       borrowerAccount.SBSS70_Score__c = '170';
       borrowerAccount.Is_Evergreen_Allowed__c = true;
       Database.update(borrowerAccount,true);
       
       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
       }
   }
   /**
   * @description - Exception Scenario: Tier two and tier 2 business info status Provided Evergreen application For Sales Agent
   * @author Sk Minsar | 08-23-2024 
   **/
  @isTest
  static void testForEvergreenTierTwoProvidedWithSA(){
   User userObj = [SELECT Id,Account.ParentId FROM User WHERE Email='cfanewus5er@yopmail.com' LIMIT 1];
      genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, Evergreen_Tier_Two_Business_Info_Status__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
      applicationObj.Is_Evergreen__c = true;
      applicationObj.Evergreen_Tier_Two_Business_Info_Status__c = 'Provided';
      applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 2');
      Database.update(applicationObj, true);

      Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
      borrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
      borrowerAccount.Score_1__c = '680';
      borrowerAccount.SBSS70_Score__c = '170';
      borrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(borrowerAccount,true);

      Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
      System.runAs(userObj) {
          Test.startTest();
          PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
          clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
          Test.stopTest();
          System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
      }
  }
   /**
   * @description - Sucess Scenario: Tier two and tier 2 business info status Provided Evergreen application for corporation
   * @author Sk Minsar | 08-23-2024 
   **/
  @isTest
  static void testForCorporationEvergreenTierTwoProvided(){
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, Evergreen_Tier_Two_Business_Info_Status__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
      applicationObj.Is_Evergreen__c = true;
      applicationObj.Evergreen_Tier_Two_Business_Info_Status__c = 'Provided';
      applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 2');
      Database.update(applicationObj, true);

      Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
      borrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.Is_Evergreen_Allowed__c = true;
      borrowerAccount.clcommon__Legal_Entity_Type__c = getLegalEntityId(PortalConstants.CORPORATION);
      Database.update(borrowerAccount,true);

      Account coBorrowerAccount = [SELECT id, name, Phone, Is_Evergreen_Allowed__c, clcommon__Legal_Entity_Type__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where clcommon__Email__c = 'mike.johnson@yopmail.com' LIMIT 1];
      coBorrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
      borrowerAccount.Score_1__c = '680';
      borrowerAccount.SBSS70_Score__c = '170';
      coBorrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(coBorrowerAccount,true);

      Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
      System.runAs(userObj) {
          Test.startTest();
          PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
          clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
          Test.stopTest();
          System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
      }
  }

  /**
   * @description - Sucess Scenario: Tier two and tier 2 business info status Provided Evergreen application for DBA
   * @author Sk Minsar | 08-23-2024 
   **/
  @isTest
  static void testForDBAEvergreenTierTwoProvided(){
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, Evergreen_Tier_Two_Business_Info_Status__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
      applicationObj.Is_Evergreen__c = true;
      applicationObj.Evergreen_Tier_Two_Business_Info_Status__c = 'Provided';
      applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 2');
      Database.update(applicationObj, true);

      Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
      borrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.Is_Evergreen_Allowed__c = true;
      borrowerAccount.clcommon__Legal_Entity_Type__c = getLegalEntityId(PortalConstants.INDIVIDUAL_ENTITY);
      Database.update(borrowerAccount,true);

      Account coBorrowerAccount = [SELECT id, name, Phone, Is_Evergreen_Allowed__c, clcommon__Legal_Entity_Type__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where clcommon__Email__c = 'mike.johnson@yopmail.com' LIMIT 1];
      coBorrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
      borrowerAccount.Score_1__c = '680';
      borrowerAccount.SBSS70_Score__c = '170';
      coBorrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(coBorrowerAccount,true);

      Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
      System.runAs(userObj) {
          Test.startTest();
          PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
          clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
          Test.stopTest();
          System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
      }
  }
   /**
   * @description - Success Scenario: Tier three Evergreen application
   * @author Sk Minsar | 08-23-2024 
   **/
  @isTest
  static void testForEvergreenTierThree(){
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
      applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 3');
      applicationObj.Is_Evergreen__c = true;
      Database.update(applicationObj, true);

      Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
      borrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(borrowerAccount,true);

      Account coBorrowerAccount = [SELECT id, name, Phone, Is_Evergreen_Allowed__c, clcommon__Legal_Entity_Type__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where clcommon__Email__c = 'mike.johnson@yopmail.com' LIMIT 1];
      coBorrowerAccount.Coop_Type__c = 'CFA';
      coBorrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
      coBorrowerAccount.Score_1__c = '680';
      coBorrowerAccount.SBSS70_Score__c = '170';
      coBorrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(coBorrowerAccount,true);
      Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
      System.runAs(userObj) {
          Test.startTest();
          PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
          clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
          Test.stopTest();
          System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
      }
  }
   /**
   * @description - Success Scenario: Tier three Evergreen application with Sales Agent
   * @author Sk Minsar | 08-23-2024 
   **/
  @isTest
  static void testForEvergreenTierThreeWitSA(){
      User userObj = [SELECT Id,Account.ParentId FROM User WHERE Email='cfanewus5er@yopmail.com' LIMIT 1];
      genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
      applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 3');
      applicationObj.Is_Evergreen__c = true;
      Database.update(applicationObj, true);

      Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
      borrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(borrowerAccount,true);

      Account coBorrowerAccount = [SELECT id, name, Phone, Is_Evergreen_Allowed__c, clcommon__Legal_Entity_Type__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where clcommon__Email__c = 'mike.johnson@yopmail.com' LIMIT 1];
      coBorrowerAccount.Coop_Type__c = 'CFA';
      coBorrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
      coBorrowerAccount.Score_1__c = '680';
      coBorrowerAccount.SBSS70_Score__c = '170';
      coBorrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(coBorrowerAccount,true);

      Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
      System.runAs(userObj) {
          Test.startTest();
          PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
          clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
          Test.stopTest();
          System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
      }
  }
   /**
   * @description - Success Scenario: Tier three Evergreen application for corporation
   * @author Sk Minsar | 08-23-2024 
   **/
   @isTest
   static void testForCorporationEvergreenTierThree(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 3');
       applicationObj.Is_Evergreen__c = true;
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.clcommon__Legal_Entity_Type__c = getLegalEntityId(PortalConstants.CORPORATION);
       borrowerAccount.Is_Evergreen_Allowed__c = true;
       Database.update(borrowerAccount,true);

       Account coBorrowerAccount = [SELECT id, name, Phone, Is_Evergreen_Allowed__c, clcommon__Legal_Entity_Type__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where clcommon__Email__c = 'mike.johnson@yopmail.com' LIMIT 1];
       coBorrowerAccount.Coop_Type__c = 'CFA';
       coBorrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
       coBorrowerAccount.Score_1__c = '680';
       coBorrowerAccount.SBSS70_Score__c = '170';
       coBorrowerAccount.Is_Evergreen_Allowed__c = true;
       Database.update(coBorrowerAccount,true);

       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
       }
   }
   /**
   * @description - Success Scenario: Tier three Evergreen application for DBA
   * @author Sk Minsar | 08-23-2024 
   **/
  @isTest
  static void testForDBAEvergreenTierThree(){
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
      applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 3');
      applicationObj.Is_Evergreen__c = true;
      Database.update(applicationObj, true);

      Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
      borrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.clcommon__Legal_Entity_Type__c = getLegalEntityId(PortalConstants.INDIVIDUAL_ENTITY);
      borrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(borrowerAccount,true);

      Account coBorrowerAccount = [SELECT id, name, Phone, Is_Evergreen_Allowed__c, clcommon__Legal_Entity_Type__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where clcommon__Email__c = 'mike.johnson@yopmail.com' LIMIT 1];
      coBorrowerAccount.Coop_Type__c = 'CFA';
      coBorrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
      coBorrowerAccount.Score_1__c = '680';
      coBorrowerAccount.SBSS70_Score__c = '170';
      coBorrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(coBorrowerAccount,true);

      Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
      System.runAs(userObj) {
          Test.startTest();
          PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
          clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
          Test.stopTest();
          System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
      }
  }
   /**
   * @description - Exception Scenario: Tier Four Evergreen application
   * @author Sk Minsar | 08-23-2024 
   **/
   @isTest
   static void testForEvergreenTierFour(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 4');
       applicationObj.Is_Evergreen__c = true;
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
       borrowerAccount.Score_1__c = '580';
       borrowerAccount.SBSS70_Score__c = '140';
       borrowerAccount.Is_Evergreen_Allowed__c = true;
       Database.update(borrowerAccount,true);

       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
       }
   }
   /**
   * @description - Exception Scenario: For empty loan amount
   * @author Sk Minsar | 08-27-2024 
   **/
   @isTest
   static void testEmptyLoanAmount(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 1');
       applicationObj.Is_Evergreen__c = true;
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
       borrowerAccount.Score_1__c = '750';
       borrowerAccount.SBSS70_Score__c = '210';
       borrowerAccount.Is_Evergreen_Allowed__c = true;
       Database.update(borrowerAccount,true);

       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => null};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
       }
   }  
   
   /**
   * @description - Exception Scenario: For negative loan amount
   * @author Sk Minsar | 08-27-2024 
   **/
   @isTest
   static void testNegetiveLoanAmount(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 1');
       applicationObj.Is_Evergreen__c = true;
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
       borrowerAccount.Score_1__c = '750';
       borrowerAccount.SBSS70_Score__c = '210';
       borrowerAccount.Is_Evergreen_Allowed__c = true;
       Database.update(borrowerAccount,true);
       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => -5000};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
       }
   }

   /**
   * @description - Exception Scenario: For invalid application 
   * @author Sk Minsar | 08-27-2024 
   **/
   @isTest
   static void testInvalidApplicationId(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 1');
       applicationObj.Is_Evergreen__c = true;
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
       borrowerAccount.Score_1__c = '750';
       borrowerAccount.SBSS70_Score__c = '210';
       borrowerAccount.Is_Evergreen_Allowed__c = true;
       Database.update(borrowerAccount,true);

       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => null, 'loanAmount' => 5000};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
       }
   }

   /**
   * @description - Exception Scenario: For Active application 
   * @author Sk Minsar | 08-27-2024 
   **/
  @isTest
  static void testActiveEvergreenApp(){
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
      applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 1');
      applicationObj.Is_Evergreen__c = true;
      applicationObj.genesis__Status__c = PortalConstants.ACTIVE_APPLICATION_STATUS;
      Database.update(applicationObj, true);

      Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
      borrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
      borrowerAccount.Score_1__c = '750';
      borrowerAccount.SBSS70_Score__c = '210';
      borrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(borrowerAccount,true);

      Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => null, 'loanAmount' => 5000};
      System.runAs(userObj) {
          Test.startTest();
          PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
          clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
          Test.stopTest();
          System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
      }
  }
   /**
   * @description - Exception Scenario: For Signature pending application status
   * @author Sk Minsar | 08-27-2024 
   **/
  @isTest
  static void testSignPendingApp(){
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
      applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 1');
      applicationObj.Is_Evergreen__c = true;
      applicationObj.genesis__Status__c = PortalConstants.E_SIGN_PENDING_APPLICATION_STATUS;
      Database.update(applicationObj, true);

      Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
      borrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
      borrowerAccount.Score_1__c = '750';
      borrowerAccount.SBSS70_Score__c = '210';
      borrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(borrowerAccount,true);

      Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => null, 'loanAmount' => 5000};
      System.runAs(userObj) {
          Test.startTest();
          PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
          clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
          Test.stopTest();
          System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
      }
  }
  /**
   * @description - Exception Scenario: For New Entered application status
   * @author Sk Minsar | 08-27-2024 
   **/
  @isTest
  static void testNewEnteredApp(){
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
      applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 1');
      applicationObj.Is_Evergreen__c = true;
      applicationObj.genesis__Status__c = PortalConstants.NEW_ENTERED_APPLICATION_STATUS;
      Database.update(applicationObj, true);

      Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
      borrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
      borrowerAccount.Score_1__c = '750';
      borrowerAccount.SBSS70_Score__c = '210';
      borrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(borrowerAccount,true);

      Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => null, 'loanAmount' => 5000};
      System.runAs(userObj) {
          Test.startTest();
          PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
          clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
          Test.stopTest();
          System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
      }
  }

   /**
   * @description - Exception Scenario: For invalid user 
   * @author Sk Minsar | 08-27-2024 
   **/
   @isTest
   static void testInvalidUser(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, Dealer_Name__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.Is_Evergreen__c = true;
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 1');
       applicationObj.Dealer_Name__c = null;
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
       borrowerAccount.Score_1__c = '750';
       borrowerAccount.SBSS70_Score__c = '210';
       borrowerAccount.Is_Evergreen_Allowed__c = true;
       Database.update(borrowerAccount,true);

       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
       }
   }
   /**
   * @description - Exception Scenario: For invalid fico score 
   * @author Sk Minsar | 08-27-2024 
   **/
   @isTest
   static void testWithInvalidFicoScoreApp(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 1');
       applicationObj.Is_Evergreen__c = true;
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
       borrowerAccount.Score_1__c = null;
       borrowerAccount.SBSS70_Score__c = '210';
       borrowerAccount.Is_Evergreen_Allowed__c = true;
       Database.update(borrowerAccount,true);

       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
       }
   }
   /**
   * @description - Exception Scenario: For invalid sbss score 
   * @author Sk Minsar | 08-27-2024 
   **/
   @isTest
   static void testWithInvalidSBSSScoreApp(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 1');
       applicationObj.Is_Evergreen__c = true;
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
       borrowerAccount.Score_1__c = '750';
       borrowerAccount.SBSS70_Score__c = null;
       borrowerAccount.Is_Evergreen_Allowed__c = true;
       Database.update(borrowerAccount,true);

       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
       }
   }
   /**
   * @description - Exception Scenario: For old fico score
   * @author Sk Minsar | 08-27-2024 
   **/
   @isTest
   static void testWithOlderFicoScoreOfSixMonthsApp(){
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
       applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 1');
       applicationObj.Is_Evergreen__c = true;
       Database.update(applicationObj, true);

       Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
       borrowerAccount.Coop_Type__c = 'CFA';
       borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-200);
       borrowerAccount.Score_1__c = '750';
       borrowerAccount.SBSS70_Score__c = '210';
       borrowerAccount.Is_Evergreen_Allowed__c = true;
       Database.update(borrowerAccount,true);

       Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
       System.runAs(userObj) {
           Test.startTest();
           PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
           clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
           Test.stopTest();
           System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
       }
   }

   /**
   * @description - Exception Scenario: For old fico score
   * @author Sk Minsar | 08-27-2024 
   **/
  @isTest
  static void testInvalidCreditRatingApp(){
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
      applicationObj.genesis__Credit_Rating__c = null;
      applicationObj.Is_Evergreen__c = true;
      Database.update(applicationObj, true);

      Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
      borrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-200);
      borrowerAccount.Score_1__c = '750';
      borrowerAccount.SBSS70_Score__c = '210';
      borrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(borrowerAccount,true);
      
      Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 5000};
      System.runAs(userObj) {
          Test.startTest();
          PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
          clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
          Test.stopTest();
          System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
      }
  }

  /**
   * @description - Success Scenario: Tier one Evergreen application to Tier two
   * @author Sk Minsar | 08-23-2024 
   **/
  @isTest
  static void testForEvergreenTierOneToTierTwo(){
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
      applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 1');
      applicationObj.Is_Evergreen__c = true;
      applicationobj.Net_Worth__c = '150000';
      Database.update(applicationObj, true);

      Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c, clcommon__Legal_Entity_Type__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
      borrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
      borrowerAccount.Score_1__c = '750';
      borrowerAccount.SBSS70_Score__c = '210';
      borrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(borrowerAccount,true);

      Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 50000};
      System.runAs(userObj) {
          Test.startTest();
          PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
          testApi.invokeAction('', new List<String>(), requestMap);
          genesis__Applications__c responseApplicationObj = [SELECT Id, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 50000 LIMIT 1];
          Test.stopTest();
          System.assertEquals('Tier 2', responseApplicationObj.genesis__Credit_Rating__r.name,'Assertion Failed');
          
      }
  }

  /**
   * @description - Success Scenario: Tier one Evergreen application to Tier three
   * @author Sk Minsar | 08-23-2024 
   **/
  @isTest
  static void testForEvergreenTierOneToTierThree(){
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
      applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 1');
      applicationObj.Is_Evergreen__c = true;
      applicationobj.Net_Worth__c = '150000';
      Database.update(applicationObj, true);

      Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c, clcommon__Legal_Entity_Type__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
      borrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
      borrowerAccount.Score_1__c = '750';
      borrowerAccount.SBSS70_Score__c = '210';
      borrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(borrowerAccount,true);

      Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 500000};
      System.runAs(userObj) {
          Test.startTest();
          PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
          testApi.invokeAction('', new List<String>(), requestMap);
          genesis__Applications__c responseApplicationObj = [SELECT Id, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 50000 LIMIT 1];
          Test.stopTest();
          System.assertEquals('Tier 3', responseApplicationObj.genesis__Credit_Rating__r.name,'Assertion Failed');
          
      }
  }
   /**
   * @description - Success Scenario: Tier Two Evergreen application to Tier One
   * @author Sk Minsar | 08-23-2024 
   **/
  @isTest
  static void testForEvergreenTierTwoToTierOne(){
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
      applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 2');
      applicationObj.Is_Evergreen__c = true;
      applicationobj.Net_Worth__c = '100000';
      Database.update(applicationObj, true);

      Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c, clcommon__Legal_Entity_Type__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
      borrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
      borrowerAccount.Score_1__c = '750';
      borrowerAccount.SBSS70_Score__c = '210';
      borrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(borrowerAccount,true);

      Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 20000};
      System.runAs(userObj) {
          Test.startTest();
          PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
          testApi.invokeAction('', new List<String>(), requestMap);
          genesis__Applications__c responseApplicationObj = [SELECT Id, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 50000 LIMIT 1];
          Test.stopTest();
          System.assertEquals('Tier 1', responseApplicationObj.genesis__Credit_Rating__r.name,'Assertion Failed');
          
      }
  }
  
  /**
   * @description - Success Scenario: Tier Two Evergreen application to Tier Three
   * @author Sk Minsar | 08-23-2024 
   **/
  @isTest
  static void testForEvergreenTierTwoToTierThree(){
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
      applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 2');
      applicationObj.Is_Evergreen__c = true;
      applicationobj.Net_Worth__c = '100000';
      Database.update(applicationObj, true);

      Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c, clcommon__Legal_Entity_Type__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
      borrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
      borrowerAccount.Score_1__c = '680';
      borrowerAccount.SBSS70_Score__c = '170';
      borrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(borrowerAccount,true);

      Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 20000};
      System.runAs(userObj) {
          Test.startTest();
          PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
          testApi.invokeAction('', new List<String>(), requestMap);
          genesis__Applications__c responseApplicationObj = [SELECT Id, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 50000 LIMIT 1];
          Test.stopTest();
          System.assertEquals('Tier 3', responseApplicationObj.genesis__Credit_Rating__r.name,'Assertion Failed');
          
      }
  }
  /**
   * @description - Success Scenario: Tier Three Evergreen application to Tier One
   * @author Sk Minsar | 08-23-2024 
   **/
  @isTest
  static void testForEvergreenTierThreeToTierOne(){
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
      applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 3');
      applicationObj.Is_Evergreen__c = true;
      applicationobj.Net_Worth__c = '20000';
      Database.update(applicationObj, true);

      Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c, clcommon__Legal_Entity_Type__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
      borrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
      borrowerAccount.Score_1__c = '750';
      borrowerAccount.SBSS70_Score__c = '210';
      borrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(borrowerAccount,true);

      Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 3000};
      System.runAs(userObj) {
          Test.startTest();
          PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
          testApi.invokeAction('', new List<String>(), requestMap);
          genesis__Applications__c responseApplicationObj = [SELECT Id, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 50000 LIMIT 1];
          Test.stopTest();
          System.assertEquals('Tier 1', responseApplicationObj.genesis__Credit_Rating__r.name,'Assertion Failed');
          
      }
  }
  /**
   * @description - Success Scenario: Tier Three Evergreen application to Tier Two
   * @author Sk Minsar | 08-23-2024 
   **/
  @isTest
  static void testForEvergreenTierThreeToTierTwo(){
      User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
      genesis__Applications__c applicationObj = [SELECT Id,genesis__Account__c, Is_Evergreen__c, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 35000 LIMIT 1];
      applicationObj.genesis__Credit_Rating__c = getCreditRating('Tier 3');
      applicationObj.Is_Evergreen__c = true;
      applicationobj.Net_Worth__c = '20000';
      Database.update(applicationObj, true);

      Account borrowerAccount = [SELECT id, name,Phone, Is_Evergreen_Allowed__c, Coop_Type__c, Score_1__c, SBSS70_Score__c, FICO_Recorded_On__c, clcommon__Legal_Entity_Type__c  from account where id =:applicationObj.genesis__Account__c LIMIT 1];
      borrowerAccount.Coop_Type__c = 'CFA';
      borrowerAccount.FICO_Recorded_On__c = Date.today().addDays(-1);
      borrowerAccount.Score_1__c = '680';
      borrowerAccount.SBSS70_Score__c = '170';
      borrowerAccount.Is_Evergreen_Allowed__c = true;
      Database.update(borrowerAccount,true);

      Map<String,Object> requestMap = new Map<String,Object>{'applicationId' => applicationObj.Id, 'loanAmount' => 19000};
      System.runAs(userObj) {
          Test.startTest();
          PortalUpdateLoanAmountAPI testApi = new PortalUpdateLoanAmountAPI();
          testApi.invokeAction('', new List<String>(), requestMap);
          genesis__Applications__c responseApplicationObj = [SELECT Id, genesis__Credit_Rating__c FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 50000 LIMIT 1];
          Test.stopTest();
          System.assertEquals('Tier 2', responseApplicationObj.genesis__Credit_Rating__r.name,'Assertion Failed');
          
      }
  }
}