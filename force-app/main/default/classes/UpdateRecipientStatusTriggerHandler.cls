/**
 * @description This trigger get fired when a docusign changes the status
 * @author Ayush Kumar Singh 
 * @since 
 */
public inherited sharing class UpdateRecipientStatusTriggerHandler {
    private static final String FIRST_SIGNER = 'Signer 1';
    private static final String ENVELOPE_ID = 'envelopeId';
    private static final String ROLE = 'role';
    private static final String APP_ID = 'appId';
    private static final String CONTACT_ID = 'contactId';
    

    private static List<String> applicationIdList = new List<String>();
    private static List<String> envelopeDocusignIdList = new List<String>();
    private static Map<String,String> appIdMap = new Map<String,String>();
    private static Map<String,dfsle__EnvelopeStatus__c> envelopeStatusMap = new Map<String,dfsle__EnvelopeStatus__c>();
    private static List<String> envelopeIdList = new List<String>();
    private static Map<String,String> envelopeIdMap = new Map<String,String>();
    /**
     * @description Check the accessesibility of an object
     * @exception 
     */
    private static void checkAccessOnObjects(){
        if((!Schema.sObjectType.clcommon__Party__c.isAccessible())
                || (!Schema.sObjectType.dfsle__RecipientStatus__c.isAccessible())
                || (!Schema.sObjectType.dfsle__EnvelopeStatus__c.isAccessible())
                || (!Schema.sObjectType.dfsle__Envelope__c.isAccessible())
                || (!Schema.sObjectType.dfsle__Recipient__c.isAccessible())
                || (!Schema.sObjectType.genesis__Applications__c.isUpdateable())
                || (!Schema.sObjectType.clcommon__party__c.isUpdateable())
                ){
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
        }
    }
    /**
     * @description Update the Docusign Recipient Status
     * @param recipientStatusList 
     */
    public static void updateDocusignRecipientStatus(List<dfsle__RecipientStatus__c> recipientStatusList){
        try{
            checkAccessOnObjects();
            List<String> envelopeStatusList = getEnvelopeStatusIdList(recipientStatusList);
            getEnvelopeDetails(envelopeStatusList);
            getEnvelopeId();

            Map<String,Map<String,dfsle__Recipient__c>> recipientMap = getRecipientMap(envelopeIdList);
            
            Map<String,genesis__Applications__c> applicationMap = getApplicationMap(applicationIdList);
            Map<String,List<dfsle__RecipientStatus__c>> recipientStatusMap = getRecipientStatusMap(envelopeStatusList);
            Map<String,Map<String,clcommon__Party__c>> partyMap = getPartyMap(applicationIdList);
            

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
                if(applicationObj != null && applicationObj.Signing_Method__c == PortalConstants.IN_PERSON_DOCUSIGN){
                    updateApplication(recipientObjList,applicationObj);
                    applicationIdSet.add(applicationObj);
                }
                if(partyMap.containsKey(applicationId) && applicationObj.Signing_Method__c == PortalConstants.IN_PERSON_DOCUSIGN){
                    Map<String,clcommon__Party__c> partyObjMap = partyMap.get(applicationId);
                    party = updateApplicationParty(partyObjMap,status);
                    updatePartyList.add(party);
                }
                Map<String,String> docusignUrlParamMap = new Map<String,String>{
                    ROLE => recipient.dfsle__Role__c,
                    ENVELOPE_ID => envelopeId
                };
                getDocusignUrl(status,applicationObj,docusignUrlParamMap);
        
            }
            updateApplicationAndPartyList(applicationIdSet,updatePartyList);
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, PortalConstants.SOMETHING_WENT_WRONG);
        }
    }
    /**
     * @description Get all docusign recipient status in Map 
     * @param envelopeStatusList 
     * @return  `Map<String,List<dfsle__RecipientStatus__c>>`
     */
    private static Map<String,List<dfsle__RecipientStatus__c>> getRecipientStatusMap(List<String> envelopeStatusList){

        List<dfsle__RecipientStatus__c> recipientList = [SELECT Id, 
                                                                dfsle__EnvelopeStatus__c,
                                                                dfsle__Email__c, 
                                                                Recipient_Signed__c,
                                                                dfsle__Status__c 
                                                            FROM dfsle__RecipientStatus__c
                                                            WHERE dfsle__EnvelopeStatus__c IN: envelopeStatusList
                                                            AND Recipient_Signed__c != true];

        Map<String,List<dfsle__RecipientStatus__c>> recipientStatusMap = new Map<String,List<dfsle__RecipientStatus__c>>();
        for(dfsle__RecipientStatus__c recipientStatus : recipientList){
            String envelopeStatusId = recipientStatus.dfsle__EnvelopeStatus__c;
            if(!recipientStatusMap.containsKey(envelopeStatusId)){
                List<dfsle__RecipientStatus__c> recipientObjList = new List<dfsle__RecipientStatus__c>();
                recipientObjList.add(recipientStatus);
                recipientStatusMap.put(envelopeStatusId,recipientObjList);
            }
            else{
                List<dfsle__RecipientStatus__c> recipientObjList = recipientStatusMap.get(envelopeStatusId);
                recipientObjList.add(recipientStatus);
                recipientStatusMap.put(envelopeStatusId,recipientObjList);
            }
        }
        return recipientStatusMap;
    }

    /**
     * @description get all party of the signer
     * @param applicationIdList 
     * @return  `Map<String,Map<String,clcommon__Party__c>>`
     */
    private static Map<String,Map<String,clcommon__Party__c>> getPartyMap( List<String> applicationIdList){
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    clcommon__Contact__c,
                                                    DocuSign_Signing_Status__c,
                                                    genesis__Application__r.Signing_Method__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c IN: applicationIdList
                                                AND (clcommon__Type__r.Name = :PortalConstants.BORROWER_PARTY_NAME
                                                OR clcommon__Type__r.Name = :PortalConstants.PRINCIPAL_PARTY_NAME)];
        

        Map<String,Map<String,clcommon__Party__c>> partyMap = new Map<String,Map<String,clcommon__Party__c>>();
        for(clcommon__Party__c party : partyList){
            String appId = party.genesis__Application__c;
            if(!partyMap.containsKey(appId)){
                Map<String,clcommon__Party__c> partyObjMap = new Map<String,clcommon__Party__c>{
                    party.clcommon__Contact__c => party
                };
                partyMap.put(appId,partyObjMap);
            }
            else{
                Map<String,clcommon__Party__c> partyObjMap = partyMap.get(appId);
                partyObjMap.put(party.clcommon__Contact__c,party);
                partyMap.put(appId,partyObjMap);
            }
        }
        return partyMap;
    }

    /**
     * @description : get the application
     * @param applicationIdList 
     * @return  `Map<String,genesis__Applications__c>`
     */
    private static Map<String,genesis__Applications__c> getApplicationMap( List<String> applicationIdList){
        List<genesis__Applications__c> applicationList;
        if(Schema.sObjectType.genesis__Applications__c.isAccessible()){
                applicationList = [SELECT Agreement_Sign__c,Signing_Method__c,
                                                Stage__c,genesis__Status__c
                                            FROM genesis__Applications__c 
                                            WHERE Id IN: applicationIdList];
        }
        
        Map<String,genesis__Applications__c> applicationMap = new Map<String,genesis__Applications__c>();

        for(genesis__Applications__c app : applicationList){
            applicationMap.put(app.id,app);
        }
        return applicationMap;
    }
    /**
     * @description : update application status and stage
     * @param recipientList 
     * @param objApplication 
     */
    private static void updateApplication(List<dfsle__RecipientStatus__c> recipientList,genesis__Applications__c objApplication){
        if(recipientList.size() == 0){
            if(objApplication.Agreement_Sign__c == false && objApplication.Signing_Method__c == PortalConstants.IN_PERSON_DOCUSIGN){
                objApplication.Agreement_Sign__c = true;
                objApplication.genesis__Status__c = PortalConstants.E_SIGN_COMPLETED_APPLICATION_STATUS;
            }
            //Change the stage of Application
            if(objApplication.Stage__c == PortalConstants.APPLICANT_SIGNATURE){
                objApplication.Stage__c = PortalConstants.SCORE_CREDIT_REFERENCE;
            }
        }
    
    }
    /**
     * @description Update application party
     * @param partyObjMap 
     * @param status 
     * @return  `clcommon__party__c`
     */
    private static clcommon__party__c updateApplicationParty(Map<String,clcommon__Party__c> partyObjMap,dfsle__RecipientStatus__c status){
            clcommon__party__c party = partyObjMap.get(status.dfsle__SourceId__c);
            if(partyObjMap.containsKey(status.dfsle__SourceId__c) && party.genesis__Application__r.Signing_Method__c ==  PortalConstants.IN_PERSON_DOCUSIGN && party.clcommon__Contact__c == status.dfsle__SourceId__c) {
                if(status.dfsle__Status__c == PortalConstants.ENVELOPE_STATUS_DELIVERED || status.dfsle__Status__c == PortalConstants.ENVELOPE_STATUS || status.dfsle__Status__c == PortalConstants.ENVELOPE_STATUS_CREATED) {
                    party.DocuSign_Signing_Status__c =  PortalConstants.PARTY_STATUS_PENDING;
                } else if(status.dfsle__Status__c == PortalConstants.ENVELOPE_STATUS_COMPLETED) {
                    party.DocuSign_Signing_Status__c = PortalConstants.PARTY_STATUS_COMPLETED;
                } else {
                    party.DocuSign_Signing_Status__c = status.dfsle__Status__c;
                } 
                return party;
            }
        return null;
    }
    /**
     * @description Get all recipient in a map
     * @param envelopeIdList 
     * @return  `Map<String,Map<String,dfsle__Recipient__c>>`
     */
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
    /**
     * @description Get Envelope Status in List
     * @param recipientStatusList 
     * @return  `List<String>`
     */
    private static List<String> getEnvelopeStatusIdList(List<dfsle__RecipientStatus__c> recipientStatusList){
        List<String> envelopeStatusList = new List<String>();
        for(dfsle__RecipientStatus__c status : recipientStatusList){
            String envelopeStatusId = status.dfsle__EnvelopeStatus__c;
            envelopeStatusList.add(envelopeStatusId);  
        }
        return envelopeStatusList;
    }
    /**
     * @description Get Envelope Details
     * @param envelopeStatusList 
     */
    private static void getEnvelopeDetails(List<String> envelopeStatusList){
        List<dfsle__EnvelopeStatus__c> envelopeStatusObjList = [SELECT Id, 
                                                                    dfsle__SourceId__c,
                                                                    dfsle__DocuSignId__c
                                                                    FROM dfsle__EnvelopeStatus__c
                                                                    WHERE  id IN :envelopeStatusList];

        for(dfsle__EnvelopeStatus__c envelopeStatus : envelopeStatusObjList){
            envelopeDocusignIdList.add(envelopeStatus.dfsle__DocuSignId__c);
            applicationIdList.add(envelopeStatus.dfsle__SourceId__c);
            appIdMap.put(envelopeStatus.id,envelopeStatus.dfsle__SourceId__c);
            envelopeStatusMap.put(envelopeStatus.id,envelopeStatus);
        }
    }
    
    /**
     * @description Get Envelope Id
     */
    private static void getEnvelopeId(){
        List<dfsle__Envelope__c> envelopeList = [SELECT id,dfsle__DocuSignId__c
                                    FROM dfsle__Envelope__c 
                                    WHERE dfsle__DocuSignId__c IN: envelopeDocusignIdList];

        for(dfsle__Envelope__c envelope : envelopeList){
            envelopeIdList.add(envelope.id);
            envelopeIdMap.put(envelope.dfsle__DocuSignId__c,envelope.id);
        }
    }
    /**
     * @description Update application and party in database
     * @param applicationIdSet 
     * @param updatePartyList 
     */
    private static void updateApplicationAndPartyList(Set<genesis__Applications__c> applicationIdSet,List<clcommon__party__c> updatePartyList){
        List<genesis__Applications__c> updateAppList = new List<genesis__Applications__c>(applicationIdSet);
        if(!updateAppList.isEmpty()){
            Database.update(updateAppList);
        }
        if(updatePartyList != null && !updatePartyList.isEmpty()) {
            Database.update(updatePartyList,true);
        }
    }
    /**
     * @description Call the callout for in person docusign to generate the url
     * @param status 
     * @param applicationObj 
     * @param docusignUrlParamMap 
     */
    private static void getDocusignUrl(dfsle__RecipientStatus__c status, genesis__Applications__c applicationObj, Map<String,String> docusignUrlParamMap){
        String role = docusignUrlParamMap.get(ROLE);
        String envelopeId = docusignUrlParamMap.get(ENVELOPE_ID);
        if(status.dfsle__Status__c == PortalConstants.ENVELOPE_STATUS && applicationObj.Agreement_Sign__c != true && applicationObj.Signing_Method__c == PortalConstants.IN_PERSON_DOCUSIGN && role != FIRST_SIGNER ){
            Map<String,String> paramMap = new Map<String,String>{
                ENVELOPE_ID => envelopeId,
                APP_ID => applicationObj.id,
                CONTACT_ID =>status.dfsle__SourceId__c
            };
            System.enqueueJob(new InPersonDSGetURLCallout(paramMap,role));
        }
    }
}