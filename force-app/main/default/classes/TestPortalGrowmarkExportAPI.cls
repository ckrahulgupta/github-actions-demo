/**
 * @description       : Test class for PortalGrowmarkExportAPI
 * @author            : Rahul Gupta | 26-05-2022
 * @group             : 
 * @last modified on  : 03-11-2025
 * @last modified by  : Rahul Gorai
**/
@isTest
public class TestPortalGrowmarkExportAPI {

    @TestSetup
    static void setup() {
        // creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = TestClassHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);
        clcommon__Legal_Entity__c entityObj = TestClassHelper.createLegalEntity(PortalConstants.SOLE_PROP_ENTITY);
        Database.insert(entityObj, true);
        // Creating Account for Dealer
        Account dealerAccountObj = TestClassHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);    
        // creating Account for Certified Lender
        Account clAccountObj = TestClassHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Account borrowerAccountObj = TestClassHelper.createSolePropAccount(entityObj,dealerBusinessInfoObj.Id);
        Database.insert(new List<Account>{clAccountObj,borrowerAccountObj}, true);
        // Creating Contact for Certified Lender
        Contact clContactObj = TestClassHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = TestClassHelper.createBorrowerContact(borrowerAccountObj.Id);    
        Database.insert(new List<Contact>{clContactObj,borrowerContactObj}, true);
        // creating user for certified lender
        User clUser = TestClassHelper.createCLUser(clContactObj.Id);
        User borrowerUserObj = TestClassHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(new List<User>{clUser,borrowerUserObj}, true);
        // creating relationship of certified lender
        clcommon__Reciprocal_Role__c clRoleObj = TestClassHelper.createReciprocalRole('Certified Lender');
        Database.insert(clRoleObj, true);
        clcommon__Relationship__c objRelationship = TestClassHelper.createCLDealerRelationship(clRoleObj,
                                                                                                    dealerAccountObj.Id, 
                                                                                                    clAccountObj.Id);
        Database.insert(objRelationship, true);
        
