/**
 * @description       : Purpose of this class is to create Special Sub - Tranches of My Program
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 30-03-2023
 * @last modified by  : Subham Nandi
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   08-02-2022   Subham Nandi   Initial Version
**/
global without sharing class PortalSaveRateCardDetailsAPI{
    // Constant parameters specific for this class starts
    private static final String RATE_CARD = 'interest';
    private static final String PROGRAM_ID = 'programId';
    private static final String SETUP_DETAIL_DESCRIPTION = 'specialInterestDescription';
    private static final String DESCRIPTION_STRING = 'description';
    private static final String SPL_SUB_TRANCHE_STRING = 'Special Term Sub-Tranche (';
    private static final String SPECIAL_TERM_C = 'Special Term Sub-Tranche (C)';
    private static final String SPECIAL_TERM_D = 'Special Term Sub-Tranche (D)';
    private static final String SPECIAL_TERM_E = 'Special Term Sub-Tranche (E)';
    private static final String MASTER_NOTERATE_A = 'NoteRate';
    private static final String SUB_TRANCHE_B = 'SpecialTermB';
    private static final String SUB_TRANCHE_C = 'SpecialTermC';
    private static final String SUB_TRANCHE_D = 'SpecialTermD';
    private static final String SUB_TRANCHE_E = 'SpecialTermE';
    // Constant parameters specific for this class ends

    /**
    * @description A method called to save a list a my program sub tranche
    * @author Subham Nandi | 28-06-2022 
    * @param argumentsFromPortal 
    * @param myProgramHeaderId 
    **/
    global static void saveRateCardDetails(Map<String, Object> argumentsFromPortal, String myProgramHeaderId, String specialTermName) {
        //declaration specific to this method starts
        SavePoint dbSavePoint = Database.setSavepoint();
        List<Object> objRateCardDetailList = new List<Object>();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardsToInsert = new List<genesis__Rate_Card_Setup_Detail__c>();
        genesis__Additional_Determining_Factor__c objAdditionalFactorProgram = new genesis__Additional_Determining_Factor__c();
        genesis__Additional_Determining_Factor__c objAdditionalFactorForDealer = new genesis__Additional_Determining_Factor__c();
        Map<String, Object> rateCardMap = new Map<String, Object>();
        Integer numberOfRates;
        Date endDatePrevious;
        Integer count;
        map<String,String> rateToDescriptionMap = new Map<String,String>();
        Integer numberOfRatePerSubTranche = 0;
        //declaration specific to this method ends
        // Declarations specific to this class starts
        String rateCard = '';
        clcommon.Response response = new clcommon.Response();
        //String myProgramHeaderId = '';
        String setupDescription = '';
        // Declarations specific to this class ends
        //getting the program Id
        //myProgramHeaderId = String.valueOf(argumentsFromPortal.get(PROGRAM_ID));
        //Validating whether the user can access the My Program
        List<User> objLoggedInUserList =  [ SELECT  Id,
                                                    ContactId,
                                                    Contact.AccountId,
                                                    Contact.Account.ParentId //gives dealer account id
                                            FROM USER
                                            WHERE Id = :UserInfo.getUserId()];
        if(objLoggedInUserList.size() > 0 &&
            objLoggedInUserList[0].Contact.Account.ParentId != null){
                //Validate user
                Boolean isMyProgram = PortalSecurityUtil.validateRateCardDetailByDealer(objLoggedInUserList[0].Contact.Account.ParentId, myProgramHeaderId);
                if(!isMyProgram){
                    throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
                }
        }
        else{
            //invalid user
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        }
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList = [ SELECT   Id,
                                                                                    Name,
                                                                                    Account__r.Name,
                                                                                    CFA_Advantage_Rate__c,
                                                                                    genesis__End_Date__c,
                                                                                    Special_Term_Number__c
                                                                            FROM genesis__Rate_Card_Setup_Header__c
                                                                            WHERE Id = :myProgramHeaderId ];
        if(objRateCardHeaderList.size() == 0 || objRateCardHeaderList == null){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        if(objRateCardHeaderList[0].Name == null ||
            objRateCardHeaderList[0].Account__r.Name == null ||
            objRateCardHeaderList[0].CFA_Advantage_Rate__c == null ||
            objRateCardHeaderList[0].genesis__End_Date__c == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        objAdditionalFactorProgram =   [SELECT  Id, 
                                                genesis__Field_Value__c 
                                        FROM genesis__Additional_Determining_Factor__c 
                                        WHERE genesis__Field_Value__c = :objRateCardHeaderList[0].Name AND genesis__Rate_Card_Setup_Header__c = :objRateCardHeaderList[0].Id
                                        LIMIT 1];
        objAdditionalFactorForDealer = [SELECT  Id, 
                                                genesis__Field_Value__c 
                                        FROM genesis__Additional_Determining_Factor__c 
                                        WHERE genesis__Field_Value__c = :objRateCardHeaderList[0].Account__r.Name AND genesis__Rate_Card_Setup_Header__c = :objRateCardHeaderList[0].Id 
                                        LIMIT 1];
        if(objAdditionalFactorProgram == null || objAdditionalFactorForDealer == null){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }                                
        //getting the description for which the rate card setup detail is created
        setupDescription = String.valueOf(argumentsFromPortal.get(DESCRIPTION_STRING));
        objRateCardDetailList = (List<Object>) Json.deserializeUntyped(Json.serialize(argumentsFromPortal.get(RATE_CARD)));
        if(String.isBlank(setupDescription) &&
            objRateCardDetailList.size() > 0){
                throw new CustomException(PortalConstants.DESCRIPTION_ERROR);
        }
        if( objRateCardDetailList.size() == 0){
            if(specialTermName == MASTER_NOTERATE_A){
                //Create a default note rate for the My Program
                genesis__Rate_Card_Setup_Detail__c objDefaultNoteRate = new genesis__Rate_Card_Setup_Detail__c();
                objDefaultNoteRate.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_A;
                objDefaultNoteRate.genesis__Use_Additional_Determining_Factors__c = true;
                objDefaultNoteRate.genesis__Determining_Factor_Key_Value__c = String.valueOf(objAdditionalFactorProgram.Id)+':'
                                                                                            +objRateCardHeaderList[0].Name+'#'
                                                                                            +String.valueOf(objAdditionalFactorForDealer.Id)+':'
                                                                                            +objRateCardHeaderList[0].Account__r.Name;
                objDefaultNoteRate.genesis__Pricing_Method__c = PortalConstants.INTEREST_RATE_STRING;
                objDefaultNoteRate.genesis__Rate_Card_Setup_Header__c = objRateCardHeaderList[0].Id;
                objDefaultNoteRate.Start_Date__c = System.today();
                objDefaultNoteRate.End_Date__c = objRateCardHeaderList[0].genesis__End_Date__c;
                objDefaultNoteRate.Participation_Percentage_Dealer_Subsidy__c = 0;
                objDefaultNoteRate.Participation_Percentage_CFA__c = 0;
                objDefaultNoteRate.Participation_Percentage_Dealer__c = 0;
                objDefaultNoteRate.genesis__Interest_Rate__c = objRateCardHeaderList[0].CFA_Advantage_Rate__c;
                objDefaultNoteRate.Special_Term_Order__c = 1;
                if(String.isBlank(setupDescription)){
                    objDefaultNoteRate.Description__c = PortalConstants.NOTE_RATE;
                }
                else{
                    objDefaultNoteRate.Description__c = setupDescription;
                }
                objDefaultNoteRate.Interest_Rate_Type__c = 'Variable';
                Database.Insert(objDefaultNoteRate,true);
                objRateCardHeaderList[0].Special_Term_Number__c = PortalConstants.SPECIAL_TERM_B;
                Database.Update(objRateCardHeaderList[0]);
            }
            return;
        }
        numberOfRatePerSubTranche = objRateCardDetailList.size();
        //Check for 3 rate cards for each sub tranche
        if(objRateCardDetailList.size() > PortalConstants.MAXIMUM_SPECIAL_TRANCHES_NUMBER){
            throw new CustomException(PortalConstants.MAXIMUM_SPL_TRANCHES);
        }
        //Instantiating a string to check for the Special Term Name
        String subTrancheString;
        if(specialTermName == MASTER_NOTERATE_A){
            subTrancheString = PortalConstants.SPECIAL_TERM_A;
        }
        else if(specialTermName == SUB_TRANCHE_B){
            subTrancheString = PortalConstants.SPECIAL_TERM_B;
        }
        else if(specialTermName == SUB_TRANCHE_C){
            subTrancheString = SPECIAL_TERM_C;
        }
        else if(specialTermName == SUB_TRANCHE_D){
            subTrancheString = SPECIAL_TERM_D;
        }
        else if(specialTermName == SUB_TRANCHE_E){
            subTrancheString = SPECIAL_TERM_E;
        }
        //get the distinct description of the rates under the my program
        List<AggregateResult> aggregateRatesDescriptionList =  [SELECT Special_Term_Reference__c description
                                                                FROM genesis__Rate_Card_Setup_Detail__c 
                                                                WHERE genesis__Rate_Card_Setup_Header__c = :objRateCardHeaderList[0].Id
                                                                GROUP BY Special_Term_Reference__c 
                                                                ];
        // if(aggregateRatesDescriptionList.size() == 0){
        //     throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        // }                                            
        for(AggregateResult eachRate : aggregateRatesDescriptionList){
            if((String)eachRate.get(DESCRIPTION_STRING) != null){
                rateToDescriptionMap.put((String)eachRate.get(DESCRIPTION_STRING),DESCRIPTION_STRING);
            }
        }
        numberOfRates = aggregateRatesDescriptionList.size();
        count =0;
        if(rateToDescriptionMap.containsKey(subTrancheString)){
            for(Object rateCardObj : objRateCardDetailList){
                rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(rateCardObj));
                genesis__Rate_Card_Setup_Detail__c objRateCardDetailIndividual = new genesis__Rate_Card_Setup_Detail__c();
                objRateCardDetailIndividual = PortalHelper.getRateCardDetails(rateCardMap, setupDescription);
                    objRateCardDetailIndividual.Special_Term_Reference__c = subTrancheString;
                objRateCardDetailIndividual.genesis__Use_Additional_Determining_Factors__c = true;
                objRateCardDetailIndividual.genesis__Determining_Factor_Key_Value__c = String.valueOf(objAdditionalFactorProgram.Id)+':'
                                                                                            +objRateCardHeaderList[0].Name+'#'
                                                                                            +String.valueOf(objAdditionalFactorForDealer.Id)+':'
                                                                                            +objRateCardHeaderList[0].Account__r.Name;
                objRateCardDetailIndividual.genesis__Pricing_Method__c = PortalConstants.INTEREST_RATE_STRING;
                if(objRateCardDetailIndividual.Id == null){
                    objRateCardDetailIndividual.genesis__Rate_Card_Setup_Header__c = myProgramHeaderId;
                }
                //start date must be equual to the previous end date + 1 for the rates excluding first rate
                if(count  > 0 ){
                    //for the rate cards excluding the first one
                    if(objRateCardDetailIndividual.Start_Date__c != endDatePrevious.addDays(1)){
                        throw new CustomException(PortalConstants.START_DATE_CHECK);
                    }
                }
                //validating that the last date doesnt pass the maturity date
                if(objRateCardDetailIndividual.End_Date__c > objRateCardHeaderList[0].genesis__End_Date__c ){
                    //if end date of the rate card goes beyond the Maturity Date
                    throw new CustomException(PortalConstants.LAST_DATE_PASSED_MATURITY+': '+objRateCardHeaderList[0].genesis__End_Date__c.format());
                }
                else{
                    //If the rate card end date is within the maturity date
                    //Getting the last day of the month
                    Integer lastDay = Date.daysInMonth(objRateCardDetailIndividual.End_Date__c.Year(), objRateCardDetailIndividual.End_Date__c.Month());
                    If(count < numberOfRatePerSubTranche - 1){ 
                        //For the rates excluding the last rate
                        if(objRateCardDetailIndividual.End_Date__c.Day() != lastDay){
                            ////if the end date is not on the last day of the month
                            throw new CustomException(PortalConstants.LAST_DATE_VALIDATION);
                        }
                        else{
                            //// if it is the last day of the month then check whether the month is not the prior month of maturity
                            if((objRateCardDetailIndividual.End_Date__c.Month() == objRateCardHeaderList[0].genesis__End_Date__c.Month() - 1) &&
                                    (objRateCardDetailIndividual.End_Date__c.Year() == objRateCardHeaderList[0].genesis__End_Date__c.Year())){
                                    throw new CustomException(PortalConstants.PRIOR_MONTH_CHECK);
                                }
                        }
                    }
                    else{
                        //enters for the last added rate of a sub tranche
                        ////check whether maturity date equals the end date
                        if(objRateCardDetailIndividual.End_Date__c != objRateCardHeaderList[0].genesis__End_Date__c){
                            throw new CustomException(PortalConstants.LAST_END_DATE_CHECK_MATURITY+objRateCardHeaderList[0].genesis__End_Date__c.format());
                        }
                    }
                }
                //for the rates excluding the last date store the end date temporarily
                If(count < numberOfRatePerSubTranche - 1){ 
                    //for rates excluding the last date
                    endDatePrevious = objRateCardDetailIndividual.End_Date__c;
                }
                
                //CALCULATION BASED ON GROWER RATE ---------------------------------------------------------------------------------------------
                //CALCULATION
                if(objRateCardDetailIndividual.genesis__Interest_Rate__c == null){
                    throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
                }
                //validation for Grower Rate and CFA Participation Rate calculations
                if(objRateCardDetailIndividual.genesis__Interest_Rate__c > objRateCardHeaderList[0].CFA_Advantage_Rate__c){
                    //Dealer Premium is chosen
                    objRateCardDetailIndividual.Participation_Percentage_Dealer_Subsidy__c = 0;
                    objRateCardDetailIndividual.Participation_Percentage_CFA__c = 0;
                    objRateCardDetailIndividual.Participation_Percentage_Dealer__c = objRateCardDetailIndividual.genesis__Interest_Rate__c
                                                                                    - objRateCardHeaderList[0].CFA_Advantage_Rate__c;
                }
                else if(objRateCardDetailIndividual.genesis__Interest_Rate__c < objRateCardHeaderList[0].CFA_Advantage_Rate__c){
                    //Dealer subsidy is chosen
                    objRateCardDetailIndividual.Participation_Percentage_Dealer__c = 0; //premium = 0
                    objRateCardDetailIndividual.Participation_Percentage_Dealer_Subsidy__c = objRateCardHeaderList[0].CFA_Advantage_Rate__c 
                                                                                            - objRateCardDetailIndividual.genesis__Interest_Rate__c;
                    if(objRateCardDetailIndividual.Participation_Percentage_Dealer_Subsidy__c/2 > PortalConstants.MAXIMUM_CFA_PARTICIPATION){
                        objRateCardDetailIndividual.Participation_Percentage_CFA__c = 1.5;
                    }                                                                        
                    else{
                        //make CFA Participation equal to dealer subsidy
                        objRateCardDetailIndividual.Participation_Percentage_CFA__c = objRateCardDetailIndividual.Participation_Percentage_Dealer_Subsidy__c/2;
                    }
                    objRateCardDetailIndividual.Participation_Percentage_Dealer_Subsidy__c = objRateCardHeaderList[0].CFA_Advantage_Rate__c 
                                                                                            - objRateCardDetailIndividual.genesis__Interest_Rate__c
                                                                                            - objRateCardDetailIndividual.Participation_Percentage_CFA__c;
                }
                else{
                    objRateCardDetailIndividual.Participation_Percentage_Dealer_Subsidy__c = 0;
                    objRateCardDetailIndividual.Participation_Percentage_CFA__c = 0;
                    objRateCardDetailIndividual.Participation_Percentage_Dealer__c = 0;
                }
                //CALCULATION BASED ON GROWER RATE ---------------------------------------------------------------------------------------------


                objRateCardsToInsert.add(objRateCardDetailIndividual); 
                count++;
            }
            Database.upsert(objRateCardsToInsert,false);
            response.status = clcommon.Constants.SUCCESS;
        }
        else{
            //Adding a new special interest rate
            if(numberOfRates <= 4){
                for(Object rateCardObj : objRateCardDetailList){
                    rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(rateCardObj));
                    genesis__Rate_Card_Setup_Detail__c objRateCardDetailIndividual = new genesis__Rate_Card_Setup_Detail__c();
                    objRateCardDetailIndividual = PortalHelper.getRateCardDetails(rateCardMap, setupDescription);
                    if(objRateCardHeaderList[0].Special_Term_Number__c != null){
                        objRateCardDetailIndividual.Special_Term_Reference__c = objRateCardHeaderList[0].Special_Term_Number__c;
                    }
                    
                    objRateCardDetailIndividual.genesis__Use_Additional_Determining_Factors__c = true;
                    objRateCardDetailIndividual.genesis__Determining_Factor_Key_Value__c = String.valueOf(objAdditionalFactorProgram.Id)+':'
                                                                                                +objRateCardHeaderList[0].Name+'#'
                                                                                                +String.valueOf(objAdditionalFactorForDealer.Id)+':'
                                                                                                +objRateCardHeaderList[0].Account__r.Name;
                    objRateCardDetailIndividual.genesis__Pricing_Method__c = PortalConstants.INTEREST_RATE_STRING;
                    if(objRateCardDetailIndividual.Id == null){
                        objRateCardDetailIndividual.genesis__Rate_Card_Setup_Header__c = myProgramHeaderId;
                    }
                    //start date must be equual to the previous end date + 1 for the rates excluding first rate
                    if(count  > 0 ){
                        //for the rate cards excluding the first one
                        if(objRateCardDetailIndividual.Start_Date__c != endDatePrevious.addDays(1)){
                            throw new CustomException(PortalConstants.START_DATE_CHECK);
                        }
                    }
                    //validating that the last date doesnt pass the maturity date
                    if(objRateCardDetailIndividual.End_Date__c > objRateCardHeaderList[0].genesis__End_Date__c ){
                        //if end date of the rate card goes beyond the Maturity Date
                        throw new CustomException(PortalConstants.LAST_DATE_PASSED_MATURITY+' :'+ objRateCardHeaderList[0].genesis__End_Date__c.format());
                    }
                    else{
                        //If the rate card end date is within the maturity date
                        //Getting the last day of the month
                        Integer lastDay = Date.daysInMonth(objRateCardDetailIndividual.End_Date__c.Year(), objRateCardDetailIndividual.End_Date__c.Month());
                        If(count < numberOfRatePerSubTranche - 1){ 
                            //For the rates excluding the last rate
                            if(objRateCardDetailIndividual.End_Date__c.Day() != lastDay){
                                ////if the end date is not on the last day of the month
                                throw new CustomException(PortalConstants.LAST_DATE_VALIDATION);
                            }
                            else{
                                //// if it is the last day of the month then check whether the month is not the prior month of maturity
                                if((objRateCardDetailIndividual.End_Date__c.Month() == objRateCardHeaderList[0].genesis__End_Date__c.Month() - 1) &&
                                    (objRateCardDetailIndividual.End_Date__c.Year() == objRateCardHeaderList[0].genesis__End_Date__c.Year())){
                                    throw new CustomException(PortalConstants.PRIOR_MONTH_CHECK);
                                }
                            }
                        }
                        else{
                            //enters for the last added rate of a sub tranche
                            ////check whether maturity date equals the end date
                            if(objRateCardDetailIndividual.End_Date__c != objRateCardHeaderList[0].genesis__End_Date__c){
                                throw new CustomException(PortalConstants.LAST_END_DATE_CHECK_MATURITY+objRateCardHeaderList[0].genesis__End_Date__c.format());
                            }
                        }
                    }
                    //for the rates excluding the last date store the end date temporarily
                    If(count < numberOfRatePerSubTranche - 1){ 
                        //for rates excluding the last date
                        endDatePrevious = objRateCardDetailIndividual.End_Date__c;
                    }
                    //CALCULATION BASED ON GROWER RATE ---------------------------------------------------------------------------------------------
                    //CALCULATION
                    if(objRateCardDetailIndividual.genesis__Interest_Rate__c == null){
                        throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
                    }
                    //validation for Grower Rate and CFA Participation Rate calculations
                    if(objRateCardDetailIndividual.genesis__Interest_Rate__c > objRateCardHeaderList[0].CFA_Advantage_Rate__c){
                        //Dealer Premium is chosen
                        objRateCardDetailIndividual.Participation_Percentage_Dealer_Subsidy__c = 0;
                        objRateCardDetailIndividual.Participation_Percentage_CFA__c = 0;
                        objRateCardDetailIndividual.Participation_Percentage_Dealer__c = objRateCardDetailIndividual.genesis__Interest_Rate__c
                                                                                        - objRateCardHeaderList[0].CFA_Advantage_Rate__c;
                    }
                    else if(objRateCardDetailIndividual.genesis__Interest_Rate__c < objRateCardHeaderList[0].CFA_Advantage_Rate__c){
                        //Dealer subsidy is chosen
                        objRateCardDetailIndividual.Participation_Percentage_Dealer__c = 0; //premium = 0
                        objRateCardDetailIndividual.Participation_Percentage_Dealer_Subsidy__c = objRateCardHeaderList[0].CFA_Advantage_Rate__c 
                                                                                                - objRateCardDetailIndividual.genesis__Interest_Rate__c;
                        if(objRateCardDetailIndividual.Participation_Percentage_Dealer_Subsidy__c / 2 > PortalConstants.MAXIMUM_CFA_PARTICIPATION){
                            objRateCardDetailIndividual.Participation_Percentage_CFA__c = 1.5;
                        }                                                                        
                        else{
                            //make CFA Participation equal to dealer subsidy
                            objRateCardDetailIndividual.Participation_Percentage_CFA__c = objRateCardDetailIndividual.Participation_Percentage_Dealer_Subsidy__c / 2;
                        }
                        objRateCardDetailIndividual.Participation_Percentage_Dealer_Subsidy__c = objRateCardHeaderList[0].CFA_Advantage_Rate__c 
                                                                                                - objRateCardDetailIndividual.genesis__Interest_Rate__c
                                                                                                    - objRateCardDetailIndividual.Participation_Percentage_CFA__c;
                    }
                    else{
                        objRateCardDetailIndividual.Participation_Percentage_Dealer_Subsidy__c = 0;
                        objRateCardDetailIndividual.Participation_Percentage_CFA__c = 0;
                        objRateCardDetailIndividual.Participation_Percentage_Dealer__c = 0;
                    }
                    //CALCULATION BASED ON GROWER RATE ---------------------------------------------------------------------------------------------
                    // updating the Special Term order
                    objRateCardDetailIndividual.Special_Term_Order__c = count+1;
                    objRateCardsToInsert.add(objRateCardDetailIndividual); 
                    count++;
                }
                // Updating the Rate Card Header Special Term Number to the next Sub Tranche Description that can be added
                if(objRateCardHeaderList[0].Special_Term_Number__c != null){
                    String currentSubTranche = String.valueOf(objRateCardHeaderList[0].Special_Term_Number__c).substringBetween(SPL_SUB_TRANCHE_STRING,')');
                    Integer charASCII = currentSubTranche.charAt(0);
                    List<Integer> characterList = new List<Integer>{charASCII+1};
                    String nextChar = String.fromCharArray(characterList);
                    objRateCardHeaderList[0].Special_Term_Number__c = SPL_SUB_TRANCHE_STRING + nextChar + ')';
                    Database.update(objRateCardHeaderList[0],true);
                }
                
                Database.upsert(objRateCardsToInsert,false);
                response.status = clcommon.Constants.SUCCESS;
            }
            else{
                throw new CustomException(PortalConstants.MAXIMUM_SPECIAL_TERM_ERROR);
            }
        }
    }
}