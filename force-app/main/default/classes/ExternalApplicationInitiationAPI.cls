/**
 * @description       : purpose of this class is to initiate an application for the external apis
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 04-08-2025
 * @last modified by  : Ayush Kumar Singh
**/
@RestResource(urlMapping = '/api/v1/external/initiateApplication')
global without sharing class ExternalApplicationInitiationAPI {
    private static final String CLASS_NAME = ExternalApplicationInitiationAPI.class.getName();
    private static final String APP_ID = 'applicationId';
    private static final String DUPLICATE_FOUND = 'duplicateFound';
    private static final String ACCOUNT_KEY = 'Account';
    private static final String CONTACT_KEY = 'Contact';
    private static final String BUSINESS_INFO_KEY = 'BusinessInfo';

    static genesis__Applications__c newApplicationObj = new genesis__Applications__c();
    static Account borrowerAccountObj;
    static Contact borrowerContactObj;
    static Account principalAccountObj = new Account();
    static Contact principalContactObj;
    static genesis__Business_Information__c borrowerBusinessInfoObj = new genesis__Business_Information__c();
    static genesis__Business_Information__c principalBusinessInfoObj = new genesis__Business_Information__c();


    static Map<String, SObject> relatedObjectsMap = new Map<String, SObject>();
    static Map<String, Object> responseMap = new Map<String, Object>();
    static Map<String,Object> appIdMapForFlowParam = new Map<String,Object>();
    static Account dealerAccountForExtUser;
    static Dealer_Applicant_Relationship__c borrowerDealerRelationObj = new Dealer_Applicant_Relationship__c();
    static Dealer_Applicant_Relationship__c principalDealerRelObj = new Dealer_Applicant_Relationship__c();

    /**
    * @description : http post method to initiate an application
    * @author Krishanu Chinya | 05-17-2024 
    **/
    @HttpPost
    global static void doInitiateNewApplication(){
        Map<String, Object> contentMap = new Map<String, Object>();
        Map<String, Object> bodyMap = new Map<String, Object>();
        Map<String, Object> applicationMap = new Map<String, Object>();
        Map<String, Object> borrowerMap = new Map<String, Object>();
        Map<String, Object> principalMap = new Map<String, Object>();
        RestResponse response = RestContext.response;

        SavePoint dbSavePoint = Database.setSavepoint();
        try{
            RestRequest requestParam = RestContext.request;
            response.addHeader(ExternalConstants.CONTENT_TYPE, ExternalConstants.APPLICATION_JSON);

            String requestBody = requestParam.requestBody.toString();
            ExternalApplicationOriginationUtil.checkForBlankParameter(requestBody);
            Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(requestBody);
            ExternalApplicationValidationUtil.validateApplicationData(requestMap);

            Map<String,Object> applicationDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.APPLICATION_DETAIL_KEY);
            Map<String,Object> borrowerDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.BORROWER_DETAIL_KEY);
            Map<String,Object> principalDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.PRINCIPAL_DETAIL_KEY);

            Map<String,Object> dealerDetailsMap = (Map<String,Object>) requestParam.headers;
            ExternalApplicationOriginationUtil.checkForNullObject(dealerDetailsMap, ExternalConstants.DEALER_DETAILS_MISSING);  
            dealerAccountForExtUser = ExternalApplicationValidationUtil.validateDealerDetails(dealerDetailsMap);
            

            ExternalApplicationValidationUtil.checkForValidLegalEntityType(String.valueOf(borrowerDetailsMap.get(ExternalConstants.ENTITY_TYPE)));
            String legalEntityType = String.valueOf(borrowerDetailsMap.get(ExternalConstants.ENTITY_TYPE));

            newApplicationObj.genesis__Loan_Amount__c = Double.valueOf(applicationDetailsMap.get(ExternalConstants.LOAN_AMOUNT_KEY));
            newApplicationObj.Is_External_Application__c = true;
            ExternalApplicationCreationHandler.addDefaultValuesToApplication(newApplicationObj);

            Map<String,Object> duplicateBorrowerMap;
            
            duplicateBorrowerMap = checkForDuplicates(legalEntityType, borrowerDetailsMap);

            borrowerAccountObj = populateAccountDetails(borrowerDetailsMap, duplicateBorrowerMap);
            borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ExternalConstants.GROWER_PROFILE).getRecordTypeId();
            borrowerContactObj = populateContactDetails(borrowerDetailsMap, duplicateBorrowerMap);
            if(duplicateBorrowerMap.get(DUPLICATE_FOUND) == true){
                borrowerBusinessInfoObj = (genesis__Business_Information__c)duplicateBorrowerMap.get(BUSINESS_INFO_KEY);
            }else { 
                createBusinessInfo(borrowerAccountObj,borrowerBusinessInfoObj,borrowerDetailsMap);
            }  
            
            Map<String,Object> duplicatePrincipalMap;
            if(legalEntityType != ExternalConstants.SOLE_PROP_ENTITY){
                //duplicate check for coapplicant
                borrowerAccountObj.Is_Individual__c = false;
                String ssn = String.valueOf(principalDetailsMap.get(ExternalConstants.SSN_KEY));
                duplicatePrincipalMap = ExternalValidationUtil.validateDuplicateIndividual(ssn);

                principalDetailsMap.put(ExternalConstants.ENTITY_TYPE, ExternalConstants.SOLE_PROP_ENTITY);
                principalAccountObj = populateAccountDetails(principalDetailsMap, duplicatePrincipalMap);
                ExternalApplicationCreationHandler.assignCoapplicantRecordType(principalAccountObj);

                principalContactObj = populateContactDetails(principalDetailsMap, duplicatePrincipalMap);
                if(duplicateBorrowerMap.get(DUPLICATE_FOUND) == true){
                    principalBusinessInfoObj = (genesis__Business_Information__c)duplicatePrincipalMap.get(BUSINESS_INFO_KEY);
                }else { 
                    createBusinessInfo(principalAccountObj,principalBusinessInfoObj,principalDetailsMap);
                }  

            }
            newApplicationObj = createNewApplication(legalEntityType);
            ExternalApplicationOriginationUtil.checkForFirstApplication(newApplicationObj, borrowerAccountObj.Id);
            Map<String,String> identifierMap = ExternalApplicationCreationHandler.getIdentifierMap(borrowerAccountObj.Id, dealerAccountForExtUser.id);
            newApplicationObj.Unique_Identifier__c = identifierMap.get('uniqueId');
            newApplicationObj.Internal_Reference_Code__c = identifierMap.get('irc');
            
            ExternalApplicationCreationHandler.linkDealerPartyToApplication(newApplicationObj,dealerAccountForExtUser);

            borrowerDealerRelationObj = getApplicantDealerRelationship(new Map<String,Object>{
                ExternalConstants.APPLICANT_ACCOUNT => borrowerAccountObj,
                ExternalConstants.APPLICANT_CONTACT => borrowerContactObj,
                ExternalConstants.DEALER_ACCOUNT => dealerAccountForExtUser}, duplicateBorrowerMap);

            if(legalEntityType != ExternalConstants.SOLE_PROP_ENTITY){
                //assign CIF to co-appliacant
                assignCoApplicantCif(principalDetailsMap,duplicatePrincipalMap);
            }

            ExternalApplicationCreationHandler.updateBorrowerDetails(newApplicationObj, borrowerDetailsMap, borrowerDealerRelationObj);

            ExternalApplicationCreationHandler.checkForNonAccrualAndPastDue(newApplicationObj.id);

            Flow.Interview.Update_Dealer_Limits_On_Creation callFlow;
            appIdMapForFlowParam.put(APP_ID,newApplicationObj.Id);
            callFlow = new Flow.Interview.Update_Dealer_Limits_On_Creation(appIdMapForFlowParam);
            callFlow.start();  

            ExternalApplicationCreationHandler.createTasks(newApplicationObj.Id);
            newApplicationObj.Dealer_Applicant_Relationship__c = borrowerDealerRelationObj.Id;
            Database.update(newApplicationObj,true);
            

            responseMap.put(ExternalConstants.STATUS_KEY, ExternalConstants.SUCCESS_VALUE);
            

            applicationMap.put(ExternalConstants.ID_KEY, newApplicationObj.Id);
            borrowerMap.put(ExternalConstants.ID_KEY, borrowerAccountObj.Id);
            principalMap.put(ExternalConstants.ID_KEY, principalAccountObj.Id);

            bodyMap.put(ExternalConstants.APPLICATION_KEY, applicationMap);
            bodyMap.put(ExternalConstants.BORROWER_DETAIL_KEY, borrowerMap);
            bodyMap.put(ExternalConstants.PRINCIPAL_DETAIL_KEY, principalMap);
            
            contentMap.put(ExternalConstants.BODY_KEY, bodyMap);
            responseMap.put(ExternalConstants.CONTENT_KEY, contentMap);

            response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
            response.statusCode = ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE;

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
    * @description 
    * @author Krishanu Chinya | 07-10-2024 
    * @param legalEntityType 
    * @param borrowerDetailsMap 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> checkForDuplicates(String legalEntityType, Map<String,Object> borrowerDetailsMap){
        Map<String,Object> duplicateBorrowerMap = new Map<String, Object>();
        duplicateBorrowerMap.put(DUPLICATE_FOUND, false);

        //sole prop
        if(legalEntityType == ExternalConstants.SOLE_PROP_ENTITY) {
            String ssn = String.valueOf(borrowerDetailsMap.get(ExternalConstants.SSN_KEY));
            duplicateBorrowerMap = ExternalValidationUtil.validateDuplicateIndividual(ssn);
        } 
        //company
        else if(legalEntityType != ExternalConstants.INDIVIDUAL_ENTITY) {
            //finding duplicate corp
            String taxId = String.valueOf(borrowerDetailsMap.get(ExternalConstants.TAX_ID_KEY));
            Id legalEntityTypeId = ExternalApplicationOriginationUtil.getLegalEntityByName(String.valueOf(borrowerDetailsMap.get(ExternalConstants.ENTITY_TYPE)));

            duplicateBorrowerMap = ExternalValidationUtil.validateDuplicateCorporation(taxId, legalEntityTypeId);
        } 
        return duplicateBorrowerMap;
    }
    
    /**
    * @description : populates account fields from the request map data
    * @author Krishanu Chinya | 07-10-2024 
    * @param paramMap 
    * @param duplicatesMap 
    * @return Account 
    **/
    private static Account populateAccountDetails(Map<String,Object> paramMap, Map<String, Object> duplicatesMap){
        Account accountObj;
        if(duplicatesMap.get(DUPLICATE_FOUND)==true){
            accountObj = (Account)duplicatesMap.get(ACCOUNT_KEY);
            accountObj.clcommon__Email__c = ExternalApplicationOriginationUtil.assignValuesAfterKycCheck(accountObj.Kyc_Verified__c, accountObj.clcommon__Email__c, String.valueOf(paramMap.get(ExternalConstants.EMAIL_KEY)));
            accountObj.Confirm_Email__c = ExternalApplicationOriginationUtil.assignValuesAfterKycCheck(accountObj.Kyc_Verified__c, accountObj.Confirm_Email__c, String.valueOf(paramMap.get(ExternalConstants.CONFIRM_EMAIL_KEY)));
            accountObj.Phone = ExternalApplicationOriginationUtil.assignValueIfEmpty(accountObj.Phone, String.valueOf(paramMap.get(ExternalConstants.PHONE_NUMBER_KEY)));
            accountObj.Work_Number__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(accountObj.Work_Number__c, String.valueOf(paramMap.get(ExternalConstants.WORK_PHONE_KEY)));
            accountObj.Home_Number__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(accountObj.Home_Number__c, String.valueOf(paramMap.get(ExternalConstants.HOME_PHONE_KEY)));

        }else{
            accountObj = new Account();
            if(String.valueOf(paramMap.get(ExternalConstants.ENTITY_TYPE)) == ExternalConstants.SOLE_PROP_ENTITY){
                accountObj.Name = String.valueOf(paramMap.get(ExternalConstants.LAST_NAME_KEY)) + ExternalConstants.COMMA_STRING + ExternalConstants.SPACE_STRING + String.valueOf(paramMap.get(ExternalConstants.FIRST_NAME_KEY));
            }else{
                accountObj.Name = String.valueOf(paramMap.get(ExternalConstants.NAME_KEY));
            }
            accountObj.clcommon__Legal_Entity_Type__c = ExternalApplicationOriginationUtil.getLegalEntityByName(String.valueOf(paramMap.get(ExternalConstants.ENTITY_TYPE)));
            accountObj.clcommon__Email__c = String.valueOf(paramMap.get(ExternalConstants.EMAIL_KEY));
            accountObj.Confirm_Email__c = String.valueOf(paramMap.get(ExternalConstants.CONFIRM_EMAIL_KEY));
            accountObj.Phone = String.valueOf(paramMap.get(ExternalConstants.PHONE_NUMBER_KEY));
            accountObj.Work_Number__c = String.valueOf(paramMap.get(ExternalConstants.WORK_PHONE_KEY));
            accountObj.Home_Number__c = String.valueOf(paramMap.get(ExternalConstants.HOME_PHONE_KEY));
    
        }

        ExternalApplicationCreationHandler.checkForUniqueId(accountObj, String.valueOf(paramMap.get(ExternalConstants.USER_ID_KEY)));
        
        accountObj.Coop_Type__c = dealerAccountForExtUser.Coop_Type__c;
        accountObj.ParentId = dealerAccountForExtUser.Id;

        ExternalApplicationCreationHandler.updateCifForAccount(accountObj, dealerAccountForExtUser.Coop_Type__c);
        return accountObj;
    }

    /**
    * @description :populates contact fields from the request map data 
    * @author Krishanu Chinya | 07-10-2024 
    * @param paramMap 
    * @param duplicatesMap 
    * @return Contact 
    **/
    private static Contact populateContactDetails(Map<String,Object> paramMap, Map<String, Object> duplicatesMap){
        Contact contactObj;
        if(duplicatesMap.get(DUPLICATE_FOUND) == true){
            contactObj = (Contact)duplicatesMap.get(CONTACT_KEY);
            contactObj.Email = ExternalApplicationOriginationUtil.assignValuesAfterKycCheck(contactObj.Account.Kyc_Verified__c, contactObj.Email, String.valueOf(paramMap.get(ExternalConstants.EMAIL_KEY)));
            contactObj.Confirm_Email__c = ExternalApplicationOriginationUtil.assignValuesAfterKycCheck(contactObj.Account.Kyc_Verified__c, contactObj.Confirm_Email__c, String.valueOf(paramMap.get(ExternalConstants.EMAIL_KEY)));
            contactObj.genesis__SSN__c = ExternalApplicationOriginationUtil.assignValuesAfterKycCheck(contactObj.Account.Kyc_Verified__c, contactObj.genesis__SSN__c, String.valueOf(paramMap.get(ExternalConstants.SSN_KEY)));
            contactObj.Confirm_SSN__c = ExternalApplicationOriginationUtil.assignValuesAfterKycCheck(contactObj.Account.Kyc_Verified__c, contactObj.Confirm_SSN__c, String.valueOf(paramMap.get(ExternalConstants.CONFIRM_SSN_KEY)));
            contactObj.MobilePhone = ExternalApplicationOriginationUtil.assignValueIfEmpty(contactObj.MobilePhone, String.valueOf(paramMap.get(ExternalConstants.PHONE_NUMBER_KEY)));
            contactObj.HomePhone = ExternalApplicationOriginationUtil.assignValueIfEmpty(contactObj.HomePhone, String.valueOf(paramMap.get(ExternalConstants.HOME_PHONE_KEY)));
            contactObj.Phone = ExternalApplicationOriginationUtil.assignValueIfEmpty(contactObj.Phone, String.valueOf(paramMap.get(ExternalConstants.WORK_PHONE_KEY)));

        }else{
            contactObj = new Contact();
            if(paramMap.get(ExternalConstants.ENTITY_TYPE) == ExternalConstants.SOLE_PROP_ENTITY){
                contactObj.FirstName = String.valueOf(paramMap.get(ExternalConstants.FIRST_NAME_KEY));
                contactObj.LastName = String.valueOf(paramMap.get(ExternalConstants.LAST_NAME_KEY));
            }else{
                contactObj.LastName = String.valueOf(paramMap.get(ExternalConstants.NAME_KEY));
            }
    
            contactObj.Email = String.valueOf(paramMap.get(ExternalConstants.EMAIL_KEY));
            contactObj.Confirm_Email__c = String.valueOf(paramMap.get(ExternalConstants.CONFIRM_EMAIL_KEY));
            contactObj.genesis__SSN__c = String.valueOf(paramMap.get(ExternalConstants.SSN_KEY));
            contactObj.Confirm_SSN__c = String.valueOf(paramMap.get(ExternalConstants.CONFIRM_SSN_KEY));
            contactObj.MobilePhone = String.valueOf(paramMap.get(ExternalConstants.PHONE_NUMBER_KEY));
            contactObj.HomePhone = String.valueOf(paramMap.get(ExternalConstants.HOME_PHONE_KEY));
            contactObj.Phone = String.valueOf(paramMap.get(ExternalConstants.WORK_PHONE_KEY));
        }

        return contactObj;
    }

    /**
    * @description : populates business info fields from the request map data
    * @author Krishanu Chinya | 05-17-2024 
    * @param paramMap 
    * @param duplicateBorrowerMap 
    **/
    private static void populateBusinessInfoDetails(Map<String,Object> paramMap, Map<string, Object> duplicateBorrowerMap){
        if(duplicateBorrowerMap.get(DUPLICATE_FOUND) == true){
            borrowerBusinessInfoObj = (genesis__Business_Information__c)duplicateBorrowerMap.get(BUSINESS_INFO_KEY);
        }else{
            borrowerBusinessInfoObj.genesis__Tax_Identification_Number__c = String.valueOf(paramMap.get(ExternalConstants.TAX_ID_KEY));
            borrowerBusinessInfoObj.Confirm_Tax_Identification_Number__c = String.valueOf(paramMap.get(ExternalConstants.CONFIRM_TAX_ID_KEY));
        }
    }
    /**
    * @description : calls the product api to create a new application
    * @author Krishanu Chinya | 05-17-2024 
    * @param legalEntity 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c createNewApplication(String legalEntity){
        relatedObjectsMap.put(ExternalConstants.GENESIS_ACCOUNT_KEY, borrowerAccountObj);
        relatedObjectsMap.put(ExternalConstants.GENESIS_BUSINESS_INFORMATION_KEY, borrowerBusinessInfoObj); 
        relatedObjectsMap.put(ExternalConstants.GENESIS_CONTACT_KEY, borrowerContactObj);

        genesis.BorrowerAPI5 saveAPI = genesis.APIFactory.getBorrowerAPI5();
        genesis__Applications__c appCreated = saveAPI.createApplication(newApplicationObj, relatedObjectsMap, 
                                                                        new Map<String, List<Map<String, String>>>(), 
                                                                        false);
                                                                        
        if(appCreated.Id==null){
            throw new CustomException(ExternalConstants.SOMETHING_WENT_WRONG);
        }
        return newApplicationObj;
    }

    /**
    * @description : method to assign cif to co applicant
    * @author Suraj Kumar | 09-11-2024 
    * @param paramMap 
    * @param duplicatePrincipalMap 
    **/
    private static void assignCoApplicantCif(Map<String,Object> paramMap, Map<String,Object> duplicatePrincipalMap){
        ExternalApplicationCreationHandler.updateCifForAccount(principalAccountObj, dealerAccountForExtUser.Coop_Type__c);
        principalContactObj.AccountId = principalAccountObj.Id;
        Database.upsert(principalContactObj, true);
        principalDealerRelObj = getApplicantDealerRelationship(new Map<String,Object>{
            ExternalConstants.APPLICANT_ACCOUNT => principalAccountObj,
            ExternalConstants.APPLICANT_CONTACT => principalContactObj,
            ExternalConstants.DEALER_ACCOUNT => dealerAccountForExtUser}, duplicatePrincipalMap);
        paramMap.put(ExternalConstants.PRINCIPAL_ACCOUNT_ID, principalAccountObj.Id);
        paramMap.put(ExternalConstants.PRINCIPAL_CONTACT_ID, principalContactObj.Id);
        ExternalApplicationCreationHandler.createPrincipalParty(newApplicationObj, paramMap, principalDealerRelObj);
    }

    /**
    * @description : Method to get the Dealer_Applicant_Relationship__c record
    * @author Suraj Kumar | 12-03-2024 
    * @param paramMap 
    * @param duplicatesMap 
    * @return Dealer_Applicant_Relationship__c 
    **/
    private static Dealer_Applicant_Relationship__c getApplicantDealerRelationship(Map<String,Object> paramMap, Map<String,Object> duplicatesMap){
        Account applicantAccounObj = (Account)paramMap.get(ExternalConstants.APPLICANT_ACCOUNT);
        Contact applicantContactObj = (Contact)paramMap.get(ExternalConstants.APPLICANT_CONTACT);
        Account dealerAccountObj = (Account)paramMap.get(ExternalConstants.DEALER_ACCOUNT);
        Dealer_Applicant_Relationship__c applicantDealerRelObj;
        if(duplicatesMap.get(DUPLICATE_FOUND)==true){
            List<Dealer_Applicant_Relationship__c> dealerApplicantRelList = [SELECT Id
                                                                                    FROM Dealer_Applicant_Relationship__c
                                                                                    WHERE Applicant_Contact__c= :applicantContactObj.Id
                                                                                    AND Applicant__c= :applicantAccounObj.Id
                                                                                    AND Dealer__c= :dealerAccountObj.Id];
            if(dealerApplicantRelList.size()>0){
                applicantDealerRelObj = dealerApplicantRelList[0];
            }
            else{
                applicantDealerRelObj = ExternalApplicationCreationHandler.createNewApplicantDealerRelationship(applicantAccounObj,applicantContactObj,dealerAccountObj);
            }
        }else{
            applicantDealerRelObj = ExternalApplicationCreationHandler.createNewApplicantDealerRelationship(applicantAccounObj,applicantContactObj,dealerAccountObj);
        }
        return applicantDealerRelObj;
    }
    /**
    * @description : Method to create bussiness information for borrower and principal
    * @author Shristy Kumari | 02-15-2025 
    * @param accountObj 
    * @param businessInfoObj 
    * @param paramMap 
    **/
    private static void createBusinessInfo(Account accountObj,genesis__Business_Information__c businessInfoObj,Map<String,Object> paramMap) {
        if(accountObj.genesis__Business_Information__c == null){
        businessinfoObj.genesis__Tax_Identification_Number__c = String.valueOf(paramMap.get(ExternalConstants.TAX_ID_KEY));
        businessinfoObj.Confirm_Tax_Identification_Number__c = String.valueOf(paramMap.get(ExternalConstants.CONFIRM_TAX_ID_KEY));
        Database.upsert(businessInfoObj, true);                
        accountObj.genesis__Business_Information__c = businessInfoObj.Id;
        Database.update(accountObj,true);
        }
    } 
}