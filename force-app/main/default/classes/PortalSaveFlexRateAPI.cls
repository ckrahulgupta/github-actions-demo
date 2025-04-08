/**
 * @description       :  Save Flex Rate Details API
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 10-04-2024
 * @last modified by  : Rakesh Saraf
**/
global without sharing class PortalSaveFlexRateAPI implements clcommon.PortalCustomRemoteAPI1{
    //Constants specific to this class starts
    private static final String APPLICATION_ID = PortalConstants.APPLICATION_ID;
    private static final String KEY_SHOULD_VALIDATE = 'shouldValidate';
    private static final String DO_YOU_RECOMMEND = 'Do_You_Recommend_This_Applicant__c';
    private static final String NEGATIVE_VALUE = 'No';
    private static final String MY_PROGRAM_ID = 'myProgramId';
    //Constants specific to this class ends

    /**
    * @description Counts Rate Card Details in Flex Rate
    * @author  Pritam Roy | 04-17-2024 
    * @param flexId 
    **/
    private static void countRateCardDetails(String flexId){
        List<genesis__Rate_Card_Setup_Detail__c> objRateCardList = [SELECT Id,
                                                                            Name,
                                                                            genesis__rate_card_setup_header__c
                                                                        FROM genesis__Rate_Card_Setup_Detail__c
                                                                        WHERE genesis__rate_card_setup_header__c =: flexId];
        if(objRateCardList.size()==0){
            throw new CustomException(PortalConstants.NO_RATE_CARDS_EXIST);
        }
    }

    /**
    * @description : Validate App Id
    * @author  Pritam Roy | 07-25-2024 
    * @param applicationId 
    **/
    private static void validateAppId(String applicationId){
        if (String.isBlank(applicationId)){
            throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
        }
    }

    /**
    * @description : Save Flex Rate in Application
    * @author  Pritam Roy | 07-18-2024 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                        String[] disclosureNames,
                                        Map<String, Object> argumentsFromPortal) {
        SavePoint dbSavePoint = Database.setSavepoint();                                    
        String coopType;
        String programId;
        String applicationId;
        Boolean shouldDeny = true;
        Boolean shouldValidate = true;
        clcommon.Response response = new clcommon.Response(); 
        List<clcommon.PortalCustomRemoteActionRecord> respData = new List<clcommon.PortalCustomRemoteActionRecord>();
        Map<String, Object> fields = new Map<String, Object>();                                   
        try{

            //Get Application
            applicationId = String.valueOf(argumentsFromPortal.get(APPLICATION_ID));
            shouldValidate = Boolean.valueOf(argumentsFromPortal.get(KEY_SHOULD_VALIDATE));

            if(String.valueOf(argumentsFromPortal.get(DO_YOU_RECOMMEND)) == NEGATIVE_VALUE){
                shouldDeny = false;
            }

            if(!shouldDeny){
                response.status = clcommon.Constants.SUCCESS;
                return response;
            }
            validateAppId(applicationId);

            //Validate User Application
            PortalApplicationOriginationHelper.validateUser(applicationId);

            //Get Coop Type
            coopType = PortalApplicationOriginationHelper.getCoopType(applicationId);
            if(coopType != PortalConstants.GROWMARK_COOP_TYPE){
                programId = PortalCreateMyProgramAPI.createFlexRateCard(applicationId, argumentsFromPortal);
            }else{
                GMKPortalCreateMyProgramAPI myProgramAPI = new GMKPortalCreateMyProgramAPI();
                programId = myProgramAPI.createFlexRateCard(applicationId, argumentsFromPortal);
            }

            List<genesis__Applications__c> objAppList = [SELECT Id,
                                                                Flex_Rate_Pricing__c,
                                                                My_Program__c
                                                            FROM genesis__Applications__c 
                                                            WHERE id =: applicationId];
            if(objAppList[0].Flex_Rate_Pricing__c != true ){                                                
                objAppList[0].Flex_Rate_Pricing__c = true;
                Database.update(objAppList, true);
            }
            
            //Count Rate Card Details
            if(shouldValidate){
                countRateCardDetails(programId);
            }
            fields.put(MY_PROGRAM_ID, programId);
            respData.add(new clcommon.PortalCustomRemoteActionRecord(fields));
            clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(respData);
            response.content = null;
            response.response = responseFormat.response;
            response.status = clcommon.Constants.SUCCESS;
        }catch(CustomException objCustomException){
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
}