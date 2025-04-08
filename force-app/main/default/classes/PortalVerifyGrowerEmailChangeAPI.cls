/**
 * @description       : verifies the email change for a grower
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 08-10-2024
 * @last modified by  : Soumik Pattanayak
**/
global without sharing class PortalVerifyGrowerEmailChangeAPI implements clcommon.PortalCustomRemoteAPI1{
    private final String CLASS_NAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    private final String TOKEN = 'token';
    private final String SSN_OR_TIN = 'ssnOrTin';
    private final String LEGAL_ENTITY_TYPE = 'legalEntityType';
    private final String COOP_TYPE_KEY = 'coopType';
    private final String CONTACT_ID_KEY = 'contactId';
    private final String PREVIOUS_EMAIL_KEY = 'prev_email';
    private final String NEW_EMAIL_KEY = 'new_email';
    private final String CREATED_DATE_KEY = 'createdDate';

    private static List<String> nonIndividualEntityList = new List<String>{
        PortalConstants.CORPORATION,
        PortalConstants.LIMITED_LIABILITY_COMPANY,
        PortalConstants.GENERAL_PARTNERSHIP,
        PortalConstants.LIMITED_PARTNERSHIP,
        PortalConstants.JOINT_VENTURE,
        PortalConstants.TRUST
    };

    clcommon.Response response = new clcommon.Response();
    public static final Integer EMAIL_VERIFICATION_TIME_WINDOW = Integer.valueOf(System.Label.Email_Verfication_Time_Window);
    public static final Integer MAX_ATTEMPT = Integer.valueOf(System.Label.Max_Attempt_for_Email_Verification);

    /**
    * @description : verifies the email change for a grower
    * @author Krishanu Chinya | 04-08-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames,Map<String, Object> argumentsFromPortal){
        SavePoint dbSavePoint = Database.setSavepoint();
        try{
            String token = String.valueOf(argumentsFromPortal.get(TOKEN));
            String ssnOrTin = String.valueOf(argumentsFromPortal.get(SSN_OR_TIN));
            String ssnOrTinLastDigits = PortalConstants.EMPTY_STRING;
            List<Contact> growerContactList = new List<Contact>();
    
            //validate the token
            Boolean isValidToken = JWTUtil.isValidEmailVerificationToken(token);
            PortalApplicationOriginationHelper.throwErrorIfFalse(isValidToken, PortalConstants.SOMETHING_WENT_WRONG);
            
            //decrypt the token
            Map<String,String> decryptedValues =  JWTUtil.decryptToken(token);

            checkTimeWindow(decryptedValues.get(CREATED_DATE_KEY));

            //getting the contact list
            growerContactList = [SELECT Id,
                                        email,
                                        Confirm_Email__c,
                                        AccountId,
                                        Account.genesis__Business_Information__r.genesis__Tax_Identification_Number__c,
                                        genesis__SSN__c,
                                        New_Email__c,
                                        Verification_Attempt__c
                                    FROM Contact
                                    WHERE Id =: decryptedValues.get(CONTACT_ID_KEY)];
            PortalApplicationOriginationHelper.checkEmptyList(growerContactList, PortalConstants.SOMETHING_WENT_WRONG);

            //If change is already verifies
            checkIfEmailChangeIsAlreadyVerified(decryptedValues.get(NEW_EMAIL_KEY), growerContactList[0].Email);

            //checks the number of attempt and throws error if max attempt is reached
            checkNumberOfAttempts(Integer.valueOf(decryptedValues.get('attemptNum')), Integer.valueOf(growerContactList[0].Verification_Attempt__c));

            growerContactList[0].Verification_Attempt__c += PortalConstants.ONE_VALUE;
            Database.update(growerContactList[0], true);
            dbSavePoint = Database.setSavepoint();

            //getting last 4 digits of ssn or tin
            if(decryptedValues.get(LEGAL_ENTITY_TYPE) == PortalConstants.SOLE_PROP_ENTITY){
                ssnOrTinLastDigits = String.valueOf(growerContactList[0].genesis__SSN__c).substring(PortalConstants.FIVE_VALUE,PortalConstants.NINE_VALUE);
            }else if(nonIndividualEntityList.contains(decryptedValues.get(LEGAL_ENTITY_TYPE))){
                ssnOrTinLastDigits = String.valueOf(growerContactList[0].Account.genesis__Business_Information__r.genesis__Tax_Identification_Number__c).substring(PortalConstants.FIVE_VALUE,PortalConstants.NINE_VALUE);
            }

            checkForWrongSSNorTIN(ssnOrTinLastDigits,ssnOrTin);

            //match the values
            if(growerContactList[0].Email != decryptedValues.get(PREVIOUS_EMAIL_KEY)
                        || growerContactList[0].New_Email__c != decryptedValues.get(NEW_EMAIL_KEY)){
                throw new CustomException(PortalConstants.INVALID_EMAIL_CHANGE_REQUEST);
            }

            //if values are matched
            //update contact
            growerContactList[0].Email = growerContactList[0].New_Email__c;
            growerContactList[0].Confirm_Email__c = growerContactList[0].New_Email__c;
            growerContactList[0].New_Email__c = null;
            growerContactList[0].Verification_Attempt__c = PortalConstants.ZERO_VALUE;
            Database.update(growerContactList[0], true);

            //update account
            updateGrowerAccount(growerContactList[0]);

            //update user if present
            updateGrowerUser(growerContactList[0].Id,decryptedValues.get(NEW_EMAIL_KEY));

            response.status = clcommon.Constants.SUCCESS;
        }catch (CustomException CustomExceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = CustomExceptionObj.getMessage();
            PortalHelper.saveExceptionLog(CustomExceptionObj, CLASS_NAME);
        } catch (Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(exceptionObj, CLASS_NAME);
        }
        return response;
    }

    /**
    * @description : verifies whether verification attempt is within limit
    * @author Krishanu Chinya | 04-24-2024 
    * @param startingAttemptNum 
    * @param currentAttemptNumber 
    **/
    private static void checkNumberOfAttempts(Integer startingAttemptNum, Integer currentAttemptNumber){
        if(currentAttemptNumber >= (startingAttemptNum + MAX_ATTEMPT)){
            throw new CustomException(PortalConstants.MAX_ATTEMPT_REACHED);
        }
    }

    /**
    * @description : verifies whether the verification link was opened within specified window 
    * @author Krishanu Chinya | 04-11-2024 
    * @param createdDate 
    **/
    private static void checkTimeWindow(String createdDate){
        DateTime startTime = (DateTime)Json.deserialize('"'+createdDate+'"', DateTime.class);
        DateTime endTime = DateTime.now();
        Integer daysBetween = startTime.date().daysBetween(endTime.date());
        daysBetween = Math.abs(daysBetween);
        Integer hoursBetween = endTime.hour() - startTime.hour();
        hoursBetween = Math.abs(hoursBetween);
        Integer totalHoursBetween = (daysBetween*24) + hoursBetween;

        if(totalHoursBetween>EMAIL_VERIFICATION_TIME_WINDOW){
            throw new CustomException(PortalConstants.VERIFICATION_LINK_EXPIRED);
        }
    }

    /**
    * @description : verifies whether the entered ssn/tin is correct
    * @author Krishanu Chinya | 04-08-2024 
    * @param ssnOrTinLastDigits 
    * @param ssnOrTin 
    **/
    private static void checkForWrongSSNorTIN(String ssnOrTinLastDigits,String ssnOrTin){
        //if wrong ssn/tin is entered
        if(ssnOrTinLastDigits != ssnOrTin){
            throw new CustomException(PortalConstants.WRONG_SSN_OR_TIN);
        }
    }

    /**
    * @description : updates the account of the grower
    * @author Krishanu Chinya | 04-08-2024 
    * @param growerContact 
    **/
    private static void updateGrowerAccount(Contact growerContact){
        Account growerAccount = new Account();
        growerAccount.Id = growerContact.AccountId;
        growerAccount.clcommon__Email__c = growerContact.Email;
        growerAccount.Confirm_Email__c = growerContact.Email;
        Database.update(growerAccount, true);
    }

    
    /**
    * @description  : updates the user of the grower, if present
    * @author Krishanu Chinya | 04-11-2024 
    * @param contactId 
    * @param growerEmail 
    **/
    private static void updateGrowerUser(Id contactId, String growerEmail){
        List<User> growerUserList = [SELECT Id,
                                                Email
                                        FROM User 
                                        WHERE ContactId = :contactId];
        if(!growerUserList.isEmpty()){
            growerUserList[0].Email = growerEmail;
            Database.update(growerUserList[0], true);
        }
    }

    /**
    * @description : checks is grower has already verified the email change
    * @author Krishanu Chinya | 04-08-2024 
    * @param emailFromToken 
    * @param emailInContact 
    **/
    private static void checkIfEmailChangeIsAlreadyVerified(String emailFromToken, String emailInContact){
        if(emailFromToken == emailInContact){
            throw new CustomException(PortalConstants.EMAIL_CHANGE_ALREADY_VERIFIED);
        }
    }
}