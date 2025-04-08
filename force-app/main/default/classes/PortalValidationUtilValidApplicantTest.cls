/**
 * @description       : Test Class for PortalValidationUtilTest
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 03-12-2025
 * @last modified by  : Ayush Kumar Singh
**/
@isTest
public without sharing class PortalValidationUtilValidApplicantTest {
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
        Database.insert(dealerAccountObj, true);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInfoObj.Id, dealerAccountObj.Id);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(legalEntityObj,coBorrowerBusinessInfoObj.id);
        Account saAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(businessInfoObj.id,dealerAccountObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        borrowerAccountObj.ParentId = dealerAccountObj.Id;
        borrowerAccountObj.BillingCity = 'Kolkata';
        borrowerAccountObj.BillingState = 'WA';
        borrowerAccountObj.Billing_County__c = 'fghu';
        borrowerAccountObj.Work_Number__c = '098765678';
        borrowerAccountObj.BillingStreet = 'Kolkata';
        borrowerAccountObj.BillingPostalCode = '12345';
        borrowerAccountObj.Work_Number__c = '1234567890';
        borrowerAccountObj.Home_Number__c = '1234567890';
        borrowerAccountObj.Phone = '123467890';
        Database.Insert(new List<Account>{clAccountObj, borrowerAccountObj, coBorrowerAccountObj, saAccountObj}, true);

        
        // Creating All Contacts
        Contact clcontactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        Contact saContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(saAccountObj.id);
        borrowerContactObj.MobilePhone = '9734227544';
        borrowerContactObj.HomePhone = '9734227544';
        borrowerContactObj.Phone = '9734227544';
        borrowerContactObj.Confirm_SSN__c = 'GHFB6766';
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




        Map<String,Object> applicationDataMap = new Map<String,Object>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'saAccountObjId' => saAccountObj.id
        };
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(applicationDataMap);
        applicationObj.genesis__Product_Type__c ='Package';
        applicationObj.Certified_Lender__c = clAccountObj.id;
        applicationObj.Internal_Reference_Code__c = 'Lucifer12345';
        applicationObj.Years_Of_Business_With_Applicant__c = '1-3 Years';
        applicationObj.Flex_Rate_Pricing__c = PortalConstants.TRUE_VALUE;
        applicationObj.Do_You_Recommend_This_Applicant__c = 'Yes';
        Database.insert(applicationObj,true); 

        // Create Borrower Party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(borrowerPartyTypeObj, true);

        // Creating Borrower Party
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>();
        paramForBorrowerPartyMap.put('accountId', borrowerAccountObj.Id);
        paramForBorrowerPartyMap.put('contactId', borrowerContactObj.Id);
        paramForBorrowerPartyMap.put('partyTypeId', borrowerPartyTypeObj.Id);
        paramForBorrowerPartyMap.put('applicationId', applicationObj.Id);
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(paramForBorrowerPartyMap);
        
        Dealer_Applicant_Relationship__c dealerApplicantRelObj=ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.id);
        Database.insert(dealerApplicantRelObj,true);

        borrowerPartyObj=ApplicationOriginationTestHelper.insertIndividualPartyDetails(borrowerPartyObj,dealerApplicantRelObj.id);
        
        Database.insert(borrowerPartyObj,true);
    }

     /**
    * @description - Test validateRateCardDetails for max no of Special Tranche
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateRateCardDetailsMAXTranche(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateRateCardDetails('Seeds', new List<Object>{new Map<String, Object>{'Description' => 'Seeds'}, new Map<String, Object>{'Description' => 'Seeds'}, new Map<String, Object>{'Description' => 'Seeds'}, new Map<String, Object>{'Description' => 'Seeds'}, new Map<String, Object>{'Description' => 'Seeds'}, new Map<String, Object>{'Description' => 'Seeds'}, new Map<String, Object>{'Description' => 'Seeds'}, new Map<String, Object>{'Description' => 'Seeds'},new Map<String, Object>{'Description' => 'Seeds'}});  
            }catch(Exception e){
                System.assertEquals(PortalConstants.MAXIMUM_SPL_TRANCHES, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Null Billing County & Postal code of 9 Digit for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForCorpBlankBillingCounty(){
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account> accountList = [SELECT Id,
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
        accountList[0].BillingPostalCode = '123456789';
        accountList[0].Billing_County__c = '';
        Database.update(accountList, true);
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

        List<clcommon__Legal_Entity__c> legalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];
        legalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(legalEntityTypeList, true);

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        List<clcommon__Party__c> borrowerPartyList= [SELECT ID,
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
                                                    WHERE clcommon__Account__c=:accountList[0].id];
        borrowerPartyList[0].County__c='';
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
                System.assertEquals(PortalConstants.APPL_COUNTY_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Null Phone numbers for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForCorpNullPhones(){
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account> accountList = [SELECT Id,
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
        accountList[0].Work_Number__c = null;
        accountList[0].Home_Number__c = null;
        accountList[0].Phone = null;
        Database.update(accountList, true);
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

        List<clcommon__Legal_Entity__c> legalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];
        legalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(legalEntityTypeList, true);

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];
        businessInfoList[0].genesis__State_of_Incorporation__c = 'WA';

        List<clcommon__Party__c> borrowerPartyList= [SELECT ID,
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
                                                    WHERE clcommon__Account__c=:accountList[0].id];
        borrowerPartyList[0].Work_Number__c=null;
        borrowerPartyList[0].Home_Number__c=null;
        borrowerPartyList[0].Mobile_Number__c=null;

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
                System.assertEquals(PortalConstants.APPL_MOBILE_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Blank Phone numbers for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForCorpBlankPhones(){
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account> accountList = [SELECT Id,
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
        accountList[0].Work_Number__c = '';
        accountList[0].Home_Number__c = '';
        accountList[0].Phone = '';
        Database.update(accountList, true);
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

        List<clcommon__Legal_Entity__c> legalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];
        legalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(legalEntityTypeList, true);

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];
        businessInfoList[0].genesis__State_of_Incorporation__c = 'WA';

        List<clcommon__Party__c> borrowerPartyList= [SELECT ID,
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
                                                    WHERE clcommon__Account__c=:accountList[0].id];
        borrowerPartyList[0].Work_Number__c='';
        borrowerPartyList[0].Home_Number__c='';
        borrowerPartyList[0].Mobile_Number__c='';
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
                System.assertEquals(PortalConstants.APPL_MOBILE_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Null total Assts Work_Number__c and nuill work phone numbers for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForCorpNullTotalAssets(){
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account> accountList = [SELECT Id,
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
        accountList[0].Work_Number__c = null;
        Database.update(accountList, true);
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

        List<clcommon__Legal_Entity__c> legalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];
        legalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(legalEntityTypeList, true);

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];
        businessInfoList[0].genesis__Total_Assets__c = null;
        businessInfoList[0].genesis__State_of_Incorporation__c = 'WA';

        List<clcommon__Party__c> borrowerPartyList= [SELECT ID,
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
                                                    WHERE clcommon__Account__c=:accountList[0].id];

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
                System.assertEquals(PortalConstants.APPL_TOTAL_ASSETS_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Null Total Liabilities and null home phone numbers for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForCorpNullTotalLiab(){
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account> accountList = [SELECT Id,
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
        accountList[0].Home_Number__c = null;
        Database.update(accountList, true);
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

        List<clcommon__Legal_Entity__c> legalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];
        legalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(legalEntityTypeList, true);

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];
        businessInfoList[0].genesis__Total_Liabilities__c = -1000;
        businessInfoList[0].genesis__State_of_Incorporation__c = 'WA';

        List<clcommon__Party__c> borrowerPartyList= [SELECT ID,
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
                                                    WHERE clcommon__Account__c=:accountList[0].id];
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
                System.assertEquals(PortalConstants.APPL_TOTAL_LIABILITIES_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateCropYear for Jun to August Prev Crop Year Invalid
    * @author Sk Minsar | 09-11-2024 
    **/
    @isTest
    static void testValidateCropYearJunToAugust() {
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        if (System.today().month() >= 6 && System.today().month() <= 8) {
            Integer invalidCropYear = System.today().year() - 1; 
            
            System.runAs(clUserObj){
                Test.startTest();
                try {
                    PortalValidationUtil.validateCropYear(invalidCropYear);
                } catch (CustomException e) {
                    System.assertEquals(PortalConstants.CROP_YEAR_ELIGIBLE_ERROR_JUN_AUG, e.getMessage(), PortalConstants.ASSERTION_FAILED);
                }
                Test.stopTest();
            }
        }
    }

    /**
    * @description - Test validateCropYear for September to December Prev Crop Year Invalid
    * @author Sk Minsar | 09-11-2024 
    **/
    @isTest
    static void testValidateCropYearSepToDec() {
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        if (System.today().month() >= 9 && System.today().month() <= 12) {
            Integer invalidCropYear = System.today().year(); 
            
            System.runAs(clUserObj){
                Test.startTest();
                try {
                    PortalValidationUtil.validateCropYear(invalidCropYear);
                } catch (CustomException e) {
                    System.assertEquals(PortalConstants.CROP_YEAR_ELIGIBLE_ERROR_SEP_DEC, e.getMessage(), PortalConstants.ASSERTION_FAILED);
                }
                Test.stopTest();
            }
        }
    }

    /**
    * @description - Test validateCropYear for JanToMay Prev Crop Year Invalid
    * @author Sk Minsar | 09-11-2024 
    **/
    @isTest
    static void testValidateCropYearJanToMay() {
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        if (System.today().month() >= 1 && System.today().month() <= 5) {
            Integer invalidCropYear = System.today().year() - 1; 
            
            System.runAs(clUserObj){
                Test.startTest();
                try {
                    PortalValidationUtil.validateCropYear(invalidCropYear);
                } catch (CustomException e) {
                    System.assertEquals(PortalConstants.CROP_YEAR_ELIGIBLE_ERROR_JAN_MAY, e.getMessage(), PortalConstants.ASSERTION_FAILED);
                }
                Test.stopTest();
            }
        }
    }

    /**
    * @description - Test validateNewGrower NULL SSN
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateNewGrowerNullSSN(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account> accountList = [SELECT Id,
                                            Name,
                                            ParentId,
                                            Parent.Id,
                                            Parent.Coop_Type__c, 
                                            Coop_Type__c, 
                                            RecordType.Name,
                                            clcommon__Legal_Entity_Type__c,
                                            genesis__Business_Information__c,
                                            genesis__Business_Information__r.genesis__Total_Assets__c,
                                            genesis__Business_Information__r.genesis__Total_Liabilities__c
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
        contactList[0].genesis__SSN__c = null;

        System.runAs(clUserObj){
            Test.startTest();
            Contact result = PortalValidationUtil.validateNewGrower(contactList[0], accountList[0].Parent.Coop_Type__c, accountList[0].ParentId);
            System.assertEquals(PortalConstants.TRUE_VALUE, result != null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateNewGrower validate same dealer
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateNewGrowerSameDealer(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Dealer_Name__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account> accountList = [SELECT Id,
                                            Name,
                                            ParentId,
                                            Parent.Id,
                                            Parent.Coop_Type__c, 
                                            Coop_Type__c, 
                                            RecordType.Name,
                                            clcommon__Legal_Entity_Type__c,
                                            genesis__Business_Information__c,
                                            genesis__Business_Information__r.genesis__Total_Assets__c,
                                            genesis__Business_Information__r.genesis__Total_Liabilities__c
                                    FROM Account
                                    WHERE Id =: applicationList[0].genesis__Account__c  
                                    LIMIT 1];
        accountList[0].Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        accountList[0].ParentId = applicationList[0].Dealer_Name__c;
        Database.update(accountList, true);
        Account dealerAccount = [SELECT Id,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =:  accountList[0].ParentId LIMIT 1];
        dealerAccount.Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.update(dealerAccount, true);
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

        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateNewGrower(contactList[0], PortalConstants.GROWMARK_COOP_TYPE, accountList[0].ParentId);
            }catch(Exception e){
                System.assertEquals(PortalConstants.USER_EXIST_IN_SAME_DEALER, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateNewGrower Existing Grower Usess existing account contact
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateNewGrowerUseSameAcc(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Contact result;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Dealer_Name__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account> accountList = [SELECT Id,
                                            Name,
                                            ParentId,
                                            Parent.Id,
                                            Parent.Coop_Type__c, 
                                            Coop_Type__c, 
                                            RecordType.Name,
                                            clcommon__Legal_Entity_Type__c,
                                            genesis__Business_Information__c,
                                            genesis__Business_Information__r.genesis__Total_Assets__c,
                                            genesis__Business_Information__r.genesis__Total_Liabilities__c
                                    FROM Account
                                    WHERE Id =: applicationList[0].genesis__Account__c  
                                    LIMIT 1];
        accountList[0].Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        accountList[0].ParentId = applicationList[0].Dealer_Name__c;
        Database.update(accountList, true);
        Account dealerAccount = [SELECT Id,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =:  accountList[0].ParentId LIMIT 1];
        dealerAccount.Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.update(dealerAccount, true);
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
        List<clcommon__Legal_Entity__c> legalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];
        legalEntityTypeList[0].Name = PortalConstants.INDIVIDUAL_ENTITY;                                                   
        Database.update(legalEntityTypeList, true);

        System.runAs(clUserObj){
            Test.startTest();
            try{
                result = PortalValidationUtil.validateNewGrower(contactList[0], PortalConstants.GROWMARK_COOP_TYPE, accountList[0].ParentId);

            } catch(Exception excp){
                System.assertEquals('A user already exists. Please try searching the grower.',excp.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateNewGrower Existing Grower Usess existing account contact for CFA
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateNewGrowerUseSameAccForCFA(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Contact result;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account> accountList = [SELECT Id,
                                            Name,
                                            ParentId,
                                            Parent.Id,
                                            Parent.Coop_Type__c, 
                                            Coop_Type__c, 
                                            RecordType.Name,
                                            clcommon__Legal_Entity_Type__c,
                                            genesis__Business_Information__c,
                                            genesis__Business_Information__r.genesis__Total_Assets__c,
                                            genesis__Business_Information__r.genesis__Total_Liabilities__c
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
        List<clcommon__Legal_Entity__c> legalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];
        legalEntityTypeList[0].Name = PortalConstants.INDIVIDUAL_ENTITY;                                                   
        Database.update(legalEntityTypeList, true);

        System.runAs(clUserObj){
            Test.startTest();
            try{
                result = PortalValidationUtil.validateNewGrower(contactList[0], PortalConstants.CFA_COOP_TYPE, accountList[0].ParentId);
            }
            catch(Exception excp){
                System.assertEquals('A user already exists. Please try searching the grower.',excp.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateNewGrower validate same dealer FOR CFA
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateNewGrowerSameDealerFORCFA(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Dealer_Name__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account> accountList = [SELECT Id,
                                            Name,
                                            ParentId,
                                            Parent.Id,
                                            Parent.Coop_Type__c, 
                                            Coop_Type__c, 
                                            RecordType.Name,
                                            clcommon__Legal_Entity_Type__c,
                                            genesis__Business_Information__c,
                                            genesis__Business_Information__r.genesis__Total_Assets__c,
                                            genesis__Business_Information__r.genesis__Total_Liabilities__c
                                    FROM Account
                                    WHERE Id =: applicationList[0].genesis__Account__c  
                                    LIMIT 1];
        accountList[0].ParentId = applicationList[0].Dealer_Name__c;
        Database.update(accountList, true);
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

        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateNewGrower(contactList[0], PortalConstants.CFA_COOP_TYPE, accountList[0].ParentId);
            }catch(Exception e){
                System.assertEquals(PortalConstants.USER_EXIST_IN_SAME_DEALER, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateNewGrower Existing Grower of Different Dealer
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateNewGrowerDifferentDealer(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account> accountList = [SELECT Id,
                                            Name,
                                            ParentId,
                                            Parent.Id,
                                            Parent.Coop_Type__c, 
                                            Coop_Type__c, 
                                            RecordType.Name,
                                            clcommon__Legal_Entity_Type__c,
                                            genesis__Business_Information__c,
                                            genesis__Business_Information__r.genesis__Total_Assets__c,
                                            genesis__Business_Information__r.genesis__Total_Liabilities__c
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
        List<clcommon__Legal_Entity__c> legalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];
        legalEntityTypeList[0].Name = PortalConstants.INDIVIDUAL_ENTITY;                                                   
        Database.update(legalEntityTypeList, true);

        System.runAs(clUserObj){
            Test.startTest();
            Contact result = PortalValidationUtil.validateNewGrower(contactList[0], PortalConstants.CFA_COOP_TYPE, accountList[0].Id);
            System.assertEquals(PortalConstants.TRUE_VALUE, result != null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateNewGrower Existing Grower of Different Dealer For Growmark
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateNewGrowerGMKDifferentDealer(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Dealer_Name__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account> accountList = [SELECT Id,
                                            Name,
                                            ParentId,
                                            Parent.Id,
                                            Parent.Coop_Type__c, 
                                            Coop_Type__c, 
                                            RecordType.Name,
                                            clcommon__Legal_Entity_Type__c,
                                            genesis__Business_Information__c,
                                            genesis__Business_Information__r.genesis__Total_Assets__c,
                                            genesis__Business_Information__r.genesis__Total_Liabilities__c
                                    FROM Account
                                    WHERE Id =: applicationList[0].genesis__Account__c  
                                    LIMIT 1];
        accountList[0].Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        accountList[0].ParentId = applicationList[0].Dealer_Name__c;
        Database.update(accountList, true);
        Account dealerAccount = [SELECT Id,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =:  accountList[0].ParentId LIMIT 1];
        dealerAccount.Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.update(dealerAccount, true);
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
        List<clcommon__Legal_Entity__c> legalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];
        legalEntityTypeList[0].Name = PortalConstants.INDIVIDUAL_ENTITY;                                                   
        Database.update(legalEntityTypeList, true);

        System.runAs(clUserObj){
            Test.startTest();
            Contact result = PortalValidationUtil.validateNewGrower(contactList[0], PortalConstants.CFA_COOP_TYPE, accountList[0].Id);
            System.assertEquals(PortalConstants.TRUE_VALUE, result != null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateNewCoApplicant validate same dealer FOR CFA
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateNewCoApplicantSameDealer(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
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
                                            Mailing_County__c,
                                            AccountId
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];

        
        Test.startTest();
            System.runAs(clUserObj){
                PortalValidationUtil.validateNewCoApplicant(contactList[0], PortalConstants.CFA_COOP_TYPE);
            }
            List<Contact> result = [SELECT Id,
                                            LastName
                                    FROM Contact
                                    WHERE Email =: 'jasmin.albin@yopmail.com'
                                    LIMIT 1];
            System.assertEquals(contactList[0].LastName, result[0].LastName, PortalConstants.ASSERTION_FAILED);
        Test.stopTest();
    }

    /**
    * @description - Test validateNewCoApplicant validate same dealer for Growmark
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateNewCoApplicantGMKSameDealer(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Dealer_Name__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account> accountList = [SELECT Id,
                                            Name,
                                            ParentId,
                                            Parent.Id,
                                            Parent.Coop_Type__c, 
                                            Coop_Type__c, 
                                            RecordType.Name,
                                            clcommon__Legal_Entity_Type__c,
                                            genesis__Business_Information__c,
                                            genesis__Business_Information__r.genesis__Total_Assets__c,
                                            genesis__Business_Information__r.genesis__Total_Liabilities__c
                                    FROM Account
                                    WHERE Id =: applicationList[0].genesis__Account__c  
                                    LIMIT 1];
        accountList[0].Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        accountList[0].ParentId = applicationList[0].Dealer_Name__c;
        Database.update(accountList, true);
        Account dealerAccount = [SELECT Id,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =:  accountList[0].ParentId LIMIT 1];
        dealerAccount.Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.update(dealerAccount, true);
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
                                            Mailing_County__c,
                                            AccountId
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];

        
        Test.startTest();
            System.runAs(clUserObj){
                PortalValidationUtil.validateNewCoApplicant(contactList[0], PortalConstants.GROWMARK_COOP_TYPE);
            }
            List<Contact> result = [SELECT Id,
                                            LastName
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];
            System.assertEquals(contactList[0].LastName, result[0].LastName, PortalConstants.ASSERTION_FAILED);
        Test.stopTest();
    }

    /**
    * @description - Test validateDuplicateCorporation for Null Tax id
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateDuplicateCorporationForNullTaxId(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account> accountList = [SELECT Id,
                                            Name,
                                            Parent.Id,
                                            Parent.Coop_Type__c, 
                                            Coop_Type__c, 
                                            RecordType.Name,
                                            clcommon__Legal_Entity_Type__c,
                                            genesis__Business_Information__c,
                                            genesis__Business_Information__r.genesis__Total_Assets__c,
                                            genesis__Business_Information__r.genesis__Total_Liabilities__c
                                    FROM Account
                                    WHERE Id =: applicationList[0].genesis__Account__c  
                                    LIMIT 1];

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        businessInfoList[0].genesis__Tax_Identification_Number__c = null;
        Database.update(businessInfoList[0], true);
        Test.startTest();
            System.runAs(clUserObj){
                PortalValidationUtil.validateDuplicateCorporation(new Map<String,Object>{PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                         PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                         PortalConstants.DEALER_ID_KEY=>accountList[0].ParentId});  
            }
            List<Account> result = [SELECT Id,
                                            Name
                                    FROM Account
                                    WHERE Name = 'Jasmine Albin'
                                    LIMIT 1];
            System.assertEquals(accountList[0].Name, result[0].Name, PortalConstants.ASSERTION_FAILED);
        Test.stopTest();
    }

    /**
    * @description - Test validateDuplicateCorporation for Same dealer
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateDuplicateCorporationForSameDealer(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account> accountList = [SELECT Id,
                                            Name,
                                            Parent.Id,
                                            ParentId,
                                            Parent.Coop_Type__c, 
                                            Coop_Type__c, 
                                            RecordType.Name,
                                            clcommon__Legal_Entity_Type__c,
                                            genesis__Business_Information__c,
                                            genesis__Business_Information__r.genesis__Total_Assets__c,
                                            genesis__Business_Information__r.genesis__Total_Liabilities__c
                                    FROM Account
                                    WHERE Id =: applicationList[0].genesis__Account__c  
                                    LIMIT 1];

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        Database.update(businessInfoList[0], true);
        
        Test.startTest();
            System.runAs(clUserObj){
                try{
                    PortalValidationUtil.validateDuplicateCorporation(new Map<String,Object>{PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                             PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                             PortalConstants.DEALER_ID_KEY=>accountList[0].ParentId});
                }
                catch(Exception ex){
                    System.assert(ex!=null,'Assertion Failed');
                }
            }  
            
        Test.stopTest();
        
    }

    /**
    * @description test for the function verifyUserForApplicant
    * @author Rakesh Saraf | 03-02-2025 
    **/
    @isTest
    private static void testVerifyUserForApplicant(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<Contact> contactList=[SELECT ID FROM Contact WHERE Confirm_SSN__c='GHFB6766'];

        Contact contactObj=ApplicationOriginationTestHelper.createContact();
        Database.insert(contactObj,true);

        Test.startTest();
            System.runAs(clUserObj){
                try{
                    PortalValidationUtil.verifyUserForApplicant(contactList[0].id,contactObj.id);
                }
                catch(Exception ex){
                    System.assert(ex!=null,'Assertion Failed');
                }
            }  
            
        Test.stopTest();
    }
    
    @isTest
    private static void testVerifyUserForApplicantWithoutUser(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Contact contactObj=ApplicationOriginationTestHelper.createContact();
        Database.insert(contactObj,true);

        Boolean exceptionThrown=false;

        Test.startTest();
            System.runAs(clUserObj){
                try{
                    PortalValidationUtil.verifyUserForApplicant(contactObj.id,contactObj.id);
                }
                catch(Exception ex){
                    exceptionThrown=true;
                }
                System.assertEquals(exceptionThrown,false,'Assertion Failed');
            }  
            
        Test.stopTest();
    }
}