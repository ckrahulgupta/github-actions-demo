/**********************************************************************************************
 * @className         : TestExternalAPIApplication
 * @description       : Test Class for ExternalAPIApplication
 * @author            : simranjha
 * @created Date      : 01-03-2022
 * @last modified on  : 15-01-2025
 * @last modified by  : Soumik Pattanayak
 * @deprecated
 **********************************************************************************************/

@IsTest
public class TestExternalAPIApplication {
    @isTest
    public static void TestExternalAPIApplication() {
        
        //Creating data for Application
        genesis__Applications__c objApplication = new genesis__Applications__c();
        objApplication.genesis__Loan_Amount__c = 35000.00;
        objApplication.Crop_Year__c = '2008';
        Database.Insert(objApplication);
       
        List<String> ids = new List<String>();
        ids.add(objApplication.Id);
        ExternalAPIApplication.applicationRecord(ids);
        System.assertEquals(objApplication.genesis__Loan_Amount__c, 35000.00);

    }
    @isTest
    public static void TestExternalAPIApplication1() {
        List<String> ids = new List<String>();
        ExternalAPIApplication.applicationRecord(ids);
    }
}