/**********************************************************************************************************************
 * @description       : The purpose of this class is to clone an entire application including additional info details 
 *                      and all other party related to that application
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 04-07-2025
 * @last modified by  : Ayush Kumar Singh
**********************************************************************************************************************/

global without sharing class PortalApplicationCloneAPI implements clcommon.PortalCustomRemoteAPI1 {
    
    // parameters specific for this class [start]
    private static final String EDIT ='edit';
    private static final String KEY_CREATE_EVERGREEN_APPL = 'createEvergreenApplication';
    private static final String TRACK_PAST_DUE = 'trackHasPastDue';
    private static final String TRACK_NON_ACCRUAL = 'trackNonAccrual';
    private static final String GENESIS_APPLICATION_STATUS = 'genesis__Application__r.genesis__Status__c';
    private static final String GENESIS_APPLICATION_STAGE = 'genesis__Application__r.Stage__c';
    private static final String GENESIS_APPLICATION_AGREEMENT_SIGN = 'genesis__Application__r.Agreement_Sign__c';
    private static final String GENESIS_APPLICATION_ID = 'genesis__Application__r.Id';
    private static final String GENESIS_APPLICATION_ACCOUNT_ID = 'genesis__Application__r.genesis__Account__r.Id';
    private static final String GENESIS_APPLICATION_SIGNING_METHOD = 'genesis__Application__r.Signing_Method__c';
    private static final String GENESIS_APPLICATION_ACCOUNT_LEGAL_ENTITY_NAME = 'genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name';
    private static final String GENESIS_APPLICATION_CREDIT_RATING = 'genesis__Application__r.genesis__Credit_Rating__r.Name';
    private static final String GENESIS_APPLICATION_ADDITION_INFO_REQD = 'genesis__Application__r.Additional_Information_Needed__c';
    private static final String GENESIS_APPLICATION_CREDIT_APPLICATION = 'genesis__Application__r.Credit_Application_And_Agreement_Process__c';
    private static final String GENESIS_APPLICATION_MY_PROGRAM = 'genesis__Application__r.My_Program__c';
    private static final String GENESIS_APPLICATION_IS_EVERGREEN = 'genesis__Application__r.Is_Evergreen__c';
    // parameters specific for this class [end]

    /*******************************Declaration of global variables*******************************************/

    private final String CLASS_NAME = PortalApplicationCloneAPI.class.getName();
    String applicationId;
    List<User> loggedInUserList = new List<User>();
    Map<String, Id> mapOfpartyType = new Map<String, Id>();
    clcommon.Response response = new clcommon.Response();
    Map<String, Object> fields = new Map<String, Object>();
    Map<String, SObject> relatedObjects = new Map<String, SObject>();
    List<clcommon.PortalCustomRemoteActionRecord> respData = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon__Party__c existingAppBorrowerParty=new clcommon__Party__c();

    /**
     * @description This constructor will assign the values.
     */
    global PortalApplicationCloneAPI(){
        this.mapOfpartyType = PortalApplicationOriginationHelper.getPartyTypeMap();
        this.loggedInUserList = PortalApplicationOriginationHelper.getLoggedInUser(); 
    }

    /**
    * @description - Purpose of this method is to clone an appliation from a existing application Id.
    * @author Arka Jyoti Deb | 04-28-2022 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                            String[] disclosureNames,
                                            Map<String, Object> argumentsFromPortal) {
        
        Boolean hasPastDueOrIsNonAccrual = false;
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<clcommon__Party__c> newPartyList = new List<clcommon__Party__c>();
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        List<genesis__Applications__c>  existingApplicationList = new List<genesis__Applications__c>();
        List<genesis__Business_Information__c> businessInfoList = new List<genesis__Business_Information__c>();
        SavePoint dbSavePoint = Database.setSavepoint();
        try {
            applicationId = String.valueOf(argumentsFromPortal.get(PortalConstants.APPLICATION_ID));
            checkValidUser();

            Boolean shouldCreateEvergreenApp = false;
            if(argumentsFromPortal.containsKey(KEY_CREATE_EVERGREEN_APPL)){
                shouldCreateEvergreenApp = Boolean.valueOf(argumentsFromPortal.get(KEY_CREATE_EVERGREEN_APPL));
            }
        
            existingApplicationList = [SELECT genesis__Account__c, 
                                             genesis__Contact__c, 
                                             genesis__CL_Product__c, 
                                             genesis__CL_Purpose__c, 
                                             genesis__Term__c,
                                             genesis__Loan_Amount__c,
                                             genesis__Interest_Rate__c,
                                             Internal_Reference_Code__c,
                                             Sales_Agent__c,
                                             Certified_Lender__c,
                                             Dealer_Name__c,
                                             genesis__Pricing_Method__c,
                                             OwnerId,
                                             Signing_Method__c,
                                             Is_Evergreen_Eligible__c,
                                             Dealer_Name__r.Allow_Dealer_Evergreen_Applications__c,
                                             Coop_Type__c,
                                             Dealer_Applicant_Relationship__c,
                                             (SELECT Id,  
                                                    clcommon__Account__r.genesis__Business_Information__r.genesis__Total_Assets__c,
                                                    clcommon__Account__r.genesis__Business_Information__r.genesis__Total_Liabilities__c,
                                                    clcommon__Account__c,
                                                    clcommon__Account__r.genesis__Business_Information__c,
                                                    clcommon__Type__c,
                                                    clcommon__Type__r.Name, 
                                                    clcommon__Contact__c, 
                                                    clcommon__Party_Types__c, 
                                                    genesis__Application__c ,
                                                    Total_Assets__c,
                                                    Total_Liabilities__c,
                                                    Title__c,
                                                    Suffix__c,
                                                    Mobile_Number__c,
                                                    Home_Number__c,
                                                    Work_Number__c,
                                                    Street__c,
                                                    City__c,
                                                    State__c,
                                                    Postal_Code__c,
                                                    County__c,
                                                    Marital_Status__c,
                                                    Gross_Farm_Income__c,
                                                    Dealer_Applicant_Relationship__c,
                                                    genesis__Application__r.Is_Evergreen_Eligible__c
                                                FROM genesis__Parties__r 
                                                WHERE genesis__Application__c = :applicationId
                                                AND clcommon__Type__r.Name IN ( :PortalConstants.BORROWER_PARTY_NAME,
                                                                                :PortalConstants.PRINCIPAL_PARTY_NAME,
                                                                                :PortalConstants.SPOUSE_PARTY_NAME,
                                                                                :PortalConstants.LANDOWNER_PARTY_NAME,
                                                                                :PortalConstants.BUYER_PARTY_NAME,
                                                                                :PortalConstants.INSURANCE_AGENT_PARTY_NAME,
                                                                                :PortalConstants.SALES_AGENT_PARTY_NAME,
                                                                                :PortalConstants.CERTIFIED_LENDER,
                                                                                :PortalConstants.CERTIFIED_LENDER_PLUS,
                                                                                :PortalConstants.INQUIRY,
                                                                                :PortalConstants.INQUIRY_PLUS,
                                                                                :PortalConstants.SALES_AGENT_PLUS,
                                                                                :PortalConstants.DEALER_PARTY_NAME,
                                                                                :PortalConstants.FIELD_STAFF_AGENT,
                                                                                :PortalConstants.SALES_AGENT_ADMIN,
                                                                                :PortalConstants.PAYMENT_ADMINISTRATOR))
                                        FROM genesis__Applications__c 
                                        WHERE Id = :applicationId];

            PortalApplicationOriginationHelper.throwErrorIfTrue(existingApplicationList[0].Is_Evergreen_Eligible__c == false & shouldCreateEvergreenApp == true, PortalConstants.LOAN_IS_NOT_EVERGREEN_ELIGIBLE);

            applicationObj.genesis__CL_Product__c = existingApplicationList[0].genesis__CL_Product__c;
            applicationObj.genesis__Product_Type__c = PortalConstants.LOAN_TYPE;
            applicationObj.genesis__Term__c = existingApplicationList[0].genesis__Term__c;
            applicationObj.genesis__Term__c = PortalConstants.TERM;
            applicationObj.genesis__Loan_Amount__c = existingApplicationList[0].genesis__Loan_Amount__c;
            applicationObj.genesis__Interest_Rate__c = existingApplicationList[0].genesis__Interest_Rate__c;
            applicationObj.Internal_Reference_Code__c = existingApplicationList[0].Internal_Reference_Code__c;
            applicationObj.Sales_Agent__c = existingApplicationList[0].Sales_Agent__c;
            applicationObj.OwnerId = existingApplicationList[0].OwnerId;
            applicationObj.Certified_Lender__c = existingApplicationList[0].Certified_Lender__c;
            applicationObj.Dealer_Name__c = existingApplicationList[0].Dealer_Name__c;
            applicationObj.genesis__Pricing_Method__c = existingApplicationList[0].genesis__Pricing_Method__c;
            applicationObj.genesis__Parent_Application__c = existingApplicationList[0].Id;
            applicationObj.Dealer_Applicant_Relationship__c = existingApplicationList[0].Dealer_Applicant_Relationship__c;
            if(shouldCreateEvergreenApp && 
                (existingApplicationList[0].Coop_Type__c == PortalConstants.GROWMARK_COOP_TYPE || 
                existingApplicationList[0].Dealer_Name__r.Allow_Dealer_Evergreen_Applications__c) ){
                    applicationObj.Is_Evergreen__c = true;
            }
            hasPastDueOrIsNonAccrual = verifyExistingAccounts(existingApplicationList);

            if(hasPastDueOrIsNonAccrual){
                return response;
            }

            accountList = [SELECT Id, 
                                Name,
                                AccountNumber, 
                                genesis__Business_Information__c, 
                                clcommon__Legal_Entity_Type__c,
                                OwnerId,
                                Year_Began_Farming__c
                          FROM Account
                          WHERE Id =: existingApplicationList[0].genesis__Account__c];
            
            contactList = [SELECT Id, 
                                LastName, 
                                FirstName, 
                                Name, 
                                Email, 
                                Suffix__c, 
                                genesis__SSN__c, 
                                Birthdate, 
                                ints__Middle_Name__c 
                          FROM Contact
                          WHERE Id =: existingApplicationList[0].genesis__Contact__c];

             businessInfoList = [ SELECT Id,
                                        genesis__State_of_Incorporation__c,
                                        genesis__Tax_Identification_Number__c,
                                        Gross_Farm_Income__c
                                FROM genesis__Business_Information__c 
                                WHERE Id =: accountList[0].genesis__Business_Information__c ];

            relatedObjects.put(PortalConstants.GENESIS_ACCOUNT_KEY, accountList[0]);
            relatedObjects.put(PortalConstants.GENESIS_CONTACT_KEY, contactList[0]); 
            relatedObjects.put(PortalConstants.GENESIS_BUSINESS_INFORMATION_KEY, businessInfoList[0]);  

            //applicationObj.ERP_Id__c = PortalApplicationCreationHandler.getErpId(accountList[0].Id, loggedInUserList[0].Account.ParentId);
            Map<String,String> identifierMap = PortalApplicationCreationHandler.getIdentifierMap(accountList[0].Id, loggedInUserList[0].Account.ParentId);
            applicationObj.ERP_Id__c = identifierMap.get('erpId');
            applicationObj.Unique_Identifier__c = identifierMap.get('uniqueId');
            applicationObj.Internal_Reference_Code__c = identifierMap.get('irc');

            applicationObj = PortalApplicationOriginationHelper.disableApplicantFields(applicationObj,accountList[0]);

            genesis.BorrowerAPI5 saveAPI = genesis.APIFactory.getBorrowerAPI5();
            genesis__Applications__c appCreated = saveAPI.createApplication(applicationObj, 
                                                                                relatedObjects, 
                                                                                new Map<String, List<Map<String, String>>>(), 
                                                                                false);
            
            PortalApplicationCreationHandler.throwExceptionIfIdIsNull(appCreated.Id, PortalConstants.SOMETHING_WENT_WRONG);
            fields.put(PortalConstants.APPLICATION_ID, appCreated.Id );
            
            newPartyList = createNewParties(existingApplicationList, appCreated);
            Database.insert(newPartyList, true);

            clcommon__party__c newBorrowerParty = updateBorrowerParty(appCreated.Id);
            
            //Update Borrower Party with total assets and liabilities if it is evergreen
            updateBorrowerPartyForEvergreen(existingApplicationList, newBorrowerParty);
            
            genesis__Applications__Share applicationShareObj = new genesis__Applications__Share();
            applicationShareObj.AccessLevel = EDIT;
            applicationShareObj.ParentId = appCreated.Id;
            applicationShareObj.UserOrGroupId = loggedInUserList[0].Id;
            Database.Insert(applicationShareObj, true);

            createSharingRecords(loggedInUserList[0], appCreated);

            Flow.Interview.Update_Dealer_Limits_On_Creation callFlow;
            Map<String,Object> applicationIdMap = new Map<String,Object>();
            applicationIdMap.put(PortalConstants.APPLICATION_ID,applicationId);
            callFlow = new Flow.Interview.Update_Dealer_Limits_On_Creation(applicationIdMap);
            callFlow.start();

            List<genesis__Applications__c> updatedApplicationList = [SELECT Id, 
                                                                        Stage__c,
                                                                        Agreement_Sign__c,
                                                                        My_Program__c,
                                                                        genesis__Account__r.Id,
                                                                        genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                                        genesis__Status__c,
                                                                        Signing_Method__c,
                                                                        genesis__Credit_Rating__r.Name,
                                                                        Additional_Information_Needed__c,
                                                                        Credit_Application_And_Agreement_Process__c,
                                                                        Is_Evergreen__c
                                                                FROM genesis__Applications__c
                                                                WHERE Id = :appCreated.Id
                                                                LIMIT 1];
            
            PortalApplicationOriginationHelper.checkEmptyList(updatedApplicationList, PortalConstants.SOMETHING_WENT_WRONG);        
            
            // crafting the response to be sent to the portal
            fields.put(TRACK_NON_ACCRUAL, false);
            fields.put(TRACK_PAST_DUE, false);
            fields.put(GENESIS_APPLICATION_STATUS, updatedApplicationList[0].genesis__Status__c);
            fields.put(GENESIS_APPLICATION_STAGE, updatedApplicationList[0].Stage__c);
            fields.put(GENESIS_APPLICATION_AGREEMENT_SIGN, updatedApplicationList[0].Agreement_Sign__c);
            fields.put(GENESIS_APPLICATION_ID, updatedApplicationList[0].Id);
            fields.put(GENESIS_APPLICATION_ACCOUNT_ID, updatedApplicationList[0].genesis__Account__r.Id);
            fields.put(GENESIS_APPLICATION_ACCOUNT_LEGAL_ENTITY_NAME, updatedApplicationList[0].genesis__Account__r.clcommon__Legal_Entity_Type__r.Name);
            fields.put(GENESIS_APPLICATION_SIGNING_METHOD, updatedApplicationList[0].Signing_Method__c);
            fields.put(GENESIS_APPLICATION_CREDIT_RATING, updatedApplicationList[0].genesis__Credit_Rating__r.Name);
            fields.put(GENESIS_APPLICATION_ADDITION_INFO_REQD, updatedApplicationList[0].Additional_Information_Needed__c);
            fields.put(GENESIS_APPLICATION_CREDIT_APPLICATION, updatedApplicationList[0].Credit_Application_And_Agreement_Process__c);
            fields.put(GENESIS_APPLICATION_MY_PROGRAM, updatedApplicationList[0].My_Program__c);
            fields.put(GENESIS_APPLICATION_IS_EVERGREEN, updatedApplicationList[0].Is_Evergreen__c);

            respData.add(new clcommon.PortalCustomRemoteActionRecord(fields));
            clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(respData);
            response.content = null;
            response.response = responseFormat.response;
            response.status = clcommon.Constants.SUCCESS;
        } catch (CustomException customException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = customException.getMessage();
            PortalHelper.saveExceptionLog(customException, CLASS_NAME);

        } catch (Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(exceptionObj, CLASS_NAME);

        }
        return response;
    }

    /**
     * @description 
     * @param loggedInUser 
     * @param applicationObj 
     */
    private void createSharingRecords(User loggedInUser, genesis__Applications__c applicationObj) {
        List<clcommon__Relationship__c> relations = [SELECT Id, 
                                                            clcommon__Entity__c,
                                                            clcommon__Related_Entity__c, 
                                                            clcommon__Relationship__r.Name
                                                    FROM clcommon__Relationship__c
                                                    WHERE clcommon__Entity__c = :loggedInUser.Account.ParentId
                                                    AND clcommon__Relationship__r.Name IN (
                                                            :PortalConstants.CERTIFIED_LENDER, 
                                                            :PortalConstants.CERTIFIED_LENDER_PLUS,
                                                            :PortalConstants.INQUIRY,
                                                            :PortalConstants.INQUIRY_PLUS,
                                                            :PortalConstants.FIELD_STAFF_AGENT
                                                        )
                                                    ];
      
        List<String> relationIdList = new List<String>();

        for (clcommon__Relationship__c relation : relations) {
            // getting all the certified lenders account id in a list  
            relationIdList.add(relation.clcommon__Related_Entity__c);
        }

        List<User> dealerUsers;

        if (applicationObj.Sales_Agent__c == null) {
            dealerUsers = [
                    SELECT Id,
                            Account.RecordType.Name 
                    FROM User 
                    WHERE AccountId IN :relationIdList
                ];
        } else {
            dealerUsers = [
                    SELECT Id,
                            Account.RecordType.Name 
                    FROM User 
                    WHERE AccountId IN :relationIdList
                    OR AccountId = :applicationObj.Sales_Agent__c
                ];
        }

        List<clcommon__Document_Category__c> documentCategories = [SELECT Id 
                                                                   FROM clcommon__Document_Category__c 
                                                                   WHERE genesis__Application__c = :applicationObj.Id];

        List<genesis__Applications__Share> applicationSharingRecords = new List<genesis__Applications__Share>();
        List<clcommon__Document_Category__Share> documentSharingRecords = new List<clcommon__Document_Category__Share>();

        for (User dealerUser : dealerUsers) {
            genesis__Applications__Share applicationSharingRecord = new genesis__Applications__Share();

            applicationSharingRecord.AccessLevel = EDIT;
            applicationSharingRecord.ParentId = applicationObj.Id;
            applicationSharingRecord.UserOrGroupId = dealerUser.Id;

            applicationSharingRecords.add(applicationSharingRecord);

            for (clcommon__Document_Category__c documentCategory : documentCategories) {

                clcommon__Document_Category__Share documentSharingRecord = new clcommon__Document_Category__Share();

                documentSharingRecord.AccessLevel = EDIT;
                documentSharingRecord.ParentId = documentCategory.Id;
                documentSharingRecord.UserOrGroupId = dealerUser.Id;

                documentSharingRecords.add(documentSharingRecord);
            }
        }

        Database.upsert(applicationSharingRecords, false);
        Database.upsert(documentSharingRecords, false);
    }

    /**
     * @description - Purpose of this method is to update the borrower party
     * @author Arka Jyoti Deb | 04-28-2022 
     * @param applicationId 
     * @return  `clcommon__party__c`
     */
    private clcommon__party__c updateBorrowerParty(String applicationId){
        List<clcommon__party__c> borrowerPartyList = [SELECT Id,
                                                            clcommon__Contact__c,
                                                            Total_Assets__c,
                                                            Total_Liabilities__c
                                                     FROM clcommon__party__c
                                                     WHERE genesis__Application__c =: applicationId
                                                     AND clcommon__Type__r.Name =: PortalConstants.BORROWER_PARTY_NAME];

        genesis__Applications__c applicationObj = [SELECT Id,
                                                          genesis__Contact__c,
                                                          genesis__Account__c
                                                   FROM genesis__Applications__c
                                                   WHERE Id =: applicationId];
        clcommon__Party__c partyObj = new clcommon__Party__c();
        if (borrowerPartyList==null || borrowerPartyList.isEmpty()){
            
            partyObj.genesis__Application__c = applicationId;
            partyObj.clcommon__Account__c = applicationObj.genesis__Account__c;
            partyObj.clcommon__Contact__c = applicationObj.genesis__Contact__c;
            List<clcommon__Party_Type__c> partyType = [SELECT Id
                                                       FROM clcommon__Party_Type__c
                                                       WHERE NAME =: PortalConstants.BORROWER_PARTY_NAME];
            partyObj.clcommon__Type__c = partyType[0].Id;
            partyObj.clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;
            updateApplicantPartyDetails(partyObj,existingAppBorrowerParty);
            Database.insert(partyObj, false);
            borrowerPartyList.add(partyObj);
        }
        else{
            borrowerPartyList[0].clcommon__Contact__c = applicationObj.genesis__Contact__c;
            borrowerPartyList[0].clcommon__Party_Types__c = PortalConstants.BORROWER_PARTY_NAME;
            updateApplicantPartyDetails(borrowerPartyList[0],existingAppBorrowerParty);
            Database.update(borrowerPartyList, false);    
        }
        List<Contact> contactList = [SELECT Id, 
                                     AccountId
                              FROM Contact
                              WHERE Id = :applicationObj.genesis__Contact__c];
        contactList[0].AccountId = applicationObj.genesis__Account__c;
        Database.update(contactList);

        List<Account> accountList=[SELECT ID,
                                            ParentId
                                    FROM Account
                                    WHERE ID= :applicationObj.genesis__Account__c];
        accountList[0].ParentId=loggedInUserList[0].Account.PArentId;
        Database.update(accountList,true);
            
        return borrowerPartyList[0];

    } 

    
    /**
    * @description updates the details of the borrower party from the previous application to this application
    * @author Rakesh Saraf | 12-12-2024 
    * @param partyObj 
    * @param existingPartyObj 
    **/
    private static void updateApplicantPartyDetails(clcommon__Party__c partyObj,clcommon__Party__c existingPartyObj){
        
        PortalApplicationOriginationHelper.throwErrorIfTrue(existingPartyObj==null, PortalConstants.SOMETHING_WENT_WRONG);

        partyObj.Title__c=existingPartyObj.Title__c;
        partyObj.Suffix__c	=existingPartyObj.Suffix__c;

        partyObj.Gross_Farm_Income__c=existingPartyObj.Gross_Farm_Income__c;
        
        partyObj.Street__c=existingPartyObj.Street__c;
        partyObj.City__c=existingPartyObj.City__c;
        partyObj.State__c=existingPartyObj.State__c;
        partyObj.Postal_Code__c=existingPartyObj.Postal_Code__c;
        partyObj.County__c=existingPartyObj.County__c;

        partyObj.Home_Number__c=existingPartyObj.Home_Number__c;
        partyObj.Work_Number__c=existingPartyObj.Work_Number__c;
        partyObj.Mobile_Number__c=existingPartyObj.Mobile_Number__c;

        partyObj.Marital_Status__c=existingPartyObj.Marital_Status__c;

        partyObj.Dealer_Applicant_Relationship__c=existingPartyObj.Dealer_Applicant_Relationship__c;
    }

    /**
     * @description This method will update parties for evergreen.
     * @param existingApplicationList 
     * @param newBorrowerParty 
     */
    private void updateBorrowerPartyForEvergreen(List<genesis__Applications__c> existingApplicationList, clcommon__party__c newBorrowerParty){
        if(existingApplicationList[0].Is_Evergreen_Eligible__c == true){
            //Query Borrower Party and copy the details to the new party thus created
            List<clcommon__Party__c> borrowerPartyExisting = [SELECT Id, 
                                                                    Total_Assets__c, 
                                                                    Total_Liabilities__c 
                                                            FROM clcommon__Party__c 
                                                            WHERE genesis__Application__c = :existingApplicationList[0].Id AND 
                                                            clcommon__party_Types__c = :PortalConstants.BORROWER_PARTY_NAME];
            if(borrowerPartyExisting.size()>0 && borrowerPartyExisting[0].Total_Assets__c != null){
                newBorrowerParty.Total_Assets__c = borrowerPartyExisting[0].Total_Assets__c;
            }
            if(borrowerPartyExisting.size()>0 && borrowerPartyExisting[0].Total_Liabilities__c != null ){
                newBorrowerParty.Total_Liabilities__c = borrowerPartyExisting[0].Total_Liabilities__c;
            }
            Database.update(newBorrowerParty,true);
        }
    }

    /**
     * @description This method will create new parties to clone app.
     * @param existingApplicationList 
     * @param appCreated 
     * @return  `List<clcommon__Party__c>`
     */
    private List<clcommon__Party__c> createNewParties(List<genesis__Applications__c> existingApplicationList, genesis__Applications__c appCreated){
        List<clcommon__Party__c> newPartyList = new List<clcommon__Party__c>();
        List<Id> principalAccountIdList=new List<Id>();
        List<Account> principalAccToUpdateList = new List<Account>();

        for (clcommon__Party__c eachExistingParty: existingApplicationList[0].genesis__Parties__r) {
            if(eachExistingParty.clcommon__Party_Types__c==PortalConstants.BORROWER_PARTY_NAME){
                existingAppBorrowerParty=eachExistingParty;
                continue;
            }
            clcommon__Party__c partyObj = new clcommon__Party__c();
            partyObj.genesis__Application__c = appCreated.Id;
            partyObj.clcommon__Account__c = eachExistingParty.clcommon__Account__c;
            partyObj.clcommon__Contact__c = eachExistingParty.clcommon__Contact__c;
            partyObj.clcommon__Type__c = eachExistingParty.clcommon__Type__c;
            partyObj.clcommon__Party_Types__c = eachExistingParty.clcommon__Type__r.Name;
            if(eachExistingParty.genesis__Application__r.Is_Evergreen_Eligible__c == true &
                eachExistingParty.clcommon__Party_Types__c == PortalConstants.PRINCIPAL_PARTY_NAME){
                    if(eachExistingParty.Total_Assets__c != null){
                        partyObj.Total_Assets__c = eachExistingParty.Total_Assets__c;
                    }
                    if(eachExistingParty.Total_Liabilities__c != null){
                        partyObj.Total_Liabilities__c = eachExistingParty.Total_Liabilities__c;
                    }

            }
            if(eachExistingParty.clcommon__Party_Types__c == PortalConstants.PRINCIPAL_PARTY_NAME){
                principalAccountIdList.add(eachExistingParty.clcommon__Account__c);
                updateApplicantPartyDetails(partyObj, eachExistingParty);
            }
            newPartyList.add(partyObj);
        }

        principalAccToUpdateList=[SELECT Id,
                                         ParentId
                                  FROM Account
                                  WHERE Id IN :principalAccountIdList];
        for(Account eachAccount:principalAccToUpdateList){
            eachAccount.ParentId=loggedInUserList[0].Account.ParentId;
        }
        Database.update(principalAccToUpdateList);
        return newPartyList;
    }

     /**
     * @description This method will check the user is valid or not.
     */
    private void checkValidUser(){

        Boolean isValidUser = false;
        PortalApplicationOriginationHelper.checkBlankParameter(applicationId,PortalConstants.SOMETHING_WENT_WRONG);

        isValidUser = PortalSecurityUtil.validateUserApplication(applicationId); 
        PortalApplicationOriginationHelper.checkValidUser(isValidUser);
    }

    /**
    * @description : Verify Existing Accounts
    * @author  Pritam Roy | 06-20-2024 
    * @param userAppList 
    * @return Boolean 
    **/
    private Boolean verifyExistingAccounts(List<genesis__Applications__c> userAppList){
        Boolean trackNonAccrual = false;
        Boolean trackHasPastDue = false;
        Boolean hasPastDueOrIsNonAccrual = false;
        List<clcommon__Party__c> verifyPartyList = [SELECT Id,  
                                                                Dealer_Applicant_Relationship__r.Has_Past_Due__c,
                                                                Dealer_Applicant_Relationship__r.Is_Non_Accrual__c,
                                                                clcommon__Type__r.Name
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__c = :userAppList[0].Id
                                                            AND clcommon__Type__r.Name IN (
                                                                :PortalConstants.PRINCIPAL_PARTY_NAME,
                                                                :PortalConstants.BORROWER_PARTY_NAME)
                                                            ];
        for(clcommon__Party__c eachExistingParty: verifyPartyList){
            if(eachExistingParty.Dealer_Applicant_Relationship__r.Has_Past_Due__c == true){
                trackHasPastDue = true;
                hasPastDueOrIsNonAccrual = true;
            }
            if(eachExistingParty.Dealer_Applicant_Relationship__r.Is_Non_Accrual__c == true){
                trackNonAccrual = true;
                hasPastDueOrIsNonAccrual = true;
            }
        }
        if(trackHasPastDue | trackNonAccrual){
            fields.put(TRACK_PAST_DUE, trackHasPastDue);
            fields.put(TRACK_NON_ACCRUAL, trackNonAccrual);
            respData.add(new clcommon.PortalCustomRemoteActionRecord(fields));
            clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(respData);
            response.content = null;
            response.response = responseFormat.response;
            response.status = clcommon.Constants.SUCCESS;
        }
        return hasPastDueOrIsNonAccrual;
    }
             
}