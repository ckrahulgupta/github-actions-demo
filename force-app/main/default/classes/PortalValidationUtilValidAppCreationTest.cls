/**
 * @description       : Test class for PortalValidationUtil's isValidApplicationCreation method
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 03-17-2025
 * @last modified by  : Ayush Kumar Singh
**/
@isTest
public without sharing class PortalValidationUtilValidAppCreationTest {
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
        borrowerContactObj.Confirm_SSN__c = '123467669';
        borrowerContactObj.genesis__SSN__c = '123467669';
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
    * @description - Test isValidApplicationCreation for Tax id Null for Corporation and CFA
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForGMKNullTaxId(){
        String shouldValidate = 'SaveAndExit';
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
        Account parentAccount = [SELECT Id,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =: accountList[0].ParentId
                                LIMIT 1];
        parentAccount.Coop_Type__c = 'Growmark';
        Database.update(parentAccount, true);

        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        

        List<Contact> contactList = [SELECT Id,
                                            LastName,
                                            genesis__SSN__c,
                                            Confirm_SSN__c
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
        businessInfoList[0].genesis__Tax_Identification_Number__c = null;
        Database.update(businessInfoList, true);

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
                System.assertEquals(PortalConstants.APPL_TAX_ID_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Tax id Blank for Corporation and CFA
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForGMKBlankTaxId(){
        String shouldValidate = 'SaveAndExit';
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
        Account parentAccount = [SELECT Id,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =: accountList[0].ParentId
                                LIMIT 1];
        parentAccount.Coop_Type__c = 'Growmark';
        Database.update(parentAccount, true);

        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        

        List<Contact> contactList = [SELECT Id,
                                            LastName,
                                            genesis__SSN__c,
                                            Confirm_SSN__c
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
        businessInfoList[0].genesis__Tax_Identification_Number__c = '';
        Database.update(businessInfoList, true);

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
                System.assertEquals(PortalConstants.APPL_TAX_ID_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Account Id Existing Applicant
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForAccountIdMissing(){
        String shouldValidate = 'existingApplicant';
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
        List<Contact> contactList = [SELECT Id,
                                            LastName,
                                            genesis__SSN__c,
                                            Confirm_SSN__c
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

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
                System.assertEquals(PortalConstants.APPL_EXISTING_BORROWER_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Contact first name missing
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForNullFirstName(){
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
                                            HomePhone,
                                            Phone,
                                            Confirm_SSN__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];
        contactList[0].FirstName = null;
        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
                System.assertEquals(PortalConstants.APPL_FIRST_NAME_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
    /**
    * @description - Test isValidApplicationCreation for Contact first name missing
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForBlankFirstName(){
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
                                            Phone
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];
        contactList[0].FirstName = '';

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
                System.assertEquals(PortalConstants.APPL_FIRST_NAME_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Null MailingStreet
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForNullMailingStreet(){
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
                                            Phone
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

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
        borrowerPartyList[0].Street__c=null;
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
                System.assertEquals(PortalConstants.APPL_ADDRESS_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
    /**
    * @description - Test isValidApplicationCreation for Blank Mailing Street
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForBlankMailingStreet(){
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
                                            Phone
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

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
        borrowerPartyList[0].Street__c='';
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
                System.assertEquals(PortalConstants.APPL_ADDRESS_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Null Mailing City
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForNullMailingCity(){
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
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c,
                                            Confirm_SSN__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];

        contactList[0].MailingCity = null;

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
        borrowerPartyList[0].City__c=null;
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
                System.assertEquals(PortalConstants.APPL_CITY_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
    /**
    * @description - Test isValidApplicationCreation for Blank Mailing City
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForBlankMailingCity(){
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
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c,
                                            Confirm_SSN__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];
        contactList[0].MailingCity = '';

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
        borrowerPartyList[0].City__c='';
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
                System.assertEquals(PortalConstants.APPL_CITY_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Null Mailing State
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForNullMailingState(){
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
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c,
                                            Confirm_SSN__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];

        contactList[0].MailingState = null;

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
        borrowerPartyList[0].State__c=null;
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
                System.assertEquals(PortalConstants.APPL_STATE_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
    /**
    * @description - Test isValidApplicationCreation for Blank Mailing State
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForBlankMailingState(){
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
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c,
                                            Confirm_SSN__c
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

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
        borrowerPartyList[0].State__c='';
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
                System.assertEquals(PortalConstants.APPL_STATE_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Null Mailing County
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForNullMailingCounty(){
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
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c,
                                            Confirm_SSN__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];
        contactList[0].Mailing_County__c = null;

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
        borrowerPartyList[0].County__c=null;
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
    * @description - Test isValidApplicationCreation for Blank Mailing County
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForBlankMailingCounty(){
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
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c,
                                            Confirm_SSN__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];
        contactList[0].Mailing_County__c = '';

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
    * @description - Test isValidApplicationCreation for Null Mailing Postal Code
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForNullZIP(){
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
                                            Mailing_County__c,
                                            Birthdate,
                                            MobilePhone,
                                            genesis__SSN__c,
                                            HomePhone,
                                            Phone,
                                            Confirm_SSN__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];

        contactList[0].MailingPostalCode = null;

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
        borrowerPartyList[0].Postal_Code__c=null;
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
                System.assertEquals(PortalConstants.APPL_ZIP_CODE_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
    /**
    * @description - Test isValidApplicationCreation for Blank Mailing Postal Code
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForBlankZIP(){
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
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c,
                                            Confirm_SSN__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];

        contactList[0].MailingPostalCode = '';

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
        borrowerPartyList[0].Postal_Code__c='';
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
                System.assertEquals(PortalConstants.APPL_ZIP_CODE_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Invalid ZIP
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForInvalidZip(){
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
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c,
                                            Confirm_SSN__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];

        contactList[0].MailingPostalCode = '123456';

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
        borrowerPartyList[0].Postal_Code__c='123456';
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
                System.assertEquals(PortalConstants.APPL_ZIP_CODE_INVALID, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Null SSN for ShouldValidate SaveAndContinue
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForNullSSN(){
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
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c,
                                            Confirm_SSN__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];

        contactList[0].genesis__SSN__c = null;
        contactList[0].Confirm_SSN__c = null;

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
                System.assertEquals(PortalConstants.APPL_SSN_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
    /**
    * @description - Test isValidApplicationCreation for Blank SSN for shoudvalidate for save and continue
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForBlankSSN(){
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

        contactList[0].genesis__SSN__c = '';
        contactList[0].Confirm_SSN__c = '';

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
        borrowerPartyList[0].Postal_Code__c='123456';
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
                System.assertEquals(PortalConstants.APPL_SSN_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Null Phone numbers
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForNullPhones(){
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
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c,
                                            Confirm_SSN__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];

        contactList[0].MobilePhone = null;
        contactList[0].HomePhone = null;
        contactList[0].Phone = null;

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
    * @description - Test isValidApplicationCreation for Null Phone numbers
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForNullMaritalStatus(){
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
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c,
                                            Confirm_SSN__c
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

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
        borrowerPartyList[0].Marital_Status__c = null;
        Database.update(borrowerPartyList,true);

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
                System.assertEquals(PortalConstants.APPL_MARITAL_STATUS_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
    /**
    * @description - Test isValidApplicationCreation for Null Phone numbers
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForInvalidSSNLength(){
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
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c,
                                            genesis__SSN__c,
                                            Confirm_SSN__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];
        contactList[0].genesis__SSN__c = '1234567';
        Database.update(contactList,true);


        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
                System.assertEquals(PortalConstants.INVALID_SSN, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
     /**
    * @description - Test isValidApplicationCreation for Null Phone numbers
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForInvalidSSNForNonNumeric(){
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
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c,
                                            genesis__SSN__c,
                                            Confirm_SSN__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];
        contactList[0].genesis__SSN__c = '1234567GT';
        Database.update(contactList,true);


        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
                System.assertEquals(PortalConstants.INVALID_SSN, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

     /**
    * @description - Test isValidApplicationCreation for Null Phone numbers
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForInvalidTaxIDLength(){
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
                                            genesis__Business_Information__r.genesis__Total_Liabilities__c
                                    FROM Account
                                    WHERE Id =: applicationList[0].genesis__Account__c  
                                    LIMIT 1];
                                
                                
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);

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
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c,
                                            Confirm_SSN__c
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
        businessInfoList[0].genesis__Tax_Identification_Number__c = '1234567';
        businessInfoList[0].genesis__State_of_Incorporation__c = 'WA';
        Database.update(businessInfoList,true);

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
                System.assertEquals(PortalConstants.INVALID_TAX_ID, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
     /**
    * @description - Test isValidApplicationCreation for Null Phone numbers
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForInvalidTaxIDForNonNumeric(){
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
                                            genesis__Business_Information__r.genesis__Total_Liabilities__c
                                    FROM Account
                                    WHERE Id =: applicationList[0].genesis__Account__c  
                                    LIMIT 1];
                                
                                
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);

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
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c,
                                            Confirm_SSN__c
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
        businessInfoList[0].genesis__Tax_Identification_Number__c = '1234567GT';
        businessInfoList[0].genesis__State_of_Incorporation__c = 'WA';
        Database.update(businessInfoList,true);

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
                System.assertEquals(PortalConstants.INVALID_TAX_ID, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
     /**
    * @description - Test isValidApplicationCreation for Null Phone numbers
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForNullStateOfIncorporation(){
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
                                            genesis__Business_Information__r.genesis__Total_Liabilities__c
                                    FROM Account
                                    WHERE Id =: applicationList[0].genesis__Account__c  
                                    LIMIT 1];
                                
                                
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);

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
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c,
                                            Confirm_SSN__c
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
        businessInfoList[0].genesis__Tax_Identification_Number__c = '123456789';
        businessInfoList[0].genesis__State_of_Incorporation__c = null;
        Database.update(businessInfoList,true);

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID,
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
                System.assertEquals(PortalConstants.STATE_OF_INCORPORATION_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
    
}