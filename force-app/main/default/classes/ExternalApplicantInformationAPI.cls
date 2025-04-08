/**
 * @description       : saves the applicant information for external apis
 * @author            : Krishanu Chinya
 * @group             : 
  * @last modified on  : 03-28-2025
 * @last modified by  : Rakesh Saraf
**/
@RestResource(urlMapping = '/api/v1/external/saveApplicantInformation')
global without sharing class ExternalApplicantInformationAPI {
    private static final String CLASS_NAME = ExternalApplicantInformationAPI.class.getName();
    private static final String BORROWER_ACC_KEY = 'borrowerAccount';
    private static final String BORROWER_CONTACT_KEY = 'borrowerContact'; 
    private static final String BORROWER_PARTY_KEY = 'borrowerParty';
    private static final String PARAM_MAP_KEY = 'paramMap';
    static Account dealerForExtUser;

    /**
    * @description : saves the information of borrower in applicant information page
    * @author Krishanu Chinya | 05-30-2024 
    **/
    @HttpPost
    global static void doSaveApplicantInformation(){
        RestResponse response = RestContext.response;
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Object> contentMap = new Map<String, Object>();
        Map<String, Object> bodyMap = new Map<String, Object>();
        SavePoint dbSavePoint = Database.setSavepoint();

        try{
            RestRequest requestParam = RestContext.request;
            response.addHeader(ExternalConstants.CONTENT_TYPE, ExternalConstants.APPLICATION_JSON);

            String requestBody = requestParam.requestBody.toString();
            ExternalApplicationOriginationUtil.checkForBlankParameter(requestBody);
            Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(requestBody);

            Map<String,Object> applicationDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.APPLICATION_DETAIL_KEY);
            Map<String,Object> borrowerDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.BORROWER_DETAIL_KEY);
            ExternalApplicationOriginationUtil.checkForNullObject(applicationDetailsMap, ExternalConstants.APPLICATION_DETAILS_MISSING);  
            ExternalApplicationOriginationUtil.checkForNullObject(borrowerDetailsMap, ExternalConstants.BORROWER_DETAILS_MISSING);  

            Map<String,Object> dealerDetailsMap = (Map<String,Object>) requestParam.headers;
            ExternalApplicationOriginationUtil.checkForNullObject(dealerDetailsMap, ExternalConstants.DEALER_DETAILS_MISSING);  
            dealerForExtUser = ExternalApplicationValidationUtil.validateDealerDetails(dealerDetailsMap);

            //querying the original application
            List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                                    Name,
                                                                    Stage__c,
                                                                    Dealer_Name__c,
                                                                    genesis__Contact__c,
                                                                    genesis__Account__c,                        
                                                                    Internal_Reference_Code__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id =: (String)applicationDetailsMap.get(ExternalConstants.ID)];
            ExternalApplicationOriginationUtil.checkEmptyList(applicationList,ExternalConstants.APPLICATION_NOT_FOUND);
            
            ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(borrowerDetailsMap.get(ExternalConstants.USER_ID_KEY)), ExternalConstants.USER_ID_MISSING); 

            //validating whether the borrower belongs to the application
            ExternalSecurityUtil.validateBorrowerWithApplication((String)applicationDetailsMap.get(ExternalConstants.ID), (String)borrowerDetailsMap.get(ExternalConstants.USER_ID_KEY), dealerForExtUser.Id);

            //updating application fields
            populateApplicationData(applicationList[0], applicationDetailsMap);
            Database.update(applicationList[0], true);

            //fetching the borrower account
            List<Account> borrowerAccountList = [SELECT Id, 
                                                        Name,
                                                        clcommon__Legal_Entity_Type__r.Name,
                                                        genesis__Business_Information__c,
                                                        clcommon__Email__c,
                                                        Confirm_Email__C,
                                                        Work_Number__c,
                                                        Home_Number__c,
                                                        Phone,
                                                        BillingStreet,
                                                        BillingState,
                                                        BillingCity,
                                                        BillingPostalCode,
                                                        Billing_County__c,
                                                        Year_Began_Farming__c,
                                                        Kyc_Verified__c
                                                FROM Account 
                                                WHERE Id =: applicationList[0].genesis__Account__c
                                                AND Unique_Id__c =: (String)borrowerDetailsMap.get(ExternalConstants.USER_ID_KEY)];
            ExternalApplicationOriginationUtil.checkEmptyList(borrowerAccountList, ExternalConstants.BORROWER_ACCOUNT_NOT_FOUND);

            //upadting borrower data if it is not a dba
            if(borrowerAccountList[0].clcommon__Legal_Entity_Type__r.Name != ExternalConstants.INDIVIDUAL_ENTITY){
                ExternalApplicationValidationUtil.validateApplicantInfoData(borrowerDetailsMap, borrowerAccountList[0].clcommon__Legal_Entity_Type__r.Name);

                List<Contact> borrowerContactList = [SELECT Id,
                                                            Name,
                                                            FirstName,
                                                            LastName,
                                                            ints__Middle_Name__c,
                                                            Email,
                                                            Confirm_Email__C,
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
                                                            Title,
                                                            clcommon__Marital_Status__c
                                                    FROM Contact
                                                    WHERE Id =: applicationList[0].genesis__Contact__c
                                                    AND AccountId =: borrowerAccountList[0].Id];
                ExternalApplicationOriginationUtil.checkEmptyList(borrowerContactList, ExternalConstants.BORROWER_CONTACT_NOT_FOUND);

                List<clcommon__party__c> borrowerPartyList = [SELECT Id,
                                                                    Total_Assets__c,
                                                                    Total_Liabilities__c,
                                                                    Street__c,
                                                                    City__c,
                                                                    State__c,
                                                                    Postal_Code__c,
                                                                    County__c,
                                                                    Mobile_Number__c,
                                                                    Work_Number__c,
                                                                    Home_Number__c,
                                                                    Gross_Farm_Income__c,
                                                                    Marital_Status__c,
                                                                    Suffix__c,
                                                                    Dealer_Applicant_Relationship__r.Has_Past_Due__c,
                                                                    Dealer_Applicant_Relationship__r.Is_Non_Accrual__c
                                                                FROM clcommon__party__c
                                                                WHERE genesis__Application__c =: applicationList[0].Id
                                                                AND clcommon__Type__r.Name =: ExternalConstants.BORROWER_PARTY];
                ExternalApplicationOriginationUtil.checkEmptyList(borrowerContactList, ExternalConstants.BORROWER_PARTY_NOT_FOUND);

                ExternalApplicationCreationHandler.checkForNonAccrualOrPastDueParty(borrowerPartyList[0]);

                populateBorrowerData(new Map<String, Object> {
                    BORROWER_ACC_KEY => borrowerAccountList[0],
                    BORROWER_CONTACT_KEY => borrowerContactList[0],
                    BORROWER_PARTY_KEY => borrowerPartyList[0],
                    PARAM_MAP_KEY => borrowerDetailsMap
                });
            
                Database.update(borrowerAccountList[0], true);
                Database.update(borrowerContactList[0], true);
                Database.update(borrowerPartyList[0], true);
            }

            bodyMap.put(ExternalConstants.MESSAGE_KEY, ExternalConstants.RECORD_CREATED_VALUE);
            contentMap.put(ExternalConstants.BODY_KEY, bodyMap);
            responseMap.put(ExternalConstants.CONTENT_KEY, contentMap);
            responseMap.put(ExternalConstants.STATUS_KEY, ExternalConstants.SUCCESS_VALUE);
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
    * @description : populates application fields
    * @author Krishanu Chinya | 05-30-2024 
    * @param applicationObj 
    * @param paramMap 
    **/
    private static void populateApplicationData (genesis__Applications__c applicationObj, Map<String,Object> paramMap){
        applicationObj.Internal_Reference_Code__c = (String)paramMap.get(ExternalConstants.INTERNAL_REFERENCE_CODE_KEY);

        applicationObj.Stage__c = ExternalConstants.APPLICANT_SIGNATURE;
    }

    /**
    * @description : populates fields in borrower account, contact
    * @author Krishanu Chinya | 05-30-2024 
    * @param paramMap 
    **/
    private static void populateBorrowerData(Map<String, Object> paramMap){
        Account borrowerAccountObj = (Account)paramMap.get(BORROWER_ACC_KEY);
        Contact borrowerContactObj = (Contact)paramMap.get(BORROWER_CONTACT_KEY);
        clcommon__party__c borrowerPartyObj = (clcommon__party__c)paramMap.get(BORROWER_PARTY_KEY);
        Map<String,Object> borrowerDetailsMap = (Map<String,Object>)paramMap.get(PARAM_MAP_KEY);

        List<genesis__Business_Information__c> borrowerBusinessInfoList  = [SELECT Id,
                                                                                genesis__Total_Assets__c,
                                                                                genesis__Total_Liabilities__c,
                                                                                Gross_Farm_Income__c,
																				genesis__State_of_Incorporation__c
                                                                            FROM genesis__Business_Information__c
                                                                            WHERE Id =: borrowerAccountObj.genesis__Business_Information__c];
        ExternalApplicationOriginationUtil.checkEmptyList(borrowerBusinessInfoList, ExternalConstants.BORROWER_BUSINESS_INFO_NOT_FOUND);

        //populate email
        if(String.isBlank(borrowerContactObj.Email) && !borrowerAccountObj.Kyc_Verified__c){
            borrowerContactObj.Email = String.valueOf(borrowerDetailsMap.get(ExternalConstants.EMAIL_KEY));
            borrowerContactObj.Confirm_Email__C = String.valueOf(borrowerDetailsMap.get(ExternalConstants.EMAIL_KEY));

            borrowerAccountObj.clcommon__Email__c = String.valueOf(borrowerDetailsMap.get(ExternalConstants.EMAIL_KEY));
            borrowerAccountObj.Confirm_Email__C = String.valueOf(borrowerDetailsMap.get(ExternalConstants.EMAIL_KEY));
        }

        if(String.isBlank(borrowerContactObj.Phone)){
            borrowerContactObj.Phone = String.valueOf(borrowerDetailsMap.get(ExternalConstants.WORK_PHONE_KEY));
            borrowerAccountObj.Work_Number__c = String.valueOf(borrowerDetailsMap.get(ExternalConstants.WORK_PHONE_KEY));
        }

        if(String.isBlank(borrowerContactObj.HomePhone)){
            borrowerContactObj.HomePhone = String.valueOf(borrowerDetailsMap.get(ExternalConstants.HOME_PHONE_KEY));
            borrowerAccountObj.Home_Number__c = String.valueOf(borrowerDetailsMap.get(ExternalConstants.HOME_PHONE_KEY));
        }

        if(String.isBlank(borrowerContactObj.MobilePhone)){
            borrowerContactObj.MobilePhone = String.valueOf(borrowerDetailsMap.get(ExternalConstants.PHONE_NUMBER_KEY));
            borrowerAccountObj.Phone = String.valueOf(borrowerDetailsMap.get(ExternalConstants.PHONE_NUMBER_KEY));
        }

        //populating address 
        //Updating the address if the request parameter contains an address.
        borrowerContactObj.MailingStreet = borrowerAccountObj.BillingStreet = ExternalApplicationOriginationUtil.assignValueIfEmpty(borrowerContactObj.MailingStreet, String.valueOf(borrowerDetailsMap.get(ExternalConstants.STREET_KEY)));
        borrowerContactObj.MailingCity = borrowerAccountObj.BillingCity = ExternalApplicationOriginationUtil.assignValueIfEmpty(borrowerContactObj.MailingCity, String.valueOf(borrowerDetailsMap.get(ExternalConstants.CITY_KEY)));
        borrowerContactObj.MailingState = borrowerAccountObj.BillingState = ExternalApplicationOriginationUtil.assignValueIfEmpty(borrowerContactObj.MailingState, String.valueOf(borrowerDetailsMap.get(ExternalConstants.STATE_KEY)));
        borrowerContactObj.MailingPostalCode = borrowerAccountObj.BillingPostalCode = ExternalApplicationOriginationUtil.assignValueIfEmpty(borrowerContactObj.MailingPostalCode, String.valueOf(borrowerDetailsMap.get(ExternalConstants.POSTAL_CODE_KEY)));
        borrowerContactObj.Mailing_County__c = borrowerAccountObj.Billing_County__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(borrowerContactObj.Mailing_County__c, String.valueOf(borrowerDetailsMap.get(ExternalConstants.COUNTY_KEY)));

        borrowerBusinessInfoList[0].genesis__Total_Assets__c = (borrowerBusinessInfoList[0].genesis__Total_Assets__c == null) ? Integer.valueOf(borrowerDetailsMap.get(ExternalConstants.TOTAL_ASSETS_KEY)) : borrowerBusinessInfoList[0].genesis__Total_Assets__c;
        borrowerBusinessInfoList[0].genesis__Total_Liabilities__c = (borrowerBusinessInfoList[0].genesis__Total_Liabilities__c == null) ? Integer.valueOf(borrowerDetailsMap.get(ExternalConstants.TOTAL_LIABILITIES_KEY)) : borrowerBusinessInfoList[0].genesis__Total_Liabilities__c;
        borrowerBusinessInfoList[0].Gross_Farm_Income__c = (borrowerBusinessInfoList[0].Gross_Farm_Income__c == null) ? Integer.valueOf(borrowerDetailsMap.get(ExternalConstants.GROSS_FARM_INCOME_KEY)) : borrowerBusinessInfoList[0].Gross_Farm_Income__c;
        
        //for entity other than sole-prop and DBA, store state of incorporation
        fillCompanySpecificData(borrowerBusinessInfoList, borrowerDetailsMap, borrowerAccountObj.clcommon__Legal_Entity_Type__r.Name);
        Database.update(borrowerBusinessInfoList[0], true);

        fillIndividualSpecificData(borrowerAccountObj,borrowerContactObj,borrowerDetailsMap);

        fillBorrowerPartyDetails(borrowerPartyObj,borrowerDetailsMap, borrowerAccountObj.clcommon__Legal_Entity_Type__r.Name);

        ExternalApplicationValidationUtil.validatePartyContactInfo(borrowerContactObj,borrowerPartyObj);
    }

   
    /**
    * @description : fill the borrower details specific to companies
    * @author Krishanu Chinya | 03-02-2025 
    * @param borrowerBusinessInfoList 
    * @param borrowerDetailsMap 
    * @param entityType 
    **/
    private static void fillCompanySpecificData(List<genesis__Business_Information__c> borrowerBusinessInfoList, Map<String,Object> borrowerDetailsMap, String entityType){
        if(entityType != ExternalConstants.SOLE_PROP_ENTITY && entityType != ExternalConstants.INDIVIDUAL_ENTITY){

            borrowerBusinessInfoList[0].genesis__State_of_Incorporation__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(borrowerBusinessInfoList[0].genesis__State_of_Incorporation__c, String.valueOf(borrowerDetailsMap.get(ExternalConstants.STATE_OF_INCORPORATION_KEY)));
        }
    }

   
    /**
    * @description : fill the borrower details specific to individuals
    * @author Krishanu Chinya | 03-02-2025 
    * @param borrowerAccountObj 
    * @param borrowerContactObj 
    * @param borrowerDetailsMap 
    **/
    private static void fillIndividualSpecificData(Account borrowerAccountObj, Contact borrowerContactObj, Map<String,Object> borrowerDetailsMap){
        if(borrowerAccountObj.clcommon__Legal_Entity_Type__r.Name != ExternalConstants.SOLE_PROP_ENTITY){
            return;
        }

        borrowerContactObj.Suffix__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(borrowerContactObj.Suffix__c, String.valueOf(borrowerDetailsMap.get(ExternalConstants.SUFFIX_KEY)));
        if(borrowerContactObj.Birthdate == null && !borrowerAccountObj.Kyc_Verified__c){
            borrowerContactObj.Birthdate = Date.valueOf(String.valueOf(borrowerDetailsMap.get(ExternalConstants.BIRTHDATE_KEY)));
        }
        if(borrowerContactObj.clcommon__Marital_Status__c == ExternalConstants.NOT_PROVIDED_MARITAL_STATUS){
            borrowerContactObj.clcommon__Marital_Status__c = String.valueOf(borrowerDetailsMap.get(ExternalConstants.MARITAL_STATUS_KEY));
        }
        if(!borrowerAccountObj.Kyc_Verified__c && String.isBlank(borrowerContactObj.ints__Middle_Name__c) & !String.isBlank(String.valueOf(borrowerDetailsMap.get(ExternalConstants.MIDDLE_NAME_KEY)))){
            borrowerContactObj.ints__Middle_Name__c = String.valueOf(borrowerDetailsMap.get(ExternalConstants.MIDDLE_NAME_KEY));
            borrowerAccountObj.Name = borrowerContactObj.LastName 
                                    + ExternalConstants.COMMA_STRING 
                                    + ExternalConstants.SPACE_STRING 
                                    + borrowerContactObj.FirstName 
                                    + ExternalConstants.SPACE_STRING 
                                    + String.valueOf(borrowerDetailsMap.get(ExternalConstants.MIDDLE_NAME_KEY));
        }
        borrowerAccountObj.Year_Began_Farming__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(borrowerAccountObj.Year_Began_Farming__c, String.valueOf(borrowerDetailsMap.get(ExternalConstants.YEAR_BEGAN_FARMING_KEY)));
    }

   
    /**
    * @description : fill the borrower details in borrower party
    * @author Krishanu Chinya | 03-02-2025 
    * @param borrowerPartyObj 
    * @param borrowerDetailsMap 
    * @param entityType 
    **/
    private static void fillBorrowerPartyDetails(clcommon__party__c borrowerPartyObj, Map<String,Object> borrowerDetailsMap, String entityType){
        //populating address
        borrowerPartyObj.Street__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(borrowerPartyObj.Street__c, String.valueOf(borrowerDetailsMap.get(ExternalConstants.STREET_KEY)));
        borrowerPartyObj.City__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(borrowerPartyObj.City__c, String.valueOf(borrowerDetailsMap.get(ExternalConstants.CITY_KEY)));
        borrowerPartyObj.State__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(borrowerPartyObj.State__c, String.valueOf(borrowerDetailsMap.get(ExternalConstants.STATE_KEY)));
        borrowerPartyObj.Postal_Code__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(borrowerPartyObj.Postal_Code__c, String.valueOf(borrowerDetailsMap.get(ExternalConstants.POSTAL_CODE_KEY)));
        borrowerPartyObj.County__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(borrowerPartyObj.County__c, String.valueOf(borrowerDetailsMap.get(ExternalConstants.COUNTY_KEY)));

        //populating total assets and liabilities and address
        borrowerPartyObj.Total_Assets__c = (borrowerPartyObj.Total_Assets__c == null) ? Integer.valueOf(borrowerDetailsMap.get(ExternalConstants.TOTAL_ASSETS_KEY)) : borrowerPartyObj.Total_Assets__c;
        borrowerPartyObj.Total_Liabilities__c = (borrowerPartyObj.Total_Liabilities__c == null) ? Integer.valueOf(borrowerDetailsMap.get(ExternalConstants.TOTAL_LIABILITIES_KEY)) :borrowerPartyObj.Total_Liabilities__c;
        borrowerPartyObj.Gross_Farm_Income__c = (borrowerPartyObj.Gross_Farm_Income__c == null) ? Integer.valueOf(borrowerDetailsMap.get(ExternalConstants.GROSS_FARM_INCOME_KEY)) : borrowerPartyObj.Gross_Farm_Income__c;

        //populating contact numbers
        borrowerPartyObj.Work_Number__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(borrowerPartyObj.Work_Number__c, String.valueOf(borrowerDetailsMap.get(ExternalConstants.WORK_PHONE_KEY)));
        borrowerPartyObj.Home_Number__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(borrowerPartyObj.Home_Number__c, String.valueOf(borrowerDetailsMap.get(ExternalConstants.HOME_PHONE_KEY)));
        borrowerPartyObj.Mobile_Number__c = ExternalApplicationOriginationUtil.assignValueIfEmpty(borrowerPartyObj.Mobile_Number__c, String.valueOf(borrowerDetailsMap.get(ExternalConstants.PHONE_NUMBER_KEY)));

        if(entityType == ExternalConstants.SOLE_PROP_ENTITY){
            borrowerPartyObj.Suffix__c = String.valueOf(borrowerDetailsMap.get(ExternalConstants.SUFFIX_KEY));
            borrowerPartyObj.Marital_Status__c = String.valueOf(borrowerDetailsMap.get(ExternalConstants.MARITAL_STATUS_KEY));
        }
    }

}