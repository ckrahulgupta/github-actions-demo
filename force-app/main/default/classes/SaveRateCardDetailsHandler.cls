/**
 * @description       : Handler Class for PortalSaveRateCardDetailAPI
 * @author            : Pritam Roy
 * @group             : 
 * @last modified on  : 09-06-2024
 * @last modified by  : Sk Minsar
**/
global inherited sharing class SaveRateCardDetailsHandler {
    //declaration specific to the class starts
    private static final String HEADER_STRING = 'header';
    private static final String PROGRAM_STRING = 'program';
    private static final String DEALER_STRING = 'dealer';
    private static final String DEALER_NAME = 'dealerName';
    private static final String SUB_TRANCH_STRING = 'subTranchString';
    private static final String DESCRIPTION_STRING = 'description';
    private static final String ID_STRING = 'Id';
    private static final String NAME_STRING = 'Name';
    private static final String VARIABLE_STRING = 'Variable';
    private static final String INTEREST_RATE_TYPE = 'Interest_Rate_Type__c';
    private static final String GENESIS_INTEREST_RATE = 'genesis__Interest_Rate__c';
    private static final String SPECIAL_TERM_NUMBER = 'Special_Term_Number__c';
    //declaration specific to the class ends

    /**
    * @description : Wrapper class for Tier Participation Rate Records
    * @author Pritam Roy | 03-06-2024
    **/
    global class TierWrapper{
        //contains tier details
        global Date startDate;
        global Date endDate;
        global Decimal participationRate;
    }
    /**
    * @description : Wrapper class sent for Rate Card Creation
    * @author Pritam Roy | 03-06-2024
    **/
    global class RateCardWrapper{
        global Date startDate;
        global Date endDate;
        global Boolean foundStartDate;
        global Boolean foundEndDate;
        global Integer foundInTranch;
        global Boolean isDefaultRateCard;
        global Map<String,Object> rateCardMap;
        global Tier_Participation_Rate__mdt objTier;
        global Map<String,List<Object>> rateCardDetailInfoMap;
        global List<Tier_Participation_Rate__mdt> objTierParticipationList;
    }
     /**
    * @description : Wrapper class returned after Rate Card Creation
    * @author Pritam Roy | 03-06-2024
    **/
    global class RateCardReturnWrapper{
        global Boolean foundStartDate;
        global Boolean foundEndDate;
        global Integer foundInTranch;
        global genesis__Rate_Card_Setup_Detail__c objRateCard;
    }
    
    /**
    * @description : checks if the data is present between start date and end date
    * @author  Pritam Roy | 03-06-2024 
    * @param startDate 
    * @param endDate 
    * @param dateToCheck 
    * @return Boolean 
    **/
    private static Boolean compareDate(Date startDate,Date endDate,Date dateToCheck){
        //check if dateToCheck exists between startDate and endDate
        if(startDate <= dateToCheck && dateToCheck <= endDate){
            return true;
        }else{ 
            return false;
        }
    }
    
    /**
    * @description : CS-272: updates and creates new rate card based on crop year plan
    * @author  Pritam Roy | 03-06-2024 
    * @param objRateCardDateWrapper 
    * @param rateCardMap 
    * @param objTierParticipationList 
    * @return List<genesis__Rate_Card_Setup_Detail__c> 
    **/
    public static List<genesis__Rate_Card_Setup_Detail__c> updateRateCardDetail(PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper objRateCardDateWrapper,Map<String,Object> rateCardMap,List<Tier_Participation_Rate__mdt> objTierParticipationList){
        // declaration specific to this method starts
        System.debug('---------->'+objRateCardDateWrapper);
        System.debug('---------->'+rateCardMap);
        System.debug('---------->'+objTierParticipationList);

        List<genesis__Rate_Card_Setup_Detail__c> objRateCardsToInsert = new List<genesis__Rate_Card_Setup_Detail__c>();
        RateCardReturnWrapper objRateCardReturn = new RateCardReturnWrapper();
        Date startDate = objRateCardDateWrapper.startDate;
        Date endDate = objRateCardDateWrapper.endDate;
        Boolean defaultRateCard = objRateCardDateWrapper.defaultRateCard;
        Boolean foundStartDate = false;
        Boolean foundEndDate = false;
        Integer foundInTranch = 0;
        // declaration specific to this method ends

        //create rate card details depending upon tier chart
        for(Tier_Participation_Rate__mdt objTier : objTierParticipationList){
            RateCardWrapper objRateCardWrapper = new RateCardWrapper();
            objRateCardWrapper.startDate = startDate;
            objRateCardWrapper.endDate = endDate;
            objRateCardWrapper.objTier = objTier;
            objRateCardWrapper.rateCardMap = rateCardMap;
            objRateCardWrapper.foundStartDate = foundStartDate;
            objRateCardWrapper.foundEndDate = foundEndDate;
            objRateCardWrapper.foundInTranch = foundInTranch;
            objRateCardWrapper.isDefaultRateCard = defaultRateCard;
            objRateCardWrapper.objTierParticipationList = objTierParticipationList;
            objRateCardWrapper.rateCardDetailInfoMap = objRateCardDateWrapper.rateCardDetailInfoMap;

            System.debug('--------->'+ foundStartDate);
            System.debug('--------->'+ foundEndDate);

            if(foundStartDate &&
                    !foundEndDate){ 
                objRateCardReturn = createRateCardBeforeLastRange(objRateCardWrapper);
                objRateCardsToInsert.add(objRateCardReturn.objRateCard);
                foundEndDate = objRateCardReturn.foundEndDate;
                foundStartDate = objRateCardReturn.foundStartDate;
                foundInTranch = objRateCardReturn.foundInTranch;
                System.debug('--------->'+ foundStartDate);
                System.debug('--------->'+ foundEndDate);
                if(foundStartDate && foundEndDate){
                    continue;
                }

                
                objRateCardReturn = createRateCardWhenInRange(objRateCardWrapper);
                objRateCardsToInsert.add(objRateCardReturn.objRateCard);
                foundEndDate = objRateCardReturn.foundEndDate;
                foundStartDate = objRateCardReturn.foundStartDate;
                System.debug('--------->'+ foundStartDate);
                System.debug('--------->'+ foundEndDate);
                foundInTranch = objRateCardReturn.foundInTranch;
            }
            objRateCardReturn = createRateCardInMidRange(objRateCardWrapper);
            objRateCardsToInsert.add(objRateCardReturn.objRateCard);
            foundEndDate = objRateCardReturn.foundEndDate;
            foundStartDate = objRateCardReturn.foundStartDate;
            System.debug('--------->'+ foundStartDate);
            System.debug('--------->'+ foundEndDate);
            foundInTranch = objRateCardReturn.foundInTranch;

            objRateCardReturn = createRateCardInCurrentRange(objRateCardWrapper);
            objRateCardsToInsert.add(objRateCardReturn.objRateCard);
            foundEndDate = objRateCardReturn.foundEndDate;
            foundStartDate = objRateCardReturn.foundStartDate;
            System.debug('--------->'+ foundStartDate);
            System.debug('--------->'+ foundEndDate);
            foundInTranch = objRateCardReturn.foundInTranch;
            if(foundStartDate && foundEndDate){
                continue;
            }
        }
        objRateCardsToInsert = checkRateCardForInsert(objRateCardsToInsert);
        return objRateCardsToInsert;
    }
    
    /**
    * @description : CS-341: creates master records for all Coop types exept GROWMARK for loan commitment letter
    * @author  Pritam Roy | 03-06-2024 
    * @param objRateCardDetailWrapper 
    * @param rateCardMap 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    public static genesis__Rate_Card_Setup_Detail__c createMasterRateCardDetail(PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper objRateCardDetailWrapper,Map<String, Object> rateCardMap){
        // declaration specific to this method starts
        Map<String, List<Object>> rateCardDetailInfoMap = objRateCardDetailWrapper.rateCardDetailInfoMap;
        genesis__Rate_Card_Setup_Detail__c objRateCard = new genesis__Rate_Card_Setup_Detail__c();
        Date startDate = objRateCardDetailWrapper.startDate;
        Date endDate = objRateCardDetailWrapper.endDate;
        List<Object> objDescription = new List<Object>();
        List<Object> objSubTranch = new List<Object>();
        List<Object> objAssignBillingDate = new List<Object>();
        List<Object> objBillingDate = new List<Object>();
        String specialTermReference = '';
        String headerId = '';
        objDescription = rateCardDetailInfoMap.get(DESCRIPTION_STRING);
        objSubTranch = rateCardDetailInfoMap.get(SUB_TRANCH_STRING);
        objAssignBillingDate = rateCardDetailInfoMap.get(PortalConstants.ASSIGN_BILLING_DATE);
        objBillingDate = rateCardDetailInfoMap.get(PortalConstants.BILLING_DATE);
        // declaration specific to this method ends

        //getting rate card header details
        for(Object objRateCardHeader : rateCardDetailInfoMap.get(HEADER_STRING)){
            Map<String, Object> objRateCardHeaderMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objRateCardHeader));
            headerId = (String)objRateCardHeaderMap.get(ID_STRING);
            specialTermReference = MyProgramValidationHelper.validateStringNullCheck(objRateCardHeaderMap.get(SPECIAL_TERM_NUMBER));
        }
        objRateCard.Special_Term_Reference__c = specialTermReference;
        objRateCard.genesis__Rate_Card_Setup_Header__c = headerId;
        objRateCard.Start_Date__c = startDate;
        objRateCard.End_Date__c = endDate;
        objRateCard.Description__c = String.valueOf(objDescription[0]);
        objRateCard.genesis__Interest_Rate__c = Double.valueOf(rateCardMap.get(GENESIS_INTEREST_RATE));
        objRateCard.Interest_Rate_Type__c = String.valueOf(rateCardMap.get(INTEREST_RATE_TYPE));
        objRateCard.genesis__Pricing_Method__c = PortalConstants.INTEREST_RATE_STRING;
        objRateCard.Billing_Date__c = Date.valueOf(objBillingDate[0]);
        objRateCard.Has_Billing_Date__c = Boolean.valueOf(objAssignBillingDate[0]); 
        objRateCard.genesis__Enabled_Flag__c = false;
        return objRateCard;
    }
    
    /**
    * @description : CS-341: creates default master record for all Coop types exept GROWMARK for loan commitment letter
    * @author  Pritam Roy | 03-06-2024 
    * @param objRateCardDetailWrapper 
    * @param rateCardMap 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    public static genesis__Rate_Card_Setup_Detail__c createMasterDefaultDetail(PortalSaveRateCardDetailAPI.RateCardDetailDateWrapper objRateCardDetailWrapper, Map<String, Object> rateCardMap){
        // declaration specific to this method starts
        Map<String, List<Object>> rateCardDetailInfoMap = objRateCardDetailWrapper.rateCardDetailInfoMap;
        genesis__Rate_Card_Setup_Detail__c objDefaultNoteRate = new genesis__Rate_Card_Setup_Detail__c();
        Date startDate = objRateCardDetailWrapper.startDate;
        Date endDate = objRateCardDetailWrapper.endDate;
        List<Object> objDescription = new List<Object>();
        List<Object> objSubTranch = new List<Object>();
        Decimal advantageRate = 0;
        String headerName = '';
        String headerId = '';
        String description = '';
        // declaration specific to this method ends

        objDescription = rateCardDetailInfoMap.get(DESCRIPTION_STRING);
        objSubTranch = rateCardDetailInfoMap.get(SUB_TRANCH_STRING);
        description = MyProgramValidationHelper.checkNullList(objDescription);
        //getting rate card header details
        for(Object objRateCardHeader : rateCardDetailInfoMap.get(HEADER_STRING)){
            Map<String, Object> objRateCardHeaderMap = (Map<String, Object>)Json.deserializeUntyped(JSON.serialize(objRateCardHeader));
            headerName = (String)objRateCardHeaderMap.get(NAME_STRING);
            advantageRate = MyProgramHelper.checkAdvantageRate(objRateCardHeaderMap);
            headerId = (String)objRateCardHeaderMap.get(ID_STRING);
        }
        objDefaultNoteRate.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_A;
        objDefaultNoteRate.genesis__Rate_Card_Setup_Header__c = headerId;
        objDefaultNoteRate.Start_Date__c = startDate;
        objDefaultNoteRate.End_Date__c = endDate;
        objDefaultNoteRate.genesis__Pricing_Method__c = PortalConstants.INTEREST_RATE_STRING;
        objDefaultNoteRate.genesis__Interest_Rate__c = advantageRate;
        if(String.isBlank(description)){
            objDefaultNoteRate.Description__c = PortalConstants.NOTE_RATE;
        }else{
            objDefaultNoteRate.Description__c = String.valueOf(description);
        }
        objDefaultNoteRate.Interest_Rate_Type__c = VARIABLE_STRING;
        objDefaultNoteRate.genesis__Enabled_Flag__c = false;
        return objDefaultNoteRate;
    }

    /**
    * @description : CS-272: creating rate card by the start date and end date using the crop year plan
    * @author  Pritam Roy | 03-06-2024 
    * @param objRateCardWrapper 
    * @return RateCardReturnWrapper 
    **/
    private static RateCardReturnWrapper createRateCardBeforeLastRange(RateCardWrapper objRateCardWrapper){
        // declaration specific to this method starts
        genesis__Rate_Card_Setup_Detail__c objRateCardTranchA = new genesis__Rate_Card_Setup_Detail__c();
        Map <String,List<Object>> rateCardDetailInfoMap = objRateCardWrapper.rateCardDetailInfoMap;
        Map<String, Object> rateCardMap = objRateCardWrapper.rateCardMap;
        RateCardReturnWrapper objRateCardReturn = new RateCardReturnWrapper();
        TierWrapper objTierWrapper = new TierWrapper();
        Tier_Participation_Rate__mdt objTier = objRateCardWrapper.objTier;
        Date startDate = objRateCardWrapper.startDate;
        Date endDate = objRateCardWrapper.endDate;
        Boolean isDefaultRateCard = objRateCardWrapper.isDefaultRateCard;
        Boolean foundStartDate = objRateCardWrapper.foundStartDate;
        Boolean foundEndDate = objRateCardWrapper.foundEndDate;
        Integer foundInTranch = objRateCardWrapper.foundInTranch;
        // declaration specific to this method ends

        if(endDate <= (objTier.End_Date__c) &&
                foundInTranch!=0){
            objTierWrapper.startDate = objTier.Start_Date__c;
            objTierWrapper.endDate = endDate;
            objTierWrapper.participationRate = objTier.CFA_Participation_Rate__c;
            objRateCardTranchA = isDefaultRateCard? MyProgramHelper.createDefaultRateCardDetail(objTierWrapper,rateCardDetailInfoMap)
                                                     :MyProgramHelper.createRateCardDetail(objTierWrapper,rateCardMap,rateCardDetailInfoMap);
            foundEndDate = true;
            foundInTranch++;
        }
        objRateCardReturn.foundEndDate = foundEndDate;
        objRateCardReturn.foundStartDate = foundStartDate;
        objRateCardReturn.foundInTranch = foundInTranch;
        objRateCardReturn.objRateCard = objRateCardTranchA;
        return objRateCardReturn;
    }
    
    /**
    * @description : CS-272: creating rate card by the start date and end date using the crop year plan
    * @author  Pritam Roy | 03-06-2024 
    * @param objRateCardWrapper 
    * @return RateCardReturnWrapper 
    **/
    private static RateCardReturnWrapper createRateCardWhenInRange(RateCardWrapper objRateCardWrapper){
        // declaration specific to this method starts
        genesis__Rate_Card_Setup_Detail__c objRateCardTranchB = new genesis__Rate_Card_Setup_Detail__c();
        Map <String,List<Object>> rateCardDetailInfoMap = objRateCardWrapper.rateCardDetailInfoMap;
        Map<String, Object> rateCardMap = objRateCardWrapper.rateCardMap;
        RateCardReturnWrapper objRateCardReturn = new RateCardReturnWrapper();
        TierWrapper objTierWrapper = new TierWrapper();
        Tier_Participation_Rate__mdt objTier = objRateCardWrapper.objTier;
        Date startDate = objRateCardWrapper.startDate;
        Date endDate = objRateCardWrapper.endDate;
        Boolean isDefaultRateCard = objRateCardWrapper.isDefaultRateCard;
        Boolean foundStartDate = objRateCardWrapper.foundStartDate;
        Boolean foundEndDate = objRateCardWrapper.foundEndDate;
        Integer foundInTranch = objRateCardWrapper.foundInTranch;
        // declaration specific to this method ends

        if(endDate >= (objTier.End_Date__c) &&
                foundInTranch!=0){
            objTierWrapper.startDate = objTier.Start_Date__c;
            objTierWrapper.endDate = objTier.End_Date__c;
            objTierWrapper.participationRate = objTier.CFA_Participation_Rate__c;
            objRateCardTranchB = isDefaultRateCard? MyProgramHelper.createDefaultRateCardDetail(objTierWrapper,rateCardDetailInfoMap)
                                                        :MyProgramHelper.createRateCardDetail(objTierWrapper,rateCardMap,rateCardDetailInfoMap);
            foundInTranch++;
        }
        objRateCardReturn.foundEndDate = foundEndDate;
        objRateCardReturn.foundStartDate = foundStartDate;
        objRateCardReturn.foundInTranch = foundInTranch;
        objRateCardReturn.objRateCard = objRateCardTranchB;
        return objRateCardReturn;
    }
    
    /**
    * @description : CS-272: creating rate card by the start date and end date using the crop year plan
    * @author  Pritam Roy | 03-06-2024 
    * @param objRateCardWrapper 
    * @return RateCardReturnWrapper 
    **/
    private static RateCardReturnWrapper createRateCardInMidRange(RateCardWrapper objRateCardWrapper){
        // declaration specific to this method starts
        genesis__Rate_Card_Setup_Detail__c objRateCardTranchC = new genesis__Rate_Card_Setup_Detail__c();
        List<Tier_Participation_Rate__mdt> objTierParticipationList = objRateCardWrapper.objTierParticipationList;
        Map <String,List<Object>> rateCardDetailInfoMap = objRateCardWrapper.rateCardDetailInfoMap;
        Map<String, Object> rateCardMap = objRateCardWrapper.rateCardMap;
        RateCardReturnWrapper objRateCardReturn = new RateCardReturnWrapper();
        TierWrapper objTierWrapper = new TierWrapper();
        Tier_Participation_Rate__mdt objTier = objRateCardWrapper.objTier;
        Date startDate = objRateCardWrapper.startDate;
        Date endDate = objRateCardWrapper.endDate;
        Boolean isDefaultRateCard = objRateCardWrapper.isDefaultRateCard;
        Boolean foundStartDate = objRateCardWrapper.foundStartDate;
        Boolean foundEndDate = objRateCardWrapper.foundEndDate;
        Integer foundInTranch = objRateCardWrapper.foundInTranch;
        // declaration specific to this method ends

        if(foundStartDate &&
                !foundEndDate &&
                compareDate(objTier.Start_Date__c,objTier.End_Date__c,endDate) &&
                foundInTranch == (objTierParticipationList.size()-1)){
            objTierWrapper.startDate = objTier.Start_Date__c;
            objTierWrapper.endDate = endDate;
            objTierWrapper.participationRate = objTier.CFA_Participation_Rate__c;
            objRateCardTranchC = isDefaultRateCard? MyProgramHelper.createDefaultRateCardDetail(objTierWrapper,rateCardDetailInfoMap)
                                                        : MyProgramHelper.createRateCardDetail(objTierWrapper,rateCardMap,rateCardDetailInfoMap);
            foundEndDate = true;
        }
        objRateCardReturn.foundEndDate = foundEndDate;
        objRateCardReturn.foundStartDate = foundStartDate;
        objRateCardReturn.foundInTranch = foundInTranch;
        objRateCardReturn.objRateCard = objRateCardTranchC;
        return objRateCardReturn;
    }
    
    /**
    * @description : CS-272: creating rate card by the start date and end date using the crop year plan
    * @author  Pritam Roy | 03-06-2024 
    * @param objRateCardWrapper 
    * @return RateCardReturnWrapper 
    **/
    private static RateCardReturnWrapper createRateCardInCurrentRange(RateCardWrapper objRateCardWrapper){
        // declaration specific to this method starts
        genesis__Rate_Card_Setup_Detail__c objRateCardTranchD = new genesis__Rate_Card_Setup_Detail__c();
        Map <String,List<Object>> rateCardDetailInfoMap = objRateCardWrapper.rateCardDetailInfoMap;
        Map<String, Object> rateCardMap = objRateCardWrapper.rateCardMap;
        Tier_Participation_Rate__mdt objTier = objRateCardWrapper.objTier;
        RateCardReturnWrapper objRateCardReturn = new RateCardReturnWrapper();
        TierWrapper objTierWrapper = new TierWrapper();
        Boolean isDefaultRateCard = objRateCardWrapper.isDefaultRateCard;
        Date startDate = objRateCardWrapper.startDate;
        Date endDate = objRateCardWrapper.endDate;
        Boolean foundStartDate = objRateCardWrapper.foundStartDate;
        Boolean foundEndDate = objRateCardWrapper.foundEndDate;
        Integer foundInTranch = objRateCardWrapper.foundInTranch;
        // declaration specific to this method ends

        if(!foundStartDate &&
                compareDate(objTier.Start_Date__c,objTier.End_Date__c, startDate)){
            if(!foundEndDate &&
                    compareDate(objTier.Start_Date__c,objTier.End_Date__c, endDate)){
                objTierWrapper.startDate = startDate;
                objTierWrapper.endDate = endDate;
                objTierWrapper.participationRate = objTier.CFA_Participation_Rate__c;
                objRateCardTranchD = isDefaultRateCard? MyProgramHelper.createDefaultRateCardDetail(objTierWrapper,rateCardDetailInfoMap)
                                                        :MyProgramHelper.createRateCardDetail(objTierWrapper,rateCardMap,rateCardDetailInfoMap);
                foundStartDate = true;
                foundEndDate = true;
            }else{
                objTierWrapper.startDate = startDate;
                objTierWrapper.endDate = objTier.End_Date__c;
                objTierWrapper.participationRate = objTier.CFA_Participation_Rate__c;
                objRateCardTranchD = isDefaultRateCard? MyProgramHelper.createDefaultRateCardDetail(objTierWrapper,rateCardDetailInfoMap)
                                                            :MyProgramHelper.createRateCardDetail(objTierWrapper,rateCardMap,rateCardDetailInfoMap);
                foundstartDate = true;
                foundInTranch++;
            }
        }
        objRateCardReturn.foundEndDate = foundEndDate;
        objRateCardReturn.foundStartDate = foundStartDate;
        objRateCardReturn.foundInTranch = foundInTranch;
        objRateCardReturn.objRateCard = objRateCardTranchD;
        return objRateCardReturn;
    }
    
    /**
    * @description : segregates the rate cards that are valid and returns
    * @author  Pritam Roy | 03-06-2024 
    * @param objRateCardList 
    * @return List<genesis__Rate_Card_Setup_Detail__c> 
    **/
    private static  List<genesis__Rate_Card_Setup_Detail__c> checkRateCardForInsert(List<genesis__Rate_Card_Setup_Detail__c> objRateCardList){
        List<genesis__Rate_Card_Setup_Detail__c> rateCardList = new list<genesis__Rate_Card_Setup_Detail__c>();
        for(genesis__Rate_Card_Setup_Detail__c objRateCard : objRateCardList){
            if(objRateCard.Description__c != null){
                rateCardList.add(objRateCard);
            }
        }
        return rateCardList;
    }
}