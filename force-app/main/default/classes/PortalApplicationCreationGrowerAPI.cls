/**********************************************************************************************************************
 * @description       : Purpose of this class is to create and save application and party details for grower 
 * @author            : Bijay Shaw
 * @last modified on  : 04-07-2025
 * @last modified by  : Ayush Kumar Singh
**********************************************************************************************************************/
global without sharing class PortalApplicationCreationGrowerAPI implements clcommon.PortalCustomRemoteAPI1{
    // parameters specific for this class [start]
    private static final String EDIT ='edit';
    private final String CLASS_NAME = PortalApplicationCreationGrowerAPI.class.getName();
    private static final String GENESIS_ACCOUNT ='genesis__account__c';
    private static final String GENESIS_CONTACT ='genesis__Contact__c';
    private static final String INVALID_CIF = 'Invalid Dealer CIF';
    // parameters specific for this class [end]

    //custom label delarations for the class
    String invalidCLLabel = System.Label.INACTIVE_CL_LIST;


    /*******************************Declaration of global variables*******************************************/

    String userApplication = ConstantValues.EMPTY_STRING;
    String userPrimaryAccount = ConstantValues.EMPTY_STRING;
    String primaryBusinessInfo = ConstantValues.EMPTY_STRING;
    String entityName = ConstantValues.EMPTY_STRING;
    String applicationId = ConstantValues.EMPTY_STRING;
    String shouldValidate = ConstantValues.EMPTY_STRING;
   
    Boolean shouldNotCreateParty = false;
    Map<String, Id> mapOfpartyType = new Map<String, Id>();
    List<User> loggedInUser = new List<User>();
    List<clcommon.PortalCustomRemoteActionRecord> responseDataList = new List<clcommon.PortalCustomRemoteActionRecord>();
    Map<String, Object> fieldsMap = new Map<String, Object>();
    clcommon.Response response = new clcommon.Response();
    
    genesis__Business_Information__c businessInfoObj = new genesis__Business_Information__c();

     /**
    * @description - Purpose of this method is to create application for grower and send the appId in return
    * @author Bijay Shaw | 17-7-2023 
    **/
    global PortalApplicationCreationGrowerAPI() {
        this.mapOfpartyType = PortalApplicationOriginationHelper.getPartyTypeMap();
        this.loggedInUser = PortalApplicationOriginationHelper.getLoggedInUser(); 
    }
    

   
    /**
    * @description : Get Legal Entity
    * @author  Pritam Roy | 06-17-2024 
    * @param accountObj 
    * @param primaryBusinessInfo 
    * @return genesis__Business_Information__c 
    **/
    private genesis__Business_Information__c getLegalEntity(Account accountObj,String primaryBusinessInfo){
        
        entityName = PortalApplicationOriginationHelper.getLegalEntityByAccount(accountObj);
        if((entityName != PortalConstants.INDIVIDUAL && entityName != PortalConstants.SOLE_PROP_ENTITY) && !String.isBlank(primaryBusinessInfo)) {
                businessInfoObj = (genesis__Business_Information__c) Json.deserialize(primaryBusinessInfo, genesis__Business_Information__c.class);
        }
        return businessInfoObj;
    }


    /**
    * @description - Purpose of this method is to create application for grower and send the appId in return
    * @author Bijay Shaw | 17-7-2023 
    * @param componentStrName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                        String[] disclosureNames,
                                        Map<String, Object> request) {
        PortalApplicationCreationGrowerHandler.DBAWrapper wrapperObj = new PortalApplicationCreationGrowerHandler.DBAWrapper();
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        genesis__Business_Information__c businessInfoObj = new genesis__Business_Information__c();
        Map<String, SObject> relatedObjectsMap = new Map<String, SObject>();
        Account accountObj = loggedInUser[0].Account;

        Id dealerGrowerRelId;
        ID userAccId = accountObj.id;
        ID userContactId = loggedInUser[0].contactId;
        List<Contact> contactList=[ SELECT id,
                                            AccountId,
                                            Account.Coop_Type__c,
                                            Account.ParentId,
                                            name,
                                            MobilePhone,
                                            Phone,
                                            Email,
                                            FirstName,
                                            LastName,
                                            HomePhone,
                                            genesis__SSN__c,
                                            Confirm_Email__c,
                                            Confirm_SSN__c,
                                            ints__Middle_Name__c,
                                            MailingCity,
                                            MailingState,
                                            MailingStreet,
                                            MailingPostalCode,
                                            Mailing_County__c,
                                            Title,
                                            Suffix__c,
                                            clcommon__Marital_Status__c 
                                    FROM Contact
                                    WHERE Id = :userContactId
                                    LIMIT 1];
        
        SavePoint dbSavePoint = Database.setSavepoint();
        try{
            userApplication = String.valueOf(request.get(PortalConstants.APPLICATION_KEY));
            userPrimaryAccount = String.valueOf(request.get(PortalConstants.PRIMARY_APPLICANT_ACCOUNT_KEY));
            primaryBusinessInfo = String.valueOf(request.get(PortalConstants.PRIMARY_APPLICANT_BUSINESS_INFO_KEY));
            shouldValidate = String.valueOf(request.get(PortalConstants.KEY_SHOULD_VALIDATE));
            
            applicationObj = (genesis__Applications__c) Json.deserialize(userApplication, genesis__Applications__c.class);
            accountObj = (Account) Json.deserialize(userPrimaryAccount, Account.class);
            
            //Getting the Legal entityName for the Applicant
            businessInfoObj = getLegalEntity(accountObj,primaryBusinessInfo);
            // updating contact phone fields if null value is sent
            PortalApplicationOriginationHelper.nullifyContactNumbers(accountObj,contactList[0]);
            
            contactList = PortalApplicationCreationGrowerHandler.setSSN(entityName,contactList,request);

            PortalApplicationOriginationHelper.checkEmptyList(loggedInUser, PortalConstants.SOMETHING_WENT_WRONG);

            PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{ PortalConstants.APPLICATION_OBJ_KEY=>applicationObj, 
                                                                                    PortalConstants.CONTACT_OBJ_KEY=> contactList[0], 
                                                                                    PortalConstants.ACCOUNT_OBJ_KEY=> accountObj, 
                                                                                    PortalConstants.BUSINESS_INFO_OBJ_KEY =>businessInfoObj, 
                                                                                    PortalConstants.KEY_SHOULD_VALIDATE=> shouldValidate });

            if(applicationObj.Stage__c == PortalConstants.APPLICANT_INFORMATION){
                applicationObj.Stage__c = PortalConstants.APPLICANT_SIGNATURE;
            }

            if (shouldValidate == PortalConstants.NEW_APPLICANT) {
                Contact borrowerContactObj = new Contact();

                
                if (entityName == PortalConstants.SOLE_PROP_ENTITY) {
                    PortalApplicationCreationGrowerHandler.validateLoggedInGrowerSSN(contactList[0]);
                    populateSolePropDetails(accountObj,contactList[0]);
                    
                }
                else if (entityName == PortalConstants.INDIVIDUAL_ENTITY) {
                    
                    wrapperObj = PortalApplicationCreationGrowerHandler.populateDBADetails(accountObj,borrowerContactObj);
                    accountObj = wrapperObj.accountObj;
                    borrowerContactObj = wrapperObj.contactObj;
                }    
                else{
                    wrapperObj = PortalApplicationCreationGrowerHandler.checkDetails(accountObj,businessInfoObj,borrowerContactObj);
                    accountObj = wrapperObj.accountObj;
                    borrowerContactObj = wrapperObj.contactObj;
                    
                }
                
                List<Account> accountList = [SELECT id,
                                                    Name 
                                            FROM Account 
                                            WHERE id= :userAccId];

                applicationObj.genesis__Account__c = accountList[0].Id;
                applicationObj.genesis__Contact__c = userContactId;
                //applicationObj.ERP_Id__c = PortalApplicationCreationHandler.getErpId(accountObj.Id, loggedInUser[0].Account.ParentId);
                //Map<String,String> identifierMap = PortalApplicationCreationHandler.getIdentifierMap(accountObj.Id, loggedInUser[0].Account.ParentId);
                // applicationObj.ERP_Id__c = identifierMap.get('erpId');
                // applicationObj.Unique_Identifier__c = identifierMap.get('uniqueId');
                // applicationObj.Internal_Reference_Code__c = identifierMap.get('irc');
                // applicationObj = PortalApplicationOriginationHelper.disableApplicantFields(applicationObj,accountList[0]);
                // applicationObj = PortalApplicationOriginationHelper.addDefaultValuesToApplication(applicationObj);

                accountObj=updateCIF(accountObj);
                accountList[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId();
                
                accountObj = PortalApplicationCreationGrowerHandler.checkSolePropDetails(businessInfoObj,entityName,accountObj);
                if(entityName == PortalConstants.SOLE_PROP_ENTITY){
                    borrowerContactObj=contactList[0];
                    relatedObjectsMap.put(GENESIS_CONTACT, contactList[0]);
                }
                else{
                    relatedObjectsMap.put(GENESIS_CONTACT, borrowerContactObj);
                }
                
                accountObj.Coop_Type__c=contactList[0].Account.Coop_Type__c;
                relatedObjectsMap.put(GENESIS_ACCOUNT, accountObj);
                applicationObj = PortalApplicationOriginationHelper.disableApplicantFields(applicationObj,accountObj);
                genesis.BorrowerAPI5 saveAPI = genesis.APIFactory.getBorrowerAPI5();
                genesis__Applications__c appCreated = saveAPI.createApplication(applicationObj, 
                                                                                relatedObjectsMap, 
                                                                                new Map<String, List<Map<String, String>>>(), 
                                                                                false);
                setAppId(appCreated,entityName);

                createDealerParty(appCreated, contactList[0],loggedInUser[0]);

                dealerGrowerRelId=PortalApplicationCreationGrowerHandler.processDealerGrowerRelationship(new Map<String,Object>{PortalConstants.APPLICATION_OBJ_KEY=>appCreated,
                                                                                                                PortalConstants.ACCOUNT_OBJ_KEY=>accountObj,
                                                                                                                PortalConstants.CONTACT_OBJ_KEY=>borrowerContactObj,
                                                                                                                PortalConstants.LOGGED_IN_USER=>loggedInUser[0]});

                PortalApplicationCreationHandler.updateBorrowerDetails(new Map<String,Object>{  PortalConstants.APPLICATION_KEY=>appCreated,
                                                                                                PortalConstants.CONTACT_OBJ_KEY=>borrowerContactObj,
                                                                                                PortalConstants.ACCOUNT_OBJ_KEY=>accountObj,
                                                                                                PortalConstants.ID_KEY=>dealerGrowerRelId,
                                                                                                PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoObj});
            }
            //------------------
            PortalApplicationCreationHandler.verifyExistingAccounts(applicationObj);
            //------------------
            fieldsMap.put(PortalConstants.BORROWER_ENTITY_TYPE, entityName);
            responseDataList.add(new clcommon.PortalCustomRemoteActionRecord(fieldsMap));
            clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(responseDataList);
            response.content = null;
            response.response = responseFormat.response;
            response.status = clcommon.Constants.SUCCESS;
        }catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, CLASS_NAME);
        }catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response;
    }
   

    
    /**
    * @description : Create Dealer Party
    * @author  Pritam Roy | 06-20-2024 
    * @param applicationObj 
    * @param principalContactObj 
    * @param loggedInUser 
    **/
    private void createDealerParty(genesis__Applications__c applicationObj,
                                        Contact principalContactObj,User loggedInUser) {
            String cifnumber = PortalConstants.LANDUS_DEALER_CIF;
            List<String> inactiveCLList = invalidCLLabel.split(ConstantValues.COMMA_STRING);
            List<String> dealerCifList = cifnumber.split(ConstantValues.COMMA_STRING);
            List<Account> dealerAccountList = [SELECT Id,
                                                name 
                                        FROM Account 
                                        WHERE CIF_Number__c IN :dealerCifList AND RecordType.name = :PortalConstants.DEALER_PROFILE];
            PortalApplicationOriginationHelper.checkEmptyList(dealerAccountList, INVALID_CIF);
            List<clcommon__Relationship__c> dealerRelationshipList =[SELECT Id, 
                                                                            clcommon__Entity__c,
                                                                            clcommon__Related_Entity__c, 
                                                                            clcommon__Relationship__r.Name
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE clcommon__Entity__c = :dealerAccountList[0].id
                                                                    AND clcommon__Relationship__r.Name IN ( :PortalConstants.CERTIFIED_LENDER, 
                                                                                                            :PortalConstants.SALES_AGENT, 
                                                                                                            :PortalConstants.CERTIFIED_LENDER_PLUS, 
                                                                                                            :PortalConstants.SALES_AGENT_PLUS
                                                                                                        )
                                                                    AND clcommon__Related_Entity__r.Name NOT IN :inactiveCLList
                                                                    ORDER BY clcommon__Relationship__r.Name ASC];
            
            PortalApplicationOriginationHelper.checkEmptyList(dealerRelationshipList, PortalConstants.SOMETHING_WENT_WRONG);                                                
            List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
            //Adding a party of Dealer
            clcommon__Party__c partyObj = new clcommon__Party__c();
            partyObj.genesis__Application__c = applicationObj.Id;
            partyObj.clcommon__Account__c = dealerRelationshipList[0].clcommon__Entity__c;  
            partyObj.clcommon__Type__c = mapOfpartyType.get(PortalConstants.DEALER_PARTY_NAME);
            partyObj.clcommon__Party_Types__c = PortalConstants.DEALER_PARTY_NAME;

            partyList.add(partyObj);

            applicationObj.Dealer_Name__c = dealerRelationshipList[0].clcommon__Entity__c;
            Map<String,String> identifierMap = PortalApplicationCreationHandler.getIdentifierMap(principalContactObj.AccountId, dealerRelationshipList[0].clcommon__Entity__c);
            applicationObj.ERP_Id__c = identifierMap.get('erpId');
            applicationObj.Unique_Identifier__c = identifierMap.get('uniqueId');
            applicationObj.Internal_Reference_Code__c = identifierMap.get('irc');
            applicationObj.OwnerId = PortalSecurityUtil.getSiteAdmin();
            //Adding party for Loggedin user (Certified Lender or Sales Agent)

            clcommon__Party__c clPartyObj = new clcommon__Party__c();
            clPartyObj.genesis__Application__c = applicationObj.Id;
            clPartyObj.clcommon__Account__c = loggedInUser.AccountId;
            clPartyObj.clcommon__Contact__c = loggedInUser.ContactId;
            
            partyList.addAll(PortalApplicationCreationGrowerHandler.updateParty(dealerRelationshipList,applicationObj,clPartyObj));



            /**
             * Prod issue fix: Certified lenders will be able to view all the applications of that 
             * particular dealer
             */
            List<clcommon__Relationship__c> clRelationshipList = [SELECT Id, 
                                                                        clcommon__Entity__c,
                                                                        clcommon__Related_Entity__c, 
                                                                        clcommon__Relationship__r.Name
                                                                FROM clcommon__Relationship__c
                                                                WHERE clcommon__Entity__c = :dealerAccountList[0].id
                                                                AND clcommon__Relationship__r.Name IN (
                                                                        :PortalConstants.CERTIFIED_LENDER, 
                                                                        :PortalConstants.CERTIFIED_LENDER_PLUS,
                                                                        :PortalConstants.INQUIRY,
                                                                        :PortalConstants.INQUIRY_PLUS,
                                                                        :PortalConstants.FIELD_STAFF_AGENT
                                                                    )
                                                                    ORDER BY clcommon__Relationship__r.Name ASC];

            // if the application is created by SA/SA+, assign a random CL/CL+ initially.
            applicationObj = PortalApplicationCreationGrowerHandler.updateCertifiedLender(clRelationshipList,dealerRelationshipList,applicationObj);

            // also create parties of all the CLs for that particular dealer
            List<String> relationIdList = new List<String>();

            for (clcommon__Relationship__c relation : clRelationshipList) {
                // getting all the certified lenders account id in a list  
                relationIdList.add(relation.clcommon__Related_Entity__c);
            }

            if (!relationIdList.isEmpty()) {
                List<Contact> relationContactList = [SELECT Account.Id, 
                                                            Id,
                                                            Account.RecordType.Name 
                                                    FROM Contact 
                                                    WHERE AccountId IN :relationIdList];

                if (relationContactList.size() != 0) {
                    partyList.addAll(PortalApplicationCreationGrowerHandler.setRelation(relationContactList,applicationObj));
                    
                }
            }


            Database.upsert(partyList, true);

            createSharingRecords(cifnumber, applicationObj);

            if(shouldValidate == PortalConstants.NEW_APPLICANT && shouldNotCreateParty != null && shouldNotCreateParty == false ){
                createPrimaryApplicantParty(applicationObj,principalContactObj,loggedInUser);
            }
        } 

    /**
    * @description : Create Primary Applicant Party
    * @author Sk Minsar | 01-29-2024 
    * @param applicationObj 
    * @param userContactObj 
    * @param loggedInUser 
    **/
    global void createPrimaryApplicantParty(genesis__Applications__c applicationObj, Contact userContactObj,User loggedInUser){
        List<Contact> userContactList;


        if (!String.isBlank(userContactObj.genesis__SSN__c)) {
            userContactList = [SELECT Id,
                                    AccountId,
                                    Account.clcommon__Legal_Entity_Type__c,
                                    Account.Kyc_verified__c,
                                    genesis__SSN__c,
                                    Account.genesis__Business_Information__c
                                FROM Contact
                                WHERE genesis__SSN__c = :userContactObj.genesis__SSN__c
                                AND (Account.clcommon__Legal_Entity_Type__r.Name = :PortalConstants.SOLE_PROP_ENTITY
                                    OR Account.clcommon__Legal_Entity_Type__c = null)];
        } 
        
        PortalApplicationOriginationHelper.checkEmptyList(userContactList, PortalConstants.SOMETHING_WENT_WRONG);

        if(!userContactList[0].Account.Kyc_verified__c){
            userContactList[0].FirstName = userContactObj.FirstName;
            userContactList[0].Lastname = userContactObj.LastName;
        }

        userContactList[0].MobilePhone = userContactObj.MobilePhone;
        userContactList[0].HomePhone = userContactObj.HomePhone ;
        userContactList[0].Phone = userContactObj.Phone ;

        Database.update(userContactList[0], true);

        List<Account> userAccountList = [SELECT Id, 
                                                Work_Number__c, 
                                                Home_Number__c, 
                                                Phone,
                                                ParentId,
                                                Coop_Type__c
                                        FROM Account
                                        WHERE Id =: userContactList[0].AccountId
                                        ];
        userAccountList[0].Phone = userContactObj.MobilePhone;
        userAccountList[0].Home_Number__c = userContactObj.HomePhone;
        userAccountList[0].Work_Number__c = userContactObj.Phone;

        userAccountList[0].ParentId = applicationObj.Dealer_Name__c;
        userAccountList[0].Coop_Type__c = userContactObj.Account.Coop_Type__c;
        Database.Update(userAccountList[0], true);

        List<genesis__Business_Information__c> userBusinessInfoList=[SELECT ID,
                                                                            Gross_Farm_Income__c 
                                                                    FROM genesis__Business_Information__c
                                                                    WHERE id=: userContactList[0].Account.genesis__Business_Information__c];

        clcommon__Party__c principalParty = new clcommon__Party__c();
        principalParty.genesis__Application__c = applicationObj.Id;
        principalParty.clcommon__Account__c = userContactList[0].AccountId;
        principalParty.clcommon__Contact__c = userContactList[0].Id;
        principalParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.PRINCIPAL_PARTY_NAME);
        principalParty.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;

        if(entityName==PortalConstants.CORPORATION){
            principalParty.Title__c=userContactObj.Title;
        }
        principalParty.Suffix__c=userContactObj.Suffix__c;

        principalParty.Gross_Farm_Income__c=userBusinessInfoList[0].Gross_Farm_Income__c;

        principalParty.Street__c=userContactObj.MailingStreet;

        principalParty.City__c=userContactObj.MailingCity;
        principalParty.State__c=userContactObj.MailingState;
        principalParty.Postal_Code__c=userContactObj.MailingPostalCode;
        principalParty.County__c=userContactObj.Mailing_County__c;

        principalParty.Home_Number__c=userContactObj.HomePhone;
        principalParty.Work_Number__c=userContactObj.Phone;
        principalParty.Mobile_Number__c=userContactObj.MobilePhone;

        principalParty.Marital_Status__c=userContactObj.clcommon__Marital_Status__c;
        principalParty.Dealer_Applicant_Relationship__c=PortalApplicationCreationGrowerHandler.processDealerGrowerRelationship(new Map<String,Object>{PortalConstants.APPLICATION_OBJ_KEY=>applicationObj,
                                                                                                                                                    PortalConstants.ACCOUNT_OBJ_KEY=>userAccountList[0],
                                                                                                                                                    PortalConstants.CONTACT_OBJ_KEY=>userContactList[0],
                                                                                                                                                    PortalConstants.LOGGED_IN_USER=>loggedInUser});
        Database.Insert(principalParty, true);

    }
    /**
    * @description : create sharing records
    * @author Sk Minsar | 01-29-2024 
    * @param cifnumber 
    * @param applicationObj 
    **/
    private void createSharingRecords(String cifnumber, genesis__Applications__c applicationObj) {
        //
        //Share the logged in account with all the CLS
        Sharing_Record__e createSharingRecords = new Sharing_Record__e();
        createSharingRecords.ApplicationId__c = applicationObj.Id;
        createSharingRecords.UserAccountId__c = loggedInUser[0].AccountId;
        EventBus.publish(createSharingRecords);
        
    }
    /**
    * @description : Populate sole prop details
    * @author Sk Minsar | 01-29-2024 
    * @param accountObj 
    * @param userContactObj 
    **/
    private void populateSolePropDetails(Account accountObj, Contact userContactObj){
        if (String.isBlank(accountObj.Name)) {
            accountObj.Name = userContactObj.LastName + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + userContactObj.FirstName;
            accountObj.Is_Individual__c = true;
            accountObj.Id = userContactObj.AccountId;
            accountObj.clcommon__Email__c = userContactObj.Email;
            accountObj.Phone = String.isBlank(userContactObj.MobilePhone) ? accountObj.Phone : userContactObj.MobilePhone;
            accountObj.Home_Number__c = String.isBlank(userContactObj.HomePhone) ? accountObj.Home_Number__c : userContactObj.HomePhone;
            accountObj.Work_Number__c = String.isBlank(userContactObj.Phone) ? accountObj.Work_Number__c : userContactObj.Phone;
        }
    }
    /**
    * @description : set App id
    * @author  Pritam Roy | 06-17-2024 
    * @param appCreated 
    * @param entityName 
    **/
    private void setAppId(genesis__Applications__c appCreated,String entityName){
        if (appCreated.Id != null) {
            fieldsMap.put(PortalConstants.APPLICATION_ID, appCreated.Id );
            applicationId = appCreated.Id;
        }
        else {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        if (entityName == PortalConstants.SOLE_PROP_ENTITY) {
            shouldNotCreateParty = true;
        } else {
            shouldNotCreateParty = false;
        }
    }

    /**
    * @description update the cif number in the account
    * @author Rakesh Saraf | 12-11-2024 
    * @param accountObj 
    * @return Account 
    **/
    private static Account updateCIF(Account accountObj){
        List<CFA_Configuration__c> latestCIFList = [SELECT CIF_Number__c
                                                FROM CFA_Configuration__c
                                                LIMIT 1];
        if (latestCIFList.isEmpty()) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        if(accountObj.Id == null){
            accountObj.CIF_Number__c = String.valueOf(latestCIFList[0].CIF_Number__c);
            latestCIFList[0].CIF_Number__c = String.valueOf(Decimal.valueOf(latestCIFList[0].CIF_Number__c) + 1);
            Database.Update(latestCIFList, true);
        }
        return accountObj;
    }


}