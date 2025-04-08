/**
 * @description       : Test class for PortalValidationUtil's isValidApplicationCreation method
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 03-12-2025
 * @last modified by  : Ayush Kumar Singh
**/
@isTest
public without sharing class PortalValidationUtilAppCreationTest {
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
    * @description - Test isValidApplicationCreation for Null Loan amount
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForNullLoanAmount(){
        String shouldValidate = 'newApplicant';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationList[0].genesis__Loan_Amount__c = null;
        List<Account> accountList = [SELECT Id,
                                            Name,
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
                                            Birthdate,
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
                System.assertEquals(PortalConstants.APPL_LOAN_AMOUNT_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Negative Loan amount
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForNegativeLoanAmount(){
        String shouldValidate = 'newApplicant';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationList[0].genesis__Loan_Amount__c = -50000;
        List<Account> accountList = [SELECT Id,
                                            Name,
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


        List<genesis__Business_Information__c> businessInfoList=[SELECT Id,
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
                System.assertEquals(PortalConstants.APPL_LOAN_AMOUNT_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Decimal Loan amount
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForDecimalLoanAmount(){
        String shouldValidate = 'newApplicant';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationList[0].genesis__Loan_Amount__c = 50000.98;
        List<Account> accountList = [SELECT Id,
                                            Name,
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


        List<genesis__Business_Information__c> businessInfoList = [ SELECT Id,
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
                System.assertEquals(PortalConstants.APPL_LOAN_AMOUNT_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Invalid Login Id
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForInvalidLogin(){
        String shouldValidate = 'newApplicant';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationList[0].genesis__Loan_Amount__c = 50000.98;
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
        accountList[0].ParentId = null;
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
                System.assertEquals(PortalConstants.SOMETHING_WENT_WRONG, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Grower Login With Application Entity Type Missing  & null coop type for grower
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForGrowerLogin(){
        String shouldValidate = 'newApplicant';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account> accountList = [SELECT Id,
                                            Name,
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
        accountList[0].clcommon__Legal_Entity_Type__c = null;
        accountList[0].Coop_Type__c = null;
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

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c,
                                                                genesis__State_of_Incorporation__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];


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
                System.assertEquals(PortalConstants.APPL_ENTITY_TYPE_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Sales Agent Login With Application Entity Type Missing
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForSaLogin(){
        String shouldValidate = 'newApplicant';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Tony Stark');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account> accountList = [SELECT Id,
                                            Name,
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
        accountList[0].clcommon__Legal_Entity_Type__c = null;
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
                System.assertEquals(PortalConstants.APPL_ENTITY_TYPE_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Co Applicant Login With Application Entity Type Missing
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForCoAppLogin(){
        String shouldValidate = 'newApplicant';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Mike Johnson');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<Account> accountList = [SELECT Id,
                                            Name,
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
        accountList[0].clcommon__Legal_Entity_Type__c = null;
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
                System.assertEquals(PortalConstants.APPL_ENTITY_TYPE_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Coop Type NULL & Misssing Entity Type & null coop type for dealer
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForCFAMissingEntity(){
        String shouldValidate = 'newApplicant';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Dealer_Name__c
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
        accountList[0].ParentId = applicationList[0].Dealer_Name__c;
        Database.update(accountList, true);
        accountList[0].clcommon__Legal_Entity_Type__c = null;
        
        List<Account> parentAccount=[SELECT Id,
                                            Coop_Type__c
                                    FROM Account
                                    WHERE Id =: accountList[0].ParentId
                                    LIMIT 1];
        parentAccount[0].Coop_Type__c = null;
        Database.update(parentAccount, true);
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
                System.assertEquals(PortalConstants.APPL_ENTITY_TYPE_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Coop Type Growmark & Misssing Entity Type & null coop type
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForGMKMissingEntity(){
        String shouldValidate = 'newApplicant';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Dealer_Name__c
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
        accountList[0].ParentId = applicationList[0].Dealer_Name__c;
        Database.update(accountList, true);
        accountList[0].clcommon__Legal_Entity_Type__c = null;
        List<Account> parentAccount= [SELECT Id,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =: accountList[0].ParentId
                                LIMIT 1];
        parentAccount[0].Coop_Type__c = 'Growmark';
        Database.update(parentAccount, true);
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
                System.assertEquals(PortalConstants.APPL_ENTITY_TYPE_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Contact last Name Missing
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForLastNameMissing(){
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

        contactList[0].LastName = null;
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
                System.assertEquals(PortalConstants.APPL_ENTITY_TYPE_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for Account Name Missing
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForNameMissing(){
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
        accountList[0].Name = null;
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

        contactList[0].LastName = null;
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
                System.assertEquals(PortalConstants.APPL_NAME_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationCreation for SSN Missing for Sole prop and CFA
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForSSNMissing(){
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
    * @description - Test isValidApplicationCreation for SSN Missing for Sole prop and GMK
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForGMKSSNMissing(){
        String shouldValidate = 'SaveAndExit';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Account__c,
                                                                genesis__Contact__c,
                                                                Dealer_Name__c
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
        accountList[0].ParentId = applicationList[0].Dealer_Name__c;
        Database.update(accountList, true);
        List<Account> parentAccount= [SELECT Id,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =: accountList[0].ParentId
                                LIMIT 1];
        parentAccount[0].Coop_Type__c = 'Growmark';
        Database.update(parentAccount, true);
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
    * @description - Test isValidApplicationCreation for SSN Blank for Sole prop and CFA
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForSSNBlank(){
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
    * @description - Test isValidApplicationCreation for SSN Blank for Individual and CFA
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForIndividualSSNBlank(){
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

        List<clcommon__Legal_Entity__c> legalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];
        legalEntityTypeList[0].Name = PortalConstants.INDIVIDUAL;                                                   
        Database.update(legalEntityTypeList, true);
        

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
    * @description - Test isValidApplicationCreation for Tax id Null for Corporation and CFA
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForCorporationNullTaxId(){
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

        List<clcommon__Legal_Entity__c> legalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];
        legalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(legalEntityTypeList, true);
        

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
        businessInfoList[0].genesis__Tax_Identification_Number__c = null;
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
    * @description - Test isValidApplicationCreation for SSN Blank for Corporation and CFA
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForDBASSNBlank(){
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

        List<clcommon__Legal_Entity__c> legalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];
        legalEntityTypeList[0].Name = PortalConstants.INDIVIDUAL_ENTITY;                                                   
        Database.update(legalEntityTypeList, true);
        

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
    * @description - Test isValidApplicationCreation for Tax id Null for Corporation and CFA
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForCorporationBlankTaxId(){
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

        List<clcommon__Legal_Entity__c> legalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];
        legalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(legalEntityTypeList, true);
        

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

   
}