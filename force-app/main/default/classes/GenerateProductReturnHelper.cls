/**
 * @description       : Helper class to update Product Return and send email to CL
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 12-23-2024
 * @last modified by  : Sk Minsar
**/
public with sharing class GenerateProductReturnHelper {
    //Constants specific to this class starts
    static Map<String, Set<String>> dealerCIFToEmailMap = new map<String, Set<String>>();
    static Map<String, String> dealerCIFToCoopTypeMap = new map<String, String>();
    static Map<String,Decimal> dealerToTotalAmountMap = new Map<String,Decimal>();

    //Constants specific to this class ends

    /**
     * @description This method check crud permissions.
     */
    private static void checkAccessOnObjects(){
        if((!Schema.sObjectType.genesis__Funding_Transaction__c.isAccessible())
                | (!Schema.sObjectType.clcommon__Funding_Transactions_Properties__c.isCreateable())
                | (!Schema.sObjectType.OrgWideEmailAddress.isAccessible())
                | (!Schema.sObjectType.clcommon__Funding_Transactions_Properties__c.isUpdateable())
                | (!Schema.sObjectType.genesis__Funding_Transaction__c.isUpdateable())){
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
        }
    }
    /**
    * @description update Funding Transaction and send email to CL
    * @author  Pritam Roy | 01-15-2024 
    **/
    public static void updateFundingTransaction(){
        String dealerCIF;
        String landusDealerCIF  = ConstantValues.EMPTY_STRING;
        String clEmailKey;
        Date nextWorkingDate;
        List<Messaging.SingleEmailMessage> emailsToSendList = new List<Messaging.SingleEmailMessage>();
        List<genesis__Funding_Transaction__c> fundingTxnList = new List<genesis__Funding_Transaction__c>();
        List<genesis__Funding_Transaction__c> updatedFundingTxnList = new List<genesis__Funding_Transaction__c>();
        clcommon__Funding_Transactions_Properties__c fundingTxnPropertiesObj = new clcommon__Funding_Transactions_Properties__c();
        Set<Id> invoiceIdSet = new Set<Id>();

        // validating CRUD operations on Objects.
        checkAccessOnObjects();

        fundingTxnList = [SELECT Id,
                                    Status__c,
                                    format(genesis__Amount__c),
                                    Pricing_Detail__r.genesis__Application__r.genesis__Maturity_Date__c,
                                    Pricing_Detail__r.genesis__Application__r.Dealer_Name__c,
                                    genesis__Application__r.Dealer_Name__r.Coop_Type__c,
                                    genesis__Application__r.Dealer_Name__r.CIF_Number__c,
                                    CreatedBy.Name,
                                    CreatedBy.Email,
                                    Invoice__c 
                                FROM genesis__Funding_Transaction__c
                                WHERE genesis__Cleared__c = :ConstantValues.FALSE_VALUE
                                AND Status__c != :ConstantValues.VOIDED_STATUS
                                AND Posted_to_NLS__c = :ConstantValues.FALSE_VALUE
                                AND genesis__Payment_Mode__r.Name =:ConstantValues.PRODUCT_RETURN
                                AND Pricing_Detail__c != null
                                AND Pricing_Detail__r.genesis__Application__c != null];

        // Get the Next Woking date on which the Product Return is going to get posted
        nextWorkingDate = PortalHelper.getNextWorkingDay(System.now().addDays(1));
        fundingTxnPropertiesObj.name = ConstantValues.PRODUCT_RETURN + ConstantValues.HYPHEN_STRING
                                             + System.now().addHours(Integer.valueOf(ConstantValues.GMT_TO_CDT_HOUR_DIFF));
        fundingTxnPropertiesObj.Status__c = ConstantValues.INITIATED_STATUS;
        fundingTxnPropertiesObj.Payment_Mode__c = ConstantValues.PRODUCT_RETURN;
        fundingTxnPropertiesObj.Batch_Total_Amount__c = ConstantValues.ZERO_VALUE;
        fundingTxnPropertiesObj.Recorded_Date__c = nextWorkingDate;
        Database.insert(fundingTxnPropertiesObj,ConstantValues.TRUE_VALUE);
        
        for(genesis__Funding_Transaction__c fundingTxnObj : fundingTxnList){

            //Get Landus Dealer CIF
            if(fundingTxnObj.genesis__Application__r.Dealer_Name__r.Coop_Type__c == ConstantValues.LANDUS_COOP_TYPE){

                landusDealerCIF = fundingTxnObj.genesis__Application__r.Dealer_Name__r.CIF_Number__c;
                // Adding the CIF number of dealer and emails in map.
                if(dealerCIFToEmailMap.containsKey(landusDealerCIF)){
                    dealerCIFToEmailMap.get(landusDealerCIF).add(ConstantValues.LANDUS_SHARED_INBOX_EMAIL);
                } else {
                    dealerCIFToEmailMap.put(landusDealerCIF, new Set<String>{ConstantValues.LANDUS_SHARED_INBOX_EMAIL});
                }
                dealerCIFToCoopTypeMap.put(landusDealerCIF, fundingTxnObj.genesis__Application__r.Dealer_Name__r.Coop_Type__c);
            } 
            fundingTxnObj.genesis__Cleared__c = ConstantValues.TRUE_VALUE;
            fundingTxnObj.Status__c = ConstantValues.STATUS_INITIATED;
            fundingTxnObj.Batch__c = fundingTxnPropertiesObj.Id;
            fundingTxnPropertiesObj.Batch_Total_Amount__c = fundingTxnPropertiesObj.Batch_Total_Amount__c 
                                                                    + fundingTxnObj.genesis__Amount__c;
            updatedFundingTxnList.add(fundingTxnObj);

            dealerCIF = fundingTxnObj.genesis__Application__r.Dealer_Name__r.CIF_Number__c;
            clEmailKey = fundingTxnObj.CreatedBy.Email; 
            if(dealerCIFToEmailMap.containsKey(dealerCIF)){
                dealerCIFToEmailMap.get(dealerCIF).add(clEmailKey);
            } else {
                dealerCIFToEmailMap.put(dealerCIF, new Set<String>{clEmailKey});
            }

            dealerCIFToCoopTypeMap.put(dealerCIF, fundingTxnObj.genesis__Application__r.Dealer_Name__r.Coop_Type__c);
            addTotalAmtToDealerMap(dealerToTotalAmountMap, dealerCIF, fundingTxnObj.genesis__Amount__c);
            invoiceIdSet = PaymentInvoiceHelper.addInvoiceIdSet(fundingTxnObj.Invoice__c, invoiceIdSet);
        }
        Database.update(fundingTxnPropertiesObj,ConstantValues.TRUE_VALUE);

        if(!updatedFundingTxnList.isEmpty()){
            Database.update(updatedFundingTxnList,ConstantValues.TRUE_VALUE);
            PaymentInvoiceHelper.updateInvoiceStatus(new List<Id>(invoiceIdSet), ConstantValues.STATUS_INITIATED);
        }
        emailsToSendList = createEmail(landusDealerCIF, fundingTxnList);
        sendEmail(emailsToSendList);
    }

    /**
    * @description 
    * @author Ayan Bhowmik | 02-09-2024 
    * @param landusDealerCIF 
    * @param fundingTxnList 
    * @return List<Messaging.SingleEmailMessage> 
    **/
    private static List<Messaging.SingleEmailMessage> createEmail(String landusDealerCIF, List<genesis__Funding_Transaction__c> fundingTxnList){

        List<OrgWideEmailAddress> senderAddressList = setSenderAddress();
        List<Messaging.SingleEmailMessage> emailsToSendList = new List<Messaging.SingleEmailMessage>();
        Map<String, String> dealerCIFToLogoURLMap = new Map<String, String>();
        EmailTemplate emailTemplate = CFAOriginationHelperClass.emailTemplateMappingMetadata(EmailUtil.getLabelType(fundingTxnList[ConstantValues.ZERO_VALUE].genesis__Application__r.Dealer_Name__c),
                                                                                                    ConstantValues.PRODUCT_RETURN_NOTICE);

        dealerCIFToEmailMap = CFAOriginationHelperClass.getAdditionalRecipientEmailForMultipleTransaction(dealerCIFToCoopTypeMap, emailTemplate.Name, dealerCIFToEmailMap);

        List<String> dealerCIFList = new List<String>();
        dealerCIFList.addAll(dealerCIFToEmailMap.keySet());
        dealerCIFToLogoURLMap = getLogoURLMap(dealerCIFList);


        for(String eachDealerCIF : dealerCIFToEmailMap.keySet()){
            for(String eachEmail : new List<String>(dealerCIFToEmailMap.get(eachDealerCIF))){
                String emailBody = emailTemplate.HtmlValue;
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String paymentAmountStr = String.valueOf(dealerToTotalAmountMap.get(eachDealerCIF));
                if(landusDealerCIF == eachDealerCIF){
                    paymentAmountStr = String.valueOf(dealerToTotalAmountMap.get(landusDealerCIF));
                }
                String totalBatchAmount = ConstantValues.DOLLAR_STRING + paymentAmountStr;
                email.setOrgWideEmailAddressId(senderAddressList[ConstantValues.ZERO_VALUE].Id);                                           
                email.setToAddresses(new String[] {eachEmail});
                email.subject = emailTemplate.Subject.replace(ConstantValues.REPLACE_CLEARING_DATE,System.today().format());
                emailBody = emailBody.replace(ConstantValues.REPLACE_BATCH_AMOUNT,totalBatchAmount);
                emailBody = emailBody.replace(ConstantValues.REPLACE_LOGO_URL, dealerCIFToLogoURLMap.get(eachDealerCIF));
                email.setHtmlBody(emailBody);
                emailsToSendList.add(email);              
            }
        }
        return emailsToSendList;
    }

    /**
    * @description : prepares a map of the dealer cif and their logo url
    * @author Kabir Pramanik | 07-28-2024 
    * @param dealerCIFList 
    * @return Map<String, String> 
    **/
    private static Map<String, String> getLogoURLMap (List<String> dealerCIFList ){
        Map<String, String> dealerCIFToLogoURLMap = new Map<String, String>();
        List<Account> logoURLList = [SELECT Id, 
                                        Name,
                                        CIF_Number__c,
                                        Coop_Type__c,
                                        CFA_Partner_Program__c,
                                        CFA_Partner_Program__r.Dealer_Portal_Logo__c
                                FROM Account
                                WHERE CIF_Number__c IN :dealerCIFList];
        for(Account acc : logoURLList){
            if(acc.Coop_Type__c == ConstantValues.GROWMARK_COOP_TYPE){
                dealerCIFToLogoURLMap.put(acc.CIF_Number__c,System.Label.GMK_Logo_Url);
            }else{
                dealerCIFToLogoURLMap.put(acc.CIF_Number__c,ConstantValues.LOGO_BASE_URL + acc.CFA_Partner_Program__r.Dealer_Portal_Logo__c);
            }
        }
        return dealerCIFToLogoURLMap;
    }

    /**
    * @description set Sender Address
    * @author  Pritam Roy | 01-15-2024 
    * @return List<OrgWideEmailAddress> 
    **/
    private static List<OrgWideEmailAddress> setSenderAddress(){
        List<OrgWideEmailAddress> senderAddressList = [SELECT Id,
                                                                Address, 
                                                                DisplayName 
                                                            FROM  OrgWideEmailAddress 
                                                            WHERE DisplayName = :ConstantValues.CFA_ORGANISATION];
        if(senderAddressList.isEmpty()) {
            throw new CustomException(ConstantValues.ORGWIDE_ADDRESS_NOT_FOUND);
        }
        return senderAddressList;
    }
    /**
     * @description This method send the emails.
     * @param emailsToSendList 
     */
    private static void sendEmail(List<Messaging.SingleEmailMessage> emailsToSendList){
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSendList);
        if (!results[ConstantValues.ZERO_VALUE].isSuccess()) {
            throw new CustomException(ConstantValues.EMAIL_SEND_FAILED);
        } 
    }
    /**
     * @description This method will add all the funding transaction amount a dealer and put in the map.
     * @param dealerToTotalAmountMap 
     * @param dealerId 
     * @param amount 
     */
    private static void addTotalAmtToDealerMap(Map<String,Decimal> dealerToTotalAmountMap, String dealerId, Decimal amount){
        if(dealerToTotalAmountMap.containsKey(dealerId)){
            Decimal amountSum = dealerToTotalAmountMap.get(dealerId);
            amountSum = amountSum + amount;
            dealerToTotalAmountMap.put(dealerId, amountSum);
        }else{ 
            dealerToTotalAmountMap.put(dealerId, amount);
        }
    }
}