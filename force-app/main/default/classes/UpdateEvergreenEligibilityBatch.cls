/**
 * @description       : Update the Evergreen Eligibility when we update the Grower Evergreen Evergreen Allowed flag
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 01-10-2025
 * @last modified by  : Rakesh Saraf
**/

global without sharing class UpdateEvergreenEligibilityBatch implements  Database.Batchable<sObject>, Database.AllowsCallouts{
    private final String CLASS_NAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    private Boolean isEvergreenAllowed;
    private String accountId;

    
    /**
    * @description - Constructor to assing accountId and Grower Evergreen eligibility flag
    * @author Sk Minsar | 05-13-2024 
    * @param isEvergreenAllowed 
    * @param accountId 
    **/
    public UpdateEvergreenEligibilityBatch(Boolean isEvergreenAllowed, String accountId){
        this.isEvergreenAllowed = isEvergreenAllowed;
        this.accountId = accountId;
    }

    /**
    * @description - This methods query the Applications for update the Evergreen Eligibility
    * @author Sk Minsar | 05-13-2024 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id,
                                                genesis__Status__c,
                                                Is_Evergreen_Eligible__c,
                                                Is_Evergreen__c,
                                                genesis__Credit_Rating__r.Name,
                                                Stage__c
                                                FROM genesis__applications__c
                                                WHERE Id IN ( SELECT genesis__Application__c
                                                            FROM clcommon__Party__c 
                                                            WHERE (genesis__Application__c != NULL
                                                            AND (genesis__Application__r.Is_Evergreen_Eligible__c != :isEvergreenAllowed
                                                            OR genesis__Application__r.Is_Evergreen__c != :isEvergreenAllowed)
                                                            AND clcommon__Party_Types__c IN (:PortalConstants.BORROWER_PARTY_NAME,:PortalConstants.PRINCIPAL_PARTY_NAME)
                                                            AND Dealer_Applicant_Relationship__c = :accountId )
                                                            OR //Check for finding out the applications which has Dealers as Evergreen Allowed/Not Allowed - Call from Dealer Creation Flow
                                                            (genesis__Application__c != NULL AND 
                                                            genesis__Application__r.Dealer_Name__c = :accountId AND 
                                                            clcommon__Party_Types__c = :PortalConstants.DEALER_PROFILE AND 
                                                            (genesis__Application__r.Is_Evergreen_Eligible__c != :isEvergreenAllowed
                                                                OR genesis__Application__r.Is_Evergreen__c != :isEvergreenAllowed))
                                                            )]);
    }

    /**
    * @description - This method updates the Eligibility of applications
    * @author Sk Minsar | 05-13-2024 
    * @param bc 
    * @param applicationsList 
    **/
    public void execute(Database.BatchableContext bc, List<genesis__Applications__c> applicationsList) {
        SavePoint dbSavePoint = Database.setSavepoint();
        try{
            for(genesis__Applications__c applicationObj: applicationsList){
                boolean isActiveOrClosed = (applicationObj.genesis__Status__c).equals(PortalConstants.ACTIVE_APPLICATION_STATUS) || 
                                (applicationObj.genesis__Status__c).equals(PortalConstants.CLOSED_APPLICATION_STATUS);
                if(!isEvergreenAllowed){
                    applicationObj = EvergreenCheckHandler.updateEvergreenStatusForNotAllowed(applicationObj, isActiveOrClosed);
                }else{
                    applicationObj = EvergreenCheckHandler.updateEvergreenStatusForAllowed(applicationObj, isActiveOrClosed);
                }
            }
            if(!applicationsList.isEmpty()){ 
                Database.update(applicationsList, PortalConstants.TRUE_VALUE);
            }
        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
    }

    /**
    * @description - finish method for UpdateEvergreenEligibilityBatch
    * @author Sk Minsar | 05-13-2024 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc){
        return;
    }

    /**
    * @description This is called from a flow whenever a Dealer Account changes the value of the field - Allow Evergreen Applications.
    *              What this method does : Calls a BATCH class which sets the Evergreen checkboxes for each application on the query.
    * @author Subham Nandi | 23-07-2024 
    * @param accountId 
    **/
    @InvocableMethod(label = 'Update Dealer Specific Evergreen Applications')
    public static void updateEvegreenForSpecificDealer(List<Id> accountId){
        List<Account> dealerContact = [SELECT Id,
                                        RecordType.Name,
                                        ParentId,
                                        Parent.Coop_type__c,
                                        Allow_Dealer_Evergreen_Applications__c
                                    FROM Account
                                    WHERE Id = :accountId[ConstantValues.ZERO_VALUE]];
        UpdateEvergreenEligibilityBatch updateEvergreenApps = new UpdateEvergreenEligibilityBatch(dealerContact[0].Allow_Dealer_Evergreen_Applications__c,
                                                                                                        dealerContact[0].Id);
        Database.executeBatch(updateEvergreenApps, 40);

    }
}