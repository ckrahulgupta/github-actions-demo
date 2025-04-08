/**
 * @description       : 
 * @author            : Rakesh Saraf
 * @group             : 
 * @last modified on  : 01-16-2025
 * @last modified by  : Rakesh Saraf
**/
public with sharing class UpdateMyProgramController {

    /**
    * @description wrapper to send the proper data
    * @author Rakesh Saraf | 01-08-2025 
    **/
    public class MyProgramWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public genesis__Rate_Card_Setup_Header__c rateCardHeader;
        @AuraEnabled public List<genesis__Rate_Card_Setup_Detail__c> rateCardDetails;
    }

    /**
    * @description this method is used to get the my program
    * @author Rakesh Saraf | 01-08-2025 
    * @param myProgramId 
    * @return MyProgramWrapper 
    **/
    @AuraEnabled(cacheable=true)
    public static MyProgramWrapper getMyProgramDetails(Id myProgramId){
        try {
            List<genesis__Rate_Card_Setup_Header__c> myProgramList= [SELECT Id, 
                                                                            Name, 
                                                                            Closing_Fee__c, 
                                                                            Crop_Year__c, 
                                                                            CFA_Advantage_Rate__c, 
                                                                            Loan_Fee_Advanced_On__c, 
                                                                            Dealer_Participate_on_Closing_Fee__c, 
                                                                            Account__r.Name, 
                                                                            Payer_of_Loan_Closing_Fee__c
                                                                FROM genesis__Rate_Card_Setup_Header__c
                                                                WHERE ID =:myprogramId
                                                                WITH SECURITY_ENFORCED];
            if(myProgramList.isEmpty()){
                throw new AuraHandledException(ConstantValues.LIST_EMPTY_CHECK);
            }

            List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetails= [SELECT Id, 
                                                                                    Interest_Rate_Type__c, 
                                                                                    Participation_Percentage_CFA__c, 
                                                                                    Participation_Percentage_Dealer_Subsidy__c, 
                                                                                    Participation_Percentage_Dealer__c, 
                                                                                    Special_Term_Order__c, 
                                                                                    Special_Term_Reference__c, 
                                                                                    Start_Date__c, 
                                                                                    Billing_Date__c, 
                                                                                    Has_Billing_Date__c, 
                                                                                    End_Date__c, 
                                                                                    Description__c, 
                                                                                    genesis__Interest_Rate__c, 
                                                                                    genesis__Rate_Card_Setup_Header__c 
                                                                            FROM genesis__Rate_Card_Setup_Detail__c
                                                                            WHERE genesis__Rate_Card_Setup_Header__c=: myProgramList[0].ID
                                                                            AND genesis__Enabled_Flag__c= :ConstantValues.TRUE_VALUE
                                                                            WITH SECURITY_ENFORCED];

            // return myProgramList[0];
            if(rateCardSetupDetails.isEmpty()){
                throw new AuraHandledException(ConstantValues.LIST_EMPTY_CHECK);
            }

            MyProgramWrapper wrapperObj=new MyProgramWrapper();
            wrapperObj.id=myProgramList[0].id;
            wrapperObj.rateCardHeader=myProgramList[0];
            wrapperObj.rateCardDetails=rateCardSetupDetails;
            System.debug('wrapper'+wrapperObj);

            return wrapperObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
}