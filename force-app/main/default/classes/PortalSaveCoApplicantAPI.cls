/**
 * @description       : 
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 02-26-2025
 * @last modified by  : Rakesh Saraf
**/
global without sharing class PortalSaveCoApplicantAPI implements clcommon.PortalCustomRemoteAPI1{
    private final String CLASS_NAME = PortalSaveCoApplicantAPI.class.getName();  

    private static final String COAPPLICANT_TYPE_KEY = 'coapplicantType';
    private static final String EXISTING_COAPPLICANT = 'existingCoapplicant';
    private static final String NEW_COAPPLICANT = 'newCoapplicant';
    private static final String COAPPLICANT_ACCOUNT = 'coApplicantAccount';
    private static final String COAPPLICANT_CONTACT = 'coApplicantContact';
    private static final String COAPPLICANT_BUSINESS = 'coApplicantBusiness';
    private static final String SAVE_TYPE = 'saveType';
    private static final String COAPPLICANT_ACCOUNT_ID = 'coApplicantAccId';
    private static final String COAPPLICANT_CONTACT_ID = 'coApplicantContactId';
    private static final String COAPPLICANT_BUSINESS_INFO = 'coApplicantBusinessInfo';

    clcommon.Response response = new clcommon.Response();
    List<clcommon.PortalCustomRemoteActionRecord> responseDataList = new List<clcommon.PortalCustomRemoteActionRecord>();
    Map<String, Object> fieldsMap = new Map<String, Object>();
    Dealer_Applicant_Relationship__c dealerCoAppRelObj=new Dealer_Applicant_Relationship__c();

    String coapplicantType = PortalConstants.EMPTY_STRING;
    List<User> loggedInUser = new List<User>();
    Map<String, Id> mapOfLegalEntity = new Map<String, Id>();
    Map<String, Id> mapOfpartyType = new Map<String, Id>();



    /**
    * @description 
    * @author Krishanu Chinya | 02-12-2024 
    **/
    global PortalSaveCoApplicantAPI() {
        this.loggedInUser = PortalApplicationOriginationHelper.getLoggedInUser(); 
        this.mapOfLegalEntity = PortalApplicationOriginationHelper.getLegalEntityMap();
        this.mapOfpartyType = PortalApplicationOriginationHelper.getPartyTypeMap();
    }


    /**
    * @description 
    * @author Krishanu Chinya | 02-07-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal){
        SavePoint dbSavePoint = Database.setSavepoint();
        try {
            Contact coApplicantContact = new Contact();
            Account coApplicantAccount = new Account();
            genesis__Business_Information__c coApplicantBusinessInfo = new genesis__Business_Information__c();
            List<genesis__Applications__c> userApplicationList=new List<genesis__Applications__c>();

            String coApplicantAccountRecord = String.valueOf(argumentsFromPortal.get(COAPPLICANT_ACCOUNT));
            String coApplicantContactRecord = String.valueOf(argumentsFromPortal.get(COAPPLICANT_CONTACT));
            String applicationId = String.valueOf(argumentsFromPortal.get(PortalConstants.APPLICATION_ID));
            String coApplicantBusinessRecord = String.valueOf(argumentsFromPortal.get(COAPPLICANT_BUSINESS));
            String saveType = String.valueOf(argumentsFromPortal.get(SAVE_TYPE));

            String dealerCoopType = loggedInUser[0].Account.Parent.Coop_Type__c;

            PortalApplicationCreationHandler.checkNecessaryParam(applicationId, coApplicantAccountRecord);

            userApplicationList=[SELECT ID,
                                        genesis__Account__r.clcommon__Legal_Entity_Type__c,
                                        Is_Evergreen__c
                                 FROM genesis__Applications__c
                                 WHERE ID=: applicationId
                                 LIMIT 1];
            
            PortalApplicationOriginationHelper.checkValidUser(PortalSecurityUtil.validateUserApplicationByAccount(applicationId, loggedInUser[0].AccountId));

            coApplicantAccount = (Account) Json.deserialize(coApplicantAccountRecord, Account.class);
            if(coApplicantContactRecord != null){
                coApplicantContact = (Contact) Json.deserialize(coApplicantContactRecord, Contact.class);
            }
            coApplicantBusinessInfo = (genesis__Business_Information__c) Json.deserialize(coApplicantBusinessRecord, genesis__Business_Information__c.class);

            checkForNewOrExistingCoApplicant(coApplicantAccount.Id);

            //new coapplicant is chosen
            if(coapplicantType == NEW_COAPPLICANT){
                PortalValidationUtil.isValidCoApplicantCreation(new Map<String,Object>{PortalConstants.CONTACT_OBJ_KEY=>coApplicantContact, 
                                                                                        PortalConstants.ACCOUNT_OBJ_KEY=>coApplicantAccount, 
                                                                                        PortalConstants.BUSINESS_INFO_OBJ_KEY=>coApplicantBusinessInfo, 
                                                                                        PortalConstants.SAVE_TYPE_KEY =>saveType});

                PortalValidationUtil.validateNewCoApplicant(coApplicantContact, dealerCoopType);

                //if contact is found, setting the account id
                if(!String.isBlank(coApplicantContact.Id)){
                    coApplicantAccount.Id = coApplicantContact.AccountId;
                    //setting business info
                    List<Account> coAppAccountList=[SELECT id, 
                                                           genesis__Business_Information__c 
                                                    FROM Account 
                                                    WHERE id=:coApplicantAccount.id 
                                                    LIMIT 1];
                    PortalApplicationOriginationHelper.checkEmptyList(coAppAccountList, PortalConstants.SOMETHING_WENT_WRONG);
                    coApplicantBusinessInfo.Id = coAppAccountList[0].genesis__Business_Information__c;

                }

                coApplicantAccount.clcommon__Legal_Entity_Type__c = mapOfLegalEntity.get(PortalConstants.SOLE_PROP_ENTITY);

                setCoApplicantRecordType(coApplicantAccount);
                
                coApplicantBusinessInfo.Gross_Farm_Income__c = coApplicantBusinessInfo.Gross_Farm_Income__c == null ? null : coApplicantBusinessInfo.Gross_Farm_Income__c;
                Database.upsert(coApplicantBusinessInfo, true);
                coApplicantAccount.genesis__Business_Information__c = coApplicantBusinessInfo.Id;
                coApplicantAccount.ParentId = loggedInUser[0].Account.ParentId;

                //setting the account name
                coApplicantAccount = PortalApplicationOriginationHelper.setAccountName(coApplicantAccount, coApplicantContact);
				coApplicantAccount.OwnerId = PortalSecurityUtil.getSiteAdmin();
                coApplicantAccount.Year_Began_Farming__c = coApplicantAccount.Year_Began_Farming__c == null ? null : coApplicantAccount.Year_Began_Farming__c;

                PortalApplicationCreationHandler.checkIfKycVerified(coApplicantContact,coApplicantAccount);

                Database.upsert(coApplicantAccount, true);
                coApplicantContact.AccountId =  coApplicantAccount.Id;
                Database.upsert(coApplicantContact, true);

                updatingDealerApplicantRel(new Map<String,Object>{
                                                            PortalConstants.ACCOUNT_OBJ_KEY=>coApplicantAccount,
                                                            PortalConstants.CONTACT_OBJ_KEY=>coApplicantContact
                                                        });

                createNewCoApplicantParty(new Map<String, Object>{
                                                                COAPPLICANT_ACCOUNT_ID => coApplicantAccount.Id,
                                                                COAPPLICANT_CONTACT_ID => coApplicantContact.Id,
                                                                PortalConstants.APPLICATION_OBJ_KEY => userApplicationList[0],
                                                                COAPPLICANT_BUSINESS_INFO => coApplicantBusinessInfo,
                                                                COAPPLICANT_TYPE_KEY => coapplicantType,
                                                                COAPPLICANT_CONTACT=>coApplicantContact
                                                            });

            }
            //existing coapplicant added via add button
            else{
                PortalValidationUtil.validateCoapplicantByDealer(loggedInUser[0].Account.ParentId, coApplicantAccount.Id);
                
                List<Contact> existingContactList = [SELECT Id,
                                                            AccountId
                                                    FROM Contact
                                                    WHERE AccountId =: coApplicantAccount.Id];

                PortalApplicationOriginationHelper.checkEmptyList(existingContactList, PortalConstants.SOMETHING_WENT_WRONG);

                coApplicantAccount.ParentId = loggedInUser[0].Account.ParentId;

                List<Dealer_applicant_Relationship__c> dealerApplicantRelList=[SELECT ID
                                                                                FROM Dealer_Applicant_Relationship__c
                                                                                WHERE Dealer__c= :loggedInUser[0].Account.ParentId
                                                                                AND Applicant__c=: existingContactList[0].AccountId];

                PortalApplicationOriginationHelper.checkEmptyList(dealerApplicantRelList, PortalConstants.SOMETHING_WENT_WRONG);

                dealerCoAppRelObj=dealerApplicantRelList[0];

                createExistingCoApplicantParty(new Map<String, Object>{
                                                                    COAPPLICANT_ACCOUNT_ID => existingContactList[0].AccountId,
                                                                    COAPPLICANT_CONTACT_ID => existingContactList[0].Id,
                                                                    PortalConstants.APPLICATION_OBJ_KEY => userApplicationList[0],
                                                                    COAPPLICANT_BUSINESS_INFO => coApplicantBusinessInfo});
            }
            //assigning CIF to the coapplicant
            PortalApplicationCreationHandler.updateCifForAccount(coApplicantAccount, dealerCoopType);

            userApplicationList[0].Is_Evergreen__c = false;
        
            Database.update(userApplicationList,true);

            responseDataList.add(new clcommon.PortalCustomRemoteActionRecord(fieldsMap));
            clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(responseDataList);
            response.content = null;
            response.response = responseFormat.response;
            response.status = clcommon.Constants.SUCCESS;

        }catch (CustomException mce) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = mce.getMessage();
            PortalHelper.saveExceptionLog(mce, CLASS_NAME);
        } catch (Exception ex) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(ex, CLASS_NAME);
        }
        return response;
    }

    /**
    * @description : sets the recordtype of the coapplicant
    * @author Krishanu Chinya | 03-04-2024 
    * @param coApplicantAccount 
    **/
    private void setCoApplicantRecordType (Account coApplicantAccount){
        if(!String.isBlank(coApplicantAccount.Id)){
            coApplicantAccount = [SELECT Id,
                                            RecordTypeId 
                                        FROM Account
                                        WHERE Id =: coApplicantAccount.Id];
        }
        //set record type of the coapplicant
        //once a grower, always a grower
        if(coApplicantAccount.RecordTypeId != Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId()){
            coApplicantAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.CO_APPLICATION_RECORD_TYPE).getRecordTypeId();
        }
    }

    /**
    * @description 
    * @author Krishanu Chinya | 02-19-2024 
    * @param coApplicantAccountId 
    **/
    private void checkForNewOrExistingCoApplicant(Id coApplicantAccountId){
        if(String.isBlank(coApplicantAccountId)){
            coapplicantType = NEW_COAPPLICANT;
        }
        else{
            coapplicantType = EXISTING_COAPPLICANT;
        }
    }

   
    /**
    * @description : this method is used to create a party of the coapplicant
    * @author Krishanu Chinya | 02-12-2024 
    * @param paramMap 
    **/
    private void createNewCoApplicantParty(Map<String, Object> paramMap){
        Id coApplicantAccountId = (Id) paramMap.get(COAPPLICANT_ACCOUNT_ID);
        Id coApplicantContactId = (Id) paramMap.get(COAPPLICANT_CONTACT_ID);
        genesis__applications__c applicationObj = (genesis__applications__c) paramMap.get(PortalConstants.APPLICATION_OBJ_KEY);
        genesis__Business_Information__c coApplicantBusinessInfo = (genesis__Business_Information__c)paramMap.get(COAPPLICANT_BUSINESS_INFO);
        Contact coApplicantContact=(Contact) paramMap.get(COAPPLICANT_CONTACT);

        PortalValidationUtil.checkForDuplicateCoapplicant(coApplicantContactId, applicationObj.id);

        clcommon__Party__c coApplicantParty = new clcommon__Party__c();
        coApplicantParty.clcommon__Account__c = coApplicantAccountId;
        coApplicantParty.clcommon__Contact__c = coApplicantContactId;
        coApplicantParty.genesis__Application__c = applicationObj.id;
        
        coApplicantParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.PRINCIPAL_PARTY_NAME);
        coApplicantParty.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;

        if(applicationObj.genesis__Account__r.clcommon__Legal_Entity_Type__c==mapOfLegalEntity.get(PortalConstants.INDIVIDUAL_ENTITY)){
            coApplicantParty.Title__c=PortalConstants.EMPTY_STRING;
        } else if(applicationObj.genesis__Account__r.clcommon__Legal_Entity_Type__c==mapOfLegalEntity.get(PortalConstants.SOLE_PROP_ENTITY)){
            coApplicantParty.Title__c=PortalConstants.CO_APPLICANT_TITLE_KEY;
        } else{
            coApplicantParty.Title__c=coApplicantContact.Title;
        }
        coApplicantParty.Suffix__c	=coApplicantContact.Suffix__c;

        coApplicantParty.Gross_Farm_Income__c=coApplicantBusinessInfo.Gross_Farm_Income__c;

        coApplicantParty.Street__c=coApplicantContact.MailingStreet;
        coApplicantParty.City__c=coApplicantContact.MailingCity;
        coApplicantParty.State__c=coApplicantContact.MailingState;
        coApplicantParty.Postal_Code__c=coApplicantContact.MailingPostalCode;
        coApplicantParty.County__c=coApplicantContact.Mailing_County__c;

        coApplicantParty.Home_Number__c=coApplicantContact.HomePhone;
        coApplicantParty.Work_Number__c=coApplicantContact.Phone;
        coApplicantParty.Mobile_Number__c=coApplicantContact.MobilePhone;

        coApplicantParty.Marital_Status__c=coApplicantContact.clcommon__Marital_Status__c;

        if(dealerCoAppRelObj!=null){
            coApplicantParty.Dealer_Applicant_Relationship__c= dealerCoAppRelObj.id;
        }

        coApplicantParty.Total_Assets__c = coApplicantBusinessInfo.genesis__Total_Assets__c;
        coApplicantParty.Total_Liabilities__c = coApplicantBusinessInfo.genesis__Total_Liabilities__c;

        Database.insert(coApplicantParty, true);
    }



    /**
    * @description this method is used to create a party of the coapplicant
    * @author Rakesh Saraf | 12-04-2024 
    * @param paramMap 
    **/
    private void createExistingCoApplicantParty(Map<String, Object> paramMap){
        Id coApplicantAccountId = (Id) paramMap.get(COAPPLICANT_ACCOUNT_ID);
        Id coApplicantContactId = (Id) paramMap.get(COAPPLICANT_CONTACT_ID);
        genesis__applications__c applicationObj = (genesis__applications__c) paramMap.get(PortalConstants.APPLICATION_OBJ_KEY);
        genesis__Business_Information__c coApplicantBusinessInfo = (genesis__Business_Information__c)paramMap.get(COAPPLICANT_BUSINESS_INFO);

        PortalValidationUtil.checkForDuplicateCoapplicant(coApplicantContactId, applicationObj.id);

        List<Contact> coApplicantContactList=[SELECT Id,
                                                     Title,
                                                     Suffix__c,
                                                     MailingStreet,
                                                     MailingCity,
                                                     MailingState,
                                                     MailingPostalCode,
                                                     Mailing_County__c,
                                                     HomePhone,
                                                     Phone,
                                                     MobilePhone,
                                                     clcommon__Marital_Status__c
                                             FROM Contact
                                             WHERE ID=:coApplicantContactId];

        PortalApplicationOriginationHelper.checkEmptyList(coApplicantContactList, PortalConstants.SOMETHING_WENT_WRONG);

        List<genesis__Business_Information__c> coAppBusinessInfoList=[SELECT ID,
                                                                                    Gross_Farm_Income__c
                                                                            FROM genesis__Business_Information__c
                                                                            WHERE Id=:coApplicantBusinessInfo.id];

        PortalApplicationOriginationHelper.checkEmptyList(coAppBusinessInfoList, PortalConstants.SOMETHING_WENT_WRONG);

        clcommon__Party__c coApplicantParty = new clcommon__Party__c();
        coApplicantParty.clcommon__Account__c = coApplicantAccountId;
        coApplicantParty.clcommon__Contact__c = coApplicantContactId;
        coApplicantParty.genesis__Application__c = applicationObj.id;
        
        coApplicantParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.PRINCIPAL_PARTY_NAME);
        coApplicantParty.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;

        if(applicationObj.genesis__Account__r.clcommon__Legal_Entity_Type__c==mapOfLegalEntity.get(PortalConstants.CORPORATION)){
            coApplicantParty.Title__c=coApplicantContactList[0].Title;
        } else if(applicationObj.genesis__Account__r.clcommon__Legal_Entity_Type__c==mapOfLegalEntity.get(PortalConstants.SOLE_PROP_ENTITY)){
            coApplicantParty.Title__c=PortalConstants.CO_APPLICANT_TITLE_KEY;
        }
        coApplicantParty.Suffix__c	=coApplicantContactList[0].Suffix__c;

        coApplicantParty.Gross_Farm_Income__c=coAppBusinessInfoList[0].Gross_Farm_Income__c;

        coApplicantParty.Street__c=coApplicantContactList[0].MailingStreet;
        coApplicantParty.City__c=coApplicantContactList[0].MailingCity;
        coApplicantParty.State__c=coApplicantContactList[0].MailingState;
        coApplicantParty.Postal_Code__c=coApplicantContactList[0].MailingPostalCode;
        coApplicantParty.County__c=coApplicantContactList[0].Mailing_County__c;

        coApplicantParty.Home_Number__c=coApplicantContactList[0].HomePhone;
        coApplicantParty.Work_Number__c=coApplicantContactList[0].Phone;
        coApplicantParty.Mobile_Number__c=coApplicantContactList[0].MobilePhone;

        coApplicantParty.Marital_Status__c=coApplicantContactList[0].clcommon__Marital_Status__c;

        if(dealerCoAppRelObj!=null){
            coApplicantParty.Dealer_Applicant_Relationship__c= dealerCoAppRelObj.id;
        }

        Database.insert(coApplicantParty, true);
    }

    /**
    * @description this is to update the dealer applicant rel if already existing or else creating a new one.
    * @author Rakesh Saraf | 11-28-2024 
    * @param paramMap 
    **/
    private void updatingDealerApplicantRel(Map<String,Object> paramMap){
        Contact coApplicantContact=(Contact) paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        Account coApplicantAccount=(Account) paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList=[SELECT Id
                                                                            FROM Dealer_Applicant_Relationship__c
                                                                            WHERE Applicant__c= :coApplicantAccount.id
                                                                            AND Dealer__c= :loggedInUser[0].Account.ParentId];
        
        if(dealerApplicantRelList.isEmpty()){
            dealerCoAppRelObj=PortalApplicationCreationHandler.createDealerApplicantRelationship(new Map<String,Object>{
                                                                                                                    PortalConstants.LOGGED_IN_USER=>loggedInUser[0],
                                                                                                                    PortalConstants.CONTACT_OBJ_KEY=>coApplicantContact,
                                                                                                                    PortalConstants.ACCOUNT_OBJ_KEY=>coApplicantAccount
                                                                                                                });

            Database.insert(dealerCoAppRelObj,true);
        }
        else{
            dealerCoAppRelObj=dealerApplicantRelList[0];
        }
    }
    
}