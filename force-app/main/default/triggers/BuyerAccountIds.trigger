/**
 * @description       : Trigger to store All Buyer's AccountId in Application Field
 * @author            : Simran
 * @group             : 
 * @last modified on  : 05-12-2023
 * @last modified by  : Simran
**/
trigger BuyerAccountIds on clcommon__party__c (after insert, before delete) {
    String buyer='BUYER';
    String bUYERACCOUNTIDS='BuyerAccountIds';
    Map<String,String> accountappMap = new Map<String,String>();
    List<genesis__Applications__c> objAppId= new List<genesis__Applications__c>();
    try{
        if(Trigger.isAfter){
        for( clcommon__party__c event : trigger.new){
                if(event.clcommon__Party_Types__c==buyer){
                    accountappMap.put(event.clcommon__Account__c,event.genesis__Application__c);
                }
            }
        }
        if(Trigger.isBefore){
            for( clcommon__party__c event : trigger.old){
                if(event.clcommon__Party_Types__c==buyer){
                    accountappMap.put(event.clcommon__Account__c,event.genesis__Application__c);
                }
            }
        }
        if(accountappMap !=null){
            List<Id>  appIds = new List<Id>();
            for (String key : accountappMap.keySet()){
                appIds.add(accountappMap.get(key));
                
            }
            if(genesis__Applications__c.SObjectType.getDescribe().isAccessible()){
                objAppId=[SELECT Id,
                                Buyer_Account_Id__c 
                            FROM genesis__Applications__c 
                            WHERE Id In: appIds];
            }
            if(Trigger.isAfter){
                for(genesis__Applications__c app: objAppId){
                    if(app.Buyer_Account_Id__c==null){
                        app.Buyer_Account_Id__c=' / ';
                    }
                    for(String key:accountappMap.keySet()){
                        if(!String.valueOf(app.Buyer_Account_Id__c).contains(key)){
                            app.Buyer_Account_Id__c=app.Buyer_Account_Id__c + key + ' / ';
                        } 
                    }
                }
            }
            if(Trigger.isBefore){
                for(genesis__Applications__c app: objAppId){
                    if(app.Buyer_Account_Id__c==null){
                        app.Buyer_Account_Id__c=' / ';
                    }
                    for(String key:accountappMap.keySet()){
                        if(String.valueOf(app.Buyer_Account_Id__c).contains(key)){
                            app.Buyer_Account_Id__c = app.Buyer_Account_Id__c.replace(key,'');
                        }
                    }
                }
            } 
            if(genesis__Applications__c.SObjectType.getDescribe().isUpdateable()){
                Database.update(objAppId,true);
            }
        }
    }
    catch (Exception objException) {
        PortalHelper.saveExceptionLog(objException, bUYERACCOUNTIDS);
    }
}