        // Creating CL Product for Application
        clcommon__CL_Product__c clProductObj = TestClassHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);
        // Creating CL Purpose for Application
        clcommon__CL_Purpose__c clPurposeObj = TestClassHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);
        //creating application
        Map<String, Id> paramForApplicationMap = new Map<String, Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'clAccountId' => clAccountObj.Id
        };
        genesis__Applications__c applicationObj = TestClassHelper.createCurrCropYearApplication(paramForApplicationMap);
        applicationObj.genesis__Status__c = 'New - Entered';
        Database.insert(applicationObj, true);
        //create borrower party
        clcommon__Party_Type__c borrowerPartyType = TestClassHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c clPartyType = TestClassHelper.createPartyType('CERTIFIED LENDER');
        
        Database.insert(new List<clcommon__Party_Type__c>{borrowerPartyType,clPartyType}, true);
        Map<String, Id> paramForBorrowerPartyMap = new Map<String, Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyType.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__Party__c borrowerPartyObj = TestClassHelper.createParty(paramForBorrowerPartyMap);
        borrowerPartyObj.genesis__Application__c = applicationObj.Id;
        Database.insert(borrowerPartyObj, true);
        
        Map<String, Id> paramForCLPartyMap = new Map<String, Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clPartyType.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__Party__c certifiedLenderPartyObj = TestClassHelper.createParty(paramForCLPartyMap);
        Database.insert(certifiedLenderPartyObj, true);
        
        Map<String, Id> paramForDealerPartyMap = new Map<String, Id>{
            'accountId' => dealerAccountObj.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__Party__c dealerPartyObj = TestClassHelper.createParty(paramForDealerPartyMap);
        Database.insert(dealerPartyObj, true);
        // create rate card and pricing detail
        genesis__Rate_Card_Setup_Header__c rateCardSetupHeaderObj = TestClassHelper.createCurrYearRateCardHeader(dealerAccountObj);
        Database.insert(rateCardSetupHeaderObj, true);
        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailObj = TestClassHelper.createRateCardSetupDetailOne(rateCardSetupHeaderObj);
        Database.insert(rateCardSetupDetailObj, true);
        genesis__Application_Pricing_Detail__c appPricingDetailObj = TestClassHelper.createEnabledPricingDetail(applicationObj, rateCardSetupDetailObj.Id);
        Database.insert(appPricingDetailObj, true);
        //Create Application Fee Payment record
        genesis__Application_Fee_Payment__c appFeePaymentPremium = TestClassHelper.createApplicationFeePayment(applicationObj.Id, appPricingDetailObj.Id);
        genesis__Application_Fee_Payment__c appFeePaymentSubsidy = TestClassHelper.createApplicationFeePaymentSubsidy(applicationObj.Id, appPricingDetailObj.Id);
        Database.insert(new List<genesis__Application_Fee_Payment__c>{appFeePaymentPremium,appFeePaymentSubsidy}, true);
        // creating rate card and pricing detail
        rateCardSetupDetailObj = TestClassHelper.createRateCardSetupDetailTwo(rateCardSetupHeaderObj);
        Database.insert(rateCardSetupDetailObj, true);
        appPricingDetailObj = TestClassHelper.createDisabledPricingDetail(applicationObj, rateCardSetupDetailObj.Id);
        Database.insert(appPricingDetailObj, true);

        
        // create payment mode
        clcommon__Payment_Mode__c achPaymentModeObj = TestClassHelper.createPaymentMode().get('ACH');
        clcommon__Payment_Mode__c draftPaymentModeObj = TestClassHelper.createPaymentMode().get('DRAFT');
        Database.insert(new List<clcommon__Payment_Mode__c>{achPaymentModeObj,draftPaymentModeObj}, true);

        clcommon__Funding_Transactions_Properties__c achFundingTxnProperties = TestClassHelper.createFundingTransactionProperty('ACH - 07-09-2022');
        Database.insert(achFundingTxnProperties, true);
        Map<String, Id> paramForACHFundingTxnMap = new Map<String, Id>{
            'applicationId' => applicationObj.Id,
            'pricingDetailId' => appPricingDetailObj.Id,
            'paymentModeId' => achPaymentModeObj.Id,
            'fundingTransactionPropertyId' => achFundingTxnProperties.Id
        };

        genesis__Funding_Transaction__c achFundingTransactionObj = TestClassHelper.createACHFundingTransaction(paramForACHFundingTxnMap);
        Database.insert(achFundingTransactionObj, true);
        applicationObj = TestClassHelper.createPrevCropYearApplication(paramForApplicationMap);
        Database.insert(applicationObj, true);
        paramForApplicationMap = new Map<String, Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'clAccountId' => clAccountObj.Id
        };
        applicationObj = TestClassHelper.createCurrCropYearApplication(paramForApplicationMap);
        applicationObj.Collateral_Report_Task_Pending__c = true;
        
        Database.insert(applicationObj, true);

    }

    
    /**
    * @description Providing data for pdf and applications
    * @author Rahul Gorai | 03-09-2025 
    **/
    @isTest
    public static void testExportApplicationInPDF() {
        List<User> certifiedLenderUserList =  [SELECT Id, 
                                                        Name, 
                                                        AccountId, 
                                                        Account.ParentId 
                                                FROM User 
                                                WHERE UserName='ross.geller@yopmail.com'
                                                LIMIT 1];
        Map<String, Object> requestmap = new Map<String, Object>();
    
        List<Object> partiesList = new List<Object>();
        List<clcommon__party__c> borrowerPartyList =   [SELECT Id, 
                                                                clcommon__Type__r.Name 
                                                        FROM clcommon__Party__c 
                                                        WHERE clcommon__Type__r.Name = 'BORROWER'
                                                        LIMIT 1 ];
        List<clcommon__party__c> clPartyList = [SELECT Id, 
                                                        clcommon__Type__r.Name 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Type__r.Name = 'CERTIFIED LENDER'
                                                LIMIT 1];

        partiesList.add(borrowerPartyList[0].Id);
        partiesList.add(clPartyList[0].Id); 

        requestMap.put('applications', JSON.serialize(partiesList));
        requestMap.put('exportType', 'pdf');
        requestMap.put('dataType', 'application');

        System.runAs(certifiedLenderUserList[0]) {
            Test.startTest();
            PortalGrowmarkExportAPI saveApi = new PortalGrowmarkExportAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'Assertion Failed'); 
            Test.stopTest();
        }
    }

    /**
    * @description Providing data for csv and applications
    * @author Rahul Gorai | 03-09-2025 
    **/
    @isTest
    public static void testExportApplicationInCSV() {
        List<User> certifiedLenderUserList =  [SELECT Id, 
                                                        Name, 
                                                        AccountId, 
                                                        Account.ParentId 
                                                FROM User 
                                                WHERE UserName='ross.geller@yopmail.com'
                                                LIMIT 1];
        Map<String, Object> requestmap = new Map<String, Object>();
        
        List<Object> partiesList = new List<Object>();
        List<clcommon__party__c> borrowerPartyList =   [SELECT Id, 
                                                                clcommon__Type__r.Name 
                                                        FROM clcommon__Party__c 
                                                        WHERE clcommon__Type__r.Name = 'BORROWER'
                                                        LIMIT 1];
        List<clcommon__party__c> clPartyList = [SELECT Id, 
                                                        clcommon__Type__r.Name 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Type__r.Name = 'CERTIFIED LENDER'
                                                LIMIT 1];

        partiesList.add(borrowerPartyList[0].Id);
        partiesList.add(clPartyList[0].Id);  

        requestMap.put('applications', JSON.serialize(partiesList));
        requestMap.put('exportType', 'csv');
        requestMap.put('dataType', 'application');

        System.runAs(certifiedLenderUserList[0]) {
            Test.startTest();
            PortalGrowmarkExportAPI saveApi = new PortalGrowmarkExportAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'Assertion Failed'); 
            Test.stopTest();
        }
    }



    /**
    * @description Providing data for pdf and loans
    * @author Rahul Gorai | 03-09-2025 
    **/
    @isTest
    public static void testExportLoanInPDF() {
        List<User> certifiedLenderUserList =  [SELECT Id, 
                                                        Name, 
                                                        AccountId, 
                                                        Account.ParentId 
                                                FROM User 
                                                WHERE UserName='ross.geller@yopmail.com'
                                                LIMIT 1];
        List<genesis__Applications__c> applicationList =   [SELECT Id, 
                                                                    genesis__Status__c,
                                                                    Sales_Agent__c,
                                                                    genesis__Contact__c
                                                            FROM genesis__Applications__c 
                                                            WHERE genesis__Loan_Number__c = '300023456'
                                                            LIMIT 1];
        applicationList[0].genesis__Status__c = 'APPROVED - APPROVED';
        Database.update(applicationList[0], true);

        Map<String, Object> requestmap = new Map<String, Object>();
        
        List<Object> partiesList = new List<Object>();
        List<clcommon__party__c> borrowerPartyList =   [SELECT Id, 
                                                                clcommon__Type__r.Name 
                                                        FROM clcommon__Party__c 
                                                        WHERE clcommon__Type__r.Name = 'BORROWER'
                                                        LIMIT 1];
        List<clcommon__party__c> clPartyList = [SELECT Id, 
                                                        clcommon__Type__r.Name 
                                                        FROM clcommon__Party__c 
                                                        WHERE clcommon__Type__r.Name = 'CERTIFIED LENDER'
                                                        LIMIT 1];

        partiesList.add(borrowerPartyList[0].Id);
        partiesList.add(clPartyList[0].Id);  

        requestMap.put('applications', JSON.serialize(partiesList));
        requestMap.put('exportType', 'pdf');
        requestMap.put('dataType', 'loan');

        System.runAs(certifiedLenderUserList[0]) {
            Test.startTest();
            PortalGrowmarkExportAPI saveApi = new PortalGrowmarkExportAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'Assertion Failed'); 
            Test.stopTest();
        }
    }

    /**
    * @description Providing data for csv and loan
    * @author Rahul Gorai | 03-09-2025 
    **/
    @isTest
    public static void testExportLoanInCSV() {
        List<User> certifiedLenderUserList =  [SELECT Id, 
                                                        Name, 
                                                        AccountId, 
                                                        Account.ParentId 
                                                FROM User 
                                                WHERE UserName='ross.geller@yopmail.com'
                                                LIMIT 1];  
        List<genesis__Applications__c> applicationList =  [SELECT Id, 
                                                                    genesis__Status__c,
                                                                    Sales_Agent__c,
                                                                    genesis__Contact__c
                                                            FROM genesis__Applications__c 
                                                            WHERE genesis__Loan_Number__c = '300023456'
                                                            LIMIT 1];
        applicationList[0].genesis__Status__c = 'ACTIVE';
        Database.update(applicationList[0], true);

        Map<String, Object> requestmap = new Map<String, Object>();
        
        List<Object> partiesList = new List<Object>();
        List<clcommon__party__c> borrowerPartyList =   [SELECT Id, 
                                                                clcommon__Type__r.Name 
                                                        FROM clcommon__Party__c 
                                                        WHERE clcommon__Type__r.Name = 'BORROWER'
                                                        LIMIT 1];
        List<clcommon__party__c> clPartyList = [SELECT Id, 
                                                        clcommon__Type__r.Name 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Type__r.Name = 'CERTIFIED LENDER'
                                                LIMIT 1];

        partiesList.add(borrowerPartyList[0].Id);
        partiesList.add(clPartyList[0].Id); 

        requestMap.put('applications', JSON.serialize(partiesList));
        requestMap.put('exportType', 'csv');
        requestMap.put('dataType', 'loan');

        System.runAs(certifiedLenderUserList[0]) {
            Test.startTest();
            PortalGrowmarkExportAPI saveApi = new PortalGrowmarkExportAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'Assertion Failed'); 
            Test.stopTest();
        }
    }

    /**
    * @description Providing data for csv and no applications
    * @author Rahul Gorai | 03-09-2025 
    **/
    @isTest
    public static void testExportWithNoApplicationInCSV() {
        List<User> certifiedLenderUserList =  [SELECT Id, 
                                                        Name, 
                                                        AccountId, 
                                                        Account.ParentId 
                                                FROM User 
                                                WHERE UserName='ross.geller@yopmail.com'
                                                LIMIT 1]; 
        Map<String, Object> requestmap = new Map<String, Object>();
        
        List<Object> parties = new List<Object>();
        List<clcommon__party__c> borrowerPartyList =   [SELECT Id, 
                                                                clcommon__Type__r.Name 
                                                        FROM clcommon__Party__c 
                                                        WHERE clcommon__Type__r.Name = 'BORROWER'
                                                        LIMIT 1];
        List<clcommon__party__c> clPartyList = [SELECT Id, 
                                                        clcommon__Type__r.Name 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Type__r.Name = 'CERTIFIED LENDER'
                                                LIMIT 1];

        parties.add(borrowerPartyList[0].Id);
        parties.add(clPartyList[0].Id); 

        requestMap.put('exportType', 'csv');
        requestMap.put('dataType', 'application');

        System.runAs(certifiedLenderUserList[0]) {
            Test.startTest();
            // Calling  the API
            PortalGrowmarkExportAPI saveApi = new PortalGrowmarkExportAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'Assertion Failed'); 
            Test.stopTest();
        }
    }

    /**
    * @description Providing data for pdf and no applications
    * @author Rahul Gorai | 03-09-2025 
    **/
    @isTest
    public static void testExportWithNoApplicationInPDF() {
        List<User> certifiedLenderUserList =  [SELECT Id, 
                                                        Name, 
                                                        AccountId, 
                                                        Account.ParentId 
                                                FROM User 
                                                WHERE UserName='ross.geller@yopmail.com'
                                                LIMIT 1]; 
        Map<String, Object> requestmap = new Map<String, Object>();
        
        List<Object> parties = new List<Object>();
        List<clcommon__party__c> borrowerPartyList =   [SELECT Id, 
                                                                clcommon__Type__r.Name 
                                                        FROM clcommon__Party__c 
                                                        WHERE clcommon__Type__r.Name = 'BORROWER'
                                                        LIMIT 1];
        List<clcommon__party__c> clPartyList = [SELECT Id, 
                                                        clcommon__Type__r.Name 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Type__r.Name = 'CERTIFIED LENDER'
                                                LIMIT 1];

        parties.add(borrowerPartyList[0].Id);
        parties.add(clPartyList[0].Id); 
        requestMap.put('exportType', 'pdf');
        requestMap.put('dataType', 'application');

        System.runAs(certifiedLenderUserList[0]) {
            Test.startTest();

            // Calling  the API
            PortalGrowmarkExportAPI saveApi = new PortalGrowmarkExportAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, resp.status, 'Assertion Failed'); 
            Test.stopTest();
        }
    }

    /**
    * @description Providing no data
    * @author Rahul Gorai | 03-09-2025 
    **/
    @isTest
    public static void testWithNoData() {
        List<User> certifiedLenderUserList =  [SELECT Id, 
                                                        Name, 
                                                        AccountId, 
                                                        Account.ParentId 
                                                FROM User 
                                                WHERE UserName='ross.geller@yopmail.com'
                                                LIMIT 1];

        System.runAs(certifiedLenderUserList[0]) {
            Test.startTest();

            // Calling  the API
            PortalGrowmarkExportAPI saveApi = new PortalGrowmarkExportAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), null);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'Assertion Failed'); 
            Test.stopTest();
        }
    }

    /**
    * @description Providing no applications data
    * @author Rahul Gorai | 03-09-2025 
    **/
    @isTest
    public static void testWithNoApplicationData() {
        List<User> certifiedLenderUserList =  [SELECT Id, 
                                                        Name, 
                                                        AccountId, 
                                                        Account.ParentId 
                                                FROM User 
                                                WHERE UserName='ross.geller@yopmail.com'
                                                LIMIT 1];
        Map<String, Object> requestmap = new Map<String, Object>();
        
        List<Object> parties = new List<Object>();
        List<clcommon__party__c> borrowerPartyList =   [SELECT Id, 
                                                                clcommon__Type__r.Name 
                                                        FROM clcommon__Party__c 
                                                        WHERE clcommon__Type__r.Name = 'BORROWER'
                                                        LIMIT 1];
        List<clcommon__party__c> clPartyList = [SELECT Id, 
                                                        clcommon__Type__r.Name 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Type__r.Name = 'CERTIFIED LENDER'
                                                LIMIT 1];

        parties.add(borrowerPartyList[0].Id);
        parties.add(clPartyList[0].Id); 

        requestMap.put('applications', JSON.serialize(parties));
        requestMap.put('exportType', 'pdf');
        requestMap.put('dataType', 'loan');

        System.runAs(certifiedLenderUserList[0]) {
            Test.startTest();
            // Calling  the API
            PortalGrowmarkExportAPI saveApi = new PortalGrowmarkExportAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'Assertion Failed'); 
            Test.stopTest();
        }
    }

    /**
    * @description Providing no loans data
    * @author Rahul Gorai | 03-09-2025 
    **/
    @isTest
    public static void testWithNoLoansData() {
        List<User> certifiedLenderUserList =  [SELECT Id, 
                                                        Name, 
                                                        AccountId, 
                                                        Account.ParentId 
                                                FROM User 
                                                WHERE UserName='ross.geller@yopmail.com'
                                                LIMIT 1];
        Map<String, Object> requestmap = new Map<String, Object>();
        
        List<Object> parties = new List<Object>();
        List<clcommon__party__c> borrowerPartyList =   [SELECT Id, 
                                                                clcommon__Type__r.Name 
                                                        FROM clcommon__Party__c 
                                                        WHERE clcommon__Type__r.Name = 'BORROWER'
                                                        LIMIT 1];
        List<clcommon__party__c> clPartyList = [SELECT Id, 
                                                        clcommon__Type__r.Name 
                                                FROM   clcommon__Party__c 
                                                WHERE clcommon__Type__r.Name = 'CERTIFIED LENDER'
                                                LIMIT 1];

        parties.add(borrowerPartyList[0].Id);
        parties.add(clPartyList[0].Id); 
        requestMap.put('exportType', 'pdf');
        requestMap.put('dataType', 'loan');

        System.runAs(certifiedLenderUserList[0]) {
            Test.startTest();
            // Calling  the API
            PortalGrowmarkExportAPI saveApi = new PortalGrowmarkExportAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'Assertion Failed'); 
            Test.stopTest();
        }
    }
    /**
    * @description Providing no request data
    * @author Rahul Gorai | 03-08-2025 
    **/
    @isTest
    public static void testWithNoRequestData() {
        
        List<User> certifiedLenderUserList =  [SELECT Id, 
                                                        Name, 
                                                        AccountId, 
                                                        Account.ParentId 
                                                FROM User 
                                                WHERE UserName='ross.geller@yopmail.com'
                                                LIMIT 1];

        System.runAs(certifiedLenderUserList[0]) {
            Test.startTest();
            PortalExportAPI saveApi = new PortalExportAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), null);

            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status,PortalConstants.ASSERTION_FAILED); 

            Test.stopTest();
        }
    }
    
    /**
    * @description CustomException-No data is avaialable for export
    * @author Rahul Gorai | 03-10-2025 
    **/
    @isTest
    static void testApplicationsWithNoDataToExportException() {
        List<User> certifiedLenderUserList =  [SELECT Id, 
                                                        Name, 
                                                        AccountId, 
                                                        Account.ParentId 
                                                FROM User 
                                                WHERE UserName='ross.geller@yopmail.com'
                                                LIMIT 1];
        
        
        Set<Id> emptyPartyIdList = new Set<Id>(); 
        String exportType = 'CSV';
        Boolean shouldExportAll = false;

        
        System.runAs(certifiedLenderUserList[0]) {
            Test.startTest();
            try {
                PortalGrowmarkExportAPI obj = new PortalGrowmarkExportAPI(); 
                obj.exportApplications(emptyPartyIdList, exportType, shouldExportAll);
            
            } catch (CustomException e) {
                System.assertEquals(PortalConstants.NO_DATA_TO_EXPORT, e.getMessage(), 'Assertion failed');
            }
            Test.stopTest();
        }

        
    }
    /**
    * @description CustomException-User not authorised
    * @author Rahul Gorai | 03-10-2025 
    **/
    @isTest
    public static void testApiCustomException(){
        List<User> certifiedLenderUserList =  [SELECT Id, 
                                                        Name, 
                                                        AccountId, 
                                                        Account.ParentId 
                                                FROM User 
                                                WHERE UserName='ross.geller@yopmail.com'
                                                LIMIT 1];
        Map<String, Object> requestmap = new Map<String, Object>();
        Account objAccount =   [SELECT Id, 
                                        ParentId 
                                FROM Account 
                                WHERE Id = :certifiedLenderUserList[0].AccountId
                                LIMIT 1];
        objAccount.ParentId =null;
        Database.update(objAccount,true);
        requestMap.put('exportType', 'pdf');
        requestMap.put('dataType', 'loan');
    
        System.runAs(certifiedLenderUserList[0]) {
            Test.startTest();
            PortalGrowmarkExportAPI saveApi = new PortalGrowmarkExportAPI();
            clcommon.Response resp = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, resp.status, 'Assertion Failed'); 
            Test.stopTest();
        }
        
    }
}