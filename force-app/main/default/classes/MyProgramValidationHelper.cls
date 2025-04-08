/**
 * @description       : Validation class for My Program
 * @author            : Pritam Roy
 * @group             : 
 * @last modified on  : 08-27-2024
 * @last modified by  :  Pritam Roy
**/
global inherited sharing class MyProgramValidationHelper {
    private static final String FIELD_CROP_YEAR = 'Crop_Year__c';
    private static final String FIELD_MATURITY_DATE = 'genesis__End_Date__c';
    private static final String FIELD_PAYER = 'Payer_of_Loan_Closing_Fee__c';
    private static final String FIELD_ADVANCEON = 'Loan_Fee_Advanced_On__c';
    private static final String FIELD_DEALER_PART = 'Dealer_Participate_on_Closing_Fee__c';
    private static final String FIELD_FEE_PORTION = 'Portion_of_Fee_to_Cover__c';
    private static final String FIELD_CFA_ADV = 'CFA_Advantage_Rate__c';
    private static final String FIELD_CLOSING_FEE = 'Closing_Fee__c';
    private static final String FIELD_BASE_RATE = 'Base_Rate_Value__c';
    private static final String FIELD_ID = 'Id';
    private static final String AFFIRMATIVE = 'Yes';
    private static final String NEW_RECORD_STRING = 'new_record_id';
    private static final Integer MONTH_JANUARY = 1;
    private static final Integer MONTH_FEBRUARY = 2;
    private static final Integer MONTH_MARCH = 3;
    private static final String FIELD_FINANCE_RATE = 'Field_Finance_Rate__c';


    /**
    * @description validate string and return
    * @author Ayan Bhowmik | 02-22-2024 
    * @param objCheck 
    * @return string 
    **/
    public static string validateStringNullCheck(Object objCheck){
        if(objCheck != null){
            return (String)objCheck;
        }
        return '';

    /**
    * @description check affirmative 
    * @author Ayan Bhowmik | 02-22-2024 
    * @param objCheck 
    * @param objToCompare 
    * @param customExceptionString 
    **/
    }public static void checkAffirmative(Object objCheck,Object objToCompare,string customExceptionString){
        if(objCheck == AFFIRMATIVE && objToCompare == null){
            throw new CustomException(customExceptionString);
        }
    }

    /**
    * @description check description
    * @author Ayan Bhowmik | 02-22-2024 
    * @param setupDescription 
    * @param objRateCardDetailList 
    **/
    public static void checkDescription(String setupDescription,List<Object> objRateCardDetailList){
        //if description not found for more than one rate card detail
        if(String.isBlank(setupDescription) &&
                objRateCardDetailList.size() > 0){
            throw new CustomException(PortalConstants.DESCRIPTION_ERROR);
        }
    }

    /**
    * @description null check list
    * @author Ayan Bhowmik | 02-22-2024 
    * @param objList 
    * @return string 
    **/
    public static string checkNullList(List<Object> objList){
        if(objList != null){
            return  (String)objList[0];
        }
        return '';
    }

    /**
    * @description validate flex rate header arguments
    * @author Ayan Bhowmik | 02-22-2024 
    * @param applicationId 
    * @param flexRateProgramMap 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    public static genesis__Rate_Card_Setup_Header__c validateFlexRateHeader(String applicationId, Map<String, Object> flexRateProgramMap) {
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        String myProgramId = '';
    
        genesis__Applications__c application = [
            SELECT Dealer_Name__r.CFA_Partner_Program__r.Base_Rate__r.Name,
                   Dealer_Name__r.CFA_Partner_Program__r.Base_Rate__r.Current_Floating_Rate__c
            FROM genesis__Applications__c
            WHERE Id = :applicationId
        ];
    
        String baseRateName = application.Dealer_Name__r.CFA_Partner_Program__r.Base_Rate__r.Name;
        Decimal baseRateValue = application.Dealer_Name__r.CFA_Partner_Program__r.Base_Rate__r.Current_Floating_Rate__c;
    
        objRateCardHeader.Crop_Year__c = (String) flexRateProgramMap.get(FIELD_CROP_YEAR);
    
        if (flexRateProgramMap.get(baseRateName) != null) {
            objRateCardHeader.put(baseRateName, baseRateValue);
        }
    
        if (flexRateProgramMap.get(FIELD_CLOSING_FEE) != null) {
            objRateCardHeader.Closing_Fee__c = (Decimal) flexRateProgramMap.get(FIELD_CLOSING_FEE);
        }
    
        if (flexRateProgramMap.get(FIELD_MATURITY_DATE) != null) {
            objRateCardHeader.genesis__End_Date__c = Date.valueOf((String) flexRateProgramMap.get(FIELD_MATURITY_DATE));
        }
    
        objRateCardHeader.Payer_of_Loan_Closing_Fee__c = (String) flexRateProgramMap.get(FIELD_PAYER);
    
        if ((String) flexRateProgramMap.get(FIELD_PAYER) == PortalConstants.GROWER_PROFILE) {
            objRateCardHeader.Loan_Fee_Advanced_On__c = (String) flexRateProgramMap.get(FIELD_ADVANCEON);
            objRateCardHeader.Dealer_Participate_on_Closing_Fee__c = (String) flexRateProgramMap.get(FIELD_DEALER_PART);
    
            if (flexRateProgramMap.get(FIELD_DEALER_PART) == AFFIRMATIVE &&
                flexRateProgramMap.get(FIELD_FEE_PORTION) != null) {
                objRateCardHeader.Portion_of_Fee_to_Cover__c = (Decimal) flexRateProgramMap.get(FIELD_FEE_PORTION);
            }
        }
        //Inside flexRatingJsonMap we have my program Id, rateCard list
        myProgramId = (String)flexRateProgramMap.get(FIELD_ID);
        if(myProgramId == null || myProgramId == NEW_RECORD_STRING){
            objRateCardHeader.Id = null;
        }
        else{
            objRateCardHeader.Id = myProgramId;
        }
        return objRateCardHeader;
    }
    /**
    * @description : Validate Billing Date
    * @author  Pritam Roy | 07-23-2024 
    * @param billingDate 
    * @param maturityDate 
    **/
    public static void validateBillingDate(Date billingDate,Date maturityDate){
        if(billingDate < System.today()){
            throw new CustomException(PortalConstants.BILLING_DATE_TODAYS_DATE_CHECK);
        }
        if(billingDate > maturityDate){
            throw new CustomException(PortalConstants.BILLING_DATE_MATURITY_DATE_CHECK);
        }
        if(!isLastDayOfMonth(billingDate)){
            throw new CustomException(PortalConstants.BILLING_DATE_IS_NOT_LAST_DAY);
        }
    }

    /**
    * @description : Check Last Day of Month
    * @author  Pritam Roy | 08-23-2024 
    * @param inputDate 
    * @return Boolean 
    **/
    public static Boolean isLastDayOfMonth(Date inputDate) {
        // Set the day to 1 to get the first day of the month
        Date firstDayOfMonth = inputDate.addDays(-inputDate.day() + 1);
    
        // Add one month and subtract one day to get the last day of the month
        Date lastDayOfMonth = firstDayOfMonth.addMonths(1).addDays(-1);
    
        // Check if the input date is equal to the last day of the month
        return inputDate.equals(lastDayOfMonth);
    }
}