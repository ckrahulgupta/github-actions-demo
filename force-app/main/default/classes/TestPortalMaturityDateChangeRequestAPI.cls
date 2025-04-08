/**
 * @description       : This is a TEST Class for PortalMaturityDateChangeRequestAPI
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 01-04-2025
 * @last modified by  : Rakesh Saraf
**/
@isTest
public class TestPortalMaturityDateChangeRequestAPI {

    @TestSetup
    static void makeData(){
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
    }

   
    /**
    * @description tests foe default success for PortalMatruityDateChangeRequestAPI class
    * @author Rakesh Saraf | 11-25-2024 
    **/
    @isTest
    public static void testPortalMaturityDateChangeRequestAPISuccess() {

        genesis__Applications__c applicationObj = [ SELECT Id,
                                                            genesis__Account__r.Name,
                                                            genesis__Loan_Number__c,
                                                            genesis__Maturity_Date__c,
                                                            genesis__Account__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c='300023456'];
        
        Map<String, Object> requestMap = new Map<String, Object>{
            ConstantValues.LOAN_NUMBER => applicationObj.genesis__loan_number__c,
            ConstantValues.MATURITY_DATE => '2025-12-15',
            ConstantValues.GROWER_NAME => applicationObj.genesis__Account__r.Name,
            ConstantValues.OLD_MATURITY_DATE =>'2025-11-15',
            PortalConstants.APPLICATION_ID => applicationObj.id
        };
        User certifiedLenderUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');

        Test.startTest();
        System.runAs(certifiedLenderUserObj) {
            //Calling the API
            PortalMaturityDateChangeRequestAPI saveApi = new PortalMaturityDateChangeRequestAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS');
        }
        Test.stopTest();
    }
    
