/**
 * @description       : this api is used to verify the email verification token
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 01-24-2025
 * @last modified by  : Rakesh Saraf
**/
global without sharing class PortalCheckEmailVerificationTokenAPI implements clcommon.PortalCustomRemoteAPI1{
    private final String CLASS_NAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    private final String TOKEN = 'token';
    private final String ATTEMPT_NUM_KEY = 'attemptNum';
    private final String CREATED_DATE_KEY = 'createdDate';
    private final String CONTACT_ID_KEY = 'contactId';
    private final String TOKEN_INVALID_KEY = 'isTokenInvalid';
    private final String TIME_LIMIT_EXCEEDED_KEY = 'isTimeLimitExceeded';
    private final String ALL_ATTWMPTS_EXHAUSTED_KEY = 'isAllAttemptExhausted';
    private final String ATTEMPTS_LEFT_KEY = 'attemptsLeft';

    public static final Integer EMAIL_VERIFICATION_TIME_WINDOW = Integer.valueOf(System.Label.Email_Verfication_Time_Window);
    public static final Integer MAX_ATTEMPT = Integer.valueOf(System.Label.Max_Attempt_for_Email_Verification);


    clcommon.Response response = new clcommon.Response();

    /**
    * @description : used to verify the email verification token
    * @author Krishanu Chinya | 04-26-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames,Map<String, Object> argumentsFromPortal){
        SavePoint dbSavePoint = Database.setSavepoint();
        try{
            String token = String.valueOf(argumentsFromPortal.get(TOKEN));
            Map<String, Object> resultMap = new Map<String, Object>();
            List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
            Boolean isTimeExceeded = false;
            Boolean isAttemptsExhausted = false;
            Integer numOfAttemptsLeft = 0;

            //validate the token
            Boolean isValidToken = JWTUtil.isValidEmailVerificationToken(token);
            //PortalApplicationOriginationHelper.throwErrorIfFalse(isValidToken, PortalConstants.SOMETHING_WENT_WRONG);

            //decrypt the token
            if(isValidToken){
                Map<String,String> decryptedValues =  JWTUtil.decryptToken(token);
                isTimeExceeded = checkTimeWindow(decryptedValues.get(CREATED_DATE_KEY));
                
                List<Contact> growerContactList = [SELECT Id, 
                                                            Verification_Attempt__c 
                                                    FROM Contact 
                                                    WHERE Id =: decryptedValues.get(CONTACT_ID_KEY)];
                PortalApplicationOriginationHelper.checkEmptyList(growerContactList, PortalConstants.SOMETHING_WENT_WRONG);
                
                
                isAttemptsExhausted = checkNumberOfAttempts(Integer.valueOf(decryptedValues.get(ATTEMPT_NUM_KEY)), Integer.valueOf(growerContactList[0].Verification_Attempt__c));
                numOfAttemptsLeft = calculateAttemptsLeft(Integer.valueOf(decryptedValues.get(ATTEMPT_NUM_KEY)), Integer.valueOf(growerContactList[0].Verification_Attempt__c));
            }

            resultMap.put(TOKEN_INVALID_KEY, !isValidToken);
            resultMap.put(TIME_LIMIT_EXCEEDED_KEY, isTimeExceeded);
            resultMap.put(ALL_ATTWMPTS_EXHAUSTED_KEY, isAttemptsExhausted);
            resultMap.put(ATTEMPTS_LEFT_KEY, numOfAttemptsLeft);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(resultMap));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
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
    * @description : calculates the number of attempts left 
    * @author Krishanu Chinya | 04-26-2024 
    * @param startingAttemptNum 
    * @param currentAttemptNumber 
    * @return Integer 
    **/
    private static Integer calculateAttemptsLeft(Integer startingAttemptNum, Integer currentAttemptNumber){
        return ((startingAttemptNum + MAX_ATTEMPT) - currentAttemptNumber);
    }

    
    /**
    * @description : verifies whether the verification link was opened within specified window 
    * @author Krishanu Chinya | 04-11-2024 
    * @param createdDate 
    * @return Boolean 
    **/
    private static Boolean checkTimeWindow(String createdDate){
        DateTime startTime = (DateTime)Json.deserialize('"'+createdDate+'"', DateTime.class);
        DateTime endTime = DateTime.now();
        Integer daysBetween = startTime.date().daysBetween(endTime.date());
        daysBetween = Math.abs(daysBetween);
        Integer hoursBetween = endTime.hour() - startTime.hour();
        hoursBetween = Math.abs(hoursBetween);
        Integer totalHoursBetween = (daysBetween*24) + hoursBetween;

        if(totalHoursBetween>EMAIL_VERIFICATION_TIME_WINDOW){
            return true;
        }
        return false;
    }

    /**
    * @description verifies whether verification attempt is within limit
    * @author Krishanu Chinya | 04-24-2024 
    * @param startingAttemptNum 
    * @param currentAttemptNumber 
    * @return Boolean 
    **/
    private static Boolean checkNumberOfAttempts(Integer startingAttemptNum, Integer currentAttemptNumber){
        if(currentAttemptNumber >= (startingAttemptNum + MAX_ATTEMPT)){
            return true;
        }
        return false;
    }
}