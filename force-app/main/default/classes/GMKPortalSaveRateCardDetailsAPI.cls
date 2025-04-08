/**
 * @description       : Purpose of this class is to create Special Sub - Tranches of My Program
 * @author            : Rahul
 * @group             : 
 * @last modified on  : 08-10-2024
 * @last modified by  : Soumik Pattanayak
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   08-02-2022   Rahul   Initial Version
**/
global inherited sharing class GMKPortalSaveRateCardDetailsAPI{
    // Constant parameters specific for this class starts
    private static final String RATE_CARD = 'interest';
    private static final String PROGRAM_ID = 'programId';
    private static final String SETUP_DETAIL_DESCRIPTION = 'specialInterestDescription';
    private static final String DESCRIPTION_STRING = 'description';
    private static final String SPL_SUB_TRANCHE_STRING = 'Special Term Sub-Tranche (';
    private static final String SPECIAL_TERM_C = PortalConstants.SPECIAL_TERM_C;
    private static final String SPECIAL_TERM_D = PortalConstants.SPECIAL_TERM_D;
    private static final String SPECIAL_TERM_E = PortalConstants.SPECIAL_TERM_E;
    private static final String SPECIAL_TERM_F = PortalConstants.SPECIAL_TERM_F;
    private static final String SPECIAL_TERM_G = PortalConstants.SPECIAL_TERM_G;
    private static final String SPECIAL_TERM_H = PortalConstants.SPECIAL_TERM_H;
    private static final String MASTER_NOTERATE_A = PortalConstants.MASTER_NOTERATE_A;
    private static final String SUB_TRANCHE_B = PortalConstants.SUB_TRANCHE_B;
    private static final String SUB_TRANCHE_C = PortalConstants.SUB_TRANCHE_C;
    private static final String SUB_TRANCHE_D = PortalConstants.SUB_TRANCHE_D;
    private static final String SUB_TRANCHE_E = PortalConstants.SUB_TRANCHE_E;
    private static final String SUB_TRANCHE_F = PortalConstants.SUB_TRANCHE_F;
    private static final String SUB_TRANCHE_G = PortalConstants.SUB_TRANCHE_G;
    private static final String SUB_TRANCHE_H = PortalConstants.SUB_TRANCHE_H;
    private static final String VARIABLE = 'Variable';
    // Constant parameters specific for this class ends

    private static List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList; 
    private static genesis__Additional_Determining_Factor__c objFactorProgram;
    private static genesis__Additional_Determining_Factor__c objFactorDealer;
    private static List<Object> objRateCardDetailList;
    private static String setupDescription;
    private static Boolean assignBillingDate;
    private static Date billingDate;
    
    // clcommon.Response response = new clcommon.Response();

    /**
    * @description : Validate Logged In User
    * @author  Pritam Roy | 03-04-2024 
    * @param myProgramHeaderId 
    **/
    private static void validateRateCardUser(String myProgramHeaderId) {
        List<User> objLoggedInUserList = PortalApplicationOriginationHelper.getLoggedInUser();
        if (objLoggedInUserList.size() > 0 && objLoggedInUserList[0].Account.ParentId != null) {
                // Validate user
                Boolean isMyProgram = PortalSecurityUtil.validateRateCardDetailByDealer(objLoggedInUserList[0].Account.ParentId, myProgramHeaderId);
                if (!isMyProgram) {
                    throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
                }
        } else {
            //invalid user
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }
    }


    /**
    * @description : Get Rate Card Header
    * @author  Pritam Roy | 03-04-2024 
    * @param myProgramHeaderId 
    * @return List<genesis__Rate_Card_Setup_Header__c> 
    **/
    private static List<genesis__Rate_Card_Setup_Header__c> getRateCardSetupHeaderList(String myProgramHeaderId) {

        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList = [SELECT Id,
                                                                                Name,
                                                                                Account__r.Name,
                                                                                FS_Index_Rate__c,
                                                                                genesis__End_Date__c,
                                                                                Special_Term_Number__c
                                                                            FROM genesis__Rate_Card_Setup_Header__c
                                                                            WHERE Id = :myProgramHeaderId];
        MyProgramUtil.nullCheckException(objRateCardHeaderList, PortalConstants.SOMETHING_WENT_WRONG);
        MyProgramUtil.listIsEmptyCheck(objRateCardHeaderList, PortalConstants.SOMETHING_WENT_WRONG);
        return objRateCardHeaderList;
    }

    /**
    * @description : Generate Default Note
    * @author  Pritam Roy | 03-04-2024 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    private static genesis__Rate_Card_Setup_Detail__c generateDefaultNoteRate() {
        //Create a default note rate for the My Program
        genesis__Rate_Card_Setup_Detail__c objDefaultNoteRate = new genesis__Rate_Card_Setup_Detail__c();
        objDefaultNoteRate.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_A;
        objDefaultNoteRate.genesis__Use_Additional_Determining_Factors__c = true;
        objDefaultNoteRate.genesis__Determining_Factor_Key_Value__c = 
                    String.valueOf(objFactorProgram.Id) + ':'
                    + objRateCardHeaderList[0].Name+'#'
                    + String.valueOf(objFactorDealer.Id) + ':'
                    + objRateCardHeaderList[0].Account__r.Name;

        objDefaultNoteRate.genesis__Pricing_Method__c = PortalConstants.INTEREST_RATE_STRING;
        objDefaultNoteRate.genesis__Rate_Card_Setup_Header__c = objRateCardHeaderList[0].Id;
        objDefaultNoteRate.Start_Date__c = System.today();
        objDefaultNoteRate.End_Date__c = objRateCardHeaderList[0].genesis__End_Date__c;
        objDefaultNoteRate.Participation_Percentage_Dealer_Subsidy__c = 0;
        objDefaultNoteRate.Participation_Percentage_CFA__c = 0;
        objDefaultNoteRate.Participation_Percentage_Dealer__c = 0;
        objDefaultNoteRate.genesis__Interest_Rate__c = objRateCardHeaderList[0].FS_Index_Rate__c;
        objDefaultNoteRate.Special_Term_Order__c = 1;

        if (String.isBlank(setupDescription)) {
            objDefaultNoteRate.Description__c = PortalConstants.NOTE_RATE;
        } else {
            objDefaultNoteRate.Description__c = setupDescription;
        }
        objDefaultNoteRate.Interest_Rate_Type__c = VARIABLE;


        return objDefaultNoteRate;
    }

    /**
    * @description : Set rate card description to map
    * @author  Pritam Roy | 03-04-2024 
    * @param aggRateDescriptionList 
    * @return Map<String, String> 
    **/
    private static Map<String, String> getRateCardDescriptionMap(List<AggregateResult> aggRateDescriptionList) {
        Map<String, String> rateToDescriptionMap = new Map<String, String>();

        for (AggregateResult eachRate : aggRateDescriptionList) {
            if ((String)eachRate.get(DESCRIPTION_STRING) != null) {
                rateToDescriptionMap.put((String)eachRate.get(DESCRIPTION_STRING),DESCRIPTION_STRING);
            }
        }

        return rateToDescriptionMap;
    }

    /**
    * @description : Validate Grower Rate
    * @author  Pritam Roy | 03-04-2024 
    * @param objRateCard 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    private static genesis__Rate_Card_Setup_Detail__c validateGrowerRate(genesis__Rate_Card_Setup_Detail__c objRateCard) {
        //CALCULATION BASED ON GROWER RATE ---------------------------------------------------------------------------------------------
        //CALCULATION
        MyProgramUtil.nullCheckException(objRateCard.genesis__Interest_Rate__c, PortalConstants.REQUIRED_PARAMETERS_MISSING);
        //validation for Grower Rate and CFA Participation Rate calculations
        if (objRateCard.genesis__Interest_Rate__c > objRateCardHeaderList[0].FS_Index_Rate__c) {
            //Dealer Premium is chosen
            objRateCard.Participation_Percentage_Dealer_Subsidy__c = 0;
            objRateCard.Participation_Percentage_CFA__c = 0;
            objRateCard.Participation_Percentage_Dealer__c = 
                            objRateCard.genesis__Interest_Rate__c
                            - objRateCardHeaderList[0].FS_Index_Rate__c;

        } else if (objRateCard.genesis__Interest_Rate__c < objRateCardHeaderList[0].FS_Index_Rate__c) {
            //Dealer subsidy is chosen
            objRateCard.Participation_Percentage_Dealer__c = 0; //premium = 0
            objRateCard.Participation_Percentage_Dealer_Subsidy__c = 
                                objRateCardHeaderList[0].FS_Index_Rate__c 
                                - objRateCard.genesis__Interest_Rate__c;
            if (objRateCard.Participation_Percentage_Dealer_Subsidy__c / 2 > PortalConstants.MAXIMUM_CFA_PARTICIPATION) {
                objRateCard.Participation_Percentage_CFA__c = 0;
            } else {
                //make CFA Participation equal to dealer subsidy
                objRateCard.Participation_Percentage_CFA__c = 0;
            }
            objRateCard.Participation_Percentage_Dealer_Subsidy__c = 
                                objRateCardHeaderList[0].FS_Index_Rate__c 
                                - objRateCard.genesis__Interest_Rate__c;
        } else {
            objRateCard.Participation_Percentage_Dealer_Subsidy__c = 0;
            objRateCard.Participation_Percentage_CFA__c = 0;
            objRateCard.Participation_Percentage_Dealer__c = 0;
        }
        //CALCULATION BASED ON GROWER RATE ---------------------------------------------------------------------------------------------

        return objRateCard;
    }


    /**
    * @description : Process Existing Subtranche
    * @author  Pritam Roy | 03-04-2024 
    * @param myProgramHeaderId 
    * @param subTrancheString 
    * @return List<genesis__Rate_Card_Setup_Detail__c> 
    **/
    private static List<genesis__Rate_Card_Setup_Detail__c> processExistingSubTranche(String myProgramHeaderId, String subTrancheString) {
        Integer count = 0;
        Date endDatePrevious;
        Integer numberOfRatePerSubTranche = objRateCardDetailList.size();

        List<genesis__Rate_Card_Setup_Detail__c> objRateCardsToInsert = new List<genesis__Rate_Card_Setup_Detail__c>();

        for (Object rateCardObj : objRateCardDetailList) {
            Map<String, Object> rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(rateCardObj));
            genesis__Rate_Card_Setup_Detail__c objRateCard = new genesis__Rate_Card_Setup_Detail__c();
            objRateCard = PortalHelper.getRateCardDetails(rateCardMap, setupDescription);
            objRateCard.Special_Term_Reference__c = subTrancheString;
            objRateCard.genesis__Use_Additional_Determining_Factors__c = true;
            objRateCard.genesis__Determining_Factor_Key_Value__c = 
                        String.valueOf(objFactorProgram.Id) + ':'
                        + objRateCardHeaderList[0].Name + '#'
                        + String.valueOf(objFactorDealer.Id) + ':'
                        + objRateCardHeaderList[0].Account__r.Name;

            objRateCard.genesis__Pricing_Method__c = PortalConstants.INTEREST_RATE_STRING;

            if (objRateCard.Id == null) {
                objRateCard.genesis__Rate_Card_Setup_Header__c = myProgramHeaderId;
            }
      
            //objRateCard = validateIndividualRateCardSetupDetail(objRateCard, count, endDatePrevious);
            //for the rates excluding the last date store the end date temporarily
            if (count < numberOfRatePerSubTranche - 1) { 
                //for rates excluding the last date
                endDatePrevious = objRateCard.End_Date__c;
            }
            if(billingDate != null){
                objRateCard.Billing_Date__c = billingDate;
            }
            objRateCard.Has_Billing_Date__c = assignBillingDate;
            objRateCard = validateGrowerRate(objRateCard);
            //CALCULATION BASED ON GROWER RATE ---------------------------------------------------------------------------------------------

            objRateCard.Special_Term_Order__c = count + 1;
            objRateCardsToInsert.add(objRateCard); 
            count++;
        }
        Database.upsert(objRateCardsToInsert, true);

        return objRateCardsToInsert;
    }

    /**
    * @description : Process New Subtranche
    * @author  Pritam Roy | 03-04-2024 
    * @param myProgramHeaderId 
    * @param subTrancheString 
    * @return List<genesis__Rate_Card_Setup_Detail__c> 
    **/
    private static List<genesis__Rate_Card_Setup_Detail__c> processNewSubTranche(String myProgramHeaderId, String subTrancheString) {
        Integer count = 0;
        Date endDatePrevious;
        Integer numberOfRatePerSubTranche = objRateCardDetailList.size();

        List<genesis__Rate_Card_Setup_Detail__c> objRateCardsToInsert = new List<genesis__Rate_Card_Setup_Detail__c>();

        for (Object rateCardObj : objRateCardDetailList) {
            Map<String, Object> rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(rateCardObj));
            genesis__Rate_Card_Setup_Detail__c objRateCard = new genesis__Rate_Card_Setup_Detail__c();
            objRateCard = PortalHelper.getRateCardDetails(rateCardMap, setupDescription);

            if (objRateCardHeaderList[0].Special_Term_Number__c != null) {
                objRateCard.Special_Term_Reference__c = objRateCardHeaderList[0].Special_Term_Number__c;
            }
            objRateCard.Id = null;
            objRateCard.genesis__Use_Additional_Determining_Factors__c = true;
            objRateCard.genesis__Determining_Factor_Key_Value__c = 
                        String.valueOf(objFactorProgram.Id) + ':'
                        + objRateCardHeaderList[0].Name + '#'
                        + String.valueOf(objFactorDealer.Id) + ':'
                        + objRateCardHeaderList[0].Account__r.Name;
            objRateCard.genesis__Pricing_Method__c = PortalConstants.INTEREST_RATE_STRING;
            if (objRateCard.Id == null) {
                objRateCard.genesis__Rate_Card_Setup_Header__c = myProgramHeaderId;
            }
            if(billingDate != null){
                objRateCard.Billing_Date__c = billingDate;
            }
            objRateCard.Has_Billing_Date__c = assignBillingDate;
            //objRateCard = validateIndividualRateCardSetupDetail(objRateCard, count, endDatePrevious);


            //for the rates excluding the last date store the end date temporarily
            if (count < numberOfRatePerSubTranche - 1) { 
                //for rates excluding the last date
                endDatePrevious = objRateCard.End_Date__c;
            }
            objRateCard = validateGrowerRate(objRateCard);
            //CALCULATION BASED ON GROWER RATE ---------------------------------------------------------------------------------------------
            // updating the Special Term order
            objRateCard.Special_Term_Order__c = count + 1;
            objRateCardsToInsert.add(objRateCard); 
            count++;
        }

        return objRateCardsToInsert;
    }

    /**
    * @description : Update Default Note
    * @author  Pritam Roy | 03-04-2024 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    private static genesis__Rate_Card_Setup_Detail__c updateDefaultNoteRate() {
        // Create a default note rate for the My Program
        genesis__Rate_Card_Setup_Detail__c objDefaultNoteRate = generateDefaultNoteRate();

        Database.insert(objDefaultNoteRate, true);
        objRateCardHeaderList[0].Special_Term_Number__c = PortalConstants.SPECIAL_TERM_B;
        Database.update(objRateCardHeaderList[0], true);

        return objDefaultNoteRate;
    }


    /**
    * @description : Update Additional Determining Factor
    * @author  Pritam Roy | 03-04-2024 
    **/
    private static void validateAdditionalDeterminingFactor() {
        objFactorProgram = [
                    SELECT Id, 
                        genesis__Field_Value__c 
                    FROM genesis__Additional_Determining_Factor__c 
                    WHERE genesis__Field_Value__c = :objRateCardHeaderList[0].Name 
                    AND genesis__Rate_Card_Setup_Header__c = :objRateCardHeaderList[0].Id
                    LIMIT 1
                ];

        objFactorDealer = [
                    SELECT Id, 
                        genesis__Field_Value__c 
                    FROM genesis__Additional_Determining_Factor__c 
                    WHERE genesis__Field_Value__c = :objRateCardHeaderList[0].Account__r.Name 
                    AND genesis__Rate_Card_Setup_Header__c = :objRateCardHeaderList[0].Id 
                    LIMIT 1
                ];
        
        MyProgramUtil.nullCheckException(objFactorProgram, PortalConstants.SOMETHING_WENT_WRONG);
        MyProgramUtil.nullCheckException(objFactorDealer, PortalConstants.SOMETHING_WENT_WRONG);
    }

    /**
    * @description : Update Rate Card Details
    * @author  Pritam Roy | 03-04-2024 
    * @param myProgramHeaderId 
    * @param subTrancheString 
    * @param objRateCardsToInsert 
    * @return objRateCardsToInsert
    **/
    private static List<genesis__Rate_Card_Setup_Detail__c> updateRateCardDetails(
            String myProgramHeaderId, 
            String subTrancheString, 
            List<genesis__Rate_Card_Setup_Detail__c> objRateCardsToInsert
        ) {
        objRateCardsToInsert = processNewSubTranche(myProgramHeaderId, subTrancheString);
        // Updating the Rate Card Header Special Term Number to the next Sub Tranche Description that can be added
        if (objRateCardHeaderList[0].Special_Term_Number__c != null) {
            String currentSubTranche = String.valueOf(objRateCardHeaderList[0].Special_Term_Number__c).substringBetween(SPL_SUB_TRANCHE_STRING, ')');
            Integer charASCII = currentSubTranche.charAt(0);
            List<Integer> characterList = new List<Integer> {charASCII + 1};
            String nextChar = String.fromCharArray(characterList);
            objRateCardHeaderList[0].Special_Term_Number__c = SPL_SUB_TRANCHE_STRING + nextChar + ')';
            Database.update(objRateCardHeaderList[0], true);
        }
        
        Database.upsert(objRateCardsToInsert, true);
        return objRateCardsToInsert;
    }
    /**
    * @description :A method called to save a list a my program sub tranche
    * @author  Pritam Roy | 03-04-2024 
    * @param request 
    * @param myProgramHeaderId 
    * @param specialTermName 
    **/
    public static void saveRateCardDetails(
            Map<String, Object> request, 
            String myProgramHeaderId, 
            String specialTermName
        ) {
        //declaration specific to this method starts
       
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardsToInsert;
        clcommon.Response response = new clcommon.Response();

        validateRateCardUser(myProgramHeaderId);
        objRateCardHeaderList = getRateCardSetupHeaderList(myProgramHeaderId);

        validateAdditionalDeterminingFactor();

        setupDescription = String.valueOf(request.get(DESCRIPTION_STRING));
        assignBillingDate = Boolean.valueOf(request.get(PortalConstants.ASSIGN_BILLING_DATE)==true?true:false);
        if(!assignBillingDate){
            billingDate = null;
        }else{
            if(request.get(PortalConstants.BILLING_DATE) != null){
                billingDate = MyProgramHelper.getBillingDate(String.valueOf(request.get(PortalConstants.BILLING_DATE)));
                MyProgramValidationHelper.validateBillingDate(billingDate,objRateCardHeaderList[0].genesis__End_Date__c);
            }
        }
        objRateCardDetailList = (List<Object>) JSON.deserializeUntyped(JSON.serialize(request.get(RATE_CARD)));

        PortalValidationUtil.validateRateCardDetails(setupDescription, objRateCardDetailList);

        if (objRateCardDetailList.size() == 0) {

            if (specialTermName == MASTER_NOTERATE_A) {
                updateDefaultNoteRate();
            }
            return;
        }

        String subTrancheString = GMKSaveRateCardDetailsHandler.getSubTranche(specialTermName);

        List<AggregateResult> aggRateDescriptionList = [
                SELECT Special_Term_Reference__c description
                FROM genesis__Rate_Card_Setup_Detail__c 
                WHERE genesis__Rate_Card_Setup_Header__c = :objRateCardHeaderList[0].Id
                GROUP BY Special_Term_Reference__c
            ];

        Map<String, String> rateToDescriptionMap = getRateCardDescriptionMap(aggRateDescriptionList);
     
        Integer numberOfRates = aggRateDescriptionList.size();


        if (rateToDescriptionMap.containsKey(subTrancheString)) {
            objRateCardsToInsert = processExistingSubTranche(myProgramHeaderId, subTrancheString);
            
        }
        else if (numberOfRates <= ConstantValues.MAX_TRANCHES - 1) {
            objRateCardsToInsert = updateRateCardDetails(myProgramHeaderId, subTrancheString, objRateCardsToInsert);
        }
            
        MyProgramUtil.decimalGreaterThanCheck(Decimal.valueOf(numberOfRates),Decimal.valueOf((ConstantValues.MAX_TRANCHES - 1)),PortalConstants.MAXIMUM_SPECIAL_TERM_ERROR);

        MyProgramUtil.validateRateCardDetail(objRateCardsToInsert, objRateCardHeaderList[0].genesis__End_Date__c);
        response.status = clcommon.Constants.SUCCESS;
    }
}