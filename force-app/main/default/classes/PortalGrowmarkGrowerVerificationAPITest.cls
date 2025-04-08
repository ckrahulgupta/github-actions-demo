/**
 * @description       : This is the test class for PortalGrowmarkGrowerVerificationAPI
 * @author            : Ravi Ranjan
 * @group             : 
 * @last modified on  : 01-15-2025
 * @last modified by  : Rahul Gorai
**/
@isTest
private with sharing class PortalGrowmarkGrowerVerificationAPITest {
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
        Account accountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(businessInfoObj.id,dealerAccountObj.id);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInfoObj.id,dealerAccountObj.id);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId();
        Database.insert(new List<Account>{borrowerAccountObj,accountObj,clAccountObj},true);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        Contact contactObj = ApplicationOriginationTestHelper.createSalesAgentContact(accountObj.id);
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
        Database.insert(new List<Contact>{clContactObj,borrowerContactObj,contactObj},true);
        // creating user 
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        User saUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(contactObj.Id);
        Database.insert(new List<User>{clUserObj,saUserObj},true);
        
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
        
        clcommon__Party_Type__c clPartyObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.CERTIFIED_LENDER);
        //Create Party
        Map<String,Id> partyDataMap =new Map<String,Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clPartyObj.Id,
            'applicationId' => applicationObj.Id

        };
        clcommon__Party__c partyObj= ApplicationOriginationTestHelper.createParty(partyDataMap);
        partyObj.clcommon__Party_Types__c=PortalConstants.GROWER_PROFILE;
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
    * @description Return list of grower's account
    * @author Soumik Pattanayak | 08-01-2025 
    * @return Account 
    **/
    private static List<Account> getGrowerAccountList(){
        return [SELECT Id, 
                        Name, 
                        clcommon__Email__c, 
                        clcommon__Legal_Entity_Type__c,
                        clcommon__Legal_Entity_Type__r.Name
                FROM Account 
                WHERE clcommon__Email__c = 'jasmin.albin@yopmail.com'];
    }

    /**
    * @description Return list of grower's contact
    * @author Soumik Pattanayak | 08-01-2025 
    * @return Contact 
    **/
    private static List<Contact> getGrowerContactList(){
        return [SELECT FirstName, 
                            LastName, 
                            Email,
                            genesis__SSN__c,
                            Account.Coop_Type__c
                FROM Contact 
                WHERE genesis__SSN__c = 'GHFB6766'];
    }
    /**
    * @description Creates a map of arguments with email and SSN as keys
    * @author Rahul Gorai | 01-14-2025 
    * @param email 
    * @param ssn 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getArgumentsMap(String email, String ssn) {
        Map<String, Object> argumentsMap = new Map<String, Object>();
        if (email != null) {
            argumentsMap.put('email', email);
        }
        if (ssn != null) {
            argumentsMap.put('ssn', ssn);
        }
        return argumentsMap;
    }
    /**
    * @description Test Success scenario for Sole prop
    * @author Ravi Ranjan | 03-21-2024 
    **/
    @isTest
    private static void testSolePropGrowmarkGrowerVerification(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accList = getGrowerAccountList();
        accList[0].Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.update(accList[0],true);
        List<Contact> contactList = getGrowerContactList();
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortalMap = getArgumentsMap(contactList[0].Email,contactList[0].genesis__SSN__c);
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowmarkGrowerVerificationAPI growmarkGrowerAPIInst = new PortalGrowmarkGrowerVerificationAPI();
                clcommon.Response response = growmarkGrowerAPIInst.invokeAction(componentStrName, disclosureNames, argumentsFromPortalMap);
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
        List<Account> accList= getGrowerAccountList();
        accList[0].Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        accList[0].clcommon__Legal_Entity_Type__r.Name = PortalConstants.CORPORATION;
        Database.update(accList[0],true);
        List<Account> coBorrowerAccList = [SELECT Id, 
                                                    Name, 
                                                    clcommon__Email__c, 
                                                    clcommon__Legal_Entity_Type__r.Name 
                                            FROM Account 
                                            WHERE clcommon__Email__c = 'mike.johnson@yopmail.com'];
        coBorrowerAccList[0].Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.update(coBorrowerAccList[0],true);
        List<Contact> coBorrowerContactList =  [SELECT FirstName, 
                                                        LastName, 
                                                        Email,
                                                        genesis__SSN__c 
                                                FROM Contact 
                                                WHERE Email = 'mike.johnson@yopmail.com'];
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortalMap = getArgumentsMap(coBorrowerContactList[0].Email,coBorrowerContactList[0].genesis__SSN__c);
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowmarkGrowerVerificationAPI growmarkGrowerAPIInst = new PortalGrowmarkGrowerVerificationAPI();
                clcommon.Response response = growmarkGrowerAPIInst.invokeAction(componentStrName, disclosureNames, argumentsFromPortalMap);
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
        List<Account> accList = getGrowerAccountList();
        accList[0].Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        accList[0].clcommon__Legal_Entity_Type__r.Name = PortalConstants.INDIVIDUAL_ENTITY;
        Database.update(accList[0],true);
        List<Account> coBorrowerAccList =  [SELECT Id, 
                                                    Name, 
                                                    clcommon__Email__c, 
                                                    clcommon__Legal_Entity_Type__r.Name 
                                            FROM Account 
                                            WHERE clcommon__Email__c = 'mike.johnson@yopmail.com'];
        coBorrowerAccList[0].Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.update(coBorrowerAccList[0],true);
        List<Contact> coBorrowerContactList =  [SELECT FirstName, 
                                                        LastName, 
                                                        Email,
                                                        genesis__SSN__c 
                                                FROM Contact 
                                                WHERE Email = 'mike.johnson@yopmail.com'];
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortalMap = getArgumentsMap(coBorrowerContactList[0].Email,coBorrowerContactList[0].genesis__SSN__c);
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowmarkGrowerVerificationAPI growmarkGrowerAPIInst = new PortalGrowmarkGrowerVerificationAPI();
                clcommon.Response response = growmarkGrowerAPIInst.invokeAction(componentStrName, disclosureNames, argumentsFromPortalMap);
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
        List<Account> accList = getGrowerAccountList();
        accList[0].Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.update(accList[0],true);
        List<Contact> contactList = getGrowerContactList();
        User growerUser = ApplicationOriginationTestHelper.createBorrowerUser(contactList[0].Id);
        Database.insert(growerUser, true);
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortalMap = getArgumentsMap(contactList[0].Email,contactList[0].genesis__SSN__c);
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowmarkGrowerVerificationAPI growmarkGrowerAPIInst = new PortalGrowmarkGrowerVerificationAPI();
                clcommon.Response response = growmarkGrowerAPIInst.invokeAction(componentStrName, disclosureNames, argumentsFromPortalMap);
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
        List<Account> accList = getGrowerAccountList();
        accList[0].Coop_Type__c = null;
        Database.update(accList[0],true);
        List<Contact> contactList = getGrowerContactList();
        User growerUser = ApplicationOriginationTestHelper.createBorrowerUser(contactList[0].Id);
        Database.insert(growerUser, true);
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortalMap = getArgumentsMap(contactList[0].Email,contactList[0].genesis__SSN__c);
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowmarkGrowerVerificationAPI growmarkGrowerAPIInst = new PortalGrowmarkGrowerVerificationAPI();
                clcommon.Response response = growmarkGrowerAPIInst.invokeAction(componentStrName, disclosureNames, argumentsFromPortalMap);
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
        List<Account> accList = getGrowerAccountList();
        accList[0].Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.update(accList[0],true);
        List<Contact> contactList = getGrowerContactList();
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortalMap = getArgumentsMap(null,contactList[0].genesis__SSN__c);
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowmarkGrowerVerificationAPI growmarkGrowerAPIInst = new PortalGrowmarkGrowerVerificationAPI();
                clcommon.Response response = growmarkGrowerAPIInst.invokeAction(componentStrName, disclosureNames, argumentsFromPortalMap);
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
        List<Account> accList = getGrowerAccountList();
        accList[0].Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.update(accList[0],true);
        List<Contact> contactList = getGrowerContactList();
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortalMap = getArgumentsMap(contactList[0].Email,null);
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowmarkGrowerVerificationAPI growmarkGrowerAPIInst = new PortalGrowmarkGrowerVerificationAPI();
                clcommon.Response response = growmarkGrowerAPIInst.invokeAction(componentStrName, disclosureNames, argumentsFromPortalMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();

            }
        }
    }
    /**
    * @description Exception- Validate null email
    * @author Rahul Gorai | 01-13-2025 
    **/
    @isTest
    private static void checkCustomException(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accList = getGrowerAccountList();
        accList[0].Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.update(accList[0],true);
        List<Contact> contactList = getGrowerContactList();
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortalMap = getArgumentsMap(null,contactList[0].genesis__SSN__c);
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowmarkGrowerVerificationAPI growmarkGrowerAPIInst = new PortalGrowmarkGrowerVerificationAPI();
                clcommon.Response response = growmarkGrowerAPIInst.invokeAction(componentStrName, disclosureNames, argumentsFromPortalMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();

            }
        }
    }
    /**
    * @description Exception- Validate null portal argument
    * @author Rahul Gorai | 01-13-2025 
    **/
    @isTest
    private static void checkException(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowmarkGrowerVerificationAPI growmarkGrowerAPIInst = new PortalGrowmarkGrowerVerificationAPI();
                clcommon.Response response = growmarkGrowerAPIInst.invokeAction(componentStrName, disclosureNames, null);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();

            }
        }
    }
    /**
    * @description : testing for soleprop who has a long lastname
    * @author Krishanu Chinya | 04-16-2024 
    **/
    @isTest
    private static void testSolePropWithLongLastname(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accList = getGrowerAccountList();
        accList[0].Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.update(accList[0],true);
        List<Contact> contactList = getGrowerContactList();
        contactList[0].LastName = 'Vjrigubangshi';
        Database.update(contactList[0], true);
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortalMap = getArgumentsMap(contactList[0].Email,contactList[0].genesis__SSN__c);
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowmarkGrowerVerificationAPI growmarkGrowerAPIInst = new PortalGrowmarkGrowerVerificationAPI();
                clcommon.Response response = growmarkGrowerAPIInst.invokeAction(componentStrName, disclosureNames, argumentsFromPortalMap);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }
    
    /**
    * @description Exception-Validate missing email in input arguments
    * @author Rahul Gorai | 01-12-2025 
    **/
    @isTest
    private static void validateMissingEmailExceptionScenario() {
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accList = getGrowerAccountList();
        accList[0].Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.update(accList[0],true);
        List<Contact> contactList = getGrowerContactList();
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortal = getArgumentsMap('', contactList[0].genesis__SSN__c);
        

        if (certifiedLenderUserObj != null) {
            System.runAs(certifiedLenderUserObj) {
                Test.startTest();
                PortalGrowmarkGrowerVerificationAPI growmarkGrowerAPIInst = new PortalGrowmarkGrowerVerificationAPI();
                clcommon.Response response = growmarkGrowerAPIInst.invokeAction(componentStrName, disclosureNames, argumentsFromPortal);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }
    
    /**
    * @description Exception-Validate missing SSN in input arguments
    * @author Rahul Gorai | 01-12-2025 
    **/
    @isTest
    private static void validateMissingSSNExceptionScenario() {
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> accList = getGrowerAccountList();
        accList[0].Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        Database.update(accList[0],true);

        List<Contact> contactList = getGrowerContactList();
        
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortalMap = getArgumentsMap(contactList[0].Email ,'');
        if (certifiedLenderUserObj != null) {
            System.runAs(certifiedLenderUserObj) {
                Test.startTest();
                PortalGrowmarkGrowerVerificationAPI growmarkGrowerAPIInst = new PortalGrowmarkGrowerVerificationAPI();
                clcommon.Response response = growmarkGrowerAPIInst.invokeAction(componentStrName, disclosureNames, argumentsFromPortalMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }
    /**
    * @description Success- Validation for invalid coop type
    * @author Rahul Gorai | 01-13-2025 
    **/
    @isTest
    private static void checkSuccessForCFACoopType(){
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        
        List<Contact> contactList = getGrowerContactList();
        contactList[0].Account.Coop_Type__c='CFA';
        Database.update(contactList[0],true);

        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortalMap = getArgumentsMap(contactList[0].Email,contactList[0].genesis__SSN__c);
            
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowmarkGrowerVerificationAPI growmarkGrowerAPIInst = new PortalGrowmarkGrowerVerificationAPI();
                clcommon.Response response = growmarkGrowerAPIInst.invokeAction(componentStrName, disclosureNames, argumentsFromPortalMap);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();

            }
        }
    }
    
    /**
    * @description Exception- Validate for Invalid Email
    * @author Rahul Gorai | 01-13-2025 
    **/
    @isTest
    private static void testExceptionForInvalidEmail() {
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Contact> contactList = getGrowerContactList();
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortalMap = getArgumentsMap('invalidEmail@gmail.com',contactList[0].genesis__SSN__c);
        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowmarkGrowerVerificationAPI growmarkGrowerAPIInst = new PortalGrowmarkGrowerVerificationAPI();
                clcommon.Response response = growmarkGrowerAPIInst.invokeAction(componentStrName, disclosureNames, argumentsFromPortalMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
        
    }
    /**
    * @description Exception- Validate for Invalid SSN
    * @author Rahul Gorai | 01-13-2025 
    **/
    @isTest
    private static void testExceptionForInvalidSSN() {
        User certifiedLenderUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Contact> contactList = getGrowerContactList();
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortalMap = getArgumentsMap(contactList[0].Email,'904567389');

        if(certifiedLenderUserObj != null){
            System.runAs(certifiedLenderUserObj){
                Test.startTest();
                PortalGrowmarkGrowerVerificationAPI growmarkGrowerAPIInst = new PortalGrowmarkGrowerVerificationAPI();
                clcommon.Response response = growmarkGrowerAPIInst.invokeAction(componentStrName, disclosureNames, argumentsFromPortalMap);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
        
    }
    
    
}