/**
 * @description       : Helper class for ApplicationOriginationTest
 * @author            : Krishanu Chinya
 * created date       : 10-08-2023
 * @group             : 
 * @last modified on  : 03-25-2025
 * @last modified by  : Rakesh Saraf
**/


@isTest
global without sharing class ApplicationOriginationTestHelper {

    /**
    * @description The purpose of this method is to create test account.
    * @author Ayan Bhowmik | 02-20-2024 
    * @return Account 
    **/
    public static Account createAccount(){
        return new Account(Name = 'Red Beard', clcommon__Email__c = 'red.beard@yopmail.com');
    }

    /**
    * @description The purpose of this method is to create test contact.
    * @author Ayan Bhowmik | 02-20-2024 
    * @return Contact 
    **/
    public static Contact createContact(){
        return new Contact(FirstName = 'Red', LastName = 'Beard', genesis__SSN__c = '858589253', Email = 'red.beard@yopmail.com');
    }

    /**
    * @description The purpose of this method is to create test business information.
    * @author Ayan Bhowmik | 02-20-2024 
    * @return genesis__Business_Information__c 
    **/
    public static genesis__Business_Information__c createBusinessInfoForDealer(){        
        genesis__Business_Information__c businessInfoObj = new genesis__Business_Information__c();
        businessInfoObj.genesis__Business_Country__c='India';
        businessInfoObj.Remaining_Customised_Limit__c=200000;
        businessInfoObj.Contract_Loan_Limit__c=300000;
        businessInfoObj.Approved_Loan_Amount__c=150000;
        businessInfoObj.genesis__Tax_Identification_Number__c = '666899905';
        businessInfoObj.Customised_Loan_Limit__c = 200000;
        businessInfoObj.Customised_Individual_Limit__c = 200000;
        return businessInfoObj;
    }

    /**
    * @description Creating Dealer Account With Coop Type CFA
    * @author Ayan Bhowmik | 02-20-2024 
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
        // dealerAccountObj.IFP_checkbox__c = false;
        dealerAccountObj.Enable_ERP_Id__c = true;
        dealerAccountObj.Is_Required_ERP_Id__c = true;
        dealerAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId();
        return dealerAccountObj;
    }

    /**
    * @description Dealer company account for test
    * @author Ayan Bhowmik | 02-20-2024 
    * @param businessInfo 
    * @return Account 
    **/
    public static Account createDealerParentAccount(genesis__Business_Information__c businessInfo ){  
        Account accountObj = new Account();
        accountObj.Name='AMKE Enterprise';
        accountObj.genesis__Business_Information__c=businessInfo.Id;
        return accountObj;
    }

    /**
    * @description Dealer user account for test
    * @author Ayan Bhowmik | 02-20-2024 
    * @param businessInfo 
    * @param parentAccount 
    * @return Account 
    **/
    public static Account createDealerChildAccount(genesis__Business_Information__c businessInfo, Account parentAccount ){  
        Account accountObj = new Account();
        clcommon__Legal_Entity__c clEntity= new clcommon__Legal_Entity__c();
        clEntity.Name='Individual';
        // Database.insert(clEntity,true);
        accountObj.Name='Dealer Bob';
        accountObj.ParentId = parentAccount.Id;
        accountObj.clcommon__Legal_Entity_Type__c = clEntity.Id;
        accountObj.genesis__Business_Information__c=businessInfo.Id;
        return accountObj;
    }


    /**
    * @description Creating Certfied Lender Account
    * @author Ayan Bhowmik | 02-20-2024 
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
    * @description Creating Certified Lender Contact
    * @author Ayan Bhowmik | 02-20-2024 
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
        // clContactObj.MobilePhone='777623477';
        clContactObj.accountId = accountId;
        return clContactObj;
    }

    /**
    * @description create cl plus account
    * @author Ayan Bhowmik | 02-20-2024 
    * @param businessInfoId 
    * @param dealerAccountId 
    * @return Account 
    **/
    public static Account createCLPlusAccount(Id businessInfoId, Id dealerAccountId){
        Account clAccountObj = new Account();
        clAccountObj.Name = 'Peter Geller';
        clAccountObj.genesis__Business_Information__c = businessInfoId;
        clAccountObj.Phone = '666717488';
        clAccountObj.BillingStreet = '2423 6th Avenue';
        clAccountObj.BillingCity = 'Frankenmouth';
        clAccountObj.BillingState = 'WA';
        clAccountObj.BillingPostalCode = '61232';
        clAccountObj.CIF_Number__c = '009978';
        clAccountObj.clcommon__Email__c = 'peter.geller@yopmail.com';
        clAccountObj.ParentId = dealerAccountId;
        clAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Certified Lender Plus').getRecordTypeId();
        return clAccountObj;
    }

    /**
    * @description create cl plus contact
    * @author Ayan Bhowmik | 02-20-2024 
    * @param accountId 
    * @return Contact 
    **/
    public static Contact createCLPlusContact(Id accountId){
        Contact clContactObj=new Contact();
        clContactObj.FirstName='Peter';
        clContactObj.LastName='Geller';
        clContactObj.genesis__SSN__c='552212413';
        clContactObj.Confirm_SSN__c='552212413';
        clContactObj.Email='peter.geller@yopmail.com';
        clContactObj.Phone='663714588';
        clContactObj.accountId = accountId;
        return clContactObj;
    }

    /**
    * @description create inquiry account
    * @author Ayan Bhowmik | 02-20-2024 
    * @param businessInfoId 
    * @param dealerAccountId 
    * @return Account 
    **/
    public static Account createInquiryAccount(Id businessInfoId, Id dealerAccountId){
        Account clAccountObj = new Account();
        clAccountObj.Name = 'Andrew Geller';
        clAccountObj.genesis__Business_Information__c = businessInfoId;
        clAccountObj.Phone = '666712348';
        clAccountObj.BillingStreet = '2423 6th Avenue';
        clAccountObj.BillingCity = 'Frankenmouth';
        clAccountObj.BillingState = 'WA';
        clAccountObj.BillingPostalCode = '61232';
        clAccountObj.CIF_Number__c = '009955';
        clAccountObj.clcommon__Email__c = 'andrew.geller@yopmail.com';
        clAccountObj.ParentId = dealerAccountId;
        clAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Inquiry').getRecordTypeId();
        return clAccountObj;
    }

    /**
    * @description create inquiry contact
    * @author Ayan Bhowmik | 02-20-2024 
    * @param accountId 
    * @return Contact 
    **/
    public static Contact createInquiryContact(Id accountId){
        Contact clContactObj=new Contact();
        clContactObj.FirstName='Andrew';
        clContactObj.LastName='Geller';
        clContactObj.genesis__SSN__c='555242313';
        clContactObj.Confirm_SSN__c='555242313';
        clContactObj.Email='andrew.geller@yopmail.com';
        clContactObj.Phone='666712348';
        clContactObj.accountId = accountId;
        return clContactObj;
    }
    /**
    * @description create inquiry plus account
    * @author Ayan Bhowmik | 02-20-2024 
    * @param businessInfoId 
    * @param dealerAccountId 
    * @return Account 
    **/
    public static Account createInquiryPlusAccount(Id businessInfoId, Id dealerAccountId){
        Account clAccountObj = new Account();
        clAccountObj.Name = 'Sammy Geller';
        clAccountObj.genesis__Business_Information__c = businessInfoId;
        clAccountObj.Phone = '661714558';
        clAccountObj.BillingStreet = '2423 6th Avenue';
        clAccountObj.BillingCity = 'Frankenmouth';
        clAccountObj.BillingState = 'WA';
        clAccountObj.BillingPostalCode = '61932';
        clAccountObj.CIF_Number__c = '009388';
        clAccountObj.clcommon__Email__c = 'sammy.geller@yopmail.com';
        clAccountObj.ParentId = dealerAccountId;
        clAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Inquiry Plus').getRecordTypeId();
        return clAccountObj;
    }
    /**
    * @description create inquiry plus contact
    * @author Ayan Bhowmik | 02-20-2024 
    * @param accountId 
    * @return Contact 
    **/
    public static Contact createInquiryPlusContact(Id accountId){
        Contact clContactObj=new Contact();
        clContactObj.FirstName='Sammy';
        clContactObj.LastName='Geller';
        clContactObj.genesis__SSN__c='555214313';
        clContactObj.Confirm_SSN__c='555214313';
        clContactObj.Email='sammy.geller@yopmail.com';
        clContactObj.Phone='661714558';
        clContactObj.accountId = accountId;
        return clContactObj;
    }

    /**
    * @description create payment administrator account
    * @author Ayan Bhowmik | 02-20-2024 
    * @param businessInfoId 
    * @param dealerAccountId 
    * @return Account 
    **/
    public static Account createPaymentAdministratorAccount(Id businessInfoId, Id dealerAccountId){
        Account paAccountObj = new Account();
        paAccountObj.Name = 'Alexa Aston';
        paAccountObj.genesis__Business_Information__c = businessInfoId;
        paAccountObj.Phone = '9876543210';
        paAccountObj.BillingStreet = '2423 6th Avenue';
        paAccountObj.BillingCity = 'Frankenmouth';
        paAccountObj.BillingState = 'Michigan';
        paAccountObj.BillingPostalCode = '61232';
        paAccountObj.CIF_Number__c = '009911';
        paAccountObj.clcommon__Email__c = 'alexa.aston@yopmail.com';
        paAccountObj.ParentId = dealerAccountId;
        paAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment Administrator').getRecordTypeId();
        return paAccountObj;
    }

    /**
    * @description create payment administrator contact
    * @author Ayan Bhowmik | 02-20-2024 
    * @param accountId 
    * @return Contact 
    **/
    public static Contact createPaymentAdministratorContact(Id accountId){
        Contact paContactObj=new Contact();
        paContactObj.FirstName='Alexa';
        paContactObj.LastName='Aston';
        paContactObj.genesis__SSN__c='999214313';
        paContactObj.Confirm_SSN__c='999214313';
        paContactObj.Email='alexa.aston@yopmail.com';
        paContactObj.Phone='9876543210';
        paContactObj.accountId = accountId;
        return paContactObj;
    }

    /**
    * @description Creating Dealer Contact
    * @author Ayan Bhowmik | 02-20-2024 
    * @param accountId 
    * @return Contact 
    **/
    public static Contact createDealerContact(Id accountId){
        Contact clContactObj=new Contact();
        clContactObj.FirstName='Kisan';
        clContactObj.LastName='Loan';
        clContactObj.genesis__SSN__c='777888555';
        clContactObj.Confirm_SSN__c='777888555';
        clContactObj.Email='kisan.loan@yopmail.com';
        clContactObj.Phone='1234567890';
        clContactObj.accountId = accountId;
        return clContactObj;
    }

    // Creating Field Staff Account

    /**
    * @description Creating Field Staff Account
    * @author Simran | 03-29-2024 
    * @param businessInfoId 
    * @param dealerAccountId 
    * @return Account 
    **/
    public static Account createFSAgentAccount(Id businessInfoId, Id dealerAccountId){
        Account clAccountObj = new Account();
        clAccountObj.Name = 'Ross FieldStaff';
        clAccountObj.genesis__Business_Information__c = businessInfoId;
        clAccountObj.Phone = '666714590';
        clAccountObj.BillingStreet = '2423 6th Avenue';
        clAccountObj.BillingCity = 'Frankenmouth';
        clAccountObj.BillingState = 'Michigan';
        clAccountObj.BillingPostalCode = '61232';
        clAccountObj.CIF_Number__c = '009909';
        clAccountObj.clcommon__Email__c = 'ross.fieldstaff@yopmail.com';
        clAccountObj.ParentId = dealerAccountId;
        clAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Field Staff Agent').getRecordTypeId();
        return clAccountObj;
    }

    /**
    * @description Creating FS Agent Contact
    * @author Simran | 03-29-2024 
    * @param accountId 
    * @return Contact 
    **/
    public static Contact createFSAgentContact(Id accountId){
        Contact clContactObj=new Contact();
        clContactObj.FirstName='Ross';
        clContactObj.LastName='FieldStaff';
        clContactObj.Email='ross.fieldstaff@yopmail.com';
        clContactObj.Phone='666714590';
        clContactObj.accountId = accountId;
        return clContactObj;
    }

    /**
    * @description Creating FS Agent User
    * @author Simran | 02-21-2024 
    * @param contactID 
    * @return User 
    **/
    public static User createFSAgentUser(Id contactID){
        Profile clProfileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'Growmark Field Staff Agent'
                                    LIMIT 1];
        User clUserObj = new User();
        clUserObj.Alias = 'newUser';
        clUserObj.Email='ross.fieldstaff@yopmail.com';
        clUserObj.EmailEncodingKey='UTF-8';
        clUserObj.LastName='Testing';
        clUserObj.LanguageLocaleKey='en_US';
        clUserObj.LocaleSidKey='en_US';
        clUserObj.ProfileId = clProfileObj.Id;
        clUserObj.ContactId = contactID;
        clUserObj.TimeZoneSidKey='America/Los_Angeles';
        clUserObj.UserName='ross.fieldstaff@yopmail.com';
        return clUserObj;
    }
    /**
    * @description create payment administrator user
    * @author Ayan Bhowmik | 02-20-2024 
    * @param contactID 
    * @return User 
    **/
    public static User createPaymentAdministratorUser(Id contactID){
        Profile paProfileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'Growmark Payment Administrator'
                                    LIMIT 1];
        User paUserObj = new User();
        paUserObj.Alias = 'paUser';
        paUserObj.Email='cfanewuserpa@yopmail.com';
        paUserObj.EmailEncodingKey='UTF-8';
        paUserObj.LastName='Testing';
        paUserObj.LanguageLocaleKey='en_US';
        paUserObj.LocaleSidKey='en_US';
        paUserObj.ProfileId = paProfileObj.Id;
        paUserObj.ContactId = contactID;
        paUserObj.TimeZoneSidKey='America/Los_Angeles';
        paUserObj.UserName='alexa.aston234@yopmail.com';
        return paUserObj;
    }

    /**
    * @description Creating Test Data for Standard User
    * @author Ayan Bhowmik | 02-21-2024 
    * @return User 
    **/
    public static User createStandardUser(){
        Profile clProfileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'Standard User'
                                    LIMIT 1];
        User clUserObj = new User();
        clUserObj.Alias = 'newUser2';
        clUserObj.Email='cfastdus5er@yopmail.com';
        clUserObj.EmailEncodingKey='UTF-8';
        clUserObj.LastName='standard';
        clUserObj.LanguageLocaleKey='en_US';
        clUserObj.LocaleSidKey='en_US';
        clUserObj.ProfileId = clProfileObj.Id;
        //clUserObj.ContactId = contactID;
        clUserObj.TimeZoneSidKey='America/Los_Angeles';
        clUserObj.UserName='std.user@yopmail.com';
        return clUserObj;
    }

    /**
    * @description Creating Certified Lender User
    * @author Ayan Bhowmik | 02-20-2024 
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
    * @author Ayan Bhowmik | 02-20-2024 
    * @param userName 
    * @return User 
    **/
    public static User getCertifiedLenderUser(String userName) {
        List<User> userList = [SELECT Id,Account.ParentId
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
    * @description Fetching  User by userName
    * @author Rahul Gorai | 01-10-2025 
    * @param userName 
    * @return User 
    **/
    public static User getUserByUserName(String userName) {
        List<User> userList =      [SELECT Id,Account.ParentId
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

    // CREATING RECIPROCAL ROLE FOR ALL ROLE TYPE START  :------------------------------------------

    /**
    * @description Creating Reciprocal Role for Certified Lender
    * @author Ayan Bhowmik | 02-20-2024 
    * @return clcommon__Reciprocal_Role__c 
    **/
    public static clcommon__Reciprocal_Role__c createCertifiedLenderRole() {
        clcommon__Reciprocal_Role__c roleObj = new clcommon__Reciprocal_Role__c();
        roleObj.name = 'Certified Lender';
        return roleObj;    
    }
    /**
    * @description Creating Reciprocal Role for Certified Lender Plus
    * @author Ayan Bhowmik | 02-20-2024 
    * @return clcommon__Reciprocal_Role__c 
    **/
    public static clcommon__Reciprocal_Role__c createCertifiedLenderPlusRole() {
        clcommon__Reciprocal_Role__c roleObj = new clcommon__Reciprocal_Role__c();
        roleObj.name = 'Certified Lender Plus';
        return roleObj;    
    }
    /**
    * @description Creating Reciprocal Role for Inquiry
    * @author Ayan Bhowmik | 02-20-2024 
    * @return clcommon__Reciprocal_Role__c 
    **/
    public static clcommon__Reciprocal_Role__c createInquiryRole() {
        clcommon__Reciprocal_Role__c roleObj = new clcommon__Reciprocal_Role__c();
        roleObj.name = 'Inquiry';
        return roleObj;    
    }
    /**
    * @description Creating Reciprocal Role for Inquiry Plus
    * @author Ayan Bhowmik | 02-20-2024 
    * @return clcommon__Reciprocal_Role__c 
    **/
    public static clcommon__Reciprocal_Role__c createInquiryPlusRole() {
        clcommon__Reciprocal_Role__c roleObj = new clcommon__Reciprocal_Role__c();
        roleObj.name = 'Inquiry Plus';
        return roleObj;    
    }
    /**
    * @description Creating Reciprocal Role for Sales Agent
    * @author Ayan Bhowmik | 02-20-2024 
    * @return clcommon__Reciprocal_Role__c 
    **/
    public static clcommon__Reciprocal_Role__c createSalesAgentRole() {
        clcommon__Reciprocal_Role__c roleObj = new clcommon__Reciprocal_Role__c();
        roleObj.name = 'Sales Agent';
        return roleObj;    
    }
    /**
    * @description Creating Reciprocal Role for Payment Administrator
    * @author Ayan Bhowmik | 02-20-2024 
    * @return clcommon__Reciprocal_Role__c 
    **/
    public static clcommon__Reciprocal_Role__c createPaymentAdministratorRole() {
        clcommon__Reciprocal_Role__c roleObj = new clcommon__Reciprocal_Role__c();
        roleObj.name = 'Payment Administrator';
        return roleObj;    
    }

    /**
    * @description Generic Method to Create Reciprocal Role
    * @author Ayan Bhowmik | 02-20-2024 
    * @param name 
    * @return clcommon__Reciprocal_Role__c 
    **/
    public static clcommon__Reciprocal_Role__c createReciprocalRole(String name) {
        clcommon__Reciprocal_Role__c roleObj = new clcommon__Reciprocal_Role__c();
        roleObj.name = name;
        return roleObj;    
    }

// CREATING RECIPROCAL ROLE FOR ALL ROLE TYPE END :---------------------------------------------

// ESTABLISH RELATIONSHIP BETWEEN CL AND DEALER METHODS START :---------------------------------
    // Creating Relationship Between Dealer and CL
    // Use createReciprocalRoleV2 Mehtod to Create Reciprocal Role

    /**
    * @description Creating Relationship Between Dealer and CL
    * @author Ayan Bhowmik | 02-20-2024 
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
    * @description Creating Relationship Between Dealer and SA
    * @author Ayan Bhowmik | 02-20-2024 
    * @param clRoleObj 
    * @param dealerAccountId 
    * @param clAccountId 
    * @return clcommon__Relationship__c 
    **/
    public static clcommon__Relationship__c createSalesAgentDealerRelationship(clcommon__Reciprocal_Role__c clRoleObj,
                                                                        Id dealerAccountId,
                                                                        Id clAccountId) {
        clcommon__Relationship__c relationshipObj = new clcommon__Relationship__c();
        relationshipObj.clcommon__Relationship__c = clRoleObj.Id;
        relationshipObj.clcommon__Entity__c = dealerAccountId;
        relationshipObj.clcommon__Related_Entity__c = clAccountId;
        return relationshipObj;
    }

        /**
        * @description Creating Relationship Between Dealer and PA
        * @author Ayan Bhowmik | 02-20-2024 
        * @param clRoleObj 
        * @param dealerAccountId 
        * @param paAccountId 
        * @return clcommon__Relationship__c 
        **/
        public static clcommon__Relationship__c createPADealerRelationship(clcommon__Reciprocal_Role__c clRoleObj,
                                                                            Id dealerAccountId,
                                                                            Id paAccountId) {
        clcommon__Relationship__c relationshipObj = new clcommon__Relationship__c();
        relationshipObj.clcommon__Relationship__c = clRoleObj.Id;
        relationshipObj.clcommon__Entity__c = dealerAccountId;
        relationshipObj.clcommon__Related_Entity__c = paAccountId;
        return relationshipObj;
    }

    /**
    * @description Generic method to create relationship between dealer and dealer contacts
    * @author Ayan Bhowmik | 02-20-2024 
    * @param role 
    * @param entity 
    * @param relatedEntity 
    * @return clcommon__Relationship__c 
    **/
    public static clcommon__Relationship__c createRelWithDealer(clcommon__Reciprocal_Role__c role,
                                                                        Id entity,
                                                                        Id relatedEntity) {
        clcommon__Relationship__c relationshipObj = new clcommon__Relationship__c();
        relationshipObj.clcommon__Relationship__c = role.Id;
        relationshipObj.clcommon__Entity__c = entity;
        relationshipObj.clcommon__Related_Entity__c = relatedEntity;
        return relationshipObj;
    }

    /**
    * @description Creating Sales Agent Account
    * @author Ayan Bhowmik | 02-20-2024 
    * @param businessInfoId 
    * @param dealerAccountId 
    * @return Account 
    **/
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
     * @description Creating Sales Agent Contact
     * @author Ayan Bhowmik | 02-20-2024 
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
     * @description Creating Sales Agent User
     * @author Ayan Bhowmik | 02-20-2024 
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
     * @description Creating Sales Agent User
     * @author Ayan Bhowmik | 02-20-2024 
     * @param fsaContactId 
     * @return User 
     **/
    public static User createFSAUser(Id fsaContactId){
        List<Profile> fsaProfileList = [SELECT Id
                                        FROM Profile
                                        WHERE Name = 'Growmark Field Staff Agent'
                                        LIMIT 1];
        User fsaUserObj = new User();
        fsaUserObj.Alias = 'newUser';
        fsaUserObj.Email='cfanewus5er@yopmail.com';
        fsaUserObj.EmailEncodingKey='UTF-8';
        fsaUserObj.LastName='Testing';
        fsaUserObj.LanguageLocaleKey='en_US';
        fsaUserObj.LocaleSidKey='en_US';
        fsaUserObj.ProfileId = fsaProfileList[0].Id;
        fsaUserObj.ContactId = fsaContactId;
        fsaUserObj.TimeZoneSidKey='America/Los_Angeles';
        fsaUserObj.UserName='ross.fieldstaff@yopmail.com';
        return fsaUserObj;
    }

     /**
     * @description Creating Prod Ag User
     * @author Ayan Bhowmik | 02-20-2024 
     * @param userContactId 
     * @return User 
     **/
     public static User createProdAgUser(Id userContactId){
        List<Profile> prodAgProfileList = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'System Administrator'
                                    LIMIT 1];
        User prodAgUser = new User();
        prodAgUser.Alias = 'newUser';
        prodAgUser.Email='cfanewus5er@yopmail.com';
        prodAgUser.EmailEncodingKey='UTF-8';
        prodAgUser.LastName='Testing';
        prodAgUser.LanguageLocaleKey='en_US';
        prodAgUser.LocaleSidKey='en_US';
        prodAgUser.ProfileId = prodAgProfileList[0].Id;
        prodAgUser.ContactId = userContactId;
        prodAgUser.TimeZoneSidKey='America/Los_Angeles';
        prodAgUser.UserName='tarik.clinton@yopmail.com';
        prodAgUser.Prod_AG_Officer__c = true;
        return prodAgUser;
    }


    /**
    * @description Creating Sales Agent Admin Account
    * @author Ayan Bhowmik | 02-20-2024 
    * @param businessInfoId 
    * @param dealerAccountId 
    * @return Account 
    **/
    public static Account createSAAdminAccount(Id businessInfoId, Id dealerAccountId){
        Account saAdminAccObj = new Account();
         saAdminAccObj.Name = 'Tim Couper';
         saAdminAccObj.genesis__Business_Information__c = businessInfoId;
         saAdminAccObj.Phone = '663711590';
         saAdminAccObj.BillingStreet = '2423 6th Avenue';
         saAdminAccObj.BillingCity = 'Frankenmouth';
         saAdminAccObj.BillingState = 'Michigan';
         saAdminAccObj.BillingPostalCode = '61232';
         saAdminAccObj.CIF_Number__c = '009988';
         saAdminAccObj.clcommon__Email__c = 'tim.couper@yopmail.com';
         saAdminAccObj.ParentId = dealerAccountId;
         saAdminAccObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('Sales Agent Admin').getRecordTypeId();
        return saAdminAccObj;
    }

     /**
     * @description Creating Sales Agent Admin Contact
     * @author Ayan Bhowmik | 02-20-2024 
     * @param accountId 
     * @return Contact 
     **/
     public static Contact createSAAdminContact(Id accountId){
        Contact saAdminContactObj=new Contact();
         saAdminContactObj.FirstName='Tim';
         saAdminContactObj.LastName='Couper';
         saAdminContactObj.Email='tim.couper@yopmail.com';
         saAdminContactObj.Phone='663711590';
         saAdminContactObj.accountId = accountId;
        return saAdminContactObj;
    }

     /**
     * @description Creating Sales Agent Admin User
     * @author Ayan Bhowmik | 02-20-2024 
     * @param saContactId 
     * @return User 
     **/
     public static User createSAAdminUser(Id saContactId){
        Profile saAdminProfileObj = [SELECT Id
                                     FROM Profile
                                     WHERE Name = 'Sales Agent Admin'
                                     LIMIT 1];
         User saAdminUserObj = new User();
         saAdminUserObj.Alias = 'newUser';
         saAdminUserObj.Email='tim.couper@yopmail.com';
         saAdminUserObj.EmailEncodingKey='UTF-8';
         saAdminUserObj.LastName='Couper';
         saAdminUserObj.LanguageLocaleKey='en_US';
         saAdminUserObj.LocaleSidKey='en_US';
         saAdminUserObj.ProfileId = saAdminProfileObj.Id;
         saAdminUserObj.ContactId = saContactId;
         saAdminUserObj.TimeZoneSidKey='America/Los_Angeles';
         saAdminUserObj.UserName='tim.couper@yopmail.com';
        return saAdminUserObj;
    }

    /**
    * @description Creating Borrower User
    * @author Ayan Bhowmik | 02-20-2024 
    * @param borrowerContactId 
    * @return User 
    **/
    public static User createBorrowerUser(Id borrowerContactId){
        Profile borrowerProfileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'Grower'
                                    LIMIT 1];
        User borrowerUserObj = new User();
        borrowerUserObj.Alias = 'newUser';
        borrowerUserObj.Email='cfanewus5er@yopmail.com';
        borrowerUserObj.EmailEncodingKey='UTF-8';
        borrowerUserObj.LastName='Testing';
        borrowerUserObj.LanguageLocaleKey='en_US';
        borrowerUserObj.LocaleSidKey='en_US';
        borrowerUserObj.ProfileId = borrowerProfileObj.Id;
        borrowerUserObj.ContactId = borrowerContactId;
        borrowerUserObj.TimeZoneSidKey='America/Los_Angeles';
        borrowerUserObj.UserName='star.lord@yopmail.com';
        return borrowerUserObj;
    }

    /**
    * @description Fetching Borrower User
    * @author Ayan Bhowmik | 02-20-2024 
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
    * @description : This method returns the Guest User for Dealer Portal
    * @author Tuhin Bhunia | 03-21-2024 
    * @return User 
    **/
    public static User fetchDealerPortalGuestUser(){

        Profile guestProfileObj = [SELECT Id
                                        FROM Profile
                                        WHERE Name = 'Dealer Portal Profile'
                                        LIMIT 1];
        return [SELECT Id, name FROM User WHERE ProfileId =: guestProfileObj.Id LIMIT 1];

    }

    /**
    * @description : This method returns the Guest User for Grower Portal
    * @author Tuhin Bhunia | 03-21-2024 
    * @return User 
    **/
    public static User fetchGrowerPortalGuestUser(){

        Profile guestProfileObj = [SELECT Id
                                        FROM Profile
                                        WHERE Name = 'Grower Portal Profile'
                                        LIMIT 1];
        return [SELECT Id, name FROM User WHERE ProfileId =: guestProfileObj.Id LIMIT 1];

    }


    /**
    * @description Creating Sole Prop Legal Entity
    * @author Ayan Bhowmik | 02-20-2024 
    * @return clcommon__Legal_Entity__c 
    **/
    public static clcommon__Legal_Entity__c createSolePropLegalEntity() {
        clcommon__Legal_Entity__c entityObj = new clcommon__Legal_Entity__c();
        entityObj.clcommon__Legal_Entity_Type__c = 'Individual(s) - Sole Proprietorship';
        entityObj.Name = 'Individual(s) - Sole Proprietorship';
        return entityObj;
    }
    /**
    * @description Creating Individual Legal Entity
    * @author Ayan Bhowmik | 02-20-2024 
    * @return clcommon__Legal_Entity__c 
    **/
    public static clcommon__Legal_Entity__c createIndividualLegalEntity() {
        clcommon__Legal_Entity__c entityObj = new clcommon__Legal_Entity__c();
        entityObj.clcommon__Legal_Entity_Type__c = 'Individual';
        entityObj.Name = 'Individual';
        return entityObj;
    }
    /**
    * @description Creating Corporation Legal Entity
    * @author Ayan Bhowmik | 02-20-2024 
    * @return clcommon__Legal_Entity__c 
    **/
    public static clcommon__Legal_Entity__c createCorporationLegalEntity() {
        clcommon__Legal_Entity__c entityObj = new clcommon__Legal_Entity__c();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        return entityObj;
    }
    /**
    * @description Creating Trust Legal Entity
    * @author Ayan Bhowmik | 02-20-2024 
    * @return clcommon__Legal_Entity__c 
    **/
    public static clcommon__Legal_Entity__c createTrustLegalEntity() {
        clcommon__Legal_Entity__c entityObj = new clcommon__Legal_Entity__c();
        entityObj.clcommon__Legal_Entity_Type__c = 'Trust';
        entityObj.Name = 'Trust';
        return entityObj;
    }
    /**
    * @description Creating Business Information for Borrower
    * @author Ayan Bhowmik | 02-20-2024 
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
    * @description Creating Business Information for Principal
    * @author Ayan Bhowmik | 02-20-2024 
    * @return genesis__Business_Information__c 
    **/
    public static genesis__Business_Information__c createBusinessInfoForPrincipal(){        
        genesis__Business_Information__c businessInfoObj = new genesis__Business_Information__c();
        businessInfoObj.genesis__Business_Country__c='India';
        businessInfoObj.Remaining_Customised_Limit__c=100000;
        businessInfoObj.Contract_Loan_Limit__c=500000;
        businessInfoObj.Approved_Loan_Amount__c=200000;
        businessInfoObj.genesis__Tax_Identification_Number__c = '676736463';
        businessInfoObj.genesis__Total_Liabilities__c=2346;
        businessInfoObj.genesis__Total_Assets__c=987683;
        
        return businessInfoObj;
    }


    /**
    * @description Creating Sole Prop Borrower Account
    * @author Ayan Bhowmik | 02-20-2024 
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
        accountObj.Work_Number__c='098765678';
        return accountObj;
    }
    
    /**
    * @description : Creating Legal Entity
    * @author Tuhin Bhunia | 03-21-2024 
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
    * @description Creating DBA Legal Entity
    * @author Ayan Bhowmik | 02-20-2024 
    * @return clcommon__Legal_Entity__c 
    **/
    public static clcommon__Legal_Entity__c createDBALegalEntity() {
        clcommon__Legal_Entity__c entityObj = new clcommon__Legal_Entity__c();
        entityObj.clcommon__Legal_Entity_Type__c = 'Individual(s) with DBA';
        entityObj.Name = 'Individual(s) with DBA';
        return entityObj;
    }

    /**
    * @description Creating DBA Borrower Account
    * @author Ayan Bhowmik | 02-20-2024 
    * @param entityObj 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createDBAccount(clcommon__Legal_Entity__c entityObj, Id businessInfoId){  
        Account accountObj = new Account();
        accountObj.Name='Warner Farms';
        accountObj.CIF_Number__c='123456';
        accountObj.BillingCity='San Mateo';
        accountObj.Short_Name__c='San';
        accountObj.BillingState='WA';
        accountObj.BillingStreet='Waters Park Drive';
        accountObj.BillingPostalCode='41223';
        accountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        accountObj.genesis__Business_Information__c=businessInfoId;
        return accountObj;
    }

    /**
    * @description : DBA Account
    * @author  Pritam Roy | 03-28-2024 
    * @param businessInfo 
    * @return Account 
    **/
    public static Account createNewDBAccount(genesis__Business_Information__c businessInfo ){  
        Account accountObj = new Account();
        clcommon__Legal_Entity__c clEntity= new clcommon__Legal_Entity__c();
        clEntity.Name='Individual(s) with DBA';
        clEntity.clcommon__Legal_Entity_Type__c='Individual(s) with DBA';
        accountObj.Name='SJha';
        accountObj.CIF_Number__c='123456';
        accountObj.BillingCity='San Mateo';
        accountObj.Short_Name__c='San';
        accountObj.BillingState='CA';
        accountObj.BillingStreet='Waters Park Drive';
        accountObj.BillingPostalCode='41223';
        Database.insert(clEntity,true);
        accountObj.clcommon__Legal_Entity_Type__c = clEntity.Id;
        accountObj.genesis__Business_Information__c=businessInfo.Id;
        return accountObj;
    }

    /**
    * @description Creating Sole Prop Co-Borrower Account
    * @author Ayan Bhowmik | 02-20-2024 
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
    * @description Creating Sole Prop buyer Account
    * @author Ayan Bhowmik | 02-20-2024 
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
    * @author Ayan Bhowmik | 02-20-2024 
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
    * @author Ayan Bhowmik | 02-20-2024 
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
    * @description Creating Borrower Contact
    * @author Ayan Bhowmik | 02-20-2024 
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
        contactObj.genesis__SSN__c = 'GHFB6766';
        contactObj.Confirm_SSN__c = 'GHFB6766';
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
    * @description Creating Co-Borrower Contact
    * @author Ayan Bhowmik | 02-20-2024 
    * @param objAccountID 
    * @return Contact 
    **/
    public static Contact createCoBorrowerContact(Id objAccountID){
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
    * @description Creating Buyer Contact
    * @author Ayan Bhowmik | 02-20-2024 
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
    * @author Ayan Bhowmik | 02-20-2024 
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
    * @author Ayan Bhowmik | 02-20-2024 
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
    * @description Creating loan product
    * @author Ayan Bhowmik | 02-20-2024 
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
    * @description Creating Data for CL Product of Application
    * @author Ayan Bhowmik | 02-20-2024 
    * @return clcommon__CL_Product__c 
    **/
    public static clcommon__CL_Product__c createCLProductForApplication() {
        clcommon__CL_Product__c clProductObj = new clcommon__CL_Product__c();
        clProductObj.clcommon__Product_Name__c ='Simpli-Fi';
        return clProductObj;
    }

    /**
    * @description Creating data for Purpose of Application
    * @author Ayan Bhowmik | 02-20-2024 
    * @return clcommon__CL_Purpose__c 
    **/
    public static clcommon__CL_Purpose__c createCLPurposeForApplication() {
        clcommon__CL_Purpose__c  clPurposeObj = new clcommon__CL_Purpose__c();
        clPurposeObj.Name='Crop';
        return clPurposeObj;
    }

    /**
    * @description Creating an Application Which is ACTIVATED for Current Crop Year 
    * @author Ayan Bhowmik | 02-20-2024 
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
    * @description Creating an Application with flex rate 
    * @author Ayan Bhowmik | 02-20-2024 
    * @param clProduct 
    * @param accountObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplicationForFlex(clcommon__CL_Product__c clProduct, Account accountObj){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Account__c = accountObj.Id;
        applicationObj.genesis__Product_Type__c ='Package';
        applicationObj.genesis__Term__c = 19;
        applicationObj.genesis__Interest_Rate__c = 1.45;
        applicationObj.genesis__Loan_Amount__c = 7685;
        applicationObj.genesis__CL_Product__c = clProduct.Id;
        return applicationObj;
    }

    /**
    * @description Creating Rate Card Setup Header
    * @author Ayan Bhowmik | 02-20-2024 
    * @param accountObj 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    public static genesis__Rate_Card_Setup_Header__c createRateCardSetupHeader(Account accountObj){

        String endDateStr = '03/15/2026';
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = new genesis__Rate_Card_Setup_Header__c();
        rateCardHeaderObj.Name = 'My Test Program 99';
        rateCardHeaderObj.genesis__Product_Type__c = PortalConstants.PRODUCT_TYPE_FOR_MY_PROGRAM;
        rateCardHeaderObj.Account__c = accountObj.Id;
        rateCardHeaderObj.CFA_Advantage_Rate__c = 7;
        rateCardHeaderObj.genesis__Description__c = 'This rate card calculates an interest for seed purpose oriented loans';
        rateCardHeaderObj.Crop_Year__c = '2025';
        rateCardHeaderObj.Closing_Fee__c = 200;
        rateCardHeaderObj.Special_Term_Number__c = PortalConstants.SPECIAL_TERM_A;
        rateCardHeaderObj.genesis__Start_Date__c = System.today();
        rateCardHeaderObj.genesis__Transaction_Date__c = System.today();
        rateCardHeaderObj.genesis__End_Date__c = Date.parse(endDateStr);
        rateCardHeaderObj.Payer_of_Loan_Closing_Fee__c = 'Grower';
        rateCardHeaderObj.Loan_Fee_Advanced_On__c = 'A';
        rateCardHeaderObj.Dealer_Participate_on_Closing_Fee__c = 'Yes';
        rateCardHeaderObj.Portion_of_Fee_to_Cover__c = 100;
        return rateCardHeaderObj;
    }

    /**
    * @description Creating Enabled Rate Card Setup Header for Current Year
    * @author Ayan Bhowmik | 02-22-2024 
    * @param accountObj 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
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
        * @description Creating Rate Card Set up Details for Rate Change Class on 45 and 32 days ahead
        * @author Ayan Bhowmik | 02-22-2024 
        * @param myProgramObj 
        * @param applicationObj createThirtyTwoRateChngRateCards
        * @return List<genesis__Rate_Card_Setup_Detail__c> 
        **/
        public static List<genesis__Rate_Card_Setup_Detail__c> createFourtyFiveRateChngRateCards(genesis__Rate_Card_Setup_Header__c myProgramObj, 
                                                                                                    genesis__Applications__c applicationObj){
            List<genesis__Rate_Card_Setup_Detail__c> rateCards = new List<genesis__Rate_Card_Setup_Detail__c>();
            for(integer iterator =0; iterator < 2; iterator++){
                genesis__Rate_Card_Setup_Detail__c eachRate = new genesis__Rate_Card_Setup_Detail__c();
                eachRate.genesis__Pricing_Method__c = PortalConstants.INTEREST_RATE_STRING;
                eachRate.genesis__Rate_Card_Setup_Header__c = myProgramObj.Id;
                eachRate.Interest_Rate_Type__c = 'VARIABLE';
                eachRate.Description__c = 'Seeds';
                if(iterator == 0){
                    eachRate.Start_Date__c = System.today();
                    eachrate.genesis__Interest_Rate__c = 2;
                    eachRate.End_Date__c = System.today().addDays(44);
                }else{
                    eachrate.genesis__Interest_Rate__c = 4;
                    eachRate.Start_Date__c = System.today().addDays(45);
                    eachRate.End_Date__c = myProgramObj.genesis__End_Date__c;
                }
                rateCards.add(eachRate);
            }
            return rateCards;
        }

     /**
        * @description Creating Rate Card Set up Details for Rate Change Class on 45 and 32 days ahead
        * @author Ayan Bhowmik | 02-22-2024 
        * @param myProgramObj 
        * @param applicationObj 
        * @return List<genesis__Rate_Card_Setup_Detail__c> 
        **/
        public static List<genesis__Rate_Card_Setup_Detail__c> createThirtyTwoRateChngRateCards(genesis__Rate_Card_Setup_Header__c myProgramObj, 
                                                                                                genesis__Applications__c applicationObj){
            List<genesis__Rate_Card_Setup_Detail__c> rateCards = new List<genesis__Rate_Card_Setup_Detail__c>();
            for(integer iterator = 0; iterator < 2; iterator++){
                genesis__Rate_Card_Setup_Detail__c eachRate = new genesis__Rate_Card_Setup_Detail__c();
                eachRate.genesis__Pricing_Method__c = PortalConstants.INTEREST_RATE_STRING;
                eachRate.genesis__Rate_Card_Setup_Header__c = myProgramObj.Id;
                eachRate.Interest_Rate_Type__c = 'VARIABLE';
                eachRate.Description__c = 'Seeds';
                if(iterator == 0){
                    eachRate.Start_Date__c = System.today();
                    eachrate.genesis__Interest_Rate__c = 2;  
                    eachRate.End_Date__c = System.today().addDays(31);
                }else{
                    eachrate.genesis__Interest_Rate__c = 4;
                    eachRate.Start_Date__c = System.today().addDays(32);
                    eachRate.End_Date__c = myProgramObj.genesis__End_Date__c;
                }
                rateCards.add(eachRate);
            }
            return rateCards;
    }

    /**
    * @description Creating pricing Details
    * @author Ayan Bhowmik | 02-20-2024 
    * @param applicationId 
    * @return genesis__Application_Pricing_Detail__c 
    **/
    public static genesis__Application_Pricing_Detail__c createPricingDetail(String applicationId){
        genesis__Application_Pricing_Detail__c pricingDetailsObj = new genesis__Application_Pricing_Detail__c();
        pricingDetailsObj.genesis__Maximum_Financed_Amount__c = 15000;
        pricingDetailsObj.genesis__Rate_Factor_Based_On_Amount__c = 100;
        pricingDetailsObj.genesis__Rate_Factor__c = 0.00;
        pricingDetailsObj.genesis__Term__c = 12;
        pricingDetailsObj.genesis__Yield_Percent__c = 0.00;
        pricingDetailsObj.genesis__Application__c = applicationId;
        pricingDetailsObj.Loan_Number__c = '123234345-A';
        pricingDetailsObj.Loan_Id__c = '139001';
        pricingDetailsObj.Maturity_Date__c = Date.today().addYears(1);
        pricingDetailsObj.Interest_Per_Diem__c = 100;
        pricingDetailsObj.Fees__c = 100;
        return pricingDetailsObj;
    }

    /**
    * @description Creating Enabled Pricing Details
    * @author Ayan Bhowmik | 02-20-2024 
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
        //pricingDetailsObj.Loan_Number__c = '300023457';
        pricingDetailsObj.Maturity_Date__c = Date.today().addYears(1);
        pricingDetailsObj.Interest_Per_Diem__c = 100;
        pricingDetailsObj.Fees__c = 100;
        pricingDetailsObj.genesis__Enabled_Flag__c = true;
        pricingDetailsObj.genesis__Rate_Card_Setup_Detail__c = rateCardSetupDetailId;
        return pricingDetailsObj;
    }

    /**
    * @description Creating Disabled Pricing Details
    * @author Ayan Bhowmik | 02-20-2024 
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
    * @description Creating Rate Card To Product Association 
    * @author Ayan Bhowmik | 02-20-2024 
    * @param product 
    * @param rateCard 
    * @return genesis__Product_Rate_Card_Association__c 
    **/
    public static genesis__Product_Rate_Card_Association__c createRateToProductAssociation(clcommon__CL_Product__c product, genesis__Rate_Card_Setup_Header__c rateCard){
        genesis__Product_Rate_Card_Association__c rateToProduct = new genesis__Product_Rate_Card_Association__c();
        rateToProduct.genesis__CL_Product__c = product.Id;
        rateToProduct.genesis__Rate_Card_Setup__c = rateCard.Id;
        return rateToProduct;
    }

    /**
    * @description Creating Additional Factor For My Program
    * @author Ayan Bhowmik | 02-20-2024 
    * @param rateCardHeader 
    * @return genesis__Additional_Determining_Factor__c 
    **/
    public static genesis__Additional_Determining_Factor__c createAdditionalFactorForProgram(genesis__Rate_Card_Setup_Header__c rateCardHeader){
        genesis__Additional_Determining_Factor__c factor = new genesis__Additional_Determining_Factor__c();
        factor.genesis__Field_Value__c = rateCardHeader.Name;
        factor.Name = PortalConstants.MY_PROGRAM_FACTOR_NAME;
        factor.genesis__Evaluation_Operator__c = PortalConstants.FACTOR_EVALUATION_OPERATOR;
        factor.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        factor.genesis__Applicable_for_Application__c = true;
        factor.genesis__Application_Object_API_Name__c = PortalConstants.APPLICATION_API_NAME;
        factor.genesis__Application_Object_Name__c = PortalConstants.APPLICATION_OBJECT_NAME;
        factor.genesis__Application_Field_API_Name__c = PortalConstants.MY_PROGRAM_FIELD_API_NAME;
        factor.genesis__Application_Field_Name__c = PortalConstants.MY_PROGRAM_FIELD_NAME;
        factor.genesis__Application_Field_Type__c = PortalConstants.FIELD_TYPE;
        factor.genesis__Apply_to_all_Rate_Card_Details__c = true;
        return factor;
    }

    /**
    * @description Creating Additional Factor For Dealer
    * @author Ayan Bhowmik | 02-20-2024 
    * @param rateCardHeader 
    * @return genesis__Additional_Determining_Factor__c 
    **/
    public static genesis__Additional_Determining_Factor__c createAdditionalFactorForDealer(genesis__Rate_Card_Setup_Header__c rateCardHeader){
        genesis__Additional_Determining_Factor__c factor = new genesis__Additional_Determining_Factor__c();
        Account accountObj = [SELECT Id, Name FROM Account WHERE Id = :rateCardHeader.Account__c];
        factor.genesis__Field_Value__c = accountObj.Name;
        factor.Name = PortalConstants.DEALER_PROFILE;
        factor.genesis__Evaluation_Operator__c = PortalConstants.FACTOR_EVALUATION_OPERATOR;
        factor.genesis__Rate_Card_Setup_Header__c = rateCardHeader.Id;
        factor.genesis__Applicable_for_Application__c = true;
        factor.genesis__Application_Object_API_Name__c = PortalConstants.APPLICATION_API_NAME;
        factor.genesis__Application_Object_Name__c = PortalConstants.APPLICATION_OBJECT_NAME;
        factor.genesis__Application_Field_API_Name__c = PortalConstants.MY_PROGRAM_DEALER_FIELD;
        factor.genesis__Application_Field_Name__c = PortalConstants.DEALER_NAME;
        factor.genesis__Application_Field_Type__c = PortalConstants.FIELD_TYPE;
        factor.genesis__Apply_to_all_Rate_Card_Details__c = true;
        return factor;
    }

    /**
    * @description Creating New Rate Card Setup Detail
    * @author Ayan Bhowmik | 02-20-2024 
    * @param myProgram 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    public static genesis__Rate_Card_Setup_Detail__c createNewRateCardSetupDetail(genesis__Rate_Card_Setup_Header__c myProgram){

        String startDateStr = '03/03/2025';
        String endDateStr = '03/15/2026';
        genesis__Rate_Card_Setup_Detail__c rateCardDetailObj = new genesis__Rate_Card_Setup_Detail__c();
        rateCardDetailObj.genesis__Rate_Card_Setup_Header__c = myProgram.Id;
        rateCardDetailObj.Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account';
        rateCardDetailObj.Participation_Percentage_CFA__c = 5.5;
        rateCardDetailObj.Participation_Percentage_Dealer__c = 0;
        rateCardDetailObj.Participation_Percentage_Dealer_Subsidy__c = 2;
        rateCardDetailObj.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_A;
        rateCardDetailObj.Interest_Rate_Type__c = 'Fixed';
        Date startDate = Date.parse(startDateStr);
        Date endDate = Date.parse(endDateStr);
        rateCardDetailObj.Start_Date__c = startDate;
        rateCardDetailObj.End_Date__c = endDate;
        rateCardDetailObj.genesis__Interest_Rate__c = 6.5;
        return rateCardDetailObj;
    }

    /**
    * @description Creating Cl Product
    * @author Ayan Bhowmik | 02-20-2024 
    * @return clcommon__CL_Product__c 
    **/
    public static clcommon__CL_Product__c createCLProduct(){
        clcommon__CL_Product__c clProduct = new clcommon__CL_Product__c();
        clProduct.clcommon__Product_Name__c ='SimpliFi';
        return clProduct;
    }
    /**
    * @description Creating Cl Purpose
    * @author Ayan Bhowmik | 02-20-2024 
    * @return clcommon__CL_Purpose__c 
    **/
    public static clcommon__CL_Purpose__c createCLPurpose(){ // duplicate
        clcommon__CL_Purpose__c  clPurposes = new clcommon__CL_Purpose__c();
        clPurposes.Name='Crop';
        return clPurposes;
    }
    /**
    * @description Creating Application
    * @author Ayan Bhowmik | 02-20-2024 
    * @param applicationDataMap 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createApplication(Map<String, Object> applicationDataMap){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Product_Type__c ='Loan';
        applicationObj.genesis__Term__c = 12;
        applicationObj.genesis__Interest_Rate__c = 1;
        applicationObj.genesis__Loan_Amount__c = 35000;
        applicationObj.Peak_Loan_Volume__c = 15000;
        applicationObj.genesis__Maturity_Date__c = Date.today().addYears(1);
        applicationObj.Loan_Id__c = '139000';
        applicationObj.genesis__Loan_Number__c = '398762543';
        applicationObj.Dealer_Name__c = (Id)applicationDataMap.get('dealerAccountObjId');
        applicationObj.genesis__CL_Product__c = (Id)applicationDataMap.get('clProductObjId');
        applicationObj.genesis__CL_Purpose__c = (Id)applicationDataMap.get('clPurposeObjId');
        applicationObj.genesis__Contact__c = (Id)applicationDataMap.get('borrowerContactObjId');
        applicationObj.genesis__Account__c = (Id)applicationDataMap.get('borrowerAccountObjId');
        applicationObj.Sales_Agent__c= (Id)applicationDataMap.get('saAccountObjId');
        applicationObj.Certified_Lender__c = (Id)applicationDataMap.get('clAccountObjId');

        // This part is for application submission 
        applicationObj.Internal_Reference_Code__c = (String)applicationDataMap.get('internalReferenceCode');
        applicationObj.Years_Of_Business_With_Applicant__c = (String)applicationDataMap.get('yearsOfBusiness');
        applicationObj.My_Program__c = (Id)applicationDataMap.get('myProgramId');
        applicationObj.genesis__Status__c = (String)applicationDataMap.get('status');
        applicationObj.genesis__Credit_Rating__c = (Id)applicationDataMap.get('creditRatingId');
        applicationObj.Do_You_Recommend_This_Applicant__c = (String)applicationDataMap.get('recommendThisApplicant');
        return applicationObj;
    }

    // // Assign the required data of application for submission
    // public static genesis__Applications__c updateApplicationForSubmission(Id appId,
    //                                                                       String internalReferenceCode,
    //                                                                       String yearsOfBusiness,
    //                                                                       Id myProgramId,
    //                                                                       Boolean flexRatePricing,
    //                                                                       Boolean acceptApplicableGuaranty,
    //                                                                       String recommendApplication,
    //                                                                       Boolean secondLook){

    //     // Fetch the application with Id
    //     List<genesis__Applications__c> appList = [SELECT Id, name, Internal_Reference_Code__c,  Years_Of_Business_With_Applicant__c, 
    //                                                     My_Program__c, Flex_Rate_Pricing__c, Do_You_Accept_Applicable_Guaranty__c, 
    //                                                     Do_You_Recommend_Second_Look__c
    //                                               FROM genesis__Applications__c
    //                                               WHERE Id =: appId
    //                                               LIMIT 1];

    //     // This part is for application submission 
    //     appList[0].Internal_Reference_Code__c = internalReferenceCode;
    //     appList[0].Years_Of_Business_With_Applicant__c = yearsOfBusiness;
    //     appList[0].My_Program__c = myProgramId;
    //     appList[0].Flex_Rate_Pricing__c = flexRatePricing;
    //     appList[0].Do_You_Accept_Applicable_Guaranty__c = acceptApplicableGuaranty;
    //     appList[0].Do_You_Recommend_Second_Look__c = secondLook;

    //     return applist[0];
    // }


    /**
    * @description Create application object with no data
    * @author Ayan Bhowmik | 02-20-2024 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createBlankApplication(){
        return new genesis__Applications__c();
    }


    /**
    * @description Creating Party Type
    * @author Ayan Bhowmik | 02-20-2024 
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
    * @author Ayan Bhowmik | 02-20-2024 
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
        partyObj.Dealer_Applicant_Relationship__c = paramMap.get('dealerApplicantRelationshipId');
        partyObj.Total_Assets__c = 2346;
        partyObj.Total_Liabilities__c = 2423433;
        return partyObj;
    }


    /**
    * @description Creating the Credit Rating Matrix
    * @author Ayan Bhowmik | 02-20-2024 
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
    * @description Creating CIF Number
    * @author Ayan Bhowmik | 02-20-2024 
    * @return CFA_Configuration__c 
    **/
    public static CFA_Configuration__c createCIFNumber(){
        CFA_Configuration__c cifObj = new CFA_Configuration__c();
        cifObj.CIF_Number__c='32454345';
        cifObj.Growmark_CIF_Number__c = '1000501';
        return cifObj;
    }

    /**
    * @description Create Collateral Category
    * @author Ayan Bhowmik | 02-20-2024 
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
    * @description 
    * @author Soumik Pattanayak | 05-01-2025 
    * @param name 
    * @return clcommon__Collateral_Category__c 
    **/
    public static clcommon__Collateral_Category__c createCollateralCategory(String name){
        clcommon__Collateral_Category__c collateral = new clcommon__Collateral_Category__c();
        collateral.name = name;
        collateral.Collateral_Unit__c = 'BU';
        collateral.Price_Per_Unit_1__c = 10.85;
        collateral.Price_Per_Unit_2__c = 6.85;
        collateral.Commodity_Display_Position__c = 7;
        return collateral;
    }

    /**
    * @description Creating Collateral
    * @author Ayan Bhowmik | 02-20-2024 
    * @param collateralDetailsMap 
    * @return clcommon__collateral__c 
    **/
    public static clcommon__collateral__c createCollateral(Map<String,String> collateralDetailsMap){
         return new clcommon__collateral__c(clcommon__Collateral_Category__c= collateralDetailsMap.get('collateralCategoryId'),
                                            clcommon__Collateral_Name__c='commodity',
                                            Total_Acres__c= 20,
                                            Producer_Share_Percent__c= 50,
                                            Approved_Yield__c= 15,
                                            Insurance_Plan__c=collateralDetailsMap.get('insurancePlan'),
                                            Percent_Coverage_Level__c=collateralDetailsMap.get('percentCoverageLevel'),
                                            Percent_Fed__c= 12);
    }
    /**
    * @description Creating Payment Mode
    * @author Ayan Bhowmik | 02-20-2024 
    * @param paymentMode 
    * @return clcommon__Payment_Mode__c 
    **/
    public static clcommon__Payment_Mode__c createPaymentMode(String paymentMode){
        clcommon__Payment_Mode__c objPaymentMode = new clcommon__Payment_Mode__c(Name=paymentMode);
        return objPaymentMode;
    }
    /**
    * @description Creating Funding
    * @author Ayan Bhowmik | 02-20-2024 
    * @param paymentModeId 
    * @param pricingDetailId 
    * @param applicationId 
    * @return genesis__Funding_Transaction__c 
    **/
    public static genesis__Funding_Transaction__c createFundingTransaction(Id paymentModeId, Id pricingDetailId, Id applicationId){
        genesis__Funding_Transaction__c fundingTransactionObj = new genesis__Funding_Transaction__c();
        fundingTransactionObj.genesis__Payment_Mode__c = paymentModeId;
        fundingTransactionObj.genesis__Funding_Date__c = date.today();
        fundingTransactionObj.genesis__Amount__c = 1500;
        fundingTransactionObj.genesis__Reference__c = 'Crop';
        fundingTransactionObj.Grower_Name__c = 'Grower ABC';
        fundingTransactionObj.Principal_Paid__c = 10;
        fundingTransactionObj.Interest_Paid__c = 10;
        fundingTransactionObj.Fees_Paid__c = 10;
        fundingTransactionObj.Pricing_Detail__c = pricingDetailId;
        fundingTransactionObj.genesis__Application__c = applicationId;
        return fundingTransactionObj;
    }
        /**
    * @description creating collateral 
    * @author Ayan Bhowmik | 02-21-2024 
    * @param blank 
    * @param collateralDetailsMap 
    * @return clcommon__collateral__c 
    **/
    public static clcommon__collateral__c createCollateral(String blank, Map<String, Object> collateralDetailsMap){
         return new clcommon__collateral__c(clcommon__Collateral_Category__c = (Id)collateralDetailsMap.get('collateralCategoryId'),
                                            clcommon__Collateral_Name__c = (String)collateralDetailsMap.get('collateralName'),
                                            Total_Acres__c = (Double)collateralDetailsMap.get('totalAcres'),
                                            Producer_Share_Percent__c = (Double)collateralDetailsMap.get('producerShare'),
                                            Approved_Yield__c = (Double)collateralDetailsMap.get('approvedYield'),
                                            Insurance_Plan__c = (String)collateralDetailsMap.get('insurancePlan'),
                                            Percent_Coverage_Level__c = (String)collateralDetailsMap.get('percentCoverageLevel'),
                                            Percent_Fed__c = (Double)collateralDetailsMap.get('percentFed'),
                                            genesis__Application__c = (Id)collateralDetailsMap.get('appId'),
                                            Price__c = (Decimal)collateralDetailsMap.get('price')
                                            );
    }

    /**
    * @description Creating Task for signed credit agreement
    * @author Ayan Bhowmik | 02-21-2024 
    * @param applicationId 
    * @return Task 
    **/
    public static Task createTask(String applicationId){
        Task signingTaskObj = new Task(Subject = 'Signed Credit Agreement', genesis__Application__c = applicationId);
        return signingTaskObj;
    }

    /**
    * @description Generic method to create tasks
    * @author Ayan Bhowmik | 02-21-2024 
    * @param applicationId 
    * @param subject 
    * @return Task 
    **/
    public static Task createTask(Id applicationId, String subject){
        return new Task(Subject = subject, genesis__Application__c = applicationId);
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 12-12-2024 
    * @param paramMap 
    * @return Task 
    **/
    public static Task createTask(Map<String, String> paramMap){
        return new Task(Subject = paramMap.get('subject'), 
                        genesis__Application__c = paramMap.get('applicationId'),
                        Status = paramMap.get('status'),
                        Comments__c = paramMap.get('comments'));
    }

    /**
    * @description Creating Doc Category
    * @author Ayan Bhowmik | 02-21-2024 
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
    * @description Creating Bank Info
    * @author Ayan Bhowmik | 02-21-2024 
    * @return clcommon__Bank_Account__c 
    **/
    public static clcommon__Bank_Account__c createBankAccount(){
        clcommon__Bank_Account__c bankInfo = new clcommon__Bank_Account__c();
        bankInfo.clcommon__Bank_Account_Number__c = '5003101002225';
        bankInfo.clcommon__Bank_Account_Name__c = 'Sam Grower';
        bankInfo.clcommon__Routing_Number__c = '123456789';
        return bankInfo;
    }


    /**
    * @description Create Envelop Status
    * @author Ayan Bhowmik | 02-21-2024 
    * @param appId 
    * @param status 
    * @return dfsle__EnvelopeStatus__c 
    **/
    public static dfsle__EnvelopeStatus__c createEnvelopeStatus(Id appId, String status){
        dfsle__EnvelopeStatus__c envelopStatusObj = new dfsle__EnvelopeStatus__c();
        envelopStatusObj.dfsle__Status__c = status;
        envelopStatusObj.dfsle__SourceId__c = appId;
        return envelopStatusObj;
    }

    /**
    * @description Create Recipient Status
    * @author Ayan Bhowmik | 02-21-2024 
    * @param envelopeId 
    * @return dfsle__RecipientStatus__c 
    **/
    public static dfsle__RecipientStatus__c createRecipientStatus(Id envelopeId){
        dfsle__RecipientStatus__c recipientStatusObj = new dfsle__RecipientStatus__c();
        recipientStatusObj.dfsle__EnvelopeStatus__c = envelopeId;
        return recipientStatusObj;
    }

    /**
    * @description Create Content Version
    * @author Ayan Bhowmik | 02-21-2024 
    * @return ContentVersion 
    **/
    public static ContentVersion createContentVersion(){
        ContentVersion objContent=new ContentVersion();
        objContent.description = 'This is a test Content version';
        objContent.Title='Credit Application Agreement.pdf';
        objContent.PathOnClient='/'+objContent.Title+'.pdf';
        // Blob blobObj = Blob.valueOf('Test Content');
        objContent.VersionData=EncodingUtil.base64Decode('Test Content');
        objContent.IsMajorVersion = true;
        return objContent;
    }

    /**
    * @description 
    * @author Ayan Bhowmik | 02-21-2024 
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
    * @description Test data for credit application agreement content document 
    * @author Ayan Bhowmik | 02-21-2024 
    * @return ContentDocument 
    **/
    public static ContentDocument createContentDocument() {
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE Title = :PortalConstants.AGREEMENT_FILE_NAME LIMIT 1];
        return contentDocuments[0];
    }

    /**
    * @description Generic method to create content documents
    * @author Ayan Bhowmik | 02-21-2024 
    * @param fileName 
    * @return ContentDocument 
    **/
    public static ContentDocument createContentDocument(String fileName) {
        List<ContentDocument> contentDocuments = [SELECT Id FROM ContentDocument WHERE Title = :fileName LIMIT 1];
        return contentDocuments[0];
    }

    /**
    * @description creating content document to create content document link
    * @author Ayan Bhowmik | 02-21-2024 
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
    * @description creating docusign envelope
    * @author Ayan Bhowmik | 02-21-2024 
    * @param applicationId 
    * @return dfsle__Envelope__c 
    **/
    public static dfsle__Envelope__c createDocusignEnvelope(Id applicationId){
        dfsle__Envelope__c envelope = new dfsle__Envelope__c();
        envelope.dfsle__SourceId__c = applicationId;
        envelope.dfsle__DocuSignId__c = 'd5f4f3be-fe59-4819-aab1-1ded04720sf';
        return envelope;
    }

    /**
    * @description creating docusign envelope status
    * @author Ayan Bhowmik | 02-21-2024 
    * @param applicationId 
    * @return dfsle__EnvelopeStatus__c 
    **/
    public static dfsle__EnvelopeStatus__c createDocusignEnvelopeStatus(Id applicationId){
        dfsle__EnvelopeStatus__c dsStatus = new dfsle__EnvelopeStatus__c();
        dsStatus.dfsle__SourceId__c = applicationId; 
        dsStatus.dfsle__DocuSignId__c = 'd5f4f3be-fe59-4819-aab1-1ded04720sf';
        return dsStatus;
    }
    /**
    * @description creating docusign recipient 
    * @author Ayan Bhowmik | 02-21-2024 
    * @param envelopeId 
    * @param contactId 
    * @return dfsle__Recipient__c 
    **/
    public static dfsle__Recipient__c createDocusignRecipient(Id envelopeId,Id contactId){
        dfsle__Recipient__c dsRecipient = new dfsle__Recipient__c();
        dsRecipient.dfsle__Role__c = 'Signer 1';
        dsRecipient.dfsle__Envelope__c = envelopeId;
        dsRecipient.dfsle__Email__c = 'abc@yopmail.com';
        dsRecipient.dfsle__SourceId__c = contactId;
        return dsRecipient;
    }
    /**
    * @description creating recipient status
    * @author Ayan Bhowmik | 02-21-2024 
    * @param envelopeStatus 
    * @param contactId 
    * @return dfsle__RecipientStatus__c 
    **/
    public static dfsle__RecipientStatus__c createRecipientStatus(Id envelopeStatus,Id contactId){
        dfsle__RecipientStatus__c recipient = new dfsle__RecipientStatus__c();
        recipient.dfsle__EnvelopeStatus__c = envelopeStatus;
        recipient.dfsle__Status__c = 'Sent';
        recipient.dfsle__SourceId__c = contactId;
        return recipient;
    }

    /**
    * @description creating task setup
    * @author Ayan Bhowmik | 02-21-2024 
    * @param taskSetupName 
    * @return genesis__Task_Setup__c 
    **/
    public static genesis__Task_Setup__c createTaskSetup(String taskSetupName){
        genesis__Task_Setup__c taskSetup = new genesis__Task_Setup__c(genesis__Object_Type__c = 'genesis__Applications__c', genesis__Task_Name__c = taskSetupName);
        return taskSetup;
    }

    /**
    * @description creating departments by name
    * @author Ayan Bhowmik | 02-21-2024 
    * @param departmentName 
    * @return genesis__Department__c 
    **/
    public static genesis__Department__c createDepartmentByName(String departmentName){
        genesis__Department__c objDepartment = new genesis__Department__c(Name = 'Credit');
        return objDepartment;
    }

    
    /**
    * @description creating CFA user by profile
    * @author Ayan Bhowmik | 02-21-2024 
    * @param profileId 
    * @return User 
    **/
    public static User createCFAUserByProfile(Id profileId) {
        // Account objAccount = new Account(
        //         Name='Test CFA Account', 
        //         CIF_Number__c = '115282', 
        //         BillingCity = 'Seattle', 
        //         BillingState = 'WA'
        //     );
        // Database.insert(objAccount, true);
        // Contact objContact = new Contact(
        //         LastName = 'Test CFA Contact', 
        //         Email='test.account@yopmail.com', 
        //         accountId = objAccount.Id
        //     );
        // Database.insert(objContact, true);
        User objUser = new User(
                    Alias = 'newUser', 
                    Email='cfanewuser@yopmail.com',
                    EmailEncodingKey='UTF-8',
                    LastName='Testing', 
                    LanguageLocaleKey='en_US',
                    LocaleSidKey='en_US',
                    ProfileId = profileId, 
                    TimeZoneSidKey='America/Los_Angeles', 
                    UserName='cfanewuser@yopmail.com',
                    User_Number__c = 11223344
                );
        //Database.insert(objUser, true);
        return objUser;
    }
    /**
    * @description creating account document category
    * @author Ayan Bhowmik | 02-21-2024 
    * @param dealerId 
    * @return clcommon__Document_Category__c 
    **/
    public static clcommon__Document_Category__c createAccDocumentCategory(String dealerId){
        clcommon__Document_Category__c objCategory = new clcommon__Document_Category__c();
        objCategory.clcommon__Account__c = dealerId;
        objCategory.clcommon__Active__c = true;
        objCategory.clcommon__Category_Name__c = 'ACH Debit Agreement';
        return objCategory;
    }
    
    /**
    * @description 
    * @author Soumik Pattanayak | 12-12-2024 
    * @param paramMap 
    * @return clcommon__Document_Category__c 
    **/
    public static clcommon__Document_Category__c createDocumentCategory(Map<String, String> paramMap){
        clcommon__Document_Category__c objCategory = new clcommon__Document_Category__c();
        objCategory.genesis__Application__c = paramMap.get('applicationId');
        objCategory.clcommon__Status__c = paramMap.get('status');
        objCategory.clcommon__Show_In_Portal__c = paramMap.get('showInPortal');
        objCategory.clcommon__Category_Name__c = paramMap.get('categoryName');
        return objCategory;
    }
    /**
    * @description creating attachment association
    * @author Ayan Bhowmik | 02-21-2024 
    * @param objCategory 
    * @param dealerId 
    * @return clcommon__Category_Attachment_Association__c 
    **/
    public static clcommon__Category_Attachment_Association__c createAttachmentAssociation(clcommon__Document_Category__c objCategory,String dealerId){
        clcommon__Category_Attachment_Association__c objAssociation = new clcommon__Category_Attachment_Association__c();
        objAssociation.clcommon__Document_Category__c = objCategory.id;
        objAssociation.Account__c = dealerId;
        return objAssociation;
    }
        
    /**
    * @description Creating Dealer Contact Record
    * @author Simran | 03-29-2024 
    * @param dealerAccountId 
    * @param dealerContactRecordType 
    * @return Account 
    **/
    public static Account createDealerContactRecord(Id dealerAccountId,String dealerContactRecordType){
        Account clAccountObj = new Account();
        clAccountObj.Name = 'Ross Grey';
        clAccountObj.Phone = '666714908';
        clAccountObj.BillingStreet = '2423 6th Avenue';
        clAccountObj.BillingCity = 'Frankenmouth';
        clAccountObj.BillingState = 'WA';
        clAccountObj.BillingPostalCode = '61232';
        clAccountObj.CIF_Number__c = '009988';
        clAccountObj.clcommon__Email__c = 'ross.grey@yopmail.com';
        clAccountObj.ParentId = dealerAccountId;
        Account parentAccountBusinessInfo=[SELECT genesis__Business_Information__c FROM Account WHERE  Id=:dealerAccountId];
        clAccountObj.genesis__Business_Information__c = parentAccountBusinessInfo.genesis__Business_Information__c;
        clAccountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get(dealerContactRecordType).getRecordTypeId();
        return clAccountObj;
    }  
    
    /**
    * @description Blank App Record
    * @author Simran | 03-29-2024 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c createBlankApplicationRecord(){
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        applicationObj.genesis__Status__c = 'New Entered';
        return applicationObj;

    }

    /**
    * @description : Creates grower account for Individual Sole Prop entity type
    * @author Tuhin Bhunia | 04-11-2024 
    * @param entityObj 
    * @param businessInfoId 
    * @param dealerAccountId 
    * @return Account 
    **/
    public static Account createSolePropAccount(clcommon__Legal_Entity__c entityObj, 
                                                            Id businessInfoId,
                                                            Id dealerAccountId){  
        Account accountObj = new Account();
        accountObj.Name = 'Jasmine Albin';
        accountObj.clcommon__Email__c ='jasmin.albin@yopmail.com';
        accountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        accountObj.genesis__Business_Information__c = businessInfoId;
        accountObj.BillingCity = 'Kolkata';
        accountObj.BillingState = 'WA';
        accountObj.Billing_County__c = 'fghu';
        accountObj.Work_Number__c = '098765678';
        accountObj.ParentId = dealerAccountId;
        accountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        return accountObj;
    }

    /**
    * @description : Creates grower account for Corporation entity type
    * @author Tuhin Bhunia | 04-11-2024 
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
    * @author Krishanu Chinya | 04-11-2024 
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
    * @description : Creates grower account for Trust entity type
    * @author Tuhin Bhunia | 04-11-2024 
    * @param entityObj 
    * @param businessInfoId
    * @param dealerAccountId 
    * @return Account 
    **/
    public static Account createTrustAccount(clcommon__Legal_Entity__c entityObj, 
                                                            Id businessInfoId,
                                                            Id dealerAccountId){  
        Account accountObj = new Account();
        accountObj.Name = 'Johny Lawrence Foundation';
        accountObj.clcommon__Email__c='lawrence.foundation@yopmail.com';
        accountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        accountObj.genesis__Business_Information__c=businessInfoId;
        accountObj.BillingCity = 'Kansas';
        accountObj.BillingState = 'KS';
        accountObj.Billing_County__c='Olathe';
        accountObj.BillingPostalCode = '73859';
        accountObj.Work_Number__c='7734928510';
        accountObj.ParentId = dealerAccountId;
        accountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        return accountObj;
    }

    /**
    * @description : Creates grower account for Trust entity type
    * @author Tuhin Bhunia | 04-11-2024 
    * @param entityObj 
    * @param businessInfoId
    * @param dealerAccountId 
    * @return Account 
    **/
    public static Account createDBAAccount(clcommon__Legal_Entity__c entityObj, 
                                                            Id businessInfoId,
                                                            Id dealerAccountId){  
        Account accountObj = new Account();
        accountObj.Name = 'Farm to table';
        accountObj.clcommon__Email__c='farm2table@yopmail.com';
        accountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        accountObj.genesis__Business_Information__c = businessInfoId;
        accountObj.BillingCity = 'Kansas';
        accountObj.BillingState = 'KS';
        accountObj.Billing_County__c = 'Olathe';
        accountObj.BillingPostalCode = '73859';
        accountObj.Work_Number__c = '7384925899';
        accountObj.ParentId = dealerAccountId;
        accountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        return accountObj;
    }

    /**
    * @description : Creates grower account for General Partnership entity type
    * @author Tuhin Bhunia | 04-11-2024 
    * @param entityObj 
    * @param businessInfoId
    * @param dealerAccountId 
    * @return Account 
    **/
    public static Account createGeneralPartnershipAccount(clcommon__Legal_Entity__c entityObj, 
                                                                        Id businessInfoId,
                                                                        Id dealerAccountId){  
        Account accountObj = new Account();
        accountObj.Name = 'Alliance Farm Pvt. Ltd.';
        accountObj.clcommon__Email__c='alliance.farm@yopmail.com';
        accountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        accountObj.genesis__Business_Information__c=businessInfoId;
        accountObj.BillingCity = 'Kansas';
        accountObj.BillingState = 'KS';
        accountObj.Billing_County__c='Olathe';
        accountObj.BillingPostalCode = '93748';
        accountObj.Work_Number__c='8293740293';
        accountObj.ParentId = dealerAccountId;
        accountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        return accountObj;
    }

    /**
    * @description : Creates grower account for Limited Partnership entity type
    * @author Tuhin Bhunia | 04-11-2024 
    * @param entityObj 
    * @param businessInfoId
    * @param dealerAccountId 
    * @return Account 
    **/
    public static Account createLimitedPartnershipAccount(clcommon__Legal_Entity__c entityObj, 
                                                                        Id businessInfoId,
                                                                        Id dealerAccountId){  
        Account accountObj = new Account();
        accountObj.Name = 'EmberEdge Pvt. Ltd.';
        accountObj.clcommon__Email__c='emberedge@yopmail.com';
        accountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        accountObj.genesis__Business_Information__c=businessInfoId;
        accountObj.BillingCity = 'Kansas';
        accountObj.BillingState = 'KS';
        accountObj.Billing_County__c='Olathe';
        accountObj.BillingPostalCode = '93859';
        accountObj.Work_Number__c='8293740293';
        accountObj.ParentId = dealerAccountId;
        accountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        return accountObj;
    }

    /**
    * @description : Creates grower account for Limited Liability Company entity type
    * @author Tuhin Bhunia | 04-11-2024 
    * @param entityObj 
    * @param businessInfoId
    * @param dealerAccountId 
    * @return Account 
    **/
    public static Account createLLCAccount(clcommon__Legal_Entity__c entityObj, 
                                                        Id businessInfoId,
                                                        Id dealerAccountId){  
        Account accountObj = new Account();
        accountObj.Name = 'Skyline Pvt. Ltd.';
        accountObj.clcommon__Email__c='skyline@yopmail.com';
        accountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        accountObj.genesis__Business_Information__c=businessInfoId;
        accountObj.BillingCity = 'Kansas';
        accountObj.BillingState = 'KS';
        accountObj.Billing_County__c='Olathe';
        accountObj.BillingPostalCode = '36277';
        accountObj.Work_Number__c='6374938477';
        accountObj.ParentId = dealerAccountId;
        accountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        return accountObj;
    }

    /**
    * @description : Creates grower account for Joint Venture entity type
    * @author Tuhin Bhunia | 04-11-2024 
    * @param entityObj 
    * @param businessInfoId
    * @param dealerAccountId 
    * @return Account 
    **/
    public static Account createJointVentureAccount(clcommon__Legal_Entity__c entityObj, 
                                                                Id businessInfoId,
                                                                Id dealerAccountId){  

        genesis__Business_Information__c businessInfoObj = createBusinessInfoForBorrower();
        Account accountObj = new Account();
        accountObj.Name = 'Green Field Enterprises';
        accountObj.clcommon__Email__c='greenfield.enterprises@yopmail.com';
        accountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        accountObj.genesis__Business_Information__c = businessInfoObj.Id;
        accountObj.BillingCity = 'Kansas';
        accountObj.BillingState = 'KS';
        accountObj.Billing_County__c='Olathe';
        accountObj.BillingPostalCode = '90364';
        accountObj.Work_Number__c='6374838533';
        accountObj.ParentId = dealerAccountId;
        accountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        return accountObj;
    }

    /**
    * @description : Creates Contact for non-individual entities
    * @author Tuhin Bhunia | 04-11-2024 
    * @param accountObj 
    * @return Contact 
    **/
    public static Contact createContactForNonIndividuals(Account accountObj){  

        Contact contactObj = new Contact();
        contactObj.FirstName = '';
        contactObj.LastName = accountObj.Name;
        contactObj.Email = accountObj.clcommon__Email__c;
        contactObj.Phone = accountObj.Work_Number__c;
        contactObj.MobilePhone = accountObj.Work_Number__c;
        contactObj.accountId = accountObj.Id;
        contactObj.MailingCity = accountObj.BillingCity;
        contactObj.MailingState = accountObj.BillingState;
        contactObj.Mailing_County__c = accountObj.Billing_County__c;
        contactObj.MailingPostalCode = accountObj.BillingPostalCode;
        return contactObj;
    }

    /**
    * @description : This method returns multiple legal entity objects
    * @author Tuhin Bhunia | 04-11-2024 
    * @return Map<String, clcommon__Legal_Entity__c> 
    **/
    public static Map<String, clcommon__Legal_Entity__c> createMultipleLegalEntity(){

        Map<String, clcommon__Legal_Entity__c> legalEntityMap = new Map<String, clcommon__Legal_Entity__c>{

            PortalConstants.INDIVIDUAL_ENTITY => createLegalEntity(PortalConstants.INDIVIDUAL_ENTITY), // DBA entity
            PortalConstants.SOLE_PROP_ENTITY => createLegalEntity(PortalConstants.SOLE_PROP_ENTITY),
            PortalConstants.CORPORATION => createLegalEntity(PortalConstants.CORPORATION),
            PortalConstants.LIMITED_LIABILITY_COMPANY => createLegalEntity(PortalConstants.LIMITED_LIABILITY_COMPANY),
            PortalConstants.GENERAL_PARTNERSHIP => createLegalEntity(PortalConstants.GENERAL_PARTNERSHIP),
            PortalConstants.LIMITED_PARTNERSHIP => createLegalEntity(PortalConstants.LIMITED_PARTNERSHIP),
            PortalConstants.JOINT_VENTURE => createLegalEntity(PortalConstants.JOINT_VENTURE),
            PortalConstants.TRUST => createLegalEntity(PortalConstants.TRUST)
        };
        return legalEntityMap;
    }

    /**
    * @description : This method returns multiple party type objects
    * @author Krishanu Chinya | 09-04-2024 
    * @return Map<String, clcommon__Party_Type__c> 
    **/
    public static Map<String, clcommon__Party_Type__c> createMultiplePartyType(){

        Map<String, clcommon__Party_Type__c> partyTypeMap = new Map<String, clcommon__Party_Type__c>{

            PortalConstants.DEALER_PARTY_NAME => createPartyType(PortalConstants.DEALER_PARTY_NAME),

            PortalConstants.CL_PARTY_NAME => createPartyType(PortalConstants.CL_PARTY_NAME), 
            PortalConstants.CL_PLUS_PARTY_NAME => createPartyType(PortalConstants.CL_PLUS_PARTY_NAME),

            PortalConstants.SALES_AGENT_PARTY_NAME => createPartyType(PortalConstants.SALES_AGENT_PARTY_NAME),
            PortalConstants.SALES_AGENT_PLUS_PARTY_NAME => createPartyType(PortalConstants.SALES_AGENT_PLUS_PARTY_NAME),

            PortalConstants.INQUIRY_PARTY_NAME => createPartyType(PortalConstants.INQUIRY_PARTY_NAME),
            PortalConstants.INQUIRY_PLUS_PARTY_NAME => createPartyType(PortalConstants.INQUIRY_PLUS_PARTY_NAME),

            PortalConstants.PAYMENT_ADMINISTRATOR_PARTY => createPartyType(PortalConstants.PAYMENT_ADMINISTRATOR_PARTY),
            PortalConstants.FIELD_STAFF_AGENT_PARTY => createPartyType(PortalConstants.FIELD_STAFF_AGENT_PARTY),
            PortalConstants.SALES_AGENT_ADMIN_PARTY => createPartyType(PortalConstants.SALES_AGENT_ADMIN_PARTY),

            PortalConstants.BORROWER_PARTY_NAME => createPartyType(PortalConstants.BORROWER_PARTY_NAME),
            PortalConstants.PRINCIPAL_PARTY_NAME => createPartyType(PortalConstants.PRINCIPAL_PARTY_NAME)
        };
        return partyTypeMap;
    }

    /**
    * @description : creates all types of dealer roles
    * @author Krishanu Chinya | 09-04-2024 
    * @return Map<String, clcommon__Reciprocal_Role__c> 
    **/
    public static Map<String, clcommon__Reciprocal_Role__c> createDealerRoles(){
        Map<String, clcommon__Reciprocal_Role__c> rolesMap = new Map<String, clcommon__Reciprocal_Role__c>{
            'clRole' => ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.CERTIFIED_LENDER),
            'clPlusRole' => ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.CERTIFIED_LENDER_PLUS),
            'saRole' => ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.SALES_AGENT),
            'saPlusRole' => ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.SALES_AGENT_PLUS),
            'inqRole' => ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.INQUIRY),
            'inqPlusRole' => ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.INQUIRY_PLUS),
            'paRole' => ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.PAYMENT_ADMINISTRATOR),
            'fsaRole' => ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.FIELD_STAFF_AGENT),
            'saaRole' => ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.SALES_AGENT_ADMIN),
            'rsaRole' => ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.RELATED_SALES_AGENT)
        };
        return rolesMap;
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-11-2024 
    * @return Map<String, genesis__Business_Information__c> 
    **/
    public static Map<String, genesis__Business_Information__c> createMultipleBusinessInfo(){

        Map<String, genesis__Business_Information__c> businessInfoMap = new Map<String, genesis__Business_Information__c>{
            'dealerBusinessInfoObj' => createBusinessInfoForDealer(),
            'individualBusinessInfoObj' => createBusinessInfoForBorrower('339814629'),
            'corporationBusinessInfoObj' => createBusinessInfoForBorrower('927483938'),
            'llcBusinessInfoObj' => createBusinessInfoForBorrower('492749749'),
            'jointVentureBusinessInfoObj' => createBusinessInfoForBorrower('553758375'),
            'trustBusinessInfoObj' => createBusinessInfoForBorrower('846586358'),
            'generalPartnerBusinessInfoObj' => createBusinessInfoForBorrower('467398479'),
            'limitedPartnerBusinessInfoObj' => createBusinessInfoForBorrower('983546617'),
            'dbaBusinessInfoObj' => createBusinessInfoForBorrower('738402957')
        };
        return businessInfoMap;
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-11-2024 
    * @param tin 
    * @return genesis__Business_Information__c 
    **/
    public static genesis__Business_Information__c createBusinessInfoForBorrower(String tin){        
        genesis__Business_Information__c businessInfoObj = new genesis__Business_Information__c();
        businessInfoObj.genesis__Business_Country__c = 'USA';
        businessInfoObj.Remaining_Customised_Limit__c = 100000;
        businessInfoObj.Contract_Loan_Limit__c = 500000;
        businessInfoObj.Approved_Loan_Amount__c = 200000;
        businessInfoObj.genesis__Tax_Identification_Number__c = tin;
        businessInfoObj.genesis__Total_Liabilities__c = 2346;
        businessInfoObj.genesis__Total_Assets__c = 987683;
        
        return businessInfoObj;
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-11-2024 
    * @param legalEntityMap 
    * @param businessInfoMap 
    * @param dealerAccountId 
    * @return List<Account> 
    **/
    public static Map<String, Account> createDifferentGrowerAccounts(Map<String, clcommon__Legal_Entity__c> legalEntityMap, Map<String, genesis__Business_Information__c> businessInfoMap, Id dealerAccountId){

        Map<String, Account> accountMap = new Map<String, Account>{
            
            'solePropAccountObj' => createSolePropAccount(legalEntityMap.get(PortalConstants.SOLE_PROP_ENTITY), businessInfoMap.get('individualBusinessInfoObj').Id, dealerAccountId),
            'corporationAccountObj' => createCorporationAccount(legalEntityMap.get(PortalConstants.CORPORATION), businessInfoMap.get('corporationBusinessInfoObj').Id, dealerAccountId),
            'llcAccountObj' => createLLCAccount(legalEntityMap.get(PortalConstants.LIMITED_LIABILITY_COMPANY), businessInfoMap.get('llcBusinessInfoObj').Id, dealerAccountId),
            'generalPartnershipAccountObj' => createGeneralPartnershipAccount(legalEntityMap.get(PortalConstants.GENERAL_PARTNERSHIP), businessInfoMap.get('generalPartnerBusinessInfoObj').Id, dealerAccountId),
            'limitedPartnershipAccountObj' => createLimitedPartnershipAccount(legalEntityMap.get(PortalConstants.LIMITED_PARTNERSHIP), businessInfoMap.get('limitedPartnerBusinessInfoObj').Id, dealerAccountId),
            'jointVentureAccountObj' => createJointVentureAccount(legalEntityMap.get(PortalConstants.JOINT_VENTURE), businessInfoMap.get('jointVentureBusinessInfoObj').Id, dealerAccountId),
            'trustAccountObj' => createTrustAccount(legalEntityMap.get(PortalConstants.TRUST), businessInfoMap.get('trustBusinessInfoObj').Id, dealerAccountId),
            'dbaAccountObj' => createDBAAccount(legalEntityMap.get(PortalConstants.INDIVIDUAL_ENTITY), businessInfoMap.get('dbaBusinessInfoObj').Id, dealerAccountId)
        };

        return accountMap;
    }
    /**
    * @description This method return system admin user.
    * @author Ayan Bhowmik | 04-14-2024 
    * @return User 
    **/
    public static User getSystemAdminUser(){
        return [SELECT Id 
                FROM User 
                WHERE Profile.name = 'System Administrator' 
                AND isActive = true 
                LIMIT 1];
    }

     //Docusign Method
    /**
     * @description Creating Envelope for Docusign
     * @param applicationId 
     * @return  `dfsle__Envelope__c`
     */
    public static dfsle__Envelope__c createEnvelope(String applicationId){
        dfsle__Envelope__c envelope = new dfsle__Envelope__c();
        envelope.dfsle__SourceId__c =  applicationId;
        envelope.dfsle__DocuSignId__c = 'd5f4f3be-fe59-4819-aab1-1ded04720sf';
        return envelope;
    }
    /**
     * @description Creating Envelope Status for Docusign
     * @param applicationId 
     * @return  `dfsle__EnvelopeStatus__c`
     */
    public static dfsle__EnvelopeStatus__c createEnvelopeStatus(String applicationId){
        dfsle__EnvelopeStatus__c dsStatus = new dfsle__EnvelopeStatus__c();
        dsStatus.dfsle__SourceId__c = applicationId; 
        dsStatus.dfsle__DocuSignId__c = 'd5f4f3be-fe59-4819-aab1-1ded04720sf';
        return dsStatus;
    }
    /**
     * @description Creating Envelope Recipient for Docusign
     * @param principalContactId 
     * @param envelopeId 
     * @return  `dfsle__Recipient__c`
     */
    public static dfsle__Recipient__c createEnvelopeRecipient(String principalContactId,String envelopeId){
        dfsle__Recipient__c dsRecipient = new dfsle__Recipient__c();
        dsRecipient.dfsle__Role__c = 'Signer 1';
        dsRecipient.dfsle__Envelope__c = envelopeId;
        dsRecipient.dfsle__Email__c = 'abc@yopmail.com';
        dsRecipient.dfsle__SourceId__c = principalContactId;
        return dsRecipient;
    }
    /**
     * @description Create Envelope Recipient Status for Docusign
     * @param principalContactId 
     * @param envelopeStatusId 
     * @return  `dfsle__RecipientStatus__c`
     */
    public static dfsle__RecipientStatus__c createEnvelopeRecipientStatus(String principalContactId,String envelopeStatusId){
        dfsle__RecipientStatus__c recipient = new dfsle__RecipientStatus__c();
        recipient.dfsle__EnvelopeStatus__c = envelopeStatusId;
        recipient.dfsle__Status__c = 'Sent';
        recipient.dfsle__SourceId__c = principalContactId;
        return recipient;
    }
    /**
     * @description Create Docusign Parameter Configuration
     * @return  `CFA_Configuration__c`
     */
    public static CFA_Configuration__c createDocusignParameterConfig(){
        CFA_Configuration__c dsConfigParams = new CFA_Configuration__c();
        dsConfigParams.Docusign_Account_Id__c = '62c78cf7-398a-4dcf-ab2c-50ac86abae90';
        dsConfigParams.Docusign_Api_Version__c = 'v2.1';
        dsConfigParams.Docusign_Audience__c = 'account-d.docusign.com';
        dsConfigParams.Docusign_Integration_Key__c = 'lnyY+mNpZ9TIcN8nVA7NpGuFEPYNlLblKlYx9F/ZbS/cuoX5tci1UbtDOwQ75GSGd9BgHT6MBm4zLvf9LYtPcw==';
        dsConfigParams.Docusign_CFA_Return_Url__c = 'https://demo.docusign-d14211e6-33c6-436a-8a16-5f77c2c8a3ff';
        dsConfigParams.Docusign_Token_Endpoint__c = 'https://account-d.docusign.com/oauth/token';
        dsConfigParams.Docusign_User_Id__c = 'gOebdVIFdBCSXr81tiJw8Ns7AeDyIIcLftcs4PjCHYmgXhnSMbxDhf2o03CxZzD9Cde2C7iNfReAQX0lI1367w==';
        dsConfigParams.Docusign_GMK_Return_Url__c = 'https://demo.docusign-d14211e6-33c6-436a-8a16-5f77c2c8a3ff';
        dsConfigParams.Docusign_Landus_Return_Url__c = 'https://demo.docusign-d14211e6-33c6-436a-8a16-5f77c2c8a3ff';
        dsConfigParams.Docusign_Decrypt_Key__c = 'WmEJcH+x6qfajmN/EMaeZw==';
        return dsConfigParams;
    }
        /**
     * @description CFA configuration for decrypting the email change token
     * @return  `CFA_Configuration__c`
     */
    public static CFA_Configuration__c createEmailChangeDecryptionConfig(){
        CFA_Configuration__c emailChangeConfigParams = new CFA_Configuration__c();
        emailChangeConfigParams.Email_Change_Decryption_Key__c = 'MTIzNDU2NzhBQkNERUZHSA==';
        return emailChangeConfigParams;
    }

    /**
    * @description Creating AccountShare Record for dealer contacts.
    * @author Ayan Bhowmik | 06-10-2024 
    * @param dealerContactAccountId 
    * @param dealerContactUserId 
    * @return AccountShare 
    **/
    public static AccountShare createAccountShareRecord(Id dealerContactAccountId, Id dealerContactUserId){
        AccountShare newAccShare = new AccountShare();
        newAccShare.AccountAccessLevel = ConstantValues.ACCESS_LABEL_EDIT;
        newAccShare.AccountId = dealerContactAccountId;
        newAccShare.UserOrGroupId = dealerContactUserId;
        newAccShare.OpportunityAccessLevel = ConstantValues.OPPORTUNITY_ACCESS_LEVEL;
        return newAccShare;
    }

    // Grey label test helper methods start here

    /**
    * @description Creating Floating Rate Index.
    * @author Ayan Bhowmik | 06-19-2024 
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
    * @description Creating Floating Rate.
    * @author Ayan Bhowmik | 06-19-2024 
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
    * @description Creating a partner obj record.
    * @author Ayan Bhowmik | 06-19-2024 
    * @param floatingRateIndexObj 
    * @return CFA_Partner_Program 
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
        partnerProgramObj.Statement_Code_Multi_Rate_Opt_In__c = 'COMMITMENT MULTI OPT IN';
        partnerProgramObj.Statement_Code_Multi_Rate_Opt_Out__c = 'COMMITMENT MULTI OPT OUT';
        partnerProgramObj.Statement_Code_Single_Rate_Opt_In__c = 'COMMITMENT SINGLE OPT IN';
        partnerProgramObj.Statement_Code_Single_Rate_Opt_Out__c = 'COMMITMENT SINGLE OPT OUT';
        partnerProgramObj.Toll_Free_Number__c = '1234567890';
        partnerProgramObj.Transaction_Code__c = 123;
        partnerProgramObj.Website_Link__c = 'https://google.com';
        partnerProgramObj.Base_Rate__c = floatingRateIndexObj.Id;
        partnerProgramObj.Dealer_Portal_Logo__c = 'cfaLogo';
        partnerProgramObj.NLS_User_Defined_Field__c = 'CFA';
        return partnerProgramObj;
    }

    /**
    * @description Creating Content Version.
    * @author Ayan Bhowmik | 06-19-2024 
    * @param paramMap 
    * @param versionDataString 
    * @return ContentVersion 
    **/
    public static ContentVersion createContentVersion(Map<String, String> paramMap, String versionDataString){
        ContentVersion contentVersionObj = new ContentVersion();
        contentVersionObj.Title = paramMap.get('Title');
        contentVersionObj.PathOnClient = paramMap.get('Title');
        contentVersionObj.VersionData = Blob.valueOf(versionDataString);
        return contentVersionObj;
    }

    /**
    * @description Creating Floating Rate Index.
    * @param name Name of the Floating Rate Index
    * @param currentFloatingRate Value of the Floating Rate index
    * @return clcommon__Floating_Rate_Index__c 
    **/
    public static clcommon__Floating_Rate_Index__c createFloatingRateIndex(String name, Decimal currentFloatingRate){
        clcommon__Floating_Rate_Index__c floatingRateIndex = new clcommon__Floating_Rate_Index__c(
            Name = name,
            clcommon__Active__c = true,
            Current_Floating_Rate__c = currentFloatingRate
        );
        return floatingRateIndex;
    }

    /**
    * @description Creating Partner Program.
    * @author Sounak ganguly | 06-24-2024 
    * @param name Name of the Partner Program
    * @param baseRate Reference to Floating Rate Index
    * @return CFA_Partner_Program__c 
    **/
    public static CFA_Partner_Program__c createPartnerProgram(String name, clcommon__Floating_Rate_Index__c baseRate){
        CFA_Partner_Program__c partnerProgram = new CFA_Partner_Program__c(
            Name = name,
            Base_Rate__c = baseRate.Id,
            Short_Name__c = name
        );
        return partnerProgram;
    }

    /**
    * @description Creating Partner Account.
    * @author Sounak ganguly | 06-24-2024 
    * @param name Name of the Account
    * @param partnerProgram Reference to CFA Partner Program
    * @return Account 
    **/
    public static Account createPartnerAccount(String name, CFA_Partner_Program__c partnerProgram){
        Account account = new Account(
            Name = name,
            CFA_Partner_Program__c = partnerProgram.Id
        );
        return account;
    }
     /**
    * @description Creating Dealer Account With Coop Type CFA
    * @author Ayan Bhowmik | 06-28-2024
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
    * @description Return all recordTypes in a map with name as key and id as value
    * @author Ayan Bhowmik | 06-28-2024 
    * @return Map<String, Id> 
    **/
    public static Map<String, RecordType> getRecordTypeMap(){
        Map<String, RecordType> recordTypeMap = new Map<String, RecordType>();
        List<RecordType> recordTypeList = [SELECT Id,
                                                Name
                                            FROM RecordType
                                            WHERE sObjectType = 'Account'];
        for(RecordType recordTypeObj : recordTypeList){
            recordTypeMap.put(recordTypeObj.Name, recordTypeObj);
        }
        return recordTypeMap;
    }

    /**
    * @description  get application obj
    * @author Rakesh Saraf | 10-16-2024 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c getCFAApplication() {
        genesis__Applications__c applicationObj = [SELECT Id, 
                                                        CreatedDate,
                                                        genesis__Expected_Start_Date__c,
                                                        genesis__Expected_First_Payment_Date__c,
                                                        Dealer_Name__c,
                                                        Name,
                                                        My_Program__c,
                                                        Flex_Rate_Pricing__c,
                                                        genesis__Loan_Number__c,
                                                        genesis__Account__c,
                                                        genesis__Account__r.CIF_Number__c,
                                                        genesis__Account__r.Score_1__c,
                                                        genesis__Status__c,
                                                        Additional_Information_Needed__c,
                                                        genesis__Loan_Amount__c,
                                                        genesis__Credit_Rating__c,
                                                        genesis__Credit_Rating__r.Name,
                                                        Signing_Method__c,
                                                        Credit_Application_And_Agreement_Process__c,
                                                        Evergreen_Tier_Two_Business_Info_Status__c,
                                                        genesis__Parent_Application__c,
                                                        genesis__Parent_Application__r.Crop_Year__c,
                                                        Crop_Year__c,
                                                        Lien_Options__c,
                                                        Is_Evergreen__c,
                                                        Net_Worth__c,
                                                        Agreement_Sign__c,
                                                        Coop_Type__c,
                                                        Dealer_name__r.CFA_Partner_Program__c,
                                                        Dealer_name__r.CFA_Partner_Program__r.Name,
                                                        Dealer_name__r.CFA_Partner_Program__r.Allow_Auto_Booking__c,
                                                        FICO_Score__c,
                                                        SBSS_70_Score__c,
                                                        Guarantee__c,
                                                        Jointly_Payable_Proceeds_Checks__c,
                                                        Spousal_Consent__c,
                                                        Assignment_Of_Insurance__c,
                                                        Blanket_Lien__c,
                                                        Lien_Position__c,
                                                        Crops_Lien__c,
                                                        Stage__c,
                                                        Pricing_Count__c,
                                                        Dealer_Name__r.CFA_Partner_Program__r.Statement_Code_Single_Rate_Opt_Out__c,
                                                        Dealer_Name__r.CFA_Partner_Program__r.Statement_Code_Multi_Rate_Opt_Out__c,
                                                        Statement_Code__c,
                                                        (SELECT Id,
                                                        clcommon__Party_Types__c,
                                                        clcommon__Account__c,
                                                        clcommon__Account__r.Score_1__c,
                                                        clcommon__Contact__c,
                                                        genesis__Application__c,
                                                        clcommon__Type__r.Name,
                                                        clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                        clcommon__Account__r.genesis__Business_information__c,
                                                        clcommon__Contact__r.clcommon__Marital_Status__c,
                                                        Total_Assets__c,
                                                        Total_Liabilities__c,
                                                        Street__c,
                                                        City__c, 
                                                        State__c, 
                                                        County__c, 
                                                        Dealer_Applicant_Relationship__c, 
                                                        Postal_Code__c, 
                                                        Mobile_Number__c, 
                                                        Home_Number__c, 
                                                        Work_Number__c, 
                                                        Marital_Status__c, 
                                                        Suffix__c
                                                        FROM genesis__Parties__r
                                                        WHERE clcommon__Party_Types__c IN (: PortalConstants.PRINCIPAL_PARTY_NAME,:PortalConstants.BORROWER_PARTY_NAME))
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        applicationObj.genesis__Loan_Number__c = null;
        applicationObj.genesis__Status__c = 'NEW - SCORECARD GENERATED';
        Database.update(applicationObj, true);
        return applicationObj;
    }

    /**
    * @description get my program
    * @author Rakesh Saraf | 10-16-2024 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    public static genesis__Rate_Card_Setup_Header__c getCFAMyProgram() {
        genesis__Rate_Card_Setup_Header__c rateCard = [SELECT Id,
                                                        genesis__End_Date__c,
                                                        Crop_Year__c,
                                                        genesis__Start_Date__c
                                                            FROM genesis__Rate_Card_Setup_Header__c
                                                            WHERE Name = 'My Test Program 99'
                                                        LIMIT 1];

        return rateCard;
        
    }

    /**
    * @description method to get application details
    * @author Rakesh Saraf | 10-16-2024 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> getApplicationDetails(){
        Map<String, Object> applicationDetails = new Map<String, Object> {
            'Other_Additional_Requirements_Needed__c' => false,
            'Spousal_Consent__c' => false,
            'Assignment_Of_Insurance__c' => true,
            'Jointly_Payable_Proceeds_Checks__c' => true,
            'Crops_Lien__c' => 'Second Lien',
            'Years_Of_Business_With_Applicant__c' => 'New',
            'Do_You_Recommend_This_Applicant__c' => 'Yes',
            'Flex_Rate_Pricing__c' => false,
            'Credit_Application_And_Agreement_Process__c' => 'Customize',
            'ERP_Id__c' => '1234'
        };
        return applicationDetails;
    }

    /**
    * @description method to get flex rate program
    * @author Rakesh Saraf | 10-16-2024 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> getFlexRateProgramDetails(){
        Map<String, Object> flexRateProgramDetails = new Map<String, Object> {
            'Dealer_Participate_on_Closing_Fee__c' => 'No',
            'Loan_Fee_Advanced_On__c' => 'A',
            'Payer_of_Loan_Closing_Fee__c' => 'Grower',
            'Closing_Fee__c' => 200,
            'Field_Finance_Rate__c' => 9.5,
            'CFA_Advantage_Rate__c' => 11.5,
            'FS_Index_Rate__c' => 9,
            'Crop_Year__c' => '2024',
            'Id' => 'new_record_id',
            'genesis__End_Date__c' => Date.valueOf('2025-03-15')

        };
        return flexRateProgramDetails;
    }

    /**
    * @description returns the account of the borrower
    * @author Rakesh Saraf | 11-08-2024 
    * @return Account 
    **/
    public static Account getBorrowerAccount(){
        return [SELECT ID,
                        clcommon__Legal_Entity_Type__r.Name,
                        clcommon__Legal_Entity_Type__c,
                        Score_1__c
                        FROM Account
                        WHERE Name='Jasmine Albin'
                        LIMIT 1][0];
    }

    /**
    * @description returns the contact of the borrower
    * @author Rakesh Saraf | 11-08-2024 
    * @return Account 
    **/
    public static Contact getBorrowerContact(){
        return [SELECT ID,
                        clcommon__Marital_Status__c
                        FROM Contact
                        WHERE LastName = 'Albin'
                        LIMIT 1][0];
    }

    /**
    * @description Returns the principal Account for the application
    * @author Rakesh Saraf | 11-08-2024 
    * @return Account 
    **/
    public static Account getPrincipalAccount(){
        return [SELECT ID,
                        Score_1__c 
                        FROM Account
                        WHERE Name='Mike Johnson'
                        LIMIT 1][0];
    }

    /**
    * @description to get the account of the sales agent related to the application
    * @author Rakesh Saraf | 11-09-2024 
    * @return Account 
    **/
    public static Account getSalesAgentAccount(){
        return [SELECT ID 
                        FROM Account
                        WHERE Name='Tony Stark'
                        LIMIT 1][0];
    }

    /**
    * @description returns a task with a subject for the application
    * @author Rakesh Saraf | 11-10-2024 
    * @param subjectText 
    * @param applicationId 
    * @return Task 
    **/
    public static Task getTask(String subjectText, Id applicationId){
        return [SELECT ID,
                        Subject
                        FROM Task
                        WHERE Subject=:subjectText
                        AND genesis__Application__c= :applicationId][0];
    }

    /**
    * @description get the list of principal partied related to the application
    * @author Rakesh Saraf | 11-10-2024 
    * @param applicationId 
    * @return List<clcommon__Party__c> 
    **/
    public static List<clcommon__Party__c> getPrincipalPartyList(Id applicationId){
        clcommon__Party_Type__c principalPartyType=[SELECT Id FROM clcommon__Party_Type__c WHERE Name='PRINCIPAL' LIMIT 1];
        return [SELECT  Id,
                        clcommon__Account__c
                    FROM clcommon__Party__c
                    WHERE genesis__Application__c = :applicationId AND
                        clcommon__Type__c = :principalPartyType.id];
    }

    /**
    * @description creating a list of borrrowers and principals account id related to the application
    * @author Rakesh Saraf | 11-10-2024 
    * @param applicationId 
    * @return List<Id> 
    **/
    public static List<Id>  getPartiesIdList(Id applicationId){
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    clcommon__Account__c
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Party_Types__c IN (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME) 
                                                AND genesis__Application__c=:applicationId];

        List<Id> partyIdList=new List<Id>();
        for(clcommon__Party__c eachParty:partyList){
            partyIdList.add(eachParty.clcommon__Account__c);
        }
        return partyIdList;
    }

    /**
    * @description Get the rate card setup detail for the application
    * @author Rakesh Saraf | 11-10-2024 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    public static genesis__Rate_Card_Setup_Detail__c getApplicationRateCardDetail(){
        return [SELECT ID 
                    FROM genesis__Rate_Card_Setup_Detail__c
                    WHERE Interest_Rate_Type__c = 'Fixed'
                    LIMIT 1][0];
    }

    /**
    * @description RETURNS THE DEALER ACCOUNT 
    * @author Rakesh Saraf | 11-11-2024 
    * @return Account 
    **/
    public static Account getDealerAccoount(){
        return [SELECT ID,
                        CFA_Partner_Program__c
                        FROM Account 
                        WHERE Name = 'Kisan Loan'
                        LIMIT 1][0];
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 03-12-2024 
    * @param borrowerContactObj 
    * @param dealerAccountId 
    * @return Dealer_Applicant_Relationship__c 
    **/
    public static Dealer_Applicant_Relationship__c createDealerApplicantRelationship(Contact borrowerContactObj,Id dealerAccountId){
        Dealer_Applicant_Relationship__c dealerApplicantRelObj = new Dealer_Applicant_Relationship__c();
        dealerApplicantRelObj.Applicant__c = borrowerContactObj.accountId;
        dealerApplicantRelObj.Applicant_Contact__c = borrowerContactObj.id;
        dealerApplicantRelObj.Dealer__c = dealerAccountId;
        return dealerApplicantRelObj;
    }

    /**
    * @description : Method to create CL Plus user
    * @author Suraj Kumar | 11-21-2024 
    * @param contactID 
    * @return User 
    **/
    public static User createClPlusUser(Id contactID){
        Profile clPlusProfileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'Certified Lender Plus'
                                    LIMIT 1];
        User clUserObj = new User();
        clUserObj.Alias = 'newUser';
        clUserObj.Email='peter.geller@yopmail.com';
        clUserObj.EmailEncodingKey='UTF-8';
        clUserObj.LastName='Testing';
        clUserObj.LanguageLocaleKey='en_US';
        clUserObj.LocaleSidKey='en_US';
        clUserObj.ProfileId = clPlusProfileObj.Id;
        clUserObj.ContactId = contactID;
        clUserObj.TimeZoneSidKey='America/Los_Angeles';
        clUserObj.UserName='peter.geller@yopmail.com';
        return clUserObj;
    }

    /**
     * @description 
     * @param paramMap 
     * @param applicantAccount
     * @return  `clcommon__Party__c`
     */
    public static clcommon__Party__c createApplicantParty(Map<String, String> paramMap, Account applicantAccount){
        clcommon__Party__c partyObj = new clcommon__Party__c();
        partyObj.clcommon__Account__c = paramMap.get('accountId');
        partyObj.clcommon__Contact__c = paramMap.get('contactId');
        partyObj.clcommon__Type__c = paramMap.get('partyTypeId');
        partyObj.genesis__Application__c = paramMap.get('applicationId');
        // partyObj.clcommon__Party_Types__c = paramMap.get('partyTypes');
        // partyObj.Dealer_Applicant_Relationship__c = paramMap.get('dealerApplicantRelationshipId');
        partyObj.Street__c = applicantAccount.BillingStreet;
        partyObj.City__c = applicantAccount.BillingCity;
        partyObj.Postal_Code__c = applicantAccount.BillingPostalCode;
        partyObj.State__c = applicantAccount.BillingState;
        partyObj.County__c = applicantAccount.Billing_County__c;
        partyObj.Mobile_Number__c = applicantAccount.Phone;
        partyObj.Work_Number__c = applicantAccount.Work_Number__c;
        partyObj.Home_Number__c = applicantAccount.Home_Number__c;
        partyObj.Total_Assets__c = 2423433;
        partyObj.Total_Liabilities__c = 1223433;
        return partyObj;
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 16-12-2024 
    * @param applicationId 
    * @return clcommon__Consolidated_Invoice__c 
    **/
    public static clcommon__Consolidated_Invoice__c createInvoice(String applicationId){
        clcommon__Consolidated_Invoice__c invoiceObj = new clcommon__Consolidated_Invoice__c();
        invoiceObj.Application__c = applicationId;
        return invoiceObj;
    }

    /**
    * @description this method populates the details in the party of the application for individual(s)- Sole Prop
    * @author Rakesh Saraf | 12-20-2024 
    * @param partyObj 
    * @param dealerApplicantRelId 
    * @return clcommon__Party__c 
    **/
    public static clcommon__Party__c insertIndividualPartyDetails(clcommon__Party__c partyObj,Id dealerApplicantRelId){
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
        partyObj.Marital_Status__c = 'Married';

        partyObj.Dealer_Applicant_Relationship__c=dealerApplicantRelId;

        return partyObj;
    }

    /**
    * @description 
    * @author Ayush Kumar Singh | 05-06-2024 
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
    * @description this method populates the details in the party of the application for Corporation
    * @author Rakesh Saraf | 12-20-2024 
    * @param partyObj 
    * @param dealerApplicantRelId 
    * @return clcommon__Party__c 
    **/
    public static clcommon__Party__c insertCorporationPartyDetails(clcommon__Party__c partyObj,Id dealerApplicantRelId){
        partyObj.Street__c = '02 MA Road';
        partyObj.City__c = 'NEWTOWN';
        partyObj.State__c = 'AL';
        partyObj.County__c = 'Rajarhat';
        partyObj.Postal_Code__c = '54321';
        partyObj.Mobile_Number__c = '1234567890';
        partyObj.Home_Number__c = '0987654321';
        partyObj.Work_Number__c = '5432123456';

        partyObj.Dealer_Applicant_Relationship__c=dealerApplicantRelId;

        return partyObj;
    }

    /**
    * @description Creating Rate Card Details for Gray Label My Program
    * @author Kabir Pramanik | 12-23-2024 
    * @param rateCardHeader 
    * @return List<genesis__Rate_Card_Setup_Detail__c> 
    **/
    public static List<genesis__Rate_Card_Setup_Detail__c> createRateCardDetailsForGrayLabel(Id rateCardHeader) {
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
        objRateToProductAssoc.genesis__Rate_Card_Setup__c = rateCardHeader;
        Database.upsert(objRateToProductAssoc, true);

        genesis__Rate_Card_Setup_Detail__c specialTermAA = new genesis__Rate_Card_Setup_Detail__c(); 
        specialTermAA.Start_Date__c = System.today();
        specialTermAA.End_Date__c = System.today().addMonths(3).toStartOfMonth().addDays(-1);
        specialTermAA.billing_date__c = null;
        specialTermAA.has_billing_date__c = false;
        specialTermAA.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermAA.Participation_Percentage_Dealer__c = 2;
        specialTermAA.Participation_Percentage_CFA__c = 1;
        specialTermAA.genesis__Interest_Rate__c = 13;
        specialTermAA.Interest_Rate_Type__c = 'Variable';
        specialTermAA.Description__c = 'Note Rate';
        specialTermAA.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermAA.Special_Term_Order__c = 1;
        specialTermAA.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        genesis__Rate_Card_Setup_Detail__c specialTermAB = new genesis__Rate_Card_Setup_Detail__c();
        specialTermAB.Start_Date__c = System.today().addMonths(3).toStartOfMonth();
        specialTermAB.End_Date__c = System.today().addMonths(6).toStartOfMonth().addDays(-1);
        specialTermAB.billing_date__c = null;
        specialTermAB.has_billing_date__c = false;
        specialTermAB.Participation_Percentage_Dealer_Subsidy__c = 1;
        specialTermAB.Participation_Percentage_Dealer__c = 0;
        specialTermAB.Participation_Percentage_CFA__c = 1;
        specialTermAB.genesis__Interest_Rate__c = 10;
        specialTermAB.Interest_Rate_Type__c = 'Variable';
        specialTermAB.Description__c = 'Note Rate';
        specialTermAB.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermAB.Special_Term_Order__c = 1;
        specialTermAB.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        genesis__Rate_Card_Setup_Detail__c specialTermAC = new genesis__Rate_Card_Setup_Detail__c(); 
        specialTermAC.Start_Date__c = System.today().addMonths(6).toStartOfMonth();
        specialTermAC.End_Date__c = System.today().addMonths(9).toStartOfMonth().addDays(-1);
        specialTermAC.billing_date__c = null;
        specialTermAC.has_billing_date__c = false;
        specialTermAC.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermAC.Participation_Percentage_Dealer__c = 0;
        specialTermAC.Participation_Percentage_CFA__c = 1;
        specialTermAC.genesis__Interest_Rate__c = 11;
        specialTermAC.Interest_Rate_Type__c = 'Variable';
        specialTermAC.Description__c = 'Note Rate';
        specialTermAC.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermAC.Special_Term_Order__c = 1;
        specialTermAC.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        genesis__Rate_Card_Setup_Detail__c specialTermAD = new genesis__Rate_Card_Setup_Detail__c(); 
        specialTermAD.Start_Date__c = System.today().addMonths(9).toStartOfMonth();
        specialTermAD.End_Date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        specialTermAD.billing_date__c = null;
        specialTermAD.has_billing_date__c = false;
        specialTermAD.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermAD.Participation_Percentage_Dealer__c = 3.5;
        specialTermAD.Participation_Percentage_CFA__c = 0.5;
        specialTermAD.genesis__Interest_Rate__c = 15;
        specialTermAD.Interest_Rate_Type__c = 'Fixed';
        specialTermAD.Description__c = 'Note Rate';
        specialTermAD.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermAD.Special_Term_Order__c = 1;
        specialTermAD.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        genesis__Rate_Card_Setup_Detail__c specialTermAE = new genesis__Rate_Card_Setup_Detail__c();
        specialTermAE.Start_Date__c = System.today().addMonths(10).toStartOfMonth();
        specialTermAE.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermAE.billing_date__c = null;
        specialTermAE.has_billing_date__c = false;
        specialTermAE.Participation_Percentage_Dealer_Subsidy__c = 2.5;
        specialTermAE.Participation_Percentage_Dealer__c = 0;
        specialTermAE.Participation_Percentage_CFA__c = 0.5;
        specialTermAE.genesis__Interest_Rate__c = 9;
        specialTermAE.Interest_Rate_Type__c = 'Fixed';
        specialTermAE.Description__c = 'Note Rate';
        specialTermAE.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermAE.Special_Term_Order__c = 1;
        specialTermAE.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        genesis__Rate_Card_Setup_Detail__c specialTermBA = new genesis__Rate_Card_Setup_Detail__c();
        specialTermBA.Start_Date__c = System.today();
        specialTermBA.End_Date__c = System.today().addMonths(3).toStartOfMonth().addDays(-1);
        specialTermBA.billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        specialTermBA.has_billing_date__c = true;
        specialTermBA.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermBA.Participation_Percentage_Dealer__c = 1;
        specialTermBA.Participation_Percentage_CFA__c = 1;
        specialTermBA.genesis__Interest_Rate__c = 12;
        specialTermBA.Interest_Rate_Type__c = 'Fixed';
        specialTermBA.Description__c = 'Millet Seeds';
        specialTermBA.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermBA.Special_Term_Order__c = 2;
        specialTermBA.Special_Term_Reference__c = 'Special Term Sub-Tranche (B)';

        genesis__Rate_Card_Setup_Detail__c specialTermBB = new genesis__Rate_Card_Setup_Detail__c();
        specialTermBB.Start_Date__c = System.today().addMonths(3).toStartOfMonth();
        specialTermBB.End_Date__c = System.today().addMonths(6).toStartOfMonth().addDays(-1);
        specialTermBB.billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        specialTermBB.has_billing_date__c = true;
        specialTermBB.Participation_Percentage_Dealer_Subsidy__c = 2;
        specialTermBB.Participation_Percentage_Dealer__c = 0;
        specialTermBB.Participation_Percentage_CFA__c = 1;
        specialTermBB.genesis__Interest_Rate__c = 9;
        specialTermBB.Interest_Rate_Type__c = 'Fixed';
        specialTermBB.Description__c = 'Millet Seeds';
        specialTermBB.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermBB.Special_Term_Order__c = 2;
        specialTermBB.Special_Term_Reference__c = 'Special Term Sub-Tranche (B)';

        genesis__Rate_Card_Setup_Detail__c specialTermBC = new genesis__Rate_Card_Setup_Detail__c();
        specialTermBC.Start_Date__c = System.today().addMonths(6).toStartOfMonth();
        specialTermBC.End_Date__c = System.today().addMonths(9).toStartOfMonth().addDays(-1);
        specialTermBC.billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        specialTermBC.has_billing_date__c = true;
        specialTermBC.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermBC.Participation_Percentage_Dealer__c = 0;
        specialTermBC.Participation_Percentage_CFA__c = 1;
        specialTermBC.genesis__Interest_Rate__c = 11;
        specialTermBC.Interest_Rate_Type__c = 'Fixed';
        specialTermBC.Description__c = 'Millet Seeds';
        specialTermBC.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermBC.Special_Term_Order__c = 2;
        specialTermBC.Special_Term_Reference__c = 'Special Term Sub-Tranche (B)';

        genesis__Rate_Card_Setup_Detail__c specialTermBD = new genesis__Rate_Card_Setup_Detail__c();
        specialTermBD.Start_Date__c = System.today().addMonths(9).toStartOfMonth();
        specialTermBD.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermBD.billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        specialTermBD.has_billing_date__c = true;
        specialTermBD.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermBD.Participation_Percentage_Dealer__c = 1.5;
        specialTermBD.Participation_Percentage_CFA__c = 0.5;
        specialTermBD.genesis__Interest_Rate__c = 13;
        specialTermBD.Interest_Rate_Type__c = 'Variable';
        specialTermBD.Description__c = 'Millet Seeds';
        specialTermBD.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermBD.Special_Term_Order__c = 2;
        specialTermBD.Special_Term_Reference__c = 'Special Term Sub-Tranche (B)';

        genesis__Rate_Card_Setup_Detail__c specialTermCA = new genesis__Rate_Card_Setup_Detail__c();
        specialTermCA.Start_Date__c = System.today();
        specialTermCA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermCA.billing_date__c = null;
        specialTermCA.has_billing_date__c = false;
        specialTermCA.Participation_Percentage_Dealer_Subsidy__c = 1;
        specialTermCA.Participation_Percentage_Dealer__c = 0;
        specialTermCA.Participation_Percentage_CFA__c = 1;
        specialTermCA.genesis__Interest_Rate__c = 10;
        specialTermCA.Interest_Rate_Type__c = 'Variable';
        specialTermCA.Description__c = 'Millet Seeds';
        specialTermCA.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermCA.Special_Term_Order__c = 3;
        specialTermCA.Special_Term_Reference__c = 'Special Term Sub-Tranche (C)';

        genesis__Rate_Card_Setup_Detail__c specialTermDA = new genesis__Rate_Card_Setup_Detail__c();
        specialTermDA.Start_Date__c = System.today();
        specialTermDA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermDA.billing_date__c = null;
        specialTermDA.has_billing_date__c = false;
        specialTermDA.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermDA.Participation_Percentage_Dealer__c = 2;
        specialTermDA.Participation_Percentage_CFA__c = 1;
        specialTermDA.genesis__Interest_Rate__c = 13;
        specialTermDA.Interest_Rate_Type__c = 'Fixed';
        specialTermDA.Description__c = 'Millet Seeds';
        specialTermDA.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermDA.Special_Term_Order__c = 4;
        specialTermDA.Special_Term_Reference__c = 'Special Term Sub-Tranche (D)';

        genesis__Rate_Card_Setup_Detail__c specialTermEA = new genesis__Rate_Card_Setup_Detail__c();
        specialTermEA.Start_Date__c = System.today();
        specialTermEA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermEA.billing_date__c = null;
        specialTermEA.has_billing_date__c = false;
        specialTermEA.Participation_Percentage_Dealer_Subsidy__c = 1;
        specialTermEA.Participation_Percentage_Dealer__c = 0;
        specialTermEA.Participation_Percentage_CFA__c = 1;
        specialTermEA.genesis__Interest_Rate__c = 9;
        specialTermEA.Interest_Rate_Type__c = 'Fixed';
        specialTermEA.Description__c = 'Millet Seeds';
        specialTermEA.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermEA.Special_Term_Order__c = 5;
        specialTermEA.Special_Term_Reference__c = 'Special Term Sub-Tranche (E)';

        genesis__Rate_Card_Setup_Detail__c specialTermFA = new genesis__Rate_Card_Setup_Detail__c();
        specialTermFA.Start_Date__c = System.today();
        specialTermFA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermFA.billing_date__c = null;
        specialTermFA.has_billing_date__c = false;
        specialTermFA.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermFA.Participation_Percentage_Dealer__c = 4;
        specialTermFA.Participation_Percentage_CFA__c = 1;
        specialTermFA.genesis__Interest_Rate__c = 15;
        specialTermFA.Interest_Rate_Type__c = 'Fixed';
        specialTermFA.Description__c = 'Millet Seeds';
        specialTermFA.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermFA.Special_Term_Order__c = 6;
        specialTermFA.Special_Term_Reference__c = 'Special Term Sub-Tranche (F)';
        
        genesis__Rate_Card_Setup_Detail__c specialTermGA = new genesis__Rate_Card_Setup_Detail__c();
        specialTermGA.Start_Date__c = System.today();
        specialTermGA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermGA.billing_date__c = null;
        specialTermGA.has_billing_date__c = false;
        specialTermGA.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermGA.Participation_Percentage_Dealer__c = 4;
        specialTermGA.Participation_Percentage_CFA__c = 1;
        specialTermGA.genesis__Interest_Rate__c = 15;
        specialTermGA.Interest_Rate_Type__c = 'Fixed';
        specialTermGA.Description__c = 'Millet Seeds';
        specialTermGA.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermGA.Special_Term_Order__c = 7;
        specialTermGA.Special_Term_Reference__c = 'Special Term Sub-Tranche (G)';

        genesis__Rate_Card_Setup_Detail__c specialTermHA = new genesis__Rate_Card_Setup_Detail__c();
        specialTermHA.Start_Date__c = System.today();
        specialTermHA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermHA.billing_date__c = null;
        specialTermHA.has_billing_date__c = false;
        specialTermHA.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermHA.Participation_Percentage_Dealer__c = 4;
        specialTermHA.Participation_Percentage_CFA__c = 1;
        specialTermHA.genesis__Interest_Rate__c = 15;
        specialTermHA.Interest_Rate_Type__c = 'Variable';
        specialTermHA.Description__c = 'Millet Seeds';
        specialTermHA.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermHA.Special_Term_Order__c = 8;
        specialTermHA.Special_Term_Reference__c = 'Special Term Sub-Tranche (H)';

        return (new List<genesis__Rate_Card_Setup_Detail__c> {specialTermAA, specialTermAB, specialTermAC, specialTermAD, specialTermAE, specialTermBA, specialTermBB, specialTermBC, specialTermBD, specialTermCA, specialTermDA, specialTermEA, specialTermFA, specialTermGA, specialTermHA});
        
    }

    /**
    * @description Creating Rate Card Details for Growmark My Program
    * @param rateCardHeader 
    * @return List<genesis__Rate_Card_Setup_Detail__c> 
    **/
    public static List<genesis__Rate_Card_Setup_Detail__c> createRateCardDetailsForGrowmark(Id rateCardHeader) {

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
        objRateToProductAssoc.genesis__Rate_Card_Setup__c = rateCardHeader;
        Database.upsert(objRateToProductAssoc, true);

        genesis__Rate_Card_Setup_Detail__c specialTermAA = new genesis__Rate_Card_Setup_Detail__c();
        specialTermAA.Start_Date__c = System.today();
        specialTermAA.End_Date__c = System.today().addMonths(3).toStartOfMonth().addDays(-1);
        specialTermAA.billing_date__c = null;
        specialTermAA.has_billing_date__c = false;
        specialTermAA.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermAA.Participation_Percentage_Dealer__c = 1;
        specialTermAA.Participation_Percentage_CFA__c = 0;
        specialTermAA.genesis__Interest_Rate__c = 10;
        specialTermAA.Interest_Rate_Type__c = 'Variable';
        specialTermAA.Description__c = 'Note Rate';
        specialTermAA.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermAA.Special_Term_Order__c = 1;
        specialTermAA.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        genesis__Rate_Card_Setup_Detail__c specialTermAB = new genesis__Rate_Card_Setup_Detail__c();
        specialTermAB.Start_Date__c = System.today().addMonths(3).toStartOfMonth();
        specialTermAB.End_Date__c = System.today().addMonths(6).toStartOfMonth().addDays(-1);
        specialTermAB.billing_date__c = null;
        specialTermAB.has_billing_date__c = false;
        specialTermAB.Participation_Percentage_Dealer_Subsidy__c = 1;
        specialTermAB.Participation_Percentage_Dealer__c = 0;
        specialTermAB.Participation_Percentage_CFA__c = 0;
        specialTermAB.genesis__Interest_Rate__c = 8;
        specialTermAB.Interest_Rate_Type__c = 'Variable';
        specialTermAB.Description__c = 'Note Rate';
        specialTermAB.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermAB.Special_Term_Order__c = 1;
        specialTermAB.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        genesis__Rate_Card_Setup_Detail__c specialTermAC = new genesis__Rate_Card_Setup_Detail__c();
        specialTermAC.Start_Date__c = System.today().addMonths(6).toStartOfMonth();
        specialTermAC.End_Date__c = System.today().addMonths(9).toStartOfMonth().addDays(-1);
        specialTermAC.billing_date__c = null;
        specialTermAC.has_billing_date__c = false;
        specialTermAC.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermAC.Participation_Percentage_Dealer__c = 0;
        specialTermAC.Participation_Percentage_CFA__c = 0;
        specialTermAC.genesis__Interest_Rate__c = 9;
        specialTermAC.Interest_Rate_Type__c = 'Variable';
        specialTermAC.Description__c = 'Note Rate';
        specialTermAC.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermAC.Special_Term_Order__c = 1;
        specialTermAC.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';
        
        genesis__Rate_Card_Setup_Detail__c specialTermAD = new genesis__Rate_Card_Setup_Detail__c();
        specialTermAD.Start_Date__c = System.today().addMonths(9).toStartOfMonth();
        specialTermAD.End_Date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        specialTermAD.billing_date__c = null;
        specialTermAD.has_billing_date__c = false;
        specialTermAD.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermAD.Participation_Percentage_Dealer__c = 3;
        specialTermAD.Participation_Percentage_CFA__c = 0;
        specialTermAD.genesis__Interest_Rate__c = 12;
        specialTermAD.Interest_Rate_Type__c = 'Fixed';
        specialTermAD.Description__c = 'Note Rate';
        specialTermAD.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermAD.Special_Term_Order__c = 1;
        specialTermAD.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        genesis__Rate_Card_Setup_Detail__c specialTermAE = new genesis__Rate_Card_Setup_Detail__c();
        specialTermAE.Start_Date__c = System.today().addMonths(10).toStartOfMonth();
        specialTermAE.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermAE.billing_date__c = null;
        specialTermAE.has_billing_date__c = false;
        specialTermAE.Participation_Percentage_Dealer_Subsidy__c = 1;
        specialTermAE.Participation_Percentage_Dealer__c = 0;
        specialTermAE.Participation_Percentage_CFA__c = 0;
        specialTermAE.genesis__Interest_Rate__c = 8;
        specialTermAE.Interest_Rate_Type__c = 'Fixed';
        specialTermAE.Description__c = 'Note Rate';
        specialTermAE.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermAE.Special_Term_Order__c = 1;
        specialTermAE.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        genesis__Rate_Card_Setup_Detail__c specialTermBA = new genesis__Rate_Card_Setup_Detail__c();
        specialTermBA.Start_Date__c = System.today();
        specialTermBA.End_Date__c = System.today().addMonths(3).toStartOfMonth().addDays(-1);
        specialTermBA.billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        specialTermBA.has_billing_date__c = true;
        specialTermBA.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermBA.Participation_Percentage_Dealer__c = 1;
        specialTermBA.Participation_Percentage_CFA__c = 0;
        specialTermBA.genesis__Interest_Rate__c = 10;
        specialTermBA.Interest_Rate_Type__c = 'Fixed';
        specialTermBA.Description__c = 'Seeds';
        specialTermBA.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermBA.Special_Term_Order__c = 2;
        specialTermBA.Special_Term_Reference__c = 'Special Term Sub-Tranche (B)';

        genesis__Rate_Card_Setup_Detail__c specialTermBB = new genesis__Rate_Card_Setup_Detail__c();
        specialTermBB.Start_Date__c = System.today().addMonths(3).toStartOfMonth();
        specialTermBB.End_Date__c = System.today().addMonths(6).toStartOfMonth().addDays(-1);
        specialTermBB.billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        specialTermBB.has_billing_date__c = true;
        specialTermBB.Participation_Percentage_Dealer_Subsidy__c = 1;
        specialTermBB.Participation_Percentage_Dealer__c = 0;
        specialTermBB.Participation_Percentage_CFA__c = 0;
        specialTermBB.genesis__Interest_Rate__c = 8;
        specialTermBB.Interest_Rate_Type__c = 'Fixed';
        specialTermBB.Description__c = 'Seeds';
        specialTermBB.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermBB.Special_Term_Order__c = 2;
        specialTermBB.Special_Term_Reference__c = 'Special Term Sub-Tranche (B)';

        genesis__Rate_Card_Setup_Detail__c specialTermBC = new genesis__Rate_Card_Setup_Detail__c();
        specialTermBC.Start_Date__c = System.today().addMonths(6).toStartOfMonth();
        specialTermBC.End_Date__c = System.today().addMonths(9).toStartOfMonth().addDays(-1);
        specialTermBC.billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        specialTermBC.has_billing_date__c = true;
        specialTermBC.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermBC.Participation_Percentage_Dealer__c = 0;
        specialTermBC.Participation_Percentage_CFA__c = 0;
        specialTermBC.genesis__Interest_Rate__c = 9;
        specialTermBC.Interest_Rate_Type__c = 'Fixed';
        specialTermBC.Description__c = 'Seeds';
        specialTermBC.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermBC.Special_Term_Order__c = 2;
        specialTermBC.Special_Term_Reference__c = 'Special Term Sub-Tranche (B)';

        genesis__Rate_Card_Setup_Detail__c specialTermBD = new genesis__Rate_Card_Setup_Detail__c();
        specialTermBD.Start_Date__c = System.today().addMonths(9).toStartOfMonth();
        specialTermBD.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermBD.billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        specialTermBD.has_billing_date__c = true;
        specialTermBD.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermBD.Participation_Percentage_Dealer__c = 3;
        specialTermBD.Participation_Percentage_CFA__c = 0;
        specialTermBD.genesis__Interest_Rate__c = 12;
        specialTermBD.Interest_Rate_Type__c = 'Variable';
        specialTermBD.Description__c = 'Seeds';
        specialTermBD.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermBD.Special_Term_Order__c = 2;
        specialTermBD.Special_Term_Reference__c = 'Special Term Sub-Tranche (B)';

        genesis__Rate_Card_Setup_Detail__c specialTermCA = new genesis__Rate_Card_Setup_Detail__c();
        specialTermCA.Start_Date__c = System.today();
        specialTermCA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermCA.billing_date__c = null;
        specialTermCA.has_billing_date__c = false;
        specialTermCA.Participation_Percentage_Dealer_Subsidy__c = 1;
        specialTermCA.Participation_Percentage_Dealer__c = 0;
        specialTermCA.Participation_Percentage_CFA__c = 0;
        specialTermCA.genesis__Interest_Rate__c = 8;
        specialTermCA.Interest_Rate_Type__c = 'Variable';
        specialTermCA.Description__c = 'Machinary';
        specialTermCA.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermCA.Special_Term_Order__c = 3;
        specialTermCA.Special_Term_Reference__c = 'Special Term Sub-Tranche (C)';
        
        genesis__Rate_Card_Setup_Detail__c specialTermDA = new genesis__Rate_Card_Setup_Detail__c();
        specialTermDA.Start_Date__c = System.today();
        specialTermDA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermDA.billing_date__c = null;
        specialTermDA.has_billing_date__c = false;
        specialTermDA.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermDA.Participation_Percentage_Dealer__c = 1;
        specialTermDA.Participation_Percentage_CFA__c = 0;
        specialTermDA.genesis__Interest_Rate__c = 10;
        specialTermDA.Interest_Rate_Type__c = 'Fixed';
        specialTermDA.Description__c = 'Machinary 2';
        specialTermDA.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermDA.Special_Term_Order__c = 4;
        specialTermDA.Special_Term_Reference__c = 'Special Term Sub-Tranche (D)';
        
        genesis__Rate_Card_Setup_Detail__c specialTermEA = new genesis__Rate_Card_Setup_Detail__c();
        specialTermEA.Start_Date__c = System.today();
        specialTermEA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermEA.billing_date__c = null;
        specialTermEA.has_billing_date__c = false;
        specialTermEA.Participation_Percentage_Dealer_Subsidy__c = 1;
        specialTermEA.Participation_Percentage_Dealer__c = 1;
        specialTermEA.Participation_Percentage_CFA__c = 0;
        specialTermEA.genesis__Interest_Rate__c = 8;
        specialTermEA.Interest_Rate_Type__c = 'Fixed';
        specialTermEA.Description__c = 'Machinary 3';
        specialTermEA.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermEA.Special_Term_Order__c = 5;
        specialTermEA.Special_Term_Reference__c = 'Special Term Sub-Tranche (E)';

        genesis__Rate_Card_Setup_Detail__c specialTermFA = new genesis__Rate_Card_Setup_Detail__c();
        specialTermFA.Start_Date__c = System.today();
        specialTermFA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermFA.billing_date__c = null;
        specialTermFA.has_billing_date__c = false;
        specialTermFA.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermFA.Participation_Percentage_Dealer__c = 1;
        specialTermFA.Participation_Percentage_CFA__c = 0;
        specialTermFA.genesis__Interest_Rate__c = 10;
        specialTermFA.Interest_Rate_Type__c = 'Variable';
        specialTermFA.Description__c = 'Machinary 4';
        specialTermFA.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermFA.Special_Term_Order__c = 6;
        specialTermFA.Special_Term_Reference__c = 'Special Term Sub-Tranche (F)';

        genesis__Rate_Card_Setup_Detail__c specialTermGA = new genesis__Rate_Card_Setup_Detail__c();
        specialTermGA.Start_Date__c = System.today();
        specialTermGA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermGA.billing_date__c = null;
        specialTermGA.has_billing_date__c = false;
        specialTermGA.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermGA.Participation_Percentage_Dealer__c = 1;
        specialTermGA.Participation_Percentage_CFA__c = 0;
        specialTermGA.genesis__Interest_Rate__c = 10;
        specialTermGA.Interest_Rate_Type__c = 'Variable';
        specialTermGA.Description__c = 'Machinary 5';
        specialTermGA.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermGA.Special_Term_Order__c = 7;
        specialTermGA.Special_Term_Reference__c = 'Special Term Sub-Tranche (G)';

        genesis__Rate_Card_Setup_Detail__c specialTermHA = new genesis__Rate_Card_Setup_Detail__c();
        specialTermHA.Start_Date__c = System.today();
        specialTermHA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermHA.billing_date__c = null;
        specialTermHA.has_billing_date__c = false;
        specialTermHA.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermHA.Participation_Percentage_Dealer__c = 1;
        specialTermHA.Participation_Percentage_CFA__c = 0;
        specialTermHA.genesis__Interest_Rate__c = 10;
        specialTermHA.Interest_Rate_Type__c = 'Fixed';
        specialTermHA.Description__c = 'Machinary 6';
        specialTermHA.genesis__Rate_Card_Setup_Header__c = rateCardHeader;
        specialTermHA.Special_Term_Order__c = 8;
        specialTermHA.Special_Term_Reference__c = 'Special Term Sub-Tranche (H)';

        return (new List<genesis__Rate_Card_Setup_Detail__c> {specialTermAA, specialTermAB, specialTermAC, specialTermAD, specialTermAE, specialTermBA, specialTermBB, specialTermBC, specialTermBD, specialTermCA, specialTermDA, specialTermEA, specialTermFA, specialTermGA, specialTermHA});
    }
     /**
    * @description Creating Business Information for growmark profile Borrower
    * @author Shristy Kumari | 01-06-2025 
    * @return genesis__Business_Information__c 
    **/
    public static genesis__Business_Information__c createBusinessInfoForGrowmarkBorrower(){        
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
    * @description Creating Sole Prop Borrower Account for growmark
    * @author Shristy Kumari | 06-01-2025 
    * @param entityObj 
    * @param businessInfoId 
    * @return Account 
    **/
    public static Account createGrowmarkBorrowerAccount(clcommon__Legal_Entity__c entityObj, 
                                                            Id businessInfoId){  
        Account accountObj = new Account();
        accountObj.Name = 'William Carry';
        accountObj.clcommon__Email__c='william.carry@yop.com';
        accountObj.clcommon__Legal_Entity_Type__c = entityObj.Id;
        accountObj.genesis__Business_Information__c=businessInfoId;
        accountObj.BillingCity = 'Kolkata';
        accountObj.BillingState = 'WA';
        accountObj.Billing_County__c='fghu';
        accountObj.Work_Number__c='098765678';
        return accountObj;
    }
    /**
    * @description Creating Borrower Contact for growmark profile
    * @author Shristy Kumari | 01-06-2025
    * @param objAccountID 
    * @return Contact 
    **/
    public static Contact createGrowmarkBorrowerContact(Id objAccountID){
        Contact contactObj = new Contact();
        contactObj.FirstName = 'William';
        contactObj.LastName = 'carry';
        contactObj.Email = 'william.carry@yopmail.com';
        contactObj.Phone = '9734227544';
        contactObj.MobilePhone = '342134234';
        contactObj.genesis__SSN__c = 'GHFB6766';
        contactObj.Confirm_SSN__c = 'GHFB6766';
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
    * @description Creating Borrower User for growmark profile 
    * @author Shristy Kumari | 06-01-2025 
    * @param borrowerContactId 
    * @return User 
    **/
    public static User createGrowmarkBorrowerUser(Id borrowerContactId){
        Profile borrowerProfileObj = [SELECT Id
                                    FROM Profile
                                    WHERE Name = 'Growmark Grower'
                                    LIMIT 1];
        User growmarkBorrowerUserObj = new User();
        growmarkBorrowerUserObj.Alias = 'newUser';
        growmarkBorrowerUserObj.Email='growmarknewus5er@yopmail.com';
        growmarkBorrowerUserObj.EmailEncodingKey='UTF-8';
        growmarkBorrowerUserObj.LastName='Testing';
        growmarkBorrowerUserObj.LanguageLocaleKey='en_US';
        growmarkBorrowerUserObj.LocaleSidKey='en_US';
        growmarkBorrowerUserObj.ProfileId = borrowerProfileObj.Id;
        growmarkBorrowerUserObj.ContactId = borrowerContactId;
        growmarkBorrowerUserObj.TimeZoneSidKey='America/Los_Angeles';
        growmarkBorrowerUserObj.UserName='william.carry@yopmail.com';
        return growmarkBorrowerUserObj;
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 07-01-2025 
    * @param permSetName 
    * @param userId 
    * @return PermissionSetAssignment 
    **/
    public static PermissionSetAssignment createPermissionSetAssignment(String permSetName, Id userId) {
        PermissionSet permSetObj = [SELECT Id FROM PermissionSet WHERE Name = :permSetName LIMIT 1];
        Id permSetId = permSetObj.Id;
        return new PermissionSetAssignment(PermissionSetId = permSetId, AssigneeId = userId);
    }

     /**
     * @description Quering the credit rating matrix
     * @param name 
     * @return  `List<genesis__Credit_Rating_Matrix__c>`
     */
    public static List<genesis__Credit_Rating_Matrix__c> getCreditRatingMatrixForTier(String name){
        List<genesis__Credit_Rating_Matrix__c> tierMatrixObj = [SELECT Id 
                                                                    FROM genesis__Credit_Rating_Matrix__c 
                                                                    WHERE Name =: name];
        return tierMatrixObj;
    }
    
    /**
     * @description Returning the admin user
     * @return  `List<User>`
     */
    public static List<User> getAdminUser(){
        List<User> userList = [SELECT Id 
                            FROM User 
                            WHERE Profile.name = 'System Administrator' 
                            AND isActive = true LIMIT 1];

        return userList;
    }
    /**
     * @description Returning the admin user
     * @return  `List<User>`
     */
    public static List<User> getLAUser(){
        List<User> userList = [SELECT Id 
                            FROM User 
                            WHERE Profile.name = 'Loan Accounting' 
                            AND isActive = true LIMIT 1];

        return userList;
    }
     /**
     * @description Returning the admin user
     * @return  `List<User>`
     */
    public static List<User> getCreditUser(){
        List<User> userList = [SELECT Id 
                            FROM User 
                            WHERE Profile.name = 'Credit' 
                            AND isActive = true LIMIT 1];

        return userList;
    }
    /**
    * @description Creating Test Data for Seed Data for Pricing Detail
    * @author Ayush Kumar Singh | 02-22-2024 
    * @param application 
    * @return List<genesis__Application_Pricing_Detail__c> 
    **/
    public static List<genesis__Application_Pricing_Detail__c> createPricingDetailsForApplication(genesis__Applications__c application) {

        List<genesis__Rate_Card_Setup_Header__c> rateCardHeaders = [
                SELECT Id
                FROM genesis__Rate_Card_Setup_Header__c
                WHERE Id = :application.My_Program__c
            ];

        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailsList = [
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
        Map<String,String> specialTermMap = new Map<String,String>{
            'Special Term Sub-Tranche (A)' => '-A',
            'Special Term Sub-Tranche (B)' => '-B',
            'Special Term Sub-Tranche (C)' => '-C',
            'Special Term Sub-Tranche (D)' => '-D',
            'Special Term Sub-Tranche (E)' => '-E',
            'Special Term Sub-Tranche (F)' => '-F',
            'Special Term Sub-Tranche (G)' => '-G',
            'Special Term Sub-Tranche (H)' => '-H'

        };
        List<genesis__Application_Pricing_Detail__c> pricings = new List<genesis__Application_Pricing_Detail__c>();
        
        for (genesis__Rate_Card_Setup_Detail__c rateCardDetail : rateCardDetailsList) {
            genesis__Application_Pricing_Detail__c pricing = new genesis__Application_Pricing_Detail__c(
                genesis__Application__c=application.Id,
                genesis__Enabled_Flag__c=true,
                genesis__Rate_Card_Setup_Detail__c=rateCardDetail.Id
            );
            if (specialTermMap.containsKey(rateCardDetail.Special_Term_Reference__c)) {
                pricing.Loan_Number__c = application.genesis__Loan_Number__c + specialTermMap.get(rateCardDetail.Special_Term_Reference__c);
            }

            pricings.add(pricing);
            
        }
        return pricings;
        
    }

    /**
    * @description : Method to get collateral attached to an application
    * @author Suraj Kumar | 01-16-2025 
    * @param applicationId 
    * @return List<clcommon__Collateral__c> 
    **/
    public static List<clcommon__Collateral__c> getCollateralList(String applicationId){
        return [SELECT Id,
                        Price__c
                    FROM clcommon__Collateral__c 
                    WHERE genesis__Application__c =:applicationId];
    }

    /**
    * @description : Method to get party attached to an application based on the party types
    * @author Suraj Kumar | 01-16-2025 
    * @param applicationId 
    * @param partyTypes 
    * @return clcommon__Party__c 
    **/
    public static clcommon__Party__c getPartyByTypes(String applicationId, String partyTypes){
        return [SELECT Id,
                            genesis__Application__c
                        FROM clcommon__Party__c 
                        WHERE genesis__Application__c = :applicationId
                        AND clcommon__Party_Types__c = :partyTypes LIMIT 1][0];
    }

    /**
    * @description : Method to get contact by account id
    * @author Suraj Kumar | 01-16-2025 
    * @param contactAccId 
    * @return List<Contact> 
    **/
    public static Contact getContactByAccId(String contactAccId){
        return [SELECT Id, 
                        clcommon__Marital_Status__c 
                    FROM Contact 
                    WHERE AccountId = :contactAccId][0];
    }
    /**
    * @description : Method to get Account by Id
    * @author Suraj Kumar | 01-16-2025 
    * @param accountId 
    * @return Account 
    **/
    public static Account getAccountById(String accountId){
        return [SELECT Id, 
                        CFA_Partner_Program__c, 
                        Coop_Type__c 
                    FROM Account 
                    WHERE Id =: accountId][0];
    }

    /**
    * @description : method to get flex rate pricing details
    * @author Suraj Kumar | 01-16-2025 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> getFlexRatePricingDetails(){
        Map<String, Object> flexRatePricingDetails = new Map<String, Object> {
            'NoteRate' => new Map<String, Object>(),
            'SpecialTermB' => new Map<String, Object>(),
            'SpecialTermC' => new Map<String, Object>(),
            'SpecialTermD' => new Map<String, Object>{
                'description' => 'Note Rate',
                'interest' => new List<Map<String, Object>> {
                    new Map<String, Object> {
                        'Participation_Percentage_Dealer_Subsidy__c' => 0,
                        'Participation_Percentage_Dealer__c' => 0.5,
                        'Participation_Percentage_CFA__c' => 0,
                        'Start_Date__c' => Date.valueOf('2023-09-19'),
                        'End_Date__c' => Date.valueOf('2025-03-15'),
                        'genesis__Interest_Rate__c' => 12,
                        'Interest_Rate_Type__c' => 'Variable'
                    }
                }
            },

            'SpecialTermE' => new Map<String, Object> {
                'description' => 'Seeds',
                'interest' => new List<Map<String, Object>> {
                    new Map<String, Object> {
                        'Participation_Percentage_Dealer_Subsidy__c' => 0,
                        'Participation_Percentage_Dealer__c' => 0.5,
                        'Participation_Percentage_CFA__c' => 0,
                        'Start_Date__c' => Date.valueOf('2023-09-19'),
                        'End_Date__c' => Date.valueOf('2025-03-15'),
                        'genesis__Interest_Rate__c' => 12,
                        'Interest_Rate_Type__c' => 'Fixed'
                    }
                }
            }
        };
        return flexRatePricingDetails;
    }

    /**
    * @description : Method to get my program
    * @author Suraj Kumar | 01-18-2025 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    public static genesis__Rate_Card_Setup_Header__c getCurrentMyProgram(){
        genesis__Rate_Card_Setup_Header__c rateCardObj = getCFAMyProgram();
        rateCardObj.genesis__Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardObj,true);
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailList = [SELECT Id,
                                                                                    Start_Date__c 
                                                                                FROM genesis__Rate_Card_Setup_Detail__c 
                                                                                WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        rateCardSetupDetailList[0].Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardSetupDetailList[0], true);
        return rateCardObj;
    }

    /**
    * @description : Method to create dealer note
    * @author Suraj Kumar | 01-20-2025 
    * @param applicationId 
    * @param noteBody 
    * @return Note 
    **/
    public static Note createDealerNote(String applicationId, String noteBody){
        Note dealerNote = new Note();
        dealerNote.title = 'Dealer Note';
        dealerNote.body = noteBody;
        dealerNote.ParentId = applicationId;
        return dealerNote;
    }

    /**
    * @description : Method to get updated application for assertion
    * @author Suraj Kumar | 01-17-2025 
    * @param applicationId 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c getUpdatedApplication(String applicationId){
        return [SELECT Id, 
                        Name, 
                        Blanket_Lien__c, 
                        Crops_Lien__c, 
                        Lien_Options__c, 
                        Lien_Position__c, 
                        Spousal_Consent__c, 
                        Assignment_Of_Insurance__c, 
                        Jointly_Payable_Proceeds_Checks__c, 
                        Other_Additional_Requirements__c, 
                        Other_Additional_Requirements_Needed__c, 
                        Credit_Application_And_Agreement_Process__c,
                        Sales_Agent__c,
                        Sales_Agent__r.Name,
                        Growmark_Unique_Identifier__c,
                        My_Program__c,
                        My_Program__r.Name,
                        genesis__Status__c,
                        Internal_Reference_Code__c
                    FROM genesis__Applications__c
                    WHERE Id = :applicationId][0];
    }

    /**
    * @description : Method to get existing application
    * @author Suraj Kumar | 01-20-2025 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c getExistingApplication(){
        return [SELECT Id, 
                        Crop_Year__c,
                        genesis__Credit_Rating__c 
                        FROM genesis__Applications__c 
                        WHERE genesis__Loan_Number__c = '116623344' LIMIT 1][0];
    }
}