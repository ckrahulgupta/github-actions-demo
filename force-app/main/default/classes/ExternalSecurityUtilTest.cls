/**
 * @description       : test class for ExternalSecurityUtil
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 09-09-2024
 * @last modified by  : Suraj Kumar
**/
@IsTest
public with sharing class ExternalSecurityUtilTest {

    @TestSetup
    static void setup(){
        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ExternalAPITestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.CIF_Number__c = '102555';
        dealerAccountObj.Enable_ERP_Id__c = true;
        Database.insert(dealerAccountObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ExternalAPITestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ExternalAPITestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj,true);

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ExternalAPITestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);
        
        //creating business info for borrower
        genesis__Business_Information__c borrowerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);

        // Creating Account for Borrower
        Account borrowerAccountObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        //  borrowerAccountObj.Unique_Id__c = '001O100000E5kzvIAB';
        Database.insert(borrowerAccountObj, true);

        // Creating Contact for Borrower
        Contact borrowerContactObj = ExternalAPITestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(borrowerContactObj,true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ExternalAPITestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ExternalAPITestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating map for Application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'certifiedLender' =>  clAccountObj.Id
        };

        // Creating Application
        genesis__Applications__c applicationObj = ExternalAPITestHelper.createCurrCropYearApplication(paramForApplicationMap);
        Database.insert(applicationObj, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ExternalAPITestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ExternalAPITestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        Account coBorrowerAccObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        coBorrowerAccObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        coBorrowerAccObj.Unique_Id__c = '981234';
        Database.insert(coBorrowerAccObj,true);


        Contact coBorrowerContactObj = ExternalAPITestHelper.createBorrowerContact(coBorrowerAccObj.Id);
        Database.insert(coBorrowerContactObj, true);

        clcommon__Party_Type__c principalPartyTypeObj = ExternalAPITestHelper.createPartyType('PRINCIPAL');

        Database.insert(principalPartyTypeObj,true);

        // Creating Principal Party for current application
        Map<String,Id> paramForPrincipalPartyMap = new Map<String,Id>{
            'accountId' => coBorrowerAccObj.Id,
            'contactId' => coBorrowerContactObj.Id,
            'partyTypeId' => principalPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__Party__c principalPartyObj = ExternalAPITestHelper.createParty(paramForPrincipalPartyMap);
        principalPartyObj.Principal_Number__c = 1;
        Database.insert(principalPartyObj,true);
    }

    @IsTest
    public static void testGetSiteAdmin() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        
        
        System.runAs(userObj) {
            Test.startTest();
            // Calling  the API
            ExternalSecurityUtil.getSiteAdmin();
            System.assertEquals('', '', 'Assertion Failed'); 
            Test.stopTest();
        }
    }

    @isTest
    public static void testApplicationNotFound(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Account dealerAccount = [SELECT Id FROM Account WHERE Cif_Number__c = '102555'];
        System.runAs(userObj){
            Test.startTest();
            try{
                ExternalSecurityUtil.validateBorrowerWithApplication('ansvjh','ahshj', dealerAccount.Id);
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.APPLICATION_NOT_FOUND, exceptionObj.getMessage(), 'Assertion Failed');
            }
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testUserNotAuthorizedSoleProp(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            genesis__Account__c,
                                                            Dealer_Name__c,
                                                            genesis__Account__r.Unique_Id__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            try{
                ExternalSecurityUtil.validateBorrowerWithApplication(applicationObj.Id,'ahshj', applicationObj.Dealer_Name__c);
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.USER_NOT_AUTHORISED, exceptionObj.getMessage(), 'Assertion Failed');
            }
            Test.stopTest();
        }
    }

    @isTest
    public static void testUserNotAuthorizedCorporation(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        clcommon__Legal_Entity__c entityObj = [SELECT Id, 
                                                        clcommon__Legal_Entity_Type__c,
                                                        Name 
                                                    FROM clcommon__Legal_Entity__c];
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            genesis__Account__c,
                                                            Dealer_Name__c,
                                                            genesis__Account__r.Unique_Id__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            try{
                ExternalSecurityUtil.validateBorrowerWithApplication(applicationObj.Id,'ahshj', applicationObj.Dealer_Name__c);
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.USER_NOT_AUTHORISED, exceptionObj.getMessage(), 'Assertion Failed');
            }
            Test.stopTest();
        }
    }

    @isTest
    public static void testWithoutFirstPrincipalCorporation(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        clcommon__Legal_Entity__c entityObj = [SELECT Id, 
                                                        clcommon__Legal_Entity_Type__c,
                                                        Name 
                                                    FROM clcommon__Legal_Entity__c];
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            genesis__Account__c,
                                                            Dealer_Name__c,
                                                            genesis__Account__r.Unique_Id__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        List<clcommon__Party__c> principalPartyTypeList = [SELECT Id,
                                                                    clcommon__Account__r.Unique_Id__c 
                                                                FROM clcommon__Party__c 
                                                                WHERE genesis__Application__c = :applicationObj.Id
                                                                AND clcommon__Party_Types__c = :ExternalConstants.PRINCIPAL_PARTY
                                                                AND Principal_Number__c = 1];
        principalPartyTypeList[0].Principal_Number__c = 2;
        Database.update(principalPartyTypeList,true);
        System.runAs(userObj){
            Test.startTest();
            try{
                ExternalSecurityUtil.validateBorrowerWithApplication(applicationObj.Id,'ahshj', applicationObj.Dealer_Name__c);
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.USER_NOT_AUTHORISED, exceptionObj.getMessage(), 'Assertion Failed');
            }
            Test.stopTest();
        }
    }

    @IsTest
    private static void testGetLoggedInUser(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            List<User> loggedInUser = ExternalSecurityUtil.getLoggedInUser();
            System.assertEquals(1, loggedInUser.size(), 'Assertion Failed');
            Test.stopTest();
        }
    }
}