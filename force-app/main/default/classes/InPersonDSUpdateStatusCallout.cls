/**
 * @description       : 
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 06-28-2024
 * @last modified by  : Krishanu Chinya
**/
public with sharing class InPersonDSUpdateStatusCallout implements Queueable, Database.AllowsCallouts{
    private Id envelopeId;
    private String applicationId;
    private static final String IN_PERSON_DOCUSIGN = 'InPersonDSUpdateStatusCallout';
    private static final String ENVELOPE_LIST = 'docuSignList';
    private static final String INTEGRATION_FAMILY = 'DocuSign Integration';
    private static final String INTEGRATION_API_TYPE = 'DocuSign Set Status Integration API Type';
    private static final String NULL_ENVELOPE = 'Envelope Id not Found';
    private static final String NULL_RECORD_ERROR = 'Unable to fetch records ';
    private static final String FIRST_SIGNER = 'Signer 1';
    private static final String ENVELOPE_ID = 'envelopeId';
    private static final String ROLE = 'role';
    private static final String APP_ID = 'appId';
    private static final String CONTACT_ID = 'contactId';

    /**
     * @description Construtor gets call to change docusign status of recipient
     * @param envId 
     * @param appId 
     */
    public InPersonDSUpdateStatusCallout(Id envId,String appId) {
        this.envelopeId = envId;
        this.applicationId = appId;
    }
    /**
     * @description Call the integration framework to change the status 
     * @param context 
     * @exception 
     */
    public void execute(QueueableContext context){
        try{
            Map<String, Object> requestParamMap = new Map<String, Object>();
            Map<String, Object> queryIdMap = new Map<String, Object>();
            List<Id> envelopeIdList = new List<Id>();
            if(envelopeId == null) {
                throw new CustomException(NULL_ENVELOPE);
            }
            envelopeIdList.add(envelopeId);
            queryIdMap.put(ENVELOPE_LIST,envelopeIdList);
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
            responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(INTEGRATION_FAMILY,
                                                                                                                            INTEGRATION_API_TYPE,
                                                                                                                                queryIdMap, requestParamMap);
                                                                                                                                                                                                                                              
            if(responseObject.getStatusCode() == 200){                                                        
                getUrlForFirstSigner(envelopeId,applicationId);
            }
                                                                    
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, IN_PERSON_DOCUSIGN);
        }
        
        
    }
    /**
     * @description call the next callout to get url for signer 1
     * @param envelopeId 
     * @param applicationId 
     * @exception 
     */
    private static void getUrlForFirstSigner(String envelopeId,String applicationId){     
        List<dfsle__Recipient__c> recipientList = [SELECT 
                                                        id,
                                                        dfsle__SourceId__c,
                                                        dfsle__Email__c,
                                                        dfsle__Role__c 
                                                    FROM dfsle__Recipient__c 
                                                    WHERE dfsle__Envelope__c =:envelopeId and dfsle__Role__c = : FIRST_SIGNER];
        if(recipientList.isEmpty()) {
            throw new CustomException(NULL_RECORD_ERROR);
        }
        List<genesis__Applications__c> applicationList = [SELECT Agreement_Sign__c,Signing_Method__c,
                                                                    Stage__c,genesis__Status__c
                                                                FROM genesis__Applications__c 
                                                                WHERE Id =: applicationId];
        if(applicationList.isEmpty()) {
            throw new CustomException(NULL_RECORD_ERROR);
        }

        if(applicationList[0].Agreement_Sign__c != true && (applicationList[0].Signing_Method__c == PortalConstants.IN_PERSON_DOCUSIGN || applicationList[0].Signing_Method__c == ConstantValues.IN_PERSON_HYBRID)){
            Map<String,String> paramMap = new Map<String,String>{
                ENVELOPE_ID => envelopeId,
                APP_ID => applicationId,
                CONTACT_ID =>recipientList[0].dfsle__SourceId__c
            };
            System.enqueueJob(new InPersonDSGetURLCallout(paramMap,recipientList[0].dfsle__Role__c));
        }
    } 
    
}