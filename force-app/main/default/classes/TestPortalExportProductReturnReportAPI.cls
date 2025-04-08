/**
 * @description       : 
 * @author            : Tuhin Bhunia
 * @group             : 
 * @last modified on  : 10-25-2023
 * @last modified by  : Tuhin Bhunia
**/
@IsTest
public without sharing class TestPortalExportProductReturnReportAPI {
    
    @TestSetup
    static void makeData(){
       // Creating Legal Entity
       clcommon__Legal_Entity__c individualEntityObj = TestClassHelper.createLegalEntity(PortalConstants.SOLE_PROP_ENTITY);
       Database.Insert(individualEntityObj, true);

       // Creating Party Types
       clcommon__Party_Type__c borrowerPartyTypeObj = TestClassHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);
       Database.Insert(borrowerPartyTypeObj);

       clcommon__Party_Type__c dealerPartyTypeObj = TestClassHelper.createPartyType(PortalConstants.DEALER_PARTY_NAME);
       Database.Insert(dealerPartyTypeObj, true);

       clcommon__Party_Type__c clPartyTypeObj = TestClassHelper.createPartyType(PortalConstants.CERTIFIED_LENDER);
       Database.Insert(clPartyTypeObj, true);

       clcommon__Party_Type__c saPartyTypeObj = TestClassHelper.createPartyType(PortalConstants.SALES_AGENT_PARTY_NAME);
       Database.Insert(saPartyTypeObj, true);

       // Creating CL Product for Application
       clcommon__CL_Product__c clProductObj = TestClassHelper.createCLProductForApplication();
       Database.Insert(clProductObj, true);

       // Creating CL Purpose for Application
       clcommon__CL_Purpose__c clPurposeObj = TestClassHelper.createCLPurposeForApplication();
       Database.Insert(clPurposeObj, true);

       // Creating business information
       genesis__Business_Information__c dealerBusinessInfoObj = TestClassHelper.createBusinessInfoForDealer();
       Database.Insert(dealerBusinessInfoObj, true);

       genesis__Business_Information__c borrowerBusinessInfoObj = TestClassHelper.createBusinessInfoForBorrower();
       Database.Insert(borrowerBusinessInfoObj, true);

       // Creating Accounts
       Account dealerAccountObj = TestClassHelper.createDealerAccount(dealerBusinessInfoObj.Id);
       Database.Insert(dealerAccountObj, true);

       Account clAccountObj = TestClassHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
       Database.Insert(clAccountObj, true);

       Account saAccountObj = TestClassHelper.createSalesAgentAccount(null, dealerAccountObj.Id);
       Database.Insert(saAccountObj, true);

       Account borrowerAccountObj = TestClassHelper.createSolePropAccount(individualEntityObj,dealerBusinessInfoObj.Id);
       Database.Insert(borrowerAccountObj, true);

       // Creating Contacts
       Contact clContactObj = TestClassHelper.createCLContact(clAccountObj.Id);
       Database.Insert(clContactObj, true);

       Contact saContactObj = TestClassHelper.createSalesAgentContact(saAccountObj.Id);
       Database.Insert(saContactObj, true);

       Contact borrowerContactObj = TestClassHelper.createBorrowerContact(borrowerAccountObj.Id);    
       Database.Insert(borrowerContactObj, true);

       // Creating Application
       Map<String,Id> applicationDataMap = new Map<String,Id>{
           'dealerAccountId'=> dealerAccountObj.Id,
           'clProductId'=> clProductObj.Id,
           'clPurposeId'=> clPurposeObj.Id,
           'borrowerAccountId'=> borrowerAccountObj.Id,
           'borrowerContactId'=> borrowerContactObj.Id,
           'clAccountId'=> clAccountObj.Id
       };
       genesis__Applications__c applicationObj = TestClassHelper.createCurrCropYearApplication(applicationDataMap);
       applicationObj.Sales_Agent__c = saAccountObj.Id;
       Database.Insert(applicationObj);

       //Creating Parties

           // Creating Dealer Party
           Map<String,Id> dealerPartyMapData = new Map<String,Id>{
               'accountId'=> dealerAccountObj.Id,
               'partyTypeId'=> dealerPartyTypeObj.Id,
               'applicationId'=> applicationObj.Id
           };
           clcommon__Party__c dealerPartyObj = TestClassHelper.createParty(dealerPartyMapData);
           Database.Insert(dealerPartyObj, true);

           // Creating CL Party
           Map<String,Id> clPartyMapData = new Map<String,Id>{
               'accountId'=> clAccountObj.Id,
               'contactId'=> clContactObj.Id,
               'partyTypeId'=> clPartyTypeObj.Id,
               'applicationId'=> applicationObj.Id
           };
           clcommon__Party__c clPartyObj = TestClassHelper.createParty(clPartyMapData);
           Database.Insert(clPartyObj, true);

           // Creating SA Party
           Map<String,Id> saPartyMapData = new Map<String,Id>{
               'accountId'=> saAccountObj.Id,
               'contactId'=> saContactObj.Id,
               'partyTypeId'=> saPartyTypeObj.Id,
               'applicationId'=> applicationObj.Id
           };
           clcommon__Party__c saPartyObj = TestClassHelper.createParty(saPartyMapData);
           Database.Insert(saPartyObj, true);

           // Creating Borrower Party
           Map<String,Id> borrowerPartyMapData = new Map<String,Id>{
               'accountId'=> borrowerAccountObj.Id,
               'contactId'=> borrowerContactObj.Id,
               'partyTypeId'=> borrowerPartyTypeObj.Id,
               'applicationId'=> applicationObj.Id
           };
           clcommon__Party__c borrowerPartyObj = TestClassHelper.createParty(borrowerPartyMapData);
           Database.Insert(borrowerPartyObj, true);

       // Creating Reciprocal Roles
       clcommon__Reciprocal_Role__c clRoleObj = TestClassHelper.createReciprocalRole('Certified Lender');
       Database.Insert(clRoleObj, true);
       clcommon__Reciprocal_Role__c saRoleObj = TestClassHelper.createReciprocalRole('Sales Agent');
       Database.Insert(saRoleObj, true);
       
       // Creating Relationships
       clcommon__Relationship__c clDealerRealtionshipObj = TestClassHelper.createCLDealerRelationship(clRoleObj, 
                                                                                                       dealerAccountObj.Id, 
                                                                                                       clAccountObj.Id);
       Database.Insert(clDealerRealtionshipObj, true);

       // clcommon__Relationship__c saDealerRealtionshipObj = TestClassHelper.createSalesAgentDealerRelationship(saRoleObj, 
       //                                                                                                         dealerAccountObj.Id, 
       //                                                                                                         saAccountObj.Id);
       // Database.Insert(saDealerRealtionshipObj, true);

       // Creating User
       User clUserObj = TestClassHelper.createCLUser(clContactObj.Id);
       Database.Insert(clUserObj, true);

       // create rate card and pricing detail

           // Creating My Program
       genesis__Rate_Card_Setup_Header__c rateCardSetupHeaderObj = TestClassHelper.createCurrYearRateCardHeader(dealerAccountObj);
       Database.Insert(rateCardSetupHeaderObj, true);

           // Creating Child loans
       genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailObjOne = TestClassHelper.createRateCardSetupDetailOne(rateCardSetupHeaderObj);
       rateCardSetupDetailObjOne.Description__c = 'Seeds';
       Database.Insert(rateCardSetupDetailObjOne, true);
       genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailObjTwo = TestClassHelper.createRateCardSetupDetailTwo(rateCardSetupHeaderObj);
       rateCardSetupDetailObjTwo.Description__c = 'Equipments';
       Database.Insert(rateCardSetupDetailObjTwo, true);

           // Creating Application Pricing Details
       genesis__Application_Pricing_Detail__c appPricingDetailObjOne = TestClassHelper.createEnabledPricingDetail(applicationObj, rateCardSetupDetailObjOne.Id);
       Database.Insert(appPricingDetailObjOne, true);
       genesis__Application_Pricing_Detail__c appPricingDetailObjTwo = TestClassHelper.createEnabledPricingDetail(applicationObj, rateCardSetupDetailObjTwo.Id);
       Database.Insert(appPricingDetailObjTwo, true);
       
       // Creating Payment Mode
       clcommon__Payment_Mode__c achPaymentModeObj = TestClassHelper.createPaymentMode().get(PortalConstants.ACH);
       Database.Insert(achPaymentModeObj, true);

       clcommon__Payment_Mode__c productReturnPayModeObj = TestClassHelper.createPaymentMode().get(PortalConstants.PRODUCT_RETURN);
       Database.Insert(productReturnPayModeObj, true);

       // Creating Funding Transaction Properties
       clcommon__Funding_Transactions_Properties__c achFundTransacPropObj = TestClassHelper.createFundingTransactionProperty('ACH - 07-09-2022');
       Database.insert(achFundTransacPropObj, true);

        // Creating ACH Funding Transaction
       Map<String, Id> achDataMap = new Map<String, Id>{
           'applicationId'=> applicationObj.Id,
           'pricingDetailId'=> appPricingDetailObjOne.Id,
           'paymentModeId'=> achPaymentModeObj.Id,
           'fundingTransactionPropertyId'=> achFundTransacPropObj.Id
       };
       genesis__Funding_Transaction__c achFundingTransactionObj = TestClassHelper.createACHFundingTransaction(achDataMap);
       achFundingTransactionObj.genesis__Amount__c = 15000;
       Database.insert(achFundingTransactionObj, true);

        // Creating Product Return Funding Transaction
       Map<String, Id> productReturnDataMap = new Map<String, Id>{
           'applicationId'=> applicationObj.Id,
           'pricingDetailId'=> appPricingDetailObjOne.Id,
           'paymentModeId'=> productReturnPayModeObj.Id
       };
       genesis__Funding_Transaction__c prodReturnFundTransacObj = TestClassHelper.createProductReturnWithoutPropertiesBatch(productReturnDataMap);
       prodReturnFundTransacObj.genesis__Reference__c = 'Seeds';
       Database.insert(prodReturnFundTransacObj, true);
    }

    // Success Scenario 1
    @isTest
    private static void exportingProductReturnsWithoutFilterCSV(){
        User clUser;
        PortalExportProductReturnReportAPI apiObj = new PortalExportProductReturnReportAPI();
        Map<String, Object> requestMap = new Map<String, Object>{
            PortalConstants.KEY_REPORT_TYPE => PortalConstants.PRODUCT_RETURN_SUMMERY_REPORT,
            PortalConstants.KEY_EXPORT_TYPE => 'csv'
        };

        // Fetching CL user
        List<User> clUserList = [SELECT Id, Name, Email, ProfileId, UserName
                                FROM USER 
                                WHERE UserName = 'ross.geller@yopmail.com'
                                LIMIT 1];
        for(User user : clUserList){
            clUser = user;
        }

        System.runAs(clUser){
            Test.startTest();
            clcommon.Response response = apiObj.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    // Success Scenario 2
    @isTest
    private static void exportingProductReturnsWithoutFilterPDF(){
        User clUser;
        PortalExportProductReturnReportAPI apiObj = new PortalExportProductReturnReportAPI();
        Map<String, Object> requestMap = new Map<String, Object>{
            PortalConstants.KEY_REPORT_TYPE => PortalConstants.PRODUCT_RETURN_SUMMERY_REPORT,
            PortalConstants.KEY_EXPORT_TYPE => 'pdf'
        };

        // Fetching CL user
        List<User> clUserList = [SELECT Id, Name, Email, ProfileId, UserName
                                FROM USER 
                                WHERE UserName = 'ross.geller@yopmail.com'
                                LIMIT 1];
        for(User user : clUserList){
            clUser = user;
        }

        System.runAs(clUser){
            Test.startTest();
            clcommon.Response response = apiObj.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    // Success Scenario 3
    @isTest
    private static void exportingProductReturnsForSelectedDate(){
        User clUser;
        PortalExportProductReturnReportAPI apiObj = new PortalExportProductReturnReportAPI();
        Map<String, Object> requestMap = new Map<String, Object>{
            PortalConstants.KEY_REPORT_TYPE => PortalConstants.PRODUCT_RETURN_SUMMERY_REPORT,
            PortalConstants.KEY_EXPORT_TYPE => 'csv',
            PortalConstants.KEY_REPORT_FILTER => String.valueOf(Date.today())
        };

        // Fetching CL user
        List<User> clUserList = [SELECT Id, Name, Email, ProfileId, UserName
                                FROM USER 
                                WHERE UserName = 'ross.geller@yopmail.com'
                                LIMIT 1];
        for(User user : clUserList){
            clUser = user;
        }

        System.runAs(clUser){
            Test.startTest();
            clcommon.Response response = apiObj.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    // Success Scenario 4
    @isTest
    private static void exportingProductReturnsWithDateRange(){
        User clUser;
        PortalExportProductReturnReportAPI apiObj = new PortalExportProductReturnReportAPI();
        Map<String, Object> requestMap = new Map<String, Object>{
            PortalConstants.KEY_REPORT_TYPE => PortalConstants.PRODUCT_RETURN_SUMMERY_REPORT,
            PortalConstants.KEY_EXPORT_TYPE => 'csv',
            PortalConstants.KEY_FROM_DATE => String.valueOf(Date.today() - 5),
            PortalConstants.KEY_TO_DATE => String.valueOf(Date.today())
        };

        // Fetching CL user
        List<User> clUserList = [SELECT Id, Name, Email, ProfileId, UserName
                                FROM USER 
                                WHERE UserName = 'ross.geller@yopmail.com'
                                LIMIT 1];
        for(User user : clUserList){
            clUser = user;
        }

        System.runAs(clUser){
            Test.startTest();
            clcommon.Response response = apiObj.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    // Success Scenario 4
    @isTest
    private static void exportingProductReturnsWithSearchFilter(){
        User clUser;
        PortalExportProductReturnReportAPI apiObj = new PortalExportProductReturnReportAPI();
        Map<String, Object> requestMap = new Map<String, Object>{
            PortalConstants.KEY_REPORT_TYPE => PortalConstants.PRODUCT_RETURN_SUMMERY_REPORT,
            PortalConstants.KEY_EXPORT_TYPE => 'csv',
            PortalConstants.KEY_SEARCH_FILTER => 'Jasmin'
        };

        // Fetching CL user
        List<User> clUserList = [SELECT Id, Name, Email, ProfileId, UserName
                                FROM USER 
                                WHERE UserName = 'ross.geller@yopmail.com'
                                LIMIT 1];
        for(User user : clUserList){
            clUser = user;
        }

        System.runAs(clUser){
            Test.startTest();
            clcommon.Response response = apiObj.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    //Exception Scenario 1 --> covers no data to export exception
    @isTest
    private static void noDataToExport(){
        User clUser;
        PortalExportProductReturnReportAPI apiObj = new PortalExportProductReturnReportAPI();
        Map<String, Object> requestMap = new Map<String, Object>{
            PortalConstants.KEY_REPORT_TYPE => PortalConstants.PRODUCT_RETURN_SUMMERY_REPORT,
            PortalConstants.KEY_EXPORT_TYPE => 'csv',
            PortalConstants.KEY_FROM_DATE => String.valueOf(Date.today() - 5),
            PortalConstants.KEY_TO_DATE => String.valueOf(Date.today() - 1)
        };

        // Fetching CL user
        List<User> clUserList = [SELECT Id, Name, Email, ProfileId, UserName
                                FROM USER 
                                WHERE UserName = 'ross.geller@yopmail.com'
                                LIMIT 1];
        for(User user : clUserList){
            clUser = user;
        }

        System.runAs(clUser){
            Test.startTest();
            clcommon.Response response = apiObj.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }

    //Exception Scenario 2 -- covers required parameter missing exception
    @isTest
    private static void missingExportType(){
        User clUser;
        PortalExportProductReturnReportAPI apiObj = new PortalExportProductReturnReportAPI();
        Map<String, Object> requestMap = new Map<String, Object>{
            PortalConstants.KEY_REPORT_TYPE => PortalConstants.PRODUCT_RETURN_SUMMERY_REPORT,
            PortalConstants.KEY_FROM_DATE => String.valueOf(Date.today() - 5),
            PortalConstants.KEY_TO_DATE => String.valueOf(Date.today())
        };

        // Fetching CL user
        List<User> clUserList = [SELECT Id, Name, Email, ProfileId, UserName
                                FROM USER 
                                WHERE UserName = 'ross.geller@yopmail.com'
                                LIMIT 1];
        for(User user : clUserList){
            clUser = user;
        }

        System.runAs(clUser){
            Test.startTest();
            clcommon.Response response = apiObj.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion Failed');
            Test.stopTest();
        }
    }
}