/**
 * @description       : Test class for GMKSaveRateCardDetailsHandler
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 09-23-2024
 * @last modified by  : Sk Minsar
**/
@isTest
public without sharing class GMKSaveRateCardDetailsHandlerTest {
    /**
    * @description - Creating Test Data
    * @author Sk Minsar | 09-05-2024 
    **/
    @TestSetup
    static void setup(){
        //Creating Product
        clcommon__CL_Product__c objProduct = ApplicationOriginationTestHelper.createLoanProduct();
        Database.insert(objProduct, true);

        //Creating Reciprocal Role
        clcommon__Reciprocal_Role__c clRoleObj = TestClassHelper.createReciprocalRole(PortalConstants.CERTIFIED_LENDER);
        Database.insert(clRoleObj, true);

        //Creating Business Information
        genesis__Business_Information__c businessInfoDealer = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoDealer, true);

        //Creating the Dealer parent account
        Account dealerAccount = ApplicationOriginationTestHelper.createDealerAccount(businessInfoDealer.Id);
        Database.insert(dealerAccount, true);

        //Creating the CL Account
        Account clAccount = ApplicationOriginationTestHelper.createCLAccount(businessInfoDealer.Id,dealerAccount.id);
        Database.insert(clAccount,true);

        //Creating the CL Contact
        Contact clContact = ApplicationOriginationTestHelper.createCLContact(clAccount.Id);
        Database.insert(clContact,true);
        
        //Creating a test user
        User clUser = ApplicationOriginationTestHelper.createCLUser(clContact.Id);
        // clUser.account = clAccount.Id;
        Database.insert(clUser,true);
       

        //Creating Cl Dealer Relationship
        clcommon__Relationship__c cfaDealerClRelationObj = TestClassHelper.createCLDealerRelationship(clRoleObj,
                                                                dealerAccount.Id,
                                                                clAccount.Id);
        Database.insert(cfaDealerClRelationObj, true);
        
        //Creating My Program
        TestClassHelper.createTestDataForCFAMyProgram(dealerAccount.Id);
    }

    /**
    * @description - Test validateRateCardHeader success scenario
    * @author Sk Minsar | 09-20-2024 
    **/
    @isTest
    public static void testSuccessValidateRateCardHeader(){
        User clUserObj = [SELECT Id,
                                 account.ParentId
                          FROM User
                          WHERE UserName='ross.geller@yopmail.com'
                          LIMIT 1];
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeader = [SELECT Id,
                                                                       Name,
                                                                       Account__c,
                                                                       Account__r.Name,
                                                                       FS_Index_Rate__c,
                                                                       genesis__End_Date__c
                                                                FROM genesis__rate_card_setup_header__c
                                                                WHERE Account__c =: clUserObj.account.ParentId];
        
        Test.startTest();
            System.runAs(clUserObj) {
                GMKSaveRateCardDetailsHandler.validateRateCardHeader(objRateCardHeader);
            }
            List<genesis__Rate_Card_Setup_Header__c> result = [SELECT Id,
                                                                       Name,
                                                                       Account__c,
                                                                       Account__r.Name,
                                                                       FS_Index_Rate__c,
                                                                       genesis__End_Date__c
                                                                FROM genesis__rate_card_setup_header__c
                                                                WHERE Account__c =: clUserObj.account.ParentId];
            System.assertEquals(objRateCardHeader,result,PortalConstants.ASSERTION_FAILED);
        Test.stopTest();
    }

    /**
    * @description - Test validateRateCardHeader exception scenario for my Program Name null
    * @author Sk Minsar | 09-20-2024 
    **/
    @isTest
    public static void testExValidateRateCardHeaderNullName(){
        User clUserObj = [SELECT Id,
                                 account.ParentId
                          FROM User
                          WHERE UserName='ross.geller@yopmail.com'
                          LIMIT 1];

        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeader = [SELECT Id,
                                                                       Name,
                                                                       Account__c,
                                                                       Account__r.Name,
                                                                       FS_Index_Rate__c,
                                                                       genesis__End_Date__c
                                                                FROM genesis__rate_card_setup_header__c
                                                                WHERE Account__c =: clUserObj.account.ParentId];
        objRateCardHeader[0].Name = null;
        Database.update(objRateCardHeader, true);
        
        System.runAs(clUserObj) {
            Test.startTest();
            try{
                GMKSaveRateCardDetailsHandler.validateRateCardHeader(objRateCardHeader);
            }catch(Exception e){
                System.assertEquals(PortalConstants.SOMETHING_WENT_WRONG,e.getMessage(),PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
    /**
    * @description - Test validateRateCardHeader exception scenario FS Inex Rate null
    * @author Sk Minsar | 09-20-2024 
    **/
    @isTest
    public static void testExValidateRateCardHeaderNullFsIndexRate(){
         User clUserObj = [SELECT Id,
                                 account.ParentId
                          FROM User
                          WHERE UserName='ross.geller@yopmail.com'
                          LIMIT 1];

        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeader = [SELECT Id,
                                                                       Name,
                                                                       Account__c,
                                                                       Account__r.Name,
                                                                       FS_Index_Rate__c,
                                                                       genesis__End_Date__c
                                                                FROM genesis__rate_card_setup_header__c
                                                                WHERE Account__c =: clUserObj.account.ParentId];
        objRateCardHeader[0].FS_Index_Rate__c = null;
        Database.update(objRateCardHeader, true);
        
        System.runAs(clUserObj) {
            Test.startTest();
            try{
                GMKSaveRateCardDetailsHandler.validateRateCardHeader(objRateCardHeader);
            }catch(Exception e){
                System.assertEquals(PortalConstants.SOMETHING_WENT_WRONG,e.getMessage(),PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
    /**
    * @description - Test validateRateCardHeader exception scenario Maturity date null
    * @author Sk Minsar | 09-20-2024 
    **/
    @isTest
    public static void testExValidateRateCardHeaderNullMaturityDate(){
         User clUserObj = [SELECT Id,
                                 account.ParentId
                          FROM User
                          WHERE UserName='ross.geller@yopmail.com'
                          LIMIT 1];

        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeader = [SELECT Id,
                                                                       Name,
                                                                       Account__c,
                                                                       Account__r.Name,
                                                                       FS_Index_Rate__c,
                                                                       genesis__End_Date__c
                                                                FROM genesis__rate_card_setup_header__c
                                                                WHERE Account__c =: clUserObj.account.ParentId];
        objRateCardHeader[0].genesis__End_Date__c = null;
        Database.update(objRateCardHeader, true);
        
        System.runAs(clUserObj) {
            Test.startTest();
            try{
                GMKSaveRateCardDetailsHandler.validateRateCardHeader(objRateCardHeader);
            }catch(Exception e){
                System.assertEquals(PortalConstants.SOMETHING_WENT_WRONG,e.getMessage(),PortalConstants.ASSERTION_FAILED);
            }
            Test.stopTest();
        }
    }
    /**
    * @description - Test getSubTranche for Invalid subTrancheName
    * @author Sk Minsar | 09-20-2024 
    **/
    @isTest
    public static void testGetSubTrancheForIvalidSubTrancheName(){
        User clUserObj = [SELECT Id,
                                 account.ParentId
                          FROM User
                          WHERE UserName='ross.geller@yopmail.com'
                          LIMIT 1];
        String specialTermName = 'Test Tranche A';
        
        System.runAs(clUserObj) {
            Test.startTest();
            String result = GMKSaveRateCardDetailsHandler.getSubTranche(specialTermName);
            System.assertEquals(null,result,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description - Test getSubTranche for Blank subTrancheName
    * @author Sk Minsar | 09-20-2024 
    **/
    @isTest
    public static void testGetSubTrancheForBlankSubTrancheName(){
        User clUserObj = [SELECT Id,
                                 account.ParentId
                          FROM User
                          WHERE UserName='ross.geller@yopmail.com'
                          LIMIT 1];
        String specialTermName = '';
        
        System.runAs(clUserObj) {
            Test.startTest();
            String result = GMKSaveRateCardDetailsHandler.getSubTranche(specialTermName);
            System.assertEquals(null,result,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description - * @description - Test getSubTranche for Null subTrancheName
    * @author Sk Minsar | 09-20-2024 
    **/
    @isTest
    public static void testGetSubTrancheForNullSubTrancheName(){
        User clUserObj = [SELECT Id,
                                 account.ParentId
                          FROM User
                          WHERE UserName='ross.geller@yopmail.com'
                          LIMIT 1];
        String specialTermName = null;
        
        System.runAs(clUserObj) {
            Test.startTest();
            String result = GMKSaveRateCardDetailsHandler.getSubTranche(specialTermName);
            System.assertEquals(null,result,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description - Test getSubTranche for Master Note Rate A subTrancheName
    * @author Sk Minsar | 09-20-2024 
    **/
    @isTest
    public static void testGetSubTrancheForASubTrancheName(){
        User clUserObj = [SELECT Id,
                                 account.ParentId
                          FROM User
                          WHERE UserName='ross.geller@yopmail.com'
                          LIMIT 1];
        String specialTermName = PortalConstants.MASTER_NOTERATE_A;
        
        System.runAs(clUserObj) {
            Test.startTest();
            String result = GMKSaveRateCardDetailsHandler.getSubTranche(specialTermName);
            System.assertEquals(PortalConstants.SPECIAL_TERM_A,result,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description - Test getSubTranche for For Special Sub Tranche B subTrancheName
    * @author Sk Minsar | 09-20-2024 
    **/
    @isTest
    public static void testGetSubTrancheForBSubTrancheName(){
        User clUserObj = [SELECT Id,
                                 account.ParentId
                          FROM User
                          WHERE UserName='ross.geller@yopmail.com'
                          LIMIT 1];
        String specialTermName = PortalConstants.SUB_TRANCHE_B;
        
        System.runAs(clUserObj) {
            Test.startTest();
            String result = GMKSaveRateCardDetailsHandler.getSubTranche(specialTermName);
            System.assertEquals(PortalConstants.SPECIAL_TERM_B,result,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description - Test getSubTranche for For Special Sub Tranche C subTrancheName
    * @author Sk Minsar | 09-20-2024 
    **/
    @isTest
    public static void testGetSubTrancheForCSubTrancheName(){
        User clUserObj = [SELECT Id,
                                 account.ParentId
                          FROM User
                          WHERE UserName='ross.geller@yopmail.com'
                          LIMIT 1];
        String specialTermName = PortalConstants.SUB_TRANCHE_C;
        
        System.runAs(clUserObj) {
            Test.startTest();
            String result = GMKSaveRateCardDetailsHandler.getSubTranche(specialTermName);
            System.assertEquals(PortalConstants.SPECIAL_TERM_C,result,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description - Test getSubTranche for For Special Sub Tranche D subTrancheName
    * @author Sk Minsar | 09-20-2024 
    **/
    @isTest
    public static void testGetSubTrancheForDSubTrancheName(){
        User clUserObj = [SELECT Id,
                                 account.ParentId
                          FROM User
                          WHERE UserName='ross.geller@yopmail.com'
                          LIMIT 1];
        String specialTermName = PortalConstants.SUB_TRANCHE_D;
        
        System.runAs(clUserObj) {
            Test.startTest();
            String result = GMKSaveRateCardDetailsHandler.getSubTranche(specialTermName);
            System.assertEquals(PortalConstants.SPECIAL_TERM_D,result,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description - Test getSubTranche for For Special Sub Tranche E subTrancheName
    * @author Sk Minsar | 09-20-2024 
    **/
    @isTest
    public static void testGetSubTrancheForESubTrancheName(){
        User clUserObj = [SELECT Id,
                                 account.ParentId
                          FROM User
                          WHERE UserName='ross.geller@yopmail.com'
                          LIMIT 1];
        String specialTermName = PortalConstants.SUB_TRANCHE_E;
        
        System.runAs(clUserObj) {
            Test.startTest();
            String result = GMKSaveRateCardDetailsHandler.getSubTranche(specialTermName);
            System.assertEquals(PortalConstants.SPECIAL_TERM_E,result,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description - Test getSubTranche for For Special Sub Tranche F subTrancheName
    * @author Sk Minsar | 09-20-2024 
    **/
    @isTest
    public static void testGetSubTrancheForFSubTrancheName(){
         User clUserObj = [SELECT Id,
                                 account.ParentId
                          FROM User
                          WHERE UserName='ross.geller@yopmail.com'
                          LIMIT 1];
        String specialTermName = PortalConstants.SUB_TRANCHE_F;
        
        System.runAs(clUserObj) {
            Test.startTest();
            String result = GMKSaveRateCardDetailsHandler.getSubTranche(specialTermName);
            System.assertEquals(PortalConstants.SPECIAL_TERM_F,result,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description - Test getSubTranche for For Special Sub Tranche G subTrancheName
    * @author Sk Minsar | 09-20-2024 
    **/
    @isTest
    public static void testGetSubTrancheForGSubTrancheName(){
         User clUserObj = [SELECT Id,
                                 account.ParentId
                          FROM User
                          WHERE UserName='ross.geller@yopmail.com'
                          LIMIT 1];
        String specialTermName = PortalConstants.SUB_TRANCHE_G;
        
        System.runAs(clUserObj) {
            Test.startTest();
            String result = GMKSaveRateCardDetailsHandler.getSubTranche(specialTermName);
            System.assertEquals(PortalConstants.SPECIAL_TERM_G,result,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description - Test getSubTranche for For Special Sub Tranche H subTrancheName
    * @author Sk Minsar | 09-20-2024 
    **/
    @isTest
    public static void testGetSubTrancheForHSubTrancheName(){
         User clUserObj = [SELECT Id,
                                 account.ParentId
                          FROM User
                          WHERE UserName='ross.geller@yopmail.com'
                          LIMIT 1];
        String specialTermName = PortalConstants.SUB_TRANCHE_H;
        
        System.runAs(clUserObj) {
            Test.startTest();
            String result = GMKSaveRateCardDetailsHandler.getSubTranche(specialTermName);
            System.assertEquals(PortalConstants.SPECIAL_TERM_H,result,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
}