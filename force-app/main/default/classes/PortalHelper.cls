/**
 * @description       : Purpose of this class is to provide all the reusable portal methods
 * @author            : iAyush
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : Rakesh Saraf
**/
public without sharing class PortalHelper{

    private static final String CIF_SUFFIX ='001';
    private static final String NEW_APPLICANT ='newApplicant';


    /**
    * @description 
    * @author Soumik Pattanayak | 08-10-2024 
    * @return Map<String, Id> 
    **/
    public static Map<String, Id> getLegalEntityMap() {
        Map<String, Id> mapOfLegalEntity = new Map<String, Id>();

        List<clcommon__Legal_Entity__c> legalEntities = [SELECT Id, Name FROM clcommon__Legal_Entity__c];

        for (clcommon__Legal_Entity__c legalEntity : legalEntities) {
            mapOfLegalEntity.put(legalEntity.Name, legalEntity.Id);
        }

        return mapOfLegalEntity;
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 08-10-2024 
    * @return Map<String, Id> 
    **/
    public static Map<String, Id> getPartyTypeMap() {
        Map<String, Id> mapOfpartyType = new Map<String, Id>();

        List<clcommon__Party_Type__c> objPartyTypeList = [SELECT Id, 
                                                                 Name
                                                          FROM clcommon__Party_Type__c];

        for (clcommon__Party_Type__c objPartyType : objPartyTypeList) {
            mapOfpartyType.put(objPartyType.Name, objPartyType.id);
        }

        return mapOfpartyType;
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 08-10-2024 
    * @return List<User> 
    **/
    public static List<User> getLoggedInUser() {
        List<User> loggedInUser = [SELECT Id,
                                            AccountId,
                                            ContactId,
                                            Account.ParentId
                                    FROM User
                                    WHERE Id = :UserInfo.getUserId()];


        if (loggedInUser.size() == 0) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }

        return loggedInUser;
    }

    
    /**
    * @description - Purpose of this method is to iterate through the list of collaterals and save them in the DB
    * @author iAyush | 26-01-2022 
    * @param objCollateral 
    * @param applicationId 
    **/
    public static void saveApplicationCollateral(clcommon__Collateral__c objCollateral, String applicationId) {

        //Validate Collateral Details Here
        if(String.isBlank(objCollateral.Id)){
            objCollateral.genesis__Application__c = applicationId;
            //Database.Insert(objCollateral, true);
        }
        else{
            Boolean isValidCollateral = PortalSecurityUtil.validateCollteralByApplication(applicationId, objCollateral.Id);
            if (!isValidCollateral) {
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            } 
            //Database.Upsert(objCollateral, true);
        }
    }

    /**
    * @description - Purpose of this method is to parse the request and extract the collateral fields
    * @author iAyush | 26-01-2022 
    * @param mapOfCollateral
    * @return clcommon__collateral__c
    **/
    public static clcommon__collateral__c getCollateralDetails(Map<String, Object> mapOfCollateral){
        clcommon__collateral__c objCollateral = new clcommon__collateral__c();
        String id = (String) mapOfCollateral.get('Id');
        if(id == null || id == 'new_record_id'){
            objCollateral.Id = null;
        }
        else{
            objCollateral.Id = id;
        }
        objCollateral.Total_Acres__c = Double.valueOf(mapOfCollateral.get('Total_Acres__c'));
        objCollateral.Producer_Share_Percent__c = Double.valueOf(mapOfCollateral.get('Producer_Share_Percent__c'));
        objCollateral.Approved_Yield__c = Double.valueOf(mapOfCollateral.get('Approved_Yield__c'));
        objCollateral.Percent_Fed__c = Double.valueOf(mapOfCollateral.get('Percent_Fed__c'));
        objCollateral.clcommon__Collateral_Category__c = (String) mapOfCollateral.get('clcommon__Collateral_Category__c');
        objCollateral.Insurance_Plan__c = (String) mapOfCollateral.get('Insurance_Plan__c');
        objCollateral.Percent_Coverage_Level__c = (String) mapOfCollateral.get('Percent_Coverage_Level__c');
        objCollateral.clcommon__Collateral_Name__c = 'Commodity';
        return objCollateral;
    }


    /**
    * @description 
    * @author Arka Jyoti Deb | 02-15-2022 
    * @param response 
    * @param applicationId 
    * @param partyName 
    **/
    public static void saveAdditionalInfoDetails(Map<String, Object> response, String applicationId,String partyName){
        Contact objContact = new Contact();
        Account objAccount = new Account();
        List<String> nameList = new List<String>();
        clcommon__party__c objParty = new clcommon__party__c();
        objAccount = creatAccount(response, partyName);
        // Creating Record Type as BUYER
        if(partyName == PortalConstants.BUYER_PARTY_NAME){
            RecordType buyerRecordType =  [ SELECT  Id, 
                                                    SobjectType, 
                                                    Name 
                                            FROM RecordType 
                                            WHERE Name = :PortalConstants.BUYER_PARTY_NAME AND 
                                            SobjectType = 'Account'];
            objAccount.RecordTypeId = buyerRecordType.Id;
        }
        Database.Upsert(objAccount, false);
        objContact = creatContact(response, partyName);
        objContact.accountID = objAccount.Id;
        Database.Upsert(objContact, false);
        String id = (String) Response.get('id');
        if(id == null || id == 'new_record_id'){
            objParty.Id = null;
        }
        else{
            objParty.Id = id;
        }
        objParty.clcommon__Account__c = objAccount.Id;
        objParty.clcommon__Contact__c = objContact.Id;
        objParty.genesis__Application__c = applicationId;
        List<clcommon__Party_Type__c> partyType = [SELECT id
                                                    FROM clcommon__Party_Type__c
                                                    WHERE NAME =:partyName];
        objParty.clcommon__Type__c = partyType[0].id;
        objParty.clcommon__Party_Types__c = partyName;
        Database.Upsert(objParty, false);
    }


    /**
    * @description 
    * @author Arka Jyoti Deb | 02-15-2022 
    * @param response 
    * @param partyName 
    * @return Account 
    **/
    private static Account creatAccount(Map<String, Object> response , string partyName){
        Account objAccount = new Account();
        String id = (String) response.get('clcommon__Account__c');
        if(id == null || id == 'new_record_id'){
            objAccount.Id = null;
        }
        else{
            objAccount.Id = id;
        }
        if (partyName.equalsIgnoreCase(PortalConstants.SPOUSE_PARTY_NAME)){
            objAccount.Name = (String)response.get('clcommon__Contact__r.FirstName') + ' ' 
                                    + (String) response.get('clcommon__Contact__r.LastName');
            objAccount.clcommon__Email__c = (String) response.get('clcommon__Contact__r.Email');
        }else{
            objAccount.Name = (String) response.get('clcommon__Account__r.Name');
            objAccount.clcommon__Email__c = (String) response.get('clcommon__Account__r.clcommon__Email__c');
            objAccount.Phone = (String) response.get('clcommon__Account__r.Phone');
            objAccount.BillingStreet = (String) response.get('clcommon__Account__r.BillingStreet');
            objAccount.BillingCity = (String) response.get('clcommon__Account__r.BillingCity');
            objAccount.BillingState = (String) response.get('clcommon__Account__r.BillingState');
            objAccount.BillingPostalCode = (String) response.get('clcommon__Account__r.BillingPostalCode');
            objAccount.Billing_County__c = (String) response.get('clcommon__Account__r.Billing_County__c');
        }
        objAccount.OwnerId = PortalSecurityUtil.getSiteAdmin();
        return objAccount;
    }
    /**
    * @description 
    * @author Arka Jyoti Deb | 02-15-2022 
    * @param response 
    * @param partyName 
    * @return Contact 
    **/
    private static Contact creatContact(Map<String, Object> response , string partyName){
        Contact objContact = new Contact();
        List<String> nameList = new List<String>();
        String id = (String) response.get('clcommon__Contact__c');
        if(id == null || id == 'new_record_id'){
            objContact.Id = null;
        }
        else{
            objContact.Id = id;
        }
        if (partyName.equalsIgnoreCase(PortalConstants.SPOUSE_PARTY_NAME)){
            objContact.Firstname = (String)response.get('clcommon__Contact__r.FirstName');
            objContact.ints__Middle_Name__c = (String) response.get('clcommon__Contact__r.ints__Middle_Name__c');
            objContact.LastName = (String) response.get('clcommon__Contact__r.LastName');
            objContact.Email = (String) response.get('clcommon__Contact__r.Email');
            objContact.genesis__SSN__c = (String) response.get('clcommon__Contact__r.genesis__SSN__c');
        }else{
            nameList = String.valueOf((String) response.get('clcommon__Account__r.Name')).split(' ', 2);
            if(nameList.size() == 1 ){
                objContact.LastName = nameList[0];
            }else{
                objContact.FirstName = nameList[0];
                objContact.LastName = nameList[1];
            }
            objContact.Email = (String) response.get('clcommon__Account__r.clcommon__Email__c');
            objContact.Phone = (String) response.get('clcommon__Account__r.Phone');
            objContact.MailingStreet = (String) response.get('clcommon__Account__r.BillingStreet');
            objContact.MailingCity = (String) response.get('clcommon__Account__r.BillingCity');
            objContact.MailingState = (String) response.get('clcommon__Account__r.BillingState');
            objContact.MailingPostalCode = (String) response.get('clcommon__Account__r.BillingPostalCode');
            objContact.Mailing_County__c = (String) response.get('clcommon__Account__r.Billing_County__c');
        }
        return objContact;
    }

    
    /**
    * @description Returns a rate card record after parsing the portal request and fetching each field
    * @author Subham Nandi | 09-02-2022 
    * @param mapOfRateCards 
    * @param rateDetailDescription 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    public static genesis__Rate_Card_Setup_Detail__c getRateCardDetails(Map<String, Object> mapOfRateCards, String rateDetailDescription){
        genesis__Rate_Card_Setup_Detail__c objRateCard = new genesis__Rate_Card_Setup_Detail__c();
        String id = (String) mapOfRateCards.get('id');
        if(id == null || id == 'new_record_id'){
            objRateCard.Id = null;
        }
        else{
            objRateCard.Id = id;
        }
        objRateCard.Description__c = rateDetailDescription;
        objRateCard.Participation_Percentage_CFA__c = Double.valueOf(mapOfRateCards.get('Participation_Percentage_CFA__c'));
        objRateCard.Interest_Rate_Type__c = String.valueOf(mapOfRateCards.get('Interest_Rate_Type__c'));
        objRateCard.Participation_Percentage_Dealer__c = Double.valueOf(mapOfRateCards.get('Participation_Percentage_Dealer__c'));
        objRateCard.Participation_Percentage_Dealer_Subsidy__c = Double.valueOf(mapOfRateCards.get('Participation_Percentage_Dealer_Subsidy__c'));
        String startDateStr = (String)mapOfRateCards.get('Start_Date__c');
        Date startDate = Date.valueOf(startDateStr);
        objRateCard.Start_Date__c = startDate;
        String endDateStr = (String)mapOfRateCards.get('End_Date__c');
        Date endDate = Date.valueOf(endDateStr);
        objRateCard.End_Date__c = endDate;
        objRateCard.genesis__Interest_Rate__c = Double.valueOf(mapOfRateCards.get('genesis__Interest_Rate__c'));
        return objRateCard;
    }

    /**
    * @description Returns a map of collateral prices where key is the commodity name and 
                   value is the clcommon__Collateral_Category__c object
    * @author Rahul Gupta | 09-02-2022 
    * @param collateralPrices 
    * @return clcommon__Collateral_Category__c 
    **/
    public static Map<Object, clcommon__Collateral_Category__c> getMapOfCollateralPrices(List<clcommon__Collateral_Category__c> collateralPrices) {
        Map<Object, clcommon__Collateral_Category__c> mapOfCollateralPrices = new Map<Object, clcommon__Collateral_Category__c>();

        for (clcommon__Collateral_Category__c collateralPrice : collateralPrices) {
            mapOfCollateralPrices.put(collateralPrice.Id, collateralPrice);
        }
        return mapOfCollateralPrices;
    }
    /**
    * @description 
    * @author Arka Jyoti Deb | 04-26-2022 
    * @param emailTemplateNameList 
    * @return List<EmailTemplate> 
    **/
    public static List<EmailTemplate> getEmailTemplateList(String emailTemplateNameList){
        List<EmailTemplate> emailTemplateList = [SELECT Id,
                                                        Body,
                                                        Subject,
                                                        HtmlValue
                                                        FROM EmailTemplate
                                                        WHERE Name =: emailTemplateNameList];
        return emailTemplateList;
    }
    /**
    * @description Creates the HTML Body for the email that is sent as a My Program approval request
    * @author Subham Nandi | 27-04-2022 
    * @param accountName 
    * @param url 
    * @param myProgramName 
    * @return String 
    **/
    public static String getHtmlForMyProgramApproval(String accountName, String url, String myProgramName){
        String returnHtmlString = accountName + ' has requested your approval for the following My Program : <a href='+url+'>'
                                +myProgramName+'</a>' + 
                                '<br> Please click this link to approve or reject this my program.' +
                                '<br> Thank You.';
                                
        return returnHtmlString;
    }


    /**
    * @description - Purpose of this method is to create the loan number for a new application
    * @author iAyush | 22-04-2022 
    * @param applicationId 
    * @param shouldValidate 
    * @param mapOfpartyType 
    **/
    public static void updateLoanNumber(String applicationId, String shouldValidate, Map<String, Id> mapOfpartyType){
        genesis__Applications__c objApplication = [SELECT Id, 
                                                          genesis__Contact__c,
                                                          genesis__Account__c, 
                                                          genesis__Account__r.CIF_Number__c,
                                                          genesis__Loan_Number__c
                                                   FROM genesis__Applications__c
                                                   WHERE Id=: applicationId];
        //Query the Latest Loan for the Grower
        List<clcommon__party__c> objPartiesList = [SELECT Id,
                                                            genesis__Application__r.genesis__Loan_Number__c
                                                FROM clcommon__party__c
                                                WHERE clcommon__Account__c=: objApplication.genesis__Account__c
                                                AND clcommon__Type__c =: mapOfpartyType.get(PortalConstants.BORROWER_PARTY_NAME)
                                                ORDER BY genesis__Application__r.genesis__Loan_Number__c DESC];

        if(shouldValidate == NEW_APPLICANT){
            objApplication.genesis__Loan_Number__c = objApplication.genesis__Account__r.CIF_Number__c + CIF_SUFFIX;
            if(objPartiesList.size() > 1){
                objApplication.genesis__Loan_Number__c = String.valueOf((Decimal.valueOf(objPartiesList[1].genesis__Application__r.genesis__Loan_Number__c) + 1));
            }
        }
        else{
            if(objPartiesList.size() == 0 || objPartiesList.size() == 1){
                objApplication.genesis__Loan_Number__c = String.valueOf(Decimal.valueOf(objApplication.genesis__Account__r.CIF_Number__c)*1000 + 1);
            }
            else{
                //objApplication.genesis__Loan_Number__c = String.valueOf((Decimal.valueOf(objApplication.genesis__Account__r.CIF_Number__c)*1000)+ objPartiesList.size());
                objApplication.genesis__Loan_Number__c = String.valueOf((Decimal.valueOf(objPartiesList[1].genesis__Application__r.genesis__Loan_Number__c) + 1));
            }
        }
        Database.Update(objApplication, true);
    }

/**
    * @description Purpose of this method is to insert the exception logs handled in the Apex Classes
    * @author Subham Nandi | 06-05-2022 
    * @param objException 
    * @param exceptionNameString 
    **/
    public static void saveExceptionLog(Exception objException, String exceptionNameString){
        Database.Insert(new clcommon__Log__c(Name = exceptionNameString ,
                                            clcommon__Message__c = exceptionNameString 
                                            + objException.getStackTraceString()
                                            + objException.getMessage(),
                                            clcommon__Time__c = System.Now()), false);
        Logger.error(objException);
        Logger.flush(); 
    }

    /**
    * @description Purpose of this method is to return whether a particular date is a working day or not
    * @author Subham Nandi | 16-06-2022 
    * @param dateTimeOfProcessing 
    * @return boolean 
    **/
    public static boolean isTodayAWorkingDay(Datetime dateTimeOfProcessing){
        BusinessHours workingHours =  [ SELECT Id 
                                        FROM BusinessHours 
                                        WHERE isDefault = true];
        return BusinessHours.isWithin(workingHours.Id,dateTimeOfProcessing);
    }

    /**
    * @description Purpose of this method is to return the next business day
    * @author Subham Nandi | 16-06-2022 
    * @param dateTimeOfProcessing 
    * @return Date 
    **/
    public static date getNextWorkingDay(Datetime dateTimeOfProcessing){
        BusinessHours workingHours =  [ SELECT Id 
                                        FROM BusinessHours 
                                        WHERE isDefault = true];
        DateTime nextBusinessDateTime = BusinessHours.nextStartDate(workingHours.Id, dateTimeOfProcessing);
        Date nextBusinessDay = Date.newInstance(nextBusinessDateTime.year(), 
                                                nextBusinessDateTime.month(), 
                                                nextBusinessDateTime.day());
    return nextBusinessDay;
       // return BusinessHours.nextStartDate(workingHours.Id, dateTimeOfProcessing);
    }


    /**
    * @description 
    * @author iAyush | 29-06-2022 
    * @param Title 
    * @param ContentVersionId 
    * @param ContentDocId 
    * @param Id 
    * @param Name 
    **/
    public static void getDocumentCategoryName(String Title, Id ContentVersionId, Id ContentDocId, Id Id, String Name){
        List<clcommon__document_category__c> docCategory = [SELECT Id
                                                                FROM clcommon__document_category__c
                                                                WHERE genesis__Application__c =: Id
                                                                AND clcommon__Category_Name__c =: Name];

        List<ContentDocumentLink> docLink = [SELECT id
                                        FROM ContentDocumentLink
                                        WHERE ContentDocumentId = :ContentDocId];

        if(docCategory.size() >0){
            clcommon__Category_Attachment_Association__c docCategoryAttachment = new clcommon__Category_Attachment_Association__c();
            docCategoryAttachment.clcommon__Document_Category__c = docCategory[0].id;
            docCategoryAttachment.clcommon__Content_Document_Id__c = ContentDocId;
            docCategoryAttachment.clcommon__Content_Version_Id__c = ContentVersionId;
            if(docLink.size() > 0){
                docCategoryAttachment.clcommon__Attachment_Id__c = docLink[0].id;
            }
            docCategoryAttachment.Name = Title;
            Database.Insert(docCategoryAttachment, true);
        }
    }

    
    /**
    * @description : Purpose of this method is to send an email when grower delete their Pending Payment
    * @author Simran | 13-09-2022 
    * @param loanNumber 
    * @param Growername 
    * @param fundingamount 
    * @param maturityDate 
    **/
    public static void sendEmailOnDeletingPendingPayment(String loanNumber, String Growername,String fundingamount,String maturityDate){
        String LOAN_NUMBER = '{!LoanNumber}';
        String GROWER_NAME = '{!GrowerName}';
        String AMOUNT = '{!Amount}';
        String MATURITY_DATE = '{!MaturityDate}';
        String SYSTEM_TIME_DATE ='{!TimeDateStamp}';
        EmailTemplate emailTemplateList = [SELECT Id,
                                                Body,
                                                Subject,
                                                HtmlValue
                                                FROM EmailTemplate
                                                WHERE Name =:PortalConstants.PENDING_AMOUNT_DELETE];
        
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();                                          
        Messaging.SingleEmailMessage email = new  Messaging.SingleEmailMessage();
        String emailIdToSend = ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS;
        String emailBody = emailTemplateList.HtmlValue; 
        emailBody = emailBody.replace(LOAN_NUMBER, loanNumber);
        emailBody = emailBody.replace(GROWER_NAME, Growername);
        emailBody = emailBody.replace(AMOUNT, '$'+fundingamount);
        emailBody = emailBody.replace(SYSTEM_TIME_DATE, System.Now().format());
        emailBody = emailBody.replace(MATURITY_DATE, maturityDate);
        email.subject = emailTemplateList.Subject;
        email.setHtmlBody(emailBody);
        email.setTemplateId(emailTemplateList.Id);
        email.setToAddresses(new String[] {emailIdToSend});
        emailsToSend.add(email);
        Messaging.sendEmail(emailsToSend);
    }
    

    /**
    * @description : Purpose of this method is to send an email when dealer sends the grower an application to complete.
    * @author Simran | 14-09-2022 
    * @param dealerName 
    * @param appCreatedDate 
    * @param growerEmail 
    * @param dealerCity 
    * @param dealerState 
    * @param clName 
    **/
    public static void sendEmailToGrower(String dealerName,String appCreatedDate,String growerEmail, String dealerCity, String dealerState, String clName){
        String DEALER_NAME = '{!Dealer}';
        String APP_DATE = 'mm/dd/yyyy';
        String GROWER_LINK = '{!growerLink}';
        EmailTemplate emailTemplateList = [SELECT Id,
                                                Body,
                                                Subject,
                                                HtmlValue
                                                FROM EmailTemplate
                                                WHERE Name =:PortalConstants.GROWER_COMPLETE_APPLICATION];
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();                                          
        Messaging.SingleEmailMessage email = new  Messaging.SingleEmailMessage();
        String emailIdToSend = string.valueOf(growerEmail);
        String emailBody = emailTemplateList.HtmlValue; 
        emailBody = emailBody.replace(DEALER_NAME, dealerName);
        //emailBody = emailBody.replace(APP_DATE, appCreatedDate);
        emailBody = emailBody.replace(GROWER_LINK,ConstantValues.GROWER_URL);
        emailBody = emailBody.replace(PortalConstants.REPLACE_DEALER_CITY,dealerCity);
        emailBody = emailBody.replace(PortalConstants.REPLACE_DEALER_STATE,dealerState);
        emailBody = emailBody.replace(PortalConstants.REPLACE_DEALER_NAME,clName);
        email.subject = emailTemplateList.Subject.replace(DEALER_NAME, dealerName);
        email.setHtmlBody(emailBody);
        email.setTemplateId(emailTemplateList.Id);
        email.setToAddresses(new String[] {emailIdToSend});
        emailsToSend.add(email);
        Messaging.sendEmail(emailsToSend);

    }

}