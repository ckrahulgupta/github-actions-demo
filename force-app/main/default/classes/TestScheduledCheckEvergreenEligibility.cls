/**
 * @description       : Test Class to cover ScheduledCheckEvergreenEligibility
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 14-05-2023
 * @last modified by  : Subham Nandi
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   09-05-2023   Subham Nandi   Initial Version
**/
@isTest
public with sharing class TestScheduledCheckEvergreenEligibility {
    @TestSetup
    static void makeData(){
        //Create Applications with the current crop year
        List<genesis__Credit_Rating_Matrix__c> objCreditRatingList = FICOCalloutTestHelper.createCreditRatingMatrix();
        Map<String,String> mapOfCreditRating = new Map<String,String>();
        genesis__Business_Information__c objDealerBusinessInfo = new genesis__Business_Information__c ( Approved_Loan_Amount__c = 0,
                                                                                                        Contract_Loan_Limit__c = 1000000,  
                                                                                                        Customised_Loan_Limit__c = 500000, 
                                                                                                        Customised_Individual_Limit__c = 250000, 
                                                                                                        Remaining_Customised_Limit__c = 500000);
        Database.insert(objDealerBusinessInfo,true);
        Account objDealerAccount = TestClassHelper.createAccount(objDealerBusinessInfo);

        for(genesis__Credit_Rating_Matrix__c eachRating : objCreditRatingList){
            mapOfCreditRating.put(eachRating.Name, eachRating.Id);
        }
        genesis__Applications__c objCurrentApplication = TestClassHelper.createApplication();
        objCurrentApplication.Crop_Year__c = String.valueOf(System.today().year());
        objCurrentApplication.Signing_Method__c = 'In Person - Docusign';
        objCurrentApplication.genesis__Credit_Rating__c = mapOfCreditRating.get('Tier 1');
        objCurrentApplication.Non_Accrual__c = false;
        objCurrentApplication.genesis__Status__c = 'ACTIVE';
        objCurrentApplication.Dealer_Name__c = objDealerAccount.Id;
        Database.update(objCurrentApplication,true);
    }
    @isTest
    public static void testCase1(){
        Test.startTest();
        ScheduledCheckEvergreenEligibility checkEvergreen = new ScheduledCheckEvergreenEligibility();
        checkEvergreen.execute(null);
        Test.stopTest();
    }

    @isTest
    public static void testCase2(){
        Test.startTest();
        Database.delete([SELECT id FROM genesis__Applications__c]);
        ScheduledCheckEvergreenEligibility checkEvergreen = new ScheduledCheckEvergreenEligibility();
        checkEvergreen.execute(null);
        Test.stopTest();
    }
}