/**
 * @description       : This is a test class for PortalApplicationCreationHandler for all the Applicants(borrower and co-Applicant)
 * @author            : Rakesh Saraf
 * @group             : 
 * @last modified on  : 03-13-2025
 * @last modified by  : Rakesh Saraf
**/
@isTest
global without sharing class PortalAppApplicantCreationHandlerTest {

    //Global Variable
    public static Map<String,Object> coApplicantInfo = new Map<String,Object>{
                                                                            'Street__c'=> 'East 14th Street',
                                                                            'clcommon__Contact__r.Masked_Confirm_SSN__c'=> 'XXX-XX-7817',
                                                                            'clcommon__Contact__r.Masked_SSN__c'=> 'XXX-XX-7817',
                                                                            'Postal_Code__c'=> '12131',
                                                                            'Total_Assets__c'=> 100000,
                                                                            'clcommon__Contact__r.Birthdate'=> '2000-05-19',
                                                                            'Marital_Status__c'=> 'Unmarried',
                                                                            'clcommon__Contact__r.LastName'=> 'Raj',
                                                                            'Title__c'=> 'Co-Applicant',
                                                                            'Work_Number__c'=> '3535323131',
                                                                            'Gross_Farm_Income__c'=> 100000,
                                                                            'clcommon__Contact__r.Confirm_Email__c'=> 'amy.12@yopmail.com',
                                                                            'Is_SSN_Entered__c'=> true,
                                                                            'State__c'=> 'NY',
                                                                            'clcommon__Account__r.Year_Began_Farming__c'=> '2014',
                                                                            'Total_Liabilities__c'=> 1,
                                                                            'clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c'=> 99999,
                                                                            'clcommon__Contact__r.FirstName'=> 'Shivam',
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
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        borrowerBusinessInfoObj.genesis__Business_Country__c='USA';
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj,borrowerBusinessInfoObj}, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);

        // Creating Account for Borrower
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();

        //create an account
        Account testAccount=ApplicationOriginationTestHelper.createAccount();
        testAccount.genesis__Business_Information__c=borrowerBusinessInfoObj.Id;
        Database.insert(new List<Account>{clAccountObj,borrowerAccountObj,testAccount}, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);

        // Creating Contact for Borrower
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);

        //create a contact
        Contact  testContact=ApplicationOriginationTestHelper.createContact();
        testContact.AccountId=testAccount.id;
        Database.insert(new List<Contact>{clContactObj,borrowerContactObj,testContact},true);

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
        
        //creating map for party for a borrower
        Map<String,Id> borrowerParamMap=new Map<String,Id>{
            'accountId'=>borrowerAccountObj.Id,
            'contactId'=>borrowerContactObj.Id,
            'partyTypeId'=>borrowerPartyType.Id,
            'applicationId'=>applicationObj.Id
            };

        //Creating a party of borrower
        clcommon__Party__c testborrower=ApplicationOriginationTestHelper.createParty(borrowerParamMap);
        testborrower=ApplicationOriginationTestHelper.insertIndividualPartyDetails(testborrower,dealerApplicantRelObj.id);


        //creating map for creating a party
        Map<String,Id> paramMap=new Map<String,Id>{
                                                'accountId'=>testAccount.Id,
                                                'contactId'=>testContact.Id,
                                                'partyTypeId'=>principalPartyType.Id,
                                                'applicationId'=>applicationObj.Id
                                                };

        //Creating a party for principal
        clcommon__Party__c testParty=ApplicationOriginationTestHelper.createParty(paramMap);

        Dealer_Applicant_Relationship__c dealerPrincipalRelObj =ApplicationOriginationTestHelper.createDealerApplicantRelationship(testContact,dealerAccountObj.id);
        Database.insert(dealerPrincipalRelObj,true);

        testParty=ApplicationOriginationTestHelper.insertIndividualPartyDetails(testParty,dealerPrincipalRelObj.id);

        //creating a credit Rating Matrix
        List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList=ApplicationOriginationTestHelper.createCreditRatingMatrix();
        Database.insert(creditRatingMatrixList,true);

        

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
        Database.insert(new List<clcommon__Party__c>{testborrower,testParty,corpParty},true);

        makeSalesAgent();

    }

    /**
    * @description this is to set up the sales agent and other stuff
    * @author Rakesh Saraf | 09-19-2024 
    **/
    static void makeSalesAgent(){
        Account dealerAccountObj=[Select id from account where name='Kisan Loan' limit 1];
        genesis__Business_Information__c dealerBusinessInfoObj=[Select id from genesis__Business_Information__c where genesis__Business_Country__c='India' limit 1];

        //creating Sales agent account
        Account saAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(saAccountObj, true);

        // Creating Contact for Sales agent
        Contact saContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(saAccountObj.Id);
        Database.insert(saContactObj,true);

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

        //creating sa admin contact
        Contact saAdminContactObj=ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccObj.Id);
        Database.insert(saAdminContactObj, true);

        //creating sa admin user
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

        genesis__Applications__c applicationObj=[Select id,Sales_Agent__c from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        //putting the id of the sales agent account in the application sales agent field
        applicationObj.Sales_Agent__c=saAccountObj.id;
        Database.upsert(applicationObj,true);

        //creating a new cfa configuration for growmark and cfa cif numbers
        CFA_Configuration__c latestCif=ApplicationOriginationTestHelper.createCIFNumber();
        Database.insert(latestCif,true);

    }

    /**
    * @description test of the co-applicant contact details are being populated from the map
    * @author Rakesh Saraf | 09-18-2024 
    **/
    @isTest
    static void testPopulateCoApplicantContact(){

        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        System.runAs(certifiedLenderUserObj){
            Test.startTest();
            Contact coApplicantContact=PortalApplicationCreationHandler.populateCoApplicantContact(coApplicantInfo);
            //contact check
            System.assertEquals((String) coApplicantInfo.get('clcommon__Contact__r.LastName'),coApplicantContact.LastName,'Error in Last Name');
            System.assertEquals((String) coApplicantInfo.get('clcommon__Contact__r.FirstName'),coApplicantContact.FirstName,'Error in First Name');
            System.assertEquals(null,coApplicantContact.Id,'Id should be null');
            Test.stopTest();
        }
    }


    /**
    * @description test for save coApplicant where id for the coApplicant is null
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testSaveCoApplicantNullId(){

        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<Map<String,Object>> coApplicants=new List<Map<String,Object>>();
        List<Account> accountList=[Select id from Account WHERE Name='Red Beard'];
        coApplicantInfo.put('clcommon__Account__r.Id',accountList[0].Id);
        coApplicants.add(coApplicantInfo);
        List<genesis__Applications__c> applicationList=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        System.runAs(adminUser) {
            test.startTest();
            PortalApplicationCreationHandler.saveCoApplicant(coApplicants,applicationList[0].Id,'SaveAndContinue');
            List<Contact> insertedContact=[Select id,FirstName,LastName from Contact where FirstName='Shivam' and LastName='Raj'];
            System.assertEquals((String)coApplicantInfo.get('clcommon__Contact__r.FirstName'),insertedContact[0].FirstName,'Success');
            System.assertEquals(1,insertedContact.size(),'Success');
            System.assertEquals(1,applicationList.size(),'More than 1 Application Found');
            test.stopTest();
        }
        
    }

    /**
    * @description test for save coApplicant where id for the coApplicant is not null
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testSaveCoApplicantWithId(){

        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<clcommon__party__c> partyList=[Select id from clcommon__Party__c WHERE clcommon__Party_Types__c = 'PRINCIPAL'];
        List<Account> accountList=[Select id from Account WHERE Name='Red Beard'];
        List<Contact> contactList=[Select id from Contact WHERE LastName = 'Beard'];
        List<genesis__Business_Information__c> businessInfoList=[Select id from genesis__Business_Information__c where genesis__Business_Country__c='India'];


        coApplicantInfo.put('Id',partyList[0].Id);
        coApplicantInfo.put('clcommon__Contact__r.Id',contactList[0].Id);
        coApplicantInfo.put('clcommon__Account__r.Id',accountList[0].Id);
        coApplicantInfo.put('clcommon__Account__r.genesis__Business_Information__r.Id',businessInfoList[0].Id);
        List<Map<String,Object>> coApplicants=new List<Map<String,Object>>();
        coApplicants.add(coApplicantInfo);
        List<genesis__Applications__c> applicationList=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        System.runAs(adminUser) {
            test.startTest();
            PortalApplicationCreationHandler.saveCoApplicant(coApplicants,applicationList[0].Id,'SaveAndContinue');
            List<Contact> insertedContact=[Select id,FirstName,LastName from Contact where FirstName='Shivam' and LastName='Raj'];
            System.assertEquals((String)coApplicantInfo.get('clcommon__Contact__r.FirstName'),insertedContact[0].FirstName,'Success');
            System.assertEquals(1,insertedContact.size(),'Success');
            System.assertEquals(1,applicationList.size(),'More than 1 Application Found');
            test.stopTest();
        }
        
    }

    /**
    * @description test check evergreen for borrower function where the response from portal has the first name and last name
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCheckEvergreenForBorrowerWithContactName(){

        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj=[Select id,Internal_Reference_Code__c,Growmark_Unique_Identifier__c from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];


        List<clcommon__Party__c> partyList =[SELECT Id,
                                                    clcommon__Contact__c,
                                                    clcommon__Account__c,
                                                    clcommon__Contact__r.FirstName,
                                                    clcommon__Contact__r.LastName,
                                                    clcommon__Account__r.Name,
                                                    clcommon__Contact__r.genesis__SSN__c,
                                                    clcommon__Contact__r.Email,
                                                    clcommon__Account__r.clcommon__Email__c,
                                                    clcommon__Contact__r.Phone,
                                                    clcommon__Contact__r.MobilePhone,
                                                    clcommon__Contact__r.HomePhone,
                                                    clcommon__Account__r.Phone,
                                                    clcommon__Account__r.Home_Number__c,
                                                    clcommon__Account__r.Work_Number__c,
                                                    clcommon__Account__r.genesis__Business_Information__c,
                                                    clcommon__Account__r.genesis__Business_Information__r.genesis__Tax_Identification_Number__c,
                                                    clcommon__Account__r.genesis__Business_Information__r.genesis__State_of_Incorporation__c,
                                                    clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                    clcommon__Party_Types__c
                                            FROM clcommon__Party__c
                                            WHERE clcommon__Party_Types__c IN ('BORROWER','PRINCIPAL') AND 
                                            clcommon__Account__c != null AND 
                                            clcommon__Contact__c != null AND
                                            genesis__Application__c = :applicationObj.id];

        Account accountObj=[select id from account where id =:partyList[0].clcommon__Account__c limit 1];
        Contact contactObj=[select id from contact where id =:partyList[0].clcommon__Contact__c limit 1];
        genesis__Business_Information__c businessInfo=[Select id from genesis__Business_Information__c where genesis__Business_Country__c='India'];

    
                
        Map<String, Object> paramForEvergreenCheckMap = new Map<String, Object>{
                'accountObj' => accountObj,
                'contactObj' => contactObj,
                'applicationObj' => applicationObj,
                'businessInfoObj' => businessInfo
            };
        
        List<clcommon__Party__c> coApplicantParty=[Select id from clcommon__Party__c where clcommon__Party_Types__c='PRINCIPAL'];
        Map<String,Object> responseFromPortal=new Map<String,Object>{'coApplicant'=>'[{\"id\":\"a2mVD000000gr6LYAQ\",\"clcommon__Contact__r.Masked_Confirm_SSN__c\":\"XXX-XX-6556\",\"clcommon__Contact__r.Masked_SSN__c\":\"XXX-XX-6556\",\"clcommon__Contact__r.Id\":\"003VD00000GaGL9YAN\",\"clcommon__Contact__r.MobilePhone\":\"1234567834\",\"Total_Assets__c\":10000,\"clcommon__Contact__r.Birthdate\":\"1998-08-13\",\"clcommon__Contact__r.MailingStreet\":\"1234 Long Pond Road\",\"clcommon__Contact__r.LastName\":\"applicant\",\"clcommon__Contact__r.Suffix__c\":\"Sr.\",\"clcommon__Contact__r.clcommon__Marital_Status__c\":\"Unmarried\",\"clcommon__Contact__r.Confirm_Email__c\":\"kvicha@yopmail.com\",\"clcommon__Contact__r.MailingCity\":\"Long Pond\",\"clcommon__Contact__r.MailingState\":\"PA\",\"clcommon__Contact__r.Title\":\"Co-Applicant\",\"clcommon__Account__r.Id\":\"001VD000009wHEiYAM\",\"Is_SSN_Entered__c\":true,\"clcommon__Account__r.Year_Began_Farming__c\":\"2013\",\"Total_Liabilities__c\":1,\"clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c\":9999,\"clcommon__Contact__r.FirstName\":\"Jake\",\"clcommon__Contact__r.Email\":\"kvicha@yopmail.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"665566556\",\"clcommon__Account__r.genesis__Business_Information__r.Id\":\"a7AVD0000006NbR2AU\",\"clcommon__Contact__r.ints__Middle_Name__c\":\"co\",\"clcommon__Contact__r.MailingPostalCode\":\"18334\",\"Id\":\"'+coApplicantParty[0].id+'\",\"clcommon__Contact__r.Confirm_SSN__c\":\"665566556\",\"clcommon__Contact__r.Mailing_County__c\":\"Monroe County\"}]'};

        String responseFromPortalString=String.valueOf(responseFromPortal.get('coApplicant'));

        List<Object> coApplicantList = (List<Object>) Json.deserializeUntyped(responseFromPortalString);
        List<Map<String,Object>> coApplicants=new List<Map<String,Object>>();
        coApplicants.add((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(coApplicantList[0])));

        Map<String,Map<String,Object>> coApplicantMap = new Map<String,Map<String,Object>>();
        coApplicantMap.put((String)coApplicants[0].get('Id'),coApplicants[0]);

        Map<String, Object> fieldsMap = new Map<String, Object>();
        fieldsMap.put('IsNotEvergreen',false);       
        fieldsMap.put('borrowerEntityType','Individual(s) - Sole Proprietorship');

        coApplicantMap.put('fieldsMap',fieldsMap);

        System.runAs(certifiedLenderUserObj){
            Test.startTest();
            fieldsMap=PortalApplicationCreationHandler.checkEvergreenForBorrower(partyList,paramForEvergreenCheckMap,coApplicantMap);
            System.assertEquals(applicationObj,fieldsMap.get('applicationObj'),'error');
            Test.stopTest();
        }

    }

    /**
    * @description test for getting the coop type of dealer which is growmark
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testGetCoopTypeOfDealer(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Account dealerAcc=[select id,Coop_Type__c from account where name='Kisan Loan' limit 1];
        dealerAcc.Coop_Type__c='Growmark';
        Database.upsert(dealerAcc,true);
        System.runAs(adminUser){
            Test.startTest();
            String coopType=PortalApplicationCreationHandler.getCoopTypeOfDealer(dealerAcc.id);
            System.assertEquals('Growmark', coopType,'Dealer coop type error');
            Test.stopTest();
        }
        
    }

    /**
    * @description test check evergreen for borrower function where the response from portal does not have the first name and last name
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCheckEvergreenForBorrowerWithoutContactName(){

        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj=[Select id,Internal_Reference_Code__c,Growmark_Unique_Identifier__c from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];


        List<clcommon__Party__c> partyList = [SELECT Id,
                                clcommon__Contact__c,
                                clcommon__Account__c,
                                clcommon__Contact__r.FirstName,
                                clcommon__Contact__r.LastName,
                                clcommon__Account__r.Name,
                                clcommon__Contact__r.genesis__SSN__c,
                                clcommon__Contact__r.Email,
                                clcommon__Account__r.clcommon__Email__c,
                                clcommon__Contact__r.Phone,
                                clcommon__Contact__r.MobilePhone,
                                clcommon__Contact__r.HomePhone,
                                clcommon__Account__r.Phone,
                                clcommon__Account__r.Home_Number__c,
                                clcommon__Account__r.Work_Number__c,
                                clcommon__Account__r.genesis__Business_Information__c,
                                clcommon__Account__r.genesis__Business_Information__r.genesis__Tax_Identification_Number__c,
                                clcommon__Account__r.genesis__Business_Information__r.genesis__State_of_Incorporation__c,
                                clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                clcommon__Party_Types__c
                        FROM clcommon__Party__c
                        WHERE clcommon__Party_Types__c IN ('BORROWER','PRINCIPAL') AND 
                        clcommon__Account__c != null AND 
                        clcommon__Contact__c != null AND
                        genesis__Application__c = :applicationObj.id];

        Account accountObj=[select id from account where id =:partyList[0].clcommon__Account__c limit 1];
        Contact contactObj=[select id from contact where id =:partyList[0].clcommon__Contact__c limit 1];
        genesis__Business_Information__c businessInfo=[Select id from genesis__Business_Information__c where genesis__Business_Country__c='India'];

    
                
        Map<String, Object> paramForEvergreenCheckMap = new Map<String, Object>{
                'accountObj' => accountObj,
                'contactObj' => contactObj,
                'applicationObj' => applicationObj,
                'businessInfoObj' => businessInfo
            };
        
        List<clcommon__Party__c> coApplicantParty=[Select id from clcommon__Party__c where clcommon__Party_Types__c='PRINCIPAL'];
        Map<String,Object> responseFromPortal=new Map<String,Object>{'coApplicant'=>'[{\"id\":\"a2mVD000000gr6LYAQ\",\"clcommon__Contact__r.Masked_Confirm_SSN__c\":\"XXX-XX-6556\",\"clcommon__Contact__r.Masked_SSN__c\":\"XXX-XX-6556\",\"clcommon__Contact__r.Id\":\"003VD00000GaGL9YAN\",\"clcommon__Contact__r.MobilePhone\":\"1234567834\",\"Total_Assets__c\":10000,\"clcommon__Contact__r.Birthdate\":\"1998-08-13\",\"clcommon__Contact__r.MailingStreet\":\"1234 Long Pond Road\",\"clcommon__Contact__r.Suffix__c\":\"Sr.\",\"clcommon__Contact__r.clcommon__Marital_Status__c\":\"Unmarried\",\"clcommon__Contact__r.Confirm_Email__c\":\"kvicha@yopmail.com\",\"clcommon__Contact__r.MailingCity\":\"Long Pond\",\"clcommon__Contact__r.MailingState\":\"PA\",\"clcommon__Contact__r.Title\":\"Co-Applicant\",\"clcommon__Account__r.Id\":\"001VD000009wHEiYAM\",\"Is_SSN_Entered__c\":true,\"clcommon__Account__r.Year_Began_Farming__c\":\"2013\",\"Total_Liabilities__c\":1,\"clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c\":9999,\"clcommon__Contact__r.Email\":\"kvicha@yopmail.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"665566556\",\"clcommon__Account__r.genesis__Business_Information__r.Id\":\"a7AVD0000006NbR2AU\",\"clcommon__Contact__r.ints__Middle_Name__c\":\"co\",\"clcommon__Contact__r.MailingPostalCode\":\"18334\",\"Id\":\"'+coApplicantParty[0].id+'\",\"clcommon__Contact__r.Confirm_SSN__c\":\"665566556\",\"clcommon__Contact__r.Mailing_County__c\":\"Monroe County\"}]'};

        String responseFromPortalString=String.valueOf(responseFromPortal.get('coApplicant'));

        List<Object> coApplicantList = (List<Object>) Json.deserializeUntyped(responseFromPortalString);
        List<Map<String,Object>> coApplicants=new List<Map<String,Object>>();
        coApplicants.add((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(coApplicantList[0])));

        Map<String,Map<String,Object>> coApplicantMap = new Map<String,Map<String,Object>>();
        coApplicantMap.put((String)coApplicants[0].get('Id'),coApplicants[0]);

        Map<String, Object> fieldsMap = new Map<String, Object>();
        fieldsMap.put('IsNotEvergreen',false);       
        fieldsMap.put('borrowerEntityType','Individual(s) - Sole Proprietorship');

        coApplicantMap.put('fieldsMap',fieldsMap);

        System.runAs(certifiedLenderUserObj){
            Test.startTest();
            fieldsMap=PortalApplicationCreationHandler.checkEvergreenForBorrower(partyList,paramForEvergreenCheckMap,coApplicantMap);
            System.assertEquals(applicationObj,fieldsMap.get('applicationObj'),'error');
            Test.stopTest();
        }

    }

    /**
    * @description test assiging of cif number for a new applicant where coop type is growmark
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testAssignCifForNewApplicantGrowmark(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<User> loggedInUser =[Select id,AccountId,ContactId,Account.ParentId from user where username='ross.geller@yopmail.com'];

        Account newAccount=ApplicationOriginationTestHelper.createAccount();
        List<Account> accountList=[Select id,Coop_Type__c,CIF_Number__c,ParentId from account where name='Red Beard'];
        System.runAs(adminUser){
            Test.startTest();
            Account updatedAccount=PortalApplicationCreationHandler.assignCifForNewApplicant(newAccount,'Growmark',loggedInUser);
            Account updatedExistingAccount=PortalApplicationCreationHandler.assignCifForNewApplicant(accountList[0],'Growmark',loggedInUser);
            System.assertEquals('Growmark',updatedAccount.Coop_Type__c,'Wrong CoopType');
            System.assertEquals('1000501',updatedAccount.CIF_Number__c,'Wrong CIF number');

            System.assertEquals('Growmark',updatedExistingAccount.Coop_Type__c,'Wrong CoopType');
            System.assertEquals('1000502',updatedExistingAccount.CIF_Number__c,'Wrong CIF number');
            Test.stopTest();
        }
    }

    /**
    * @description test assiging of cif number for a new applicant where coop type is cfa
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testAssignCifForNewApplicantCFA(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<User> loggedInUser =[Select id,AccountId,ContactId,Account.ParentId from user where username='ross.geller@yopmail.com'];

        Account newAccount=ApplicationOriginationTestHelper.createAccount();
        List<Account> accountList=[Select id,Coop_Type__c,CIF_Number__c,ParentId from account where name='Red Beard'];
        System.runAs(adminUser){
            Test.startTest();
            Account updatedAccount=PortalApplicationCreationHandler.assignCifForNewApplicant(newAccount,'CFA',loggedInUser);
            Account updatedExistingAccount=PortalApplicationCreationHandler.assignCifForNewApplicant(accountList[0],'CFA',loggedInUser);
            System.assertEquals('CFA',updatedAccount.Coop_Type__c,'Wrong CoopType');
            System.assertEquals('32454345',updatedAccount.CIF_Number__c,'Wrong CIF number');

            System.assertEquals('CFA',updatedExistingAccount.Coop_Type__c,'Wrong CoopType');
            System.assertEquals('32454346',updatedExistingAccount.CIF_Number__c,'Wrong CIF number');
            Test.stopTest();
        }
    }

    /**
    * @description test if the account and the contact have been populated or not from the map provided
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testProcessForNewApplicantOfIndividualType(){

        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Map<String,String> numbersMap=new Map<String,String>{
            'HomePhone'=>'1234567890',
            'Phone'=>'1234567890',
            'MobilePhone'=>'098764321'
        };
        Account newAccount=ApplicationOriginationTestHelper.createAccount();
        Contact newContact=ApplicationOriginationTestHelper.createContact();
        Database.insert(newAccount,true);
        newContact.AccountId=newAccount.Id;
        Map<String, Object> paramForIndividual = new Map<String, Object>{
            'accountObj'=>newAccount,
            'contactObj'=>newContact
        };
        Map<String,String> nameMap=new Map<String,String>{
            'firstName'=>'Captain',
            'lastName'=>'Barbossa'
        };
        Map<String, String> ssnEmailTinMap = new Map<String, String>{
            'genesis__Tax_Identification_Number__c' => '123456789',
            'Confirm_Tax_Identification_Number__c' => '123456789',
            'genesis__SSN__c' => '112233445',
            'Confirm_SSN__c' => '112233445',
            'email' => 'redbeard@yopmail.com',
            'Confirm_Email__c' => 'redbeard@yopmail.com'
        }; 
        Map<String, Map<String, Object>> paramMap=new Map<String,Map<String,Object>>{
            'numbersMap'=>numbersMap,
            'accConObj'=>paramForIndividual,
            'nameMap'=>nameMap,
            'ssnEmailTinMap'=>ssnEmailTinMap
        };

        List<Account> dealerList=[Select id from account where name='Kisan Loan'];

        System.runAs(adminUser){
            Test.startTest();
            Map<String, Object> returnedMap=PortalApplicationCreationHandler.processForNewApplicantOfIndividualType(paramMap,'CFA',(String)dealerList[0].id);
            System.assert(returnedMap.get('accountObj')!=null,'Process for inividual type failed');
            Test.stopTest();
        }
    }

    /**
    * @description  test if the account and the contact have been populated or not from the map provided
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testProcessForNewApplicantOfDBAType(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Account newAccount=ApplicationOriginationTestHelper.createAccount();
        Contact newContact=ApplicationOriginationTestHelper.createContact();
        Database.insert(newAccount,true);
        newContact.AccountId=newAccount.Id;
        Map<String, Object> paramForIndividual = new Map<String, Object>{
            'accountObj'=>newAccount,
            'contactObj'=>newContact
        };
        Map<String, String> ssnEmailTinMap = new Map<String, String>{
            'genesis__Tax_Identification_Number__c' => '123456789',
            'Confirm_Tax_Identification_Number__c' => '123456789',
            'genesis__SSN__c' => '112233445',
            'Confirm_SSN__c' => '112233445',
            'email' => 'redbeard@yopmail.com',
            'Confirm_Email__c' => 'redbeard@yopmail.com'
        };

        System.runAs(adminUser){
            Test.startTest();
            Map<String, Object> returnedMap=PortalApplicationCreationHandler.processForNewApplicantOfDBAType(paramForIndividual,ssnEmailTinMap,'One8');
            System.assert(returnedMap.get('accountObj')!=null,'Process for dba type failed');
            Test.stopTest();
        }
    }

    /**
    * @description  test if the account and the contact have been populated or not from the map provided
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testProcessForNewApplicantOfCompanyType(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<Account> dealerAcc=[select id,Coop_Type__c from account where name='Kisan Loan' limit 1];

        genesis__Business_Information__c businessInfoObj=ApplicationOriginationTestHelper.createBusinessInfoForPrincipal();
        businessInfoObj.genesis__Tax_Identification_Number__c='123456789';
        businessInfoObj.Confirm_Tax_Identification_Number__c='123456789';
        Database.insert(businessInfoObj);

        Account accountObj=ApplicationOriginationTestHelper.createAccount();
        accountObj.genesis__Business_Information__c=businessInfoObj.id;
        accountObj.ParentId=dealerAcc[0].id;
        Database.insert(accountObj,true);

        Contact contactObj=ApplicationOriginationTestHelper.createContact();
        contactObj.AccountId=accountObj.id;
        Database.insert(contactObj,true);

        Account newAccount=ApplicationOriginationTestHelper.createAccount();
        Contact newContact=ApplicationOriginationTestHelper.createContact();
        genesis__Business_Information__c newBusinessInfo=ApplicationOriginationTestHelper.createBusinessInfoForPrincipal();
        Database.insert(newAccount,true);
        newContact.AccountId=newAccount.Id;
        Map<String, Object> paramMap = new Map<String, Object>{
            'accountObj'=>newAccount,
            'contactObj'=>newContact,
            'businessInfoObj'=>newBusinessInfo
        };
        Map<String, String> ssnEmailTinMap = new Map<String, String>{
            'genesis__Tax_Identification_Number__c' => '123456789',
            'Confirm_Tax_Identification_Number__c' => '123456789',
            'genesis__SSN__c' => '112233445',
            'Confirm_SSN__c' => '112233445',
            'email' => 'redbeard@yopmail.com',
            'Confirm_Email__c' => 'redbeard@yopmail.com'
        };
        Map<String,String> numbersMap=new Map<String,String>{
            'HomePhone'=>'1234567890',
            'Phone'=>'1234567890',
            'MobilePhone'=>'098764321'
        };
        Map<String, Map<String, String>> numberTinMap=new Map<String, Map<String, String>>{
            'numbersMap'=>numbersMap,
            'ssnEmailTinMap'=>ssnEmailTinMap
        };

        System.runAs(adminUser){
            Test.startTest();
            Map<String, Object> returnedMap=PortalApplicationCreationHandler.processForNewApplicantOfCompanyType(paramMap,numberTinMap,'One8');
            System.assert(returnedMap.get('accountObj')!=null,'Process for dba type failed');
            Test.stopTest();
        }
    }

    /**
    * @description check of the account and new user has been populated from the map sent
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testProcessForExistingGrowerWithNoApp(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<clcommon__Legal_Entity__c> solePropLegalEntityList=[Select id from clcommon__Legal_Entity__c where Name = 'Individual(s) - Sole Proprietorship'];

        Account newAccount=ApplicationOriginationTestHelper.createAccount();
        newAccount.Name='Kevin Hart';
        newAccount.CIF_Number__c='1234';
        newAccount.clcommon__Legal_Entity_Type__c=solePropLegalEntityList[0].id;
        Database.insert(newAccount,true);

        Contact newContact=ApplicationOriginationTestHelper.createContact();
        newContact.FirstName='Kevin';
        newContact.LastName='Hart';
        newContact.email='kevuin@yopmail.com';
        newContact.accountId = newAccount.id;

        Database.insert(newContact,true);
        List<genesis__Applications__c> applicationList=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        
        New_Portal_User__e newPortalUser=new New_Portal_User__e();

        Map<String, Object> paramMap=new Map<String,Object>{
                'accountObj'=>newAccount,
                'applicationObj'=>applicationList[0],
                'newPortalUser'=>newPortalUser
        };
        System.runAs(adminUser){
            Test.startTest();
            Map<String, Object> returnedMap=PortalApplicationCreationHandler.processForExistingGrowerWithNoApp((String)newAccount.id,paramMap);
            System.assert(returnedMap.get('accountObj')!=null,'Process for existing grower with no app failed');
            Test.stopTest();
        }

    }

    /**
    * @description test processPrincipalForNewApplicantOfCompanyOrDbaType for the case where there is no contact that exists with the same ssn as provided in the map in the db for growmark
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testPrincipalForNewApplicantNoSSNContactGMK(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Map<String, Map<String, String>> paramMap=new Map<String,Map<String,String>>{
            'numbersMap'=>new Map<String,String>{
                'HomePhone'=>'1234567890',
                'Phone'=>'1234567890',
                'MobilePhone'=>'098764321'
            },
            'nameMap'=>new Map<String,String>{
                'firstName'=>'Captain',
                'lastName'=>'Barbossa'
            },
            'ssnEmailTinMap'=>new Map<String, String>{
                'genesis__Tax_Identification_Number__c' => '123456789',
                'Confirm_Tax_Identification_Number__c' => '123456789',
                'genesis__SSN__c' => '112233445',
                'Confirm_SSN__c' => '112233445',
                'email' => 'redbeard@yopmail.com',
                'Confirm_Email__c' => 'redbeard@yopmail.com'
            }
        };
        List<genesis__Applications__c> applicationList=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        Map<String, Object> idAppCompanyNameMap=new Map<String, Object>{
            'dealerCoopType'=>'Growmark',
            'companyOrDbaName'=>'One8',
            'applicationId'=>(String)applicationList[0].id
        };
        New_Portal_User__e newPortalUser=new New_Portal_User__e();

        System.runAs(adminUser){
            Test.startTest();
            New_Portal_User__e returnedPortalUser=PortalApplicationCreationHandler.processPrincipalForNewApplicantOfCompanyOrDbaType(paramMap,newPortalUser,idAppCompanyNameMap);
            System.assert(returnedPortalUser!=null,'Error in creating a new portal user');
            Test.stopTest();
        }
    }

    /**
    * @description test processPrincipalForNewApplicantOfCompanyOrDbaType for the case where a contact exists in the db with the same ssn as provided in the map for growmark
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testPrincipalForNewApplicantContactWithSSNGMK(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Map<String, Map<String, String>> paramMap=new Map<String,Map<String,String>>{
            'numbersMap'=>new Map<String,String>{
                'HomePhone'=>'1234567890',
                'Phone'=>'1234567890',
                'MobilePhone'=>'098764321'
            },
            'nameMap'=>new Map<String,String>{
                'firstName'=>'Captain',
                'lastName'=>'Barbossa'
            },
            'ssnEmailTinMap'=>new Map<String, String>{
                'genesis__Tax_Identification_Number__c' => '123456789',
                'Confirm_Tax_Identification_Number__c' => '123456789',
                'genesis__SSN__c' => '112233445',
                'Confirm_SSN__c' => '112233445',
                'email' => 'redbeard@yopmail.com',
                'Confirm_Email__c' => 'redbeard@yopmail.com'
            }
        };
        List<genesis__Applications__c> applicationList=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        Map<String, Object> idAppCompanyNameMap=new Map<String, Object>{
            'dealerCoopType'=>'Growmark',
            'companyOrDbaName'=>'One8',
            'applicationId'=>(String)applicationList[0].id
        };
        New_Portal_User__e newPortalUser=new New_Portal_User__e();

        List<clcommon__Legal_Entity__c> solePropLegalEntityList=[Select id from clcommon__Legal_Entity__c where Name = 'Individual(s) - Sole Proprietorship'];

        genesis__Business_Information__c newBusinessInfo=ApplicationOriginationTestHelper.createBusinessInfoForPrincipal();
        Database.insert(newBusinessInfo,true);

        Account newAccount=ApplicationOriginationTestHelper.createAccount();
        newAccount.Name='Kevin Hart';
        newAccount.CIF_Number__c='1234';
        newAccount.clcommon__Legal_Entity_Type__c=solePropLegalEntityList[0].id;
        newAccount.genesis__Business_Information__c=newBusinessInfo.id;
        Database.insert(newAccount,true);

        Contact newContact=ApplicationOriginationTestHelper.createContact();
        newContact.FirstName='Kevin';
        newContact.LastName='Hart';
        newContact.genesis__SSN__c='112233445';
        newContact.accountId = newAccount.id;
        Database.insert(newContact,true);

        System.runAs(adminUser){
            Test.startTest();
            New_Portal_User__e returnedPortalUser=PortalApplicationCreationHandler.processPrincipalForNewApplicantOfCompanyOrDbaType(paramMap,newPortalUser,idAppCompanyNameMap);
            System.assert(returnedPortalUser!=null,'Error in creating a new portal user');
            Test.stopTest();
        }
    }

    /**
    * @description test processPrincipalForNewApplicantOfCompanyOrDbaType for the case where there is no contact that exists with the same ssn as provided in the map in the db for cfa
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testPrincipalForNewApplicantNoSSNContactCFA(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Map<String, Map<String, String>> paramMap=new Map<String,Map<String,String>>{
            'numbersMap'=>new Map<String,String>{
                'HomePhone'=>'1234567890',
                'Phone'=>'1234567890',
                'MobilePhone'=>'098764321'
            },
            'nameMap'=>new Map<String,String>{
                'firstName'=>'Captain',
                'lastName'=>'Barbossa'
            },
            'ssnEmailTinMap'=>new Map<String, String>{
                'genesis__Tax_Identification_Number__c' => '123456789',
                'Confirm_Tax_Identification_Number__c' => '123456789',
                'genesis__SSN__c' => '112233445',
                'Confirm_SSN__c' => '112233445',
                'email' => 'redbeard@yopmail.com',
                'Confirm_Email__c' => 'redbeard@yopmail.com'
            }
        };
        List<genesis__Applications__c> applicationList=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        Map<String, Object> idAppCompanyNameMap=new Map<String, Object>{
            'dealerCoopType'=>'CFA',
            'companyOrDbaName'=>'One8',
            'applicationId'=>(String)applicationList[0].id
        };
        New_Portal_User__e newPortalUser=new New_Portal_User__e();

        System.runAs(adminUser){
            Test.startTest();
            New_Portal_User__e returnedPortalUser=PortalApplicationCreationHandler.processPrincipalForNewApplicantOfCompanyOrDbaType(paramMap,newPortalUser,idAppCompanyNameMap);
            System.assert(returnedPortalUser!=null,'Error in creating a new portal user');
            Test.stopTest();
        }
    }

    /**
    * @description test processPrincipalForNewApplicantOfCompanyOrDbaType for the case where a contact exists in the db with the same ssn as provided in the map for cfa
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testPrincipalForNewApplicantContactWithSSNCFA(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Map<String, Map<String, String>> paramMap=new Map<String,Map<String,String>>{
            'numbersMap'=>new Map<String,String>{
                'HomePhone'=>'1234567890',
                'Phone'=>'1234567890',
                'MobilePhone'=>'098764321'
            },
            'nameMap'=>new Map<String,String>{
                'firstName'=>'Captain',
                'lastName'=>'Barbossa'
            },
            'ssnEmailTinMap'=>new Map<String, String>{
                'genesis__Tax_Identification_Number__c' => '123456789',
                'Confirm_Tax_Identification_Number__c' => '123456789',
                'genesis__SSN__c' => '112233445',
                'Confirm_SSN__c' => '112233445',
                'email' => 'redbeard@yopmail.com',
                'Confirm_Email__c' => 'redbeard@yopmail.com'
            }
        };
        List<genesis__Applications__c> applicationList=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];
        Map<String, Object> idAppCompanyNameMap=new Map<String, Object>{
            'dealerCoopType'=>'CFA',
            'companyOrDbaName'=>'One8',
            'applicationId'=>(String)applicationList[0].id
        };
        New_Portal_User__e newPortalUser=new New_Portal_User__e();

        List<clcommon__Legal_Entity__c> solePropLegalEntityList=[Select id from clcommon__Legal_Entity__c where Name = 'Individual(s) - Sole Proprietorship'];

        genesis__Business_Information__c newBusinessInfo=ApplicationOriginationTestHelper.createBusinessInfoForPrincipal();
        Database.insert(newBusinessInfo,true);

        Account newAccount=ApplicationOriginationTestHelper.createAccount();
        newAccount.Name='Kevin Hart';
        newAccount.CIF_Number__c='1234';
        newAccount.clcommon__Legal_Entity_Type__c=solePropLegalEntityList[0].id;
        newAccount.genesis__Business_Information__c=newBusinessInfo.id;
        Database.insert(newAccount,true);

        Contact newContact=ApplicationOriginationTestHelper.createContact();
        newContact.FirstName='Kevin';
        newContact.LastName='Hart';
        newContact.genesis__SSN__c='112233445';
        newContact.accountId = newAccount.id;
        Database.insert(newContact,true);

        System.runAs(adminUser){
            Test.startTest();
            New_Portal_User__e returnedPortalUser=PortalApplicationCreationHandler.processPrincipalForNewApplicantOfCompanyOrDbaType(paramMap,newPortalUser,idAppCompanyNameMap);
            System.assert(returnedPortalUser!=null,'Error in creating a new portal user');
            Test.stopTest();
        }
    }

    /**
    * @description check if feilds are being populated in the returned map from hte map we send
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testProcessForExistingApplicantSoleProp(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Applications__c> applicationList=[Select id,genesis__Contact__c,genesis__Account__c,genesis__account__r.clcommon__Legal_Entity_Type__r.Name,genesis__contact__r.Email from genesis__Applications__c where genesis__Loan_Amount__c=854001];

        Map<String, Object> paramMap=new Map<String, Object>{
            'email'=>'redBeard@yopmail.com',
            'accountObj'=>ApplicationOriginationTestHelper.createAccount(),
            'applicationObj'=>new genesis__Applications__c(),
            'newPortalUser'=>new New_Portal_User__e()
        };

        System.runAs(certifiedLenderUserObj){
            Test.startTest();
            Map<String, Object> returnedMap=PortalApplicationCreationHandler.processForExistingApplicantWithExistingApp(paramMap,applicationList);
            System.assertEquals(returnedMap.get('email'),applicationList[0].genesis__contact__r.Email,'process for existing applicants using existing application not working');
            Test.stopTest();
        }
    }

    /**
    * @description test of the email is populated in the returned map along eith fields of the application and account
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testProcessForExistingApplicantCompany(){
        // User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];


        List<genesis__Applications__c> applicationList=[Select id,genesis__Contact__c,genesis__Account__c,genesis__account__r.clcommon__Legal_Entity_Type__r.Name,genesis__contact__r.Email from genesis__Applications__c where genesis__Loan_Amount__c=854001];

        List<Account> corpAccountList=[Select id from account where name='Green Crops Pvt. Ltd.'];
        applicationList[0].genesis__Account__c=corpAccountList[0].id;
        List<Contact> corpContactList=[Select id from contact where LastName='Green Crops Pvt. Ltd.'];
        applicationList[0].genesis__Contact__c=corpContactList[0].id;

        Database.upsert(applicationList,true);
        applicationList=[Select id,genesis__Contact__c,genesis__Account__c,genesis__account__r.clcommon__Legal_Entity_Type__r.Name,genesis__contact__r.Email from genesis__Applications__c where genesis__Loan_Amount__c=854001];

        Map<String, Object> paramMap=new Map<String, Object>{
            'email'=>'green.crops@yopmail.com',
            'accountObj'=>ApplicationOriginationTestHelper.createAccount(),
            'applicationObj'=>new genesis__Applications__c(),
            'newPortalUser'=>new New_Portal_User__e()
        };

        System.runAs(adminUser){
            Test.startTest();
            Map<String, Object> returnedMap=PortalApplicationCreationHandler.processForExistingApplicantWithExistingApp(paramMap,applicationList);
            System.assertEquals('red.beard@yopmail.com',returnedMap.get('email'),'process for existing applicants using existing application not working');
            Test.stopTest();
        }
    }

    /**
    * @description testing updateBorrowerDetails after deleting the borrower party from db
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testUpdateBorrowerDetailsWithoutParty(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj=[Select id,genesis__Account__c,genesis__Contact__c,Dealer_Name__c from genesis__Applications__c where genesis__Loan_Amount__c=854001];

        clcommon__Party__c borrowerParty=[SELECT Id,
                                                clcommon__Contact__c,
                                                clcommon__Account__c,
                                                clcommon__Account__r.genesis__Business_information__c
                                            FROM clcommon__party__c
                                            WHERE genesis__Application__c =: applicationObj.Id
                                            AND clcommon__Type__r.Name =: PortalConstants.BORROWER_PARTY_NAME];

        Account accountObj=[ SELECT ID,
                                    BillingStreet,
                                    BillingCity,
                                    BillingState,
                                    BillingPostalCode,
                                    Billing_County__c,
                                    Home_Number__c,
                                    Work_Number__c,
                                    Phone,
                                    clcommon__Legal_Entity_Type__c
                            FROM ACCOUNT
                            WHERE ID=: borrowerParty.clcommon__Account__c
                            Limit 1 ];

        Contact contactObj=[ SELECT ID,
                                    MailingStreet,
                                    MailingCity,
                                    MailingState,
                                    MailingPostalCode,
                                    Mailing_County__c,
                                    MobilePhone,
                                    Phone,
                                    HomePhone,
                                    Title,
                                    Suffix__c,
                                    clcommon__Marital_Status__c
                            FROM CONTACT
                            WHERE ID=: borrowerParty.clcommon__Contact__c
                            Limit 1 ];

        genesis__Business_Information__c businessInfoObj=[Select id,
                                                                 Gross_Farm_Income__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE ID=:borrowerParty.clcommon__Account__r.genesis__Business_information__c];

        Dealer_Applicant_Relationship__c dealerApplicantRelObj=[Select id from Dealer_Applicant_Relationship__c where Applicant__c=:accountObj.id];
                                        
        Database.delete(borrowerParty,true);

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.updateBorrowerDetails(new Map<String,Object>{'contactObj'=>contactObj,
                                                                                          'accountObj'=>accountObj,
                                                                                          'businessInfoObj'=>businessInfoObj,
                                                                                          'application'=>applicationObj,
                                                                                          'Id'=>dealerApplicantRelObj.id});
            borrowerParty=[SELECT Id,
                                clcommon__Contact__c
                            FROM clcommon__party__c
                            WHERE genesis__Application__c =: applicationObj.Id
                            AND clcommon__Type__r.Name =: PortalConstants.BORROWER_PARTY_NAME];
            System.assert(borrowerParty!=null,'Borrower party details not updated');
            Test.stopTest();
        }

    }

    /**
    * @description testing updateBorrowerDetails for the case where the borrower party alredy exists in the db
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testUpdateBorrowerDetailsWithParty(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj=[SELECT id,
                                                        genesis__Account__c,
                                                        genesis__Account__r.genesis__Business_Information__c,
                                                        genesis__Contact__c,Dealer_Name__c,
                                                        Dealer_Applicant_Relationship__c
                                                FROM genesis__Applications__c 
                                                WHERE genesis__Loan_Amount__c=854001];

        Account accountObj=[ SELECT ID,
                                    BillingStreet,
                                    BillingCity,
                                    BillingState,
                                    BillingPostalCode,
                                    Billing_County__c,
                                    Home_Number__c,
                                    Work_Number__c,
                                    Phone,
                                    clcommon__Legal_Entity_Type__c
                            FROM ACCOUNT
                            WHERE ID=: applicationObj.genesis__Account__c
                            Limit 1 ];

        Contact contactObj=[ SELECT ID,
                                    MailingStreet,
                                    MailingCity,
                                    MailingState,
                                    MailingPostalCode,
                                    Mailing_County__c,
                                    MobilePhone,
                                    Phone,
                                    HomePhone,
                                    Title,
                                    Suffix__c,
                                    clcommon__Marital_Status__c
                            FROM CONTACT
                            WHERE ID=: applicationObj.genesis__Contact__c
                            Limit 1 ];

        genesis__Business_Information__c businessInfoObj=[Select id,
                                                                 Gross_Farm_Income__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE ID=:applicationObj.genesis__Account__r.genesis__Business_Information__c];

        Dealer_Applicant_Relationship__c dealerApplicantRelObj=[Select id from Dealer_Applicant_Relationship__c where Applicant__c=:accountObj.id];

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.updateBorrowerDetails(new Map<String,Object>{'contactObj'=>contactObj,
                                                                                          'accountObj'=>accountObj,
                                                                                          'businessInfoObj'=>businessInfoObj,
                                                                                          'application'=>applicationObj,
                                                                                          'Id'=>dealerApplicantRelObj.id});
            clcommon__party__c borrowerParty=[SELECT Id,
                                clcommon__Contact__c
                            FROM clcommon__party__c
                            WHERE clcommon__Contact__c =: applicationObj.genesis__Contact__c
                            AND clcommon__Type__r.Name =: PortalConstants.BORROWER_PARTY_NAME limit 1];
            System.assert(borrowerParty!=null,'Borrower party details updated');
            Test.stopTest();
        }
    }

    /**
    * @description test if the function throws error for null fields sent to it
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCheckForCoApplicant(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(adminUser){
            Test.startTest();
            try{
                PortalApplicationCreationHandler.checkForCoApplicant(null,null);
            }
            catch(CustomException excp){
                System.assertEquals('Please add a Co-Applicant',excp.getMessage(),'Exception not thrown');
            }
            Test.stopTest();
        }
    }

    /**
    * @description test of a response from portal is converted to a map with proper fields
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testGetCoApplicantList(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        String response='[{\"id\":\"a2mVD000000gr6LYAQ\",\"clcommon__Contact__r.Masked_Confirm_SSN__c\":\"XXX-XX-6556\",\"clcommon__Contact__r.Masked_SSN__c\":\"XXX-XX-6556\",\"clcommon__Contact__r.Id\":\"003VD00000GaGL9YAN\",\"clcommon__Contact__r.MobilePhone\":\"1234567834\",\"Total_Assets__c\":10000,\"clcommon__Contact__r.Birthdate\":\"1998-08-13\",\"clcommon__Contact__r.MailingStreet\":\"1234 Long Pond Road\",\"clcommon__Contact__r.LastName\":\"applicant\",\"clcommon__Contact__r.Suffix__c\":\"Sr.\",\"clcommon__Contact__r.clcommon__Marital_Status__c\":\"Unmarried\",\"clcommon__Contact__r.Confirm_Email__c\":\"kvicha@yopmail.com\",\"clcommon__Contact__r.MailingCity\":\"Long Pond\",\"clcommon__Contact__r.MailingState\":\"PA\",\"clcommon__Contact__r.Title\":\"Co-Applicant\",\"clcommon__Account__r.Id\":\"001VD000009wHEiYAM\",\"Is_SSN_Entered__c\":true,\"clcommon__Account__r.Year_Began_Farming__c\":\"2013\",\"Total_Liabilities__c\":1,\"clcommon__Account__r.genesis__Business_Information__r.Net_Worth__c\":9999,\"clcommon__Contact__r.FirstName\":\"Jake\",\"clcommon__Contact__r.Email\":\"kvicha@yopmail.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"665566556\",\"clcommon__Account__r.genesis__Business_Information__r.Id\":\"a7AVD0000006NbR2AU\",\"clcommon__Contact__r.ints__Middle_Name__c\":\"co\",\"clcommon__Contact__r.MailingPostalCode\":\"18334\",\"Id\":\"a2mVD000000gr6LYAW\",\"clcommon__Contact__r.Confirm_SSN__c\":\"665566556\",\"clcommon__Contact__r.Mailing_County__c\":\"Monroe County\"}]';
        List<Object> responseDeserialized = (List<Object>) Json.deserializeUntyped(response);
        List<Map<String, Object>> finalResponse = new List<Map<String, Object>>();
        finalResponse.add((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(responseDeserialized[0])));

        System.runAs(adminUser){
            Test.startTest();
            List<Map<String, Object>> responseFromFunc=PortalApplicationCreationHandler.getCoApplicantList(response);
            System.assertEquals(finalResponse,responseFromFunc,'Response not properly deserialized');
            Test.stopTest();
        }
    }

    /**
    * @description check if the coop type is updated for the account of the principal parties
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testUpdatePrincipalParties(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj=[Select id from genesis__Applications__c where genesis__Loan_Amount__c=854001];

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.updatePrincipalParties(applicationObj.id,'CFA',certifiedLenderUserObj);
            List<Id> principalAccIdList=new List<Id>();
            List<clcommon__Party__c> principalPartyList=[select id, clcommon__Account__c from clcommon__party__c WHERE genesis__Application__c = :applicationObj.id AND clcommon__Party_Types__c = 'PRINCIPAL'];
            for(clcommon__Party__c eachPrincipalParty : principalPartyList){
                principalAccIdList.add(eachPrincipalParty.clcommon__Account__c);
            }
            account principalAccount=[select id,Coop_Type__c from account where id in :principalAccIdList limit 1];
            System.assertEquals('CFA',principalAccount.Coop_Type__c,'Response not properly deserialized');
            Test.stopTest();
        }
    }

    /**
    * @description check if a new document category sharing record has been created where the parent id is the doc. category id. It should be cause we have a sa admin user
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCreateSharingRecordsForSAAdmin(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Account dealerObj=[select id from account where name='Kisan Loan' limit 1];
        genesis__Applications__c applicationObj=[Select id,Sales_Agent__c from genesis__Applications__c where genesis__Loan_Amount__c=854001];

        clcommon__Document_Category__c documentCategoryObj=ApplicationOriginationTestHelper.createAccDocumentCategory(dealerObj.id);
        documentCategoryObj.genesis__Application__c=applicationObj.id;
        Database.insert(documentCategoryObj,true);

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.createSharingRecordsForSAAdmin(applicationObj);
            List<clcommon__Document_Category__Share> docCategoryShareList=[Select id from clcommon__Document_Category__Share where parentId =:documentCategoryObj.id];
            System.assert(docCategoryShareList.size()>0,'Sharing records not created for SAA');
            Test.stopTest();
        }
    }

    /**
    * @description check if a new document category sharing record has been created where the parent id is the doc. category id. 
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testCreateSharingRecordsForSA(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        Account dealerObj=[select id from account where name='Kisan Loan' limit 1];
        genesis__Applications__c applicationObj=[Select id,Sales_Agent__c from genesis__Applications__c where genesis__Loan_Amount__c=854001 limit 1];

        clcommon__Document_Category__c documentCategoryObj=ApplicationOriginationTestHelper.createAccDocumentCategory(dealerObj.id);
        documentCategoryObj.genesis__Application__c=applicationObj.id;
        Database.insert(documentCategoryObj,true);

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.createSharingRecordsForSA(applicationObj);
            List<clcommon__Document_Category__Share> docCategoryShareList=[Select id from clcommon__Document_Category__Share where parentId =:documentCategoryObj.id];
            System.assert(docCategoryShareList.size()>0,'Sharing records not created for SAA');
            Test.stopTest();
        }
    }

    /**
    * @description check if the coApplicant details have been updated where ssn has not been changed
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testUpdateCoApplicantDetails(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj=[select id,Dealer_Name__c from genesis__applications__c where genesis__Loan_Amount__c=854001];

        clcommon__Party__c partyObj=[Select id,
                                                clcommon__Account__c,
                                                clcommon__Contact__c 
                                                from clcommon__Party__c 
                                                where genesis__Application__c=:applicationObj.id
                                                and clcommon__Party_Types__c = 'PRINCIPAL' Limit 1];

        genesis__Business_Information__c businessInfoObj=[select id from genesis__Business_Information__c where genesis__Business_Country__c='India'];
        Account principalAccount=[select id,genesis__Business_Information__c from account where id =:partyObj.clcommon__Account__c];
        principalAccount.genesis__Business_Information__c=businessInfoObj.id;
        Database.upsert(principalAccount,true);

        coApplicantInfo.put('clcommon__Account__r.Id',principalAccount.id);
        coApplicantInfo.put('clcommon__Contact__r.Id',partyObj.clcommon__Contact__c);
        coApplicantInfo.put('Id',partyObj.id);
        coApplicantInfo.put('clcommon__Account__r.genesis__Business_Information__r.Id',businessInfoObj.id);

        List<Map<String, Object>> coApplicants=new List<Map<String, Object>>();
        coApplicants.add(coApplicantInfo);

        List<User> userList = [SELECT Id,
                                      Account.ParentId,
                                      Account.Parent.Coop_Type__c
                                FROM User
                                WHERE AccountId IN (
                                    SELECT Id
                                        FROM Account
                                        WHERE Name = 'Ross Geller')];

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.updateCoApplicantDetails(coApplicants,new Map<String,Object>{'applicationId'=>(String)applicationObj.id,
                                                                                                          'shouldValidate'=>'SaveAndContinue',
                                                                                                          'loggedInUser'=>userList[0]});
            Contact partyContactObj=[select id from contact where FirstName='Shivam'];
            System.assert(partyContactObj.id!=null,'Update party details failed');
            Test.stopTest();
        }

    }

    /**
    * @description  check if the coApplicant details have been updated where ssn has been changed to the one that is a different account that already exists in the db
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testUpdateCoApplicantDetailsChangedSSN(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj=[select id,Dealer_Name__c from genesis__applications__c where genesis__Loan_Amount__c=854001];

        clcommon__Party__c partyObj=[Select id,
                                            clcommon__Account__c,
                                            clcommon__Contact__c 
                                            from clcommon__Party__c 
                                            where genesis__Application__c=:applicationObj.id
                                            and clcommon__Party_Types__c = 'PRINCIPAL' Limit 1];

        genesis__Business_Information__c businessInfoObj=[select id from genesis__Business_Information__c where genesis__Business_Country__c='India'];
        Account principalAccount=[select id,genesis__Business_Information__c from account where id =:partyObj.clcommon__Account__c];
        principalAccount.genesis__Business_Information__c=businessInfoObj.id;
        Database.upsert(principalAccount,true);

        genesis__Business_Information__c businessInfo=ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfo,true);

        Account accountObj=ApplicationOriginationTestHelper.createAccount();
        accountObj.genesis__Business_Information__c=businessInfo.id;
        Database.upsert(accountObj,true);

        Contact contactObj=ApplicationOriginationTestHelper.createContact();
        contactObj.genesis__SSN__c='123458809';
        contactObj.AccountId=accountObj.id;
        Database.upsert(contactObj,true);

        coApplicantInfo.put('clcommon__Account__r.Id',principalAccount.id);
        coApplicantInfo.put('clcommon__Contact__r.Id',partyObj.clcommon__Contact__c);
        coApplicantInfo.put('Id',partyObj.id);
        coApplicantInfo.put('clcommon__Account__r.genesis__Business_Information__r.Id',businessInfoObj.id);

        List<Map<String, Object>> coApplicants=new List<Map<String, Object>>();
        coApplicants.add(coApplicantInfo);

        List<User> userList = [SELECT Id,
                                      Account.ParentId,
                                      Account.Parent.Coop_Type__c
                                FROM User
                                WHERE AccountId IN (
                                    SELECT Id
                                        FROM Account
                                        WHERE Name = 'Ross Geller')];

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.updateCoApplicantDetails(coApplicants,new Map<String,Object>{'applicationId'=>(String)applicationObj.id,
                                                                                                          'shouldValidate'=>'SaveAndContinue',
                                                                                                          'loggedInUser'=>userList[0]});
            Contact partyContactObj=[select id from contact where FirstName='Shivam'];
            System.assert(partyContactObj.id!=null,'Update party details failed');
            Test.stopTest();
        }

    }

    /**
    * @description test if the total assets has been updated for the party according to that of the one,related to account by the function
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest
    static void testProcessBusinessInfoOfBorrower(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        genesis__Applications__c applicationObj=[select id,genesis__Contact__c from genesis__applications__c where genesis__Loan_Amount__c=854001];
        Contact borrowercon=[select id,AccountId from contact where id =:applicationObj.genesis__Contact__c];
        Account borrowerAcc=[select id,genesis__Business_Information__c from account where id =:borrowerCon.AccountId];
        genesis__Business_Information__c borrowerBusinessInfo=[select id,genesis__Total_Assets__c,genesis__Total_Liabilities__c from genesis__Business_Information__c where genesis__Business_Country__c='India'];
        borrowerAcc.genesis__Business_Information__c=borrowerBusinessInfo.id;
        Database.upsert(borrowerAcc,true);

        clcommon__party__c borrowerparty=[select id,Total_Assets__c from clcommon__party__c where genesis__application__c = :applicationObj.id and clcommon__Account__c = :borrowerAcc.id and clcommon__Type__r.Name = 'BORROWER'];


        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.processBusinessInfoOfBorrower(new Map<String,Object>{'businessInfoObj'=>borrowerBusinessInfo,
                                                                                                  'accountObj'=>borrowerAcc.id,
                                                                                                  'BORROWER'=>borrowerparty});
            clcommon__party__c partyInfo=[select id,Total_Assets__c from clcommon__party__c where genesis__application__c = :applicationObj.id and clcommon__Account__c = :borrowerAcc.id and clcommon__Type__r.Name = 'BORROWER'];
            System.assertEquals(borrowerBusinessInfo.genesis__Total_Assets__c,partyInfo.Total_Assets__c,'Process business info of borrower not working');
            Test.stopTest();
        }

    }


    /**
    * @description the purpose of this method is to test checkIfKycVerified
    * @author Rakesh Saraf | 02-13-2025 
    **/
    @isTest
    static void testCheckIfKycVerified(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<genesis__Applications__c> applicationObj=[select id,genesis__Contact__c from genesis__applications__c where genesis__Loan_Amount__c=854001];
        List<Contact> borrowercon=[select id,LastName,AccountId from contact where id =:applicationObj[0].genesis__Contact__c];
        String lastName=borrowercon[0].lastName;
        borrowercon[0].LastName=lastName+'Testing';

        List<Account> borrowerAcc=[select id,Kyc_Verified__c from account where id =:borrowerCon[0].AccountId];
        borrowerAcc[0].Kyc_Verified__c=true;
        Database.update(borrowerAcc,true);

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.checkIfKycVerified(borrowercon[0],borrowerAcc[0]);
            System.assertEquals(borrowercon[0].LastName,lastName,'test check for kyc verified not working');
            Test.stopTest();
        }
    }

    /**
    * @description the purpose of this method is to test checkKycVerifiedForCoApplicants
    * @author Rakesh Saraf | 02-13-2025 
    **/
    @isTest
    static void testCheckKycVerifiedForCoApplicants(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];

        List<genesis__Applications__c> applicationObj=[select id,genesis__Contact__c from genesis__applications__c where genesis__Loan_Amount__c=854001];
        List<Contact> borrowercon=[select id,LastName,AccountId from contact where id =:applicationObj[0].genesis__Contact__c];
        String lastName=borrowercon[0].lastName;
        borrowercon[0].LastName=lastName+'Testing';

        List<Account> borrowerAcc=[select id,Kyc_Verified__c from account where id =:borrowerCon[0].AccountId];
        borrowerAcc[0].Kyc_Verified__c=true;
        Database.update(borrowerAcc,true);

        Map<Id,clcommon__Party__c> contactVsPartyMap=new Map<Id,clcommon__Party__c>{
            borrowercon[0].Id => new clcommon__Party__c()
        };

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.checkKycVerifiedForCoApplicants(borrowerAcc,borrowercon,contactVsPartyMap);
            System.assertEquals(borrowercon[0].LastName,lastName,'test check for kyc verified for coApplicants not working');
            Test.stopTest();
        }
    }

    /**
    * @description method used to test PopulateCorporationContact
    * @author Rakesh Saraf | 03-13-2025 
    **/
    @isTest
    private static void testPopulateCorporationContact(){
        User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND isActive = true LIMIT 1];
        Account accountObj=new Account();
        accountObj.Phone='1234567890' ;
        accountObj.Work_Number__c = '1234567898' ;
        accountObj.Home_Number__c = '1234567894' ;

        accountObj.BillingStreet = '3rd Avenue' ;
        accountObj.BillingCity = 'Kansas City' ;
        accountObj.BillingState = 'NY' ;
        accountObj.Billing_County__c =  'Kings';
        accountObj.BillingPostalCode = '12345' ;

        Contact contactObj=new Contact();

        System.runAs(adminUser){
            Test.startTest();
            PortalApplicationCreationHandler.populateCorporationContact(contactObj,accountObj);
            System.assertEquals(contactObj.MailingStreet,accountObj.BillingStreet,'test populate corp contact not working');
            Test.stopTest();
        }
    }
}