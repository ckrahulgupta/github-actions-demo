/**
 * @description       : this class is used for data migration to create users
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 28-01-2025
 * @last modified by  : Soumik Pattanayak
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   19-04-2023   Subham Nandi   Initial Version
**/
global with sharing class EnableUsersQueueable implements Queueable{
    String contactId;
    String profileId;
    //String CLASS_NAME = 'EnableUsersQueueable';
    private final String CLASS_NAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(PortalConstants.SIGN_BY));  
    private final String USER_EXISTS = ' User already Exists : ';

    /**
    * @description Constructor to set 
    * @author Ayan Bhowmik | 02-28-2024 
    * @param contactId 
    * @param profileId 
    **/
    global EnableUsersQueueable(String contactId, String profileId) {
        this.contactId = contactId;
        this.profileId = profileId;
    }

    /**
    * @description Fetching Existing User
    * @author Ayan Bhowmik | 02-28-2024 
    * @param contactId 
    * @return List<User> 
    **/
    private static List<User> getExistingUser(String contactId){
        return [SELECT Id,
                        ProfileId
                FROM User 
                WHERE ContactId = :contactId];
    }

    /**
    * @description Fetching Contact by Id
    * @author Ayan Bhowmik | 02-28-2024 
    * @param contactId 
    * @return Contact 
    **/
    private static Contact getContactById(String contactId){
        return [SELECT Id, 
                        AccountId, 
                        Email, 
                        FirstName, 
                        LastName 
                FROM Contact 
                WHERE Id = :contactId];
    }

    /**
    * @description Fetching Profile Name by Id
    * @author Ayan Bhowmik | 02-28-2024 
    * @param id 
    * @return String 
    **/
    private static String getProfileNameById(String id){
        return [SELECT Name 
                FROM Profile 
                WHERE Id = :id].Name;
    }

    /**
    * @description The purpose of this method is to create grower user.
    * @author Ayan Bhowmik | 02-28-2024 
    * @param context 
    **/
    public void execute(QueueableContext context){
        try {
            List<User> objGrowerUser = getExistingUser(contactId);
            if(objGrowerUser.size() != 0){
                throw new CustomException(USER_EXISTS + objGrowerUser);
            }
            Contact objGrowerContact = getContactById(contactId);

            //Create an user of profile grower
            User newPortalUser = new User();
            newPortalUser.Email = objGrowerContact.Email;
            newPortalUser.FirstName = objGrowerContact.FirstName;
            newPortalUser.LastName = objGrowerContact.LastName; 
            newPortalUser.ContactId = contactId;
            newPortalUser.ProfileId = profileId;
            newPortalUser.UserName = objGrowerContact.Email;

            newPortalUser.LanguageLocaleKey='en_US';
            newPortalUser.LocaleSidKey='en_US';
            newPortalUser.TimeZoneSidKey='America/Los_Angeles';
            newPortalUser.EmailEncodingKey='UTF-8';

            newPortalUser.Alias = objGrowerContact.FirstName.subString(0,1) + objGrowerContact.LastName.subString(0,1) + Integer.valueOf(Math.random() * 100);
            newPortalUser.CommunityNickname = objGrowerContact.FirstName + '.' + objGrowerContact.LastName + Integer.valueOf(Math.random() * 100);
            Database.Insert(newPortalUser,true);


        } catch (Exception objException) {
            Database.insert(new clcommon__Log__c(Name = CLASS_NAME,
                    clcommon__Message__c = CLASS_NAME  
                    + objException.getStackTraceString()
                    + objException.getMessage(),
                    clcommon__Time__c = System.Now()), false);
        }
    }
}