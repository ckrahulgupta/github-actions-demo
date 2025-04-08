/**
 * @description       : This class adds a new Potential Buyer and choose an existing buyer and create a party for the application
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-12-2024
 * @last modified by  :  Pritam Roy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   13-07-2022   Subham Nandi   Initial Version
**/
global without sharing class PortalSavePotentialBuyerAPI implements clcommon.PortalCustomRemoteAPI1{
    // Constants specific to this class -------------------- -------------------- --------------------
    private static final String CLASS_NAME = 'PortalSavePotentialBuyerAPI';
    private static final String IS_NEW_BUYER = 'isNewBuyer';
    private static final String NEW_BUYER = 'buyerDetails';
    private static final String BUYER_LIST = 'existingBuyerList';
    private static final String KEY_APPLICATION = 'applicationId';
    private static final String FIELD_ACCOUNT_NAME = 'clcommon__Account__r.Name';
    private static final String FIELDS_ACCOUNT_STREET = 'clcommon__Account__r.BillingStreet';
    private static final String FIELDS_ACCOUNT_CITY = 'clcommon__Account__r.BillingCity';
    private static final String FIELDS_ACCOUNT_STATE = 'clcommon__Account__r.BillingState';
    private static final String FIELDS_ACCOUNT_POSTAL_CODE = 'clcommon__Account__r.BillingPostalCode';
    // Constants specific to this class -------------------- -------------------- --------------------
    Boolean isNewBuyer;
    Boolean isValidUser;
    clcommon.Response response = new clcommon.Response();
    String applicationId = '';
    String newPotentialBuyer = '';
    String potentialBuyerList = '';

    /**
    * @description : Method called from portal to create/use a Potential Buyer and create party
    * @author  Pritam Roy | 03-12-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param requestFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames, 
                                                Map<String, Object> requestFromPortal)  {
        SavePoint dbSavePoint = Database.setSavepoint();
        try{
            //Fetching the flag to add a new Potential Buyer or using an existing potential buyer
            isNewBuyer = Boolean.valueOf(requestFromPortal.get(IS_NEW_BUYER));
            applicationId = String.valueOf(requestFromPortal.get(KEY_APPLICATION));
            if(String.isBlank(applicationId)){
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            isValidUser = PortalSecurityUtil.validateUserApplication(applicationId); 
            if (!isValidUser) {
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }
            if(isNewBuyer){
                //Fetching the details of a new potential buyer
                newPotentialBuyer = String.valueOf(requestFromPortal.get(NEW_BUYER));
                List<Object> objBuyerAccount = (List<Object>) Json.deserializeUntyped(newPotentialBuyer);
                Map<String,Object> buyerMap = new Map<String,Object>();
                for(Object eachBuyer : objBuyerAccount){
                    buyerMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(eachBuyer));
                    if(String.isBlank((String) buyerMap.get(FIELD_ACCOUNT_NAME))
                            ||String.isBlank((String) buyerMap.get(FIELDS_ACCOUNT_STREET))
                            ||String.isBlank((String) buyerMap.get(FIELDS_ACCOUNT_CITY))
                            ||String.isBlank((String) buyerMap.get(FIELDS_ACCOUNT_STATE))
                            ||String.isBlank((String) buyerMap.get(FIELDS_ACCOUNT_POSTAL_CODE))){
                        throw new CustomException(PortalConstants.BUYER_DETAILS_MISSING);
                    }
                }
                if(!buyerMap.isEmpty()){
                    PortalHelper.saveAdditionalInfoDetails(buyerMap, applicationId, PortalConstants.BUYER_PARTY_NAME);
                }
            }
            else{
                if(requestFromPortal.get(BUYER_LIST) == null){
                    throw new CustomException(PortalConstants.EXISTING_BUYER_ERROR);
                }
                List<String> listOfAccountIds = new List<String>();
                List<clcommon__Party__c> listOfPartyToInsert = new List<clcommon__party__c>();
                Map<String,String> partyToAccountMap = new Map<String,String>();
                //Get the existing parties for the application
                List<clcommon__Party__c> exisitngPartiesList = [SELECT Id,
                                                                        clcommon__Account__c
                                                                FROM clcommon__Party__c
                                                                WHERE genesis__Application__c = :applicationId];
                for(clcommon__Party__c eachPartyObj : exisitngPartiesList){
                    partyToAccountMap.put(String.valueOf(eachPartyObj.clcommon__Account__c),'Account');
                }
                //Fetch list of potential buyer account ids
                potentialBuyerList = String.valueOf(requestFromPortal.get(BUYER_LIST));
                List<Object> accountIdList = (List<Object>) Json.deserializeUntyped(potentialBuyerList);
                for(Object objAccount : accountIdList){
                    listOfAccountIds.add(String.valueOf(objAccount));
                }
                //query all the accounts that were chosen as the Potential Buyers
                List<Account> objAccountList = [SELECT Id
                                                FROM Account 
                                                WHERE Id IN : listOfAccountIds];
                List<Contact> objContactList = [SELECT Id,
                                                        AccountId
                                                FROM Contact
                                                WHERE AccountId IN : listOfAccountIds];
                Map<Id,Id> accountToContactIdMap = new Map<Id,Id>();
                for(Contact objContact : objContactList){
                    accountToContactIdMap.put(objContact.AccountId , objContact.Id);
                }
                //Get the party type
                List<clcommon__Party_Type__c> partyType = [SELECT Id
                                                            FROM clcommon__Party_Type__c
                                                            WHERE Name = :PortalConstants.BUYER_PARTY_NAME];
                for(Account objAccount : objAccountList){
                    if(partyToAccountMap.containsKey((String)objAccount.Id)){
                        continue;
                    }
                    clcommon__Party__c objParty = new clcommon__Party__c();
                    objParty.clcommon__Account__c = objAccount.Id;
                    objParty.clcommon__Contact__c = accountToContactIdMap.get(objAccount.Id);
                    objParty.genesis__Application__c = applicationId;
                    objParty.clcommon__Type__c = partyType[0].Id;
                    objParty.clcommon__Party_Types__c = PortalConstants.BUYER_PARTY_NAME;
                    listOfPartyToInsert.add(objParty);
                }
                Database.insert(listOfPartyToInsert);
            }
            genesis__Applications__c objApplicationToUpdate = [ SELECT  Id,
                                                                        Additional_Information_Needed__c 
                                                                FROM genesis__Applications__c
                                                                WHERE Id = :applicationId];
            objApplicationToUpdate.Additional_Information_Needed__c = true;
            Database.update(objApplicationToUpdate,true);
            response.status = clcommon.Constants.SUCCESS;

        }
        catch(CustomException objCustomException){
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, CLASS_NAME);
        }
        catch(Exception objException){
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objException.getMessage();
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response;
    }

}