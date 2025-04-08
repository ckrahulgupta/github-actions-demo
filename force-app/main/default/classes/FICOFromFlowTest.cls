/**
 * @description       : Test Class for FICO Flow
 * @author            : Ayan Bhowmik
 * @group             : 
 * @last modified on  : 08-12-2024
 * @last modified by  :  Pritam Roy
**/
@IsTest
private without sharing class FICOFromFlowTest {
    /**
    * @description : Test Setup
    * @author  Pritam Roy | 08-12-2024 
    **/
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
        applicationObj.genesis__Loan_Amount__c = 824001;
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
    * @description : FICO Flow Success
    * @author  Pritam Roy | 08-12-2024 
    **/
    @IsTest
    private static void testFICOFromFlowSuccess(){
        User clUser = FICOCalloutTestHelper.getCLUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                    FROM genesis__Applications__c 
                                                    WHERE genesis__Loan_Amount__c = 824001];
        List<String> idList = new List<String>();
        idList.add(applicationObj.Id);
        Test.startTest();
        System.runAs(clUser){
            FICOFromFlow.callTheQueueableFICO(idList);
        }
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM clcommon__Log__c WHERE Name =: ConstantValues.FICOFROM_FLOW_ERROR].size(), PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description : App Id Missing
    * @author  Pritam Roy | 08-12-2024 
    **/
    @IsTest
    private static void testFICOFromFlowAppIdMissing(){
        User clUser = FICOCalloutTestHelper.getCLUser('Ross Geller');
        List<String> idList = new List<String>();
        Test.startTest();
        System.runAs(clUser){
            FICOFromFlow.callTheQueueableFICO(idList);
        }
        Test.stopTest();
        List<clcommon__Log__c> logList = [SELECT Id,
                                                Name 
                                            FROM clcommon__Log__c 
                                            WHERE Name =: ConstantValues.FICOFROM_FLOW_ERROR 
                                            ORDER BY CreatedDate DESC 
                                            LIMIT 1];
        System.assertEquals(ConstantValues.FICOFROM_FLOW_ERROR, logList[0].Name, PortalConstants.ASSERTION_FAILED);
    }
}