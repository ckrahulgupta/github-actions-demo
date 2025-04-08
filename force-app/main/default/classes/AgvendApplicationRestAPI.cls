/**********************************************************************************************
 * @className         : AgvendApplicationRestAPI
 * @description       : This class is used to fetch data from application by passing their loan number only for Agvend User.
 * @author            : Ayush Kumar Singh
 * @created Date      : 12-06-2023
 * @last modified on  : 12-07-2023
 * @last modified by  : Ayush Kumar Singh
 **********************************************************************************************/
@RestResource(urlMapping='/v1/loan-details/*')
global without sharing class AgvendApplicationRestAPI {
    private static final String SUCCESS = 'Success';
    private static final String AVAILAIBLE_AMOUNT = 'Availaible_Amount';
    private static final String CROP_YEAR = 'Crop_Year';
    private static final String DEALER_NAME = 'Dealer_Name';
    private static final String DEALER_CIF = 'Dealer_CIF';
    private static final String MATURITY_DATE = 'Maturity_Date';
    private static final String RESERVED_AMOUNT = 'Reserved_Amount';
    private static final String LOAN_AMOUNT = 'Loan_Amount';
    private static final String LOAN_NUMBER = 'Loan_Number';
    private static final String ID = 'Id';
    private static final String NAME = 'Name';
    private static final String CLASS_NAME = ScheduleRateChangeNotification.class.getName();

    
    
    /**
      * @description : This is the wrapper class to create custom exception
    */ 
    global class CustomResponseWrapper{
        /**
         * @description Variable to show error and success message
         */
         public String message{get;set;}

         /**
          * @description List to return application Info
          */
         public List<Map<String,String>> data{get;set;}
    }

   /**
    * @description This method is used to return application records by taking id as parameter
    * @param loanNumberList 
    * @return  `CustomResponseWrapper`
    * @exception 
    */
    @HttpPost
    global static CustomResponseWrapper applicationRecord(List<String> loanNumberList) {
        Boolean isValidUser=false;
        List<Id> objApplicationIdList = new List<Id>();
        List<genesis__Applications__c> objApplicationList = new List<genesis__Applications__c>();
        List<Map<String,String>> responseList = new List<Map<String,String>>();
        RestResponse res = RestContext.response;
        try{
            checkRequestParam(loanNumberList);
            objApplicationList = getApplicationList(loanNumberList);
            for(genesis__Applications__c applicationObj : objApplicationList){
                objApplicationIdList.add((Id)applicationObj.Id);
            }
            isValidUser=validateExternalUser(objApplicationIdList,objApplicationList);
            if(!isValidUser){
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }
           
            responseList = getResponseList(objApplicationList);
            CustomResponseWrapper response = new CustomResponseWrapper();
            response.message = SUCCESS;
            response.data = responseList;
            if(!Test.isRunningTest()){
                res.statusCode = 201;
            }
            return response;
            
        }
        catch (CustomException objCustomException) {
            PortalHelper.saveExceptionLog(objCustomException, CLASS_NAME);
            CustomResponseWrapper response = new CustomResponseWrapper();
            response.message = PortalConstants.USER_NOT_AUTHORISED;
            if(!Test.isRunningTest()){
                res.statusCode = 401;
            }
            return response;
            

        }
        catch (Exception objException) {
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
            CustomResponseWrapper response = new CustomResponseWrapper();
            response.message = PortalConstants.SOMETHING_WENT_WRONG;
            if(!Test.isRunningTest()){
                res.statusCode = 400;
            }
            return response;
        }
    }
    
    /**
     * @description This method is used to validate External User
     * @param objApplicationIdList 
     * @param applicationObjList 
     * @return  `Boolean`
     * @exception 
     */
    private  static Boolean validateExternalUser(List<Id> objApplicationIdList,List<genesis__Applications__c> applicationObjList){

        List<User> loggedInUser = new List<User>();
        
        Boolean isValidUser=false;

        loggedInUser = getLoggedInUser();

        if(JSON.serialize(System.Label.AgVend_External_User_Profile_Label).contains(loggedInUser[0].Profile.Name)){
            isValidUser=true;
            for(genesis__Applications__c app : applicationObjList){
                if(!JSON.serialize(ConstantValues.DEALER_CIF_NUMBER).contains(app.Dealer_Name__r.CIF_Number__c)){
                    isValidUser=false;
                }
            }
        }
    
        return isValidUser;                                                               
    }
    /**
     * @description Fetch application with loanNumber
     * @param loanNumberList 
     * @return  `List<genesis__Applications__c>`
     */
    private static List<genesis__Applications__c> getApplicationList(List<String> loanNumberList){
        List<genesis__Applications__c> applicationObjList = new List<genesis__Applications__c>();
        if(Schema.sObjectType.genesis__Applications__c.isAccessible()){
            applicationObjList =[SELECT Id,
                                        Available__c, 
                                        Name, 
                                        Crop_Year__c, 
                                        Dealer_Name__r.CIF_Number__c,
                                        genesis__Maturity_Date__c,
                                        genesis__Loan_Amount__c, 
                                        Reserved_Amount__c,
                                        genesis__Loan_Number__c
                                    FROM genesis__Applications__c 
                                    WHERE genesis__Loan_Number__c IN :loanNumberList];
        }
        return applicationObjList;
    }
  
    /**
     * @description Fetch Current Logged in User
     * @return  `List<User>`
     * @exception 
     */
    private static List<User> getLoggedInUser(){
        List<User> loggedInUser = new List<User>();
        if(Schema.sObjectType.USER.isAccessible()){
            loggedInUser = [SELECT Id,
                                    Profile.Name,
                                    ContactId,
                                    AccountId
                                FROM USER
                                WHERE Id = :UserInfo.getUserId()];
        }
        if(loggedInUser.isEmpty()){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        return loggedInUser;
    }
    /**
     * @description Create a response list of application data
     * @param objApplicationList
     * @return  `List<Map<String,String>>`
     */
    private static List<Map<String,String>> getResponseList(List<genesis__Applications__c> objApplicationList){
        List<Map<String,String>> responseList = new List<Map<String,String>>();
        for(genesis__Applications__c app : objApplicationList){
            Map<String,String> applicationMap = new Map<String,String>{
                AVAILAIBLE_AMOUNT => String.valueOf(app.Available__c),
                CROP_YEAR => app.Crop_Year__c,
                DEALER_NAME => app.Dealer_Name__c,
                DEALER_CIF => app.Dealer_Name__r.CIF_Number__c,
                MATURITY_DATE => String.valueOf(app.genesis__Maturity_Date__c),
                RESERVED_AMOUNT => String.valueOf(app.Reserved_Amount__c),
                LOAN_AMOUNT => String.valueOf(app.genesis__Loan_Amount__c),
                LOAN_NUMBER => app.genesis__Loan_Number__c,
                ID => app.id,
                NAME => app.Name
            };
            responseList.add(applicationMap);
        }
        return responseList;
    }
    /**
     * @description Check request parameter
     * @param loanNumberList 
     * @exception 
     */
    private static void checkRequestParam(List<String> loanNumberList){
        if (loanNumberList == null || loanNumberList.isEmpty()) {
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }
}