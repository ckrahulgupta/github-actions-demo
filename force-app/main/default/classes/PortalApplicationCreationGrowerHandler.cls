/**
 * @description       : 
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 02-15-2025
 * @last modified by  : Rakesh Saraf
**/
global without sharing class PortalApplicationCreationGrowerHandler{
    private static final String INDIVIDUAL_SSN = 'ssn';
    private static final String INDIVIDUAL_CONFIRM_SSN = 'confirmSSN';
    private static final String KEY_GROWER_RECORD_TYPE_NOT_EXISTS = 'Grower record type does not exist';


    Account objUserAccount = new Account();
    Contact objUserContact = new Contact();

/**
 * @author  Pritam Roy | 06-17-2024 
 * @description
 */
    global class DBAWrapper{
        global Account accountObj;
        global Contact contactObj;
    }
    
    
    /**
    * @description : Set Relation
    * @author  Pritam Roy | 06-20-2024 
    * @param relationContactList 
    * @param applicationObj 
    * @return List<clcommon__party__c> 
    **/
    public static List<clcommon__party__c> setRelation(List<Contact> relationContactList,genesis__Applications__c applicationObj){
        Map<String, Id> mapOfpartyType = PortalHelper.getPartyTypeMap();
        List<clcommon__Party__c> objPartyList = new List<clcommon__Party__c>();
        for (Contact relationContact : relationContactList) {

            clcommon__Party__c relationParty = new clcommon__Party__c();

            relationParty.genesis__Application__c = applicationObj.Id;
            relationParty.clcommon__Account__c = relationContact.Account.Id;
            relationParty.clcommon__Contact__c = relationContact.Id;

            if (relationContact.Account.RecordType.Name == PortalConstants.CERTIFIED_LENDER) {
                relationParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.CL_PARTY_NAME);
                relationParty.clcommon__Party_Types__c = PortalConstants.CL_PARTY_NAME;
            }

            if (relationContact.Account.RecordType.Name == PortalConstants.CERTIFIED_LENDER_PLUS) {
                relationParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.CL_PLUS_PARTY_NAME);
                relationParty.clcommon__Party_Types__c = PortalConstants.CL_PLUS_PARTY_NAME; 
            }

            if (relationContact.Account.RecordType.Name == PortalConstants.INQUIRY) {
                relationParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.INQUIRY_PARTY_NAME);
                relationParty.clcommon__Party_Types__c = PortalConstants.INQUIRY_PARTY_NAME; 
            }

            if (relationContact.Account.RecordType.Name == PortalConstants.INQUIRY_PLUS) {
                relationParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.INQUIRY_PLUS_PARTY_NAME);
                relationParty.clcommon__Party_Types__c = PortalConstants.INQUIRY_PLUS_PARTY_NAME; 
            }
            if(relationContact.Account.RecordType.Name == PortalConstants.FIELD_STAFF_AGENT){
                relationParty.clcommon__Type__c = mapOfpartyType.get(PortalConstants.FIELD_STAFF_AGENT_PARTY);
                relationParty.clcommon__Party_Types__c = PortalConstants.FIELD_STAFF_AGENT_PARTY; 
            }

            objPartyList.add(relationParty); 
        }
        return objPartyList;
    }
    
    /**
    * @description : check Details
    * @author  Pritam Roy | 06-17-2024 
    * @param accountObj 
    * @param businessInfoObj 
    * @param borrowerContactObj 
    * @return DBAWrapper 
    **/
    public static PortalApplicationCreationGrowerHandler.DBAWrapper checkDetails(Account accountObj,genesis__Business_Information__c businessInfoObj,Contact borrowerContactObj){
        DBAWrapper objGetWrapper = new DBAWrapper();

        List<Account> accountWithSameTaxInfo = [SELECT id,
                                                       Name,
                                                       Kyc_Verified__c,
                                                       clcommon__Email__c,
                                                       Confirm_Email__c,
                                                       clcommon__Legal_Entity_Type__c,
                                                       genesis__Business_Information__c
                                            FROM account 
                                            WHERE genesis__Business_Information__r.genesis__Tax_Identification_Number__c = :businessInfoObj.genesis__Tax_Identification_Number__c];
        if(!accountWithSameTaxInfo.isEmpty()){
            List<Contact> duplicateContact = [SELECT id,
                                                    FirstName,
                                                    LastName 
                                                FROM Contact
                                                WHERE AccountId = :accountWithSameTaxInfo[0].id];

            PortalApplicationOriginationHelper.checkEmptyList(duplicateContact, PortalConstants.SOMETHING_WENT_WRONG);

            accountObj.Id = accountWithSameTaxInfo[0].Id;
            accountObj.genesis__Business_Information__c = accountWithSameTaxInfo[0].genesis__Business_Information__c;
            borrowerContactObj.id = duplicateContact[0].id;

            if(accountWithSameTaxInfo[0].Kyc_Verified__c){
                accountObj.name = accountWithSameTaxInfo[0].Name ;
                accountObj.clcommon__Email__c = accountWithSameTaxInfo[0].clcommon__Email__c ;
                accountObj.Confirm_Email__c = accountWithSameTaxInfo[0].Confirm_Email__c ;
                accountObj.clcommon__Legal_Entity_Type__c = accountWithSameTaxInfo[0].clcommon__Legal_Entity_Type__c ;
            }
            else{
                borrowerContactObj.LastName=accountObj.name;
            }
        }else{
            objGetWrapper = populateDBADetails(accountObj,borrowerContactObj);
            accountObj = objGetWrapper.accountObj;
            borrowerContactObj = objGetWrapper.contactObj;
        }
        DBAWrapper objWrapper = new DBAWrapper();
        objWrapper.accountObj = accountObj;
        objWrapper.contactObj = borrowerContactObj;

        return objWrapper;
    }


    /**
    * @description : populateDBADetails
    * @author  Pritam Roy | 06-20-2024 
    * @param accountObj 
    * @param borrowerContactObj 
    * @return PortalApplicationCreationGrowerHandler.DBAWrapper 
    **/
    public static PortalApplicationCreationGrowerHandler.DBAWrapper populateDBADetails(Account accountObj, Contact borrowerContactObj){
        PortalApplicationCreationGrowerHandler.DBAWrapper wrapperObj = new PortalApplicationCreationGrowerHandler.DBAWrapper();
        accountObj.Is_Individual__c = false;
        accountObj.Work_Number__c = ConstantValues.EMPTY_STRING;
        accountObj.Home_Number__c = ConstantValues.EMPTY_STRING;
        accountObj.Phone = ConstantValues.EMPTY_STRING;
        accountObj.clcommon__Email__c = ConstantValues.EMPTY_STRING;
        accountObj.Confirm_Email__c = ConstantValues.EMPTY_STRING;
        accountObj.OwnerId = PortalSecurityUtil.getSiteAdmin();
        List<RecordType> recordType = [ SELECT id,
                                            Name
                                        FROM RecordType
                                        WHERE Name = :PortalConstants.GROWER_PROFILE];
        PortalApplicationOriginationHelper.checkEmptyList(recordType, KEY_GROWER_RECORD_TYPE_NOT_EXISTS);
        accountObj.RecordTypeId = recordType[0].id;

        // details for the primary applicant contact - business / dba
        // String firstName = accountObj.Name.Substring(0,accountObj.Name.indexOf(PortalConstants.SPACE_STRING));
        String lastName = accountObj.Name; 
        borrowerContactObj.LastName = lastName;
        borrowerContactObj.AccountId = null;
        borrowerContactObj.genesis__SSN__c = null;
        borrowerContactObj.Confirm_SSN__c = null;
        borrowerContactObj.Email = null;
        borrowerContactObj.Confirm_Email__c = null;
        wrapperObj.accountObj = accountObj;
        wrapperObj.contactObj = borrowerContactObj;
        return wrapperObj;
    }

    /**
    * @description : Validate Logged In Grower SSN
    * @author Sk Minsar | 01-29-2024 
    * @param contactObj 
    **/
    public static void validateLoggedInGrowerSSN(Contact contactObj){
        
        List<Contact> contactList = [SELECT Id
                                     FROM Contact
                                     WHERE genesis__SSN__c =:contactObj.genesis__SSN__c ];//OR Id NOT IN (SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId())];
        if(!contactList.isEmpty()){
            List<User> userList = [ SELECT Id 
                                    FROM User 
                                    WHERE ContactId = :contactList[0].Id];
            //PortalApplicationCreationGrowerAPI.checkEmptyList(userList,PortalConstants.DUPLICATE_SSN_OR_EMAIL);
            if(userList[0].Id != UserInfo.getUserId()){
                //userList.size() > 0 &&  condition in  if not needed
                throw new CustomException(PortalConstants.DUPLICATE_SSN_OR_EMAIL);
            }
        }
    }
     
    
    /**
    * @description : Check Sole Prop Details
    * @author  Pritam Roy | 06-20-2024 
    * @param businessInfoObj 
    * @param entityName 
    * @param accountObj 
    * @return Account 
    **/
    public static Account checkSolePropDetails(genesis__Business_Information__c businessInfoObj,String entityName,Account accountObj){

        if(entityName != PortalConstants.INDIVIDUAL && entityName != PortalConstants.SOLE_PROP_ENTITY){
            
            if(!String.isBlank(accountObj.genesis__Business_Information__c)){
                return accountObj;
            }
            genesis__Business_Information__c borrorwerBusinessInfoObj = new genesis__Business_Information__c();
            borrorwerBusinessInfoObj.genesis__Tax_Identification_Number__c = businessInfoObj.genesis__Tax_Identification_Number__c;
            borrorwerBusinessInfoObj.Confirm_Tax_Identification_Number__c = borrorwerBusinessInfoObj.genesis__Tax_Identification_Number__c;
            Database.insert(borrorwerBusinessInfoObj,true);
            accountObj.genesis__Business_Information__c = borrorwerBusinessInfoObj.id;
        }
        return accountObj;
    }

    /**
    * @description : setSSN
    * @author  Pritam Roy | 06-17-2024 
    * @param entityName 
    * @param contactList 
    * @param request 
    * @return List<Contact> 
    **/
    public static List<Contact> setSSN(String entityName,List<Contact> contactList,Map<String, Object> request){
        String individualSSN = String.valueOf(request.get(INDIVIDUAL_SSN));
        String individualConfirmSSN = String.valueOf(request.get(INDIVIDUAL_CONFIRM_SSN));
        if (entityName == PortalConstants.SOLE_PROP_ENTITY) {
            if(!String.isBlank(individualSSN) && contactList[0].genesis__SSN__c == null){
                contactList[0].genesis__SSN__c = individualSSN;
            }
            if(!String.isBlank(individualConfirmSSN) && contactList[0].Confirm_SSN__c == null){
                contactList[0].Confirm_SSN__c = individualConfirmSSN;
            }
        }
        return contactList;
    }

   
    /**
    * @description : Update Certifed Lender
    * @author  Pritam Roy | 06-20-2024 
    * @param clRelationshipList 
    * @param relationshipList 
    * @param applicationObj 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c updateCertifiedLender(List<clcommon__Relationship__c> clRelationshipList,List<clcommon__Relationship__c> relationshipList,genesis__Applications__c applicationObj){
        if (clRelationshipList.size() > 0 && 
            (relationshipList[0].clcommon__Relationship__r.Name == PortalConstants.SALES_AGENT || 
            relationshipList[0].clcommon__Relationship__r.Name == PortalConstants.SALES_AGENT_PLUS)) {
                
            applicationObj.Certified_Lender__c = clRelationshipList[0].clcommon__Related_Entity__c;
        }
        return applicationObj;
    }

        
    /**
    * @description : Update Party
    * @author  Pritam Roy | 06-20-2024 
    * @param relationshipList 
    * @param applicationObj 
    * @param clPartyObj 
    * @return List<clcommon__party__c> 
    **/
    public static List<clcommon__party__c> updateParty(List<clcommon__Relationship__c> relationshipList,genesis__Applications__c applicationObj,clcommon__Party__c clPartyObj){
        Map<String, Id> mapOfpartyType = PortalHelper.getPartyTypeMap();
        Map<String,String> roleToPartyTypeMap = new Map<String,String>{
            PortalConstants.SALES_AGENT_PLUS => PortalConstants.SALES_AGENT_PLUS_PARTY_NAME,
            PortalConstants.SALES_AGENT => PortalConstants.SALES_AGENT_PARTY_NAME
        };

        List<clcommon__party__c> objPartyList = new List<clcommon__party__c>();
        if(relationshipList[0].clcommon__Relationship__r.Name == PortalConstants.CERTIFIED_LENDER 
            | relationshipList[0].clcommon__Relationship__r.Name == PortalConstants.CERTIFIED_LENDER_PLUS){
            applicationObj.Certified_Lender__c = relationshipList[0].clcommon__Related_Entity__c;
        }
        else if(relationshipList[0].clcommon__Relationship__r.Name == PortalConstants.SALES_AGENT
        || relationshipList[0].clcommon__Relationship__r.Name == PortalConstants.SALES_AGENT_PLUS){
            applicationObj.Sales_Agent__c = relationshipList[0].clcommon__Related_Entity__c;
            clPartyObj.clcommon__Type__c = mapOfpartyType.get(roleToPartyTypeMap.get(relationshipList[0].clcommon__Relationship__r.Name));
            clPartyObj.clcommon__Party_Types__c = roleToPartyTypeMap.get(relationshipList[0].clcommon__Relationship__r.Name);
            objPartyList.add(clPartyObj);
        }
        return objPartyList;
    }

    /**
    * @description this method creates a dealer Applicant Relationship for the grower if it is not already created.
    * @author Rakesh Saraf | 12-11-2024 
    * @param paramMap
    * @return Id 
    **/
    public static Id processDealerGrowerRelationship(Map<String,Object> paramMap){
        Contact contactObj=(Contact) paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        Account accountObj=(Account) paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        genesis__Applications__c applicationObj=(genesis__Applications__c) paramMap.get(PortalConstants.APPLICATION_OBJ_KEY);
        Dealer_Applicant_Relationship__c dealerGrowerRelObj;

        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList=[ SELECT ID,
                                                                              Is_Non_Accrual__c,
                                                                              Has_Past_Due__c
                                                                        FROM Dealer_Applicant_Relationship__c
                                                                        WHERE Applicant__c=: accountObj.id
                                                                        AND Dealer__c=: applicationObj.Dealer_Name__c];

        if(dealerApplicantRelList.isEmpty()){
            dealerGrowerRelObj=new Dealer_Applicant_Relationship__c();
            dealerGrowerRelObj.Dealer__c=applicationObj.Dealer_Name__c;
            dealerGrowerRelObj.Applicant__c=accountObj.id;
            dealerGrowerRelObj.Applicant_Contact__c=contactObj.id;

            Database.insert(dealerGrowerRelObj,true);
            dealerApplicantRelList.add(dealerGrowerRelObj);
        }
        applicationObj.Dealer_Applicant_Relationship__c=dealerApplicantRelList[0].id;

        Database.update(applicationObj, true);
        return dealerApplicantRelList[0].id;
    }
}