/**
 * @description       : Controller for Loan Payoff VF Page
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 22-01-2025
 * @last modified by  : Soumik Pattanayak
**/
public without sharing class LoanPayoffController {
    private static final String PORTAL_EXPORT_API = 'PortalExportAPI';
    private static final String KEY_NOT_APPLICABLE = 'N/A';
    private static final String KEY_PRINCIPAL = 'PRINCIPAL';
    private static final String KEY_BORROWER = 'BORROWER';
    private static final String DOLLAR = '$';
    private static final String APP_ID = 'appid';
    private static final String RESOURCE_KEY = '/resource/';

    /**
 * @description       : Getter Setter for Date
 * @author            : Ayush Kumar Singh
 * **/
    public String todayDate{get;set;}
    /**
 * @description       : Getter Setter for Coop Type
 * @author            : Soumik Pattanayak
 * **/
    public String coopType{get;set;}
    /**
 * @description       : Getter Setter for logo
 * @author            : Soumik Pattanayak
 * **/
    public String logo{get;set;}
    /**
 * @description       : Getter Setter for LoanNumber
 * @author            : Ayush Kumar Singh
 * **/
    public String loanNumber{get;set;}
    /**
 * @description       : Getter Setter for  maturity Date
 * @author            : Ayush Kumar Singh
 * **/
    public String maturityDate{get;set;}
    /**
 * @description       : Getter Setter for Principal Balance
 * @author            : Ayush Kumar Singh
 * **/
    public String principalBalance{get;set;}
    /**
 * @description       : Getter Setter for Name
 * @author            : Ayush Kumar Singh
 * **/
    public String name{get;set;}
    /**
 * @description       : Getter Setter for Street
 * @author            : Ayush Kumar Singh
 * **/
    public String street{get;set;}
    /**
 * @description       : Getter Setter  for city
 * @author            : Ayush Kumar Singh
 * **/
    public String city{get;set;}
    /**
 * @description       : Getter Setter for Payoff Date
 * @author            : Ayush Kumar Singh
 * **/
    public String payOffDate{get;set;}
    /**
 * @description       : Getter Setter for Interest Accrued
 * @author            : Ayush Kumar Singh
 * **/
    public String interestAccrued{get;set;}
    /**
 * @description       : Getter Setter for Perdiem
 * @author            : Ayush Kumar Singh
 * **/
    public String perDiem{get;set;}
    /**
 * @description       : Getter Setter for Payoff Amount
 * @author            : Ayush Kumar Singh
 * **/
    public String payOffAmount{get;set;}
    /**
 * @description       : Getter setter for note date
 * @author            : Ayush Kumar Singh
 * **/
    public String noteDate{get;set;}
    /**
 * @description       : Getter Setter for partyList
 * @author            : Ayush Kumar Singh
 * **/
    public List<clcommon__Party__c> principal{get;set;}



    /**
 * @description       : Constructor to initialize
 * @author            : Ayush Kumar Singh
 * **/
    public LoanPayoffController() {
        String appId = Apexpages.currentPage().GetParameters().Get(APP_ID).escapeHtml4();
        vfPageController(appId);
        
    }
    /**
    * @description : Get all data required for LoanPayoff vfpage
    * @author  Pritam Roy | 03-14-2024 
    * @param recordId 
    **/
    public void vfPageController(String recordId){
        Date setTodayDate =Date.today();
        TodayDate = setTodayDate.month()+PortalConstants.SLASH_STRING+setTodayDate.day()+PortalConstants.SLASH_STRING+setTodayDate.year();
        List<clcommon__Party__c> recordPartyList = new List<clcommon__Party__c>();
        List<clcommon__Party__c> recordList = new List<clcommon__Party__c>();
        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        List<clcommon__Party__c> dealerPartyList = new List<clcommon__Party__c>();
        try{
            //getRecordListAndPartyList(recordList,partyList);
            if(clcommon__Party__c.SObjectType.getDescribe(SObjectDescribeOptions.FULL).isAccessible()){
                recordPartyList = [SELECT 
                                        Id,
                                        genesis__Application__r.Interest__c,
                                        genesis__Application__r.Note_Date__c,
                                        genesis__Application__r.Pay_Off_Date__c,
                                        genesis__Application__r.Interest_Per_Diem__c,
                                        genesis__Application__r.genesis__Loan_Number__c,
                                        Street__c,
                                        City__c,
                                        State__c,
                                        Postal_Code__c,
                                        County__c,
                                        clcommon__Account__r.Name,
                                        clcommon__Type__r.Name,
                                        genesis__Application__r.genesis__Maturity_Date__c,
                                        genesis__Application__r.Payoff_Amount_via_Mobile__c,
                                        genesis__Application__r.Current_Principal_Balance__c,
                                        clcommon__Account__r.Coop_Type__c,
                                        clcommon__Account__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c
                                FROM clcommon__Party__c
                                WHERE  genesis__Application__c = :recordId];
            }
            for(clcommon__party__c eachParty : recordPartyList){
                if(eachParty.clcommon__Type__r.Name == KEY_BORROWER){
                    recordList.add(eachParty);
                }else if(eachParty.clcommon__Type__r.Name == KEY_PRINCIPAL){
                    partyList.add(eachParty);
                }else if(eachParty.clcommon__Type__r.Name == PortalConstants.DEALER_PARTY_NAME){
                    dealerPartyList.add(eachParty);
                }
            }
            

            coopType = getCoopType(dealerPartyList);

            logo = getLogo(dealerPartyList);

            loanNumber = getLoanNumber(recordList);
                
            maturityDate = getMaturityDate(recordList);
            
            principalBalance = getPrincipalBalance(recordList);

            payOffDate = getPayOffDate(recordList);

            interestAccrued = getInterestAccrued(recordList);
            
            perDiem = getPerDiem(recordList);
            
            noteDate = getNoteDate(recordList);
            
            name = getName(recordList);
            
            street = getStreet(recordList);
             
            city = getCity(recordList);
            
            payOffAmount = getPayOffAmount(recordList);
            
            principal = getPrincipal(partyList);
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, LoanPayoffController.class.getName());
        }
    }
    /**
    * @description get the coop type
    * @author Soumik Pattanayak | 16-10-2024 
    * @param recordList 
    * @return String 
    **/
    private static String getCoopType(List<clcommon__Party__c> recordList){
        if(recordList[0].clcommon__Account__r.Coop_Type__c != null){
            return recordList[0].clcommon__Account__r.Coop_Type__c;
        }return null;
    }
    /**
    * @description get the logo
    * @author Soumik Pattanayak | 16-10-2024 
    * @param recordList 
    * @return String 
    **/
    public String getLogo(List<clcommon__Party__c> recordList){
        if(recordList[0].clcommon__Account__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c!= null){
            return RESOURCE_KEY+recordList[0].clcommon__Account__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c;
        }return null;
    }
    /**
    * @description get the loan number
    * @author Soumik Pattanayak | 16-10-2024 
    * @param recordList 
    * @return String 
    **/
    private static String getLoanNumber(List<clcommon__Party__c> recordList){
        if(recordList[0].genesis__Application__r.genesis__Loan_Number__c != null){
            return recordList[0].genesis__Application__r.genesis__Loan_Number__c;
        }return null;
    }
    /**
    * @description get the Maturity date
    * @author Soumik Pattanayak | 16-10-2024 
    * @param recordList 
    * @return String 
    **/
    private static String getMaturityDate(List<clcommon__Party__c> recordList){
        if(recordList[0].genesis__Application__r.genesis__Maturity_Date__c != null){
            Date setmaturityDate =(Date)recordList[0].genesis__Application__r.genesis__Maturity_Date__c;
            return setmaturityDate.month()+PortalConstants.SLASH_STRING+setmaturityDate.day()+PortalConstants.SLASH_STRING+setmaturityDate.year();
        }return null;
    }
    /**
    * @description get the principal balance
    * @author Soumik Pattanayak | 16-10-2024 
    * @param recordList 
    * @return String 
    **/
    private static String getPrincipalBalance(List<clcommon__Party__c> recordList){
        if(recordList[0].genesis__Application__r.Current_Principal_Balance__c != null){
            String currentPrincipalBalance = String.valueOf((recordList[0].genesis__Application__r.Current_Principal_Balance__c.setScale(2)+0.001).format());
            return DOLLAR + currentPrincipalBalance.substring(0,currentPrincipalBalance.length()-1);
        }return null;
    }
    /**
    * @description get the pay off date
    * @author Soumik Pattanayak | 16-10-2024 
    * @param recordList 
    * @return String 
    **/
    private static String getPayOffDate(List<clcommon__Party__c> recordList){
        if(recordList[0].genesis__Application__r.Pay_Off_Date__c != null){
            Date setpayoffDate =(Date)recordList[0].genesis__Application__r.Pay_Off_Date__c;
            return setpayoffDate.month()+PortalConstants.SLASH_STRING+setpayoffDate.day()+PortalConstants.SLASH_STRING+setpayoffDate.year();
        }return KEY_NOT_APPLICABLE;
    }
    /**
    * @description get the interest accured
    * @author Soumik Pattanayak | 16-10-2024 
    * @param recordList 
    * @return String 
    **/
    private static String getInterestAccrued(List<clcommon__Party__c> recordList){
        if(recordList[0].genesis__Application__r.Interest__c != null){
            String interest = String.valueOf((recordList[0].genesis__Application__r.Interest__c.setScale(2)+0.001).format());
            return DOLLAR + interest.substring(0,interest.length()-1);
        }return null;
    }
    /**
    * @description get the interest per diem
    * @author Soumik Pattanayak | 16-10-2024 
    * @param recordList 
    * @return String 
    **/
    private static String getPerDiem(List<clcommon__Party__c> recordList){
        if(recordList[0].genesis__Application__r.Interest_Per_Diem__c != null){
            String interest = String.valueOf((recordList[0].genesis__Application__r.Interest_Per_Diem__c.setScale(2)+0.001).format());
            return  DOLLAR + interest.substring(0,interest.length()-1);
        }return KEY_NOT_APPLICABLE;
    }
    /**
    * @description ge the Note date
    * @author Soumik Pattanayak | 16-10-2024 
    * @param recordList 
    * @return String 
    **/
    private static String getNoteDate(List<clcommon__Party__c> recordList){
        if(recordList[0].genesis__Application__r.Note_Date__c != null){
            Date setNoteDate =(Date)recordList[0].genesis__Application__r.Note_Date__c;
            return setNoteDate.month()+PortalConstants.SLASH_STRING+ setNoteDate.day()+PortalConstants.SLASH_STRING+ setNoteDate.year();
        }return KEY_NOT_APPLICABLE;
    }
    /**
    * @description get the Name
    * @author Soumik Pattanayak | 16-10-2024 
    * @param recordList 
    * @return String 
    **/
    private static String getName(List<clcommon__Party__c> recordList){
        if(recordList[0].clcommon__Account__r.name != null){
            return recordList[0].clcommon__Account__r.name;
        }return null;
    }
    /**
    * @description get the the street
    * @author Soumik Pattanayak | 16-10-2024 
    * @param recordList 
    * @return String 
    **/
    private static String getStreet(List<clcommon__Party__c> recordList){
        if(recordList[0].Street__c != null){
            return String.valueOf(recordList[0].Street__c);
        }return null;
    }
    /**
    * @description get the city
    * @author Soumik Pattanayak | 16-10-2024 
    * @param recordList 
    * @return String 
    **/
    private static String getCity(List<clcommon__Party__c> recordList){
        if(recordList[0].City__c != null && recordList[0].State__c != null && recordList[0].Postal_Code__c != null){
            return String.valueOf(recordList[0].City__c)+PortalConstants.SPACE_STRING+String.valueOf(recordList[0].State__c)+PortalConstants.SPACE_STRING+String.valueOf(recordList[0].Postal_Code__c);
        }return null;
    }
    /**
    * @description get the pay off amount
    * @author Soumik Pattanayak | 16-10-2024 
    * @param recordList 
    * @return String 
    **/
    private static String getPayOffAmount(List<clcommon__Party__c> recordList){
        if(recordList[0].genesis__Application__r.Payoff_Amount_via_Mobile__c != null){
            String amount = String.valueOf((recordList[0].genesis__Application__r.Payoff_Amount_via_Mobile__c.setScale(2)+0.001).format());
            return DOLLAR + amount.substring(0,amount.length()-1);
        }return null;
    }
    /**
    * @description get the principal
    * @author Soumik Pattanayak | 16-10-2024 
    * @param partyList 
    * @return List<clcommon__Party__c> 
    **/
    private static List<clcommon__Party__c> getPrincipal(List<clcommon__Party__c> partyList){
        if(partyList.size()>0){
            return partyList;
        }return null;
    }
    
}