/**
 * @description       : Portal API for Payoff Calculator
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 02-16-2024
 * @last modified by  : Ayan Bhowmik
**/
global without sharing class PortalExportPayoffDetailsAPI implements clcommon.PortalCustomRemoteAPI1{
    //Constants specific to this class starts
    private static final String PAYOFF_CALCULATOR_API = 'PortalExportPayoffDetailsAPI';
    private static final String LOAN_NUMBER = 'loanNumber';
    private static final String ESTIMATED_DATE = 'estimatedDate';
    private static final String CURRENT_BALANCE = 'currentBalance';
    private static final String CURRENT_INTEREST = 'currentInterest';
    private static final String CURRENT_CHARGES = 'currentCharges';
    private static final String CURRENT_TOL_BALANCE = 'currentTotalBalance';
    private static final String ACCRUAL_DAILY_FACTOR = 'accrualDailyFactor';
    private static final String ESTIMATED_BALANCE = 'estimatedBalance';
    private static final String ESTIMATED_INTEREST = 'estimatedInterest';
    private static final String ACCRUED_DAYS = 'accruedDays';
    private static final String ESTIMATED_CHARGES = 'estimatedCharges';
    private static final String ESTIMATED_TOL_BALANCE = 'estimatedTotalBalance';
    private static final String MATURITY_DATE = 'maturityDate';
    private static final String COOP_TYPE = 'coopType';
    private static final String KEY_PDF = 'pdf';
    private static final String CROP_YEAR = 'cropYear';
    private static final String IS_SUB_TRANCHE = 'isSubTranche';
    private static final String GROWER_NAME = 'growerName';
    private static final String APPLICATION_ID = 'applicationId';
    //Constants specific to this class ends

    Map<String, Object> responseFieldMap = new Map<String, Object>();
    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();

    /**
    * @description Check if argument is null
    * @author  Pritam Roy | 12-11-2023 
    * @param objVariable 
    **/
    private static void checkVariable(Object objVariable){
        if(objVariable == null){
            throw new CustomException(PortalConstants.NULL_EXCEPTION);
        }
    }
    /**
    * @description Check if map contains arguments
    * @author  Pritam Roy | 12-11-2023 
    * @param argumentsFromPortal 
    * @param objArgument 
    **/
    private static void checkPortalArguments(Map<String,Object> argumentsFromPortal,String objArgument){
        if(argumentsFromPortal.containsKey(objArgument)){
            checkVariable(argumentsFromPortal.get(objArgument));
        }
    }

    /**
    * @description checks checkPortalArguments for each argument
    * @author  Pritam Roy | 12-11-2023 
    * @param argumentsFromPortal 
    **/
    private static void checkArguments(Map<String,Object> argumentsFromPortal){
        checkPortalArguments(argumentsFromPortal,LOAN_NUMBER);
        checkPortalArguments(argumentsFromPortal,ESTIMATED_DATE);
        checkPortalArguments(argumentsFromPortal,CURRENT_BALANCE);
        checkPortalArguments(argumentsFromPortal,CURRENT_INTEREST);
        checkPortalArguments(argumentsFromPortal,CURRENT_CHARGES);
        checkPortalArguments(argumentsFromPortal,CURRENT_TOL_BALANCE);
        checkPortalArguments(argumentsFromPortal,ACCRUAL_DAILY_FACTOR);
        checkPortalArguments(argumentsFromPortal,ESTIMATED_BALANCE);
        checkPortalArguments(argumentsFromPortal,ESTIMATED_INTEREST);
        checkPortalArguments(argumentsFromPortal,ACCRUED_DAYS);
        checkPortalArguments(argumentsFromPortal,ESTIMATED_CHARGES);
        checkPortalArguments(argumentsFromPortal,ESTIMATED_TOL_BALANCE);
        checkPortalArguments(argumentsFromPortal,APPLICATION_ID);
        checkPortalArguments(argumentsFromPortal,IS_SUB_TRANCHE);
    }
    /**
    * @description sets parameters to VF page
    * @author  Pritam Roy | 12-11-2023 
    * @param argumentsFromPortal 
    **/
    public void exportPayoffDetails(Map<String, Object> argumentsFromPortal){
        pageReference pdfPage = Page.PayoffCalculator;
        List<genesis__Applications__c> applicationDetailsList = getApplicationDetails(String.valueOf(argumentsFromPortal.get(APPLICATION_ID)));
        pdfPage.getParameters().put(LOAN_NUMBER,String.valueOf(argumentsFromPortal.get(LOAN_NUMBER)));
        pdfPage.getParameters().put(ESTIMATED_DATE,String.valueOf(argumentsFromPortal.get(ESTIMATED_DATE)));
        pdfPage.getParameters().put(CURRENT_BALANCE,String.valueOf(argumentsFromPortal.get(CURRENT_BALANCE)));
        pdfPage.getParameters().put(CURRENT_INTEREST,String.valueOf(argumentsFromPortal.get(CURRENT_INTEREST)));
        pdfPage.getParameters().put(CURRENT_CHARGES,String.valueOf(argumentsFromPortal.get(CURRENT_CHARGES)));
        pdfPage.getParameters().put(CURRENT_TOL_BALANCE,String.valueOf(argumentsFromPortal.get(CURRENT_TOL_BALANCE)));
        pdfPage.getParameters().put(ACCRUAL_DAILY_FACTOR,String.valueOf(argumentsFromPortal.get(ACCRUAL_DAILY_FACTOR)));
        pdfPage.getParameters().put(ESTIMATED_BALANCE,String.valueOf(argumentsFromPortal.get(ESTIMATED_BALANCE)));
        pdfPage.getParameters().put(ESTIMATED_INTEREST,String.valueOf(argumentsFromPortal.get(ESTIMATED_INTEREST)));
        pdfPage.getParameters().put(ACCRUED_DAYS,String.valueOf(argumentsFromPortal.get(ACCRUED_DAYS)));
        pdfPage.getParameters().put(ESTIMATED_CHARGES,String.valueOf(argumentsFromPortal.get(ESTIMATED_CHARGES)));
        pdfPage.getParameters().put(ESTIMATED_TOL_BALANCE,String.valueOf(argumentsFromPortal.get(ESTIMATED_TOL_BALANCE)));
        pdfPage.getParameters().put(IS_SUB_TRANCHE,String.valueOf(argumentsFromPortal.get(IS_SUB_TRANCHE)));
        pdfPage.getParameters().put(GROWER_NAME, String.valueOf(applicationDetailsList[PortalConstants.ZERO_VALUE].genesis__Account__r.Name));
        pdfPage.getParameters().put(CROP_YEAR, String.valueOf(applicationDetailsList[PortalConstants.ZERO_VALUE].Crop_Year__c));
        pdfPage.getParameters().put(COOP_TYPE, String.valueOf(applicationDetailsList[PortalConstants.ZERO_VALUE].Coop_Type__c));
        pdfPage.getParameters().put(MATURITY_DATE, String.valueOf(applicationDetailsList[PortalConstants.ZERO_VALUE].genesis__Maturity_Date__c));

        if(!Test.isRunningTest()){
            responseFieldMap.put(KEY_PDF, EncodingUtil.base64Encode(pdfPage.getContentAsPDF()));
        }

    }


    /**
    * @description 
    * @author Ayan Bhowmik | 02-15-2024 
    * @param applicationId 
    * @return List<genesis__Applications__c> 
    **/
    private List<genesis__Applications__c> getApplicationDetails(String applicationId){
        List<genesis__Applications__c> getApplicationDetails = [SELECT Id,
                                                                    genesis__Account__r.Name,
                                                                    Crop_Year__c,
                                                                    genesis__Maturity_Date__c,
                                                                    Coop_Type__c
                                                                FROM genesis__Applications__c
                                                                WHERE Id =: applicationId
                                                                LIMIT 1];
        CFAOriginationHelperClass.checkEmptyList(getApplicationDetails, PortalConstants.APPLICATION_ERROR);
        return getApplicationDetails;
    }
    /**
    * @description checks arguments and sends arguments to VF page
    * @author  Pritam Roy | 12-11-2023 
    * @param componentStructureName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStructureName,String[] disclosureNames,Map<String, Object> argumentsFromPortal){
        try{
            Boolean isValidUser = false;
            checkArguments(argumentsFromPortal);
            if(!argumentsFromPortal.containsKey(LOAN_NUMBER)){
                throw new CustomException(PortalConstants.LOAN_NUMBER_EXCEPTION);
            }
            isValidUser = PortalSecurityUtil.validateUserApplication(String.valueOf(argumentsFromPortal.get(APPLICATION_ID)));
            if(!isValidUser){
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }
            exportPayoffDetails(argumentsFromPortal);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(responseFieldMap));
            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.status = clcommon.Constants.SUCCESS;  
        } catch (CustomException objCustomException) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, PAYOFF_CALCULATOR_API);
        } catch (Exception objException) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, PAYOFF_CALCULATOR_API);
        }
        return response;

    }
}