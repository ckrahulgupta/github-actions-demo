/**
* @description       : Test Class for Portal Loan Status Count API
* @author            : Arka Jyoti Deb
* @group             : 
* @last modified on  : 01-18-2025
* @last modified by  : Shruti Tamakhuwala
**/
@isTest
private with sharing class TestPortalLoanStatusCountAPI {
    /**
    * @description To create test data
    **/
    @TestSetup
    static void makeData(){
        List<clcommon__party__c> partyList = new List<clcommon__party__c>();
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        Integer count;
        String loanNumber = '349820001';
        String loanId = '139000';
        // Creating Business Information for Dealer, Borrower
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{ 
                                                                    dealerBusinessInfoObj,
                                                                    borrowerBusinessInfoObj
                                                                },true);    
        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj,true);
        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(entityObj,true);   
        // Creating Account for Certified Lender, Borrower, Sales Agent
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id,dealerAccountObj.Id);
        Account saAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(new List<Account>{
                                            clAccountObj,
                                            borrowerAccountObj,
                                            saAccountObj
                                        },true);
        // Creating Contact for Certified Lender, Borrower, Sales Agent
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Contact saContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(saAccountObj.Id);
        Database.insert(new List<Contact>{
                                            clContactObj,
                                            borrowerContactObj,
                                            saContactObj
                                        },true);
        // Creating User for Certified Lender, Borrower, Sales Agent
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        User saUserObj = ApplicationOriginationTestHelper.createSalesAgentUser(saContactObj.Id);
        Database.insert(new List<User>{
                                        clUserObj,
                                        borrowerUserObj,
                                        saUserObj
                                    },true);
        // Creating Party Type for Certified Lender, Borrower, Sales Agent
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.CL_PARTY_NAME);
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);
        clcommon__Party_Type__c saPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.SALES_AGENT_PARTY_NAME);
        Database.insert(new List<clcommon__Party_Type__c>{
                                                            clPartyTypeObj,
                                                            borrowerPartyTypeObj,
                                                            saPartyTypeObj
                                                        },true);
        // Creating Dealer Applicant Relationship
        Dealer_Applicant_Relationship__c dealerAppRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Database.insert(dealerAppRelationObj,true);    
        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj,true);
        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);
        //creating three applications with active status
        for(count=0;count<3;count++){
            genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(new Map<String,Id>{
                                                                                                            'dealerAccountObjId' => dealerAccountObj.id,
                                                                                                            'clProductObjId' => clProductObj.id,
                                                                                                            'clPurposeObjId' => clPurposeObj.id,
                                                                                                            'borrowerAccountObjId' => borrowerAccountObj.id,
                                                                                                            'borrowerContactObjId' => borrowerContactObj.id,
                                                                                                            'clAccountObjId' => clAccountObj.id,
                                                                                                            'saAccountObjId' => saAccountObj.id
                                                                                                        });
            applicationObj.genesis__Status__c = PortalConstants.ACTIVE_APPLICATION_STATUS;
            applicationObj.Crop_Year__c = String.valueOf(Date.today().Year());
            applicationObj.genesis__Maturity_Date__c = Date.today().addYears(3);
            applicationObj.genesis__Loan_Number__c = loanNumber + 1;
            applicationObj.Loan_Id__c = loanId + 1;
            applicationList.add(applicationObj);
        }        
        // creating one application with closed status
        for(count=0;count<1;count++){
            genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(new Map<String,Id>{
                                                                                                            'dealerAccountObjId' => dealerAccountObj.id,
                                                                                                            'clProductObjId' => clProductObj.id,
                                                                                                            'clPurposeObjId' => clPurposeObj.id,
                                                                                                            'borrowerAccountObjId' => borrowerAccountObj.id,
                                                                                                            'borrowerContactObjId' => borrowerContactObj.id,
                                                                                                            'clAccountObjId' => clAccountObj.id,
                                                                                                            'saAccountObjId' => saAccountObj.id
                                                                                                        });
            applicationObj.genesis__Status__c = PortalConstants.CLOSED_APPLICATION_STATUS;
            applicationObj.Crop_Year__c = String.valueOf(Date.today().Year() - 2);
            applicationObj.genesis__Maturity_Date__c = Date.newinstance(2023, 01, 15);
            applicationObj.genesis__Loan_Number__c = loanNumber + 1;
            applicationObj.Loan_Id__c = loanId + 1;
            applicationList.add(applicationObj);
        }
        //creating two applications with approved status
        for(count=0;count<2;count++){
            genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(new Map<String,Id>{
                                                                                                            'dealerAccountObjId' => dealerAccountObj.id,
                                                                                                            'clProductObjId' => clProductObj.id,
                                                                                                            'clPurposeObjId' => clPurposeObj.id,
                                                                                                            'borrowerAccountObjId' => borrowerAccountObj.id,
                                                                                                            'borrowerContactObjId' => borrowerContactObj.id,
                                                                                                            'clAccountObjId' => clAccountObj.id,
                                                                                                            'saAccountObjId' => saAccountObj.id
                                                                                                        });
            applicationObj.genesis__Status__c = PortalConstants.APPROVED_APPLICATION_STATUS;
            applicationObj.Crop_Year__c = String.valueOf(Date.today().Year() - 1);
            applicationObj.genesis__Maturity_Date__c = Date.today().addYears(2);
            applicationObj.genesis__Loan_Number__c = loanNumber + 1;
            applicationObj.Loan_Id__c = loanId + 1;
            applicationList.add(applicationObj);
        }
        Database.insert(applicationList,true);
        for(genesis__Applications__c applicationObj : applicationList){
            // Creating CL Party for each application
            partyList.add(ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                            'accountId' => clAccountObj.Id,
                                                                            'contactId' => clContactObj.Id,
                                                                            'partyTypeId' => clPartyTypeObj.Id,
                                                                            'applicationId' => applicationObj.Id
                                                                        }));
            // Creating Borrower Party for each application
            partyList.add(ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                            'accountId' => borrowerAccountObj.Id,
                                                                            'contactId' => borrowerContactObj.Id,
                                                                            'partyTypeId' => borrowerPartyTypeObj.Id,
                                                                            'applicationId' => applicationObj.Id
                                                                        }));
            // Creating Sales Agent Party for each application
            partyList.add(ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                            'accountId' => saAccountObj.Id,
                                                                            'contactId' => saContactObj.Id,
                                                                            'partyTypeId' => saPartyTypeObj.Id,
                                                                            'applicationId' => applicationObj.Id
                                                                        }));
        }
        Database.insert(partyList,true);
        // creating rate card for  applications
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerAccountObj);
        Database.insert(rateCardHeaderObj,true);
        genesis__Rate_Card_Setup_Detail__c arateCardSetupDetailsObj =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        arateCardSetupDetailsObj.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_A;
        Database.insert(arateCardSetupDetailsObj,true);
        genesis__Application_Pricing_Detail__c pricingDetailObj = ApplicationOriginationTestHelper.createEnabledPricingDetail(applicationList[0],arateCardSetupDetailsObj.Id);
        Database.insert(pricingDetailObj,true);
    }

    /**
    * @description To get User to run test
    * @author Shruti Tamakhuwala | 01-07-2025 
    * @param userAccountId 
    * @return User 
    **/
    private static User getUser(String userAccountId){
        List<User> userList = [SELECT Id,
                                        AccountId
                                FROM User
                                WHERE AccountId =: userAccountId 
                                AND isActive = true  
                                LIMIT 1];
        if(!userList.isEmpty()) {
            return userList[0];
        }     
        return null;
    } 

    /**
    * @description : This method is used to test for Success Count of Applications with Current Crop Year
    * @author  Pritam Roy | 08-28-2024 
    **/
    @isTest
    private static void testLoanStatusCountAPIForCurrentCropYearAppSuccess(){
        Integer currentYear = System.Today().year();
        if(System.today().month() >= 6){
            currentYear = currentYear + 1;
        }
        List<genesis__Applications__c> applicationList = [SELECT id,
                                                                genesis__Account__c,
                                                                Certified_Lender__c,
                                                                Crop_Year__c 
                                                            FROM genesis__Applications__c 
                                                            LIMIT 1];
        applicationList[0].Crop_Year__c = String.valueOf(currentYear);
        Database.update(applicationList,true);
        User userObj = TestPortalLoanStatusCountAPI.getUser(applicationList[0].Certified_Lender__c);      
        System.runAs(userObj){
            Test.startTest();
            //Calling the API
            PortalLoanStatusCountAPI loanStatusCountInst = new PortalLoanStatusCountAPI();
            clcommon.Response response = loanStatusCountInst.invokeAction('', new List<String>(), new Map<String, Object>());
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed for Current Crop Year Count');
            Test.stopTest();
        }        
    } 

    /**
    * @description : This method is used to test for Success Count of Evergreen Applications
    * @author  Pritam Roy | 08-28-2024 
    **/
    @isTest
    private static void testLoanStatusCountAPIForEvergreenAppSuccess(){
        List<genesis__Applications__c> applicationList = [SELECT id,
                                                                genesis__Account__c,
                                                                Certified_Lender__c,
                                                                Is_Evergreen_Eligible__c 
                                                            FROM genesis__Applications__c 
                                                            LIMIT 1];
        applicationList[0].Is_Evergreen_Eligible__c = true;
        Database.update(applicationList,true);
        User userObj = TestPortalLoanStatusCountAPI.getUser(applicationList[0].Certified_Lender__c);              
        System.runAs(userObj){
            Test.startTest();
            //Calling the API
            PortalLoanStatusCountAPI loanStatusCountInst = new PortalLoanStatusCountAPI();
            clcommon.Response response = loanStatusCountInst.invokeAction('', new List<String>(), new Map<String, Object>());
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed for Evergreen Applications Count');
            Test.stopTest();      
        }  
    } 

    /**
    * @description : This method is used to test for Success Count Past Due Applications
    * @author  Pritam Roy | 08-28-2024 
    **/
    @isTest
    private static void testLoanStatusCountAPIForPastDueAppSuccess(){
        List<genesis__Application_Pricing_Detail__c> pricingDetailList = [SELECT id,
                                                                                Past_Due_Balance__c 
                                                                            FROM genesis__Application_Pricing_Detail__c
                                                                            LIMIT 1];
        pricingDetailList[0].Past_Due_Balance__c = 100;
        Database.update(pricingDetailList,true);
        List<genesis__Applications__c> applicationList = [SELECT id,
                                                                genesis__Account__c,
                                                                Certified_Lender__c,
                                                                Past_Due_balance__c,
                                                                Is_Evergreen_Eligible__c 
                                                            FROM genesis__Applications__c 
                                                            LIMIT 1];
        applicationList[0].Is_Evergreen_Eligible__c = true;
        applicationList[0].Past_Due_balance__c = 100;
        Database.update(applicationList,true);
        User userObj = TestPortalLoanStatusCountAPI.getUser(applicationList[0].Certified_Lender__c);      
        System.runAs(userObj){
            Test.startTest();
            //Calling the API
            PortalLoanStatusCountAPI loanStatusCountInst = new PortalLoanStatusCountAPI();
            clcommon.Response response = loanStatusCountInst.invokeAction('', new List<String>(), new Map<String, Object>());
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed for Past Due Applications Count');
            Test.stopTest();      
        }        
    }

    /**
    * @description : This method is used to test for Success Count of Applications with  Closed Loan Status
    * @author  Shruti Tamakhuwala | 12-30-2024 
    **/
    @isTest
    private static void testLoanStatusCountAPIForClosedAppSuccess(){
        List<genesis__Applications__c> applicationList = [SELECT id,
                                                                genesis__Account__c,
                                                                Certified_Lender__c,
                                                                genesis__Status__c
                                                            FROM genesis__Applications__c 
                                                            LIMIT 1];
        applicationList[0].genesis__Status__c = PortalConstants.CLOSED_APPLICATION_STATUS;
        Database.update(applicationList,true);
        User userObj = TestPortalLoanStatusCountAPI.getUser(applicationList[0].Certified_Lender__c);              
        System.runAs(userObj){
            Test.startTest();
            //Calling the API
            PortalLoanStatusCountAPI loanStatusCountInst = new PortalLoanStatusCountAPI();
            clcommon.Response response = loanStatusCountInst.invokeAction('', new List<String>(), new Map<String, Object>());
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed for Closed Loan Status Count');
            Test.stopTest();      
        }  
    } 

    /**
    * @description : This method is used to test for Success Count of Applications with Active Loan Status
    * @author  Shruti Tamakhuwala | 12-30-2024 
    **/
    @isTest
    private static void testLoanStatusCountAPIForActiveAppSuccess(){
        List<genesis__Applications__c> applicationList = [SELECT id,
                                                                genesis__Account__c,
                                                                Certified_Lender__c,
                                                                genesis__Status__c
                                                            FROM genesis__Applications__c 
                                                            LIMIT 1];
        applicationList[0].genesis__Status__c = PortalConstants.ACTIVE_APPLICATION_STATUS;
        Database.update(applicationList,true);
        User userObj = TestPortalLoanStatusCountAPI.getUser(applicationList[0].Certified_Lender__c);      
        System.runAs(userObj){
            Test.startTest();
            //Calling the API
            PortalLoanStatusCountAPI loanStatusCountInst = new PortalLoanStatusCountAPI();
            clcommon.Response response = loanStatusCountInst.invokeAction('', new List<String>(), new Map<String, Object>());
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed for Active Loan Status Count');
            Test.stopTest();
        }       
    }

    /**
    * @description : This method is used to test for Success the Count of Applications with Prior Crop Year
    * @author  Shruti Tamakhuwala | 12-30-2024 
    **/
    @isTest
    private static void testLoanStatusCountAPIForPriorCropYearAppSuccess(){
        Integer previousYear = System.Today().year();
        if(System.today().month()<6){
            previousYear = previousYear-1;
        }
        List<genesis__Applications__c> applicationList = [SELECT id,
                                                                genesis__Account__c,
                                                                Certified_Lender__c,
                                                                Crop_Year__c 
                                                            FROM genesis__Applications__c 
                                                            LIMIT 1];
        applicationList[0].Crop_Year__c = String.valueOf(previousYear);
        Database.update(applicationList,true);
        User userObj = TestPortalLoanStatusCountAPI.getUser(applicationList[0].Certified_Lender__c);      
        System.runAs(userObj){
            Test.startTest();
            //Calling the API            
            PortalLoanStatusCountAPI loanStatusCountInst = new PortalLoanStatusCountAPI();
            clcommon.Response response = loanStatusCountInst.invokeAction('', new List<String>(), new Map<String, Object>());
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assesrtion failed for Prior Crop Year Count');
            Test.stopTest();
        }
    }

    /**
    * @description : This method is used to test for the Count of Applications with Sales Agent Access
    * @author  Shruti Tamakhuwala | 01-12-2025
    **/
    @isTest
    private static void testSalesAgentAccessSuccess(){
        List<genesis__Applications__c> applicationList = [SELECT id,
                                                                genesis__Account__c,
                                                                Sales_Agent__c
                                                            FROM genesis__Applications__c 
                                                            LIMIT 1];
        User userObj = TestPortalLoanStatusCountAPI.getUser(applicationList[0].genesis__Account__c);      
        System.runAs(userObj){
            Test.startTest();
            //Calling the API
            PortalLoanStatusCountAPI loanStatusCountInst = new PortalLoanStatusCountAPI();
            clcommon.Response response = loanStatusCountInst.invokeAction('', new List<String>(), new Map<String, Object>());
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed for Count of Applications with Borrower Access');            
            Test.stopTest();
        }        
    } 
}