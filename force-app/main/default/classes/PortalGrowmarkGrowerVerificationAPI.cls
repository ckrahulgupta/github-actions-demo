/**
 * @description       : This API is called when growmark grower click Sign Up after entering their email and ssn on the registration page. Registration link is being sent to
 *                      the growers who don't have the user through End Of Month Email Notification. It create a user for the grower who don't have the user.
 * @author            : Ravi Ranjan
 * @group             : 
 * @last modified on  : 09-01-2025
 * @last modified by  : Soumik Pattanayak
**/
global without sharing class PortalGrowmarkGrowerVerificationAPI implements clcommon.PortalCustomRemoteAPI1{
    private final String CLASS_NAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    private static final String EMAIL_ID = 'email';
    private static final String SSN = 'ssn';
    /**
    * @description 
    * @author Ravi Ranjan | 03-05-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                                String[] disclosureNames,
                                                Map<String, Object> argumentsFromPortal){
        SavePoint dbSavepoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();

        try {
            String emailId = (argumentsFromPortal.containsKey(EMAIL_ID)) ? String.valueOf(argumentsFromPortal.get(EMAIL_ID)) : null;
            String ssn = (argumentsFromPortal.containsKey(SSN)) ? String.valueOf(argumentsFromPortal.get(SSN)) : null;
            User newPortalUser = new User();
            // validate emailId and ssn
            PortalApplicationOriginationHelper.checkForBlankParameter(emailId);
            PortalApplicationOriginationHelper.checkForBlankParameter(ssn);
            
            //quering on conatct to to get list of contact having same SSN and Email
            List<Contact> contactList = [SELECT Id,
                                               AccountId,
                                               Account.Coop_Type__c,
                                               Account.CIF_Number__c, 
                                               FirstName, 
                                               LastName, 
                                               genesis__SSN__c, 
                                               Email 
                                        FROM Contact 
                                        WHERE genesis__SSN__C =: ssn
                                        AND Email =: emailId];
            // checking if contactList is empty or not
            PortalApplicationOriginationHelper.checkEmptyList(contactList, PortalConstants.INVALID_CREDENTIALS);
            //Validate if grower's user exist or not ? If user exist then an exception is thrown else we will create a user
            List<User> userObj = PortalApplicationOriginationHelper.checkGrowerUserExistance(contactList);
            if(!userObj.isEmpty()){
                System.enqueueJob(new UpdateUserPermissionSetQueueable(userObj[0].Id, new List<String>{PortalConstants.WHITE_LABEL_COOP_TYPE}));
                response.status = clcommon.Constants.SUCCESS;
                return response;
            }

            //Create a user for the grower
            newPortalUser.Email = contactList[0].Email;
            newPortalUser.FirstName = contactList[0].FirstName;
            newPortalUser.LastName = contactList[0].LastName; 
            newPortalUser.ContactId = contactList[0].Id;
            newPortalUser.ProfileId = PortalApplicationOriginationHelper.getProfileByName(PortalConstants.GMK_GROWER_PROFILE)[0].Id;

            newPortalUser.LanguageLocaleKey = PortalConstants.ENGLISH_US;
            newPortalUser.LocaleSidKey = PortalConstants.ENGLISH_US;
            newPortalUser.TimeZoneSidKey = PortalConstants.AMERICA_LOS_ANGELES_TIME_ZONE;
            newPortalUser.EmailEncodingKey = PortalConstants.UTF_8_ENCODING;
            
            newPortalUser.UserName = contactList[0].FirstName.subString(0,1) + contactList[0].LastName + PortalConstants.AT_SIGN + contactList[0].Account.CIF_Number__c + PortalConstants.DOT_COM;
            if(contactList[0].Lastname.length() > PortalConstants.SEVEN_VALUE){
                newPortalUser.Alias = contactList[0].Firstname.substring(0,1).toLowerCase() + contactList[0].Lastname.substring(0,7).toLowerCase();
            }else{
                newPortalUser.Alias = contactList[0].Firstname.substring(0,1).toLowerCase() + contactList[0].Lastname.toLowerCase();
            }
            newPortalUser.CommunityNickname = contactList[0].FirstName + PortalConstants.DOT + contactList[0].LastName + PortalConstants.DOT + contactList[0].Account.CIF_Number__c;
            Database.Insert(newPortalUser, true);
            System.enqueueJob(new UpdateUserPermissionSetQueueable(newPortalUser.Id, new List<String>{PortalConstants.WHITE_LABEL_COOP_TYPE}));
            response.status = clcommon.Constants.SUCCESS;

        } catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, CLASS_NAME);
        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response;

    }
   
}