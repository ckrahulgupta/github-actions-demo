/**
 * @description       : 
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 06-19-2024
 * @last modified by  : Sk Minsar
**/

global without sharing class PortalLoanStatusCountAPI implements clcommon.PortalCustomRemoteAPI1 {

    // parameters specific for this class [start]
    public static final String CLASS_NAME = 'PortalLoanStatusCountAPI';
    public static final String KEY_LOAN_STATUS_COUNT = 'loanStatusCount';
    // parameters specific for this class [end]
    
    /**
    * @description - Purpose of this method is to provide the count for different loan status and send that to portal.
    * @author Arka Jyoti Deb | 04-27-2022 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames, 
                                                Map<String, Object> argumentsFromPortal) {
        Integer value;
        // Integer year = (Date.today() < Date.newInstance(Date.today().year(), 07, 1)) ? Date.today().year() : Date.today().year() + 1;
        
        Integer month = System.today().month();
        Integer currYear = System.Today().year();
        Integer prevYear = System.Today().year();

        if (month >= 6) {
            currYear += 1;
        }

        if (month < 6) {
            prevYear -= 1;
        }

        List<User> currentUserList = new List<User>();
        clcommon.Response response = new clcommon.Response();
        Map<String,Map<String,Integer>> parseResponseMap = new Map<String,Map<String,Integer>>();
        List<genesis__Applications__c> objApplicationList = new List<genesis__Applications__c>();
        List<clcommon.PortalCustomRemoteActionRecord> responseDataList = new List<clcommon.PortalCustomRemoteActionRecord>();
        Map<String,Integer> responseMap = new Map<String, Integer> {
            PortalConstants.ACTIVE_STATUS => 0,
            PortalConstants.CLOSED_STATUS => 0,
            PortalConstants.CURRENT_CROP_YEAR => 0,
            PortalConstants.PRIOR_CROP_YEAR => 0,
            PortalConstants.PAST_DUE => 0,
            PortalConstants.EVERGREEN_ELIGIBLE => 0
        };
        try {
            currentUserList = [SELECT Id, 
                                      accountId,
                                      Account.ParentId
                               FROM User 
                               WHERE id =:UserInfo.getUserId()];
            if(currentUserList == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            objApplicationList = [SELECT Id,
                                         genesis__Status__c,
                                         Crop_Year__c,
                                         genesis__Maturity_Date__c,
                                         Past_Due_Amount__c,
                                         Is_Evergreen_Eligible__c
                                  FROM genesis__Applications__c
                                  WHERE (genesis__Status__c =: PortalConstants.ACTIVE_APPLICATION_STATUS
                                        OR genesis__Status__c =: PortalConstants.CLOSED_APPLICATION_STATUS
                                        OR genesis__Status__c =: PortalConstants.APPROVED_APPLICATION_STATUS)
                                  AND Id IN (SELECT genesis__Application__c
                                             FROM clcommon__Party__c 
                                             WHERE clcommon__Account__r.Id = :currentUserList[0].accountId 
                                             AND genesis__Application__r.Dealer_Name__c = :currentUserList[0].Account.ParentId)];
            Set<genesis__Applications__c> objApplicationSet = new Set<genesis__Applications__c>(objApplicationList);
            for(genesis__Applications__c objApplication: objApplicationSet){
                if(objApplication.genesis__Status__c == PortalConstants.ACTIVE_APPLICATION_STATUS){
                    value = responseMap.get(PortalConstants.ACTIVE_STATUS);
                    responseMap.put(PortalConstants.ACTIVE_STATUS, value + 1);
                }
                else if(objApplication.genesis__Status__c == PortalConstants.CLOSED_APPLICATION_STATUS){
                    value = responseMap.get(PortalConstants.CLOSED_STATUS);
                    responseMap.put(PortalConstants.CLOSED_STATUS, value + 1);
                }

                if(String.valueOf(currYear).equalsIgnoreCase(objApplication.Crop_Year__c)){
                    value = responseMap.get(PortalConstants.CURRENT_CROP_YEAR);
                    responseMap.put(PortalConstants.CURRENT_CROP_YEAR, value + 1);
                }
                else if(String.valueOf(prevYear).equalsIgnoreCase(objApplication.Crop_Year__c)){
                    value = responseMap.get(PortalConstants.PRIOR_CROP_YEAR);
                    responseMap.put(PortalConstants.PRIOR_CROP_YEAR, value + 1);
                }
                if(objApplication.genesis__Status__c == PortalConstants.ACTIVE_APPLICATION_STATUS && objApplication.Past_Due_Amount__c > 0){
                    value = responseMap.get(PortalConstants.PAST_DUE);
                    responseMap.put(PortalConstants.PAST_DUE, value + 1);
                }
                if(objApplication.Is_Evergreen_Eligible__c == PortalConstants.TRUE_VALUE){
                    value = responseMap.get(PortalConstants.EVERGREEN_ELIGIBLE);
                    responseMap.put(PortalConstants.EVERGREEN_ELIGIBLE, value + 1);
                }
            }

            responseMap.put(PortalConstants.ALL_APPLICATION, objApplicationSet.size());
            parseResponseMap.put(KEY_LOAN_STATUS_COUNT,responseMap);
            responseDataList.add( new clcommon.PortalCustomRemoteActionRecord(parseResponseMap));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseDataList);
            response.content = null;
            response.status = clcommon.Constants.SUCCESS; 
            
        } catch (CustomException customException) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customException.getMessage();
            PortalHelper.saveExceptionLog(customException, CLASS_NAME);
        } catch (Exception objException) {
            response.status = clcommon.Constants.API_EXCEPTION; 
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response; 
    }
}