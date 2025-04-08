/**
 * @description       : API to update the contact details for a Grower
 * @author            : iAyush
 * @last modified on  : 02-15-2025
 * @last modified by  : Sk Minsar
**/
global without sharing class PortalSaveAccountDetails  implements clcommon.PortalCustomRemoteAPI1 {
    private static final String KEY_CONTACT= 'contact';
    String contactRecord = '';
    /**
     * @description Purpose of this method is to take Contact fields and update it on the Contact of the logged in user
     * @param componentStrName 
     * @param disclosureNames 
     * @param argumentsFromPortal 
     * @return  `clcommon.Response`
     * @exception 
     */
    global clcommon.Response invokeAction(String componentStrName,
                                          String[] disclosureNames,
                                          Map<String, Object> argumentsFromPortal) {
        
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        Contact objContact = new Contact();

        try{
            contactRecord = String.valueOf(argumentsFromPortal.get(KEY_CONTACT));
            // Checking if all the Required Params are present or not
            if (String.isBlank(contactRecord)) {
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            objContact = (Contact) Json.deserialize(contactRecord, Contact.class);
            List<User> loggedInUser = [SELECT Id,
                                            ContactId,
                                            AccountId,
                                            Account.clcommon__Legal_Entity_Type__r.Name
                                            FROM USER
                                            WHERE Id = :UserInfo.getUserId()];

            objContact.Id = loggedInUser[0].ContactId;
            Database.Upsert(objContact ,false);

            //Updating Account Name for Sole Prop Entity
            if(loggedInUser[0]?.Account?.clcommon__Legal_Entity_Type__r?.Name == PortalConstants.SOLE_PROP_ENTITY && !String.isBlank(objContact?.LastName) && !String.isBlank(loggedInUser[0]?.AccountId)){
                Account objAccount = new Account(Id = loggedInUser[0].AccountId);
                objAccount = setAccountName(objAccount, objContact);
                Database.update(objAccount, false);
            }
            response.status = clcommon.Constants.SUCCESS;
        }
        catch (Exception ex) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
        }
        return response;
   }

   /**
   * @description - Set Account name based on contact firstname and lastname and middle name if present
   * @author Sk Minsar | 02-14-2025 
   * @param accountObj 
   * @param contactObj 
   * @return Account 
   **/
   private static Account setAccountName(Account accountObj, Contact contactObj){
        if(string.isBlank(contactObj.FirstName) && string.isBlank(contactObj.ints__Middle_Name__c)) {
            accountObj.Name = contactObj.LastName;
        }
        else if(string.isBlank(contactObj.ints__Middle_Name__c)){
            accountObj.Name = contactObj.LastName + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + contactObj.FirstName;
        }
        else if(string.isBlank(contactObj.FirstName)){
            accountObj.Name = contactObj.LastName + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + contactObj.ints__Middle_Name__c;
        }
        else{
            accountObj.Name = contactObj.LastName + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + contactObj.FirstName + PortalConstants.SPACE_STRING + contactObj.ints__Middle_Name__c;
        }
        return accountObj;
    }
}