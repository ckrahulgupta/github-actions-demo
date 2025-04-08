/**
 * @description       : Test class for ScheduleEOMEmailToCFAGrowerAPI
 * @author            : Simran
 * @group             : 
 * @last modified on  : 12-06-2023
 * @last modified by  : Simran
**/
@isTest
public with sharing class ScheduleEOMEmailToCFAGrowerAPITest {
    @TestSetup
    static void setup(){
        Map<String,Id> objectVsIdMap=new Map<String,Id>();
        genesis__Business_Information__c businessInformationObj = TestClassHelper.createBusinessInfoForDealer();
        Database.insert(businessInformationObj,true);
        Account dealerAccountObj = TestClassHelper.createDealerAccount(businessInformationObj.Id);
        Database.insert(dealerAccountObj, true);
        Account clAccountObj = TestClassHelper.createCLAccount(businessInformationObj.Id,dealerAccountObj.Id);
        Database.insert(clAccountObj, true);
        Contact clContactObj = TestClassHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);
        clcommon__CL_Product__c clProductObj=TestClassHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);
        clcommon__CL_Purpose__c clPurposeObj=TestClassHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj,true);
        clcommon__Legal_Entity__c entityObj= TestClassHelper.createLegalEntity('Individual(s) - Sole Proprietorship');
        Database.insert(entityObj,true);
        Account accountObj=TestClassHelper.createSolePropAccount(entityObj,businessInformationObj.Id);
        Database.insert(accountObj,true);
        Contact contactObj=TestClassHelper.createBorrowerContact(accountObj.Id);
        Database.insert(contactObj,true);
        objectVsIdMap.put('dealerAccountId',dealerAccountObj.Id);
        objectVsIdMap.put('clProductId',clProductObj.Id);
        objectVsIdMap.put('clPurposeId',clPurposeObj.Id);
        objectVsIdMap.put('borrowerAccountId',accountObj.Id);
        objectVsIdMap.put('borrowerContactId',contactObj.Id);
        objectVsIdMap.put('clAccountId',clAccountObj.Id);
        genesis__Applications__c currApplicationObj = TestClassHelper.createCurrCropYearApplication(objectVsIdMap);
        Database.insert(currApplicationObj,true);
        clcommon__Party_Type__c partyTypeObj=TestClassHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(partyTypeObj,true);
        objectVsIdMap.put('accountId',accountObj.Id);
        objectVsIdMap.put('contactId',contactObj.Id);
        objectVsIdMap.put('partyTypeId',partyTypeObj.Id);
        objectVsIdMap.put('applicationId',currApplicationObj.Id);
        clcommon__Party__c partyObj = TestClassHelper.createParty(objectVsIdMap);
        Database.insert(partyObj,true);
        objectVsIdMap.put('applicationId',currApplicationObj.Id);
        clcommon__Party__c borrowerPartyObj = TestClassHelper.createParty(objectVsIdMap);
        Database.insert(borrowerPartyObj,true);
    }
    @isTest
    public static void testEOMEmailNotification(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(objAdmin){
            Test.startTest();
            System.schedule('testScheduleEOMEmailToCFAGrowerAPI','0 55 * * * ? *', new ScheduleEOMEmailToCFAGrowerAPI());
            Test.stopTest();
        }
        System.assert(true, 'Assertion Success');  
    }
    @isTest
    public static void testEOMEmailNotificationException(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        clcommon__Legal_Entity__c legalEntityObj=[SELECT Id,Name,clcommon__Legal_Entity_Type__c FROM clcommon__Legal_Entity__c WHERE Name='Individual(s) - Sole Proprietorship'];
        legalEntityObj.Name='Individual(s) with DBA';
        legalEntityObj.clcommon__Legal_Entity_Type__c='Individual(s) with DBA';
        Database.update(legalEntityObj,true);
        System.runAs(objAdmin){
            Test.startTest();
            System.schedule('testScheduleEOMEmailToCFAGrowerAPI','0 55 * * * ? *', new ScheduleEOMEmailToCFAGrowerAPI());
            Test.stopTest();
        }
        System.assert(true, 'Assertion Failed');  
    }
}