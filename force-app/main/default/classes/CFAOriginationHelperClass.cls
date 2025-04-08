/**
 * @description       : Helper class to provide all the reusable methods
 * @author            : Simran
 * @group             : 
 * @last modified on  : 02-28-2025
 * @last modified by  : Shristy Kumari
**/
public inherited sharing class CFAOriginationHelperClass {
 
    private static final String CFA_ORGANISATION = System.Label.CFA_Sender_Name;

    /**
     * @description This method is used for quering Email Template Mapping Metadata
     * @param coopType 
     * @param emailTemplateName 
     * @return  `EmailTemplate`
     */
    public static EmailTemplate emailTemplateMappingMetadata(String coopType, String emailTemplateName) {
        Email_Template_Mapping__mdt emailTemplateMdt;
        EmailTemplate emailTemplate = new EmailTemplate();
        try{
            emailTemplateMdt = [SELECT Id, 
                                        DeveloperName, 
                                        Label, 
                                        Dealer_Group__c, 
                                        Email_Template_Name__c 
                                    FROM Email_Template_Mapping__mdt 
                                    WHERE Dealer_Group__c=:coopType 
                                    AND Email_Template_Name__c =: emailTemplateName];
            if(emailTemplateMdt == null || emailTemplateMdt.Label == null){
                throw new CustomException(ConstantValues.PARAMETER_MISSING);
            }
            emailTemplate = getEmailTemplate(emailTemplateMdt.Label);  
        }
        catch(Exception objException){
            PortalHelper.saveExceptionLog(objException, CFAOriginationHelperClass.class.getName());
        }
        return emailTemplate;
    }

    //
    /**
     * @description This method is used to return email template:-
     * @param emailTemplateLabelName 
     * @return  `EmailTemplate`
     */
    public static EmailTemplate getEmailTemplate(String emailTemplateLabelName){
        EmailTemplate emailTemplate = [SELECT Id,
                                            Name,
                                            Body,
                                            Subject,
                                            HtmlValue
                                        FROM EmailTemplate
                                        WHERE Name =:emailTemplateLabelName];
        if(emailTemplate == null){
            throw new CustomException(ConstantValues.PARAMETER_MISSING);
        }
        return emailTemplate;
    }
    /**
     * @description This method returns logo url based on coop type.
     * @param coopType 
     * @return  `String`
     */
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
    * @description Purpose of this method is to send an email when grower delete their Pending Payment
    * @author Ayan Bhowmik | 06-10-2024 
    * @param idToFundingTxnMap 
    * @param idToFundingAmountMap 
    * @param idToMaturityDateMap 
    **/
    public static void sendEmailOnDeletingPendingPayment(Map<Id, genesis__Funding_Transaction__c> idToFundingTxnMap, Map<Id, String> idToFundingAmountMap, Map<Id, String> idToMaturityDateMap){
        String replaceGrowerName = '{!GrowerName}';
        String replaceAmount = '{!Amount}';
        String systemTimeDate ='{!TimeDateStamp}';
        EmailTemplate emailTemplateList = EmailUtil.getEmailTemplate(PortalConstants.PENDING_AMOUNT_DELETE);
        String emailIdToSend = ConstantValues.LOAN_ACCOUNTING_EMAIL_ADDRESS;
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>(); 
        Messaging.SendEmailResult[] result;
        String emailSendStatus = ConstantValues.EMPTY_STRING;
        List<User> loggedInUserList = new List<User>();
        String emailBody = PortalConstants.EMPTY_STRING;
        Map<String, Object> notificationMap = new Map<String, Object>();
        List<clcommon__Notification__c> notificationList = new List<clcommon__Notification__c>();
        List<id> dealerIdList = new List<Id>();
        Map<Id, String> dealerAccToLogoMap = new Map<Id, String>();
        List<OrgWideEmailAddress> senderAddressList = PortalApplicationOriginationHelper.getOrgWideEmailAddress(ConstantValues.ORG_WIDE_NO_REPLY_EMAIL_ADDRESS);

        for(Id eachFundingTransactionId : idToFundingTxnMap.keySet()){
            genesis__Funding_Transaction__c eachFundingTransaction = idToFundingTxnMap.get(eachFundingTransactionId);
            dealerIdList.add(eachFundingTransaction.genesis__Application__r.Dealer_Name__c);
        }

        List<Account> dealerAccList = [SELECT Id, 
                                                Name,
                                                Coop_Type__c,
                                                CFA_Partner_Program__c,
                                                CFA_Partner_Program__r.Dealer_Portal_Logo__c
                                        FROM Account
                                        WHERE Id IN :dealerIdList];

        for(Account acc : dealerAccList){
            if(acc.Coop_Type__c == ConstantValues.GROWMARK_COOP_TYPE){
                dealerAccToLogoMap.put(acc.Id,System.Label.GMK_Logo_Url);
            }else{
                dealerAccToLogoMap.put(acc.Id,ConstantValues.LOGO_BASE_URL + acc.CFA_Partner_Program__r.Dealer_Portal_Logo__c);
            }  
        }   

        for(Id eachFundingTransactionId : idToFundingTxnMap.keySet()){
            genesis__Funding_Transaction__c eachFundingTransaction = idToFundingTxnMap.get(eachFundingTransactionId);
            String loanNumber = eachFundingTransaction.Pricing_Detail__r.Loan_Number__c;
            String growerName = eachFundingTransaction.Grower_Name__c;
            String dealerId = eachFundingTransaction.genesis__Application__r.Dealer_Name__c;
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();                                          
            String fundingamount = idToFundingAmountMap.get(eachFundingTransactionId);
            String maturityDate = idToMaturityDateMap.get(eachFundingTransactionId);
                emailBody = emailTemplateList.HtmlValue; 
            emailBody = emailBody.replace(PortalConstants.REPLACE_LOAN_NUMBER, loanNumber);
            emailBody = emailBody.replace(replaceGrowerName, growerName);
            emailBody = emailBody.replace(replaceAmount, ConstantValues.DOLLAR_STRING + fundingamount);
            emailBody = emailBody.replace(systemTimeDate, System.Now().format());
            emailBody = emailBody.replace(PortalConstants.REPLACE_MATURITY_DATE, maturityDate);
            emailBody = emailBody.replace(PortalConstants.REPLACE_LOGO_URL, dealerAccToLogoMap.get(dealerId));
            email.subject = emailTemplateList.Subject;
            email.setHtmlBody(emailBody);
            email.setTemplateId(emailTemplateList.Id);
            email.setOrgWideEmailAddressId(senderAddressList[0].Id);  
            email.setToAddresses(new String[] {emailIdToSend});
            emailsToSend.add(email);
            }
            result = Messaging.sendEmail(emailsToSend);
            loggedInUserList = [SELECT Id,
                                        UserName,
                                        Email
                                    FROM User
                                WHERE Id =: UserInfo.getUserId()];

            for(Messaging.SendEmailResult eachResult : result){
                emailSendStatus = eachResult.isSuccess() ? ConstantValues.SUCCESS_STATUS : ConstantValues.FAILURE_STATUS;
                notificationMap.put(ConstantValues.KEY_FROM_ADDRESS, loggedInUserList[ConstantValues.ZERO_VALUE].Email);
                notificationMap.put(ConstantValues.KEY_TO_ADDRESS, emailIdToSend);
                notificationMap.put(ConstantValues.KEY_EMAIL_TEMPLATE, ConstantValues.RESERVE_AMOUNT_EMAIL);
                notificationMap.put(ConstantValues.KEY_MESSAGE, emailBody);
                notificationMap.put(ConstantValues.KEY_CLASS_NAME, PortalPayoffAPI.class.getName());
                notificationMap.put(ConstantValues.KEY_EMAIL_STATUS, emailSendStatus);
                if(emailSendStatus == ConstantValues.FAILURE_STATUS){
                    notificationMap.put(ConstantValues.KEY_ERROR_MESSAGE, eachResult.getErrors().get(0).getMessage());
                }
                // method to save email Log
                notificationList.add(EmailUtil.getEmailLog(notificationMap));
            }
            if(!notificationList.isEmpty()){
                Database.insert(notificationList,true);
            }
    }
    /**
     * @description This method fetch the orgwide email address.
     * @return  `List<OrgWideEmailAddress>`
     */
    public static List<OrgWideEmailAddress> getOrgWideEmailAddress(){
        
        List<OrgWideEmailAddress> senderAddressList = [SELECT Id,
                                                                Address, 
                                                                DisplayName 
                                                            FROM  OrgWideEmailAddress 
                                                            WHERE DisplayName = :CFA_ORGANISATION];
        if (senderAddressList.isEmpty()) {
            throw new CustomException(ConstantValues.ORGWIDE_ADDRESS_NOT_FOUND);
        }
        return senderAddressList;
    }
    
    /**
     * @description The purpose of this method is to send user list respective to a account list.
     * @param accountList 
     * @return  `Map<Id, Id>`
     */
    public static Map<Id, Id> getUserListFromAccountList(List<Id> accountList){
        List<User> portalUserList = new List<User>();
        Map<Id, Id> userMap = new Map<Id, Id>();

        if(accountList.isEmpty()){
            return userMap;
        }

        portalUserList = [SELECT Id, 
                                AccountId, 
                                ContactId, 
                                Account.ParentId, 
                                Account.RecordType.Name 
                            FROM User 
                            WHERE AccountId IN :accountList];
        
        for(User eachUser : portalUserList){
            userMap.put(eachUser.AccountId, eachUser.Id);
        }

        return userMap;
    }

    /**
     * @description This method will return all payment administrator relationship contact associate with key account id
     * @param dealerRelationAccountIds 
     * @return  `Map<Object, Contact>`
     */
    public static Map<Object, Contact> getDealerRelationContacts(List<Id> dealerRelationAccountIds){
        Map<Object, Contact> paContactMap = new Map<Object, Contact>();
        List<Contact> dealerRelationContacts = new List<Contact>(); 

        if(dealerRelationAccountIds.isEmpty()){
            return paContactMap;
        }

        dealerRelationContacts = [SELECT Id,
                                        Account.Id, 
                                        Account.RecordType.Name
                                    FROM Contact 
                                    WHERE Account.Id IN :dealerRelationAccountIds];
                                
        for (Contact dealerRelationContact : dealerRelationContacts) {
            if (dealerRelationContact.Account.RecordType.Name == ConstantValues.PAYMENT_ADMINISTRATOR_PARTY_NAME ){
                paContactMap.put(dealerRelationContact.Account.Id, dealerRelationContact);
            }
        }
        return paContactMap;
    }
    /**
     * @description This method will check whether the list is empty or not
     * @param listToCheck
     * @param  exceptionNameString
     */
    public static void checkEmptyList(List<Object> listToCheck, String exceptionNameString){
        if(listToCheck.isEmpty()){
            throw new CustomException(exceptionNameString);
        }
    }
     /**
    * @description - Purpose of this method is to check required parameter.
    * @author Simran | 12-07-2023 
    * @param stringToCheck
    **/
    public static void checkRequiredParameters(String stringToCheck){
        if(String.isBlank(stringToCheck)){
            throw new CustomException(ConstantValues.PARAMETER_MISSING);
        }
    }
    /**
    * @description - Purpose of this method is to return the partyTypeId.
    * @author Simran | 12-20-2023 
    * @param recordType
    * @return partTypeId
    **/
    public static String getPartyTypeId(String recordType) {
        String partTypeId;
        clcommon__Party_Type__c objPartyType = [SELECT Id
                                                          FROM clcommon__Party_Type__c 
                                                          WHERE Name=:recordType LIMIT 1];

        
        partTypeId=objPartyType.Id;

        return partTypeId;
    }

    /**
    * @description 
    * @author Ayan Bhowmik | 02-07-2024 
    * @param dealerCIFToCoopMap 
    * @param emailTemplateName 
    * @param recieverAddressList 
    * @return List<String> 
    **/
    public static List<String> getAdditionalRecipientEmailForSingleTransaction(Map<String, String> dealerCIFToCoopMap, String emailTemplateName, List<String> recieverAddressList){

        Set<String> additionalRecipientSet = new Set<String>();
        List<String> dealerCIFList = new List<String>();

        for(String eachDealerCIF : dealerCIFToCoopMap.keySet()){
            dealerCIFList.add(eachDealerCIF);
        }

        if(dealerCIFList.isEmpty() | String.isBlank(emailTemplateName)){
            return recieverAddressList;
        }

        List<email_recipient__mdt>  recipientRecordsList = [SELECT Id, 
                                                                    DeveloperName, 
                                                                    Label, 
                                                                    Coop_Type__c,
                                                                    Dealer_CIF__c,
                                                                    Email__c
                                                                FROM Email_Recipient__mdt
                                                                WHERE Email_Template__c = :emailTemplateName
                                                                AND Dealer_CIF__c IN :dealerCIFList];
                                                        
        if(recipientRecordsList.isEmpty()){
            return recieverAddressList;
        }

        for(email_recipient__mdt eachRecords : recipientRecordsList){
            if((eachRecords.Email__c != null || String.isBlank(eachRecords.Email__c)) 
                        && eachRecords.Coop_Type__c == dealerCIFToCoopMap.get(eachRecords.Dealer_CIF__c)){
                additionalRecipientSet.add(eachRecords.Email__c);
            }
        }

        for(String eachEmail : new List<String>(additionalRecipientSet)){
            recieverAddressList.add(eachEmail);
        }
        return recieverAddressList;
    }

    /**
    * @description 
    * @author Ayan Bhowmik | 02-07-2024 
    * @param dealerCIFToCoopMap 
    * @param emailTemplateName 
    * @param emailRecipientMap 
    * @return Map<String, Set<String>> 
    **/
    public static Map<String, Set<String>> getAdditionalRecipientEmailForMultipleTransaction(Map<String, String> dealerCIFToCoopMap, 
                                                                                                    String emailTemplateName, 
                                                                                                    Map<String, Set<String>> emailRecipientMap){

        List<String> dealerCIFList = new List<String>();

        for(String eachDealerCIF : dealerCIFToCoopMap.keySet()){
            dealerCIFList.add(eachDealerCIF);
        }

        if(dealerCIFList.isEmpty() | String.isBlank(emailTemplateName)){
            return emailRecipientMap;
        }

        List<email_recipient__mdt>  recipientRecordsList = [SELECT Id, 
                                                                    DeveloperName, 
                                                                    Label, 
                                                                    Coop_Type__c,
                                                                    Dealer_CIF__c,
                                                                    Email__c
                                                                FROM Email_Recipient__mdt
                                                                WHERE Email_Template__c = :emailTemplateName
                                                                AND Dealer_CIF__c IN :dealerCIFList];
                                                        
        if(recipientRecordsList.isEmpty()){
            return emailRecipientMap;
        }

        for(email_recipient__mdt eachRecords : recipientRecordsList){
            if((eachRecords.Email__c != null || String.isBlank(eachRecords.Email__c)) 
                        && eachRecords.Coop_Type__c == dealerCIFToCoopMap.get(eachRecords.Dealer_CIF__c)){
                if(emailRecipientMap.containsKey(eachRecords.Dealer_CIF__c)){
                    emailRecipientMap.get(eachRecords.Dealer_CIF__c).add(eachRecords.Email__c);
                } else {
                    emailRecipientMap.put(eachRecords.Dealer_CIF__c, new Set<String>{eachRecords.Email__c});
                }
            }
        }

        return emailRecipientMap;
    }

    /**
    * @description This method is used to create Relationship record
    * @author Simran | 02-15-2024 
    * @param recordDetailsMap 
    **/
    public static void createRelationshipRecord(Map<String, Object> recordDetailsMap){

        String fsaRoleId;
        String newDealerId = (String)recordDetailsMap.get(ConstantValues.DEALER_ID);
        String newDealerCoop = (String)recordDetailsMap.get(ConstantValues.SELECTED_DEALER_COOP);
        String accountId = (String)recordDetailsMap.get(ConstantValues.DEALER_CONTACT_ID);
        List<clcommon__Relationship__c> relationshipToCreateList = new List<clcommon__Relationship__c>();
        List<String> newRelationshipList = (List<String>)recordDetailsMap.get(ConstantValues.RECORD_TYPE_NAME);
        List<clcommon__Reciprocal_Role__c> reciprocalRoleList = [SELECT Id,
                                                                        Name
                                                                    FROM clcommon__Reciprocal_Role__c 
                                                                    WHERE Name IN :newRelationshipList
                                                                    WITH SECURITY_ENFORCED];

        for(clcommon__Reciprocal_Role__c eachRole : reciprocalRoleList){
            if(eachRole.Name == ConstantValues.FIELD_STAFF_AGENT){
                fsaRoleId = eachRole.Id;
                continue;
            }
            clcommon__Relationship__c relationshipObj = new clcommon__Relationship__c();
            relationshipObj.clcommon__Relationship__c = eachRole.Id;
            relationshipObj.clcommon__Entity__c = newDealerId;
            relationshipObj.clcommon__Related_Entity__c = accountId;
            relationshipToCreateList.add(relationshipObj);
        }
        if(fsaRoleId != null | !String.isBlank(fsaRoleId)){
            //Krishanu - remove gmk hardcoding , and pass the dealer coop type
            List<Account> gmkDealerList=[SELECT Id 
                                            FROM Account 
                                            WHERE Coop_Type__c =:newDealerCoop
                                            AND RecordType.Name =:ConstantValues.DEALER
                                            WITH SECURITY_ENFORCED];
            for(Account eachDealer : gmkDealerList){
                clcommon__Relationship__c relationshipObj = new clcommon__Relationship__c();
                relationshipObj.clcommon__Relationship__c = fsaRoleId;
                relationshipObj.clcommon__Entity__c = eachDealer.Id;
                relationshipObj.clcommon__Related_Entity__c = accountId;
                relationshipToCreateList.add(relationshipObj);
            }
        }
        
        if(Schema.sObjectType.clcommon__Relationship__c.isCreateable()){
            Database.insert(relationshipToCreateList, true);
        }
    }

    /**
    * @description This method is used to create Account sharing record
    * @author Simran | 02-07-2024 
    * @param recordDetailsMap 
    **/
    public static void createAccountShareRecord(Map<String, Object> recordDetailsMap){
        List<AccountShare> accountShareList = new List<AccountShare>();
        List<String> newRelationship = (List<String>)recordDetailsMap.get(ConstantValues.RECORD_TYPE_NAME);
        List<User> userList =[SELECT Id 
                                FROM User 
                                WHERE AccountId=:(String)recordDetailsMap.get(ConstantValues.DEALER_CONTACT_ID) 
                                WITH SECURITY_ENFORCED 
                                LIMIT 1];
        if(userList.isEmpty()){
            return;
        }
        if (AccountShare.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isAccessible()) {
            accountShareList = [SELECT Id,
                                    Account.Name, 
                                    UserOrGroup.Name,
                                    OpportunityAccessLevel 
                                FROM AccountShare 
                                WHERE UserOrGroupId =: userList[ConstantValues.ZERO_VALUE].Id
                                LIMIT 1];
        }

        if((newRelationship.contains(ConstantValues.CERTIFIED_LENDER) 
                    | newRelationship.contains(ConstantValues.CERTIFIED_LENDER_PLUS)
                    | newRelationship.contains(ConstantValues.PAYMENT_ADMINISTRATOR)
                    | newRelationship.contains(ConstantValues.FIELD_STAFF_AGENT))
                    & accountShareList.isEmpty()
                    & AccountShare.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isCreateable()
                    & AccountShare.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()) {
            
            AccountShare newAccShare = new AccountShare();
            newAccShare.AccountAccessLevel = ConstantValues.ACCESS_LABEL_EDIT;
            newAccShare.AccountId = (String)recordDetailsMap.get(ConstantValues.DEALER_CONTACT_ID);
            newAccShare.UserOrGroupId = userList[ConstantValues.ZERO_VALUE].Id;
            newAccShare.OpportunityAccessLevel = ConstantValues.OPPORTUNITY_ACCESS_LEVEL;
            Database.upsert(newAccShare,false);
        } else if((!newRelationship.contains(ConstantValues.CERTIFIED_LENDER) 
                        & !newRelationship.contains(ConstantValues.CERTIFIED_LENDER_PLUS)
                        & !newRelationship.contains(ConstantValues.PAYMENT_ADMINISTRATOR)
                        & !newRelationship.contains(ConstantValues.FIELD_STAFF_AGENT))
                        & !accountShareList.isEmpty()
                        & AccountShare.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isDeletable()) {
            Database.delete(accountShareList, false);
        }
    }

    /**
    * @description This method is used to get th role type
    * @author Simran | 02-05-2024
    * @param recordTypeList 
    * @return Boolean 
    **/
    public static String getRecordType(List<String> recordTypeList){ 
        for(String eachRecordType : recordTypeList){
            if(eachRecordType == ConstantValues.CERTIFIED_LENDER
                        || eachRecordType == ConstantValues.CERTIFIED_LENDER_PLUS
                        || eachRecordType == ConstantValues.INQUIRY
                        || eachRecordType == ConstantValues.INQUIRY_PLUS
                        || eachRecordType == ConstantValues.FIELD_STAFF_AGENT
                        || eachRecordType == ConstantValues.PAYMENT_ADMINISTRATOR){
                return eachRecordType;
            }
        }
        return ConstantValues.EMPTY_STRING;
    }

    /**
    * @description The purpose of this method is to delete existing relationship.
    * @author Ayan Bhowmik | 04-01-2024 
    * @param existingRelationshipList 
    * @param previousDealer 
    * @param accountId 
    * @return List<Id> 
    **/
    public static List<Id> deleteExistingRelationship(List<String> existingRelationshipList,  String previousDealer, String accountId){
        List<Id> dealerIdList = new List<Id>();
        if(existingRelationshipList.contains(ConstantValues.FIELD_STAFF_AGENT)){
            List<clcommon__Relationship__c> objRelationshipRecordList =[SELECT Id,
                                                                                clcommon__Entity_Role__c, 
                                                                                clcommon__Entity__c,  
                                                                                clcommon__Related_Entity__c
                                                                            FROM clcommon__Relationship__c 
                                                                            WHERE clcommon__Related_Entity__c =: accountId 
                                                                            AND clcommon__Entity_Role__c =: ConstantValues.FIELD_STAFF_AGENT 
                                                                            WITH SECURITY_ENFORCED];
            for(clcommon__Relationship__c entity:objRelationshipRecordList){
                dealerIdList.add(entity.clcommon__Entity__c);
            }
        } else {
            dealerIdList.add(previousDealer);
        }
        List<clcommon__Relationship__c> objRelationshipRecordList = [SELECT Id, 
                                                                            Name 
                                                                        FROM clcommon__Relationship__c 
                                                                        WHERE clcommon__Related_Entity__c =: accountId 
                                                                        AND clcommon__Entity__c IN :dealerIdList 
                                                                        AND clcommon__Relationship__r.Name IN :existingRelationshipList
                                                                        WITH SECURITY_ENFORCED];
        if(clcommon__Relationship__c.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isDeletable()){
            Database.delete(objRelationshipRecordList,true);
        }
        if(existingRelationshipList.contains(ConstantValues.SALES_AGENT)
                    || existingRelationshipList.contains(ConstantValues.SALES_AGENT_PLUS)
                    || existingRelationshipList.contains(ConstantValues.SALES_AGENT_ADMIN)){
            //Delete relationship of selected sales agents and the admin
            List<clcommon__Relationship__c> relToDelete = [SELECT Id,
                                                                clcommon__Entity__c,
                                                                clcommon__Relationship__r.Name
                                                                FROM clcommon__Relationship__c
                                                                WHERE clcommon__Relationship__r.Name =: PortalConstants.RELATED_SALES_AGENT
                                                                AND (clcommon__Related_Entity__c =: accountId
                                                                    OR clcommon__Entity__c =: accountId)];
            
            Database.delete(relToDelete, true);
        }
        return dealerIdList;
    }

    /**
    * @description The purpose of this method is to create dummy relationship.
    * @author Ayan Bhowmik | 04-15-2024 
    * @param dealerIdList 
    * @param paramMap 
    * @param existingRelationshipList 
    **/
    public static void createDummyRelationship(List<Id> dealerIdList, Map<String, String> paramMap, List<String> existingRelationshipList){
        List<clcommon__Relationship__c> objRelToCreateList = new List<clcommon__Relationship__c>();
        Boolean isFSA = false;
        for(String eachRecordType : existingRelationshipList){
            if(eachRecordType == ConstantValues.FIELD_STAFF_AGENT){
                isFSA = true;
                continue;
            }
            clcommon__Relationship__c createDummyRelationship = new clcommon__Relationship__c();
            createDummyRelationship.Previous_Dealer_Contact__c = paramMap.get(ConstantValues.ACCOUNT_ID);
            createDummyRelationship.Previous_Dealer__c = paramMap.get(ConstantValues.DEALER_ID);
            createDummyRelationship.Previous_Dealer_Contact_Role__c = eachRecordType;
            objRelToCreateList.add(createDummyRelationship);
        }
        if(isFSA){
            for(Id eachdealerId : dealerIdList){
                clcommon__Relationship__c createDummyRelationship = new clcommon__Relationship__c();
                createDummyRelationship.Previous_Dealer_Contact__c = paramMap.get(ConstantValues.ACCOUNT_ID);
                createDummyRelationship.Previous_Dealer__c = eachdealerId;
                createDummyRelationship.Previous_Dealer_Contact_Role__c = ConstantValues.FIELD_STAFF_AGENT;
                objRelToCreateList.add(createDummyRelationship);
            }
        }
        Database.insert(objRelToCreateList, true); 
    }

    /**
    * @description This method is used to call the CreateDealerContactPartyBatch
    * @author Simran | 02-14-2024 
    * @param dealerContactRecordMap 
    **/
    public static void createPartyBatch(Map<String, Object> dealerContactRecordMap){
        String newRecordType = getRecordType((List<String>)dealerContactRecordMap.get(ConstantValues.RECORD_TYPE_NAME));
        if(!String.isBlank(newRecordType) && newRecordType != null){
            dealerContactRecordMap.put(ConstantValues.RECORD_TYPE_NAME, newRecordType);
            CreateDealerContactPartyBatch createDealerContactParty = new CreateDealerContactPartyBatch(dealerContactRecordMap);
            Database.executeBatch(createDealerContactParty, Integer.valueOf(ConstantValues.CREATE_DELETE_PARTY_BATCH_SIZE));   
        }
    }

    /**
    * @description The purpose of this method is to fetch account coop type.
    * @author Ayan Bhowmik | 04-04-2024 
    * @param accountId 
    * @return String 
    **/
    public static String getCoopTypeByAccountId(Id accountId){
        List<Account> accountList = [SELECT Id,
                                            Coop_Type__c
                                        FROM Account
                                        WHERE Id =: accountId
                                        WITH SECURITY_ENFORCED
                                        LIMIT 1];
        checkEmptyList(accountList, ConstantValues.SOMETHING_WENT_WRONG);
        return accountList[ConstantValues.ZERO_VALUE].Coop_Type__c;
    }
    /**
    * @description This method is used to update the user profile
    * @author Simran | 02-16-2024 
    * @param coopType
    * @param accountId
    * @param recordTypeName
    **/
    @future(callout = true)
    public static void updateUserProfile(String coopType,Id accountId,String recordTypeName){
        List<User> userList = [SELECT Id, 
                                    ProfileId, 
                                    Coop_Type__c,
                                    IsActive
                                FROM User 
                                WHERE AccountId=:accountId 
                                WITH SECURITY_ENFORCED LIMIT 1];
        if (userList.isEmpty()) {
            return;
        }
        if ((String.isBlank(recordTypeName)
                    | recordTypeName == ConstantValues.AUTHORIZED_PERSON
                    | recordTypeName == ConstantValues.GENERAL_MANAGER
                    | recordTypeName == ConstantValues.PRIMARY_CONTACT
                    | recordTypeName == ConstantValues.OTHER)){
            userList[ConstantValues.ZERO_VALUE].IsActive = false;
        } else {
            if (coopType == ConstantValues.GROWMARK_COOP_TYPE & recordTypeName != ConstantValues.AGRIBUSINESS){
                String profileName = ConstantValues.GROWMARK_COOP_TYPE + ConstantValues.SPACE_STRING + recordTypeName;
                Profile objProfile = [SELECT Id, 
                                            Name 
                                        FROM Profile 
                                        WHERE Name =: profileName 
                                        WITH SECURITY_ENFORCED 
                                        LIMIT 1];
                userList[ConstantValues.ZERO_VALUE].ProfileId = objProfile.Id;
            } else {
                Profile objProfile=[SELECT Id, 
                                            Name 
                                        FROM Profile 
                                        WHERE Name =: recordTypeName 
                                        WITH SECURITY_ENFORCED 
                                        LIMIT 1];
                userList[ConstantValues.ZERO_VALUE].ProfileId = objProfile.Id;
            }
            if (!userList[ConstantValues.ZERO_VALUE].IsActive){
                userList[ConstantValues.ZERO_VALUE].IsActive = true;
            }
        }
        if (User.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
            Database.update(userList, true);
        }
    }

    
    /**
    * @description The purpose of this method is to set highest record type and parent id.
    * @author Ayan Bhowmik | 04-16-2024 
    * @param newRelationRoleList 
    * @param accountObj 
    * @param dealerId 
    * @return String 
    **/
    public static String updateParentIdAndRecordType(List<RecordType> newRelationRoleList, Account accountObj, String dealerId){
        RecordType highestPriorityRecordType;
       
        if(!newRelationRoleList.isEmpty()){
            List<RecordType> objRecordType = [SELECT Id, 
                                                    Name 
                                                FROM RecordType 
                                                WHERE Id IN :newRelationRoleList
                                                WITH SECURITY_ENFORCED];
            highestPriorityRecordType = getHighestPriorityRecordType(objRecordType);
            if(highestPriorityRecordType != null){
                accountObj.RecordTypeId = highestPriorityRecordType.Id;
            }
        }
        accountObj.ParentId = (Id)dealerId;
        accountObj.Coop_Type__c = getCoopTypeByAccountId(dealerId);
        if(Account.sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).isUpdateable()){
            Database.update(accountObj, true);
        }
        return highestPriorityRecordType == null ? ConstantValues.SPACE_STRING : highestPriorityRecordType.Name;
    }
    /**
    * @description The purpose of this method is to check licenses for user.
    * @author Ayan Bhowmik | 04-03-2024 
    **/
    public static void checkLicense(){
        List<UserLicense> userLicenseList = new List<UserLicense>();
        userLicenseList = [SELECT Id, 
                                TotalLicenses, 
                                UsedLicenses 
                            FROM UserLicense 
                            WHERE Name =: ConstantValues.CUSTOMER_COMMUNITY_PLUS
                            WITH SECURITY_ENFORCED];
        CFAOriginationHelperClass.checkEmptyList(userLicenseList, ConstantValues.LICENSES_FETCHING_ERROR);
        if((userLicenseList[ConstantValues.ZERO_VALUE].TotalLicenses - userLicenseList[0].UsedLicenses) == 0){
            throw new AuraHandledException(ConstantValues.NO_LICENSES);
        }
    }

    /**
    * @description The purpose of this method is to return highest priority recordtype.
    * @author Ayan Bhowmik | 04-01-2024 
    * @param entityRoleList 
    * @return RecordType 
    **/
    public static RecordType getHighestPriorityRecordType(List<RecordType> entityRoleList){
        RecordType highestPriorityRecordType;
        for(RecordType eachRecordType : entityRoleList){
            if(ConstantValues.PERMISSIONED_USER.contains(eachRecordType.Name)){
                return eachRecordType;
            }
            if(eachRecordType.Name == ConstantValues.AGRIBUSINESS){
                highestPriorityRecordType = eachRecordType;
            }
        }
        return highestPriorityRecordType == null ? entityRoleList[ConstantValues.ZERO_VALUE] : highestPriorityRecordType;
    }

    /**
    * @description The purpose of this method is to return record type names from a record type list.
    * @author Ayan Bhowmik | 04-08-2024 
    * @param recordTypeList 
    * @return List<String> 
    **/
    public static List<String> getRecordTypeNamesList(List<RecordType> recordTypeList){
        List<String> recordTypeNameList = new List<String>();
        for(RecordType eachRecordType : recordTypeList){
            recordTypeNameList.add(eachRecordType.Name);
        }
        return recordTypeNameList;
    }

    /**
    * @description The purpose of this method is to return the values that are present in master list but not in child list.
    * @author Ayan Bhowmik | 04-08-2024 
    * @param masterList 
    * @param childList 
    * @return List<Object> 
    **/
    public static List<Object> valuesNotInList(List<Object> masterList, List<Object> childList){
        List<Object> valuesNotInChildList = new List<Object>(); 
        for(Object eachValue : masterList){
            if(!childList.contains(eachValue)){
                valuesNotInChildList.add(eachValue);
            }
        }
        return valuesNotInChildList;
    }

    /**
    * @description The purpose of this method is to return true if any same value present in both lists.
    * @author Ayan Bhowmik | 04-08-2024 
    * @param listA 
    * @param listB 
    * @return Boolean 
    **/
    public static Boolean hasAnySameValueInList(List<Object> listA, List<Object> listB){
        Boolean hasAnySameValue = false;
        for(Object eachAddedRelation : listA){
            if(listB.contains(eachAddedRelation)){
                hasAnySameValue = true;
                break;
            }
        }
        return hasAnySameValue;
    }
    /**
    * @description The purpose of this method is to set aura handled message and throw.
    * @author Ayan Bhowmik | 04-10-2024 
    * @param message 
    **/
    public static void throwAuraHandledException(String message){
        AuraHandledException exceptionObj = new AuraHandledException(message);
        exceptionObj.setMessage(message);
        throw exceptionObj;
    }
