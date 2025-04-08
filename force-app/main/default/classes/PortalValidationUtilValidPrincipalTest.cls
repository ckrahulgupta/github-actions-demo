/**
 * @description       : Test class of PortalValidationUtil
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 01-21-2025
 * @last modified by  : Sk Minsar
**/
@isTest
public without sharing class PortalValidationUtilValidPrincipalTest {
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
        User saUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(saContactObj.id);
        saUserObj.UserName=saAccountObj.clcommon__Email__c;
        Database.insert(new List<User>{clUserObj, saUserObj},true);
 
        //Creating Role
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.CERTIFIED_LENDER); 
        Database.Insert(clRoleObj, true);

        // Creating Relationships
        clcommon__Relationship__c clDealerRealtionshipObj = TestClassHelper.createCLDealerRelationship(clRoleObj, 
                                                                                                        dealerAccountObj.Id, 
                                                                                                        clAccountObj.Id);
        Database.Insert(clDealerRealtionshipObj, true);

        // Create Dealer Relationships 
        Dealer_Applicant_Relationship__c borrowerRealtionObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c principalRealtionObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(coBorrowerContactObj,dealerAccountObj.Id);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{borrowerRealtionObj, principalRealtionObj});

        //Create application
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

        //Create party
        Map<String,Id> partyParamMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => borrowerPartyTypeObj.id,
            'applicationId' => applicationObj.id,
            'dealerApplicantRelationshipId' => borrowerRealtionObj.Id
        };
        Map<String,Id> clPartyParamMap = new Map<String,Id>{
            'accountId' => clAccountObj.id,
            'contactId' => clcontactObj.id,
            'partyTypeId' => clPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(partyParamMap);
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(clPartyParamMap);
        clPartyObj.clcommon__Party_Types__c = PortalConstants.CL_PARTY_NAME;
        partyObj.clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;
        partyObj.City__c = 'Kolkata';
        partyObj.State__c = 'WA';
        partyObj.County__c = 'fghu';
        partyObj.Work_Number__c = '098765678';
        partyObj.Street__c = 'Kolkata';
        partyObj.Postal_Code__c = '12345';
        partyObj.Home_Number__c = '1234567890';
        partyObj.Mobile_Number__c = '123467890';
        Database.insert(new List<clcommon__Party__c>{partyObj, clPartyObj },true);
    }

    /**
    * @description - This method used to qury all the useful data
    * @author Sk Minsar | 01-09-2025 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getDataMap(){

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
        List<clcommon__Party__c> partyList = [SELECT ID,
                                                    City__c,
                                                    State__c,
                                                    Street__c,
                                                    Postal_Code__c,
                                                    County__c,
                                                    Work_Number__c,
                                                    Home_Number__c,
                                                    Mobile_Number__c
                                            FROM clcommon__party__c
                                            LIMIT 1];

        return new Map<String, Object>{
            'applicationList' => applicationList,
            'accountList' => accountList,
            'contactList' => contactList,
            'businessInfoList' => businessInfoList,
            'partyList' => partyList
        };
    }

    /**
    * @description - Test isValidCoApplicantCreation for Null Total Liabilities
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicantNullTotalLiab(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = PortalConstants.SAVE_AND_CONTINUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Total_Liabilities__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    }); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.FALSE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicantCreation for Negative Total Liabilities
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicantNegativeTotalLiabEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = PortalConstants.SAVE_AND_CONTINUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Total_Liabilities__c = -6000;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    }); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicantCreation for null phones
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicantNullPhonesEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = PortalConstants.SAVE_AND_CONTINUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        contactList[0].MobilePhone = null;
        contactList[0].HomePhone = null;
        contactList[0].Phone = null;
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    }); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicantCreation for Blank phones
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicantBlankPhonesEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = PortalConstants.SAVE_AND_CONTINUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        contactList[0].MobilePhone = '';
        contactList[0].HomePhone = '';
        contactList[0].Phone = '';
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    }); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test isValidCoApplicationCreation for null LastName
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicationNullLastNameEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = PortalConstants.SAVE_AND_CONTINUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        contactList[0].LastName = null;
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    }); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.FALSE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicationCreation for null Name
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicationNullNameEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = PortalConstants.SAVE_AND_CONTINUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        accountList[0].Name = null;
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    });   
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.FALSE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description - Test isValidCoApplicationCreation for null First Name
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicationNullFirstNameEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        contactList[0].FirstName = null;
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    });   
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicationCreation for null MailingStreet
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicationNullMailingStreetEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        contactList[0].MailingStreet = null;
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    });   
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description - Test isValidCoApplicationCreation for null Mailing County
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicationNullMailingCountyEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        contactList[0].Mailing_County__c = null;
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    });   
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description - Test isValidCoApplicationCreation for null MailingPostalCode
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicationNullPostalCodeEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        contactList[0].MailingPostalCode = null;
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    });   
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicationCreation for Invalid MailingPostalCode
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicationInvalidPostalCodeEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        contactList[0].MailingPostalCode = '123456';
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    });   
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicationCreation for null ssn and 5 digit postal code
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicationNullSSNEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        contactList[0].genesis__SSN__c = null;
        contactList[0].MailingPostalCode = '12345';
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    });   
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicationCreation for null birthdate and 9 digit postal code
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicationNullBirthDateEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        contactList[0].Birthdate = null;
        contactList[0].MailingPostalCode = '123456789';
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    });   
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicationCreation for Negative total Assets
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicationNegativeTotalAsstEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Total_Assets__c = -5000;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    });   
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicationCreation for Negative total Liabilities
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicationNegativeTotalLiabEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Total_Liabilities__c = -5000;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    });   
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description - Test isValidCoApplicationCreation for Null total Assets
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicationNullTotalAsstEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Total_Assets__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    });   
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.FALSE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicationCreation for Null total Liabilities
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicationNullTotalLiabEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Total_Liabilities__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    });   
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.FALSE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicationCreation for Null Phones
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicationNullPhonesEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        contactList[0].HomePhone = null;
        contactList[0].Phone = null;
        contactList[0].MobilePhone = null;
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    });   
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicationCreation for Blank Phones
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicationBlankPhonesEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>)dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>)dataMap.get('contactList');
        contactList[0].HomePhone = '';
        contactList[0].Phone = '';
        contactList[0].MobilePhone = '';
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>)dataMap.get('businessInfoList');
        
        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                    });   
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
}