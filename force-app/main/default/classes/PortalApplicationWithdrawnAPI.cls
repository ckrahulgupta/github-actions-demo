/**********************************************************************************************************************
 * @description       : This API helps in sending application withdrawn emails and change the application 
 *                      status to 'withdrawn'
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 02-15-2025
 * @last modified by  : Ayan Bhowmik
**********************************************************************************************************************/

global without sharing class PortalApplicationWithdrawnAPI implements clcommon.PortalCustomRemoteAPI1 {

    // Parameters Specific to this class.
    private static final String CFA_PRODUCTION_AG_EMAIL = System.label.Production_AG_Email;
    private static final String GMK_PRODUCTION_AG_EMAIL = System.label.GMK_Production_AG_Email;
    private static final String APPLICATION_WITHDRAWN_API = PortalApplicationWithdrawnAPI.class.getName();
    private static final String REPLACE_APPLICATION_APP = 'APP-';
    private static final String REPLACE_COMMA_WITH_SPACE = ', ';
    private static List<String> toAddresses = new List<String>();

   /**
    * @description - Purpose of this method is to check arguments from portal.
    * @param argumentsFromPortal 
    */
    private static void argumentsValidation(Map<String, Object> argumentsFromPortal) {
        Boolean isValidUser;
        String applicationId;
        // Check required params.
        PortalApplicationOriginationHelper.checkIfNullObject(argumentsFromPortal.get(PortalConstants.APPLICATION_ID),PortalConstants.REQUIRED_PARAMETERS_MISSING);
        
        applicationId = (String)argumentsFromPortal.get(PortalConstants.APPLICATION_ID);
        isValidUser = PortalSecurityUtil.validateUserApplication(applicationId); 
        PortalApplicationOriginationHelper.throwErrorIfFalse(isValidUser, PortalConstants.USER_NOT_AUTHORISED);
        
    }

    /**
    * @description - Purpose of this method is to withdrawn an application which is not yet booked and 
    *                send an email to the cfa team.
    * @author Arka Jyoti Deb | 04-26-2022 
    * @param componentStructureName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStructureName,
                                                String[] disclosureNames, 
                                                Map<String, Object> argumentsFromPortal) {
        String applicationId;
        List<genesis__Applications__c> applicationList = new List<genesis__Applications__c>();
        clcommon.Response response = new clcommon.Response();
        Messaging.SingleEmailMessage email;
        Map<String,String> growerDetails = new Map<String,String>();
        EmailTemplate emailTemplate = new EmailTemplate();
        SavePoint dbSavePoint = Database.setSavepoint();

        try {
            argumentsValidation(argumentsFromPortal);
            applicationId = (String)argumentsFromPortal.get(PortalConstants.APPLICATION_ID);
            // This query fetch the application status, certified lenders details,
            // sales agent details, dealer applicant relatioship record associated with the application.
            applicationList=[SELECT Id,
                                    Name, 
                                    genesis__Status__c,
                                    genesis__Account__r.Name,
                                    Certified_Lender__c,
                                    Certified_Lender__r.Name,
                                    Certified_Lender__r.clcommon__Email__c,
                                    Sales_Agent__c,
                                    Sales_Agent__r.Name,
                                    Sales_Agent__r.clcommon__Email__c,
                                    genesis__Maturity_Date__c,
                                    Dealer_Name__r.Name,
                                    Dealer_Name__r.Coop_Type__c,
                                    Dealer_Name__r.CIF_Number__c,
                                    Dealer_Name__r.BillingCity,
                                    Dealer_Name__r.BillingState,
                                    genesis__Loan_Number__c,
                                    genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                    genesis__Contact__r.Name,
                                    Dealer_Applicant_Relationship__r.Applicant__c,
                                    Dealer_Applicant_Relationship__r.Applicant_Contact__c	,
                                    (SELECT ID,
                                            City__c,
                                            State__c 
                                        FROM genesis__Parties__r
                                        WHERE clcommon__Type__r.Name=:PortalConstants.BORROWER_PARTY_NAME)
                             FROM genesis__Applications__c
                             WHERE Id=:applicationId
                             AND genesis__Contact__c != null
                             AND genesis__Account__c != null
                             LIMIT 1];
            PortalApplicationOriginationHelper.checkEmptyList(applicationList, PortalConstants.SOMETHING_WENT_WRONG);

            if((applicationList[0].genesis__Status__c == PortalConstants.BOOK_TO_CORE_APPLICATION_STATUS)
                    | (applicationList[0].genesis__Status__c == PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS)
                    | (applicationList[0].genesis__Status__c == PortalConstants.REJECTED_APPLICATION_STATUS)
                    | (applicationList[0].genesis__Status__c == PortalConstants.ACTIVE_APPLICATION_STATUS)){
                throw new CustomException(PortalConstants.INVALID_WITHDRAWN_REQUEST);
            }
            // Getting grower details.
            growerDetails = PortalApplicationOriginationHelper.getDealerSpecificGrowerDetails(applicationList[0]);
            if(growerDetails.isEmpty()){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            // Fetching Email Template
            emailTemplate = getEmailTemplate(applicationList[0].Dealer_Name__c);
            // Creating Email.
            email = createEmail(growerDetails, applicationList[0], emailTemplate);
            if(email == null) {
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            // Sending Email.
            sendMail(applicationList[0], email);
            response.status = clcommon.Constants.SUCCESS;
            
        }catch (CustomException customExceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customExceptionObj.getMessage();
            PortalHelper.saveExceptionLog(customExceptionObj, APPLICATION_WITHDRAWN_API);
        }catch (Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(exceptionObj, APPLICATION_WITHDRAWN_API);
        }
        return response;
    }

   /**
    * @description - Purpose of this method is to create the email that will be send to cfa team and dealers.
    * @param growerDetails 
    * @param applicationObj 
    * @param emailTemplate 
    * @return  `Messaging.SingleEmailMessage`
    */
    private static Messaging.SingleEmailMessage createEmail(Map<String,String> growerDetails,
                                                                genesis__Applications__c applicationObj,
                                                                EmailTemplate emailTemplate) {
        String plainBody;                                                    
        String loanNumber;
        String growerName;
        String growerCity;
        String growerState;
        String certifiedLenderName;
        String loggedInUserAccountType;
        Messaging.SingleEmailMessage email;
        List<OrgWideEmailAddress> senderAddressList = new List<OrgWideEmailAddress>();
        toAddresses = setAddressOfProductionAG(applicationObj.Dealer_Name__r.Coop_Type__c);

        loanNumber = applicationObj.Name;
        certifiedLenderName = applicationObj.Certified_Lender__r.Name;
        growerName = growerDetails.get(PortalConstants.GROWER_NAME);
        growerCity = growerDetails.get(PortalConstants.KEY_GROWER_CITY);
        growerState = growerDetails.get(PortalConstants.KEY_GROWER_STATE);
        loggedInUserAccountType = PortalApplicationOriginationHelper.getLoggedInUser()[0].Account.RecordType.Name;
        email = new Messaging.SingleEmailMessage();

        //If Grower is Withdrawing an Application Send an Email to Certified Lender 
        // & Sales Agent & Production Ag -- 'Withdrawal (from Grower to CL and SA and productionAg)'
        if ((loggedInUserAccountType.equalsIgnoreCase(PortalConstants.GROWER_PROFILE) 
                | loggedInUserAccountType.equalsIgnoreCase(PortalConstants.CO_APPLICATION_RECORD_TYPE))) {
            // Get the Certified Lender Addresses
            if(applicationObj.Certified_Lender__c!=null && applicationObj.Certified_Lender__r.clcommon__Email__c != null
                    // & applicationObj.Certified_Lender__r.Application_Withdrawn_Notice__c     // This commented line for cs-79
                    ){  
                toAddresses.add(applicationObj.Certified_Lender__r.clcommon__Email__c);
            }
            // Get the Sales Agent Addresses
            if(applicationObj.Sales_Agent__c != null 
                    // && applicationObj.Sales_Agent__r.Application_Withdrawn_Notice__c // This commented line for cs-79
                    && applicationObj.Sales_Agent__r.clcommon__Email__c != null){
                toAddresses.add(applicationObj.Sales_Agent__r.clcommon__Email__c);
            }
            //Set Landus Address
            if(applicationObj.Dealer_Name__r.Coop_Type__c == PortalConstants.LANDUS_COOP_TYPE){
                toAddresses.add(System.Label.Landus_Shared_Email);
            }
            Map<String, String> dealerCIFToCoopMap = new Map<String, String>();
            dealerCIFToCoopMap.put(applicationObj.Dealer_Name__r.CIF_Number__c, applicationObj.Dealer_Name__r.Coop_Type__c);

            CFAOriginationHelperClass.getAdditionalRecipientEmailForSingleTransaction(dealerCIFToCoopMap,
                                                                                        emailTemplate.Name,
                                                                                        toAddresses);

        }

        email.setToAddresses(toAddresses);
        senderAddressList = PortalApplicationOriginationHelper.getOrgWideEmailAddress(ConstantValues.ORG_WIDE_NO_REPLY_EMAIL_ADDRESS);
        email.setOrgWideEmailAddressId(senderAddressList[0].Id);
        String emailSubject = emailTemplate.Subject;
        emailSubject = emailSubject.replace(PortalConstants.REPLACE_GROWER_NAME, growerName);      
        emailSubject = (growerCity != PortalConstants.EMPTY_STRING) ? 
                            emailSubject.replace(PortalConstants.REPLACE_GROWER_CITY , growerCity) :
                            emailSubject.replace((REPLACE_COMMA_WITH_SPACE + PortalConstants.REPLACE_GROWER_CITY) , PortalConstants.EMPTY_STRING);
        emailSubject = (growerState != PortalConstants.EMPTY_STRING) ? 
                            emailSubject.replace(PortalConstants.REPLACE_GROWER_STATE , growerState) :
                            emailSubject.replace((REPLACE_COMMA_WITH_SPACE + PortalConstants.REPLACE_GROWER_STATE) , PortalConstants.EMPTY_STRING);
        
        email.subject = emailSubject;
        email.setTemplateId(emailTemplate.Id);
        plainBody = emailTemplate.HtmlValue;
        plainBody = plainBody.replace(PortalConstants.REPLACE_LOGO_URL,EmailUtil.setLogoURL(applicationObj.Dealer_Name__c));
        plainBody = plainBody.replace(PortalConstants.REPLACE_GROWER_NAME, growerName);
        plainBody = plainBody.replace(PortalConstants.REPLACE_LOAN_NUMBER , loanNumber.replace(REPLACE_APPLICATION_APP,PortalConstants.EMPTY_STRING));
        email.setHtmlBody(plainBody);
        
        return email;
    }

   /**
    * @description - Purpose of this method is to fetch the email template.
    * @param dealerId 
    * @return  `EmailTemplate`
    */
    private static EmailTemplate getEmailTemplate(String dealerId) {
        String loggedInUserAccountType = PortalApplicationOriginationHelper.getLoggedInUser()[0].Account.RecordType.Name;
        EmailTemplate emailTemplate = new EmailTemplate();

        emailTemplate = ((loggedInUserAccountType.equalsIgnoreCase(PortalConstants.GROWER_PROFILE)
                                | loggedInUserAccountType.equalsIgnoreCase(PortalConstants.CO_APPLICATION_RECORD_TYPE))) 
                            ? CFAOriginationHelperClass.emailTemplateMappingMetadata(EmailUtil.getLabelType(dealerId),
                                                                                        PortalConstants.APP_WITHDRAW_BY_GROWER_NOTIFIC)
                            : CFAOriginationHelperClass.emailTemplateMappingMetadata(EmailUtil.getLabelType(dealerId),
                                                                                        PortalConstants.APP_WITHDRAW_BY_DEALER_NOTIFIC);
        if(emailTemplate == null){
            throw new CustomException(PortalConstants.EMAIL_TEMPLATE_ERROR);
        }
        return emailTemplate;
    }

   /**
    * @description - Purpose of this method is to send the email to cfa team and dealers.
    * @param applicationObj 
    * @param email 
    */
    private static void sendMail(genesis__Applications__c applicationObj,
                                            Messaging.SingleEmailMessage email) {
        String plainBody;
        String dealerCity = PortalConstants.EMPTY_STRING;
        String dealerState = PortalConstants.EMPTY_STRING;
        Messaging.SendEmailResult[] results;

        String certifiedLenderName = PortalConstants.EMPTY_STRING;

        if(applicationObj.Certified_Lender__c!=null){
            certifiedLenderName = applicationObj.Certified_Lender__r.Name;
        }


        String loggedInUserAccountType = PortalApplicationOriginationHelper.getLoggedInUser()[0].Account.RecordType.Name;

        if (!(loggedInUserAccountType.equalsIgnoreCase(PortalConstants.GROWER_PROFILE)
                | loggedInUserAccountType.equalsIgnoreCase(PortalConstants.CO_APPLICATION_RECORD_TYPE))) {
            plainBody = email.getHtmlBody();
            plainBody = plainBody.replace(PortalConstants.REPLACE_CERTIFIED_LENDER_NAME, certifiedLenderName);
            plainBody = plainBody.replace(PortalConstants.REPLACE_DEALER_NAME, applicationObj.Dealer_Name__r.Name);
            if(applicationObj.Dealer_Name__r.BillingCity != null 
                    & applicationObj.Dealer_Name__r.BillingState != null){
                dealerCity = REPLACE_COMMA_WITH_SPACE + applicationObj.Dealer_Name__r.BillingCity;
                dealerState = REPLACE_COMMA_WITH_SPACE + applicationObj.Dealer_Name__r.BillingState;
            }
            plainBody = plainBody.replace(PortalConstants.REPLACE_DEALER_CITY, dealerCity);
            plainBody = plainBody.replace(PortalConstants.REPLACE_DEALER_STATE, dealerState);
            email.setHtmlBody(plainBody);
        }

        if(applicationObj.Certified_Lender__c!=null){
            results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}, false);

            // Storing the email log in Notification object if the logged in user is not grower or Co applicant
            // storeEmailLog
            if (!(loggedInUserAccountType.equalsIgnoreCase(PortalConstants.GROWER_PROFILE)
                | loggedInUserAccountType.equalsIgnoreCase(PortalConstants.CO_APPLICATION_RECORD_TYPE))) {
    
                storeEmailLog(results, plainBody, email);
    
            }
            // ---------------------------
            if (!results[PortalConstants.ZERO_VALUE].isSuccess()) {
                throw new CustomException(ConstantValues.EMAIL_SEND_FAILED);
            }
        }

        

         
        applicationObj.genesis__Status__c = ((loggedInUserAccountType.equalsIgnoreCase(PortalConstants.GROWER_PROFILE)
                                                    | loggedInUserAccountType.equalsIgnoreCase(PortalConstants.CO_APPLICATION_RECORD_TYPE))) ? 
                                                PortalConstants.WITHDRAWN_APPLICATION_STATUS :
                                                PortalConstants.PENDING_WITHDRAWAL_APPLICATION_STATUS;

        //Calling a method to update Lien Options field as per Jira number CS-61  
        // if(applicationObj.genesis__Status__c == PortalConstants.WITHDRAWN_APPLICATION_STATUS){           // This commented line is for CS-61
        //     PortalHelper.updateLienOptions(applicationObj);
        // }

        Database.Update(applicationObj, true);
    }
   /**
    * @description - Purpose of this method is to set the address of production ag depends upon dealer coop type
    * @param coopType 
    * @return  `List<String>`
    */
    private static List<String> setAddressOfProductionAG(String coopType){
        List<String> toAddresses = new List<String>();
        if(coopType == PortalConstants.GROWMARK_COOP_TYPE){
            toAddresses.add(GMK_PRODUCTION_AG_EMAIL);
        }else {
            toAddresses.add(CFA_PRODUCTION_AG_EMAIL);
        }
        return toAddresses;
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 06-04-2024 
    * @param emailResults 
    * @param plainBody 
    * @param email 
    **/
    private static void storeEmailLog(Messaging.SendEmailResult[] emailResults, String plainBody, Messaging.SingleEmailMessage email){

        String emailStatus = emailResults[0].isSuccess() ? ConstantValues.SUCCESS_STATUS : ConstantValues.FAILURE_STATUS;
        String errorMessage;
        if(emailStatus == ConstantValues.FAILURE_STATUS){
            for(Messaging.SendEmailError error : emailResults[0].getErrors()){
                errorMessage = error.getStatusCode() + PortalConstants.SIGN_BY+PortalConstants.SPACE_STRING + error.getMessage() + PortalConstants.SIGN_BY+PortalConstants.SPACE_STRING + error.getFields();
            }
        }
        clcommon__Notification__c notificationObj = EmailUtil.getEmailLog(
            new Map<String,Object>{
                ConstantValues.KEY_FROM_ADDRESS => PortalApplicationOriginationHelper.getLoggedInUser()[0].Email,
                ConstantValues.KEY_TO_ADDRESS => toAddresses[0],
                ConstantValues.KEY_EMAIL_TEMPLATE => EmailUtil.getTemplateNameFromId(email.TemplateId),
                ConstantValues.KEY_MESSAGE => plainBody,
                ConstantValues.KEY_CLASS_NAME => APPLICATION_WITHDRAWN_API,
                ConstantValues.KEY_EMAIL_STATUS => emailStatus,
                ConstantValues.KEY_ERROR_MESSAGE => errorMessage
            }
        );
        Database.Insert(notificationObj, true);
    }
}