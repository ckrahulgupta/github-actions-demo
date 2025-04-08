/**
 * @description       : 
 * @author            : Tuhin Bhunia
 * @group             : 
 * @last modified on  : 01-14-2025
 * @last modified by  : Rakesh Saraf
**/
@isTest
public without sharing class PortalValidationUtilTest {
    /**
    * @description - Creating Test Data
    * @author Sk Minsar | 09-13-2024 
    **/
    @TestSetup
    static void makeData(){

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

        genesis__Business_Information__c businessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.Insert(businessInfoObj, true);
        
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoObj.Id, newPartnerProgramObj.Id);
        Database.Insert(dealerAccountObj, true);

        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInfoObj.Id, dealerAccountObj.Id);
        Database.Insert(clAccountObj, true);

        Contact clcontactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.Insert(clcontactObj, true);
        
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);

        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
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
        Database.insert(borrowerAccountObj,true);

        Account accountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(borrowerBusinessInfoObj.id,dealerAccountObj.id);
        Database.insert(accountObj,true);

        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        borrowerContactObj.MobilePhone = '9734227544';
        borrowerContactObj.HomePhone = '9734227544';
        borrowerContactObj.Phone = '9734227544';
        borrowerContactObj.Confirm_SSN__c = 'GHFB6766';
        Database.insert(borrowerContactObj,true);

        //Creating Role
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.CERTIFIED_LENDER); 
        Database.Insert(clRoleObj, true);

        // Creating Relationships
        clcommon__Relationship__c clDealerRealtionshipObj = TestClassHelper.createCLDealerRelationship(clRoleObj, 
                                                                                                        dealerAccountObj.Id, 
                                                                                                        clAccountObj.Id);
        Database.Insert(clDealerRealtionshipObj, true);

        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clcontactObj.Id);
        Database.Insert(clUserObj, true);

        clcommon__Collateral_Category__c collateralCategoryObj = ApplicationOriginationTestHelper.createCollateralCategory();
        Database.insert(collateralCategoryObj, true);

        Map<String,String> collateralDetailsMap = new Map<String,String>{
            'collateralCategoryId' => collateralCategoryObj.Id,
            'collateralName' => 'commodity',
            'totalAcres' => '40',
            'producerShare' => '75.5',
            'approvedYield' => '90',
            'insurancePlan' => 'RP',
            'percentCoverageLevel' => '85%',
            'percentFed' => '2',
            'price' => '12',
            'appId' => null
         };
        clcommon__collateral__c collateralObj = ApplicationOriginationTestHelper.createCollateral(collateralDetailsMap);
        Database.insert(collateralObj, true);

        Map<String,Object> applicationDataMap = new Map<String,Object>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'saAccountObjId' => accountObj.id
        };
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(applicationDataMap);
        applicationObj.genesis__Product_Type__c ='Package';
        applicationObj.Certified_Lender__c = clAccountObj.id;
        applicationObj.Internal_Reference_Code__c = 'Lucifer12345';
        applicationObj.genesis__Loan_Amount__c = 1000;
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
        
        Database.insert(borrowerPartyObj);
    }

    /**
    * @description method to get the collateral
    * @author Rakesh Saraf | 01-10-2025 
    * @return clcommon__collateral__c 
    **/
    private static clcommon__collateral__c getCollateral(){
        return [SELECT id, 
                        name,  
                        clcommon__Collateral_Category__c, 
                        Total_Acres__c,
                        Producer_Share_Percent__c,
                        Approved_Yield__c,
                        Insurance_Plan__c,
                        Percent_Fed__c,
                        Percent_Coverage_Level__c
                FROM clcommon__collateral__c 
                WHERE clcommon__Collateral_Name__c = 'commodity' LIMIT 1][0];
    }

    /**
    * @description method to get the collateral
    * @author Rakesh Saraf | 01-10-2025 
    * @return List<genesis__Applications__c> 
    **/
    private static List<genesis__Applications__c> getApplication(){
        return [SELECT Id,
                        genesis__Account__c,
                        genesis__Contact__c,
                        Internal_Reference_Code__c,
                        Years_Of_Business_With_Applicant__c,
                        Flex_Rate_Pricing__c,
                        Do_You_Recommend_This_Applicant__c 
                FROM genesis__Applications__c LIMIT 1];
    }

    /**
    * @description - Test isValidCropInformation With Null clcommon__Collateral_Category__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void validateComodityTest(){

        Boolean shouldValidate = false;
        Boolean shouldValidatePercentFed = false;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj = getCollateral();

        collateralObj.clcommon__Collateral_Category__c = null;

        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }
    
    /**
    * @description - Test isValidCropInformation With NULL Total_Acres__c
    * @author Tuhin Bhunia | 09-06-2024 
    **/
    @isTest
    private static void missingTotalAcresInCollateral(){

        Boolean shouldValidate = true;
        Boolean shouldValidatePercentFed = false;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj = getCollateral();
        collateralObj.Total_Acres__c = null;

        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test isValidCropInformation with negative value for Total_Acres__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void totalAcresValueInNegative(){

        Boolean shouldValidate = false;
        Boolean shouldValidatePercentFed = false;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj = getCollateral();
        collateralObj.Total_Acres__c = -50;

        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test isValidCropInformation with NULL value for Producer_Share_Percent__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void producersSharePercentMissing(){

        Boolean shouldValidate = true;
        Boolean shouldValidatePercentFed = false;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj =getCollateral();
        collateralObj.Producer_Share_Percent__c = null;

        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test isValidCropInformation with Decimal value for Producer_Share_Percent__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void invalidSharePercentage(){

        Boolean shouldValidate = true;
        Boolean shouldValidatePercentFed = false;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj =getCollateral();
        collateralObj.Producer_Share_Percent__c = 10.827383;

        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test isValidCropInformation with Negative value for Producer_Share_Percent__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void negativeSharePercentage(){

        Boolean shouldValidate = true;
        Boolean shouldValidatePercentFed = false;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj = getCollateral();
        collateralObj.Producer_Share_Percent__c = -10;

        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test isValidCropInformation with > 100% value for Producer_Share_Percent__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void invalidSharePercentageTwo(){

        Boolean shouldValidate = true;
        Boolean shouldValidatePercentFed = false;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj = getCollateral();
        collateralObj.Producer_Share_Percent__c = 120;

        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test isValidCropInformation with NULL value for Approved_Yield__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void approvedYieldMissing(){

        Boolean shouldValidate = true;
        Boolean shouldValidatePercentFed = false;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj = getCollateral();
        collateralObj.Approved_Yield__c = null;

        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test isValidCropInformation with Negative value for Approved_Yield__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void invalidApprovedYield(){

        Boolean shouldValidate = true;
        Boolean shouldValidatePercentFed = false;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj = getCollateral();
        collateralObj.Approved_Yield__c = -50;

        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test isValidCropInformation with NULL value for Insurance_Plan__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void insurancePlanMissing(){

        Boolean shouldValidate = true;
        Boolean shouldValidatePercentFed = false;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj =getCollateral();
        collateralObj.Insurance_Plan__c = null;

        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test isValidCropInformation with Blank value for Insurance_Plan__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void insurancePlanBlank(){

        Boolean shouldValidate = true;
        Boolean shouldValidatePercentFed = false;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj =getCollateral();
        collateralObj.Insurance_Plan__c = '';

        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test isValidCropInformation with Length > 50 (regex string validation)for Insurance_Plan__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void invalidInsurancePlanType(){

        Boolean shouldValidate = true;
        Boolean shouldValidatePercentFed = false;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj =getCollateral();
        collateralObj.Insurance_Plan__c = 'Test insurance plan for testing isValidCropInformation';
        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test isValidCropInformation with special character for Insurance_Plan__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void testInsurancePlanWithSpecialChar(){

        Boolean shouldValidate = true;
        Boolean shouldValidatePercentFed = false;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj = getCollateral();
        collateralObj.Insurance_Plan__c = '!%&()-_+.?a9';
        collateralObj.Producer_Share_Percent__c = 50;

        System.runAs(clUserObj){
            Test.startTest();
            Boolean result = PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(PortalConstants.TRUE_VALUE, result, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test isValidCropInformation with 'None' character for Insurance_Plan__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void testInsurancePlanNone(){

        Boolean shouldValidate = true;
        Boolean shouldValidatePercentFed = false;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj =getCollateral();
        collateralObj.Insurance_Plan__c = 'None';

        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test isValidCropInformation with blank value for Percent_Coverage_Level__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void percentCoverageValueIsBlank(){

        Boolean shouldValidate = true;
        Boolean shouldValidatePercentFed = false;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj =getCollateral();
        collateralObj.Producer_Share_Percent__c = 50;
        collateralObj.Percent_Coverage_Level__c = '';

        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test isValidCropInformation with NULL value for Percent_Coverage_Level__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void percentCoverageValueIsNull(){

        Boolean shouldValidate = true;
        Boolean shouldValidatePercentFed = false;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj =getCollateral();
        collateralObj.Producer_Share_Percent__c = 50;
        collateralObj.Percent_Coverage_Level__c = null;

        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test isValidCropInformation with Special character for Percent_Coverage_Level__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void percentCoverageValueWithSpecialChar(){

        Boolean shouldValidate = true;
        Boolean shouldValidatePercentFed = false;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj =getCollateral();
        collateralObj.Producer_Share_Percent__c = 50;
        collateralObj.Percent_Coverage_Level__c = '300000000000000000000000000000000000000000000000000000000000%';
        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test isValidCropInformation with NULL value for Percent_Fed__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void percentFedValueIsMissing(){

        Boolean shouldValidate = true;
        Boolean shouldValidatePercentFed = true;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj =getCollateral();

        collateralObj.Producer_Share_Percent__c = 50;
        collateralObj.Percent_Fed__c = null;

        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test isValidCropInformation with Negative value for Percent_Fed__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void negativePercentFedValue(){

        Boolean shouldValidate = true;
        Boolean shouldValidatePercentFed = true;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj =getCollateral();

        collateralObj.Producer_Share_Percent__c = 50;
        collateralObj.Percent_Fed__c = -50;

        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }
    
    /**
    * @description - Test isValidCropInformation with Greater value than 100% value for Percent_Fed__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void invalidPercentFedValue(){

        Boolean shouldValidate = true;
        Boolean shouldValidatePercentFed = true;
        clcommon.Response responseObj = new clcommon.Response();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__collateral__c collateralObj =getCollateral();

        collateralObj.Producer_Share_Percent__c = 50;
        collateralObj.Percent_Fed__c = 120;
        System.runAs(clUserObj){
            Test.startTest();
            PortalValidationUtil.isValidCropInformation(collateralObj, shouldValidate, shouldValidatePercentFed, responseObj);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test isValidApplicationSubmission With Null Internal_Reference_Code__c
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void validateSubmissionForInvalidIRC(){
        Boolean shouldValidate = PortalConstants.TRUE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationObjList = getApplication();
        applicationObjList[0].Internal_Reference_Code__c = null;
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.isValidApplicationSubmission(applicationObjList[0], shouldValidate);
            }catch(Exception ex){
                System.assert(ex!=null,'Assertion Fail');
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationSubmission With Null irc
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void validateSubmissionForBlankIRC(){
        Boolean shouldValidate = PortalConstants.TRUE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationObjList = getApplication();
        applicationObjList[0].Internal_Reference_Code__c = '';
        System.runAs(clUserObj){
            Test.startTest();
            
            try{
                PortalValidationUtil.isValidApplicationSubmission(applicationObjList[0], shouldValidate);
            }catch(Exception ex){
                System.assert(ex!=null,'Assertion Fail');
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationSubmission With long irc
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void validateSubmissionForLongIRC(){
        Boolean shouldValidate = PortalConstants.TRUE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationObjList = getApplication();

        applicationObjList[0].Internal_Reference_Code__c = 'TestIRC12343434343839378983938937493783937494749433';
        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.isValidApplicationSubmission(applicationObjList[0], shouldValidate);
            }catch(Exception ex){
                System.assert(ex!=null,'Assertion Fail');
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationSubmission 
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void validateSubmissionForSpecialCharIRC(){
        Boolean shouldValidate = PortalConstants.TRUE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationObjList =getApplication();

        applicationObjList[0].Internal_Reference_Code__c = '!%&()-_+.?a9';

        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.isValidApplicationSubmission(applicationObjList[0], shouldValidate);
            }catch(Exception ex){
                System.assert(ex!=null,'Assertion Fail');
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationSubmission With Null year of birth
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void validateSubmissionForNullYOB(){
        Boolean shouldValidate = PortalConstants.TRUE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationObjList = getApplication();
        applicationObjList[0].Years_Of_Business_With_Applicant__c = null;

        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.isValidApplicationSubmission(applicationObjList[0], shouldValidate);
            }catch(Exception ex){
                System.assert(ex!=null,'Assertion Fail');
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationSubmission With blank year of birth
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void validateSubmissionForBlankYOB(){
        Boolean shouldValidate = PortalConstants.TRUE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationObjList = getApplication();
        applicationObjList[0].Years_Of_Business_With_Applicant__c = '';

        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.isValidApplicationSubmission(applicationObjList[0], shouldValidate);
            }catch(Exception ex){
                System.assert(ex!=null,'Assertion Fail');
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationSubmission With decimal year of birth
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void validateSubmissionForDecimalYOB(){
        Boolean shouldValidate = PortalConstants.TRUE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationObjList = getApplication();
        
        applicationObjList[0].Years_Of_Business_With_Applicant__c = '5.5';

        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.isValidApplicationSubmission(applicationObjList[0], shouldValidate);
            }catch(Exception ex){
                System.assert(ex!=null,'Assertion Fail');
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationSubmission 
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void validateSubmissionForYOB(){
        Boolean shouldValidate = PortalConstants.TRUE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationObjList = getApplication();
        applicationObjList[0].Years_Of_Business_With_Applicant__c = '1-3 Years';

        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.isValidApplicationSubmission(applicationObjList[0], shouldValidate);
            }catch(Exception ex){
                System.assert(ex!=null,'Assertion Fail');
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationSubmission With long year of birth
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void validateSubmissionForLongYOB(){
        Boolean shouldValidate = PortalConstants.TRUE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationObjList = getApplication();
        
        applicationObjList[0].Years_Of_Business_With_Applicant__c = '123456789012345678901234567890123456789012345678901';

        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.isValidApplicationSubmission(applicationObjList[0], shouldValidate);
            }catch(Exception ex){
                System.assert(ex!=null,'Assertion Fail');
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationSubmission With flex rate
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void validateSubmissionForFlexRate(){
        Boolean shouldValidate = PortalConstants.TRUE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationObjList =getApplication();
        applicationObjList[0].Flex_Rate_Pricing__c = PortalConstants.TRUE_VALUE;

        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.isValidApplicationSubmission(applicationObjList[0], shouldValidate);
            }catch(Exception ex){
                System.assert(ex!=null,'Assertion Fail');
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationSubmission not for flex rate
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void validateSubmissionForNotFlexRate(){
        Boolean shouldValidate = PortalConstants.TRUE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationObjList = getApplication();
        
        applicationObjList[0].Flex_Rate_Pricing__c = PortalConstants.FALSE_VALUE;

        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.isValidApplicationSubmission(applicationObjList[0], shouldValidate);
            }catch(Exception ex){
                System.assert(ex!=null,'Assertion Fail');
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationSubmission for recommended
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void validateSubmissionForRecommend(){
        Boolean shouldValidate = PortalConstants.TRUE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationObjList = getApplication();
        applicationObjList[0].Do_You_Recommend_This_Applicant__c = 'Yes';

        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.isValidApplicationSubmission(applicationObjList[0], shouldValidate);
            }catch(Exception ex){
                System.assert(ex!=null,'Assertion Fail');
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationSubmission for not recommended
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void validateSubmissionForNotRecommend(){
        Boolean shouldValidate = PortalConstants.TRUE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationObjList = getApplication();
    
        applicationObjList[0].Do_You_Recommend_This_Applicant__c = 'No';

        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.isValidApplicationSubmission(applicationObjList[0], shouldValidate);
            }catch(Exception ex){
                System.assert(ex!=null,'Assertion Fail');
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationSubmission With Null for recommended value
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void validateSubmissionForNullRecommend(){
        Boolean shouldValidate = PortalConstants.TRUE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationObjList = getApplication();
        
        applicationObjList[0].Do_You_Recommend_This_Applicant__c = null;

        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.isValidApplicationSubmission(applicationObjList[0], shouldValidate);
            }catch(Exception ex){
                System.assert(ex!=null,'Assertion Fail');
            }
            Test.stopTest();
        }
    }

    /**
    * @description - Test isValidApplicationSubmission With blank for recommmended
    * @author Sk Minsar | 09-09-2024 
    **/
    @isTest
    private static void validateSubmissionForBlankRecommend(){
        Boolean shouldValidate = PortalConstants.TRUE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationObjList = getApplication();

        applicationObjList[0].Do_You_Recommend_This_Applicant__c = '';

        System.runAs(clUserObj){
            Test.startTest();
            try{
                PortalValidationUtil.isValidApplicationSubmission(applicationObjList[0], shouldValidate);
            }catch(Exception ex){
                System.assert(ex!=null,'Assertion Fail');
            }
            Test.stopTest();
        }
    }

}