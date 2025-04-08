/**
 * @description       : 
 * @author            : Ravi Ranjan
 * @group             : 
 * @last modified on  : 14-01-2025
 * @last modified by  : Soumik Pattanayak
**/

@isTest
private with sharing class PortalEnableGrowerAPITest {
    
    @TestSetup
    static void setup(){
        // Creating floating rate index
        clcommon__Floating_Rate_Index__c floatingRateIndexObj = ApplicationOriginationTestHelper.createFloatingRateIndex(
            New Map<String, Object>{ 'Name' => 'CFA Advantage Rate',
                                        'Base Rate Name' => '4-CFA ADVANTAGE',
                                        'Current Floating Rate' => 11,
                                        'Base Rate Adjuster' => 5.5
        });
        Database.insert(floatingRateIndexObj, true);

        // Creating floating rate
        clcommon__Floating_Rate__c floatingRateObj = ApplicationOriginationTestHelper.createFloatingRate(floatingRateIndexObj);
        Database.insert(floatingRateObj, true);

        // Creating new partnert program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);
        genesis__Business_Information__c businessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoObj,true);
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoObj.id, newPartnerProgramObj.id);
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
        borrowerAccountObj.ParentId = dealerAccountObj.Id;
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
        //creating user for borrower
        User borrowerUser = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        borrowerUser.FirstName = 'Ravi';
        Database.insert(borrowerUser, true);
        
        genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(coBorrowerBusinessInfoObj,true);
        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(legalEntityObj,coBorrowerBusinessInfoObj.id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.CO_APPLICATION_RECORD_TYPE).getRecordTypeId();
        Database.insert(coBorrowerAccountObj,true);
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        Database.insert(coBorrowerContactObj,true);

        Dealer_Applicant_Relationship__c dealerGrowerRel = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj, dealerAccountObj.id);
        Dealer_Applicant_Relationship__c dealerPrincipalRel = ApplicationOriginationTestHelper.createDealerApplicantRelationship(coBorrowerContactObj, dealerAccountObj.id);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{dealerPrincipalRel,dealerGrowerRel},true);

        Map<String,Object> applicationDataMap = new Map<String,Object>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'saAccountObjId' => accountObj.id,
            'dealerApplicantRelationshipId' => dealerGrowerRel.id
        };
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(applicationDataMap);
        applicationObj.Certified_Lender__c = clAccountObj.id;
        Database.upsert(applicationObj,true); 
        
        clcommon__Party_Type__c clParty = ApplicationOriginationTestHelper.createPartyType(PortalConstants.CL_PARTY_NAME);
        //Create Party
        Map<String,Id> partyDataMap =new Map<String,Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clParty.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__Party__c partyObj= ApplicationOriginationTestHelper.createParty(partyDataMap);
        partyObj.clcommon__Party_Types__c = PortalConstants.GROWER_PROFILE;
        Database.upsert(partyObj,true);
        //principal party type
        clcommon__Party_Type__c prPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.PRINCIPAL_PARTY_NAME);
        Database.insert(prPartyTypeObj,true);
        Map<String,Id> principalPartyParamMap = new Map<String,Id>{
            'accountId' => coBorrowerAccountObj.id,
            'contactId' => coBorrowerContactObj.id,
            'partyTypeId' => prPartyTypeObj.id,
            'applicationId' => applicationObj.id,
            'dealerApplicantRelationshipId' => dealerPrincipalRel.id
        };
        clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createParty(principalPartyParamMap);
        principalPartyObj.Principal_Number__c = 1;
        Database.insert(principalPartyObj,true);
        
    }

    /**
    * @description invoke action method for enable user for grower portal
    * @author Soumik Pattanayak | 07-01-2025 
    **/
    @isTest
    private static void testEnbleUserForGrowerPortal(){
        User objCertifiedLenderUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> appList=[SELECT Id, Coop_Type__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c=:'398762543'];
        
         // Mocking the arguments for the invokeAction method
         String componentStrName = 'TestComponent';
         String[] disclosureNames = new String[]{'TestDisclosure'};
         Map<String, Object> argumentsFromPortal = new Map<String, Object>{
             'appId' => appList[0].Id 
         };
         if(objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
                PortalEnableGrowerAPI obj = new PortalEnableGrowerAPI();
                clcommon.Response response = obj.invokeAction(componentStrName, disclosureNames, argumentsFromPortal);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            
            }
        }
    }

    /**
    * @description invoke action method for enable user for grower portal for corporation
    * @author Soumik Pattanayak | 07-01-2025 
    **/
    @isTest
    private static void testEnableUserForGrowerPoratlCorporation(){
        User objCertifiedLenderUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<clcommon__Legal_Entity__c> legalEntity = [SELECT Id,
                                                       clcommon__Legal_Entity_Type__c
                                                       FROM clcommon__Legal_Entity__c
                                                       WHERE Name = :PortalConstants.SOLE_PROP_ENTITY];
        legalEntity[0].Name = 'Corporation';
        Database.update(legalEntity);
    
        List<genesis__Applications__c> appList=[SELECT Id,genesis__Contact__r.FirstName FROM genesis__Applications__c WHERE genesis__Loan_Number__c=:'398762543'];
        
         // Mocking the arguments for the invokeAction method
         String componentStrName = 'TestComponent';
         String[] disclosureNames = new String[]{'TestDisclosure'};
         Map<String, Object> argumentsFromPortal = new Map<String, Object>{
             'appId' => appList[0].Id 
             
         };
         if(objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
                PortalEnableGrowerAPI obj = new PortalEnableGrowerAPI();
                clcommon.Response response = obj.invokeAction(componentStrName, disclosureNames, argumentsFromPortal);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();


            }
        }
    }

    /**
    * @description check email for existing user
    * @author Soumik Pattanayak | 07-01-2025 
    **/
    @isTest
    private static void sendEmailToGrowerForExistingUserTest(){
        List<genesis__Applications__c> appObj =[SELECT Id, 
                                                            genesis__Account__c,
                                                            genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                            Coop_Type__c,
                                                            genesis__Contact__c,
                                                            genesis__Contact__r.Email,
                                                            (SELECT Id,
                                                                    genesis__Application__c, 
                                                                    clcommon__Party_Types__c,
                                                                    Principal_Number__c,
                                                                    clcommon__Account__c,
                                                                    clcommon__Account__r.Name, 
                                                                    clcommon__Contact__c,
                                                                    clcommon__Contact__r.Email 
                                                            FROM genesis__parties__r
                                                            WHERE clcommon__Party_Types__c ='Principal'
                                                            AND Principal_Number__c = 1) 
                                                            FROM genesis__Applications__c
                                                            WHERE genesis__Loan_Number__c=:'398762543'];
        List<User> borrowerUser = [SELECT Id,
                                          FirstName,
                                          Email, 
                                          Account.Parent.CFA_Partner_Program__c,
                                          Account.Parent.CFA_Partner_Program__r.Dealer_Portal_Logo__c,
                                          Account.Parent.CFA_Partner_Program__r.Short_Name__c,
                                          Account.Parent.CFA_Partner_Program__r.Name 
                                    FROM USER WHERE UserName= 'star.lord@yopmail.com'];
        String coopType =  appObj[0].Coop_Type__c;
        User objCertifiedLenderUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        System.runAs(objCertifiedLenderUser){
            Test.startTest();
            PortalEnableGrowerAPI.sendEmailToGrowerForExistingUser(borrowerUser,coopType);
            List<clcommon__Log__c> logList = [SELECT id FROM clcommon__Log__c WHERE name = 'Email - (Email For Existing Members)'];
            System.assertEquals(true, logList.size()>0, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description invoke action method for exception
    * @author Soumik Pattanayak | 07-01-2025 
    **/
    @isTest
    private static void checkException(){
        User objCertifiedLenderUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<clcommon__Legal_Entity__c> legalEntity = [SELECT Id,
                                                       clcommon__Legal_Entity_Type__c
                                                       FROM clcommon__Legal_Entity__c
                                                       WHERE Name =:PortalConstants.SOLE_PROP_ENTITY];
        legalEntity[0].Name = 'Corporation';
        Database.update(legalEntity);
        
         // Mocking the arguments for the invokeAction method
         String componentStrName = 'TestComponent';
         String[] disclosureNames = new String[]{'TestDisclosure'};
         Map<String, Object> argumentsFromPortal = new Map<String, Object>{
             'appId' => null
             
         };
         if(objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
                PortalEnableGrowerAPI obj = new PortalEnableGrowerAPI();
                clcommon.Response response = obj.invokeAction(componentStrName, disclosureNames, argumentsFromPortal);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description invoke action method for exception
    * @author Soumik Pattanayak | 07-01-2025 
    **/
    @isTest
    private static void checkObjException(){
        User objCertifiedLenderUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<clcommon__Legal_Entity__c> legalEntity = [SELECT Id,
                                                       clcommon__Legal_Entity_Type__c
                                                       FROM clcommon__Legal_Entity__c
                                                       WHERE Name =:PortalConstants.SOLE_PROP_ENTITY];
        legalEntity[0].Name = 'Corporation';
        Database.update(legalEntity);
        
         // Mocking the arguments for the invokeAction method
         String componentStrName = 'TestComponent';
         String[] disclosureNames = new String[]{'TestDisclosure'};
         Map<String, Object> argumentsFromPortal = new Map<String, Object>();
         argumentsFromPortal.put('appId', 'RAVI');
         if(objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
                PortalEnableGrowerAPI obj = new PortalEnableGrowerAPI();
                clcommon.Response response = obj.invokeAction(componentStrName, disclosureNames, argumentsFromPortal);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description invoke action method for validation exception
    * @author Soumik Pattanayak | 07-01-2025 
    **/
    @isTest
    private static void checkValidateException(){
        User objCertifiedLenderUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Contact> contactList = [SELECT Id,Email FROM Contact WHERE FirstName =: 'Jasmine'];
        contactList[0].Email = null;
        Database.update(contactList,true);
    
        List<genesis__Applications__c> appList=[SELECT Id,genesis__Contact__r.FirstName FROM genesis__Applications__c WHERE genesis__Loan_Number__c=:'398762543'];
        List<clcommon__party__c> partyObj = [SELECT Id,
                                                        genesis__Application__c, 
                                                        clcommon__Party_Types__c, 
                                                        clcommon__Account__r.Name, 
                                                        clcommon__Contact__c,
                                                        clcommon__Contact__r.FirstName,
                                                        clcommon__Contact__r.Email 
                                                        FROM clcommon__Party__c
                                                        WHERE genesis__Application__r.genesis__Loan_Number__c=:'398762543'
                                                        AND clcommon__Party_Types__c =:'Principal'
                                                        ORDER BY createddate ASC LIMIT 1];
        
        partyObj[0].clcommon__Contact__c = null;
        
         // Mocking the arguments for the invokeAction method
         String componentStrName = 'TestComponent';
         String[] disclosureNames = new String[]{'TestDisclosure'};
         Map<String, Object> argumentsFromPortal = new Map<String, Object>{
             'appId' => appList[0].Id
         };
         if(objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
                PortalEnableGrowerAPI obj = new PortalEnableGrowerAPI();
                clcommon.Response response = obj.invokeAction(componentStrName, disclosureNames, argumentsFromPortal);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description invoke action email exception
    * @author Soumik Pattanayak | 07-01-2025 
    **/
    @isTest
    private static void checkValidateEmailException(){
        User objCertifiedLenderUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<clcommon__Legal_Entity__c> legalEntity = [SELECT Id,
                                                       clcommon__Legal_Entity_Type__c
                                                       FROM clcommon__Legal_Entity__c
                                                       WHERE Name =:PortalConstants.SOLE_PROP_ENTITY];
        legalEntity[0].Name = 'Corporation';
        Database.update(legalEntity);
        
        List<Contact> contactList = [SELECT Id,Email FROM Contact WHERE genesis__SSN__c =: '982983834'];
        contactList[0].Email = null;
        Database.update(contactList,true);
        List<genesis__Applications__c> appList=[SELECT Id,genesis__Contact__c FROM genesis__Applications__c WHERE genesis__Loan_Number__c=:'398762543'];
         // Mocking the arguments for the invokeAction method
         String componentStrName = 'TestComponent';
         String[] disclosureNames = new String[]{'TestDisclosure'};
         Map<String, Object> argumentsFromPortal = new Map<String, Object>{
             'appId' => appList[0].Id
             
         };

         if(objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
                PortalEnableGrowerAPI obj = new PortalEnableGrowerAPI();
                clcommon.Response response = obj.invokeAction(componentStrName, disclosureNames, argumentsFromPortal);
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description test invoke action for GMK 
    * @author Soumik Pattanayak | 07-01-2025 
    **/
    @isTest
    private static void validateForGMK(){
        List<Account> dealeraccList = [SELECT Id,Coop_Type__c FROM Account WHERE Name=:'Kisan Loan'];
        dealeraccList[0].Coop_Type__c = 'Growmark';
        Database.update(dealeraccList,true);
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id,
                                                       clcommon__Legal_Entity_Type__c
                                                       FROM clcommon__Legal_Entity__c
                                                       WHERE Name =:PortalConstants.SOLE_PROP_ENTITY];
        legalEntityList[0].Name = 'Corporation';
        Database.update(legalEntityList);
        List<genesis__Applications__c> appList=[SELECT Id,genesis__Contact__r.FirstName FROM genesis__Applications__c WHERE genesis__Loan_Number__c=:'398762543'];
       
        User objCertifiedLenderUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        // Mocking the arguments for the invokeAction method
        String componentStrName = 'TestComponent';
        String[] disclosureNames = new String[]{'TestDisclosure'};
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'appId' => appList[0].Id
        };

        if(objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
                PortalEnableGrowerAPI obj = new PortalEnableGrowerAPI();
                clcommon.Response response = obj.invokeAction(componentStrName, disclosureNames, argumentsFromPortal);
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description send email for growmark
    * @author Soumik Pattanayak | 07-01-2025 
    **/
    @isTest
    private static void sendEmailToGrowerTestGrowmark(){
        List<User> borrowerUser = [SELECT Id, Account.ParentId, FirstName,Email FROM USER WHERE UserName= 'star.lord@yopmail.com'];
        String coopType = 'Growmark';
        User objCertifiedLenderUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        System.runAs(objCertifiedLenderUser){
            Test.startTest();
            PortalEnableGrowerAPI.sendEmailToGrowerForExistingUser(borrowerUser,coopType);
            List<clcommon__Log__c> logList = [SELECT id FROM clcommon__Log__c WHERE name = 'Email - (Email For Existing Members)'];
            System.assertEquals(true, logList.size()>0, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description send email for landus
    * @author Soumik Pattanayak | 07-01-2025 
    **/
    @isTest
    private static void sendEmailToGrowerTestLandus(){
        List<User> borrowerUser = [SELECT Id,
                                            FirstName,
                                            Email,
                                            AccountId, 
                                            Account.ParentId, 
                                            Account.Parent.CFA_Partner_Program__c,
                                            Account.Parent.CFA_Partner_Program__r.Dealer_Portal_Logo__c,
                                            Account.Parent.CFA_Partner_Program__r.Short_Name__c,
                                            Account.Parent.CFA_Partner_Program__r.Name
                                            FROM USER WHERE UserName= 'star.lord@yopmail.com'];
        String coopType = 'Landus';
        User objCertifiedLenderUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        System.runAs(objCertifiedLenderUser){
            Test.startTest();
            PortalEnableGrowerAPI.sendEmailToGrowerForExistingUser(borrowerUser,coopType);
            List<clcommon__Log__c> logList = [SELECT id FROM clcommon__Log__c WHERE name = 'Email - (Email For Existing Members)'];
            System.assertEquals(true, logList.size()>0, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description send email exception
    * @author Soumik Pattanayak | 07-01-2025 
    **/
    @isTest
    private static void sendEmailToGrowerException(){
        List<User> borrowerUser = [SELECT Id,
                                            FirstName,
                                            Email,
                                            AccountId, 
                                            Account.ParentId, 
                                            Account.Parent.CFA_Partner_Program__c,
                                            Account.Parent.CFA_Partner_Program__r.Dealer_Portal_Logo__c,
                                            Account.Parent.CFA_Partner_Program__r.Short_Name__c,
                                            Account.Parent.CFA_Partner_Program__r.Name
                                            FROM USER WHERE UserName= 'star.lord@yopmail.com'];
        String coopType = 'Landus';
        borrowerUser[0].Account.ParentId = null;
        Database.update(borrowerUser, true);
        User objCertifiedLenderUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Boolean isException =false;
        System.runAs(objCertifiedLenderUser){
            Test.startTest();
            try{
                PortalEnableGrowerAPI.sendEmailToGrowerForExistingUser(borrowerUser,coopType);
            }catch(CustomException e){
                isException = true;
            }
            System.assertEquals(true, isException, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
}