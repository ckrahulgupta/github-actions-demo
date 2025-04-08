/**
 * @description       : API to generate unique token for Landus-Conduit Dealer 
 * @author            : Suraj Kumar | 09-19-2024
 * @group             : 
 * @last modified on  : 09-19-2024
 * @last modified by  : Suraj Kumar
**/
public with sharing class AccountTokenGeneratorAPI {
    private static final String CLASS_NAME = AccountTokenGeneratorAPI.class.getName();
    /**
    * @description : Method to generate unique token for Landus-Conduit Dealer and stores on Unique Id field.
    * @author Suraj Kumar | 09-19-2024 
    * @param accountId 
    **/
    @invocableMethod(label = 'GenerateToken')
    public static void generateUniqueToken(List<String> accountId){
        SavePoint dbSavePoint = Database.setSavepoint();
        try{
            if(Schema.sObjectType.Account.isAccessible()){
                List<Account> dealerAccountList = [SELECT Id, 
                                                            CIF_Number__c, 
                                                            Unique_Id__c 
                                                        FROM Account 
                                                        WHERE Id = :accountId[0]];
                UUID randomUuid = UUID.randomUUID();
                String uniqueToken = dealerAccountList[0].CIF_Number__c + randomUuid.toString().substring(0,18);
                dealerAccountList[0].Unique_Id__c = uniqueToken;
                Database.update(dealerAccountList[0],true);
            }
        }
        catch (Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            ExternalExceptionUtil.saveExceptionLog(exceptionObj, CLASS_NAME);
        }
    }
}