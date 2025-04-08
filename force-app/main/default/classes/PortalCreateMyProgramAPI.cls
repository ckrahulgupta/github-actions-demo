/**
 * @description       : Create My Program and Flex Rate
 * @author            : Pritam Roy
 * @group             : 
 * @last modified on  : 07-30-2024
 * @last modified by  :  Pritam Roy
**/
global without sharing class PortalCreateMyProgramAPI implements clcommon.PortalCustomRemoteAPI1 {

    // Constant parameters specific for this class starts
    private static final String PROGRAM = 'program';
    private static final String FIELD_CROP_YEAR = 'Crop_Year__c';
    private static final String FIELD_NAME = 'Name';
    private static final String FIELD_MATURITY_DATE = 'genesis__End_Date__c';
    private static final String FIELD_PAYER = 'Payer_of_Loan_Closing_Fee__c';
    private static final String FIELD_ADVANCEON = 'Loan_Fee_Advanced_On__c';
    private static final String FIELD_DEALER_PART = 'Dealer_Participate_on_Closing_Fee__c';
    private static final String FIELD_FEE_PORTION = 'Portion_of_Fee_to_Cover__c';
    private static final String FIELD_ID = 'Id';
    private static final String NEW_RECORD_STRING = 'new_record_id';
    private static final String LOAN_STRING = 'Loan';
    private static final String MASTER_NOTERATE_A = 'NoteRate';
    private static final String FLEX_PROGRAM = 'flexRateProgram';
    private static final String MY_PROGRAM_ID = 'myProgramId';
    private static final String RATE_PRICING = 'ratePricing';
    private static final String HASH = '#';
    private static final String COLON = ':';
    // Constant parameters specific for this class ends

    // Class specific declarations
    List<clcommon.PortalCustomRemoteActionRecord> responseDataList = new List<clcommon.PortalCustomRemoteActionRecord>();
    Map<String, Object> fieldsMap = new Map<String, Object>();
    clcommon.Response response = new clcommon.Response();
    Integer cropYearToValidate;
    String myProgram = '';
    String myProgramId = '';
    String cropYear = '';
    String noteRateString = '';
    String specialTrancheB = '';
    String specialTrancheC = '';
    String specialTrancheD = '';
    String specialTrancheE = '';
    String specialTrancheF = '';
    String specialTrancheG = '';
    String specialTrancheH = '';
    // Class specific declarations

    /**
    * @description This method populates certain required fields for rate card header and saves the My Program
    * @author Pritam Roy | 31-08-2023 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                        String[] disclosureNames,
                                        Map<String, Object> argumentsFromPortal) {
        // declaration specific to this method starts

        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        Map<String,Object> noteRateAMap = new Map<String,Object>();
        Map<String,Object> subTrancheBMap = new Map<String,Object>();
        Map<String,Object> subTrancheCMap = new Map<String,Object>();
        Map<String,Object> subTrancheDMap =  new Map<String,Object>();
        Map<String,Object> subTrancheEMap = new Map<String,Object>();
        Map<String,Object> subTrancheFMap = new Map<String,Object>();
        Map<String,Object> subTrancheGMap = new Map<String,Object>();
        Map<String,Object> subTrancheHMap = new Map<String,Object>();
        String myProgramId = '';                                    
        // declaration specific to this method ends

        SavePoint dbSavePoint = Database.setSavepoint();
        try {
            objRateCardHeader = validateArgumentsFromPortal(argumentsFromPortal);
            myProgramId = (String) objRateCardHeader.get(FIELD_ID);
            cropYear = (String)objRateCardHeader.get(FIELD_CROP_YEAR);
            cropYearToValidate = Integer.valueOf(cropYear);
            //fetching dealer Account
            List<User> objdealerAccountName =  MyProgramHelper.getDealerAccount();
            //checks for new my program and makes the id null
            if(myProgramId == null || myProgramId == NEW_RECORD_STRING){
                objRateCardHeader.Id = null;
            }else{
                objRateCardHeader.Id = myProgramId;
            }
            //------------------Crop Year Validation----------------------
            MyProgramValidationUtil.validateCropYear(cropYearToValidate);
            //------------------Rate Card Header Validation---------------
            objRateCardHeader = MyProgramValidationUtil.validateMyProgramRateCardHeader(objRateCardHeader,cropYearToValidate);
            RecordType objRecordType = MyProgramHelper.getHeaderRecordType();
            //The fields that are required to create a desired My Program are populated
            objRateCardHeader = populateRateCardHeader(objRateCardHeader,objdealerAccountName,objRecordType);
            //My Program is getting updated
            if(objRateCardHeader.Id != null){
                checkForUpdatedMyProgram(objRateCardHeader,objdealerAccountName);
            }
            // New My Program is added
            if(objRateCardHeader.Id == null){
                //Populate the Special term Number as Special Term Sub-Tranche (B)
                checkForNewProgram(objRateCardHeader,objdealerAccountName);
            }
            //Calling Save Rate Card Detail Class to save/update the Note Rate and the Special Sub Tranches
            // MASTER NOTE RATE A
            noteRateString = (String)(argumentsFromPortal.get(MASTER_NOTERATE_A));
            noteRateAMap = (Map<String,Object>) Json.deserializeUntyped(noteRateString);
            
            PortalSaveRateCardDetailAPI.saveRateCardDetails(noteRateAMap,
                                                            objRateCardHeader.Id,
                                                            MASTER_NOTERATE_A);
            // SPECIAL TERM SUB TRANCHE B
            specialTrancheB = String.valueOf(argumentsFromPortal.get(PORTALCONSTANTS.SUB_TRANCHE_B));
            subTrancheBMap = (Map<String,Object>) Json.deserializeUntyped(specialTrancheB);
            PortalSaveRateCardDetailAPI.saveRateCardDetails(subTrancheBMap,
                                                            objRateCardHeader.Id,
                                                            PORTALCONSTANTS.SUB_TRANCHE_B);
            // SPECIAL TERM SUB TRANCHE C
            specialTrancheC = String.valueOf(argumentsFromPortal.get(PORTALCONSTANTS.SUB_TRANCHE_C));
            subTrancheCMap = (Map<String,Object>) Json.deserializeUntyped(specialTrancheC);
            PortalSaveRateCardDetailAPI.saveRateCardDetails(subTrancheCMap,
                                                            objRateCardHeader.Id,
                                                            PORTALCONSTANTS.SUB_TRANCHE_C);
            // SPECIAL TERM SUB TRANCHE D
            specialTrancheD = String.valueOf(argumentsFromPortal.get(PORTALCONSTANTS.SUB_TRANCHE_D));
            subTrancheDMap = (Map<String,Object>) Json.deserializeUntyped(specialTrancheD);
            PortalSaveRateCardDetailAPI.saveRateCardDetails(subTrancheDMap,
                                                            objRateCardHeader.Id,
                                                            PORTALCONSTANTS.SUB_TRANCHE_D);
            // SPECIAL TERM SUB TRANCHE E
            specialTrancheE = String.valueOf(argumentsFromPortal.get(PortalConstants.SUB_TRANCHE_E));
            subTrancheEMap = (Map<String,Object>) Json.deserializeUntyped(specialTrancheE);
            PortalSaveRateCardDetailAPI.saveRateCardDetails(subTrancheEMap,
                                                            objRateCardHeader.Id,
                                                            PortalConstants.SUB_TRANCHE_E);
            // SPECIAL TERM SUB TRANCHE F
            specialTrancheF = String.valueOf(argumentsFromPortal.get(PortalConstants.SUB_TRANCHE_F));
            subTrancheFMap = (Map<String,Object>) Json.deserializeUntyped(specialTrancheF);
            PortalSaveRateCardDetailAPI.saveRateCardDetails(subTrancheFMap,
                                                            objRateCardHeader.Id,
                                                            PortalConstants.SUB_TRANCHE_F);
            // SPECIAL TERM SUB TRANCHE G
            specialTrancheG = String.valueOf(argumentsFromPortal.get(PortalConstants.SUB_TRANCHE_G));
            subTrancheGMap = (Map<String,Object>) Json.deserializeUntyped(specialTrancheG);
            PortalSaveRateCardDetailAPI.saveRateCardDetails(subTrancheGMap,
                                                            objRateCardHeader.Id,
                                                            PortalConstants.SUB_TRANCHE_G);
            // SPECIAL TERM SUB TRANCHE H
            specialTrancheH = String.valueOf(argumentsFromPortal.get(PortalConstants.SUB_TRANCHE_H));
            subTrancheHMap = (Map<String,Object>) Json.deserializeUntyped(specialTrancheH);
            PortalSaveRateCardDetailAPI.saveRateCardDetails(subTrancheHMap,
                                                            objRateCardHeader.Id,
                                                            PortalConstants.SUB_TRANCHE_H);
            //validate start date of every tranch                                  
            MyProgramHelper.validateStartDateEverySubTranche(objRateCardHeader);
            //validate loan fee advanced on
            MyProgramHelper.validateLoanFeeAdvancedOn(objRateCardHeader);                                                
            //returning success as response for a successful creation of a My Program
            response.status = clcommon.Constants.SUCCESS;
            //Returning the My Program Id
            fieldsMap.put(MY_PROGRAM_ID, objRateCardHeader.Id);
            responseDataList.add(new clcommon.PortalCustomRemoteActionRecord(fieldsMap));
            clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(responseDataList);
            response.content = null;
            response.response = responseFormat.response;

        }
        catch (CustomException mce) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = mce.getMessage();
        } 
        catch (Exception ex) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
        }
        return response;
    }
    /** 
    * @description Called while submitting an application, generates the Flex Pricing Rate card header/detail and calls pricing api
    * @author Pritam Roy | 31-08-2023 
    * @param applicationId 
    * @param rateCardArguments
    * @return String 
    **/
    global static String createFlexRateCard(String applicationId, Map<String, Object> rateCardArguments){
        // declaration specific to this method starts
        CreateMyProgramHandler.FlexRateWrapper objFlexRateWrapper = new CreateMyProgramHandler.FlexRateWrapper();
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        genesis__Applications__c objApplicationBorrower = new genesis__Applications__c();
        Map<String,Object> noteRateAMap = new Map<String,Object>();
        Map<String,Object> subTrancheBMap = new Map<String,Object>();
        Map<String,Object> subTrancheCMap = new Map<String,Object>();
        Map<String,Object> subTrancheDMap =  new Map<String,Object>();
        Map<String,Object> subTrancheEMap = new Map<String,Object>();
        Map<String,Object> subTrancheFMap =  new Map<String,Object>();
        Map<String,Object> subTrancheGMap = new Map<String,Object>();
        Map<String,Object> subTrancheHMap =  new Map<String,Object>();
        Map<String, Object> flexRatingJsonMap = new Map<String, Object>();
        Map<String, Object> flexRateProgramMap = new Map<String, Object>();
        Map<String,Object> ratePricingMap = new Map<String,Object>();
        List<User> objdealerAccountName = new List<User>();
        Boolean shouldValidate = true;
        String flexRateId = '';
        String flexRateStr = '';
        Integer cropYear = 0;
        // declaration specific to this method ends

        objFlexRateWrapper = CreateMyProgramHandler.validateFlexRateCard(rateCardArguments);
        flexRateStr = objFlexRateWrapper.flexRateStr;
        shouldValidate = objFlexRateWrapper.shouldValidate;
        flexRatingJsonMap = objFlexRateWrapper.flexRatingJsonMap;
        flexRateProgramMap = (Map<String, Object>) Json.deserializeUntyped(Json.serialize(flexRatingJsonMap.get(FLEX_PROGRAM)));
        //null check for the necessary fields
        checkFlexRateArguments(flexRateProgramMap);
        objRateCardHeader = MyProgramValidationHelper.validateFlexRateHeader(applicationId,flexRateProgramMap);
        //Get the dealer name for additional determining factor
        objdealerAccountName =  MyProgramHelper.getDealerAccount();
        objApplicationBorrower =   MyProgramHelper.getApplicationById(applicationId);
        objRateCardHeader = CreateMyProgramHandler.checkFlexRateApplication(objRateCardHeader,objApplicationBorrower);
        objRateCardHeader = CreateMyProgramHandler.updateFlexRateHeader(objRateCardHeader,objdealerAccountName,objApplicationBorrower);
        //------------------Crop Year Validation----------------------
        cropYear = Integer.valueOf(objRateCardHeader.Crop_Year__c);
        MyProgramValidationUtil.validateCropYear(cropYear);
        objRateCardHeader = CreateMyProgramHandler.checkFlexRateLoanClosingFeePayer(objRateCardHeader);
        //------------------MATURITY DATE VALIDATION -----------------
        MyProgramValidationUtil.validateMaturityDate(objRateCardHeader, cropYear);
        CreateMyProgramHandler.checkFlexRateProgram(objRateCardHeader,objdealerAccountName);
        flexRateId = objRateCardHeader.Id;
        CreateMyProgramHandler.checkFlexRateAdditionalFactors(objRateCardHeader,objdealerAccountName);
        //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        ratePricingMap = (Map<String,Object>)Json.deserializeUntyped(String.valueOf(Json.serialize(flexRatingJsonMap.get(RATE_PRICING))));
        // MASTER NOTE RATE A
        noteRateAMap = (Map<String,Object>)Json.deserializeUntyped(String.valueOf(Json.serialize(ratePricingMap.get(MASTER_NOTERATE_A))));
        if(String.valueOf(noteRateAMap.get(PortalConstants.INTEREST_KEY)) != ConstantValues.BRACKETS_STRING && noteRateAMap.get(PortalConstants.INTEREST_KEY) != null ){
            PortalSaveRateCardDetailAPI.saveRateCardDetails(noteRateAMap,flexRateId,MASTER_NOTERATE_A);
        }
        // SUB TRANCHE B
        subTrancheBMap = (Map<String,Object>)Json.deserializeUntyped(String.valueOf(Json.serialize(ratePricingMap.get(PORTALCONSTANTS.SUB_TRANCHE_B))));
        createRateCardSetupDetails(subTrancheBMap, flexRateId, PORTALCONSTANTS.SUB_TRANCHE_B);

        // SUB TRANCHE C
        subTrancheCMap = (Map<String,Object>)Json.deserializeUntyped(String.valueOf(Json.serialize(ratePricingMap.get(PORTALCONSTANTS.SUB_TRANCHE_C))));
        createRateCardSetupDetails(subTrancheCMap, flexRateId, PORTALCONSTANTS.SUB_TRANCHE_C);

        // SUB TRANCHE D
        subTrancheDMap = (Map<String,Object>)Json.deserializeUntyped(String.valueOf(Json.serialize(ratePricingMap.get(PORTALCONSTANTS.SUB_TRANCHE_D))));
        createRateCardSetupDetails(subTrancheDMap, flexRateId, PORTALCONSTANTS.SUB_TRANCHE_D);

        // SUB TRANCHE E
        subTrancheEMap = (Map<String,Object>)Json.deserializeUntyped(String.valueOf(Json.serialize(ratePricingMap.get(PortalConstants.SUB_TRANCHE_E))));
        createRateCardSetupDetails(subTrancheEMap, flexRateId, PortalConstants.SUB_TRANCHE_E);

        // SUB TRANCHE F
        subTrancheFMap = (Map<String,Object>)Json.deserializeUntyped(String.valueOf(Json.serialize(ratePricingMap.get(PortalConstants.SUB_TRANCHE_F))));
        createRateCardSetupDetails(subTrancheFMap, flexRateId, PortalConstants.SUB_TRANCHE_F);

        // SUB TRANCHE G
        subTrancheGMap = (Map<String,Object>)Json.deserializeUntyped(String.valueOf(Json.serialize(ratePricingMap.get(PortalConstants.SUB_TRANCHE_G))));
        createRateCardSetupDetails(subTrancheGMap, flexRateId, PortalConstants.SUB_TRANCHE_G);

        // SUB TRANCHE H
        subTrancheHMap = (Map<String,Object>)Json.deserializeUntyped(String.valueOf(Json.serialize(ratePricingMap.get(PortalConstants.SUB_TRANCHE_H))));
        createRateCardSetupDetails(subTrancheHMap, flexRateId, PortalConstants.SUB_TRANCHE_H);

        //validate start date of every tranch
        MyProgramHelper.validateStartDateEverySubTranche(objRateCardHeader);
        //validate loan fee advanced on
        MyProgramHelper.validateLoanFeeAdvancedOn(objRateCardHeader); 
        //------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        CreateMyProgramHandler.updateFlexRateInApplication(objRateCardHeader,objApplicationBorrower,flexRateId);
        //DML on applciation to insert the Flex rating criteria on My Program.
        
        if(shouldValidate){
            //Generate the pricing detail for the particular application only for Save and Continue
            //genesis.SkuidPricingCtrl.generatePricing(applicationId);
            PortalApplicationOriginationHelper.generateChildLoans(applicationId);
        }
        return flexRateId; 
    }
    
    /**
    * @description : check flex rate arguments
    * @author  Pritam Roy | 03-06-2024 
    * @param flexRateProgramMap 
    **/
    private static void checkFlexRateArguments(Map<String, Object> flexRateProgramMap){
        MyProgramUtil.nullCheckException(flexRateProgramMap.get(FIELD_CROP_YEAR), PortalConstants.REQUIRED_PARAMETERS_MISSING);
        MyProgramUtil.nullCheckException(flexRateProgramMap.get(FIELD_MATURITY_DATE), PortalConstants.REQUIRED_PARAMETERS_MISSING);
        MyProgramUtil.nullCheckException(flexRateProgramMap.get(FIELD_PAYER), PortalConstants.REQUIRED_PARAMETERS_MISSING);
        if(flexRateProgramMap.get(FIELD_PAYER) == PortalConstants.GROWER_PROFILE){
            MyProgramUtil.nullCheckException(flexRateProgramMap.get(FIELD_ADVANCEON), PortalConstants.REQUIRED_PARAMETERS_MISSING);
            MyProgramUtil.nullCheckException(flexRateProgramMap.get(FIELD_DEALER_PART), PortalConstants.REQUIRED_PARAMETERS_MISSING);
            MyProgramValidationHelper.checkAffirmative(flexRateProgramMap.get(FIELD_DEALER_PART),flexRateProgramMap.get(FIELD_FEE_PORTION),PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }
    
    /**
    * @description : validate flex rate arguments from portal
    * @author  Pritam Roy | 03-06-2024 
    * @param argumentsFromPortal 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    private static genesis__Rate_Card_Setup_Header__c validateArgumentsFromPortal(Map<String, Object> argumentsFromPortal){
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
        String myProgram = '';
        String myProgramName = '';
        MyProgramUtil.nullCheckException(argumentsFromPortal.get(PROGRAM), PortalConstants.SOMETHING_WENT_WRONG);
        myProgram = String.valueOf(argumentsFromPortal.get(PROGRAM));
        if(String.isNotBlank(myProgram)){
            objRateCardHeader = (genesis__Rate_Card_Setup_Header__c) Json.deserialize(myProgram, genesis__Rate_Card_Setup_Header__c.class);
        }
        MyProgramUtil.nullCheckException(objRateCardHeader.get(FIELD_CROP_YEAR), PortalConstants.REQUIRED_PARAMETERS_MISSING);
        MyProgramUtil.nullCheckException(objRateCardHeader.get(FIELD_NAME), PortalConstants.REQUIRED_PARAMETERS_MISSING);
        MyProgramUtil.nullCheckException(objRateCardHeader.get(FIELD_MATURITY_DATE), PortalConstants.REQUIRED_PARAMETERS_MISSING);
        MyProgramUtil.nullCheckException(objRateCardHeader.get(FIELD_PAYER), PortalConstants.REQUIRED_PARAMETERS_MISSING);
        myProgramName = (String)objRateCardHeader.get(FIELD_NAME);
        CreateMyProgramHandler.validateMyProgramName(myProgramName,HASH);
        CreateMyProgramHandler.validateMyProgramName(myProgramName,COLON);
        if(objRateCardHeader.get(FIELD_PAYER) == PortalConstants.GROWER_PROFILE){
            MyProgramUtil.nullCheckException(objRateCardHeader.get(FIELD_ADVANCEON), PortalConstants.REQUIRED_PARAMETERS_MISSING);
            MyProgramUtil.nullCheckException(objRateCardHeader.get(FIELD_DEALER_PART), PortalConstants.REQUIRED_PARAMETERS_MISSING);
            MyProgramValidationHelper.checkAffirmative(objRateCardHeader.get(FIELD_DEALER_PART),objRateCardHeader.get(FIELD_FEE_PORTION),PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
        MyProgramUtil.nullCheckException(objRateCardHeader.get(FIELD_ID), PortalConstants.SOMETHING_WENT_WRONG);
        return objRateCardHeader;
    }
    
    /**
    * @description : update my program after it gets updated
    * @author  Pritam Roy | 03-06-2024 
    * @param objRateCardHeader 
    * @param objdealerAccountName 
    **/
    private static void checkForUpdatedMyProgram(genesis__Rate_Card_Setup_Header__c objRateCardHeader,List<User> objdealerAccountName){
        List<genesis__Additional_Determining_Factor__c> objFactorProgramList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> objFactorDealerList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardToUpdateList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = new List<genesis__Rate_Card_Setup_Detail__c>();

        Database.update(objRateCardHeader,true); //check rate card is of this particular CL
        //query the additional determining factor and update the program name
        objFactorProgramList =   [SELECT  Id, 
                                                Name,
                                                genesis__Field_Value__c 
                                        FROM genesis__Additional_Determining_Factor__c 
                                        WHERE genesis__Rate_Card_Setup_Header__c = :objRateCardHeader.Id AND
                                        Name = :PortalConstants.MY_PROGRAM_FACTOR_NAME
                                        LIMIT 1];
        objFactorProgramList[0].genesis__Field_Value__c = MyProgramUtil.objNullCheck(objRateCardHeader.Name);
        Database.update(objFactorProgramList,true);
        //query the additional determining factor and update the program name
        objFactorDealerList =  [SELECT Id, 
                                                    Name,
                                                    genesis__Field_Value__c 
                                            FROM genesis__Additional_Determining_Factor__c 
                                            WHERE genesis__Rate_Card_Setup_Header__c = :objRateCardHeader.Id AND
                                            Name = :PortalConstants.DEALER_PROFILE
                                            LIMIT 1];
        if(objdealerAccountName.size() > 0 &&
            objdealerAccountName[0].Contact.Account.ParentId != null &&
            objdealerAccountName[0].Contact.Account.Parent.Name != null){
                objFactorDealerList[0].genesis__Field_Value__c = objdealerAccountName[0].Contact.Account.Parent.Name;
        }                                    
        Database.update(objFactorDealerList,true);
        //query all the rate card details and update the additional determining factor on rate card detail level
        objRateCardDetailList =  [ SELECT  Id,
                                            genesis__Rate_Card_Setup_Header__c,
                                            genesis__Determining_Factor_Key_Value__c
                                    FROM genesis__Rate_Card_Setup_Detail__c
                                    WHERE genesis__Rate_Card_Setup_Header__c = :objRateCardHeader.Id];
        for(genesis__Rate_Card_Setup_Detail__c objIndividualRate : objRateCardDetailList){
            if(objdealerAccountName.size() > 0 && 
                objRateCardHeader.Name != null && 
                objdealerAccountName[0].Contact.Account.ParentId != null &&
                objdealerAccountName[0].Contact.Account.Parent.Name != null){
                    objIndividualRate.genesis__Determining_Factor_Key_Value__c = String.valueOf(objFactorProgramList[0].Id)+':'
                                                                                            +String.valueOf(objRateCardHeader.Name)+'#'
                                                                                            +String.valueOf(objFactorDealerList[0].Id)+':'
                                                                                            +String.valueOf(objdealerAccountName[0].Contact.Account.Parent.Name)+'#';
                    objRateCardToUpdateList.add(objIndividualRate);
            }
        }
        Database.update(objRateCardToUpdateList,true);
    }
    
    /**
    * @description : creates product rate association and additional determining factors for new program
    * @author  Pritam Roy | 03-06-2024 
    * @param objRateCardHeader 
    * @param objdealerAccountName 
    **/
    private static void checkForNewProgram(genesis__Rate_Card_Setup_Header__c objRateCardHeader,List<User> objdealerAccountName){
        genesis__Additional_Determining_Factor__c objAdditionalFactor = new genesis__Additional_Determining_Factor__c();
        genesis__Additional_Determining_Factor__c objAdditionalFactorDealer = new genesis__Additional_Determining_Factor__c();
        genesis__Product_Rate_Card_Association__c objProductAssociation = new genesis__Product_Rate_Card_Association__c();
        List<clcommon__CL_Product__c> objProductToAssociateList = new List<clcommon__CL_Product__c>();

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
        MyProgramUtil.listIsEmptyCheck(objProductToAssociateList, PortalConstants.SOMETHING_WENT_WRONG);
        //Create a Product Rate Card Association
        objProductAssociation.genesis__CL_Product__c = objProductToAssociateList[0].Id;
        objProductAssociation.genesis__Rate_Card_Setup__c = objRateCardHeader.Id;
        Database.upsert(objProductAssociation,true);
        //Setting up the additional determining factor for the particular My Program
        objAdditionalFactor.Name = PortalConstants.MY_PROGRAM_FACTOR_NAME; //Program
        objAdditionalFactor.genesis__Evaluation_Operator__c = PortalConstants.FACTOR_EVALUATION_OPERATOR;
        objAdditionalFactor.genesis__Rate_Card_Setup_Header__c = objRateCardHeader.Id;
        objAdditionalFactor.genesis__Applicable_for_Application__c = true;
        objAdditionalFactor.genesis__Application_Object_API_Name__c = PortalConstants.APPLICATION_API_NAME;
        objAdditionalFactor.genesis__Application_Object_Name__c = PortalConstants.APPLICATION_OBJECT_NAME;
        objAdditionalFactor.genesis__Application_Field_API_Name__c =  PortalConstants.MY_PROGRAM_FIELD_API_NAME;
        objAdditionalFactor.genesis__Application_Field_Name__c = PortalConstants.MY_PROGRAM_FIELD_NAME;
        objAdditionalFactor.genesis__Application_Field_Type__c = PortalConstants.FIELD_TYPE;
        objAdditionalFactor.genesis__Apply_to_all_Rate_Card_Details__c = true;
        if(String.isNotBlank(objRateCardHeader.Name)){
            objAdditionalFactor.genesis__Field_Value__c = objRateCardHeader.Name;
        }
        Database.upsert(objAdditionalFactor,true);
        //setting up the additional determining factor of the Dealer's name as the factor
        objAdditionalFactorDealer.Name = PortalConstants.DEALER_PROFILE;
        objAdditionalFactorDealer.genesis__Evaluation_Operator__c = PortalConstants.FACTOR_EVALUATION_OPERATOR;
        objAdditionalFactorDealer.genesis__Rate_Card_Setup_Header__c = objRateCardHeader.Id;
        objAdditionalFactorDealer.genesis__Applicable_for_Application__c = true;
        objAdditionalFactorDealer.genesis__Application_Object_API_Name__c = PortalConstants.APPLICATION_API_NAME;
        objAdditionalFactorDealer.genesis__Application_Object_Name__c = PortalConstants.APPLICATION_OBJECT_NAME;
        objAdditionalFactorDealer.genesis__Application_Field_API_Name__c =  PortalConstants.MY_PROGRAM_DEALER_FIELD;
        objAdditionalFactorDealer.genesis__Application_Field_Name__c = PortalConstants.DEALER_NAME;
        objAdditionalFactorDealer.genesis__Application_Field_Type__c = PortalConstants.FIELD_TYPE;
        objAdditionalFactorDealer.genesis__Apply_to_all_Rate_Card_Details__c = true;
        if(objdealerAccountName.size() > 0 &&
            String.isNotBlank(objdealerAccountName[0].Contact.Account.Parent.Name)){
                objAdditionalFactorDealer.genesis__Field_Value__c = objdealerAccountName[0].Contact.Account.Parent.Name;
        }
        Database.upsert(objAdditionalFactorDealer,true);
    }
    
    /**
    * @description : populate rate card header
    * @author  Pritam Roy | 03-06-2024 
    * @param objRateCardHeader 
    * @param objdealerAccountName 
    * @param objRecordType 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    private static genesis__Rate_Card_Setup_Header__c populateRateCardHeader(
        genesis__Rate_Card_Setup_Header__c objRateCardHeader,
        List<User> objdealerAccountName,
        RecordType objRecordType
    ) {
        if (objRateCardHeader != null) {
            if (objdealerAccountName.size() > 0 && objdealerAccountName[0].Contact.Account.ParentId != null) {
                objRateCardHeader.Account__c = objdealerAccountName[0].Contact.Account.ParentId;
                
                BaseRateService.BaseRateInfo baseRateInfo = BaseRateService.fetchAndCacheBaseRate(objRateCardHeader.Account__c);
                if (baseRateInfo != null && baseRateInfo.floatingRateIndex != null) {
                    objRateCardHeader.Base_Rate__c = baseRateInfo.floatingRateIndex.Id;
                }
            }
            if(objRecordType != null){
                objRateCardHeader.RecordTypeId = objRecordType.Id;
            }
            objRateCardHeader.genesis__Product_Type__c = PortalConstants.PRODUCT_TYPE_FOR_MY_PROGRAM;
            objRateCardHeader.genesis__Filter_By_Credit_Rating__c = false;
            objRateCardHeader.genesis__Filter_By_Frequency__c = false;
            objRateCardHeader.genesis__Filter_By_Loan_Amount__c = false;
            objRateCardHeader.genesis__Filter_By_Term__c = false;
            objRateCardHeader.genesis__Transaction_Date__c = System.today();
            objRateCardHeader.Status__c = PortalConstants.NOT_SUBMITTED_MY_PROGRAM;
            objRateCardHeader.genesis__Enabled_Flag__c = false;
            objRateCardHeader.Special_Term_Number__c = PortalConstants.SPECIAL_TERM_A;
        }
        return objRateCardHeader;
    }

    /**
    * @description : Create Rate Card Setup Details for Each Tranche
    * @author  Pritam Roy | 07-12-2024 
    * @param subTrancheMap 
    * @param headerId 
    * @param subTrancheName
    **/
    private static void createRateCardSetupDetails(Map<String,Object> subTrancheMap,Id headerId,String subTrancheName){
        if(subTrancheMap.get(PortalConstants.INTEREST_KEY) != null){
            PortalSaveRateCardDetailAPI.saveRateCardDetails(subTrancheMap,headerId,subTrancheName);
        }
    }
    
}