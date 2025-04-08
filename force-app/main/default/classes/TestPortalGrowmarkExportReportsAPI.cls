/**
 * @description       : Test class of PortalGrowmarkExportReportsAPI
 * @author            : Rahul Gupta | 07-08-2022
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  : Suraj Kumar
**/
@IsTest
public class TestPortalGrowmarkExportReportsAPI {
    
    @TestSetup
    static void makeData() {

        // create business information
        genesis__Business_Information__c objDealerBusinessInformation = new genesis__Business_Information__c(
                                                                            genesis__Business_Country__c='India',
                                                                            Approved_Loan_Amount__c=5483528.17,
                                                                            Contract_Loan_Limit__c=10000000,
                                                                            Customised_Individual_Limit__c=250000,
                                                                            Customised_Loan_Limit__c=800000,
                                                                            Remaining_Customised_Limit__c=117984
                                                                        );
        insert objDealerBusinessInformation;

        // create dealer account
        Account objDealerAccount = new Account(
                            Name='Test Dealer',
                            CIF_Number__c = '115282', 
                            BillingCity = 'Kolkata', 
                            BillingState = 'West Bengal',
                            genesis__Business_Information__c = objDealerBusinessInformation.Id
                        );

        insert objDealerAccount;
                    
        // creating user for certified lender
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Certified Lender'];
        User clUser = IntegrationTestInitHelper.createUser(profile.Id);
        Contact clUserContact = [SELECT Id, AccountId FROM Contact WHERE Id = :clUser.ContactId];
        Account clUserAccount = [SELECT Id, Name, RecordType.Name FROM Account WHERE Id = :clUserContact.AccountId];

        clUserAccount.Name = 'Ross Geller';
        clUserAccount.ParentId = objDealerAccount.Id;
        // clUserAccount.RecordType.Name = 'Certified Lender';
        clUserContact.FirstName = 'Ross';
        clUserContact.LastName = 'Geller';

        update clUserAccount;
        update clUserContact;

        clcommon__Reciprocal_Role__c role = new clcommon__Reciprocal_Role__c(Name='Certified Lender');
        Database.insert(role, true);
        clcommon__Relationship__c relationship = 
                        new clcommon__Relationship__c(clcommon__Entity__c=objDealerAccount.Id,
                                                    clcommon__Related_Entity__c=clUserAccount.Id,
                                                    clcommon__Relationship__c=role.Id);
        Database.insert(relationship, true);


        // create legal entity
        clcommon__Legal_Entity__c objEntity= new clcommon__Legal_Entity__c();
        objEntity.Name = 'Individual(s) - Sole Proprietorship';
        objEntity.clcommon__Legal_Entity_Type__c = 'Individual';

        insert objEntity;

        // create borrower
        Account objBorrowerAccount = new Account(name='Rahul Gupta');
        objBorrowerAccount.clcommon__Legal_Entity_Type__c = objEntity.Id;
        // objBorrowerAccount.RecordType.Name = 'Grower';
        insert objBorrowerAccount;
        
        Contact objBorrowerContact = new Contact(FirstName='Rahul', LastName='Gupta');
        objBorrowerContact.AccountId = objBorrowerAccount.Id;

        insert objBorrowerContact;

        // create loan product
        clcommon__CL_Product__c objClProduct = new clcommon__CL_Product__c(clcommon__Product_Name__c = 'Simpli-Fi');
        insert objClProduct;

        // create application
        genesis__Applications__c objApplication = new genesis__Applications__c();
        objApplication.genesis__Status__c = 'ACTIVE';
        objApplication.genesis__CL_Product__c = objClProduct.Id;
        objApplication.genesis__Product_Type__c ='Loan';
        objApplication.genesis__Term__c = 12;
        objApplication.genesis__Interest_Rate__c = 1;
        objApplication.genesis__Loan_Amount__c = 35000;
        Integer month = System.today().month();
        if(month >= 6){
            objApplication.Crop_Year__c = String.valueOf(System.today().addYears(1).year());
        }
        else{
            objApplication.Crop_Year__c = String.valueOf(System.today().year());
        }
        objApplication.Peak_Loan_Volume__c = 15000;
        objApplication.genesis__Maturity_Date__c = Date.today().addYears(1);
        objApplication.Loan_Id__c = '13900';
        objApplication.genesis__Loan_Number__c = '3023456';
        objApplication.genesis__Account__c = objBorrowerAccount.Id;
        objApplication.genesis__Contact__c = objBorrowerContact.Id;
        objApplication.Certified_Lender__c = clUserAccount.Id;
        objApplication.Dealer_Name__c = objDealerAccount.Id;
        
        insert objApplication;

        // create borrower party type
        clcommon__Party_Type__c objBorrowerPartyType = new clcommon__Party_Type__c(Name = 'BORROWER');
        insert objBorrowerPartyType;

        // create certified lender party
        clcommon__Party_Type__c objCertifiedLenderPartyType = new clcommon__Party_Type__c(Name = 'CERTIFIED LENDER');
        insert objCertifiedLenderPartyType;

        // create certified lender party
        clcommon__Party_Type__c objDealerPartyType = new clcommon__Party_Type__c(Name = 'DEALER');
        insert objDealerPartyType;

        // create borrower party
        clcommon__Party__c objBorrowerParty = new clcommon__Party__c();
        objBorrowerParty.clcommon__Account__c = objBorrowerAccount.Id;
        objBorrowerParty.clcommon__Contact__c = objBorrowerContact.Id;
        objBorrowerParty.clcommon__Type__c = objBorrowerPartyType.Id;
        objBorrowerParty.genesis__Application__c = objApplication.Id;
        insert objBorrowerParty;

        // create certified lender party
        clcommon__Party__c objCertifiedLenderParty = new clcommon__Party__c();
        objCertifiedLenderParty.clcommon__Account__c = clUserAccount.Id;
        objCertifiedLenderParty.clcommon__Contact__c = clUserContact.Id;
        objCertifiedLenderParty.clcommon__Type__c = objCertifiedLenderPartyType.Id;
        objCertifiedLenderParty.genesis__Application__c = objApplication.Id;
        insert objCertifiedLenderParty;

        // create dealer party
        clcommon__Party__c objDealerParty = new clcommon__Party__c();
        objDealerParty.clcommon__Account__c = objDealerAccount.Id;
        objDealerParty.clcommon__Type__c = objDealerPartyType.Id;
        objDealerParty.genesis__Application__c = objApplication.Id;
        insert objDealerParty;

        // create rare card and pricing detail
        genesis__Rate_Card_Setup_Header__c objRateCardSetupHeader = new genesis__Rate_Card_Setup_Header__c();
        objRateCardSetupHeader.genesis__Enabled_Flag__c = true;
        objRateCardSetupHeader.Crop_Year__c = '2023';
        objRateCardSetupHeader.genesis__Start_Date__c = Date.newInstance(2022, 07, 01);
        objRateCardSetupHeader.genesis__End_Date__c = Date.newInstance(2023, 09, 15);
        objRateCardSetupHeader.genesis__Transaction_Date__c = Date.newInstance(2022, 10, 15);

        insert objRateCardSetupHeader;

        genesis__Rate_Card_Setup_Detail__c objRateCardSetupDetail = new genesis__Rate_Card_Setup_Detail__c();
        objRateCardSetupDetail.genesis__Rate_Card_Setup_Header__c = objRateCardSetupHeader.Id;
        objRateCardSetupDetail.Start_Date__c = Date.newInstance(2022, 07, 01);
        objRateCardSetupDetail.End_Date__c = Date.newInstance(2022, 9, 30);
        objRateCardSetupDetail.genesis__Interest_Rate__c = 7.7;
        objRateCardSetupDetail.Participation_Percentage_Dealer__c = 0.2;
        objRateCardSetupDetail.Participation_Percentage_Dealer_Subsidy__c = 0;

        insert objRateCardSetupDetail;

        genesis__Application_Pricing_Detail__c objApplicationPricingDetail = new genesis__Application_Pricing_Detail__c();
        objApplicationPricingDetail.genesis__Enabled_Flag__c = true;
        objApplicationPricingDetail.Loan_Number__c = objApplication.genesis__Loan_Number__c + '-A';
        objApplicationPricingDetail.genesis__Rate_Card_Setup_Detail__c = objRateCardSetupDetail.Id;
        objApplicationPricingDetail.genesis__Application__c = objApplication.Id;

        insert objApplicationPricingDetail;

        //Create Application Fee Payment record -- added
        genesis__Application_Fee_Payment__c applicationFeePaymentPremium = new genesis__Application_Fee_Payment__c();
        applicationFeePaymentPremium.genesis__Application__c = objApplication.Id;
        applicationFeePaymentPremium.Pricing_Detail__c = objApplicationPricingDetail.Id;
        applicationFeePaymentPremium.Year__c = System.today().year();
        applicationFeePaymentPremium.Month__c = System.today().month();
        applicationFeePaymentPremium.Record_Type__c = 'PARTICIPANT DAILY';
        insert applicationFeePaymentPremium;
        //-----added

        objRateCardSetupDetail = new genesis__Rate_Card_Setup_Detail__c();
        objRateCardSetupDetail.genesis__Rate_Card_Setup_Header__c = objRateCardSetupHeader.Id;
        objRateCardSetupDetail.Start_Date__c = Date.newInstance(2022, 10, 01);
        objRateCardSetupDetail.End_Date__c = Date.newInstance(2022, 12, 31);
        objRateCardSetupDetail.genesis__Interest_Rate__c = 2.5;
        objRateCardSetupDetail.Participation_Percentage_Dealer__c = 0;
        objRateCardSetupDetail.Participation_Percentage_Dealer_Subsidy__c = 3;

        insert objRateCardSetupDetail;

        objApplicationPricingDetail = new genesis__Application_Pricing_Detail__c();
        objApplicationPricingDetail.genesis__Enabled_Flag__c = false;
        objApplicationPricingDetail.Loan_Number__c = objApplication.genesis__Loan_Number__c + '-A';
        objApplicationPricingDetail.genesis__Rate_Card_Setup_Detail__c = objRateCardSetupDetail.Id;
        objApplicationPricingDetail.genesis__Application__c = objApplication.Id;

        insert objApplicationPricingDetail;

        //Create Application Fee Payment record
        genesis__Application_Fee_Payment__c applicationFeePaymentSubsidy = new genesis__Application_Fee_Payment__c();
        applicationFeePaymentSubsidy.genesis__Application__c = objApplication.Id;
        applicationFeePaymentSubsidy.Pricing_Detail__c = objApplicationPricingDetail.Id;
        applicationFeePaymentSubsidy.Year__c = System.today().year();
        applicationFeePaymentSubsidy.Month__c = System.today().month();
        applicationFeePaymentSubsidy.Record_Type__c = 'PARTICIPANT DAILY';
        insert applicationFeePaymentSubsidy;
        //-----added

        objRateCardSetupDetail = new genesis__Rate_Card_Setup_Detail__c();
        objRateCardSetupDetail.genesis__Rate_Card_Setup_Header__c = objRateCardSetupHeader.Id;
        objRateCardSetupDetail.Start_Date__c = Date.newInstance(2022, 07, 01);
        objRateCardSetupDetail.End_Date__c = Date.newInstance(2022, 9, 30);
        objRateCardSetupDetail.genesis__Interest_Rate__c = 2.5;
        objRateCardSetupDetail.Participation_Percentage_Dealer__c = 0;
        objRateCardSetupDetail.Participation_Percentage_Dealer_Subsidy__c = 3;

        insert objRateCardSetupDetail;


        objApplicationPricingDetail = new genesis__Application_Pricing_Detail__c();
        objApplicationPricingDetail.genesis__Enabled_Flag__c = true;
        objApplicationPricingDetail.Loan_Number__c = objApplication.genesis__Loan_Number__c + '-B';
        objApplicationPricingDetail.genesis__Rate_Card_Setup_Detail__c = objRateCardSetupDetail.Id;
        objApplicationPricingDetail.genesis__Application__c = objApplication.Id;


        insert objApplicationPricingDetail;

        //Create Application Fee Payment record
        genesis__Application_Fee_Payment__c applicationFeePaymentAtiveLoanDaily = new genesis__Application_Fee_Payment__c();
        applicationFeePaymentAtiveLoanDaily.genesis__Application__c = objApplication.Id;
        applicationFeePaymentAtiveLoanDaily.Pricing_Detail__c = objApplicationPricingDetail.Id;
        applicationFeePaymentAtiveLoanDaily.Year__c = 2023;
        applicationFeePaymentAtiveLoanDaily.Month__c = 10;
        applicationFeePaymentAtiveLoanDaily.Record_Type__c = 'ACTIVE LOAN DAILY';
        insert applicationFeePaymentAtiveLoanDaily;
        //-----added

        //Create Application Fee Payment record
        genesis__Application_Fee_Payment__c applicationFeePaymentAtiveLoanDaily2 = new genesis__Application_Fee_Payment__c();
        applicationFeePaymentAtiveLoanDaily2.genesis__Application__c = objApplication.Id;
        applicationFeePaymentAtiveLoanDaily2.Pricing_Detail__c = objApplicationPricingDetail.Id;
        applicationFeePaymentAtiveLoanDaily2.Year__c = 2023;
        applicationFeePaymentAtiveLoanDaily2.Month__c = 0;
        applicationFeePaymentAtiveLoanDaily2.Record_Type__c = 'ACTIVE LOAN DAILY';
        applicationFeePaymentAtiveLoanDaily2.Interest_Paid__c = 10;
        insert applicationFeePaymentAtiveLoanDaily2;
        //-----added

        // ////-------------------------------------------------------------------------------------------------
        // //Record for Premium Accrual Report
        // objRateCardSetupDetail = new genesis__Rate_Card_Setup_Detail__c();
        // objRateCardSetupDetail.genesis__Rate_Card_Setup_Header__c = objRateCardSetupHeader.Id;
        // objRateCardSetupDetail.Start_Date__c = Date.newInstance(2022, 07, 01);
        // objRateCardSetupDetail.End_Date__c = Date.newInstance(2022, 9, 30);
        // objRateCardSetupDetail.genesis__Interest_Rate__c = 2.5;
        // objRateCardSetupDetail.Participation_Percentage_Dealer__c = 3;
        // objRateCardSetupDetail.Participation_Percentage_Dealer_Subsidy__c = 0;

        // insert objRateCardSetupDetail;

        // objApplicationPricingDetail = new genesis__Application_Pricing_Detail__c();
        // objApplicationPricingDetail.genesis__Enabled_Flag__c = true;
        // objApplicationPricingDetail.Loan_Number__c = objApplication.genesis__Loan_Number__c + '-A';
        // objApplicationPricingDetail.genesis__Rate_Card_Setup_Detail__c = objRateCardSetupDetail.Id;
        // objApplicationPricingDetail.genesis__Application__c = objApplication.Id;

        // insert objApplicationPricingDetail;

        // //Create Application Fee Payment record
        // genesis__Application_Fee_Payment__c applicationFeePaymentPremium = new genesis__Application_Fee_Payment__c();
        // applicationFeePaymentPremium.genesis__Application__c = objApplication.Id;
        // applicationFeePaymentPremium.Pricing_Detail__c = objApplicationPricingDetail.Id;
        // applicationFeePaymentPremium.Year__c = System.today().year();
        // applicationFeePaymentPremium.Month__c = System.today().month();
        // applicationFeePaymentPremium.Record_Type__c = 'PARTICIPANT DAILY';
        // insert applicationFeePaymentPremium;

        // //Record for Subsidy Accrual Report
        // objRateCardSetupDetail = new genesis__Rate_Card_Setup_Detail__c();
        // objRateCardSetupDetail.genesis__Rate_Card_Setup_Header__c = objRateCardSetupHeader.Id;
        // objRateCardSetupDetail.Start_Date__c = Date.newInstance(2022, 07, 01);
        // objRateCardSetupDetail.End_Date__c = Date.newInstance(2022, 9, 30);
        // objRateCardSetupDetail.genesis__Interest_Rate__c = 2.5;
        // objRateCardSetupDetail.Participation_Percentage_Dealer__c = 0;
        // objRateCardSetupDetail.Participation_Percentage_Dealer_Subsidy__c = 3;

        // insert objRateCardSetupDetail;

        // objApplicationPricingDetail = new genesis__Application_Pricing_Detail__c();
        // objApplicationPricingDetail.genesis__Enabled_Flag__c = true;
        // objApplicationPricingDetail.Loan_Number__c = objApplication.genesis__Loan_Number__c + '-A';
        // objApplicationPricingDetail.genesis__Rate_Card_Setup_Detail__c = objRateCardSetupDetail.Id;
        // objApplicationPricingDetail.genesis__Application__c = objApplication.Id;

        // insert objApplicationPricingDetail;

        // //Create Application Fee Payment record
        // genesis__Application_Fee_Payment__c applicationFeePaymentSubsidy = new genesis__Application_Fee_Payment__c();
        // applicationFeePaymentSubsidy.genesis__Application__c = objApplication.Id;
        // applicationFeePaymentSubsidy.Pricing_Detail__c = objApplicationPricingDetail.Id;
        // applicationFeePaymentSubsidy.Year__c = System.today().year();
        // applicationFeePaymentSubsidy.Month__c = System.today().month();
        // applicationFeePaymentSubsidy.Record_Type__c = 'PARTICIPANT DAILY';
        // insert applicationFeePaymentSubsidy;
        // ////-------------------------------------------------------------------------------------------------

        // create payment mode
        clcommon__Payment_Mode__c objAchPaymentMode = new clcommon__Payment_Mode__c();
        objAchPaymentMode.Name = 'ACH';

        insert objAchPaymentMode;

        clcommon__Payment_Mode__c objDraftPaymentMode = new clcommon__Payment_Mode__c();
        objDraftPaymentMode.Name = 'DRAFT';

        insert objDraftPaymentMode;

        // create ach funding transaction
        clcommon__Funding_Transactions_Properties__c objAchFundingTransactionProperties = new clcommon__Funding_Transactions_Properties__c();
        objAchFundingTransactionProperties.Name = 'ACH - 07-09-2022';

        insert objAchFundingTransactionProperties;
        

        genesis__Funding_Transaction__c objAchFundingTransaction = new genesis__Funding_Transaction__c();
        objAchFundingTransaction.genesis__Application__c = objApplication.Id;
        objAchFundingTransaction.Grower_Name__c = 'Test Grower 1';
        objAchFundingTransaction.Pricing_Detail__c = objApplicationPricingDetail.Id;
        objAchFundingTransaction.genesis__Amount__c = 1000;
        objAchFundingTransaction.genesis__Payment_Mode__c = objAchPaymentMode.Id;
        objAchFundingTransaction.Batch__c = objAchFundingTransactionProperties.Id;

        insert objAchFundingTransaction;

        // create draft funding transaction
        genesis__Funding_Transaction__c objDraftFundingTransaction = new genesis__Funding_Transaction__c();
        objDraftFundingTransaction.genesis__Application__c = objApplication.Id;
        objDraftFundingTransaction.Pricing_Detail__c = objApplicationPricingDetail.Id;
        objDraftFundingTransaction.genesis__Amount__c = 1000;
        objDraftFundingTransaction.genesis__Cleared__c = true;
        objDraftFundingTransaction.Grower_Name__c = 'Test Grower 1';
        objDraftFundingTransaction.genesis__Payment_Mode__c = objDraftPaymentMode.Id;
        // objAchFundingTransaction.Batch__c = objAchFundingTransactionProperties.Id;

        insert objDraftFundingTransaction;


        // create application
        objApplication = new genesis__Applications__c();
        objApplication.genesis__Status__c = 'ACTIVE';
        objApplication.genesis__CL_Product__c = objClProduct.Id;
        objApplication.genesis__Product_Type__c ='Loan';
        objApplication.genesis__Term__c = 12;
        objApplication.genesis__Interest_Rate__c = 1;
        objApplication.genesis__Loan_Amount__c = 40000;
        
        if(month >= 6){
            objApplication.Crop_Year__c = String.valueOf(System.today().year());
        }
        else{
            objApplication.Crop_Year__c = String.valueOf(System.today().year() - 1);
        }
        objApplication.Peak_Loan_Volume__c = 15000;
        objApplication.genesis__Maturity_Date__c = Date.today().addYears(1);
        objApplication.Loan_Id__c = '13900';
        objApplication.genesis__Loan_Number__c = '3023457';
        objApplication.genesis__Account__c = objBorrowerAccount.Id;
        objApplication.genesis__Contact__c = objBorrowerContact.Id;
        objApplication.Certified_Lender__c = clUserAccount.Id;
        objApplication.Dealer_Name__c = objDealerAccount.Id;
        
        insert objApplication;

        // create borrower party type
        objBorrowerPartyType = new clcommon__Party_Type__c(Name = 'BORROWER');
        insert objBorrowerPartyType;

        // create certified lender party
        objCertifiedLenderPartyType = new clcommon__Party_Type__c(Name = 'CERTIFIED LENDER');
        insert objCertifiedLenderPartyType;

        // create certified lender party
        objDealerPartyType = new clcommon__Party_Type__c(Name = 'DEALER');
        insert objDealerPartyType;

        // create borrower party
        objBorrowerParty = new clcommon__Party__c();
        objBorrowerParty.clcommon__Account__c = objBorrowerAccount.Id;
        objBorrowerParty.clcommon__Contact__c = objBorrowerContact.Id;
        objBorrowerParty.clcommon__Type__c = objBorrowerPartyType.Id;
        objBorrowerParty.genesis__Application__c = objApplication.Id;
        insert objBorrowerParty;

        // create certified lender party
        objCertifiedLenderParty = new clcommon__Party__c();
        objCertifiedLenderParty.clcommon__Account__c = clUserAccount.Id;
        objCertifiedLenderParty.clcommon__Contact__c = clUserContact.Id;
        objCertifiedLenderParty.clcommon__Type__c = objCertifiedLenderPartyType.Id;
        objCertifiedLenderParty.genesis__Application__c = objApplication.Id;
        insert objCertifiedLenderParty;

        // create dealer party
        objDealerParty = new clcommon__Party__c();
        objDealerParty.clcommon__Account__c = objDealerAccount.Id;
        objDealerParty.clcommon__Type__c = objDealerPartyType.Id;
        objDealerParty.genesis__Application__c = objApplication.Id;
        insert objDealerParty;
        
    }

