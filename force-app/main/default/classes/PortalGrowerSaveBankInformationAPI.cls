/**
 * @description       : Saves the bank information for a particular grower profile
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 22-06-2022
 * @last modified by  : Rahul Gupta
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   29-03-2022   Subham Nandi   Initial Version
**/
global without sharing class PortalGrowerSaveBankInformationAPI implements clcommon.PortalCustomRemoteAPI1{
    // Constant parameters specific for this class starts
    private static final String BANK_INFORMATION = 'bankInformation';
    private static final String FIELD_ID = 'id';
    private static final String NEW_RECORD_STRING = 'new_record_Id';
    private static final String FIELD_ACCOUNT_NUMBER = 'clcommon__Bank_Account_Number__c';
    private static final String FIELD_ACCOUNT_NAME = 'clcommon__Bank_Account_Name__c';
    private static final String FIELD_ACCOUNT_TYPE = 'clcommon__Account_Type__c';
    private static final String FIELD_ROUTING = 'clcommon__Routing_Number__c';
    private static final String FIELD_BANK_NAME = 'clcommon__Bank_Name__c';
    private static final String FIELD_BANK_PHONE = 'clcommon__Bank__r.clcommon__Phone_Number__c';
    private static final String FIELD_BANK_ADDR = 'clcommon__Bank__r.clcommon__Address__r.clcommon__Street_Address__c';
    private static final String FIELD_BANK_CITY = 'clcommon__Bank__r.clcommon__Address__r.clcommon__City__c';
    private static final String FIELD_BANK_STATE = 'clcommon__Bank__r.clcommon__Address__r.clcommon__State_Province__c';
    private static final String FIELD_BANK_ZIP = 'clcommon__Bank__r.clcommon__Address__r.clcommon__Zip_Code__c';
    private static final String FIELD_BANK_ID = 'clcommon__Bank__c';
    private static final String FIELD_BANK_ADDR_ID = 'clcommon__Bank__r.clcommon__Address__c';
    private static final String KEY_BANK_ACCOUNT_ID = 'bankId';
    // Constant parameters specific for this class ends
    // declaration specific to this class
    String bankInfo;
    String contactId = '';
    String accountId = '';
    Object bankAccountId = '';
    String bankId = '';
    String addressId = '';
    Map<String, Object> responseFieldMap = new Map<String, Object>();
    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();

    global clcommon.Response invokeAction(String componentStrName,
                                        String[] disclosureNames,
                                        Map<String, Object> requestParamMap) {
        //get the data from the portal and upsert all the bank accounts one might use
        SavePoint dbSavePoint = Database.setSavepoint();
        List<Object> objbankInfoList = new List<Object>();
        Map<String,Object> mapOfBankInfo = new Map<String,Object>();
        List<clcommon__Bank_Account__c> bankAccountsToSaveList = new List<clcommon__Bank_Account__c>();
        try {
            if(requestParamMap.get(BANK_INFORMATION) == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            //Get the logged in user
            List<User> loggedInUserContactList =   [SELECT  Id,
                                                            ContactId
                                                    FROM USER
                                                    WHERE Id = :UserInfo.getUserId()];
            if(loggedInUserContactList == null || loggedInUserContactList.size() == 0){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }                            
            contactId = loggedInUserContactList[0].ContactId;
            List<Contact> loggedInUserAccount = [SELECT Id, 
                                                        AccountId
                                                FROM Contact
                                                WHERE Id = :contactId];
            if(loggedInUserAccount == null || loggedInUserAccount.size() == 0){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }                                
            accountId = loggedInUserAccount[0].AccountId;
            //Get the List of Bank Account Informations in a string
            bankInfo = String.valueOf(requestParamMap.get(BANK_INFORMATION));
            //Deserialise the string to a list of objects
            if(!String.isBlank(bankInfo)){
                objbankInfoList = (List<Object>) Json.deserializeUntyped(bankInfo);
            }

            if (objbankInfoList.size() == 0) {
                throw new CustomException(PortalConstants.BANK_RECORDS_MISSING);
            }
            
            for(Object objEachBankInfo : objbankInfoList){
                mapOfBankInfo = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(objEachBankInfo));
                clcommon__Bank_Account__c bankAccountObject = new clcommon__Bank_Account__c();
                clcommon__Bank__c bankObject = new clcommon__Bank__c();
                clcommon__Address__c addressObject = new clcommon__Address__c();
                

                //get the bank info ID
                String bankInfoId = (String)mapOfBankInfo.get(FIELD_ID);
                String bankId = (String)mapOfBankInfo.get(FIELD_BANK_ID);
                String addressId = (String)mapOfBankInfo.get(FIELD_BANK_ADDR_ID);


                if(bankInfoId == NEW_RECORD_STRING || bankInfoId == null){
                    bankAccountObject.Id = null;
                }
                else{
                    bankAccountObject.Id = bankInfoId;                
                }

                bankObject.Id = bankId;
                addressObject.Id = addressId;

                //Link the contact with the bank information
                bankAccountObject.clcommon__Contact__c = contactId;
                bankAccountObject.clcommon__Account__c = accountId;
                //Make the bank account active by default
                bankAccountObject.clcommon__Active__c = true;
                //Check whether grower has added an Account Number, if not throw an error
                if((String)mapOfBankInfo.get(FIELD_ACCOUNT_NUMBER) == null){
                    throw new CustomException(PortalConstants.ACCOUNT_NUMBER_MISSING);
                }
                //Check whether grower has added an Account Name, if not throw an error
                if(mapOfBankInfo.get(FIELD_ACCOUNT_NAME) == null){
                    throw new CustomException(PortalConstants.ACCOUNT_NAME_MISSING);
                }
                //Check whether grower has added the routing number for the bank account
                if(mapOfBankInfo.get(FIELD_ROUTING) == null){
                    throw new CustomException(PortalConstants.ACCOUNT_ROUTING_NUMBER_MISSING);
                }

                if (mapOfBankInfo.get(FIELD_BANK_NAME) == null || 
                    mapOfBankInfo.get(FIELD_BANK_PHONE) == null ||
                    mapOfBankInfo.get(FIELD_BANK_ADDR) == null ||
                    mapOfBankInfo.get(FIELD_BANK_CITY) == null ||
                    mapOfBankInfo.get(FIELD_BANK_STATE) == null ||
                    mapOfBankInfo.get(FIELD_BANK_ZIP) == null) {
                    
                    throw new CustomException(PortalConstants.BANK_ROUTING_NUM_INVALID);
                }

                
                bankAccountObject.clcommon__Bank_Account_Number__c = (String)mapOfBankInfo.get(FIELD_ACCOUNT_NUMBER);
                bankAccountObject.clcommon__Bank_Account_Name__c = (String)mapOfBankInfo.get(FIELD_ACCOUNT_NAME);
                bankAccountObject.clcommon__Account_Type__c = (String)mapOfBankInfo.get(FIELD_ACCOUNT_TYPE);
                bankAccountObject.clcommon__Routing_Number__c = (String)mapOfBankInfo.get(FIELD_ROUTING);
                bankAccountObject.clcommon__Bank_Name__c = (String)mapOfBankInfo.get(FIELD_BANK_NAME);
               
                bankObject.Name = (String)mapOfBankInfo.get(FIELD_BANK_NAME);
                bankObject.clcommon__Phone_Number__c = ((String)mapOfBankInfo.get(FIELD_BANK_PHONE)).replaceAll('[-]+', '');

                addressObject.clcommon__Street_Address__c = (String)mapOfBankInfo.get(FIELD_BANK_ADDR);
                addressObject.clcommon__City__c = (String)mapOfBankInfo.get(FIELD_BANK_CITY);
                addressObject.clcommon__State_Province__c = (String)mapOfBankInfo.get(FIELD_BANK_STATE);
                addressObject.clcommon__Zip_Code__c = (String)mapOfBankInfo.get(FIELD_BANK_ZIP);

                bankObject.clcommon__Address__c = addressObject.Id;
                if (addressObject.Id == null) {
                    Database.UpsertResult savedAddress = Database.upsert(addressObject, true);
                    bankObject.clcommon__Address__c = savedAddress.getId();
                }
                
                bankAccountObject.clcommon__Bank__c = bankObject.Id;
                if (bankObject.Id == null) {
                    Database.UpsertResult savedBank = Database.upsert(bankObject, true);
                    bankAccountObject.clcommon__Bank__c = savedBank.getId();
                }

                bankAccountsToSaveList.add(bankAccountObject);

            }

            for (Integer i = 0; i < bankAccountsToSaveList.size() - 1; ++i) {
                for (Integer j = i + 1; j < bankAccountsToSaveList.size(); ++j) {
                    
                    if (bankAccountsToSaveList[i].clcommon__Bank_Account_Number__c == bankAccountsToSaveList[j].clcommon__Bank_Account_Number__c) {
                        throw new CustomException(PortalConstants.BANK_ACCOUNT_NUM_DUPLICATE + bankAccountsToSaveList[i].clcommon__Bank_Account_Number__c);
                    } 
                }
            }
            

            //upserting the list of bank accounts
            Database.UpsertResult[] savedResult = Database.upsert(bankAccountsToSaveList,true);
            
            if (savedResult.size() == 1) {
                bankAccountId = savedResult[0].getId();
                responseFieldMap.put(KEY_BANK_ACCOUNT_ID, bankAccountId);
                responseData.add(new clcommon.PortalCustomRemoteActionRecord(responseFieldMap));
            	response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            }
            response.status = clcommon.Constants.SUCCESS;
        } catch (CustomException exceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = exceptionObj.getMessage();
            
        } catch (Exception exceptionObj){
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
        }
        return response;
    }
}