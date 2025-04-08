/**
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 02-27-2025
 * @last modified by  : Shristy Kumari
**/
public with sharing class EnableGrowerPortal {
    private static final String SUCCESS_MSG = 'Success';
    private static final String COOP_TYPE_C = 'Coop_Type__c';
    //private static List<String> permissionSetSelectedList = new List<String>();
    /**
     * @description
     * @param
     * @return
     */
    public class PermissionSetWrapper{
        /**
         * @description : stores the id and the account object in a map
         */
        @AuraEnabled public List<String> psList {get; set;}

        /**
         * @description : stores the account Id and whether it has relation or not
         */
        @AuraEnabled public Map<String, Boolean> isRelatedMap {get; set;}
    }
    /**
     * @description : this method fetches all the permission set applicable for the user
     * @param cntId
     * @return List<String>
     */
    @AuraEnabled(cacheable=true)
    public static PermissionSetWrapper getPermissionSetList(String cntId){
        List<AggregateResult> relationList = [SELECT Dealer__r.Coop_Type__c, COUNT(id)
                                                                FROM Dealer_Applicant_Relationship__c 
                                                                WHERE Applicant_Contact__c = :cntId 
                                                                WITH SECURITY_ENFORCED
                                                                GROUP BY Dealer__r.Coop_Type__c];
        Set<String> permissionSetNameList = new Set<String>();
        for(AggregateResult relationObj: relationList){
            if(relationObj.get(COOP_TYPE_C) == PortalConstants.GROWMARK_COOP_TYPE){
                permissionSetNameList.add(PortalConstants.GROWMARK_COOP_TYPE);
            }else{
                permissionSetNameList.add(PortalConstants.GREYLABEL_COOP_TYPE);
            }
        }
        PermissionSetWrapper permissionSetList = new PermissionSetWrapper();
        permissionSetList.psList = new List<String>(new List<String>(permissionSetNameList));
        permissionSetList.isRelatedMap = new Map<String, Boolean>();
        for(String permission: permissionSetNameList){
            Boolean related = false;
            String coopName;
            if(permission == PortalConstants.GROWMARK_COOP_TYPE){
                coopName = PortalConstants.WHITE_LABEL_COOP_TYPE;
            }else{
                coopName = PortalConstants.GREY_LABEL_COOP_TYPE;
            }
            if(checkPermissionSet(cntId, coopName)){
                related=true;
            }
            permissionSetList.isRelatedMap.put(permission, related);
        }
        return permissionSetList;
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 31-12-2024 
    * @param cntId
    * @param permissionSetName 
    * @return Boolean 
    **/
    public static Boolean checkPermissionSet(String cntId, String permissionSetName){
        List<User> growerUser = getExistingUser(cntId);
        if(growerUser.isEmpty()){
            return false;
        }
        List<PermissionSetAssignment> psa = [SELECT PermissionSetId, 
                                                    permissionSet.Name 
                                             FROM PermissionSetAssignment 
                                             WHERE permissionSet.Name = :permissionSetName 
                                             AND AssigneeId = :growerUser[0].id];
        return psa.size()>=1;
    }

    /**
     * @description : this method updates permission set
     * @param selectedPermissionSetList
     * @param contactId
     * @return String
     * @exception
     */
    @AuraEnabled
    public static String updatePermissionSet(List<String> selectedPermissionSetList,Id contactId){
        try {
            String coopType;
            List<String> assignPermissionSetList = new List<String>();
            if(selectedPermissionSetList.size()==2){
                coopType=PortalConstants.BOTH_COOP_TYPE;
                assignPermissionSetList = new List<String>{PortalConstants.WHITE_LABEL_COOP_TYPE, PortalConstants.GREY_LABEL_COOP_TYPE};
            }else if(selectedPermissionSetList.size()==1 && selectedPermissionSetList[0] == PortalConstants.GROWMARK_COOP_TYPE){
                coopType = PortalConstants.WHITE_LABEL_COOP_TYPE;
                assignPermissionSetList = new List<String>{PortalConstants.WHITE_LABEL_COOP_TYPE};
            }else if(selectedPermissionSetList.size()==1 && selectedPermissionSetList[0] == PortalConstants.GREYLABEL_COOP_TYPE){
                coopType = PortalConstants.GREY_LABEL_COOP_TYPE;
                assignPermissionSetList = new List<String>{ PortalConstants.GREY_LABEL_COOP_TYPE};
            }
            enableUserForGrowerPortal(contactId, coopType);
            List<User> growerUser = getExistingUser(contactId);
            if(!growerUser.isEmpty()){
                System.enqueueJob(new UpdateUserPermissionSetQueueable(growerUser[0].Id, assignPermissionSetList));
            }
        }
        catch (CustomException objCustomException){
            throw new CustomException(objCustomException.getMessage());
        }
        catch (Exception e){
            return PortalConstants.SOMETHING_WENT_WRONG;
        }
        return SUCCESS_MSG;
    }

    /**
    * @description : this method is used to enable user to grower portal
    * @author Krishanu Chinya | 02-19-2024 
    * @param contactId 
    * @param coopType 
    **/
    public static Void enableUserForGrowerPortal(Id contactId, String coopType){
        //Update the Grower Account's Owner to the back end user or the current user
        Contact growerContact = getContactById(String.valueOf(contactId));
        if(growerContact.Email == null){
            throw new CustomException(PortalConstants.APPL_EMAIL_MISSING);
        }
        Account growerAccount = [SELECT Id, 
                                        OwnerId 
                                FROM Account 
                                WHERE Id = :growerContact.AccountId];

        growerAccount.OwnerId = UserInfo.getUserId();
        Database.update(growerAccount);
        //Updates the user profile to grower, and if there isn't any grower created. Creates a grower User
        updateUser(String.valueOf(growerContact.Id), coopType);
    }

    /**
    * @description : updates the user details
    * @author Krishanu Chinya | 02-19-2024 
    * @param contactId 
    * @param coopType 
    **/
    @future
    private static void updateUser(String contactId, String coopType){
        List<User> growerUser = getExistingUser(contactId);
        Contact growerContact = getContactById(contactId);
        Profile growerProfile = new Profile();

        //for growmark, assign growmark porfile
        if(growerContact.Account.Coop_Type__c == PortalConstants.GROWMARK_COOP_TYPE){
            growerProfile = getProfileByName(PortalConstants.GMK_GROWER_PROFILE);
        }
        else{
            growerProfile = getProfileByName(PortalConstants.GROWER_PROFILE);
        }
        if(growerUser.size() == 0){
            New_Portal_User__e newUserObj = new New_Portal_User__e(First_Name__c = growerContact.FirstName ,
                                                    Last_Name__c = growerContact.LastName, 
                                                    Email__c = growerContact.Email, 
                                                    Contact_Id__c = growerContact.Id, 
                                                    Coop_Type__c = coopType,
                                                    Profile_Id__c = growerProfile.id,
                                                    Account_Id__c = growerContact.AccountId,
                                                    CIF_Number__c = growerContact.Account.CIF_Number__c);

            Database.SaveResult result = EventBus.publish(newUserObj);
            if(!result.isSuccess()){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
        }
    }

    /**
    * @description : fetches an existing user by contact id
    * @author Krishanu Chinya | 02-19-2024 
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
    * @description : fetches the profile by name
    * @author Krishanu Chinya | 02-19-2024 
    * @param profileName 
    * @return Profile 
    **/
    private static Profile getProfileByName(String profileName){
        return [SELECT Id
                FROM Profile 
                WHERE Name = :profileName];
    }

    /**
    * @description : fetches the contact by contact id
    * @author Krishanu Chinya | 02-19-2024 
    * @param contactId 
    * @return Contact 
    **/
    private static Contact getContactById(String contactId){
        return [SELECT Id, 
                        AccountId,
                        Account.Coop_Type__c,
                        Account.CIF_Number__c, 
                        Email, 
                        FirstName, 
                        LastName 
                FROM Contact 
                WHERE Id = :contactId];
    }
}