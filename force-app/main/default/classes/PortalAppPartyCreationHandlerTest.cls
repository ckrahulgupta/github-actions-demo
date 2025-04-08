/**
 * @description       : This is a test class for PortalApplicationCreationHandler class where all the functions are related to party
 * @author            : Rakesh Saraf
 * @group             : 
 * @last modified on  : 03-26-2025
 * @last modified by  : Rakesh Saraf
**/
@isTest
global without sharing class PortalAppPartyCreationHandlerTest {
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
        genesis__Business_Information__c borrowerBusinessInfo = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj,borrowerBusinessInfo}, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);

        // Creating Account for Borrower
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfo.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();

        //creating a corporation Account
        Account corpAccount=ApplicationOriginationTestHelper.createCorporationAccount(corporationLegalEntity, dealerBusinessInfoObj.Id, dealerAccountObj.id);

        //create an account
        Account testAccount=ApplicationOriginationTestHelper.createAccount();
        testAccount.genesis__Business_Information__c=dealerBusinessInfoObj.id;

        Database.insert(new List<Account>{borrowerAccountObj,clAccountObj,testAccount,corpAccount}, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);

        // Creating Contact for Borrower
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);

        //create a contact
        Contact  testContact=ApplicationOriginationTestHelper.createContact();
        testContact.AccountId=testAccount.id;

        //creating a contact for corporation
        Contact corpContact= ApplicationOriginationTestHelper.createCorporationContact(corpAccount.id);

        Database.insert(new List<Contact>{clContactObj,borrowerContactObj,testContact,corpContact},true);

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

        Dealer_Applicant_Relationship__c dealerApplicantRelObj=ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.id);
        Database.insert(dealerApplicantRelObj,true);

        // Creating map for Application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>();
        paramForApplicationMap.put('dealerAccountId', dealerAccountObj.Id);
        paramForApplicationMap.put('clProductId', clProductObj.Id);
        paramForApplicationMap.put('clPurposeId', clPurposeObj.Id);
        paramForApplicationMap.put('borrowerAccountId', borrowerAccountObj.Id);
        paramForApplicationMap.put('borrowerContactId', borrowerContactObj.Id);
        paramForApplicationMap.put('clAccountId', clAccountObj.Id);

        // Creating Application
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        applicationObj.genesis__Loan_Amount__c=854001;
        applicationObj.Dealer_Applicant_Relationship__c=dealerApplicantRelObj.id;
        Database.insert(applicationObj, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        //creating a party type for borrower
        clcommon__Party_Type__c borrowerPartyType=new clcommon__Party_Type__c(Name='Borrower');

        //create new party type for principal
        clcommon__Party_Type__c principalPartyType=new clcommon__Party_Type__c(Name='PRINCIPAL');
        Database.insert(new List<clcommon__Party_Type__c>{borrowerPartyType,principalPartyType},true);
        

        //Creating a party of borrower
        clcommon__Party__c testborrower=ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                                    'accountId'=>borrowerAccountObj.Id,
                                                                                                    'contactId'=>borrowerContactObj.Id,
                                                                                                    'partyTypeId'=>borrowerPartyType.Id,
                                                                                                    'applicationId'=>applicationObj.Id
                                                                                                    });
        testborrower=ApplicationOriginationTestHelper.insertIndividualPartyDetails(testborrower,dealerApplicantRelObj.id);

        //Creating a party for principal
        clcommon__Party__c testParty=ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                                'accountId'=>testAccount.Id,
                                                                                                'contactId'=>testContact.Id,
                                                                                                'partyTypeId'=>principalPartyType.Id,
                                                                                                'applicationId'=>applicationObj.Id
                                                                                                });

        Dealer_Applicant_Relationship__c dealerPrincipalRelObj =ApplicationOriginationTestHelper.createDealerApplicantRelationship(testContact,dealerAccountObj.id);
        Database.insert(dealerPrincipalRelObj,true);

        testParty=ApplicationOriginationTestHelper.insertIndividualPartyDetails(testParty,dealerPrincipalRelObj.id);

        //creating a credit Rating Matrix
        List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList=ApplicationOriginationTestHelper.createCreditRatingMatrix();
        Database.insert(creditRatingMatrixList,true);

        //Creating a party for corporation in the application
        clcommon__Party__c corpParty=ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                                    'accountId'=>corpAccount.Id,
                                                                                                    'contactId'=>corpContact.Id,
                                                                                                    'partyTypeId'=>principalPartyType.Id,
                                                                                                    'applicationId'=>applicationObj.Id
                                                                                                    });

        Dealer_Applicant_Relationship__c dealerCorpAppRelObj=ApplicationOriginationTestHelper.createDealerApplicantRelationship(corpContact,dealerAccountObj.id);
        Database.insert(dealerCorpAppRelObj,true);

        corpParty=ApplicationOriginationTestHelper.insertCorporationPartyDetails(corpParty,dealerCorpAppRelObj.id);
        Database.insert(new List<clcommon__Party__c>{testborrower,testParty,corpParty},true);

        //creating a new cfa configuration for growmark and cfa cif numbers
        CFA_Configuration__c latestCif=ApplicationOriginationTestHelper.createCIFNumber();
        Database.insert(latestCif,true);

        makeSalesAgent();

    }

    /**
    * @description this is to set up the sakes agent
    * @author Rakesh Saraf | 09-19-2024 
    **/
    static void makeSalesAgent(){
        Account dealerAccountObj=[Select id,genesis__Business_Information__c from account where name='Kisan Loan' limit 1];
        genesis__Business_Information__c dealerBusinessInfoObj=[Select id from genesis__Business_Information__c where id=:dealerAccountObj.genesis__Business_Information__c limit 1];
        genesis__Applications__c applicationObj=[Select id,Sales_Agent__c from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];

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

        //creating a reciprocal role for sales agent
        clcommon__Reciprocal_Role__c saRoleObj = ApplicationOriginationTestHelper.createSalesAgentRole();
        Database.insert(saRoleObj, true);

        //create a relationship between dealer and sales agent
        clcommon__Relationship__c dealerSARelation=ApplicationOriginationTestHelper.createSalesAgentDealerRelationship(saRoleObj,dealerAccountObj.id,saAccountObj.id);
        Database.insert(dealerSARelation,true);

        //creating a sales agent admin
        Account saAdminAccObj = ApplicationOriginationTestHelper.createSAAdminAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(saAdminAccObj, true);

        //creating sa admin contact
        Contact saAdminContactObj=ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccObj.Id);
        Database.insert(saAdminContactObj, true);

        //creating sa admin user
        User saAdminUser=ApplicationOriginationTestHelper.createSAAdminUser(saAdminContactObj.id);
        Database.insert(new List<USer>{salesAgentUser,saAdminUser},true);

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

        //creating sales agent party type
        clcommon__Party_Type__c saPartyType=ApplicationOriginationTestHelper.createPartyType('SALES AGENT');

        //creating party type of certified lender plus
        clcommon__Party_Type__c partyTypeCLP=ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER PLUS');

        //creating party type of Inquiry
        clcommon__Party_Type__c partyTypeInq=ApplicationOriginationTestHelper.createPartyType('INQUIRY');

        //creating party type of Inquiry plus
        clcommon__Party_Type__c partyTypeIP=ApplicationOriginationTestHelper.createPartyType('INQUIRY PLUS');

        //creating party type of FSA
        clcommon__Party_Type__c partyTypeFSA=ApplicationOriginationTestHelper.createPartyType('FIELD STAFF AGENT');

        //creating party type of PA
        clcommon__Party_Type__c partyTypePA=ApplicationOriginationTestHelper.createPartyType('PAYMENT ADMINISTRATOR');
        Database.insert(new List<clcommon__Party_Type__c>{saPartyType,partyTypeCLP,partyTypeInq,partyTypeIP,partyTypeFSA,partyTypePA},true);
    }

    /**
    * @description creates a new party record with party type
    * @author Rakesh Saraf | 09-17-2024 
    * @param paramMap 
    * @param partyType 
    * @return clcommon__Party__c 
    **/
    public static clcommon__Party__c createPartyWithTypes(Map<String, Id> paramMap,String partyType){
        clcommon__Party__c partyObj = new clcommon__Party__c();
        partyObj.clcommon__Account__c=paramMap.get('accountId');
        partyObj.clcommon__Contact__c=paramMap.get('contactId');
        partyObj.clcommon__Type__c = paramMap.get('partyTypeId');
        partyObj.genesis__Application__c = paramMap.get('applicationId');
        partyObj.clcommon__Party_Types__c = partyType;
        partyObj.Total_Assets__c = 2346;
        partyObj.Total_Liabilities__c = 2423433;
        return partyObj;
    }

    /**
    * @description run get parties related to cl where the record type of the party account is certified lender plus
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testGetPartiesForRelatedCLUsingCLP(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Contact partyContact=[Select id,AccountId,Account.Id,Account.RecordType.Name from contact where FirstName='Red' limit 1];
        List<clcommon__Party__c> partyList=new List<clcommon__Party__c>();
        genesis__Applications__c applicationObj=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        List<Contact> contactList=new List<Contact>();
        partyContact.Account.RecordType.Name='Certified Lender Plus';
        contactList.add(partyContact);

        System.runAS(certifiedLenderUserObj){
            Test.startTest();
            partyList=PortalApplicationCreationHandler.getPartiesForRelatedCL(partyList,contactList,applicationObj.id);
            System.assert(partyList.size()>0,'get party list related to cl issue');
            Test.stopTest();
        }
    }

    /**
    * @description run get parties related to cl where the record type of the party account is inquiry
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testGetPartiesForRelatedCLUsingInq(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Contact partyContact=[Select id,AccountId,Account.Id,Account.RecordType.Name from contact where FirstName='Red' limit 1];
        List<clcommon__Party__c> partyList=new List<clcommon__Party__c>();
        genesis__Applications__c applicationObj=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        List<Contact> contactList=new List<Contact>();
        partyContact.Account.RecordType.Name='Inquiry';
        contactList.add(partyContact);

        System.runAS(certifiedLenderUserObj){
            Test.startTest();
            partyList=PortalApplicationCreationHandler.getPartiesForRelatedCL(partyList,contactList,applicationObj.id);
            System.assert(partyList.size()>0,'get party list related to cl issue');
            Test.stopTest();
        }
    }

    /**
    * @description run get parties related to cl where the record type of the party account is inquiry plus
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testGetPartiesForRelatedCLUsingIP(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
         
        Contact partyContact=[Select id,AccountId,Account.Id,Account.RecordType.Name from contact where FirstName='Red' limit 1];
        List<clcommon__Party__c> partyList=new List<clcommon__Party__c>();
        genesis__Applications__c applicationObj=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        List<Contact> contactList=new List<Contact>();
        partyContact.Account.RecordType.Name='Inquiry Plus' ;
        contactList.add(partyContact);

        System.runAS(certifiedLenderUserObj){
            Test.startTest();
            partyList=PortalApplicationCreationHandler.getPartiesForRelatedCL(partyList,contactList,applicationObj.id);
            System.assert(partyList.size()>0,'get party list related to cl issue');
            Test.stopTest();
        }
    }

    /**
    * @description run get parties related to cl where the record type of the party account is pa
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testGetPartiesForRelatedCLUsingPA(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
         
        Contact partyContact=[Select id,AccountId,Account.Id,Account.RecordType.Name from contact where FirstName='Red' limit 1];
        List<clcommon__Party__c> partyList=new List<clcommon__Party__c>();
        genesis__Applications__c applicationObj=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        List<Contact> contactList=new List<Contact>();
        partyContact.Account.RecordType.Name='Payment Administrator';
        contactList.add(partyContact);

        System.runAS(certifiedLenderUserObj){
            Test.startTest();
            partyList=PortalApplicationCreationHandler.getPartiesForRelatedCL(partyList,contactList,applicationObj.id);
            System.assert(partyList.size()>0,'get party list related to cl issue');
            Test.stopTest();
        }
    }

    /**
    * @description run get parties related to cl where the record type of the party account is field staff agent
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testGetPartiesForRelatedCLUsingFSA(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
         
        Contact partyContact=[Select id,AccountId,Account.Id,Account.RecordType.Name from contact where FirstName='Red' limit 1];
        List<clcommon__Party__c> partyList=new List<clcommon__Party__c>();
        genesis__Applications__c applicationObj=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        List<Contact> contactList=new List<Contact>();
        partyContact.Account.RecordType.Name='Field Staff Agent' ;
        contactList.add(partyContact);

        System.runAS(certifiedLenderUserObj){
            Test.startTest();
            partyList=PortalApplicationCreationHandler.getPartiesForRelatedCL(partyList,contactList,applicationObj.id);
            System.assert(partyList.size()>0,'get party list related to cl issue');
            Test.stopTest();
        }
    }

    /**
    * @description get the count of the number of princial that exists link to an application
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testGetPrincipalPartyCount(){

        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        
        Account testAccount=ApplicationOriginationTestHelper.createAccount();
        Contact  testContact=ApplicationOriginationTestHelper.createContact();
        List<clcommon__Party_Type__c> principalPartyTypeList=[SELECT Id FROM clcommon__Party_Type__c where Name='PRINCIPAL'];
        //System.debug(principalPartyTypeList);
        List<genesis__Applications__c> applicationList=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];

        //Id idd='a2lVD000002AVGPYA4';
        Map<String,Id> paramMap=new Map<String,Id>{
                                                'accountId'=>testAccount.Id,
                                                'contactId'=>testContact.Id,
                                                'partyTypeId'=>principalPartyTypeList[0].Id,
                                                'applicationId'=>applicationList[0].Id
                                            };

        List<clcommon__Party__c> principalPartyList=new List<clcommon__Party__c>();

        clcommon__Party__c testParty=createPartyWithTypes(paramMap,'PRINCIPAL');
        principalPartyList.add(testParty);

        testParty=createPartyWithTypes(paramMap,'PRINCIPAL');
        principalPartyList.add(testParty);

        System.runAs(certifiedLenderUserObj){
            Test.startTest();
            Integer partyCount=PortalApplicationCreationHandler.getPrincipalPartyCount(principalPartyList);
            System.assertEquals(2, partyCount, 'Error in counting Parties');
            Test.stopTest();
        }
    }

    /**
    * @description test create dealer party where the logged in user is a cl
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCreateDealerPartyUsingCL(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        User certifiedLenderUserObj =[Select id,AccountId,ContactId,Account.ParentId from user where username='ross.geller@yopmail.com'];
        List<genesis__Applications__c> applicationList=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        Contact primaryApplicantContact=[Select id from Contact where LastName='Beard'];
        String shouldValidate='SaveAndContinue';
        Map<String, Object> paramForDealerPartyMap = new Map<String, Object>{
            'loggedInUser' => certifiedLenderUserObj,
            'applicationObj' => applicationList[0],
            'primaryApplicant' => primaryApplicantContact,
            'createPrimaryApplicant' => false,
            'shouldValidate' => shouldValidate
        };

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.createDealerParty(paramForDealerPartyMap);
            applicationList=[Select id,Certified_Lender__c from genesis__Applications__c where genesis__Loan_Amount__c=854001];
            System.assert(applicationList[0].Certified_Lender__c!=null,'Create Dealer party not working');
            Test.stopTest();
        }
    }

    /**
    * @description test create dealer party where the logged in user is a sales agent. Here a new party of the sales agent admin should also be created
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCreateDealerPartyUsingSA(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        User salesAgentUserObj =[Select id,AccountId,ContactId,Account.ParentId from user where username='tony.stark@yopmail.com'];
        List<genesis__Applications__c> applicationList=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        Contact primaryApplicantContact=[Select id from Contact where LastName='Beard'];
        String shouldValidate='SaveAndContinue';
        Map<String, Object> paramForDealerPartyMap = new Map<String, Object>{
            'loggedInUser' => salesAgentUserObj,
            'applicationObj' => applicationList[0],
            'primaryApplicant' => primaryApplicantContact,
            'createPrimaryApplicant' => false,
            'shouldValidate' => shouldValidate
        };

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.createDealerParty(paramForDealerPartyMap);
            applicationList=[Select id,Certified_Lender__c from genesis__Applications__c where genesis__Loan_Amount__c=854001];
            System.assert(applicationList[0].Certified_Lender__c!=null,'Create Dealer party not working');
            Test.stopTest();
        }
    }

    /**
    * @description test create dealer party where the logged in user is a sales agent admin
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCreateDealerPartyUsingSaAdmin(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        User saAdminUserObj =[Select id,AccountId,ContactId,Account.ParentId from user where username='tim.couper@yopmail.com'];
        //System.debug(saAdminUserObj);
        List<genesis__Applications__c> applicationList=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        Contact primaryApplicantContact=[Select id from Contact where LastName='Beard'];
        String shouldValidate='SaveAndContinue';
        Map<String, Object> paramForDealerPartyMap = new Map<String, Object>{
            'loggedInUser' => saAdminUserObj,
            'applicationObj' => applicationList[0],
            'primaryApplicant' => primaryApplicantContact,
            'createPrimaryApplicant' => false,
            'shouldValidate' => shouldValidate
        };

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.createDealerParty(paramForDealerPartyMap);
            applicationList=[Select id,Certified_Lender__c from genesis__Applications__c where genesis__Loan_Amount__c=854001];
            System.assert(applicationList[0].Certified_Lender__c!=null,'Create Dealer party not working');
            Test.stopTest();
        }
    }

    /**
    * @description new parties should be created for the new application from the existing application if non of them have- has past due and non accural as false
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCreatePrincipalParty(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<genesis__Applications__c> applicationList=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        genesis__Applications__c newApplication=new genesis__Applications__c();
        Database.insert(newApplication,true);

        Map<String, Id> paramMap=new Map<String, Id>{
            'existingApplicationId'=>applicationList[0].Id,
            'applicationId'=>newApplication.id
        };

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.createPrincipalParty(paramMap);
            List<clcommon__Party__c> partyList=[Select id from clcommon__Party__c where genesis__Application__c=:newApplication.id];
            System.assert(partyList!=null,'Party has been created for new application');
            Test.stopTest();
        }
    }

    /**
    * @description should throw exception cause one of the parties has Has past dues as true
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCreatePrincipalPartyHasPastDue(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<genesis__Applications__c> applicationList=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];

        clcommon__Party__c partyOfApplication=[Select id,clcommon__Account__c,clcommon__Account__r.Has_Past_Due__c from clcommon__Party__c where genesis__Application__c=:applicationList[0].id and clcommon__Type__r.Name IN (:PortalConstants.PRINCIPAL_PARTY_NAME) ORDER BY CreatedDate ASC limit 1];

        Account partyAccount=[select id,Has_Past_Due__c from account where id=:partyOfApplication.clcommon__Account__c limit 1];
        partyAccount.Has_Past_Due__c=true;
        Database.upsert(partyAccount,true);

        genesis__Applications__c newApplication=new genesis__Applications__c();
        Database.insert(newApplication,true);

        Map<String, Id> paramMap=new Map<String, Id>{
            'existingApplicationId'=>applicationList[0].Id,
            'applicationId'=>newApplication.id
        };

        System.runAs(adminUser){
            Test.startTest();
            try{
                PortalApplicationCreationHandler.createPrincipalParty(paramMap);
            }
            catch(CustomException excp){
                System.assert(excp.getMessage()!=null,'Exception works');
            }
            Test.stopTest();
        }
    }

    /**
    * @description should throw exception cause one of the parties has non Accural as true
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCreatePrincipalPartyNonAccural(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<genesis__Applications__c> applicationList=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];

        clcommon__Party__c partyOfApplication=[Select id,clcommon__Account__c from clcommon__Party__c where genesis__Application__c=:applicationList[0].id and clcommon__Type__r.Name IN (:PortalConstants.PRINCIPAL_PARTY_NAME) ORDER BY CreatedDate ASC limit 1];

        Account partyAccount=[select id,Non_Accrual__c from account where id=:partyOfApplication.clcommon__Account__c limit 1];
        partyAccount.Non_Accrual__c=true;
        Database.upsert(partyAccount,true);

        genesis__Applications__c newApplication=new genesis__Applications__c();
        Database.insert(newApplication,true);

        Map<String, Id> paramMap=new Map<String, Id>{
            'existingApplicationId'=>applicationList[0].Id,
            'applicationId'=>newApplication.id
        };

        System.runAs(adminUser){
            Test.startTest();
            try{
                PortalApplicationCreationHandler.createPrincipalParty(paramMap);
            }
            catch(CustomException excp){
                System.assert(excp.getMessage()!=null,'Exception works');
            }
            Test.stopTest();
        }
    }


    /**
    * @description run create dealer parties for different relationship instances where the reciprocal(clcommon__relationship__c) is different for each
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCreateDealerRelationParties(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];

        List<String> relationshipName=new List<String>{'Certified Lender Plus','Inquiry','Inquiry Plus','Field Staff Agent','Payment Administrator'};
        List<clcommon__Relationship__c> relationshipList= new List<clcommon__Relationship__c>();
        Account partyAcc=[select id from account where Name='Red Beard' limit 1];
        List<String> dealerRelationAccIdList=new List<String>();
        dealerRelationAccIdList.add((String)partyAcc.id);

        for(String relation:relationshipName){
            // clcommon__Relationship__c relationshipObj=relationshipObjList[0].clone();
            clcommon__Relationship__c relationshipObj=new clcommon__Relationship__c();
            relationshipObj.clcommon__Entity__c = partyAcc.id;
            relationshipObj.clcommon__Relationship__r=new clcommon__Reciprocal_Role__c();
            relationshipObj.clcommon__Relationship__r.Name=relation;
            relationshipList.add(relationshipObj);
        }
        List<clcommon__Party__c> partyList=new List<clcommon__Party__c>();

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.createDealerRelationParties(new Map<String,List<Object>>{
                                                                                                    'dealerRelations'=>relationshipList,
                                                                                                    'dealerRelationsAccountId'=>dealerRelationAccIdList,
                                                                                                    'party'=>partyList}
                                                                                                        ,applicationObj.id);
            System.assert(partyList.size()>0,'Create Dealer party not working');
            Test.stopTest();
        }
    }

    /**
    * @description create a party of the dealer and all its related for the application where logged in user is a cl
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testlinkDealerPartyToApplicationCL(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        User certifiedLenderUserObj =[Select id,AccountId,ContactId,Account.ParentId,Account.RecordType.Name from user where username='ross.geller@yopmail.com'];
        List<genesis__Applications__c> applicationList=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        Contact primaryApplicantContact=[Select id from Contact where LastName='Beard'];
        String shouldValidate='SaveAndContinue';
        Map<String, Object> paramForDealerPartyMap = new Map<String, Object>{
            'loggedInUser' => certifiedLenderUserObj,
            'applicationObj' => applicationList[0],
            'primaryApplicant' => primaryApplicantContact,
            'createPrimaryApplicant' => false,
            'shouldValidate' => shouldValidate
        };

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.linkDealerPartyToApplication(paramForDealerPartyMap);
            applicationList=[Select id,Certified_Lender__c from genesis__Applications__c where genesis__Loan_Amount__c=854001];
            System.assert(applicationList[0].Certified_Lender__c!=null,'Create Dealer party not working');
            Test.stopTest();
        }
    }

    /**
    * @description create a party of the dealer and all its related for the application where logged in user is a sales agent
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testlinkDealerPartyToApplicationSA(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        User salesAgentUserObj =[Select id,AccountId,ContactId,Account.ParentId,Account.RecordType.Name from user where username='tony.stark@yopmail.com'];
        List<genesis__Applications__c> applicationList=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        Contact primaryApplicantContact=[Select id from Contact where LastName='Beard'];
        String shouldValidate='SaveAndContinue';
        Map<String, Object> paramForDealerPartyMap = new Map<String, Object>{
            'loggedInUser' => salesAgentUserObj,
            'applicationObj' => applicationList[0],
            'primaryApplicant' => primaryApplicantContact,
            'createPrimaryApplicant' => false,
            'shouldValidate' => shouldValidate
        };

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.linkDealerPartyToApplication(paramForDealerPartyMap);
            applicationList=[Select id,Certified_Lender__c from genesis__Applications__c where genesis__Loan_Amount__c=854001];
            System.assert(applicationList[0].Certified_Lender__c!=null,'Create Dealer party not working');
            Test.stopTest();
        }
    }

    /**
    * @description create a party of the dealer and all its related for the application where logged in user is a sales agent admin
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testlinkDealerPartyToApplicationSaAdmin(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        User saAdminUserObj =[Select id,AccountId,ContactId,Account.ParentId,Account.RecordType.Name from user where username='tim.couper@yopmail.com'];
        //System.debug(saAdminUserObj);
        List<genesis__Applications__c> applicationList=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        Contact primaryApplicantContact=[Select id from Contact where LastName='Beard'];
        String shouldValidate='SaveAndContinue';
        Map<String, Object> paramForDealerPartyMap = new Map<String, Object>{
            'loggedInUser' => saAdminUserObj,
            'applicationObj' => applicationList[0],
            'primaryApplicant' => primaryApplicantContact,
            'createPrimaryApplicant' => false,
            'shouldValidate' => shouldValidate
        };

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.linkDealerPartyToApplication(paramForDealerPartyMap);
            applicationList=[Select id,Certified_Lender__c from genesis__Applications__c where genesis__Loan_Amount__c=854001];
            System.assert(applicationList[0].Certified_Lender__c!=null,'Create Dealer party not working');
            Test.stopTest();
        }
    }

    /**
    * @description test of a new sales agent party is created when the application has a id value in the Sales_Agent__c field but there is no party of a sales agent
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testAddSalesAgentParty(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj=[Select id,Sales_Agent__c from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.addSalesAgentParty(applicationObj);
            clcommon__party__c partyList=[SELECT Id,
                                                clcommon__Account__c 
                                                FROM clcommon__party__c
                                                WHERE genesis__Application__c =: applicationObj.Id
                                                AND clcommon__Party_Types__c ='SALES AGENT'];
            System.assert(partyList!=null,'Error in creating party of sales agent');
            Test.stopTest();
        }
    }

    /**
    * @description test of a new sales agent party is created when the application has a id value in the Sales_Agent__c field and there is a party of a sales agent
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testAddSalesAgentPartyWithSAParty(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj=[Select id,Sales_Agent__c from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];

        Account dealerAcc=[select id,genesis__Business_Information__c from account where name='Kisan Loan' limit 1];
        genesis__Business_Information__c businessInfoObj=[select id from genesis__Business_Information__c where id=: dealerAcc.genesis__Business_Information__c];

        Account salesAgentAccount=ApplicationOriginationTestHelper.createSalesAgentAccount(businessInfoObj.id, dealerAcc.id);
        Database.insert(salesAgentAccount, true);

        Contact salesAgentContact=ApplicationOriginationTestHelper.createSalesAgentContact(salesAgentAccount.id);
        Database.insert(salesAgentContact,true);

        clcommon__Party_Type__c saPartyType=[select id from clcommon__Party_Type__c where name='SALES AGENT' LIMIT 1];

        clcommon__party__c salesAgentParty=new clcommon__party__c();

        salesAgentParty.genesis__Application__c = applicationObj.Id;
        salesAgentParty.clcommon__Account__c = salesAgentAccount.id;
        salesAgentParty.clcommon__contact__c = salesAgentContact.Id;
        salesAgentParty.clcommon__Type__c = saPartyType.id;
        salesAgentParty.clcommon__Party_Types__c = 'SALES AGENT';
        Database.upsert(salesAgentParty, true);

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.addSalesAgentParty(applicationObj);
            clcommon__party__c partyList=[SELECT Id,
                                                clcommon__Account__c 
                                                FROM clcommon__party__c
                                                WHERE genesis__Application__c =: applicationObj.Id
                                                AND clcommon__Party_Types__c ='SALES AGENT'];
            System.assert(partyList!=null,'Error in creating party of sales agent');
            Test.stopTest();
        }
    }

    /**
    * @description test if an exception is hrown if the sales agent field of an application is null and there is still a party of an sa linked to an application
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testAddSalesAgentPartyWithSaNull(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj=[Select id,Sales_Agent__c from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        applicationObj.Sales_Agent__c=null;
        Database.upsert(applicationObj,true);

        Account dealerAcc=[select id,genesis__Business_Information__c from account where name='Kisan Loan' limit 1];
        genesis__Business_Information__c businessInfoObj=[select id from genesis__Business_Information__c where id=:dealerAcc.genesis__Business_Information__c];

        Account salesAgentAccount=ApplicationOriginationTestHelper.createSalesAgentAccount(businessInfoObj.id, dealerAcc.id);
        Database.insert(salesAgentAccount, true);

        Contact salesAgentContact=ApplicationOriginationTestHelper.createSalesAgentContact(salesAgentAccount.id);
        Database.insert(salesAgentContact,true);

        clcommon__Party_Type__c saPartyType=[select id from clcommon__Party_Type__c where name='SALES AGENT' LIMIT 1];

        clcommon__party__c salesAgentParty=new clcommon__party__c();

        salesAgentParty.genesis__Application__c = applicationObj.Id;
        salesAgentParty.clcommon__Account__c = salesAgentAccount.id;
        salesAgentParty.clcommon__contact__c = salesAgentContact.Id;
        salesAgentParty.clcommon__Type__c = saPartyType.id;
        salesAgentParty.clcommon__Party_Types__c = 'SALES AGENT';
        Database.upsert(salesAgentParty, true);

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.addSalesAgentParty(applicationObj);
            try{
                clcommon__party__c partyList=new clcommon__party__c();
                partyList=[SELECT Id,
                                                clcommon__Account__c 
                                                FROM clcommon__party__c
                                                WHERE genesis__Application__c =: applicationObj.Id
                                                AND clcommon__Party_Types__c ='SALES AGENT'];
            }
            catch(Exception e){
                System.assert(e!=null,'Error in creating party of sales agent');
            }
            Test.stopTest();
        }
    }

    /**
    * @description check if a sharing record has been created for the dealer
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCreateDealerSharingRecords(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Account dealerAccount=[Select id from account where name='Kisan Loan' Limit 1];
        List<clcommon__Relationship__c> allDealerRelationList = [SELECT Id,
                                    clcommon__Related_Entity__c,
                                    clcommon__Related_Entity__r.ParentId,
                                    clcommon__Relationship__r.Name
                                    FROM clcommon__Relationship__c
                                    WHERE clcommon__Entity__c = :dealerAccount.Id
                                    AND clcommon__Relationship__r.Name IN (
                                        :PortalConstants.FIELD_STAFF_AGENT,
                                        :PortalConstants.CERTIFIED_LENDER, 
                                        :PortalConstants.CERTIFIED_LENDER_PLUS,
                                        :PortalConstants.SALES_AGENT_ADMIN,
                                        :PortalConstants.SALES_AGENT, 
                                        :PortalConstants.SALES_AGENT_PLUS,
                                        :PortalConstants.INQUIRY,
                                        :PortalConstants.INQUIRY_PLUS, 
                                        :PortalConstants.PAYMENT_ADMINISTRATOR)];


        List<String> dealerRelationAccIdList = new List<String>();
        for(clcommon__Relationship__c eachRelation: allDealerRelationList){
            dealerRelationAccIdList.add(eachRelation.clcommon__Related_Entity__c);
        }

        User loggedInUser=[Select id,Account.RecordType.Name from user where UserName='tony.stark@yopmail.com'];

        genesis__Applications__c applicationObj=[select id from genesis__applications__c where genesis__Loan_Amount__c=854001];

        clcommon__Document_Category__c documentCategoryObj=ApplicationOriginationTestHelper.createAccDocumentCategory(dealerAccount.id);
        documentCategoryObj.genesis__Application__c=applicationObj.id;
        Database.insert(documentCategoryObj,true);

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.createDealerRelationSharingRecords(loggedInUser, applicationObj.id, dealerRelationAccIdList);
            List<genesis__Applications__Share> appShareList=[Select id from genesis__Applications__Share where ParentId=:applicationObj.id];
            System.assert(appShareList.size()>0,'sharing records for deler relations not created');
            Test.stopTest();
        }
    }

    /**
    * @description test if a new party has been created for the application when no contact exists in the db with the same ssn for Growmark
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCreatePrimaryApplicantPartyNoSsnGMK(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj=[select id,Dealer_Name__c from genesis__applications__c where genesis__Loan_Amount__c=854001];

        Account primaryAppAccount=ApplicationOriginationTestHelper.createAccount();
        Contact primaryAppContact=ApplicationOriginationTestHelper.createContact();

        clcommon__Legal_Entity__c solePropLegalEntity=[Select id from clcommon__Legal_Entity__c where Name = 'Individual(s) - Sole Proprietorship' limit 1];
        primaryAppAccount.clcommon__Legal_Entity_Type__c=solePropLegalEntity.id;
        primaryAppAccount.Coop_Type__c='Growmark';
        Database.upsert(primaryAppAccount,true);

        primaryAppContact.AccountId=primaryAppAccount.id;
        primaryAppContact.genesis__SSN__c='112233446';
        primaryAppContact.MobilePhone='123456789';
        primaryAppContact.HomePhone='123467890';
        primaryAppContact.Phone='0987654321';
        // Database.upsert(primaryAppContact,true);

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.createPrimaryApplicantParty(applicationObj, primaryAppContact, 'Growmark');
            clcommon__Party__c newParty=[Select id from clcommon__Party__c where clcommon__Account__r.Coop_Type__c='Growmark'];
            System.assert(newParty!=null,'sharing records for deler relations not created');
            Test.stopTest();
        }
    }

    /**
    * @description test if a new party has been created for the application when no contact exists in the db with the same ssn for cfa
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCreatePrimaryApplicantPartyNoSsnCFA(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj=[select id,Dealer_Name__c from genesis__applications__c where genesis__Loan_Amount__c=854001];

        Account primaryAppAccount=ApplicationOriginationTestHelper.createAccount();
        Contact primaryAppContact=ApplicationOriginationTestHelper.createContact();

        clcommon__Legal_Entity__c solePropLegalEntity=[Select id from clcommon__Legal_Entity__c where Name = 'Individual(s) - Sole Proprietorship' limit 1];
        primaryAppAccount.clcommon__Legal_Entity_Type__c=solePropLegalEntity.id;
        primaryAppAccount.Coop_Type__c='CFA';
        Database.upsert(primaryAppAccount,true);

        primaryAppContact.AccountId=primaryAppAccount.id;
        primaryAppContact.genesis__SSN__c='112233446';
        primaryAppContact.MobilePhone='123456789';
        primaryAppContact.HomePhone='123467890';
        primaryAppContact.Phone='0987654321';
        // Database.upsert(primaryAppContact,true);

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.createPrimaryApplicantParty(applicationObj, primaryAppContact, 'CFA');
            clcommon__Party__c newParty=[Select id from clcommon__Party__c where clcommon__Account__r.Coop_Type__c='CFA'];
            System.assert(newParty!=null,'sharing records for deler relations not created');
            Test.stopTest();
        }
    }

    /**
    * @description test if a new party has been created for the application when a contact exists in the db with the same ssn for Growmark
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCreatePrimaryApplicantPartyWithSSN(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj=[select id,Dealer_Name__c from genesis__applications__c where genesis__Loan_Amount__c=854001];

        Account primaryAppAccount=ApplicationOriginationTestHelper.createAccount();
        Contact primaryAppContact=ApplicationOriginationTestHelper.createContact();

        clcommon__Legal_Entity__c solePropLegalEntity=[Select id from clcommon__Legal_Entity__c where Name = 'Individual(s) - Sole Proprietorship' limit 1];
        primaryAppAccount.clcommon__Legal_Entity_Type__c=solePropLegalEntity.id;
        primaryAppAccount.Coop_Type__c='Growmark';
        Database.upsert(primaryAppAccount,true);

        primaryAppContact.AccountId=primaryAppAccount.id;
        primaryAppContact.genesis__SSN__c='112233446';
        primaryAppContact.MobilePhone='123456789';
        primaryAppContact.HomePhone='123467890';
        primaryAppContact.Phone='0987654321';
        Database.upsert(primaryAppContact,true);

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.createPrimaryApplicantParty(applicationObj, primaryAppContact, 'Growmark');
            clcommon__Party__c newParty=[Select id from clcommon__Party__c where clcommon__Account__r.Coop_Type__c='Growmark'];
            System.assert(newParty!=null,'sharing records for deler relations not created');
            Test.stopTest();
        }
    }

    /**
    * @description test verifyExistingAccounts when the account has Has past due as true
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testVerifyExistingAccountsHasPastDue(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        clcommon__party__c partyObj=[select id,clcommon__Account__c from clcommon__party__c WHERE genesis__Application__c =: applicationObj.id
                                                                                            AND clcommon__Type__r.Name IN (
                                                                                            :PortalConstants.PRINCIPAL_PARTY_NAME,
                                                                                            :PortalConstants.BORROWER_PARTY_NAME) limit 1];

        Account partyAcc=[select id,Has_Past_Due__c from account where id =:partyObj.clcommon__Account__c limit 1];
        partyAcc.Has_Past_Due__c=true;
        Database.upsert(partyAcc,true);

        List<Dealer_applicant_Relationship__c> dealerAppRelList=[SELECT ID, Has_Past_Due__c from Dealer_Applicant_Relationship__c where Applicant__c=:partyObj.clcommon__Account__c limit 1];
        dealerAppRelList[0].Has_Past_Due__c=true;
        Database.update(dealerAppRelList,true);

        System.runAs(certifiedLenderUserObj){
            Test.startTest();
            try{
                PortalApplicationCreationHandler.verifyExistingAccounts(applicationObj);
            }
            catch(CustomException ecp){
                System.assert(ecp.getMessage()!=null,'Verify existing acc not working');
            }
            Test.stopTest();
        }
    }

    /**
    * @description test verifyExistingAccounts when the account has non accural as true
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testVerifyExistingAccountsNonAccural(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        clcommon__party__c partyObj=[select id,clcommon__Account__c from clcommon__party__c WHERE genesis__Application__c =: applicationObj.id
                                                                                            AND clcommon__Type__r.Name IN (
                                                                                            :PortalConstants.PRINCIPAL_PARTY_NAME,
                                                                                            :PortalConstants.BORROWER_PARTY_NAME) limit 1];

        Account partyAcc=[select id,Non_Accrual__c from account where id =:partyObj.clcommon__Account__c limit 1];
        partyAcc.Non_Accrual__c=true;
        Database.upsert(partyAcc,true);

        List<Dealer_applicant_Relationship__c> dealerAppRelList=[SELECT ID, Is_Non_Accrual__c from Dealer_Applicant_Relationship__c where Applicant__c=:partyObj.clcommon__Account__c limit 1];
        dealerAppRelList[0].Is_Non_Accrual__c=true;
        Database.update(dealerAppRelList,true);

        System.runAs(certifiedLenderUserObj){
            Test.startTest();
            try{
                PortalApplicationCreationHandler.verifyExistingAccounts(applicationObj);
            }
            catch(CustomException ecp){
                System.assert(ecp.getMessage()!=null,'Verify existing acc not working');
            }
            Test.stopTest();
        }
    }

    /**
    * @description test verifyApplicants when the account has non-accural as true
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testverifyApplicantsNonAccural(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        clcommon__party__c partyObj=[select id,clcommon__Account__r.Non_Accrual__c,clcommon__Account__c from clcommon__party__c WHERE genesis__Application__c =: applicationObj.id
                                                                                            AND clcommon__Type__r.Name IN (
                                                                                            :PortalConstants.PRINCIPAL_PARTY_NAME,
                                                                                            :PortalConstants.BORROWER_PARTY_NAME) limit 1];

        Account partyAcc=[select id,Non_Accrual__c from account where id =:partyObj.clcommon__Account__c limit 1];
        partyAcc.Non_Accrual__c=true;
        Database.upsert(partyAcc,true);

        partyObj.clcommon__Account__r.Non_Accrual__c=true;
        Database.upsert(partyObj,true);

        List<Dealer_applicant_Relationship__c> dealerAppRelList=[SELECT ID, Is_Non_Accrual__c from Dealer_Applicant_Relationship__c where Applicant__c=:partyObj.clcommon__Account__c limit 1];
        dealerAppRelList[0].Is_Non_Accrual__c=true;
        Database.update(dealerAppRelList,true);

        System.runAs(certifiedLenderUserObj){
            Test.startTest();
            try{
                PortalApplicationCreationHandler.verifyApplicants(applicationObj,'SaveAndContinue');
            }
            catch(CustomException ecp){
                System.assert(ecp.getMessage()!=null,'Verify existing acc not working');
            }
            Test.stopTest();
        }
    }

    /**
    * @description test verifyApplicants when the account has Has Past due as true
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testverifyApplicantsHasPastDue(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        clcommon__party__c partyObj=[select id,clcommon__Account__c,clcommon__Account__r.Has_Past_Due__c from clcommon__party__c WHERE genesis__Application__c =: applicationObj.id
                                                                                            AND clcommon__Type__r.Name IN (
                                                                                            :PortalConstants.PRINCIPAL_PARTY_NAME,
                                                                                            :PortalConstants.BORROWER_PARTY_NAME) limit 1];

        partyObj.clcommon__Account__r.Has_Past_Due__c=true;
        Database.upsert(partyObj,true);
        Account partyAcc=[select id,Has_Past_Due__c from account where id =:partyObj.clcommon__Account__c limit 1];
        partyAcc.Has_Past_Due__c=true;
        Database.upsert(partyAcc,true);

        List<Dealer_applicant_Relationship__c> dealerAppRelList=[SELECT ID, Has_Past_Due__c from Dealer_Applicant_Relationship__c where Applicant__c=:partyObj.clcommon__Account__c limit 1];
        dealerAppRelList[0].Has_Past_Due__c=true;
        Database.update(dealerAppRelList,true);

        System.runAs(certifiedLenderUserObj){
            Test.startTest();
            try{
                PortalApplicationCreationHandler.verifyApplicants(applicationObj,'SaveAndContinue');
            }
            catch(CustomException ecp){
                System.assert(ecp.getMessage()!=null,'Verify existing acc not working');
            }
            Test.stopTest();
        }
    }

    /**
    * @description test checkForNonAccrualAndHasPastDue when the account has Has Past due as true
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCheckForNonAccrualAndHasPastDueWithPastDue(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        clcommon__party__c partyObj=[select id,clcommon__Account__c,clcommon__Account__r.Has_Past_Due__c from clcommon__party__c WHERE genesis__Application__c =: applicationObj.id
                                                                                            AND clcommon__Type__r.Name IN (
                                                                                            :PortalConstants.PRINCIPAL_PARTY_NAME,
                                                                                            :PortalConstants.BORROWER_PARTY_NAME) limit 1];

        partyObj.clcommon__Account__r.Has_Past_Due__c=true;
        Database.upsert(partyObj,true);
        

        List<Dealer_applicant_Relationship__c> dealerAppRelList=[SELECT ID, Has_Past_Due__c from Dealer_Applicant_Relationship__c where Applicant__c=:partyObj.clcommon__Account__c limit 1];
        dealerAppRelList[0].Has_Past_Due__c=true;
        Database.update(dealerAppRelList,true);

        System.runAs(certifiedLenderUserObj){
            Test.startTest();
            try{
                PortalApplicationCreationHandler.checkForNonAccrualAndHasPastDue(applicationObj);
            }
            catch(CustomException ecp){
                System.assert(ecp.getMessage()!=null,'Verify existing acc not working');
            }
            Test.stopTest();
        }
    }
    /**
    * @description test checkForNonAccrualAndHasPastDue when the account has Has Past due as true
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testverifyApplicantsHasPastDueWithAccrual(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];
        clcommon__party__c partyObj=[select id,clcommon__Account__c,clcommon__Account__r.Non_Accrual__c from clcommon__party__c WHERE genesis__Application__c =: applicationObj.id
                                                                                            AND clcommon__Type__r.Name IN (
                                                                                            :PortalConstants.PRINCIPAL_PARTY_NAME,
                                                                                            :PortalConstants.BORROWER_PARTY_NAME) limit 1];

        partyObj.clcommon__Account__r.Non_Accrual__c=true;
        Database.upsert(partyObj,true);
        

        List<Dealer_applicant_Relationship__c> dealerAppRelList=[SELECT ID, Is_Non_Accrual__c from Dealer_Applicant_Relationship__c where Applicant__c=:partyObj.clcommon__Account__c limit 1];
        dealerAppRelList[0].Is_Non_Accrual__c=true;
        Database.update(dealerAppRelList,true);

        System.runAs(certifiedLenderUserObj){
            Test.startTest();
            try{
                PortalApplicationCreationHandler.checkForNonAccrualAndHasPastDue(applicationObj);
            }
            catch(CustomException ecp){
                System.assert(ecp.getMessage()!=null,'Verify existing acc not working');
            }
            Test.stopTest();
        }
    }

    /**
    * @description this method is used to test CreatePrimaryApplicantParty function where a contact exists.
    * @author Rakesh Saraf | 01-10-2025 
    **/
    @isTest
    static void testCreatePrimaryApplicantParty(){

        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];


        List<Account> coBorrowerAccountList=[SELECT ID
                                            FROM Account
                                            WHERE Name='Red Beard'];
        List<Contact> coBorrowerContactList=[SELECT Id,
                                                    AccountId,
                                                    Account.RecordTypeId,
                                                    Account.clcommon__Legal_Entity_Type__c,
                                                    ints__Middle_Name__c,
                                                    genesis__SSN__c,
                                                    Title,
                                                    Suffix__c,
                                                    MailingStreet,
                                                    MailingCity,
                                                    MailingState,
                                                    MailingPostalCode,
                                                    Mailing_County__c,
                                                    HomePhone,
                                                    Phone,
                                                    MobilePhone,
                                                    clcommon__Marital_Status__c,
                                                    LastName,
                                                    FirstName,
                                                    Email,
                                                    Confirm_Email__c
                                            FROM Contact
                                            WHERE AccountId=: coBorrowerAccountList[0].Id ];

        coBorrowerContactList[0].genesis__SSN__c='123123123';
        Database.update(coBorrowerContactList,true);

        List<genesis__Applications__c> applicationList=[SELECT ID,
                                                               Dealer_Name__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c=854001];

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.createPrimaryApplicantParty(new Map<String,Object>{
                PortalConstants.LOGGED_IN_USER=>certifiedLenderUserObj,
                PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                PortalConstants.CONTACT_OBJ_KEY=>coBorrowerContactList[0],
                PortalConstants.DEALER_COOP_TYPE_KEY=>'CFA'
            });
            List<clcommon__Party__c> coBorrowerParty=[SELECT ID
                                                  FROM clcommon__Party__C
                                                  WHERE clcommon__Account__c=:coBorrowerAccountList[0].Id
                                                  AND genesis__Application__c=:applicationList[0].Id];

            System.assert(!coBorrowerParty.isEmpty(),'Assertion Failed');
            Test.stopTest();
            
        }
    }

    /**
    * @description this method is used to test CreatePrimaryApplicantParty function where a contact exists but a dr record does not exist.
    * @author Rakesh Saraf | 01-10-2025 
    **/
    @isTest
    static void testCreatePrimaryApplicantPartyWithoutDR(){

        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];


        List<Account> coBorrowerAccountList=[SELECT ID
                                            FROM Account
                                            WHERE Name='Red Beard'];
        List<Contact> coBorrowerContactList=[SELECT Id,
                                                    AccountId,
                                                    Account.RecordTypeId,
                                                    Account.clcommon__Legal_Entity_Type__c,
                                                    ints__Middle_Name__c,
                                                    genesis__SSN__c,
                                                    Title,
                                                    Suffix__c,
                                                    MailingStreet,
                                                    MailingCity,
                                                    MailingState,
                                                    MailingPostalCode,
                                                    Mailing_County__c,
                                                    HomePhone,
                                                    Phone,
                                                    MobilePhone,
                                                    clcommon__Marital_Status__c,
                                                    LastName,
                                                    FirstName,
                                                    Email,
                                                    Confirm_Email__c
                                            FROM Contact
                                            WHERE AccountId=: coBorrowerAccountList[0].Id ];

        coBorrowerContactList[0].genesis__SSN__c='123123123';
        Database.update(coBorrowerContactList,true);

        List<genesis__Applications__c> applicationList=[SELECT ID,
                                                               Dealer_Name__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c=854001];

        List<Dealer_Applicant_Relationship__c> dealerAppRelList=[SELECT ID FROM Dealer_applicant_Relationship__c WHERE Applicant__c=:coBorrowerAccountList[0].id ];
        Database.delete(dealerAppRelList,true);

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.createPrimaryApplicantParty(new Map<String,Object>{
                PortalConstants.LOGGED_IN_USER=>certifiedLenderUserObj,
                PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                PortalConstants.CONTACT_OBJ_KEY=>coBorrowerContactList[0],
                PortalConstants.DEALER_COOP_TYPE_KEY=>'CFA'
            });
            List<clcommon__Party__c> coBorrowerParty=[SELECT ID
                                                  FROM clcommon__Party__C
                                                  WHERE clcommon__Account__c=:coBorrowerAccountList[0].Id
                                                  AND genesis__Application__c=:applicationList[0].Id];

            System.assert(!coBorrowerParty.isEmpty(),'Assertion Failed');
            Test.stopTest();
            
        }
    }

    /**
    * @description this method is used to test CreatePrimaryApplicantParty function where a contact does not exist with the same ssn.
    * @author Rakesh Saraf | 01-10-2025 
    **/
    @isTest
    static void testCreatePrimaryApplicantPartyWithoutContact(){

        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];


        List<Account> coBorrowerAccountList=[SELECT ID
                                            FROM Account
                                            WHERE Name='Red Beard'];
        Contact coBorrowerContact= ApplicationOriginationTestHelper.createContact();

        coBorrowerContact.genesis__SSN__c='123123123';

        List<genesis__Applications__c> applicationList=[SELECT ID,
                                                               Dealer_Name__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c=854001];

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.createPrimaryApplicantParty(new Map<String,Object>{
                PortalConstants.LOGGED_IN_USER=>certifiedLenderUserObj,
                PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                PortalConstants.CONTACT_OBJ_KEY=>coBorrowerContact,
                PortalConstants.DEALER_COOP_TYPE_KEY=>'CFA'
            });
            List<clcommon__Party__c> coBorrowerParty=[SELECT ID
                                                  FROM clcommon__Party__C
                                                  WHERE clcommon__Account__c=:coBorrowerAccountList[0].Id
                                                  AND genesis__Application__c=:applicationList[0].Id];

            System.assert(!coBorrowerParty.isEmpty(),'Assertion Failed');
            Test.stopTest();
            
        }
    }

    /**
    * @description this method is used to test updatePrincipalPartyDetails.
    * @author Rakesh Saraf | 01-10-2025 
    **/
    @isTest
    static void testUpdatePrincipalPartyDetails(){

        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<genesis__Applications__c> applicationList=[SELECT ID,
                                                               Dealer_Name__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c=854001];

        List<Contact> coBorrowerContactList=[SELECT Id,
                                                    MailingStreet
                                            FROM Contact
                                            WHERE LastName='Beard'];

        coBorrowerContactList[0].MailingStreet='Action Area';
        Database.update(coBorrowerContactList,true);

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.updatePrincipalPartyDetails(applicationList[0],new List<User>{certifiedLenderUserObj});
            List<clcommon__Party__c> coBorrowerParty=[SELECT ID,Street__c
                                                  FROM clcommon__Party__C
                                                  WHERE clcommon__Contact__c=:coBorrowerContactList[0].id
                                                  AND genesis__Application__c=:applicationList[0].Id];

            System.assertEquals(coBorrowerParty[0].Street__c,'Action Area','Assertion Failed');
            Test.stopTest();
            
        }
    }

    /**
    * @description this method is used to test updatePrincipalPartyDetails.
    * @author Rakesh Saraf | 01-10-2025 
    **/
    @isTest
    static void testUpdatePrincipalPartyDetailsWithNewPrincipal(){

        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<genesis__Applications__c> applicationList=[SELECT ID,
                                                               Dealer_Name__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c=854001];

        List<genesis__Business_Information__c> businessInfoList=[SELECT Id FROM genesis__Business_Information__c];
        Account principalAcc=ApplicationOriginationTestHelper.createAccount();
        principalAcc.genesis__Business_Information__c=businessInfoList[0].id;
        Database.insert(principalAcc,true);

        Contact principalContact=ApplicationOriginationTestHelper.createContact();
        principalContact.AccountId=principalAcc.id;
        principalContact.MailingState='WB';
        Database.insert(principalContact,true);

        List<clcommon__Party_Type__c> principalPartyType=[SELECT ID FROM clcommon__Party_Type__c WHERE Name='PRINCIPAL'];

        //Creating a party for principal
        clcommon__Party__c principalParty=ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                                'accountId'=>principalAcc.Id,
                                                                                                'contactId'=>principalContact.Id,
                                                                                                'partyTypeId'=>principalPartyType[0].Id,
                                                                                                'applicationId'=>applicationList[0].Id
                                                                                                });

        Database.insert(principalParty,true);

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.updatePrincipalPartyDetails(applicationList[0],new List<User>{certifiedLenderUserObj});
            List<clcommon__Party__c> coBorrowerParty=[SELECT ID, State__c
                                                  FROM clcommon__Party__c
                                                  WHERE clcommon__Contact__c=:principalContact.id
                                                  AND genesis__Application__c=:applicationList[0].Id];

            System.assertEquals(coBorrowerParty[0].State__c,'WB','Assertion Failed');
            Test.stopTest();
            
        }
    }
    
    /**
    * @description this method is used to test getCoApplicantsList.
    * @author Rakesh Saraf | 01-10-2025 
    **/
    @isTest
    static void testGetCoApplicantsList(){

        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];


        System.runAs(adminUser){
            Test.startTest();
            List<Map<String, Object>> coApplicantList=PortalApplicationCreationHandler.getCoApplicantsList(new List<Object>{coApplicantInfo});

            System.assert(!coApplicantList.isEmpty(),'Assertion Failed');
            Test.stopTest();
            
        }
    }

    /**
    * @description this method is used to test updateAccountDetails.
    * @author Rakesh Saraf | 01-10-2025 
    **/
    @isTest
    static void testUpdateAccountDetails(){

        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<genesis__Applications__c> applicationList=[SELECT ID,
                                                               Dealer_Name__c,
                                                               genesis__Contact__c,
                                                               genesis__Account__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c=854001];

        List<Contact> contactList=[SELECT ID,
                                          LastName,
                                          FirstName,
                                          ints__Middle_Name__c,
                                          genesis__SSN__c
                                    FROM Contact
                                    WHERE ID=:applicationList[0].genesis__Contact__c];

        List<Account> accountList=[SELECT ID,
                                          Name,
                                          genesis__Business_Information__c
                                    FROM Account
                                    WHERE ID=:applicationList[0].genesis__Account__c];

        List<genesis__Business_Information__c> businessInfoList=[Select id,
                                                                        gross_farm_income__c 
                                                                from genesis__Business_Information__c
                                                                where id=:accountList[0].genesis__Business_Information__c];

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID FROM clcommon__Party__c WHERE clcommon__Account__c=:accountList[0].id];

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.updateAccountDetails(new Map<String,Object>{PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                        PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                        PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                        PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoList[0],
                                                                                        PortalConstants.ENTITY_KEY=>'Individual(s) - Sole Proprietorship'},
                                                                                            borrowerPartyList,
                                                                                            new List<Map<String,Object>>{coApplicantInfo});

            List<Account> updatedAccountList=[SELECT ID,NAME FROM Account WHERE id=:accountList[0].id];
            System.assert(updatedAccountList[0].Name!=null,'Assertion Failed');
            Test.stopTest();
            
        }
    }

    /**
    * @description this method is used to test updateAccountDetails.
    * @author Rakesh Saraf | 01-10-2025 
    **/
    @isTest
    static void testUpdateAccountDetailsMissingFirstName(){

        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<genesis__Applications__c> applicationList=[SELECT ID,
                                                               Dealer_Name__c,
                                                               genesis__Contact__c,
                                                               genesis__Account__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c=854001];

        List<Contact> contactList=[SELECT ID,
                                          LastName,
                                          FirstName,
                                          genesis__SSN__c
                                    FROM Contact
                                    WHERE ID=:applicationList[0].genesis__Contact__c];
        contactList[0].FirstName=null;
        Database.update(contactList,true);

        List<Account> accountList=[SELECT ID,
                                          Name
                                    FROM Account
                                    WHERE ID=:applicationList[0].genesis__Account__c];

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID FROM clcommon__Party__c WHERE clcommon__Account__c=:accountList[0].id];

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.updateAccountDetails(new Map<String,Object>{PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                        PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                        PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0],
                                                                                        PortalConstants.ENTITY_KEY=>'Individual(s) - Sole Proprietorship'},
                                                                                            borrowerPartyList,
                                                                                            new List<Map<String,Object>>{coApplicantInfo});

            List<Account> updatedAccountList=[SELECT ID,NAME FROM Account WHERE id=:accountList[0].id];
            System.assert(updatedAccountList[0].Name!=null,'Assertion Failed');            
            Test.stopTest();
            
        }
    }
    /**
    * @description this method is used to test updateContactAndBusinessInfoDetails.
    * @author Rakesh Saraf | 01-10-2025 
    **/
    @isTest
    static void updateContactAndBusinessInfoDetails(){

        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<genesis__Applications__c> applicationList=[SELECT ID,
                                                               Dealer_Name__c,
                                                               genesis__Contact__c,
                                                               genesis__Account__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c=854001];

        List<Contact> contactList=[SELECT ID
                                    FROM Contact
                                    WHERE ID=:applicationList[0].genesis__Contact__c];

        List<Account> accountList=[SELECT ID,
                                          genesis__Business_Information__c
                                    FROM Account
                                    WHERE ID=:applicationList[0].genesis__Account__c];

        List<clcommon__Party__c> borrowerPartyList=[SELECT ID FROM clcommon__Party__c WHERE clcommon__Account__c=:accountList[0].id];

        List<genesis__Business_Information__c> businessIno=[SELECT ID,
                                                                    genesis__Total_Assets__c,
                                                                    genesis__Total_Liabilities__c 
                                                            FROM genesis__Business_Information__c 
                                                            WHERE ID=:accountList[0].genesis__Business_Information__c];

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.updateContactAndBusinessInfoDetails(new Map<String,Object>{
                                                                                        PortalConstants.CONTACT_OBJ_KEY=>contactList[0],
                                                                                        PortalConstants.ACCOUNT_OBJ_KEY=>accountList[0],
                                                                                        PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessIno[0],
                                                                                        PortalConstants.APPLICATION_OBJ_KEY=>applicationList[0]},
                                                                                            borrowerPartyList);

            List<Contact> updatedContactList=[SELECT ID FROM Contact WHERE AccountId=:accountList[0].id];
            System.assert(!updatedContactList.isEmpty(),'Assertion Failed');
            Test.stopTest();
            
        }
    }
}