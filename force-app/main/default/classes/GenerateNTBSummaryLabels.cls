/**
 * @description       : Class for all generated NTB Labels as Master file.
 * @author            : Simran
 * @group             : 
 * @last modified on  : 08-10-2024
 * @last modified by  : Soumik Pattanayak
**/
public with sharing class GenerateNTBSummaryLabels {

    /**
    * @description generates the NTB summary labels
    * @author Simran | 08-10-2024 
    * @return string 
    **/
    public static string generateNTBSummary() {
        List<ContentDocumentLink> objContentDocumentLinkList = new List<ContentDocumentLink>();
        List<Id> objPartyList = new List<Id>();
        List<Id> objApplicationIdList = new List<Id>();
        String url='/sfc/servlet.shepherd/document/download';
        String GENERATEDTEMPLATE = 'GenerateNTBSummaryLabels';
        try{
            List<clcommon__Party__c> objPartyIdList=[SELECT Id,
                                                        genesis__Application__r.Id
                                                    FROM clcommon__Party__c 
                                                    WHERE clcommon__Party_Types__c = :PortalConstants.BUYER_PARTY_NAME
                                                    AND genesis__Application__r.genesis__status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS 
                                                    AND NTB_Label_Report_Generated__c = false 
                                                    AND NTB_Generated__c = True];
            if(objPartyIdList.size()==0){
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            
            for(clcommon__Party__c partyRecord : objPartyIdList){
                objApplicationIdList.add(partyRecord.genesis__Application__r.Id);
            }
            
            objContentDocumentLinkList =  [SELECT  ContentDocumentId,
                                                linkedEntityId
                                                FROM ContentDocumentLink
                                                WHERE linkedEntityId 
                                                IN :objApplicationIdList
                                                AND ContentDocument.Title
                                                LIKE 'NTB Labels(Buye%' ];
                                        
            if(objContentDocumentLinkList.size() == 0){
                return '';
            }
            for(ContentDocumentLink objContent : objContentDocumentLinkList){
                System.debug(objContent.ContentDocumentId);
                url = url + '/' + objContent.ContentDocumentId;
            }
            for(clcommon__Party__c partyRecord : objPartyIdList){
            objPartyList.add(partyRecord.Id);
            }
            List<clcommon__Party__c> objParty=[SELECT Id,
                                                      NTB_Label_Report_Generated__c
                                                FROM clcommon__Party__c 
                                                WHERE Id 
                                                IN :objPartyList];
            for(clcommon__Party__c partyField : objParty){
                partyField.NTB_Label_Report_Generated__c=true;
                Database.update(partyField,true);
            } 
        }
        catch (Exception objException) {
            Database.insert(new clcommon__Log__c(Name = GENERATEDTEMPLATE,
                                                 clcommon__Message__c = GENERATEDTEMPLATE
                                                                            + objException.getStackTraceString()
                                                                            + ConstantValues.SOMETHING_WENT_WRONG,
                                                 clcommon__Time__c = System.Now()), 
                                                 false);
        }                                   
        return url;
    }

    public String type { get; set; }
    /**
    * @description assign type
    * @author Soumik Pattanayak | 08-10-2024 
    * @param controller 
    **/
    public GenerateNTBSummaryLabels(ApexPages.StandardController controller) {
        type =  String.valueOf(controller.getRecord());
    }
    
    /**
    * @description Method that is called from the Visual Force page action attribute
    * @author Soumik Pattanayak | 08-10-2024 
    * @return PageReference 
    **/
    public Static PageReference generateSummaryPDF() {
        //Get the user profile
        Id profileId = UserInfo.getProfileId(); 
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        if(profileName.equalsIgnoreCase(ConstantValues.PROFILE_ADMIN) || 
            profileName.equalsIgnoreCase(ConstantValues.PROFILE_CFA_ADMIN) || 
            profileName.equalsIgnoreCase(ConstantValues.PROFILE_CREDIT)){
                String url = generateNTBSummary();
                String RetPage = String.valueOf(ApexPages.currentPage().getHeaders().get('Referer')) + url;
                PageReference RetPageRef = new PageReference(RetPage);
                return RetPageRef;
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ConstantValues.INSUFFICIENT_ACCESS));
            return null;
        }
        
    }
}