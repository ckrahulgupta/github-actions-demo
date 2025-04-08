/**
 * @description       : 
 * @author            : iAyush
 * @group             : 
 * @last modified on  : 02-28-2024
 * @last modified by  : Ayan Bhowmik
**/
public without sharing class EarlyNoticeToBuyers {
    /**
    * @description Updating NTB_Generated__c for buyers
    * @author Ayan Bhowmik | 02-28-2024 
    * @param objBuyerList 
    **/
    public static void earlyNotices(List<clcommon__Party__c> objBuyerList) {
        String earlyNTBClass = 'EarlyNoticeToBuyers';
        try{
            List<clcommon__party__c> objPartyList = new List<clcommon__party__c>();
            for(clcommon__party__c objBuyer : objBuyerList){
                objBuyer.NTB_Generated__c = true;
                objPartyList.add(objBuyer);
            }
            Database.update(objPartyList, true);
        }
        catch (Exception objException) {
            Portalhelper.saveExceptionLog(objException, earlyNTBClass);
        } 
    }
 }