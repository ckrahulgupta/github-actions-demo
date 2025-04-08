/**
 * @description       :  Test class for PortalSaveFlexRateAPI
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 08-12-2024
 * @last modified by  :  Pritam Roy
**/
@isTest
public with sharing class PortalSaveFlexRateAPITest {
     /**
    * @description : Test Setup
    * @author  Pritam Roy | 04-30-2024 
    **/
    @TestSetup
    static void makeData() {

        clcommon__Reciprocal_Role__c clRole = TestClassHelper.createReciprocalRole('Certified Lender');
        Database.insert(clRole, true);

        clcommon__CL_Product__c clProductObj = TestClassHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // CFA dealer test data
        genesis__Business_Information__c cfaDealerBusinessinfo = TestClassHelper.createBusinessInfoForDealer();
        Database.insert(cfaDealerBusinessinfo, true);

        Account cfaDealerAccount = TestClassHelper.createDealerAccount(cfaDealerBusinessinfo.Id);
        cfaDealerAccount.Coop_Type__c = 'Growmark';
        Database.insert(cfaDealerAccount, true);

        Contact cfaDealerContact = TestClassHelper.createDealerContact(cfaDealerAccount.Id);
        Database.insert(cfaDealerContact, true);

        // create CL
        genesis__Business_Information__c cfaClBusinessinformation = TestClassHelper.createBusinessInfoForDealer();
        Database.insert(cfaClBusinessinformation, true);

        Account cfaClAccount = TestClassHelper.createCLAccount(cfaClBusinessinformation.Id, cfaDealerAccount.Id);
        Database.insert(cfaClAccount, true);

        Contact cfaClContact = TestClassHelper.createCLContact(cfaClAccount.Id);
        Database.insert(cfaClContact, true);

        User cfaClUser = TestClassHelper.createCLUser(cfaClContact.Id);
        Database.insert(cfaClUser, true);

        clcommon__Relationship__c cfaDealerClRelation = TestClassHelper.createCLDealerRelationship(clRole,
                                                                cfaDealerAccount.Id,
                                                                cfaClAccount.Id);

        Database.insert(cfaDealerClRelation, true);

        TestClassHelper.createApplicationSetupData(cfaClContact, cfaDealerContact, clProductObj.Id);
    }

    /**
    * @description : get CL user
    * @author  Pritam Roy | 03-06-2024 
    * @return User 
    **/
    private static User getCLUser() {
        return [
            SELECT Id 
            FROM User 
            WHERE Username = 'ross.geller@yopmail.com' 
            LIMIT 1
        ][0];
    }

    /**
    * @description : get Dealer Account
    * @author  Pritam Roy | 03-06-2024 
    * @return Account 
    **/
    private static Account getDealerAccount() {
        return [
            SELECT Id 
            FROM Account 
            WHERE Name = 'Kisan Loan' 
            LIMIT 1
        ][0];
    }

     /**
    * @description : Flex Rate Success
    * @author  Pritam Roy | 04-30-2024 
    **/
    @IsTest
    public static void testCaseCreateNewFlexRateSuccess() {
        
        Map<String, Object> flexCardRequest = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put('genesis__End_Date__c', '2025-04-15');
        program.put('Id', 'new_record_id');
        // program.put('Name', 'GMK My Program - 110');
        program.put('Crop_Year__c', '2025');
        program.put('FS_Index_Rate__c', 8.75);
        program.put('Closing_Fee__c', 0);
        program.put('Payer_of_Loan_Closing_Fee__c', 'Grower');
        program.put('Loan_Fee_Advanced_On__c', 'A');
        program.put('Dealer_Participate_on_Closing_Fee__c', 'No');

        flexCardRequest.put('flexRateProgram', program);

        Map<String, Map<String, Object>> flexRatePricing = new Map<String, Map<String, Object>>();

        // add the interest rate attributes for Note Rate
        Map<String, Object> subTranche = new Map<String, Object>();
        subTranche.put('description', 'Note Rate');

        List<Map<String, Object>> subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 1.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 10,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('NoteRate', subTranche);

        // add the interest attributes for Subtrance B
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Seeds');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0.75,
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 8,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermB', subTranche);


        // add the interest attributes for Subtrance C
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Chemicals');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermC', subTranche);


        // add the interest attributes for Subtrance D
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Equipment');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermD', subTranche);

        // add the interest attributes for Subtrance E
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Vehicle');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermE', subTranche);

        flexCardRequest.put('ratePricing', flexRatePricing);

        // add the interest attributes for Subtrance D
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Equipment');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermF', subTranche);

        // add the interest attributes for Subtrance D
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Equipment');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermG', subTranche);

        // add the interest attributes for Subtrance D
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Equipment');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermH', subTranche);
        Map<String, Object> request = new Map<String, Object>();
        request.put('flexPricing', JSON.serialize(flexCardRequest));
        request.put('shouldValidate', true);
        

        genesis__Applications__c objApplication = [
                SELECT Id 
                FROM genesis__Applications__c 
                LIMIT 1
            ];
        request.put('applicationId',objApplication.id);

        System.runAs(getCLUser()) {
            PortalSaveFlexRateAPI api = new PortalSaveFlexRateAPI();
            clcommon.Response response = api.invokeAction('', null, request);

            // System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Test Success');
            
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Test Success');
        }
    }

     /**
    * @description : Flex Rate Exception
    * @author  Pritam Roy | 04-30-2024 
    **/
    @IsTest
    public static void testCaseCreateNewFlexRateException() {
        
        Map<String, Object> flexCardRequest = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put('genesis__End_Date__c', '2025-04-15');
        program.put('Id', 'new_record_id');
        // program.put('Name', 'GMK My Program - 110');
        program.put('Crop_Year__c', '2025');
        program.put('FS_Index_Rate__c', 8.75);
        program.put('Closing_Fee__c', 0);
        program.put('Payer_of_Loan_Closing_Fee__c', 'Grower');
        program.put('Loan_Fee_Advanced_On__c', 'A');
        program.put('Dealer_Participate_on_Closing_Fee__c', 'No');

        flexCardRequest.put('flexRateProgram', program);

        Map<String, Map<String, Object>> flexRatePricing = new Map<String, Map<String, Object>>();

        // add the interest rate attributes for Note Rate
        Map<String, Object> subTranche = new Map<String, Object>();
        subTranche.put('description', 'Note Rate');

        List<Map<String, Object>> subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 1.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 10,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('NoteRate', subTranche);

        // add the interest attributes for Subtrance B
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Seeds');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0.75,
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 8,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermB', subTranche);


        // add the interest attributes for Subtrance C
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Chemicals');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermC', subTranche);


        // add the interest attributes for Subtrance D
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Equipment');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermD', subTranche);

        // add the interest attributes for Subtrance E
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Vehicle');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermE', subTranche);

        flexCardRequest.put('ratePricing', flexRatePricing);

        // add the interest attributes for Subtrance D
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Equipment');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermF', subTranche);

        // add the interest attributes for Subtrance D
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Equipment');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermG', subTranche);

        // add the interest attributes for Subtrance D
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Equipment');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermH', subTranche);
        Map<String, Object> request = new Map<String, Object>();
        request.put('flexPricing', JSON.serialize(flexCardRequest));
        request.put('shouldValidate', true);
        
        request.put('applicationId',NULL);

        System.runAs(getCLUser()) {
            PortalSaveFlexRateAPI api = new PortalSaveFlexRateAPI();
            clcommon.Response response = api.invokeAction('', null, request);

            // System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Test Success');
            
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Test Success');
        }
    }

     /**
    * @description : Flex Rate Do you Recommend Success
    * @author  Pritam Roy | 04-30-2024 
    **/
    @IsTest
    public static void testCaseCreateRecommendSuccess() {
        
        Map<String, Object> flexCardRequest = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put('genesis__End_Date__c', '2025-04-15');
        program.put('Id', 'new_record_id');
        // program.put('Name', 'GMK My Program - 110');
        program.put('Crop_Year__c', '2025');
        program.put('FS_Index_Rate__c', 8.75);
        program.put('Closing_Fee__c', 0);
        program.put('Payer_of_Loan_Closing_Fee__c', 'Grower');
        program.put('Loan_Fee_Advanced_On__c', 'A');
        program.put('Dealer_Participate_on_Closing_Fee__c', 'No');

        flexCardRequest.put('flexRateProgram', program);

        Map<String, Map<String, Object>> flexRatePricing = new Map<String, Map<String, Object>>();

        // add the interest rate attributes for Note Rate
        Map<String, Object> subTranche = new Map<String, Object>();
        subTranche.put('description', 'Note Rate');

        List<Map<String, Object>> subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 1.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 10,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('NoteRate', subTranche);

        // add the interest attributes for Subtrance B
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Seeds');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0.75,
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 8,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermB', subTranche);


        // add the interest attributes for Subtrance C
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Chemicals');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermC', subTranche);


        // add the interest attributes for Subtrance D
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Equipment');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermD', subTranche);

        // add the interest attributes for Subtrance E
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Vehicle');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermE', subTranche);

        flexCardRequest.put('ratePricing', flexRatePricing);

        // add the interest attributes for Subtrance D
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Equipment');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermF', subTranche);

        // add the interest attributes for Subtrance D
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Equipment');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermG', subTranche);

        // add the interest attributes for Subtrance D
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Equipment');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermH', subTranche);
        Map<String, Object> request = new Map<String, Object>();
        request.put('flexPricing', JSON.serialize(flexCardRequest));
        request.put('shouldValidate', true);
        request.put('Do_You_Recommend_This_Applicant__c','No');

        genesis__Applications__c objApplication = [
                SELECT Id 
                FROM genesis__Applications__c 
                LIMIT 1
            ];
        request.put('applicationId',objApplication.Id);

        System.runAs(getCLUser()) {
            PortalSaveFlexRateAPI api = new PortalSaveFlexRateAPI();
            clcommon.Response response = api.invokeAction('', null, request);

            
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Test Success');
        }
    }

      /**
    * @description : Flex Rate CFA Success
    * @author  Pritam Roy | 04-30-2024 
    **/
    @IsTest
    public static void testCaseCreateCFARecommendSuccess() {
        
        Map<String, Object> flexCardRequest = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put('genesis__End_Date__c', '2025-04-15');
        program.put('Id', 'new_record_id');
        // program.put('Name', 'GMK My Program - 110');
        program.put('Crop_Year__c', '2025');
        program.put('FS_Index_Rate__c', 8.75);
        program.put('Closing_Fee__c', 0);
        program.put('Payer_of_Loan_Closing_Fee__c', 'Grower');
        program.put('Loan_Fee_Advanced_On__c', 'A');
        program.put('Dealer_Participate_on_Closing_Fee__c', 'No');

        flexCardRequest.put('flexRateProgram', program);

        Map<String, Map<String, Object>> flexRatePricing = new Map<String, Map<String, Object>>();

        // add the interest rate attributes for Note Rate
        Map<String, Object> subTranche = new Map<String, Object>();
        subTranche.put('description', 'Note Rate');

        List<Map<String, Object>> subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 1.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 10,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('NoteRate', subTranche);

        // add the interest attributes for Subtrance B
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Seeds');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0.75,
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 8,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermB', subTranche);


        // add the interest attributes for Subtrance C
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Chemicals');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermC', subTranche);


        // add the interest attributes for Subtrance D
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Equipment');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermD', subTranche);

        // add the interest attributes for Subtrance E
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Vehicle');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermE', subTranche);

        flexCardRequest.put('ratePricing', flexRatePricing);

        // add the interest attributes for Subtrance D
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Equipment');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermF', subTranche);

        // add the interest attributes for Subtrance D
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Equipment');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermG', subTranche);

        // add the interest attributes for Subtrance D
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Equipment');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        flexRatePricing.put('SpecialTermH', subTranche);
        Map<String, Object> request = new Map<String, Object>();
        request.put('flexPricing', JSON.serialize(flexCardRequest));
        request.put('shouldValidate', true);

        genesis__Applications__c objApplication = [
                SELECT Id,Coop_Type__c 
                FROM genesis__Applications__c 
                LIMIT 1
            ];

        Account dealerAccount = [SELECT id,Coop_type__c FROM Account WHERE Name = 'Kisan Loan'];
        dealerAccount.Coop_type__c = 'CFA';
        Database.update(dealerAccount,true);
        request.put('applicationId',objApplication.Id);

        System.runAs(getCLUser()) {
            PortalSaveFlexRateAPI api = new PortalSaveFlexRateAPI();
            clcommon.Response response = api.invokeAction('', null, request);

            
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Test Success');
        }
    }

   
}