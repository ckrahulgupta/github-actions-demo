/**
 * @description       : Purpose of this class is to create and save application and party details
 * @author            : iAyush
 * @last modified on  : 03-10-2025
 * @last modified by  : Ayush Kumar Singh
**/
global without sharing class PortalApplicationCreationAPI implements clcommon.PortalCustomRemoteAPI1 {
    
    private final String CLASS_NAME = PortalApplicationCreationAPI.class.getName();
    
    String primaryAccountRecord = PortalConstants.EMPTY_STRING;
    String primaryContactRecord = PortalConstants.EMPTY_STRING;
    String primaryBusinessInfoRecord = PortalConstants.EMPTY_STRING;
    String coApplicantRecords = PortalConstants.EMPTY_STRING;
    String entity = PortalConstants.EMPTY_STRING;
    String applicationId = PortalConstants.EMPTY_STRING;
    String shouldValidate = PortalConstants.EMPTY_STRING;

    List<User> loggedInUser = new List<User>();

    Boolean flag = false;

    List<clcommon.PortalCustomRemoteActionRecord> respData = new List<clcommon.PortalCustomRemoteActionRecord>();
    Map<String, Object> fields = new Map<String, Object>();
    clcommon.Response response = new clcommon.Response();
    Map<String, SObject> relatedObjects = new Map<String, SObject>();
    Contact contactObj = new Contact();

    /**
     * @description : default constructor
     */
    global PortalApplicationCreationAPI() {
        this.loggedInUser = PortalApplicationOriginationHelper.getLoggedInUser(); 

    }
  
    /**
     *@description : Purpose of this method is to create application and send the appId in return
     * @author iAyush | 20-1-2022
     * @param componentStrName 
     * @param disclosureNames 
     * @param argumentsFromPortal 
     * @return  `clcommon.Response`
     * @exception 
     */
    global clcommon.Response invokeAction(String componentStrName,
                                          String[] disclosureNames,
                                          Map<String, Object> argumentsFromPortal) {
  
        SavePoint dbSavePoint = Database.setSavepoint();
        String applicationRecord = PortalConstants.EMPTY_STRING;
        genesis__Applications__c applicationObj = new genesis__Applications__c();
        Account accountObj = new Account();
        genesis__Business_Information__c businessInfoObj = new genesis__Business_Information__c();
        List<Map<String, Object>> coApplicants = new List<Map<String, Object>>();
        List<Object> coApplicantList = new List<Object>();
        List<clcommon__Party__c> borrowerPartyList=new List<clcommon__Party__c>();


        try {
            applicationRecord = String.valueOf(argumentsFromPortal.get(PortalConstants.APPLICATION_KEY));
            primaryAccountRecord = String.valueOf(argumentsFromPortal.get(PortalConstants.PRIMARY_APPLICANT_ACCOUNT_KEY));
            primaryContactRecord = String.valueOf(argumentsFromPortal.get(PortalConstants.PRIMARY_APPLICANT_CONTACT_KEY));
            primaryBusinessInfoRecord = String.valueOf(argumentsFromPortal.get(PortalConstants.PRIMARY_APPLICANT_BUSINESS_INFO_KEY));
            coApplicantRecords = String.valueOf(argumentsFromPortal.get(PortalConstants.COAPPLICANT_KEY));
            shouldValidate = String.valueOf(argumentsFromPortal.get(PortalConstants.SAVE_TYPE_KEY));
            // Checking if all the Required Params are present or not

            PortalApplicationOriginationHelper.checkBlankParameter(applicationRecord, PortalConstants.SOMETHING_WENT_WRONG);
            PortalApplicationOriginationHelper.checkBlankParameter(primaryAccountRecord, PortalConstants.SOMETHING_WENT_WRONG);
            
            applicationObj = (genesis__Applications__c) Json.deserialize(applicationRecord, genesis__Applications__c.class);
            accountObj = (Account) Json.deserialize(primaryAccountRecord, Account.class);

            getContactRecord(primaryContactRecord);

            businessInfoObj=geBusinessInfoRecord(primaryBusinessInfoRecord);
            
            coApplicantList=getCoApplicantList(coApplicantRecords);

            applicationObj=PortalApplicationCreationHandler.setNullIfEmpty(applicationObj);

            applicationObj.Sales_Agent__c = applicationObj.Sales_Agent__c == null ? null : applicationObj.Sales_Agent__c;

            coApplicants=PortalApplicationCreationHandler.getCoApplicantsList(coApplicantList);
            
            entity = PortalApplicationOriginationHelper.getLegalEntityByAccount(accountObj);
            
            // updating contact phone fields if null value is sent
            PortalApplicationOriginationHelper.nullifyContactNumbers(accountObj, contactObj);

            borrowerPartyList=updateBorrowerDetails(new Map<String,Object>{PortalConstants.APPLICATION_OBJ_KEY=>applicationObj,
                                                              PortalConstants.CONTACT_OBJ_KEY=>contactObj,
                                                              PortalConstants.ACCOUNT_OBJ_KEY=>accountObj,
                                                              PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoObj});
            
  
            PortalValidationUtil.isValidApplicationCreation(new Map<String,Object>{PortalConstants.APPLICATION_OBJ_KEY=> applicationObj,
                                                                                    PortalConstants.CONTACT_OBJ_KEY=>contactObj, 
                                                                                    PortalConstants.ACCOUNT_OBJ_KEY=>accountObj, 
                                                                                    PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoObj, 
                                                                                    PortalConstants.KEY_SHOULD_VALIDATE=>shouldValidate,
                                                                                    PortalConstants.BORROWER_PARTY_KEY=>borrowerPartyList[0]});

            applicationObj=changeApplicationStage(applicationObj,shouldValidate);

            String coopType = PortalApplicationOriginationHelper.getCoopType(applicationObj.Id);

            PortalApplicationOriginationHelper.checkBlankParameter(coopType, PortalConstants.SOMETHING_WENT_WRONG);

            accountObj = PortalApplicationOriginationHelper.setNullIfEmpty(accountObj, coopType);
            contactObj = PortalApplicationOriginationHelper.setNullIfEmpty(contactObj, coopType);
            businessInfoObj = PortalApplicationOriginationHelper.setNullIfEmpty(businessInfoObj, coopType);
  
            //If it is an existing Application, then we are only doing an Update to the same Application
            if(!String.isBlank(applicationObj.Id) && String.valueOf(applicationObj.Id)!=PortalConstants.NEW_RECORD_STRING){
                applicationId = applicationObj.Id;

                Boolean conditionToCheck=(coApplicantList.isEmpty() && entity != PortalConstants.INDIVIDUAL && entity != PortalConstants.SOLE_PROP_ENTITY);
                PortalApplicationOriginationHelper.throwErrorIfTrue(conditionToCheck, PortalConstants.CO_APPLICANT_MISSING);

                Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationObj.Id);
                PortalApplicationOriginationHelper.throwErrorIfFalse(isValidUser, PortalConstants.USER_NOT_AUTHORISED);
                
                
                Database.update(applicationObj, true);

                PortalApplicationCreationHandler.updateAccountDetails(new Map<String,Object>{PortalConstants.ACCOUNT_OBJ_KEY=>accountObj,
                                                                                             PortalConstants.CONTACT_OBJ_KEY=>contactObj,
                                                                                             PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoObj,
                                                                                             PortalConstants.APPLICATION_OBJ_KEY=>applicationObj,
                                                                                             PortalConstants.ENTITY_KEY=>entity,
                                                                                             PortalConstants.KEY_COOP_TYPE=>coopType},
                                                                        borrowerPartyList, coApplicants);
                
                PortalApplicationCreationHandler.updateContactAndBusinessInfoDetails(new Map<String,Object>{PortalConstants.ACCOUNT_OBJ_KEY=>accountObj,
                                                                                                            PortalConstants.CONTACT_OBJ_KEY=>contactObj,
                                                                                                            PortalConstants.APPLICATION_OBJ_KEY=>applicationObj,
                                                                                                            PortalConstants.BUSINESS_INFO_OBJ_KEY=>businessInfoObj},
                                                                                        borrowerPartyList);
                
                
                //Call a method to add document category
                linkDriverLicence(applicationId);
            }
            
            //Comparing and saving all the coapplicants for this application
            if (!String.isBlank(coApplicantRecords)){
                PortalApplicationCreationHandler.saveCoApplicant(coApplicants, applicationId , shouldValidate);
            }
            PortalApplicationCreationHandler.updatePrincipalParties(applicationObj.Id, coopType,loggedInUser[0]);

            PortalApplicationOriginationHelper.throwErrorIfTrue(flag, PORTALCONSTANTS.CO_APPLICANT_EXCEPTION);
            PortalApplicationCreationHandler.createTasks(String.valueOf(applicationId));

            //------------------
            PortalApplicationCreationHandler.verifyApplicants(applicationObj,shouldValidate);
            //------------------
            fields.put(PortalConstants.BORROWER_ENTITY_TYPE, entity);
            respData.add(new clcommon.PortalCustomRemoteActionRecord(fields));
            clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(respData);
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
    * @description gets the contact record from the response from portal
    * @author Rakesh Saraf | 01-12-2025 
    * @param primaryContactRecord 
    **/
    private void getContactRecord(String primaryContactRecord){
        if(!String.isBlank(primaryContactRecord)){
            contactObj= ( (Contact) Json.deserialize(primaryContactRecord, Contact.class));
        }
    }

    /**
    * @description gets the contact record from the response from portal
    * @author Rakesh Saraf | 01-12-2025 
    * @param primaryBusinessInfoRecord 
    * @return genesis__Business_Information__c
    **/
    private genesis__Business_Information__c geBusinessInfoRecord(String primaryBusinessInfoRecord){
        if(!String.isBlank(primaryBusinessInfoRecord)){
            return( (genesis__Business_Information__c) Json.deserialize(primaryBusinessInfoRecord, genesis__Business_Information__c.class));
        }
        return null;
    }

    /**
    * @description gets the contact record from the response from portal
    * @author Rakesh Saraf | 01-12-2025 
    * @param coApplicantRecords 
    * @return List<Object>
    **/
    private List<Object> getCoApplicantList(String coApplicantRecords){
        List<Object> coApplicantList= new List<Object>();
        if (!String.isBlank(coApplicantRecords) ) {
            coApplicantList = (List<Object>) Json.deserializeUntyped (coApplicantRecords);
        }
        return coApplicantList;
    }
    
    /**
     * @description : Purpose of this method is to fetch the Driver's Licence and upload it under an application document category
     * @param applicationId 
     */
    private void linkDriverLicence(String applicationId){
        String drivingLicenceDocCategory = PortalConstants.DRIVING_LICENSE_TASK;
        //Get the application
        PortalApplicationOriginationHelper.uploadDocumentOnDocCategory(applicationId,drivingLicenceDocCategory);
        
    }

    /**
    * @description this method is used to change the stage of the application to applicant signature if the stage is applicant info.
    * @author Rakesh Saraf | 01-12-2025 
    * @param applicationObj 
    * @param shouldValidate 
    * @return genesis__Applications__c 
    **/
    private genesis__Applications__c changeApplicationStage(genesis__Applications__c applicationObj,String shouldValidate){
        if(shouldValidate==PortalConstants.SAVE_AND_EXIT){
            applicationObj.Stage__c = PortalConstants.APPLICANT_INFORMATION;
            return applicationObj;
        }
        if(shouldValidate==PortalConstants.SAVE_AND_CONTINUE){
            applicationObj.Stage__c = PortalConstants.APPLICANT_SIGNATURE;
        }
        return applicationObj;
    }

    /**
    * @description the purpose of this function is to update the party of the borrower for validations
    * @author Rakesh Saraf | 12-12-2024 
    * @param paramMap 
    * @return List<clcommon__Party__c> 
    **/
    public static List<clcommon__Party__c> updateBorrowerDetails(Map<string,Object> paramMap){
        genesis__Applications__c applicationObj=(genesis__Applications__c) paramMap.get(PortalConstants.APPLICATION_OBJ_KEY);
        Account accountObj=(Account) paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);

        List<clcommon__Party__c> borrowerPartyList=[SELECT Id,
                                                            Home_Number__c,
                                                            Work_Number__c,
                                                            Mobile_Number__c,
                                                            Street__c,
                                                            State__c,
                                                            County__c,
                                                            City__c,
                                                            Postal_Code__c,
                                                            Gross_Farm_Income__c,
                                                            Total_Assets__c,
                                                            Total_Liabilities__c,
                                                            Marital_Status__c
                                                        FROM clcommon__Party__c
                                                        WHERE genesis__Application__c= :applicationObj.id
                                                        AND clcommon__Account__c=:accountObj.id
                                                        AND clcommon__Type__r.Name = :PortalConstants.BORROWER_PARTY_NAME];

        PortalApplicationOriginationHelper.checkEmptyList(borrowerPartyList, PortalConstants.SOMETHING_WENT_WRONG);

        paramMap.put(PortalConstants.BORROWER_PARTY_KEY,borrowerPartyList[0]);
        PortalApplicationCreationHandler.updateBorrowerPartyDetails(paramMap);
        return borrowerPartyList;
    }
}