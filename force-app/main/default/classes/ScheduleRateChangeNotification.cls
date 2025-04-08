/**
 * @description       : This class checks if there is any rate change 45 AND 32 Days ahead, 
 *                      then it sends a notification to CL AND Grower respecively
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 12-29-2024
 * @last modified by  : Ayush Kumar Singh
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   09-09-2022   Subham Nandi   Initial Version
**/
public with sharing class ScheduleRateChangeNotification implements Schedulable {
    // CONSTANTS Specific to This Class -------------------------------------
    private static final String CLASS_NAME = ScheduleRateChangeNotification.class.getName();
    private static final Date DAY_FOURTY_FIVE = System.today().addDays(45); // 45 days ahead
    private static final Date DAY_FOURTY_FOUR = System.today().addDays(44); // 34 days ahead
    private static final Date DAY_THIRTY_TWO = System.today().addDays(32); // 32 days ahead
    private static final Date DAY_THIRTY_ONE = System.today().addDays(31); // 31 days ahead
    private static final String EFFECTIVE_DATE = '{!EffectiveDate}';
    private static final String CROP_YEAR = '{!CropYear}';
    private static final String LOAN_NUMBER = '{!Loan Number}';
    private static final String CURRENT_RATE = '{!Current Rate}';
    private static final String NEW_RATE = '{!New Rate}';
    private static final String RATE_DESCRIPTION = '{!Account Description}';
    private static final String DEALER_NAME = '{!Dealer}';
    private static final String LOGO_URL = '{!logoURL}';
    private static final String CFA_ORGANISATION = System.Label.CFA_Sender_Name;
    private static final String CFA_LOGO_URL = System.Label.CFA_Logo_Url;
    private static final String GMK_LOGO_URL = System.Label.GMK_Logo_Url;
    private static final String LANDUS_LOGO_URL = System.Label.Landus_Logo_Url;
    // CONSTANTS Specific to This Class -------------------------------------

   
    /**
    * @description : This methods send email notifications to cl's if any rate change happen on 45 days ahead 
     *              and growers if any rate change happen on 32 days ahead.
    * @author Suraj Kumar | 03-16-2024 
    * @param sc 
    **/
    public void execute(SchedulableContext sc){
        fourtyFiveDaysNotificationAsync();
        thirtyTwoDaysNotificationAsync();
    }
    
    /**
    * @description : This method check crud permissions
    * @author Suraj Kumar | 03-16-2024 
    **/
    private static void checkAccessOnObjects(){
        if((!Schema.sObjectType.genesis__Application_Pricing_Detail__c.isAccessible())
                | (!Schema.sObjectType.clcommon__Relationship__c.isAccessible())
                | (!Schema.sObjectType.OrgWideEmailAddress.isAccessible())){
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
        }
    }
    
    /**
    * @description : This method Checks for Any Rate change happen on the 45 days ahead of today.
    *                If any rate change happens then 
    *               it will send mail the cl's of the dealer of the application
    * @author Suraj Kumar | 03-16-2024 
    **/
    
    @future(callout=true)
    private static void fourtyFiveDaysNotificationAsync(){
        try{
            EmailTemplate emailTemplate = new EmailTemplate();
            Map<String, String> dealerCIFToCityMap = new Map<String, String>();               // dealer city, state 
            Map<String, String> dealerCIFToStateMap = new Map<String, String>();              // email with CIF key
            Map<String, String> dealerCIFToCoopTypeMap = new Map<String, String>();
            Map<String, Set<String>> dealerCIFToEmailMap = new Map<String, Set<String>>();              // This 3 maps store 
            Map<String, String> dealerCIFToIdMap = new Map<String, String>();              // This 3 maps store 
            Map<String,EmailTemplate> dealerCIFToTemplateMap = new Map<String, EmailTemplate>();
            List<clcommon__Relationship__c> clOfDealerList = new List<clcommon__Relationship__c>();
            List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
            // rateChangeList variable contains all the rate changes happen on the 45 days ahead.
            List<genesis__Application_Pricing_Detail__c> rateChangeList = new List<genesis__Application_Pricing_Detail__c>();

            // Validating CRUD operations on Objects.
            checkAccessOnObjects();

            // Taking the rates of the applcations on the 45 days ahead
            rateChangeList = [SELECT Id, 
                                    genesis__Rate_Card_Setup_Detail__r.Start_Date__c,
                                    genesis__Application__r.genesis__Maturity_Date__c,
                                    genesis__Application__r.Dealer_Name__r.Coop_Type__c,
                                    genesis__Application__r.Dealer_Name__c,
                                    genesis__Interest_Rate__c,
                                    genesis__Application__c,
                                    Loan_Number__c
                                FROM genesis__Application_Pricing_Detail__c 
                                WHERE genesis__Rate_Card_Setup_Detail__r.Start_Date__c = :DAY_FOURTY_FIVE];
                                                           
            //Get all the Certified Lender
            clOfDealerList = getAllCL(rateChangeList);

            EmailTemplate glEmailTemplate = CFAOriginationHelperClass.emailTemplateMappingMetadata(ConstantValues.KEY_GREY_LABEL, ConstantValues.FOURTY_FIVE_DAYS_RATE_CHANGE);

            EmailTemplate gmkEmailTemplate = CFAOriginationHelperClass.emailTemplateMappingMetadata(ConstantValues.GROWMARK_COOP_TYPE, ConstantValues.FOURTY_FIVE_DAYS_RATE_CHANGE);
      

            for(clcommon__Relationship__c eachCetifiedLender : clOfDealerList) {
                String dealerCIF;
                String dealerCity;
                String dealerState;
                String dealerCoopType;
                String dealerId;
                Map<String, String> dealerDetails = CFAOriginationHelperClass.getDealerDetails(eachCetifiedLender);
                String clEmail = eachCetifiedLender.clcommon__Related_Entity__r.clcommon__Email__c;

                dealerCity = dealerDetails.get(ConstantValues.KEY_DEALER_CITY);
                dealerState = dealerDetails.get(ConstantValues.KEY_DEALER_STATE);
                dealerCIF = dealerDetails.get(ConstantValues.KEY_DEALER_CIF);
                dealerCoopType = eachCetifiedLender.clcommon__Entity__r.Coop_Type__c;
                dealerId = dealerDetails.get(ConstantValues.KEY_DEALER_ID);

                dealerCIFToCityMap.put(dealerCIF, dealerCity);
                if(dealerCIFToEmailMap.containsKey(dealerCIF)){
                    dealerCIFToEmailMap.get(dealerCIF).add(clEmail);
                } else {
                    dealerCIFToEmailMap.put(dealerCIF, new Set<String>{clEmail});
                }

                dealerCIFToTemplateMap.put(dealerCIF,getEmailTemplate(dealerCoopType, glEmailTemplate, gmkEmailTemplate));
                dealerCIFToStateMap.put(dealerCIF, dealerState);
                dealerCIFToCoopTypeMap.put(dealerCIF, dealerCoopType);
                dealerCIFToIdMap.put(dealerCIF, dealerId);
            }

            Boolean hasSharedEmailOfLandus = false;

            dealerCIFToEmailMap = CFAOriginationHelperClass.getAdditionalRecipientEmailForMultipleTransaction(dealerCIFToCoopTypeMap, glEmailTemplate.Name, dealerCIFToEmailMap);      
            dealerCIFToEmailMap = CFAOriginationHelperClass.getAdditionalRecipientEmailForMultipleTransaction(dealerCIFToCoopTypeMap, gmkEmailTemplate.Name, dealerCIFToEmailMap);      

            for(String eachDealerCIF : dealerCIFToEmailMap.keySet()){
                //Fetch the Email Template
                emailTemplate = dealerCIFToTemplateMap.get(eachDealerCIF);
                for(String eachEmail : new List<String>(dealerCIFToEmailMap.get(eachDealerCIF))){
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    String emailBody = emailTemplate.HtmlValue;
                    String effectiveDate = DAY_FOURTY_FIVE.format();
                    String dealerCity = dealerCIFToCityMap.get(eachDealerCIF);
                    String dealerState = dealerCIFToStateMap.get(eachDealerCIF);
                    String dealerCoopType = dealerCIFToCoopTypeMap.get(eachDealerCIF);

                    emailBody = emailBody.replace(EFFECTIVE_DATE, effectiveDate);
                    emailBody = emailBody.replace(ConstantValues.REPLACE_DEALER_CITY, dealerCity);
                    emailBody = emailBody.replace(ConstantValues.REPLACE_DEALER_STATE, dealerState);
                    emailBody = emailBody.replace(ConstantValues.REPLACE_DEALER_CIF, eachDealerCIF);
                    emailBody = emailBody.replace(ConstantValues.REPLACE_LOGO_URL,EmailUtil.setLogoURL(dealerCIFToIdMap.get(eachDealerCIF)));
                    email.subject = emailTemplate.Subject;
                    email.setHtmlBody(emailBody);
                    email.setTemplateId(emailTemplate.Id);
                    
                    if(dealerCoopType == ConstantValues.LANDUS_COOP_TYPE & !hasSharedEmailOfLandus){
                        email.setToAddresses(new String[] {eachEmail, ConstantValues.LANDUS_SHARED_INBOX_EMAIL});
                        hasSharedEmailOfLandus = true;
                    }
                    else{
                        email.setToAddresses(new String[] {eachEmail});
                    }
                    sendEmailList.add(email);
                }
            }
            sendMailToDealer(sendEmailList);
        } catch(CustomException customExceptionObj){
            PortalHelper.saveExceptionLog(customExceptionObj, CLASS_NAME);
        } catch(Exception exceptionObj){
            PortalHelper.saveExceptionLog(exceptionObj, CLASS_NAME);
        }
    }
   
    /**
    * @description : This method fetch all cl's under the dealer who has a rate change application
    * @author Suraj Kumar | 03-16-2024 
    * @param rateChangeList 
    * @return List<clcommon__Relationship__c> 
    **/
    private static List<clcommon__Relationship__c> getAllCL(List<genesis__Application_Pricing_Detail__c> rateChangeList ) {
        Set<String> dealerIdSet = new Set<String>();
        List<String> dealerIdList = new List<String>();
        List<String> appIdList = new List<String>();
        Map<String,Decimal> pricingToRateMap = new Map<String,Decimal>();
        List<clcommon__Relationship__c> clOfDealerList = new List<clcommon__Relationship__c>();
        List<genesis__Application_Pricing_Detail__c> currentRateList = new List<genesis__Application_Pricing_Detail__c>();

        //Get all the current rates
        for(genesis__Application_Pricing_Detail__c eachPricing : rateChangeList){
            appIdList.add(eachPricing.genesis__Application__c);
        }
        if(appIdList.isEmpty()) {
            return clOfDealerList;
        }
        currentRateList = [SELECT Id,
                                    genesis__Interest_Rate__c,
                                    Loan_Number__c,
                                    genesis__Rate_Card_Setup_Detail__r.End_Date__c
                                FROM genesis__Application_Pricing_Detail__c
                                WHERE genesis__Application__c IN : appIdList AND 
                                genesis__Enabled_Flag__c = true AND 
                                genesis__Rate_Card_Setup_Detail__r.End_Date__c = :DAY_FOURTY_FOUR];
        for(genesis__Application_Pricing_Detail__c currentRate : currentRateList){
            pricingToRateMap.put(String.valueOf(currentRate.Loan_Number__c), currentRate.genesis__Interest_Rate__c);
        } 
        for(genesis__Application_Pricing_Detail__c eachPricing : rateChangeList){
            Decimal oldRate = 0;
            Decimal newRate = eachPricing.genesis__Interest_Rate__c;
            if(pricingToRateMap.get(eachPricing.Loan_Number__c) != null){
                oldRate = pricingToRateMap.get(eachPricing.Loan_Number__c);
            }
            if(newRate != oldRate){
                dealerIdSet.add(eachPricing.genesis__Application__r.Dealer_Name__c);
            }
        }

        for(String eachDealerId : dealerIdSet){
            dealerIdList.add(eachDealerId);
        }
        CFAOriginationHelperClass.checkEmptyList(dealerIdList, ConstantValues.DEALER_NOT_FOUND);

        clOfDealerList = [SELECT Id,
                                clcommon__Entity__c,
                                clcommon__Entity__r.BillingCity,
                                clcommon__Entity__r.BillingState,
                                clcommon__Entity__r.CIF_Number__c,
                                clcommon__Related_Entity__r.name,
                                clcommon__Related_Entity__r.clcommon__Email__c,
                                clcommon__Entity__r.Coop_Type__c
                            FROM clcommon__Relationship__c 
                            WHERE clcommon__Entity__c IN :dealerIdSet
                            AND (clcommon__Relationship__r.name=:ConstantValues.CL_PARTY_NAME
                            OR clcommon__Relationship__r.name=:ConstantValues.CLP_PARTY_NAME)
                            AND clcommon__Related_Entity__r.clcommon__Email__c != null];
        return clOfDealerList;
    }

   
    /**
    * @description : This method sends add the sender address and send the emails to cls
    * @author Suraj Kumar | 03-16-2024 
    * @param sendEmailList 
    **/
    private static void sendMailToDealer(List<Messaging.SingleEmailMessage> sendEmailList) {

        List<OrgWideEmailAddress> senderAddressList = CFAOriginationHelperClass.getOrgWideEmailAddress();
        for(Messaging.SingleEmailMessage eachEmail : sendEmailList) {
            eachEmail.setOrgWideEmailAddressId(senderAddressList[ConstantValues.ZERO_VALUE].Id);
        }
        Messaging.sendEmail(sendEmailList,false);
    }

   
    /**
    * @description : This method send emails to all the grower who have a rate change on 32 days ahead
    * @author Suraj Kumar | 03-16-2024 
    **/
    @future(callout=true)
    private static void thirtyTwoDaysNotificationAsync(){
        List<String> appIdList = new List<String>();
        Map<String,String> pricingToRateMap = new Map<String,String>();
        Map<String,String> pricingToRateTypeMap = new Map<String,String>();
        List<genesis__Application_Pricing_Detail__c> rateChangeList = new List<genesis__Application_Pricing_Detail__c>();
        List<genesis__Application_Pricing_Detail__c> currentRateList = new List<genesis__Application_Pricing_Detail__c>();

        try{
            //Check if any rate change is happening in the 32th day from today
            rateChangeList = [SELECT Id, 
                                        genesis__Rate_Card_Setup_Detail__r.Start_Date__c,
                                        genesis__Application__r.genesis__Account__r.clcommon__Email__c,
                                        genesis__Application__r.genesis__Account__r.Name,
                                        genesis__Application__r.genesis__Maturity_Date__c,
                                        genesis__Application__r.Dealer_Name__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c,
                                        genesis__Application__c,
                                        Loan_Number__c,
                                        Principal_Advanced__c,
                                        genesis__Interest_Rate__c,
                                        genesis__Application__r.Crop_Year__c,
                                        genesis__Application__r.Dealer_Name__r.Name,
                                        genesis__Application__r.Dealer_Name__r.Coop_Type__c,
                                        genesis__Rate_Card_Setup_Detail__r.Description__c,
                                        genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c
                                    FROM genesis__Application_Pricing_Detail__c 
                                    WHERE genesis__Rate_Card_Setup_Detail__r.Start_Date__c = :DAY_THIRTY_TWO AND
                                    genesis__Application__r.genesis__Account__r.clcommon__Email__c != null];

            //Send email to the Certified Lender
            for(genesis__Application_Pricing_Detail__c eachPricing : rateChangeList){
                appIdList.add(eachPricing.genesis__Application__c);
            }
            if (appIdList.isEmpty()) {
                return;
            }
            currentRateList = [SELECT Id,
                                        genesis__Interest_Rate__c,
                                        Loan_Number__c,
                                        genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c
                                    FROM genesis__Application_Pricing_Detail__c
                                    WHERE genesis__Application__c IN : appIdList AND 
                                    genesis__Enabled_Flag__c = true AND 
                                    genesis__Rate_Card_Setup_Detail__r.End_Date__c = :DAY_THIRTY_ONE];
            for(genesis__Application_Pricing_Detail__c currentRate : currentRateList){
                pricingToRateMap.put(String.valueOf(currentRate.Loan_Number__c), String.valueOf(currentRate.genesis__Interest_Rate__c));
                pricingToRateTypeMap.put(String.valueOf(currentRate.Loan_Number__c),
                                            String.valueOf(currentRate.genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c));                    
            }                 
            sendMailToGrower(pricingToRateMap, pricingToRateTypeMap, rateChangeList);  
        }catch(CustomException customExceptionObj){
            PortalHelper.saveExceptionLog(customExceptionObj, CLASS_NAME);
        }catch(Exception exceptionObj){
            PortalHelper.saveExceptionLog(exceptionObj, CLASS_NAME);
        }
    }
    /**
     * @description This method sends email to Grower.
     * @author Suraj Kumar | 03-16-2024 
     * @param pricingToRateMap 
     * @param pricingToRateTypeMap 
     * @param rateChangeList 
     */
    private static void sendMailToGrower(Map<String,String> pricingToRateMap, 
                                        Map<String,String> pricingToRateTypeMap,
                                        List<genesis__Application_Pricing_Detail__c> rateChangeList) {
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> senderAddressList = CFAOriginationHelperClass.getOrgWideEmailAddress();

        EmailTemplate glEmailTemplate = CFAOriginationHelperClass.emailTemplateMappingMetadata(ConstantValues.KEY_GREY_LABEL, ConstantValues.THIRTY_TWO_DAYS_RATE_CHANGE);

        EmailTemplate gmkEmailTemplate = CFAOriginationHelperClass.emailTemplateMappingMetadata(ConstantValues.GROWMARK_COOP_TYPE, ConstantValues.THIRTY_TWO_DAYS_RATE_CHANGE);
  

        for(genesis__Application_Pricing_Detail__c eachPricing : rateChangeList){
            String newRate;
            String emailBody;
            String loanNumber;
            String growerEmail;
            String balance = '';
            String oldRate = '';
            String effectiveDate = DAY_THIRTY_TWO.format();
            String cropYear = eachPricing.genesis__Application__r.Crop_Year__c;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String dealerName = eachPricing.genesis__Application__r.Dealer_Name__r.Name;
            String accountDescription = eachPricing.genesis__Rate_Card_Setup_Detail__r.Description__c;
            String dealerId = eachPricing.genesis__Application__r.Dealer_Name__c;
            String dealerCoopType = eachPricing.genesis__Application__r.Dealer_Name__r.Coop_Type__c;
            EmailTemplate emailTemplate = new EmailTemplate();
            if(eachPricing.genesis__Application__r.genesis__Account__r.clcommon__Email__c == null){
                continue;
            }
            if(String.isBlank(dealerId)){
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            }

            emailTemplate = getEmailTemplate(dealerCoopType, glEmailTemplate, gmkEmailTemplate);

            if(pricingToRateMap.get(eachPricing.Loan_Number__c) != null){
                oldRate = pricingToRateMap.get(eachPricing.Loan_Number__c) 
                            + ConstantValues.PERCENTAGE_STRING 
                            + ConstantValues.SPACE_STRING
                            + pricingToRateTypeMap.get(eachPricing.Loan_Number__c);  
            }
            newRate = String.valueOf(eachPricing.genesis__Interest_Rate__c);
            if(eachPricing.genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c != null){
                newRate = newRate 
                            + ConstantValues.PERCENTAGE_STRING 
                            + ConstantValues.SPACE_STRING 
                            + eachPricing.genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c;
            }
            loanNumber = eachPricing.Loan_Number__c;
            if(String.valueOf(eachPricing.Principal_Advanced__c) != null){
                balance = String.valueOf(eachPricing.Principal_Advanced__c);
            }
            //Email
            email.setOrgWideEmailAddressId(senderAddressList[ConstantValues.ZERO_VALUE].Id);
            growerEmail = eachPricing.genesis__Application__r.genesis__Account__r.clcommon__Email__c;   
            emailBody = emailTemplate.HtmlValue;
            emailBody = emailBody.replace(EFFECTIVE_DATE, effectiveDate);
            emailBody = emailBody.replace(CROP_YEAR,cropYear);
            emailBody = emailBody.replace(DEALER_NAME,dealerName);
            emailBody = emailBody.replace(LOAN_NUMBER,loanNumber);
            emailBody = emailBody.replace(CURRENT_RATE,oldRate);
            emailBody = emailBody.replace(NEW_RATE,newRate);
            emailBody = emailBody.replace(RATE_DESCRIPTION,accountDescription);
            emailBody = emailBody.replace(ConstantValues.REPLACE_LOGO_URL, EmailUtil.setLogoURL(dealerId));
            email.subject = emailTemplate.Subject;
            email.setHtmlBody(emailBody);
            email.setTemplateId(emailTemplate.Id);
            email.setToAddresses(new String[] {growerEmail});
            //Send the email only when there is a rate change
            if(oldRate != newRate){
                sendEmailList.add(email);
            }
        }
        Messaging.sendEmail(sendEmailList,false);
    }

    /**
     * @description Getting the email template
     * @param dealerCoopType 
     * @param glEmailTemplate 
     * @param gmkEmailTemplate 
     * @return  `EmailTemplate`
     */
    private static EmailTemplate getEmailTemplate(String dealerCoopType, EmailTemplate glEmailTemplate, EmailTemplate gmkEmailTemplate){
        if(dealerCoopType == ConstantValues.GROWMARK_COOP_TYPE){
            return gmkEmailTemplate;
        }
        else{
            return glEmailTemplate;
        }
    }
}