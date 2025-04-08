/**
 * @description       : Purpose of this class is to approve/reject a my program and avtivate or deactivate it accordingly
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 02-27-2024
 * @last modified by  : Ayan Bhowmik
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   12-04-2022   Subham Nandi   Initial Version
**/
public with sharing class ApprovalOfMyProgramFromVF {
    // declaration specific to this class starts
    /**
     * @description get set method for my program id.
     */
    public Id myProgramId {get; set;}
    /**
     * @description get set method for my program.
     */
    public genesis__Rate_Card_Setup_Header__c myProgram { get; set; }
    String ACTIVE_STRING = 'Active';
    String REJECTED_STRING = 'Rejected';
    String REPLACING_STRING = 'Url:[delegate=';
    String RATECARD_URL = '/lightning/r/genesis__Rate_Card_Setup_Header__c/';
    String VIEW_FORM = 'view';
    String baseURL;
    String myProgramURL;
    PageReference myProgramPage;
    // declaration specific to this class ends
    
    /**
     * @description Constructor to assign my program id.
     * @param controller 
     */
    public ApprovalOfMyProgramFromVF(ApexPages.StandardController controller){
        myProgram = (genesis__Rate_Card_Setup_Header__c)controller.getRecord();
        myProgramId = myProgram.Id;

    }
    /**
    * @description Functions to be done for approval of my program.
    * @author Ayan Bhowmik | 02-27-2024 
    * @return Pagereference 
    **/
    public Pagereference approve() {
        SavePoint dbSavePoint = Database.setSavepoint();
        genesis__Rate_Card_Setup_Header__c objRateCardToApprove = new genesis__Rate_Card_Setup_Header__c();
        
        try {
            if(myProgramId != null){
                if(genesis__Rate_Card_Setup_Header__c.SObjectType.getDescribe().isAccessible()){
                    System.debug('------->'+myProgramId);
                    objRateCardToApprove = [SELECT Id, 
                                                    Status__c 
                                            FROM genesis__Rate_Card_Setup_Header__c
                                            WHERE Id = :myProgramId];     
                    objRateCardToApprove.Status__c = ACTIVE_STRING;
                    objRateCardToApprove.genesis__Enabled_Flag__c = true;
                }
                if(genesis__Rate_Card_Setup_Header__c.SObjectType.getDescribe().isUpdateable()){
                    Database.update(objRateCardToApprove,true);
                }
                baseURL =String.valueOf(System.URL.getOrgDomainUrl());
                if(!String.isBlank(baseURL)){
                    myProgramURL = (baseURL.replace(REPLACING_STRING,'')).replace(']','');
                }
                myProgramURL = myProgramURL +RATECARD_URL+myProgramId+'/'+VIEW_FORM;
                myProgramPage = new PageReference(myProgramURL);
                myProgramPage.setRedirect(true);
            }
            return myProgramPage;
        } 
        catch (Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            PortalHelper.saveExceptionLog(exceptionObj, ConstantValues.APPROVAL_ERROR);
        }
        return null;
        
    }
    /**
    * @description Functions to be done for rejection of my program.
    * @author Ayan Bhowmik | 02-27-2024 
    * @return Pagereference 
    **/
    public Pagereference reject() {
        SavePoint dbSavePoint = Database.setSavepoint();
        genesis__Rate_Card_Setup_Header__c objRateCardToReject = new genesis__Rate_Card_Setup_Header__c();
        try {
            if(myProgramId != null){
                if(genesis__Rate_Card_Setup_Header__c.SObjectType.getDescribe().isAccessible()){
                    objRateCardToReject = [SELECT Id, 
                                                    Status__c 
                                                FROM genesis__Rate_Card_Setup_Header__c
                                                WHERE Id = :myProgramId];
                    objRateCardToReject.Status__c = REJECTED_STRING;
                    objRateCardToReject.genesis__Enabled_Flag__c = false;
                }
                if(genesis__Rate_Card_Setup_Header__c.SObjectType.getDescribe().isUpdateable()){
                    Database.update(objRateCardToReject,true);
                }
                baseURL =String.valueOf(System.URL.getOrgDomainUrl());
                if(!String.isBlank(baseURL)){
                    myProgramURL = (baseURL.replace(REPLACING_STRING,'')).replace(']','');
                }
                myProgramURL = myProgramURL +RATECARD_URL+myProgramId+'/'+VIEW_FORM;
                myProgramPage = new PageReference(myProgramURL);
                myProgramPage.setRedirect(true);
            }
            
            return myProgramPage;
        } 
        catch (Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            PortalHelper.saveExceptionLog(exceptionObj, ConstantValues.APPROVAL_ERROR);
        }
        return null;
    }
    
}