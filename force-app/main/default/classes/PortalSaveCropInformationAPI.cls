/**
* @description       : Purpose of this class is to save/update the collateral details
 * @author            : iAyush
 * @group             : 
 * @last modified on  : 03-12-2024
 * @last modified by  :  Pritam Roy
**/
global without sharing class PortalSaveCropInformationAPI implements clcommon.PortalCustomRemoteAPI1 {
    // constants specific for this class [start]
    private static final String KEY_APPLICATION = 'application';
    private static final String KEY_CROP = 'cropDetails';
    private static final String KEY_DOES_APPLICANT_FEED_COLLATERAL = 'feedCollateral';
    private static final String KEY_SHOULD_VALIDATE = 'shouldValidate';
    private static final String KEY_CALCULATE_PRICE = 'calculatePrice';
    private static final String FEED_COLLATERAL_CHECKED_VALUE = 'Checked';
    private static final String FEED_COLLATERAL_UNCHECKED_VALUE = 'Unchecked';
    private static final String INSURANCE_PLAN_RP_VALUE = 'RP';
    private static final String INSURANCE_PLAN_ARP_VALUE = 'ARP';
    private static final String INSURANCE_PLAN_ARH_VALUE = 'ARH';
    private static final String AGGREGATE_KEY = 'expr0';
    private static final String PORTAL_SAVE_CROP_INFORMATION_API = 'PortalSaveCropInformationAPI';
    private static final String LOAN_CONFIRMATION='loanConfirmation';
    private static final String COLLATERAL_ZERO='collateralZero';
    
    
    // constants specific for this class [end]
    String cropDetails = '';
    String applicationId = '';
    String feedCollateral = '';
    String applicationDetails = '';
    Boolean shouldValidate = true;
    Boolean calculatePrice = false;
    Boolean checkPrice=false;
    Boolean reduceLoanToZero=false;
    Boolean loanConfirmation=false;
    Boolean collateralZero=false;
    
    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
    clcommon.Response response = new clcommon.Response();
    Map<String, Boolean> fieldsMap = new Map<String, Boolean>();
            
    
    /**
    * @description : Method called from portal to save collateral details
    * @author  Pritam Roy | 03-12-2024 
    * @param componentStructureName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStructureName,
                                          String[] disclosureNames,
                                          Map<String, Object> request) {
        SavePoint dbSavePoint = Database.setSavepoint();
        genesis__Applications__c objApplication = new genesis__Applications__c();
        
        List<clcommon__collateral__c> objCollateralList = new List<clcommon__collateral__c>();
        List<genesis__Application_Collateral__c> objApplicationCollateralList = new List<genesis__Application_Collateral__c>();

        try {
            if (String.isBlank((String) request.get(KEY_APPLICATION)) || 
                //String.isBlank((String) request.get(KEY_CROP)) || 
                String.isBlank((String) request.get(KEY_DOES_APPLICANT_FEED_COLLATERAL)) || 
                request.get(KEY_SHOULD_VALIDATE) == null) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }

            applicationDetails = String.valueOf(request.get(KEY_APPLICATION));
            cropDetails = String.valueOf(request.get(KEY_CROP));
            feedCollateral = String.valueOf(request.get(KEY_DOES_APPLICANT_FEED_COLLATERAL));
            shouldValidate = Boolean.valueOf(request.get(KEY_SHOULD_VALIDATE));

            if (request.get(LOAN_CONFIRMATION) != null) {
            loanConfirmation = Boolean.valueOf(request.get(LOAN_CONFIRMATION));
            }
            if(!loanConfirmation && String.isBlank((String) request.get(KEY_CROP))){
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }


            if (request.get(KEY_CALCULATE_PRICE) != null) {
                calculatePrice = Boolean.valueOf(request.get(KEY_CALCULATE_PRICE));
            }
            if (request.get(COLLATERAL_ZERO) != null) {
                collateralZero = Boolean.valueOf(request.get(COLLATERAL_ZERO));
            }
            if (String.isBlank(applicationDetails)) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
            
            objApplication = (genesis__Applications__c) Json.deserialize(applicationDetails, genesis__Applications__c.class);

            if (objApplication.Id != null) {
                applicationId = objApplication.Id;
            } else {
                throw new CustomException(PortalConstants.APPL_ID_FIELD_MISSING);
            }
            
            // If it is an existing Application, then we are only doing an Update to the same Application
            Boolean isValidUser = PortalSecurityUtil.validateUserApplication(applicationId); 
            if (!isValidUser) {
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }
            
            if(feedCollateral.equals(FEED_COLLATERAL_CHECKED_VALUE)){
                objApplication.Does_Applicant_Feed_Above_Collaterals__c = true;
            }
            else if (feedCollateral.equals(FEED_COLLATERAL_UNCHECKED_VALUE)) {
                objApplication.Does_Applicant_Feed_Above_Collaterals__c = false;
            } else {
                throw new CustomException(PortalConstants.APPL_INVALID_FEED_COLLATERALS_TYPE);
            }

            // Checking if all the Required Params are present or not
            if (String.isBlank(applicationId)) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }

            List<Object> cropList = new List<Object>();
            if(!loanConfirmation){
                cropList = (List<Object>) Json.deserializeUntyped(cropDetails);
            }
            if(!loanConfirmation && cropList.size() == 0){
                reduceLoanToZero=true; 
                // updating loan amount to 0 if no collaterals is provided
                objApplication.genesis__Loan_Amount__c = 0;
                objApplication.genesis__Requested_Loan_Amount__c = 0;
                Database.update(objApplication, true);
                fieldsMap.put('reduceLoanToZero', reduceLoanToZero);
                responseData.add(new clcommon.PortalCustomRemoteActionRecord(fieldsMap));
                clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
                response.content = null;
                response.response = responseFormat.response;
                response.status = clcommon.Constants.SUCCESS;
                return response;
            }
            if(!loanConfirmation && cropList.size() == 1 && collateralZero){
                Map<String, Object> objCollateralMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(cropList[0]));
                clcommon__Collateral__c objCollateral = new clcommon__Collateral__c();
                objCollateral = PortalHelper.getCollateralDetails(objCollateralMap);

                if(objCollateral.Id==null && objCollateral.Total_Acres__c == null ){
                    checkPrice=true;
                    objApplication.genesis__Loan_Amount__c = 0;
                    objApplication.genesis__Requested_Loan_Amount__c = 0;
                    Database.update(objApplication, true);
                    fieldsMap.put('checkPrice', checkPrice);
                    responseData.add(new clcommon.PortalCustomRemoteActionRecord(fieldsMap));
                    clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
                    response.content = null;
                    response.response = responseFormat.response;
                    response.status = clcommon.Constants.SUCCESS;
                    return response;
                }
            }
            if(!loanConfirmation){
                for (Object crop : cropList) {
                    Map<String, Object> objCollateralMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(crop));
                    
                    clcommon__Collateral__c objCollateral = new clcommon__Collateral__c();
                    objCollateral = PortalHelper.getCollateralDetails(objCollateralMap);

                    // Validate request parameters if "shouldValidate" flag is set to "true"
                    if (!PortalValidationUtil.isValidCropInformation(objCollateral, 
                                                                        shouldValidate,
                                                                        objApplication.Does_Applicant_Feed_Above_Collaterals__c,
                                                                        response)) {
                        return response;
                    }

                    if (!objApplication.Does_Applicant_Feed_Above_Collaterals__c) {
                        objCollateral.Percent_Fed__c = null;
                    }
                    
                    PortalHelper.saveApplicationCollateral(objCollateral, applicationId);

                    objCollateralList.add(objCollateral);
                }
            }
            List<Id> collateralCategoryIdList = new List<Id>();
            for (clcommon__collateral__c objCollateral : objCollateralList) {
                collateralCategoryIdList.add(objCollateral.clcommon__Collateral_Category__c);
            }

            List<clcommon__Collateral_Category__c> objCollateralCategoryList = [SELECT Id, 
                                                                                       Name, 
                                                                                       Collateral_Unit__c, 
                                                                                       Price_Per_Unit_1__c, 
                                                                                       Price_Per_Unit_2__c 
                                                                                FROM clcommon__Collateral_Category__c 
                                                                                WHERE Id IN :collateralCategoryIdList];

            Map<Object, clcommon__Collateral_Category__c> objCollateralPriceMap = PortalHelper.getMapOfCollateralPrices(objCollateralCategoryList);

            // Assigning prices to collaterals
            if (shouldValidate || calculatePrice) {
                for (clcommon__collateral__c objCollateral : objCollateralList) {
                    if(objCollateral.clcommon__Collateral_Category__c != null 
                        && objCollateral.Total_Acres__c != null 
                        && objCollateral.Total_Acres__c > 0 
                        && objCollateral.Producer_Share_Percent__c != null 
                        && objCollateral.Producer_Share_Percent__c > 0 
                        && objCollateral.Producer_Share_Percent__c < 101 
                        && objCollateral.Approved_Yield__c != null 
                        && objCollateral.Approved_Yield__c >=0 
                        && objCollateral.Insurance_Plan__c != null){

                        if (objCollateralPriceMap.containsKey(objCollateral.clcommon__Collateral_Category__c)) {
                            if (objCollateral.Insurance_Plan__c.equals(INSURANCE_PLAN_RP_VALUE) ||
                                objCollateral.Insurance_Plan__c.equals(INSURANCE_PLAN_ARP_VALUE) ||
                                objCollateral.Insurance_Plan__c.equals(INSURANCE_PLAN_ARH_VALUE)) {
                                objCollateral.Price__c = objCollateralPriceMap.get(objCollateral.clcommon__Collateral_Category__c)
                                                                            .Price_Per_Unit_1__c;
                            } else {
                                // for insurance type YP/APH/AYP/CAT/Hail only/None
                                objCollateral.Price__c = objCollateralPriceMap.get(objCollateral.clcommon__Collateral_Category__c)
                                                                            .Price_Per_Unit_2__c;
                            }
                        }   
                    }
                    else{
                        objCollateral.Price__c= 0.00;
                    }
                }
            }
            Database.UpsertResult[] result = Database.upsert(objCollateralList, true);

            if (shouldValidate) {
                Double sumTotalCollateralsPrice = Double.valueOf([SELECT SUM(Total_Collateral_Price__c) 
                                                                  FROM clcommon__Collateral__c 
                                                                  WHERE genesis__Application__c = :applicationId][0]
                                                                 .get(AGGREGATE_KEY));
                
                Double requestedLoanAmount = Double.valueOf([SELECT genesis__Loan_Amount__c 
                                                             FROM genesis__Applications__c 
                                                             WHERE Id = :applicationId][0]
                                                            .genesis__Loan_Amount__c);

                if (requestedLoanAmount > sumTotalCollateralsPrice) {
                    checkPrice=true;
                    if(loanConfirmation){
                        objApplication.genesis__Loan_Amount__c = sumTotalCollateralsPrice;
                        objApplication.genesis__Requested_Loan_Amount__c = sumTotalCollateralsPrice;
                    }

                   // PortalHelper.updateDealerLimits(applicationId, sumTotalCollateralsPrice);
                }
                //To change the stage of Application
                genesis__Applications__c objApplicationStage = [SELECT Id,
                                                                        Stage__c 
                                                                FROM genesis__Applications__c 
                                                                WHERE id= :objApplication.Id];

                if(objApplicationStage.Stage__c == PortalConstants.CROP_INFORMATION){
                    objApplication.stage__c = PortalConstants.APPLICANT_SIGNATURE;
                }
            }

            Database.update(objApplication, true);

            // fetching all the current application collateral junction records for this application
            objApplicationCollateralList = [SELECT Id, 
                                                genesis__Collateral__c, 
                                                genesis__Application__c 
                                            FROM genesis__Application_Collateral__c
                                            WHERE genesis__Application__c = :applicationId];
            
            Map<Id, genesis__Application_Collateral__c> objApplicationCollateralMap = new Map<Id, genesis__Application_Collateral__c>();

            for (genesis__Application_Collateral__c objApplicationCollateral : objApplicationCollateralList) {
                objApplicationCollateralMap.put(objApplicationCollateral.genesis__Collateral__c, 
                                                objApplicationCollateral);
            }

            for (Database.UpsertResult savedCollateral : result) {
                // filtering out only those collaterals which doesn't have a junction
                // currently present
                if (!objApplicationCollateralMap.containsKey(savedCollateral.getId())) {
                    objApplicationCollateralList.add(new genesis__Application_Collateral__c(
                                                        genesis__Collateral__c=savedCollateral.getId(),
                                                        genesis__Application__c=applicationId
                                                    ));
                }
            }

            Database.upsert(objApplicationCollateralList);
            fieldsMap.put('checkPrice', checkPrice);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(fieldsMap));
            clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.content = null;
            response.response = responseFormat.response;
            response.status = clcommon.Constants.SUCCESS;
        } catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
            PortalHelper.saveExceptionLog(objCustomException, PORTAL_SAVE_CROP_INFORMATION_API);
        } catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(objException, PORTAL_SAVE_CROP_INFORMATION_API); 
        }
        return response;
    }
}