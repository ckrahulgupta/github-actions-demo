/**
 * @description       : Test class for PortalSaveCoApplicantAPI
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 01-13-2025
 * @last modified by  : Rakesh Saraf
**/
@isTest
public with sharing class PortalSaveCoApplicantAPITest {
    @TestSetup
    static void setup(){
        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj,true);

        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        Database.insert(clUserObj, true);

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);

        // Creating Account for Borrower
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, ApplicationOriginationTestHelper.createBusinessInfoForBorrower().Id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.insert(borrowerAccountObj, true);

        // Creating Contact for Borrower
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(borrowerContactObj,true);

        // Creating User for Borrower
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(borrowerUserObj, true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

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

        Dealer_Applicant_Relationship__c dealerAppRel=ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.id);
        Database.insert(dealerAppRel,true);

        applicationObj.Dealer_Applicant_Relationship__c=dealerAppRel.id;
        Database.insert(applicationObj, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,clAccountObj.Id,borrowerAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        // Creating Certified Lender Party Type
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');

        // Create Borrower Party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(new List<clcommon__Party_Type__c>{borrowerPartyTypeObj,clPartyTypeObj}, true);

        // Creating Certified Lender Party
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                                    'accountId'=> clAccountObj.Id,
                                                                                                    'contactId'=> clContactObj.Id,
                                                                                                    'partyTypeId'=> clPartyTypeObj.Id,
                                                                                                    'applicationId'=> applicationObj.Id
                                                                                                });

        // Creating Borrower Party
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                                            'accountId'=> borrowerAccountObj.Id,
                                                                                                            'contactId'=> borrowerContactObj.Id,
                                                                                                            'partyTypeId'=> borrowerPartyTypeObj.Id,
                                                                                                            'applicationId'=> applicationObj.Id
                                                                                                        });
        borrowerPartyObj.Dealer_Applicant_Relationship__c=dealerAppRel.id;
        Database.insert(new List<clcommon__Party__c>{clPartyObj,borrowerPartyObj},true);   

        // Creating Account for CoApplicant
        Account principalAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, ApplicationOriginationTestHelper.createBusinessInfoForPrincipal().Id);
        principalAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        Database.insert(principalAccountObj, true);

        // Creating Contact for Borrower
        Contact principalContactObj = ApplicationOriginationTestHelper.createBorrowerContact(principalAccountObj.Id);
        Database.insert(principalContactObj,true);

        CFA_Configuration__c cifObj = ApplicationOriginationTestHelper.createCIFNumber();
        Database.insert(cifObj,true);

        genesis__Applications__c duplicateApplicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        duplicateApplicationObj.genesis__Loan_Number__c='300023411';
        Database.insert(duplicateApplicationObj,true);        
    }

    /**
    * @description save a co applicant with the details from the portal
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testNewCoApplicantSaveAndContinue(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();

        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Phone'=> '1111111111',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'clcommon__Email__c'=> 'ajeet_raj@yopmail.com',
            'Billing_County__c'=> 'Orange County',
            'BillingPostalCode'=> '32824',
            'BillingState'=> 'FL',
            'BillingCity'=> 'Orlando',
            'BillingStreet'=> '12340 Boggy Creek Road',
            'Year_Began_Farming__c'=> '2024'
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'genesis__Total_Assets__c'=> 18738970,
            'genesis__Total_Liabilities__c'=> 10,
            'Gross_Farm_Income__c'=> 20000
        };
        Map<String,Object> coApplicantContactMap=new Map<String,Object>{
            'Birthdate'=> '1985-12-12',
            'MobilePhone'=> '1111111111',
            'Confirm_SSN__c'=> '878737654',
            'genesis__SSN__c'=> '878737654',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'Email'=> 'ajeet_raj@yopmail.com',
            'FirstName'=> 'Ajeet',
            'LastName'=> 'Raj',
            'Mailing_County__c'=> 'Orange County',
            'MailingPostalCode'=> '32824',
            'MailingState'=> 'FL',
            'MailingCity'=> 'Orlando',
            'MailingStreet'=> '12340 Boggy Creek Road',
            'clcommon__Marital_Status__c'=> 'Married',
            'Title'=> 'Co-Applicant'
        };

        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));
        requestMap.put('coApplicantContact', JSON.serialize(coApplicantContactMap));
        requestMap.put('saveType', 'SaveAndContinue');

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Failure'); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description save a co applicant with the details from the portal for a applicant which already has a contact with the same ssn
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testCoApplicantExistingSSNSaveAndContinue(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
                                                        

        genesis__Business_Information__c principalBusinessInfo=ApplicationOriginationTestHelper.createBusinessInfoForPrincipal();
        Database.insert(principalBusinessInfo,true);

        Account principalAccountObj=ApplicationOriginationTestHelper.createAccount();
        principalAccountObj.genesis__Business_Information__c=principalBusinessInfo.id;
        Database.insert(principalAccountObj,true);

        Contact principalContact=ApplicationOriginationTestHelper.createContact();
        principalContact.AccountId=principalAccountObj.id;
        principalContact.genesis__SSN__c='878737654';
        Database.insert(principalContact,true);

        Map<String,Object> requestMap = new Map<String,Object>();

        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Phone'=> '1111111111',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'clcommon__Email__c'=> 'ajeet_raj@yopmail.com',
            'Billing_County__c'=> 'Orange County',
            'BillingPostalCode'=> '32824',
            'BillingState'=> 'FL',
            'BillingCity'=> 'Orlando',
            'BillingStreet'=> '12340 Boggy Creek Road',
            'Year_Began_Farming__c'=> '2024'
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'genesis__Total_Assets__c'=> 18738970,
            'genesis__Total_Liabilities__c'=> 10,
            'Gross_Farm_Income__c'=> 20000
        };
        Map<String,Object> coApplicantContactMap=new Map<String,Object>{
            'Birthdate'=> '1985-12-12',
            'MobilePhone'=> '1111111111',
            'Confirm_SSN__c'=> '878737654',
            'genesis__SSN__c'=> '878737654',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'Email'=> 'ajeet_raj@yopmail.com',
            'FirstName'=> 'Ajeet',
            'LastName'=> 'Raj',
            'Mailing_County__c'=> 'Orange County',
            'MailingPostalCode'=> '32824',
            'MailingState'=> 'FL',
            'MailingCity'=> 'Orlando',
            'MailingStreet'=> '12340 Boggy Creek Road',
            'clcommon__Marital_Status__c'=> 'Married',
            'Title'=> 'Co-Applicant'
        };

        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));
        requestMap.put('coApplicantContact', JSON.serialize(coApplicantContactMap));
        requestMap.put('saveType', 'SaveAndContinue');

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Failure'); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description exception to be thrown if the applicant already exists in the application
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testCustomExceptionCoApplicantAlreadyExist(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        Account principalAccountObj = [SELECT Id,
                                                genesis__Business_Information__c
                                            FROM Account
                                            WHERE Name = 'Jasmine Albin'
                                            LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();

        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Id'=> principalAccountObj.id
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'Id'=> principalAccountObj.genesis__Business_Information__c
        };
        

        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));
        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed'); 
                Test.stopTest();
            }
        }
    }


    /**
    * @description saving a co applicant using the add button
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testAddNewCoApplicantFromAddButton(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        
        genesis__Applications__c duplicateApplicationObj = [SELECT Id
                                                            FROM genesis__Applications__c 
                                                            WHERE genesis__Loan_Number__c = '300023411'
                                                            LIMIT 1];

        Account dealerAcc=ApplicationOriginationTestHelper.getDealerAccoount();
        
        genesis__Business_Information__c principalBusinessInfo=ApplicationOriginationTestHelper.createBusinessInfoForPrincipal();
        Database.insert(principalBusinessInfo,true);

        Account principalAccountObj=ApplicationOriginationTestHelper.createAccount();
        principalAccountObj.genesis__Business_Information__c=principalBusinessInfo.id;
        Database.insert(principalAccountObj,true);

        Contact principalContact=ApplicationOriginationTestHelper.createContact();
        principalContact.AccountId=principalAccountObj.id;
        Database.insert(principalContact,true);

        Dealer_Applicant_Relationship__c dealerCoAppRel=ApplicationOriginationTestHelper.createDealerApplicantRelationship(principalContact,dealerAcc.id);
        Database.insert(dealerCoAppRel,true);

        clcommon__Party__c principalParty=ApplicationOriginationTestHelper.createApplicantParty(new Map<String,String>{
                                                                                                                    'accountId'=>principalAccountObj.id,
                                                                                                                    'contactId'=>principalContact.id,
                                                                                                                    'applicationId'=>duplicateApplicationObj.id},principalAccountObj);

        principalParty.Dealer_Applicant_Relationship__c=dealerCoAppRel.id;
        Database.insert(principalParty,true);

        Map<String,Object> requestMap = new Map<String,Object>();

        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Id'=> principalAccountObj.id
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'Id'=> principalAccountObj.genesis__Business_Information__c
        };
        
        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed'); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description adding the wrong json format to get an exception
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testApiException(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();

        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Phone'=> '1111111111',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'clcommon__Email__c'=> 'ajeet_raj@yopmail.com',
            'Billing_County__c'=> 'Orange County',
            'BillingPostalCode'=> '32824',
            'BillingState'=> 'FL',
            'BillingCity'=> 'Orlando',
            'BillingStreet'=> '12340 Boggy Creek Road',
            'Year_Began_Farming__c'=> '2024'
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'genesis__Total_Assets__c'=> 18738970,
            'genesis__Total_Liabilities__c'=> 10,
            'Gross_Farm_Income__c'=> 20000
        };
        Map<String,Object> coApplicantContactMap=new Map<String,Object>{
            'Birthdate'=> '1985-12-12',
            'MobilePhone'=> '1111111111',
            'Confirm_SSN__c'=> '878737654',
            'genesis__SSN__c'=> '878737654',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'Email'=> 'ajeet_raj@yopmail.com',
            'FirstName'=> 'Ajeet',
            'LastName'=> 'Raj',
            'Mailing_County__c'=> 'Orange County',
            'MailingPostalCode'=> '32824',
            'MailingState'=> 'FL',
            'MailingCity'=> 'Orlando',
            'MailingStreet'=> '12340 Boggy Creek Road',
            'clcommon__Marital_Status__c'=> 'Married',
            'Title'=> 'Co-Applicant'
        };

        List<Map<String,Object>> coApplicantContactMapList=new List<Map<String,Object>>{coApplicantContactMap};

        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));
        requestMap.put('coApplicantContact', JSON.serialize(coApplicantContactMapList));
        requestMap.put('saveType', 'SaveAndContinue');

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed'); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description not sending the name to get an exception
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testMissingName(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();

        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Phone'=> '1111111111',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'clcommon__Email__c'=> 'ajeet_raj@yopmail.com',
            'Billing_County__c'=> 'Orange County',
            'BillingPostalCode'=> '32824',
            'BillingState'=> 'FL',
            'BillingCity'=> 'Orlando',
            'BillingStreet'=> '12340 Boggy Creek Road',
            'Year_Began_Farming__c'=> '2024'
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'genesis__Total_Assets__c'=> 18738970,
            'genesis__Total_Liabilities__c'=> 10,
            'Gross_Farm_Income__c'=> 20000
        };
        Map<String,Object> coApplicantContactMap=new Map<String,Object>{
            'Birthdate'=> '1985-12-12',
            'MobilePhone'=> '1111111111',
            'Confirm_SSN__c'=> '878737654',
            'genesis__SSN__c'=> '878737654',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'Email'=> 'ajeet_raj@yopmail.com',
            'FirstName'=> 'Ajeet',
            'Mailing_County__c'=> 'Orange County',
            'MailingPostalCode'=> '32824',
            'MailingState'=> 'FL',
            'MailingCity'=> 'Orlando',
            'MailingStreet'=> '12340 Boggy Creek Road',
            'clcommon__Marital_Status__c'=> 'Married',
            'Title'=> 'Co-Applicant'
        };

        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));
        requestMap.put('coApplicantContact', JSON.serialize(coApplicantContactMap));
        requestMap.put('saveType', 'SaveAndContinue');

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed'); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description the response does not contain the ssn for the coApplicant to get an exception
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testMissingSSN(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();

        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Phone'=> '1111111111',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'clcommon__Email__c'=> 'ajeet_raj@yopmail.com',
            'Billing_County__c'=> 'Orange County',
            'BillingPostalCode'=> '32824',
            'BillingState'=> 'FL',
            'BillingCity'=> 'Orlando',
            'BillingStreet'=> '12340 Boggy Creek Road',
            'Year_Began_Farming__c'=> '2024'
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'genesis__Total_Assets__c'=> 18738970,
            'genesis__Total_Liabilities__c'=> 10,
            'Gross_Farm_Income__c'=> 20000
        };
        Map<String,Object> coApplicantContactMap=new Map<String,Object>{
            'Birthdate'=> '1985-12-12',
            'MobilePhone'=> '1111111111',
            'Confirm_SSN__c'=> '878737654',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'Email'=> 'ajeet_raj@yopmail.com',
            'FirstName'=> 'Ajeet',
            'LastName'=> 'Raj',
            'Mailing_County__c'=> 'Orange County',
            'MailingPostalCode'=> '32824',
            'MailingState'=> 'FL',
            'MailingCity'=> 'Orlando',
            'MailingStreet'=> '12340 Boggy Creek Road',
            'clcommon__Marital_Status__c'=> 'Married',
            'Title'=> 'Co-Applicant'
        };

        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));
        requestMap.put('coApplicantContact', JSON.serialize(coApplicantContactMap));
        requestMap.put('saveType', 'SaveAndContinue');

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed'); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description the response does not containt the confirm ssn to get an exception
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testMissingConfirmSSN(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();
        
        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Phone'=> '1111111111',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'clcommon__Email__c'=> 'ajeet_raj@yopmail.com',
            'Billing_County__c'=> 'Orange County',
            'BillingPostalCode'=> '32824',
            'BillingState'=> 'FL',
            'BillingCity'=> 'Orlando',
            'BillingStreet'=> '12340 Boggy Creek Road',
            'Year_Began_Farming__c'=> '2024'
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'genesis__Total_Assets__c'=> 18738970,
            'genesis__Total_Liabilities__c'=> 10,
            'Gross_Farm_Income__c'=> 20000
        };
        Map<String,Object> coApplicantContactMap=new Map<String,Object>{
            'Birthdate'=> '1985-12-12',
            'MobilePhone'=> '1111111111',
            'genesis__SSN__c'=> '878737654',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'Email'=> 'ajeet_raj@yopmail.com',
            'FirstName'=> 'Ajeet',
            'LastName'=> 'Raj',
            'Mailing_County__c'=> 'Orange County',
            'MailingPostalCode'=> '32824',
            'MailingState'=> 'FL',
            'MailingCity'=> 'Orlando',
            'MailingStreet'=> '12340 Boggy Creek Road',
            'clcommon__Marital_Status__c'=> 'Married',
            'Title'=> 'Co-Applicant'
        };

        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));
        requestMap.put('coApplicantContact', JSON.serialize(coApplicantContactMap));
        requestMap.put('saveType', 'SaveAndContinue');

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed'); 
                Test.stopTest();
            }
        }
    }
    /**
    * @description the response does not contain the first name of the coApplicant
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testMissingFirstName(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();

        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Phone'=> '1111111111',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'clcommon__Email__c'=> 'ajeet_raj@yopmail.com',
            'Billing_County__c'=> 'Orange County',
            'BillingPostalCode'=> '32824',
            'BillingState'=> 'FL',
            'BillingCity'=> 'Orlando',
            'BillingStreet'=> '12340 Boggy Creek Road',
            'Year_Began_Farming__c'=> '2024'
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'genesis__Total_Assets__c'=> 18738970,
            'genesis__Total_Liabilities__c'=> 10,
            'Gross_Farm_Income__c'=> 20000
        };
        Map<String,Object> coApplicantContactMap=new Map<String,Object>{
            'Birthdate'=> '1985-12-12',
            'MobilePhone'=> '1111111111',
            'genesis__SSN__c'=> '878737654',
            'Confirm_SSN__c'=> '878737654',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'Email'=> 'ajeet_raj@yopmail.com',
            'LastName'=> 'Raj',
            'Mailing_County__c'=> 'Orange County',
            'MailingPostalCode'=> '32824',
            'MailingState'=> 'FL',
            'MailingCity'=> 'Orlando',
            'MailingStreet'=> '12340 Boggy Creek Road',
            'clcommon__Marital_Status__c'=> 'Married',
            'Title'=> 'Co-Applicant'
        };

        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));
        requestMap.put('coApplicantContact', JSON.serialize(coApplicantContactMap));
        requestMap.put('saveType', 'SaveAndContinue');

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed'); 
                Test.stopTest();
            }
        }
    }
    /**
    * @description the response does not contain the mailing street for the coapplicant to get an exception
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testMissingMailingStreet(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();
        
        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Phone'=> '1111111111',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'clcommon__Email__c'=> 'ajeet_raj@yopmail.com',
            'Billing_County__c'=> 'Orange County',
            'BillingPostalCode'=> '32824',
            'BillingState'=> 'FL',
            'BillingCity'=> 'Orlando',
            'BillingStreet'=> '12340 Boggy Creek Road',
            'Year_Began_Farming__c'=> '2024'
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'genesis__Total_Assets__c'=> 18738970,
            'genesis__Total_Liabilities__c'=> 10,
            'Gross_Farm_Income__c'=> 20000
        };
        Map<String,Object> coApplicantContactMap=new Map<String,Object>{
            'Birthdate'=> '1985-12-12',
            'MobilePhone'=> '1111111111',
            'genesis__SSN__c'=> '878737654',
            'Confirm_SSN__c'=> '878737654',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'Email'=> 'ajeet_raj@yopmail.com',
            'FirstName'=> 'Ajeet',
            'LastName'=> 'Raj',
            'Mailing_County__c'=> 'Orange County',
            'MailingPostalCode'=> '32824',
            'MailingState'=> 'FL',
            'MailingCity'=> 'Orlando',
            'clcommon__Marital_Status__c'=> 'Married',
            'Title'=> 'Co-Applicant'
        };

        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));
        requestMap.put('coApplicantContact', JSON.serialize(coApplicantContactMap));
        requestMap.put('saveType', 'SaveAndContinue');

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed'); 
                Test.stopTest();
            }
        }
    }
    /**
    * @description the response does not contain the mailing state for the coapplicant to get an exception
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testMissingState(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();
        
        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Phone'=> '1111111111',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'clcommon__Email__c'=> 'ajeet_raj@yopmail.com',
            'Billing_County__c'=> 'Orange County',
            'BillingPostalCode'=> '32824',
            'BillingState'=> 'FL',
            'BillingCity'=> 'Orlando',
            'BillingStreet'=> '12340 Boggy Creek Road',
            'Year_Began_Farming__c'=> '2024'
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'genesis__Total_Assets__c'=> 18738970,
            'genesis__Total_Liabilities__c'=> 10,
            'Gross_Farm_Income__c'=> 20000
        };
        Map<String,Object> coApplicantContactMap=new Map<String,Object>{
            'Birthdate'=> '1985-12-12',
            'MobilePhone'=> '1111111111',
            'genesis__SSN__c'=> '878737654',
            'Confirm_SSN__c'=> '878737654',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'Email'=> 'ajeet_raj@yopmail.com',
            'FirstName'=> 'Ajeet',
            'LastName'=> 'Raj',
            'Mailing_County__c'=> 'Orange County',
            'MailingPostalCode'=> '32824',
            'MailingCity'=> 'Orlando',
            'MailingStreet'=> '12340 Boggy Creek Road',
            'clcommon__Marital_Status__c'=> 'Married',
            'Title'=> 'Co-Applicant'
        };

        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));
        requestMap.put('coApplicantContact', JSON.serialize(coApplicantContactMap));
        requestMap.put('saveType', 'SaveAndContinue');

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed'); 
                Test.stopTest();
            }
        }
    }
    /**
    * @description the response does not contain the mailing city for the coapplicant to get an exception
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testMissingMailingCity(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();
        
        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Phone'=> '1111111111',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'clcommon__Email__c'=> 'ajeet_raj@yopmail.com',
            'Billing_County__c'=> 'Orange County',
            'BillingPostalCode'=> '32824',
            'BillingState'=> 'FL',
            'BillingCity'=> 'Orlando',
            'BillingStreet'=> '12340 Boggy Creek Road',
            'Year_Began_Farming__c'=> '2024'
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'genesis__Total_Assets__c'=> 18738970,
            'genesis__Total_Liabilities__c'=> 10,
            'Gross_Farm_Income__c'=> 20000
        };
        Map<String,Object> coApplicantContactMap=new Map<String,Object>{
            'Birthdate'=> '1985-12-12',
            'MobilePhone'=> '1111111111',
            'genesis__SSN__c'=> '878737654',
            'Confirm_SSN__c'=> '878737654',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'Email'=> 'ajeet_raj@yopmail.com',
            'FirstName'=> 'Ajeet',
            'LastName'=> 'Raj',
            'Mailing_County__c'=> 'Orange County',
            'MailingPostalCode'=> '32824',
            'MailingState'=> 'FL',
            'MailingStreet'=> '12340 Boggy Creek Road',
            'clcommon__Marital_Status__c'=> 'Married',
            'Title'=> 'Co-Applicant'
        };

        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));
        requestMap.put('coApplicantContact', JSON.serialize(coApplicantContactMap));
        requestMap.put('saveType', 'SaveAndContinue');

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed'); 
                Test.stopTest();
            }
        }
    }
    /**
    * @description the response does not contain the mailing county for the coapplicant to get an exception
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testMissignMailingCounty(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();

        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Phone'=> '1111111111',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'clcommon__Email__c'=> 'ajeet_raj@yopmail.com',
            'Billing_County__c'=> 'Orange County',
            'BillingPostalCode'=> '32824',
            'BillingState'=> 'FL',
            'BillingCity'=> 'Orlando',
            'BillingStreet'=> '12340 Boggy Creek Road',
            'Year_Began_Farming__c'=> '2024'
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'genesis__Total_Assets__c'=> 18738970,
            'genesis__Total_Liabilities__c'=> 10,
            'Gross_Farm_Income__c'=> 20000
        };
        Map<String,Object> coApplicantContactMap=new Map<String,Object>{
            'Birthdate'=> '1985-12-12',
            'MobilePhone'=> '1111111111',
            'genesis__SSN__c'=> '878737654',
            'Confirm_SSN__c'=> '878737654',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'Email'=> 'ajeet_raj@yopmail.com',
            'FirstName'=> 'Ajeet',
            'LastName'=> 'Raj',
            'MailingPostalCode'=> '32824',
            'MailingState'=> 'FL',
            'MailingCity'=> 'Orlando',
            'MailingStreet'=> '12340 Boggy Creek Road',
            'clcommon__Marital_Status__c'=> 'Married',
            'Title'=> 'Co-Applicant'
        };

        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));
        requestMap.put('coApplicantContact', JSON.serialize(coApplicantContactMap));
        requestMap.put('saveType', 'SaveAndContinue');

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed'); 
                Test.stopTest();
            }
        }
    }
    /**
    * @description the response does not contain the mailing postal code for the coapplicant to get an exception
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testMissingPostalCode(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();

        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Phone'=> '1111111111',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'clcommon__Email__c'=> 'ajeet_raj@yopmail.com',
            'Billing_County__c'=> 'Orange County',
            'BillingPostalCode'=> '32824',
            'BillingState'=> 'FL',
            'BillingCity'=> 'Orlando',
            'BillingStreet'=> '12340 Boggy Creek Road',
            'Year_Began_Farming__c'=> '2024'
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'genesis__Total_Assets__c'=> 18738970,
            'genesis__Total_Liabilities__c'=> 10,
            'Gross_Farm_Income__c'=> 20000
        };
        Map<String,Object> coApplicantContactMap=new Map<String,Object>{
            'Birthdate'=> '1985-12-12',
            'MobilePhone'=> '1111111111',
            'genesis__SSN__c'=> '878737654',
            'Confirm_SSN__c'=> '878737654',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'Email'=> 'ajeet_raj@yopmail.com',
            'FirstName'=> 'Ajeet',
            'LastName'=> 'Raj',
            'Mailing_County__c'=> 'Orange County',
            'MailingState'=> 'FL',
            'MailingCity'=> 'Orlando',
            'MailingStreet'=> '12340 Boggy Creek Road',
            'clcommon__Marital_Status__c'=> 'Married',
            'Title'=> 'Co-Applicant'
        };

        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));
        requestMap.put('coApplicantContact', JSON.serialize(coApplicantContactMap));
        requestMap.put('saveType', 'SaveAndContinue');

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed'); 
                Test.stopTest();
            }
        }
    }
    /**
    * @description the response contains the incorrect postal code for the coapplicant to get an exception
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testInvalidPostalCode(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();

        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Phone'=> '1111111111',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'clcommon__Email__c'=> 'ajeet_raj@yopmail.com',
            'Billing_County__c'=> 'Orange County',
            'BillingPostalCode'=> '32824',
            'BillingState'=> 'FL',
            'BillingCity'=> 'Orlando',
            'BillingStreet'=> '12340 Boggy Creek Road',
            'Year_Began_Farming__c'=> '2024'
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'genesis__Total_Assets__c'=> 18738970,
            'genesis__Total_Liabilities__c'=> 10,
            'Gross_Farm_Income__c'=> 20000
        };
        Map<String,Object> coApplicantContactMap=new Map<String,Object>{
            'Birthdate'=> '1985-12-12',
            'MobilePhone'=> '1111111111',
            'genesis__SSN__c'=> '878737654',
            'Confirm_SSN__c'=> '878737654',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'Email'=> 'ajeet_raj@yopmail.com',
            'FirstName'=> 'Ajeet',
            'LastName'=> 'Raj',
            'Mailing_County__c'=> 'Orange County',
            'MailingPostalCode'=> '3282475',
            'MailingState'=> 'FL',
            'MailingCity'=> 'Orlando',
            'MailingStreet'=> '12340 Boggy Creek Road',
            'clcommon__Marital_Status__c'=> 'Married',
            'Title'=> 'Co-Applicant'
        };

        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));
        requestMap.put('coApplicantContact', JSON.serialize(coApplicantContactMap));
        requestMap.put('saveType', 'SaveAndContinue');

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed'); 
                Test.stopTest();
            }
        }
    }
    /**
    * @description the response does not contain the birth date for the coapplicant to get an exception
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testMissingBirthDate(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();

        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Phone'=> '1111111111',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'clcommon__Email__c'=> 'ajeet_raj@yopmail.com',
            'Billing_County__c'=> 'Orange County',
            'BillingPostalCode'=> '32824',
            'BillingState'=> 'FL',
            'BillingCity'=> 'Orlando',
            'BillingStreet'=> '12340 Boggy Creek Road',
            'Year_Began_Farming__c'=> '2024'
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'genesis__Total_Assets__c'=> 18738970,
            'genesis__Total_Liabilities__c'=> 10,
            'Gross_Farm_Income__c'=> 20000
        };
        Map<String,Object> coApplicantContactMap=new Map<String,Object>{
            'MobilePhone'=> '1111111111',
            'genesis__SSN__c'=> '878737654',
            'Confirm_SSN__c'=> '878737654',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'Email'=> 'ajeet_raj@yopmail.com',
            'FirstName'=> 'Ajeet',
            'LastName'=> 'Raj',
            'Mailing_County__c'=> 'Orange County',
            'MailingPostalCode'=> '32824',
            'MailingState'=> 'FL',
            'MailingCity'=> 'Orlando',
            'MailingStreet'=> '12340 Boggy Creek Road',
            'clcommon__Marital_Status__c'=> 'Married',
            'Title'=> 'Co-Applicant'
        };

        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));
        requestMap.put('coApplicantContact', JSON.serialize(coApplicantContactMap));
        requestMap.put('saveType', 'SaveAndContinue');

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed'); 
                Test.stopTest();
            }
        }
    }
    /**
    * @description the response contains a negative total asset for the coapplicant to get an exception
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testNegativeTotalAsset(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();

        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Phone'=> '1111111111',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'clcommon__Email__c'=> 'ajeet_raj@yopmail.com',
            'Billing_County__c'=> 'Orange County',
            'BillingPostalCode'=> '32824',
            'BillingState'=> 'FL',
            'BillingCity'=> 'Orlando',
            'BillingStreet'=> '12340 Boggy Creek Road',
            'Year_Began_Farming__c'=> '2024'
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'genesis__Total_Assets__c'=> -18738970,
            'genesis__Total_Liabilities__c'=> 10,
            'Gross_Farm_Income__c'=> 20000
        };
        Map<String,Object> coApplicantContactMap=new Map<String,Object>{
            'Birthdate'=> '1985-12-12',
            'MobilePhone'=> '1111111111',
            'genesis__SSN__c'=> '878737654',
            'Confirm_SSN__c'=> '878737654',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'Email'=> 'ajeet_raj@yopmail.com',
            'FirstName'=> 'Ajeet',
            'LastName'=> 'Raj',
            'Mailing_County__c'=> 'Orange County',
            'MailingPostalCode'=> '32824',
            'MailingState'=> 'FL',
            'MailingCity'=> 'Orlando',
            'MailingStreet'=> '12340 Boggy Creek Road',
            'clcommon__Marital_Status__c'=> 'Married',
            'Title'=> 'Co-Applicant'
        };

        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));
        requestMap.put('coApplicantContact', JSON.serialize(coApplicantContactMap));
        requestMap.put('saveType', 'SaveAndContinue');

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed'); 
                Test.stopTest();
            }
        }
    }
    /**
    * @description the response contains negative total liabilites for the coapplicant to get an exception
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testNegativeTotalLiabilities(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();

        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Phone'=> '1111111111',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'clcommon__Email__c'=> 'ajeet_raj@yopmail.com',
            'Billing_County__c'=> 'Orange County',
            'BillingPostalCode'=> '32824',
            'BillingState'=> 'FL',
            'BillingCity'=> 'Orlando',
            'BillingStreet'=> '12340 Boggy Creek Road',
            'Year_Began_Farming__c'=> '2024'
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'genesis__Total_Assets__c'=> 18738970,
            'genesis__Total_Liabilities__c'=> -10,
            'Gross_Farm_Income__c'=> 20000
        };
        Map<String,Object> coApplicantContactMap=new Map<String,Object>{
            'Birthdate'=> '1985-12-12',
            'MobilePhone'=> '1111111111',
            'genesis__SSN__c'=> '878737654',
            'Confirm_SSN__c'=> '878737654',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'Email'=> 'ajeet_raj@yopmail.com',
            'FirstName'=> 'Ajeet',
            'LastName'=> 'Raj',
            'Mailing_County__c'=> 'Orange County',
            'MailingPostalCode'=> '32824',
            'MailingState'=> 'FL',
            'MailingCity'=> 'Orlando',
            'MailingStreet'=> '12340 Boggy Creek Road',
            'clcommon__Marital_Status__c'=> 'Married',
            'Title'=> 'Co-Applicant'
        };

        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));
        requestMap.put('coApplicantContact', JSON.serialize(coApplicantContactMap));
        requestMap.put('saveType', 'SaveAndContinue');

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed'); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description the response does not contain the numbers for the coapplicant to get an exception
    * @author Rakesh Saraf | 12-03-2024 
    **/
    @isTest
    public static void testMissingNumber(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c applicationObj = [SELECT Id
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();

        Map<String,Object> coApplicantAccountMap=new Map<String,Object>{
            'Phone'=> '1111111111',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'clcommon__Email__c'=> 'ajeet_raj@yopmail.com',
            'Billing_County__c'=> 'Orange County',
            'BillingPostalCode'=> '32824',
            'BillingState'=> 'FL',
            'BillingCity'=> 'Orlando',
            'BillingStreet'=> '12340 Boggy Creek Road',
            'Year_Began_Farming__c'=> '2024'
        };
        Map<String,Object> coApplicantBusinessMap=new Map<String,Object>{
            'genesis__Total_Assets__c'=> 18738970,
            'genesis__Total_Liabilities__c'=> 10,
            'Gross_Farm_Income__c'=> 20000
        };
        Map<String,Object> coApplicantContactMap=new Map<String,Object>{
            'Birthdate'=> '1985-12-12',
            'genesis__SSN__c'=> '878737654',
            'Confirm_SSN__c'=> '878737654',
            'Confirm_Email__c'=> 'ajeet_raj@yopmail.com',
            'Email'=> 'ajeet_raj@yopmail.com',
            'FirstName'=> 'Ajeet',
            'LastName'=> 'Raj',
            'Mailing_County__c'=> 'Orange County',
            'MailingPostalCode'=> '32824',
            'MailingState'=> 'FL',
            'MailingCity'=> 'Orlando',
            'MailingStreet'=> '12340 Boggy Creek Road',
            'clcommon__Marital_Status__c'=> 'Married',
            'Title'=> 'Co-Applicant'
        };

        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('coApplicantAccount', JSON.serialize(coApplicantAccountMap));
        requestMap.put('coApplicantBusiness', JSON.serialize(coApplicantBusinessMap));
        requestMap.put('coApplicantContact', JSON.serialize(coApplicantContactMap));
        requestMap.put('saveType', 'SaveAndContinue');

        if(userObj!= null){
            System.runAs(userObj){
                Test.startTest();
                PortalSaveCoApplicantAPI apiObj = new PortalSaveCoApplicantAPI();
                clcommon.Response response = apiObj.invokeAction(null, null, requestMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed'); 
                Test.stopTest();
            }
        }
    }
}