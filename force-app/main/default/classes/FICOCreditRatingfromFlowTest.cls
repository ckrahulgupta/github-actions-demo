/**
 * @description       : 
 * @author            : Ayan Bhowmik
 * @group             : 
 * @last modified on  : 02-11-2024
 * @last modified by  : Soumik Pattanayak
**/

@IsTest
private without sharing class FICOCreditRatingfromFlowTest {
    @TestSetup
    static void makeData(){

         // Creating sole-prop, corporation, dba legal entities
         clcommon__Legal_Entity__c solePropLegalEntityObj  = FICOCalloutTestHelper.createSolePropLegalEntity();
         Database.insert(solePropLegalEntityObj, true);
 
         // Creating cl product
         clcommon__CL_Product__c clProductObj = FICOCalloutTestHelper.createCLProductForApplication();
         Database.insert(clProductObj,true);
 
         // Creating cl purpose
         clcommon__CL_Purpose__c  clPurposeObj = FICOCalloutTestHelper.createCLPurposeForApplication();
         Database.insert(clPurposeObj,true);
 
         // Creating CL, Borrower, Principal, Dealer Party Types
         clcommon__Party_Type__c borrowerPartyTypeObj = FICOCalloutTestHelper.createPartyType('BORROWER');
         Database.insert(borrowerPartyTypeObj, true);

        //Creating Credit Rating Matrix
        List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList = ApplicationOriginationTestHelper.createCreditRatingMatrix();
        Database.insert(creditRatingMatrixList,true);

         // Creating Dealer, Borrower Business Information
         genesis__Business_Information__c dealerBusinessInfoObj = FICOCalloutTestHelper.createBusinessInfoForDealer();
         genesis__Business_Information__c borrowerBusinessInfoObj = FICOCalloutTestHelper.createBusinessInfoForBorrower();
         Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj, borrowerBusinessInfoObj}, true);
 
        // Creating dealer, CL, Borrower, Coapplicant Account
        Account dealerAccountObj = FICOCalloutTestHelper.createDealerAccount(dealerBusinessInfoObj.id);      
        Account clAccountObj = FICOCalloutTestHelper.createCLAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Account borrowerAccountObj = FICOCalloutTestHelper.createSolePropAccount(solePropLegalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        borrowerAccountObj.BillingStreet = '12th Road';
        borrowerAccountObj.CIF_Number__c = '123456';
        borrowerAccountObj.SBSS70_Score__c='250';
        borrowerAccountObj.Score_1__c='800';
        Database.insert(new List<Account>{dealerAccountObj, clAccountObj, borrowerAccountObj},true);

        // Creating CL, Borrower, Coapplicant Contact
        Contact clContactObj = FICOCalloutTestHelper.createCLContact(clAccountObj.id);
        Contact borrowerContactObj = FICOCalloutTestHelper.createBorrowerContact(borrowerAccountObj.id);
        borrowerContactObj.genesis__SSN__c = '324242424';
        borrowerContactObj.Confirm_SSN__c = '324242424';
        Database.insert(new List<Contact>{clContactObj, borrowerContactObj},true);

        // Creating CL User
        User clUser = FICOCalloutTestHelper.createCLUser(clContactObj.Id);
        Database.insert(clUser, true);

        // Creating Application
        Map<String,Id> applicationDataMap = new Map<String,Id>{
            'dealerAccountObjId' => dealerAccountObj.Id,
            'clProductObjId' => clProductObj.Id,
            'clPurposeObjId' => clPurposeObj.Id,
            'borrowerAccountObjId' => borrowerAccountObj.Id,
            'borrowerContactObjId' => borrowerContactObj.Id,
            'saAccountObjId' => null
        };
        genesis__Applications__c applicationObj = FICOCalloutTestHelper.createApplication(applicationDataMap);
        applicationObj.genesis__Product_Type__c ='Package';
        applicationObj.genesis__Loan_Amount__c = 1000;
        Database.insert(applicationObj,true); 

        // Creating Borrower Party
        Map<String,Id> partyParamMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(partyParamMap);
        partyObj.clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;
        Database.insert(partyObj,true);
    }
    /**
    * @description call the queuable method
    * @author Soumik Pattanayak | 02-11-2024 
    **/
    @IsTest
    private static void testFICOCreditRatingFromFlowSuccess(){
        User clUser = FICOCalloutTestHelper.getCLUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 1000];
        List<String> idList = new List<String>();
        idList.add(applicationObj.Id);
        Test.startTest();
        System.runAs(clUser){
            FICOCreditRatingfromFlow.callTheQueueableCreditRating(idList);
        }
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM clcommon__Log__c WHERE Name =: ConstantValues.CREDIT_RATING_EXCEPTION].size(), PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description score application from backend
    * @author Soumik Pattanayak | 02-11-2024 
    **/
    @IsTest
    private static void testFICOCreditRatingSuccess(){
        User clUser = FICOCalloutTestHelper.getCLUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 1000];
        Test.startTest();
        System.runAs(clUser){
            FICOCreditRating.scoreTheApplication((String)applicationObj.id);
        }
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM clcommon__Log__c WHERE Name =: ConstantValues.CREDIT_RATING_EXCEPTION].size(), PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description score application from ficoCreditRatingMatrix exception
    * @author Soumik Pattanayak | 02-11-2024 
    **/
    @IsTest
    private static void testFICOCreditRatingException(){
        User clUser = FICOCalloutTestHelper.getCLUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 1000];
        Account borrowerAccountObj=[SELECT Id,
                                           Score_1__c 
                                    FROM Account 
                                    WHERE CIF_Number__c = '123456'];
        borrowerAccountObj.Score_1__c='abc';
        Database.update(borrowerAccountObj,true);
        Test.startTest();
        System.runAs(clUser){
            FICOCreditRating.scoreTheApplication((String)applicationObj.id);
        }
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM clcommon__Log__c WHERE Name =: ConstantValues.CREDIT_RATING_EXCEPTION].size(), PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description score application from backend exception
    * @author Soumik Pattanayak | 02-11-2024 
    **/
    @IsTest
    private static void testFICOCreditRatingMatrixException(){
        User clUser = FICOCalloutTestHelper.getCLUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 1000];
        applicationObj.FICO_Score__c='abc';
        Database.update(applicationObj,true);
        Test.startTest();
        System.runAs(clUser){
            FICOCreditRating.ficoCreditRatingMatrix((String)applicationObj.id);
        }
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM clcommon__Log__c WHERE Name =: ConstantValues.CREDIT_RATING_EXCEPTION].size(), PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description no application
    * @author Soumik Pattanayak | 02-11-2024 
    **/
    @IsTest
    private static void testFICOCreditRatingFail(){
        User clUser = FICOCalloutTestHelper.getCLUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 1000];
        Database.delete(applicationObj);
        Test.startTest();
        System.runAs(clUser){
            FICOCreditRating.scoreTheApplication((String)applicationObj.id);
        }
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM clcommon__Log__c WHERE Name =: ConstantValues.CREDIT_RATING_EXCEPTION].size(), PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description score application from ficoCreditRatingMatrix
    * @author Soumik Pattanayak | 02-11-2024 
    **/
    @IsTest
    private static void testFICOCreditRatingMatrixSuccess(){
        User clUser = FICOCalloutTestHelper.getCLUser('Ross Geller');

        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 1000];
        applicationObj.FICO_Score__c='740';
        applicationObj.SBSS_70_Score__c='200';
        //applicationObj.Net_Worth__c='5000';
        Database.update(applicationObj,true);
        Test.startTest();
        System.runAs(clUser){
            FICOCreditRating.ficoCreditRatingMatrix((String)applicationObj.id);
        }
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM clcommon__Log__c WHERE Name =: ConstantValues.CREDIT_RATING_EXCEPTION].size(), PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description no application 
    * @author Soumik Pattanayak | 02-11-2024 
    **/
    @IsTest
    private static void testFICOCreditRatingMatrixFail(){
        User clUser = FICOCalloutTestHelper.getCLUser('Ross Geller');

        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 1000];
        Database.delete(applicationObj);
        Test.startTest();
        System.runAs(clUser){
            FICOCreditRating.ficoCreditRatingMatrix((String)applicationObj.id);
        }
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM clcommon__Log__c WHERE Name =: ConstantValues.CREDIT_RATING_EXCEPTION].size(), PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description active application 
    * @author Soumik Pattanayak | 02-11-2024 
    **/
    @IsTest
    private static void testFICOCreditRatingMatrixActiveApplication(){
        User clUser = FICOCalloutTestHelper.getCLUser('Ross Geller');

        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 1000];
        applicationObj.genesis__Status__c=ConstantValues.ACTIVE;
        Database.update(applicationObj);
        Test.startTest();
        System.runAs(clUser){
            FICOCreditRating.ficoCreditRatingMatrix((String)applicationObj.id);
        }
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM clcommon__Log__c WHERE Name =: ConstantValues.CREDIT_RATING_EXCEPTION].size(), PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description tier 1 application 
    * @author Soumik Pattanayak | 02-11-2024 
    **/
    @IsTest
    private static void testFICOCreditRatingSuccessTierOne(){
        User clUser = FICOCalloutTestHelper.getCLUser('Ross Geller');

        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 1000];
        applicationObj.FICO_Score__c='740';
        applicationObj.SBSS_70_Score__c='200';
        applicationObj.Net_Worth__c='5000';
        Database.update(applicationObj,true);
        Test.startTest();
        System.runAs(clUser){
            FICOCreditRating.ficoCreditRatingMatrix((String)applicationObj.id);
        }
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM clcommon__Log__c WHERE Name =: ConstantValues.CREDIT_RATING_EXCEPTION].size(), PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description tier 2 application 
    * @author Soumik Pattanayak | 02-11-2024 
    **/
    @IsTest
    private static void testFICOCreditRatingSuccessTierTwo(){
        User clUser = FICOCalloutTestHelper.getCLUser('Ross Geller');

        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 1000];
        applicationObj.FICO_Score__c='670';
        applicationObj.SBSS_70_Score__c='160';
        applicationObj.Net_Worth__c='5000';
        Database.update(applicationObj,true);
        Test.startTest();
        System.runAs(clUser){
            FICOCreditRating.ficoCreditRatingMatrix((String)applicationObj.id);
        }
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM clcommon__Log__c WHERE Name =: ConstantValues.CREDIT_RATING_EXCEPTION].size(), PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description tier 3 application 
    * @author Soumik Pattanayak | 02-11-2024 
    **/
    @IsTest
    private static void testFICOCreditRatingSuccessTierThree(){
        User clUser = FICOCalloutTestHelper.getCLUser('Ross Geller');

        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 1000];
        applicationObj.FICO_Score__c='600';
        applicationObj.SBSS_70_Score__c='150';
        applicationObj.Net_Worth__c='5000';
        Database.update(applicationObj,true);
        Test.startTest();
        System.runAs(clUser){
            FICOCreditRating.ficoCreditRatingMatrix((String)applicationObj.id);
        }
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM clcommon__Log__c WHERE Name =: ConstantValues.CREDIT_RATING_EXCEPTION].size(), PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description tier 4 application 
    * @author Soumik Pattanayak | 02-11-2024 
    **/
    @IsTest
    private static void testFICOCreditRatingSuccessTierFour(){
        User clUser = FICOCalloutTestHelper.getCLUser('Ross Geller');

        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 1000];
        applicationObj.FICO_Score__c='500';
        applicationObj.SBSS_70_Score__c='140';
        applicationObj.Net_Worth__c='5000';
        Database.update(applicationObj,true);
        Test.startTest();
        System.runAs(clUser){
            FICOCreditRating.ficoCreditRatingMatrix((String)applicationObj.id);
        }
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM clcommon__Log__c WHERE Name =: ConstantValues.CREDIT_RATING_EXCEPTION].size(), PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description is evrgreen application
    * @author Soumik Pattanayak | 02-11-2024 
    **/
    @IsTest
    private static void testFICOCreditRatingSuccessIsEvergreen(){
        User clUser = FICOCalloutTestHelper.getCLUser('Ross Geller');

        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 1000];
        applicationObj.Is_Evergreen__c=true;
        List<genesis__Credit_Rating_Matrix__c> objCreditRatingTiersLists = [SELECT  Id, 
                                                                                    Name 
                                                                            FROM genesis__Credit_Rating_Matrix__c 
                                                                            ORDER BY Name ASC
                                                                            LIMIT 4];
        Map<String, Id> creditRatingMap = new Map<String ,Id>();
        for(genesis__Credit_Rating_Matrix__c objTier : objCreditRatingTiersLists){
            creditRatingMap.put(objTier.Name,objTier.Id);
        }
        applicationObj.genesis__Credit_Rating__c=creditRatingMap.get(ConstantValues.CREDIT_RATE_3);
        Database.update(applicationObj,true);
        Test.startTest();
        System.runAs(clUser){
            FICOCreditRating.ficoCreditRatingMatrix((String)applicationObj.id);
        }
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM clcommon__Log__c WHERE Name =: ConstantValues.CREDIT_RATING_EXCEPTION].size(), PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description Application Id missing
    * @author Soumik Pattanayak | 02-11-2024 
    **/
    @IsTest
    private static void testFICOFromFlowAppIdMissing(){
        User clUser = FICOCalloutTestHelper.getCLUser('Ross Geller');
        List<String> idList = new List<String>();
        Test.startTest();
        System.runAs(clUser){
            FICOCreditRatingfromFlow.callTheQueueableCreditRating(idList);
        }
        Test.stopTest();
        List<clcommon__Log__c> logList = [SELECT Id,
                                                Name 
                                            FROM clcommon__Log__c 
                                            WHERE Name =: ConstantValues.CREDIT_RATING_EXCEPTION 
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];
        System.assertEquals(ConstantValues.CREDIT_RATING_EXCEPTION, logList[0].Name, PortalConstants.ASSERTION_FAILED);
    }
}