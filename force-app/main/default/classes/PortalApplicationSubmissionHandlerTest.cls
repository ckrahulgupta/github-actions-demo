/**
 * @description       : test class for PortalApplicationsubmissionHanlder class
 * @author            : Rakesh Saraf
 * @group             : 
 * @last modified on  : 12-26-2024
 * @last modified by  : Kabir Pramanik
**/
@isTest
public without sharing class PortalApplicationSubmissionHandlerTest {
    @TestSetup
    static void setup() {
        
        // Creating floating rate index
        clcommon__Floating_Rate_Index__c floatingRateIndexObj = ApplicationOriginationTestHelper.createFloatingRateIndex(
        New Map<String, Object>{ 'Name' => 'CFA Advantage Rate',
                                    'Base Rate Name' => '4-CFA ADVANTAGE',
                                    'Current Floating Rate' => 11,
                                    'Base Rate Adjuster' => 5.5
        });
        Database.insert(floatingRateIndexObj, true);

        // Creating floating rate
        clcommon__Floating_Rate__c floatingRateObj = ApplicationOriginationTestHelper.createFloatingRate(floatingRateIndexObj);
        Database.insert(floatingRateObj, true);

        // Creating new partnert program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);

        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();

        //creating business info for borrower
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();

        Database.insert(new List<genesis__Business_Information__c>{
        dealerBusinessInfoObj,
        borrowerBusinessInfoObj
        }, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.CFA_Partner_Program__c = newPartnerProgramObj.Id;
        Database.insert(dealerAccountObj, true);

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);

        // Creating Account for Borrower
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        borrowerAccountObj.CIF_Number__c = '141623';
        borrowerAccountObj.BillingStreet = 'Action area 1';

        Database.insert(new List<Account>{
            clAccountObj,
            borrowerAccountObj
        }, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);

        // Creating Contact for Borrower
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);

        Database.insert(new List<Contact>{
            clContactObj,
            borrowerContactObj
        },true);

        //Create Dealer Relationship Record
        Dealer_Applicant_Relationship__c borrowerDealerRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Database.insert(borrowerDealerRelationObj,true);

        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(new List<User>{
            clUserObj,
            borrowerUserObj
        },true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
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
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        applicationObj.Agreement_Sign__c = true;
        applicationObj.Dealer_Applicant_Relationship__c = borrowerDealerRelationObj.Id;
        Database.insert(applicationObj, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        // Creating Certified Lender Party Type
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');

        // Create Borrower Party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(new List<clcommon__Party_Type__c>{
            clPartyTypeObj,
            borrowerPartyTypeObj
        }, true);

        // Creating Certified Lender Party
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        List<clcommon__Party__c> partyObjList = new List<clcommon__Party__c>();

        partyObjList.add(ApplicationOriginationTestHelper.createParty(paramForCLPartyMap));

        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        partyObjList.add(ApplicationOriginationTestHelper.createParty(paramForBorrowerPartyMap));

        ApplicationOriginationSetupTestHelper.createSaSaAdminTestData(dealerBusinessInfoObj,dealerAccountObj);
        ApplicationOriginationSetupTestHelper.createAdditionalTestData(applicationObj,dealerAccountObj);

        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        existingApplicationObj.genesis__Loan_Number__c = '116623344';
        existingApplicationObj.Signing_Method__c = 'Paper - Scanned';
        existingApplicationObj.Submitted_to_CFA__c=Date.newInstance(2024, 08, 08);
        Database.insert(existingApplicationObj,true);

        Map<String,Id> paramForExistingBorrower = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => existingApplicationObj.Id
        };

        partyObjList.add(ApplicationOriginationTestHelper.createParty(paramForExistingBorrower));
        Database.insert(partyObjList,true);

        ApplicationOriginationSetupTestHelper.createPrincipalParty(applicationObj,entityObj, existingApplicationObj);

    }

    /**
    * @description to test for get application details
    * @author Rakesh Saraf | 11-01-2024 
    **/
    @isTest
    private static void testGetApplicationDetails(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();


        Test.startTest();
        System.runAs(adminUserObj) {
            List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicationDetails(applicationObj.id);
            System.assert(applicationList.size()>0, 'Assertion unsuccessful!');
        }
        Test.stopTest();
    }

    /**
    * @description check if the principal parties are returned for the application
    * @author Rakesh Saraf | 11-01-2024 
    **/
    @isTest
    private static void testGetPrincipalPartyList(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        Test.startTest();
        System.runAs(adminUserObj) {
            List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicationDetails(applicationObj.id);

            List<clcommon__Party__c> principalPartyList=PortalApplicationSubmissionHandler.getPrincipalPartyList(applicationList[0]);
            System.assert(principalPartyList.size()>0, 'Assertion unsuccessful!');
        }
        Test.stopTest();
    }

    /**
    * @description check if the my program is fetched for the application
    * @author Rakesh Saraf | 11-04-2024 
    **/
    @isTest
    private static void testGetMyProgram(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.My_Program__c=rateCardObj.Id;
        Database.update(applicationObj,true);

        Test.startTest();
        System.runAs(adminUserObj) {
            List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicationDetails(applicationObj.id);

            genesis__Rate_Card_Setup_Header__c myProgramObj=PortalApplicationSubmissionHandler.getMyProgram(applicationList[0]);
            System.assert(myProgramObj!=null, 'Assertion unsuccessful!');
        }
        Test.stopTest();
    }

    /**
    * @description check if field is updated for the tasks created under the application
    * @author Rakesh Saraf | 11-05-2024 
    **/
    @isTest
    private static void testCheckTask(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Credit_Application_And_Agreement_Process__c = 'Proceed with the requirements for the tier';
        Database.update(applicationObj,true);

        
        Test.startTest();
        System.runAs(adminUserObj) {
            List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicationDetails(applicationObj.id);
            PortalApplicationSubmissionHandler.checkTask(applicationList,false);

            List<Task> taskList=[SELECT Id, Status FROM Task WHERE genesis__Application__c=:applicationList[0].id];
            System.assertEquals('OPEN',taskList[0].Status , 'Assertion success!');
        }
        Test.stopTest();
    }

    /**
    * @description check if field is updated for the tasks created under the tier one application
    * @author Rakesh Saraf | 11-05-2024 
    **/
    @isTest
    private static void testCheckTaskTierOne(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Credit_Application_And_Agreement_Process__c = 'Proceed with the requirements for the tier';
        applicationObj.genesis__Credit_Rating__c=tier.id;

        Database.update(applicationObj,true);

        
        Test.startTest();
        System.runAs(adminUserObj) {
            List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicationDetails(applicationObj.id);
            PortalApplicationSubmissionHandler.checkTask(applicationList,false);

            List<Task> taskList=[SELECT Id, Status FROM Task WHERE genesis__Application__c=:applicationList[0].id];
            System.assertEquals('OPEN',taskList[0].Status , 'Assertion success!');
        }
        Test.stopTest();
    }

    /**
    * @description check if field is updated for the tasks created under the application with credit application and agreement process as Customize
    * @author Rakesh Saraf | 11-05-2024 
    **/
    @isTest
    private static void testCheckTaskCustomizedApplication(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Credit_Application_And_Agreement_Process__c = 'Customize';
        applicationObj.Jointly_Payable_Proceeds_Checks__c=true;
        applicationObj.Assignment_Of_Insurance__c=true;
        applicationObj.Spousal_Consent__c=true;
        Database.update(applicationObj,true);

        
        Test.startTest();
        System.runAs(adminUserObj) {
            List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicationDetails(applicationObj.id);

            PortalApplicationSubmissionHandler.checkTask(applicationList,false);

            List<Task> taskList=[SELECT Id, Status FROM Task WHERE genesis__Application__c=:applicationList[0].id];
            System.assertEquals('Completed',taskList[0].Status , 'Assertion success!');
        }
        Test.stopTest();
    }

    @isTest
    private static void testUpdateApplicationTerms(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        
        Test.startTest();
        System.runAs(adminUserObj){
            List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicationDetails(applicationObj.id);

            PortalApplicationSubmissionHandler.updateApplicationTerms(applicationList[0],rateCardObj);
            System.assertEquals(rateCardObj.genesis__End_Date__c,applicationList[0].genesis__Maturity_Date__c,'Assertion unsuccessfull');
        }
        Test.stopTest();
    }

    /**
    * @description test for UpdateAutoBook function where the borrower is new and autobook is not possible
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void testAutoBookNotPossibleForNewBorrower(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Signing_Method__c = PortalConstants.PAPER_SCANNED;
        applicationObj.genesis__Credit_Rating__c=tier.id;
        Database.update(applicationObj,true);

        genesis__Applications__c existingApplication=[SELECT id FROM genesis__Applications__c WHERE genesis__Loan_Number__c ='116623344' LIMIT 1];
        Database.delete(existingApplication,true);

        List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicationDetails(applicationObj.id);
        List<clcommon__Party__c> principalPartyList=PortalApplicationSubmissionHandler.getPrincipalPartyList(applicationList[0]);

        Id borrowerAccId=ApplicationOriginationTestHelper.getDealerAccoount().id;
        Id principlAccId=ApplicationOriginationTestHelper.getPrincipalAccount().id;

        Test.startTest();
        System.runAs(adminUserObj){

            Boolean isAutoBookPossible=PortalApplicationSubmissionHandler.updateAutoBook(new Map<String,Object>{
                                                                                                            'application'=>applicationList[0],
                                                                                                            'isAutoBookPossible'=>false,
                                                                                                            'borrowerAcc'=>borrowerAccId},
                                                                                        new Map<String, List<Object>>{
                                                                                                            'currentApplication'=>applicationList,
                                                                                                            'principal'=>principalPartyList,
                                                                                                            'principalAcc'=>new List<Id>{principlAccId}                    
                                                                                        });

            System.assertEquals(false,isAutoBookPossible,'Assertion unsuccessful');
        }
        Test.stopTest();
    }

    /**
    * @description test for UpdateAutoBook function where the borrower is new and autobook is possible
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void testAutoBookPossibleForNewBorrower(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.genesis__Credit_Rating__c=tier.id;
        Database.update(applicationObj,true);

        genesis__Applications__c existingApplication=[SELECT id FROM genesis__Applications__c WHERE genesis__Loan_Number__c ='116623344' LIMIT 1];
        Database.delete(existingApplication,true);

        List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicationDetails(applicationObj.id);
        List<clcommon__Party__c> principalPartyList=PortalApplicationSubmissionHandler.getPrincipalPartyList(applicationList[0]);

        Id borrowerAccId=ApplicationOriginationTestHelper.getDealerAccoount().id;
        Id principlAccId=ApplicationOriginationTestHelper.getPrincipalAccount().id;

        Test.startTest();
        System.runAs(adminUserObj){

            Boolean isAutoBookPossible=PortalApplicationSubmissionHandler.updateAutoBook(new Map<String,Object>{
                                                                                                            'application'=>applicationList[0],
                                                                                                            'isAutoBookPossible'=>false,
                                                                                                            'borrowerAcc'=>borrowerAccId},
                                                                                        new Map<String, List<Object>>{
                                                                                                            'currentApplication'=>applicationList,
                                                                                                            'principal'=>principalPartyList,
                                                                                                            'principalAcc'=>new List<Id>{principlAccId}                   
                                                                                        });

            System.assertEquals(true,isAutoBookPossible,'Assertion unsuccessful');
        }
        Test.stopTest();
    }

    /**
    * @description test for updateAutoBook when there already exisits an application for the borrower with the status as active
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void testAutoBookPossibleForExistingBorrower(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 1' LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.genesis__Credit_Rating__c=tier.id;
        Database.update(applicationObj,true);

        Task entityDocTask=ApplicationOriginationTestHelper.getTask('Entity Documents',applicationObj.id);
        entityDocTask.Status=PortalConstants.OPEN_TASK_STATUS;
        Database.update(entityDocTask,true);

        List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicationDetails(applicationObj.id);
        List<clcommon__Party__c> principalPartyList=PortalApplicationSubmissionHandler.getPrincipalPartyList(applicationList[0]);

        Id borrowerAccId=ApplicationOriginationTestHelper.getDealerAccoount().id;
        Id principlAccId=ApplicationOriginationTestHelper.getPrincipalAccount().id;

        Test.startTest();
        System.runAs(adminUserObj){

            Boolean isAutoBookPossible=PortalApplicationSubmissionHandler.updateAutoBook(new Map<String,Object>{
                                                                                                            'application'=>applicationList[0],
                                                                                                            'isAutoBookPossible'=>false,
                                                                                                            'borrowerAcc'=>borrowerAccId},
                                                                                        new Map<String, List<Object>>{
                                                                                                            'currentApplication'=>applicationList,
                                                                                                            'principal'=>principalPartyList,
                                                                                                            'principalAcc'=>new List<Id>{principlAccId}                    
                                                                                        });

            System.assertEquals(true,isAutoBookPossible,'Assertion unsuccessful');
        }
        Test.stopTest();
    }

    /**
    * @description test for updateAutoBook when there already exisits an application for the borrower with the status as active
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void testAutoBookNotPossibleForExistingBorrower(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3' LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Signing_Method__c = PortalConstants.PAPER_SCANNED;
        applicationObj.genesis__Credit_Rating__c=tier.id;
        Database.update(applicationObj,true);

        List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicationDetails(applicationObj.id);
        List<clcommon__Party__c> principalPartyList=PortalApplicationSubmissionHandler.getPrincipalPartyList(applicationList[0]);

        Id borrowerAccId=ApplicationOriginationTestHelper.getDealerAccoount().id;
        Id principlAccId=ApplicationOriginationTestHelper.getPrincipalAccount().id;

        Test.startTest();
        System.runAs(adminUserObj){

            Boolean isAutoBookPossible=PortalApplicationSubmissionHandler.updateAutoBook(new Map<String,Object>{
                                                                                                            'application'=>applicationList[0],
                                                                                                            'isAutoBookPossible'=>false,
                                                                                                            'borrowerAcc'=>borrowerAccId},
                                                                                        new Map<String, List<Object>>{
                                                                                                            'currentApplication'=>applicationList,
                                                                                                            'principal'=>principalPartyList,
                                                                                                            'principalAcc'=>new List<Id>{principlAccId}                  
                                                                                        });

            System.assertEquals(false,isAutoBookPossible,'Assertion unsuccessful');
        }
        Test.stopTest();
    }

    /**
    * @description delete the principal parties for the application
    * @author Rakesh Saraf | 11-10-2024 
    * @param applicationId 
    * @param typeString 
    **/
    public static void deleteParty(Id applicationId,String typeString){

        clcommon__Party_Type__c principalPartyType=[SELECT Id FROM clcommon__Party_Type__c WHERE Name=:typeString LIMIT 1];
        List<clcommon__Party__c> principalPartyList = [SELECT  Id,
                                                                clcommon__Account__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__c = :applicationId AND
                                                                clcommon__Type__c = :principalPartyType.id];

        Database.delete(principalPartyList,true);
    }

    /**
    * @description test for updateAutoBook when there already exisits an application for the borrower with the status as active but with a different principal
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void testAutoBookNotPossibleWithDifferentPrincipal(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 1' LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.genesis__Credit_Rating__c=tier.id;
        Database.update(applicationObj,true);

        Task entityDocTask=ApplicationOriginationTestHelper.getTask('Entity Documents',applicationObj.id);
        entityDocTask.Status=PortalConstants.OPEN_TASK_STATUS;
        Database.update(entityDocTask,true);

        genesis__Applications__c existingApp=[SELECT ID FROM genesis__Applications__c WHERE genesis__Loan_Number__c='116623344' LIMIT 1];

        deleteParty(existingApp.id,'PRINCIPAL');
        createPrincipalPartyForApplication(existingApp.id);

        List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicationDetails(applicationObj.id);
        List<clcommon__Party__c> principalPartyList=PortalApplicationSubmissionHandler.getPrincipalPartyList(applicationList[0]);

        Id borrowerAccId=ApplicationOriginationTestHelper.getDealerAccoount().id;
        Id principlAccId=ApplicationOriginationTestHelper.getPrincipalAccount().id;

        Test.startTest();
        System.runAs(adminUserObj){

            Boolean isAutoBookPossible=PortalApplicationSubmissionHandler.updateAutoBook(new Map<String,Object>{
                                                                                                            'application'=>applicationList[0],
                                                                                                            'isAutoBookPossible'=>false,
                                                                                                            'borrowerAcc'=>borrowerAccId},
                                                                                        new Map<String, List<Object>>{
                                                                                                            'currentApplication'=>applicationList,
                                                                                                            'principal'=>principalPartyList,
                                                                                                            'principalAcc'=>new List<Id>{principlAccId}                  
                                                                                        });

            System.assertEquals(false,isAutoBookPossible,'Assertion unsuccessful');
        }
        Test.stopTest();
    }

    /**
    * @description creating a new principal party for comparing if the parties of the application are same to those of the existing application
    * @author Rakesh Saraf | 11-10-2024 
    * @param applicationId 
    **/
    public static void createPrincipalPartyForApplication(Id applicationId){
        //QUERYING business info for principal
        genesis__Business_Information__c principalBusinessInfoObj = [SELECT ID
                                                                        FROM genesis__Business_Information__c
                                                                        WHERE genesis__Business_Country__c='India'
                                                                        LIMIT 1];


        clcommon__Legal_Entity__c entityObj=[SELECT ID 
                                                FROM clcommon__Legal_Entity__c
                                                WHERE Name = 'Individual(s) - Sole Proprietorship'
                                                LIMIT 1];
        // Creating CoApplicant Account
        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(entityObj,principalBusinessInfoObj.Id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        Database.insert(coBorrowerAccountObj,true);

        //Creating Co-Applicant contact
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.Id);
        coBorrowerContactObj.Confirm_SSN__c='982983834';
        Database.insert(coBorrowerContactObj,true);

        // QUERYING Principal party type
        clcommon__Party_Type__c principalPartyType=[SELECT Id FROM clcommon__Party_Type__c WHERE Name= 'PRINCIPAL' LIMIT 1];

        // Creating Principal Party for current application

        clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                                        'accountId' => coBorrowerAccountObj.Id,
                                                                                                        'contactId' => coBorrowerContactObj.Id,
                                                                                                        'partyTypeId' => principalPartyType.Id,
                                                                                                        'applicationId' => applicationId
                                                                                                    });
        Database.insert(principalPartyObj,true);
    }

    /**
    * @description test for excpetion in the method generate pricing
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void testGeneratePricingException(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.My_Program__c=null;

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Test.startTest();
        System.runAs(adminUserObj){
            try{
                PortalApplicationSubmissionHandler.generatePricing(applicationObj, rateCardObj);
            }
            catch(CustomException e){
                System.assertEquals('Please enter the my program for the application.',e.getMessage(),'Assertion unsuccessful');
            }
        }
        Test.stopTest();
    }

    /**
    * @description test the method generatePricing
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void testGeneratePricing(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.My_Program__c=rateCardObj.id;

        Test.startTest();
        System.runAs(adminUserObj){

            PortalApplicationSubmissionHandler.generatePricing(applicationObj, rateCardObj);
            System.assertEquals(rateCardObj.genesis__End_Date__c,applicationObj.genesis__Maturity_Date__c,'Assertion unsuccessful');
        }
        Test.stopTest();
    }

    
    /**
    * @description test for generatesLoanNumber when an application alsready exisits for the borrower
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void testgeneratesLoanNumber(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        Test.startTest();
        System.runAs(adminUserObj){
            PortalApplicationSubmissionHandler.generatesLoanNumber( applicationObj, false);
            System.assertEquals('116623345',applicationObj.genesis__Loan_Number__c,'Assertion unsuccessful');
        }
        Test.stopTest();
    }
    /**
    * @description test for generatesLoanNumber when the applicant is a new one
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void testgeneratesLoanNumberNewBorrower(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        genesis__Applications__c existingApplication=[SELECT ID FROM genesis__Applications__c WHERE genesis__Loan_Number__c='116623344' LIMIT 1];
        deleteParty(existingApplication.id,'BORROWER');

        Test.startTest();
        System.runAs(adminUserObj){
            PortalApplicationSubmissionHandler.generatesLoanNumber( applicationObj, false);
            System.assertEquals('141623001',applicationObj.genesis__Loan_Number__c,'Assertion unsuccessful');
        }
        Test.stopTest();
    }

    /**
    * @description test for upfateApplicationPricing method
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void testUpdateApplicationPricing(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        List<genesis__Application_Pricing_Detail__c> appPricingList=new List<genesis__Application_Pricing_Detail__c>();

        Test.startTest();
        System.runAs(adminUserObj){
            PortalApplicationSubmissionHandler.updateApplicationPricing(applicationObj, appPricingList, 0);
            System.assert(appPricingList.size()>0,'Assertion Failed');
        }
        Test.stopTest();
    }

    /**
    * @description test if the Certified Lenders Signature field is getting populated in the application or not
    * @author Rakesh Saraf | 11-10-2024 
    **/
    // @isTest
    // private Static void testCLSignature(){
    //     User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
    //     genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
    //     applicationObj.Certified_Lenders_Signature__c=null;

    //     genesis__Business_Information__c dealerBusinessInfo=[SELECT ID FROM genesis__Business_Information__c WHERE genesis__Business_Country__c='India' LIMIT 1];

    //     Account dealerAcc=[SELECT ID FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];

    //     clcommon__Reciprocal_Role__c clRole=[SELECT ID FROM clcommon__Reciprocal_Role__c WHERE Name='Certified Lender' LIMIT 1];

    //     Test.startTest();
    //     System.runAs(clUserObj){
    //         ApplicationOriginationTestHelper.createNewClUser(dealerBusinessInfo,dealerAcc,clRole);
    //         
    //         PortalApplicationSubmissionHandler.updateCertifiedLendersSignature(applicationObj);
    //         System.assert(applicationObj.Certified_Lenders_Signature__c!=null,'Assertion Failed');
    //     }
    //     Test.stopTest();
    // }

    /**
    * @description test statement code for growmark
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void updateStatementCodeGMK(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        Test.startTest();
        System.runAs(adminUserObj){
            List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicationDetails(applicationObj.id);

            PortalApplicationSubmissionHandler.updateStatementCode(applicationList[0],'Growmark', 1);
            System.assertEquals('MONTHLY STATEMENT-GMK',applicationList[0].Statement_Code__c,'Assertion Unsuccessful');
        }
        Test.stopTest();
    }

    /**
    * @description test statement code for growmark with multiple pricing
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void updateStatementCodeGMKMulitplePricing(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        genesis__Rate_Card_Setup_Detail__c rateCardDetail = ApplicationOriginationTestHelper.getApplicationRateCardDetail();

        Test.startTest();
        System.runAs(adminUserObj){
            List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicationDetails(applicationObj.id);
            genesis__Application_Pricing_Detail__c pricingDetail = ApplicationOriginationTestHelper.createEnabledPricingDetail(applicationList[0],rateCardDetail.Id);
            Database.insert(pricingDetail,true);

            PortalApplicationSubmissionHandler.updateStatementCode(applicationList[0],'Growmark', 2);
            System.assertEquals('COMMITMENT-GROWMARK', applicationList[0].Statement_Code__c,'Assertion Unsuccessful');
        }
        Test.stopTest();
    }

    /**
    * @description test statement code when coop type is null
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void updateStatementCodeNull(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        Test.startTest();
        System.runAs(adminUserObj){
            List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicationDetails(applicationObj.id);

            try{
                PortalApplicationSubmissionHandler.updateStatementCode(applicationList[0],null, 2);
            } catch(Exception e){
                System.assertEquals('Something went wrong',e.getMessage(),'Assertion Unsuccessful');
            }
        }
        Test.stopTest();
    }

    /**
    * @description test statement code for cfa
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void updateStatementCodeCFA(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        Test.startTest();
        System.runAs(adminUserObj){

            PortalApplicationSubmissionHandler.updateStatementCode(applicationObj,'CFA', 1);
            System.assertEquals('COMMITMENT SINGLE OPT OUT',applicationObj.Statement_Code__c,'Assertion Unsuccessful');
        }
        Test.stopTest();
        
    }

     /**
    * @description test statement code for cfa with multiple pricing
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void updateStatementCodeCFAMulitplePricing(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        genesis__Rate_Card_Setup_Detail__c rateCardDetail = ApplicationOriginationTestHelper.getApplicationRateCardDetail();

        Test.startTest();
        System.runAs(adminUserObj){
            List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicationDetails(applicationObj.id);
            genesis__Application_Pricing_Detail__c pricingDetail = ApplicationOriginationTestHelper.createEnabledPricingDetail(applicationList[0],rateCardDetail.Id);
            Database.insert(pricingDetail,true);

            PortalApplicationSubmissionHandler.updateStatementCode(applicationList[0],'CFA', 2);
            System.assertEquals('COMMITMENT MULTI OPT OUT',applicationList[0].Statement_Code__c,'Assertion Unsuccessful');
        }
        Test.stopTest();
    }

    /**
    * @description test if autobook is false when there are non accural loans for a borrower 
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void testAutoBookForNonAccuralLoans(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        Map<String, List<Id>> autoBookMap = new Map<String,List<Id>>();
        genesis__Applications__c existingApp=[SELECT ID,Non_Accrual__c,Dealer_Name__c, Dealer_Applicant_Relationship__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c='300023456' LIMIT 1];
        //existingApp.Non_Accrual__c=true;
        //Database.update(existingApp,true);
        Dealer_Applicant_Relationship__c borrowerDealerRelationObj = new Dealer_Applicant_Relationship__c(Id = existingApp.Dealer_Applicant_Relationship__c);
        borrowerDealerRelationObj.Is_Non_Accrual__c = true;
        Database.update(borrowerDealerRelationObj,true);

        List<Id> applicantsIdList=ApplicationOriginationTestHelper.getPartiesIdList(existingApp.id);
        autoBookMap.put('borrowerPrincipalIdList',applicantsIdList);
        autoBookMap.put('dealerIdList',new List<Id>{existingApp.Dealer_Name__c});
        Test.startTest();
        System.runAs(adminUserObj){
            
            Boolean isAutoBookPossible=PortalApplicationSubmissionHandler.updateAutobookForNonAccuralLoans(autoBookMap,true);
            System.assertEquals(false,isAutoBookPossible,'Assertion Unsuccessful');
        }
        Test.stopTest();
    }

    /**
    * @description test calcBorrowerTotalLoanAmount to return true as the loan amount of boht the application is less than 1000000
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void testCalcBorrowerTotalLoanAmount(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        Test.startTest();
        System.runAs(adminUserObj){
            List<genesis__Applications__c> applicationList=PortalApplicationSubmissionHandler.getApplicationDetails(applicationObj.id);
            
            Boolean isAutoBookPossible=PortalApplicationSubmissionHandler.calcBorrowerTotalLoanAmount(applicationList);
            System.assertEquals(true,isAutoBookPossible,'Assertion Unsuccessful');
        }
        Test.stopTest();
    }

    /**
    * @description test whether a new note is stored for the application when a note is passed
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void testUpdateNote(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        Test.startTest();
        System.runAs(adminUserObj){

            PortalApplicationSubmissionHandler.updateNote(new Map<String, Object> {
                                                                                    'note' => 'This is a test note!'
                                                                                }, applicationObj);
            List<Note> noteList=[SELECT ID FROM NOTE WHERE ParentId = :applicationObj.id];
            System.assert(noteList.size()==1,'Assertion Unsuccessful');
        }
    }

    /**
    * @description create a test note for the application
    * @author Rakesh Saraf | 11-10-2024 
    * @param applicationId 
    **/
    public static void createDealerNote(Id applicationId){
        Note noteObj=new Note();
        noteObj.Title = PortalConstants.DEALER_NOTE_TITLE;
        noteObj.Body = 'Note';
        noteObj.ParentId = applicationId;
        Database.insert(noteObj,true);
    }

    /**
    * @description test whether a new note is stored for the application even when an existing note is present
    * @author Rakesh Saraf | 11-10-2024 
    **/
    @isTest
    private static void testUpdateNoteForExistingNote(){
        User adminUserObj = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        createDealerNote(applicationObj.id);

        Test.startTest();
        System.runAs(adminUserObj){

            PortalApplicationSubmissionHandler.updateNote(new Map<String, Object> {
                                                                                    'note' => 'This is a test note!'
                                                                                }, applicationObj);
            List<Note> noteList=[SELECT ID,Body FROM NOTE WHERE ParentId = :applicationObj.id];
            System.assert(noteList.size()==1,'Assertion Unsuccessful');
            System.assertEquals('This is a test note!',noteList[0].Body,'Assertion Unsuccessful');
        }
        
    }

}