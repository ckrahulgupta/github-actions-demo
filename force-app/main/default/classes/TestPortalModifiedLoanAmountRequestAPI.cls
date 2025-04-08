/**
 * @description       : This is a TEST Class for PortalModifiedLoanAmountRequestAPI
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 01-04-2025
 * @last modified by  : Rakesh Saraf
**/
@isTest
public class TestPortalModifiedLoanAmountRequestAPI {
    @TestSetup
    static void setUpTestData(){
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

        // Creating new partner program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);

        genesis__Business_Information__c dealerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj,true);

        // creating Reciprocal role
        clcommon__Reciprocal_Role__c roleObj = LoanServicingTestHelper.createReciprocalRole('Certified Lender');
        Database.insert(roleObj,true);

        // creating cl product
        clcommon__CL_Product__c clProductObj=LoanServicingTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        // creating cl purpose
        clcommon__CL_Purpose__c clPurposeObj=LoanServicingTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj,true);

        // creating legal entity 
        clcommon__Legal_Entity__c entityObj= LoanServicingTestHelper.createLegalEntity('Individual(s) with DBA');
        Database.insert(entityObj,true);

        // Creating dealer account
        Account dealerAccountObj = LoanServicingTestHelper.createDealerAccount(dealerBusinessInfoObj.Id, newPartnerProgramObj.id);
        
        // creating certified lender account
        Account clAccountObj = LoanServicingTestHelper.createCLAccount(dealerBusinessInfoObj.Id,dealerAccountObj.Id);
    
        //creating borrower account
        Account borrowerAccountObj=LoanServicingTestHelper.createSolePropAccount(entityObj,LoanServicingTestHelper.createBusinessInfoForBorrower().Id);

        List<Account> accountObjList = new  List<Account>{
            dealerAccountObj,
            clAccountObj,
            borrowerAccountObj
        };
        Database.insert(accountObjList,true);

        // Creating Contact for Dealer
        Contact dealerContactObj = LoanServicingTestHelper.createDealerContact(dealerAccountObj);
        // creating certified lender contact
        Contact clContactObj = LoanServicingTestHelper.createCLContact(clAccountObj.Id);
        //creating borrower contact
        Contact borrowerContactObj=LoanServicingTestHelper.createBorrowerContact(borrowerAccountObj.Id);

        List<Contact> contactList = new List<Contact>{
            dealerContactObj,
            clContactObj,
            borrowerContactObj
        };
        Database.insert(contactList,true);

        // creating cl user
        User clUserObj = LoanServicingTestHelper.createCLUser(clContactObj.Id);

        // create borrower user
        User borrowerUserObj = LoanServicingTestHelper.createBorrowerUser(borrowerContactObj.Id);

        List<User> userList = new List<User>{
            clUserObj,
            borrowerUserObj
        };
        Database.insert(userList,true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = LoanServicingTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        Map<String,Id> paramIdMap=new Map<String,Id>{
            'dealerAccountId'=> dealerAccountObj.Id,
            'clProductId'=> clProductObj.Id,
            'clPurposeId'=> clPurposeObj.Id,
            'borrowerAccountId'=> borrowerAccountObj.Id,
            'borrowerContactId'=> borrowerContactObj.Id,
            'clAccountId'=> clAccountObj.Id
        };
        //creating application obj
        genesis__Applications__c applicationObj = LoanServicingTestHelper.createCurrCropYearApplication(paramIdMap);

        // creating a dealer applicant relationship
        Dealer_Applicant_Relationship__c dealerApplicantRelObj=LoanServicingTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.id);
        Database.insert(dealerApplicantRelObj,true);

        //linking it to the application
        applicationObj.Dealer_Applicant_Relationship__c=dealerApplicantRelObj.id;
        applicationObj.Dealer_Name__c = dealerAccountObj.id;

        Database.insert(applicationObj,true);

        // Creating Borrower Party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = LoanServicingTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c clPartyTypeObj = LoanServicingTestHelper.createPartyType('CERTIFIED LENDER');
        clcommon__Party_Type__c dealerPartyTypeObj = LoanServicingTestHelper.createPartyType('DEALER');


        Database.insert(new List<clcommon__Party_Type__c>{borrowerPartyTypeObj,clPartyTypeObj,dealerPartyTypeObj}, true);

        // Creating Borrower Party
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId'=> borrowerAccountObj.Id,
            'contactId'=> borrowerContactObj.Id,
            'partyTypeId'=> borrowerPartyTypeObj.Id,
            'applicationId'=> applicationObj.Id
        };
        clcommon__Party__c borrowerPartyObj = LoanServicingTestHelper.createParty(paramForBorrowerPartyMap);
        borrowerPartyObj=LoanServicingTestHelper.insertIndividualPartyDetails(borrowerPartyObj,dealerAccountObj.id);


        // Creating Certified Lender Party
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
            'accountId'=> clAccountObj.Id,
            'contactId'=> clContactObj.Id,
            'partyTypeId'=> clPartyTypeObj.Id,
            'applicationId'=> applicationObj.Id
        };
        clcommon__Party__c clPartyObj = LoanServicingTestHelper.createParty(paramForCLPartyMap);

        // Creating Dealer party
        Map<String,Id> paramForDealerPartyMap = new Map<String,Id>{
            'accountId'=> dealerAccountObj.Id,
            'contactId'=> dealerContactObj.Id,
            'partyTypeId'=> dealerPartyTypeObj.Id,
            'applicationId'=> applicationObj.Id
        };
        clcommon__Party__c dealerPartyObj = LoanServicingTestHelper.createParty(paramForDealerPartyMap);
        Database.insert(new List<clcommon__Party__c>{borrowerPartyObj,clPartyObj,dealerPartyObj}, true);

        Map<String, clcommon__Payment_Mode__c> paymentModeMap = LoanServicingTestHelper.createPaymentMode();

        // Create ACH Payment Mode
        clcommon__Payment_Mode__c achPaymentModeObj = paymentModeMap.get('ACH');
        //Database.insert(achPaymentModeObj,true);
        
        clcommon__Payment_Mode__c draftPaymentModeObj = paymentModeMap.get('DRAFT');
        //Database.insert(draftPaymentModeObj,true);

        List<clcommon__Payment_Mode__c> paymentMode = new List<clcommon__Payment_Mode__c>{
            draftPaymentModeObj,
            achPaymentModeObj
        };
        Database.insert(paymentMode,true);

        // Creating ACH funding transaction properties
        clcommon__Funding_Transactions_Properties__c achfundingPropertiesObj = LoanServicingTestHelper.createAchFundingTransactionProperties();
        Database.insert(achfundingPropertiesObj,true);
       
        // Creating Rate card setup header
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = LoanServicingTestHelper.createRateCardHeader(borrowerAccountObj);
        Database.insert(rateCardHeaderObj,true);
        // Creating rate card setup detail
        genesis__Rate_Card_Setup_Detail__c rateCardDetailObj = LoanServicingTestHelper.createRateCardSetupDetail(rateCardHeaderObj);
        Database.insert(rateCardDetailObj,true);
        // Creating pricing detail
        genesis__Application_Pricing_Detail__c pricingDetailsObj = LoanServicingTestHelper.createEnabledPricingDetail(applicationObj,rateCardDetailObj.Id);
        pricingDetailsObj.Principal_Advanced__c = 0;
        Database.insert(pricingDetailsObj,true);

        // Creating ACH funding transaction
        genesis__Funding_Transaction__c achfundingTransactionObj = LoanServicingTestHelper.createFundingTransaction(achPaymentModeObj.Id, achfundingPropertiesObj.Id, applicationObj.Id);
        achfundingTransactionObj.Pricing_Detail__c = achfundingTransactionObj.id;
        Database.insert(achfundingTransactionObj,true);
    }
    
    /**
    * @description test for default success
    * @author Rakesh Saraf | 01-04-2025 
    **/
    @isTest
    public static void testModifiedLoanSuccess(){
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = [SELECT Id,Certified_Lender__c,genesis__Loan_Number__c,genesis__Loan_Amount__c,genesis__Account__r.Name FROM genesis__Applications__c LIMIT 1];
        Account accountObj = [SELECT Id, Name FROM Account WHERE Id =:applicationObj.Certified_Lender__c];
        Contact contactObj = [SELECT Id,Email, accountId FROM Contact WHERE AccountId =:accountObj.id];
        User clUser = [SELECT Id,ContactId FROM USER WHERE Profile.Name = 'Certified Lender' and ContactId =: contactObj.id LIMIT 1];


        requestMap.put('loanNumber',applicationObj.genesis__Loan_Number__c);
        requestMap.put('loanAmount', applicationObj.genesis__Loan_Amount__c);
        requestMap.put('growerName',applicationObj.genesis__Account__r.Name);
        requestMap.put(PortalConstants.APPLICATION_ID,applicationObj.id); 
       
        System.runAs(clUser){
            Test.startTest();
            PortalModifiedLoanAmountRequestAPI saveApi = new PortalModifiedLoanAmountRequestAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success');
        }
    }
    @isTest
    public static void testWithoutLoanNumberParam() {
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = [SELECT Id,Certified_Lender__c,genesis__Loan_Amount__c,genesis__Account__r.Name FROM genesis__Applications__c LIMIT 1];
        Account accountObj = [SELECT Id, Name FROM Account WHERE Id =:applicationObj.Certified_Lender__c];
        Contact contactObj = [SELECT Id,Email, accountId FROM Contact WHERE AccountId =:accountObj.id];
        User clUser = [SELECT Id,ContactId FROM USER WHERE Profile.Name = 'Certified Lender' and ContactId =: contactObj.id LIMIT 1];

        requestMap.put('loanAmount', applicationObj.genesis__Loan_Amount__c);
        requestMap.put('growerName',applicationObj.genesis__Account__r.Name);
        requestMap.put('applicationId',applicationObj.id);
       
        System.runAs(clUser){
            Test.startTest();
            PortalModifiedLoanAmountRequestAPI saveApi = new PortalModifiedLoanAmountRequestAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Failure');
        }
    }
    
    /**
    * @description test for without application id being passed
    * @author Rakesh Saraf | 01-04-2025 
    **/
    @isTest
    public static void testWithoutApplicationIdParam() {
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = [SELECT Id,Certified_Lender__c,genesis__Loan_Amount__c,genesis__Loan_Number__c,genesis__Account__r.Name FROM genesis__Applications__c LIMIT 1];
        Account accountObj = [SELECT Id, Name FROM Account WHERE Id =:applicationObj.Certified_Lender__c];
        Contact contactObj = [SELECT Id,Email, accountId FROM Contact WHERE AccountId =:accountObj.id];
        User clUser = [SELECT Id,ContactId FROM USER WHERE Profile.Name = 'Certified Lender' and ContactId =: contactObj.id LIMIT 1];

        requestMap.put('loanAmount', applicationObj.genesis__Loan_Amount__c);
        requestMap.put('loanNumber',applicationObj.genesis__Loan_Number__c);
        requestMap.put('growerName',applicationObj.genesis__Account__r.Name);
       
        System.runAs(clUser){
            Test.startTest();
            PortalModifiedLoanAmountRequestAPI saveApi = new PortalModifiedLoanAmountRequestAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Failure');
        }
    }
    
    /**
    * @description 
    * @author Rakesh Saraf | 01-04-2025 
    **/
    @isTest
    public static void havingBillingCityAndState() {
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = [SELECT Id,Certified_Lender__c,genesis__Loan_Number__c,genesis__Loan_Amount__c,genesis__Account__r.Name FROM genesis__Applications__c LIMIT 1];
        Account accountObj = [SELECT Id, Name FROM Account WHERE Id =:applicationObj.Certified_Lender__c];
        Contact contactObj = [SELECT Id,Email, accountId FROM Contact WHERE AccountId =:accountObj.id];
        User clUser = [SELECT Id,ContactId FROM USER WHERE Profile.Name = 'Certified Lender' and ContactId =: contactObj.id LIMIT 1];

        Account borrowerObj = [SELECT Id,
                                        BillingCity,
                                        BillingState
                                    FROM Account
                                    WHERE Id = :applicationObj.genesis__Account__c];
        borrowerObj.BillingCity = 'Kolkata';
        borrowerObj.BillingState ='WB';
        Database.update(borrowerObj, true);
        
        requestMap.put('loanNumber',applicationObj.genesis__Loan_Number__c);
        requestMap.put('loanAmount', applicationObj.genesis__Loan_Amount__c);
        requestMap.put('growerName',applicationObj.genesis__Account__r.Name);      
        requestMap.put('applicationId',applicationObj.id);      
        System.runAs(clUser){
            Test.startTest();
            PortalModifiedLoanAmountRequestAPI saveApi = new PortalModifiedLoanAmountRequestAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success');
        }
    }
    
    /**
    * @description test for invalid loan number
    * @author Rakesh Saraf | 01-04-2025 
    **/
    @isTest
    public static void testWithInvalidLoanNumber() {
        Map<String,Object> requestMap = new Map<String,Object>();
        genesis__Applications__c applicationObj = [SELECT Id,Certified_Lender__c,genesis__Loan_Amount__c,genesis__Account__r.Name FROM genesis__Applications__c LIMIT 1];
        Account accountObj = [SELECT Id, Name FROM Account WHERE Id =:applicationObj.Certified_Lender__c];
        Contact contactObj = [SELECT Id,Email, accountId FROM Contact WHERE AccountId =:accountObj.id];
        User clUser = [SELECT Id,ContactId FROM USER WHERE Profile.Name = 'Certified Lender' and ContactId =: contactObj.id LIMIT 1];

        requestMap.put('loanNumber','123456789');
        requestMap.put('loanAmount', applicationObj.genesis__Loan_Amount__c);
        requestMap.put('growerName',applicationObj.genesis__Account__r.Name);
        requestMap.put('applicationId',applicationObj.id);
       
        System.runAs(clUser){
            Test.startTest();
            PortalModifiedLoanAmountRequestAPI saveApi = new PortalModifiedLoanAmountRequestAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Failure');
        }
    }
    @isTest
    public static void testInvalidLoanNumberException() {
        Map<String,Object> requestMap = new Map<String,Object>();
       
        genesis__Applications__c applicationObj = [SELECT Id,Certified_Lender__c,genesis__Loan_Amount__c,genesis__Account__r.Name FROM genesis__Applications__c LIMIT 1];
        Account accountObj = [SELECT Id, Name FROM Account WHERE Id =:applicationObj.Certified_Lender__c];
        Contact contactObj = [SELECT Id,Email, accountId FROM Contact WHERE AccountId =:accountObj.id];
        User clUser = [SELECT Id,ContactId FROM USER WHERE Profile.Name = 'Certified Lender' and ContactId =: contactObj.id LIMIT 1];

        requestMap.put('loanNumber',applicationObj.genesis__Loan_Amount__c);
        requestMap.put('loanAmount', applicationObj.genesis__Loan_Amount__c);
        requestMap.put('growerName',applicationObj.genesis__Account__r.Name);
        requestMap.put('applicationId',applicationObj.id);
       
        System.runAs(clUser){
            Test.startTest();
            PortalModifiedLoanAmountRequestAPI saveApi = new PortalModifiedLoanAmountRequestAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), null);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Failure');
        }
    }

    /**
    * @description test for not having billing state and city
    * @author Rakesh Saraf | 01-04-2025 
    **/
    @isTest
    public static void notHavingBillingCityAndState() {
        Map<String,Object> requestMap = new Map<String,Object>();
        
        genesis__Applications__c applicationObj = [SELECT Id,Certified_Lender__c,Dealer_Name__r.Name,genesis__Account__c, genesis__Loan_Amount__c,genesis__Account__r.Name,genesis__Loan_Number__c FROM genesis__Applications__c LIMIT 1];
        Account accountObj = [SELECT Id, Name FROM Account WHERE Id =:applicationObj.Certified_Lender__c];
        Contact contactObj = [SELECT Id,Email, accountId FROM Contact WHERE AccountId =:accountObj.id];
        User clUser = [SELECT Id,ContactId FROM USER WHERE Profile.Name = 'Certified Lender' and ContactId =: contactObj.id LIMIT 1];

        Account dealerObj = [SELECT Id,
                                    Name,
                                    Coop_Type__c
                            FROM Account
                            WHERE Name = :applicationObj.Dealer_Name__r.Name];
        dealerObj.Coop_Type__c = 'Growmark';
        Database.update(dealerObj,true);
        Account borrowerObj = [ SELECT Id
                                FROM Account
                                WHERE Id = :applicationObj.genesis__Account__c];

        clcommon__Party__c borrowerParty=[SELECT ID,
                                                City__c,
                                                State__c
                                        FROM clcommon__Party__c
                                        WHERE clcommon__Account__c=:borrowerObj.id];
        borrowerParty.City__c = null;
        borrowerParty.State__c = null;
        Database.update(borrowerParty, true);

        requestMap.put('loanNumber',applicationObj.genesis__Loan_Number__c);
        requestMap.put('loanAmount', applicationObj.genesis__Loan_Amount__c);
        requestMap.put('growerName',applicationObj.genesis__Account__r.Name);      
        requestMap.put('applicationId',applicationObj.id);      
        System.runAs(clUser){
            Test.startTest();
            PortalModifiedLoanAmountRequestAPI saveApi = new PortalModifiedLoanAmountRequestAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Success');
        }
    }
    
    /**
    * @description test for gmk coop type
    * @author Rakesh Saraf | 01-04-2025 
    **/
    @isTest
    public static void testForGrowmarkCoop() {
        Map<String,Object> requestMap = new Map<String,Object>();
        
        genesis__Applications__c applicationObj = [SELECT Id,Certified_Lender__c,Dealer_Name__r.Coop_Type__c,genesis__Loan_Amount__c,genesis__Account__c,genesis__Loan_Number__c,genesis__Account__r.Name FROM genesis__Applications__c LIMIT 1];
        Account accountObj = [SELECT Id, Name FROM Account WHERE Id =:applicationObj.Certified_Lender__c];
        Contact contactObj = [SELECT Id,Email, accountId FROM Contact WHERE AccountId =:accountObj.id];
        User clUser = [SELECT Id,ContactId FROM USER WHERE Profile.Name = 'Certified Lender' and ContactId =: contactObj.id LIMIT 1];

        applicationObj.Dealer_Name__r.Coop_Type__c = 'PQRS';
        applicationObj.genesis__Loan_Amount__c = 0;
        Database.update(applicationObj, true);
        Account borrowerObj = [SELECT Id,
                                        BillingCity,
                                        BillingState
                                    FROM Account
                                    WHERE Id = :applicationObj.genesis__Account__c];
        borrowerObj.BillingCity = null;
        borrowerObj.BillingState = null;
        Database.update(borrowerObj, true);

        requestMap.put('loanNumber',applicationObj.genesis__Loan_Number__c);
        requestMap.put('loanAmount', applicationObj.genesis__Loan_Amount__c);
        requestMap.put('growerName',applicationObj.genesis__Account__r.Name);      
        System.runAs(clUser){
            Test.startTest();
            PortalModifiedLoanAmountRequestAPI saveApi = new PortalModifiedLoanAmountRequestAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Success');
        }
    }
    

}