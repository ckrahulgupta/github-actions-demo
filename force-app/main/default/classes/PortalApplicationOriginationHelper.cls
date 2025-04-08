/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 

 * @last modified on  : 04-08-2025
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   01-08-2023   Subham Nandi   Initial Version
**/
global without sharing class PortalApplicationOriginationHelper {

    private static final String DEALER_NAME = '{!Dealer}';
    private static final String APP_DATE = 'mm/dd/yyyy';
    private static final String GROWER_LINK = '{!growerLink}';
    private static final String SPL_SUB_TRANCHE_STRING = 'Special Term Sub-Tranche (';
    private static final Integer NEW_RATE_CROP_YEAR = 2024;
    private static final String KEY_APPLICATION = 'applicationId';
    private static final String RECORD_TYPE_MAP = 'recordTypeMap';
    private static final String PARTY_TYPE_MAP = 'partyTypeMap';

    private static final String INSURANCE_PLAN_RP_VALUE = 'RP';
    private static final String INSURANCE_PLAN_ARP_VALUE = 'ARP';
    private static final String INSURANCE_PLAN_ARH_VALUE = 'ARH';
    private static final String AGGREGATE_KEY = 'expr0';
    private static final String KEY_NEEDS_LOAN_AMT_ADJUSTMENT = 'needsLoanAmountAdjustment';

    private static final String FIELD_ACCOUNT_NAME = 'clcommon__Account__r.Name';
    private static final String FIELDS_ACCOUNT_COUNTY = 'clcommon__Account__r.Billing_County__c';
    private static final String KEY_SAVE_TYPE = 'shouldValidate';
    private static final String FIELD_CONTACT_FIRST_NAME = 'clcommon__Contact__r.FirstName';
    private static final String FIELD_CONTACT_LAST_NAME = 'clcommon__Contact__r.LastName';
    private static final String FIELDS_ACCOUNT_STREET = 'clcommon__Account__r.BillingStreet';
    private static final String FIELDS_ACCOUNT_CITY = 'clcommon__Account__r.BillingCity';
    private static final String FIELDS_ACCOUNT_STATE = 'clcommon__Account__r.BillingState';
    private static final String FIELDS_ACCOUNT_POSTAL_CODE = 'clcommon__Account__r.BillingPostalCode';
    private static final String KEY_CROP_DETAILS = 'cropDetails';
    private static final String KEY_DOES_APPLICANT_FEED_COLLATERAL = 'feedCollateral';
    private static final String KEY_SPOUSE_DETAILS = 'spouseDetails';
    private static final String KEY_ADDITIONAL_CROP_DETAILS = 'landownersDetails';
    private static final String KEY_LOAN_AMT_REDUCED_TO_ZERO = 'loanAmountReducedToZero';

    private static final String SPOUSE_DETAILS = 'spouseDetails';
    private static final String ADDITIONAL_CROP_DETAILS = 'additionalCropDetails';
    private static final String POTENTIAL_BUYERS_DETAILS = 'potentialBuyerdetails';
    private static final String CROP_INDURANCE_DETAILS = 'cropInsuranceDetails';

    private static final String EMAIL_TEMPLATE = 'eamilTemplate';
    private static final String SENDER_EMAIL = 'senderEmail';
    private static final String RECEIVER_EMAIL = 'receiverEmail';
    private static final String REPORT_LOG_NAME = 'Email - (';
    private static final String EMAIL_TEMPLATE_NAME = 'Email Template Name: ';
    private static final String SENDER = 'Sender: ';
    private static final String RECEIVER = 'Receiver: ';
    private static final String NEXT_LINE = '\n';
    private static final String CLOSING_BRACKET = ')';
    private static final String CIF_SUFFIX ='001';
    private static final String NEW_APPLICANT ='newApplicant';
    private static final String EMPTY_STRING = '';
    private static final String GROWER_NAME = 'growerName';
    private static final String GROWER_CITY = 'growerCity';
    private static final String GROWER_STATE = 'growerState';
    private static final String NINE_STRING = '9';
    private static final String SEND_APP_TO_GROWER = 'SEND_APP_TO_GROWER';
    private static final String CREDIT_BUREAU_SCORE_PDF_SUFFIX  = '%Credit Bureau Scores.pdf';
    private static final String CREDIT_BUREAU_SUMMARY_PDF_SUFFIX  = '%Credit Bureau Summary.pdf';
    
    
    /**
    * @description 
    * @param applicationId 
    * @return String 
    **/
    public static String getCoopType(Id applicationId) {
        return [SELECT Id, 
                       Coop_Type__c 
                FROM genesis__Applications__c 
                WHERE Id = :applicationId
                LIMIT 1][0].Coop_Type__c;
    }
    
    /**
    * @description The purpose of this method is to fetch the documents under an Account and upload it under an application document category
 
    * @param applicationId 
    * @param documentCategoryName 
    **/
    public static void uploadDocumentOnDocCategory(String applicationId, String documentCategoryName){
        //Method Specific Variables-------------------------------------------------------------------
        List<String> contentDocList = new List<String>(); 
        Map<String,String> contentDocToVersionMap = new Map<String,String>();
        Map<String,String> contentDocToTitle = new Map<String,String>();
        List<clcommon__document_category__c> docCategory = new List<clcommon__document_category__c>();
                //Method Specific Variables-------------------------------------------------------------------
        //This method takes the document category name and the account from where the document must be fetched
        List<clcommon__Category_Attachment_Association__c> categoryAttachmentList = new List<clcommon__Category_Attachment_Association__c>();
        genesis__Applications__c objCurrentApplication = [SELECT Id, 
                                                                Coop_Type__c,
                                                                genesis__Account__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id = :applicationId];
        //Get logged in user profile
        String objProfile = [SELECT Id, 
                                    Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
List<ContentDocumentLink> objContentDocument = new List<ContentDocumentLink>();
        if(objProfile == PortalConstants.GROWER_PROFILE){
            objContentDocument = [SELECT Id, 
                                            ContentDocumentId,
                                            ContentDocument.Title, 
                                            LinkedEntityId 
                                    FROM ContentDocumentLink 
                                    WHERE LinkedEntityId =: UserInfo.getUserId() ];
        }
        else{
            objContentDocument = [SELECT Id, 
                                        ContentDocumentId,
                                        ContentDocument.Title, 
                                        LinkedEntityId 
                                FROM ContentDocumentLink 
                                WHERE LinkedEntityId =:  objCurrentApplication.genesis__Account__c
                                AND (NOT ContentDocument.Title LIKE :CREDIT_BUREAU_SCORE_PDF_SUFFIX)
                                AND (NOT ContentDocument.Title LIKE :CREDIT_BUREAU_SUMMARY_PDF_SUFFIX)];
        }
        if(objContentDocument.size() > 0){
            //Get the Content Documents into a list query all the respective Content Version   
            for(ContentDocumentLink eachContentDocument : objContentDocument){
                contentDocList.add(eachContentDocument.ContentDocumentId);
            }
            List<ContentVersion> objContentDocumentVersion =  [SELECT Id, 
                                                                        Title,
                                                                        ContentDocumentId 
                                                                    FROM ContentVersion 
                                                                    WHERE ContentDocumentId IN :contentDocList];
            for(ContentVersion eachContentVersion : objContentDocumentVersion){
                contentDocToVersionMap.put(eachContentVersion.ContentDocumentId,eachContentVersion.Id);
                contentDocToTitle.put(eachContentVersion.ContentDocumentId,eachContentVersion.Title);
            }
            docCategory = [SELECT Id
                            FROM clcommon__document_category__c
                            WHERE genesis__Application__c =: applicationId
                            AND clcommon__Category_Name__c =: documentCategoryName];
                                        for(ContentDocumentLink eachDoc : objContentDocument){
                clcommon__Category_Attachment_Association__c docCategoryAttachment = new clcommon__Category_Attachment_Association__c();
                docCategoryAttachment.clcommon__Document_Category__c = docCategory[0].id;
                docCategoryAttachment.clcommon__Content_Document_Id__c = eachDoc.ContentDocumentId;
                docCategoryAttachment.clcommon__Content_Version_Id__c = contentDocToVersionMap.get(eachDoc.ContentDocumentId);
                docCategoryAttachment.clcommon__Attachment_Id__c = eachDoc.id;
    
                docCategoryAttachment.Name = contentDocToTitle.get(eachDoc.ContentDocumentId);
                categoryAttachmentList.add(docCategoryAttachment);
                
            }
            Database.Insert(categoryAttachmentList, true);
        }
        
    }

    /**
    * @description 
    * @author Ravi Ranjan | 06-11-2023 
    * @param response 
    * @param containsPartyRecordMap 
    * @param partyName 
    **/
    public static void saveAdditionalInfoDetails(Map<String, Object> response, Map<String, Object> containsPartyRecordMap,String partyName){
        String applicationId = String.valueOf(containsPartyRecordMap.get(KEY_APPLICATION));
        Map<String, RecordType> partyRecordTypeMap =  (Map<String, RecordType>)containsPartyRecordMap.get(RECORD_TYPE_MAP);
        Map<String, clcommon__Party_Type__c> partyTypeMap = (Map<String, clcommon__Party_Type__c>) containsPartyRecordMap.get(PARTY_TYPE_MAP);
        Map<String, Id> mapOfLegalEntity = getLegalEntityMap();

        Contact contactObj = new Contact();
        Account accountObj = new Account();
        clcommon__party__c partyObj = new clcommon__party__c();
        accountObj = createAccount(response, partyName);
        // Creating Record Type as Landowner
        if(partyName == PortalConstants.LANDOWNER_PARTY_NAME){
            RecordType landownerRecordType = partyRecordTypeMap.get(PortalConstants.LANDOWNER_PARTY_NAME);
            accountObj.RecordTypeId = landownerRecordType.Id;
        }
        //Creating Reecord Type as Spouse
        if(partyName == PortalConstants.SPOUSE_PARTY_NAME){
            RecordType spouseRecordType = partyRecordTypeMap.get(PortalConstants.SPOUSE_PARTY_NAME);
            accountObj.RecordTypeId = spouseRecordType.Id;
            accountObj.clcommon__legal_entity_type__c=mapOfLegalEntity.get(PortalConstants.SOLE_PROP_ENTITY);
            genesis__Business_Information__c businessInfoObj=new genesis__Business_Information__c();
            Database.insert(businessInfoObj,true);
            accountObj.genesis__Business_Information__c=businessInfoObj.id;
        }
        //Creating Record Type as Insurance Agency
        if(partyName == PortalConstants.INSURANCE_AGENT_PARTY_NAME){
            RecordType insuranceRecordType = partyRecordTypeMap.get(PortalConstants.INSURANCE_AGENT_PARTY_NAME);
            accountObj.RecordTypeId = insuranceRecordType.Id;
        }
        // Creating Record Type as BUYER
        if(partyName == PortalConstants.BUYER_PARTY_NAME){
            RecordType buyerRecordType = partyRecordTypeMap.get(PortalConstants.BUYER_PARTY_NAME);
            accountObj.RecordTypeId = buyerRecordType.Id;
        }

        Database.Upsert(accountObj, true);
        contactObj = createContact(response, partyName);
        contactObj.accountID = accountObj.Id;
        Database.Upsert(contactObj, true);
        String id = (String) Response.get(PortalConstants.ID_KEY);
        if(id == null || id == PortalConstants.NEW_RECORD_STRING){
            partyObj.Id = null;
        }
        else{
            partyObj.Id = id;
        }
        partyObj.clcommon__Account__c = accountObj.Id;
        partyObj.clcommon__Contact__c = contactObj.Id;
        partyObj.genesis__Application__c = applicationId;
        clcommon__Party_Type__c partyType = partyTypeMap.get(partyName);
        partyObj.clcommon__Type__c = partyType.id;
        partyObj.clcommon__Party_Types__c = partyName;
        Database.Upsert(partyObj, true);
    }

    /**
    * @description 
    * @author Ravi Ranjan | 06-11-2023 
    * @param response 
    * @param partyName 
    * @return Account 
    **/
    private static Account createAccount(Map<String, Object> response , string partyName){
        Account accountObj = new Account();
        String id = (String) response.get(PortalConstants.CLCOMMON_ACCOUNT_KEY);
        if(id == null || id == PortalConstants.NEW_RECORD_STRING){
            accountObj.Id = null;
        }
        else{
            accountObj.Id = id;
        }
        if (partyName.equalsIgnoreCase(PortalConstants.SPOUSE_PARTY_NAME)){
            accountObj.Name = (String)response.get(PortalConstants.COAPPLICANT_FIRST_NAME_KEY) + PortalConstants.SPACE_STRING 
                                    + (String) response.get(PortalConstants.COAPPLICANT_LAST_NAME_KEY);
            accountObj.clcommon__Email__c = (String) response.get(PortalConstants.COAPPLICANT_CONTACT_EMAIL_KEY);
        }else{
            accountObj.Name = (String) response.get(PortalConstants.CLCOMMON_ACCOUNT_NAME_KEY);
            accountObj.clcommon__Email__c = (String) response.get(PortalConstants.CLCOMMON_ACCOUNT_EMAIL_KEY);
            accountObj.Phone = (String) response.get(PortalConstants.CLCOMMON_ACCOUNT_PHONE_KEY);
            accountObj.BillingStreet = (String) response.get(PortalConstants.CLCOMMON_ACCOUNT_BILLING_STREET_KEY);
            accountObj.BillingCity = (String) response.get(PortalConstants.CLCOMMON_ACCOUNT_BILLING_CITY_KEY);
            accountObj.BillingState = (String) response.get(PortalConstants.CLCOMMON_ACCOUNT_BILLING_STATE_KEY);
            accountObj.BillingPostalCode = (String) response.get(PortalConstants.CLCOMMON_ACCOUNT_BILLING_POSTAL_CODE_KEY);
            accountObj.Billing_County__c = (String) response.get(PortalConstants.CLCOMMON_ACCOUNT_BILLING_COUNTY_KEY);
        }
        accountObj.OwnerId = PortalSecurityUtil.getSiteAdmin();
        return accountObj;
        
    }

    /**
    * @description 
    * @author Ravi Ranjan | 06-11-2023 
    * @param response 
    * @param partyName 
    * @return Contact 
    **/
    private static Contact createContact(Map<String, Object> response , string partyName){
        Contact contactObj = new Contact();
        List<String> nameList = new List<String>();
        String id = (String) response.get(PortalConstants.CLCOMMON_CONTACT_KEY);
        if(id == null || id == PortalConstants.NEW_RECORD_STRING){
            contactObj.Id = null;
        }
        else{
            contactObj.Id = id;
        }
        if (partyName.equalsIgnoreCase(PortalConstants.SPOUSE_PARTY_NAME)){
            contactObj.Firstname = (String)response.get(PortalConstants.COAPPLICANT_FIRST_NAME_KEY);
            contactObj.ints__Middle_Name__c = (String) response.get(PortalConstants.COAPPLICANT_MIDDLE_NAME_KEY);
            contactObj.LastName = (String) response.get(PortalConstants.COAPPLICANT_LAST_NAME_KEY);
            contactObj.Email = (String) response.get(PortalConstants.COAPPLICANT_CONTACT_EMAIL_KEY);
            contactObj.genesis__SSN__c = (String) response.get(PortalConstants.COAPPLICANT_SSN_KEY);
            contactObj.Confirm_SSN__c = (String) response.get(PortalConstants.COAPPLICANT_SSN_KEY);
        }else{
            nameList = String.valueOf((String) response.get(PortalConstants.CLCOMMON_ACCOUNT_NAME_KEY)).split(PortalConstants.SPACE_STRING, PortalConstants.TWO_VALUE);
            if(nameList.size() == 1 ){
                contactObj.LastName = nameList[0];
            }else{
                contactObj.FirstName = nameList[0];
                contactObj.LastName = nameList[1];
            }
            contactObj.Email = (String) response.get(PortalConstants.CLCOMMON_ACCOUNT_EMAIL_KEY);
            contactObj.Phone = (String) response.get(PortalConstants.CLCOMMON_ACCOUNT_PHONE_KEY);
            contactObj.MailingStreet = (String) response.get(PortalConstants.CLCOMMON_ACCOUNT_BILLING_STREET_KEY);
            contactObj.MailingCity = (String) response.get(PortalConstants.CLCOMMON_ACCOUNT_BILLING_CITY_KEY);
            contactObj.MailingState = (String) response.get(PortalConstants.CLCOMMON_ACCOUNT_BILLING_STATE_KEY);
            contactObj.MailingPostalCode = (String) response.get(PortalConstants.CLCOMMON_ACCOUNT_BILLING_POSTAL_CODE_KEY);
            contactObj.Mailing_County__c = (String) response.get(PortalConstants.CLCOMMON_ACCOUNT_BILLING_COUNTY_KEY);
        }
        return contactObj;
    }

    /**
    * @description The purpose of this method is to attach a sales agent to the application if there is none.
    * @author Subham Nandi | 02-08-2023 
    * @param objApplication 
    * @param mapOfpartyType 
    **/
    public static void addSalesAgentParty(genesis__Applications__c objApplication, Map<String, Id> mapOfpartyType){

        List<clcommon__party__c> objSalesAgentParties = [SELECT Id 
                                                            FROM clcommon__party__c
                                                            WHERE genesis__Application__c =: objApplication.Id
                                                                AND clcommon__Type__c=: mapOfpartyType.get(PortalConstants.SALES_AGENT_PARTY_NAME)];
        if (objSalesAgentParties.size() <= 0 && objApplication.Sales_Agent__c != null) {
            clcommon__Party__c objCLParty = new clcommon__Party__c();

            List<Contact> objSalesAgentContact = [SELECT Id
                                                    FROM Contact
                                                    WHERE AccountId = :objApplication.Sales_Agent__c];
            if(objSalesAgentContact.size() == 0 || objSalesAgentContact == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            } 
            objCLParty.genesis__Application__c = objApplication.Id;
            objCLParty.clcommon__Account__c = objApplication.Sales_Agent__c;
            objCLParty.clcommon__contact__c = objSalesAgentContact[0].Id;
            objCLParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.SALES_AGENT_PARTY_NAME);
            objCLParty.clcommon__Party_Types__c = PortalConstants.SALES_AGENT_PARTY_NAME;
            Database.upsert(objCLParty, true);


            //add party of sa admin if the sa has an admin
            List<Id> saAdminAccIdList = PortalApplicationOriginationHelper.fetchSAAdmin(objApplication.Sales_Agent__c);
            if(!saAdminAccIdList.isEmpty()){
                List<Contact> saAdminContactList = [SELECT Id, AccountId
                                                    FROM Contact
                                                    WHERE AccountId IN :saAdminAccIdList];
                Map<Id,Id> saAdminAccIdvsConIdMap = new Map<Id,Id>();
                for(Contact con : saAdminContactList){
                    saAdminAccIdvsConIdMap.put(con.AccountId, con.Id);
                }
                                                    
                if(saAdminContactList.size() == 0 || saAdminContactList == null){
                    throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
                } 
                List<clcommon__Party__c> saAdminPartyList = new List<clcommon__Party__c>();

                List<clcommon__Party__c> checkIfPartyExistList = new List<clcommon__Party__c>();
                checkIfPartyExistList = [SELECT Id,
                                            clcommon__Account__c,
                                            genesis__Application__c
                                            FROM clcommon__Party__c 
                                            WHERE clcommon__Account__c IN :saAdminAccIdList 
                                            AND genesis__Application__c =:objApplication.Id];
                Map<Id, clcommon__Party__c> checkIfPartyExistMap = new Map<Id, clcommon__Party__c>();
                
                for(clcommon__Party__c party : checkIfPartyExistList){
                    if(!checkIfPartyExistMap.containsKey(party.clcommon__Account__c)){
                        checkIfPartyExistMap.put(party.clcommon__Account__c, party);
                    }
                }

                for(Id saAdminAccId : saAdminAccIdList){
                    //first ceck if sa admin already has a party (if app was created by sa admin, he will have a party)
                    if(!checkIfPartyExistMap.containsKey(saAdminAccId)){

                        clcommon__Party__c saAdminPartyObj = new clcommon__Party__c();
                        saAdminPartyObj.genesis__Application__c = objApplication.Id;
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

    }

    
    /**
    * @description : this method is used to set the address in the DBA Account
    * @author Krishanu Chinya | 02-05-2024 
    * @param coApplicants 
    * @param accountObj 
    * @param borrowerParty 
    * @return Account 
    **/
    public static Account addDBAAdress(List<Map<String, Object>> coApplicants, Account accountObj,clcommon__Party__c borrowerParty){

        for(Map<String, Object> mapOfCoApplicant : coApplicants){
            String existingPriApplicantId = (String) mapOfCoApplicant.get(PortalConstants.ID_KEY);
            if(existingPriApplicantId == null | existingPriApplicantId == PortalConstants.NEW_RECORD_STRING){
                    continue;
            }
            else{
                accountObj.BillingStreet = (String) mapOfCoApplicant.get(PortalConstants.STREET_KEY);
                accountObj.BillingCity = (String) mapOfCoApplicant.get(PortalConstants.CITY_KEY);
                accountObj.BillingPostalCode = (String) mapOfCoApplicant.get(PortalConstants.POSTAL_CODE_KEY);
                accountObj.BillingState = (String) mapOfCoApplicant.get(PortalConstants.STATE_KEY);
                accountObj.Billing_County__c = (String) mapOfCoApplicant.get(PortalConstants.COUNTY_KEY);
            }
        }

        borrowerParty.City__c=accountObj.BillingCity;
        borrowerParty.State__c=accountObj.BillingState;
        borrowerParty.County__c=accountObj.Billing_County__c;
        borrowerParty.Street__c=accountObj.BillingStreet;
        borrowerParty.Postal_Code__c=accountObj.BillingPostalCode;

        return accountObj;
    }

   
    /**
    * @description The purpose of this method is to add default values to the application while creating
    * @author Subham Nandi | 03-12-2024 
    * @param applicationObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c addDefaultValuesToApplication(genesis__Applications__c applicationObj){
        List<clcommon__CL_Product__c> clProductList = new List<clcommon__CL_Product__c>();
        
        if(applicationObj.genesis__Term__c == null) {
            applicationObj.genesis__Term__c = PortalConstants.TERM; //adding default term
        }
        if(applicationObj.genesis__Interest_Rate__c == null) {
            applicationObj.genesis__Interest_Rate__c = PortalConstants.INTEREST_RATE; //adding default interest rate
        }
        applicationObj.genesis__Pricing_Method__c = PortalConstants.RATE_CARD_STRING;
        applicationObj.genesis__Product_Type__c = PortalConstants.LOAN_TYPE; //adding the product type as 'Loan'

        //Adding the CL Product as Simpli-Fi
        clProductList = [SELECT Id,
                                clcommon__Product_Name__c
                        FROM clcommon__Cl_Product__c
                        WHERE clcommon__Product_Name__c =: PortalConstants.SIMPLIFY_TYPE];
        PortalApplicationOriginationHelper.checkEmptyList(clProductList, PortalConstants.SOMETHING_WENT_WRONG);
        applicationObj.genesis__CL_Product__c = clProductList[0].Id;
        return applicationObj;
    }

    /**
    * @description 
    * @param appCreated 
    * @param objAccount 
    **/
    public static void copyAdditionalPartyDetails(genesis__Applications__c appCreated, Account objAccount){

        List<clcommon__Party__c> newPartyList = new List<clcommon__Party__c>();
        List<genesis__Applications__c> latestExistingApp = [SELECT Id
                                                                        FROM genesis__applications__c
                                                                        WHERE genesis__account__c = :objAccount.Id
                                                                        AND genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                                                                        AND Dealer_Name__c=: appCreated.Dealer_Name__c
                                                                        ORDER BY CreatedDate DESC
                                                                        LIMIT 1];
        if(latestExistingApp.size() > 0){
            List<clcommon__Party__c> existingPartyList = [SELECT Id,  
                                                                clcommon__Account__r.genesis__Business_Information__r.genesis__Total_Assets__c,
                                                                clcommon__Account__r.genesis__Business_Information__r.genesis__Total_Liabilities__c,
                                                                clcommon__Account__c,
                                                                clcommon__Account__r.genesis__Business_Information__c,
                                                                clcommon__Type__c,
                                                                clcommon__Type__r.Name, 
                                                                clcommon__Contact__c, 
                                                                clcommon__Party_Types__c, 
                                                                genesis__Application__c,
                                                                clcommon__Account__r.Has_Past_Due__c,
                                                                clcommon__Account__r.Non_Accrual__c 
                                                            FROM clcommon__Party__c 
                                                            WHERE genesis__Application__c =: latestExistingApp[0].Id
                                                            AND clcommon__Type__r.Name IN (
                                                                    :PortalConstants.PRINCIPAL_PARTY_NAME,
                                                                    :PortalConstants.SPOUSE_PARTY_NAME,
                                                                    :PortalConstants.LANDOWNER_PARTY_NAME,
                                                                    :PortalConstants.BUYER_PARTY_NAME,
                                                                    :PortalConstants.INSURANCE_AGENT_PARTY_NAME
                                                            )];

            for (clcommon__Party__c objExistingParty: existingPartyList) {
                clcommon__Party__c objParty = new clcommon__Party__c();
                objParty.genesis__Application__c = appCreated.Id;
                objParty.clcommon__Account__c = objExistingParty.clcommon__Account__c;
                objParty.clcommon__Contact__c = objExistingParty.clcommon__Contact__c;
                objParty.clcommon__Type__c = objExistingParty.clcommon__Type__c;
                objParty.clcommon__Party_Types__c = objExistingParty.clcommon__Type__r.Name;
                newPartyList.add(objParty);
            }
            Database.insert(newPartyList, true); 
        }
    }


    
    /**
    * @description Purpose of this method is to create the primary applicant party
    * @param objApplication 
    * @param objContact 
    * @param mapOfpartyType 
    **/
    public static void createPrimaryApplicantParty(genesis__Applications__c objApplication, Contact objContact,  Map<String, Id> mapOfpartyType){
        List<Contact> objContactList;
        Map<String, Id> mapOfLegalEntity = PortalHelper.getLegalEntityMap();

        if (objContact.Email == null || String.isBlank(objContact.Email)) {
            objContactList = [SELECT Id,
                                    AccountId,
                                    Account.clcommon__Legal_Entity_Type__c,
                                    ints__Middle_Name__c,
                                    genesis__SSN__c
                             FROM Contact
                             WHERE genesis__SSN__c = :objContact.genesis__SSN__c
                             AND (Account.clcommon__Legal_Entity_Type__r.Name = :PortalConstants.SOLE_PROP_ENTITY
                             OR Account.clcommon__Legal_Entity_Type__c = null)];

           
        } else {
            objContactList = [SELECT Id,
                                    AccountId,
                                    ints__Middle_Name__c
                             FROM Contact
                             WHERE genesis__SSN__c = :objContact.genesis__SSN__c
                             AND email = :objContact.Email
                             AND (Account.clcommon__Legal_Entity_Type__r.Name = :PortalConstants.SOLE_PROP_ENTITY
                             OR Account.clcommon__Legal_Entity_Type__c = null)];
        }
       
        if(objContactList.size() == 0){
            genesis__Business_Information__c objBusinessInformation = new genesis__Business_Information__c();
            Database.Insert(objBusinessInformation, true);
            Account objPrimaryAccount = new Account();
            objPrimaryAccount.Name = objContact.LastName+ ', '+ objContact.FirstName;
            objPrimaryAccount.genesis__Business_Information__c = objBusinessInformation.Id;
            objPrimaryAccount.clcommon__Legal_Entity_Type__c = mapOfLegalEntity.get(PortalConstants.SOLE_PROP_ENTITY);
            objPrimaryAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.CO_APPLICATION_RECORD_TYPE).getRecordTypeId();
            objPrimaryAccount.clcommon__Email__c = objContact.Email;
            objPrimaryAccount.OwnerId = PortalSecurityUtil.getSiteAdmin();

            objPrimaryAccount.Phone = objContact.MobilePhone;
            objPrimaryAccount.Home_Number__c = objContact.HomePhone;
            objPrimaryAccount.Work_Number__c = objContact.Phone;

            Database.Insert(objPrimaryAccount, true);

            objContact.AccountId = objPrimaryAccount.Id;
            objContact.OwnerId = PortalSecurityUtil.getSiteAdmin();
            Database.Insert(objContact, true);
            clcommon__Party__c objCLParty = new clcommon__Party__c();
            objCLParty.genesis__Application__c = objApplication.Id;
            objCLParty.clcommon__Account__c = objContact.AccountId;
            objCLParty.clcommon__Contact__c = objContact.Id;
            objCLParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.PRINCIPAL_PARTY_NAME);
            objCLParty.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;
            Database.Insert(objCLParty, true);

           
        }
        else {
            objContactList[0].FirstName = objContact.FirstName;
            objContactList[0].Lastname = objContact.LastName;
            objContactList[0].ints__Middle_Name__c = objContact.ints__Middle_Name__c;

            objContactList[0].MobilePhone = objContact.MobilePhone;
            objContactList[0].HomePhone = objContact.HomePhone;
            objContactList[0].Phone = objContact.Phone;

            Database.Update(objContactList[0], true);

            List<Account> objAccountList = [SELECT Id, Work_Number__c, Home_Number__c, Phone, Name
                                            FROM Account
                                            WHERE Id =: objContactList[0].AccountId
                                            ];
            objAccountList[0].Phone = objContact.MobilePhone;
            objAccountList[0].Home_Number__c = objContact.HomePhone;
            objAccountList[0].Work_Number__c = objContact.Phone;

            objAccountList[0].Name = objContact.LastName + ', ' + objContact.FirstName;

            Database.Update(objAccountList[0], true);

            clcommon__Party__c objCLParty = new clcommon__Party__c();
            objCLParty.genesis__Application__c = objApplication.Id;
            objCLParty.clcommon__Account__c = objContactList[0].AccountId;
            objCLParty.clcommon__Contact__c = objContactList[0].Id;
            objCLParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.PRINCIPAL_PARTY_NAME);
            objCLParty.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;
            Database.Insert(objCLParty, true);
        }
    }

   
    /**
    * @description Purpose of this method is to update the borrower party
    * @param applicationId 
    **/
    public static void updateBorrowerParty(String applicationId){

        List<clcommon__party__c> objBorrowerParty = [SELECT Id,
                                                            clcommon__Contact__c
                                                     FROM clcommon__party__c
                                                     WHERE genesis__Application__c =: applicationId
                                                     AND clcommon__Type__r.Name =: PortalConstants.BORROWER_PARTY_NAME];
        
        genesis__Applications__c objApplication = [SELECT Id,
                                                          genesis__Contact__c,
                                                          genesis__Account__c,
                                                          Dealer_Name__c
                                                   FROM genesis__Applications__c
                                                   WHERE Id =: applicationId];                                         
        if (objBorrowerParty==null || objBorrowerParty.isEmpty()){
            clcommon__Party__c objParty = new clcommon__Party__c();
            objParty.genesis__Application__c = applicationId;
            objParty.clcommon__Account__c = objApplication.genesis__Account__c;
            objParty.clcommon__Contact__c = objApplication.genesis__Contact__c;
            List<clcommon__Party_Type__c> partyType = [SELECT Id
                                                       FROM clcommon__Party_Type__c
                                                       WHERE NAME =: PortalConstants.BORROWER_PARTY_NAME];
            objParty.clcommon__Type__c = partyType[0].Id;
            objParty.clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;
            Database.upsert(objParty, true);
        }
        else{
            objBorrowerParty[0].clcommon__Contact__c = objApplication.genesis__Contact__c;
            objBorrowerParty[0].clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;   
            Database.upsert(objBorrowerParty, true);    
        }

        Account objAccount = [SELECT Id, 
                                    OwnerId,
                                    ParentId
                                FROM Account
                                WHERE Id=: objApplication.genesis__Account__c];
        objAccount.OwnerId = PortalSecurityUtil.getSiteAdmin();
        if(String.isBlank(objAccount.ParentId)){
            objAccount.ParentId = objApplication.Dealer_Name__c;
        }
        Database.Update(objAccount, true);

        Contact objContact = [SELECT Id, 
                                     AccountId
                              FROM Contact
                              WHERE Id = :objApplication.genesis__Contact__c];
        objContact.AccountId = objApplication.genesis__Account__c;
        Database.update(objContact, true);
    }

    /**
    * @description 
    * @param objAccount 
    * @param objPrimaryApplicant 
    * @param objContact 
    **/
    public static void populateDBAApplicant (Account objAccount, Contact objPrimaryApplicant, Contact objContact){
        objAccount.Is_Individual__c = false;

        // mandatory co-applicants detail for a dba
        objPrimaryApplicant.Id = objContact.Id;
        objPrimaryApplicant.AccountId = objContact.AccountId;
        objPrimaryApplicant.FirstName =  objContact.FirstName;
        objPrimaryApplicant.LastName = objContact.LastName;
        
        objPrimaryApplicant.MobilePhone = objContact.MobilePhone;
        objPrimaryApplicant.HomePhone = String.isBlank(objContact.HomePhone) ? '' : objContact.HomePhone;
        objPrimaryApplicant.Phone = String.isBlank(objContact.Phone) ? '' : objContact.Phone;

        objContact.MobilePhone = '';
        objContact.HomePhone = '';
        objContact.Phone = '';

        objAccount.Work_Number__c = '';
        objAccount.Home_Number__c = '';
        objAccount.Phone = '';

        if (objContact.Email != null) {
            objPrimaryApplicant.Email = objContact.Email;
        }

        if (objContact.Confirm_Email__c != null) {
            objPrimaryApplicant.Confirm_Email__c = objContact.Confirm_Email__c;
        }
        
        objPrimaryApplicant.genesis__SSN__c = objContact.genesis__SSN__c;
        objPrimaryApplicant.Confirm_SSN__c = objContact.Confirm_SSN__c;

        objAccount.clcommon__Email__c = null;

        // details for the primary applicant contact - business / dba 
        objContact.LastName = objAccount.Name;
        objContact.FirstName = null;
        objContact.Id = null;
        objContact.AccountId = null;
        objContact.genesis__SSN__c = null;
        objContact.Confirm_SSN__c = null;
        objContact.Email = objAccount.clcommon__Email__c;
        objContact.Confirm_Email__c = null;
    }

    /**
    * @description 
    * @param accountObj 
    * @param priApplicantContact 
    * @param contactObj 
    **/
    public static void populateCorporationCoApplicant(Account accountObj, Contact priApplicantContact, Contact contactObj){
        // here objAccount stores the account of the primary applicant i.e. business
        // here objContact stores the contact of the mandatory co-applicant
        
        accountObj.Is_Individual__c = false;

        // mandatory co-applicants detail for a business
        priApplicantContact.Id = contactObj.Id;
        priApplicantContact.AccountId = contactObj.AccountId;
        priApplicantContact.FirstName =  contactObj.FirstName;
        priApplicantContact.LastName = contactObj.LastName;

        priApplicantContact.MobilePhone = contactObj.MobilePhone;
        priApplicantContact.HomePhone = String.isBlank(contactObj.HomePhone) ? PortalConstants.EMPTY_STRING : contactObj.HomePhone;
        priApplicantContact.Phone = String.isBlank(contactObj.Phone) ? PortalConstants.EMPTY_STRING : contactObj.Phone;


        if (contactObj.Email != null) {
            priApplicantContact.Email = contactObj.Email;
        }

        if (contactObj.Confirm_Email__c != null) {
            priApplicantContact.Confirm_Email__c = contactObj.Confirm_Email__c;
        }
        
        priApplicantContact.genesis__SSN__c = contactObj.genesis__SSN__c;
        priApplicantContact.Confirm_SSN__c = contactObj.Confirm_SSN__c;

        // details for the primary applicant contact - business / dba 
        contactObj.LastName = accountObj.Name;
        contactObj.FirstName = null;
        contactObj.Id = null;
        contactObj.AccountId = null;
        contactObj.genesis__SSN__c = null;
        contactObj.Confirm_SSN__c = null;
        contactObj.Email = accountObj.clcommon__Email__c;
        contactObj.Confirm_Email__c = accountObj.Confirm_Email__c;
    }

    /**
    * @description 
    * @param loggedInUser 
    * @param objApplication 
    **/
    public static void createSharingRecords(User loggedInUser, genesis__Applications__c objApplication) {
        List<clcommon__Relationship__c> relations = [SELECT Id, 
                                                            clcommon__Entity__c,
                                                            clcommon__Related_Entity__c, 
                                                            clcommon__Relationship__r.Name
                                                    FROM clcommon__Relationship__c
                                                    WHERE clcommon__Entity__c = :loggedInUser.Account.ParentId
                                                    AND clcommon__Relationship__r.Name IN (
                                                            :PortalConstants.CERTIFIED_LENDER, 
                                                            :PortalConstants.CERTIFIED_LENDER_PLUS,
                                                            :PortalConstants.INQUIRY,
                                                            :PortalConstants.INQUIRY_PLUS,
                                                            :PortalConstants.FIELD_STAFF_AGENT
                                                        )
                                                    ];
      
        List<String> relationIdList = new List<String>();

        for (clcommon__Relationship__c relation : relations) {
            // getting all the certified lenders account id in a list  
            relationIdList.add(relation.clcommon__Related_Entity__c);
        }

        List<User> clUsers = [SELECT Id,
                                    Account.RecordType.Name 
                              FROM User 
                              WHERE AccountId IN :relationIdList];

        List<clcommon__Document_Category__c> documentCategories = [SELECT Id 
                                                                   FROM clcommon__Document_Category__c 
                                                                   WHERE genesis__Application__c = :objApplication.Id];

        List<genesis__Applications__Share> applicationSharingRecords = new List<genesis__Applications__Share>();
        List<clcommon__Document_Category__Share> documentSharingRecords = new List<clcommon__Document_Category__Share>();

        for (User clUser : clUsers) {
            genesis__Applications__Share applicationSharingRecord = new genesis__Applications__Share();

            applicationSharingRecord.AccessLevel = 'edit';
            applicationSharingRecord.ParentId = objApplication.Id;
            applicationSharingRecord.UserOrGroupId = clUser.Id;

            applicationSharingRecords.add(applicationSharingRecord);

            for (clcommon__Document_Category__c documentCategory : documentCategories) {

                clcommon__Document_Category__Share documentSharingRecord = new clcommon__Document_Category__Share();

                documentSharingRecord.AccessLevel = 'edit';
                documentSharingRecord.ParentId = documentCategory.Id;
                documentSharingRecord.UserOrGroupId = clUser.Id;

                documentSharingRecords.add(documentSharingRecord);
            }
        }

        Database.upsert(applicationSharingRecords, false);
        Database.upsert(documentSharingRecords, false);
    }

    /**
    * @description 
    * @param accountObj 
    * @param contactObj 
    **/
    public static void nullifyContactNumbers(Account accountObj, Contact contactObj){
        if (contactObj != null) {
            if (String.isBlank(contactObj.MobilePhone)) {
                contactObj.MobilePhone = PortalConstants.EMPTY_STRING;
            }

            if (String.isBlank(contactObj.HomePhone)) {
                contactObj.HomePhone = PortalConstants.EMPTY_STRING;
            }

            if (String.isBlank(contactObj.Phone)) {
                contactObj.Phone = PortalConstants.EMPTY_STRING;
            }
        }
        // updating account phone fields if null value is sent
        if (accountObj != null) {
            if (String.isBlank(accountObj.Work_Number__c)) {
                accountObj.Work_Number__c = PortalConstants.EMPTY_STRING;
            }

            if (String.isBlank(accountObj.Home_Number__c)) {
                accountObj.Home_Number__c = PortalConstants.EMPTY_STRING;
            }

            if (String.isBlank(accountObj.Phone)) {
                accountObj.Phone = PortalConstants.EMPTY_STRING;
            }
        }
    }

    /**
    * @description 
    * @param applicationId 
    **/
    public static void updatePrincipalCoopType(String applicationId){
        List<String> accountIdList = new List<String>();
        String coopType = PortalConstants.EMPTY_STRING;
        //Query all the Principal Party and update the coop type on the coapplicant
        List<clcommon__Party__c> principalList = [SELECT Id,
                                                        clcommon__Account__c,
                                                        genesis__Application__r.Coop_Type__c,
                                                        genesis__Application__r.Dealer_Name__r.Coop_Type__c
                                                FROM clcommon__Party__c
                                                WHERE genesis__Application__c = :applicationId AND 
                                                    clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME];
        for(clcommon__Party__c eachParty : principalList){
            accountIdList.add(eachParty.clcommon__Account__c);
            coopType = eachParty.genesis__Application__r.Dealer_Name__r.Coop_Type__c;
        }
        List<Account> principalAccountList = [SELECT Id,
                                                    Coop_Type__c,
                                                    RecordTypeId
                                            FROM Account
                                            WHERE Id IN :accountIdList];
        for(Account eachAccount : principalAccountList){
            if(eachAccount.RecordTypeId != Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId()){
                eachAccount.Coop_Type__c = coopType;
                eachAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.CO_APPLICATION_RECORD_TYPE).getRecordTypeId();
            }
        }
        Database.update(principalAccountList,true);
    }

    
    
    /**
    * @description 
    * @author Kabir Pramanik | 07-25-2024 
    * @param accountId 
    * @param growerEmail 
    * @param appCreated 
    **/
    public static void sendEmailToGrower(String accountId,String growerEmail, genesis__Applications__c appCreated){

        List<User> userList = new List<User>();
        List<EmailTemplate> emailTemplateList = new List<EmailTemplate>();
        genesis__Applications__c applicationCreatedList = new genesis__Applications__c();
        String dealerCity = PortalConstants.EMPTY_STRING;
        String dealerState = PortalConstants.EMPTY_STRING;
        String certifiedLenderName = PortalConstants.EMPTY_STRING;
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();                                          
        Messaging.SingleEmailMessage email = new  Messaging.SingleEmailMessage();
        Messaging.SendEmailResult[] result;
        String emailIdToSend = PortalConstants.EMPTY_STRING;
        String emailBody = PortalConstants.EMPTY_STRING;
        String dealerName = PortalConstants.EMPTY_STRING;
        String dealerId = PortalConstants.EMPTY_STRING;
        String coopType = PortalConstants.EMPTY_STRING;
        String emailStatus = PortalConstants.EMPTY_STRING;
        String coopShortName = PortalConstants.EMPTY_STRING;
        List<OrgWideEmailAddress> senderAddressList = new List<OrgWideEmailAddress>();


        userList = [SELECT Id
                            FROM User
                            WHERE AccountId =: accountId];

        applicationCreatedList=[SELECT  Id,
                                Dealer_Name__r.Name,
                                Dealer_Name__r.BillingCity,
                                Dealer_Name__r.BillingState,
                                Dealer_Name__r.Coop_Type__c,
                                Certified_Lender__r.Name,
                                Certified_Lender__r.clcommon__Email__c,
                                Dealer_Name__r.CFA_Partner_Program__r.Short_Name__c,
                                Dealer_Name__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c
                            FROM genesis__Applications__c
                            WHERE Id = :appCreated.Id];
        dealerName = applicationCreatedList.Dealer_Name__r.Name;
        dealerId = applicationCreatedList.Dealer_Name__c;

        checkBlankParameter(dealerId,PortalConstants.SOMETHING_WENT_WRONG);

        if(initiationEmailRequired(userList, applicationCreatedList.Dealer_Name__r.Coop_Type__c)){
            return;
        }

        coopType = applicationCreatedList.Dealer_Name__r.Coop_Type__c;
        if(coopType != PortalConstants.GROWMARK_COOP_TYPE){
            coopShortName = applicationCreatedList.Dealer_Name__r.CFA_Partner_Program__r.Short_Name__c;
        }

        if (applicationCreatedList.Dealer_Name__r.BillingCity != null) {
            dealerCity = applicationCreatedList.Dealer_Name__r.BillingCity;
        }
        if (applicationCreatedList.Dealer_Name__r.BillingState != null) {
            dealerState = applicationCreatedList.Dealer_Name__r.BillingState;
        }
        if (applicationCreatedList.Certified_Lender__c != null) {
            certifiedLenderName = applicationCreatedList.Certified_Lender__r.Name;
        }
        
        emailTemplateList = [SELECT Id,
                                    Name,
                                    Body,
                                    Subject,
                                    HtmlValue
                                FROM EmailTemplate
                                WHERE Name =:PortalConstants.GROWER_COMPLETE_APPLICATION];

        emailBody = emailTemplateList[0].HtmlValue;

        emailBody = emailBody.replace(GROWER_LINK,
                                        (coopType == PortalConstants.GROWMARK_COOP_TYPE ? 
                                            ConstantValues.GMK_GROWER_URL :
                                            ConstantValues.GROWER_URL + PortalConstants.REPLACE_COOP_KEY + coopShortName.toLowerCase()
                                        )
                                    );
        emailIdToSend = String.valueOf(growerEmail);
        senderAddressList = PortalApplicationOriginationHelper.getOrgWideEmailAddress(ConstantValues.ORG_WIDE_NO_REPLY_EMAIL_ADDRESS);
        email.setOrgWideEmailAddressId(senderAddressList[0].Id);
        emailBody = emailBody.replace(DEALER_NAME, dealerName);
        emailBody = emailBody.replace(PortalConstants.REPLACE_DEALER_CITY,dealerCity);
        emailBody = emailBody.replace(PortalConstants.REPLACE_DEALER_STATE,dealerState);
        emailBody = emailBody.replace(PortalConstants.REPLACE_DEALER_NAME,certifiedLenderName);
        emailBody = emailBody.replace(PortalConstants.REPLACE_LOGO_URL, EmailUtil.setLogoURL(dealerId));
        email.subject = emailTemplateList[0].Subject.replace(DEALER_NAME, dealerName);
                email.setHtmlBody(emailBody);
        email.setTemplateId(emailTemplateList[0].Id);
        email.setToAddresses(new String[] {emailIdToSend});
        emailsToSend.add(email);
        result = Messaging.sendEmail(emailsToSend);
        emailStatus = result[0].isSuccess()?ConstantValues.SUCCESS_STATUS : ConstantValues.FAILURE_STATUS;

        Map<String,Object> emailLogMap = new Map<String,Object>{
            ConstantValues.KEY_FROM_ADDRESS => applicationCreatedList.Certified_Lender__r.clcommon__Email__c,
            ConstantValues.KEY_TO_ADDRESS => emailIdToSend,
            ConstantValues.KEY_EMAIL_TEMPLATE => emailTemplateList[0].Name,
            ConstantValues.KEY_MESSAGE => emailBody,
            ConstantValues.KEY_CLASS_NAME => PortalSendApplicationToGrowerAPI.class.getName(),
            ConstantValues.KEY_EMAIL_STATUS => emailStatus
        };
        if(emailStatus == ConstantValues.FAILURE_STATUS){
            emailLogMap.put(ConstantValues.KEY_ERROR_MESSAGE,result[0].getErrors()[0].getMessage());
        }
        clcommon__Notification__c notificationObj = EmailUtil.getEmailLog(emailLogMap);
        Database.insert(notificationObj, PortalConstants.TRUE_VALUE);
        
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 15-02-2025 
    * @param userList 
    * @param coopType 
    * @return boolean 
    **/
    private static boolean initiationEmailRequired(List<User> userList, String coopType){
        if(userList.isEmpty()){
            return true;
        }
        String permissionName = coopType == PortalConstants.GROWMARK_COOP_TYPE ? PortalConstants.WHITE_LABEL_COOP_TYPE : PortalConstants.GREY_LABEL_COOP_TYPE;

        List<PermissionSetAssignment> psaList = [SELECT id FROM PermissionSetAssignment WHERE AssigneeId = :userList[0].Id AND permissionSet.Name = :permissionName];

        if(psaList.isEmpty()){
            return true;
        }
        return false;
    }
    
    /**
    * @description  this method is used to set the account fields as empty if no value is set from applicant info page
    * @author Rahul Gupta | 03-12-2024 
    * @param accountObj 
    * @param coopType 
    * @return Account 
    **/
    public static Account setNullIfEmpty(Account accountObj, String coopType) {
        String legalEntity = getLegalEntityByAccount(accountObj);
        
        accountObj.Work_Number__c = returnEmptyStringForField(accountObj.Work_Number__c);
        accountObj.Phone = returnEmptyStringForField(accountObj.Phone);
        accountObj.Home_Number__c = returnEmptyStringForField(accountObj.Home_Number__c);

        accountObj.clcommon__Email__c = accountObj.clcommon__Email__c == null ? PortalConstants.EMPTY_STRING : accountObj.clcommon__Email__c;
        accountObj.Confirm_Email__c = accountObj.Confirm_Email__c == null ? PortalConstants.EMPTY_STRING : accountObj.Confirm_Email__c;

        accountObj.Billing_County__c = returnEmptyStringForField(accountObj.Billing_County__c);
        accountObj.BillingPostalCode = returnEmptyStringForField(accountObj.BillingPostalCode);
        accountObj.BillingState = returnEmptyStringForField(accountObj.BillingState);
        accountObj.BillingCity = returnEmptyStringForField(accountObj.BillingCity);
        accountObj.BillingStreet = returnEmptyStringForField(accountObj.BillingStreet);


        if(legalEntity == PortalConstants.SOLE_PROP_ENTITY){
            accountObj.Year_Began_Farming__c = accountObj.Year_Began_Farming__c == null ? null : accountObj.Year_Began_Farming__c;
        }
        return accountObj;
    }

    /**
    * @description returns an empty string if the value of the field is null or the field is blank.
    * @author Rakesh Saraf | 12-24-2024 
    * @param fieldValue 
    * @return String 
    **/
    public static String returnEmptyStringForField(String fieldValue){
        if(fieldValue==null || String.isBlank(fieldValue)){
            return PortalConstants.EMPTY_STRING;
        }
        return fieldValue;
    }

   
    /**
    * @description this method is used to set the contact fields as empty if no value is set from applicant info page
    * @author Rahul Gupta | 03-12-2024 
    * @param contactObj 
    * @param coopType 
    * @return Contact 
    **/
    public static Contact setNullIfEmpty(Contact contactObj, String coopType) {
        contactObj.FirstName = returnEmptyStringForField(contactObj.FirstName);
        contactObj.ints__Middle_Name__c = returnEmptyStringForField(contactObj.ints__Middle_Name__c);

        contactObj.MailingStreet = returnEmptyStringForField(contactObj.MailingStreet);
        contactObj.MailingCity = returnEmptyStringForField(contactObj.MailingCity);
        contactObj.MailingState = returnEmptyStringForField(contactObj.MailingState);
        contactObj.MailingPostalCode = returnEmptyStringForField(contactObj.MailingPostalCode);
        contactObj.Mailing_County__c = returnEmptyStringForField(contactObj.Mailing_County__c);

        contactObj.MobilePhone = returnEmptyStringForField(contactObj.MobilePhone);
        contactObj.HomePhone = returnEmptyStringForField(contactObj.HomePhone);
        contactObj.Phone = returnEmptyStringForField(contactObj.Phone);

        contactObj.Suffix__c = contactObj.Suffix__c == null ? PortalConstants.EMPTY_STRING : contactObj.Suffix__c;

        contactObj.clcommon__Marital_Status__c = contactObj.clcommon__Marital_Status__c == null ? PortalConstants.EMPTY_STRING : contactObj.clcommon__Marital_Status__c;
        contactObj.Birthdate = contactObj.Birthdate == null ? null : contactObj.Birthdate;
        contactObj.Email = contactObj.Email == null ? PortalConstants.EMPTY_STRING : contactObj.Email;
        contactObj.Confirm_Email__c = contactObj.Confirm_Email__c == null ? PortalConstants.EMPTY_STRING : contactObj.Confirm_Email__c;

        if (coopType == PortalConstants.GROWMARK_COOP_TYPE) {
            contactObj.genesis__SSN__c = returnEmptyStringForField(contactObj.genesis__SSN__c);

            contactObj.Confirm_SSN__c = returnEmptyStringForField(contactObj.Confirm_SSN__c);
        }

        return contactObj;
    }

    
    /**
    * @description  this method is used to set the business info fields as empty if no value is set from applicant info page
    * @author Rahul Gupta | 03-12-2024 
    * @param businessInfoObj 
    * @param coopType 
    * @return genesis__Business_Information__c 
    **/
    public static genesis__Business_Information__c setNullIfEmpty(genesis__Business_Information__c businessInfoObj, String coopType) {

        if (coopType == PortalConstants.GROWMARK_COOP_TYPE) {
            businessInfoObj.Confirm_Tax_Identification_Number__c = 
                businessInfoObj.Confirm_Tax_Identification_Number__c == null ? PortalConstants.EMPTY_STRING : businessInfoObj.Confirm_Tax_Identification_Number__c;
            businessInfoObj.genesis__Tax_Identification_Number__c = 
                businessInfoObj.genesis__Tax_Identification_Number__c == null ? PortalConstants.EMPTY_STRING : businessInfoObj.genesis__Tax_Identification_Number__c;
        }
        
        businessInfoObj.genesis__State_of_Incorporation__c = 
            businessInfoObj.genesis__State_of_Incorporation__c == null ? PortalConstants.EMPTY_STRING : businessInfoObj.genesis__State_of_Incorporation__c;

        businessInfoObj.Gross_Farm_Income__c = 
            businessInfoObj.Gross_Farm_Income__c == null ? null : businessInfoObj.Gross_Farm_Income__c;

        return businessInfoObj;
    }

    /**
     * @description Purpose of this method is to check/update the email field for Email - Docusign.
     * @param applicantDetailsList 
     * @param objPartyList 
     * @param signingMethod 
     * @exception 
     */
    public static void checkEmailDetails(List<Object> applicantDetailsList, List<clcommon__Party__c> objPartyList, String signingMethod){
        
        List<Contact> partyContactList = new List<Contact>();
        List<Account> partyAccountList = new List<Account>();
        Map<String, String> mapOfParty = new Map<String, String>();
        for(Object party : applicantDetailsList){
            Map<String, Object> temporaryApplicationMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(party));
            mapOfParty.put(String.valueOf(temporaryApplicationMap.get(PortalConstants.PARTY_ID)), String.valueOf(temporaryApplicationMap.get(PortalConstants.COAPPLICANT_CONTACT_EMAIL_KEY)));
        }

        for(clcommon__Party__c partyObj : objPartyList){
            Contact contactObj = new Contact(Id= partyObj.clcommon__contact__c);

            Account accountObj=new Account(Id=partyObj.clcommon__Account__c);
            accountObj.Kyc_Verified__c=PortalConstants.TRUE_VALUE;

            if(mapOfParty.get(partyObj.Id) != null){
                if(!partyObj.clcommon__Account__r.Kyc_Verified__c){
                    contactObj.Email = mapOfParty.get(partyObj.Id);
                    contactObj.Confirm_Email__c = mapOfParty.get(partyObj.Id);

                    accountObj.clcommon__Email__c=contactObj.Email;
                    accountObj.Confirm_Email__c=contactObj.Confirm_Email__c;
                }
            }
            else{
                if(partyObj.clcommon__Account__r.Is_Individual__c && (signingMethod == PortalConstants.EMAIL_DOCUSIGN | signingMethod == PortalConstants.IN_PERSON_DOCUSIGN)){
                    throw new CustomException(PortalConstants.EMAIL_FIELD_MISSING);
                }
            }
            partyContactList.add(contactObj);
            partyAccountList.add(accountObj);
        }
        if(!partyContactList.isEmpty() & !partyAccountList.isEmpty()){
            Database.update(partyContactList, true);
            Database.update(partyAccountList, true);
        }
    }
    /**
     * @description Checks the Signed agreement task as required if Paper Scanned is chosen as Signing Method and unchecks it if email docusign is chosen
     * @param signingMethod 
     * @param applicationId 
     * @exception 
     */
    public static void checkSignAgreementTask(String signingMethod, String applicationId){
        final String SIGNING_TASK = 'Signed Credit Agreement';
        final String OPEN_TASK_STATUS = 'OPEN';
            //Query the task for Signing while Paper Scanned is Chosen
        List<Task> signedAgreementTaskList = [SELECT Id, 
                                                Subject,
                                                Status
                                        FROM Task
                                        WHERE Subject = :SIGNING_TASK AND 
                                        genesis__Application__c = :applicationId];
        if(signedAgreementTaskList == null){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        if(signingMethod == PortalConstants.EMAIL_DOCUSIGN ||
            signingMethod == PortalConstants.IN_PERSON_DOCUSIGN ){
                //Task is not required
                signedAgreementTaskList[0].Status = OPEN_TASK_STATUS;
        }
        else{
            //Task is Required
            signedAgreementTaskList[0].Status = PortalConstants.COMPLETED_TASK_STATUS;
        }
        Database.update(signedAgreementTaskList,true);
        }
    
    /**
     * @description Check  if there is any principal for application of entity type Corporation and DBA
     * @param objPartyListToValidate 
     * @exception 
     */
    public static void checkCoApplicant(List<clcommon__Party__c> objPartyListToValidate){
        if(objPartyListToValidate.size() == 1 
                    && objPartyListToValidate[0].clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name != PortalConstants.INDIVIDUAL 
                    && objPartyListToValidate[0].clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name != PortalConstants.SOLE_PROP_ENTITY){
                    throw new CustomException(PortalConstants.CO_APPLICANT_MISSING);
                }
    }

    /**
     * @description Check whether total liability and total asset is present or not only if not a DBA
     * @param objIndividualParty 
     * @exception 
     */
    public static void checkAssetAndLiability(clcommon__Party__c objIndividualParty){
        // if not an DBA, then only enforce the validation
        if (objIndividualParty.clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name != PortalConstants.INDIVIDUAL_ENTITY){
            if (objIndividualParty.clcommon__Type__r.Name == PortalConstants.BORROWER_PARTY_NAME){
                checkApplicantAssetAndLiability(objIndividualParty);
            }
            if (objIndividualParty.clcommon__Type__r.Name == PortalConstants.PRINCIPAL_PARTY_NAME){
                checkCoapplicantsAssetAndLiability(objIndividualParty);
            }
        } 
    }
    /**
    * @description This method is used to validate total liability and total asset for Applicant
    * @param objIndividualParty 
    **/
    public static void checkApplicantAssetAndLiability(clcommon__Party__c objIndividualParty){
        if (objIndividualParty.Total_Assets__c == null || objIndividualParty.Total_Assets__c < 0) {
            throw new CustomException(PortalConstants.APPL_TOTAL_ASSETS_MISSING);
        }
        if (objIndividualParty.Total_Liabilities__c == null || objIndividualParty.Total_Liabilities__c < 0){
            throw new CustomException(PortalConstants.APPL_TOTAL_LIABILITIES_MISSING);
        }
    }
    /**
    * @description This method is used to validate total liability and total asset for Co-Applicant
    * @param objIndividualParty 
    **/
    public static void checkCoapplicantsAssetAndLiability(clcommon__Party__c objIndividualParty){
        if (objIndividualParty.Total_Assets__c == null || objIndividualParty.Total_Assets__c < 0) {
            throw new CustomException(PortalConstants.CO_APPL_TOTAL_ASSETS_MISSING);
        }
        if (objIndividualParty.Total_Liabilities__c == null || objIndividualParty.Total_Liabilities__c < 0){
            throw new CustomException(PortalConstants.CO_APPL_TOTAL_LIABILITIES_MISSING);
        }
    }
     /**
     * @description This method will check the list is empty or not. If empty then it will throw an exception.
     * @param listToCheck 
     * @param exceptionNameString 
     * */
    public static void checkEmptyList(List<Object> listToCheck, String exceptionNameString){
        if(listToCheck.isEmpty()){
            throw new CustomException(exceptionNameString);
        }
    }
  
    /**
     * @description This method will check the valid user.
     * @param isValidUser 
     * */
    public static void checkValidUser(Boolean isValidUser) {
        if (!isValidUser) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }

    }

   
    /**
    * @description this method is used to fetch all the sales agent admins for a particular sales agent
    * @param saAccountId 
    * @return List<Id> 
    **/
    public static List<Id> fetchSAAdmin (Id saAccountId){
        List<clcommon__Reciprocal_Role__c> rsaRoleObj = [SELECT Id,
                                                        Name
                                                        FROM clcommon__Reciprocal_Role__c
                                                        WHERE Name =: PortalConstants.RELATED_SALES_AGENT];

        List<clcommon__Relationship__c> relatedSAList = new List<clcommon__Relationship__c>();

        relatedSAList = [SELECT Id, 
                            clcommon__Entity__c, 
                            clcommon__Related_Entity__c, 
                            clcommon__Relationship__c 
                            FROM clcommon__Relationship__c 
                            WHERE clcommon__Related_Entity__c =: saAccountId 
                            AND clcommon__Relationship__c =: rsaRoleObj[0].Id];
        List<Id> saAdminAccountIdList = new List<Id>();

        for(clcommon__Relationship__c rel: relatedSAList){
            saAdminAccountIdList.add(rel.clcommon__Entity__c);
        }
        return saAdminAccountIdList;
    }
    /**
    * @description delete additional info
    * @author Ravi Ranjan | 11-30-2023 
    * @param applicationId 
    * @param recordId 
    * @param objectApiName 
    **/
    public static void deleteObjparty(String applicationId, String recordId,String objectApiName){
        if(objectApiName == 'clcommon__Party__c'){

            deleteParty(applicationId, recordId);
        }

    }
    /**
    * @description 
    * @author Ravi Ranjan | 11-29-2023 
    * @param applicationId 
    * @param recordId 
    **/
    public static void deleteParty(String applicationId, String recordId){
        
        
        List<clcommon__Party__c> partyList = [ SELECT  Id, 
                                                       clcommon__Party_Types__c,
                                                       clcommon__Account__c,
                                                       genesis__Application__r.Dealer_Name__c,
                                                       clcommon__Contact__c,
                                                       genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name
                                               FROM clcommon__Party__c
                                               WHERE Id=: recordId AND genesis__Application__c =: applicationId];                             
            if(partyList[0].clcommon__Party_Types__c.equalsIgnoreCase(PortalConstants.SPOUSE_PARTY_NAME)
                   ||partyList[0].clcommon__Party_Types__c.equalsIgnoreCase(PortalConstants.LANDOWNER_PARTY_NAME)
                   ||partyList[0].clcommon__Party_Types__c.equalsIgnoreCase(PortalConstants.INSURANCE_AGENT_PARTY_NAME)){
                       //Check for the Principal Party 
                       deletePrincipalAndOther(partyList[0]);
            }
            else if(partyList[0].clcommon__Party_Types__c.equalsIgnoreCase(PortalConstants.PRINCIPAL_PARTY_NAME)){
                genesis__Applications__c userApplication = new genesis__Applications__c(Id = applicationId);
                userApplication.Is_Evergreen__c = false;
                Database.update(userApplication, true);
                deleteDealerApplicantRelationship(partyList[0].genesis__Application__r.Dealer_Name__c, partyList[0].clcommon__Account__c);  
                deletePrincipalParty(partyList[0], applicationId);
            }
            else if(partyList[0].clcommon__Party_Types__c.equalsIgnoreCase(PortalConstants.BUYER_PARTY_NAME)){
                Database.delete(partyList[0], true);
            }

   }

    /**
    * @description : this method is used to delete the co-applicant party
    * @author Krishanu Chinya | 02-16-2024 
    * @param partyToDelete 
    * @param applicationId 
    **/
    public static void deletePrincipalParty(clcommon__Party__c partyToDelete, String applicationId){
        List<clcommon__Party__c> otherApplicationList = [SELECT Id
                                                        FROM clcommon__Party__c
                                                        WHERE genesis__Application__c !=: applicationId
                                                        AND clcommon__Account__c =:partyToDelete.clcommon__Account__c];

        //selected person doesn't have party in any other application
        //delete account and contact also
        if(otherApplicationList.isEmpty()){
            List<User> userList = [SELECT Id, 
                                        IsActive 
                                    FROM User 
                                    WHERE accountId =: partyToDelete.clcommon__Account__c];
           
            deactivateUser(partyToDelete.clcommon__Account__c);
            if(userList.isEmpty()){
                Contact contactToDelete = [SELECT Id
                                        FROM Contact
                                        WHERE Id =: partyToDelete.clcommon__Contact__c];
                Account accountToDelete = [SELECT Id
                                        FROM Account
                                        WHERE Id =: partyToDelete.clcommon__Account__c];

                Database.delete(contactToDelete, true);
                Database.delete(accountToDelete, true);
            }
        }

        Database.delete(partyToDelete, true);
    }

    /**
    * @description : deactivates a user by account id
    * @author Krishanu Chinya | 05-08-2024 
    * @param accountId 
    **/
    @future 
    public static void deactivateUser(Id accountId){
        List<User> userList = [SELECT Id, 
                                    IsActive 
                                FROM User 
                                WHERE accountId =: accountId];
        if(!userList.isEmpty()){
            userList[0].isActive = false;
            Database.update(userList[0], true);
        }
    }
   /**
    * @description 
    * @author Ravi Ranjan | 11-30-2023 
    * @param objParty 
    **/
    public static void deletePrincipalAndOther(clcommon__Party__c objParty){
        List<clcommon__Party__c> objRemainingPrincipals = [SELECT Id
                                                                    FROM clcommon__Party__c
                                                                    WHERE genesis__Application__c = :objParty.genesis__Application__c AND 
                                                                    clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME 
                                                                    ORDER BY CreatedDate ASC 
                                                                    LIMIT 1];
        if(objRemainingPrincipals.size() > 0 && 
        objParty.clcommon__Party_Types__c.equalsIgnoreCase(PortalConstants.PRINCIPAL_PARTY_NAME) &&
        (objParty.genesis__Application__r
                    .genesis__Account__r
                    .clcommon__Legal_Entity_Type__r
                    .Name != (PortalConstants.SOLE_PROP_ENTITY)) &&
        objRemainingPrincipals[0].Id ==  objParty.Id){
            genesis__Applications__c userApplication = new genesis__Applications__c(Id = objParty.genesis__Application__c);
            userApplication.Is_Evergreen__c = false;
            Database.update(userApplication, true);
            //Delete Just the party if the Primary Applicant is chosen
            Database.delete(objParty, true);
        }
        else{
            if(!String.isBlank(objParty.clcommon__Contact__c)){
                Contact objContact = [SELECT id 
                                        FROM Contact
                                        WHERE id=: objParty.clcommon__Contact__c];
                Database.delete(objContact, true);
            }
            if(!String.isBlank(objParty.clcommon__Account__c)){
                Account objAccount = [SELECT id 
                                        FROM Account
                                        WHERE id=:objParty.clcommon__Account__c];
                Database.delete(objAccount, true);
            }
            Database.delete(objParty, true);
        }
   }
   /**
    * @description delete collateral
    * @author Ravi Ranjan | 11-29-2023 
    * @param applicationId 
    * @param recordId 
    **/
    public static void deleteCollateral(String applicationId, String recordId){

        clcommon__Collateral__c objCollateral = [SELECT id 
                                                        FROM clcommon__Collateral__c
                                                        WHERE Id=: recordId AND genesis__Application__c =: applicationId];
        if(objCollateral == null){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }                                        
        Database.delete(objCollateral, true);
    }
    /**
    * @description 
    * @author Ravi Ranjan | 11-29-2023 
    * @param recordId 
    **/
    public static void deleteRateCardHeader(String recordId){
        
        String dealerId = getDealerId();
        
        List<genesis__rate_card_setup_header__c> objRateCardHeaderList =   [SELECT  id,
                                                                                    Account__c
                                                                            FROM genesis__rate_card_setup_header__c
                                                                            WHERE Id=:recordId];
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = [SELECT Id
                                                                            FROM genesis__Rate_Card_Setup_Detail__c
                                                                            WHERE genesis__Rate_Card_Setup_Header__c =: recordId];
        if(objRateCardHeaderList.size() > 0 && 
            objRateCardHeaderList[0].Account__c != null &&
            (dealerId == null || 
            objRateCardHeaderList[0].Account__c != dealerId)){
            //Dealer is not authorised
            throw new CustomException(PortalConstants.MY_PROGRAM_AUTH);
        }
        if(objRateCardHeaderList != null && objRateCardDetailList.size() > 0){
            Database.delete(objRateCardDetailList, true);
        }                                                                
        
        Database.delete(objRateCardHeaderList, true);
    }
    /**
    * @description 
    * @author Ravi Ranjan | 11-29-2023 
    * @return String 
    **/
    public static String getDealerId(){
        List<User> objLoggedInUserList =  [ SELECT Id,
                                                    ContactId,
                                                    Contact.AccountId,
                                                    Contact.Account.ParentId
                                                FROM USER
                                                WHERE Id = :UserInfo.getUserId()];
        //get the dealer id to check dealer authorisation
        String dealerId = null;
        if(objLoggedInUserList[0].Contact.Account.ParentId != null){
            dealerId = objLoggedInUserList[0].Contact.Account.ParentId;
        }
        return dealerId;
    }
    /**
    * @description deleting grower bank account
    * @author Ravi Ranjan | 11-29-2023 
    * @param recordId 
    **/
    public static void deleteBankAccount(String recordId){
        List<User> objLoggedInUserList =  [ SELECT Id,
                                                    ContactId,
                                                    Contact.AccountId,
                                                    Contact.Account.ParentId
                                                FROM USER
                                                WHERE Id = :UserInfo.getUserId()];
                                                Id recordIdType = (Id)recordId;
        clcommon__Bank_Account__c objBankAccountToDelete = [SELECT Id,
                                                                    clcommon__Contact__c,
                                                                    clcommon__Account__c
                                                            FROM clcommon__Bank_Account__c
                                                            WHERE Id = :recordIdType];
        if(objBankAccountToDelete == null){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }                                                    
        //Check the bank account belongs to the current user
        if(objBankAccountToDelete.clcommon__Contact__c == objLoggedInUserList[0].ContactId &&
            objBankAccountToDelete.clcommon__Account__c == objLoggedInUserList[0].Contact.AccountId){
                Database.delete(objBankAccountToDelete, true);
        }
        else {
            throw new CustomException(PortalConstants.GROWER_NOT_AUTHORIZED_TO_DELETE);
        }
    }
     /**
    * @description 
    * @author Ravi Ranjan | 11-30-2023 
    * @param recordId 
    **/
    public static void deleteRateCardDetail(String recordId){
        //get the dealer id to check dealer authorisation
        String dealerId = getDealerId();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardOnDescripList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardList = new List<genesis__Rate_Card_Setup_Detail__c>();
        
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList =  [ SELECT  Id,
                                                                                    Start_Date__c,
                                                                                    End_Date__c,
                                                                                    Description__c,
                                                                                    genesis__rate_card_setup_header__c,
                                                                                    genesis__rate_card_setup_header__r.genesis__End_Date__c,
                                                                                    genesis__rate_card_setup_header__r.Account__c,
                                                                                    genesis__rate_card_setup_header__r.Account__r.Coop_Type__c,
                                                                                    genesis__rate_card_setup_header__r.Crop_Year__c,
                                                                                    Special_Term_Reference__c
                                                                            FROM genesis__Rate_Card_Setup_Detail__c
                                                                            WHERE Id =: recordId];
        if((objRateCardDetailList.size() == 0 ||
               objRateCardDetailList[0].genesis__rate_card_setup_header__c == null)){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }                                                                    
        //If user is not authorised then user cannot delete the My Program
        checkUserAuthorization(dealerId, objRateCardDetailList);
        Date startDateRange = (objRateCardDetailList[0].Start_Date__c).addDays(-1);
        Date endDateRange = (objRateCardDetailList[0].End_Date__c).addDays(1);
        Integer cropYear = Integer.valueOf(objRateCardDetailList[0].genesis__rate_card_setup_header__r.Crop_Year__c);
        String coopType = (String) objRateCardDetailList[0].genesis__rate_card_setup_header__r.Account__r.Coop_Type__c;

        Map<String, List<genesis__Rate_Card_Setup_Detail__c> > paramMap = coopRateCardDetail(new Map<String, Object>{
                                                                                                                    'startDateRange' => startDateRange,
                                                                                                                    'endDateRange'  => endDateRange,
                                                                                                                    'cropYear' => cropYear,
                                                                                                                    'coopType' => coopType
                                                                                                                },objRateCardDetailList);
        objRateCardOnDescripList =  paramMap.get('objRateCardOnDescripList');
        objRateCardList =paramMap.get('objRateCardList');                                                                                                 
        
        //Check whether the Sub Tranche has any other Rates
        if(objRateCardOnDescripList.size() > 1){ 
            deleteRateCrdFrmDatabase(coopType, objRateCardList, objRateCardDetailList);
            
        }
        else{
            //Means this Rate is the last Rate under the Special Term Reference
            //Need to check if there are anymore Sub Tranches after this
            // Special Term Sub-Tranche (A)
            genesis__Rate_Card_Setup_Header__c myProgramToUpdate = new genesis__Rate_Card_Setup_Header__c(Id = objRateCardDetailList[0].genesis__rate_card_setup_header__c);
            myProgramToUpdate.Special_Term_Number__c = objRateCardDetailList[0].Special_Term_Reference__c;
            String currentSubTranche = String.valueOf(objRateCardDetailList[0].Special_Term_Reference__c).substringBetween(SPL_SUB_TRANCHE_STRING,')');
            if(currentSubTranche != 'A'){
                Integer charASCII = currentSubTranche.charAt(0);
                List<Integer> characterListFirst = new List<Integer>{charASCII+1};
                String nextCharFirst = String.fromCharArray(characterListFirst);
                String nextSubTrancheNumberFirst = SPL_SUB_TRANCHE_STRING + nextCharFirst + ')';
                List<Integer> characterListSecond = new List<Integer>{charASCII+2};
                String nextCharSecond = String.fromCharArray(characterListSecond);
                String nextSubTrancheNumberSec = SPL_SUB_TRANCHE_STRING + nextCharSecond + ')';
                List<Integer> characterListThird = new List<Integer>{charASCII+3};
                String nextCharThird = String.fromCharArray(characterListThird);
                String nextSubTrancheNumberThird = SPL_SUB_TRANCHE_STRING + nextCharThird + ')';
                List<Integer> characterListFourth = new List<Integer>{charASCII+4};
                String nextCharFourth = String.fromCharArray(characterListFourth);
                String nextSubTrancheNumberFour = SPL_SUB_TRANCHE_STRING + nextCharFourth + ')';
                
                List<genesis__Rate_Card_Setup_Detail__c> nextRateList = [SELECT Id,
                                                                                Special_Term_Reference__c
                                                                        FROM genesis__Rate_Card_Setup_Detail__c
                                                                        WHERE genesis__rate_card_setup_header__c = :objRateCardDetailList[0].genesis__Rate_Card_Setup_Header__c AND
                                                                        (Special_Term_Reference__c = :nextSubTrancheNumberFirst OR 
                                                                        Special_Term_Reference__c = :nextSubTrancheNumberSec OR
                                                                        Special_Term_Reference__c = :nextSubTrancheNumberThird OR
                                                                        Special_Term_Reference__c = :nextSubTrancheNumberFour)
                                                                        ORDER BY Special_Term_Reference__c];
                if(nextRateList.size() > 0){
                    List<genesis__Rate_Card_Setup_Detail__c> updateNextRateList = new List<genesis__Rate_Card_Setup_Detail__c>();
                    String specialTermNumber;
                    for(genesis__Rate_Card_Setup_Detail__c objEachNextRate : nextRateList){
                        specialTermNumber = objEachNextRate.Special_Term_Reference__c;
                        String subTrancheToReduce = String.valueOf(objEachNextRate.Special_Term_Reference__c).substringBetween(SPL_SUB_TRANCHE_STRING,')');
                        Integer charASCIIValue = subTrancheToReduce.charAt(0);
                        List<Integer> previousASCII = new List<Integer>{charASCIIValue-1};
                        String previousChar = String.fromCharArray(previousASCII);
                        objEachNextRate.Special_Term_Reference__c = SPL_SUB_TRANCHE_STRING + previousChar + ')';
                        updateNextRateList.add(objEachNextRate);
                        
                    }
                    Database.update(updateNextRateList, true);
                    //Update the Special Term Number field in the My program
                    
                    myProgramToUpdate.Special_Term_Number__c = specialTermNumber;
                    
                }
                Database.update(myProgramToUpdate, true);
                deleteRateCrdFrmDatabase(coopType, objRateCardList, objRateCardDetailList);
                
            }
            else{
                updateRateCardNoteRate(objRateCardDetailList, objRateCardOnDescripList, new Map<String, Object>{
                    'cropYear' => cropYear,
                    'coopType' => coopType
                });
        
            }
        }                                   
   }
  
   
    /**
    * @description 
    * @author Ravi Ranjan | 12-04-2023 
    * @param paramMap 
    * @param objRateCardDetailList 
    * @return Map<String, List<genesis__Rate_Card_Setup_Detail__c>> 
    **/
    public static Map<String, List<genesis__Rate_Card_Setup_Detail__c> > coopRateCardDetail(Map<String, Object> paramMap, List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList){
        Date startDateRange = (Date)paramMap.get('startDateRange');
        Date endDateRange = (Date)paramMap.get('endDateRange');
        String coopType = (String)paramMap.get('coopType');

        List<genesis__Rate_Card_Setup_Detail__c> objRateCardOnDescripList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardList = new List<genesis__Rate_Card_Setup_Detail__c>();

        if(coopType != PortalConstants.GROWMARK_COOP_TYPE){
            objRateCardList = [SELECT  Id,
                                    Start_Date__c,
                                    genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c
                                FROM genesis__Rate_Card_Setup_Detail__c
                                WHERE genesis__rate_card_setup_header__c = :objRateCardDetailList[0].genesis__rate_card_setup_header__c
                                AND Special_Term_Reference__c = :objRateCardDetailList[0].Special_Term_Reference__c
                                AND Start_Date__c >: startDateRange
                                AND End_Date__c <: endDateRange
                                ORDER BY Start_Date__c];

            objRateCardOnDescripList = [SELECT  Id,
                                                Start_Date__c,
                                                End_Date__c
                                        FROM genesis__Rate_Card_Setup_Detail__c
                                        WHERE genesis__rate_card_setup_header__c = :objRateCardDetailList[0].genesis__rate_card_setup_header__c
                                        AND Special_Term_Reference__c = :objRateCardDetailList[0].Special_Term_Reference__c
                                        AND genesis__Enabled_flag__c = false
                                        ORDER BY Start_Date__c];

            if(objRateCardDetailList[0].Special_Term_Reference__c == PortalConstants.SPECIAL_TERM_A &&
            objRateCardOnDescripList[0].End_Date__c == objRateCardList[0].genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c){
                throw new CustomException(PortalConstants.DELETE_MY_PROGRAM_INVALID+
                    objRateCardDetailList[0].Start_Date__c.format() + 
                    ' to '+
                    objRateCardDetailList[0].End_Date__c.format());
            }                    
            if(objRateCardList.size() > 0 && 
            objRateCardOnDescripList[0].Start_Date__c != objRateCardList[0].Start_Date__c){
                throw new CustomException(PortalConstants.DELETE_MY_PROGRAM_INVALID+
                        objRateCardDetailList[0].Start_Date__c.format() + 
                        ' to '+
                        objRateCardDetailList[0].End_Date__c.format());
            }
        }else{       
            objRateCardOnDescripList = gmkRateCardDetail(objRateCardDetailList);   
            
        }
        return new Map<String, List<genesis__Rate_Card_Setup_Detail__c> >{
               'objRateCardOnDescripList' => objRateCardOnDescripList,
               'objRateCardList' => objRateCardList
        };
        
                                   

   }
    
   /**
   * @description 
   * @author Ravi Ranjan | 11-30-2023 
   * @param objRateCardDetailList 
   * @return List<genesis__Rate_Card_Setup_Detail__c>
   **/
  public static List<genesis__Rate_Card_Setup_Detail__c> gmkRateCardDetail(List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList){
    List<genesis__Rate_Card_Setup_Detail__c> objRateCardOnDescripList = new List<genesis__Rate_Card_Setup_Detail__c>();
    objRateCardOnDescripList = [SELECT  Id, 
                                       Start_Date__c,
                                       genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c,
                                       genesis__Rate_Card_Setup_Header__r.CFA_Advantage_Rate__c,
                                       genesis__Rate_Card_Setup_Header__r.FS_Index_Rate__c
                               FROM genesis__Rate_Card_Setup_Detail__c
                               WHERE genesis__rate_card_setup_header__c = :objRateCardDetailList[0].genesis__rate_card_setup_header__c
                               AND Special_Term_Reference__c = :objRateCardDetailList[0].Special_Term_Reference__c
                               ORDER BY Start_Date__c];
       
           //we can only delete the first rate card
           if(objRateCardOnDescripList.size() > 0 &&
               objRateCardDetailList[0].Id != objRateCardOnDescripList[0].Id){
               throw new CustomException(PortalConstants.DELETE_MY_PROGRAM_INVALID+
                                           objRateCardDetailList[0].Start_Date__c.format() + 
                                           ' to '+
                                           objRateCardDetailList[0].End_Date__c.format());

           }
        return objRateCardOnDescripList;


  }
  /**
    * @description 
    * @author Ravi Ranjan | 11-30-2023 
    * @param coopType 
    * @param objRateCardList 
    * @param objRateCardDetailList 
    **/
    public static void deleteRateCrdFrmDatabase(String coopType, List<genesis__Rate_Card_Setup_Detail__c> objRateCardList, 
                                                                                List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList){
            if(coopType != PortalConstants.GROWMARK_COOP_TYPE){
                //Means that there are no more Rates under this sub tranche
                Database.delete(objRateCardList, true);
            }else{
                Database.delete(objRateCardDetailList, true);
            }

    }
    /**
    * @description 
    * @author Ravi Ranjan | 11-30-2023 
    * @param objRateCardDetailList 
    * @param objRateCardOnDescripList 
    * @param paramMap 
    **/
    public static void updateRateCardNoteRate(List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList, 
                                                   List<genesis__Rate_Card_Setup_Detail__c> objRateCardOnDescripList,
                                                   Map<String, Object>paramMap){
        Integer cropYear = (Integer)paramMap.get('cropYear');
        String coopType = (String)paramMap.get('coopType');
        objRateCardDetailList[0].Start_Date__c = System.today();
        objRateCardDetailList[0].End_Date__c = objRateCardOnDescripList[0].genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c;
        objRateCardDetailList[0].Participation_Percentage_Dealer_Subsidy__c = 0;
        objRateCardDetailList[0].Participation_Percentage_CFA__c = 0;
        objRateCardDetailList[0].Participation_Percentage_Dealer__c = 0;

        if (coopType == PortalConstants.GROWMARK_COOP_TYPE) {
            objRateCardDetailList[0].genesis__Interest_Rate__c = objRateCardOnDescripList[0].genesis__Rate_Card_Setup_Header__r.FS_Index_Rate__c;
        } else if(cropYear < NEW_RATE_CROP_YEAR){
            objRateCardDetailList[0].genesis__Interest_Rate__c = objRateCardOnDescripList[0].genesis__Rate_Card_Setup_Header__r.CFA_Advantage_Rate__c;
        } else{
            CFA_Partner_Program__c cfaPartnerProgram = [SELECT Id, Base_Rate__c FROM CFA_Partner_Program__c WHERE Name = :coopType LIMIT 1];

            if (cfaPartnerProgram != null && cfaPartnerProgram.Base_Rate__c != null) {
                clcommon__Floating_Rate_Index__c floatingRateIndex = [SELECT Current_Floating_Rate__c FROM clcommon__Floating_Rate_Index__c WHERE Id = :cfaPartnerProgram.Base_Rate__c LIMIT 1];
                
                if (floatingRateIndex != null) {
                    objRateCardDetailList[0].genesis__Interest_Rate__c = floatingRateIndex.Current_Floating_Rate__c;
                }
            }
        }
        objRateCardDetailList[0].Special_Term_Order__c = 1;
        Database.update(objRateCardDetailList, true);
    }

    /**
    * @description 
    * @author Ravi Ranjan | 12-07-2023 
    * @param dealerId 
    * @param objRateCardDetailList 
    **/
    public static void checkUserAuthorization(String dealerId, List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList){
        if(dealerId == null || 
        objRateCardDetailList[0].genesis__rate_card_setup_header__r.Account__c == null ||
        objRateCardDetailList[0].genesis__rate_card_setup_header__r.Account__c != dealerId){
        //Dealer is not authorised to delete this Special Term Tranche
            throw new CustomException(PortalConstants.SPECIAL_TERM_SUB_TRANCHE_AUTH);
        }
    }

    /**
    * @description 
    * @author Suraj Kumar | 12-29-2023 
    * @param application 
    * @param responseFieldsMap 
    **/
    public static void isLoanAmountAdjustment(genesis__Applications__c application, Map<String, Object> responseFieldsMap){
        if ((application.genesis__Credit_Rating__r.Name == ConstantValues.CREDIT_RATE_3
                || application.genesis__Credit_Rating__r.Name == ConstantValues.CREDIT_RATE_4) 
                && application.Credit_Application_And_Agreement_Process__c != 'Customized') {

                Double sumTotalCollateralsPrice = totalCollateralPrice(application.Id);

                Double requestedLoanAmount = Double.valueOf([SELECT genesis__Loan_Amount__c 
                                                            FROM genesis__Applications__c 
                                                            WHERE Id = :application.Id][0]
                                                            .genesis__Loan_Amount__c);
                if (requestedLoanAmount > sumTotalCollateralsPrice) {
                    responseFieldsMap.put(KEY_NEEDS_LOAN_AMT_ADJUSTMENT, true);
                }
            }
    }
    
    /**
    * @description 
    * @author Suraj Kumar | 12-29-2023 
    * @param collateral 
    * @param collateralPriceMap 
    **/
    public static void updateCollateralAcToInsurancePlan(clcommon__collateral__c collateral, Map<Object, clcommon__Collateral_Category__c> collateralPriceMap){
        if (collateralPriceMap.containsKey(collateral.clcommon__Collateral_Category__c)) {
            if (collateral.Insurance_Plan__c.equals(INSURANCE_PLAN_RP_VALUE) ||
                collateral.Insurance_Plan__c.equals(INSURANCE_PLAN_ARP_VALUE) ||
                collateral.Insurance_Plan__c.equals(INSURANCE_PLAN_ARH_VALUE)) {
                collateral.Price__c = collateralPriceMap.get(collateral.clcommon__Collateral_Category__c)
                                                        .Price_Per_Unit_1__c;
            } else {
                // for insurance type YP/APH/AYP/CAT/Hail only/None
                collateral.Price__c = collateralPriceMap.get(collateral.clcommon__Collateral_Category__c)
                                                        .Price_Per_Unit_2__c;
            }
        }
    }

    /**
    * @description 
    * @author Suraj Kumar | 12-27-2023 
    * @param collateral 
    * @param collateralPriceMap 
    **/
    public static void updateCollateralPrice(clcommon__collateral__c collateral, Map<Object, clcommon__Collateral_Category__c> collateralPriceMap){
        if (collateral.clcommon__Collateral_Category__c != null 
                && collateral.Total_Acres__c != null 
                && collateral.Total_Acres__c > 0 
                && isValidProducerShare(collateral)
                && collateral.Approved_Yield__c != null 
                && collateral.Approved_Yield__c >= 0 
                && collateral.Insurance_Plan__c != null) {
                    updateCollateralAcToInsurancePlan(collateral, collateralPriceMap);  
            } else {
                collateral.Price__c = 0.00;
            }
    }

    /**
    * @description 
    * @author Suraj Kumar | 01-03-2024 
    * @param collateral 
    * @return Boolean 
    **/
    public static Boolean isValidProducerShare(clcommon__collateral__c collateral){
        if (collateral.Producer_Share_Percent__c != null 
                && collateral.Producer_Share_Percent__c > 0 
                && collateral.Producer_Share_Percent__c <= 100) {
                     return true;
            }
            return false;
    }

    /**
    * @description 
    * @author Suraj Kumar | 12-27-2023 
    * @param collateral 
    * @param application 
    * @return Boolean 
    **/
    public static Boolean isCollateralBlank(clcommon__collateral__c collateral, genesis__Applications__c application){

        if(application.Does_Applicant_Feed_Above_Collaterals__c){
            if(collateral.Total_Acres__c == null &
                collateral.Producer_Share_Percent__c == null &
                collateral.Approved_Yield__c == null &
                collateral.Percent_Fed__c == null &
                collateral.clcommon__Collateral_Category__c == null &
                collateral.Insurance_Plan__c == null &
                collateral.Percent_Coverage_Level__c == null
            ){
                return true;
            }
        }else{
            if(collateral.Total_Acres__c == null &
                collateral.Producer_Share_Percent__c == null &
                collateral.Approved_Yield__c == null &
                collateral.clcommon__Collateral_Category__c == null &
                collateral.Insurance_Plan__c == null &
                collateral.Percent_Coverage_Level__c == null
            ){
                return true;
            }
        }
        return false;
    }

    /**
    * @description 
    * @author Suraj Kumar | 12-27-2023 
    * @param applicationId 
    * @return Double 
    **/
    public static Double totalCollateralPrice(Id applicationId){
        Double sumTotalCollateralsPrice = Double.valueOf([SELECT SUM(Total_Collateral_Price__c) 
                                                  FROM clcommon__Collateral__c 
                                                  WHERE genesis__Application__c = :applicationId][0].get(AGGREGATE_KEY));

        if (sumTotalCollateralsPrice == null) {
                sumTotalCollateralsPrice = 0;
        }
        return sumTotalCollateralsPrice;
    }

    /**
    * @description 
    * @author Suraj Kumar | 12-27-2023 
    * @param collaterals 
    * @param applicationId 
    **/
    public static void persistCollaterals(List<clcommon__Collateral__c> collaterals, String applicationId) {

        if (collaterals.size() == 0) {
            return;
        }

        List<Id> collateralIds = new List<Id>();
        for (clcommon__collateral__c collateral : collaterals) {
            collateralIds.add(collateral.clcommon__Collateral_Category__c);
        }

        List<clcommon__Collateral_Category__c> collateralCategories = [SELECT Id, 
                                                                            Name, 
                                                                            Collateral_Unit__c, 
                                                                            Price_Per_Unit_1__c, 
                                                                            Price_Per_Unit_2__c 
                                                                    FROM clcommon__Collateral_Category__c 
                                                                    WHERE Id IN :collateralIds];

        Map<Object, clcommon__Collateral_Category__c> collateralPriceMap = 
                                        PortalHelper.getMapOfCollateralPrices(collateralCategories);

        for (clcommon__collateral__c collateral : collaterals) {
                updateCollateralPrice(collateral,collateralPriceMap);
        }

        Database.UpsertResult[] result = Database.upsert(collaterals, true);

        List<genesis__Application_Collateral__c> applicationCollaterals = [SELECT Id, 
                                                                                    genesis__Collateral__c, 
                                                                                    genesis__Application__c 
                                                                                FROM genesis__Application_Collateral__c
                                                                                WHERE genesis__Application__c = :applicationId];

        Map<Id, genesis__Application_Collateral__c> applicationCollateralMap = 
                                    new Map<Id, genesis__Application_Collateral__c>();

        for (genesis__Application_Collateral__c applicationCollateral : applicationCollaterals) {
            applicationCollateralMap.put(applicationCollateral.genesis__Collateral__c, 
                                            applicationCollateral);
        }

        for (Database.UpsertResult savedCollateral : result) {
            // filtering out only those collaterals which doesn't have a junction
            // currently present
            if (!applicationCollateralMap.containsKey(savedCollateral.getId())) {
                applicationCollaterals.add(new genesis__Application_Collateral__c(
                                                    genesis__Collateral__c = savedCollateral.getId(),
                                                    genesis__Application__c = applicationId
                                                ));
            }
        }

        Database.upsert(applicationCollaterals, true);
    }

    /**
    * @description 
    * @author Suraj Kumar | 12-27-2023 
    * @param cropDetails 
    **/
    public static void validateCropDetails(String cropDetails){
        if (String.isBlank(cropDetails)) {
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }

    /**
    * @description 
    * @author Suraj Kumar | 12-27-2023 
    * @param spouseDetailsList 
    * @param containsPartyRecordMap 
    * @param application 
    **/
    public static void processSpouseDetails(List<Object> spouseDetailsList, Map<String, Object> containsPartyRecordMap, genesis__Applications__c application){
        for(Object objSpouseDetails : spouseDetailsList){
            Map<String, Object> spouseDetailsMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objSpouseDetails));
            if(spouseDetailsMap.isEmpty()){
                continue;
            }
            if (String.isBlank((String)spouseDetailsMap.get(FIELD_CONTACT_FIRST_NAME)) || String.isBlank((String)spouseDetailsMap.get(FIELD_CONTACT_LAST_NAME))){
                throw new CustomException(PortalConstants.SPOUSE_NAME_MISSING);
            }
            saveAdditionalInfoDetails(spouseDetailsMap, containsPartyRecordMap, PortalConstants.SPOUSE_PARTY_NAME);
            application.Additional_Information_Needed__c = true;
        }
    } 

    /**
    * @description 
    * @author Suraj Kumar | 12-27-2023 
    * @param additionalCropDetailsList 
    * @param containsPartyRecordMap 
    * @param application 
    **/
    public static void processAdditionalCropDetails(List<Object> additionalCropDetailsList, Map<String, Object> containsPartyRecordMap, genesis__Applications__c application){
        Boolean shouldValidate = Boolean.valueOf(containsPartyRecordMap.get(KEY_SAVE_TYPE));
        for(Object objAdditionalCropDetails : additionalCropDetailsList){
            Map<String, Object> additionalCropDetailsMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objAdditionalCropDetails));
            if(additionalCropDetailsMap.isEmpty()){
                continue; //@tuhin
            }
            if (String.isBlank((String)additionalCropDetailsMap.get(FIELD_ACCOUNT_NAME))){ // for Save & Exit
                throw new CustomException(PortalConstants.LANDOWNER_NAME_MISSING);
            }
            if(shouldValidate){ // for Save & Continue
                if(String.isBlank((String) additionalCropDetailsMap.get(FIELD_ACCOUNT_NAME)) 
                        ||String.isBlank((String) additionalCropDetailsMap.get(FIELDS_ACCOUNT_COUNTY))){
                    throw new CustomException(PortalConstants.LANDOWNER_DETAILS_MISSING);
                }
            }
            saveAdditionalInfoDetails(additionalCropDetailsMap, containsPartyRecordMap, PortalConstants.LANDOWNER_PARTY_NAME);
            application.Additional_Information_Needed__c = true;
        }
    }

    /**
    * @description 
    * @author Suraj Kumar | 12-27-2023 
    * @param potentialBuyerdetailsList 
    * @param containsPartyRecordMap 
    * @param application 
    **/
    public static void processPotentialBuyers(List<Object> potentialBuyerdetailsList, Map<String, Object> containsPartyRecordMap, genesis__Applications__c application){
        Boolean shouldValidate = Boolean.valueOf(containsPartyRecordMap.get(KEY_SAVE_TYPE));
        for(Object objPotentialBuyerdetails : potentialBuyerdetailsList){
            Map<String, Object> potentialBuyerdetailsMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objPotentialBuyerdetails));
            if(potentialBuyerdetailsMap.isEmpty()){
                continue; //@tuhin
            }
            if (String.isBlank((String)potentialBuyerdetailsMap.get(FIELD_ACCOUNT_NAME))){
                throw new CustomException(PortalConstants.BUYER_NAME_MISSING);
            }
            if(shouldValidate){
                validateBuyersDetails(potentialBuyerdetailsMap);
            }
            saveAdditionalInfoDetails(potentialBuyerdetailsMap, containsPartyRecordMap, PortalConstants.BUYER_PARTY_NAME);
            application.Additional_Information_Needed__c = true;
        }
    }

    /**
    * @description 
    * @author Suraj Kumar | 12-27-2023 
    * @param cropInsuranceDetailsList 
    * @param containsPartyRecordMap 
    * @param application 
    **/
    public static void processCropInsuranceDetails(List<Object> cropInsuranceDetailsList, Map<String, Object> containsPartyRecordMap, genesis__Applications__c application){
        Boolean shouldValidate = Boolean.valueOf(containsPartyRecordMap.get(KEY_SAVE_TYPE));
        for(Object objCropInsuranceDetails : cropInsuranceDetailsList){
            Map<String, Object> cropInsuranceDetailsMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objCropInsuranceDetails));
            if(cropInsuranceDetailsMap.isEmpty()){
                continue; //@tuhin
            }
            if (String.isBlank((String)cropInsuranceDetailsMap.get(FIELD_ACCOUNT_NAME))){
                throw new CustomException(PortalConstants.AGENCY_NAME_MISSING );
            }
            if(shouldValidate){
                validateInsuranceAgentDetails(cropInsuranceDetailsMap);
            }
            saveAdditionalInfoDetails(cropInsuranceDetailsMap, containsPartyRecordMap, PortalConstants.INSURANCE_AGENT_PARTY_NAME);
            application.Additional_Information_Needed__c = true;
        }
    }

    /**
    * @description 
    * @author Suraj Kumar | 12-28-2023 
    * @param potentialBuyerdetailsMap 
    **/
    public static void validateBuyersDetails(Map<String, Object> potentialBuyerdetailsMap){
        if(String.isBlank((String) potentialBuyerdetailsMap.get(FIELD_ACCOUNT_NAME))
                    || String.isBlank((String) potentialBuyerdetailsMap.get(FIELDS_ACCOUNT_STREET))
                    || String.isBlank((String) potentialBuyerdetailsMap.get(FIELDS_ACCOUNT_CITY))
                    || String.isBlank((String) potentialBuyerdetailsMap.get(FIELDS_ACCOUNT_STATE))
                    || String.isBlank((String) potentialBuyerdetailsMap.get(FIELDS_ACCOUNT_POSTAL_CODE))){
            throw new CustomException(PortalConstants.BUYER_DETAILS_MISSING);
        }
    }

    /**
    * @description 
    * @author Suraj Kumar | 12-28-2023 
    * @param cropInsuranceDetailsMap 
    **/
    public static void validateInsuranceAgentDetails(Map<String, Object> cropInsuranceDetailsMap){
        if(String.isBlank((String) cropInsuranceDetailsMap.get(FIELD_ACCOUNT_NAME))
                    || String.isBlank((String) cropInsuranceDetailsMap.get(FIELDS_ACCOUNT_STREET))
                    || String.isBlank((String) cropInsuranceDetailsMap.get(FIELDS_ACCOUNT_CITY))
                    || String.isBlank((String) cropInsuranceDetailsMap.get(FIELDS_ACCOUNT_STATE))
                    || String.isBlank((String) cropInsuranceDetailsMap.get(FIELDS_ACCOUNT_POSTAL_CODE))){
            throw new CustomException(PortalConstants.AGENCY_DETAILS_MISSING);
        }
    }

     /**
    * @description 
    * @author Suraj Kumar | 12-21-2023 
    * @param request 
    **/
    public static void validateRequestParam(Map<String, Object> request){
        if(!request.containsKey(KEY_DOES_APPLICANT_FEED_COLLATERAL) || !request.containsKey(KEY_APPLICATION)|| !request.containsKey(KEY_SPOUSE_DETAILS)
                || !request.containsKey(KEY_ADDITIONAL_CROP_DETAILS) || !request.containsKey(KEY_CROP_DETAILS)){
                        throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
                 }
    }

    /**
    * @description 
    * @author Suraj Kumar | 01-02-2024 
    * @param applicationId 
    **/
    public static void validateUser(String applicationId){
        Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationId); 
        if (!isValidUser) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }
    }

    /**
    * @description 
    * @author Suraj Kumar | 01-02-2024 
    * @param sumTotalCollateralsPrice 
    * @param responseFieldsMap 
    **/
    public static void isLoanAmountZero(Double sumTotalCollateralsPrice, Map<String, Object> responseFieldsMap){
        if (sumTotalCollateralsPrice == 0) {
            responseFieldsMap.put(KEY_LOAN_AMT_REDUCED_TO_ZERO, true);
        } else {
            responseFieldsMap.put(KEY_LOAN_AMT_REDUCED_TO_ZERO, false);
        }
    }

    /**
    * @description 
    * @author Suraj Kumar | 01-04-2024 
    * @param additionalInfoMap 
    **/
    public static void validateAdditionalInfoDetails(Map<String,String> additionalInfoMap){
        String spouseDetails = additionalInfoMap.get(SPOUSE_DETAILS);
        String additionalCropDetails = additionalInfoMap.get(ADDITIONAL_CROP_DETAILS);
        String potentialBuyerdetails = additionalInfoMap.get(POTENTIAL_BUYERS_DETAILS);
        String cropInsuranceDetails = additionalInfoMap.get(CROP_INDURANCE_DETAILS);
        // String applicationId = additionalInfoMap.get(KEY_APPLICATION);
        Boolean shouldValidate = Boolean.valueOf(additionalInfoMap.get(KEY_SAVE_TYPE));

        List<Object> spouseDetailsList = (List<Object>) JSON.deserializeUntyped (spouseDetails);
        List<Object> additionalCropDetailsList = (List<Object>) JSON.deserializeUntyped (additionalCropDetails);
        List<Object> potentialBuyerdetailsList = (List<Object>) JSON.deserializeUntyped (potentialBuyerdetails);
        List<Object> cropInsuranceDetailsList = (List<Object>) JSON.deserializeUntyped (cropInsuranceDetails);

        validateSpouseDetails(spouseDetailsList);
        validateAdditionalCropDetails(additionalCropDetailsList, shouldValidate);
        validatePotentialBuyersDetails(potentialBuyerdetailsList, shouldValidate);
        validateCropInsuranceDetails(cropInsuranceDetailsList,shouldValidate);
    }

    /**
    * @description 
    * @author Suraj Kumar | 01-04-2024 
    * @param spouseDetailsList 
    **/
    public static void validateSpouseDetails( List<Object> spouseDetailsList){
        for(Object objSpouseDetails : spouseDetailsList){
            Map<String, Object> spouseDetailsMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objSpouseDetails));
            if(spouseDetailsMap.isEmpty()){
                continue; 
            }
            if (String.isBlank((String)spouseDetailsMap.get(FIELD_CONTACT_FIRST_NAME)) || String.isBlank((String)spouseDetailsMap.get(FIELD_CONTACT_LAST_NAME))){
                throw new CustomException(PortalConstants.SPOUSE_NAME_MISSING);
            }
        }
    }
    /**
    * @description 
    * @author Suraj Kumar | 01-04-2024 
    * @param additionalCropDetailsList 
    * @param shouldValidate 
    **/
    public static void validateAdditionalCropDetails(List<Object> additionalCropDetailsList , Boolean shouldValidate){
        for(Object objAdditionalCropDetails : additionalCropDetailsList){
            Map<String, Object> additionalCropDetailsMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objAdditionalCropDetails));
            if(additionalCropDetailsMap.isEmpty()){
                continue;
            }
            if (String.isBlank((String)additionalCropDetailsMap.get(FIELD_ACCOUNT_NAME))){ // for Save & Exit
                throw new CustomException(PortalConstants.LANDOWNER_NAME_MISSING);
            }
            // if(shouldValidate){ // for Save & Continue
            //     if(String.isBlank((String) additionalCropDetailsMap.get(FIELD_ACCOUNT_NAME)) 
            //             || String.isBlank((String) additionalCropDetailsMap.get(FIELDS_ACCOUNT_STATE))
            //             || String.isBlank((String) additionalCropDetailsMap.get(FIELDS_ACCOUNT_COUNTY))){
            //         throw new CustomException(PortalConstants.LANDOWNER_DETAILS_MISSING);
            //     }
            // }
            validateAdditionalCropForSaveAndContinue(additionalCropDetailsMap, shouldValidate);
        }
    }

    /**
    * @description 
    * @author Suraj Kumar | 01-04-2024 
    * @param additionalCropDetailsMap 
    * @param shouldValidate 
    **/
    public static void validateAdditionalCropForSaveAndContinue(Map<String, Object> additionalCropDetailsMap, Boolean shouldValidate){
        if(shouldValidate){ // for Save & Continue
            if(String.isBlank((String) additionalCropDetailsMap.get(FIELD_ACCOUNT_NAME)) 
                    || String.isBlank((String) additionalCropDetailsMap.get(FIELDS_ACCOUNT_STATE))
                    || String.isBlank((String) additionalCropDetailsMap.get(FIELDS_ACCOUNT_COUNTY))){
                throw new CustomException(PortalConstants.LANDOWNER_DETAILS_MISSING);
            }
        }
    }
    /**
    * @description 
    * @author Suraj Kumar | 01-04-2024 
    * @param potentialBuyerdetailsList 
    * @param shouldValidate 
    **/
    public static void validatePotentialBuyersDetails(List<Object> potentialBuyerdetailsList, Boolean shouldValidate ){
        for(Object objPotentialBuyerdetails : potentialBuyerdetailsList){
            Map<String, Object> potentialBuyerdetailsMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objPotentialBuyerdetails));
            if(potentialBuyerdetailsMap.isEmpty()){
                continue; 
            }
            if (String.isBlank((String)potentialBuyerdetailsMap.get(FIELD_ACCOUNT_NAME))){
                throw new CustomException(PortalConstants.BUYER_NAME_MISSING);
            }
            if(shouldValidate){
                validateBuyersDetails(potentialBuyerdetailsMap);
            }
        }
    }
    /**
    * @description 
    * @author Suraj Kumar | 01-04-2024 
    * @param cropInsuranceDetailsList 
    * @param shouldValidate 
    **/
    public static void validateCropInsuranceDetails(List<Object> cropInsuranceDetailsList, Boolean shouldValidate){
        for(Object objCropInsuranceDetails : cropInsuranceDetailsList){
            Map<String, Object> cropInsuranceDetailsMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objCropInsuranceDetails));
            if(cropInsuranceDetailsMap.isEmpty()){
                continue; 
            }
            if (String.isBlank((String)cropInsuranceDetailsMap.get(FIELD_ACCOUNT_NAME))){
                throw new CustomException(PortalConstants.AGENCY_NAME_MISSING );
            }
            if(shouldValidate){
                validateInsuranceAgentDetails(cropInsuranceDetailsMap);
            }
        }
    }
    /**
    * @description 
    * @author Ravi Ranjan | 01-05-2024 
    * @param paramMap 
    **/
    public static void saveEmailLog(Map<String,String> paramMap){
        String emailTemplate = paramMap.get(EMAIL_TEMPLATE);
        String senderEmail = paramMap.get(SENDER_EMAIL);
        String receiverEmail = paramMap.get(RECEIVER_EMAIL);
        String logName = REPORT_LOG_NAME + emailTemplate + CLOSING_BRACKET;
        String message = EMAIL_TEMPLATE_NAME + emailTemplate + NEXT_LINE
                        +SENDER+ senderEmail + NEXT_LINE
                        +RECEIVER + receiverEmail;
        //keeping log of email send
        Database.Insert(new clcommon__Log__c(Name = logName,
                                            clcommon__Message__c = message,
                                            clcommon__Time__c = System.Now()), true);

    }
    /**
    * @description
    * @author Ravi Ranjan | 01-19-2024
    * @param displayName
    * @return List<OrgWideEmailAddress>
    **/
    public static List<OrgWideEmailAddress> getOrgWideEmailAddress(String displayName){
        return [SELECT Id,
                       Address,
                       DisplayName
                FROM OrgWideEmailAddress
                WHERE DisplayName = :displayName];
    }

    /**
    * @description - Purpose of this method is to return grower details.
    * @author Ravi Ranjan | 01-23-2024 
    * @param applicationObj 
    * @return Map<String, String> 
    **/
    public static Map<String,String> getGrowerDetails(genesis__Applications__c applicationObj) {
        String growerName;
        String growerCity = EMPTY_STRING;
        String growerState = EMPTY_STRING;
        Map<String,String> accountObjMap = new Map<String,String>();
        Map<String,String> contactObjMap = new Map<String,String>();

        // If the Account is not Individual applicant type.
        if(applicationObj.genesis__Account__r.clcommon__Legal_Entity_Type__c == null){
            throw new CustomException(PortalConstants.LEGAL_ENTITY_MISSING);
        }
        if(applicationObj.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name != PortalConstants.INDIVIDUAL_ENTITY
                & applicationObj.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name != PortalConstants.INDIVIDUAL
                & applicationObj.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name != PortalConstants.SOLE_PROP_ENTITY){
            growerName = applicationObj.genesis__Account__r.Name;
            if(applicationObj.genesis__Account__r.BillingCity != null){
                growerCity = applicationObj.genesis__Account__r.BillingCity;
            }
            if(applicationObj.genesis__Account__r.BillingState != null){
                growerState = applicationObj.genesis__Account__r.BillingState;
            }
            accountObjMap.put(GROWER_NAME,growerName);
            accountObjMap.put(GROWER_CITY,growerCity);
            accountObjMap.put(GROWER_STATE,growerState);
            return accountObjMap;
        }

        // else for Individual applicant type fetch the contact details.
        growerName = applicationObj.genesis__Contact__r.Name;
        if(applicationObj.genesis__Contact__r.MailingCity != null){
            growerCity = applicationObj.genesis__Contact__r.MailingCity;
        }
        if(applicationObj.genesis__Contact__r.MailingState != null){
            growerState = applicationObj.genesis__Contact__r.MailingState;
        }
        contactObjMap.put(GROWER_NAME,growerName);
        contactObjMap.put(GROWER_CITY,growerCity);
        contactObjMap.put(GROWER_STATE,growerState);
        return contactObjMap;
    }


    //----------------------------------------------------------------------------------------------------------------
    //========================================================================================================================
    //========================================================================================================================
    //NEW METHODS RELATED TO APPLICATION CREATION
    //========================================================================================================================
    //========================================================================================================================

    /**
     * @description : this method is used to fetch the legal entity of an account
     * @param accountObj 
     * @return  `String`
     */
    public static String getLegalEntityByAccount(Account accountObj){
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id, 
                                                                    Name
                                                            FROM clcommon__Legal_Entity__c
                                                            WHERE Id =: accountObj.clcommon__Legal_Entity_Type__c];

        PortalApplicationOriginationHelper.checkEmptyList(legalEntityList, PortalConstants.SOMETHING_WENT_WRONG);
        return legalEntityList[0].Name;
    }

    /**
     * @description : this method is used fetch the current logged in USER
     * @return  `List<User>`
     * @exception 
     */
    public static List<User> getLoggedInUser() {
        List<User> loggedInUserList = [SELECT Id,
                                        Email, 
                                        ContactId, 
                                        AccountId, 
                                        Account.ParentId, 
                                        Account.Parent.Name,
                                        Account.Parent.Coop_Type__c,
                                        Account.Parent.CFA_Partner_Program__r.Short_Name__c,
                                        Account.RecordTypeId,
                                        Account.RecordType.Name
                                    FROM User
                                    WHERE Id = :UserInfo.getUserId()];


        if (loggedInUserList.size() == 0) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }

        return loggedInUserList;
    }

    /**
     * @description : this method is used to generate a map of legal entity name vs legal entity id
     * @return  `Map<String, Id>`
     */
    public static Map<String, Id> getLegalEntityMap() {
        Map<String, Id> mapOfLegalEntity = new Map<String, Id>();
    
        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id, 
                                                                Name
                                                        FROM clcommon__Legal_Entity__c];
    
        for (clcommon__Legal_Entity__c legalEntity : legalEntityList) {
            mapOfLegalEntity.put(legalEntity.Name, legalEntity.Id);
        }
        return mapOfLegalEntity;
    }
    
    /**
     * @description : this method is used to generate a map of the party type name vs party type id
     * @return  `Map<String, Id>`
     */
    public static Map<String, Id> getPartyTypeMap() {
        Map<String, Id> mapOfpartyType = new Map<String, Id>();
    
        List<clcommon__Party_Type__c> partyTypeList = [SELECT Id, 
                                                                Name
                                                        FROM clcommon__Party_Type__c];
    
        for (clcommon__Party_Type__c partyType : partyTypeList) {
            mapOfpartyType.put(partyType.Name, partyType.id);
        }
    
        return mapOfpartyType;
    }

    /**
     * @description : this method is used fetch the current logged in ACCOUNT
     * @return  `Account`
     * @exception 
     */
    public static Account getLoggedInAccount(){
        List<Account> loggedInAccList = [SELECT Id, 
                                            Parent.Coop_Type__c, 
                                            Coop_Type__c, 
                                            RecordTypeId,
                                            RecordType.Name
                                        FROM Account
                                        WHERE Id IN (
                                            SELECT AccountId 
                                            FROM User
                                            WHERE Id = :UserInfo.getUserId())];
        if (loggedInAccList.isEmpty()) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }
        return loggedInAccList[0];
    }


