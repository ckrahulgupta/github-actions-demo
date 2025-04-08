/**
 * @description       : Scheduled class to activate/deactivate the pricing based on current date
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 06-10-2023
 * @last modified by  : Subham Nandi
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   12-04-2022   Subham Nandi   Initial Version
**/
public with sharing class ScheduledActivePricingDetailAPI implements Schedulable{
    /**
    * @description Disables all the My Programs that has passed the maturity, Enables/Disbales pricing based Start Date and End Date
    * @author Subham Nandi | 06-10-2023 
    * @param ctx 
    **/
    public void execute(SchedulableContext ctx){
        try {
            //query the My program that need to deactivate today
            //Validate Crud
            if(!genesis__Rate_Card_Setup_Header__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable() || 
            !genesis__Application_Pricing_Detail__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable() || 
            !genesis__Rate_Card_Setup_Header__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() ||
            !genesis__Rate_Card_Setup_Detail__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible() ||
            !genesis__Application_Pricing_Detail__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()){
                throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
            }
            //Call a method to update The My Program
            disableMyProgram();
            //Call a method to update the Pricing
            enableOrDisablePricing();
            
        } 
        catch (CustomException objCustomException) {
            PortalHelper.saveExceptionLog(objCustomException, ConstantValues.SCHEDULED_PRICING_ERROR);
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, ConstantValues.SCHEDULED_PRICING_ERROR);
        }
        
    }

    /**
    * @description Enables or Disables the Child Loans
    * @author Subham Nandi | 06-10-2023
    **/
    private static void enableOrDisablePricing(){
        List<genesis__Application_Pricing_Detail__c> objPricingListToConsider = [SELECT Id, 
                                                                                        genesis__Enabled_Flag__c, 
                                                                                        genesis__Rate_Card_Setup_Detail__r.End_Date__c, 
                                                                                        genesis__Rate_Card_Setup_Detail__r.Start_Date__c,
                                                                                        genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c
                                                                                FROM genesis__Application_Pricing_Detail__c
                                                                                WHERE genesis__Rate_Card_Setup_Detail__r.Start_Date__c = :System.today()
                                                                                OR genesis__Rate_Card_Setup_Detail__r.End_Date__c = :System.today().addDays(-1)];
        if(objPricingListToConsider.size() == 0 || objPricingListToConsider == null){
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
        
        Database.update(objpricingToUpdateList,true);
    }

    /**
    * @description Disables the My Program which have gone past the Maturity Date
    * @author Subham Nandi | 06-10-2023 
    **/
    private static void disableMyProgram(){
        List<genesis__Rate_Card_Setup_Header__c> objRateCardToUpdateList = new List<genesis__Rate_Card_Setup_Header__c>();
        List<genesis__Rate_Card_Setup_Header__c> programsToDeactivateList =  [ SELECT  Id,
                                                                                                genesis__Enabled_Flag__c,
                                                                                                Status__c
                                                                                        FROM genesis__Rate_Card_Setup_Header__c
                                                                                        WHERE genesis__End_Date__c = :System.today()];
        for(genesis__Rate_Card_Setup_Header__c objIndividualRate : programsToDeactivateList){
            objIndividualRate.genesis__Enabled_Flag__c = false;
            //objIndividualRate.Status__c = ConstantValues.MY_PROGRAM_EXPIRED_STATUS;
            objRateCardToUpdateList.add(objIndividualRate);
        }
        
        Database.update(objRateCardToUpdateList,true);
    }
}