/**
 * @description       : 
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 11-29-2023
 * @last modified by  : Ayush Kumar Singh
**/
public with sharing class InPersonDSGetURLCallout implements Queueable, Database.AllowsCallouts {
    private String envelopeId = '';
    private String role;
    private String appId;
    private String contactId;
    private static final String IN_PERSON_DOCUSIGN = 'InPersonDSGetURLCallout';
    private static final String ENVELOPE_LIST = 'docuSignList';
    private static final String ROLE_LIST = 'roleList';
    private static final String APP_ID_LIST = 'appIdList';
    private static final String CONTACT_ID_LIST = 'contactList';
    private static final String INTEGRATION_FAMILY = 'DocuSign Integration';
    private static final String INTEGRATION_API_TYPE = 'DocuSign Get URL Integration API Type';
    private static final String ENVELOPE_ID = 'envelopeId';
    private static final String ROLE = 'role';
    private static final String APP_ID = 'appId';
    private static final String CONTACT_ID = 'contactId';

    /**
     * @description 
     * @param paramMap 
     * @param roleName 
     */
    public InPersonDSGetURLCallout(Map<String,String> paramMap,String roleName) {
        this.envelopeId = paramMap.get(ENVELOPE_ID);
        this.role = roleName;
        this.appId = paramMap.get(APP_ID);
        this.contactId = paramMap.get(CONTACT_ID);
    }

    /**
     * @description This method helps to call adapter to get url of signer to sign docusign
     * @param context 
     * @exception 
     */
    public void execute(QueueableContext context){
        try{

            //List<dfsle__Recipient__c> objRecipientList = new List<dfsle__Recipient__c>();
            Map<String, Object> requestParamMap = new Map<String, Object>();
            Map<String, Object> queryIdMap = new Map<String, Object>();
            List<Id> envelopeIdList = new List<Id>();
            List<String> roleList = new List<String>();
            List<String> appIdList = new List<String>();
            List<String> contactList = new List<String>();

            if(envelopeId == null || role == null || appId == null || contactId == null) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            envelopeIdList.add(envelopeId);
            roleList.add(role);
            appIdList.add(appId);
            contactList.add(contactId);
            queryIdMap.put(ENVELOPE_LIST,envelopeIdList);
            queryIdMap.put(ROLE_LIST,roleList);
            queryIdMap.put(APP_ID_LIST, appIdList);
            queryIdMap.put(CONTACT_ID_LIST,contactList);
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
            responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(INTEGRATION_FAMILY,
                                                                                                                            INTEGRATION_API_TYPE ,
                                                                                                                                queryIdMap, requestParamMap);
            
        } catch(Exception objException) {
            PortalHelper.saveExceptionLog(objException, IN_PERSON_DOCUSIGN);
        }   
    }   
}