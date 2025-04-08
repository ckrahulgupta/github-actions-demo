/**
 * @description       : This class is used to upate the invoice total amount, total principal, total interest, total fees that updated on the transactions with backend
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 12-24-2024
 * @last modified by  : Sk Minsar
**/
global with sharing class UpdateInvoiceDynamicJob extends clcommon.DynamicJob {

    /**
    * @description - Default Constructor
    * @author Sk Minsar | 12-16-2024 
    **/
    global UpdateInvoiceDynamicJob() {
        super();
    }

    /**
    * @description - Parameterized constructor to get the query that has been passed from salesforce DAG Schedule
    * @author Sk Minsar | 12-16-2024 
    * @param name 
    * @param query 
    **/
    global UpdateInvoiceDynamicJob(String name, String query) {
        super(name, query);
    }

    /**
    * @description - overriding the doInitialize method of the dynamic job class
    * @author Sk Minsar | 12-16-2024 
    **/
    public override void doInitialize(){
        return ;
    }

    /**
    * @description - returns the query of Invoice recoreds which we need to validate the values
    * @author Sk Minsar | 12-16-2024 
    * @return String 
    **/
    public override String getRuntimeQuery(){
        return 'select id, name, Total_Amount__c, Total_Principal__c, Total_Interest__c, Total_Fees__c, Payment_Mode__c, Payment_Mode__r.Name, CreatedDate from clcommon__Consolidated_Invoice__c WHERE CreatedDate  = LAST_N_DAYS:1';
    }

    /**
    * @description - doStart method of the DAG framework is blank
    * @author Sk Minsar | 12-16-2024 
    * @param bc 
    **/
    public override void doStart(Database.BatchableContext bc) {
        return ;
    }

    /**
    * @description - the doExecute method of DAG framework which calculate the corresponding funding transaction's total values with invoice total values
    * @author Sk Minsar | 12-16-2024 
    * @param bc 
    * @param objlist 
    **/
    public override void doExecute(Database.BatchableContext bc, List<sObject> objlist) {
        try {
            PaymentInvoiceHelper.updateInvoiceTotalAmounts(objlist);
            
        } catch (Exception objException) {
            LoanServicingHelper.saveExceptionLog(objException, UpdateInvoiceDynamicJob.class.getName());
        }
    }

    /**
    * @description - doFinish method of the DAG framework
    * @author Sk Minsar | 12-16-2024 
    * @param bc 
    **/
    public override void doFinish(Database.BatchableContext bc){
        
    }

    /**
    * @description - This is to scedule the batch job using the DAG framework
    * @author Sk Minsar | 12-16-2024 
    * @param sc 
    **/
    public override void doExecute(SchedulableContext sc){
        UpdateInvoiceDynamicJob obj=new UpdateInvoiceDynamicJob();
        Database.executeBatch(obj,ConstantValues.UPDATE_INVOICE_DAG_BATCH_SIZE);
    }
}