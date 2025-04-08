/**
 * @description       : 
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 06-28-2024
 * @last modified by  : Krishanu Chinya
**/
public inherited sharing class DocuSignRecipientStatusTriggerHandler {
    private static final String FIRST_SIGNER = 'Signer 1';
    private static final String ENVELOPE_ID = 'envelopeId';
    private static final String ROLE = 'role';
    private static final String APP_ID = 'appId';
    private static final String CONTACT_ID = 'contactId';

    private static Map<String,List<dfsle__RecipientStatus__c>> recipientStatusMap = new Map<String,List<dfsle__RecipientStatus__c>>();
    private static Map<String,Map<String,clcommon__Party__c>> partyMap = new Map<String,Map<String,clcommon__Party__c>>();
    private static Map<String,genesis__Applications__c> applicationMap = new Map<String,genesis__Applications__c>();


    private static List<String> envelopeDocusignIdList = new List<String>();
    private static Map<String,String> appIdMap = new Map<String,String>();
    private static Map<String,dfsle__EnvelopeStatus__c> envelopeStatusMap = new Map<String,dfsle__EnvelopeStatus__c>();

    /**
    * @description : checks access permissions
    * @author Krishanu Chinya | 06-28-2024 
    **/
    public static void checkAccessOnObjects(){
        if((!Schema.sObjectType.clcommon__Party__c.isAccessible())
                | (!Schema.sObjectType.clcommon__party__c.isUpdateable())
                | (!Schema.sObjectType.dfsle__RecipientStatus__c.isAccessible())
                | (!Schema.sObjectType.dfsle__EnvelopeStatus__c.isAccessible())
                | (!Schema.sObjectType.dfsle__Envelope__c.isAccessible())
                | (!Schema.sObjectType.dfsle__Recipient__c.isAccessible())
                | (!Schema.sObjectType.genesis__Applications__c.isUpdateable())
                | (!Schema.sObjectType.genesis__Applications__c.isAccessible())
                ){
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
        }
    }

    /**
    * @description : Update the Docusign Recipient Status
    * @author Krishanu Chinya | 06-27-2024 
    * @param recipientStatusList 
    **/
    public static void updateDocusignRecipientStatus(List<dfsle__RecipientStatus__c> recipientStatusList){
        try{
            checkAccessOnObjects();
            List<String> envelopeStatusList = DocuSignHelper.getEnvelopeStatusIdList(recipientStatusList);

            List<dfsle__EnvelopeStatus__c> envelopeStatusObjList = [SELECT Id, 
                                                                    dfsle__SourceId__c,
                                                                    dfsle__DocuSignId__c
                                                                    FROM dfsle__EnvelopeStatus__c
                                                                    WHERE  id IN :envelopeStatusList];

            List<String> applicationIdList = new List<String>();

            for(dfsle__EnvelopeStatus__c envelopeStatus : envelopeStatusObjList){
                envelopeDocusignIdList.add(envelopeStatus.dfsle__DocuSignId__c);
                applicationIdList.add(envelopeStatus.dfsle__SourceId__c);
                appIdMap.put(envelopeStatus.id,envelopeStatus.dfsle__SourceId__c);
                envelopeStatusMap.put(envelopeStatus.id,envelopeStatus);
            }

            applicationMap = DocuSignHelper.getApplicationMap(applicationIdList);
            recipientStatusMap = DocuSignHelper.getRecipientStatusMap(envelopeStatusList);
            partyMap = DocuSignHelper.getPartyMap(applicationIdList);

            if(applicationMap.get(applicationIdList[0]).Signing_Method__c == PortalConstants.EMAIL_DOCUSIGN){
                updateDocusignRecipientStatusForEmailDS(recipientStatusList);
            }else if(applicationMap.get(applicationIdList[0]).Signing_Method__c == PortalConstants.IN_PERSON_DOCUSIGN 
                        || applicationMap.get(applicationIdList[0]).Signing_Method__c == ConstantValues.IN_PERSON_HYBRID){
                updateDocusignRecipientStatusForInPersonDS(recipientStatusList);
            }
        }catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, PortalConstants.SOMETHING_WENT_WRONG);
        }
    }

    
    /**
     * @description : updates the recipient status for in person docusign and in person hybrid 
     * @param recipientStatusList 
     */
    public static void updateDocusignRecipientStatusForEmailDS(List<dfsle__RecipientStatus__c> recipientStatusList){
            Set<genesis__Applications__c> applicationIdSet = new Set<genesis__Applications__c>();
            List<clcommon__party__c> updatePartyList = new List<clcommon__party__c>();
            for(dfsle__RecipientStatus__c status : recipientStatusList){
                clcommon__party__c party;
                String envelopeStatusId = status.dfsle__EnvelopeStatus__c;
                String applicationId = appIdMap.get(envelopeStatusId);
                genesis__Applications__c applicationObj = applicationMap.get(applicationId);
                List<dfsle__RecipientStatus__c> recipientObjList = new  List<dfsle__RecipientStatus__c>();
                if(recipientStatusMap.get(envelopeStatusId) != null){
                    recipientObjList = recipientStatusMap.get(envelopeStatusId);
                }
                if(applicationObj != null && applicationObj.Signing_Method__c == PortalConstants.EMAIL_DOCUSIGN){
                    DocuSignHelper.updateApplicationForEmailDS(recipientObjList,applicationObj);
                    applicationIdSet.add(applicationObj);
                }
                if(partyMap.containsKey(applicationId) && applicationObj.Signing_Method__c == PortalConstants.EMAIL_DOCUSIGN){
                    Map<String,clcommon__Party__c> partyObjMap = partyMap.get(applicationId);
                    party = DocuSignHelper.updateApplicationPartyForEmailDS(partyObjMap,status);
                    updatePartyList.add(party);
                }
            }
            DocuSignHelper.updateApplicationAndPartyList(applicationIdSet,updatePartyList);
    }

    /**
    * @description : updates the recipient status for in person docusign and in person hybrid 
    * @author Krishanu Chinya | 06-27-2024 
    * @param recipientStatusList 
    **/
    public static void updateDocusignRecipientStatusForInPersonDS(List<dfsle__RecipientStatus__c> recipientStatusList){
            List<String> envelopeIdList = new List<String>();
            Map<String,String> envelopeIdMap = new Map<String,String>();

            List<dfsle__Envelope__c> envelopeList = [SELECT id,
                                                            dfsle__DocuSignId__c
                                                        FROM dfsle__Envelope__c 
                                                        WHERE dfsle__DocuSignId__c IN: envelopeDocusignIdList];

            for(dfsle__Envelope__c envelope : envelopeList){
                envelopeIdList.add(envelope.id);
                envelopeIdMap.put(envelope.dfsle__DocuSignId__c,envelope.id);
            }

            Map<String,Map<String,dfsle__Recipient__c>> recipientMap = getRecipientMap(envelopeIdList);

            Set<genesis__Applications__c> applicationIdSet = new Set<genesis__Applications__c>();
            List<clcommon__party__c> updatePartyList = new List<clcommon__party__c>();
            for(dfsle__RecipientStatus__c status : recipientStatusList){
                clcommon__party__c party;
                String envelopeStatusId = status.dfsle__EnvelopeStatus__c;
                String applicationId = appIdMap.get(envelopeStatusId);
                genesis__Applications__c applicationObj = applicationMap.get(applicationId);
                dfsle__EnvelopeStatus__c envelopeStatus = envelopeStatusMap.get(envelopeStatusId);
                String envelopeId = envelopeIdMap.get(envelopeStatus.dfsle__DocuSignId__c);
                Map<String,dfsle__Recipient__c> recipientObjMap = recipientMap.get(envelopeId);
                dfsle__Recipient__c recipient = recipientObjMap.get(status.dfsle__SourceId__c);
                List<dfsle__RecipientStatus__c> recipientObjList = new  List<dfsle__RecipientStatus__c>();
                if(recipientStatusMap.get(envelopeStatusId) != null){
                    recipientObjList = recipientStatusMap.get(envelopeStatusId);
                }
                if(applicationObj != null 
                    && (applicationObj.Signing_Method__c == PortalConstants.IN_PERSON_DOCUSIGN 
                        | applicationObj.Signing_Method__c == ConstantValues.IN_PERSON_HYBRID)){
                    
                            DocuSignHelper.updateApplicationForInPersonDS(recipientObjList,applicationObj);
                    applicationIdSet.add(applicationObj);
                }
                if(partyMap.containsKey(applicationId) 
                    && (applicationObj.Signing_Method__c == PortalConstants.IN_PERSON_DOCUSIGN 
                        | applicationObj.Signing_Method__c == ConstantValues.IN_PERSON_HYBRID)){
                    
                    Map<String,clcommon__Party__c> partyObjMap = partyMap.get(applicationId);
                    party = DocuSignHelper.updateApplicationPartyForInPersonDS(partyObjMap,status);
                    updatePartyList.add(party);
                }
                Map<String,String> docusignUrlParamMap = new Map<String,String>{
                    ROLE => recipient.dfsle__Role__c,
                    ENVELOPE_ID => envelopeId
                };
                if(applicationObj.Signing_Method__c != ConstantValues.IN_PERSON_HYBRID){
                    getDocusignUrl(status,applicationObj,docusignUrlParamMap);
                }
            }
            DocuSignHelper.updateApplicationAndPartyList(applicationIdSet,updatePartyList);
    }

    /**
    * @description : fetches the docusign url
    * @author Krishanu Chinya | 06-27-2024 
    * @param status 
    * @param applicationObj 
    * @param docusignUrlParamMap 
    **/
    private static void getDocusignUrl(dfsle__RecipientStatus__c status, genesis__Applications__c applicationObj, Map<String,String> docusignUrlParamMap){
        String role = docusignUrlParamMap.get(ROLE);
        String envelopeId = docusignUrlParamMap.get(ENVELOPE_ID);
        if(status.dfsle__Status__c == PortalConstants.ENVELOPE_STATUS & applicationObj.Agreement_Sign__c != true & applicationObj.Signing_Method__c == PortalConstants.IN_PERSON_DOCUSIGN & role != FIRST_SIGNER ){
            Map<String,String> paramMap = new Map<String,String>{
                ENVELOPE_ID => envelopeId,
                APP_ID => applicationObj.id,
                CONTACT_ID =>status.dfsle__SourceId__c
            };
            System.enqueueJob(new InPersonDSGetURLCallout(paramMap,role));
        }
    }

    /**
    * @description : fetches the recipent map
    * @author Krishanu Chinya | 06-27-2024 
    * @param envelopeIdList 
    * @return Map<String, Map<String, dfsle__Recipient__c>> 
    **/
    private static Map<String,Map<String,dfsle__Recipient__c>> getRecipientMap(List<String> envelopeIdList){
        List<dfsle__Recipient__c> recipientList = [SELECT id,
                                                            dfsle__Email__c,
                                                            dfsle__SourceId__c,
                                                            dfsle__Envelope__c,
                                                            dfsle__Role__c 
                                                        FROM dfsle__Recipient__c 
                                                        WHERE dfsle__Envelope__c IN: envelopeIdList];
        Map<String,Map<String,dfsle__Recipient__c>> recipientMap = new Map<String,Map<String,dfsle__Recipient__c>>();
        for(dfsle__Recipient__c recipient : recipientList){
            String envelopeId = recipient.dfsle__Envelope__c;
            if(!recipientMap.containsKey(envelopeId)){
                Map<String,dfsle__Recipient__c> recipientObjMap = new Map<String,dfsle__Recipient__c>{
                    recipient.dfsle__SourceId__c => recipient
                };
                recipientMap.put(envelopeId,recipientObjMap);
            }
            else{
                Map<String,dfsle__Recipient__c> recipientObjMap = recipientMap.get(envelopeId);
                recipientObjMap.put(recipient.dfsle__SourceId__c,recipient);
                recipientMap.put(envelopeId,recipientObjMap);
            }
        }
        return recipientMap;
    }
}