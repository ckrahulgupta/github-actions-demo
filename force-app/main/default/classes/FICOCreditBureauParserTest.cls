/**
 * @description       : Test Class for FICOCreditBureauParser
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 10-14-2024
 * @last modified by  : Rakesh Saraf
**/
@isTest
public without sharing class FICOCreditBureauParserTest {
    @testSetup
    static void setup(){
        Map<String, Id> objectVsIdMap=new Map<String, Id>();
        Map<String, Id> objBorrowerMap = new Map<String,Id>();
        Map<String, Id> objPrincipalMap = new Map<String,Id>();
        genesis__Business_Information__c businessInformationObj = TestClassHelper.createBusinessInfoForDealer();
        Database.insert(businessInformationObj,true);
        Account dealerAccountObj = TestClassHelper.createDealerAccount(businessInformationObj.Id);
        Database.insert(dealerAccountObj, true);
        Account clAccountObj = TestClassHelper.createCLAccount(businessInformationObj.Id,dealerAccountObj.Id);
        Database.insert(clAccountObj, true);
        Contact clContactObj = TestClassHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);
        clcommon__CL_Product__c clProductObj=TestClassHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);
        clcommon__CL_Purpose__c clPurposeObj=TestClassHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj,true);
        clcommon__Legal_Entity__c entityObj= TestClassHelper.createLegalEntity('Individual(s) - Sole Proprietorship');
        Database.insert(entityObj,true);
        Account accountObj=TestClassHelper.createSolePropAccount(entityObj,businessInformationObj.Id);
        Database.insert(accountObj,true);
        Contact contactObj=TestClassHelper.createBorrowerContact(accountObj.Id);
        Database.insert(contactObj,true);
        
        objectVsIdMap.put('dealerAccountId',dealerAccountObj.Id);
        objectVsIdMap.put('clProductId',clProductObj.Id);
        objectVsIdMap.put('clPurposeId',clPurposeObj.Id);
        objectVsIdMap.put('borrowerAccountId',accountObj.Id);
        objectVsIdMap.put('borrowerContactId',contactObj.Id);
        objectVsIdMap.put('clAccountId',clAccountObj.Id);
        genesis__Applications__c currApplicationObj = TestClassHelper.createCurrCropYearApplication(objectVsIdMap);
        Database.insert(currApplicationObj,true);
        clcommon__Party_Type__c partyTypeObj=TestClassHelper.createPartyType('BORROWER');
        Database.insert(partyTypeObj,true);
        objBorrowerMap.put('accountId',accountObj.Id);
        objBorrowerMap.put('contactId',contactObj.Id);
        objBorrowerMap.put('partyTypeId',partyTypeObj.Id);
        objBorrowerMap.put('applicationId',currApplicationObj.Id);
        clcommon__Party__c partyObj = TestClassHelper.createParty(objBorrowerMap);
        Database.insert(partyObj,true);
        clcommon__Party_Type__c partyPrincipalTypeObj=TestClassHelper.createPartyType('PRINCIPAL');
        Database.insert(partyPrincipalTypeObj,true);
        Account principalAccount = FICOCalloutTestHelper.createAccount(businessInformationObj.Id);
        Database.insert(principalAccount,true);
        Contact principalContact = FICOCalloutTestHelper.createPrincipalContact(principalAccount);
        Database.insert(principalContact,true);
        objPrincipalMap.put('accountId',principalAccount.Id);
        objPrincipalMap.put('contactId',principalContact.Id);
        objPrincipalMap.put('partyTypeId',partyPrincipalTypeObj.Id);
        objPrincipalMap.put('applicationId',currApplicationObj.Id);
        clcommon__Party__c principalPartyObj = TestClassHelper.createParty(objPrincipalMap);
        Database.insert(principalPartyObj,true);

        clcommon__Legal_Entity__c entityCorpObj= TestClassHelper.createLegalEntity('Corporation');
        Database.insert(entityCorpObj,true);
    }
    /**
    * @description Testing FICO Responses
    * @author  Pritam Roy | 01-17-2024 
    **/
    @isTest
    static void testFICOCreditParser(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        StaticResource ficoResponse = new StaticResource();
        StaticResource ficoResponseTwo = new StaticResource();
        StaticResource ficoResponseThree = new StaticResource();
        StaticResource ficoResponseFour = new StaticResource();

        ficoResponse = [SELECT Id,
                                Body 
                            FROM StaticResource 
                            WHERE Name ='Test'];
        ficoResponseTwo = [SELECT Id,
                                 Body 
                            FROM StaticResource 
                            WHERE Name ='Test2'];
        ficoResponseThree = [SELECT Id,
                                 Body 
                            FROM StaticResource 
                            WHERE Name ='Test3'];
        ficoResponseFour = [SELECT Id,
                                Body 
                             FROM StaticResource 
                             WHERE Name ='Test4'];

        String ficoBody = ficoResponse.body.toString();
        String ficoBodyTwo = ficoResponseTwo.body.toString();
        String ficoBodyThree = ficoResponseThree.body.toString();
        String ficoBodyFour = ficoResponseFour.body.toString();

        Contact objBorrowerContact = [SELECT Id 
                                            FROM Contact 
                                            WHERE LastName = 'Albin'];
        Contact objPrincipalContact = [SELECT Id 
                                            FROM Contact 
                                            WHERE LastName = 'Andersan']; 
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 35000];

        objBorrowerContact.genesis__SSN__c = '506502389';
        objPrincipalContact.genesis__SSN__c = '507886136';

        Database.upsert(objBorrowerContact,true);
        Database.upsert(objPrincipalContact,true);
        List<clcommon__Party__c> objListParty = [SELECT  Name, 
                                                            Id, 
                                                            clcommon__Type__r.Name,
                                                            clcommon__Contact__r.genesis__SSN__c, 
                                                            clcommon__Account__c,
                                                            clcommon__Party_Types__c,
                                                            clcommon__Account__r.Score_1__c,
                                                            clcommon__Account__r.Score_2__c,
                                                            clcommon__Account__r.SBSS70_Score__c,
                                                            clcommon__Account__r.BK10_Score__c   
                                                    FROM clcommon__Party__c 
                                                    WHERE genesis__Application__c = :applicationObj.Id
                                                    AND (clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME OR
                                                    clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME)
                                                    AND clcommon__Account__c != null];
        System.assert(!objListParty.isEmpty(),'Party Not Found');                                            
        System.runAs(objAdmin){
            Test.startTest();                            
            FICOCreditBureauParser.createCreditBureauReport(ficoBody, (String)applicationObj.Id);
            FICOCreditBureauParser.createCreditBureauReport(ficoBodyTwo, (String)applicationObj.Id);
            FICOCreditBureauParser.createCreditBureauReport(ficoBodyThree, (String)applicationObj.Id);
            FICOCreditBureauParser.createCreditBureauReport(ficoBodyFour, (String)applicationObj.Id);
            Test.stopTest();
            List<Account> parsedAccountList = [SELECT id,FICO_Recorded_On__c FROM Account WHERE FICO_Recorded_On__c!=null];
            System.assert(parsedAccountList!=null,'No values parsed');
        }
    }

    @isTest
    static void testNoScoreApplicantResponse(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        StaticResource ficoResponse = new StaticResource();
        ficoResponse = [SELECT Id,
                                Body 
                            FROM StaticResource 
                            WHERE Name ='TestNoScoreApplicantWithPrincipal'];

        String ficoBody = ficoResponse.body.toString();

        //System.debug(ficoBody);

        Contact objBorrowerContact = [SELECT Id ,AccountId
                                            FROM Contact 
                                            WHERE LastName = 'Albin'];
        Contact objPrincipalContact = [SELECT Id ,AccountId
                                            FROM Contact 
                                            WHERE LastName = 'Andersan']; 
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 35000];

        objBorrowerContact.genesis__SSN__c = '509540692';
        objPrincipalContact.genesis__SSN__c = '507886136';

        Database.upsert(objBorrowerContact,true);
        Database.upsert(objPrincipalContact,true);
        List<clcommon__Party__c> objListParty = [SELECT  Name, 
                                                            Id, 
                                                            clcommon__Type__r.Name,
                                                            clcommon__Contact__r.genesis__SSN__c, 
                                                            clcommon__Account__c,
                                                            clcommon__Party_Types__c,
                                                            clcommon__Account__r.Score_1__c,
                                                            clcommon__Account__r.Score_2__c,
                                                            clcommon__Account__r.SBSS70_Score__c,
                                                            clcommon__Account__r.BK10_Score__c   
                                                    FROM clcommon__Party__c 
                                                    WHERE genesis__Application__c = :applicationObj.Id
                                                    AND (clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME OR
                                                    clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME)
                                                    AND clcommon__Account__c != null];
        System.assert(!objListParty.isEmpty(),'Party Not Found');
        System.runAs(objAdmin){
            Test.startTest();                            
            FICOCreditBureauParser.createCreditBureauReport(ficoBody, (String)applicationObj.Id);
            // FICOCreditRating.ficoCreditRatingMatrix((String)applicationObj.Id);
            Account objBorrowerAccount=[select id,Score_1__c,Score_2__c,SBSS70_Score__c from account where id=:objBorrowerContact.AccountId];
            Account objPrincipalAccount=[select id,Score_1__c,Score_2__c,SBSS70_Score__c from account where id=:objPrincipalContact.AccountId];
            genesis__Applications__c updatedApplicationObj=[select id,FICO_Score__c,SBSS_70_Score__c from genesis__Applications__c where genesis__Loan_Amount__c = 35000];

            System.debug('Borrower Fico Score: '+objBorrowerAccount.Score_1__c+', Score 2: '+objBorrowerAccount.Score_2__c+', Sbss Score: '+objBorrowerAccount.SBSS70_Score__c);
            System.debug('Principal Fico Score: '+objPrincipalAccount.Score_1__c+', Score 2: '+objPrincipalAccount.Score_2__c+', Sbss Score: '+objPrincipalAccount.SBSS70_Score__c);
            System.debug('Application Fico Score: '+updatedApplicationObj.FICO_Score__c+', SBSS score: '+updatedApplicationObj.SBSS_70_Score__c);
            Test.stopTest();
        }
               
    }
    
    /**
    * @description Fico Response Exception
    * @author  Pritam Roy | 01-18-2024 
    **/
    @isTest
    static void testFICOCreditParserException(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        StaticResource ficoResponseException = new StaticResource();
        ficoResponseException = [SELECT Id,
                                        Body 
                                    FROM StaticResource 
                                    WHERE Name ='FicoResponseException'];
        String ficoExceptionBody = ficoResponseException.body.toString();

        Contact objBorrowerContact = [SELECT Id 
                                            FROM Contact 
                                            WHERE LastName = 'Albin'];
        Contact objPrincipalContact = [SELECT Id 
                                            FROM Contact 
                                            WHERE LastName = 'Andersan']; 
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 35000];
                            
        objBorrowerContact.genesis__SSN__c = '390081443';
        objPrincipalContact.genesis__SSN__c = '390081443';
                            
        Database.upsert(objBorrowerContact,true);
        Database.upsert(objPrincipalContact,true);
        List<clcommon__Party__c> objListParty = [SELECT  Name, 
                                                            Id, 
                                                            clcommon__Type__r.Name,
                                                            clcommon__Contact__r.genesis__SSN__c, 
                                                            clcommon__Account__c,
                                                            clcommon__Party_Types__c,
                                                            clcommon__Account__r.Score_1__c,
                                                            clcommon__Account__r.Score_2__c,
                                                            clcommon__Account__r.SBSS70_Score__c,
                                                            clcommon__Account__r.BK10_Score__c   
                                                    FROM clcommon__Party__c 
                                                    WHERE genesis__Application__c = :applicationObj.Id
                                                    AND (clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME OR
                                                    clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME)
                                                    AND clcommon__Account__c != null];
        System.assert(!objListParty.isEmpty(),'Party Not Found');                                            
        System.runAs(objAdmin){
            Test.startTest();                            
            FICOCreditBureauParser.createCreditBureauReport(ficoExceptionBody, (String)applicationObj.Id);
            Test.stopTest();
            List<Account> parsedAccountList = [SELECT id,FICO_Recorded_On__c FROM Account WHERE FICO_Recorded_On__c!=null];
            System.assert(parsedAccountList!=null,'No values parsed');
        }
    }

    /**
    * @description Fico Response Exception
    * @author  Pritam Roy | 01-18-2024 
    **/
    @isTest
    static void testFICOCreditParserExceptionSolePropScenario(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        StaticResource ficoResponseException = new StaticResource();
        ficoResponseException = [SELECT Id,
                                        Body 
                                    FROM StaticResource 
                                    WHERE Name ='Fico_test_a'];
        String ficoExceptionBody = ficoResponseException.body.toString();

        Contact objBorrowerContact = [SELECT Id 
                                            FROM Contact 
                                            WHERE LastName = 'Albin'];
        Contact objPrincipalContact = [SELECT Id 
                                            FROM Contact 
                                            WHERE LastName = 'Andersan']; 
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 35000];
                            
        objBorrowerContact.genesis__SSN__c = '508232423';
        objPrincipalContact.genesis__SSN__c = '508232423';
                            
        Database.upsert(objBorrowerContact,true);
        Database.upsert(objPrincipalContact,true);
        List<clcommon__Party__c> objListParty = [SELECT  Name, 
                                                            Id, 
                                                            clcommon__Type__r.Name,
                                                            clcommon__Contact__r.genesis__SSN__c, 
                                                            clcommon__Account__c,
                                                            clcommon__Party_Types__c,
                                                            clcommon__Account__r.Score_1__c,
                                                            clcommon__Account__r.Score_2__c,
                                                            clcommon__Account__r.SBSS70_Score__c,
                                                            clcommon__Account__r.BK10_Score__c   
                                                    FROM clcommon__Party__c 
                                                    WHERE genesis__Application__c = :applicationObj.Id
                                                    AND (clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME OR
                                                    clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME)
                                                    AND clcommon__Account__c != null];
        System.assert(!objListParty.isEmpty(),'Party Not Found');                                            
        System.runAs(objAdmin){
            Test.startTest();                            
            FICOCreditBureauParser.createCreditBureauReport(ficoExceptionBody, (String)applicationObj.Id);
            Test.stopTest();
            List<Account> parsedAccountList = [SELECT id,FICO_Recorded_On__c FROM Account WHERE FICO_Recorded_On__c!=null];
            System.assert(parsedAccountList!=null,'No values parsed');
        }
    }
     /**
    * @description Fico PrintImage is not there in the second principal
    * @author  Pritam Roy | 01-18-2024 
    **/
    @isTest
    static void testFICOPrintImageException(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        StaticResource ficoResponseException = new StaticResource();
        ficoResponseException = [SELECT Id,
                                        Body 
                                    FROM StaticResource 
                                    WHERE Name ='Fico_test_b'];
        String ficoExceptionBody = ficoResponseException.body.toString();

        Contact objBorrowerContact = [SELECT Id 
                                            FROM Contact 
                                            WHERE LastName = 'Albin'];
        Contact objPrincipalContact = [SELECT Id 
                                            FROM Contact 
                                            WHERE LastName = 'Andersan']; 
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 35000];
                            
        objBorrowerContact.genesis__SSN__c = '399487910';
        objPrincipalContact.genesis__SSN__c = '391824132';
                            
        Database.upsert(objBorrowerContact,true);
        Database.upsert(objPrincipalContact,true);
        List<clcommon__Party__c> objListParty = [SELECT  Name, 
                                                            Id, 
                                                            clcommon__Type__r.Name,
                                                            clcommon__Contact__r.genesis__SSN__c, 
                                                            clcommon__Account__c,
                                                            clcommon__Party_Types__c,
                                                            clcommon__Account__r.Score_1__c,
                                                            clcommon__Account__r.Score_2__c,
                                                            clcommon__Account__r.SBSS70_Score__c,
                                                            clcommon__Account__r.BK10_Score__c   
                                                    FROM clcommon__Party__c 
                                                    WHERE genesis__Application__c = :applicationObj.Id
                                                    AND (clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME OR
                                                    clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME)
                                                    AND clcommon__Account__c != null];
        System.assert(!objListParty.isEmpty(),'Party Not Found');                                            
        System.runAs(objAdmin){
            Test.startTest();                            
            FICOCreditBureauParser.createCreditBureauReport(ficoExceptionBody, (String)applicationObj.Id);
            Test.stopTest();
            List<Account> parsedAccountList = [SELECT id,FICO_Recorded_On__c FROM Account WHERE FICO_Recorded_On__c!=null];
            System.assert(parsedAccountList!=null,'No values parsed');
        }
    }

    /**
    * @description Fico for Business
    * @author  Pritam Roy | 02-23-2024 
    **/
    @isTest
    static void testFICOBusiness(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        StaticResource ficoResponseException = new StaticResource();
        ficoResponseException = [SELECT Id,
                                        Body 
                                    FROM StaticResource 
                                    WHERE Name ='Fico_test_b'];
        String ficoExceptionBody = ficoResponseException.body.toString();

        clcommon__Legal_Entity__c objEntity = [SELECT Id
                                                    FROM clcommon__Legal_Entity__c
                                                    WHERE Name = 'Corporation'];

        Account objBorrowerAccount = [SELECT Id,
                                            clcommon__Legal_Entity_Type__c
                                            FROM Account 
                                            WHERE Name = 'Jasmine Albin'];
        Contact objPrincipalContact = [SELECT Id 
                                            FROM Contact 
                                            WHERE LastName = 'Andersan']; 
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 35000];
                            
        //objBorrowerContact.genesis__SSN__c = '';
        objPrincipalContact.genesis__SSN__c = '391824132';
                            
        //Database.upsert(objBorrowerContact,true);
        Database.upsert(objPrincipalContact,true);

        objBorrowerAccount.clcommon__Legal_Entity_Type__c = objEntity.id;
        Database.upsert(objBorrowerAccount,true);
        List<clcommon__Party__c> objListParty = [SELECT  Name, 
                                                            Id, 
                                                            clcommon__Type__r.Name,
                                                            clcommon__Contact__r.genesis__SSN__c, 
                                                            clcommon__Account__c,
                                                            clcommon__Party_Types__c,
                                                            clcommon__Account__r.Score_1__c,
                                                            clcommon__Account__r.Score_2__c,
                                                            clcommon__Account__r.SBSS70_Score__c,
                                                            clcommon__Account__r.BK10_Score__c   
                                                    FROM clcommon__Party__c 
                                                    WHERE genesis__Application__c = :applicationObj.Id
                                                    AND (clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME OR
                                                    clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME)
                                                    AND clcommon__Account__c != null];
        System.assert(!objListParty.isEmpty(),'Party Not Found');                                            
        System.runAs(objAdmin){
            Test.startTest();                            
            FICOCreditBureauParser.createCreditBureauReport(ficoExceptionBody, (String)applicationObj.Id);
            Test.stopTest();
            List<Account> parsedAccountList = [SELECT id,FICO_Recorded_On__c FROM Account WHERE FICO_Recorded_On__c!=null];
            System.assert(parsedAccountList!=null,'No values parsed');
        }
    }
     /**
    * @description Fico PrintImage is not there in the first principal
    * @author  Pritam Roy | 01-18-2024 
    **/
    @isTest
    static void testNoFICOPrintImage(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        StaticResource ficoResponseException = new StaticResource();
        ficoResponseException = [SELECT Id,
                                        Body 
                                    FROM StaticResource 
                                    WHERE Name ='Fico_test_x'];
        String ficoExceptionBody = ficoResponseException.body.toString();

        Contact objBorrowerContact = [SELECT Id 
                                            FROM Contact 
                                            WHERE LastName = 'Albin'];
        Contact objPrincipalContact = [SELECT Id 
                                            FROM Contact 
                                            WHERE LastName = 'Andersan']; 
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 35000];
                            
        objBorrowerContact.genesis__SSN__c = '399487910';
        objPrincipalContact.genesis__SSN__c = '391824132';
                            
        Database.upsert(objBorrowerContact,true);
        Database.upsert(objPrincipalContact,true);
        List<clcommon__Party__c> objListParty = [SELECT  Name, 
                                                            Id, 
                                                            clcommon__Type__r.Name,
                                                            clcommon__Contact__r.genesis__SSN__c, 
                                                            clcommon__Account__c,
                                                            clcommon__Party_Types__c,
                                                            clcommon__Account__r.Score_1__c,
                                                            clcommon__Account__r.Score_2__c,
                                                            clcommon__Account__r.SBSS70_Score__c,
                                                            clcommon__Account__r.BK10_Score__c   
                                                    FROM clcommon__Party__c 
                                                    WHERE genesis__Application__c = :applicationObj.Id
                                                    AND (clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME OR
                                                    clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME)
                                                    AND clcommon__Account__c != null];
        System.assert(!objListParty.isEmpty(),'Party Not Found');                                            
        System.runAs(objAdmin){
            Test.startTest();                            
            FICOCreditBureauParser.createCreditBureauReport(ficoExceptionBody, (String)applicationObj.Id);
            Test.stopTest();
            List<Account> parsedAccountList = [SELECT id,FICO_Recorded_On__c FROM Account WHERE FICO_Recorded_On__c!=null];
            System.assert(parsedAccountList!=null,'No values parsed');
        }
    }
    /**
    * @description Testing FICO For Null Checks
    * @author  Pritam Roy | 01-17-2024 
    **/
    @isTest
    static void testForNullChecks(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        StaticResource ficoResponse = new StaticResource();

        ficoResponse = [SELECT Id,
                                Body 
                            FROM StaticResource 
                            WHERE Name ='Fico_test_y'];

        String ficoBody = ficoResponse.body.toString();
        Contact objBorrowerContact = [SELECT Id 
                                            FROM Contact 
                                            WHERE LastName = 'Albin'];
        Contact objPrincipalContact = [SELECT Id 
                                            FROM Contact 
                                            WHERE LastName = 'Andersan']; 
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 35000];

        objBorrowerContact.genesis__SSN__c = '506502389';
        objPrincipalContact.genesis__SSN__c = '507886136';

        Database.upsert(objBorrowerContact,true);
        Database.upsert(objPrincipalContact,true);
        List<clcommon__Party__c> objListParty = [SELECT  Name, 
                                                            Id, 
                                                            clcommon__Type__r.Name,
                                                            clcommon__Contact__r.genesis__SSN__c, 
                                                            clcommon__Account__c,
                                                            clcommon__Party_Types__c,
                                                            clcommon__Account__r.Score_1__c,
                                                            clcommon__Account__r.Score_2__c,
                                                            clcommon__Account__r.SBSS70_Score__c,
                                                            clcommon__Account__r.BK10_Score__c   
                                                    FROM clcommon__Party__c 
                                                    WHERE genesis__Application__c = :applicationObj.Id
                                                    AND (clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME OR
                                                    clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME)
                                                    AND clcommon__Account__c != null];
        System.assert(!objListParty.isEmpty(),'Party Not Found');                                            
        System.runAs(objAdmin){
            Test.startTest();                            
            FICOCreditBureauParser.createCreditBureauReport(ficoBody, (String)applicationObj.Id);
            Test.stopTest();
            List<Account> parsedAccountList = [SELECT id,FICO_Recorded_On__c FROM Account WHERE FICO_Recorded_On__c!=null];
            System.assert(parsedAccountList!=null,'No values parsed');
        }
    }
    /**
    * @description Testing FICO For Single Borrower no printImage
    * @author  Pritam Roy | 01-17-2024 
    **/
    @isTest
    static void testForSinglePrintImage(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        StaticResource ficoResponse = new StaticResource();

        ficoResponse = [SELECT Id,
                                Body 
                            FROM StaticResource 
                            WHERE Name ='Fico_test_z'];

        String ficoBody = ficoResponse.body.toString();
        Contact objBorrowerContact = [SELECT Id 
                                            FROM Contact 
                                            WHERE LastName = 'Albin'];
        genesis__Applications__c applicationObj = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Amount__c = 35000];

        objBorrowerContact.genesis__SSN__c = '666714588';
        Database.upsert(objBorrowerContact,true);                              
        System.runAs(objAdmin){
            Test.startTest();                            
            FICOCreditBureauParser.createCreditBureauReport(ficoBody, (String)applicationObj.Id);
            Test.stopTest();
            List<Account> parsedAccountList = [SELECT id,FICO_Recorded_On__c FROM Account WHERE FICO_Recorded_On__c!=null];
            System.assert(parsedAccountList!=null,'No values parsed');
        }
    }
}