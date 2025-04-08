/**
 * @description       : 
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 08-10-2024
 * @last modified by  : Soumik Pattanayak
**/
public inherited sharing class DocuSignHelper {
    /**
    * @description This method checks if the Objects are accessible or not
    * @author Soumik Pattanayak | 08-10-2024 
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
    * @description 
    * @author Krishanu Chinya | 06-27-2024 
    * @param recipientStatusList 
    * @return List<String> 
    **/
    public static List<String> getEnvelopeStatusIdList(List<dfsle__RecipientStatus__c> recipientStatusList){
        List<String> envelopeStatusList = new List<String>();
        for(dfsle__RecipientStatus__c status : recipientStatusList){
            String envelopeStatusId = status.dfsle__EnvelopeStatus__c;
            envelopeStatusList.add(envelopeStatusId);  
        }
        return envelopeStatusList;
    }

    /**
    * @description 
    * @author Krishanu Chinya | 06-27-2024 
    * @param applicationIdList 
    * @return Map<String, genesis__Applications__c> 
    **/
    public static Map<String,genesis__Applications__c> getApplicationMap( List<String> applicationIdList){
        Map<String,genesis__Applications__c> applicationMap = new Map<String,genesis__Applications__c>();

        List<genesis__Applications__c> applicationList = [SELECT Agreement_Sign__c,
                                                                    Signing_Method__c,
                                                                    Stage__c,
                                                                    genesis__Status__c
                                                            FROM genesis__Applications__c 
                                                            WHERE Id IN: applicationIdList];
        
        for(genesis__Applications__c app : applicationList){
            applicationMap.put(app.id,app);
        }
        return applicationMap;
    }

    /**
    * @description 
    * @author Krishanu Chinya | 06-27-2024 
    * @param envelopeStatusList 
    * @return Map<String, List<dfsle__RecipientStatus__c>> 
    **/
    public static Map<String,List<dfsle__RecipientStatus__c>> getRecipientStatusMap(List<String> envelopeStatusList){
        Map<String,List<dfsle__RecipientStatus__c>> recipientStatusMap = new Map<String,List<dfsle__RecipientStatus__c>>();

        List<dfsle__RecipientStatus__c> recipientStatusList = [SELECT Id, 
                                                                dfsle__EnvelopeStatus__c,
                                                                dfsle__Email__c, 
                                                                Recipient_Signed__c,
                                                                dfsle__Status__c 
                                                            FROM dfsle__RecipientStatus__c
                                                            WHERE dfsle__EnvelopeStatus__c IN: envelopeStatusList
                                                            AND Recipient_Signed__c != true];

        for(dfsle__RecipientStatus__c recipientStatus : recipientStatusList){
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
    * @description 
    * @author Krishanu Chinya | 06-27-2024 
    * @param applicationIdList 
    * @return Map<String, Map<String, clcommon__Party__c>> 
    **/
    public static Map<String,Map<String,clcommon__Party__c>> getPartyMap( List<String> applicationIdList){
        Map<String,Map<String,clcommon__Party__c>> partyMap = new Map<String,Map<String,clcommon__Party__c>>();

        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    clcommon__Contact__c,
                                                    DocuSign_Signing_Status__c,
                                                    genesis__Application__r.Signing_Method__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c IN: applicationIdList
                                                AND (clcommon__Type__r.Name = :PortalConstants.BORROWER_PARTY_NAME
                                                        OR clcommon__Type__r.Name = :PortalConstants.PRINCIPAL_PARTY_NAME)];

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
    * @description 
    * @author Krishanu Chinya | 06-27-2024 
    * @param applicationIdSet 
    * @param updatePartyList 
    **/
    public static void updateApplicationAndPartyList(Set<genesis__Applications__c> applicationIdSet,List<clcommon__party__c> updatePartyList){
        List<genesis__Applications__c> updateAppList = new List<genesis__Applications__c>(applicationIdSet);
        if(!updateAppList.isEmpty()){
            Database.update(updateAppList);
        }
        if(!updatePartyList.isEmpty()) {
            Database.update(updatePartyList,true);
        }
    }

    /**
    * @description 
    * @author Krishanu Chinya | 06-27-2024 
    * @param recipientList 
    * @param objApplication 
    **/
    public static void updateApplicationForEmailDS(List<dfsle__RecipientStatus__c> recipientList,genesis__Applications__c objApplication){
        /**
         * update the genesis__Status__c = 'SIGNATURE COMPLETETED' only when the current status is 'SIGNATURE PENDING'.
         * update the Stage__c to 'Scoring & Credit Reference' only when the current stage is 'Applicant Signature'
         */

        List<genesis__Applications__c> fetchedApplications = [SELECT Id, 
                                                                    genesis__Status__c, 
                                                                    Stage__c
                                                                FROM genesis__Applications__c
                                                                WHERE Id = :objApplication.Id
                                                                LIMIT 1]; 

        if (fetchedApplications.size() == 0) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }

        if (recipientList.size() > 0) {
            return;
        }

        if (objApplication.Agreement_Sign__c == false && 
            objApplication.Signing_Method__c == PortalConstants.EMAIL_DOCUSIGN) {
            objApplication.Agreement_Sign__c = true;

            if (fetchedApplications[0].genesis__Status__c == PortalConstants.E_SIGN_PENDING_APPLICATION_STATUS) {
                objApplication.genesis__Status__c = PortalConstants.E_SIGN_COMPLETED_APPLICATION_STATUS;
            }
            
        }
        // Change the stage of Application
        if (objApplication.Stage__c == PortalConstants.APPLICANT_SIGNATURE) {
            objApplication.Stage__c = PortalConstants.SCORE_CREDIT_REFERENCE;
        }
    }

    /**
    * @description 
    * @author Krishanu Chinya | 06-27-2024 
    * @param partyObjMap 
    * @param status 
    * @return clcommon__party__c 
    **/
    public static clcommon__party__c updateApplicationPartyForEmailDS(  Map<String,clcommon__Party__c> partyObjMap,dfsle__RecipientStatus__c status){
        clcommon__party__c party = partyObjMap.get(status.dfsle__SourceId__c);
        if(partyObjMap.containsKey(status.dfsle__SourceId__c) && party.genesis__Application__r.Signing_Method__c ==  PortalConstants.EMAIL_DOCUSIGN && party.clcommon__Contact__c == status.dfsle__SourceId__c) {
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
    * @description 
    * @author Krishanu Chinya | 06-27-2024 
    * @param recipientList 
    * @param applicationObj 
    **/
    public static void updateApplicationForInPersonDS(List<dfsle__RecipientStatus__c> recipientList,genesis__Applications__c applicationObj){
        if(recipientList.size() == 0){
            if(applicationObj.Agreement_Sign__c == false 
                && (applicationObj.Signing_Method__c == PortalConstants.IN_PERSON_DOCUSIGN 
                        | applicationObj.Signing_Method__c == ConstantValues.IN_PERSON_HYBRID)){

                applicationObj.Agreement_Sign__c = true;
                applicationObj.genesis__Status__c = PortalConstants.E_SIGN_COMPLETED_APPLICATION_STATUS;
            }
            //Change the stage of Application
            if(applicationObj.Stage__c == PortalConstants.APPLICANT_SIGNATURE){
                applicationObj.Stage__c = PortalConstants.SCORE_CREDIT_REFERENCE;
            }
        }
    }

    /**
    * @description 
    * @author Krishanu Chinya | 06-27-2024 
    * @param partyObjMap 
    * @param status 
    * @return clcommon__party__c 
    **/
    public static clcommon__party__c updateApplicationPartyForInPersonDS(Map<String,clcommon__Party__c> partyObjMap,dfsle__RecipientStatus__c status){
        clcommon__party__c party = partyObjMap.get(status.dfsle__SourceId__c);
        if(partyObjMap.containsKey(status.dfsle__SourceId__c) 
            && (party.genesis__Application__r.Signing_Method__c ==  PortalConstants.IN_PERSON_DOCUSIGN  
                    | party.genesis__Application__r.Signing_Method__c == ConstantValues.IN_PERSON_HYBRID) 
            && party.clcommon__Contact__c == status.dfsle__SourceId__c) {

            if(status.dfsle__Status__c == PortalConstants.ENVELOPE_STATUS_DELIVERED 
                | status.dfsle__Status__c == PortalConstants.ENVELOPE_STATUS 
                | status.dfsle__Status__c == PortalConstants.ENVELOPE_STATUS_CREATED) {

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
}