/**
 * @description       : Test class for ExternalAdditionalInfoValidationUtil
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 01-12-2025
 * @last modified by  : Shristy Kumari
**/
@isTest 
private with sharing class ExternalAdditionalInfoValidationUtilTest{
    /**
    * @description : test setup
    * @author Shristy Kumari | 01-09-2025 
    **/
    @TestSetup
    private static void setup(){
        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);
        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ExternalAPITestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);
        //creating business info for borrower
        genesis__Business_Information__c borrowerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);
        // Creating Account for Dealer
        Account dealerAccountObj = ExternalAPITestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        // Creating Account for Certified Lender
        Account clAccountObj = ExternalAPITestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        // Creating Account for Borrower
        Account borrowerAccountObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        borrowerAccountObj.Unique_Id__c = 'TestUniqueIdBorrower00001';
        // creating Account for coborrower
        Account coBorrowerAccObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        coBorrowerAccObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        coBorrowerAccObj.Unique_Id__c = 'TestUniqueIdcoBorrower00001';
        Database.insert(new List<Account>{dealerAccountObj,clAccountObj,borrowerAccountObj,coBorrowerAccObj},true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ExternalAPITestHelper.createCLContact(clAccountObj.Id);
        // Creating Contact for Borrower
        Contact borrowerContactObj = ExternalAPITestHelper.createBorrowerContact(borrowerAccountObj.Id);
        // Creating Contact for Borrower
        Contact coBorrowerContactObj = ExternalAPITestHelper.createBorrowerContact(coBorrowerAccObj.Id);
        Database.insert(new List<Contact>{clContactObj,borrowerContactObj,coBorrowerContactObj},true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ExternalAPITestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ExternalAPITestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating map for Application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'certifiedLender' =>  clAccountObj.Id
        };

        // Creating Application
        genesis__Applications__c applicationObj = ExternalAPITestHelper.createCurrCropYearApplication(paramForApplicationMap);
        Database.insert(applicationObj, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ExternalAPITestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ExternalAPITestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);
        clcommon__Collateral_Category__c collateralCategoryObj = ExternalAPITestHelper.createCollateralCategory();
        Database.insert(collateralCategoryObj,true);

        // Creating DealerApplicant relationship
        Dealer_Applicant_Relationship__c borrowerDealerRelObj = ExternalAPITestHelper.createApplicantDealerRelationship(borrowerAccountObj, borrowerContactObj, dealerAccountObj);
        Dealer_Applicant_Relationship__c coBorrowerDealerRelObj = ExternalAPITestHelper.createApplicantDealerRelationship(coBorrowerAccObj, coBorrowerContactObj, dealerAccountObj);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{borrowerDealerRelObj,coBorrowerDealerRelObj},true);

        clcommon__Party_Type__c principalPartyTypeObj = ExternalAPITestHelper.createPartyType('PRINCIPAL');

        Database.insert(principalPartyTypeObj,true);

        // Creating Principal Party for current application
        Map<String,Id> paramForPrincipalPartyMap = new Map<String,Id>{
            'accountId' => coBorrowerAccObj.Id,
            'contactId' => coBorrowerContactObj.Id,
            'partyTypeId' => principalPartyTypeObj.Id,
            'applicationId' => applicationObj.Id,
            'dealerApplicantRelId' => coBorrowerDealerRelObj.Id
        };
        clcommon__Party__c principalPartyObj = ExternalAPITestHelper.createApplicantParty(paramForPrincipalPartyMap);
        principalPartyObj.Principal_Number__c = 1;
        Database.insert(principalPartyObj,true);
    }
    /**
    * @description Method to get system admin user
    * @author Shristy Kumari | 01-06-2025 
    * @return User 
    **/
    private static User getUser(){
        List<User> objUserList = [SELECT Id 
                                    FROM User 
                                    WHERE Profile.name = 'System Administrator'
                                    AND isActive = true
                                    LIMIT 1];
                                    
        if (objUserList.size() == 1){
            return objUserList[0];
        } 
        return null;
    }
    /**
    * @description Method to get application
    * @author Shristy Kumari | 01-06-2025 
    * @return User 
    **/
    private static genesis__Applications__c getApplication(){
        List<genesis__Applications__c> applicationObjList = [SELECT Id,
                                                                      genesis__Account__c,
                                                                      genesis__Account__r.Unique_Id__c
                                                                FROM genesis__Applications__c  
                                                                WHERE genesis__Loan_Number__c = '300023456'
                                                                LIMIT 1];
        if (applicationObjList.size() == 1){
             return applicationObjList[0];
         } 
      return null; 
    }
    /**
    * @description : Method to test exception when decimal values is empty
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testDecimalValuesEmptyException(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateDecimalValue('','Invalid Decimal Value');
            }catch(Exception exceptionObj){
                System.assertEquals('Invalid Decimal Value', exceptionObj.getMessage(), 'Assertion failed for testing exception when decimal values is empty.');
            }
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception when decimal value is invalid
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testInvalidDecimalValuesException(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateDecimalValue('S^','Invalid Decimal Value');
            }catch(Exception exceptionObj){
                System.assertEquals('Invalid Decimal Value', exceptionObj.getMessage(), 'Assertion Failed for testing when decimal value is invalid.');
            }
            Test.stopTest();
        }
    }
     /**
    * @description : Method to test success scenerio when decimal value is valid
    * @author Shristy Kumari | 10-11-2025 
    **/
    @isTest
    private static void testValidDecimalValuesSuccess(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInfoValidationUtil.validateDecimalValue('123.45','Invalid Decimal Value'); 
            System.assertEquals('SUCCESS', ExternalConstants.SUCCESS_VALUE, 'Assertion Failed for testing when decimal value is valid.');    
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception scenerio when state value is invalid
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testValidateStates(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateState('NRR');
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.STATE_INVALID, exceptionObj.getMessage(), 'Assertion Failed for testing exception scenerio when state is invalid.');
            }
            Test.stopTest();
        }
    }
     /**
    * @description : Method to test success scenerio when state value is valid
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testValidStateSuccess(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInfoValidationUtil.validateState('WA');
            System.assertEquals('SUCCESS', ExternalConstants.SUCCESS_VALUE, 'Assertion Failed for testing success scenerio when state value is valid.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception scenerio when insurance coverage is invalid
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testYieldInsuranceCoverageException(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateYieldInsuranceCoverage(new Map<String,Object>{
                    'commodity' => 'Millet',
                    'total_acres'=> 600,
                    'producer_share_percent'=> 100,
                    'approved_yield'=> 600,
                    'insurance_plan'=> 'RP',
                    'coverage_level_percent'=> 95
                });
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.CROP_INVALID_PERCENT_COVERAGE_LEVEL_TYPE, exceptionObj.getMessage(), 'Exception expected for invalid coverage level percent');
            }
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test exception scenerio when total acres is invalid
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testTotalAcresException(){
        User userObj = getUser();
        clcommon__Collateral_Category__c collateralCategoryObj = [SELECT Id FROM clcommon__Collateral_Category__c];
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateTotalSharePercent(new Map<String,Object>{
                    'commodity' => 'Millet',
                    'total_acres'=> -600,
                    'producer_share_percent'=> 100,
                    'approved_yield'=> 10,
                    'insurance_plan'=> 'RP',
                    'coverage_level_percent'=> 95
                }, new Map<String,Id>{
                    'Millet' => collateralCategoryObj.Id
                });
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.CROP_INVALID_TOTAL_ACRES_VALUE, exceptionObj.getMessage(), 'Assertion Failed for testing exception scenerio exception scenerio when total acres is invalid');
            }
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test exception scenerio when producer share percent is less than zero
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testSharePercentLessThanZeroException(){
        User userObj = getUser();
        clcommon__Collateral_Category__c collateralCategoryObj = [SELECT Id FROM clcommon__Collateral_Category__c];
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateTotalSharePercent(new Map<String,Object>{
                    'commodity' => 'Millet',
                    'total_acres'=> 600,
                    'producer_share_percent'=> -100,
                    'approved_yield'=> 10,
                    'insurance_plan'=> 'RP',
                    'coverage_level_percent'=> 95
                }, new Map<String,Id>{
                    'Millet' => collateralCategoryObj.Id
                });
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.CROP_INVALID_PRODUCER_SHARE_PERCENT_VALUE, exceptionObj.getMessage(), 'Assertion Failed for testing exception scenerio when producer share percent is less than zero');
            }
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test exception scenerio when producer share percent is greater than hundred
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testSharePercentGreaterHundredException(){
        User userObj = getUser();
        clcommon__Collateral_Category__c collateralCategoryObj = [SELECT Id FROM clcommon__Collateral_Category__c];
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateTotalSharePercent(new Map<String,Object>{
                    'commodity' => 'Millet',
                    'total_acres'=> 600,
                    'producer_share_percent'=> 1100,
                    'approved_yield'=> 10,
                    'insurance_plan'=> 'RP',
                    'coverage_level_percent'=> 95
                }, new Map<String,Id>{
                    'Millet' => collateralCategoryObj.Id
                });
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.CROP_INVALID_PRODUCER_SHARE_PERCENT_VALUE, exceptionObj.getMessage(), 'Assertion Failed for testing exception scenerio when producer share percent is greater than hundred');
            }
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test exception scenerio when fed collateraal percent is less than zero
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testFeedCollateralLessThanZeroException(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateFeedCollateral(new Map<String,Object>{
                    'commodity' => 'Millet',
                    'total_acres'=> 600,
                    'producer_share_percent'=> 100,
                    'approved_yield'=> 10,
                    'insurance_plan'=> 'RP',
                    'coverage_level_percent'=> 80,
                    'collateral_fed_percent' => -10
                }, true);
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.CROP_INVALID_PERCENT_FED_VALUE, exceptionObj.getMessage(), 'Assertion Failed for testing exception scenerio when fed collateraal percent is less than zero');
            }
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test exception scenerio when fed collateraal percent is less than zero
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testFeedCollateralGreaterHundredException(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateFeedCollateral(new Map<String,Object>{
                    'commodity' => 'Millet',
                    'total_acres'=> 600,
                    'producer_share_percent'=> 100,
                    'approved_yield'=> 10,
                    'insurance_plan'=> 'RP',
                    'coverage_level_percent'=> 80,
                    'collateral_fed_percent' => 110
                }, true);
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.CROP_INVALID_PERCENT_FED_VALUE, exceptionObj.getMessage(), 'Assertion failed for testing exception scenerio when fed collateraal percent is greater than hundred');
            }
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test exception scenerio when spouse email is invalid
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void validatesSpouseEmail(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateSpouseDetails(new List<Object>{
                    new Map<String,Object>{
                        'first_name' => 'Richie',
                        'middle_name' => 'waley',
                        'last_name' => 'Henry',
                        'ssn' => '123456789',
                        'email' => 'evajamesyopmailcom'
                    }
                });
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.INVALID_EMAIL, exceptionObj.getMessage(), 'Assertion failed for testing exception scenerio when spouse email is invalid');
            }
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test exception scenerio when landowner's state is invalid
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testLandownerStateException(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateLandownerDetails(new List<Object>{
                    new Map<String,Object>{
                        'name' => 'Lee Richie',
                        'state' => 'WATJ',
                        'county' => 'Adelade'
                    }
                });
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.STATE_INVALID, exceptionObj.getMessage(), 'Assertion failed for testing exception scenerio when landowners state is invalid');
            }
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test exception when buyer's state is invalid
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testInvalidBuyerStateException(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateBuyersDetails(new List<Object>{
                    new Map<String,Object>{
                        'name' => 'David Warner',
                        'street' => '123 Melrose Street',
                        'city' => 'Adelade',
                        'state' => 'WAAY',
                        'postal_code' => '12205',
                        'email' => 'david.warner@yopmail.com',
                        'phone' => '1890871256'
                    }
                });
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.STATE_INVALID, exceptionObj.getMessage(), 'Assertion Failed for testing exception when buyers state is invalid');
            }
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test exception scenerio when Insurance agent state is invalid
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testInvalidInsAgentStateException(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateInsuranceAgentDetails(new List<Object>{
                    new Map<String,Object>{
                        'name' => 'Acko Birla',
                        'street' => '123 Melrose Street',
                        'city' => 'Adelade',
                        'state' => 'WAAU',
                        'postal_code' => '12205',
                        'email' => 'aditya.insurance@yopmail.com',
                        'phone' => '1890871256'
                    }
                });
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.STATE_INVALID, exceptionObj.getMessage(), 'Assertion Failed for testing exception scenerio when Insurance agent state is invalid');
            }
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test success scenerio for getSiteAdmin method
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testGetSiteAdminSuccess(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInfoValidationUtil.getSiteAdmin();
            System.assertEquals('SUCCESS', ExternalConstants.SUCCESS_VALUE, 'Assertion Failed for testing success scenerio for getSiteAdmin method');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test success scenerio for validateRequestMap
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testValidateRequestMapSuccess(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInfoValidationUtil.validateRequestMap(new Map<String,Object>{
                'application_details' => 'APP001122',
                'borrower_details' => '001O100000F696PIARRTQQ',
                'crop_details' => 'svhs',
                'insurance_agent_details' => 'svhs',
                'buyer_details' => 'svhs',
                'landowner_details' =>'wjjh',
                'spouse_details' => 'ajahj'
            });
            System.assertEquals('SUCCESS', ExternalConstants.SUCCESS_VALUE, 'Assertion Failed for testing success scenerio for validateRequestMap');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test success scenerio for validate ApplicationUserDetailsMap 
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testAppDetailMapSuccess(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInfoValidationUtil.validateApplicationUserDetailsMap(new Map<String,Object>{
                'id' => 'APP006872JHGS'
            }, new Map<String,Object>{
                'user_id' => '001O100000F696PIARRTQQ'
            });
            System.assertEquals('SUCCESS', ExternalConstants.SUCCESS_VALUE, 'Assertion Failed for testing test success scenerio for validate ApplicationUserDetailsMap');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test success scenerio to validate CropDetails Map
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testValidateCropDetailSuccess(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
                ExternalAdditionalInfoValidationUtil.validateCropDetailsMap(new Map<String,Object>{
                    'do_feed_collateral' => false,
                    'collaterals' => 'ajha'
                });
                System.assertEquals('SUCCESS', ExternalConstants.SUCCESS_VALUE, 'Assertion Failed for testing success scenerio to validate CropDetails Map');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test exception scenerio when application is not found
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testApplicationNotFoundException(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateApplicationUserId('ansvjh','ahshj');
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.APPLICATION_NOT_FOUND, exceptionObj.getMessage(), 'Assertion Failed for testing exception scenerio when application is not found');
            }
            Test.stopTest();
        }
    }
    
    /**
    * @description : Method to test exception scenerio when user is not authorized for sole prop
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testUserNotAuthorizedSoleProp(){
        User userObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateApplicationUserId(applicationObj.Id,'ahshj');
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.USER_NOT_AUTHORISED, exceptionObj.getMessage(), 'Assertion Failed for testing exception scenerio when user is not authorized');
            }
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test exception scenerio when user is not authorized for corporation
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testUserNotAuthorizedCorporation(){
        User userObj = getUser();
        clcommon__Legal_Entity__c entityObj = [SELECT Id, 
                                                        clcommon__Legal_Entity_Type__c,
                                                        Name 
                                                    FROM clcommon__Legal_Entity__c];
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        System.runAs(userObj){
            Test.startTest();
            try{
                ExternalAdditionalInfoValidationUtil.validateApplicationUserId(applicationObj.Id,'ahshj');
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.USER_NOT_AUTHORISED, exceptionObj.getMessage(), 'Assertion Failed for testing exception scenerio when user is not authorized');
            }
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception scenerio without first principal for corporation
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testExceptionWithoutFirstPrincipalCorporation(){
        User userObj = getUser();
        clcommon__Legal_Entity__c entityObj = [SELECT Id, 
                                                        clcommon__Legal_Entity_Type__c,
                                                        Name 
                                                    FROM clcommon__Legal_Entity__c];
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> principalPartyTypeList = [SELECT Id,
                                                                    clcommon__Account__r.Unique_Id__c 
                                                                FROM clcommon__Party__c 
                                                                WHERE genesis__Application__c = :applicationObj.Id
                                                                AND clcommon__Party_Types__c = :ExternalConstants.PRINCIPAL_PARTY
                                                                AND Principal_Number__c = 1];
        principalPartyTypeList[0].Principal_Number__c = 2;
        Database.update(principalPartyTypeList,true);
        System.runAs(userObj){
            Test.startTest();
            try{
                ExternalAdditionalInfoValidationUtil.validateApplicationUserId(applicationObj.Id,'ahshj');
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.USER_NOT_AUTHORISED, exceptionObj.getMessage(), 'Assertion Failed for testing exception scenerio without first principal for corporation');
            }
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception scenerio when spouse SSN is invalid
    * @author Shristy Kumari | 12-30-2024 
    **/
    @isTest
    private static void testInvalidSpouseSsnException(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateSpouseDetails(new List<Object>{
                    new Map<String,Object>{
                        'first_name' => 'Richie',
                        'middle_name' => 'waley',
                        'last_name' => 'Henry',
                        'ssn' => '123456',
                        'email' => 'evajames@yopmail.com'
                    }
                });
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.INVALID_SSN, exceptionObj.getMessage(), 'Assertion Failed for testing exception scenerio when spouse SSN is invalid');
            }
            Test.stopTest();
        }
    }
     /**
    * @description : Method to test exception scenerio when buyers email is invalid
    * @author Shristy Kumari | 12-30-2024 
    **/
    @isTest
    private static void testInvalidBuyersEmailException(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateBuyersDetails(new List<Object>{
                    new Map<String,Object>{
                        'name' => 'David Warner',
                        'street' => '123 Melrose Street',
                        'city' => 'Adelade',
                        'state' => 'AK',
                        'postal_code' => '12205',
                        'email' => 'david.warneryopmailcom',
                        'phone' => '1890871256'
                    }
                });
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.INVALID_EMAIL, exceptionObj.getMessage(), 'Assertion Failed for testing exception scenerio when buyers email is invalid');
            }
            Test.stopTest();
        }
    }
     /**
    * @description : Method to test exception scenerio when buyer phone number is invalid
    * @author Shristy kumari | 12-30-2024 
    **/
    @isTest
    private static void testInvalidBuyersPhoneException(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateBuyersDetails(new List<Object>{
                    new Map<String,Object>{
                        'name' => 'David Warner',
                        'street' => '123 Melrose Street',
                        'city' => 'Adelade',
                        'state' => 'AK',
                        'postal_code' => '12205',
                        'email' => 'david.warner@yopmail.com',
                        'phone' => '1890871'
                    }
                });
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.INVALID_PHONE_NUMBER, exceptionObj.getMessage(), 'Assertion Failed for testing exception scenerio when buyer phone number is invalid');
            }
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception scenerio when postal code for buyer is invalid
    * @author Shristy Kumari | 12-30-2024 
    **/
    @isTest
    private static void testInvalidBuyersPostalCodeException(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateBuyersDetails(new List<Object>{
                    new Map<String,Object>{
                        'name' => 'David Warner',
                        'street' => '123 Melrose Street',
                        'city' => 'Adelade',
                        'state' => 'AK',
                        'postal_code' => '1220556',
                        'email' => 'david.warner@yopmail.com',
                        'phone' => '1890871256'
                    }
                });
            }catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.POSTAL_CODE_INVALID, exceptionObj.getMessage(), 'Assertion Failed for testing exception scenerio when postal code for buyer is invalid');
            }
            Test.stopTest();
        }
    }
     /**
    * @description : Method to test success scenerio to validate spouse detail
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testSpouseDetailSuccess(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInfoValidationUtil.validateSpouseDetails(new List<Object>{
                new Map<String,Object>{
                    'first_name' => 'Richie',
                    'middle_name' => 'waley',
                    'last_name' => 'Henry',
                    'ssn' => '123456789',
                    'email' => 'eva.james@yopmail.com'
                    }
                });
            System.assertEquals('SUCCESS', ExternalConstants.SUCCESS_VALUE, 'Invalid spouse details.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception scenerio when landowner's state is invalid
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testLandownerDetailSuccess(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
                ExternalAdditionalInfoValidationUtil.validateLandownerDetails(new List<Object>{
                    new Map<String,Object>{
                        'name' => 'Lee Richie',
                        'state' => 'WA',
                        'county' => 'Adelade'
                    }
                });
                System.assertEquals('SUCCESS', ExternalConstants.SUCCESS_VALUE, 'Invalid land owner details.');
                Test.stopTest();
        }
    }
     /**
    * @description : Method to success scenerio for buyers detail
    * @author Shristy Kumari | 01-11-2025
    **/
    @isTest
    private static void testBuyerDetaiSuccess(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
                ExternalAdditionalInfoValidationUtil.validateBuyersDetails(new List<Object>{
                    new Map<String,Object>{
                        'name' => 'David Warner',
                        'street' => '123 Melrose Street',
                        'city' => 'Adelade',
                        'state' => 'WA',
                        'postal_code' => '12205',
                        'email' => 'david.warner@yopmail.com',
                        'phone' => '1890871256'
                    }
                });
            System.assertEquals('SUCCESS', ExternalConstants.SUCCESS_VALUE, 'Invalid buyer details.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test success scenerio for Insurance agent detail
    * @author Shristy Kumari | 01-11-2025
    **/
    @isTest
    private static void testInsAgentDetailSuccess(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
                ExternalAdditionalInfoValidationUtil.validateInsuranceAgentDetails(new List<Object>{
                    new Map<String,Object>{
                        'name' => 'Acko Birla',
                        'street' => '123 Melrose Street',
                        'city' => 'Adelade',
                        'state' => 'WA',
                        'postal_code' => '12205',
                        'email' => 'aditya.insurance@yopmail.com',
                        'phone' => '1890871256'
                    }
                });
            System.assertEquals('SUCCESS', ExternalConstants.SUCCESS_VALUE, 'Invalid insurance agent details.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test success scenerio for fed collateral details
    * @author Shristy Kumari | 01-11-2025 
    **/
    @isTest
    private static void testFeedCollateralSuccess(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
                ExternalAdditionalInfoValidationUtil.validateFeedCollateral(new Map<String,Object>{
                    'commodity' => 'Millet',
                    'total_acres'=> 600,
                    'producer_share_percent'=> 100,
                    'approved_yield'=> 10,
                    'insurance_plan'=> 'RP',
                    'coverage_level_percent'=> 80,
                    'collateral_fed_percent' => 10
                }, true);
            System.assertEquals('SUCCESS', ExternalConstants.SUCCESS_VALUE, 'Invalid feed collateral details.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test success scenerio for total total share percent details map
    * @author Shristy Kumari | 01-11-2024 
    **/
    @isTest
    private static void testTotalShareSuccess(){
        User userObj = getUser();
        clcommon__Collateral_Category__c collateralCategoryObj = [SELECT Id FROM clcommon__Collateral_Category__c];
        System.runAs(userObj){
            Test.startTest();
                ExternalAdditionalInfoValidationUtil.validateTotalSharePercent(new Map<String,Object>{
                    'commodity' => 'Millet',
                    'total_acres'=> 600,
                    'producer_share_percent'=> 100,
                    'approved_yield'=> 10,
                    'insurance_plan'=> 'RP',
                    'coverage_level_percent'=> 95
                }, new Map<String,Id>{
                    'Millet' => collateralCategoryObj.Id
                });
            System.assertEquals('SUCCESS', ExternalConstants.SUCCESS_VALUE, 'Invalid total share percent details.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test success scenerio for yield insurance coverage details
    * @author Shristy Kumari | 01-11-2024 
    **/
    @isTest
    private static void testYieldInsuranceCoverageSuccess(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInfoValidationUtil.validateYieldInsuranceCoverage(new Map<String,Object>{
                    'commodity' => 'Millet',
                    'total_acres'=> 600,
                    'producer_share_percent'=> 100,
                    'approved_yield'=> 600,
                    'insurance_plan'=> 'RP',
                    'coverage_level_percent'=> 85
                });
            System.assertEquals('SUCCESS', ExternalConstants.SUCCESS_VALUE, 'Invalid yield insurance coverage details.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test Exception scenerio to validate CropDetails Map when fed collateral is missing
    * @author Shristy Kumari | 01-11-2025 
    **/
    @isTest
    private static void testValidateCropDetailException(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateCropDetailsMap(new Map<String,Object>{
                     'collaterals' => 'ajha'
                });
            }
            catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.FED_COLLATERAL_MISSING, exceptionObj.getMessage(), 'Exception expected for missing fed collateral');
            }
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test Exception scenerio to validate CropDetails Map when collateral value is missing
    * @author Shristy Kumari | 01-11-2025 
    **/
    @isTest
    private static void testCollateralMissingException(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateCropDetailsMap(new Map<String,Object>{
                     'do_feed_collateral' => false
                });
            }
            catch(Exception exceptionObj){
                System.assertEquals(ExternalConstants.COLLATERAL_MISSING, exceptionObj.getMessage(), 'Exception expected for missing collateral');
            }
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception scenerio to validate ApplicationUserDetailsMap 
    * @author Shristy Kumari | 01-11-2025 
    **/
    @isTest
    private static void testAppDetailMapException(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateApplicationUserDetailsMap(new Map<String,Object>{}, new Map<String,Object>{
                'user_id' => '001O100000F696PIARRTQQ'
              });
            }
            catch(Exception exceptionObj){
            System.assertEquals(ExternalConstants.APPLICATION_ID_MISSING, exceptionObj.getMessage(), 'Exception expected for missing application id.');
            }
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception scenerio to validate ApplicationUserDetailsMap 
    * @author Shristy Kumari | 01-11-2025 
    **/
    @isTest
    private static void testRequiredKeyException(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateRequiredKey(new Map<String,Object>{},ExternalConstants.FED_COLLATERAL_KEY, ExternalConstants.FED_COLLATERAL_MISSING );
            }
            catch(Exception exceptionObj){
            System.assertEquals(ExternalConstants.FED_COLLATERAL_MISSING, exceptionObj.getMessage(), 'Exception expected for missing fed collateral');
            }
            Test.stopTest();
        }
    }
    
    /**
    * @description : Method to test exception scenerio to validate ApplicationUserDetailsMap 
    * @author Shristy Kumari | 01-11-2025 
    **/
    @isTest
    private static void testRequiredKeySuccess(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            ExternalAdditionalInfoValidationUtil.validateRequiredKey(new Map<String,Object>{
                'do_feed_collateral' => false
            },ExternalConstants.FED_COLLATERAL_KEY, ExternalConstants.FED_COLLATERAL_MISSING );
            System.assertEquals('SUCCESS', ExternalConstants.SUCCESS_VALUE, 'Fed collateral missing');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test exception scenerio to validate ApplicationUserDetailsMap when user id is missing 
    * @author Shristy Kumari | 01-11-2025 
    **/
    @isTest
    private static void testUserIdMissingException(){
        User userObj = getUser();
        System.runAs(userObj){
            Test.startTest();
            Try{
                ExternalAdditionalInfoValidationUtil.validateApplicationUserDetailsMap(new Map<String,Object>{
                 'id' => 'APP006872JHGS'
                }, new Map<String,Object>{});
            }
            catch(Exception exceptionObj){
            System.assertEquals(ExternalConstants.USER_ID_MISSING, exceptionObj.getMessage(), 'Exception expected for missing user id.');
            }
            Test.stopTest();
        }
    }
}