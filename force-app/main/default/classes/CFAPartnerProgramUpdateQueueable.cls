/**
 * @description       : The purpose of this class is to update Cfa Partner program fields.
 * @author            : Ayan Bhowmik
 * @group             : 
 * @last modified on  : 07-10-2024
 * @last modified by  : Soumik Pattanayak
**/
public with sharing class CFAPartnerProgramUpdateQueueable implements Queueable{
    private static final String CLASS_NAME = CFAPartnerProgramUpdateQueueable.class.getName();
    private static final String DEALER_PORTAL_LOGO = '_Dealer_Portal_Logo';
    private static final String DEALER_PORTAL_NAV_BANNER = '_Dealer_Portal_Nav_Banner';
    private static final String GROWER_PORTAL_LOGO = '_Grower_Portal_Logo';
    private static final String GROWER_PORTAL_NAV_BANNER = '_Grower_Portal_Nav_Banner';
    private Map<String, String> fieldToSrMap = new Map<String, String>();
    private String programId; 
    private String congaTemplateLogoId; 

    /**
     * @description constructor for assigning the Ids and Map
     * @param fieldToSrMap 
     * @param programId 
     * @param congaTemplateLogoId 
     */
    public CFAPartnerProgramUpdateQueueable(Map<String, String> fieldToSrMap, String programId, String congaTemplateLogoId) {
        this.fieldToSrMap = fieldToSrMap;
        this.programId = programId;
        this.congaTemplateLogoId = congaTemplateLogoId;
    }
    /**
    * @description Execute method for the class CFAPartnerProgramUpdateQueueable
    * @author Ayan Bhowmik | 06-18-2024 
    * @param context 
    **/
    public void execute(QueueableContext context) {
        try{
            List<CFA_Partner_Program__c> partnerProgramList = [SELECT Id,
                                                                Dealer_Portal_Nav_Banner__c,
                                                                Grower_Portal_Nav_Banner__c,
                                                                Dealer_Portal_Logo__c,
                                                                Grower_Portal_Logo__c
                                                            FROM CFA_Partner_Program__c
                                                            WHERE Id =: programId
                                                            LIMIT 1];
            CFAOriginationHelperClass.checkEmptyList(partnerProgramList, ConstantValues.SOMETHING_WENT_WRONG);
            partnerProgramList[0].Dealer_Portal_Logo__c = fieldToSrMap.get(DEALER_PORTAL_LOGO);
            partnerProgramList[0].Dealer_Portal_Nav_Banner__c = fieldToSrMap.get(DEALER_PORTAL_NAV_BANNER);
            partnerProgramList[0].Grower_Portal_Logo__c = fieldToSrMap.get(GROWER_PORTAL_LOGO);
            partnerProgramList[0].Grower_Portal_Nav_Banner__c = fieldToSrMap.get(GROWER_PORTAL_NAV_BANNER);
            List<ContentVersion> contentVersionList = [SELECT Id,
                                                                Logo_URL__c
                                                            FROM ContentVersion
                                                            WHERE ContentDocumentId = :congaTemplateLogoId
                                                            LIMIT 1];
            if(!contentVersionList.isEmpty() && !String.isBlank(contentVersionList[0].Logo_URL__c)){
                partnerProgramList[0].Conga_Template_Logo__c = contentVersionList[0].Logo_URL__c;
            }
            Database.update(partnerProgramList[0], true);
        } catch(Exception exceptionObj) {
            PortalHelper.saveExceptionLog(exceptionObj, CLASS_NAME);
        }
    }
}