    /**
    * @description requested maturity date is not 15th of a month.
    * @author Rakesh Saraf | 11-25-2024 
    **/
    @isTest
    public static void testIncorrectMaturityDate() {
        genesis__Applications__c applicationObj = [ SELECT Id,
                                                            genesis__Account__r.Name,
                                                            genesis__Loan_Number__c,
                                                            genesis__Maturity_Date__c,
                                                            genesis__Account__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c='300023456'];
        Map<String, Object> requestMap = new Map<String, Object>{
            ConstantValues.LOAN_NUMBER => applicationObj.genesis__loan_number__c,
            ConstantValues.MATURITY_DATE => '2025-10-17',
            ConstantValues.GROWER_NAME => applicationObj.genesis__Account__r.Name,
            ConstantValues.OLD_MATURITY_DATE => applicationObj.genesis__Maturity_Date__c,
            PortalConstants.APPLICATION_ID => applicationObj.id
        };
        User certifiedLenderUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');

        Test.startTest();
        System.runAs(certifiedLenderUserObj) {
            //Calling the API
            PortalMaturityDateChangeRequestAPI saveApi = new PortalMaturityDateChangeRequestAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'SUCCESS');
        }
        Test.stopTest();
    }
    
    /**
    * @description requested maturity date is beyond 60 days.
    * @author Rakesh Saraf | 11-25-2024 
    **/
    @isTest
    public static void testMaturityDateBeyondSixtyDays() {
        genesis__Applications__c applicationObj = [ SELECT Id,
                                                            genesis__Account__r.Name,
                                                            genesis__Loan_Number__c,
                                                            genesis__Maturity_Date__c,
                                                            genesis__Account__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c='300023456'];
        Map<String, Object> requestMap = new Map<String, Object>{
            ConstantValues.LOAN_NUMBER => applicationObj.genesis__loan_number__c,
            ConstantValues.MATURITY_DATE => applicationObj.genesis__Maturity_Date__c.addMonths(3),
            ConstantValues.GROWER_NAME => applicationObj.genesis__Account__r.Name,
            ConstantValues.OLD_MATURITY_DATE => applicationObj.genesis__Maturity_Date__c,
            PortalConstants.APPLICATION_ID => applicationObj.id
        };
        User certifiedLenderUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');

        Test.startTest();
        System.runAs(certifiedLenderUserObj) {
            //Calling the API
            PortalMaturityDateChangeRequestAPI saveApi = new PortalMaturityDateChangeRequestAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'SUCCESS');
        }
        Test.stopTest();
    }
    
    /**
    * @description exception for grower name missing in the request map
    * @author Rakesh Saraf | 11-25-2024 
    **/
    @isTest
    public static void testGrowerNameMissing() {
        genesis__Applications__c applicationObj = [ SELECT Id,
                                                            genesis__Account__r.Name,
                                                            genesis__Loan_Number__c,
                                                            genesis__Maturity_Date__c,
                                                            genesis__Account__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c='300023456'];
        Map<String, Object> requestMap = new Map<String, Object>{
            ConstantValues.LOAN_NUMBER => applicationObj.genesis__loan_number__c,
            ConstantValues.MATURITY_DATE => '2025-12-15',
            ConstantValues.OLD_MATURITY_DATE => applicationObj.genesis__Maturity_Date__c,
            PortalConstants.APPLICATION_ID => applicationObj.id
        };
        User certifiedLenderUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(certifiedLenderUserObj) {
            //Calling the API
            PortalMaturityDateChangeRequestAPI saveApi = new PortalMaturityDateChangeRequestAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'API EXCEPTION');
        }
        Test.stopTest();
    }
    
    /**
    * @description exception for loan number missing in the request map
    * @author Rakesh Saraf | 11-25-2024 
    **/
    @isTest
    public static void testLoanNumberMissing() {
        genesis__Applications__c applicationObj = [ SELECT Id,
                                                            genesis__Account__r.Name,
                                                            genesis__Loan_Number__c,
                                                            genesis__Maturity_Date__c,
                                                            genesis__Account__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c='300023456'];
        Map<String, Object> requestMap = new Map<String, Object>{
            ConstantValues.MATURITY_DATE => '2025-12-15',
            ConstantValues.GROWER_NAME => applicationObj.genesis__Account__r.Name,
            ConstantValues.OLD_MATURITY_DATE => applicationObj.genesis__Maturity_Date__c,
            PortalConstants.APPLICATION_ID => applicationObj.id
        };
        User certifiedLenderUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(certifiedLenderUserObj) {
            //Calling the API
            PortalMaturityDateChangeRequestAPI saveApi = new PortalMaturityDateChangeRequestAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'API EXCEPTION');
        }
        Test.stopTest();
    }
    
    /**
    * @description exception for new maturity date missing in the request map
    * @author Rakesh Saraf | 11-25-2024 
    **/
    @isTest
    public static void testNewlMaturityDateMissing() {
        genesis__Applications__c applicationObj = [ SELECT Id,
                                                            genesis__Account__r.Name,
                                                            genesis__Loan_Number__c,
                                                            genesis__Maturity_Date__c,
                                                            genesis__Account__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c='300023456'];
        Map<String, Object> requestMap = new Map<String, Object>{
            ConstantValues.LOAN_NUMBER => applicationObj.genesis__loan_number__c,
            ConstantValues.GROWER_NAME => applicationObj.genesis__Account__r.Name,
            ConstantValues.OLD_MATURITY_DATE => applicationObj.genesis__Maturity_Date__c,
            PortalConstants.APPLICATION_ID => applicationObj.id
        };
        User certifiedLenderUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(certifiedLenderUserObj) {
            //Calling the API
            PortalMaturityDateChangeRequestAPI saveApi = new PortalMaturityDateChangeRequestAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'API EXCEPTION');
        }
        Test.stopTest();
    }
    
    /**
    * @description exception for current maturity date missing in the request map
    * @author Rakesh Saraf | 11-25-2024 
    **/
    @isTest
    public static void testCurrentlMaturityDateMissing() {
        genesis__Applications__c applicationObj = [ SELECT Id,
                                                            genesis__Account__r.Name,
                                                            genesis__Loan_Number__c,
                                                            genesis__Maturity_Date__c,
                                                            genesis__Account__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c='300023456'];
        Map<String, Object> requestMap = new Map<String, Object>{
            ConstantValues.LOAN_NUMBER => applicationObj.genesis__loan_number__c,
            ConstantValues.MATURITY_DATE => '2025-12-15',
            ConstantValues.GROWER_NAME => applicationObj.genesis__Account__r.Name,
            PortalConstants.APPLICATION_ID => applicationObj.id
        };
        User certifiedLenderUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
        Test.startTest();
        System.runAs(certifiedLenderUserObj) {
            //Calling the API
            PortalMaturityDateChangeRequestAPI saveApi = new PortalMaturityDateChangeRequestAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'API EXCEPTION');
        }
        Test.stopTest();
    }
    
    /**
    * @description test case for when all the parameters are empty strings
    * @author Rakesh Saraf | 11-25-2024 
    **/
    @isTest
    public static void testArgsMising() {
         Map<String, Object> requestMap = new Map<String, Object>{
            ConstantValues.LOAN_NUMBER => PortalConstants.SPACE_STRING,
            ConstantValues.MATURITY_DATE => PortalConstants.SPACE_STRING,
            ConstantValues.GROWER_NAME => PortalConstants.SPACE_STRING,
            ConstantValues.OLD_MATURITY_DATE => PortalConstants.SPACE_STRING,
            PortalConstants.APPLICATION_ID => PortalConstants.SPACE_STRING
        };
        User certifiedLenderUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');

        Test.startTest();
        System.runAs(certifiedLenderUserObj) {
            //Calling the API
            PortalMaturityDateChangeRequestAPI saveApi = new PortalMaturityDateChangeRequestAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'API EXCEPTION');
        }
        Test.stopTest();
    }
}