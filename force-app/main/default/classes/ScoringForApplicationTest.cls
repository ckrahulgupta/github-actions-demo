/**
 * @description       : Test class for FICOCreditRating
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-19-2025
 * @last modified by  : Kabir Pramanik
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   30-01-2022   Subham Nandi   Initial Version
**/

@isTest
private without sharing class ScoringForApplicationTest {
    
    /**
    * @description Creating test data
    * @author Kabir Pramanik | 03-19-2025 
    **/
    @TestSetup
    static void setup(){
        ApplicationOriginationSetupTestHelper.createTestSetup();
        List<genesis__Applications__c> appList = [SELECT Id FROM genesis__Applications__c WHERE Internal_Reference_Code__c = 'testApp002'];
        appList[0].genesis__Loan_Number__c = '64783033';
        appList[0].Loan_Id__c = '536363';
        Database.update(appList, true);
        List<genesis__Credit_Rating_Matrix__c> creditMatrixList = FICOCalloutTestHelper.createAllCreditRatingMatrix();
        Database.insert(creditMatrixList, true);
    }
    
    /**
    * @description This method is used to check the application tier where all parties have fico and sbss score which are more than the eligible values
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testCreditBureauLocked(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c 
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543' )
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        for(clcommon__party__c eachParty : partyList){
            eachParty.Total_Assets__c = 40000;
            eachParty.Total_Liabilities__c = 0;
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '950',
                                    SBSS70_Score__c = '350'));
        }
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_3, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check the application tier where all parties have fico and sbss score which are more than the eligible values when scored from skuid
    * @author Kabir Pramanik | 03-06-2025 
    **/
    @isTest
    static void testCreditBureauLockedSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            eachParty.Total_Assets__c = 40000;
            eachParty.Total_Liabilities__c = 0;
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '950',
                                    SBSS70_Score__c = '350'));
        }
        Database.update(partyList,true);
        Database.update(accList, true);
        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id= :partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_3, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check the tier 1 application where one party has the hightest tier value of tier 1 among all parties
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testPartyTierOneScore(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                //Net worth of party is 4xloan amount
                eachParty.Total_Assets__c = 1000000;
                eachParty.Total_Liabilities__c = 0;
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '750',
                                        SBSS70_Score__c = '205'));
            }else {
                accList.add(new Account(Id = eachParty.clcommon__Account__c, 
                                        Score_1__c = '670', 
                                        SBSS70_Score__c = '170'));
            }
        }
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c 
                                                            LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_1, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check the tier 1 application where one party has the hightet tier value of tier 1 among all parties when scored from skuid
    * @author Kabir Pramanik | 03-06-2025 
    **/
    @isTest
    static void testPartyTierOneScoreSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                //Net worth of party is 4xloan amount
                eachParty.Total_Assets__c = 1000000;
                eachParty.Total_Liabilities__c = 0;
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '750',
                                        SBSS70_Score__c = '205'));
            }else {
                accList.add(new Account(Id = eachParty.clcommon__Account__c, 
                                        Score_1__c = '670', 
                                        SBSS70_Score__c = '170'));
            }
        }
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_1, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to check the tier 2 application where one party has the highest tier value of tier 2 among all parties
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testPartyTierTwoScore(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                eachParty.Total_Assets__c = 1000000;
                eachParty.Total_Liabilities__c = 0;
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '700',
                                        SBSS70_Score__c = '170'));
            }else {
                accList.add(new Account(Id = eachParty.clcommon__Account__c, 
                                        Score_1__c = '610', 
                                        SBSS70_Score__c = '150'));
            }
        }
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_2, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check the tier 2 application where one party has the highest tier value of tier 2 among all parties when scored from skuid
    * @author Kabir Pramanik | 03-06-2025 
    **/
    @isTest
    static void testPartyTierTwoScoreSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                eachParty.Total_Assets__c = 1000000;
                eachParty.Total_Liabilities__c = 0;
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '700',
                                        SBSS70_Score__c = '170'));
            }else {
                accList.add(new Account(Id = eachParty.clcommon__Account__c, 
                                        Score_1__c = '610', 
                                        SBSS70_Score__c = '150'));
            }
        }
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_2, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check the tier 3 application where one party has the highest tier value of tier 3 among all parties
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testPartyTierThreeScore(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                eachParty.Total_Assets__c = 10000;
                eachParty.Total_Liabilities__c = 500;
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '610',
                                        SBSS70_Score__c = '150'));
            }else {
                accList.add(new Account(Id = eachParty.clcommon__Account__c, 
                                        Score_1__c = '0', 
                                        SBSS70_Score__c = '0'));
            }
        }
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_3, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check the tier 3 application where one party has the highest tier value of tier 3 among all parties when scored from skuid
    * @author Kabir Pramanik | 03-06-2025 
    **/
    @isTest
    static void testPartyTierThreeScoreSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                eachParty.Total_Assets__c = 10000;
                eachParty.Total_Liabilities__c = 500;
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '610',
                                        SBSS70_Score__c = '150'));
            }else {
                accList.add(new Account(Id = eachParty.clcommon__Account__c, 
                                        Score_1__c = '0', 
                                        SBSS70_Score__c = '0'));
            }
        }
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_3, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to check the application tier 3 where both fico and sbss score is 0 for the parties
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testPartyWithZeroScores(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            eachParty.Total_Assets__c = 10000;
            eachParty.Total_Liabilities__c = 500;
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '0',
                                    SBSS70_Score__c = '0'));
        }
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_3, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check the application tier 3 where both fico and sbss score is 0 for the parties when scored from skuid
    * @author Kabir Pramanik | 03-06-2025 
    **/
    @isTest
    static void testPartyWithZeroScoresSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            eachParty.Total_Assets__c = 10000;
            eachParty.Total_Liabilities__c = 500;
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '0',
                                    SBSS70_Score__c = '0'));
        }
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c 
                                                            LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_3, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check the application tier based on fico and sbss score where both is greater than maximum eligible for all the parties
    * @author Kabir | 03-06-2025
    **/
    @isTest
    static void testPartyScoresExceedMaxEligible(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                eachParty.Total_Assets__c = 10000;
                eachParty.Total_Liabilities__c = 500;
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '1050',
                                        SBSS70_Score__c = '250'));
            }
        }
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c 
                                                            LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_3, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check the application tier based on fico and sbss score where both is greater than maximum eligible for all parties when scored from skuid
    * @author Kabir | 03-06-2025
    **/
    @isTest
    static void testPartyScoresExceedMaxEligibleSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            eachParty.Total_Assets__c = 10000;
            eachParty.Total_Liabilities__c = 500;
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '1050',
                                    SBSS70_Score__c = '250'));
        }
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c 
                                                            LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_3, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to check the tier 4 application where parties have socres of tier 4 and dealer's customised loan limit is more than 0
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testPartyTierFourScoreDealerCustomizeLimitPositive(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c  
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            eachParty.Total_Assets__c = 5000;
            eachParty.Total_Liabilities__c = 500;
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '560',
                                    SBSS70_Score__c = '140'));
        }
        Database.update(partyList,true);
        Database.update(accList, true);
        genesis__Business_Information__c dealerBusinessInfo = new genesis__Business_Information__c(
            Id = partyList[0].genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c,
            Customised_Loan_Limit__c = 10000
        );
        Database.update(dealerBusinessInfo, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c 
                                                            LIMIT 1];
            System.assertEquals(100, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_4, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to check the tier 4 application where parties have socres of tier 4 and dealer's customised loan limit is more than 0 when scored from skuid
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testPartyTierFourScoreDealerCustomizeLimitPositiveSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c  
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            eachParty.Total_Assets__c = 5000;
            eachParty.Total_Liabilities__c = 500;
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '560',
                                    SBSS70_Score__c = '140'));
        }
        Database.update(partyList,true);
        Database.update(accList, true);
        genesis__Business_Information__c dealerBusinessInfo = new genesis__Business_Information__c(
            Id = partyList[0].genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c,
            Customised_Loan_Limit__c = 10000
        );
        Database.update(dealerBusinessInfo, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(100, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_4, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to check the tier 4 application where parties have socres of tier 4 and dealer's customised loan limit is 0
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testPartyTierFourScoreDealerCustomizeLimitZero(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c  
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            eachParty.Total_Assets__c = 5000;
            eachParty.Total_Liabilities__c = 500;
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '560',
                                    SBSS70_Score__c = '140'));
        }
        Database.update(partyList,true);
        Database.update(accList, true);
        genesis__Business_Information__c dealerBusinessInfo = new genesis__Business_Information__c(
            Id = partyList[0].genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c,
            Customised_Loan_Limit__c = 0
        );
        Database.update(dealerBusinessInfo, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_4, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to check the tier 4 application where parties have socres of tier 4 and dealer's customised loan limit is 0 when scored from skuid
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testPartyTierFourScoreDealerCustomizeLimitZeroSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c  
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            eachParty.Total_Assets__c = 5000;
            eachParty.Total_Liabilities__c = 500;
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '560',
                                    SBSS70_Score__c = '140'));
        }
        Database.update(partyList,true);
        Database.update(accList, true);
        genesis__Business_Information__c dealerBusinessInfo = new genesis__Business_Information__c(
            Id = partyList[0].genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c,
            Customised_Loan_Limit__c = 0
        );
        Database.update(dealerBusinessInfo, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_4, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to check the tier 4 application where dealer's customised loan limit is 0 and parties' hightest net worth is 0 
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testPartyNetWorthZeroDealerCustomizeLimitZero(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c  
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            eachParty.Total_Assets__c = 0;
            eachParty.Total_Liabilities__c = 0;
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '720',
                                    SBSS70_Score__c = '170'));
        }
        Database.update(partyList,true);
        Database.update(accList, true);
        genesis__Business_Information__c dealerBusinessInfo = new genesis__Business_Information__c(
            Id = partyList[0].genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c,
            Customised_Loan_Limit__c = 0
        );
        Database.update(dealerBusinessInfo, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_4, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to check the tier 4 application where dealer's customised loan limit is 0, parties' hightest net worth is 0 and dealer customized loan limit is 0 when scored from skuid
    * @author Kabir Pramanik | 03-06-2025 
    **/
    @isTest
    static void testPartyNetWorthZeroDealerCustomizeLimitZeroSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c  
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            eachParty.Total_Assets__c = 0;
            eachParty.Total_Liabilities__c = 0;
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '720',
                                    SBSS70_Score__c = '170'));
        }
        Database.update(partyList,true);
        Database.update(accList, true);
        genesis__Business_Information__c dealerBusinessInfo = new genesis__Business_Information__c(
            Id = partyList[0].genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c,
            Customised_Loan_Limit__c = 0
        );
        Database.update(dealerBusinessInfo, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_4, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check the tier 4 application where one party has fico score more than maximum eligible and others have tier 4 score
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testPartiesWithScoreExceedMaxEligibleAndTierFour(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '910',
                                        SBSS70_Score__c = '150'));
            }else {
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '500',
                                        SBSS70_Score__c = '120'));
            }
            eachParty.Total_Assets__c = 0;
            eachParty.Total_Liabilities__c = 0;
        }
        Database.update(partyList,true);
        Database.update(accList, true);
        genesis__Business_Information__c dealerBusinessInfo = new genesis__Business_Information__c(
            Id = partyList[0].genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c,
            Customised_Loan_Limit__c = 0
        );
        Database.update(dealerBusinessInfo, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c 
                                                            LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_4, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check the application tier 4 where some party has fico score more than maximum eligible and others have tier 4 score when scored from skuid
    * @author Kabir Pramanik | 03-06-2025 
    **/
    @isTest
    static void testPartiesWithScoreExceedMaxEligibleAndTierFourSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '910',
                                        SBSS70_Score__c = '150'));
            }else {
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '500',
                                        SBSS70_Score__c = '120'));
            }
            eachParty.Total_Assets__c = 0;
            eachParty.Total_Liabilities__c = 0;
        }
        Database.update(partyList,true);
        Database.update(accList, true);
        genesis__Business_Information__c dealerBusinessInfo = new genesis__Business_Information__c(
            Id = partyList[0].genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c,
            Customised_Loan_Limit__c = 0
        );
        Database.update(dealerBusinessInfo, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c 
                                                            LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_4, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check the tier 4 application where one party has fico score more than maximum eligible and others have tier 4 score. Dealer customized loan limit is positive
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testPartiesScoreExceedMaxEligibleAndTierFourDealerCustLimitPositive(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '910',
                                        SBSS70_Score__c = '150'));
            }else {
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '500',
                                        SBSS70_Score__c = '120'));
            }
            eachParty.Total_Assets__c = 0;
            eachParty.Total_Liabilities__c = 0;
        }
        Database.update(partyList,true);
        Database.update(accList, true);
        genesis__Business_Information__c dealerBusinessInfo = new genesis__Business_Information__c(
            Id = partyList[0].genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c,
            Customised_Loan_Limit__c = 10000
        );
        Database.update(dealerBusinessInfo, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c 
                                                            LIMIT 1];
            System.assertEquals(100, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_4, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check the application tier 4 where some party has fico score more than maximum eligible and others have tier 4 score when scored from skuid. Dealer customized loan limit is positive
    * @author Kabir Pramanik | 03-06-2025 
    **/
    @isTest
    static void testPartiesScoreExceedMaxEligibleAndTierFourDealerCustLimitPosSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                FROM genesis__Applications__c
                                                                                WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '910',
                                        SBSS70_Score__c = '150'));
            }else {
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '500',
                                        SBSS70_Score__c = '120'));
            }
            eachParty.Total_Assets__c = 0;
            eachParty.Total_Liabilities__c = 0;
        }
        Database.update(partyList,true);
        Database.update(accList, true);
        genesis__Business_Information__c dealerBusinessInfo = new genesis__Business_Information__c(
            Id = partyList[0].genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c,
            Customised_Loan_Limit__c = 10000
        );
        Database.update(dealerBusinessInfo, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c 
                                                            LIMIT 1];
            System.assertEquals(100, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_4, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description Test method is to check appliation tier where the legal entity type of borrower is DBA 
    * @author Kabir Pramanik | 03-06-2025 
    **/
    @isTest
    static void testAppicationTierForDBA(){
        List<clcommon__Legal_Entity__c> dbaEntity = [SELECT Id From clcommon__Legal_Entity__c WHERE clcommon__Legal_Entity_Type__c = :PortalConstants.INDIVIDUAL_ENTITY];
        List<genesis__Applications__c> appObjList = [SELECT Id, genesis__Account__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '398762543' LIMIT 1];
        Account borrowerAcc = new Account();
        borrowerAcc.Id = appObjList[0].genesis__Account__c;
        borrowerAcc.clcommon__Legal_Entity_Type__c = dbaEntity[0].Id;
        borrowerAcc.Score_1__c = '0';
        Database.update(borrowerAcc, true);
        List<Account> appAccounList=[SELECT Id
                                        FROM Account 
                                        WHERE Id In (SELECT clcommon__Account__c 
                                                        FROM clcommon__Party__c 
                                                        WHERE genesis__Application__c=:appObjList[0].Id 
                                                        AND clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME)];
        for(Account eachAcc : appAccounList){
            eachAcc.Score_1__c='750';
            eachAcc.SBSS70_Score__c='200';
        }
        Database.update(appAccounList,true);

        List<clcommon__party__c> partyList = [SELECT Id FROM clcommon__Party__c WHERE genesis__Application__c = :appObjList[0].Id AND clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME LIMIT 1];
        //Net worth of any party is 4xloan amount or more
        partyList[0].Total_Assets__c = 10000000;
        partyList[0].Total_Liabilities__c = 0;
        Database.update(partyList,true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(appObjList[0].Id);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:appObjList[0].Id LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_1, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description Test method is to check appliation tier where the legal entity type of borrower is DBA when scored from skuid
    * @author Kabir Pramanik | 03-06-2025 
    **/
    @isTest
    static void testApplicationTierForDBASkuid(){
        List<clcommon__Legal_Entity__c> dbaEntity = [SELECT Id From clcommon__Legal_Entity__c WHERE clcommon__Legal_Entity_Type__c = :PortalConstants.INDIVIDUAL_ENTITY];
        List<genesis__Applications__c> appObjList = [SELECT Id, genesis__Account__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '398762543' LIMIT 1];
        Account borrowerAcc = new Account();
        borrowerAcc.Id = appObjList[0].genesis__Account__c;
        borrowerAcc.clcommon__Legal_Entity_Type__c = dbaEntity[0].Id;
        borrowerAcc.Score_1__c = '0';
        Database.update(borrowerAcc, true);
        List<Account> appAccounList=[SELECT Id FROM Account WHERE Id In(SELECT clcommon__Account__c FROM clcommon__Party__c WHERE genesis__Application__c=:appObjList[0].Id AND clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME)];
        for(Account eachAcc : appAccounList){
            eachAcc.Score_1__c='750';
            eachAcc.SBSS70_Score__c='200';
        }
        Database.update(appAccounList,true);

        List<clcommon__party__c> partyList = [SELECT Id FROM clcommon__Party__c WHERE genesis__Application__c = :appObjList[0].Id AND clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME LIMIT 1];
        //Net worth of any party is 4xloan amount
        partyList[0].Total_Assets__c = 1000000;
        partyList[0].Total_Liabilities__c = 0;
        Database.update(partyList,true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(appObjList[0].Id);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:appObjList[0].Id LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_1, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description Test method is to check appliation tier where the legal entity type of borrower is Corporation
    * @author Kabir Pramanik | 03-06-2025 
    **/
    @isTest
    static void testApplicationTierForCorporation(){
        List<Account> accList = new List<Account>();
        List<clcommon__Legal_Entity__c> corporationEntity = [SELECT Id From clcommon__Legal_Entity__c WHERE clcommon__Legal_Entity_Type__c = :PortalConstants.CORPORATION];
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '0',
                                        clcommon__Legal_Entity_Type__c = corporationEntity[0].Id));
            }else {
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '750',
                                        SBSS70_Score__c = '200'));
            }
            eachParty.Total_Assets__c = 10000000;
            eachParty.Total_Liabilities__c = 0;
        }
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c 
                                                            LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_1, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description Test method is to check appliation tier where the legal entity type of borrower is Corporation when scored from skuid
    * @author Kabir Pramanik | 03-06-2025 
    **/
    @isTest
    static void testApplicationTierForCorporationSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__Legal_Entity__c> corporationEntity = [SELECT Id From clcommon__Legal_Entity__c WHERE clcommon__Legal_Entity_Type__c = :PortalConstants.CORPORATION];
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '0',
                                        clcommon__Legal_Entity_Type__c = corporationEntity[0].Id));
            }else {
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '750',
                                        SBSS70_Score__c = '200'));
            }
            eachParty.Total_Assets__c = 10000000;
            eachParty.Total_Liabilities__c = 0;
        }
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c 
                                                            LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_1, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to check whether application tier changes or not when the application already has fico and sbss scored populated
    * @author Kabir Pramanik | 03-07-2025 
    **/
    @isTest
    static void testCreditRatingOfAppWithScores(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '700',
                                    SBSS70_Score__c = '170'));
            eachParty.Total_Assets__c = 10000000;
            eachParty.Total_Liabilities__c = 0;
        }
        Database.update(partyList,true);
        Database.update(accList, true);
        genesis__Applications__c appObj = new genesis__Applications__c(
            //Tier 1
            Id = partyList[0].genesis__Application__c,
            FICO_Score__c = '750',
            SBSS_70_Score__c = '220',
            Net_Worth__c = '5000000'
        );
        Database.update(appObj, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c 
                                                            LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_1, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to check whether application tier changes or not when the application already has fico and sbss scored populated, when scored from skuid
    * @author Kabir Pramanik | 03-07-2025 
    **/
    @isTest
    static void testCreditRatingOfAppWithScoresSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '700',
                                    SBSS70_Score__c = '170'));
            eachParty.Total_Assets__c = 10000000;
            eachParty.Total_Liabilities__c = 0;
        }
        Database.update(partyList,true);
        Database.update(accList, true);
        genesis__Applications__c appObj = new genesis__Applications__c(
            //Tier 1
            Id = partyList[0].genesis__Application__c,
            FICO_Score__c = '750',
            SBSS_70_Score__c = '220',
            Net_Worth__c = '5000000'
        );
        Database.update(appObj, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c 
                                                            LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_2, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to check the application tier where neither the parties are scored nor the application and it is being scored from skuid
    * @author Kabir Pramanik | 03-07-2025 
    **/
    @isTest
    static void testAppWithNoPartyScoredSkuid(){
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')];
        for(clcommon__Party__c eachParty : partyList){
            eachParty.Total_Assets__c = 500000;
            eachParty.Total_Liabilities__c = 0;
        }
        Database.update(partyList,true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c 
                                                            LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_3, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This mehtod is to check the application tier where not all parties are scored and the application is being scored from skuid
    * @author Kabir Pramanik | 03-07-2025 
    **/
    @isTest
    static void testAppWithOnePartyScoredSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '700',
                                        SBSS70_Score__c = '170'));
            }
            eachParty.Total_Assets__c = 10000000;
            eachParty.Total_Liabilities__c = 0;
        }
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c 
                                                            LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_2, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check tier 1 evergreen application
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testPartyTierOneScoreEvergreenApp(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '750',
                                    SBSS70_Score__c = '205'));
            eachParty.Total_Assets__c = 1000000;
            eachParty.Total_Liabilities__c = 0;
        }
        genesis__Applications__c appObj = new genesis__Applications__c(
            Id = partyList[0].genesis__Application__c,
            Is_Evergreen__c = true
        );
        Database.update(appObj, true);
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c,
                                                                    Stage__c,
                                                                    Is_Evergreen__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_1, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(PortalConstants.SCORE_CREDIT_REFERENCE, updatedAppObj[0].Stage__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Is_Evergreen__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check tier 1 evergreen application when scored from skuid
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testPartyTierOneScoreEvergreenAppSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '750',
                                    SBSS70_Score__c = '205'));
            eachParty.Total_Assets__c = 1000000;
            eachParty.Total_Liabilities__c = 0;
        }
        genesis__Applications__c appObj = new genesis__Applications__c(
            Id = partyList[0].genesis__Application__c,
            Is_Evergreen__c = true
        );
        Database.update(appObj, true);
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c,
                                                                    Stage__c,
                                                                    Is_Evergreen__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_1, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(PortalConstants.SCORE_CREDIT_REFERENCE, updatedAppObj[0].Stage__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Is_Evergreen__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check tier 2 evergreen application
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testpartyTierTwoScoreEvergreenApp(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '700',
                                    SBSS70_Score__c = '170'));
            eachParty.Total_Assets__c = 1000000;
            eachParty.Total_Liabilities__c = 0;
        }
        genesis__Applications__c appObj = new genesis__Applications__c(
            Id = partyList[0].genesis__Application__c,
            Is_Evergreen__c = true,
            Evergreen_Tier_Two_Business_Info_Status__c = PortalConstants.EVERGREEN_BIZ_STATUS_IN_ELIGIBLE
        );
        Database.update(appObj, true);
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Evergreen_Tier_Two_Business_Info_Status__c,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c,
                                                                    Stage__c,
                                                                    Is_Evergreen__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_2, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(PortalConstants.SCORE_CREDIT_REFERENCE, updatedAppObj[0].Stage__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(PortalConstants.EVERGREEN_BIZ_STATUS_PENDING, updatedAppObj[0].Evergreen_Tier_Two_Business_Info_Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Is_Evergreen__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check tier 2 evergreen application when scored from skuid
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testpartyTierTwoScoreEvergreenAppSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '700',
                                    SBSS70_Score__c = '170'));
            eachParty.Total_Assets__c = 1000000;
            eachParty.Total_Liabilities__c = 0;
        }
        genesis__Applications__c appObj = new genesis__Applications__c(
            Id = partyList[0].genesis__Application__c,
            Is_Evergreen__c = true,
            Evergreen_Tier_Two_Business_Info_Status__c = PortalConstants.EVERGREEN_BIZ_STATUS_IN_ELIGIBLE
        );
        Database.update(appObj, true);
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Evergreen_Tier_Two_Business_Info_Status__c,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c,
                                                                    Stage__c,
                                                                    Is_Evergreen__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_2, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(PortalConstants.SCORE_CREDIT_REFERENCE, updatedAppObj[0].Stage__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(PortalConstants.EVERGREEN_BIZ_STATUS_PENDING, updatedAppObj[0].Evergreen_Tier_Two_Business_Info_Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Is_Evergreen__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check tier 3 evergreen application
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testPartyTierThreeScoreEvergreenApp(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '0',
                                    SBSS70_Score__c = '0'));
            eachParty.Total_Assets__c = 50000;
            eachParty.Total_Liabilities__c = 0;
        }
        genesis__Applications__c appObj = new genesis__Applications__c(
            Id = partyList[0].genesis__Application__c,
            Is_Evergreen__c = true
        );
        Database.update(appObj, true);
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c,
                                                                    Stage__c,
                                                                    Is_Evergreen__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_3, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(PortalConstants.SCORE_CREDIT_REFERENCE, updatedAppObj[0].Stage__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Is_Evergreen__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check tier 3 evergreen application when scored from skuid
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testPartyTierThreeScoreEvergreenAppSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '0',
                                    SBSS70_Score__c = '0'));
            eachParty.Total_Assets__c = 50000;
            eachParty.Total_Liabilities__c = 0;
        }
        genesis__Applications__c appObj = new genesis__Applications__c(
            Id = partyList[0].genesis__Application__c,
            Is_Evergreen__c = true
        );
        Database.update(appObj, true);
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c,
                                                                    Stage__c,
                                                                    Is_Evergreen__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_3, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(PortalConstants.SCORE_CREDIT_REFERENCE, updatedAppObj[0].Stage__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Is_Evergreen__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check tier 4 evergreen application
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testPartyTierFourScoreEvergreenApp(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '250',
                                    SBSS70_Score__c = '0'));
            eachParty.Total_Assets__c = 50000;
            eachParty.Total_Liabilities__c = 0;
        }
        genesis__Applications__c appObj = new genesis__Applications__c(
            Id = partyList[0].genesis__Application__c,
            Is_Evergreen__c = true
        );
        genesis__Business_Information__c dealerBusinessInfo = new genesis__Business_Information__c(
            Id = partyList[0].genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c,
            Customised_Loan_Limit__c = 50000
        );
        Database.update(appObj, true);
        Database.update(partyList,true);
        Database.update(accList, true);
        Database.update(dealerBusinessInfo, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c,
                                                                    Stage__c,
                                                                    Is_Evergreen__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(100, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_4, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(PortalConstants.NEW_ENTERED_APPLICATION_STATUS, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(PortalConstants.APPLICANT_SIGNATURE, updatedAppObj[0].Stage__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Is_Evergreen__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check tier 4 evergreen application
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testPartyTierFourScoreEvergreenAppSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                    Score_1__c = '250',
                                    SBSS70_Score__c = '0'));
            eachParty.Total_Assets__c = 50000;
            eachParty.Total_Liabilities__c = 0;
        }
        genesis__Applications__c appObj = new genesis__Applications__c(
            Id = partyList[0].genesis__Application__c,
            Is_Evergreen__c = true
        );
        genesis__Business_Information__c dealerBusinessInfo = new genesis__Business_Information__c(
            Id = partyList[0].genesis__Application__r.Dealer_Name__r.genesis__Business_Information__c,
            Customised_Loan_Limit__c = 50000
        );
        Database.update(appObj, true);
        Database.update(partyList,true);
        Database.update(accList, true);
        Database.update(dealerBusinessInfo, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c,
                                                                    Stage__c,
                                                                    Is_Evergreen__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(100, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_4, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(PortalConstants.NEW_ENTERED_APPLICATION_STATUS, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(PortalConstants.APPLICANT_SIGNATURE, updatedAppObj[0].Stage__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Is_Evergreen__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check exception by passing an id for which no application is present
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testInvalidAppIdException(){
        List<genesis__Applications__c> appObjList = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '398762543' LIMIT 1];
        Id appId = appObjList[0].Id;
        Database.delete(appObjList, true);
        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(appId);
            List<clcommon__Log__c> logList = [SELECT Id
                                                FROM clcommon__Log__c 
                                                WHERE Name = :ConstantValues.CREDIT_RATING_EXCEPTION
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is used to check exception by passing an id for which no application is present when scored from skuid
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testInvalidAppIdExceptionSkuid(){
        List<genesis__Applications__c> appObjList = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '398762543' LIMIT 1];
        Id appId = appObjList[0].Id;
        Database.delete(appObjList, true);
        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(appId);
            List<clcommon__Log__c> logList = [SELECT Id
                                                FROM clcommon__Log__c 
                                                WHERE Name = :ConstantValues.CREDIT_RATING_EXCEPTION
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to check exception by passing a null value as application id
    * @author Kabir Pramanik | 03-19-2025 
    **/
    @isTest 
    static void testNullAppIdException(){
        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(null);
            List<clcommon__Log__c> logList = [SELECT Id
                                                FROM clcommon__Log__c 
                                                WHERE Name = :ConstantValues.CREDIT_RATING_EXCEPTION
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to check exception by passing a null value as application id when scored from skuid
    * @author Kabir Pramanik | 03-19-2025 
    **/
    @isTest 
    static void testNullAppIdExceptionSkuid(){
        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(null);
            List<clcommon__Log__c> logList = [SELECT Id
                                                FROM clcommon__Log__c 
                                                WHERE Name = :ConstantValues.CREDIT_RATING_EXCEPTION
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test whether an application having ACTIVE status is rescored or not if attempted
    * @author Kabir Pramanik | 03-07-2025 
    **/
    @isTest
    static void testActiveApplicationScoring(){
        List<Account> accList = new List<Account>();
        List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = :ConstantValues.CREDIT_RATE_2 LIMIT 1];
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                //Net worth of party is 4xloan amount
                eachParty.Total_Assets__c = 1000000;
                eachParty.Total_Liabilities__c = 0;
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '750',
                                        SBSS70_Score__c = '205'));
            }else {
                accList.add(new Account(Id = eachParty.clcommon__Account__c, 
                                        Score_1__c = '670', 
                                        SBSS70_Score__c = '170'));
            }
        }
        //If fico and sbss score are present in an application, application score is not re-evaluated. 
        //So keeping the scores as null to give this mehtod the scope to re-evaluate
        genesis__Applications__c appObj = new genesis__Applications__c(
            Id = partyList[0].genesis__Application__c,
            FICO_Score__c = null,
            SBSS_70_Score__c = null,
            genesis__Credit_Rating__c = creditRatingMatrixList[0].Id,
            genesis__Status__c = ConstantValues.ACTIVE
        );
        Database.update(partyList,true);
        Database.update(accList, true);
        Database.update(appObj, true);

        System.runAs(FICOCalloutTestHelper.getCreditUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(ConstantValues.CREDIT_RATE_2, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.ACTIVE, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test whether an application having PENDING APPROVAL status is rescored or not if attempted
    * @author Kabir Pramanik | 03-07-2025 
    **/
    @isTest
    static void testPendingApprovalApplicationScoring(){
        List<Account> accList = new List<Account>();
        List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = :ConstantValues.CREDIT_RATE_2 LIMIT 1];
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                //Net worth of party is 4xloan amount
                eachParty.Total_Assets__c = 1000000;
                eachParty.Total_Liabilities__c = 0;
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '750',
                                        SBSS70_Score__c = '205'));
            }else {
                accList.add(new Account(Id = eachParty.clcommon__Account__c, 
                                        Score_1__c = '670', 
                                        SBSS70_Score__c = '170'));
            }
        }
        genesis__Applications__c appObj = new genesis__Applications__c(
            Id = partyList[0].genesis__Application__c,
            FICO_Score__c = null,
            SBSS_70_Score__c = null,
            genesis__Credit_Rating__c = creditRatingMatrixList[0].Id,
            genesis__Status__c = ConstantValues.PENDING_APPROVAL_APPLICATION_STATUS
        );
        Database.update(partyList,true);
        Database.update(accList, true);
        Database.update(appObj, true);

        System.runAs(FICOCalloutTestHelper.getCreditUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(ConstantValues.CREDIT_RATE_2, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.PENDING_APPROVAL_APPLICATION_STATUS, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to check whether exception is thrown or not if credit rating matrix is not present
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testCreditRatingMatrixMissingException(){
        List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList = [SELECT Id FROM genesis__Credit_Rating_Matrix__c];
        List<genesis__Applications__c> appObjList = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '398762543' LIMIT 1];
        Database.delete(creditRatingMatrixList, true);
        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(appObjList[0].Id);
            List<clcommon__Log__c> logList = [SELECT Id
                                                FROM clcommon__Log__c 
                                                WHERE Name = :ConstantValues.CREDIT_RATING_EXCEPTION
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to check whether exception is thrown or not if credit rating matrix is not present when scored from skuid
    * @author Simran | 04-08-2024 
    **/
    @isTest
    static void testCreditRatingMatrixMissingExceptionSkuid(){
        List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList = [SELECT Id FROM genesis__Credit_Rating_Matrix__c];
        List<genesis__Applications__c> appObjList = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '398762543' LIMIT 1];
        Database.delete(creditRatingMatrixList, true);
        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(appObjList[0].Id);
            List<clcommon__Log__c> logList = [SELECT Id
                                                FROM clcommon__Log__c 
                                                WHERE Name = :ConstantValues.CREDIT_RATING_EXCEPTION
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test application tier with negativo fico and sbss scores
    * @author Kabir Pramanik | 03-07-2025 
    **/
    @isTest
    static void testAppWithNegativeScores(){
        List<genesis__Applications__c> appObjList = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Number__c = '398762543' LIMIT 1];
        appObjList[0].FICO_Score__c = '-100';
        appObjList[0].SBSS_70_Score__c = '-10';
        appObjList[0].Net_Worth__c = '5000000';
        Database.update(appObjList, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.ficoCreditRatingMatrix(appObjList[0].Id);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:appObjList[0].Id LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_3, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test application tier with negativo fico and sbss scores when scored from skuid
    * @author Kabir Pramanik | 03-07-2025 
    **/
    @isTest
    static void testAppWithNegativeScoresSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            eachParty.Total_Assets__c = 5000;
            eachParty.Total_Liabilities__c = 0;
            accList.add(new Account(Id = eachParty.clcommon__Account__c, 
                                    Score_1__c = '-100', 
                                    SBSS70_Score__c = '-10'));
        }
        genesis__Applications__c appObj = new genesis__Applications__c(
            Id = partyList[0].genesis__Application__c,
            FICO_Score__c = '-100',
            SBSS_70_Score__c = '-10',
            Net_Worth__c = '5000'
        );
        Database.update(partyList,true);
        Database.update(accList, true);
        Database.update(appObj, true);

        System.runAs(FICOCalloutTestHelper.getAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(30, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_3, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test whether an User with CFA Admin User profile can score an application from skuid or not
    * @author Kabir Pramanik | 03-07-2025 
    **/
    @isTest
    static void testCFAAdminUserScoringAccessSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                eachParty.Total_Assets__c = 1000000;
                eachParty.Total_Liabilities__c = 0;
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '750',
                                        SBSS70_Score__c = '205'));
            }else {
                accList.add(new Account(Id = eachParty.clcommon__Account__c, 
                                        Score_1__c = '670', 
                                        SBSS70_Score__c = '170'));
            }
        }
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getCFAAdminUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_1, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test whether an User with Loan Accounting profile can score an application from skuid or not
    * @author Kabir Pramanik | 03-07-2025 
    **/
    @isTest
    static void testLoanAccUserScoringAccessSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                eachParty.Total_Assets__c = 1000000;
                eachParty.Total_Liabilities__c = 0;
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '750',
                                        SBSS70_Score__c = '205'));
            }else {
                accList.add(new Account(Id = eachParty.clcommon__Account__c, 
                                        Score_1__c = '670', 
                                        SBSS70_Score__c = '170'));
            }
        }
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getLoanAccountingUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_1, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test whether an User with Loan Accounting profile can score an application from skuid or not
    * @author Kabir Pramanik | 03-07-2025 
    **/
    @isTest
    static void testMasterCreditUserScoringAccessSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                eachParty.Total_Assets__c = 1000000;
                eachParty.Total_Liabilities__c = 0;
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '750',
                                        SBSS70_Score__c = '205'));
            }else {
                accList.add(new Account(Id = eachParty.clcommon__Account__c, 
                                        Score_1__c = '670', 
                                        SBSS70_Score__c = '170'));
            }
        }
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getMasterCreditUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_1, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test whether an User with Loan Accounting profile can score an application from skuid or not
    * @author Kabir Pramanik | 03-07-2025 
    **/
    @isTest
    static void testCreditUserScoringAccessSkuid(){
        List<Account> accList = new List<Account>();
        List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        genesis__Application__c
                                                FROM clcommon__Party__c
                                                WHERE genesis__Application__c In (SELECT Id
                                                                                    FROM genesis__Applications__c
                                                                                    WHERE genesis__Loan_Number__c = '398762543')
                                                AND clcommon__Party_Types__c In (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];
        
        for(clcommon__party__c eachParty : partyList){
            if(eachParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                eachParty.Total_Assets__c = 1000000;
                eachParty.Total_Liabilities__c = 0;
                accList.add(new Account(Id = eachParty.clcommon__Account__c,
                                        Score_1__c = '750',
                                        SBSS70_Score__c = '205'));
            }else {
                accList.add(new Account(Id = eachParty.clcommon__Account__c, 
                                        Score_1__c = '670', 
                                        SBSS70_Score__c = '170'));
            }
        }
        Database.update(partyList,true);
        Database.update(accList, true);

        System.runAs(FICOCalloutTestHelper.getCreditUser()[0]) {
            Test.startTest();
            FICOCreditRating.scoreTheApplication(partyList[0].genesis__Application__c);
            List<genesis__Applications__c> updatedAppObj = [SELECT Id,
                                                                    Guarantee__c,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    genesis__Status__c,
                                                                    Additional_Information_Needed__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id=:partyList[0].genesis__Application__c LIMIT 1];
            System.assertEquals(0, updatedAppObj[0].Guarantee__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.CREDIT_RATE_1, updatedAppObj[0].genesis__Credit_Rating__r.Name, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(ConstantValues.SCORECARD_GENERATED, updatedAppObj[0].genesis__Status__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(false, updatedAppObj[0].Additional_Information_Needed__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
}