/**
 * @description       : Test class of PortalValidationUtil
 * @author            : Rakesh Saraf
 * @group             : 
 * @last modified on  : 01-22-2025
 * @last modified by  : Sk Minsar
**/
@isTest
public without sharing class PortalValidationUtilValidCoAppTest {

    /**
    * @description 
    * @author Sk Minsar | 01-13-2025 
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
        User saUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(saContactObj.id);
        saUserObj.UserName=saAccountObj.clcommon__Email__c;
        Database.insert(new List<User>{clUserObj, saUserObj}, true);

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
    * @description get the application and applicant details
    * @author Rakesh Saraf | 11-17-2024 
    * @return Map<String, List<Object>> 
    **/
    private static Map<String,List<Object>> getDataMap(){
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

        return (new Map<String,List<Object>>{
                PortalConstants.APPLICATION_KEY=>applicationList,
                PortalConstants.ACCOUNT_KEY=>accountList,
                PortalConstants.CONTACT_KEY=>contactList,
                PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList
        });
    }


    /**
    * @description - Test isValidCoApplicantCreation success scenario
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    public static void testCoApplicantCreation(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        String saveType = 'existingApplicant';
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        List<genesis__Business_Information__c> businessInfoList =(List<genesis__Business_Information__c>) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{ 
                    PortalValidationUtil.isValidCoApplicant(new Map<String,Object>{
                                                                            PortalConstants.CONTACT_KEY=>contactList[0],
                                                                            PortalConstants.ACCOUNT_KEY=>accountList[0],
                                                                            PortalConstants.GENESIS_BUSINESS_INFORMATION_KEY=>businessInfoList[0],
                                                                            PortalConstants.SAVE_TYPE_KEY=>saveType
                                                                        });  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.FALSE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicantCreation for Last Name Null
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    public static void testCoApplicantNullLastname(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        String saveType = 'existingApplicant';
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        List<genesis__Business_Information__c> businessInfoList =(List<genesis__Business_Information__c>) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        contactList[0].LastName = null;

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicant(new Map<String,Object>{
                                                                            PortalConstants.CONTACT_KEY=>contactList[0],
                                                                            PortalConstants.ACCOUNT_KEY=>accountList[0],
                                                                            PortalConstants.GENESIS_BUSINESS_INFORMATION_KEY=>businessInfoList[0],
                                                                            PortalConstants.SAVE_TYPE_KEY=>saveType
                                                                        });              
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.FALSE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicantCreation Name null
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    public static void testCoApplicantNullName(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        String saveType = 'existingApplicant';
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        List<genesis__Business_Information__c> businessInfoList =(List<genesis__Business_Information__c>) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        accountList[0].Name = null;
        
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicant(new Map<String,Object>{
                                                                            PortalConstants.CONTACT_KEY=>contactList[0],
                                                                            PortalConstants.ACCOUNT_KEY=>accountList[0],
                                                                            PortalConstants.GENESIS_BUSINESS_INFORMATION_KEY=>businessInfoList[0],
                                                                            PortalConstants.SAVE_TYPE_KEY=>saveType
                                                                        });  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.FALSE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicantCreation for SSN NULL
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    public static void testCoApplicantNullSSNEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        String saveType = 'existingApplicant';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        List<genesis__Business_Information__c> businessInfoList =(List<genesis__Business_Information__c>) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        contactList[0].genesis__SSN__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicant(new Map<String,Object>{
                                                                            PortalConstants.CONTACT_KEY=>contactList[0],
                                                                            PortalConstants.ACCOUNT_KEY=>accountList[0],
                                                                            PortalConstants.GENESIS_BUSINESS_INFORMATION_KEY=>businessInfoList[0],
                                                                            PortalConstants.SAVE_TYPE_KEY=>saveType
                                                                        });   
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicantCreation for Confirm SSN NULL
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    public static void testCoApplicantNullConfirmSSNEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        String saveType = 'existingApplicant';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        List<genesis__Business_Information__c> businessInfoList =(List<genesis__Business_Information__c>) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        contactList[0].Confirm_SSN__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicant(new Map<String,Object>{
                                                                            PortalConstants.CONTACT_KEY=>contactList[0],
                                                                            PortalConstants.ACCOUNT_KEY=>accountList[0],
                                                                            PortalConstants.GENESIS_BUSINESS_INFORMATION_KEY=>businessInfoList[0],
                                                                            PortalConstants.SAVE_TYPE_KEY=>saveType
                                                                        });   
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicantCreation for first name null
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    public static void testCoApplicantNullFirstNameEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        String saveType = PortalConstants.SAVE_AND_CONTINUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        List<genesis__Business_Information__c> businessInfoList =(List<genesis__Business_Information__c>) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        contactList[0].FirstName = null;
        
        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicant(new Map<String,Object>{
                                                                            PortalConstants.CONTACT_KEY=>contactList[0],
                                                                            PortalConstants.ACCOUNT_KEY=>accountList[0],
                                                                            PortalConstants.GENESIS_BUSINESS_INFORMATION_KEY=>businessInfoList[0],
                                                                            PortalConstants.SAVE_TYPE_KEY=>saveType
                                                                        });  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicantCreation for Null Mailing Street
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    public static void testCoApplicantNullMailingStreetEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        String saveType = PortalConstants.SAVE_AND_CONTINUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        List<genesis__Business_Information__c> businessInfoList =(List<genesis__Business_Information__c>) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        contactList[0].MailingStreet = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicant(new Map<String,Object>{
                                                                            PortalConstants.CONTACT_KEY=>contactList[0],
                                                                            PortalConstants.ACCOUNT_KEY=>accountList[0],
                                                                            PortalConstants.GENESIS_BUSINESS_INFORMATION_KEY=>businessInfoList[0],
                                                                            PortalConstants.SAVE_TYPE_KEY=>saveType
                                                                        });    
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicantCreation for Null Mailing City
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    public static void testCoApplicantNullMailingCityEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        String saveType = PortalConstants.SAVE_AND_CONTINUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        List<genesis__Business_Information__c> businessInfoList =(List<genesis__Business_Information__c>) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        contactList[0].MailingCity = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicant(new Map<String,Object>{
                                                                            PortalConstants.CONTACT_KEY=>contactList[0],
                                                                            PortalConstants.ACCOUNT_KEY=>accountList[0],
                                                                            PortalConstants.GENESIS_BUSINESS_INFORMATION_KEY=>businessInfoList[0],
                                                                            PortalConstants.SAVE_TYPE_KEY=>saveType
                                                                        });   
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description - Test isValidCoApplicantCreation for Null MailingState
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    public static void testCoApplicantNullMailingStateEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        String saveType = PortalConstants.SAVE_AND_CONTINUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        List<genesis__Business_Information__c> businessInfoList =(List<genesis__Business_Information__c>) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        contactList[0].MailingState = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicant(new Map<String,Object>{
                                                                            PortalConstants.CONTACT_KEY=>contactList[0],
                                                                            PortalConstants.ACCOUNT_KEY=>accountList[0],
                                                                            PortalConstants.GENESIS_BUSINESS_INFORMATION_KEY=>businessInfoList[0],
                                                                            PortalConstants.SAVE_TYPE_KEY=>saveType
                                                                        });    
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicantCreation for Null Mailing County
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    public static void testCoApplicantNullMailingCountyEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        String saveType = PortalConstants.SAVE_AND_CONTINUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        List<genesis__Business_Information__c> businessInfoList =(List<genesis__Business_Information__c>) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        contactList[0].Mailing_County__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicant(new Map<String,Object>{
                                                                            PortalConstants.CONTACT_KEY=>contactList[0],
                                                                            PortalConstants.ACCOUNT_KEY=>accountList[0],
                                                                            PortalConstants.GENESIS_BUSINESS_INFORMATION_KEY=>businessInfoList[0],
                                                                            PortalConstants.SAVE_TYPE_KEY=>saveType
                                                                        });  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicantCreation for Null Mailing Postal Code
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    public static void testCoApplicantNullMailingPostalCodeEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        String saveType = PortalConstants.SAVE_AND_CONTINUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        List<genesis__Business_Information__c> businessInfoList =(List<genesis__Business_Information__c>) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        contactList[0].MailingPostalCode = null;
        
        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicant(new Map<String,Object>{
                                                                            PortalConstants.CONTACT_KEY=>contactList[0],
                                                                            PortalConstants.ACCOUNT_KEY=>accountList[0],
                                                                            PortalConstants.GENESIS_BUSINESS_INFORMATION_KEY=>businessInfoList[0],
                                                                            PortalConstants.SAVE_TYPE_KEY=>saveType
                                                                        });   
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicantCreation for Invalid Mailing Postal Code
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    public static void testCoApplicantInvalidMailingPostalCodeEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        String saveType = PortalConstants.SAVE_AND_CONTINUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        List<genesis__Business_Information__c> businessInfoList =(List<genesis__Business_Information__c>) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        contactList[0].MailingPostalCode = '123456';

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicant(new Map<String,Object>{
                                                                            PortalConstants.CONTACT_KEY=>contactList[0],
                                                                            PortalConstants.ACCOUNT_KEY=>accountList[0],
                                                                            PortalConstants.GENESIS_BUSINESS_INFORMATION_KEY=>businessInfoList[0],
                                                                            PortalConstants.SAVE_TYPE_KEY=>saveType
                                                                        });  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description when the legal entity of the account is null
    * @author Rakesh Saraf | 11-12-2024 
    **/
    @isTest
    public static void testDuplicateIndividualNullEntity(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        accountList[0].clcommon__Legal_Entity_Type__c=null;
        contactList[0].email=null;
        contactList[0].genesis__SSN__c=null;

        System.runAs(clUserObj){
            Test.startTest();
                Contact contactObj=PortalValidationUtil.validateDuplicateIndividual(contactList[0],accountList[0]);
                System.assertEquals(contactObj!=null, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description when the legal entity of the account is null along with the email
    * @author Rakesh Saraf | 11-12-2024 
    **/
    @isTest
    public static void testDuplicateIndividualNullEntityAndEmail(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        accountList[0].clcommon__Legal_Entity_Type__c=null;
        contactList[0].email=null;

        System.runAs(clUserObj){
            Test.startTest();
                Contact contactObj=PortalValidationUtil.validateDuplicateIndividual(contactList[0],accountList[0]);
                System.assertEquals(contactObj!=null, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description when the legal entity of the account is null and has an email and ssn
    * @author Rakesh Saraf | 11-12-2024 
    **/
    @isTest
    public static void testDuplicateIndividualEmailAndSSN(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        accountList[0].clcommon__Legal_Entity_Type__c=null;
        contactList[0].email=null;
        contactList[0].genesis__SSN__c='123234345';
        Database.update(contactList,true);
        contactList[0].email='null@yopmail.com';

        System.runAs(clUserObj){
            Test.startTest();
                Contact contactObj=PortalValidationUtil.validateDuplicateIndividual(contactList[0],accountList[0]);
                System.assertEquals(contactObj!=null, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description when the legal entity of the account is null and has a matching email and ssn
    * @author Rakesh Saraf | 11-12-2024 
    **/
    @isTest
    public static void testDuplicateIndividualMatchingEmailAndSSN(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        accountList[0].clcommon__Legal_Entity_Type__c=null;
        contactList[0].email='null@yopmail.com';
        contactList[0].genesis__SSN__c='123234345';
        Database.update(contactList,true);

        System.runAs(clUserObj){
            Test.startTest();
                Contact contactObj=PortalValidationUtil.validateDuplicateIndividual(contactList[0],accountList[0]);
                System.assertEquals(contactObj!=null, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description when the legal entity of the account is not null
    * @author Rakesh Saraf | 11-12-2024 
    **/
    @isTest
    public static void testDuplicateIndividualWithEntity(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        contactList[0].email=null;
        contactList[0].genesis__SSN__c=null;

        System.runAs(clUserObj){
            Test.startTest();
                Contact contactObj=PortalValidationUtil.validateDuplicateIndividual(contactList[0],accountList[0]);
                System.assertEquals(contactObj!=null, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description when the legal entity of the account is null along with the email
    * @author Rakesh Saraf | 11-12-2024 
    **/
    @isTest
    public static void testDuplicateIndividualWithEntityNullEmail(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        Id entityObjId=accountList[0].clcommon__Legal_Entity_Type__c;
        accountList[0].clcommon__Legal_Entity_Type__c=null;
        Database.update(accountList,true);
        accountList[0].clcommon__Legal_Entity_Type__c=entityObjId;
        contactList[0].email=null;

        System.runAs(clUserObj){
            Test.startTest();
                Contact contactObj=PortalValidationUtil.validateDuplicateIndividual(contactList[0],accountList[0]);
                System.assertEquals(contactObj!=null, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description when the legal entity of the account is null along with the email
    * @author Rakesh Saraf | 11-12-2024 
    **/
    @isTest
    public static void testDuplicateIndividualMatchingEntityType(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        contactList[0].email=null;

        System.runAs(clUserObj){
            Test.startTest();
                Contact contactObj=PortalValidationUtil.validateDuplicateIndividual(contactList[0],accountList[0]);
                System.assertEquals(contactObj!=null, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description when the legal entity of the account is null along with the email
    * @author Rakesh Saraf | 11-12-2024 
    **/
    @isTest
    public static void testDuplicateIndividual(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, List<Object>> paramMap=getDataMap();
        List<Account> accountList =( List<Account>) paramMap.get(PortalConstants.ACCOUNT_KEY);
        List<Contact> contactList = ( List<Contact>) paramMap.get(PortalConstants.CONTACT_KEY);
        Id entityObjId=accountList[0].clcommon__Legal_Entity_Type__c;
        accountList[0].clcommon__Legal_Entity_Type__c=null;
        Database.update(accountList,true);
        accountList[0].clcommon__Legal_Entity_Type__c=entityObjId;
        contactList[0].genesis__SSN__c='123234345';
        contactList[0].email=null;
        Database.update(contactList,true);
        contactList[0].email='null@yopmail.com';

        System.runAs(clUserObj){
            Test.startTest();
                Contact contactObj=PortalValidationUtil.validateDuplicateIndividual(contactList[0],accountList[0]);
                System.assertEquals(contactObj!=null, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description Test isValidApplicationSubmission With Null Internal_Reference_Code__c
    * @author Rakesh Saraf | 11-13-2024 
    **/
    @isTest
    public static void testSubmissionForInvalidIRC(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Boolean shouldValidate = PortalConstants.TRUE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationObjList = [SELECT Id,
                                                                    genesis__Account__c,
                                                                    genesis__Contact__c,
                                                                    Internal_Reference_Code__c,
                                                                    Years_Of_Business_With_Applicant__c,
                                                                    Flex_Rate_Pricing__c,
                                                                    Do_You_Recommend_This_Applicant__c 
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationObjList[0].Internal_Reference_Code__c = null;
        
        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidApplicationSubmission(applicationObjList[0], shouldValidate);
                }
                catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.FALSE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
}