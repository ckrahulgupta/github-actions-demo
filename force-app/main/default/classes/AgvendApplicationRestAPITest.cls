/**********************************************************************************************
 * @className         : TestExternalAPIApplication
 * @description       : Test Class for ExternalAPIApplication and ExternalAPIApplicationCIF
 * @author            : Ayush Kumar Singh
 * @created Date      : 12-06-2023
 * @last modified on  : 07-12-2023
 * @last modified by  : Subham Nandi
 **********************************************************************************************/
@IsTest
public with sharing class AgvendApplicationRestAPITest {
	@TestSetup
	static void setup() {
        List<String> externalUserProfile = System.Label.AgVend_External_User_Profile_Label.split(',');
		Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name =: externalUserProfile[0] LIMIT 1];
        
        Account userAccountObj = ApplicationOriginationTestHelper.createAccount();
        Database.insert(userAccountObj,true);
        Contact userContactObj = ApplicationOriginationTestHelper.createContact();
        userContactObj.AccountId = userAccountObj.id;
        Database.insert(userContactObj,true);
        User userObj = ApplicationOriginationTestHelper.createCLUser(userContactObj.id);
        userObj.ProfileId = objProfile.id;
        Database.insert(userObj,true);

        genesis__Business_Information__c businessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoObj,true);
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoObj.id);
        Database.insert(dealerAccountObj,true);
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProduct();
        Database.insert(clProductObj,true);
        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(legalEntityObj,true);
        clcommon__Legal_Entity__c corpLegalEntityObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(corpLegalEntityObj,true);
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.insert(borrowerAccountObj,true);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        Database.insert(borrowerContactObj,true);
       
        Map<String,Object> applicationDataMap = new Map<String,Object>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'saAccountObjId' => null
        };
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(applicationDataMap);
        Database.insert(applicationObj,true); 

	}
	@IsTest
	public static void testAgvendApplicationRestAPISuccess() {
        List<String> externalUserProfile = System.Label.AgVend_External_User_Profile_Label.split(',');
        Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = :externalUserProfile[0] LIMIT 1];
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
        Account dealerAccount = [Select Id From Account Where CIF_Number__c =: applicationObj.Dealer_Name__r.CIF_Number__c];
        dealerAccount.CIF_Number__c = externalUserDealerCIF[0];
        Database.update(dealerAccount,true);
        List<User> userList = [SELECT Id,IsActive FROM User WHERE ProfileId =: objProfile.id AND Username = 'ross.geller@yopmail.com' LIMIT 1];
        for(User newUser : userList){
            userObj = newUser;
        }
        
		System.runAs(userObj) {
            AgvendApplicationRestAPI.CustomResponseWrapper response = new AgvendApplicationRestAPI.CustomResponseWrapper();
			response = AgvendApplicationRestAPI.applicationRecord(loanNumberList);
            List<Map<String,String>> responseList = response.data;
			System.assertEquals(externalUserDealerCIF[0],responseList[0].get('Dealer_CIF'), 'Assertion Failed');
		}

	}
	@IsTest
	public static void testAgvendApplicationRestAPIException() {
        List<String> externalUserProfile = System.Label.AgVend_External_User_Profile_Label.split(',');

        Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = :externalUserProfile[0] LIMIT 1];
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
        Account dealerAccount = [Select Id From Account Where CIF_Number__c =: applicationObj.Dealer_Name__r.CIF_Number__c];
        dealerAccount.CIF_Number__c = externalUserDealerCIF[0];
        Database.update(dealerAccount,true);
        List<User> userList = [SELECT Id,IsActive FROM User WHERE ProfileId =: objProfile.id AND Username = 'ross.geller@yopmail.com' LIMIT 1];
        for(User newUser : userList){
            userObj = newUser;
        }
        
		System.runAs(userObj) {
            AgvendApplicationRestAPI.CustomResponseWrapper response = new AgvendApplicationRestAPI.CustomResponseWrapper();
			response = AgvendApplicationRestAPI.applicationRecord(loanNumberList);
			System.assertEquals(response.data, null, 'Assertion Failed');
		}

	}
}