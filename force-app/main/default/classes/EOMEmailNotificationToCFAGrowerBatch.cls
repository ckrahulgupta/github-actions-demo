/**
 * @description       : Batch class to send Email notification to CFA Grower to see the monthly statement.
 * @author            : Simran
 * @group             : 
 * @last modified on  : 01-04-2024
 * @last modified by  : Ayush Kumar Singh
**/
public with sharing class EOMEmailNotificationToCFAGrowerBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    private static final String GMK_GROWER_URL=System.Label.GMK_Grower_Portal_Url;
    private static final String LANDUS_GROWER_URL = System.Label.Landus_Grower_Portal_Url;
    private static final String GROWER_LINK = '{!growerLogInLink}';

    /**
     * @description : This method is used to query all the Active Application
     * @param batchableContext
     * @return 'Database.QueryLocator'
     */
    public Database.QueryLocator start(Database.BatchableContext batchableContext){
        return Database.getQueryLocator([SELECT Id,
                                            genesis__Contact__r.Email,
                                            genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                            Dealer_Name__r.Coop_Type__c,
                                            (SELECT Id,
                                                    clcommon__Contact__r.Email
                                            FROM genesis__Parties__r
                                            WHERE clcommon__Party_Types__c = :ConstantValues.PRINCIPAL_PARTY
                                            ORDER BY CreatedDate ASC)
                                            FROM genesis__Applications__c 
                                            WHERE genesis__Status__c = :ConstantValues.ACTIVE
                                            ]);
    }

    /**
     * @description : This method is used to add all the emails to the coreGrowerEmailMap Map
     * @param batchableContext
     * @param applicationList
     */
    public void execute(Database.BatchableContext batchableContext, List<genesis__Applications__c> applicationList){
        try{
            CFAOriginationHelperClass.checkEmptyList(applicationList,ConstantValues.PARAMETER_MISSING);
            Map<String,String> coreGrowerEmailMap = new Map<String,String>();
            Map<String,String> coreGrowerCoopTypeMap = new Map<String,String>();
            for(genesis__Applications__c application:applicationList){
                if(application.genesis__Account__c != null &&
                application.genesis__Account__r.clcommon__Legal_Entity_Type__c != null &&
                    (application.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name.equalsIgnoreCase(ConstantValues.SOLE_PROP_ENTITY)) &&
                    application.genesis__Contact__r.Email != null){
                        coreGrowerEmailMap.put(application.id,application.genesis__Contact__r.Email);
                        coreGrowerCoopTypeMap.put(application.id,application.Dealer_Name__r.Coop_Type__c);
                }
                else{
                    if(application.genesis__Parties__r.size() > 0 &&
                    application.genesis__Parties__r[0].clcommon__Contact__r.Email != null){
                            coreGrowerEmailMap.put(application.id,application.genesis__Parties__r[0].clcommon__Contact__r.Email);
                            coreGrowerCoopTypeMap.put(application.id,application.Dealer_Name__r.Coop_Type__c);
                    }
                }
                
            }
            
            CFAOriginationHelperClass.checkEmptyList(applicationList,ConstantValues.EMAIL_LIST_EMPTY);
            sendEmailToGrower(coreGrowerEmailMap,coreGrowerCoopTypeMap);
            
        }
        catch (Exception objException) {
            LoggingUtility.saveExceptionLogging(objException, EOMEmailNotificationToCFAGrowerBatch.class.getName());
        }
    }

     /**
     * @description 
     * @param batchableContext
     */
    public void finish(Database.BatchableContext batchableContext) {}

    /**
     * @description  This method is used to send the email to the CFA Grower
     * @param coreGrowerEmailMap 
     * @param coreGrowerCoopTypeMap 
     * @exception 
     */
    private static void sendEmailToGrower(Map<String,String> coreGrowerEmailMap,Map<String,String> coreGrowerCoopTypeMap){
        OrgWideEmailAddress senderAddress =  [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName=:ConstantValues.ORG_WIDE_NO_REPLY_EMAIL_ADDRESS];
        EmailTemplate eomEmailTemplate = CFAOriginationHelperClass.getEmailTemplate(ConstantValues.EOM_EMAIL_TO_CFA_GROWER);
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        if(coreGrowerEmailMap.size() != coreGrowerCoopTypeMap.size()){
            throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
        }
        for(String appId : coreGrowerEmailMap.keySet()){
            String coopType = coreGrowerCoopTypeMap.get(appId);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.subject = eomEmailTemplate.Subject;
            String emailBody = eomEmailTemplate.HtmlValue;
            emailBody = emailBody.replace(ConstantValues.REPLACE_LOGO_URL,
                                        CFAOriginationHelperClass.getLogoURLbyCoopType(coopType));
            if(coopType == ConstantValues.GROWMARK_COOP_TYPE){
                emailBody = emailBody.replace(GROWER_LINK, GMK_GROWER_URL);
            }else if(coopType == ConstantValues.LANDUS_COOP_TYPE){
                emailBody = emailBody.replace(GROWER_LINK, LANDUS_GROWER_URL);
            }else{
                emailBody = emailBody.replace(GROWER_LINK, ConstantValues.GROWER_URL);
            }
            email.setHtmlBody(emailBody);
            email.setTemplateId(eomEmailTemplate.Id);
            email.setOrgWideEmailAddressId(senderAddress.Id);
            String growerEmail = coreGrowerEmailMap.get(appId);
            email.setToAddresses(new String[] {growerEmail});
           
            emailsToSend.add(email);
        }
        Messaging.sendEmail(emailsToSend);
    }
}