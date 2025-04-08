/**
 * @description       : Test class for PortalValidationUtil's isValidApplicationCreation method
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 03-12-2025
 * @last modified by  : Ayush Kumar Singh
**/
@isTest
public without sharing class PortalValidationUtilValidateGrowerTest {

    /**
    * @description - Creating Test Data
    * @author Sk Minsar | 09-13-2024 
    **/
    @TestSetup
    static void makeData(){

        //Creating Legal Entity
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(legalEntityObj,true);

        // Creating CL Product for application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.Insert(clProductObj,true);

        // Creating CL Purpose for application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.Insert(clPurposeObj, true);

        //Create party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(borrowerPartyTypeObj,true);

        // Creating floating rate index
        clcommon__Floating_Rate_Index__c floatingRateIndexObj = ApplicationOriginationTestHelper.createFloatingRateIndex(
            New Map<String, Object>{ 'Name' => 'CFA Advantage Rate',
                                        'Base Rate Name' => '4-CFA ADVANTAGE',
                                        'Current Floating Rate' => 11,
                                        'Base Rate Adjuster' => 5.5
        });
        Database.Insert(floatingRateIndexObj, true);

        // Creating floating rate
        clcommon__Floating_Rate__c floatingRateObj = ApplicationOriginationTestHelper.createFloatingRate(floatingRateIndexObj);
        Database.Insert(floatingRateObj, true);

        // Creating new partner program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.Insert(newPartnerProgramObj, true);

        //Creating all Business Info
        genesis__Business_Information__c businessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.Insert(new List<genesis__Business_Information__c>{businessInfoObj, borrowerBusinessInfoObj, coBorrowerBusinessInfoObj}, true);

        // Creating All Accounts
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoObj.Id, newPartnerProgramObj.Id);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInfoObj.Id, dealerAccountObj.Id);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(legalEntityObj,coBorrowerBusinessInfoObj.id);
        Account saAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(businessInfoObj.id,dealerAccountObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        Database.Insert(new List<Account>{dealerAccountObj, clAccountObj, borrowerAccountObj, coBorrowerAccountObj, saAccountObj}, true);

        
        // Creating All Contacts
        Contact clcontactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        Contact saContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(saAccountObj.id);
        borrowerContactObj.MobilePhone = '9734227544';
        borrowerContactObj.HomePhone = '9734227544';
        borrowerContactObj.Phone = '9734227544';
        Database.Insert(new List<Contact>{clcontactObj, borrowerContactObj, coBorrowerContactObj, saContactObj}, true);

        // Creating all users
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clcontactObj.Id);
        User coBorrowerUserObj = ApplicationOriginationTestHelper.createCLUser(coBorrowerContactObj.id);
        coBorrowerUserObj.UserName=coBorrowerAccountObj.clcommon__Email__c;
        User borrowerUserObj = ApplicationOriginationTestHelper.createCLUser(borrowerContactObj.id);
        borrowerUserObj.UserName=borrowerAccountObj.clcommon__Email__c;
        User saUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(saContactObj.id);
        saUserObj.UserName=saAccountObj.clcommon__Email__c;
        Database.insert(new List<User>{clUserObj, coBorrowerUserObj, borrowerUserObj, saUserObj},true);

        //Creating Role
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.CERTIFIED_LENDER); 
        Database.Insert(clRoleObj, true);

        // Creating Relationships
        clcommon__Relationship__c clDealerRealtionshipObj = TestClassHelper.createCLDealerRelationship(clRoleObj, 
                                                                                                        dealerAccountObj.Id, 
                                                                                                        clAccountObj.Id);
        Database.Insert(clDealerRealtionshipObj, true);

         // Create Relationships 
        Dealer_Applicant_Relationship__c borrowerRealtionObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c principalRealtionObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(coBorrowerContactObj,dealerAccountObj.Id);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{borrowerRealtionObj, principalRealtionObj});

        // Create Application
        Map<String,Object> applicationDataMap = new Map<String,Object>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'saAccountObjId' => saAccountObj.id,
            'dealerApplicantRelationshipId' => borrowerRealtionObj.id
        };
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(applicationDataMap);
        applicationObj.genesis__Product_Type__c ='Package';
        applicationObj.Certified_Lender__c = clAccountObj.id;
        applicationObj.Internal_Reference_Code__c = 'Lucifer12345';
        applicationObj.Years_Of_Business_With_Applicant__c = '1-3 Years';
        applicationObj.Flex_Rate_Pricing__c = PortalConstants.TRUE_VALUE;
        applicationObj.Do_You_Recommend_This_Applicant__c = 'Yes';
        Database.insert(applicationObj,true); 

        //Create Borrower Party
        Map<String,Id> partyParamMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => borrowerPartyTypeObj.id,
            'applicationId' => applicationObj.id,
            'dealerApplicantRelationshipId' => borrowerRealtionObj.Id
        };
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(partyParamMap);
        partyObj.clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;
        partyObj.City__c = 'Kolkata';
        partyObj.State__c = 'WA';
        partyObj.County__c = 'fghu';
        partyObj.Work_Number__c = '098765678';
        partyObj.Street__c = 'Kolkata';
        partyObj.Postal_Code__c = '12345';
        partyObj.Home_Number__c = '1234567890';
        partyObj.Mobile_Number__c = '123467890';
        Database.insert(partyObj,true);
    }

    /**
    * @description - return data map
    * @author Sk Minsar | 01-06-2025 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getDataMap(){
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account>  accountList = [SELECT Id,
                                            Name,
                                            Parent.Id,
                                            Parent.Coop_Type__c, 
                                            Coop_Type__c, 
                                            RecordType.Name,
                                            clcommon__Legal_Entity_Type__c,
                                            genesis__Business_Information__c,
                                            genesis__Business_Information__r.genesis__Total_Assets__c,
                                            genesis__Business_Information__r.genesis__Total_Liabilities__c,
                                            BillingState,
                                            BillingStreet,
                                            BillingCity,
                                            BillingPostalCode,
                                            Billing_County__c,
                                            Work_Number__c,
                                            Home_Number__c,
                                            Phone
                                    FROM Account
                                    WHERE Id =: applicationList[0].genesis__Account__c  
                                    LIMIT 1];

        List<Contact> contactList = [SELECT Id,
                                            LastName,
                                            FirstName,
                                            MailingStreet,
                                            MailingCity,
                                            MailingState,
                                            MailingPostalCode,
                                            Birthdate,
                                            MobilePhone,
                                            genesis__SSN__c,
                                            Confirm_SSN__c,
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];
        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                            genesis__Total_Assets__c,
                                                                            genesis__Total_Liabilities__c,
                                                                            genesis__Tax_Identification_Number__c,
                                                                            genesis__State_of_Incorporation__c
                                                                    FROM genesis__Business_Information__c
                                                                    WHERE Id = :accountList[0].genesis__Business_Information__c
                                                                    LIMIT 1];
        List<clcommon__Party__c> partyList = [SELECT ID,
                                                    City__c,
                                                    State__c,
                                                    Street__c,
                                                    Postal_Code__c,
                                                    County__c,
                                                    Work_Number__c,
                                                    Home_Number__c,
                                                    Mobile_Number__c,
                                                    Marital_Status__c
                                            FROM clcommon__party__c
                                            LIMIT 1];

        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];

        return new Map<String, Object>{
            'applicationList' => applicationList,
            'accountList' => accountList,
            'contactList' => contactList,
            'businessInfoList' => businessInfoList,
            'partyList' => partyList,
            'objLegalEntityTypeList' => objLegalEntityTypeList
        };

    }

    /**
    * @description - Test isValidApplicationCreation for Null MobilePhone numbers & Total Liabilities Negative
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForNullMobilePhoneEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Total_Liabilities__c = -1000;
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].Mobile_Number__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Null Home Phone numbers & Total Liabilities Negative
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForNullHomePhoneEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');                                               
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        businessInfoList[0].genesis__Total_Liabilities__c = -1000;
        borrowerPartyList[0].Home_Number__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Not Null values for Phone numbers & Total Liabilities Negative
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForNotNullPhonesEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Total_Liabilities__c = -1000;
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].Home_Number__c = '1234567890';
        borrowerPartyList[0].Work_Number__c = '1234567890';
        borrowerPartyList[0].Mobile_Number__c = '1234567890';

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Null Phone numbers & Total Asset Negative
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForNullPhoneEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Total_Assets__c = -1000;
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].Mobile_Number__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Null Name for DBA
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForDBANullNameEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        accountList[0].Name = null;
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>)dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.INDIVIDUAL_ENTITY;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Null Name for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpNullNameEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        accountList[0].Name = null;
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>)dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');

        System.runAs(clUserObj){
            Test.startTest();
                try{ 
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Null BillingState for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpNullBillingStateEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        Database.update(accountList, true);
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>)dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].State__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Null Tax Id for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpNullTaxIdEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        Database.update(accountList, true);
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>)dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Tax_Identification_Number__c = null;
        Database.update(businessInfoList, true);
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Blank Name for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpBlankNameEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        accountList[0].Name = '';
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');

        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>)dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);

        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');

        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');

        System.runAs(clUserObj){
            Test.startTest();
                try{  
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Blank BillingState for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpBlankBillingStateEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        Database.update(accountList, true);
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>)dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].State__c = '';

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Blank BillingState for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpBlankTaxIdEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');

        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>)dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);

        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Tax_Identification_Number__c = '';
        Database.update(businessInfoList, true);

        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test isValidApplicationCreation for Null BillingStreet for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpNullBillingStreetEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        Database.update(accountList, true);
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');

        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>)dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);

        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].Street__c = null;
        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Blank BillingStreet for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpBlankBillingStreetEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        Database.update(accountList, true);
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>)dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].Street__c = '';

        System.runAs(clUserObj){
            Test.startTest();
                try{  
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Null BillingCity for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpNullBillingCityEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        Database.update(accountList, true);
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>)dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].City__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{ 
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Blank BillingCity for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpBlankBillingCityEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        Database.update(accountList, true);
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>)dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].City__c = '';

        System.runAs(clUserObj){
            Test.startTest();
                try{ 
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test isValidApplicationCreation for Null BillingPostalCode for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpNullBillingPostalCodeEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>)dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].Postal_Code__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{ 
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Blank BillingPostalCode for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpBlankBillingPostalCodeEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        Database.update(accountList, true);
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>)dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].Postal_Code__c = '';

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Invalid BillingPostalCode for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpInvalidBillingPostalCodeEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        Database.update(accountList, true);
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>)dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].Postal_Code__c = '123456';

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Null Billing County & Postal code of 5 Digit for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpNullBillingCountyEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        Database.update(accountList, true);
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>)dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__business_information__c>)dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].Postal_Code__c = '12345';
        borrowerPartyList[0].County__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{  
                    PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
}