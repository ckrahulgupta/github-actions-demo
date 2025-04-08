/**
 * @description       :  Batch Class For Rate Change
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 02-04-2025
 * @last modified by  : Ayush Kumar Singh
**/
public inherited sharing class BaseRateChangeBatch implements Database.Batchable<SObject> {
    private static final String DUMMY_RECORD = ConstantValues.DUMMY_RECORD;
    private static final String BASERATE_NOTIFICATION = ConstantValues.BASERATE_NOTIFICATION;
    private static final String BASERATE_TITLE = ConstantValues.BASERATE_TITLE;
    private static final String BASE_RATE_NOTIFICATION_TYPE = ConstantValues.BASE_RATE_NOTIFICATION_TYPE;
    private static final String LOAN_ACCOUNTING_GROUP = ConstantValues.LOAN_ACCOUNTING_GROUP;
    private List<genesis__Rate_Card_Setup_Header__c> myProgramsToUpdateList;
    private String currentInterestRate;
    private String newRate;
    private String selectedRate;
    
    /**
    * @description : Constructor to initialize variables
    * @author  Pritam Roy | 04-11-2024 
    * @param objWrapper 
    * @param objHeaderList 
    **/
    public BaseRateChangeBatch(BaseRateChangeController.RateInfoWrapper objWrapper,List<genesis__Rate_Card_Setup_Header__c> objHeaderList){
        this.newRate = objWrapper.newInterestRate;
        this.currentInterestRate = objWrapper.currentInterestRate;
        this.selectedRate = objWrapper.selectedRate;
        this.myProgramsToUpdateList = objHeaderList;
    }

    /**
     * @description Updating the FS Index Rate in Rate Card Header.
     * @param objRateCardSetupDetails 
     * @param newRate
     */
    private static void updateRateCardHeader(List<genesis__Rate_Card_Setup_Detail__c> objRateCardSetupDetails, String newRate){
        if(Schema.sObjectType.genesis__Rate_Card_Setup_Header__c.isUpdateable()){ 
            genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = new genesis__Rate_Card_Setup_Header__c(Id = objRateCardSetupDetails[0].genesis__Rate_Card_Setup_Header__c);
            rateCardHeaderObj.FS_Index_Rate__c = Decimal.valueOf(newRate);
            Database.update(rateCardHeaderObj,true);
        }
    }
    /**
    * @description : Query the rate card setup details to update
    * @author  Pritam Roy | 04-11-2024 
    * @param batchableContext 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext batchableContext){
        return Database.getQueryLocator([SELECT Id,
                                                genesis__Rate_Card_Setup_Header__c,
                                                genesis__Rate_Card_Setup_Header__r.FS_Index_Rate__c,
                                                genesis__Interest_Rate__c,
                                                Participation_Percentage_Dealer__c,
                                                Participation_Percentage_Dealer_Subsidy__c,
                                                Interest_Rate_Type__c,
                                                Participation_Percentage_CFA__c,
                                                genesis__Enabled_Flag__c
                                        FROM genesis__Rate_Card_Setup_Detail__c
                                        WHERE genesis__Rate_Card_Setup_Header__c in: myProgramsToUpdateList
                                        WITH SECURITY_ENFORCED ]);
    }

    /**
    * @description : Execute method to perform operations on rate card setup detail
    * @author  Pritam Roy | 04-11-2024 
    * @param batchableContext 
    * @param objRateCardSetup 
    **/
    public void execute(Database.BatchableContext batchableContext, List<genesis__Rate_Card_Setup_Detail__c> objRateCardSetup){
        SavePoint dbSavePoint = Database.setSavepoint();
        try{
            Decimal diffInInterest;
            diffInInterest = Decimal.valueOf(newRate) - Decimal.valueOf(currentInterestRate);
            if(objRateCardSetup[0].Interest_Rate_Type__c == ConstantValues.VARIABLE_STRING){
                if(objRateCardSetup[0].genesis__Enabled_Flag__c == false){
                    objRateCardSetup[0].genesis__Interest_Rate__c = objRateCardSetup[0].genesis__Interest_Rate__c + diffInInterest;
                }else{
                    objRateCardSetup[0].genesis__Interest_Rate__c = Decimal.valueOf(newRate) + objRateCardSetup[0].Participation_Percentage_Dealer__c - objRateCardSetup[0].Participation_Percentage_Dealer_Subsidy__c - objRateCardSetup[0].Participation_Percentage_CFA__c;
                }
            }else{
                Decimal interestCalculationCheck  = objRateCardSetup[0].genesis__Interest_Rate__c - Decimal.valueOf(newRate) + objRateCardSetup[0].Participation_Percentage_CFA__c;
                if(interestCalculationCheck < 0){
                    objRateCardSetup[0].Participation_Percentage_Dealer__c = 0;
                    objRateCardSetup[0].Participation_Percentage_Dealer_Subsidy__c = Math.abs(interestCalculationCheck);
                }else if(interestCalculationCheck > 0){
                    objRateCardSetup[0].Participation_Percentage_Dealer__c = interestCalculationCheck;
                    objRateCardSetup[0].Participation_Percentage_Dealer_Subsidy__c = 0;
                }else{
                    objRateCardSetup[0].Participation_Percentage_Dealer__c = 0;
                    objRateCardSetup[0].Participation_Percentage_Dealer_Subsidy__c = 0;
                }
            }
            if(Schema.sObjectType.genesis__Rate_Card_Setup_Detail__c.isUpdateable()){ 
                Database.update(objRateCardSetup,true);
            }
            if(selectedRate == ConstantValues.FS_INDEX_RATE && objRateCardSetup[0].genesis__Rate_Card_Setup_Header__r.FS_Index_Rate__c != Decimal.valueOf(newRate)){
                updateRateCardHeader(objRateCardSetup,newRate);
            }
        }
        catch (Exception objException){
            Database.rollback(dbSavePoint);
            LoggingUtility.saveExceptionLogging(objException, BaseRateChangeBatch.class.getName());
        }
    }

    /**
    * @description : Finish method to send notification
    * @author  Pritam Roy | 04-11-2024 
    * @param batchableContext 
    **/
    public void finish(Database.BatchableContext batchableContext){
        Set<String> userIds = new Set<String>();
        List<GroupMember> groupMemberList = new List<GroupMember>();
        try{
            // Get a list of User IDs for the group members
            groupMemberList = [SELECT UserOrGroupId 
                                    FROM GroupMember 
                                    WHERE groupId IN (SELECT Id 
                                                        FROM Group 
                                                        WHERE Name =: LOAN_ACCOUNTING_GROUP)];
            
            for(GroupMember groupUser : groupMemberList) {
                userIds.add(groupUser.UserOrGroupId);
            }

            Id notificationTypeId = [SELECT Id FROM 
                                            CustomNotificationType 
                                            WHERE DeveloperName =: BASE_RATE_NOTIFICATION_TYPE].Id;

            Messaging.CustomNotification objNotification = new Messaging.CustomNotification();
            objNotification.setTitle(selectedRate + BASERATE_TITLE);
            objNotification.setNotificationTypeId(notificationTypeId);
            objNotification.setBody(BASERATE_NOTIFICATION);
            objNotification.setTargetId(DUMMY_RECORD);
            objNotification.send(userIds);
        }catch (Exception objException) {
            LoggingUtility.saveExceptionLogging(objException, BaseRateChangeBatch.class.getName());
        }
    }
}