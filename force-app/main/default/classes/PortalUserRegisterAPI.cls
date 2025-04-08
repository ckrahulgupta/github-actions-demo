/**
 * @description       : Create user,account and contact from register page
 * @author            :  Bijay Shaw
 * @group             : 
 * @last modified on  : 14-02-2025
 * @last modified by  : Soumik Pattanayak
**/

global without sharing class PortalUserRegisterAPI implements clcommon.PortalCustomRemoteAPI1{
    private final String CLASS_NAME = String.valueOf(this).substring(0,String.valueOf(this).indexOf(':'));  

    private static final String KEY_FIRST_NAME = 'firstName';
    private static final String KEY_LAST_NAME = 'lastName';
    private static final String KEY_PHONE_NUMBER = 'phone';
    private static final String KEY_SSN = 'ssn';
    private static final String KEY_CONFIRM_EMAIL = 'confirmEmail';
    private static final String KEY_EMAIL = 'email';
    private static final String KEY_ACCOUNT = 'Account';
    private static final String KEY_FEDERATION_IDENTIFIER = 'federationIdentifier';
    private static final String KEY_REDIRECT_TO_SSO_FLAG = 'redirectToSSO';
    private static final String KEY_ACC_FULL_NAME = 'fullName';
    private static final String KEY_ACC_LEGAL_ENTITY = 'legalEntity';
    private static final String KEY_ACC_EMAIL = 'accEmail';
    private static final String KEY_ACC_CONFIRM_EMAIL = 'accConfirmEmail';
    private static final String KEY_ACC_PHONE_NUMBER = 'accphoneNumber';
    private static final String KEY_ACC_RECORD_TYPE = 'recordType';
    private static final String KEY_CONTACT_FIRST_NAME = 'contFirstName';
    private static final String KEY_CONTACT_LAST_NAME = 'contLastName';
    private static final String KEY_CONTACT_PHONE_NUMBER = 'contPhoneNumber';
    private static final String KEY_CONTACT_EMAIL = 'contEmail';
    private static final String KEY_CONTACT_SSN = 'contSSN';
    private static final String INVALID_CIF = 'Invalid Dealer CIF';
    private static final String KEY_ACC_PARENT_ID = 'parentId';

    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();
    
    /**
    * @description : create Business Info method
    * @author  Pritam Roy | 03-12-2024 
    * @return List<genesis__Business_Information__c> 
    **/
    public static List<genesis__Business_Information__c> createBusinessInfo(){
        List<genesis__Business_Information__c> businessInfoList = new List<genesis__Business_Information__c>();
        genesis__Business_Information__c businessTempObj = new genesis__Business_Information__c();
        businessTempObj.genesis__Total_Assets__c = PortalConstants.ZERO_VALUE;
        businessTempObj.genesis__Total_Liabilities__c = PortalConstants.ZERO_VALUE;
        businessInfoList.add(businessTempObj);
        Database.insert(businessInfoList,true);
        return businessInfoList;
    }

    
    /**
    * @description : create Account method
    * @author  Pritam Roy | 03-12-2024 
    * @param businessInfoId 
    * @param accInfoMap 
    * @return List<Account> 
    **/
    public static List<Account> createAccount(Id businessInfoId , Map<String,String> accInfoMap){
        List<Account> accountList = new List<Account>();
        Account userAccountobj = new Account();
        userAccountobj.genesis__Business_Information__c = businessInfoId;
        userAccountobj.Name = accInfoMap.get(KEY_ACC_FULL_NAME);
        userAccountobj.clcommon__Legal_Entity_Type__c = accInfoMap.get(KEY_ACC_LEGAL_ENTITY);
        userAccountobj.clcommon__Email__c = accInfoMap.get(KEY_ACC_EMAIL);
        userAccountobj.Phone = accInfoMap.get(KEY_ACC_PHONE_NUMBER);
        userAccountobj.Coop_Type__c = PortalConstants.LANDUS_COOP_TYPE;
        userAccountobj.RecordTypeId = accInfoMap.get(KEY_ACC_RECORD_TYPE);
        userAccountobj.Confirm_Email__c = accInfoMap.get(KEY_ACC_CONFIRM_EMAIL);
        userAccountobj.parentId = accInfoMap.get(KEY_ACC_PARENT_ID);

        List<CFA_Configuration__c> latestCIFList = [SELECT CIF_Number__c
                                            FROM CFA_Configuration__c
                                            LIMIT 1];

        userAccountobj.CIF_Number__c = String.valueOf(latestCIFList[0].CIF_Number__c);
        userAccountobj.OwnerId = PortalSecurityUtil.getSiteAdmin();
        latestCIFList[0].CIF_Number__c = String.valueOf(Decimal.valueOf(latestCIFList[0].CIF_Number__c) + PortalConstants.ONE_VALUE);
        Database.update(latestCIFList,true);
        accountList.add(userAccountobj);
        Database.insert(accountList, true);
        return accountList;
    }

    
    /**
    * @description : create contact method
    * @author  Pritam Roy | 03-12-2024 
    * @param accountId 
    * @param contactInfoMap 
    * @return List<Contact> 
    **/
    public static List<Contact> createContact(Id accountId , Map<String,String> contactInfoMap){
        List<Contact> contactList = new List<Contact>();
        Contact userContactobj = new Contact();
        userContactobj.FirstName = contactInfoMap.get(KEY_CONTACT_FIRST_NAME);
        userContactobj.LastName = contactInfoMap.get(KEY_CONTACT_LAST_NAME);
        userContactobj.MobilePhone = contactInfoMap.get(KEY_CONTACT_PHONE_NUMBER);
        userContactobj.Email = contactInfoMap.get(KEY_CONTACT_EMAIL);
        userContactobj.Confirm_Email__c =  contactInfoMap.get(KEY_CONTACT_EMAIL);
        userContactobj.AccountId = accountId;
        userContactobj.Confirm_SSN__c = contactInfoMap.get(KEY_CONTACT_SSN);
        userContactobj.genesis__SSN__c = contactInfoMap.get(KEY_CONTACT_SSN);
        contactList.add(userContactobj);
        Database.insert(contactList, true);
        return contactList;
    }
    
    /**
    * @description : checking RecordType
    * @author  Pritam Roy | 03-12-2024 
    * @return List<RecordType> 
    **/
    private List<RecordType> checkRecordType(){
        List<RecordType> recordType = [SELECT id,
                                                Name
                                        FROM RecordType
                                        WHERE Name =:PortalConstants.GROWER_PROFILE
                                        AND SobjectType =: KEY_ACCOUNT];

        PortalApplicationOriginationHelper.checkEmptyList(recordType, PortalConstants.SOMETHING_WENT_WRONG);
        return recordType;
    }
    
    /**
    * @description : Checking Legal Entity
    * @author  Pritam Roy | 03-12-2024 
    * @return List<clcommon__Legal_Entity__c> 
    **/
    private List<clcommon__Legal_Entity__c> checkLegalEntity(){
        List<clcommon__Legal_Entity__c> legalEntityTypeList = [SELECT id,
                                                                        Name
                                                                FROM clcommon__Legal_Entity__c
                                                                WHERE Name = :PortalConstants.SOLE_PROP_ENTITY];

        PortalApplicationOriginationHelper.checkEmptyList(legalEntityTypeList, PortalConstants.SOMETHING_WENT_WRONG);
        return legalEntityTypeList;
    }
    
    /**
    * @description : Validating Required Parameter
    * @author  Pritam Roy | 03-12-2024 
    * @param request 
    **/
    private void validateRequestParameters(Map<String, Object> request){
        if (request.get(KEY_EMAIL) == null 
                || request.get(KEY_PHONE_NUMBER) == null 
                || request.get(KEY_FIRST_NAME) == null 
                || request.get(KEY_LAST_NAME) == null 
                || request.get(KEY_SSN) == null 
                || request.get(KEY_CONFIRM_EMAIL) == null) {
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }
    
    /**
    * @description : Check Existing Contact
    * @author  Pritam Roy | 03-12-2024 
    * @param ssn 
    * @return List<Contact> 
    **/
    private List<Contact> checkExistingContact(String ssn){
        List<Contact> existingContactList = [SELECT id,
                                                    name,
                                                    AccountId,
                                                    Account.CIF_Number__c,
                                                    FirstName,
                                                    LastName,
                                                    Email
                                                FROM Contact
                                                WHERE genesis__SSN__c = :ssn];
        return existingContactList;
    }
    
    /**
    * @description : Check Existing User
    * @author  Pritam Roy | 03-12-2024 
    * @param existingContactList 
    * @return List<USER>
    **/
    private static List<USER> checkExistingUser(List<Contact> existingContactList){
        List<USER> userObjList = new List<USER>();
        if(!existingContactList.isEmpty()){
            userObjList = [SELECT id,
                                name
                            FROM USER 
                            WHERE contactId = :existingContactList[0].id];
        }return userObjList;
    }

    /**
    * @description : Method called from portal to create account,contact from register page
    * @author  Pritam Roy | 03-12-2024 
    * @param componentStructureName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStructureName,String[] disclosureNames,Map<String, Object> request) {
        SavePoint dbSavePoint = Database.setSavepoint();
        
        try{
            String accountName = PortalConstants.EMPTY_STRING;
            String firstName = PortalConstants.EMPTY_STRING;
            String lastName = PortalConstants.EMPTY_STRING;
            String ssn = PortalConstants.EMPTY_STRING;
            String emailAddress = PortalConstants.EMPTY_STRING;
            String confirmEmailAddress = PortalConstants.EMPTY_STRING;
            String phoneNumber = PortalConstants.EMPTY_STRING;

            Boolean redirectToSSOFlag = request.containsKey(KEY_FEDERATION_IDENTIFIER);
            Map<String,Object> fieldMap = new Map<String,Object>{
                KEY_REDIRECT_TO_SSO_FLAG => (request.get(KEY_FEDERATION_IDENTIFIER) == null) ? false : true
            };
            String federationIdentifier = redirectToSSOFlag ? String.valueOf(request.get(KEY_FEDERATION_IDENTIFIER)) : PortalConstants.EMPTY_STRING;
            New_Portal_User__e newUserObj = new New_Portal_User__e();

            validateRequestParameters(request);

            firstName = String.valueOf(request.get(KEY_FIRST_NAME));
            lastName = String.valueOf(request.get(KEY_LAST_NAME));
            ssn = String.valueOf(request.get(KEY_SSN));
            emailAddress = String.valueOf(request.get(KEY_EMAIL));
            confirmEmailAddress = String.valueOf(request.get(KEY_CONFIRM_EMAIL));
            phoneNumber = String.valueOf(request.get(KEY_PHONE_NUMBER));

            String cifnumber = PortalConstants.LANDUS_DEALER_CIF;
            List<String> dealerCifList = cifnumber.split(ConstantValues.COMMA_STRING);
            List<Account> dealerAccountList = [SELECT Id,
                                                    name
                                            FROM Account
                                            WHERE CIF_Number__c IN :dealerCifList AND RecordType.name = :PortalConstants.DEALER_PROFILE];
    
            PortalApplicationOriginationHelper.checkEmptyList(dealerAccountList, INVALID_CIF);
            
            List<Contact> existingContactList = checkExistingContact(ssn);
            List<User> existingUserList = checkExistingUser(existingContactList);
            if(!existingUserList.isEmpty()){
                createDealerApplicantRelationship(existingContactList[0], dealerAccountList[0].Id);
                System.enqueueJob(new UpdateUserPermissionSetQueueable(existingUserList[0].Id, new List<String>{PortalConstants.GREY_LABEL_COOP_TYPE}));
                responseData.add( new clcommon.PortalCustomRemoteActionRecord(fieldMap));
                response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
                response.status = clcommon.Constants.SUCCESS; 
                return response;
            }
            
            List<Profile> profileObjList = PortalApplicationOriginationHelper.getProfileByName(PortalConstants.GROWER_PROFILE);
            PortalApplicationOriginationHelper.checkEmptyList(profileObjList, PortalConstants.SOMETHING_WENT_WRONG);

            //if new grower
            if(existingContactList.isEmpty()){
                accountName = setAccountName(firstName, lastName, accountName);
                List<clcommon__Legal_Entity__c> legalEntityTypeList = checkLegalEntity();

                List<RecordType> recordType = checkRecordType();

                List<genesis__Business_Information__c> userbusinessInfoList = createBusinessInfo();

                Map<String,String> accountInfoMap = new Map<String,String>{
                    KEY_ACC_FULL_NAME => accountName,
                    KEY_ACC_LEGAL_ENTITY => legalEntityTypeList[0].id,
                    KEY_ACC_EMAIL => emailAddress,
                    KEY_ACC_CONFIRM_EMAIL => confirmEmailAddress,
                    KEY_ACC_PHONE_NUMBER => phoneNumber,
                    KEY_ACC_RECORD_TYPE => recordType[0].id,
                    KEY_ACC_PARENT_ID => dealerAccountList[0].Id
                };

                List<Account> userAccountList = createAccount(userbusinessInfoList[0].id,accountInfoMap);

                Map<String,String> contactInfoMap = new Map<String,String>{
                    KEY_CONTACT_FIRST_NAME => firstName,
                    KEY_CONTACT_LAST_NAME => lastName,
                    KEY_CONTACT_PHONE_NUMBER => phoneNumber,
                    KEY_CONTACT_EMAIL => emailAddress,
                    KEY_CONTACT_SSN =>ssn
                };

                List<Contact> userContactList = createContact(userAccountList[0].id,contactInfoMap);

                createDealerApplicantRelationship(userContactList[0], dealerAccountList[0].Id);

                //Create New User
                newUserObj = new New_Portal_User__e(First_Name__c = userContactList[0].FirstName ,
                                                    Last_Name__c = userContactList[0].LastName, 
                                                    Email__c = userContactList[0].Email, 
                                                    Contact_Id__c = userContactList[0].Id, 
                                                    Profile_Id__c = profileObjList[0].id,
                                                    Coop_Type__c = PortalConstants.GREY_LABEL_COOP_TYPE,
                                                    Account_Id__c = userContactList[0].AccountId,
                                                    CIF_Number__c = userAccountList[0].CIF_Number__c,
                                                    Federation_Identifier__c = federationIdentifier);
            }
            
            //Creating an user for an already existing account and a corresponding Contact
            else{
                createDealerApplicantRelationship(existingContactList[0], dealerAccountList[0].Id);

                newUserObj = new New_Portal_User__e(First_Name__c = existingContactList[0].FirstName ,
                                                    Last_Name__c = existingContactList[0].LastName, 
                                                    Email__c = existingContactList[0].Email, 
                                                    Contact_Id__c = existingContactList[0].Id, 
                                                    Profile_Id__c = profileObjList[0].id,
                                                    Coop_Type__c = PortalConstants.GREY_LABEL_COOP_TYPE,
                                                    Account_Id__c = existingContactList[0].AccountId,
                                                    CIF_Number__c = existingContactList[0].Account.CIF_Number__c,
                                                    Federation_Identifier__c = federationIdentifier);
            }
            Database.SaveResult result = EventBus.publish(newUserObj);
            if(!result.isSuccess()){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            responseData.add( new clcommon.PortalCustomRemoteActionRecord(fieldMap));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
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
    * @description
    * @author Soumik Pattanayak | 13-02-2025
    * @param borrowerContactObj
    * @param dealerId
    **/
    private static void createDealerApplicantRelationship(Contact borrowerContactObj, Id dealerId){
 
        List<Dealer_Applicant_Relationship__c> dealerApplicantRelList=[SELECT ID
                                                                            FROM Dealer_Applicant_Relationship__c
                                                                            WHERE Dealer__c= :dealerId
                                                                            AND Applicant_Contact__c= :borrowerContactObj.id
                                                                            AND Applicant__c =: borrowerContactObj.AccountId
                                                                            LIMIT 1];
        if(!dealerApplicantRelList.isEmpty()){
            return;
        }
        dealer_Applicant_Relationship__c dealerApplicntRelationObj = new dealer_Applicant_Relationship__c(Applicant__c = borrowerContactObj.AccountId,
                                                                                                           Applicant_Contact__c = borrowerContactObj.Id,
                                                                                                           Dealer__c = dealerId
                                                                                                        );
 
        Database.insert(dealerApplicntRelationObj, true);
    }

    /**
    * @description : sets the account name for the new grower user
    * @author Krishanu Chinya | 04-15-2024 
    * @param firstName 
    * @param lastName 
    * @param accountName 
    * @return String 
    **/
    private static String setAccountName(String firstName, String lastName, String accountName){
        if(!String.isBlank(firstName) && !String.isBlank(lastName)){
            accountName = lastName + PortalConstants.COMMA_STRING + PortalConstants.SPACE_STRING + firstName;
        }
        return accountName;
    }
}