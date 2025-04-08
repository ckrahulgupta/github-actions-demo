/**
 * @description       : 
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 06-24-2024
 * @last modified by  : Krishanu Chinya
**/
public with sharing class InPersonDSUpdateRecipientCalloutAPI implements Queueable, Database.AllowsCallouts{
    private Id envelopeId;
    private String applicationId;
    private String signingMethod;
    private static final String IN_PERSON_DOCUSIGN = 'InPersonDocuSign';
    private static final String INTEGRATION_NAME = 'DocuSign Integration';
    private static final String INTEGRATION_API_TYPE = 'DocuSign Update Recipient Integration API Type';
    private static final String ENVELOPE_LIST = 'docuSignList';
    private static final String SIGNING_TYPE = 'signingMethod';
    
    /**
    * @description : Construtor gets call to update Recipient contact in envelope
    * @author Krishanu Chinya | 06-24-2024 
    * @param envId 
    * @param appId 
    * @param signingMethod 
    **/
    public InPersonDSUpdateRecipientCalloutAPI(Id envId,String appId, String signingMethod) {
        this.envelopeId = envId;
        this.applicationId = appId;
        this.signingMethod = signingMethod;
    }
    /**
     * @description Call the integration framework to update the recipient and also call the next callout
     * @param context 
     * @exception 
     */
    public  void execute(QueueableContext context){
        try{
            if(envelopeId == null){
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            List<Id> envelopeIdList = new List<Id>();
            envelopeIdList.add(envelopeId);         
            Map<String, Object> requestParamMap = new Map<String, Object>();
            requestParamMap.put(SIGNING_TYPE, signingMethod);
            Map<String, Object> queryIdMap = new Map<String, Object>();
            queryIdMap.put(ENVELOPE_LIST,envelopeIdList);
            intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            intframework.BaseIntegrationResponse responseObject;
            responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(INTEGRATION_NAME,
                                                                                                                            INTEGRATION_API_TYPE ,
                                                                                                                            queryIdMap, requestParamMap); 
            System.enqueueJob(new InPersonDSUpdateStatusCallout(envelopeId,applicationId));
      } catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, IN_PERSON_DOCUSIGN);
        } 
    }
}