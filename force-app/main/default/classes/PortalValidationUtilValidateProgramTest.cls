/**
 * @description       : Test class for PortalValidationUtil
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 01-20-2025
 * @last modified by  : Sk Minsar
**/

@isTest
public without sharing class PortalValidationUtilValidateProgramTest {

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

        //Create party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);
        Database.insert(borrowerPartyTypeObj,true);

        //Creating all Business Info
        genesis__Business_Information__c businessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.Insert(new List<genesis__Business_Information__c>{businessInfoObj, borrowerBusinessInfoObj, coBorrowerBusinessInfoObj}, true);

        // Creating All Accounts
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoObj.Id, newPartnerProgramObj.Id);
        Database.Insert(dealerAccountObj, true);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInfoObj.Id, dealerAccountObj.Id);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(legalEntityObj,coBorrowerBusinessInfoObj.id);
        Account saAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(businessInfoObj.id,dealerAccountObj.id);
        Account dealerCompany = LoanServicingTestHelper.createDealerAccount(businessInfoObj.Id);
        borrowerAccountObj.BillingCity = 'Kolkata';
        borrowerAccountObj.BillingState = 'WA';
        borrowerAccountObj.Billing_County__c = 'fghu';
        borrowerAccountObj.BillingStreet = 'Kolkata';
        borrowerAccountObj.BillingPostalCode = '12345';
        borrowerAccountObj.Work_Number__c = '1234567890';
        borrowerAccountObj.Home_Number__c = '1234567890';
        borrowerAccountObj.Phone = '123467890';
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.Insert(new List<Account>{clAccountObj, borrowerAccountObj, coBorrowerAccountObj, saAccountObj, dealerCompany}, true);
        
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
        User borrowerUserObj = ApplicationOriginationTestHelper.createCLUser(borrowerContactObj.id);
        User saUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(saContactObj.id);
        coBorrowerUserObj.UserName=coBorrowerAccountObj.clcommon__Email__c;
        borrowerUserObj.UserName=borrowerAccountObj.clcommon__Email__c;
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

        //Creating Rate Card Setup Header
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerCompany);
        Database.insert(objRateCardHeader,true);

        //Create additional dertermining factor
        genesis__Additional_Determining_Factor__c objDeterminingFactor = ApplicationOriginationTestHelper.createAdditionalFactorForProgram(objRateCardHeader);
        Database.insert(objDeterminingFactor, true);

        Map<String,Id> partyParamMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => borrowerPartyTypeObj.id,
            'applicationId' => applicationObj.id,
            'dealerApplicantRelationshipId' => borrowerRealtionObj.Id
        };

        //Create Borrower Party
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
    * @description - This method used to qury all the useful data to call the main class
    * @author Sk Minsar | 01-06-2025 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getDataMap(){

        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList = [ SELECT Id,
                                                                            Name, 
                                                                            Account__c, 
                                                                            CFA_Advantage_Rate__c, 
                                                                            genesis__Description__c, 
                                                                            Crop_Year__c, 
                                                                            Closing_Fee__c , 
                                                                            Field_Finance_Rate__c,
                                                                            genesis__End_Date__c,
                                                                            Payer_of_Loan_Closing_Fee__c,
                                                                            Loan_Fee_Advanced_On__c,
                                                                            Dealer_Participate_on_Closing_Fee__c,
                                                                            Portion_of_Fee_to_Cover__c,
                                                                            Account__r.Name,
                                                                            Account__r.Tier__c
                                                                        FROM genesis__Rate_Card_Setup_Header__c 
                                                                        WHERE Name = 'My Test Program 99'];

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

        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = [SELECT Id, 
                                                                        Name 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE id=:accountList[0].clcommon__Legal_Entity_Type__c];

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
            'objRateCardHeaderList' => objRateCardHeaderList[0],
            'applicationList' => applicationList,
            'accountList' => accountList,
            'contactList' => contactList,
            'objLegalEntityTypeList' => objLegalEntityTypeList,
            'businessInfoList' => businessInfoList,
            'partyList' => partyList
        };
    }

    /**
    * @description - Success scenario for validateFlexRateRequest
    * @author Sk Minsar | 09-13-2024 
    **/
    @isTest
    public static void testValidateFlexRateRequestSuccess() {
        Map<String, Object> dataMap = getDataMap();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        genesis__Rate_Card_Setup_Header__c objRateCardHeaderObj = (genesis__Rate_Card_Setup_Header__c)dataMap.get('objRateCardHeaderList');
        
        Map<String, Object> rateCardRequest = new Map<String, Object>{
            PortalConstants.FLEXPRICING => JSON.serialize(new Map<String, Object>{
                PortalConstants.FLEXPROGRAM => new Map<String, Object>{
                    PortalConstants.FIELD_CROP_YEAR => objRateCardHeaderObj.Crop_Year__c,
                    PortalConstants.FIELD_FS_IDX => 1.5,
                    PortalConstants.FIELD_CLOSING_FEE => objRateCardHeaderObj.Closing_Fee__c,
                    PortalConstants.FIELD_MATURITY_DATE => objRateCardHeaderObj.genesis__End_Date__c,
                    PortalConstants.FIELD_PAYER => objRateCardHeaderObj.Payer_of_Loan_Closing_Fee__c,
                    PortalConstants.FIELD_ADVANCEON => objRateCardHeaderObj.Loan_Fee_Advanced_On__c,
                    PortalConstants.FIELD_DEALER_PART => objRateCardHeaderObj.Dealer_Participate_on_Closing_Fee__c,
                    PortalConstants.FIELD_FEE_PORTION => objRateCardHeaderObj.Portion_of_Fee_to_Cover__c,
                    PortalConstants.FIELD_ID => objRateCardHeaderObj.Id
                }
            }),
            PortalConstants.KEY_SHOULD_VALIDATE => true
        };
        
        Map<String, Object> flexRatingJsonMap = new Map<String, Object>{
            PortalConstants.FLEXPROGRAM => new Map<String, Object>{
                PortalConstants.FIELD_CROP_YEAR => objRateCardHeaderObj.Crop_Year__c,
                PortalConstants.FIELD_FS_IDX => 1.5,
                PortalConstants.FIELD_CLOSING_FEE => objRateCardHeaderObj.Closing_Fee__c,
                PortalConstants.FIELD_MATURITY_DATE => objRateCardHeaderObj.genesis__End_Date__c,
                PortalConstants.FIELD_PAYER => objRateCardHeaderObj.Payer_of_Loan_Closing_Fee__c,
                PortalConstants.FIELD_ADVANCEON => objRateCardHeaderObj.Loan_Fee_Advanced_On__c,
                PortalConstants.FIELD_DEALER_PART => objRateCardHeaderObj.Dealer_Participate_on_Closing_Fee__c,
                PortalConstants.FIELD_FEE_PORTION => objRateCardHeaderObj.Portion_of_Fee_to_Cover__c,
                PortalConstants.FIELD_ID => objRateCardHeaderObj.Id
            }
        };

        System.runAs(clUserObj){
            Test.startTest();
                genesis__Rate_Card_Setup_Header__c result = PortalValidationUtil.validateFlexRateRequest(rateCardRequest, objRateCardHeader, flexRatingJsonMap);
                System.assertEquals('2025', result.Crop_Year__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Success scenario for validateFlexRateRequest by sales agent user
    * @author Sk Minsar | 09-13-2024 
    **/
    @isTest
    public static void testValidateFlexRateRequestBySaSuccess() {
        Map<String, Object> dataMap = getDataMap();
        User saUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Tony Stark');
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        genesis__Rate_Card_Setup_Header__c objRateCardHeaderObj = (genesis__Rate_Card_Setup_Header__c)dataMap.get('objRateCardHeaderList');
        
        Map<String, Object> rateCardRequest = new Map<String, Object>{
            PortalConstants.FLEXPRICING => JSON.serialize(new Map<String, Object>{
                PortalConstants.FLEXPROGRAM => new Map<String, Object>{
                    PortalConstants.FIELD_CROP_YEAR => objRateCardHeaderObj.Crop_Year__c,
                    PortalConstants.FIELD_FS_IDX => 1.5,
                    PortalConstants.FIELD_CLOSING_FEE => objRateCardHeaderObj.Closing_Fee__c,
                    PortalConstants.FIELD_MATURITY_DATE => objRateCardHeaderObj.genesis__End_Date__c,
                    PortalConstants.FIELD_PAYER => objRateCardHeaderObj.Payer_of_Loan_Closing_Fee__c,
                    PortalConstants.FIELD_ADVANCEON => objRateCardHeaderObj.Loan_Fee_Advanced_On__c,
                    PortalConstants.FIELD_DEALER_PART => objRateCardHeaderObj.Dealer_Participate_on_Closing_Fee__c,
                    PortalConstants.FIELD_FEE_PORTION => objRateCardHeaderObj.Portion_of_Fee_to_Cover__c,
                    PortalConstants.FIELD_ID => objRateCardHeaderObj.Id
                }
            }),
            PortalConstants.KEY_SHOULD_VALIDATE => true
        };
        
        Map<String, Object> flexRatingJsonMap = new Map<String, Object>{
            PortalConstants.FLEXPROGRAM => new Map<String, Object>{
                PortalConstants.FIELD_CROP_YEAR => objRateCardHeaderObj.Crop_Year__c,
                PortalConstants.FIELD_FS_IDX => 1.5,
                PortalConstants.FIELD_CLOSING_FEE => objRateCardHeaderObj.Closing_Fee__c,
                PortalConstants.FIELD_MATURITY_DATE => objRateCardHeaderObj.genesis__End_Date__c,
                PortalConstants.FIELD_PAYER => objRateCardHeaderObj.Payer_of_Loan_Closing_Fee__c,
                PortalConstants.FIELD_ADVANCEON => objRateCardHeaderObj.Loan_Fee_Advanced_On__c,
                PortalConstants.FIELD_DEALER_PART => objRateCardHeaderObj.Dealer_Participate_on_Closing_Fee__c,
                PortalConstants.FIELD_FEE_PORTION => objRateCardHeaderObj.Portion_of_Fee_to_Cover__c,
                PortalConstants.FIELD_ID => objRateCardHeaderObj.Id
            }
        };

        System.runAs(saUserObj){
            Test.startTest();
                genesis__Rate_Card_Setup_Header__c result = PortalValidationUtil.validateFlexRateRequest(rateCardRequest, objRateCardHeader, flexRatingJsonMap);
                System.assertEquals('2025', result.Crop_Year__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateFlexRateRequest for null Flex Program
    * @author Sk Minsar | 09-13-2024 
    **/
    @isTest
    public static void testValidateFlexRateRequestNullFlexProgramEx() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        Map<String, Object> rateCardRequest = new Map<String, Object>{
            PortalConstants.FLEXPRICING => JSON.serialize(new Map<String, Object>()),
            PortalConstants.KEY_SHOULD_VALIDATE => PortalConstants.TRUE_VALUE
        };
        Map<String, Object> flexRatingJsonMap = new Map<String, Object>();

        System.runAs(clUserObj){
            Test.startTest();
                try {
                    PortalValidationUtil.validateFlexRateRequest(rateCardRequest, objRateCardHeader, flexRatingJsonMap);
                } catch (Exception e) {
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Null total Assts Work_Number__c and null work phone numbers for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpNullTotalAssetsEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>) dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>) dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>) dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>) dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Total_Assets__c = -1234;
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].Work_Number__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateApplicationData(new Map<String, Object>{
                            PortalConstants.ACCOUNT_OBJ_KEY => accountList[0],
                            PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                            PortalConstants.KEY_SHOULD_VALIDATE => shouldValidate,
                            PortalConstants.APPLICATION_OBJ_KEY => applicationList[0],
                            PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                            PortalConstants.BORROWER_PARTY_NAME => borrowerPartyList[0]
                        }
                    ); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Null Total Liabilities and null home phone numbers for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpNullTotalLiabEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>) dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>) dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>) dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>) dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Total_Liabilities__c = -1000;
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].Home_Number__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateApplicationData(new Map<String, Object>{
                            PortalConstants.ACCOUNT_OBJ_KEY => accountList[0],
                            PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                            PortalConstants.KEY_SHOULD_VALIDATE => shouldValidate,
                            PortalConstants.APPLICATION_OBJ_KEY => applicationList[0],
                            PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                            PortalConstants.BORROWER_PARTY_NAME => borrowerPartyList[0]
                        }
                    ); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Null MobilePhone numbers & Total Liabilities Negative
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForNullMobilePhoneEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>) dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>) dataMap.get('contactList');
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>) dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Total_Liabilities__c = -1000;
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].Mobile_Number__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateApplicationData(new Map<String, Object>{
                            PortalConstants.ACCOUNT_OBJ_KEY => accountList[0],
                            PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                            PortalConstants.KEY_SHOULD_VALIDATE => shouldValidate,
                            PortalConstants.APPLICATION_OBJ_KEY => applicationList[0],
                            PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                            PortalConstants.BORROWER_PARTY_NAME => borrowerPartyList[0]
                        }
                    ); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Null Home Phone numbers & Total Liabilities Negative
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForNullHomePhoneEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>) dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>) dataMap.get('contactList');
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>) dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Total_Liabilities__c = -1000;
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].Home_Number__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateApplicationData(new Map<String, Object>{
                            PortalConstants.ACCOUNT_OBJ_KEY => accountList[0],
                            PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                            PortalConstants.KEY_SHOULD_VALIDATE => shouldValidate,
                            PortalConstants.APPLICATION_OBJ_KEY => applicationList[0],
                            PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                            PortalConstants.BORROWER_PARTY_NAME => borrowerPartyList[0]
                    });
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Not Null values for Phone numbers & Total Liabilities Negative
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForNotNullPhonesEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>) dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>) dataMap.get('contactList');
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>) dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Total_Liabilities__c = -1000;
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].Work_Number__c = '1234567890';
        borrowerPartyList[0].Home_Number__c = '1234567890';
        borrowerPartyList[0].Mobile_Number__c = '1234567890';

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateApplicationData(new Map<String, Object>{
                            PortalConstants.ACCOUNT_OBJ_KEY => accountList[0],
                            PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                            PortalConstants.KEY_SHOULD_VALIDATE => shouldValidate,
                            PortalConstants.APPLICATION_OBJ_KEY => applicationList[0],
                            PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                            PortalConstants.BORROWER_PARTY_NAME => borrowerPartyList[0]
                        }
                    ); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Null Phone numbers & Total Asset Negative
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForNullPhoneEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>) dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>) dataMap.get('contactList');
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>) dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Total_Assets__c = -1000;
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].Mobile_Number__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateApplicationData(new Map<String, Object>{
                            PortalConstants.ACCOUNT_OBJ_KEY => accountList[0],
                            PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                            PortalConstants.KEY_SHOULD_VALIDATE => shouldValidate,
                            PortalConstants.APPLICATION_OBJ_KEY => applicationList[0],
                            PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                            PortalConstants.BORROWER_PARTY_NAME => borrowerPartyList[0]
                        }
                    ); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Null Name for DBA
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForDBANullNameEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>) dataMap.get('accountList');
        accountList[0].Name = null;
        List<Contact> contactList = (List<Contact>) dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>) dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.INDIVIDUAL_ENTITY;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>) dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateApplicationData(new Map<String, Object>{
                            PortalConstants.ACCOUNT_OBJ_KEY => accountList[0],
                            PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                            PortalConstants.KEY_SHOULD_VALIDATE => shouldValidate,
                            PortalConstants.APPLICATION_OBJ_KEY => applicationList[0],
                            PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                            PortalConstants.BORROWER_PARTY_NAME => borrowerPartyList[0]
                        }
                    ); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Null Name for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpNullNameEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>) dataMap.get('accountList');
        accountList[0].Name = null;
        List<Contact> contactList = (List<Contact>) dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>) dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>) dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateApplicationData(new Map<String, Object>{
                            PortalConstants.ACCOUNT_OBJ_KEY => accountList[0],
                            PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                            PortalConstants.KEY_SHOULD_VALIDATE => shouldValidate,
                            PortalConstants.APPLICATION_OBJ_KEY => applicationList[0],
                            PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                            PortalConstants.BORROWER_PARTY_NAME => borrowerPartyList[0]
                        }
                    ); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Null BillingState for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpNullBillingStateEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>) dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>) dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>) dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>) dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].State__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateApplicationData(new Map<String, Object>{
                            PortalConstants.ACCOUNT_OBJ_KEY => accountList[0],
                            PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                            PortalConstants.KEY_SHOULD_VALIDATE => shouldValidate,
                            PortalConstants.APPLICATION_OBJ_KEY => applicationList[0],
                            PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                            PortalConstants.BORROWER_PARTY_NAME => borrowerPartyList[0]
                        }
                    ); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Null Tax Id for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpNullTaxIdEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>) dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>) dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>) dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>) dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Tax_Identification_Number__c = null;
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateApplicationData(new Map<String, Object>{
                        PortalConstants.ACCOUNT_OBJ_KEY => accountList[0],
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.KEY_SHOULD_VALIDATE => shouldValidate,
                        PortalConstants.APPLICATION_OBJ_KEY => applicationList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.BORROWER_PARTY_NAME => borrowerPartyList[0]
                        }
                    ); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Blank Name for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpBlankNameEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>) dataMap.get('accountList');
        accountList[0].Name = '';
        List<Contact> contactList = (List<Contact>) dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>) dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateApplicationData(new Map<String, Object>{
                        PortalConstants.ACCOUNT_OBJ_KEY => accountList[0],
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.KEY_SHOULD_VALIDATE => shouldValidate,
                        PortalConstants.APPLICATION_OBJ_KEY => applicationList[0],
                        PortalConstants.BORROWER_PARTY_NAME => borrowerPartyList[0]
                    }
                );  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Blank BillingState for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpBlankBillingStateEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>) dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>) dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>) dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>) dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].County__c = '';

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateApplicationData(new Map<String, Object>{
                            PortalConstants.ACCOUNT_OBJ_KEY => accountList[0],
                            PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                            PortalConstants.KEY_SHOULD_VALIDATE => shouldValidate,
                            PortalConstants.APPLICATION_OBJ_KEY => applicationList[0],
                            PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                            PortalConstants.BORROWER_PARTY_NAME => borrowerPartyList[0]
                        }
                    ); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidCoApplicantCreation for Negative assets
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testValidCoApplicantNegativeTotalAssetEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String saveType = PortalConstants.SAVE_AND_CONTINUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accountList = (List<Account>) dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>) dataMap.get('contactList');
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>) dataMap.get('businessInfoList');
        businessInfoList[0].genesis__Total_Assets__c = -6000;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.isValidCoApplicantCreation(new Map<String, Object>{
                        PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                        PortalConstants.ACCOUNT_OBJ_KEY =>  accountList[0],
                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                        PortalConstants.SAVE_TYPE_KEY => saveType
                        }
                    ); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateRateCardDetails for null setup description
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testRateCardDetailsNullDescriptionEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateRateCardDetails(null, new List<Object>{new Map<String, Object>{'Description' => 'Seeds'}, new Map<String, Object>{'Description' => 'Seeds'}, new Map<String, Object>{'Description' => 'Seeds'}, new Map<String, Object>{'Description' => 'Seeds'}, new Map<String, Object>{'Description' => 'Seeds'}, new Map<String, Object>{'Description' => 'Seeds'}, new Map<String, Object>{'Description' => 'Seeds'}, new Map<String, Object>{'Description' => 'Seeds'},new Map<String, Object>{'Description' => 'Seeds'}});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Blank SSN for shoudvalidate for save and continue
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForBlankSSNEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>) dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>) dataMap.get('contactList');
        contactList[0].genesis__SSN__c = '';
        contactList[0].Confirm_SSN__c = '';
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>) dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateApplicationData(new Map<String, Object>{
                            PortalConstants.ACCOUNT_OBJ_KEY => accountList[0],
                            PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                            PortalConstants.KEY_SHOULD_VALIDATE => shouldValidate,
                            PortalConstants.APPLICATION_OBJ_KEY => applicationList[0],
                            PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                            PortalConstants.BORROWER_PARTY_NAME => borrowerPartyList[0]
                        }
                    ); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Null Phone numbers
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForNullPhonesEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>) dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>) dataMap.get('contactList');
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>) dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].Work_Number__c = null;
        borrowerPartyList[0].Home_Number__c = null;
        borrowerPartyList[0].Mobile_Number__c = null;

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateApplicationData(new Map<String, Object>{
                            PortalConstants.ACCOUNT_OBJ_KEY => accountList[0],
                            PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                            PortalConstants.KEY_SHOULD_VALIDATE => shouldValidate,
                            PortalConstants.APPLICATION_OBJ_KEY => applicationList[0],
                            PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                            PortalConstants.BORROWER_PARTY_NAME => borrowerPartyList[0]
                        }
                    ); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateApplicationData for Null Billing County & Postal code of 9 Digit for Corporation
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testAppCreationForCorpBlankBillingCountyEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        String shouldValidate = 'SaveAndContinue';
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get('applicationList');
        List<Account> accountList = (List<Account>) dataMap.get('accountList');
        List<Contact> contactList = (List<Contact>) dataMap.get('contactList');
        List<clcommon__Legal_Entity__c> objLegalEntityTypeList = (List<clcommon__Legal_Entity__c>) dataMap.get('objLegalEntityTypeList');
        objLegalEntityTypeList[0].Name = PortalConstants.CORPORATION;                                                   
        Database.update(objLegalEntityTypeList, true);
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>) dataMap.get('businessInfoList');
        List<clcommon__Party__c> borrowerPartyList= (List<clcommon__Party__c>)dataMap.get('partyList');
        borrowerPartyList[0].Postal_Code__c = '123456789';
        borrowerPartyList[0].County__c = '';

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateApplicationData(new Map<String, Object>{
                            PortalConstants.ACCOUNT_OBJ_KEY => accountList[0],
                            PortalConstants.CONTACT_OBJ_KEY => contactList[0],
                            PortalConstants.KEY_SHOULD_VALIDATE => shouldValidate,
                            PortalConstants.APPLICATION_OBJ_KEY => applicationList[0],
                            PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoList[0],
                            PortalConstants.BORROWER_PARTY_NAME => borrowerPartyList[0]
                        }
                    ); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
}