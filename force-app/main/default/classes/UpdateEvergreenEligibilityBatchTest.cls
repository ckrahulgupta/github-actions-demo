/**
 * @description       : Test Class for UpdateEvergreenEligibilityBatch
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 01-10-2025
 * @last modified by  : Rakesh Saraf
**/

@isTest
public with sharing class UpdateEvergreenEligibilityBatchTest {
    @TestSetup
    static void makeData(){
        // Object List declarations
        List<clcommon__Party_Type__c> partyTypeList;
        List<Account> accountList;
        List<Contact> contactList;
        List<genesis__Business_Information__c> businsessInfoList;
        List<clcommon__party__c> partyList;
        List<clcommon__Legal_Entity__c> entityObjList;

        // Creating Legal Entity
        clcommon__Legal_Entity__c individualEntityObj = LoanServicingTestHelper.createLegalEntity(PortalConstants.SOLE_PROP_ENTITY);

        clcommon__Legal_Entity__c corpEntityObj = LoanServicingTestHelper.createLegalEntity(PortalConstants.CORPORATION);

        clcommon__Legal_Entity__c dbaEntityObj = LoanServicingTestHelper.createLegalEntity(PortalConstants.INDIVIDUAL_ENTITY);

        entityObjList = new  List<clcommon__Legal_Entity__c>{
            individualEntityObj,
            corpEntityObj,
            dbaEntityObj
        };
        Database.insert(entityObjList);
        // Creating Party Types
        clcommon__Party_Type__c borrowerPartyTypeObj = LoanServicingTestHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);

        clcommon__Party_Type__c dealerPartyTypeObj = LoanServicingTestHelper.createPartyType(PortalConstants.DEALER_PARTY_NAME);

        partyTypeList = new List<clcommon__Party_Type__c>{
            borrowerPartyTypeObj,
            dealerPartyTypeObj
        };
        Database.Insert(partyTypeList, true);

        // Creating CL Product for Application
        clcommon__CL_Product__c clProductObj = LoanServicingTestHelper.createCLProductForApplication();
        Database.Insert(clProductObj, true);

        // Creating CL Purpose for Application
        clcommon__CL_Purpose__c clPurposeObj = LoanServicingTestHelper.createCLPurposeForApplication();
        Database.Insert(clPurposeObj, true);

        // Creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForDealer();

        genesis__Business_Information__c borrowerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForBorrower();

        businsessInfoList = new List<genesis__Business_Information__c>{
            dealerBusinessInfoObj,
            borrowerBusinessInfoObj
        };
        Database.Insert(businsessInfoList, true);

        // Creating Accounts
        Account dealerAccountObj = LoanServicingTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.Insert(dealerAccountObj, true);

        Account borrowerAccountObj = LoanServicingTestHelper.createSolePropAccount(individualEntityObj, borrowerBusinessInfoObj.Id);

        accountList = new List<Account>{
            borrowerAccountObj
        };
        Database.Insert(accountList, true);

        // Creating Contact

        Contact borrowerContactObj = LoanServicingTestHelper.createBorrowerContact(borrowerAccountObj.Id);    

        contactList = new List<Contact>{
            borrowerContactObj
        };
        Database.Insert(contactList, true);

        //creating dealer_applicant_relationship__c
        dealer_applicant_relationship__c relationObj = LoanServicingTestHelper.createDealerApplicantRelationship(borrowerContactObj, dealerAccountObj.Id);
        Database.Insert(relationObj, true);

        // Creating Application
        Map<String,Id> applicationDataMap = new Map<String,Id>{
            'dealerAccountId'=> dealerAccountObj.Id,
            'clProductId'=> clProductObj.Id,
            'clPurposeId'=> clPurposeObj.Id,
            'borrowerAccountId'=> borrowerAccountObj.Id,
            'borrowerContactId'=> borrowerContactObj.Id,
            'dealerApplicantRelationshipId' => relationObj.Id
            //'clAccountId'=> clAccountObj.Id
        };
        genesis__Applications__c applicationObj = LoanServicingTestHelper.createPrevCropYearApplication(applicationDataMap);
        Database.Insert(applicationObj,true);

        //Creating Parties

            // Creating Dealer Party
            Map<String,Id> dealerPartyMapData = new Map<String,Id>{
                'accountId'=> dealerAccountObj.Id,
                'partyTypeId'=> dealerPartyTypeObj.Id,
                'applicationId'=> applicationObj.Id
            };
            clcommon__Party__c dealerPartyObj = LoanServicingTestHelper.createParty(dealerPartyMapData);

            // Creating Borrower Party
            Map<String,Id> borrowerPartyMapData = new Map<String,Id>{
                'accountId'=> borrowerAccountObj.Id,
                'contactId'=> borrowerContactObj.Id,
                'partyTypeId'=> borrowerPartyTypeObj.Id,
                'applicationId'=> applicationObj.Id,
                'dealerApplicantRelationshipId' => relationObj.Id
            };
            clcommon__Party__c borrowerPartyObj = LoanServicingTestHelper.createParty(borrowerPartyMapData);

            partyList = new List<clcommon__Party__c>{
                dealerPartyObj,
                borrowerPartyObj
            };
            Database.Insert(partyList, true);
            List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList = ApplicationOriginationTestHelper.createCreditRatingMatrix();
            Database.insert(creditRatingMatrixList,true);
    }

    /**
    * @description method used to get the credit rating matrix
    * @author Rakesh Saraf | 01-10-2025 
    * @return List<genesis__Credit_Rating_Matrix__c> 
    **/
    private static List<genesis__Credit_Rating_Matrix__c> getCreditRatingMatrixList(){
        return [SELECT  Id, 
                        Name 
                FROM genesis__Credit_Rating_Matrix__c 
                WHERE Name =: 'Tier 1'];
    } 

    /**
    * @description method to return the application
    * @author Rakesh Saraf | 01-10-2025 
    * @return List<genesis__Applications__c> 
    **/
    private static genesis__Applications__c getApplication(){
        return [SELECT Id,
                        Non_Accrual__c,
                        genesis__Credit_Rating__c,   
                        genesis__Credit_Rating__r.name,
                        Dealer_Applicant_Relationship__c,
                        Is_Evergreen_Eligible__c,
                        Is_Evergreen__c
                FROM genesis__Applications__c
                WHERE genesis__Loan_Number__c = '300023457'
                LIMIT 1][0];
    }

    /**
    * @description - set a grower as eligible
    * @author Sk Minsar | 05-15-2024 
    **/
    @isTest
    private static void testEESetEligibleApps(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();

        List<genesis__Credit_Rating_Matrix__c> creditRatingTiersList = getCreditRatingMatrixList();

        genesis__Applications__c appObj = getApplication();

        appObj.Non_Accrual__c = false;
        appObj.genesis__Credit_Rating__c = creditRatingTiersList[0].id;
        appObj.Is_Evergreen_Eligible__c = true;
        appObj.Is_Evergreen__c = false;
        appObj.Crop_Year__c = String.valueOf(System.today().year());
        Database.update(appObj, true);
        
        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                UpdateEvergreenEligibilityBatch batchObj = new UpdateEvergreenEligibilityBatch(true, appObj.Dealer_Applicant_Relationship__c);
                Database.executeBatch(batchObj,1);
                Test.stopTest();
                genesis__Applications__c applicationObj = getApplication();
                System.assertEquals(true, applicationObj.Is_Evergreen_Eligible__c, PortalConstants.ASSERTION_FAILED);
            }
        }
    }

     /**
    * @description - set a grower as eligible whose application is in created two years back
    * @author Sk Minsar | 05-15-2024 
    **/
    @isTest
    private static void testEESetEligibleForTwoYearsBackApps(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();

        List<genesis__Credit_Rating_Matrix__c> creditRatingTiersList = getCreditRatingMatrixList();

        genesis__Applications__c appObj = getApplication();

        appObj.Non_Accrual__c = false;
        appObj.genesis__Credit_Rating__c = creditRatingTiersList[0].id;
        appObj.Is_Evergreen_Eligible__c = false;
        appObj.Is_Evergreen__c = false;
        appObj.Crop_Year__c = String.valueOf(System.today().year() - 2);
        Database.update(appObj, true);
        
        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                UpdateEvergreenEligibilityBatch batchObj = new UpdateEvergreenEligibilityBatch(true, appObj.Dealer_Applicant_Relationship__c);
                Database.executeBatch(batchObj,1);
                Test.stopTest();
                genesis__Applications__c applicationObj = getApplication();
                System.assertEquals(true, applicationObj.Is_Evergreen_Eligible__c, PortalConstants.ASSERTION_FAILED);
            }
        }
    }

     /**
    * @description - set a grower as eligible whose application is in created past crop year 
    * @author Sk Minsar | 05-15-2024 
    **/
    @isTest
    private static void testEESetEligibleForPriorCropYearApps(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();

        List<genesis__Credit_Rating_Matrix__c> creditRatingTiersList = getCreditRatingMatrixList();

        genesis__Applications__c appObj = getApplication();

        appObj.Non_Accrual__c = false;
        appObj.genesis__Credit_Rating__c = creditRatingTiersList[0].id;
        appObj.Is_Evergreen_Eligible__c = true;
        appObj.Is_Evergreen__c = false;
        appObj.Crop_Year__c = String.valueOf(System.today().year() - 1);
        Database.update(appObj, true);
        
        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                UpdateEvergreenEligibilityBatch batchObj = new UpdateEvergreenEligibilityBatch(true, appObj.Dealer_Applicant_Relationship__c);
                Database.executeBatch(batchObj,1);
                Test.stopTest();
                genesis__Applications__c applicationObj = getApplication();
                System.assertEquals(true, applicationObj.Is_Evergreen_Eligible__c, PortalConstants.ASSERTION_FAILED);
            }
        }
    }

    /**
    * @description - test with Null Params
    * @author Sk Minsar | 05-16-2024 
    **/
    @isTest
    private static void testWithNullParams(){
        String objExceptionString;
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                try{
                    UpdateEvergreenEligibilityBatch batchObj = new UpdateEvergreenEligibilityBatch(null,null);
                    Database.executeBatch(batchObj,1);
                }catch(Exception objException){
                    objExceptionString = objException.getMessage();
                }
                Test.stopTest();
                System.assertEquals(objExceptionString==null, true, PortalConstants.ASSERTION_FAILED);
            }
        }
    }
    
    /**
    * @description - Set a grower as non eligbile
    * @author Sk Minsar | 05-15-2024 
    **/
    @isTest
    private static void testEESetNonEligibleApps(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();

        genesis__Applications__c appObj = getApplication();

        // appObj.Non_Accrual__c = true;
        appObj.Is_Evergreen_Eligible__c = true;
        appObj.Is_Evergreen__c = true;
        appObj.Crop_Year__c = String.valueOf(System.today().year());
        Database.update(appObj, true);
        
        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                UpdateEvergreenEligibilityBatch batchObj = new UpdateEvergreenEligibilityBatch(false, appObj.Dealer_Applicant_Relationship__c);
                Database.executeBatch(batchObj,1);
                Test.stopTest();
                genesis__Applications__c applicationObj = getApplication();
                System.assertEquals(false, applicationObj.Is_Evergreen_Eligible__c, PortalConstants.ASSERTION_FAILED);
            }
        }
    }

    /**
    * @description - set a grower eligible update their closed app
    * @author Sk Minsar | 05-15-2024 
    **/
    @isTest
    private static void testEESetNonEligibleClosedApps(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();

        genesis__Applications__c appObj = getApplication();

        // appObj.Non_Accrual__c = true;
        appObj.Is_Evergreen_Eligible__c = true;
        appObj.Is_Evergreen__c = true;
        appObj.genesis__Status__c = 'CLOSED';
        appObj.Crop_Year__c = String.valueOf(System.today().year());
        Database.update(appObj, true);
        
        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                UpdateEvergreenEligibilityBatch batchObj = new UpdateEvergreenEligibilityBatch(false, appObj.Dealer_Applicant_Relationship__c);
                Database.executeBatch(batchObj,1);
                Test.stopTest();
                genesis__Applications__c applicationObj = getApplication();
                System.assertEquals(false, applicationObj.Is_Evergreen_Eligible__c, PortalConstants.ASSERTION_FAILED);
            }
        }
    }

     /**
    * @description - set a grower isEvergreen false update their app other than active or closed
    * @author Sk Minsar | 05-15-2024 
    **/
    @isTest
    private static void testEESetIEFalseForNotACApps(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();

        genesis__Applications__c appObj = getApplication();

        appObj.Is_Evergreen_Eligible__c = true;
        appObj.Is_Evergreen__c = true;
        appObj.genesis__Status__c = 'NEW - SCORECARD GENERATED';
        appObj.Crop_Year__c = String.valueOf(System.today().year());
        Database.update(appObj, true);
        
        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                UpdateEvergreenEligibilityBatch batchObj = new UpdateEvergreenEligibilityBatch(false, appObj.Dealer_Applicant_Relationship__c);
                Database.executeBatch(batchObj,1);
                Test.stopTest();
                genesis__Applications__c applicationObj = getApplication();
                System.assertEquals(false, applicationObj.Is_Evergreen__c, PortalConstants.ASSERTION_FAILED);
            }
        }
    }

    /**
    * @description - set a grower isEvergreen true update their app other than active or closed
    * @author Sk Minsar | 05-15-2024 
    **/
    @isTest
    private static void testEESetIETrueForNotACApps(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();

        genesis__Applications__c appObj = getApplication();

        appObj.Is_Evergreen_Eligible__c = false;
        appObj.Is_Evergreen__c = false;
        appObj.genesis__Status__c = 'NEW - SCORECARD GENERATED';
        appObj.Crop_Year__c = String.valueOf(System.today().year());
        Database.update(appObj, true);
        
        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                UpdateEvergreenEligibilityBatch batchObj = new UpdateEvergreenEligibilityBatch(false, appObj.Dealer_Applicant_Relationship__c);
                Database.executeBatch(batchObj,1);
                Test.stopTest();
                genesis__Applications__c applicationObj = getApplication();
                System.assertEquals(false, applicationObj.Is_Evergreen__c, PortalConstants.ASSERTION_FAILED);
            }
        }
    }


    
    /**
    * @description Set the Allow Evergreen Application to True 
    * @author Subham Nandi | 25-07-2024 
    **/
     @isTest
    private static void testAllowEvergreenForSpecificDealer(){
        User userObj = ApplicationOriginationTestHelper.getSystemAdminUser();

        if(userObj!= null){
            System.runAs(userObj){
                List<Id> dealerId = new List<Id>();
                List<Account> accountObj = [SELECT Id FROM Account WHERE RecordType.Name = 'Dealer' LIMIT 1];
                dealerId.add(accountObj[0].Id);
                Test.startTest();
                UpdateEvergreenEligibilityBatch.updateEvegreenForSpecificDealer(dealerId);
                Test.stopTest();
                List<genesis__Applications__c>applicationList = [SELECT Id FROM genesis__Applications__c WHERE Is_Evergreen_Eligible__c = True];
                System.assertEquals(0, applicationList.Size(), PortalConstants.ASSERTION_FAILED);
            }
        }
    }
}