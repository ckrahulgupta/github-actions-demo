/**
 * @description       : A class to bulkify the process of disabling all the rate card setup heaaders who have reached the matturity date and disable all the active pricing who have reached the end date. It also enables the pricing for the next month
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 10-03-2024
 * @last modified by  : Rakesh Saraf
**/

global with sharing class PricingManagementDynamicJob extends clcommon.DynamicJob {
    Boolean isProcessingPricing;

    /**
    * @description Default constructor
    * @author Krishanu Chinya | 09-26-2024 
    **/
    global PricingManagementDynamicJob() {
        super();
        this.isProcessingPricing=false;
    }

    /**
    * @description Parameterized constructor to get the query that has been passed from salesforce DAG Schedule
    * @author Rakesh Saraf | 09-26-2024 
    * @param name 
    * @param query 
    **/
    public PricingManagementDynamicJob(String name,String query){
        super(name,query);
        this.isProcessingPricing=false;

    }

    /**
    * @description Parameterized constructor which will be used to set the value of the flag so that the batch class runs again
    * @author Rakesh Saraf | 09-26-2024 
    * @param isProcessingPricing
    **/
    public PricingManagementDynamicJob(Boolean isProcessingPricing){

        this.isProcessingPricing=isProcessingPricing;
    }


    /**
    * @description overriding the doInitialize method of the dynamic job class
    * @author Rakesh Saraf | 09-26-2024 
    **/
    public override void doInitialize(){
        return ;
    }

    /**
    * @description retuns the query based on
    * @author Rakesh Saraf | 09-26-2024 
    * @return String 
    **/
    public override String getRuntimeQuery(){
        if(this.isProcessingPricing==false){
            return 'SELECT Id, genesis__Enabled_Flag__c, Status__c FROM genesis__Rate_Card_Setup_Header__c where genesis__End_Date__c= today';

        } else {
            return 'SELECT Id, genesis__Enabled_Flag__c, genesis__Rate_Card_Setup_Detail__r.End_Date__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c, genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c FROM genesis__Application_Pricing_Detail__c WHERE genesis__Rate_Card_Setup_Detail__r.Start_Date__c = today OR genesis__Rate_Card_Setup_Detail__r.End_Date__c = yesterday';
        }
    }

    /**
    * @description doStart method of the DAG framework is blank
    * @author Rakesh Saraf | 09-26-2024 
    * @param bc 
    **/
    public override void doStart(Database.BatchableContext bc) {
        return ;
    }

    /**
    * @description the doExecute method of DAG framework which will run the process Pricing if the isProcessingPricing is true else it will run the process RateCard
    * @author Rakesh Saraf | 09-26-2024 
    * @param bc 
    * @param objlist 
    **/
    public override void doExecute(Database.BatchableContext bc, List<sObject> objlist) {
        SavePoint dbSavePoint = Database.setSavepoint();
        try {
            if(this.isProcessingPricing==true & objlist.getSObjectType()==genesis__Application_Pricing_Detail__c.SObjectType){
                processPricing(objlist);
            }
            if(this.isProcessingPricing==false & objList.getSObjectType()==genesis__Rate_Card_Setup_Header__c.SObjectType){
                processRateCard(objlist);
            }
            
        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            LoanServicingHelper.saveExceptionLog(objException, PricingManagementDynamicJob.class.getName());
        }
    }

    /**
    * @description This method will disable all the active pricing if yesterday was the last day of the month and it was also the end day of the sub-tranche. It will enable the pricing for the next month too
    * @author Krishanu Chinya | 09-26-2024 
    * @param objPricingListToConsider 
    **/
    private static void processPricing(List<genesis__Application_Pricing_Detail__c> objPricingListToConsider){
        if(objPricingListToConsider.isEmpty()){
            throw new CustomException(ConstantValues.PRICING_NOT_FOUND);
        }
        List<genesis__Application_Pricing_Detail__c> objpricingToUpdateList = new List<genesis__Application_Pricing_Detail__c>();
        for(genesis__Application_Pricing_Detail__c eachPricingDetail : objPricingListToConsider){

            //Check whether to start ot to end
            if(eachPricingDetail.genesis__Rate_Card_Setup_Detail__r.Start_Date__c == System.today()){
                //Pricing to start---Activate it
                eachPricingDetail.genesis__Enabled_Flag__c = true;

            }
            
            else if(eachPricingDetail.genesis__Rate_Card_Setup_Detail__r.End_Date__c == System.today().addDays(-1) &&
                eachPricingDetail.genesis__Rate_Card_Setup_Detail__r.End_Date__c < eachPricingDetail.genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c){
                    //pricing to end---Deactivate it
                    eachPricingDetail.genesis__Enabled_Flag__c = false;
            }
            objpricingToUpdateList.add(eachPricingDetail);
        }
        
        Database.update(objpricingToUpdateList,true,AccessLevel.SYSTEM_MODE);
    }

    /**
    * @description The method will diable all the reate cards that have reached their maturity date
    * @author Rakesh Saraf | 09-26-2024  
    * @param programsToDeactivateList 
    **/
    private static void processRateCard(List<genesis__Rate_Card_Setup_Header__c> programsToDeactivateList){
        
        if(programsToDeactivateList.isEmpty()){
            throw new CustomException(ConstantValues.RATE_CARD_NOT_FOUND);
        }
        List<genesis__Rate_Card_Setup_Header__c> objRateCardToUpdateList = new List<genesis__Rate_Card_Setup_Header__c>();
        
        for(genesis__Rate_Card_Setup_Header__c objIndividualRate : programsToDeactivateList){
            objIndividualRate.genesis__Enabled_Flag__c = false;
            objRateCardToUpdateList.add(objIndividualRate);
        }
        
        Database.update(objRateCardToUpdateList,true,AccessLevel.SYSTEM_MODE);
    }

    /**
    * @description doFinish method of the DAG framework which will run the batch process again to disable all the active pricing
    * @author Rakesh Saraf | 09-26-2024 
    * @param bc 
    **/
    public override void doFinish(Database.BatchableContext bc){
        if(this.isProcessingPricing==false){
            PricingManagementDynamicJob obj=new PricingManagementDynamicJob(true);
            Database.executeBatch(obj,ConstantValues.PRICING_MANAGEMENT_DAG_BATCH_SIZE);
        }
    }

    /**
    * @description This is to scedule the batch job using the DAG framework
    * @author Rakesh Saraf | 09-27-2024 
    * @param sc 
    **/
    public override void doExecute(SchedulableContext sc){
        PricingManagementDynamicJob obj=new PricingManagementDynamicJob();
        Database.executeBatch(obj,ConstantValues.PRICING_MANAGEMENT_DAG_BATCH_SIZE);
    }
}