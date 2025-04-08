/**
 * @description       : This API helps in creating a new application, a new grower user.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 04-07-2025
 * @last modified by  : Rakesh Saraf
**/
global without sharing class PortalSendApplicationToGrowerAPI implements clcommon.PortalCustomRemoteAPI1{
    
    private static final String PORTAL_SEND_APPLICATION_TO_GROWER_API = PortalSendApplicationToGrowerAPI.class.getName();
    private static final String KEY_FIRST_NAME = 'firstName';
    private static final String KEY_LAST_NAME = 'lastName';
    private static final String NEW_APPLICANT ='SendToGrower';
    private static final String KEY_ENTITY_TYPE = 'entityType';
    private static final String KEY_SSN = 'genesis__SSN__c';
    private static final String KEY_CONFIRM_EMAIL = 'Confirm_Email__c';
    private static final String KEY_CONFIRM_SSN = 'Confirm_SSN__c';
    private static final String KEY_CONFIRM_TIN = 'Confirm_Tax_Identification_Number__c';
    private static final String KEY_TIN = 'genesis__Tax_Identification_Number__c';
    private static final String KEY_COMPANY_NAME = 'companyName';
    private static final String KEY_DBA_NAME = 'DBAName';
    private static final String KEY_EXISTING_GROWER_ACCOUNT_ID = 'accountId';
    private static final String KEY_MOBILE_NUMBER = 'MobilePhone';
    private static final String KEY_WORK_NUMBER = 'Phone';
    private static final String KEY_HOME_NUMBER = 'HomePhone';
    private static final String KEY_ACC_CON_OBJ = 'accConObj';
    private static final String KEY_NAME_MAP = 'nameMap';
    private static final String KEY_NUMBERS_MAP = 'numbersMap';
    private static final String KEY_SSN_EMAIL_TIN_MAP = 'ssnEmailTinMap';
    private static final String KEY_NEW_PORTAL_USER = 'newPortalUser';
    private static final String KEY_EXISTING_APP_ID = 'existingApplicationId';
    private static final String SEND_APP_TO_GROWER = 'SEND_APP_TO_GROWER';

    Decimal loanAmount;

    // One map for storing first name and last name
    Map<String, String> nameMap ;
    String companyName = PortalConstants.EMPTY_STRING;
    String dbaName = PortalConstants.EMPTY_STRING;
    String entityType = PortalConstants.EMPTY_STRING;
    String applicationId = PortalConstants.EMPTY_STRING;

    // One Map to store TIN, SSN and Email
    Map<String, String> ssnEmailTinMap;
    String existingAccountId = PortalConstants.EMPTY_STRING;

    // One map for all numbers  
    Map<String, String> numbersMap ;
    
    Map<String, Id> mapOfpartyType = new Map<String, Id>();
    List<User> loggedInUser = new List<User>();
    List<clcommon.PortalCustomRemoteActionRecord> respData = new List<clcommon.PortalCustomRemoteActionRecord>();
    Map<String, Object> fields = new Map<String, Object>();
    clcommon.Response response = new clcommon.Response();
    Map<String, SObject> relatedObjects = new Map<String, SObject>();

    /**
     * @description The purpose of the constructor is to assign neccesary variable.
     */
    global PortalSendApplicationToGrowerAPI() {

        this.mapOfpartyType = PortalApplicationOriginationHelper.getPartyTypeMap();
        this.loggedInUser = PortalApplicationOriginationHelper.getLoggedInUser(); 
    }

    /**
     * @description This is the invoke action method.
     * @param componentStrName 
     * @param disclosureNames 
     * @param argumentsFromPortal 
     * @return  `clcommon.Response`
     */
    global clcommon.Response invokeAction(String componentStrName, String[] disclosureNames, Map<String, Object> argumentsFromPortal)  {
        SavePoint dbSavePoint = Database.setSavepoint();
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        genesis__Business_Information__c businessInfoObj = new genesis__Business_Information__c();
        Account accountObj = new Account();
        Contact contactObj = new Contact();
        New_Portal_User__e newPortalUser = new New_Portal_User__e();
        Dealer_Applicant_Relationship__c dealerApplicantRelObj=new Dealer_Applicant_Relationship__c();


        try {
            existingAccountId = String.valueOf(argumentsFromPortal.get(KEY_EXISTING_GROWER_ACCOUNT_ID));
            loanAmount = (Decimal)argumentsFromPortal.get(PortalConstants.LOAN_AMOUNT);

            nameMap = new Map<String, String>{ KEY_FIRST_NAME=> String.valueOf(argumentsFromPortal.get(KEY_FIRST_NAME)),
                                                KEY_LAST_NAME=> String.valueOf(argumentsFromPortal.get(KEY_LAST_NAME))};

            ssnEmailTinMap = new Map<String, String>{PortalConstants.EMAIL_KEY=> String.valueOf(argumentsFromPortal.get(PortalConstants.EMAIL_KEY)),
                                                    KEY_TIN=> String.valueOf(argumentsFromPortal.get(KEY_TIN)),
                                                    KEY_SSN=> String.valueOf(argumentsFromPortal.get(KEY_SSN)),
                                                    KEY_CONFIRM_SSN=> String.valueOf(argumentsFromPortal.get(KEY_CONFIRM_SSN)),
                                                    KEY_CONFIRM_EMAIL=> String.valueOf(argumentsFromPortal.get(KEY_CONFIRM_EMAIL)),
                                                    KEY_CONFIRM_TIN=> String.valueOf(argumentsFromPortal.get(KEY_CONFIRM_TIN))
                                                };

            entityType = String.valueOf(argumentsFromPortal.get(KEY_ENTITY_TYPE));
            companyName = String.valueOf(argumentsFromPortal.get(KEY_COMPANY_NAME));
            dbaName = String.valueOf(argumentsFromPortal.get(KEY_DBA_NAME));
            
            numbersMap=new Map<String, String>{ KEY_MOBILE_NUMBER=> String.valueOf(argumentsFromPortal.get(KEY_MOBILE_NUMBER)),
                                                KEY_WORK_NUMBER=> String.valueOf(argumentsFromPortal.get(KEY_WORK_NUMBER)),
                                                KEY_HOME_NUMBER=> String.valueOf(argumentsFromPortal.get(KEY_HOME_NUMBER)) };

            String coopType = loggedInUser[0].Account.Parent.Coop_Type__c;

            //setting the loan amount in application
            applicationObj.genesis__Loan_Amount__c = loanAmount;

            //Assigning the defaults to the Application
            applicationObj = PortalApplicationOriginationHelper.addDefaultValuesToApplication(applicationObj);


            processForNewApplicant(new Map<String, Object>{
                                                        PortalConstants.ACCOUNT_OBJ_KEY => accountObj,
                                                        PortalConstants.CONTACT_OBJ_KEY => contactObj,
                                                        PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoObj
                                                    }, coopType);

            
            processForExistingApplicant(new Map<String, Object>{
                                                            PortalConstants.ACCOUNT_OBJ_KEY => accountObj,
                                                            PortalConstants.CONTACT_OBJ_KEY => contactObj,
                                                            KEY_NEW_PORTAL_USER => newPortalUser,
                                                            PortalConstants.APPLICATION_OBJ_KEY => applicationObj
                                                        });
           
            //applicationObj.ERP_Id__c = PortalApplicationCreationHandler.getErpId(accountObj.Id, loggedInUser[0].Account.ParentId);
            Map<String,String> identifierMap = PortalApplicationCreationHandler.getIdentifierMap(accountObj.Id, loggedInUser[0].Account.ParentId);
            applicationObj.ERP_Id__c = identifierMap.get('erpId');
            applicationObj.Unique_Identifier__c = identifierMap.get('uniqueId');
            applicationObj.Internal_Reference_Code__c = identifierMap.get('irc');
            applicationObj = PortalApplicationOriginationHelper.disableApplicantFields(applicationObj, accountObj);

            genesis.BorrowerAPI5 saveAPI = genesis.APIFactory.getBorrowerAPI5();
            genesis__Applications__c appCreated = saveAPI.createApplication(applicationObj, 
                                                                            relatedObjects, 
                                                                            new Map<String, List<Map<String, String>>>(), 
                                                                            false); 

            accountObj.OwnerId = PortalSecurityUtil.getSiteAdmin();

            dealerApplicantRelObj=processDealerApplicantRelationship(new Map<String,Object>{PortalConstants.CONTACT_OBJ_KEY=>contactObj,
                                                                      PortalConstants.ACCOUNT_OBJ_KEY=>accountObj,
                                                                      PortalConstants.APPLICATION_OBJ_KEY=>applicationObj,
                                                                      PortalConstants.APPLICANT_DEALER_RELATION_KEY=> dealerApplicantRelObj});

            if (appCreated.Id != null) {
                fields.put(PortalConstants.APPLICATION_ID, appCreated.Id);
                applicationId = appCreated.Id;
            }
            
            PortalApplicationCreationHandler.linkDealerPartyToApplication(new Map<String, Object>{
                                                                                                PortalConstants.LOGGED_IN_USER => loggedInUser[0],
                                                                                                PortalConstants.APPLICATION_OBJ_KEY => applicationObj,
                                                                                                PortalConstants.KEY_PRIMARY_APPLICANT => null,
                                                                                                PortalConstants.KEY_CREATE_PRIMARY_APPLICANT => true
                                                                                            });

            PortalApplicationCreationHandler.updateBorrowerDetails(new Map<String,Object>{
                                                                                        PortalConstants.CONTACT_OBJ_KEY=>contactObj,
                                                                                        PortalConstants.ACCOUNT_OBJ_KEY=>accountObj,
                                                                                        PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoObj,
                                                                                        PortalConstants.APPLICATION_KEY=>applicationObj,
                                                                                        PortalConstants.ID_KEY=>dealerApplicantRelObj.id
                                                                                    });

            //Call flow inorder to update the Approved Loan Amount of the dealer
            Flow.Interview.Update_Dealer_Limits_On_Creation callFlow;
            Map<String, Object> applicationIdMap = new Map<String, Object>();
            applicationIdMap.put(PortalConstants.APPLICATION_ID, applicationId);
            callFlow = new Flow.Interview.Update_Dealer_Limits_On_Creation(applicationIdMap);
            callFlow.start();           


            newPortalUser = processPrincipalForNewApplicant(applicationObj, new Map<String, Object>{
                                                                                                KEY_NEW_PORTAL_USER => newPortalUser,
                                                                                                PortalConstants.ACCOUNT_OBJ_KEY => accountObj,
                                                                                                PortalConstants.CONTACT_OBJ_KEY => contactObj
                                                                                            });

            if(!String.isBlank(existingAccountId)){
                newPortalUser = processPrincipalForExistingApplicant(newPortalUser, appCreated);
                PortalApplicationCreationHandler.updatePrincipalPartyDetails(applicationObj,loggedInUser);
            }

            newPortalUser = PortalApplicationCreationHandler.assigningProfileToNewUser(newPortalUser, coopType); 
            

            //------------------
            PortalApplicationCreationHandler.verifyExistingAccounts(appCreated);
            //------------------
            //Get all the Principal Party Account and update the Coop Type------------------------------------------------
            PortalApplicationOriginationHelper.updatePrincipalCoopType(appCreated.Id);

            //send email to grower when dealer sends the grower an application to complete.
            PortalApplicationOriginationHelper.sendEmailToGrower(newPortalUser.Account_Id__c,ssnEmailTinMap.get(PortalConstants.EMAIL_KEY),appCreated);  

            // Call method to publish events
            publishEventForNewPortaluser(newPortalUser);
            response.status = clcommon.Constants.SUCCESS;
        } catch (CustomException objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objException.getMessage();
            PortalHelper.saveExceptionLog(objException, PORTAL_SEND_APPLICATION_TO_GROWER_API);
        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;     
            PortalHelper.saveExceptionLog(objException, PORTAL_SEND_APPLICATION_TO_GROWER_API);      
        }
        return response;
    }

    /**
     * @description The purpose of this method is to publish the portal for new user.
     * @param newPortalUser 
     */
    private void publishEventForNewPortaluser(New_Portal_User__e newPortalUser){
        Database.SaveResult result = EventBus.publish(newPortalUser);
        if (!(result.isSuccess())) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
    }

    /**
     * @description The purpose of this method is to process for new applicant.
     * @param paramMap 
     * @param coopType 
     */
    private void processForNewApplicant(Map<String, Object> paramMap, String coopType){
        Account accountObj = (Account)paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        Contact contactObj = (Contact)paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        genesis__Business_Information__c businessInfoObj = (genesis__Business_Information__c)paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);

        if(!String.isBlank(existingAccountId)){
            return;
            
        }
        // new applicant
        // Checking if all the Required Params are present or not
        PortalApplicationCreationHandler.checkRequiredParamsForNewApplicant(new Map<String, Object>{
            PortalConstants.LOAN_AMOUNT => loanAmount,
            KEY_ENTITY_TYPE => entityType,
            KEY_COMPANY_NAME => companyName,
            KEY_DBA_NAME => dbaName,
            KEY_FIRST_NAME => nameMap.get(KEY_FIRST_NAME),
            KEY_LAST_NAME => nameMap.get(KEY_LAST_NAME),
            PortalConstants.EMAIL_KEY => ssnEmailTinMap.get(PortalConstants.EMAIL_KEY)
        }); 

        accountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId();
        accountObj.clcommon__Legal_Entity_Type__c =  entityType; 
        businessInfoObj.genesis__Total_Assets__c = 0.0;
        businessInfoObj.genesis__Total_Liabilities__c = 0.0;

        if (!String.isBlank(companyName)) {
            // business type entity 
            Map<String, Object> updateAccConBusInfoMap = PortalApplicationCreationHandler.processForNewApplicantOfCompanyType(new Map<String, Object>{
                PortalConstants.ACCOUNT_OBJ_KEY => accountObj,
                PortalConstants.CONTACT_OBJ_KEY => contactObj,
                PortalConstants.BUSINESS_INFO_OBJ_KEY => businessInfoObj
            }, new Map<String, Map<String, String>>{
                KEY_NUMBERS_MAP => numbersMap,
                KEY_SSN_EMAIL_TIN_MAP => ssnEmailTinMap
            }, companyName);

            accountObj = (Account)updateAccConBusInfoMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
            contactObj = (Contact)updateAccConBusInfoMap.get(PortalConstants.CONTACT_OBJ_KEY);
            businessInfoObj = (genesis__Business_Information__c)updateAccConBusInfoMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);

            PortalApplicationCreationHandler.checkIfKycVerified(contactObj, accountObj);
        } else if (!String.isBlank(dbaName)) {
            // dba type entity
            Map<String, Object> updateAccConMap = PortalApplicationCreationHandler.processForNewApplicantOfDBAType(new Map<String, Object>{
                PortalConstants.ACCOUNT_OBJ_KEY => accountObj,
                PortalConstants.CONTACT_OBJ_KEY => contactObj
            }, ssnEmailTinMap, dbaName);
            accountObj = (Account)updateAccConMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
            contactObj = (Contact)updateAccConMap.get(PortalConstants.CONTACT_OBJ_KEY);
        }
        else {
            Map<String, Object> paramForIndividual = new Map<String, Object>{
                PortalConstants.ACCOUNT_OBJ_KEY => accountObj,
                PortalConstants.CONTACT_OBJ_KEY => contactObj
            };
            Map<String, Object> updateAccConMap = PortalApplicationCreationHandler.processForNewApplicantOfIndividualType(new Map<String, Map<String,Object>>{
                KEY_ACC_CON_OBJ => paramForIndividual,
                KEY_NAME_MAP => nameMap,
                KEY_SSN_EMAIL_TIN_MAP => ssnEmailTinMap,
                KEY_NUMBERS_MAP => numbersMap
            }, coopType, loggedInUser[0].Account.ParentId);
            accountObj = (Account)updateAccConMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
            contactObj = (Contact)updateAccConMap.get(PortalConstants.CONTACT_OBJ_KEY);

            PortalApplicationCreationHandler.checkIfKycVerified(contactObj, accountObj);
            ssnEmailTinMap.put(PortalConstants.EMAIL_KEY, contactObj.Email);
            ssnEmailTinMap.put(KEY_CONFIRM_EMAIL, contactObj.Confirm_Email__c);
        }
        //new code
        PortalApplicationCreationHandler.updateBusinessInfo(contactObj.id, businessInfoObj);

        relatedObjects.put(PortalConstants.GENESIS_ACCOUNT_KEY, accountObj);
        relatedObjects.put(PortalConstants.GENESIS_BUSINESS_INFORMATION_KEY, businessInfoObj);  
        relatedObjects.put(PortalConstants.GENESIS_CONTACT_KEY, contactObj); 
        //Assign CIF only for New Applicant
        accountObj.ParentId = loggedInUser[0].Account.ParentId;
        accountObj = PortalApplicationCreationHandler.updateCifForAccount(accountObj, loggedInUser[0].Account.Parent.Coop_Type__c);
        
    }

    /**
     * @description The purpose of this method is to process primary applicant and party for new applicant.
     * @param applicationObj 
     * @param paramMap 
     * @return  `New_Portal_User__e`
     */
    private New_Portal_User__e processPrincipalForNewApplicant(genesis__Applications__c applicationObj, Map<String, Object> paramMap){

        Account accountObj = (Account)paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        Contact contactObj = (Contact)paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        New_Portal_User__e newPortalUser = (New_Portal_User__e)paramMap.get(KEY_NEW_PORTAL_USER);

        if (String.isBlank(existingAccountId)) {
            // new applicant DBA or corp
            if(!String.isBlank(companyName) || !String.isBlank(dbaName)){
                String companyOrDbaName = String.isBlank(companyName) ? dbaName : companyName;
                newPortalUser = PortalApplicationCreationHandler.processPrincipalForNewApplicantOfCompanyOrDbaType(new Map<String, Map<String, String>>{
                                                                                                                                                    KEY_SSN_EMAIL_TIN_MAP => ssnEmailTinMap,
                                                                                                                                                    KEY_NAME_MAP => nameMap,
                                                                                                                                                    KEY_NUMBERS_MAP => numbersMap
                                                                                                                                                }, newPortalUser, new Map<String, Object>{
                                                                                                                                                                                        PortalConstants.APPLICATION_ID => applicationId,
                                                                                                                                                                                        PortalConstants.KEY_COMPANY_OR_DBA_NAME => companyOrDbaName,
                                                                                                                                                                                        PortalConstants.APPLICATION_OBJ_KEY => applicationObj
                                                                                                                                                                                    }
                                                                                                                                            );
            }else{
                // for sole prop
                newPortalUser = PortalApplicationCreationHandler.setPortalUserDetails(newPortalUser, New Map<String, Object>{
                                                                                                                        PortalConstants.KEY_PORTAL_USER_EMAIL => ssnEmailTinMap.get(PortalConstants.EMAIL_KEY),
                                                                                                                        PortalConstants.KEY_PORTAL_USER_FIRST_NAME => nameMap.get(KEY_FIRST_NAME),
                                                                                                                        PortalConstants.KEY_PORTAL_USER_LAST_NAME => nameMap.get(KEY_LAST_NAME),
                                                                                                                        PortalConstants.KEY_PORTAL_USER_ACC_ID => accountObj.Id,
                                                                                                                        PortalConstants.KEY_PORTAL_USER_CON_ID => contactObj.Id,
                                                                                                                        PortalConstants.KEY_PORTAL_USER_CIF_NUM => accountObj.CIF_Number__c
                                                                                                                    });
            }
        }
        return newPortaluser;
    }

    /**
     * @description The purpose of this method is to process the existing applicant.
     * @param paramMap 
     */
    private void processForExistingApplicant(Map<String, Object> paramMap){
        Account accountObj = (Account)paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        genesis__Applications__c applicationObj = (genesis__Applications__c)paramMap.get(PortalConstants.APPLICATION_OBJ_KEY);
        New_Portal_User__e newPortalUser = (New_Portal_User__e)paramMap.get(KEY_NEW_PORTAL_USER);

        if(!String.isBlank(existingAccountId)){
            // existing applicant
            List<genesis__Applications__c> latestApplication = [SELECT Id,
                                                                       genesis__contact__r.FirstName,
                                                                       genesis__contact__r.Email,
                                                                       genesis__contact__r.LastName,
                                                                       genesis__contact__c,
                                                                       genesis__account__c,
                                                                       genesis__account__r.clcommon__Legal_Entity_Type__r.Name
                                                                FROM genesis__applications__c
                                                                WHERE genesis__account__c = :existingAccountId
                                                                AND genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                                                                AND Dealer_Name__c=:loggedInUser[0].Account.ParentId
                                                                ORDER BY CreatedDate DESC
                                                                LIMIT 1];

            if (latestApplication.size() > 0) {
                // if an active application exists for the grower

                Map<String, Object> updateEmailAccConMap = PortalApplicationCreationHandler.processForExistingApplicantWithExistingApp(new Map<String, Object>{
                                                                                                                                                            PortalConstants.ACCOUNT_OBJ_KEY => accountObj,
                                                                                                                                                            PortalConstants.APPLICATION_OBJ_KEY => applicationObj,
                                                                                                                                                            KEY_NEW_PORTAL_USER => newPortalUser,
                                                                                                                                                            PortalConstants.EMAIL_KEY => ssnEmailTinMap.get(PortalConstants.EMAIL_KEY)
                                                                                                                                                        }, latestApplication);

                accountObj = (Account)updateEmailAccConMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
                applicationObj = (genesis__Applications__c)updateEmailAccConMap.get(PortalConstants.APPLICATION_OBJ_KEY);
                newPortalUser = (New_Portal_User__e)updateEmailAccConMap.get(KEY_NEW_PORTAL_USER);
                ssnEmailTinMap.put(PortalConstants.EMAIL_KEY, String.valueOf(updateEmailAccConMap.get(PortalConstants.EMAIL_KEY)));
            }else{
                latestApplication = [SELECT Id,
                                                genesis__contact__r.FirstName,
                                                genesis__contact__r.Email,
                                                genesis__contact__r.LastName,
                                                genesis__contact__c,
                                                genesis__account__c,
                                                genesis__account__r.clcommon__Legal_Entity_Type__r.Name
                                            FROM genesis__applications__c
                                            WHERE genesis__account__c = :existingAccountId
                                            AND Dealer_Name__c=:loggedInUser[0].Account.ParentId
                                            ORDER BY CreatedDate DESC
                                            LIMIT 1];
                if(latestApplication.size() > 0){
                    Map<String, Object> updateEmailAccConMap = PortalApplicationCreationHandler.processForExistingApplicantWithExistingApp(new Map<String, Object>{
                        PortalConstants.ACCOUNT_OBJ_KEY => accountObj,
                        PortalConstants.APPLICATION_OBJ_KEY => applicationObj,
                        KEY_NEW_PORTAL_USER => newPortalUser,
                        PortalConstants.EMAIL_KEY => ssnEmailTinMap.get(PortalConstants.EMAIL_KEY)
                    }, latestApplication);

                    accountObj = (Account)updateEmailAccConMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
                    applicationObj = (genesis__Applications__c)updateEmailAccConMap.get(PortalConstants.APPLICATION_OBJ_KEY);
                    newPortalUser = (New_Portal_User__e)updateEmailAccConMap.get(KEY_NEW_PORTAL_USER);
                    ssnEmailTinMap.put(PortalConstants.EMAIL_KEY, String.valueOf(updateEmailAccConMap.get(PortalConstants.EMAIL_KEY)));
                }else {

                    List<Account> existingAccountList = [SELECT Id, 
                                                                CIF_Number__c,
                                                                clcommon__Legal_Entity_Type__r.Name 
                                                            FROM Account 
                                                            WHERE Id = :existingAccountId];
                    if(existingAccountList.size()>0){
                        chcekLegalEntityForSoleProp(existingAccountList);
                        List<Contact> existingContactList = [SELECT Id, 
                                                                    FirstName, 
                                                                    LastName, 
                                                                    Email,
                                                                    Confirm_Email__c
                                                                FROM Contact 
                                                                WHERE AccountID = :existingAccountId];
                        accountObj.Id = existingAccountId;
                        
                        ssnEmailTinMap.put(PortalConstants.EMAIL_KEY, existingContactList[0].Email);
                        ssnEmailTinMap.put(KEY_CONFIRM_EMAIL, existingContactList[0].Confirm_Email__c);

                        applicationObj.genesis__Account__c = existingAccountId;
                        applicationObj.genesis__Contact__c = existingContactList[0].Id;
                        //setting up the user
                        newPortalUser = PortalApplicationCreationHandler.setPortalUserDetails(newPortalUser, New Map<String, Object>{
                            PortalConstants.KEY_PORTAL_USER_EMAIL => existingContactList[0].Email,
                            PortalConstants.KEY_PORTAL_USER_FIRST_NAME => existingContactList[0].FirstName,
                            PortalConstants.KEY_PORTAL_USER_LAST_NAME => existingContactList[0].LastName,
                            PortalConstants.KEY_PORTAL_USER_ACC_ID => existingAccountId,
                            PortalConstants.KEY_PORTAL_USER_CON_ID => existingContactList[0].Id,
                            PortalConstants.KEY_PORTAL_USER_CIF_NUM => existingAccountList[0].CIF_Number__c
                        });
                    }
                }
            }
        }
        
    }

    /**
     * @description The purpose of this method is to throw an exception if the legal entity is not sole prop.
     * @param existingAccountList 
     */
    private void chcekLegalEntityForSoleProp(List<Account> existingAccountList){
        if(String.valueOf(existingAccountList[0].clcommon__Legal_Entity_Type__c) == null ||
                    existingAccountList[0].clcommon__Legal_Entity_Type__r.Name != PortalConstants.SOLE_PROP_ENTITY){
            throw new CustomException(PortalConstants.SEND_APPLICATION_ERROR);
        }
    }

    /**
     * @description The purpose of this method is to process principal party for existing applicant.
     * @param newPortalUser 
     * @param appCreated 
     * @return  `New_Portal_User__e`
     */
    private New_Portal_User__e processPrincipalForExistingApplicant(New_Portal_User__e newPortalUser, 
                                                                            genesis__Applications__c appCreated){
        // existing applicant
        List<clcommon__Party__c> primaryApplicantParty = new List<clcommon__Party__c>();
        List<clcommon__Party__c> newPartyList = new List<clcommon__Party__c>();
        List<genesis__Applications__c> latestExistingApp = [SELECT Id,
                                                                    genesis__contact__r.FirstName,
                                                                    genesis__contact__r.Email,
                                                                    genesis__contact__r.LastName,
                                                                    genesis__contact__c,
                                                                    genesis__account__c,
                                                                    genesis__account__r.clcommon__Legal_Entity_Type__r.Name,
                                                                    genesis__account__r.CIF_Number__c
                                                            FROM genesis__applications__c
                                                            WHERE genesis__account__c = :existingAccountId
                                                            AND genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                                                            AND Dealer_Name__c=:loggedInUser[0].Account.ParentId
                                                            ORDER BY CreatedDate DESC
                                                            LIMIT 1];
        if (!latestExistingApp.isEmpty()) {
            List<clcommon__Party__c> existingPartyList = [SELECT Id,  
                                                                clcommon__Account__r.genesis__Business_Information__r.genesis__Total_Assets__c,
                                                                clcommon__Account__r.genesis__Business_Information__r.genesis__Total_Liabilities__c,
                                                                clcommon__Account__c,
                                                                clcommon__Account__r.genesis__Business_Information__c,
                                                                clcommon__Account__r.CIF_Number__c,
                                                                clcommon__Type__c,
                                                                clcommon__Contact__r.Email,
                                                                clcommon__Type__r.Name, 
                                                                clcommon__Contact__c, 
                                                                clcommon__Party_Types__c, 
                                                                genesis__Application__c ,
                                                                Name,
                                                                clcommon__Contact__r.FirstName,
                                                                clcommon__Contact__r.LastName
                                                            FROM clcommon__Party__c 
                                                            WHERE genesis__Application__c = :latestExistingApp[0].Id
                                                            AND clcommon__Type__r.Name IN (
                                                                :PortalConstants.PRINCIPAL_PARTY_NAME,
                                                                :PortalConstants.SPOUSE_PARTY_NAME,
                                                                :PortalConstants.LANDOWNER_PARTY_NAME,
                                                                :PortalConstants.BUYER_PARTY_NAME,
                                                                :PortalConstants.INSURANCE_AGENT_PARTY_NAME
                                                            )
                                                            ORDER BY CreatedDate ASC];

            for(clcommon__Party__c existingParty: existingPartyList){
                clcommon__Party__c principalParty = new clcommon__Party__c();
                principalParty.genesis__Application__c = appCreated.Id;
                principalParty.clcommon__Account__c = existingParty.clcommon__Account__c;
                principalParty.clcommon__Contact__c = existingParty.clcommon__Contact__c;
                principalParty.clcommon__Type__c = existingParty.clcommon__Type__c;
                principalParty.clcommon__Party_Types__c = existingParty.clcommon__Type__r.Name;
                newPartyList.add(principalParty);
                if(primaryApplicantParty.isEmpty() & existingParty.clcommon__Type__r.Name == PortalConstants.PRINCIPAL_PARTY_NAME){
                    primaryApplicantParty.add(existingParty);
                }
            }
            Database.insert(newPartyList, true); 

            if (latestExistingApp[0].genesis__account__r.clcommon__Legal_Entity_Type__r.Name == PortalConstants.SOLE_PROP_ENTITY 
                    | latestExistingApp[0].genesis__account__r.clcommon__Legal_Entity_Type__r.Name == PortalConstants.INDIVIDUAL) {

                newPortalUser = PortalApplicationCreationHandler.setPortalUserDetails(newPortalUser, New Map<String, Object>{
                    PortalConstants.KEY_PORTAL_USER_EMAIL => latestExistingApp[0].genesis__contact__r.Email,
                    PortalConstants.KEY_PORTAL_USER_FIRST_NAME => latestExistingApp[0].genesis__contact__r.Firstname,
                    PortalConstants.KEY_PORTAL_USER_LAST_NAME => latestExistingApp[0].genesis__contact__r.LastName,
                    PortalConstants.KEY_PORTAL_USER_ACC_ID => latestExistingApp[0].genesis__account__c,
                    PortalConstants.KEY_PORTAL_USER_CON_ID => latestExistingApp[0].genesis__contact__c,
                    PortalConstants.KEY_PORTAL_USER_CIF_NUM => latestExistingApp[0].genesis__account__r.CIF_Number__c
                });

            } else {
        
                PortalApplicationOriginationHelper.checkEmptyList(primaryApplicantParty, PortalConstants.NO_COAPPLICANT_FOR_THIS_APPLICATION);

                newPortalUser = PortalApplicationCreationHandler.setPortalUserDetails(newPortalUser, New Map<String, Object>{
                    PortalConstants.KEY_PORTAL_USER_EMAIL => primaryApplicantParty[0].clcommon__Contact__r.Email,
                    PortalConstants.KEY_PORTAL_USER_FIRST_NAME => primaryApplicantParty[0].clcommon__Contact__r.Firstname,
                    PortalConstants.KEY_PORTAL_USER_LAST_NAME => primaryApplicantParty[0].clcommon__Contact__r.LastName,
                    PortalConstants.KEY_PORTAL_USER_ACC_ID => primaryApplicantParty[0].clcommon__Account__c,
                    PortalConstants.KEY_PORTAL_USER_CON_ID => primaryApplicantParty[0].clcommon__Contact__c,
                    PortalConstants.KEY_PORTAL_USER_CIF_NUM => primaryApplicantParty[0].clcommon__Account__r.CIF_Number__c
                });

            }
        }
        else {
            List<genesis__Applications__c> lastApplication = [SELECT Id,
                                                                    genesis__contact__r.FirstName,
                                                                    genesis__contact__r.Email,
                                                                    genesis__contact__r.LastName,
                                                                    genesis__contact__c,
                                                                    genesis__account__c,
                                                                    genesis__account__r.clcommon__Legal_Entity_Type__r.Name,
                                                                    genesis__account__r.CIF_Number__c
                                                                FROM genesis__applications__c
                                                                WHERE genesis__account__c = :existingAccountId
                                                                AND id != :applicationId
                                                                AND Dealer_Name__c=:loggedInUser[0].Account.ParentId
                                                                ORDER BY CreatedDate DESC
                                                                LIMIT 1];                                             
            if (lastApplication.size() > 0 && (lastApplication[0].genesis__account__r.clcommon__Legal_Entity_Type__r.Name == PortalConstants.SOLE_PROP_ENTITY 
                    | lastApplication[0].genesis__account__r.clcommon__Legal_Entity_Type__r.Name == PortalConstants.INDIVIDUAL)) {

                newPortalUser = PortalApplicationCreationHandler.setPortalUserDetails(newPortalUser, New Map<String, Object>{
                    PortalConstants.KEY_PORTAL_USER_EMAIL => lastApplication[0].genesis__contact__r.Email,
                    PortalConstants.KEY_PORTAL_USER_FIRST_NAME => lastApplication[0].genesis__contact__r.Firstname,
                    PortalConstants.KEY_PORTAL_USER_LAST_NAME => lastApplication[0].genesis__contact__r.LastName,
                    PortalConstants.KEY_PORTAL_USER_ACC_ID => lastApplication[0].genesis__account__c,
                    PortalConstants.KEY_PORTAL_USER_CON_ID => lastApplication[0].genesis__contact__c,
                    PortalConstants.KEY_PORTAL_USER_CIF_NUM => lastApplication[0].genesis__account__r.CIF_Number__c
                });

                PortalApplicationCreationHandler.createPrincipalParty(new Map<String, Id>{
                    KEY_EXISTING_APP_ID => lastApplication[0].Id,
                    PortalConstants.APPLICATION_ID => appCreated.Id
                });
            } else if(lastApplication.size()>0) {
                primaryApplicantParty = [SELECT Id,  
                                                Name,
                                                clcommon__Account__c,
                                                clcommon__Contact__c,
                                                clcommon__Contact__r.FirstName,
                                                clcommon__Contact__r.LastName,
                                                clcommon__Contact__r.Email,
                                                clcommon__Account__r.CIF_Number__c
                                        FROM clcommon__Party__c 
                                        WHERE genesis__Application__c =: lastApplication[0].Id
                                        AND clcommon__Type__r.Name  = :PortalConstants.PRINCIPAL_PARTY_NAME
                                        ORDER BY Name ASC
                                        LIMIT 1];

                PortalApplicationOriginationHelper.checkEmptyList(primaryApplicantParty, PortalConstants.NO_COAPPLICANT_FOR_THIS_APPLICATION);

                newPortalUser = PortalApplicationCreationHandler.setPortalUserDetails(newPortalUser, New Map<String, Object>{
                    PortalConstants.KEY_PORTAL_USER_EMAIL => primaryApplicantParty[0].clcommon__Contact__r.Email,
                    PortalConstants.KEY_PORTAL_USER_FIRST_NAME => primaryApplicantParty[0].clcommon__Contact__r.Firstname,
                    PortalConstants.KEY_PORTAL_USER_LAST_NAME => primaryApplicantParty[0].clcommon__Contact__r.LastName,
                    PortalConstants.KEY_PORTAL_USER_ACC_ID => primaryApplicantParty[0].clcommon__Account__c,
                    PortalConstants.KEY_PORTAL_USER_CON_ID => primaryApplicantParty[0].clcommon__Contact__c,
                    PortalConstants.KEY_PORTAL_USER_CIF_NUM => primaryApplicantParty[0].clcommon__Account__r.CIF_Number__c
                });

                
                PortalApplicationCreationHandler.createPrincipalParty(new Map<String, Id>{
                    KEY_EXISTING_APP_ID => lastApplication[0].Id,
                    PortalConstants.APPLICATION_ID => appCreated.Id
                });
            }
        }
        return newPortalUser;
    }


    /**
    * @description this method creates a dealer applicant relationship for the borrower if it not already present.
    * @author Rakesh Saraf | 12-05-2024 
    * @param paramMap 
    * @return Dealer_Applicant_Relationship__c 
    **/
    private Dealer_Applicant_Relationship__c processDealerApplicantRelationship(Map<String,Object> paramMap){
        genesis__Applications__c applicationObj=(genesis__Applications__c) paramMap.get(PortalConstants.APPLICATION_OBJ_KEY);
        Contact contactObj=(Contact) paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        Account accountObj=(Account) paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        Dealer_Applicant_Relationship__c dealerApplicantRelObj=(Dealer_Applicant_Relationship__c) paramMap.get(PortalConstants.APPLICANT_DEALER_RELATION_KEY);

        List<Dealer_Applicant_Relationship__c> dealerGrowerRel=[SELECT Id
                                                                FROM Dealer_Applicant_Relationship__c
                                                                WHERE Dealer__c=: loggedInUser[0].Account.ParentId
                                                                AND Applicant__c=:accountObj.id];

        if(dealerGrowerRel.isEmpty()){
            dealerApplicantRelObj=PortalApplicationCreationHandler.createDealerApplicantRelationship(new Map<String,Object>{
                                                                                                    PortalConstants.CONTACT_OBJ_KEY=>contactObj,
                                                                                                    PortalConstants.ACCOUNT_OBJ_KEY=>accountObj,
                                                                                                    PortalConstants.LOGGED_IN_USER=>loggedInUser[0]
                                                                                                });
            Database.insert(dealerApplicantRelObj,true);
            applicationObj.Dealer_Applicant_Relationship__c=dealerApplicantRelObj.Id;
        }
        else{
            dealerApplicantRelObj=dealerGrowerRel[0];
            applicationObj.Dealer_Applicant_Relationship__c=dealerGrowerRel[0].Id;
        }
        Database.update(applicationObj,true);
        return dealerApplicantRelObj;
    }

}