/**
* @description  this method is used to update the loan number of the application
* @param objApplication 
* @param shouldValidate 
* @param mapOfpartyType 
* @return String 
**/
public static String updateLoanNumber(genesis__Applications__c objApplication, String shouldValidate, Map<String, Id> mapOfpartyType){
   String loanNumber = '';
   //Query the Latest Loan for the Grower
   List<clcommon__party__c> objPartiesList = [SELECT Id,
                                                       genesis__Application__r.genesis__Loan_Number__c
                                           FROM clcommon__party__c
                                           WHERE clcommon__Account__c =: objApplication.genesis__Account__c
                                           AND clcommon__Type__c =: mapOfpartyType.get(PortalConstants.BORROWER_PARTY_NAME)
                                           AND genesis__Application__r.genesis__Status__c IN (:PortalConstants.ACTIVE_APPLICATION_STATUS,
                                                                                               :PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS,
                                                                                               :PortalConstants.CLOSED_APPLICATION_STATUS)
                                           AND genesis__Application__r.Submitted_to_CFA__c != NULL
                                           ORDER BY genesis__Application__r.genesis__Loan_Number__c DESC];
   if(shouldValidate == NEW_APPLICANT){
       loanNumber = objApplication.genesis__Account__r.CIF_Number__c + CIF_SUFFIX;
   }
   else{
       loanNumber = String.valueOf((Decimal.valueOf(objPartiesList[0].genesis__Application__r.genesis__Loan_Number__c) + 1));
   }
   return loanNumber;
}

