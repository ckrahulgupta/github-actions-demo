/**
 * @description       : Queueable Class for ACH Import.
 * @author            : Simran
 * @group             : 
 * @last modified on  : 12-23-2024
 * @last modified by  : Sk Minsar
**/

public without sharing class PortalImportACHQueueableClass implements Queueable, Database.AllowsCallouts {

    String[] csvRecordData;
    List<String> csvLoan= new List<String>();
    List<String> csvAmount= new List<String>();
    List<String> csvReference= new List<String>();
    Map<String,List<String>> csvLoanAmount = new Map<String,List<String>>();
    List<List<String>> allCSVFileLinesList = new List<List<String>>();
    List<String> uniqueLoan=new List<String>();
    Map<String,Map<String, String>> loanDetailsMap = new  Map<String,Map<String, String>>();
    Map<String, String> loanInvoiceMap = new Map<String, String>();
    clcommon__Payment_Mode__c paymentMode = new clcommon__Payment_Mode__c();
    List<String> csvFileLines=new List<String>();

    /**
    * @description - Constructor for PortalImportACHQueueableClass
    * @author Sk Minsar | 12-09-2024 
    * @param inputAllCSVFileLinesList 
    * @param achParamMap 
    **/
    public PortalImportACHQueueableClass(List<List<String>> inputAllCSVFileLinesList, Map<String, Object> achParamMap) {
        allCSVFileLinesList = inputAllCSVFileLinesList;
        paymentMode= (clcommon__Payment_Mode__c)achParamMap.get(PortalConstants.KEY_PAYMENT_MODE);
        uniqueLoan = new List<String>((Set<String>)achParamMap.get(PortalConstants.KEY_UNIQUE_LOAN_SET));
        loanDetailsMap = (Map<String,Map<String,String>>)achParamMap.get(PortalConstants.KEY_LOAN_DETAILS_MAP);
    }
    /**
    * @description 
    * @author Sk Minsar | 11-29-2023 
    * @param context 
    **/
    public void execute(QueueableContext context){
    try{
        Map<String, genesis__Application_Pricing_Detail__c> objPricingDetailsMap = new Map<String, genesis__Application_Pricing_Detail__c>();
        List<genesis__Application_Pricing_Detail__c> objPricingDetailsList = [SELECT Id, 
                                                                                Loan_Number__c,
                                                                                genesis__Application__c,
                                                                                genesis__Application__r.Available__c ,
                                                                                genesis__Application__r.Reserved_Amount__c,
                                                                                genesis__Application__r.genesis__Loan_Amount__c,
                                                                                genesis__Application__r.genesis__Maturity_Date__c,
                                                                                genesis__Application__r.Peak_Loan_Volume__c,
                                                                                genesis__Application__r.genesis__Contact__r.Name,
                                                                                genesis__Application__r.genesis__Account__r.Name,
                                                                                Principal_Advanced__c
                                                                            FROM genesis__Application_Pricing_Detail__c
                                                                            WHERE Loan_Number__c In : uniqueLoan
                                                                            AND genesis__Application__r.genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                                                                            AND Loan_Id__c != null
                                                                            AND genesis__Enabled_Flag__c =: PortalConstants.TRUE_VALUE
                                                                            AND genesis__Application__r.Dealer_Name__c = :LoanServicingHelper.getLoggedInUserDealerId()];
        LoanServicingHelper.checkEmptyList(objPricingDetailsList, PortalConstants.INVALID_LOAN_NUMBER_ERROR);
        for (genesis__Application_Pricing_Detail__c detail : objPricingDetailsList) {
            objPricingDetailsMap.put(String.valueOf(detail.Loan_Number__c), detail);
        }
        loanInvoiceMap = PaymentInvoiceHelper.createInvoiceForImportedCSV(String.valueOf(paymentMode.Id), loanDetailsMap);
        Map<Id,genesis__Applications__c> objApplicationMap = new Map<Id,genesis__Applications__c>();
        List<genesis__Funding_Transaction__c> objFundingTransactionList = new List<genesis__Funding_Transaction__c>();
        for(List<String> rowList : allCSVFileLinesList) {  
            genesis__Funding_Transaction__c objFundingTransaction = new genesis__Funding_Transaction__c();
            genesis__Applications__c objApplications = new genesis__Applications__c();    
            Decimal amount = Decimal.valueOf(String.valueOf(rowList[2]).replace('\r', ''));
            if(objApplicationMap.containsKey(objPricingDetailsMap.get(rowList[0]).genesis__Application__c)){
                genesis__Applications__c oldApplication = objApplicationMap.get(objPricingDetailsMap.get(rowList[0]).genesis__Application__c);
                if((objPricingDetailsMap.get(rowList[0]).genesis__Application__r.genesis__Loan_Amount__c 
                            - oldApplication.Peak_Loan_Volume__c 
                            - objPricingDetailsMap.get(rowList[0]).genesis__Application__r.Reserved_Amount__c) > amount ){
                            oldApplication.Peak_Loan_Volume__c = oldApplication.Peak_Loan_Volume__c + amount;
                            objApplicationMap.put(oldApplication.Id,oldApplication);
                    }
                }
                else{
                    objApplications.Id = objPricingDetailsMap.get(rowList[0]).genesis__Application__c;
                    objApplications.Peak_Loan_Volume__c = objPricingDetailsMap.get(rowList[0]).genesis__Application__r.Peak_Loan_Volume__c + amount;
                    objApplicationMap.put(objApplications.Id,objApplications);
                }
                objFundingTransaction.genesis__Amount__c = amount;
                objFundingTransaction.genesis__Reference__c = String.valueOf(rowList[1]).replace('\r', '');
                objFundingTransaction.genesis__Application__c = objPricingDetailsMap.get(rowList[0]).genesis__Application__c;
                objFundingTransaction.genesis__Payment_Mode__c = paymentMode.Id;
                objFundingTransaction.genesis__Funding_Date__c = date.today();
                objFundingTransaction.Grower_Name__c = objPricingDetailsMap.get(rowList[0]).genesis__Application__r.genesis__Account__r.Name;
                objFundingTransaction.Pricing_Detail__c = objPricingDetailsMap.get(rowList[0]).Id;
                objFundingTransaction.invoice__c = loanInvoiceMap.get(LoanServicingHelper.getParentLoanNumberMap(rowList[0]));
                objFundingTransactionList.add(objFundingTransaction);
                //Update the Principal Advanced for the child loans
                objPricingDetailsMap.get(rowList[0]).Principal_Advanced__c = objPricingDetailsMap.get(rowList[0]).Principal_Advanced__c + amount;
        }
        Database.Insert(objFundingTransactionList,PortalConstants.TRUE_VALUE);
        Database.Update(objApplicationMap.values(),PortalConstants.TRUE_VALUE);
        Database.update(objPricingDetailsMap.values(),PortalConstants.TRUE_VALUE);
        }
        catch (CustomException objCustomException) {
            PortalHelper.saveExceptionLog(objCustomException, PortalImportACHQueueableClass.class.getName());
        } 
        catch (LimitException objLimitException) {
            PortalHelper.saveExceptionLog(objLimitException, PortalImportACHQueueableClass.class.getName());
        } 
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, PortalImportACHQueueableClass.class.getName());
        }
    }
}