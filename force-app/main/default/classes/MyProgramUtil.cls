/**
 * @description       : Util class for My Program
 * @author            : Pritam Roy
 * @group             : 
 * @last modified on  : 03-04-2024
 * @last modified by  :  Pritam Roy
**/
global inherited sharing class MyProgramUtil {
    private static final String NEGATIVE_STRING = 'No';
    private static final Integer MONTH_AUGUST = 8;
    private static final Integer MONTH_DECEMBER = 12;
    private static final Integer MONTH_JANUARY = 1;
    private static final Integer MONTH_FEBRUARY = 2;
    private static final Integer MONTH_MARCH = 3;

    
    /**
    * @description : check date not equal check
    * @author  Pritam Roy | 03-04-2024 
    * @param objDate 
    * @param objDateToCompare 
    * @param customExceptionString 
    **/
    public static void dateNotEqualsCheck(Date objDate,Date objDateToCompare,String customExceptionString){
        if(objDate != objDateToCompare){
            throw new CustomException(customExceptionString);
        }
    }
    
    /**
    * @description : two integer not equal check
    * @author  Pritam Roy | 03-04-2024 
    * @param objNumber 
    * @param objNumberToCompare 
    * @param customExceptionString 
    **/
    public static void integerNotEqualsCheck(Integer objNumber,Integer objNumberToCompare,String customExceptionString){
        if(objNumber != objNumberToCompare){
            throw new CustomException(customExceptionString);
        }
    }
    /**
    * @description : date less than check 
    * @author  Pritam Roy | 03-04-2024 
    * @param objDate 
    * @param objDateToCompare 
    * @param customExceptionString 
    **/
    public static void dateLessThanCheck(Date objDate,Date objDateToCompare,String customExceptionString){
        if(objDate < objDateToCompare){
            throw new CustomException(customExceptionString);
        }
    }
    /**
    * @description : decimal greater than check
    * @author  Pritam Roy | 03-04-2024 
    * @param objDecimal 
    * @param objDecimalToCompare 
    * @param customExceptionString 
    **/
    public static void decimalGreaterThanCheck(Decimal objDecimal,Decimal objDecimalToCompare,String customExceptionString){
        if(objDecimal > objDecimalToCompare){
            throw new CustomException(customExceptionString);
        }
    }
    
    /**
    * @description : null check exception
    * @author  Pritam Roy | 03-04-2024 
    * @param objCheck 
    * @param customExcepTionString 
    **/
    public static void nullCheckException(Object objCheck,String customExcepTionString){
        if(objCheck == null){
            throw new CustomException(customExceptionString);
        }
    }

    /**
    * @description : list is empty check
    * @author  Pritam Roy | 03-04-2024 
    * @param objList 
    * @param customExceptionString 
    **/
    public static void listIsEmptyCheck(List<Object> objList,String customExceptionString){
        if(objList.isEmpty()){
            throw new CustomException(customExceptionString);
        }
    }

    /**
    * @description : prior month check
    * @author  Pritam Roy | 03-04-2024 
    * @param startDate 
    * @param maturityDate 
    **/
    public static void priorMonthCheckvalidation(Date startDate,Date maturityDate){
        // if it is the last day of the month then check whether the month is not the prior month of maturity
        if((startDate.Month() == maturityDate.Month()) &&
                (startDate.Year() == maturityDate.Year())){ 
            throw new CustomException(PortalConstants.PRIOR_MONTH_CHECK);
        }
    }
    /**
    * @description : null object check
    * @author  Pritam Roy | 03-04-2024 
    * @param objToCheck 
    * @return string 
    **/
    public static string objNullCheck(Object objToCheck){
        if(objToCheck != null){
            return (string)objToCheck;
        }
        return '';
    }
    
    /**
    * @description : validate rate card detail
    * @author  Pritam Roy | 03-04-2024 
    * @param objRateCardsToInsert 
    * @param maturityDate 
    **/
    public static void validateRateCardDetail(List<genesis__Rate_Card_Setup_Detail__c> objRateCardsToInsert,Date maturityDate){
        Date endDatePrevious;
        Integer rateCardSize = objRateCardsToInsert.size();
        Integer countRateCard = 0;
        Date startDate;
        Date endDate;
        Integer lastDay = 0;
        for(genesis__Rate_Card_Setup_Detail__c objRateCard : objRateCardsToInsert){
            startDate = objRateCard.Start_Date__c;
            endDate = objRateCard.End_Date__c;

            //check for start date and end date such that they do not overlap
            if(endDatePrevious != null){
                dateNotEqualsCheck(startDate,endDatePrevious.addDays(1),PortalConstants.START_DATE_CHECK);
            }
            //check if enddate is greater than maturity
            if(endDate > maturityDate){
                throw new CustomException(PortalConstants.LAST_DATE_PASSED_MATURITY+' :'+ maturityDate.format());
            }
            lastDay = Date.daysInMonth(endDate.Year(), endDate.Month());
            //last end date must be maturity date
            if(countRateCard == (rateCardSize - 1)){
                dateNotEqualsCheck(endDate,maturityDate,PortalConstants.LAST_END_DATE_CHECK_MATURITY+maturityDate.format());
            }
            ////if the end date is not on the last day of the month
            if(endDate != maturityDate){
                IntegerNotEqualsCheck(endDate.Day(), lastDay, PortalConstants.LAST_DATE_VALIDATION);
            }
            if(countRateCard > 0){
                priorMonthCheckvalidation(startDate,maturityDate);
            }
            endDatePrevious = endDate;
            countRateCard++;
        }
    }
}