/**
 * @description       : Helper Class for External APIs. Contains Methods to Validate all the necessary Security Params
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 09-09-2024
 * @last modified by  : Suraj Kumar
**/
global inherited sharing class ExternalSecurityUtil {
    /**
    * @description : returns the site admin
    * @author Krishanu Chinya | 05-20-2024 
    * @return String 
    **/
    public static String getSiteAdmin(){
        List<site> siteList = [SELECT Id, AdminId, Admin.Email
                                 FROM site
                                 WHERE AdminId != ''];

        return siteList[0].AdminId;
    }

    /**
    * @description : validates whether correct user id id provided against an application
    * @author Krishanu Chinya | 05-30-2024 
    * @param applicationId 
    * @param userId 
    * @param dealerAccId 
    **/
    public static void  validateBorrowerWithApplication(String applicationId,String userId, Id dealerAccId){
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                    Dealer_Name__c,
                                                                    genesis__Account__r.Unique_Id__c
                                                                FROM genesis__Applications__c
                                                                WHERE Id = :applicationId];
        ExternalApplicationOriginationUtil.checkEmptyList(applicationList, ExternalConstants.APPLICATION_NOT_FOUND);
        
        if((!userId.equals(applicationList[0].genesis__Account__r.Unique_Id__c)) 
                | (dealerAccId != applicationList[0].Dealer_Name__c)){
            throw new CustomException(ExternalConstants.USER_NOT_AUTHORISED);
        }
    }

  
    /**
    * @description : Method to get the Logged In User , This method is used for Agvend API
    * @author Suraj Kumar | 09-09-2024 
    * @return List<User> 
    **/
    public static List<User> getLoggedInUser(){
        List<User> loggedInUser = new List<User>();
        if(Schema.sObjectType.USER.isAccessible()){
            loggedInUser = [SELECT Id,
                                    Profile.Name,
                                    ContactId,
                                    AccountId
                                FROM USER
                                WHERE Id = :UserInfo.getUserId()];
        }
        ExternalApplicationOriginationUtil.checkEmptyList(loggedInUser,PortalConstants.SOMETHING_WENT_WRONG);
        return loggedInUser;
    }
}