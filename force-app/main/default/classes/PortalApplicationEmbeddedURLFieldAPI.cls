/***************************************************************************************
 * @className         : PortalApplicationEmbeddedURLFieldAPI
 * @description       : This class is used to check Embedded DocuSign URL field is null or not.
 * @author            : Ayush Kumar Singh
 * @created Date      : 04-05-2022
 * @last modified on  : 03-11-2024
 * @last modified by  : Tuhin Bhunia
 ****************************************************************************************/

global without sharing class PortalApplicationEmbeddedURLFieldAPI implements clcommon.PortalCustomRemoteAPI1{
    private static final String KEY_APPLICATION= 'application';
    private static final String KEY_URL= 'DocuSign_URL__c';
    private static final String KEY_SIGNING_COMPLETED = 'Signing_Completed';
    private static final String STATUS_SENT = 'Sent';
    private static final String STATUS_DELIVERED = 'Delivered';
    String objApplicationRecord = '';
    genesis__Applications__c objfetchApplication = new genesis__Applications__c();
    SavePoint dbSavePoint = Database.setSavepoint();

    /**
     * @description : This method is used to get to know Embedded DocuSign URL is null or not and send response accordinly.
     * @param componentStrName 
     * @param disclosureNames 
     * @param argumentsFromPortal 
     * @return  `clcommon.Response`
     * @exception 
     */
    global clcommon.Response invokeAction(String componentStrName,
                                          String[] disclosureNames,
                                          Map<String, Object> argumentsFromPortal) {
        clcommon.Response objResponse = new clcommon.Response();
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        Map<String,Object> fieldMap = new Map<String,Object>();
        List<dfsle__Recipient__c> recipientList = new List<dfsle__Recipient__c>();
        List<dfsle__RecipientStatus__c> recipientStatusList = new List<dfsle__RecipientStatus__c>();
        List<clcommon__party__c> updatePartyList = new List<clcommon__party__c>();

        Decimal urlTime = 0.0;
        try{
            objApplicationRecord = String.valueOf(argumentsFromPortal.get(KEY_APPLICATION));
            if (String.isBlank(objApplicationRecord)) {
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            objfetchApplication = (genesis__Applications__c) Json.deserialize(objApplicationRecord, genesis__Applications__c.class);            

            List<genesis__Applications__c> objApplication = [SELECT Id,
                                                                Agreement_Sign__c 
                                                            FROM genesis__Applications__c 
                                                            WHERE Id =: objfetchApplication.Id];
            if(objApplication.isEmpty()) {
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            List<clcommon__party__c> partyList = [SELECT Id,
                                                        clcommon__Account__r.Name,DocuSign_URL__c,
                                                        Sent_Url__c,clcommon__Contact__c,DocuSign_Generation_Time__c  
                                                    FROM clcommon__party__c 
                                                    WHERE genesis__Application__r.Id = :objfetchApplication.Id 
                                                    AND (clcommon__Type__r.Name = :PortalConstants.BORROWER_PARTY_NAME 
                                                    OR clcommon__Type__r.Name = :PortalConstants.PRINCIPAL_PARTY_NAME)];

            List<dfsle__Envelope__c> envelopeList = [SELECT 
                                                        id,
                                                        dfsle__DocuSignId__c 
                                                        FROM dfsle__Envelope__c 
                                                        WHERE dfsle__SourceId__c =:objApplication[0].id ORDER BY createddate desc limit 1];
                                                   
            if(envelopeList.size()>0){
                recipientStatusList= [SELECT 
                                        id,dfsle__SourceId__c,
                                        dfsle__Status__c 
                                        FROM dfsle__RecipientStatus__c 
                                        WHERE dfsle__EnvelopeStatus__r.dfsle__SourceId__c=: objApplication[0].id AND dfsle__EnvelopeStatus__r.dfsle__DocuSignId__c =: envelopeList[0].dfsle__DocuSignId__c and (dfsle__Status__c = :STATUS_SENT OR dfsle__Status__c = :STATUS_DELIVERED) limit 1];
            }
            
            
            for(clcommon__party__c party : partyList){
                urlTime = 0.0;
                if(party.DocuSign_Generation_Time__c !=null){
                    urlTime = Decimal.valueOf((System.now().getTime()-party.DocuSign_Generation_Time__c.getTime())/(1000*60));
                }                
                if(recipientStatusList.size()>0 && urlTime>=5 && party.clcommon__Contact__c == recipientStatusList[0].dfsle__SourceId__c){
                    List<DocuSignPlatformEvent__e > docuSignEvents = new List<DocuSignPlatformEvent__e>();
                    docuSignEvents.add(new DocuSignPlatformEvent__e(Application_Id__c = objApplication[0].id ));
                    List<Database.SaveResult> results = EventBus.publish(docuSignEvents);
                    break;
                }
                
                else if(party.DocuSign_URL__c != null && party.Sent_Url__c ==false && urlTime<5){
                    objResponse.status = clcommon.Constants.SUCCESS;
                    fieldMap.put(KEY_URL,party.DocuSign_URL__c);
                    responseData.add(new clcommon.PortalCustomRemoteActionRecord(fieldMap));
                    objResponse = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
                    objResponse.content = null;
                    party.Sent_Url__c =true;
                    updatePartyList.add(party);
                    break;   
                }
                else if(objApplication[0].Agreement_Sign__c == true){
                    objResponse.status = clcommon.Constants.SUCCESS;
                    fieldMap.put(KEY_SIGNING_COMPLETED,true);
                    responseData.add( new clcommon.PortalCustomRemoteActionRecord(fieldMap));
                    objResponse = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
                    objResponse.content = null;
                }
                else{
                    objResponse.status = clcommon.Constants.PENDING;
                }
            }
            if(updatePartyList.size()>0){
                Database.update(updatePartyList,true);
            }
        }
        catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            objResponse.status = clcommon.Constants.API_EXCEPTION;
            objResponse.errorMessage = objCustomException.getMessage();
        }
        catch (Exception objException) {
            Database.rollback(dbSavePoint);
            objResponse.status = clcommon.Constants.API_EXCEPTION;
            objResponse.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
        }
        return objResponse;
    }
}