/**
 * @description       : Handler class for PortalCreateMyProgramAPI
 * @author            : Pritam Roy
 * @group             : 
 * @last modified on  : 05-03-2024
 * @last modified by  :  Pritam Roy
**/
global inherited sharing class CreateMyProgramHandler {
    // Constant parameters specific for this class starts
    private static final String KEY_SHOULD_VALIDATE = 'shouldValidate';
    private static final String FLEXPRICING = 'flexPricing';
    private static final String FLEXPROGRAM = 'flexRateProgram';
    private static final String FLEX_PRICE_STRING = ' Flex Price';
    private static final String NEGATIVE_STRING = 'No';
    private static final String LOAN_STRING = 'Loan';
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
    private static final String PROGRAM = 'program';
    // Constant parameters specific for this class ends

    /**
     * @description Wrapper class with flex rate arguments
     */
    global class FlexRateWrapper{
        //wrapper class for Flex Rate
        global Boolean shouldValidate;
        global String flexRateStr;
        global Map<String,Object> flexRatingJsonMap;
    }

    /**
    * @description validate flex rate arguments
    * @author Ayan Bhowmik | 02-27-2024 
    * @param rateCardArguments 
    * @return FlexRateWrapper 
    **/
    public static FlexRateWrapper validateFlexRateCard(Map<String, Object> rateCardArguments){
        Map<String, Object> flexRatingJsonMap = new Map<String, Object>();
        FlexRateWrapper objFlexRateWrapper = new FlexRateWrapper();
        Boolean shouldValidate = false;
        String flexRateStr = '';
        //validate flex rate arguments
        MyProgramUtil.nullCheckException(rateCardArguments.get(FLEXPRICING),PortalConstants.SOMETHING_WENT_WRONG);
        MyProgramUtil.nullCheckException(rateCardArguments.get(KEY_SHOULD_VALIDATE),PortalConstants.REQUIRED_PARAMETERS_MISSING);
        shouldValidate = Boolean.valueOf(rateCardArguments.get(KEY_SHOULD_VALIDATE));
        flexRateStr = String.valueOf(rateCardArguments.get(FLEXPRICING));
        if(String.isNotBlank(flexRateStr)){
            flexRatingJsonMap = (Map<String, Object>)Json.deserializeUntyped(flexRateStr);
        }
        //Rate Card Header for Flex Rate
        MyProgramUtil.nullCheckException(flexRatingJsonMap.get(FLEXPROGRAM),PortalConstants.SOMETHING_WENT_WRONG);
        objFlexRateWrapper.flexRateStr = flexRateStr;
        objFlexRateWrapper.flexRatingJsonMap = flexRatingJsonMap;
        objFlexRateWrapper.shouldValidate = shouldValidate;
        return objFlexRateWrapper;
    }

    /**
    * @description update flex rate header details
    * @author Ayan Bhowmik | 02-27-2024 
    * @param objRateCardHeader 
    * @param objdealerAccountName 
    * @param objApplicationBorrower 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    public static genesis__Rate_Card_Setup_Header__c updateFlexRateHeader(genesis__Rate_Card_Setup_Header__c objRateCardHeader,List<User> objdealerAccountName,genesis__Applications__c objApplicationBorrower){
        Date flexRateStartDate;
        RecordType objRecordType = MyProgramHelper.getHeaderRecordType();
        MyProgramUtil.nullCheckException(objRecordType,PortalConstants.SOMETHING_WENT_WRONG);
        if(objRecordType != null){
            objRateCardHeader.RecordTypeId = objRecordType.Id;
        }
        //Assigning the rate card to the Dealer
        if(objdealerAccountName.size() > 0 &&
                objdealerAccountName[0].Contact.Account.ParentId != null){
            objRateCardHeader.Account__c = objdealerAccountName[0].Contact.Account.ParentId;
                BaseRateService.BaseRateInfo baseRateInfo = BaseRateService.fetchAndCacheBaseRate(objRateCardHeader.Account__c);
                try{
                    if(baseRateInfo != null && baseRateInfo.floatingRateIndex != null) {
                        objRateCardHeader.Base_Rate__c = baseRateInfo.floatingRateIndex.Id;
                    }
                } catch(Exception ex){
                    throw new CustomException(ConstantValues.BASE_RATE_NOT_FOUND);
                }
        }
        flexRateStartDate = date.newinstance(objApplicationBorrower.CreatedDate.year(), objApplicationBorrower.CreatedDate.month(), objApplicationBorrower.CreatedDate.day());
        objRateCardHeader.genesis__Start_Date__c = flexRateStartDate;
        objRateCardHeader.genesis__Transaction_Date__c = system.today();
        objRateCardHeader.genesis__Product_Type__c = PortalConstants.PRODUCT_TYPE_FOR_MY_PROGRAM;
        objRateCardHeader.genesis__Filter_By_Credit_Rating__c = false;
        objRateCardHeader.genesis__Filter_By_Frequency__c = false;
        objRateCardHeader.genesis__Filter_By_Loan_Amount__c = false;
        objRateCardHeader.genesis__Filter_By_Term__c = false;
        objRateCardHeader.Is_Flex_Rate__c = true;
        objRateCardHeader.Special_Term_Number__c = PortalConstants.SPECIAL_TERM_A;
        return objRateCardHeader;
    }

    /**
    * @description update flex rate loan closing fee payer
    * @author Ayan Bhowmik | 02-27-2024 
    * @param objRateCardHeader 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    public static genesis__Rate_Card_Setup_Header__c checkFlexRateLoanClosingFeePayer(genesis__Rate_Card_Setup_Header__c objRateCardHeader){
         //check for the payer of loan closing fee
         if(objRateCardHeader.Payer_of_Loan_Closing_Fee__c == PortalConstants.DEALER_PROFILE){
            //If Dealer is chosen for paying the loan closing fee
            objRateCardHeader.Loan_Fee_Advanced_On__c = null;
            objRateCardHeader.Dealer_Participate_on_Closing_Fee__c = NEGATIVE_STRING;
            objRateCardHeader.Portion_of_Fee_to_Cover__c = 0;
        }
        else{
            //If grower is chosen to pay the loan closing fee
            MyProgramUtil.decimalGreaterThanCheck(objRateCardHeader.Portion_of_Fee_to_Cover__c,objRateCardHeader.Closing_Fee__c,PortalConstants.CLOSING_FEE_EXCEEDED);
        }
        // //validate past date in maturity date
        // MyProgramUtil.dateLessThanCheck(objRateCardHeader.genesis__End_Date__c, System.today(), PortalConstants.CLONE_MATURITY_DATE_ERROR);
        //Validate that the maturity date for the flex rate program is on 15th of a month
        // if(objRateCardHeader.genesis__End_Date__c.Day() != 15){
        //     throw new CustomException(PortalConstants.MATURITY_DATE_ON_15);
        // }
        return objRateCardHeader;
    }

    /**
    * @description validate flex rate application
    * @author Ayan Bhowmik | 02-27-2024 
    * @param objRateCardHeader 
    * @param objApplicationBorrower 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    public static genesis__Rate_Card_Setup_Header__c checkFlexRateApplication(genesis__Rate_Card_Setup_Header__c objRateCardHeader,genesis__Applications__c objApplicationBorrower){  
        MyProgramUtil.nullCheckException(objApplicationBorrower,PortalConstants.SOMETHING_WENT_WRONG);                                              
        objRateCardHeader.Name = objApplicationBorrower.Name+FLEX_PRICE_STRING;
        return objRateCardHeader;
    }

    /**
    * @description update flex rate id in application
    * @author Ayan Bhowmik | 02-27-2024 
    * @param objRateCardHeader 
    * @param objApplication 
    * @param flexRateId 
    **/
    public static void updateFlexRateInApplication(genesis__Rate_Card_Setup_Header__c objRateCardHeader,genesis__Applications__c objApplication,String flexRateId){
        MyProgramUtil.nullCheckException(objApplication,PortalConstants.SOMETHING_WENT_WRONG);                   
        objApplication.My_Program__c = flexRateId;
        objApplication.genesis__Pricing_Method__c = PortalConstants.RATE_CARD_STRING;
        if(objRateCardHeader.genesis__End_Date__c != null && objRateCardHeader.Crop_Year__c != null){
            objApplication.genesis__Maturity_Date__c = objRateCardHeader.genesis__End_Date__c;
            objApplication.Crop_Year__c = objRateCardHeader.Crop_Year__c;
        }
        //update my program for flex rate
        Database.update(objApplication,true);
    }

    /**
    * @description check flex rate additional determing factors
    * @author Ayan Bhowmik | 02-27-2024 
    * @param objRateCardHeader 
    * @param objdealerAccountName 
    **/
    public static void checkFlexRateAdditionalFactors(genesis__Rate_Card_Setup_Header__c objRateCardHeader,List<User> objdealerAccountName){
        List<genesis__Additional_Determining_Factor__c> objFactorDetailList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objFactorDetailDealerList = new List<genesis__Additional_Determining_Factor__c>();

        objFactorDetailList =  [SELECT  Id, 
                                        genesis__Field_Value__c, 
                                        genesis__Rate_Card_Setup_Header__c
                                FROM genesis__Additional_Determining_Factor__c 
                                WHERE genesis__Field_Value__c = :objRateCardHeader.Name AND
                                    genesis__Rate_Card_Setup_Header__c = :objRateCardHeader.Id
                                LIMIT 1];
        if(objdealerAccountName.size() > 0){
        objFactorDetailDealerList = [SELECT Id, 
                                            genesis__Field_Value__c, 
                                            genesis__Rate_Card_Setup_Header__c
                                    FROM genesis__Additional_Determining_Factor__c 
                                    WHERE genesis__Field_Value__c = :objdealerAccountName[0].Contact.Account.Parent.Name AND
                                        genesis__Rate_Card_Setup_Header__c = :objRateCardHeader.Id
                                    LIMIT 1];
        }
        /*generating the rate card setup detail for the FLEX PRICING from the Portal*/
        //fetching the flex rate in a string
        MyProgramUtil.listIsEmptyCheck(objFactorDetailList,PortalConstants.SOMETHING_WENT_WRONG);
        MyProgramUtil.listIsEmptyCheck(objFactorDetailDealerList, PortalConstants.SOMETHING_WENT_WRONG);
    }

    /**
    * @description check flex rate product rate association and additional determing factors
    * @author Ayan Bhowmik | 02-27-2024 
    * @param objRateCardHeader 
    * @param objdealerAccountName 
    **/
    public static void checkFlexRateProgram(genesis__Rate_Card_Setup_Header__c objRateCardHeader,List<User> objdealerAccountName){
        genesis__Additional_Determining_Factor__c objFactorProgram = new genesis__Additional_Determining_Factor__c();
        genesis__Additional_Determining_Factor__c objFactorForDealer = new genesis__Additional_Determining_Factor__c();
        genesis__Product_Rate_Card_Association__c objRateCardAssociation = new genesis__Product_Rate_Card_Association__c();
        List<clcommon__CL_Product__c> objProductToAssociateList = new List<clcommon__CL_Product__c>();

        if(objRateCardHeader.Id != null){
            Database.update(objRateCardHeader,true);
        }else{
            objRateCardHeader.Special_Term_Number__c = PortalConstants.SPECIAL_TERM_A;
            Database.insert(objRateCardHeader,true);
            objProductToAssociateList = [SELECT Id, 
                                            Name, 
                                            RecordType.Name, 
                                            clcommon__Product_Name__c, 
                                            clcommon__Pricing_Method__c 
                                        FROM clcommon__CL_Product__c 
                                        WHERE RecordType.Name = :LOAN_STRING AND 
                                            clcommon__Product_Name__c = :PortalConstants.SIMPLIFY_TYPE 
                                        LIMIT 1];
            //Create a Product Rate Card Association
            if(objProductToAssociateList.isEmpty()){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            //Create a Product Rate Card Association
            objRateCardAssociation.genesis__CL_Product__c = objProductToAssociateList[0].Id;
            objRateCardAssociation.genesis__Rate_Card_Setup__c = objRateCardHeader.Id;
            Database.upsert(objRateCardAssociation,true);
            //Setting up the additional determining factor for the particular My Program
            objFactorProgram.Name = PortalConstants.MY_PROGRAM_FACTOR_NAME; //Program
            objFactorProgram.genesis__Evaluation_Operator__c = PortalConstants.FACTOR_EVALUATION_OPERATOR;
            objFactorProgram.genesis__Rate_Card_Setup_Header__c = objRateCardHeader.Id;
            objFactorProgram.genesis__Applicable_for_Application__c = true;
            objFactorProgram.genesis__Application_Object_API_Name__c = PortalConstants.APPLICATION_API_NAME;
            objFactorProgram.genesis__Application_Object_Name__c = PortalConstants.APPLICATION_OBJECT_NAME;
            objFactorProgram.genesis__Application_Field_API_Name__c =  PortalConstants.MY_PROGRAM_FIELD_API_NAME;
            objFactorProgram.genesis__Application_Field_Name__c = PortalConstants.MY_PROGRAM_FIELD_NAME;
            objFactorProgram.genesis__Application_Field_Type__c = PortalConstants.FIELD_TYPE;
            objFactorProgram.genesis__Apply_to_all_Rate_Card_Details__c = true;
            if(String.isNotBlank(objRateCardHeader.Name)){
                objFactorProgram.genesis__Field_Value__c = objRateCardHeader.Name;
            }
            Database.upsert(objFactorProgram,true);
            //setting up the additional determining factor of the Dealer's name as the factor
            objFactorForDealer.Name = PortalConstants.DEALER_PROFILE;
            objFactorForDealer.genesis__Evaluation_Operator__c = PortalConstants.FACTOR_EVALUATION_OPERATOR;
            objFactorForDealer.genesis__Rate_Card_Setup_Header__c = objRateCardHeader.Id;
            objFactorForDealer.genesis__Applicable_for_Application__c = true;
            objFactorForDealer.genesis__Application_Object_API_Name__c = PortalConstants.APPLICATION_API_NAME;
            objFactorForDealer.genesis__Application_Object_Name__c = PortalConstants.APPLICATION_OBJECT_NAME;
            objFactorForDealer.genesis__Application_Field_API_Name__c =  PortalConstants.MY_PROGRAM_DEALER_FIELD;
            objFactorForDealer.genesis__Application_Field_Name__c = PortalConstants.DEALER_NAME;
            objFactorForDealer.genesis__Application_Field_Type__c = PortalConstants.FIELD_TYPE;
            objFactorForDealer.genesis__Apply_to_all_Rate_Card_Details__c = true;
            if(objdealerAccountName.size() > 0 &&
                    String.isNotBlank(objdealerAccountName[0].Contact.Account.Parent.Name)){
                objFactorForDealer.genesis__Field_Value__c = objdealerAccountName[0].Contact.Account.Parent.Name;
            }
            Database.upsert(objFactorForDealer,true);
        }
    }

    /**
    * @description : validate my program name
    * @author  Pritam Roy | 03-06-2024 
    * @param myProgramName 
    * @param specialCharacter 
    **/
    public static void validateMyProgramName(String myProgramName,String specialCharacter){
        if(myProgramName.contains(specialCharacter)){
            throw new CustomException(PortalConstants.WRONG_MY_PROGRAM_NAME);
        }
    }

    /**
    * @description : check Additional Determining Factor Dealer
    * @author  Pritam Roy | 05-03-2024 
    * @param objdealerAccountName 
    * @return boolean 
    **/
    public static boolean checkArguments(List<User> objdealerAccountName){
        if(objdealerAccountName.size() > 0 &&
            objdealerAccountName[0].Account.ParentId != null &&
            objdealerAccountName[0].Account.Parent.Name != null){
                return true;
        }
        return false;
    }
}