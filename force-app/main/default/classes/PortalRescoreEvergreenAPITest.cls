/**
 * @description       :  Test class for PortalRescoreEvergreenAPI
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 01-20-2025
 * @last modified by  : Shristy Kumari
**/
@isTest
private with sharing class PortalRescoreEvergreenAPITest {
    /**
    * @description : Test Setup
    * @author  Pritam Roy | 05-30-2024 
    **/
    @TestSetup
    private static void makeData(){
        //creating legal entity for individual sole prop
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        //creating legal entity for DBA
        clcommon__Legal_Entity__c legalEntityDbaObj  = ApplicationOriginationTestHelper.createDBALegalEntity();
        //creating legal entity for Corporation
        clcommon__Legal_Entity__c legalEntityCorpObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(new List<clcommon__Legal_Entity__c>{legalEntityObj,legalEntityDbaObj,legalEntityCorpObj},true);
        //creating cl product
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);
        //creating cl purpose
        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);
        // creating parties
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c principalPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        clcommon__Party_Type__c dealerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('DEALER');
        Database.insert(new List<clcommon__Party_Type__c>{clPartyTypeObj, borrowerPartyTypeObj, principalPartyTypeObj, dealerPartyTypeObj},true);
        // creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c businessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj, businessInfoObj},true);
        // creating account
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.id);
        dealerAccountObj.Enable_ERP_Id__c = true;
        Account saAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Account saAdminAccountObj = ApplicationOriginationTestHelper.createSAAdminAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Database.insert(new List<Account>{dealerAccountObj, saAccountObj, saAdminAccountObj, clAccountObj},true);
        //creating contact
        Contact saContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(saAccountObj.id);
        Contact saAdminContactObj=ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccountObj.Id);
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
        Database.insert(new List<Contact>{saContactObj, saAdminContactObj, clContactObj},true);
        //creating cl user
        User userObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.id);
        User saUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(saContactObj.Id);
        User saAdminUserObj = ApplicationOriginationTestHelper.createSAAdminUser(saAdminContactObj.Id);
        Database.insert(new List<User>{userObj, saUserObj, saAdminUserObj},true);
        //creating reciprocal role
        clcommon__Reciprocal_Role__c clRole = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(clRole,true);
        // creating dealer cl relationship
        clcommon__Relationship__c clRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(clRole,dealerAccountObj.id,clAccountObj.id);
        Database.insert(clRelationship,true);
        // creating borrower business info
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);
        // creating borrower account
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        borrowerAccountObj.CIF_Number__c = '123456';
        borrowerAccountObj.Coop_Type__c = 'CFA';
        Database.insert(borrowerAccountObj,true);
        // creating borrower contact
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        borrowerContactObj.genesis__SSN__c = '324242424';
        borrowerContactObj.Confirm_SSN__c = '324242424';
        Database.insert(borrowerContactObj,true);
        //creating coborrower business info
        genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(coBorrowerBusinessInfoObj,true);
        // creating coborrower account
        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(legalEntityObj,coBorrowerBusinessInfoObj.id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        Database.insert(coBorrowerAccountObj,true);
        // creating coborrower contact
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        Database.insert(coBorrowerContactObj,true);
        // creating application
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
        //creating borrower party
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => borrowerPartyTypeObj.id,
            'applicationId' => applicationObj.id
        });
        partyObj.clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;
        //creating cl party
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
            'accountId' => clAccountObj.id,
            'contactId' => clContactObj.id,
            'partyTypeId' => clPartyTypeObj.id,
            'applicationId' => applicationObj.id
        });
        // creating coborrower party
        clcommon__Party__c coPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
            'accountId' => coBorrowerAccountObj.id,
            'contactId' => coBorrowerContactObj.id,
            'partyTypeId' => principalPartyTypeObj.id,
            'applicationId' => applicationObj.id
        });
        coPartyObj.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;
        Database.insert(new List<clcommon__Party__c>{partyObj, clPartyObj, coPartyObj},true);
        //creating cfa configuration
        CFA_Configuration__c cifObj = ApplicationOriginationTestHelper.createCIFNumber();
        Database.insert(cifObj,true);
        //creating credit rating matrix
        List<genesis__Credit_Rating_Matrix__c> creditMatrixList = FICOCalloutTestHelper.createAllCreditRatingMatrix();
        Database.insert(creditMatrixList, true);
    }
    /**
    * @description Method to fetch the cl user
    * @author Shristy Kumari | 01-08-2025 
    * @return User 
    **/
    private static User getClUser(){
        List<User> objClUserList = [SELECT Id,
                                         contactId
                                    FROM User 
                                    WHERE username = 'ross.geller@yopmail.com'
                                    LIMIT 1];         
        if (objClUserList.size() == 1) {
            return objClUserList[0];
        } 
        return null;
    }
    /**
    * @description Method to fetch application
    * @author Shristy Kumari | 01-08-2025 
    * @return User 
    **/
    private static genesis__Applications__c getApplication(){
        List<genesis__Applications__c> applicationObjList = [SELECT Id
                                                                FROM genesis__Applications__c  
                                                                WHERE genesis__Loan_Amount__c = 82400
                                                                AND FICO_Score__c = '680'
                                                                AND SBSS_70_Score__c = '160'
                                                                LIMIT 1];
        if (applicationObjList.size() == 1){
             return applicationObjList[0];
        } 
        
        return null;
    }
    /**
    * @description Method to fetch the cl user
    * @author Shristy Kumari | 01-08-2025 
    * @return User 
    **/
    private static clcommon__Party__c getBorrowerParty(){
        List<clcommon__Party__c> objBorrPartyList = [SELECT Id,
                                                              clcommon__Account__c
                                                     FROM clcommon__Party__c
                                                     WHERE clcommon__Account__r.name = 'Jasmine Albin'
                                                     LIMIT 1];         
        if (objBorrPartyList.size() == 1) {
            return objBorrPartyList[0];
        } 
        return null;
    }
    /**
    * @description Method to fetch credit rating matrix
    * @author Shristy Kumari | 01-08-2025 
    * @return User 
    **/
    private static genesis__Credit_Rating_Matrix__c getCreditRateMatrixTearTwo(){
        List<genesis__Credit_Rating_Matrix__c> objCreditRatingMatrixList = [SELECT Id,
                                                                                     Name 
                                                                                 FROM genesis__Credit_Rating_Matrix__c 
                                                                                 WHERE Name = 'Tier 2' 
                                                                                 LIMIT 1];       
        if (objCreditRatingMatrixList.size() == 1) {
            return objCreditRatingMatrixList[0];
        } 
        return null;
    }
    /**
    * @description : Updates legal entity
    * @param entityType 
    * @param objBorrowerAccount 
    **/
    private static void updateLegalEntity(String entityType, Account objBorrowerAccount){
        clcommon__Legal_Entity__c objEntity = [SELECT Id FROM clcommon__Legal_Entity__c WHERE name =: entityType];
        objBorrowerAccount.clcommon__Legal_Entity_Type__c = objEntity.id;
        Database.update(objBorrowerAccount, true);
    }
    /**
    * @description : Test Rescore Evergreen Success
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testRescoreEvergreenSuccess(){
        User userObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRatesObj = getCreditRateMatrixTearTwo();
        applicationObj.genesis__Credit_Rating__c = creditRatesObj.Id;
        Database.upsert(applicationObj,false);
        requestMap.put('shouldValidate', true);
        clcommon__Party__c objBorrowerParty = getBorrowerParty();
        List<Map<String, Object>> subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'id' => objBorrowerParty.id,
                'Total_Assets__c' => 1000,
                'Total_Liabilities__c' => 200,
                'Gross_Farm_Income__c' => 3000,
                'clcommon__Account__r.Year_Began_Farming__c' => 2024
            }
        );
        requestMap.put('applicationId', applicationObj.id);
        requestMap.put('businessDetails',JSON.serialize(subTrancheInfoList));
        System.runAs(userObj){ 
            Test.startTest();
            PortalRescoreEvergreenAPI rescoreEvergreenAPIObj = new PortalRescoreEvergreenAPI();
            clcommon.Response responseObj = rescoreEvergreenAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, responseObj.status, 'Assertion Failed');
            
            Test.stopTest();
        }
        clcommon__Party__c updatedParty = [SELECT Id, Total_Assets__c, Total_Liabilities__c, Gross_Farm_Income__c FROM clcommon__Party__c WHERE Id = :objBorrowerParty.Id LIMIT 1];
        System.assertEquals(1000, updatedParty.Total_Assets__c, 'Party Total Assets not updated correctly');
        System.assertEquals(200, updatedParty.Total_Liabilities__c, 'Party Total Liabilities not updated correctly');
        System.assertEquals(3000, updatedParty.Gross_Farm_Income__c, 'Party Gross Farm Income not updated correctly'); 
    }
     /**
    * @description : Test Rescore Evergreen Success for tier four
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testRescoreEvergreenTierFourSuccess(){
        User userObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRatesObj = [SELECT Id,Name FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 4' LIMIT 1];
        applicationObj.genesis__Credit_Rating__c = creditRatesObj.Id;
        Database.upsert(applicationObj,false);
        requestMap.put('shouldValidate', true);
        clcommon__Party__c borrowerPartyObj = getBorrowerParty();
        List<Map<String, Object>> subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'id' => borrowerPartyObj.id,
                'Total_Assets__c' => 0,
                'Total_Liabilities__c' => 200,
                'Gross_Farm_Income__c' => 3000,
                'clcommon__Account__r.Year_Began_Farming__c' => 2024
            }
        );
        requestMap.put('applicationId', applicationObj.id);
        requestMap.put('businessDetails',JSON.serialize(subTrancheInfoList));
        System.runAs(userObj){ 
            Test.startTest();
            PortalRescoreEvergreenAPI rescoreEvergreenAPIObj = new PortalRescoreEvergreenAPI();
            clcommon.Response responseObj = rescoreEvergreenAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, responseObj.status, 'Application not rescored successfully for tier four'); 
            Test.stopTest();
        }
        Account updatedAccount = [SELECT Id, Year_Began_Farming__c FROM Account WHERE Id = :borrowerPartyObj.clcommon__Account__c LIMIT 1];
        System.assertEquals('2024', updatedAccount.Year_Began_Farming__c, 'Account Year Began Farming not updated correctly');
    }
     /**
    * @description : Test Rescore Evergreen Success on Save and Exit
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testRescoreEvergreenSaveAndExitSuccess(){
        User userObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRatesObj = getCreditRateMatrixTearTwo();
        applicationObj.genesis__Credit_Rating__c = creditRatesObj.Id;
        Database.upsert(applicationObj,false);
        requestMap.put('shouldValidate', false);
        clcommon__Party__c borrowerPartyObj = getBorrowerParty();
        List<Map<String, Object>> subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'id' => borrowerPartyObj.id,
                'Total_Assets__c' => 2000,
                'Total_Liabilities__c' => 200,
                'Gross_Farm_Income__c' => 3000,
                'clcommon__Account__r.Year_Began_Farming__c' => 2024
            }
        );
        requestMap.put('applicationId', applicationObj.id);
        requestMap.put('businessDetails',JSON.serialize(subTrancheInfoList));

        System.runAs(userObj){ 
            Test.startTest();
            PortalRescoreEvergreenAPI rescoreEvergreenAPIObj = new PortalRescoreEvergreenAPI();
            clcommon.Response responseObj = rescoreEvergreenAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, responseObj.status, 'Assertion Failed to test Success on Save and Exit'); 
            Test.stopTest();
        }
        Account updatedAccount = [SELECT Id, Year_Began_Farming__c FROM Account WHERE Id = :borrowerPartyObj.clcommon__Account__c LIMIT 1];
        System.assertEquals('2024', updatedAccount.Year_Began_Farming__c, 'Account Year Began Farming not updated correctly');
    }
     /**
    * @description : Test Rescore Evergreen Null check success scenerio
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testRescoreEvergreenSaveAndExitNullCheck(){
        User userObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRatesObj = getCreditRateMatrixTearTwo();
        applicationObj.genesis__Credit_Rating__c = creditRatesObj.Id;
        Database.upsert(applicationObj,false);
        requestMap.put('shouldValidate', false);
        clcommon__Party__c borrowerPartyObj = getBorrowerParty();
        List<Map<String, Object>> subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'id' => borrowerPartyObj.id,
                'Total_Assets__c' => NULL,
                'Total_Liabilities__c' => NULL,
                'Gross_Farm_Income__c' => NULL,
                'clcommon__Account__r.Year_Began_Farming__c' => 2024
            }
        );
        requestMap.put('applicationId', applicationObj.id);
        requestMap.put('businessDetails',JSON.serialize(subTrancheInfoList));
        System.runAs(userObj){ 
            Test.startTest();
            PortalRescoreEvergreenAPI rescoreEvergreenAPIObj = new PortalRescoreEvergreenAPI();
            clcommon.Response responseObj = rescoreEvergreenAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, responseObj.status, 'Assertion Failed to test Rescore Evergreen Null check success scenerio'); 
            Test.stopTest();
        }
        Account updatedAccount = [SELECT Id, Year_Began_Farming__c FROM Account WHERE Id = :borrowerPartyObj.clcommon__Account__c LIMIT 1];
        System.assertEquals('2024', updatedAccount.Year_Began_Farming__c, 'Account Year Began Farming not updated correctly');
    }
    /**
    * @description : Test Rescore Evergreen Success with Co - applicants
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testRescoreEvergreenCoApplicantsSuccess(){
        User userObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRatesObj = getCreditRateMatrixTearTwo();
        applicationObj.genesis__Credit_Rating__c = creditRatesObj.Id;
        Database.upsert(applicationObj,false);
        requestMap.put('shouldValidate', true);
        clcommon__Party__c borrowerPartyObj = getBorrowerParty();
        clcommon__Party__c objCoBorrowerParty = [SELECT Id,clcommon__Account__c FROM clcommon__party__c WHERE clcommon__Account__r.name = 'Mike Johnson'];

        List<Map<String, Object>> subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'id' => borrowerPartyObj.id,
                'Total_Assets__c' => 2000,
                'Total_Liabilities__c' => 0,
                'Gross_Farm_Income__c' => 3000,
                'clcommon__Account__r.Year_Began_Farming__c' => 2024
            }
        );
        subTrancheInfoList.add(
            new Map<String, Object>{
                'id' => objCoBorrowerParty.id,
                'Total_Assets__c' => 2000,
                'Total_Liabilities__c' => 0,
                'Gross_Farm_Income__c' => 3000,
                'clcommon__Account__r.Year_Began_Farming__c' => 2024
            }
        );
        requestMap.put('applicationId', applicationObj.id);
        requestMap.put('businessDetails',JSON.serialize(subTrancheInfoList));
        System.runAs(userObj){ 
            Test.startTest();
            PortalRescoreEvergreenAPI rescoreEvergreenAPIObj = new PortalRescoreEvergreenAPI();
            clcommon.Response responseObj = rescoreEvergreenAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, responseObj.status, 'Application not rescored successfully for application with co-applicants'); 
            Test.stopTest();
        }
        Account updatedAccount = [SELECT Id, Year_Began_Farming__c FROM Account WHERE Id = :objCoBorrowerParty.clcommon__Account__c LIMIT 1];
        System.assertEquals('2024', updatedAccount.Year_Began_Farming__c, 'Account Year Began Farming not updated correctly');
    }
    /**
    * @description : Test Rescore Evergreen Success for DBA
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testRescoreEvergreenDBASuccess(){
        User userObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRatesObj = getCreditRateMatrixTearTwo();
        applicationObj.genesis__Credit_Rating__c = creditRatesObj.Id;
        Database.upsert(applicationObj,false);
        requestMap.put('shouldValidate', true);
        clcommon__Party__c borrowerPartyObj = getBorrowerParty();
        Account objBorrowerAccount = [SELECT Id FROM Account WHERE name = 'Jasmine Albin'];
        updateLegalEntity('Individual(s) with DBA', objBorrowerAccount);
        clcommon__Party__c objCoBorrowerParty = [SELECT Id FROM clcommon__party__c WHERE clcommon__Account__r.name = 'Mike Johnson'];

        List<Map<String, Object>> subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'id' => borrowerPartyObj.id,
                'Total_Assets__c' => 20000,
                'Total_Liabilities__c' => 20,
                'Gross_Farm_Income__c' => 3000,
                'clcommon__Account__r.Year_Began_Farming__c' => 2024
            }
        );
        subTrancheInfoList.add(
            new Map<String, Object>{
                'id' => objCoBorrowerParty.id,
                'Total_Assets__c' => 2000,
                'Total_Liabilities__c' => 200,
                'Gross_Farm_Income__c' => 3000,
                'clcommon__Account__r.Year_Began_Farming__c' => 2024
            }
        );
        requestMap.put('applicationId', applicationObj.id);
        requestMap.put('businessDetails',JSON.serialize(subTrancheInfoList));
        System.runAs(userObj){ 
            Test.startTest();
            PortalRescoreEvergreenAPI rescoreEvergreenAPIObj = new PortalRescoreEvergreenAPI();
            clcommon.Response responseObj = rescoreEvergreenAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, responseObj.status, 'Application not rescored successfully for DBA'); 
            Test.stopTest();
        }
        Account updatedAccount = [SELECT Id, Year_Began_Farming__c FROM Account WHERE Id = :borrowerPartyObj.clcommon__Account__c LIMIT 1];
        System.assertEquals('2024', updatedAccount.Year_Began_Farming__c, 'Account Year Began Farming not updated correctly');      
    }
    /**
    * @description : Test Rescore Evergreen Success for Corporation
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testRescoreEvergreenCorpSuccess(){
        User userObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRatesObj = getCreditRateMatrixTearTwo();
        applicationObj.genesis__Credit_Rating__c = creditRatesObj.Id;
        Database.upsert(applicationObj,false);
        requestMap.put('shouldValidate', true);
        clcommon__Party__c borrowerPartyObj = getBorrowerParty();
        Account objBorrowerAccount = [SELECT Id FROM Account WHERE name = 'Jasmine Albin'];
        updateLegalEntity('Corporation', objBorrowerAccount);
        clcommon__Party__c objCoBorrowerParty = [SELECT Id FROM clcommon__party__c WHERE clcommon__Account__r.name = 'Mike Johnson'];

        List<Map<String, Object>> subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'id' => borrowerPartyObj.id,
                'Total_Assets__c' => 1500000,
                'Total_Liabilities__c' => 200,
                'Gross_Farm_Income__c' => 3000,
                'clcommon__Account__r.Year_Began_Farming__c' => 2024
            }
        );
        subTrancheInfoList.add(
            new Map<String, Object>{
                'id' => objCoBorrowerParty.id,
                'Total_Assets__c' => 0,
                'Total_Liabilities__c' => 200,
                'Gross_Farm_Income__c' => 3000,
                'clcommon__Account__r.Year_Began_Farming__c' => 2024
            }
        );
        requestMap.put('applicationId', applicationObj.id);
        requestMap.put('businessDetails',JSON.serialize(subTrancheInfoList));

        System.runAs(userObj){ 
            Test.startTest();
            PortalRescoreEvergreenAPI rescoreEvergreenAPIObj = new PortalRescoreEvergreenAPI();
            clcommon.Response responseObj = rescoreEvergreenAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, responseObj.status, 'Application not rescored successfully for corporation'); 
            Test.stopTest();
        }
        Account updatedAccount = [SELECT Id, Year_Began_Farming__c FROM Account WHERE Id = :borrowerPartyObj.clcommon__Account__c LIMIT 1];
        System.assertEquals('2024', updatedAccount.Year_Began_Farming__c, 'Account Year Began Farming not updated correctly');
    }
    /**
    * @description : Test Rescore Evergreen Missing Arguments Exception
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testRescoreEvergreenMissingArgumentsException(){
        User userObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRatesObj = getCreditRateMatrixTearTwo();
        applicationObj.genesis__Credit_Rating__c = creditRatesObj.Id;
        Database.upsert(applicationObj,false);
        clcommon__Party__c borrowerPartyObj = getBorrowerParty();
        clcommon__Party__c objCoBorrowerParty = [SELECT Id FROM clcommon__party__c WHERE clcommon__Account__r.name = 'Mike Johnson'];

        List<Map<String, Object>> subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'id' => borrowerPartyObj.id,
                'Total_Assets__c' => 0,
                'Total_Liabilities__c' => 200,
                'Gross_Farm_Income__c' => 3000,
                'clcommon__Account__r.Year_Began_Farming__c' => 2024
            }
        );
        subTrancheInfoList.add(
            new Map<String, Object>{
                'id' => objCoBorrowerParty.id,
                'Total_Assets__c' => 0,
                'Total_Liabilities__c' => 200,
                'Gross_Farm_Income__c' => 3000,
                'clcommon__Account__r.Year_Began_Farming__c' => 2024
            }
        );
        requestMap.put('businessDetails',JSON.serialize(subTrancheInfoList));
        System.runAs(userObj){ 
            Test.startTest();
            PortalRescoreEvergreenAPI rescoreEvergreenAPIObj = new PortalRescoreEvergreenAPI();
            clcommon.Response responseObj = rescoreEvergreenAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, 'Exception expected for missing arguments'); 
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'PortalRescoreEvergreenAPI'
                                              LIMIT 1];
            System.assertEquals('PortalRescoreEvergreenAPI', logList[0].Name,'Exception Expected');
            Test.stopTest();
        }
    }
    /**
    * @description : Test Rescore Evergreen exception by salesagent user
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testRescoreEvergreenExceptionBySaUser(){
        User saUser = [SELECT Id,UserName FROM User WHERE UserName='tony.stark@yopmail.com' LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRatesObj = getCreditRateMatrixTearTwo();
        applicationObj.genesis__Credit_Rating__c = creditRatesObj.Id;
        Database.upsert(applicationObj,false);
        requestMap.put('shouldValidate', true);
        clcommon__Party__c objBorrowerParty = getBorrowerParty();
        List<Map<String, Object>> subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'id' => objBorrowerParty.id,
                'Total_Assets__c' => 1000,
                'Total_Liabilities__c' => 200,
                'Gross_Farm_Income__c' => 3000,
                'clcommon__Account__r.Year_Began_Farming__c' => 2024
            }
        );
        requestMap.put('applicationId', applicationObj.id);
        requestMap.put('businessDetails',JSON.serialize(subTrancheInfoList));
        System.runAs(saUser){ 
            Test.startTest();
            PortalRescoreEvergreenAPI rescoreEvergreenAPIObj = new PortalRescoreEvergreenAPI();
            clcommon.Response responseObj = rescoreEvergreenAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, 'Exception expected for missing arguments'); 
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'PortalRescoreEvergreenAPI'
                                              LIMIT 1];
            System.assertEquals('PortalRescoreEvergreenAPI', logList[0].Name,'Exception Expected');
            Test.stopTest();
        }
    }
    /**
    * @description : Test Rescore Evergreen by salesagent Admin user exception
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testRescoreEvergreenExceptionBySaAdminUser(){
        User saUser = [SELECT Id,UserName FROM User WHERE UserName='tim.couper@yopmail.com' LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRatesObj = getCreditRateMatrixTearTwo();
        applicationObj.genesis__Credit_Rating__c = creditRatesObj.Id;
        Database.upsert(applicationObj,false);
        requestMap.put('shouldValidate', true);
        clcommon__Party__c objBorrowerParty = getBorrowerParty();
        List<Map<String, Object>> subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'id' => objBorrowerParty.id,
                'Total_Assets__c' => 1000,
                'Total_Liabilities__c' => 200,
                'Gross_Farm_Income__c' => 3000,
                'clcommon__Account__r.Year_Began_Farming__c' => 2024
            }
        );
        requestMap.put('applicationId', applicationObj.id);
        requestMap.put('businessDetails',JSON.serialize(subTrancheInfoList));
        System.runAs(saUser){ 
            Test.startTest();
            PortalRescoreEvergreenAPI rescoreEvergreenAPIObj = new PortalRescoreEvergreenAPI();
            clcommon.Response responseObj = rescoreEvergreenAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, 'Exception expected for missing arguments'); 
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'PortalRescoreEvergreenAPI'
                                              LIMIT 1];
            System.assertEquals('PortalRescoreEvergreenAPI', logList[0].Name,'Exception Expected');            
            Test.stopTest();
        }
    }
    /**
    * @description : Test Rescore Evergreen empty request map exception
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testRescoreEvergreenEmptyRequestMapException(){
        User userObj = getClUser();
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRatesObj = getCreditRateMatrixTearTwo();
        applicationObj.genesis__Credit_Rating__c = creditRatesObj.Id;
        Database.upsert(applicationObj,false);
        requestMap.put('shouldValidate', true);
        requestMap.put('applicationId', applicationObj.id);
        requestMap.put('businessDetails', '[]');
        System.runAs(userObj){ 
            Test.startTest();
            PortalRescoreEvergreenAPI rescoreEvergreenAPIObj = new PortalRescoreEvergreenAPI();
            clcommon.Response responseObj = rescoreEvergreenAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, 'Assertion Failed');
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'PortalRescoreEvergreenAPI'
                                              LIMIT 1];
            System.assertEquals('PortalRescoreEvergreenAPI', logList[0].Name,'Exception Expected');
            Test.stopTest();
        }
    }
    /**
    * @description : Test Rescore Evergreen empty list exception
    * @author  Pritam Roy | 05-30-2024 
    **/
    @isTest
    private static void testRescoreEvergreenEmptyListException(){
        User saUser = [SELECT Id,UserName FROM User WHERE UserName='tim.couper@yopmail.com' LIMIT 1];
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = getApplication();
        genesis__Credit_Rating_Matrix__c creditRatesObj = getCreditRateMatrixTearTwo();
        applicationObj.genesis__Credit_Rating__c = creditRatesObj.Id;
        Database.upsert(applicationObj,false);
        requestMap.put('shouldValidate', true);
        clcommon__Party__c objBorrowerParty = new clcommon__Party__c();
        List<Map<String, Object>> subTrancheInfoList = new List<Map<String, Object>>();
        subTrancheInfoList.add(
            new Map<String, Object>{
                'id' => objBorrowerParty.id,
                'Total_Assets__c' => 1000,
                'Total_Liabilities__c' => 200,
                'Gross_Farm_Income__c' => 3000,
                'clcommon__Account__r.Year_Began_Farming__c' => 2024
            }
        );
        requestMap.put('applicationId', applicationObj.id);
        requestMap.put('businessDetails',JSON.serialize(subTrancheInfoList));
        System.runAs(saUser){ 
            Test.startTest();
            PortalRescoreEvergreenAPI rescoreEvergreenAPIObj = new PortalRescoreEvergreenAPI();
            clcommon.Response responseObj = rescoreEvergreenAPIObj.invokeAction('',new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, responseObj.status, 'Exception expected for missing arguments'); 
            List<clcommon__Log__c> logList = [SELECT Name
                                              FROM clcommon__Log__c 
                                              WHERE Name= 'PortalRescoreEvergreenAPI'
                                              LIMIT 1];
            System.assertEquals('PortalRescoreEvergreenAPI', logList[0].Name,'Exception Expected');            
            Test.stopTest();
        }
    }
}