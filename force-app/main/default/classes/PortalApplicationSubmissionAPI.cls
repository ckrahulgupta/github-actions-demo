/**
 * @description       : This api is for submitting the application and if possible, also autobooks it
 * @author            : Simran
 * @group             : 
 * @last modified on  : 12-26-2024
 * @last modified by  : Kabir Pramanik
**/

global without sharing class PortalApplicationSubmissionAPI  implements clcommon.PortalCustomRemoteAPI1 {


    // Declarations specific to this class starts
    String applicationRecord = PortalConstants.EMPTY_STRING;
    Boolean shouldValidate = true;
    Map<String, Object> fieldsMap = new Map<String, Object>();
    clcommon.Response response = new clcommon.Response();
    genesis__Applications__c applicationObj = new genesis__Applications__c();
    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();

    String borrowerAccountId;
    List<Id> principalAccountIdList = new List<Id>();
    public static Integer activePricingCount = PortalConstants.ZERO_VALUE;
    // Declaration specific to this class ends

    /**
    * @description - Purpose of this method is to take Application and Submit it validating the necessary details if necessary. It also autobooks it if all the requirements are met
    * @author simranjha | 04-01-2022
    * @param componentStructureName 
    * @param disclosureNames 
    * @param request 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStructureName,
                                            String[] disclosureNames,
                                            Map<String, Object> request) {
        
        SavePoint dbSavePoint = Database.setSavepoint();

        // declaration specific to this method starts
        User loggedInUser=new User();
        List<genesis__Applications__c> currentApplicationList = new List<genesis__Applications__c>();
        String coopType=PortalConstants.EMPTY_STRING;
        List<genesis__Application_Pricing_Detail__c> applicationPricingList = new List<genesis__Application_Pricing_Detail__c>();
        List<clcommon__Party__c> principalPartyList=new List<clcommon__Party__c>();
        genesis__Rate_Card_Setup_Header__c applicationMyProgramObj=new genesis__Rate_Card_Setup_Header__c();
        Map<String,Object> borrowerInfoMap= new Map<String,Object>();


        // flag for autobook
        Boolean isAutoBookPossible = false;
        Boolean shouldDeny = false;
        // declaration specific to this method ends

        try{
        
            // Checking if all the Required Params are present or not
            PortalApplicationOriginationHelper.checkIfNullObject(request.get(PortalConstants.APPLICATION_KEY), PortalConstants.REQUIRED_PARAMETERS_MISSING);
            PortalApplicationOriginationHelper.checkIfNullObject(request.get(PortalConstants.KEY_SHOULD_VALIDATE), PortalConstants.SOMETHING_WENT_WRONG);
            
            applicationRecord = String.valueOf(request.get(PortalConstants.APPLICATION_KEY));
            shouldValidate = Boolean.valueOf(request.get(PortalConstants.KEY_SHOULD_VALIDATE));

            PortalApplicationOriginationHelper.checkBlankParameter(applicationRecord, PortalConstants.REQUIRED_PARAMETERS_MISSING);
            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(shouldValidate), PortalConstants.SOMETHING_WENT_WRONG);

            
            //getting the application from the request from portal
            applicationObj = (genesis__Applications__c) JSON.deserialize(applicationRecord, genesis__Applications__c.class);

            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(applicationObj.id),PortalConstants.SOMETHING_WENT_WRONG);

            //validating if the user has permission to submit the application
            loggedInUser=PortalAppSubmissionValidationUtil.isValidUser((String)applicationObj.id);

            PortalApplicationOriginationHelper.checkBlankParameter(String.valueOf(applicationObj.Do_You_Recommend_This_Applicant__c) ,PortalConstants.MISSING_APPROVAL_FOR_THE_APPLICATION);
            
            //if do you recommend this application is marked false, we mark the value of shouldDeny as true
            if(applicationObj.Do_You_Recommend_This_Applicant__c == PortalConstants.NEGATIVE_STRING) {
                shouldDeny = true;
            }

            //uploading notes to the database if it came with the application
            PortalApplicationSubmissionHandler.updateNote(request, applicationObj);

            //validating erp id
            applicationObj.ERP_Id__c = PortalApplicationCreationHandler.validateErpId(applicationObj.ERP_Id__c,applicationObj.Id, shouldValidate);
                

            //querying the application for some of the fields that are created while initiating the application and some other fields which is not present in the request from portal
            currentApplicationList = PortalApplicationSubmissionHandler.getApplicationDetails(applicationObj.id);

            PortalApplicationSubmissionHandler.updateQueriedApplicationFields(currentApplicationList,applicationObj);

            //saving the coopType associated with the application
            coopType=currentApplicationList[0].Coop_Type__c;

            //query the my program linked to the application
            applicationMyProgramObj = PortalApplicationSubmissionHandler.getMyProgram(applicationObj);
                        
                
            if(!shouldValidate){

                //save and exit the application, so no validations will be done, only the neccessary fields will be populated and stored
                saveAndExitApplication(new Map<String,Object>{
                    PortalConstants.APPLICATION_KEY=>currentApplicationList[0],
                    PortalConstants.KEY_SHOULD_DENY=>shouldDeny,
                    PortalConstants.KEY_MY_PROGRAM=>applicationMyProgramObj
                });
            }
            else{
                //SAVE AND CONTINUE----> validate and run the workflow

                // Validation for Borrower and CoBorrower Details present in the Applicant Information Tab
                PortalAppSubmissionValidationUtil.validateDealerPartnerProgram(currentApplicationList[0]);
                
                //getting all the principal parties linked to the application
                principalPartyList = PortalApplicationSubmissionHandler.getPrincipalPartyList(currentApplicationList[0]);
       
                Map<String,Id> borrowerDetailsMap=PortalApplicationSubmissionHandler.getBorrowerDetails(currentApplicationList[0]);
                Map<String,List<Id>> principalDetailsMap=PortalApplicationSubmissionHandler.getPrincipalDetails(currentApplicationList[0]);

                borrowerInfoMap= PortalAppSubmissionValidationUtil.validateApplicationInfoForApplicants(currentApplicationList,borrowerDetailsMap,principalDetailsMap);

                borrowerAccountId=(Id)borrowerDetailsMap.get(PortalConstants.ACCOUNT_KEY);
                principalAccountIdList=(List<Id>) principalDetailsMap.get(PortalConstants.ACCOUNT_KEY);

                // Validation for if the application is a valid application submission
                PortalValidationUtil.isValidApplicationSubmission(currentApplicationList[0], shouldValidate);

                //Check whether the applicationObj was scored or not
                PortalAppSubmissionValidationUtil.validateApplicationScored(currentApplicationList[0]);

                //need to validate the addition info of the application
                PortalAppSubmissionValidationUtil.validateAdditionalInformation(new Map<String,Object>{
                                                                                        PortalConstants.APPLICATION_KEY=>currentApplicationList[0],
                                                                                        PortalConstants.KEY_SHOULD_DENY=>shouldDeny,
                                                                                        PortalConstants.ACCOUNT_KEY=>borrowerInfoMap.get(PortalConstants.ACCOUNT_KEY),
                                                                                        PortalConstants.CONTACT_KEY=>borrowerInfoMap.get(PortalConstants.CONTACT_KEY),
                                                                                        PortalConstants.KEY_PARTY=>borrowerInfoMap.get(PortalConstants.KEY_PARTY)
                                                                                    },principalPartyList);
                        
                //Evergreen Check
                PortalAppSubmissionValidationUtil.validationForEvergreenApplication(currentApplicationList[0],shouldDeny);
                

                //performing all the neccessary operations for saving the application like generating the pricing and generating loan number
                isAutoBookPossible=saveAndContinueApplication(new Map<String,Object>{
                                                                        PortalConstants.IS_AUTOBOOK_POSSIBLE=>isAutoBookPossible,
                                                                        PortalConstants.APPLICATION_KEY=>applicationObj,
                                                                        PortalConstants.KEY_SHOULD_DENY=>shouldDeny,
                                                                        PortalConstants.KEY_BORROWER_ACC=>borrowerAccountId,
                                                                        PortalConstants.KEY_MY_PROGRAM=>applicationMyProgramObj,
                                                                        PortalConstants.LOGGED_IN_USER=>loggedInUser
                                                                }, new Map<String,List<Object>>{
                                                                        PortalConstants.CURRENT_APPLICATION=>currentApplicationList,
                                                                        PortalConstants.KEY_PRINCIPAL=>principalPartyList,
                                                                        PortalConstants.KEY_PRINICPAL_ACC=>principalAccountIdList,
                                                                        PortalConstants.KEY_PRICING=>applicationPricingList
                                                                });
                
            }
            

            System.debug('----------->2' + activePricingCount);
            // updating the statement code
            PortalApplicationSubmissionHandler.updateStatementCode(currentApplicationList[0],coopType, activePricingCount);
            

            //Change the Stage to Scoring and Credit Reference
            applicationObj.Stage__c = PortalConstants.SCORE_CREDIT_REFERENCE;
            
            //Creating the Sales Agent and Sales Agent Admin Party 
            PortalApplicationCreationHandler.addSalesAgentParty(currentApplicationList[0]);
            PortalApplicationCreationHandler.createSharingRecordsForSAAdmin(currentApplicationList[0]);
            PortalApplicationCreationHandler.createSharingRecordsForSA(currentApplicationList[0]);

          
            //if the difference in crop year between this application and its parent application(if evergreen) is > 1, an exception must be thrown
            cropYearCheckForEvergreen(currentApplicationList[0]);

            //checking for the tasks related to the application and updating its statuses
            PortalApplicationSubmissionHandler.checkTask(currentApplicationList,shouldDeny);

            //updating all the application details in the database.
            Database.update(currentApplicationList,true);
            
            //isAutoBookPossible will get updated based on the Guarantee on the application 
            //also, this is to check if the sum of loan amount of all the active and closed loans plus the loan amount of this application does not exceed the loan limit for autobooking
            isAutoBookPossible = PortalApplicationSubmissionHandler.checkIsAutobookPossible(currentApplicationList, isAutoBookPossible);

            // book the application now if autobook is possible
            if(isAutoBookPossible 
                        && (currentApplicationList[0].Coop_Type__c == PortalConstants.GROWMARK_COOP_TYPE
                                || currentApplicationList[0].Dealer_Name__r.CFA_Partner_Program__r.Allow_Auto_Booking__c)) {
                System.enqueueJob(new NLSBookToCoreCIFCalloutClass(currentApplicationList[0].Id));
            }

            //creates the response to be returned tothe portal.
            createResponse(currentApplicationList[0],isAutoBookPossible);
        
        } catch (CustomException e) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = e.getMessage();
            PortalHelper.saveExceptionLog(e, PortalApplicationSubmissionAPI.class.getName());
        } 
        catch (Exception e) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
            PortalHelper.saveExceptionLog(e, PortalApplicationSubmissionAPI.class.getName());
        }
        return response;
    }

    /**
    * @description this function executes when the cl chooses save and exit on the scoring and credit reference page
    * @author Rakesh Saraf | 10-22-2024 
    * @param paramMap
    **/
    private static void saveAndExitApplication(Map<String,Object> paramMap){
        
        genesis__Applications__c currentApplicationObj=(genesis__Applications__c) paramMap.get(PortalConstants.APPLICATION_KEY);
        Boolean shouldDeny=(Boolean) paramMap.get(PortalConstants.KEY_SHOULD_DENY);
        genesis__Rate_Card_Setup_Header__c applicationMyProgramObj=(genesis__Rate_Card_Setup_Header__c) paramMap.get(PortalConstants.KEY_MY_PROGRAM);  
        
        //SAVE AND EXIT---->Simply insert the objects without validations and workflow
        if(shouldDeny){
            return;
        }
        
        //updating the terms of the application
        if(!currentApplicationObj.Flex_Rate_Pricing__c & 
            currentApplicationObj.My_Program__c != null & 
                applicationMyProgramObj!=null){
                    PortalApplicationSubmissionHandler.updateApplicationTerms(currentApplicationObj,applicationMyProgramObj);


            // update the expected start date & the expected 1st payment
            // date for the application if the My Program is created after the application
            
            if(currentApplicationObj.genesis__Expected_Start_Date__c <= applicationMyProgramObj.genesis__Start_Date__c) {

                currentApplicationObj.genesis__Expected_Start_Date__c = applicationMyProgramObj.genesis__Start_Date__c.addDays(1);
                currentApplicationObj.genesis__Expected_First_Payment_Date__c = currentApplicationObj.genesis__Expected_Start_Date__c.addMonths(1);
            }
        }
    }
    
    /**
    * @description this function executes when the cl chooses save and continue on the scoring and credit reference page
    * @author Rakesh Saraf | 10-28-2024 
    * @param paramMap 
    * @param paramListMap 
    * @return Boolean 
    **/
    private static Boolean saveAndContinueApplication(Map<String,Object> paramMap,Map<String,List<Object>> paramListMap){
        Boolean isAutoBookPossible=(Boolean) paramMap.get(PortalConstants.IS_AUTOBOOK_POSSIBLE);
        Boolean shouldDeny=(Boolean) paramMap.get(PortalConstants.KEY_SHOULD_DENY);
        genesis__Rate_Card_Setup_Header__c applicationMyProgramObj=(genesis__Rate_Card_Setup_Header__c) paramMap.get(PortalConstants.KEY_MY_PROGRAM);
        User loggedInUser=(User) paramMap.get(PortalConstants.LOGGED_IN_USER);

        
        List<genesis__Applications__c> currentApplicationList=(List<genesis__Applications__c>) paramListMap.get(PortalConstants.CURRENT_APPLICATION);
        List<genesis__Application_Pricing_Detail__c> applicationPricingList=(List<genesis__Application_Pricing_Detail__c>) paramListMap.get(PortalConstants.KEY_PRICING);
        
        
        //if the dealer is not Growmark and is not allowed to customise a loan. Then throw an error "Please contact CFA if you’d like to customize."
        if(currentApplicationList[0].Credit_Application_And_Agreement_Process__c == PortalConstants.CUSTOMIZE_LOAN &&
                currentApplicationList[0].Coop_Type__c != PortalConstants.GROWMARK_COOP_TYPE 
                & (String.isBlank(String.valueOf(currentApplicationList[0].Dealer_Name__r.genesis__Business_Information__r.Customised_Individual_Limit__c)) ||
                currentApplicationList[0].Dealer_Name__r.genesis__Business_Information__r.Customised_Individual_Limit__c < currentApplicationList[0].genesis__Loan_Amount__c || 
                String.isBlank(String.valueOf(currentApplicationList[0].Dealer_Name__r.genesis__Business_Information__r.Customised_Loan_Limit__c)) ||
                currentApplicationList[0].Dealer_Name__r.genesis__Business_Information__r.Customised_Loan_Limit__c < currentApplicationList[0].genesis__Loan_Amount__c)){
                    throw new CustomException(PortalConstants.DEALER_CUSTOMISE_LIMIT_EXCEEDED);
        }
        
        


        //Generating the pricing for this particular applicationObj
        if(!shouldDeny & 
            currentApplicationList[0].Flex_Rate_Pricing__c == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }

        if(!shouldDeny & 
            !currentApplicationList[0].Flex_Rate_Pricing__c){
                PortalApplicationSubmissionHandler.generatePricing(currentApplicationList[0],applicationMyProgramObj);
        }

        if(shouldDeny){
            //is not recommmended, set the application status to rejected
            currentApplicationList[0].genesis__Status__c = PortalConstants.REJECTED_APPLICATION_STATUS;
        }
        else if(currentApplicationList[0].Credit_Application_And_Agreement_Process__c != PortalConstants.CUSTOMIZE_LOAN ){
            
            //AUTOBOOK Checks
            isAutoBookPossible=PortalApplicationSubmissionHandler.updateAutoBook(paramMap,paramListMap);
        }
        else{
            //the credit application and agreement process is customized, so it will not be autobooked.
            currentApplicationList[0].genesis__Status__c = PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS;
        }
        
        //generating the loan number for the application
        PortalApplicationSubmissionHandler.generatesLoanNumber(currentApplicationList[0],shouldDeny);

        //query on the pricing details that gets generated and populated the loan number
        activePricingCount = PortalApplicationSubmissionHandler.updateApplicationPricing(currentApplicationList[0],applicationPricingList, activePricingCount);
        System.debug('----------->1' + activePricingCount);

        //Populating the Submission Date of the application after all the validations are successful
        currentApplicationList[0].Submitted_to_CFA__c = System.today();

        //Populating the Certified Lenders Signatures after all the validation are successful.
        PortalApplicationSubmissionHandler.updateCertifiedLendersSignature(currentApplicationList[0],loggedInUser);
        
        return isAutoBookPossible;
    }

    /**
    * @description function to throw an exception if the application is evergreen and difference between the crop year with the parent application is greater than 1.
    * @author Rakesh Saraf | 10-29-2024 
    * @param currentApplicationObj 
    **/
    private void cropYearCheckForEvergreen(genesis__Applications__c currentApplicationObj){

        //if the application is not evergreen or it does not have a my program/flex rate(in case of save and exit), we do nothing.
        if(currentApplicationObj.Is_Evergreen__c != true | 
            String.isBlank(currentApplicationObj.Crop_Year__c)){
                return;
        }
        
        
        Integer diffInYears  = (Integer.valueOf(currentApplicationObj.Crop_Year__c)-Integer.valueOf(currentApplicationObj.genesis__Parent_Application__r.Crop_Year__c));

        //difference should not be > 1 years between the crop year of this application andthe parent application
        if(diffInYears > 1){
            throw new CustomException(PortalConstants.EVERGREEN_CROP_YEAR_EXCEPTION);
        }
    }


    /**
    * @description creates a response to be returned to portal
    * @author Rakesh Saraf | 10-29-2024 
    * @param applicationObj 
    * @param isAutoBookPossible 
    **/
    private void createResponse(genesis__Applications__c applicationObj,Boolean isAutoBookPossible){
        fieldsMap.put(PortalConstants.KEY_STATUS, applicationObj.genesis__Status__c);
        fieldsMap.put(PortalConstants.KEY_IS_AUTOBOOKING, isAutoBookPossible);

        //creating a response to be retuned to the portal
        
        responseData.add(new clcommon.PortalCustomRemoteActionRecord(fieldsMap));
        clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
        response.content = null;
        response.response = responseFormat.response;
        response.status = clcommon.Constants.SUCCESS;
    }

}