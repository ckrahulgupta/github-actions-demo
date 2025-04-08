/**
 * @description       :  Controller class for PayoffCalculatorVF page
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 02-26-2024
 * @last modified by  : Tuhin Bhunia
**/
public without sharing class PayoffCalculatorController {
    //Constants specific to this class starts
    private static final String PAYOFF_CALCULATOR_CLASS = 'PayoffCalculatorController';
    //Constants specific to this class ends

    Date formatTodaysDate = Date.today();
    Date formatMaturityDate;
    Date formatPayoffDate;
    Decimal escapedCurrBalance;
    Decimal escapedCurrInterest;
    Decimal escapedCurrCharges;
    Decimal escapedAccDailyFactor;
    Decimal escapedEstBalance;
    Decimal escapedEstInterest;
    Decimal escapedEstCharges;
    Decimal escapedCurrTolBalance;
    Decimal escapedEstTolBalance;

    /**
    * @description : variable to store currentBalance value for PayOffCalculator VF Page
    * @author  Tuhin Bhunia | 02-26-2024
    **/
    public String currentBalance{get;set;}

    /**
    * @description : variable to store currentInterest value for PayOffCalculator VF Page
    * @author  Tuhin Bhunia | 02-26-2024
    **/
    public String currentInterest{get;set;}

    /**
    * @description : variable to store currentCharges value for PayOffCalculator VF Page
    * @author  Tuhin Bhunia | 02-26-2024
    **/
    public String currentCharges{get;set;}

    /**
    * @description : variable to store accruedDays value for PayOffCalculator VF Page
    * @author  Tuhin Bhunia | 02-26-2024
    **/
    public String accruedDays{get;set;}

    /**
    * @description : variable to store accrualDailyFactor value for PayOffCalculator VF Page
    * @author  Tuhin Bhunia | 02-26-2024
    **/
    public String accrualDailyFactor{get;set;}

    /**
    * @description : variable to store estimatedBalance value for PayOffCalculator VF Page
    * @author  Tuhin Bhunia | 02-26-2024
    **/
    public String estimatedBalance{get;set;}

    /**
    * @description : variable to store estimatedInterest value for PayOffCalculator VF Page
    * @author  Tuhin Bhunia | 02-26-2024
    **/
    public String estimatedInterest{get;set;}

    /**
    * @description : variable to store estimatedCharges value for PayOffCalculator VF Page
    * @author  Tuhin Bhunia | 02-26-2024
    **/
    public String estimatedCharges{get;set;}

    /**
    * @description : variable to store currentTotalBalance value for PayOffCalculator VF Page
    * @author  Tuhin Bhunia | 02-26-2024
    **/
    public String currentTotalBalance{get;set;}

    /**
    * @description : variable to store estimatedTotalBalance value for PayOffCalculator VF Page
    * @author  Tuhin Bhunia | 02-26-2024
    **/
    public String estimatedTotalBalance{get;set;}

    /**
    * @description : variable to store loanNumber value for PayOffCalculator VF Page
    * @author  Tuhin Bhunia | 02-26-2024
    **/
    public String loanNumber{get;set;}

    /**
    * @description : variable to store todaysDate value for PayOffCalculator VF Page
    * @author  Tuhin Bhunia | 02-26-2024
    **/
    public String todaysDate{get;set;}

    /**
    * @description : variable to store estimatedDate value for PayOffCalculator VF Page
    * @author  Tuhin Bhunia | 02-26-2024
    **/
    public String estimatedDate{get;set;}

    /**
    * @description : variable to store maturityDate value for PayOffCalculator VF Page
    * @author  Tuhin Bhunia | 02-26-2024
    **/
    public String maturityDate{get;set;}

    /**
    * @description : variable to store coopType value for PayOffCalculator VF Page
    * @author  Tuhin Bhunia | 02-26-2024
    **/
    public String coopType{get;set;}

    /**
    * @description : variable to store isSubTranche value for PayOffCalculator VF Page
    * @author  Tuhin Bhunia | 02-26-2024
    **/
    public Boolean isSubTranche{get;set;}

    /**
    * @description : variable to store cropYear value for PayOffCalculator VF Page
    * @author  Tuhin Bhunia | 02-26-2024
    **/
    public String cropYear{get;set;}

    /**
    * @description : variable to store growerName value for PayOffCalculator VF Page
    * @author  Tuhin Bhunia | 02-26-2024
    **/
    public String growerName{get;set;}

    /**
    * @description Formats string to two decimal places
    * @author  Pritam Roy | 12-11-2023 
    * @param objAmount 
    * @return String 
    **/
    private String formatAmount(String objAmount) {
        objAmount = ConstantValues.DOLLAR_STRING + objAmount;
        if (!objAmount.contains(ConstantValues.PERIOD_STRING)) {
            objAmount += ConstantValues.FORMAT_TO_DECIMAL_STRING;
        } else {
          Integer decimalPosition = objAmount.indexOf(ConstantValues.PERIOD_STRING);
          if (objAmount.length() - decimalPosition < 3){ 
              objAmount += ConstantValues.FORMAT_STRING;
            }   
        }
        return objAmount; 
    }
    /** 
    * @description stores data from arguments
    * @author  Pritam Roy | 12-11-2023 
    **/
    private void escapeCharacters(){
        escapedCurrBalance = Decimal.valueOf(Apexpages.currentPage().GetParameters().Get('currentBalance').escapeHtml4());
        escapedCurrInterest = Decimal.valueOf(Apexpages.currentPage().GetParameters().Get('currentInterest').escapeHtml4());
        escapedCurrCharges = Decimal.valueOf(Apexpages.currentPage().GetParameters().Get('currentCharges').escapeHtml4());
        escapedAccDailyFactor = Decimal.valueOf(Apexpages.currentPage().GetParameters().Get('accrualDailyFactor').escapeHtml4());
        escapedEstBalance = Decimal.valueOf(Apexpages.currentPage().GetParameters().Get('estimatedBalance').escapeHtml4());
        escapedEstInterest = Decimal.valueOf(Apexpages.currentPage().GetParameters().Get('estimatedInterest').escapeHtml4());
        escapedEstCharges = Decimal.valueOf(Apexpages.currentPage().GetParameters().Get('estimatedCharges').escapeHtml4());
        escapedCurrTolBalance = Decimal.valueOf(Apexpages.currentPage().GetParameters().Get('currentTotalBalance').escapeHtml4());
        escapedEstTolBalance = Decimal.valueOf(Apexpages.currentPage().GetParameters().Get('estimatedTotalBalance').escapeHtml4());
        formatMaturityDate = Date.valueOf(Apexpages.currentPage().GetParameters().Get('maturityDate').escapeHtml4());
        formatPayoffDate = Date.valueOf(Apexpages.currentPage().GetParameters().Get('estimatedDate').escapeHtml4());
        accruedDays = Apexpages.currentPage().GetParameters().Get('accruedDays').escapeHtml4();
        LoanNumber = Apexpages.currentPage().GetParameters().Get('loanNumber').escapeHtml4();
        coopType = Apexpages.currentPage().GetParameters().Get('coopType').escapeHtml4();
        growerName = (Apexpages.currentPage().GetParameters().Get('growerName').escapeHtml4()).replace('&amp;', '&');

    }
    /**
     * @description Constructor to format and assign values
     */
    public PayoffCalculatorController() {
        try{
            escapeCharacters();
            //format string
            currentBalance = formatAmount(escapedCurrBalance.format());
            currentInterest = formatAmount(escapedCurrInterest.format());
            currentCharges = formatAmount(escapedCurrCharges.format());
            accrualDailyFactor = formatAmount(String.valueOf(escapedAccDailyFactor.setScale(3)));
            estimatedBalance = formatAmount(escapedEstBalance.format());
            estimatedInterest = formatAmount(escapedEstInterest.format());
            estimatedCharges = formatAmount(escapedEstCharges.format());
            currentTotalBalance = formatAmount(escapedCurrTolBalance.format());
            estimatedTotalBalance = formatAmount(escapedEstTolBalance.format());
            maturityDate = String.valueOf(formatMaturityDate.month()+'/'+formatMaturityDate.day()+'/'+formatMaturityDate.year());
            estimatedDate = String.valueOf(formatPayoffDate.month()+'/'+formatPayoffDate.day()+'/'+formatPayoffDate.year());
            todaysDate = String.valueOf(formatTodaysDate.month()+'/'+formatTodaysDate.day()+'/'+formatTodaysDate.year());
            cropYear = Apexpages.currentPage().GetParameters().Get('cropYear').escapeHtml4();
            isSubTranche = Boolean.valueOf(Apexpages.currentPage().GetParameters().Get('isSubTranche').escapeHtml4());
        }catch(Exception objException){
            PortalHelper.saveExceptionLog(objException, PAYOFF_CALCULATOR_CLASS);
        }
    }
}