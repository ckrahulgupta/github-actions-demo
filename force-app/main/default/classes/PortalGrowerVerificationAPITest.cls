/**
 * @description       : Test class for PortalGrowerVerificationAPI
 * @author            : Ravi Ranjan
 * @group             : 
 * @last modified on  : 14-01-2025
 * @last modified by  : Soumik Pattanayak
**/
@isTest
private with sharing class PortalGrowerVerificationAPITest {
    @TestSetup
    static void setup(){
        genesis__Business_Information__c businessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoObj,true);
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoObj.id);
        Database.insert(dealerAccountObj,true);
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProduct();
        Database.insert(clProductObj,true);
        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(legalEntityObj,true);
        
        clcommon__Legal_Entity__c corpLegalEntityObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(corpLegalEntityObj,true);
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId();
        Database.insert(borrowerAccountObj,true);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        Database.insert(borrowerContactObj,true);
        Account accountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(businessInfoObj.id,dealerAccountObj.id);
        Database.insert(accountObj,true);
        Contact contactObj = ApplicationOriginationTestHelper.createSalesAgentContact(accountObj.id);
        Database.insert(contactObj,true);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInfoObj.id,dealerAccountObj.id);
        Database.insert(clAccountObj,true);
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
        Database.insert(clContactObj,true);
         // creating user for certified lender
        User clUser = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        Database.insert(clUser, true);
        User saUser = ApplicationOriginationTestHelper.createSalesAgentUser(contactObj.Id);
        Database.insert(saUser, true);
        genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(coBorrowerBusinessInfoObj,true);
        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(legalEntityObj,coBorrowerBusinessInfoObj.id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.CO_APPLICATION_RECORD_TYPE).getRecordTypeId();
        Database.insert(coBorrowerAccountObj,true);
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        Database.insert(coBorrowerContactObj,true);

        Map<String,Object> applicationDataMap = new Map<String,Object>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'saAccountObjId' => accountObj.id
        };
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(applicationDataMap);
        applicationObj.Certified_Lender__c = clAccountObj.id;
        Database.upsert(applicationObj,true); 
        
        clcommon__Party_Type__c clParty = ApplicationOriginationTestHelper.createPartyType(PortalConstants.CERTIFIED_LENDER);
        //Create Party
        Map<String,Id> partyDataMap =new Map<String,Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clParty.Id,
            'applicationId' => applicationObj.Id

        };
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(partyDataMap);
        partyObj.clcommon__Party_Types__c = PortalConstants.GROWER_PROFILE;
        Database.upsert(partyObj,true);
        //principal party type
        clcommon__Party_Type__c prPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.PRINCIPAL_PARTY_NAME);
        Database.insert(prPartyTypeObj,true);
        Map<String,Id> principalPartyParamMap = new Map<String,Id>{
            'accountId' => coBorrowerAccountObj.id,
            'contactId' => coBorrowerContactObj.id,
            'partyTypeId' => prPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createParty(principalPartyParamMap);
        Database.insert(principalPartyObj,true);
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 08-01-2025 
    * @return Account 
    **/
    private static Account getGrowerAccount(){
        return [SELECT Id, 
                        Name, 
                        clcommon__Email__c, 
                        clcommon__Legal_Entity_Type__c,
                        clcommon__Legal_Entity_Type__r.Name
                FROM Account 
                WHERE clcommon__Email__c = 'jasmin.albin@yopmail.com'][0];
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 08-01-2025 
    * @return Contact 
    **/
    private static Contact getGrowerContact(){
        return [SELECT FirstName, 
                            LastName, 
                            Email,
                            genesis__SSN__c 
                FROM Contact 
                WHERE genesis__SSN__c = 'GHFB6766'][0];
    }

    /**
    * @description : Success Scenario for CFA Coop Type
    * @author Ravi Ranjan | 03-21-2024 
    **/
    @isTest
    private static void testSolePropGrowerVerification(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Account accObj = getGrowerAccount();
        accObj.Coop_Type__c = PortalConstants.CFA_COOP_TYPE;
        Database.update(accObj);
        Contact contactObj = getGrowerContact();
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            PortalConstants.EMAIL_KEY => contactObj.Email,
            'ssn' => contactObj.genesis__SSN__c
        };
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowerVerificationAPI obj = new PortalGrowerVerificationAPI();
                clcommon.Response response = obj.invokeAction(componentStrName, disclosureNames, argumentsFromPortal);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description : testing for a grower with long username
    * @author Ravi Ranjan | 03-21-2024 
    **/
   @isTest
   private static void testSolePropWithLongUsername(){
       User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
       Account accObj = getGrowerAccount();
       accObj.Coop_Type__c = PortalConstants.CFA_COOP_TYPE;
       Database.update(accObj);
       Contact contactObj = getGrowerContact();
        contactObj.LastName = 'Vjrigubangshi';
        Database.update(contactObj, true);
                   
       String componentStrName = 'TestComponent';
       String[] disclosureNames = new String[]{'TestDisclosure'};
       Map<String, Object> argumentsFromPortal = new Map<String, Object>{
           PortalConstants.EMAIL_KEY => contactObj.Email,
           'ssn' => contactObj.genesis__SSN__c
       };
       if(certifiedLenderUserObj != null){
           System.runAs(certifiedLenderUserObj){
            Test.startTest();
               PortalGrowerVerificationAPI obj = new PortalGrowerVerificationAPI();
               clcommon.Response response = obj.invokeAction(componentStrName, disclosureNames, argumentsFromPortal);
               System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
               Test.stopTest();
            }
        }
    }
    /**
    * @description : Success Scenario for Corporation Type
    * @author Ravi Ranjan | 03-21-2024 
    **/
    @isTest
    private static void testCorporationGrowerVerification(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Account accObj = getGrowerAccount();
        accObj.Coop_Type__c = PortalConstants.CFA_COOP_TYPE;
        accObj.clcommon__Legal_Entity_Type__r.Name = PortalConstants.CORPORATION;
        Database.update(accObj);
        List<Account> coBorrowerAccList = [SELECT Id, 
                                            Name, 
                                            clcommon__Email__c, 
                                            clcommon__Legal_Entity_Type__r.Name 
                                    FROM Account 
                                    WHERE clcommon__Email__c = 'mike.johnson@yopmail.com'];
        coBorrowerAccList[0].Coop_Type__c = PortalConstants.CFA_COOP_TYPE;
        Database.update(coBorrowerAccList);
        List<Contact> coBorrowerContactList = [SELECT FirstName, 
                                            LastName, 
                                            Email,
                                            genesis__SSN__c 
                                        FROM Contact 
                                        WHERE Email = 'mike.johnson@yopmail.com'];
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            PortalConstants.EMAIL_KEY => coBorrowerContactList[0].Email,
            'ssn' => coBorrowerContactList[0].genesis__SSN__c
        };
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowerVerificationAPI obj = new PortalGrowerVerificationAPI();
                clcommon.Response response = obj.invokeAction(componentStrName, disclosureNames, argumentsFromPortal);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }
    /**
    * @description Success Scenario for DBA Type
    * @author Ravi Ranjan | 03-21-2024 
    **/
    @isTest
    private static void testDBAGrowerVerification(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Account accObj = getGrowerAccount();
        accObj.Coop_Type__c = PortalConstants.CFA_COOP_TYPE;
        accObj.clcommon__Legal_Entity_Type__r.Name = PortalConstants.INDIVIDUAL_ENTITY;
        Database.update(accObj);
        List<Account> coBorrowerAccList = [SELECT Id, 
                                            Name, 
                                            clcommon__Email__c, 
                                            clcommon__Legal_Entity_Type__r.Name 
                                    FROM Account 
                                    WHERE clcommon__Email__c = 'mike.johnson@yopmail.com'];
        coBorrowerAccList[0].Coop_Type__c = PortalConstants.CFA_COOP_TYPE;
        Database.update(coBorrowerAccList);
        List<Contact> coBorrowerContactList = [SELECT FirstName, 
                                            LastName, 
                                            Email,
                                            genesis__SSN__c 
                                        FROM Contact 
                                        WHERE Email = 'mike.johnson@yopmail.com'];
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            PortalConstants.EMAIL_KEY => coBorrowerContactList[0].Email,
            'ssn' => coBorrowerContactList[0].genesis__SSN__c
        };
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowerVerificationAPI obj = new PortalGrowerVerificationAPI();
                clcommon.Response response = obj.invokeAction(componentStrName, disclosureNames, argumentsFromPortal);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }
    /**
    * @description : Success Scenario for Landus Coop Type
    * @author Ravi Ranjan | 03-21-2024 
    **/
    @isTest
    private static void testLandusGrowerVerification(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Account accObj = getGrowerAccount();
        accObj.Coop_Type__c = PortalConstants.LANDUS_COOP_TYPE;
        Database.update(accObj);
        Contact contactObj = getGrowerContact();
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            PortalConstants.EMAIL_KEY => contactObj.Email,
            'ssn' => contactObj.genesis__SSN__c
        };
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowerVerificationAPI obj = new PortalGrowerVerificationAPI();
                clcommon.Response response = obj.invokeAction(componentStrName, disclosureNames, argumentsFromPortal);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }
    /**
    * @description Check when grower have already a user
    * @author Ravi Ranjan | 03-21-2024 
    **/
    @isTest
    private static void checkForGrowerHavingUser(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Account accObj = getGrowerAccount();
        accObj.Coop_Type__c = PortalConstants.LANDUS_COOP_TYPE;
        Database.update(accObj);
        Contact contactObj = getGrowerContact();
        User growerUser = ApplicationOriginationTestHelper.createBorrowerUser(contactObj.Id);
        Database.insert(growerUser, true);
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            PortalConstants.EMAIL_KEY => contactObj.Email,
            'ssn' => contactObj.genesis__SSN__c
        };
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowerVerificationAPI obj = new PortalGrowerVerificationAPI();
                clcommon.Response response = obj.invokeAction(componentStrName, disclosureNames, argumentsFromPortal);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }
    /**
    * @description Check when coop type is equal to null
    * @author Ravi Ranjan | 03-21-2024 
    **/
    @isTest
    private static void checkForNullCoopType(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Account accObj = getGrowerAccount();
        accObj.Coop_Type__c = null;
        Database.update(accObj);
        Contact contactObj = getGrowerContact();
        User growerUser = ApplicationOriginationTestHelper.createBorrowerUser(contactObj.Id);
        Database.insert(growerUser, true);
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            PortalConstants.EMAIL_KEY => contactObj.Email,
            'ssn' => contactObj.genesis__SSN__c
        };
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowerVerificationAPI obj = new PortalGrowerVerificationAPI();
                clcommon.Response response = obj.invokeAction(componentStrName, disclosureNames, argumentsFromPortal);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }
    /**
    * @description check exception if grower's contact email is null
    * @author Ravi Ranjan | 03-21-2024 
    **/
    @isTest
    private static void checkExceptionForGrowerNullEmail(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Account accObj = getGrowerAccount();
        accObj.Coop_Type__c = PortalConstants.CFA_COOP_TYPE;
        Database.update(accObj);
        Contact contactObj = getGrowerContact();
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'emailId' => null,
            'ssn' => contactObj.genesis__SSN__c
        };
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowerVerificationAPI obj = new PortalGrowerVerificationAPI();
                clcommon.Response response = obj.invokeAction(componentStrName, disclosureNames, argumentsFromPortal);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }
    /**
    * @description check exception if grower's ssn is null
    * @author Ravi Ranjan | 03-21-2024 
    **/
    @isTest
    private static void checkExceptionForGrowerNullSSN(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Account accObj = getGrowerAccount();
        accObj.Coop_Type__c = PortalConstants.CFA_COOP_TYPE;
        Database.update(accObj);
        Contact contactObj = getGrowerContact();
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'emailId' => contactObj.Email,
            'ssn' => null
        };
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowerVerificationAPI obj = new PortalGrowerVerificationAPI();
                clcommon.Response response = obj.invokeAction(componentStrName, disclosureNames, argumentsFromPortal);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description Check exception when arguments from portal is null
    * @author Ravi Ranjan | 03-21-2024 
    **/
    @isTest
    private static void checkException(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowerVerificationAPI obj = new PortalGrowerVerificationAPI();
                clcommon.Response response = obj.invokeAction(componentStrName, disclosureNames, null);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }
}