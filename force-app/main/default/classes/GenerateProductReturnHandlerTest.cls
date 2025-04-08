/**
 * @description       : Generate Product Return Initiated Document Test Class
 * @author            : Pritam
 * @group             : 
 * @last modified on  : 03-17-2024
 * @last modified by  :  Pritam Roy
**/
@isTest
private class GenerateProductReturnHandlerTest {
    //Create Product Return Document
    @isTest(seeAllData=true)
    public static void createProductReturnDocument(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        String reportName = ConstantValues.PRODUCT_RETURN_INITIATED;
        String folderName = ConstantValues.PRODUCT_RETURN_REPORTS;
        String folderType = 'Document';
        String reportId = 'reportID';
        String folderId = 'folderID';
        Map<String,Id> typeVsIdMap = new Map<String,Id>();
        clcommon__Payment_Mode__c objPaymentMode = new clcommon__Payment_Mode__c(Name = 'PRODUCT RETURN');
        Database.insert(objPaymentMode, true);

        genesis__Funding_Transaction__c objProductTransaction = TestClassHelper.createFundingTransaction(objPaymentMode);
        objProductTransaction.genesis__Cleared__c = false;
        objProductTransaction.Posted_to_NLS__c = false;
        Database.insert(objProductTransaction, true);

        List<Report> reportList =  [SELECT  Id,
                                                Name 
                                        FROM Report 
                                        WHERE Name = :reportName
                                        LIMIT 1];
                
        List<Folder> folderList =   [SELECT Id,
                                            Name 
                                    FROM Folder 
                                    WHERE Name = :folderName
                                    AND Type =: folderType
                                    LIMIT 1];

        typeVsIdMap.put(reportId,(Id) String.valueOf(reportList[0].Id));
        typeVsIdMap.put(folderId,(Id) String.valueOf(folderList[0].Id));
        
        //Generate Product Return Posted Document and send it to Loan Accounting
        System.runAs(objAdmin){
            Test.startTest();
            GenerateProductReturnHandler.createProductReturnDocument(typeVsIdMap,true,'Test Subject');
            Test.stopTest();
        }
        Document objDocument = [SELECT Id FROM Document WHERE Name LIKE 'Loan Accounting Product Return%' LIMIT 1];
        System.assertEquals(objDocument != null,true,'No Document Generated');
    }
}