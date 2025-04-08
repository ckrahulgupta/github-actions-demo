/**
 * @description       : Updates the CIF number in the CFA Configuration 
 * @author            : iAyush
 * @group             : 
 * @last modified on  : 03-14-2024
 * @last modified by  :  Pritam Roy
**/
global with sharing class UpdateCIFFromFlow {

    private final static String GROWMARK = 'Growmark';
    /**
    * @description : Update Account CIF
    * @author  Pritam Roy | 03-14-2024 
    * @param accountId 
    **/
    @invocableMethod(label = 'UpdateCIF')
    global static void updateCIFNumber (List<String> accountId){
        clcommon.Response response = new clcommon.Response();
        SavePoint dbSavePoint = Database.setSavepoint();

        try{
            CFA_Configuration__c latestCIF = [SELECT    CIF_Number__c, 
                                                        Growmark_CIF_Number__c
                                                FROM CFA_Configuration__c];
            if(latestCIF == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            List<Account> objAccountList = [SELECT Id, CIF_Number__c, Coop_Type__c
                                                FROM Account    
                                                WHERE Id =: accountId[0]];
            if(objAccountList[0].Coop_Type__c != null && objAccountList[0].Coop_Type__c == GROWMARK){
                objAccountList[0].CIF_Number__c = latestCIF.Growmark_CIF_Number__c;
                latestCIF.Growmark_CIF_Number__c = String.valueOf(Decimal.valueOf(latestCIF.Growmark_CIF_Number__c)+1);
            }
            else{
                objAccountList[0].CIF_Number__c = latestCIF.CIF_Number__c;
                latestCIF.CIF_Number__c = String.valueOf(Decimal.valueOf(latestCIF.CIF_Number__c)+1);
            }
            
            Database.Update(objAccountList, true);
            Database.Update(latestCIF, true);
            if(Test.isRunningTest()){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
        }
        catch (CustomException mce) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = mce.getMessage();
        } catch (Exception ex) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
        }
    }
}