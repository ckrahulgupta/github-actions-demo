/**
 * @description       : Handler class for ExternalAPIApplication
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 16-09-2024
 * @last modified by  : Soumik Pattanayak
**/
global inherited sharing class ExternalAPIApplicationHandler {
    /**
     * @description This method is used to validate External User
     * @param objApplicationIdList
     * @return  `Boolean`
     */
    public static Boolean validateExternalUser(List<Id> objApplicationIdList ){
 
        List<User> loggedInUser = new List<User>();
        Boolean isValidUser=false;
        
        loggedInUser = ExternalSecurityUtil.getLoggedInUser();

        if(JSON.serialize(System.Label.AgVend_External_User_Profile_Label).contains(loggedInUser[0].Profile.Name)){
            List<genesis__Applications__c> objApplicationList = new List<genesis__Applications__c>();
            isValidUser=true;
            if(Schema.sObjectType.genesis__Applications__c.isAccessible()){
                objApplicationList =[SELECT Id,
                                            Dealer_Name__r.CIF_Number__c       
                                        FROM genesis__Applications__c
                                        WHERE ID IN :objApplicationIdList];
            }
            for(genesis__Applications__c app : objApplicationList){
                if(!JSON.serialize(ConstantValues.DEALER_CIF_NUMBER).contains(app.Dealer_Name__r.CIF_Number__c)){
                    isValidUser=false;
                }
            }
        }
        else if(loggedInUser[0].ContactId !=null && loggedInUser[0].AccountId !=null){
            List<clcommon__Party__c> applicationParties= new List<clcommon__Party__c>();
            applicationParties = getApplicationParty(loggedInUser,objApplicationIdList);
            isValidUser = validateUserByParty(applicationParties,objApplicationIdList);
            
        }
        return isValidUser;                                                               
    }

    /**
     * @description Method to get application party
     * @param loggedInUser 
     * @param objApplicationIdList 
     * @return  `List<clcommon__Party__c>`
     */
    private static List<clcommon__Party__c> getApplicationParty(List<User> loggedInUser,List<Id> objApplicationIdList){
        List<clcommon__Party__c> applicationParties= new List<clcommon__Party__c>();
        if(Schema.sObjectType.clcommon__Party__c.isAccessible()){
            applicationParties = [SELECT Id,
                                        genesis__Application__c,
                                        genesis__Application__r.Dealer_Name__r.CIF_Number__c
                                    FROM clcommon__Party__c
                                    WHERE genesis__Application__c In :objApplicationIdList
                                    AND clcommon__Contact__c = :loggedInUser[0].ContactId
                                    AND clcommon__Account__c = :loggedInUser[0].AccountId];
        }
        return applicationParties;
    }

    /**
     * @description Validate logged in user by application party
     * @param applicationParties 
     * @param objApplicationIdList 
     * @return  `Boolean`
     */
    private static Boolean validateUserByParty(List<clcommon__Party__c> applicationParties,List<Id> objApplicationIdList){
        Boolean isValidUser = false;
        List<Id> appPartyIdList=new List<Id>();
        if(applicationParties.size() > 0){
            for(clcommon__Party__c objApplicationParty:applicationParties){
                appPartyIdList.add(objApplicationParty.genesis__Application__c);
                if(JSON.serialize(ConstantValues.DEALER_CIF_NUMBER).contains(objApplicationParty.genesis__Application__r.Dealer_Name__r.CIF_Number__c)){
                    isValidUser=true;
                }else{
                    isValidUser=false;
                    break;
                }
            }
            for(Id appId:objApplicationIdList){
                if(!appPartyIdList.contains(appId)){
                    isValidUser=false;
                    break;
                }
            }
        }
        return isValidUser;
    }

     /**
    * @description : Method to get the updated child loan instances
    * @author Suraj Kumar | 08-30-2024 
    * @param objApplicationIdList 
    * @return Map<Id, List<genesis__Application_Pricing_Detail__c>> 
    **/
    public static Map<Id, List<genesis__Application_Pricing_Detail__c>> getUpdatedPricingMap(List<Id> objApplicationIdList){
        List<genesis__Application_Pricing_Detail__c> pricingDetailList = [SELECT Id,
                                                                                    genesis__Interest_Rate__c,
                                                                                    Principal_Advanced__c,
                                                                                    Interest_Accrued_Thru_Date__c,
                                                                                    Payoff_Amount_via_US_Mail__c,
                                                                                    Interest_Per_Diem__c,
                                                                                    genesis__Rate_Card_Setup_Detail__r.Billing_Date__c,
                                                                                    genesis__Application__c
                                                                            FROM genesis__Application_Pricing_Detail__c
                                                                            WHERE genesis__Enabled_Flag__c = true
                                                                            AND genesis__Application__c IN :objApplicationIdList];

        Map<Id, List<genesis__Application_Pricing_Detail__c>> updatedPricingDetailMap = new Map<Id, List<genesis__Application_Pricing_Detail__c>>();                                             
        for(genesis__Application_Pricing_Detail__c pricingDetailObj: pricingDetailList){
            if(pricingDetailObj.genesis__Rate_Card_Setup_Detail__r.Billing_Date__c == null){
                pricingDetailObj.genesis__Rate_Card_Setup_Detail__r.Billing_Date__c = null;
            }
            if(pricingDetailObj.Interest_Accrued_Thru_Date__c == null){
                pricingDetailObj.Interest_Accrued_Thru_Date__c = null;
            }
            if(pricingDetailObj.genesis__Interest_Rate__c == null){
                pricingDetailObj.genesis__Interest_Rate__c = null;
            }

            if(!updatedPricingDetailMap.containsKey(pricingDetailObj.genesis__Application__c)){
                List<genesis__Application_Pricing_Detail__c> tempPricingList = new List<genesis__Application_Pricing_Detail__c>();
                tempPricingList.add(pricingDetailObj);
                updatedPricingDetailMap.put(pricingDetailObj.genesis__Application__c, tempPricingList);
            }else{
                List<genesis__Application_Pricing_Detail__c> tempPricingList = updatedPricingDetailMap.get(pricingDetailObj.genesis__Application__c);
                tempPricingList.add(pricingDetailObj);
                updatedPricingDetailMap.put(pricingDetailObj.genesis__Application__c, tempPricingList);
            }
        }
        return updatedPricingDetailMap;
    }

    /**
     * @description Method to get application
     * @param loanNumberList 
     * @return  `List<genesis__Applications__c>`
     */
    public static List<genesis__Applications__c> getApplication(List<String> loanNumberList){
        List<genesis__Applications__c> objApplicationList = new List<genesis__Applications__c>();
        if(Schema.sObjectType.genesis__Applications__c.isAccessible()){
            objApplicationList =[SELECT Id,
                                        Available__c,
                                        Name,
                                        Crop_Year__c,
                                        genesis__Maturity_Date__c,
                                        genesis__Loan_Amount__c,
                                        Reserved_Amount__c,
                                        genesis__Loan_Number__c,
                                        ERP_Id__c,
                                        (SELECT genesis__Interest_Rate__c,
                                                    Principal_Advanced__c,
                                                    Interest_Accrued_Thru_Date__c,
                                                    Payoff_Amount_via_US_Mail__c,
                                                    Interest_Per_Diem__c,
                                                    genesis__Rate_Card_Setup_Detail__r.Billing_Date__c
                                            FROM genesis__Pricing_Details__r
                                            WHERE genesis__Enabled_Flag__c = true)
                                    FROM genesis__Applications__c
                                    WHERE genesis__Loan_Number__c IN :loanNumberList
                                    AND genesis__Status__c = : PortalConstants.ACTIVE_APPLICATION_STATUS
					                AND Loan_Id__c != null];
        }
        for (genesis__Applications__c app : objApplicationList) {
            if (String.isBlank(app.ERP_Id__c)) {
                app.ERP_Id__c = ExternalConstants.EMPTY_STRING; 
            }
            if(app.genesis__Maturity_Date__c == null){
                app.genesis__Maturity_Date__c = null;
            }
        }
        return objApplicationList;
    }
}