/**
* @description 
* @param accountObj 
* @param contactObj 
* @return Account 
**/
public static Account setAccountName(Account accountObj, Contact contactObj){
    if(string.isBlank(contactObj.ints__Middle_Name__c) || contactObj.ints__Middle_Name__c==null){
            accountObj.Name = contactObj.LastName + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + contactObj.FirstName;
    }
    else if(string.isBlank(contactObj.FirstName) || contactObj.FirstName==null){
            accountObj.Name = contactObj.LastName + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + contactObj.ints__Middle_Name__c;

    }
    else if((string.isBlank(contactObj.FirstName) || contactObj.FirstName==null) 
                    && (string.isBlank(contactObj.ints__Middle_Name__c) || contactObj.ints__Middle_Name__c==null)){
        accountObj.Name = contactObj.LastName;

    }
    else{
            accountObj.Name = contactObj.LastName + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + contactObj.FirstName + PortalConstants.SPACE_STRING + contactObj.ints__Middle_Name__c;
    }

    return accountObj;

}

     /**
* @description disable existing applicant fields
* @author  Pritam Roy | 02-13-2024 
    * @param applicationObj 
    * @param accountObj 
* @return genesis__Applications__c 
**/
   public static genesis__Applications__c disableApplicantFields(genesis__Applications__c applicationObj,Account accountObj){
List<clcommon__Party__c> objPartyList = [SELECT clcommon__Account__c,
                                                genesis__Application__r.genesis__Status__c 
                                                FROM clcommon__Party__c
                                                WHERE genesis__Application__r.genesis__Status__c IN (:PortalConstants.ACTIVE_APPLICATION_STATUS,
                                                                                                        :PortalConstants.CLOSED_APPLICATION_STATUS,
                                                                                                        :PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS)
                                                AND clcommon__Party_Types__c =: PortalConstants.BORROWER_PARTY_NAME
                                            AND clcommon__Account__c =: accountObj.id];
if(!objPartyList.isEmpty()){
        applicationObj.Is_First_Application__c = false;
}
    return applicationObj;
}

