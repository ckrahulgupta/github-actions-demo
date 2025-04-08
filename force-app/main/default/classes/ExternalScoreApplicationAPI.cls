/**
 * @description       : External api, used to initiate scoring of an application 
 * @author            : Soumik Pattanayak
 * @group             : 
 * @last modified on  : 03-01-2025
 * @last modified by  : Krishanu Chinya
**/
@RestResource(urlMapping='/api/v1/external/scoreApplication')
global without sharing class ExternalScoreApplicationAPI {
    private static final String FLOW_APPLICATION_ID = 'ApplicationId';
    private static final String APPLICATION_TIER = 'ApplicationTierRating';
    private static final String CLASS_NAME = ExternalScoreApplicationAPI.class.getName();

    private static List<Account> updatedAccountList=new List<Account>();
    private static List<Id> accountIdList;
    private static List<clcommon__party__c> partyList;
    private static List<Id> contactIdList;
    private static List<String> ssnList;
                                                         
    /**
    * @description generates scores for all the individual
    * @author Soumik Pattanayak | 20-08-2024 
    **/
	@HttpPost
    global static void generateScore(){

        RestRequest requestParam = RestContext.request;
        String applicationId;
        String userId;
        Account dealerForExtUser;
        genesis__Applications__c objApplication = new genesis__Applications__c();
        Map<String, Object> applicationIdMap = new Map<String, Object>();
        Map<String, Object> bodyMap = new Map<String, Object>();
        RestResponse response = RestContext.response;
        response.addHeader(ExternalConstants.CONTENT_TYPE, ExternalConstants.APPLICATION_JSON);
        Savepoint dbSavePoint = Database.setSavepoint();
        Map<String, Object> responseMap = new Map<String, Object>();
        try{
            String requestBody = requestParam.requestBody.toString();
            ExternalApplicationOriginationUtil.checkForBlankParameter(requestBody);
            Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
            Map<String, Object> contentMap = new Map<String, Object>();
            
            ExternalAdditionalInfoValidationUtil.validateRequiredKey(requestMap, ExternalConstants.APPLICATION_DETAIL_KEY, ExternalConstants.APPLICATION_DETAILS_MISSING);
            ExternalAdditionalInfoValidationUtil.validateRequiredKey(requestMap, ExternalConstants.BORROWER_DETAIL_KEY, ExternalConstants.BORROWER_DETAILS_MISSING);
            
            Map<String, Object> applicationDetailsMap = (Map<String, Object>)requestMap.get(ExternalConstants.APPLICATION_DETAIL_KEY);
            Map<String,Object> userDetailsMap = (Map<String,Object>) requestMap.get(ExternalConstants.BORROWER_DETAIL_KEY);
            
            ExternalAdditionalInfoValidationUtil.validateRequiredKey(applicationDetailsMap, ExternalConstants.ID_KEY, ExternalConstants.APPLICATION_ID_MISSING);
            applicationId = String.valueOf(applicationDetailsMap.get(ExternalConstants.ID_KEY));
            
            ExternalAdditionalInfoValidationUtil.validateRequiredKey(userDetailsMap, ExternalConstants.USER_ID_KEY, ExternalConstants.USER_ID_MISSING);
            userId = String.valueOf(userDetailsMap.get(ExternalConstants.USER_ID_KEY));

            Map<String,Object> dealerDetailsMap = (Map<String,Object>) requestParam.headers;
            ExternalApplicationOriginationUtil.checkForNullObject(dealerDetailsMap, ExternalConstants.DEALER_DETAILS_MISSING);  
            
            dealerForExtUser = ExternalApplicationValidationUtil.validateDealerDetails(dealerDetailsMap);
            // dealerForExtUser = ExternalApplicationOriginationUtil.getExtUserInfo(dealerForExtUser);
            ExternalSecurityUtil.validateBorrowerWithApplication(applicationId,userId,dealerForExtUser.Id);

            List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                    signing_method__c,
                                                                    genesis__Credit_Rating__c,
                                                                    genesis__Status__c
                                                                    FROM genesis__Applications__c
                                                                    WHERE Id =:applicationId];
            
            ExternalApplicationOriginationUtil.checkEmptyList(applicationList, ExternalConstants.APPLICATION_NOT_FOUND);

            ExternalValidationUtil.validateAppForScoring(applicationList[0]);

            objApplication = applicationList[0];
            objApplication.genesis__Credit_Rating__c = null;
            // checkAccessOnObjects();
            Database.update(objApplication,true);
            
            applicationIdMap.put(FLOW_APPLICATION_ID,objApplication.Id);
            partyList = [SELECT Id,
                                                        clcommon__Account__c,
                                                        clcommon__Contact__c,
                                                        Document_Generated__c,
                                                        clcommon__Contact__r.genesis__SSN__c,
                                                        clcommon__Party_Types__c
                                                    FROM clcommon__party__c 
                                                    WHERE genesis__Application__c =: objApplication.Id
                                                    AND clcommon__Party_Types__c IN ( :ExternalConstants.BORROWER_PARTY, :ExternalConstants.PRINCIPAL_PARTY)
                                                    AND clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name =: ExternalConstants.SOLE_PROP_ENTITY];

            Map<Id, String> contactSSNMap = new Map<Id, String>();
            List<Contact> existingContactList = new List<Contact>();
            contactIdList = new List<Id>();
            ssnList = new List<String>();
            Map<String, Id> ssnToAccountIdMap = new Map<String, Id>();
            contactSSNandSSNAccountMapping(contactSSNMap, ssnToAccountIdMap);
            
            if(!ssnList.isEmpty() && !contactIdList.isEmpty()){
                existingContactList = [SELECT Id,
                                                AccountId,
                                                genesis__SSN__c
                                            FROM Contact
                                            WHERE genesis__SSN__c =: ssnList
                                            AND Id != :contactIdList
                                            AND Account.FICO_Recorded_On__c = LAST_N_DAYS:182];
            }
            accountIdList = new List<Id>();
            accountIdListing(existingContactList);
            
            Map<Id, Account> accounIdtoAccountMap = accounIdtoAccountMapping();

            updateAccountList(existingContactList, accounIdtoAccountMap, ssnToAccountIdMap);
            if(updatedAccountList.size()!=0){
                Database.update(updatedAccountList, true);
            }
                                                    
            Flow.Interview.FICOFlow callFlow = new Flow.Interview.FICOFlow(applicationIdMap);
            callFlow.start();  

            responseMap.put(ExternalConstants.STATUS_KEY, ExternalConstants.SUCCESS_VALUE);

            bodyMap.put(ExternalConstants.MESSAGE_KEY,ExternalConstants.SCORE_INITIATED_MESSAGE_KEY);
            
            contentMap.put(ExternalConstants.BODY_KEY,bodyMap);
            
            responseMap.put(ExternalConstants.CONTENT_KEY,contentMap);

            response.statusCode = 201;
            response.responseBody = blob.valueOf(JSON.serialize(responseMap));
        }catch(CustomException customExceptionObj) {
            Database.rollback(dbSavePoint);
            ExternalExceptionUtil.saveExceptionLog(customExceptionObj, CLASS_NAME);
            if(customExceptionObj.getMessage().equals(ExternalConstants.USER_NOT_AUTHORISED)){
                ExternalExceptionUtil.setUnauthorizeResponse(response);
            }
            else{
                ExternalExceptionUtil.setFailureResponse(response,customExceptionObj.getMessage());
            }
        }catch (Exception exceptionObj) {
            Database.rollback(dbSavePoint);
            ExternalExceptionUtil.saveExceptionLog(exceptionObj, CLASS_NAME);
            ExternalExceptionUtil.setFailureResponse(response,ExternalConstants.UNEXPECTED_ERROR);
        }
    }

    /**
    * @description Updates the score field in account who are already scored
    * @author Soumik Pattanayak | 20-08-2024 
    * @param existingContactList 
    * @param accounIdtoAccountMap
    * @param ssnToAccountIdMap  
    **/
    private static void updateAccountList(List<Contact> existingContactList, Map<Id, Account> accounIdtoAccountMap, Map<String, Id> ssnToAccountIdMap){
        for(Contact eachContact : existingContactList){
            Account currentAccount = new Account();
            Account existingAccount = new Account();
            currentAccount.Id = ssnToAccountIdMap.get(eachContact.genesis__SSN__c);
            existingAccount = accounIdtoAccountMap.get(eachContact.AccountId);
            currentAccount.FICO_Recorded_On__c = existingAccount.FICO_Recorded_On__c;
            currentAccount.message_text__c = existingAccount.message_text__c;
            currentAccount.Score_1__c = existingAccount.Score_1__c;
            currentAccount.Score_2__c = existingAccount.Score_2__c;
            currentAccount.SBSS70_Score__c = existingAccount.SBSS70_Score__c;
            currentAccount.BK10_Score__c = existingAccount.BK10_Score__c;
            currentAccount.AbnormalReportIndicator__c = existingAccount.AbnormalReportIndicator__c;
            currentAccount.addressMismatchIndicator__c = existingAccount.addressMismatchIndicator__c;
            currentAccount.aliasIndicator__c = existingAccount.aliasIndicator__c;
            currentAccount.bankruptcyOnFileIndicator__c = existingAccount.bankruptcyOnFileIndicator__c;
            currentAccount.consumerStatementIndicator__c = existingAccount.consumerStatementIndicator__c;
            currentAccount.contactSubscriberIndicator__c = existingAccount.contactSubscriberIndicator__c;
            currentAccount.creditCounselingIndicator__c = existingAccount.creditCounselingIndicator__c;
            currentAccount.disputedAccountIndicator__c = existingAccount.disputedAccountIndicator__c;
            currentAccount.fileVariationIndicator__c = existingAccount.fileVariationIndicator__c;
            currentAccount.irregularReportDeceasedIndicator__c = existingAccount.irregularReportDeceasedIndicator__c;
            currentAccount.irregularReportManualFileIndicator__c = existingAccount.irregularReportManualFileIndicator__c;
            currentAccount.lostOrStolenCardIndicator__c = existingAccount.lostOrStolenCardIndicator__c;
            currentAccount.nameMismatchIndicator__c = existingAccount.nameMismatchIndicator__c;
            currentAccount.securityFrozenFileIndicator__c = existingAccount.securityFrozenFileIndicator__c;
            currentAccount.securityOfacIndicator__c = existingAccount.securityOfacIndicator__c;
            currentAccount.securityReportIndicator__c = existingAccount.securityReportIndicator__c;
            currentAccount.ssnVariationIndicator__c = existingAccount.ssnVariationIndicator__c;
            currentAccount.thinFileIndicator__c = existingAccount.thinFileIndicator__c;
            currentAccount.avgMosInFileTLRptd0To2Mos__c = existingAccount.avgMosInFileTLRptd0To2Mos__c;
            currentAccount.highestUtilOnBankNatlRevTL__c = existingAccount.highestUtilOnBankNatlRevTL__c;
            currentAccount.maxDelqPR0To11Mos__c = existingAccount.maxDelqPR0To11Mos__c;
            currentAccount.mosSncOldestBankNatlRevOpenTLOpnd__c = existingAccount.mosSncOldestBankNatlRevOpenTLOpnd__c;
            currentAccount.numTL30pDaysEverDerogPR__c = existingAccount.numTL30pDaysEverDerogPR__c;
            currentAccount.numTL60pDaysEverDerogPR__c = existingAccount.numTL60pDaysEverDerogPR__c;
            currentAccount.numTL90pDaysEverDerogPR__c = existingAccount.numTL90pDaysEverDerogPR__c;
            currentAccount.numBankNatlRevTL90PctRptd0To2Mos__c = existingAccount.numBankNatlRevTL90PctRptd0To2Mos__c;
            currentAccount.numBankNatlRevTLWBal75PctAmt__c = existingAccount.numBankNatlRevTLWBal75PctAmt__c;
            currentAccount.lowestRatingRevOpen__c = existingAccount.lowestRatingRevOpen__c;
            currentAccount.avgMosInFile__c = existingAccount.avgMosInFile__c;
            currentAccount.lowestRating__c = existingAccount.lowestRating__c;
            currentAccount.lowestRatingIL__c = existingAccount.lowestRatingIL__c;
            currentAccount.lowestRatingOpndLast12Mos__c = existingAccount.lowestRatingOpndLast12Mos__c;
            currentAccount.lowestRatingOpndLast24Mos__c = existingAccount.lowestRatingOpndLast24Mos__c;
            currentAccount.lowestRatingOpndLast36Mos__c = existingAccount.lowestRatingOpndLast36Mos__c;
            currentAccount.maxDelqEver__c = existingAccount.maxDelqEver__c;
            currentAccount.mosSncMostRcnt30pDelq__c = existingAccount.mosSncMostRcnt30pDelq__c;
            currentAccount.mosSncMostRcnt60pDelq__c = existingAccount.mosSncMostRcnt60pDelq__c;
            currentAccount.mosSncMostRcntDtOpnd__c = existingAccount.mosSncMostRcntDtOpnd__c;
            currentAccount.mosSncMostRcntFinTLOpnd__c = existingAccount.mosSncMostRcntFinTLOpnd__c;
            currentAccount.mosSncMostRcntInq__c = existingAccount.mosSncMostRcntInq__c;
            currentAccount.mosSncOldestDtOpnd__c = existingAccount.mosSncOldestDtOpnd__c;
            currentAccount.netFrctIL__c = existingAccount.netFrctIL__c;
            currentAccount.netFrctMtg__c = existingAccount.netFrctMtg__c;
            currentAccount.netFrctRev__c = existingAccount.netFrctRev__c;
            currentAccount.numCollection__c = existingAccount.numCollection__c;
            currentAccount.numDaysInq0to11MosExclLast30Days__c = existingAccount.numDaysInq0to11MosExclLast30Days__c;
            currentAccount.numFinTL__c = existingAccount.numFinTL__c;
            currentAccount.numInq0to11MosExclLast30Days__c = existingAccount.numInq0to11MosExclLast30Days__c;
            currentAccount.numInq0to5MosExclLast14Days__c = existingAccount.numInq0to5MosExclLast14Days__c;
            currentAccount.numInq0to5MosExclLast7Days__c = existingAccount.numInq0to5MosExclLast7Days__c;
            currentAccount.numPR__c = existingAccount.numPR__c;
            currentAccount.numRevOpenTLWBal__c = existingAccount.numRevOpenTLWBal__c;
            currentAccount.numRevTL30pDaysEver__c = existingAccount.numRevTL30pDaysEver__c;
            currentAccount.numRevTLWBal50PctAmt__c = existingAccount.numRevTLWBal50PctAmt__c;
            currentAccount.numTL__c = existingAccount.numTL__c;
            currentAccount.numTLOpnd3MosAndNotGT2x30Days__c = existingAccount.numTLOpnd3MosAndNotGT2x30Days__c;
            currentAccount.pctTLNeverDelq__c = existingAccount.pctTLNeverDelq__c;
            currentAccount.pctTLNowCurr__c = existingAccount.pctTLNowCurr__c;
            currentAccount.totBal__c = existingAccount.totBal__c;
            currentAccount.Model_Reason_1__c = existingAccount.Model_Reason_1__c;
            currentAccount.Model_Reason_2__c = existingAccount.Model_Reason_2__c;
            currentAccount.Model_Reason_3__c = existingAccount.Model_Reason_3__c;
            currentAccount.Model_Reason_4__c = existingAccount.Model_Reason_4__c;
            currentAccount.Model_Reason_Bk_1__c = existingAccount.Model_Reason_Bk_1__c;
            currentAccount.Model_Reason_Bk_2__c = existingAccount.Model_Reason_Bk_2__c;
            currentAccount.Model_Reason_Bk_3__c = existingAccount.Model_Reason_Bk_3__c;
            currentAccount.Model_Reason_Bk_4__c = existingAccount.Model_Reason_Bk_4__c;
            currentAccount.Reason_Code_1__c = existingAccount.Reason_Code_1__c;
            currentAccount.Reason_Code_2__c = existingAccount.Reason_Code_2__c;
            currentAccount.Reason_Code_3__c = existingAccount.Reason_Code_3__c;
            currentAccount.Reason_Code_4__c = existingAccount.Reason_Code_4__c;
            currentAccount.Message__c = existingAccount.Message__c;
            currentAccount.FICO_Document_Generated__c = true;

            updatedAccountList.add(currentAccount);
        }
    }

    /**
    * @description Gets all the field that required to update
    * @author Soumik Pattanayak | 20-08-2024 
    * @return Map<Id, Account> 
    **/
    private static Map<Id, Account> accounIdtoAccountMapping(){
        return new Map<Id, Account>(
            [SELECT Id,
                    FICO_Recorded_On__c,
                    message_text__c,
                    Score_1__c,
                    Score_2__c,
                    SBSS70_Score__c,
                    BK10_Score__c,
                    AbnormalReportIndicator__c,
                    addressMismatchIndicator__c,
                    aliasIndicator__c,
                    bankruptcyOnFileIndicator__c,
                    consumerStatementIndicator__c,
                    contactSubscriberIndicator__c,
                    creditCounselingIndicator__c,
                    disputedAccountIndicator__c,
                    fileVariationIndicator__c,
                    irregularReportDeceasedIndicator__c,
                    irregularReportManualFileIndicator__c,
                    lostOrStolenCardIndicator__c,
                    nameMismatchIndicator__c,
                    securityFrozenFileIndicator__c,
                    securityOfacIndicator__c,
                    securityReportIndicator__c,
                    ssnVariationIndicator__c,
                    thinFileIndicator__c,
                    avgMosInFileTLRptd0To2Mos__c,
                    highestUtilOnBankNatlRevTL__c,
                    maxDelqPR0To11Mos__c,
                    mosSncOldestBankNatlRevOpenTLOpnd__c,
                    numTL30pDaysEverDerogPR__c,
                    numTL60pDaysEverDerogPR__c,
                    numTL90pDaysEverDerogPR__c,
                    numBankNatlRevTL90PctRptd0To2Mos__c,
                    numBankNatlRevTLWBal75PctAmt__c,
                    lowestRatingRevOpen__c,
                    avgMosInFile__c,
                    lowestRating__c,
                    lowestRatingIL__c,
                    lowestRatingOpndLast12Mos__c,
                    lowestRatingOpndLast24Mos__c,
                    lowestRatingOpndLast36Mos__c,
                    maxDelqEver__c,
                    mosSncMostRcnt30pDelq__c,
                    mosSncMostRcnt60pDelq__c,
                    mosSncMostRcntDtOpnd__c,
                    mosSncMostRcntFinTLOpnd__c,
                    mosSncMostRcntInq__c,
                    mosSncOldestDtOpnd__c,
                    netFrctIL__c,
                    netFrctMtg__c,
                    netFrctRev__c,
                    numCollection__c,
                    numDaysInq0to11MosExclLast30Days__c,
                    numFinTL__c,
                    numInq0to11MosExclLast30Days__c,
                    numInq0to5MosExclLast14Days__c,
                    numInq0to5MosExclLast7Days__c,
                    numPR__c,
                    numRevOpenTLWBal__c,
                    numRevTL30pDaysEver__c,
                    numRevTLWBal50PctAmt__c,
                    numTL__c,
                    numTLOpnd3MosAndNotGT2x30Days__c,
                    pctTLNeverDelq__c,
                    pctTLNowCurr__c,
                    totBal__c,
                    Model_Reason_1__c,
                    Model_Reason_2__c,
                    Model_Reason_3__c,
                    Model_Reason_4__c,
                    Model_Reason_Bk_1__c,
                    Model_Reason_Bk_2__c,
                    Model_Reason_Bk_3__c,
                    Model_Reason_Bk_4__c,
                    Reason_Code_1__c,
                    Reason_Code_2__c,
                    Reason_Code_3__c,
                    Reason_Code_4__c,
                    Message__c
                FROM Account WHERE Id IN :accountIdList]
        );
    }

    /**
    * @description maps SSN of every party who are scored to their account and contact
    * @author Soumik Pattanayak | 20-08-2024 
    * @param contactSSNMap 
    * @param ssnToAccountIdMap 
    **/
    private static void contactSSNandSSNAccountMapping(Map<Id, String> contactSSNMap,
                                                         Map<String, Id> ssnToAccountIdMap){
        for(clcommon__party__c eachParty : partyList){
            contactSSNMap.put(eachParty.clcommon__Contact__c, eachParty.clcommon__Contact__r.genesis__SSN__c);
            contactIdList.add(eachParty.clcommon__Contact__c);
            ssnList.add(eachParty.clcommon__Contact__r.genesis__SSN__c);
            ssnToAccountIdMap.put(eachParty.clcommon__Contact__r.genesis__SSN__c, eachParty.clcommon__Account__c);
        }
    }

    /**
    * @description Lists all the account Id from contact who are already scored
    * @author Soumik Pattanayak | 20-08-2024 
    * @param existingContactList 
    **/
    private static void accountIdListing(List<Contact> existingContactList){
        for(Contact eachContact : existingContactList){
            accountIdList.add(eachContact.AccountId);
        }
    }
    
}