/**
 * @description This class is used to send Document through email for eSignature.
 * @author Simran
 * @created Date : 15-02-2022
 * @last modified on  : 08-26-2024
 * @last modified by  : Ayan Bhowmik
 */
public with sharing class DocuSignviaEmail implements Queueable, Database.AllowsCallouts {
    private  String objapplicationId;
    private  String objContentId;
    private static final String RIGHT = 'right';
    private static final String PIXELS = 'pixels';
    private static final String DOCUSIGN_VIA_EMAIL = 'DocuSignviaEmail';
    private static final String CFA = 'CFA';
    
    /**
     * @description Purpose of this constructor is to check pass the parameters.
     * @param contentDocumentId 
     * @param linkedEntityId 
     */
    public DocuSignviaEmail(String contentDocumentId, String linkedEntityId){
        this.objContentId = contentDocumentId;
        this.objapplicationId = linkedEntityId;
    }
    
    /**
     * @description This class is used to send Document through email for eSignature. 
     * @param context 
     * @exception 
     */
    public void execute(QueueableContext context){
        try{
            if(objContentId != ''){
                List<clcommon__Party__c> partyList =  [SELECT  Id,
                                                                clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                                genesis__Application__r.Signing_Method__c,
                                                                clcommon__Account__r.Name 
                                                        FROM clcommon__Party__c 
                                                        WHERE genesis__Application__r.Id = :objapplicationId
                                                        AND clcommon__Type__r.Name = :PortalConstants.BORROWER_PARTY_NAME LIMIT 1];
                if(partyList.isEmpty()){
                    throw new CustomException(PortalConstants.NO_PARTY_FOUND);
                }
                if(partyList[0].genesis__Application__r.Signing_Method__c == PortalConstants.EMAIL_DOCUSIGN){

                    checkApplicationEntityTypeForEmailDocusign(partyList[0]);
                    
                }
            }
            
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, DOCUSIGN_VIA_EMAIL);
            }    
    }
    

    /**
    * @description This method is used to send Document through email of Entity Type Individual / Individual(s) with DBA / Individual(s) - Sole Proprietorship
    **/
    private void docuSignViaEmailForIndividual() {
        try{
            // Create an empty envelope
            dfsle.Envelope objEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(objapplicationId));
            // The ID of a document stored in a Salesforce library
            Id objContentDocumentId =  [SELECT ContentDocumentId 
                                        FROM ContentVersion 
                                        WHERE ContentDocumentId = :objContentId 
                                        AND Title = :PortalConstants.AGREEMENT_FILE_NAME].id;
            // Add document to the envelope
            objEnvelope = objEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> {objContentDocumentId}));
            List<dfsle.Recipient> objSignerList = new  List<dfsle.Recipient>(); 
            List<clcommon__Party__c> objPartyBorrower =  [SELECT  genesis__Application__r.Id,
                                                                    clcommon__Contact__r.id,
                                                                  clcommon__Contact__r.Name,
                                                                  clcommon__Contact__r.Email 
                                                          FROM clcommon__Party__c 
                                                          WHERE genesis__Application__r.Id = :objapplicationId 
                                                          AND clcommon__Type__r.Name = :PortalConstants.BORROWER_PARTY_NAME];
            dfsle.Entity borrowerEntity = new dfsle.Entity(objPartyBorrower[0].clcommon__Contact__r.id);
            dfsle.Tab borrowerSignHereTab = new dfsle.SignHereTab().withScale(1.0).withRequired(true).withAnchor(
                                        new dfsle.Tab.Anchor(PortalConstants.BORROWER_SIGNED_BY,false,false,RIGHT,true,true,PIXELS,10,5));
            dfsle.Tab borrowerInitialHereTab = new dfsle.InitialHereTab().withScale(1.0).withRequired(true).withAnchor(
                                            new dfsle.Tab.Anchor(PortalConstants.INITIAL+(0),false,false,RIGHT,true,true,PIXELS,10,5));    
            dfsle.Recipient objRecipientBorrower = dfsle.Recipient.fromSource(objPartyBorrower[0].clcommon__Contact__r.Name,objPartyBorrower[0].clcommon__Contact__r.Email,null,PortalConstants.SIGNER,borrowerEntity).withTabs(
                                                    new List<dfsle.Tab>{borrowerSignHereTab, borrowerInitialHereTab});      
            objSignerList.add(objRecipientBorrower);
            List<clcommon__Party__c> objPartyPrincipalList =  [SELECT genesis__Application__r.Id,
                                                                    clcommon__Contact__r.id,
                                                                      clcommon__Contact__r.Name,
                                                                      clcommon__Contact__r.Email
                                                                FROM  clcommon__Party__c 
                                                                WHERE genesis__Application__r.Id= :objapplicationId 
                                                                AND   clcommon__Type__r.Name = :PortalConstants.PRINCIPAL_PARTY_NAME];
            for (Integer iterator=0; iterator < objPartyPrincipalList.size(); iterator++ ){
                dfsle.Entity coBorrowerEntity = new dfsle.Entity(objPartyPrincipalList[iterator].clcommon__Contact__r.id);
                dfsle.Tab coborrowerSignHereTab = new dfsle.SignHereTab().withScale(1.0).withRequired(true).withAnchor(
                                                new dfsle.Tab.Anchor(PortalConstants.SIGNED_BY+(iterator+1)+PortalConstants.SIGN_BY,false,false,RIGHT,true,true,PIXELS,10,5));
                dfsle.Tab coborrowerInitialHereTab = new dfsle.InitialHereTab().withScale(1.0).withRequired(true).withAnchor(
                                                new dfsle.Tab.Anchor(PortalConstants.INITIAL+(iterator+1),false,false,RIGHT,true,true,PIXELS,10,5));
                dfsle.Recipient objRecipientPrincipal = dfsle.Recipient.fromSource(objPartyPrincipalList[iterator].clcommon__Contact__r.Name,objPartyPrincipalList[iterator].clcommon__Contact__r.Email,null,PortalConstants.SIGNER,coBorrowerEntity).withTabs(
                                                        new List<dfsle.Tab>{coborrowerSignHereTab,coborrowerInitialHereTab});
                objSignerList.add(objRecipientPrincipal);
            }   
           /*  dfsle.Tab objSignHereTab2 = new dfsle.SignHereTab().withScale(0.5).withRequired(true).withAnchor(
                                        new dfsle.Tab.Anchor(PortalConstants.CFA_SIGNED_BY,false,false,RIGHT,true,true,PIXELS,10,17));
            dfsle.Recipient objRecipientCFA = dfsle.Recipient.fromSource(CFA,ConstantValues.CFA_EMAIL_DOCUSIGN,null,PortalConstants.SIGNER,null).withTabs(
                                                new List<dfsle.Tab>{objSignHereTab2});  
            objSignerList.add(objRecipientCFA);  */
            // Add a recipient to the envelope  
            objEnvelope = objEnvelope.withRecipients(objSignerList);
            objEnvelope = dfsle.EnvelopeService.sendEnvelope(objEnvelope,true);
            genesis__Applications__c objApplicationField=[SELECT Id, DocuSign_Credit_Agreement_Initiated__c FROM genesis__Applications__c WHERE Id=:objapplicationId];
            objApplicationField.DocuSign_Credit_Agreement_Initiated__c=true;
            Database.update(objApplicationField,true);
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, DOCUSIGN_VIA_EMAIL);
        }    
    }
  
 
    /**
    * @description This method is used to send Document through email of Entity Type other than Individual / Individual(s) with DBA / Individual(s) - Sole Proprietorship
    **/
    private void docuSignViaEmailForCorporation() {
        try{
            // Create an empty envelope
            dfsle.Envelope objEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(objapplicationId));
            // The ID of a document stored in a Salesforce library
            Id objContentDocumentId =  [SELECT ContentDocumentId 
                                        FROM ContentVersion 
                                        WHERE  ContentDocumentId = :objContentId
                                        AND Title =:PortalConstants.AGREEMENT_FILE_NAME].id;
            // Add document to the envelope
            objEnvelope = objEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> { objContentDocumentId }));
            List<dfsle.Recipient> objSignerList = new  List<dfsle.Recipient>(); 
            List<clcommon__Party__c> objPartyPrincipalList =  [SELECT  genesis__Application__r.Id, 
                                                                       clcommon__Contact__r.Name,
                                                                       clcommon__Contact__r.Email,
                                                                       Principal_Number__c
                                                                FROM clcommon__Party__c 
                                                                WHERE genesis__Application__r.Id= :objapplicationId 
                                                                AND clcommon__Type__r.Name = :PortalConstants.PRINCIPAL_PARTY_NAME
                                                                ORDER BY Principal_Number__c ASC];
            for (Integer iterator=0; iterator<objPartyPrincipalList.size(); iterator++){
                List<dfsle.Tab> recipientTabList = new List<dfsle.Tab>();
                dfsle.Entity coBorrowerEntity = new dfsle.Entity(objPartyPrincipalList[iterator].clcommon__Contact__r.id);
                dfsle.Tab coborrowerSignHereTab = new dfsle.SignHereTab().withScale(1.0).withRequired(true).withAnchor(
                                                new dfsle.Tab.Anchor(PortalConstants.SIGNED_BY+(iterator+1)+PortalConstants.SIGN_BY,false,false,RIGHT,true,true,PIXELS,10,5));
                // dfsle.Tab coborrowerInitialHereTab = new dfsle.InitialHereTab().withScale(1.0).withRequired(true).withAnchor(
                //                                 new dfsle.Tab.Anchor(PortalConstants.INITIAL+(iterator+1),false,false,RIGHT,true,true,PIXELS,10,5));
                if(objPartyPrincipalList[iterator].Principal_Number__c == 1){
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
                dfsle.Recipient objRecipientPrincipal = dfsle.Recipient.fromSource(objPartyPrincipalList[iterator].clcommon__Contact__r.Name,objPartyPrincipalList[iterator].clcommon__Contact__r.Email,null,PortalConstants.SIGNER,coBorrowerEntity).withTabs(recipientTabList);
                objSignerList.add(objRecipientPrincipal);
            }  
            /* dfsle.Tab objSignHereTab2 = new dfsle.SignHereTab().withScale(0.5).withRequired(true).withAnchor(
                                         new dfsle.Tab.Anchor(PortalConstants.CFA_SIGNED_BY,false,false,RIGHT,true,true,PIXELS,10,17));
            dfsle.Recipient objRecipientCFA = dfsle.Recipient.fromSource(CFA,ConstantValues.CFA_EMAIL_DOCUSIGN,null,PortalConstants.SIGNER,null).withTabs(
                                            new List<dfsle.Tab>{objSignHereTab2});  
            objSignerList.add(objRecipientCFA); */
            // Add a recipient to the envelope  
            objEnvelope = objEnvelope.withRecipients(objSignerList);
            objEnvelope = dfsle.EnvelopeService.sendEnvelope(objEnvelope,true);
            genesis__Applications__c objApplicationField=[SELECT Id, DocuSign_Credit_Agreement_Initiated__c FROM genesis__Applications__c WHERE Id=:objapplicationId];
            objApplicationField.DocuSign_Credit_Agreement_Initiated__c=true;
            Database.update(objApplicationField,true);
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, DOCUSIGN_VIA_EMAIL);
            }    
    }
    
    /**
     * @description  Purpose of this method is to check entity type of the application and call method accordingly
     * @param party 
     * @exception 
     */
    private void checkApplicationEntityTypeForEmailDocusign(clcommon__Party__c party){
        if((party.clcommon__Account__c == null) || (party.clcommon__Account__r.clcommon__Legal_Entity_Type__c==null)){
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
        if (party.clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name == PortalConstants.INDIVIDUAL || 
                party.clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name == PortalConstants.SOLE_PROP_ENTITY){
            docuSignViaEmailForIndividual();
        }
        else{
            docuSignViaEmailForCorporation(); 
        } 
    }

    /*
    public static void docuSignViaCFA(String appId){
        String RIGHT = 'right';
        String PIXELS = 'pixels';
        String CFA = 'CFA';
        dfsle.Envelope objEnvelope = dfsle.EnvelopeService.getEmptyEnvelope(new dfsle.Entity(appId));
                            // The ID of a document stored in a Salesforce library
                            
                            List<ContentDocumentLink> contentDocLink = [SELECT Id,
                                                                            LinkedEntityId, 
                                                                            ContentDocumentId
                                                                            FROM ContentDocumentLink 
                                                                            WHERE linkedEntityId = :appId];
    
                            List<Id> contentDocumentList = new List<Id>();
                            for(ContentDocumentLink cdlink : contentDocLink){
                                contentDocumentList.add(cdlink.ContentDocumentId);
                            }

                            Id objContentDocumentId =  [SELECT ContentDocumentId 
                                                            FROM ContentVersion 
                                                            WHERE ContentDocumentId  IN :contentDocumentList
                                                            AND Title = :PortalConstants.AGREEMENT_FILE_NAME
                                                            ORDER BY CreatedDate DESC
                                                            LIMIT 1].Id;
                
                            // Add document to the envelope
                            objEnvelope = objEnvelope.withDocuments(dfsle.DocumentService.getDocuments(ContentVersion.getSObjectType(), new Set<Id> {objContentDocumentId}));
                            List<dfsle.Recipient> objSignerList = new  List<dfsle.Recipient>(); 
                            
                            dfsle.Tab objSignHereTab0 = new dfsle.SignHereTab().withScale(0.5).withRequired(true).withAnchor(
                                                        new dfsle.Tab.Anchor(PortalConstants.CFA_SIGNED_BY,false,false,RIGHT,true,true,PIXELS,10,17));
                            dfsle.Recipient objRecipientBorrower = dfsle.Recipient.fromSource(CFA,ConstantValues.CFA_EMAIL_DOCUSIGN,null,PortalConstants.SIGNER,null).withTabs(
                                                                    new List<dfsle.Tab>{objSignHereTab0});      
                            objSignerList.add(objRecipientBorrower);
                        
                            // Add a recipient to the envelope  
                            objEnvelope = objEnvelope.withRecipients(objSignerList);
                            objEnvelope = dfsle.EnvelopeService.sendEnvelope(objEnvelope,true);
    }
*/
}