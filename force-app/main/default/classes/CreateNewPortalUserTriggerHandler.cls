/**
 * @description       : 
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 03-19-2025
 * @last modified by  : Ayan Bhowmik
**/
public with sharing class CreateNewPortalUserTriggerHandler {

    /**
    * @description : creates a new user
    * @author Krishanu Chinya | 02-28-2024 
    * @param newPortalUserList 
    **/
    public static void createNewUser(List<New_Portal_User__e> newPortalUserList){
        clcommon.Response response = new clcommon.Response();
        try{
            User userObj = new User();
            String coopType;
            String eventContactId;
            for (New_Portal_User__e event : newPortalUserList) {
                checkForRequiredParameters(event);
                eventContactId = event.Contact_Id__c;
                userObj.Username = event.First_Name__c.subString(0,1) + event.Last_Name__c + PortalConstants.AT_SIGN + event.CIF_Number__c + PortalConstants.DOT_COM;         
                userObj.Email = event.Email__c;
                coopType = event.Coop_Type__c;
                event = updateUserDetails(userObj, event);
                userObj.LastName = event.Last_Name__c;            
                userObj.ProfileId = event.Profile_Id__c;            
                userObj.contactId = event.Contact_Id__c;    
                userObj.emailencodingkey = PortalConstants.EMAIL_ENCODING;
                userObj.languagelocalekey = PortalConstants.ENGLISH_US; 
                userObj.localesidkey = PortalConstants.ENGLISH_US;
                userObj.timezonesidkey = PortalConstants.AMERICA_LOS_ANGELES_TIME_ZONE;
                
            }
            
            List<User> existingUserList = [SELECT Id FROM User WHERE ContactId =: userObj.ContactId];
            Id userId;
            if(existingUserList.size() == 0){
                Database.insert(userObj,true);
                userId = userObj.Id;
            }else{
                userId = existingUserList[0].Id;
            }
            if(coopType == PortalConstants.BOTH_COOP_TYPE){
                System.enqueueJob(new UpdateUserPermissionSetQueueable(userId, new List<String>{PortalConstants.WHITE_LABEL_COOP_TYPE, PortalConstants.GREY_LABEL_COOP_TYPE}));
            }else if(coopType!=null){
                System.enqueueJob(new UpdateUserPermissionSetQueueable(userId, new List<String>{coopType}));
            }
        }
        catch (CustomException objException) {
                response.status = clcommon.Constants.API_EXCEPTION;
                response.errorMessage = objException.getMessage(); 
        } catch (Exception objException) {
                response.status = clcommon.Constants.API_EXCEPTION;
                response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
        }
            
    }

    /**
    * @description updates the user fields
    * @author Soumik Pattanayak | 02-01-2025 
    * @param userObj 
    * @param event 
    * @return New_Portal_User__e 
    **/
    private static New_Portal_User__e updateUserDetails(User userObj, New_Portal_User__e event){
        if(event.Federation_Identifier__c != null){
            userObj.FederationIdentifier = event.Federation_Identifier__c;
        }
        if(event.First_Name__c != null && !String.isblank(event.First_Name__c)){
            userObj.FirstName = event.First_Name__c; 
            userObj.CommunityNickname = event.First_Name__c + event.Last_Name__c + PortalConstants.DOT + event.CIF_Number__c; 
            if(event.Last_Name__c.length() > PortalConstants.SEVEN_VALUE){
                userObj.Alias = event.First_Name__c.substring(0,1).toLowerCase() + event.Last_Name__c.substring(0,7).toLowerCase();
            }else{
                userObj.Alias = event.First_Name__c.substring(0,1).toLowerCase() + event.Last_Name__c.toLowerCase();
            }
        } 
        else{
            userObj.CommunityNickname =  event.Last_Name__c + PortalConstants.DOT + event.CIF_Number__c ; 
            if(event.Last_Name__c.length() > PortalConstants.SEVEN_VALUE){
                userObj.Alias = event.Last_Name__c.substring(0,7).toLowerCase();
            }else{
                userObj.Alias = event.Last_Name__c.toLowerCase();
            }
        }
        return event;
    }
    
    
    /**
    * @description : checks for the required parameters
    * @author Krishanu Chinya | 02-28-2024 
    * @param event 
    **/
    public static void checkForRequiredParameters(New_Portal_User__e event){
        if(event.Last_Name__c == null || event.Email__c == null || event.Profile_Id__c == null || event.Contact_Id__c == null){
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }
}