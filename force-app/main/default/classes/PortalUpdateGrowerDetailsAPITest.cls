/**
 * @description       : Test class for PortalUpdateGrowerDetailsAPI
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 02-17-2025
 * @last modified by  : Ayush Kumar Singh
**/
@isTest
private without sharing class PortalUpdateGrowerDetailsAPITest {
    /**
    * @description : This method is to prepare test data
    * @author Ayan Khanra | 01-13-2025 
    **/
    @testSetup
    static void setup(){
        // creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);
        // Creating floating rate index
        clcommon__Floating_Rate_Index__c floatingRateIndexObj = ApplicationOriginationTestHelper.createFloatingRateIndex(
            New Map<String, Object>{ 'Name' => 'CFA Advantage Rate',
                                    'Base Rate Name' => '4-CFA ADVANTAGE',
                                    'Current Floating Rate' => 11,
                                    'Base Rate Adjuster' => 5.5
        });
        Database.insert(floatingRateIndexObj, true);
        // Creating floating rate
        clcommon__Floating_Rate__c floatingRateObj = ApplicationOriginationTestHelper.createFloatingRate(floatingRateIndexObj);
        Database.insert(floatingRateObj, true);
        // Creating new partner program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);
        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.CFA_Partner_Program__c = newPartnerProgramObj.Id;
        Database.insert(dealerAccountObj, true);
        // create sole prop legal entity
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(legalEntityObj,true);
        // create borrower business information
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);
        //create borrower account
        Account borrowerAccountObj = createBorrowerAccount(legalEntityObj,borrowerBusinessInfoObj.Id,dealerAccountObj.Id);
        // creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(new List<Account>{clAccountObj,borrowerAccountObj}, true);
        //create borrower contact
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.insert(new List<Contact>{clContactObj,borrowerContactObj}, true);
        // creating user for certified lender
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        Database.insert(clUserObj, true);
        //create cl resiprocal role
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(clRoleObj,true);
        //create cl deealer relation
        clcommon__Relationship__c clRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj,dealerAccountObj.id,clAccountObj.id);
        Database.insert(clRelationshipObj,true);
        //create product
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);
        //create purpose
        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);
        //creating corporation account, contact
        genesis__Business_Information__c corpBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(corpBusinessInfoObj,true);
        //cretae corporationn legal entity
        clcommon__Legal_Entity__c corpLegalEntityObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(corpLegalEntityObj,true);
        //create corporation account
        Account corporationAccountObj = ApplicationOriginationTestHelper.createCorporationAccount(corpLegalEntityObj, corpBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(corporationAccountObj,true);
        //create corporation contact
        Contact corporationContactObj = ApplicationOriginationTestHelper.createCorporationContact(corporationAccountObj.Id);
        Database.insert(corporationContactObj,true);
        //create corporation application
        genesis__Applications__c corporationApplicationObj = ApplicationOriginationTestHelper.createApplication(new Map<String,Id>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => corporationAccountObj.id,
            'borrowerContactObjId' => corporationContactObj.id,
            'clAccountObjId' => clAccountObj.id
        });
        corporationApplicationObj.genesis__Product_Type__c ='Package';
        // Database.insert(corporationApplicationObj,true); 
        
        Map<String,Id> applicationDataMap = new Map<String,Id>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'clAccountObjId' => clAccountObj.id
        };
        //crate sole prop application
        genesis__Applications__c applicationObj = createSolePropApplication(applicationDataMap);
        Database.insert(new List<genesis__Applications__c>{applicationObj,corporationApplicationObj});
        //create cl party type
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        //crate borrower party type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(new List<clcommon__Party_Type__c>{borrowerPartyTypeObj,clPartyTypeObj},true);
        //create borrower party
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => borrowerPartyTypeObj.id,
            'applicationId' => applicationObj.id
        });
        //create cl party
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
            'accountId' => clAccountObj.id,
            'contactId' => clContactObj.id,
            'partyTypeId' => clPartyTypeObj.id,
            'applicationId' => applicationObj.id
        });
        clPartyObj.clcommon__Party_Types__c = PortalConstants.CERTIFIED_LENDER;
        //create corporation borrower party
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
            'accountId' => corporationAccountObj.id,
            'contactId' => corporationContactObj.id,
            'partyTypeId' => borrowerPartyTypeObj.id,
            'applicationId' => corporationApplicationObj.id
        });
        Database.insert(new List<clcommon__party__c>{clPartyObj,borrowerPartyObj,partyObj},true);
        //create cl party for corporation application
        createCLPartyCorporationApp(new Map<String,Id>{
            'accountId' => clAccountObj.id,
            'contactId' => clContactObj.id,
            'partyTypeId' => clPartyTypeObj.id,
            'applicationId' => corporationApplicationObj.id});
        createCoBorrowerDetails(legalEntityObj,applicationObj,dealerAccountObj.Id);
        CFA_Configuration__c credentialParameterObj = ApplicationOriginationTestHelper.createEmailChangeDecryptionConfig();
        Database.insert(credentialParameterObj,true);
        //dealer applicant relation for individual borrower
        createDealerApplicantRelation(borrowerContactObj,dealerAccountObj.Id);
        //dealer applicant relation for corporation borrower
        createDealerApplicantRelation(corporationContactObj,dealerAccountObj.Id); 
    }

    /**
    * @description : This method creates Dealer applicant relation
    * @author Ayan Khanra | 01-10-2025 
    * @param borrowerContactObj 
    * @param dealerId 
    * @return Dealer_Applicant_Relationship__c 
    **/
    private static Dealer_Applicant_Relationship__c createDealerApplicantRelation(Contact borrowerContactObj,Id dealerId){
        Dealer_Applicant_Relationship__c dealerAppRelationObj= ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerId);
        dealerAppRelationObj.Is_Evergreen_Eligible__c = false;
        Database.insert(dealerAppRelationObj,true);                                                          
        return dealerAppRelationObj;
    }

    /**
    * @description : This method creates cl party that is attached to a corporation application
    * @author Ayan Khanra | 01-11-2025 
    * @param partyParamMap 
    **/
    private static void createCLPartyCorporationApp(Map<String,Id> partyParamMap){
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(partyParamMap);
        clPartyObj.clcommon__Party_Types__c = PortalConstants.CERTIFIED_LENDER;
        Database.insert(clPartyObj,true);
    }
    
    /**
    * @description : This method creates co borrower details
    * @author Ayan Khanra | 01-11-2025 
    * @param legalEntityObj 
    * @param applicationObj 
    * @param dealerId 
    **/
    private static void createCoBorrowerDetails(clcommon__Legal_Entity__c legalEntityObj, genesis__Applications__c applicationObj,Id dealerId){
        genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(coBorrowerBusinessInfoObj,true);
        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(legalEntityObj,coBorrowerBusinessInfoObj.id);
        coBorrowerAccountObj.ParentId = dealerId;
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        Database.insert(coBorrowerAccountObj,true);
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        Database.insert(coBorrowerContactObj,true);
        clcommon__Party_Type__c principalPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        Database.insert(principalPartyTypeObj,true);
        Map<String,Id> principalPartyParamMap = new Map<String,Id>{
            'accountId' => coBorrowerAccountObj.id,
            'contactId' => coBorrowerContactObj.id,
            'partyTypeId' => principalPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createParty(principalPartyParamMap);
        Database.insert(principalPartyObj,true);
        createDealerApplicantRelation(coBorrowerContactObj,dealerId);
    }

    /**
    * @description : This method creates borrower account
    * @author Ayan Khanra | 01-10-2025 
    * @param legalEntityObj 
    * @param borrowerBusinessInfoId 
    * @param dealerAccountObjId 
    * @return Account 
    **/
    private static Account createBorrowerAccount(clcommon__Legal_Entity__c legalEntityObj , Id borrowerBusinessInfoId,Id dealerAccountObjId){
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoId);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        borrowerAccountObj.CIF_Number__c = '123456';
        borrowerAccountObj.ParentId = dealerAccountObjId;
        borrowerAccountObj.Coop_Type__c = 'CFA';
        return borrowerAccountObj;
    }

    /**
    * @description : This method creates sole prop application
    * @author Ayan Khanra | 01-10-2025 
    * @param applicationDataMap 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c createSolePropApplication(Map<String,Id> applicationDataMap){
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(applicationDataMap);
        applicationObj.genesis__Product_Type__c ='Package';
        applicationObj.Crop_Year__c = String.valueOf(System.today().year());
        return applicationObj;
    }

    /**
    * @description : This test method updates the 'Email' and 'Confirm email' filed with the new Email
    * @author Ayan Khanra | 01-10-2025 
    **/
    @isTest
    private static void testChangeEmailAndConfirmEmailFieldSuccess(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Contact> contactList = getIndividualContact();
        contactList[0].Email=null;
        Database.update(contactList[0],true);                 
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'newEmail' => 'gogreen@yopmail.com',
            'contactId' => contactList[0].Id,
            'updateRequest' => 'Email'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Exception occured while changing email of Individual');
            List<Contact> updatedContactList = getIndividualContact();
            System.assertEquals('gogreen@yopmail.com',updatedContactList[0].Email,'Email not updated');
            System.assertEquals('gogreen@yopmail.com',updatedContactList[0].Confirm_Email__c,'New Email not updated');
            System.assertEquals('gogreen@yopmail.com', updatedContactList[0].Account.clcommon__Email__c,'Email filed on account not changed');
            System.assertEquals('gogreen@yopmail.com',updatedContactList[0].Account.Confirm_Email__c,'Confirm Email value on account not changed');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method updates the Dealer applicant to ever Green Eligable successfully
    * @author Ayan Khanra | 01-10-2025 
    **/
    @isTest
    private static void testEverGreenAllowedSuccess(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Contact> contactList = getIndividualContact();                 
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'contactId' => contactList[0].Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Allowed'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);                                                      
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Exception occured while updating ever green eligibily to allowed');
            List<Dealer_Applicant_Relationship__c> dealerRelationList = getDealerApplicantRelation(contactList); 
            System.assertEquals(true,dealerRelationList[0].Is_Evergreen_Eligible__c,'EverGreen eligble status should have changed to true');
            Test.stopTest();
        }
    }

    /**
    * @description :  This test method updates ever green eligble to false value successfully
    * @author Ayan Khanra | 01-10-2025 
    **/
    @isTest
    private static void testEverGreenNotAllowedSuccess(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Contact> contactList = getIndividualContact(); 
        List<Dealer_Applicant_Relationship__c> dealerRelationList = getDealerApplicantRelation(contactList); 
        dealerRelationList[0].Is_Evergreen_Eligible__c = true;
        Database.update(dealerRelationList[0],true);                                                                                               
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'contactId' => contactList[0].Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Not Allowed'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);                                                   
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Exception occured while updating evergreen eligibilty to Not Allowed');
            List<Dealer_Applicant_Relationship__c> updatedDealerRelationList = getDealerApplicantRelation(contactList); 
            System.assertEquals(false,updatedDealerRelationList[0].Is_Evergreen_Eligible__c,'EverGreen eligble status should have changed');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method changes email of a grower from growmark coop type
    * @author Krishanu Chinya | 04-10-2024  
    **/
    @isTest
    private static void testChangeEmailofIndividualGMKSuccess() {
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Test data setup
        List<Contact> contactList = getIndividualContact();
        Account accountToUpdate = new Account(Id = contactList[0].AccountId);
        accountToUpdate.Coop_Type__c = 'Growmark';
        Database.update(accountToUpdate, true);
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'newEmail' => 'new@example.com',
            'contactId' => contactList[0].Id,
            'updateRequest' => 'Email'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Exception occured while changing the email of GMK grower');
            List<Contact> updatedContactList = getIndividualContact();
            System.assertEquals('new@example.com',updatedContactList[0].New_Email__c,'New Email filed value not updated for growmark account');
            Test.stopTest();
        }
    }
    
    /**
    * @description : This test method changes email of a grower from landus coop type and runs on the context of sales agent admin
    * @author Krishanu Chinya | 04-10-2024 
    **/
    @isTest
    private static void testChangeEmailofIndividualLandusSuccess() {
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Test data setup
        List<Contact> contactList = getIndividualContact();
        Account updatedAccountObj = new Account(Id = contactList[0].AccountId);
        updatedAccountObj.Coop_Type__c = 'Landus';
        Database.update(updatedAccountObj, true);
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'newEmail' => 'new@example.com',
            'contactId' => contactList[0].Id,
            'updateRequest' => 'Email'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'New Email filed value not updated for landus');
            Test.stopTest();                      
        }
    }

    /**
    * @description : This test method populates new email if no previous email existed
    * @author Krishanu Chinya | 04-10-2024 
    **/
    @isTest
    private static void testPreviousEmailEmptySuccess() {
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Test data setup
        List<Contact> contactList = getIndividualContact();
        contactList[0].Email = null;
        Database.update(contactList[0], true);
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'newEmail' => 'new@example.com',
            'contactId' => contactList[0].Id,
            'updateRequest' => 'Email'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'New Email filed value not updated');
            Test.stopTest();
        }
    }
    /**
    * @description : This test method gives exception if new email and old email is same
    * @author Krishanu Chinya | 04-10-2024 
    **/
    @isTest
    private static void testWithSameNewAndOldEmailException() {
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Test data setup
        List<Contact> contactList = getIndividualContact();
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'newEmail' => contactList[0].Email,
            'contactId' => contactList[0].Id,
            'updateRequest' => 'Email'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received although new email and old email are same');
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Exception Log not inserted');
            Test.stopTest();
        }
    }

    /**
    * @description - This method gives exception for no parameter
    * @author Sk Minsar | 05-16-2024 
    **/
    @isTest
    private static void testWithNoParamAndLogInsertException() {
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{};
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Exception Log not inserted');
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received although no parameter is passed');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method gives excetion for grower whose account does not exist
    * @author Krishanu Chinya | 04-10-2024 
    **/
    @isTest
    private static void testWithNoAccountIDException() {
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Contact> contactList = getIndividualContact();
        contactList[0].AccountId = null;
        contactList[0].email = null;
        Database.update(contactList[0], true);
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'newEmail' => 'new@example.com',
            'contactId' => contactList[0].Id,
            'updateRequest' => 'Email'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.SOMETHING_WENT_WRONG);
            Test.stopTest();
        }
    }

    /**
    * @description : This test method give exception for Individual grower who doesn't have an SSN
    * @author Krishanu Chinya | 04-11-2024 
    **/
    @isTest
    private static void testWithIndividualWithNoSsnException() {
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Test data setup
        List<Contact> contactList = getIndividualContact();
        contactList[0].genesis__SSN__c = null;
        Database.update(contactList[0], true);
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'newEmail' => 'new@example.com',
            'contactId' => contactList[0].Id,
            'updateRequest' => 'Email'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received although ssn null in contact');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method gives exception for Corporation grower who doesn't have an business info
    * @author Krishanu Chinya | 04-11-2024 
    **/
    @isTest
    private static void testWithCorporationWithNoTaxIndetificationException() {
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Test data setup
        List<Contact> contactList = getCorporationContact();
        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                            genesis__Tax_Identification_Number__c
                                                                    FROM genesis__Business_Information__c
                                                                    WHERE Id =: contactList[0].Account.genesis__Business_Information__c];
        businessInfoList[0].genesis__Tax_Identification_Number__c = null;
        Database.update(businessInfoList[0], true);
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'newEmail' => 'new@example.com',
            'contactId' => contactList[0].Id,
            'updateRequest' => 'Email'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received although ssn null in contact');
            Test.stopTest();
        }
    }

    /**
    * @description : This method updates the new email filed of corporation
    * @author Ayan Khanra | 01-10-2025 
    **/
    @isTest
    private static void testForCorporationEmailUpdateSuccess() {
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Test data setup
        List<Contact> contactList = getCorporationContact();
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'newEmail' => 'new@example.com',
            'contactId' => contactList[0].Id,
            'updateRequest' => 'Email'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Exception occured while updating Email of Corporation');
            Test.stopTest();
        }
        List<Contact> updatedContactList = getCorporationContact();
        System.assertEquals('new@example.com',updatedContactList[0].New_Email__c,'New Email not updated');
    }

    /**
    * @description : This test method logs notification after sending email
    * @author Ayan Khanra | 01-10-2025 
    **/
    @IsTest
    private static void testForCorporationNotificationLogSuccess(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Contact> contactList = getCorporationContact();
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'newEmail' => 'gogreen@yopmail.com',
            'contactId' => contactList[0].Id,
            'updateRequest' => 'Email'
        }; 
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Exception occured while changing the email');
            List<clcommon__Notification__c> notificationList = [SELECT ID 
                                                                FROM clcommon__Notification__c
                                                                WHERE Class_Name__c = 'PortalUpdateGrowerDetailsAPI' LIMIT 1];
            System.assertEquals(1, notificationList.size(),'Email log not inserted');
            Test.stopTest();
        }                                                           
    }

    /**
    * @description : This test method update ever green eligble value to true
    * @author Ayan Khanra | 01-11-2025 
    **/
    @isTest
    private static void testEverGreenAllowedforCoBorrower() {
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Test data setup
        List<Contact> contactList = [SELECT Id,
                                            AccountId
                                    FROM Contact
                                    WHERE Email='mike.johnson@yopmail.com' LIMIT 1];
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'contactId' => contactList[0].Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Allowed'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);           
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Exception occured for coboorower while updaing evergreen eligibilty to true');
            Test.stopTest();
        }
        List<Dealer_Applicant_Relationship__c> dealerRelationList = getDealerApplicantRelation(contactList);
        System.assertEquals(true, dealerRelationList[0].Is_Evergreen_Eligible__c,'Ever greeen Eligibily false');                                                         
    }
    
    /**
    * @description : This test method changes evergren eligibilty of coborrower to false
    * @author Ayan Khanra | 01-11-2025 
    **/
    @isTest
    private static void testEverGreenNotAllowedforCoBorrowerSuccess() {
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Test data setup
        List<Contact> contactList = [SELECT Id,
                                        AccountId
                                    FROM Contact
                                    WHERE Email='mike.johnson@yopmail.com' LIMIT 1];
        List<Dealer_Applicant_Relationship__c> dealerRelationList =  getDealerApplicantRelation(contactList);
        dealerRelationList[0].Is_Evergreen_Eligible__c = true;
        Database.update(dealerRelationList[0]);
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'contactId' => contactList[0].Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Not Allowed'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Exception occured for coborower while updating evergreen value to false');
        }
    }

    /**
    * @description : This test method gives exception for no relatd dealer applicant relation
    * @author Ayan Khanra | 01-10-2025 
    **/
    @isTest
    private static void testForNoRelatedDealerApplicantRelationException() {
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Test data setup
        List<Contact> contactList = getIndividualContact();
        List<Dealer_Applicant_Relationship__c> dealerAppRelationList = getDealerApplicantRelation(contactList);
        Database.delete(dealerAppRelationList[0],true);                                                        
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'contactId' => contactList[0].Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Allowed'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success resonse received  although DR relation not present');
            Test.stopTest();
        }
    } 

    /**
    * @description : This test method gives exception for same value of Evergreen value of dealaer appliant relation and the Evergreen value coming from portal for Individual
    * @author Ayan Khanra | 01-10-2025 
    **/
    @isTest
    private static void testForSameEvergreenValueIndividualException() {
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Test data setup
        List<Contact> contactList = getIndividualContact();                                         
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'contactId' => contactList[0].Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Not Allowed'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success resonse received for individual although requested evergreen value is same');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method gives exception for same value of Evergreen of dalaer appliant relation and the Evergreen value coming from portal for Corporation
    * @author Ayan Khanra | 01-10-2025 
    **/
    @isTest
    private static void testForSameEverGreenValueCorporationException() {
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Test data setup
        List<Contact> contactList = getCorporationContact();
        Account accountObj = new Account(Id = contactList[0].AccountId);
        accountObj.Is_Evergreen_Allowed__c = false;
        Database.update(accountObj);
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'contactId' => contactList[0].Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Not Allowed'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success resonse received for corporation although requested evergreen value is same');
            Test.stopTest();
        }
    }

    /**
    * @description : This test method gives exception for not having dealer
    * @author Ayan Khanra | 01-10-2025 
    **/
    @IsTest
    private static void testNotValidDealerException(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> clAccountObj = [SELECT Id,
                                                ParentId 
                                    FROM Account 
                                    WHERE Name = 'Ross Geller'];
        clAccountObj[0].ParentId = null;
        Database.update(clAccountObj,true);
        List<Contact> contactList = getCorporationContact();
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'contactId' => contactList[0].Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Not Allowed'
        }; 
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received although parentId of looged in user is null');
            Test.stopTest();
        }                   
    }

    /**
    * @description : This test method gives exception for not having required value
    * @author Ayan Khanra | 01-10-2025 
    **/
    @IsTest
    private static void testForNullCotactIdException(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> argumentsFromPortalMap = new Map<String, Object>{
            'contactId' => null,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Allowed'
        }; 
        System.runAs(clUserObj) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI growerDetailsAPIInst = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = growerDetailsAPIInst.invokeAction('componentStrName', new String[]{}, argumentsFromPortalMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success response received altough contact id is null');
            Test.stopTest();
        }                   
    }

    /**
    * @description : Get Contact of corporation Type
    * @author Ayan Khanra | 01-11-2025 
    * @return List<Contact> 
    **/
    private static List<Contact> getCorporationContact(){
        return [SELECT Id,
                        genesis__SSN__c,
                        Account.genesis__Business_Information__c,
                        AccountId,
                        Email,
                        New_Email__c,
                        Confirm_Email__c
                FROM Contact
                WHERE Email = 'green.crops@yopmail.com' LIMIT 1];
    }

    /**
    * @description : Get Contact of Individual Type
    * @author Ayan Khanra | 01-11-2025 
    * @return List<Contact> 
    **/
    private static List<Contact> getIndividualContact(){
        return [SELECT Id,
                        AccountId,
                        Account.clcommon__Email__c, 
                        Account.Confirm_Email__c,
                        genesis__SSN__c,
                        Email,
                        New_Email__c,
                        Confirm_Email__c
                FROM Contact
                WHERE genesis__SSN__c = 'GHFB6766' LIMIT 1];
    }

    /**
    * @description : This method returns DAR
    * @author Ayan Khanra | 01-11-2025 
    * @param contactList 
    * @return List<Dealer_Applicant_Relationship__c> 
    **/
    private static List<Dealer_Applicant_Relationship__c> getDealerApplicantRelation(List<Contact> contactList){
        return [SELECT ID,
                        Is_Evergreen_Eligible__c,
                        Applicant__c
                FROM Dealer_Applicant_Relationship__c
                WHERE Applicant_Contact__c= :contactList[0].Id];
    }

    /**
    * @description : This method returns inserted logs
    * @author Ayan Khanra | 01-07-2025 
    * @return List<clcommon__Log__c> 
    **/
    private static List<clcommon__Log__c> getInsertedLog(){
        return [SELECT ID
                FROM clcommon__Log__c 
                WHERE Name = 'PortalUpdateGrowerDetailsAPI' Limit 1];
    }
}