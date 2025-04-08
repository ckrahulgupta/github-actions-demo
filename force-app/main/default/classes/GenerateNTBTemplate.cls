/**
 * @description       : Class for all generated NTB templates as Master file.
 * @author            : Simran
 * @group             : 
 * @last modified on  : 03-06-2024
 * @last modified by  :  Pritam Roy
**/
public with sharing class GenerateNTBTemplate {
    public static final String APPLICATION_LIST_URL = '/lightning/o/genesis__Applications__c/list?filterName=Recent';
    /**
    * @description : Generate NTB
    * @author  Pritam Roy | 03-06-2024 
    * @return string 
    **/
    public static string generateNTB() {
        List<ContentDocumentLink> objContentDocumentLinkList = new List<ContentDocumentLink>();
        List<Id> objApplicationIdList = new List<Id>();
        List<Id> objPartyList = new List<Id>();
        String url = '/sfc/servlet.shepherd/document/download';
        String controllerClassName = 'GenerateNTBTemplate';
        String ntb='NTB (Buyer';
        String name='s Name - ';
        String pdf=').pdf';
        
        try{
            List<clcommon__Party__c> objPartyIdList= new List<clcommon__Party__c>();
            if(clcommon__Party__c.SObjectType.getDescribe().isAccessible()){
                objPartyIdList=[SELECT Id,
                                        clcommon__Account__r.Name,
                                        genesis__Application__r.Id
                                FROM clcommon__Party__c 
                                WHERE clcommon__Party_Types__c = :PortalConstants.BUYER_PARTY_NAME 
                                AND genesis__Application__r.genesis__status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS 
                                AND NTB_Report_Generated__c = false 
                                AND NTB_Generated__c = true];
            }
            if(objPartyIdList.size()==0){
                url=String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm()) + APPLICATION_LIST_URL  ;
                return url;
            }
            List<String> templateNameList=new List<String>();
            for(clcommon__Party__c partyRecord : objPartyIdList){
                objApplicationIdList.add(partyRecord.genesis__Application__r.Id);
                templateNameList.add(ntb+'\''+name+partyRecord.clcommon__Account__r.Name+pdf);
            }
            if(ContentDocumentLink.SObjectType.getDescribe().isAccessible()){
                objContentDocumentLinkList =  [SELECT  ContentDocumentId,
                                                    linkedEntityId
                                            FROM ContentDocumentLink
                                            WHERE linkedEntityId 
                                            IN :objApplicationIdList
                                            AND ContentDocument.Title
                                            IN :templateNameList];
            }
            if(objContentDocumentLinkList.size() == 0){
                url=String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm()) + APPLICATION_LIST_URL  ;
                return url;
            }
            if(objPartyIdList.size()==objContentDocumentLinkList.size()){
                for(ContentDocumentLink objContent : objContentDocumentLinkList){
                    url = url + '/' + objContent.ContentDocumentId;
                }
                for(clcommon__Party__c partyRecord : objPartyIdList){
                    
                objPartyList.add(partyRecord.Id);
                }
                List<clcommon__Party__c> objParty = [SELECT Id,
                                                            NTB_Report_Generated__c 
                                                    FROM clcommon__Party__c 
                                                    WHERE Id 
                                                    IN :objPartyList];
                for(clcommon__Party__c objPartyField : objParty){
                    objPartyField.NTB_Report_Generated__c = true;
                } 
                if(clcommon__Party__c.SObjectType.getDescribe().isUpdateable()){
                    Database.update(objParty,true);}
            }
            else{
                url=String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm()) + APPLICATION_LIST_URL  ;
                return url;
            }
        }
        catch (Exception objException) {
            if(clcommon__Log__c.SObjectType.getDescribe().isCreateable()){
                PortalHelper.saveExceptionLog(objException, controllerClassName);
            }
        }                                   
        return url;  
    }
    /**
    * @description : variable to store type
    * @author  Pritam Roy | 03-06-2024
    **/
    public String type { get; set; }
    /**
    * @description :constructor for controller
    * @author  Pritam Roy | 03-06-2024 
    * @param controller 
    **/
    public GenerateNTBTemplate(ApexPages.StandardController controller) {
        type =  String.valueOf(controller.getRecord());
    }
    /**
    * @description : Method that can be called from the Visual Force page action attribute
    * @author  Pritam Roy | 03-06-2024 
    * @return PageReference 
    **/
    public Static PageReference generateSummaryPDF() {
        //Get the user profile
        Id profileId = UserInfo.getProfileId(); 
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        if(profileName.equalsIgnoreCase(ConstantValues.PROFILE_ADMIN) || 
            profileName.equalsIgnoreCase(ConstantValues.PROFILE_CFA_ADMIN) || 
            profileName.equalsIgnoreCase(ConstantValues.PROFILE_CREDIT)){
                String url = generateNTB();
                String retPage;
                if(url==String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm()) + APPLICATION_LIST_URL){
                    retPage = String.valueOf(System.URL.getSalesforceBaseUrl().toExternalForm()) + APPLICATION_LIST_URL  ;
                    PageReference retPageRef = new PageReference(retPage);
                    return retPageRef;
                }
                retPage = String.valueOf(ApexPages.currentPage().getHeaders().get('Referer')) + url;
                PageReference RetPageRef = new PageReference(retPage);
                return RetPageRef;
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ConstantValues.INSUFFICIENT_ACCESS));
            return null;
        }
        
    }    
}