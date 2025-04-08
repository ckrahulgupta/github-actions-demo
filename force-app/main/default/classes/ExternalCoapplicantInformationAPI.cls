/**
 * @description       : saves the co-applicant information for external apis
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 04-01-2025
 * @last modified by  : Rakesh Saraf
**/
@RestResource(urlMapping = '/api/v1/external/saveCoapplicantInformation')
global without sharing class ExternalCoapplicantInformationAPI {
    private static final String CLASS_NAME = ExternalCoapplicantInformationAPI.class.getName();
    private static final String UNIQUE_ID_ASSET_KEY = 'uniqueIdVsAssetsMap';
    private static final String UNIQUE_ID_LIABILITIES_KEY = 'uniqueIdVsLiabilitiesMap';
    private static final String UNIQUE_ID_PARTY_KEY = 'uniqueIdVspartyMap';
    private static final String UNIQUE_ID_GFI_KEY = 'uniqueIdVsGFIMap';
    private static final String ACC_DBUSINESS_KEY = 'accVsDuplicateBusinessMap';
    private static final String ACC_UNIQUE_ID_KEY = 'accountUniqueId';
    private static final String DUPLICATE_FOUND = 'duplicateFound';
    private static final String CONTACT_KEY = 'Contact';
    private static final String ACC_KEY = 'Account';
    private static final String B_INFO_KEY = 'BusinessInfo';
    private static final String CONTACT_DR_KEY = 'conVsDealerApplicantMap';
    private static final String FIRST_PRINCIPAL_KEY = 'firstPrincipalParty';
    private static final String FIRST_PRINCIPAL_MAP = 'firstPrincipalDetailsMap';
    private static final String ACCOUNT_VS_BINFO_KEY = 'accountVsBInforMap';
    static Account dealerForExtUser;
    static Map<Id,genesis__Business_Information__c> bInfoIdVsBInfoMap=new Map<Id,genesis__Business_Information__c>();

    /**
    * @description : saves the information of borrower in applicant information page
    * @author Krishanu Chinya | 05-30-2024 
    **/
    @HttpPost
    global static void doSaveCoapplicantsInformation(){
        RestResponse response = RestContext.response;
        SavePoint dbSavePoint = Database.setSavepoint();

        try{
            RestRequest requestParam = RestContext.request;
            response.addHeader(ExternalConstants.CONTENT_TYPE, ExternalConstants.APPLICATION_JSON);
            String requestBody = requestParam.requestBody.toString();
            ExternalApplicationOriginationUtil.checkForBlankParameter(requestBody);
            Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(requestBody);

            Map<String,Object> applicationDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.APPLICATION_DETAIL_KEY);
            Map<String,Object> borrowerDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.BORROWER_DETAIL_KEY);
            List<Object> principalDetailList = (List<Object>)requestMap.get(ExternalConstants.PRINCIPAL_DETAIL_KEY);

            Map<String,Object> dealerDetailsMap = (Map<String,Object>) requestParam.headers;
            ExternalApplicationOriginationUtil.checkForNullObject(dealerDetailsMap, ExternalConstants.DEALER_DETAILS_MISSING);  
            dealerForExtUser = ExternalApplicationValidationUtil.validateDealerDetails(dealerDetailsMap);
            
            String applicationId = (String)applicationDetailsMap.get(ExternalConstants.ID);

            Map<String, Contact> uniqueIdvsContactMap = new Map<String, Contact>();
            Map<String, clcommon__Party__c> uniqueIdvsPartyMap = new Map<String, clcommon__Party__c>();
            Map<String, Integer> uniqueIdVsAssetsMap = new Map<String, Integer>();
            Map<String, Integer> uniqueIdVsGFIMap = new Map<String, Integer>();
            Map<String, Integer> uniqueIdVsLiabilitiesMap = new Map<String, Integer>();
            Map<String, Id> accVsDuplicateBusinessMap = new Map<String,Id>();
            Map<String, genesis__Business_Information__c> accIdVsBusinessInfoMap = new Map<String, genesis__Business_Information__c>();
            List<Contact> principalContactList = new List<Contact>();
            List<Account> principalAccountList = new List<Account>();
            List<genesis__Business_Information__c> businessInfoList = new List<genesis__Business_Information__c>();
            Boolean firstPrincipalFlag = false;
            List<String> duplicateContactIdList = new List<String>();
            
            //validating application with bororwer id
            ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(borrowerDetailsMap.get(ExternalConstants.USER_ID_KEY)), ExternalConstants.USER_ID_MISSING); 

            //validating whether the borrower belongs to the application
            ExternalSecurityUtil.validateBorrowerWithApplication(applicationId, (String)borrowerDetailsMap.get(ExternalConstants.USER_ID_KEY), dealerForExtUser.Id);
            String legalEntity = ExternalApplicationOriginationUtil.getLegalEntityByUniqueId((String)borrowerDetailsMap.get(ExternalConstants.USER_ID_KEY));

            Map<String, Object> firstPrincipalDetailsMap;
            clcommon__Party__c firstPrincipalParty;
            String firstPrincipalUniquId;
            if(legalEntity != ExternalConstants.SOLE_PROP_ENTITY){
                firstPrincipalParty = getFirstPrincipalParty(applicationId);
                firstPrincipalUniquId = firstPrincipalParty.clcommon__Account__r.Unique_Id__c;
            }

            //processing each principal
            for(Object eachPrincipal : principalDetailList){
                Map<String, Object> principalDetailsMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(eachPrincipal));
                ExternalApplicationValidationUtil.validateApplicantInfoData(principalDetailsMap, ExternalConstants.SOLE_PROP_ENTITY);
                ExternalApplicationValidationUtil.validateTitle(String.valueOf(principalDetailsMap.get(ExternalConstants.TITLE_KEY)), legalEntity);

                if(String.valueOf(principalDetailsMap.get(ExternalConstants.USER_ID_KEY)) == firstPrincipalUniquId){
                    firstPrincipalFlag = true;
                    firstPrincipalDetailsMap = principalDetailsMap;
                    continue;
                }

                String ssn = ExternalApplicationValidationUtil.validateSSNOfPrincipal(principalDetailsMap);

                //duplicate check 
                Map<String, Object> duplicatePrincipalMap = ExternalValidationUtil.validateDuplicateIndividual(ssn);

                //populate contact details
                Map<String,Object> principalConPartyMap = populatePrincipalContactAndParty(new Map<String,Map<String,Object>>{
                                                                                                                            ExternalConstants.PRINCIPAL_DETAIL_KEY=>principalDetailsMap,
                                                                                                                            ExternalConstants.DUPLICATE_DETAILS_KEY=>duplicatePrincipalMap
                                                                                                                        },
                                                                                           new Map<String,List<Object>>{
                                                                                                                        ExternalConstants.DUPLICATE_CONTACT_ID_KEY=>duplicateContactIdList,
                                                                                                                        ExternalConstants.PRINCIPAL_CONTACT_KEY=>principalContactList
                                                                                                                        });
                
                //populate account details
                Account principalAccountObj = populatePrincipalAccount(principalDetailsMap,duplicatePrincipalMap,accVsDuplicateBusinessMap);
                principalAccountList.add(principalAccountObj);
                
                uniqueIdVsContactMap.put(String.valueOf(principalDetailsMap.get(ExternalConstants.USER_ID_KEY)), (Contact)principalConPartyMap.get(ExternalConstants.PRINCIPAL_CONTACT_KEY));
                uniqueIdvsPartyMap.put(String.valueOf(principalDetailsMap.get(ExternalConstants.USER_ID_KEY)), (clcommon__Party__c)principalConPartyMap.get(ExternalConstants.PRINCIPAL_PARTY_KEY));
                uniqueIdVsAssetsMap.put(String.valueOf(principalDetailsMap.get(ExternalConstants.USER_ID_KEY)), Integer.valueOf(principalDetailsMap.get(ExternalConstants.TOTAL_ASSETS_KEY)));
                uniqueIdVsGFIMap.put(String.valueOf(principalDetailsMap.get(ExternalConstants.USER_ID_KEY)), Integer.valueOf(principalDetailsMap.get(ExternalConstants.GROSS_FARM_INCOME_KEY)));
                uniqueIdVsLiabilitiesMap.put(String.valueOf(principalDetailsMap.get(ExternalConstants.USER_ID_KEY)), Integer.valueOf(principalDetailsMap.get(ExternalConstants.TOTAL_LIABILITIES_KEY)));
            }

            checkForFirstPrincipal(firstPrincipalFlag, legalEntity, new Map<String,Object>{
                FIRST_PRINCIPAL_KEY => firstPrincipalParty,
                FIRST_PRINCIPAL_MAP => firstPrincipalDetailsMap
            });

            Database.upsert(principalAccountList, true);

            ExternalApplicationCreationHandler.assignCIFtoCoapplicants(principalAccountList, dealerForExtUser.Coop_Type__c);

            getPrincipalBusinessInfo((List<Id>) accVsDuplicateBusinessMap.values());
        
            for(Account principalAccountObj : principalAccountList){
                Contact currentContactObj = uniqueIdVsContactMap.get(principalAccountObj.Unique_Id__c);
                currentContactObj.AccountId = principalAccountObj.Id;

                genesis__Business_Information__c principalBusinessInfoObj = getNewBusinessInfo(new Map<String, Object> {
                    UNIQUE_ID_ASSET_KEY => uniqueIdVsAssetsMap,
                    UNIQUE_ID_LIABILITIES_KEY => uniqueIdVsLiabilitiesMap,
                    UNIQUE_ID_GFI_KEY => uniqueIdVsGFIMap,
                    ACC_DBUSINESS_KEY => accVsDuplicateBusinessMap,
                    ACC_UNIQUE_ID_KEY => principalAccountObj.Unique_Id__c
                });
                businessInfoList.add(principalBusinessInfoObj);
                accIdVsBusinessInfoMap.put(principalAccountObj.Id, principalBusinessInfoObj);
            }
            Database.upsert(principalContactList, true);
            Database.upsert(businessInfoList, true);

            //populating business info in account
            assignBusinessInfoToAccount(principalAccountList,accIdVsBusinessInfoMap);

            Map<String,Dealer_Applicant_Relationship__c> conVsDealerApplicantMap = getDealerApplicantRelationship(duplicateContactIdList,principalContactList);

            createPrincipalParty(principalContactList, applicationId, new Map<String,Object>{
                UNIQUE_ID_GFI_KEY => uniqueIdVsGFIMap,
                UNIQUE_ID_ASSET_KEY => uniqueIdVsAssetsMap,
                UNIQUE_ID_LIABILITIES_KEY => uniqueIdVsLiabilitiesMap,
                UNIQUE_ID_PARTY_KEY => uniqueIdvsPartyMap,
                CONTACT_DR_KEY => conVsDealerApplicantMap
            });

            setSuccessResponse(response);
        }catch(CustomException customExceptionObj) {
            Database.rollback(dbSavePoint);
            ExternalExceptionUtil.handleCustomException(customExceptionObj, CLASS_NAME, response);
        }catch (Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            ExternalExceptionUtil.saveExceptionLog(exceptionObj, CLASS_NAME);
            ExternalExceptionUtil.setFailureResponse(response,ExternalConstants.UNEXPECTED_ERROR);
        }
    }

    /**
    * @description method to get the business info for all the principals
    * @author Rakesh Saraf | 03-20-2025 
    * @param principalBInfoIdList 
    **/
    private static void getPrincipalBusinessInfo(List<Id> principalBInfoIdList){
        
        if(principalBInfoIdList.isEmpty()){
            return;
        }

        bInfoIdVsBInfoMap=new Map<Id,genesis__Business_Information__c>([SELECT ID,
                                                                                genesis__Total_Assets__c,
                                                                                genesis__Total_Liabilities__c,
                                                                                Gross_Farm_Income__c
                                                                        FROM genesis__Business_Information__c
                                                                        WHERE Id IN :principalBInfoIdList]);

    }

   
    /**
    * @description : creates a business infor for the coapplicant
    * @author Krishanu Chinya | 07-10-2024 
    * @param paramMap 
    * @return genesis__Business_Information__c 
    **/
    private static genesis__Business_Information__c getNewBusinessInfo(Map<String, Object> paramMap){
        Map<String, Integer> uniqueIdVsAssetsMap = (Map<String, Integer>)paramMap.get(UNIQUE_ID_ASSET_KEY);
        Map<String, Integer> uniqueIdVsLiabilitiesMap = (Map<String, Integer>)paramMap.get(UNIQUE_ID_LIABILITIES_KEY);
        Map<String, Integer> uniqueIdVsGFIMap = (Map<String, Integer>)paramMap.get(UNIQUE_ID_GFI_KEY);
        String uniqueId = (String)paramMap.get(ACC_UNIQUE_ID_KEY);
        Map<String, Id> accVsDuplicateBusinessMap = (Map<String, Id>)paramMap.get(ACC_DBUSINESS_KEY);

        genesis__Business_Information__c principalBusinessInfoObj = new genesis__Business_Information__c();
        principalBusinessInfoObj.Id = accVsDuplicateBusinessMap.get(uniqueId);
        if(bInfoIdVsBInfoMap.containsKey(principalBusinessInfoObj.Id)){
            genesis__Business_Information__c principalBusinessInfo=bInfoIdVsBInfoMap.get(principalBusinessInfoObj.Id);
            principalBusinessInfoObj.genesis__Total_Assets__c = ExternalApplicationOriginationUtil.assignDecimalValueIfEmpty(principalBusinessInfo.genesis__Total_Assets__c, Integer.valueOf(uniqueIdVsAssetsMap.get(uniqueId)));
            principalBusinessInfoObj.genesis__Total_Liabilities__c = ExternalApplicationOriginationUtil.assignDecimalValueIfEmpty(principalBusinessInfo.genesis__Total_Liabilities__c, Integer.valueOf(uniqueIdVsLiabilitiesMap.get(uniqueId)));
            principalBusinessInfoObj.Gross_Farm_Income__c = ExternalApplicationOriginationUtil.assignDecimalValueIfEmpty(principalBusinessInfo.Gross_Farm_Income__c, Integer.valueOf(uniqueIdVsGFIMap.get(uniqueId)));
        }
        else{
            principalBusinessInfoObj.genesis__Total_Assets__c = Integer.valueOf(uniqueIdVsAssetsMap.get(uniqueId));
            principalBusinessInfoObj.genesis__Total_Liabilities__c = Integer.valueOf(uniqueIdVsLiabilitiesMap.get(uniqueId));
            principalBusinessInfoObj.Gross_Farm_Income__c = Integer.valueOf(uniqueIdVsGFIMap.get(uniqueId));
        }
        return principalBusinessInfoObj;
    }

    /**
    * @description : assignes usiness information to the coapplicant accounts
    * @author Krishanu Chinya | 06-12-2024 
    * @param principalAccountList 
    * @param accIdVsBusinessInfoMap 
    **/
    private static void assignBusinessInfoToAccount ( List<Account> principalAccountList,Map<String, genesis__Business_Information__c> accIdVsBusinessInfoMap){
        for(Account principalAccountObj : principalAccountList){
            principalAccountObj.genesis__Business_Information__c = accIdVsBusinessInfoMap.get(principalAccountObj.Id).Id;
        }
        Database.update(principalAccountList, true);

    }

    /**
    * @description : checks whether first principal data is provided or not
    * @author Krishanu Chinya | 06-12-2024 
    * @param firstPrincipalFlag 
    * @param legalEntity 
    * @param paramMap
    **/
    private static void checkForFirstPrincipal(Boolean firstPrincipalFlag, String legalEntity, Map<String,Object> paramMap){
        clcommon__Party__c firstPrincipalParty = (clcommon__Party__c)paramMap.get(FIRST_PRINCIPAL_KEY);
        Map<String, Object> firstPrincipalDetailsMap = (Map<String, Object>)paramMap.get(FIRST_PRINCIPAL_MAP);
        if(firstPrincipalFlag){
            populateFirstPrincipalData(firstPrincipalParty, firstPrincipalDetailsMap);
        }
        if(firstPrincipalFlag != true && legalEntity != ExternalConstants.SOLE_PROP_ENTITY){
            ExternalExceptionUtil.throwCustomException(ExternalConstants.PRINCIPAL_DETAILS_MISSING);
        }
    }

    /**
    * @description : creates party for the principal
    * @author Krishanu Chinya | 06-12-2024 
    * @param principalContactList 
    * @param applicationId 
    * @param paramMap
    **/
    private static void createPrincipalParty(List<Contact> principalContactList, String applicationId, Map<String,Object> paramMap){
        Map<String, Integer> uniqueIdVsGFIMap = (Map<String, Integer>)paramMap.get(UNIQUE_ID_GFI_KEY);
        Map<String, Integer> uniqueIdVsAssetsMap = (Map<String, Integer>)paramMap.get(UNIQUE_ID_ASSET_KEY);
        Map<String, Integer> uniqueIdVsLiabilitiesMap = (Map<String, Integer>)paramMap.get(UNIQUE_ID_LIABILITIES_KEY);
        Map<String, clcommon__Party__c> uniqueIdVsPartiesMap = (Map<String, clcommon__Party__c>)paramMap.get(UNIQUE_ID_PARTY_KEY);

        Map<String,Dealer_Applicant_Relationship__c> conVsDealerApplicantMap = (Map<String,Dealer_Applicant_Relationship__c>)paramMap.get(CONTACT_DR_KEY);
        List<clcommon__party__c> coApplicantPartyList = new List<clcommon__party__c>();
        Map<String, Id> mapOfpartyType = ExternalApplicationOriginationUtil.getPartyTypeMap();

        List<id> contactIdList = new List<id>();
        for(Contact contactObj : principalContactList){
            contactIdList.add(contactObj.Id);
        }

        ExternalValidationUtil.checkForDuplicateCoapplicant(contactIdList, applicationId);

        principalContactList = [SELECT Id, 
                                    AccountId, 
                                    Account.Unique_Id__c
                                FROM Contact
                                WHERE Id IN : contactIdList];

        for(Contact principalContactObj : principalContactList){

            clcommon__Party__c coApplicantParty = uniqueIdVsPartiesMap.get(principalContactObj.Account.Unique_Id__c);
            coApplicantParty.clcommon__Account__c = principalContactObj.AccountId;
            coApplicantParty.clcommon__Contact__c = principalContactObj.Id;
            coApplicantParty.genesis__Application__c = applicationId;
            
            coApplicantParty.clcommon__Type__c = mapOfpartyType.get(ExternalConstants.PRINCIPAL_PARTY);
            coApplicantParty.clcommon__Party_Types__c = ExternalConstants.PRINCIPAL_PARTY;

            coApplicantParty.Total_Assets__c = uniqueIdVsAssetsMap.get(principalContactObj.Account.Unique_Id__c);
            coApplicantParty.Total_Liabilities__c = uniqueIdVsLiabilitiesMap.get(principalContactObj.Account.Unique_Id__c);

            coApplicantParty.Gross_Farm_Income__c = uniqueIdVsGFIMap.get(principalContactObj.Account.Unique_Id__c);

            coApplicantParty.Dealer_Applicant_Relationship__c = conVsDealerApplicantMap.get(principalContactObj.Id).Id;

            coApplicantPartyList.add(coApplicantParty);
        }
        Database.insert(coApplicantPartyList, true);
    }


    /**
    * @description : crates a acontact for the principal
    * @author Krishanu Chinya | 07-10-2024 
    * @param paramMap 
    * @param paramListMap 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> populatePrincipalContactAndParty(Map<String,Map<String, Object>> paramMap,Map<String,List<Object>> paramListMap){

        Map<String, Object> principalDetailsMap=(Map<String, Object>) paramMap.get(ExternalConstants.PRINCIPAL_DETAIL_KEY);
        Map<String, Object> duplicatePrincipalMap=(Map<String, Object>)paramMap.get(ExternalConstants.DUPLICATE_DETAILS_KEY);
        List<String> duplicateContactIdList=(List<String>)paramListMap.get(ExternalConstants.DUPLICATE_CONTACT_ID_KEY);
        List<Contact> principalContactList=(List<Contact>)paramListMap.get(ExternalConstants.PRINCIPAL_CONTACT_KEY);

        Contact principalContactObj;
        clcommon__Party__c principalParty;

        if(duplicatePrincipalMap.get(DUPLICATE_FOUND)==true){
            principalContactObj = (Contact)duplicatePrincipalMap.get(CONTACT_KEY);
            
            principalContactObj.Email = ExternalApplicationOriginationUtil.assignValuesAfterKycCheck(principalContactObj.Account.Kyc_Verified__c, principalContactObj.Email, String.valueOf(principalDetailsMap.get(ExternalConstants.EMAIL_KEY)));
            principalContactObj.Confirm_Email__c = ExternalApplicationOriginationUtil.assignValuesAfterKycCheck(principalContactObj.Account.Kyc_Verified__c, principalContactObj.Confirm_Email__c, String.valueOf(principalDetailsMap.get(ExternalConstants.CONFIRM_EMAIL_KEY)));
            principalContactObj.Confirm_SSN__c = ExternalApplicationOriginationUtil.assignValuesAfterKycCheck(principalContactObj.Account.Kyc_Verified__c, principalContactObj.Confirm_SSN__c, String.valueOf(principalDetailsMap.get(ExternalConstants.CONFIRM_SSN_KEY)));

            principalContactObj.MobilePhone = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactObj.MobilePhone, String.valueOf(principalDetailsMap.get(ExternalConstants.WORK_PHONE_KEY)));
            principalContactObj.HomePhone = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactObj.HomePhone, String.valueOf(principalDetailsMap.get(ExternalConstants.HOME_PHONE_KEY)));
            principalContactObj.Phone = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactObj.Phone, String.valueOf(principalDetailsMap.get(ExternalConstants.PHONE_NUMBER_KEY)));

            principalContactObj.MailingStreet = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactObj.MailingStreet, String.valueOf(principalDetailsMap.get(ExternalConstants.STREET_KEY)));
            principalContactObj.MailingCity = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactObj.MailingCity, String.valueOf(principalDetailsMap.get(ExternalConstants.CITY_KEY)));
            principalContactObj.MailingState = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactObj.MailingState, String.valueOf(principalDetailsMap.get(ExternalConstants.STATE_KEY)));
            principalContactObj.MailingPostalCode = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactObj.MailingPostalCode, String.valueOf(principalDetailsMap.get(ExternalConstants.POSTAL_CODE_KEY)));
            principalContactObj.Mailing_County__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactObj.Mailing_County__c, String.valueOf(principalDetailsMap.get(ExternalConstants.COUNTY_KEY)));
            principalContactObj.Suffix__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactObj.Suffix__c, String.valueOf(principalDetailsMap.get(ExternalConstants.SUFFIX_KEY)));
            principalContactObj.clcommon__Marital_Status__c = ExternalApplicationOriginationUtil.assignMaritalStatus(principalContactObj.clcommon__Marital_Status__c, String.valueOf(principalDetailsMap.get(ExternalConstants.MARITAL_STATUS_KEY)));
            principalContactObj.Title = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactObj.Title, String.valueOf(principalDetailsMap.get(ExternalConstants.TITLE_KEY)));

            ExternalApplicationCreationHandler.populateMiddleNameOfCoApplicant(principalContactObj,duplicatePrincipalMap,principalDetailsMap);


            if(principalContactObj.Birthdate == null && !principalContactObj.Account.Kyc_Verified__c){
                principalContactObj.Birthdate = Date.valueOf(String.valueOf(principalDetailsMap.get(ExternalConstants.BIRTHDATE_KEY)));
            }
            duplicateContactIdList.add(principalContactObj.Id);
        }else{
            principalContactObj = new Contact();
            principalContactObj.FirstName = String.valueOf(principalDetailsMap.get(ExternalConstants.FIRST_NAME_KEY));
            principalContactObj.LastName = String.valueOf(principalDetailsMap.get(ExternalConstants.LAST_NAME_KEY));
            principalContactObj.ints__middle_name__c = String.valueOf(principalDetailsMap.get(ExternalConstants.MIDDLE_NAME_KEY));

            principalContactObj.Email = String.valueOf(principalDetailsMap.get(ExternalConstants.EMAIL_KEY));
            principalContactObj.Confirm_Email__c = String.valueOf(principalDetailsMap.get(ExternalConstants.CONFIRM_EMAIL_KEY));
            principalContactObj.genesis__SSN__c = String.valueOf(principalDetailsMap.get(ExternalConstants.SSN_KEY));
            principalContactObj.Confirm_SSN__c = String.valueOf(principalDetailsMap.get(ExternalConstants.CONFIRM_SSN_KEY));
            principalContactObj.MobilePhone = String.valueOf(principalDetailsMap.get(ExternalConstants.WORK_PHONE_KEY));
            principalContactObj.HomePhone = String.valueOf(principalDetailsMap.get(ExternalConstants.HOME_PHONE_KEY));
            principalContactObj.Phone = String.valueOf(principalDetailsMap.get(ExternalConstants.PHONE_NUMBER_KEY));

            //populating address
            principalContactObj.MailingStreet = String.valueOf(principalDetailsMap.get(ExternalConstants.STREET_KEY));
            principalContactObj.MailingCity = String.valueOf(principalDetailsMap.get(ExternalConstants.CITY_KEY));
            principalContactObj.MailingState = String.valueOf(principalDetailsMap.get(ExternalConstants.STATE_KEY));
            principalContactObj.MailingPostalCode = String.valueOf(principalDetailsMap.get(ExternalConstants.POSTAL_CODE_KEY));
            principalContactObj.Mailing_County__c = String.valueOf(principalDetailsMap.get(ExternalConstants.COUNTY_KEY));

            principalContactObj.Suffix__c = String.valueOf(principalDetailsMap.get(ExternalConstants.SUFFIX_KEY));
            principalContactObj.Birthdate = Date.valueOf(String.valueOf(principalDetailsMap.get(ExternalConstants.BIRTHDATE_KEY)));
            principalContactObj.clcommon__Marital_Status__c = String.valueOf(principalDetailsMap.get(ExternalConstants.MARITAL_STATUS_KEY));
            principalContactObj.Title = String.valueOf(principalDetailsMap.get(ExternalConstants.TITLE_KEY));
        }
        ExternalApplicationValidationUtil.validateApplicantContactInfo(principalContactObj);

        principalContactList.add(principalContactObj);

        principalParty=ExternalApplicationCreationHandler.populateNewPartyDetails(principalDetailsMap);
        return new Map<String,Object>{
            ExternalConstants.PRINCIPAL_CONTACT_KEY=>principalContactObj,
            ExternalConstants.PRINCIPAL_PARTY_KEY=>principalParty
        };
    }

   
    /**
    * @description : creates a account for the principal
    * @author Krishanu Chinya | 07-10-2024 
    * @param principalDetailsMap 
    * @param duplicatePrincipalMap 
    * @param accVsDuplicateBusinessMap 
    * @return Account 
    **/
    private static Account populatePrincipalAccount (Map<String, Object> principalDetailsMap,Map<String, Object> duplicatePrincipalMap, Map<String,Id> accVsDuplicateBusinessMap){
        Account principalAccountObj;

        if(duplicatePrincipalMap.get(DUPLICATE_FOUND)==true){
            principalAccountObj = (Account)duplicatePrincipalMap.get(ACC_KEY);

            principalAccountObj.clcommon__Email__c = ExternalApplicationOriginationUtil.assignValuesAfterKycCheck(principalAccountObj.Kyc_Verified__c, principalAccountObj.clcommon__Email__c, String.valueOf(principalDetailsMap.get(ExternalConstants.EMAIL_KEY)));
            principalAccountObj.Confirm_Email__c = ExternalApplicationOriginationUtil.assignValuesAfterKycCheck(principalAccountObj.Kyc_Verified__c, principalAccountObj.Confirm_Email__c, String.valueOf(principalDetailsMap.get(ExternalConstants.EMAIL_KEY)));

            principalAccountObj.Phone = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalAccountObj.Phone, String.valueOf(principalDetailsMap.get(ExternalConstants.PHONE_NUMBER_KEY)));
            principalAccountObj.Work_Number__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalAccountObj.Work_Number__c, String.valueOf(principalDetailsMap.get(ExternalConstants.WORK_PHONE_KEY)));
            principalAccountObj.Home_Number__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalAccountObj.Home_Number__c, String.valueOf(principalDetailsMap.get(ExternalConstants.HOME_PHONE_KEY)));

            principalAccountObj.BillingStreet = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalAccountObj.BillingStreet, String.valueOf(principalDetailsMap.get(ExternalConstants.STREET_KEY)));
            principalAccountObj.BillingCity = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalAccountObj.BillingCity, String.valueOf(principalDetailsMap.get(ExternalConstants.CITY_KEY)));
            principalAccountObj.BillingState = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalAccountObj.BillingState, String.valueOf(principalDetailsMap.get(ExternalConstants.STATE_KEY)));
            principalAccountObj.BillingPostalCode = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalAccountObj.BillingPostalCode, String.valueOf(principalDetailsMap.get(ExternalConstants.POSTAL_CODE_KEY)));
            principalAccountObj.Billing_County__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalAccountObj.Billing_County__c, String.valueOf(principalDetailsMap.get(ExternalConstants.COUNTY_KEY)));

            principalAccountObj.Year_Began_Farming__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalAccountObj.Year_Began_Farming__c, String.valueOf(principalDetailsMap.get(ExternalConstants.YEAR_BEGAN_FARMING_KEY)));
        }else{
            principalAccountObj = new Account();
            
            principalAccountObj.Name = String.valueOf(principalDetailsMap.get(ExternalConstants.LAST_NAME_KEY)) 
                                            + ExternalConstants.COMMA_STRING 
                                            + ExternalConstants.SPACE_STRING 
                                            + String.valueOf(principalDetailsMap.get(ExternalConstants.FIRST_NAME_KEY));

            if(!String.isBlank(String.valueOf(principalDetailsMap.get(ExternalConstants.MIDDLE_NAME_KEY)))){
                principalAccountObj.Name = principalAccountObj.Name
                                                + ExternalConstants.SPACE_STRING 
                                                + String.valueOf(principalDetailsMap.get(ExternalConstants.MIDDLE_NAME_KEY));
            }

            principalAccountObj.clcommon__Email__c = String.valueOf(principalDetailsMap.get(ExternalConstants.EMAIL_KEY));
            principalAccountObj.Confirm_Email__c = String.valueOf(principalDetailsMap.get(ExternalConstants.CONFIRM_EMAIL_KEY));
            principalAccountObj.Phone = String.valueOf(principalDetailsMap.get(ExternalConstants.PHONE_NUMBER_KEY));
            principalAccountObj.Work_Number__c = String.valueOf(principalDetailsMap.get(ExternalConstants.WORK_PHONE_KEY));
            principalAccountObj.Home_Number__c = String.valueOf(principalDetailsMap.get(ExternalConstants.HOME_PHONE_KEY));

            //populating address
            principalAccountObj.BillingStreet = String.valueOf(principalDetailsMap.get(ExternalConstants.STREET_KEY));
            principalAccountObj.BillingCity = String.valueOf(principalDetailsMap.get(ExternalConstants.CITY_KEY));
            principalAccountObj.BillingState = String.valueOf(principalDetailsMap.get(ExternalConstants.STATE_KEY));
            principalAccountObj.BillingPostalCode = String.valueOf(principalDetailsMap.get(ExternalConstants.POSTAL_CODE_KEY));
            principalAccountObj.Billing_County__c = String.valueOf(principalDetailsMap.get(ExternalConstants.COUNTY_KEY));

            principalAccountObj.Year_Began_Farming__c = String.valueOf(principalDetailsMap.get(ExternalConstants.YEAR_BEGAN_FARMING_KEY));
        }
        principalAccountObj.clcommon__Legal_Entity_Type__c = ExternalApplicationOriginationUtil.getLegalEntityByName(ExternalConstants.SOLE_PROP_ENTITY);
        principalAccountObj.ParentId = dealerForExtUser.Id; 
        principalAccountObj.Coop_type__c = dealerForExtUser.Coop_type__c; 
        ExternalApplicationCreationHandler.assignCoapplicantRecordType(principalAccountObj);

        principalAccountObj.OwnerId = ExternalSecurityUtil.getSiteAdmin(); 

        ExternalApplicationCreationHandler.checkForUniqueId(principalAccountObj, String.valueOf(principalDetailsMap.get(ExternalConstants.USER_ID_KEY)));

        if(((genesis__Business_Information__c)duplicatePrincipalMap.get(B_INFO_KEY)) != null){
            accVsDuplicateBusinessMap.put(principalAccountObj.Unique_Id__c, ((genesis__Business_Information__c)duplicatePrincipalMap.get(B_INFO_KEY)).Id);
        }

        return principalAccountObj;
    }
    

    /**
    * @description : fetches the primary coapplicant party
    * @author Krishanu Chinya | 06-12-2024 
    * @param applicationId 
    * @return clcommon__Party__c 
    **/
    private static clcommon__Party__c getFirstPrincipalParty(String applicationId){
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    Dealer_Applicant_Relationship__r.Has_Past_Due__c,
                                                    Dealer_Applicant_Relationship__r.Is_Non_Accrual__c,
                                                    clcommon__Contact__c,
                                                    clcommon__Account__c,
                                                    clcommon__Account__r.Unique_Id__c,
                                                    Work_Number__c,
                                                    Home_Number__c,
                                                    Mobile_Number__c,
                                                    Street__c,
                                                    City__c,
                                                    Postal_Code__c,
                                                    State__c,
                                                    County__c,
                                                    Marital_Status__c,
                                                    Title__c,
                                                    Suffix__c,
                                                    Total_Assets__c,
                                                    Total_Liabilities__c,
                                                    Gross_Farm_Income__c
                                            FROM clcommon__Party__c
                                            WHERE genesis__Application__c =: applicationId
                                            AND clcommon__Contact__c != null
                                            AND clcommon__Account__c != null
                                            AND clcommon__Type__r.Name =: ExternalConstants.PRINCIPAL_PARTY
                                            AND Principal_Number__c = 1 LIMIT 1];
        ExternalApplicationOriginationUtil.checkEmptyList(partyList, ExternalConstants.PRINCIPAL_NOT_FOUND);

        ExternalApplicationCreationHandler.checkForNonAccrualOrPastDueParty(partyList[0]);

        return partyList[0];

    }

    /**
    * @description : populates fields in borrower account, contact and party
    * @author Krishanu Chinya | 05-30-2024 
    * @param firstPrincipalParty 
    * @param principalDetailsMap 
    **/
    private static void populateFirstPrincipalData(clcommon__Party__c firstPrincipalParty, Map<String, Object> principalDetailsMap){
        List<Account> principalAccountList = [SELECT Id,
                                                        Name,
                                                        clcommon__Email__c,
                                                        Confirm_Email__C,
                                                        Work_Number__c,
                                                        Home_Number__c,
                                                        Phone,
                                                        Year_Began_Farming__c,
                                                        genesis__Business_Information__c,
                                                        Kyc_Verified__c 
                                                FROM Account
                                                WHERE Id =: firstPrincipalParty.clcommon__Account__c];
        ExternalApplicationOriginationUtil.checkEmptyList(principalAccountList, ExternalConstants.PRINCIPAL_NOT_FOUND);

        List<Contact> principalContactList = [SELECT Id, 
                                                        Name,
                                                        Email,
                                                        Confirm_Email__c,
                                                        MobilePhone,
                                                        HomePhone,
                                                        Phone,
                                                        MailingStreet,
                                                        MailingCity,
                                                        MailingState,
                                                        MailingPostalCode,
                                                        Mailing_County__c,
                                                        Suffix__c,
                                                        Birthdate,
                                                        clcommon__Marital_Status__c,
                                                        Title,
                                                        ints__middle_name__c
                                                FROM Contact 
                                                WHERE Id =: firstPrincipalParty.clcommon__Contact__c];
        ExternalApplicationOriginationUtil.checkEmptyList(principalContactList, ExternalConstants.PRINCIPAL_NOT_FOUND);

        //populate email
        if(String.isBlank(principalContactList[0].Email) & !principalAccountList[0].Kyc_Verified__c){
            principalContactList[0].Email = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactList[0].Email, String.valueOf(principalDetailsMap.get(ExternalConstants.EMAIL_KEY)));
            principalContactList[0].Confirm_Email__C = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactList[0].Confirm_Email__C, String.valueOf(principalDetailsMap.get(ExternalConstants.EMAIL_KEY)));

            principalAccountList[0].clcommon__Email__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalAccountList[0].clcommon__Email__c, String.valueOf(principalDetailsMap.get(ExternalConstants.EMAIL_KEY)));
            principalAccountList[0].Confirm_Email__C = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalAccountList[0].Confirm_Email__C, String.valueOf(principalDetailsMap.get(ExternalConstants.EMAIL_KEY)));
        }

        if(String.isBlank(principalContactList[0].MobilePhone)){
            principalContactList[0].MobilePhone = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactList[0].MobilePhone, String.valueOf(principalDetailsMap.get(ExternalConstants.WORK_PHONE_KEY)));
            principalAccountList[0].Work_Number__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalAccountList[0].Work_Number__c, String.valueOf(principalDetailsMap.get(ExternalConstants.WORK_PHONE_KEY)));
        }

        if(String.isBlank(principalContactList[0].HomePhone)){
            principalContactList[0].HomePhone = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactList[0].HomePhone, String.valueOf(principalDetailsMap.get(ExternalConstants.HOME_PHONE_KEY)));
            principalAccountList[0].Home_Number__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalAccountList[0].Home_Number__c, String.valueOf(principalDetailsMap.get(ExternalConstants.HOME_PHONE_KEY)));
        }

        if(String.isBlank(principalContactList[0].Phone)){
            principalContactList[0].Phone = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactList[0].Phone, String.valueOf(principalDetailsMap.get(ExternalConstants.PHONE_NUMBER_KEY)));
            principalAccountList[0].Phone = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalAccountList[0].Phone, String.valueOf(principalDetailsMap.get(ExternalConstants.PHONE_NUMBER_KEY)));
        }

        if(!String.isBlank(String.valueOf(principalDetailsMap.get(ExternalConstants.MIDDLE_NAME_KEY))) & String.isBlank(principalContactList[0].ints__middle_name__c) & !principalAccountList[0].Kyc_Verified__c){
            principalContactList[0].ints__middle_name__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactList[0].ints__middle_name__c, String.valueOf(principalDetailsMap.get(ExternalConstants.MIDDLE_NAME_KEY)));

            principalAccountList[0].Name = principalAccountList[0].Name
                                            + ExternalConstants.SPACE_STRING 
                                            + principalContactList[0].ints__middle_name__c;
        }

        //populating address
        principalContactList[0].MailingStreet = principalAccountList[0].BillingStreet = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactList[0].MailingStreet, String.valueOf(principalDetailsMap.get(ExternalConstants.STREET_KEY)));
        principalContactList[0].MailingCity = principalAccountList[0].BillingCity = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactList[0].MailingCity ,String.valueOf(principalDetailsMap.get(ExternalConstants.CITY_KEY)));
        principalContactList[0].MailingState = principalAccountList[0].BillingState = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactList[0].MailingState ,String.valueOf(principalDetailsMap.get(ExternalConstants.STATE_KEY)));
        principalContactList[0].MailingPostalCode = principalAccountList[0].BillingPostalCode = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactList[0].MailingPostalCode ,String.valueOf(principalDetailsMap.get(ExternalConstants.POSTAL_CODE_KEY)));
        principalContactList[0].Mailing_County__c = principalAccountList[0].Billing_County__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactList[0].Mailing_County__c ,String.valueOf(principalDetailsMap.get(ExternalConstants.COUNTY_KEY)));


        List<genesis__Business_Information__c> principalBusinessInfoList = [SELECT Id,
                                                                                   genesis__Total_Assets__c,
                                                                                   genesis__Total_Liabilities__c,
                                                                                   Gross_Farm_Income__c
                                                                                FROM genesis__Business_Information__c
                                                                                WHERE Id =: principalAccountList[0].genesis__Business_Information__c];
        principalBusinessInfoList[0].genesis__Total_Assets__c = ExternalApplicationOriginationUtil.assignDecimalValueIfEmpty(principalBusinessInfoList[0].genesis__Total_Assets__c,Integer.valueOf(principalDetailsMap.get(ExternalConstants.TOTAL_ASSETS_KEY)));
        principalBusinessInfoList[0].genesis__Total_Liabilities__c = ExternalApplicationOriginationUtil.assignDecimalValueIfEmpty(principalBusinessInfoList[0].genesis__Total_Liabilities__c,Integer.valueOf(principalDetailsMap.get(ExternalConstants.TOTAL_LIABILITIES_KEY)));
        principalBusinessInfoList[0].Gross_Farm_Income__c = ExternalApplicationOriginationUtil.assignDecimalValueIfEmpty(principalBusinessInfoList[0].Gross_Farm_Income__c, Integer.valueOf(principalDetailsMap.get(ExternalConstants.GROSS_FARM_INCOME_KEY)));
        Database.upsert(principalBusinessInfoList[0], true);

        principalAccountList[0].Year_Began_Farming__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalAccountList[0].Year_Began_Farming__c,String.valueOf(principalDetailsMap.get(ExternalConstants.YEAR_BEGAN_FARMING_KEY)));

        principalContactList[0].Suffix__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactList[0].Suffix__c,String.valueOf(principalDetailsMap.get(ExternalConstants.SUFFIX_KEY)));

        if(principalContactList[0].Birthdate == null & !principalAccountList[0].Kyc_Verified__c){
            principalContactList[0].Birthdate = Date.valueOf(String.valueOf(principalDetailsMap.get(ExternalConstants.BIRTHDATE_KEY)));
        }

        principalContactList[0].clcommon__Marital_Status__c = ExternalApplicationOriginationUtil.assignMaritalStatus(principalContactList[0].clcommon__Marital_Status__c, String.valueOf(principalDetailsMap.get(ExternalConstants.MARITAL_STATUS_KEY)));
        principalContactList[0].Title = ExternalApplicationOriginationUtil.assignValueIfEmpty(principalContactList[0].Title, String.valueOf(principalDetailsMap.get(ExternalConstants.TITLE_KEY)));

        //populating party details of the principal
        populateFirstPrincipalParty(firstPrincipalParty,principalDetailsMap);
        ExternalApplicationValidationUtil.validatePartyContactInfo(principalContactList[0],firstPrincipalParty);
        
        Database.update(principalContactList[0], true);
        Database.update(principalAccountList[0], true);

    }

    /**
    * @description : Method to get contact vs dealer applicant relationship
    * @author Suraj Kumar | 12-11-2024 
    * @param duplicateContactIdList 
    * @param principalContactList 
    * @return Map<String, Dealer_Applicant_Relationship__c> 
    **/
    private static Map<String,Dealer_Applicant_Relationship__c> getDealerApplicantRelationship(List<String> duplicateContactIdList, List<Contact> principalContactList){
        Map<String,Dealer_Applicant_Relationship__c> conVsDealerApplicantMap = new Map<String,Dealer_Applicant_Relationship__c>();
        Map<String,Dealer_Applicant_Relationship__c> conIdVsExistingDRMap = new Map<String,Dealer_Applicant_Relationship__c>();
        List<Dealer_Applicant_Relationship__c> newDealerApplicantList = new List<Dealer_Applicant_Relationship__c>();

        if(!duplicateContactIdList.isEmpty()){
            List<Dealer_Applicant_Relationship__c> dealerApplicantRelList = [SELECT Id,
                                                                                    Applicant_Contact__c,
                                                                                    Has_Past_Due__c,
                                                                                    Is_Non_Accrual__c
                                                                                FROM Dealer_Applicant_Relationship__c
                                                                                WHERE Applicant_Contact__c IN :duplicateContactIdList
                                                                                AND Dealer__c= :dealerForExtUser.Id];
            for(Dealer_Applicant_Relationship__c existingDRObj: dealerApplicantRelList){
                if(existingDRObj.Has_Past_Due__c == true){
                    throw new CustomException(ExternalConstants.PAST_DUE_APPLICANT_EXCEPTION);
                }
                if(existingDRObj.Is_Non_Accrual__c == true){
                    throw new CustomException(ExternalConstants.NON_ACCRUAL_APPLICANT_EXCEPTION);
                }
                conIdVsExistingDRMap.put(existingDRObj.Applicant_Contact__c,existingDRObj);
            }
        }
        for(Contact principalContactObj: principalContactList){
            if(conIdVsExistingDRMap.containsKey(principalContactObj.Id)){
                conVsDealerApplicantMap.put(principalContactObj.Id,conIdVsExistingDRMap.get(principalContactObj.Id));
            } else{
                Dealer_Applicant_Relationship__c dealerApplicantRelObj = new Dealer_Applicant_Relationship__c();
                dealerApplicantRelObj.Applicant__c = principalContactObj.AccountId;
                dealerApplicantRelObj.Applicant_Contact__c = principalContactObj.Id;
                dealerApplicantRelObj.Dealer__c = dealerForExtUser.Id;
                newDealerApplicantList.add(dealerApplicantRelObj);
            }
        }
        if(!newDealerApplicantList.isEmpty()){
            Database.insert(newDealerApplicantList,true);

            for(Dealer_Applicant_Relationship__c dealerApplicantRelObj: newDealerApplicantList){
                conVsDealerApplicantMap.put(dealerApplicantRelObj.Applicant_Contact__c,dealerApplicantRelObj);
            }
        }
        return conVsDealerApplicantMap;
    }

    /**
    * @description : setting up the success response for this class
    * @author Suraj Kumar | 12-11-2024 
    * @param response 
    **/
    private static void setSuccessResponse(RestResponse response){
        Map<String, Object> bodyMap = new Map<String, Object>{
            ExternalConstants.MESSAGE_KEY => ExternalConstants.RECORD_CREATED_VALUE
        };
        Map<String, Object> contentMap = new Map<String, Object>{
            ExternalConstants.BODY_KEY => bodyMap
        };
        Map<String, Object> responseMap = new Map<String, Object>{
            ExternalConstants.CONTENT_KEY => contentMap,
            ExternalConstants.STATUS_KEY => ExternalConstants.SUCCESS_VALUE
        };
        response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
        response.statusCode = ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE;
    }
    /**
    * @description : populate the first principal party details
    * @author Suraj Kumar | 12-11-2024 
    * @param firstPrincipalParty 
    * @param principalDetailsMap 
    **/
    private static void populateFirstPrincipalParty(clcommon__Party__c firstPrincipalParty,Map<String, Object> principalDetailsMap){

        firstPrincipalParty.Total_Assets__c = ExternalApplicationOriginationUtil.assignDecimalValueIfEmpty(firstPrincipalParty.Total_Assets__c, Integer.valueOf(principalDetailsMap.get(ExternalConstants.TOTAL_ASSETS_KEY)));
        firstPrincipalParty.Total_Liabilities__c = ExternalApplicationOriginationUtil.assignDecimalValueIfEmpty(firstPrincipalParty.Total_Liabilities__c, Integer.valueOf(principalDetailsMap.get(ExternalConstants.TOTAL_LIABILITIES_KEY)));

        firstPrincipalParty.Work_Number__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(firstPrincipalParty.Work_Number__c, String.valueOf(principalDetailsMap.get(ExternalConstants.WORK_PHONE_KEY)));
        firstPrincipalParty.Home_Number__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(firstPrincipalParty.Home_Number__c, String.valueOf(principalDetailsMap.get(ExternalConstants.HOME_PHONE_KEY)));
        firstPrincipalParty.Mobile_Number__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(firstPrincipalParty.Mobile_Number__c, String.valueOf(principalDetailsMap.get(ExternalConstants.PHONE_NUMBER_KEY)));

        firstPrincipalParty.Street__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(firstPrincipalParty.Street__c, String.valueOf(principalDetailsMap.get(ExternalConstants.STREET_KEY)));
        firstPrincipalParty.City__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(firstPrincipalParty.City__c, String.valueOf(principalDetailsMap.get(ExternalConstants.CITY_KEY)));
        firstPrincipalParty.State__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(firstPrincipalParty.State__c, String.valueOf(principalDetailsMap.get(ExternalConstants.STATE_KEY)));
        firstPrincipalParty.Postal_Code__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(firstPrincipalParty.Postal_Code__c, String.valueOf(principalDetailsMap.get(ExternalConstants.POSTAL_CODE_KEY)));
        firstPrincipalParty.County__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(firstPrincipalParty.County__c, String.valueOf(principalDetailsMap.get(ExternalConstants.COUNTY_KEY)));

        firstPrincipalParty.Gross_Farm_Income__c = ExternalApplicationOriginationUtil.assignDecimalValueIfEmpty(firstPrincipalParty.Gross_Farm_Income__c, Integer.valueOf(principalDetailsMap.get(ExternalConstants.GROSS_FARM_INCOME_KEY)));

        firstPrincipalParty.Suffix__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(firstPrincipalParty.Suffix__c, String.valueOf(principalDetailsMap.get(ExternalConstants.SUFFIX_KEY)));
        firstPrincipalParty.Marital_Status__c = ExternalApplicationOriginationUtil.assignMaritalStatus(firstPrincipalParty.Marital_Status__c, String.valueOf(principalDetailsMap.get(ExternalConstants.MARITAL_STATUS_KEY)));
        firstPrincipalParty.Title__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(firstPrincipalParty.Title__c, String.valueOf(principalDetailsMap.get(ExternalConstants.TITLE_KEY)));
        Database.update(firstPrincipalParty, true);
    }
}