/**
 * @description       : Test class for CFAOriginationHelperClass
 * @author            : Ayan Bhowmik
 * @group             : 
 * @last modified on  : 12-12-2024
 * @last modified by  : Soumik Pattanayak
**/
@IsTest
public inherited sharing class CFAOriginationHelperTest {
    /**
    * @description Method for making test data
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @TestSetup
    static void makeData(){
        // Creating sole-prop, corporation, dba legal entities
        clcommon__Legal_Entity__c solePropLegalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(new List<clcommon__Legal_Entity__c>{solePropLegalEntityObj}, true);

        // Creating cl product
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        // Creating cl purpose
        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj,true);

        // Creating CL, Borrower, Principal, Dealer Party Types
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c principalPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        clcommon__Party_Type__c dealerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('DEALER');
        Database.insert(new List<clcommon__Party_Type__c>{clPartyTypeObj, borrowerPartyTypeObj, principalPartyTypeObj, dealerPartyTypeObj}, true);

        // Creating Dealer, Borrower Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        borrowerBusinessInfoObj.genesis__Tax_Identification_Number__c = '';
        genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        coBorrowerBusinessInfoObj.genesis__Tax_Identification_Number__c = '';
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj, borrowerBusinessInfoObj, coBorrowerBusinessInfoObj}, true);

        // Creating dealer, CL, Borrower, Coapplicant Account
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.id);  
        dealerAccountObj.CIF_Number__c = '114618';
        Account landusDealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.id);
        landusDealerAccountObj.Coop_Type__c = 'Landus';
        Account gmkDealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.id);
        gmkDealerAccountObj.Coop_Type__c = 'Growmark';
        Database.insert(new List<Account>{dealerAccountObj, landusDealerAccountObj, gmkDealerAccountObj},true);

        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Account paAccountObj = ApplicationOriginationTestHelper.createPaymentAdministratorAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Account saAccObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.Id,dealerAccountObj.Id);
        Account saAdminAccObj = ApplicationOriginationTestHelper.createSAAdminAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);                
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(solePropLegalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        borrowerAccountObj.BillingStreet = '12th Road';
        borrowerAccountObj.CIF_Number__c = '123456';
        borrowerAccountObj.BillingPostalCode = '77777';
        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(solePropLegalEntityObj,coBorrowerBusinessInfoObj.id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        Database.insert(new List<Account>{clAccountObj, paAccountObj, saAccObj, saAdminAccObj, borrowerAccountObj, coBorrowerAccountObj},true);
        
        // Creating CL, Borrower, Coapplicant Contact
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
        Contact paContactObj = ApplicationOriginationTestHelper.createPaymentAdministratorContact(paAccountObj.Id);
        Contact saContactObj=ApplicationOriginationTestHelper.createSalesAgentContact(saAccObj.Id);
        Contact saAdminContactObj=ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccObj.Id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        borrowerContactObj.genesis__SSN__c = '324242424';
        borrowerContactObj.Confirm_SSN__c = '324242424';
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        coBorrowerContactObj.genesis__SSN__c = '666714588';
        coBorrowerContactObj.Confirm_SSN__c = '666714588';
        coBorrowerContactObj.ints__Middle_Name__c = 'Kumar';
        Database.insert(new List<Contact>{clContactObj, paContactObj, saContactObj, saAdminContactObj, borrowerContactObj, coBorrowerContactObj},true);

        Dealer_Applicant_Relationship__c borrowerRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c coBorrowerRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(coBorrowerContactObj,dealerAccountObj.Id);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{borrowerRelationObj, coBorrowerRelationObj},true);

        // Creating CL User
        User clUser = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        User paUser = ApplicationOriginationTestHelper.createPaymentAdministratorUser(paContactObj.Id);
        Database.insert(new List<User>{clUser, paUser}, true);

        // Creating Application
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(new Map<String,Id>{'dealerAccountObjId' => dealerAccountObj.id,
                                                                                                                        'clProductObjId' => clProductObj.id,
                                                                                                                        'clPurposeObjId' => clPurposeObj.id,
                                                                                                                        'borrowerAccountObjId' => borrowerAccountObj.id,
                                                                                                                        'borrowerContactObjId' => borrowerContactObj.id,
                                                                                                                        'saAccountObjId' => saAccObj.id,
                                                                                                                        'dealerApplicantRelationshipId' => borrowerRelationObj.id
                                                                                                                    });
        applicationObj.genesis__Product_Type__c ='Package';
        applicationObj.genesis__Loan_Amount__c = 824001;
        Database.insert(applicationObj,true); 

        // Creating Borrower Party
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{'accountId' => borrowerAccountObj.id,
                                                                                                        'contactId' => borrowerContactObj.id,
                                                                                                        'partyTypeId' => borrowerPartyTypeObj.id,
                                                                                                        'applicationId' => applicationObj.id,
                                                                                                        'dealerApplicantRelationshipId' => borrowerRelationObj.id
                                                                                                    });
        partyObj.clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;
        Database.insert(partyObj,true);

        clcommon__Reciprocal_Role__c paRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.PAYMENT_ADMINISTRATOR);
        clcommon__Reciprocal_Role__c rsaRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.RELATED_SALES_AGENT);
        clcommon__Reciprocal_Role__c fsaRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.FIELD_STAFF_AGENT);
        clcommon__Reciprocal_Role__c saRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.SALES_AGENT);
        Database.insert(new List<clcommon__Reciprocal_Role__c>{paRoleObj, rsaRoleObj, fsaRoleObj, saRoleObj}, true);

        clcommon__Relationship__c relationshipObject = ApplicationOriginationTestHelper.createRelWithDealer(rsaRoleObj,saAdminAccObj.Id,saAccObj.Id);
        clcommon__Relationship__c paDealerRelationObj = ApplicationOriginationTestHelper.createPADealerRelationship(paRoleObj, dealerAccountObj.Id, clAccountObj.Id);
        Database.insert(new List<clcommon__Relationship__c>{paDealerRelationObj, relationshipObject}, true);

        AccountShare accountShareObj = ApplicationOriginationTestHelper.createAccountShareRecord(clAccountObj.Id, clUser.Id);
        Database.insert(accountShareObj, true);

        genesis__Application_Pricing_Detail__c pricingDeailsObj = ApplicationOriginationTestHelper.createPricingDetail(applicationObj.Id);
        Database.insert(pricingDeailsObj, true);

        clcommon__Payment_Mode__c paymentModeObj = ApplicationOriginationTestHelper.createPaymentMode('PAYMENT');
        Database.insert(paymentModeObj, true);

        genesis__Funding_Transaction__c fundingTxnObj = ApplicationOriginationTestHelper.createFundingTransaction(paymentModeObj.Id, pricingDeailsObj.Id, applicationObj.Id);
        Database.insert(fundingTxnObj, true);
    
        testSetupContentdocument(applicationObj.id,borrowerAccountObj.Id);
    }

    /**
    * @description : Method to create contet document for test setup
    * @author Suraj Kumar | 10-25-2024 
    * @param applicationId 
    * @param borrowerId 
    **/
    private static void testSetupContentdocument(String applicationId, String borrowerId){
        //creating content version
        ContentVersion contentVerAgreementObj = ApplicationOriginationTestHelper.createContentVersion(PortalConstants.AGREEMENT_FILE_NAME);
        Database.insert(contentVerAgreementObj,true);
 
        // creating content Document
        ContentDocument contentDocAgreementObj = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
 
        // creating ContentDocumentLink
        ContentDocumentLink contentDocLinkAgrmttObj = ApplicationOriginationTestHelper.createContentDocumentLink(contentDocAgreementObj.id,applicationId);
        Database.insert(contentDocLinkAgrmttObj,true);

        clcommon__document_category__c docCategorySigned = ApplicationOriginationTestHelper.createDocCategory(applicationId,PortalConstants.SIGNED_AGREEMENT_TASK);
        Database.insert(docCategorySigned,true); 
    }
    
    /**
    * @description Test method for hasAnySameValueInList with same value
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testSameValueInList() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            Boolean res = CFAOriginationHelperClass.hasAnySameValueInList(new List<Object>{'Test'}, new List<Object>{'Test'});
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for hasAnySameValueInList with no same value
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testNoSameValueInList() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            Boolean res = CFAOriginationHelperClass.hasAnySameValueInList(new List<Object>{'Test'}, new List<Object>{''});
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getHighestPriorityRecordType for CL,AB and GM
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetHighestPriorityRecordTypeForCL() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<RecordType> recordTypeList = [SELECT Id,
                                                    Name
                                                FROM RecordType
                                                WHERE Name IN ('Certified Lender', 'AgriBusiness', 'General Manager')];
        Test.startTest();
        System.runAs(clUser){
            RecordType res = CFAOriginationHelperClass.getHighestPriorityRecordType(recordTypeList);
            System.assertEquals('Certified Lender', res.Name, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getHighestPriorityRecordType for AB and GM
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetHighestPriorityRecordTypeForAB() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<RecordType> recordTypeList = [SELECT Id,
                                                    Name
                                                FROM RecordType
                                                WHERE Name IN ('AgriBusiness', 'General Manager')];
        Test.startTest();
        System.runAs(clUser){
            RecordType res = CFAOriginationHelperClass.getHighestPriorityRecordType(recordTypeList);
            System.assertEquals('AgriBusiness', res.Name, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getHighestPriorityRecordType for GM and AP
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetHighestPriorityRecordTypeForGM() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<RecordType> recordTypeList = [SELECT Id,
                                                    Name
                                                FROM RecordType
                                                WHERE Name IN ('General Manager', 'Authorized Person')
                                                ORDER BY Name];
        Test.startTest();
        System.runAs(clUser){
            RecordType res = CFAOriginationHelperClass.getHighestPriorityRecordType(recordTypeList);
            System.assertEquals('Authorized Person', res.Name, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getRecordTypeNamesList
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetRecordTypeNameList() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<RecordType> recordTypeList = [SELECT Id,
                                                    Name
                                                FROM RecordType
                                                WHERE Name IN ('General Manager', 'Authorized Person')
                                                ORDER BY Name];
        Test.startTest();
        System.runAs(clUser){
            List<String> res = CFAOriginationHelperClass.getRecordTypeNamesList(recordTypeList);
            System.assertEquals('Authorized Person', res[0], PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for valuesNotInList with same value
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetSameValueInList() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            List<Object> res = CFAOriginationHelperClass.valuesNotInList(new List<Object>{'Test', 'Test1'}, new List<Object>{'Test', 'Test2'});
            System.assertEquals(1, res.size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for valuesNotInList with no same value
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testNotSameValueInList() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            List<Object> res = CFAOriginationHelperClass.valuesNotInList(new List<Object>{'Test', 'Test1'}, new List<Object>{'Test', 'Test1'});
            System.assertEquals(0, res.size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for checkLicense
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testCheckLicense() {
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            CFAOriginationHelperClass.checkLicense();
            System.assertEquals(0, [SELECT Id FROM clcommon__Log__c].size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for updateParentIdAndRecordType
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testUpdateParentIdAndCoopType() {
        Account landusDealerAccount = [SELECT Id 
                                        FROM Account 
                                        WHERE RecordType.Name = 'Dealer' 
                                        AND Coop_Type__c = 'Landus' 
                                        LIMIT 1];
        Account clAccount = [SELECT Id 
                                FROM Account
                                WHERE RecordType.Name = 'Certified Lender' 
                                LIMIT 1];
        List<RecordType> recordTypeList = [SELECT Id,
                                                    Name
                                                FROM RecordType
                                                WHERE Name IN ('Certified Lender', 'General Manager', 'Authorized Person')
                                                ORDER BY Name];
        clAccount.RecordType = recordTypeList[0];
        Database.update(clAccount, true);
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            String recordType = CFAOriginationHelperClass.updateParentIdAndRecordType(recordTypeList, clAccount, landusDealerAccount.Id);
            System.assertEquals('Certified Lender', recordType, PortalConstants.ASSERTION_FAILED);
            clAccount = [SELECT Id, Name, Coop_Type__c, ParentId, RecordType.Name FROM Account WHERE Id =: clAccount.Id LIMIT 1];
            System.assertEquals('Landus', clAccount.Coop_Type__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals(landusDealerAccount.Id, clAccount.ParentId, PortalConstants.ASSERTION_FAILED);
            System.assertEquals('Certified Lender', clAccount.RecordType.Name, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for updateUserProfile for AP
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testUpdateUserProfileForAP() {
        User clUser = [SELECT Id,
                                IsActive,
                                AccountId
                        FROM User
                        WHERE AccountId IN (
                            SELECT Id
                                FROM Account
                                WHERE Name = 'Ross Geller')];
        clUser.IsActive = true;
        Database.update(clUser, true);
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            CFAOriginationHelperClass.updateUserProfile('CFA', clUser.AccountId, 'Authorized Person');
        }
        Test.stopTest();
        cluser = [SELECT Id,
                        IsActive,
                        AccountId
                    FROM User
                    WHERE AccountId IN (
                        SELECT Id
                            FROM Account
                            WHERE Name = 'Ross Geller')];
        System.assertEquals(false, cluser.IsActive, PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description Test method for updateUserProfile for GMK FSA
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testUpdateUserProfileForGmkFSA() {
        User clUser = [SELECT Id,
                                IsActive,
                                AccountId
                        FROM User
                        WHERE AccountId IN (
                            SELECT Id
                                FROM Account
                                WHERE Name = 'Ross Geller')];
        clUser.IsActive = true;
        Database.update(clUser, true);
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            CFAOriginationHelperClass.updateUserProfile('Growmark', clUser.AccountId, 'Field Staff Agent');
        }
        Test.stopTest();
        cluser = [SELECT Id,
                        IsActive,
                        AccountId,
                        Profile.Name
                    FROM User
                    WHERE AccountId IN (
                        SELECT Id
                            FROM Account
                            WHERE Name = 'Ross Geller')];
        System.assertEquals('Growmark Field Staff Agent', cluser.Profile.Name, PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description Test method for updateUserProfile for Landus PA
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testUpdateUserProfileForLandusPA() {
        User clUser = [SELECT Id,
                                IsActive,
                                AccountId
                        FROM User
                        WHERE AccountId IN (
                            SELECT Id
                                FROM Account
                                WHERE Name = 'Ross Geller')];
        clUser.IsActive = true;
        Database.update(clUser, true);
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            CFAOriginationHelperClass.updateUserProfile('Landus', clUser.AccountId, 'Payment Administrator');
        }
        Test.stopTest();
        cluser = [SELECT Id,
                        IsActive,
                        AccountId,
                        Profile.Name
                    FROM User
                    WHERE AccountId IN (
                        SELECT Id
                            FROM Account
                            WHERE Name = 'Ross Geller')];
        System.assertEquals('Payment Administrator', cluser.Profile.Name, PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description Test method for updateUserProfile for deactivate user
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testUpdateUserProfileForDeactivateUser() {
        User clUser = [SELECT Id,
                                IsActive,
                                AccountId
                        FROM User
                        WHERE AccountId IN (
                            SELECT Id
                                FROM Account
                                WHERE Name = 'Ross Geller')];
        clUser.IsActive = false;
        Database.update(clUser, true);
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            CFAOriginationHelperClass.updateUserProfile('Landus', clUser.AccountId, 'Payment Administrator');
        }
        Test.stopTest();
        cluser = [SELECT Id,
                        IsActive,
                        AccountId,
                        Profile.Name
                    FROM User
                    WHERE AccountId IN (
                        SELECT Id
                            FROM Account
                            WHERE Name = 'Ross Geller')];
        System.assertEquals('Payment Administrator', cluser.Profile.Name, PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description Test method for updateUserProfile for profile with no user
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testUpdateUserProfileWithoutUser() {
        Account accountObj = [SELECT Id FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            CFAOriginationHelperClass.updateUserProfile('Landus', accountObj.Id, 'Payment Administrator');
        }
        Test.stopTest();
        List<User> userList = [SELECT Id,
                                        IsActive,
                                        AccountId
                                FROM User
                                WHERE AccountId IN (
                                    SELECT Id
                                        FROM Account
                                        WHERE Name = 'Kisan Loan')];
        System.assertEquals(0, userList.size(), PortalConstants.ASSERTION_FAILED);
    }
    /**
    * @description Test method for getCoopTypeByAccountId
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetCoopType() {
        Account accountObj = [SELECT Id FROM Account WHERE Coop_Type__c = 'Landus' LIMIT 1];
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            String coop = CFAOriginationHelperClass.getCoopTypeByAccountId(accountObj.Id);
            System.assertEquals('Landus', coop, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for createDummyRelationship
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testCreateDummyRelationship() {
        List<Account> accountList = [SELECT Id FROM Account WHERE RecordType.Name = 'Dealer' AND Coop_Type__c = 'Growmark'];
        Account clAccount = [SELECT Id, ParentId FROM Account WHERE RecordType.Name = 'Certified Lender' LIMIT 1];
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            CFAOriginationHelperClass.createDummyRelationship(new List<Id>{accountList[0].Id}, new Map<String, String>{ConstantValues.ACCOUNT_ID => clAccount.Id, ConstantValues.DEALER_ID => clAccount.ParentId}, new List<String>{'Field Staff Agent', 'Authorized Person'});
            System.assertEquals(1, [SELECT Id FROM clcommon__Relationship__c WHERE Previous_Dealer_Contact_Role__c =: ConstantValues.FIELD_STAFF_AGENT].size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getDealerRelationContacts with relationship
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetDealerPARelationContacts() {
        List<Account> accountList = [SELECT Id FROM Account WHERE RecordType.Name = 'Payment Administrator'];
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Map<Object, Contact> resMap = CFAOriginationHelperClass.getDealerRelationContacts(new List<Id>{accountList[0].Id});
            System.assertEquals(1, resMap.size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getDealerRelationContacts with no relationship
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetDealerPARelationsEmpty() {
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Map<Object, Contact> resMap = CFAOriginationHelperClass.getDealerRelationContacts(new List<Id>());
            System.assertEquals(0, resMap.size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getRecordType for CL
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetRecordTypeOfCL() {
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            String res = CFAOriginationHelperClass.getRecordType(new List<String>{'Certified Lender', 'Authorized Person'});
            System.assertEquals('Certified Lender', res, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getRecordType with no record
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetEmptyRecordType() {
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            String res = CFAOriginationHelperClass.getRecordType(new List<String>{'Authorized Person'});
            System.assertEquals('', res, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getAdditionalRecipientEmailForSingleTransaction
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testAdditionalRecipientSingleTxn() {
        List<Account> accountList = [SELECT Id, Coop_Type__c, CIF_Number__c FROM Account WHERE RecordType.Name = 'Dealer' AND Coop_Type__c = 'CFA'];
        accountList[0].CIF_Number__c = '888888';
        Database.update(accountList, true);
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            List<String> res = CFAOriginationHelperClass.getAdditionalRecipientEmailForSingleTransaction(new Map<String, String>{accountList[0].CIF_Number__c => accountList[0].Coop_Type__c},
                                                                                                    'APPLICATION SUBMITTTED BY SALES AGENT ON BEHALF OF GROWER NOTIFICATION',
                                                                                                    new List<String>{});
            System.assertEquals(true, res.size() > 0, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getAdditionalRecipientEmailForSingleTransaction with changed dealer 
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testNoAdditionalRecipientForSingleTxn() {
        List<Account> accountList = [SELECT Id, Coop_Type__c, CIF_Number__c FROM Account WHERE RecordType.Name = 'Dealer' AND Coop_Type__c = 'CFA'];
        accountList[0].CIF_Number__c = '111111';
        Database.update(accountList, true);
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            List<String> res = CFAOriginationHelperClass.getAdditionalRecipientEmailForSingleTransaction(new Map<String, String>{accountList[0].CIF_Number__c => accountList[0].Coop_Type__c},
                                                                                                    'APPLICATION SUBMITTTED BY SALES AGENT ON BEHALF OF GROWER NOTIFICATION',
                                                                                                    new List<String>{});
            System.assertEquals(true, res.size() == 0, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getAdditionalRecipientEmailForSingleTransaction with empty dealer CIF to coop map
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testAdditionalRecipientWithoutCIF() {
        List<Account> accountList = [SELECT Id, Coop_Type__c, CIF_Number__c FROM Account WHERE RecordType.Name = 'Dealer' AND Coop_Type__c = 'CFA'];
        accountList[0].CIF_Number__c = '888888';
        Database.update(accountList, true);
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            List<String> res = CFAOriginationHelperClass.getAdditionalRecipientEmailForSingleTransaction(new Map<String, String>(),
                                                                                                    'APPLICATION SUBMITTTED BY SALES AGENT ON BEHALF OF GROWER NOTIFICATION',
                                                                                                    new List<String>{});
            System.assertEquals(true, res.size() == 0, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getAdditionalRecipientEmailForMultipleTransaction
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testAdditionalRecipientMultiTxn() {
        List<Account> accountList = [SELECT Id, Coop_Type__c, CIF_Number__c FROM Account WHERE RecordType.Name = 'Dealer' AND Coop_Type__c = 'CFA'];
        accountList[0].CIF_Number__c = '888888';
        Database.update(accountList, true);
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Map<String, Set<String>> res = CFAOriginationHelperClass.getAdditionalRecipientEmailForMultipleTransaction(new Map<String, String>{accountList[0].CIF_Number__c => accountList[0].Coop_Type__c},
                                                                                                    'CFA ACH Activity Notice',
                                                                                                    new Map<String, Set<String>>{});
            System.assertEquals(true, res.size() > 0, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getAdditionalRecipientEmailForMultipleTransaction with changed dealer
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testNoAdditionalRecipientMultiTxn() {
        List<Account> accountList = [SELECT Id, Coop_Type__c, CIF_Number__c FROM Account WHERE RecordType.Name = 'Dealer' AND Coop_Type__c = 'CFA'];
        accountList[0].CIF_Number__c = '111111';
        Database.update(accountList, true);
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Map<String, Set<String>> res = CFAOriginationHelperClass.getAdditionalRecipientEmailForMultipleTransaction(new Map<String, String>{accountList[0].CIF_Number__c => accountList[0].Coop_Type__c},
                                                                                                    'CFA ACH Activity Notice',
                                                                                                    new Map<String, Set<String>>{});
            System.assertEquals(true, res.size() == 0, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getAdditionalRecipientEmailForMultipleTransaction with empty dealer CIF to coop map
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testAdditionalRecipientMultiTxnWithoutCIF() {
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            Map<String, Set<String>> res = CFAOriginationHelperClass.getAdditionalRecipientEmailForMultipleTransaction(new Map<String, String>(),
                                                                                                    'CFA ACH Activity Notice',
                                                                                                    new Map<String, Set<String>>{});
            System.assertEquals(true, res.size() == 0, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for createRelationshipRecord for PA
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testCreateNewRelationship() {
        List<Account> accountList = [SELECT Id, Coop_Type__c, CIF_Number__c FROM Account WHERE RecordType.Name = 'Dealer' AND Coop_Type__c = 'CFA'];
        Account accountObj = [SELECT Id, ParentId FROM Account WHERE RecordType.Name = 'Certified Lender' LIMIT 1];
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            CFAOriginationHelperClass.createRelationshipRecord(new Map<String, Object>{ConstantValues.PREVIOUS_RECORD_TYPE_NAME => 'Certified Lender',
                                                                                        ConstantValues.PREVIOUS_DEALER_ID => accountObj.ParentId,
                                                                                        ConstantValues.DEALER_CONTACT_ID => accountObj.Id,
                                                                                        ConstantValues.DEALER_ID => accountList[0].Id,
                                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{'Payment Administrator'}});
            clcommon__Relationship__c relationshipRecord = [SELECT Id, clcommon__Relationship__r.Name FROM clcommon__Relationship__c WHERE clcommon__Related_Entity__c =: accountObj.Id LIMIT 1];
            System.assertEquals('Payment Administrator', relationshipRecord.clcommon__Relationship__r.Name, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for createRelationshipRecord for FSA
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testCreateNewRelationshipForFSA() {
        List<Account> accountList = [SELECT Id, Coop_Type__c, CIF_Number__c FROM Account WHERE RecordType.Name = 'Dealer' AND Coop_Type__c = 'Growmark'];
        Account accountObj = [SELECT Id, ParentId FROM Account WHERE RecordType.Name = 'Certified Lender' LIMIT 1];
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            CFAOriginationHelperClass.createRelationshipRecord(new Map<String, Object>{ConstantValues.PREVIOUS_RECORD_TYPE_NAME => 'Certified Lender',
                                                                                        ConstantValues.PREVIOUS_DEALER_ID => accountObj.ParentId,
                                                                                        ConstantValues.DEALER_CONTACT_ID => accountObj.Id,
                                                                                        ConstantValues.DEALER_ID => accountList[0].Id,
                                                                                        ConstantValues.RECORD_TYPE_NAME => new List<String>{'Field Staff Agent'},
                                                                                        ConstantValues.SELECTED_DEALER_COOP => accountList[0].Coop_Type__c});
            clcommon__Relationship__c relationshipRecord = [SELECT Id, clcommon__Relationship__r.Name FROM clcommon__Relationship__c WHERE clcommon__Related_Entity__c =: accountObj.Id Order by clcommon__Relationship__r.Name ASC LIMIT 1];
            System.assertEquals('Field Staff Agent', relationshipRecord.clcommon__Relationship__r.Name, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for deleteExistingRelationship with no existing relationship for FSA
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testDeleteExistingRelationshipForFSA() {
        Account accountObj = [SELECT Id, ParentId FROM Account WHERE RecordType.Name = 'Certified Lender' LIMIT 1];   
        clcommon__Relationship__c relationshipObj = [SELECT Id, clcommon__Relationship__c FROM clcommon__Relationship__c WHERE clcommon__Related_Entity__c =: accountObj.Id LIMIT 1];    
        clcommon__Reciprocal_Role__c roleObj = [SELECT Id FROM clcommon__Reciprocal_Role__c WHERE Name = 'Field Staff Agent' LIMIT 1];
        relationshipObj.clcommon__Relationship__c = roleObj.Id;
        Database.update(relationshipObj, true);
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            CFAOriginationHelperClass.deleteExistingRelationship(new List<String>{'Field Staff Agent'}, accountObj.ParentId, accountObj.Id);
            List<clcommon__Relationship__c> relationshipRecordList = [SELECT Id, clcommon__Relationship__r.Name FROM clcommon__Relationship__c WHERE clcommon__Related_Entity__c =: accountObj.Id LIMIT 1];
            System.assertEquals(0, relationshipRecordList.size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for deleteExistingRelationship with no existing relationship for Sales Agent
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testDeleteExistingRelationshipForSA() {
        Account accountObj = [SELECT Id, ParentId FROM Account WHERE RecordType.Name = 'Certified Lender' LIMIT 1];   
        clcommon__Relationship__c relationshipObj = [SELECT Id, clcommon__Relationship__c FROM clcommon__Relationship__c WHERE clcommon__Related_Entity__c =: accountObj.Id LIMIT 1];    
        clcommon__Reciprocal_Role__c roleObj = [SELECT Id FROM clcommon__Reciprocal_Role__c WHERE Name = 'Sales Agent' LIMIT 1];
        relationshipObj.clcommon__Relationship__c = roleObj.Id;
        Database.update(relationshipObj, true);
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            CFAOriginationHelperClass.deleteExistingRelationship(new List<String>{'Sales Agent'}, accountObj.ParentId, accountObj.Id);
            List<clcommon__Relationship__c> relationshipRecordList = [SELECT Id, clcommon__Relationship__r.Name FROM clcommon__Relationship__c WHERE clcommon__Related_Entity__c =: accountObj.Id LIMIT 1];
            System.assertEquals(0, relationshipRecordList.size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for deleteExistingRelationship with existing relationship for FSA
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testDeleteExistingRelationship() {
        Account accountObj = [SELECT Id, ParentId FROM Account WHERE RecordType.Name = 'Certified Lender' LIMIT 1];
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            CFAOriginationHelperClass.deleteExistingRelationship(new List<String>{'Field Staff Agent'}, accountObj.ParentId, accountObj.Id);
            List<clcommon__Relationship__c> relationshipRecordList = [SELECT Id, clcommon__Relationship__r.Name FROM clcommon__Relationship__c WHERE clcommon__Related_Entity__c =: accountObj.Id LIMIT 1];
            System.assertEquals(1, relationshipRecordList.size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for createPartyBatch
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testCreatePartyBatch() {
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            CFAOriginationHelperClass.createPartyBatch(new Map<String, Object>{ConstantValues.RECORD_TYPE_NAME => new List<String>{'Payment Administrator'}});
            System.assertEquals(0, [SELECT Id FROM clcommon__Log__c].size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for createAccountShareRecord to delete account share
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testDeleteAccountShare() {
        Account clAccountObj = [SELECT Id FROM Account WHERE RecordType.Name = 'Certified Lender' LIMIT 1];
        User clUser = [SELECT Id FROM User WHERE AccountId =: clAccountObj.Id LIMIT 1];
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            CFAOriginationHelperClass.createAccountShareRecord(new Map<String, Object>{ConstantValues.RECORD_TYPE_NAME => new List<String>{'Sales Agent'}, ConstantValues.DEALER_CONTACT_ID => clAccountObj.Id});
            System.assertEquals(0, [SELECT Id FROM AccountShare  WHERE UserOrGroupId =: clUser.Id LIMIT 1].size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for createAccountShareRecord to create account share
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testCreateAccountShare() {
        Account paAccountObj = [SELECT Id FROM Account WHERE RecordType.Name = 'Payment Administrator' LIMIT 1];
        User paUser = [SELECT Id FROM User WHERE AccountId =: paAccountObj.Id LIMIT 1];
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            CFAOriginationHelperClass.createAccountShareRecord(new Map<String, Object>{ConstantValues.RECORD_TYPE_NAME => new List<String>{'Payment Administrator'}, ConstantValues.DEALER_CONTACT_ID => paAccountObj.Id});
            System.assertEquals(1, [SELECT Id FROM AccountShare  WHERE UserOrGroupId =: paUser.Id LIMIT 1].size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for createAccountShareRecord to create account share with no user
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testCreateAccountShareWithNoUser() {
        Account saAccountObj = [SELECT Id FROM Account WHERE RecordType.Name = 'Sales Agent' LIMIT 1];
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            CFAOriginationHelperClass.createAccountShareRecord(new Map<String, Object>{ConstantValues.RECORD_TYPE_NAME => new List<String>{'Sales Agent'}, ConstantValues.DEALER_CONTACT_ID => saAccountObj.Id});
            System.assertEquals(0, [SELECT Id FROM User  WHERE AccountId =: saAccountObj.Id LIMIT 1].size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for sendEmailOnDeletingPendingPayment
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testSendEmailOnDeletePendingPayment() {
        genesis__Funding_Transaction__c fundingTxnObj = [SELECT Id, 
                                                                Pricing_Detail__r.Loan_Number__c, 
                                                                Grower_Name__c, 
                                                                genesis__Application__r.Dealer_Name__r.Coop_Type__c,
                                                                genesis__Amount__c,
                                                                genesis__Application__r.genesis__Maturity_Date__c
                                                            FROM genesis__Funding_Transaction__c 
                                                            WHERE genesis__Application__r.genesis__Loan_Amount__c = 824001 
                                                            LIMIT 1];
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            try{
                CFAOriginationHelperClass.sendEmailOnDeletingPendingPayment(new Map<Id, genesis__Funding_Transaction__c>{fundingTxnObj.Id => fundingTxnObj},
                new Map<Id, String>{fundingTxnObj.Id => String.valueOf(fundingTxnObj.genesis__Amount__c)},
                new Map<Id, String>{fundingTxnObj.Id => (fundingTxnObj.genesis__Application__r.genesis__Maturity_Date__c).format()});
            } catch (Exception exceptionObj){
                System.assertEquals(0, [SELECT Id FROM clcommon__Log__c WHERE Name =: PortalGenericDeleteAPI.class.getName()].size(), PortalConstants.ASSERTION_FAILED);
            }
        }
        Test.stopTest();
    }

    /**
    * @description Test method for emailTemplateMappingMetadata
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testEmailTemplateMapping() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            EmailTemplate emailTemplate = CFAOriginationHelperClass.emailTemplateMappingMetadata(ConstantValues.CFA_COOP_TYPE, PortalConstants.APP_WITHDRAW_BY_DEALER_NOTIFIC);
            System.assertEquals('CFA App Withdrawal by Dealer Notific', emailTemplate.Name, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for emailTemplateMappingMetadata Exception
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testEmailTemplateMappingException() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            EmailTemplate emailTemplate;
            try{
                emailTemplate = CFAOriginationHelperClass.emailTemplateMappingMetadata(ConstantValues.CFA_COOP_TYPE, PortalConstants.EMPTY_STRING);
            }catch(Exception exceptionObj){
                System.assertEquals(null, emailTemplate, PortalConstants.ASSERTION_FAILED);
            }
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getLogoURLbyCoopType CFA
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetCFALogUrl() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            String url = CFAOriginationHelperClass.getLogoURLbyCoopType(ConstantValues.CFA_COOP_TYPE);
            System.assertEquals(System.Label.CFA_Logo_Url, url, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getLogoURLbyCoopType GrowMark
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetGMKLogUrl() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            String url = CFAOriginationHelperClass.getLogoURLbyCoopType(ConstantValues.GROWMARK_COOP_TYPE);
            System.assertEquals(System.Label.GMK_Logo_Url, url, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getLogoURLbyCoopType Landus
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest 
    private static void testGetLandusLogUrl() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            String url = CFAOriginationHelperClass.getLogoURLbyCoopType(ConstantValues.LANDUS_COOP_TYPE);
            System.assertEquals(System.Label.Landus_Logo_Url, url, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getOrgWideEmailAddress
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetOrgWideEmailAddress() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            List<OrgWideEmailAddress> senderAddressList = CFAOriginationHelperClass.getOrgWideEmailAddress();
            System.assertEquals(1, senderAddressList.size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getUserListFromAccountList with No Account Id
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetUserListWithNoAccountId() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            Map<Id, Id> resultMap = CFAOriginationHelperClass.getUserListFromAccountList(new List<Id>{});
            System.assertEquals(0, resultMap.size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getUserListFromAccountList
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testGetUserList() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            Map<Id, Id> resultMap = CFAOriginationHelperClass.getUserListFromAccountList(new List<Id>{[SELECT Id FROM Account WHERE Name = 'Ross Geller' LIMIT 1][0].Id});
            System.assertEquals(1, resultMap.size(), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for checkEmptyList
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testCheckEmptyList() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            try{
                CFAOriginationHelperClass.checkEmptyList(new List<Object>(), 'Test');
            }catch(Exception exceptionObj){
                System.assertEquals('Test', exceptionObj.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
        }
        Test.stopTest();
    }
    /**
    * @description Test method for checkRequiredParameters
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testBlankString() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            try{
                CFAOriginationHelperClass.checkRequiredParameters('');
            }catch(Exception exceptionObj){
                System.assertEquals(ConstantValues.PARAMETER_MISSING, exceptionObj.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getPartyTypeId
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void getPartyTypeIdByRecordType() {
        Test.startTest();
        System.runAs([SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1][0]){
            String partyTypeId = CFAOriginationHelperClass.getPartyTypeId(ConstantValues.CERTIFIED_LENDER);
            List<clcommon__Party_Type__c> clPartytype = [SELECT Id
                                                            FROM clcommon__Party_Type__c 
                                                            WHERE Name= 'Certified Lender'];
            System.assertEquals(clPartytype[0].Id, partyTypeId, PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
    /**
    * @description Test method for getPartyTypeId Exception
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void getPartyTypeIdByRecordTypeException() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            try{
                CFAOriginationHelperClass.getPartyTypeId(ConstantValues.CERTIFIED_LENDER);
            } catch (Exception exceptionObj){
                System.assertEquals('List has no rows for assignment to SObject', exceptionObj.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
        }
        Test.stopTest();
    }

    /**
    * @description Test method for throwAuraHandledException
    * @author Soumik Pattanayak | 07-10-2024 
    **/
    @IsTest
    private static void testThrowAuraHandledException() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(clUser){
            try{
                CFAOriginationHelperClass.throwAuraHandledException('Testing Aura Handled Exception');
            } catch (Exception exceptionObj){
                System.assertEquals('Testing Aura Handled Exception', exceptionObj.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
        }
        Test.stopTest();
    }
    /**
    * @description : Test Method for createDocCategoryAttachment for succes scenario
    * @author Suraj Kumar | 10-25-2024 
    **/
    @isTest
    private static void testCreateDocCategoryAttachment(){
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 824001 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id, Title FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID LIMIT 1];
        ContentVersion contentVersionObj =  [SELECT Id, 
                                                    Title,
                                                    ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId = :contentDocumentObj.Id LIMIT 1];
        Test.startTest();
        System.runAs(userObj){  
            CFAOriginationHelperClass.createDocCategoryAttachment(new Map<String,String>{
                PortalConstants.TITLE_KEY => contentVersionObj.Title,
                PortalConstants.CONTENT_VERSION_ID_KEY => contentVersionObj.Id,
                PortalConstants.CONTENT_DOC_ID_KEY => contentDocumentLinkObj.ContentDocumentId,
                PortalConstants.APPLICATION_ID_KEY => contentDocumentLinkObj.LinkedEntityId,
                PortalConstants.NAME_KEY => PortalConstants.SIGNED_AGREEMENT_TASK
            });  
            List<clcommon__Category_Attachment_Association__c> categoryAttachmentObj = [SELECT Id FROM clcommon__Category_Attachment_Association__c WHERE clcommon__Content_Document_Id__c = :contentDocumentObj.Id];
            System.assert(categoryAttachmentObj.size()>0, 'AssertionFailed');
        }
        Test.stopTest();
    }

    /**
    * @description : Test Method for createDocCategoryAttachment for failure scenario
    * @author Suraj Kumar | 10-25-2024 
    **/
    @isTest
    private static void testCreateDocCategoryAttachmentFailure(){
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 824001 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id, Title FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID LIMIT 1];
        ContentVersion contentVersionObj =  [SELECT Id, 
                                                    Title,
                                                    ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId = :contentDocumentObj.Id LIMIT 1];
        Test.startTest();
        System.runAs(userObj){  
            CFAOriginationHelperClass.createDocCategoryAttachment(new Map<String,String>{
                PortalConstants.TITLE_KEY => contentVersionObj.Title,
                PortalConstants.CONTENT_VERSION_ID_KEY => contentVersionObj.Id,
                PortalConstants.CONTENT_DOC_ID_KEY => contentDocumentLinkObj.ContentDocumentId,
                PortalConstants.APPLICATION_ID_KEY => contentDocumentLinkObj.LinkedEntityId,
                PortalConstants.NAME_KEY => PortalConstants.AGREEMENT_FILE_NAME
            });  
            List<clcommon__Category_Attachment_Association__c> categoryAttachmentObj = [SELECT Id FROM clcommon__Category_Attachment_Association__c WHERE clcommon__Content_Document_Id__c = :contentDocumentObj.Id];
            System.assert(categoryAttachmentObj.size()==0, 'AssertionFailed');
        }
        Test.stopTest();
    }

     /**
    * @description : Test Method for createDocCategoryAttachment empty parameter map
    * @author Suraj Kumar | 10-25-2024 
    **/
    @isTest
    private static void testCategoryAttachmentEmptyParameterMap(){
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        Test.startTest();
        System.runAs(userObj){  
            try{
                CFAOriginationHelperClass.createDocCategoryAttachment(new Map<String,String>());  
            } catch (Exception exceptionObj){
                List<clcommon__Category_Attachment_Association__c> categoryAttachmentObj = [SELECT Id FROM clcommon__Category_Attachment_Association__c];
                System.assert(categoryAttachmentObj.size()==0, 'AssertionFailed');
            }
        }
        Test.stopTest();
    }

    /**
    * @description : Test Method for createDocCategoryAttachment without Title Key
    * @author Suraj Kumar | 10-25-2024 
    **/
    @isTest
    private static void testCategoryAttachmentWithoutTitle(){
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 824001 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id, Title FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID LIMIT 1];
        ContentVersion contentVersionObj =  [SELECT Id, 
                                                    Title,
                                                    ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId = :contentDocumentObj.Id LIMIT 1];
        Test.startTest();
        System.runAs(userObj){  
            try{
                CFAOriginationHelperClass.createDocCategoryAttachment(new Map<String,String>{
                    PortalConstants.CONTENT_VERSION_ID_KEY => contentVersionObj.Id,
                    PortalConstants.CONTENT_DOC_ID_KEY => contentDocumentLinkObj.ContentDocumentId,
                    PortalConstants.APPLICATION_ID_KEY => contentDocumentLinkObj.LinkedEntityId,
                    PortalConstants.NAME_KEY => PortalConstants.SIGNED_AGREEMENT_TASK
                }); 
            } catch (Exception exceptionObj){
                List<clcommon__Category_Attachment_Association__c> categoryAttachmentObj = [SELECT Id FROM clcommon__Category_Attachment_Association__c];
                System.assert(categoryAttachmentObj.size()==0, 'AssertionFailed');
            } 
        }
        Test.stopTest();
    }

    /**
    * @description : Test Method for createDocCategoryAttachment without content version Key
    * @author Suraj Kumar | 10-25-2024 
    **/
    @isTest
    private static void testCategoryAttachmentWithoutConVersion(){
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 824001 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id, Title FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID LIMIT 1];
        ContentVersion contentVersionObj =  [SELECT Id, 
                                                    Title,
                                                    ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId = :contentDocumentObj.Id LIMIT 1];
        Test.startTest();
        System.runAs(userObj){  
            try{
                CFAOriginationHelperClass.createDocCategoryAttachment(new Map<String,String>{
                    PortalConstants.TITLE_KEY => contentVersionObj.Title,
                    PortalConstants.CONTENT_DOC_ID_KEY => contentDocumentLinkObj.ContentDocumentId,
                    PortalConstants.APPLICATION_ID_KEY => contentDocumentLinkObj.LinkedEntityId,
                    PortalConstants.NAME_KEY => PortalConstants.SIGNED_AGREEMENT_TASK
                }); 
            } catch (Exception exceptionObj){
                List<clcommon__Category_Attachment_Association__c> categoryAttachmentObj = [SELECT Id FROM clcommon__Category_Attachment_Association__c];
                System.assert(categoryAttachmentObj.size()==0, 'AssertionFailed');
            } 
        }
        Test.stopTest();
    }

    /**
    * @description : Test Method for createDocCategoryAttachment without content doc Key
    * @author Suraj Kumar | 10-25-2024 
    **/
    @isTest
    private static void testCategoryAttachmentWithoutConDoc(){
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 824001 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id, Title FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID LIMIT 1];
        ContentVersion contentVersionObj =  [SELECT Id, 
                                                    Title,
                                                    ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId = :contentDocumentObj.Id LIMIT 1];
        Test.startTest();
        System.runAs(userObj){  
            try{
                CFAOriginationHelperClass.createDocCategoryAttachment(new Map<String,String>{
                    PortalConstants.TITLE_KEY => contentVersionObj.Title,
                    PortalConstants.CONTENT_VERSION_ID_KEY => contentVersionObj.Id,
                    PortalConstants.APPLICATION_ID_KEY => contentDocumentLinkObj.LinkedEntityId,
                    PortalConstants.NAME_KEY => PortalConstants.SIGNED_AGREEMENT_TASK
                }); 
            } catch (Exception exceptionObj){
                List<clcommon__Category_Attachment_Association__c> categoryAttachmentObj = [SELECT Id FROM clcommon__Category_Attachment_Association__c];
                System.assert(categoryAttachmentObj.size()==0, 'AssertionFailed');
            } 
        }
        Test.stopTest();
    }

     /**
    * @description : Test Method for createDocCategoryAttachment without app Id Key
    * @author Suraj Kumar | 10-25-2024 
    **/
    @isTest
    private static void testCategoryAttachmentWithoutAppId(){
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 824001 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id, Title FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID LIMIT 1];
        ContentVersion contentVersionObj =  [SELECT Id, 
                                                    Title,
                                                    ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId = :contentDocumentObj.Id LIMIT 1];
        Test.startTest();
        System.runAs(userObj){  
            try{
                CFAOriginationHelperClass.createDocCategoryAttachment(new Map<String,String>{
                    PortalConstants.TITLE_KEY => contentVersionObj.Title,
                    PortalConstants.CONTENT_VERSION_ID_KEY => contentVersionObj.Id,
                    PortalConstants.CONTENT_DOC_ID_KEY => contentDocumentLinkObj.ContentDocumentId,
                    PortalConstants.NAME_KEY => PortalConstants.SIGNED_AGREEMENT_TASK
                }); 
            } catch (Exception exceptionObj){
                List<clcommon__Category_Attachment_Association__c> categoryAttachmentObj = [SELECT Id FROM clcommon__Category_Attachment_Association__c];
                System.assert(categoryAttachmentObj.size()==0, 'AssertionFailed');
            } 
        }
        Test.stopTest();
    }

    /**
    * @description : Test Method for createDocCategoryAttachment without Name Key
    * @author Suraj Kumar | 10-25-2024 
    **/
    @isTest
    private static void testCategoryAttachmentWithoutName(){
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c WHERE genesis__Loan_Amount__c = 824001 LIMIT 1];
        ContentDocument contentDocumentObj = [SELECT Id, Title FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        ContentDocumentLink contentDocumentLinkObj =[SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:applicationObj.Id AND ContentDocumentId=:contentDocumentObj.ID LIMIT 1];
        ContentVersion contentVersionObj =  [SELECT Id, 
                                                    Title,
                                                    ContentDocumentId 
                                                FROM ContentVersion 
                                                WHERE ContentDocumentId = :contentDocumentObj.Id LIMIT 1];
        Test.startTest();
        System.runAs(userObj){  
            try{
                CFAOriginationHelperClass.createDocCategoryAttachment(new Map<String,String>{
                    PortalConstants.TITLE_KEY => contentVersionObj.Title,
                    PortalConstants.CONTENT_VERSION_ID_KEY => contentVersionObj.Id,
                    PortalConstants.CONTENT_DOC_ID_KEY => contentDocumentLinkObj.ContentDocumentId,
                    PortalConstants.APPLICATION_ID_KEY => contentDocumentLinkObj.LinkedEntityId
                }); 
            } catch (Exception exceptionObj){
                List<clcommon__Category_Attachment_Association__c> categoryAttachmentObj = [SELECT Id FROM clcommon__Category_Attachment_Association__c];
                System.assert(categoryAttachmentObj.size()==0, 'AssertionFailed');
            }
        }
        Test.stopTest();
    }
    /**
    * @description : Test Method for getDealerDetails
    * @author Ayan Bhowmik | 12-31-2024 
    **/
    @isTest
    private static void testGetDealerDetails(){
        List<clcommon__Relationship__c> relList = [SELECT Id,
                                                        clcommon__Entity__c,
                                                        clcommon__Entity__r.BillingCity,
                                                        clcommon__Entity__r.BillingState,
                                                        clcommon__Entity__r.CIF_Number__c,
                                                        clcommon__Related_Entity__r.name,
                                                        clcommon__Related_Entity__r.clcommon__Email__c,
                                                        clcommon__Entity__r.Coop_Type__c
                                                    FROM clcommon__Relationship__c
                                                    WHERE clcommon__Relationship__r.Name = 'PAYMENT ADMINISTRATOR'
                                                    LIMIT 1];
        User userObj = [SELECT Id
                            FROM USER 
                            WHERE Id = :UserInfo.getUserId() 
                            LIMIT 1];
        List<Account> dealerAccountList = [SELECT Id, 
                                                BillingCity, 
                                                BillingState, 
                                                CIF_Number__c 
                                            FROM Account 
                                            WHERE Coop_Type__c = 'CFA' 
                                            AND RecordType.Name = 'DEALER' 
                                            LIMIT 1];
        Test.startTest();
        System.runAs(userObj){  
            Map<String, String> dealerDetails = CFAOriginationHelperClass.getDealerDetails(relList[0]);
            System.assertEquals(dealerAccountList[0].BillingCity
                                     + ConstantValues.SPACE_STRING 
                                     + ConstantValues.COMMA_STRING 
                                     + ConstantValues.SPACE_STRING, 
                                     dealerDetails.get(ConstantValues.KEY_DEALER_CITY), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(dealerAccountList[0].BillingState, dealerDetails.get(ConstantValues.KEY_DEALER_STATE), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(dealerAccountList[0].CIF_Number__c, dealerDetails.get(ConstantValues.KEY_DEALER_CIF), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(dealerAccountList[0].Id, dealerDetails.get(ConstantValues.KEY_DEALER_ID), PortalConstants.ASSERTION_FAILED);
        }
        Test.stopTest();
    }
}