/**
 * @description       : Portal API to call the fico flow after getting all the application details
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 23-07-2024
 * @last modified by  : Subham Nandi
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   27-01-2022   Subham Nandi   Initial Version
**/
global without sharing class PortalScoreApplicationAPI implements clcommon.PortalCustomRemoteAPI1 {
    // Constant parameters specific for this class starts
    private static final String KEY_APPLICATION = 'application';
    private static final String APPLICATION_ID = 'ApplicationId';
    private static final String APPLICATION_TIER = 'ApplicationTierRating';
    private static final String CREDIT_RATING = 'CreditRating';
    private static final String TIER_1_STRING = 'Tier 1';
    private static final String TIER_2_STRING = 'Tier 2';
    private static final String TIER_3_STRING = 'Tier 3';
    private static final String TIER_1_PHONE = '1111111111';
    private static final String TIER_2_PHONE = '2222222222';
    private static final String TIER_3_PHONE = '3333333333';
    private static final String LOCKED_CREDIT_SCORE = '920';
    // Constant parameters specific for this class ends
    // Declarations specific to this class starts
    String applicationRecord = '';
    List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
    Map<String, Object> fieldsMap = new Map<String, Object>();
    Map<String, Object> applicationIdMap = new Map<String, Object>();
    genesis__Applications__c objApplication = new genesis__Applications__c();
    string tierName;
    // Declarations specific to this class ends


    /**
    * @description 
    * @param componentStrName 
    * @param disclosureNames 
    * @param argumentsFromPortal 
    * @return clcommon.Response 
    **/
    global clcommon.Response invokeAction(String componentStrName,
                                        String[] disclosureNames,
                                        Map<String, Object> argumentsFromPortal) {
        SavePoint dbSavePoint = Database.setSavepoint();
        clcommon.Response response = new clcommon.Response();
        Flow.Interview.FICOFlow callFlow;
        try {
            if(argumentsFromPortal.get(KEY_APPLICATION) == null){
                throw new CustomException(PortalConstants.SOMETHING_WENT_WRONG);
            }
            applicationRecord = String.valueOf(argumentsFromPortal.get(KEY_APPLICATION));
            if(applicationRecord != null){
                objApplication = (genesis__Applications__c) Json.deserialize(applicationRecord, genesis__Applications__c.class);
            }
            //logged in user check
            Boolean isValidUser = PortalSecurityUtil.validateUserApplication(objApplication.Id); 
            if (!isValidUser) {
                throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
            }
            objApplication.genesis__Credit_Rating__c = null;
            Database.update(objApplication,true);
            ////TESTING for Tier 1, Tier 2, Tier 3
            //query the borrower's Mobile Number
            List<clcommon__Party__c> objBorrowerParty = [ SELECT  Id,
                                                                    clcommon__Account__r.Phone, 
                                                                    clcommon__Account__r.genesis__Business_Information__r.genesis__Tax_identification_Number__c,
                                                                    clcommon__Contact__r.genesis__SSN__c,
                                                                    clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                                    clcommon__Account__c,
                                                                    genesis__Application__r.Is_Evergreen__c,
                                                                    genesis__Application__r.Net_Worth__c
                                                    FROM clcommon__Party__c
                                                    WHERE genesis__Application__c = :objApplication.Id AND 
                                                    clcommon__Party_Types__c = :ConstantValues.BORROWER_PARTY];
            if(objBorrowerParty.size() > 0 &&  objBorrowerParty[0].clcommon__Account__c != null){                                        
                // if(objBorrowerParty[0].clcommon__Account__r.Phone != null && 
                // objBorrowerParty[0].clcommon__Account__r.Phone == TIER_1_PHONE){
                //   //Update the Application With Tier 1 Credit
                //     genesis__Credit_Rating_Matrix__c objCreditRatingTiersLists = [SELECT Id, 
                //                                                                         Name 
                //                                                                 FROM genesis__Credit_Rating_Matrix__c 
                //                                                                 WHERE Name = :TIER_1_STRING];
                //     objApplication.genesis__Credit_Rating__c = objCreditRatingTiersLists.Id;
                //     objApplication.Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_1);
                //     objApplication.genesis__Status__c = ConstantValues.SCORECARD_GENERATED;
                    
                // }
                // else if(objBorrowerParty[0].clcommon__Account__r.Phone != null && 
                //         objBorrowerParty[0].clcommon__Account__r.Phone == TIER_2_PHONE){
                //         //Update the Application With Tier 2 Credit
                //         genesis__Credit_Rating_Matrix__c objCreditRatingTiersLists = [SELECT Id, 
                //                                                                                 Name 
                //                                                                         FROM genesis__Credit_Rating_Matrix__c 
                //                                                                         WHERE Name = :TIER_2_STRING];
                //         objApplication.genesis__Credit_Rating__c = objCreditRatingTiersLists.Id;
                //         objApplication.Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_2);
                //         objApplication.genesis__Status__c = ConstantValues.SCORECARD_GENERATED;
                        
                // }
                // else if(objBorrowerParty[0].clcommon__Account__r.Phone != null && 
                //         objBorrowerParty[0].clcommon__Account__r.Phone == TIER_3_PHONE){
                //         //Update the Application With Tier 3 Credit
                //         genesis__Credit_Rating_Matrix__c objCreditRatingTiersLists = [SELECT Id, 
                //                                                                             Name 
                //                                                                         FROM genesis__Credit_Rating_Matrix__c 
                //                                                                         WHERE Name = :TIER_3_STRING];
                //         objApplication.genesis__Credit_Rating__c = objCreditRatingTiersLists.Id;
                //         objApplication.Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_3);
                //         objApplication.genesis__Status__c = ConstantValues.SCORECARD_GENERATED;
                //         Database.update(objApplication,true);
                // }
                // else{
                    //original code
                    
                    // //Call the flow with objApplication.Id
                    // if(objApplication.Id != null){
                    //     applicationIdMap.put(APPLICATION_ID,objApplication.Id);
                    // }
                    // if(applicationIdMap != null){
                    //     callFlow = new Flow.Interview.FICOFlow(applicationIdMap);
                    // }
                    // callFlow.start();
                    // tierName=(string)callFlow.getvariableValue(APPLICATION_TIER);
                    //need to return tierName as response to the portal

                    //-------------------------------------------------------------------------
                    //FIX TO UPDATE SCORE IF DUPLICATE ACCOUNT IS PRESENT IN OTHER COOP
                    if(objApplication.Id != null){
                        applicationIdMap.put(APPLICATION_ID,objApplication.Id);
                        List<clcommon__party__c> partyList = [SELECT Id,
                                                                    clcommon__Account__c,
                                                                    clcommon__Contact__c,
                                                                    Document_Generated__c,
                                                                    clcommon__Contact__r.genesis__SSN__c,
                                                                    clcommon__Party_Types__c
                                                                FROM clcommon__party__c 
                                                                WHERE genesis__Application__c =: objApplication.Id
                                                                AND clcommon__Party_Types__c IN ( :PortalConstants.BORROWER_PARTY_NAME, :PortalConstants.PRINCIPAL_PARTY_NAME)
																AND clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name =: PortalConstants.SOLE_PROP_ENTITY];

                        Map<Id, String> contactSSNMap = new Map<Id, String>();
                        List<Contact> existingContactList = new List<Contact>();
                        List<Id> contactIdList = new List<Id>();
                        List<String> ssnList = new List<String>();
                        Map<String, Id> ssnToAccountIdMap = new Map<String, Id>();
                        for(clcommon__party__c eachParty : partyList){
                            contactSSNMap.put(eachParty.clcommon__Contact__c, eachParty.clcommon__Contact__r.genesis__SSN__c);
                            contactIdList.add(eachParty.clcommon__Contact__c);
                            ssnList.add(eachParty.clcommon__Contact__r.genesis__SSN__c);
                            ssnToAccountIdMap.put(eachParty.clcommon__Contact__r.genesis__SSN__c, eachParty.clcommon__Account__c);
                        }
                        
                        if(!ssnList.isEmpty() && !contactIdList.isEmpty()){
                            existingContactList = [SELECT Id,

                                                            AccountId,
                                                            genesis__SSN__c
                                                        FROM Contact 
                                                        WHERE genesis__SSN__c =: ssnList
                                                        AND Id != :contactIdList
                                                        AND Account.FICO_Recorded_On__c = LAST_N_DAYS:182];
                        }
                        List<Id> accountIdList = new List<Id>();
                        for(Contact eachContact : existingContactList){
                            accountIdList.add(eachContact.AccountId);
                        }
                        Map<Id, Account> accounIdtoAccountMap = new Map<Id, Account>(
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

                        List<Account> updatedAccountList = new List<Account>();
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
                        Database.update(updatedAccountList, true);
                                                                
                        callFlow = new Flow.Interview.FICOFlow(applicationIdMap);
                        callFlow.start();
                        tierName=(string)callFlow.getvariableValue(APPLICATION_TIER);  
                    }

                // }
            }
            
            fieldsMap.put(CREDIT_RATING, tierName);
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(fieldsMap));
            clcommon.Response responseFormat = clcommon.PortalActions.getCustomRemoteActionResponse(responseData);
            response.content = null;
            response.response = responseFormat.response;
            response.status = clcommon.Constants.SUCCESS;
            return response;
        } 
        catch (CustomException ex) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = ex.getMessage();
        }
        catch (Exception ex) {
            Database.rollback(dbSavePoint);
            response.status = clcommon.Constants.API_EXCEPTION;
            response.errorMessage = PortalConstants.SOMETHING_WENT_WRONG;
        }
        return null;
    }
}