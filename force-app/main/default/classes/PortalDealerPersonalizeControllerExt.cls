/**
 * @description       : Purpose of this class is to return the dealer of the logged in certified lender or sales agent
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  : Tuhin Bhunia
**/
public without sharing class PortalDealerPersonalizeControllerExt {

    /**
     * @description : Controller class constructor
     * @param portalActions 
     */
    public PortalDealerPersonalizeControllerExt(clcommon.PortalActions portalActions) {
        
    }

    /**
     * @description : Purpose of this method is to fetch the value of "coop" variable from URL
     * @return  `String`
     */
    public static String getCoopTypeFromURL() {
        if (System.currentPageReference().getParameters().containsKey('coop')) {
            return System.currentPageReference().getParameters().get('coop').toLowerCase();
        }
        return 'cfa';
    }

    /**
     * @description : This method is used to get the logged in user details.
     * @return  `User`
     * @exception 
     */
    private static User getLoggedInUser() {

        if (!Schema.sObjectType.User.isAccessible()) {
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS);
        }

        List<User> loggedInUser = [
                SELECT Id,
                       AccountId,
                       ContactId,
                       Account.ParentId,
                       Account.Parent.RecordTypeId,
                       Account.Parent.Coop_Type__c,
                       Account.RecordTypeId,
                       Account.Coop_Type__c
                FROM User
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
            ];

        if (loggedInUser.size() == 0) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }

        return loggedInUser[0];
    }

    /**
     * @description : This method is used to get the RecordType object reference using the provided RecordType object Id
     * @param recordTypeId 
     * @return  `RecordType`
     * @exception 
     */
    private static RecordType getRecordTypeById(Id recordTypeId) {
        if (!Schema.sObjectType.RecordType.isAccessible()) {
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS);
        }
        List<RecordType> recordTypes = [
                SELECT Id, 
                       Name 
                FROM RecordType 
                WHERE Id = :recordTypeId
                LIMIT 1
            ];

        if (recordTypes.size() == 0) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }

        return recordTypes[0];
    }

    /**
     * @description : Purpose of this method is to get the coop type of the logged in user.
     * @return  `String`
     */
    public static String getCoopTypeFromLoggedInUser() {

        User loggedInUser = getLoggedInUser();

        if (loggedInUser.Account.Coop_Type__c != null) {

            RecordType currentRecordType = getRecordTypeById(loggedInUser.Account.recordTypeId);

            if (
                String.valueOf(currentRecordType.Name).equals(PortalConstants.CO_APPLICATION_RECORD_TYPE) || 
                String.valueOf(currentRecordType.Name).equals(PortalConstants.GROWER_PROFILE)
            ) {
                // for grower / co-applicant
                return loggedInUser.Account.Coop_Type__c;
            }
        }  
        
        if (loggedInUser.Account.Parent.Coop_Type__c != null) {

            RecordType currentRecordType = getRecordTypeById(loggedInUser.Account.RecordTypeId);

            if (
                String.valueOf(currentRecordType.Name).equals(PortalConstants.CERTIFIED_LENDER) || 
                String.valueOf(currentRecordType.Name).equals(PortalConstants.CERTIFIED_LENDER_PLUS) || 
                String.valueOf(currentRecordType.Name).equals(PortalConstants.SALES_AGENT) ||
                String.valueOf(currentRecordType.Name).equals(PortalConstants.SALES_AGENT_PLUS) ||
                String.valueOf(currentRecordType.Name).equals(PortalConstants.SALES_AGENT_ADMIN) ||
                String.valueOf(currentRecordType.Name).equals(PortalConstants.INQUIRY) ||
                String.valueOf(currentRecordType.Name).equals(PortalConstants.INQUIRY_PLUS) ||
                String.valueOf(currentRecordType.Name).equals(PortalConstants.PAYMENT_ADMINISTRATOR)
            ) {
                // for dealer users
                return loggedInUser.Account.Parent.Coop_Type__c;
            }
        }

        return null;
    }
}