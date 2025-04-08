/**
 * @description       : Validation classes for external API
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 03-27-2025
 * @last modified by  : Rakesh Saraf
**/
public inherited sharing class ExternalValidationUtil {
    private static final String DUPLICATE_FOUND = 'duplicateFound';
    private static final String CONTACT_KEY = 'Contact';
    private static final String ACCOUNT_KEY = 'Account';
    private static final String BUSINESS_INFO = 'BusinessInfo';

    public static final String STATES = System.Label.Additional_Info_States;

    /**
    * @description : validates whether a birthdate is valid or not
    * @author Krishanu Chinya | 05-30-2024 
    * @param birthdateString 
    **/
    public static void validateBirthDate(String birthdateString) {
        Boolean isValid = false;
        try {
            Date birthdate = Date.valueOf(birthdateString);
            Date today = Date.today();
            Date minimumValidBirthdate = today.addYears(-18);
            isValid = birthdate <= minimumValidBirthdate;
        } catch (Exception e) {
            // If there's any exception while parsing the input string or performing the validation,
            // the birthdate is considered invalid.
            isValid = false;
        }
        //return isValid;
        if(!isValid){
            throw new CustomException(ExternalConstants.INVALID_BIRTHDATE);
        }
    }


    /**
    * @description : checks whether a loan amount is valid or not
    * @author Krishanu Chinya | 05-30-2024 
    * @param amt 
    * @return Boolean 
    **/
    public static Boolean checkLoanAmount(String amt){
        Boolean isValid;
        try{
            Decimal.valueOf(amt);
            isValid = true; 
        } catch (Exception e) {
            isValid = false;
        }
        return isValid;
    }

    /**
    * @description : validates whether state is valid
    * @author Krishanu Chinya | 05-30-2024 
    * @param state 
    **/
    public static void validateState(String state){
        List<String> statesList = STATES.split(ExternalConstants.COMMA_STRING);
        if(!statesList.contains(state)){
            ExternalExceptionUtil.throwCustomException(ExternalConstants.STATE_INVALID);
        }

    }

    /**
    * @description : validates the phone number 
    * @author Krishanu Chinya | 05-20-2024 
    * @param phoneNum 
    **/
    public static void validatePhoneNum (String phoneNum){
        if(String.isBlank(phoneNum)){
            return;
        }

        if (phoneNum.length() != 10 || !phoneNum.isNumeric()) {
            ExternalExceptionUtil.throwCustomException(ExternalConstants.INVALID_PHONE_NUMBER);
        }
    }

    /**
    * @description : validates the email address
    * @author Krishanu Chinya | 05-17-2024 
    * @param email 
    * @param confirmEmail
    **/
    public static void validateEmailAddress(String email, String confirmEmail) {
        if(String.isBlank(email)){
            return;
        }
        String emailRegex = ExternalConstants.EMAIL_REGEX; 

        Pattern emailPattern = Pattern.compile(emailRegex);
        Matcher matcherObj = emailPattern.matcher(email);

        if (!matcherObj.matches()) {
            ExternalExceptionUtil.throwCustomException(ExternalConstants.INVALID_EMAIL);
        }

        if(String.isBlank(confirmEmail) || email != confirmEmail){
            ExternalExceptionUtil.throwCustomException(ExternalConstants.EMAIL_CONFIRM_EMAIL_MISMATCH);
        }
    }

    /**
    * @description : validates the ssn of an individual
    * @author Krishanu Chinya | 05-17-2024 
    * @param ssn 
    * @param confirmSSN 
    **/
    public static void validateSSN(String ssn, String confirmSSN) {
        ExternalApplicationOriginationUtil.checkForEmptyString(ssn, ExternalConstants.SSN_MISSING);
        
        if(ssn.length() != 9) {
            ExternalExceptionUtil.throwCustomException(ExternalConstants.INVALID_SSN);
        }

        if(ssn != confirmSSN){
            ExternalExceptionUtil.throwCustomException(ExternalConstants.SSN_CONFIRM_SSN_MISMATCH);
        }
    }

    /**
    * @description : validates the tin for business
    * @author Krishanu Chinya | 05-17-2024 
    * @param tin 
    * @param confirmTIN 
    **/
    public static void validateTIN(String tin, String confirmTIN) {
        ExternalApplicationOriginationUtil.checkForEmptyString(tin, ExternalConstants.TIN_MISSING);
        if (tin.length() != 9) {
            ExternalExceptionUtil.throwCustomException(ExternalConstants.INVALID_TIN);
        }
        if(tin != confirmTIN){
            ExternalExceptionUtil.throwCustomException(ExternalConstants.TIN_CONFIRM_TIN_MISMATCH);
        }
    }

    /**
    * @description : validates the postal code 
    * @author Suraj Kumar | 05-20-2024 
    * @param postalCode 
    **/
    public static void validatePostalCode(String postalCode){
        if((postalCode.length() !=5 && postalCode.length() != 9) || !postalCode.isNumeric()){
            ExternalExceptionUtil.throwCustomException(ExternalConstants.POSTAL_CODE_INVALID);
        }
    }

    /**
    * @description : validates a new individual
    * @author Krishanu Chinya | 07-10-2024 
    * @param ssn 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> validateDuplicateIndividual(String ssn) {
        Map<String, Object> duplicatesMap = new Map<String, Object>();
        duplicatesMap.put(DUPLICATE_FOUND, false);

        if(String.isBlank(ssn)){
            return duplicatesMap;
        }
        //search if a user exist with the same ssn
        List<Contact> contactList = [SELECT Id,
                                            genesis__SSN__c, 
                                            ints__middle_name__c,
                                            Email,
                                            Confirm_Email__c,
                                            Confirm_SSN__c,
                                            MobilePhone,
                                            HomePhone,
                                            Phone,
                                            MailingStreet,
                                            MailingCity,
                                            MailingState,
                                            MailingPostalCode,
                                            Mailing_County__c,
                                            Suffix__c,
                                            clcommon__Marital_Status__c,
                                            Title,
                                            Birthdate,
                                            AccountId,
                                            Account.genesis__Business_Information__c,
                                            Account.Kyc_Verified__c
                                        FROM Contact
                                        WHERE genesis__SSN__c = :ssn];
        if(!contactList.isEmpty()){
            duplicatesMap.put(DUPLICATE_FOUND, true);
            duplicatesMap.put(CONTACT_KEY, contactList[0]);

            List<Account> accountList = [SELECT Id,
                                                Name,
                                                Unique_id__c,
                                                clcommon__Email__c,
                                                Confirm_Email__c,
                                                Phone,
                                                Work_Number__c,
                                                Home_Number__c,
                                                BillingStreet,
                                                BillingCity,
                                                BillingState,
                                                BillingPostalCode,
                                                Billing_County__c,
                                                Year_Began_Farming__c,
                                                genesis__business_information__c,
                                                RecordTypeId,
                                                CIF_Number__c,
                                                Kyc_Verified__c
                                        FROM Account
                                        WHERE Id =: contactList[0].AccountId];
                                        
            duplicatesMap.put(ACCOUNT_KEY, accountList[0]);

            List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                                Name,
                                                                                genesis__Tax_Identification_Number__c,
                                                                                genesis__State_of_Incorporation__c
                                                                        FROM genesis__business_information__c
                                                                        WHERE Id =: accountList[0].genesis__business_information__c];
            duplicatesMap.put(BUSINESS_INFO, businessInfoList[0]);
        }
        return duplicatesMap;
    }

    
    /**
    * @description : validates whether a duplicate corportation exists or not
    * @author Krishanu Chinya | 07-10-2024 
    * @param taxId 
    * @param legalEntityTypeId  
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> validateDuplicateCorporation(String taxId, Id legalEntityTypeId) {
        Map<String, Object> duplicatesMap = new Map<String, Object>();
        duplicatesMap.put(DUPLICATE_FOUND, false);

        if(String.isBlank(taxId)){
            return duplicatesMap;
        }
        
        List<Account> corporationAccList = [SELECT Id,
                                                    clcommon__Email__c,
                                                    Confirm_Email__c,
                                                    clcommon__Legal_Entity_type__c,
                                                    clcommon__Legal_entity_Type__r.Name,
                                                    Coop_Type__c,
                                                    genesis__business_information__c,
                                                    ParentId,
                                                    Phone,
                                                    Unique_id__c,
                                                    Work_Number__c,
                                                    Home_Number__c,
                                                    BillingStreet,
                                                    BillingCity,
                                                    BillingState,
                                                    BillingPostalCode,
                                                    Kyc_Verified__c
                                                FROM Account
                                                WHERE genesis__business_information__r.genesis__Tax_Identification_Number__c = :taxId
                                                ];

        if(!corporationAccList.isEmpty()){
            duplicatesMap.put(DUPLICATE_FOUND, true);
            duplicatesMap.put(ACCOUNT_KEY, corporationAccList[0]);

            List<genesis__Business_Information__c> corpBusinessInfoList = [SELECT Id,
                                                                                    genesis__Tax_Identification_Number__c,
                                                                                    genesis__State_of_Incorporation__c
                                                                            FROM genesis__business_information__c
                                                                            WHERE Id =: corporationAccList[0].genesis__business_information__c];
            duplicatesMap.put(BUSINESS_INFO, corpBusinessInfoList[0]);

            List<Contact> corpContactList = [SELECT Id,
                                                    genesis__SSN__c,
                                                    Confirm_SSN__c,
                                                    Confirm_Email__c,
                                                    MailingCity,
                                                    MailingState,
                                                    MailingStreet,
                                                    FirstName,
                                                    LastName,
                                                    Email,
                                                    MobilePhone,
                                                    HomePhone,
                                                    Phone,
                                                    Account.Kyc_Verified__c
                                            FROM Contact
                                            WHERE AccountId =: corporationAccList[0].Id];
            duplicatesMap.put(CONTACT_KEY,corpContactList[0]);
        }

        return duplicatesMap;
    }

    /**
    * @description : Method to check duplicate coapplicant
    * @author Krishanu Chinya | 07-11-2024 
    * @param contactIdList 
    * @param applicationId 
    **/
    public static void checkForDuplicateCoapplicant(List<Id> contactIdList, Id applicationId){
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    clcommon__Account__r.Unique_Id__c
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Contact__c IN :contactIdList 
                                                AND genesis__Application__c =: applicationId];
        if(!partyList.isEmpty()){
            ExternalExceptionUtil.throwCustomException(partyList[0].clcommon__Account__r.Unique_Id__c  + ExternalConstants.COAPPLICANT_ALREADY_ADDED);
        }
    }

    /**
    * @description : Method to validate application for scoring
    * @author Krishanu Chinya | 03-01-2025 
    * @param appObj 
    **/
    public static void validateAppForScoring(genesis__Applications__c appObj){
        if(String.isBlank(appObj.signing_method__c)){
            ExternalExceptionUtil.throwCustomException(ExternalConstants.NO_SIGNING_METHOD);
        }
        else if((appObj.signing_method__c == ExternalConstants.PAPER_SCANNED & appObj.genesis__Status__c != ExternalConstants.E_SIGN_PENDING_APPLICATION_STATUS)
                || (appObj.signing_method__c != ExternalConstants.PAPER_SCANNED & appObj.genesis__Status__c != ExternalConstants.SIGNATURE_COMPLETED_APPLICATION_STATUS)){
            ExternalExceptionUtil.throwCustomException(ExternalConstants.APP_IS_NOT_READY_FOR_SCORING);
        }
    }
}