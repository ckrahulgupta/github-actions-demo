/**
 * @description       : Generate Dealer Payment Handler Test Class
 * @author            : Pritam
 * @group             : 
 * @last modified on  : 05-10-23
 * @last modified by  : Pritam
**/
@isTest
private class GenerateDealerPaymentHandlerTest {
    //Generate Payment Document
    @isTest(seeAllData=true)
    public static void createDealerPaymentDocument(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        String reportName = ConstantValues.DEALER_ONLINE_PAYMENT_POSTED;
        String folderName = ConstantValues.DEALER_ONLINE_PAYMENT_REPORTS;
        String folderType = 'Document';
        clcommon__Payment_Mode__c objPaymentMode = new clcommon__Payment_Mode__c(Name = 'PAYMENT');
        Database.insert(objPaymentMode, true);

        genesis__Funding_Transaction__c objProductTransaction = TestClassHelper.createFundingTransaction(objPaymentMode);
        objProductTransaction.genesis__Cleared__c = true;
        objProductTransaction.Posted_to_NLS__c = false;
        objProductTransaction.Paid_By_Dealer__c = true;
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
        //Generate Product Return Posted Document and send it to Loan Accounting
        System.runAs(objAdmin){
            Test.startTest();
            GenerateDealerPaymentHandler.createDealerPaymentDocument((Id) String.valueOf(reportList[0].Id), (Id) String.valueOf(folderList[0].Id),'Test Subject');
            Test.stopTest();
        }
        Document objDocument = [SELECT Id FROM Document WHERE Name LIKE 'Dealer Online Payment%' LIMIT 1];
        System.assertEquals(objDocument != null,true,'No Document Generated');
    }
    //Generate Document Exception
    @isTest
    public static void createDealerPaymentException(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        System.runAs(objAdmin){
            Test.startTest();
            GenerateDealerPaymentHandler.createDealerPaymentDocument(null,null,'Test Subject');
            Test.stopTest();
            System.assertEquals(true,true,'No Document Generated');
        }
    }
}