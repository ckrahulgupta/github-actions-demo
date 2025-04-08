/**
 * @description       : Test Class for ReserveAmountTrigger & ReserveAmountTriggerHandler
 * @author            : Simran
 * @group             : 
 * @last modified on  : 03-10-2025
 * @last modified by  : Sk Minsar
**/
@isTest
public with sharing class ReserveAmountTriggerTest {

    private static final String KEY_APPLICATION_LIST = 'applicationList';
    private static final String ASSERTION_FAILED = 'Assertion Failed';
    private static final String KEY_DEALER_ACCOUNT_LIST = 'dealerAccountList';
    private static final String SUCCESS = 'Success';
    private static final String KEY_NOTIFICATION_LIST = 'notificationList';
    private static final String CERTIFIED_LENDER_NAME = 'Ross Geller';
    private static final String PROFILE_CFA_USER = 'CFA User';
    
    /**
    * @description - Creating Test Data
    * @author Sk Minsar | 03-04-2025 
    **/
    @TestSetup
    static void makeData(){

        //creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj,true);

        //creating floating rate index
        clcommon__Floating_Rate_Index__c floatingRateIndexObj = LoanServicingTestHelper.createFloatingRateIndex(
            New Map<String, Object>{'Name' => 'Field Finance Rate',
                                    'Base Rate Name' => '4-CFA ADVANTAGE',
                                    'Current Floating Rate' => 11,
                                    'Base Rate Adjuster' => 5.5
            });
        Database.insert(floatingRateIndexObj, true);

        //creating new partnert program
        CFA_Partner_Program__c newPartnerProgramObj = LoanServicingTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);

        //creating dealer account
        Account dealerAccountObj = LoanServicingTestHelper.createDealerAccount(dealerBusinessInfoObj.Id, newPartnerProgramObj.Id);
        Database.insert(dealerAccountObj, true);

        //creating legal entity 
        clcommon__Legal_Entity__c entityObj= LoanServicingTestHelper.createLegalEntity(ConstantValues.SOLE_PROP_ENTITY);
        Database.insert(entityObj,true);

        //creating accounts
        Account clAccountObj = LoanServicingTestHelper.createCLAccount(dealerBusinessInfoObj.Id,dealerAccountObj.Id);
        Account borrowerAccountObj=LoanServicingTestHelper.createSolePropAccount(entityObj,LoanServicingTestHelper.createBusinessInfoForBorrower().Id);
        Database.insert(new List<Account>{clAccountObj, borrowerAccountObj}, true);

        //creating contacts
        Contact clContactObj = LoanServicingTestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj=LoanServicingTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(new List<Contact>{clContactObj, borrowerContactObj}, true);

        //creating reciprocal role
        clcommon__Reciprocal_Role__c roleObj = LoanServicingTestHelper.createReciprocalRole(ConstantValues.CERTIFIED_LENDER);
        Database.insert(roleObj,true);

        //creating Relationship between dealer and certified lender
        clcommon__Relationship__c clDealerRelationshipObj = LoanServicingTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        //creating cl product
        clcommon__CL_Product__c clProductObj=LoanServicingTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        //creating cl purpose
        clcommon__CL_Purpose__c clPurposeObj=LoanServicingTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj,true);

        //creating dealer applicant relationship
        Dealer_Applicant_Relationship__c relationObj = LoanServicingTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Database.insert(relationObj,true);
       
        Map<String,Id> paramIdMap=new Map<String,Id>();
        paramIdMap.put('dealerAccountId',dealerAccountObj.Id);
        paramIdMap.put('clProductId',clProductObj.Id);
        paramIdMap.put('clPurposeId',clPurposeObj.Id);
        paramIdMap.put('borrowerAccountId',borrowerAccountObj.Id);
        paramIdMap.put('borrowerContactId',borrowerContactObj.Id);
        paramIdMap.put('clAccountId',clAccountObj.Id);
        paramIdMap.put('dealerApplicantRelationshipId',relationObj.Id);

        //creating applications
        List<genesis__Applications__c> applicationList = LoanServicingTestHelper.createCurrCropYearApplicationList(paramIdMap, ConstantValues.TWO_HUNDRED_VALUE);
        Database.insert(applicationList, true);

        //creating users
        User adminUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_ADMIN, 'testadminuser445@yopmail.com')[0];
        User cfaUser = LoanServicingTestHelper.createUserByProfileName(PROFILE_CFA_USER, 'test1cfa.user112@yopmail.com')[0];
        User executiveUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_EXECUTIVE, 'test2cfa.user113@yopmail.com')[0];
        User fieldStaffUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_FIELD_STAFF, 'test3cfa.user114@yopmail.com')[0];
        User creditUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_CREDIT, 'test4cfa.user115@yopmail.com')[0];
        User masterCreditUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_MASTER_CREDIT, 'test6cfa.user117@yopmail.com')[0];
        User loanAccountingUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_LOAN_ACCOUNTING, 'test8cfa.user119@yopmail.com')[0];
        User cfaAdminUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_CFA_ADMIN, 'test01cfa.user103@yopmail.com')[0];
        User clUser = LoanServicingTestHelper.createCLUser(clContactObj.Id);
        Database.insert(new List<User>{cfaUser, clUser, executiveUser, fieldStaffUser, creditUser, masterCreditUser, loanAccountingUser, cfaAdminUser, adminUser}, true);

    }

    /**
    * @description - This method queries and returns all the necessary data
    * @author Sk Minsar | 03-05-2025 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getDataMap(){
        List<genesis__Applications__c> applicationList = [SELECT Id, Reserved_Amount__c, genesis__Maturity_Date__c, genesis__Loan_Number__c, genesis__Account__c, Dealer_name__r.CFA_Partner_Program__c FROM genesis__Applications__c WHERE genesis__Status__c =: ConstantValues.ACTIVE ORDER BY genesis__Loan_Number__c LIMIT 200];
        List<Account> dealerAccountList = [SELECT Id, Name, Coop_Type__c FROM Account WHERE RecordType.Name = :ConstantValues.DEALER LIMIT 1];
        List<clcommon__Notification__c> notificationList = [SELECT id, Recipient_Address__c, Email_Status__c, Email_Body__c FROM clcommon__Notification__c WHERE Email_Template__c =: ConstantValues.RESERVE_AMOUNT_EMAIL LIMIT 1];

        return new Map<String, Object>{
            KEY_APPLICATION_LIST => applicationList,
            KEY_DEALER_ACCOUNT_LIST => dealerAccountList,
            KEY_NOTIFICATION_LIST => notificationList
        };
    }

    /**
    * @description - Method to test the updated reserve amount
    * @author Simran | 04-16-2024 
    **/
    @isTest
    public static void updateReserveAmount() {
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].Reserved_Amount__c = 537683.98;
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                Database.update(applicationList[0],true);
                dataMap = getDataMap();
                applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
                List<clcommon__Notification__c> notificationList = (List<clcommon__Notification__c>)dataMap.get(KEY_NOTIFICATION_LIST);
                System.assertEquals(SUCCESS, notificationList[0].Email_Status__c, ASSERTION_FAILED);
                System.assertEquals(ConstantValues.TRUE_VALUE, notificationList[0].Email_Body__c != null, ASSERTION_FAILED);
                System.assertEquals(ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS, notificationList[0].Recipient_Address__c, ASSERTION_FAILED);
                System.assertEquals(537683.98, applicationList[0].Reserved_Amount__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Method to test the update reserve amount for growmark application
    * @author Sk Minsar | 03-07-2025 
    **/
    @isTest
    public static void updateReserveAmountForGmk() {
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        List<Account> dealerAccountList = (List<Account>) dataMap.get(KEY_DEALER_ACCOUNT_LIST);
        dealerAccountList[0].Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
        Database.update(dealerAccountList[0], true);
        applicationList[0].Reserved_Amount__c = 537683.00;
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                Database.update(applicationList[0],true);
                dataMap = getDataMap();
                applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
                List<clcommon__Notification__c> notificationList = (List<clcommon__Notification__c>)dataMap.get(KEY_NOTIFICATION_LIST);
                System.assertEquals(SUCCESS, notificationList[0].Email_Status__c, ASSERTION_FAILED);
                System.assertEquals(ConstantValues.TRUE_VALUE, notificationList[0].Email_Body__c != null, ASSERTION_FAILED);
                System.assertEquals(ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS, notificationList[0].Recipient_Address__c, ASSERTION_FAILED);
                System.assertEquals(537683.00, applicationList[0].Reserved_Amount__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Method to test the negative reserve amount
    * @author Simran | 04-16-2024 
    **/
    @isTest
    public static void updateNegativeReserveAmount() {
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].Reserved_Amount__c = -537683.00;
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                Database.update(applicationList[0],true);
                dataMap = getDataMap();
                applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
                List<clcommon__Notification__c> notificationList = (List<clcommon__Notification__c>)dataMap.get(KEY_NOTIFICATION_LIST);
                System.assertEquals(SUCCESS, notificationList[0].Email_Status__c, ASSERTION_FAILED);
                System.assertEquals(ConstantValues.TRUE_VALUE, notificationList[0].Email_Body__c != null, ASSERTION_FAILED);
                System.assertEquals(ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS, notificationList[0].Recipient_Address__c, ASSERTION_FAILED);
                System.assertEquals(-537683.00, applicationList[0].Reserved_Amount__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Method to test the zero reserve amount
    * @author Sk Minsar | 03-07-2025 
    **/
    @isTest
    public static void updateZeroReserveAmount() {
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].Reserved_Amount__c = 0;
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                Database.update(applicationList[0],true);
                dataMap = getDataMap();
                applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
                List<clcommon__Notification__c> notificationList = (List<clcommon__Notification__c>)dataMap.get(KEY_NOTIFICATION_LIST);
                System.assertEquals(SUCCESS, notificationList[0].Email_Status__c, ASSERTION_FAILED);
                System.assertEquals(ConstantValues.TRUE_VALUE, notificationList[0].Email_Body__c != null, ASSERTION_FAILED);
                System.assertEquals(ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS, notificationList[0].Recipient_Address__c, ASSERTION_FAILED);
                System.assertEquals(0, applicationList[0].Reserved_Amount__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Method to test the null reserve amount
    * @author Sk Minsar | 03-07-2025 
    **/
    @isTest
    public static void updateNullReserveAmount() {
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].Reserved_Amount__c = null;
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                Database.update(applicationList[0],true);
                dataMap = getDataMap();
                applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
                List<clcommon__Notification__c> notificationList = (List<clcommon__Notification__c>)dataMap.get(KEY_NOTIFICATION_LIST);
                System.assertEquals(ConstantValues.ZERO_VALUE, notificationList.size(), ASSERTION_FAILED);
                System.assertEquals(null, applicationList[0].Reserved_Amount__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Method to test updating the reserved amount for multiple applications
    * @author Sk Minsar | 03-07-2025 
    **/
    @isTest
    public static void updateMultipleReserveAmount() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        for(Integer count = 0; count < applicationList.size(); count++){
            applicationList[count].Reserved_Amount__c = 537683.32;
        }
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                try{
                    Database.update(applicationList,true);
                }catch(Exception e){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                }
                dataMap = getDataMap();
                List<clcommon__Notification__c> notificationList = (List<clcommon__Notification__c>)dataMap.get(KEY_NOTIFICATION_LIST);
                System.assertEquals(SUCCESS, notificationList[0].Email_Status__c, ASSERTION_FAILED);
                System.assertEquals(ConstantValues.TRUE_VALUE, notificationList[0].Email_Body__c != null, ASSERTION_FAILED);
                System.assertEquals(ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS, notificationList[0].Recipient_Address__c, ASSERTION_FAILED);
                System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Method to test the user access for CL profile
    * @author Simran | 04-16-2024 
    **/
    @isTest
    public static void checkCLUserAccessEx() {
        User userObj = LoanServicingTestHelper.getCertifiedLenderUser(CERTIFIED_LENDER_NAME);
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].Reserved_Amount__c = 537683.11;
        if(userObj!=null){
            System.runAs(userObj) {
                Test.startTest();
                    try {
                        Database.update(applicationList[0],true);
                    } catch (Exception e) {
                        isExceptionThrown = ConstantValues.TRUE_VALUE;
                    }
                    System.assertEquals(ConstantValues.TRUE_VALUE, isExceptionThrown, ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description - Method to test the user access for Executive profile
    * @author Simran | 04-16-2024 
    **/
    @isTest
    public static void checkExecutiveUserAccessEx() {
        List<User> userList = LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_EXECUTIVE);
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].Reserved_Amount__c = 537683.22;
        if(!userList.isEmpty()){
            System.runAs(userList[0]) {
                Test.startTest();
                    try {
                        Database.update(applicationList[0]);
                    } catch (Exception e) {
                        isExceptionThrown = ConstantValues.TRUE_VALUE;
                    }
                    System.assertEquals(ConstantValues.TRUE_VALUE, isExceptionThrown, ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }
    
    /**
    * @description - Method to test the user access for Loan Accounting profile
    * @author Sk Minsar | 03-06-2025 
    **/
    @isTest
    public static void checkLoanAccountingUserAccessEx() {
        List<User> userList = LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_LOAN_ACCOUNTING);
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].Reserved_Amount__c = 537683.63;
        if(!userList.isEmpty()){
            System.runAs(userList[0]) {
                Test.startTest();
                    try {
                        Database.update(applicationList[0]);
                    } catch (Exception e) {
                        isExceptionThrown = ConstantValues.TRUE_VALUE;
                    }
                    System.assertEquals(ConstantValues.TRUE_VALUE, isExceptionThrown, ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description - Method to test the user access for Field Staff profile
    * @author Sk Minsar | 03-06-2025 
    **/
    @isTest
    public static void checkFieldStaffUserAccessEx() {
        List<User> userList = LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_FIELD_STAFF);
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].Reserved_Amount__c = 537683.10;
        if(!userList.isEmpty()){
            System.runAs(userList[0]) {
                Test.startTest();
                    try {
                        Database.update(applicationList[0]);
                    } catch (Exception e) {
                        isExceptionThrown = ConstantValues.TRUE_VALUE;
                    }
                    System.assertEquals(ConstantValues.TRUE_VALUE, isExceptionThrown, ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description - Method to test the user access for CFA User profile
    * @author Sk Minsar | 03-06-2025 
    **/
    @isTest
    public static void checkCFAUserAccessEx() {
        List<User> userList = LoanServicingTestHelper.getUserByProfileName(PROFILE_CFA_USER);
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].Reserved_Amount__c = 537683.10;
        if(!userList.isEmpty()){
            System.runAs(userList[0]) {
                Test.startTest();
                    try {
                        Database.update(applicationList[0]);
                    } catch (Exception e) {
                        isExceptionThrown = ConstantValues.TRUE_VALUE;
                    }
                    System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description - Method to test the user access for CFA Admin User profile
    * @author Sk Minsar | 03-06-2025 
    **/
    @isTest
    public static void checkCFAAdminUserAccess() {
        List<User> userList = LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_CFA_ADMIN);
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].Reserved_Amount__c = 537683.80;
        if(!userList.isEmpty()){
            System.runAs(userList[0]) {
                Test.startTest();
                    try {
                        Database.update(applicationList[0]);
                    } catch (Exception e) {
                        isExceptionThrown = ConstantValues.TRUE_VALUE;
                    }
                    dataMap = getDataMap();
                    List<clcommon__Notification__c> notificationList = (List<clcommon__Notification__c>)dataMap.get(KEY_NOTIFICATION_LIST);
                    System.assertEquals(SUCCESS, notificationList[0].Email_Status__c, ASSERTION_FAILED);
                    System.assertEquals(ConstantValues.TRUE_VALUE, notificationList[0].Email_Body__c != null, ASSERTION_FAILED);
                    System.assertEquals(ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS, notificationList[0].Recipient_Address__c, ASSERTION_FAILED);
                    System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description - Method to test the user access for Credit profile
    * @author Sk Minsar | 03-06-2025 
    **/
    @isTest
    public static void checkCreditUserAccess() {
        List<User> userList = LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_CREDIT);
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].Reserved_Amount__c = 537683.33;
        if(!userList.isEmpty()){
            System.runAs(userList[0]) {
                Test.startTest();
                    try {
                        Database.update(applicationList[0]);
                    } catch (Exception e) {
                        isExceptionThrown = ConstantValues.TRUE_VALUE;
                    }
                    dataMap = getDataMap();
                    List<clcommon__Notification__c> notificationList = (List<clcommon__Notification__c>)dataMap.get(KEY_NOTIFICATION_LIST);
                    System.assertEquals(SUCCESS, notificationList[0].Email_Status__c, ASSERTION_FAILED);
                    System.assertEquals(ConstantValues.TRUE_VALUE, notificationList[0].Email_Body__c != null, ASSERTION_FAILED);
                    System.assertEquals(ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS, notificationList[0].Recipient_Address__c, ASSERTION_FAILED);
                    System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description - Method to test the user access for Master Credit profile
    * @author Sk Minsar | 03-06-2025 
    **/
    @isTest
    public static void checkMasterCreditUserAccess() {
        List<User> userList = LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_MASTER_CREDIT);
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object>  dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].Reserved_Amount__c = 537683.30;
        if(!userList.isEmpty()){
            System.runAs(userList[0]) {
                Test.startTest();
                    try {
                        Database.update(applicationList[0]);
                    } catch (Exception e) {
                        isExceptionThrown = ConstantValues.TRUE_VALUE;
                    }
                    dataMap = getDataMap();
                    List<clcommon__Notification__c> notificationList = (List<clcommon__Notification__c>)dataMap.get(KEY_NOTIFICATION_LIST);
                    System.assertEquals(SUCCESS, notificationList[0].Email_Status__c, ASSERTION_FAILED);
                    System.assertEquals(ConstantValues.TRUE_VALUE, notificationList[0].Email_Body__c != null, ASSERTION_FAILED);
                    System.assertEquals(ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS, notificationList[0].Recipient_Address__c, ASSERTION_FAILED);
                    System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
                Test.stopTest();
            }
        }
    }

    /**
    * @description - Method to test the updated same reserve amount as previous
    * @author Sk Minsar | 03-10-2025 
    **/
    @isTest
    public static void updateSameReserveAmount() {
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].Reserved_Amount__c = 1500.00;
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                Database.update(applicationList[0],true);
                dataMap = getDataMap();
                applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
                List<clcommon__Notification__c> notificationList = (List<clcommon__Notification__c>)dataMap.get(KEY_NOTIFICATION_LIST);
                System.assertEquals(SUCCESS, notificationList[0].Email_Status__c, ASSERTION_FAILED);
                System.assertEquals(ConstantValues.TRUE_VALUE, notificationList[0].Email_Body__c != null, ASSERTION_FAILED);
                System.assertEquals(ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS, notificationList[0].Recipient_Address__c, ASSERTION_FAILED);
                System.assertEquals(1500.00, applicationList[0].Reserved_Amount__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Method to test the missing loan number
    * @author Sk Minsar | 03-10-2025 
    **/
    @isTest
    public static void testLoanNumberMissingEx() {
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Loan_Number__c = null;
        Database.update(applicationList[0], true);
        applicationList[0].Reserved_Amount__c = 537683.55;
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                Database.update(applicationList[0],true);
                dataMap = getDataMap();
                applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
                List<clcommon__Notification__c> notificationList = (List<clcommon__Notification__c>)dataMap.get(KEY_NOTIFICATION_LIST);
                System.assertEquals(ConstantValues.ZERO_VALUE, notificationList.size(), ASSERTION_FAILED);
                System.assertEquals(537683.55, applicationList[0].Reserved_Amount__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Method to test the missing grower name
    * @author Sk Minsar | 03-10-2025 
    **/
    @isTest
    public static void testGrowerNameMissingEx() {
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        applicationList[0].genesis__Account__c = null;
        Database.update(applicationList[0], true);
        applicationList[0].Reserved_Amount__c = 537683.99;
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                Database.update(applicationList[0],true);
                dataMap = getDataMap();
                applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
                List<clcommon__Notification__c> notificationList = (List<clcommon__Notification__c>)dataMap.get(KEY_NOTIFICATION_LIST);
                System.assertEquals(ConstantValues.ZERO_VALUE, notificationList.size(), ASSERTION_FAILED);
                System.assertEquals(537683.99, applicationList[0].Reserved_Amount__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Method to test the missing coop type
    * @author Sk Minsar | 03-10-2025 
    **/
    @isTest
    public static void testCoopTypeMissing() {
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        List<Account> dealerAccountList = (List<Account>) dataMap.get(KEY_DEALER_ACCOUNT_LIST);
        dealerAccountList[0].Coop_Type__c = null;
        Database.update(dealerAccountList[0], true);
        applicationList[0].Reserved_Amount__c = 537683.50;
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                Database.update(applicationList[0],true);
                dataMap = getDataMap();
                applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
                List<clcommon__Notification__c> notificationList = (List<clcommon__Notification__c>)dataMap.get(KEY_NOTIFICATION_LIST);
                System.assertEquals(SUCCESS, notificationList[0].Email_Status__c, ASSERTION_FAILED);
                System.assertEquals(ConstantValues.TRUE_VALUE, notificationList[0].Email_Body__c != null, ASSERTION_FAILED);
                System.assertEquals(ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS, notificationList[0].Recipient_Address__c, ASSERTION_FAILED);
                System.assertEquals(537683.50, applicationList[0].Reserved_Amount__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Method to test the missing partner program logo
    * @author Sk Minsar | 03-10-2025 
    **/
    @isTest
    public static void testProgramLogoMissing() {
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        CFA_Partner_Program__c partnerProgramObj = new CFA_Partner_Program__c(Id = applicationList[0].Dealer_name__r.CFA_Partner_Program__c);
        partnerProgramObj.Dealer_Portal_Logo__c = null;
        Database.update(partnerProgramObj, true);
        applicationList[0].Reserved_Amount__c = 537683.20;
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                Database.update(applicationList[0],true);
                dataMap = getDataMap();
                applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
                List<clcommon__Notification__c> notificationList = (List<clcommon__Notification__c>)dataMap.get(KEY_NOTIFICATION_LIST);
                System.assertEquals(SUCCESS, notificationList[0].Email_Status__c, ASSERTION_FAILED);
                System.assertEquals(ConstantValues.TRUE_VALUE, notificationList[0].Email_Body__c != null, ASSERTION_FAILED);
                System.assertEquals(ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS, notificationList[0].Recipient_Address__c, ASSERTION_FAILED);
                System.assertEquals(537683.20, applicationList[0].Reserved_Amount__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }

}