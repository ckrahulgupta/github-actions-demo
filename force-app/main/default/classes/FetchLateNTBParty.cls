/**
 * @description       : Controller class for Late NTB VF page
 * @author            : Simran
 * @group             : 
 * @last modified on  : 03-04-2024
 * @last modified by  :  Pritam Roy
**/
public with sharing class FetchLateNTBParty {
    //Constants specific to this class starts
    public static final String APPLICATION_LIST_URL = '/lightning/o/genesis__Applications__c/list?filterName=Recent';
    public static final String NTB_FOLDER = 'NTB';
    //Constants specific to this class ends
    List<Id> objValidAppList = new List<Id>();
    public Boolean hasBeenClickedAlready = false;
    /**
    * @description : unused
    * @author  Pritam Roy | 03-04-2024
    **/
    public List<clcommon__party__c> allPartyList{get;set;}
    /**
    * @description : Stores all parties of Applications that are active
    * @author  Pritam Roy | 03-04-2024
    **/
    public List<clcommon__party__c> allList{get;set;}
    /**
    * @description : Stores the Applications to generate NTB
    * @author  Pritam Roy | 03-04-2024
    **/
    public List<selectedApplication> selectApps {get; set;}
    /**
    * @description : Stores the Applications that are selected for NTB
    * @author  Pritam Roy | 03-04-2024
    **/
    public List<clcommon__party__c> newApps {get; set;}
    /**
    * @description : Stores the crop year
    * @author  Pritam Roy | 03-04-2024
    **/
    public String cropYear{get;set;}
    /**
    * @description constructor to show party records while vf page calling
    * @author  Pritam Roy | 03-04-2024 
    **/
    public FetchLateNTBParty(){
        List<Task> objTaskList = new List<Task>();
        if(Task.SObjectType.getDescribe().isAccessible()){
            objTaskList = [SELECT genesis__Application__c 
                                        FROM Task 
                                        WHERE Subject = :PortalConstants.NTB_TASK_CFA_ACTION 
                                        AND Status = :PortalConstants.COMPLETED_TASK_STATUS];
                                }
        for(Task task : objTaskList){
            objValidAppList.add(task.genesis__Application__c);
        }
        selectApps = new List<selectedApplication>();
        if(clcommon__Party__c.SObjectType.getDescribe().isAccessible() && 
        genesis__Applications__c.SObjectType.getDescribe().isAccessible()){
            allList=[SELECT clcommon__Party__c.Name,
                            genesis__Application__r.Name,
                            genesis__Application__r.Dealer_Name__r.CIF_Number__c,
                            genesis__Application__r.genesis__Loan_Number__c, 
                            genesis__Application__r.genesis__Account__r.Name,
                            clcommon__Account__r.Name, 
                            NTB_Generated__c,
                            genesis__Application__r.genesis__Account__r.BillingCity,
                            genesis__Application__r.genesis__Account__r.BillingState 
                        FROM clcommon__Party__c 
                        WHERE clcommon__Party_Types__c = :PortalConstants.BUYER_PARTY_NAME
                        AND genesis__Application__c IN:objValidAppList
                        AND genesis__Application__r.genesis__Status__c=:PortalConstants.ACTIVE_APPLICATION_STATUS
                        AND NTB_Generated__c = false];
                        }
        for(clcommon__party__c objPartyId: allList){
            SelectedApplication selAppobj = new SelectedApplication(objPartyId,false);
            selectApps.add(selAppobj);
        }
        
    }
    /**
    * @description : class to save the application details
    * @author  Pritam Roy | 03-04-2024
    **/
    public class SelectedApplication{
        /**
        * @description : variable to store the application object of the party
        * @author  Pritam Roy | 03-04-2024
        **/
        public clcommon__party__c  appSelected {get; set;}
        /**
        * @description :  variable to store the application 
        * @author  Pritam Roy | 03-04-2024
        **/
        public Boolean appIdFlag {get;set;}
        /**
        * @description : variable to store the application name
        * @author  Pritam Roy | 03-04-2024
        **/
        public String appName{get;set;}
        /**
        * @description : variable to store the loan number
        * @author  Pritam Roy | 03-04-2024
        **/
        public String loanNumber{get;set;}
        /**
        * @description : variable to store the CIF
        * @author  Pritam Roy | 03-04-2024
        **/
        public String cif{get;set;}
        /**
        * @description : variable to store account name
        * @author  Pritam Roy | 03-04-2024
        **/
        public String legalName{get;set;}
        /**
        * @description : variable to store the buyer name
        * @author  Pritam Roy | 03-04-2024
        **/
        public String buyersName{get;set;}
        /**
        * @description : variable to store the city of the borrower
        * @author  Pritam Roy | 03-04-2024
        **/
        public String city{get;set;}
        /**
        * @description : variable to store the state of the borrower
        * @author  Pritam Roy | 03-04-2024
        **/
        public String state{get;set;}
        /**
        * @description : method to store details of the buyer party
        * @author  Pritam Roy | 03-04-2024
        * @param objpartySelected
        * @param selected
        **/
        public SelectedApplication(clcommon__party__c objpartySelected,Boolean selected){
            this.appSelected=objpartySelected;
            this.appName = objpartySelected.genesis__Application__r.Name;
            this.appIdFlag = selected;
            this.cif = objpartySelected.genesis__Application__r.Dealer_Name__r.CIF_Number__c;
            this.loanNumber = objpartySelected.genesis__Application__r.genesis__Loan_Number__c;
            this.legalName = objpartySelected.genesis__Application__r.genesis__Account__r.Name;
            this.buyersName = objpartySelected.clcommon__Account__r.Name;
            this.city = objpartySelected.genesis__Application__r.genesis__Account__r.BillingCity;
            this.state=objpartySelected.genesis__Application__r.genesis__Account__r.BillingState;
        }
    }
    
    /**
    * @description : query applictions of buyer
    * @author  Pritam Roy | 03-04-2024 
    **/
    public void searchApp(){
        String controllerClassName = 'FetchLateNTBParty';
        try{
            selectApps = new List<selectedApplication>();
            if(String.isBlank(cropYear)){
                List<clcommon__party__c> allList=[SELECT clcommon__Party__c.Name,
                                                        genesis__Application__r.Name,
                                                        genesis__Application__r.Dealer_Name__r.CIF_Number__c,
                                                        genesis__Application__r.genesis__Loan_Number__c, 
                                                        genesis__Application__r.genesis__Account__r.Name,
                                                        clcommon__Account__r.Name, 
                                                        NTB_Generated__c,
                                                        genesis__Application__r.genesis__Account__r.BillingCity,
                                                        genesis__Application__r.genesis__Account__r.BillingState 
                                                        FROM clcommon__Party__c 
                                                        WHERE clcommon__Party_Types__c = :PortalConstants.BUYER_PARTY_NAME 
                                                        AND genesis__Application__c IN:objValidAppList
                                                        AND genesis__Application__r.genesis__Status__c=:PortalConstants.ACTIVE_APPLICATION_STATUS
                                                        AND NTB_Generated__c = false];
                for(clcommon__party__c objPartyId: allList){
                    SelectedApplication selAppobj = new SelectedApplication(objPartyId,false);
                    selectApps.add(selAppobj);
                }
            }
            else{
                if(cropYear.length()!=4 || cropYear.isAlpha()){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ConstantValues.NTB_INVALID_CROPYEAR));
                }
                else{
                    List<clcommon__party__c> allList=[SELECT clcommon__Party__c.Name,
                                                                genesis__Application__r.Name,
                                                                genesis__Application__r.Dealer_Name__r.CIF_Number__c,
                                                                genesis__Application__r.genesis__Loan_Number__c, 
                                                                genesis__Application__r.genesis__Account__r.Name,
                                                                clcommon__Account__r.Name, 
                                                                NTB_Generated__c,
                                                                genesis__Application__r.Crop_Year__c,
                                                                genesis__Application__r.genesis__Account__r.BillingCity,
                                                                genesis__Application__r.genesis__Account__r.BillingState 
                                                                FROM clcommon__Party__c 
                                                                WHERE clcommon__Party_Types__c = :PortalConstants.BUYER_PARTY_NAME  
                                                                AND genesis__Application__c IN:objValidAppList
                                                                AND genesis__Application__r.genesis__Status__c=:PortalConstants.ACTIVE_APPLICATION_STATUS
                                                                AND NTB_Generated__c = false
                                                                AND genesis__Application__r.Crop_Year__c=:cropYear];
                    if(allList.size()==0){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,ConstantValues.NTB_NOAPPLICATION));
                    }
                    for(clcommon__party__c objPartyId: allList){
                        SelectedApplication selAppobj = new SelectedApplication(objPartyId,true);
                        selectApps.add(selAppobj);

                    }
                }
            }
        }
        catch (Exception objException) {
            if(clcommon__Log__c.SObjectType.getDescribe().isCreateable()){
                PortalHelper.saveExceptionLog(objException, controllerClassName);
            }
        } 
    }
    /**
    * @description : unused 
    * @author  Pritam Roy | 03-04-2024
    **/
    public Boolean disableSaveButton {
        get {
            return hasBeenClickedAlready;
        }
    }
    /**
    * @description : Returns page reference and process NTB
    * @author  Pritam Roy | 03-04-2024 
    * @return pageReference 
    **/
    public pageReference processNTB() {
        //Check for Profiles
        Id profileId = UserInfo.getProfileId(); 
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        if(profileName.equalsIgnoreCase(ConstantValues.PROFILE_ADMIN) || 
        profileName.equalsIgnoreCase(ConstantValues.PROFILE_CFA_ADMIN) || 
        profileName.equalsIgnoreCase(ConstantValues.PROFILE_CREDIT)){
            newApps = new List<clcommon__Party__c>();
            for(selectedApplication appSelected : selectApps) {
                if (appSelected.appIdFlag == true) {
                    newApps.add(appSelected.appSelected);
                }
            }
            if(String.isBlank(cropYear)){

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ConstantValues.NTB_BLANK_CROPYEAR));
            }
            else{
                List<Id> partyApplicationId=new List<Id>();
                List<clcommon__party__c> clpartyappList =[SELECT Id,
                                                                genesis__Application__c 
                                                            FROM clcommon__Party__c 
                                                            WHERE Id IN :newApps ];

                for(clcommon__party__c objPartyId: clpartyappList){
                    partyApplicationId.add(objPartyId.genesis__Application__c);
                }
                List<clcommon__party__c> clpartyBorrowerCoBorrower=[SELECT Id,
                                                                            Marked_NTB_Annual_Summary__c 
                                                                        FROM clcommon__Party__c 
                                                                        WHERE genesis__Application__r.Id IN:partyApplicationId
                                                                        AND clcommon__Type__r.Name 
                                                                        IN (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME) ORDER BY createdDate];
                for(clcommon__party__c objPartyId: clpartyBorrowerCoBorrower){
                    objpartyId.Marked_NTB_Annual_Summary__c=true;
                }
                if(clcommon__Party__c.SObjectType.getDescribe().isUpdateable()){
                    Database.update(clpartyBorrowerCoBorrower,true);
                }
                hasBeenClickedAlready = true;
                EarlyNoticeToBuyers.earlyNotices(newApps); 
                String retPage = String.valueOf(URL.getSalesforceBaseUrl().toExternalForm()) + APPLICATION_LIST_URL  ;
                PageReference retPageRef = new PageReference(retPage);
                return retPageRef;
            }
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ConstantValues.INSUFFICIENT_ACCESS));
            return null;
        }
        
        return null;
        
    }
}