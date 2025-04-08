/**
 * @description       : Collects the id and passes it to the integration configuration
 * @author            :  subham nandi
 * @group             : 
 * @last modified on  : 01-22-2025
 * @last modified by  : Ayan Bhowmik
**/

global without sharing class FICOCallout implements Database.Batchable<sObject>, Database.AllowsCallouts{
    string partyQuery;
    string applicationId;
    string borrowerParty;
    string principalParty;
    // Constants specific to this class starts
    private static final String PARTY_ID = 'partyIdList';
    // Constants specific to this class starts

    /**
    * @description : FICO Callout Party Query
    * @author  Pritam Roy | 03-14-2024
    * @param applicationId
    **/
    global FICOCallout(string applicationId){
        this.applicationId = applicationId;
        borrowerParty = ConstantValues.BORROWER_PARTY;
        principalParty = ConstantValues.PRINCIPAL_PARTY;
        partyQuery = 'SELECT Id, '
                            + 'Name, '
                            + 'clcommon__Party_Types__c, '
                            + 'clcommon__Contact__c, '
                            + 'clcommon__Account__r.genesis__Business_Information__c,  '
                            + 'clcommon__Account__c '
                        + 'FROM clcommon__Party__c '
                        + 'WHERE genesis__Application__c = :applicationId AND '
                        + '(clcommon__Account__r.FICO_Recorded_On__c != LAST_N_DAYS:182 AND '
                        + '(clcommon__Party_Types__c = :borrowerParty OR ' 
                        + 'clcommon__Party_Types__c = :principalParty))'
                        + 'ORDER BY CreatedDate';
        
    }
  
    /**
    * @description : Batch Query Start
    * @author  Pritam Roy | 03-14-2024 
    * @param bC 
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext bC){
        //queries the principals
        return Database.getQueryLocator(partyQuery);
    }
  
    /**
    * @description Takes the partylist of principals in multiples of 2, adds the borrower and then calls the 
                    integration framework for every group of principal/borrower
    * @author Subham Nandi | 30-01-2022 
    * @param bC 
    * @param partyList 
    **/
    global void execute(Database.BatchableContext bC, List<clcommon__party__c> partyList){
  
        try{
            //Declarations specific to this method starts
            Set<String> partySet = new Set<String>();
            set<String> applicationSet = new Set<String>();
            intframework.BaseIntegrationResponse responseObject;
            Map<String, Object> queryMap = new Map<String, Object>();
            Map<String, Object> requestMap = new Map<String, Object>();
            intframework.AbstractIntegrationService baseIntegrationService;

            PortalApplicationOriginationHelper.checkBlankParameter(applicationId, PortalConstants.SOMETHING_WENT_WRONG);
            applicationSet.add(applicationId);            
            queryMap.put(PortalConstants.APPLICATION_ID,applicationSet);

            for(clcommon__party__c partyObj : partyList){
                partySet.add(partyObj.id);
            }
            queryMap.put(PARTY_ID, partySet);
            //Calling the integration framework
            baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.FICO_INT_FAMILY, ConstantValues.FICO_INT_TYPE, queryMap, requestMap);
  
        } catch (Exception exceptionObj) {
            PortalHelper.saveExceptionLog(exceptionObj, FICOCallout.class.getName());
        }
    }
    /**
    * @description After fetching all the scores from FICO for all the principal and the borrower, 
                    this takes the maximum score to be considered for the application and updates it on the application
    * @author Subham Nandi | 30-01-2022 
    * @param bC 
    **/
    public void finish(Database.BatchableContext bC){
        try{
            // Declarations specific to this Method starts
            String sbssScore;
            String ficoScore;
            List<clcommon__Party__c> borrowerPartyList = new List<clcommon__Party__c>();
            List<clcommon__party__c> partyForMaxNetWorthList = new List<clcommon__party__c>();
            List<genesis__Applications__c> applicationToUpdateList = new List<genesis__Applications__c>();
            // Declarations specific to this Method ends
            applicationToUpdateList = [SELECT Id, 
                                            (Select Id,
                                                    clcommon__Account__r.Score_1__c, 
                                                    clcommon__Account__r.SBSS70_Score__c  
                                                FROM genesis__Parties__r 
                                                WHERE (clcommon__Party_Types__c = :ConstantValues.PRINCIPAL_PARTY 
                                                OR (clcommon__Party_Types__c = :ConstantValues.BORROWER_PARTY 
                                                AND clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name = :PortalConstants.SOLE_PROP_ENTITY)) 
                                                AND clcommon__Account__r.SBSS70_Score__c != null 
                                                AND clcommon__Account__r.SBSS70_Score__c < :ConstantValues.MAXIMUM_ELIGIBLE_SBSS 
                                                AND clcommon__Account__r.Score_1__c != null
                                                AND clcommon__Account__r.Score_1__c < :ConstantValues.MAXIMUM_ELIGIBLE_FICO 
                                                ORDER BY clcommon__Account__r.Score_1__c DESC 
                                                LIMIT 1)
                                        FROM genesis__Applications__c 
                                        WHERE Id = :applicationId];
            PortalApplicationOriginationHelper.checkEmptyList(applicationToUpdateList, ConstantValues.SOMETHING_WENT_WRONG);
            for(clcommon__party__c partyObj : applicationToUpdateList[0].genesis__Parties__r){
                ficoScore = partyObj.clcommon__Account__r.Score_1__c;
                sbssScore = partyObj.clcommon__Account__r.SBSS70_Score__c;
            }
            partyForMaxNetWorthList = [SELECT  Id, 
                                                Net_Worth__c,
                                                clcommon__account__r.clcommon__Legal_Entity_Type__r.name 
                                        FROM clcommon__Party__c 
                                        WHERE genesis__Application__c = :applicationId AND
                                        Net_Worth__c != null AND
                                        (clcommon__Party_Types__c = :ConstantValues.PRINCIPAL_PARTY 
                                            OR clcommon__Party_Types__c = :ConstantValues.BORROWER_PARTY)
                                        AND clcommon__account__r.clcommon__Legal_Entity_Type__r.name !=: PortalConstants.INDIVIDUAL_ENTITY
                                        ORDER BY Net_Worth__c  DESC
                                        LIMIT 1];
            if(!applicationToUpdateList[0].genesis__Parties__r.isEmpty()){
                applicationToUpdateList[0].FICO_Score__c = ficoScore;
                applicationToUpdateList[0].SBSS_70_Score__c = sbssScore;
            }
            else{
                //Gets in only for an individual borrower with no other party associated with it
                borrowerPartyList = [SELECT  Id,
                                                clcommon__Account__r.Score_1__c, 
                                                clcommon__Account__r.SBSS70_Score__c 
                                        FROM clcommon__Party__c 
                                        WHERE genesis__Application__c = :applicationId AND 
                                        clcommon__Party_Types__c = :ConstantValues.BORROWER_PARTY AND
                                        clcommon__Account__r.SBSS70_Score__c != null AND
                                        clcommon__Account__r.Score_1__c != null LIMIT 1];
                if(!borrowerPartyList.isEmpty()){
                    applicationToUpdateList[0].FICO_Score__c = borrowerPartyList[0].clcommon__Account__r.Score_1__c;
                    applicationToUpdateList[0].SBSS_70_Score__c = borrowerPartyList[0].clcommon__Account__r.SBSS70_Score__c;
                }
            }
            if(!partyForMaxNetWorthList.isEmpty()){ 
                applicationToUpdateList[0].Net_Worth__c = String.valueOf(partyForMaxNetWorthList[0].Net_Worth__c);
            }
            Database.update(applicationToUpdateList, true);
        } catch (CustomException customExceptionObj) {
            PortalHelper.saveExceptionLog(customExceptionObj, FICOCallout.class.getName());
        } catch (Exception exceptionObj) {
            PortalHelper.saveExceptionLog(exceptionObj, FICOCallout.class.getName());
        }
    }
  
    /**
    * @description :FICO Called from Skuid
    * @author  Pritam Roy | 03-14-2024 
    * @param partyId 
    **/
    webservice static void ficoCalloutMethodForParty(String partyId) {
        try{
            List<User> loggedInUser;
            Set<String> partySet = new Set<String>();
            Set<String> applicationSet = new Set<String>();
            intframework.BaseIntegrationResponse responseObject;
            Map<String, Object> queryMap = new Map<String, Object>();
            Map<String, Object> requestMap = new Map<String, Object>();
            intframework.AbstractIntegrationService baseIntegrationService;

            PortalApplicationOriginationHelper.checkBlankParameter(partyId, ConstantValues.SOMETHING_WENT_WRONG);
            loggedInUser = getLoggedInUserProfile();
            if(!ConstantValues.PARTY_FICO_CALLOUT_PERMISSIONED_USER_LIST.contains(loggedInUser[0].Profile.Name)){
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }
            List<clcommon__Party__c> partyList =  [SELECT Id, 
                                                        Name, 
                                                        clcommon__Party_Types__c, 
                                                        clcommon__Contact__c,
                                                        genesis__Application__c,
                                                        genesis__Application__r.genesis__Account__c,
                                                        genesis__Application__r.genesis__Account__r.genesis__Business_Information__c
                                                    FROM clcommon__Party__c 
                                                    WHERE Id = :partyId];
            CFAOriginationHelperClass.checkEmptyList(partyList, ConstantValues.SOMETHING_WENT_WRONG);
            partySet.add(partyList[0].Id);
            applicationSet.add(partyList[0].genesis__Application__c);
            queryMap.put(PortalConstants.APPLICATION_ID,applicationSet);
            queryMap.put(PARTY_ID, partySet);
            //Calling the Integration Framework
            baseIntegrationService = intframework.IntegrationServiceFactory.getBaseIntegrationService();
            responseObject = (intframework.BaseIntegrationResponse)baseIntegrationService.runSynchronousIntegrationService(ConstantValues.FICO_INT_FAMILY,ConstantValues.FICO_INT_TYPE,queryMap, requestMap);
        
        } catch (CustomException customExceptionObj) {
            PortalHelper.saveExceptionLog(customExceptionObj, FICOCallout.class.getName());
        } catch (Exception exceptionObj) {
            PortalHelper.saveExceptionLog(exceptionObj, FICOCallout.class.getName());
        }
    }

    /**
    * @description The purpose of this method is to return logged in user profile.
    * @author Ayan Bhowmik | 01-22-2025 
    * @return List<User> 
    **/
    private static List<User> getLoggedInUserProfile(){
        List<User> loggedInUserList = [SELECT Id,
                                            Name, 
                                            ProfileId,
                                            Profile.Name
                                        FROM User 
                                        WHERE Id =: UserInfo.getUserId()
                                        LIMIT 1];
        PortalApplicationOriginationHelper.checkEmptyList(loggedInUserList, ConstantValues.SOMETHING_WENT_WRONG);
        return loggedInUserList;
    }
}