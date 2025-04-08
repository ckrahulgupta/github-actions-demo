/**
 * @description       : Validation Util classes for ExternalSaveSigningMethodAPI
 * @author            : Suraj Kumar | 05-29-2024
 * @group             : 
 * @last modified on  : 02-27-2025
 * @last modified by  : Krishanu Chinya
**/
public inherited sharing class ExternalSaveSigningMethodValidationUtil {
    /**
    * @description : method to validate signing method wheather it is hybrid or Email
    * @author Suraj Kumar | 05-29-2024 
    * @param signingMethod 
    **/
    public static void validateSigningMethod(String signingMethod){
        if(!signingMethod.equals(ExternalConstants.IN_PERSON_HYBRID) 
                && !signingMethod.equals(ExternalConstants.EMAIL_DOCUSIGN)){
            throw new CustomException(ExternalConstants.SIGNING_METHOD_INVALID);
        }
    }

    /**
    * @description : method to validate total asset and liabilities
    * @author Suraj Kumar | 05-29-2024 
    * @param partyObj 
    **/
    public static void validateAssetAndLiability(clcommon__Party__c partyObj){
        // if not an DBA, then only enforce the validation
        if (partyObj.clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name != ExternalConstants.INDIVIDUAL_ENTITY){
            if(partyObj.Total_Assets__c == null) {
                throw new CustomException(ExternalConstants.APPL_TOTAL_ASSETS_MISSING);
            }
            if(partyObj.Total_Liabilities__c == null) {
                throw new CustomException(ExternalConstants.APPL_TOTAL_LIABILITIES_MISSING);
            }
            checkAmountLessThanZero(Double.valueOf(partyObj.Total_Assets__c),ExternalConstants.APPL_TOTAL_ASSETS_INVALID);
            checkAmountLessThanZero(Double.valueOf(partyObj.Total_Liabilities__c), ExternalConstants.APPL_TOTAL_LIABILITIES_INVALID);
        }
    }
    /**
    * @description : validate co applicant details
    * @author Suraj Kumar | 05-29-2024 
    * @param partyList 
    **/
    public static void validateCoApplicant(List<clcommon__Party__c> partyList){
        if(partyList.size() == 1 
                    && partyList[0].clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name != ExternalConstants.SOLE_PROP_ENTITY){
            throw new CustomException(ExternalConstants.CO_APPLICANT_MISSING);
        }
    }

    /**
    * @description : this methods validates the borrower details
    * @author Suraj Kumar | 05-30-2024 
    * @param applicationObj 
    * @param borrowerPartyList 
    **/
    public static void isValidApplicationCreation(genesis__Applications__c applicationObj, List<clcommon__Party__c> borrowerPartyList){
        ExternalApplicationOriginationUtil.checkEmptyList(borrowerPartyList,ExternalConstants.SIGNING_WITHOUT_APPLICANT_INFO);
        
        if(applicationObj.genesis__Loan_Amount__c == null || applicationObj.genesis__Loan_Amount__c <0){
            throw new CustomException(ExternalConstants.LOAN_AMOUNT_MISSING);
        }
        if(borrowerPartyList[0].clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name == ExternalConstants.SOLE_PROP_ENTITY){
            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].clcommon__Contact__r.Email, ExternalConstants.EMAIL_FIELD_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].clcommon__Contact__r.FirstName, ExternalConstants.APPL_FIRST_NAME_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].Street__c, ExternalConstants.APPL_ADDRESS_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].City__c, ExternalConstants.APPL_CITY_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].State__c, ExternalConstants.APPL_STATE_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].County__c, ExternalConstants.APPL_COUNTY_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].Postal_Code__c, ExternalConstants.APPL_ZIP_CODE_MISSING);
            checkMaritalStatus(borrowerPartyList[0].Marital_Status__c, ExternalConstants.APPL_MARITAL_STATUS_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].clcommon__Contact__r.genesis__SSN__c, ExternalConstants.APPL_SSN_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].clcommon__Contact__r.Confirm_SSN__c, ExternalConstants.APPL_CONFIRM_SSN_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(borrowerPartyList[0].clcommon__Contact__r.Birthdate), ExternalConstants.APPL_DATE_OF_BIRTH_MISSING);
            ExternalValidationUtil.validatePostalCode(String.valueOf(borrowerPartyList[0].Postal_Code__c));
            checkContactNumber(String.valueOf(borrowerPartyList[0].Mobile_Number__c),String.valueOf(borrowerPartyList[0].Home_Number__c), String.valueOf(borrowerPartyList[0].Work_Number__c));
            ExternalValidationUtil.validateEmailAddress(borrowerPartyList[0].clcommon__Contact__r.Email,borrowerPartyList[0].clcommon__Contact__r.Email);
            ExternalValidationUtil.validateSSN(borrowerPartyList[0].clcommon__Contact__r.genesis__SSN__c, borrowerPartyList[0].clcommon__Contact__r.Confirm_SSN__c);

            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].clcommon__Account__r.clcommon__Email__c, ExternalConstants.EMAIL_FIELD_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].clcommon__Account__r.Name, ExternalConstants.APPL_NAME_MISSING);
        }
        else if(borrowerPartyList[0].clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name == ExternalConstants.INDIVIDUAL_ENTITY){
            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].clcommon__Account__r.Name, ExternalConstants.APPL_NAME_MISSING);
        }
        else{
            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].clcommon__Account__r.Name, ExternalConstants.APPL_NAME_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].State__c, ExternalConstants.APPL_STATE_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].Street__c, ExternalConstants.APPL_ADDRESS_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].City__c, ExternalConstants.APPL_CITY_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].Postal_Code__c, ExternalConstants.APPL_ZIP_CODE_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].County__c, ExternalConstants.APPL_COUNTY_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(borrowerPartyList[0].clcommon__Account__r.genesis__Business_information__r.genesis__Tax_Identification_Number__c, ExternalConstants.APPL_TAX_ID_MISSING);
            ExternalValidationUtil.validatePostalCode(String.valueOf(borrowerPartyList[0].Postal_Code__c));
            checkContactNumber(String.valueOf(borrowerPartyList[0].Work_Number__c),String.valueOf(borrowerPartyList[0].Home_Number__c), String.valueOf(borrowerPartyList[0].Mobile_Number__c));
        }
        checkAmountLessThanZero(Double.valueOf(borrowerPartyList[0].clcommon__Account__r.genesis__Business_information__r.genesis__Total_Assets__c),ExternalConstants.APPL_TOTAL_ASSETS_INVALID);
        checkAmountLessThanZero(Double.valueOf(borrowerPartyList[0].clcommon__Account__r.genesis__Business_information__r.genesis__Total_Liabilities__c), ExternalConstants.APPL_TOTAL_LIABILITIES_INVALID);
        if(applicationObj.Stage__c == ExternalConstants.APPLICANT_INFORMATION){
            applicationObj.Stage__c = ExternalConstants.APPLICANT_SIGNATURE;
        }
    }

    /**
    * @description : this methods validates the co-applicant details
    * @author Suraj Kumar | 05-30-2024 
    * @param principalPartyList 
    **/
    public static void isValidCoApplicantCreation(List<clcommon__Party__c> principalPartyList){
        for (clcommon__Party__c principalPartyObj: principalPartyList){
            ExternalApplicationOriginationUtil.checkForEmptyString(principalPartyObj.clcommon__Contact__r.Email, ExternalConstants.EMAIL_FIELD_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(principalPartyObj.clcommon__Contact__r.LastName, ExternalConstants.CO_APPL_LAST_NAME_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(principalPartyObj.clcommon__Account__r.Name, ExternalConstants.CO_APPL_LAST_NAME_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(principalPartyObj.clcommon__Contact__r.FirstName, ExternalConstants.CO_APPL_FIRST_NAME_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(principalPartyObj.Street__c, ExternalConstants.CO_APPL_ADDRESS_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(principalPartyObj.City__c, ExternalConstants.CO_APPL_CITY_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(principalPartyObj.State__c, ExternalConstants.CO_APPL_STATE_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(principalPartyObj.County__c, ExternalConstants.CO_APPL_COUNTY_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(principalPartyObj.Postal_Code__c, ExternalConstants.CO_APPL_ZIP_CODE_MISSING);
            checkMaritalStatus(principalPartyObj.Marital_Status__c, ExternalConstants.CO_APPL_MARITAL_STATUS_MISSING);
            ExternalValidationUtil.validatePostalCode(String.valueOf(principalPartyObj.Postal_Code__c));
            ExternalApplicationOriginationUtil.checkForEmptyString(principalPartyObj.clcommon__Contact__r.genesis__SSN__c, ExternalConstants.CO_APPL_SSN_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(principalPartyObj.clcommon__Contact__r.Birthdate), ExternalConstants.CO_APPL_DATE_OF_BIRTH_MISSING);   
            checkAmountLessThanZero(Double.valueOf(principalPartyObj.clcommon__Account__r.genesis__Business_information__r.genesis__Total_Assets__c),ExternalConstants.CO_APPL_TOTAL_ASSETS_INVALID);
            checkAmountLessThanZero(Double.valueOf(principalPartyObj.clcommon__Account__r.genesis__Business_information__r.genesis__Total_Liabilities__c), ExternalConstants.CO_APPL_TOTAL_LIABILITIES_INVALID);
            checkContactNumber(String.valueOf(principalPartyObj.Mobile_Number__c),String.valueOf(principalPartyObj.Home_Number__c),String.valueOf(principalPartyObj.Work_Number__c));
            ExternalValidationUtil.validateEmailAddress(principalPartyObj.clcommon__Contact__r.Email,principalPartyObj.clcommon__Contact__r.Email);
            ExternalValidationUtil.validateSSN(principalPartyObj.clcommon__Contact__r.genesis__SSN__c, principalPartyObj.clcommon__Contact__r.Confirm_SSN__c);

            ExternalApplicationOriginationUtil.checkForEmptyString(principalPartyObj.clcommon__Account__r.clcommon__Email__c, ExternalConstants.EMAIL_FIELD_MISSING);
        }
    }

    /**
    * @description : method to check whether the marital status is provided or not
    * @author Krishanu Chinya | 02-27-2025 
    * @param stringToCheck 
    * @param exceptionString 
    **/
    public static void checkMaritalStatus(String stringToCheck, String exceptionString){
        if(String.isBlank(stringToCheck) || stringToCheck == ExternalConstants.NOT_PROVIDED_MARITAL_STATUS){
            throw new CustomException(exceptionString);
        }
    }

    /**
    * @description : method to check contact number is present or not
    * @author Suraj Kumar | 05-30-2024 
    * @param mobilePhone 
    * @param homePhone 
    * @param phone 
    **/
    public static void checkContactNumber(String mobilePhone, String homePhone, String phone){
        if(String.isBlank(mobilePhone) && String.isBlank(homePhone) && String.isBlank(phone)){
            throw new CustomException(ExternalConstants.APPL_MOBILE_MISSING);
        }
    }

    /**
    * @description : method to check amount less than zero
    * @author Suraj Kumar | 05-30-2024 
    * @param amount 
    * @param exceptionString 
    **/
    public static void checkAmountLessThanZero(Double amount, String exceptionString){
        if(amount < 0){
            throw new CustomException(exceptionString);
        }
    }
}