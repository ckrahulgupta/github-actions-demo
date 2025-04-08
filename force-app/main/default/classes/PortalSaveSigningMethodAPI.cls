/**********************************************************************************************************************
 * @description       : This class stores the signing method of a borrower/principal for an application.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 03-11-2025
 * @last modified by  : Ayush Kumar Singh
**********************************************************************************************************************/
global without sharing class PortalSaveSigningMethodAPI implements clcommon.PortalCustomRemoteAPI1 {
    
    // parameters specific for this class [start]
    private final String CLASS_NAME = PortalSaveSigningMethodAPI.class.getName();
    private static final String IN_PERSON_DOCUSIGN = 'IN Person - Docusign';
    private static final String EMAIL_DOCUSIGN = 'Email - Docusign';
    private static final String KEY_APPLICATION = 'application';
    private static final String KEY_SIGNING_METHOD = 'signingMethod';
    private static final String KEY_APPLICANT_DETAILS = 'applicantDetails';
    private static final String SAVE_AND_CONTINUE_STRING = 'SaveAndContinue';
    private static final String SIGNING_TASK = 'Signed Credit Agreement';

    /*******************************Declaration of global variables*******************************************/
    String signingMethod;
    String applicationId;
    String applicantDetails;
    String applicationRecord;
    List<clcommon.PortalCustomRemoteActionRecord> respData = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();
    String borrowerAccountId;
    String borrowerContactId;
    String borrowerBusinessInfoId;
    List<Id> principalAccountIdList = new List<Id>();
    List<Id> principalContactIdList = new List<Id>();
    List<Id> principalBInfoIdList = new List<Id>();
    SavePoint dbSavePoint = Database.setSavepoint();

    /**
    * @description - Purpose of this method is to update the application status and the signing method field 
    *                depending on the signing method
    * @author Arka Jyoti Deb | 04-28-2022 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                                String[] disclosureNames,
                                                Map<String, Object> argumentsFromPortal) {

        List<Object> applicantDetailsList = new List<Object>();
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        Account borrowerAccount;
        try {
            List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
            List<clcommon__Party__c> partyListToValidate = new List<clcommon__Party__c>();
            applicationRecord = String.valueOf(argumentsFromPortal.get(KEY_APPLICATION));
            applicantDetails = String.valueOf(argumentsFromPortal.get(KEY_APPLICANT_DETAILS));
            applicationObj = (genesis__Applications__c) Json.deserialize(applicationRecord, genesis__Applications__c.class);
            applicationId = applicationObj.Id;
            List<genesis__Applications__c> applicationList = [SELECT id, 
                                                                        signing_method__c,
                                                                        Agreement_Sign__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE id = :applicationId];
            deleteExistingDocument(applicationList);
            
            signingMethod = String.valueOf(argumentsFromPortal.get(KEY_SIGNING_METHOD));
            
            PortalApplicationOriginationHelper.checkForBlankParameter(applicantDetails);
            PortalApplicationOriginationHelper.checkForBlankParameter(applicationId);
            PortalApplicationOriginationHelper.checkForBlankParameter(signingMethod);


            applicantDetailsList = (List<Object>) Json.deserializeUntyped(applicantDetails);         
            Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationId); 
            PortalApplicationOriginationHelper.throwErrorIfFalse(isValidUser,PortalConstants.USER_NOT_AUTHORISED);
            
            //Validations required for Applicant Information details for Borrower Starts------
            partyListToValidate = [SELECT Id, 
                                                clcommon__Account__c,
                                                clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                clcommon__Contact__c,
                                                clcommon__Account__r.genesis__Business_information__c,
                                                clcommon__Type__r.Name,
                                                Street__c,
                                                City__c,
                                                State__c,
                                                County__c,
                                                Postal_Code__c,
                                                Mobile_Number__c,
                                                Home_Number__c,
                                                Work_Number__c,
                                                Total_Assets__c,
                                                Total_Liabilities__c,
                                                Marital_Status__c
                                        FROM clcommon__Party__c
                                        WHERE genesis__Application__r.Id=:applicationId 
                                        AND (clcommon__Type__r.Name =: PortalConstants.PRINCIPAL_PARTY_NAME 
                                        OR clcommon__Type__r.Name =: PortalConstants.BORROWER_PARTY_NAME)];

            getApplicantInfo(partyListToValidate);
            
            
            List<genesis__Applications__c> applicationListToValidate = [SELECT Id,
                                                                        Signing_Method__c, 
                                                                        Stage__c,
                                                                        genesis__Loan_Amount__c
                                                                FROM genesis__Applications__c
                                                                WHERE Id = :applicationId];
            borrowerAccount=validateApplicationInfoForBorrower(applicationListToValidate, partyListToValidate);
            
            //Validations required for Applicant Information details for Borrower Ends------
            //Validations required for Applicant Information details for Principal Starts------
            validateApplicationInfoForPrincipal(partyListToValidate);
            
            //Validations required for Applicant Information details for Principal Ends------
            partyList = [SELECT Id,
                                   clcommon__Contact__r.Email,
                                   clcommon__Account__c,
                                   clcommon__Contact__c,
                                   clcommon__Account__r.genesis__Business_information__c,
                                   clcommon__Account__r.Kyc_Verified__c,
                                   clcommon__Type__r.Name,
                                   clcommon__Account__r.Is_Individual__c
                            FROM clcommon__Party__c
                            WHERE genesis__Application__r.Id=:applicationId 
                            AND ((clcommon__Type__r.Name =: PortalConstants.PRINCIPAL_PARTY_NAME 
                                            OR clcommon__Type__r.Name =: PortalConstants.BORROWER_PARTY_NAME) 
                                    OR clcommon__Type__r.Name =: PortalConstants.PRINCIPAL_PARTY_NAME)];

            if(applicantDetailsList.size() != partyList.size() && borrowerAccount.Is_Individual__c ){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            
            PortalApplicationOriginationHelper.checkEmailDetails(applicantDetailsList, partyList,signingMethod);
            applicationObj.Signing_Method__c = signingMethod;
            //Based on the Signing Method, the task is marked required or not
            PortalApplicationOriginationHelper.checkSignAgreementTask(applicationObj.Signing_Method__c, applicationObj.Id);
                                    
            applicationObj.genesis__Status__c = PortalConstants.E_SIGN_PENDING_APPLICATION_STATUS;
            //To change the stage of A[pplication
            if(applicationObj.Signing_Method__c == PortalConstants.PAPER_SCANNED && applicationListToValidate[0].Stage__c == PortalConstants.APPLICANT_SIGNATURE){
                applicationObj.Stage__c = PortalConstants.SCORE_CREDIT_REFERENCE;
            }
            applicationObj.DocuSign_Credit_Agreement_Initiated__c = false;
            Database.Update(applicationObj, true);
            
            clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(respData);
            response.content = null;
            response.response = responseFormat.response;
            response.status = clcommon.Constants.SUCCESS;
        } catch (CustomException customExceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customExceptionObj.getMessage();
            PortalHelper.saveExceptionLog(customExceptionObj, CLASS_NAME); 

        }
         catch (Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(exceptionObj, CLASS_NAME); 
        }
        return response;
    }
    
    /**
     * @description If there is existing document present then need to delete that first and then procees with signing method
     * @param applicationList 
     */
    private void deleteExistingDocument(List<genesis__Applications__c> applicationList){
        List<ContentDocumentLink> oldDocument = new List<ContentDocumentLink>();
        List<clcommon__document_category__c> docCategoryList = new List<clcommon__document_category__c>();
        List<clcommon__party__c> partyList = new List<clcommon__party__c>();
        List<clcommon__Category_Attachment_Association__c> docAttachment = new List<clcommon__Category_Attachment_Association__c>();
        List<String> contentDocumentIdList = new List<String>();
        if(!applicationList.isEmpty() && applicationList[0].Signing_Method__c!= null && applicationList[0].Agreement_Sign__c == false){

            oldDocument = [SELECT Id, 
                                    LinkedEntityId, 
                                    ContentDocumentId 
                            FROM ContentDocumentLink 
                            WHERE LinkedEntityId = :applicationList[0].id];

            for(ContentDocumentLink docLink : oldDocument){
                contentDocumentIdList.add(docLink.ContentDocumentId);
            }
                            
            docCategoryList = [SELECT Id 
                            FROM clcommon__document_category__c 
                            WHERE genesis__Application__c =: applicationList[0].id 
                            AND clcommon__Category_Name__c =: SIGNING_TASK ];
            PortalApplicationOriginationHelper.checkEmptyList(docCategoryList, PortalConstants.SOMETHING_WENT_WRONG);
            
            partyList = [SELECT id,
                                DocuSign_URL__c 
                        FROM clcommon__party__c 
                        WHERE genesis__Application__c =:applicationList[0].id];
            
            PortalApplicationOriginationHelper.checkEmptyList(partyList, PortalConstants.SOMETHING_WENT_WRONG);
           
            for(clcommon__party__c party : partyList){
                if(party.DocuSign_URL__c != null){
                    party.DocuSign_URL__c = null;
                    party.Sent_Url__c = false;
                    party.DocuSign_Generation_Time__c = null;
                }
            }

            docAttachment = [SELECT Id, 
                                    Name, 
                                    clcommon__Document_Category__c, 
                                    clcommon__Content_Document_Id__c 
                            FROM clcommon__Category_Attachment_Association__c 
                            WHERE clcommon__Document_Category__c = :docCategoryList[0].id];
            applicationList[0].Signing_Method__c = null;

            Database.update(partyList,true);
            Database.delete(docAttachment,true);
            Database.delete(oldDocument,true);
            if(!contentDocumentIdList.isEmpty()){
                Database.delete([SELECT id from ContentDocument WHERE Id IN :contentDocumentIdList]);
            }
            Database.update(applicationList,true);
        }
        
    }

    /**
     * @description Validation for borrower
     * @param applicationListToValidate 
     * @param partyListToValidate 
     * @return Account 
     */
    private Account validateApplicationInfoForBorrower(List<genesis__Applications__c> applicationListToValidate, List<clcommon__Party__c> partyListToValidate){
            // Query on Borrower Account for validation
            List<Account> borrowerAccountList =    [SELECT Id,
                                                    Name,
                                                    clcommon__Legal_Entity_Type__c,
                                                    Kyc_Verified__c,
                                                    Is_Individual__c
                                            FROM Account
                                            WHERE Id=:borrowerAccountId];
            // Query on Borrower Contact for Validation
            List<Contact> borrowerContactList =[SELECT Id,
                                                FirstName,
                                                genesis__SSN__c,
                                                Confirm_SSN__c,
                                                Birthdate
                                            FROM Contact
                                            WHERE Id=:borrowerContactId];
            List<genesis__Business_Information__c> borrowerBInfoList =  [SELECT Id,
                                                                                genesis__Total_Assets__c,
                                                                                genesis__Total_Liabilities__c,
                                                                                genesis__Tax_Identification_Number__c,
                                                                                genesis__State_of_Incorporation__c
                                                                            FROM genesis__Business_Information__c
                                                                            WHERE Id=:borrowerBusinessInfoId];
            
            List<clcommon__party__c> partyList = new List<clcommon__party__c>();
            for(clcommon__party__c party : partyListToValidate){
                if(party.clcommon__Type__r.Name == PortalConstants.BORROWER_PARTY_NAME){
                    partyList.add(party);
                    break;
                }
            }
            
            PortalApplicationOriginationHelper.checkEmptyList(borrowerAccountList, PortalConstants.SUBMITTED_WITHOUT_APPLICANT_INFO);
            PortalApplicationOriginationHelper.checkEmptyList(borrowerContactList, PortalConstants.SUBMITTED_WITHOUT_APPLICANT_INFO);
            PortalApplicationOriginationHelper.checkEmptyList(borrowerBInfoList, PortalConstants.SUBMITTED_WITHOUT_APPLICANT_INFO);

            PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{PortalConstants.APPLICATION_OBJ_KEY => applicationListToValidate[0],
                                                                                PortalConstants.CONTACT_OBJ_KEY => borrowerContactList[0],
                                                                                PortalConstants.ACCOUNT_OBJ_KEY => borrowerAccountList[0],
                                                                                PortalConstants.BUSINESS_INFO_OBJ_KEY => borrowerBInfoList[0],
                                                                                PortalConstants.BORROWER_PARTY_KEY => partyList[0],
                                                                                PortalConstants.KEY_SHOULD_VALIDATE => SAVE_AND_CONTINUE_STRING
                                                                            });

            return borrowerAccountList[0];
    }

    /**
     * @description Validation For Principal
     * @param partyListToValidate 
     */
    private void validateApplicationInfoForPrincipal(List<clcommon__Party__c> partyListToValidate){
        List<clcommon__party__c> newpartyListToValidate = new List<clcommon__party__c>();
        for(clcommon__party__c party : partyListToValidate){
            if(party.clcommon__Type__r.Name == PortalConstants.PRINCIPAL_PARTY_NAME){
                newpartyListToValidate.add(party);
            }
        }
        List<Account> principalAccountList = [SELECT Id,
                                                    Name,
                                                    clcommon__Legal_Entity_Type__c,
                                                    Kyc_Verified__c
                                            FROM Account
                                            WHERE Id IN :principalAccountIdList];
        List<Contact> principalContactList = [SELECT Id,
                                                        FirstName,
                                                        LastName,
                                                        MailingStreet,
                                                        MailingCity,
                                                        MailingPostalCode,
                                                        MailingState,
                                                        Mailing_County__c,
                                                        genesis__SSN__c,
                                                        Confirm_SSN__c,
                                                        Birthdate,
                                                        MobilePhone,
                                                        HomePhone,
                                                        Phone
                                                FROM Contact
                                                WHERE Id IN :principalContactIdList];
        List<genesis__Business_Information__c> principalBusinessInfoList =   [SELECT Id,
                                                                                        genesis__Total_Assets__c,
                                                                                        genesis__Total_Liabilities__c,
                                                                                        genesis__Tax_Identification_Number__c
                                                                                FROM genesis__Business_Information__c
                                                                                WHERE Id IN :principalBInfoIdList]; 

        for(Integer partyCount = 0; partyCount<partyListToValidate.size()-1; partyCount++){
            PortalValidationUtil.isValidCoApplicationCreation(new Map<String,Object>{PortalConstants.CONTACT_OBJ_KEY => principalContactList[partyCount],
                                                                                    PortalConstants.ACCOUNT_OBJ_KEY => principalAccountList[partyCount],
                                                                                    PortalConstants.BUSINESS_INFO_OBJ_KEY => principalBusinessInfoList[partyCount],
                                                                                    PortalConstants.BORROWER_PARTY_KEY => newpartyListToValidate[partyCount],
                                                                                    PortalConstants.KEY_SHOULD_VALIDATE => SAVE_AND_CONTINUE_STRING
                                                                                });

        }

    }

    /**
     * @description Get Applicant Information need for validation
     * @param partyListToValidate 
     */
    private void getApplicantInfo(List<clcommon__Party__c> partyListToValidate){
        for(clcommon__Party__c individualPartyObj : partyListToValidate){
            //Check whether Total Assets and Liabilities are present before signing

            PortalApplicationOriginationHelper.checkAssetAndLiability(individualPartyObj);
            if(individualPartyObj.clcommon__Type__r.Name == PortalConstants.BORROWER_PARTY_NAME ){
                borrowerAccountId = individualPartyObj.clcommon__Account__c;
                borrowerContactId = individualPartyObj.clcommon__Contact__c;
                borrowerBusinessInfoId = individualPartyObj.clcommon__Account__r.genesis__Business_information__c;
                
                PortalApplicationOriginationHelper.checkCoApplicant(partyListToValidate);
            }
            else if (individualPartyObj.clcommon__Type__r.Name == PortalConstants.PRINCIPAL_PARTY_NAME){
                principalAccountIdList.add(individualPartyObj.clcommon__Account__c);
                principalContactIdList.add(individualPartyObj.clcommon__Contact__c);
                principalBInfoIdList.add(individualPartyObj.clcommon__Account__r.genesis__Business_information__c);
            }
        }
    }
   
}