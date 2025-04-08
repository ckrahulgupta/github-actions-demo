/**
 * @description       : 
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 04-12-2024
 * @last modified by  : Soumik Pattanayak
**/
global without sharing class PortalExportLoanPayoff implements clcommon.PortalCustomRemoteAPI1{
    private static final String KEY_APPLICATIONS = 'applicationId';
    private static final String KEY_APP_ID = 'appid';
    private static final String KEY_PDF = 'pdf';

    private static final String PORTAL_EXPORT_API = 'PortalExportAPI';


    Map<String, Object> responseFieldMap = new Map<String, Object>();
    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();


    /**
     * @description : Purpose of this method is to validate the application and export the Loan Payoff details using the "LoanPayoff" VF page.
     * @param applicationiId 
     * @exception 
     */
    public void exportPayoff(String applicationiId){  
        List<genesis__Applications__c> recordList= [SELECT 
                                                    Id,
                                                    Interest__c,
                                                    Note_Date__c,
                                                    genesis__Loan_Number__c,
                                                    genesis__Account__r.name,
                                                    genesis__Maturity_Date__c
                                                    FROM genesis__Applications__c 
                                                    WHERE id = :applicationiId 
                                                    Limit 1];
        
        if(recordList[0].genesis__Loan_Number__c == null){
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
        if(recordList[0].genesis__Maturity_Date__c == null){
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }               

        if(recordList[0].genesis__Account__r.name == null){
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
        pageReference pdfPage = Page.LoanPayoff;
  
        String appId = applicationiId;
        pdfPage.getParameters().put(KEY_APP_ID,appId);

        if(!Test.isRunningTest()){
            responseFieldMap.put(KEY_PDF, EncodingUtil.base64Encode(pdfPage.getContentAsPDF()));
        }
    }

    /**
     * @description : This method takes the portal request and process the request to Export the Loan Payoff details.
     * @param componentStructureName 
     * @param disclosureNames 
     * @param request 
     * @return  `clcommon.Response`
     * @exception 
     */
    global clcommon.Response invokeAction(String componentStructureName,String[] disclosureNames,Map<String, Object> request){
        SavePoint dbSavePoint = Database.setSavepoint();
        try{
            if(request.get(KEY_APPLICATIONS)==null){
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            String applicationId = String.valueOf(request.get(KEY_APPLICATIONS));
            exportPayoff(applicationId);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(responseFieldMap));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS;  
        } catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, PORTAL_EXPORT_API);
        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, PORTAL_EXPORT_API);
        }
        return response;

    }

}