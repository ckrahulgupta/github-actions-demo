/**
 * @description       : Batch class for creating neccessary data sets for historical data.
 * @author            : Ayan Bhowmik
 * @group             : 
 * @last modified on  : 02-17-2025
 * @last modified by  : Ayan Bhowmik
**/
global with sharing class CreateRecordsForHistoricalDataBatch implements Database.Batchable<sObject> {
    public static final String CLASS_NAME = CreateRecordsForHistoricalDataBatch.class.getName();
    String operationType;
    List<Id> idList;
    /**
    * @description 
    * @author Ayan Bhowmik | 02-13-2025 
    * @param operationType
    * @param idList
    **/
    global CreateRecordsForHistoricalDataBatch(String operationType, List<Id> idList) {
        this.operationType = operationType;
        this.idList = idList;
    }

    /**
    * @description 
    * @author Ayan Bhowmik | 02-13-2025 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext bc){
        if(operationType != null && idList != null && !idList.isEmpty()){
            if(operationType == 'Dealer_Applicant_Relationship__c'){
                return Database.getQueryLocator(
                    [
                        SELECT Id, 
                            genesis__Account__c,
                            genesis__Contact__c,
                            Dealer_Name__c, 
                            Dealer_Applicant_Relationship__c,
                            genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                            (
                                SELECT Id,  
                                    clcommon__Account__r.Is_Evergreen_Allowed__c,
                                    clcommon__Account__r.Non_Accrual__c,
                                    clcommon__Account__r.Has_Past_Due__c,
                                    clcommon__Account__r.BillingStreet,
                                    clcommon__Account__r.BillingCity,
                                    clcommon__Account__r.BillingState,
                                    clcommon__Account__r.BillingPostalCode,
                                    clcommon__Account__r.Billing_County__c,
                                    clcommon__Account__r.Work_Number__c,
                                    clcommon__Account__r.Home_Number__c,
                                    clcommon__Account__r.Phone,
                                    clcommon__Account__r.genesis__Business_Information__r.Gross_Farm_Income__c,
                                    clcommon__Contact__r.MailingStreet,
                                    clcommon__Contact__r.MailingCity,
                                    clcommon__Contact__r.MailingState,
                                    clcommon__Contact__r.MailingPostalCode,
                                    clcommon__Contact__r.Mailing_County__c,
                                    clcommon__Contact__r.HomePhone,
                                    clcommon__Contact__r.MobilePhone,
                                    clcommon__Contact__r.Phone,
                                    clcommon__Contact__r.clcommon__Marital_Status__c,
                                    clcommon__Contact__r.Title,
                                    clcommon__Contact__r.Suffix__c,
                                    clcommon__Contact__c,
                                    clcommon__Account__c,
                                    clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name
                                FROM genesis__Parties__r 
                                WHERE clcommon__Type__r.Name IN ('BORROWER', 'PRINCIPAL')
                                AND clcommon__Account__c != null
                                AND clcommon__Contact__c != null
                            )
                        FROM genesis__Applications__c
                        WHERE Id IN :idList
                    ]
                );
            }
        }
        else {
            return Database.getQueryLocator(
                [
                    SELECT Id, 
                        genesis__Account__c,
                        genesis__Contact__c,
                        Dealer_Name__c, 
                        Dealer_Applicant_Relationship__c,
                        genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                        (
                            SELECT Id,  
                                clcommon__Account__r.Is_Evergreen_Allowed__c,
                                clcommon__Account__r.Non_Accrual__c,
                                clcommon__Account__r.Has_Past_Due__c,
                                clcommon__Account__r.BillingStreet,
                                clcommon__Account__r.BillingCity,
                                clcommon__Account__r.BillingState,
                                clcommon__Account__r.BillingPostalCode,
                                clcommon__Account__r.Billing_County__c,
                                clcommon__Account__r.Work_Number__c,
                                clcommon__Account__r.Home_Number__c,
                                clcommon__Account__r.Phone,
                                clcommon__Account__r.genesis__Business_Information__r.Gross_Farm_Income__c,
                                clcommon__Contact__r.MailingStreet,
                                clcommon__Contact__r.MailingCity,
                                clcommon__Contact__r.MailingState,
                                clcommon__Contact__r.MailingPostalCode,
                                clcommon__Contact__r.Mailing_County__c,
                                clcommon__Contact__r.HomePhone,
                                clcommon__Contact__r.MobilePhone,
                                clcommon__Contact__r.Phone,
                                clcommon__Contact__r.clcommon__Marital_Status__c,
                                clcommon__Contact__r.Title,
                                clcommon__Contact__r.Suffix__c,
                                clcommon__Contact__c,
                                clcommon__Account__c,
                                clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name
                            FROM genesis__Parties__r 
                            WHERE clcommon__Type__r.Name IN ('BORROWER', 'PRINCIPAL')
                            AND clcommon__Account__c != null
                            AND clcommon__Contact__c != null
                        )
                    FROM genesis__Applications__c
                    WHERE Dealer_Applicant_Relationship__c = null
                    AND genesis__Contact__c != null
                    AND genesis__Account__c != null
                    AND Dealer_Name__c != null
                    ORDER BY LastModifiedDate ASC
                ]
            );
        }
        return null;
    }

    /**
    * @description 
    * @author Ayan Bhowmik | 02-13-2025 
    * @param bc 
    * @param allApplications 
    **/
    global void execute(Database.BatchableContext bc, List<genesis__Applications__c> allApplications){
        Set<String> growerSet = new Set<String>();
        Set<String> dealerSet = new Set<String>();
        
        for (genesis__Applications__c application : allApplications) {
        
            for (clcommon__Party__c party : application.genesis__Parties__r) {
                growerSet.add(party.clcommon__Account__c);
                dealerSet.add(application.Dealer_Name__c);
            }
        }
        List<String> growerList = new List<String>(growerSet);
        List<String> dealerList = new List<String>(dealerSet);
        
        Map<String, Dealer_Applicant_Relationship__c> drMap = new Map<String, Dealer_Applicant_Relationship__c>();
        Map<String, String> applicationToGrowerDR = new Map<String, String>();
        Map<String, String> partyToDR = new Map<String, String>();
        List<clcommon__Party__c> updatedParties = new List<clcommon__Party__c>();
        SavePoint dbSavePoint = Database.setSavepoint();
        try {
        
            List<Dealer_Applicant_Relationship__c> drs = [
                SELECT Id,
                    Applicant__c,
                    Applicant_Contact__c,
                    Dealer__c
                FROM Dealer_Applicant_Relationship__c 
                WHERE Dealer__c IN :dealerList
                AND Applicant__c IN :growerList
            ];
            
            // prepopulate the DR map with the existing DR records
            for (Dealer_Applicant_Relationship__c dr : drs) {
                String key = dr.Applicant__c + '-' + dr.Applicant_Contact__c + '-' + dr.Dealer__c;
                drMap.put(key, dr);
            }
            
            for (genesis__Applications__c application : allApplications) {
            
                for (clcommon__Party__c party : application.genesis__Parties__r) {
                    String key = party.clcommon__Account__c + '-' + party.clcommon__Contact__c + '-' + application.Dealer_Name__c;
            
                    // if primary applicant
                    if (party.clcommon__Account__c == application.genesis__Account__c &&
                        party.clcommon__Contact__c == application.genesis__Contact__c) {
            
                        applicationToGrowerDR.put(application.Id, key);
                    }
            
                    partyToDR.put(party.Id, key);
            
            
                    if (drMap.containsKey(key)) {
                        continue;
                    }
            
                    Dealer_Applicant_Relationship__c dr = new Dealer_Applicant_Relationship__c();
                    dr.Dealer__c = application.Dealer_Name__c;
                    dr.Applicant__c = party.clcommon__Account__c;
                    dr.Applicant_Contact__c = party.clcommon__Contact__c;
                    dr.Is_Evergreen_Eligible__c = party.clcommon__Account__r.Is_Evergreen_Allowed__c;
                    dr.Is_Non_Accrual__c = party.clcommon__Account__r.Non_Accrual__c;
                    dr.Has_Past_Due__c = party.clcommon__Account__r.Has_Past_Due__c;
            
                    drMap.put(key, dr);
            
                }
            }
            
            Database.upsert(drMap.values(), true);
            
            for (genesis__Applications__c application : allApplications) {
            
                for (clcommon__Party__c party : application.genesis__Parties__r) {
            
                    if (!applicationToGrowerDR.containsKey(application.Id)) {
                        continue;
                    }
            
                    if (!partyToDR.containsKey(party.Id)) {
                        continue;
                    }
            
            
                    // update the party records with the account and contact data
                    clcommon__Party__c updatedParty = new clcommon__Party__c(Id = party.Id);
            
                    // for individual
                    if (party.clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name == PortalConstants.SOLE_PROP_ENTITY) {
                        
                        updatedParty.Street__c = party.clcommon__Contact__r?.MailingStreet;
                        updatedParty.City__c = party.clcommon__Contact__r?.MailingCity;
                        updatedParty.State__c = party.clcommon__Contact__r?.MailingState;
                        updatedParty.Postal_Code__c = party.clcommon__Contact__r?.MailingPostalCode;
                        updatedParty.County__c = party.clcommon__Contact__r?.Mailing_County__c;
                        updatedParty.Title__c = party.clcommon__Contact__r?.Title;
                        updatedParty.Suffix__c = party.clcommon__Contact__r?.Suffix__c;
                        updatedParty.Marital_Status__c = party.clcommon__Contact__r?.clcommon__Marital_Status__c;
                        updatedParty.Gross_Farm_Income__c = party.clcommon__Account__r?.genesis__Business_Information__r?.Gross_Farm_Income__c;
            
                        updatedParty.Home_Number__c = party.clcommon__Contact__r?.HomePhone;
                        updatedParty.Work_Number__c = party.clcommon__Contact__r?.Phone;
                        updatedParty.Mobile_Number__c = party.clcommon__Contact__r?.MobilePhone;
            
                    } else if (party.clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name == PortalConstants.INDIVIDUAL_ENTITY) {
            
                        updatedParty.Street__c = party.clcommon__Account__r?.BillingStreet;
                        updatedParty.City__c = party.clcommon__Account__r?.BillingCity;
                        updatedParty.State__c = party.clcommon__Account__r?.BillingState;
                        updatedParty.Postal_Code__c = party.clcommon__Account__r?.BillingPostalCode;
                        updatedParty.County__c = party.clcommon__Account__r?.Billing_County__c;
                        updatedParty.Title__c = party.clcommon__Contact__r?.Title;
                        updatedParty.Suffix__c = party.clcommon__Contact__r?.Suffix__c;
                        updatedParty.Marital_Status__c = party.clcommon__Contact__r?.clcommon__Marital_Status__c;
                        updatedParty.Gross_Farm_Income__c = party.clcommon__Account__r?.genesis__Business_Information__r?.Gross_Farm_Income__c;
            
                        updatedParty.Work_Number__c = party.clcommon__Account__r?.Work_Number__c;
                        updatedParty.Home_Number__c = party.clcommon__Account__r?.Home_Number__c;
                        updatedParty.Mobile_Number__c = party.clcommon__Account__r?.Phone;
            
                    } else {
            
                        updatedParty.Street__c = party.clcommon__Account__r?.BillingStreet;
                        updatedParty.City__c = party.clcommon__Account__r?.BillingCity;
                        updatedParty.State__c = party.clcommon__Account__r?.BillingState;
                        updatedParty.Postal_Code__c = party.clcommon__Account__r?.BillingPostalCode;
                        updatedParty.County__c = party.clcommon__Account__r?.Billing_County__c;
                        updatedParty.Title__c = party.clcommon__Contact__r?.Title;
                        updatedParty.Suffix__c = party.clcommon__Contact__r?.Suffix__c;
                        updatedParty.Marital_Status__c = party.clcommon__Contact__r?.clcommon__Marital_Status__c;
                        updatedParty.Gross_Farm_Income__c = party.clcommon__Account__r?.genesis__Business_Information__r?.Gross_Farm_Income__c;
            
                        updatedParty.Work_Number__c = party.clcommon__Account__r?.Work_Number__c;
                        updatedParty.Home_Number__c = party.clcommon__Account__r?.Home_Number__c;
                        updatedParty.Mobile_Number__c = party.clcommon__Account__r?.Phone;
                    }
            
                    updatedParty.Dealer_Applicant_Relationship__c = drMap.get(partyToDR.get(updatedParty.Id)).Id;
            
                    updatedParties.add(updatedParty);
            
                    application.Dealer_Applicant_Relationship__c = drMap.get(applicationToGrowerDR.get(application.Id)).Id;
            
                    
                }
            }
            
            Database.update(updatedParties, true);
            Database.update(allApplications, true);
        }catch (Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            PortalHelper.saveExceptionLog(exceptionObj, CreateRecordsForHistoricalDataBatch.class.getName());
        }
    }

    /**
    * @description 
    * @author Ayan Bhowmik | 02-13-2025 
    * @param bc 
    **/
    global void finish(Database.BatchableContext bc){
    }
}