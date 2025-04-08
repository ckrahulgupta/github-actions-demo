/**
 * @description       : This portal API class helps in fetching all the loans details for a particular loan ID.
 * @author            :  Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 03-12-2024
 * @last modified by  :  Pritam Roy
**/


global without sharing class PortalNLSLoanDetailsAPI implements clcommon.PortalCustomRemoteAPI1 {

    public static final String NLS_LOAN_DETAILS_API = 'PortalNLSLoanDetailsAPI';
    
    /**
    * @description : Make Callout to get Loan Details
    * @author  Pritam Roy | 03-12-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames, 
                                                Map<String, Object> argumentsFromPortal) {
        
        string loanId;
        List<User> currentUserList = new List<User>();
        clcommon.Response response = new clcommon.Response();
        Map<String,Object> parseResponse = new Map<String,Object>();
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        try {
            currentUserList = [select id, 
                                    accountId 
                                    FROM User 
                                    where id =:UserInfo.getUserId()];
            //Check required params.
            if (null == argumentsFromPortal.get(ConstantValues.LOAN_ID)){
                throw new CustomException(ConstantValues.PARAMETER_MISSING);
            }
            loanId = String.valueOf(argumentsFromPortal.get(ConstantValues.LOAN_ID));
            parseResponse = NLSCallout.nlsGetLoanCalloutMethod(currentUserList[0].accountId, loanId);
            if(parseResponse == null){
                throw new CustomException(ConstantValues.INTEGRATION_FAILED);
            }           
            responseData.add( new clcommon.PortalCustomRemoteActionRecord(parseResponse));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.content = null;
            response.status = clcommon.Constants.SUCCESS; 
        } catch (Exception objException) {
            response.status = clcommon.Constants.API_EXCEPTION;
            Database.insert(new clcommon__Log__c(Name = NLS_LOAN_DETAILS_API ,
                    clcommon__Message__c = NLS_LOAN_DETAILS_API
                    + objException.getStackTraceString()
                    + objException.getMessage(),
                    clcommon__Time__c = System.Now()), false);   
        }
        return response;
    }
}