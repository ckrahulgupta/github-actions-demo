/**
 * @description       : Saves a My program for a particular GMK
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 10-25-2024
 * @last modified by  : Ayush Kumar Singh
**/
global without sharing class GMKPortalCreateMyProgramAPI implements clcommon.PortalCustomRemoteAPI1 {

    //constants specific to this class starts
    private static final String HASH = '#';
    private static final String COLON = ':';
    private static final String MY_PROGRAM_ID = 'myProgramId';
    //constants specific to thsi class ends

    // Class specific declarations
    private Map<String, Object> noteRateAMap = new Map<String, Object>();
    private Map<String, Object> subTrancheBMap = new Map<String, Object>();
    private Map<String, Object> subTrancheCMap = new Map<String, Object>();
    private Map<String, Object> subTrancheDMap =  new Map<String, Object>();
    private Map<String, Object> subTrancheEMap = new Map<String, Object>();
    private Map<String, Object> subTrancheFMap = new Map<String, Object>();
    private Map<String, Object> subTrancheGMap = new Map<String, Object>();
    private Map<String, Object> subTrancheHMap = new Map<String, Object>();
   
    private Map<String, Object> flexRatingJsonMap = new Map<String, Object>();
    //Integer cropYearToValidate;
    private String cropYear = '';
    

    /**
    * @description : Populate My Program Header Fields
    * @author  Pritam Roy | 03-04-2024 
    * @param objRateCardHeader 
    * @param objdealerAccountName 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    private genesis__Rate_Card_Setup_Header__c populateRequiredFieldsForMyProgram(genesis__Rate_Card_Setup_Header__c objRateCardHeader, List<User> objdealerAccountName) {

        RecordType objRecordType = [
                        SELECT Id 
                        FROM RecordType 
                        WHERE Name = :PortalConstants.LOAN_STRING AND 
                              SObjectType = :PortalConstants.OBJECT_RATE 
                        LIMIT 1
                    ];
        // My Program is getting updated
        if (objdealerAccountName.size() > 0 &&
            objdealerAccountName[0].Account.ParentId != null) {
            objRateCardHeader.Account__c = objdealerAccountName[0].Account.ParentId;
        }
        objRateCardHeader.RecordTypeId = MyProgramutil.objNullCheck(objRecordType.Id);
        objRateCardHeader.genesis__Product_Type__c = PortalConstants.PRODUCT_TYPE_FOR_MY_PROGRAM;
        objRateCardHeader.genesis__Filter_By_Credit_Rating__c = false;
        objRateCardHeader.genesis__Filter_By_Frequency__c = false;
        objRateCardHeader.genesis__Filter_By_Loan_Amount__c = false;
        objRateCardHeader.genesis__Filter_By_Term__c = false;
        objRateCardHeader.genesis__Transaction_Date__c = System.today();
        objRateCardHeader.Status__c = PortalConstants.NOT_SUBMITTED_MY_PROGRAM;
        objRateCardHeader.genesis__Enabled_Flag__c = false;

        return objRateCardHeader;
    }

    /**
    * @description : Process existing My ProgramF
    * @author  Pritam Roy | 03-04-2024 
    * @param objRateCardHeader 
    * @param objdealerAccountName 
    **/
    private void processExistingMyProgram(genesis__Rate_Card_Setup_Header__c objRateCardHeader, List<User> objdealerAccountName) {
        
        List<genesis__Additional_Determining_Factor__c> objAddDetFactorList = new List<genesis__Additional_Determining_Factor__c>();
        List<genesis__Additional_Determining_Factor__c> updateAddDetFactorList = new List<genesis__Additional_Determining_Factor__c>();
        String programAdditionalFactor;
        String dealerAdditionalFactor;

        Database.update(objRateCardHeader, true);

        // query the additional determining factor and update the program name
        objAddDetFactorList = [
                    SELECT Id, 
                            Name,
                            genesis__Field_Value__c 
                    FROM genesis__Additional_Determining_Factor__c 
                    WHERE genesis__Rate_Card_Setup_Header__c = :objRateCardHeader.Id 
                    AND (Name = :PortalConstants.MY_PROGRAM_FACTOR_NAME OR Name = :PortalConstants.DEALER_PROFILE)
                ];

        for(genesis__Additional_Determining_Factor__c objFactor : objAddDetFactorList ){
        
            if(objFactor.name == PortalConstants.MY_PROGRAM_FACTOR_NAME){
                objFactor.genesis__Field_Value__c = MyProgramUtil.objNullCheck(objRateCardHeader.Name);
                programAdditionalFactor = String.valueOf(objFactor.Id);
            }else{
                if (CreateMyProgramHandler.checkArguments(objdealerAccountName)) {
                        objFactor.genesis__Field_Value__c = objdealerAccountName[0].Account.Parent.Name;
                } 
                dealerAdditionalFactor = String.valueOf(objFactor.Id);
            }
            updateAddDetFactorList.add(objFactor);
        }
        //objAddDetFactorList.add(dealerAdditionalFactor);
        Database.update(updateAddDetFactorList,true);

        //query all the rate card details and update the additional determining factor on rate card detail level
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardToUpdateList = new List<genesis__Rate_Card_Setup_Detail__c>();
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardDetailList = [ 
                    SELECT  Id,
                            genesis__Rate_Card_Setup_Header__c,
                            genesis__Determining_Factor_Key_Value__c
                    FROM genesis__Rate_Card_Setup_Detail__c
                    WHERE genesis__Rate_Card_Setup_Header__c = :objRateCardHeader.Id
                ];
        for (genesis__Rate_Card_Setup_Detail__c objIndividualRate : objRateCardDetailList) {
            if (objdealerAccountName.size() > 0 && 
                objRateCardHeader.Name != null && 
                objdealerAccountName[0].Account.ParentId != null &&
                objdealerAccountName[0].Account.Parent.Name != null
            ) {
                objIndividualRate.genesis__Determining_Factor_Key_Value__c = 
                    String.valueOf(programAdditionalFactor) + COLON
                    + String.valueOf(objRateCardHeader.Name) + HASH
                    + String.valueOf(dealerAdditionalFactor) + COLON
                    + String.valueOf(objdealerAccountName[0].Account.Parent.Name) + HASH;

                objRateCardToUpdateList.add(objIndividualRate);
            }
        }
        Database.update(objRateCardToUpdateList, true);
    }

    
    /**
    * @description : Process new My Program
    * @author  Pritam Roy | 05-02-2024 
    * @param objRateCardHeader 
    * @param objdealerAccountName 
    * @param programType 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    private static genesis__Rate_Card_Setup_Header__c processNewMyProgram(genesis__Rate_Card_Setup_Header__c objRateCardHeader, List<User> objdealerAccountName,String programType) {
        List<genesis__Additional_Determining_Factor__c> objAddDetFactorList = new List<genesis__Additional_Determining_Factor__c>();
        genesis__Additional_Determining_Factor__c objAdditionalFactor = new genesis__Additional_Determining_Factor__c();
        genesis__Additional_Determining_Factor__c objFactorDealer = new genesis__Additional_Determining_Factor__c();
        genesis__Product_Rate_Card_Association__c objRatecardAssociation = new genesis__Product_Rate_Card_Association__c();

        //Populate the Special term Number as Special Term Sub-Tranche (B)
        objRateCardHeader.Special_Term_Number__c = PortalConstants.SPECIAL_TERM_A;
        Database.insert(objRateCardHeader, true);
        //create product association
        //Get the Id of the particular product to associate
        clcommon__CL_Product__c objProductToAssociate = [
                    SELECT Id, 
                           Name, 
                           RecordType.Name, 
                           clcommon__Product_Name__c, 
                           clcommon__Pricing_Method__c 
                    FROM clcommon__CL_Product__c 
                    WHERE RecordType.Name = :PortalConstants.LOAN_STRING AND 
                        clcommon__Product_Name__c = :PortalConstants.SIMPLIFY_TYPE 
                    LIMIT 1
                ];
        //Create a Product Rate Card Association
        objRatecardAssociation.genesis__CL_Product__c = MyProgramUtil.objNullCheck(objProductToAssociate.id);
        objRatecardAssociation.genesis__Rate_Card_Setup__c = objRateCardHeader.Id;
        Database.upsert(objRatecardAssociation, true);

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
        if (String.isNotBlank(objRateCardHeader.Name)) {
            objAdditionalFactor.genesis__Field_Value__c = objRateCardHeader.Name;
        }
        objAddDetFactorList.add(objAdditionalFactor);

        //setting up the additional determining factor of the Dealer's name as the factor
        objFactorDealer.Name = PortalConstants.DEALER_PROFILE;
        objFactorDealer.genesis__Evaluation_Operator__c = PortalConstants.FACTOR_EVALUATION_OPERATOR;
        objFactorDealer.genesis__Rate_Card_Setup_Header__c = objRateCardHeader.Id;
        objFactorDealer.genesis__Applicable_for_Application__c = true;
        objFactorDealer.genesis__Application_Object_API_Name__c = PortalConstants.APPLICATION_API_NAME;
        objFactorDealer.genesis__Application_Object_Name__c = PortalConstants.APPLICATION_OBJECT_NAME;
        objFactorDealer.genesis__Application_Field_API_Name__c =  PortalConstants.MY_PROGRAM_DEALER_FIELD;
        objFactorDealer.genesis__Application_Field_Name__c = PortalConstants.DEALER_NAME;
        objFactorDealer.genesis__Application_Field_Type__c = PortalConstants.FIELD_TYPE;
        objFactorDealer.genesis__Apply_to_all_Rate_Card_Details__c = true;
        if (objdealerAccountName.size() > 0 &&
            String.isNotBlank(objdealerAccountName[0].Account.Parent.Name)) {
            objFactorDealer.genesis__Field_Value__c = objdealerAccountName[0].Account.Parent.Name;
        }
        objAddDetFactorList.add(objFactorDealer);
        Database.upsert(objAddDetFactorList, true);

        if(programType.equals(PortalConstants.FLEXPROGRAM)){
            return objRateCardHeader;
        }
        return null;
    }

    /**
    * @description : Generate Rate Card Details
    * @author  Pritam Roy | 03-04-2024 
    * @param objRateCardHeader 
    * @param request 
    **/
    private void generateRateCardDetails(genesis__Rate_Card_Setup_Header__c objRateCardHeader, Map<String, Object> request) {
        //Calling Save Rate Card Detail Class to save/update the Note Rate and the Special Sub Tranches
        // MASTER NOTE RATE A
        String noteRateString = '';
        String specialTrancheB = '';
        String specialTrancheC = '';
        String specialTrancheD = '';
        String specialTrancheE = '';
        String specialTrancheF = '';
        String specialTrancheG = '';
        String specialTrancheH = '';
        noteRateString = (String) (request.get(PortalConstants.MASTER_NOTERATE_A));
        noteRateAMap = (Map<String, Object>) JSON.deserializeUntyped(noteRateString);
        
        GMKPortalSaveRateCardDetailsAPI.saveRateCardDetails(noteRateAMap,
                                                        objRateCardHeader.Id,
                                                        PortalConstants.MASTER_NOTERATE_A);
        // SPECIAL TERM SUB TRANCHE B
        specialTrancheB = String.valueOf(request.get(PortalConstants.SUB_TRANCHE_B));
        subTrancheBMap = (Map<String, Object>) JSON.deserializeUntyped(specialTrancheB);
        GMKPortalSaveRateCardDetailsAPI.saveRateCardDetails(subTrancheBMap,
                                                        objRateCardHeader.Id,
                                                        PortalConstants.SUB_TRANCHE_B);
        // SPECIAL TERM SUB TRANCHE C
        specialTrancheC = String.valueOf(request.get(PortalConstants.SUB_TRANCHE_C));
        subTrancheCMap = (Map<String, Object>) JSON.deserializeUntyped(specialTrancheC);
        GMKPortalSaveRateCardDetailsAPI.saveRateCardDetails(subTrancheCMap,
                                                        objRateCardHeader.Id,
                                                        PortalConstants.SUB_TRANCHE_C);
        // SPECIAL TERM SUB TRANCHE D
        specialTrancheD = String.valueOf(request.get(PortalConstants.SUB_TRANCHE_D));
        subTrancheDMap = (Map<String, Object>) JSON.deserializeUntyped(specialTrancheD);
        GMKPortalSaveRateCardDetailsAPI.saveRateCardDetails(subTrancheDMap,
                                                        objRateCardHeader.Id,
                                                        PortalConstants.SUB_TRANCHE_D);
        // SPECIAL TERM SUB TRANCHE E
        specialTrancheE = String.valueOf(request.get(PortalConstants.SUB_TRANCHE_E));
        subTrancheEMap = (Map<String, Object>) Json.deserializeUntyped(specialTrancheE);
        GMKPortalSaveRateCardDetailsAPI.saveRateCardDetails(subTrancheEMap,
                                                        objRateCardHeader.Id,
                                                        PortalConstants.SUB_TRANCHE_E);

        // SPECIAL TERM SUB TRANCHE F
        specialTrancheF = String.valueOf(request.get(PortalConstants.SUB_TRANCHE_F));
        subTrancheFMap = (Map<String, Object>) Json.deserializeUntyped(specialTrancheF);
        GMKPortalSaveRateCardDetailsAPI.saveRateCardDetails(subTrancheFMap,
                                                        objRateCardHeader.Id,
                                                        PortalConstants.SUB_TRANCHE_F);
        
        // SPECIAL TERM SUB TRANCHE G
        specialTrancheG = String.valueOf(request.get(PortalConstants.SUB_TRANCHE_G));
        subTrancheGMap = (Map<String, Object>) Json.deserializeUntyped(specialTrancheG);
        GMKPortalSaveRateCardDetailsAPI.saveRateCardDetails(subTrancheGMap,
                                                        objRateCardHeader.Id,
                                                        PortalConstants.SUB_TRANCHE_G);

        // SPECIAL TERM SUB TRANCHE H
        specialTrancheH = String.valueOf(request.get(PortalConstants.SUB_TRANCHE_H));
        subTrancheHMap = (Map<String, Object>) Json.deserializeUntyped(specialTrancheH);
        GMKPortalSaveRateCardDetailsAPI.saveRateCardDetails(subTrancheHMap,
                                                        objRateCardHeader.Id,
                                                        PortalConstants.SUB_TRANCHE_H);
    }

    /**
    * @description This method populates certain required fields for rate card header and saves the My Program
    * @author Subham Nandi | 08-02-2022 
    * @param componentStrName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                        String[] disclosureNames,
                                        Map<String, Object> request) {
        String myProgramName = '';
        SavePoint dbSavePoint = Database.setSavepoint();
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        Map<String, Object> fieldsMap = new Map<String, Object>();
        clcommon.Response response = new clcommon.Response();


        Integer cropYearToValidate;
        try {
            
            genesis__Rate_Card_Setup_Header__c objRateCardHeader = PortalValidationUtil.validateMyProgramRequest(request);
            myProgramName = (String)objRateCardHeader.get(PortalConstants.FIELD_NAME);
            CreateMyProgramHandler.validateMyProgramName(myProgramName, HASH);
            CreateMyProgramHandler.validateMyProgramName(myProgramName, COLON);

            String myProgramId = (String) objRateCardHeader.Id;
            cropYear = (String) objRateCardHeader.Crop_Year__c;
            if (String.isNotBlank(cropYear)) {
                cropYearToValidate = Integer.valueOf(cropYear);
            }


            List<User> objdealerAccountName =  PortalApplicationOriginationHelper.getLoggedInUser();

            objRateCardHeader.Id = (myProgramId == null || myProgramId == PortalConstants.NEW_RECORD_STRING) ? null : myProgramId;
            
            PortalValidationUtil.validateCropYear(cropYearToValidate);


            // PortalValidationUtil.validatePayerOfLoanClosingFee(objRateCardHeader);

            //Auto populating start date of the 'My Program' as today's date if not selected
            objRateCardHeader.genesis__Start_Date__c = System.today();
            // //Check for the maturity date of a my program to be on future dates
            
            MyProgramValidationUtil.validateMaturityDate(objRateCardHeader,cropYearToValidate);
            
            //The fields that are required to create a desired My Program are populated
            
            objRateCardHeader = populateRequiredFieldsForMyProgram(objRateCardHeader, objdealerAccountName);

            if (objRateCardHeader.Id != null) {
                processExistingMyProgram(objRateCardHeader, objdealerAccountName);
            }else{
            // New My Program is added
                processNewMyProgram(objRateCardHeader, objdealerAccountName,PortalConstants.MY_PROGRAM_FACTOR_NAME);
            }

            generateRateCardDetails(objRateCardHeader, request);
            MyProgramHelper.validateStartDateEverySubTranche(objRateCardHeader);
            // returning success as response for a successful creation of a My Program
            response.status = clcommon.Constants.SUCCESS;
            //Returning the My Program Id
            fieldsMap.put(MY_PROGRAM_ID, objRateCardHeader.Id);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(fieldsMap));
            clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.content = null;
            response.response = responseFormat.response;

        }
        catch (CustomException mce) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = mce.getMessage();
            PortalHelper.saveExceptionLog(mce, GMKPortalCreateMyProgramAPI.class.getName());
        } 
        catch (Exception ex) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(ex, GMKPortalCreateMyProgramAPI.class.getName());
        }
        return response;
    }


    /**
    * @description : Populate flex rate fields
    * @author  Pritam Roy | 03-04-2024 
    * @param objdealerAccountName 
    * @param objBorrower 
    * @param objRateCardHeader 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    private genesis__Rate_Card_Setup_Header__c populateRequiredFieldsForFlexRate(List<User> objdealerAccountName, genesis__Applications__c objBorrower, genesis__Rate_Card_Setup_Header__c objRateCardHeader) {
        objRateCardHeader.Name = objBorrower.Name + PortalConstants.FLEX_PRICE_STRING;
        //getting the record type for rate card header
        RecordType objRecordType = [
                    SELECT Id 
                    FROM RecordType 
                    WHERE Name = :PortalConstants.LOAN_STRING AND 
                    SobjectType = :PortalConstants.OBJECT_RATE
                    LIMIT 1
                ];
        MyProgramUtil.nullCheckException(objRecordType, PortalConstants.SOMETHING_WENT_WRONG);
            objRateCardHeader.RecordTypeId = MyProgramUtil.objNullCheck(objRecordType.id);
        //Assigning the rate card to the Dealer
        if (objdealerAccountName.size() > 0 &&
            objdealerAccountName[0].Account.ParentId != null) {
            objRateCardHeader.Account__c = objdealerAccountName[0].Account.ParentId;
        }
        // Integer differenceInDays = Integer.valueOf(PortalConstants.DIFFERENCE_BETWEEN_STARTDATE);
        Date flexRateStartDate = date.newinstance(objBorrower.CreatedDate.year(), objBorrower.CreatedDate.month(), objBorrower.CreatedDate.day());
        objRateCardHeader.genesis__Start_Date__c = flexRateStartDate;
        objRateCardHeader.genesis__Transaction_Date__c = system.today();
        objRateCardHeader.genesis__Product_Type__c = PortalConstants.PRODUCT_TYPE_FOR_MY_PROGRAM;
        objRateCardHeader.genesis__Filter_By_Credit_Rating__c = false;
        objRateCardHeader.genesis__Filter_By_Frequency__c = false;
        objRateCardHeader.genesis__Filter_By_Loan_Amount__c = false;
        objRateCardHeader.genesis__Filter_By_Term__c = false;
        objRateCardHeader.Is_Flex_Rate__c = true;


        return objRateCardHeader;
    }


    /**
    * @description : Generate rate card deatails for flex rate
    * @author  Pritam Roy | 03-04-2024 
    * @param flexRateId 
    **/
    private void generateCardDetailsForFlexRate(String flexRateId) {

        Map<String, Object> ratePricingMap = (Map<String, Object>)JSON.deserializeUntyped(String.valueOf(Json.serialize(flexRatingJsonMap.get('ratePricing'))));

        


        // MASTER NOTE RATE A
        //noteRateString = (String)(flexRatingJsonMap.get(PortalConstants.MASTER_NOTERATE_A));
        noteRateAMap = (Map<String, Object>)Json.deserializeUntyped(String.valueOf(Json.serialize(ratePricingMap.get(PortalConstants.MASTER_NOTERATE_A))));
        if (String.valueOf(noteRateAMap.get(PortalConstants.INTEREST_KEY)) != ConstantValues.BRACKETS_STRING && noteRateAMap.get(PortalConstants.INTEREST_KEY) != null) {
            GMKPortalSaveRateCardDetailsAPI.saveRateCardDetails(noteRateAMap,flexRateId,PortalConstants.MASTER_NOTERATE_A);
        }
        // SUB TRANCHE B
        //specialTrancheB = (String)(flexRatingJsonMap.get(PortalConstants.SUB_TRANCHE_B));
        subTrancheBMap = (Map<String, Object>)Json.deserializeUntyped(String.valueOf(Json.serialize(ratePricingMap.get(PortalConstants.SUB_TRANCHE_B))));
        createRateCardSetupDetails(subTrancheBMap, flexRateId, PortalConstants.SUB_TRANCHE_B);
        // SUB TRANCHE C
        //specialTrancheC = (String)(flexRatingJsonMap.get(PortalConstants.SUB_TRANCHE_B));
        subTrancheCMap = (Map<String, Object>)Json.deserializeUntyped(String.valueOf(Json.serialize(ratePricingMap.get(PortalConstants.SUB_TRANCHE_C))));
        createRateCardSetupDetails(subTrancheCMap, flexRateId, PortalConstants.SUB_TRANCHE_C);
        // SUB TRANCHE D
        //specialTrancheD = (String)(flexRatingJsonMap.get(PortalConstants.SUB_TRANCHE_B));
        subTrancheDMap = (Map<String, Object>)Json.deserializeUntyped(String.valueOf(Json.serialize(ratePricingMap.get(PortalConstants.SUB_TRANCHE_D))));
        createRateCardSetupDetails(subTrancheDMap, flexRateId, PortalConstants.SUB_TRANCHE_D);
        // SUB TRANCHE E
        //specialTrancheE = (String)(flexRatingJsonMap.get(PortalConstants.SUB_TRANCHE_B));
        subTrancheEMap = (Map<String, Object>)Json.deserializeUntyped(String.valueOf(Json.serialize(ratePricingMap.get(PortalConstants.SUB_TRANCHE_E))));
        createRateCardSetupDetails(subTrancheEMap, flexRateId, PortalConstants.SUB_TRANCHE_E);
        // SUB TRANCHE F
        subTrancheFMap = (Map<String, Object>)Json.deserializeUntyped(String.valueOf(Json.serialize(ratePricingMap.get(PortalConstants.SUB_TRANCHE_F))));
        createRateCardSetupDetails(subTrancheFMap, flexRateId, PortalConstants.SUB_TRANCHE_F);
        // SUB TRANCHE G
        subTrancheGMap = (Map<String, Object>)Json.deserializeUntyped(String.valueOf(Json.serialize(ratePricingMap.get(PortalConstants.SUB_TRANCHE_G))));
        createRateCardSetupDetails(subTrancheGMap, flexRateId, PortalConstants.SUB_TRANCHE_G);
        // SUB TRANCHE H
        subTrancheHMap = (Map<String, Object>)Json.deserializeUntyped(String.valueOf(Json.serialize(ratePricingMap.get(PortalConstants.SUB_TRANCHE_H))));
        createRateCardSetupDetails(subTrancheHMap, flexRateId, PortalConstants.SUB_TRANCHE_H);
    }

    /**
    * @description : Called while submitting an application, generates the Flex Pricing Rate card header/detail and calls pricing api
    * @author  Pritam Roy | 03-04-2024 
    * @param applicationId 
    * @param rateCardrequest 
    * @return String 
    **/
    public String createFlexRateCard(
            String applicationId, 
            Map<String, Object> rateCardrequest
        ) {
        // Method specific constant parameters starts
        String flexRateId; 
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();
     
        flexRatingJsonMap = PortalValidationUtil.defaultFlexRateValidation(rateCardrequest, flexRatingJsonMap);
        objRateCardHeader = PortalValidationUtil.validateFlexRateRequest(rateCardrequest, objRateCardHeader, flexRatingJsonMap);
        Boolean shouldValidate = Boolean.valueOf(rateCardrequest.get(PortalConstants.KEY_SHOULD_VALIDATE));

        List<User> objdealerAccountName =  PortalApplicationOriginationHelper.getLoggedInUser();
        //Start by creating a rate card setup header with the borrowers name
        //get borrower name using applicaiton id
        genesis__Applications__c objApplication = [
                        SELECT Id,
                               Name,
                               genesis__Account__r.Name, 
                               CreatedDate,
                               My_Program__c,
                               genesis__Maturity_Date__c,
                               Crop_Year__c
                        FROM genesis__Applications__c
                        WHERE Id = :applicationId
                    ];

        MyProgramUtil.nullCheckException(objApplication, PortalConstants.SOMETHING_WENT_WRONG);                                               
        

        objRateCardHeader = populateRequiredFieldsForFlexRate(objdealerAccountName, objApplication, objRateCardHeader);

        Integer cropYearToValidate;

        cropYearToValidate = Integer.valueOf(objRateCardHeader.Crop_Year__c);
      
        PortalValidationUtil.validateCropYear(cropYearToValidate);

        //check for the payer of loan closing fee
        // objRateCardHeader = PortalValidationUtil.validatePayerOfLoanClosingFee(objRateCardHeader);

        //validate past date in maturity date
        //cropYearToValidate = Integer.valueOf(objRateCardHeader.Crop_Year__c);
        MyProgramValidationUtil.validateMaturityDate(objRateCardHeader,cropYearToValidate);

        if (objRateCardHeader.Id != null) {
            flexRateId = objRateCardHeader.Id;
            objRateCardHeader = deleteExistingRateCardSetupDetails(objRateCardHeader, objApplication.My_Program__c);
            Database.update(objRateCardHeader, true);
        }else{
    
            objRateCardHeader = processNewMyProgram(objRateCardHeader,objdealerAccountName,PortalConstants.FLEXPROGRAM);
            flexRateId = objRateCardHeader.Id;
        }
        
        PortalValidationUtil.validateDeterminingFactors(objRateCardHeader, objdealerAccountName);

        generateCardDetailsForFlexRate(flexRateId);
        //DML on applciation to insert the Flex rating criteria on My Program.
        
        MyProgramUtil.nullCheckException(objApplication, PortalConstants.SOMETHING_WENT_WRONG);
        MyProgramHelper.validateStartDateEverySubTranche(objRateCardHeader);
        CreateMyProgramHandler.updateFlexRateInApplication(objRateCardHeader, objApplication, flexRateId);
        if (shouldValidate) {
            //Generate the pricing detail for the particular application only for Save and Continue
            //genesis.SkuidPricingCtrl.generatePricing(applicationId);
            PortalApplicationOriginationHelper.generateChildLoans(applicationId);
        }
        
        return flexRateId;
        
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
            GMKPortalSaveRateCardDetailsAPI.saveRateCardDetails(subTrancheMap,headerId,subTrancheName);
        }
    }
    /**
    * @description The purpose of this method is to delete all existing flex rate card details.
    * @author Ayan Bhowmik | 08-13-2024 
    * @param objRateCardHeader 
    * @param myProgramId 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    private static genesis__Rate_Card_Setup_Header__c deleteExistingRateCardSetupDetails(genesis__Rate_Card_Setup_Header__c objRateCardHeader, Id myProgramId){
        if(!String.isBlank(myProgramId) && objRateCardHeader.Id != myProgramId ){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        List<genesis__Rate_Card_Setup_Detail__c> existingRCDetailList = [SELECT Id
                                                                            FROM genesis__Rate_Card_Setup_Detail__c
                                                                            WHERE genesis__Rate_Card_Setup_Header__c =: objRateCardHeader.Id];
        if(!existingRCDetailList.isEmpty()){
            Database.delete(existingRCDetailList, true);
        }
        objRateCardHeader.Special_Term_Number__c = PortalConstants.SPECIAL_TERM_A;
        return objRateCardHeader;
    }
}