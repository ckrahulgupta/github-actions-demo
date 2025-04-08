/**
 * @description       : 
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 04-07-2025
 * @last modified by  : Ayush Kumar Singh
**/

global inherited sharing class PortalApplicationCreationHandler {

    private static Map<String, Id> mapOfpartyType = PortalApplicationOriginationHelper.getPartyTypeMap();
    private static List<User> loggedInUser = PortalApplicationOriginationHelper.getLoggedInUser();
    private static Map<String, Id> mapOfLegalEntity = PortalApplicationOriginationHelper.getLegalEntityMap();
    
    private static final String EVERGREEN_FLAG = 'IsNotEvergreen';
    private static final String EDIT ='edit';
    private static final String NEW_APPLICANT ='newApplicant';
    private static final String KEY_LOAN_AMOUNT = 'loanAmount';
    private static final String KEY_FIRST_NAME = 'firstName';
    private static final String KEY_LAST_NAME = 'lastName';
    private static final String KEY_ENTITY_TYPE = 'entityType';
    private static final String KEY_EMAIL = 'email';
    private static final String KEY_COMPANY_NAME = 'companyName';
    private static final String KEY_DBA_NAME = 'DBAName';
    private static final String KEY_ACCOUNT_OBJ = 'accountObj';
    private static final String KEY_CONTACT_OBJ = 'contactObj';
    private static final String KEY_ACC_CON_OBJ = 'accConObj';
    private static final String KEY_NAME_MAP = 'nameMap';
    private static final String KEY_NUMBERS_MAP = 'numbersMap';
    private static final String KEY_SSN_EMAIL_TIN_MAP = 'ssnEmailTinMap';
    private static final String KEY_SSN = 'genesis__SSN__c';
    private static final String KEY_CONFIRM_EMAIL = 'Confirm_Email__c';
    private static final String KEY_CONFIRM_SSN = 'Confirm_SSN__c';
    private static final String KEY_CONFIRM_TIN = 'Confirm_Tax_Identification_Number__c';
    private static final String KEY_TIN = 'genesis__Tax_Identification_Number__c';
    private static final String KEY_MOBILE_NUMBER = 'MobilePhone';
    private static final String KEY_WORK_NUMBER = 'Phone';
    private static final String KEY_HOME_NUMBER = 'HomePhone';
    private static final String KEY_BUSINESS_INFO = 'businessInfoObj';
    private static final String KEY_APPLICATION_OBJ = 'applicationObj';
    private static final String KEY_NEW_PORTAL_USER = 'newPortalUser';
    private static final String EMPTY_GROWER_EMAIL = 'Grower\'s email is empty. Cannot send application to Grower.';
    private static final String NO_COAPP_FOUND = 'No co-applicants found. Cannot send application to Grower.';
    private static final String EMPTY_PRINCIPAL_EMAIL = 'Co-Applicants doesn\'t have an email. Cannot send application to Grower.';
    private static final String KEY_EXISTING_APP_ID = 'existingApplicationId';
    private static final String KEY_APPLICATION_ID = 'applicationId';
    private static final String TRACK_PAST_DUE = 'trackHasPastDue';
    private static final String TRACK_NON_ACCRUAL = 'trackNonAccrual';
    private static final String SEND_APP_TO_GROWER = 'SEND_APP_TO_GROWER';
    private static final String ENTITY_KEY = 'entity';

      
    /**
    * @description populating the coapplicant contact details 
    * @author Rahul Gupta | 09-06-2023 
    * @param coApplicant 
    * @return Contact 
    **/
    public static Contact populateCoApplicantContact(Map<String, Object> coApplicant) {

        Contact coApplicantContact = new Contact();

        coApplicantContact.Id = 
            ((String) coApplicant.get(PortalConstants.COAPPLICANT_CONTACT_ID_KEY)) == null || 
            ((String) coApplicant.get(PortalConstants.COAPPLICANT_CONTACT_ID_KEY)) == PortalConstants.NEW_RECORD_STRING 
                ? null 
                : (String) coApplicant.get(PortalConstants.COAPPLICANT_CONTACT_ID_KEY);

                
        coApplicantContact.Birthdate = 
                coApplicant.containsKey(PortalConstants.COAPPLICANT_BIRTHDAY_KEY) ? 
                Date.valueOf((String) coApplicant.get(PortalConstants.COAPPLICANT_BIRTHDAY_KEY)) : null;
                
        coApplicantContact.MobilePhone = PortalApplicationOriginationHelper.checkFieldInMap(coApplicant, PortalConstants.MOBILE_PHONE_KEY);
        coApplicantContact.Phone = PortalApplicationOriginationHelper.checkFieldInMap(coApplicant, PortalConstants.WORK_PHONE_KEY);
        coApplicantContact.HomePhone = PortalApplicationOriginationHelper.checkFieldInMap(coApplicant, PortalConstants.HOME_PHONE_KEY);
                
        coApplicantContact.FirstName = PortalApplicationOriginationHelper.checkFieldInMap(coApplicant, PortalConstants.COAPPLICANT_FIRST_NAME_KEY);
        coApplicantContact.LastName = PortalApplicationOriginationHelper.checkFieldInMap(coApplicant, PortalConstants.COAPPLICANT_LAST_NAME_KEY);
        coApplicantContact.ints__Middle_Name__c = PortalApplicationOriginationHelper.checkFieldInMap(coApplicant,  PortalConstants.COAPPLICANT_MIDDLE_NAME_KEY);

        coApplicantContact.MailingStreet = PortalApplicationOriginationHelper.checkFieldInMap(coApplicant, PortalConstants.STREET_KEY);
        coApplicantContact.MailingCity = PortalApplicationOriginationHelper.checkFieldInMap(coApplicant, PortalConstants.CITY_KEY);
        coApplicantContact.MailingState = PortalApplicationOriginationHelper.checkFieldInMap(coApplicant, PortalConstants.STATE_KEY);
        coApplicantContact.Mailing_County__c = PortalApplicationOriginationHelper.checkFieldInMap(coApplicant, PortalConstants.COUNTY_KEY);
        coApplicantContact.MailingPostalCode = PortalApplicationOriginationHelper.checkFieldInMap(coApplicant,  PortalConstants.POSTAL_CODE_KEY);
                
        coApplicantContact.Email = PortalApplicationOriginationHelper.checkFieldInMap(coApplicant, PortalConstants.COAPPLICANT_CONTACT_EMAIL_KEY);
        coApplicantContact.Confirm_Email__c = PortalApplicationOriginationHelper.checkFieldInMap(coApplicant, PortalConstants.COAPPLICANT_CONFIRM_EMAIL_KEY);
            
        coApplicantContact.Title = PortalApplicationOriginationHelper.checkFieldInMap(coApplicant, PortalConstants.TITLE);
        coApplicantContact.Suffix__c = PortalApplicationOriginationHelper.checkFieldInMap(coApplicant,  PortalConstants.SUFFIX_KEY);

        coApplicantContact.genesis__SSN__c = PortalApplicationOriginationHelper.checkFieldInMap(coApplicant,  PortalConstants.COAPPLICANT_SSN_KEY);
        coApplicantContact.Confirm_SSN__c = PortalApplicationOriginationHelper.checkFieldInMap(coApplicant, PortalConstants.COAPPLICANT_CONFIRM_SSN_KEY);
            
        coApplicantContact.clcommon__Marital_Status__c = PortalApplicationOriginationHelper.checkFieldInMap(coApplicant, PortalConstants.MARITAL_STATUS_KEY);

        return coApplicantContact;
    }

    /**
    * @description populating the assets and liability for co applicant party 
    * @author iAyush | 22-01-2022 
    * @param coApplicant 
    * @return clcommon__Party__c 
    **/
    private static clcommon__Party__c populateCoApplicantParty(Map<String, Object> coApplicant){
        clcommon__party__c coApplicantParty = new clcommon__party__c();

        coApplicantParty.Id = 
                (String) coApplicant.get(PortalConstants.ID_KEY) == null ||
                (String) coApplicant.get(PortalConstants.ID_KEY) == PortalConstants.NEW_RECORD_STRING ?
                    null :
                    (String) coApplicant.get(PortalConstants.ID_KEY);

        coApplicantParty.Total_Assets__c = 
                coApplicant.containsKey(PortalConstants.TOTAL_ASSETS) ? (Decimal) coApplicant.get(PortalConstants.TOTAL_ASSETS) : null;

        coApplicantParty.Total_Liabilities__c = 
                coApplicant.containsKey(PortalConstants.TOTAL_LIABILITIES) ? (Decimal) coApplicant.get(PortalConstants.TOTAL_LIABILITIES) : null;
                
        coApplicantParty.Gross_Farm_Income__c = 
                coApplicant.containsKey(PortalConstants.GROSS_FARM_INCOME_KEY) ? (Decimal) coApplicant.get(PortalConstants.GROSS_FARM_INCOME_KEY) : null;

        return coApplicantParty;
    }

   
    /**
    * @description populating the coapplicant account details 
    * @author iAyush | 22-01-2022 
    * @param coApplicant 
    * @param coApplicantContact 
    * @return Account 
    **/
    private static Account populateCoApplicantAccount(Map<String, Object> coApplicant, Contact coApplicantContact){
        Account coApplicantAccount = new Account();
        String id = (String) coApplicant.get(PortalConstants.COAPPLICANT_ACCOUNT_ID_KEY);
        if (id == null || id == PortalConstants.NEW_RECORD_STRING) {
            coApplicantAccount.Id = null;
        } else {
            coApplicantAccount.Id = id;
        }

        coApplicantAccount = PortalApplicationOriginationHelper.setAccountName(coApplicantAccount, coApplicantContact);

        coApplicantAccount.Work_Number__c = PortalApplicationOriginationHelper.returnEmptyStringForField(coApplicantContact.Phone);
        coApplicantAccount.Home_Number__c = PortalApplicationOriginationHelper.returnEmptyStringForField(coApplicantContact.HomePhone);
        coApplicantAccount.Phone = PortalApplicationOriginationHelper.returnEmptyStringForField(coApplicantContact.MobilePhone);

        coApplicantAccount.clcommon__Email__c = coApplicantContact.Email == null ? PortalConstants.EMPTY_STRING : coApplicantContact.Email;
        coApplicantAccount.Confirm_Email__c = coApplicantContact.Confirm_Email__c == null ? PortalConstants.EMPTY_STRING : coApplicantContact.Confirm_Email__c;

        coApplicantAccount.Billing_County__c = PortalApplicationOriginationHelper.returnEmptyStringForField(coApplicantContact.Mailing_County__c);
        coApplicantAccount.BillingPostalCode = PortalApplicationOriginationHelper.returnEmptyStringForField(coApplicantContact.MailingPostalCode);
        coApplicantAccount.BillingState = PortalApplicationOriginationHelper.returnEmptyStringForField(coApplicantContact.MailingState);
        coApplicantAccount.BillingCity = PortalApplicationOriginationHelper.returnEmptyStringForField(coApplicantContact.MailingCity);
        coApplicantAccount.BillingStreet = PortalApplicationOriginationHelper.returnEmptyStringForField(coApplicantContact.MailingStreet);
        coApplicantAccount.Year_Began_Farming__c  = (String)coApplicant.get(PortalConstants.COAPPLICANT_YEAR_BEGAN_FARMING_KEY) == null ? null : (String)coApplicant.get(PortalConstants.COAPPLICANT_YEAR_BEGAN_FARMING_KEY);
        
        return coApplicantAccount;
    }

    /**
    * @description populating the details of business info for coapplicant 
    * @author iAyush | 22-01-2022 
    * @param coApplicant 
    * @return genesis__Business_Information__c 
    **/
    private static genesis__Business_Information__c populateCoApplicantBusinessInformation(Map<String, Object> coApplicant){
        genesis__Business_Information__c objBusinessInformation = new genesis__Business_Information__c();
        String id = (String) coApplicant.get(PortalConstants.COAPPLICANT_BUSINESS_INFO_ID_KEY);
        if (id == null || id == PortalConstants.NEW_RECORD_STRING) {
            objBusinessInformation.Id = null;
        } else {
            objBusinessInformation.Id = id;
        }
        objBusinessInformation.genesis__Total_Assets__c = (Integer) coApplicant.get(PortalConstants.TOTAL_ASSETS);
        objBusinessInformation.genesis__Total_Liabilities__c = (Integer) coApplicant.get(PortalConstants.TOTAL_LIABILITIES);
        objBusinessInformation.Gross_Farm_Income__c = (Double)coApplicant.get(PortalConstants.GROSS_FARM_INCOME_KEY) == null ? null : (Double)coApplicant.get(PortalConstants.GROSS_FARM_INCOME_KEY);
        
        return objBusinessInformation;
    }


    /**
    * @description Inserting or updating the coapplicant 
    * @author Rahul Gupta | 09-06-2023 
    * @param coApplicants 
    * @param applicationId 
    * @param shouldValidate 
    **/
    public static void saveCoApplicant(List<Map<String, Object>> coApplicants, String applicationId, String shouldValidate) {
        List<Id> coApplicantConIdToDel=new List<Id>();
        List<Id> coApplicantAccIDToDel=new List<Id>();
        List<Id> coApplicantBInfoIdToDel=new List<Id>();

        Map<Id,clcommon__Party__c> accountIdvsPartyMap = new Map<Id,clcommon__Party__c>();
        Map<Id,clcommon__Party__c> partyIdvsPartyMap = new Map<Id,clcommon__Party__c>();
        Map<Id,clcommon__Party__c> contactIdvsPartyMap = new Map<Id,clcommon__Party__c>();

        List<Id> coApplicantContactIdList = new List<Id>();
        List<Id> coApplicantPartyIdList = new List<Id>();
        List<Id> coApplicantAccountIdList = new List<Id>();
        List<Id> coApplicantBusinessIdList = new List<Id>();

        List<clcommon__Party__c> coApplicantPartyList = new List<clcommon__Party__c>();

        Boolean shouldDelete=PortalConstants.FALSE_VALUE;

        checkCoApplicantWithDuplicateSSN(coApplicants);

        //taking all the id's in a list
        for(Map<String, Object> coApplicant : coApplicants){
            Id coApplicantAccountId = (Id) coApplicant.get(PortalConstants.COAPPLICANT_ACCOUNT_ID_KEY);
            Id coApplicantContactId = (Id) coApplicant.get(PortalConstants.COAPPLICANT_CONTACT_ID_KEY);
            String coApplicantPartyId = (String) coApplicant.get(PortalConstants.ID_KEY);
            Id coApplicantBusinessInfoId = (Id) coApplicant.get(PortalConstants.COAPPLICANT_BUSINESS_INFO_ID_KEY);

            if(!(String.isBlank(coApplicantAccountId) | 
                    String.isBlank(coApplicantContactId) | 
                        String.isBlank(coApplicantPartyId) | 
                            coApplicantPartyId==PortalConstants.NEW_RECORD_STRING | 
                                String.isBlank(coApplicantBusinessInfoId))){

                coApplicantAccountIdList.add(coApplicantAccountId);
                coApplicantContactIdList.add(coApplicantContactId);
                coApplicantPartyIdList.add(coApplicantPartyId);
                coApplicantBusinessIdList.add(coApplicantBusinessInfoId);
            }

        }

        partyIdvsPartyMap=getPartyVsIdMap(coApplicantPartyIdList,applicationId);

        contactIdvsPartyMap=getContactIdVsPartyMap(coApplicantContactIdList,applicationId);

        accountIdvsPartyMap=getAccountIdVsPartyMap(coApplicantAccountIdList,applicationId);

        for (Map<String, Object> coApplicant : coApplicants) {
            Contact coApplicantContact = PortalApplicationCreationHandler.populateCoApplicantContact(coApplicant);
            Account coApplicantAccount =  PortalApplicationCreationHandler.populateCoApplicantAccount(coApplicant, coApplicantContact);
            genesis__Business_Information__c coApplicantBusinessInfo =  PortalApplicationCreationHandler.populateCoApplicantBusinessInformation(coApplicant);
            clcommon__Party__c coApplicantParty =  PortalApplicationCreationHandler.populateCoApplicantParty(coApplicant);

            updateBorrowerPartyDetails(new Map<String,Object>{PortalConstants.ACCOUNT_OBJ_KEY=>coApplicantAccount,
                                                              PortalConstants.CONTACT_OBJ_KEY=>coApplicantContact,
                                                              PortalConstants.BUSINESS_INFO_OBJ_KEY=>coApplicantBusinessInfo,
                                                              PortalConstants.BORROWER_PARTY_KEY=>coApplicantParty});

            PortalValidationUtil.isValidCoApplicationCreation(new Map<String,Object>{PortalConstants.CONTACT_OBJ_KEY=>coApplicantContact,
                                                                                     PortalConstants.ACCOUNT_OBJ_KEY=>coApplicantAccount,
                                                                                     PortalConstants.BUSINESS_INFO_OBJ_KEY=>coApplicantBusinessInfo,
                                                                                     PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                     PortalConstants.BORROWER_PARTY_KEY=>coApplicantParty});

            shouldDelete=handlePrincipalSSNChange(new Map<String,Object>{PortalConstants.CONTACT_OBJ_KEY=>coApplicantContact,
                                                                        PortalConstants.ACCOUNT_OBJ_KEY=>coApplicantAccount,
                                                                        PortalConstants.BUSINESS_INFO_OBJ_KEY=>coApplicantBusinessInfo,
                                                                        PortalConstants.BORROWER_PARTY_KEY=>coApplicantParty,
                                                                        PortalConstants.APPLICATION_ID_KEY=>applicationId,
                                                                        PortalConstants.KEY_SHOULD_DELETE=>shouldDelete},
                                                new Map<String,List<Object>>{ PortalConstants.CONTACT_OBJ_KEY=>coApplicantConIdToDel,
                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>coApplicantAccIDToDel,
                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>coApplicantBInfoIdToDel},
                                                new Map<String,Map<Id,clcommon__Party__c>>{PortalConstants.CONTACT_OBJ_KEY=>contactIdvsPartyMap,
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountIdvsPartyMap});
                                                                    

            if (String.isBlank(coApplicantParty.Id)) {
                createNewCoApplicantParty(new Map<String,Object>{PortalConstants.ACCOUNT_OBJ_KEY=>coApplicantAccount,
                                                                PortalConstants.CONTACT_OBJ_KEY=>coApplicantContact,
                                                                PortalConstants.BUSINESS_INFO_OBJ_KEY=>coApplicantBusinessInfo,
                                                                PortalConstants.KEY_PARTY=>coApplicantParty,
                                                                PortalConstants.APPLICATION_ID_KEY=>applicationId});

            } else {
                Boolean isValidPartyCreation = PortalSecurityUtil.validatePrincipalParty(applicationId, coApplicantParty.Id); 
                PortalApplicationOriginationHelper.throwErrorIfFalse(isValidPartyCreation,PortalConstants.USER_NOT_AUTHORISED);

                if (!String.isBlank(coApplicantAccount.Id) &
                        !String.isBlank(coApplicantContact.Id) &
                            !String.isBlank(coApplicantBusinessInfo.Id)) {

                    Boolean isValidAccount = PortalSecurityUtil.validateCoApplicantAccount(coApplicantAccount.Id, accountIdvsPartyMap);
                    Boolean isValidContact = PortalSecurityUtil.validateCoApplicantContact(coApplicantContact.Id, contactIdvsPartyMap); 
                    Boolean isValidParty = PortalSecurityUtil.validateCoApplicantParty(coApplicantParty.Id, partyIdvsPartyMap); 

                    PortalApplicationOriginationHelper.throwErrorIfTrue(!isValidAccount | !isValidContact | !isValidParty, PortalConstants.USER_NOT_AUTHORISED);

                    //Rename Account to match the Contact's Name for Co-Applicant
                    coApplicantAccount=renameCoApplicantAccount(coApplicantContact,coApplicantAccount);

                    checkIfKycVerified(coApplicantContact,coApplicantAccount);
                } 
                else{
                    throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
                }
                
                Database.update(coApplicantBusinessInfo, true);
                Database.update(coApplicantAccount, true);
                Database.update(coApplicantContact, true);
                coApplicantPartyList.add(coApplicantParty);
                Database.update(coApplicantParty, true);
            }
        }

        deleteRedundantPartyDetails(new Map<String,List<Object>>{
                                                                    PortalConstants.CONTACT_OBJ_KEY=>coApplicantConIdToDel,
                                                                    PortalConstants.ACCOUNT_OBJ_KEY=>coApplicantAccIDToDel,
                                                                    PortalConstants.BUSINESS_INFO_OBJ_KEY=>coApplicantBInfoIdToDel,
                                                                    PortalConstants.KEY_PARTY=>coApplicantPartyList
                                                                },loggedInUser[0],shouldDelete);

    }

    /**
    * @description 
    * @author Rakesh Saraf | 02-16-2025 
    * @param paramMap 
    * @param paramListMap 
    * @param objMapList 
    * @return Boolean 
    **/
    public static Boolean handlePrincipalSSNChange(Map<String,Object> paramMap,Map<String,List<Object>> paramListMap, Map<String,Map<Id,clcommon__Party__c>> objMapList){

        Contact coApplicantContact = (Contact)paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        Account coApplicantAccount = (Account)paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        genesis__Business_Information__c coApplicantBusinessInfo = (genesis__Business_Information__c)paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY) ;
        clcommon__Party__c coApplicantParty=(clcommon__Party__c)paramMap.get(PortalConstants.BORROWER_PARTY_KEY);
        String applicationId=(String)paramMap.get(PortalConstants.APPLICATION_ID_KEY);
        Boolean shouldDelete=(Boolean)paramMap.get(PortalConstants.KEY_SHOULD_DELETE);

        List<Id> coApplicantConIdToDel= (List<Id>)paramListMap.get(PortalConstants.CONTACT_OBJ_KEY);
        List<Id> coApplicantAccIDToDel= (List<Id>)paramListMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        List<Id> coApplicantBInfoIdToDel= (List<Id>)paramListMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);

        Map<Id,clcommon__Party__c> accountIdvsPartyMap = objMapList.get(PortalConstants.ACCOUNT_OBJ_KEY);
        Map<Id,clcommon__Party__c> contactIdvsPartyMap =  objMapList.get(PortalConstants.CONTACT_OBJ_KEY);
        
        Id oldCoApplicantContactId = coApplicantContact.Id;
        Id oldCoApplicantAccountId = coApplicantAccount.Id;
        Id oldCoApplicanBInfoId = coApplicantBusinessInfo.Id;
        PortalValidationUtil.validateNewCoApplicant(coApplicantContact, loggedInUser[0].Account.Parent.Coop_Type__c);

        if(String.isBlank(oldCoApplicantContactId) && !String.isBlank(coApplicantContact.id)){
            updateCoAppDetailsForExistingIndividual(new Map<String,Object>{ PortalConstants.CONTACT_OBJ_KEY=>coApplicantContact,
                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>coApplicantAccount,
                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>coApplicantBusinessInfo,
                                                                            PortalConstants.KEY_PARTY=>coApplicantParty},applicationId);

            accountIdvsPartyMap.put(coApplicantAccount.Id, coApplicantParty);
            contactIdvsPartyMap.put(coApplicantContact.Id, coApplicantParty);
        }
        else if(!String.isBlank(oldCoApplicantContactId) && oldCoApplicantContactId!=coApplicantContact.id){

            PortalValidationUtil.verifyUserForApplicant(oldCoApplicantContactId,coApplicantContact.id);
            
            updateCoAppDetailsForExistingIndividual(new Map<String,Object>{ PortalConstants.CONTACT_OBJ_KEY=>coApplicantContact,
                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>coApplicantAccount,
                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>coApplicantBusinessInfo,
                                                                            PortalConstants.KEY_PARTY=>coApplicantParty},applicationId);

            accountIdvsPartyMap.put(coApplicantAccount.Id, coApplicantParty);
            contactIdvsPartyMap.put(coApplicantContact.Id, coApplicantParty);

            //deleting old account contact
            List<clcommon__Party__c> checkPartyList = [SELECT Id 
                                                        FROM clcommon__Party__c
                                                        WHERE genesis__Application__c !=: applicationId
                                                        AND clcommon__Contact__c =: oldCoApplicantContactId];

            if(checkPartyList.isEmpty()){
                coApplicantConIdToDel.add(oldCoApplicantContactId);
                coApplicantAccIDToDel.add(oldCoApplicantAccountId);
                coApplicantBInfoIdToDel.add(oldCoApplicanBInfoId);

                shouldDelete=PortalConstants.TRUE_VALUE;

                accountIdvsPartyMap.remove(oldCoApplicantAccountId);
                contactIdvsPartyMap.remove(oldCoApplicantContactId);
            }
        }

        return shouldDelete;
        
    }

    /**
    * @description 
    * @author Rakesh Saraf | 02-16-2025 
    * @param paramMap 
    **/
    private static void createNewCoApplicantParty(Map<String,Object> paramMap){
        Account coApplicantAccount=(Account)paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        Contact coApplicantContact=(Contact)paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        genesis__Business_Information__c coApplicantBusinessInfo=(genesis__Business_Information__c)paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        clcommon__party__c coApplicantParty=(clcommon__party__c)paramMap.get(PortalConstants.KEY_PARTY);
        String applicationId=(String)paramMap.get(PortalConstants.APPLICATION_ID_KEY);

        coApplicantAccount.Id = coApplicantContact.AccountId;
        Database.upsert(coApplicantBusinessInfo, true);
        coApplicantAccount.genesis__Business_Information__c = coApplicantBusinessInfo.Id;
        coApplicantAccount.clcommon__Legal_Entity_Type__c = mapOfLegalEntity.get(PortalConstants.SOLE_PROP_ENTITY);
        coApplicantAccount.Name = coApplicantContact.LastName + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + coApplicantContact.FirstName + PortalConstants.SPACE_STRING + coApplicantContact.ints__Middle_Name__c;
        coApplicantAccount.OwnerId = PortalSecurityUtil.getSiteAdmin();
        
        if(coApplicantContact.AccountId != null){
            List<Account> accList = [SELECT Id, 
                                            RecordTypeId 
                                        FROM Account 
                                        WHERE Id = :coApplicantContact.AccountId 
                                        LIMIT 1];
            coApplicantAccount.RecordTypeId = accList[0].RecordTypeId;
        }else{
            coApplicantAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.CO_APPLICATION_RECORD_TYPE).getRecordTypeId();
        }
        coApplicantAccount.Is_Individual__c = true;

        checkIfKycVerified(coApplicantContact,coApplicantAccount);
        Database.upsert(coApplicantAccount, true);
        
        coApplicantContact.accountId = coApplicantAccount.Id;
        Database.upsert(coApplicantContact, true);
        coApplicantParty.clcommon__Account__c = coApplicantAccount.Id;
        coApplicantParty.clcommon__Contact__c = coApplicantContact.Id;
        coApplicantParty.genesis__Application__c = applicationId;
        
        coApplicantParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.PRINCIPAL_PARTY_NAME);
        coApplicantParty.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;
        Database.upsert(coApplicantParty, true);
    }

    /**
    * @description the purpse of this method is to check if there are any duplicate ssns entered by the user
    * @author Rakesh Saraf | 02-15-2025 
    * @param coApplicants 
    **/
    private static void checkCoApplicantWithDuplicateSSN(List<Map<String, Object>> coApplicants){
        Map<String,Map<String, Object>> coApplicantMap= new Map<String,Map<String, Object>>();

        for(Map<String, Object> eachCoApplicant:coApplicants){
            String coApplicantSSN=PortalApplicationOriginationHelper.checkFieldInMap(eachCoApplicant,PortalConstants.COAPPLICANT_SSN_KEY);
            if(String.isBlank(coApplicantSSN)){
                throw new CustomException(PortalConstants.CO_APPL_SSN_MISSING);
            }

            if(coApplicantMap.containsKey(coApplicantSSN)){
                throw new CustomException(PortalConstants.COAPPLICANT_ALREADY_EXIST);
            }
            coApplicantMap.put(coApplicantSSN,eachCoApplicant);
        }
        
    }

    /**
    * @description Rename Account to match the Contact's Name for Co-Applicant
    * @author Rakesh Saraf | 12-24-2024 
    * @param coApplicantContact 
    * @param coApplicantAccount 
    * @return Account 
    **/
    private static Account renameCoApplicantAccount(Contact coApplicantContact,Account coApplicantAccount){
        if(!String.isBlank(coApplicantContact.FirstName) &
                            !String.isBlank(coApplicantContact.LastName)){

                                coApplicantAccount.Name = coApplicantContact.LastName + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + coApplicantContact.FirstName + PortalConstants.SPACE_STRING + coApplicantContact.ints__Middle_Name__c;
        }
        return coApplicantAccount;
    }

    /**
     * @description This method will return parties related to cl.
     * @author Ayan Bhowmik | 11-17-2023
     * @param dealerRelationPartyList 
     * @param relationContactList 
     * @param applicationId 
     * @return  `List<clcommon__Party__c>`
     */
    public static List<clcommon__Party__c> getPartiesForRelatedCL(List<clcommon__Party__c> dealerRelationPartyList, List<Contact> relationContactList, Id applicationId){
        Map<String, Id> mapOfpartyType = new Map<String, Id>();
        mapOfpartyType = PortalHelper.getPartyTypeMap();

        for (Contact relationContact : relationContactList) {

            clcommon__Party__c relationParty = new clcommon__Party__c();
    
                relationParty.genesis__Application__c = applicationId;
                relationParty.clcommon__Account__c = relationContact.Account.Id;
                relationParty.clcommon__Contact__c = relationContact.Id;
    
                if (relationContact.Account.RecordType.Name == PortalConstants.CERTIFIED_LENDER) {
                    relationParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.CL_PARTY_NAME);
                    relationParty.clcommon__Party_Types__c = PortalConstants.CL_PARTY_NAME;
                }
    
                if (relationContact.Account.RecordType.Name == PortalConstants.CERTIFIED_LENDER_PLUS) {
                    relationParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.CL_PLUS_PARTY_NAME);
                    relationParty.clcommon__Party_Types__c = PortalConstants.CL_PLUS_PARTY_NAME; 
                }
    
                if (relationContact.Account.RecordType.Name == PortalConstants.INQUIRY) {
                    relationParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.INQUIRY_PARTY_NAME);
                    relationParty.clcommon__Party_Types__c = PortalConstants.INQUIRY_PARTY_NAME; 
                }
    
                if (relationContact.Account.RecordType.Name == PortalConstants.INQUIRY_PLUS) {
                    relationParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.INQUIRY_PLUS_PARTY_NAME);
                    relationParty.clcommon__Party_Types__c = PortalConstants.INQUIRY_PLUS_PARTY_NAME; 
                }
                //Adding Field Staff Agent Party Type --------------------------------
                if (relationContact.Account.RecordType.Name == PortalConstants.FIELD_STAFF_AGENT) {
                    relationParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.FIELD_STAFF_AGENT_PARTY);
                    relationParty.clcommon__Party_Types__c = PortalConstants.FIELD_STAFF_AGENT_PARTY;
                }
                //Adding Field Staff Agent Party Type --------------------------------
    
                // Adding Payment Administrator Party Type -------------------------
                if (relationContact.Account.RecordType.Name == PortalConstants.PAYMENT_ADMINISTRATOR) {
                    relationParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.PAYMENT_ADMINISTRATOR_PARTY);
                    relationParty.clcommon__Party_Types__c = PortalConstants.PAYMENT_ADMINISTRATOR_PARTY;
                }
    
            dealerRelationPartyList.add(relationParty); 
        }
        return dealerRelationPartyList;
    }
    
    /**
     * @description This method will check if account name is missing then update account details with contact details
     * @author Ayan Bhowmik | 11-17-2023
     * @param accountObj 
     * @param contactObj 
     * @return  `Account`
     */
    public static Account updateAccountFromContactDetails(Account accountObj, Contact contactObj){
        if (String.isBlank(accountObj.Name)) {
            //Assigning the name to the account = contact.fname + contact.lname;
            accountObj.Name = contactObj.LastName + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + contactObj.FirstName + PortalConstants.SPACE_STRING +  contactObj.ints__Middle_Name__c;
            accountObj.Is_Individual__c = true;
            accountObj.Id = contactObj.AccountId;
            accountObj.clcommon__Email__c = contactObj.Email;

            accountObj.Phone = contactObj.MobilePhone;
            accountObj.Home_Number__c = String.isBlank(contactObj.HomePhone) ? PortalConstants.EMPTY_STRING : contactObj.HomePhone;
            accountObj.Work_Number__c = String.isBlank(contactObj.Phone) ? PortalConstants.EMPTY_STRING : contactObj.Phone;
            accountObj.BillingStreet = contactObj.MailingStreet == null ? PortalConstants.EMPTY_STRING : contactObj.MailingStreet;
            accountObj.BillingCity = contactObj.MailingCity == null ? PortalConstants.EMPTY_STRING : contactObj.MailingCity;
            accountObj.BillingState = contactObj.MailingState == null ? PortalConstants.EMPTY_STRING : contactObj.MailingState;
            accountObj.BillingPostalCode = contactObj.MailingPostalCode == null ? PortalConstants.EMPTY_STRING : contactObj.MailingPostalCode;
            accountObj.Billing_County__c = contactObj.Mailing_County__c == null ? PortalConstants.EMPTY_STRING : contactObj.Mailing_County__c;
        }
        return accountObj;
    }

    /**
     * @description This method will return the party count of principal party.
     * @author Ayan Bhowmik | 17-11-2023
     * @param principalPartyList 
     * @return  `Integer`
     */
    public static Integer getPrincipalPartyCount(List<clcommon__Party__c> principalPartyList){
        Integer partyCount = 0;
        for(clcommon__Party__c eachparty : principalPartyList){
            if( eachparty.clcommon__Party_Types__c == PortalConstants.PRINCIPAL_PARTY_NAME){
                partyCount+=1;
            }
        }
        return partyCount;
    }

        /**
     * @description This method will check if the entity has changed or not for evergreen app.
     * @author Ayan Bhowmik | 11-20-2023
     * @param accountObj 
     * @param partyObj 
     * @param applicationObj 
     * @return  `Boolean`
     */
    public static Boolean checkEntityChanged(Account accountObj, 
                                                    clcommon__Party__c partyObj,
                                                    genesis__Applications__c applicationObj){

        return accountObj.clcommon__Legal_Entity_Type__c != partyObj.clcommon__Account__r.clcommon__Legal_Entity_Type__c ?
                true :
                false;
    }

    /**
     * @description This method will check evergreen eligibility for corporation
     * @param accountObj 
     * @param businessInfoObj 
     * @param partyObj 
     * @return  `Boolean`
     */
    public static Boolean checkEvergreenForCorporation(Account accountObj,
                                                                genesis__Business_Information__c businessInfoObj, 
                                                                clcommon__Party__c partyObj){

        if(partyObj.clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name != PortalConstants.SOLE_PROP_ENTITY &
                    partyObj.clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name != PortalConstants.INDIVIDUAL_ENTITY){
            if(accountObj.Name != partyObj.clcommon__Account__r.Name |
                        businessInfoObj.genesis__State_of_Incorporation__c != partyObj.clcommon__Account__r.genesis__Business_Information__r.genesis__State_of_Incorporation__c){
                return true;
            }
        }
        return false;
    }

    /**
     * @description This method will check evergreen eligibility for Sole Prop.
     * @author Ayan Bhowmik | 11-20-2023
     * @param partyObj 
     * @param contactObj 
     * @param applicationObj 
     * @return  `Boolean`
     */
    public static Boolean checkEvergreenForSoleProp(clcommon__Party__c partyObj,
                                                                    Contact contactObj,
                                                                    genesis__Applications__c applicationObj){
        if(partyObj.clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name == PortalConstants.SOLE_PROP_ENTITY){
            if(contactObj.FirstName != partyObj.clcommon__Contact__r.FirstName ||
                    contactObj.LastName != partyObj.clcommon__Contact__r.LastName){
                return true;
            }
        }
        return false;
    }

    /**
     * @description This will change the stage of the application for evergreen application.
     * @author Ayan Bhowmik | 11-20-2023
     * @param currentApplication 
     * @param applicationObj 
     * @return  `genesis__Applications__c`
     */
    public static genesis__Applications__c changeStageOfApplication(List<genesis__Applications__c> currentApplication,
                                                                            genesis__Applications__c applicationObj){
         if((currentApplication[0].Is_Evergreen__c && !String.isBlank(currentApplication[0].genesis__Credit_Rating__c)) && 
            (currentApplication[0].genesis__Credit_Rating__r.Name == PortalConstants.TIER_1_CREDIT || 
            currentApplication[0].genesis__Credit_Rating__r.Name == PortalConstants.TIER_2_CREDIT)){
                //Stage - credit reference
                applicationObj.Stage__c = PortalConstants.SCORE_CREDIT_REFERENCE;       
        }
        return applicationObj;
    }

    /**
     * @description This method will assign empty string if irc and gmk unique identifier is null
     * @author Ayan Bhowmik | 11-21-2023
     * @param applicationObj 
     * @return  `genesis__Applications__c`
     */
    public static genesis__Applications__c setNullIfEmpty(genesis__Applications__c applicationObj){
        applicationObj.Internal_Reference_Code__c = applicationObj.Internal_Reference_Code__c == null 
                                                            ? PortalConstants.EMPTY_STRING 
                                                            : applicationObj.Internal_Reference_Code__c;

        applicationObj.Unique_Identifier__c = applicationObj.Unique_Identifier__c == null 
                                                                ? PortalConstants.EMPTY_STRING 
                                                                : applicationObj.Unique_Identifier__c;

        return applicationObj;
    }

    /**
     * @description This method will throw an exception if neccesary parameters are blank.
     * @author Ayan Bhowmik | 11-21-2023
     * @param applicationObjRecord 
     * @param objPrimaryAccountRecord 
     */
    public static void neccesaryParamCheckForApplicationCreation(String applicationObjRecord, String objPrimaryAccountRecord){
        if ((String.isBlank(applicationObjRecord) | String.isBlank(objPrimaryAccountRecord))) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
    }

    /**
     * @description This method will throw respective exception if incoming id is null.
     * @author Ayan Bhowmik | 11-21-2023
     * @param paramId 
     * @param exceptionNameString 
     */
    public static void throwExceptionIfIdIsNull(Id paramId, String exceptionNameString){
        if(paramId == null){
            throw new CustomException(exceptionNameString);
        }
    }

   
    /**
    * @description Check the borrower evergreen eligibility 
    * @author Krishanu Chinya | 03-05-2024 
    * @param partyList 
    * @param paramMap 
    * @param coApplicantMap 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> checkEvergreenForBorrower(List<clcommon__Party__c> partyList, 
                                                                    Map<String, Object> paramMap,
                                                                    Map<String,Map<String,Object>> coApplicantMap){

        genesis__Applications__c applicationObj = (genesis__Applications__c)paramMap.get(PortalConstants.APPLICATION_OBJ_KEY);
        Map<String, Object> fieldsMap = coApplicantMap.get(PortalConstants.FIELDS_MAP_KEY);

        fieldsMap = checkEvergreenForCoApplicants(partyList, coApplicantMap, applicationObj);
        return fieldsMap;
    }

    /**
     * @description This method will check evergreen eligibilty for coapplicants.
     * @author Ayan Bhowmik | 11-21-2023
     * @param partyList 
     * @param coApplicantMap 
     * @param applicationObj 
     * @return  `genesis__Application__c`
     */
    public static Map<String, Object> checkEvergreenForCoApplicants(List<clcommon__Party__c> partyList,
                                                                        Map<String,Map<String,Object>> coApplicantMap,
                                                                        genesis__Applications__c applicationObj){
        Map<String, Object> fieldsMap = coApplicantMap.get(PortalConstants.FIELDS_MAP_KEY);
        for(clcommon__Party__c eachparty : partyList){
            if(eachparty.clcommon__Party_Types__c != PortalConstants.BORROWER_PARTY_NAME){
                //Get the CoApplicant Map
                Map<String,Object> currentPrincipalMap = coApplicantMap.get(eachparty.Id);
                if((currentPrincipalMap.containsKey(PortalConstants.COAPPLICANT_FIRST_NAME_KEY) & eachparty.clcommon__Contact__r.FirstName == null) |
                    (currentPrincipalMap.containsKey(PortalConstants.COAPPLICANT_LAST_NAME_KEY) & eachparty.clcommon__Contact__r.LastName == null) 
                ){
                        applicationObj.Is_Evergreen__c = false;
                        fieldsMap.put(EVERGREEN_FLAG,true);fieldsMap.put(PortalConstants.APPLICATION_OBJ_KEY, applicationObj);
                        return fieldsMap;
                }
                if(currentPrincipalMap.get(PortalConstants.COAPPLICANT_FIRST_NAME_KEY) != eachparty.clcommon__Contact__r.FirstName |
                    currentPrincipalMap.get(PortalConstants.COAPPLICANT_LAST_NAME_KEY) != eachparty.clcommon__Contact__r.LastName 
                ){
                        //Contains FirstName, Check for changes
                        applicationObj.Is_Evergreen__c = false;
                        fieldsMap.put(EVERGREEN_FLAG,true);
                        fieldsMap.put(PortalConstants.APPLICATION_OBJ_KEY, applicationObj);
                        return fieldsMap;
                }
            }
        }
        fieldsMap.put(PortalConstants.APPLICATION_OBJ_KEY, applicationObj);
        return fieldsMap;
    }

    /**
     * @description - Purpose of this method is to create the dealer party and linked it to the application.
     * @author iAyush | 22-04-2022
     * @param paramMap 
     */
    public static void createDealerParty(Map<String, Object> paramMap) {

        Id certifiedLenderId;
        Map<String, Id> mapOfpartyType = PortalHelper.getPartyTypeMap();
        List<String> relationIdList = new List<String>();
        clcommon__Party__c partyObj = new clcommon__Party__c();
        clcommon__Party__c clParty = new clcommon__Party__c();
        List<clcommon__Party__c> dealerRelationPartyList = new List<clcommon__Party__c>();
        List<clcommon__Relationship__c> relationship = new List<clcommon__Relationship__c>();
        List<clcommon__Relationship__c> clRelationships = new List<clcommon__Relationship__c>();
        User loggedInUser = (User)paramMap.get('loggedInUser');
        genesis__Applications__c applicationObj = (genesis__Applications__c)paramMap.get('applicationObj');
        Contact primaryApplicantContact = new Contact();
        Boolean createPrimaryApplicant = (Boolean)paramMap.get('createPrimaryApplicant');
        String shouldValidate = (String)paramMap.get('shouldValidate');
        if((Contact)paramMap.get('primaryApplicant') != null){
            primaryApplicantContact = (Contact)paramMap.get('primaryApplicant');
        }
        Map<String,String> roleToPartyTypeMap = new Map<String,String>{
            PortalConstants.SALES_AGENT_PLUS => PortalConstants.SALES_AGENT_PLUS_PARTY_NAME,
            PortalConstants.SALES_AGENT => PortalConstants.SALES_AGENT_PARTY_NAME
        };

        relationship = [SELECT Id, 
                                clcommon__Entity__c,
                                clcommon__Related_Entity__c, 
                                clcommon__Relationship__r.Name,
                                clcommon__Related_Entity__r.ParentId
                            FROM clcommon__Relationship__c
                            WHERE clcommon__Related_Entity__c =: loggedInUser.AccountId
                            AND clcommon__Relationship__r.Name IN (
                                :PortalConstants.CERTIFIED_LENDER, 
                                :PortalConstants.SALES_AGENT, 
                                :PortalConstants.CERTIFIED_LENDER_PLUS, 
                                :PortalConstants.SALES_AGENT_PLUS,
                                :PortalConstants.FIELD_STAFF_AGENT,
                                :PortalConstants.SALES_AGENT_ADMIN)
                            ORDER BY clcommon__Relationship__r.Name ASC];

        PortalApplicationOriginationHelper.checkEmptyList(relationship, PortalConstants.SOMETHING_WENT_WRONG);
        //Adding a party of Dealer
        partyObj.genesis__Application__c = applicationObj.Id;
        partyObj.clcommon__Account__c = relationship[0].clcommon__Related_Entity__r.ParentId;   
        partyObj.clcommon__Type__c = mapOfpartyType.get(PortalConstants.DEALER_PARTY_NAME);
        partyObj.clcommon__Party_Types__c = PortalConstants.DEALER_PARTY_NAME;
        dealerRelationPartyList.add(partyObj);
        applicationObj.Dealer_Name__c = relationship[0].clcommon__Related_Entity__r.ParentId;
        applicationObj.OwnerId = PortalSecurityUtil.getSiteAdmin();
        //Adding party for Loggedin user (Certified Lender or Sales Agent)
        clParty.genesis__Application__c = applicationObj.Id;
        clParty.clcommon__Account__c = loggedInUser.AccountId;
        clParty.clcommon__Contact__c = loggedInUser.ContactId;

        //adding sa admin party if logged in is user is an sa
        Account loggedInAcc = [SELECT Id, RecordType.Name FROM Account WHERE Id =: loggedInUser.AccountId];
        if(loggedInAcc.RecordType.Name == PortalConstants.SALES_AGENT || loggedInAcc.RecordType.Name == PortalConstants.SALES_AGENT_PLUS){
            //add party of sa admin if the sa has an admin
            List<Id> saAdminAccIdList = PortalApplicationOriginationHelper.fetchSAAdmin(loggedInAcc.Id);
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

                for(Id saAdminAccId : saAdminAccIdList){
                    clcommon__Party__c saAdminPartyObj = new clcommon__Party__c();
                    saAdminPartyObj.genesis__Application__c = applicationObj.Id;
                    saAdminPartyObj.clcommon__Account__c = saAdminAccId;
                    saAdminPartyObj.clcommon__contact__c = saAdminAccIdvsConIdMap.get(saAdminAccId);
                    saAdminPartyObj.clcommon__Type__c = mapOfpartyType.get(PortalConstants.SALES_AGENT_ADMIN_PARTY);
                    saAdminPartyObj.clcommon__Party_Types__c = PortalConstants.SALES_AGENT_ADMIN_PARTY;
                    saAdminPartyList.add(saAdminPartyObj);
                }
                Database.Insert(saAdminPartyList, true);
            }

        }
        
        if(relationship[0].clcommon__Relationship__r.Name == PortalConstants.CERTIFIED_LENDER 
            | relationship[0].clcommon__Relationship__r.Name == PortalConstants.CERTIFIED_LENDER_PLUS){
            applicationObj.Certified_Lender__c = relationship[0].clcommon__Related_Entity__c;
        }
        else if(relationship[0].clcommon__Relationship__r.Name == PortalConstants.SALES_AGENT
                || relationship[0].clcommon__Relationship__r.Name == PortalConstants.SALES_AGENT_PLUS){
            applicationObj.Sales_Agent__c = relationship[0].clcommon__Related_Entity__c;
            clParty.clcommon__Type__c = mapOfpartyType.get(roleToPartyTypeMap.get(relationship[0].clcommon__Relationship__r.Name));
            clParty.clcommon__Party_Types__c = roleToPartyTypeMap.get(relationship[0].clcommon__Relationship__r.Name);
            dealerRelationPartyList.add(clParty);
        }
         else if(relationship[0].clcommon__Relationship__r.Name == PortalConstants.SALES_AGENT_ADMIN){
            clParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.SALES_AGENT_ADMIN_PARTY);
            clParty.clcommon__Party_Types__c = PortalConstants.SALES_AGENT_ADMIN_PARTY;
            dealerRelationPartyList.add(clParty);
        }


        /**
         * Prod issue fix: Certified lenders will be able to view all the applications of that 
         * particular dealer
         */
        clRelationships = [SELECT Id, 
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
                                    :PortalConstants.FIELD_STAFF_AGENT,
                                    :PortalConstants.PAYMENT_ADMINISTRATOR
                                )];

        //get a random CL 
        for(clcommon__Relationship__c eachCl : clRelationships){
            if(eachCl.clcommon__Relationship__r.Name == PortalConstants.CERTIFIED_LENDER){
                certifiedLenderId = eachCl.clcommon__Related_Entity__c;
            }
        }  
        // if the application is created by SA/SA+, assign a random CL/CL+ initially.
        if (clRelationships.size() > 0 &
            (relationship[0].clcommon__Relationship__r.Name == PortalConstants.SALES_AGENT |
            relationship[0].clcommon__Relationship__r.Name == PortalConstants.SALES_AGENT_PLUS |
            relationship[0].clcommon__Relationship__r.Name == PortalConstants.SALES_AGENT_ADMIN |
            relationship[0].clcommon__Relationship__r.Name == PortalConstants.FIELD_STAFF_AGENT)) {
                applicationObj.Certified_Lender__c = certifiedLenderId;
        }

        // also create parties of all the CLs for that particular dealer
        for (clcommon__Relationship__c relation : clRelationships) {
            // getting all the certified lenders account id in a list  
            relationIdList.add(relation.clcommon__Related_Entity__c);
        }

        if (relationIdList.size() == 0) {
            return;
        }
        List<Contact> relationContactList = [SELECT Account.Id, 
                                                    Id,
                                                    Account.RecordType.Name 
                                            FROM Contact 
                                            WHERE AccountId IN :relationIdList];

        dealerRelationPartyList = getPartiesForRelatedCL(dealerRelationPartyList, relationContactList, applicationObj.Id);

        Database.upsert(dealerRelationPartyList, true);
        Database.upsert(applicationObj, true);
        //Adding a sharing record for the loggedIn user
        genesis__Applications__Share appShareObj = new genesis__Applications__Share();
        appShareObj.AccessLevel = EDIT;
        appShareObj.ParentId = applicationObj.Id;
        appShareObj.UserOrGroupId = loggedInUser.Id;
        Database.Insert(appShareObj, true);

        PortalApplicationOriginationHelper.createSharingRecords(loggedInUser, applicationObj);

        if(shouldValidate == NEW_APPLICANT & createPrimaryApplicant == false){
            PortalApplicationOriginationHelper.createPrimaryApplicantParty(applicationObj, primaryApplicantContact, mapOfpartyType);
        }
    } 

    /**
     * @description This method will process the business account name.
     * @author Ayan Bhowmik | 11-21-2023
     * @param paramMap 
     * @return  `Account`
     */
    public static Account processBusinessAccount(Map<String, Object> paramMap){

        Account accountObj = (Account)paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        Contact contactObj = (Contact)paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        genesis__Applications__c applicationObj = (genesis__Applications__c)paramMap.get(PortalConstants.APPLICATION_OBJ_KEY);
        String entity = (String)paramMap.get(ENTITY_KEY);

        Boolean isValidAccount = PortalSecurityUtil.validateUserApplicationByBusinessAccount(applicationObj.Id, accountObj.Id); 
        if (!isValidAccount) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        } 
        //Rename the Account from Contact for Individual Sole Prop ------------------
        if(entity == PortalConstants.SOLE_PROP_ENTITY && !String.isBlank(contactObj.Id) && !String.isBlank(contactObj.LastName)){
            PortalApplicationOriginationHelper.setAccountName(accountObj, contactObj);
        }
        return accountObj;
    }

    /**
     * @description The purpose of this method is to assign portal to the grower.
     * @author Ayan Bhowmik | 11-27-2023
     * @param newPortalUser 
     * @param coopType 
     * @return  `New_Portal_User__e`
     */
    public static New_Portal_User__e assigningProfileToNewUser(New_Portal_User__e newPortalUser, String coopType){
        Map<String,Id> mapOfProfileName = new Map<String,Id>();
        List<Profile> profileList = [SELECT Id,
                                        name
                                        FROM Profile 
                                        WHERE Name = :PortalConstants.GROWER_PROFILE OR Name = :PortalConstants.GMK_GROWER_PROFILE];
        for(Profile eachProfile : profileList){
            mapOfProfileName.put(eachProfile.Name,eachProfile.Id);
        }

        if(coopType != PortalConstants.EMPTY_STRING && coopType == PortalConstants.GROWMARK_COOP_TYPE){
            newPortalUser.Profile_Id__c = mapOfProfileName.get(PortalConstants.GMK_GROWER_PROFILE);
            newPortalUser.Coop_Type__c = PortalConstants.WHITE_LABEL_COOP_TYPE;
        }else{
            newPortalUser.Profile_Id__c = mapOfProfileName.get(PortalConstants.GROWER_PROFILE );
            newPortalUser.Coop_Type__c = PortalConstants.GREY_LABEL_COOP_TYPE;
        }
        return newPortalUser;
    }

   
    /**
     * @description The purpose of this method is to return coop type of dealer.
     * @author Ayan Bhowmik | 11-27-2023
     * @param dealerId 
     * @return  `String`
     */
    public static String getCoopTypeOfDealer(Id dealerId){
        String coopType = PortalConstants.EMPTY_STRING;
        Account dealerAccount = [SELECT Id, 
                                        Coop_Type__c 
                                FROM Account 
                                WHERE id = :dealerId];
        if((String)dealerAccount.Coop_Type__c != null){
            coopType = dealerAccount.Coop_Type__c;
        }
        return coopType;
    }

    /**
     * @description The purpose of this method is to assign defaults values for term, interest rate, pricing method and product type
     * @author Ayan Bhowmik | 11-27-2023
     * @param applicationObj 
     * @return  `genesis__Applications__c`
     */
    public static genesis__Applications__c setDefaultValue(genesis__Applications__c applicationObj){
        if (applicationObj.genesis__Term__c == null) {
            // adding default term
            applicationObj.genesis__Term__c = PortalConstants.TERM; 
        }

        if (applicationObj.genesis__Interest_Rate__c == null) {
            // adding default interest rate
            applicationObj.genesis__Interest_Rate__c = PortalConstants.INTEREST_RATE;
        }

        applicationObj.genesis__Pricing_Method__c = PortalConstants.RATE_CARD_STRING;
        applicationObj.genesis__Product_Type__c = PortalConstants.LOAN_TYPE; 

        return applicationObj;
    }

    /**
     * @description The purpose of this method is to throw an exception if neccessary params are missing.
     * @author Ayan Bhowmik | 11-27-2023
     * @param paramMap 
     */
    public static void checkRequiredParamsForNewApplicant(Map<String, Object> paramMap){

        if (String.isBlank(String.valueOf(paramMap.get(KEY_LOAN_AMOUNT))) 
                    | String.isBlank(String.valueOf(paramMap.get(KEY_ENTITY_TYPE)))) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        
        if (String.isBlank(String.valueOf(paramMap.get(KEY_COMPANY_NAME)))
                    & String.isBlank(String.valueOf(paramMap.get(KEY_DBA_NAME)))
                    & (String.isBlank(String.valueOf(paramMap.get(KEY_FIRST_NAME))) || String.isBlank(String.valueOf(paramMap.get(KEY_LAST_NAME))))) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        
        if (String.isBlank(String.valueOf(paramMap.get(KEY_EMAIL)))) {
            throw new CustomException(PortalConstants.EMAIL_FIELD_MISSING);
        }
    }

    /**
     * @description The purpose of this method is to assign cif number for new applicant.
     * @author Ayan Bhowmik | 11-27-2023
     * @param accountObj 
     * @param coopType 
     * @param loggedInUser 
     * @return  `Account`
     */
    public static Account assignCifForNewApplicant(Account accountObj, String coopType, List<User> loggedInUser){
        CFA_Configuration__c latestCIF = [SELECT CIF_Number__c, 
                                                    Growmark_CIF_Number__c
                                              FROM CFA_Configuration__c];
        if(accountObj.id == null){
            if(coopType != PortalConstants.EMPTY_STRING && coopType == PortalConstants.GROWMARK_COOP_TYPE){
                accountObj.CIF_Number__c = String.valueOf(latestCIF.Growmark_CIF_Number__c);
                latestCIF.Growmark_CIF_Number__c = String.valueOf(Decimal.valueOf(latestCIF.Growmark_CIF_Number__c) + 1);
            }
            else{
                accountObj.CIF_Number__c = String.valueOf(latestCIF.CIF_Number__c);
                latestCIF.CIF_Number__c = String.valueOf(Decimal.valueOf(latestCIF.CIF_Number__c) + 1);
            }
            accountObj.Coop_Type__c = coopType;
            accountObj.ParentId = loggedInUser[0].Account.ParentId;
            Database.update(latestCIF, true);
        }else{ 
            List<Account> accList = [SELECT Id, CIF_Number__c FROM Account WHERE Id = :accountObj.Id LIMIT 1];
            if(accList[0].CIF_Number__c == null || accList[0].CIF_Number__c == PortalConstants.EMPTY_STRING){
                if(coopType != PortalConstants.EMPTY_STRING && coopType == PortalConstants.GROWMARK_COOP_TYPE){
                    accountObj.CIF_Number__c = String.valueOf(latestCIF.Growmark_CIF_Number__c);
                    latestCIF.Growmark_CIF_Number__c = String.valueOf(Decimal.valueOf(latestCIF.Growmark_CIF_Number__c) + 1);
                }
                else{
                    accountObj.CIF_Number__c = String.valueOf(latestCIF.CIF_Number__c);
                    latestCIF.CIF_Number__c = String.valueOf(Decimal.valueOf(latestCIF.CIF_Number__c) + 1);
                }
                accountObj.Coop_Type__c = coopType;
                accountObj.ParentId = loggedInUser[0].Account.ParentId;
                Database.update(latestCIF, true);
            }
        }
        return accountObj;
    }   

   
    /**
    * @description Return the account and contacts for coapplicant. 
    * @param paramMap 
    * @param dealerCoop 
    * @param dealerId 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> processForNewApplicantOfIndividualType(Map<String, Map<String, Object>> paramMap,String dealerCoop,String dealerId){

        Map<String, Object> numbersMap = paramMap.get(KEY_NUMBERS_MAP);
        Map<String, Object> nameMap = paramMap.get(KEY_NAME_MAP);
        Map<String, Object> ssnEmailTinMap = paramMap.get(KEY_SSN_EMAIL_TIN_MAP);
        Map<String, Object> paramForIndividual = paramMap.get(KEY_ACC_CON_OBJ);
        Account accountObj = (Account)paramForIndividual.get(KEY_ACCOUNT_OBJ);
        Contact contactObj = (Contact)paramForIndividual.get(KEY_CONTACT_OBJ);

        // individual type
        accountObj.Name = nameMap.get(KEY_LAST_NAME) + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + nameMap.get(KEY_FIRST_NAME);
        accountObj.Is_Individual__c = true;
        contactObj.LastName = String.valueOf(nameMap.get(KEY_LAST_NAME));
        contactObj.genesis__SSN__c = String.valueOf(ssnEmailTinMap.get(KEY_SSN));
        contactObj.Confirm_SSN__c = String.valueOf(ssnEmailTinMap.get(KEY_CONFIRM_SSN));
        contactObj.FirstName = String.valueOf(nameMap.get(KEY_FIRST_NAME));

        if(!String.isBlank(String.valueOf(numbersMap.get(KEY_MOBILE_NUMBER)))){
            accountObj.Phone = String.valueOf(numbersMap.get(KEY_MOBILE_NUMBER));
            contactObj.MobilePhone = String.valueOf(numbersMap.get(KEY_MOBILE_NUMBER));
        }
        if(!String.isBlank(String.valueOf(numbersMap.get(KEY_HOME_NUMBER)))){
            accountObj.Home_Number__c = String.valueOf(numbersMap.get(KEY_HOME_NUMBER));
            contactObj.HomePhone = String.valueOf(numbersMap.get(KEY_HOME_NUMBER));
        }
        if(!String.isBlank(String.valueOf(numbersMap.get(KEY_WORK_NUMBER)))){
            accountObj.Work_Number__c = String.valueOf(numbersMap.get(KEY_WORK_NUMBER));
            contactObj.Phone = String.valueOf(numbersMap.get(KEY_WORK_NUMBER));
        }


        if (String.valueOf(ssnEmailTinMap.get(KEY_EMAIL)) != null) {
            contactObj.Email = String.valueOf(ssnEmailTinMap.get(KEY_EMAIL));
            accountObj.clcommon__email__c = String.valueOf(ssnEmailTinMap.get(KEY_EMAIL));
        }
        
        if (String.valueOf(ssnEmailTinMap.get(KEY_CONFIRM_EMAIL)) != null) {
            contactObj.Confirm_Email__c = String.valueOf(ssnEmailTinMap.get(KEY_CONFIRM_EMAIL));
        }
        
        contactObj = PortalValidationUtil.validateNewGrower(contactObj, dealerCoop, dealerId);

        accountObj.Id = contactObj.AccountId;
        populateNecessaryAccountDetails(accountObj, contactObj);


        return new Map<String, Object>{
            KEY_ACCOUNT_OBJ => accountObj,
            KEY_CONTACT_OBJ => contactObj
        };
    }

    /**
     * @description The purpose of this method is process for dba entity type.
     * @param paramMap 
     * @param ssnEmailTinMap 
     * @param dbaName
     * @return  `Map<String, Object>`
     */
    public static Map<String, Object> processForNewApplicantOfDBAType(Map<String, Object> paramMap,
                                                                                 Map<String, String> ssnEmailTinMap,
                                                                                 String dbaName){
        Account accountObj = (Account)paramMap.get(KEY_ACCOUNT_OBJ);
        Contact contactObj = (Contact)paramMap.get(KEY_CONTACT_OBJ);

        accountObj.Name = dbaName;
        accountObj.Is_Individual__c = false;
        contactObj.LastName = dbaName;
        
        Contact primaryApplicantContact = new Contact(); 
        if (ssnEmailTinMap.get(KEY_EMAIL) != null) {
            primaryApplicantContact.Email = ssnEmailTinMap.get(KEY_EMAIL);
        }
        primaryApplicantContact.genesis__SSN__c = ssnEmailTinMap.get(KEY_SSN);
        PortalValidationUtil.validateNewCoApplicant(primaryApplicantContact, loggedInUser[0].Account.Parent.Coop_Type__c);

        return new Map<String, Object>{
            KEY_ACCOUNT_OBJ => accountObj,
            KEY_CONTACT_OBJ => contactObj
        };
    }

    /**
    * @description The purpose of this method is process for company entity type.
    * @param paramMap 
    * @param numberTinMap 
    * @param companyName 
    * @return  `Map<String, Object>`
    */
    public static Map<String, Object> processForNewApplicantOfCompanyType(Map<String, Object> paramMap,
                                                                            Map<String, Map<String, String>> numberTinMap,
                                                                            String companyName){
        Account accountObj = (Account)paramMap.get(KEY_ACCOUNT_OBJ);
        Contact contactObj = (Contact)paramMap.get(KEY_CONTACT_OBJ);    
        genesis__Business_Information__c objBusinessInfo = (genesis__Business_Information__c)paramMap.get(KEY_BUSINESS_INFO);
        
        Map<String, String> numbersMap = numberTinMap.get(KEY_NUMBERS_MAP);
        Map<String, String> ssnEmailTinMap = numberTinMap.get(KEY_SSN_EMAIL_TIN_MAP);

        accountObj.Name = companyName;
        accountObj.Is_Individual__c = false;
        objBusinessInfo.genesis__Tax_Identification_Number__c = ssnEmailTinMap.get(KEY_TIN);
        objBusinessInfo.Confirm_Tax_Identification_Number__c = ssnEmailTinMap.get(KEY_CONFIRM_TIN);
        contactObj.LastName = companyName;

        contactObj.Email = ssnEmailTinMap.get(KEY_EMAIL);
        contactObj.Confirm_Email__c = ssnEmailTinMap.get(KEY_EMAIL);
        accountObj.clcommon__Email__c = ssnEmailTinMap.get(KEY_EMAIL);
        accountObj.Confirm_Email__c = ssnEmailTinMap.get(KEY_EMAIL);

        if(!String.isBlank(String.valueOf(numbersMap.get(KEY_MOBILE_NUMBER)))){
            accountObj.Phone = String.valueOf(numbersMap.get(KEY_MOBILE_NUMBER));
            contactObj.MobilePhone = String.valueOf(numbersMap.get(KEY_MOBILE_NUMBER));
        }
        if(!String.isBlank(String.valueOf(numbersMap.get(KEY_HOME_NUMBER)))){
            accountObj.Home_Number__c = String.valueOf(numbersMap.get(KEY_HOME_NUMBER));
            contactObj.HomePhone = String.valueOf(numbersMap.get(KEY_HOME_NUMBER));
        }
        if(!String.isBlank(String.valueOf(numbersMap.get(KEY_WORK_NUMBER)))){
            accountObj.Work_Number__c = String.valueOf(numbersMap.get(KEY_WORK_NUMBER));
            contactObj.Phone = String.valueOf(numbersMap.get(KEY_WORK_NUMBER));
        }

        Contact primaryApplicantContact = new Contact();
        if (ssnEmailTinMap.get(KEY_EMAIL) != null) {
            primaryApplicantContact.Email = ssnEmailTinMap.get(KEY_EMAIL);
        }
        primaryApplicantContact.genesis__SSN__c = ssnEmailTinMap.get(KEY_SSN);

        PortalValidationUtil.validateDuplicateCorporation(new Map<String,Object>{PortalConstants.BUSINESS_INFO_OBJ_KEY=>objBusinessInfo,
                                                                                 PortalConstants.ACCOUNT_OBJ_KEY=>accountObj,
                                                                                 PortalConstants.DEALER_ID_KEY=>loggedInUser[0].Account.ParentId});

        // if account existed in the system, use same account, contact
        if(accountObj.Id != null || !String.isBlank(accountObj.Id)){
            List<Contact> existingContactList = [SELECT Id 
                                                 FROM Contact 
                                                 WHERE AccountId =:accountObj.Id ];
            PortalApplicationOriginationHelper.checkEmptyList(existingContactList, PortalConstants.SOMETHING_WENT_WRONG);
            contactObj.Id = existingContactList[0].Id;
        }

        PortalValidationUtil.validateNewCoApplicant(primaryApplicantContact,loggedInUser[0].Account.Parent.Coop_Type__c);

        return new Map<String, Object>{
            KEY_ACCOUNT_OBJ => accountObj,
            KEY_CONTACT_OBJ => contactObj,
            KEY_BUSINESS_INFO => objBusinessInfo
        };
    }

    /**
     * @description The Purpose of this method is to create portal user.
     * @param existingAccountId 
     * @param paramMap 
     * @return  `Map<String, Object>`
     */
    public static Map<String, Object> processForExistingGrowerWithNoApp(String existingAccountId, Map<String, Object> paramMap){
        Account accountObj = (Account)paramMap.get(KEY_ACCOUNT_OBJ);
        genesis__Applications__c applicationObj = (genesis__Applications__c)paramMap.get(KEY_APPLICATION_OBJ);
        New_Portal_User__e newPortalUser = (New_Portal_User__e)paramMap.get(KEY_NEW_PORTAL_USER);

        List<Account> objExistingAccount = [SELECT Id,
                                                    CIF_Number__c, 
                                                    clcommon__Legal_Entity_Type__r.Name 
                                                FROM Account 
                                                WHERE Id = :existingAccountId];
        if(objExistingAccount.size()>0){
            if(String.valueOf(objExistingAccount[0].clcommon__Legal_Entity_Type__c) == null ||
                        objExistingAccount[0].clcommon__Legal_Entity_Type__r.Name != PortalConstants.SOLE_PROP_ENTITY){
                throw new CustomException(PortalConstants.SEND_APPLICATION_ERROR);
            }
            List<Contact> objExistingContact = [SELECT Id, 
                                                        FirstName, 
                                                        LastName, 
                                                        Email 
                                                    FROM Contact
                                                    WHERE AccountID = :existingAccountId];
            accountObj.Id = existingAccountId;

            applicationObj.genesis__Account__c = existingAccountId;
            applicationObj.genesis__Contact__c = objExistingContact[0].Id;
            newPortalUser = setPortalUserDetails(newPortalUser, New Map<String, Object>{
                'portalUserEmail' => objExistingContact[0].Email,
                'portalUserFirstName' => objExistingContact[0].FirstName,
                'portalUserLastName' => objExistingContact[0].LastName,
                'portalUserAccountId' => existingAccountId,
                'portalUserContactId' => objExistingContact[0].Id,
                'portalUserCIFNumber' => objExistingAccount[0].CIF_Number__c
            });
        }
        return new Map<String, Object>{
            KEY_ACCOUNT_OBJ => accountObj,
            KEY_APPLICATION_OBJ => applicationObj,
            KEY_NEW_PORTAL_USER => newPortalUser
        };
    }
    /**
     * @description The purpose of this method is to procees parties for new applicant.
     * @param paramMap 
     * @param newPortalUser 
     * @param idAppCompanyNameMap 
     * @return  `New_Portal_User__e`
     */
    public static New_Portal_User__e processPrincipalForNewApplicantOfCompanyOrDbaType(Map<String, Map<String, String>> paramMap, 
                                                                                            New_Portal_User__e newPortalUser,
                                                                                            Map<String, Object> idAppCompanyNameMap){
        Map<String, String> nameMap = paramMap.get(KEY_NAME_MAP);
        Map<String, String> ssnEmailTinMap = paramMap.get(KEY_SSN_EMAIL_TIN_MAP);
        Map<String, String> numbersMap = paramMap.get(KEY_NUMBERS_MAP);
        String companyOrDbaName = String.valueOf(idAppCompanyNameMap.get(PortalConstants.KEY_COMPANY_OR_DBA_NAME));
        String applicationId = String.valueOf(idAppCompanyNameMap.get(PortalConstants.APPLICATION_ID_KEY));
        List<Contact> priApplicantContactList = new List<Contact>();

        Dealer_Applicant_Relationship__c dealerApplicantRelObj=new Dealer_Applicant_Relationship__c();

        Map<String,Object> principalDetails;
        Account principalAccount=new Account();
        Contact principalContact=new Contact();

        if (String.isBlank(companyOrDbaName)) {
            return newPortalUser;
        }
        clcommon__Party__c principalParty = new clcommon__Party__c();
        principalParty.genesis__Application__c = applicationId;
        principalParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.PRINCIPAL_PARTY_NAME);
        principalParty.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;

        if(ssnEmailTinMap.get(KEY_SSN) != null || !String.isBlank(ssnEmailTinMap.get(KEY_SSN))){
            
            priApplicantContactList=[SELECT Id,
                                            AccountId,
                                            Account.Kyc_Verified__c,
                                            Account.clcommon__Legal_Entity_Type__c,
                                            genesis__SSN__c,
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
                                            clcommon__Marital_Status__c,
                                            Email,
                                            Confirm_Email__c
                                    FROM Contact
                                    WHERE genesis__SSN__c = :ssnEmailTinMap.get(KEY_SSN)
                                    AND (Account.clcommon__Legal_Entity_Type__r.Name = :PortalConstants.SOLE_PROP_ENTITY
                                    OR Account.clcommon__Legal_Entity_Type__c = null)];
            
        }
        
        if (priApplicantContactList.isEmpty()) {

            principalDetails=createPrincipalPartyForSendToGrower(paramMap,principalParty);
            principalAccount=(Account) principalDetails.get(PortalConstants.ACCOUNT_OBJ_KEY);
            principalContact=(Contact) principalDetails.get(PortalConstants.CONTACT_OBJ_KEY);

            newPortalUser = setPortalUserDetails(newPortalUser, New Map<String, Object>{
                PortalConstants.KEY_PORTAL_USER_EMAIL => ssnEmailTinMap.get(KEY_EMAIL),
                PortalConstants.KEY_PORTAL_USER_FIRST_NAME => nameMap.get(KEY_FIRST_NAME),
                PortalConstants.KEY_PORTAL_USER_LAST_NAME => nameMap.get(KEY_LAST_NAME),
                PortalConstants.KEY_PORTAL_USER_ACC_ID => principalAccount.Id,
                PortalConstants.KEY_PORTAL_USER_CON_ID => principalContact.Id,
                PortalConstants.KEY_PORTAL_USER_CIF_NUM => principalAccount.CIF_Number__c
            });
    

        } else {
            priApplicantContactList[0] = setEmptyIfNumbersBlank(priApplicantContactList[0], numbersMap);

            List<Account> priApplicantAccountList = [SELECT Id,
                                                            Name,
                                                            CIF_Number__c,
                                                            genesis__Business_Information__c
                                                    FROM Account
                                                    WHERE Id =: priApplicantContactList[0].AccountId];

            PortalApplicationOriginationHelper.checkEmptyList(priApplicantAccountList, PortalConstants.SOMETHING_WENT_WRONG);

            if(!priApplicantContactList[0].Account.Kyc_Verified__c){
                priApplicantContactList[0].FirstName = nameMap.get(KEY_FIRST_NAME);
                priApplicantContactList[0].Lastname = nameMap.get(KEY_LAST_NAME);
                //update email from received portal
                priApplicantContactList[0].Email = ssnEmailTinMap.get(KEY_EMAIL);
                priApplicantContactList[0].Confirm_Email__c = ssnEmailTinMap.get(KEY_CONFIRM_EMAIL);

                priApplicantAccountList[0].Name = nameMap.get(KEY_LAST_NAME) + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + nameMap.get(KEY_FIRST_NAME);
                priApplicantAccountList[0].clcommon__Email__c = ssnEmailTinMap.get(KEY_EMAIL);
                priApplicantAccountList[0].Confirm_Email__c = ssnEmailTinMap.get(KEY_CONFIRM_EMAIL);

            }
            else{
                ssnEmailTinMap.put(KEY_EMAIL,priApplicantContactList[0].Email);
                ssnEmailTinMap.put(KEY_CONFIRM_EMAIL,priApplicantContactList[0].Confirm_Email__c);
            }

            priApplicantAccountList[0] = setEmptyIfNumbersBlank(priApplicantAccountList[0], numbersMap);
            priApplicantAccountList[0].ParentId = loggedInUser[0].Account.ParentId;

            Database.Update(priApplicantContactList[0], true);
            Database.update(priApplicantAccountList[0], true);

            principalParty.clcommon__Account__c = priApplicantContactList[0].AccountId;
            principalParty.clcommon__Contact__c = priApplicantContactList[0].Id;

            List<Dealer_Applicant_Relationship__c> dealerApplicantRelList=[ SELECT ID
                                                                            FROM Dealer_Applicant_Relationship__c
                                                                            WHERE Dealer__c= :loggedInUser[0].Account.ParentId
                                                                            AND Applicant__c= :priApplicantAccountList[0].id
                                                                            LIMIT 1];
                                                                            
            if(dealerApplicantRelList.isEmpty()){
                dealerApplicantRelObj=createDealerApplicantRelationship(new Map<String,Object>{
                                                                                            PortalConstants.LOGGED_IN_USER=>loggedInUser[0],
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>priApplicantContactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>priApplicantAccountList[0]
                                                                                        });
                 Database.insert(dealerApplicantRelObj,true);
                 dealerApplicantRelList.add(dealerApplicantRelObj);
            }

            principalParty.Title__c=priApplicantContactList[0].Title;
            principalParty.Suffix__c	=priApplicantContactList[0].Suffix__c;
            principalParty.Street__c=priApplicantContactList[0].MailingStreet;
            principalParty.City__c=priApplicantContactList[0].MailingCity;
            principalParty.State__c=priApplicantContactList[0].MailingState;
            principalParty.Postal_Code__c=priApplicantContactList[0].MailingPostalCode;
            principalParty.County__c=priApplicantContactList[0].Mailing_County__c;

            principalParty.Home_Number__c=priApplicantContactList[0].HomePhone;
            principalParty.Work_Number__c=priApplicantContactList[0].Phone;
            principalParty.Mobile_Number__c=priApplicantContactList[0].MobilePhone;

            List<genesis__Business_Information__c>  principalBusinessInfoList=[SELECT ID,
                                                                                      Gross_Farm_Income__c
                                                                                FROM genesis__Business_Information__c
                                                                                WHERE Id=: priApplicantAccountList[0].genesis__Business_Information__c];

            PortalApplicationOriginationHelper.checkEmptyList(principalBusinessInfoList, PortalConstants.SOMETHING_WENT_WRONG);
            

            principalParty.Gross_Farm_Income__c=principalBusinessInfoList[0].Gross_Farm_Income__c;

            principalParty.Marital_Status__c=priApplicantContactList[0].clcommon__Marital_Status__c;
            
            principalParty.Dealer_Applicant_Relationship__c=dealerApplicantRelList[0].id;


            //assigning CIF to primary co-applicant
            PortalApplicationCreationHandler.updateCifForAccount(priApplicantAccountList[0], loggedInUser[0].Account.Parent.Coop_Type__c);

            newPortalUser = setPortalUserDetails(newPortalUser, New Map<String, Object>{
                PortalConstants.KEY_PORTAL_USER_EMAIL => ssnEmailTinMap.get(KEY_EMAIL),
                PortalConstants.KEY_PORTAL_USER_FIRST_NAME => nameMap.get(KEY_FIRST_NAME),
                PortalConstants.KEY_PORTAL_USER_LAST_NAME => nameMap.get(KEY_LAST_NAME),
                PortalConstants.KEY_PORTAL_USER_ACC_ID => priApplicantContactList[0].AccountId,
                PortalConstants.KEY_PORTAL_USER_CON_ID => priApplicantContactList[0].Id,
                PortalConstants.KEY_PORTAL_USER_CIF_NUM => priApplicantAccountList[0].CIF_Number__c
            });

            Database.insert(principalParty, true);
        }


        return newPortalUser;
    }

    /**
    * @description creates an account, contact, businessInfo for the principal which is new
    * @author Rakesh Saraf | 12-05-2024 
    * @param paramMap 
    * @param principalParty 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> createPrincipalPartyForSendToGrower(Map<String, Map<String, String>> paramMap,clcommon__Party__c principalParty){
        Map<String, String> nameMap = paramMap.get(KEY_NAME_MAP);
        Map<String, String> ssnEmailTinMap = paramMap.get(KEY_SSN_EMAIL_TIN_MAP);
        Map<String, String> numbersMap = paramMap.get(KEY_NUMBERS_MAP);

        Dealer_applicant_Relationship__c dealerApplicantRelObj=new Dealer_Applicant_Relationship__c();

        genesis__Business_Information__c principalBusinessInfo = new genesis__Business_Information__c();
        Database.insert(principalBusinessInfo, true);

        Account principalAccount = new Account();
        principalAccount.genesis__Business_Information__c = principalBusinessInfo.Id;
        principalAccount.Name = nameMap.get(KEY_LAST_NAME) + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + nameMap.get(KEY_FIRST_NAME);
        principalAccount.clcommon__Email__c = ssnEmailTinMap.get(KEY_EMAIL);
        principalAccount.Confirm_Email__c = ssnEmailTinMap.get(KEY_CONFIRM_EMAIL);
        principalAccount = setEmptyIfNumbersBlank(principalAccount, numbersMap);
        principalAccount.OwnerId = PortalSecurityUtil.getSiteAdmin();
        principalAccount.ParentId = loggedInUser[0].Account.ParentId;
        principalAccount.clcommon__Legal_Entity_Type__c = mapOfLegalEntity.get(PortalConstants.SOLE_PROP_ENTITY);
        Database.insert(principalAccount, true);

        Contact principalContact = new Contact();
        principalContact.accountId = principalAccount.Id;
        principalContact.FirstName = nameMap.get(KEY_FIRST_NAME);
        principalContact.LastName = nameMap.get(KEY_LAST_NAME);
        principalContact.Email = ssnEmailTinMap.get(KEY_EMAIL);
        principalContact.Confirm_Email__c = ssnEmailTinMap.get(KEY_CONFIRM_EMAIL);
        principalContact.genesis__SSN__c = ssnEmailTinMap.get(KEY_SSN);
        principalContact.Confirm_SSN__c = ssnEmailTinMap.get(KEY_CONFIRM_SSN);
        principalContact = setEmptyIfNumbersBlank(principalContact, numbersMap);
        Database.insert(principalContact, true);

        principalParty.clcommon__Account__c = principalAccount.Id;
        principalParty.clcommon__Contact__c = principalContact.Id;

        //assigning CIF to primary co-applicant
        PortalApplicationCreationHandler.updateCifForAccount(principalAccount, loggedInUser[0].Account.Parent.Coop_Type__c);

        dealerApplicantRelObj=createDealerApplicantRelationship(new Map<String,Object>{
            PortalConstants.LOGGED_IN_USER=>loggedInUser[0],
            PortalConstants.CONTACT_OBJ_KEY=>principalContact,
            PortalConstants.ACCOUNT_OBJ_KEY=>principalAccount
        });

        Database.insert(dealerApplicantRelObj,true);

        principalParty.Home_Number__c=principalContact.HomePhone;
        principalParty.Work_Number__c=principalContact.Phone;
        principalParty.Mobile_Number__c=principalContact.MobilePhone;

        principalParty.Dealer_Applicant_Relationship__c=dealerApplicantRelObj.id;

        Database.insert(principalParty, true);

        return new Map<String,Object>{PortalConstants.ACCOUNT_OBJ_KEY=>principalAccount,
                                      PortalConstants.CONTACT_OBJ_KEY=>principalContact};
    }

    /**
     * @description The purpose of this method is to set numbers to empty string if numbers are blank on account.
     * @param accountObj 
     * @param numbersMap 
     * @return  `Account`
     */
    public static Account setEmptyIfNumbersBlank(Account accountObj, Map<String, String> numbersMap){
        if(!String.isBlank(numbersMap.get(KEY_MOBILE_NUMBER))){
            accountObj.Phone = numbersMap.get(KEY_MOBILE_NUMBER);
        }
        if(!String.isBlank(numbersMap.get(KEY_WORK_NUMBER))){
            accountObj.Work_Number__c = numbersMap.get(KEY_WORK_NUMBER);
        }
        if(!String.isBlank(numbersMap.get(KEY_HOME_NUMBER))){
            accountObj.Home_Number__c = numbersMap.get(KEY_HOME_NUMBER);
        }
        return accountObj;
    }
    /**
     * @description The purpose of this method is to set numbers to empty string if numbers are blank on contact.
     * @param contactObj 
     * @param numbersMap 
     * @return  `Contact`
     */
    public static Contact setEmptyIfNumbersBlank(Contact contactObj, Map<String, String> numbersMap){
        if(!String.isBlank(numbersMap.get(KEY_MOBILE_NUMBER))){
            contactObj.MobilePhone = numbersMap.get(KEY_MOBILE_NUMBER);
        }
        if(!String.isBlank(numbersMap.get(KEY_WORK_NUMBER))){
            contactObj.Phone = numbersMap.get(KEY_WORK_NUMBER);
        }
        if(!String.isBlank(numbersMap.get(KEY_WORK_NUMBER))){
            contactObj.HomePhone = numbersMap.get(KEY_HOME_NUMBER);
        }
        return contactObj;
    }

    /**
    * @description return the existing applicant account and contact details 
    * @author Sk Minsar | 01-23-2024 
    * @param paramMap 
    * @param latestApplication 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> processForExistingApplicantWithExistingApp(Map<String, Object> paramMap, 
                                                                                    List<genesis__Applications__c> latestApplication){
        String email = String.valueOf(paramMap.get(KEY_EMAIL));
        Account accountObj = (Account)paramMap.get(KEY_ACCOUNT_OBJ);
        genesis__Applications__c applicationObj = (genesis__Applications__c)paramMap.get(KEY_APPLICATION_OBJ);
        New_Portal_User__e newPortalUser = (New_Portal_User__e)paramMap.get(KEY_NEW_PORTAL_USER);

        // an application exists for this grower

        if (latestApplication[0].genesis__account__r.clcommon__Legal_Entity_Type__r.Name == PortalConstants.SOLE_PROP_ENTITY) {
            // if the existing application is a sole-prop
            if (latestApplication[0].genesis__contact__r.Email == null) {
                // cannot perform send-to-grower as grower's email is empty
                throw new CustomException(EMPTY_GROWER_EMAIL);
            }
            email = latestApplication[0].genesis__contact__r.Email;

        } else {
            // if the existing application is a business/dba 

            List<clcommon__Party__c> existingCoApplicants = 
                                        [SELECT Id,
                                                clcommon__Contact__r.Email
                                            FROM clcommon__Party__c
                                            WHERE genesis__Application__c = :latestApplication[0].Id
                                            AND clcommon__Type__r.Name = :PortalConstants.PRINCIPAL_PARTY_NAME
                                            ORDER BY CreatedDate ASC 
                                            LIMIT 1];

            if (existingCoApplicants.size() == 0) {
                throw new CustomException(NO_COAPP_FOUND);
            }

            if (existingCoApplicants[0].clcommon__Contact__r.Email == null) {
                throw new CustomException(EMPTY_PRINCIPAL_EMAIL);
            }

            email = existingCoApplicants[0].clcommon__Contact__r.Email;

        }
        accountObj.Id = latestApplication[0].genesis__account__c;
        applicationObj.genesis__Account__c = latestApplication[0].genesis__account__c;
        applicationObj.genesis__Contact__c = latestApplication[0].genesis__contact__c;

        
        return new Map<String, Object>{
            KEY_EMAIL => email,
            KEY_ACCOUNT_OBJ => accountObj,
            KEY_APPLICATION_OBJ => applicationObj,
            KEY_NEW_PORTAL_USER => newPortalUser
        };
    }

    /**
    * @description The purpose of this method is to create principal party for existing applicant.
    * @author Sk Minsar | 01-23-2024 
    * @param paramMap 
    **/
    public static void createPrincipalParty(Map<String, Id> paramMap){
        
        List<clcommon__Party__c> newPartyList = new List<clcommon__Party__c>();
        List<clcommon__Party__c> existingPartyList = [SELECT Id,  
                                                            clcommon__Account__r.genesis__Business_Information__r.genesis__Total_Assets__c,
                                                            clcommon__Account__r.genesis__Business_Information__r.genesis__Total_Liabilities__c,
                                                            Dealer_Applicant_Relationship__r.Has_Past_Due__c,
                                                            Dealer_Applicant_Relationship__r.Is_Non_Accrual__c,
                                                            clcommon__Account__c,
                                                            clcommon__Account__r.genesis__Business_Information__c,
                                                            clcommon__Type__c,
                                                            clcommon__Type__r.Name, 
                                                            clcommon__Contact__c, 
                                                            clcommon__Party_Types__c,
                                                            genesis__Application__c 
                                                        FROM clcommon__Party__c 
                                                        WHERE genesis__Application__c = :parammap.get(KEY_EXISTING_APP_ID)
                                                        AND clcommon__Type__r.Name IN (:PortalConstants.PRINCIPAL_PARTY_NAME)
                                                        ORDER BY CreatedDate ASC
                                                        LIMIT 1];

        for (clcommon__Party__c existingParty: existingPartyList) {
            clcommon__Party__c partyObj = new clcommon__Party__c();
            partyObj.genesis__Application__c = paramMap.get(KEY_APPLICATION_ID);
            partyObj.clcommon__Account__c = existingParty.clcommon__Account__c;
            partyObj.clcommon__Contact__c = existingParty.clcommon__Contact__c;
            partyObj.clcommon__Type__c = existingParty.clcommon__Type__c;
            partyObj.clcommon__Party_Types__c = existingParty.clcommon__Type__r.Name;
            newPartyList.add(partyObj);
        }
        for(clcommon__Party__c existingParty: existingPartyList){
            if(existingParty.clcommon__Type__r.Name != PortalConstants.PRINCIPAL_PARTY_NAME){
                continue;
            }
            if(existingParty.Dealer_Applicant_Relationship__r.Has_Past_Due__c == true){
                throw new CustomException(PortalConstants.PAST_DUE_APPLICATIONS_EXCEPTION);
            }
            if(existingParty.Dealer_Applicant_Relationship__r.Is_Non_Accrual__c == true){
                throw new CustomException(PortalConstants.NON_ACCRUAL_APPLICATIONS_EXCEPTION);
            }
            
        }
        
        Database.insert(newPartyList, true); 
    }

     /**
     * @description The purpose of this method is to set contact details from existing contact. (Fix for individual sole prop. when a coapp is used as a sole prop.)
     * @param contactObj 
     * @return  `Contact`
     */
    public static Contact setContactDetailsFromExistingContact(Contact contactObj){
        List<Contact> exitingContactList = [SELECT Id,
                                                    Name,
                                                    MailingStreet,
                                                    MailingCity,
                                                    MailingState,
                                                    MailingPostalCode,
                                                    Mailing_County__c,
                                                    Birthdate,
                                                    clcommon__Marital_Status__c,
                                                    Suffix__c,
                                                    MobilePhone,
                                                    HomePhone,
                                                    Phone
                                                FROM Contact
                                                WHERE Id = :contactObj.Id];
        if(exitingContactList.isEmpty()){
            return contactObj;
        }
        contactObj.MailingStreet = exitingContactList[0].MailingStreet == null ? PortalConstants.EMPTY_STRING : exitingContactList[0].MailingStreet;
        contactObj.MailingCity = exitingContactList[0].MailingCity == null ? PortalConstants.EMPTY_STRING : exitingContactList[0].MailingCity;
        contactObj.MailingState = exitingContactList[0].MailingState == null ? PortalConstants.EMPTY_STRING : exitingContactList[0].MailingState;
        contactObj.MailingPostalCode = exitingContactList[0].MailingPostalCode == null ? PortalConstants.EMPTY_STRING : exitingContactList[0].MailingPostalCode;
        contactObj.Mailing_County__c = exitingContactList[0].Mailing_County__c == null ? PortalConstants.EMPTY_STRING : exitingContactList[0].Mailing_County__c;
        contactObj.Birthdate = exitingContactList[0].Birthdate;
        contactObj.clcommon__Marital_Status__c = exitingContactList[0].clcommon__Marital_Status__c == null ? PortalConstants.EMPTY_STRING : exitingContactList[0].clcommon__Marital_Status__c;
        contactObj.Suffix__c = exitingContactList[0].Suffix__c == null ? PortalConstants.EMPTY_STRING : exitingContactList[0].Suffix__c;
        contactObj = setContactNumbers(contactObj, exitingContactList);

        return contactObj;
    }

    /**
     * @description Purpose of this method is to set contact numbers from the existing contact.
     * @param contactObj 
     * @param exitingContactList 
     * @return  `Contact`
     */
    private static Contact setContactNumbers(Contact contactObj, List<Contact> exitingContactList){

        contactObj.MobilePhone = exitingContactList[0].MobilePhone == null ? PortalConstants.EMPTY_STRING : exitingContactList[0].MobilePhone;
        contactObj.HomePhone = exitingContactList[0].HomePhone == null ? PortalConstants.EMPTY_STRING : exitingContactList[0].HomePhone;
        contactObj.Phone = exitingContactList[0].Phone == null ? PortalConstants.EMPTY_STRING : exitingContactList[0].Phone;
        
        return contactObj;
    }


    /**
     * @description The purpose of this method is to set account details from existing account. (Fix for individual sole prop. when a sole prop is used to create an new app with same ssn and email.)
     * @param accountObj 
     * @param contactObj 
     * @return  `Account`
     */
    public static Account setAccountDetailsFromExistingAccount(Account accountObj, Contact contactObj){
        List<Account> exitingAccountList = [SELECT Id,
                                                    Name,
                                                    BillingStreet,
                                                    BillingCity,
                                                    BillingState,
                                                    BillingPostalCode,
                                                    Billing_County__c,
                                                    Phone,
                                                    Work_Number__c,
                                                    Home_Number__c
                                                FROM Account
                                                WHERE Id = :contactObj.AccountId];
        if(exitingAccountList.isEmpty()){
            return accountObj;
        }
        accountObj.BillingStreet = exitingAccountList[0].BillingStreet == null ? PortalConstants.EMPTY_STRING : exitingAccountList[0].BillingStreet;
        accountObj.BillingCity = exitingAccountList[0].BillingCity == null ? PortalConstants.EMPTY_STRING : exitingAccountList[0].BillingCity;
        accountObj.BillingState = exitingAccountList[0].BillingState == null ? PortalConstants.EMPTY_STRING : exitingAccountList[0].BillingState;
        accountObj.BillingPostalCode = exitingAccountList[0].BillingPostalCode == null ? PortalConstants.EMPTY_STRING : exitingAccountList[0].BillingPostalCode;
        accountObj.Billing_County__c = exitingAccountList[0].Billing_County__c == null ? PortalConstants.EMPTY_STRING : exitingAccountList[0].Billing_County__c;
        setAccountDetails(accountObj, exitingAccountList);

        return accountObj;
    }

    /**
     * @description The purpose of this method is to set account details from an existing account.
     * @param accountObj 
     * @param exitingAccountList 
     * @return  `Account`
     */
    private static Account setAccountDetails(Account accountObj, List<Account> exitingAccountList){

        accountObj.Work_Number__c = exitingAccountList[0].Work_Number__c == null ? PortalConstants.EMPTY_STRING : exitingAccountList[0].Work_Number__c;
        accountObj.Home_Number__c = exitingAccountList[0].Home_Number__c == null ? PortalConstants.EMPTY_STRING : exitingAccountList[0].Home_Number__c;
        accountObj.Phone = exitingAccountList[0].Phone == null ? PortalConstants.EMPTY_STRING : exitingAccountList[0].Phone;

        return accountObj;
    }
    
    /**
    * @description - This method return ERP Id from existing grower's application 
    * @author Sk Minsar | 01-17-2024 
    * @param existingAccountId 
    * @param dealerId 
    * @return String 
    **/
    public static Map<String,String> getIdentifierMap(Id existingAccountId, Id dealerId){
        String erpId = PortalConstants.EMPTY_STRING;
        String uniqueId = PortalConstants.EMPTY_STRING;
        String irc = PortalConstants.EMPTY_STRING;
        List<genesis__Applications__c>  lastActiveAppOfGrowerList = [SELECT Id,
                                        Unique_Identifier__c,
                                        Internal_Reference_Code__c,
                                        ERP_Id__c,
                                        Dealer_Name__r.Enable_ERP_Id__c 
                                        FROM genesis__Applications__c 
                                        WHERE genesis__Account__c =: existingAccountId
                                        AND Dealer_Name__c =: dealerId
                                        AND genesis__Status__c IN (
                                            :PortalConstants.ACTIVE_APPLICATION_STATUS,
                                            :PortalConstants.CLOSED_APPLICATION_STATUS)
                                        ORDER BY genesis__Status__c ASC, genesis__Loan_Number__c DESC LIMIT 1];
        
        if (lastActiveAppOfGrowerList.size() > 0){
            if(lastActiveAppOfGrowerList[0].Dealer_Name__r.Enable_ERP_Id__c = true){
                 erpId = String.valueOf(lastActiveAppOfGrowerList[0].ERP_Id__c);
            }
            uniqueId = String.valueOf(lastActiveAppOfGrowerList[0].Unique_Identifier__c);
            irc = String.valueOf(lastActiveAppOfGrowerList[0].Internal_Reference_Code__c);
        }
        Map<String,String> identifierMap = new Map<String,String>{'erpId' => erpId,
                                                                    'uniqueId' => uniqueId,
                                                                    'irc' => irc
                                                                };
        return identifierMap;
    }

    /**
    * @description - This method validates the ERP ID
    * @author Sk Minsar | 01-17-2024 
    * @param erpId 
    * @param applicationId 
    * @param shouldValidate 
    * @return String 
    **/
    public static String validateErpId(String erpId, String applicationId, Boolean shouldValidate){
        erpId = setEmptyIfStringBlank(erpId);
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                ERP_Id__c,
                                                                Dealer_Name__c,
                                                                Dealer_Name__r.Enable_ERP_Id__c,
                                                                Dealer_Name__r.Is_Required_ERP_Id__c
                                                            FROM genesis__Applications__c
                                                          WHERE Id =: applicationId];

        PortalApplicationOriginationHelper.checkEmptyList(applicationList, PortalConstants.SOMETHING_WENT_WRONG);
        
        if(!applicationList[0].Dealer_Name__r.Enable_ERP_Id__c){
            applicationList[0].ERP_Id__c = setEmptyIfStringBlank(applicationList[0].ERP_Id__c);
            if(!erpId.equals(applicationList[0].ERP_Id__c)){
                throw new CustomException(PortalConstants.ERP_ID_NOT_ENABLED);
            }
            return applicationList[0].ERP_Id__c;
        }
        if(!shouldValidate){
            return erpId;
        }
        if(applicationList[0].Dealer_Name__r.Is_Required_ERP_Id__c && String.isBlank(erpId)){
            throw new CustomException(PortalConstants.ERP_ID_REQUIRED);
        }
        return erpId;
    }

    /**
    * @description - this method set empty value into a string if it's blank or null
    * @author Sk Minsar | 02-20-2024 
    * @param input 
    * @return String 
    **/
    public static String setEmptyIfStringBlank(String input){
        if(String.isBlank(input)){
            return PortalConstants.EMPTY_STRING;
        }
    return input;
    }

     //========================================================================================================================
    //========================================================================================================================
    //NEW METHODS RELATED TO APPLICATION CREATION
    //========================================================================================================================
    //========================================================================================================================
    
    /**
    * @description check the parameter 
    * @author Krishanu Chinya | 02-19-2024 
    * @param application 
    * @param primaryApplicantAccount 
    **/
    public static void checkNecessaryParam(String application, String primaryApplicantAccount){
        if ((String.isBlank(application) || String.isBlank(primaryApplicantAccount))) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
    }
   
    /**
    * @description : called from initiate application api, thus populates only necessary account details for sole prop
    * @author Krishanu Chinya | 02-09-2024 
    * @param accountObj 
    * @param contactObj 
    * @return Account 
    **/
    public static Account populateNecessaryAccountDetails(Account accountObj, Contact contactObj){
        if (String.isBlank(accountObj.Name)) {
            accountObj.Name = contactObj.LastName + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + contactObj.FirstName;
            accountObj.Is_Individual__c = true;
            accountObj.Id = contactObj.AccountId;
            accountObj.genesis__Business_Information__c = contactObj.Account.genesis__Business_Information__c;
        }
        return accountObj;
    }

    /**
    * @description : updates the business info id according to found account, contact
    * @author Krishanu Chinya | 02-14-2024 
    * @param contactId 
    * @param growerBusinessInfo 
    **/
    public static void updateBusinessInfo (Id contactId, genesis__Business_Information__c growerBusinessInfo){
        if(!String.isBlank(contactId)){
            List<Contact> contactList = [SELECT Id, 
                                        Account.genesis__business_information__c 
                                    FROM Contact 
                                    WHERE Id =:contactId];

            growerBusinessInfo.Id = contactList[0].Account.genesis__business_information__c;
        }
    }

   
    /**
    * @description Create dealer contact party 
    * @author Krishanu Chinya | 02-14-2024 
    * @param paramMap 
    **/
    public static void linkDealerPartyToApplication(Map<String, Object> paramMap) {
        clcommon__Party__c partyObj = new clcommon__Party__c();
        List<clcommon__Relationship__c> allDealerRelationList = new List<clcommon__Relationship__c>();
        List<clcommon__Relationship__c> loggedInUserRelationList = new List<clcommon__Relationship__c>();
        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        Id randomCLId;
        List<String> dealerRelationAccIdList = new List<String>();
        clcommon__Party__c loggedInUserParty = new clcommon__Party__c();
        Map<String,String> roleToPartyTypeMap = new Map<String,String>{
            PortalConstants.SALES_AGENT_PLUS => PortalConstants.SALES_AGENT_PLUS_PARTY_NAME,
            PortalConstants.SALES_AGENT => PortalConstants.SALES_AGENT_PARTY_NAME
        };
        
        User loggedInUser = (User)paramMap.get('loggedInUser');
        genesis__Applications__c applicationObj = (genesis__Applications__c)paramMap.get('applicationObj');

        //Querieng
        allDealerRelationList = [SELECT Id,
                                    clcommon__Related_Entity__c,
                                    clcommon__Related_Entity__r.ParentId,
                                    clcommon__Relationship__r.Name
                                    FROM clcommon__Relationship__c
                                    WHERE clcommon__Entity__c = :loggedInUser.Account.ParentId
                                    AND clcommon__Relationship__r.Name IN (
                                        :PortalConstants.FIELD_STAFF_AGENT,
                                        :PortalConstants.CERTIFIED_LENDER, 
                                        :PortalConstants.CERTIFIED_LENDER_PLUS,
                                        :PortalConstants.SALES_AGENT_ADMIN,
                                        :PortalConstants.SALES_AGENT, 
                                        :PortalConstants.SALES_AGENT_PLUS,
                                        :PortalConstants.INQUIRY,
                                        :PortalConstants.INQUIRY_PLUS, 
                                        :PortalConstants.PAYMENT_ADMINISTRATOR)];

        PortalApplicationOriginationHelper.checkEmptyList(allDealerRelationList, PortalConstants.SOMETHING_WENT_WRONG);

        for(clcommon__Relationship__c eachRelation: allDealerRelationList){
            //checking whether logged in user has relation with dealer
            if(eachRelation.clcommon__Related_Entity__c == loggedInUser.AccountId){
                loggedInUserRelationList.add(eachRelation);
            }
            // getting all the dealer relation's account id in a list  
            dealerRelationAccIdList.add(eachRelation.clcommon__Related_Entity__c);

            //fetching a random cl
            if(eachRelation.clcommon__Relationship__r.Name == PortalConstants.CERTIFIED_LENDER 
                    | eachRelation.clcommon__Relationship__r.Name == PortalConstants.CERTIFIED_LENDER_PLUS){
                randomCLId = eachRelation.clcommon__Related_Entity__c;
            }
        }

        //if logged in user doesn't have a relationship with dealer
        PortalApplicationOriginationHelper.checkEmptyList(loggedInUserRelationList, PortalConstants.SOMETHING_WENT_WRONG);

        //adding dealer party
        partyObj.genesis__Application__c = applicationObj.Id;
        partyObj.clcommon__Account__c = loggedInUser.Account.ParentId;   
        partyObj.clcommon__Type__c = mapOfpartyType.get(PortalConstants.DEALER_PARTY_NAME);
        partyObj.clcommon__Party_Types__c = PortalConstants.DEALER_PARTY_NAME;
        partyList.add(partyObj);

        //setting dealer name in application
        applicationObj.Dealer_Name__c = loggedInUser.Account.ParentId;
        applicationObj.OwnerId = PortalSecurityUtil.getSiteAdmin();

        //adding party of logged in user
        loggedInUserParty.genesis__Application__c = applicationObj.Id;
        loggedInUserParty.clcommon__Account__c = loggedInUser.AccountId;
        loggedInUserParty.clcommon__Contact__c = loggedInUser.ContactId;

        if(loggedInUserRelationList[0].clcommon__Relationship__r.Name == PortalConstants.CERTIFIED_LENDER 
            | loggedInUserRelationList[0].clcommon__Relationship__r.Name == PortalConstants.CERTIFIED_LENDER_PLUS){

            applicationObj.Certified_Lender__c = loggedInUserRelationList[0].clcommon__Related_Entity__c;
            }
        else if(loggedInUserRelationList[0].clcommon__Relationship__r.Name == PortalConstants.SALES_AGENT
                    || loggedInUserRelationList[0].clcommon__Relationship__r.Name == PortalConstants.SALES_AGENT_PLUS){

            applicationObj.Sales_Agent__c = loggedInUserRelationList[0].clcommon__Related_Entity__c;

            loggedInUserParty.clcommon__Type__c = mapOfpartyType.get(roleToPartyTypeMap.get(loggedInUserRelationList[0].clcommon__Relationship__r.Name));
            loggedInUserParty.clcommon__Party_Types__c = roleToPartyTypeMap.get(loggedInUserRelationList[0].clcommon__Relationship__r.Name);
            partyList.add(loggedInUserParty);
            addSAAdminParty(loggedInUserRelationList[0].clcommon__Related_Entity__c, applicationObj.Id);

}
        else if(loggedInUserRelationList[0].clcommon__Relationship__r.Name == PortalConstants.SALES_AGENT_ADMIN){

            loggedInUserParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.SALES_AGENT_ADMIN_PARTY);
            loggedInUserParty.clcommon__Party_Types__c = PortalConstants.SALES_AGENT_ADMIN_PARTY;
            partyList.add(loggedInUserParty);
        }

        // if the application is created by SA/SA+/SAAdmin/FSA, assign a random CL/CL+ initially.
        if (loggedInUserRelationList.size() > 0 &
            (loggedInUserRelationList[0].clcommon__Relationship__r.Name == PortalConstants.SALES_AGENT |
            loggedInUserRelationList[0].clcommon__Relationship__r.Name == PortalConstants.SALES_AGENT_PLUS |
            loggedInUserRelationList[0].clcommon__Relationship__r.Name == PortalConstants.SALES_AGENT_ADMIN |
            loggedInUserRelationList[0].clcommon__Relationship__r.Name == PortalConstants.FIELD_STAFF_AGENT)) {
                
                applicationObj.Certified_Lender__c = randomCLId;
        }

        //creating parties of all CL/CL+/Inquiry/Inquiry+/FSA/PA
        createDealerRelationParties(new Map<String,List<Object>>{PortalConstants.KEY_DEALER_RELATION=>allDealerRelationList,
                                                                 PortalConstants.KEY_DEALER_RELATION_ACC_ID =>dealerRelationAccIdList, 
                                                                 PortalConstants.KEY_PARTY =>partyList}, applicationObj.Id);

        Database.upsert(partyList, true);
        Database.upsert(applicationObj, true);
        
        //create sharing records for cl/cl+/inq/inq+/fsa
        createDealerRelationSharingRecords(loggedInUser, applicationObj.Id, dealerRelationAccIdList);
    }

    
    /**
    * @description 
    * @author Krishanu Chinya | 03-05-2024  
    * @param paramMap 
    * @param applicationId 
    **/
    public static void createDealerRelationParties(Map<String,List<Object>> paramMap, Id applicationId){
        List<clcommon__Relationship__c> allDealerRelationList=(List<clcommon__Relationship__c>) paramMap.get(PortalConstants.KEY_DEALER_RELATION);
        List<String> dealerRelationAccIdList=(List<String>) paramMap.get(PortalConstants.KEY_DEALER_RELATION_ACC_ID);
        List<clcommon__Party__c> partyList=(List<clcommon__Party__c>) paramMap.get(PortalConstants.KEY_PARTY);

        PortalApplicationOriginationHelper.checkEmptyList(dealerRelationAccIdList, PortalConstants.SOMETHING_WENT_WRONG);
        Map<Id,Id> relationAccVSContactMap = new Map<Id, Id> ();

        List<Contact> dealerRelationContactList = [SELECT Id, 
                                                            Account.Id,
                                                            Account.RecordType.Name 
                                                    FROM Contact 
                                                    WHERE AccountId IN :dealerRelationAccIdList];

        for(Contact dealerRelationContact : dealerRelationContactList){
            relationAccVSContactMap.put(dealerRelationContact.AccountId, dealerRelationContact.Id);
        }

        for(clcommon__Relationship__c dealerRelation : allDealerRelationList){
            clcommon__Party__c relationParty = new clcommon__Party__c();
            relationParty.genesis__Application__c = applicationId;
            relationParty.clcommon__Account__c = dealerRelation.clcommon__Related_Entity__c;
            relationParty.clcommon__Contact__c = relationAccVSContactMap.get(dealerRelation.clcommon__Related_Entity__c);

            relationParty = updateRelationshipParty(dealerRelation,relationParty);
            
            if(relationParty.clcommon__Type__c != null){
                partyList.add(relationParty); 
            }
        }

    }
    
    /**
    * @description 
    * @author Krishanu Chinya | 03-05-2024 
    * @param dealerRelation 
    * @param relationParty 
    * @return clcommon__Party__c 
    **/
    private static clcommon__Party__c updateRelationshipParty(clcommon__Relationship__c dealerRelation,clcommon__Party__c relationParty){
        if(dealerRelation.clcommon__Relationship__r.Name == PortalConstants.CERTIFIED_LENDER ){
            relationParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.CL_PARTY_NAME);
            relationParty.clcommon__Party_Types__c = PortalConstants.CL_PARTY_NAME;
        }
        if(dealerRelation.clcommon__Relationship__r.Name == PortalConstants.CERTIFIED_LENDER_PLUS ){
            relationParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.CL_PLUS_PARTY_NAME);
            relationParty.clcommon__Party_Types__c = PortalConstants.CL_PLUS_PARTY_NAME; 
        }
        if(dealerRelation.clcommon__Relationship__r.Name == PortalConstants.INQUIRY ){
            relationParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.INQUIRY_PARTY_NAME);
            relationParty.clcommon__Party_Types__c = PortalConstants.INQUIRY_PARTY_NAME; 
        }
        if(dealerRelation.clcommon__Relationship__r.Name == PortalConstants.INQUIRY_PLUS ){
            relationParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.INQUIRY_PLUS_PARTY_NAME);
            relationParty.clcommon__Party_Types__c = PortalConstants.INQUIRY_PLUS_PARTY_NAME; 
        }
        if(dealerRelation.clcommon__Relationship__r.Name == PortalConstants.FIELD_STAFF_AGENT ){
            relationParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.FIELD_STAFF_AGENT_PARTY);
            relationParty.clcommon__Party_Types__c = PortalConstants.FIELD_STAFF_AGENT_PARTY;
        }
        if(dealerRelation.clcommon__Relationship__r.Name == PortalConstants.PAYMENT_ADMINISTRATOR ){
            relationParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.PAYMENT_ADMINISTRATOR_PARTY);
            relationParty.clcommon__Party_Types__c = PortalConstants.PAYMENT_ADMINISTRATOR_PARTY;
        }
        return relationParty;
    }
    
    /**
    * @description create sales agent admin party 
    * @author Krishanu Chinya | 03-05-2024 
    * @param saAccId 
    * @param applicationId 
    **/
    public static void addSAAdminParty(Id saAccId, Id applicationId){
            Map<Id,Id> saAdminAccIdvsConIdMap = new Map<Id,Id>();
            List<Contact> saAdminContactList = new List<Contact>();
            //add party of sa admin if the sa has an admin
            List<Id> saAdminAccIdList = PortalApplicationOriginationHelper.fetchSAAdmin(saAccId);
            
            if(!saAdminAccIdList.isEmpty()){
                saAdminContactList = [SELECT Id, 
                                                        AccountId
                                                    FROM Contact
                                                    WHERE AccountId IN :saAdminAccIdList];
                for(Contact con : saAdminContactList){
                    saAdminAccIdvsConIdMap.put(con.AccountId, con.Id);
                }
                                                    
                PortalApplicationOriginationHelper.checkEmptyList(saAdminContactList, PortalConstants.SOMETHING_WENT_WRONG); 
                List<clcommon__Party__c> saAdminPartyList = new List<clcommon__Party__c>();

                for(Id saAdminAccId : saAdminAccIdList){
                    clcommon__Party__c saAdminPartyObj = new clcommon__Party__c();
                    saAdminPartyObj.genesis__Application__c = applicationId;
                    saAdminPartyObj.clcommon__Account__c = saAdminAccId;
                    saAdminPartyObj.clcommon__contact__c = saAdminAccIdvsConIdMap.get(saAdminAccId);
                    saAdminPartyObj.clcommon__Type__c = mapOfpartyType.get(PortalConstants.SALES_AGENT_ADMIN_PARTY);
                    saAdminPartyObj.clcommon__Party_Types__c = PortalConstants.SALES_AGENT_ADMIN_PARTY;
                    saAdminPartyList.add(saAdminPartyObj);
                }
                Database.Upsert(saAdminPartyList, true);
            }
    }

    
    /**
    * @description create sales agent party 
    * @author Krishanu Chinya | 02-09-2024 
    * @param applicationObj 
    **/
    public static void addSalesAgentParty(genesis__Applications__c applicationObj){

        Map<String,String> recordTypeToPartyTypeMap = new Map<String,String>{
            PortalConstants.SALES_AGENT_PLUS => PortalConstants.SALES_AGENT_PLUS_PARTY_NAME,
            PortalConstants.SALES_AGENT => PortalConstants.SALES_AGENT_PARTY_NAME
        };

        List<clcommon__party__c> salesAgentPartyList = [SELECT Id,
                                                            clcommon__Account__c 
                                                        FROM clcommon__party__c
                                                        WHERE genesis__Application__c =: applicationObj.Id
                                                        AND (clcommon__Type__c=: mapOfpartyType.get(PortalConstants.SALES_AGENT_PARTY_NAME)
                                                        OR clcommon__Type__c =: mapOfpartyType.get(PortalConstants.SALES_AGENT_PLUS_PARTY_NAME))];

        if(applicationObj.Sales_Agent__c == null && !salesAgentPartyList.isEmpty()){
            deleteSAAdminParty(salesAgentPartyList[0].clcommon__Account__c, applicationObj.Id);
            Database.delete(salesAgentPartyList, true);
        }

        if(applicationObj.Sales_Agent__c != null && !salesAgentPartyList.isEmpty() && applicationObj.Sales_Agent__c != salesAgentPartyList[0].clcommon__Account__c){
            deleteSAAdminParty(salesAgentPartyList[0].clcommon__Account__c, applicationObj.Id);
            Database.delete(salesAgentPartyList, true);
            clcommon__Party__c salesAgentParty = new clcommon__Party__c();

            List<Contact> salesAgentContactList = [SELECT Id,
                                                        Account.RecordType.Name
                                                    FROM Contact
                                                    WHERE AccountId = :applicationObj.Sales_Agent__c];
            
            PortalApplicationOriginationHelper.checkEmptyList(salesAgentContactList, PortalConstants.SOMETHING_WENT_WRONG);

            salesAgentParty.genesis__Application__c = applicationObj.Id;
            salesAgentParty.clcommon__Account__c = applicationObj.Sales_Agent__c;
            salesAgentParty.clcommon__contact__c = salesAgentContactList[0].Id;
            salesAgentParty.clcommon__Type__c = mapOfpartyType.get(recordTypeToPartyTypeMap.get(salesAgentContactList[0].Account.RecordType.Name));
            salesAgentParty.clcommon__Party_Types__c = recordTypeToPartyTypeMap.get(salesAgentContactList[0].Account.RecordType.Name);
       
            Database.upsert(salesAgentParty, true);


            //FOR SA ADMIN
            addSAAdminParty(applicationObj.Sales_Agent__c, applicationObj.Id);
        }

        //if app has sales agent but there is no party, create a party
        if (salesAgentPartyList.size() <= 0 && applicationObj.Sales_Agent__c != null) {
            clcommon__Party__c salesAgentParty = new clcommon__Party__c();

            List<Contact> salesAgentContactList = [SELECT Id,
                                                        Account.RecordType.Name
                                                    FROM Contact
                                                    WHERE AccountId = :applicationObj.Sales_Agent__c];
            
            PortalApplicationOriginationHelper.checkEmptyList(salesAgentContactList, PortalConstants.SOMETHING_WENT_WRONG);

            salesAgentParty.genesis__Application__c = applicationObj.Id;
            salesAgentParty.clcommon__Account__c = applicationObj.Sales_Agent__c;
            salesAgentParty.clcommon__contact__c = salesAgentContactList[0].Id;
            if(salesAgentContactList[0].Account.RecordType.Name == PortalConstants.SALES_AGENT_PLUS){
                salesAgentParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.SALES_AGENT_PLUS_PARTY_NAME);
                salesAgentParty.clcommon__Party_Types__c = PortalConstants.SALES_AGENT_PLUS_PARTY_NAME;
            }
            else{
            salesAgentParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.SALES_AGENT_PARTY_NAME);
            salesAgentParty.clcommon__Party_Types__c = PortalConstants.SALES_AGENT_PARTY_NAME;
            } 
            Database.upsert(salesAgentParty, true);


            //FOR SA ADMIN
            addSAAdminParty(applicationObj.Sales_Agent__c, applicationObj.Id);
        }
    }

    /**
    * @description : deletes the sa admin party from application if sa is changed
    * @author Krishanu Chinya | 03-02-2024
    * @param saAccId 
    * @param applicationId 
    **/
    public static void deleteSAAdminParty(Id saAccId, Id applicationId){
        List<Id> saAdminAccIdList = PortalApplicationOriginationHelper.fetchSAAdmin(saAccId);
        List<clcommon__Party__c> saAdminPartyList = [SELECT Id 
                                                    FROM clcommon__Party__c
                                                    WHERE clcommon__Account__c IN :saAdminAccIdList
                                                    AND genesis__Application__c =: applicationId
                                                    AND clcommon__Type__c=: mapOfpartyType.get(PortalConstants.SALES_AGENT_ADMIN_PARTY)];
        Database.delete(saAdminPartyList, true);

        List<User> saAdminUserList = [SELECT Id 
                                        FROM USER 
                                        WHERE AccountId IN :saAdminAccIdList];

        //delete application sharing records
        List<genesis__Applications__Share> appShareToDel = [SELECT Id,
                                                                    ParentId,
                                                                    UserOrGroupId
                                                                    FROM genesis__Applications__Share
                                                                    WHERE UserOrGroupId IN :saAdminUserList
                                                                    AND ParentId =:applicationId];
        Database.delete(appShareToDel, false);

        //delete document sharing records
        List<clcommon__Document_Category__Share> docCatShareToDel = [SELECT Id,
                                                                            ParentId,
                                                                            UserOrGroupId
                                                                            FROM clcommon__Document_Category__Share
                                                                            WHERE UserOrGroupId IN :saAdminUserList
                                                                            AND Parent.genesis__Application__c =:applicationId];
        Database.delete(docCatShareToDel, false);
    }

    /**
     * @description : this method creates sharing records for the dealer relations
     * @param loggedInUser 
     * @param applicationId 
     * @param dealerRelationAccIdList 
     */
    public static void createDealerRelationSharingRecords(User loggedInUser, Id applicationId, List<String> dealerRelationAccIdList) {
        List<genesis__Applications__Share> appShareList = new List<genesis__Applications__Share>();
        List<clcommon__Document_Category__Share> docCatagoryShareList = new List<clcommon__Document_Category__Share>();
        genesis__Applications__Share loggedInUserAppShare = new genesis__Applications__Share();
        
        //Adding a sharing record for the loggedIn user
        //for sa/sa+/saadmin is creating the application
        if(loggedInUser.Account.RecordType.Name == PortalConstants.SALES_AGENT
                   || loggedInUser.Account.RecordType.Name == PortalConstants.SALES_AGENT_PLUS
                   || loggedInUser.Account.RecordType.Name == PortalConstants.SALES_AGENT_ADMIN){

            loggedInUserAppShare.AccessLevel = ConstantValues.ACCESS_LABEL_EDIT;
            loggedInUserAppShare.ParentId = applicationId;
            loggedInUserAppShare.UserOrGroupId = loggedInUser.Id;
            Database.Insert(loggedInUserAppShare, true);
        }

        List<User> dealerRelationUserList = [SELECT Id,
                                                    Account.RecordType.Name 
                                            FROM User 
                                            WHERE AccountId IN :dealerRelationAccIdList
                                            AND Account.RecordType.Name IN (
                                                :PortalConstants.CERTIFIED_LENDER, 
                                                :PortalConstants.CERTIFIED_LENDER_PLUS,
                                                :PortalConstants.INQUIRY,
                                                :PortalConstants.INQUIRY_PLUS,
                                                :PortalConstants.FIELD_STAFF_AGENT)];

        List<clcommon__Document_Category__c> documentCategoriesList = [SELECT Id 
                                                                   FROM clcommon__Document_Category__c 
                                                                   WHERE genesis__Application__c = :applicationId];

        
        for (User dealerRelationUser : dealerRelationUserList) {
            genesis__Applications__Share appShareRecord = new genesis__Applications__Share();
            appShareRecord.AccessLevel = ConstantValues.ACCESS_LABEL_EDIT;
            appShareRecord.ParentId = applicationId;
            appShareRecord.UserOrGroupId = dealerRelationUser.Id;
            appShareList.add(appShareRecord);

            for (clcommon__Document_Category__c documentCategory : documentCategoriesList) {

                clcommon__Document_Category__Share documentSharingRecord = new clcommon__Document_Category__Share();
                documentSharingRecord.AccessLevel = ConstantValues.ACCESS_LABEL_EDIT;
                documentSharingRecord.ParentId = documentCategory.Id;
                documentSharingRecord.UserOrGroupId = dealerRelationUser.Id;
                docCatagoryShareList.add(documentSharingRecord);
            }
        }

        Database.upsert(appShareList, false);
        Database.upsert(docCatagoryShareList, false);
    }

    /**
    * @description : updates the cif number of the borrower
    * @author Krishanu Chinya | 03-06-2024 
    * @param accountObj 
    * @param coopType 
    * @return Account 
    **/
    public static Account updateCifForAccount(Account accountObj, String coopType){
        List<CFA_Configuration__c> latestCIFList = [SELECT CIF_Number__c,
                                                            Growmark_CIF_Number__c
                                                    FROM CFA_Configuration__c];

        if(accountObj.Id == null){
            if(coopType != PortalConstants.EMPTY_STRING && coopType == PortalConstants.GROWMARK_COOP_TYPE){
                accountObj.CIF_Number__c = String.valueOf(latestCIFList[0].Growmark_CIF_Number__c);
                latestCIFList[0].Growmark_CIF_Number__c = String.valueOf(Decimal.valueOf(latestCIFList[0].Growmark_CIF_Number__c) + PortalConstants.ONE_VALUE);
            }
            else{
                accountObj.CIF_Number__c = String.valueOf(latestCIFList[0].CIF_Number__c);
                latestCIFList[0].CIF_Number__c = String.valueOf(Decimal.valueOf(latestCIFList[0].CIF_Number__c) + PortalConstants.ONE_VALUE);
            }
            Database.Update(latestCIFList, true);
        }else{ 
            accountObj=updateCIFForExistingAccount(accountObj,latestCIFList,coopType);
        }
        accountObj.Coop_Type__c = coopType;
        Database.upsert(accountObj, true);
        return accountObj;
    }

    /**
    * @description this method is used to update the cif for an existing account
    * @author Rakesh Saraf | 01-09-2025 
    * @param accountObj 
    * @param latestCIFList 
    * @param coopType 
    * @return Account 
    **/
    private static Account updateCIFForExistingAccount(Account accountObj,List<CFA_Configuration__c> latestCIFList,String coopType){
        List<Account> accList = [SELECT Id, 
                                            CIF_Number__c 
                                    FROM Account 
                                    WHERE Id = :accountObj.Id 
                                    LIMIT 1];

        if(accList[0].CIF_Number__c == null || accList[0].CIF_Number__c == PortalConstants.EMPTY_STRING){
            if(coopType != PortalConstants.EMPTY_STRING && coopType == PortalConstants.GROWMARK_COOP_TYPE){
                accountObj.CIF_Number__c = String.valueOf(latestCIFList[0].Growmark_CIF_Number__c);
                latestCIFList[0].Growmark_CIF_Number__c = String.valueOf(Decimal.valueOf(latestCIFList[0].Growmark_CIF_Number__c) + PortalConstants.ONE_VALUE);
            }
            else{
                accountObj.CIF_Number__c = String.valueOf(latestCIFList[0].CIF_Number__c);
                latestCIFList[0].CIF_Number__c = String.valueOf(Decimal.valueOf(latestCIFList[0].CIF_Number__c) + PortalConstants.ONE_VALUE);
            }
            Database.Update(latestCIFList, true);
        }else{
            accountObj.CIF_Number__c = accList[0].CIF_Number__c;
        }
        return accountObj;
    }

   
    /**
    * @description : creates a party of the primary applicant in the application
    * @author Krishanu Chinya | 03-05-2024 
    * @param applicationObj 
    * @param priApplicantContact 
    * @param dealerCoopType 
    **/
    public static void createPrimaryApplicantParty(genesis__Applications__c applicationObj, Contact priApplicantContact, String dealerCoopType){
        List<Contact> priApplicantContactList = new List<Contact>();
        //creating primary applicant party
        clcommon__Party__c priApplicantParty = new clcommon__Party__c();
        priApplicantParty.genesis__Application__c = applicationObj.Id;
        priApplicantParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.PRINCIPAL_PARTY_NAME);
        priApplicantParty.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;


        if(!String.isBlank(priApplicantContact.genesis__SSN__c)){
            if(dealerCoopType == PortalConstants.GROWMARK_COOP_TYPE){
                priApplicantContactList = [SELECT Id,
                                                    AccountId,
                                                    Account.clcommon__Legal_Entity_Type__c,
                                                    genesis__SSN__c
                                            FROM Contact
                                            WHERE genesis__SSN__c = :priApplicantContact.genesis__SSN__c
                                            AND Account.Coop_Type__c =: PortalConstants.GROWMARK_COOP_TYPE
                                            AND (Account.clcommon__Legal_Entity_Type__r.Name = :PortalConstants.SOLE_PROP_ENTITY
                                            OR Account.clcommon__Legal_Entity_Type__c = null)];
            }
            else{
                priApplicantContactList = [SELECT Id,
                                                AccountId,
                                                Account.clcommon__Legal_Entity_Type__c,
                                                genesis__SSN__c
                                        FROM Contact
                                        WHERE genesis__SSN__c = :priApplicantContact.genesis__SSN__c
                                        AND Account.Coop_Type__c !=: PortalConstants.GROWMARK_COOP_TYPE
                                        AND (Account.clcommon__Legal_Entity_Type__r.Name = :PortalConstants.SOLE_PROP_ENTITY
                                        OR Account.clcommon__Legal_Entity_Type__c = null)];
            }
        }

        if(priApplicantContactList.isEmpty()){
            //creating primary applicant business info
            genesis__Business_Information__c priApplicantBusinessInfo = new genesis__Business_Information__c();
            Database.Insert(priApplicantBusinessInfo, true);

            //creating primary applicant account
            Account priApplicantAcc = new Account();
            priApplicantAcc.Name = priApplicantContact.LastName + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + priApplicantContact.FirstName;
            priApplicantAcc.genesis__Business_Information__c = priApplicantBusinessInfo.Id;
            priApplicantAcc.clcommon__Legal_Entity_Type__c = mapOfLegalEntity.get(PortalConstants.SOLE_PROP_ENTITY);
            priApplicantAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.CO_APPLICATION_RECORD_TYPE).getRecordTypeId();
            priApplicantAcc.clcommon__Email__c = priApplicantContact.Email; 
            priApplicantAcc.Coop_Type__c = dealerCoopType; 
            priApplicantAcc.ParentId = applicationObj.Dealer_Name__c;
            priApplicantAcc.OwnerId = PortalSecurityUtil.getSiteAdmin();

            priApplicantAcc.Phone = priApplicantContact.MobilePhone;
            priApplicantAcc.Home_Number__c = priApplicantContact.HomePhone;
            priApplicantAcc.Work_Number__c = priApplicantContact.Phone;
            Database.Insert(priApplicantAcc, true);

            priApplicantContact.AccountId = priApplicantAcc.Id;
            priApplicantContact.OwnerId = PortalSecurityUtil.getSiteAdmin();
            Database.Insert(priApplicantContact, true);

         
            priApplicantParty.clcommon__Account__c = priApplicantContact.AccountId;
            priApplicantParty.clcommon__Contact__c = priApplicantContact.Id;
        }
        else{
            //update the existing contact
            priApplicantContactList[0].FirstName = priApplicantContact.FirstName;
            priApplicantContactList[0].Lastname = priApplicantContact.LastName;
            priApplicantContactList[0].ints__Middle_Name__c = priApplicantContact.ints__Middle_Name__c;
            priApplicantContactList[0].MobilePhone = priApplicantContact.MobilePhone;
            priApplicantContactList[0].HomePhone = priApplicantContact.HomePhone;
            priApplicantContactList[0].Phone = priApplicantContact.Phone;
            Database.Update(priApplicantContactList[0], true);

            //fetch the account 
            List<Account> priApplicantAccList = [SELECT Id, 
                                                        Work_Number__c, 
                                                        Home_Number__c, 
                                                        Phone, 
                                                        Name,
                                                        ParentId,
                                                        Coop_Type__c
                                                FROM Account
                                                WHERE Id =: priApplicantContactList[0].AccountId];

            //update the account details
            priApplicantAccList[0].Phone = priApplicantContact.MobilePhone;
            priApplicantAccList[0].Home_Number__c = priApplicantContact.HomePhone;
            priApplicantAccList[0].Work_Number__c = priApplicantContact.Phone;
            priApplicantAccList[0].Name = priApplicantContact.LastName + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + priApplicantContact.FirstName;
            priApplicantAccList[0].ParentId = applicationObj.Dealer_Name__c;
            priApplicantAccList[0].Coop_Type__c = dealerCoopType;

            Database.Update(priApplicantAccList[0], true);

            priApplicantParty.clcommon__Account__c = priApplicantContactList[0].AccountId;
            priApplicantParty.clcommon__Contact__c = priApplicantContactList[0].Id;
        }

        Database.Insert(priApplicantParty, true);
    }

   
    /**
    * @description this method is used to update the contact on borrower party, 
     *                 set parent id in borrower account,
     *                 set account id in borrower contact
    * @author Krishanu Chinya | 02-09-2024 
    * @param paramMap 
    **/
    public static void updateBorrowerDetails(Map<String,Object> paramMap){
        Contact contactObj=(Contact)paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        Account accountObj=(Account)paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        genesis__Business_Information__c businessInfoObj=(genesis__Business_Information__c)paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        genesis__Applications__c applicationObj=(genesis__Applications__c)paramMap.get(PortalConstants.APPLICATION_KEY);
        Id dealerApplicantRelId=(Id)paramMap.get(PortalConstants.ID_KEY);

        List<clcommon__party__c> borrowerPartyList = [SELECT Id,
                                                            clcommon__Contact__c
                                                        FROM clcommon__party__c
                                                        WHERE genesis__Application__c =: applicationObj.Id
                                                        AND clcommon__Type__r.Name =: PortalConstants.BORROWER_PARTY_NAME];

        if (borrowerPartyList.isEmpty()){
            clcommon__Party__c borrowerParty = new clcommon__Party__c();
            borrowerParty.genesis__Application__c = applicationObj.Id;
            borrowerParty.clcommon__Account__c = applicationObj.genesis__Account__c;
            borrowerParty.clcommon__Contact__c = applicationObj.genesis__Contact__c;
            List<clcommon__Party_Type__c> partyType = [SELECT Id
                                                       FROM clcommon__Party_Type__c
                                                       WHERE NAME =: PortalConstants.BORROWER_PARTY_NAME];
            borrowerParty.clcommon__Type__c = partyType[0].Id;
            borrowerParty.clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;
            borrowerParty.Dealer_Applicant_Relationship__c = dealerApplicantRelId;

            updateBorrowerPartyDetails(new Map<String,Object>{
                                                            PortalConstants.CONTACT_OBJ_KEY=>contactObj,
                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountObj,
                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoObj,
                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerParty
                                                        });
            Database.insert(borrowerParty, true);
        }
        else{
            borrowerPartyList[0].clcommon__Contact__c = applicationObj.genesis__Contact__c;
            borrowerPartyList[0].clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;  
            List<Dealer_Applicant_Relationship__c> dealerGrowerRelList=[SELECT Id
                                                                        FROM Dealer_Applicant_Relationship__c
                                                                        WHERE id=: applicationObj.Dealer_Applicant_Relationship__c
                                                                        LIMIT 1];

            PortalApplicationOriginationHelper.checkEmptyList(dealerGrowerRelList, PortalConstants.SOMETHING_WENT_WRONG);
            borrowerPartyList[0].Dealer_Applicant_Relationship__c = dealerGrowerRelList[0].id;

            List<Contact> borrowerContactList=[SELECT ID,
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
                                                WHERE ID=: applicationObj.genesis__Contact__c
                                                LIMIT 1];

            List<Account> borrowerAccountList=[SELECT ID,
                                                      clcommon__Legal_Entity_Type__c,
                                                      clcommon__Legal_Entity_Type__r.Name,
                                                      BillingStreet,
                                                      BillingCity,
                                                      BillingState,
                                                      BillingPostalCode,
                                                      Billing_County__c,
                                                      Home_Number__c,
                                                      Phone,
                                                      Work_Number__c,
                                                      genesis__Business_Information__c
                                                 FROM Account 
                                                 WHERE ID=: applicationObj.genesis__Account__c
                                                 LIMIT 1];
            List<genesis__Business_Information__c> borrowerBusinessInfoList=[SELECT ID,
                                                                                    Gross_Farm_Income__c
                                                                             FROM genesis__Business_Information__c 
                                                                             WHERE ID=: borrowerAccountList[0].genesis__Business_Information__c
                                                                             LIMIT 1];

            updateBorrowerPartyDetails(new Map<String,Object>{
                                                            PortalConstants.CONTACT_OBJ_KEY=>borrowerContactList[0],
                                                            PortalConstants.ACCOUNT_OBJ_KEY=>borrowerAccountList[0],
                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>borrowerBusinessInfoList[0],
                                                            PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]
                                                        });

            Database.update(borrowerPartyList, true);    
        }


        List<Account> accountList = [SELECT Id, 
                                    OwnerId,
                                    ParentId
                                FROM Account
                                WHERE Id=: applicationObj.genesis__Account__c];
        accountList[0].OwnerId = PortalSecurityUtil.getSiteAdmin();
        accountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId();
        //update parent id to current dealer
        accountList[0].ParentId = applicationObj.Dealer_Name__c;
        Database.Update(accountList, true);

        List<Contact> contactList = [SELECT Id, 
                                    AccountId
                                FROM Contact
                                WHERE Id = :applicationObj.genesis__Contact__c];
        contactList[0].AccountId = applicationObj.genesis__Account__c;
        Database.update(contactList, true);
    }

    /**
    * @description update the details of the borrower party
    * @author Rakesh Saraf | 12-02-2024 
    * @param paramMap 
    **/
    public static void updateBorrowerPartyDetails(Map<String,Object> paramMap){
        Contact contactObj=(Contact) paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        Account accountObj=(Account) paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        genesis__Business_Information__c businessInfoObj=(genesis__Business_Information__c) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        clcommon__Party__c borrowerParty=(clcommon__Party__c) paramMap.get(PortalConstants.BORROWER_PARTY_KEY);
        String legalEntity=PortalConstants.EMPTY_STRING;

        borrowerParty.Gross_Farm_Income__c=businessInfoObj.Gross_Farm_Income__c;

        if(!String.isBlank(accountObj.clcommon__Legal_Entity_Type__c)){
            legalEntity = PortalApplicationOriginationHelper.getLegalEntityByAccount(accountObj);
        }

        if(legalEntity!=PortalConstants.CORPORATION & legalEntity!=PortalConstants.INDIVIDUAL_ENTITY){
            borrowerParty.Title__c=contactObj.Title;
            borrowerParty.Suffix__c	=contactObj.Suffix__c;
        }
        else{
            borrowerParty.Title__c=PortalConstants.EMPTY_STRING;
            borrowerParty.Suffix__c=PortalConstants.EMPTY_STRING;
        }
        if(accountObj.clcommon__Legal_Entity_Type__c==null || legalEntity==PortalConstants.SOLE_PROP_ENTITY ){
            borrowerParty.Street__c=contactObj.MailingStreet;
            borrowerParty.City__c=contactObj.MailingCity;
            borrowerParty.State__c=contactObj.MailingState;
            borrowerParty.Postal_Code__c=contactObj.MailingPostalCode;
            borrowerParty.County__c=contactObj.Mailing_County__c;

            borrowerParty.Home_Number__c=contactObj.HomePhone;
            borrowerParty.Work_Number__c=contactObj.Phone;
            borrowerParty.Mobile_Number__c=contactObj.MobilePhone;

            borrowerParty.Marital_Status__c=contactObj.clcommon__Marital_Status__c;

        }
        else{
            borrowerParty.Street__c=accountObj.BillingStreet;
            borrowerParty.City__c=accountObj.BillingCity;
            borrowerParty.State__c=accountObj.BillingState;
            borrowerParty.Postal_Code__c=accountObj.BillingPostalCode;
            borrowerParty.County__c=accountObj.Billing_County__c;

            borrowerParty.Home_Number__c=accountObj.Home_Number__c;
            borrowerParty.Work_Number__c=accountObj.Work_Number__c;
            borrowerParty.Mobile_Number__c=accountObj.Phone;
        }
    }

    /**
    * @description : checks whether atleast a coapplicant exists for dba and corporation or not
    * @author Krishanu Chinya | 03-05-2024 
    * @param coApplicantRecord 
    * @param entity 
    **/
    public static void checkForCoApplicant(String coApplicantRecord, String entity){
        if (coApplicantRecord == null && entity != PortalConstants.SOLE_PROP_ENTITY) {
            throw new CustomException(PortalConstants.CO_APPLICANT_MISSING);
        }
    }

    /**
    * @description : process a list of coapplicants from argument
    * @author Krishanu Chinya | 03-05-2024 
    * @param coApplicantRecord 
    * @return List<Map<String, Object>> 
    **/
    public static List<Map<String, Object>> getCoApplicantList(String coApplicantRecord){
        List<Object> coApplicantList = new List<Object>();
        List<Map<String, Object>> coApplicantDetailList = new List<Map<String, Object>>();
        if (!String.isBlank(coApplicantRecord)) {
            coApplicantList = (List<Object>) Json.deserializeUntyped(coApplicantRecord);
        }
        for (Object eachCoApplicant : coApplicantList) {
            Map<String, Object> coApplicant = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(eachCoApplicant));
            coApplicantDetailList.add(coApplicant);
        }
        return coApplicantDetailList;
    }

   
    
    /**
    * @description : updates coop type and record types of principal parties
    * @author Krishanu Chinya | 03-07-2024 
    * @param applicationId 
    * @param coopType 
    * @param loggedInUser 
    **/
    public static void updatePrincipalParties(String applicationId, String coopType,User loggedInUser){
        List<String> principalAccIdList = new List<String>();
        List<String> principalConIdList = new List<String>();
        List<String> principalBInfoIdList = new List<String>();
        List<Dealer_Applicant_Relationship__c> createdDealerAppRelList=new List<Dealer_Applicant_Relationship__c>();

        List<Dealer_Applicant_Relationship__c> dealerPrincipalRelList=new List<Dealer_Applicant_Relationship__c>();
        Map<Id,Contact> idVSContactMap=new Map<Id,Contact>();
        Map<Id,Id> dealerApplicantRelMap=new Map<Id,Id>();



        //Query all the Principal Party and update the coop type on the coapplicant
        List<clcommon__Party__c> principalPartyList = [SELECT Id,
                                                            clcommon__Account__c,
                                                            clcommon__Contact__c,
                                                            genesis__Application__r.Coop_Type__c,
                                                            genesis__Application__r.Dealer_Name__r.Coop_Type__c,
                                                            Dealer_Applicant_Relationship__c
                                                        FROM clcommon__Party__c
                                                        WHERE genesis__Application__c = :applicationId 
                                                        AND clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME];

        for(clcommon__Party__c eachPrincipalParty : principalPartyList){
            principalAccIdList.add(eachPrincipalParty.clcommon__Account__c);
            principalConIdList.add(eachPrincipalParty.clcommon__Contact__c);
        }
        
        dealerPrincipalRelList=[SELECT ID ,
                                        Applicant__c
                                FROM Dealer_Applicant_Relationship__c
                                WHERE Applicant__c IN :principalAccIdList
                                AND Dealer__c= :loggedInUser.Account.ParentID];

        for(Dealer_applicant_Relationship__c eachRelationship: dealerPrincipalRelList){
            dealerApplicantRelMap.put(eachRelationship.Applicant__c,eachRelationship.id);
        }

        for(clcommon__Party__c eachPrincipalParty : principalPartyList){
            if(!dealerApplicantRelMap.containsKey(eachPrincipalParty.clcommon__Account__c)){
                Dealer_Applicant_Relationship__c dealerPrincipalRelObj=new Dealer_Applicant_Relationship__c();
                dealerPrincipalRelObj.Applicant__c=eachPrincipalParty.clcommon__Account__c;
                dealerPrincipalRelObj.Applicant_Contact__c=eachPrincipalParty.clcommon__Contact__c;
                dealerPrincipalRelObj.Dealer__c=loggedInUser.Account.ParentId;

                createdDealerAppRelList.add(dealerPrincipalRelObj);
            }
        }

        if(!createdDealerAppRelList.isEmpty()){
            Database.insert(createdDealerAppRelList,true);

            for(Dealer_applicant_Relationship__c eachCreatedRel:createdDealerAppRelList){
                dealerApplicantRelMap.put(eachCreatedRel.Applicant__c,eachCreatedRel.id);
            }

            dealerPrincipalRelList.addAll(createdDealerAppRelList);
        }

        principalBInfoIdList=updatePrincipalAccountRoles(principalAccIdList,coopType);

        List<Contact> principalContactList = [SELECT Id,
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
                                                    clcommon__Marital_Status__c,
                                                    Account.genesis__Business_Information__c,
                                                    Account.genesis__Business_Information__r.Gross_Farm_Income__c
                                            FROM Contact
                                            WHERE Id IN :principalConIdList];

        for(Contact eachContact:principalContactList){
            idVSContactMap.put(eachContact.id,eachContact);
        }

        for(clcommon__party__c eachParty:principalPartyList){
            Contact principalContact=idVSContactMap.get(eachParty.clcommon__Contact__c);

            eachParty.Title__c=principalContact.Title;
            eachParty.Suffix__c	=principalContact.Suffix__c;
            eachParty.Street__c=principalContact.MailingStreet;
            eachParty.City__c=principalContact.MailingCity;
            eachParty.State__c=principalContact.MailingState;
            eachParty.Postal_Code__c=principalContact.MailingPostalCode;
            eachParty.County__c=principalContact.Mailing_County__c;

            eachParty.Home_Number__c=principalContact.HomePhone;
            eachParty.Work_Number__c=principalContact.Phone;
            eachParty.Mobile_Number__c=principalContact.MobilePhone;

            eachParty.Marital_Status__c=principalContact.clcommon__Marital_Status__c;

            eachParty.Gross_Farm_Income__c=principalContact.Account.genesis__Business_Information__r.Gross_Farm_Income__c;

            eachParty.Dealer_Applicant_Relationship__c=dealerApplicantRelMap.get(eachParty.clcommon__Account__c);
        }

        Database.update(principalPartyList,true);
    }

    /**
    * @description updates the roles of all the principals if their role is not grower
    * @author Rakesh Saraf | 01-05-2025 
    * @param principalAccIdList 
    * @param coopType 
    * @return List<String> 
    **/
    private static List<String> updatePrincipalAccountRoles(List<String> principalAccIdList,String coopType){
        List<String> principalBInfoIdList=new List<String>();
        List<Account> principalAccountList = [SELECT Id,
                                                    Coop_Type__c,
                                                    RecordTypeId,
                                                    genesis__Business_Information__c
                                            FROM Account
                                            WHERE Id IN :principalAccIdList];

        for(Account eachPrincipalAcc : principalAccountList){
            //once a account is grower, it's record type will always be grower
            if(eachPrincipalAcc.RecordTypeId != Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId()){
                eachPrincipalAcc.Coop_Type__c = coopType;
                eachPrincipalAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.CO_APPLICATION_RECORD_TYPE).getRecordTypeId();
            }

            principalBInfoIdList.add(eachPrincipalAcc.genesis__Business_Information__c);
        }
        Database.update(principalAccountList,true);
        return principalBInfoIdList;
    }

    /**
    * @description : creates sharing records for the sa admin
    * @author Krishanu Chinya | 03-05-2024 
    * @param applicationObj 
    **/
    public static void createSharingRecordsForSAAdmin(genesis__Applications__c applicationObj){
        List<genesis__Applications__Share> appSharingRecordList = new List<genesis__Applications__Share>();
        List<clcommon__Document_Category__Share> documentSharingRecordList = new List<clcommon__Document_Category__Share>();
        List<Id> saAdminIdList = PortalApplicationOriginationHelper.fetchSAAdmin(applicationObj.Sales_Agent__c); 
        List<User> saAdminUserList = new List<User>();
        if(!saAdminIdList.isEmpty()){
            saAdminUserList = [SELECT Id
                                    FROM User
                                    WHERE AccountId IN :saAdminIdList];   
        }

        List<clcommon__Document_Category__c> documentCategories = [SELECT Id 
                                                                    FROM clcommon__Document_Category__c 
                                                                    WHERE genesis__Application__c = :applicationObj.Id];

        for(User saAdmin : saAdminUserList){
            genesis__Applications__Share applicationSharingRecord = new genesis__Applications__Share();
            applicationSharingRecord.AccessLevel = ConstantValues.ACCESS_LABEL_EDIT;
            applicationSharingRecord.ParentId = applicationObj.Id;
            applicationSharingRecord.UserOrGroupId = saAdmin.Id;
            appSharingRecordList.add(applicationSharingRecord);
        }

        for (clcommon__Document_Category__c documentCategory : documentCategories) {
            for(User saAdmin : saAdminUserList){
                clcommon__Document_Category__Share documentSharingRecord = new clcommon__Document_Category__Share();
                documentSharingRecord.AccessLevel = ConstantValues.ACCESS_LABEL_EDIT;
                documentSharingRecord.ParentId = documentCategory.Id;
                documentSharingRecord.UserOrGroupId = saAdmin.Id;
                documentSharingRecordList.add(documentSharingRecord);
            }
        }
                
        Database.upsert(appSharingRecordList, false);
        Database.upsert(documentSharingRecordList, false);

    }

    /**
    * @description : creates sharing records for the sales agent
    * @author Krishanu Chinya | 03-05-2024 
    * @param applicationObj 
    **/
    public static void createSharingRecordsForSA(genesis__Applications__c applicationObj){
        genesis__Applications__Share applicationSharingRecord = new genesis__Applications__Share();
        List<clcommon__Document_Category__Share> documentSharingRecordList = new List<clcommon__Document_Category__Share>();

        if (applicationObj.Sales_Agent__c != null) {
            List<User> salesAgentUserList = [SELECT Id
                                                FROM User
                                                WHERE AccountId = :applicationObj.Sales_Agent__c
                                                LIMIT 1];

            PortalApplicationOriginationHelper.checkEmptyList(salesAgentUserList, PortalConstants.NO_SALES_AGENT_USER);

            List<clcommon__Document_Category__c> documentCategories = [
                                    SELECT Id 
                                    FROM clcommon__Document_Category__c 
                                    WHERE genesis__Application__c = :applicationObj.Id];

            applicationSharingRecord.AccessLevel = ConstantValues.ACCESS_LABEL_EDIT;
            applicationSharingRecord.ParentId = applicationObj.Id;
            applicationSharingRecord.UserOrGroupId = salesAgentUserList[0].Id;

            for (clcommon__Document_Category__c documentCategory : documentCategories) {

                clcommon__Document_Category__Share documentSharingRecord = new clcommon__Document_Category__Share();
                documentSharingRecord.AccessLevel = ConstantValues.ACCESS_LABEL_EDIT;
                documentSharingRecord.ParentId = documentCategory.Id;
                documentSharingRecord.UserOrGroupId = salesAgentUserList[0].Id;
                documentSharingRecordList.add(documentSharingRecord);
            }
                 
            Database.upsert(applicationSharingRecord, false);
            Database.upsert(documentSharingRecordList, false);
        }
    }

    /**
    * @description : updates the coapplicant contact
    * @author Krishanu Chinya | 03-05-2024 
    * @param coApplicant 
    * @return Contact 
    **/
    public static Contact updateCoApplicantContactDetails(Map<String, Object> coApplicant) {

        Contact coApplicantContact = new Contact();

        coApplicantContact.Id = 
            ((String) coApplicant.get('clcommon__Contact__r.Id')) == null 
                ? null 
                : (String) coApplicant.get('clcommon__Contact__r.Id');

        coApplicantContact.MobilePhone = 
                coApplicant.containsKey('clcommon__Contact__r.MobilePhone') ? 
                (String) coApplicant.get('clcommon__Contact__r.MobilePhone') : PortalConstants.EMPTY_STRING;
        coApplicantContact.Birthdate = 
                coApplicant.containsKey('clcommon__Contact__r.Birthdate') ? 
                Date.valueOf((String) coApplicant.get('clcommon__Contact__r.Birthdate')) : null;
        coApplicantContact.MailingStreet = 
                coApplicant.containsKey('clcommon__Contact__r.MailingStreet') ? 
                (String) coApplicant.get('clcommon__Contact__r.MailingStreet') : PortalConstants.EMPTY_STRING;
        coApplicantContact.Phone = 
                coApplicant.containsKey('clcommon__Contact__r.Phone') ? 
                (String) coApplicant.get('clcommon__Contact__r.Phone') : PortalConstants.EMPTY_STRING;
        coApplicantContact.HomePhone = 
                coApplicant.containsKey('clcommon__Contact__r.HomePhone') ? 
                (String) coApplicant.get('clcommon__Contact__r.HomePhone') : PortalConstants.EMPTY_STRING;
        coApplicantContact.LastName = 
                coApplicant.containsKey('clcommon__Contact__r.LastName') ? 
                (String) coApplicant.get('clcommon__Contact__r.LastName') : PortalConstants.EMPTY_STRING;
        coApplicantContact.MailingCity = 
                coApplicant.containsKey('clcommon__Contact__r.MailingCity') ? 
                (String) coApplicant.get('clcommon__Contact__r.MailingCity') : PortalConstants.EMPTY_STRING;
        coApplicantContact.MailingState = 
                coApplicant.containsKey('clcommon__Contact__r.MailingState') ? 
                (String) coApplicant.get('clcommon__Contact__r.MailingState') : PortalConstants.EMPTY_STRING;
        coApplicantContact.FirstName = 
                coApplicant.containsKey('clcommon__Contact__r.FirstName') ? 
                (String) coApplicant.get('clcommon__Contact__r.FirstName') : PortalConstants.EMPTY_STRING;
        coApplicantContact.Mailing_County__c = 
                coApplicant.containsKey('clcommon__Contact__r.Mailing_County__c') ? 
                (String) coApplicant.get('clcommon__Contact__r.Mailing_County__c') : PortalConstants.EMPTY_STRING;
        coApplicantContact.Email = 
                coApplicant.containsKey('clcommon__Contact__r.Email') ? 
                (String) coApplicant.get('clcommon__Contact__r.Email') : PortalConstants.EMPTY_STRING;
        coApplicantContact.Title = 
                coApplicant.containsKey('clcommon__Contact__r.Title') ? 
                (String) coApplicant.get('clcommon__Contact__r.Title') : PortalConstants.EMPTY_STRING;
        coApplicantContact.Confirm_SSN__c = 
                coApplicant.containsKey('clcommon__Contact__r.Confirm_SSN__c') ? 
                (String) coApplicant.get('clcommon__Contact__r.Confirm_SSN__c') : PortalConstants.EMPTY_STRING;
        coApplicantContact.Confirm_Email__c = 
                coApplicant.containsKey('clcommon__Contact__r.Confirm_Email__c') ? 
                (String) coApplicant.get('clcommon__Contact__r.Confirm_Email__c') : PortalConstants.EMPTY_STRING;
        coApplicantContact.clcommon__Marital_Status__c = 
                coApplicant.containsKey('clcommon__Contact__r.clcommon__Marital_Status__c') ? 
                (String) coApplicant.get('clcommon__Contact__r.clcommon__Marital_Status__c') : PortalConstants.EMPTY_STRING;
        coApplicantContact.genesis__SSN__c = 
                coApplicant.containsKey('clcommon__Contact__r.genesis__SSN__c') ? 
                (String) coApplicant.get('clcommon__Contact__r.genesis__SSN__c') : PortalConstants.EMPTY_STRING;
        coApplicantContact.MailingPostalCode = 
                coApplicant.containsKey('clcommon__Contact__r.MailingPostalCode') ? 
                (String) coApplicant.get('clcommon__Contact__r.MailingPostalCode') : PortalConstants.EMPTY_STRING;
        coApplicantContact.ints__Middle_Name__c = 
                coApplicant.containsKey('clcommon__Contact__r.ints__Middle_Name__c') ? 
                (String) coApplicant.get('clcommon__Contact__r.ints__Middle_Name__c') : PortalConstants.EMPTY_STRING;
        coApplicantContact.Suffix__c = 
                coApplicant.containsKey('clcommon__Contact__r.Suffix__c') ? 
                (String) coApplicant.get('clcommon__Contact__r.Suffix__c') : PortalConstants.EMPTY_STRING;

        if(coApplicantContact.genesis__SSN__c != coApplicantContact.Confirm_SSN__c){
            throw new CustomException(PortalConstants.SSN_CONFIRM_SSN_MISMATCH);
        }

        return coApplicantContact;
    }

    /**
    * @description : updates the coapplicants from applicant info page
    * @author Krishanu Chinya | 02-19-2024 
    * @param coApplicants 
    * @param paramMap 
    **/
    public static void updateCoApplicantDetails(List<Map<String, Object>> coApplicants, Map<string,Object> paramMap){
        String applicationId= (String)paramMap.get(PortalConstants.APPLICATION_ID_KEY);
        String shouldValidate=( String)paramMap.get(PortalConstants.KEY_SHOULD_VALIDATE);
        User loggedInUser=(User) paramMap.get(PortalConstants.LOGGED_IN_USER);

        Map<Id, Id> businessInfoVSAccIdMap = new Map<Id, Id>();
        List<Id> coApplicantContactIdList = new List<Id>();
        List<Id> coApplicantPartyIdList = new List<Id>();
        List<Id> coApplicantAccountIdList = new List<Id>();
        List<Id> coApplicantBusinessIdList = new List<Id>();

        Map<Id,clcommon__Party__c> accountIdvsPartyMap = new Map<Id,clcommon__Party__c>();
        Map<Id,clcommon__Party__c> partyIdvsPartyMap = new Map<Id,clcommon__Party__c>();
        Map<Id,clcommon__Party__c> contactIdvsPartyMap = new Map<Id,clcommon__Party__c>();

        List<Account> accountVSBusinessInfoList = new List<Account>();
        List<Account> coApplicantAccountList = new List<Account>();
        List<Contact> coApplicantContactList = new List<Contact>();
        List<clcommon__Party__c> coApplicantPartyList = new List<clcommon__Party__c>();
        List<genesis__Business_Information__c> coApplicantBusinessList = new List<genesis__Business_Information__c>();

        List<Id> coApplicantConIdToDel=new List<Id>();
        List<Id> coApplicantAccIDToDel=new List<Id>();
        List<Id> coApplicantBInfoIdToDel=new List<Id>();
        
        Boolean shouldDelete=PortalConstants.FALSE_VALUE;

        //taking all the id's in a list
        for(Map<String, Object> coApplicant : coApplicants){
            Id coApplicantAccountId = (Id) coApplicant.get(PortalConstants.COAPPLICANT_ACCOUNT_ID_KEY);
            Id coApplicantContactId = (Id) coApplicant.get(PortalConstants.COAPPLICANT_CONTACT_ID_KEY);
            Id coApplicantPartyId = (Id) coApplicant.get(PortalConstants.ID_KEY);
            Id coApplicantBusinessInfoId = (Id) coApplicant.get(PortalConstants.COAPPLICANT_BUSINESS_INFO_ID_KEY);

            PortalApplicationOriginationHelper.throwErrorIfFalse(!(String.isBlank(coApplicantAccountId) 
                                                                    | String.isBlank(coApplicantContactId) 
                                                                        | String.isBlank(coApplicantPartyId) 
                                                                            | String.isBlank(coApplicantBusinessInfoId)),PortalConstants.SOMETHING_WENT_WRONG);

            coApplicantAccountIdList.add(coApplicantAccountId);
            coApplicantContactIdList.add(coApplicantContactId);
            coApplicantPartyIdList.add(coApplicantPartyId);
            coApplicantBusinessIdList.add(coApplicantBusinessInfoId);

            businessInfoVSAccIdMap.put(coApplicantBusinessInfoId, coApplicantAccountId);

        }

        partyIdvsPartyMap=getPartyVsIdMap(coApplicantPartyIdList,applicationId);

        contactIdvsPartyMap=getContactIdVsPartyMap(coApplicantContactIdList,applicationId);

        accountIdvsPartyMap=getAccountIdVsPartyMap(coApplicantAccountIdList,applicationId);

        accountVSBusinessInfoList=getAccVsBusinessInfoList(coApplicantBusinessIdList);

        Boolean isValidBusinessInfo = PortalSecurityUtil.validateCoApplicantBusinessInfo(accountVSBusinessInfoList, businessInfoVSAccIdMap); 
        PortalApplicationOriginationHelper.throwErrorIfFalse(isValidBusinessInfo,PortalConstants.USER_NOT_AUTHORISED);
        
        for (Map<String, Object> coApplicant : coApplicants){
            Contact coApplicantContact = PortalApplicationCreationHandler.populateCoApplicantContact(coApplicant);
            Account coApplicantAccount = PortalApplicationCreationHandler.populateCoApplicantAccount(coApplicant,coApplicantContact);
            genesis__Business_Information__c coApplicantBusinessInfo = PortalApplicationCreationHandler.populateCoApplicantBusinessInformation(coApplicant);
            clcommon__Party__c coApplicantParty = PortalApplicationCreationHandler.populateCoApplicantParty(coApplicant);

            updateBorrowerPartyDetails(new Map<String,Object>{PortalConstants.ACCOUNT_OBJ_KEY=>coApplicantAccount,
                                                              PortalConstants.CONTACT_OBJ_KEY=>coApplicantContact,
                                                              PortalConstants.BUSINESS_INFO_OBJ_KEY=>coApplicantBusinessInfo,
                                                              PortalConstants.BORROWER_PARTY_KEY=>coApplicantParty});

            
            PortalValidationUtil.isValidCoApplicationCreation(new Map<String,Object>{PortalConstants.CONTACT_OBJ_KEY=>coApplicantContact,
                                                                                     PortalConstants.ACCOUNT_OBJ_KEY=>coApplicantAccount,
                                                                                     PortalConstants.BUSINESS_INFO_OBJ_KEY=>coApplicantBusinessInfo,
                                                                                     PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                     PortalConstants.BORROWER_PARTY_KEY=>coApplicantParty});

            //if SSN of coapplicant is changed
            Id oldCoApplicantContactId = coApplicantContact.Id;
            Id oldCoApplicantAccountId = coApplicantAccount.Id;
            Id oldCoApplicanBInfoId = coApplicantBusinessInfo.Id;
            PortalValidationUtil.validateNewCoApplicant(coApplicantContact, loggedInUser.Account.Parent.Coop_Type__c);

            PortalValidationUtil.verifyUserForApplicant(oldCoApplicantContactId,coApplicantContact.id);
            
            //if new ssn exists in the DB
            if(oldCoApplicantContactId != coApplicantContact.Id){
                updateCoAppDetailsForExistingIndividual(new Map<String,Object>{ PortalConstants.CONTACT_OBJ_KEY=>coApplicantContact,
                                                                                PortalConstants.ACCOUNT_OBJ_KEY=>coApplicantAccount,
                                                                                PortalConstants.BUSINESS_INFO_OBJ_KEY=>coApplicantBusinessInfo,
                                                                                PortalConstants.KEY_PARTY=>coApplicantParty},applicationId);

                accountIdvsPartyMap.put(coApplicantAccount.Id, coApplicantParty);
                contactIdvsPartyMap.put(coApplicantContact.Id, coApplicantParty);

                //deleting old account contact
                List<clcommon__Party__c> checkPartyList = [SELECT Id 
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__c !=: applicationId
                                                            AND clcommon__Contact__c =: oldCoApplicantContactId];
                if(checkPartyList.isEmpty()){

                    coApplicantConIdToDel.add(oldCoApplicantContactId);
                    coApplicantAccIDToDel.add(oldCoApplicantAccountId);
                    coApplicantBInfoIdToDel.add(oldCoApplicanBInfoId);

                    shouldDelete=PortalConstants.TRUE_VALUE;
                    
                    accountIdvsPartyMap.remove(oldCoApplicantAccountId);
                    contactIdvsPartyMap.remove(oldCoApplicantContactId);
                }
            }
            Boolean isValidAccount = PortalSecurityUtil.validateCoApplicantAccount(coApplicantAccount.Id, accountIdvsPartyMap);
            Boolean isValidContact = PortalSecurityUtil.validateCoApplicantContact(coApplicantContact.Id, contactIdvsPartyMap); 
            Boolean isValidParty = PortalSecurityUtil.validateCoApplicantParty(coApplicantParty.Id, partyIdvsPartyMap); 

            PortalApplicationOriginationHelper.throwErrorIfTrue(!isValidAccount | !isValidContact | !isValidParty, PortalConstants.USER_NOT_AUTHORISED);
            
            coApplicantAccountList.add(coApplicantAccount);
            coApplicantContactList.add(coApplicantContact);
            coApplicantPartyList.add(coApplicantParty);
            coApplicantBusinessList.add(coApplicantBusinessInfo);
        }

        checkKycVerifiedForCoApplicants(coApplicantAccountList,coApplicantContactList,contactIdvsPartyMap);

        deleteRedundantPartyDetails(new Map<String,List<Object>>{
                                                                PortalConstants.CONTACT_OBJ_KEY=>coApplicantConIdToDel,
                                                                PortalConstants.ACCOUNT_OBJ_KEY=>coApplicantAccIDToDel,
                                                                PortalConstants.BUSINESS_INFO_OBJ_KEY=>coApplicantBInfoIdToDel,
                                                                PortalConstants.KEY_PARTY=>coApplicantPartyList
                                                            },loggedInUser,shouldDelete);

        Database.upsert(coApplicantAccountList, true);
        Database.upsert(coApplicantContactList, true);
        Database.upsert(coApplicantPartyList, true);
        Database.upsert(coApplicantBusinessList, true);

    }

    /**
    * @description the purpose of this method is to delete account, contact, business info and dr record of all the new co applicants whose ssn have been changed
    * @author Rakesh Saraf | 01-23-2025 
    * @param paramMap
    * @param loggedInUser 
    * @param shouldDelete 
    **/
    private static void deleteRedundantPartyDetails(Map<String,List<Object>> paramMap,User loggedInUser ,Boolean shouldDelete){

        if(shouldDelete==PortalConstants.FALSE_VALUE){
            return;
        }

        List<Id> coApplicantConIdToDel=(List<Id>) paramMap.get(PortalConstants.CONTACT_OBJ_KEY); 
        List<Id> coApplicantAccIDToDel=(List<Id>) paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        List<Id> coApplicantBInfoIdToDel =(List<Id>) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);

        List<Contact> oldCoApplicantContact = [SELECT Id,AccountId FROM Contact WHERE Id IN :coApplicantConIdToDel];
        List<Account> oldCoApplicantAccount = [SELECT Id,genesis__Business_Information__c FROM Account WHERE Id IN :coApplicantAccIDToDel];
        List<genesis__Business_Information__c> oldCoApplicantBusiness = [SELECT Id FROM genesis__Business_Information__c WHERE Id IN :coApplicantBInfoIdToDel];

        List<Dealer_Applicant_Relationship__c> dealerCoAppRelList=[SELECT Id FROM Dealer_Applicant_Relationship__c WHERE Dealer__c=:loggedInUser.Account.ParentID AND Applicant__c IN :coApplicantAccIDToDel];


        Database.delete(oldCoApplicantContact, true);
        Database.delete(oldCoApplicantAccount, true);
        Database.delete(oldCoApplicantBusiness, true);
        Database.delete(dealerCoAppRelList, true);


    }

    /**
    * @description the purpose of this method is to create a dealer applicant relationship for all the coapplicants that are new and their ssn have been changed
    * @author Rakesh Saraf | 01-23-2025 
    * @param coApplicantPartyList 
    * @param loggedInUser 
    **/
    private static void updateDealerApplicantRelDetails(List<clcommon__Party__c> coApplicantPartyList,User loggedInUser){

        Map<Id,Integer> partyCountMap=new Map<Id,Integer>();
        Map<Id,clcommon__Party__c> partyVsAccountMap=new Map<Id,clcommon__Party__c>();
        List<Id> coAppPartyAccIdList=new List<Id>();
        List<Dealer_Applicant_Relationship__c> dealerAppRelListToDel=new List<Dealer_Applicant_Relationship__c>();
        List<Dealer_Applicant_Relationship__c> newCreatedDealerAppRel=new List<Dealer_Applicant_Relationship__c>();
        List<Id> accountIdToCreateDRList=new List<Id>();

        for(clcommon__Party__c eachParty:coApplicantPartyList){
            coAppPartyAccIdList.add(eachParty.clcommon__Account__c);
            partyVsAccountMap.put(eachParty.clcommon__Account__c,eachParty);
        }
        List<Dealer_Applicant_Relationship__c> dealerCoAppRelList=[SELECT ID,
                                                                          Applicant__c
                                                                    FROM Dealer_Applicant_Relationship__c
                                                                    WHERE Dealer__c=:loggedInUser.Account.ParentID
                                                                    AND Applicant__c In :coAppPartyAccIdList];

        List<clcommon__Party__c> partyForDrCheckList=[SELECT ID,
                                                             Dealer_Applicant_Relationship__c 
                                                      FROM clcommon__Party__c 
                                                      WHERE Dealer_Applicant_Relationship__c IN :dealerCoAppRelList];

        for (clcommon__Party__c eachParty : partyForDrCheckList) {
            Id partyDRId = eachParty.Dealer_Applicant_Relationship__c; 
            if (partyCountMap.containsKey(partyDRId)) {
                partyCountMap.put(partyDRId, partyCountMap.get(partyDRId) + 1);
            } else {
                partyCountMap.put(partyDRId, 1);
            }
        }

        for(Dealer_Applicant_Relationship__c eachDealerRel: dealerCoAppRelList){
            if(partyCountMap.containsKey(eachDealerRel.id) && partyCountMap.get(eachDealerRel.id)==1){
                dealerAppRelListToDel.add(eachDealerRel);
                accountIdToCreateDRList.add(eachDealerRel.Applicant__c);
            }
        }
        if(!dealerAppRelListToDel.isEmpty()){
            Database.delete(dealerAppRelListToDel,true);
        }
        for(Id eachAccountId:accountIdToCreateDRList){
            clcommon__Party__c partyObj=partyVsAccountMap.get(eachAccountId);
            Dealer_applicant_Relationship__c dealerCoAppRelObj=new Dealer_applicant_Relationship__c();
            dealerCoAppRelObj.Dealer__c=loggedInUser.Account.ParentId;
            dealerCoAppRelObj.Applicant__c=partyObj.clcommon__Account__c;
            dealerCoAppRelObj.Applicant_Contact__c=partyObj.clcommon__Contact__c;
            newCreatedDealerAppRel.add(dealerCoAppRelObj);
        }

        Database.insert(newCreatedDealerAppRel,true);
        for(Dealer_applicant_Relationship__c dealerCoAppRelObj:newCreatedDealerAppRel){
            clcommon__Party__c partyObj=partyVsAccountMap.get(dealerCoAppRelObj.Applicant__c);
            partyObj.Dealer_Applicant_Relationship__c=dealerCoAppRelObj.id;
        }
    }
    /**
    * @description the purpose of this method is to upate the details of the co applicant when an individual with the same ssn is found in the db
    * @author Rakesh Saraf | 11-26-2024 
    * @param paramMap 
    * @param applicationId 
    **/
    private static void updateCoAppDetailsForExistingIndividual(Map<String,Object> paramMap,Id applicationId){
        Contact coApplicantContact=(Contact) paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        Account coApplicantAccount=(Account) paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        genesis__Business_Information__c coApplicantBusinessInfo=(genesis__Business_Information__c) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        clcommon__Party__c coApplicantParty=(clcommon__Party__c) paramMap.get(PortalConstants.KEY_PARTY);

        PortalValidationUtil.checkForDuplicateCoapplicant(coApplicantContact.Id, applicationId);
        coApplicantAccount.Id = coApplicantContact.AccountId;
        Account existingAccount = [SELECT Id,
                                        genesis__Business_Information__c
                                        FROM Account
                                        WHERE Id =: coApplicantContact.AccountId];
        coApplicantBusinessInfo.Id = existingAccount.genesis__Business_Information__c;
        coApplicantAccount.genesis__Business_Information__c = coApplicantBusinessInfo.Id;
        coApplicantParty.clcommon__Contact__c = coApplicantContact.Id;
        coApplicantParty.clcommon__Account__c = coApplicantContact.AccountId;
    }

    /**
    * @description get the party vs the party id map
    * @author Rakesh Saraf | 11-26-2024 
    * @param coApplicantPartyIdList 
    * @param applicationId 
    * @return Map<Id, clcommon__Party__c> 
    **/
    private static Map<Id,clcommon__Party__c> getPartyVsIdMap(List<Id> coApplicantPartyIdList,Id applicationId){
        Map<Id,clcommon__Party__c> partyIdvsPartyMap=new Map<Id,clcommon__Party__c>();
        if(!coApplicantPartyIdList.isEmpty()){
            List<clcommon__Party__c> appPartyByPartyIdList = [SELECT Id
                                                                FROM clcommon__Party__c
                                                                WHERE Id IN :coApplicantPartyIdList
                                                                AND genesis__Application__c = :applicationId
                                                                AND clcommon__Type__r.Name =: PortalConstants.PRINCIPAL_PARTY_NAME];

            for(clcommon__Party__c coApplicantParty : appPartyByPartyIdList){
                partyIdvsPartyMap.put(coApplicantParty.Id, coApplicantParty);
            }
        }
        return partyIdvsPartyMap;
    }

    /**
    * @description function to get the party vs contact map
    * @author Rakesh Saraf | 11-26-2024 
    * @param coApplicantContactIdList 
    * @param applicationId 
    * @return Map<Id, clcommon__Party__c> 
    **/
    private static Map<Id,clcommon__Party__c> getContactIdVsPartyMap(List<Id> coApplicantContactIdList,Id applicationId){
        Map<Id,clcommon__Party__c> contactIdvsPartyMap=new Map<Id,clcommon__Party__c>();
        if(!coApplicantContactIdList.isEmpty()){
            List<clcommon__Party__c> appPartyByContactList = [SELECT Id,
                                                                    clcommon__Contact__r.Id
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__c = :applicationId
                                                                AND clcommon__Contact__c IN :coApplicantContactIdList
                                                                AND clcommon__Type__r.Name =: PortalConstants.PRINCIPAL_PARTY_NAME];

            for(clcommon__Party__c eachPartyByContact : appPartyByContactList){
                contactIdvsPartyMap.put(eachPartyByContact.clcommon__Contact__r.Id, eachPartyByContact);
            }
        }
        return contactIdvsPartyMap;
    }

    /**
    * @description function to get the party by account id map
    * @author Rakesh Saraf | 11-26-2024 
    * @param coApplicantAccountIdList 
    * @param applicationId 
    * @return Map<Id, clcommon__Party__c> 
    **/
    private static Map<Id,clcommon__Party__c> getAccountIdVsPartyMap(List<Id> coApplicantAccountIdList,Id applicationId){
        Map<Id,clcommon__Party__c> accountIdvsPartyMap=new Map<Id,clcommon__Party__c>();
        if(!coApplicantAccountIdList.isEmpty()){
            List<clcommon__Party__c> appPartyByAccountList = [SELECT Id,
                                                                clcommon__Account__r.Id
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__c = :applicationId
                                                                AND clcommon__Account__c IN :coApplicantAccountIdList];

            for(clcommon__Party__c eachPartyByAccount : appPartyByAccountList){
                accountIdvsPartyMap.put(eachPartyByAccount.clcommon__Account__r.Id, eachPartyByAccount);
            }
        }
        return accountIdvsPartyMap;
    }

    /**
    * @description function to get the account vs the business info map
    * @author Rakesh Saraf | 11-26-2024 
    * @param coApplicantBusinessIdList 
    * @return List<Account> 
    **/
    private static List<Account> getAccVsBusinessInfoList(List<Id> coApplicantBusinessIdList){
        List<Account> accountVSBusinessInfoList=new List<Account>();
        if(!coApplicantBusinessIdList.isEmpty()){
            accountVSBusinessInfoList = [SELECT Id,
                                                genesis__Business_Information__r.Id
                                        FROM Account 
                                        WHERE genesis__Business_Information__c IN :coApplicantBusinessIdList ];
        }
        return accountVSBusinessInfoList;
    }

    /**
    * @description : deletes an account contact when ssn is changed from applicant info page
    * @author Krishanu Chinya | 02-28-2024 
    * @param currentContact 
    * @param applicationId 
    * @param loggedInUser 
    **/
    public static void deleteRedundantAccountAndContact(Contact currentContact, Id applicationId,User loggedInUser){
        List<Account> currentAccount = [SELECT Id 
                                    FROM Account 
                                    WHERE Id =: currentContact.AccountId];

        List<clcommon__Party__c> partyList = [SELECT Id 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Contact__c =: currentContact.Id
                                                AND genesis__Application__c !=: applicationId];

        List<User> userList = [SELECT Id, 
                                    IsActive 
                                FROM User 
                                WHERE accountId =: currentAccount[0].Id];

        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList=[SELECT ID
                                                                        FROM Dealer_Applicant_Relationship__c
                                                                        WHERE Dealer__c= :loggedInUser.Account.ParentId
                                                                        AND Applicant__c =: currentContact.AccountId];

        List<clcommon__Party__c> partyWithSameDealerAppRel=[SELECT ID
                                                            FROM clcommon__Party__c
                                                            WHERE Dealer_Applicant_Relationship__c=: dealerApplicantRelList[0].id];
        PortalApplicationOriginationHelper.deactivateUser(currentAccount[0].Id);
        if(partyList.isEmpty() && userList.isEmpty()){
            List<genesis__Business_Information__c> currentBusinessInfo=[SELECT Id 
                                                                        FROM genesis__Business_Information__c 
                                                                        WHERE Id =: currentContact.Account.genesis__Business_Information__c];
            Database.delete(currentBusinessInfo, true);

            Database.delete(currentContact, true);
            Database.delete(currentAccount, true);
        }
        if(partyWithSameDealerAppRel.size()==1){
            Database.delete(dealerApplicantRelList, true);
        }

        
    }

    /**
    * @description : this method validates the business info,
    *                   updates total assets and liabilities of the borrower party
    * @author Krishanu Chinya | 02-05-2024 
    * @param paramMap
    **/
    public static void processBusinessInfoOfBorrower(Map<String,Object> paramMap){

        genesis__Business_Information__c businessInfoObj=(genesis__Business_Information__c)paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY); 
        Id borrowerAccountId=(Id) paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY); 
        clcommon__party__c borrowerPartyObj = (clcommon__party__c) paramMap.get(PortalConstants.BORROWER_PARTY_NAME);

        Boolean isValidBusiness = PortalSecurityUtil.validateUserBusinessInformation(businessInfoObj.Id, borrowerAccountId); 
        if (!isValidBusiness) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }
        Database.update(businessInfoObj, true);

        
        borrowerPartyObj.Total_Assets__c = businessInfoObj.genesis__Total_Assets__c;
        borrowerPartyObj.Total_Liabilities__c = businessInfoObj.genesis__Total_Liabilities__c;
        Database.Update(borrowerPartyObj, true);
    }

    /**
     * @description Creates required tasks for the application if they aren't created
     * @param applicationId 
     */
    public static void createTasks(String applicationId){
        List<Task> masterTaskList = new List<Task>();
        List<Task> applicationTasks = [SELECT Id 
                                        FROM Task 
                                        WHERE genesis__Application__c = :applicationId];
        if(applicationTasks.size() == 0 ){
            String departmentId = [SELECT Id FROM genesis__Department__c WHERE Name  = :PortalConstants.KEY_CREDIT].Id;
            List<genesis__Task_Setup__c> taskSetupList = [SELECT Id, 
                                                            genesis__Object_Type__c, 
                                                            genesis__Priority__c, 
                                                            genesis__Task_Name__c, 
                                                            genesis__Type__c 
                                                        FROM genesis__Task_Setup__c 
                                                        WHERE (genesis__Task_name__c != :PortalConstants.KEY_TASK_TESTING_ONE AND 
                                                        genesis__Task_name__c != :PortalConstants.KEY_TASK_TESTING_TWO AND 
                                                        genesis__Task_name__c != :PortalConstants.KEY_TASK_TESTING_THREE)];
            integer count = 1;
            for (genesis__Task_Setup__c eachTaskSetup : taskSetupList){
                Task eachTask = new Task();
                //DEPARTMENT - CREDIT
                eachTask.genesis__Department__c = departmentId;//Dev - a7R74000000GhxGEAS, Prod - a7R5f000000coIfEAI
                //APPLICATION
                eachTask.WhatId = applicationId;
                eachTask.genesis__Application__c = applicationId;

                //SUBJECT - Task Name
                eachTask.Subject = eachTaskSetup.genesis__Task_Name__c;
                eachtask.Description = eachTaskSetup.genesis__Task_Name__c;
                eachTask.genesis__Task_Setup__c = eachTaskSetup.Id;

                eachTask.genesis__Completion_Mandatory__c = PortalConstants.FALSE_VALUE;
                eachTask.genesis__Is_Archived__c = PortalConstants.FALSE_VALUE;
                eachTask.genesis__Is_Parallel__c = PortalConstants.FALSE_VALUE;

                eachTask.genesis__Task_Order__c = count;
                count++;
                masterTaskList.add(eachTask);
            }
            Database.insert(masterTaskList,true);
        }
    }

    /**
    * @description : updates the details of the new portaluser
    * @author Krishanu Chinya | 04-07-2024 
    * @param newPortalUser 
    * @param portalUserParamMap 
    * @return New_Portal_User__e 
    **/
    public static New_Portal_User__e setPortalUserDetails(New_Portal_User__e newPortalUser, Map<String,Object> portalUserParamMap){
        newPortalUser.Email__c = (String)portalUserParamMap.get(PortalConstants.KEY_PORTAL_USER_EMAIL);
        newPortalUser.First_Name__c = (String)portalUserParamMap.get(PortalConstants.KEY_PORTAL_USER_FIRST_NAME);
        newPortalUser.Last_Name__c = (String)portalUserParamMap.get(PortalConstants.KEY_PORTAL_USER_LAST_NAME); 
        newPortalUser.Account_Id__c = (String)portalUserParamMap.get(PortalConstants.KEY_PORTAL_USER_ACC_ID);
        newPortalUser.Contact_Id__c = (String)portalUserParamMap.get(PortalConstants.KEY_PORTAL_USER_CON_ID);
        newPortalUser.CIF_Number__c = (String)portalUserParamMap.get(PortalConstants.KEY_PORTAL_USER_CIF_NUM);

        return newPortalUser;
    }

    /**
    * @description - This method validates the fields for EDE integration
    * @author Sk Minsar | 04-16-2024 
    * @param accountObj 
    * @param businessInfoObj 
    * @param legalEntity 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> validateNewEDEFieldsMap (Account accountObj, genesis__Business_Information__c businessInfoObj, String legalEntity){

        Map<String, Object> validateNewEDEFieldsMap = new Map<String, Object>();
        validateNewEDEFieldsMap.put(PortalConstants.YEAR_BEGAN_FARMING_KEY, null);
        if(legalEntity == PortalConstants.SOLE_PROP_ENTITY){
            accountObj.Year_Began_Farming__c = accountObj.Year_Began_Farming__c == null ? null : accountObj.Year_Began_Farming__c;
            validateNewEDEFieldsMap.put(PortalConstants.YEAR_BEGAN_FARMING_KEY, accountObj.Year_Began_Farming__c);
        }

        businessInfoObj.Gross_Farm_Income__c = businessInfoObj.Gross_Farm_Income__c == null ? null : businessInfoObj.Gross_Farm_Income__c;
            validateNewEDEFieldsMap.put(PortalConstants.GROSS_FARM_INCOME_KEY, businessInfoObj.Gross_Farm_Income__c);

        return validateNewEDEFieldsMap;
    }

    
   
    /**
    * @description : Verify Accounts for Past Due and Non Accrual
    * @author  Pritam Roy | 06-20-2024 
    * @param userApp 
    **/
    public static void verifyExistingAccounts(genesis__Applications__c userApp){
        //Map<String,Boolean> trackStatusMap = new Map<String,Boolean>();
        Boolean trackNonAccrual = false;
        Boolean trackHasPastDue = false;
        List<clcommon__Party__c> verifyPartyList=[SELECT Id,  
                                                         Dealer_Applicant_Relationship__r.Has_Past_Due__c,
                                                         Dealer_Applicant_Relationship__r.Is_Non_Accrual__c,
                                                         Dealer_Applicant_Relationship__c,
                                                         clcommon__Type__r.Name
                                                    FROM clcommon__Party__c
                                                    WHERE genesis__Application__c =: userApp.id
                                                    AND clcommon__Type__r.Name IN (
                                                        :PortalConstants.PRINCIPAL_PARTY_NAME,
                                                        :PortalConstants.BORROWER_PARTY_NAME)
                                                    ];
        for(clcommon__Party__c existingParty: verifyPartyList){
            if(existingParty.Dealer_Applicant_Relationship__r.Has_Past_Due__c == true){
                trackHasPastDue = true;
            }
            if(existingParty.Dealer_Applicant_Relationship__r.Is_Non_Accrual__c == true){
                trackNonAccrual = true;
            }
        }
        if(trackNonAccrual){
            throw new CustomException(PortalConstants.NON_ACCRUAL_APPLICATIONS_EXCEPTION);
        }  
        if(trackHasPastDue){
            throw new CustomException(PortalConstants.PAST_DUE_APPLICATIONS_EXCEPTION);
        }
              
    }

    /**
    * @description : Verify Accounts for Past Due and Non Accrual
    * @author  Pritam Roy | 06-20-2024 
    * @param userApp 
    * @param shouldValidate
    **/
    public static void verifyApplicants(genesis__Applications__c userApp,String shouldValidate){
        //Map<String,Boolean> trackStatusMap = new Map<String,Boolean>();
        Boolean trackNonAccrual = false;
        Boolean trackHasPastDue = false;
        if(shouldValidate == PortalConstants.SAVE_AND_EXIT){
            return;
        }
        List<clcommon__Party__c> verifyPartyList = [SELECT Id,  
                                                            Dealer_Applicant_Relationship__r.Has_Past_Due__c,
                                                            Dealer_Applicant_Relationship__r.Is_Non_Accrual__c,
                                                            clcommon__Type__r.Name
                                                    FROM clcommon__Party__c
                                                    WHERE genesis__Application__c =: userApp.id
                                                    AND clcommon__Type__r.Name IN (
                                                        :PortalConstants.PRINCIPAL_PARTY_NAME,
                                                        :PortalConstants.BORROWER_PARTY_NAME)
                                                    ];
        for(clcommon__Party__c existingParty: verifyPartyList){
            if(existingParty.Dealer_Applicant_Relationship__r.Has_Past_Due__c == true){
                trackHasPastDue = true;
            }
            if(existingParty.Dealer_Applicant_Relationship__r.Is_Non_Accrual__c == true){
                trackNonAccrual = true;
            }
        }
        if(trackNonAccrual){
            throw new CustomException(PortalConstants.NON_ACCRUAL_APPLICANT_EXCEPTION);
        }  
        if(trackHasPastDue){
            throw new CustomException(PortalConstants.PAST_DUE_APPLICANT_EXCEPTION);
        }
              
    }
   
    /**
    * @description this method creates a new dealer applicant relationship for application initiation
    * @author Rakesh Saraf | 11-25-2024 
    * @param paramMap 
    * @return Dealer_Applicant_Relationship__c 
    **/
    public static Dealer_Applicant_Relationship__c createDealerApplicantRelationship(Map<String,Object> paramMap){

        User loggedinUser=(User) paramMap.get(PortalConstants.LOGGED_IN_USER);
        Contact contactObj=(Contact) paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        Account accountObj=(Account) paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);

        Dealer_Applicant_Relationship__c dealerApplicantRelObj=new Dealer_Applicant_Relationship__c();
        dealerApplicantRelObj.Dealer__c=loggedinUser.Account.ParentId;

        dealerApplicantRelObj.Applicant__c=accountObj.id;
        dealerApplicantRelObj.Applicant_Contact__c=contactObj.id;
        
        return dealerApplicantRelObj;
    }
    
    /**
    * @description creates a party of the primary applicant in the application
    * @author Rakesh Saraf | 11-25-2024 
    * @param paramMap
    **/
    public static void createPrimaryApplicantParty(Map<String,Object> paramMap){
        User loggedInUser=(User)paramMap.get(PortalConstants.LOGGED_IN_USER);
        genesis__Applications__c applicationObj=(genesis__Applications__c)paramMap.get(PortalConstants.APPLICATION_OBJ_KEY);
        Contact priApplicantContact=(Contact)paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        String dealerCoopType=(String)paramMap.get(PortalConstants.DEALER_COOP_TYPE_KEY);

        Dealer_Applicant_Relationship__c dealerApplicantRelObj= new Dealer_Applicant_Relationship__c();

        List<Contact> priApplicantContactList = new List<Contact>();
        //creating primary applicant party
        clcommon__Party__c priApplicantParty = new clcommon__Party__c();
        priApplicantParty.genesis__Application__c = applicationObj.Id;
        priApplicantParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.PRINCIPAL_PARTY_NAME);
        priApplicantParty.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;


        if(!String.isBlank(priApplicantContact.genesis__SSN__c)){
            priApplicantContactList =[SELECT Id,
                                            AccountId,
                                            Account.clcommon__Legal_Entity_Type__c,
                                            genesis__SSN__c,
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
                                            clcommon__Marital_Status__c,
                                            Email,
                                            Confirm_Email__c
                                    FROM Contact
                                    WHERE genesis__SSN__c = :priApplicantContact.genesis__SSN__c
                                    AND (Account.clcommon__Legal_Entity_Type__r.Name = :PortalConstants.SOLE_PROP_ENTITY
                                    OR Account.clcommon__Legal_Entity_Type__c = null)];
        }

        if(priApplicantContactList.isEmpty()){
            insertPrincipalPartyDetails(new Map<String,Object>{
                                                            PortalConstants.PRIMARY_APPLICANT_CONTACT_KEY=>priApplicantContact,
                                                            PortalConstants.APPLICATION_KEY=>applicationObj,
                                                            PortalConstants.DEALER_COOP_TYPE_KEY=>dealerCoopType,
                                                            PortalConstants.PRINCIPAL_PARTY_NAME=>priApplicantParty,
                                                            PortalConstants.LOGGED_IN_USER=>loggedInUser
                                                        });

        }
        else{
            //update the existing contact
            priApplicantContactList[0].MobilePhone=PortalApplicationOriginationHelper.setOriginalOrNewValue(priApplicantContact.MobilePhone,priApplicantContactList[0].MobilePhone);
            priApplicantContactList[0].HomePhone=PortalApplicationOriginationHelper.setOriginalOrNewValue(priApplicantContact.HomePhone,priApplicantContactList[0].HomePhone);
            priApplicantContactList[0].Phone=PortalApplicationOriginationHelper.setOriginalOrNewValue(priApplicantContact.Phone,priApplicantContactList[0].Phone);
            

            //fetch the account 
            List<Account> priApplicantAccList = [SELECT Id, 
                                                        Work_Number__c, 
                                                        Home_Number__c, 
                                                        Phone, 
                                                        Name,
                                                        ParentId,
                                                        Coop_Type__c,
                                                        genesis__Business_Information__c,
                                                        Kyc_Verified__c,
                                                        clcommon__Email__c,
                                                        Confirm_Email__c,
                                                        RecordTypeId
                                                FROM Account
                                                WHERE Id =: priApplicantContactList[0].AccountId];

            List<genesis__Business_Information__c> principalBusinessInfoList=[SELECT ID,Gross_Farm_Income__c FROM genesis__Business_Information__c WHERE Id=:priApplicantAccList[0].genesis__Business_Information__c];

            //update the account details

            if(!priApplicantAccList[0].Kyc_Verified__c){
                priApplicantContactList[0].FirstName = priApplicantContact.FirstName;
                priApplicantContactList[0].Lastname = priApplicantContact.LastName;
                priApplicantContactList[0].ints__Middle_Name__c = priApplicantContact.ints__Middle_Name__c;
                priApplicantContactList[0].Email = !String.isBlank(priApplicantContact.Email)?priApplicantContact.Email:priApplicantContactList[0].Email;
                priApplicantContactList[0].Confirm_Email__c = !String.isBlank(priApplicantContact.Confirm_Email__c)?priApplicantContact.Confirm_Email__c:priApplicantContactList[0].Confirm_Email__c;
                priApplicantAccList[0].clcommon__Email__c = priApplicantContactList[0].Email;
                priApplicantAccList[0].Confirm_Email__c = priApplicantContactList[0].Confirm_Email__c;
                priApplicantAccList[0].Name = priApplicantContact.LastName + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + priApplicantContact.FirstName;
                
            }
            priApplicantAccList[0].ParentId = applicationObj.Dealer_Name__c;
            priApplicantAccList[0].Coop_Type__c = dealerCoopType;
            PortalApplicationOriginationHelper.setRecordTypeForPrincipal(priApplicantAccList[0]);

            priApplicantAccList[0].Home_Number__c= priApplicantContactList[0].HomePhone;
            priApplicantAccList[0].Work_Number__c=priApplicantContactList[0].Phone;
            priApplicantAccList[0].Phone=priApplicantContactList[0].MobilePhone;

            Database.Update(priApplicantContactList[0], true);
            Database.Update(priApplicantAccList[0], true);

            List<Dealer_Applicant_Relationship__c> dealerApplicantRelList=[ SELECT ID
                                                                            FROM Dealer_Applicant_Relationship__c
                                                                            WHERE Dealer__c= :loggedInUser.Account.ParentId
                                                                            AND Applicant__c= :priApplicantAccList[0].id
                                                                            LIMIT 1];

            if(dealerApplicantRelList.isEmpty()){
                dealerApplicantRelObj=createDealerApplicantRelationship(new Map<String,Object>{
                                                                                            PortalConstants.LOGGED_IN_USER=>loggedInUser,
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>priApplicantContactList[0],
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>priApplicantAccList[0]
                                                                                        });
                
                dealerApplicantRelList.add(dealerApplicantRelObj);
            }
            
            Database.upsert(dealerApplicantRelList,true);

            priApplicantParty.clcommon__Account__c = priApplicantContactList[0].AccountId;
            priApplicantParty.clcommon__Contact__c = priApplicantContactList[0].Id;

            priApplicantParty.Title__c=priApplicantContactList[0].Title;
            priApplicantParty.Suffix__c	=priApplicantContactList[0].Suffix__c;
            priApplicantParty.Street__c=priApplicantContactList[0].MailingStreet;
            priApplicantParty.City__c=priApplicantContactList[0].MailingCity;
            priApplicantParty.State__c=priApplicantContactList[0].MailingState;
            priApplicantParty.Postal_Code__c=priApplicantContactList[0].MailingPostalCode;
            priApplicantParty.County__c=priApplicantContactList[0].Mailing_County__c;

            priApplicantParty.Home_Number__c=priApplicantContactList[0].HomePhone;
            priApplicantParty.Work_Number__c=priApplicantContactList[0].Phone;
            priApplicantParty.Mobile_Number__c=priApplicantContactList[0].MobilePhone;

            priApplicantParty.Gross_Farm_Income__c=principalBusinessInfoList[0].Gross_Farm_Income__c;

            priApplicantParty.Marital_Status__c=priApplicantContactList[0].clcommon__Marital_Status__c;
            
            priApplicantParty.Dealer_Applicant_Relationship__c=dealerApplicantRelList[0].id;

        }

        Database.Insert(priApplicantParty, true);
    }

    /**
    * @description inserts the details of the principal in the account, contact, business info and the party
    * @author Rakesh Saraf | 12-02-2024 
    * @param paramMap 
    **/
    private static void insertPrincipalPartyDetails(Map<String,Object> paramMap){
        genesis__Applications__c applicationObj=(genesis__Applications__c)paramMap.get(PortalConstants.APPLICATION_KEY);
        Contact priApplicantContact =(Contact)paramMap.get(PortalConstants.PRIMARY_APPLICANT_CONTACT_KEY);
        String dealerCoopType=(String)paramMap.get(PortalConstants.DEALER_COOP_TYPE_KEY);
        clcommon__Party__c priApplicantParty=(clcommon__Party__c)paramMap.get(PortalConstants.PRINCIPAL_PARTY_NAME);
        User loggedInUser=(User)paramMap.get(PortalConstants.LOGGED_IN_USER);
        
        Dealer_Applicant_Relationship__c dealerApplicantRelObj=new Dealer_Applicant_Relationship__c();

        //creating primary applicant business info
        genesis__Business_Information__c priApplicantBusinessInfo = new genesis__Business_Information__c();
        Database.Insert(priApplicantBusinessInfo, true);

        //creating primary applicant account
        Account priApplicantAcc = new Account();
        priApplicantAcc.Name = priApplicantContact.LastName + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + priApplicantContact.FirstName;
        priApplicantAcc.genesis__Business_Information__c = priApplicantBusinessInfo.Id;
        priApplicantAcc.clcommon__Legal_Entity_Type__c = mapOfLegalEntity.get(PortalConstants.SOLE_PROP_ENTITY);
        priApplicantAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.CO_APPLICATION_RECORD_TYPE).getRecordTypeId();
        priApplicantAcc.clcommon__Email__c = priApplicantContact.Email; 
        priApplicantAcc.Confirm_Email__c = priApplicantContact.Confirm_Email__c; 
        priApplicantAcc.Coop_Type__c = dealerCoopType; 
        priApplicantAcc.ParentId = applicationObj.Dealer_Name__c;
        priApplicantAcc.OwnerId = PortalSecurityUtil.getSiteAdmin();

        priApplicantAcc.Phone = priApplicantContact.MobilePhone;
        priApplicantAcc.Home_Number__c = priApplicantContact.HomePhone;
        priApplicantAcc.Work_Number__c = priApplicantContact.Phone;
        Database.Insert(priApplicantAcc, true);

        priApplicantContact.AccountId = priApplicantAcc.Id;
        priApplicantContact.OwnerId = PortalSecurityUtil.getSiteAdmin();
        Database.Insert(priApplicantContact, true);
     
        dealerApplicantRelObj=createDealerApplicantRelationship(new Map<String,Object>{
                                                                                PortalConstants.LOGGED_IN_USER=>loggedInUser,
                                                                                PortalConstants.CONTACT_OBJ_KEY=>priApplicantContact,
                                                                                PortalConstants.ACCOUNT_OBJ_KEY=>priApplicantAcc
                                                                            });

        Database.insert(dealerApplicantRelObj,true);

        priApplicantParty.clcommon__Account__c = priApplicantContact.AccountId;
        priApplicantParty.clcommon__Contact__c = priApplicantContact.Id;

        priApplicantParty.Title__c=priApplicantContact.Title;
        priApplicantParty.Suffix__c	=priApplicantContact.Suffix__c;
        priApplicantParty.Street__c=priApplicantContact.MailingStreet;
        priApplicantParty.City__c=priApplicantContact.MailingCity;
        priApplicantParty.State__c=priApplicantContact.MailingState;
        priApplicantParty.Postal_Code__c=priApplicantContact.MailingPostalCode;
        priApplicantParty.County__c=priApplicantContact.Mailing_County__c;

        priApplicantParty.Home_Number__c=priApplicantContact.HomePhone;
        priApplicantParty.Work_Number__c=priApplicantContact.Phone;
        priApplicantParty.Mobile_Number__c=priApplicantContact.MobilePhone;

        priApplicantParty.Marital_Status__c=priApplicantContact.clcommon__Marital_Status__c;

        priApplicantParty.Dealer_Applicant_Relationship__c=dealerApplicantRelObj.id;
    }

    /**
    * @description this method is to check for the applicants, if they have a non accrual or  have past due, we throw an exception
    * @author Rakesh Saraf | 11-26-2024 
    * @param userApp 
    **/
    public static void checkForNonAccrualAndHasPastDue(genesis__Applications__c userApp){
        //Map<String,Boolean> trackStatusMap = new Map<String,Boolean>();
        Boolean trackNonAccrual = false;
        Boolean trackHasPastDue = false;
        List<clcommon__Party__c> verifyPartyList = [SELECT Id,  
                                                            Dealer_Applicant_Relationship__r.Has_Past_Due__c,
                                                            Dealer_Applicant_Relationship__r.Is_Non_Accrual__c,
                                                            clcommon__Type__r.Name
                                                        FROM clcommon__Party__c
                                                        WHERE genesis__Application__c =: userApp.id
                                                        AND clcommon__Type__r.Name IN (
                                                            :PortalConstants.PRINCIPAL_PARTY_NAME,
                                                            :PortalConstants.BORROWER_PARTY_NAME)
                                                        ];
        for(clcommon__Party__c existingParty: verifyPartyList){
            if(existingParty.Dealer_Applicant_Relationship__r.Has_Past_Due__c == true){
                trackHasPastDue = true;
            }
            if(existingParty.Dealer_Applicant_Relationship__r.Is_Non_Accrual__c == true){
                trackNonAccrual = true;
            }
        }
        if(trackNonAccrual){
            throw new CustomException(PortalConstants.NON_ACCRUAL_APPLICATIONS_EXCEPTION);
        }  
        if(trackHasPastDue){
            throw new CustomException(PortalConstants.PAST_DUE_APPLICATIONS_EXCEPTION);
        }
              
    }

    /**
    * @description updates the details of the principal parties
    * @author Rakesh Saraf | 12-05-2024 
    * @param applicationObj 
    * @param loggedInUser 
    **/
    public static void updatePrincipalPartyDetails(genesis__Applications__c applicationObj,List<User> loggedInUser){
        List<Id> principalConIdList=new List<Id>();
        List<Id> principalBInfoIdList=new List<Id>();
        Map<Id,Contact> idVsContactMap=new Map<Id,Contact>();
        Map<Id,Id> idVsDealerAppRelMap=new Map<Id,Id>();
        Map<Id,genesis__Business_Information__c> idVsBusinessnInfoMap=new Map<Id,genesis__Business_Information__c>();

        List<Contact> principalContactList=new List<Contact>();
        List<genesis__Business_Information__c> principalBusinessInfoList=new List<genesis__Business_Information__c>();

        List<clcommon__Party__c> principalParties=[SELECT ID,
                                                          clcommon__Account__c,
                                                          clcommon__Contact__c,
                                                          Dealer_Applicant_Relationship__c
                                                    FROM clcommon__Party__c
                                                    WHERE genesis__Application__c =: applicationObj.Id
                                                    AND clcommon__Type__r.Name  = :PortalConstants.PRINCIPAL_PARTY_NAME];


        if(principalParties.isEmpty()){
            return;
        }

        for(clcommon__Party__c eachParty:principalParties){
            principalConIdList.add(eachParty.clcommon__Contact__c);
        }

        principalContactList=[SELECT Id,
                                    AccountId,
                                    Account.clcommon__Legal_Entity_Type__c,
                                    genesis__SSN__c,
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
                                    clcommon__Marital_Status__c,
                                    Account.genesis__Business_Information__c
                            FROM Contact
                            WHERE Id IN: principalConIdList];

        List<Dealer_Applicant_Relationship__c> dealerPrincipalRelList=[SELECT ID,
                                                                              Applicant__c
                                                                       FROM Dealer_Applicant_Relationship__c
                                                                       WHERE Dealer__c=: loggedInUser[0].Account.ParentId 
                                                                       AND Applicant_Contact__c IN: principalConIdList];

        dealerPrincipalRelList=processDealerAppplicantRelForPrincipals(new Map<String,List<Object>>{PortalConstants.LOGGED_IN_USER=>loggedInUser,
                                                                                                    PortalConstants.KEY_PRINCIPAL=>principalParties,
                                                                                                    PortalConstants.APPLICANT_DEALER_RELATION_KEY=>dealerPrincipalRelList}
                                                                                                        ,idVsDealerAppRelMap);

        
        for(Contact eachPrinContact: principalContactList){
            idVsContactMap.put(eachPrinContact.id,eachPrinContact);
            principalBInfoIdList.add(eachPrinContact.Account.genesis__Business_Information__c);
        }

        principalBusinessInfoList=[SELECT ID,
                                          Gross_Farm_Income__c
                                    FROM genesis__Business_Information__c
                                    WHERE Id IN :principalBInfoIdList];

        for(genesis__Business_Information__c eachBusinessInfo:principalBusinessInfoList){
            idVsBusinessnInfoMap.put(eachBusinessInfo.id,eachBusinessInfo);
        }

        for(clcommon__Party__c eachParty:principalParties){
            
            Contact principalContact=idVsContactMap.get(eachParty.clcommon__Contact__c);
            genesis__Business_Information__c principalBInfo=idVsBusinessnInfoMap.get(principalContact.Account.genesis__Business_Information__c);

            eachParty.Title__c=principalContact.Title;
            eachParty.Suffix__c	=principalContact.Suffix__c;
            eachParty.Street__c=principalContact.MailingStreet;
            eachParty.City__c=principalContact.MailingCity;
            eachParty.State__c=principalContact.MailingState;
            eachParty.Postal_Code__c=principalContact.MailingPostalCode;
            eachParty.County__c=principalContact.Mailing_County__c;

            eachParty.Home_Number__c=principalContact.HomePhone;
            eachParty.Work_Number__c=principalContact.Phone;
            eachParty.Mobile_Number__c=principalContact.MobilePhone;

            eachParty.Gross_Farm_Income__c=principalBInfo.Gross_Farm_Income__c;

            eachParty.Marital_Status__c=principalContact.clcommon__Marital_Status__c;

            eachParty.Dealer_Applicant_Relationship__c=idVsDealerAppRelMap.get(eachParty.clcommon__Account__c);
        }
        Database.update(principalParties,true);
    }

    /**
    * @description the purpose of this method is to check of all the principals have a dealer applicant rel created for them. If not it creates one for them.
    * @author Rakesh Saraf | 01-09-2025 
    * @param paramMap 
    * @param idVsDealerAppRelMap 
    * @return List<Dealer_Applicant_Relationship__c> 
    **/
    private static List<Dealer_Applicant_Relationship__c> processDealerAppplicantRelForPrincipals(Map<String,List<Object>> paramMap,Map<Id,Id> idVsDealerAppRelMap){
        List<User> loggedInUser=(List<User>)paramMap.get(PortalConstants.LOGGED_IN_USER);
        List<clcommon__Party__c> principalParties=(List<clcommon__Party__c>)paramMap.get(PortalConstants.KEY_PRINCIPAL);
        List<Dealer_Applicant_Relationship__c> dealerPrincipalRelList=(List<Dealer_Applicant_Relationship__c>)paramMap.get(PortalConstants.APPLICANT_DEALER_RELATION_KEY);


        List<Dealer_Applicant_Relationship__c> createdDealerAppRelList=new List<Dealer_Applicant_Relationship__c>();

        
        for(Dealer_Applicant_Relationship__c eachDealerAppRel:dealerPrincipalRelList){
            idVsDealerAppRelMap.put(eachDealerAppRel.Applicant__c,eachDealerAppRel.id);
        }

        for(clcommon__Party__c eachParty: principalParties){
            if(!idVsDealerAppRelMap.containsKey(eachParty.clcommon__Account__c)){
                Dealer_Applicant_Relationship__c dealerApplicanRelObj=new Dealer_Applicant_Relationship__c();
                dealerApplicanRelObj.Dealer__c=loggedInUser[0].Account.ParentId;
                dealerApplicanRelObj.Applicant__c=eachParty.clcommon__Account__c;
                dealerApplicanRelObj.Applicant_Contact__c=eachParty.clcommon__Contact__c;
                createdDealerAppRelList.add(dealerApplicanRelObj);
            }
        }

        if(!createdDealerAppRelList.isEmpty()){
            Database.insert(createdDealerAppRelList,true);
            for(Dealer_Applicant_Relationship__c eachCreatedRel: createdDealerAppRelList){
                idVsDealerAppRelMap.put(eachCreatedRel.Applicant__c,eachCreatedRel.id);
            }
            dealerPrincipalRelList.addAll(createdDealerAppRelList);
        }
        return dealerPrincipalRelList;
    }

    /**
    * @description get the list of coApplicants
    * @author Rakesh Saraf | 01-12-2025 
    * @param coApplicantList 
    * @return List<Map<String, Object>> 
    **/
    public static List<Map<String, Object>> getCoApplicantsList(List<Object> coApplicantList){
        List<Map<String, Object>> coApplicants=new List<Map<String, Object>>();
        if (!coApplicantList.isEmpty()) {
            for (Object eachCoApplicant : coApplicantList) {
                Map<String, Object> coApplicant = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(eachCoApplicant));

                coApplicants.add(coApplicant);
            }
        }
        return coApplicants;
    }

    /**
    * @description method used to insert the account details
    * @author Rakesh Saraf | 01-12-2025 
    * @param paramMap 
    * @param borrowerPartyList 
    * @param coApplicants 
    **/
    public static void updateAccountDetails(Map<String,Object> paramMap,List<clcommon__Party__c> borrowerPartyList,List<Map<String, Object>> coApplicants){
        Account accountObj=(Account) paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        Contact contactObj=(Contact)paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        genesis__Business_Information__c businessInfoObj=(genesis__Business_Information__c) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        genesis__Applications__c applicationObj=(genesis__Applications__c)paramMap.get(PortalConstants.APPLICATION_OBJ_KEY);
        String entity=(String)paramMap.get(PortalConstants.ENTITY_KEY);
        String coopType=(String)paramMap.get(PortalConstants.KEY_COOP_TYPE);

        Contact contactToDelete;
        Boolean shouldDeleteRedundantData=PortalConstants.FALSE_VALUE;
        
        if(entity == PortalConstants.INDIVIDUAL_ENTITY){
            PortalApplicationOriginationHelper.addDBAAdress(coApplicants, accountObj,borrowerPartyList[0]);

            accountObj.Is_Individual__c=false;
        }

        else if(entity == PortalConstants.SOLE_PROP_ENTITY){
            //if the new ssn already exist as a coapplicant
            checkForCoapplicantWithSameSSN(coApplicants, contactObj.genesis__SSN__c);

            List<Contact> currentContactList = [SELECT Id,
                                                        AccountId,
                                                        Account.genesis__Business_Information__c,
                                                        genesis__SSN__c
                                                FROM Contact
                                                WHERE Id =:contactObj.id ];

            if(currentContactList[0].genesis__SSN__c != contactObj.genesis__SSN__c){
                contactObj = PortalValidationUtil.validateNewGrower(contactObj, coopType, loggedInUser[0].Account.ParentId);
                PortalValidationUtil.verifyUserForApplicant(currentContactList[0].id,contactObj.id);
            }

            //if contact is found from db
            if(currentContactList[0].Id != contactObj.Id){

                applicationObj.genesis__Contact__c = contactObj.Id;
                applicationObj.genesis__Account__c = contactObj.AccountId;
                
                accountObj.Id = contactObj.AccountId;

                shouldDeleteRedundantData=PortalConstants.TRUE_VALUE;
                contactToDelete=currentContactList[0];
                
                borrowerPartyList[0].clcommon__Account__c = contactObj.AccountId;

                List<Contact> newContact = [SELECT Id,
                                                    Account.genesis__business_information__c 
                                            FROM Contact 
                                            WHERE Id =: contactObj.Id];

                businessInfoObj.Id = newContact[0].Account.genesis__business_information__c;

                borrowerPartyList[0].clcommon__Contact__c = contactObj.Id;
            }

            accountObj.Is_Individual__c=true;
        }
        else{
            Account currentAccount=[SELECT Id, 
                                           genesis__business_information__r.genesis__Tax_Identification_Number__c
                                    FROM Account WHERE Id =: accountObj.id];
            if(businessInfoObj.genesis__Tax_Identification_Number__c != currentAccount.genesis__business_information__r.genesis__Tax_Identification_Number__c){
                PortalValidationUtil.validateDuplicateCorporation(new Map<String,Object>{PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoObj,
                                                                                        PortalConstants.ACCOUNT_OBJ_KEY=>accountObj,
                                                                                        PortalConstants.DEALER_ID_KEY=>loggedInUser[0].Account.ParentId
                                                                                    });
            }

            //for - if only corporation name is changed
            List<Contact> contactForFoundAccount = [SELECT Id 
                                                    FROM Contact 
                                                    WHERE AccountId =: accountObj.Id];
            contactObj.Id = contactForFoundAccount[0].Id;
            contactObj.LastName = accountObj.Name;

            if(currentAccount.Id != accountObj.Id){
                contactObj.AccountId = accountObj.Id;
                applicationObj.genesis__Account__c = accountObj.Id;
                applicationObj.genesis__Contact__c = contactObj.Id;

                List<Contact> currentContactList = [SELECT Id,
                                                            Account.genesis__Business_Information__c
                                                    FROM Contact
                                                    WHERE AccountId =: currentAccount.Id];

                shouldDeleteRedundantData=PortalConstants.TRUE_VALUE;
                contactToDelete=currentContactList[0];

                borrowerPartyList[0].clcommon__Account__c = contactObj.AccountId;

                List<Contact> newContact = [SELECT Id,
                                                    Account.genesis__business_information__c 
                                            FROM Contact 
                                            WHERE Id =: contactObj.Id];

                businessInfoObj.Id = newContact[0].Account.genesis__business_information__c;

                borrowerPartyList[0].clcommon__Contact__c = contactObj.Id;

            }

            accountObj.Is_Individual__c=false;
        }

        renameAccountForSoleProp(paramMap);
        accountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId();

        Database.update(accountObj, true);

        List<Dealer_Applicant_Relationship__c> dealerGrowerRelList=[SELECT ID 
                                                                    FROM Dealer_Applicant_Relationship__c 
                                                                    WHERE Dealer__c=:accountObj.ParentId 
                                                                    AND Applicant__c=:accountObj.id];
        if(dealerGrowerRelList.isEmpty()){
            Dealer_Applicant_Relationship__c dealerGrowerRelObj=PortalApplicationCreationHandler.createDealerApplicantRelationship(new Map<String,Object>{
                                                                                                                                                            PortalConstants.LOGGED_IN_USER=>loggedInUser[0],
                                                                                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactObj,
                                                                                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountObj
                                                                                                                                                        });
            dealerGrowerRelList.add(dealerGrowerRelObj);
            Database.insert(dealerGrowerRelList,true);
            
        }
        borrowerPartyList[0].Dealer_Applicant_Relationship__c=dealerGrowerRelList[0].id;
        applicationObj.Dealer_Applicant_Relationship__c=dealerGrowerRelList[0].id;

        Database.update(applicationObj, true);

        if(shouldDeleteRedundantData == PortalConstants.TRUE_VALUE){
            PortalApplicationCreationHandler.deleteRedundantAccountAndContact(contactToDelete, applicationObj.id,loggedInUser[0]);
        }
        Database.update(borrowerPartyList, true);
        
    }

    /**
    * @description check whether a co app with the same ssn as the grower exists or not
    * @author Rakesh Saraf | 02-16-2025 
    * @param coApplicants 
    * @param borrowerSSN 
    **/
    private static void checkForCoapplicantWithSameSSN(List<Map<String, Object>> coApplicants,String borrowerSSN){

        for(Map<String, Object> coApplicant:coApplicants){
            String coApplicantSSN=PortalApplicationOriginationHelper.checkFieldInMap(coApplicant,PortalConstants.COAPPLICANT_SSN_KEY);
            if(coApplicantSSN==borrowerSSN){
                throw new CustomException(PortalConstants.COAPPLICANT_ALREADY_EXIST);
            }

        }

    }

    /**
    * @description the purpose of this method is to rename the sole prop account
    * @author Rakesh Saraf | 02-14-2025 
    * @param paramMap
    **/
    private static void renameAccountForSoleProp(Map<String,Object> paramMap){
        String entity=(String)paramMap.get(PortalConstants.ENTITY_KEY);
        Account accountObj=(Account) paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        Contact contactObj=(Contact)paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        genesis__Business_Information__c businessInfoObj=(genesis__Business_Information__c) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        genesis__Applications__c applicationObj=(genesis__Applications__c)paramMap.get(PortalConstants.APPLICATION_OBJ_KEY);

        List<genesis__Applications__c> applicationList=[SELECT Id,
                                                               Coop_type__c,
                                                               Dealer_Name__c
                                                        FROM genesis__Applications__c
                                                        WHERE Id=:applicationObj.id];

        PortalApplicationOriginationHelper.checkEmptyList(applicationList,PortalConstants.SOMETHING_WENT_WRONG);

        accountObj.ParentId=applicationList[0].Dealer_Name__c;
        accountObj.Coop_Type__c=applicationList[0].Coop_type__c;

        List<Account> accountList=[SELECT ID,
                                          Kyc_Verified__c,
                                          Name,
                                          clcommon__Email__c,
                                          Confirm_Email__c,
                                          clcommon__Legal_Entity_Type__c,
                                          genesis__Business_Information__r.genesis__Tax_Identification_Number__c
                                   FROM Account
                                   WHERE id=:accountObj.id];
        PortalApplicationOriginationHelper.checkEmptyList(accountList,PortalConstants.SOMETHING_WENT_WRONG);

        if(accountList[0].Kyc_Verified__c){
            accountObj.Name=accountList[0].Name;
            accountObj.clcommon__Email__c=accountList[0].clcommon__Email__c;
            accountObj.Confirm_Email__c=accountList[0].Confirm_Email__c;
            accountObj.clcommon__Legal_Entity_Type__c=accountList[0].clcommon__Legal_Entity_Type__c;
            businessInfoObj.genesis__Tax_Identification_Number__c=accountList[0].genesis__Business_Information__r.genesis__Tax_Identification_Number__c;
            return;
        }

        //Rename the Account from Contact for Individual Sole Prop ------------------
        if (entity == PortalConstants.SOLE_PROP_ENTITY &&
            !String.isBlank(contactObj.Id) && 
            (!String.isBlank(contactObj.FirstName) &
            !String.isBlank(contactObj.LastName))) {
                accountObj.Name = contactObj.LastName + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + contactObj.FirstName + PortalConstants.SPACE_STRING + contactObj.ints__Middle_Name__c;
        }
        //Rename the Account from Contact for Individual Sole Prop ------------------
        else if (entity == PortalConstants.SOLE_PROP_ENTITY &&
            !String.isBlank(contactObj.Id) && 
            (String.isBlank(contactObj.FirstName) &
            !String.isBlank(contactObj.LastName))) {
                accountObj.Name = contactObj.LastName;
        }
    }

    /**
    * @description this method is used to check the presence of contact with same ssn and then process the business info. 
    * @author Rakesh Saraf | 01-12-2025 
    * @param paramMap 
    * @param borrowerPartyList 
    **/
    public static void updateContactAndBusinessInfoDetails(Map<String,Object> paramMap, List<clcommon__Party__c> borrowerPartyList){
        Account accountObj=(Account) paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        Contact contactObj=(Contact)paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        genesis__Applications__c applicationObj=(genesis__Applications__c)paramMap.get(PortalConstants.APPLICATION_OBJ_KEY);
        genesis__Business_Information__c  businessInfoObj=(genesis__Business_Information__c) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);

        if(!String.isBlank(contactObj.Id)){
            Boolean isValidContact = PortalSecurityUtil.validateUserBorrowerContactByApplication(applicationObj.Id, contactObj.Id); 
            PortalApplicationOriginationHelper.throwErrorIfFalse(isValidContact, PortalConstants.USER_NOT_AUTHORISED);

            List<Contact> contactList=[SELECT id,
                                          FirstName,
                                          LastName,
                                          ints__Middle_Name__c,
                                          Email,
                                          Confirm_Email__c,
                                          Birthdate,
                                          genesis__SSN__c,
                                          Confirm_SSN__c,
                                          Account.Kyc_Verified__c
                                   FROM Contact
                                   WHERE id=:contactObj.id];
            PortalApplicationOriginationHelper.checkEmptyList(contactList, PortalConstants.SOMETHING_WENT_WRONG);

            if(contactList[0].Account.Kyc_Verified__c){
                contactObj.FirstName=contactList[0].FirstName;
                contactObj.LastName=contactList[0].LastName;
                contactObj.ints__Middle_Name__c=contactList[0].ints__Middle_Name__c;
                contactObj.Email=contactList[0].Email;
                contactObj.genesis__SSN__c=contactList[0].genesis__SSN__c;
                contactObj.Confirm_SSN__c=contactList[0].Confirm_SSN__c;
                contactObj.Confirm_Email__c=contactList[0].Confirm_Email__c;
                contactObj.Birthdate=contactList[0].Birthdate;
            }

            Database.update(contactObj, true);
        }
        if(!String.isBlank(businessInfoObj.Id)){
            processBusinessInformation(new Map<String,Object>{PortalConstants.BUSINESS_INFO_OBJ_KEY=> businessInfoObj,
                                                              PortalConstants.ACCOUNT_OBJ_KEY=>accountObj,
                                                              PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});
        }
    }

    /**
     * @description : This method validate and updates the business info and updates the total asset and total liabilities field values in party object
     * @param  paramMap
     * @exception 
     */
    private static void processBusinessInformation(Map<string,Object> paramMap){

        genesis__Business_Information__c businessInfoObj=(genesis__Business_Information__c) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        Account accountObj=(Account)paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        clcommon__party__c borrowerPartyObj=(clcommon__party__c)paramMap.get(PortalConstants.BORROWER_PARTY_KEY);

        Boolean isValidBusiness = PortalSecurityUtil.validateUserBusinessInformation(businessInfoObj.Id, accountObj.Id); 
        PortalApplicationOriginationHelper.throwErrorIfFalse(isValidBusiness, PortalConstants.USER_NOT_AUTHORISED);

        Database.update(businessInfoObj, true);

        borrowerPartyObj.Total_Assets__c = businessInfoObj.genesis__Total_Assets__c;
        borrowerPartyObj.Total_Liabilities__c = businessInfoObj.genesis__Total_Liabilities__c;
        Database.Update(borrowerPartyObj, true);
    }
    
    /**
    * @description this method makes sure that for a grower or a coApplicant, if their KYC has been verifired, they will not be able to change certain fields while initiating an application
    * @author Rakesh Saraf | 02-11-2025 
    * @param contactObj 
    * @param accountObj 
    **/
    public static void checkIfKycVerified(Contact contactObj,Account accountObj){
        if(String.isBlank(contactObj.Id) || String.isBlank(accountObj.id)){
            return;
        }

        List<Contact> contactList=[SELECT id,
                                          FirstName,
                                          LastName,
                                          ints__Middle_Name__c,
                                          genesis__SSN__c,
                                          Confirm_SSN__c,
                                          Email,
                                          Confirm_Email__c,
                                          Birthdate,
                                          Account.Kyc_Verified__c,
                                          Account.Name,
                                          Account.clcommon__Email__c,
                                          Account.Confirm_Email__c,
                                          Account.clcommon__Legal_Entity_Type__c
                                   FROM Contact
                                   WHERE id=:contactObj.id];

        PortalApplicationOriginationHelper.checkEmptyList(contactList, PortalConstants.SOMETHING_WENT_WRONG);

        if(contactList[0].Account.Kyc_Verified__c){
            contactObj.FirstName=contactList[0].FirstName;
            contactObj.LastName=contactList[0].LastName;
            contactObj.ints__Middle_Name__c=contactList[0].ints__Middle_Name__c;
            contactObj.genesis__SSN__c=contactList[0].genesis__SSN__c;
            contactObj.Confirm_SSN__c=contactList[0].Confirm_SSN__c;
            contactObj.Email=contactList[0].Email;
            contactObj.Confirm_Email__c=contactList[0].Confirm_Email__c;
            contactObj.Birthdate=contactList[0].Birthdate;

            accountObj.Name=contactList[0].Account.Name;
            accountObj.clcommon__Email__c=contactList[0].Account.clcommon__Email__c;
            accountObj.Confirm_Email__c=contactList[0].Account.Confirm_Email__c;
            accountObj.clcommon__Legal_Entity_Type__c=contactList[0].Account.clcommon__Legal_Entity_Type__c;
        }

    }

    /**
    * @description the purpose of this method is to check if any of the principal account is kyc verified, certain details of their account and contact must not change
    * @author Rakesh Saraf | 02-12-2025 
    * @param accountList 
    * @param contactList 
    * @param contactIdvsPartyMap 
    **/
    public static void checkKycVerifiedForCoApplicants(List<Account> accountList,List<Contact> contactList,Map<Id,clcommon__Party__c> contactIdvsPartyMap){
        Set<Id> contactIdList=contactIdvsPartyMap.keySet();
        Map<Id,Account> idVsAccountMap=new Map<Id,Account>();
        Map<Id,Contact> idVsContactMap=new Map<Id,Contact>();

        for(Account eachAccount:accountList){
            idVsAccountMap.put(eachAccount.id,eachAccount);
        }
        for(Contact eachContact:contactList){
            idVsContactMap.put(eachContact.id,eachContact);
        }

        List<Contact> existingContactList=[SELECT id,
                                                  FirstName,
                                                  LastName,
                                                  ints__Middle_Name__c,
                                                  genesis__SSN__c,
                                                  Confirm_SSN__c,
                                                  Email,
                                                  Confirm_Email__c,
                                                  Birthdate,
                                                  AccountId,
                                                  Account.Kyc_Verified__c,
                                                  Account.Name,
                                                  Account.clcommon__Email__c,
                                                  Account.Confirm_Email__c,
                                                  Account.clcommon__Legal_Entity_Type__c
                                          FROM Contact
                                          WHERE id IN :contactIdList];

        for(Contact eachContact:existingContactList){
            Contact principalContact=idVsContactMap.get(eachContact.id);
            Account principalAccount=idVsAccountMap.get(eachContact.AccountId);

            if(eachContact.Account.Kyc_Verified__c){
                principalContact.FirstName=eachContact.FirstName;
                principalContact.LastName=eachContact.LastName;
                principalContact.ints__Middle_Name__c=eachContact.ints__Middle_Name__c;
                principalContact.genesis__SSN__c=eachContact.genesis__SSN__c;
                principalContact.Confirm_SSN__c=eachContact.Confirm_SSN__c;
                principalContact.Email=eachContact.Email;
                principalContact.Confirm_Email__c=eachContact.Confirm_Email__c;
                principalContact.Birthdate=eachContact.Birthdate;

                principalAccount.Name=eachContact.Account.Name;
                principalAccount.clcommon__Email__c=eachContact.Account.clcommon__Email__c;
                principalAccount.Confirm_Email__c=eachContact.Account.Confirm_Email__c;
                principalAccount.clcommon__Legal_Entity_Type__c=eachContact.Account.clcommon__Legal_Entity_Type__c;
            }
        }
    }

    /**
    * @description this method is used to populate the corporation contact with the info from the account
    * @author Rakesh Saraf | 03-11-2025 
    * @param contactObj 
    * @param accountObj 
    **/
    public static void populateCorporationContact(Contact contactObj,Account accountObj){

        contactObj.MobilePhone = accountObj.Phone ;
        contactObj.Phone = accountObj.Work_Number__c ;
        contactObj.HomePhone =accountObj.Home_Number__c  ;

        contactObj.MailingStreet = accountObj.BillingStreet ;
        contactObj.MailingCity = accountObj.BillingCity ;
        contactObj.MailingState = accountObj.BillingState ;
        contactObj.Mailing_County__c =  accountObj.Billing_County__c;
        contactObj.MailingPostalCode = accountObj.BillingPostalCode ;
    }
}