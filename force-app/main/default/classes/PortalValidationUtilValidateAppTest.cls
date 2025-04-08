/**
 * @description       : Test Class for Portal Validation Util
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 01-24-2025
 * @last modified by  : Rakesh Saraf
**/
@isTest
public without sharing class PortalValidationUtilValidateAppTest {
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

        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        clcommon__Party_Type__c dealerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('DEALER');
        Database.insert(new List<clcommon__Party_Type__c>{dealerPartyTypeObj, borrowerPartyTypeObj, clPartyTypeObj},true);

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
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
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
        Database.Insert(new List<Account>{ clAccountObj, borrowerAccountObj, coBorrowerAccountObj, saAccountObj}, true);

        
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

        AccountShare accountShareObj = ApplicationOriginationTestHelper.createAccountShareRecord(clAccountObj.Id, clUserObj.Id);
        Database.insert(accountShareObj, true);



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

        Map<String,Id> partyParamMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => borrowerPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        Map<String,Id> clPartyParamMap = new Map<String,Id>{
            'accountId' => clAccountObj.id,
            'contactId' => clcontactObj.id,
            'partyTypeId' => clPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(partyParamMap);

        Dealer_Applicant_Relationship__c dealerApplicantRelObj=ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.id);
        Database.insert(dealerApplicantRelObj,true);
        partyObj=ApplicationOriginationTestHelper.insertIndividualPartyDetails(partyObj,dealerApplicantRelObj.id);

        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(clPartyParamMap);
        partyObj.clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;
        clPartyObj.clcommon__Party_Types__c = PortalConstants.CL_PARTY_NAME;
        Database.insert(new List<clcommon__Party__c>{partyObj, clPartyObj },true);
    }


    /**
    * @description - Test validateApplicationData for Tax id Null for Corporation and CFA
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForGMKNullTaxId(){
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
        Account parentAccount = [SELECT Id,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =: accountList[0].ParentId
                                LIMIT 1];
        parentAccount.Coop_Type__c = 'Growmark';
        Database.update(parentAccount, true);

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
                                                                genesis__Tax_Identification_Number__c
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
                                                            Mobile_Number__c
                                                    FROM clcommon__party__c
                                                    WHERE clcommon__Account__c=:accountList[0].id];

        
        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_TAX_ID_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Tax id Blank for Corporation and CFA
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void validateAppCreationForGMKBlankTaxId(){
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
        Account parentAccount = [SELECT Id,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =: accountList[0].ParentId
                                LIMIT 1];
        parentAccount.Coop_Type__c = 'Growmark';
        Database.update(parentAccount, true);

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
                                                                genesis__Tax_Identification_Number__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];
        businessInfoList[0].genesis__Tax_Identification_Number__c = '';
        Database.update(businessInfoList, true);

        List<clcommon__Party__c> borrowerPartyList= [SELECT ID,
                                                            City__c,
                                                            State__c,
                                                            Street__c,
                                                            Postal_Code__c,
                                                            County__c,
                                                            Work_Number__c,
                                                            Home_Number__c,
                                                            Mobile_Number__c
                                                    FROM clcommon__party__c
                                                    WHERE clcommon__Account__c=:accountList[0].id];

        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_TAX_ID_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Account Id Existing Applicant
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
                                                                genesis__Tax_Identification_Number__c
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
                                                            Mobile_Number__c
                                                    FROM clcommon__party__c
                                                    WHERE clcommon__Account__c=:accountList[0].id];

        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_EXISTING_BORROWER_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Contact first name missing
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
                                            Confirm_SSN__c,
                                            HomePhone,
                                            Phone
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];
        contactList[0].FirstName = null;
        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c
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
                                                            Mobile_Number__c
                                                    FROM clcommon__party__c
                                                    WHERE clcommon__Account__c=:accountList[0].id];
        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_FIRST_NAME_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
    /**
    * @description - Test validateApplicationData for Contact first name missing
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
                                                                genesis__Tax_Identification_Number__c
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
                                                            Mobile_Number__c
                                                    FROM clcommon__party__c
                                                    WHERE clcommon__Account__c=:accountList[0].id];

        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORRROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_FIRST_NAME_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Null MailingStreet
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
        contactList[0].MailingStreet = null;

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c
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
                                                            Mobile_Number__c
                                                    FROM clcommon__party__c
                                                    WHERE clcommon__Account__c=:accountList[0].id];

        borrowerPartyList[0].Street__c=null;
        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_ADDRESS_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
    /**
    * @description - Test validateApplicationData for Blank Mailing Street
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
        contactList[0].MailingStreet = '';

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c
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
                                                            Mobile_Number__c
                                                    FROM clcommon__party__c
                                                    WHERE clcommon__Account__c=:accountList[0].id];
        borrowerPartyList[0].Street__c='';
        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_ADDRESS_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Null Mailing City
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
                                            Confirm_SSN__c,
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];

        contactList[0].MailingCity = null;

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c
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
                                                            Mobile_Number__c
                                                    FROM clcommon__party__c
                                                    WHERE clcommon__Account__c=:accountList[0].id];

        borrowerPartyList[0].City__c=null;
        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_CITY_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
    /**
    * @description - Test validateApplicationData for Blank Mailing City
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
                                            Confirm_SSN__c,
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];
        contactList[0].MailingCity = '';

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c
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
                                                            Mobile_Number__c
                                                    FROM clcommon__party__c
                                                    WHERE clcommon__Account__c=:accountList[0].id];

        borrowerPartyList[0].City__c='';
        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_CITY_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Null Mailing State
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
                                            Confirm_SSN__c,
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];

        contactList[0].MailingState = null;

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c
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
                                                            Mobile_Number__c
                                                    FROM clcommon__party__c
                                                    WHERE clcommon__Account__c=:accountList[0].id];
        borrowerPartyList[0].State__c=null;
        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_STATE_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
    /**
    * @description - Test validateApplicationData for Blank Mailing State
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
                                            Confirm_SSN__c,
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];
        contactList[0].MailingState = '';
        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c
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
                                                            Mobile_Number__c
                                                    FROM clcommon__party__c
                                                    WHERE clcommon__Account__c=:accountList[0].id];
        borrowerPartyList[0].State__c='';
        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_STATE_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Null Mailing County
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
                                            Confirm_SSN__c,
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];
        contactList[0].Mailing_County__c = null;

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c
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
                                                            Mobile_Number__c
                                                    FROM clcommon__party__c
                                                    WHERE clcommon__Account__c=:accountList[0].id];
        borrowerPartyList[0].County__c=null;
        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_COUNTY_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
    /**
    * @description - Test validateApplicationData for Blank Mailing County
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
                                            Confirm_SSN__c,
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];
        contactList[0].Mailing_County__c = '';

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c
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
                                                            Mobile_Number__c
                                                    FROM clcommon__party__c
                                                    WHERE clcommon__Account__c=:accountList[0].id];
        borrowerPartyList[0].County__c='';
        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_COUNTY_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Null Mailing Postal Code
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
                                            Confirm_SSN__c,
                                            HomePhone,
                                            Phone
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];

        contactList[0].MailingPostalCode = null;

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c
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
                                                            Mobile_Number__c
                                                    FROM clcommon__party__c
                                                    WHERE clcommon__Account__c=:accountList[0].id];
        borrowerPartyList[0].Postal_Code__c=null;
        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_ZIP_CODE_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
    /**
    * @description - Test validateApplicationData for Blank Mailing Postal Code
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
                                            Confirm_SSN__c,
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];

        contactList[0].MailingPostalCode = '';

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c
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
                                                            Mobile_Number__c
                                                    FROM clcommon__party__c
                                                    WHERE clcommon__Account__c=:accountList[0].id];
        borrowerPartyList[0].Postal_Code__c='';
        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_ZIP_CODE_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Invalid ZIP
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
                                            Confirm_SSN__c,
                                            HomePhone,
                                            Phone,
                                            Mailing_County__c
                                    FROM Contact
                                    WHERE Id =: applicationList[0].genesis__Contact__c  
                                    LIMIT 1];

        contactList[0].MailingPostalCode = '123456';

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                genesis__Total_Assets__c,
                                                                genesis__Total_Liabilities__c,
                                                                genesis__Tax_Identification_Number__c
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
        borrowerPartyList[0].Postal_Code__c='123456';
        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_ZIP_CODE_INVALID, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Null SSN for ShouldValidate SaveAndContinue
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
                                                                genesis__Tax_Identification_Number__c
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
                                                            Marital_status__c
                                                    FROM clcommon__party__c
                                                    WHERE clcommon__Account__c=:accountList[0].id];

        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_SSN_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
       /**
    * @description - Test validateApplicationData for Null Phone numbers for Corporation
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
                                                                genesis__Tax_Identification_Number__c
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
                                                            Mobile_Number__c
                                                    FROM clcommon__party__c
                                                    WHERE clcommon__Account__c=:accountList[0].id];
        borrowerPartyList[0].Work_Number__c=null;
        borrowerPartyList[0].Home_Number__c=null;
        borrowerPartyList[0].Mobile_Number__c=null;
        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_MOBILE_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Blank Phone numbers for Corporation
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
                                                                genesis__Tax_Identification_Number__c
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
                                                            Mobile_Number__c
                                                    FROM clcommon__party__c
                                                    WHERE clcommon__Account__c=:accountList[0].id];

        borrowerPartyList[0].Work_Number__c='';
        borrowerPartyList[0].Home_Number__c='';
        borrowerPartyList[0].Mobile_Number__c='';
        Map<String, Object> paramForValidationMap = new Map<String, Object>();
        paramForValidationMap.put('accountObj', accountList[0]);
        paramForValidationMap.put('contactObj', contactList[0]);
        paramForValidationMap.put('shouldValidate', shouldValidate);
        paramForValidationMap.put('applicationObj', applicationList[0]);
        paramForValidationMap.put('businessInfoObj', businessInfoList[0]);
        paramForValidationMap.put('BORROWER', borrowerPartyList[0]);
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.validateApplicationData(paramForValidationMap);  
            }catch(Exception e){
                System.assertEquals(PortalConstants.APPL_MOBILE_MISSING, e.getMessage(), PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
}