    /**
    * @description : return the certified lender user
    * @author Suraj Kumar | 03-11-2024 
    * @return User 
    **/
    private static User getCertifiedLenderUser() {
       
        List<User> objUserList = [SELECT Id 
                                    FROM User 
                                    WHERE AccountId IN (
                                        SELECT Id 
                                        FROM Account 
                                        WHERE Name = 'Ross Geller')];
                                    
        if (objUserList.size() == 1) {
            return objUserList[0];
        } 
        
        return null;
    }

    @IsTest
    public static void testCase1() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP Active Loan Report');
        Integer month = System.today().month();

        if(month >= 6){
            
            request.put('filter', String.valueOf(System.today().addYears(1).year()));
        }
        else{
            
            request.put('filter', String.valueOf(String.valueOf(System.today().year())));
        }
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase2() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP Active Loan Report');
        Integer month = System.today().month();

        if(month >= 6){
            
            request.put('filter', String.valueOf(System.today().addYears(1).year()));
        }
        else{
            
            request.put('filter', String.valueOf(String.valueOf(System.today().year())));
        }
        request.put('exportType', 'pdf');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase3() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'Rate Change Notification Report');
        // request.put('reportFilter', 'Rate Change Notification Report');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase4() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'Rate Change Notification Report');
        // request.put('reportFilter', 'Rate Change Notification Report');
        request.put('exportType', 'pdf');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase5() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'Online Users Report');
        // request.put('reportFilter', 'Online Users Report');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase6() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'Online Users Report');
        // request.put('reportFilter', 'Online Users Report');
        request.put('exportType', 'pdf');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase7() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'Current Crop Year Loans Report');
        // request.put('reportFilter', 'Current Crop Year Loans Report');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase8() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'Current Crop Year Loans Report');
        // request.put('reportFilter', 'Current Crop Year Loans Report');
        request.put('exportType', 'pdf');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase9() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'Previous Crop Year Loans Report');
        // request.put('reportFilter', 'Previous Crop Year Loans Report');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase10() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'Previous Crop Year Loans Report');
        // request.put('reportFilter', 'Previous Crop Year Loans Report');
        request.put('exportType', 'pdf');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase11() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'Loan Account Report');
  
        Integer month = System.today().month();

        if(month >= 6){
            
            request.put('filter', String.valueOf(System.today().addYears(1).year()));
        }
        else{
            
            request.put('filter', String.valueOf(String.valueOf(System.today().year())));
        }
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase12() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'Loan Account Report');

        Integer month = System.today().month();

        if(month >= 6){
            
            request.put('filter', String.valueOf(System.today().addYears(1).year()));
        }
        else{
           
            request.put('filter', String.valueOf(String.valueOf(System.today().year())));
        }
        request.put('exportType', 'pdf');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase13() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP Active Loan Report');

        Integer month = System.today().month();

        if(month >= 6){
            
            request.put('filter', String.valueOf(System.today().addYears(1).year()));
        }
        else{
            
            request.put('filter', String.valueOf(String.valueOf(System.today().year())));
        }
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase14() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP Active Loan Report');
      
        Integer month = System.today().month();

        if(month >= 6){
            request.put('filter', String.valueOf(System.today().addYears(1).year()));
        }
        else{
            
            request.put('filter', String.valueOf(String.valueOf(System.today().year())));
        }
        request.put('exportType', 'pdf');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase15() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP End Of Month Active Loan Report');
        // request.put('reportFilter', 'IFP End Of Month Active Loan Report');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase16() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP End Of Month Active Loan Report');
        // request.put('reportFilter', 'IFP End Of Month Active Loan Report');
        request.put('exportType', 'pdf');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase17() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP End Of Year Report');
        // request.put('reportFilter', 'IFP End Of Year Report');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase18() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP End Of Year Report');
        // request.put('reportFilter', 'IFP End Of Year Report');
        request.put('exportType', 'pdf');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase19() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP Subsidy Accrual Report');
        // request.put('reportFilter', 'IFP Subsidy Accrual Report');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase20() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP Subsidy Accrual Report');
        // request.put('reportFilter', 'IFP Subsidy Accrual Report');
        request.put('exportType', 'pdf');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase21() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP Premium Accrual Report');
        // request.put('reportFilter', 'IFP Premium Accrual Report');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase22() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP Premium Accrual Report');
        // request.put('reportFilter', 'IFP Premium Accrual Report');
        request.put('exportType', 'pdf');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase23() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'DRAFT History Report');
        // request.put('reportFilter', 'DRAFT History Report');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase24() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'DRAFT History Report');
        // request.put('reportFilter', 'DRAFT History Report');
        request.put('exportType', 'pdf');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase25() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        clcommon__Funding_Transactions_Properties__c objBatch = [SELECT Id 
                                                                FROM clcommon__Funding_Transactions_Properties__c 
                                                                WHERE Name = 'ACH - 07-09-2022'];

        request.put('reportType', 'ACH Batch History Report');
        request.put('batchId', objBatch.Id);
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase26() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        clcommon__Funding_Transactions_Properties__c objBatch = [SELECT Id 
                                                                FROM clcommon__Funding_Transactions_Properties__c 
                                                                WHERE Name = 'ACH - 07-09-2022'];

        request.put('reportType', 'ACH Batch History Report');
        request.put('batchId', objBatch.Id);
        request.put('exportType', 'pdf');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    

    @IsTest
    public static void testCase27() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase28() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP End Of Month Active Loan Report');
        request.put('filter', 'October 2023');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }
    @IsTest
    public static void testCase29() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP End Of Month Active Loan Report');
        request.put('filter', 'October 2023');
        request.put('exportType', 'pdf');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }

    @IsTest
    public static void testCase30() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP End Of Year Report');
        request.put('filter', '2023');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }
    @IsTest
    public static void testCase31() {
        User objCertifiedLenderUser = getCertifiedLenderUser();

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP End Of Year Report');
        request.put('filter', '2023');
        request.put('exportType', 'pdf');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalGrowmarkExportReportsAPI portalReportsApi = new PortalGrowmarkExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);

                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed'); 
    
                Test.stopTest();
            }
        }
    }
    
}