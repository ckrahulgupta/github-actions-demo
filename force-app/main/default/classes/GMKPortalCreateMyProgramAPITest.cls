/**
 * @description       : Test Class for GMKPortalCreateMyProgramAPI
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 10-25-2024
 * @last modified by  : Ayush Kumar Singh
**/
@IsTest
public with sharing class GMKPortalCreateMyProgramAPITest {
    
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
    * @description : My Program Success
    * @author  Pritam Roy | 04-30-2024 
    **/
    @IsTest
    public static void testCaseCreateNewMyProgramSuccess() {
        
        Map<String, Object> request = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put('genesis__End_Date__c', '2025-04-15');
        program.put('Id', 'new_record_id');
        program.put('Name', 'GMK My Program - 110');
        program.put('Crop_Year__c', '2025');
        program.put('FS_Index_Rate__c', 8.75);
        program.put('Closing_Fee__c', 0);
        program.put('Payer_of_Loan_Closing_Fee__c', 'Grower');
        program.put('Loan_Fee_Advanced_On__c', 'A');
        program.put('Dealer_Participate_on_Closing_Fee__c', 'No');

        request.put('program', JSON.serialize(program));

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

        request.put('NoteRate', JSON.serialize(subTranche));

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

        request.put('SpecialTermB', JSON.serialize(subTranche));


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

        request.put('SpecialTermC', JSON.serialize(subTranche));


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

        request.put('SpecialTermD', JSON.serialize(subTranche));

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

        request.put('SpecialTermE', JSON.serialize(subTranche));

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
 
         request.put('SpecialTermF', JSON.serialize(subTranche));

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

        request.put('SpecialTermG', JSON.serialize(subTranche));

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
 
         request.put('SpecialTermH', JSON.serialize(subTranche));
        
        System.runAs(getCLUser()) {
            GMKPortalCreateMyProgramAPI api = new GMKPortalCreateMyProgramAPI();
            clcommon.Response response = api.invokeAction('', null, request);

            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Test Success');
        }
    }

    /**
    * @description : Create My Program Same FS Index Success
    * @author  Pritam Roy | 04-30-2024 
    **/
    @IsTest
    public static void testCaseCreateNewMyProgramWithSameFsIndexSuccess() {
        
        Map<String, Object> request = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put('genesis__End_Date__c', '2025-04-15');
        program.put('Id', 'new_record_id');
        program.put('Name', 'GMK My Program - 110');
        program.put('Crop_Year__c', '2025');
        program.put('FS_Index_Rate__c', 8.75);
        program.put('Closing_Fee__c', 0);
        program.put('Payer_of_Loan_Closing_Fee__c', 'Grower');
        program.put('Loan_Fee_Advanced_On__c', 'A');
        program.put('Dealer_Participate_on_Closing_Fee__c', 'No');

        request.put('program', JSON.serialize(program));

        // add the interest rate attributes for Note Rate
        Map<String, Object> subTranche = new Map<String, Object>();
        subTranche.put('description', 'Note Rate');

        List<Map<String, Object>> subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 8.75,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        request.put('NoteRate', JSON.serialize(subTranche));

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

        request.put('SpecialTermB', JSON.serialize(subTranche));


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

        request.put('SpecialTermC', JSON.serialize(subTranche));


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

        request.put('SpecialTermD', JSON.serialize(subTranche));

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

        request.put('SpecialTermE', JSON.serialize(subTranche));

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

        request.put('SpecialTermF', JSON.serialize(subTranche));

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

        request.put('SpecialTermG', JSON.serialize(subTranche));

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

        request.put('SpecialTermH', JSON.serialize(subTranche));

        System.runAs(getCLUser()) {
            GMKPortalCreateMyProgramAPI api = new GMKPortalCreateMyProgramAPI();
            clcommon.Response response = api.invokeAction('', null, request);

            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Test Success');
        }
    }
    @IsTest
    public static void testCaseCreateNewMyProgramWithDifferentStartDate() {
        
        Map<String, Object> request = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put('genesis__End_Date__c', '2025-04-15');
        program.put('Id', 'new_record_id');
        program.put('Name', 'GMK My Program - 110');
        program.put('Crop_Year__c', '2025');
        program.put('FS_Index_Rate__c', 8.75);
        program.put('Closing_Fee__c', 0);
        program.put('Payer_of_Loan_Closing_Fee__c', 'Grower');
        program.put('Loan_Fee_Advanced_On__c', 'A');
        program.put('Dealer_Participate_on_Closing_Fee__c', 'No');

        request.put('program', JSON.serialize(program));

        // add the interest rate attributes for Note Rate
        Map<String, Object> subTranche = new Map<String, Object>();
        subTranche.put('description', 'Note Rate');

        List<Map<String, Object>> subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-08-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 8.75,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        request.put('NoteRate', JSON.serialize(subTranche));

        // add the interest attributes for Subtrance B
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Seeds');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0.75,
                'Participation_Percentage_Dealer__c' => 0,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-07-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 8,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        request.put('SpecialTermB', JSON.serialize(subTranche));


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

        request.put('SpecialTermC', JSON.serialize(subTranche));


        // add the interest attributes for Subtrance D
        subTranche = new Map<String, Object>();
        subTranche.put('description', 'Equipment');

        subTrancheInterestList = new List<Map<String, Object>>();
        subTrancheInterestList.add(
            new Map<String, Object>{
                'Participation_Percentage_Dealer_Subsidy__c' => 0,
                'Participation_Percentage_Dealer__c' => 2.25,
                'Participation_Percentage_CFA__c' => 0,
                'Start_Date__c' => '2024-09-07',
                'End_Date__c' => '2025-04-15',
                'genesis__Interest_Rate__c' => 11,
                'Interest_Rate_Type__c' => 'Fixed'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        request.put('SpecialTermD', JSON.serialize(subTranche));

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

        request.put('SpecialTermE', JSON.serialize(subTranche));

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

        request.put('SpecialTermF', JSON.serialize(subTranche));

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

        request.put('SpecialTermG', JSON.serialize(subTranche));

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

        request.put('SpecialTermH', JSON.serialize(subTranche));

        System.runAs(getCLUser()) {
            GMKPortalCreateMyProgramAPI api = new GMKPortalCreateMyProgramAPI();
            clcommon.Response response = api.invokeAction('', null, request);

            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
        }
    }

    /**
    * @description : Update Existing My Program Success
    * @author  Pritam Roy | 04-30-2024 
    **/
    @IsTest
    public static void testCaseUpdateExistingMyProgramSuccess() {

        TestClassHelper.createTestDataForGrowmarkMyProgram(getDealerAccount().Id); 

        genesis__Rate_Card_Setup_Header__c rateCardHeader = [
                SELECT Id 
                FROM genesis__Rate_Card_Setup_Header__c 
                WHERE Name = 'GMK My Program - 110'
                LIMIT 1
            ];

        List<genesis__Rate_Card_Setup_Detail__c> setupDetailsList = [
            SELECT Id,Start_Date__c,Special_Term_Reference__c
            FROM genesis__Rate_Card_Setup_Detail__c 
            WHERE Description__c IN ('Note Rate', 'Seeds')
            AND Start_Date__c != :System.today()
            
        ];
        Database.delete(setupDetailsList,true);
        List<genesis__Rate_Card_Setup_Detail__c> setupDetails = [
                SELECT Id
                FROM genesis__Rate_Card_Setup_Detail__c 
                WHERE Description__c IN ('Note Rate', 'Seeds')
        ];

        Map<String, Object> request = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put('genesis__End_Date__c', '2025-04-15');
        program.put('Id', rateCardHeader.Id);
        program.put('Name', 'GMK My Program - 110');
        program.put('Crop_Year__c', '2025');
        program.put('FS_Index_Rate__c', 8.75);
        program.put('Closing_Fee__c', 0);
        program.put('Payer_of_Loan_Closing_Fee__c', 'Grower');
        program.put('Loan_Fee_Advanced_On__c', 'A');
        program.put('Dealer_Participate_on_Closing_Fee__c', 'No');

        request.put('program', JSON.serialize(program));

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
                'Interest_Rate_Type__c' => 'Variable',
                'id' => setupDetails[0].Id
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        request.put('NoteRate', JSON.serialize(subTranche));

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
                'Interest_Rate_Type__c' => 'Variable',
                'id' => setupDetails[1].Id
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        request.put('SpecialTermB', JSON.serialize(subTranche));


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

        request.put('SpecialTermC', JSON.serialize(subTranche));


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

        request.put('SpecialTermD', JSON.serialize(subTranche));

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

        request.put('SpecialTermE', JSON.serialize(subTranche));

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

        request.put('SpecialTermF', JSON.serialize(subTranche));

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

        request.put('SpecialTermG', JSON.serialize(subTranche));

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

        request.put('SpecialTermH', JSON.serialize(subTranche));

        System.runAs(getCLUser()) {
            GMKPortalCreateMyProgramAPI api = new GMKPortalCreateMyProgramAPI();
            clcommon.Response response = api.invokeAction('', null, request);

            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Test Success');
        }
    }

    /**
    * @description : Default Rate Success
    * @author  Pritam Roy | 04-30-2024 
    **/
    @IsTest
    public static void testCaseCreateNewMyProgramWithDefaultNoteRateSuccess() {
        
        Map<String, Object> request = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put('genesis__End_Date__c', '2025-04-15');
        program.put('Id', 'new_record_id');
        program.put('Name', 'GMK My Program - 110');
        program.put('Crop_Year__c', '2025');
        program.put('FS_Index_Rate__c', 8.75);
        program.put('Closing_Fee__c', 0);
        program.put('Payer_of_Loan_Closing_Fee__c', 'Grower');
        program.put('Loan_Fee_Advanced_On__c', 'A');
        program.put('Dealer_Participate_on_Closing_Fee__c', 'No');

        request.put('program', JSON.serialize(program));

        // add the interest rate attributes for Note Rate
        Map<String, Object> subTranche = new Map<String, Object>();
        subTranche.put('description', 'Note Rate');

        List<Map<String, Object>> subTrancheInterestList = new List<Map<String, Object>>();
        

        subTranche.put('interest', subTrancheInterestList);

        request.put('NoteRate', JSON.serialize(subTranche));

       

        subTrancheInterestList = new List<Map<String, Object>>();
        

        subTranche.put('interest', subTrancheInterestList);

        request.put('SpecialTermB', JSON.serialize(subTranche));



        subTrancheInterestList = new List<Map<String, Object>>();
        

        subTranche.put('interest', subTrancheInterestList);

        request.put('SpecialTermC', JSON.serialize(subTranche));


        subTrancheInterestList = new List<Map<String, Object>>();
        

        subTranche.put('interest', subTrancheInterestList);

        request.put('SpecialTermD', JSON.serialize(subTranche));

        subTrancheInterestList = new List<Map<String, Object>>();
        

        subTranche.put('interest', subTrancheInterestList);

        request.put('SpecialTermE', JSON.serialize(subTranche));

        subTrancheInterestList = new List<Map<String, Object>>();

        subTranche.put('interest', subTrancheInterestList);

        request.put('SpecialTermF', JSON.serialize(subTranche));

        subTrancheInterestList = new List<Map<String, Object>>();

        subTranche.put('interest', subTrancheInterestList);

        request.put('SpecialTermG', JSON.serialize(subTranche));

        subTrancheInterestList = new List<Map<String, Object>>();

        subTranche.put('interest', subTrancheInterestList);

        request.put('SpecialTermH', JSON.serialize(subTranche));


        System.runAs(getCLUser()) {
            GMKPortalCreateMyProgramAPI api = new GMKPortalCreateMyProgramAPI();
            clcommon.Response response = api.invokeAction('', null, request);

            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Test Success');
        }
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

        genesis__Applications__c application = [
                SELECT Id 
                FROM genesis__Applications__c 
                LIMIT 1
            ];


        System.runAs(getCLUser()) {
            GMKPortalCreateMyProgramAPI api = new GMKPortalCreateMyProgramAPI();
            String flexId = api.createFlexRateCard(application.Id, request);
            // clcommon.Response response = api.invokeAction('', null, request);

            // System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Test Success');
            System.assert(flexId != null, 'Success');
        }
    }

    /**
    * @description : No Interest Rate in any Tranche Success
    * @author  Pritam Roy | 04-30-2024 
    **/
    @IsTest
    public static void testCaseCreateNewFlexRateSuccessNoInterestTranche() {
        
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
        flexRatePricing.put('NoteRate', subTranche);
        flexRatePricing.put('SpecialTermB', subTranche);
        flexRatePricing.put('SpecialTermC', subTranche);
        flexRatePricing.put('SpecialTermD', subTranche);

        flexRatePricing.put('SpecialTermE', subTranche);
        flexRatePricing.put('SpecialTermF', subTranche);
        flexRatePricing.put('SpecialTermG', subTranche);
        flexRatePricing.put('SpecialTermH', subTranche);

        flexCardRequest.put('ratePricing', flexRatePricing);

        Map<String, Object> request = new Map<String, Object>();
        request.put('flexPricing', JSON.serialize(flexCardRequest));
        request.put('shouldValidate', true);

        genesis__Applications__c application = [
                SELECT Id 
                FROM genesis__Applications__c 
                LIMIT 1
            ];


        System.runAs(getCLUser()) {
            GMKPortalCreateMyProgramAPI api = new GMKPortalCreateMyProgramAPI();
            String flexId = api.createFlexRateCard(application.Id, request);
            List<genesis__Rate_Card_Setup_Detail__c> objRateCardList = [SELECT Id,
                                                                                Special_Term_Reference__c 
                                                                            FROM genesis__Rate_Card_Setup_Detail__c 
                                                                            WHERE genesis__Rate_Card_Setup_Header__r.id =: flexId 
                                                                            AND Special_Term_Reference__c = 'Special Term Sub-Tranche (A)'];
            
            System.assertEquals(objRateCardList.size()==0,true,'No Flex Rate Card Found');
        }
    }

    /**
    * @description : Null Tranche Check
    * @author  Pritam Roy | 04-30-2024 
    **/
    @IsTest
    public static void testCaseCreateNewFlexRateNullTrancheException() {
        String flexId;
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
        flexRatePricing.put('NoteRate', null);
        flexRatePricing.put('SpecialTermB', subTranche);
        flexRatePricing.put('SpecialTermC', subTranche);
        flexRatePricing.put('SpecialTermD', subTranche);

        flexRatePricing.put('SpecialTermE', subTranche);
        flexRatePricing.put('SpecialTermF', subTranche);
        flexRatePricing.put('SpecialTermG', subTranche);
        flexRatePricing.put('SpecialTermH', subTranche);

        flexCardRequest.put('ratePricing', flexRatePricing);

        Map<String, Object> request = new Map<String, Object>();
        request.put('flexPricing', JSON.serialize(flexCardRequest));
        request.put('shouldValidate', true);

        genesis__Applications__c application = [
                SELECT Id 
                FROM genesis__Applications__c 
                LIMIT 1
            ];


        System.runAs(getCLUser()) {
            String exceptionString;
            GMKPortalCreateMyProgramAPI api = new GMKPortalCreateMyProgramAPI();
            try{
                flexId = api.createFlexRateCard(application.Id, request);
            }catch(Exception objException){
                exceptionString = objException.getMessage();
            }
            
            System.assertEquals(exceptionString!=null,true,'No Exception');
        }
    }

    /**
    * @description : Random Interest Tranche Success
    * @author  Pritam Roy | 04-30-2024 
    **/
    @IsTest
    public static void testCaseCreateNewFlexRateRandomInterestTranche() {
        
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
        flexRatePricing.put('NoteRate', subTranche);
        flexRatePricing.put('SpecialTermA', subTranche);
        flexRatePricing.put('SpecialTermB', subTranche);
        flexRatePricing.put('SpecialTermF', subTranche);
        flexRatePricing.put('SpecialTermG', subTranche);
        flexRatePricing.put('SpecialTermH', subTranche);


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

        flexRatePricing.put('SpecialTermC', subTranche);

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

        flexRatePricing.put('SpecialTermD', subTranche);


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
        flexRatePricing.put('SpecialTermE', subTranche);

        flexCardRequest.put('ratePricing', flexRatePricing);

        Map<String, Object> request = new Map<String, Object>();
        request.put('flexPricing', JSON.serialize(flexCardRequest));
        request.put('shouldValidate', true);

        genesis__Applications__c application = [
                SELECT Id 
                FROM genesis__Applications__c 
                LIMIT 1
            ];

        String flexId;
        System.runAs(getCLUser()) {
            GMKPortalCreateMyProgramAPI api = new GMKPortalCreateMyProgramAPI();
            flexId = api.createFlexRateCard(application.Id, request);
        }
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardList = [SELECT Id,
                                                                                Special_Term_Reference__c 
                                                                            FROM genesis__Rate_Card_Setup_Detail__c 
                                                                            WHERE genesis__Rate_Card_Setup_Header__r.id =: flexId
                                                                            AND Special_Term_Reference__c = 'Special Term Sub-Tranche (B)'];
            
        System.assertEquals(objRateCardList.size()>0,true,'No Flex Rate Card Found');
    }


    /**
    * @description : Maturity Date Failure
    * @author  Pritam Roy | 04-30-2024 
    **/
    @IsTest
    public static void testCaseCreateNewMyProgramWrongMaturityDateFailure() {
        
        Map<String, Object> request = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put('genesis__End_Date__c', '2024-03-18');
        program.put('Id', 'new_record_id');
        program.put('Name', 'GMK My Program - 110');
        program.put('Crop_Year__c', '2025');
        program.put('FS_Index_Rate__c', 8.75);
        program.put('Closing_Fee__c', 0);
        program.put('Payer_of_Loan_Closing_Fee__c', 'Grower');
        program.put('Loan_Fee_Advanced_On__c', 'A');
        program.put('Dealer_Participate_on_Closing_Fee__c', 'No');

        request.put('program', JSON.serialize(program));

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

        request.put('NoteRate', JSON.serialize(subTranche));

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

        request.put('SpecialTermB', JSON.serialize(subTranche));


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

        request.put('SpecialTermC', JSON.serialize(subTranche));


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

        request.put('SpecialTermD', JSON.serialize(subTranche));

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

        request.put('SpecialTermE', JSON.serialize(subTranche));
        subTranche = new Map<String, Object>();

        request.put('SpecialTermE', JSON.serialize(subTranche));
        request.put('SpecialTermF', JSON.serialize(subTranche));
        request.put('SpecialTermG', JSON.serialize(subTranche));
        System.runAs(getCLUser()) {
            GMKPortalCreateMyProgramAPI api = new GMKPortalCreateMyProgramAPI();
            clcommon.Response response = api.invokeAction('', null, request);

            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Test Success');
        }
    }


    /**
    * @description : Wrong End Date Failure
    * @author  Pritam Roy | 04-30-2024 
    **/
    @IsTest
    public static void testCaseCreateNewMyProgramWrongEndDateFailure() {
        
        Map<String, Object> request = new Map<String, Object>();

        // add the setup header parameters
        Map<String, Object> program = new Map<String, Object>();
        program.put('genesis__End_Date__c', '2025-04-15');
        program.put('Id', 'new_record_id');
        program.put('Name', 'GMK My Program - 110');
        program.put('Crop_Year__c', '2025');
        program.put('FS_Index_Rate__c', 8.75);
        program.put('Closing_Fee__c', 0);
        program.put('Payer_of_Loan_Closing_Fee__c', 'Grower');
        program.put('Loan_Fee_Advanced_On__c', 'A');
        program.put('Dealer_Participate_on_Closing_Fee__c', 'No');

        request.put('program', JSON.serialize(program));

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
                'End_Date__c' => '2024-03-01',
                'genesis__Interest_Rate__c' => 10,
                'Interest_Rate_Type__c' => 'Variable'
            }
        );

        subTranche.put('interest', subTrancheInterestList);

        request.put('NoteRate', JSON.serialize(subTranche));

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

        request.put('SpecialTermB', JSON.serialize(subTranche));


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

        request.put('SpecialTermC', JSON.serialize(subTranche));


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

        request.put('SpecialTermD', JSON.serialize(subTranche));

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

        request.put('SpecialTermE', JSON.serialize(subTranche));
        subTranche = new Map<String, Object>();
        request.put('SpecialTermF', JSON.serialize(subTranche));
        request.put('SpecialTermG', JSON.serialize(subTranche));
        request.put('SpecialTermH', JSON.serialize(subTranche));
        System.runAs(getCLUser()) {
            GMKPortalCreateMyProgramAPI api = new GMKPortalCreateMyProgramAPI();
            clcommon.Response response = api.invokeAction('', null, request);

            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Test Success');
        }
    }


    /**
    * @description : Wrong Arguments Failure
    * @author  Pritam Roy | 04-30-2024 
    **/
    @IsTest
    public static void testCaseCreateNewFlexRateNoDataFailure() {
        
        Map<String, Object> request = new Map<String, Object>();
        request.put('flexPricing', '');
        request.put('shouldValidate', true);

        genesis__Applications__c application = [
                SELECT Id 
                FROM genesis__Applications__c 
                LIMIT 1
            ];

        System.runAs(getCLUser()) {
            
            try {
                GMKPortalCreateMyProgramAPI api = new GMKPortalCreateMyProgramAPI();
                api.createFlexRateCard(application.Id, request);
            
            } catch (Exception objException) {
                System.assertEquals('Something went wrong', objException.getMessage(), 'Success');
            }
        }
    }

    /**
    * @description : Null Flex Pricing Failure
    * @author  Pritam Roy | 04-30-2024 
    **/
    @IsTest
    public static void testCaseCreateNewFlexRateNullFlexPricingException() {
        String flexId;
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
        flexRatePricing.put('NoteRate', subTranche);
        flexRatePricing.put('SpecialTermB', subTranche);
        flexRatePricing.put('SpecialTermC', subTranche);
        flexRatePricing.put('SpecialTermD', subTranche);

        flexRatePricing.put('SpecialTermE', subTranche);
        flexRatePricing.put('SpecialTermF', subTranche);
        flexRatePricing.put('SpecialTermG', subTranche);
        flexRatePricing.put('SpecialTermH', subTranche);

        flexCardRequest.put('ratePricing', flexRatePricing);

        Map<String, Object> request = new Map<String, Object>();
        request.put('flexPricing', null);
        request.put('shouldValidate', true);

        genesis__Applications__c application = [
                SELECT Id 
                FROM genesis__Applications__c 
                LIMIT 1
            ];


        System.runAs(getCLUser()) {
            String exceptionString;
            GMKPortalCreateMyProgramAPI api = new GMKPortalCreateMyProgramAPI();
            try{
                flexId = api.createFlexRateCard(application.Id, request);
            }catch(Exception objException){
                exceptionString = objException.getMessage();
            }
            
            System.assertEquals(exceptionString!=null,true,'No Exception');
        }
    }

    /**
    * @description : Null Should Validate Failure
    * @author  Pritam Roy | 04-30-2024 
    **/
    @IsTest
    public static void testCaseCreateNewFlexRateNullShouldValidateException() {
        String flexId;
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
        flexRatePricing.put('NoteRate', subTranche);
        flexRatePricing.put('SpecialTermB', subTranche);
        flexRatePricing.put('SpecialTermC', subTranche);
        flexRatePricing.put('SpecialTermD', subTranche);

        flexRatePricing.put('SpecialTermE', subTranche);
        flexRatePricing.put('SpecialTermF', subTranche);
        flexRatePricing.put('SpecialTermG', subTranche);
        flexRatePricing.put('SpecialTermH', subTranche);

        flexCardRequest.put('ratePricing', flexRatePricing);

        Map<String, Object> request = new Map<String, Object>();
        request.put('flexPricing', JSON.serialize(flexCardRequest));
        request.put('shouldValidate', null);

        genesis__Applications__c application = [
                SELECT Id 
                FROM genesis__Applications__c 
                LIMIT 1
            ];


        System.runAs(getCLUser()) {
            String exceptionString;
            GMKPortalCreateMyProgramAPI api = new GMKPortalCreateMyProgramAPI();
            try{
                flexId = api.createFlexRateCard(application.Id, request);
            }catch(Exception objException){
                exceptionString = objException.getMessage();
            }
            
            System.assertEquals(exceptionString!=null,true,'No Exception');
        }
    }

}