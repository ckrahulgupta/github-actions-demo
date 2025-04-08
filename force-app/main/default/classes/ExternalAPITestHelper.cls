/**
 * @description       : Test helper class to create test data for external API
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 03-17-2025
 * @last modified by  : Kabir Pramanik
**/
@isTest
public inherited sharing class ExternalAPITestHelper {

    /**
    * @description : creates a business info for the dealer
    * @author Krishanu Chinya | 05-21-2024 
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
    * @description : creates a dealer account
    * @author Krishanu Chinya | 05-21-2024 
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
        dealerAccountObj.Coop_Type__c = 'Landus';
        dealerAccountObj.Tier__c = 'Gold';
        dealerAccountObj.Enable_ERP_Id__c = true;
        dealerAccountObj.Is_Required_ERP_Id__c = true;
        dealerAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        return dealerAccountObj;
    }

    /**
    * @description : creates a certified lender account
    * @author Krishanu Chinya | 05-21-2024 
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
    * @description : creates a certified lender contact
    * @author Krishanu Chinya | 05-21-2024 
    * @param accountId 
    * @return Contact 
    **/
    public static Contact createCLContact(Id accountId){
        Contact clContactObj=new Contact();
        clContactObj.FirstName='Ross';
        clContactObj.LastName='Geller';
        clContactObj.Email='ross.geller@yopmail.com';
        clContactObj.Phone='666714588';
        clContactObj.accountId = accountId;
        return clContactObj;
    }

    /**
    * @description : creates a certified lender cuser
    * @author Krishanu Chinya | 05-21-2024 
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
    * @description : fetches a certified lender user
    * @author Krishanu Chinya | 05-21-2024 
    * @param userName 
    * @return User 
    **/
    public static User getCertifiedLenderUser(String userName) {
        List<User> userList = [SELECT Id,
                                    AccountId,
                                    Account.ParentId,
                                    Account.Parent.Coop_type__c
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
    * @description : creates cif
    * @author Krishanu Chinya | 05-21-2024 
    * @return CFA_Configuration__c 
    **/
    public static CFA_Configuration__c createCIFNumber(){
        CFA_Configuration__c cifObj = new CFA_Configuration__c();
        cifObj.CIF_Number__c='32454345';
        cifObj.Growmark_CIF_Number__c = '1000501';
        return cifObj;
    }

    /**
    * @description : Creating Legal Entity
    * @author Krishanu Chinya | 05-21-2024 
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
    * @description : creates all possible legal entities
    * @author Krishanu Chinya | 05-21-2024 
    * @return Map<String, clcommon__Legal_Entity__c> 
    **/
    public static Map<String, clcommon__Legal_Entity__c> createMultipleLegalEntity(){

        Map<String, clcommon__Legal_Entity__c> legalEntityMap = new Map<String, clcommon__Legal_Entity__c>{

            ExternalConstants.INDIVIDUAL_ENTITY => createLegalEntity(ExternalConstants.INDIVIDUAL_ENTITY), // DBA entity
            ExternalConstants.SOLE_PROP_ENTITY => createLegalEntity(ExternalConstants.SOLE_PROP_ENTITY),
            ExternalConstants.CORPORATION => createLegalEntity(ExternalConstants.CORPORATION),
            ExternalConstants.LIMITED_LIABILITY_COMPANY => createLegalEntity(ExternalConstants.LIMITED_LIABILITY_COMPANY),
            ExternalConstants.GENERAL_PARTNERSHIP => createLegalEntity(ExternalConstants.GENERAL_PARTNERSHIP),
            ExternalConstants.LIMITED_PARTNERSHIP => createLegalEntity(ExternalConstants.LIMITED_PARTNERSHIP),
            ExternalConstants.JOINT_VENTURE => createLegalEntity(ExternalConstants.JOINT_VENTURE),
            ExternalConstants.TRUST => createLegalEntity(ExternalConstants.TRUST)
        };
        return legalEntityMap;
    }

    /**
    * @description Creating Sole Prop Legal Entity
    * @author Suraj Kumar | 02-20-2024 
    * @return clcommon__Legal_Entity__c 
    **/
    public static clcommon__Legal_Entity__c createSolePropLegalEntity() {
        clcommon__Legal_Entity__c entityObj = new clcommon__Legal_Entity__c();
        entityObj.clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship';
        entityObj.Name = 'Individual(s) - Sole Proprietorship';
        return entityObj;
    }

    /**
    * @description Creating Business Information for Borrower
    * @author Suraj Kumar | 02-20-2024 
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
    * @description Creating Sole Prop Borrower Account
    * @author Suraj Kumar| 02-20-2024 
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
        accountObj.BillingCity = 'Kolkata';
        accountObj.BillingState = 'WA';
        accountObj.Billing_County__c='fghu';
        accountObj.Work_Number__c='1987656789';
        accountObj.Unique_Id__c = 'kzBagk';
        accountObj.BillingStreet = 'nhgv';
        accountObj.BillingPostalCode = '12345';
        return accountObj;
    }

    /**
    * @description Creating Borrower Contact
    * @author Suraj Kumar | 02-20-2024 
    * @param objAccountID 
    * @return Contact 
    **/
    public static Contact createBorrowerContact(Id objAccountID){
        Contact contactObj = new Contact();
        contactObj.FirstName = 'Jasmine';
        contactObj.LastName = 'Albin';
        contactObj.Email = 'jasmin.albin@yopmail.com';
        contactObj.Phone = '9734227544';
        contactObj.MobilePhone = '342134234';
        contactObj.genesis__SSN__c = 'GHFB67666';
        contactObj.Confirm_SSN__c = 'GHFB67666';
        contactObj.accountId = objAccountId;
        contactObj.MailingCity = 'Kolkata';
        contactObj.MailingState = 'WA';
        contactObj.MailingStreet='nhgv';
        contactObj.Mailing_County__c = 'county';
        contactObj.MailingPostalCode = '12345';
        contactObj.Birthdate = System.today().addYears(-35);
        return contactObj;
    }

    /**
    * @description Creating data for Purpose of Application
    * @author Suraj Kumar | 02-20-2024 
    * @return clcommon__CL_Purpose__c 
    **/
    public static clcommon__CL_Purpose__c createCLPurposeForApplication() {
        clcommon__CL_Purpose__c  clPurposeObj = new clcommon__CL_Purpose__c();
        clPurposeObj.Name='Crop';
        return clPurposeObj;
    }

     /**
    * @description Creating Data for CL Product of Application
    * @author Suraj Kumar | 02-20-2024 
    * @return clcommon__CL_Product__c 
    **/
    public static clcommon__CL_Product__c createCLProductForApplication() {
        clcommon__CL_Product__c clProductObj = new clcommon__CL_Product__c();
        clProductObj.clcommon__Product_Name__c ='Simpli-Fi';
        return clProductObj;
    }

    /**
    * @description Creating an Application Which is ACTIVATED for Current Crop Year 
    * @author Suraj Kumar | 02-20-2024 
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
        applicationObj.Signing_Method__c = 'Email - Docusign';
        return applicationObj;
    }

     /**
    * @description Creating Reciprocal Role for Certified Lender
    * @author Suraj Kumar | 02-20-2024 
    * @return clcommon__Reciprocal_Role__c 
    **/
    public static clcommon__Reciprocal_Role__c createCertifiedLenderRole() {
        clcommon__Reciprocal_Role__c roleObj = new clcommon__Reciprocal_Role__c();
        roleObj.name = 'Certified Lender';
        return roleObj;    
    }

    /**
    * @description Creating Relationship Between Dealer and CL
    * @author Suraj Kumar | 02-20-2024 
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
    * @description Create Collateral Category
    * @author Suraj Kumar | 02-20-2024 
    * @return clcommon__Collateral_Category__c 
    **/
    public static clcommon__Collateral_Category__c createCollateralCategory(){
        clcommon__Collateral_Category__c collateral = new clcommon__Collateral_Category__c();
        collateral.name = 'Millet';
        collateral.Collateral_Unit__c = 'BU';
        collateral.Price_Per_Unit_1__c = 10.85;
        collateral.Price_Per_Unit_2__c = 6.85;
        collateral.Commodity_Display_Position__c = 7;
        return collateral;
    }

    /**
    * @description Creating Sole Prop buyer Account
    * @author Suraj Kumar | 02-20-2024 
    * @param entityObj 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createBuyerAccount(clcommon__Legal_Entity__c entityObj, 
                                                            Id businessInfoId){  
        Account accountObj = new Account();
        accountObj.Name = 'Jacota Morgan';
        accountObj.clcommon__Email__c = 'jacota.morgan@yopmail.com';
        accountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        accountObj.genesis__Business_Information__c = businessInfoId;
        accountObj.BillingCity = 'Wakanda';
        accountObj.BillingState = 'WA';
        accountObj.Billing_County__c = 'Johnson';
        accountObj.Work_Number__c = '8748394883';
        return accountObj;
    }

     /**
    * @description Creating Sole Prop land owner Account
    * @author Suraj Kumar | 02-20-2024 
    * @param entityObj 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createLandOwnerAccount(clcommon__Legal_Entity__c entityObj, 
                                                            Id businessInfoId){  
        Account accountObj = new Account();
        accountObj.Name = 'Martha Hudson';
        accountObj.clcommon__Email__c = 'martha.hudson@yopmail.com';
        accountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        accountObj.genesis__Business_Information__c = businessInfoId;
        accountObj.BillingCity = 'London';
        accountObj.BillingState = 'WA';
        accountObj.Billing_County__c = 'Marylebone';
        accountObj.Work_Number__c = '7256328743';
        return accountObj;
    }

     /**
    * @description Creating Sole Prop insurance agent Account
    * @author Suraj Kumar| 02-20-2024 
    * @param entityObj 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createInsuranceAgentAccount(clcommon__Legal_Entity__c entityObj, 
                                                            Id businessInfoId){  
        Account accountObj = new Account();
        accountObj.Name = 'Benjamin Carson';
        accountObj.clcommon__Email__c = 'benjamin.carson@yopmail.com';
        accountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        accountObj.genesis__Business_Information__c = businessInfoId;
        accountObj.BillingCity = 'Paris';
        accountObj.BillingState = 'WA';
        accountObj.Billing_County__c = 'Orange County';
        accountObj.Work_Number__c = '6365386432';
        return accountObj;
    }

    /**
    * @description The purpose of this method is to create test account.
    * @author Suraj Kumar | 02-20-2024 
    * @return Account 
    **/
    public static Account createAccount(){
        return new Account(Name = 'Red Beard', clcommon__Email__c = 'red.beard@yopmail.com');
    }

     /**
    * @description Creating Buyer Contact
    * @author Suraj Kumar | 02-20-2024 
    * @param objAccountID 
    * @return Contact 
    **/
    public static Contact createBuyerContact(Id objAccountID){
        Contact contactObj=new Contact();
        contactObj.FirstName='Jacota';
        contactObj.LastName='Morgan';
        contactObj.Email='jacota.morgan@yopmail.com';
        contactObj.Phone='7256328743';
        contactObj.MobilePhone = '8728378473';
        contactObj.genesis__SSN__c = '638563858';
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
    * @description Creating land owner Contact
    * @author Suraj Kumar | 02-20-2024 
    * @param objAccountID 
    * @return Contact 
    **/
    public static Contact createLandOwnerContact(Id objAccountID){
        Contact contactObj=new Contact();
        contactObj.FirstName='Martha';
        contactObj.LastName='Hudson';
        contactObj.Email='martha.hudson@yopmail.com';
        contactObj.Phone='7385375843';
        contactObj.MobilePhone = '8374837584';
        contactObj.genesis__SSN__c = '938564849';
        contactObj.accountId = objAccountId;
        contactObj.MailingCity = 'London';
        contactObj.MailingState = 'WA';
        contactObj.MailingStreet='221B Bakers Street';
        contactObj.Mailing_County__c='Marylebone';
        contactObj.MailingPostalCode='73859';
        contactObj.Birthdate=System.today().addYears(-35);
        return contactObj;
    }

     /**
    * @description Creating insurance agent Contact
    * @author Suraj Kumar | 02-20-2024 
    * @param objAccountID 
    * @return Contact 
    **/
    public static Contact createInsuranceAgentContact(Id objAccountID){
        Contact contactObj=new Contact();
        contactObj.FirstName='Benjamin';
        contactObj.LastName='Carson';
        contactObj.Email='benjamin.carson@yopmail.com';
        contactObj.Phone='6365386432';
        contactObj.MobilePhone = '8765373532';
        contactObj.genesis__SSN__c = '637509883';
        contactObj.accountId = objAccountId;
        contactObj.MailingCity = 'Paris';
        contactObj.MailingState = 'WA';
        contactObj.MailingStreet='45 LL';
        contactObj.Mailing_County__c='Orange County';
        contactObj.MailingPostalCode='63758';
        contactObj.Birthdate=System.today().addYears(-35);
        return contactObj;
    }

    /**
    * @description The purpose of this method is to create test contact.
    * @author Suraj Kumar | 02-20-2024 
    * @return Contact 
    **/
    public static Contact createContact(){
        return new Contact(FirstName = 'Red', LastName = 'Beard', genesis__SSN__c = '858589253', Email = 'red.beard@yopmail.com');
    }

     /**
    * @description Creating Party Type
    * @author Suraj Kumar | 02-20-2024 
    * @param name 
    * @return clcommon__Party_Type__c 
    **/
    public static clcommon__Party_Type__c createPartyType(String name) {
        clcommon__Party_Type__c partyTypeObj = new clcommon__Party_Type__c();
        partyTypeObj.Name= name;
        return partyTypeObj;
    }

    /**
    * @description Generic Method For Creating Party 
    * @author Suraj Kumar | 02-20-2024 
    * @param paramMap 
    * @return clcommon__Party__c 
    **/
    public static clcommon__Party__c createParty(Map<String, Id> paramMap){
        clcommon__Party__c partyObj = new clcommon__Party__c();
        partyObj.clcommon__Account__c=paramMap.get('accountId');
        partyObj.clcommon__Contact__c=paramMap.get('contactId');
        partyObj.clcommon__Type__c = paramMap.get('partyTypeId');
        partyObj.genesis__Application__c = paramMap.get('applicationId');
        // partyObj.clcommon__Party_Types__c = paramMap.get('partyTypes');
        partyObj.Total_Assets__c = 2346;
        partyObj.Total_Liabilities__c = 2423433;
        return partyObj;
    }

   
    /**
    * @description : Creating the Credit Rating Matrix
    * @author Suraj Kumar | 05-27-2024 
    * @return List<genesis__Credit_Rating_Matrix__c> 
    **/
    public static List<genesis__Credit_Rating_Matrix__c> createCreditRatingMatrix(){
        List<genesis__Credit_Rating_Matrix__c> creditRatingList = new List<genesis__Credit_Rating_Matrix__c>();
        for(Integer creditNum=1;creditNum<=4;creditNum++){
            genesis__Credit_Rating_Matrix__c creditRatingMatrixObj = new genesis__Credit_Rating_Matrix__c(Name='Tier '+creditNum);
            creditRatingList.add(creditRatingMatrixObj);
        }
        return creditRatingList;
    }

    /**
    * @description Generic method to create tasks
    * @author Suraj Kumar | 06-06-2024 
    * @param applicationId 
    * @param subject 
    * @return Task 
    **/
    public static Task createTask(Id applicationId, String subject){
        return new Task(Subject = subject, genesis__Application__c = applicationId);
    }

    /**
    * @description Creating Doc Category
    * @author Suraj Kumar | 06-06-2024 
    * @param applicationId 
    * @param name 
    * @return clcommon__document_category__c 
    **/
    public static clcommon__document_category__c createDocCategory(Id applicationId, String name){
        clcommon__document_category__c docCategory = new clcommon__document_category__c();
        docCategory.genesis__Application__c = applicationId;
        docCategory.clcommon__Category_Name__c = name;
        return docCategory;
    }

     /**
    * @description : creating content document link
    * @author Suraj Kumar | 06-06-2024 
    * @param conDocId 
    * @param applicationID 
    * @return ContentDocumentLink 
    **/
    public static ContentDocumentLink createContentDocumentLink(Id conDocId, Id applicationID){

        ContentDocumentLink contentDocumentLinkObj = New ContentDocumentLink();
        contentDocumentLinkObj.LinkedEntityId = applicationID;
        contentDocumentLinkObj.ContentDocumentId = conDocId;
        contentDocumentLinkObj.shareType = 'V';
        contentDocumentLinkObj.Visibility = 'AllUsers';
        return contentDocumentLinkObj;
    }

    /**
    * @description : creating content version
    * @author Suraj Kumar | 06-06-2024 
    * @param fileName 
    * @return ContentVersion 
    **/
    public static ContentVersion createContentVersion(String fileName) {

        ContentVersion contentVersion = new ContentVersion(
            Title = fileName,
            PathOnClient = fileName,
            VersionData = Blob.valueOf('Test Credit Application Agreement Content'),
            IsMajorVersion = true
        );
        return contentVersion;
    }

    /**
    * @description : method to create envelope for docusign
    * @author Suraj Kumar | 06-21-2024 
    * @param applicationId 
    * @return dfsle__Envelope__c 
    **/
    public static dfsle__Envelope__c createEnvelope(Id applicationId){
        dfsle__Envelope__c envelope = new dfsle__Envelope__c();
        envelope.dfsle__SourceId__c = applicationId;
        envelope.dfsle__DocuSignId__c = 'd5f4f3be-fe59-4819-aab1-1ded04720sf';
        return envelope;
    }

    /**
    * @description : method to create envelope status for Docusign
    * @author Suraj Kumar | 06-21-2024 
    * @param applicationId 
    * @return dfsle__EnvelopeStatus__c
    **/
    public static dfsle__EnvelopeStatus__c createEnvelopeStatus(Id applicationId){
        dfsle__EnvelopeStatus__c dsEnvelopeStatus = new dfsle__EnvelopeStatus__c();
        dsEnvelopeStatus.dfsle__SourceId__c = applicationId; 
        dsEnvelopeStatus.dfsle__DocuSignId__c = 'd5f4f3be-fe59-4819-aab1-1ded04720sf';
        return dsEnvelopeStatus;
    }

    /**
    * @description : method to create credit department for task
    * @author Ayan Bhowmik | 08-30-2024 
    * @param departmentName
    * @return genesis__Department__c
    **/
    public static genesis__Department__c createDepartment(String departmentName){
        genesis__Department__c departmentObj = new genesis__Department__c();
        departmentObj.Name = departmentName; 
        return departmentObj;
    }

    /**
    * @description : Method to create applicant dealer relationship
    * @author Suraj Kumar | 12-05-2024 
    * @param applicantAccounObj 
    * @param applicantContactObj 
    * @param dealerAccountObj 
    * @return Dealer_Applicant_Relationship__c 
    **/
    public static Dealer_Applicant_Relationship__c createApplicantDealerRelationship(Account applicantAccounObj, Contact applicantContactObj, Account dealerAccountObj){
        Dealer_Applicant_Relationship__c applicantDealerRelObj = new Dealer_Applicant_Relationship__c();
        applicantDealerRelObj.Applicant__c = applicantAccounObj.Id;
        applicantDealerRelObj.Applicant_Contact__c = applicantContactObj.Id;
        applicantDealerRelObj.Dealer__c = dealerAccountObj.Id;
        return applicantDealerRelObj;
    }

    /**
    * @description : Creates grower account for Corporation entity type
    * @author Suraj Kumar | 12-05-2024 
    * @param entityObj 
    * @param businessInfoId 
    * @param dealerAccountId
    * @return Account 
    **/
    public static Account createCorporationAccount(clcommon__Legal_Entity__c entityObj, 
                                                                Id businessInfoId,
                                                                Id dealerAccountId){  
        Account accountObj = new Account();
        accountObj.Name = 'Green Crops Pvt. Ltd.';
        accountObj.clcommon__Email__c='green.crops@yopmail.com';
        accountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        accountObj.genesis__Business_Information__c = businessInfoId;
        accountObj.BillingCity = 'Kansas';
        accountObj.BillingState = 'KS';
        accountObj.Billing_County__c='Olathe';
        accountObj.BillingPostalCode = '73853';
        accountObj.Work_Number__c='1138739873';
        accountObj.ParentId = dealerAccountId;
        accountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        return accountObj;
    }

    /**
    * @description : creates contact for corporation
    * @author Suraj Kumar | 12-05-2024
    * @param accountId 
    * @return Contact 
    **/
    public static Contact createCorporationContact(Id accountId){  
        Contact contactObj = new Contact();
        contactObj.FirstName = '';
        contactObj.LastName = 'Green Crops Pvt. Ltd.';
        contactObj.Email = 'green.crops@yopmail.com';
        contactObj.Phone = '9734227544';
        contactObj.MobilePhone = '1138739873';
        contactObj.accountId = accountId;
        contactObj.MailingCity = 'Kansas';
        contactObj.MailingState = 'KS';
        contactObj.MailingStreet='nhgv';
        contactObj.Mailing_County__c = 'Olathe';
        contactObj.MailingPostalCode = '12345';
        return contactObj;
    }

    /**
    * @description : Method to create task setup
    * @author Suraj Kumar | 12-07-2024 
    * @param taskSetupName 
    * @return genesis__Task_Setup__c 
    **/
    public static genesis__Task_Setup__c createTaskSetup(String taskSetupName){
        genesis__Task_Setup__c taskSetup = new genesis__Task_Setup__c(genesis__Object_Type__c = 'genesis__Applications__c', genesis__Task_Name__c = taskSetupName);
        return taskSetup;
    }

    /**
    * @description : Generic Method to create borrower/coBorrower party 
    * @author Suraj Kumar | 12-23-2024 
    * @param paramMap 
    * @return clcommon__Party__c 
    **/
    public static clcommon__Party__c createApplicantParty(Map<String, Id> paramMap){
        clcommon__Party__c partyObj = new clcommon__Party__c();
        partyObj.clcommon__Account__c=paramMap.get('accountId');
        partyObj.clcommon__Contact__c=paramMap.get('contactId');
        partyObj.clcommon__Type__c = paramMap.get('partyTypeId');
        partyObj.genesis__Application__c = paramMap.get('applicationId');
        partyObj.Dealer_Applicant_Relationship__c = paramMap.get('dealerApplicantRelId');
        partyObj.Total_Assets__c = 2346;
        partyObj.Total_Liabilities__c = 2423433;
        partyObj.Street__c = '256 mall road';
        partyObj.City__c = 'Kansas';
        partyObj.State__c = 'IL';
        partyObj.County__c = 'New York';
        partyObj.Postal_Code__c = '12345';
        partyObj.Home_Number__c = '1234567890';
        partyObj.Mobile_Number__c = '2345678901';
        partyObj.Work_Number__c = '3456789012';
        partyObj.Gross_Farm_Income__c = 10001;
        return partyObj;
    }
    /**
    * @description : Method to get external api user
    * @author Suraj Kumar | 01-09-2025 
    * @return List<User> 
    **/
    public static List<User> getExternalAPIUser(){
        List<User> userList = [SELECT Id 
                                    FROM User 
                                    WHERE Profile.Name = 'CFA External API Profile' 
                                    AND isActive = true 
                                    LIMIT 1];
        ExternalApplicationOriginationUtil.checkEmptyList(userList, 'External api user not found');
        return userList;
    }

    /**
    * @description : Method to get System admin user
    * @author Suraj Kumar | 01-09-2025 
    * @return List<User> 
    **/
    public static List<User> getSystemAdminUser(){
        List<User> userList = [SELECT Id 
                                    FROM User 
                                    WHERE Profile.Name = 'System Administrator' 
                                    AND isActive = true 
                                    LIMIT 1];
        return userList;
    }

    /**
    * @description This method is to create rate card setup header obj
    * @author Kabir Pramanik | 03-12-2025 
    * @param dealerAccObj 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    public static genesis__Rate_Card_Setup_Header__c createRateCardSetupHeader(Account dealerAccObj){
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderObj.Name = 'My Test Program 99';
        rateCardHeaderObj.genesis__Product_Type__c = ExternalConstants.LOAN_TYPE;
        rateCardHeaderObj.Account__c = dealerAccObj.Id;
        rateCardHeaderObj.CFA_Advantage_Rate__c = 7;
        rateCardHeaderObj.genesis__Description__c = 'This rate card calculates an interest for seed purpose oriented loans';
        rateCardHeaderObj.Closing_Fee__c = 200;
        rateCardHeaderObj.genesis__Start_Date__c = Date.today();
        rateCardHeaderObj.genesis__Transaction_Date__c = Date.today();
        rateCardHeaderObj.genesis__End_Date__c = Date.today().addYears(1).toStartOfMonth().addDays(15);
        rateCardHeaderObj.Payer_of_Loan_Closing_Fee__c = 'Grower';
        rateCardHeaderObj.Loan_Fee_Advanced_On__c = 'A';
        rateCardHeaderObj.Dealer_Participate_on_Closing_Fee__c = 'Yes';
        rateCardHeaderObj.Portion_of_Fee_to_Cover__c = 100;
        if( Date.today().month() >= 6){
            rateCardHeaderObj.Crop_Year__c = String.valueOf(Date.today().year());
        } else {
            rateCardHeaderObj.Crop_Year__c = String.valueOf(Date.today().year() - 1);
        }
        return rateCardHeaderObj;
    }

    /**
    * @description This method is to create rate card setup detail obj
    * @author Kabir Pramanik | 03-12-2025 
    * @param myProgram 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    public static genesis__Rate_Card_Setup_Detail__c createRateCardSetupDetail(genesis__Rate_Card_Setup_Header__c myProgram){
        genesis__Rate_Card_Setup_Detail__c rateCardDetailObj = new genesis__Rate_Card_Setup_Detail__c();
        rateCardDetailObj.genesis__Rate_Card_Setup_Header__c = myProgram.Id;
        rateCardDetailObj.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';
        rateCardDetailObj.Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account';
        rateCardDetailObj.Participation_Percentage_CFA__c = 5.5;
        rateCardDetailObj.Participation_Percentage_Dealer__c = 0.2;
        rateCardDetailObj.Participation_Percentage_Dealer_Subsidy__c = 0;
        rateCardDetailObj.Interest_Rate_Type__c = 'Fixed';
        rateCardDetailObj.Start_Date__c = Date.today().addMonths(3).toStartOfMonth();
        rateCardDetailObj.End_Date__c = Date.today().addMonths(6).toStartOfMonth().addDays(-1);
        rateCardDetailObj.genesis__Interest_Rate__c = 7.7;
        rateCardDetailObj.genesis__Enabled_Flag__c = true;
        return rateCardDetailObj;
    }

    /**
    * @description This method is to create application pricing detail obj
    * @author Kabir Pramanik | 03-12-2025 
    * @param application 
    * @return List<genesis__Application_Pricing_Detail__c> 
    **/
    public static List<genesis__Application_Pricing_Detail__c> createApplicationPricings(genesis__Applications__c application) {
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
    * @description This meethod is to create all types of payment modes
    * @author Kabir Pramanik | 03-12-2025 
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
    * @description This method is to create funding transaction obj
    * @author Kabir Pramanik | 03-12-2025 
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
    * @description get the admin user 
    * @author Kabir Pramanik | 03-12-2025 
    * @return User 
    **/
    public static User getAdminUser(){
        return [SELECT Id 
                FROM User 
                WHERE Profile.name = 'System Administrator'
                AND isActive = true LIMIT 1][0];
    }
    /**
    * @description This method is to create user by profile name
    * @author Kabir Pramanik | 03-17-2025 
    * @param profileName 
    * @param userName 
    * @return User
    **/
    public static User createUserByProfileName(String profileName, String userName) {
        List<Profile> profileList = [SELECT Id FROM Profile WHERE Name =: profileName LIMIT 1];
        return new User (
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
                    );
    }
    /**
    * @description This mehtod returns user with given profile name
    * @author Kabir Pramanik | 03-17-2025 
    * @param profileName 
    * @return User 
    **/
    public static User getUserByProfileName(String profileName){
        return [SELECT Id 
                FROM User 
                WHERE Profile.name =: profileName
                AND isActive =: ConstantValues.TRUE_VALUE LIMIT 1][0];

    }
}