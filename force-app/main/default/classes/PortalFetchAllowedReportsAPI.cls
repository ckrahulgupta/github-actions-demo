/**
 * @description       : This class is called from Reports Tab and is used to fetch the list of Reports from the CFA Partner Program Object.
 * @author            : Swapnamoy Chakraborty
 * @group             : 
 * @last modified on  : 07-11-2024
 * @last modified by  : Swapnamoy Chakraborty
**/
global without sharing class PortalFetchAllowedReportsAPI implements clcommon.PortalCustomRemoteAPI1{

    //Constants
    private final String CLASS_NAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));
    
    /**
    * @description : This method fetches the LoggedInUser generates the response and returns.
    * @author Swapnamoy Chakraborty | 07-08-2024
    * @param componentStructureName
    * @param disclosureNames
    * @param request
    * @return clcommon.response
    **/

    global clcommon.Response invokeAction(String componentStructureName,
                                          String[] disclosureNames,
                                          Map<String, Object> request) {
        
        // Starting
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        clcommon.Response response = new clcommon.Response();
        try{
            List<User> loggedInUserList = [SELECT Id,
                                        Account.Parent.CFA_Partner_Program__r.Id
                                        FROM User
                                        WHERE Id = :UserInfo.getUserId()];
            if (loggedInUserList.size() == 0) {
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }

            User loggedInUser = loggedInUserList[0];

            if(loggedInUser.AccountId == null || loggedInUser.Account.ParentId == null || loggedInUser.Account.Parent.CFA_Partner_Program__c == null){
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }

            String programId = loggedInUser.Account.Parent.CFA_Partner_Program__c;
            Map<String, Object> responseMap = createSelectedReportsMap(programId);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(responseMap));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS;
            
        }catch(Exception exceptionObj){
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(exceptionObj, CLASS_NAME);
        }
        return response;
    }

    /**
    * @description : This method is used to convert a Multipicklist into a Map
    * @author Swapnamoy Chakraborty | 07-08-2024
    * @param programId
    * @return Map<String, Object> 
    **/
    
    public static Map<String, Object> createSelectedReportsMap(String programId){

        Map<String, Object> resultMap = new Map<String, Object>();
        
        Schema.DescribeSObjectResult objSchema = CFA_Partner_Program__c.sObjectType.getDescribe(SObjectDescribeOptions.DEFAULT);
        Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getmap();
        List<Schema.Picklistentry> fld =fieldmap.get('Reports__c').getDescribe().getpicklistValues();
        List<String> allReports = new List<String>();
        for(Schema.Picklistentry pl : fld)
        {
            allReports.add(pl.getValue());
        }
        
        List<CFA_Partner_Program__c> programList = [
            SELECT Id,  Reports__c 
            FROM CFA_Partner_Program__c 
            WHERE Id = :programId
        ];

        List<String> selectedReports = programList[0].Reports__c != null ? programList[0].Reports__c.split(';') : new List<String>();

        for(String reportName : allReports){
            Boolean isSelected = selectedReports.contains(reportName);
            String modifiedKey = 'dealerReportLink' + reportName.replaceAll('[^a-zA-Z0-9]', '');
            resultMap.put(modifiedKey, isSelected);
        }

        return resultMap;
        
    }
}