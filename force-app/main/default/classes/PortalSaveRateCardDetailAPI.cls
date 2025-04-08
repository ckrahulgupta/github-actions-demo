/**
 * @description       : Save My Program Details
 * @author            : Pritam Roy
 * @group             : 
 * @last modified on  : 07-29-2024
 * @last modified by  :  Pritam Roy
**/
global inherited sharing class PortalSaveRateCardDetailAPI{ 
    // Constant parameters specific for this class starts
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
    private static final String DESCRIPTION_STRING = 'description';
    private static final Integer MAXIMUM_SPECIAL_TRANCHES_NUMBER = 5;
    private static final String HEADER_STRING = 'header';
    private static final String PROGRAM_STRING = 'program';
    private static final String DEALER_STRING = 'dealer';
    private static final String DETAIL_STRING = 'detail';
    private static final String DEALER_NAME = 'dealerName';
    private static final String RATE_CARD = 'interest';
    private static final String SUB_TRANCH_STRING = 'subTranchString';
    private static final String START_DATE = 'Start_Date__c';
    private static final String END_DATE = 'End_Date__c';
    // Constant parameters specific for this class ends

    /**
    * @description : Wrapper class contains Rate Card Details
    * @author  Pritam Roy | 03-06-2024
    **/
    global class RateCardDetailDateWrapper{
        //contains start date - end date details
        global Date startDate;
        global Date endDate;
        global Boolean defaultRateCard;
        global Map<String, List<Object>> rateCardDetailInfoMap;
    }
    /**
    * @description : Wrapper class with additional information of Rate Card
    * @author  Pritam Roy | 03-06-2024
    **/
    global class UseRateCardWrapper{
        //store rate card details
        global String subTranchString;
        global Map<String, List<Object>> rateCardDetailInfoMap;
        global List<Tier_Participation_Rate__mdt> objTierParticipationList;
        global Integer numberOfRates;
        global String specialTermNumber;
        global List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList;
        //global String cropYearDate;
    }
    /**
    * @description A method called to save a list a my program sub tranche
    * @author Pritam Roy | 31-08-2023
    * @param argumentsFromPortal 
    * @param myProgramHeaderId 
    * @param specialTermName
    **/
    global static void saveRateCardDetails(Map<String, Object> argumentsFromPortal, String myProgramHeaderId, String specialTermName) {
        // declaration specific to this method starts
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<genesis__Rate_Card_Setup_Detail__c> masterRateCardList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<genesis__Additional_Determining_Factor__c> objProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objDealerList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList  = new List<genesis__Rate_Card_Setup_Header__c>();
        List<Tier_Participation_Rate__mdt> objTierParticipationList = new List<Tier_Participation_Rate__mdt>();
        genesis__Additional_Determining_Factor__c objFactorProgram = new genesis__Additional_Determining_Factor__c();
        genesis__Additional_Determining_Factor__c obFactorForDealer = new genesis__Additional_Determining_Factor__c();
        Map<String, List<Object>> rateCardDetailInfoMap = new Map<String,List<Object>>();
        Map<String,String> rateToDescriptionMap = new Map<String,String>();
        Map<String, Object> rateCardMap = new Map<String, Object>();
        List<Object> objRateCardDetailList = new List<Object>();
        List<String> descriptionList = new List<String>();
        List<String> subTranchList = new List<String>();
        List<String> objDealerNameList = new List<String>();
        List<User> objLoggedInUserList = new List<User>();
        clcommon.Response response = new clcommon.Response();
        RateCardDetailDateWrapper objRateCardWrapper;
        UseRateCardWrapper objUseRateCardWrapper;
        String setupDescription = '';
        String subTrancheString = '';
        Date billingDate;
        Boolean assignBillingDate = false;
        String tierName = ''; 
        Integer numberOfRates = 0;
        Date startDate;
        Date endDate;
        // declaration specific to this method ends

        objLoggedInUserList =  MyProgramHelper.getDealerAccount();
        //Validate Logged In User with Rate Card Header Id                                 
        MyProgramValidationUtil.validateLoggedInUser(objLoggedInUserList,myProgramHeaderId);
        objRateCardHeaderList = [ SELECT   Id,
                                            Name,
                                            Account__r.Name,
                                            CFA_Advantage_Rate__c,
                                            Field_Finance_Rate__c,
                                            genesis__End_Date__c,
                                            Special_Term_Number__c,
                                            Crop_Year__c
                                    FROM genesis__Rate_Card_Setup_Header__c
                                    WHERE Id =: myProgramHeaderId ];                                                  
        //Validate Rate Card Header                                                                   
        MyProgramValidationUtil.validateRateCardHeader(objRateCardHeaderList);
        objDealerNameList.add(objRateCardHeaderList[0].Account__r.Name);
        tierName = objLoggedInUserList[0].Contact.Account.Parent.Tier__c;

        //Getting CFA Participation Rate recods
        objTierParticipationList = [SELECT Id,
                                            Label,
                                            DeveloperName,
                                            Start_Date__c,
                                            End_Date__c,
                                            CFA_Participation_Rate__c,
                                            Crop_Year__c
                                    FROM Tier_Participation_Rate__mdt
                                    WHERE Label =: tierName
                                    AND Crop_Year__c =: objRateCardHeaderList[0].Crop_Year__c
                                    ORDER BY Start_Date__c ];                                                                                   
        objFactorProgram =   [SELECT  Id, 
                                        genesis__Field_Value__c 
                                FROM genesis__Additional_Determining_Factor__c 
                                WHERE genesis__Field_Value__c = :objRateCardHeaderList[0].Name AND genesis__Rate_Card_Setup_Header__c = :objRateCardHeaderList[0].Id
                                LIMIT 1];
        obFactorForDealer = [SELECT  Id, 
                                        genesis__Field_Value__c 
                                FROM genesis__Additional_Determining_Factor__c 
                                WHERE genesis__Field_Value__c = :objRateCardHeaderList[0].Account__r.Name AND genesis__Rate_Card_Setup_Header__c = :objRateCardHeaderList[0].Id 
                                LIMIT 1];
        //Check if both additional factor is present or not                                
        MyProgramValidationUtil.validateTierAndAdditionalFactor(objFactorProgram,obFactorForDealer,objTierParticipationList);

        //getting the description for which the rate card setup detail is created
        setupDescription = String.valueOf(argumentsFromPortal.get(DESCRIPTION_STRING));
        billingDate = MyProgramHelper.getBillingDate(String.valueOf(argumentsFromPortal.get(PortalConstants.BILLING_DATE)));
        //Validate Billing Date
        if(String.isNotBlank(String.valueOf(billingDate))){
         MyProgramValidationHelper.validateBillingDate(billingDate, objRateCardHeaderList[0].genesis__End_Date__c);
        }
        assignBillingDate = Boolean.valueOf(argumentsFromPortal.get(PortalConstants.ASSIGN_BILLING_DATE)==true?true:false);
        objRateCardDetailList = (List<Object>) Json.deserializeUntyped(Json.serialize(argumentsFromPortal.get(RATE_CARD)));
        MyProgramValidationHelper.checkDescription(setupDescription, objRateCardDetailList);

        List<Date> billingDateList = new List<Date>();
        List<Boolean> assignBillingDateList = new List<Boolean>();

        //populating rate card detials
        rateCardDetailInfoMap.put(HEADER_STRING,objRateCardHeaderList);
        objProgramList.add(objFactorProgram);
        rateCardDetailInfoMap.put(PROGRAM_STRING,objProgramList);
        objDealerList.add(obFactorForDealer);
        rateCardDetailInfoMap.put(DEALER_STRING, objDealerList); 
        rateCardDetailInfoMap.put(DETAIL_STRING,objRateCardDetailList);
        rateCardDetailInfoMap.put(DEALER_NAME,objDealerNameList);
        descriptionList.add(setupDescription);
        rateCardDetailInfoMap.put(DESCRIPTION_STRING,descriptionList);
        assignBillingDateList.add(assignBillingDate);
        rateCardDetailInfoMap.put(PortalConstants.ASSIGN_BILLING_DATE,assignBillingDateList);
        billingDateList.add(billingDate);
        rateCardDetailInfoMap.put(PortalConstants.BILLING_DATE,billingDateList);

        //check for Default Note Rate
        if(objRateCardDetailList.size() == 0){
            if(specialTermName == MASTER_NOTERATE_A){
                startDate = System.today();
                endDate = objRateCardHeaderList[0].genesis__End_Date__c;
                objRateCardWrapper = new RateCardDetailDateWrapper();
                objRateCardWrapper.startDate = startDate;
                objRateCardWrapper.endDate = endDate;
                objRateCardWrapper.defaultRateCard = true;
                objRateCardWrapper.rateCardDetailInfoMap = rateCardDetailInfoMap;
                //creating rate card records
                masterRateCardList.add(SaveRateCardDetailsHandler.createMasterDefaultDetail(objRateCardWrapper,rateCardMap));
                rateCardDetailList = SaveRateCardDetailsHandler.updateRateCardDetail(objRateCardWrapper,rateCardMap,objTierParticipationList);
                rateCardDetailList = updateSpecialTermOrder(rateCardDetailList);
                rateCardDetailList.addAll(masterRateCardList);
                Database.insert(rateCardDetailList,true);
                objRateCardHeaderList[0].Special_Term_Number__c = PortalConstants.SPECIAL_TERM_B;
                Database.update(objRateCardHeaderList[0],true);
            }
            return;
        }
        //Check for 3 rate cards for each sub tranche
        if(objRateCardDetailList.size() > MAXIMUM_SPECIAL_TRANCHES_NUMBER){
            throw new CustomException(PortalConstants.MAXIMUM_SPL_TRANCHES);
        }

        //get the distinct description of the rates under the my program
        List<AggregateResult> aggregateRateList =  [SELECT Special_Term_Reference__c description
                                                                FROM genesis__Rate_Card_Setup_Detail__c 
                                                                WHERE genesis__Rate_Card_Setup_Header__c = :objRateCardHeaderList[0].Id
                                                                GROUP BY Special_Term_Reference__c 
                                                                ];                                     
        for(AggregateResult eachRate : aggregateRateList){
            if((String)eachRate.get(DESCRIPTION_STRING) != null){
                rateToDescriptionMap.put((String)eachRate.get(DESCRIPTION_STRING),DESCRIPTION_STRING);
            }
        }
        numberOfRates = aggregateRateList.size();
        subTrancheString = getSubTranche(specialTermName);
        subTranchList.add(subTrancheString);
        rateCardDetailInfoMap.put(SUB_TRANCH_STRING,subTranchList);
        objUseRateCardWrapper = new UseRateCardWrapper();
        objUseRateCardWrapper.numberOfRates = numberOfRates;
        objUseRateCardWrapper.subTranchString = subTrancheString;
        objUseRateCardWrapper.objTierParticipationList = objTierParticipationList;
        objUseRateCardWrapper.rateCardDetailInfoMap = rateCardDetailInfoMap;
        objUseRateCardWrapper.objRateCardHeaderList = objRateCardHeaderList;
        response = checkForRateCardDetail(objUseRateCardWrapper,rateToDescriptionMap,objRateCardDetailList);
    }
    
    /**
    * @description : create and update rate card detail
    * @author  Pritam Roy | 03-06-2024 
    * @param objUseRateCardWrapper 
    * @param rateToDescriptionMap 
    * @param objRateCardDetailList 
    * @return clcommon.Response 
    **/
    private static clcommon.Response checkForRateCardDetail(UseRateCardWrapper objUseRateCardWrapper,Map<String,String> rateToDescriptionMap,List<Object> objRateCardDetailList){
        // declaration specific to this method starts
        List<genesis__Rate_Card_Setup_Detail__c> rateCardsToInsertList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<genesis__Rate_Card_Setup_Detail__c> masterRateCardList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<genesis__Rate_Card_Setup_Detail__c> deleteRateCardList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<Tier_Participation_Rate__mdt> objTierParticipationList = objUseRateCardWrapper.objTierParticipationList;
        List<genesis__Rate_Card_Setup_Header__c> objRateCardHeaderList = objUseRateCardWrapper.objRateCardHeaderList;
        Map<String, List<Object>> rateCardDetailInfoMap = objUseRateCardWrapper.rateCardDetailInfoMap;
        String subTrancheString = objUseRateCardWrapper.subTranchString;
        Integer numberOfRates = objUseRateCardWrapper.numberOfRates;
        Map<String, Object> rateCardMap = new Map<String, Object>();
        clcommon.Response response = new clcommon.Response();
        RateCardDetailDateWrapper objRateCardWrapper;
        String currentSubTranche = '';
        Integer charASCII = 0;
        String getStartDate = '';
        String getEndDate = '';
        String nextChar = '';
        Date startDate;
        Date endDate;
        // declaration specific to this method ends
        
        //CS-272: Rate Card Updation
        if(rateToDescriptionMap.containsKey(subTrancheString)){ 
            for(Object rateCardObj : objRateCardDetailList){
                rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(rateCardObj));
                getStartDate = (String)rateCardMap.get(START_DATE);
                getEndDate = (String)rateCardMap.get(END_DATE);
                startDate = Date.valueOf(getStartDate);//start date
                endDate = Date.valueOf(getEndDate);//end date
                objRateCardWrapper = new RateCardDetailDateWrapper();
                objRateCardWrapper.startDate = startDate;
                objRateCardWrapper.endDate = endDate;
                objRateCardWrapper.defaultRateCard = false;
                objRateCardWrapper.rateCardDetailInfoMap = rateCardDetailInfoMap;
                rateCardsToInsertList.addAll(SaveRateCardDetailsHandler.updateRateCardDetail(objRateCardWrapper,rateCardMap,objTierParticipationList));
                masterRateCardList.add(SaveRateCardDetailsHandler.createMasterRateCardDetail(objRateCardWrapper,rateCardMap));
            }
            //delete previous special interest rate and insert new special rate to avoid duplicates
            deleteRateCardList = [SELECT Id,
                                         Name,
                                         Special_Term_Reference__c,
                                         genesis__Rate_Card_Setup_Header__r.Id
                                     FROM genesis__Rate_Card_Setup_Detail__c
                                     WHERE genesis__Rate_Card_Setup_Header__r.Id =: objRateCardHeaderList[0].Id];                          
            Database.delete(deleteRateCardList,true);
            rateCardsToInsertList = updateSpecialTermOrder(rateCardsToInsertList);
            MyProgramUtil.validateRateCardDetail(masterRateCardList,objRateCardHeaderList[0].genesis__End_Date__c);
            rateCardsToInsertList.addAll(masterRateCardList);
            Database.insert(rateCardsToInsertList,true);
            response.status = clcommon.Constants.SUCCESS;
        }
        else{
            //CS-272: Rate Card Creation
            if(numberOfRates <= 7){
                for(Object rateCardObj : objRateCardDetailList){
                    rateCardMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(rateCardObj));
                    getStartDate = (String)rateCardMap.get(START_DATE);
                    getEndDate = (String)rateCardMap.get(END_DATE);
                    startDate = Date.valueOf(getStartDate);//start date
                    endDate = Date.valueOf(getEndDate);//end date
                    objRateCardWrapper = new RateCardDetailDateWrapper();
                    objRateCardWrapper.startDate = startDate;
                    objRateCardWrapper.endDate = endDate;
                    objRateCardWrapper.defaultRateCard = false;
                    objRateCardWrapper.rateCardDetailInfoMap = rateCardDetailInfoMap;
                    rateCardsToInsertList.addAll(SaveRateCardDetailsHandler.updateRateCardDetail(objRateCardWrapper,rateCardMap,objTierParticipationList));
                    masterRateCardList.add(SaveRateCardDetailsHandler.createMasterRateCardDetail(objRateCardWrapper,rateCardMap));
                }
                rateCardsToInsertList = updateSpecialTermOrder(rateCardsToInsertList);
                MyProgramUtil.validateRateCardDetail(masterRateCardList,objRateCardHeaderList[0].genesis__End_Date__c);
                rateCardsToInsertList.addAll(masterRateCardList);
                Database.insert(rateCardsToInsertList,true);
                response.status = clcommon.Constants.SUCCESS;
            }
            else{
                throw new CustomException(PortalConstants.MAXIMUM_SPECIAL_TERM_ERROR);
            }
        }
        // Updating the Rate Card Header Special Term Number to the next Sub Tranche Description that can be added
        if(objRateCardHeaderList[0].Special_Term_Number__c != null){
            currentSubTranche = String.valueOf(objRateCardHeaderList[0].Special_Term_Number__c).substringBetween(SPL_SUB_TRANCHE_STRING,')');
            charASCII = currentSubTranche.charAt(0);
            List<Integer> characterList = new List<Integer>{charASCII+1};
            nextChar = String.fromCharArray(characterList);
            objRateCardHeaderList[0].Special_Term_Number__c = SPL_SUB_TRANCHE_STRING + nextChar + ')';
            Database.update(objRateCardHeaderList[0],true);
        }
        return response;
    }
    
    /**
    * @description : get sub tranche name
    * @author  Pritam Roy | 03-06-2024 
    * @param specialTermName 
    * @return String 
    **/
    private static String getSubTranche(String specialTermName){
        String subTrancheString = '';
        //get special term name
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
        else if(specialTermName == SUB_TRANCHE_F){
            subTrancheString = SPECIAL_TERM_F;
        }
        else if(specialTermName == SUB_TRANCHE_G){
            subTrancheString = SPECIAL_TERM_G;
        }
        else if(specialTermName == SUB_TRANCHE_H){
            subTrancheString = SPECIAL_TERM_H;
        }
        return subTrancheString;
    }
    
    /**
    * @description : CS-272: update special term order for all rate cards generated by crop year plan
    * @author  Pritam Roy | 03-06-2024 
    * @param objRateCardDetailList 
    * @return List<genesis__Rate_Card_Setup_Detail__c> 
    **/
    private static List<genesis__Rate_Card_Setup_Detail__c> updateSpecialTermOrder(List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList){
        List<genesis__Rate_Card_Setup_Detail__c> objUpdatedRateCardList = new List<genesis__Rate_Card_Setup_Detail__c>();
        Integer countOrder = 0;
        for(genesis__Rate_Card_Setup_Detail__c objRateCardDetail : objRateCardDetailList){
            objRateCardDetail.Special_Term_Order__c = ++countOrder;
            objUpdatedRateCardList.add(objRateCardDetail);
        }
        return objUpdatedRateCardList;
    }
}