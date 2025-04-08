/**
 * @description       : Purpose of this class is to either approve or decline the modification request and send email accordingly.
 * @author            : Simran
 * @group             : 
 * @last modified on  : 11-19-2024
 * @last modified by  : Krishanu Chinya
**/
global with sharing class ApplicationModificationRequestAPI {
    private static final String LOAN_NUMBER='{!LoanNumber}';
    private static final String GROWER_NAME='{!GrowerName}';
    private static final String CURRENT_LOAN_AMOUNT='{!CurrentLoanAmount}';
    private static final String UPDATED_LOAN_AMOUNT='{!UpdatedLoanAmount}';
    private static final String MODIFIED_MATURITY_DATE='{!ModifiedMaturityDate}';
    private static final String CURRENT_MATURITY_DATE='{!CurrentMaturityDate}';
    private static final String APPLICATION_LIST = 'appList';
    private static final String APPLICATION_NOTE_LIST= 'appNoteId';
    private static String  currentAmount='currentAmount';
    private static String updatedAmount='updatedAmount';
    private static String response;
    private static List<OrgWideEmailAddress> senderAddressList = new List<OrgWideEmailAddress>();

    /**
     * @description This method check crud permissions.
     */
    private static void checkAccessOnObjects(){
        if((!Schema.sObjectType.clcommon__Party__c.isAccessible())
                | (!Schema.sObjectType.genesis__Application_Note__c.isAccessible())
                | (!Schema.sObjectType.genesis__Applications__c.isAccessible())
                | (!Schema.sObjectType.genesis__Applications__c.isUpdateable())
                | (!Schema.sObjectType.genesis__Application_Note__c.isUpdateable())){
            throw new CustomException(ConstantValues.INSUFFICIENT_ACCESS_ON_OBJECTS);
        }
    }

    /**
    * @description - Purpose of this method is to either approve or decline the modification request based on parameter received from Skuid UI.
    * @author Simran | 08-03-2023 
    * @param appId
    * @param applicationNoteId
    * @param modificationStatus 
    * @return String 
    **/
    webservice static String modificationRequestWS(String appId,String applicationNoteId,String modificationStatus) {
        try{
            List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
            List<genesis__Application_Note__c> applicationNoteObjList = new List<genesis__Application_Note__c>();

            // Calling this method to check required parameters 
            CFAOriginationHelperClass.checkRequiredParameters(appId);
            CFAOriginationHelperClass.checkRequiredParameters(modificationStatus);

            // Validating all CRUD Permission on Object.
            checkAccessOnObjects();

            if(modificationStatus == ConstantValues.APPLICATION_NOTE_APPROVE_STATUS){
                // Calling callout method which will call integartion framework
                nlsUpdateModificationRequestCallout(applicationNoteId);
            }
            // Fetching email id of CL,CL+ and Grower of the application
            partyList = [SELECT  Id,
                                clcommon__Account__r.clcommon__Email__c
                            FROM clcommon__Party__c
                            WHERE clcommon__Type__r.Name IN (
                                :ConstantValues.CL_PARTY_NAME, 
                                :ConstantValues.CLP_PARTY_NAME)
                            AND genesis__Application__c =: appId];
            
            // Calling this method to check partyList and throw exception if partyList is empty

            //commenting out the following line for CFAS - 9560, so that there is no error even if there is no CL in the application
            //CFAOriginationHelperClass.checkEmptyList(partyList, ConstantValues.CL_OR_CLP_PARTY_NOT_FOUND);

            // Fetching updated loan amount, modified maturity date, coop type etc.
            applicationNoteObjList= [SELECT genesis__Application__c,
                                            Status__c,
                                            Completed_Date__c,
                                            genesis__Application__r.Dealer_Name__c,
                                            genesis__Application__r.Dealer_Name__r.Coop_Type__c,
                                            genesis__Application__r.Dealer_Name__r.CIF_Number__c,
                                            genesis__Application__r.genesis__Loan_Number__c,
                                            genesis__Application__r.genesis__Account__r.Name,
                                            genesis__Note__c,
                                            Format(Current_Loan_Amount__c) currentAmount, 
                                            Format(Updated_Loan_Amount__c) updatedAmount,
                                            Current_Maturity_Date__c,
                                            Modified_Maturity_Date__c, 
                                            Updated_Loan_Amount__c 
                                        FROM genesis__Application_Note__c
                                        WHERE id=:applicationNoteId
                                        AND genesis__Application__c=:appId
                                        order by createddate desc LIMIT 1];

            CFAOriginationHelperClass.checkEmptyList(applicationNoteObjList, ConstantValues.PARAMETER_MISSING);

            // Fetching the Sender Address List.
            senderAddressList = CFAOriginationHelperClass.getOrgWideEmailAddress(); 

            // Adapter allready updated the status the Application Note.
            if(applicationNoteObjList[ConstantValues.ZERO_VALUE].Status__c == ConstantValues.APPLICATION_NOTE_APPROVE_STATUS){
                // Calling this method to approve the modification request
                approvedModificationRequest(appId,applicationNoteObjList,partyList);
                response = ConstantValues.SUCCESS_MODIFICATION_MESSAGE;

            }else if(modificationStatus == ConstantValues.APPLICATION_NOTE_DECLINE_STATUS){
                // Calling this method to decline the modification request
                declineModificationRequest(applicationNoteObjList,partyList);
            }
            else{
                response = ConstantValues.FAILED_MODIFICATION_MESSAGE; 
            }
            updateCompletedDate(applicationNoteObjList);
        }
        catch (Exception objException) {
            LoggingUtility.saveExceptionLogging(objException, ApplicationModificationRequestAPI.class.getName());
        }
        return response;
    }

    /**
    * @description purpose of this method to update completed date when status quals to approved or declined
    * @author Ravi Ranjan | 02-06-2024 
    * @param applicationNoteObjList 
    **/
    private static void updateCompletedDate(List<genesis__Application_Note__c> applicationNoteObjList){
        if(applicationNoteObjList[ConstantValues.ZERO_VALUE].Status__c == ConstantValues.APPLICATION_NOTE_DECLINE_STATUS 
                    || applicationNoteObjList[ConstantValues.ZERO_VALUE].Status__c == ConstantValues.APPLICATION_NOTE_APPROVE_STATUS){
            // Updating completed date field
            applicationNoteObjList[ConstantValues.ZERO_VALUE].Completed_Date__c = System.now();
            Database.update(applicationNoteObjList, true);
        }
    }

    /**
    * @description - Purpose of this method is to approved modification request.
    * @author Suraj Kumar | 10-03-2023 
    * @param appId
    * @param applicationNoteObjList  
    * @param partyList
    **/
    private static void approvedModificationRequest(String appId , List<genesis__Application_Note__c> applicationNoteObjList, List<clcommon__Party__c> partyList){
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Loan_Amount__c, 
                                                                genesis__Maturity_Date__c 
                                                            FROM genesis__Applications__c 
                                                            WHERE Id =: appId
                                                            LIMIT 1];
        
        CFAOriginationHelperClass.checkEmptyList(applicationList, ConstantValues.PARAMETER_MISSING);

        if(applicationNoteObjList[ConstantValues.ZERO_VALUE].Updated_Loan_Amount__c != null){
            applicationList[ConstantValues.ZERO_VALUE].genesis__Loan_Amount__c = applicationNoteObjList[ConstantValues.ZERO_VALUE].Updated_Loan_Amount__c;
        }
        if(applicationNoteObjList[ConstantValues.ZERO_VALUE].Modified_Maturity_Date__c != null){
            applicationList[ConstantValues.ZERO_VALUE].genesis__Maturity_Date__c = applicationNoteObjList[ConstantValues.ZERO_VALUE].Modified_Maturity_Date__c;
        }
        Database.update(applicationList, true);

        //adding the following check for CFAS-9560, so that email is send iff there is CL attached to the application
        if(!partyList.isEmpty()){ 
            // If updated loan amount is equal to Application's Loan Amount then call method to send out Loan Approval Email
            if(applicationNoteObjList[ConstantValues.ZERO_VALUE].Updated_Loan_Amount__c == applicationList[ConstantValues.ZERO_VALUE].genesis__Loan_Amount__c){
                approveLoanAmountModification(applicationNoteObjList, partyList);
            }
            // If modified maturity date is equal to Application's Maturity Date then call method to send out Maturity Date Modification Email
            if(applicationNoteObjList[ConstantValues.ZERO_VALUE].Modified_Maturity_Date__c == applicationList[ConstantValues.ZERO_VALUE].genesis__Maturity_Date__c){
                approveMaturityDateModification(applicationNoteObjList, partyList);
            }
        }
    }

    /**
    * @description - Purpose of this method is to Decline modification request.
    * @author Suraj Kumar | 10-03-2023 
    * @param applicationNoteObjList  
    * @param partyList
    **/
    private static void declineModificationRequest(List<genesis__Application_Note__c> applicationNoteObjList, List<clcommon__Party__c> partyList){

        applicationNoteObjList[ConstantValues.ZERO_VALUE].Status__c = ConstantValues.APPLICATION_NOTE_DECLINE_STATUS;
        Database.update(applicationNoteObjList,true);

        //adding the following check for CFAS-9560, so that email is send iff there is CL attached to the application
        if(!partyList.isEmpty()){ 
            // If updated loan amount is not null and status changed to decline
            if(applicationNoteObjList[ConstantValues.ZERO_VALUE].get(updatedAmount) != '' 
                        && applicationNoteObjList[ConstantValues.ZERO_VALUE].Status__c == ConstantValues.APPLICATION_NOTE_DECLINE_STATUS){
                declineLoanAmountModification(applicationNoteObjList, partyList);
                response=ConstantValues.LOAN_DECLINATION_MESSAGE;
            }
            // If modified maturity date is not null and status changed to decline
            if(applicationNoteObjList[ConstantValues.ZERO_VALUE].Modified_Maturity_Date__c != null 
                        && applicationNoteObjList[ConstantValues.ZERO_VALUE].Status__c == ConstantValues.APPLICATION_NOTE_DECLINE_STATUS){
                declineMaturityDateModification(applicationNoteObjList, partyList);
                response = ConstantValues.MATURITY_DECLINATION_MESSAGE;
            }
        }
    }

    /**
    * @description - Purpose of this method is to send out email for Loan Amount Approval
    * @author Simran | 08-03-2023 
    * @param applicationNoteObjList
    * @param partyList
    **/
    private static void approveLoanAmountModification(List<genesis__Application_Note__c> applicationNoteObjList, List<clcommon__Party__c> partyList){
        // Calling helper class's method to fetch Email Template
        EmailTemplate emailTemplate = CFAOriginationHelperClass.emailTemplateMappingMetadata(EmailUtil.getLabelType(applicationNoteObjList[ConstantValues.ZERO_VALUE].genesis__Application__r.Dealer_Name__c),ConstantValues.APPROVE_LOAN_AMOUNT_MODIFICATION);
        List<Messaging.SingleEmailMessage> emailListToSend = new List<Messaging.SingleEmailMessage>();                                            
        Messaging.SingleEmailMessage email = new  Messaging.SingleEmailMessage();
        List<String> emailIdList = getEmailIdList(partyList, applicationNoteObjList, emailTemplate.Name);
        String emailBody = emailTemplate.HtmlValue; 
        emailBody = emailBody.replace(LOAN_NUMBER, applicationNoteObjList[ConstantValues.ZERO_VALUE].genesis__Application__r.genesis__Loan_Number__c);
        emailBody = emailBody.replace(GROWER_NAME, applicationNoteObjList[ConstantValues.ZERO_VALUE].genesis__Application__r.genesis__Account__r.Name);
        emailBody = emailBody.replace(CURRENT_LOAN_AMOUNT, String.valueOf(applicationNoteObjList[ConstantValues.ZERO_VALUE].get(currentAmount)));
        emailBody = emailBody.replace(UPDATED_LOAN_AMOUNT, String.valueOf(applicationNoteObjList[ConstantValues.ZERO_VALUE].get(updatedAmount)));
        emailBody = emailBody.replace(ConstantValues.REPLACE_LOGO_URL,EmailUtil.setLogoURL(applicationNoteObjList[ConstantValues.ZERO_VALUE].genesis__Application__r.Dealer_Name__c));
        email.subject = emailTemplate.Subject;
        email.setHtmlBody(emailBody);
        email.setTemplateId(emailTemplate.Id);
        email.setOrgWideEmailAddressId(senderAddressList[ConstantValues.ZERO_VALUE].Id);      
        email.setToAddresses(new List<String>(emailIdList));
        emailListToSend.add(email);
        Messaging.sendEmail(emailListToSend);
    }

    /**
    * @description - Purpose of this method is to send out email of Maturity Date Approval
    * @author Simran | 08-03-2023 
    * @param applicationNoteObjList
    * @param partyList
    **/
    private static void approveMaturityDateModification(List<genesis__Application_Note__c> applicationNoteObjList, List<clcommon__Party__c> partyList){
        // Calling helper class's method to fetch Email Template
        EmailTemplate emailTemplate = CFAOriginationHelperClass.emailTemplateMappingMetadata(EmailUtil.getLabelType(applicationNoteObjList[ConstantValues.ZERO_VALUE].genesis__Application__r.Dealer_Name__c),ConstantValues.APPROVE_MATURITY_DATE_MODIFICATION);

        List<Messaging.SingleEmailMessage> emailListToSend = new List<Messaging.SingleEmailMessage>();                                            
        Messaging.SingleEmailMessage email = new  Messaging.SingleEmailMessage();
        List<String> emailIdList = getEmailIdList(partyList,applicationNoteObjList,emailTemplate.Name);
       
        String emailBody = emailTemplate.HtmlValue; 
        emailBody = emailBody.replace(LOAN_NUMBER, applicationNoteObjList[ConstantValues.ZERO_VALUE].genesis__Application__r.genesis__Loan_Number__c);
        emailBody = emailBody.replace(GROWER_NAME, applicationNoteObjList[ConstantValues.ZERO_VALUE].genesis__Application__r.genesis__Account__r.Name);
        emailBody = emailBody.replace(CURRENT_MATURITY_DATE, applicationNoteObjList[ConstantValues.ZERO_VALUE].Current_Maturity_Date__c.format());
        emailBody = emailBody.replace(MODIFIED_MATURITY_DATE, applicationNoteObjList[ConstantValues.ZERO_VALUE].Modified_Maturity_Date__c.format());
        emailBody = emailBody.replace(ConstantValues.REPLACE_LOGO_URL,EmailUtil.setLogoURL(applicationNoteObjList[ConstantValues.ZERO_VALUE].genesis__Application__r.Dealer_Name__c));
        email.subject = emailTemplate.Subject;
        email.setHtmlBody(emailBody);
        email.setTemplateId(emailTemplate.Id);
        email.setOrgWideEmailAddressId(senderAddressList[ConstantValues.ZERO_VALUE].Id);  
        email.setToAddresses(new List<String>(emailIdList));
        emailListToSend.add(email);
        Messaging.sendEmail(emailListToSend);
    }
    
    /**
    * @description - Purpose of this method is to update the loan amount or maturity date to nls after approval of modification request
    * @author Simran | 08-03-2023 
    * @param applicationNote
    **/
    private static void nlsUpdateModificationRequestCallout(String applicationNote){
        try{
            if(applicationNote !=null){
                List<String> appNoteIds=new List<String>();
                appNoteIds.add(applicationNote);
                Map<String, Object> requestParamMap = new Map<String, Object>();
                Map<String, Object> queryIdMap = new Map<String, Object>();
                queryIdMap.put(APPLICATION_NOTE_LIST, appNoteIds);
                intframework.AbstractIntegrationService baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
                intframework.BaseIntegrationResponse responseObject;
                responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(
                                ConstantValues.NLS_INTEGRATION_FAMILY,
                                ConstantValues.INTEGRATION_API_TYPE_APPROVE_MODIFICATION,
                                queryIdMap, requestParamMap);

            }
            else{
                throw new CustomException(ConstantValues.SOMETHING_WENT_WRONG);
            }
        }
        catch(Exception objException){
            LoggingUtility.saveExceptionLogging(objException, ConstantValues.NLS_CALLOUT);
        }
    }

    /**
    * @description - Purpose of this method is to send out email for Loan Amount Decline
    * @author Simran | 08-03-2023 
    * @param applicationNoteObjList
    * @param partyList
    **/
    private static void declineLoanAmountModification(List<genesis__Application_Note__c> applicationNoteObjList, List<clcommon__Party__c> partyList){
        // Calling helper class's method to fetch Email Template
        EmailTemplate emailTemplate = CFAOriginationHelperClass.emailTemplateMappingMetadata(EmailUtil.getLabelType(applicationNoteObjList[ConstantValues.ZERO_VALUE].genesis__Application__r.Dealer_Name__c),ConstantValues.DECLINE_LOAN_AMOUNT_MODIFICATION);

        List<Messaging.SingleEmailMessage> emailListToSend = new List<Messaging.SingleEmailMessage>();                                            
        Messaging.SingleEmailMessage email = new  Messaging.SingleEmailMessage();
        List<String> emailIdList = getEmailIdList(partyList,applicationNoteObjList,emailTemplate.Name);
        
        String emailBody = emailTemplate.HtmlValue; 
        emailBody = emailBody.replace(LOAN_NUMBER, applicationNoteObjList[ConstantValues.ZERO_VALUE].genesis__Application__r.genesis__Loan_Number__c);
        emailBody = emailBody.replace(GROWER_NAME, applicationNoteObjList[ConstantValues.ZERO_VALUE].genesis__Application__r.genesis__Account__r.Name);
        emailBody = emailBody.replace(CURRENT_LOAN_AMOUNT, String.valueOf(applicationNoteObjList[ConstantValues.ZERO_VALUE].get(currentAmount)));
        emailBody = emailBody.replace(UPDATED_LOAN_AMOUNT, String.valueOf(applicationNoteObjList[ConstantValues.ZERO_VALUE].get(updatedAmount)));
        emailBody = emailBody.replace(ConstantValues.REPLACE_LOGO_URL,EmailUtil.setLogoURL(applicationNoteObjList[ConstantValues.ZERO_VALUE].genesis__Application__r.Dealer_Name__c));
        email.subject = emailTemplate.Subject;
        email.setHtmlBody(emailBody);
        email.setTemplateId(emailTemplate.Id);
        email.setOrgWideEmailAddressId(senderAddressList[ConstantValues.ZERO_VALUE].Id);  
        email.setToAddresses(new List<String>(emailIdList));
        emailListToSend.add(email);
        Messaging.sendEmail(emailListToSend);
    }
    
    /**
    * @description - Purpose of this method is to send out email for maturity Date decline
    * @author Simran | 08-03-2023 
    * @param applicationNoteObjList
    * @param partyList
    **/
    private static void declineMaturityDateModification(List<genesis__Application_Note__c> applicationNoteObjList, List<clcommon__Party__c> partyList){
        // Calling helper class's method to fetch Email Template
        EmailTemplate emailTemplate = CFAOriginationHelperClass.emailTemplateMappingMetadata(EmailUtil.getLabelType(applicationNoteObjList[ConstantValues.ZERO_VALUE].genesis__Application__r.Dealer_Name__c),ConstantValues.DECLINE_MATURITY_DATE_MODIFICATION);

        List<Messaging.SingleEmailMessage> emailListToSend = new List<Messaging.SingleEmailMessage>();                                            
        Messaging.SingleEmailMessage email = new  Messaging.SingleEmailMessage();
        List<String> emailIdList = getEmailIdList(partyList,applicationNoteObjList,emailTemplate.Name);
       
        String emailBody = emailTemplate.HtmlValue; 
        emailBody = emailBody.replace(LOAN_NUMBER, applicationNoteObjList[ConstantValues.ZERO_VALUE].genesis__Application__r.genesis__Loan_Number__c);
        emailBody = emailBody.replace(GROWER_NAME, applicationNoteObjList[ConstantValues.ZERO_VALUE].genesis__Application__r.genesis__Account__r.Name);
        emailBody = emailBody.replace(CURRENT_MATURITY_DATE, applicationNoteObjList[ConstantValues.ZERO_VALUE].Current_Maturity_Date__c.format());
        emailBody = emailBody.replace(MODIFIED_MATURITY_DATE, applicationNoteObjList[ConstantValues.ZERO_VALUE].Modified_Maturity_Date__c.format());
        emailBody = emailBody.replace(ConstantValues.REPLACE_LOGO_URL,EmailUtil.setLogoURL(applicationNoteObjList[ConstantValues.ZERO_VALUE].genesis__Application__r.Dealer_Name__c));
        email.subject = emailTemplate.Subject;
        email.setHtmlBody(emailBody);
        email.setTemplateId(emailTemplate.Id);
        email.setOrgWideEmailAddressId(senderAddressList[ConstantValues.ZERO_VALUE].Id);  
        email.setToAddresses(new List<String>(emailIdList));
        emailListToSend.add(email);
        Messaging.sendEmail(emailListToSend);
    }

    /**
    * @description 
    * @author Suraj | 10-11-2023 
    * @param partyList 
    * @param applicationNoteObjList 
    * @param emailTemplateName 
    * @return List<String> 
    **/
    private static List<String> getEmailIdList(List<clcommon__Party__c> partyList,
                                                    List<genesis__Application_Note__c> applicationNoteObjList,
                                                    String emailTemplateName){

        List<String> emailIdList = new List<String>();
        Map<String, String> dealerCIFToCoopMap = new Map<String, String>();
        String coopType = applicationNoteObjList[ConstantValues.ZERO_VALUE].genesis__Application__r.Dealer_Name__r.Coop_Type__c;

        for(clcommon__Party__c partyObj:partyList){
            emailIdList.add(partyObj.clcommon__Account__r.clcommon__Email__c);
        }
        // Add shared email for Landus coop type
        if(coopType == ConstantValues.LANDUS_COOP_TYPE){
            emailIdList.add((String)System.Label.Landus_Shared_Email);
        }

        dealerCIFToCoopMap.put(applicationNoteObjList[ConstantValues.ZERO_VALUE].genesis__Application__r.Dealer_Name__r.CIF_Number__c, coopType);

        emailIdList = CFAOriginationHelperClass.getAdditionalRecipientEmailForSingleTransaction(dealerCIFToCoopMap,
                                                                                                    emailTemplateName,
                                                                                                    emailIdList);
        return emailIdList;
    }


}