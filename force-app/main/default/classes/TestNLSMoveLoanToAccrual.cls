/**
 * @description       : Test Class for NLSMoveLoanToAccrual
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-20-2025
 * @last modified by  : Ayan Khanra
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   18-01-2023   Subham Nandi   Initial Version
**/
@isTest 
public with sharing class TestNLSMoveLoanToAccrual {
    
    /**
    * @description 
    * @author Tuhin Bhunia | 05-08-2024 
    **/
    @testSetup
    static void setup() {
        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c gmkDealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj, gmkDealerBusinessInfoObj}, true);

        // Creating Individual sole prop Legal Entity for Borrower
        clcommon__Legal_Entity__c solePropEntityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();

        // Creating Corporation Legal Entity
        clcommon__Legal_Entity__c corporationEntityObj = ApplicationOriginationTestHelper.createCorporationLegalEntity();

        // Creating Individual with DBA Legal 
        clcommon__Legal_Entity__c dbaEntityObj = ApplicationOriginationTestHelper.createDBALegalEntity();

        Database.Insert(new List<clcommon__Legal_Entity__c>{
            solePropEntityObj,
            corporationEntityObj,
            dbaEntityObj
        }, true);

        // Creating Dealer Party Type
        clcommon__Party_Type__c dealerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.DEALER_PARTY_NAME);

        // Creating Certified Lender Party Type
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.CL_PARTY_NAME);

        // Create Borrower Party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);

        // Creating Principal party type
        clcommon__Party_Type__c principalPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.PRINCIPAL_PARTY_NAME);

        Database.Insert(new List<clcommon__Party_Type__c>{
            dealerPartyTypeObj,
            clPartyTypeObj,
            borrowerPartyTypeObj,
            principalPartyTypeObj
        }, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Account gmkDealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(gmkDealerBusinessInfoObj.Id);
        gmkDealerAccountObj.Coop_Type__c = 'Growmark';
        Database.insert(new List<Account>{dealerAccountObj, gmkDealerAccountObj}, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Account gmkClAccountObj = ApplicationOriginationTestHelper.createCLAccount(gmkDealerBusinessInfoObj.Id, gmkDealerAccountObj.Id);


        // Creating sole prop Account for Borrower
        Account solePropBorrowerAccObj = ApplicationOriginationTestHelper.createSolePropAccount(solePropEntityObj, ApplicationOriginationTestHelper.createBusinessInfoForBorrower().Id);
        solePropBorrowerAccObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId();

        // Creating CoApplicant Account
        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(solePropEntityObj,ApplicationOriginationTestHelper.createBusinessInfoForBorrower().Id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.CO_APPLICATION_RECORD_TYPE).getRecordTypeId();

        Database.Insert(new List<Account>{
            clAccountObj,
            gmkClAccountObj,
            solePropBorrowerAccObj,
            coBorrowerAccountObj
        }, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Contact gmkClContactObj = ApplicationOriginationTestHelper.createCLContact(gmkClAccountObj.Id);

        // Creating Contact for Borrower
        Contact solePropBorrowerContObj = ApplicationOriginationTestHelper.createBorrowerContact(solePropBorrowerAccObj.Id);

        //Creating Co-Applicant contact
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.Id);

        Database.Insert(new List<Contact>{
            clContactObj,
            gmkClContactObj,
            solePropBorrowerContObj,
            coBorrowerContactObj
        }, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelObj = ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id, clAccountObj.Id);
        clcommon__Relationship__c gmkClDealerRelObj = ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,gmkDealerAccountObj.Id, gmkClAccountObj.Id);
        Database.insert(new List<clcommon__Relationship__c>{clDealerRelObj, gmkClDealerRelObj}, true);

        // Creating map for Application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => solePropBorrowerAccObj.Id,
            'borrowerContactId' => solePropBorrowerContObj.Id,
            'clAccountId' => clAccountObj.Id
        };
        // Creating Application
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);

        // Creating GMK Application
        genesis__Applications__c gmkApplicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(new Map<String,Id>{
            'dealerAccountId' => gmkDealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => solePropBorrowerAccObj.Id,
            'borrowerContactId' => solePropBorrowerContObj.Id,
            'clAccountId' => gmkClAccountObj.Id
        });
        gmkApplicationObj.genesis__Loan_Number__c = '100630001';
        gmkApplicationObj.Loan_Id__c = '333344';
        Database.insert(new List<genesis__Applications__c>{applicationObj, gmkApplicationObj}, true);

        Map<String, Id> partyDetailsMap = new Map<String, Id>{
            'dealerAccountId' =>  dealerAccountObj.Id,
            'gmkDealerAccountId' =>  gmkDealerAccountObj.Id,
            'clAccountId' =>  clAccountObj.Id,
            'gmkClAccountId' =>  gmkClAccountObj.Id,
            'borrowerAccountId' => solePropBorrowerAccObj.Id,
            'principalAccountId' => coBorrowerAccountObj.Id,
            'clContactId' =>  clContactObj.Id,
            'gmkClContactId' =>  gmkClContactObj.Id,
            'borrowerContactId' => solePropBorrowerContObj.Id,
            'principalContactId' => coBorrowerContactObj.Id,
            'dealerPartyTypeId' =>  dealerPartyTypeObj.Id,
            'clPartyTypeId' =>  clPartyTypeObj.Id,
            'borrowerPartyTypeId' => borrowerPartyTypeObj.Id,
            'principalPartyTypeId' => principalPartyTypeObj.Id,
            'applicationId' =>  applicationObj.Id,
            'gmkApplicationId' =>  gmkApplicationObj.Id
        };

        List<clcommon__party__c> partyList = createPartyForApplication(partyDetailsMap,solePropBorrowerContObj,coBorrowerContactObj);
        Database.Insert(partyList, true);


        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerAccountObj);

        genesis__Rate_Card_Setup_Header__c rateCardHeaderObjTwo = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerAccountObj);
        rateCardHeaderObjTwo.Name = 'Test Rate Card Header With Two Tranches';

        Database.Insert(new List<genesis__Rate_Card_Setup_Header__c>{
            rateCardHeaderObj,
            rateCardHeaderObjTwo
        }, true);

        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailsObjA =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        rateCardSetupDetailsObjA.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_A;

        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailsObjAA =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObjTwo);
        rateCardSetupDetailsObjAA.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_A;

        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailsObjAB =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObjTwo);
        rateCardSetupDetailsObjAB.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_B;

        Database.Insert(new List<genesis__Rate_Card_Setup_Detail__c>{
            rateCardSetupDetailsObjA,
            rateCardSetupDetailsObjAA,
            rateCardSetupDetailsObjAB
        }, true);

        genesis__Application_Pricing_Detail__c pricingDetailsForA = ApplicationOriginationTestHelper.createEnabledPricingDetail(applicationObj, rateCardSetupDetailsObjA.Id);
        Database.insert(pricingDetailsForA,true);
        
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 05-07-2024 
    * @param partyDetailsMap 
    * @param borrowerContactObj
    * @param coBorrowerContactObj
    * @return List<clcommon__party__c> 
    **/
    private static List<clcommon__party__c> createPartyForApplication(Map<String, Id> partyDetailsMap, Contact borrowerContactObj, Contact coBorrowerContactObj){

        Dealer_Applicant_Relationship__c dealerBorrRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj, partyDetailsMap.get('dealerAccountId'));
        Dealer_Applicant_Relationship__c dealerCoBorrRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(coBorrowerContactObj, partyDetailsMap.get('dealerAccountId'));
        Dealer_Applicant_Relationship__c gmkDealerBorrRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj, partyDetailsMap.get('gmkDealerAccountId'));
        Dealer_Applicant_Relationship__c gmkDealerCoBorrRelObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(coBorrowerContactObj, partyDetailsMap.get('gmkDealerAccountId'));
        Database.insert(new List<Dealer_Applicant_Relationship__c>{dealerBorrRelationObj, dealerCoBorrRelationObj, gmkDealerBorrRelationObj, gmkDealerCoBorrRelObj},true);

        // Creating Dealer Party
        Map<String,Id> paramForDealerPartyMap = new Map<String,Id>{
            'accountId' =>  partyDetailsMap.get('dealerAccountId'),
            'contactId' =>  null,
            'partyTypeId' =>  partyDetailsMap.get('dealerPartyTypeId'),
            'applicationId' =>  partyDetailsMap.get('applicationId')
        };
        clcommon__Party__c dealerPartyObj = ApplicationOriginationTestHelper.createParty(paramForDealerPartyMap);

        // Creating Certified Lender Party
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
            'accountId' =>  partyDetailsMap.get('clAccountId'),
            'contactId' =>  partyDetailsMap.get('clContactId'),
            'partyTypeId' =>  partyDetailsMap.get('clPartyTypeId'),
            'applicationId' =>  partyDetailsMap.get('applicationId')
        };
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(paramForCLPartyMap);

        // Creating Borrower Party
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId' => partyDetailsMap.get('borrowerAccountId'),
            'contactId' => partyDetailsMap.get('borrowerContactId'),
            'partyTypeId' => partyDetailsMap.get('borrowerPartyTypeId'),
            'applicationId' => partyDetailsMap.get('applicationId')
        };
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(paramForBorrowerPartyMap);
        borrowerPartyObj.Dealer_Applicant_Relationship__c = dealerBorrRelationObj.id;

        // Creating Principal Party
        Map<String,Id> paramForPrincipalPartyMap = new Map<String,Id>{
            'accountId' => partyDetailsMap.get('principalAccountId'),
            'contactId' => partyDetailsMap.get('principalContactId'),
            'partyTypeId' => partyDetailsMap.get('principalPartyTypeId'),
            'applicationId' => partyDetailsMap.get('applicationId')
        };
        clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createParty(paramForPrincipalPartyMap);
        principalPartyObj.Dealer_Applicant_Relationship__c = dealerCoBorrRelationObj.id;

        // Creating Dealer Party
        Map<String,Id> paramForGMKDealerPartyMap = new Map<String,Id>{
            'accountId' =>  partyDetailsMap.get('gmkDealerAccountId'),
            'contactId' =>  null,
            'partyTypeId' =>  partyDetailsMap.get('dealerPartyTypeId'),
            'applicationId' =>  partyDetailsMap.get('gmkApplicationId')
        };
        clcommon__Party__c gmkDealerPartyObj = ApplicationOriginationTestHelper.createParty(paramForGMKDealerPartyMap);

        // Creating Certified Lender Party
        Map<String,Id> paramForGMKCLPartyMap = new Map<String,Id>{
            'accountId' =>  partyDetailsMap.get('gmkClAccountId'),
            'contactId' =>  partyDetailsMap.get('gmkClContactId'),
            'partyTypeId' =>  partyDetailsMap.get('clPartyTypeId'),
            'applicationId' =>  partyDetailsMap.get('gmkApplicationId')
        };
        clcommon__Party__c gmkClPartyObj = ApplicationOriginationTestHelper.createParty(paramForGMKCLPartyMap);

        // Creating Borrower Party
        clcommon__Party__c gmkBorrowerPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
            'accountId' => partyDetailsMap.get('borrowerAccountId'),
            'contactId' => partyDetailsMap.get('borrowerContactId'),
            'partyTypeId' => partyDetailsMap.get('borrowerPartyTypeId'),
            'applicationId' => partyDetailsMap.get('gmkApplicationId')
        });
        gmkBorrowerPartyObj.Dealer_Applicant_Relationship__c = gmkDealerBorrRelationObj.id;

        // Creating Principal Party
        clcommon__Party__c gmkPrincipalPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
            'accountId' => partyDetailsMap.get('principalAccountId'),
            'contactId' => partyDetailsMap.get('principalContactId'),
            'partyTypeId' => partyDetailsMap.get('principalPartyTypeId'),
            'applicationId' => partyDetailsMap.get('gmkApplicationId')
        });
        gmkPrincipalPartyObj.Dealer_Applicant_Relationship__c = gmkDealerCoBorrRelObj.id;

        return new List<clcommon__party__c>{
            dealerPartyObj,
            clPartyObj,
            borrowerPartyObj,
            principalPartyObj,
            gmkDealerPartyObj,
            gmkClPartyObj,
            gmkBorrowerPartyObj,
            gmkPrincipalPartyObj
        };
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 05-07-2024 
    **/
    @isTest
    public static void testApiSucessForSolePropApplication(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                            genesis__Loan_Number__c,
                                                            Loan_Id__c,
                                                            Non_Accrual__c,
                                                            genesis__Account__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        applicationList[0].genesis__Loan_Number__c = '9'+applicationList[0].genesis__Loan_Number__c;
        applicationList[0].Non_Accrual__c = true;
        Database.update(applicationList,true);

        List<genesis__Application_Pricing_Detail__c> pricingDetailObjList = [SELECT Id, 
                                                                                        loan_Number__c
                                                                                FROM genesis__Application_Pricing_Detail__c 
                                                                                WHERE genesis__Application__c = :applicationList[0].Id];
        for(genesis__Application_Pricing_Detail__c childLoanObj: pricingDetailObjList){
            childLoanObj.loan_Number__c = applicationList[0].genesis__Loan_Number__c;
        }   
        Database.update(pricingDetailObjList,true);   
        List<Dealer_Applicant_Relationship__c> borrowerDealerRelList = [SELECT Id,
                                                                            Applicant__r.clcommon__Legal_Entity_Type__c,
                                                                            Is_Non_Accrual__c
                                                                        FROM Dealer_Applicant_Relationship__c 
                                                                        WHERE Applicant__r.Name = 'Jasmine Albin' 
                                                                        AND Dealer__r.Coop_Type__c != 'Growmark'
                                                                        LIMIT 1];
        borrowerDealerRelList[0].Is_Non_Accrual__c = true;
        Database.update(borrowerDealerRelList,true);

        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                NLSMoveLoanToAccrual.moveToAccrual(applicationList[0].Id);
                Test.stopTest();
                List<genesis__Applications__c> updatedApplicationList = [SELECT Id, 
                                                                            genesis__Loan_Number__c,
                                                                            Non_Accrual__c,
                                                                            Loan_Id__c
                                                                        FROM genesis__Applications__c 
                                                                        WHERE Loan_Id__c = :applicationList[0].Loan_Id__c];
                List<Dealer_Applicant_Relationship__c> updatedBorrDealerRelList = [SELECT Id,
                                                                                         Is_Non_Accrual__c
                                                                                    FROM Dealer_Applicant_Relationship__c 
                                                                                    WHERE Applicant__r.Name = 'Jasmine Albin'
                                                                                    AND Dealer__r.Coop_Type__c != 'Growmark'
                                                                                    LIMIT 1];
                List<Dealer_Applicant_Relationship__c> updatedPrincipalDRList = [SELECT Id,
                                                                                        Is_Non_Accrual__c
                                                                                    FROM Dealer_Applicant_Relationship__c 
                                                                                    WHERE Applicant__r.Name = 'Mike Johnson' 
                                                                                    AND Dealer__r.Coop_Type__c != 'Growmark'
                                                                                    LIMIT 1];
                List<genesis__Application_Pricing_Detail__c> updatedPricingObjList = [SELECT Id, 
                                                                                                loan_Number__c
                                                                                        FROM genesis__Application_Pricing_Detail__c 
                                                                                        WHERE genesis__Application__c = :updatedApplicationList[0].Id
                                                                                        ORDER BY loan_Number__c];
                System.assertEquals(false, updatedApplicationList[0].Non_Accrual__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals('300023456', updatedApplicationList[0].genesis__Loan_Number__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(false, updatedBorrDealerRelList[0].Is_Non_Accrual__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(false, updatedPrincipalDRList[0].Is_Non_Accrual__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals('300023456-A', updatedPricingObjList[0].loan_Number__c, PortalConstants.ASSERTION_FAILED);
            }
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 05-07-2024 
    **/
    @isTest
    public static void testApiSucessForDbaApplication(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        clcommon__Legal_Entity__c dbaEntityObj = [SELECT Id 
                                                        FROM clcommon__Legal_Entity__c
                                                        WHERE Name = :PortalConstants.INDIVIDUAL_ENTITY LIMIT 1];
        List<Dealer_Applicant_Relationship__c> borrowerDealerRelList = [SELECT Id,
                                                                            Applicant__r.clcommon__Legal_Entity_Type__c,
                                                                            Is_Non_Accrual__c
                                                                        FROM Dealer_Applicant_Relationship__c 
                                                                        WHERE Applicant__r.Name = 'Jasmine Albin' 
                                                                        AND Dealer__r.Coop_Type__c != 'Growmark'
                                                                        LIMIT 1];
        borrowerDealerRelList[0].Is_Non_Accrual__c = true;
        borrowerDealerRelList[0].Applicant__r.clcommon__Legal_Entity_Type__c = dbaEntityObj.Id;
        Database.update(borrowerDealerRelList,true);

        List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                            genesis__Loan_Number__c,
                                                            Loan_Id__c,
                                                            Non_Accrual__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        applicationList[0].genesis__Loan_Number__c = '9'+applicationList[0].genesis__Loan_Number__c;
        applicationList[0].Non_Accrual__c = true;
        Database.update(applicationList,true);

        List<genesis__Application_Pricing_Detail__c> pricingDetailObjList = [SELECT Id, 
                                                                                        loan_Number__c
                                                                                FROM genesis__Application_Pricing_Detail__c 
                                                                                WHERE genesis__Application__c = :applicationList[0].Id];        for(genesis__Application_Pricing_Detail__c childLoanObj: pricingDetailObjList){
            childLoanObj.loan_Number__c = applicationList[0].genesis__Loan_Number__c;
        }   
        Database.update(pricingDetailObjList,true);   

        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                NLSMoveLoanToAccrual.moveToAccrual(applicationList[0].Id);
                Test.stopTest();
                List<genesis__Applications__c> updatedApplicationList = [SELECT Id, 
                                                                    genesis__Loan_Number__c,
                                                                    Non_Accrual__c,
                                                                    Loan_Id__c
                                                                FROM genesis__Applications__c 
                                                                WHERE Loan_Id__c = :applicationList[0].Loan_Id__c];
                List<Dealer_Applicant_Relationship__c> updatedBorrDealerRelList = [SELECT Id,
                                                                                            Is_Non_Accrual__c
                                                                                        FROM Dealer_Applicant_Relationship__c 
                                                                                        WHERE Applicant__r.Name = 'Jasmine Albin'
                                                                                        AND Dealer__r.Coop_Type__c != 'Growmark'
                                                                                        LIMIT 1];
                List<Dealer_Applicant_Relationship__c> updatedPrincipalDRList = [SELECT Id,
                                                                                        Is_Non_Accrual__c
                                                                                    FROM Dealer_Applicant_Relationship__c 
                                                                                    WHERE Applicant__r.Name = 'Mike Johnson' 
                                                                                    AND Dealer__r.Coop_Type__c != 'Growmark'
                                                                                    LIMIT 1];
                List<genesis__Application_Pricing_Detail__c> updatedPricingObjList = [SELECT Id, 
                                                                                                loan_Number__c
                                                                                        FROM genesis__Application_Pricing_Detail__c 
                                                                                        WHERE genesis__Application__c = :updatedApplicationList[0].Id
                                                                                        ORDER BY loan_Number__c];
                System.assertEquals(false, updatedApplicationList[0].Non_Accrual__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals('300023456', updatedApplicationList[0].genesis__Loan_Number__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(false, updatedBorrDealerRelList[0].Is_Non_Accrual__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(false, updatedPrincipalDRList[0].Is_Non_Accrual__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals('300023456-A', updatedPricingObjList[0].loan_Number__c, PortalConstants.ASSERTION_FAILED);
            }
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 05-07-2024 
    **/
    @isTest
    public static void testApiSucessForCorporationApplication(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        clcommon__Legal_Entity__c corporationEntityObj = [SELECT Id 
                                                        FROM clcommon__Legal_Entity__c
                                                        WHERE Name = :PortalConstants.CORPORATION LIMIT 1];
        List<Dealer_Applicant_Relationship__c> borrowerDealerRelList = [SELECT Id,
                                                                            Applicant__r.clcommon__Legal_Entity_Type__c,
                                                                            Is_Non_Accrual__c
                                                                        FROM Dealer_Applicant_Relationship__c 
                                                                        WHERE Applicant__r.Name = 'Jasmine Albin' 
                                                                        AND Dealer__r.Coop_Type__c != 'Growmark'
                                                                        LIMIT 1];
        borrowerDealerRelList[0].Is_Non_Accrual__c = true;
        borrowerDealerRelList[0].Applicant__r.clcommon__Legal_Entity_Type__c = corporationEntityObj.Id;
        Database.update(borrowerDealerRelList,true);

        List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                            genesis__Loan_Number__c,
                                                            Loan_Id__c,
                                                            Non_Accrual__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        applicationList[0].genesis__Loan_Number__c = '9'+applicationList[0].genesis__Loan_Number__c;
        applicationList[0].Non_Accrual__c = true;
        Database.update(applicationList,true);

        List<genesis__Application_Pricing_Detail__c> pricingDetailObjList = [SELECT Id, 
                                                                                        loan_Number__c
                                                                                FROM genesis__Application_Pricing_Detail__c 
                                                                                WHERE genesis__Application__c = :applicationList[0].Id
                                                                                LIMIT 1];
        for(genesis__Application_Pricing_Detail__c childLoanObj: pricingDetailObjList){
            childLoanObj.loan_Number__c = applicationList[0].genesis__Loan_Number__c;
        }   
        Database.update(pricingDetailObjList,true);   

        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                NLSMoveLoanToAccrual.moveToAccrual(applicationList[0].Id);
                Test.stopTest();
                List<genesis__Applications__c> updatedApplicationObj = [SELECT Id, 
                                                                                genesis__Loan_Number__c,
                                                                                Non_Accrual__c,
                                                                                Loan_Id__c
                                                                            FROM genesis__Applications__c 
                                                                            WHERE Loan_Id__c = :applicationList[0].Loan_Id__c];
                List<Dealer_Applicant_Relationship__c> updatedBorrDealerRelList = [SELECT Id,
                                                                                            Is_Non_Accrual__c
                                                                                        FROM Dealer_Applicant_Relationship__c 
                                                                                        WHERE Applicant__r.Name = 'Jasmine Albin'
                                                                                        AND Dealer__r.Coop_Type__c != 'Growmark'
                                                                                        LIMIT 1];
                List<Dealer_Applicant_Relationship__c> updatedPrincipalDRList = [SELECT Id,
                                                                                        Is_Non_Accrual__c
                                                                                    FROM Dealer_Applicant_Relationship__c 
                                                                                    WHERE Applicant__r.Name = 'Mike Johnson' 
                                                                                    AND Dealer__r.Coop_Type__c != 'Growmark'
                                                                                    LIMIT 1];
                List<genesis__Application_Pricing_Detail__c> updatedPricingObjList = [SELECT Id, 
                                                                                                loan_Number__c
                                                                                        FROM genesis__Application_Pricing_Detail__c 
                                                                                        WHERE genesis__Application__c = :updatedApplicationObj[0].Id
                                                                                        ORDER BY loan_Number__c];
                System.assertEquals(false, updatedApplicationObj[0].Non_Accrual__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals('300023456', updatedApplicationObj[0].genesis__Loan_Number__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(false, updatedBorrDealerRelList[0].Is_Non_Accrual__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(false, updatedPrincipalDRList[0].Is_Non_Accrual__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals('300023456-A', updatedPricingObjList[0].loan_Number__c, PortalConstants.ASSERTION_FAILED);
            }
        }
    }

    @isTest
    public static void testApiFailureWithNullApplicationId(){ 
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                String response = NLSMoveLoanToAccrual.moveToAccrual(null);
                Test.stopTest();
                System.assertEquals(response, ConstantValues.SOMETHING_WENT_WRONG,'Success');
            }
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 05-08-2024 
    **/
    @isTest
    public static void testApiSuccessForMultipleChildLoan(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                            genesis__Account__c,
                                                            genesis__Loan_Number__c,
                                                            Loan_Id__c,
                                                            Non_Accrual__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        applicationList[0].genesis__Loan_Number__c = '9'+applicationList[0].genesis__Loan_Number__c;
        applicationList[0].Non_Accrual__c = true;
        Database.update(applicationList,true);

        List<genesis__Application_Pricing_Detail__c> pricingDetailObjList = [SELECT Id, 
                                                                                    loan_Number__c
                                                                            FROM genesis__Application_Pricing_Detail__c 
                                                                            WHERE genesis__Application__c = :applicationList[0].Id
                                                                            LIMIT 1];
        for(genesis__Application_Pricing_Detail__c childLoanObj: pricingDetailObjList){
            childLoanObj.loan_Number__c = applicationList[0].genesis__Loan_Number__c;
        }   
        Database.update(pricingDetailObjList,true);   
        List<Dealer_Applicant_Relationship__c> borrowerDealerRelList = [SELECT Id,
                                                                                Is_Non_Accrual__c
                                                                        FROM Dealer_Applicant_Relationship__c 
                                                                        WHERE Applicant__c = :applicationList[0].genesis__Account__c 
                                                                        AND Dealer__r.Coop_Type__c != 'Growmark'
                                                                        LIMIT 1];
        borrowerDealerRelList[0].Is_Non_Accrual__c = true;
        Database.update(borrowerDealerRelList,true);

        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
                NLSMoveLoanToAccrual.moveToAccrual(applicationList[0].Id);
                Test.stopTest();
                List<genesis__Applications__c> updatedApplicationList = [SELECT Id, 
                                                                                genesis__Loan_Number__c,
                                                                                Non_Accrual__c,
                                                                                Loan_Id__c
                                                                            FROM genesis__Applications__c 
                                                                            WHERE Loan_Id__c = :applicationList[0].Loan_Id__c];
                List<Dealer_Applicant_Relationship__c> updatedBorrDealerRelList = [SELECT Id,
                                                                                    Is_Non_Accrual__c
                                                                                FROM Dealer_Applicant_Relationship__c 
                                                                                WHERE Applicant__r.Name = 'Jasmine Albin'
                                                                                AND Dealer__r.Coop_Type__c != 'Growmark'
                                                                                LIMIT 1];
                List<Dealer_Applicant_Relationship__c> updatedPrincipalDRList = [SELECT Id,
                                                                                        Is_Non_Accrual__c
                                                                                    FROM Dealer_Applicant_Relationship__c 
                                                                                    WHERE Applicant__r.Name = 'Mike Johnson' 
                                                                                    AND Dealer__r.Coop_Type__c != 'Growmark'
                                                                                    LIMIT 1];
                List<genesis__Application_Pricing_Detail__c> updatedPricingObjList = [SELECT Id, 
                                                                                                loan_Number__c
                                                                                        FROM genesis__Application_Pricing_Detail__c 
                                                                                        WHERE genesis__Application__c = :updatedApplicationList[0].Id
                                                                                        ORDER BY loan_Number__c];
                System.assertEquals(false, updatedApplicationList[0].Non_Accrual__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals('300023456', updatedApplicationList[0].genesis__Loan_Number__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(false, updatedBorrDealerRelList[0].Is_Non_Accrual__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(false, updatedPrincipalDRList[0].Is_Non_Accrual__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals('300023456-A', updatedPricingObjList[0].loan_Number__c, PortalConstants.ASSERTION_FAILED);
            }
        }
    }

    /**
    * @description : Test method for Loan Accounting Profile
    * @author Tuhin Bhunia | 05-15-2024 
    **/
    @isTest
    public static void testApiSucessForMultipleChildLoanLAProfile(){
        User laUserObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                            genesis__Account__c,
                                                            genesis__Loan_Number__c,
                                                            Loan_Id__c,
                                                            Non_Accrual__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        applicationList[0].genesis__Loan_Number__c = '9'+applicationList[0].genesis__Loan_Number__c;
        applicationList[0].Non_Accrual__c = true;
        Database.update(applicationList,true);

        List<genesis__Application_Pricing_Detail__c> pricingDetailObjList = [SELECT Id, 
                                                                                        loan_Number__c
                                                                                FROM genesis__Application_Pricing_Detail__c 
                                                                                WHERE genesis__Application__c = :applicationList[0].Id
                                                                                LIMIT 1];
        for(genesis__Application_Pricing_Detail__c childLoanObj: pricingDetailObjList){
            childLoanObj.loan_Number__c = applicationList[0].genesis__Loan_Number__c;
        }   
        Database.update(pricingDetailObjList,true);   
        List<Dealer_Applicant_Relationship__c> borrowerDealerList = [SELECT Id,
                                                                            Is_Non_Accrual__c
                                                                        FROM Dealer_Applicant_Relationship__c 
                                                                        WHERE Applicant__c = :applicationList[0].genesis__Account__c 
                                                                        AND Dealer__r.Coop_Type__c != 'Growmark'
                                                                        LIMIT 1];
        borrowerDealerList[0].Is_Non_Accrual__c = true;
        Database.update(borrowerDealerList,true);

        if(laUserObj != null){
            System.runAs(laUserObj){
                Test.startTest();
                NLSMoveLoanToAccrual.moveToAccrual(applicationList[0].Id);
                Test.stopTest();
                List<genesis__Applications__c> updatedApplicationList = [SELECT Id, 
                                                                                genesis__Loan_Number__c,
                                                                                Non_Accrual__c,
                                                                                Loan_Id__c
                                                                            FROM genesis__Applications__c 
                                                                            WHERE Loan_Id__c = :applicationList[0].Loan_Id__c];
                List<Dealer_Applicant_Relationship__c> updatedBorrDealerRelList = [SELECT Id,
                                                                                            Is_Non_Accrual__c
                                                                                        FROM Dealer_Applicant_Relationship__c 
                                                                                        WHERE Applicant__r.Name = 'Jasmine Albin'
                                                                                        AND Dealer__r.Coop_Type__c != 'Growmark'
                                                                                        LIMIT 1];
                List<Dealer_Applicant_Relationship__c> updatedPrincipalDRList = [SELECT Id,
                                                                                    Is_Non_Accrual__c
                                                                                FROM Dealer_Applicant_Relationship__c 
                                                                                WHERE Applicant__r.Name = 'Mike Johnson' 
                                                                                AND Dealer__r.Coop_Type__c != 'Growmark'
                                                                                LIMIT 1];
                List<genesis__Application_Pricing_Detail__c> updatedPricingObjList = [SELECT Id, 
                                                                                                loan_Number__c
                                                                                        FROM genesis__Application_Pricing_Detail__c 
                                                                                        WHERE genesis__Application__c = :updatedApplicationList[0].Id
                                                                                        ORDER BY loan_Number__c];
                System.assertEquals(false, updatedApplicationList[0].Non_Accrual__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals('300023456', updatedApplicationList[0].genesis__Loan_Number__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(false, updatedBorrDealerRelList[0].Is_Non_Accrual__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals(false, updatedPrincipalDRList[0].Is_Non_Accrual__c, PortalConstants.ASSERTION_FAILED);
                System.assertEquals('300023456-A', updatedPricingObjList[0].loan_Number__c, PortalConstants.ASSERTION_FAILED);
            }
        }
    }
    /**
    * @description 
    * @author Ayan Bhowmik | 01-27-2025
    **/
    @isTest
    public static void testForDiffDR(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                            genesis__Account__c,
                                                            genesis__Loan_Number__c,
                                                            Loan_Id__c,
                                                            Non_Accrual__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        applicationList[0].genesis__Loan_Number__c = '9'+applicationList[0].genesis__Loan_Number__c;
        applicationList[0].Non_Accrual__c = true;
        Database.update(applicationList,true);

        List<genesis__Application_Pricing_Detail__c> pricingDetailObjList = [SELECT Id, 
                                                                                    loan_Number__c
                                                                            FROM genesis__Application_Pricing_Detail__c 
                                                                            WHERE genesis__Application__c = :applicationList[0].Id];
        for(genesis__Application_Pricing_Detail__c childLoanObj: pricingDetailObjList){
            childLoanObj.loan_Number__c = applicationList[0].genesis__Loan_Number__c;
        }   
        Database.update(pricingDetailObjList,true);   
        List<Dealer_Applicant_Relationship__c> borrowerDealerRelList = [SELECT Id,
                                                                                Is_Non_Accrual__c
                                                                        FROM Dealer_Applicant_Relationship__c 
                                                                        WHERE Applicant__c = :applicationList[0].genesis__Account__c];
        for(Dealer_Applicant_Relationship__c eachDR : borrowerDealerRelList){
            eachDR.Is_Non_Accrual__c = true;
        }
        Database.update(borrowerDealerRelList,true);

        if(userObj != null){
            System.runAs(userObj){
                Test.startTest();
            NLSMoveLoanToAccrual.moveToAccrual(applicationList[0].Id);
            Test.stopTest();
            List<genesis__Applications__c> updatedApplicationList = [SELECT Id, 
                                                                            genesis__Loan_Number__c,
                                                                            Non_Accrual__c,
                                                                            Loan_Id__c
                                                                        FROM genesis__Applications__c 
                                                                        WHERE Loan_Id__c = :applicationList[0].Loan_Id__c];
            List<Dealer_Applicant_Relationship__c> updatedBorrDealerRelList = [SELECT Id,
                                                                                    Is_Non_Accrual__c,
                                                                                    Dealer__r.Coop_Type__c,
                                                                                    Dealer__c
                                                                                FROM Dealer_Applicant_Relationship__c 
                                                                                WHERE Applicant__r.Name = 'Jasmine Albin'];
            List<Dealer_Applicant_Relationship__c> updatedPrincipalDRList = [SELECT Id,
                                                                                    Is_Non_Accrual__c,
                                                                                    Dealer__r.Coop_Type__c,
                                                                                    Dealer__c
                                                                                FROM Dealer_Applicant_Relationship__c 
                                                                                WHERE Applicant__r.Name = 'Mike Johnson'];
            List<genesis__Application_Pricing_Detail__c> updatedPricingObjList = [SELECT Id, 
                                                                                            loan_Number__c
                                                                                    FROM genesis__Application_Pricing_Detail__c 
                                                                                    WHERE genesis__Application__c = :updatedApplicationList[0].Id
                                                                                    ORDER BY loan_Number__c];
            System.assertEquals(false, updatedApplicationList[0].Non_Accrual__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals('300023456', updatedApplicationList[0].genesis__Loan_Number__c, PortalConstants.ASSERTION_FAILED);
            System.assertEquals('300023456-A', updatedPricingObjList[0].loan_Number__c, PortalConstants.ASSERTION_FAILED);
            for(Dealer_Applicant_Relationship__c eachDealerRel : updatedBorrDealerRelList){
                if(eachDealerRel.Dealer__r.Coop_Type__c == 'Growmark'){
                    System.assertEquals(true, eachDealerRel.Is_Non_Accrual__c, 'Non Accrual is incorrectly updated to true');
                    System.assertEquals(true, eachDealerRel.Is_Non_Accrual__c, 'Non Accrual is incorrectly updated to true');
                } else {
                    System.assertEquals(false, eachDealerRel.Is_Non_Accrual__c, 'Non Accrual is incorrectly updated to true');
                    System.assertEquals(false, eachDealerRel.Is_Non_Accrual__c, 'Non Accrual is incorrectly updated to true');
                }
            }
            for(Dealer_Applicant_Relationship__c eachDealerRel : updatedPrincipalDRList){
                    System.assertEquals(false, eachDealerRel.Is_Non_Accrual__c, 'Non Accrual is incorrectly updated to false');
                    System.assertEquals(false, eachDealerRel.Is_Non_Accrual__c, 'Non Accrual is incorrectly updated to false');
                }
            }
        }
    }
}