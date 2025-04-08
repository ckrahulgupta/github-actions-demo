/**
 * @description       :  This is a controller class for Base Rate Change LWC
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 02-04-2025
**/
public inherited sharing class BaseRateChangeController {
    private static final String CFA_ADVANTAGE_RATE = ConstantValues.CFA_ADVANTAGE_RATE;
    private static final String FIELD_FINANCE_RATE = ConstantValues.FIELD_FINANCE_RATE;
    private static final String FS_INDEX_RATE = ConstantValues.FS_INDEX_RATE;
    private static final String LIST_EMPTY_CHECK = ConstantValues.LIST_EMPTY_CHECK;
    private static final String CROPYEAR_XXI = ConstantValues.CROPYEAR_XXI;
    private static final String CROPYEAR_XXII = ConstantValues.CROPYEAR_XXII;
    private static final String CROPYEAR_XXIII = ConstantValues.CROPYEAR_XXIII;
    
    private static final String CFA = ConstantValues.CFA_COOP_TYPE;
    private static final String LANDUS = ConstantValues.LANDUS_COOP_TYPE;
    private static final String GROWMARK = ConstantValues.GROWMARK_COOP_TYPE;
    private static final String EMPTY_PARAMETERS = ConstantValues.EMPTY_PARAMETERS;
    private static final String KEY_LABEL = 'label';
    private static final String KEY_VALUE = 'value';
    private static final String KEY_ERROR_MESSAGE = 'Error updating rates: '; 
    private static final String KEY_CFA_CONFIG_NOT_FOUND = 'CFA Configuation Not Found';
    private static final String KEY_NEW_INTEREST_RATE = 'newInterestRate';
    private static final String KEY_CURRRENT_INTEREST_RATE = 'currentInterestRate';
    private static final String KEY_RATE_TYPE = 'selectedRate';



    /**
     * @description       :  This is a wrapper class for storing the Rate Info
     * @author            :  Sounak Ganguly
     * @group             : 
     * @last modified on  : 02-04-2025
    **/
    public class RateInfoWrapper {
        public String newInterestRate;
        public String currentInterestRate;
        public String selectedRate;
    }
    /**
    * @description : Get base rate options for the dropdown in the LWC
    * @author  Sounak Ganguly | 06-24-2024 
    * @return List<Map<String, String>> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getBaseRateOptions() {
        List<Map<String, String>> options = new List<Map<String, String>>();
        List<clcommon__Floating_Rate_Index__c> baseRateIndexes = [
            SELECT Name
            FROM clcommon__Floating_Rate_Index__c
            WHERE clcommon__Active__c = true 
            WITH SECURITY_ENFORCED
        ];
        for (clcommon__Floating_Rate_Index__c index : baseRateIndexes) {
            Map<String, String> option = new Map<String, String>();
            option.put(KEY_LABEL, index.Name);
            option.put(KEY_VALUE, index.Name);
            options.add(option);
        }
        Map<String, String> option = new Map<String, String>();
        option.put(KEY_LABEL, FS_INDEX_RATE);
        option.put(KEY_VALUE, FS_INDEX_RATE);
        options.add(option);

        return options;
    }

    /**
    * @description : Get current interest rates for active floating rate indexes
    * @author  Sounak Ganguly | 06-24-2024 
    * @return Map<String, Decimal> 
    **/
    @AuraEnabled(cacheable=true)
    public static Map<String, Decimal> getCurrentInterestRate() {
        Map<String, Decimal> interestRates = new Map<String, Decimal>();
        List<CFA_Configuration__c> cfaConfigList = new List<CFA_Configuration__c>();
        List<clcommon__Floating_Rate_Index__c> baseRates = [
            SELECT Name, Current_Floating_Rate__c
            FROM clcommon__Floating_Rate_Index__c
            WHERE clcommon__Active__c = true
            WITH SECURITY_ENFORCED
        ];
        for (clcommon__Floating_Rate_Index__c rate : baseRates) {
            interestRates.put(rate.Name, rate.Current_Floating_Rate__c);
        }
        cfaConfigList = getCFAConfigurtion();
        interestRates.put(FS_INDEX_RATE, cfaConfigList[0].FS_Index_Rate__c);
        return interestRates;
    }

    /**
     * @description Querying the CFA Configuration
     * @return  `List<CFA_Configuration__c>`
     * @exception 
     */
    private static List<CFA_Configuration__c> getCFAConfigurtion(){
        List<CFA_Configuration__c> cfaConfigList = [SELECT Id,
                                                        FS_Index_Rate__c
                                                    FROM CFA_Configuration__c  
                                                    WITH SECURITY_ENFORCED
                                                    LIMIT 1];
        if(cfaConfigList.isEmpty()){
            throw new CustomException(KEY_CFA_CONFIG_NOT_FOUND);
        }
        return cfaConfigList;
    }

    /**
     * @description Updating CFA config's FS Index rate
     * @param newInterests 
     */
    private static void updateFSIndexRate(String newInterests){
        List<CFA_Configuration__c> cfaConfigList = getCFAConfigurtion();

        cfaConfigList[0].FS_Index_Rate__c = Decimal.valueOf(newInterests);
        if (Schema.sObjectType.CFA_Configuration__c.isUpdateable()) {
            Database.update(cfaConfigList,true);
        }
        
    }

    /**
     * @description : Update the interest rate for the selected rate index and create a new floating rate record
     * @author  Sounak Ganguly | 06-27-2024 
     * @param selectedRate 
     * @param newInterestRate 
     * @param currentInterestRate
     **/
    @AuraEnabled
    public static void updateInterestRate(String selectedRate, String newInterestRate, String currentInterestRate) {
        try {
            validateParameters(selectedRate, newInterestRate, currentInterestRate);
            if(selectedRate != FS_INDEX_RATE){
                clcommon__Floating_Rate_Index__c floatingRate = getFloatingRateIndex(selectedRate);
                updateCurrentFloatingRate(floatingRate, newInterestRate);
                
                clcommon__Floating_Rate__c floatingRateRecord = getOrCreateFloatingRateRecord(floatingRate, newInterestRate);
                upsertFloatingRate(floatingRateRecord);
            }
            else{
                updateFSIndexRate(newInterestRate);
            }

            List<genesis__Rate_Card_Setup_Header__c> presentMyProgramsList = getFilteredPrograms(selectedRate);
            updateProgramsList(presentMyProgramsList);

            Map<String,String> paramMap = new Map<String,String>{
                KEY_NEW_INTEREST_RATE => newInterestRate,
                KEY_CURRRENT_INTEREST_RATE => currentInterestRate,
                KEY_RATE_TYPE => selectedRate
            };

            executeBatchJob(paramMap, presentMyProgramsList);
            
        } catch (Exception e) {
            LoggingUtility.saveExceptionLogging(e, BaseRateChangeController.class.getName());
            throw new AuraHandledException(KEY_ERROR_MESSAGE + e.getMessage());
        }
    }

    /**
     * @description : Validate the input parameters for null or empty values
     * @author  Sounak Ganguly | 06-27-2024 
     * @param selectedRate 
     * @param newInterestRate 
     * @param currentInterestRate
     **/
    private static void validateParameters(String selectedRate, String newInterestRate, String currentInterestRate) {
        checkParameters(selectedRate);
        checkParameters(newInterestRate);
        checkParameters(currentInterestRate);
    }

    /**
     * @description : Retrieve the floating rate index based on the selected rate name and active status
     * @author  Sounak Ganguly | 06-27-2024 
     * @param selectedRate 
     * @return clcommon__Floating_Rate_Index__c
     **/
    private static clcommon__Floating_Rate_Index__c getFloatingRateIndex(String selectedRate) {
        List<clcommon__Floating_Rate_Index__c> floatingRates = [
            SELECT Id, Current_Floating_Rate__c
            FROM clcommon__Floating_Rate_Index__c
            WHERE Name = :selectedRate
            AND clcommon__Active__c = true
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (floatingRates.isEmpty()) {
            throw new CustomException(LIST_EMPTY_CHECK);
        }
        
        return floatingRates[0];
    }

    /**
     * @description : Update the current floating rate for the given floating rate index with the new interest rate
     * author  Sounak Ganguly | 06-27-2024 
     * @param floatingRate 
     * @param newInterestRate
     **/
    private static void updateCurrentFloatingRate(clcommon__Floating_Rate_Index__c floatingRate, String newInterestRate) {
        floatingRate.Current_Floating_Rate__c = Decimal.valueOf(newInterestRate);

        if (Schema.sObjectType.clcommon__Floating_Rate_Index__c.isUpdateable()) {
            Database.update(floatingRate);
        }
    }

    /**
     * @description : Get or create a floating rate record for the given floating rate index and new interest rate
     * author  Sounak Ganguly | 06-27-2024 
     * @param floatingRate 
     * @param newInterestRate 
     * @return clcommon__Floating_Rate__c
     **/
    private static clcommon__Floating_Rate__c getOrCreateFloatingRateRecord(clcommon__Floating_Rate_Index__c floatingRate, String newInterestRate) {
        List<clcommon__Floating_Rate__c> existingRates = [
            SELECT Id
            FROM clcommon__Floating_Rate__c
            WHERE clcommon__Floating_Rate_Index__c = :floatingRate.Id
            AND clcommon__Start_Date__c = :Date.today()
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        clcommon__Floating_Rate__c floatingRateRecord;

        if (!existingRates.isEmpty()) {
            floatingRateRecord = existingRates[0];
            floatingRateRecord.clcommon__Rate__c = Decimal.valueOf(newInterestRate);
        } else {
            floatingRateRecord = new clcommon__Floating_Rate__c();
            floatingRateRecord.clcommon__Floating_Rate_Index__c = floatingRate.Id;
            floatingRateRecord.clcommon__Rate__c = Decimal.valueOf(newInterestRate);
            floatingRateRecord.clcommon__Start_Date__c = Date.today();
        }
        
        return floatingRateRecord;
    }

    /**
     * @description : Upsert the floating rate record based on its existence and permissions
     * author  Sounak Ganguly | 06-27-2024 
     * @param floatingRateRecord
     **/
    private static void upsertFloatingRate(clcommon__Floating_Rate__c floatingRateRecord) {
        if (Schema.sObjectType.clcommon__Floating_Rate__c.isCreateable() || Schema.sObjectType.clcommon__Floating_Rate__c.isUpdateable()) {
            Database.upsert(floatingRateRecord);
        }
    }

    /**
     * @description : Update the list of rate card setup headers with the filtered programs list
     * author  Sounak Ganguly | 06-27-2024 
     * @param presentMyProgramsList
     **/
    private static void updateProgramsList(List<genesis__Rate_Card_Setup_Header__c> presentMyProgramsList) {
        checkEmptyList(presentMyProgramsList);

        if (Schema.sObjectType.genesis__Rate_Card_Setup_Header__c.isUpdateable()) {
            Database.update(presentMyProgramsList, true);
        }
    }

   /**
    * @description  Execute the batch job for base rate change with the provided parameters and program list
    * author  Sounak Ganguly | 06-27-2024 
    * @param paramMap 
    * @param presentMyProgramsList 
    */
    private static void executeBatchJob(Map<String,String> paramMap, List<genesis__Rate_Card_Setup_Header__c> presentMyProgramsList) {
        RateInfoWrapper objWrapper = new RateInfoWrapper();
        objWrapper.newInterestRate = paramMap.get(KEY_NEW_INTEREST_RATE);
        objWrapper.currentInterestRate = paramMap.get(KEY_CURRRENT_INTEREST_RATE);
        objWrapper.selectedRate = paramMap.get(KEY_RATE_TYPE);

        BaseRateChangeBatch objBaseRateChangeBatch = new BaseRateChangeBatch(objWrapper, presentMyProgramsList);
        Database.executeBatch(objBaseRateChangeBatch, 1);
    }


    /**
    * @description : Check if the parameter is null and throw a custom exception if it is
    * @author  Pritam Roy | 04-12-2024 
    * @param objParameter 
    **/
    private static void checkParameters(String objParameter) {
        if (objParameter == null) {
            throw new CustomException(EMPTY_PARAMETERS);
        }
    }

    /**
    * @description : Check if the list is empty and throw a custom exception if it is
    * @param objList 
    **/
    private static void checkEmptyList(List<Object> objList) {
        if (objList.isEmpty()) {
            throw new CustomException(LIST_EMPTY_CHECK);
        }
    }

    /**
    * @description : Get Filtered Programs
    * @author  Pritam Roy | 04-12-2024 
    * @param selectedRate 
    * @return List<genesis__Rate_Card_Setup_Header__c> 
    **/
    public static List<genesis__Rate_Card_Setup_Header__c> getFilteredPrograms(String selectedRate) {
         // Separate method for coop types
        List<String> partnerProgramList = new List<String>();
        List<String> cropYearList = new List<String>();
        cropYearList.add(CROPYEAR_XXI);
        cropYearList.add(CROPYEAR_XXII);
        cropYearList.add(CROPYEAR_XXIII);
      
        if(selectedRate.equals(FS_INDEX_RATE)){
            return [SELECT Id,
                      CFA_Advantage_Rate__c,
                      Field_Finance_Rate__c,
                      FS_Index_Rate__c,
                      Account__r.CFA_Partner_Program__r.Name
                  FROM genesis__Rate_Card_Setup_Header__c
                  WHERE Account__r.Coop_Type__c =: ConstantValues.GROWMARK_COOP_TYPE
                  WITH SECURITY_ENFORCED];
        }
        else if (selectedRate.equals(CFA_ADVANTAGE_RATE)) {  // Update condition for CFA
            partnerProgramList = getPartnerProgram(selectedRate);
            return [SELECT Id,
                        CFA_Advantage_Rate__c,
                        Field_Finance_Rate__c,
                        FS_Index_Rate__c,
                        Account__r.CFA_Partner_Program__r.Name
                    FROM genesis__Rate_Card_Setup_Header__c
                    WHERE Crop_Year__c IN: cropYearList
                    AND Account__r.CFA_Partner_Program__r.Name IN :partnerProgramList
                    WITH SECURITY_ENFORCED];
        } else {
            partnerProgramList = getPartnerProgram(selectedRate);
            return [SELECT Id,
                        CFA_Advantage_Rate__c,
                        Field_Finance_Rate__c,
                        FS_Index_Rate__c,
                        Account__r.CFA_Partner_Program__r.Name
                    FROM genesis__Rate_Card_Setup_Header__c
                    WHERE Crop_Year__c NOT IN: cropYearList  // Maintain filter for other rates
                    AND Account__r.CFA_Partner_Program__r.Name IN :partnerProgramList
                    WITH SECURITY_ENFORCED];
        }
    }

    /**
    * @description : Get coop types based on the selected rate name
    * @param selectedRate 
    * @return List<String> 
    **/

    @TestVisible
    private static List<String> getPartnerProgram(String selectedRate) {
        List<String> partnerProgramList = new List<String>();
        String rateName = selectedRate.replace(ConstantValues.UNDERSCORE_STRING, ConstantValues.SPACE_STRING);

        List<CFA_Partner_Program__c> partnerPrograms = [
            SELECT Name
            FROM CFA_Partner_Program__c
            WHERE Base_Rate__r.Name = :rateName
            WITH SECURITY_ENFORCED
        ];

        for (CFA_Partner_Program__c program : partnerPrograms) {
            partnerProgramList.add(program.Name);
        }

        return partnerProgramList;
    }
}