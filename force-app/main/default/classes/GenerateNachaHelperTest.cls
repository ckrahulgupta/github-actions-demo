/**
 * @description       : Generate Nacha File Test Class
 * @author            : Pritam
 * @group             : 
 * @last modified on  : 11-10-2023
 * @last modified by  : Pritam
**/
@isTest
private class GenerateNachaHelperTest {
    @TestSetup
    static void makeData(){
        //Create Payment Mode
        clcommon__Payment_Mode__c objPaymentMode = new clcommon__Payment_Mode__c(Name = 'PRODUCT RETURN');
        Database.insert(objPaymentMode, true);

        //Create Funding Transaction
        genesis__Funding_Transaction__c objProductTransaction = TestClassHelper.createFundingTransaction(objPaymentMode);
        Database.insert(objProductTransaction, true);
    }
    //create Nacha String
    @isTest
    public static void createNacha(){
        User objAdmin = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Funding_Transaction__c objTransaction = [SELECT Id FROM genesis__Funding_Transaction__c LIMIT 1];
        objTransaction.genesis__Cleared__c = true;
        objTransaction.Posted_to_NLS__c = false;
        Database.update(objTransaction, true);
        String csvHeader = 'Dealer Routing Number,Dealer Account Number,Dealer Bank Account Name,Dealer Bank Account Type,Dealer Name,Dealer CIF,Total Amount \n';
        Map<String,String> nachaArgumentsMap = new Map<String,String>();
        //Query All the Funding transasction that are Not Cleared and are Not posted yet
        List<AggregateResult> nachaPayments = [ SELECT  genesis__Bank_Account__r.clcommon__Routing_Number__c RoutingNumber, 
                                                        genesis__Bank_Account__r.clcommon__Bank_Name__c BankName, 
                                                        genesis__Bank_Account__r.clcommon__Account_Type__c AccountType,
                                                        genesis__Application__r.Dealer_Name__r.Name  DealerName, 
                                                        genesis__Application__r.Dealer_Name__r.CIF_Number__c CIFNumber, 
                                                        genesis__Bank_Account__c bankId,
                                                        SUM(genesis__Amount__c) Amount 
                                                FROM genesis__Funding_Transaction__c 
                                                WHERE genesis__Payment_Mode__r.Name =: ConstantValues.PRODUCT_RETURN AND 
                                                genesis__Cleared__c = true AND 
                                                Posted_to_NLS__c = false 
                                                GROUP BY genesis__Bank_Account__r.clcommon__Routing_Number__c, 
                                                        genesis__Application__r.Dealer_Name__r.Name, 
                                                        genesis__Bank_Account__r.clcommon__Account_Type__c, 
                                                        genesis__Bank_Account__r.clcommon__Bank_Name__c, 
                                                        genesis__Application__r.Dealer_Name__r.CIF_Number__c,
                                                        genesis__Bank_Account__c];
        nachaArgumentsMap.put('FIRST_COLUMN','RoutingNumber');
        nachaArgumentsMap.put('SECOND_COLUMN','bankId');
        nachaArgumentsMap.put('THIRD_COLUMN','BankName');
        nachaArgumentsMap.put('FOURTH_COLUMN','AccountType');
        nachaArgumentsMap.put('FIFTH_COLUMN','DealerName');
        nachaArgumentsMap.put('SIXTH_COLUMN','CIFNumber');
        nachaArgumentsMap.put('SEVENTH_COLUMN','Amount');
        nachaArgumentsMap.put('CSV_HEADER',csvHeader);
        System.runAs(objAdmin){
            Test.startTest();
            String finalString = GenerateNachaHelper.getNacha(nachaPayments,nachaArgumentsMap);
            Test.stopTest();
            System.assertEquals(finalString != null,true,'Final String was Null');
        }
        
    }
}