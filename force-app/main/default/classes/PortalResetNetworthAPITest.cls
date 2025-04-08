/**
 * @description       :  Test class for Portal Reset Networth API
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 01-20-2025
 * @last modified by  : Shristy Kumari
**/
@isTest
private without sharing class PortalResetNetworthAPITest {
    /**
    * @description : Test Setup
    * @author  Pritam Roy | 05-30-2024 
    **/
    @TestSetup
    private static void makeData(){
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        clcommon__Legal_Entity__c legalEntityDbaObj  = ApplicationOriginationTestHelper.createDBALegalEntity();
        clcommon__Legal_Entity__c legalEntityCorpObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(new List<clcommon__Legal_Entity__c>{legalEntityObj,legalEntityDbaObj,legalEntityCorpObj},true);

        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);

        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c principalPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        clcommon__Party_Type__c dealerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('DEALER');
        Database.insert(new List<clcommon__Party_Type__c>{clPartyTypeObj, borrowerPartyTypeObj, principalPartyTypeObj, dealerPartyTypeObj},true);

        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj, borrowerBusinessInfoObj, coBorrowerBusinessInfoObj},true);

        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.id);
        dealerAccountObj.Enable_ERP_Id__c = true;
        Account saAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        borrowerAccountObj.CIF_Number__c = '123456';
        borrowerAccountObj.Coop_Type__c = 'CFA';
        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(legalEntityObj,coBorrowerBusinessInfoObj.id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        Database.insert(new List<Account>{dealerAccountObj, saAccountObj, clAccountObj, borrowerAccountObj, coBorrowerAccountObj},true);

        Contact saContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(saAccountObj.id);
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        borrowerContactObj.genesis__SSN__c = '324242424';
        borrowerContactObj.Confirm_SSN__c = '324242424';
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        Database.insert(new List<Contact>{saContactObj, clContactObj, borrowerContactObj,coBorrowerContactObj},true);

        User userObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.id);
        Database.insert(userObj,true);

        clcommon__Reciprocal_Role__c clRole = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(clRole,true);

        clcommon__Relationship__c clRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(clRole,dealerAccountObj.id,clAccountObj.id);
        Database.insert(clRelationship,true);

        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.id);
        Database.insert(borrowerUserObj,true);

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(new Map<String, Id>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'saAccountObjId' => saAccountObj.id
        });
        applicationObj.genesis__Product_Type__c ='Package';
        applicationObj.genesis__Loan_Amount__c = 82400;
        applicationObj.FICO_Score__c = '680';
        applicationObj.SBSS_70_Score__c = '160';
        Database.insert(applicationObj,true); 

        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => borrowerPartyTypeObj.id,
            'applicationId' => applicationObj.id
        });
        partyObj.clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;

        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
            'accountId' => clAccountObj.id,
            'contactId' => clContactObj.id,
            'partyTypeId' => clPartyTypeObj.id,
            'applicationId' => applicationObj.id
        });

        clcommon__Party__c coPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
            'accountId' => coBorrowerAccountObj.id,
            'contactId' => coBorrowerContactObj.id,
            'partyTypeId' => principalPartyTypeObj.id,
            'applicationId' => applicationObj.id
        });
        coPartyObj.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;
        Database.insert(new List<clcommon__Party__c>{partyObj, clPartyObj, coPartyObj},true);

        CFA_Configuration__c cifObj = ApplicationOriginationTestHelper.createCIFNumber();
        Database.insert(cifObj,true);

        List<genesis__Credit_Rating_Matrix__c> creditMatrixList = FICOCalloutTestHelper.createAllCreditRatingMatrix();
        Database.insert(creditMatrixList, true);
    }
    /**
    * @description : method to update legal entity of borrower
    * @param entityType 
    * @param objBorrowerAccount 
    **/
    private static void updateLegalEntity(String entityType, Account objBorrowerAccount){
        clcommon__Legal_Entity__c objEntity = [SELECT Id FROM clcommon__Legal_Entity__c WHERE name =: entityType];
        objBorrowerAccount.clcommon__Legal_Entity_Type__c = objEntity.id;
        Database.update(objBorrowerAccount, true);
    }
    /**
    * @description Method to fetch the cl user
    * @author Soumik Pattanayak | 08-10-2024 
    * @return User 
    **/
    private static User getClUser(){
        List<User> objUserList = [SELECT Id 
                                    FROM User 
                                    WHERE AccountId IN (
                                        SELECT Id 
                                        FROM Account 
                                        WHERE Name = 'Ross Geller')];
                                    
        if(objUserList.size() == 1){
            return objUserList[0];
        } 
        return null;
    }
    /**
    * @description Method to fetch the Application
    * @author Shristy Kumari | 01-11-2025 
    * @return  genesis__Applications__c
    **/
    private static genesis__Applications__c getApplication(){
        List<genesis__Applications__c> applicationList =[SELECT Id,
                                                                  Net_Worth__c, 
                                                                  Evergreen_Tier_Two_Business_Info_Status__c
                                                         FROM genesis__Applications__c 
                                                         WHERE genesis__Loan_Amount__c = 82400 
                                                         AND FICO_Score__c = '680' 
                                                         AND SBSS_70_Score__c = '160' 
                                                         LIMIT 1];
                                    
        if(applicationList.size() == 1){
            return applicationList[0];
        } 
        return null;
    }
    /**
    * @description Method to fetch the credit rating matrix
    * @author Shristy Kumari | 01-11-2025 
    * @return  genesis__Credit_Rating_Matrix__c
    **/
    private static genesis__Credit_Rating_Matrix__c getCreditRate(){
        List<genesis__Credit_Rating_Matrix__c> creditRatesList = [SELECT Id,
                                                                         Name 
                                                                  FROM genesis__Credit_Rating_Matrix__c 
                                                                  WHERE Name = 'Tier 2' 
                                                                  LIMIT 1];
                                    
        if(creditRatesList.size() == 1){
            return creditRatesList[0];
        } 
        return null;
    }
    /**
    * @description : Test Reset Net Worth Success
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testResetNetWorthSuccess(){
       User clUserObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRates = getCreditRate();
        applicationObj.genesis__Credit_Rating__c = creditRates.Id;
        Database.upsert(applicationObj,false);
        requestMap.put('applicationId', applicationObj.id);

        System.debug('----->' + [SELECT Id, Owner.Name
    FROM genesis__Applications__c 
    WHERE Id = :applicationObj.id 
    LIMIT 1]);
        System.runAs(clUserObj){ 
            Test.startTest();

            System.debug('----->' + [SELECT Id, Owner.Name
    FROM genesis__Applications__c 
    WHERE Id = :applicationObj.id 
    LIMIT 1]);


            PortalResetNetworthAPI portalResetNetworthAPIObj = new PortalResetNetworthAPI();
            clcommon.Response responseObj = portalResetNetworthAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, responseObj.status, 'Assertion Failed'); 
            Test.stopTest();
        }
        List<genesis__Applications__c> updatedApplicationList = [SELECT Id,
                                                                            Net_Worth__c, 
                                                                            Evergreen_Tier_Two_Business_Info_Status__c
                                                                    FROM genesis__Applications__c 
                                                                    WHERE Id = :applicationObj.id 
                                                                    LIMIT 1];
        System.assertEquals(null, updatedApplicationList[0].Net_Worth__c, 'Net Worth was not reset to NULL');
        System.assertEquals(PortalConstants.EVERGREEN_BIZ_STATUS_IN_PROGRESS, updatedApplicationList[0].Evergreen_Tier_Two_Business_Info_Status__c, 'Evergreen Tier Two status was not set to IN PROGRESS');
    }
    /**
    * @description : Test Reset Net Worth No Business Info No Business Info Exception
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testResetNetWorthNoBusinessInfoException(){
        User clUserObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRates = getCreditRate();
        applicationObj.genesis__Credit_Rating__c = creditRates.Id;
        Database.upsert(applicationObj,false);
        List<genesis__Business_Information__c> delBusinessInfoList = [SELECT Id FROM genesis__Business_Information__c];
        Database.delete(delBusinessInfoList, true);
        requestMap.put('applicationId', applicationObj.id);
        System.runAs(clUserObj){ 
            Test.startTest();
            PortalResetNetworthAPI portalResetNetworthAPIObj = new PortalResetNetworthAPI();
            clcommon.Response responseObj = portalResetNetworthAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, 'Assertion Failed'); 
            List<clcommon__Log__c> logList = [SELECT Name
                                          FROM clcommon__Log__c 
                                          WHERE Name= 'PortalResetNetworthAPI'
                                          LIMIT 1];
            System.assertEquals('PortalResetNetworthAPI', logList[0].Name,'Exception Expected');
            Test.stopTest();
        }
    }
    /**
    * @description : Test Reset Net Worth No App Id Exception
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testResetNetWorthWrongApplicationIdException(){
        User clUserObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRates = getCreditRate();
        applicationObj.genesis__Credit_Rating__c = creditRates.Id;
        Database.upsert(applicationObj,true);

        requestMap.put('applicationId', '"'+applicationObj.id);
        System.runAs(clUserObj){ 
            Test.startTest();
            PortalResetNetworthAPI portalResetNetworthAPIObj = new PortalResetNetworthAPI();
            clcommon.Response responseObj = portalResetNetworthAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, 'Assertion Failed'); 
            List<clcommon__Log__c> logList = [SELECT Name
                                          FROM clcommon__Log__c 
                                          WHERE Name= 'PortalResetNetworthAPI'
                                          LIMIT 1];
            System.assertEquals('PortalResetNetworthAPI', logList[0].Name,'Exception Expected');
            Test.stopTest();
        }
    }
    /**
    * @description : Test Reset Net Worth Wrong User Exception
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testResetNetWorthWrongUserException(){
        User clUserObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRates = getCreditRate();
        applicationObj.genesis__Credit_Rating__c = creditRates.Id;
        Database.upsert(applicationObj,false);
        List<clcommon__party__c> objCLparty = [SELECT Id,clcommon__Contact__c,genesis__Application__c FROM clcommon__party__c WHERE clcommon__Account__r.name = 'Ross Geller'];
        objCLparty[0].genesis__Application__c = NULL;
        Database.upsert(objCLparty, true);
        requestMap.put('applicationId', JSON.serialize(applicationObj.id));
        System.runAs(clUserObj){ 
            Test.startTest();
            PortalResetNetworthAPI portalResetNetworthAPIObj = new PortalResetNetworthAPI();
            clcommon.Response responseObj = portalResetNetworthAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, 'Assertion Failed'); 
            List<clcommon__Log__c> logList = [SELECT Name
                                          FROM clcommon__Log__c 
                                          WHERE Name= 'PortalResetNetworthAPI'
                                          LIMIT 1];
            System.assertEquals('PortalResetNetworthAPI', logList[0].Name,'Exception Expected');
            Test.stopTest();
        }
    }
    /**
    * @description : Test Reset Net Worth No Party Exception
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testResetNetWorthNoPartyExcption(){
        User clUserObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRates = getCreditRate();
        applicationObj.genesis__Credit_Rating__c = creditRates.Id;
        Database.upsert(applicationObj,false);
        List<clcommon__party__c> objCLparty = [SELECT Id,clcommon__Contact__c,genesis__Application__c FROM clcommon__party__c WHERE clcommon__Party_Types__c IN (:PortalConstants.BORROWER_PARTY_NAME,:PortalConstants.PRINCIPAL_PARTY_NAME)];
        Database.delete(objCLparty, true);
        requestMap.put('applicationId', '"'+applicationObj.id);
        System.runAs(clUserObj){ 
            Test.startTest();
            PortalResetNetworthAPI portalResetNetworthAPIObj = new PortalResetNetworthAPI();
            clcommon.Response responseObj = portalResetNetworthAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, 'Assertion Failed'); 
            List<clcommon__Log__c> logList = [SELECT Name
                                          FROM clcommon__Log__c 
                                          WHERE Name= 'PortalResetNetworthAPI'
                                          LIMIT 1];
            System.assertEquals('PortalResetNetworthAPI', logList[0].Name,'Exception Expected');
            Test.stopTest();
        }
    }
    /**
    * @description : Test Reset Net Worth DBA Success
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testResetNetWorthDBASuccess(){
        User clUserObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRates = getCreditRate();
        applicationObj.genesis__Credit_Rating__c = creditRates.Id;
        Database.upsert(applicationObj,false);
        Account objBorrowerAccount = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin'];
        updateLegalEntity('Individual(s) with DBA', objBorrowerAccount);
        requestMap.put('applicationId', applicationObj.id);
        System.runAs(clUserObj){ 
            Test.startTest();
            PortalResetNetworthAPI portalResetNetworthAPIObj = new PortalResetNetworthAPI();
            clcommon.Response responseObj = portalResetNetworthAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, responseObj.status, 'Assertion Failed'); 
            Test.stopTest();
        }
        List<genesis__Applications__c> updatedApplicationList = [SELECT Id,
                                                                            Net_Worth__c, 
                                                                            Evergreen_Tier_Two_Business_Info_Status__c
                                                                    FROM genesis__Applications__c 
                                                                    WHERE Id = :applicationObj.id 
                                                                    LIMIT 1];
        System.assertEquals(null, updatedApplicationList[0].Net_Worth__c, 'Net Worth was not reset to NULL');
        System.assertEquals(PortalConstants.EVERGREEN_BIZ_STATUS_IN_PROGRESS, updatedApplicationList[0].Evergreen_Tier_Two_Business_Info_Status__c, 'Evergreen Tier Two status was not set to IN PROGRESS');
    }
    /**
    * @description : Test Reset Net Worth Corp Success
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testResetNetWorthCorpSuccess(){
        User clUserObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRates = getCreditRate();
        applicationObj.genesis__Credit_Rating__c = creditRates.Id;
        Database.upsert(applicationObj,false);
        Account objBorrowerAccount = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin'];
        updateLegalEntity('Corporation', objBorrowerAccount);
        requestMap.put('applicationId', applicationObj.id);
        System.runAs(clUserObj){ 
            Test.startTest();
            PortalResetNetworthAPI portalResetNetworthAPIObj = new PortalResetNetworthAPI();
            clcommon.Response responseObj = portalResetNetworthAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, responseObj.status, 'Assertion Failed');
            Test.stopTest();
        }
        List<genesis__Applications__c> updatedApplicationList = [SELECT Id,
                                                                            Net_Worth__c, 
                                                                            Evergreen_Tier_Two_Business_Info_Status__c
                                                                    FROM genesis__Applications__c 
                                                                    WHERE Id = :applicationObj.id 
                                                                    LIMIT 1];
        System.assertEquals(null, updatedApplicationList[0].Net_Worth__c, 'Net Worth was not reset to NULL');
        System.assertEquals(PortalConstants.EVERGREEN_BIZ_STATUS_IN_PROGRESS, updatedApplicationList[0].Evergreen_Tier_Two_Business_Info_Status__c, 'Evergreen Tier Two status was not set to IN PROGRESS');
    }
     /**
    * @description : Test Reset Net Worth  Party Exception
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testResetNetWorthPartyExcption(){
        User clUserObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRates = getCreditRate();
        applicationObj.genesis__Credit_Rating__c = creditRates.Id;
        Database.upsert(applicationObj,false);
        List<clcommon__party__c> objCLparty = [SELECT Id,clcommon__Contact__c,genesis__Application__c FROM clcommon__party__c WHERE clcommon__Account__r.name = 'Ross Geer'];
        Database.upsert(objCLparty, true);
        requestMap.put('applicationId', '"'+applicationObj.id);
        System.runAs(clUserObj){ 
            Test.startTest();
            PortalResetNetworthAPI portalResetNetworthAPIObj = new PortalResetNetworthAPI();
            clcommon.Response responseObj = portalResetNetworthAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, 'Assertion Failed'); 
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'PortalResetNetworthAPI'
                                              LIMIT 1];
            System.assertEquals('PortalResetNetworthAPI', logList[0].Name,'Exception Expected');
            Test.stopTest();
        }
    }
    /**
    * @description : Test success scenerio to Reset Net Worth Success by borrower user
    * @author  Shristy Kumari | 01-06-2025
    **/
    @isTest
    private static void testResetNetWorthSuccessByBorrower(){
        User borrowerUserObj = [SELECT Id,contactId FROM user WHERE username = 'star.lord@yopmail.com'];
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRates = getCreditRate();
        applicationObj.genesis__Credit_Rating__c = creditRates.Id;
        Database.upsert(applicationObj,false);
        requestMap.put('applicationId', applicationObj.id);
        System.runAs(borrowerUserObj){ 
            Test.startTest();
            PortalResetNetworthAPI portalResetNetworthAPIObj = new PortalResetNetworthAPI();
            clcommon.Response responseObj = portalResetNetworthAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, responseObj.status, 'Assertion Failed to Reset Net Worth by borrower user'); 
            Test.stopTest();
        }
    }
}