/**
 * @description       : This class is a test class for PortalReportsHelper
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : Shristy Kumari
**/

@isTest
public without sharing class PortalReportsHelperTest{
    /**
    * @description Test data setup
    * @author Shristy Kumari | 01-22-2025 
    **/
    @TestSetup
    static void setup(){

        //Creating CL Product for Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.Insert(clProductObj, true);

        //Creating CL Purpose for Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.Insert(clPurposeObj, true);

        //create borrower party
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);
        // create Dealer party
        clcommon__Party_Type__c dealerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.DEALER_PARTY_NAME);
        // create certified lender party
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.CL_PARTY_NAME);
        Database.Insert(new List<clcommon__Party_Type__c>{
            borrowerPartyTypeObj,
            dealerPartyTypeObj,
            clPartyTypeObj
        }, true);

        //Creating Floating Rate Index
        clcommon__Floating_Rate_Index__c floatingRateIndexObj = ApplicationOriginationTestHelper.createFloatingRateIndex(
            New Map<String, Object>{ 'Name' => 'CFA Advantage Rate',
                                        'Base Rate Name' => '4-CFA ADVANTAGE',
                                        'Current Floating Rate' => 11,
                                        'Base Rate Adjuster' => 5.5
            });
        Database.Insert(floatingRateIndexObj, true);

        //Creating Floating rate
        clcommon__Floating_Rate__c floatingRateObj = ApplicationOriginationTestHelper.createFloatingRate(floatingRateIndexObj);
        Database.Insert(floatingRateObj, true);

        //Creating New Partner Program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.Insert(newPartnerProgramObj, true);

        //Creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.Insert(dealerBusinessInfoObj, true);

        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createLegalEntity(PortalConstants.SOLE_PROP_ENTITY);
        Database.Insert(entityObj, true);

        //Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id, newPartnerProgramObj.Id);
        Database.Insert(dealerAccountObj, true);

        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, dealerBusinessInfoObj.Id, dealerAccountObj.Id);

        //Creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        clAccountObj.ParentId = dealerAccountObj.Id;
        Database.Insert(new List<Account>{
            borrowerAccountObj,
            clAccountObj
        }, true);

        //Creating Contacts
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);    
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Contact dealerContactObj = TestClassHelper.createDealerContact(dealerAccountObj.Id);
        Database.Insert(new List<Contact>{
            borrowerContactObj,
            clContactObj,
            dealerContactObj
        }, true);

        Dealer_Applicant_Relationship__c dealerAppRelationshipObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj, dealerAccountObj.Id);
        Database.Insert(dealerAppRelationshipObj, true);

        //Creating Users
        Database.Insert(new List<User>{
            ApplicationOriginationTestHelper.createCLUser(clContactObj.Id),
            TestClassHelper.createBorrowerUser(borrowerContactObj.Id)
        }, true);

        //Creating relationship of certified lender
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.CERTIFIED_LENDER);
        Database.Insert(clRoleObj, true);
        clcommon__Relationship__c relationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj,
                                                                                                    dealerAccountObj.Id, 
                                                                                                    clAccountObj.Id);
        Database.Insert(relationshipObj, true);

        Map<String,Id> paramForApplicationMap = new Map<String,Id>{
            'dealerAccountId'=> dealerAccountObj.Id,
            'clProductId'=> clProductObj.Id,
            'clPurposeId'=> clPurposeObj.Id,
            'borrowerAccountId'=> borrowerAccountObj.Id,
            'borrowerContactId'=> borrowerContactObj.Id,
            'clAccountId'=> clAccountObj.Id
        };

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        applicationObj.Dealer_Applicant_Relationship__c = dealerAppRelationshipObj.Id;
        Database.Insert(applicationObj, true);

        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id,
            'dealerApplicantRelationshipId' => dealerAppRelationshipObj.Id
        };

        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };


        Map<String,Id> paramForDealerPartyMap = new Map<String,Id>{
            'accountId' => dealerAccountObj.Id,
            'contactId' => dealerContactObj.Id,
            'partyTypeId' => dealerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        Database.Insert(new List<clcommon__Party__c>{
            ApplicationOriginationTestHelper.createParty(paramForDealerPartyMap),
            ApplicationOriginationTestHelper.createParty(paramForCLPartyMap),
            ApplicationOriginationTestHelper.createApplicantParty(paramForBorrowerPartyMap, borrowerAccountObj)
        }, true);

        //Create rate card and pricing detail
        genesis__Rate_Card_Setup_Header__c rateCardSetupHeaderObj = LoanServicingTestHelper.createCurrYearRateCardHeader(dealerAccountObj);
        Database.Insert(rateCardSetupHeaderObj, true);

        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailObj = LoanServicingTestHelper.createRateCardSetupDetailOne(rateCardSetupHeaderObj);
        Database.Insert(rateCardSetupDetailObj, true);

        genesis__Application_Pricing_Detail__c appPricingDetailObj = LoanServicingTestHelper.createEnabledPricingDetail(applicationObj, rateCardSetupDetailObj.Id);
        Database.Insert(appPricingDetailObj, true);

        genesis__Application_Fee_Payment__c appFeePaymentPremium = LoanServicingTestHelper.createApplicationFeePayment(applicationObj.Id, appPricingDetailObj.Id);

        rateCardSetupDetailObj = LoanServicingTestHelper.createRateCardSetupDetailTwo(rateCardSetupHeaderObj);
        Database.Insert(rateCardSetupDetailObj, true);
        
        appPricingDetailObj = LoanServicingTestHelper.createDisabledPricingDetail(applicationObj, rateCardSetupDetailObj.Id);
        appPricingDetailObj.Loan_Number__c = applicationObj.genesis__Loan_Number__c;
        Database.Insert(appPricingDetailObj, true);

        genesis__Application_Fee_Payment__c appFeePaymentSubsidyObj = LoanServicingTestHelper.createApplicationFeePaymentSubsidy(applicationObj.Id, appPricingDetailObj.Id);
        Database.Insert(new List<genesis__Application_Fee_Payment__c>{
            appFeePaymentPremium,
            appFeePaymentSubsidyObj
        }, true);

        //Create payment mode
        clcommon__Payment_Mode__c achPaymentModeObj = LoanServicingTestHelper.createPaymentMode().get('ACH');

        clcommon__Payment_Mode__c draftPaymentModeObj = LoanServicingTestHelper.createPaymentMode().get('DRAFT');
        Database.Insert(new List<clcommon__Payment_Mode__c>{
            achPaymentModeObj,
            draftPaymentModeObj
        }, true);

        clcommon__Funding_Transactions_Properties__c achFundingTransacPropsObj = LoanServicingTestHelper.createFundingTransactionProperty('ACH - 07-09-2022');
        Database.Insert(achFundingTransacPropsObj, true);

        Map<String, Id> achFundingTransacParamMap = new Map<String, Id>{
            'applicationId' => applicationObj.Id,
            'pricingDetailId' => appPricingDetailObj.Id,
            'paymentModeId' => achPaymentModeObj.Id,
            'fundingTransactionPropertyId' => achFundingTransacPropsObj.Id
        };
        Map<String, Id> draftFundingTransParamMap = new Map<String, Id>{
            'applicationId' => applicationObj.Id,
            'pricingDetailId' => appPricingDetailObj.Id,
            'paymentModeId' => draftPaymentModeObj.Id
        };
        Database.Insert(new List<genesis__Funding_Transaction__c>{
            LoanServicingTestHelper.createDraftFundingTransaction(draftFundingTransParamMap),
            LoanServicingTestHelper.createACHFundingTransaction(achFundingTransacParamMap)}, true);

        applicationObj = LoanServicingTestHelper.createPrevCropYearApplication(paramForApplicationMap);
        Database.Insert(applicationObj, true);
    }

    /**
    * @description : Method to create system admin user
    * @author Shristy Kumari | 01-06-2025 
    * @return User 
    **/
    private static User getUser(){
        List<User> objUserList = [SELECT Id 
                                    FROM User 
                                    WHERE Profile.name = 'System Administrator'
                                    AND isActive = true
                                    LIMIT 1];
        return objUserList[0];
    }

    /**
    * @description : Method to create cl user by username
    * @author Tuhin Bhunia | 01-09-2025 
    * @param userName 
    * @return User 
    **/
    private static User getUserByUsername(String userName){
        User objCLUser;
        // Fetching CL user
        List<User> clUserList = [SELECT Id, Name, Email, ProfileId, UserName, Account.ParentId
                                FROM USER 
                                WHERE UserName = :userName
                                LIMIT 1];
        for(User user : clUserList){
            objCLUser = user;
        }
        if(objCLUser != null){
            return objCLUser;
        }
        return null;
    }

    /**
    * @description : Method to test getDealerAccountId success scenerio
    * @author Tuhin Bhunia | 11-27-2024 
    **/
    @IsTest
    public static void testGetDealerAccountId() {
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                List<User> dealerAccountId = [SELECT Account.ParentId
                                                    FROM User 
                                                    WHERE Id = :UserInfo.getUserId()
                                                    LIMIT 1];
                Test.startTest();
                String response = PortalReportsHelper.getDealerAccountId();
                System.assertEquals(dealerAccountId[0].Account.ParentId, response, 'Assertion failed to test getDealerAccountId success scenerio'); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test getCommitmentLoanList success scenerio
    * @author Tuhin Bhunia | 11-27-2024 
    **/
    @IsTest
    public static void testGetCommitmentLoanList() {
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                Pricing_Count__c,
                                                                genesis__Loan_Number__c,
                                                                genesis__Loan_Amount__c, 
                                                                genesis__Maturity_Date__c,
                                                                Certified_Lender__r.Name, 
                                                                Sales_Agent__r.Name, 
                                                                genesis__Credit_Rating__r.Name, 
                                                                Note_Date__c,
                                                                genesis__Status__c,
                                                                genesis__Account__r.Name,
                                                                Crop_Year__c,
                                                                Internal_Reference_Code__c,
                                                                Growmark_Unique_Identifier__c,
                                                                Guarantee__c,
                                                                Available__c,
                                                                Reserved_Amount__c,
                                                                CreatedDate 
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Number__c = '300023457'];
        if (clUserObj != null) {
            System.runAs(clUserObj){
                Test.startTest();
                List<Map<String, Object>> result = PortalReportsHelper.getCommitmentLoanList(applicationList);
                System.assertEquals(result[0].get('loan_number'), applicationList[0].genesis__Loan_Number__c, 'Assertion failed to test getCommitmentLoanList success scenerio');
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test getLoanAccountList success scenerio
    * @author Tuhin Bhunia | 11-27-2024 
    **/
    @IsTest
    public static void testGetLoanAccountList() {
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Application_Pricing_Detail__c> appPricingDetailList = [SELECT Id,
                                                                                            genesis__Application__r.Certified_Lender__r.Name, 
                                                                                            genesis__Application__r.Sales_Agent__r.Name, 
                                                                                            genesis__Application__r.genesis__Credit_Rating__r.Name, 
                                                                                            genesis__Application__r.Note_Date__c,
                                                                                            Loan_Number__c,
                                                                                            genesis__Application__r.genesis__Maturity_Date__c,
                                                                                            genesis__Application__r.genesis__Status__c,
                                                                                            genesis__Application__r.genesis__Account__r.Name,
                                                                                            genesis__Interest_Rate__c,
                                                                                            Principal_Advanced__c,
                                                                                            Accrued_Interest__c,
                                                                                            Fees__c,
                                                                                            Interest_Per_Diem__c,
                                                                                            genesis__Rate_Card_Setup_Detail__r.Description__c,
                                                                                            genesis__Application__r.Crop_Year__c,
                                                                                            genesis__Application__r.Internal_Reference_Code__c,
                                                                                            genesis__Application__r.Growmark_Unique_Identifier__c,
                                                                                            genesis__Application__r.Guarantee__c,
                                                                                            genesis__Application__r.CreatedDate,
                                                                                            genesis__Application__r.Available__c,
                                                                                            genesis__Application__r.Pricing_Count__c,
                                                                                            genesis__Application__r.genesis__Loan_Number__c,
                                                                                            genesis__Application__r.Reserved_Amount__c,
                                                                                            genesis__Application__r.genesis__Loan_Amount__c
                                                                                            FROM genesis__Application_Pricing_Detail__c 
                                                                                            WHERE genesis__Application__r.genesis__Loan_Number__c = '300023456'];
        if (clUserObj != null) {
            System.runAs(clUserObj){
                Test.startTest();
                List<Map<String, Object>> result = PortalReportsHelper.getLoanAccountList(appPricingDetailList);
                System.assertEquals('300023456', result[0].get('loan_number'), 'Assertion failed to test getLoanAccountList success scenerio');
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test createCSVTableRow success scenerio
    * @author Tuhin Bhunia | 11-27-2024 
    **/
    @IsTest
    public static void testCreateCSVTableRow() {
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        if (clUserObj != null) {
            System.runAs(clUserObj){
                Test.startTest();
                String response = PortalReportsHelper.createCSVTableRow(null);
                System.assertEquals(',', response, 'Assertion failed to test createCSVTableRow success scenerio');
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test getChildLoanList with pricing
    * @author Tuhin Bhunia | 11-27-2024 
    **/
    @IsTest
    public static void testGetChildLoanList() {
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Application_Fee_Payment__c> applicationFeePaymentList = [SELECT Id,
                                                                                        genesis__Application__r.Certified_Lender__r.Name, 
                                                                                        genesis__Application__r.Sales_Agent__r.Name, 
                                                                                        genesis__Application__r.genesis__Credit_Rating__r.Name, 
                                                                                        genesis__Application__r.Note_Date__c,
                                                                                        Pricing_Detail__r.Loan_Number__c,
                                                                                        genesis__Application__r.genesis__Loan_Number__c,
                                                                                        genesis__Application__r.genesis__Loan_Amount__c,
                                                                                        genesis__Application__r.genesis__Maturity_Date__c,
                                                                                        genesis__Application__r.genesis__Status__c,
                                                                                        genesis__Application__r.genesis__Account__r.Name,
                                                                                        genesis__Application__r.Current_Principal_Balance__c,
                                                                                        genesis__Application__r.Total_Interest__c,
                                                                                        genesis__Application__r.Total_Interest_Per_Diem__c,
                                                                                        genesis__Application__r.Total_Fees__c,
                                                                                        genesis__Application__c,
                                                                                        genesis__Application__r.Pricing_Count__c,
                                                                                        Pricing_Detail__r.genesis__Application__c,
                                                                                        Pricing_Detail__r.genesis__Interest_Rate__c,
                                                                                        Pricing_Detail__r.Principal_Advanced__c,
                                                                                        Interest_Earned__c,
                                                                                        Principal_Balance__c,
                                                                                        Per_Diem__c,
                                                                                        Fees__c,
                                                                                        Interest_Rate__c,
                                                                                        Pricing_Detail__r.Interest_Per_Diem__c,
                                                                                        Pricing_Detail__r.Fees__c,
                                                                                        Pricing_Detail__c,
                                                                                        Past_Due_Balance__c,
                                                                                        Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c,
                                                                                        genesis__Application__r.Crop_Year__c,
                                                                                        genesis__Application__r.Internal_Reference_Code__c,
                                                                                        genesis__Application__r.Growmark_Unique_Identifier__c,
                                                                                        genesis__Application__r.Guarantee__c,
                                                                                        genesis__Application__r.Available__c,
                                                                                        genesis__Application__r.Reserved_Amount__c,
                                                                                        genesis__Application__r.Past_Due_Amount__c,
                                                                                        genesis__Application__r.CreatedDate
                                                                                        FROM genesis__Application_Fee_Payment__c];                                     
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                List<Map<String, Object>> result = PortalReportsHelper.getChildLoanList(applicationFeePaymentList);
                System.assertEquals('300023456', result[0].get('loan_number'), 'Assertion failed to test getChildLoanList With pricing success scenerio');
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test getChildLoanList Without pricing
    * @author Tuhin Bhunia | 11-28-2024 
    **/
    @isTest
    public static void testGetChildLoansWithoutPricing() {
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Application_Fee_Payment__c> feePaymentsToUpdate = new List<genesis__Application_Fee_Payment__c>();
        List<genesis__Application_Fee_Payment__c> applicationFeePaymentList = [SELECT Id,
                                                                                        genesis__Application__r.Certified_Lender__r.Name, 
                                                                                        genesis__Application__r.Sales_Agent__r.Name, 
                                                                                        genesis__Application__r.genesis__Credit_Rating__r.Name, 
                                                                                        genesis__Application__r.Note_Date__c,
                                                                                        Pricing_Detail__r.Loan_Number__c,
                                                                                        genesis__Application__r.genesis__Loan_Number__c,
                                                                                        genesis__Application__r.genesis__Loan_Amount__c,
                                                                                        genesis__Application__r.genesis__Maturity_Date__c,
                                                                                        genesis__Application__r.genesis__Status__c,
                                                                                        genesis__Application__r.genesis__Account__r.Name,
                                                                                        genesis__Application__r.Current_Principal_Balance__c,
                                                                                        genesis__Application__r.Total_Interest__c,
                                                                                        genesis__Application__r.Total_Interest_Per_Diem__c,
                                                                                        genesis__Application__r.Total_Fees__c,
                                                                                        genesis__Application__c,
                                                                                        genesis__Application__r.Pricing_Count__c,
                                                                                        Pricing_Detail__r.genesis__Application__c,
                                                                                        Pricing_Detail__r.genesis__Interest_Rate__c,
                                                                                        Pricing_Detail__r.Principal_Advanced__c,
                                                                                        Interest_Earned__c,
                                                                                        Principal_Balance__c,
                                                                                        Per_Diem__c,
                                                                                        Fees__c,
                                                                                        Interest_Rate__c,
                                                                                        Pricing_Detail__r.Interest_Per_Diem__c,
                                                                                        Pricing_Detail__r.Fees__c,
                                                                                        Pricing_Detail__c,
                                                                                        Past_Due_Balance__c,
                                                                                        Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c,
                                                                                        genesis__Application__r.Crop_Year__c,
                                                                                        genesis__Application__r.Internal_Reference_Code__c,
                                                                                        genesis__Application__r.Growmark_Unique_Identifier__c,
                                                                                        genesis__Application__r.Guarantee__c,
                                                                                        genesis__Application__r.Available__c,
                                                                                        genesis__Application__r.Reserved_Amount__c,
                                                                                        genesis__Application__r.Past_Due_Amount__c,
                                                                                        genesis__Application__r.CreatedDate
                                                                                        FROM genesis__Application_Fee_Payment__c];

            for(genesis__Application_Fee_Payment__c applicationFeePayment : applicationFeePaymentList){
                applicationFeePayment.Pricing_Detail__c = null;
                feePaymentsToUpdate.add(applicationFeePayment);
            }            
            Database.Update(feePaymentsToUpdate, true);                       
            if (clUserObj != null) {
                System.runAs(clUserObj) {
                Test.startTest();
                List<Map<String, Object>> result = PortalReportsHelper.getChildLoanList(feePaymentsToUpdate);
                System.assertEquals('300023456', result[0].get('loan_number'), 'Assertion failed to test getChildLoanList Without pricing success scenerio');
                Test.stopTest();
                }
            }
    }

    /**
    * @description : Method to test createTableForEndOfYearReport success scenerio
    * @author Tuhin Bhunia | 11-27-2024 
    **/
    @IsTest
    public static void testCreateTableForEndOfYearReport() {
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        List<Map<String, Object>> applicationDataList = new List<Map<String, Object>>();
        Map<String, Map<String, Object>> resultMap = new Map<String, Map<String, Object>>();
        List<AggregateResult> resultList = [SELECT Pricing_Detail__r.genesis__Application__c,
                                                    SUM(Interest_Paid__c) Total_Interest__c
                                                    FROM genesis__Application_Fee_Payment__c
                                                    GROUP BY Pricing_Detail__r.genesis__Application__c];
        Set<Id> applicationIds = new Set<Id>();

        for (AggregateResult aggegateResult : resultList) {
            Map<String, Object> applicationData = new Map<String, Object>();
            applicationIds.add((Id) aggegateResult.get('genesis__Application__c'));
            resultMap.put((String) aggegateResult.get('genesis__Application__c'), applicationData);
        }

        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                    genesis__Loan_Number__c,
                                                                    genesis__Loan_Amount__c,
                                                                    genesis__Maturity_Date__c,
                                                                    genesis__Status__c,
                                                                    genesis__Account__r.Name,
                                                                    Current_Principal_Balance__c,
                                                                    Crop_Year__c,
                                                                    Internal_Reference_Code__c,
                                                                    Growmark_Unique_Identifier__c,
                                                                    Guarantee__c,
                                                                    Available__c,
                                                                    Reserved_Amount__c,
                                                                    CreatedDate
                                                                    FROM genesis__Applications__c];
            for (genesis__Applications__c applicationObj : applicationList) {

                if (resultMap.get(applicationObj.Id) != null) {
                    Map<String, Object> applicationData = resultMap.get(applicationObj.Id);
                    applicationData.put('loan_number', applicationObj.genesis__Loan_Number__c);
                    applicationData.put('loan_amount', applicationObj.genesis__Loan_Amount__c);
                    applicationData.put('maturity_date', applicationObj.genesis__Maturity_Date__c);
                    applicationData.put('grower_name', applicationObj.genesis__Account__r.Name);
                    applicationData.put('principal_balance', applicationObj.Current_Principal_Balance__c);
                    applicationData.put('crop_year', applicationObj.Crop_Year__c);
                    applicationData.put('irc', applicationObj.Internal_Reference_Code__c);
                    applicationData.put('Growmark_Unique_Identifier__c', applicationObj.Growmark_Unique_Identifier__c);
                    applicationData.put('guaranty', applicationObj.Guarantee__c);
                    applicationData.put('created_date', applicationObj.CreatedDate);
                    applicationDataList.add(applicationData);
                }
            }
                                            
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                String result = PortalReportsHelper.createTableForEndOfYearReport(applicationDataList);
                Boolean isSuccess = result.contains(applicationList[0].genesis__Loan_Number__c);
                System.assertEquals(true, isSuccess, 'Assertion failed to test createTableForEndOfYearReport success scenerio');           
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test createTableForEndOfMonthActiveLoanReport success scenerio
    * @author Tuhin Bhunia | 11-27-2024 
    **/
    @IsTest
    public static void testCreateTableForEndOfMonthActiveLoanReport() {

        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        List<Map<String, Object>> childLoanList = new List<Map<String, Object>>();
        List<genesis__Application_Fee_Payment__c> applicationFeePaymentList;

        Set<Id> applicationIds = new Set<Id>();
        applicationFeePaymentList = [SELECT Id,
                                            Pricing_Detail__r.Loan_Number__c,
                                            genesis__Application__r.genesis__Loan_Number__c,
                                            genesis__Application__r.genesis__Loan_Amount__c,
                                            genesis__Application__r.genesis__Maturity_Date__c,
                                            genesis__Application__r.Certified_Lender__r.Name, 
                                            genesis__Application__r.Sales_Agent__r.Name, 
                                            genesis__Application__r.genesis__Credit_Rating__r.Name, 
                                            genesis__Application__r.Note_Date__c,
                                            genesis__Application__r.genesis__Status__c,
                                            genesis__Application__r.genesis__Account__r.Name,
                                            genesis__Application__r.Current_Principal_Balance__c,
                                            genesis__Application__r.Total_Interest__c,
                                            genesis__Application__r.Total_Interest_Per_Diem__c,
                                            genesis__Application__r.Total_Fees__c,
                                            genesis__Application__c,
                                            genesis__Application__r.Pricing_Count__c,
                                            Pricing_Detail__r.genesis__Application__c,
                                            Pricing_Detail__r.genesis__Interest_Rate__c,
                                            Pricing_Detail__r.Principal_Advanced__c,
                                            Interest_Earned__c,
                                            Principal_Balance__c,
                                            Per_Diem__c,
                                            Fees__c,
                                            Interest_Rate__c,
                                            Pricing_Detail__r.Interest_Per_Diem__c,
                                            Pricing_Detail__r.Fees__c,
                                            Pricing_Detail__c,
                                            Past_Due_Balance__c,
                                            Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c,
                                            genesis__Application__r.Crop_Year__c,
                                            genesis__Application__r.Internal_Reference_Code__c,
                                            genesis__Application__r.Growmark_Unique_Identifier__c,
                                            genesis__Application__r.Guarantee__c,
                                            genesis__Application__r.Available__c,
                                            genesis__Application__r.Reserved_Amount__c,
                                            genesis__Application__r.Past_Due_Amount__c,
                                            genesis__Application__r.CreatedDate
                                    FROM genesis__Application_Fee_Payment__c
                                ];

            for (genesis__Application_Fee_Payment__c applicationFeePaymentObj : applicationFeePaymentList) {
                applicationIds.add(applicationFeePaymentObj.Pricing_Detail__r.genesis__Application__c);
            }

            childLoanList = PortalReportsHelper.getChildLoanList(applicationFeePaymentList);

        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                String result = PortalReportsHelper.createTableForEndOfMonthActiveLoanReport(childLoanList);
                Boolean isSuccess = result.contains(applicationFeePaymentList[0].Pricing_Detail__r.Loan_Number__c);
                System.assertEquals(true, isSuccess, 'Assertion failed to test createTableForEndOfMonthActiveLoanReport success scenerio');           
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test createTableForCurrentCropYearReport success scenerio
    * @author Tuhin Bhunia | 11-27-2024 
    **/
    @IsTest
    public static void testCreateTableForCurrentCropYearReport() {
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                    genesis__Loan_Number__c,
                                                                    genesis__Loan_Amount__c,
                                                                    Loan_Id__c,
                                                                    genesis__Maturity_Date__c,
                                                                    genesis__Status__c,
                                                                    genesis__Account__r.Name,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    Crop_Year__c,
                                                                    Internal_Reference_Code__c,
                                                                    Growmark_Unique_Identifier__c,
                                                                    Guarantee__c,
                                                                    CreatedDate,
                                                                    Certified_Lender__r.Name,
                                                                    Sales_Agent__r.Name,
                                                                    Dealer_Name__r.CIF_Number__c
                                                                    FROM genesis__Applications__c];
                                                                    

        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                String result = PortalReportsHelper.createTableForCurrentCropYearReport(applicationList);
                Boolean isSuccess = result.contains(applicationList[0].genesis__Loan_Number__c);
                System.assertEquals(false, isSuccess, 'Assertion failed to test createTableForCurrentCropYearReport success scenerio');           
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test createTableForPriorCropYearReport success scenerio
    * @author Tuhin Bhunia | 11-27-2024 
    **/
    @IsTest
    public static void testCreateTableForPriorCropYearReport() {
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                    genesis__Loan_Number__c,
                                                                    genesis__Loan_Amount__c,
                                                                    Loan_Id__c,
                                                                    genesis__Maturity_Date__c,
                                                                    genesis__Status__c,
                                                                    genesis__Account__r.Name,
                                                                    genesis__Credit_Rating__r.Name,
                                                                    Crop_Year__c,
                                                                    Internal_Reference_Code__c,
                                                                    Growmark_Unique_Identifier__c,
                                                                    Guarantee__c,
                                                                    CreatedDate,
                                                                    Certified_Lender__r.Name,
                                                                    Sales_Agent__r.Name,
                                                                    Dealer_Name__r.CIF_Number__c
                                                                    FROM genesis__Applications__c];
                                                                    
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                String result = PortalReportsHelper.createTableForPriorCropYearReport(applicationList);
                Boolean isSuccess = result.contains(applicationList[0].genesis__Loan_Number__c);
                System.assertEquals(false, isSuccess, 'Assertion failed to test createTableForPriorCropYearReport success scenerio');           
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test createTableForOnlineUsersReport success scenerio
    * @author Tuhin Bhunia | 11-27-2024 
    **/
    @IsTest
    public static void testCreateTableForOnlineUsersReport() {
        User clUserObj = TestClassHelper.getCertifiedLenderUserV2('Ross Geller');
        
        List<AggregateResult> onlineUsers = [SELECT clcommon__Contact__r.Name, 
                                                    COUNT(genesis__Application__r.Loan_Id__c) loanCount, 
                                                    clcommon__Contact__r.MobilePhone, 
                                                    clcommon__Contact__r.Email 
                                                    FROM clcommon__Party__c 
                                                    GROUP BY clcommon__Contact__c, 
                                                    clcommon__Contact__r.MobilePhone,
                                                    clcommon__Contact__r.Email,
                                                    clcommon__Contact__r.Name ];

        List<Map<String, Object>> resultList = new List<Map<String,Object>>();
        Map<String, Object> responseMap;
        for(AggregateResult onlineUser: onlineUsers) {
            responseMap = new Map<String, Object>();
            responseMap.put('Name', onlineUser.get('Name'));
            responseMap.put('Email', onlineUser.get('Email'));
            responseMap.put('Phone', onlineUser.get('MobilePhone'));
            
            if ((Integer)(onlineUser.get('loanCount')) > 0) {
                responseMap.put('has_active_loan', 'Yes');
            } else {
                responseMap.put('has_active_loan', 'No');
            }
            
            resultList.add(responseMap);
        }
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                String result = PortalReportsHelper.createTableForOnlineUsersReport(resultList);
                Boolean isSuccess = result.contains(String.valueOf(onlineUsers[0].get('Name')));
                System.assertEquals(true, isSuccess, 'Assertion failed to test createTableForOnlineUsersReport success scenerio');           
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test createTableForSubsidyAccrualReport success scenerio
    * @author Tuhin Bhunia | 11-27-2024 
    **/
    @IsTest
    public static void testCreateTableForSubsidyAccrualReport() {
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        
        List<genesis__Application_Fee_Payment__c> applicationFeePaymentList = [SELECT Id,
                                                                    Pricing_Detail__r.Loan_Number__c,
                                                                    genesis__Application__r.genesis__Loan_Amount__c,
                                                                    genesis__Application__r.genesis__Maturity_Date__c,
                                                                    genesis__Application__r.Certified_Lender__r.Name,
                                                                    genesis__Application__r.Sales_Agent__r.Name,
                                                                    genesis__Application__r.genesis__Status__c,
                                                                    genesis__Application__r.genesis__Account__r.Name,
                                                                    genesis__Application__r.Dealer_Name__r.BillingCity,
                                                                    genesis__Application__r.Dealer_Name__r.BillingState,
                                                                    Pricing_Detail__r.genesis__Interest_Rate__c,
                                                                    Pricing_Detail__r.Principal_Advanced__c,
                                                                    Pricing_Detail__r.Dealer_Interest_Accrued__c,
                                                                    Pricing_Detail__r.Dealer_Interest_Per_Diem__c,
                                                                    Pricing_Detail__r.Interest_Per_Diem__c,
                                                                    Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c,
                                                                    Dealer_Monthly_Interest__c,
                                                                    Interest_Earned__c,
                                                                    Principal_Balance__c,
                                                                    genesis__Application__r.Crop_Year__c,
                                                                    genesis__Application__r.Internal_Reference_Code__c,
                                                                    genesis__Application__r.Growmark_Unique_Identifier__c,
                                                                    genesis__Application__r.Guarantee__c,
                                                                    genesis__Application__r.Available__c,
                                                                    genesis__Application__r.Reserved_Amount__c,
                                                                    Pricing_Detail__r.CreatedDate
                                                                    FROM genesis__Application_Fee_Payment__c];
                                                                    
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                String result = PortalReportsHelper.createTableForSubsidyAccrualReport(applicationFeePaymentList);
                Boolean isSuccess = result.contains(applicationFeePaymentList[0].Pricing_Detail__r.Loan_Number__c);
                System.assertEquals(true, isSuccess, 'Assertion failed to test createTableForSubsidyAccrualReport success scenerio');           
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test createTableForPremiumAccrualReport
    * @author Tuhin Bhunia | 11-27-2024 
    **/
    @IsTest
    public static void testCreateTableForPremiumAccrualReport() {
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        
        List<genesis__Application_Fee_Payment__c> applicationFeePaymentList = [SELECT Id,
                                                                                        Pricing_Detail__r.Loan_Number__c,
                                                                                        genesis__Application__r.genesis__Loan_Amount__c,
                                                                                        genesis__Application__r.genesis__Maturity_Date__c,
                                                                                        genesis__Application__r.Certified_Lender__r.Name,
                                                                                        genesis__Application__r.Sales_Agent__r.Name,
                                                                                        genesis__Application__r.genesis__Status__c,
                                                                                        genesis__Application__r.genesis__Account__r.Name,
                                                                                        genesis__Application__r.Dealer_Name__r.BillingCity,
                                                                                        genesis__Application__r.Dealer_Name__r.BillingState,
                                                                                        Pricing_Detail__r.genesis__Interest_Rate__c,
                                                                                        Pricing_Detail__r.Principal_Advanced__c,
                                                                                        Pricing_Detail__r.Dealer_Interest_Accrued__c,
                                                                                        Pricing_Detail__r.Dealer_Interest_Per_Diem__c,
                                                                                        Pricing_Detail__r.Interest_Per_Diem__c,
                                                                                        Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c,
                                                                                        Dealer_Monthly_Interest__c,
                                                                                        Interest_Earned__c,
                                                                                        Principal_Balance__c,
                                                                                        genesis__Application__r.Crop_Year__c,
                                                                                        genesis__Application__r.Internal_Reference_Code__c,
                                                                                        genesis__Application__r.Growmark_Unique_Identifier__c,
                                                                                        genesis__Application__r.Guarantee__c,
                                                                                        genesis__Application__r.Available__c,
                                                                                        genesis__Application__r.Reserved_Amount__c,
                                                                                        Pricing_Detail__r.CreatedDate
                                                                                        FROM genesis__Application_Fee_Payment__c];
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                String result = PortalReportsHelper.createTableForPremiumAccrualReport(applicationFeePaymentList);
                Boolean isSuccess = result.contains(applicationFeePaymentList[0].Pricing_Detail__r.Loan_Number__c);
                System.assertEquals(true, isSuccess, 'Assertion failed to test createTableForPremiumAccrualReport success scenerio');           
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test createTableForLoanAccrualReport success scenerio
    * @author Tuhin Bhunia | 11-27-2024 
    **/
    @IsTest
    public static void testCreateTableForLoanAccrualReport() {
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        
        List<genesis__Application_Pricing_Detail__c> applicationPricingList;
        List<genesis__Applications__c> applicationList;

        List<Map<String, Object>> loanAccountList = new List<Map<String, Object>>();
        List<Map<String, Object>> commitmentLoanList = new List<Map<String, Object>>();

        applicationPricingList = [SELECT Id,
                                            genesis__Application__r.Certified_Lender__r.Name, 
                                            genesis__Application__r.Sales_Agent__r.Name, 
                                            genesis__Application__r.genesis__Credit_Rating__r.Name, 
                                            genesis__Application__r.Note_Date__c,
                                            Loan_Number__c,
                                            genesis__Application__r.genesis__Loan_Amount__c,
                                            genesis__Application__r.genesis__Maturity_Date__c,
                                            genesis__Application__r.genesis__Status__c,
                                            genesis__Application__r.genesis__Account__r.Name,
                                            genesis__Interest_Rate__c,
                                            Principal_Advanced__c,
                                            Accrued_Interest__c,
                                            Interest_Per_Diem__c,
                                            Fees__c,
                                            genesis__Rate_Card_Setup_Detail__r.Description__c,
                                            genesis__Application__r.Crop_Year__c,
                                            genesis__Application__r.Internal_Reference_Code__c,
                                            genesis__Application__r.Growmark_Unique_Identifier__c,
                                            genesis__Application__r.Guarantee__c,
                                            genesis__Application__r.Available__c,
                                            genesis__Application__r.Reserved_Amount__c,
                                            genesis__Application__r.CreatedDate,
                                            genesis__Application__r.Pricing_Count__c
                                            FROM genesis__Application_Pricing_Detail__c];
                                            
        applicationList = [SELECT Id,
                                    Certified_Lender__r.Name, 
                                    Sales_Agent__r.Name, 
                                    genesis__Credit_Rating__r.Name, 
                                    Note_Date__c,
                                    genesis__Loan_Amount__c,
                                    genesis__Maturity_Date__c,
                                    genesis__Status__c,
                                    genesis__Account__r.Name,
                                    Current_Principal_Balance__c,
                                    Total_Interest__c,
                                    Total_Interest_Per_Diem__c,
                                    Total_Fees__c,
                                    genesis__Loan_Number__c,
                                    Crop_Year__c,
                                    Internal_Reference_Code__c,
                                    Growmark_Unique_Identifier__c,
                                    Guarantee__c,
                                    Available__c,
                                    Reserved_Amount__c,
                                    CreatedDate,
                                    Pricing_Count__c
                                    FROM genesis__Applications__c];
                                    
        loanAccountList = PortalReportsHelper.getLoanAccountList(applicationPricingList);
        commitmentLoanList = PortalReportsHelper.getCommitmentLoanList(applicationList);
        loanAccountList.addAll(commitmentLoanList);

        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                String result = PortalReportsHelper.createTableForLoanAccrualReport(loanAccountList);
                Boolean isSuccess = result.contains(applicationList[0].genesis__Loan_Number__c);
                System.assertEquals(true, isSuccess, 'Assertion failed to test createTableForLoanAccrualReport success scenerio');           
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test createTableForRateChangeNotificationReport success scenerio
    * @author Tuhin Bhunia | 11-27-2024 
    **/
    @IsTest
    public static void testCreateTableForRateChangeNotificationReport() {
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        List<AggregateResult> results = [SELECT Loan_Number__c 
                                                FROM genesis__Application_Pricing_Detail__c 
                                                GROUP BY Loan_Number__c 
                                                HAVING COUNT(Id) > 1];
        List<String> loanNumberList = new List<String>();
        for (AggregateResult result : results) {
            if (result.get('Loan_Number__c') != null) {
                loanNumberList.add(String.valueOf(result.get('Loan_Number__c')));
            }  
        }
        List<genesis__Application_Pricing_Detail__c> objApplicationPricingList = [SELECT genesis__Rate_Card_Setup_Detail__r.Start_Date__c, 
                                                                                        genesis__Rate_Card_Setup_Detail__r.End_Date__c, 
                                                                                        genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c,
                                                                                        genesis__Application__r.genesis__Account__r.Name,
                                                                                        genesis__Application__r.genesis__Loan_Number__c,
                                                                                        genesis__Application__r.genesis__Maturity_Date__c,
                                                                                        genesis__Application__r.Certified_Lender__r.Name,
                                                                                        genesis__Application__r.Internal_Reference_Code__c,
                                                                                        genesis__Application__r.Growmark_Unique_Identifier__c,
                                                                                        genesis__Application__r.Sales_Agent__r.Name,
                                                                                        genesis__Application__r.genesis__Account__r.clcommon__Email__c,
                                                                                        Loan_Number__c,
                                                                                        genesis__Enabled_Flag__c 
                                                                                FROM genesis__Application_Pricing_Detail__c
                                                                            ];
        Map<Object, Map<String, List<genesis__Application_Pricing_Detail__c>>> objApplicationPricingMap = 
                new Map<Object, Map<String, List<genesis__Application_Pricing_Detail__c>>>();

        Map<Id, clcommon__party__c> appIdToPartyMap = new Map<Id, clcommon__party__c>();
        List<clcommon__Party__c> objPartyList = [SELECT Id, Mobile_Number__c,
                                                        Street__c,
                                                        City__c,
                                                        State__c,
                                                        Postal_Code__c,
                                                        genesis__Application__c
                                                        FROM clcommon__party__c
                                                        WHERE clcommon__type__r.name =: PortalConstants.BORROWER_PARTY_NAME
                                                        AND genesis__Application__r.genesis__Status__c =: PortalConstants.ACTIVE_APPLICATION_STATUS];

        for(clcommon__party__c eachParty : objPartyList){
            appIdToPartyMap.put(eachParty.genesis__Application__c, eachParty);
        }

        for (genesis__Application_Pricing_Detail__c objApplicationPricing : objApplicationPricingList) {
            List<genesis__Application_Pricing_Detail__c> subTrancheList;
            Map<String, List<genesis__Application_Pricing_Detail__c>> innerMap;
            
            String isEnabled = String.valueOf(objApplicationPricing.genesis__Enabled_Flag__c);
            
            if (objApplicationPricingMap.containsKey(objApplicationPricing.Loan_Number__c)) {
                // if the loan number key is present in the map already
                innerMap = objApplicationPricingMap.get(objApplicationPricing.Loan_Number__c);
                
                if (!innerMap.containsKey(isEnabled)) {
                    // add the String key
                    subTrancheList = new List<genesis__Application_Pricing_Detail__c>();
                    subTrancheList.add(objApplicationPricing);
                    innerMap.put(isEnabled, subTrancheList);
                } else {
                    subTrancheList = innerMap.get(isEnabled);
                    subTrancheList.add(objApplicationPricing);
                    innerMap.put(isEnabled, subTrancheList);
                }
            } else {
                innerMap = new Map<String, List<genesis__Application_Pricing_Detail__c>>();
                subTrancheList = new List<genesis__Application_Pricing_Detail__c>();
                subTrancheList.add(objApplicationPricing);
                innerMap.put(isEnabled, subTrancheList);
            }
            
            objApplicationPricingMap.put(objApplicationPricing.Loan_Number__c, innerMap);
        }
        List<Map<String, Object>> resultList = new List<Map<String, Object>>();
        resultList = PortalReportsHelper.getResultList(objApplicationPricingMap, appIdToPartyMap);
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                String result = PortalReportsHelper.createTableForRateChangeNotificationReport(resultList);
                Boolean isSuccess = result.contains(objApplicationPricingList[0].genesis__Application__r.genesis__Loan_Number__c);
                System.assertEquals(true, isSuccess, 'Assertion failed to test createTableForRateChangeNotificationReport success scenerio');           
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test createTableForExportActiveLoanReport success scenerio
    * @author Tuhin Bhunia | 11-27-2024 
    **/
    @IsTest
    public static void testCreateTableForExportActiveLoanReport() {
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        
        List<genesis__Applications__c> objApplicationList = [SELECT Id,
                                                                    Certified_Lender__r.Name, 
                                                                    Sales_Agent__r.Name, 
                                                                    genesis__Credit_Rating__r.Name, 
                                                                    Note_Date__c,
                                                                    genesis__Loan_Amount__c,
                                                                    genesis__Maturity_Date__c,
                                                                    genesis__Status__c,
                                                                    genesis__Account__r.Name,
                                                                    Current_Principal_Balance__c,
                                                                    genesis__Loan_Number__c,
                                                                    genesis__Interest_Rate__c,
                                                                    Total_Interest__c,
                                                                    Total_Interest_Per_Diem__c,
                                                                    Total_Fees__c,
                                                                    Crop_Year__c,
                                                                    Internal_Reference_Code__c,
                                                                    Growmark_Unique_Identifier__c,
                                                                    Guarantee__c,
                                                                    Available__c,
                                                                    Reserved_Amount__c,
                                                                    Past_Due_Amount__c,
                                                                    CreatedDate
                                                                    FROM genesis__Applications__c];
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                String result = PortalReportsHelper.createTableForExportActiveLoanReport(objApplicationList);
                Boolean isSuccess = result.contains(objApplicationList[0].genesis__Loan_Number__c);
                System.assertEquals(true, isSuccess, 'Assertion failed to test createTableForExportActiveLoanReport success scenerio');           
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test GetFormatedDate success scenario
     * @author Tuhin Bhunia | 11-28-2024 
     **/
    @isTest
    public static void testGetFormatedDateSuccessScenario(){
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        Datetime parsedDate = (Datetime)System.now();
        String dateStr = String.valueOf(date.newInstance(parsedDate.yearGmt(), parsedDate.monthGmt(), parsedDate.dayGmt()));
        if(clUserObj != null){
            System.runAs(clUserObj){
                Test.startTest();
                String result = PortalReportsHelper.getformatedDate(parsedDate);
                System.assertEquals(result, dateStr, 'Assertion failed to test getformatedDate success scenerio');
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test GetFormatedDate faliure scenario
     * @author Tuhin Bhunia | 11-28-2024 
     **/
    @isTest
    public static void testGetFormatedDateFailureScenario(){
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        if(clUserObj != null){
            System.runAs(clUserObj){
                Test.startTest();
                String result = PortalReportsHelper.getformatedDate(null);
                System.assertEquals(result, null, 'Assertion failed to test getformatedDate faliure scenerio');
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test createPDFTableRow success scenerio 
     * @author Tuhin Bhunia | 11-28-2024 
     **/
    @isTest
    public static void testCreatePDFTableRowSuccess(){
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        String tdStart = '<td>';
        String tdEnd = '</td>';
        String cellData = 'Test Table Row';
        String expectedResult = tdStart + cellData + tdEnd;
        if(clUserObj != null){
            System.runAs(clUserObj){
                Test.startTest();
                String result = PortalReportsHelper.createPDFTableRow(cellData);
                System.assertEquals(result, expectedResult, 'Assertion failed to test createPDFTableRow success scenerio');
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test createPDFTableRow faliure scenerio 
     * @author Tuhin Bhunia | 11-28-2024 
     **/
    @isTest
    public static void testCreatePDFTableRowFailure(){
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        String expectedResult = '<td></td>';
        if(clUserObj != null){
            System.runAs(clUserObj){
                Test.startTest();
                String result = PortalReportsHelper.createPDFTableRow(null);
                System.assertEquals(result, expectedResult, 'Assertion failed to test createPDFTableRow faliure scenerio');
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test checkAndThrowExceptionIfListEmpty faliure scenerio 
     * @author Tuhin Bhunia | 11-28-2024 
     **/
    @isTest
    public static void testCheckAndThrowExceptionIfListEmpty(){
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        if(clUserObj != null){
            System.runAs(clUserObj){
                Test.startTest();
                    try {
                        PortalReportsHelper.checkAndThrowExceptionIfListEmpty(new List<String>());
                    } catch (CustomException exceptionObj) {
                        System.assertEquals(PortalConstants.NO_DATA_TO_EXPORT, exceptionObj.getMessage(), 'Assertion failed to test checkAndThrowExceptionIfListEmpty faliure scenerio');
                    }
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test exportAndDataTypeMissingThrowException faliure scenerio when export type is missing
     * @author Tuhin Bhunia | 11-28-2024 
     **/
    @isTest
    public static void testReportAndExportTypeMissingThrowException(){
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        if(clUserObj != null){
            System.runAs(clUserObj){
                Test.startTest();
                    try {
                        PortalReportsHelper.reportAndExportTypeMissingThrowException(new Map<String, Object>{
                            PortalConstants.KEY_REPORT_TYPE => PortalConstants.LOAN_ACCOUNT_REPORT,
                            PortalConstants.KEY_EXPORT_TYPE => null
                        });
                    } catch (CustomException exceptionObj) {
                        System.assertEquals(PortalConstants.REQUIRED_PARAMETERS_MISSING, exceptionObj.getMessage(), 'Assertion failed to test requiredParameterMissingThrowException faliure scenerio');
                    }
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test exportAndDataTypeMissingThrowException faliure scenerio when data type and export type is missing
     * @author Tuhin Bhunia | 11-28-2024 
     **/
    @isTest
    public static void testExportAndDataTypeMissingThrowException(){
    User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        if(clUserObj != null){
            System.runAs(clUserObj){
            Test.startTest();
                try {
                    PortalReportsHelper.exportAndDataTypeMissingThrowException(new Map<String, Object>{
                        PortalConstants.KEY_EXPORT_TYPE => '',
                        PortalConstants.KEY_DATA_TYPE => ''
                    });
                } catch (CustomException exceptionObj) {
                    System.assertEquals(PortalConstants.REQUIRED_PARAMETERS_MISSING, exceptionObj.getMessage(), 'Assertion failed to test requiredParameterMissingThrowException faliure scenerio');
                }
            Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test exportAndDataTypeMissingThrowException faliure scenerio when data type is missing
    * @author Tuhin Bhunia | 11-28-2024 
    **/
    @isTest
    public static void testReportTypeMissingThrowException(){
    User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
    if(clUserObj != null){
        System.runAs(clUserObj){
            Test.startTest();
                try {
                    PortalReportsHelper.exportAndDataTypeMissingThrowException(new Map<String, Object>{
                        PortalConstants.KEY_EXPORT_TYPE => 'pdf',
                        PortalConstants.KEY_DATA_TYPE => ''
                    });
                } catch (CustomException exceptionObj) {
                    System.assertEquals(PortalConstants.REQUIRED_PARAMETERS_MISSING, exceptionObj.getMessage(), 'Assertion failed to test requiredParameterMissingThrowException faliure scenerio');
                }
            Test.stopTest();
        }
    }
}

    /**
    * @description : Method to test requiredParameterMissingThrowException faliure scenerio
    * @author Tuhin Bhunia | 11-28-2024 
    **/
    @isTest
    public static void testRequiredParameterMissingThrowException(){
    User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        if(clUserObj != null){
            System.runAs(clUserObj){
            Test.startTest();
                try {
                    PortalReportsHelper.requiredParameterMissingThrowException(new Map<String, Object>{
                        PortalConstants.KEY_BATCH_ID => null
                    });
                } catch (CustomException exceptionObj) {
                    System.assertEquals(PortalConstants.REQUIRED_PARAMETERS_MISSING, exceptionObj.getMessage(), 'Assertion failed to test requiredParameterMissingThrowException faliure scenerio');
                }
            Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test hasActiveLoan success scenerio
    * @author Tuhin Bhunia | 11-28-2024 
    **/
    @isTest
    public static void testHasActiveLoanSuccess(){
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        if(clUserObj != null){
            System.runAs(clUserObj){
                Test.startTest();
                String result = PortalReportsHelper.hasActiveLoan(5);
                System.assertEquals('Yes', result, 'Assertion failed to test hasActiveLoan success scenerio');
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test hasActiveLoan faliure scenerio
    * @author Tuhin Bhunia | 11-28-2024 
    **/
    @isTest
    public static void testHasActiveLoanFailure(){
    User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        if(clUserObj != null){
            System.runAs(clUserObj){
            Test.startTest();
            String result = PortalReportsHelper.hasActiveLoan(0);
            System.assertEquals('No', result, 'Assertion failed to test hasActiveLoan faliure scenerio');
            Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test createTableForGMKOnlineUsersReport success scenerio
    * @author Tuhin Bhunia | 11-28-2024 
    **/
    @isTest
    public static void testCreateTableForGMKOnlineUsersReport(){
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        
        List<AggregateResult> onlineUsers = [SELECT clcommon__Contact__r.Name, 
                                                    COUNT(genesis__Application__r.Loan_Id__c) loanCount, 
                                                    clcommon__Contact__r.MobilePhone, 
                                                    clcommon__Contact__r.Email 
                                            FROM clcommon__Party__c 
                                            GROUP BY clcommon__Contact__c, 
                                                    clcommon__Contact__r.MobilePhone,
                                                    clcommon__Contact__r.Email,
                                                    clcommon__Contact__r.Name ];

        List<Map<String, Object>> resultList = new List<Map<String,Object>>();
        Map<String, Object> responseMap;
        
        for(AggregateResult onlineUser: onlineUsers) {
            responseMap = new Map<String, Object>{
                'Name' => onlineUser.get('Name'),
                'Email' => onlineUser.get('Email'),
                'Phone' => onlineUser.get('MobilePhone')
            };
            
            if ((Integer)(onlineUser.get('loanCount')) > 0) {
                responseMap.put('has_active_loan', 'Yes');
            } else {
                responseMap.put('has_active_loan', 'No');
            }
            
            resultList.add(responseMap);
        }

        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                String result = PortalReportsHelper.createTableForGMKOnlineUsersReport(resultList);
                Boolean isSuccess = result.contains(String.valueOf(onlineUsers[0].get('Name')));
                System.assertEquals(true, isSuccess, 'Assertion failed to test createTableForGMKOnlineUsersReport success scenerio');           
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test createTableForGMKSubsidyAccrualReport success scenerio
    * @author Tuhin Bhunia | 11-28-2024 
    **/
    @isTest
    public static void testCreateTableForGMKSubsidyAccrualReport(){
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        
        List<genesis__Application_Fee_Payment__c> applicationFeePaymentList = [SELECT Id,
                                                                    Pricing_Detail__r.Loan_Number__c,
                                                                    genesis__Application__r.genesis__Loan_Amount__c,
                                                                    genesis__Application__r.genesis__Maturity_Date__c,
                                                                    genesis__Application__r.Certified_Lender__r.Name,
                                                                    genesis__Application__r.Sales_Agent__r.Name,
                                                                    genesis__Application__r.genesis__Status__c,
                                                                    genesis__Application__r.genesis__Account__r.Name,
                                                                    genesis__Application__r.Dealer_Name__r.BillingCity,
                                                                    genesis__Application__r.Dealer_Name__r.BillingState,
                                                                    Pricing_Detail__r.genesis__Interest_Rate__c,
                                                                    Pricing_Detail__r.Principal_Advanced__c,
                                                                    Pricing_Detail__r.Dealer_Interest_Accrued__c,
                                                                    Pricing_Detail__r.Dealer_Interest_Per_Diem__c,
                                                                    Pricing_Detail__r.Interest_Per_Diem__c,
                                                                    Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c,
                                                                    Dealer_Monthly_Interest__c,
                                                                    Interest_Earned__c,
                                                                    Principal_Balance__c,
                                                                    genesis__Application__r.Crop_Year__c,
                                                                    genesis__Application__r.Internal_Reference_Code__c,
                                                                    genesis__Application__r.Growmark_Unique_Identifier__c,
                                                                    genesis__Application__r.Guarantee__c,
                                                                    genesis__Application__r.Available__c,
                                                                    genesis__Application__r.Reserved_Amount__c,
                                                                    Pricing_Detail__r.CreatedDate
                                                                FROM genesis__Application_Fee_Payment__c];
                                                                    
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                String result = PortalReportsHelper.createTableForGMKSubsidyAccrualReport(applicationFeePaymentList);
                Boolean isSuccess = result.contains(applicationFeePaymentList[0].Pricing_Detail__r.Loan_Number__c);
                System.assertEquals(true, isSuccess, 'Assertion failed to test createTableForGMKSubsidyAccrualReport success scenerio');
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test createTableForGMKPremiumAccrualReport success scenerio
    * @author Tuhin Bhunia | 11-28-2024 
    **/
    @isTest
    public static void testCreateTableForGMKPremiumAccrualReport(){
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Application_Fee_Payment__c> applicationFeePaymentList = [SELECT Id,
                                                                                Pricing_Detail__r.Loan_Number__c,
                                                                                genesis__Application__r.genesis__Loan_Amount__c,
                                                                                genesis__Application__r.genesis__Maturity_Date__c,
                                                                                genesis__Application__r.Certified_Lender__r.Name,
                                                                                genesis__Application__r.Sales_Agent__r.Name,
                                                                                genesis__Application__r.genesis__Status__c,
                                                                                genesis__Application__r.genesis__Account__r.Name,
                                                                                genesis__Application__r.Dealer_Name__r.BillingCity,
                                                                                genesis__Application__r.Dealer_Name__r.BillingState,
                                                                                Pricing_Detail__r.genesis__Interest_Rate__c,
                                                                                Pricing_Detail__r.Principal_Advanced__c,
                                                                                Pricing_Detail__r.Dealer_Interest_Accrued__c,
                                                                                Pricing_Detail__r.Dealer_Interest_Per_Diem__c,
                                                                                Pricing_Detail__r.Interest_Per_Diem__c,
                                                                                Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c,
                                                                                Dealer_Monthly_Interest__c,
                                                                                Interest_Earned__c,
                                                                                Principal_Balance__c,
                                                                                genesis__Application__r.Crop_Year__c,
                                                                                genesis__Application__r.Internal_Reference_Code__c,
                                                                                genesis__Application__r.Growmark_Unique_Identifier__c,
                                                                                genesis__Application__r.Guarantee__c,
                                                                                genesis__Application__r.Available__c,
                                                                                genesis__Application__r.Reserved_Amount__c,
                                                                                Pricing_Detail__r.CreatedDate
                                                                            FROM genesis__Application_Fee_Payment__c];
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                String result = PortalReportsHelper.createTableForGMKPremiumAccrualReport(applicationFeePaymentList);
                Boolean isSuccess = result.contains(applicationFeePaymentList[0].Pricing_Detail__r.Loan_Number__c);
                System.assertEquals(true, isSuccess, 'Assertion failed to test createTableForGMKPremiumAccrualReport success scenerio');
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Method to test createTableForGMKLoanAccrualReport success scenerio
    * @author Tuhin Bhunia | 11-28-2024 
    **/
    @isTest
    public static void testCreateTableForGMKLoanAccrualReport(){
        User clUserObj = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Application_Pricing_Detail__c> applicationPricingList;
        List<genesis__Applications__c> applicationList;
        List<Map<String, Object>> loanAccountList = new List<Map<String, Object>>();
        List<Map<String, Object>> commitmentLoanList = new List<Map<String, Object>>();
        applicationPricingList = [SELECT Id,
                                            genesis__Application__r.Certified_Lender__r.Name, 
                                            genesis__Application__r.Sales_Agent__r.Name, 
                                            genesis__Application__r.genesis__Credit_Rating__r.Name, 
                                            genesis__Application__r.Note_Date__c,
                                            Loan_Number__c,
                                            genesis__Application__r.genesis__Loan_Amount__c,
                                            genesis__Application__r.genesis__Maturity_Date__c,
                                            genesis__Application__r.genesis__Status__c,
                                            genesis__Application__r.genesis__Account__r.Name,
                                            genesis__Interest_Rate__c,
                                            Principal_Advanced__c,
                                            Accrued_Interest__c,
                                            Interest_Per_Diem__c,
                                            Fees__c,
                                            genesis__Rate_Card_Setup_Detail__r.Description__c,
                                            genesis__Application__r.Crop_Year__c,
                                            genesis__Application__r.Internal_Reference_Code__c,
                                            genesis__Application__r.Growmark_Unique_Identifier__c,
                                            genesis__Application__r.Guarantee__c,
                                            genesis__Application__r.Available__c,
                                            genesis__Application__r.Reserved_Amount__c,
                                            genesis__Application__r.CreatedDate,
                                            genesis__Application__r.Pricing_Count__c
                                            FROM genesis__Application_Pricing_Detail__c];
        applicationList = [SELECT Id,
                                    Certified_Lender__r.Name, 
                                    Sales_Agent__r.Name, 
                                    genesis__Credit_Rating__r.Name, 
                                    Note_Date__c,
                                    genesis__Loan_Amount__c,
                                    genesis__Maturity_Date__c,
                                    genesis__Status__c,
                                    genesis__Account__r.Name,
                                    Current_Principal_Balance__c,
                                    Total_Interest__c,
                                    Total_Interest_Per_Diem__c,
                                    Total_Fees__c,
                                    genesis__Loan_Number__c,
                                    Crop_Year__c,
                                    Internal_Reference_Code__c,
                                    Growmark_Unique_Identifier__c,
                                    Guarantee__c,
                                    Available__c,
                                    Reserved_Amount__c,
                                    CreatedDate,
                                    Pricing_Count__c
                                    FROM genesis__Applications__c];
                                    
        loanAccountList = PortalReportsHelper.getLoanAccountList(applicationPricingList);
        commitmentLoanList = PortalReportsHelper.getCommitmentLoanList(applicationList);
        loanAccountList.addAll(commitmentLoanList);
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                String result = PortalReportsHelper.createTableForGMKLoanAccrualReport(loanAccountList);
                Boolean isSuccess = result.contains(applicationList[0].genesis__Loan_Number__c);
                System.assertEquals(true, isSuccess, 'Assertion failed to test createTableForGMKLoanAccrualReport success scenerio');           
                Test.stopTest();
            }
        }
    }
    
    /**
    * @description Method to test checkRequestParam exception scenerio
    * @author Shristy Kumari | 01-21-2025 
    **/
    @isTest
    public static void testCheckRequestParam(){
        User adminUserObj = getUser();
        String errorMessage;
        Map<String, Object> requestMap = new Map<String, Object>();
        String paymentParam;
        System.runAs(adminUserObj){
                Test.startTest();
                Try{
                    PortalReportsHelper.checkRequestParam(requestMap,paymentParam);
                }
                catch(CustomException exceptionObj){
                    errorMessage = exceptionObj.getMessage();
                }    
                System.assertEquals(errorMessage, 'Required parameters missing', 'Assertion failed to test checkRequestParam exception scenerio');
                Test.stopTest();
        } 
    }

    /**
    * @description Method to test checkRequestParam Success scenerio
    * @author Shristy Kumari | 01-21-2025 
    **/
    @isTest
    public static void testCheckRequestParamSuccess(){
        User adminUserObj = getUser();
        //Account accountObj;
        boolean isException = false;
        String paymentParam;
        Map<String, Object> requestMap = new Map<String, Object>{ paymentParam => null };
        System.runAs(adminUserObj){
                Test.startTest();
                Try{
                    PortalReportsHelper.checkRequestParam(requestMap,paymentParam);
                }
                catch(CustomException exceptionObj){
                    isException = true;
                }    
                System.assertEquals(isException, false, 'Assertion failed to test checkRequestParam Success scenerio');
                Test.stopTest();
        }
    }

    /**
    * @description Method to test checkRequestBody exception scenerio
    * @author Shristy Kumari | 01-21-2025 
    **/
    @isTest
    public static void testCheckRequestBodyException(){
        User adminUserObj = getUser();
        String errorMessage;
        String param;
        Map<String, Object> requestMap = new Map<String, Object>{param => null};
        System.runAs(adminUserObj){
                Test.startTest();
                Try{
                    PortalReportsHelper.checkRequestBody(requestMap,param);
                }
                catch(CustomException exceptionObj){
                    errorMessage = exceptionObj.getMessage();
                }    
                System.assertEquals(errorMessage, 'Required parameters missing', 'Assertion failed to test checkRequestBody exception scenerio');
                Test.stopTest();
        } 
    }

    /**
    * @description Method to test checkRequestBody Success scenerio
    * @author Shristy Kumari | 01-21-2025 
    **/
    @isTest
    public static void testCheckRequestBodySuccess(){
        User adminUserObj = getUser();
        Account accountObj = new Account();
        boolean isException = false;
        String param;
        Map<String, Object> requestMap = new Map<String, Object>{ param => accountObj };
        System.runAs(adminUserObj){
                Test.startTest();
                Try{
                    PortalReportsHelper.checkRequestBody(requestMap,param);
                }
                catch(CustomException exceptionObj){
                    isException = true;
                }    
                System.assertEquals(isException, false, 'Assertion failed to test checkRequestBody Success scenerio');
                Test.stopTest();
        }
    }

    /**
    * @description Method to test reportTypeMissingThrowException exception scenerio
    * @author Shristy Kumari | 01-21-2025 
    **/
    @isTest
    public static void testReportTypeMissingThrowExceptionScenerio(){
        User adminUserObj = getUser();
        String errorMessage;
        Map<String, Object> requestMap = new Map<String, Object>();
        System.runAs(adminUserObj){
                Test.startTest();
                Try{
                    PortalReportsHelper.reportTypeMissingThrowException(requestMap);
                }
                catch(CustomException exceptionObj){
                    errorMessage = exceptionObj.getMessage();
                }    
                System.assertEquals(errorMessage, 'Required parameters missing', 'Assertion failed to test reportTypeMissingThrowException exception scenerio');
                Test.stopTest();
        } 
    }

    /**
    * @description Method to test getProductReturnSummaryListand createTableForProductReturnSummaryReport success scenerio
    * @author Shristy Kumari | 01-21-2025 
    **/
    @isTest
    public static void testcreateTableForProductReturnSummaryReport(){
        String tableData = '';
        List<genesis__Funding_Transaction__c> fundingTransactionList = [SELECT Grower_Name__c,
                                                                                Pricing_Detail__r.genesis__Application__r.genesis__Account__r.Name,
                                                                                Pricing_Detail__r.Loan_Number__c,
                                                                                Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c,
                                                                                Pricing_Detail__r.genesis__Application__r.Crop_Year__c,
                                                                                genesis__Reference__c,
                                                                                genesis__Amount__c,
                                                                                createdDate,
                                                                                CreatedBy.Account.Name
                                                                            FROM genesis__Funding_Transaction__c
                                                                            LIMIT 2];
        User adminUserObj = getUser();
        System.runAs(adminUserObj){
                Test.startTest();
                List<Map<String, Object>> productReturnList = PortalReportsHelper.getProductReturnSummaryList(fundingTransactionList);
                tableData = PortalReportsHelper.createTableForProductReturnSummaryReport(productReturnList);
                System.assertEquals(productReturnList.size(), 2, 'Product return list is empty');   
                System.assert(tableData.contains('Jasmine Albin'), 'Table data does not contain Jasmine Albin'); 
                Test.stopTest();
        } 
    }
    
    /**
    * @description Method to test getformatedDate success scenerio
    * @author Shristy Kumari | 01-21-2025 
    **/
    @isTest
    public static void testGetformatedDate(){
        User adminUserObj = getUser();
        Datetime inputDate = Datetime.newInstanceGmt(2022, 11, 18, 12, 0, 0); 
        Object firstCheck = 'someValue';  
        Object secondCheck = 'anotherValue'; 
        System.runAs(adminUserObj){
            Test.startTest();
            String formattedDate = PortalReportsHelper.getformatedDate(firstCheck, secondCheck, inputDate);
            System.assertEquals('2022-11-18', formattedDate , 'Assertion failed test getformatedDate success scenerio.');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test getformatedDate and getString methods when first check is null
    * @author Shristy Kumari | 01-21-2025 
    **/
    @isTest
    public static void testNullGetformatedDate(){
        User adminUserObj = getUser();
        Datetime inputDate = Datetime.newInstanceGmt(2022, 11, 18, 12, 0, 0); 
        Object firstCheck = null;  
        Object secondCheck = null; 
        System.runAs(adminUserObj){
            Test.startTest();
            String formattedDateA = PortalReportsHelper.getformatedDate(firstCheck, secondCheck, inputDate);
            String cellData = PortalReportsHelper.getString(firstCheck, secondCheck, inputDate);
            String formattedDateB = PortalReportsHelper.getformatedDate(firstCheck, inputDate);
            System.assertEquals(null, formattedDateA , 'Assertion failed to test getformatedDate.');            
            System.assertEquals(null, formattedDateB , 'Assertion failed to test getformatedDate.');            
            System.assertEquals(null, cellData , 'Assertion failed to test getString.');            
            Test.stopTest();
        }
    }
}