/**
 * @description       : Test class of PortalValidationUtil
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 01-20-2025
 * @last modified by  : Sk Minsar
**/
@isTest
public without sharing class PortalValidationUtilValidateFlexRateTest {
    
    /**
    * @description - Creating test data
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
        Database.Insert(dealerAccountObj, true);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInfoObj.Id, dealerAccountObj.Id);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(legalEntityObj,coBorrowerBusinessInfoObj.id);
        Account saAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(businessInfoObj.id,dealerAccountObj.id);
        borrowerAccountObj.BillingCity = 'Kolkata';
        borrowerAccountObj.BillingState = 'WA';
        borrowerAccountObj.Billing_County__c = 'fghu';
        borrowerAccountObj.Work_Number__c = '098765678';
        borrowerAccountObj.BillingStreet = 'Kolkata';
        borrowerAccountObj.BillingPostalCode = '12345';
        borrowerAccountObj.Work_Number__c = '1234567890';
        borrowerAccountObj.Home_Number__c = '1234567890';
        borrowerAccountObj.Phone = '123467890';
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
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
        Database.insert(new List<User>{clUserObj, saUserObj},true);

        //Creating Role
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.CERTIFIED_LENDER); 
        Database.Insert(clRoleObj, true);

        // Creating Relationships
        clcommon__Relationship__c clDealerRealtionshipObj = TestClassHelper.createCLDealerRelationship(clRoleObj, 
                                                                                                        dealerAccountObj.Id, 
                                                                                                        clAccountObj.Id);
        Database.Insert(clDealerRealtionshipObj, true);

        //Create Application
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

        //Creating the dealer parent account
        Account dealerCompany = LoanServicingTestHelper.createDealerAccount(businessInfoObj.Id);
        Database.insert(dealerCompany, true);

        //Creating Rate Card Setup Header
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerCompany);
        Database.insert(objRateCardHeader,true);

        //Creating additional determining factor
        genesis__Additional_Determining_Factor__c objAdditionalFactor = ApplicationOriginationTestHelper.createAdditionalFactorForProgram(objRateCardHeader);
        genesis__Additional_Determining_Factor__c objDealerAdditionalFactor = ApplicationOriginationTestHelper.createAdditionalFactorForDealer(objRateCardHeader);
        Database.insert(new List<genesis__Additional_Determining_Factor__c>{objAdditionalFactor, objDealerAdditionalFactor}, true);
    }

    /**
    * @description - Test defaultFlexRateValidation for flex rate null
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testFlexRatePricingNullEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> flexRatingJsonMap = new Map<String, Object>();
        Map<String, Object> rateCardRequest = new Map<String, Object>{PortalConstants.FLEXPRICING => null,
                                                                      PortalConstants.KEY_SHOULD_VALIDATE => PortalConstants.TRUE_VALUE};
        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.defaultFlexRateValidation(rateCardRequest, flexRatingJsonMap); 
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test defaultFlexRateValidation for null shouldalidate
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testFlexRateShouldValidateNullEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> flexRatingJsonMap = new Map<String, Object>();
        Map<String, Object> rateCardRequest = new Map<String, Object>{PortalConstants.FLEXPRICING => flexRatingJsonMap,
                                                                      PortalConstants.KEY_SHOULD_VALIDATE => null};
        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.defaultFlexRateValidation(rateCardRequest, flexRatingJsonMap);  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test defaultFlexRateValidation for shouldValidate true
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testFlexRateNotNull(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> flexRatingJsonMap = new Map<String, Object>{'flexRateProgram' => null};
        Map<String, Object> rateCardRequest = new Map<String, Object>{PortalConstants.FLEXPRICING => JSON.serialize(flexRatingJsonMap),
                                                                      PortalConstants.KEY_SHOULD_VALIDATE => PortalConstants.TRUE_VALUE};
        System.runAs(clUserObj){
            Test.startTest();
                Map<String, Object> result = PortalValidationUtil.defaultFlexRateValidation(rateCardRequest, flexRatingJsonMap);  
                System.assertEquals(flexRatingJsonMap, result, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateMyProgramRequest method for success scenario
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testMyProgramRequest(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put(PortalConstants.FIELD_MATURITY_DATE, '2025-04-15');
        program.put(PortalConstants.FIELD_ID, 'new_record_id');
        program.put(PortalConstants.FIELD_NAME, 'GMK My Program - 110');
        program.put(PortalConstants.FIELD_CROP_YEAR, '2025');
        program.put(PortalConstants.FIELD_FS_IDX, 8.75);
        program.put(PortalConstants.FIELD_CLOSING_FEE, 0);
        program.put(PortalConstants.FIELD_PAYER, 'Grower');
        program.put(PortalConstants.FIELD_ADVANCEON, 'A');
        program.put(PortalConstants.FIELD_DEALER_PART, 'No');
        request.put(PortalConstants.PROGRAM, JSON.serialize(program));

        System.runAs(clUserObj){
            Test.startTest();
                genesis__Rate_Card_Setup_Header__c result = PortalValidationUtil.validateMyProgramRequest(request);  
                System.assertEquals(PortalConstants.TRUE_VALUE, result != null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateMyProgramRequest for null program
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testMyProgramRequestNullProgramEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();
        
        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateMyProgramRequest(request);  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateMyProgramRequest for null crop year
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testMyProgramRequestNullCropYearEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put(PortalConstants.FIELD_MATURITY_DATE, '2025-04-15');
        program.put(PortalConstants.FIELD_ID, 'new_record_id');
        program.put(PortalConstants.FIELD_NAME, 'GMK My Program - 110');
        program.put(PortalConstants.FIELD_CROP_YEAR, null);
        program.put(PortalConstants.FIELD_FS_IDX, 8.75);
        program.put(PortalConstants.FIELD_CLOSING_FEE, 0);
        program.put(PortalConstants.FIELD_PAYER, 'Grower');
        program.put(PortalConstants.FIELD_ADVANCEON, 'A');
        program.put(PortalConstants.FIELD_DEALER_PART, 'No');
        request.put(PortalConstants.PROGRAM, JSON.serialize(program));
        
        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateMyProgramRequest(request);  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test validateMyProgramRequest for null Name
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testMyProgramRequestNullNameEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put(PortalConstants.FIELD_MATURITY_DATE, '2025-04-15');
        program.put(PortalConstants.FIELD_ID, 'new_record_id');
        program.put(PortalConstants.FIELD_NAME, null);
        program.put(PortalConstants.FIELD_CROP_YEAR, '2025');
        program.put(PortalConstants.FIELD_FS_IDX, 8.75);
        program.put(PortalConstants.FIELD_CLOSING_FEE, 0);
        program.put(PortalConstants.FIELD_PAYER, 'Grower');
        program.put(PortalConstants.FIELD_ADVANCEON, 'A');
        program.put(PortalConstants.FIELD_DEALER_PART, 'No');
        request.put(PortalConstants.PROGRAM, JSON.serialize(program));

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateMyProgramRequest(request);  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateMyProgramRequest for null program
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testMyProgramRequestNullMaturityDateEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put(PortalConstants.FIELD_MATURITY_DATE, null);
        program.put(PortalConstants.FIELD_ID, 'new_record_id');
        program.put(PortalConstants.FIELD_NAME, 'GMK My Program - 110');
        program.put(PortalConstants.FIELD_CROP_YEAR, '2025');
        program.put(PortalConstants.FIELD_FS_IDX, 8.75);
        program.put(PortalConstants.FIELD_CLOSING_FEE, 0);
        program.put(PortalConstants.FIELD_PAYER, 'Grower');
        program.put(PortalConstants.FIELD_ADVANCEON, 'A');
        program.put(PortalConstants.FIELD_DEALER_PART, 'No');
        request.put(PortalConstants.PROGRAM, JSON.serialize(program));

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateMyProgramRequest(request);  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description - Test validateMyProgramRequest for null Payer
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testMyProgramRequestNullPayerEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put(PortalConstants.FIELD_MATURITY_DATE, '2025-04-15');
        program.put(PortalConstants.FIELD_ID, 'new_record_id');
        program.put(PortalConstants.FIELD_NAME, 'GMK My Program - 110');
        program.put(PortalConstants.FIELD_CROP_YEAR, '2025');
        program.put(PortalConstants.FIELD_FS_IDX, 8.75);
        program.put(PortalConstants.FIELD_CLOSING_FEE, 0);
        program.put(PortalConstants.FIELD_PAYER, null);
        program.put(PortalConstants.FIELD_ADVANCEON, 'A');
        program.put(PortalConstants.FIELD_DEALER_PART, 'No');
        request.put(PortalConstants.PROGRAM, JSON.serialize(program));

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateMyProgramRequest(request);  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateMyProgramRequest for null Id
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testMyProgramRequestNullIdEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put(PortalConstants.FIELD_MATURITY_DATE, '2025-04-15');
        program.put(PortalConstants.FIELD_ID, null);
        program.put(PortalConstants.FIELD_NAME, 'GMK My Program - 110');
        program.put(PortalConstants.FIELD_CROP_YEAR, '2025');
        program.put(PortalConstants.FIELD_FS_IDX, 8.75);
        program.put(PortalConstants.FIELD_CLOSING_FEE, 0);
        program.put(PortalConstants.FIELD_PAYER, 'Grower');
        program.put(PortalConstants.FIELD_ADVANCEON, 'A');
        program.put(PortalConstants.FIELD_DEALER_PART, 'No');
        request.put(PortalConstants.PROGRAM, JSON.serialize(program));

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateMyProgramRequest(request);  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateMyProgramRequest for null loan fee advance on
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testMyProgramRequestNullAdvanceEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put(PortalConstants.FIELD_MATURITY_DATE, '2025-04-15');
        program.put(PortalConstants.FIELD_ID, 'new_record_id');
        program.put(PortalConstants.FIELD_NAME, 'GMK My Program - 110');
        program.put(PortalConstants.FIELD_CROP_YEAR, '2025');
        program.put(PortalConstants.FIELD_FS_IDX, 8.75);
        program.put(PortalConstants.FIELD_CLOSING_FEE, 0);
        program.put(PortalConstants.FIELD_PAYER, 'Grower');
        program.put(PortalConstants.FIELD_ADVANCEON, null);
        program.put(PortalConstants.FIELD_DEALER_PART, 'No');
        request.put(PortalConstants.PROGRAM, JSON.serialize(program));

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateMyProgramRequest(request);  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateMyProgramRequest for null Dealer_Participate_on_Closing_Fee__c
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testMyProgramRequestNullDealerPartEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put(PortalConstants.FIELD_MATURITY_DATE, '2025-04-15');
        program.put(PortalConstants.FIELD_ID, 'new_record_id');
        program.put(PortalConstants.FIELD_NAME, 'GMK My Program - 110');
        program.put(PortalConstants.FIELD_CROP_YEAR, '2025');
        program.put(PortalConstants.FIELD_FS_IDX, 8.75);
        program.put(PortalConstants.FIELD_CLOSING_FEE, 0);
        program.put(PortalConstants.FIELD_PAYER, 'Grower');
        program.put(PortalConstants.FIELD_ADVANCEON, 'A');
        program.put(PortalConstants.FIELD_DEALER_PART, null);
        request.put(PortalConstants.PROGRAM, JSON.serialize(program));

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateMyProgramRequest(request);  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateMyProgramRequest for null Portion_of_Fee_to_Cover__c
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testMyProgramRequestNullPortionCoverEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put(PortalConstants.FIELD_MATURITY_DATE, '2025-04-15');
        program.put(PortalConstants.FIELD_ID, 'new_record_id');
        program.put(PortalConstants.FIELD_NAME, 'GMK My Program - 110');
        program.put(PortalConstants.FIELD_CROP_YEAR, '2025');
        program.put(PortalConstants.FIELD_FS_IDX, 8.75);
        program.put(PortalConstants.FIELD_CLOSING_FEE, 0);
        program.put(PortalConstants.FIELD_PAYER, 'Grower');
        program.put(PortalConstants.FIELD_ADVANCEON, 'A');
        program.put(PortalConstants.FIELD_DEALER_PART, 'Yes');
        program.put(PortalConstants.FIELD_FEE_PORTION, null);
        request.put(PortalConstants.PROGRAM, JSON.serialize(program));

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateMyProgramRequest(request);  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test nullCheckForFlexRateRequest for null crop year
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testNullCheckFlexRateNullCropYearEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> program = new Map<String, Object>();
        program.put(PortalConstants.FIELD_MATURITY_DATE, '2025-04-15');
        program.put(PortalConstants.FIELD_ID, 'new_record_id');
        program.put(PortalConstants.FIELD_NAME, 'GMK My Program - 110');
        program.put(PortalConstants.FIELD_CROP_YEAR, null);
        program.put(PortalConstants.FIELD_FS_IDX, 8.75);
        program.put(PortalConstants.FIELD_CLOSING_FEE, 0);
        program.put(PortalConstants.FIELD_PAYER, 'Grower');
        program.put(PortalConstants.FIELD_ADVANCEON, 'A');
        program.put(PortalConstants.FIELD_DEALER_PART, 'Yes');
        program.put(PortalConstants.FIELD_FEE_PORTION, 'No');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.nullCheckForFlexRateRequest(program);  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test nullCheckForFlexRateRequest for null maturity date
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testNullCheckFlexRateNullMaturityEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> program = new Map<String, Object>();
        program.put(PortalConstants.FIELD_MATURITY_DATE, null);
        program.put(PortalConstants.FIELD_ID, 'new_record_id');
        program.put(PortalConstants.FIELD_NAME, 'GMK My Program - 110');
        program.put(PortalConstants.FIELD_CROP_YEAR, '2025');
        program.put(PortalConstants.FIELD_FS_IDX, 8.75);
        program.put(PortalConstants.FIELD_CLOSING_FEE, 0);
        program.put(PortalConstants.FIELD_PAYER, 'Grower');
        program.put(PortalConstants.FIELD_ADVANCEON, 'A');
        program.put(PortalConstants.FIELD_DEALER_PART, 'Yes');
        program.put(PortalConstants.FIELD_FEE_PORTION, 'No');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.nullCheckForFlexRateRequest(program);  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test nullCheckForFlexRateRequest for null Payer
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testNullCheckFlexRateNullPayerEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> program = new Map<String, Object>();
        program.put(PortalConstants.FIELD_MATURITY_DATE, '2025-04-15');
        program.put(PortalConstants.FIELD_ID, 'new_record_id');
        program.put(PortalConstants.FIELD_NAME, 'GMK My Program - 110');
        program.put(PortalConstants.FIELD_CROP_YEAR, '2025');
        program.put(PortalConstants.FIELD_FS_IDX, 8.75);
        program.put(PortalConstants.FIELD_CLOSING_FEE, 0);
        program.put(PortalConstants.FIELD_PAYER,null);
        program.put(PortalConstants.FIELD_ADVANCEON, 'A');
        program.put(PortalConstants.FIELD_DEALER_PART, 'Yes');
        program.put(PortalConstants.FIELD_FEE_PORTION, 'No');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.nullCheckForFlexRateRequest(program);  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test nullCheckForFlexRateRequest for null Loan Advance Fee
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testNullCheckFlexRateNullAdvanceEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> program = new Map<String, Object>();
        program.put(PortalConstants.FIELD_MATURITY_DATE, '2025-04-15');
        program.put(PortalConstants.FIELD_ID, 'new_record_id');
        program.put(PortalConstants.FIELD_NAME, 'GMK My Program - 110');
        program.put(PortalConstants.FIELD_CROP_YEAR, '2025');
        program.put(PortalConstants.FIELD_FS_IDX, 8.75);
        program.put(PortalConstants.FIELD_CLOSING_FEE, 0);
        program.put(PortalConstants.FIELD_PAYER,'Grower');
        program.put(PortalConstants.FIELD_ADVANCEON, null);
        program.put(PortalConstants.FIELD_DEALER_PART, 'Yes');
        program.put(PortalConstants.FIELD_FEE_PORTION, 'No');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.nullCheckForFlexRateRequest(program);  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test nullCheckForFlexRateRequest for null Dealer Portion
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testNullCheckFlexRateNullDealerPortionEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> program = new Map<String, Object>();
        program.put(PortalConstants.FIELD_MATURITY_DATE, '2025-04-15');
        program.put(PortalConstants.FIELD_ID, 'new_record_id');
        program.put(PortalConstants.FIELD_NAME, 'GMK My Program - 110');
        program.put(PortalConstants.FIELD_CROP_YEAR, '2025');
        program.put(PortalConstants.FIELD_FS_IDX, 8.75);
        program.put(PortalConstants.FIELD_CLOSING_FEE, 0);
        program.put(PortalConstants.FIELD_PAYER,'Grower');
        program.put(PortalConstants.FIELD_ADVANCEON, 'A');
        program.put(PortalConstants.FIELD_DEALER_PART, null);
        program.put(PortalConstants.FIELD_FEE_PORTION, 'No');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.nullCheckForFlexRateRequest(program);  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test nullCheckForFlexRateRequest for null Field Fee Portion
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testNullCheckFlexRateNullFeePortionEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> program = new Map<String, Object>();
        program.put(PortalConstants.FIELD_MATURITY_DATE, '2025-04-15');
        program.put(PortalConstants.FIELD_ID, 'new_record_id');
        program.put(PortalConstants.FIELD_NAME, 'GMK My Program - 110');
        program.put(PortalConstants.FIELD_CROP_YEAR, '2025');
        program.put(PortalConstants.FIELD_FS_IDX, 8.75);
        program.put(PortalConstants.FIELD_CLOSING_FEE, 0);
        program.put(PortalConstants.FIELD_PAYER,'Grower');
        program.put(PortalConstants.FIELD_ADVANCEON, 'A');
        program.put(PortalConstants.FIELD_DEALER_PART, 'Yes');
        program.put(PortalConstants.FIELD_FEE_PORTION, null);

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.nullCheckForFlexRateRequest(program);  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test nullCheckForFlexRateRequest for null Field Fee Portion by sales agent user
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testNullCheckFlexRateNullFeePortionBySaEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User saUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Tony Stark');
        Map<String, Object> program = new Map<String, Object>();
        program.put(PortalConstants.FIELD_MATURITY_DATE, '2025-04-15');
        program.put(PortalConstants.FIELD_ID, 'new_record_id');
        program.put(PortalConstants.FIELD_NAME, 'GMK My Program - 110');
        program.put(PortalConstants.FIELD_CROP_YEAR, '2025');
        program.put(PortalConstants.FIELD_FS_IDX, 8.75);
        program.put(PortalConstants.FIELD_CLOSING_FEE, 0);
        program.put(PortalConstants.FIELD_PAYER,'Grower');
        program.put(PortalConstants.FIELD_ADVANCEON, 'A');
        program.put(PortalConstants.FIELD_DEALER_PART, 'Yes');
        program.put(PortalConstants.FIELD_FEE_PORTION, null);

        System.runAs(saUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.nullCheckForFlexRateRequest(program);  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateDeterminingFactors for null Determining Factors
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testDeterminingFactorNullEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = [SELECT Id, Account.ParentId, Account.Parent.Name  FROM User WHERE UserName='ross.geller@yopmail.com' LIMIT 1];
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
        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateDeterminingFactors(objRateCardHeaderList[0], new List<User>{clUserObj});  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.FALSE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateDeterminingFactors for null Determining Factors
    * @author Sk Minsar | 09-10-2024 
    **/
    @isTest
    public static void testDeterminingFactorNullDealerEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalValidationUtil.validateDeterminingFactors(new genesis__Rate_Card_Setup_Header__c(), new List<User>());  
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(isExceptionThrown, PortalConstants.TRUE_VALUE, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
}