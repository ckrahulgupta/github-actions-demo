/**
 * @description       : This class is used to create and send the Envelope for In Person docusign.
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 11-04-2024
 * @last modified by  : Suraj Kumar
**/
public with sharing class InPersonDocuSignCreateEnvelope implements Queueable, Database.AllowsCallouts {
    private String applicationId;
    private String contentDocId;
    private static final String RIGHT = 'right';
    private static final String PIXELS = 'pixels';
    private static final String SIGNER = 'Signer ';
    private static final String PARTY_ERROR = 'No Parties found ';
    private static final String NULL_CONTENT_DOCUMENT = 'No Content Document Id found ';

    /**
     * @description  Purpose of this constructor is to check pass the parameters.
     * @param contentDocumentId 
     * @param linkedEntityId 
     */
    public InPersonDocuSignCreateEnvelope(String contentDocumentId, String linkedEntityId){
        this.contentDocId = contentDocumentId;
        this.applicationId = linkedEntityId;
    }
    /**
     * @description This class is used to send Document through email for eSignature. 
     * @param context 
     * @exception 
     */
    public void execute(QueueableContext context){
        try{
            Id envelopeId; 
            if(contentDocId != PortalConstants.EMPTY_STRING){
                List<clcommon__Party__c> borrowerPartyList =  [SELECT  Id,
                                                            clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                            genesis__Application__r.Signing_Method__c,
                                                            clcommon__Account__r.Name 
                                                        FROM clcommon__Party__c 
                                                        WHERE genesis__Application__r.Id = :applicationId
                                                        AND clcommon__Type__r.Name = :PortalConstants.BORROWER_PARTY_NAME LIMIT 1]; 
                
                if(borrowerPartyList.isEmpty()) {
                    throw new CustomException(PARTY_ERROR);
                }
                String signingMethod = borrowerPartyList[0].genesis__Application__r.Signing_Method__c;

                if(signingMethod == ConstantValues.IN_PERSON_DOCUSIGN || signingMethod == ConstantValues.IN_PERSON_HYBRID){
                    envelopeId = getEnvelopeIdForInPersonDocusign(borrowerPartyList[0]);

                    System.enqueueJob(new InPersonDSUpdateRecipientCalloutAPI(envelopeId,applicationId,signingMethod));
                }
            }
        } catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, ConstantValues.IN_PERSON_DOCUSIGN);
        }    
    }

    /**
     * @description This method is used to send Document through email of Entity Type Individual / Individual(s) with DBA / Individual(s) - Sole Proprietorship
     * @return  `dfsle.Envelope`
     * @exception 
     */
    private dfsle.Envelope inPersonDocuSignForIndividual() {
        try{
            dfsle.Envelope envelopeObj = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(applicationId));
            Id contentDocumentId =  [SELECT ContentDocumentId 
                                        FROM ContentVersion 
                                        WHERE ContentDocumentId = :contentDocId 
                                        AND Title = :PortalConstants.AGREEMENT_FILE_NAME].id;
            if(contentDocumentId == null) {
                throw new CustomException(NULL_CONTENT_DOCUMENT);
            }
            envelopeObj = envelopeObj.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> {contentDocumentId}));
            List<dfsle.Recipient> signerList = new  List<dfsle.Recipient>(); 
            List<clcommon__Party__c> borrowerPartyList =  [SELECT  genesis__Application__r.Id, 
                                                                  clcommon__Contact__r.Name,
                                                                  clcommon__Contact__r.Email 
                                                          FROM clcommon__Party__c 
                                                          WHERE genesis__Application__r.Id = :applicationId 
                                                          AND clcommon__Type__r.Name = :PortalConstants.BORROWER_PARTY_NAME];
            if(borrowerPartyList.isEmpty()) {
                throw new CustomException(PARTY_ERROR);
            }
            dfsle.Tab borrowerSignHereTab = new dfsle.SignHereTab().withScale(1.0).withRequired(true).withAnchor(
                                        new dfsle.Tab.Anchor(PortalConstants.BORROWER_SIGNED_BY,false,false,RIGHT,true,true,PIXELS,10,5));
            dfsle.Tab borrowerInitialHereTab = new dfsle.InitialHereTab().withScale(1.0).withRequired(true).withAnchor(
                                            new dfsle.Tab.Anchor(PortalConstants.INITIAL+(0),false,false,RIGHT,true,true,PIXELS,10,5));    
            dfsle.Recipient borrowerRecipientObj = dfsle.Recipient.fromSource(borrowerPartyList[0].clcommon__Contact__r.Name,borrowerPartyList[0].clcommon__Contact__r.Email,null,PortalConstants.SIGNER,new dfsle.Entity(borrowerPartyList[0].clcommon__Contact__r.id)).withTabs(
                                                    new List<dfsle.Tab>{borrowerSignHereTab, borrowerInitialHereTab});      
            signerList.add(borrowerRecipientObj);
            List<clcommon__Party__c> principalPartyList =  [SELECT genesis__Application__r.Id, 
                                                                      clcommon__Contact__r.Name,
                                                                      clcommon__Contact__r.Email
                                                                FROM  clcommon__Party__c 
                                                                WHERE genesis__Application__r.Id= :applicationId 
                                                                AND   clcommon__Type__r.Name = :PortalConstants.PRINCIPAL_PARTY_NAME];
            for (Integer iterator=0; iterator < principalPartyList.size(); iterator++ ){
                dfsle.Tab coborrowerSignHereTab = new dfsle.SignHereTab().withScale(1.0).withRequired(true).withAnchor(
                                                new dfsle.Tab.Anchor(PortalConstants.SIGNED_BY+(iterator+1)+PortalConstants.SIGN_BY,false,false,RIGHT,true,true,PIXELS,10,5));
                dfsle.Tab coborrowerInitialHereTab = new dfsle.InitialHereTab().withScale(1.0).withRequired(true).withAnchor(
                                                new dfsle.Tab.Anchor(PortalConstants.INITIAL+(iterator+1),false,false,RIGHT,true,true,PIXELS,10,5));
                dfsle.Recipient principalRecipientObj = dfsle.Recipient.fromSource(principalPartyList[iterator].clcommon__Contact__r.Name,principalPartyList[iterator].clcommon__Contact__r.Email,null,SIGNER+(iterator+2),new dfsle.Entity(principalPartyList[iterator].clcommon__Contact__r.id)).withTabs(
                                                        new List<dfsle.Tab>{coborrowerSignHereTab,coborrowerInitialHereTab});
                signerList.add(principalRecipientObj);
            }   

            envelopeObj = envelopeObj.withRecipients(signerList);
            envelopeObj = dfsle.EnvelopeService.sendEnvelope(envelopeObj,false);
            
            updateCreditAgreementIniated(applicationId);
            
            return envelopeObj;
        } catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, ConstantValues.IN_PERSON_DOCUSIGN);
            return null;
        }    
    }
    
    /**
    * @description This method is used to send Document through email of Entity Type Individual / Individual(s) with DBA / Individual(s) - Sole Proprietorship
    * @author Ayush Kumar Singh | 11-09-2023 
    * @return dfsle.Envelope 
    **/
    private dfsle.Envelope inPersonDocuSignForCorporation() {
        try{

            dfsle.Envelope envelopeObj = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(applicationId));
            Id contentDocumentId =  [SELECT ContentDocumentId 
                                        FROM ContentVersion 
                                        WHERE  ContentDocumentId = :contentDocId
                                        AND Title =:PortalConstants.AGREEMENT_FILE_NAME].id;
            if(contentDocumentId == null) {
                throw new CustomException(NULL_CONTENT_DOCUMENT);
            }
            envelopeObj = envelopeObj.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { contentDocumentId }));
            List<dfsle.Recipient> signerList = new  List<dfsle.Recipient>(); 
            List<clcommon__Party__c> principalPartyList =  [SELECT  genesis__Application__r.Id, 
                                                                       clcommon__Contact__r.Name,
                                                                       clcommon__Contact__r.Email,
                                                                       Principal_Number__c
                                                                FROM clcommon__Party__c 
                                                                WHERE genesis__Application__r.Id= :applicationId 
                                                                AND clcommon__Type__r.Name = :PortalConstants.PRINCIPAL_PARTY_NAME
                                                                ORDER BY Principal_Number__c];
            for (Integer iterator=0; iterator<principalPartyList.size(); iterator++){
                List<dfsle.Tab> recipientTabList = new List<dfsle.Tab>();
                dfsle.Tab coborrowerSignHereTab = new dfsle.SignHereTab().withScale(1.0).withRequired(true).withAnchor(
                                                new dfsle.Tab.Anchor(PortalConstants.SIGNED_BY+(iterator+1)+PortalConstants.SIGN_BY,false,false,RIGHT,true,true,PIXELS,10,5));
                // dfsle.Tab coborrowerInitialHereTab= new dfsle.InitialHereTab().withScale(1.0).withRequired(true).withAnchor(
                //                                 new dfsle.Tab.Anchor(PortalConstants.INITIAL+(iterator+1),false,false,RIGHT,true,true,PIXELS,10,5));
                if(principalPartyList[iterator].Principal_Number__c == 1){
                    dfsle.Tab resolutionSignHereTab = new dfsle.SignHereTab().withScale(1.0).withRequired(true).withAnchor(
                        new dfsle.Tab.Anchor(PortalConstants.SIGNATURE_ONE+PortalConstants.SIGN_BY,false,false,RIGHT,true,true,PIXELS,10,5));
                    dfsle.Tab resolutionInitialHereTab = new dfsle.InitialHereTab().withScale(1.0).withRequired(true).withAnchor(
                        new dfsle.Tab.Anchor(PortalConstants.INTT_ONE,false,false,RIGHT,true,true,PIXELS,10,5));
                    recipientTabList.add(resolutionSignHereTab);
                    recipientTabList.add(resolutionInitialHereTab);
                } else {
                    dfsle.Tab coborrowerInitialHereTab = new dfsle.InitialHereTab().withScale(1.0).withRequired(true).withAnchor(
                                                new dfsle.Tab.Anchor(PortalConstants.INITIAL+(iterator+1),false,false,RIGHT,true,true,PIXELS,10,5));
                    recipientTabList.add(coborrowerInitialHereTab);                       
                }
                recipientTabList.add(coborrowerSignHereTab);
                dfsle.Recipient principalRecipientObj = dfsle.Recipient.fromSource(principalPartyList[iterator].clcommon__Contact__r.Name,principalPartyList[iterator].clcommon__Contact__r.Email,null,SIGNER+(iterator+1),new dfsle.Entity(principalPartyList[iterator].clcommon__Contact__r.id)).withTabs(recipientTabList);
                signerList.add(principalRecipientObj);
            }  

            envelopeObj = envelopeObj.withRecipients(signerList);
            envelopeObj = dfsle.EnvelopeService.sendEnvelope(envelopeObj,false);

            updateCreditAgreementIniated(applicationId);
    
            return envelopeObj;
        } catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, ConstantValues.IN_PERSON_DOCUSIGN);
            return null;
        }    
    }

   /**
    * @description Purpose of this method is to check entity type of the application and call method accordingly
    * @param party 
    * @return  `Id`
    * @exception 
    */
    private Id getEnvelopeIdForInPersonDocusign(clcommon__Party__c party){
        Id envelopeId;
        if((party.clcommon__Account__c == null) || (party.clcommon__Account__r.clcommon__Legal_Entity_Type__c==null)){
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
        else if (party.clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name == PortalConstants.SOLE_PROP_ENTITY){
            dfsle.Envelope envelope  = inPersonDocuSignForIndividual();
            envelopeId = envelope.id;
        }
        else{
            dfsle.Envelope envelope  = inPersonDocuSignForCorporation(); 
            envelopeId = envelope.id;  
        } 
        return envelopeId;
    }

    /**
    * @description : Method to update credit agreement Iniated 
    * @author Suraj Kumar | 11-04-2024 
    * @param applicationId 
    **/
    private static void updateCreditAgreementIniated(String applicationId){
        genesis__Applications__c applicationObj=[SELECT Id, DocuSign_Credit_Agreement_Initiated__c FROM genesis__Applications__c WHERE Id=:applicationId];
        applicationObj.DocuSign_Credit_Agreement_Initiated__c=true;
        Database.update(applicationObj,true);
    }
}