/**
 * @description       : Purpose of this class is to test ApprovalOfMyProgramFromVF
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 09-17-2024
 * @last modified by  : Sk Minsar
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   25-05-2022   Subham Nandi   Initial Version
**/
@isTest
private class TestApprovalOfMyProgramFromVF {
    
    @TestSetup
    static void makeData(){
        //Creating Product
        clcommon__CL_Product__c objProduct = LoanServicingTestHelper.createLoanProduct();
        Database.insert(objProduct, true);

        //Creating Business Information
        genesis__Business_Information__c businessInfoDealer = LoanServicingTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoDealer, true);

        //Creating the dealer parent account
        Account dealerCompany = LoanServicingTestHelper.createDealerAccount(businessInfoDealer.Id);
        Database.insert(dealerCompany, true);

        //Creating the CL Account
        Account dealerUserAccount = LoanServicingTestHelper.createCLAccount(businessInfoDealer.Id,dealerCompany.id);
        Database.insert(dealerUserAccount,true);

        //Creating the CL Contact
        Contact dealerContact = LoanServicingTestHelper.createCLContact(dealerUserAccount.Id);
        Database.insert(dealerContact,true);
        
        //Creating a test user
        User testUser = LoanServicingTestHelper.createCLUser(dealerContact.Id);
        Database.insert(testUser,true);
        
        //Creating Rate Card Setup Header
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerCompany);
        Database.insert(objRateCardHeader,true);

        //Creating Product Rate Card Association
        genesis__Product_Rate_Card_Association__c rateProduct = ApplicationOriginationTestHelper.createRateToProductAssociation(objProduct,objRateCardHeader);
        Database.insert(rateProduct, true);

        //Additional Determing Factor for Program
        genesis__Additional_Determining_Factor__c additionalFactor = ApplicationOriginationTestHelper.createAdditionalFactorForProgram(objRateCardHeader);
        Database.insert(additionalFactor, true);

        //Additional Factor for Dealer
        genesis__Additional_Determining_Factor__c additionalFactorDealer = ApplicationOriginationTestHelper.createAdditionalFactorForDealer(objRateCardHeader);
        Database.insert(additionalFactorDealer, true);

        //Creating Rate Card Setup Detail
        genesis__Rate_Card_Setup_Detail__c objRateCardDetail = ApplicationOriginationTestHelper.createNewRateCardSetupDetail(objRateCardHeader);
        Database.insert(objRateCardDetail, true);

    }
    
    /**
    * @description - Test Approve My Program from VF page
    **/
    @isTest 
    static void testApproveMyProgram(){
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];
        Test.startTest();
        genesis__Rate_Card_Setup_Header__c objMyProgram = [SELECT Id, 
                                                                    Name, 
                                                                    Account__c, 
                                                                    CFA_Advantage_Rate__c, 
                                                                    genesis__Description__c, 
                                                                    Crop_Year__c,
                                                                    genesis__Enabled_Flag__c, 
                                                                    Closing_Fee__c , 
                                                                    genesis__End_Date__c,
                                                                    Payer_of_Loan_Closing_Fee__c,
                                                                    Loan_Fee_Advanced_On__c,
                                                                    Dealer_Participate_on_Closing_Fee__c,
                                                                    Portion_of_Fee_to_Cover__c
                                                                FROM genesis__Rate_Card_Setup_Header__c
                                                                WHERE Name = 'My Test Program 99'];
        System.runAs(adminUserObj){
            ApexPages.StandardController sc = new ApexPages.StandardController(objMyProgram);
        
            ApprovalOfMyProgramFromVF approvalVFClass = new ApprovalOfMyProgramFromVF(sc);
            Pagereference approvalVFPage = page.ApproveMyProgramVF;
            test.setCurrentPage(approvalVFPage);
            approvalVFClass.approve();
            System.assertEquals(true,objMyProgram.genesis__Enabled_Flag__c,'invalid arguments');
        }
        Test.stopTest();
    }

    /**
    * @description - Test Approve My Program Exception
    **/
    @isTest 
    static void testApproveMyProgramException(){
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];
        Test.startTest();
        genesis__Rate_Card_Setup_Header__c objMyProgram = new genesis__Rate_Card_Setup_Header__c();
        System.runAs(adminUserObj){
            ApexPages.StandardController sc = new ApexPages.StandardController(objMyProgram);
        
            ApprovalOfMyProgramFromVF approvalVFClass = new ApprovalOfMyProgramFromVF(sc);
            Pagereference approvalVFPage = page.ApproveMyProgramVF;
            test.setCurrentPage(approvalVFPage);
            approvalVFClass.approve();
            System.assertEquals(false,objMyProgram.genesis__Enabled_Flag__c,'invalid arguments');
        }
        Test.stopTest();
    }

    /**
    * @description - Reject a My Program
    **/
    @isTest 
    static void testRejectMyProgram(){
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];
        Test.startTest();
        genesis__Rate_Card_Setup_Header__c objMyProgram = [SELECT Id, 
                                                                    Name, 
                                                                    Account__c, 
                                                                    CFA_Advantage_Rate__c, 
                                                                    genesis__Description__c, 
                                                                    Crop_Year__c, 
                                                                    genesis__Enabled_Flag__c, 
                                                                    Closing_Fee__c , 
                                                                    genesis__End_Date__c,
                                                                    Payer_of_Loan_Closing_Fee__c,
                                                                    Loan_Fee_Advanced_On__c,
                                                                    Dealer_Participate_on_Closing_Fee__c,
                                                                    Portion_of_Fee_to_Cover__c
                                                                FROM genesis__Rate_Card_Setup_Header__c 
                                                                WHERE Name = 'My Test Program 99'];
        ApexPages.StandardController sc = new ApexPages.StandardController(objMyProgram);
        System.runAs(adminUserObj){
            ApprovalOfMyProgramFromVF approvalVFClass = new ApprovalOfMyProgramFromVF(sc);
            Pagereference approvalVFPage = page.RejectMYProgramVF;
            test.setCurrentPage(approvalVFPage);
            approvalVFClass.reject();
            System.assertEquals(true,objMyProgram.genesis__Enabled_Flag__c,'invalid arguments');
        }
        Test.stopTest();
    }

    /**
    * @description - Reject a My Program
    **/
    @isTest 
    static void testRejectMyProgramException(){
        User adminUserObj = [SELECT Id 
                                FROM User 
                                WHERE Profile.Name = 'System Administrator' 
                                AND IsActive = true 
                                LIMIT 1];
        Test.startTest();
        genesis__Rate_Card_Setup_Header__c objMyProgram = new genesis__Rate_Card_Setup_Header__c();
        ApexPages.StandardController sc = new ApexPages.StandardController(objMyProgram);
        System.runAs(adminUserObj){
            ApprovalOfMyProgramFromVF approvalVFClass = new ApprovalOfMyProgramFromVF(sc);
            Pagereference approvalVFPage = page.RejectMYProgramVF;
            test.setCurrentPage(approvalVFPage);
            approvalVFClass.reject();
            System.assertEquals(false,objMyProgram.genesis__Enabled_Flag__c,'invalid arguments');
        }
        Test.stopTest();
    }

}