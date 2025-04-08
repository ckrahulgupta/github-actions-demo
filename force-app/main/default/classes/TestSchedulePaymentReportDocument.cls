/**
 * @description       : Test Class to cover Schedule Payment Clear and report generation
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 12-21-2024
 * @last modified by  : Sk Minsar
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   17-06-2022   Subham Nandi   Initial Version
**/
@isTest(seeAllData = true)
public with sharing class TestSchedulePaymentReportDocument {
    
     /**
    * @description - Returns the Admin User
    * @author Sk Minsar | 12-18-2024 
    * @return User 
    **/
    private static User getAdminUser(){
        return [
            SELECT Id 
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ][0];
    }

    /**
    * @description - Test TestSchedulePaymentReportDocument
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    public static void testPaymentReportDocument(){
        genesis__Applications__c objApplication = TestClassHelper.createApplication();
        genesis__Application_Pricing_Detail__c newPricingDetails = TestClassHelper.createPricingDetail(objApplication.Id);
        genesis__Funding_Transaction__c achFundingTransaction = TestClassHelper.createFundingTransaction('PAYMENT');
        achFundingTransaction.Pricing_Detail__c = newPricingDetails.Id;
        achFundingTransaction.genesis__Cleared__c = false;
        Database.update(achFundingTransaction,false);
        String jobId = null;
        System.runAs(getAdminUser()){
            Test.startTest();
            jobId = System.schedule('TestSchedulePaymentReportDocument Job','0 55 * * * ? *', new SchedulePaymentReportDocument());
            Test.stopTest();
        }
        system.assertEquals(jobID != null, true,'Failed to Schedule job for clearing payments');
    }

    /**
    * @description - Test TestSchedulePaymentReportDocument
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    public static void testPaymentReportDocumentWithoutData(){
        String jobId = null;
        System.runAs(getAdminUser()){
            Test.startTest();
            jobId = System.schedule('TestSchedulePaymentReportDocument Job','0 55 * * * ? *', new SchedulePaymentReportDocument());
            Test.stopTest();
        }
        system.assertEquals(jobID != null, true,'Failed to Schedule job for clearing payments');
    }

    /**
    * @description - Test Create Document 
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    public static void testCreateDocument(){
        Boolean isExceptionThrown = false;
        System.runAs(getAdminUser()){
            Test.startTest();
            try {
                GeneratePaymentReportDocument.createDocument(null, null);
            }catch (Exception e){
                isExceptionThrown = true;
            }
            Test.stopTest();
        }
        System.assertEquals(isExceptionThrown, false, PortalConstants.ASSERTION_FAILED);

    }
}