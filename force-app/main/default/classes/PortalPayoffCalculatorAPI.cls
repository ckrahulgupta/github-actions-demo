/**
 * @description       : Portal API for Payoff Calculator
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 01-12-2025
 * @last modified by  : Ayan Khanra
**/

global without sharing class PortalPayoffCalculatorAPI implements clcommon.PortalCustomRemoteAPI1{
    //Constants for the specific class starts
    private static final String LOAN_NUMBER = 'loanNumber';
    private static final String PAYOFF_DATE = 'payoffDate';
    private static final String CLASS_NAME = 'PortalPayoffCalculatorAPI';
    private static final String PRINCIPAL_BALANCE = 'PrincipalBalance';
    private static final String ACCRUED_INTEREST = 'AccruedInterest';
    private static final String FEES_DUE = 'FeesDue';
    private static final String SERVICING_FEE = 'ServicingFee';
    private static final String LATE_CHARGES = 'LateCharges';
    private static final String PER_DIEM = 'PerDiem';
    private static final String CURRENT_DATE = 'currentDate';
    private static final String EXPECTED_DATE = 'expectedDate';
    //Constants for the specific class ends

    private static Decimal principalBalance = 0.0;
    private static Decimal accruedInterest = 0.0;
    private static Decimal feesDue = 0.0;
    private static Decimal servicingFee = 0.0;
    private static Decimal lateCharges = 0.0;
    private static Decimal perDiem = 0.0;
   

    /**
    * @description check null variable
    * @author  Pritam Roy | 12-11-2023 
    * @param objVariable 
    **/
    private static void checkVariable(Object objVariable){
        if(objVariable == null){
            throw new CustomException(PortalConstants.INVALID_ARGUMENTS);
        }
    }

    /**
    * @description checks arguments
    * @author  Pritam Roy | 12-11-2023 
    * @param argumentsFromPortal 
    **/
    private static void checkArguments(Map<String, Object> argumentsFromPortal){
        if(!argumentsFromPortal.containsKey(LOAN_NUMBER)||!argumentsFromPortal.containsKey(PAYOFF_DATE)){
            throw new CustomException(PortalConstants.NULL_EXCEPTION);
        }
    }

    /**
    * @description sum of responses
    * @author  Pritam Roy | 12-11-2023 
    * @param responseMap 
    **/
    private static void sumResponseData(Map<String,Object> responseMap){

        principalBalance += Decimal.valueOf(String.valueOf(responseMap.get(PRINCIPAL_BALANCE)));
        accruedInterest += Decimal.valueOf(String.valueOf(responseMap.get(ACCRUED_INTEREST)));
        feesDue += Decimal.valueOf(String.valueOf(responseMap.get(FEES_DUE)));
        servicingFee += Decimal.valueOf(String.valueOf(responseMap.get(SERVICING_FEE)));
        lateCharges += Decimal.valueOf(String.valueOf(responseMap.get(LATE_CHARGES)));
        perDiem += Decimal.valueOf(String.valueOf(responseMap.get(PER_DIEM)));
    }
    
    /**
    * @description calls NLSLoanPayoffCalculatorAdapter for Payoff Details
    * @author  Pritam Roy | 12-11-2023 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                            String[] disclosureNames,
                                            Map<String, Object> argumentsFromPortal){  
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        List<genesis__Application_Pricing_Detail__c> pricingDetailList = new List<genesis__Application_Pricing_Detail__c>(); 
        clcommon.Response response = new clcommon.Response();
        Map<String,Object> responseMap = new Map<String,String>();
        Map<String,Object> principalMap = new Map<String,Object>();
        Map<String,Object> interestMap = new Map<String,Object>();
        Map<String,Object> otherChargesMap = new Map<String,Object>();  
        List<String> loanIdList = new List<String>();
        List<String> splitStringList = new List<String>();
        String currentBalance;
        String currentInterest;
        String currentCharges;
        String accruedDays;
        String accrualDailyFactor;
        String estimatedBalance;
        String estimatedInterest;
        String estimatedCharges;
        String currentTotalBalance;
        String estimatedTotalBalance;
        String setLoanNumber;          
        try{
            checkArguments(argumentsFromPortal);
            checkVariable(argumentsFromPortal.get(LOAN_NUMBER));
            checkVariable(argumentsFromPortal.get(PAYOFF_DATE));
            splitStringList = String.valueOf(argumentsFromPortal.get(LOAN_NUMBER)).split(' ');
            setLoanNumber = splitStringList[0] + ConstantValues.PERCENTAGE_STRING;
            pricingDetailList = [SELECT Id,
                                    Loan_Id__c,
                                    Loan_Number__c,
                                    genesis__Enabled_Flag__c,
                                    genesis__Application__r.genesis__Status__c 
                                FROM genesis__Application_Pricing_Detail__c 
                                WHERE Loan_Number__c like :setLoanNumber
                                AND Loan_Id__c != NULL
                                AND genesis__Application__r.genesis__Status__c =: ConstantValues.ACTIVE
                                AND genesis__Enabled_Flag__c = TRUE];
            if(pricingDetailList.isEmpty()){
                throw new CustomException(PortalConstants.EMPTY_PRICING_LIST);
            }
            for(genesis__Application_Pricing_Detail__c objPricingDetail : pricingDetailList){
                loanIdList.add(objPricingDetail.Loan_ID__c);
            }
            responseMap = NLSLoanPayoffCalculatorCallout.getPayoffDetails(loanIdList,String.valueOf(argumentsFromPortal.get(PAYOFF_DATE)).remove(ConstantValues.HYPHEN_STRING).trim());

            //Calculate Response for Current Date
            Map<String,Object> currentDateMap = (Map<String,Object>)responseMap.get(CURRENT_DATE);
            for(String key : currentDateMap.keySet()){
                    Map<String,Object> objMap = (Map<String,Object>)currentDateMap.get(key);
                    sumResponseData(objMap);
            }

            currentBalance = String.valueOf(principalBalance);
            currentInterest = String.valueOf(accruedInterest);
            currentCharges = String.valueOf(feesDue + servicingFee + lateCharges);
            currentTotalBalance = String.valueOf(principalBalance + accruedInterest + feesDue + servicingFee + lateCharges);
            accruedDays = String.valueOf(Integer.valueOf(System.today().daysBetween(Date.valueOf(String.valueOf(argumentsFromPortal.get(PAYOFF_DATE)).trim()))));
            accrualDailyFactor = String.valueOf(perDiem.setScale(3));

            principalBalance  = 0.0;
            accruedInterest = 0.0;
            feesDue = 0.0;
            servicingFee = 0.0;
            lateCharges = 0.0;
            perDiem = 0.0;

            //Calculate Response for Expected Date
            Map<String,Object> payoffDateMap = (Map<String,Object>)responseMap.get(EXPECTED_DATE);
            for(String key : currentDateMap.keySet()){
                Map<String,Object> objMap = (Map<String,Object>)payoffDateMap.get(key);
                sumResponseData(objMap);
            }
            estimatedBalance = String.valueOf(principalBalance);
            estimatedInterest = String.valueOf(accruedInterest);
            estimatedCharges = String.valueOf(feesDue + servicingFee + lateCharges);
            estimatedTotalBalance = String.valueOf(principalBalance + accruedInterest + feesDue + servicingFee + lateCharges);

            //creating response
            principalMap.put('label','Principal');
            principalMap.put('currentBalance',currentBalance);
            principalMap.put('estimatedBalance',estimatedBalance);
            principalMap.put('currentTotalBalance',currentTotalBalance);
            principalMap.put('estimatedTotalBalance',estimatedTotalBalance);
            principalMap.put('currentInterest',currentInterest);
            principalMap.put('estimatedInterest',estimatedInterest);
            principalMap.put('diffInDays',accruedDays);
            principalMap.put('dailyFactor',accrualDailyFactor);
            principalMap.put('currentCharges',currentCharges);
            principalMap.put('estimatedCharges',estimatedCharges);
    
            interestMap.put('label','Interest');
            interestMap.put('currentBalance',currentInterest);
            interestMap.put('estimatedBalance',estimatedInterest);
            interestMap.put('accruedDays',accruedDays);
            interestMap.put('accrualDailyFactor',accrualDailyFactor);
    
            otherChargesMap.put('label','Other Charges');
            otherChargesMap.put('currentBalance',currentCharges);
            otherChargesMap.put('estimatedBalance',estimatedCharges);

            responseData.add(new clcommon.PortalCustomRemoteActionRecord((Map<String,Object>)principalMap));
            responseData.add(new clcommon.PortalCustomRemoteActionRecord((Map<String,Object>)interestMap));
            responseData.add(new clcommon.PortalCustomRemoteActionRecord((Map<String,Object>)otherChargesMap));

            response = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.content = null;
            response.status = clcommon.Constants.SUCCESS; 
        } catch (Exception objException) {
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, CLASS_NAME);
        }
        return response;
    }
}