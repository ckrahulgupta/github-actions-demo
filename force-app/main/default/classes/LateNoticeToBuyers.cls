/**
 * @description       : Conga Class for Late NTB
 * @author            : iAyush
 * @group             : 
 * @last modified on  : 03-14-2024
 * @last modified by  :  Pritam Roy
**/
global without sharing class LateNoticeToBuyers {

    /**
    * @description : late notice conga trigger
    * @author  Pritam Roy | 03-14-2024 
    **/
    public static void lateNotices() {
        List<Task> objTaskList = [SELECT genesis__Application__c 
                                    FROM Task 
                                    WHERE Subject = 'Notice of Security Interest (CFA Action)' 
                                    AND Status = 'Completed'];
        List<Id> objValidAppList = new List<Id>();
        for(Task task : objTaskList){
            objValidAppList.add(task.genesis__Application__c);
        }
        List<clcommon__party__c> objBuyerList = [SELECT Id,
                                                        clcommon__account__c,
                                                        genesis__Application__c,
                                                        genesis__Application__r.genesis__status__c,
                                                        NTB_Generated__c
                                                    FROM clcommon__Party__c 
                                                    WHERE clcommon__Party_Types__c = 'BUYER' 
                                                    AND genesis__Application__r.genesis__status__c = 'Active'
                                                    AND NTB_Generated__c = false
                                                    AND genesis__Application__c IN :objValidAppList];
    
        
        //call conga trigger here!
        List<clcommon__party__c> objPartyList = new List<clcommon__party__c>();
        for(clcommon__party__c objBuyer : objBuyerList){
            objBuyer.NTB_Generated__c = true;
            objPartyList.add(objBuyer);
        }
        Database.update(objPartyList, true);

    }

    /**
    * @description : Call conga trigger from skuid
    * @author  Pritam Roy | 03-14-2024 
    * @param appId 
    * @return String 
    **/
    webservice static String adhocNTB(String appId) {
        List<clcommon__party__c> objBuyerList = [SELECT Id,
                                                    clcommon__account__c,
                                                    genesis__Application__c,
                                                    genesis__Application__r.genesis__status__c
                                                    FROM clcommon__Party__c 
                                                    WHERE clcommon__Party_Types__c = 'BUYER' 
                                                    AND NTB_Generated__c = false
                                                    AND genesis__Application__r.genesis__status__c = 'Active'
                                                    AND genesis__Application__c =: appId];
    
        //call conga trigger here!
        List<clcommon__party__c> objPartyList = new List<clcommon__party__c>();
        for(clcommon__party__c objBuyer : objBuyerList){
            objBuyer.NTB_Generated__c = true;
            objBuyer.NTB_Label_Report_Generated__c = true;
            objBuyer.NTB_Report_Generated__c = true;
            objBuyer.NTB_Summary_Report_Generated__c = true;
            objPartyList.add(objBuyer);
        }
        Database.update(objPartyList, true);
        return 'Document Generated Successfully';
    }

    /**
    * @description : Call conga trigger from skuid
    * @author  Pritam Roy | 03-14-2024 
    * @param appId 
    * @return String 
    **/
    webservice static String adhocNTBRelease(String appId) {
        List<clcommon__party__c> objBuyerList = [SELECT Id,
                                                    clcommon__account__c,
                                                    genesis__Application__c,
                                                    genesis__Application__r.genesis__status__c
                                                    FROM clcommon__Party__c 
                                                    WHERE clcommon__Party_Types__c = 'BUYER' 
                                                    AND NTB_Generated_Release__c = false
                                                    AND genesis__Application__r.genesis__status__c = 'Active'
                                                    AND genesis__Application__c =: appId];
    
        
        //call conga trigger here!
        List<clcommon__party__c> objPartyList = new List<clcommon__party__c>();
        for(clcommon__party__c objBuyer : objBuyerList){
            objBuyer.NTB_Generated_Release__c = true;
            objPartyList.add(objBuyer);
        }
        Database.update(objPartyList, true);
        return 'Document Generated Successfully';
    }
    
    /**
    * @description : Contructor to initialize
    * @author  Pritam Roy | 03-14-2024 
    * @param controller 
    **/
    public LateNoticeToBuyers(ApexPages.StandardController controller) {
        type =  String.valueOf(controller.getRecord());
    }

    /**
    * @description : Getter and Setter Methods
    * @author  Pritam Roy | 03-14-2024 
    **/
    public String type { get; set; }

    
    /**
    * @description : Method that can is called from the Visual Force page action attribute
    * @author  Pritam Roy | 03-14-2024 
    * @return PageReference 
    **/
    public static PageReference sendLateNotice() {
        //Get the user profile
        Id profileId = UserInfo.getProfileId(); 
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        if(profileName.equalsIgnoreCase(ConstantValues.PROFILE_ADMIN) || 
            profileName.equalsIgnoreCase(ConstantValues.PROFILE_CFA_ADMIN) || 
            profileName.equalsIgnoreCase(ConstantValues.PROFILE_CREDIT)){
            lateNotices();
            String RetPage = String.valueOf(ApexPages.currentPage().getHeaders().get('Referer')) + 'lightning/o/genesis__Applications__c/list?filterName=Recent';
            PageReference RetPageRef = new PageReference(RetPage);
            return RetPageRef;
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ConstantValues.INSUFFICIENT_ACCESS));
            return null;
        }
        
    }
}