/**
    * @description 
    * @author Ayan Bhowmik | 06-18-2024 
    * @param inputString 
    * @return String 
    **/
    public static String removeNonAlphabeticCharacters(String inputString) {
        String regex = ConstantValues.NON_ALPHA_NUMERIC_REGEX;
        String result = inputString.replaceAll(regex, ConstantValues.EMPTY_STRING);
        
        return result;
    }

    
    /**
    * @description : Method to create clcommon__Category_Attachment_Association__c
    * @author Suraj Kumar | 10-25-2024 
    * @param categoryAttachmentMap 
    **/
    public static void createDocCategoryAttachment(Map<String,String> categoryAttachmentMap){
        List<clcommon__document_category__c> docCategoryList = [SELECT Id
                                                                    FROM clcommon__document_category__c
                                                                    WHERE genesis__Application__c =:categoryAttachmentMap.get(PortalConstants.APPLICATION_ID_KEY)
                                                                    AND clcommon__Category_Name__c =: categoryAttachmentMap.get(PortalConstants.NAME_KEY)];

        List<ContentDocumentLink> conDocLinkList = [SELECT Id
                                                        FROM ContentDocumentLink
                                                        WHERE ContentDocumentId = :categoryAttachmentMap.get(PortalConstants.CONTENT_DOC_ID_KEY)];

        if (docCategoryList.size() >0 && conDocLinkList.Size()>0) {
            clcommon__Category_Attachment_Association__c docCategoryAttachmentObj = new clcommon__Category_Attachment_Association__c();
            docCategoryAttachmentObj.clcommon__Document_Category__c = docCategoryList[0].Id;
            docCategoryAttachmentObj.clcommon__Content_Document_Id__c = categoryAttachmentMap.get(PortalConstants.CONTENT_DOC_ID_KEY);
            docCategoryAttachmentObj.clcommon__Content_Version_Id__c = categoryAttachmentMap.get(PortalConstants.CONTENT_VERSION_ID_KEY);
            docCategoryAttachmentObj.clcommon__Attachment_Id__c = conDocLinkList[0].Id;
            docCategoryAttachmentObj.Name = categoryAttachmentMap.get(PortalConstants.TITLE_KEY);
            Database.Insert(docCategoryAttachmentObj, true);
        }
    }
    /**
    * @description : This method return dealer details
    * @author Suraj Kumar | 03-16-2024
    * @param eachCetifiedLender 
    * @return Map<String, String> 
    **/
    public static Map<String, String> getDealerDetails(clcommon__Relationship__c eachCetifiedLender){
        String dealerCity = '';
        String dealerState = '';
        String dealerCIF = '';
        Boolean hasDealerCity = false;
        Boolean hasDealerState = false;
        Map<String, String> dealerDetailsMap = new Map<String, String>();

        if(eachCetifiedLender.clcommon__Entity__r.BillingCity != null){
            dealerCity = eachCetifiedLender.clcommon__Entity__r.BillingCity;
            hasDealerCity = true;
        }
        if(eachCetifiedLender.clcommon__Entity__r.BillingState != null){
            dealerState = eachCetifiedLender.clcommon__Entity__r.BillingState;
            hasDealerState = true;
        }
        if(eachCetifiedLender.clcommon__Entity__r.CIF_Number__c != null){
            dealerCIF = eachCetifiedLender.clcommon__Entity__r.CIF_Number__c;
        }
        if((hasDealerCity & hasDealerState)) {
            dealerCity += ConstantValues.SPACE_STRING + ConstantValues.COMMA_STRING + ConstantValues.SPACE_STRING;
        }
        dealerDetailsMap.put(ConstantValues.KEY_DEALER_CITY, dealerCity);
        dealerDetailsMap.put(ConstantValues.KEY_DEALER_STATE, dealerState);
        dealerDetailsMap.put(ConstantValues.KEY_DEALER_CIF, dealerCIF);
        dealerDetailsMap.put(ConstantValues.KEY_DEALER_ID, eachCetifiedLender.clcommon__Entity__c);
        return dealerDetailsMap;
    }
}