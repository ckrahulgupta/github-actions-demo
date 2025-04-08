/**
 * @description       : purpose of this class is to save the applicant information on the application
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 03-01-2025
 * @last modified by  : Rakesh Saraf
**/
global without sharing class PortalSaveApplicantInformationAPI implements clcommon.PortalCustomRemoteAPI1{

    //Constant Values Specific to the Class
    private final String CLASS_NAME = PortalSaveApplicantInformationAPI.class.getName();  
    private static final String EVERGREEN_FLAG = 'IsNotEvergreen';

    //Global Variables
    String application = PortalConstants.EMPTY_STRING;
    String primaryApplicantAccount = PortalConstants.EMPTY_STRING;
    String primaryApplicantContact = PortalConstants.EMPTY_STRING;
    String primaryApplicantBusiness = PortalConstants.EMPTY_STRING;
    String coApplicantRecord = PortalConstants.EMPTY_STRING;
    String shouldValidate = PortalConstants.EMPTY_STRING;
    String applicationId = PortalConstants.EMPTY_STRING;
    String legalEntity = PortalConstants.EMPTY_STRING;
    String dealerCoopType = PortalConstants.EMPTY_STRING;


    List<User> loggedInUser = new List<User>();

    List<clcommon.PortalCustomRemoteActionRecord> responseDataList = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();
    Map<String, Object> fieldsMap = new Map<String, Object>();
    Map<String, SObject> relatedObjectsMap = new Map<String, SObject>();
   
    /**
     * @description : default constructor
     */
    global PortalSaveApplicantInformationAPI() {
        this.loggedInUser = PortalApplicationOriginationHelper.getLoggedInUser(); 
        dealerCoopType = loggedInUser[0].Account.Parent.Coop_Type__c; 

    }

    /**
    * @description 
    * @author Krishanu Chinya | 02-01-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames,Map<String, Object> argumentsFromPortal) {
        Account accountObj = new Account();
        Contact contactObj = new Contact();
        Contact priApplicantContactObj = new Contact();
        List<Map<String, Object>> coApplicants = new List<Map<String, Object>>();
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        genesis__Business_Information__c businessInfoObj = new genesis__Business_Information__c();

        SavePoint dbSavePoint = Database.setSavepoint();
        try {
            //fetching the required arguents 
            application = String.valueOf(argumentsFromPortal.get(PortalConstants.APPLICATION_KEY));
            primaryApplicantAccount = String.valueOf(argumentsFromPortal.get(PortalConstants.PRIMARY_APPLICANT_ACCOUNT_KEY));
            primaryApplicantContact = String.valueOf(argumentsFromPortal.get(PortalConstants.PRIMARY_APPLICANT_CONTACT_KEY));
            primaryApplicantBusiness = String.valueOf(argumentsFromPortal.get(PortalConstants.PRIMARY_APPLICANT_BUSINESS_INFO_KEY));
            coApplicantRecord = String.valueOf(argumentsFromPortal.get(PortalConstants.COAPPLICANT_KEY));
            shouldValidate = String.valueOf(argumentsFromPortal.get(PortalConstants.SAVE_TYPE_KEY));

            PortalApplicationCreationHandler.checkNecessaryParam(application, primaryApplicantAccount);

            applicationObj = (genesis__Applications__c) Json.deserialize(application, genesis__Applications__c.class);
            accountObj = (Account) Json.deserialize(primaryApplicantAccount, Account.class);
            if (!String.isBlank(primaryApplicantContact)) {
                contactObj = (Contact) Json.deserialize(primaryApplicantContact, Contact.class);
            }
            if (!String.isBlank(primaryApplicantBusiness)) {
                businessInfoObj = (genesis__Business_Information__c) Json.deserialize(primaryApplicantBusiness, genesis__Business_Information__c.class);
            }

            //getting the current legal entity 
            legalEntity = PortalApplicationOriginationHelper.getLegalEntityByAccount(accountObj); 

            //deserialise and creating a list of the coapplicants
            PortalApplicationCreationHandler.checkForCoApplicant(coApplicantRecord, legalEntity);
            coApplicants = PortalApplicationCreationHandler.getCoApplicantList(coApplicantRecord);

            List<clcommon__Party__c> borowerPartyList= [SELECT Id,
                                                                Street__c,
                                                                City__c,
                                                                State__c,
                                                                County__c,
                                                                Postal_Code__c,
                                                                Title__c,	
                                                                Suffix__c,
                                                                Home_Number__c,
                                                                Mobile_Number__c,
                                                                Work_Number__c,
                                                                Marital_Status__c,
                                                                clcommon__Account__c, 
                                                                clcommon__Contact__c, 
                                                                genesis__Application__c, 
                                                                clcommon__Party_Type__c, 
                                                                clcommon__Party_Types__c ,
                                                                Total_Assets__c,
                                                                Total_Liabilities__c
                                                        FROM clcommon__Party__c 
                                                        WHERE genesis__Application__c =: applicationObj.id
                                                        AND clcommon__Party_Types__c =: PortalConstants.BORROWER_PARTY_NAME];

            PortalApplicationOriginationHelper.checkEmptyList(borowerPartyList, PortalConstants.SOMETHING_WENT_WRONG);

            PortalApplicationCreationHandler.updateBorrowerPartyDetails(new Map<String,Object> {
                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactObj,
                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountObj,
                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoObj,
                                                                                            PortalConstants.BORROWER_PARTY_KEY=>borowerPartyList[0]});
    
            PortalValidationUtil.validateApplicationData(new Map<String, Object>{
                                                                            PortalConstants.ACCOUNT_OBJ_KEY => accountObj,
                                                                            PortalConstants.CONTACT_OBJ_KEY => contactObj,
                                                                            PortalConstants.KEY_SHOULD_VALIDATE => shouldValidate,
                                                                            PortalConstants.APPLICATION_OBJ_KEY => applicationObj,
                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoObj,
                                                                            PortalConstants.BORROWER_PARTY_NAME=> borowerPartyList[0]
                                                                        });

            //****** Default IsNotEvergreen */
            //tier 1, in person or email doc,prev 2 year, 2 no accrual loan
            fieldsMap.put(EVERGREEN_FLAG,true);

            //if save and exit, set all the fields as blank    
            if(shouldValidate == PortalConstants.SAVE_AND_EXIT){
                accountObj = PortalApplicationOriginationHelper.setNullIfEmpty(accountObj, dealerCoopType);
                contactObj = PortalApplicationOriginationHelper.setNullIfEmpty(contactObj, dealerCoopType);
                businessInfoObj = PortalApplicationOriginationHelper.setNullIfEmpty(businessInfoObj, dealerCoopType);
            }

            Map<String, Object> paramForApplicationMap = new Map<String, Object>{
                PortalConstants.ACCOUNT_OBJ_KEY => accountObj,
                PortalConstants.CONTACT_OBJ_KEY => contactObj,
                PortalConstants.PRIMARY_APPLICANT_KEY => priApplicantContactObj,
                PortalConstants.APPLICATION_OBJ_KEY => applicationObj,
                PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoObj,
                PortalConstants.BORROWER_PARTY_NAME=> borowerPartyList[0]
            };
            applicationObj = processTheExistingApplication(paramForApplicationMap, coApplicants, legalEntity);

            updateSalesAgentInApplication(applicationObj);
            Database.update(applicationObj,true);
            
            //Comparing and saving all the coapplicants for this application
            if (!String.isBlank(coApplicantRecord)){
                PortalApplicationCreationHandler.updateCoApplicantDetails(coApplicants,new Map<String,Object>{
                                                                                                            PortalConstants.APPLICATION_ID_KEY=>applicationId,
                                                                                                            PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                                            PortalConstants.LOGGED_IN_USER=>loggedInUser[0]
                                                                                                    });
            }


            //Update the Coop Type for all the Principal
            PortalApplicationCreationHandler.updatePrincipalParties(applicationObj.Id, dealerCoopType,loggedInUser[0]);
            //Create tasks if there are no tasks created Yet
            PortalApplicationCreationHandler.createTasks(String.valueOf(applicationObj.Id));

            //------------------
            PortalApplicationCreationHandler.verifyApplicants(applicationObj,shouldValidate);
            // createDealerApplicantRelationship(applicationObj.id);
            //------------------
            fieldsMap.put(PortalConstants.BORROWER_ENTITY_TYPE, legalEntity);
            responseDataList.add(new clcommon.PortalCustomRemoteActionRecord(fieldsMap));
            clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(responseDataList);
            response.content = null;
            response.response = responseFormat.response;
            response.status = clcommon.Constants.SUCCESS;
            
        } catch (CustomException mce) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = mce.getMessage();
            PortalHelper.saveExceptionLog(mce, CLASS_NAME);
        } catch (Exception ex) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(ex, CLASS_NAME);
        }
        return response;
        
    }

    /**
    * @description : updates sales agent and sa admin in application
    * @author Krishanu Chinya | 03-11-2024 
    * @param applicationObj 
    **/
    private void updateSalesAgentInApplication(genesis__Applications__c applicationObj){
        PortalApplicationCreationHandler.addSalesAgentParty(applicationObj); 
        PortalApplicationCreationHandler.createSharingRecordsForSA(applicationObj);           
        PortalApplicationCreationHandler.createSharingRecordsForSAAdmin(applicationObj);  
    }

    /**
    * @description 
    * @author Krishanu Chinya | 02-05-2024 
    * @param currentApplicationList 
    * @param shouldValidate 
    **/
    private void changeStageToApplicantSignature(List<genesis__Applications__c> currentApplicationList, String shouldValidate){
        if(shouldValidate == PortalConstants.SAVE_AND_CONTINUE 
            && currentApplicationList[0].Stage__c == PortalConstants.APPLICANT_INFORMATION){
                if(currentApplicationList[0].Is_Evergreen__c == false){
                    currentApplicationList[0].Stage__c = PortalConstants.APPLICANT_SIGNATURE;
                }else{
                    currentApplicationList[0].Stage__c = PortalConstants.SCORE_CREDIT_REFERENCE;
                }
            Database.update(currentApplicationList[0],true); 
        }
    }

    /**
    * @description This method will process the existing application.
    * @param paramMap 
    * @param coApplicants 
    * @param legalEntity 
    * @return genesis__Applications__c 
    **/
    private genesis__Applications__c processTheExistingApplication(Map<String, Object> paramMap, List<Map<String, Object>> coApplicants, String legalEntity){
        Account accountObj = new Account();
        Contact contactObj = new Contact();
        Contact priApplicantContactObj = new Contact();
        genesis__Business_Information__c businessInfoObj = new genesis__business_information__c();
        genesis__applications__c applicationObj = new genesis__Applications__c();
        List<genesis__Applications__c> currentApplicationList = new List<genesis__Applications__c>();
        Map<String, Object> validatedNewEDEFieldsMap = new Map<String, Object>();
        clcommon__Party__c borrowerParty=new clcommon__Party__c();

        accountObj = (Account)paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        contactObj = (Contact)paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        priApplicantContactObj = (Contact)paramMap.get(PortalConstants.PRIMARY_APPLICANT_KEY);
        applicationObj = (genesis__Applications__c)paramMap.get(PortalConstants.APPLICATION_OBJ_KEY);
        businessInfoObj = (genesis__Business_Information__c)paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        borrowerParty=(clcommon__Party__c) paramMap.get(PortalConstants.BORROWER_PARTY_NAME);
        applicationId = applicationObj.Id;

        validatedNewEDEFieldsMap = PortalApplicationCreationHandler.validateNewEDEFieldsMap(accountObj, businessInfoObj, legalEntity);
        if(!validatedNewEDEFieldsMap.isEmpty()){
            accountObj.Year_Began_Farming__c = (String)validatedNewEDEFieldsMap.get(PortalConstants.YEAR_BEGAN_FARMING_KEY);
            businessInfoObj.Gross_Farm_Income__c = (Double)validatedNewEDEFieldsMap.get(PortalConstants.GROSS_FARM_INCOME_KEY);
        }

        checkValidUser();
        //Query the Current Application
        currentApplicationList = [SELECT Id, 
                                        genesis__Contact__c,
                                        genesis__Account__c,
                                        Is_Evergreen__c, 
                                        Is_Evergreen_Eligible__c,
                                        Internal_Reference_Code__c,
                                        Sales_Agent__c,
                                        Sales_Agent__r.Name,
                                        genesis__Loan_Amount__c,
                                        Stage__c,
                                        genesis__Credit_Rating__r.Name
                                    FROM genesis__Applications__c
                                    WHERE Id = :applicationId];
        PortalApplicationOriginationHelper.checkEmptyList(currentApplicationList, PortalConstants.SOMETHING_WENT_WRONG);
        
        currentApplicationList[0].Sales_Agent__c = applicationObj.Sales_Agent__c;
        Database.update(currentApplicationList, true);

        changeStageToApplicantSignature(currentApplicationList, shouldValidate);        

        //EVERGREEN APPLICATION
        applicationObj = processForEvergreenApplication(new Map<String, Object>{
                            PortalConstants.ACCOUNT_OBJ_KEY => accountObj,
                            PortalConstants.CONTACT_OBJ_KEY => contactObj,
                            PortalConstants.APPLICATION_OBJ_KEY => applicationObj,
                            PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoObj
        }, currentApplicationList, coApplicants);
        
        //Evergreen application and it is already scored

        updateBorrower(new Map<String, Object>{
                                            PortalConstants.ACCOUNT_OBJ_KEY => accountObj,
                                            PortalConstants.CONTACT_OBJ_KEY => contactObj,
                                            PortalConstants.CURRENT_APPLICATION => currentApplicationList[0],
                                            PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoObj,
                                            PortalConstants.BORROWER_PARTY_NAME=> borrowerParty
                                        });


        accountObj = PortalApplicationCreationHandler.processBusinessAccount(new Map<String, Object>{
            PortalConstants.CONTACT_OBJ_KEY => contactObj,
            PortalConstants.ACCOUNT_OBJ_KEY => accountObj,
            PortalConstants.APPLICATION_OBJ_KEY => applicationObj,
            PortalConstants.ENTITY_KEY => legalEntity
        });
        if(legalEntity == PortalConstants.INDIVIDUAL_ENTITY){
            //Populate the Address from Primary CoApplicant if the account is DBA 
            accountObj = PortalApplicationOriginationHelper.addDBAAdress(coApplicants, accountObj,borrowerParty);
        }

        accountObj.ParentId=loggedInUser[0].Account.ParentId;

        Database.update(accountObj, true);

        PortalApplicationCreationHandler.processBusinessInfoOfBorrower(new Map<String,Object>{
                                                                                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoObj,
                                                                                        PortalConstants.ACCOUNT_OBJ_KEY=>accountObj.id,
                                                                                        PortalConstants.BORROWER_PARTY_NAME=>borrowerParty
                                                                                    });
        PortalApplicationOriginationHelper.uploadDocumentOnDocCategory(applicationObj.Id, PortalConstants.DRIVING_LICENSE_TASK);

        return applicationObj;
    }

   
    /**
    * @description 
    * @author Krishanu Chinya | 02-21-2024 
    * @param paramMap 
    **/
    private void updateBorrower(Map<String, Object> paramMap){
        List<Dealer_applicant_Relationship__c> dealerGrowerRelList=new List<Dealer_applicant_Relationship__c>();

        Account accountObj = (Account)paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        Contact contactObj = (Contact)paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        genesis__Applications__c currentApp = (genesis__Applications__c)paramMap.get(PortalConstants.CURRENT_APPLICATION);
        genesis__Business_Information__c businessInfoObj = (genesis__Business_Information__c)paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        clcommon__Party__c borrowerParty=(clcommon__Party__c) paramMap.get(PortalConstants.BORROWER_PARTY_NAME);

        Boolean shouldDeleteRedundantData=PortalConstants.FALSE_VALUE;
        Contact contactToDelete=new Contact();

        if (legalEntity == PortalConstants.SOLE_PROP_ENTITY) {
            List<Contact> currentContactList = [SELECT Id,
                                                        AccountId,
                                                        Account.genesis__Business_Information__c,
                                                        genesis__SSN__c
                                                FROM Contact
                                                WHERE Id =: currentApp.genesis__Contact__c];

            if(currentContactList[0].genesis__SSN__c != contactObj.genesis__SSN__c){
                contactObj = PortalValidationUtil.validateNewGrower(contactObj, dealerCoopType, loggedInUser[0].Account.ParentId);
                PortalValidationUtil.verifyUserForApplicant(currentContactList[0].id,contactObj.id);
            }

            //if contact is found from db
            if(currentContactList[0].Id != contactObj.Id){
                //if the new ssn already exist as a coapplicant
                PortalValidationUtil.checkForDuplicateCoapplicant(contactObj.Id, currentApp.Id);

                currentApp.genesis__Contact__c = contactObj.Id;
                currentApp.genesis__Account__c = contactObj.AccountId;
                
                accountObj.Id = contactObj.AccountId;

                shouldDeleteRedundantData=PortalConstants.TRUE_VALUE;
                contactToDelete=currentContactList[0];
                
                borrowerParty.clcommon__Account__c = contactObj.AccountId;

                List<Contact> newContact = [SELECT Id,
                                                    Account.genesis__business_information__c 
                                            FROM Contact 
                                            WHERE Id =: contactObj.Id];

                businessInfoObj.Id = newContact[0].Account.genesis__business_information__c;

                borrowerParty.clcommon__Contact__c = contactObj.Id;
            }
            PortalApplicationCreationHandler.checkIfKycVerified(contactObj,accountObj);
            Database.update(contactObj, true);
        }
        else if(legalEntity != PortalConstants.INDIVIDUAL_ENTITY){
            Account currentAccount=[SELECT Id, 
                                           genesis__business_information__r.genesis__Tax_Identification_Number__c
                                    FROM Account WHERE Id =: currentApp.genesis__Account__c];
            if(businessInfoObj.genesis__Tax_Identification_Number__c != currentAccount.genesis__business_information__r.genesis__Tax_Identification_Number__c){
                PortalValidationUtil.validateDuplicateCorporation(new Map<String,Object>{PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoObj,
                                                                                        PortalConstants.ACCOUNT_OBJ_KEY=>accountObj,
                                                                                        PortalConstants.DEALER_ID_KEY=>loggedInUser[0].Account.ParentId
                                                                                    });
            }

            //for - if only corporation name is changed
            List<Contact> contactForFoundAccount = [SELECT Id 
                                                    FROM Contact 
                                                    WHERE AccountId =: accountObj.Id];
            contactObj.Id = contactForFoundAccount[0].Id;
            contactObj.LastName = accountObj.Name;

            if(currentAccount.Id != accountObj.Id){
                contactObj.AccountId = accountObj.Id;
                currentApp.genesis__Account__c = accountObj.Id;
                currentApp.genesis__Contact__c = contactObj.Id;

                List<Contact> currentContactList = [SELECT Id,
                                                            Account.genesis__Business_Information__c
                                                    FROM Contact
                                                    WHERE AccountId =: currentAccount.Id];

                shouldDeleteRedundantData=PortalConstants.TRUE_VALUE;
                contactToDelete=currentContactList[0];

                borrowerParty.clcommon__Account__c = contactObj.AccountId;

                List<Contact> newContact = [SELECT Id,
                                                    Account.genesis__business_information__c 
                                            FROM Contact 
                                            WHERE Id =: contactObj.Id];

                businessInfoObj.Id = newContact[0].Account.genesis__business_information__c;

                borrowerParty.clcommon__Contact__c = contactObj.Id;

            }

            PortalApplicationCreationHandler.populateCorporationContact(contactObj,accountObj);

            PortalApplicationCreationHandler.checkIfKycVerified(contactObj,accountObj);
            Database.update(contactObj, true);

        }

        accountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId();
        Database.update(accountObj, true);

        dealerGrowerRelList=[SELECT ID 
                            FROM Dealer_Applicant_Relationship__c 
                            WHERE Dealer__c=:loggedInUser[0].Account.ParentId 
                            AND Applicant__c=:accountObj.id];
        if(dealerGrowerRelList.isEmpty()){
            Dealer_Applicant_Relationship__c dealerGrowerRelObj=PortalApplicationCreationHandler.createDealerApplicantRelationship(new Map<String,Object>{
                                                                                                                                                            PortalConstants.LOGGED_IN_USER=>loggedInUser[0],
                                                                                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactObj,
                                                                                                                                                            PortalConstants.ACCOUNT_OBJ_KEY=>accountObj
                                                                                                                                                        });
            dealerGrowerRelList.add(dealerGrowerRelObj);
            Database.insert(dealerGrowerRelList,true);
            
        }
        borrowerParty.Dealer_Applicant_Relationship__c=dealerGrowerRelList[0].id;
        currentApp.Dealer_Applicant_Relationship__c=dealerGrowerRelList[0].id;

        Database.update(currentApp, true);

        if(shouldDeleteRedundantData == PortalConstants.TRUE_VALUE){
            PortalApplicationCreationHandler.deleteRedundantAccountAndContact(contactToDelete, applicationId,loggedInUser[0]);
        }
        Database.update(borrowerParty, true);
    }
    
    

   
    /**
    * @description 
    * @author Krishanu Chinya | 02-19-2024 
    * @param paramMap 
    * @param currentApplicationList 
    * @param coApplicants 
    * @return genesis__Applications__c 
    **/
    private genesis__Applications__c processForEvergreenApplication(Map<String, Object> paramMap,
                                                                            List<genesis__Applications__c> currentApplicationList,
                                                                            List<Map<String, Object>> coApplicants){
                            
        Contact contactObj = new Contact();
        Account accountObj = new Account();
        genesis__Business_Information__c businessInfoObj = new genesis__business_information__c();
        genesis__applications__c applicationObj = new genesis__Applications__c();
        Integer partyCount=0;
        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();

        accountObj = (Account)paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        contactObj = (Contact)paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        applicationObj = (genesis__Applications__c)paramMap.get(PortalConstants.APPLICATION_OBJ_KEY);
        businessInfoObj = (genesis__Business_Information__c)paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);

        //if current app is not evergreen
        if(!currentApplicationList[0].Is_Evergreen__c){
            return applicationObj;
        }
        fieldsMap.put(EVERGREEN_FLAG,false);
        //Process if the application is evergreen elligible

        partyList = [SELECT Id,
                                clcommon__Contact__r.FirstName,
                                clcommon__Contact__r.LastName,
                                clcommon__Account__r.Name,
                                clcommon__Contact__r.genesis__SSN__c,
                                clcommon__Contact__r.Email,
                                clcommon__Account__r.clcommon__Email__c,
                                clcommon__Account__r.genesis__Business_Information__r.genesis__Tax_Identification_Number__c,
                                clcommon__Account__r.genesis__Business_Information__r.genesis__State_of_Incorporation__c,
                                clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                clcommon__Party_Types__c
                        FROM clcommon__Party__c
                        WHERE clcommon__Party_Types__c IN (:PortalConstants.BORROWER_PARTY_NAME,:PortalConstants.PRINCIPAL_PARTY_NAME) AND 
                        clcommon__Account__c != null AND 
                        clcommon__Contact__c != null AND 
                        genesis__Application__C = :applicationId];
        
        PortalApplicationOriginationHelper.checkEmptyList(partyList, PortalConstants.SOMETHING_WENT_WRONG);
                                                
        //Check if any more party is added as principals in the loan
        partyCount = PortalApplicationCreationHandler.getPrincipalPartyCount(partyList);
        if(!String.isBlank(coApplicantRecord) && coApplicants.size() != partyCount){
            // CoApplicants are added, which makes the application - NonEvergreen 
            applicationObj.Is_Evergreen__c = false;
            fieldsMap.put(EVERGREEN_FLAG,true);
        }
        else{
            Map<String,Map<String,Object>> coApplicantMap = new Map<String,Map<String,Object>>();
            for (Map<String, Object> eachCoApplicant : coApplicants) {
                coApplicantMap.put((String)eachCoApplicant.get(PortalConstants.ID_KEY),eachCoApplicant);
            }

            Map<String, Object> paramForEvergreenCheckMap = new Map<String, Object>{
                PortalConstants.ACCOUNT_OBJ_KEY => accountObj,
                PortalConstants.CONTACT_OBJ_KEY => contactObj,
                PortalConstants.APPLICATION_OBJ_KEY => applicationObj,
                PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoObj
            };
            coApplicantMap.put(PortalConstants.FIELDS_MAP_KEY , fieldsMap);
            fieldsMap = PortalApplicationCreationHandler.checkEvergreenForBorrower(partyList, paramForEvergreenCheckMap, coApplicantMap);
            applicationObj = (genesis__Applications__c)fieldsMap.get(PortalConstants.APPLICATION_OBJ_KEY);
        }
        return applicationObj;
    }

    
    /**
    * @description : this method checks whether current logged in user has access to the application
    * @author Krishanu Chinya | 02-05-2024 
    **/
    private void checkValidUser(){

        Boolean isValidUser = false;
        if (String.isEmpty(applicationId)) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        isValidUser = PortalSecurityUtil.validateUserApplication(applicationId); 
        if (!isValidUser) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }
    }

}