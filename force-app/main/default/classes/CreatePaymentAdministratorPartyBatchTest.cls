/**
 * @description       : Batch class to create the Payment Administrator parties for all the applications
 * @author            : Ayan Bhowmik
 * @since             : 11-08-2023
 * @last modified on  : 13-01-2025
 * @last modified by  : Soumik Pattanayak
 */
@IsTest
public with sharing class CreatePaymentAdministratorPartyBatchTest {
    @TestSetup
    static void makeData(){
        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.Coop_Type__c = 'Growmark';
        Database.insert(dealerAccountObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj,true);

        // Creating User for Certified Lender
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        Database.insert(clUserObj, true);

        // Creating Account for Payment Administrator
        Account paAccountObj = ApplicationOriginationTestHelper.createPaymentAdministratorAccount(dealerBusinessInfoObj.Id, 
                                                                                                        dealerAccountObj.Id);
        Database.insert(paAccountObj, true);

        // Creating Contact for Payment Administrator
        Contact paContactObj = ApplicationOriginationTestHelper.createPaymentAdministratorContact(paAccountObj.Id);
        Database.insert(paContactObj, true);

        // Creating User for Payment Administrator
        User paUserObj = ApplicationOriginationTestHelper.createPaymentAdministratorUser(paContactObj.Id);
        Database.insert(paUserObj, true);

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);

        // Creating Account for Borrower
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, ApplicationOriginationTestHelper.createBusinessInfoForBorrower().Id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.insert(borrowerAccountObj, true);

        // Creating Contact for Borrower
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(borrowerContactObj,true);

        // Creating User for Borrower
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(borrowerUserObj, true);

        // creating dealer applicant relationship
        Dealer_Applicant_Relationship__c relationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj, dealerAccountObj.Id);
        Database.insert(relationObj, true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating map for Application
        Map<String, Id> paramForApplicationMap = new Map<String, Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'clAccountId' => clAccountObj.Id,
            'dealerApplicantRelationshipId' => relationObj.Id
        };

        // Creating Application
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        Database.insert(applicationObj, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(clRoleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        // Creating Payment Administrator Reciprocal Role
        clcommon__Reciprocal_Role__c paRoleObj = ApplicationOriginationTestHelper.createPaymentAdministratorRole();
        Database.insert(paRoleObj);

        // Creating Relationship betweem Dealer and Payment Administrator
        clcommon__Relationship__c paDelaerRelationshipObj = ApplicationOriginationTestHelper.createPADealerRelationship(paRoleObj, dealerAccountObj.Id, paAccountObj.Id);
        Database.insert(paDelaerRelationshipObj, true);

        // Creating Certified Lender Party Type
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(clPartyTypeObj, true);

        // Creating Certified Lender Party
        Map<String, Id> paramForCLPartyMap = new Map<String, Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(paramForCLPartyMap);
        Database.insert(clPartyObj, true);

        // Create Borrower Party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(borrowerPartyTypeObj, true);

        // Creating Borrower Party
        Map<String, Id> paramForBorrowerPartyMap = new Map<String, Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id,
            'dealerApplicantRelationshipId' => relationObj.Id
        };
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(paramForBorrowerPartyMap);
        Database.insert(borrowerPartyObj);
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 13-01-2025 
    * @param applicationObj 
    **/
    private static void createPaymentAdministrator(genesis__Applications__c applicationObj){
        // Creating Account for Payment Administrator
        Account paAccountObj = ApplicationOriginationTestHelper.createPaymentAdministratorAccount(applicationObj.Dealer_Name__r.genesis__Business_Information__c, 
                                                                                                        applicationObj.Dealer_Name__c);
        paAccountObj.Name = 'Alexa Warner';
        paAccountObj.Phone = '9876543212';
        paAccountObj.CIF_Number__c = '779911';
        paAccountObj.clcommon__Email__c = 'alexa.warner@yopmail.com';
        Database.insert(paAccountObj, true);

        // Creating Contact for Payment Administrator
        Contact paContactObj = ApplicationOriginationTestHelper.createPaymentAdministratorContact(paAccountObj.Id);
        paContactObj.LastName='Warner';
        paContactObj.genesis__SSN__c='999444313';
        paContactObj.Confirm_SSN__c='999444313';
        paContactObj.Email='alexa.warner@yopmail.com';
        paContactObj.Phone='9876543212';
        Database.insert(paContactObj, true);

        // Creating User for Payment Administrator
        User paUserObj = ApplicationOriginationTestHelper.createPaymentAdministratorUser(paContactObj.Id);
        paUserObj.UserName='alexa.warner234@yopmail.com';
        Database.insert(paUserObj, true);

        // Creating Payment Administrator Reciprocal Role
        clcommon__Reciprocal_Role__c paRoleObj = ApplicationOriginationTestHelper.createPaymentAdministratorRole();
        Database.insert(paRoleObj);

        // Creating Relationship betweem Dealer and Payment Administrator
        clcommon__Relationship__c paDelaerRelationshipObj = ApplicationOriginationTestHelper.createPADealerRelationship(paRoleObj, applicationObj.Dealer_Name__c, paAccountObj.Id);
        Database.insert(paDelaerRelationshipObj, true);

        // Creating Payment Administrator Party Type
        clcommon__Party_Type__c paPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PAYMENT ADMINISTRATOR');
        Database.insert(paPartyTypeObj, true);

        // Creating Certified Lender Party
        Map<String,Id> paramForPAPartyMap = new Map<String,Id>();
        paramForPAPartyMap.put('accountId', paAccountObj.Id);
        paramForPAPartyMap.put('contactId', paContactObj.Id);
        paramForPAPartyMap.put('partyTypeId', paPartyTypeObj.Id);
        paramForPAPartyMap.put('applicationId', applicationObj.Id);
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(paramForPAPartyMap);
        Database.insert(clPartyObj, true);
    }

    /**
    * @description test for success
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @IsTest
    public static void testCaseSucces() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){
            List<genesis__Applications__c> applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c
                                                        WHERE genesis__Status__c = 'ACTIVE'];

            Test.startTest();
            CreatePaymentAdministratorPartyBatch paPartyBatch = new CreatePaymentAdministratorPartyBatch();
            Database.executeBatch(paPartyBatch, 20);
            Test.stopTest();
            List<clcommon__Party__c> partyObj = [SELECT Id
                                                    FROM clcommon__Party__c 
                                                    WHERE genesis__Application__c = :applicationObj[0].Id 
                                                    AND clcommon__Account__r.RecordType.Name = 'Payment Administrator'];
            System.assertEquals(1, partyObj.size(), 'Failure');
        }
    }
    /**
    * @description test for createPaPartyForSpecificDealer
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @IsTest
    public static void testCaseSuccesInvocableMethod() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){
            genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c
                                                        WHERE genesis__Status__c = 'ACTIVE'
                                                        LIMIT 1];
            List<Id> paAccountIdList = new List<Id>();
            Account paAccountObj = [SELECT Id 
                                        FROM Account 
                                        WHERE RecordType.Name = 'Payment Administrator'];
            paAccountIdList.add(paAccountObj.Id);
            Test.startTest();
            CreatePaymentAdministratorPartyBatch.createPaPartyForSpecificDealer(paAccountIdList);
            Test.stopTest();
            List<clcommon__Party__c> partyObj = [SELECT Id
                                                    FROM clcommon__Party__c 
                                                    WHERE genesis__Application__c = :applicationObj.Id 
                                                    AND clcommon__Account__r.RecordType.Name = 'Payment Administrator'];
            System.assertEquals(1, partyObj.size(), 'Failure');
        }
    }

    /**
    * @description test for existing payment admin
    * @author Soumik Pattanayak | 05-01-2025 
    **/
    @isTest
    public static void testForExistingPA(){
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            Dealer_Name__c, 
                                                            Dealer_Name__r.genesis__Business_Information__c
                                                        FROM genesis__Applications__c
                                                        WHERE genesis__Status__c = 'ACTIVE'
                                                        LIMIT 1];

        createPaymentAdministrator(applicationObj);

        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            CreatePaymentAdministratorPartyBatch paPartyBatch = new CreatePaymentAdministratorPartyBatch();
            Database.executeBatch(paPartyBatch, 20);
            Test.stopTest();
        }
        List<clcommon__Party__c> partyObj = [SELECT Id, name , clcommon__Account__r.name
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c = :applicationObj.Id 
                                                AND clcommon__Account__r.RecordType.Name = 'Payment Administrator'];

        System.assertEquals(2, partyObj.size(), 'Failure');
    }
}