/**
* @description 
* @author Ravi Ranjan | 03-12-2024 
* @param profileName 
* @return List<Profile> 
**/
public static List<Profile> getProfileByName(String profileName){
    return [SELECT Id
            FROM Profile 
            WHERE Name =: profileName];
}

/**
* @description 
* @author Ravi Ranjan | 03-12-2024 
* @param contactList 
    * @return List<User> 
**/
    public static List<User> checkGrowerUserExistance(List<Contact> contactList){
    List<User> userList =  [SELECT Id
                            FROM User
                            WHERE AccountId =: contactList[0].AccountId
                            AND ContactId =: contactList[0].Id];
        return userList;
}

/**
* @description : checks if the parameter is blank or not
* @author Krishanu Chinya | 03-27-2024 
* @param parameter 
**/
public static void checkForBlankParameter(String parameter){
    if (String.isBlank(parameter)) {
        throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
    }
}

/**
* @description 
* @author Krishanu Chinya | 04-09-2024 
* @param value 
* @param exceptionString 
**/
public static void throwErrorIfFalse(Boolean value, String exceptionString){
    if (!value) {
        throw new CustomException(exceptionString);
    }
}

    /**
    * @description throws exception if a condition is met
    * @author Rakesh Saraf | 01-09-2025 
    * @param value 
    * @param exceptionString 
    **/
    public static void throwErrorIfTrue(Boolean value, String exceptionString){
        if (value) {
            throw new CustomException(exceptionString);
        }
    }
 /**
* @description This is a method to generate child loans of an application based on the MyProgram/FlexRate Chosen.
* @author Subham Nandi | 07-06-2024 
* @param applicationId 
**/
public static void generateChildLoans(String applicationId){
    genesis__Applications__c objApp = [SELECT Id, 
                                            My_Program__c 
                                        FROM genesis__Applications__c 
                                        WHERE Id = :applicationId];
    List<genesis__Rate_Card_Setup_Detail__c> objRateCardList = [SELECT Id,
                                                                        genesis__Interest_Rate__c 
                                                                FROM genesis__Rate_Card_Setup_Detail__c   
                                                                WHERE genesis__Rate_Card_Setup_Header__c  = :objApp.My_program__c AND 
                                                                        genesis__Enabled_Flag__c = true];
    List<genesis__Application_Pricing_Detail__c> appPricingList = [SELECT Id, 
                                                                    genesis__Application__c 
                                                                FROM genesis__Application_Pricing_Detail__c
                                                                WHERE genesis__Application__c =: objApp.id];
    if(appPricingList.size()>0){
        Database.delete(appPricingList,true);
    }
    List<genesis__Application_Pricing_Detail__c> pricingList = new List<genesis__Application_Pricing_Detail__c>();
    for(genesis__Rate_Card_Setup_Detail__c eachPricing : objRateCardList){
    genesis__Application_Pricing_Detail__C objPricing  = new genesis__Application_Pricing_Detail__C();
    objPricing.genesis__Rate_Card_Setup_Detail__c = eachPricing.Id;
    objPricing.genesis__Interest_Rate__c = eachPricing.genesis__Interest_Rate__c;
    objPricing.genesis__Application__c = objApp.Id;
    pricingList.add(objPricing);
    }
    database.insert(pricingList,true);                      
}

