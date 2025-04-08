/** 
 * @description       : Purpose of this class is to validate different portal inputs
 * @author            : Rahul Gupta | 06-02-2022
 * @group             : 
 * @last modified on  : 03-13-2025
 * @last modified by  : Ayush Kumar Singh
**/
global without sharing class PortalValidationUtil {
    
    
    /**
    * @description 
    * @param collateral 
    * @param shouldValidateReqFields 
    * @param shouldValidatePercentFed 
    * @param response 
    * @return Boolean 
    **/
    public static Boolean isValidCropInformation(clcommon__Collateral__c collateral, 
                                                Boolean shouldValidateReqFields,
                                                Boolean shouldValidatePercentFed,
                                                clcommon.Response response) {
        SavePoint dbSavePoint = Database.setSavepoint();
  
        try {
            
            // Map<String, Object> parsedCrop = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(crop));
  
            // Validate commodity
            if (collateral.clcommon__Collateral_Category__c == null) {
                throw new CustomException(PortalConstants.CROP_COMMODITY_FIELD_MISSING);
            } 
  
            // Validate total acres
            if (shouldValidateReqFields && 
                collateral.Total_Acres__c == null) {
                throw new CustomException(PortalConstants.CROP_TOTAL_ACRES_FIELD_MISSING);
            } else if (collateral.Total_Acres__c != null) {
                if (collateral.Total_Acres__c < 0) {
                    throw new CustomException(PortalConstants.CROP_INVALID_TOTAL_ACRES_VALUE);
                }
            }
            
  
            // Validate producers share percent
            if (shouldValidateReqFields && 
                collateral.Producer_Share_Percent__c == null) {
                throw new CustomException(PortalConstants.CROP_PRODUCER_SHARE_PERCENT_FIELD_MISSING);
            } else if (collateral.Producer_Share_Percent__c != null) {
                if (!PortalRegexUtil.isValidDecimal(String.valueOf(collateral.Producer_Share_Percent__c))) {
                    throw new CustomException(PortalConstants.CROP_INVALID_PRODUCER_SHARE_PERCENT_VALUE);
                } else if (collateral.Producer_Share_Percent__c < 0 || 
                            collateral.Producer_Share_Percent__c > 100) {
                    throw new CustomException(PortalConstants.CROP_INVALID_PRODUCER_SHARE_PERCENT_VALUE);
                }
            }
            
  
            // Validate approved yield
            if (shouldValidateReqFields && 
                collateral.Approved_Yield__c == null) {
                throw new CustomException(PortalConstants.CROP_APPROVED_YIELD_FIELD_MISSING);
            } else if (collateral.Approved_Yield__c != null) {
                if (collateral.Approved_Yield__c < 0) {
                    throw new CustomException(PortalConstants.CROP_INVALID_APPROVED_YIELD_VALUE);
                }
            }
  
            // Validate insurance plan
            if (shouldValidateReqFields && 
                collateral.Insurance_Plan__c == null) {
                throw new CustomException(PortalConstants.CROP_INSURANCE_PLAN_FIELD_MISSING);
            } else if (collateral.Insurance_Plan__c != null && 
                        !PortalRegexUtil.isValidString(String.valueOf(collateral.Insurance_Plan__c))) {
                throw new CustomException(PortalConstants.CROP_INVALID_INSURANCE_PLAN_TYPE);
            } 
  
            // Validate percent coverage level
            if (shouldValidateReqFields && 
                String.isNotBlank(collateral.Insurance_Plan__c) &&
                !collateral.Insurance_Plan__c.equalsIgnoreCase('None') &&
                String.isBlank(collateral.Percent_Coverage_Level__c)) {
                throw new CustomException(PortalConstants.CROP_PERCENT_COVERAGE_LEVEL_FIELD_MISSING);
            } else if (String.isNotBlank(collateral.Percent_Coverage_Level__c) && 
                        !PortalRegexUtil.isValidString(String.valueOf(collateral.Percent_Coverage_Level__c))) {
                throw new CustomException(PortalConstants.CROP_INVALID_PERCENT_COVERAGE_LEVEL_TYPE);
            }
  
            // Validate percent fed
            if (shouldValidatePercentFed) {
                if (shouldValidateReqFields && 
                    collateral.Percent_Fed__c == null) {
                    throw new CustomException(PortalConstants.CROP_PERCENT_FED_FIELD_MISSING);
                } else if (collateral.Percent_Fed__c != null) {
                    if (!PortalRegexUtil.isValidDecimal(String.valueOf(collateral.Percent_Fed__c))) {
                        throw new CustomException(PortalConstants.CROP_INVALID_PERCENT_FED_VALUE);
                    } else if (collateral.Percent_Fed__c < 0 || 
                                collateral.Percent_Fed__c > 100) {
                        throw new CustomException(PortalConstants.CROP_INVALID_PERCENT_FED_VALUE);
                    }
                }
            }
  
            return true;
  
        } catch (CustomException e) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = e.getMessage();
        } 
  
        return false;
    }
   
    /**
    * @description 
    * @param paramMap
    **/
    public static void isValidApplicationCreation(Map<String,Object> paramMap) {
        genesis__Applications__c applicationObj=(genesis__Applications__c) paramMap.get(PortalConstants.APPLICATION_OBJ_KEY); 
        Contact contactObj=(Contact)paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        Account accountObj=(Account)paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY); 
        genesis__Business_Information__c businessInformationObj=(genesis__Business_Information__c)paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY); 
        String shouldValidate=(String) paramMap.get(PortalConstants.KEY_SHOULD_VALIDATE);
        clcommon__Party__c borrowerPartyObj=(clcommon__Party__c) paramMap.get(PortalConstants.BORROWER_PARTY_KEY);

        String coopType=PortalConstants.EMPTY_STRING;
        String legalEntity=PortalConstants.EMPTY_STRING;
        Account loggedInAccount=new Account();

        PortalApplicationOriginationHelper.throwErrorIfFalse(applicationObj.genesis__Loan_Amount__c != null, PortalConstants.APPL_LOAN_AMOUNT_MISSING);
        PortalApplicationOriginationHelper.throwErrorIfFalse(applicationObj.genesis__Loan_Amount__c > 0, PortalConstants.APPL_LOAN_AMOUNT_MISSING);
        
        loggedInAccount = PortalApplicationOriginationHelper.getLoggedInAccount();

        coopType=getCoopType(loggedInAccount);


        if(!String.isBlank(accountObj.clcommon__Legal_Entity_Type__c)){
            legalEntity = PortalApplicationOriginationHelper.getLegalEntityByAccount(accountObj);
        } 

        if(shouldValidate == PortalConstants.NEW_APPLICANT | shouldValidate == PortalConstants.SAVE_AND_EXIT){

            PortalApplicationOriginationHelper.checkBlankParameter(accountObj.clcommon__Legal_Entity_Type__c, PortalConstants.APPL_ENTITY_TYPE_MISSING);

            validateNameOfApplicant(contactObj,accountObj);

            validateSSNAndTaxId(new Map<String,String>{ PortalConstants.LEGAL_ENTITY_NAME_KEY => legalEntity,
                                                        PortalConstants.COOP_TYPE_KEY => coopType},
                                contactObj,businessInformationObj);
        }
        else if(shouldValidate == PortalConstants.EXISTING_APPLICANT){
            PortalApplicationOriginationHelper.checkBlankParameter(accountObj.id, PortalConstants.APPL_EXISTING_BORROWER_MISSING);

        }
        if(shouldValidate == PortalConstants.SAVE_AND_CONTINUE){
            if(legalEntity == PortalConstants.INDIVIDUAL 
                    | legalEntity == PortalConstants.SOLE_PROP_ENTITY){
            
                    PortalApplicationOriginationHelper.checkBlankParameter(contactObj.FirstName, PortalConstants.APPL_FIRST_NAME_MISSING);
                    PortalApplicationOriginationHelper.checkBlankParameter(borrowerPartyObj.Street__c, PortalConstants.APPL_ADDRESS_MISSING);
                    PortalApplicationOriginationHelper.checkBlankParameter(borrowerPartyObj.City__c, PortalConstants.APPL_CITY_MISSING);
                    PortalApplicationOriginationHelper.checkBlankParameter(borrowerPartyObj.State__c, PortalConstants.APPL_STATE_MISSING);
                    PortalApplicationOriginationHelper.checkBlankParameter(borrowerPartyObj.Postal_Code__c, PortalConstants.APPL_ZIP_CODE_MISSING);
                    PortalApplicationOriginationHelper.checkBlankParameter(borrowerPartyObj.County__c, PortalConstants.APPL_COUNTY_MISSING);
                    PortalApplicationOriginationHelper.checkBlankParameter(contactObj.genesis__SSN__c, PortalConstants.APPL_SSN_MISSING);
                    PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(contactObj.Birthdate), PortalConstants.APPL_DATE_OF_BIRTH_MISSING);
                    PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(borrowerPartyObj.Marital_Status__c), PortalConstants.APPL_MARITAL_STATUS_MISSING);
                    
                    validateSSNAndTaxIdLength(contactObj.genesis__SSN__c,PortalConstants.INVALID_SSN);
                    validatePostalCodeLength(borrowerPartyObj);

                    validateApplicantContactInfo(new Map<String,String>{
                                                                    PortalConstants.WORK_NUMBER_KEY => String.valueOf(borrowerPartyObj.Work_Number__c),
                                                                    PortalConstants.HOME_NUMBER_KEY => String.valueOf(borrowerPartyObj.Home_Number__c),
                                                                    PortalConstants.MOBILE_NUMBER_KEY => String.valueOf(borrowerPartyObj.Mobile_Number__c)
                                                                }, PortalConstants.APPL_MOBILE_MISSING);
                    
            } else if (legalEntity == PortalConstants.INDIVIDUAL_ENTITY) {
                PortalApplicationOriginationHelper.checkBlankParameter(accountObj.Name, PortalConstants.APPL_NAME_MISSING);
            }
            else{
                
                PortalApplicationOriginationHelper.checkBlankParameter(accountObj.Name, PortalConstants.APPL_NAME_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(borrowerPartyObj.Street__c, PortalConstants.APPL_ADDRESS_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(borrowerPartyObj.City__c, PortalConstants.APPL_CITY_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(borrowerPartyObj.State__c, PortalConstants.APPL_STATE_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(borrowerPartyObj.Postal_Code__c, PortalConstants.APPL_ZIP_CODE_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(borrowerPartyObj.County__c, PortalConstants.APPL_COUNTY_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(businessInformationObj.genesis__Tax_Identification_Number__c, PortalConstants.APPL_TAX_ID_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(businessInformationObj.genesis__State_of_Incorporation__c, PortalConstants.STATE_OF_INCORPORATION_MISSING);

                validateSSNAndTaxIdLength(businessInformationObj.genesis__Tax_Identification_Number__c,PortalConstants.INVALID_TAX_ID);


                validatePostalCodeLength(borrowerPartyObj);

                validateApplicantContactInfo(new Map<String,String>{
                                                                PortalConstants.WORK_NUMBER_KEY => String.valueOf(borrowerPartyObj.Work_Number__c),
                                                                PortalConstants.HOME_NUMBER_KEY => String.valueOf(borrowerPartyObj.Home_Number__c),
                                                                PortalConstants.MOBILE_NUMBER_KEY => String.valueOf(borrowerPartyObj.Mobile_Number__c)
                                                            }, PortalConstants.APPL_MOBILE_MISSING);

                
            }
            validateBusinessAssetsAndLiabilities(businessInformationObj, PortalConstants.APPL_TOTAL_ASSETS_MISSING, PortalConstants.APPL_TOTAL_LIABILITIES_MISSING);
        }
    }

    /**
     * @description 
     * @param ssn 
     * @param exceptionName 
     * @exception 
     */
    public static void validateSSNAndTaxIdLength(String ssn, String exceptionName){
        if (String.valueOf(ssn).length()!= 9 || !String.valueOf(ssn).isNumeric()) {
            throw new CustomException(exceptionName);
        }
    }
    /**
    * @description
    * @author Krishanu Chinya | 03-05-2024 
    * @param paramMap
    **/
    public static void isValidCoApplicationCreation(Map<String,Object> paramMap) {
        Contact contactObj=(Contact)paramMap.get(PortalConstants.CONTACT_OBJ_KEY);
        Account accountObj=(Account)paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY); 
        genesis__Business_Information__c businessInformationObj=(genesis__Business_Information__c)paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY); 
        String shouldValidate=(String) paramMap.get(PortalConstants.KEY_SHOULD_VALIDATE);
        clcommon__Party__c borrowerPartyObj=(clcommon__Party__c) paramMap.get(PortalConstants.BORROWER_PARTY_KEY);

        if(String.isBlank(contactObj.LastName) && String.isBlank(accountObj.Name)){
            throw new CustomException(PortalConstants.CO_APPL_LAST_NAME_MISSING);
        }

        if(shouldValidate == PortalConstants.SAVE_AND_CONTINUE){
            PortalApplicationOriginationHelper.checkBlankParameter(contactObj.FirstName, PortalConstants.CO_APPL_FIRST_NAME_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(borrowerPartyObj.Street__c, PortalConstants.CO_APPL_ADDRESS_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(borrowerPartyObj.City__c, PortalConstants.CO_APPL_CITY_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(borrowerPartyObj.State__c, PortalConstants.CO_APPL_STATE_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(borrowerPartyObj.Postal_Code__c, PortalConstants.CO_APPL_ZIP_CODE_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(borrowerPartyObj.County__c, PortalConstants.CO_APPL_COUNTY_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(contactObj.genesis__SSN__c, PortalConstants.CO_APPL_SSN_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(contactObj.Birthdate), PortalConstants.CO_APPL_DATE_OF_BIRTH_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(borrowerPartyObj.Marital_Status__c, PortalConstants.CO_APPL_MARITAL_STATUS_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(contactObj.Confirm_SSN__c, PortalConstants.CO_APPL_SSN_MISSING);

            validateSSNAndTaxIdLength(contactObj.genesis__SSN__c,PortalConstants.INVALID_SSN);
            validatePostalCodeLength(borrowerPartyObj);

            validateApplicantContactInfo(new Map<String,String>{
                                                        PortalConstants.WORK_NUMBER_KEY => String.valueOf(borrowerPartyObj.Work_Number__c),
                                                        PortalConstants.HOME_NUMBER_KEY => String.valueOf(borrowerPartyObj.Home_Number__c),
                                                        PortalConstants.MOBILE_NUMBER_KEY => String.valueOf(borrowerPartyObj.Mobile_Number__c)
                                                    }, PortalConstants.APPL_MOBILE_MISSING_COAPPLICANT);

            validateBusinessAssetsAndLiabilities(businessInformationObj, PortalConstants.CO_APPL_TOTAL_ASSETS_MISSING, PortalConstants.CO_APPL_TOTAL_LIABILITIES_MISSING);
        }
    }

   
    /**
    * @description 
    * @param objContact 
    * @param objAccount 
    * @return Contact 
    **/
    public static Contact validateDuplicateIndividual(Contact objContact, Account objAccount) {
         return objContact;
    }

    /**
     * @description validateDuplicateCoop description
     * @param  objBusinessInfo objBusinessInfo description
     * @param  objAccount      objAccount description
     * @param  objContact      objContact description
     */ 
    public static void validateDuplicateCoop(
                     genesis__Business_Information__c objBusinessInfo, 
                     Account objAccount, 
                     Contact objContact
                 ) {
                    return;
        
    }

    /**
    * @description 
    * @param objAccount 
    * @param objContact 
    **/
    public static void validateDuplicateDBACoop(Account objAccount, Contact objContact) {
        return;                                   
    }
    //this method is commented by krishanu 
    //as these are the old duplicate check methods, 
    //which don't have any coverage and will not be used



    // My program validation methods --------------------

    /**
    * @description 
    * @param rateCardrequest 
    * @param flexRatingJsonMap 
    * @return Map<String, Object> 
    **/
    public static Map<String, Object> defaultFlexRateValidation(Map<String, Object> rateCardrequest, Map<String, Object> flexRatingJsonMap) {
        String flexRateStr = '';
        // Integer differenceInDays;
        // Map<String, Object> flexRatingJsonMap = new Map<String, Object>();
        // Map<String, Object> flexRateProgramMap = new Map<String, Object>();
        // Method specific declaration ends
        if (rateCardrequest.get(PortalConstants.FLEXPRICING) == null) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        if (rateCardrequest.get(PortalConstants.KEY_SHOULD_VALIDATE) == null) {
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
        // Boolean shouldValidate = Boolean.valueOf(rateCardrequest.get(PortalConstants.KEY_SHOULD_VALIDATE));
        flexRateStr = String.valueOf(rateCardrequest.get(PortalConstants.FLEXPRICING));
        if (String.isNotBlank(flexRateStr)) {
            flexRatingJsonMap = (Map<String, Object>)JSON.deserializeUntyped(flexRateStr);
        }

        return flexRatingJsonMap;
    }


    /**
    * @description 
    * @param rateCardrequest 
    * @param objRateCardHeader 
    * @param flexRatingJsonMap 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    public static genesis__Rate_Card_Setup_Header__c validateFlexRateRequest(
            Map<String, Object> rateCardrequest, 
            genesis__Rate_Card_Setup_Header__c objRateCardHeader, 
            Map<String, Object> flexRatingJsonMap
        ) {
        Map<String, Object> flexRateProgramMap = new Map<String, Object>();
        // Method specific declaration ends
        //Rate Card Header for Flex Rate
        
        if (flexRatingJsonMap.get(PortalConstants.FLEXPROGRAM) == null) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        flexRateProgramMap = 
            (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(flexRatingJsonMap.get(PortalConstants.FLEXPROGRAM)));
        //null check for the necessary fields
        

        nullCheckForFlexRateRequest(flexRateProgramMap);

        objRateCardHeader.Crop_Year__c = (String)flexRateProgramMap.get(PortalConstants.FIELD_CROP_YEAR);
        if (flexRateProgramMap.get(PortalConstants.FIELD_FS_IDX) != null) {
            objRateCardHeader.FS_Index_Rate__c = (Decimal)flexRateProgramMap.get(PortalConstants.FIELD_FS_IDX);
        }
        if (flexRateProgramMap.get(PortalConstants.FIELD_CLOSING_FEE) != null) {
            objRateCardHeader.Closing_Fee__c = (Decimal)flexRateProgramMap.get(PortalConstants.FIELD_CLOSING_FEE);
        }
        if (flexRateProgramMap.get(PortalConstants.FIELD_MATURITY_DATE) != null) {
            objRateCardHeader.genesis__End_Date__c = Date.valueOf((String)flexRateProgramMap.get(PortalConstants.FIELD_MATURITY_DATE));
        }
        objRateCardHeader.Payer_of_Loan_Closing_Fee__c = (String)flexRateProgramMap.get(PortalConstants.FIELD_PAYER);
        if ((String)flexRateProgramMap.get(PortalConstants.FIELD_PAYER) == PortalConstants.GROWER_PROFILE) {
            objRateCardHeader.Loan_Fee_Advanced_On__c = 
                    (String)flexRateProgramMap.get(PortalConstants.FIELD_ADVANCEON);
            objRateCardHeader.Dealer_Participate_on_Closing_Fee__c = 
                    (String)flexRateProgramMap.get(PortalConstants.FIELD_DEALER_PART);

            if (flexRateProgramMap.get(PortalConstants.FIELD_DEALER_PART) == PortalConstants.AFFIRMATIVE &&
                flexRateProgramMap.get(PortalConstants.FIELD_FEE_PORTION) != null) {
                objRateCardHeader.Portion_of_Fee_to_Cover__c = 
                        (Decimal)flexRateProgramMap.get(PortalConstants.FIELD_FEE_PORTION);
            }
        }
        //Inside flexRatingJsonMap we have my program Id, rateCard list
        String myProgramId = (String)flexRateProgramMap.get(PortalConstants.FIELD_ID);

        objRateCardHeader.Id = (myProgramId == null || myProgramId == PortalConstants.NEW_RECORD_STRING) ? null : myProgramId;

        return objRateCardHeader;
    }

    /**
    * @description 
    * @param request 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    public static genesis__Rate_Card_Setup_Header__c validateMyProgramRequest(Map<String, Object> request) {
        genesis__Rate_Card_Setup_Header__c objRateCardHeader = new genesis__Rate_Card_Setup_Header__c();

        if (request.get(PortalConstants.PROGRAM) == null) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        String myProgram = String.valueOf(request.get(PortalConstants.PROGRAM));
        if (String.isNotBlank(myProgram)) {
            objRateCardHeader = 
            (genesis__Rate_Card_Setup_Header__c) JSON.deserialize(myProgram, genesis__Rate_Card_Setup_Header__c.class);
        }
        if (objRateCardHeader.get(PortalConstants.FIELD_CROP_YEAR) == null ||
            objRateCardHeader.get(PortalConstants.FIELD_NAME) == null ||
            objRateCardHeader.get(PortalConstants.FIELD_MATURITY_DATE) == null ||
            objRateCardHeader.get(PortalConstants.FIELD_PAYER) == null
        ) {  
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }

        if (objRateCardHeader.get(PortalConstants.FIELD_ID) == null) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        if (objRateCardHeader.get(PortalConstants.FIELD_PAYER) == PortalConstants.GROWER_PROFILE) {
            if (objRateCardHeader.get(PortalConstants.FIELD_ADVANCEON) == null ||
                objRateCardHeader.get(PortalConstants.FIELD_DEALER_PART) == null) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            if (objRateCardHeader.get(PortalConstants.FIELD_DEALER_PART) == PortalConstants.AFFIRMATIVE 
                && objRateCardHeader.get(PortalConstants.FIELD_FEE_PORTION) == null) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
        }
        return objRateCardHeader;
    }
    
    /**
    * @description validates crop year
    * @author Soumik Pattanayak | 08-10-2024 
    * @param cropYearToValidate 
    **/
    public static void validateCropYear(Integer cropYearToValidate) {
        ////------------------Crop Year Validation----------------------
        if (PortalConstants.STRING_JAN_TO_MAY.Contains(String.valueOf(System.today().month()))) {
            //January to May
            //Crop year must be current year
            if (cropYearToValidate != System.today().Year()) {
                throw new CustomException(PortalConstants.CROP_YEAR_ELIGIBLE_ERROR_JAN_MAY);
            }
        }
        if (PortalConstants.STRING_JUN_TO_AUG.Contains(String.valueOf(System.today().month()))) {
            //June to August
            //Check for the crop year(Current year and next year)
            if (cropYearToValidate != System.today().Year() && cropYearToValidate != System.today().Year() + 1) {
                throw new CustomException(PortalConstants.CROP_YEAR_ELIGIBLE_ERROR_JUN_AUG);
            }
        }
        if (PortalConstants.STRING_SEP_TO_DEC.Contains(String.valueOf(System.today().month()))) {
            //September to December
            //Check for the crop year(next year)
            if (cropYearToValidate != System.today().Year() + 1) {
                throw new CustomException(PortalConstants.CROP_YEAR_ELIGIBLE_ERROR_SEP_DEC);
            }
        }
        ////------------------Crop Year Validation-------------------------
    }


    /**
    * @description 
    * @param flexRateProgramMap 
    **/
    public static void nullCheckForFlexRateRequest(Map<String, Object> flexRateProgramMap) {
        //null check for the necessary fields
        if (flexRateProgramMap.get(PortalConstants.FIELD_CROP_YEAR) == null ||
            flexRateProgramMap.get(PortalConstants.FIELD_MATURITY_DATE) == null ||
            flexRateProgramMap.get(PortalConstants.FIELD_PAYER) == null
            ) {  
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
        if (flexRateProgramMap.get(PortalConstants.FIELD_PAYER) == PortalConstants.GROWER_PROFILE) {
            if (flexRateProgramMap.get(PortalConstants.FIELD_ADVANCEON) == null ||
                flexRateProgramMap.get(PortalConstants.FIELD_DEALER_PART) == null) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            if (flexRateProgramMap.get(PortalConstants.FIELD_DEALER_PART) == PortalConstants.AFFIRMATIVE) {
                if (flexRateProgramMap.get(PortalConstants.FIELD_FEE_PORTION) == null) {
                    throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
                }
            }
        }
    }

    // public static genesis__Rate_Card_Setup_Header__c validatePayerOfLoanClosingFee(genesis__Rate_Card_Setup_Header__c objRateCardHeader) {
    //     if (objRateCardHeader.Payer_of_Loan_Closing_Fee__c == PortalConstants.DEALER_PROFILE) {
    //         //If Dealer is chosen for paying the loan closing fee
    //         objRateCardHeader.Loan_Fee_Advanced_On__c = null;
    //         objRateCardHeader.Dealer_Participate_on_Closing_Fee__c = PortalConstants.NEGATIVE_STRING;
    //         objRateCardHeader.Portion_of_Fee_to_Cover__c = 0;
    //     }
    //     else if (objRateCardHeader.Portion_of_Fee_to_Cover__c > objRateCardHeader.Closing_Fee__c) {
    //         //If grower is chosen to pay the loan closing fee
            
    //         throw new CustomException(PortalConstants.CLOSING_FEE_EXCEEDED);
    //         // }
    //     }

    //     return objRateCardHeader;
    // }

    /**
    * @description 
    * @param objRateCardHeader 
    * @param objdealerAccountName 
    **/
    public static void validateDeterminingFactors(genesis__Rate_Card_Setup_Header__c objRateCardHeader, List<User> objdealerAccountName) {
        genesis__Additional_Determining_Factor__c objFactorDetail = new genesis__Additional_Determining_Factor__c();
        genesis__Additional_Determining_Factor__c objFactorDetailDealer = new genesis__Additional_Determining_Factor__c();

        objFactorDetail = [
                    SELECT Id, 
                           genesis__Field_Value__c, 
                           genesis__Rate_Card_Setup_Header__c
                    FROM genesis__Additional_Determining_Factor__c 
                    WHERE genesis__Field_Value__c = :objRateCardHeader.Name AND
                        genesis__Rate_Card_Setup_Header__c = :objRateCardHeader.Id
                    LIMIT 1
                ];
        if (objdealerAccountName.size() > 0) {
            objFactorDetailDealer = [
                        SELECT Id, 
                               genesis__Field_Value__c, 
                               genesis__Rate_Card_Setup_Header__c
                        FROM genesis__Additional_Determining_Factor__c 
                        WHERE genesis__Field_Value__c = :objdealerAccountName[0].Account.Parent.Name AND
                            genesis__Rate_Card_Setup_Header__c = :objRateCardHeader.Id
                        LIMIT 1
                    ];
        }
        /*generating the rate card setup detail for the FLEX PRICING from the Portal*/
        //fetching the flex rate in a string
        if (objFactorDetail == null || objFactorDetailDealer == null) {
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
    }

    /**
    * @description validates rate card details
    * @author Soumik Pattanayak | 08-10-2024 
    * @param setupDescription 
    * @param objRateCardDetailList 
    **/
    public static void validateRateCardDetails(String setupDescription, List<Object> objRateCardDetailList) {
        if (String.isBlank(setupDescription) && objRateCardDetailList.size() > 0) {
            throw new CustomException(PortalConstants.DESCRIPTION_ERROR);
        }

        if (objRateCardDetailList.size() > PortalConstants.MAXIMUM_SPECIAL_TRANCHES_NUMBER){
            throw new CustomException(PortalConstants.MAXIMUM_SPL_TRANCHES);
        }
    }


    //--------------------------------------------------------------------------------------------------------------------------
    // NEW VALIDATION RULES STARTS HERE

   
    /**
    * @description : validates all application data is present or not
    * @author Krishanu Chinya | 02-09-2024 
    * @param paramForValidationMap 
    **/
    public static void validateApplicationData(Map<String, Object> paramForValidationMap) {
        Account accountObj = (Account)paramForValidationMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        Contact contactObj = (Contact)paramForValidationMap.get(PortalConstants.CONTACT_OBJ_KEY);
        String shouldValidate = (String)paramForValidationMap.get(PortalConstants.KEY_SHOULD_VALIDATE);
        genesis__applications__c applicationObj = (genesis__Applications__c)paramForValidationMap.get(PortalConstants.APPLICATION_OBJ_KEY);
        genesis__Business_Information__c businessInfoObj = (genesis__Business_Information__c)paramForValidationMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        clcommon__party__c borrowerPartyObj = (clcommon__party__c)paramForValidationMap.get(PortalConstants.BORROWER_PARTY_NAME);

        String legalEntity = PortalConstants.EMPTY_STRING;
        String coopType;

        PortalApplicationOriginationHelper.throwErrorIfFalse(applicationObj.genesis__Loan_Amount__c != null, PortalConstants.APPL_LOAN_AMOUNT_MISSING);
        PortalApplicationOriginationHelper.throwErrorIfFalse(applicationObj.genesis__Loan_Amount__c >=0, PortalConstants.APPL_LOAN_AMOUNT_MISSING);

        //create a method in origination helper
        Account loggedInAccount = PortalApplicationOriginationHelper.getLoggedInAccount();
        //fetching the coop type
        coopType = getCoopType(loggedInAccount);
        
        //fetching the current legal entity 
        if(!String.isBlank(accountObj.clcommon__Legal_Entity_Type__c)){
            legalEntity = PortalApplicationOriginationHelper.getLegalEntityByAccount(accountObj);
        }

        PortalApplicationOriginationHelper.throwErrorIfFalse(contactObj.genesis__SSN__c == contactObj.Confirm_SSN__c, PortalConstants.SSN_CONFIRM_SSN_MISMATCH);
      
        if(shouldValidate == PortalConstants.NEW_APPLICANT || shouldValidate == PortalConstants.SAVE_AND_EXIT){
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(accountObj.clcommon__Legal_Entity_Type__c),PortalConstants.APPL_ENTITY_TYPE_MISSING);
            validateNameOfApplicant(contactObj,accountObj);   
            Map<String, String> entityCoopDetailsMap = new Map<String, String>{
                PortalConstants.LEGAL_ENTITY_NAME_KEY => legalEntity,
                PortalConstants.COOP_TYPE_KEY => coopType
            };
            validateSSNAndTaxId(entityCoopDetailsMap, contactObj, businessInfoObj);
            
        }
        if(shouldValidate == PortalConstants.EXISTING_APPLICANT){
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(accountObj.Id),PortalConstants.APPL_ENTITY_TYPE_MISSING);
        }
        if(shouldValidate == PortalConstants.SAVE_AND_CONTINUE){
            //for individual sole prop
            if(legalEntity == PortalConstants.SOLE_PROP_ENTITY){
                
                PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(contactObj.FirstName), PortalConstants.APPL_FIRST_NAME_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(borrowerPartyObj.Street__c), PortalConstants.APPL_ADDRESS_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(borrowerPartyObj.City__c), PortalConstants.APPL_CITY_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(borrowerPartyObj.State__c), PortalConstants.APPL_STATE_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(borrowerPartyObj.County__c), PortalConstants.APPL_COUNTY_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(borrowerPartyObj.Postal_Code__c), PortalConstants.APPL_ZIP_CODE_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(borrowerPartyObj.Marital_Status__c), PortalConstants.APPL_MARITAL_STATUS_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(contactObj.genesis__SSN__c), PortalConstants.APPL_SSN_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(contactObj.Confirm_SSN__c), PortalConstants.APPL_CONFIRM_SSN_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(contactObj.Birthdate), PortalConstants.APPL_DATE_OF_BIRTH_MISSING);

                validatePostalCodeLength(borrowerPartyObj);
        
                validateApplicantContactInfo(new Map<String,String>{
                                                                PortalConstants.WORK_NUMBER_KEY => String.valueOf(borrowerPartyObj.Work_Number__c),
                                                                PortalConstants.HOME_NUMBER_KEY => String.valueOf(borrowerPartyObj.Home_Number__c),
                                                                PortalConstants.MOBILE_NUMBER_KEY => String.valueOf(borrowerPartyObj.Mobile_Number__c)
                                                            }, PortalConstants.APPL_MOBILE_MISSING);
            }
            //for DBA 
            else if (legalEntity == PortalConstants.INDIVIDUAL_ENTITY) {
                PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(accountObj.Name),PortalConstants.APPL_NAME_MISSING);
            }
            //for company
            else{
                
                PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(accountObj.Name),PortalConstants.APPL_NAME_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(borrowerPartyObj.State__c), PortalConstants.APPL_STATE_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(businessInfoObj.genesis__Tax_Identification_Number__c), PortalConstants.APPL_TAX_ID_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(borrowerPartyObj.Street__c), PortalConstants.APPL_ADDRESS_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(borrowerPartyObj.City__c), PortalConstants.APPL_CITY_MISSING);
                PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(borrowerPartyObj.Postal_Code__c), PortalConstants.APPL_ZIP_CODE_MISSING);
                validateSSNAndTaxId(new Map<String, String>{
                                                        PortalConstants.LEGAL_ENTITY_NAME_KEY => legalEntity,
                                                        PortalConstants.COOP_TYPE_KEY => coopType
                                                    }, contactObj, businessInfoObj);

                validatePostalCodeLength(borrowerPartyObj);
                PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(borrowerPartyObj.County__c), PortalConstants.APPL_COUNTY_MISSING);
                validateApplicantContactInfo(new Map<String,String>{
                                                            PortalConstants.WORK_NUMBER_KEY => String.valueOf(borrowerPartyObj.Work_Number__c),
                                                            PortalConstants.HOME_NUMBER_KEY => String.valueOf(borrowerPartyObj.Home_Number__c),
                                                            PortalConstants.MOBILE_NUMBER_KEY => String.valueOf(borrowerPartyObj.Mobile_Number__c)
                                                        }, PortalConstants.APPL_MOBILE_MISSING);
            }
            validateBusinessAssetsAndLiabilities(businessInfoObj, PortalConstants.APPL_TOTAL_ASSETS_MISSING, PortalConstants.APPL_TOTAL_LIABILITIES_MISSING);
        }
    }

    /** 
     * @description 
     * @param contactObj 
     * @param accountObj 
     * @exception 
     */
    public static void validateNameOfApplicant(Contact contactObj, Account accountObj){
        if(String.isBlank(contactObj.LastName) && String.isBlank(accountObj.Name)){
            throw new CustomException(PortalConstants.APPL_NAME_MISSING);
        }
    }

    /**
     * @description 
     * @param contactInfoMap 
     * @param exceptionName 
     * @exception 
     */
    public static void validateApplicantContactInfo(Map<String, String> contactInfoMap, String exceptionName){
        if(String.isBlank(contactInfoMap.get(PortalConstants.WORK_NUMBER_KEY)) 
            && String.isBlank(contactInfoMap.get(PortalConstants.HOME_NUMBER_KEY)) 
            && String.isBlank(contactInfoMap.get(PortalConstants.MOBILE_NUMBER_KEY))){

            throw new CustomException(exceptionName);
        }
    }
    /**
     * @description 
     * @param entityCoopDetailsMap 
     * @param contactObj 
     * @param businessInfoObj 
     * @exception 
     */
    public static void validateSSNAndTaxId(Map<String, String> entityCoopDetailsMap, Contact contactObj, genesis__Business_Information__c businessInfoObj){
        //if individual sole prop
        String legalEntityObj = entityCoopDetailsMap.get(PortalConstants.LEGAL_ENTITY_NAME_KEY);
        String coopType = entityCoopDetailsMap.get(PortalConstants.COOP_TYPE_KEY);

        if(legalEntityObj == PortalConstants.SOLE_PROP_ENTITY){
            //for cfa, landus -  ssn is compulsory at this shoudValidate state
            if(coopType != PortalConstants.GROWMARK_COOP_TYPE && String.isBlank(contactObj.genesis__SSN__c)){
                throw new CustomException(PortalConstants.APPL_SSN_MISSING);
            }
        }
        //if company 
        else if (legalEntityObj != PortalConstants.INDIVIDUAL_ENTITY) {
            if(coopType != PortalConstants.GROWMARK_COOP_TYPE && String.isBlank(businessInfoObj.genesis__Tax_Identification_Number__c)){
                throw new CustomException(PortalConstants.APPL_TAX_ID_MISSING);
            }
        }
    }

    /**
     * @description 
     * @param loggedInAccount 
     * @return  `String`
     */
    public static String getCoopType(Account loggedInAccount){
        String coopType;
        if (loggedInAccount.RecordType.Name == PortalConstants.GROWER_PROFILE || 
                    loggedInAccount.RecordType.Name == PortalConstants.CO_APPLICATION_RECORD_TYPE) {
            // get the grower coop type
            coopType = loggedInAccount.Coop_Type__c == null ? PortalConstants.CFA_COOP_TYPE : loggedInAccount.Coop_Type__c;
        } 
        else {
            // get the dealer coop type
            coopType = loggedInAccount.Parent.Coop_Type__c == null ? PortalConstants.CFA_COOP_TYPE : loggedInAccount.Parent.Coop_Type__c;
        }
        return coopType;
    }

   /**
    * @description 
    * @param businessInfoObj 
    * @param exceptionForAsset 
    * @param exceptionForLiability 
    * @exception 
    */
    public static void validateBusinessAssetsAndLiabilities(genesis__Business_Information__c businessInfoObj, String exceptionForAsset, String exceptionForLiability){
        if(businessInfoObj.genesis__Total_Assets__c < 0){
            throw new CustomException(exceptionForAsset);
        }
        if(businessInfoObj.genesis__Total_Liabilities__c < 0){
            throw new CustomException(exceptionForLiability);
        }
    }

    /**
     * @description 
     * @param borrowerPartyObj 
     * @exception 
     */
    public static void validatePostalCodeLength(clcommon__party__c borrowerPartyObj ){
        if(String.valueOf(borrowerPartyObj.Postal_Code__c).length()!=5 
                        && String.valueOf(borrowerPartyObj.Postal_Code__c).length()!=9){
            throw new CustomException(PortalConstants.APPL_ZIP_CODE_INVALID);
        }
    }

    /**
     * @description 
     * @param applicantContact 
     * @exception 
     */
    public static void validatePostalCodeLength(Contact applicantContact){
        if(String.valueOf(applicantContact.MailingPostalCode).length()!=5 
                        && String.valueOf(applicantContact.MailingPostalCode).length()!=9){
            throw new CustomException(PortalConstants.APPL_ZIP_CODE_INVALID);
        }
    }

    /**
    * @description : validates whether an individual exist with the same ssn or not while adding a borrower
    * @author Krishanu Chinya | 02-09-2024 
    * @param contactObj 
    * @param dealerCoopType 
    * @param dealerId 
    * @return Contact 
    **/
    public static Contact validateNewGrower(Contact contactObj, String dealerCoopType, String dealerId){
        if(String.isBlank(contactObj.genesis__SSN__c)){
            return contactObj;
        }

        List<Contact> contactList = [SELECT Id,
                                            Email, 
                                            genesis__SSN__c, 
                                            Account.clcommon__Legal_Entity_Type__c,
                                            Account.clcommon__Legal_Entity_Type__r.Name,
                                            Account.RecordTypeId,
                                            Account.RecordType.Name,
                                            AccountId,
                                            Account.ParentId,
                                            Account.Coop_Type__c,
                                            Account.genesis__business_information__c
                                    FROM Contact
                                    WHERE genesis__SSN__c = :contactObj.genesis__SSN__c];

        if(contactList.isEmpty()){
            return contactObj;
        }

        List<Dealer_Applicant_Relationship__c> dealerGrowerRelList=[SELECT ID 
                                                                    FROM Dealer_Applicant_Relationship__c
                                                                    WHERE Applicant_Contact__c=:contactList[0].Id
                                                                    AND Dealer__c=:dealerId];

        if(!dealerGrowerRelList.isEmpty()
                & contactList[0].Account.RecordTypeId==Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId() ){
                    throw new CustomException(PortalConstants.USER_EXIST_IN_SAME_DEALER);
        }

        //same dealer check
        if(dealerId == contactList[0].Account.ParentId){
            
            //grower - recordType: grower, legalEntity: sole prop
            //coapp - recordType: coapplicant, legalEntity: sole prop
            //spouse, etc - recordType: spouse, landowner, legalEntity: null
            
            //checking if it existed as an individual grower
            if(contactList[0].Account.RecordTypeId==Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.GROWER_PROFILE).getRecordTypeId()
                    & contactList[0].Account.clcommon__Legal_Entity_Type__r.Name ==PortalConstants.SOLE_PROP_ENTITY){
                throw new CustomException(PortalConstants.USER_EXIST_IN_SAME_DEALER);
            }
            // if existed as coapplicant , spouse
            //use same account contact
            else{
                contactObj.Id = contactList[0].Id;
                contactObj.AccountId = contactList[0].AccountId;
            }
        }
        //different dealer
        else{
            //use same account and contact
            contactObj.Id = contactList[0].Id;
            contactObj.AccountId = contactList[0].AccountId;
        }

        return contactObj;
    }

    /**
    * @description : validates whether an individual exist with the same ssn or not while adding a coapplicant
    * @author Krishanu Chinya | 03-05-2024 
    * @param contactObj 
    * @param dealerCoopType 
    **/
    public static void validateNewCoApplicant(Contact contactObj, String dealerCoopType) {
        if(String.isBlank(contactObj.genesis__SSN__c)){
            return;
        }

        //if a contact exists with the same ssn as the the one entered, then irrespective of the coop type, we will assign that id of the exisitng contact to this one.
        List<Contact> contactList = [SELECT Id,
                                            Email, 
                                            genesis__SSN__c, 
                                            Account.clcommon__Legal_Entity_Type__c,
                                            Account.clcommon__Legal_Entity_Type__r.Name,
                                            Account.genesis__Business_Information__c,
                                            Account.RecordTypeId,
                                            Account.RecordType.Name,
                                            AccountId,
                                            Account.ParentId,
                                            Account.Coop_Type__c
                                    FROM Contact
                                    WHERE genesis__SSN__c = :contactObj.genesis__SSN__c];

        if(!contactList.isEmpty()){
            //use same account and contact
            contactObj.Id = contactList[0].Id;
            contactObj.AccountId = contactList[0].AccountId;
        }
        
    }

    /**
    * @description : this method is used to check whether the new co-applicant that we are trying to add to the application
    *                   already exist in the application or not
    * @author Krishanu Chinya | 02-19-2024 
    * @param coApplicantContactId 
    * @param applicationId 
    **/
    public static void checkForDuplicateCoapplicant(Id coApplicantContactId, Id applicationId){
        List<clcommon__Party__c> partyList = [SELECT Id 
                                                FROM clcommon__Party__c 
                                                WHERE clcommon__Contact__c =:coApplicantContactId 
                                                AND genesis__Application__c =: applicationId];
        if(!partyList.isEmpty()){
            throw new CustomException(PortalConstants.COAPPLICANT_ALREADY_EXIST);
        }
    }

    /**
    * @description : validates whether the chosen coapplicant exists under the dealer or not
    * @author Krishanu Chinya | 03-07-2024 
    * @param dealerId 
    * @param coApplicantAccountId 
    **/
    public static void validateCoapplicantByDealer(Id dealerId, Id coApplicantAccountId){
        List<clcommon__Party__c> partyList = [SELECT Id
                                                FROM clcommon__Party__c
                                                WHERE genesis__Application__r.Dealer_Name__c =: dealerId
                                                AND clcommon__Account__c =: coApplicantAccountId];
        if(partyList.isEmpty()){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
    }


    /**
    * @description : checks whether all fields are populated for a new coapplicant or not
    * @param paramMap
    **/
    public static void isValidCoApplicantCreation(Map<String,Object> paramMap) {

        Contact coApplicantContact=(Contact) paramMap.get(PortalConstants.CONTACT_OBJ_KEY); 
        Account coApplicantAccount=(Account) paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY); 
        genesis__Business_Information__c coApplicantBusiness=(genesis__Business_Information__c) paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY); 
        String saveType=(String) paramMap.get(PortalConstants.SAVE_TYPE_KEY);
  
        if(String.isBlank(coApplicantContact.LastName) && String.isBlank(coApplicantAccount.Name)){
            throw new CustomException(PortalConstants.CO_APPL_LAST_NAME_MISSING);
        }

        PortalApplicationOriginationHelper.checkBlankParameter(coApplicantContact.genesis__SSN__c, PortalConstants.CO_APPL_SSN_MISSING);
        PortalApplicationOriginationHelper.checkBlankParameter(coApplicantContact.Confirm_SSN__c, PortalConstants.CO_APPL_SSN_MISSING);

        
        if(saveType == PortalConstants.SAVE_AND_CONTINUE){
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(coApplicantContact.FirstName), PortalConstants.CO_APPL_FIRST_NAME_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(coApplicantContact.MailingStreet), PortalConstants.CO_APPL_ADDRESS_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(coApplicantContact.MailingCity), PortalConstants.CO_APPL_CITY_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(coApplicantContact.MailingState), PortalConstants.CO_APPL_STATE_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(coApplicantContact.Mailing_County__c), PortalConstants.CO_APPL_COUNTY_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(coApplicantContact.MailingPostalCode), PortalConstants.CO_APPL_ZIP_CODE_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(coApplicantContact.Birthdate), PortalConstants.CO_APPL_DATE_OF_BIRTH_MISSING);

            validatePostalCodeLength(coApplicantContact);

            validateBusinessAssetsAndLiabilities(coApplicantBusiness, PortalConstants.CO_APPL_TOTAL_ASSETS_MISSING, PortalConstants.CO_APPL_TOTAL_LIABILITIES_MISSING);

            if(String.isBlank(String.valueOf(coApplicantContact.MobilePhone)) && String.isBlank(String.valueOf(coApplicantContact.HomePhone)) && String.isBlank(String.valueOf(coApplicantContact.Phone))){
                throw new CustomException(PortalConstants.APPL_MOBILE_MISSING_COAPPLICANT);
            }
        }
    }


    /**
    * @description used to check if the coApplicant is valid or not.
    * @author Rakesh Saraf | 11-05-2024 
    * @param paramMap 
    **/
    public static void isValidCoApplicant(Map<String,Object> paramMap) {

        Contact coApplicantContact=(Contact)paramMap.get(PortalConstants.CONTACT_KEY); 
        Account coApplicantAccount=(Account)paramMap.get(PortalConstants.ACCOUNT_KEY); 
        genesis__Business_Information__c coApplicantBusiness=(genesis__Business_Information__c)paramMap.get(PortalConstants.GENESIS_BUSINESS_INFORMATION_KEY);
        clcommon__party__c partyObj = (clcommon__party__c)paramMap.get(PortalConstants.KEY_PARTY); 
        String saveType=(String)paramMap.get(PortalConstants.SAVE_TYPE_KEY);
  
        if(String.isBlank(coApplicantContact.LastName) && String.isBlank(coApplicantAccount.Name)){
            throw new CustomException(PortalConstants.CO_APPL_LAST_NAME_MISSING);
        }
        PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(coApplicantContact.genesis__SSN__c), PortalConstants.CO_APPL_SSN_MISSING);
        PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(coApplicantContact.Confirm_SSN__c), PortalConstants.CO_APPL_SSN_MISSING);
        
        if(saveType == PortalConstants.SAVE_AND_CONTINUE){
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(coApplicantContact.FirstName), PortalConstants.CO_APPL_FIRST_NAME_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(partyObj.Street__c), PortalConstants.CO_APPL_ADDRESS_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(partyObj.City__c), PortalConstants.CO_APPL_CITY_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(partyObj.State__c), PortalConstants.CO_APPL_STATE_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(partyObj.County__c), PortalConstants.CO_APPL_COUNTY_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(partyObj.Postal_Code__c), PortalConstants.CO_APPL_ZIP_CODE_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(partyObj.Marital_Status__c), PortalConstants.CO_APPL_MARITAL_STATUS_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(coApplicantContact.Birthdate), PortalConstants.CO_APPL_DATE_OF_BIRTH_MISSING);
            
            validatePostalCodeLength(partyObj);
            
            validateBusinessAssetsAndLiabilities(coApplicantBusiness, PortalConstants.CO_APPL_TOTAL_ASSETS_MISSING, PortalConstants.CO_APPL_TOTAL_LIABILITIES_MISSING);
            
            Map<String,String> contactInfoMap = new Map<String,String>{
                PortalConstants.WORK_NUMBER_KEY => String.valueOf(partyObj.Work_Number__c),
                PortalConstants.HOME_NUMBER_KEY => String.valueOf(partyObj.Home_Number__c),
                PortalConstants.MOBILE_NUMBER_KEY => String.valueOf(partyObj.Mobile_Number__c)
            };
            validateApplicantContactInfo(contactInfoMap, PortalConstants.APPL_MOBILE_MISSING_COAPPLICANT);
        }
    }

    /**
    * @description To check if the application fields have valid values. If not then we throw exception
    * @author Rakesh Saraf | 11-13-2024 
    * @param application 
    * @param shouldValidateReqFields 
    **/
    public static void isValidApplicationSubmission(genesis__Applications__c application,
                                                            Boolean shouldValidateReqFields) {

        if (application.Internal_Reference_Code__c != null && 
            !PortalRegexUtil.isValidString(application.Internal_Reference_Code__c)) {
            PortalApplicationOriginationHelper.throwErrorIfFalse(PortalConstants.FALSE_VALUE, PortalConstants.APPL_INVALID_INTERNAL_REF_CODE_TYPE);
        }
        if (shouldValidateReqFields &
            application.Years_Of_Business_With_Applicant__c == null )  {
            PortalApplicationOriginationHelper.throwErrorIfFalse(PortalConstants.FALSE_VALUE, PortalConstants.APPL_YEARS_OF_BUSINESS_FIELD_MISSING);

        } 
        else if (!PortalRegexUtil.isValidString(application.Years_Of_Business_With_Applicant__c)) {
            PortalApplicationOriginationHelper.throwErrorIfFalse(PortalConstants.FALSE_VALUE, PortalConstants.APPL_INVALID_YEARS_OF_BUSINESS_TYPE);
        }
        if (shouldValidateReqFields &
            application.Flex_Rate_Pricing__c == null) {
            PortalApplicationOriginationHelper.throwErrorIfFalse(PortalConstants.FALSE_VALUE, PortalConstants.APPL_FLEX_RATE_PRICING_FIELD_MISSING);

        }   
        if (shouldValidateReqFields &
            application.Do_You_Recommend_This_Applicant__c == null) {
            PortalApplicationOriginationHelper.throwErrorIfFalse(PortalConstants.FALSE_VALUE, PortalConstants.APPL_RECOMMEND_APPL_FIELD_MISSING);
        }  
    }

    /**
    * @description : Method to validate Email address
    * @author Suraj Kumar | 11-23-2024 
    * @param email 
    * @param exceptionMessage 
    **/
    public static void validateEmailAddress(String email, String exceptionMessage) {
        Pattern emailPattern = Pattern.compile(ConstantValues.EMAIL_REGEX);
        Matcher matcherObj = emailPattern.matcher(email);

        if (!matcherObj.matches()) {
            throw new CustomException(exceptionMessage);
        }
    }


    /**
    * @description validates whether a duplicate corportation exists or not
    * @author Rakesh Saraf | 12-02-2024 
    * @param paramMap 
    **/
    public static void validateDuplicateCorporation(Map<String,Object> paramMap) {
        genesis__Business_Information__c businessInfoObj=(genesis__Business_Information__c)paramMap.get(PortalConstants.BUSINESS_INFO_OBJ_KEY);
        Account accountObj=(Account)paramMap.get(PortalConstants.ACCOUNT_OBJ_KEY);
        Id dealerId=(Id)paramMap.get(PortalConstants.DEALER_ID_KEY);

        if(String.isBlank(businessInfoObj.genesis__Tax_Identification_Number__c)){
            return;
        }
        List<Account> corporationAccList = [SELECT Id,
                                                    Coop_Type__c,
                                                    genesis__business_information__c,
                                                    ParentId
                                            FROM Account
                                            WHERE genesis__business_information__r.genesis__Tax_Identification_Number__c = :businessInfoObj.genesis__Tax_Identification_Number__c];

        if(corporationAccList.isEmpty()){
            return;
        }
        List<Dealer_Applicant_Relationship__c> dealerGrowerRelList=[SELECT ID 
                                                                    FROM Dealer_Applicant_Relationship__c 
                                                                    WHERE Applicant__c=:corporationAccList[0].Id
                                                                    AND Dealer__c=:dealerId];
        
        //same dealer
        if(dealerId == corporationAccList[0].ParentId || !dealerGrowerRelList.isEmpty()){
            throw new CustomException(PortalConstants.DUPLICATE_TIN);
        }
        //other dealer
        else{
            accountObj.Id = corporationAccList[0].Id;
            businessInfoObj.Id = corporationAccList[0].genesis__business_information__c;
        }
        
    }

    /**
    * @description method to check if ssn and tin are present or not. 
    * @author Rakesh Saraf | 01-09-2025 
    * @param growerContact 
    **/
    public static void checkIfSSNorTINisPresent(Contact growerContact){
        //if grower does not have ssn
        
        if(String.isBlank(growerContact.genesis__SSN__c) 
                    && growerContact.Account.clcommon__Legal_Entity_Type__r.Name == PortalConstants.SOLE_PROP_ENTITY){
            throw new CustomException(PortalConstants.MISSING_SSN_OR_TIN);
        }
        if(String.isBlank(growerContact.Account.genesis__Business_Information__r.genesis__Tax_Identification_Number__c) 
                && growerContact.Account.clcommon__Legal_Entity_Type__r.Name == PortalConstants.CORPORATION){
            throw new CustomException(PortalConstants.MISSING_SSN_OR_TIN); 
        }
    }

    /**
    * @description this method is to check if a user exists for the grower for whom we are trying to update the SSN.
    * @author Rakesh Saraf | 03-01-2025 
    * @param oldApplicantContactId 
    * @param currentApplicantContactId 
    **/
    public static void verifyUserForApplicant(Id oldApplicantContactId,Id currentApplicantContactId){
        List<User> userList=[SELECT Id
                             FROM User
                             WHERE ContactId=:oldApplicantContactId];
        if(!userList.isEmpty() && currentApplicantContactId!=oldApplicantContactId){
            throw new CustomException(PortalConstants.COULD_NOT_UPDATE_SSN);
        }
    }
}