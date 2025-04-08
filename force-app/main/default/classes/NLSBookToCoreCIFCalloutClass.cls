/**
 * @description       : This class is used for booking the CIF and Booking the Loan.
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 02-14-2025
 * @last modified by  : Ayush Kumar Singh
**/
global without sharing class NLSBookToCoreCIFCalloutClass implements Queueable , Database.AllowsCallouts{

    private static final String PRINCIPAL_PARTY = 'principalParty';
    private static final String CLASS_NAME = NLSBookToCoreCIFCalloutClass.class.getName();
    private static final String INTEGRATION_API_TYPE = 'Post CIF Book To Core NLS Integration API Type';
    string applicationId;
    List<String> partyTypesList = new List<String>();
    /**
    * @description : Constructor is used for assigning the application Id.
    * @author Suraj Kumar | 01-31-2024 
    * @param applicationId 
    **/
    global NLSBookToCoreCIFCalloutClass(string applicationId){
        this.applicationId = applicationId;
    }
    /**
    * @description : This method is used for booking the CIF (If Required) calls the Integration framework Post CIF Book To Core NLS Integration API Type
    *                and booking the loan.
    * @author Suraj Kumar | 01-31-2024 
    * @param context 
    **/
    public void execute(QueueableContext context) {
        Map<String, Object> requestParamMap = new Map<String, Object>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        try{
            List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                                    genesis__Account__c
                                                                FROM genesis__Applications__c
                                                                WHERE Id = :applicationId
                                                                LIMIT 1];
            PortalApplicationOriginationHelper.checkEmptyList(applicationList, ConstantValues.SOMETHING_WENT_WRONG);

            List<clcommon__party__c> borrowerPartiesList = [SELECT Id,
                                                                clcommon__Account__c,
                                                                genesis__Application__c
                                                            FROM clcommon__party__c
                                                            WHERE clcommon__Account__c = :applicationList[0].genesis__Account__c
                                                            AND genesis__Application__r.genesis__status__c =: ConstantValues.ACTIVE
                                                            AND clcommon__Type__r.Name =: ConstantValues.BORROWER_PARTY];
            if(!borrowerPartiesList.isEmpty()){
                System.enqueueJob(new NLSBookToCoreCalloutClass(applicationId));
            } else {
                intframework.BaseIntegrationResponse responseObject;
                intframework.AbstractIntegrationService baseIntegrationService;
                queryIdMap.put(ConstantValues.APPLICATION_ID_KEY,applicationId);
                partyTypesList.add(ConstantValues.BORROWER_PARTY);
                partyTypesList.add(ConstantValues.PRINCIPAL_PARTY);
                queryIdMap.put(PRINCIPAL_PARTY,partyTypesList);
                //Calling the integration framework
                baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
                responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService( ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                    INTEGRATION_API_TYPE,
                                                                                                                                    queryIdMap, requestParamMap);
               
                System.enqueueJob(new NLSBookToCoreCalloutClass(applicationId));
            }       
        }
        catch (Exception exceptionObj) {
            LoggingUtility.saveExceptionLogging(exceptionObj, NLSBookToCoreCIFCalloutClass.class.getName());
        }
    }
    /**
    * @description : This method is called from the Skuid by clicking book to Core button to book the CIF 
    *                calls the Integration framework Post CIF Book To Core NLS Integration API Type.
    * @author Suraj Kumar | 01-31-2024 
    * @param applicationId 
    * @return String 
    **/
    webservice static String bookToCoreCIFFromBackEnd(String applicationId) {
        List<String> partyTypesList = new List<String>();
        Map<String, Object> queryIdMap = new Map<String, Object>();
        Map<String, Object> requestParamMap = new Map<String, Object>();
        try{
            //prevent from booking the loan if Borrower or any principal party is associated with any non accrual loan
            //CFAS-6894
            validateBookingForNonAccrualParties(applicationId);
            List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                                    genesis__Account__c
                                                                FROM genesis__Applications__c
                                                                WHERE Id = :applicationId
                                                                LIMIT 1];
            CFAOriginationHelperClass.checkEmptyList(applicationList, ConstantValues.SOMETHING_WENT_WRONG);
            List<clcommon__party__c> borrowerPartiesList = [SELECT Id,
                                                                clcommon__Account__c,
                                                                genesis__Application__c
                                                            FROM clcommon__party__c
                                                            WHERE clcommon__Account__c = :applicationList[0].genesis__Account__c
                                                            AND genesis__Application__r.genesis__status__c =: ConstantValues.ACTIVE
                                                            AND clcommon__Type__r.Name =: ConstantValues.BORROWER_PARTY];
            if(borrowerPartiesList.isEmpty()){ 
                intframework.BaseIntegrationResponse responseObject;
                intframework.AbstractIntegrationService baseIntegrationService;
                queryIdMap.put(ConstantValues.APPLICATION_ID_KEY,applicationId);
                partyTypesList.add(ConstantValues.BORROWER_PARTY);
                partyTypesList.add(ConstantValues.PRINCIPAL_PARTY);
                queryIdMap.put(PRINCIPAL_PARTY,partyTypesList);
                //Calling the integration framework
                baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
                responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService( ConstantValues.NLS_INTEGRATION_FAMILY,
                                                                                                                                    INTEGRATION_API_TYPE,
                                                                                                                                    queryIdMap, requestParamMap);

            }
        }
        catch (CustomException customExceptionObj){
            LoggingUtility.saveExceptionLogging(customExceptionObj, NLSBookToCoreCIFCalloutClass.class.getName());
        } 
        catch (Exception exceptionObj) {
            LoggingUtility.saveExceptionLogging(exceptionObj, NLSBookToCoreCIFCalloutClass.class.getName());
        } 
        return ConstantValues.SUCCESS_STATUS;
    }

    /**
    * @description : This method is used to prevent the loan from booking 
    *                if Borrower or any principal party is associated with any other non accrual loan.
    * @author Suraj Kumar | 01-31-2024 
    * @param applicationId 
    **/
    private static void validateBookingForNonAccrualParties(String applicationId){
        //List<Id> borrowerPrincipalIdList = new List<Id>();
        List<clcommon__Party__c> partyList = [SELECT Id, 
                                                    Name, 
                                                    Dealer_Applicant_Relationship__c,
                                                    clcommon__Account__c,
                                                    clcommon__Contact__r.genesis__SSN__c 
                                        FROM clcommon__Party__c 
                                        WHERE genesis__Application__c = :applicationId 
                                        AND clcommon__Party_Types__c IN (:ConstantValues.BORROWER_PARTY, :ConstantValues.PRINCIPAL_PARTY) 
                                        AND (Dealer_Applicant_Relationship__r.Is_Non_Accrual__c = true OR Dealer_Applicant_Relationship__r.Has_Past_Due__c = true)];

        if(!partyList.isEmpty()){ 
            throw new CustomException(ConstantValues.ASSOCIATED_WITH_NON_ACCRUAL);
        }
    }
}