/**********************************************************************************************************************
 * @description       : This class create funding transaction record for bulk ACH present in a csv file.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 12-23-2024
 * @last modified by  : Sk Minsar
**********************************************************************************************************************/
global without sharing class PortalImportACHDataFromCSVAPI implements clcommon.PortalCustomRemoteAPI1 {

    /**
    * @description - Purpose of this method is to parse a CSV file and store all the requested ACH in salesforce.
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames, 
                                                Map<String, Object> argumentsFromPortal) {
        List<String> csvFileLinesList = new List<String>();
        Map<String,List<String>> csvLoanAmountMap = new Map<String,List<String>>();
        List<List<String>> allCSVFileLinesList = new List<List<String>>();
        Map<String,String> parentLoanNumberMap = new Map<String,String>();
        clcommon.Response response = new clcommon.Response();
        clcommon__Payment_Mode__c objPaymentMode = new clcommon__Payment_Mode__c();
        Set<String> uniqueLoanSet=new Set<String>();
        Map<String,Map<String,String>> loanDetailsMap = new Map<String,Map<String,String>>();
        Map<String, Object> filteredCSVDataMap = new Map<String, Object>();
        List<String> csvLoanList = new List<String>();
        SavePoint dbSavePoint = Database.setSavePoint();
        try{
            objPaymentMode = [SELECT Id, 
                                     Name 
                              FROM clcommon__Payment_Mode__c
                              WHERE Name =: PortalConstants.KEY_ACH 
                              LIMIT 1];
            csvFileLinesList = LoanServicingHelper.getcsvFileLinesList(argumentsFromPortal);
            LoanServicingHelper.validateCSVFormat(csvFileLinesList);
            
            filteredCSVDataMap = LoanServicingHelper.getFilteredCSVDataMap(csvFileLinesList);
            csvLoanAmountMap = (Map<String,List<String>>)filteredCSVDataMap.get(PortalConstants.KEY_CSV_LOAN_AMOUNT_MAP);
            allCSVFileLinesList = (List<List<String>>)filteredCSVDataMap.get(PortalConstants.KEY_ALL_CSV_FILE_LINES_LIST);
            parentLoanNumberMap = (Map<String,String>)filteredCSVDataMap.get(PortalConstants.KEY_PARENT_LOAN_NUMBER_MAP);
            uniqueLoanSet = (Set<String>)filteredCSVDataMap.get(PortalConstants.KEY_UNIQUE_LOAN_SET);
            loanDetailsMap = (Map<String,Map<String,String>>)filteredCSVDataMap.get(PortalConstants.KEY_LOAN_DETAILS_MAP);
            csvLoanList = (List<String>)filteredCSVDataMap.get(PortalConstants.KEY_CSV_LOAN_LIST);

            if(allCSVFileLinesList.size()>100){
                    throw new  CustomException(PortalConstants.ACH_LIMIT_EX);
            }
            LoanServicingHelper.isValidLoanNumber(csvLoanList);
            List<String> csvLoanNumberList = new List<String>((Set<String>)(csvLoanAmountMap.keySet()));
            List<genesis__Application_Pricing_Detail__c> objPricingDetailsList = [SELECT Id,
                                                                                    genesis__Application__c,
                                                                                    Loan_Number__c,
                                                                                    genesis__Application__r.Available__c ,
                                                                                    genesis__Application__r.Reserved_Amount__c,
                                                                                    genesis__Application__r.genesis__Loan_Amount__c,
                                                                                    genesis__Application__r.genesis__Maturity_Date__c,
                                                                                    genesis__Application__r.Peak_Loan_Volume__c,
                                                                                    genesis__Application__r.genesis__Contact__r.Name,
                                                                                    genesis__Application__r.Id,
                                                                                    Principal_Advanced__c
                                                                            FROM genesis__Application_Pricing_Detail__c
                                                                            WHERE Loan_Number__c In : csvLoanNumberList
                                                                            AND genesis__Enabled_Flag__c =: PortalConstants.TRUE_VALUE
                                                                            AND genesis__Application__r.genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                                                                            AND Loan_Id__c != null
                                                                            AND genesis__Application__r.Dealer_Name__c = :LoanServicingHelper.getLoggedInUserDealerId()];


            loanDetailsMap = LoanServicingHelper.validateLoanDetails(new Map<String, Object>{
                    PortalConstants.KEY_OBJ_PRICING_DETAILS_LIST => objPricingDetailsList,
                    PortalConstants.KEY_LOAN_DETAILS_MAP => loanDetailsMap,
                    PortalConstants.KEY_CSV_LOAN_AMOUNT_MAP => csvLoanAmountMap,
                    PortalConstants.KEY_PARENT_LOAN_NUMBER_MAP => parentLoanNumberMap
            });
            
            System.enqueueJob(new PortalImportACHQueueableClass(allCSVFileLinesList, new Map<String, Object> {
                PortalConstants.KEY_LOAN_DETAILS_MAP => loanDetailsMap,
                PortalConstants.KEY_PAYMENT_MODE => objPaymentMode,
                PortalConstants.KEY_UNIQUE_LOAN_SET => uniqueLoanSet
               }));
            response.status = clcommon.Constants.SUCCESS; 
        } 
        catch (CustomException customException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customException.getMessage();
            PortalHelper.saveExceptionLog(customException, PortalImportACHDataFromCSVAPI.class.getName());
        } 
        catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION; 
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, PortalImportACHDataFromCSVAPI.class.getName());
        }
        return response;
    }
}