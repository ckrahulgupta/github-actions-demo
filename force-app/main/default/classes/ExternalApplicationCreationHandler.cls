/**
 * @description       : handler class for application creation for external apis
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 04-08-2025
 * @last modified by  : Ayush Kumar Singh
**/
public inherited sharing class ExternalApplicationCreationHandler {
    private static final String ALL_DEALER_RELATION = 'allDealerRelationList';
    private static final String DEALER_RELATION_ACC_ID = 'dealerRelationAccIdList';
    private static final String PARTY_LIST = 'partyList';
    private static final String APPLICATION_ID = 'applicationId';
    private static final String DEALER_RELATIONSHIP_NAME = 'dealerRelationshipName';
    private static final String RELATIONSHIP_NAME = 'relationshipName';
    private static final String PARTY_TYPE_NAME = 'partyTypeName';
    private static final String RELATION_PARTY = 'relationParty';
    private static final String CREDIT = 'Credit';
    private static final String TASK_TESTING_ONE = 'Task Testing 1';
    private static final String TASK_TESTING_TWO = 'Task Testing 2';
    private static final String TASK_TESTING_THREE = 'Task Testing 3';
    private static Map<String, Id> mapOfpartyType = ExternalApplicationOriginationUtil.getPartyTypeMap();

    /**
    * @description : adds default values to the application
    * @author Krishanu Chinya | 05-17-2024 
    * @param newApplication 
    **/
    public static void addDefaultValuesToApplication(genesis__Applications__c newApplication){
        List<clcommon__CL_Product__c> clProductList = new List<clcommon__CL_Product__c>();
        
        //adding default term
        if(newApplication.genesis__Term__c == null) {
            newApplication.genesis__Term__c = ExternalConstants.TERM; 
        }
        
        //adding default interest rate
        if(newApplication.genesis__Interest_Rate__c == null) {
            newApplication.genesis__Interest_Rate__c = ExternalConstants.INTEREST_RATE; 
        }
        
        //adding the pricing method
        newApplication.genesis__Pricing_Method__c = ExternalConstants.RATE_CARD_STRING;

        //adding the product type as 'Loan'
        newApplication.genesis__Product_Type__c = ExternalConstants.LOAN_TYPE; 

        //Adding the CL Product as Simpli-Fi
        clProductList = [SELECT Id,
                                clcommon__Product_Name__c
                        FROM clcommon__Cl_Product__c
                        WHERE clcommon__Product_Name__c =: ExternalConstants.SIMPLIFY_TYPE];

        ExternalApplicationOriginationUtil.checkEmptyList(clProductList, ExternalConstants.SOMETHING_WENT_WRONG);
        newApplication.genesis__CL_Product__c = clProductList[0].Id;
    }

    /**
    * @description : creates dealer parties in the application
    * @author Krishanu Chinya | 05-17-2024 
    * @param applicationObj 
    * @param dealerAccount 
    **/
    public static void linkDealerPartyToApplication(genesis__Applications__c applicationObj,Account dealerAccount) {
        clcommon__Party__c partyObj = new clcommon__Party__c();
        List<clcommon__Relationship__c> allDealerRelationList = new List<clcommon__Relationship__c>();

        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        Id randomCLId;
        List<String> dealerRelationAccIdList = new List<String>();



        //Querieng all the dealer relations
        allDealerRelationList = [SELECT Id,
                                    clcommon__Related_Entity__c,
                                    clcommon__Related_Entity__r.ParentId,
                                    clcommon__Relationship__r.Name
                                    FROM clcommon__Relationship__c
                                    WHERE clcommon__Entity__c = :dealerAccount.Id
                                    AND clcommon__Relationship__r.Name IN (
                                        :ExternalConstants.FIELD_STAFF_AGENT,
                                        :ExternalConstants.CERTIFIED_LENDER, 
                                        :ExternalConstants.CERTIFIED_LENDER_PLUS,
                                        :ExternalConstants.SALES_AGENT_ADMIN,
                                        :ExternalConstants.SALES_AGENT, 
                                        :ExternalConstants.SALES_AGENT_PLUS,
                                        :ExternalConstants.INQUIRY,
                                        :ExternalConstants.INQUIRY_PLUS, 
                                        :ExternalConstants.PAYMENT_ADMINISTRATOR)];

        ExternalApplicationOriginationUtil.checkEmptyList(allDealerRelationList, ExternalConstants.SOMETHING_WENT_WRONG);

        for(clcommon__Relationship__c eachRelation: allDealerRelationList){
            dealerRelationAccIdList.add(eachRelation.clcommon__Related_Entity__c);

            //fetching a random cl
            if(eachRelation.clcommon__Relationship__r.Name == ExternalConstants.CERTIFIED_LENDER){
                randomCLId = eachRelation.clcommon__Related_Entity__c;
            }
        }

        //adding dealer party
        partyObj.genesis__Application__c = applicationObj.Id;
        partyObj.clcommon__Account__c = dealerAccount.Id;   
        partyObj.clcommon__Type__c = mapOfpartyType.get(ExternalConstants.DEALER_PARTY);
        partyObj.clcommon__Party_Types__c = ExternalConstants.DEALER_PARTY;
        partyList.add(partyObj);

        //setting dealer name in application
        applicationObj.Dealer_Name__c = dealerAccount.Id;
        applicationObj.OwnerId = ExternalSecurityUtil.getSiteAdmin();

        applicationObj.Certified_Lender__c = randomCLId;

        //creating parties of all CL/CL+/Inquiry/Inquiry+/FSA/PA
        createDealerRelationParties(New Map<String, Object>{
            ALL_DEALER_RELATION => allDealerRelationList,
            DEALER_RELATION_ACC_ID => dealerRelationAccIdList,
            PARTY_LIST=> partyList,
            APPLICATION_ID => applicationObj.Id
        });

        Database.upsert(partyList, true);
        Database.upsert(applicationObj, true);
        
        //create sharing records for cl/cl+/inq/inq+/fsa
        createDealerRelationSharingRecords(applicationObj.Id, dealerRelationAccIdList);
    }

    /**
    * @description : creates parties of the dealer relations
    * @author Krishanu Chinya | 05-17-2024 
    * @param paramMap
    **/
    public static void createDealerRelationParties(Map<String, Object> paramMap){
        
        List<clcommon__Relationship__c> allDealerRelationList = (List<clcommon__Relationship__c>)paramMap.get(ALL_DEALER_RELATION);
        List<String> dealerRelationAccIdList = (List<String>)paramMap.get(DEALER_RELATION_ACC_ID);
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)paramMap.get(PARTY_LIST);
        Id applicationId = (String)paramMap.get(APPLICATION_ID);
        
        ExternalApplicationOriginationUtil.checkEmptyList(dealerRelationAccIdList, ExternalConstants.SOMETHING_WENT_WRONG);
        Map<Id,Id> relationAccVSContactMap = new Map<Id, Id> ();

        List<Contact> dealerRelationContactList = [SELECT Id, 
                                                            Account.Id,
                                                            Account.RecordType.Name 
                                                    FROM Contact 
                                                    WHERE AccountId IN :dealerRelationAccIdList];

        for(Contact dealerRelationContact : dealerRelationContactList){
            relationAccVSContactMap.put(dealerRelationContact.AccountId, dealerRelationContact.Id);
        }

        for(clcommon__Relationship__c dealerRelation : allDealerRelationList){
            clcommon__Party__c relationParty = new clcommon__Party__c();
            relationParty.genesis__Application__c = applicationId;
            relationParty.clcommon__Account__c = dealerRelation.clcommon__Related_Entity__c;
            relationParty.clcommon__Contact__c = relationAccVSContactMap.get(dealerRelation.clcommon__Related_Entity__c);

            setPartyType(New Map<String, Object>{
                DEALER_RELATIONSHIP_NAME => dealerRelation.clcommon__Relationship__r.Name,
                RELATIONSHIP_NAME => ExternalConstants.CERTIFIED_LENDER,
                PARTY_TYPE_NAME => ExternalConstants.CERTIFIED_LENDER_PARTY,
                RELATION_PARTY => relationParty
            });
            setPartyType(New Map<String, Object>{
                DEALER_RELATIONSHIP_NAME => dealerRelation.clcommon__Relationship__r.Name,
                RELATIONSHIP_NAME => ExternalConstants.CERTIFIED_LENDER_PLUS,
                PARTY_TYPE_NAME => ExternalConstants.CERTIFIED_LENDER_PLUS_PARTY,
                RELATION_PARTY => relationParty
            });
            setPartyType(New Map<String, Object>{
                DEALER_RELATIONSHIP_NAME => dealerRelation.clcommon__Relationship__r.Name,
                RELATIONSHIP_NAME => ExternalConstants.INQUIRY,
                PARTY_TYPE_NAME => ExternalConstants.INQUIRY_PARTY,
                RELATION_PARTY => relationParty
            });
            setPartyType(New Map<String, Object>{
                DEALER_RELATIONSHIP_NAME => dealerRelation.clcommon__Relationship__r.Name,
                RELATIONSHIP_NAME => ExternalConstants.INQUIRY_PLUS,
                PARTY_TYPE_NAME => ExternalConstants.INQUIRY_PLUS_PARTY,
                RELATION_PARTY => relationParty
            });
            setPartyType(New Map<String, Object>{
                DEALER_RELATIONSHIP_NAME => dealerRelation.clcommon__Relationship__r.Name,
                RELATIONSHIP_NAME => ExternalConstants.FIELD_STAFF_AGENT,
                PARTY_TYPE_NAME => ExternalConstants.FIELD_STAFF_AGENT_PARTY,
                RELATION_PARTY => relationParty
            });
            setPartyType(New Map<String, Object>{
                DEALER_RELATIONSHIP_NAME => dealerRelation.clcommon__Relationship__r.Name,
                RELATIONSHIP_NAME => ExternalConstants.PAYMENT_ADMINISTRATOR,
                PARTY_TYPE_NAME => ExternalConstants.PAYMENT_ADMINISTRATOR_PARTY,
                RELATION_PARTY => relationParty
            });
            
            if(relationParty.clcommon__Type__c != null){
                partyList.add(relationParty); 
            }
        }
    }

    /**
    * @description : sets the party type in the party based on the relationship type
    * @author Krishanu Chinya | 05-17-2024 
    * @param paramMap
    **/
    public static void setPartyType(Map<String, Object> paramMap){
        String dealerRelationshipName = (String)paramMap.get(DEALER_RELATIONSHIP_NAME);
        String relationshipName = (String)paramMap.get(RELATIONSHIP_NAME);
        String partyTypeName = (String)paramMap.get(PARTY_TYPE_NAME);
        clcommon__party__c relationParty = (clcommon__party__c)paramMap.get(RELATION_PARTY);

        if(dealerRelationshipName == relationshipName ){
            relationParty.clcommon__Type__c = mapOfpartyType.get(partyTypeName);
            relationParty.clcommon__Party_Types__c = partyTypeName;
        }
    }

    /**
    * @description : creates sharing records for the dealer relations
    * @author Krishanu Chinya | 05-17-2024 
    * @param applicationId 
    * @param dealerRelationAccIdList 
    **/
    public static void createDealerRelationSharingRecords(Id applicationId, List<String> dealerRelationAccIdList) {
        List<genesis__Applications__Share> appShareList = new List<genesis__Applications__Share>();
        List<clcommon__Document_Category__Share> docCatagoryShareList = new List<clcommon__Document_Category__Share>();

        List<User> dealerRelationUserList = [SELECT Id,
                                                    Account.RecordType.Name 
                                            FROM User 
                                            WHERE AccountId IN :dealerRelationAccIdList
                                            AND Account.RecordType.Name IN (
                                                :ExternalConstants.CERTIFIED_LENDER, 
                                                :ExternalConstants.CERTIFIED_LENDER_PLUS,
                                                :ExternalConstants.INQUIRY,
                                                :ExternalConstants.INQUIRY_PLUS,
                                                :ExternalConstants.FIELD_STAFF_AGENT)];

        List<clcommon__Document_Category__c> documentCategoriesList = [SELECT Id 
                                                                FROM clcommon__Document_Category__c 
                                                                WHERE genesis__Application__c = :applicationId];

        
        for (User dealerRelationUser : dealerRelationUserList) {
            genesis__Applications__Share appShareRecord = new genesis__Applications__Share();
            appShareRecord.AccessLevel = ConstantValues.ACCESS_LABEL_EDIT;
            appShareRecord.ParentId = applicationId;
            appShareRecord.UserOrGroupId = dealerRelationUser.Id;
            appShareList.add(appShareRecord);

            for (clcommon__Document_Category__c documentCategory : documentCategoriesList) {

                clcommon__Document_Category__Share documentSharingRecord = new clcommon__Document_Category__Share();
                documentSharingRecord.AccessLevel = ConstantValues.ACCESS_LABEL_EDIT;
                documentSharingRecord.ParentId = documentCategory.Id;
                documentSharingRecord.UserOrGroupId = dealerRelationUser.Id;
                docCatagoryShareList.add(documentSharingRecord);
            }
        }

        Database.upsert(appShareList, false);
        Database.upsert(docCatagoryShareList, false);
    }

    /**
    * @description : creates a party of the principal in the application
    * @author Krishanu Chinya | 05-17-2024 
    * @param applicationObj 
    * @param priApplicantContact 
    **/
    public static void createPrincipalParty(genesis__Applications__c applicationObj, Contact priApplicantContact){
        //duplicate check of the principal

        //creating primary applicant party
        clcommon__Party__c priApplicantParty = new clcommon__Party__c();
        priApplicantParty.genesis__Application__c = applicationObj.Id;
        priApplicantParty.clcommon__Type__c = mapOfpartyType.get(ExternalConstants.PRINCIPAL_PARTY);
        priApplicantParty.clcommon__Party_Types__c = ExternalConstants.PRINCIPAL_PARTY;
        priApplicantParty.clcommon__Account__c = priApplicantContact.AccountId;
        priApplicantParty.clcommon__Contact__c = priApplicantContact.Id;
        Database.Insert(priApplicantParty, true);
    }

    /**
    * @description : updates the borrower details 
    * @author Krishanu Chinya | 05-17-2024 
    * @param applicationObj 
    * @param paramMap
    * @param borrowerDealerRelationObj
    **/
    public static void updateBorrowerDetails(genesis__Applications__c applicationObj, Map<String,Object> paramMap, Dealer_Applicant_Relationship__c borrowerDealerRelationObj){

        List<clcommon__party__c> borrowerPartyList = [SELECT Id,
                                                            clcommon__Contact__c,
                                                            Home_Number__c,
                                                            Mobile_Number__c,
                                                            Work_Number__c
                                                        FROM clcommon__party__c
                                                        WHERE genesis__Application__c =: applicationObj.Id
                                                        AND clcommon__Type__r.Name =: ExternalConstants.BORROWER_PARTY];

        if (borrowerPartyList.isEmpty()){
            clcommon__Party__c borrowerParty = new clcommon__Party__c();
            borrowerParty.genesis__Application__c = applicationObj.Id;
            borrowerParty.clcommon__Account__c = applicationObj.genesis__Account__c;
            borrowerParty.clcommon__Contact__c = applicationObj.genesis__Contact__c;
            borrowerParty.Home_Number__c = String.valueOf(paramMap.get(ExternalConstants.HOME_PHONE_KEY));
            borrowerParty.Mobile_Number__c = String.valueOf(paramMap.get(ExternalConstants.PHONE_NUMBER_KEY));
            borrowerParty.Work_Number__c = String.valueOf(paramMap.get(ExternalConstants.WORK_PHONE_KEY));
            borrowerParty.Dealer_Applicant_Relationship__c = borrowerDealerRelationObj.Id;
            List<clcommon__Party_Type__c> partyType = [SELECT Id
                                                    FROM clcommon__Party_Type__c
                                                    WHERE NAME =: ExternalConstants.BORROWER_PARTY];
            borrowerParty.clcommon__Type__c = partyType[0].Id;
            borrowerParty.clcommon__Party_Types__c = ExternalConstants.BORROWER_PARTY;
            Database.upsert(borrowerParty, true);
        }
        else{
            borrowerPartyList[0].clcommon__Contact__c = applicationObj.genesis__Contact__c;
            borrowerPartyList[0].clcommon__Party_Types__c = ExternalConstants.BORROWER_PARTY;   
            borrowerPartyList[0].Home_Number__c = String.valueOf(paramMap.get(ExternalConstants.HOME_PHONE_KEY));
            borrowerPartyList[0].Mobile_Number__c = String.valueOf(paramMap.get(ExternalConstants.PHONE_NUMBER_KEY));
            borrowerPartyList[0].Work_Number__c = String.valueOf(paramMap.get(ExternalConstants.WORK_PHONE_KEY));
            borrowerPartyList[0].Dealer_Applicant_Relationship__c = borrowerDealerRelationObj.Id;
            Database.update(borrowerPartyList, true);    
        }


        List<Account> accountList = [SELECT Id, 
                                    OwnerId,
                                    ParentId
                                FROM Account
                                WHERE Id=: applicationObj.genesis__Account__c];
        accountList[0].OwnerId = ExternalSecurityUtil.getSiteAdmin();
        //update parent id to current dealer
        accountList[0].ParentId = applicationObj.Dealer_Name__c;
        Database.Update(accountList[0], true);

        List<Contact> contactList = [SELECT Id, 
                                        AccountId
                                    FROM Contact
                                    WHERE Id = :applicationObj.genesis__Contact__c];
        contactList[0].AccountId = applicationObj.genesis__Account__c;
        Database.update(contactList[0], true);
    }

    /**
    * @description : updates cif for an account
    * @author Krishanu Chinya | 05-17-2024 
    * @param accountObj 
    * @param coopType 
    * @return Account 
    **/
    public static Account updateCifForAccount(Account accountObj, String coopType){
        List<CFA_Configuration__c> latestCIFList = [SELECT CIF_Number__c,
                                                    Growmark_CIF_Number__c
                                              FROM CFA_Configuration__c LIMIT 1];

        if(accountObj.Id == null){
            assignNewCIF(accountObj, coopType, latestCIFList[0]);

        }else{ 
            List<Account> accList = [SELECT Id, 
                                            CIF_Number__c 
                                    FROM Account 
                                    WHERE Id = :accountObj.Id 
                                    LIMIT 1];

            if(accList[0].CIF_Number__c == null || accList[0].CIF_Number__c == ExternalConstants.EMPTY_STRING){
                assignNewCIF(accountObj, coopType, latestCIFList[0]);
            }else{
                accountObj.CIF_Number__c = accList[0].CIF_Number__c;
            }
        }
        Database.upsert(accountObj, true);
        return accountObj;
    }

    /**
    * @description : assigns cif based on coop and update the cif number
    * @author Krishanu Chinya | 05-20-2024 
    * @param accountObj 
    * @param coopType 
    * @param latestCIF 
    **/
    public static void assignNewCIF(Account accountObj, String coopType, CFA_Configuration__c latestCIF){
        if(coopType != ExternalConstants.EMPTY_STRING && coopType == ExternalConstants.GROWMARK_COOP_TYPE){
            accountObj.CIF_Number__c = String.valueOf(latestCIF.Growmark_CIF_Number__c);
            latestCIF.Growmark_CIF_Number__c = String.valueOf(Decimal.valueOf(latestCIF.Growmark_CIF_Number__c) + ExternalConstants.ONE_VALUE);
        }
        else{
            accountObj.CIF_Number__c = String.valueOf(latestCIF.CIF_Number__c);
            latestCIF.CIF_Number__c = String.valueOf(Decimal.valueOf(latestCIF.CIF_Number__c) + ExternalConstants.ONE_VALUE);
        }
        accountObj.Coop_Type__c = coopType;
        Database.Update(latestCIF, true);
    }

    /**
    * @description : assignes cif to a list of accounts
    * @author Krishanu Chinya | 06-10-2024 
    * @param coapplicantAccList 
    * @param coopType 
    **/
    public static void assignCIFtoCoapplicants(List<Account> coapplicantAccList, String coopType){
        List<CFA_Configuration__c> latestCIFList = [SELECT Id, 
                                                            CIF_Number__c,
                                                    Growmark_CIF_Number__c
                                            FROM CFA_Configuration__c LIMIT 1];
        for(Account accountObj : coapplicantAccList){
            if(accountObj.Id == null || accountObj.CIF_Number__c == null || accountObj.CIF_Number__c == ExternalConstants.EMPTY_STRING){
                if(coopType != ExternalConstants.EMPTY_STRING && coopType == ExternalConstants.GROWMARK_COOP_TYPE){
                    accountObj.CIF_Number__c = String.valueOf(latestCIFList[0].Growmark_CIF_Number__c);
                    latestCIFList[0].Growmark_CIF_Number__c = String.valueOf(Decimal.valueOf(latestCIFList[0].Growmark_CIF_Number__c) + ExternalConstants.ONE_VALUE);
                }
                else{
                    accountObj.CIF_Number__c = String.valueOf(latestCIFList[0].CIF_Number__c);
                    latestCIFList[0].CIF_Number__c = String.valueOf(Decimal.valueOf(latestCIFList[0].CIF_Number__c) + ExternalConstants.ONE_VALUE);
                }            
            }
        }
        Database.update(latestCIFList[0], true);
    }

    /**
    * @description : Method to assign record type to the coapplicant
    * @author Krishanu Chinya | 07-10-2024 
    * @param principalAccount 
    **/
    public static void assignCoapplicantRecordType(Account principalAccount){
        if(principalAccount.RecordTypeId != Schema.SObjectType.Account.getRecordTypeInfosByName().get(ExternalConstants.GROWER_PROFILE).getRecordTypeId()){
            principalAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(ExternalConstants.CO_APPLICATION_RECORD_TYPE).getRecordTypeId();
        }
    }
    /**
     * @description Creates required tasks for the application if they aren't created
     * @param applicationId 
     */
    public static void createTasks(String applicationId){
        List<Task> masterTaskList = new List<Task>();
        List<Task> applicationTasks = [SELECT Id 
                                        FROM Task 
                                        WHERE genesis__Application__c = :applicationId];
        if(applicationTasks.size() == 0 ){
            String departmentId = [SELECT Id FROM genesis__Department__c WHERE Name  = :CREDIT].Id;
            List<genesis__Task_Setup__c> taskSetupList = [SELECT Id, 
                                                            genesis__Object_Type__c, 
                                                            genesis__Priority__c, 
                                                            genesis__Task_Name__c, 
                                                            genesis__Type__c 
                                                        FROM genesis__Task_Setup__c 
                                                        WHERE (genesis__Task_name__c != :TASK_TESTING_ONE AND 
                                                        genesis__Task_name__c != :TASK_TESTING_TWO AND 
                                                        genesis__Task_name__c != :TASK_TESTING_THREE)];
            integer count = 1;
            for (genesis__Task_Setup__c eachTaskSetup : taskSetupList){
                Task eachTask = new Task();
                //DEPARTMENT - CREDIT
                eachTask.genesis__Department__c = departmentId;//Dev - a7R74000000GhxGEAS, Prod - a7R5f000000coIfEAI
                //APPLICATION
                eachTask.WhatId = applicationId;
                eachTask.genesis__Application__c = applicationId;

                //SUBJECT - Task Name
                eachTask.Subject = eachTaskSetup.genesis__Task_Name__c;
                eachtask.Description = eachTaskSetup.genesis__Task_Name__c;
                eachTask.genesis__Task_Setup__c = eachTaskSetup.Id;

                eachTask.genesis__Completion_Mandatory__c = false;
                eachTask.genesis__Is_Archived__c = false;
                eachTask.genesis__Is_Parallel__c = false;

                eachTask.genesis__Task_Order__c = count;
                count++;
                masterTaskList.add(eachTask);
            }
            Database.insert(masterTaskList,true);
        }
    }

    /**
    * @description : Method to create new Dealer_Applicant_Relationship__c record
    * @author Suraj Kumar | 12-03-2024 
    * @param applicantAccounObj 
    * @param applicantContactObj 
    * @param dealerAccountObj 
    * @return Dealer_Applicant_Relationship__c 
    **/
    public static Dealer_Applicant_Relationship__c createNewApplicantDealerRelationship(Account applicantAccounObj, Contact applicantContactObj, Account dealerAccountObj){
        Dealer_Applicant_Relationship__c applicantDealerRelObj = new Dealer_Applicant_Relationship__c();
        applicantDealerRelObj.Applicant__c = applicantAccounObj.Id;
        applicantDealerRelObj.Applicant_Contact__c = applicantContactObj.Id;
        applicantDealerRelObj.Dealer__c = dealerAccountObj.Id;
        Database.insert(applicantDealerRelObj,true);
        return applicantDealerRelObj;
    }

     /**
    * @description : creates a party of the principal in the application
    * @author Suraj Kumar | 12-03-2024 
    * @param applicationObj 
    * @param paramMap 
    * @param principalDealerRelObj
    **/
    public static void createPrincipalParty(genesis__Applications__c applicationObj, Map<String,Object> paramMap, Dealer_Applicant_Relationship__c principalDealerRelObj){
        //creating primary applicant party
        clcommon__Party__c priApplicantPartyObj = new clcommon__Party__c();
        priApplicantPartyObj.genesis__Application__c = applicationObj.Id;
        priApplicantPartyObj.clcommon__Type__c = mapOfpartyType.get(ExternalConstants.PRINCIPAL_PARTY);
        priApplicantPartyObj.clcommon__Party_Types__c = ExternalConstants.PRINCIPAL_PARTY;
        priApplicantPartyObj.clcommon__Account__c = String.valueOf(paramMap.get(ExternalConstants.PRINCIPAL_ACCOUNT_ID));
        priApplicantPartyObj.clcommon__Contact__c = String.valueOf(paramMap.get(ExternalConstants.PRINCIPAL_CONTACT_ID));
        priApplicantPartyObj.Home_Number__c = String.valueOf(paramMap.get(ExternalConstants.HOME_PHONE_KEY));
        priApplicantPartyObj.Mobile_Number__c = String.valueOf(paramMap.get(ExternalConstants.PHONE_NUMBER_KEY));
        priApplicantPartyObj.Work_Number__c = String.valueOf(paramMap.get(ExternalConstants.WORK_PHONE_KEY));
        priApplicantPartyObj.Dealer_Applicant_Relationship__c = principalDealerRelObj.Id;
        Database.Insert(priApplicantPartyObj, true);
    }

    
    /**
    * @description : checks whether the applicants are marked as non accrual or past due
    * @author Krishanu Chinya | 02-26-2025 
    * @param appId 
    **/
    public static void checkForNonAccrualAndPastDue(Id appId){
        List<clcommon__Party__c> applicantPartyList = [SELECT Id,  
                                                            Dealer_Applicant_Relationship__r.Has_Past_Due__c,
                                                            Dealer_Applicant_Relationship__r.Is_Non_Accrual__c,
                                                            clcommon__Type__r.Name
                                                        FROM clcommon__Party__c
                                                        WHERE genesis__Application__c =: appId
                                                        AND clcommon__Type__r.Name IN (
                                                            :ExternalConstants.PRINCIPAL_PARTY,
                                                            :ExternalConstants.BORROWER_PARTY)
                                                        ];
        for(clcommon__Party__c existingParty: applicantPartyList){
            if(existingParty.Dealer_Applicant_Relationship__r.Has_Past_Due__c == true){
                throw new CustomException(ExternalConstants.PAST_DUE_APPLICATIONS_EXCEPTION);
            }
            if(existingParty.Dealer_Applicant_Relationship__r.Is_Non_Accrual__c == true){
                throw new CustomException(ExternalConstants.NON_ACCRUAL_APPLICATIONS_EXCEPTION);
            }
        }  
    }

    /**
    * @description : checks whether an applicant party is marked as non accrual or past due
    * @author Krishanu Chinya | 02-26-2025 
    * @param partyToCheck 
    **/
    public static void checkForNonAccrualOrPastDueParty(clcommon__party__c partyToCheck){
        if(partyToCheck.Dealer_Applicant_Relationship__r.Has_Past_Due__c == true){
            throw new CustomException(ExternalConstants.PAST_DUE_APPLICANT_EXCEPTION);
        }
        if(partyToCheck.Dealer_Applicant_Relationship__r.Is_Non_Accrual__c == true){
            throw new CustomException(ExternalConstants.NON_ACCRUAL_APPLICANT_EXCEPTION);
        }
    }

    /**
    * @description : checks whether the applicant exist in the system with a different user id or not
    * @author Krishanu Chinya | 02-26-2025 
    * @param accountObj 
    * @param newUniqueId 
    **/
    public static void checkForUniqueId(Account accountObj, String newUniqueId){
        if (String.isBlank(accountObj.Unique_Id__c)) {
    		accountObj.Unique_Id__c = newUniqueId;
		} else if (!accountObj.Unique_Id__c.equals(newUniqueId)) {
    		throw new CustomException(ExternalConstants.USERID_ALREADY_ASSIGNED);
		}
    }

    /**
    * @description method to populate the new details entered through the api to the party
    * @author Rakesh Saraf | 03-24-2025 
    * @param principalDetailsMap 
    * @return clcommon__Party__c 
    **/
    public static clcommon__Party__c populateNewPartyDetails(Map<String, Object> principalDetailsMap){
        clcommon__Party__c principalParty= new clcommon__Party__c();

        principalParty.Work_Number__c = String.valueOf(principalDetailsMap.get(ExternalConstants.WORK_PHONE_KEY));
        principalParty.Home_Number__c = String.valueOf(principalDetailsMap.get(ExternalConstants.HOME_PHONE_KEY));
        principalParty.Mobile_Number__c = String.valueOf(principalDetailsMap.get(ExternalConstants.PHONE_NUMBER_KEY));

        //populating address
        principalParty.Street__c = String.valueOf(principalDetailsMap.get(ExternalConstants.STREET_KEY));
        principalParty.City__c = String.valueOf(principalDetailsMap.get(ExternalConstants.CITY_KEY));
        principalParty.State__c = String.valueOf(principalDetailsMap.get(ExternalConstants.STATE_KEY));
        principalParty.Postal_Code__c = String.valueOf(principalDetailsMap.get(ExternalConstants.POSTAL_CODE_KEY));
        principalParty.County__c = String.valueOf(principalDetailsMap.get(ExternalConstants.COUNTY_KEY));

        principalParty.Suffix__c = String.valueOf(principalDetailsMap.get(ExternalConstants.SUFFIX_KEY));
        principalParty.Marital_Status__c = String.valueOf(principalDetailsMap.get(ExternalConstants.MARITAL_STATUS_KEY));
        principalParty.Title__c = String.valueOf(principalDetailsMap.get(ExternalConstants.TITLE_KEY));

        return principalParty;
    }

    /**
    * @description method to populate the middle name of the co-applicant
    * @author Rakesh Saraf | 03-28-2025 
    * @param principalContactObj 
    * @param duplicatePrincipalMap 
    * @param principalDetailsMap 
    **/
    public static void populateMiddleNameOfCoApplicant(Contact principalContactObj, Map<String,Object> duplicatePrincipalMap, Map<String, Object> principalDetailsMap){

        Account principalAccountObj= (Account)duplicatePrincipalMap.get(ExternalConstants.ACCOUNT_KEY);

        String middleName = String.valueOf(principalDetailsMap.get(ExternalConstants.MIDDLE_NAME_KEY));

        if(!String.isBlank(middleName) && String.isBlank(principalContactObj.ints__middle_name__c) && !principalAccountObj.Kyc_Verified__c){
            principalContactObj.ints__middle_name__c = middleName;

            principalAccountObj.Name= principalAccountObj.Name + ExternalConstants.SPACE_STRING  + middleName;
        }

        duplicatePrincipalMap.put(ExternalConstants.ACCOUNT_KEY,principalAccountObj);

    }

    /**
     * @description return IRC of an existing active or closed application
     * @param existingAccountId 
     * @param dealerId 
     * @return  `Map<String,String>`
     */
    public static Map<String,String> getIdentifierMap(Id existingAccountId, Id dealerId){
        String uniqueId = PortalConstants.EMPTY_STRING;
        String irc = PortalConstants.EMPTY_STRING;
        List<genesis__Applications__c>  lastActiveAppOfGrowerList = [SELECT Id,
                                        Unique_Identifier__c,
                                        Internal_Reference_Code__c 
                                        FROM genesis__Applications__c 
                                        WHERE genesis__Account__c =: existingAccountId
                                        AND Dealer_Name__c =: dealerId
                                        AND genesis__Status__c IN (
                                            :PortalConstants.ACTIVE_APPLICATION_STATUS,
                                            :PortalConstants.CLOSED_APPLICATION_STATUS)
                                        ORDER BY genesis__Status__c ASC, genesis__Loan_Number__c DESC LIMIT 1];
        
        if (lastActiveAppOfGrowerList.size() > 0){
            uniqueId = String.valueOf(lastActiveAppOfGrowerList[0].Unique_Identifier__c);
            irc = String.valueOf(lastActiveAppOfGrowerList[0].Internal_Reference_Code__c);
        }
        Map<String,String> identifierMap = new Map<String,String>{'uniqueId' => uniqueId,
                                                                    'irc' => irc
                                                                };
        return identifierMap;
    }
}