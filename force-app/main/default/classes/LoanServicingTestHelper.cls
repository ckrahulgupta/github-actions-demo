/**
 * @description       : Helper Class for Test Classes Contains Methods to provide all the necessary data
 * @author            : Pritam Roy
 * @last modified on  : 03-19-2025
 * @last modified by  : Sk Minsar
**/
@isTest
public inherited sharing class LoanServicingTestHelper {

    /**
    * @description Creating Test Data for Payment Mode
    * @author Ayan Bhowmik | 02-21-2024 
    * @param paymentMode 
    * @return clcommon__Payment_Mode__c 
    **/
    public static clcommon__Payment_Mode__c createPaymentMode(String paymentMode){
        clcommon__Payment_Mode__c objPaymentMode = new clcommon__Payment_Mode__c(Name=paymentMode);
        return objPaymentMode;
    }

    /**
    * @description Creating Test Data for Funding Transaction
    * @author Ayan Bhowmik | 02-21-2024 
    * @param objPaymentMode 
    * @return genesis__Funding_Transaction__c 
    **/
    public static genesis__Funding_Transaction__c createFundingTransaction(clcommon__Payment_Mode__c objPaymentMode){
        genesis__Funding_Transaction__c objFundingTransactionACH = new genesis__Funding_Transaction__c();
        objFundingTransactionACH.genesis__Payment_Mode__c = objPaymentMode.Id;
        objFundingTransactionACH.genesis__Funding_Date__c = date.today().addMonths(-2);
        objFundingTransactionACH.genesis__Amount__c = 1500;
        objFundingTransactionACH.genesis__Reference__c = 'Crop';
        return objFundingTransactionACH;
    }

    /**
    * @description Creating Test Data for Certified Lender User
    * @author Ayan Bhowmik | 02-21-2024 
    * @param contactID 
    * @return User 
    **/
    public static User createCLUser(Id contactID){
        Profile clProfileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'Certified Lender'
                                    LIMIT 1];
        User clUserObj = new User();
        clUserObj.Alias = 'newUser';
        clUserObj.Email='cfanewus5er@yopmail.com';
        clUserObj.EmailEncodingKey='UTF-8';
        clUserObj.LastName='Testing';
        clUserObj.LanguageLocaleKey='en_US';
        clUserObj.LocaleSidKey='en_US';
        clUserObj.ProfileId = clProfileObj.Id;
        clUserObj.ContactId = contactID;
        clUserObj.TimeZoneSidKey='America/Los_Angeles';
        clUserObj.UserName='ross.geller@yopmail.com';
        return clUserObj;
    }

    /**
    * @description Fetching Certified Lender User
    * @author Ayan Bhowmik | 02-21-2024 
    * @param userName 
    * @return User 
    **/
    public static User getCertifiedLenderUser(String userName) {
        List<User> userList = [SELECT Id
                                    FROM User
                                    WHERE AccountId IN (
                                        SELECT Id
                                            FROM Account
                                            WHERE Name = :userName)];
        if (userList.isEmpty()) {
            return null;
        }
        return userList[0];
    }
    

    /**
    * @description  Creating Test Data for Loan Product
    * @author Ayan Bhowmik | 02-21-2024 
    * @return clcommon__CL_Product__c 
    **/
    public static clcommon__CL_Product__c createLoanProduct(){
        clcommon__CL_Product__c productObj = new clcommon__CL_Product__c();
        productObj.clcommon__Product_Name__c = PortalConstants.SIMPLIFY_TYPE;
        RecordType recordTypeId = [SELECT Id, 
                                            Name, 
                                            SobjectType, 
                                            DeveloperName, 
                                            NamespacePrefix 
                                        FROM RecordType 
                                        WHERE Name = 'Loan' AND 
                                            SobjectType = 'clcommon__CL_Product__c'];
        productObj.RecordTypeId = recordTypeId.Id;
        return productObj;
    }

    /**
    * @description Creating Test Data for Cl Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @return Account 
    **/
    public static Account createAccount(){
        Account objAccount = new Account();
        objAccount.Name='Test dealer';
        objAccount.Coop_Type__c='CFA';
        objAccount.CIF_Number__c = '115282';
        objAccount.BillingCity = 'Jackson';
        objAccount.BillingState = 'WA';
        return objAccount;
    }

    /**
    * @description Creating Test Data for CL purpose
    * @author Ayan Bhowmik | 02-21-2024 
    * @return clcommon__CL_Purpose__c 
    **/
    public static clcommon__CL_Purpose__c createPurpose(){
        clcommon__CL_Purpose__c  clPurposes = new clcommon__CL_Purpose__c();
        clPurposes.Name='Crop';
        return clPurposes;
    }

    /**
    * @description Creating Test Data for Active Application
    * @author Ayan Bhowmik | 02-21-2024 
    * @param objAccount 
    * @param clProduct 
    * @param clPurposes 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplication(Account objAccount,clcommon__CL_Product__c clProduct,clcommon__CL_Purpose__c clPurposes){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Product_Type__c ='Loan';
        applicationObj.genesis__Term__c = 12;
        applicationObj.genesis__Interest_Rate__c = 1;
        applicationObj.genesis__Loan_Amount__c = 35000;
        applicationObj.Peak_Loan_Volume__c = 15000;
        applicationObj.genesis__Maturity_Date__c = Date.today().addYears(1);
        applicationObj.Loan_Id__c = '139000';
        applicationObj.genesis__Loan_Number__c = '398762543';
        applicationObj.Dealer_Name__c = objAccount.Id;
        applicationObj.genesis__CL_Product__c = clProduct.Id;
        applicationObj.genesis__CL_Purpose__c = clPurposes.Id;
        applicationObj.genesis__Status__c = 'ACTIVE';
        return applicationObj;
    }

    /**
    * @description Creating Test Data for Bank Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param dealerName 
    * @return clcommon__Bank_Account__c 
    **/
    public static clcommon__Bank_Account__c createBankAccount(String dealerName){
        clcommon__Bank_Account__c bankInfo = new clcommon__Bank_Account__c();
        bankInfo.clcommon__Bank_Account_Number__c = '5003101002225';
        bankInfo.clcommon__Bank_Account_Name__c = 'Sam Grower';
        bankInfo.clcommon__Routing_Number__c = '123456789';
        bankInfo.clcommon__Account__c = dealerName;
        //bankInfo.ACH_Debit__c = true;
        bankInfo.clcommon__Active__c = true;
        return bankInfo;
    }

    /**
    * @description Creating Test Data for Pricing Detail
    * @author Ayan Bhowmik | 02-21-2024 
    * @param applicationId 
    * @return genesis__Application_Pricing_Detail__c 
    **/
    public static genesis__Application_Pricing_Detail__c createPricingDetail(String applicationId){
        genesis__Application_Pricing_Detail__c newPricingDetails = new genesis__Application_Pricing_Detail__c();
        newPricingDetails.genesis__Maximum_Financed_Amount__c = 15000;
        newPricingDetails.genesis__Rate_Factor_Based_On_Amount__c = 100;
        newPricingDetails.genesis__Rate_Factor__c = 0.00;
        newPricingDetails.genesis__Term__c = 12;
        newPricingDetails.genesis__Yield_Percent__c = 0.00;
        newPricingDetails.genesis__Application__c = applicationId;
        newPricingDetails.Loan_Number__c = '123234345-A';
        newPricingDetails.Loan_Id__c = '139001';
        newPricingDetails.Maturity_Date__c = Date.today().addYears(1);
        newPricingDetails.Interest_Per_Diem__c = 100;
        newPricingDetails.Fees__c = 100;
        return newPricingDetails;
    }

    /**
    * @description Creating Test Data for Dealer Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @return Account 
    **/
    public static Account createDealerAccount(){
        Account objAccount = new Account();
        objAccount.Name='Test Account';
        objAccount.CIF_Number__c = '115283';
        objAccount.BillingCity = 'Kolkata';
        objAccount.BillingState = 'WA';
        return objAccount;
    }

    /**
    * @description Creating Test Data for Dealer Contact
    * @author Ayan Bhowmik | 02-21-2024 
    * @param objAccount 
    * @return Contact 
    **/
    public static Contact createDealerContact(Account objAccount){
        Contact objContact = new Contact();
        objContact.LastName = 'Test Contact';
        objContact.Email='test.account@yopmail.com';
        objContact.accountId = objAccount.Id;
        return objContact;
    }

    /**
    * @description Creating Test Data for CL Party
    * @author Ayan Bhowmik | 02-21-2024 
    * @param objDealerAccount 
    * @param objClPartyType 
    * @param objApplication 
    * @return clcommon__Party__c 
    **/
    public static clcommon__Party__c createClParty(Account objDealerAccount,clcommon__Party_Type__c objClPartyType,genesis__Applications__c objApplication){
        Contact objDealerContact = [SELECT Id FROM Contact WHERE AccountId =: objDealerAccount.Id];    
        clcommon__Party__c objCertifiedLenderParty = new clcommon__Party__c();
        objCertifiedLenderParty.clcommon__Account__c = objDealerAccount.Id;
        objCertifiedLenderParty.clcommon__Contact__c = objDealerContact.Id;
        objCertifiedLenderParty.clcommon__Type__c = objClPartyType.Id;
        objCertifiedLenderParty.genesis__Application__c = objApplication.Id;
        return objCertifiedLenderParty;
    }

    /**
    * @description Creating Test Data for Reciprocal Role
    * @author Ayan Bhowmik | 02-21-2024 
    * @param name 
    * @return clcommon__Reciprocal_Role__c 
    **/
    public static clcommon__Reciprocal_Role__c createReciprocalRole(String name) {
        clcommon__Reciprocal_Role__c roleObj = new clcommon__Reciprocal_Role__c();
        roleObj.name = name;
        return roleObj;    
    }

     /**
     * @description Creating Test Data for Content Document Link
     * @author Ayan Bhowmik | 02-21-2024 
     * @param application 
     * @return contentDocumentLink 
     **/
     public static contentDocumentLink createContentDocumentLink(genesis__Applications__c application) { 
        List<ContentDocument> contentDocuments = [
                        SELECT Id 
                        FROM ContentDocument 
                        WHERE Title = 'Pre Printed Application.pdf' 
                        LIMIT 1
                    ];
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.LinkedEntityId = application.Id;
        contentDocumentLink.ContentDocumentId = contentDocuments[0].Id;
        contentDocumentLink.ShareType = 'V';
        contentDocumentLink.Visibility = 'AllUsers';
        return contentDocumentLink;
    }

    /**
    * @description Creating Test data for Content Version
    * @author Ayan Bhowmik | 02-21-2024 
    * @param fileName 
    * @return ContentVersion 
    **/
    public static ContentVersion createContentVersion(String fileName) {
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title          = fileName;
        contentVersion.PathOnClient   = fileName;
        contentVersion.VersionData    = Blob.valueOf('Test Credit Application Agreement Content');
        contentVersion.IsMajorVersion = true;
        return contentVersion;
    }

    /**
    * @description Creating Test Data for Grower Contact
    * @author Ayan Bhowmik | 02-21-2024 
    * @param objAccount 
    * @return Contact 
    **/
    public static Contact createGrowerContact(Account objAccount){
        Contact objContact = new Contact(
                LastName = 'Test Grower Contact', 
                Email='test@yopmail.com', 
                accountId = objAccount.Id
            );
        return objContact;    
    }

    /**
    * @description Creating Test Data for Grower User
    * @author Ayan Bhowmik | 02-21-2024 
    * @param objContact 
    * @return User 
    **/
    public static User createGrowerUser(Contact objContact){
        Profile profileId = [SELECT Id 
                            FROM Profile 
                            WHERE Name='Grower'];
        User objUser = new User(
                    Alias = 'newUser', 
                    Email='cfanewuser@yopmail.com',
                    EmailEncodingKey='UTF-8',
                    LastName='Testing', 
                    LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US',
                    ProfileId = profileId.Id, 
                    ContactId = objContact.Id,
                    TimeZoneSidKey='America/Los_Angeles', 
                    UserName='cfanewuser@yopmail.com',
                    User_Number__c = 11223344
                );
        return objUser;        
    }

    /**
    * @description Creating Test Data for Business Information for Dealer
    * @author Ayan Bhowmik | 02-21-2024 
    * @return genesis__Business_Information__c 
    **/
    public static genesis__Business_Information__c createBusinessInfoForDealer(){        
        genesis__Business_Information__c businessInfoObj = new genesis__Business_Information__c();
        businessInfoObj.genesis__Business_Country__c='India';
        businessInfoObj.Remaining_Customised_Limit__c=200000;
        businessInfoObj.Contract_Loan_Limit__c=300000;
        businessInfoObj.Approved_Loan_Amount__c=150000;
        businessInfoObj.genesis__Tax_Identification_Number__c = '666899905';
        return businessInfoObj;
    }

     /**
     * @description Creating Test Data for Dealer Account With Coop Type CFA
     * @author Ayan Bhowmik | 02-21-2024 
     * @param businessInfoId 
     * @return Account 
     **/
     public static Account createDealerAccount(Id businessInfoId) {
        Account dealerAccountObj = new Account();
        dealerAccountObj.Name = 'Kisan Loan';
        dealerAccountObj.genesis__Business_Information__c = businessInfoId;
        dealerAccountObj.Phone = '1234567890';
        dealerAccountObj.BillingStreet = '2423 6th Avenue';
        dealerAccountObj.BillingCity = 'Frankenmouth';
        dealerAccountObj.BillingState = 'WA';
        dealerAccountObj.BillingPostalCode = '61232';
        dealerAccountObj.CIF_Number__c = '091284';
        dealerAccountObj.Coop_Type__c = 'CFA';
        dealerAccountObj.Tier__c = 'Gold';
        //dealerAccountObj.IFP_checkbox__c = false;
        dealerAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        return dealerAccountObj;
    }

    /**
    * @description Creating Test Data for Dealer Contact
    * @author Ayan Bhowmik | 02-21-2024 
    * @param objAccountID 
    * @return Contact 
    **/
    public static Contact createDealerContact(Id objAccountID){
        Contact contactObj=new Contact();
        contactObj.FirstName='Kisan';
        contactObj.LastName='Loan';
        contactObj.Email='kisan.loan@yopmail.com';
        contactObj.Phone='1234567890';
        contactObj.accountId = objAccountId;
        return contactObj;
    }

    /**
    * @description Creating Test Data for Borrower Profile 
    * @author Ayan Bhowmik | 02-21-2024 
    * @return Profile 
    **/
    public static Profile getBorrowerProfile() {
        Profile borrowerProfileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'Grower'
                                    LIMIT 1];
        return borrowerProfileObj;
    }

    /**
    * @description Creating Test Data for Borrower User
    * @author Ayan Bhowmik | 02-21-2024 
    * @param borrowerContactId 
    * @return User 
    **/
    public static User createBorrowerUser(Id borrowerContactId){
        Profile borrowerProfileObj = getBorrowerProfile();
        User borrowerUserObj = new User();
        borrowerUserObj.Alias = 'newUser';
        // borrowerUserObj.Email='cfanewus5er@yopmail.com';
        borrowerUserObj.Email = 'jasmin.albin@yopmail.com';
        borrowerUserObj.EmailEncodingKey='UTF-8';
        borrowerUserObj.LastName='Testing';
        borrowerUserObj.LanguageLocaleKey='en_US';
        borrowerUserObj.LocaleSidKey='en_US';
        borrowerUserObj.ProfileId = borrowerProfileObj.Id;
        borrowerUserObj.ContactId = borrowerContactId;
        borrowerUserObj.TimeZoneSidKey='America/Los_Angeles';
        borrowerUserObj.UserName='jasmine.albin@yopmail.com';
        return borrowerUserObj;
    }

    /**
    * @description Fetching Borrower User
    * @author Ayan Bhowmik | 02-21-2024 
    * @param userName 
    * @return User 
    **/
    public static User getBorrowerUser(String userName) {
        List<User> borrowerUserList = [SELECT Id 
                                    FROM User 
                                    WHERE ContactId IN (
                                    SELECT Id 
                                    FROM Contact 
                                    WHERE LastName = :userName)];
                                    
        if (borrowerUserList.isEmpty()) {
            return null;
        } 
        return borrowerUserList[0];
    }
    
    /**
    * @description Creating Test Data for Certfied Lender Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param businessInfoId 
    * @param dealerAccountId 
    * @return Account 
    **/
    public static Account createCLAccount(Id businessInfoId, Id dealerAccountId){
        Account clAccountObj = new Account();
        clAccountObj.Name = 'Ross Geller';
        clAccountObj.genesis__Business_Information__c = businessInfoId;
        clAccountObj.Phone = '666714588';
        clAccountObj.BillingStreet = '2423 6th Avenue';
        clAccountObj.BillingCity = 'Frankenmouth';
        clAccountObj.BillingState = 'WA';
        clAccountObj.BillingPostalCode = '61232';
        clAccountObj.CIF_Number__c = '009988';
        clAccountObj.clcommon__Email__c = 'ross.geller@yopmail.com';
        clAccountObj.ParentId = dealerAccountId;
        clAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Certified Lender').getRecordTypeId();
        return clAccountObj;
    }

    /**
    * @description Creating Sales Agent Account
    * @author Ravi Ranjan | 04-17-2024 
     * @param businessInfoId 
     * @param dealerAccountId 
     * @return  `Account`
     */
    public static Account createSalesAgentAccount(Id businessInfoId, Id dealerAccountId){
        Account saAccountObj = new Account();
        saAccountObj.Name = 'Tony Stark';
        saAccountObj.genesis__Business_Information__c = businessInfoId;
        saAccountObj.Phone = '98765453456';
        saAccountObj.BillingStreet = '2423 6th Avenue';
        saAccountObj.BillingCity = 'Frankenmouth';
        saAccountObj.BillingState = 'WA';
        saAccountObj.BillingPostalCode = '61232';
        saAccountObj.CIF_Number__c = '787867';
        saAccountObj.clcommon__Email__c = 'tony.stark@yopmail.com';
        saAccountObj.ParentId = dealerAccountId;
        saAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sales Agent').getRecordTypeId();
        return saAccountObj;
    }

    /**
    * @description Creating Test Data for CL Product of Application
    * @author Ayan Bhowmik | 02-21-2024 
    * @return clcommon__CL_Product__c 
    **/
    public static clcommon__CL_Product__c createCLProductForApplication() {
        clcommon__CL_Product__c clProductObj = new clcommon__CL_Product__c();
        clProductObj.clcommon__Product_Name__c ='Simpli-Fi';
        return clProductObj;
    }

    /**
    * @description Creating Test Data for Purpose of Application
    * @author Ayan Bhowmik | 02-21-2024 
    * @return clcommon__CL_Purpose__c 
    **/
    public static clcommon__CL_Purpose__c createCLPurposeForApplication() {
        clcommon__CL_Purpose__c  clPurposeObj = new clcommon__CL_Purpose__c();
        clPurposeObj.Name='Crop';
        return clPurposeObj;
    }


     /**
     * @description Creating Test Data for Legal Entity
     * @author Ayan Bhowmik | 02-21-2024 
     * @param name 
     * @return clcommon__Legal_Entity__c 
     **/
     public static clcommon__Legal_Entity__c createLegalEntity(String name) {
        clcommon__Legal_Entity__c entityObj = new clcommon__Legal_Entity__c();
        entityObj.clcommon__Legal_Entity_Type__c = name;
        entityObj.Name = name;
        return entityObj;
    }


    /**
    * @description Creating Test Data for Sole Prop Borrower Account
    * @author Ayan Bhowmik | 02-21-2024 
    * @param entityObj 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createSolePropAccount(clcommon__Legal_Entity__c entityObj, 
                                                            Id businessInfoId){  
        Account accountObj = new Account();
        accountObj.Name = 'Jasmine Albin';
        accountObj.clcommon__Email__c='jasmin.albin@yopmail.com';
        accountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        accountObj.genesis__Business_Information__c=businessInfoId;
        return accountObj;
    }


    /**
    * @description Creating Test Data for Certified Lender Contact
    * @author Ayan Bhowmik | 02-21-2024 
    * @param accountId 
    * @return Contact 
    **/
    public static Contact createCLContact(Id accountId){
        Contact clContactObj=new Contact();
        clContactObj.FirstName='Ross';
        clContactObj.LastName='Geller';
        clContactObj.genesis__SSN__c='555212313';
        clContactObj.Confirm_SSN__c='555212313';
        clContactObj.Email='ross.geller@yopmail.com';
        clContactObj.Phone='666714588';
        clContactObj.accountId = accountId;
        return clContactObj;
    }


    /**
    * @description Creating Test Data for Borrower Contact
    * @author Ayan Bhowmik | 02-21-2024 
    * @param objAccountID 
    * @return Contact 
    **/
    public static Contact createBorrowerContact(Id objAccountID){
        Contact contactObj=new Contact();
        contactObj.FirstName='Jasmine';
        contactObj.LastName='Albin';
        contactObj.Email='jasmin.albin@yopmail.com';
        contactObj.Phone='9734227544';
        contactObj.MobilePhone = '342134234';
        contactObj.genesis__SSN__c = '738209348';
        contactObj.accountId = objAccountId;
        contactObj.Birthdate = System.today().addYears(-35);
        return contactObj;
    }

 
    /**
    * @description Creating Test Data for an Application Which is ACTIVATED for Current Crop Year
    * @author Ayan Bhowmik | 02-21-2024 
    * @param paramMap 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createCurrCropYearApplication(Map<String, Id> paramMap){
        Integer month = System.today().month();
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Product_Type__c ='Loan';
        applicationObj.genesis__Term__c = 12;
        applicationObj.genesis__Interest_Rate__c = 1;
        applicationObj.genesis__Loan_Amount__c = 35000;
        applicationObj.Peak_Loan_Volume__c = 15000;
        applicationObj.genesis__Maturity_Date__c = Date.today().addYears(1);
        applicationObj.Loan_Id__c = '139000';
        applicationObj.genesis__Loan_Number__c = '300023456';
        applicationObj.genesis__Status__c = 'ACTIVE';
        applicationObj.Reserved_Amount__c = 15000;
        applicationObj.DocuSign_Credit_Agreement_Initiated__c = true;
        if(month >= 6){
            applicationObj.Crop_Year__c = String.valueOf(System.today().addYears(1).year());
        } else {
            applicationObj.Crop_Year__c = String.valueOf(System.today().year());
        }
        applicationObj.Dealer_Name__c = paramMap.get('dealerAccountId');
        applicationObj.genesis__CL_Product__c = paramMap.get('clProductId');
        applicationObj.genesis__CL_Purpose__c = paramMap.get('clPurposeId');
        applicationObj.genesis__Account__c = paramMap.get('borrowerAccountId');
        applicationObj.genesis__Contact__c = paramMap.get('borrowerContactId');
        applicationObj.Certified_Lender__c = paramMap.get('clAccountId');
        applicationObj.Dealer_Applicant_Relationship__c = paramMap.get('dealerApplicantRelationshipId');
        applicationObj.Signing_Method__c = 'Email - Docusign';
        return applicationObj;
    } 
    

    /**
    * @description Creating Test Data for Enabled Pricing Details
    * @author Ayan Bhowmik | 02-21-2024 
    * @param applicationobj 
    * @param rateCardSetupDetailId 
    * @return genesis__Application_Pricing_Detail__c 
    **/
    public static genesis__Application_Pricing_Detail__c createEnabledPricingDetail(genesis__Applications__c applicationobj,
                                                                                                Id rateCardSetupDetailId){
        genesis__Application_Pricing_Detail__c pricingDetailsObj = new genesis__Application_Pricing_Detail__c();
        pricingDetailsObj.genesis__Maximum_Financed_Amount__c = 15000;
        pricingDetailsObj.genesis__Rate_Factor_Based_On_Amount__c = 100;
        pricingDetailsObj.genesis__Rate_Factor__c = 0.00;
        pricingDetailsObj.genesis__Term__c = 12;
        pricingDetailsObj.genesis__Yield_Percent__c = 0.00;
        pricingDetailsObj.genesis__Application__c = applicationobj.Id;
        pricingDetailsObj.Loan_Number__c = applicationobj.genesis__Loan_Number__c + '-A';
        pricingDetailsObj.Loan_Id__c = '139001';
        pricingDetailsObj.Loan_Number__c = applicationobj.genesis__Loan_Number__c;
        pricingDetailsObj.Maturity_Date__c = Date.today().addYears(1);
        pricingDetailsObj.Interest_Per_Diem__c = 100;
        pricingDetailsObj.Fees__c = 100;
        pricingDetailsObj.genesis__Enabled_Flag__c = true;
        pricingDetailsObj.genesis__Rate_Card_Setup_Detail__c = rateCardSetupDetailId;
        return pricingDetailsObj;
    }

    /**
    * @description Creating Test Data for Pending Payments
    * @author Ayan Bhowmik | 02-21-2024 
    * @param paymentModeId 
    * @param objPricingId 
    * @return genesis__Funding_Transaction__c 
    **/
    public static genesis__Funding_Transaction__c createPendingPayment(Id paymentModeId, Id objPricingId){
        genesis__Funding_Transaction__c pendingPayment = new genesis__Funding_Transaction__c();
        pendingPayment.Interest_Paid__c = 0.1;
        pendingPayment.Principal_Paid__c = 0.1; 
        pendingPayment.Fees_Paid__c = 0.1;
        pendingPayment.genesis__Payment_Mode__c = paymentModeId;
        pendingPayment.Pricing_Detail__c = objPricingId;
        pendingPayment.genesis__Cleared__c = true;
        pendingPayment.Posted_to_NLS__c = false;
        return pendingPayment;
    }


    /**
    * @description Creating Test Data for Rate Card Setup Details for Current Year My Program
    * @author Ayan Bhowmik | 02-21-2024 
    * @param myProgram 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    public static genesis__Rate_Card_Setup_Detail__c createRateCardSetupDetail(genesis__Rate_Card_Setup_Header__c myProgram){
        genesis__Rate_Card_Setup_Detail__c rateCardDetailObj = new genesis__Rate_Card_Setup_Detail__c();
        rateCardDetailObj.genesis__Rate_Card_Setup_Header__c = myProgram.Id;
        rateCardDetailObj.Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account';
        rateCardDetailObj.Participation_Percentage_CFA__c = 5.5;
        rateCardDetailObj.Participation_Percentage_Dealer__c = 0.2;
        rateCardDetailObj.Participation_Percentage_Dealer_Subsidy__c = 0;
        rateCardDetailObj.Interest_Rate_Type__c = 'Fixed';
        rateCardDetailObj.Start_Date__c = Date.newInstance(2022, 07, 01);
        rateCardDetailObj.End_Date__c = Date.newInstance(2022, 09, 30);
        rateCardDetailObj.genesis__Interest_Rate__c = 7.7;
        return rateCardDetailObj;
    }


     /**
     * @description Creating Test Data for Enabled Rate Card Setup Header for Previous Year
     * @author Ayan Bhowmik | 02-21-2024 
     * @param accountObj 
     * @return genesis__Rate_Card_Setup_Header__c 
     **/
     public static genesis__Rate_Card_Setup_Header__c createRateCardHeader(Account accountObj){
        Integer month;
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderObj.Name = 'My Test Program 99';
        rateCardHeaderObj.genesis__Product_Type__c = PortalConstants.PRODUCT_TYPE_FOR_MY_PROGRAM;
        rateCardHeaderObj.Account__c = accountObj.Id;
        rateCardHeaderObj.CFA_Advantage_Rate__c = 7;
        rateCardHeaderObj.genesis__Description__c = 'This rate card calculates an interest for seed purpose oriented loans';
        rateCardHeaderObj.Closing_Fee__c = 200;
        rateCardHeaderObj.genesis__Start_Date__c = Date.newInstance(2022, 10, 01);
        rateCardHeaderObj.genesis__Transaction_Date__c = System.today();
        rateCardHeaderObj.genesis__End_Date__c = Date.newInstance(2022, 12, 01);
        rateCardHeaderObj.Payer_of_Loan_Closing_Fee__c = 'Grower';
        rateCardHeaderObj.Loan_Fee_Advanced_On__c = 'A';
        rateCardHeaderObj.Dealer_Participate_on_Closing_Fee__c = 'Yes';
        rateCardHeaderObj.Portion_of_Fee_to_Cover__c = 100;
        rateCardHeaderObj.genesis__Enabled_Flag__c = true;
        if(month >= 6){
            rateCardHeaderObj.Crop_Year__c = String.valueOf(System.today().year());
        } else {
            rateCardHeaderObj.Crop_Year__c = String.valueOf(System.today().year() - 1);
        }
        return rateCardHeaderObj;
    }


     /**
     * @description Creating Test Data for Payment Mode for all type of Payment
     * @author Ayan Bhowmik | 02-21-2024 
     * @return Map<String, clcommon__Payment_Mode__c> 
     **/
     public static Map<String, clcommon__Payment_Mode__c> createPaymentMode() {
        Map<String, clcommon__Payment_Mode__c> paymentModeMap = new Map<String, clcommon__Payment_Mode__c>{
            ConstantValues.ACH => new clcommon__Payment_Mode__c(Name = ConstantValues.ACH),
            ConstantValues.DRAFT => new clcommon__Payment_Mode__c(Name = ConstantValues.DRAFT),
            ConstantValues.PAYMENT => new clcommon__Payment_Mode__c(Name = ConstantValues.PAYMENT),
            ConstantValues.MOBILE_DEPOSIT => new clcommon__Payment_Mode__c(Name = ConstantValues.MOBILE_DEPOSIT),
            ConstantValues.PRODUCT_RETURN => new clcommon__Payment_Mode__c(Name = ConstantValues.PRODUCT_RETURN)
        };
        return paymentModeMap;
    }


    /**
    * @description Creating Test Data for Funding Transaction
    * @author Ayan Bhowmik | 02-21-2024 
    * @param paymentModeId 
    * @return genesis__Funding_Transaction__c 
    **/
    public static genesis__Funding_Transaction__c createFundingTransaction(Id paymentModeId){
        genesis__Funding_Transaction__c objFundingTransaction = new genesis__Funding_Transaction__c();
        objFundingTransaction.genesis__Payment_Mode__c = paymentModeId;
        objFundingTransaction.genesis__Funding_Date__c = date.today();
        objFundingTransaction.genesis__Amount__c = 1500;
        objFundingTransaction.genesis__Reference__c = 'Crop';
        return objFundingTransaction;
    }


    /**
    * @description Creating Test Data for Party Type
    * @author Ayan Bhowmik | 02-21-2024 
    * @param name 
    * @return clcommon__Party_Type__c 
    **/
    public static clcommon__Party_Type__c createPartyType(String name) {
        clcommon__Party_Type__c partyTypeObj = new clcommon__Party_Type__c();
        partyTypeObj.Name= name;
        return partyTypeObj;
    }

    /**
    * @description : This method creates and returns multiple party type instances
    * @author Tuhin Bhunia | 03-21-2024 
    * @return Map<String, clcommon__Party_Type__c> 
    **/
    public static Map<String, clcommon__Party_Type__c> createMultiplePartyType() {
        
        Map<String, clcommon__Party_Type__c> partyTypesMap = new Map<String, clcommon__Party_Type__c>{
            'dealerPartyType' => new clcommon__Party_Type__c(name = 'DEALER'),
            'borrowerPartyType' => new clcommon__Party_Type__c(name = 'BORROWER'),
            'principalPartyType' => new clcommon__Party_Type__c(name = 'PRINCIPAL'),
            'clPartyType' => new clcommon__Party_Type__c(name = 'CERTIFIED LENDER'),
            'clPlusPartyType' => new clcommon__Party_Type__c(name = 'CERTIFIED LENDER PLUS'),
            'saPartyType' => new clcommon__Party_Type__c(name = 'SALES AGENT'),
            'saPlusPartyType' => new clcommon__Party_Type__c(name = 'SALES AGENT PLUS'),
            'inquiryPartyType' => new clcommon__Party_Type__c(name = 'INQUIRY'),
            'inquiryPlusPartyType' => new clcommon__Party_Type__c(name = 'INQUIRY PLUS'),
            'spousePartyType' => new clcommon__Party_Type__c(name = 'SPOUSE'),
            'landOwnerPartyType' => new clcommon__Party_Type__c(name = 'LANDOWNER'),
            'insuranceAgentPartyType' => new clcommon__Party_Type__c(name = 'INSURANCE AGENT')
        };
        return partyTypesMap;
    }

    /**
    * @description Creating Test Data for Party
    * @author Ayan Bhowmik | 02-21-2024 
    * @param paramMap 
    * @return clcommon__Party__c 
    **/
    public static clcommon__Party__c createParty(Map<String, Id> paramMap){
        clcommon__Party__c partyObj = new clcommon__Party__c();
        partyObj.clcommon__Account__c=paramMap.get('accountId');
        partyObj.clcommon__Contact__c=paramMap.get('contactId');
        partyObj.clcommon__Type__c = paramMap.get('partyTypeId');
        partyObj.genesis__Application__c = paramMap.get('applicationId');
        partyObj.Dealer_Applicant_Relationship__c = paramMap.get('dealerApplicantRelationshipId');
        // partyObj.clcommon__Party_Types__c = paramMap.get('partyTypes');
        partyObj.Total_Assets__c = 2346;
        partyObj.Total_Liabilities__c = 2423433;
        return partyObj;
    }


    /**
    * @description Creating Test Data for business info for Borrower
    * @author Ayan Bhowmik | 02-21-2024 
    * @return genesis__Business_Information__c 
    **/
    public static genesis__Business_Information__c createBusinessInfoForBorrower(){        
        genesis__Business_Information__c businessInfoObj = new genesis__Business_Information__c();
        businessInfoObj.genesis__Business_Country__c='India';
        businessInfoObj.Remaining_Customised_Limit__c=100000;
        businessInfoObj.Contract_Loan_Limit__c=500000;
        businessInfoObj.Approved_Loan_Amount__c=200000;
        businessInfoObj.genesis__Tax_Identification_Number__c = '122334556';
        businessInfoObj.genesis__Total_Liabilities__c=2346;
        businessInfoObj.genesis__Total_Assets__c=987683;
        
        return businessInfoObj;
    }


    /**
    * @description Creating Test Data for Relationship between Dealer and Certified Lender
    * @author Ayan Bhowmik | 02-21-2024 
    * @param clRoleObj 
    * @param dealerAccountId 
    * @param clAccountId 
    * @return clcommon__Relationship__c 
    **/
    public static clcommon__Relationship__c createCLDealerRelationship(clcommon__Reciprocal_Role__c clRoleObj,
                                                                        Id dealerAccountId,
                                                                        Id clAccountId) {
        clcommon__Relationship__c relationshipObj = new clcommon__Relationship__c();
        relationshipObj.clcommon__Relationship__c = clRoleObj.Id;
        relationshipObj.clcommon__Entity__c = dealerAccountId;
        relationshipObj.clcommon__Related_Entity__c = clAccountId;
        return relationshipObj;
    }


    /**
    * @description Creating Test Data for ACH funding transaction properties
    * @author Ayan Bhowmik | 02-21-2024 
    * @return clcommon__Funding_Transactions_Properties__c 
    **/
    public static clcommon__Funding_Transactions_Properties__c createAchFundingTransactionProperties(){
        clcommon__Funding_Transactions_Properties__c fundingPropertiesObj = new clcommon__Funding_Transactions_Properties__c();
        fundingPropertiesObj.Batch_Total_Amount__c = 1000;
        fundingPropertiesObj.Payment_Mode__c = 'ACH';
        fundingPropertiesObj.Status__c = 'Recorded';
        fundingPropertiesObj.Name = 'ACH-2022-06-17 11:30:01';
        return fundingPropertiesObj;
    }

    /**
     * @description : Creating Test Data for ACH funding transaction
     * @author Tuhin Bhunia | 03-20-2024 
     * @param paramMap 
     * @return  `genesis__Funding_Transaction__c`
     */
    public static genesis__Funding_Transaction__c createACHFundingTransaction(Map<String, Id> paramMap) {
        genesis__Funding_Transaction__c fundingTransactionObj = new genesis__Funding_Transaction__c();
        fundingTransactionObj.genesis__Application__c = paramMap.get('applicationId');
        fundingTransactionObj.Grower_Name__c = 'Test Grower 1';
        fundingTransactionObj.Pricing_Detail__c = paramMap.get('pricingDetailId');
        fundingTransactionObj.genesis__Amount__c = 1000;
        fundingTransactionObj.genesis__Payment_Mode__c = paramMap.get( 'paymentModeId');
        fundingTransactionObj.Batch__c = paramMap.get('fundingTransactionPropertyId');
        fundingTransactionObj.genesis__Funding_Date__c = Date.today().addDays(-1);
        return fundingTransactionObj;
    }

    /**
     * @description :
     * @author Tuhin Bhunia | 03-20-2024 
     * @param paramMap 
     * @return  `genesis__Funding_Transaction__c`
     */
    public static genesis__Funding_Transaction__c createProductReturnWithoutPropertiesBatch(Map<String, Id> paramMap) {
        genesis__Funding_Transaction__c fundingTransactionObj = new genesis__Funding_Transaction__c();
        fundingTransactionObj.genesis__Application__c = paramMap.get('applicationId');
        fundingTransactionObj.Grower_Name__c = 'Test Grower 1';
        fundingTransactionObj.Pricing_Detail__c = paramMap.get('pricingDetailId');
        fundingTransactionObj.genesis__Amount__c = 1000;
        fundingTransactionObj.genesis__Payment_Mode__c = paramMap.get( 'paymentModeId');
        fundingTransactionObj.genesis__Cleared__c = false;
        return fundingTransactionObj;
    }

    /**
    * @description Creating Test Data for DRAFT funding transaction properties
    * @author Ayan Bhowmik | 02-21-2024 
    * @return clcommon__Funding_Transactions_Properties__c 
    **/
    public static clcommon__Funding_Transactions_Properties__c createDraftFundingTransactionProperties(){
        clcommon__Funding_Transactions_Properties__c fundingPropertiesObj = new clcommon__Funding_Transactions_Properties__c();
        fundingPropertiesObj.Batch_Total_Amount__c = 1000;
        fundingPropertiesObj.Payment_Mode__c = 'DRAFT';
        fundingPropertiesObj.Status__c = 'Recorded';
        fundingPropertiesObj.Name = 'DRAFT-2022-06-17 11:30:01';
        return fundingPropertiesObj;
    }



    /**
    * @description Creating Test Data for Funding Transaction
    * @author Ayan Bhowmik | 02-21-2024 
    * @param paymentModeId 
    * @param fundingPropertiesId 
    * @param applicationId 
    * @return genesis__Funding_Transaction__c 
    **/
    public static genesis__Funding_Transaction__c createFundingTransaction(Id paymentModeId, Id fundingPropertiesId, Id applicationId){
        genesis__Funding_Transaction__c fundingTransactionObj = new genesis__Funding_Transaction__c();
        fundingTransactionObj.genesis__Amount__c = 1000;
        fundingTransactionObj.genesis__Application__c = applicationId;
        fundingTransactionObj.Batch__c = fundingPropertiesId;
        fundingTransactionObj.genesis__Payment_Mode__c = paymentModeId;
        return fundingTransactionObj;
    }


    /**
    * @description Creating Test Data for Application Fees 
    * @author Ayan Bhowmik | 02-21-2024 
    * @param applicationId 
    * @param pricingDetailId 
    * @return genesis__Application_Fee_Payment__c 
    **/
    public static genesis__Application_Fee_Payment__c createApplicationFeePayment(Id applicationId,
                                                                                        Id pricingDetailId) {
        genesis__Application_Fee_Payment__c applicationFeePaymentObj = new genesis__Application_Fee_Payment__c();
        applicationFeePaymentObj.External_Id__c = 'weqasweqwe1124';
        applicationFeePaymentObj.Pricing_Detail__c = pricingDetailId;
        applicationFeePaymentObj.Interest_Earned__c=10;
        applicationFeePaymentObj.Interest_Paid__c=10;
        applicationFeePaymentObj.Dealer_Monthly_Interest__c=10;
        applicationFeePaymentObj.Past_Due_Balance__c=10;
        applicationFeePaymentObj.Month__c=System.today().month();
        applicationFeePaymentObj.Year__c=System.today().year();
        applicationFeePaymentObj.genesis__Application__c = applicationId;
        applicationFeePaymentObj.Record_Type__c='PARTICIPANT DAILY';
        return applicationFeePaymentObj;
    }

    /**
    * @description Creating Test Data for Application Fee Payment of Active Loan
    * @author Ayan Bhowmik | 02-21-2024 
    * @param applicationId 
    * @param pricingDetailId 
    * @return genesis__Application_Fee_Payment__c 
    **/
    public static genesis__Application_Fee_Payment__c createApplicationFeePaymentOfActiveLoanDailyType(Id applicationId,
                                                                                                        Id pricingDetailId){
        genesis__Application_Fee_Payment__c applicationFeePaymentObj=new genesis__Application_Fee_Payment__c();
        applicationFeePaymentObj.Pricing_Detail__c = pricingDetailId;
        applicationFeePaymentObj.Record_Type__c = 'ACTIVE LOAN DAILY';
        applicationFeePaymentObj.genesis__Application__c = applicationId;
        applicationFeePaymentObj.External_Id__c='participant-'+applicationId+'-2022-202202';
        return applicationFeePaymentObj;
                                                                                                        
    }


    /**
    * @description Creating Test Data for bank account by dealer account id
    * @author Ayan Bhowmik | 02-21-2024 
    * @param dealerAccountid 
    * @return clcommon__Bank_Account__c 
    **/
    public static clcommon__Bank_Account__c createBankAccount(Id dealerAccountid){
        clcommon__Bank_Account__c bankInfo = new clcommon__Bank_Account__c();
        bankInfo.clcommon__Bank_Account_Number__c = '5003101002225';
        bankInfo.clcommon__Bank_Account_Name__c = 'Sam Grower';
        bankInfo.clcommon__Routing_Number__c = '322078804';
        bankInfo.clcommon__Account__c = dealerAccountid;
        bankInfo.clcommon__Bank_Name__c = 'FINANCIAL PARTNERS CREDIT UNION';
        bankInfo.clcommon__Active__c = true;
        bankInfo.ACH_Debit__c = true;
        bankInfo.ACH_Credit__c = true;
        return bankInfo;
    }
    /**
    * @description Creating Test Data for Rate Card Setup Details
    * @author Ayan Bhowmik | 02-21-2024 
    * @param myProgram 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    public static genesis__Rate_Card_Setup_Detail__c createRateCardSetupDetailOne(genesis__Rate_Card_Setup_Header__c myProgram){
        genesis__Rate_Card_Setup_Detail__c rateCardDetailObj = new genesis__Rate_Card_Setup_Detail__c();
        rateCardDetailObj.genesis__Rate_Card_Setup_Header__c = myProgram.Id;
        rateCardDetailObj.Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account';
        rateCardDetailObj.Participation_Percentage_CFA__c = 5.5;
        rateCardDetailObj.Participation_Percentage_Dealer__c = 0.2;
        rateCardDetailObj.Participation_Percentage_Dealer_Subsidy__c = 0;
        rateCardDetailObj.Interest_Rate_Type__c = 'Fixed';
        rateCardDetailObj.Start_Date__c = Date.newInstance(2022, 07, 01);
        rateCardDetailObj.End_Date__c = Date.newInstance(2022, 09, 30);
        rateCardDetailObj.genesis__Interest_Rate__c = 7.7;
        return rateCardDetailObj;
    }

    /**
    * @description Creating Test Data for Disabled Pricing Detail
    * @author Ayan Bhowmik | 02-21-2024 
    * @param applicationobj 
    * @param rateCardSetupDetailId 
    * @return genesis__Application_Pricing_Detail__c 
    **/
    public static genesis__Application_Pricing_Detail__c createDisabledPricingDetail(genesis__Applications__c applicationobj,Id rateCardSetupDetailId){
        genesis__Application_Pricing_Detail__c pricingDetailsObj = new genesis__Application_Pricing_Detail__c();
        pricingDetailsObj.genesis__Maximum_Financed_Amount__c = 15000;
        pricingDetailsObj.genesis__Rate_Factor_Based_On_Amount__c = 100;
        pricingDetailsObj.genesis__Rate_Factor__c = 0.00;
        pricingDetailsObj.genesis__Term__c = 12;
        pricingDetailsObj.genesis__Yield_Percent__c = 0.00;
        pricingDetailsObj.genesis__Application__c = applicationobj.Id;
        pricingDetailsObj.Loan_Number__c = applicationobj.genesis__Loan_Number__c + '-A';
        pricingDetailsObj.Loan_Id__c = '139001';
        pricingDetailsObj.Loan_Number__c = '300023457';
        pricingDetailsObj.Maturity_Date__c = Date.today().addYears(1);
        pricingDetailsObj.Interest_Per_Diem__c = 100;
        pricingDetailsObj.Fees__c = 100;
        pricingDetailsObj.genesis__Enabled_Flag__c = false;
        pricingDetailsObj.genesis__Rate_Card_Setup_Detail__c = rateCardSetupDetailId;
        return pricingDetailsObj;
    }

    /**
     * @description : Creates rate card setup header for current year.
     * @author Tuhin Bhunia | 03-20-2024 
     * @param accountObj 
     * @return  `genesis__Rate_Card_Setup_Header__c`
     */
    public static genesis__Rate_Card_Setup_Header__c createCurrYearRateCardHeader(Account accountObj){
        Integer month;
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderObj.Name = 'My Test Program 99';
        rateCardHeaderObj.genesis__Product_Type__c = PortalConstants.PRODUCT_TYPE_FOR_MY_PROGRAM;
        rateCardHeaderObj.Account__c = accountObj.Id;
        rateCardHeaderObj.CFA_Advantage_Rate__c = 7;
        rateCardHeaderObj.genesis__Description__c = 'This rate card calculates an interest for seed purpose oriented loans';
        rateCardHeaderObj.Closing_Fee__c = 200;
        rateCardHeaderObj.genesis__Start_Date__c = Date.newInstance(2022, 07, 01);
        rateCardHeaderObj.genesis__Transaction_Date__c = Date.newInstance(2022, 10, 15);
        rateCardHeaderObj.genesis__End_Date__c = Date.newInstance(2023, 09, 15);
        rateCardHeaderObj.Payer_of_Loan_Closing_Fee__c = 'Grower';
        rateCardHeaderObj.Loan_Fee_Advanced_On__c = 'A';
        rateCardHeaderObj.Dealer_Participate_on_Closing_Fee__c = 'Yes';
        rateCardHeaderObj.Portion_of_Fee_to_Cover__c = 100;
        rateCardHeaderObj.genesis__Enabled_Flag__c = true;
        if(month >= 6){
            rateCardHeaderObj.Crop_Year__c = String.valueOf(System.today().addYears(1).year());
        } else {
            rateCardHeaderObj.Crop_Year__c = String.valueOf(System.today().year());
        }
        return rateCardHeaderObj;
    }

    /**
     * @description : Creating funding transaction properties for test cases
     * @author Tuhin Bhunia | 03-20-2024 
     * @param name 
     * @return  `clcommon__Funding_Transactions_Properties__c`
     */
    public static clcommon__Funding_Transactions_Properties__c createFundingTransactionProperty(String name) {
        clcommon__Funding_Transactions_Properties__c fundingTransacPropertyObj = new clcommon__Funding_Transactions_Properties__c();
        fundingTransacPropertyObj.Name = name;
        return fundingTransacPropertyObj;
    }

    /**
    * @description Creating Approved Application Note
    * @author Simran | 03-22-2024 
    * @param applicationObj 
    * @return genesis__Application_Note__c 
    **/
    public static genesis__Application_Note__c createApproveApplicationNote(genesis__Applications__c applicationObj){
        genesis__Application_Note__c appNoteObj = new genesis__Application_Note__c();
        appNoteObj.genesis__Application__c=applicationObj.Id;
        appNoteObj.Status__c=ConstantValues.APPLICATION_NOTE_APPROVE_STATUS;
        appNoteObj.Updated_Loan_Amount__c =425.00;
        appNoteObj.Current_Loan_Amount__c=4575.98;
        appNoteObj.Current_Maturity_Date__c=Date.today().addMonths(3);
        appNoteObj.Modified_Maturity_Date__c =Date.today().addMonths(6);
        return appNoteObj;
    }

    /**
    * @description Creating an Application Which is ACTIVATED for Previous Crop Year 
    * @author Simran | 03-22-2024 
    * @param paramMap 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createPrevCropYearApplication(Map<String, Id> paramMap){
        Integer month = System.today().month();
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Product_Type__c ='Loan';
        applicationObj.genesis__Term__c = 12;
        applicationObj.genesis__Interest_Rate__c = 1;
        applicationObj.genesis__Loan_Amount__c = 35000;
        applicationObj.Peak_Loan_Volume__c = 15000;
        applicationObj.genesis__Maturity_Date__c = Date.today().addYears(1);
        applicationObj.Loan_Id__c = '139000';
        applicationObj.genesis__Loan_Number__c = '300023457';
        applicationObj.genesis__Status__c = 'ACTIVE';
        applicationObj.Reserved_Amount__c = 15000;
        applicationObj.DocuSign_Credit_Agreement_Initiated__c = true;
        if(month >= 6){
            applicationObj.Crop_Year__c = String.valueOf(System.today().year());
        } else {
            applicationObj.Crop_Year__c = String.valueOf(System.today().year() - 1);
        }
        applicationObj.Dealer_Name__c = paramMap.get('dealerAccountId');
        applicationObj.genesis__CL_Product__c = paramMap.get('clProductId');
        applicationObj.genesis__CL_Purpose__c = paramMap.get('clPurposeId');
        applicationObj.genesis__Account__c = paramMap.get('borrowerAccountId');
        applicationObj.genesis__Contact__c = paramMap.get('borrowerContactId');
        applicationObj.Certified_Lender__c = paramMap.get('clAccountId');
        applicationObj.Dealer_Applicant_Relationship__c = paramMap.get('dealerApplicantRelationshipId');
        return applicationObj;
    } 

    /**
    * @description Creating Declined Application Note
    * @author Simran | 03-22-2024 
    * @param applicationObj 
    * @return genesis__Application_Note__c 
    **/
    public static genesis__Application_Note__c createDeclineApplicationNote(genesis__Applications__c applicationObj){
        genesis__Application_Note__c appNoteObj = new genesis__Application_Note__c();
        appNoteObj.genesis__Application__c=applicationObj.Id;
        appNoteObj.Status__c=ConstantValues.APPLICATION_NOTE_DECLINE_STATUS;
        appNoteObj.Updated_Loan_Amount__c =425.00;
        appNoteObj.Current_Loan_Amount__c=4575.98;
        appNoteObj.Current_Maturity_Date__c=Date.today().addMonths(3);
        appNoteObj.Modified_Maturity_Date__c =Date.today().addMonths(6);
        return appNoteObj;
    }

    
    /**
    * @description Creating Test Data for CFA Statement Code
    * @author Ayan Bhowmik | 02-22-2024 
    * @param dealerId 
    * @param certifiedLenderId 
    **/
    public static void createTestDataForCFAStatementCode(String dealerId, String certifiedLenderId) {
        List<genesis__Applications__c> applications = new List<genesis__Applications__c>{
                
                new genesis__Applications__c(
                    genesis__Loan_Number__c = '22222',
                    Loan_Id__c = '22222',
                    genesis__Maturity_Date__c = Date.valueOf('2024-03-15'),
                    genesis__Status__c = 'ACTIVE',
                    Statement_Code__c = 'COMMITMENT-OPT OUT',
                    Dealer_Name__c = dealerId,
                    Certified_Lender__c = certifiedLenderId
                ),
                new genesis__Applications__c(
                    genesis__Loan_Number__c = '33333',
                    Loan_Id__c = '33333',
                    genesis__Maturity_Date__c = Date.valueOf('2024-03-15'),
                    genesis__Status__c = 'ACTIVE',
                    Statement_Code__c = 'COMMITMENT STATEMENT',
                    Dealer_Name__c = dealerId,
                    Certified_Lender__c = certifiedLenderId
                ),
                new genesis__Applications__c(
                    genesis__Loan_Number__c = '44444',
                    Loan_Id__c = '44444',
                    genesis__Maturity_Date__c = Date.valueOf('2024-03-15'),
                    genesis__Status__c = 'ACTIVE',
                    Statement_Code__c = 'MONTHLY-OPT OUT',
                    Dealer_Name__c = dealerId,
                    Certified_Lender__c = certifiedLenderId
                ),
                new genesis__Applications__c(
                    genesis__Loan_Number__c = '55555',
                    Loan_Id__c = '55555',
                    genesis__Maturity_Date__c = Date.valueOf('2024-03-15'),
                    genesis__Status__c = 'ACTIVE',
                    Statement_Code__c = 'MONTHLY STATEMENT',
                    Dealer_Name__c = dealerId,
                    Certified_Lender__c = certifiedLenderId
                )
            };
    
        Database.upsert(applications, true);

        List<genesis__Application_Pricing_Detail__c> childApplications = new List<genesis__Application_Pricing_Detail__c> {
            new genesis__Application_Pricing_Detail__c(
                genesis__Application__c = applications[0].Id,
                genesis__Enabled_Flag__c = true
            ),

            new genesis__Application_Pricing_Detail__c(
                genesis__Application__c = applications[0].Id,
                genesis__Enabled_Flag__c = true
            ),

            new genesis__Application_Pricing_Detail__c(
                genesis__Application__c = applications[1].Id,
                genesis__Enabled_Flag__c = true
            ),

            new genesis__Application_Pricing_Detail__c(
                genesis__Application__c = applications[2].Id,
                genesis__Enabled_Flag__c = true
            )
        };

        Database.upsert(childApplications, true);
    }
    /**
    * @description Creating Test Data for Landus Statement Code
    * @author Ayan Bhowmik | 02-22-2024 
    * @param dealerId 
    * @param certifiedLenderId 
    **/
    public static void createTestDataForLandusStatementCode(String dealerId, String certifiedLenderId) {
        List<genesis__Applications__c> applications = new List<genesis__Applications__c>{
                
                new genesis__Applications__c(
                    genesis__Loan_Number__c = '22222',
                    Loan_Id__c = '22222',
                    genesis__Maturity_Date__c = Date.valueOf('2024-03-15'),
                    genesis__Status__c = 'ACTIVE',
                    Statement_Code__c = '102555-LANDUS-OPT OUT',
                    Dealer_Name__c = dealerId,
                    Certified_Lender__c = certifiedLenderId
                ),
                new genesis__Applications__c(
                    genesis__Loan_Number__c = '33333',
                    Loan_Id__c = '33333',
                    genesis__Maturity_Date__c = Date.valueOf('2024-03-15'),
                    genesis__Status__c = 'ACTIVE',
                    Statement_Code__c = '102555-LANDUS',
                    Dealer_Name__c = dealerId,
                    Certified_Lender__c = certifiedLenderId
                ),
                new genesis__Applications__c(
                    genesis__Loan_Number__c = '44444',
                    Loan_Id__c = '44444',
                    genesis__Maturity_Date__c = Date.valueOf('2024-03-15'),
                    genesis__Status__c = 'ACTIVE',
                    Statement_Code__c = '1',
                    Dealer_Name__c = dealerId,
                    Certified_Lender__c = certifiedLenderId
                ),
                new genesis__Applications__c(
                    genesis__Loan_Number__c = '55555',
                    Loan_Id__c = '55555',
                    genesis__Maturity_Date__c = Date.valueOf('2024-03-15'),
                    genesis__Status__c = 'ACTIVE',
                    Statement_Code__c = '6',
                    Dealer_Name__c = dealerId,
                    Certified_Lender__c = certifiedLenderId
                )
            };
    
        Database.upsert(applications, true);

        List<genesis__Application_Pricing_Detail__c> childApplications = new List<genesis__Application_Pricing_Detail__c> {
            new genesis__Application_Pricing_Detail__c(
                genesis__Application__c = applications[0].Id,
                genesis__Enabled_Flag__c = true
            ),

            new genesis__Application_Pricing_Detail__c(
                genesis__Application__c = applications[0].Id,
                genesis__Enabled_Flag__c = true
            ),

            new genesis__Application_Pricing_Detail__c(
                genesis__Application__c = applications[1].Id,
                genesis__Enabled_Flag__c = true
            )
        };

        Database.upsert(childApplications, true);
    }
    /**
    * @description Creating Test Data for Growmark Statement Code
    * @author Ayan Bhowmik | 02-22-2024 
    * @param dealerId 
    * @param certifiedLenderId 
    **/
    public static void createTestDataForGrowmarkStatementCode(String dealerId, String certifiedLenderId) {
        List<genesis__Applications__c> applications = new List<genesis__Applications__c>{
                
                new genesis__Applications__c(
                    genesis__Loan_Number__c = '22222',
                    Loan_Id__c = '22222',
                    genesis__Maturity_Date__c = Date.valueOf('2024-03-15'),
                    genesis__Status__c = 'ACTIVE',
                    Statement_Code__c = 'COMMITMENT-GROWMARK',
                    Dealer_Name__c = dealerId,
                    Certified_Lender__c = certifiedLenderId
                ),
                new genesis__Applications__c(
                    genesis__Loan_Number__c = '33333',
                    Loan_Id__c = '33333',
                    genesis__Maturity_Date__c = Date.valueOf('2024-03-15'),
                    genesis__Status__c = 'ACTIVE',
                    Statement_Code__c = 'MONTHLY STATEMENT-GMK',
                    Dealer_Name__c = dealerId,
                    Certified_Lender__c = certifiedLenderId
                )
            };
    
        Database.upsert(applications, true);

        List<genesis__Application_Pricing_Detail__c> childApplications = new List<genesis__Application_Pricing_Detail__c> {
            new genesis__Application_Pricing_Detail__c(
                genesis__Application__c = applications[0].Id,
                genesis__Enabled_Flag__c = true
            ),

            new genesis__Application_Pricing_Detail__c(
                genesis__Application__c = applications[1].Id,
                genesis__Enabled_Flag__c = true
            )
        };

        Database.upsert(childApplications, true);
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 05-06-2024 
    * @param userName 
    * @return User 
    **/
    public static User createAdminUser(String userName) {

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

        return new User(
                    Alias = 'newUser', 
                    Email=userName,
                    EmailEncodingKey='UTF-8',
                    LastName='Testing', 
                    LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US',
                    ProfileId = adminProfile.Id, 
                    // ContactId = contactId,
                    TimeZoneSidKey='America/Los_Angeles', 
                    UserName=userName,
                    User_Number__c = 11223344
                );
    }

    
    /**
    * @description 
    * @author Tuhin Bhunia | 05-06-2024 
    * @param dealerId 
    * @return List<genesis__Rate_Card_Setup_Detail__c> 
    **/
    public static List<genesis__Rate_Card_Setup_Detail__c> createTestDataForCFAMyProgram(String dealerId) {

        Integer month = System.today().month();
        genesis__Rate_Card_Setup_Header__c rateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeader.Name = 'CFA My Program - 110';
        // rateCardHeader.Crop_Year__c = '2023';
        if(month >= 6){
            rateCardHeader.Crop_Year__c = String.valueOf(System.today().addYears(1).year());
        } else {
            rateCardHeader.Crop_Year__c = String.valueOf(System.today().year());
        }
        rateCardHeader.FS_Index_Rate__c = 8.75;
        rateCardHeader.CFA_Advantage_Rate__c = 11.5;
        rateCardHeader.Closing_Fee__c = 200;
        rateCardHeader.Payer_of_Loan_Closing_Fee__c = 'Grower';
        rateCardHeader.Loan_Fee_Advanced_On__c = 'A';
        rateCardHeader.Dealer_Participate_on_Closing_Fee__c = 'No';
        rateCardHeader.Account__c = dealerId;
        rateCardHeader.genesis__Start_Date__c = System.today();
        rateCardHeader.genesis__End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        rateCardHeader.genesis__Transaction_Date__c = System.today();

        Database.insert(rateCardHeader, true);

        clcommon__CL_Product__c objProductToAssociate = [SELECT Id, 
                                                                Name, 
                                                                RecordType.Name, 
                                                                clcommon__Product_Name__c, 
                                                                clcommon__Pricing_Method__c 
                                                        FROM clcommon__CL_Product__c 
                                                        WHERE RecordType.Name = :PortalConstants.LOAN_STRING 
                                                            AND clcommon__Product_Name__c =:PortalConstants.SIMPLIFY_TYPE 
                                                        LIMIT 1];
                                                        
        genesis__Product_Rate_Card_Association__c objRateToProductAssoc = new genesis__Product_Rate_Card_Association__c();
        objRateToProductAssoc.genesis__CL_Product__c = objProductToAssociate.Id;
        objRateToProductAssoc.genesis__Rate_Card_Setup__c = rateCardHeader.Id;
        Database.upsert(objRateToProductAssoc, true);

        genesis__Additional_Determining_Factor__c additionalFactor = new genesis__Additional_Determining_Factor__c();
        additionalFactor = TestClassHelper.createAdditionalFactor(rateCardHeader);
        
        //Additional Factor for dealer check
        genesis__Additional_Determining_Factor__c additionalFactorDealer = new genesis__Additional_Determining_Factor__c();
        additionalFactorDealer = TestClassHelper.createAdditionalFactorDealer(rateCardHeader);

        genesis__Rate_Card_Setup_Detail__c noteRateAA = new genesis__Rate_Card_Setup_Detail__c();
        noteRateAA.Start_Date__c = System.today();
        noteRateAA.End_Date__c = System.today().addMonths(3).toStartOfMonth().addDays(-1);
        noteRateAA.Participation_Percentage_Dealer_Subsidy__c = 0.75;
        noteRateAA.Participation_Percentage_Dealer__c = 0;
        noteRateAA.Participation_Percentage_CFA__c = 0.75;
        noteRateAA.genesis__Interest_Rate__c = 10;
        noteRateAA.Interest_Rate_Type__c = 'Fixed';
        noteRateAA.Description__c = 'Note Rate';
        noteRateAA.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        noteRateAA.Special_Term_Order__c = 1;
        noteRateAA.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        genesis__Rate_Card_Setup_Detail__c noteRateAB = new genesis__Rate_Card_Setup_Detail__c();
        noteRateAB.Start_Date__c = System.today().addMonths(3).toStartOfMonth();
        noteRateAB.End_Date__c = System.today().addMonths(6).toStartOfMonth().addDays(-1);
        noteRateAB.Participation_Percentage_Dealer_Subsidy__c = 0;
        noteRateAB.Participation_Percentage_Dealer__c = 0.5;
        noteRateAB.Participation_Percentage_CFA__c = 0;
        noteRateAB.genesis__Interest_Rate__c = 12;
        noteRateAB.Interest_Rate_Type__c = 'Variable';
        noteRateAB.Description__c = 'Note Rate';
        noteRateAB.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        noteRateAB.Special_Term_Order__c = 1;
        noteRateAB.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        genesis__Rate_Card_Setup_Detail__c noteRateAC = new genesis__Rate_Card_Setup_Detail__c();
        noteRateAC.Start_Date__c = System.today().addMonths(6).toStartOfMonth();
        noteRateAC.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        noteRateAC.Participation_Percentage_Dealer_Subsidy__c = 2;
        noteRateAC.Participation_Percentage_Dealer__c = 0;
        noteRateAC.Participation_Percentage_CFA__c = 1.5;
        noteRateAC.genesis__Interest_Rate__c = 8;
        noteRateAC.Interest_Rate_Type__c = 'Fixed';
        noteRateAC.Description__c = 'Note Rate';
        noteRateAC.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        noteRateAC.Special_Term_Order__c = 1;
        noteRateAC.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';



        genesis__Rate_Card_Setup_Detail__c specialTermBA = new genesis__Rate_Card_Setup_Detail__c();
        specialTermBA.Start_Date__c = System.today();
        specialTermBA.End_Date__c = System.today().addMonths(3).toStartOfMonth().addDays(-1);
        specialTermBA.Participation_Percentage_Dealer_Subsidy__c = 2;
        specialTermBA.Participation_Percentage_Dealer__c = 0;
        specialTermBA.Participation_Percentage_CFA__c = 1.5;
        specialTermBA.genesis__Interest_Rate__c = 8;
        specialTermBA.Interest_Rate_Type__c = 'Fixed';
        specialTermBA.Description__c = 'Seeds';
        specialTermBA.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        specialTermBA.Special_Term_Order__c = 1;
        specialTermBA.Special_Term_Reference__c = 'Special Term Sub-Tranche (B)';

        genesis__Rate_Card_Setup_Detail__c specialTermBB = new genesis__Rate_Card_Setup_Detail__c();
        specialTermBB.Start_Date__c = System.today().addMonths(3).toStartOfMonth();
        specialTermBB.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermBB.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermBB.Participation_Percentage_Dealer__c = 0.5;
        specialTermBB.Participation_Percentage_CFA__c = 0;
        specialTermBB.genesis__Interest_Rate__c = 12;
        specialTermBB.Interest_Rate_Type__c = 'Variable';
        specialTermBB.Description__c = 'Seeds';
        specialTermBB.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        specialTermBB.Special_Term_Order__c = 2;
        specialTermBB.Special_Term_Reference__c = 'Special Term Sub-Tranche (B)';

        return new List<genesis__Rate_Card_Setup_Detail__c>{noteRateAA, noteRateAB, noteRateAC, specialTermBA, specialTermBB};
        
    }

    
    /**
    * @description 
    * @author Tuhin Bhunia | 05-07-2024 
    * @param dealerId 
    * @return List<genesis__Rate_Card_Setup_Detail__c> 
    **/
    public static List<genesis__Rate_Card_Setup_Detail__c> createSingleChildLoanFlexRate(String dealerId) {

        Integer month = System.today().month();
        genesis__Rate_Card_Setup_Header__c rateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeader.Name = 'Test Flex Rate Program';
        // rateCardHeader.Crop_Year__c = '2023';
        if(month >= 6){
            rateCardHeader.Crop_Year__c = String.valueOf(System.today().addYears(1).year());
        } else {
            rateCardHeader.Crop_Year__c = String.valueOf(System.today().year());
        }
        rateCardHeader.FS_Index_Rate__c = 8.75;
        rateCardHeader.CFA_Advantage_Rate__c = 11.5;
        rateCardHeader.Closing_Fee__c = 200;
        rateCardHeader.Payer_of_Loan_Closing_Fee__c = 'Grower';
        rateCardHeader.Loan_Fee_Advanced_On__c = 'A';
        rateCardHeader.Dealer_Participate_on_Closing_Fee__c = 'No';
        rateCardHeader.Account__c = dealerId;
        rateCardHeader.genesis__Start_Date__c = System.today();
        rateCardHeader.genesis__End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        rateCardHeader.genesis__Transaction_Date__c = System.today();

        Database.insert(rateCardHeader, true);

        clcommon__CL_Product__c objProductToAssociate = [SELECT Id, 
                                                                Name, 
                                                                RecordType.Name, 
                                                                clcommon__Product_Name__c, 
                                                                clcommon__Pricing_Method__c 
                                                        FROM clcommon__CL_Product__c 
                                                        WHERE RecordType.Name = :PortalConstants.LOAN_STRING 
                                                            AND clcommon__Product_Name__c =:PortalConstants.SIMPLIFY_TYPE 
                                                        LIMIT 1];
                                                        
        genesis__Product_Rate_Card_Association__c objRateToProductAssoc = new genesis__Product_Rate_Card_Association__c();
        objRateToProductAssoc.genesis__CL_Product__c = objProductToAssociate.Id;
        objRateToProductAssoc.genesis__Rate_Card_Setup__c = rateCardHeader.Id;
        Database.Insert(objRateToProductAssoc, true);

        genesis__Additional_Determining_Factor__c additionalFactor = new genesis__Additional_Determining_Factor__c();
        additionalFactor = TestClassHelper.createAdditionalFactor(rateCardHeader);
        
        //Additional Factor for dealer check
        genesis__Additional_Determining_Factor__c additionalFactorDealer = new genesis__Additional_Determining_Factor__c();
        additionalFactorDealer = TestClassHelper.createAdditionalFactorDealer(rateCardHeader);

        genesis__Rate_Card_Setup_Detail__c noteRateAA = new genesis__Rate_Card_Setup_Detail__c();
        noteRateAA.Start_Date__c = System.today();
        noteRateAA.End_Date__c = System.today().addMonths(3).toStartOfMonth().addDays(-1);
        noteRateAA.Participation_Percentage_Dealer_Subsidy__c = 0.75;
        noteRateAA.Participation_Percentage_Dealer__c = 0;
        noteRateAA.Participation_Percentage_CFA__c = 0.75;
        noteRateAA.genesis__Interest_Rate__c = 10;
        noteRateAA.Interest_Rate_Type__c = 'Fixed';
        noteRateAA.Description__c = 'Note Rate';
        noteRateAA.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        noteRateAA.Special_Term_Order__c = 1;
        noteRateAA.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        genesis__Rate_Card_Setup_Detail__c noteRateAB = new genesis__Rate_Card_Setup_Detail__c();
        noteRateAB.Start_Date__c = System.today().addMonths(3).toStartOfMonth();
        noteRateAB.End_Date__c = System.today().addMonths(6).toStartOfMonth().addDays(-1);
        noteRateAB.Participation_Percentage_Dealer_Subsidy__c = 0;
        noteRateAB.Participation_Percentage_Dealer__c = 0.5;
        noteRateAB.Participation_Percentage_CFA__c = 0;
        noteRateAB.genesis__Interest_Rate__c = 12;
        noteRateAB.Interest_Rate_Type__c = 'Variable';
        noteRateAB.Description__c = 'Note Rate';
        noteRateAB.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        noteRateAB.Special_Term_Order__c = 1;
        noteRateAB.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        genesis__Rate_Card_Setup_Detail__c noteRateAC = new genesis__Rate_Card_Setup_Detail__c();
        noteRateAC.Start_Date__c = System.today().addMonths(6).toStartOfMonth();
        noteRateAC.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        noteRateAC.Participation_Percentage_Dealer_Subsidy__c = 2;
        noteRateAC.Participation_Percentage_Dealer__c = 0;
        noteRateAC.Participation_Percentage_CFA__c = 1.5;
        noteRateAC.genesis__Interest_Rate__c = 8;
        noteRateAC.Interest_Rate_Type__c = 'Fixed';
        noteRateAC.Description__c = 'Note Rate';
        noteRateAC.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        noteRateAC.Special_Term_Order__c = 1;
        noteRateAC.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        return new List<genesis__Rate_Card_Setup_Detail__c>{noteRateAA, noteRateAB, noteRateAC};
        
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 05-06-2024 
    * @param creditRatingName 
    * @return genesis__Credit_Rating_Matrix__c 
    **/
    public static genesis__Credit_Rating_Matrix__c getCreditRatingMatrix(String creditRatingName){
        return new genesis__Credit_Rating_Matrix__c(Name = creditRatingName);
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 05-06-2024 
    * @param application 
    * @return List<genesis__Application_Pricing_Detail__c> 
    **/
    public static List<genesis__Application_Pricing_Detail__c> createSeedDataForPricingDetail(genesis__Applications__c application) {
        String specialSubTrancheString = 'Special Term Sub-Tranche (';
        List<genesis__Rate_Card_Setup_Header__c> rateCardHeaders = [
                SELECT Id
                FROM genesis__Rate_Card_Setup_Header__c
                WHERE Id = :application.My_Program__c
            ];

        if (rateCardHeaders.size() == 0) {
            throw new CustomException('No my program found for this test application.');
        }

        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetails = [
                SELECT Id,
                       genesis__Enabled_Flag__c,
                       Start_Date__c,
                       End_Date__c,
                       genesis__Interest_Rate__c,
                       Participation_Percentage_Dealer_Subsidy__c,
                       Participation_Percentage_Dealer__c,
                       Special_Term_Reference__c
                FROM genesis__Rate_Card_Setup_Detail__c
                WHERE genesis__Rate_Card_Setup_Header__c = :rateCardHeaders[0].Id
            ];

        List<genesis__Application_Pricing_Detail__c> pricings = new List<genesis__Application_Pricing_Detail__c>();
        
        for (genesis__Rate_Card_Setup_Detail__c rateCardDetail : rateCardDetails) {
            genesis__Application_Pricing_Detail__c pricing = new genesis__Application_Pricing_Detail__c(
                genesis__Application__c=application.Id,
                genesis__Enabled_Flag__c=true,
                genesis__Rate_Card_Setup_Detail__c=rateCardDetail.Id,
                Loan_Number__c = application.genesis__Loan_Number__c + ConstantValues.HYPHEN_STRING +  String.valueOf(rateCardDetail.Special_Term_Reference__c).substringBetween(specialSubTrancheString,')')
            );
            pricings.add(pricing);
        }
        return pricings;
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 05-07-2024 
    * @param application 
    * @return List<genesis__Application_Pricing_Detail__c> 
    **/
    public static List<genesis__Application_Pricing_Detail__c> createSingleChildLoanPricingDetail(genesis__Applications__c application) {

        List<genesis__Rate_Card_Setup_Header__c> rateCardHeaders = [
                SELECT Id
                FROM genesis__Rate_Card_Setup_Header__c
                WHERE Id = :application.My_Program__c
            ];

        if (rateCardHeaders.size() == 0) {
            throw new CustomException('No my program found for this test application.');
        }

        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetails = [
                SELECT Id,
                       genesis__Enabled_Flag__c,
                       Start_Date__c,
                       End_Date__c,
                       genesis__Interest_Rate__c,
                       Participation_Percentage_Dealer_Subsidy__c,
                       Participation_Percentage_Dealer__c,
                       Special_Term_Reference__c
                FROM genesis__Rate_Card_Setup_Detail__c
                WHERE genesis__Rate_Card_Setup_Header__c = :rateCardHeaders[0].Id
            ];

        List<genesis__Application_Pricing_Detail__c> pricings = new List<genesis__Application_Pricing_Detail__c>();
        
        for (genesis__Rate_Card_Setup_Detail__c rateCardDetail : rateCardDetails) {
            genesis__Application_Pricing_Detail__c pricing = new genesis__Application_Pricing_Detail__c(
                genesis__Application__c=application.Id,
                genesis__Enabled_Flag__c=true,
                genesis__Rate_Card_Setup_Detail__c=rateCardDetail.Id
            );

            if (rateCardDetail.Special_Term_Reference__c == 'Special Term Sub-Tranche (A)') {
                pricing.Loan_Number__c = application.genesis__Loan_Number__c;
            }
            pricings.add(pricing);
        }
        return pricings;
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 05-07-2024 
    * @param myProgram 
    * @param application
    * @return List<genesis__Application_Pricing_Detail__c> 
    **/
    public static List<genesis__Application_Pricing_Detail__c> createPricingDetailsForMultipleTranche(genesis__Rate_Card_Setup_Header__c myProgram, genesis__Applications__c application){
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetails = [
                SELECT Id,
                       genesis__Enabled_Flag__c,
                       Start_Date__c,
                       End_Date__c,
                       genesis__Interest_Rate__c,
                       Participation_Percentage_Dealer_Subsidy__c,
                       Participation_Percentage_Dealer__c,
                       Special_Term_Reference__c
                FROM genesis__Rate_Card_Setup_Detail__c
                WHERE genesis__Rate_Card_Setup_Header__c = :myProgram.Id
            ];

        List<genesis__Application_Pricing_Detail__c> pricings = new List<genesis__Application_Pricing_Detail__c>();
        
        for (genesis__Rate_Card_Setup_Detail__c rateCardDetail : rateCardDetails) {
            genesis__Application_Pricing_Detail__c pricing = new genesis__Application_Pricing_Detail__c(
                genesis__Application__c=application.Id,
                genesis__Enabled_Flag__c=true,
                genesis__Rate_Card_Setup_Detail__c=rateCardDetail.Id
            );

            if (rateCardDetail.Special_Term_Reference__c == 'Special Term Sub-Tranche (A)') {
                pricing.Loan_Number__c = application.genesis__Loan_Number__c + '-A';
            }

            if (rateCardDetail.Special_Term_Reference__c == 'Special Term Sub-Tranche (B)') {
                pricing.Loan_Number__c = application.genesis__Loan_Number__c + '-B';
            }

            if (rateCardDetail.Special_Term_Reference__c == 'Special Term Sub-Tranche (C)') {
                pricing.Loan_Number__c = application.genesis__Loan_Number__c + '-C';
            }

            if (rateCardDetail.Special_Term_Reference__c == 'Special Term Sub-Tranche (D)') {
                pricing.Loan_Number__c = application.genesis__Loan_Number__c + '-D';
            }

            if (rateCardDetail.Special_Term_Reference__c == 'Special Term Sub-Tranche (E)') {
                pricing.Loan_Number__c = application.genesis__Loan_Number__c + '-E';
            }
            pricings.add(pricing);
        }
        return pricings;
    }

    /**
    * @description - Method to create Invoice
    * @author Sk Minsar | 12-09-2024 
    * @param applicationId 
    * @return clcommon__Consolidated_Invoice__c 
    **/
    public static clcommon__Consolidated_Invoice__c createInvoice(String applicationId){
        clcommon__Consolidated_Invoice__c invoiceObj = new clcommon__Consolidated_Invoice__c();
        invoiceObj.Application__c = applicationId;
        return invoiceObj;
    }
    
    /**
    * @description - Method to create Invoice
    * @author Sk Minsar | 12-09-2024 
    * @param applicationId 
    * @param paymentMode 
    * @return clcommon__Consolidated_Invoice__c 
    **/
    public static clcommon__Consolidated_Invoice__c createInvoice(String applicationId, Id paymentMode){
        clcommon__Consolidated_Invoice__c invoiceObj = new clcommon__Consolidated_Invoice__c();
        invoiceObj.Application__c = applicationId;
        invoiceObj.Payment_Mode__c = paymentMode;
        invoiceObj.Total_Amount__c = 1000.01;
        invoiceObj.Total_Principal__c = 2000.00;
        invoiceObj.Total_Interest__c = 50.00;
        invoiceObj.Total_Fees__c = 20.00;
        invoiceObj.Comment__c = 'Test comment';
        return invoiceObj;
    }

    
    /**
    * @description this method helps to create a new dealer applicant relationship
    * @author Rakesh Saraf | 11-24-2024
    * @param borrowerContactObj 
    * @param dealerAccountId 
    * @return Dealer_Applicant_Relationship__c 
    **/
    public static Dealer_Applicant_Relationship__c createDealerApplicantRelationship(Contact borrowerContactObj,Id dealerAccountId){
        Dealer_Applicant_Relationship__c dealerGrowerRelation = new Dealer_Applicant_Relationship__c();
        dealerGrowerRelation.Applicant__c = borrowerContactObj.accountId;
        dealerGrowerRelation.Applicant_Contact__c= borrowerContactObj.id;
        dealerGrowerRelation.Dealer__c=dealerAccountId;
        return dealerGrowerRelation;
    }

   
    /**
    * @description Creating Dealer Account With Coop Type CFA
    * @author Rakesh Saraf | 11-25-2024 
    * @param businessInfoId 
    * @param partnerProgramId 
    * @return Account 
    **/
    public static Account createDealerAccount(Id businessInfoId, Id partnerProgramId) {
        Account dealerAccountObj = new Account();
        dealerAccountObj.Name = 'Kisan Loan';
        dealerAccountObj.genesis__Business_Information__c = businessInfoId;
        dealerAccountObj.Phone = '1234567890';
        dealerAccountObj.BillingStreet = '2423 6th Avenue';
        dealerAccountObj.BillingCity = 'Frankenmouth';
        dealerAccountObj.BillingState = 'WA';
        dealerAccountObj.BillingPostalCode = '61232';
        dealerAccountObj.CIF_Number__c = '091284';
        dealerAccountObj.Tier__c = 'Gold';
        dealerAccountObj.Enable_ERP_Id__c = true;
        dealerAccountObj.Is_Required_ERP_Id__c = true;
        dealerAccountObj.CFA_Partner_Program__c = partnerProgramId;
        dealerAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        dealerAccountObj.Coop_Type__c = 'CFA';
        return dealerAccountObj;
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 11-27-2024 
    * @param myProgram 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    public static genesis__Rate_Card_Setup_Detail__c createRateCardSetupDetailTwo(genesis__Rate_Card_Setup_Header__c myProgram){
        genesis__Rate_Card_Setup_Detail__c rateCardDetailObj = new genesis__Rate_Card_Setup_Detail__c();
        rateCardDetailObj.genesis__Rate_Card_Setup_Header__c = myProgram.Id;
        rateCardDetailObj.Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account';
        rateCardDetailObj.Participation_Percentage_CFA__c = 5.5;
        rateCardDetailObj.Participation_Percentage_Dealer__c = 0;
        rateCardDetailObj.Participation_Percentage_Dealer_Subsidy__c = 3;
        rateCardDetailObj.Interest_Rate_Type__c = 'Fixed';
        rateCardDetailObj.Start_Date__c = Date.newInstance(2022, 10, 01);
        rateCardDetailObj.End_Date__c = Date.newInstance(2022, 12, 31);
        rateCardDetailObj.genesis__Interest_Rate__c = 2.5;
        return rateCardDetailObj;
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 11-27-2024 
    * @param applicationId 
    * @param pricingDetailId 
    * @return genesis__Application_Fee_Payment__c 
    **/
    public static genesis__Application_Fee_Payment__c createApplicationFeePaymentSubsidy(Id applicationId, Id pricingDetailId) {
        genesis__Application_Fee_Payment__c applicationFeePaymentObj = new genesis__Application_Fee_Payment__c();
        applicationFeePaymentObj.genesis__Application__c = applicationId;
        applicationFeePaymentObj.Pricing_Detail__c = pricingDetailId;
        applicationFeePaymentObj.Year__c = System.today().year();
        applicationFeePaymentObj.Month__c = System.today().month();
        applicationFeePaymentObj.Record_Type__c = 'PARTICIPANT DAILY';
        return applicationFeePaymentObj;
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 11-27-2024 
    * @param paramMap 
    * @return genesis__Funding_Transaction__c 
    **/
    public static genesis__Funding_Transaction__c createDraftFundingTransaction(Map<String, Id> paramMap) {
        genesis__Funding_Transaction__c draftFundingTransactObj = new genesis__Funding_Transaction__c();
        draftFundingTransactObj.genesis__Application__c = paramMap.get('applicationId');
        draftFundingTransactObj.Pricing_Detail__c = paramMap.get('pricingDetailId');
        draftFundingTransactObj.genesis__Amount__c = 1000;
        draftFundingTransactObj.genesis__Cleared__c = true;
        draftFundingTransactObj.Grower_Name__c = 'Test Grower 1';
        draftFundingTransactObj.genesis__Payment_Mode__c = paramMap.get('paymentModeId');
        return draftFundingTransactObj;
    }

    /**
    * @description Creating Enabled Rate Card Setup Header for Previous Year
    * @author Ayan Bhowmik | 02-22-2024 
    * @param accountObj 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    public static genesis__Rate_Card_Setup_Header__c createPrevYearRateCardHeader(Account accountObj){
        Integer month;
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderObj.Name = 'My Test Program 99';
        rateCardHeaderObj.genesis__Product_Type__c = PortalConstants.PRODUCT_TYPE_FOR_MY_PROGRAM;
        rateCardHeaderObj.Account__c = accountObj.Id;
        rateCardHeaderObj.CFA_Advantage_Rate__c = 7;
        rateCardHeaderObj.genesis__Description__c = 'This rate card calculates an interest for seed purpose oriented loans';
        rateCardHeaderObj.Closing_Fee__c = 200;
        rateCardHeaderObj.genesis__Start_Date__c = Date.newInstance(2022, 10, 01);
        rateCardHeaderObj.genesis__Transaction_Date__c = System.today();
        rateCardHeaderObj.genesis__End_Date__c = Date.newInstance(2022, 12, 01);
        rateCardHeaderObj.Payer_of_Loan_Closing_Fee__c = 'Grower';
        rateCardHeaderObj.Loan_Fee_Advanced_On__c = 'A';
        rateCardHeaderObj.Dealer_Participate_on_Closing_Fee__c = 'Yes';
        rateCardHeaderObj.Portion_of_Fee_to_Cover__c = 100;
        rateCardHeaderObj.genesis__Enabled_Flag__c = true;
        if(month >= 6){
            rateCardHeaderObj.Crop_Year__c = String.valueOf(System.today().year());
        } else {
            rateCardHeaderObj.Crop_Year__c = String.valueOf(System.today().year() - 1);
        }
        return rateCardHeaderObj;
    }

    /**
    * @description Creating Test Data for Application Fee Payment List
    * @author Ayan Bhowmik | 02-21-2024 
    * @param applicationId 
    * @param pricingDetail 
    * @return List<genesis__Application_Fee_Payment__c> 
    **/
    public static List<genesis__Application_Fee_Payment__c> createApplicationFeePaymentList (String applicationId, String pricingDetail){
        List<genesis__Application_Fee_Payment__c> applicationFeePaymentList = new List<genesis__Application_Fee_Payment__c>();

        Integer year = System.today().year();
        Integer month = Integer.valueOf(System.today().month());
        applicationFeePaymentList.add(new genesis__Application_Fee_Payment__c(
                                                    External_Id__c = 'weqasweqwe1124',
                                                    Interest_Earned__c = 10,
                                                    Interest_Paid__c = 10,
                                                    Dealer_Monthly_Interest__c = 10,
                                                    Past_Due_Balance__c = 10,
                                                    Month__c = month,
                                                    Year__c = year,
                                                    Pricing_Detail__c = pricingDetail,
                                                    genesis__Application__c = applicationId,
                                                    Record_Type__c = 'ACTIVE LOAN DAILY'
                                                ));

        applicationFeePaymentList.add(new genesis__Application_Fee_Payment__c(
                                                    External_Id__c = 'weqasweqwde1124',
                                                    Interest_Earned__c = 130,
                                                    Interest_Paid__c = 40,
                                                    Dealer_Monthly_Interest__c = 10,
                                                    Past_Due_Balance__c = 10,
                                                    Month__c = 0,
                                                    Year__c = year,
                                                    Pricing_Detail__c = pricingDetail,
                                                    genesis__Application__c = applicationId,
                                                    Record_Type__c = 'ACTIVE LOAN DAILY'
                                                ));
        

        applicationFeePaymentList.add(new genesis__Application_Fee_Payment__c(
                                                    External_Id__c = 'weqweqwsde1124',
                                                    Interest_Earned__c = 250,
                                                    Interest_Paid__c = 100,
                                                    Dealer_Monthly_Interest__c = 50,
                                                    Past_Due_Balance__c = 10,
                                                    Month__c = month,
                                                    Year__c = year,
                                                    Pricing_Detail__c = pricingDetail,
                                                    genesis__Application__c = applicationId,
                                                    Record_Type__c = 'PARTICIPANT DAILY'
                                                ));

        applicationFeePaymentList.add(new genesis__Application_Fee_Payment__c(
                                                    External_Id__c = 'arhweuwsde1124',
                                                    Interest_Earned__c = 350,
                                                    Interest_Paid__c = 130,
                                                    Dealer_Monthly_Interest__c = 0,
                                                    Past_Due_Balance__c = 10,
                                                    Month__c = month,
                                                    Year__c = year,
                                                    Pricing_Detail__c = pricingDetail,
                                                    genesis__Application__c = applicationId,
                                                    Record_Type__c = 'PARTICIPANT DAILY'
                                                ));
        
        applicationFeePaymentList.add(new genesis__Application_Fee_Payment__c(
                                                    External_Id__c = 'weqwqeqwsde1124',
                                                    Interest_Earned__c = 550,
                                                    Interest_Paid__c = 255,
                                                    Dealer_Monthly_Interest__c = 20,
                                                    Past_Due_Balance__c = 10,
                                                    Month__c = 0,
                                                    Year__c = year,
                                                    Pricing_Detail__c = pricingDetail,
                                                    genesis__Application__c = applicationId,
                                                    Record_Type__c = 'PARTICIPANT DAILY'
                                                ));
        
        return applicationFeePaymentList;

    }

    /**
    * @description Create different funding transaction properties record
    * @author Kabir Pramanik | 01-02-2025 
    * @return Map<String, clcommon__Funding_Transactions_Properties__c> 
    **/
    public static Map<String, clcommon__Funding_Transactions_Properties__c> createFundingTransactionProperties() {
        Map<String, clcommon__Funding_Transactions_Properties__c> fundingTraxPropMap = new Map<String, clcommon__Funding_Transactions_Properties__c>{
            ConstantValues.ACH => new clcommon__Funding_Transactions_Properties__c(Name = ConstantValues.ACH + '-' + System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF), Payment_Mode__c = ConstantValues.ACH),
            ConstantValues.DRAFT => new clcommon__Funding_Transactions_Properties__c(Name = ConstantValues.DRAFT + '-' + System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF), Payment_Mode__c = ConstantValues.DRAFT),
            ConstantValues.PAYMENT => new clcommon__Funding_Transactions_Properties__c(Name = ConstantValues.PAYMENT + '-' + System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF), Payment_Mode__c = ConstantValues.PAYMENT),
            ConstantValues.MOBILE_DEPOSIT => new clcommon__Funding_Transactions_Properties__c(Name = ConstantValues.MOBILE_DEPOSIT + '-' + System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF), Payment_Mode__c = ConstantValues.MOBILE_DEPOSIT),
            ConstantValues.PRODUCT_RETURN => new clcommon__Funding_Transactions_Properties__c(Name = ConstantValues.PRODUCT_RETURN + '-' + System.now().addHours(ConstantValues.GMT_TO_CST_HOUR_DIFF), Payment_Mode__c = ConstantValues.PRODUCT_RETURN)
        };
        return fundingTraxPropMap;
    }

    /**
    * @description this method populates the details in the party of the application for individual(s)- Sole Prop
    * @author Rakesh Saraf | 01-02-2024  
    * @param partyObj 
    * @param dealerAccountId 
    * @return clcommon__Party__c 
    **/
    public static clcommon__Party__c insertIndividualPartyDetails(clcommon__Party__c partyObj,Id dealerAccountId){
        partyObj.Street__c = '02 MA Road';
        partyObj.City__c = 'NEWTOWN';
        partyObj.State__c = 'AL';
        partyObj.County__c = 'Rajarhat';
        partyObj.Postal_Code__c = '54321';
        partyObj.Mobile_Number__c = '1234567890';
        partyObj.Home_Number__c = '0987654321';
        partyObj.Work_Number__c = '5432123456';
        partyObj.Marital_Status__c = 'Married';
        partyObj.Suffix__c = 'Jr.';

        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList=[ SELECT ID 
                                                                        FROM Dealer_Applicant_Relationship__c 
                                                                        WHERE Dealer__c=:dealerAccountId 
                                                                        AND Applicant__c=:partyObj.clcommon__Account__c];
        if(dealerApplicantRelList.isEmpty()){
            Dealer_Applicant_Relationship__c dealerAppRelObj=new Dealer_Applicant_Relationship__c();
            dealerAppRelObj.Dealer__c=dealerAccountId;
            dealerAppRelObj.Applicant__c=partyObj.clcommon__Account__c;
            dealerAppRelObj.Applicant_Contact__c=partyObj.clcommon__Contact__c;
            Database.insert(dealerAppRelObj,true);
            dealerApplicantRelList.add(dealerAppRelObj);
        }

        partyObj.Dealer_Applicant_Relationship__c=dealerApplicantRelList[0].id;

        return partyObj;
    }

    /**
    * @description Creating floating rate index recoed
    * @author Kabir Pramanik | 01-09-2025 
    * @param paramMap 
    * @return clcommon__Floating_Rate_Index__c 
    **/
    public static clcommon__Floating_Rate_Index__c createFloatingRateIndex(Map<String, Object> paramMap){
        clcommon__Floating_Rate_Index__c floatingRateIndexObj = new clcommon__Floating_Rate_Index__c();
        floatingRateIndexObj.Name = String.valueOf(paramMap.get('Name'));
        floatingRateIndexObj.Base_Rate_Adjuster__c = (Decimal)paramMap.get('Base Rate Adjuster');
        floatingRateIndexObj.Base_Rate_Name__c = String.valueOf(paramMap.get('Base Rate Name'));
        floatingRateIndexObj.Current_Floating_Rate__c = (Decimal)paramMap.get('Current Floating Rate');
        floatingRateIndexObj.clcommon__Active__c = true;
        return floatingRateIndexObj;
    }

    /**
    * @description Creating floating rate record
    * @author Kabir Pramanik | 01-22-2025 
    * @param floatingRateIndexObj 
    * @return clcommon__Floating_Rate__c 
    **/
    public static clcommon__Floating_Rate__c createFloatingRate(clcommon__Floating_Rate_Index__c floatingRateIndexObj){
        clcommon__Floating_Rate__c floatingRateObj = new clcommon__Floating_Rate__c();
        floatingRateObj.clcommon__Floating_Rate_Index__c = floatingRateIndexObj.Id;
        floatingRateObj.clcommon__Rate__c = floatingRateIndexObj.Current_Floating_Rate__c;
        floatingRateObj.clcommon__Start_Date__c = System.today();
        return floatingRateObj;
    }

    /**
    * @description Creating a partner program  record
    * @author Kabir Pramanik | 01-09-2025 
    * @param floatingRateIndexObj 
    * @return CFA_Partner_Program__c 
    **/
    public static CFA_Partner_Program__c createPartnerProgram(clcommon__Floating_Rate_Index__c floatingRateIndexObj){
        CFA_Partner_Program__c partnerProgramObj = new CFA_Partner_Program__c();
        partnerProgramObj.Name = 'New Partner Program';
        partnerProgramObj.Short_Name__c = 'pro';
        partnerProgramObj.Allow_Auto_Booking__c = true;
        partnerProgramObj.Allow_Evergreen_Applications__c = true;
        partnerProgramObj.Allow_Field_Staff_Agents__c = true;
        partnerProgramObj.Allow_Growers_to_Initiate_Application__c	 = true;
        partnerProgramObj.Allow_Payment_Admin__c = true;
        partnerProgramObj.Allow_Sales_Agent_Admin__c = true;
        partnerProgramObj.Allow_Self_Register__c = true;
        partnerProgramObj.Dealer_Portal_Contact_Us__c = 'https://google.com';
        partnerProgramObj.Dealer_Portal_Primary_Color_Pallatte__c = '#000000';
        partnerProgramObj.Dealer_Portal_Secondary_Color_Pallatte__c = '#000001';
        partnerProgramObj.Dealer_Portal_Tertiary_Color_Pallatte__c = '#000002';
        partnerProgramObj.Dealer_Portal_Terms_Conditions__c = 'Test Dealer Portal Term & Condition';
        partnerProgramObj.Email_Address__c = 'new.partner.program@yopmail.com';
        partnerProgramObj.Fax__c = '1234567890';
        partnerProgramObj.Grower_Portal_Contact_Us__c = 'https://google.com';
        partnerProgramObj.Grower_Portal_Primary_Color_Pallatte__c = '#000004';
        partnerProgramObj.Grower_Portal_Secondary_Color_Pallatte__c = '#000005';
        partnerProgramObj.Grower_Portal_Tertiary_Color_Pallatte__c = '#000006';
        partnerProgramObj.Grower_Portal_Terms_Conditions__c = 'Test Grower Portal Term & Condition';
        partnerProgramObj.Loan_Closing_Fee__c = 200;
        partnerProgramObj.Mailing_Address__c = '12th Block Street';
        partnerProgramObj.Mailing_City__c = 'New Port';
        partnerProgramObj.Mailing_County__c = 'Kings';
        partnerProgramObj.Mailing_State__c = 'AL';
        partnerProgramObj.Mailing_Zip__c = '56890';
        partnerProgramObj.Mobile__c = '1234567890';
        partnerProgramObj.SSO_Available__c = true;
        partnerProgramObj.Statement_Code_Multi_Rate_Opt_In__c = 'COMMITMENT STATEMENT';
        partnerProgramObj.Statement_Code_Multi_Rate_Opt_Out__c = 'COMMITMENT-OPT OUT';
        partnerProgramObj.Statement_Code_Single_Rate_Opt_In__c = 'MONTHLY STATEMENT';
        partnerProgramObj.Statement_Code_Single_Rate_Opt_Out__c = 'MONTHLY-OPT OUT';
        partnerProgramObj.Toll_Free_Number__c = '1234567890';
        partnerProgramObj.Transaction_Code__c = 123;
        partnerProgramObj.Website_Link__c = 'https://google.com';
        partnerProgramObj.Base_Rate__c = floatingRateIndexObj.Id;
        partnerProgramObj.Dealer_Portal_Logo__c = 'cfaLogo';
        partnerProgramObj.NLS_User_Defined_Field__c = 'CFA';
        return partnerProgramObj;
    }

    /**
    * @description get the admin user
    * @author Kabir Pramanik | 01-12-2025 
    * @return User 
    **/
    public static User getAdminUser(){
        List<User> userList = [SELECT Id 
                            FROM User 
                            WHERE Profile.name = :ConstantValues.PROFILE_ADMIN
                            AND isActive = true LIMIT 1];
        if(userList.isEmpty()){
            return null;
        }
        return userList[0];
    }
    /**
    * @description Create Sales Agent Contact record
    * @author Kabir Pramanik | 01-13-2025 
    * @param accountId 
    * @return Contact 
    **/
    public static Contact createSalesAgentContact(Id accountId){
        Contact saContactObj=new Contact();
        saContactObj.FirstName='Tony';
        saContactObj.LastName='Stark';
        saContactObj.Email='tony.Stark@yopmail.com';
        saContactObj.Phone='98765453456';
        saContactObj.accountId = accountId;
        return saContactObj;
    }
    /**
    * @description Create Sales Agent User record
    * @author Kabir Pramanik | 01-13-2025 
    * @param saContactId 
    * @return User 
    **/
    public static User createSalesAgentUser(Id saContactId){
        List<Profile> saProfileList = [SELECT Id
                                        FROM Profile
                                        WHERE Name = 'Sales Agent'
                                        LIMIT 1];
        User saUserObj = new User();
        saUserObj.Alias = 'newUser';
        saUserObj.Email='cfanewus5er@yopmail.com';
        saUserObj.EmailEncodingKey='UTF-8';
        saUserObj.LastName='Testing';
        saUserObj.LanguageLocaleKey='en_US';
        saUserObj.LocaleSidKey='en_US';
        saUserObj.ProfileId = saProfileList[0].Id;
        saUserObj.ContactId = saContactId;
        saUserObj.TimeZoneSidKey='America/Los_Angeles';
        saUserObj.UserName='tony.stark@yopmail.com';
        return saUserObj;
    }
    
    /**
    * @description Creating Sole Prop Co-Borrower Account record
    * @author Kabir Pramanik | 01-15-2025 
    * @param entityObj 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createCoBorrowerAccount(clcommon__Legal_Entity__c entityObj, 
                                                            Id businessInfoId){  
        Account accountObj = new Account();
        accountObj.Name = 'Mike Johnson';
        accountObj.clcommon__Email__c = 'mike.johnson@yopmail.com';
        accountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        accountObj.genesis__Business_Information__c = businessInfoId;
        accountObj.BillingCity = 'Kolkata';
        accountObj.BillingState = 'WA';
        accountObj.Billing_County__c = 'fghu';
        accountObj.Work_Number__c = '098765678';
        return accountObj;
    }
    
    /**
    * @description Creating Co-Borrower Contact record
    * @author Kabir Pramanik | 01-15-2025 
    * @param objAccountId
    * @return Contact 
    **/
    public static Contact createCoBorrowerContact(Id objAccountId){
        Contact contactObj=new Contact();
        contactObj.FirstName='Mike';
        contactObj.LastName='Johnson';
        contactObj.Email='mike.johnson@yopmail.com';
        contactObj.Phone='8638473943';
        contactObj.MobilePhone = '739438473';
        contactObj.genesis__SSN__c = '982983834';
        contactObj.Confirm_SSN__c = '982983834';
        contactObj.accountId = objAccountId;
        contactObj.MailingCity = 'Mumbai';
        contactObj.MailingState = 'WA';
        contactObj.MailingStreet='Dombivali';
        contactObj.Mailing_County__c='county';
        contactObj.MailingPostalCode='67374';
        contactObj.Birthdate=System.today().addYears(-35);
        return contactObj;
    }

    /**
    * @description - This method is used to create a List of Current Crop Year Applications
    * @author Sk Minsar | 03-04-2025 
    * @param paramMap
    * @param noOfRecords
    * @return List<genesis__Applications__c>
    **/
    public static List<genesis__Applications__c> createCurrCropYearApplicationList(Map<String, Id> paramMap, Integer noOfRecords){
        List<genesis__Applications__c> currentCropYearAppList = new List<genesis__Applications__c>();
        for(Integer count = 0; count < noOfRecords; count++){
            genesis__Applications__c currentCropYearApp = createCurrCropYearApplication(paramMap);
            currentCropYearApp.genesis__Loan_Number__c = String.valueOf(Integer.valueOf(currentCropYearApp.genesis__Loan_Number__c) + count);
            currentCropYearApp.Loan_Id__c = String.valueOf(Integer.valueOf(currentCropYearApp.Loan_Id__c) + ConstantValues.TEN_VALUE * count );
            currentCropYearAppList.add(currentCropYearApp);
        }
        return currentCropYearAppList;
    }

    /**
    * @description - Fetching user by profile
    * @author Sk Minsar | 03-05-2025 
    * @param profileName 
    * @return List<User> 
    **/
    public static List<User> getUserByProfileName(String profileName){
        List<User> userList = [SELECT Id 
                            FROM User 
                            WHERE Profile.name =: profileName
                            AND isActive =: ConstantValues.TRUE_VALUE LIMIT 1];

        return userList;
    }

    /**
    * @description - This method is used to create user by profile name
    * @author Sk Minsar | 03-10-2025 
    * @param profileName 
    * @param userName 
    * @return List<User> 
    **/
    public static List<User> createUserByProfileName(String profileName, String userName) {

        List<Profile> profileList = [SELECT Id FROM Profile WHERE Name =: profileName LIMIT 1];

        return new List<User>{ 
            new User (
                        Alias = 'newUser', 
                        Email=userName,
                        EmailEncodingKey='UTF-8',
                        LastName='Testing', 
                        LanguageLocaleKey='en_US',
                        LocaleSidKey='en_US',
                        ProfileId = profileList[0].Id, 
                        TimeZoneSidKey='America/Los_Angeles', 
                        UserName=userName,
                        User_Number__c = 11223344
                    )};
    }

    
    /**
    * @description - This method is used to create a List of Pricing Details
    * @author Sk Minsar | 03-19-2025 
    * @param applicationList 
    * @param hasEnable 
    * @param noOfRecords 
    * @return List<genesis__Application_Pricing_Detail__c> 
    **/
    public static List<genesis__Application_Pricing_Detail__c> createPricingDetailList(List<genesis__Applications__c> applicationList, Boolean hasEnable, Integer noOfRecords){
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = new List<genesis__Application_Pricing_Detail__c>();
        for(genesis__Applications__c applicationObj: applicationList){
            genesis__Application_Pricing_Detail__c pricingDetailObj = createPricingDetail(applicationObj.Id);
            pricingDetailObj.Loan_Number__c = applicationObj.genesis__Loan_Number__c;
            pricingDetailObj.Loan_Id__c = applicationObj.Loan_Id__c;
            pricingDetailObj.genesis__Enabled_Flag__c = hasEnable;
            pricingDetailsList.add(pricingDetailObj);
        }
        return pricingDetailsList;
    }

}