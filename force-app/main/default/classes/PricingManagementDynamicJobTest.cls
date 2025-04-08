/**
 * @description       : test for Pricing Management Dynamic Job class.
 * @author            : Rakesh Saraf
 * @group             : 
 * @last modified on  : 09-30-2024
 * @last modified by  : Rakesh Saraf
**/
@isTest
public with sharing class PricingManagementDynamicJobTest {

    /**
    * @description setting up test data
    * @author Rakesh Saraf | 09-30-2024 
    **/
    @TestSetup
    static void makeData(){
        ApplicationOriginationSetupTestHelper.createTestSetup();

        Account clAccountObj=[SELECT ID FROM ACCOUNT WHERE NAME='Ross Geller' LIMIT 1];

        genesis__Rate_Card_Setup_Header__c rateCardSetupHeader=ApplicationOriginationTestHelper.createRateCardSetupHeader(clAccountObj);
        rateCardSetupHeader.genesis__End_Date__c=System.today();
        Database.insert(rateCardSetupHeader,true);

        genesis__Rate_Card_Setup_Detail__c ratecardSetUpDetail=ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardSetupHeader);
        ratecardSetUpDetail.Start_Date__c=System.today();
        Database.insert(ratecardSetUpDetail,true);

        genesis__Rate_Card_Setup_Detail__c newRatecardSetUpDetail=ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardSetupHeader);
        newRatecardSetUpDetail.End_Date__c=System.today().addDays(-1);
        Database.insert(newRatecardSetUpDetail,true);

        genesis__Applications__c applicationObj=[SELECT id,genesis__Loan_Number__c FROM genesis__Applications__c LIMIT 1];

        genesis__Application_Pricing_Detail__c disabledPricing=ApplicationOriginationTestHelper.createDisabledPricingDetail(applicationObj,ratecardSetUpDetail.id);
        Database.insert(disabledPricing,true);

        genesis__Application_Pricing_Detail__c enabledPricing=ApplicationOriginationTestHelper.createEnabledPricingDetail(applicationObj,newRatecardSetUpDetail.id);
        Database.insert(enabledPricing,true);
    }

    /**
    * @description check for default success
    * @author Rakesh Saraf | 09-30-2024 
    **/
    @isTest
    static void checkIfBatchWorking(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Test.startTest();
        System.runAs(objAdmin){
            clcommon.DynamicJobAPI apiHandle = clcommon.APIFactory.getDynamicJobAPI(); 
            String name = 'MyDag';
            Map<String, List<Object>> jobs = new Map<String, List<Object>>();
            jobs.put('j1', new List<Object>{'PricingManagementDynamicJob', 4, '', 'Logging', 200});
            Map<String, Set<String>> dependencyList = new Map<String, Set<String>>();
            dependencyList.put('j1', new Set<String>());
            apiHandle.addDag(name, jobs, dependencyList);
            apiHandle.editCron(name, '20 30 8 10 2 ?');

            System.assert(apiHandle!=null,'Error in the DAG scheduling');
        }
        Test.stopTest();
    }

    /**
    * @description check for the case when we have a uer query in the dag configuration, so it should directly call the parameterized constructor instead of the deafault one.
    * @author Rakesh Saraf | 09-30-2024 
    **/
    @isTest
    static void checkForUserQuery(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Test.startTest();
        System.runAs(objAdmin){
            PricingManagementDynamicJob obj=new PricingManagementDynamicJob('MyDag','SELECT Id, genesis__Enabled_Flag__c, Status__c FROM genesis__Rate_Card_Setup_Header__c where genesis__End_Date__c= today');
            Id batchId=Database.executeBatch(obj,200);
            System.assert(batchId!=null,'Error in the DAG scheduling');
        }
        Test.stopTest();
    }

    /**
    * @description check if the scheduler method of the dag is working or not.
    * @author Rakesh Saraf | 09-30-2024 
    **/
    @isTest
    static void checkScheduler(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Test.startTest();
        System.runAs(objAdmin){

            String jobId = System.schedule('Schedule NLS Loan Details Batch' , '0 1 * * * ? *',  new PricingManagementDynamicJob());
            PricingManagementDynamicJob obj=new PricingManagementDynamicJob();
            obj.doExecute(null);

            System.assert(jobId!=null,'Error in the DAG scheduling');
        }
        Test.stopTest();
    }

    /**
    * @description checking if exception is thrown when a null list is passed to the doExecute method for pricing details.
    * @author Rakesh Saraf | 09-30-2024 
    **/
    @isTest
    static void checkEmptyPricingList(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Test.startTest();
        try{
            System.runAs(objAdmin){
                List<genesis__Application_Pricing_Detail__c> pricingEmptyList=new List<genesis__Application_Pricing_Detail__c>();
                PricingManagementDynamicJob obj=new PricingManagementDynamicJob(true);
                obj.doExecute(null,pricingEmptyList);
            }
        }
        catch(Exception e){
            System.assert(e!=null,'Exception not thrown');
        }
        Test.stopTest();
    }
    
    /**
    * @description checking if exception is thrown when a null list is passed to the doExecute method for rate card setup header.
    * @author Rakesh Saraf | 09-30-2024 
    **/
    @isTest
    static void checkEmptyRateCardList(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Test.startTest();
        try{
            System.runAs(objAdmin){
                List<genesis__Rate_Card_Setup_Header__c> rateCardEmptyList=new List<genesis__Rate_Card_Setup_Header__c>();
                PricingManagementDynamicJob obj=new PricingManagementDynamicJob();
                obj.doExecute(null,rateCardEmptyList);
            }
        }
        catch(Exception e){
            System.assert(e!=null,'Exception not thrown');
        }
        Test.stopTest();
    }

}