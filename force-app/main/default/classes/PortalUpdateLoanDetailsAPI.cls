/**
 * @description       : This class is called from the Loan Tile -> Edit Loan button , to update the CL, SA, IRC, ERP Id
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 04-08-2025
 * @last modified by  : Ayush Kumar Singh
**/
global without sharing class PortalUpdateLoanDetailsAPI implements clcommon.PortalCustomRemoteAPI1{
private static Map<String, Id> mapOfpartyType = PortalApplicationOriginationHelper.getPartyTypeMap();
    private static final String KEY_APPLICATION = 'applicationId';
    private static final String KEY_SALES_AGENT = 'salesAgent';
    private static final String KEY_IRC = 'irc';
    private static final String KEY_UNIQUE_IDENTIFIER = 'uniqueIdentifier';
    private static final String EDIT = 'edit';
    private static final String KEY_ERP = 'erpId';
    private static final String KEY_CL = 'certifiedLender';

    String applicationId = '';
    String saAccountId ;
    String ircObj = '';
    String uniqueIdentifier = '';
    String erpId = '';
    String clAccountId = '';
    clcommon.Response response = new clcommon.Response();


/**
 * @description 
 * @param componentStrName 
 * @param disclosureNames 
 * @param argumentsFromPortal 
 * @return  `clcommon.Response`
 * @exception 
 */
    global clcommon.Response invokeAction(String componentStrName,
                                            String[] disclosureNames,
                                            Map<String, Object> argumentsFromPortal) {

        SavePoint dbSavePoint = Database.setSavepoint();

        try{
            applicationId = getRequestParamValue(argumentsFromPortal,KEY_APPLICATION);
            saAccountId = getRequestParamValue(argumentsFromPortal,KEY_SALES_AGENT);
            ircObj = getRequestParamValue(argumentsFromPortal,KEY_IRC);
            uniqueIdentifier = getRequestParamValue(argumentsFromPortal,KEY_UNIQUE_IDENTIFIER);
            erpId = getRequestParamValue(argumentsFromPortal,KEY_ERP);
            clAccountId = getRequestParamValue(argumentsFromPortal,KEY_CL);

            List<genesis__Applications__c> applicationList = getApplication(applicationId);
            List<clcommon__party__c> updatePartyList = new List<clcommon__party__c>();
            List<Contact> contactList = new List<Contact>();

            validateApplication(applicationList);

            List<clcommon__Party__c> partyList = [SELECT Id,
                                                        clcommon__Account__c,
                                                        clcommon__Contact__c 
                                                    FROM clcommon__Party__c 
                                                    WHERE genesis__Application__c =:  applicationId
                                                    AND (clcommon__Type__c=: mapOfpartyType.get(PortalConstants.SALES_AGENT_PARTY_NAME)
                                                    OR clcommon__Type__c =: mapOfpartyType.get(PortalConstants.SALES_AGENT_PLUS_PARTY_NAME))
                                                    LIMIT 1];

            //delete the old sa admin party
            deleteSAAdminParty(applicationId);
           
            if(saAccountId != null){
                contactList = [SELECT Id,
                                    Account.RecordType.Name 
                                FROM CONTACT
                                WHERE AccountId =: saAccountId];
            }

            
                applicationList[0].Internal_Reference_Code__c = ircObj;
                applicationList[0].ERP_Id__c = PortalApplicationCreationHandler.validateErpId(erpId, applicationList[0].Id, true);
                if(applicationList[0].Dealer_Name__r.Coop_Type__c == PortalConstants.GROWMARK_COOP_TYPE){
                    applicationList[0].Unique_Identifier__c = uniqueIdentifier;
                }
                applicationList[0].Sales_Agent__c = saAccountId;

                //update CL In application
                updateCertifiedLenderInApplication(applicationList[0],clAccountId);
                
                //create party for the sa admin of the new sa
                createSAAdminParty(applicationList[0].Sales_Agent__c, applicationId);

                Map<String,String> recordIdMap = new Map<String,String>{
                    KEY_APPLICATION => applicationId,
                    KEY_SALES_AGENT => saAccountId
                };
                updatePartyList = updateSalesAgentInApplication(recordIdMap,partyList,contactList);
            

            Database.update(applicationList,true);
            if(updatePartyList.size() == 1 && saAccountId == null){
                Database.delete(updatePartyList,true);
            }
            else if(updatePartyList.size()>0){
                Database.upsert(updatePartyList,true);
            }

            createSharingRecord(saAccountId,applicationId);
            PortalApplicationCreationHandler.createSharingRecordsForSAAdmin(applicationList[0]);
            
            response.status = clcommon.Constants.SUCCESS;
        } catch (CustomException customException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customException.getMessage();
            PortalHelper.saveExceptionLog(customException,PortalUpdateLoanDetailsAPI.class.getName());
        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;  
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, PortalUpdateLoanDetailsAPI.class.getName());
        }
        return response;
    } 

   /**
    * @description 
    * @param saAccountId 
    * @param appId 
    * @exception 
    */
    private static void createSAAdminParty(Id saAccountId, String appId){
        //add party of sa admin if the sa has an admin
        List<Id> saAdminAccIdList = PortalApplicationOriginationHelper.fetchSAAdmin(saAccountId);
        if(!saAdminAccIdList.isEmpty()){
            List<Contact> saAdminContactList = [SELECT Id, 
                                                        AccountId
                                                    FROM Contact
                                                    WHERE AccountId IN :saAdminAccIdList];
            Map<Id,Id> saAdminAccIdvsConIdMap = new Map<Id,Id>();
            for(Contact con : saAdminContactList){
                saAdminAccIdvsConIdMap.put(con.AccountId, con.Id);
            }
            PortalApplicationOriginationHelper.checkEmptyList(saAdminContactList, PortalConstants.SOMETHING_WENT_WRONG);                                  
            List<clcommon__Party__c> saAdminPartyList = new List<clcommon__Party__c>();

            List<clcommon__Party__c> checkIfPartyExistList = new List<clcommon__Party__c>();
            checkIfPartyExistList = [SELECT Id,
                                            clcommon__Account__c,
                                            genesis__Application__c
                                        FROM clcommon__Party__c 
                                        WHERE clcommon__Account__c IN :saAdminAccIdList 
                                        AND genesis__Application__c =:appId];
            Map<Id, clcommon__Party__c> checkIfPartyExistMap = new Map<Id, clcommon__Party__c>();
            
            for(clcommon__Party__c party : checkIfPartyExistList){
                if(!checkIfPartyExistMap.containsKey(party.clcommon__Account__c)){
                    checkIfPartyExistMap.put(party.clcommon__Account__c, party);
                }
            }

            for(Id saAdminAccId : saAdminAccIdList){
                if(!checkIfPartyExistMap.containsKey(saAdminAccId)){
                    clcommon__Party__c saAdminPartyObj = new clcommon__Party__c();
                    saAdminPartyObj.genesis__Application__c = appId;
                    saAdminPartyObj.clcommon__Account__c = saAdminAccId;
                    saAdminPartyObj.clcommon__contact__c = saAdminAccIdvsConIdMap.get(saAdminAccId);
                    saAdminPartyObj.clcommon__Type__c = mapOfpartyType.get(PortalConstants.SALES_AGENT_ADMIN_PARTY);
                    saAdminPartyObj.clcommon__Party_Types__c = PortalConstants.SALES_AGENT_ADMIN_PARTY;
                    saAdminPartyList.add(saAdminPartyObj);
                }
            }
            Database.Insert(saAdminPartyList, true);
        }
    }

    /**
     * @description 
     * @param applicationId 
     */
    private static void deleteSAAdminParty(String applicationId){
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            Sales_Agent__c 
                                                        FROM genesis__Applications__c 
                                                        WHERE Id =: applicationId];
        List<Id> saAdminAccountIdList=  PortalApplicationOriginationHelper.fetchSAAdmin(applicationObj.Sales_Agent__c);

        List<clcommon__Party__c> oldParties = [SELECT Id,
                                                        Name,
                                                        clcommon__Account__c
                                                    FROM clcommon__Party__c
                                                    WHERE genesis__Application__c = :applicationId 
                                                    And clcommon__Account__c IN :saAdminAccountIdList];

        Database.delete(oldParties, true);
    }

    
    /**
     * @description This method validate application 
     * @param applicationList 
     * @exception 
     */
    private static void validateApplication(List<genesis__Applications__c> applicationList){
        List<Account> loggedInAccountList = [SELECT Id, 
                                                    ParentId,
                                                    RecordTypeId,
                                                    RecordType.Name
                                                FROM Account
                                                WHERE Id IN (SELECT AccountId 
                                                                FROM User
                                                                WHERE Id = :UserInfo.getUserId())];

                                
        PortalApplicationOriginationHelper.checkEmptyList(loggedInAccountList, PortalConstants.SOMETHING_WENT_WRONG);
        if(!loggedInAccountList[0].RecordType.Name.equals(PortalConstants.CERTIFIED_LENDER) 
                & !loggedInAccountList[0].RecordType.Name.equals(PortalConstants.CERTIFIED_LENDER_PLUS) 
                & !loggedInAccountList[0].RecordType.Name.equals(PortalConstants.FIELD_STAFF_AGENT)){
                    throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }

        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    clcommon__Account__c,
                                                    clcommon__Contact__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c =: applicationList[0].id
                                                AND clcommon__Account__c =: loggedInAccountList[0].id];
        if(loggedInAccountList[0].ParentId != applicationList[0].Dealer_Name__c && partyList.size()!=1){
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }
    }

    /** 
     * @description This method get value from request map
     * @param argumentsFromPortal 
     * @param key 
     * @return  `String`
     */
    private static String getRequestParamValue(Map<String, Object> argumentsFromPortal,String key){
        String requestParamValue;
        if(argumentsFromPortal.containsKey(key)){
            requestParamValue = String.valueOf(argumentsFromPortal.get(key));
        }
        return requestParamValue;
    }

    /**
     * @description This method update and create party for SalesAgent in application
     * @param recordIdMap 
     * @param partyList 
     * @param contactList 
     * @return  `List<clcommon__Party__c>`
     */
    private static List<clcommon__Party__c> updateSalesAgentInApplication(Map<String,String> recordIdMap, List<clcommon__Party__c> partyList,List<Contact> contactList){
        List<clcommon__Party__c> updatedPartyList = new List<clcommon__Party__c>();
        String applicationId = recordIdMap.get(KEY_APPLICATION);
        String saAccountId = recordIdMap.get(KEY_SALES_AGENT);
        Map<String,String> recordTypeToPartyTypeMap = new Map<String,String>{
            PortalConstants.SALES_AGENT_PLUS => PortalConstants.SALES_AGENT_PLUS_PARTY_NAME,
            PortalConstants.SALES_AGENT => PortalConstants.SALES_AGENT_PARTY_NAME
        };
        if(contactList.isEmpty() ){
            return partyList;
        }
        if(partyList.size()==1){
            partyList[0].clcommon__Account__c = saAccountId;
            partyList[0].clcommon__Contact__c = contactList[0].id;
            partyList[0].clcommon__Type__c = mapOfpartyType.get(recordTypeToPartyTypeMap.get(contactList[0].Account.RecordType.Name));
            partyList[0].clcommon__Party_Types__c = recordTypeToPartyTypeMap.get(contactList[0].Account.RecordType.Name);
            updatedPartyList.add(partyList[0]);
        }
        else{
            clcommon__party__c partyObj = new clcommon__party__c();
            partyObj.clcommon__Account__c = saAccountId;
            partyObj.clcommon__Contact__c = contactList[0].id;
            partyObj.genesis__Application__c = applicationId;
            partyObj.clcommon__Type__c = mapOfpartyType.get(recordTypeToPartyTypeMap.get(contactList[0].Account.RecordType.Name));
            partyObj.clcommon__Party_Types__c = recordTypeToPartyTypeMap.get(contactList[0].Account.RecordType.Name);
            updatedPartyList.add(partyObj);
        }
        return updatedPartyList;
    }
    
    /**
     * @description Get the application need to update
     * @param applicationId 
     * @return  `List<genesis__Applications__c>`
     * @exception 
     */
    private static List<genesis__Applications__c> getApplication(String applicationId){
        if(applicationId == null){
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                Dealer_Name__c,
                                                                Dealer_Name__r.Coop_Type__c,
                                                                Internal_Reference_Code__c,
                                                                Sales_Agent__c,
                                                                Certified_Lender__c
                                                            FROM genesis__Applications__c
                                                            WHERE Id =: applicationId];

        PortalApplicationOriginationHelper.checkEmptyList(applicationList, PortalConstants.NO_APPLICATIONS_FOUND);
        
        return applicationList;
    }
    /**
     * @description This method create sharing record for Sales Agent
     * @param saAccountId 
     * @param applicationId 
     * @exception 
     */
    private static void createSharingRecord(String saAccountId,String applicationId){
        if (saAccountId != null) {
            List<User> salesAgentUserList = [SELECT Id
                                                FROM User
                                                WHERE AccountId = :saAccountId
                                                LIMIT 1];

            
            PortalApplicationOriginationHelper.checkEmptyList(salesAgentUserList, PortalConstants.NO_SALES_AGENT_USER);

            List<clcommon__Document_Category__c> documentCategories = [SELECT Id 
                                                                            FROM clcommon__Document_Category__c 
                                                                            WHERE genesis__Application__c = :applicationId];
            List<clcommon__Document_Category__Share> documentSharingRecordList = [SELECT Id,
                                                                                            Parent.genesis__Application__c 
                                                                                        FROM clcommon__Document_Category__Share 
                                                                                        WHERE Parent.genesis__Application__c =: applicationId 
                                                                                        AND UserOrGroupId =: salesAgentUserList[0].id];

            List<genesis__Applications__Share> appSharingRecordList = [SELECT Id 
                                                                            FROM genesis__Applications__Share 
                                                                            WHERE ParentId =: applicationId 
                                                                            AND UserOrGroupId =: salesAgentUserList[0].id];

            

            List<clcommon__Document_Category__Share> documentSharingList = new List<clcommon__Document_Category__Share>();
            List<genesis__Applications__Share> appSharingList = new List<genesis__Applications__Share>();
            if(appSharingRecordList.size()==0){
                genesis__Applications__Share applicationSharingRecord = new genesis__Applications__Share();
                applicationSharingRecord.AccessLevel = EDIT;
                applicationSharingRecord.ParentId = applicationId;
                applicationSharingRecord.UserOrGroupId = salesAgentUserList[0].id;
                appSharingList.add(applicationSharingRecord);
                Database.upsert(appSharingList, false);
            }
            if(documentSharingRecordList.size() < documentCategories.size()){
                for (clcommon__Document_Category__c documentCategory : documentCategories) {
                    clcommon__Document_Category__Share documentSharingRecord = new clcommon__Document_Category__Share();
                    documentSharingRecord.AccessLevel = EDIT;
                    documentSharingRecord.ParentId = documentCategory.Id;
                    documentSharingRecord.UserOrGroupId = salesAgentUserList[0].id;
                    documentSharingList.add(documentSharingRecord);
                }
                Database.upsert(documentSharingList, false);
            }  
        }
    }

    /**
    * @description 
    * @author Suraj Kumar | 02-19-2024 
    * @param applicationObj 
    * @param clAccountId 
    **/
    private static void updateCertifiedLenderInApplication(genesis__Applications__c applicationObj,String clAccountId){
        if(!String.isBlank(clAccountId)){
            applicationObj.Certified_Lender__c = clAccountId;
        }
    }
}