/**
* @description check necessary params
* @author Rakesh Saraf | 10-25-2024 
* @param paramToCheck 
* @param exceptionMessage 
**/
public static void checkBlankParameter(String paramToCheck,String exceptionMessage){
    //if the param to check will be null, we will throw the exception message 
    if((String.isBlank(paramToCheck) )) {
        throw new CustomException(exceptionMessage);
    }
}

/**
* @description to check if the object is null or not
* @author Rakesh Saraf | 11-13-2024 
* @param objectToCheck 
* @param exceptionMessage 
**/
public static void checkIfNullObject(Object objectToCheck,String exceptionMessage){
    if(objectToCheck == null) {
        throw new CustomException(exceptionMessage);
    }
}

    /**
    * @description this function helps to get the grower details specific to the dealer uing the Dealer Applicant Relationship Record linked to the application
    * @author Rakesh Saraf | 11-21-2024 
    * @param applicationObj 
    * @return Map<String, String> 
    **/
    public static Map<String,String> getDealerSpecificGrowerDetails(genesis__Applications__c applicationObj){
        String growerName = PortalConstants.EMPTY_STRING;
        String growerCity = PortalConstants.EMPTY_STRING;
        String growerState = PortalConstants.EMPTY_STRING;

        if(applicationObj.genesis__Account__r.clcommon__Legal_Entity_Type__c == null){
            throw new CustomException(PortalConstants.LEGAL_ENTITY_MISSING);
        }

        // If the Account is not an Individual applicant type.
        if(applicationObj.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name != PortalConstants.INDIVIDUAL_ENTITY
                & applicationObj.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name != PortalConstants.INDIVIDUAL
                & applicationObj.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name != PortalConstants.SOLE_PROP_ENTITY){

            growerName = applicationObj.genesis__Account__r.Name;
        }
        //if the applicant is an Individual Type
        else{
            growerName = applicationObj.genesis__Contact__r.Name;
        }

        clcommon__Party__c borrowerPartyObj=applicationObj.genesis__Parties__r[0];
        //using the Dealer Applicant Relationship Object's Record to fetch the data
        if(borrowerPartyObj.City__c != null){
            growerCity = borrowerPartyObj.City__c;
        }
        if(borrowerPartyObj.State__c != null){
            growerState = borrowerPartyObj.State__c;
        }
        return new Map<String, String>{
                                    PortalConstants.GROWER_NAME => growerName,
                                    PortalConstants.KEY_GROWER_CITY => growerCity,
                                    PortalConstants.KEY_GROWER_STATE => growerState
                                };
    }


    /**
    * @description purpose of this method is to update the dealer applicant relationship record with new values and only update the values of the account,contact and business info if they have not yet been filled
    * @author Rakesh Saraf | 11-27-2024 
    * @param paramMap 
    * @return Dealer_Applicant_Relationship__c 
    **/
    public static Dealer_Applicant_Relationship__c updateApplicantDetailsSpecificToDealer(Map<String,Object> paramMap){
        Account borrowerAccount=(Account) paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        Dealer_Applicant_Relationship__c dealerGrowerRelObj=(Dealer_Applicant_Relationship__c)paramMap.get(PortalConstants.APPLICANT_DEALER_RELATION_KEY);

        dealerGrowerRelObj.Has_Past_Due__c=borrowerAccount.Has_Past_Due__c;
        dealerGrowerRelObj.Is_Non_Accrual__c=borrowerAccount.Non_Accrual__c;
        dealerGrowerRelObj.Is_Evergreen_Eligible__c=borrowerAccount.Is_Evergreen_Allowed__c;

        return dealerGrowerRelObj;
    }

    

    /**
    * @description this method checks if the field to check is null or not
    * @author Rakesh Saraf | 11-26-2024 
    * @param fieldTocheck 
    * @param newValue 
    * @return String 
    **/
    public static String setOriginalOrNewValue(String fieldTocheck, String newValue){
        if(fieldTocheck==null|| String.isBlank(fieldTocheck)){
            return newValue;
        }
        return fieldToCheck;
    }

    /**
    * @description this method checks if the field to check is null or not for boolean
    * @author Rakesh Saraf | 11-26-2024 
    * @param fieldToCheck 
    * @param newValue 
    * @return Boolean 
    **/
    private static Boolean checkNullforBoolean(Boolean fieldToCheck,Boolean newValue){
        if(fieldTocheck==null){
            return newValue;
        }
        return fieldToCheck;
    }

    /**
    * @description this method checks if the field exists in the map and if so returns the string value of the field else returns empty String
    * @author Rakesh Saraf | 11-26-2024
    * @param mapToCheck 
    * @param fieldToCheck 
    * @return String 
    **/
    public static String checkFieldInMap(Map<String,Object> mapToCheck,String fieldToCheck){
        return mapToCheck.containsKey(fieldToCheck) ? 
                    (String) mapToCheck.get(fieldToCheck) : PortalConstants.EMPTY_STRING;
    }

    /**
    * @description this method deletes the dealer applicant relationship for a party if that acount does not exist as a party in any other application
    * @author Soumik Pattanayak | 12-24-2024 
    * @param dealerId 
    * @param applicantId 
    **/
    private static void deleteDealerApplicantRelationship(Id dealerId, Id applicantId){
        List<clcommon__party__c> partyList = [SELECT id
                                              FROM clcommon__party__c
                                              WHERE clcommon__Account__c = :applicantId
                                              AND genesis__Application__r.Dealer_Name__c = :dealerId
                                              AND clcommon__type__r.name IN (:PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)];

        if(partyList.size()==1){
            List<Dealer_Applicant_Relationship__c> dealerAppRelToDelete = [SELECT id
                                                                      FROM Dealer_Applicant_Relationship__c
                                                                      WHERE Dealer__c = :dealerId
                                                                      AND Applicant__c = :applicantId
                                                                      LIMIT 1];
            Database.delete(dealerAppRelToDelete,true);
        }
    }

    /**
    * @description sets the record type for the coapplicant
    * @author Rakesh Saraf | 03-26-2025 
    * @param accountObj 
    **/
    public static void setRecordTypeForPrincipal(Account accountObj){
        if(accountObj.RecordTypeId != Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId()){
            accountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.CO_APPLICATION_RECORD_TYPE).getRecordTypeId();
        }
    }
}