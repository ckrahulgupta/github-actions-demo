/**
 * @description       : Test class for PortalProductReturn
 * @author            : Simran
 * @group             : 
 * @last modified on  : 01-24-2025
 * @last modified by  : Ayan Khanra
**/
@isTest
private without sharing  class PortalProductReturnTest {
    /**
     * @description : This method is to prepare data for the test class
     * @author Ayan Khanra | 01-12-2025 
     **/
    @TestSetup
    static void makeData(){
        ApplicationOriginationSetupTestHelper.createTestSetup(); 
        clcommon__Payment_Mode__c productReturnModeObj = new clcommon__Payment_Mode__c(Name=ConstantValues.PRODUCT_RETURN);
        Database.insert(productReturnModeObj, true);
        List<genesis__Applications__c> applicationList =  [SELECT Id,
                                                                    Name,
                                                                    Dealer_Name__c,
                                                                    genesis__Loan_Number__c,
                                                                    Internal_Reference_Code__c 
                                                            FROM genesis__Applications__c 
                                                            WHERE Internal_Reference_Code__c ='testApp001'];                                                   
        List<Account> clAccountList = [SELECT ID
                                        FROM Account
                                        WHERE Name = 'Ross Geller'];                                                   
        applicationList[0].Certified_Lender__c =  clAccountList[0].Id;
        Database.update(applicationList[0],true);                                                  
        genesis__Application_Pricing_Detail__c pricingDetailObj = ApplicationOriginationTestHelper.createPricingDetail(applicationList[0].Id);
        pricingDetailObj.Loan_Number__c = applicationList[0].genesis__Loan_Number__c;
        pricingDetailObj.Principal_Advanced__c = 500.00;
        pricingDetailObj.genesis__Enabled_Flag__c = true;
        pricingDetailObj.Loan_Id__c='139001';
        Database.upsert(pricingDetailObj,true);
        clcommon__Bank_Account__c dealerbankObj = ApplicationOriginationTestHelper.createBankAccount();
        dealerbankObj.clcommon__Account__c = applicationList[0].Dealer_Name__c;
        dealerbankObj.ACH_Credit__c = true;
        dealerbankObj.ACH_Debit__c = true;
        dealerbankObj.clcommon__Active__c = true;
        dealerbankObj.clcommon__Account_Type__c = 'Savings';
        Database.insert(dealerbankObj,true);
        List<Contact> borrContactlist = [SELECT ID,
                                                AccountId
                                        FROM Contact
                                        WHERE Email = 'jasmin.albin@yopmail.com' Limit 1];
        Dealer_Applicant_Relationship__c dealerAppRelationObj= ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrContactlist[0],applicationList[0].Dealer_Name__c);
        Database.insert(dealerAppRelationObj,true);
    }

    /**
     * @description : This test method validates succes response upon product return
     * @author Ayan Khanra | 01-01-2025 
     **/
    @isTest
    private static void testProductReturnSuccess(){
        genesis__Application_Pricing_Detail__c childLoanObj = getPricingDetail();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id', 'new_record_id');
        requestMap.put('amount', 20);
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();  
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();  
        } 
    }
    /**
    * @description : This test method updates the  pricipal advance amount and peak loan volumn(PLV)
    * @author Ayan Khanra | 01-01-2025 
    **/
    @isTest
    private static void testUpdatedPrincipalAdvanceAndPLVSuccess(){
        genesis__Application_Pricing_Detail__c childLoanObj = getPricingDetail();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id', 'new_record_id');
        requestMap.put('amount', 100);
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
        List<genesis__Application_Pricing_Detail__c> pricingDetailList = [SELECT Id,
                                                                                Principal_Advanced__c,
                                                                                genesis__Application__r.Peak_Loan_Volume__c
                                                                            FROM genesis__Application_Pricing_Detail__c 
                                                                            WHERE Loan_Id__c = '139001'];
        System.assertEquals(400,pricingDetailList[0].Principal_Advanced__c,'Principal Advance amount not upated');
        System.assertEquals(14900,pricingDetailList[0].genesis__Application__r.Peak_Loan_Volume__c,'Peak Loan volumn not updated');
    }
    /**
    * @description : This method test for new funding transaction creation
    * @author Ayan Khanra | 01-01-2025 
    **/
    @isTest
    private static void testFundingTransactionCreationSuccess(){
        genesis__Application_Pricing_Detail__c childLoanObj  =  getPricingDetail();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id', 'new_record_id');
        requestMap.put('amount', 20);
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
            List<genesis__Funding_Transaction__c> tranctionList = [SELECT Id, 
                                                                            genesis__Application__c,
                                                                            Pricing_Detail__c 
                                                                    FROM genesis__Funding_Transaction__c 
                                                                    WHERE Pricing_Detail__c =: childLoanObj.Id];
            System.assertEquals(1,tranctionList.size(),'Funding transaction not created for product return'); 
            Test.stopTest();
        }                                                          
    }
    /**
     * @description :This test method  Gives exception for pricing detail key missing and cretes log 
     * @author Ayan Khanra | 01-01-2025 
     **/
    @isTest
    private static void testPricingDetailKeyMissingAndLogException(){
        genesis__Application_Pricing_Detail__c childLoanObj = getPricingDetail();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id', 'new_record_id');
        requestMap.put('amount', 20);
        requestMap.put('purpose', 'chocolate');
        requestMap.put('', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success response received for misssing pricing detail key');
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Log not inserted'); 
            Test.stopTest(); 
        } 
    }
    /**
     * @description : This test method Gives exception for purpose key missing
     * @author Ayan Khanra | 01-01-2025 
     **/
    @isTest
    private static void testPurposeKeyMissingException(){
        genesis__Application_Pricing_Detail__c childLoanObj = getPricingDetail();
        PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id', 'new_record_id');
        requestMap.put('amount', 20);
        requestMap.put('', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success response received for missing puspose key');
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Log not inserted');
            Test.stopTest();  
        }
    }
    /**
     * @description : Gives exception for amount key missing
     * @author Ayan Khanra | 01-01-2025 
     **/
    @isTest
    private static void testAmountKeyMissingException(){
        genesis__Application_Pricing_Detail__c childLoanObj = getPricingDetail();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id', 'new_record_id');
        requestMap.put('', 20);
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success response received for missing amount key');
            Test.stopTest();  
        }  
    }
    /**
     * @description : This test method gives exception for funding transaction key missing
     * @author Ayan Khanra | 12-31-2024 
     **/
    @isTest
    private static void testFundingDetailsKeyMissing(){
        genesis__Application_Pricing_Detail__c childLoanObj = getPricingDetail();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('', 'new_record_id');
        requestMap.put('amount', 20);
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser(); 
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success response received for missing funding transaction key');
            Test.stopTest();  
        }  
    }
    /**
     * @description : This test method gives exception for null product return amount
     * @author Ayan Khanra | 01-01-2025 
     **/
    @isTest
    private static void testProductReturnAmountNullValueException(){
        genesis__Application_Pricing_Detail__c childLoanObj = getPricingDetail();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id', 'new_record_id');
        requestMap.put('amount', null);
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();       
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success response received for null puspose value');
            Test.stopTest();  
        }
    }
    /**
     * @description : This test method Gives exception for null puspose value
     * @author Ayan Khanra | 01-01-2025 
     **/
    @isTest
    private static void testPurposeNullValueException(){
        genesis__Application_Pricing_Detail__c childLoanObj = getPricingDetail();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id', 'new_record_id');
        requestMap.put('amount', 20);
        requestMap.put('purpose', null);
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success response received for null puspose value');
            Test.stopTest(); 
        }     
    }
    /**
     * @description : This test method gives exception for null funding Transaction
     * @author Ayan Khanra | 01-01-2025 
     **/
    @isTest
    private static void testFundingTransactionNullValueException(){
        genesis__Application_Pricing_Detail__c childLoanObj = getPricingDetail();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id',null);
        requestMap.put('amount', 20);
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success response received for null funding Transaction');
            Test.stopTest(); 
        } 
    }
    /**
     * @description : This test method Gives Exception for product return amount zero
     * @author Ayan Khanra | 01-01-2025 
     **/
    @isTest
    private static void testAmountValueZeroException(){
        genesis__Application_Pricing_Detail__c childLoanObj = getPricingDetail();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id','new_record_id');
        requestMap.put('amount', 0);
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success response received for Zero product return amount');
            Test.stopTest(); 
        }   
    }
    /**
     * @description : This test method gives exeption for negetive product return amount
     * @author Ayan Khanra | 01-01-2025 
     **/
    @isTest
    private static void testNegetiveAmountException(){
        genesis__Application_Pricing_Detail__c childLoanObj = getPricingDetail();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id','new_record_id');
        requestMap.put('amount', -200);
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success response received for Negetive product return amount');
            Test.stopTest(); 
        } 
    }
    /**
     * @description : This test method gives Exception if Payment Mode not present
     * @author Ayan Khanra | 01-01-2025 
     **/
    @isTest
    private static void testEmptyPaymentModeException(){
        genesis__Application_Pricing_Detail__c childLoanObj = getPricingDetail();
        Database.delete([SELECT Id FROM clcommon__Payment_Mode__c]);
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id', 'new_record_id');
        requestMap.put('amount', 20);
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success response received for Dealer Empty Payment Mode');
            Test.stopTest(); 
        }    
    }
    /**
     * @description : This test method gives Exception for Empty Bank Information
    * @author Ayan Khanra | 01-01-2025 
    **/
    @isTest
    private static void testEmptyBankInformationException(){
        genesis__Application_Pricing_Detail__c childLoanObj = getPricingDetail();
        Database.delete([SELECT Id 
                        FROM clcommon__Bank_Account__c
                        WHERE clcommon__Account__c =: childLoanObj.genesis__Application__r.Dealer_Name__c]);
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id', 'new_record_id');
        requestMap.put('amount', 20);
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success response received for Dealer Empty Bank info');
            Test.stopTest(); 
        }
    }
    /**
    * @description : This test method gives Exception for null loan number
    * @author Ayan Khanra | 01-01-2025 
    **/
    @isTest
    private static void testNullLoanNumberException(){
        genesis__Application_Pricing_Detail__c childLoanObj = getPricingDetail();
        childLoanObj.Loan_Number__c  = null;
        Database.update(childLoanObj,true);
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id', 'new_record_id');
        requestMap.put('amount', 20);
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success response received for null loan number');
            Test.stopTest(); 
        }  
    }
    /**
    * @description : This test method Gives Exception for not valid user
    * @author Ayan Khanra | 01-01-2025 
    **/
    @isTest
    private static void testNonAuthorisedUserException(){
        genesis__Application_Pricing_Detail__c childLoanObj = getPricingDetail();
        List<clcommon__Party__c> clPartyList = [SELECT ID FROM clcommon__Party__c WHERE genesis__Application__r.Internal_Reference_Code__c ='testApp001'];
        Database.delete(clPartyList[0]);
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id', 'new_record_id');
        requestMap.put('amount', 20);
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success response received for Not Authorised User');
            Test.stopTest(); 
        }  
    }
    /**
    * @description :This test method gives exception for past due loan
    * @author Ayan Khanra | 01-01-2025 
    **/
    @isTest
    private static void testPastDueLoanException(){
        genesis__Application_Pricing_Detail__c childLoanObj = getPricingDetail();
        childLoanObj.Past_Due_Balance__c = 50;
        Database.update(childLoanObj,true);
        Date maturityDate = System.today().addDays(-30);
        genesis__Applications__c applicationObj = new genesis__Applications__c(Id = childLoanObj.genesis__Application__c,genesis__Maturity_Date__c = maturityDate);
        Database.update(applicationObj,true);
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id', 'new_record_id');
        requestMap.put('amount', 20);
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success Response received for Past Due Loan'); 
            Test.stopTest();
        }  
    }
    /**
    * @description : This test method gives Exception for same month maturity and current month
    * @author Ayan Khanra | 01-01-2025 
    **/
    @isTest
    private static void testMaturityCurrentSameMonthException(){
        genesis__Application_Pricing_Detail__c childLoanObj  = getPricingDetail();
        Date maturityDate = System.today();
        genesis__Applications__c applicationObj = new genesis__Applications__c(Id = childLoanObj.genesis__Application__c,genesis__Maturity_Date__c = maturityDate);
        Database.update(applicationObj,true);
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id', 'new_record_id');
        requestMap.put('amount', 20);
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success Response Received for Same Maturity Month');
            Test.stopTest(); 
        }  
    }
    /**
    * @description : This test method Gives exception For past maturity date
    * @author Ayan Khanra | 01-01-2025 
    **/
    @isTest
    private static void testPastMaturityDateException(){
        genesis__Application_Pricing_Detail__c childLoanObj =  getPricingDetail();
        Date maturityDate = System.today().addDays(-60);
        genesis__Applications__c applicationObj = new genesis__Applications__c(Id = childLoanObj.genesis__Application__c,genesis__Maturity_Date__c = maturityDate);
        Database.update(applicationObj,true);
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id', 'new_record_id');
        requestMap.put('amount', 20);
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success Response received for Past Maturity Date');
            Test.stopTest();
        }  
    }
    /**
    * @description :This test method Gives exception when return amount is higher than prinicipal advance amount
    * @author Ayan Khanra | 01-01-2025 
    **/
    @isTest
    private static void testReturnAmountHigherException(){
        genesis__Application_Pricing_Detail__c childLoanObj = getPricingDetail();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id', 'new_record_id');
        requestMap.put('amount', 2000);
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success Response Received for Higher product return amount');
            Test.stopTest(); 
        }  
    }
    /**
    * @description :This test method Gives exception for invalid loan amount that can't be converted to decimal
    * @author Ayan Khanra | 01-01-2025 
    **/
    @isTest
    private static void testNotConvertableLoanAmountException(){
        genesis__Application_Pricing_Detail__c childLoanObj = getPricingDetail();
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('Id', 'new_record_id');
        requestMap.put('amount', 'ABC');
        requestMap.put('purpose', 'chocolate');
        requestMap.put('pricingId', childLoanObj.Id);
        List<User> clUser = getUser();
        System.runAs(clUser[0]){
            Test.startTest();
            PortalProductReturnAPI productReturnAPIInst = new PortalProductReturnAPI();
            clcommon.Response response = productReturnAPIInst.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success Response Received for Not valid product return amount');
            List<clcommon__Log__c> logList = getInsertedLog();
            System.assertEquals(1,logList.size(),'Log not inserted'); 
            Test.stopTest(); 
        }  
    }
    /**
    * @description : Returns cl and sa User from createTestSetup()
    * @author Ayan Khanra | 01-07-2025 
    * @return List<User> 
    **/
    private static List<User> getUser(){
        return [SELECT Id,
                        Email 
                FROM User 
                WHERE Email  = 'cfanewus5er@yopmail.com' Limit 1];
    }
    /**
    * @description : Returns Pricing Detail
    * @author Ayan Khanra | 01-07-2025 
    * @return List<genesis__Application_Pricing_Detail__c> 
    **/
    private static  genesis__Application_Pricing_Detail__c  getPricingDetail(){
        return [SELECT Id,
                        genesis__Application__c,
                        genesis__Application__r.Dealer_Name__c 
                FROM genesis__Application_Pricing_Detail__c 
                WHERE Loan_Id__c = '139001' Limit 1];
    }
    /**
    * @description : This method returns inserted logs
    * @author Ayan Khanra | 01-07-2025 
    * @return List<clcommon__Log__c> 
    **/
    private static List<clcommon__Log__c> getInsertedLog(){
        return [SELECT ID
                FROM clcommon__Log__c 
                WHERE Name = 'PortalProductReturnAPI' Limit 1];
    }
}