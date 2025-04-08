/**
 * @description       : Handler class of ReserveAmountTrigger
 * @author            : Simran
 * @group             : 
 * @last modified on  : 03-10-2025
 * @last modified by  : Sk Minsar
**/
public with sharing class ReserveAmountTriggerHandler {
    private static final String CLASS_NAME = ReserveAmountTriggerHandler.class.getName();
    private static Map<Id,Decimal> oldAppRecordMap= new Map<Id,Decimal>();
    private static final String LOAN_NUMBER = '{!genesis__Applications__c.genesis__Loan_Number__c}';
    private static final String GROWER_NAME = '{!GrowerName}';
    private static final String OLD_RESERVE_AMOUNT = '{!PriorReserveAmount}';
    private static final String NEW_RESERVE_AMOUNT = '{!ReserveAmount}';
    private static final String LOAN_OFFICER='{!LoanOfficer}';
    private static final String SYSTEM_TIME_DATE ='{!TimeDateStamp}';

    /**
    * @description : This method is used to check access of the objects
    * @author Simran | 04-16-2024 
    **/
    private static void checkAccessOnObjects(){
        if((!Schema.sObjectType.genesis__Applications__c.isAccessible())
                || (!Schema.sObjectType.User.isAccessible())
                || (!Schema.sObjectType.EmailTemplate.isAccessible())
                || (!Schema.sObjectType.clcommon__Notification__c.isCreateable())
                || (!Schema.sObjectType.Account.isAccessible())){
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
        }
    }

    /**
    * @description : This method is used to fetch app id of all the applications whose reserve amount has been changed.
    * @author Simran | 04-16-2024 
    * @param newAppList 
    * @param oldAppList 
    * @return List<Id> 
    **/
    private static List<Id> getRsvAmntChngAppRecord(List<genesis__Applications__c> newAppList,List<genesis__Applications__c> oldAppList){
        List<Id> appIdList = new List<Id>();
        for(genesis__Applications__c app:oldAppList){
            oldAppRecordMap.put(app.Id,app.Reserved_Amount__c);
        }
        for(genesis__Applications__c app:newAppList){
            if(oldAppRecordMap.get(app.Id) != app.Reserved_Amount__c){
                appIdList.add(app.Id);
            }
        }
        return appIdList;
    }

    /**
    * @description : This method is used to send the email to Loan Accounting team for all the change for reserve amount
    * @author Simran | 04-16-2024 
    * @param newAppList 
    * @param oldAppList 
    **/
    public static void sendReserveAmountEmail(List<genesis__Applications__c> newAppList,List<genesis__Applications__c> oldAppList){
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Messaging.SendEmailResult[] result;
        String emailSendStatus = ConstantValues.EMPTY_STRING;
        List<User> loggedInUserList = new List<User>();
        Map<Id, String> appToLogoURLMap = new Map<id, String>();
        try{
            List<Id> appRecordIdList=getRsvAmntChngAppRecord(newAppList,oldAppList);
            if(appRecordIdList.size()>0){
                checkAccessOnObjects();
                EmailTemplate emailTemplateList = EmailUtil.getEmailTemplate(ConstantValues.RESERVE_AMOUNT_EMAIL);
                String emailIdToSend = ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS;
                String emailBody;
                List<genesis__Applications__c> applicationList=[SELECT Id, 
                                                                    Name, 
                                                                    genesis__Loan_Number__c, 
                                                                    genesis__Account__r.Name, 
                                                                    Reserved_Amount__c, 
                                                                    LastModifiedBy.Name,
                                                                    Coop_Type__c ,
                                                                    Dealer_name__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c
                                                                    FROM genesis__Applications__c 
                                                                    WHERE Id IN :appRecordIdList];

                for(genesis__Applications__c app : applicationList){
                    if(app.Coop_Type__c == ConstantValues.GROWMARK_COOP_TYPE){
                        appToLogoURLMap.put(app.Id,System.Label.GMK_Logo_Url);
                    }else{
                        appToLogoURLMap.put(app.Id,ConstantValues.LOGO_BASE_URL + app.Dealer_Name__r.CFA_Partner_Program__r.Dealer_Portal_Logo__c);
                    }                
                }

                for(genesis__Applications__c app:applicationList){
                    String oldReserveAmount = getFormattedValue(oldAppRecordMap.get(app.Id));
                    String newReserveAmount = getFormattedValue(app.Reserved_Amount__c);
                    Messaging.SingleEmailMessage email = new  Messaging.SingleEmailMessage();
                    emailBody = emailTemplateList.HtmlValue; 
                    emailBody = emailBody.replace(LOAN_NUMBER, app.genesis__Loan_Number__c);
                    emailBody = emailBody.replace(GROWER_NAME, app.genesis__Account__r.Name);
                    emailBody = emailBody.replace(OLD_RESERVE_AMOUNT,ConstantValues.DOLLAR_STRING + oldReserveAmount);
                    emailBody = emailBody.replace(NEW_RESERVE_AMOUNT,ConstantValues.DOLLAR_STRING + newReserveAmount);
                    emailBody = emailBody.replace(LOAN_OFFICER, app.LastModifiedBy.Name);
                    emailBody = emailBody.replace(SYSTEM_TIME_DATE, System.Now().format());
                    emailBody = emailBody.replace(ConstantValues.REPLACE_LOGO_URL,appToLogoURLMap.get(app.Id));
                    email.subject = emailTemplateList.Subject;
                    email.setHtmlBody(emailBody);

                    email.setToAddresses(new String[] {emailIdToSend});
                    emailsToSend.add(email);
                }                        
                result = Messaging.sendEmail(emailsToSend);
                String errorMessage;
                emailSendStatus = result[0].isSuccess() ? ConstantValues.SUCCESS_STATUS : ConstantValues.FAILURE_STATUS;
                if(emailSendStatus == ConstantValues.FAILURE_STATUS){
                    errorMessage = result[0].getErrors().get(0).getMessage();
                }
                loggedInUserList = [SELECT Id,
                                            UserName,
                                            Email
                                        FROM User
                                        WHERE Id =: UserInfo.getUserId()];
                // method to save email Log
                clcommon__Notification__c notificationObj = EmailUtil.getEmailLog(new Map<String,Object>{ConstantValues.KEY_FROM_ADDRESS => loggedInUserList[ConstantValues.ZERO_VALUE].Email,
                                                                                                        ConstantValues.KEY_TO_ADDRESS => emailIdToSend,
                                                                                                        ConstantValues.KEY_EMAIL_TEMPLATE => ConstantValues.RESERVE_AMOUNT_EMAIL,
                                                                                                        ConstantValues.KEY_MESSAGE => emailBody,
                                                                                                        ConstantValues.KEY_CLASS_NAME => CLASS_NAME,
                                                                                                        ConstantValues.KEY_EMAIL_STATUS => emailSendStatus,
                                                                                                        ConstantValues.KEY_ERROR_MESSAGE => errorMessage
                    }
                );
                if(notificationObj != null){
                    Database.insert(notificationObj,true);
                }
            }
        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, ReserveAmountTriggerHandler.class.getName());
        }
    }
    /**
    * @description This method is used to get the rounded value
    * @author Simran | 04-18-2024 
    * @param value 
    * @return String 
    **/
    private static String getFormattedValue(Decimal value){
        String amount = (value.setScale(2) + 0.001 ).format();
        return amount.substring(0,amount.length()-1);
    }
}