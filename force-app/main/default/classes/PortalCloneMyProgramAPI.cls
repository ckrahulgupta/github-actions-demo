/**
 * @description       : Purpose of the class is to clone a my program and its rate cards
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 07-29-2024
 * @last modified by  :  Pritam Roy
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   22-02-2022   Subham Nandi   Initial Version
**/
global without sharing class PortalCloneMyProgramAPI  implements clcommon.PortalCustomRemoteAPI1 {
    // Constant parameters specific for this class starts
    private static final String MY_PROGRAM_HEADER = 'program';
    private static final String CROPYEARSTRING = 'Crop_Year__c';
    private static final String NEGATIVE_STRING = 'No';
    private static final String MYPROGRAM_ID_STRING = 'myProgramId';
    private static final Integer MONTH_AUGUST = 8;
    private static final Integer MONTH_DECEMBER = 12;
    private static final Integer MONTH_JANUARY = 1;
    private static final Integer MONTH_FEBRUARY = 2;
    private static final Integer MONTH_MARCH = 3;
    private static final String HASH = '#';
    private static final String COLON = ':';
    private static final String LOAN_STRING = 'Loan';
    List<String> stringJanToMay = new List<String> {'1','2','3','4','5'};
    List<String> stringJuneToAug = new List<String> {'6','7','8'};
    List<String> stringSepToDec = new List<String> {'9','10','11','12'};
    // Constant parameters specific for this class Ends
    // Declaration specific to this class
    String myProgramId = '';
    clcommon.Response response = new clcommon.Response();
    String myProgram = '';
    String cropYear;
    List<clcommon.PortalCustomRemoteActionRecord> responseDataList = new List<clcommon.PortalCustomRemoteActionRecord>();
    Map<String, Object> fieldsMap = new Map<String, Object>();
    
    /**
    * @description : gets the program id and clones the particular my program(edited) and its rate card details
    * @author  Pritam Roy | 03-04-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param requestMyProgram 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                        String[] disclosureNames,
                                        Map<String, Object> requestMyProgram) {

        //get the programId as headerId to clone
        SavePoint dbSavePoint = Database.setSavepoint();
        if(requestMyProgram.get(MY_PROGRAM_HEADER) == null){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        myProgram = String.valueOf(requestMyProgram.get(MY_PROGRAM_HEADER));
        
        Integer differenceInDays = Integer.valueOf(PortalConstants.DIFFERENCE_BETWEEN_STARTDATE);
        genesis__Rate_Card_Setup_Header__c objNewRateCardClone = new genesis__Rate_Card_Setup_Header__c();
        genesis__Additional_Determining_Factor__c objAdditionalFactorClone = new genesis__Additional_Determining_Factor__c();
        genesis__Additional_Determining_Factor__c  objFactorDealerClone = new genesis__Additional_Determining_Factor__c();
        genesis__Product_Rate_Card_Association__c productAssociationClone = new genesis__Product_Rate_Card_Association__c();
        Integer cropYearToValidate;
        String dealerName;

        try{
            // Fetching the logged in user's Account Id and the Dealer account id for this particular user
            List<User> objLoggedInUserList =  MyProgramHelper.getDealerAccount();
            dealerName = getDealerName(objLoggedInUserList);
            objNewRateCardClone = (genesis__Rate_Card_Setup_Header__c) Json.deserialize(myProgram, genesis__Rate_Card_Setup_Header__c.class);
            String myProgramName = objNewRateCardClone.Name;
            validateMyProgramName(myProgramName, HASH);
            validateMyProgramName(myProgramName, COLON);
            myProgramId = objNewRateCardClone.Id;
            objNewRateCardClone.Id = null;
            Boolean isValidUser = PortalSecurityUtil.validateRateCardDetailByDealer(objLoggedInUserList[0].Contact.Account.ParentId, myProgramId);
            PortalApplicationOriginationHelper.checkValidUser(isValidUser);
            List<genesis__Rate_Card_Setup_Header__c> rateCardHeaderList = [ SELECT  Id,
                                                                                    Name,
                                                                                    genesis__CL_Product__c,
                                                                                    genesis__End_Date__c,
                                                                                    RecordTypeId,
                                                                                    Account__c,
                                                                                    Account__r.Name,
                                                                                    Special_Term_Number__c,
                                                                                    Base_Rate__c,
                                                                                    (SELECT Id,
                                                                                            genesis__Rate_Card_Setup_Header__c, 
                                                                                            genesis__Determining_Factor_Key_Value__c, 
                                                                                            genesis__Interest_Rate__c, 
                                                                                            genesis__Pricing_Method__c, 
                                                                                            genesis__Product_Type__c, 
                                                                                            genesis__Use_Additional_Determining_Factors__c,
                                                                                            Description__c, 
                                                                                            End_Date__c, 
                                                                                            Interest_Rate_Type__c, 
                                                                                            Participation_Percentage_CFA__c, 
                                                                                            Participation_Percentage_Dealer__c, 
                                                                                            Start_Date__c, 
                                                                                            Participation_Percentage_Dealer_Subsidy__c, 
                                                                                            Special_Term_Order__c,
                                                                                            genesis__Enabled_Flag__c, 
                                                                                            Special_Term_Reference__c,
                                                                                            Billing_Date__c,
                                                                                            Has_Billing_Date__c
                                                                                    FROM genesis__Rate_Card_Setup_Details__r)
                                                                            FROM genesis__Rate_Card_Setup_Header__c
                                                                            WHERE Id = :myProgramId ];
            checkRateCardHeader(rateCardHeaderList,objNewRateCardClone);                                                            
            cropYear = (String)objNewRateCardClone.get(CROPYEARSTRING);
            if(String.isNotBlank(cropYear)){
                cropYearToValidate = Integer.valueOf(cropYear);
            }
            ////------------------Crop Year Validation--STARTS----------------------------------------------
            MyProgramValidationUtil.validateCropYear(cropYearToValidate);
            ////------------------Crop Year Validation--ENDS--------------------------------------------------
            //check for the payer of loan closing fee
            MyProgramValidationUtil.validateMaturityDate(objNewRateCardClone,cropYearToValidate);
            //Cloning the rate card header from portal
            objNewRateCardClone.Special_Term_Number__c = rateCardHeaderList[0].Special_Term_Number__c;
            objNewRateCardClone = validateRateCardHeader(objNewRateCardClone, rateCardHeaderList, cropYear);
            objNewRateCardClone.genesis__Transaction_Date__c = System.today();
            objNewRateCardClone.genesis__Start_Date__c = System.today().addDays(differenceInDays);
            objNewRateCardClone.genesis__Filter_By_Credit_Rating__c = false;
            objNewRateCardClone.genesis__Filter_By_Frequency__c = false;
            objNewRateCardClone.genesis__Filter_By_Loan_Amount__c = false;
            objNewRateCardClone.genesis__Filter_By_Term__c = false;
            objNewRateCardClone.Status__c = PortalConstants.NOT_SUBMITTED_MY_PROGRAM;
            objNewRateCardClone.genesis__Enabled_Flag__c = false;
            objNewRateCardClone.Base_Rate__c = rateCardHeaderList[0].Base_Rate__c;
            Database.insert(objNewRateCardClone,true);
            fieldsMap.put(MYPROGRAM_ID_STRING, objNewRateCardClone.Id);
            //Cloning the Product Rate Card Association
            clcommon__CL_Product__c objProductToAssociate = [SELECT Id, 
                                                                    Name, 
                                                                    RecordType.Name, 
                                                                    clcommon__Product_Name__c, 
                                                                    clcommon__Pricing_Method__c 
                                                                    FROM clcommon__CL_Product__c 
                                                                    WHERE RecordType.Name = :LOAN_STRING AND 
                                                                        clcommon__Product_Name__c = :PortalConstants.SIMPLIFY_TYPE 
                                                                    LIMIT 1];
            productAssociationClone.genesis__CL_Product__c = objProductToAssociate.Id;
            productAssociationClone.genesis__Rate_Card_Setup__c = objNewRateCardClone.Id;
            Database.insert(productAssociationClone,false);
            //Cloning the Additional Determining Factor for the My Program
            objAdditionalFactorClone.Name = PortalConstants.MY_PROGRAM_FACTOR_NAME;
            objAdditionalFactorClone.genesis__Evaluation_Operator__c = PortalConstants.FACTOR_EVALUATION_OPERATOR;
            objAdditionalFactorClone.genesis__Rate_Card_Setup_Header__c = objNewRateCardClone.Id;
            objAdditionalFactorClone.genesis__Applicable_for_Application__c = true;
            objAdditionalFactorClone.genesis__Application_Object_API_Name__c = PortalConstants.APPLICATION_API_NAME;
            objAdditionalFactorClone.genesis__Application_Object_Name__c = PortalConstants.APPLICATION_OBJECT_NAME;
            objAdditionalFactorClone.genesis__Application_Field_API_Name__c =  PortalConstants.MY_PROGRAM_FIELD_API_NAME;
            objAdditionalFactorClone.genesis__Application_Field_Name__c = PortalConstants.MY_PROGRAM_FIELD_NAME;
            objAdditionalFactorClone.genesis__Application_Field_Type__c = PortalConstants.FIELD_TYPE;
            objAdditionalFactorClone.genesis__Apply_to_all_Rate_Card_Details__c = true;
            objAdditionalFactorClone.genesis__Field_Value__c = objNewRateCardClone.Name;
            Database.upsert(objAdditionalFactorClone,false);

            objFactorDealerClone.Name = PortalConstants.DEALER_PROFILE;
            objFactorDealerClone.genesis__Evaluation_Operator__c = PortalConstants.FACTOR_EVALUATION_OPERATOR;
            objFactorDealerClone.genesis__Rate_Card_Setup_Header__c = objNewRateCardClone.Id;
            objFactorDealerClone.genesis__Applicable_for_Application__c = true;
            objFactorDealerClone.genesis__Application_Object_API_Name__c = PortalConstants.APPLICATION_API_NAME;
            objFactorDealerClone.genesis__Application_Object_Name__c = PortalConstants.APPLICATION_OBJECT_NAME;
            objFactorDealerClone.genesis__Application_Field_API_Name__c =  PortalConstants.MY_PROGRAM_DEALER_FIELD;
            objFactorDealerClone.genesis__Application_Field_Name__c = PortalConstants.DEALER_NAME;
            objFactorDealerClone.genesis__Application_Field_Type__c = PortalConstants.FIELD_TYPE;
            objFactorDealerClone.genesis__Apply_to_all_Rate_Card_Details__c = true;
            if(String.isNotBlank(dealerName)){
                    objFactorDealerClone.genesis__Field_Value__c = dealerName;
            }
            
            Database.upsert(objFactorDealerClone,false);
            //Create all the My Program Sub Tranches [Starts]--------------------------------------------------------------------------------------------------------
            List<genesis__Rate_Card_Setup_Detail__c> objNewRateCardList = new List<genesis__Rate_Card_Setup_Detail__c>();
            for(genesis__Rate_Card_Setup_Detail__c objRateCardDetail : rateCardHeaderList[0].genesis__Rate_Card_Setup_Details__r){
                genesis__Rate_Card_Setup_Detail__c objNewRateCard = new genesis__Rate_Card_Setup_Detail__c();
                objNewRateCard.genesis__Rate_Card_Setup_Header__c = objNewRateCardClone.Id;
                objNewRateCard.genesis__Determining_Factor_Key_Value__c = String.valueOf(objAdditionalFactorClone.Id)+':'
                                                                            +String.valueOf(objNewRateCardClone.Name)+'#'
                                                                            +String.valueOf(objFactorDealerClone.Id)+':'
                                                                            +String.valueOf(dealerName);
                objNewRateCard.genesis__Interest_Rate__c = objRateCardDetail.genesis__Interest_Rate__c;
                // objNewRateCard.genesis__Product_Type__c = objRateCardDetail.genesis__Product_Type__c;
                objNewRateCard.genesis__Use_Additional_Determining_Factors__c = objRateCardDetail.genesis__Use_Additional_Determining_Factors__c;
                objNewRateCard.Description__c = objRateCardDetail.Description__c;
                objNewRateCard.End_Date__c = objRateCardDetail.End_Date__c;
                objNewRateCard.Interest_Rate_Type__c = objRateCardDetail.Interest_Rate_Type__c;
                objNewRateCard.Participation_Percentage_CFA__c = objRateCardDetail.Participation_Percentage_CFA__c;
                objNewRateCard.Participation_Percentage_Dealer__c = objRateCardDetail.Participation_Percentage_Dealer__c;
                objNewRateCard.Start_Date__c = objRateCardDetail.Start_Date__c;
                objNewRateCard.Participation_Percentage_Dealer_Subsidy__c = objRateCardDetail.Participation_Percentage_Dealer_Subsidy__c;
                objNewRateCard.Special_Term_Order__c = objRateCardDetail.Special_Term_Order__c;
                objNewRateCard.Special_Term_Reference__c = objRateCardDetail.Special_Term_Reference__c;
                objNewRateCard.Billing_Date__c = objRateCardDetail.Billing_Date__c;
                objNewRateCard.Has_Billing_Date__c = objRateCardDetail.Has_Billing_Date__c;
                objNewRateCard.genesis__Enabled_Flag__c = objRateCardDetail.genesis__Enabled_Flag__c; 
                objNewRateCardList.add(objNewRateCard);
            }
            Database.insert(objNewRateCardList,true);
            responseDataList.add(new clcommon.PortalCustomRemoteActionRecord(fieldsMap));
            clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(responseDataList);
            response.content = null;
            response.response = responseFormat.response;
            response.status = clcommon.Constants.SUCCESS;
        }
        catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = objCustomException.getMessage();
        }
        catch (Exception objException) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
        }
        return response;    
    }
    
    /**
    * @description : This method is used to validate rate card header detail for clone
    * @author  Pritam Roy | 03-04-2024 
    * @param objNewRateCardClone 
    * @param rateCardHeaderList 
    * @param cropYear 
    * @return genesis__Rate_Card_Setup_Header__c 
    **/
    private static genesis__Rate_Card_Setup_Header__c validateRateCardHeader(genesis__Rate_Card_Setup_Header__c objNewRateCardClone,List<genesis__Rate_Card_Setup_Header__c> rateCardHeaderList,String cropYear){
        if(String.isNotBlank(cropYear)){
            objNewRateCardClone.Crop_Year__c = cropYear;
        }
        if(rateCardHeaderList.size() > 0){
            if(rateCardHeaderList[0].genesis__CL_Product__c != null){
                objNewRateCardClone.genesis__CL_Product__c = rateCardHeaderList[0].genesis__CL_Product__c;
            }
            if(rateCardHeaderList[0].RecordTypeId != null){
                objNewRateCardClone.RecordTypeId = rateCardHeaderList[0].RecordTypeId;
            }
            if(rateCardHeaderList[0].Account__c != null){
                objNewRateCardClone.Account__c = rateCardHeaderList[0].Account__c;
            }
        }
        return objNewRateCardClone;
    }
    
    /**
    * @description : This method is used to check rate card details
    * @author  Pritam Roy | 03-04-2024 
    * @param rateCardHeaderList 
    * @param objNewRateCardClone 
    **/
    private static void checkRateCardHeader(List<genesis__Rate_Card_Setup_Header__c> rateCardHeaderList,genesis__Rate_Card_Setup_Header__c objNewRateCardClone){
        if(rateCardHeaderList.size() == 0 || rateCardHeaderList == null){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
        if(objNewRateCardClone.get(CROPYEARSTRING) == null){
            throw new CustomException(PortalConstants.CROP_YEAR_NULL_ERROR);
        }
    }
    
    /**
    * @description : This method is used to validate my program name
    * @author  Pritam Roy | 03-04-2024 
    * @param myProgramName 
    * @param specialCharacter 
    **/
    private static void validateMyProgramName(String myProgramName,String specialCharacter){
        if(myProgramName.contains(specialCharacter)){
            throw new CustomException(PortalConstants.WRONG_MY_PROGRAM_NAME);
        }
    }

    /**
    * @description : Get Dealer Name
    * @author  Pritam Roy | 07-24-2024 
    * @param objLoggedInUserList 
    * @return String 
    **/
    private static String getDealerName(List<User> objLoggedInUserList){
        String dealerName;
        if(objLoggedInUserList.size() > 0 &&
            objLoggedInUserList[0].Contact != null &&
            objLoggedInUserList[0].Contact.Account != null &&
            objLoggedInUserList[0].Contact.Account.ParentId != null &&
            objLoggedInUserList[0].Contact.Account.Parent.Name != null){
                dealerName = objLoggedInUserList[0].Contact.Account.Parent.Name;
        }
        return dealerName;
    }
}