/**
 * @description       :  Evaluate Past Due Balance
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : Ayush Kumar Singh
**/
public with sharing class NLSEvaluatePastDueBatch implements  Database.Batchable<sObject>{
    /**
    * @description : Update Past Due Flag in Dealer Applicant Relationship
    * @author  Pritam Roy | 05-16-2024 
    * @param dealerRelUpdateList 
    **/
    private static void updateDealerApplicantRelation(List<Dealer_Applicant_Relationship__c> dealerRelUpdateList){
        if(Schema.sObjectType.Dealer_Applicant_Relationship__c.isUpdateable()){ 
            Database.update(dealerRelUpdateList,true);
        }
    }
    /**
    * @description : Batch Query to get Past Due Accounts
    * @author  Pritam Roy | 03-14-2024 
    * @param batchableContext 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext batchableContext) {
        return Database.getQueryLocator([SELECT Id 
                                                FROM Dealer_Applicant_Relationship__c 
                                                WHERE Has_Past_Due__c = true
                                                WITH SECURITY_ENFORCED]);
    }
    
    /**
    * @description : Validate Past Due Applications for Each Account
    * @author  Pritam Roy | 06-13-2024 
    * @param batchableContext 
    * @param dealerApplicantRelList 
    **/
    public void execute( Database.BatchableContext batchableContext, List<Dealer_Applicant_Relationship__c> dealerApplicantRelList) {
        Map<String,Decimal> pastDueAppMap = new Map<String,Decimal>();
        Map<String,Boolean> isAccountPastdueMap = new Map<String,Boolean>();
        List<Dealer_Applicant_Relationship__c> dealerRelUpdateList = new List <Dealer_Applicant_Relationship__c>();
        try {
            //query all past due applications
            List<genesis__Applications__c> pastDueAppList = [SELECT Id,
                                                                    Name,
                                                                    Past_Due_Amount__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE Past_Due_Amount__c > 0
                                                                WITH SECURITY_ENFORCED];

            //Add Accounts that are past due in a map
            for(Dealer_Applicant_Relationship__c eachDealerApplicantRel : dealerApplicantRelList){
                isAccountPastdueMap.put(eachDealerApplicantRel.id,false);
            }
            //Add Past Due Applications in Map
            for(genesis__Applications__c userApplication : pastDueAppList){
                pastDueAppMap.put(userApplication.id,userApplication.Past_Due_Amount__c);
            }
            //Query all parties of all the User Accounts
            List<clcommon__party__c> appPartiesList = [SELECT Id,
                                                                Dealer_Applicant_Relationship__c,
                                                                genesis__Application__c,
                                                                genesis__Application__r.name,
                                                                genesis__Application__r.Non_Accrual__c,
                                                                genesis__Application__r.Past_Due_Amount__c,
                                                                clcommon__Account__c,
                                                                clcommon__Account__r.Name,
                                                                clcommon__Account__r.Has_Past_Due__c
                                                            FROM clcommon__party__c 
                                                            WHERE Dealer_Applicant_Relationship__c IN: dealerApplicantRelList 
                                                            AND clcommon__Type__r.Name IN (:PortalConstants.BORROWER_PARTY_NAME,
                                                                                            :PortalConstants.PRINCIPAL_PARTY_NAME)
                                                            WITH SECURITY_ENFORCED
                                                            ORDER BY genesis__Application__r.Past_Due_Amount__c DESC];

            //Check if party is linked to any app that has non accrual
            for(clcommon__party__c eachParty : appPartiesList){
                if(pastDueAppMap.containsKey(eachParty.genesis__Application__c)){
                    isAccountPastdueMap.put(eachParty.Dealer_Applicant_Relationship__c, true);
                }
            }

            //Reeavluate Past Due
            for(Dealer_Applicant_Relationship__c eachDealerApplicantRel : dealerApplicantRelList){
                Dealer_Applicant_Relationship__c dealerApplicantRel = new Dealer_Applicant_Relationship__c(Id = eachDealerApplicantRel.id);
                dealerApplicantRel.Has_Past_Due__c = isAccountPastdueMap.get(eachDealerApplicantRel.id);
                if(isAccountPastdueMap.get(eachDealerApplicantRel.id)){
                    dealerApplicantRel.Has_Past_Due__c = true;
                }else{
                    dealerApplicantRel.Has_Past_Due__c = false;
                }
                dealerRelUpdateList.add(dealerApplicantRel);
            }
            //Update Accounts
            updateDealerApplicantRelation(dealerRelUpdateList);
            
        } catch (Exception objException) {
            LoggingUtility.saveExceptionLogging(objException, NLSEvaluatePastDueBatch.class.getName());
        }
    }

    /**
    * @description : Batch Finish
    * @author  Pritam Roy | 03-14-2024 
    * @param batchableContext 
    **/
    public void finish(Database.BatchableContext batchableContext) {}
}