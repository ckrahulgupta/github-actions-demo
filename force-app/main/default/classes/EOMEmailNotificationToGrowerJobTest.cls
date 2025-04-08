/**
 * @description       : Test class for ScheduleEOMEmailToCFAGrowerAPI
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 13-01-2025
 * @last modified by  : Soumik Pattanayak
**/
@isTest
private with sharing class EOMEmailNotificationToGrowerJobTest {
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

        clcommon__Legal_Entity__c clEntity= ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(clEntity, true);
        
        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id, newPartnerProgramObj.id);
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
        borrowerAccountObj.ParentId = dealerAccountObj.Id;
        Database.insert(borrowerAccountObj, true);

        // Creating Contact for Borrower
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(borrowerContactObj,true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        Dealer_Applicant_Relationship__c dealerApplRelationshipObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj, dealerAccountObj.Id);
        Database.insert(dealerApplRelationshipObj, true);

        // Creating map for Application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>{
            'dealerAccountId'=> dealerAccountObj.Id,
            'clProductId'=> clProductObj.Id,
            'clPurposeId'=> clPurposeObj.Id,
            'borrowerAccountId'=> borrowerAccountObj.Id,
            'borrowerContactId'=> borrowerContactObj.Id,
            'clAccountId'=> clAccountObj.Id,
            'dealerApplicantRelationshipId' => dealerApplRelationshipObj.Id
        };

        Date todayDate = System.today();
        String currentMonth = String.valueOf(todayDate.month());
        String previousMonth = String.valueOf(todayDate.addMonths(-1).month());
        String currentYear = String.valueOf(todayDate.year());
        String previousMonthYear;
        if(currentMonth.equals('1') || currentMonth.equals('01')){
            previousMonthYear = String.valueOf(todayDate.addYears(-1).year());
        }else{
            previousMonthYear = currentYear;
        }
        String previousMonthDate = previousMonthYear + previousMonth;

        // Creating Application
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        applicationObj.Monthly_Statement_Sent__c = previousMonthDate;
        Database.insert(applicationObj, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,clAccountObj.Id,borrowerAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        // Creating Certified Lender Party Type
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(clPartyTypeObj, true);

        // Creating Certified Lender Party
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
            'accountId'=> clAccountObj.Id,
            'contactId'=> clContactObj.Id,
            'partyTypeId'=> clPartyTypeObj.Id,
            'applicationId'=> applicationObj.Id
        };
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(paramForCLPartyMap);
        Database.insert(clPartyObj, true);

        // Create Borrower Party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(borrowerPartyTypeObj, true);

        // Creating Borrower Party
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId'=> borrowerAccountObj.Id,
            'contactId'=> borrowerContactObj.Id,
            'partyTypeId'=> borrowerPartyTypeObj.Id,
            'applicationId'=> applicationObj.Id,
            'dealerApplicantRelationshipId' => dealerApplRelationshipObj.Id
        };
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(paramForBorrowerPartyMap);
        Database.insert(borrowerPartyObj);

        createRecordsForCoBorrower(entityObj, applicationObj, dealerAccountObj);
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 09-01-2025 
    * @param entityObj 
    * @param applicationObj 
    * @param dealerAccountObj 
    **/
    private static void createRecordsForCoBorrower(clcommon__Legal_Entity__c entityObj, genesis__Applications__c applicationObj, Account dealerAccountObj){
        // Create Co Borrower Account
        genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(coBorrowerBusinessInfoObj,true);
        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(entityObj,coBorrowerBusinessInfoObj.id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        Database.insert(coBorrowerAccountObj,true);
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        Database.insert(coBorrowerContactObj,true);

        Dealer_Applicant_Relationship__c coBorrowerRelationshipObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(coBorrowerContactObj, dealerAccountObj.Id);
        Database.insert(coBorrowerRelationshipObj, true);

        clcommon__Party_Type__c prPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        Database.insert(prPartyTypeObj,true);
        Map<String,Id> principalPartyParamMap = new Map<String,Id>{
            'accountId' => coBorrowerAccountObj.id,
            'contactId' => coBorrowerContactObj.id,
            'partyTypeId' => prPartyTypeObj.id,
            'applicationId' => applicationObj.id,
            'dealerApplicantRelationshipId' => coBorrowerRelationshipObj.id
        };
        clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createParty(principalPartyParamMap);
        Database.insert(principalPartyObj,true);
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 09-01-2025 
    * @return User 
    **/
    private static User getAdminUser(){
        return [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 13-01-2025 
    * @return List<Contact> 
    **/
    private static List<Contact> getContact(){
        return [SELECT Id,FirstName,Email FROM Contact WHERE genesis__SSN__c = 'GHFB6766'];
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 09-01-2025 
    * @return List<genesis__Applications__c> 
    **/
    private static List<genesis__Applications__c> getApplicaitonList(){
        return [SELECT Id, Dealer_Name__c, Monthly_Statement_Sent__c FROM genesis__Applications__c LIMIT 1];
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 13-01-2025 
    * @param appId 
    * @return List<genesis__Applications__c> 
    **/
    private static List<genesis__Applications__c> getTestApplicaitonList(String appId){
        return [SELECT Id,Dealer_Name__c,Monthly_Statement_Sent__c FROM genesis__Applications__c Where Id =: appId LIMIT 1];
    }

    /**
    * @description test for exception
    * @author Soumik Pattanayak | 09-01-2025 
    **/
    @isTest
    private static void testException(){
        genesis__Applications__c appObj;
        List<genesis__Applications__c> applicationList = getApplicaitonList();
        User adminUser = getAdminUser();
        
        if(applicationList.size()==1){
            appObj = applicationList[0];
            appObj.genesis__contact__c = null;
            Database.update(appObj, true);
        }
        List<Contact> contactList  = [SELECT id FROM Contact WHERE id NOT IN (SELECT contactId FROM User)];
        Database.delete(contactList, true);
        System.runAs(adminUser){
            Test.startTest();
            EOMEmailNotificationToGrowerJob scheduleEOMEmail = new EOMEmailNotificationToGrowerJob();
            scheduleEOMEmail.execute(null);
            Test.stopTest();
            List<clcommon__Log__c> logList = [SELECT id FROM clcommon__Log__c WHERE name = 'EOMEmailNotificationToGrowerBatch'];
            System.assertEquals(true, logList.size()>0, PortalConstants.ASSERTION_FAILED); 
        }
    }

    /**
    * @description test for CFA without user
    * @author Soumik Pattanayak | 09-01-2025 
    **/
    @isTest
    private static void testWithoutUserForCFA(){
        genesis__Applications__c appObj;
        List<genesis__Applications__c> applicationList = getApplicaitonList();
        User adminUser = getAdminUser();
        if(applicationList.size()==1){
            appObj = applicationList[0];
        }
        System.runAs(adminUser){
            Test.startTest();
            EOMEmailNotificationToGrowerJob scheduleEOMEmail = new EOMEmailNotificationToGrowerJob();
            scheduleEOMEmail.execute(null);
            Test.stopTest();
            Date todayDate = System.today();
            String currentYear = String.valueOf(todayDate.year());
            String currentMonth = String.valueOf(todayDate.month());
            String currentDate = currentYear + currentMonth;
            appObj = getTestApplicaitonList(applicationList[0].id)[0];
            System.assertEquals(appObj.Monthly_Statement_Sent__c,currentDate, PortalConstants.ASSERTION_FAILED); 
        }
    }
    /**
    * @description test for Growmark without user
    * @author Soumik Pattanayak | 09-01-2025 
    **/
    @isTest
    private static void testWithoutUserForGrowmark(){
        genesis__Applications__c appObj;
        Account dealerAccount;
        List<genesis__Applications__c> applicationList = getApplicaitonList();
        List<Account> dealerAccountList = [SELECT Id,Coop_Type__c FROM Account Where Id =: applicationList[0].Dealer_Name__c];
        if(applicationList.size()==1){
            appObj = applicationList[0];
        }
        if(dealerAccountList.size()==1){
            dealerAccount = dealerAccountList[0];
            dealerAccount.Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
            Database.update(dealerAccount,true);
        }
        User adminUser = getAdminUser();
        System.runAs(adminUser){
            Test.startTest();
            EOMEmailNotificationToGrowerJob scheduleEOMEmail = new EOMEmailNotificationToGrowerJob();
            scheduleEOMEmail.execute(null);
            Test.stopTest();
            Date todayDate = System.today();
            String currentYear = String.valueOf(todayDate.year());
            String currentMonth = String.valueOf(todayDate.month());
            String currentDate = currentYear + currentMonth;
            appObj = getTestApplicaitonList(applicationList[0].id)[0];
            System.assertEquals(appObj.Monthly_Statement_Sent__c,currentDate, PortalConstants.ASSERTION_FAILED); 
        }
    }

    /**
    * @description test for CFA with user
    * @author Soumik Pattanayak | 09-01-2025 
    **/
    @isTest
    private static void testForExistingUserForCFA(){
        Contact contactObj;
        genesis__Applications__c appObj;
        User adminUser = getAdminUser();
        List<genesis__Applications__c> applicationList = getApplicaitonList();
        if(applicationList.size()==1){
            appObj = applicationList[0];
        }
        List<Contact> contactList = getContact();
        if(contactList.size()==1){
            contactObj = contactList[0];
        }
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(contactObj.Id);
        borrowerUserObj.userName = 'testUsercfa@yopmail.com';
        Database.Insert(borrowerUserObj,true);
        System.runAs(adminUser){
            Test.startTest();
            EOMEmailNotificationToGrowerJob scheduleEOMEmail = new EOMEmailNotificationToGrowerJob();
            scheduleEOMEmail.execute(null);
            Test.stopTest();
            Date todayDate = System.today();
            String currentYear = String.valueOf(todayDate.year());
            String currentMonth = String.valueOf(todayDate.month());
            String currentDate = currentYear + currentMonth;
            appObj = getTestApplicaitonList(applicationList[0].id)[0];
            System.assertEquals(appObj.Monthly_Statement_Sent__c,currentDate, PortalConstants.ASSERTION_FAILED); 
        }
    }

    /**
    * @description test for CFA with user and permission set
    * @author Soumik Pattanayak | 09-01-2025 
    **/
    @isTest
    private static void testForExistingUserWithPermissionForCFA(){
        Contact contactObj;
        genesis__Applications__c appObj;
        User adminUser = getAdminUser();
        List<genesis__Applications__c> applicationList = getApplicaitonList();
        if(applicationList.size()==1){
            appObj = applicationList[0];
        }
        List<Contact> contactList = getContact();
        if(contactList.size()==1){
            contactObj = contactList[0];
        }
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(contactObj.Id);
        borrowerUserObj.userName = 'testUsercfa@yopmail.com';
        Database.Insert(borrowerUserObj,true);

        System.runAs(adminUser){
            PermissionSetAssignment psa = ApplicationOriginationTestHelper.createPermissionSetAssignment(PortalConstants.GREY_LABEL_COOP_TYPE, borrowerUserObj.Id);
            Database.insert(psa, true);
            Test.startTest();
            EOMEmailNotificationToGrowerJob scheduleEOMEmail = new EOMEmailNotificationToGrowerJob();
            scheduleEOMEmail.execute(null);
            Test.stopTest();
            Date todayDate = System.today();
            String currentYear = String.valueOf(todayDate.year());
            String currentMonth = String.valueOf(todayDate.month());
            String currentDate = currentYear + currentMonth;
            appObj = getTestApplicaitonList(applicationList[0].id)[0];
            System.assertEquals(appObj.Monthly_Statement_Sent__c,currentDate, PortalConstants.ASSERTION_FAILED); 
        }
         
    }

    /**
    * @description  test for Growmark with user
    * @author Soumik Pattanayak | 09-01-2025 
    **/
    @isTest
    private static void testForExistingUserForGrowmark(){
        genesis__Applications__c appObj;
        Account dealerAccount;
        Contact contactObj;
        List<genesis__Applications__c> applicationList = getApplicaitonList();
        List<Account> dealerAccountList = [SELECT Id,Coop_Type__c FROM Account Where Id =: applicationList[0].Dealer_Name__c];
        if(applicationList.size()==1){
            appObj = applicationList[0];
        }
        if(dealerAccountList.size()==1){
            dealerAccount = dealerAccountList[0];
            dealerAccount.Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
            Database.update(dealerAccount,true);
        }
        List<Contact> contactList = getContact();
        if(contactList.size()==1){
            contactObj = contactList[0];
        }

        User adminUser = getAdminUser();
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(contactObj.Id);
        borrowerUserObj.userName = 'testUserGrowmark@yopmail.com';
        Database.Insert(borrowerUserObj,true);
        System.runAs(adminUser){
            Test.startTest();
            EOMEmailNotificationToGrowerJob scheduleEOMEmail = new EOMEmailNotificationToGrowerJob();
            scheduleEOMEmail.execute(null);
            Test.stopTest();
            Date todayDate = System.today();
            String currentYear = String.valueOf(todayDate.year());
            String currentMonth = String.valueOf(todayDate.month());
            String currentDate = currentYear + currentMonth;
            appObj = getTestApplicaitonList(applicationList[0].id)[0];
            System.assertEquals(appObj.Monthly_Statement_Sent__c,currentDate, PortalConstants.ASSERTION_FAILED); 
        }
    }

    /**
    * @description  test for Growmark with user and permission set
    * @author Soumik Pattanayak | 09-01-2025 
    **/
    @isTest
    private static void testForExistingUserWithPermissionSetForGrowmark(){
        genesis__Applications__c appObj;
        Account dealerAccount;
        Contact contactObj;
        List<genesis__Applications__c> applicationList = getApplicaitonList();
        List<Account> dealerAccountList = [SELECT Id,Coop_Type__c FROM Account Where Id =: applicationList[0].Dealer_Name__c];
        if(applicationList.size()==1){
            appObj = applicationList[0];
        }
        if(dealerAccountList.size()==1){
            dealerAccount = dealerAccountList[0];
            dealerAccount.Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
            Database.update(dealerAccount,true);
        }
        List<Contact> contactList = getContact();
        if(contactList.size()==1){
            contactObj = contactList[0];
        }

        User adminUser = getAdminUser();
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(contactObj.Id);
        borrowerUserObj.userName = 'testUserGrowmark@yopmail.com';
        Database.Insert(borrowerUserObj,true);
        System.runAs(adminUser){
            PermissionSetAssignment psa = ApplicationOriginationTestHelper.createPermissionSetAssignment(PortalConstants.WHITE_LABEL_COOP_TYPE, borrowerUserObj.Id);
            Database.insert(psa, true);
            Test.startTest();
            EOMEmailNotificationToGrowerJob scheduleEOMEmail = new EOMEmailNotificationToGrowerJob();
            scheduleEOMEmail.execute(null);
            Test.stopTest();
            Date todayDate = System.today();
            String currentYear = String.valueOf(todayDate.year());
            String currentMonth = String.valueOf(todayDate.month());
            String currentDate = currentYear + currentMonth;
            appObj = getTestApplicaitonList(applicationList[0].id)[0];
            System.assertEquals(appObj.Monthly_Statement_Sent__c,currentDate, PortalConstants.ASSERTION_FAILED); 
        }
    }
    
    /**
    * @description test for corporation
    * @author Soumik Pattanayak | 09-01-2025 
    **/
    @isTest
    private static void testForExistingUserForLandusCorporation(){
        genesis__Applications__c appObj;
        Account dealerAccount;
        Contact contactObj;
        List<genesis__Applications__c> applicationList = getApplicaitonList();
        List<Account> dealerAccountList = [SELECT Id,Coop_Type__c FROM Account Where Id =: applicationList[0].Dealer_Name__c];
        if(applicationList.size()==1){
            appObj = applicationList[0];
        }
        if(dealerAccountList.size()==1){
            dealerAccount = dealerAccountList[0];
            dealerAccount.Coop_Type__c = ConstantValues.LANDUS_COOP_TYPE;
            Database.update(dealerAccount,true);
        }
        clcommon__Legal_Entity__c legalEntityObj=[SELECT Id,Name,clcommon__Legal_Entity_Type__c FROM clcommon__Legal_Entity__c WHERE Name='Individual(s) - Sole Proprietorship'];
        legalEntityObj.Name='Corporation';
        legalEntityObj.clcommon__Legal_Entity_Type__c='Corporation';
        Database.update(legalEntityObj,true);

        List<Contact> contactList = getContact();
        if(contactList.size()==1){
            contactObj = contactList[0];
        }
        User adminUser = getAdminUser();
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(contactObj.Id);
        borrowerUserObj.userName = 'testUserLandus@yopmail.com';
        Database.Insert(borrowerUserObj,true);
        System.runAs(adminUser){
            Test.startTest();
            EOMEmailNotificationToGrowerJob scheduleEOMEmail = new EOMEmailNotificationToGrowerJob();
            scheduleEOMEmail.execute(null);
            Test.stopTest();
            Date todayDate = System.today();
            String currentYear = String.valueOf(todayDate.year());
            String currentMonth = String.valueOf(todayDate.month());
            String currentDate = currentYear + currentMonth;
            appObj = getTestApplicaitonList(applicationList[0].id)[0];
            System.assertEquals(appObj.Monthly_Statement_Sent__c,currentDate, PortalConstants.ASSERTION_FAILED); 
        }
    }

    /**
    * @description test for gmk corporation
    * @author Soumik Pattanayak | 09-01-2025 
    **/
    @isTest
    private static void testForExistingUserForGrowmarkCorporation(){
        genesis__Applications__c appObj;
        Account dealerAccount;
        Contact contactObj;
        List<genesis__Applications__c> applicationList = getApplicaitonList();
        List<Account> dealerAccountList = [SELECT Id,Coop_Type__c FROM Account Where Id =: applicationList[0].Dealer_Name__c];
        if(applicationList.size()==1){
            appObj = applicationList[0];
        }
        if(dealerAccountList.size()==1){
            dealerAccount = dealerAccountList[0];
            dealerAccount.Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
            Database.update(dealerAccount,true);
        }
        clcommon__Legal_Entity__c legalEntityObj=[SELECT Id,Name,clcommon__Legal_Entity_Type__c FROM clcommon__Legal_Entity__c WHERE Name='Individual(s) - Sole Proprietorship'];
        legalEntityObj.Name='Corporation';
        legalEntityObj.clcommon__Legal_Entity_Type__c='Corporation';
        Database.update(legalEntityObj,true);

        List<Contact> contactList = getContact();
        if(contactList.size()==1){
            contactObj = contactList[0];
        }
        User adminUser = getAdminUser();
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(contactObj.Id);
        borrowerUserObj.userName = 'testUserLandus@yopmail.com';
        Database.Insert(borrowerUserObj,true);
        System.runAs(adminUser){
            Test.startTest();
            EOMEmailNotificationToGrowerJob scheduleEOMEmail = new EOMEmailNotificationToGrowerJob();
            scheduleEOMEmail.execute(null);
            Test.stopTest();
            Date todayDate = System.today();
            String currentYear = String.valueOf(todayDate.year());
            String currentMonth = String.valueOf(todayDate.month());
            String currentDate = currentYear + currentMonth;
            appObj = getTestApplicaitonList(applicationList[0].id)[0];
            System.assertEquals(appObj.Monthly_Statement_Sent__c,currentDate, PortalConstants.ASSERTION_FAILED); 
        }
    }

    /**
    * @description test for current month note application
    * @author Soumik Pattanayak | 09-01-2025 
    **/
    @isTest
    private static void testForCurrentMonthNoteDateApplication(){
        genesis__Applications__c appObj;
        Account dealerAccount;
        Contact contactObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,Dealer_Name__c,Note_Date__c,Monthly_Statement_Sent__c FROM genesis__Applications__c LIMIT 1];
        List<Account> dealerAccountList = [SELECT Id,Coop_Type__c FROM Account Where Id =: applicationList[0].Dealer_Name__c];
        if(applicationList.size()==1){
            appObj = applicationList[0];
            appObj.Note_Date__c = System.today();
            appObj.Monthly_Statement_Sent__c = null;
            Database.update(appObj,true);
        }
        if(dealerAccountList.size()==1){
            dealerAccount = dealerAccountList[0];
            dealerAccount.Coop_Type__c = ConstantValues.LANDUS_COOP_TYPE;
            Database.update(dealerAccount,true);
        }
        clcommon__Legal_Entity__c legalEntityObj=[SELECT Id,Name,clcommon__Legal_Entity_Type__c FROM clcommon__Legal_Entity__c WHERE Name='Individual(s) - Sole Proprietorship'];
        legalEntityObj.Name='Corporation';
        legalEntityObj.clcommon__Legal_Entity_Type__c='Corporation';
        Database.update(legalEntityObj,true);

        List<Contact> contactList = getContact();
        if(contactList.size()==1){
            contactObj = contactList[0];
        }
        User adminUser = getAdminUser();
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(contactObj.Id);
        borrowerUserObj.userName = 'testUserLandus@yopmail.com';
        Database.Insert(borrowerUserObj,true);
        System.runAs(adminUser){
            Test.startTest();
            EOMEmailNotificationToGrowerJob scheduleEOMEmail = new EOMEmailNotificationToGrowerJob();
            scheduleEOMEmail.execute(null);
            Test.stopTest();
            appObj = getTestApplicaitonList(applicationList[0].id)[0];
            System.assertEquals(appObj.Monthly_Statement_Sent__c,null, PortalConstants.ASSERTION_FAILED); 
        }
    }
}