/**
 * @description       : If Loan Amount and Reserved Amount field is modify in application it will update credit total limit  field  in NLS
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  : Tuhin Bhunia
**/
global without sharing class NLSModifyFieldCallout{

  private static final String APPLICATION_LIST = 'appList';
  
  /**
   * @description : This method is used to update the application fields.
   * @param applicationId 
   * @exception 
   */
  @invocableMethod(label = 'ModifyField')
  public static void nlsUpdateApplicationField(List<String> applicationId){
    try{
      if(applicationId.size()>0){
        callWebService(applicationId);
      }
      else{
        throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
      }
    }
    catch(Exception objException){
      PortalHelper.saveExceptionLog(objException, ConstantValues.NLS_CALLOUT);
    }
  }

  /**
   * @description : This method makes a callout to NLS and updates the credit total draw limit.
   * @param applicationId 
   * @exception 
   */
  @future(callout=true)
  public static void callWebService(List<String> applicationId) {
    try{
      Map<String, Object> requestParamMap = new Map<String, Object>();
      Map<String, Object> queryIdMap = new Map<String, Object>();
      queryIdMap.put(APPLICATION_LIST, applicationId);
      intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
      intframework.BaseIntegrationResponse responseObject;
      responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                            ConstantValues.INTEGRATION_API_TYPE_MODIFY_FIELD,
                                                                                                                        queryIdMap, requestParamMap);

      if(responseObject.getBody() == null){
        throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
      }
    }
    catch(Exception objException){
      PortalHelper.saveExceptionLog(objException, ConstantValues.NLS_CALLOUT);
    }
  }
}