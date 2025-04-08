/**
 * @description       : validation util for application creation for external apis
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 04-02-2025
 * @last modified by  : Rakesh Saraf
**/
public inherited sharing class ExternalApplicationValidationUtil {
    public static final String CONTACT_OBJ = 'Contact';
    public static final String BUSINESS_INFO_OBJ = 'genesis__Business_Information__c';
    public static final String SUFFIX_FIELD = 'Suffix__c';
    public static final String TITLE_FIELD = 'Title';
    public static final String MARITAL_STATUS_FIELD = 'clcommon__Marital_Status__c';
    public static final String STATE_OF_INCORPORATION_FIELD = 'genesis__State_of_Incorporation__c';

    /**
    * @description : validates the legal entity type
    * @author Krishanu Chinya | 05-17-2024 
    * @param legalEntity 
    **/
    public static void checkForValidLegalEntityType (String legalEntity){
        //fetching a list of all the possible legal entity in cfa
        List<String> possibleLegalEntityList = ExternalApplicationOriginationUtil.getPossibleLegalEntityList();
        
        if(!possibleLegalEntityList.contains(legalEntity)){
            throw new CustomException(ExternalConstants.INVALID_LEGAL_ENTITY_TYPE);
        }
    }

    /**
    * @description : validates the values for creating an application
    * @author Krishanu Chinya | 05-17-2024 
    * @param requestMap
    **/
    public static void validateApplicationData (Map<String,Object> requestMap){
        //segregating the details from requestMap
        Map<String,Object> applicationDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.APPLICATION_DETAIL_KEY);
        Map<String,Object> borrowerDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.BORROWER_DETAIL_KEY);
        Map<String,Object> principalDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.PRINCIPAL_DETAIL_KEY);

        ExternalApplicationOriginationUtil.checkForNullObject(applicationDetailsMap, ExternalConstants.APPLICATION_DETAILS_MISSING);
        ExternalApplicationOriginationUtil.checkForNullObject(borrowerDetailsMap, ExternalConstants.BORROWER_DETAILS_MISSING);


        String legalEntity = ExternalConstants.EMPTY_STRING;

        //validating application details
        validateLoanAmount(Integer.valueOf(applicationDetailsMap.get(ExternalConstants.LOAN_AMOUNT_KEY)));

        //validating borrower and principal details

        //validating entity type
        ExternalApplicationOriginationUtil.checkForBlankParameter(String.valueOf(borrowerDetailsMap.get(ExternalConstants.ENTITY_TYPE)));
        checkForValidLegalEntityType(String.valueOf(borrowerDetailsMap.get(ExternalConstants.ENTITY_TYPE)));

        //validating user id key
        ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(borrowerDetailsMap.get(ExternalConstants.USER_ID_KEY)), ExternalConstants.BORROWER_USER_ID_MISSING);            

        legalEntity = String.valueOf(borrowerDetailsMap.get(ExternalConstants.ENTITY_TYPE));

        //validations for sole prop
        if(legalEntity == ExternalConstants.SOLE_PROP_ENTITY){
            ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(borrowerDetailsMap.get(ExternalConstants.LAST_NAME_KEY)), ExternalConstants.APPLICANT_NAME_MISSING);            
            ExternalValidationUtil.validateSSN(String.valueOf(borrowerDetailsMap.get(ExternalConstants.SSN_KEY)), String.valueOf(borrowerDetailsMap.get(ExternalConstants.CONFIRM_SSN_KEY)));
            
            ExternalValidationUtil.validateEmailAddress(String.valueOf(borrowerDetailsMap.get(ExternalConstants.EMAIL_KEY)), String.valueOf(borrowerDetailsMap.get(ExternalConstants.CONFIRM_EMAIL_KEY)));
            ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(borrowerDetailsMap.get(ExternalConstants.PHONE_NUMBER_KEY)), ExternalConstants.PHONE_NUMBER_MISSING);            
            ExternalValidationUtil.validatePhoneNum(String.valueOf(borrowerDetailsMap.get(ExternalConstants.PHONE_NUMBER_KEY)));
            ExternalValidationUtil.validatePhoneNum(String.valueOf(borrowerDetailsMap.get(ExternalConstants.HOME_PHONE_KEY)));
            ExternalValidationUtil.validatePhoneNum(String.valueOf(borrowerDetailsMap.get(ExternalConstants.WORK_PHONE_KEY)));

        }else{
            //validations for dba and corporation
            ExternalApplicationOriginationUtil.checkForNullObject(principalDetailsMap, ExternalConstants.PRINCIPAL_DETAILS_MISSING);
            ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(borrowerDetailsMap.get(ExternalConstants.NAME_KEY)), ExternalConstants.APPLICANT_NAME_MISSING);
            
            ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(principalDetailsMap.get(ExternalConstants.LAST_NAME_KEY)), ExternalConstants.PRINCIPAL_NAME_MISSING);
            ExternalValidationUtil.validateSSN(String.valueOf(principalDetailsMap.get(ExternalConstants.SSN_KEY)), String.valueOf(principalDetailsMap.get(ExternalConstants.CONFIRM_SSN_KEY)));

            ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(principalDetailsMap.get(ExternalConstants.USER_ID_KEY)), ExternalConstants.PRINCIPAL_USER_ID_MISSING);            


            ExternalValidationUtil.validateEmailAddress(String.valueOf(principalDetailsMap.get(ExternalConstants.EMAIL_KEY)), String.valueOf(principalDetailsMap.get(ExternalConstants.CONFIRM_EMAIL_KEY)));
            ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(principalDetailsMap.get(ExternalConstants.PHONE_NUMBER_KEY)), ExternalConstants.PHONE_NUMBER_MISSING);            
            ExternalValidationUtil.validatePhoneNum(String.valueOf(principalDetailsMap.get(ExternalConstants.PHONE_NUMBER_KEY)));
            ExternalValidationUtil.validatePhoneNum(String.valueOf(principalDetailsMap.get(ExternalConstants.HOME_PHONE_KEY)));
            ExternalValidationUtil.validatePhoneNum(String.valueOf(principalDetailsMap.get(ExternalConstants.WORK_PHONE_KEY)));
        }

        //validation specific to corporation and others who have tin
        if(legalEntity != ExternalConstants.SOLE_PROP_ENTITY && legalEntity != ExternalConstants.INDIVIDUAL_ENTITY){
            ExternalValidationUtil.validateTIN(String.valueOf(borrowerDetailsMap.get(ExternalConstants.TAX_ID_KEY)), String.valueOf(borrowerDetailsMap.get(ExternalConstants.CONFIRM_TAX_ID_KEY)));
        }
    }

    /**
    * @description : validates application and borrower data in applicant information page
    * @author Krishanu Chinya | 05-30-2024 
    * @param borrowerDetailsMap 
    * @param legalEntity 
    **/
    public static void validateApplicantInfoData(Map<String,Object> borrowerDetailsMap, String legalEntity){
        //Map<String,Object> borrowerDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.BORROWER_DETAIL_KEY);
        ExternalApplicationOriginationUtil.checkForNullObject(borrowerDetailsMap, ExternalConstants.BORROWER_DETAILS_MISSING);

        ExternalValidationUtil.validateEmailAddress(String.valueOf(borrowerDetailsMap.get(ExternalConstants.EMAIL_KEY)), String.valueOf(borrowerDetailsMap.get(ExternalConstants.CONFIRM_EMAIL_KEY)));
        ExternalValidationUtil.validatePhoneNum(String.valueOf(borrowerDetailsMap.get(ExternalConstants.PHONE_NUMBER_KEY)));
        ExternalValidationUtil.validatePhoneNum(String.valueOf(borrowerDetailsMap.get(ExternalConstants.HOME_PHONE_KEY)));
        ExternalValidationUtil.validatePhoneNum(String.valueOf(borrowerDetailsMap.get(ExternalConstants.WORK_PHONE_KEY)));

        ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(borrowerDetailsMap.get(ExternalConstants.USER_ID_KEY)), ExternalConstants.USER_ID_MISSING); 
        
        validateTotalAssets(Integer.valueOf(borrowerDetailsMap.get(ExternalConstants.TOTAL_ASSETS_KEY)));
        validateTotalLiabilities(Integer.valueOf(borrowerDetailsMap.get(ExternalConstants.TOTAL_LIABILITIES_KEY)));

        ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(borrowerDetailsMap.get(ExternalConstants.POSTAL_CODE_KEY)), ExternalConstants.POSTAL_CODE_MISSING); 
        ExternalValidationUtil.validatePostalCode(String.valueOf(borrowerDetailsMap.get(ExternalConstants.POSTAL_CODE_KEY)));

        ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(borrowerDetailsMap.get(ExternalConstants.STATE_KEY)), ExternalConstants.STATE_MISSING); 
        ExternalValidationUtil.validateState(String.valueOf(borrowerDetailsMap.get(ExternalConstants.STATE_KEY)));

        ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(borrowerDetailsMap.get(ExternalConstants.STREET_KEY)), ExternalConstants.STREET_MISSING); 
        ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(borrowerDetailsMap.get(ExternalConstants.CITY_KEY)), ExternalConstants.CITY_MISSING); 
        ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(borrowerDetailsMap.get(ExternalConstants.COUNTY_KEY)), ExternalConstants.COUNTY_MISSING); 

        if(legalEntity == ExternalConstants.SOLE_PROP_ENTITY){
            ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(borrowerDetailsMap.get(ExternalConstants.BIRTHDATE_KEY)), ExternalConstants.BIRTHDATE_MISSING); 
            ExternalValidationUtil.validateBirthDate(String.valueOf(borrowerDetailsMap.get(ExternalConstants.BIRTHDATE_KEY)));

            ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(borrowerDetailsMap.get(ExternalConstants.MARITAL_STATUS_KEY)), ExternalConstants.MARITAL_STATUS_MISSING); 
            validateMaritalStatus(String.valueOf(borrowerDetailsMap.get(ExternalConstants.MARITAL_STATUS_KEY)));

            validateSuffix(String.valueOf(borrowerDetailsMap.get(ExternalConstants.SUFFIX_KEY)));
        }

        if(legalEntity != ExternalConstants.SOLE_PROP_ENTITY && legalEntity != ExternalConstants.INDIVIDUAL_ENTITY){
            ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(borrowerDetailsMap.get(ExternalConstants.STATE_OF_INCORPORATION_KEY)), ExternalConstants.SOI_MISSING); 
            validateStateOfIncorporation(String.valueOf(borrowerDetailsMap.get(ExternalConstants.STATE_OF_INCORPORATION_KEY)));
        }
    }

    /**
    * @description : validates that email is present and atleast one contact number is present
    * @author Krishanu Chinya | 06-12-2024 
    * @param applicantContact 
    **/
    public static void validateApplicantContactInfo(Contact applicantContact){

        if(String.isBlank(String.valueOf(applicantContact.MobilePhone)) 
                    & String.isBlank(String.valueOf(applicantContact.HomePhone)) 
                    & String.isBlank(String.valueOf(applicantContact.Phone))){

            ExternalExceptionUtil.throwCustomException(ExternalConstants.CONTACT_NUMBER_MISSING);
        }
    }


    /**
    * @description : validates the loan amount
    * @author Krishanu Chinya | 05-17-2024 
    * @param loanAmount 
    **/
    public static void validateLoanAmount(Decimal loanAmount){
        if(loanAmount == null || loanAmount < 0){
            ExternalExceptionUtil.throwCustomException(ExternalConstants.INVALID_LOAN_AMOUNT);
        }
    }

    /**
    * @description : validates the total assets
    * @author Krishanu Chinya | 05-17-2024 
    * @param totalAssets 
    **/
    public static void validateTotalAssets(Decimal totalAssets){
        if(totalAssets == null || totalAssets < 0){
            ExternalExceptionUtil.throwCustomException(ExternalConstants.TOTAL_ASSETS_MISSING);
        }
    }
    /**
    * @description : validates the total liabilities
    * @author Krishanu Chinya | 05-17-2024 
    * @param totalLiabilities 
    **/
    public static void validateTotalLiabilities(Decimal totalLiabilities){
        if(totalLiabilities == null || totalLiabilities < 0){
            ExternalExceptionUtil.throwCustomException(ExternalConstants.TOTAL_LIABILITIES_MISSING);
        }
    }

    /**
    * @description : validates whether suffix is valid 
    * @author Krishanu Chinya | 05-30-2024 
    * @param suffix 
    **/
    public static void validateSuffix(String suffix){
        List<String> possibleSuffixList = ExternalApplicationOriginationUtil.getPicklistValues(CONTACT_OBJ, SUFFIX_FIELD);
        if(suffix!=null && !possibleSuffixList.contains(suffix)){
            throw new CustomException(ExternalConstants.INVALID_SUFFIX);
        }
        
    }

    /**
    * @description : validates marital status
    * @author Krishanu Chinya | 05-30-2024 
    * @param maritalStatus 
    **/
    public static void validateMaritalStatus(String maritalStatus){
        List<String> possibleMaritalStatusList = ExternalApplicationOriginationUtil.getPicklistValues(CONTACT_OBJ, MARITAL_STATUS_FIELD);
        if(!possibleMaritalStatusList.contains(maritalStatus)){
            ExternalExceptionUtil.throwCustomException(ExternalConstants.INVALID_MARITAL_STATUS);
        }
    }

    /**
    * @description : validate state of incorporation
    * @author Krishanu Chinya | 05-30-2024 
    * @param stateOfIncorporation 
    **/
    public static void validateStateOfIncorporation(String stateOfIncorporation){
        List<String> possibleSOIList = ExternalApplicationOriginationUtil.getPicklistValues(BUSINESS_INFO_OBJ, STATE_OF_INCORPORATION_FIELD);
        if(!possibleSOIList.contains(stateOfIncorporation)){
            ExternalExceptionUtil.throwCustomException(ExternalConstants.INVALID_STATE_INCORPORATION);
        }
    }

    /**
    * @description : validates title of a co-applicant
    * @author Krishanu Chinya | 06-10-2024 
    * @param title 
    * @param legalEntity 
    **/
    public static void validateTitle(String title, String legalEntity){
        ExternalApplicationOriginationUtil.checkForEmptyString(title, ExternalConstants.TITLE_MISSING);

        List<String> corporationTitles = new List<String>{ExternalConstants.PRESIDENT, 
                                                            ExternalConstants.VIDE_PRESIDENT, 
                                                            ExternalConstants.SECRETARY, 
                                                            ExternalConstants.TREASURER, 
                                                            ExternalConstants.DIRECTOR};

        if((legalEntity == ExternalConstants.CORPORATION & !corporationTitles.contains(title))
            | (legalEntity == ExternalConstants.GENERAL_PARTNERSHIP & title!= ExternalConstants.PARTNER)
            | (legalEntity == ExternalConstants.LIMITED_PARTNERSHIP & title != ExternalConstants.PARTNER)
            | (legalEntity == ExternalConstants.JOINT_VENTURE & title != ExternalConstants.MEMBER)
            | (legalEntity == ExternalConstants.LIMITED_LIABILITY_COMPANY & (title != ExternalConstants.MEMBER & title != ExternalConstants.MANAGER))
            | (legalEntity == ExternalConstants.TRUST & title != ExternalConstants.TRUSTEE)
            | ((legalEntity == ExternalConstants.SOLE_PROP_ENTITY | legalEntity == ExternalConstants.INDIVIDUAL_ENTITY) & title != ExternalConstants.CO_APPLICANT)){
                throw new CustomException(ExternalConstants.INVALID_TITLE);
        }
    }

    /**
    * @description : Method to validate dealer details
    * @author Suraj Kumar | 09-11-2024 
    * @param dealerDetailsMap 
    * @return Account 
    **/
    public static Account validateDealerDetails(Map<String,Object> dealerDetailsMap){
        Account dealerForExtUser;
        if(!dealerDetailsMap.containsKey(ExternalConstants.DEALER_CIF_KEY)){
            ExternalExceptionUtil.throwCustomException(ExternalConstants.DEALER_CIF_MISSING);
        }
        ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(dealerDetailsMap.get(ExternalConstants.DEALER_CIF_KEY)), ExternalConstants.DEALER_CIF_MISSING);

        if(!dealerDetailsMap.containsKey(ExternalConstants.DEALER_TOKEN_KEY)){
            ExternalExceptionUtil.throwCustomException(ExternalConstants.DEALER_TOKEN_MISSING);
        }
        ExternalApplicationOriginationUtil.checkForEmptyString(String.valueOf(dealerDetailsMap.get(ExternalConstants.DEALER_TOKEN_KEY)), ExternalConstants.DEALER_TOKEN_MISSING);

        String dealerCIF = String.valueOf(dealerDetailsMap.get(ExternalConstants.DEALER_CIF_KEY));
        String dealerUniqueId = String.valueOf(dealerDetailsMap.get(ExternalConstants.DEALER_TOKEN_KEY));
        
       dealerForExtUser = ExternalApplicationOriginationUtil.getDealerInfoForExternalUser(dealerCIF);
        
        if(dealerForExtUser.Unique_Id__c != dealerUniqueId){
            ExternalExceptionUtil.throwCustomException(ExternalConstants.DEALER_TOKEN_INVALID);
        }
        return dealerForExtUser;
    }

    /**
    * @description : validates that email is present and atleast one contact number is present
    * @author Suraj Kumar| 12-10-2024 
    * @param applicantContact 
    * @param applicantPartyObj 
    **/
    public static void validatePartyContactInfo(Contact applicantContact, clcommon__party__c applicantPartyObj){

        if(String.isBlank(String.valueOf(applicantPartyObj.Mobile_Number__c)) 
                    & String.isBlank(String.valueOf(applicantPartyObj.Work_Number__c)) 
                    & String.isBlank(String.valueOf(applicantPartyObj.Home_Number__c))){

            ExternalExceptionUtil.throwCustomException(ExternalConstants.CONTACT_NUMBER_MISSING);
        }
    }

    /**
    * @description validates if the ssn has been entered for the coapplicant. If it is a first co-applicant, then we do not to verify the ssn
    * @author Rakesh Saraf | 03-18-2025 
    * @param principalDetailsMap 
    * @return String 
    **/
    public static String validateSSNOfPrincipal(Map<String,Object> principalDetailsMap){
        if(!principalDetailsMap.containsKey(ExternalConstants.SSN_KEY) 
            || String.isBlank(String.valueOf(principalDetailsMap.get(ExternalConstants.SSN_KEY)))){
            ExternalExceptionUtil.throwCustomException(ExternalConstants.COAPP_SSN_MISSING);
        }

        if(!principalDetailsMap.containsKey(ExternalConstants.CONFIRM_SSN_KEY) 
            || String.isBlank(String.valueOf(principalDetailsMap.get(ExternalConstants.CONFIRM_SSN_KEY)))){
            ExternalExceptionUtil.throwCustomException(ExternalConstants.COAPP_CONFIRM_SSN_MISSING);
        }

        String coAppSSN =String.valueOf(principalDetailsMap.get(ExternalConstants.SSN_KEY));
        String coAppConfirmSSN =String.valueOf(principalDetailsMap.get(ExternalConstants.CONFIRM_SSN_KEY));

        ExternalValidationUtil.validateSSN(coAppSSN,coAppConfirmSSN);
        return coAppSSN;

    }
   
}