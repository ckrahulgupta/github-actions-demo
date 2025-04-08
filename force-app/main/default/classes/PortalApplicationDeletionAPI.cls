/**
 * @description       :  Deletes User Application
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 06-11-2024
 * @last modified by  :  Pritam Roy
**/
global without sharing class PortalApplicationDeletionAPI implements clcommon.PortalCustomRemoteAPI1{ 
    //Constant values specific to this class starts
    private static final string MISSING_ARGUMENTS = PortalConstants.MISSING_ARGUMENTS;
    private static final string APPLICATION_DELETED = 'Application - Deleted ';
    private static final string BORROWER_NAME = ' Borrower:';
    private static final string LOAN_AMOUNT = ' Loan Amount:';
    private static final string CERTIFIED_LENDER = ' Certified Lender:';
    private static final String KEY_APPLICATION_ID = 'applicationId';
    //Constant values specific to this class ends

    /**
    * @description : Validates Arguments
    * @author  Pritam Roy | 05-31-2024 
    * @param request 
    * @param keyToContain 
    * @return String 
    **/
    private static String getKeyValue(Map<String, Object> request,String keyToContain){
        if(!request.containsKey(keyToContain) || request.get(keyToContain) == NULL){
            throw new CustomException(MISSING_ARGUMENTS);
        }
        return String.valueOf(request.get(keyToContain));
    }
     /**
    * @description : Validate User
    * @author  Pritam Roy | 05-16-2024 
    * @param isValidUser 
    * @param objExceptionString 
    **/
    private static void checkValidUser(Boolean isValidUser, String objExceptionString){
        if(isValidUser == false){
            throw new CustomException(objExceptionString);
        }
    }
    /**
    * @description 
    * @author  Pritam Roy | 06-11-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,String[] disclosureNames,Map<String, Object> argumentsFromPortal){
        List<clcommon__party__c> partyList = new List<clcommon__party__c>();
        clcommon.Response objResponse = new clcommon.Response();
        SavePoint dbSavePoint = Database.setSavePoint();
        String applicationId = '';
        String appName = '';
        String borrowerName = '';
        String appLoanAmount = '';
        String certifiedLenderName = '';
        try{
            applicationId = getKeyValue(argumentsFromPortal,KEY_APPLICATION_ID);

            Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationId);
            checkValidUser(isValidUser, PortalConstants.USER_NOT_AUTHORISED);

            List<genesis__Applications__c> userApplicationList = [SELECT Id, 
                                                                            Name, 
                                                                            genesis__Account__c,
                                                                            genesis__Account__r.name,
                                                                            Dealer_Name__c,
                                                                            Dealer_Name__r.name, 
                                                                            genesis__Status__c, 
                                                                            Sales_Agent__c,
                                                                            genesis__Loan_Amount__c,(SELECT id 
                                                                                                            FROM genesis__parties__r 
                                                                                                            WHERE genesis__Application__c =: applicationId), 
                                                                            Certified_Lender__c,
                                                                            Certified_Lender__r.name
                                                                        FROM genesis__Applications__c
                                                                        WHERE Id =: applicationId];
            appName =  userApplicationList[0].Name;
            borrowerName = userApplicationList[0].genesis__Account__r.name;
            appLoanAmount = String.valueOf(userApplicationList[0].genesis__Loan_Amount__c);
            certifiedLenderName = userApplicationList[0].Certified_Lender__r.name;

            partyList = userApplicationList[0].genesis__parties__r;
            Database.delete(partyList, true);
            
            List<genesis__Application_Status_History__c> objStatusHistoryList = [SELECT Id 
                                                                        FROM genesis__Application_Status_History__c 
                                                                        WHERE genesis__Application__c =: applicationid];
            Database.delete(objStatusHistoryList, true);

            List<genesis__Applications__Share> userAppShare = [SELECT Id 
                                                                    FROM genesis__Applications__Share 
                                                                    WHERE parentId =: applicationid];
            Database.delete(userAppShare, true);

            List<clcommon__Document_Category__c> userAppDocList = [SELECT Id
                                                                    FROM clcommon__Document_Category__c
                                                                    WHERE genesis__Application__c =: applicationId];
            
            List<clcommon__Document_Category__Share> userAppShareList = [SELECT Id,ParentId 
                                                                            FROM clcommon__Document_Category__Share
                                                                            WHERE parentId in: userAppDocList];
            Database.delete(userAppShareList, false);
            Database.delete(userAppDocList, true);

            genesis__Applications__c userApp = new genesis__Applications__c(Id = applicationId);
            Database.delete(userApp, true);

            Database.insert(new clcommon__Log__c(Name = APPLICATION_DELETED ,
                    clcommon__Message__c = APPLICATION_DELETED + appName + 
                                                BORROWER_NAME + borrowerName + 
                                                LOAN_AMOUNT + appLoanAmount + 
                                                CERTIFIED_LENDER + certifiedLenderName,
                    clcommon__Time__c = System.Now()), false); 

            objResponse.status = clcommon.Constants.SUCCESS;
        }catch(CustomException objCustomException){
            Database.rollback(dbSavePoint);
            objResponse.status = clcommon.Constants.API_EXCEPTION;
            objResponse.errorMessage = objCustomException.getMessage();
        }
        catch(Exception objexception){
            Database.rollback(dbSavePoint);
            objResponse.status = clcommon.Constants.API_EXCEPTION;
            objResponse.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
        }
        return objResponse;
    }
}