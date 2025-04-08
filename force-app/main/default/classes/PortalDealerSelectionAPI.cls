/**
 * @description       : Purpose of this API is to switch the parent id of a field staff agent to the selected dealer
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 25-11-2024
 * @last modified by  : Soumik Pattanayak
**/
global without sharing class PortalDealerSelectionAPI implements clcommon.PortalCustomRemoteAPI1 {
    private final String CLASS_NAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));  
    private final String DEALER_KEY = 'dealerAccountId';  

    /**
     * @description - This method fetches the current logged in field staff agen account
     * @return  `Account`
     * @exception 
     */
    private static Account getCurrentFieldStaffAcc(){
        List<Account> loggedInAccountList = [SELECT Id,
                                            ParentId
                                            FROM Account
                                            WHERE Id IN (
                                                SELECT AccountId 
                                                    FROM User
                                                    WHERE Id = :UserInfo.getUserId())
                                            LIMIT 1];

        if (loggedInAccountList.isEmpty()) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        return loggedInAccountList[0];
    }
   
    /**
     * @description - this method switches the parentId of current field staff agent to selected dealer
     * @param componentStructureName 
     * @param disclosureNames 
     * @param request 
     * @return  `clcommon.Response`
     * @exception 
     */
    global clcommon.Response invokeAction(String componentStructureName,
                                        String[] disclosureNames,
                                        Map<String, Object> request) {

        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();

        try {
            String selectedDealerId = 
                    (request.containsKey(DEALER_KEY)) ? String.valueOf(request.get(DEALER_KEY)) : null;

            if (selectedDealerId == null) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }

            //check if user has existing relationship with the dealer
            if (!PortalSecurityUtil.validateDealerByAccount(selectedDealerId) 
                    && !PortalSecurityUtil.validateDealerByGrowerAccount(selectedDealerId) ) {
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }

            //fetching account details of the logged in field staff agent
            Account loggedInAccount = getCurrentFieldStaffAcc();

            //changing parent id of current logged in user
            loggedInAccount.ParentId = selectedDealerId;
            Database.update(loggedInAccount, true);

            response.status = clcommon.Constants.SUCCESS;

        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objException.getMessage();
        }
        return response;
    }
}