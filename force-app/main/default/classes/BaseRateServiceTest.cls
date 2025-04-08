/**
 * @description       : Test Class for BaseRateService
 * @author            : Sounak Ganguly
 * @group             : 
 * @last modified on  : 01-14-2025
**/
@isTest
private class BaseRateServiceTest {
    /**
    * @description : test setup
    * @author Shristy Kumari | 01-12-2025 
    **/
    @testSetup
    static void setupTestData(){
        // creating floating rate index
        clcommon__Floating_Rate_Index__c floatingRateIndex = ApplicationOriginationTestHelper.createFloatingRateIndex('CFA_Advantage_Rate',11);
        // creating inactive floating rate index
        clcommon__Floating_Rate_Index__c inactiveFloatingRateIndex = ApplicationOriginationTestHelper.createFloatingRateIndex('Inactive Rate',12);
        Database.insert(new List<clcommon__Floating_Rate_Index__c>{floatingRateIndex,inactiveFloatingRateIndex},true);
        // creating CFA partner program
        CFA_Partner_Program__c partnerProgram = ApplicationOriginationTestHelper.createPartnerProgram('Test Partner Program',floatingRateIndex);
        // creating inactive CFA partner program
        CFA_Partner_Program__c partnerProgramInactive = ApplicationOriginationTestHelper.createPartnerProgram('Test Partner Program Inactive',inactiveFloatingRateIndex);
        Database.insert(new List<CFA_Partner_Program__c>{partnerProgram,partnerProgramInactive},true);
        //creating account for testing
        Account accountWithPartnerProgram = ApplicationOriginationTestHelper.createPartnerAccount('George Clare',partnerProgram);
        Account accountWithoutProgram = new Account(
                Name = 'Robert Hooke'
            );
        Database.insert(new List<Account>{accountWithPartnerProgram,accountWithoutProgram},true);
    }
    /**
    * @description Method to fetch Account having partner program associated with it
    * @author Shristy Kumari | 01-06-2025 
    * @return User 
    **/
    private static Account getAccount(){
        List<Account> accountObjList = [SELECT Id 
                                        FROM Account 
                                        WHERE Name = 'George Clare'
                                        LIMIT 1];  
            if(accountObjList.size() == 1){
                return accountObjList[0];
            }  
        return null;
    }
    /**
    * @description : Method to test succes scenerio to fetch and cache base rate
    * @author Shristy Kumari | 01-08-2025 
    **/
    @isTest
    static void testFetchAndCacheBaseRateSuccess(){
        System.runAs(new User(Id=UserInfo.getUserId())){
            Test.startTest();
            Account accountObj = getAccount();
            BaseRateService.BaseRateInfo baseRateInfo = BaseRateService.fetchAndCacheBaseRate(accountObj.Id);
            System.assertNotEquals(null, baseRateInfo, 'Expected baseRateInfo to be not null for active custom metadata');
            System.assertEquals('CFA_Advantage_Rate', baseRateInfo.floatingRateIndex.Name, 'Expected Name to be CFA_Advantage_Rate');
            System.assertEquals(11, baseRateInfo.floatingRateIndex.Current_Floating_Rate__c, 'Expected Current Floating Rate to be 11');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test success scenerio to fetch base rate from cache
    * @author Shristy Kumari | 01-08-2025 
    **/
    @isTest
    static void testFetchFromCacheSuccess(){
        System.runAs(new User(Id=UserInfo.getUserId())){
            Test.startTest();
            Account accountObj = getAccount();
            clcommon__Floating_Rate_Index__c floatingRateIndex = new clcommon__Floating_Rate_Index__c(
                Name = 'CFA_Advantage_Rate',
                Current_Floating_Rate__c = 1.5,
                clcommon__Active__c = true
            );
            BaseRateService.BaseRateInfo baseRateInfo = new BaseRateService.BaseRateInfo(floatingRateIndex);
            Cache.Session.put(accountObj.Id, baseRateInfo);
            BaseRateService.BaseRateInfo cachedBaseRateInfo = BaseRateService.fetchAndCacheBaseRate(accountObj.Id);
            System.assertNotEquals(null, cachedBaseRateInfo, 'Expected cachedBaseRateInfo to be not null from cache');
            System.assertEquals('CFA_Advantage_Rate', cachedBaseRateInfo.floatingRateIndex.Name, 'Expected Name from cache to be CFA_Advantage_Rate');
            System.assertEquals(1.5, cachedBaseRateInfo.floatingRateIndex.Current_Floating_Rate__c, 'Expected Current Floating Rate from cache to be 1.5');
            // Assertion for modified cache value
            BaseRateService.BaseRateInfo updatedBaseRateInfo = (BaseRateService.BaseRateInfo) Cache.Session.get(accountObj.Id);
            System.assertEquals(1.5, updatedBaseRateInfo.floatingRateIndex.Current_Floating_Rate__c, 'Cache value should be updated with the correct floating rate.');
            Test.stopTest();
        }
    }
    /**
    * @description Method to test success scenerio to fetch base rate from cache when there is no CFA Partner Program
    * @author Shristy Kumari | 01-08-2025 
    **/
    @isTest
    static void testNoCfaPartnerProgram(){
        System.runAs(new User(Id=UserInfo.getUserId())){
            Test.startTest();
            Account accountObj = [SELECT Id FROM Account WHERE Name = 'Robert Hooke' LIMIT 1];
            BaseRateService.BaseRateInfo baseRateInfo = BaseRateService.fetchAndCacheBaseRate(accountObj.Id);
            System.assertEquals(null, baseRateInfo, 'Expected baseRateInfo to be null for account without CFA Partner Program');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test success scenerio to fetch base rate from cache when floating rate is null
    * @author Shristy Kumari | 01-08-2025 
    **/
    @isTest
    static void testWithNoFloatingRateSuccess(){
        System.runAs(new User(Id=UserInfo.getUserId())){
            Test.startTest();
            Account accountObj = getAccount();
            clcommon__Floating_Rate_Index__c floatingRateIndex = new clcommon__Floating_Rate_Index__c(
                Name = 'CFA_Advantage_Rate',
                Current_Floating_Rate__c = null,
                clcommon__Active__c = true
            );
            BaseRateService.BaseRateInfo baseRateInfo = new BaseRateService.BaseRateInfo(floatingRateIndex);
            Cache.Session.put(accountObj.Id, baseRateInfo);
            System.assertNotEquals(null, baseRateInfo, 'Expected baseRateInfo to be not null for active custom metadata');
            System.assertEquals('CFA_Advantage_Rate', baseRateInfo.floatingRateIndex.Name, 'Expected Name to be CFA_Advantage_Rate');
            System.assertEquals(true, baseRateInfo.floatingRateIndex.clcommon__Active__c, 'Expected Current Floating Rate status to be active');
            Test.stopTest();
        }
    }
}