/**
 * @description       : test class for PortalApplicationCreationHandler class
 * @author            : Rakesh Saraf
 * @group             : 
 * @last modified on  : 04-07-2025
 * @last modified by  : Ayush Kumar Singh
**/
@isTest
global without sharing class PortalApplicationCreationHandlerTest {

    //Global Variable
    public static Map<String,Object> coApplicantInfo = new Map<String,Object>{
                                                                            'Street__c'=> 'East 14th Street',
                                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-7817',
                                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-7817',
                                                                            'Postal_Code__c'=> '12131',
                                                                            'Total_Assets__c'=> 100000,
                                                                            'clcommon__Contact__r.Birthdate'=> '2000-05-19',
                                                                            'Marital_Status__c'=> 'Unmarried',
                                                                            'clcommon__Contact__r.LastName'=> 'Santiago',
                                                                            'Title__c'=> 'Co-Applicant',
                                                                            'Work_Number__c'=> '3535323131',
                                                                            'Gross_Farm_Income__c'=> 100000,
                                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'amy.12@yopmail.com',
                                                                            'Is_SSN_Entered__c'=> true,
                                                                            'State__c'=> 'NY',
                                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                                            'Total_Liabilities__c'=> 1,
                                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 99999,
                                                                            'clcommon__Contact__r.FirstName'=> 'Amy',
                                                                            'clcommon__Contact__r.Email'=> 'amy.12@yopmail.com',
                                                                            'clcommon__Contact__r.genesis__SSN__c'=> '137837817',
                                                                            'City__c'=> 'New York',
                                                                            'County__c'=> 'New York County',
                                                                            'Home_Number__c'=> '1322425464',
                                                                            'clcommon__Contact__r.Confirm_SSN__c'=> '137837817',
                                                                            'Mobile_Number__c'=> '1314242424'
                                                                        };
        


    /**
    * @description test set up
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @TestSetup
    static void makeData(){
        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();

        //creating corportation legal entity.
        clcommon__Legal_Entity__c corporationLegalEntity=ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(new List<clcommon__Legal_Entity__c>{entityObj,corporationLegalEntity},true);
        
        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);

        // Creating Account for Borrower
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, ApplicationOriginationTestHelper.createBusinessInfoForBorrower().Id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.insert(new List<Account>{clAccountObj,borrowerAccountObj}, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);

        // Creating Contact for Borrower
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(new List<Contact>{clContactObj,borrowerContactObj},true);

        //creating a user for cl
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);

        // Creating User for Borrower
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(new List<User>{clUserObj,borrowerUserObj}, true);

        

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating Application
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(new Map<String,Id>{
                                                                                                                                'dealerAccountId'=> dealerAccountObj.Id,
                                                                                                                                'clProductId'=> clProductObj.Id,
                                                                                                                                'clPurposeId'=> clPurposeObj.Id,
                                                                                                                                'borrowerAccountId'=> borrowerAccountObj.Id,
                                                                                                                                'borrowerContactId'=> borrowerContactObj.Id,
                                                                                                                                'clAccountId'=> clAccountObj.Id});
        applicationObj.genesis__Loan_Amount__c=854001;
        Database.insert(applicationObj, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        //create an account
        Account testAccount=ApplicationOriginationTestHelper.createAccount();
        testAccount.genesis__Business_Information__c=ApplicationOriginationTestHelper.createBusinessInfoForBorrower().Id;
        Database.insert(testAccount,true);
        
        //create a contact
        Contact  testContact=ApplicationOriginationTestHelper.createContact();
        Database.insert(testContact,true);

        //creating a party type for borrower
        clcommon__Party_Type__c borrowerPartyType=new clcommon__Party_Type__c(Name='Borrower');

        //create new party type for principal
        clcommon__Party_Type__c principalPartyType=new clcommon__Party_Type__c(Name='PRINCIPAL');
        Database.insert(new List<clcommon__Party_Type__c>{borrowerPartyType,principalPartyType},true);
        
        //creating map for party for a borrower
        Map<String,Id> borrowerParamMap=new Map<String,Id>{
            'accountId'=>borrowerAccountObj.Id,
            'contactId'=>borrowerContactObj.Id,
            'partyTypeId'=>borrowerPartyType.Id,
            'applicationId'=>applicationObj.Id
            };

        //Creating a party of borrower
        clcommon__Party__c testBorrowerParty=ApplicationOriginationTestHelper.createParty(borrowerParamMap);

        Dealer_Applicant_Relationship__c dealerApplicantRelObj=ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.id);
        Database.insert(dealerApplicantRelObj,true);

        testBorrowerParty=ApplicationOriginationTestHelper.insertIndividualPartyDetails(testBorrowerParty,dealerApplicantRelObj.id);

        

        //creating map for creating a party
        Map<String,Id> paramMap=new Map<String,Id>{
                                                'accountId'=>testAccount.Id,
                                                'contactId'=>testContact.Id,
                                                'partyTypeId'=>principalPartyType.Id,
                                                'applicationId'=>applicationObj.Id
                                                };

        //Creating a party for principal
        clcommon__Party__c testParty=ApplicationOriginationTestHelper.createParty(paramMap);

        Dealer_Applicant_Relationship__c testdealerAppRelObj=ApplicationOriginationTestHelper.createDealerApplicantRelationship(testContact,dealerAccountObj.id);
        Database.insert(testdealerAppRelObj,true);
        
        testParty=ApplicationOriginationTestHelper.insertIndividualPartyDetails(testParty,testdealerAppRelObj.id);

        
        //creating a corporation Account
        Account corpAccount=ApplicationOriginationTestHelper.createCorporationAccount(corporationLegalEntity, dealerBusinessInfoObj.Id, dealerAccountObj.id);
        Database.insert(corpAccount,true);

        //creating a contact for corporation
        Contact corpContact= ApplicationOriginationTestHelper.createCorporationContact(corpAccount.id);
        Database.insert(corpContact,true);

        //creating a map for corp principal
        paramMap=new Map<String,Id>{
            'accountId'=>corpAccount.Id,
            'contactId'=>corpContact.Id,
            'partyTypeId'=>principalPartyType.Id,
            'applicationId'=>applicationObj.Id
            };

        //Creating a party for corporation in the application
        clcommon__Party__c corpParty=ApplicationOriginationTestHelper.createParty(paramMap);

        Dealer_Applicant_Relationship__c dealerCorpAppRelObj=ApplicationOriginationTestHelper.createDealerApplicantRelationship(corpContact,dealerAccountObj.id);
        Database.insert(dealerCorpAppRelObj,true);

        corpParty=ApplicationOriginationTestHelper.insertCorporationPartyDetails(corpParty,dealerCorpAppRelObj.id);
        Database.insert(new List<clcommon__Party__c>{testBorrowerParty,testParty,corpParty},true);

        makeSalesAgent();

    }

    /**
    * @description this is to set up the sakes agent and other requirments
    * @author Rakesh Saraf | 09-19-2024 
    **/
    static void makeSalesAgent(){
        genesis__Applications__c applicationObj=[Select id,Sales_Agent__c from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        Account dealerAccountObj=[Select id from account where name='Kisan Loan' limit 1];
        genesis__Business_Information__c dealerBusinessInfoObj=[Select id from genesis__Business_Information__c where genesis__Business_Country__c='India' limit 1];

        //creating Sales agent account
        Account saAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(saAccountObj, true);

        // Creating Contact for Sales agent
        Contact saContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(saAccountObj.Id);
        Database.insert(saContactObj,true);

        //inserting the sales agent account in the applications Sales agent field
        applicationObj.Sales_Agent__c=saAccountObj.id;
        Database.upsert(applicationObj,true);

        //creating sales agent user
        User salesAgentUser=ApplicationOriginationTestHelper.createSalesAgentUser(saContactObj.id);
        Database.insert(salesAgentUser,true);

        //creating a reciprocal role for sales agent
        clcommon__Reciprocal_Role__c saRoleObj = ApplicationOriginationTestHelper.createSalesAgentRole();
        Database.insert(saRoleObj, true);

        //create a relationship between dealer and sales agent
        clcommon__Relationship__c dealerSARelation=ApplicationOriginationTestHelper.createSalesAgentDealerRelationship(saRoleObj,dealerAccountObj.id,saAccountObj.id);
        Database.insert(dealerSARelation,true);

        //creating a sales agent admin
        Account saAdminAccObj = ApplicationOriginationTestHelper.createSAAdminAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(saAdminAccObj, true);

        //creating sales agent admin contact
        Contact saAdminContactObj=ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccObj.Id);
        Database.insert(saAdminContactObj, true);

        //creating sales agent admin user
        User saAdminUser=ApplicationOriginationTestHelper.createSAAdminUser(saAdminContactObj.id);
        Database.insert(saAdminUser,true);

        //creating related sales agent  role
        clcommon__Reciprocal_Role__c rsaRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.RELATED_SALES_AGENT);
        Database.insert(rsaRoleObj, true);

        //creating sales agent admin  role
        clcommon__Reciprocal_Role__c saaRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.SALES_AGENT_ADMIN);
        Database.insert(saaRoleObj, true);

        //creating sales agent admin relationship with dealer
        clcommon__Relationship__c relationshipObject = ApplicationOriginationTestHelper.createRelWithDealer(saaRoleObj,dealerAccountObj.Id,saAdminAccObj.Id);
        Database.insert(relationshipObject, true);

        //creating related sales agent relation with sales agent
        clcommon__Relationship__c saARelationshipObject = ApplicationOriginationTestHelper.createRelWithDealer(rsaRoleObj,saAdminAccObj.Id,saAccountObj.Id);
        Database.insert(saARelationshipObject, true);

        //create department
        genesis__Department__c newDepartment=ApplicationOriginationTestHelper.createDepartmentByName('Credit');
        Database.insert(newDepartment,true);

        //task set up
        List<genesis__Task_Setup__c> taskSetupList=new List<genesis__Task_Setup__c>();
        taskSetupList.add(ApplicationOriginationTestHelper.createTaskSetup('Task Testing 4'));
        taskSetupList.add(ApplicationOriginationTestHelper.createTaskSetup('Task Testing 5'));
        Database.insert(taskSetupList,true);

        //creating a new cfa configuration for growmark and cfa cif numbers
        CFA_Configuration__c latestCif=ApplicationOriginationTestHelper.createCIFNumber();
        Database.insert(latestCif,true);

    }
    


    /**
    * @description To test if the account will get updated from the contact details
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testUpdateAccountFromContactDetails(){

        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Account testAccount=ApplicationOriginationTestHelper.createAccount();
        testAccount.Name=null;
        Contact  testContact=ApplicationOriginationTestHelper.createContact();
        testContact.Email='helo@yopmail.com';
        testContact.HomePhone='1234567890';
        testContact.Phone='0987654321';
        testContact.MailingStreet='Action Area';
        testContact.MailingCity='Kolkata';
        testContact.MailingState='West Bengal';
        testContact.MailingPostalCode='12345';
        testContact.Mailing_County__c='Kings';

        Test.startTest();
        System.runAs(certifiedLenderUserObj){
            testAccount=PortalApplicationCreationHandler.updateAccountFromContactDetails(testAccount, testContact);
            System.assertEquals(testContact.HomePhone, testAccount.Home_Number__c,'Error in home phone number field update');
            System.assertEquals(testContact.Phone, testAccount.Work_Number__c,'Error in Work phone field update');
            System.assertEquals(testContact.Mailing_County__c,testAccount.Billing_County__c,'Biling county update error');
        }
        Test.stopTest();

    }


    /**
    * @description check that it sjould return false if same entity types are passed
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCheckEntityType(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj=[Select id,genesis__Contact__c from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        Contact contactObj=[Select id,AccountId from contact where id =:applicationObj.genesis__Contact__c limit 1];
        Account accountObj=[select id,clcommon__Legal_Entity_Type__c from account where id=:contactObj.AccountId limit 1];
        clcommon__Legal_Entity__c solePropLegalEntity=[Select id,Name from clcommon__Legal_Entity__c where Name = 'Individual(s) - Sole Proprietorship' limit 1];


        clcommon__party__c partyObj=[select id,clcommon__Account__c,clcommon__Account__r.clcommon__Legal_Entity_Type__c from clcommon__party__c 
                                                                                            WHERE genesis__Application__c =: applicationObj.id
                                                                                            AND clcommon__Type__r.Name IN (
                                                                                            :PortalConstants.PRINCIPAL_PARTY_NAME,
                                                                                            :PortalConstants.BORROWER_PARTY_NAME) limit 1];

        Account partyAccountObj=[select id,clcommon__Legal_Entity_Type__c from account where id=:partyObj.clcommon__Account__c limit 1];
        partyAccountObj.clcommon__Legal_Entity_Type__c=solePropLegalEntity.id;
        Database.upsert(partyAccountObj,true);
        accountObj.clcommon__Legal_Entity_Type__c=solePropLegalEntity.id;
        

        
        Test.startTest();
        System.runAs(certifiedLenderUserObj){
            Boolean isDifferentLegalEntity=PortalApplicationCreationHandler.checkEntityChanged(accountObj,partyObj,applicationObj);
            System.assertEquals(false, isDifferentLegalEntity,'Error in checking for same legal entity');
        }
        Test.stopTest();
    }

    /**
    * @description testing of evergreen for corporation
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCheckEvergreenForCorporation(){

        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj=[Select id,genesis__Contact__c from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        Contact contactObj=[Select id,AccountId from contact where id =:applicationObj.genesis__Contact__c limit 1];
        Account accountObj=[select id,clcommon__Legal_Entity_Type__c from account where id=:contactObj.AccountId limit 1];
        clcommon__Legal_Entity__c corpLegalEntity=[Select id,Name from clcommon__Legal_Entity__c where Name = 'Corporation' limit 1];


        clcommon__party__c partyObj=[select id,clcommon__Account__c,clcommon__Account__r.clcommon__Legal_Entity_Type__c,clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,clcommon__Account__r.genesis__Business_Information__r.genesis__State_of_Incorporation__c
                                                                                            FROM clcommon__party__c 
                                                                                            WHERE genesis__Application__c =: applicationObj.id
                                                                                            AND clcommon__Type__r.Name IN (
                                                                                            :PortalConstants.PRINCIPAL_PARTY_NAME,
                                                                                            :PortalConstants.BORROWER_PARTY_NAME) limit 1];

        Account partyAccountObj=[select id,Name,clcommon__Legal_Entity_Type__c from account where id=:partyObj.clcommon__Account__c limit 1];
        partyAccountObj.clcommon__Legal_Entity_Type__c=corpLegalEntity.id; 
        partyAccountObj.Name='Kisan Loan Seva Trust'; 
        Database.upsert(partyAccountObj,true);   

        genesis__Business_Information__c businessInfo=[Select id,genesis__State_of_Incorporation__c from genesis__Business_Information__c where genesis__Business_Country__c='India' limit 1];

        Test.startTest();
        System.runAs(certifiedLenderUserObj){
            Boolean flag=PortalApplicationCreationHandler.checkEvergreenForCorporation(accountObj,businessInfo, partyObj);
            System.assertEquals(false, flag,'Error in testing Evergreen for corporation');
        }
        Test.stopTest();

    }

    /**
    * @description testing if an account with entity type sole prop and a party account with the same entity type will be eligible for evergreen
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCheckEvergreenForSoleProp(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj=[Select id,genesis__Contact__c from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        Contact contactObj=[Select id,FirstName,LastName from contact where id =:applicationObj.genesis__Contact__c limit 1];
        contactObj.FirstName='Hello';
        contactObj.LastName='World';
        clcommon__Legal_Entity__c corpLegalEntity=[Select id,Name from clcommon__Legal_Entity__c where Name = 'Individual(s) - Sole Proprietorship' limit 1];


        clcommon__party__c partyObj=[select id,clcommon__Contact__c,clcommon__Account__r.clcommon__Legal_Entity_Type__c,clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,clcommon__Contact__r.FirstName,clcommon__Contact__r.LastName
                                                                                            FROM clcommon__party__c 
                                                                                            WHERE genesis__Application__c =: applicationObj.id
                                                                                            AND clcommon__Type__r.Name IN (
                                                                                            :PortalConstants.PRINCIPAL_PARTY_NAME,
                                                                                            :PortalConstants.BORROWER_PARTY_NAME) limit 1];

        Account partyAccountObj=[select id,clcommon__Legal_Entity_Type__c from account where id=:partyObj.clcommon__Account__c limit 1];
        partyAccountObj.clcommon__Legal_Entity_Type__c=corpLegalEntity.id; 
        Database.upsert(partyAccountObj,true);

        
        Test.startTest();
        System.runAs(certifiedLenderUserObj){
            Boolean checkEvergreen=PortalApplicationCreationHandler.checkEvergreenForSoleProp(partyObj,contactObj, applicationObj);
            System.assertEquals(true,checkEvergreen,'Error while checking for evergreen of sole prop');
        }
        Test.stopTest();

        
    }

    /**
    * @description check if necessary details are present or not
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testPopulateNecessaryAccountDetails(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Contact contactObj=ApplicationOriginationTestHelper.createContact();
        Account accountObj=new Account();
        System.runAs(certifiedLenderUserObj){
            accountObj=PortalApplicationCreationHandler.populateNecessaryAccountDetails(accountObj,contactObj);
            System.assertEquals('Beard, Red',accountObj.name,'Error while checking for evergreen of sole prop');
        }

    }

    /**
    * @description testing for changing the stage of the application
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testChangeStageOfApplication(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Credit_Rating_Matrix__c creditRating=new genesis__Credit_Rating_Matrix__c();
        creditRating.Name='Tier 1';
        Database.insert(creditRating,true);

        genesis__Applications__c applicationObj=[Select id,Is_Evergreen__c,genesis__Credit_Rating__c,genesis__Credit_Rating__r.Name,Stage__c from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        // List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList=[select id, name from genesis__Credit_Rating_Matrix__c];
        applicationObj.Is_Evergreen__c=true;
        applicationObj.genesis__Credit_Rating__c=creditRating.id;
        Database.update(applicationObj,true);

        applicationObj=[Select id,Is_Evergreen__c,genesis__Credit_Rating__c,genesis__Credit_Rating__r.Name,Stage__c from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        applicationObj.genesis__Credit_Rating__r.Name='Tier 1';
        
        List<genesis__Applications__c> applicationList=new List<genesis__Applications__c>();
        applicationList.add(applicationObj);

        Test.startTest();
        System.runAs(objAdmin){
            applicationObj=PortalApplicationCreationHandler.changeStageOfApplication(applicationList,applicationObj);
            System.assertEquals('Scoring & Credit Reference',applicationObj.Stage__c,'Error in updating the status of application');
        }
        Test.stopTest();

    }

    /**
    * @description id the irc and gmk unique identifier fields are null, then empty string will be returned
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testsetNullIfEmpty(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList=[Select id,Internal_Reference_Code__c,Growmark_Unique_Identifier__c from genesis__Applications__c where genesis__Loan_Amount__c=854001];

        Test.startTest();
        System.runAs(certifiedLenderUserObj){
            genesis__Applications__c updatedApplication=PortalApplicationCreationHandler.setNullIfEmpty(applicationList[0]);
            System.Assert.areEqual('',updatedApplication.Growmark_Unique_Identifier__c,'Growmark unique identifier is populated');
            System.Assert.areEqual('',updatedApplication.Internal_Reference_Code__c,'Internal Reference Code is populated');
        }
        Test.stopTest();
    }

    /**
    * @description check for mecessary parmeters
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void checkNecessaryParams(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

            test.startTest();
            System.runAs(certifiedLenderUserObj){
                try{
                    PortalApplicationCreationHandler.neccesaryParamCheckForApplicationCreation(null,null);
                }
                catch(CustomException except){
                    System.assertEquals(PortalConstants.SOMETHING_WENT_WRONG,except.getMessage(),'Runs properly');
                }
            }
            test.stopTest();
        
    }

    /**
    * @description throws exception as we send a null as id
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void checkthrowsExceptionIfIdNull(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

            test.startTest();
            System.runAs(certifiedLenderUserObj){
                try{
                    PortalApplicationCreationHandler.throwExceptionIfIdIsNull(null,PortalConstants.SOMETHING_WENT_WRONG);
                }
                catch(CustomException except){
                    System.assertEquals(PortalConstants.SOMETHING_WENT_WRONG,except.getMessage(),'Runs properly');
                }
            }
            test.stopTest();
        
    }

    /**
    * @description check if account nme is populated when enitity is sole prop and contact has id and a last name
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testProcessBusinessAccount(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<Contact> contactList=[Select id,LastName,FirstName,ints__Middle_Name__c from contact where LastName='Beard'];
        List<Account> accountList=[Select id,Name from Account where name='Red Beard'];
        List<genesis__Applications__c> applicationList=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        List<clcommon__Legal_Entity__c> solePropLegalEntityList=[Select id,name from clcommon__Legal_Entity__c where Name = 'Individual(s) - Sole Proprietorship'];

        accountList[0].Name=null;

        Map<String, Object> paramMap=new Map<String, Object>{
            'accountObj'=>accountList[0],
            'contactObj'=>contactList[0],
            'applicationObj'=>applicationList[0],
            'entity'=>solePropLegalEntityList[0].Name
        };

        Test.startTest();
        System.runAs(objAdmin){
            Account returnedAcc=PortalApplicationCreationHandler.processBusinessAccount(paramMap);
            System.assert(returnedAcc.name!=null,'Process business acc not working');
        }
        Test.stopTest();
    }

    /**
    * @description assinging a new profile id to a new user for growmark
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testAssigningGMKProfileToNewUser(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        New_Portal_User__e newPortalUser=new New_Portal_User__e();
        String coopType='Growmark';
        Test.startTest();
        System.runAs(certifiedLenderUserObj){
            newPortalUser=PortalApplicationCreationHandler.assigningProfileToNewUser(newPortalUser,coopType);
            System.assert(newPortalUser.Profile_Id__c!=null,'Incorrect assignment');
        }
        Test.stopTest();
    }

    /**
    * @description assinging a new profile id to a new user for cfa
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testAssigningCFAProfileToNewUser(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        New_Portal_User__e newPortalUser=new New_Portal_User__e();
        String coopType='';
        Test.startTest();
        System.runAs(certifiedLenderUserObj){
            newPortalUser=PortalApplicationCreationHandler.assigningProfileToNewUser(newPortalUser,coopType);
            System.assert(newPortalUser.Profile_Id__c!=null,'Incorrect assignment');
        }
        Test.stopTest();
    }

    /**
    * @description sets a default value for term and interest if those fields are null for the application
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testSetDefaultValue(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<genesis__Applications__c> applicationList=[Select id,genesis__Term__c,genesis__Interest_Rate__c,genesis__Pricing_Method__c,genesis__Product_Type__c from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        
        Test.startTest();
        System.runAs(objAdmin){
            genesis__Applications__c updatedApplication=PortalApplicationCreationHandler.setDefaultValue(applicationList[0]);
            System.assertEquals(12,updatedApplication.genesis__Term__c,'Application info is wrong');
        }
        Test.stopTest();
    }

    /**
    * @description throws exception when the loan amount is set to null for the application
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCheckRequiredParamsNullLoanAmount(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Test.startTest();
        System.runAs(certifiedLenderUserObj){
            try{
                Map<String, Object> paramMap=new Map<String, Object>{
                    'loanAmount'=>null,
                    'entityType'=>'Individual(s) - Sole Proprietorship'
                };
                PortalApplicationCreationHandler.checkRequiredParamsForNewApplicant(paramMap);
            }
            catch(CustomException excp){
                System.assertEquals('Something went wrong', excp.getMessage(),'Wrong Exception thrown');
            }

        }
        Test.stopTest();
    }

    /**
    * @description throws exception when the company name or the dba name is null
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCheckRequiredParamsNullCompany(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Test.startTest();
        System.runAs(certifiedLenderUserObj){
            try{
                Map<String, Object> paramMap=new Map<String, Object>{
                    'loanAmount'=>10000,
                    'entityType'=>'Individual(s) - Sole Proprietorship',
                    'companyName'=>'',
                    'DBAName'=>'',
                    'firstName'=>'',
                    'lastName'=>'Beard'
                };
                PortalApplicationCreationHandler.checkRequiredParamsForNewApplicant(paramMap);
            }
            catch(CustomException excp){
                System.assertEquals('Something went wrong', excp.getMessage(),'Wrong Exception thrown');
            }

        }
        Test.stopTest();
    }

    /**
    * @description throws wxception cause the email is set to null
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCheckRequiredParamsNullEmail(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Test.startTest();
        System.runAs(certifiedLenderUserObj){
            try{
                Map<String, Object> paramMap=new Map<String, Object>{
                    'loanAmount'=>10000,
                    'entityType'=>'Individual(s) - Sole Proprietorship',
                    'companyName'=>'Apex Tech',
                    'DBAName'=>'Apex',
                    'firstName'=>'Red',
                    'lastName'=>'Beard',
                    'email'=>''
                };
                PortalApplicationCreationHandler.checkRequiredParamsForNewApplicant(paramMap);
            }
            catch(CustomException excp){
                System.assertEquals('Please enter the email for all the applicants.', excp.getMessage(),'Wrong Exception thrown');
            }

        }
        Test.stopTest();
    }

    /**
    * @description set the phone nu,ber and the home phone numbers if they are present in the param map
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testSetEmptyIfNumbersBlank(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, String> paramMap=new Map<String, String>{
            'HomePhone'=>'0987654321',
            'Phone'=>'12345678'
        };
        Account accountObj=ApplicationOriginationTestHelper.createAccount();
        Contact contactObj=ApplicationOriginationTestHelper.createContact();
        Test.startTest();
        System.runAs(certifiedLenderUserObj){
            Account returnedAccount=PortalApplicationCreationHandler.setEmptyIfNumbersBlank(accountObj,paramMap);
            Contact returnedContact=PortalApplicationCreationHandler.setEmptyIfNumbersBlank(contactObj,paramMap);

            System.assertEquals(returnedAccount.Home_Number__c,paramMap.get('HomePhone'),'Did not get the correct number');
            System.assertEquals(returnedContact.HomePhone,paramMap.get('HomePhone'),'Did not get the correct number');
        }
    }

    /**
    * @description sets the details in the account from the contact
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testSetContactDetailsfromExistingContact(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Contact contactObj=ApplicationOriginationTestHelper.createContact();

        contactObj.MailingStreet = 'Action area 1';
        contactObj.MailingCity = 'Kolkata';
        contactObj.MailingState = 'WB';
        contactObj.MailingPostalCode = '700156';
        contactObj.Mailing_County__c = 'Kings';
        contactObj.Birthdate = Date.today();
        contactObj.clcommon__Marital_Status__c = 'Unmarried';
        contactObj.Suffix__c ='Jr.';
        contactObj.MobilePhone = '1234567890';
        contactObj.HomePhone = '0987654321';
        contactObj.Phone='45678234';
        Database.insert(contactObj,true);
        Test.startTest();
        System.runAs(objAdmin){
            Contact returnedContact=PortalApplicationCreationHandler.setContactDetailsFromExistingContact(contactObj);
            System.assertEquals(contactObj.MailingStreet,returnedContact.MailingStreet,'Error in filling contact details');
        }
        Test.stopTest();
    }

    /**
    * @description sets the details of the account from the account queried using the accountid field from the contact
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testSetContactDetailsfromExistingAccount(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Account accountObj=ApplicationOriginationTestHelper.createAccount();

        accountObj.BillingStreet = 'Action Area 1';
        accountObj.BillingCity = 'Kolkata';
        accountObj.BillingState = 'WB';
        accountObj.BillingPostalCode = '20131';
        accountObj.Billing_County__c = 'Kings';
        accountObj.Work_Number__c = '1234567890';
        accountObj.Home_Number__c = '098765432';
        accountObj.Phone ='52745725472';
        Database.insert(accountObj,true);

        Contact contactObj=ApplicationOriginationTestHelper.createContact();
        contactObj.AccountId=accountObj.id;
        Database.insert(contactObj,true);

        Test.startTest();
        System.runAs(objAdmin){
            Account returnedAccount=PortalApplicationCreationHandler.setAccountDetailsFromExistingAccount(accountObj,contactObj);
            System.assertEquals(accountObj.BillingStreet,returnedAccount.BillingStreet,'Error in filling account details');
        }
        Test.stopTest();
    }

    /**
    * @description test if it returns the erp id from nthe application
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testGetErpId(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj=[Select id,ERP_Id__c,genesis__Account__c,Dealer_Name__r.Enable_ERP_Id__c,Dealer_Name__c,genesis__Status__c  from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        applicationObj.genesis__Status__c='ACTIVE';
        applicationObj.ERP_Id__c='abc12345';
        Database.upsert(applicationObj,true);

        Account dealerAcc=[Select id,Enable_ERP_Id__c from account where name='Kisan Loan' limit 1];
        dealerAcc.Enable_ERP_Id__c=true;
        Database.upsert(dealerAcc,true);

        Account growerAcc=[Select id from account where id =:applicationObj.genesis__Account__c];

        // Test.startTest();
        // System.runAs(objAdmin){
        //     //String erpId=PortalApplicationCreationHandler.getErpId(growerAcc.id,dealerAcc.id);
        //     //System.assertEquals(applicationObj.ERP_Id__c,erpId,'Error in getting erp id');
        // }
        // Test.stopTest();
    }

    /**
    * @description testing for erp id when the erp id is disabled
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testDisabledValidateErpId(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj=[Select id,ERP_Id__c,genesis__Account__c,Dealer_Name__r.Enable_ERP_Id__c,Dealer_Name__c,genesis__Status__c  from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        applicationObj.genesis__Status__c='ACTIVE';
        applicationObj.ERP_Id__c='abc12345';
        Database.upsert(applicationObj,true);

        Account dealerAcc=[Select id,Enable_ERP_Id__c from account where name='Kisan Loan' limit 1];
        dealerAcc.Enable_ERP_Id__c=false;
        Database.upsert(dealerAcc,true);

        Test.startTest();
        System.runAs(objAdmin){
            String erpId=PortalApplicationCreationHandler.validateErpId(applicationObj.ERP_Id__c, applicationObj.id, true);
            System.assertEquals(applicationObj.ERP_Id__c,erpId,'Error in validating erp id');
        }
        Test.stopTest();
    }

    /**
    * @description testing for erp id when the erp id is a required field for the dealer account
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testIsRequiredValidateErpId(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj=[Select id,ERP_Id__c,genesis__Account__c,Dealer_Name__r.Enable_ERP_Id__c,Dealer_Name__c,genesis__Status__c  from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        applicationObj.genesis__Status__c='ACTIVE';
        applicationObj.ERP_Id__c='abc12345';
        Database.upsert(applicationObj,true);

        Account dealerAcc=[Select id,Enable_ERP_Id__c,Is_Required_ERP_Id__c from account where name='Kisan Loan' limit 1];
        dealerAcc.Enable_ERP_Id__c=true;
        dealerAcc.Is_Required_ERP_Id__c=true;
        Database.upsert(dealerAcc,true);

        Test.startTest();
        System.runAs(objAdmin){
            String erpId=PortalApplicationCreationHandler.validateErpId(applicationObj.ERP_Id__c, applicationObj.id, true);
            System.assertEquals(applicationObj.ERP_Id__c,erpId,'Error in validating erp id');
        }
        Test.stopTest();
    }

    /**
    * @description checking for necessary parameters
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCheckParams(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(certifiedLenderUserObj){
            try{
                PortalApplicationCreationHandler.checkNecessaryParam(null,null);
            }
            catch(CustomException excp){
                System.assertEquals('Something went wrong',excp.getMessage(),'Exception not thrown');
            }
        }
        Test.stopTest();
    }

    /**
    * @description test if it updates the business info id by querying the business id from the account linked to the contact
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testUpdateBusinessInfo(){

        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];


        genesis__Business_Information__c businessInfoObj=ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoObj,true);
        Account accountObj=ApplicationOriginationTestHelper.createAccount();
        accountObj.genesis__Business_Information__c=businessInfoObj.id;
        Database.insert(accountObj,true);
        Contact contactObj=ApplicationOriginationTestHelper.createContact();
        contactObj.AccountId=accountObj.id;
        Database.insert(contactObj,true);

        genesis__Business_Information__c newBusinesInfo=new genesis__Business_Information__c();
        Test.startTest();
        System.runAs(objAdmin){
            PortalApplicationCreationHandler.updateBusinessInfo(contactObj.id,newBusinesInfo);
            System.assert(newBusinesInfo.id!=null,'Error in updating business info');
        }
        Test.stopTest();
    }

    /**
    * @description testing to get the cif number for both cases where account id is null and populated for growmark
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testUpdateCifforAccountNullIdGrowmark(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Account accountObj=ApplicationOriginationTestHelper.createAccount();
        Test.startTest();
        System.runAs(certifiedLenderUserObj){
            accountObj=PortalApplicationCreationHandler.updateCifForAccount(accountObj,'Growmark');
            accountObj.CIF_Number__c='';
            Database.upsert(accountObj,true);
            accountObj=PortalApplicationCreationHandler.updateCifForAccount(accountObj,'Growmark');
            System.assertEquals('1000502', accountObj.CIF_Number__c,'Did not update cif number for acc');
        }
        Test.stopTest();
    }

    /**
    * @description testing to get the cif number for both cases where account id is null and populated for cfa
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testUpdateCifforAccountNullIdCFA(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Account accountObj=ApplicationOriginationTestHelper.createAccount();
        Test.startTest();
        System.runAs(certifiedLenderUserObj){
            accountObj=PortalApplicationCreationHandler.updateCifForAccount(accountObj,'CFA');
            accountObj.CIF_Number__c='';
            Database.upsert(accountObj,true);
            accountObj=PortalApplicationCreationHandler.updateCifForAccount(accountObj,'CFA');

            System.assertEquals('32454346', accountObj.CIF_Number__c,'Did not update cif number for acc');
        }
        Test.stopTest();
    }

    /**
    * @description updating the coApplicant details from the map
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testUpdateCoApplicantContactDetails(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Test.startTest();
        System.runAs(objAdmin){
            Contact returnedContact=PortalApplicationCreationHandler.updateCoApplicantContactDetails(coApplicantInfo);
            System.assertEquals(coApplicantInfo.get('clcommon__Contact__r.FirstName'), returnedContact.FirstName,'Error in filling contact details');
        }
        Test.stopTest();

    }

    /**
    * @description testing for the number of inactive users to be one
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testDeleteRedundantAccount(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj=[Select id,genesis__Contact__c from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        
        Contact contactObj=[Select id,AccountId from contact where id =:applicationObj.genesis__Contact__c limit 1];

        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Test.startTest();
        System.runAs(objAdmin){
            PortalApplicationCreationHandler.deleteRedundantAccountAndContact(contactobj,applicationObj.id,certifiedLenderUserObj);
            List<User> inactiveUser=[select id,IsActive from user where accountId =: contactObj.AccountId];
            System.assert(inactiveUser.size()>0,'Delete Redundant acc and contact not working');
        }
        Test.stopTest();
    }

    /**
    * @description check if a new task is created for the application
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCreateTasks(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];

        Test.startTest();
        System.runAs(objAdmin){
            PortalApplicationCreationHandler.createTasks((String)applicationObj.id);
            List<Task> taskList=[Select id from Task where WhatId=:applicationObj.id];
            System.assert(taskList.size()>0,'Create task not working');
        }
        Test.stopTest();
    }

    /**
    * @description check if the details of the portal user is populated using the map and the return the user
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testSetPortalUserDetails(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Account accountObj=[Select id from account where name='Red Beard' limit 1];
        Contact contactObj=[select id from contact where FirstName='Red' limit 1];

        Map<String,Object> portalUserParamMap=new Map<String,Object>{
                                                            'portalUserEmail'=>'porta.user@yopmail.com',
                                                            'portalUserFirstName'=>'Portal',
                                                            'portalUserLastName'=>'User',
                                                            'portalUserAccountId'=>accountObj.id,
                                                            'portalUserContactId'=>contactObj.id,
                                                            'portalUserCIFNumber'=>'115282'
        };
        New_Portal_User__e newPortalUser=new New_Portal_User__e();
        Test.startTest();
        System.runAs(certifiedLenderUserObj){
            newPortalUser=PortalApplicationCreationHandler.setPortalUserDetails(newPortalUser,portalUserParamMap);
            System.assertEquals(portalUserParamMap.get('portalUserEmail'),newPortalUser.Email__c,'Set portal user details not working');
        }
        Test.stopTest();
    }

    /**
    * @description test iof fields like year began farming and gross farm income have been updated from the business information object and the account
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testValidateNewEDEFieldsMap(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Account accountObj=[Select id,Year_Began_Farming__c from account where name='Red Beard'];
        accountObj.Year_Began_Farming__c='2014';
        genesis__Business_Information__c businessInfo=[Select id,Gross_Farm_Income__c from genesis__Business_Information__c where genesis__Business_Country__c='India'];
        businessInfo.Gross_Farm_Income__c=500000;
        Test.startTest();
        System.runAs(certifiedLenderUserObj){
            Map<String, Object> returnedMap=PortalApplicationCreationHandler.validateNewEDEFieldsMap(accountObj,businessInfo,'Individual(s) - Sole Proprietorship');
            System.assertEquals(accountObj.Year_Began_Farming__c,returnedMap.get('Year_Began_Farming__c'),'Set portal user details not working');
        }
        Test.stopTest();
    }

}