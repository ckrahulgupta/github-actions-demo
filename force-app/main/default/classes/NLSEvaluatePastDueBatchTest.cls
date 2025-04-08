/**
 * @description       :  Test Class for NLSEvaluatePastDueBatch
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : Ayan Bhowmik
**/
@isTest
public with sharing class NLSEvaluatePastDueBatchTest {
    /**
    * @description : Test Setup
    * @author  Pritam Roy | 05-30-2024 
    **/
    @TestSetup
    static void makeData(){
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(legalEntityObj,true);

        clcommon__Legal_Entity__c legalEntityDbaObj  = ApplicationOriginationTestHelper.createDBALegalEntity();
        Database.insert(legalEntityDbaObj,true);

        clcommon__Legal_Entity__c legalEntityCorpObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(legalEntityCorpObj,true);

        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);

        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c principalPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        clcommon__Party_Type__c dealerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('DEALER');
        Database.insert(new List<clcommon__Party_Type__c>{clPartyTypeObj, borrowerPartyTypeObj, principalPartyTypeObj, dealerPartyTypeObj},true);

        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c gmkDealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        gmkDealerBusinessInfoObj.genesis__Tax_Identification_Number__c = '888999911';
        genesis__Business_Information__c businessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj, businessInfoObj, gmkDealerBusinessInfoObj},true);

        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.id);
        dealerAccountObj.Enable_ERP_Id__c = true;
        Account gmkDealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(gmkDealerBusinessInfoObj.id);
        gmkDealerAccountObj.Enable_ERP_Id__c = true;
        gmkDealerAccountObj.Coop_Type__c = 'Growmark';
        Database.insert(new List<Account>{dealerAccountObj, gmkDealerAccountObj}, true);

        Account accountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(businessInfoObj.id,dealerAccountObj.id);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Account gmkClAccountObj = ApplicationOriginationTestHelper.createCLAccount(gmkDealerBusinessInfoObj.id, gmkDealerAccountObj.id);
        gmkClAccountObj.Coop_Type__c = 'Growmark';
        Database.insert(new List<Account>{accountObj, clAccountObj, gmkClAccountObj},true);

        Contact contactObj = ApplicationOriginationTestHelper.createSalesAgentContact(accountObj.id);
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
        Contact gmkClContactObj = ApplicationOriginationTestHelper.createCLContact(gmkClAccountObj.id);
        Database.insert(new List<Contact>{contactObj, clContactObj, gmkClContactObj},true);

        User userObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.id);
        User gmkUserObj = ApplicationOriginationTestHelper.createCLUser(gmkClContactObj.id);
        gmkUserObj.UserName = 'ross.geller@yopmail.com.gmk';
        Database.insert(new List<User>{userObj, gmkUserObj},true);
    
        clcommon__Reciprocal_Role__c clRole = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(clRole,true);

        clcommon__Relationship__c clRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(clRole,dealerAccountObj.id,clAccountObj.id);
        clcommon__Relationship__c gmkClRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(clRole,gmkDealerAccountObj.id,gmkClAccountObj.id);
        Database.insert(new List<clcommon__Relationship__c>{clRelationship, gmkClRelationship},true);

        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);

        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        borrowerAccountObj.CIF_Number__c = '123456';
        borrowerAccountObj.Coop_Type__c = 'CFA';

        genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(coBorrowerBusinessInfoObj,true);

        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(legalEntityObj,coBorrowerBusinessInfoObj.id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        Database.insert(new List<Account>{borrowerAccountObj,coBorrowerAccountObj},true);

        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        borrowerContactObj.genesis__SSN__c = '324242424';
        borrowerContactObj.Confirm_SSN__c = '324242424';

        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        Database.insert(new List<Contact>{coBorrowerContactObj,borrowerContactObj},true);

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(new Map<String, Id>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'saAccountObjId' => accountObj.id
        });
        applicationObj.genesis__Product_Type__c ='Package';
        applicationObj.genesis__Loan_Amount__c = 82400;
        applicationObj.FICO_Score__c = '680';
        applicationObj.SBSS_70_Score__c = '160';
        Database.insert(applicationObj,true); 

        genesis__Applications__c gmkApplicationObj = ApplicationOriginationTestHelper.createApplication(new Map<String, Id>{
            'dealerAccountObjId' => gmkDealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'saAccountObjId' => null
        });
        gmkApplicationObj.genesis__Product_Type__c ='Package';
        gmkApplicationObj.genesis__Loan_Amount__c = 9000;
        gmkApplicationObj.FICO_Score__c = '690';
        gmkApplicationObj.SBSS_70_Score__c = '170';
        Database.insert(gmkApplicationObj,true); 
        
        Map<String, Object> dealerRelationMap = createDealerRelations(new Map<String, Object>{
            'borrowerContactObj' => borrowerContactObj,
            'coBorrowerContactObj' => coBorrowerContactObj,
            'dealerAccountObj' => dealerAccountObj,
            'gmkDealerAccountObj' => gmkDealerAccountObj
        });

        createParties(new Map<String, Object>{
            'borrowerAccountObj' => borrowerAccountObj,
            'borrowerContactObj' => borrowerContactObj,
            'borrowerPartyTypeObj' => borrowerPartyTypeObj,
            'applicationObj' => applicationObj,
            'dealerBorrRelationObj' => dealerRelationMap.get('dealerBorrRelationObj'),
            'clAccountObj' => clAccountObj,
            'clContactObj' => clContactObj,
            'clPartyTypeObj' => clPartyTypeObj,
            'coBorrowerAccountObj' => coBorrowerAccountObj,
            'coBorrowerContactObj' => coBorrowerContactObj,
            'principalPartyTypeObj' => principalPartyTypeObj,
            'gmkApplicationObj' => gmkApplicationObj,
            'gmkClAccountObj' => gmkClAccountObj,
            'gmkClContactObj' => gmkClContactObj,
            'dealerCoBorrRelationObj' => dealerRelationMap.get('dealerCoBorrRelationObj'),
            'gmkDealerBorrRelObj' => dealerRelationMap.get('gmkDealerBorrRelObj'),
            'gmkDealerCoBorrRelObj' => dealerRelationMap.get('gmkDealerCoBorrRelObj')
        });
        createPricing(New Map<String, Object>{
            'applicationObj' => applicationObj,
            'gmkApplicationObj' => gmkApplicationObj
        });
    }

    /**
    * @description Creating pricings for gl application and growmark application
    * @author Ayan Bhowmik | 01-23-2025 
    * @param paramMap 
    **/
    private static void createPricing(Map<String, Object> paramMap){
        genesis__Application_Pricing_Detail__c objPricingDetail = ApplicationOriginationTestHelper.createPricingDetail(((genesis__Applications__c)paramMap.get('applicationObj')).Id);
        Database.insert(objPricingDetail, true);
        genesis__Application_Pricing_Detail__c gmkPricingDetail = ApplicationOriginationTestHelper.createPricingDetail(((genesis__Applications__c)paramMap.get('gmkApplicationObj')).Id);
        gmkPricingDetail.Fees__c = 0;
        Database.insert(gmkPricingDetail, true);
    }
    /**
    * @description Creatring dealer relations for borrower and principal
    * @author Ayan Bhowmik | 01-22-2025 
    * @param paramMap 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> createDealerRelations(Map<String, Object> paramMap) {

        Dealer_Applicant_Relationship__c dealerBorrRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship((Contact)paramMap.get('borrowerContactObj'),
                                                                                                                                        ((Account)paramMap.get('dealerAccountObj')).Id);
        Dealer_Applicant_Relationship__c dealerCoBorrRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship((Contact)paramMap.get('coBorrowerContactObj'),
                                                                                                                                        ((Account)paramMap.get('dealerAccountObj')).Id);
        Dealer_Applicant_Relationship__c gmkDealerBorrRelObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship((Contact)paramMap.get('borrowerContactObj'),
                                                                                                                                        ((Account)paramMap.get('gmkDealerAccountObj')).Id);
        Dealer_Applicant_Relationship__c gmkDealerCoBorrRelObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship((Contact)paramMap.get('coBorrowerContactObj'),
                                                                                                                                        ((Account)paramMap.get('gmkDealerAccountObj')).Id);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{dealerBorrRelationObj, dealerCoBorrRelationObj, gmkDealerBorrRelObj, gmkDealerCoBorrRelObj},true);
        return new Map<String, Object>{
            'dealerBorrRelationObj' => dealerBorrRelationObj,
            'dealerCoBorrRelationObj' => dealerCoBorrRelationObj,
            'gmkDealerBorrRelObj' => gmkDealerBorrRelObj,
            'gmkDealerCoBorrRelObj' => gmkDealerCoBorrRelObj
        };
    }

    /**
    * @description creating parties for applications
    * @author Ayan Bhowmik | 01-22-2025 
    * @param paramMap 
    **/
    private static void createParties(Map<String, Object> paramMap){
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
            'accountId' => ((Account)paramMap.get('borrowerAccountObj')).Id,
            'contactId' => ((Contact)paramMap.get('borrowerContactObj')).Id,
            'partyTypeId' => ((clcommon__Party_Type__c)paramMap.get('borrowerPartyTypeObj')).Id,
            'applicationId' => ((genesis__Applications__c)paramMap.get('applicationObj')).Id
        });
        partyObj.clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;
        partyObj.Dealer_Applicant_Relationship__c = ((Dealer_Applicant_Relationship__c)paramMap.get('dealerBorrRelationObj')).Id;

        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
            'accountId' => ((Account)paramMap.get('clAccountObj')).Id,
            'contactId' => ((Contact)paramMap.get('clContactObj')).Id,
            'partyTypeId' => ((clcommon__Party_Type__c)paramMap.get('clPartyTypeObj')).Id,
            'applicationId' => ((genesis__Applications__c)paramMap.get('applicationObj')).Id
        });

        clcommon__Party__c coPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
            'accountId' => ((Account)paramMap.get('coBorrowerAccountObj')).Id,
            'contactId' => ((Contact)paramMap.get('coBorrowerContactObj')).Id,
            'partyTypeId' => ((clcommon__Party_Type__c)paramMap.get('principalPartyTypeObj')).Id,
            'applicationId' => ((genesis__Applications__c)paramMap.get('applicationObj')).Id
        });
        coPartyObj.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;
        coPartyObj.Dealer_Applicant_Relationship__c = ((Dealer_Applicant_Relationship__c)paramMap.get('dealerCoBorrRelationObj')).Id;

        clcommon__Party__c gmkPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
            'accountId' => ((Account)paramMap.get('borrowerAccountObj')).Id,
            'contactId' => ((Contact)paramMap.get('borrowerContactObj')).Id,
            'partyTypeId' => ((clcommon__Party_Type__c)paramMap.get('borrowerPartyTypeObj')).Id,
            'applicationId' => ((genesis__Applications__c)paramMap.get('gmkApplicationObj')).Id
        });
        gmkPartyObj.clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;
        gmkPartyObj.Dealer_Applicant_Relationship__c = ((Dealer_Applicant_Relationship__c)paramMap.get('gmkDealerBorrRelObj')).Id;

        clcommon__Party__c gmkClPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
            'accountId' => ((Account)paramMap.get('gmkClAccountObj')).Id,
            'contactId' => ((Contact)paramMap.get('gmkClContactObj')).Id,
            'partyTypeId' => ((clcommon__Party_Type__c)paramMap.get('clPartyTypeObj')).Id,
            'applicationId' => ((genesis__Applications__c)paramMap.get('gmkApplicationObj')).Id
        });

        clcommon__Party__c gmkCoPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
            'accountId' => ((Account)paramMap.get('coBorrowerAccountObj')).Id,
            'contactId' => ((Contact)paramMap.get('coBorrowerContactObj')).Id,
            'partyTypeId' => ((clcommon__Party_Type__c)paramMap.get('principalPartyTypeObj')).Id,
            'applicationId' => ((genesis__Applications__c)paramMap.get('gmkApplicationObj')).Id
        });
        gmkCoPartyObj.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;
        gmkCoPartyObj.Dealer_Applicant_Relationship__c = ((Dealer_Applicant_Relationship__c)paramMap.get('gmkDealerCoBorrRelObj')).Id;

        Database.insert(new List<clcommon__Party__c>{partyObj, clPartyObj, coPartyObj, gmkPartyObj, gmkClPartyObj, gmkCoPartyObj},true);
    }

    /**
     * @description Fetching the Dealer Applicant Relation
     * @param name 
     * @return  `List<Dealer_Applicant_Relationship__c>`
     */
    private static List<Dealer_Applicant_Relationship__c> getDealerApplicantRel(String name){
         List<Dealer_Applicant_Relationship__c> dealerApplicantList = [SELECT Id,
                                                                            Has_Past_Due__c,
                                                                            Dealer__c,
                                                                            Dealer__r.Coop_Type__c
                                                                        FROM Dealer_Applicant_Relationship__c 
                                                                        WHERE Applicant__r.name = :name];
        if(dealerApplicantList.isEmpty()){
            return null;
        }
        return dealerApplicantList;
    }
    /**
    * @description : tesitng no DR record with has past due true
    * @author  Pritam Roy | 06-20-2024 
    **/
    @isTest
    static void testNoPastDueTrue(){
        List<Dealer_Applicant_Relationship__c> dealerApplicantList;
        List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
        System.runAs(userObj[0]){
            Test.startTest();
            NLSEvaluatePastDueBatch objBatch = new NLSEvaluatePastDueBatch();
            Database.executeBatch(objBatch, 40);
            Test.stopTest();
            dealerApplicantList = getDealerApplicantRel('Jasmine Albin');
            System.assertEquals(false, dealerApplicantList[0].Has_Past_Due__c,'Has Past Due is incorrectly updated to true');
        }
    }
    /**
    * @description :Test Past Due Borrower Account Success
    * @author  Pritam Roy | 06-20-2024 
    **/
    @isTest
    static void testWithoutPastDueAmount(){
        List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
        List<Dealer_Applicant_Relationship__c> dealerApplicantList = getDealerApplicantRel('Jasmine Albin');
        dealerApplicantList[0].Has_Past_Due__c = true;
        Database.update(dealerApplicantList, true);                                
        System.runAs(userObj[0]){
            Test.startTest();
            NLSEvaluatePastDueBatch objBatch = new NLSEvaluatePastDueBatch();
            Database.executeBatch(objBatch,1);
            Test.stopTest();
            dealerApplicantList = getDealerApplicantRel('Jasmine Albin');
            System.assertEquals(false, dealerApplicantList[0].Has_Past_Due__c,'Has Past Due is incorrectly updated to true');
        }
    }
    /**
    * @description : Test Past Due Application and Borrower Success
    * @author  Pritam Roy | 06-20-2024 
    **/
    @isTest
    static void testWithPastDueAmount(){
        List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
        List<Dealer_Applicant_Relationship__c> dealerApplicantList = getDealerApplicantRel('Jasmine Albin');
        dealerApplicantList[0].Has_Past_Due__c = true;
        Database.update(dealerApplicantList, true);     
        List<genesis__Application_Pricing_Detail__c> pricingDetailList = [SELECT Id,
                                                                            Past_Due_Balance__c 
                                                                        FROM genesis__Application_Pricing_Detail__c
                                                                        WHERE Fees__c = 100];
        pricingDetailList[0].Past_Due_Balance__c = 100;
        Database.update(pricingDetailList, true);                                                                        
        System.runAs(userObj[0]){
            Test.startTest();
            NLSEvaluatePastDueBatch objBatch = new NLSEvaluatePastDueBatch();
            Database.executeBatch(objBatch,1);
            Test.stopTest();
        
            dealerApplicantList = getDealerApplicantRel('Jasmine Albin');
            System.assertEquals(true, dealerApplicantList[0].Has_Past_Due__c,'Has Past Due is incorrectly updated to false');
        }
    }
    /**
    * @description : Test Past Due Application and Co Borrower Success
    * @author  Pritam Roy | 06-20-2024 
    **/
    @isTest
    static void testPastDueCoApplicantSuccess(){
        List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
        List<Dealer_Applicant_Relationship__c> dealerApplicantList = getDealerApplicantRel('Jasmine Albin');
        for(Dealer_Applicant_Relationship__c eachDealerRel : dealerApplicantList) {
            eachDealerRel.Has_Past_Due__c = true;
        }
        Database.update(dealerApplicantList, true);

        List<genesis__Application_Pricing_Detail__c> pricingDetailList = [SELECT Id,
                                                                            Past_Due_Balance__c 
                                                                        FROM genesis__Application_Pricing_Detail__c
                                                                        WHERE Fees__c = 100];
        pricingDetailList[0].Past_Due_Balance__c = 100;
        Database.update(pricingDetailList, true);                                                                        
        System.runAs(userObj[0]){
            Test.startTest();
            NLSEvaluatePastDueBatch objBatch = new NLSEvaluatePastDueBatch();
            Database.executeBatch(objBatch, 40);
            Test.stopTest();
            dealerApplicantList = getDealerApplicantRel('Jasmine Albin');
            for(Dealer_Applicant_Relationship__c eachDealerRel : dealerApplicantList){
                if(eachDealerRel.Dealer__r.Coop_Type__c == 'Growmark'){
                    System.assertEquals(false, eachDealerRel.Has_Past_Due__c, 'Has Past Due is incorrectly updated to true');
                    System.assertEquals(false, eachDealerRel.Has_Past_Due__c, 'Has Past Due is incorrectly updated to true');
                } else {
                    System.assertEquals(true, eachDealerRel.Has_Past_Due__c, 'Has Past Due is incorrectly updated to false');
                    System.assertEquals(true, eachDealerRel.Has_Past_Due__c, 'Has Past Due is incorrectly updated to false');
                }
            }
        }
    }
}