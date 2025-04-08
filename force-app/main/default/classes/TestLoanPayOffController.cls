/**
 * @description       : 
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 01-22-2025
 * @last modified by  : Shruti Tamakhuwala
**/
@isTest
private without sharing class TestLoanPayOffController {

    /**
    * @description This method is used to create test data
    * @author Shruti Tamakhuwala | 01-21-2025 
    **/
    @TestSetup
    static void makeData(){
        // Creating application setup
        ApplicationOriginationSetupTestHelper.createTestSetup(); 
        genesis__Applications__c applicationObj = getApplication();
        // Creating party type for Dealer
        clcommon__Party_Type__c dealerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.DEALER_PARTY_NAME);
        Database.insert(dealerPartyTypeObj);
        Account dealerAccountObj = getAccount('Kisan Loan');
        // Creating Party for Dealer
        clcommon__Party__c dealerPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
                                                                                            'accountId' => dealerAccountObj.Id,
                                                                                            'partyTypeId' => dealerPartyTypeObj.Id,
                                                                                            'applicationId' => applicationObj.Id
                                                                                        });       
        Database.insert(dealerPartyObj,true);
        // Creating Princing Details dor application
        genesis__Application_Pricing_Detail__c pricingDetailObj = ApplicationOriginationTestHelper.createPricingDetail(applicationObj.Id);
        pricingDetailObj.Principal_Advanced__c = 500;
        pricingDetailObj.Accrued_Interest__c = 250;
        Database.insert(pricingDetailObj,true);
        applicationObj.Pay_Off_Date__c = Date.today();
        applicationObj.Note_Date__c = Date.today();
        Database.update(applicationObj, true);
    }

    /**
    * @description : This method creates instance of Vf page
    * @author Shruti Tamnakhuwala | 01-21-2025 
    * @param applicationId
    * @return pageReference 
    **/
    private static pageReference createVfPageReference(String applicationId){
        pageReference pageObj = Page.LoanPayoff;
        pageObj.getParameters().put('appid', applicationId);
        return pageObj;
    }
    
    /**
    * @description This method is used to get User to run test
    * @author Shruti Tamakhuwala | 01-21-2025 
    * @param userAccountName 
    * @return User 
    **/
    private static User getUser(String userAccountName){
        List<User> userList = [SELECT Id,
                                        Account.Name,
                                        Profile.Name
                                FROM User
                                WHERE Account.Name =: userAccountName 
                                AND isActive = true  
                                LIMIT 1];
        if(!userList.isEmpty()) {
            return userList[0];
        }     
        return null;
    } 
    
    /**
    * @description This method is used to get Application details for test
    * @author Shruti Tamakhuwala | 01-22-2025 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c getApplication(){
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                    Name,
                                                                    Internal_Reference_Code__c,
                                                                    Interest__c,
                                                                    Current_Principal_Balance__c,
                                                                    Interest_Per_Diem__c,
                                                                    genesis__Loan_Number__c,
                                                                    Payoff_Amount_via_Mobile__c 
                                                            FROM genesis__Applications__c 
                                                            WHERE Internal_Reference_Code__c ='testApp001' 
                                                            LIMIT 1];
        if(!applicationList.isEmpty()){
            return applicationList[0];
        }
        return null;
    }

    /**
    * @description This method is used to get party of application
    * @author Shruti Tamakhuwala | 01-22-2025 
    * @param partyType 
    * @param applicationId
    * @return List<clcommon__Party__c> 
    **/
    private static List<clcommon__Party__c> getParty(String partyType, String applicationId){
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                        clcommon__Account__r.Name,
                                                        clcommon__Type__r.Name,
                                                        Street__c,
                                                        City__c,
                                                        State__c,
                                                        Postal_Code__c,
                                                        clcommon__Account__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c,
                                                        clcommon__Account__r.Coop_Type__c
                                                FROM clcommon__Party__c
                                                WHERE clcommon__Type__r.Name =: partyType
                                                AND genesis__Application__c =: applicationId
                                            ];
        if(!partyList.isEmpty()){
            return partyList;
        }
        return null;
    }

    /**
    * @description This method is used to get Account details for test
    * @author Shruti Tamakhuwala | 01-22-2025 
    * @param accountName 
    * @return Account 
    **/
    private static Account getAccount(String accountName){
        List<Account> accountList = [SELECT Id,
                                            Name,
                                            Coop_Type__c
                                        FROM Account
                                        WHERE Name =: accountName
                                        LIMIT 1];
        if(!accountList.isEmpty()){
            return accountList[0];
        }
        return null;
    }

    /** This method is used to get expected format of dates for test
    * @description 
    * @author Shruti Tamakhuwala | 01-22-2025 
    * @param actualDate 
    * @return String
    **/
    private static String getDateFormat(Date actualDate){
        String expectedDate = actualDate.month() + PortalConstants.SLASH_STRING + actualDate.day() + PortalConstants.SLASH_STRING + actualDate.year();
        return expectedDate;
    }

    /** This method is used to get expected format of amounts for test
    * @description 
    * @author Shruti Tamakhuwala | 01-22-2025 
    * @param actualAmount 
    * @return String 
    **/
    private static String getAmountFormat(Decimal actualAmount){
        String expectedAmount = String.valueOf((actualAmount.setScale(2)+0.001).format());
        return '$' + expectedAmount.substring(0,expectedAmount.length()-1);       
    }

    /**
    * @description This method is used to get log message name
    * @author Shruti Tamakhuwala | 01-22-2025 
    * @return List<clcommon__Log__c> 
    **/
    private static List<clcommon__Log__c> getLogMessage(){
        List<clcommon__Log__c> logList = [SELECT Name,
                                                    clcommon__Message__c
                                            FROM clcommon__Log__c
                                            WHERE Name = 'LoanPayoffController'
                                            LIMIT 1];
        if(!logList.isEmpty()){
            return logList;
        }           
        return null;
    }

    /**
    * @description This method is used to test success scenario of Loan Payoff Controller
    * @author Shruti Tamakhuwala | 01-21-2025 
    **/
    @isTest
    private static void testLoanPayOffControllerSuccess(){
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = getParty(PortalConstants.BORROWER_PARTY_NAME, applicationObj.Id);
        String expectedBorrowerCity = String.valueOf(borrowerPartyList[0].City__c) + PortalConstants.SPACE_STRING + String.valueOf(borrowerPartyList[0].State__c) + PortalConstants.SPACE_STRING + String.valueOf(borrowerPartyList[0].Postal_Code__c);  
        List<clcommon__Party__c> principalPartyList = getParty(PortalConstants.PRINCIPAL_PARTY_NAME, applicationObj.Id);
        String todayDate = getDateFormat(Date.today());
        pageReference pageObj = createVfPageReference(getApplication().Id);
        Test.setCurrentPage(pageObj);
        System.runAs(getUser('Jasmine Albin')) {
            Test.startTest();
            LoanPayoffController loanPayOffControllerInst = new LoanPayoffController();
            System.assertEquals(applicationObj.genesis__Loan_Number__c, loanPayOffControllerInst.loanNumber, 'Expected Loan Number should match the actual value');
            System.assertEquals(todayDate, loanPayOffControllerInst.todayDate, 'Expected Today Date should match the actual value');
            System.assertEquals(PortalConstants.CFA_COOP_TYPE, loanPayOffControllerInst.coopType, 'Expected CFA Coop Type should match the actual value');
            System.assertEquals(PortalConstants.KEY_RESOURCE+'cfaLogo', loanPayOffControllerInst.logo, 'Expected CFA Logo should match the actual value');
            System.assertEquals(getDateFormat(Date.today().addYears(1)), loanPayOffControllerInst.maturityDate, 'Expected Maturity Date should match the actual value');
            System.assertEquals(todayDate, loanPayOffControllerInst.payOffDate, 'Expected Payoff Date should match the actual value');
            System.assertEquals(todayDate, loanPayOffControllerInst.noteDate, 'Expected Note Date should match the actual value');
            System.assertEquals(getAmountFormat(applicationObj.Current_Principal_Balance__c), loanPayOffControllerInst.principalBalance, 'Expected Current Principal Balance should match the actual value');
            System.assertEquals(getAmountFormat(applicationObj.Interest__c), loanPayOffControllerInst.interestAccrued, 'Expected Interest accrued should match the actual value');
            System.assertEquals(getAmountFormat(applicationObj.Payoff_Amount_via_Mobile__c), loanPayOffControllerInst.payOffAmount, 'Expected Payoff Amount should match the actual value');
            System.assertEquals(getAmountFormat(applicationObj.Interest_Per_Diem__c), loanPayOffControllerInst.perDiem, 'Expected Per Diem should match the actual value');
            System.assertEquals(borrowerPartyList[0].Street__c, loanPayOffControllerInst.street, 'Expected City should match the actual value');
            System.assertEquals(expectedBorrowerCity, loanPayOffControllerInst.city, 'Expected City should match the actual value');
            System.assertEquals(borrowerPartyList[0].clcommon__Account__r.Name, loanPayOffControllerInst.name, 'Expected State should match the actual value');
            System.assertEquals(principalPartyList.size(), loanPayOffControllerInst.principal.size(), 'Expected number of principal party should match the actual value');
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to test sucess returning null or N/A for invalid data scenario of Loan Payoff Controller
    * @author Shruti Tamakhuwala | 01-22-2025 
    **/
    @isTest
    private static void testInvalidDataSucess(){
        // updating application for invalid data
        genesis__Applications__c applicationObj = getApplication();
        applicationObj.genesis__Loan_Number__c = null;
        applicationObj.Interest_Per_Diem__c = null;
        applicationObj.Note_Date__c = null;
        applicationObj.Pay_Off_Date__c = null;
        applicationObj.genesis__Maturity_Date__c = null;
        Database.update(applicationObj,true);
        // updating borrower party for invalid data
        List<clcommon__Party__c> borrowerPartyList = getParty(PortalConstants.BORROWER_PARTY_NAME, applicationObj.Id);
        borrowerPartyList[0].Street__c = null;
        borrowerPartyList[0].City__c = null;
        Database.update(borrowerPartyList,true);
        // deleting principal party for invalid data
        List<clcommon__Party__c> principalPartyList = getParty(PortalConstants.PRINCIPAL_PARTY_NAME, applicationObj.Id);
        Database.delete(principalPartyList,true);
        // updating dealer account for invalid data
        Account dealerAccountObj = getAccount('Kisan Loan');
        dealerAccountObj.Coop_Type__c = null;
        Database.update(dealerAccountObj);
        // updating CFA partner program for invalid data
        List<CFA_Partner_Program__c> partnerProgramList = [SELECT Id,
                                                                    Name,
                                                                    Dealer_Portal_Logo__c
                                                                    FROM CFA_Partner_Program__c 
                                                                    WHERE Name = 'New Partner Program'
                                                                    LIMIT 1];
        partnerProgramList[0].Dealer_Portal_Logo__c = null;
        Database.update(partnerProgramList,true);
        pageReference pageObj = createVfPageReference(getApplication().Id);
        Test.setCurrentPage(pageObj);
        System.runAs(new User(Id = UserInfo.getUserId())){
            Test.startTest();
            LoanPayoffController loanPayOffControllerInst = new LoanPayoffController();
            System.assertEquals(null, loanPayOffControllerInst.loanNumber, 'Loan Number should return null value');
            System.assertEquals('N/A', loanPayOffControllerInst.perDiem, 'Interest Per Diem should return null value');
            System.assertEquals(null, loanPayOffControllerInst.street, 'Borrower party street should return null value');
            System.assertEquals(null, loanPayOffControllerInst.city, 'Borrower party city should return null value');
            System.assertEquals(null, loanPayOffControllerInst.principal, 'Expected null as no principal party present');
            System.assertEquals('N/A', loanPayOffControllerInst.noteDate, 'Note Date should return N/A value');
            System.assertEquals('N/A', loanPayOffControllerInst.payOffDate, 'Pay Off Date should return N/A value');
            System.assertEquals(null, loanPayOffControllerInst.maturityDate, 'Maturity Date should return null value');
            System.assertEquals(null, loanPayOffControllerInst.coopType, 'Coop Type should return null value');
            System.assertEquals(null, loanPayOffControllerInst.logo, 'CFA Logo should return null value');
            Test.stopTest();
        }
    }

    /**
    * @description This method is to test invalid application id exception scenario
    * @author Shruti Tamakhuwala | 01-22-2025 
    **/
    @isTest
    private static void testInvalidApplicationException(){
        // creating application without application id
        pageReference pageObj = createVfPageReference('');
        Test.setCurrentPage(pageObj);
        System.runAs(new User(Id = UserInfo.getUserId())){
            Test.startTest();
            new LoanPayoffController();
            System.assertEquals(1, getLogMessage().size(), 'Exception expected for missing application id');
            Test.stopTest();
        }
    }

    /**
    * @description This method is used to test invalid party type for borrower exception scenario
    * @author Shruti Tamakhuwala | 01-22-2025 
    **/
    @isTest
    private static void testInvalidPartyTypeException(){
        genesis__Applications__c applicationObj = getApplication();
        // updating borrower party for invalid data
        List<clcommon__Party__c> borrowerPartyList = getParty(PortalConstants.BORROWER_PARTY_NAME, applicationObj.Id);
        borrowerPartyList[0].clcommon__Type__c = null;
        Database.update(borrowerPartyList,true);
        pageReference pageObj = createVfPageReference(getApplication().Id);
        Test.setCurrentPage(pageObj);
        System.runAs(getUser('Ross Geller')) {
            Test.startTest();
            new LoanPayoffController();
            System.assertEquals(1, getLogMessage().size(), 'Exception expected for invalid party type');
            Test.stopTest();
        }
    }
}