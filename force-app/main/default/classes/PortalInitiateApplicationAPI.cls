/**
 * @description       : purpose of this class is to create an application from the initiate application tab
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 04-07-2025
 * @last modified by  : Ayush Kumar Singh
**/

global without sharing class PortalInitiateApplicationAPI implements clcommon.PortalCustomRemoteAPI1{

    //Constant Values Specific to the Class
    private final String CLASS_NAME = PortalInitiateApplicationAPI.class.getName();  
    private static final String GENESIS_ACCOUNT_KEY ='genesis__account__c';
    private static final String GENESIS_CONTACT_KEY ='genesis__Contact__c';

    //Global Variables
    String legalEntity = PortalConstants.EMPTY_STRING;
    String shouldValidate = PortalConstants.EMPTY_STRING;
    Dealer_Applicant_Relationship__c dealerApplicantRelObj=new Dealer_Applicant_Relationship__c();

    List<User> loggedInUser = new List<User>();
    Map<String, Id> mapOfLegalEntity = new Map<String, Id>();


    List<clcommon.PortalCustomRemoteActionRecord> responseDataList = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();
    Map<String, Object> fieldsMap = new Map<String, Object>();
    Map<String, SObject> relatedObjectsMap = new Map<String, SObject>();

   
    /**
     * @description : constructor that initialises the necesary maps
     */
    global PortalInitiateApplicationAPI() {
        this.mapOfLegalEntity = PortalApplicationOriginationHelper.getLegalEntityMap();
        this.loggedInUser = PortalApplicationOriginationHelper.getLoggedInUser(); 
    }

    /**
     * @description : creates a new application based on the save type
     * @param componentStrName 
     * @param disclosureNames 
     * @param argumentsFromPortal 
     * @return  `clcommon.Response`
     */
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames,Map<String, Object> argumentsFromPortal){

        //initiating the required objects
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        Account accountObj = new Account(); 
        Contact contactObj = new Contact();
        Contact priApplicantContactObj = new Contact();
        genesis__Business_Information__c businessInfoObj = new genesis__Business_Information__c();
        String dealerCoopType = PortalConstants.EMPTY_STRING;
        Map<String,Object> appIdMapForFlowParam = new Map<String,Object>();
        String application = PortalConstants.EMPTY_STRING;
        String primaryApplicantContact = PortalConstants.EMPTY_STRING;
        String primaryApplicantAccount = PortalConstants.EMPTY_STRING;
        String primaryApplicantBusiness = PortalConstants.EMPTY_STRING;


        SavePoint dbSavePoint = Database.setSavepoint();
        try{

            //fetching the required arguents 
            application = String.valueOf(argumentsFromPortal.get(PortalConstants.APPLICATION_KEY));
            primaryApplicantAccount = String.valueOf(argumentsFromPortal.get(PortalConstants.PRIMARY_APPLICANT_ACCOUNT_KEY));
            primaryApplicantContact = String.valueOf(argumentsFromPortal.get(PortalConstants.PRIMARY_APPLICANT_CONTACT_KEY));
            primaryApplicantBusiness = String.valueOf(argumentsFromPortal.get(PortalConstants.PRIMARY_APPLICANT_BUSINESS_INFO_KEY));

            PortalApplicationCreationHandler.checkNecessaryParam(application, primaryApplicantAccount);
            applicationObj = (genesis__Applications__c) Json.deserialize(application, genesis__Applications__c.class);
            
            //sole prop - grower account details
            //dba - dba details
            //entity - entity details
            accountObj = (Account) Json.deserialize(primaryApplicantAccount, Account.class);
            if (!String.isBlank(primaryApplicantContact)) {
                //sole prop - grower contact details
                //dba - primary co-applicant details
                //entity - primary co-applicant details
                contactObj = (Contact) Json.deserialize(primaryApplicantContact, Contact.class);
            }
            if (!String.isBlank(primaryApplicantBusiness)) {
                businessInfoObj = (genesis__Business_Information__c) Json.deserialize(primaryApplicantBusiness, genesis__Business_Information__c.class);
            }

            //setting whether it is a new applicant or existing
            checkForNewOrExistingBuyer(accountObj.Id);

            //Getting the Legal entity for the Applicant
            legalEntity = PortalApplicationOriginationHelper.getLegalEntityByAccount(accountObj);  

            //validating
            // Map<String, Object> paramForValidationMap = ;
            PortalValidationUtil.validateApplicationData(new Map<String, Object>{
                                                                            PortalConstants.ACCOUNT_OBJ_KEY => accountObj,
                                                                            PortalConstants.CONTACT_OBJ_KEY => contactObj,
                                                                            PortalConstants.KEY_SHOULD_VALIDATE => shouldValidate,
                                                                            PortalConstants.APPLICATION_OBJ_KEY => applicationObj,
                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoObj
                                                                        });

            dealerCoopType = loggedInUser[0].Account.Parent.Coop_Type__c;

            // Map<String, Object> paramForApplicationMap = ;
            applicationObj = createNewApplication(new Map<String, Object>{
                                                                        PortalConstants.ACCOUNT_OBJ_KEY => accountObj,
                                                                        PortalConstants.CONTACT_OBJ_KEY => contactObj,
                                                                        PortalConstants.PRIMARY_APPLICANT_KEY => priApplicantContactObj,
                                                                        PortalConstants.APPLICATION_OBJ_KEY => applicationObj,
                                                                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoObj
                                                                    }, dealerCoopType);
                    
            //creating all the necessary parties for the application
            Map<String, Object> paramForDealerPartyMap = new Map<String, Object>{
                PortalConstants.LOGGED_IN_USER => loggedInUser[0],
                PortalConstants.APPLICATION_OBJ_KEY => applicationObj
            };
            PortalApplicationCreationHandler.linkDealerPartyToApplication(paramForDealerPartyMap);

            if(shouldValidate==PortalConstants.NEW_APPLICANT && legalEntity != PortalConstants.SOLE_PROP_ENTITY){
                PortalApplicationCreationHandler.createPrimaryApplicantParty(new Map<String,Object>{PortalConstants.LOGGED_IN_USER=>loggedInUser[0],
                                                                                                    PortalConstants.APPLICATION_OBJ_KEY=>applicationObj,
                                                                                                    PortalConstants.CONTACT_OBJ_KEY=>priApplicantContactObj,
                                                                                                    PortalConstants.DEALER_COOP_TYPE_KEY=>dealerCoopType});

                //assign CIF to co-appliacant
                assignCIFtoPrimaryApplicant(priApplicantContactObj.AccountId,dealerCoopType);
            }
            
            //to set the contact in the borrower party
            PortalApplicationCreationHandler.updateBorrowerDetails(new Map<String,Object>{
                                                                                    PortalConstants.CONTACT_OBJ_KEY=>contactObj,
                                                                                    PortalConstants.ACCOUNT_OBJ_KEY=>accountObj,
                                                                                    PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoObj,
                                                                                    PortalConstants.APPLICATION_KEY=>applicationObj,
                                                                                    PortalConstants.ID_KEY=>dealerApplicantRelObj.id
                                                                                });
            
            if (shouldValidate == PortalConstants.EXISTING_APPLICANT) {
                //Copy the Additional Information Parties from the existing application
                PortalApplicationOriginationHelper.copyAdditionalPartyDetails(applicationObj,accountObj);

                //Update the Coop Type and record type  for all the Principal i.e coapplicants
                PortalApplicationCreationHandler.updatePrincipalParties(applicationObj.Id, dealerCoopType,loggedInUser[0]);
            }
            //------------------
            PortalApplicationCreationHandler.checkForNonAccrualAndHasPastDue(applicationObj);
            //------------------
            //Call flow inorder to update the Approved Loan Amount of the dealer
            Flow.Interview.Update_Dealer_Limits_On_Creation callFlow;
            appIdMapForFlowParam.put(PortalConstants.APPLICATION_ID,applicationObj.Id);
            callFlow = new Flow.Interview.Update_Dealer_Limits_On_Creation(appIdMapForFlowParam);
            callFlow.start();            

            fieldsMap.put(PortalConstants.BORROWER_ENTITY_TYPE, legalEntity);
            responseDataList.add(new clcommon.PortalCustomRemoteActionRecord(fieldsMap));
            clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(responseDataList);
            response.content = null;
            response.response = responseFormat.response;
            response.status = clcommon.Constants.SUCCESS;

        } catch (CustomException CustomExceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = CustomExceptionObj.getMessage();
            PortalHelper.saveExceptionLog(CustomExceptionObj, CLASS_NAME);
        } catch (Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(exceptionObj, CLASS_NAME);
        }
        return response;
    }

    /**
    * @description : this method assigns a CIF to the primary coapplicant of entity
    * @author Krishanu Chinya | 03-28-2024 
    * @param primaryApplicantAccId 
    * @param dealerCoopType 
    **/
    private void assignCIFtoPrimaryApplicant (Id primaryApplicantAccId, String dealerCoopType){
        List<Account> primaryApplicantAccIdList = [SELECT Id
                                                    FROM Account
                                                    WHERE Id =: primaryApplicantAccId];
                                                    
        PortalApplicationOriginationHelper.checkEmptyList(primaryApplicantAccIdList, PortalConstants.SOMETHING_WENT_WRONG);
        PortalApplicationCreationHandler.updateCifForAccount(primaryApplicantAccIdList[0], dealerCoopType);
    }

    
    /**
    * @description : checks whether the borrower is new or existing
    * @author Krishanu Chinya | 02-28-2024 
    * @param accountId 
    **/
    private void checkForNewOrExistingBuyer (Id accountId){
        if(String.isBlank(accountId)){
            shouldValidate = PortalConstants.NEW_APPLICANT;
        }else{
            shouldValidate = PortalConstants.EXISTING_APPLICANT;
        }
    }

    
    /**
    * @description 
    * @author Krishanu Chinya | 02-19-2024 
    * @param paramMap 
    * @param dealerCoopType 
    * @return genesis__Applications__c 
    **/
    private genesis__Applications__c createNewApplication(Map<String, Object> paramMap, String dealerCoopType){

        Account accountObj = (Account)paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        Contact contactObj = (Contact)paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        Contact priApplicantContact = (Contact)paramMap.get(PortalConstants.PRIMARY_APPLICANT_KEY);
        genesis__applications__c applicationObj = (genesis__Applications__c)paramMap.get(PortalConstants.APPLICATION_OBJ_KEY);
        genesis__Business_Information__c businessInfoObj = (genesis__Business_Information__c)paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);

        if (shouldValidate == PortalConstants.NEW_APPLICANT) {
            //sole prop
            if (legalEntity == PortalConstants.SOLE_PROP_ENTITY) {
                contactObj = PortalValidationUtil.validateNewGrower(contactObj, dealerCoopType, loggedInUser[0].Account.ParentId);
                accountObj.clcommon__Legal_Entity_Type__c = mapOfLegalEntity.get(PortalConstants.SOLE_PROP_ENTITY);
                PortalApplicationCreationHandler.populateNecessaryAccountDetails(accountObj, contactObj);
                PortalApplicationCreationHandler.updateBusinessInfo(contactObj.id, businessInfoObj);

            } 
            //dba
            else if (legalEntity == PortalConstants.INDIVIDUAL_ENTITY) {
                PortalValidationUtil.validateNewCoApplicant(contactObj,dealerCoopType);
                PortalApplicationOriginationHelper.populateDBAApplicant(accountObj,priApplicantContact,contactObj);
            } 
            //company
            else {
                PortalValidationUtil.validateDuplicateCorporation(new Map<String,Object>{
                                                                                    PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoObj,
                                                                                    PortalConstants.ACCOUNT_OBJ_KEY=>accountObj,
                                                                                    PortalConstants.DEALER_ID_KEY=>loggedInUser[0].Account.ParentId
                                                                                    });
                PortalValidationUtil.validateNewCoApplicant(contactObj,dealerCoopType);
                PortalApplicationOriginationHelper.populateCorporationCoApplicant(accountObj,priApplicantContact,contactObj);

                //if account existed in the system, use same account, contact
                if(accountObj.Id != null || !String.isBlank(accountObj.Id)){
                    List<Contact> existingContactList = [SELECT Id 
                                                         FROM Contact 
                                                         WHERE AccountId =:accountObj.Id ];
                    PortalApplicationOriginationHelper.checkEmptyList(existingContactList, PortalConstants.SOMETHING_WENT_WRONG);
                    contactObj.Id = existingContactList[0].Id;
                }
            }

            PortalApplicationCreationHandler.checkIfKycVerified(contactObj,accountObj);

            dealerApplicantRelObj=createDealerGrowerRelationship(contactObj,accountObj);

            //Update CIF Number only when the Borrower is new
            PortalApplicationCreationHandler.updateCifForAccount(accountObj, dealerCoopType);

            //setting account record type
            accountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId();
            accountObj.Coop_Type__c = dealerCoopType;

            relatedObjectsMap.put(GENESIS_ACCOUNT_KEY, accountObj);
            relatedObjectsMap.put(PortalConstants.GENESIS_BUSINESS_INFORMATION_KEY, businessInfoObj); 
            relatedObjectsMap.put(GENESIS_CONTACT_KEY, contactObj);

        } else if(shouldValidate == PortalConstants.EXISTING_APPLICANT){
            List<Contact> existingContactList = [SELECT Id
                                                FROM Contact
                                                WHERE AccountId =: accountObj.Id];

            List<Dealer_Applicant_Relationship__c> dealerApplicantRelList=[ SELECT ID
                                                                            FROM Dealer_Applicant_Relationship__c
                                                                            WHERE Dealer__c= :loggedInUser[0].Account.ParentId
                                                                            AND Applicant__c= :accountObj.id
                                                                            LIMIT 1];
            
            PortalApplicationOriginationHelper.checkEmptyList(existingContactList, PortalConstants.SOMETHING_WENT_WRONG);
            PortalApplicationOriginationHelper.checkEmptyList(dealerApplicantRelList, PortalConstants.SOMETHING_WENT_WRONG);
            applicationObj.genesis__Account__c = accountObj.Id;
            applicationObj.genesis__Contact__c = existingContactList[0].Id;
            dealerApplicantRelObj=dealerApplicantRelList[0];
            applicationObj.Dealer_Applicant_Relationship__c = dealerApplicantRelList[0].Id;
        }
        
        //Assigning the defaults to the Application
        applicationObj = PortalApplicationOriginationHelper.addDefaultValuesToApplication(applicationObj);
        applicationObj = PortalApplicationOriginationHelper.disableApplicantFields(applicationObj,accountObj);

        //adding erp id to application
        //applicationObj.ERP_Id__c = PortalApplicationCreationHandler.getErpId(accountObj.Id, loggedInUser[0].Account.ParentId);
        Map<String,String> identifierMap = PortalApplicationCreationHandler.getIdentifierMap(accountObj.Id, loggedInUser[0].Account.ParentId);
        applicationObj.ERP_Id__c = identifierMap.get('erpId');
        applicationObj.Unique_Identifier__c = identifierMap.get('uniqueId');
        applicationObj.Internal_Reference_Code__c = identifierMap.get('irc');

        //creating app and adding the account in the Borrower party
        genesis.BorrowerAPI5 saveAPI = genesis.APIFactory.getBorrowerAPI5();
        genesis__Applications__c appCreated = saveAPI.createApplication(applicationObj, 
                                                                        relatedObjectsMap, 
                                                                        new Map<String, List<Map<String, String>>>(), 
                                                                        false);
                                                                        
        PortalApplicationOriginationHelper.throwErrorIfTrue(appCreated.Id==null,PortalConstants.SOMETHING_WENT_WRONG);

        updateDealerApplicantRel(applicationObj, accountObj,contactObj);
        
        fieldsMap.put(PortalConstants.APPLICATION_ID, appCreated.Id );
        return applicationObj;
    }

    /**
    * @description updates the dealer applicant relationship object with the values of the the grower account and contact after they have been inserted in the
                    by the saveAPI.createApplication method called above. Simultaneously updating the application with the dealer applicant relationship record id
    * @author Rakesh Saraf | 11-26-2024 
    * @param applicationObj 
    * @param accountObj 
    * @param contactObj 
    **/
    private void updateDealerApplicantRel(genesis__Applications__c applicationObj,Account accountObj, Contact contactObj){
        if (shouldValidate == PortalConstants.NEW_APPLICANT){
            dealerApplicantRelObj.Applicant__c=accountObj.id;
            dealerApplicantRelObj.Applicant_Contact__c=contactObj.id;
            Database.upsert(dealerApplicantRelObj,true);

            applicationObj.Dealer_Applicant_Relationship__c=dealerApplicantRelObj.id;
            Database.update(applicationObj,true);
        }
    }

     /**
    * @description this method created a dealer applicant relationship for the borrower if it does not exist.
    * @author Rakesh Saraf | 01-09-2025 
    * @param contactObj 
    * @param accountObj 
    * @return Dealer_Applicant_Relationship__c 
    **/
    public Dealer_Applicant_Relationship__c createDealerGrowerRelationship(Contact contactObj,Account accountObj){
        Dealer_Applicant_Relationship__c dealerApplicantRelObj;
        if(contactObj.id==null){
            //getting the id for the dealer applicant relationship record for the new applicant
            dealerApplicantRelObj=PortalApplicationCreationHandler.createDealerApplicantRelationship(new Map<String,Object>{ PortalConstants.LOGGED_IN_USER=>loggedInUser[0],
                                                                                                                             PortalConstants.CONTACT_OBJ_KEY=>contactObj,
                                                                                                                             PortalConstants.ACCOUNT_OBJ_KEY=>accountObj});

        } else {
            List<Dealer_Applicant_Relationship__c> dealerGrowerRelList=[SELECT Id,
                                                                                Has_Past_Due__c,
                                                                                Is_Non_Accrual__c,
                                                                                Is_Evergreen_Eligible__c
                                                                        FROM Dealer_Applicant_Relationship__c
                                                                        WHERE (Applicant_Contact__c= :contactObj.id
                                                                            OR Applicant__c= :accountObj.id)
                                                                        AND Dealer__c= :loggedInUser[0].Account.ParentId];

            if(dealerGrowerRelList.isEmpty()){
                dealerApplicantRelObj=PortalApplicationCreationHandler.createDealerApplicantRelationship(new Map<String,Object>{PortalConstants.LOGGED_IN_USER=>loggedInUser[0],
                                                                                                                                PortalConstants.CONTACT_OBJ_KEY=>contactObj,
                                                                                                                                PortalConstants.ACCOUNT_OBJ_KEY=>accountObj});
            }else{
                dealerApplicantRelObj=dealerGrowerRelList[0];
            }
            
        }
        return dealerApplicantRelObj;
    }
    
}