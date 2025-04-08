/**
 * @description       : utility class related to email
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 01-09-2025
 * @last modified by  : Rakesh Saraf
**/
public inherited sharing class EmailUtil {
    private static final String CFA_CONTCT_INFORMATION = System.Label.CFA_Contact_Information;
    private static final String GMK_CONTACT_INFORMATION = System.Label.GMK_Contact_Information;
    private static final String CFA_PRIMARY_COLOR = System.Label.CFA_Primary_Color;
    private static final String LANDUS_PRIMARY_COLOR = System.Label.Landus_Primary_Color;
    private static final String GROWMARK_PRIMARY_COLOR = System.Label.Growmark_Primary_Color;
    private static final String CFA_PRODUCTION_AG_EMAIL = System.label.Production_AG_Email;
    private static final String GMK_PRODUCTION_AG_EMAIL = System.label.GMK_Production_AG_Email;

    /**
    * @description : fetches the email template by name
    * @author Krishanu Chinya | 04-08-2024 
    * @param emailTemplateLabelName 
    * @return EmailTemplate 
    **/
    public static EmailTemplate getEmailTemplate(String emailTemplateLabelName){
        List<EmailTemplate> emailTemplateList = [SELECT Id,
                                            Name,
                                            Body,
                                            Subject,
                                            HtmlValue
                                        FROM EmailTemplate
                                        WHERE Name =:emailTemplateLabelName];
        if(emailTemplateList.isEmpty()){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        return emailTemplateList[0];
    }

    /**
    * @description  fetches the organization wide email address
    * @author Krishanu Chinya | 04-08-2024 
    * @param displayName 
    * @return List<OrgWideEmailAddress> 
    **/
    public static List<OrgWideEmailAddress> getOrgWideEmailAddress(String displayName){
        return [SELECT Id,
                    Address,
                    DisplayName
                FROM OrgWideEmailAddress
                WHERE DisplayName = :displayName];
    }
    
    /**
    * @description : fetches the logo by coop type
    * @author Krishanu Chinya | 04-08-2024 
    * @param coopType 
    * @return String 
    **/
    public static String getLogoURLbyCoopType(String coopType){
        if(coopType == ConstantValues.GROWMARK_COOP_TYPE){
            return System.Label.GMK_Logo_Url;
        }else if(coopType == ConstantValues.LANDUS_COOP_TYPE){
            return System.Label.Landus_Logo_Url;
        }else{
            return System.Label.CFA_Logo_Url;
        }
    }
    /**
    * @description : fetches the contact information according to coop type
    * @author Krishanu Chinya | 04-08-2024 
    * @param coop 
    * @return String 
    **/
    public static String getContactInfoByCoop (String coop){
        if(coop == PortalConstants.GROWMARK_COOP_TYPE){
            return GMK_CONTACT_INFORMATION;
        }
        else{
            return CFA_CONTCT_INFORMATION;
        }
    }

    /**
    * @description : returns the color code as per coop type
    * @author Krishanu Chinya | 04-08-2024 
    * @param coop 
    * @return String 
    **/
    public static String getColorByCoop (String coop){
        if(coop == PortalConstants.GROWMARK_COOP_TYPE){
            return GROWMARK_PRIMARY_COLOR;
        }
        else if(coop == PortalConstants.LANDUS_COOP_TYPE){
            return LANDUS_PRIMARY_COLOR;
        }
        else{
            return CFA_PRIMARY_COLOR;
        }
    }

    /**
    * @description : This method is used to store the log of Email in clcommon__Notification__c object
    * @author Suraj Kumar | 04-30-2024 
    * @param paramMap 
    * @return clcommon__Notification__c 
    **/
    public static clcommon__Notification__c getEmailLog(Map<String,Object> paramMap){
        clcommon__Notification__c notificationObj;
        // validate null check
        if(!paramMap.containsKey(ConstantValues.KEY_FROM_ADDRESS) 
                || !paramMap.containsKey(ConstantValues.KEY_TO_ADDRESS) 
                || !paramMap.containsKey(ConstantValues.KEY_EMAIL_TEMPLATE) 
                || !paramMap.containsKey(ConstantValues.KEY_MESSAGE) 
                || !paramMap.containsKey(ConstantValues.KEY_CLASS_NAME) 
                || !paramMap.containsKey(ConstantValues.KEY_EMAIL_STATUS)){
            return notificationObj;
        }
        notificationObj = new clcommon__Notification__c();
        if(paramMap.containsKey(ConstantValues.KEY_ERROR_MESSAGE)){
            notificationObj.Error_Message__c = (String)paramMap.get(ConstantValues.KEY_ERROR_MESSAGE);
        }
        notificationObj.clcommon__Email_Address__c = (String)paramMap.get(ConstantValues.KEY_FROM_ADDRESS);
        notificationObj.Recipient_Address__c = (String)paramMap.get(ConstantValues.KEY_TO_ADDRESS);
        notificationObj.Email_Template__c = (String)paramMap.get(ConstantValues.KEY_EMAIL_TEMPLATE);
        notificationObj.Email_Body__c = (String)paramMap.get(ConstantValues.KEY_MESSAGE);
        notificationObj.Class_Name__c = (String)paramMap.get(ConstantValues.KEY_CLASS_NAME);
        notificationObj.Email_Status__c = (String)paramMap.get(ConstantValues.KEY_EMAIL_STATUS);
        return notificationObj;
    }

    /**
    * @description : method to save email log which is not sent
    * @author Suraj Kumar | 05-06-2024 
    * @param emailTemplateName 
    * @param message 
    * @return clcommon__Log__c
    **/
    public static clcommon__Log__c getUnsentEmailLog(String emailTemplateName, String message){
        clcommon__Log__c logObj = new clcommon__Log__c(Name = emailTemplateName,
                                            clcommon__Message__c = message,
                                            clcommon__Time__c = System.Now());
        return logObj;
            
    }

    /**
    * @description : sets the logo based on coop type and partner program
    * @author Kabir Pramanik | 07-24-2024 
    * @param dealerId 
    * @return String 
    **/
    public static String setLogoURL(Id dealerId){

        List<Account> dealerAccList = [SELECT Id,
                                                Name,
                                                Coop_Type__c,
                                                CFA_Partner_Program__c,
                                                CFA_Partner_Program__r.Dealer_Portal_Logo__c
                                        FROM Account 
                                        WHERE Id = :dealerId];
        String logoURL = ConstantValues.EMPTY_STRING;
        if(dealerAccList[0].Coop_Type__c == ConstantValues.GROWMARK_COOP_TYPE){
            logoURL = getLogoURLbyCoopType(dealerAccList[0].Coop_Type__c);
        } else {
            if(dealerAccList[0].CFA_Partner_Program__c == null){
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            } else if(String.isBlank(dealerAccList[0].CFA_Partner_Program__r.Dealer_Portal_Logo__c)){
                return logoURL;
            } else {
                logoURL = ConstantValues.LOGO_BASE_URL + dealerAccList[0].CFA_Partner_Program__r.Dealer_Portal_Logo__c;
            }         
        } 
        return logoURL;
                                        
    }
    /**
    * @description : This method takes the Email Template Id and returns the name of that Email Template
    * @author Tuhin Bhunia | 05-29-2024 
    * @param templateId 
    * @return String 
    **/
    public static String getTemplateNameFromId(String templateId) {
        // Query on EmailTemplate object
        EmailTemplate template = [SELECT Name
                                  FROM EmailTemplate
                                  WHERE Id = :templateId
                                ];
        if (template != null) {
          return template.Name;
        } else {
          return null;
        }
    }

    /**
    * @description : sets the contact info for email template
    * @author Krishanu Chinya | 07-24-2024 
    * @param dealerId 
    * @return String 
    **/
    public static String setContactInfo(Id dealerId){
        List<Account> dealerAccList = [SELECT Id,
                                                Name,
                                                Coop_Type__c,
                                                CFA_Partner_Program__c,
                                                CFA_Partner_Program__r.Dealer_Portal_Logo__c,
                                                CFA_Partner_Program__r.Mobile__c
                                                FROM Account WHERE Id = :dealerId];
        PortalApplicationOriginationHelper.checkEmptyList(dealerAccList, ConstantValues.SOMETHING_WENT_WRONG);      
                                         
        String contactInfo = ConstantValues.EMPTY_STRING;
        if(dealerAccList[0].Coop_Type__c == ConstantValues.GROWMARK_COOP_TYPE){
            contactInfo = GMK_CONTACT_INFORMATION;
        } else {
            if(dealerAccList[0].CFA_Partner_Program__c == null){
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            } else if(String.isBlank(dealerAccList[0].CFA_Partner_Program__r.Mobile__c)){
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            } else {
                contactInfo = dealerAccList[0].CFA_Partner_Program__r.Mobile__c;
            }         
        } 
        return contactInfo;                                
    }

    /**
    * @description : 
    * @author Krishanu Chinya | 07-26-2024 
    * @param dealerId 
    * @return String 
    **/
    public static String getLabelType(String dealerId){
        List<Account> dealerAccList = [SELECT Id,
                                                Name,
                                                Coop_Type__c,
                                                CFA_Partner_Program__c
                                                FROM Account WHERE Id = :dealerId];
        PortalApplicationOriginationHelper.checkEmptyList(dealerAccList, ConstantValues.SOMETHING_WENT_WRONG);  

        if(dealerAccList[0].Coop_Type__c == ConstantValues.GROWMARK_COOP_TYPE
                & dealerAccList[0].CFA_Partner_Program__c == null){
            return ConstantValues.GROWMARK_COOP_TYPE;
        }else{
            return ConstantValues.KEY_GREY_LABEL;
        }
    }

    /**
    * @description Purpose of this method is to create email and set the addresses according to coop type
    * @author Rakesh Saraf | 01-09-2025 
    * @param coopType 
    * @return Messaging.SingleEmailMessage 
    **/
    public static Messaging.SingleEmailMessage createEmail(String coopType){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if (coopType == PortalConstants.GROWMARK_COOP_TYPE) {
            email.setToAddresses(new String[] {GMK_PRODUCTION_AG_EMAIL});
        }else{
            email.setToAddresses(new String[] {CFA_PRODUCTION_AG_EMAIL});
        }
        return email;
    }
}