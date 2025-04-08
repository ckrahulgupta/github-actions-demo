/**
 * @description       : Docusign class to listen to platform event and make callout
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 05-10-2024
 * @last modified by  : Ayush Kumar Singh
**/
public with sharing class DocusignPlatformEventTriggerHandler {
    private static final String ENVELOPE_LIST = 'docuSignList';
    private static final String ROLE_LIST = 'roleList';
    private static final String APP_ID_LIST = 'appIdList';
    private static final String CONTACT_LIST = 'contactList';
    private static final String INTEGRATION_FAMILY = 'DocuSign Integration';
    private static final String INTEGRATION_API_TYPE = 'DocuSign Get URL Integration API Type';
    private static final String ENVELOPE_MAP = 'envelopeMap';
    private static final String RECIPIENT_STATUS_MAP = 'recipientStatusMap';
    private static final String RECIPIENT_MAP = 'recipientMap';
    

    /**
    * @description : Constructor to listen published event
    * @author  Pritam Roy | 03-12-2024 
    * @param newEvent 
    **/
    public DocusignPlatformEventTriggerHandler(List<DocuSignPlatformEvent__e> newEvent) {
        if(!newEvent.isEmpty()){
            publishDSEvent(newEvent);
        }
    }
    
    /**
    * @description : Check published event
    * @author  Pritam Roy | 03-12-2024 
    * @param eventList 
    **/
    public static void publishDSEvent(List<DocuSignPlatformEvent__e> eventList){
         try{
            List<String> applicationIdList = new List<String>();
            for(DocuSignPlatformEvent__e event : eventList){
                if(event.Application_Id__c	 != null){
                    applicationIdList.add(event.Application_Id__c);
                } 
            }

            getDocusignURL(applicationIdList);

        }
        catch(Exception ex) {
            PortalHelper.saveExceptionLog(ex, DocusignPlatformEventTriggerHandler.class.getName()); 
        }
    }
   
    /**
     * @description Getting the docusign URL for esign
     * @param applicationIdList 
     */
    @future(callout = true)
    public static void getDocusignURL(List<String> applicationIdList){
        try{
                Map<String,Object> dsParamMap  =  getEnvelopeDetails(applicationIdList);
                Map<String,Object> envelopeMap = (Map<String,Object>)dsParamMap.get(ENVELOPE_MAP);
                Map<String,Object> recipientStatusMap = (Map<String,Object>) dsParamMap.get(RECIPIENT_STATUS_MAP);
                Map<String,Object> recipientMap = (Map<String,Object>) dsParamMap.get(RECIPIENT_MAP);
                

                for(String app : applicationIdList){
                    dfsle__Envelope__c envelope = (dfsle__Envelope__c) envelopeMap.get(app);
                    dfsle__RecipientStatus__c recipStatus = (dfsle__RecipientStatus__c)recipientStatusMap.get(app);
                    dfsle__Recipient__c recipient = (dfsle__Recipient__c)recipientMap.get(recipStatus.dfsle__SourceId__c);

                    Map<String, Object> requestParamMap = new Map<String, Object>();
                    Map<String, Object> queryIdMap = new Map<String, Object>();
                    List<Id> envelopeIdList = new List<Id>();
                    envelopeIdList.add(envelope.id);
                    List<String> roleList = new List<String>();
                    roleList.add(recipient.dfsle__Role__c);
                    List<String> appIdList = new List<String>();
                    appIdList.add(app);
                    
                    List<String> contactList = new List<String>();
                    contactList.add(recipient.dfsle__SourceId__c);
                    queryIdMap.put(ENVELOPE_LIST,envelopeIdList);
                    queryIdMap.put(ROLE_LIST,roleList);
                    queryIdMap.put(APP_ID_LIST, appIdList);
                    queryIdMap.put(CONTACT_LIST,contactList);
                    intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
                    intframework.BaseIntegrationResponse responseObject;
                    responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(INTEGRATION_FAMILY,
                                                                                                                                INTEGRATION_API_TYPE ,
                                                                                                                                queryIdMap, requestParamMap);
                }
             
        } catch(Exception ex) {
            PortalHelper.saveExceptionLog(ex, DocusignPlatformEventTriggerHandler.class.getName()); 
        }

       
    }

    /**
     * @description Getting the docusign Envelope details
     * @param applicationIdList 
     * @return  `Map<String,Object>`
     */
    private static  Map<String,Object> getEnvelopeDetails(List<String> applicationIdList){
        List<dfsle__Envelope__c> envelopeList;
        if(Schema.sObjectType.dfsle__Envelope__c.isAccessible()){
        envelopeList = [SELECT 
                            id,dfsle__SourceId__c,
                            dfsle__DocuSignId__c 
                        FROM dfsle__Envelope__c 
                        WHERE dfsle__SourceId__c IN: applicationIdList ORDER BY createddate desc];
        }

        List<String> dsEnvelopeIdList = new List<String>();
        List<String> envelopeIdList = new List<String>();
        Map<String,dfsle__Envelope__c> envelopeMap = new Map<String,dfsle__Envelope__c>();
        for(dfsle__Envelope__c envelope : envelopeList){
            if(!envelopeMap.containsKey(envelope.dfsle__SourceId__c)){
                envelopeMap.put(envelope.dfsle__SourceId__c,envelope);
                dsEnvelopeIdList.add(envelope.dfsle__DocuSignId__c);
                envelopeIdList.add(envelope.id);
            }
        }
        Map<String,Object> recipeintDetailMap =  getRecipientStatus(applicationIdList,dsEnvelopeIdList,envelopeIdList);
        recipeintDetailMap.put(ENVELOPE_MAP,envelopeMap);
        return recipeintDetailMap;
    }

    /**
     * @description Getting the Recipient Status
     * @param applicationIdList 
     * @param dsEnvelopeIdList 
     * @param envelopeIdList 
     * @return  `Map<String,Object>`
     */
    private static Map<String,Object> getRecipientStatus(List<String> applicationIdList, List<String> dsEnvelopeIdList,List<String> envelopeIdList){
        List<dfsle__RecipientStatus__c> recipientStatusList;
        if(Schema.sObjectType.dfsle__RecipientStatus__c.isAccessible()){
            recipientStatusList = [SELECT 
                                        id,dfsle__SourceId__c,
                                        dfsle__EnvelopeStatus__r.dfsle__DocuSignId__c,
                                        dfsle__EnvelopeStatus__r.dfsle__SourceId__c,
                                        dfsle__Status__c 
                                    FROM dfsle__RecipientStatus__c 
                                    WHERE dfsle__EnvelopeStatus__r.dfsle__SourceId__c IN: applicationIdList
                                    AND dfsle__EnvelopeStatus__r.dfsle__DocuSignId__c IN: dsEnvelopeIdList 
                                    AND dfsle__Status__c =: PortalConstants.ENVELOPE_STATUS 
                                    ];
        }
        List<String> contactIdList = new List<String>();
        Map<String,dfsle__RecipientStatus__c> recipientStatusMap = new Map<String,dfsle__RecipientStatus__c>();
        for(dfsle__RecipientStatus__c recipientStatus : recipientStatusList){
            if(!recipientStatusMap.containsKey(recipientStatus.dfsle__EnvelopeStatus__r.dfsle__DocuSignId__c)){
                recipientStatusMap.put(recipientStatus.dfsle__EnvelopeStatus__r.dfsle__SourceId__c,recipientStatus);
                contactIdList.add(recipientStatus.dfsle__SourceId__c);
            }
        }
        Map<String,dfsle__Recipient__c> recipientMap = getEnvelopeRecipient(envelopeIdList,contactIdList);
        Map<String,Object> recipientDetailMap = new Map<String,Object>{
            RECIPIENT_STATUS_MAP => recipientStatusMap,
            RECIPIENT_MAP => recipientMap
        };

        return recipientDetailMap;
    }
    /**
     * @description Getting Envelope recipient 
     * @param envelopeIdList 
     * @param contactIdList 
     * @return  `Map<String,dfsle__Recipient__c>`
     */
    private static Map<String,dfsle__Recipient__c> getEnvelopeRecipient(List<String> envelopeIdList,List<String> contactIdList){
        List<dfsle__Recipient__c> recipientList;
        if(Schema.sObjectType.dfsle__Recipient__c.isAccessible()){
            recipientList = [SELECT 
                                id,
                                dfsle__Email__c,
                                dfsle__SourceId__c,
                                dfsle__Role__c 
                            FROM dfsle__Recipient__c 
                            WHERE dfsle__Envelope__c =: envelopeIdList and dfsle__SourceId__c =: contactIdList];
        }
        Map<String,dfsle__Recipient__c> recipientMap = new Map<String,dfsle__Recipient__c>();
        for(dfsle__Recipient__c recipient : recipientList){
            if(!recipientMap.containsKey(recipient.dfsle__SourceId__c)){
                recipientMap.put(recipient.dfsle__SourceId__c, recipient);
            }
        }
        return recipientMap;

    }
}