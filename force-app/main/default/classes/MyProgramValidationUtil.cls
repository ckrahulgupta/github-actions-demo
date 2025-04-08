/**
 * @description       : Validation class for My Program
 * @author            : Pritam Roy
 * @group             : 
 * @last modified on  : 06-26-2024
**/
global inherited sharing class MyProgramValidationUtil {
    private static final String NEGATIVE_STRING = 'No';
    private static final Integer MONTH_AUGUST = 8;
    private static final Integer MONTH_DECEMBER = 12;
    private static final Integer MONTH_JANUARY = 1;
    private static final Integer MONTH_FEBRUARY = 2;
    private static final Integer MONTH_MARCH = 3;
    private static final Integer MONTH_APRIL = 4;
    private static final Integer MONTH_MAY = 5;
    private static final Integer MONTH_JUNE = 6;
    private static final Integer MONTH_JULY = 7;
    private static final Integer MONTH_SEPTEMBER = 9;
    private static final Integer MONTH_OCTOBER = 10;
    private static final Integer MONTH_NOVEMBER = 11;
    
    /**
    * @description : validate crop year
    * @author  Pritam Roy | 03-04-2024 
    * @param cropYearToValidate 
    **/
    public static void validateCropYear(Integer cropYearToValidate){ 
        switch on System.today().month(){
            when 1,2,3,4,5{
                if(cropYearToValidate != System.today().Year()){
                    throw new CustomException(PortalConstants.CROP_YEAR_ELIGIBLE_ERROR_JAN_MAY);
                }
            }
            when 6,7,8{
                if(cropYearToValidate != System.today().Year() && cropYearToValidate != System.today().Year() + 1){
                    throw new CustomException(PortalConstants.CROP_YEAR_ELIGIBLE_ERROR_JUN_AUG);
                }
            }
            when 9,10,11,12{
                if(cropYearToValidate != System.today().Year() + 1){
                    throw new CustomException(PortalConstants.CROP_YEAR_ELIGIBLE_ERROR_SEP_DEC);
                }
            }
        }
    }
    
    /**
    * @description : update my program loan payer closing fee
    * @author  Pritam Roy | 03-04-2024 
    * @param objRateCardHeader 
    * @param cropYearToValidate 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    public static genesis__Rate_Card_Setup_Header__c validateMyProgramRateCardHeader(genesis__Rate_Card_Setup_Header__c objRateCardHeader,Integer cropYearToValidate){
        //check for the payer of loan closing fee
        if(objRateCardHeader.Payer_of_Loan_Closing_Fee__c == PortalConstants.DEALER_PROFILE){
            //If Dealer is chosen for paying the loan closing fee
            objRateCardHeader.Loan_Fee_Advanced_On__c = null;
            objRateCardHeader.Dealer_Participate_on_Closing_Fee__c = NEGATIVE_STRING;
            objRateCardHeader.Portion_of_Fee_to_Cover__c = 0;
        }
        else{
            //If grower is chosen to pay the loan closing fee
            if(objRateCardHeader.Portion_of_Fee_to_Cover__c > objRateCardHeader.Closing_Fee__c){
                throw new CustomException(PortalConstants.CLOSING_FEE_EXCEEDED);
            }
        }
        //Auto populating start date of the 'My Program' as today's date if not selected
        objRateCardHeader.genesis__Start_Date__c = System.today();
        //Check for the maturity date of a my program to be on future dates
        // MyProgramUtil.dateLessThanCheck(objRateCardHeader.genesis__End_Date__c, System.today(), PortalConstants.CLONE_MATURITY_DATE_ERROR);
        // //Check for the maturity date of a my program to be on 15th
        // MyProgramUtil.integerNotEqualsCheck(objRateCardHeader.genesis__End_Date__c.Day(),PortalConstants.MATURITY_DATE_DAY,PortalConstants.MATURITY_DATE_ON_15);
        validateMaturityDate(objRateCardHeader, cropYearToValidate);
        return objRateCardHeader;
    }
    
    /**
    * @description : validate logged in user
    * @author  Pritam Roy | 03-04-2024 
    * @param objLoggedInUserList 
    * @param myProgramHeaderId 
    **/
    public static void validateLoggedInUser(List<User> objLoggedInUserList,String myProgramHeaderId){
        Boolean isMyProgram = false;
        if(objLoggedInUserList.size() > 0 && objLoggedInUserList[0].Contact.Account.Parent.Tier__c !=null &&
            objLoggedInUserList[0].Contact.Account.ParentId != null){
                //Validate user
            isMyProgram = PortalSecurityUtil.validateRateCardDetailByDealer(objLoggedInUserList[0].Contact.Account.ParentId, myProgramHeaderId);
            if(!isMyProgram){
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }
        }
        else{
            //invalid user
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }
    }
    
    /**
    * @description : validate rate card header
    * @author  Pritam Roy | 03-04-2024 
    * @param objRateCardHeaderList 
    **/
    public static void validateRateCardHeader(List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList){
        //validate rate card header
        if(objRateCardHeaderList.size() == 0 || objRateCardHeaderList == null){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        MyProgramUtil.nullCheckException(objRateCardHeaderList[0].Name,PortalConstants.SOMETHING_WENT_WRONG);
        MyProgramUtil.nullCheckException(objRateCardHeaderList[0].Account__r.Name, PortalConstants.SOMETHING_WENT_WRONG);
        MyProgramUtil.nullCheckException(objRateCardHeaderList[0].genesis__End_Date__c, PortalConstants.SOMETHING_WENT_WRONG);
    }
    
    /**
    * @description : validate tier and addional factor
    * @author  Pritam Roy | 03-04-2024 
    * @param objFactorProgram 
    * @param obFactorForDealer 
    * @param objTierParticipationList 
    **/
    public static void validateTierAndAdditionalFactor(genesis__Additional_Determining_Factor__c objFactorProgram,genesis__Additional_Determining_Factor__c obFactorForDealer,List<Tier_Participation_Rate__mdt> objTierParticipationList){
        if(objFactorProgram == null || obFactorForDealer == null || objTierParticipationList.size() == 0){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }  
    }
    
    /**
    * @description : validate maturity date
    * @author  Pritam Roy | 03-04-2024 
    * @param objRateCardHeader 
    * @param cropYearToValidate 
    **/
    public static void validateMaturityDate(genesis__Rate_Card_Setup_Header__c objRateCardHeader,Integer cropYearToValidate){
        ////MATURITY DATE VALIDATION ---------------------------------
        //Check for the maturity date of a my program to be on future dates
        MyProgramUtil.dateLessThanCheck(objRateCardHeader.genesis__End_Date__c, System.today(), PortalConstants.CLONE_MATURITY_DATE_ERROR);
        //Check for the maturity date of a my program to be on 15th
        MyProgramUtil.integerNotEqualsCheck(objRateCardHeader.genesis__End_Date__c.Day(),PortalConstants.MATURITY_DATE_DAY,PortalConstants.MATURITY_DATE_ON_15);

        if(objRateCardHeader.genesis__End_Date__c.year() > cropYearToValidate + 1){
                throw new CustomException(PortalConstants.MATURITY_DATE_EXCEEDED_ERROR+Integer.valueOf(cropYearToValidate+1));
        }
        if(objRateCardHeader.genesis__End_Date__c.year() == cropYearToValidate){
            //December And August should be the only months
            validateAprilToDecember(objRateCardHeader);
        }
        if(objRateCardHeader.genesis__End_Date__c.year() == cropYearToValidate+1){
            //Only Jan - March allowed
            validateJanuaryToMarch(objRateCardHeader,cropYearToValidate);
        }
        if(objRateCardHeader.genesis__End_Date__c.year() < cropYearToValidate){
            throw new CustomException(PortalConstants.MATURITY_DATE_ERROR
                + Date.newInstance(Integer.valueOf(objRateCardHeader.Crop_Year__c), 4, 15).format() + PortalConstants.MATURITY_DATE_ERROR_EXTENDED
                + Date.newInstance((Integer.valueOf(objRateCardHeader.Crop_Year__c)+1), 3, 15).format());
        }
    }
    
    /**
    * @description : validate maturity date April To December
    * @author  Pritam Roy | 03-04-2024 
    * @param objRateCardHeader 
    **/
    private static void validateAprilToDecember(genesis__Rate_Card_Setup_Header__c objRateCardHeader){
        List<Integer> monthList = new List<Integer>{MONTH_APRIL, MONTH_MAY, MONTH_JUNE, MONTH_JULY, MONTH_AUGUST, 
                                                        MONTH_SEPTEMBER, MONTH_OCTOBER, MONTH_NOVEMBER, MONTH_DECEMBER};
        Integer monthToValidate = objRateCardHeader.genesis__End_Date__c.month();
        if(!monthList.contains(monthToValidate)){
            throw new CustomException(PortalConstants.MATURITY_DATE_ERROR
            + Date.newInstance(Integer.valueOf(objRateCardHeader.Crop_Year__c), 4, 15).format() + PortalConstants.MATURITY_DATE_ERROR_EXTENDED
            + Date.newInstance((Integer.valueOf(objRateCardHeader.Crop_Year__c)+1), 3, 15).format());
        }
    }
    
    /**
    * @description : validate maturity date January To March
    * @author  Pritam Roy | 03-04-2024 
    * @param objRateCardHeader 
    * @param cropYearToValidate 
    **/
    private static void validateJanuaryToMarch(genesis__Rate_Card_Setup_Header__c objRateCardHeader,Integer cropYearToValidate){
        List<Integer> monthList = new List<Integer>{MONTH_JANUARY,MONTH_FEBRUARY,MONTH_MARCH};
        Integer monthToValidate = objRateCardHeader.genesis__End_Date__c.month();
        if(!monthList.contains(monthToValidate)){
            throw new CustomException(PortalConstants.MATURITY_DATE_ERROR
            + Date.newInstance(Integer.valueOf(objRateCardHeader.Crop_Year__c), 4, 15).format() + PortalConstants.MATURITY_DATE_ERROR_EXTENDED
            + Date.newInstance((Integer.valueOf(objRateCardHeader.Crop_Year__c)+1), 3, 15).format());
        }
    }
}