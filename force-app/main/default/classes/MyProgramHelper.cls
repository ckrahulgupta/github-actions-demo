/**
 * @description       : Helper class for MyProgram
 * @author            : Pritam Roy
 * @group             : 
 * @last modified on  : 10-24-2024
 * @last modified by  : Ayush Kumar Singh
**/
global inherited sharing class MyProgramHelper{
    // Constant parameters specific for this class starts
    private static final String LOAN_STRING = 'Loan';
    private static final String OBJECT_RATE = 'genesis__Rate_Card_Setup_Header__c';
    private static final String HEADER_STRING = 'header';
    private static final String PROGRAM_STRING = 'program';
    private static final String DEALER_STRING = 'dealer';
    private static final String DEALER_NAME = 'dealerName';
    private static final String SUB_TRANCH_STRING = 'subTranchString';
    private static final String DESCRIPTION_STRING = 'description';
    private static final String ID_STRING = 'Id';
    private static final String CFA_ADVANTAGE_RATE_STRING = 'CFA_Advantage_Rate__c';
    private static final String NAME_STRING = 'Name';
    private static final String VARIABLE_STRING = 'Variable';
    private static final String INTEREST_RATE_TYPE = 'Interest_Rate_Type__c';
    private static final String PARTICIPATION_PERCENTAGE_DEALER = 'Participation_Percentage_Dealer__c';
    private static final String PARTICIPATION_PERCENTAGE_SUBSIDY = 'Participation_Percentage_Dealer_Subsidy__c';
    private static final String GENESIS_INTEREST_RATE = 'genesis__Interest_Rate__c';
    private static final String NEW_ID_STRING = 'id';
    private static final String FIELD_FINANCE_RATE = 'Field_Finance_Rate__c';
    private static final String CROP_YEAR = 'Crop_Year__c';
    private static final Integer NEW_RATE_CROP_YEAR = 2024;
    private static final String SPECIAL_TERM_NUMBER = 'Special_Term_Number__c';
    // Constant parameters specific for this class ends


    /**
    * @description Fetching Dealer Account
    * @author Ayan Bhowmik | 02-22-2024 
    * @return List<User> 
    **/
    public static List<User> getDealerAccount(){
        List<User> getDealerAccountList = [SELECT  Id,
                                                    ContactId,
                                                    Contact.AccountId,
                                                    Contact.Account.ParentId,
                                                    Contact.Account.Parent.Name,
                                                    Contact.Account.Parent.Tier__c 
                                            FROM USER 
                                            WHERE Id = :UserInfo.getUserId()];
        return getDealerAccountList;                                   
    }

    /**
    * @description Fetching Rate Card Header RecordType
    * @author Ayan Bhowmik | 02-22-2024 
    * @return RecordType 
    **/
    public static RecordType getHeaderRecordType(){
        RecordType objHeaderRecordType = [SELECT Id 
                                            FROM RecordType 
                                            WHERE   Name = :LOAN_STRING AND 
                                                    SobjectType = :OBJECT_RATE 
                                            LIMIT 1];
        return objHeaderRecordType;                                    
    }

    /**
    * @description Fetching application by id
    * @author Ayan Bhowmik | 02-22-2024 
    * @param applicationId 
    * @return genesis__Applications__c 
    **/
    public static genesis__Applications__c getApplicationById(String applicationId){
        if(applicationId!=null){
            List<genesis__Applications__c> objApplicationList = [SELECT Id,
                                                                    Name,
                                                                    genesis__Account__r.Name, 
                                                                    CreatedDate,
                                                                    Dealer_Name__c
                                                            FROM genesis__Applications__c
                                                            WHERE Id = :applicationId];
            return objApplicationList[0];                                         
        }
        return null;
    }

    /**
    * @description validate start date of every tranch should match
    * @author Ayan Bhowmik | 02-22-2024 
    * @param objRateCardHeader 
    **/
    public static void validateStartDateEverySubTranche(genesis__Rate_Card_Setup_Header__c objRateCardHeader){
        List<genesis__Rate_Card_Setup_Detail__c> rateCardList = new List<genesis__Rate_Card_Setup_Detail__c>();
        Integer countForStartDateChange = 0;
        Date startDate;
        String specialTermReference = '';
        rateCardList = [SELECT Id,
                                Name,
                                Start_Date__c,
                                Special_Term_Reference__c,
                                genesis__Rate_Card_Setup_Header__r.Id
                            FROM genesis__Rate_Card_Setup_Detail__c
                            WHERE genesis__Rate_Card_Setup_Header__r.Id =: objRateCardHeader.Id
                            ORDER BY Special_Term_Reference__c]; 
        System.debug(rateCardList);
        for(genesis__Rate_Card_Setup_Detail__c objRateCard : rateCardList){
            if(specialTermReference != objRateCard.Special_Term_Reference__c){
                specialTermReference = objRateCard.Special_Term_Reference__c;
                if(startDate!=objRateCard.Start_Date__c){
                    startDate = objRateCard.Start_Date__c;
                    countForStartDateChange++;
                }
            }
        }
        if(countForStartDateChange>1){
            throw new CustomException(PortalConstants.CHECK_START_DATE_OF_EVERY_TRANCH);
        }                                                            
    }

    /**
    * @description validate loan fee advanced on
    * @author Ayan Bhowmik | 02-22-2024 
    * @param objRateCardHeader 
    **/
    public static void validateLoanFeeAdvancedOn(genesis__Rate_Card_Setup_Header__c objRateCardHeader){
        List<genesis__Rate_Card_Setup_Detail__c> rateCardList = new List<genesis__Rate_Card_Setup_Detail__c>();
        Integer loanFeeAdvancedOnCount = 0;
        String loanFeeAdvancedOn = '';
        rateCardList = [SELECT Id,
                                Name,
                                Special_Term_Reference__c,
                                genesis__Rate_Card_Setup_Header__r.Payer_of_Loan_Closing_Fee__c
                            FROM genesis__Rate_Card_Setup_Detail__c
                            WHERE genesis__Rate_Card_Setup_Header__r.Id =: objRateCardHeader.Id
                            AND genesis__Rate_Card_Setup_Header__r.Payer_of_Loan_Closing_Fee__c =: PortalConstants.GROWER_PROFILE];
        if(rateCardList.size()>0){                                                         
            loanFeeAdvancedOn = String.valueOf(objRateCardHeader.Loan_Fee_Advanced_On__c);//''                                                        
            for(genesis__Rate_Card_Setup_Detail__c objRateCard : rateCardList){
                if(((String)objRateCard.Special_Term_Reference__c).contains(loanFeeAdvancedOn)){
                    loanFeeAdvancedOnCount++;
                }
            }
            if(loanFeeAdvancedOnCount==0 ){
                throw new CustomException(PortalConstants.LOAN_FEE_ADVANCED_ON);
            }
        }
    }
                                        
    /**
    * @description create rate card
    * @author Ayan Bhowmik | 02-22-2024 
    * @param objTierWrapper 
    * @param rateCardMap 
    * @param rateCardDetailInfoMap 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    public static genesis__Rate_Card_Setup_Detail__c createRateCardDetail(SaveRateCardDetailsHandler.TierWrapper objTierWrapper,Map<String,Object> rateCardMap, Map<String,List<Object>> rateCardDetailInfoMap){ 
        //method specific declaration starts
        genesis__Rate_Card_Setup_Detail__c objRateCardIndividual = new genesis__Rate_Card_Setup_Detail__c();
        List<Object> objDescription = new List<Object>();
        List<Object> dealerName = new List<Object>();
        List<Object> objSubTranch = new List<Object>();
        List<Object> objAssignBillingDate = new List<Object>();
        List<Object> objBillingDate = new List<Object>();
        Date startDate = objTierWrapper.startDate;
        Date endDate = objTierWrapper.endDate;
        Decimal participationRate = objTierWrapper.participationRate;
        String determiningFactor = '';
        String headerName = '';
        Decimal advantageRate;
        String dealerId = '';
        String programId = '';
        String headerId = '';
        String specialTermReference = '';
        Decimal interestCalculationCheck = 0;
        //method specific declaration ends

        objDescription = rateCardDetailInfoMap.get(DESCRIPTION_STRING);
        objSubTranch = rateCardDetailInfoMap.get(SUB_TRANCH_STRING);
        dealerName = rateCardDetailInfoMap.get(DEALER_NAME);
        objAssignBillingDate = rateCardDetailInfoMap.get(PortalConstants.ASSIGN_BILLING_DATE);
        objBillingDate = rateCardDetailInfoMap.get(PortalConstants.BILLING_DATE);
        objRateCardIndividual = getNewRateCardDetails(rateCardMap, String.valueOf(objDescription[0]));
        objRateCardIndividual.Start_Date__c = startDate;
        objRateCardIndividual.End_Date__c = endDate;
        objRateCardIndividual.Participation_Percentage_CFA__c = participationRate;
        objRateCardIndividual.genesis__Use_Additional_Determining_Factors__c = true;
        objRateCardIndividual.Billing_Date__c = Date.valueOf(objBillingDate[0]);
        objRateCardIndividual.Has_Billing_Date__c = Boolean.valueOf(objAssignBillingDate[0]); 
        //getting header details
        for(Object objRateCardHeader : rateCardDetailInfoMap.get(HEADER_STRING)){
            Map<String, Object> objRateCardHeaderMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objRateCardHeader));
            headerName = (String)objRateCardHeaderMap.get(NAME_STRING);
            advantageRate = checkAdvantageRate(objRateCardHeaderMap);
            headerId = (String)objRateCardHeaderMap.get(ID_STRING);
            specialTermReference = MyProgramValidationHelper.validateStringNullCheck(objRateCardHeaderMap.get(SPECIAL_TERM_NUMBER));
        }
        //getting additional program details
        for(Object objProgram : rateCardDetailInfoMap.get(PROGRAM_STRING)){
            Map<String, Object> objProgramMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objProgram));
            programId = (String)objProgramMap.get(ID_STRING);
        }
        // getting additional program dealer details
        for(Object objDealer : rateCardDetailInfoMap.get(DEALER_STRING)){
            Map<String, Object> objDealerMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objDealer));
            dealerId = (String)objDealerMap.get(ID_STRING);
        }
        determiningFactor = programId+':'+headerName+'#'+dealerId+':'+String.valueOf(dealerName[0]);
        objRateCardIndividual.Special_Term_Reference__c = specialTermReference;  
        objRateCardIndividual.genesis__Determining_Factor_Key_Value__c = determiningFactor;
        objRateCardIndividual.genesis__Pricing_Method__c = PortalConstants.INTEREST_RATE_STRING;
        if(objRateCardIndividual.Id == null){
            objRateCardIndividual.genesis__Rate_Card_Setup_Header__c = headerId;
        }
        //CALCULATION BASED ON GROWER RATE ---------------------------------------------------------------------------------------------
        //CALCULATION
        MyProgramUtil.nullCheckException(objRateCardIndividual.genesis__Interest_Rate__c,PortalConstants.REQUIRED_PARAMETERS_MISSING);
        //validation for Grower Rate and CFA Participation Rate calculations
        interestCalculationCheck  = objRateCardIndividual.genesis__Interest_Rate__c + participationRate - advantageRate;
        if(interestCalculationCheck < 0){
            objRateCardIndividual.Participation_Percentage_Dealer__c = 0;
            objRateCardIndividual.Participation_Percentage_CFA__c = participationRate;
            objRateCardIndividual.Participation_Percentage_Dealer_Subsidy__c = Math.abs(interestCalculationCheck);
        }else if(interestCalculationCheck > 0){
            objRateCardIndividual.Participation_Percentage_Dealer__c = interestCalculationCheck;
            objRateCardIndividual.Participation_Percentage_CFA__c = participationRate;
            objRateCardIndividual.Participation_Percentage_Dealer_Subsidy__c = 0;
        }else{
            objRateCardIndividual.Participation_Percentage_Dealer__c = 0;
            objRateCardIndividual.Participation_Percentage_CFA__c = participationRate;
            objRateCardIndividual.Participation_Percentage_Dealer_Subsidy__c = 0;
        }
        return objRateCardIndividual;
    }

    /**
    * @description create default rate card
    * @author Ayan Bhowmik | 02-22-2024 
    * @param objTierWrapper 
    * @param rateCardDetailInfoMap 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    public static genesis__Rate_Card_Setup_Detail__c createDefaultRateCardDetail(SaveRateCardDetailsHandler.TierWrapper objTierWrapper,Map<String,List<Object>> rateCardDetailInfoMap){
        //method specific declaration starts
        genesis__Rate_Card_Setup_Detail__c objDefaultNoteRate = new genesis__Rate_Card_Setup_Detail__c();
        List<Object> objDescription = new List<Object>();
        List<Object> dealerName = new List<Object>();
        Date startDate = objTierWrapper.startDate;
        Date endDate = objTierWrapper.endDate;
        Decimal participationRate = objTierWrapper.participationRate;
        String headerName = '';
        Decimal advantageRate;
        String dealerId = '';
        String programId = '';
        String headerId = '';
        String determiningFactor = '';
        String description;
        Decimal interestCalculationCheck = 0;
        //method specific declaration ends

        objDescription = rateCardDetailInfoMap.get(DESCRIPTION_STRING);
        dealerName = rateCardDetailInfoMap.get(DEALER_NAME);
        if(objDescription!=null){
            description = String.valueOf(objDescription[0]);
        }
        objDefaultNoteRate.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_A;
        objDefaultNoteRate.genesis__Use_Additional_Determining_Factors__c = true;
        //getting rate card header details
        for(Object objRateCardHeader : rateCardDetailInfoMap.get(HEADER_STRING)){
            Map<String, Object> objRateCardHeaderMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objRateCardHeader));
            headerName = (String)objRateCardHeaderMap.get(NAME_STRING);
            advantageRate = checkAdvantageRate(objRateCardHeaderMap);
            headerId = (String)objRateCardHeaderMap.get(ID_STRING);
        }
        //getting additional information for program
        for(Object objProgram : rateCardDetailInfoMap.get(PROGRAM_STRING)){
            Map<String, Object> objProgramMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objProgram));
            programId = (String)objProgramMap.get(ID_STRING);
        }
        //getting additional information for dealer
        for(Object objDealer : rateCardDetailInfoMap.get(DEALER_STRING)){
            Map<String, Object> objDealerMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objDealer));
            dealerId = (String)objDealerMap.get(ID_STRING);
        }
        determiningFactor = programId+':'+headerName+'#'+dealerId+':'+String.valueOf(dealerName[0]);
        objDefaultNoteRate.genesis__Determining_Factor_Key_Value__c = determiningFactor;
        objDefaultNoteRate.genesis__Pricing_Method__c = PortalConstants.INTEREST_RATE_STRING;
        objDefaultNoteRate.genesis__Rate_Card_Setup_Header__c = headerId;
        objDefaultNoteRate.Start_Date__c = startDate;
        objDefaultNoteRate.End_Date__c = endDate;
        objDefaultNoteRate.genesis__Interest_Rate__c = advantageRate;
        objDefaultNoteRate.Participation_Percentage_Dealer__c = 0;
        interestCalculationCheck  =  participationRate;
        //Calculation based on Field Finance Rate
        if(interestCalculationCheck<0){
            objDefaultNoteRate.Participation_Percentage_Dealer__c = 0;
            objDefaultNoteRate.Participation_Percentage_CFA__c = participationRate;
            objDefaultNoteRate.Participation_Percentage_Dealer_Subsidy__c = Math.abs(interestCalculationCheck);
        }else if(interestCalculationCheck>0){
            objDefaultNoteRate.Participation_Percentage_Dealer__c = interestCalculationCheck;
            objDefaultNoteRate.Participation_Percentage_CFA__c = participationRate;
            objDefaultNoteRate.Participation_Percentage_Dealer_Subsidy__c = 0;
        }else{
            objDefaultNoteRate.Participation_Percentage_Dealer__c = 0;
            objDefaultNoteRate.Participation_Percentage_CFA__c = participationRate;
            objDefaultNoteRate.Participation_Percentage_Dealer_Subsidy__c = 0;
        }
        objDefaultNoteRate.Special_Term_Order__c = 1;
        if(String.isBlank(description)){
            objDefaultNoteRate.Description__c = PortalConstants.NOTE_RATE;
        }
        else{
            objDefaultNoteRate.Description__c = String.valueOf(description);
        }
        objDefaultNoteRate.Interest_Rate_Type__c = VARIABLE_STRING;
        return objDefaultNoteRate;
    }

    /**
    * @description get rate card details
    * @author Ayan Bhowmik | 02-22-2024 
    * @param mapOfRateCards 
    * @param rateDetailDescription 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    private static genesis__Rate_Card_Setup_Detail__c getNewRateCardDetails(Map<String, Object> mapOfRateCards, String rateDetailDescription){
        genesis__Rate_Card_Setup_Detail__c objRateCard = new genesis__Rate_Card_Setup_Detail__c();
        String id = (String) mapOfRateCards.get(NEW_ID_STRING);
        if(id == null){
            objRateCard.Id = null;
        }
        objRateCard.Description__c = rateDetailDescription;
        objRateCard.Interest_Rate_Type__c = String.valueOf(mapOfRateCards.get(INTEREST_RATE_TYPE));
        objRateCard.Participation_Percentage_Dealer__c = Double.valueOf(mapOfRateCards.get(PARTICIPATION_PERCENTAGE_DEALER));
        objRateCard.Participation_Percentage_Dealer_Subsidy__c = Double.valueOf(mapOfRateCards.get(PARTICIPATION_PERCENTAGE_SUBSIDY));
        objRateCard.genesis__Interest_Rate__c = Double.valueOf(mapOfRateCards.get(GENESIS_INTEREST_RATE));
        return objRateCard;
    }

    /**
    * @description check advantage rate
    * @author Ayan Bhowmik | 02-22-2024 
    * @param objRateCardHeaderMap 
    * @return Decimal 
    **/
    public static Decimal checkAdvantageRate(Map<String, Object> objRateCardHeaderMap) {    
        if (Integer.valueOf(objRateCardHeaderMap.get(CROP_YEAR)) < NEW_RATE_CROP_YEAR) {
            return (Decimal) objRateCardHeaderMap.get(CFA_ADVANTAGE_RATE_STRING);
        } else {
            Id accountId = (String)objRateCardHeaderMap.get('Account__c');
            BaseRateService.BaseRateInfo baseRateInfo = BaseRateService.fetchAndCacheBaseRate(accountId);
            
            if (baseRateInfo != null && baseRateInfo.floatingRateIndex != null) {
                return baseRateInfo.floatingRateIndex.Current_Floating_Rate__c;
            } else {
                return 0;
            }
        }
    }
     /**
    * @description : Get Billing Date
    * @author  Pritam Roy | 07-24-2024 
    * @param dateString 
    * @return Date 
    **/
    public static Date getBillingDate(String dateString){
        if(String.isBlank(dateString) || dateString == null){
            return null;
        }
        dateString = dateString.replace(PortalConstants.HYPHEN_STRING,PortalConstants.COMMA_STRING);
        List<String> dateComponents = dateString.split(PortalConstants.COMMA_STRING);
        Integer year = Integer.valueOf(dateComponents[0]);
        Integer month = Integer.valueOf(dateComponents[1]);
        Integer day = Integer.valueOf(dateComponents[2]);
        return Date.newInstance(year, month, day);
    }
}