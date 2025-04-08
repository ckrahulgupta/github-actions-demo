/**********************************************************************************************
 * @className         : TestExternalAPIApplication
 * @description       : Test Class for ExternalAPIApplication and ExternalAPIApplicationCIF
 * @author            : Simran
 * @created Date      : 03-01-2022
 * @last modified on  : 16-09-2024
 * @last modified by  : Soumik Pattanayak
 **********************************************************************************************/

 @IsTest
 public class ExternalAPIApplicationTest {
	 @TestSetup
	 static void setup() {
		 Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Certified Lender' LIMIT 1];
 
		 clcommon__Legal_Entity__c objAccountEntity = TestClassHelper.createLegalEntity('Individual(s) - Sole Proprietorship');
		 Database.insert(objAccountEntity,true);
 
		 genesis__Business_Information__c businessInfo = TestClassHelper.createBusinessInfoForBorrower();
		 Database.insert(businessInfo,true);
 
		 Account accountObj = TestClassHelper.createSolePropAccount(objAccountEntity,businessInfo.id);
		 accountObj.Name = 'TestAccount';
		 accountObj.CIF_Number__c = '113255';
		 Database.insert(accountObj,true);
 
		 Contact contactObj = TestClassHelper.createBorrowerContact(accountObj.id);
		 Database.insert(contactObj,true);
 
		 insertUserFuture(objProfile.Id, contactObj.Id,'cfanewuser@yopmail.com');
		 
		 List<String> externalUserProfile = System.Label.AgVend_External_User_Profile_Label.split(',');
		 Profile agvendProfile = [SELECT Id, Name FROM Profile WHERE Name = :externalUserProfile[0] LIMIT 1];
 
		 Account advendAccountObj = TestClassHelper.createSolePropAccount(objAccountEntity,businessInfo.id);
		 advendAccountObj.Name = 'Test Contact1';
		 Database.insert(advendAccountObj,true);
 
		 Contact advendContactObj = TestClassHelper.createBorrowerContactV2(advendAccountObj.id);
		 Database.insert(advendContactObj,true);
		 insertUserFuture(agvendProfile.Id, advendContactObj.Id,'cfanewuser@yopmail.com.agvend');
		 
		 Map<String, Id> paramMap = new Map<String,Id>{
			 'dealerAccountId' => accountObj.Id,
			 'clProductId' => null,
			 'clPurposeId' => null,
			 'borrowerAccountId' => accountObj.Id,
			 'borrowerContactId' => advendContactObj.Id,
			 'clAccountId' => null
		 };
 
		 genesis__Applications__c objApplication = TestClassHelper.createNewlyCreatedApplication(paramMap);
		 objApplication.genesis__Loan_Amount__c = 35000.00;
		 objApplication.Crop_Year__c = '2008';
		 objApplication.genesis__Status__c='ACTIVE';
		 objApplication.Loan_Id__c='123123';
		 Database.insert(objApplication,true);
 
		 clcommon__Party_Type__c clPartyType = TestClassHelper.createPartyType('CERTIFIED LENDER');
		 Database.insert(clPartyType,true);
 
		 Map<String, Id> paramPartyMap = new Map<String,Id>{
			 'accountId' => accountObj.id,
			 'contactId' => contactObj.id,
			 'partyTypeId' => clPartyType.id,
			 'applicationId' => objApplication.id
		 };
		 clcommon__Party__c clParty = TestClassHelper.createParty(paramPartyMap);
		 Database.insert(clParty,true);

		genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = ApplicationOriginationTestHelper.createRateCardSetupHeader(accountObj);
        Database.insert(rateCardHeaderObj,true);
		genesis__Rate_Card_Setup_Detail__c arateCardSetupDetails =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        arateCardSetupDetails.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_A;
        Database.insert(arateCardSetupDetails,true);
   
        genesis__Application_Pricing_Detail__c pricingDetail = ApplicationOriginationTestHelper.createEnabledPricingDetail(objApplication,arateCardSetupDetails.Id);
        Database.insert(pricingDetail,true);

		genesis__Rate_Card_Setup_Detail__c brateCardSetupDetails =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        brateCardSetupDetails.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_B;
        Database.insert(brateCardSetupDetails,true);
   
        genesis__Application_Pricing_Detail__c bPricingDetail = ApplicationOriginationTestHelper.createEnabledPricingDetail(objApplication,brateCardSetupDetails.Id);
        Database.insert(bPricingDetail,true);
 
	 }
	 
	 @IsTest
	 public static void testExternalAPIApplication() {
		RestResponse response = new RestResponse();
		RestContext.response = response;
		 Account acc = [SELECT Id, Name, CIF_Number__c, BillingCity, BillingState FROM Account WHERE Name = 'TestAccount' LIMIT 1];
		 User objUserId = [SELECT Id, Alias, Email, LastName, Profile.Name, ProfileId, ContactId, UserName FROM User WHERE Username = 'cfanewuser@yopmail.com' LIMIT 1];
		 genesis__Applications__c objApp = [SELECT Id, genesis__Loan_Number__c,genesis__Loan_Amount__c, Crop_Year__c, genesis__Account__c, Dealer_Name__c FROM genesis__Applications__c WHERE genesis__Account__c = :acc.Id LIMIT 1];
		 List<String> loanNumberList = new List<String>();
		 loanNumberList.add(objApp.genesis__Loan_Number__c);
		 System.runAs(objUserId) {
			 ExternalAPIApplication.applicationRecord(loanNumberList);
			 System.assertEquals(200,RestContext.response.statusCode, 'Assertion Failed');
		 }
 
	 }
 
	 @IsTest
	 public static void testExternalAPIApplicationCIF() {
		RestResponse response = new RestResponse();
		RestContext.response = response;
		 Account acc = [SELECT Id, Name, CIF_Number__c, BillingCity, BillingState FROM Account WHERE Name = 'TestAccount' LIMIT 1];
		 User objUserId = [SELECT Id, Alias, Email, LastName, Profile.Name, ProfileId, ContactId, UserName FROM User WHERE Username = 'cfanewuser@yopmail.com' LIMIT 1];
		 genesis__Applications__c objApp = [SELECT Id, genesis__Loan_Number__c,genesis__Loan_Amount__c, Crop_Year__c, genesis__Account__c, Dealer_Name__c FROM genesis__Applications__c WHERE genesis__Account__c = :acc.Id LIMIT 1];
		 List<String> loanNumberList = new List<String>();
		 loanNumberList.add(objApp.genesis__Loan_Number__c);
		 String cif = acc.CIF_Number__c;
		 System.runAs(objUserId) {
			ExternalAPIApplicationCIF.applicationRecordCIF(cif);
			System.assertEquals(200,RestContext.response.statusCode, 'Assertion Failed');
		 }
 
	 }
 
	 @IsTest
	 public static void testExternalAPIApplicationForAgvendSuccess() {
		RestResponse response = new RestResponse();
		RestContext.response = response;
		 List<String> externalUserProfile = System.Label.AgVend_External_User_Profile_Label.split(',');
		 Profile agvendProfile = [SELECT Id, Name FROM Profile WHERE Name = :externalUserProfile[0] LIMIT 1];
		 User userObj;
		 genesis__Applications__c applicationObj;
		 List<String> externalUserDealerCIF = System.Label.External_Dealer_CIF_Number.split(',');
		 List<String> loanNumberList = new List<String>();
		 List<genesis__Applications__c> applicationList = [SELECT Id,
															 genesis__Loan_Number__c,
															 Dealer_Name__r.CIF_Number__c
															 FROM genesis__Applications__c LIMIT 1];
		 for(genesis__Applications__c appObj : applicationList){
			 applicationObj = appObj;
			 loanNumberList.add(appObj.genesis__Loan_Number__c);
		 }
		 Account dealerAccount = [Select Id From Account Where CIF_Number__c =: applicationObj.Dealer_Name__r.CIF_Number__c Limit 1];
		 dealerAccount.CIF_Number__c = externalUserDealerCIF[0];
		 Database.update(dealerAccount,true);
		 List<User> userList = [SELECT Id,ProfileId FROM User WHERE ProfileId =: agvendProfile.id AND Username = 'cfanewuser@yopmail.com.agvend' LIMIT 1];
		 
		 for(User newUser : userList){
			 userObj = newUser;
		 }
		 
		 System.runAs(userObj) {
			 ExternalAPIApplication.applicationRecord(loanNumberList);
			 System.assertEquals(200,RestContext.response.statusCode, 'Assertion Failed');
		 }
 
	 }
 
	 @IsTest
	 public static void testExternalAPIApplicationCIFForAgvendSuccess() {
		RestResponse response = new RestResponse();
		RestContext.response = response;
		 List<String> externalUserProfile = System.Label.AgVend_External_User_Profile_Label.split(',');
		 Profile agvendProfile = [SELECT Id, Name FROM Profile WHERE Name = :externalUserProfile[0] LIMIT 1];
		 User userObj;
		 genesis__Applications__c applicationObj;
		 List<String> externalUserDealerCIF = System.Label.External_Dealer_CIF_Number.split(',');
		 List<String> loanNumberList = new List<String>();
		 List<genesis__Applications__c> applicationList = [SELECT Id,
															 genesis__Loan_Number__c,
															 Dealer_Name__r.CIF_Number__c
															 FROM genesis__Applications__c LIMIT 1];
		 for(genesis__Applications__c appObj : applicationList){
			 applicationObj = appObj;
			 loanNumberList.add(appObj.genesis__Loan_Number__c);
		 }
		 Account dealerAccount = [Select Id From Account Where CIF_Number__c =: applicationObj.Dealer_Name__r.CIF_Number__c Limit 1];
		 dealerAccount.CIF_Number__c = externalUserDealerCIF[0];
		 Database.update(dealerAccount,true);
		 List<User> userList = [SELECT Id,ProfileId FROM User WHERE ProfileId =: agvendProfile.id AND Username = 'cfanewuser@yopmail.com.agvend' LIMIT 1];
		 
		 for(User newUser : userList){
			 userObj = newUser;
		 }
		 
		 System.runAs(userObj) {
			 ExternalAPIApplicationCIF.applicationRecordCIF(externalUserDealerCIF[0]);
			 System.assertEquals(200,RestContext.response.statusCode, 'Assertion Failed');
		 }
 
	 }
	 @IsTest
	 public static void testExternalAPIApplicationForAgvendException() {
		RestResponse response = new RestResponse();
		RestContext.response = response;
		 List<String> externalUserProfile = System.Label.AgVend_External_User_Profile_Label.split(',');
 
		 Profile agvendProfile = [SELECT Id, Name FROM Profile WHERE Name = :externalUserProfile[0] LIMIT 1];
		 User userObj;
		 genesis__Applications__c applicationObj;
		 List<String> externalUserDealerCIF = System.Label.External_Dealer_CIF_Number.split(',');
		 List<String> loanNumberList = new List<String>();
		 List<genesis__Applications__c> applicationList = [SELECT Id,
															 genesis__Loan_Number__c,
															 Dealer_Name__r.CIF_Number__c
															 FROM genesis__Applications__c LIMIT 1];
		 for(genesis__Applications__c appObj : applicationList){
			 applicationObj = appObj;
 
		 }
		 Account dealerAccount = [Select Id From Account Where CIF_Number__c =: applicationObj.Dealer_Name__r.CIF_Number__c Limit 1];
		 dealerAccount.CIF_Number__c = externalUserDealerCIF[0];
		 Database.update(dealerAccount,true);
		 List<User> userList = [SELECT Id,ProfileId FROM User WHERE ProfileId =: agvendProfile.id AND  Username = 'cfanewuser@yopmail.com.agvend' LIMIT 1];
		 for(User newUser : userList){
			 userObj = newUser;
		 }
		 
		 System.runAs(userObj) {
			 ExternalAPIApplication.applicationRecord(loanNumberList);
			 System.assertEquals(null,RestContext.response.statusCode, 'Assertion Failed');
		 }
 
	 }
 
	 @IsTest
	 public static void testExternalAPIApplicationCIFForAgvend() {
		RestResponse response = new RestResponse();
		RestContext.response = response;
		 List<String> externalUserProfile = System.Label.AgVend_External_User_Profile_Label.split(',');
 
		 Profile agvendProfile = [SELECT Id, Name FROM Profile WHERE Name = :externalUserProfile[0] LIMIT 1];
		 User userObj;
		 List<String> externalUserDealerCIF = System.Label.External_Dealer_CIF_Number.split(',');
		 List<User> userList = [SELECT Id,ProfileId FROM User WHERE ProfileId =: agvendProfile.id AND  Username = 'cfanewuser@yopmail.com.agvend' LIMIT 1];
		 for(User newUser : userList){
			 userObj = newUser;
		 }
		 
		 System.runAs(userObj) {
			 ExternalAPIApplicationCIF.applicationRecordCIF(externalUserDealerCIF[0]);
			 System.assertEquals(200,RestContext.response.statusCode, 'Assertion Failed');
		 }
 
	 }
	 @IsTest
	 public static void testExternalAPIApplicationException() {
		RestResponse response = new RestResponse();
		RestContext.response = response;
		 Account acc = [SELECT Id, Name, CIF_Number__c, BillingCity, BillingState FROM Account WHERE Name = 'TestAccount' LIMIT 1];
		 acc.CIF_Number__c = '123456';
		 Database.update(acc, true);
		 User objUserId = [SELECT Id, Alias, Email, LastName, Profile.Name, ProfileId, ContactId, UserName FROM User WHERE Username = 'cfanewuser@yopmail.com' LIMIT 1];
		 genesis__Applications__c objApp = [SELECT Id,genesis__Loan_Number__c, genesis__Loan_Amount__c, Crop_Year__c, genesis__Account__c, Dealer_Name__c FROM genesis__Applications__c WHERE genesis__Account__c = :acc.Id LIMIT 1];
		 
		 List<String> ids = new List<String>();
		 ids.add(objApp.genesis__Loan_Number__c);
		 System.runAs(objUserId) {
			  ExternalAPIApplication.applicationRecord(ids);
			  System.assertEquals(null,RestContext.response.statusCode, 'Assertion Failed');
		 }
	 }
	 @IsTest
	 public static void testExternalAPIApplicationCIFException() {
		RestResponse response = new RestResponse();
		RestContext.response = response;
		 Account acc = [SELECT Id, Name, CIF_Number__c, BillingCity, BillingState FROM Account WHERE Name = 'TestAccount' LIMIT 1];
		 acc.CIF_Number__c = '123456';
		 Database.update(acc, true);
	 
		 User objUserId = [SELECT Id, Alias, Email, LastName, Profile.Name, ProfileId, ContactId, UserName FROM User WHERE Username = 'cfanewuser@yopmail.com' LIMIT 1];
		 genesis__Applications__c objApp = [SELECT Id,genesis__Loan_Number__c, genesis__Loan_Amount__c, Crop_Year__c, genesis__Account__c, Dealer_Name__c FROM genesis__Applications__c WHERE genesis__Account__c = :acc.Id LIMIT 1];
		 
		 List<String> ids = new List<String>();
		 ids.add(objApp.genesis__Loan_Number__c);
		 String cif = acc.CIF_Number__c;
		 System.runAs(objUserId) {
			  ExternalAPIApplicationCIF.applicationRecordCIF(cif);
			  System.assertEquals(null,RestContext.response.statusCode, 'Assertion Failed');
		 }
	 }
 
	 /**
	  * @description This method use to create user
	  * @param objProfileId 
	  * @param objContactId 
	  * @param userName 
	  */
	 @Future
	 public static void insertUserFuture(String objProfileId, String objContactId,String userName) {
		 User objUser = new User(
			   Alias = 'newUser',
			   Email = 'cfanewuser@yopmail.com',
			   EmailEncodingKey = 'UTF-8',
			   LastName = 'Testing',
			   LanguageLocaleKey = 'en_US',
			   LocaleSidKey = 'en_US',
			   ProfileId = objProfileId,
			   ContactId = objContactId,
			   TimeZoneSidKey = 'America/Los_Angeles',
			   UserName = userName,
			   PortalRole = 'Manager');
		 Database.insert(objUser, true);
	 
	 }
 }