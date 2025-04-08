/**
 * @description       : Recieves the response, generates a file, parses and store the response
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 09-23-2024
 * @created on        : 06-05-2023
 * @last modified by  : Ayush Kumar Singh
**/

public without sharing class FICOCreditBureauParser {
    /**
    * @description Parse Reason Code
    * @author  Pritam Roy | 02-22-2024 
    * @param parseCode 
    * @return List<String> 
    **/
    private static List<String> parseReasonCode(Dom.XmlNode parseCode){ 
        List<String> responseList = new List<String>();
        List<Dom.XmlNode> reasonList = parseCode.getChildElements();
        if(reasonList.size()>0&&reasonList[0].getText()!=null){
            responseList.add(reasonList[0].getText());
        }
        if(reasonList.size()>1&&reasonList[1].getText()!=null){
            responseList.add(reasonList[1].getText());
        }
        if(reasonList.size()>2&&reasonList[2].getText()!=null){
            responseList.add(reasonList[2].getText());
        }
        if(reasonList.size()>3&&reasonList[3].getText()!=null){
            responseList.add(reasonList[3].getText());
        }
        return responseList;
    }
    /**
    * @description Parse and add Indicators to Map
    * @author  Pritam Roy | 02-22-2024 
    * @param indicators 
    * @return Map<String, String> 
    **/
    private static Map<String,String> parseIndicators(Dom.XmlNode indicators){
        Map<String,String> responseMap = new Map<String,String>();
        if(indicators!=null){
            Dom.XmlNode abnormalReportIndicator = indicators.getChildElement('abnormalReportIndicator', null);
            if(abnormalReportIndicator!=null){
                responseMap.put('abnormalReportIndicator',abnormalReportIndicator.getText());
            }else{
                responseMap.put('abnormalReportIndicator','');
            }
            Dom.XmlNode addressMismatchIndicator = indicators.getChildElement('addressMismatchIndicator', null);
            if(addressMismatchIndicator!=null){
                responseMap.put('addressMismatchIndicator',indicators.getChildElement('addressMismatchIndicator', null).getText());
            }else{
                responseMap.put('addressMismatchIndicator','');
            }
            Dom.XmlNode aliasIndicator = indicators.getChildElement('aliasIndicator', null);
            if(aliasIndicator!=null){
                responseMap.put('aliasIndicator',indicators.getChildElement('aliasIndicator', null).getText());
            }else{
                responseMap.put('aliasIndicator','');
            }
            Dom.XmlNode bankruptcyOnFileIndicator = indicators.getChildElement('bankruptcyOnFileIndicator', null);
            if(bankruptcyOnFileIndicator!=null){
                responseMap.put('bankruptcyOnFileIndicator',indicators.getChildElement('bankruptcyOnFileIndicator', null).getText());
            }else{
                responseMap.put('bankruptcyOnFileIndicator','');
            }
            Dom.XmlNode consumerStatementIndicator = indicators.getChildElement('consumerStatementIndicator', null);
            if(consumerStatementIndicator!=null){
                responseMap.put('consumerStatementIndicator',indicators.getChildElement('consumerStatementIndicator', null).getText());
            }else{
                responseMap.put('consumerStatementIndicator','');
            }
            Dom.XmlNode contactSubscriberIndicator = indicators.getChildElement('contactSubscriberIndicator', null);
            if(contactSubscriberIndicator!=null){
                responseMap.put('contactSubscriberIndicator',indicators.getChildElement('contactSubscriberIndicator', null).getText());
            }else{
                responseMap.put('contactSubscriberIndicator','');
            }
            Dom.XmlNode creditCounselingIndicator = indicators.getChildElement('creditCounselingIndicator', null);
            if(creditCounselingIndicator!=null){
                responseMap.put('creditCounselingIndicator',indicators.getChildElement('creditCounselingIndicator', null).getText());
            }else{
                responseMap.put('creditCounselingIndicator','');
            }
            Dom.XmlNode disputedAccountIndicator = indicators.getChildElement('disputedAccountIndicator', null);
            if(disputedAccountIndicator!=null){
                responseMap.put('disputedAccountIndicator',indicators.getChildElement('disputedAccountIndicator', null).getText());
            }else{
                responseMap.put('disputedAccountIndicator','');
            }
            Dom.XmlNode fileVariationIndicator = indicators.getChildElement('fileVariationIndicator', null);
            if(fileVariationIndicator!=null){
                responseMap.put('fileVariationIndicator',indicators.getChildElement('fileVariationIndicator', null).getText());
            }else{
                responseMap.put('fileVariationIndicator','');
            }
            Dom.XmlNode irregularReportDeceasedIndicator = indicators.getChildElement('irregularReportDeceasedIndicator', null);
            if(irregularReportDeceasedIndicator!=null){
                responseMap.put('irregularReportDeceasedIndicator',indicators.getChildElement('irregularReportDeceasedIndicator', null).getText());
            }else{
                responseMap.put('irregularReportDeceasedIndicator','');
            }
            Dom.XmlNode irregularReportManualFileIndicator = indicators.getChildElement('irregularReportManualFileIndicator', null);
            if(irregularReportManualFileIndicator!=null){
                responseMap.put('irregularReportManualFileIndicator',indicators.getChildElement('irregularReportManualFileIndicator', null).getText());
            }else{
                responseMap.put('irregularReportManualFileIndicator','');
            }
            Dom.XmlNode lostOrStolenCardIndicator = indicators.getChildElement('lostOrStolenCardIndicator', null);
            if(lostOrStolenCardIndicator!=null){
                responseMap.put('lostOrStolenCardIndicator',indicators.getChildElement('lostOrStolenCardIndicator', null).getText());
            }else{
                responseMap.put('lostOrStolenCardIndicator','');
            }
            Dom.XmlNode nameMismatchIndicator = indicators.getChildElement('nameMismatchIndicator', null);
            if(nameMismatchIndicator!=null){
                responseMap.put('nameMismatchIndicator',indicators.getChildElement('nameMismatchIndicator', null).getText());
            }else{
                responseMap.put('nameMismatchIndicator','');
            }
            Dom.XmlNode securityFrozenFileIndicator = indicators.getChildElement('securityFrozenFileIndicator', null);
            if(securityFrozenFileIndicator!=null){
                responseMap.put('securityFrozenFileIndicator',indicators.getChildElement('securityFrozenFileIndicator', null).getText());
            }else{
                responseMap.put('securityFrozenFileIndicator','');
            }
            Dom.XmlNode securityOfacIndicator = indicators.getChildElement('securityOfacIndicator', null);
            if(securityOfacIndicator!=null){
                responseMap.put('securityOfacIndicator',indicators.getChildElement('securityOfacIndicator', null).getText());
            }else{
                responseMap.put('securityOfacIndicator','');
            }
            Dom.XmlNode securityReportIndicator = indicators.getChildElement('securityReportIndicator', null);
            if(securityReportIndicator!=null){
                responseMap.put('securityReportIndicator',indicators.getChildElement('securityReportIndicator', null).getText());
            }else{
                responseMap.put('securityReportIndicator','');
            }
            Dom.XmlNode ssnVariationIndicator = indicators.getChildElement('ssnVariationIndicator', null);
            if(ssnVariationIndicator!=null){
                responseMap.put('ssnVariationIndicator',indicators.getChildElement('ssnVariationIndicator', null).getText());
            }else{
                responseMap.put('ssnVariationIndicator','');
            }
            Dom.XmlNode thinFileIndicator = indicators.getChildElement('thinFileIndicator', null);
            if(thinFileIndicator!=null){
                responseMap.put('thinFileIndicator',indicators.getChildElement('thinFileIndicator', null).getText());
            }else{
                responseMap.put('thinFileIndicator','');
            }
        }
        return responseMap;
    }
    /**
    * @description Parse and add Characteristics to Map
    * @author  Pritam Roy | 02-22-2024 
    * @param characteristics 
    * @return Map<String, String> 
    **/
    private static Map<String,String> parseCharacteristics(Dom.XmlNode characteristics){
        Map<String,String> responseMap = new Map<String,String>();
        if(characteristics!=null){
            Dom.XmlNode avgMosInFile = characteristics.getChildElement('avgMosInFile', null);
            if(avgMosInFile!=null){
                responseMap.put('avgMosInFile',characteristics.getChildElement('avgMosInFile', null).getText());
            }else{
                responseMap.put('avgMosInFile','');
            }
            Dom.XmlNode avgMosInFileTLRptd0To2Mos = characteristics.getChildElement('avgMosInFileTLRptd0To2Mos', null);
            if(avgMosInFileTLRptd0To2Mos!=null){
                responseMap.put('avgMosInFileTLRptd0To2Mos',characteristics.getChildElement('avgMosInFileTLRptd0To2Mos', null).getText());
            }else{
                responseMap.put('avgMosInFileTLRptd0To2Mos','');
            }
            Dom.XmlNode highestUtilOnBankNatlRevTL = characteristics.getChildElement('highestUtilOnBankNatlRevTL', null);
            if(highestUtilOnBankNatlRevTL!=null){
                responseMap.put('highestUtilOnBankNatlRevTL',characteristics.getChildElement('highestUtilOnBankNatlRevTL', null).getText());
            }else{
                responseMap.put('avgMosInhighestUtilOnBankNatlRevTLFile','');
            }
            Dom.XmlNode mosSncOldestBankNatlRevOpenTLOpnd = characteristics.getChildElement('mosSncOldestBankNatlRevOpenTLOpnd', null);
            if(mosSncOldestBankNatlRevOpenTLOpnd!=null){
                responseMap.put('mosSncOldestBankNatlRevOpenTLOpnd',characteristics.getChildElement('mosSncOldestBankNatlRevOpenTLOpnd', null).getText());
            }else{
                responseMap.put('mosSncOldestBankNatlRevOpenTLOpnd','');
            }
            Dom.XmlNode numTL30pDaysEverDerogPR = characteristics.getChildElement('numTL30pDaysEverDerogPR', null);
            if(numTL30pDaysEverDerogPR!=null){
                responseMap.put('numTL30pDaysEverDerogPR',characteristics.getChildElement('numTL30pDaysEverDerogPR', null).getText());
            }else{
                responseMap.put('numTL30pDaysEverDerogPR','');
            }
            Dom.XmlNode numTL60pDaysEverDerogPR = characteristics.getChildElement('numTL60pDaysEverDerogPR', null);
            if(numTL60pDaysEverDerogPR!=null){
                responseMap.put('numTL60pDaysEverDerogPR',characteristics.getChildElement('numTL60pDaysEverDerogPR', null).getText());
            }else{
                responseMap.put('numTL60pDaysEverDerogPR','');
            }
            Dom.XmlNode numTL90pDaysEverDerogPR = characteristics.getChildElement('numTL90pDaysEverDerogPR', null);
            if(numTL90pDaysEverDerogPR!=null){
                responseMap.put('numTL90pDaysEverDerogPR',characteristics.getChildElement('numTL90pDaysEverDerogPR', null).getText());
            }else{
                responseMap.put('numTL90pDaysEverDerogPR','');
            }
            Dom.XmlNode numBankNatlRevTL90PctRptd0To2Mos = characteristics.getChildElement('numBankNatlRevTL90PctRptd0To2Mos', null);
            if(numBankNatlRevTL90PctRptd0To2Mos!=null){
                responseMap.put('numBankNatlRevTL90PctRptd0To2Mos',characteristics.getChildElement('numBankNatlRevTL90PctRptd0To2Mos', null).getText());
            }else{
                responseMap.put('numBankNatlRevTL90PctRptd0To2Mos','');
            }
            Dom.XmlNode numBankNatlRevTLWBal75PctAmt = characteristics.getChildElement('numBankNatlRevTLWBal75PctAmt', null);
            if(numBankNatlRevTLWBal75PctAmt!=null){
                responseMap.put('numBankNatlRevTLWBal75PctAmt',characteristics.getChildElement('numBankNatlRevTLWBal75PctAmt', null).getText());
            }else{
                responseMap.put('numBankNatlRevTLWBal75PctAmt','');
            }
            Dom.XmlNode lowestRatingRevOpen = characteristics.getChildElement('lowestRatingRevOpen', null);
            if(lowestRatingRevOpen!=null){
                responseMap.put('lowestRatingRevOpen',characteristics.getChildElement('lowestRatingRevOpen', null).getText());
            }else{
                responseMap.put('lowestRatingRevOpen','');
            }
            Dom.XmlNode lowestRating = characteristics.getChildElement('lowestRating', null);
            if(lowestRating!=null){
                responseMap.put('lowestRating',characteristics.getChildElement('lowestRating', null).getText());
            }else{
                responseMap.put('lowestRating','');
            }
            Dom.XmlNode lowestRatingIL = characteristics.getChildElement('lowestRatingIL', null);
            if(lowestRatingIL!=null){
                responseMap.put('lowestRatingIL',characteristics.getChildElement('lowestRatingIL', null).getText());
            }else{
                responseMap.put('lowestRatingIL','');
            }
            Dom.XmlNode lowestRatingOpndLast12Mos = characteristics.getChildElement('lowestRatingOpndLast12Mos', null);
            if(lowestRatingOpndLast12Mos!=null){
                responseMap.put('lowestRatingOpndLast12Mos',characteristics.getChildElement('lowestRatingOpndLast12Mos', null).getText());
            }else{
                responseMap.put('lowestRatingOpndLast12Mos','');
            }
            Dom.XmlNode lowestRatingOpndLast24Mos = characteristics.getChildElement('lowestRatingOpndLast24Mos', null);
            if(lowestRatingOpndLast24Mos!=null){
                responseMap.put('lowestRatingOpndLast24Mos',characteristics.getChildElement('lowestRatingOpndLast24Mos', null).getText());
            }else{
                responseMap.put('lowestRatingOpndLast24Mos','');
            }
            Dom.XmlNode lowestRatingOpndLast36Mos = characteristics.getChildElement('lowestRatingOpndLast36Mos', null);
            if(lowestRatingOpndLast36Mos!=null){
                responseMap.put('lowestRatingOpndLast36Mos',characteristics.getChildElement('lowestRatingOpndLast36Mos', null).getText());
            }else{
                responseMap.put('lowestRatingOpndLast36Mos','');
            }
            Dom.XmlNode maxDelqEver = characteristics.getChildElement('maxDelqEver', null);
            if(maxDelqEver!=null){
                responseMap.put('maxDelqEver',characteristics.getChildElement('maxDelqEver', null).getText());
            }else{
                responseMap.put('maxDelqEver','');
            }
            Dom.XmlNode maxDelqPR0To11Mos = characteristics.getChildElement('maxDelqPR0To11Mos', null);
            if(maxDelqPR0To11Mos!=null){
                responseMap.put('maxDelqPR0To11Mos',characteristics.getChildElement('maxDelqPR0To11Mos', null).getText());
            }else{
                responseMap.put('maxDelqPR0To11Mos','');
            }
            Dom.XmlNode mosSncMostRcnt30pDelq = characteristics.getChildElement('mosSncMostRcnt30pDelq', null);
            if(mosSncMostRcnt30pDelq!=null){
                responseMap.put('mosSncMostRcnt30pDelq',characteristics.getChildElement('mosSncMostRcnt30pDelq', null).getText());
            }else{
                responseMap.put('mosSncMostRcnt30pDelq','');
            }
            Dom.XmlNode mosSncMostRcnt60pDelq = characteristics.getChildElement('mosSncMostRcnt60pDelq', null);
            if(mosSncMostRcnt60pDelq!=null){
                responseMap.put('mosSncMostRcnt60pDelq',characteristics.getChildElement('mosSncMostRcnt60pDelq', null).getText());
            }else{
                responseMap.put('mosSncMostRcnt60pDelq','');
            }
            Dom.XmlNode mosSncMostRcntDtOpnd = characteristics.getChildElement('mosSncMostRcntDtOpnd', null);
            if(mosSncMostRcntDtOpnd!=null){
                responseMap.put('mosSncMostRcntDtOpnd',characteristics.getChildElement('mosSncMostRcntDtOpnd', null).getText());
            }else{
                responseMap.put('mosSncMostRcntDtOpnd','');
            }
            Dom.XmlNode mosSncMostRcntFinTLOpnd = characteristics.getChildElement('mosSncMostRcntFinTLOpnd', null);
            if(mosSncMostRcntFinTLOpnd!=null){
                responseMap.put('mosSncMostRcntFinTLOpnd',characteristics.getChildElement('mosSncMostRcntFinTLOpnd', null).getText());
            }else{
                responseMap.put('mosSncMostRcntFinTLOpnd','');
            }
            Dom.XmlNode mosSncMostRcntInq = characteristics.getChildElement('mosSncMostRcntInq', null);
            if(mosSncMostRcntInq!=null){
                responseMap.put('mosSncMostRcntInq',characteristics.getChildElement('mosSncMostRcntInq', null).getText());
            }else{
                responseMap.put('mosSncMostRcntInq','');
            }
            Dom.XmlNode mosSncOldestDtOpnd = characteristics.getChildElement('mosSncOldestDtOpnd', null);
            if(mosSncOldestDtOpnd!=null){
                responseMap.put('mosSncOldestDtOpnd',characteristics.getChildElement('mosSncOldestDtOpnd', null).getText());
            }else{
                responseMap.put('mosSncOldestDtOpnd','');
            }
            Dom.XmlNode netFrctIL = characteristics.getChildElement('netFrctIL', null);
            if(netFrctIL!=null){
                responseMap.put('netFrctIL',characteristics.getChildElement('netFrctIL', null).getText());
            }else{
                responseMap.put('netFrctIL','');
            }
            Dom.XmlNode netFrctMtg = characteristics.getChildElement('netFrctMtg', null);
            if(netFrctMtg!=null){
                responseMap.put('netFrctMtg',characteristics.getChildElement('netFrctMtg', null).getText());
            }else{
                responseMap.put('netFrctMtg','');
            }
            Dom.XmlNode netFrctRev = characteristics.getChildElement('netFrctRev', null);
            if(netFrctRev!=null){
                responseMap.put('netFrctRev',characteristics.getChildElement('netFrctRev', null).getText());
            }else{
                responseMap.put('netFrctRev','');
            }
            Dom.XmlNode numCollection = characteristics.getChildElement('numCollection', null);
            if(numCollection!=null){
                responseMap.put('numCollection',characteristics.getChildElement('numCollection', null).getText());
            }else{
                responseMap.put('numCollection','');
            }
            Dom.XmlNode numDaysInq0to11MosExclLast30Days = characteristics.getChildElement('numDaysInq0to11MosExclLast30Days', null);
            if(numDaysInq0to11MosExclLast30Days!=null){
                responseMap.put('numDaysInq0to11MosExclLast30Days',characteristics.getChildElement('numDaysInq0to11MosExclLast30Days', null).getText());
            }else{
                responseMap.put('numDaysInq0to11MosExclLast30Days','');
            }
            Dom.XmlNode numFinTL = characteristics.getChildElement('numFinTL', null);
            if(numFinTL!=null){
                responseMap.put('numFinTL',characteristics.getChildElement('numFinTL', null).getText());
            }else{
                responseMap.put('numFinTL','');
            }
            Dom.XmlNode numInq0to11MosExclLast30Days = characteristics.getChildElement('numInq0to11MosExclLast30Days', null);
            if(numInq0to11MosExclLast30Days!=null){
                responseMap.put('numInq0to11MosExclLast30Days',characteristics.getChildElement('numInq0to11MosExclLast30Days', null).getText());
            }else{
                responseMap.put('numInq0to11MosExclLast30Days','');
            }
            Dom.XmlNode numInq0to5MosExclLast14Days = characteristics.getChildElement('numInq0to5MosExclLast14Days', null);
            if(numInq0to5MosExclLast14Days!=null){
                responseMap.put('numInq0to5MosExclLast14Days',characteristics.getChildElement('numInq0to5MosExclLast14Days', null).getText());
            }else{
                responseMap.put('numInq0to5MosExclLast14Days','');
            }
            Dom.XmlNode numInq0to5MosExclLast7Days = characteristics.getChildElement('numInq0to5MosExclLast7Days', null);
            if(numInq0to5MosExclLast7Days!=null){
                responseMap.put('numInq0to5MosExclLast7Days',characteristics.getChildElement('numInq0to5MosExclLast7Days', null).getText());
            }else{
                responseMap.put('numInq0to5MosExclLast7Days','');
            }
            Dom.XmlNode numPR = characteristics.getChildElement('numPR', null);
            if(numPR!=null){
                responseMap.put('numPR',characteristics.getChildElement('numPR', null).getText());
            }else{
                responseMap.put('numPR','');
            }
            Dom.XmlNode numRevOpenTLWBal = characteristics.getChildElement('numRevOpenTLWBal', null);
            if(numRevOpenTLWBal!=null){
                responseMap.put('numRevOpenTLWBal',characteristics.getChildElement('numRevOpenTLWBal', null).getText());
            }else{
                responseMap.put('numRevOpenTLWBal','');
            }
            Dom.XmlNode numRevTL30pDaysEver = characteristics.getChildElement('numRevTL30pDaysEver', null);
            if(numRevTL30pDaysEver!=null){
                responseMap.put('numRevTL30pDaysEver',characteristics.getChildElement('numRevTL30pDaysEver', null).getText());
            }else{
                responseMap.put('numRevTL30pDaysEver','');
            }
            Dom.XmlNode numRevTLWBal50PctAmt = characteristics.getChildElement('numRevTLWBal50PctAmt', null);
            if(numRevTLWBal50PctAmt!=null){
                responseMap.put('numRevTLWBal50PctAmt',characteristics.getChildElement('numRevTLWBal50PctAmt', null).getText());
            }else{
                responseMap.put('numRevTLWBal50PctAmt','');
            }
            Dom.XmlNode numTL = characteristics.getChildElement('numTL', null);
            if(numTL!=null){
                responseMap.put('numTL',characteristics.getChildElement('numTL', null).getText());
            }else{
                responseMap.put('numTL','');
            }
            Dom.XmlNode numTLOpnd3MosAndNotGT2x30Days = characteristics.getChildElement('numTLOpnd3MosAndNotGT2x30Days', null);
            if(numTLOpnd3MosAndNotGT2x30Days!=null){
                responseMap.put('numTLOpnd3MosAndNotGT2x30Days',characteristics.getChildElement('numTLOpnd3MosAndNotGT2x30Days', null).getText());
            }else{
                responseMap.put('numTLOpnd3MosAndNotGT2x30Days','');
            }
            Dom.XmlNode pctTLNeverDelq = characteristics.getChildElement('pctTLNeverDelq', null);
            if(pctTLNeverDelq!=null){
                responseMap.put('pctTLNeverDelq',characteristics.getChildElement('pctTLNeverDelq', null).getText());
            }else{
                responseMap.put('pctTLNeverDelq','');
            }
            Dom.XmlNode pctTLNowCurr = characteristics.getChildElement('pctTLNowCurr', null);
            if(pctTLNowCurr!=null){
                responseMap.put('pctTLNowCurr',characteristics.getChildElement('pctTLNowCurr', null).getText());
            }else{
                responseMap.put('pctTLNowCurr','');
            }
            Dom.XmlNode totBal = characteristics.getChildElement('totBal', null);
            if(totBal!=null){
                responseMap.put('totBal',characteristics.getChildElement('totBal', null).getText());
            }else{
                responseMap.put('totBal','');
            }
        }
        return responseMap;
    }
    /**
    * @description Add Indicatiors to Account
    * @author  Pritam Roy | 02-22-2024 
    * @param objAccount 
    * @param responseMap 
    * @param creditReportMap 
    * @return Account 
    **/
    private static Account addIndicatorsToAccount(Account objAccount,Map<String,String> responseMap,Map<String,String> creditReportMap){
        if(responseMap.get('abnormalReportIndicator')!=null&&responseMap.get('abnormalReportIndicator')!=''&&creditReportMap.get('Abnormal Report Indicator'+responseMap.get('abnormalReportIndicator'))!=null){
            objAccount.AbnormalReportIndicator__c = creditReportMap.get('Abnormal Report Indicator'+responseMap.get('abnormalReportIndicator'));
        }
        if(responseMap.get('addressMismatchIndicator')!=null&&responseMap.get('addressMismatchIndicator')!=''&&creditReportMap.get('Address Mismatch'+responseMap.get('addressMismatchIndicator'))!=null){
            objAccount.addressMismatchIndicator__c = creditReportMap.get('Address Mismatch'+responseMap.get('addressMismatchIndicator'));
        }
        if(responseMap.get('aliasIndicator')!=null&&responseMap.get('aliasIndicator')!=''){
            objAccount.aliasIndicator__c = responseMap.get('aliasIndicator').equalsIgnoreCase('Y')?'Yes':'No';
        }
        if(responseMap.get('bankruptcyOnFileIndicator')!=null&&responseMap.get('bankruptcyOnFileIndicator')!=''){
            objAccount.bankruptcyOnFileIndicator__c = responseMap.get('bankruptcyOnFileIndicator').equalsIgnoreCase('Y')?'Yes':'No';
        }
        if(responseMap.get('consumerStatementIndicator')!=null&&responseMap.get('consumerStatementIndicator')!=''){
            objAccount.consumerStatementIndicator__c = responseMap.get('consumerStatementIndicator').equalsIgnoreCase('Y')?'Yes':'No';
        }
        if(responseMap.get('contactSubscriberIndicator')!=null&&responseMap.get('contactSubscriberIndicator')!=''){
            objAccount.contactSubscriberIndicator__c = responseMap.get('contactSubscriberIndicator').equalsIgnoreCase('Y')?'Yes':'No';
        }
        if(responseMap.get('creditCounselingIndicator')!=null&&responseMap.get('creditCounselingIndicator')!=''){
            objAccount.creditCounselingIndicator__c = responseMap.get('creditCounselingIndicator').equalsIgnoreCase('Y')?'Yes':'No';
        }
        if(responseMap.get('disputedAccountIndicator')!=null&&responseMap.get('disputedAccountIndicator')!=''){
            objAccount.disputedAccountIndicator__c = responseMap.get('disputedAccountIndicator').equalsIgnoreCase('Y')?'Yes':'No';
        }
        if(responseMap.get('fileVariationIndicator')!=null&&responseMap.get('fileVariationIndicator')!=''){
            objAccount.fileVariationIndicator__c = responseMap.get('fileVariationIndicator').equalsIgnoreCase('Y')?'Yes':'No';
        }
        if(responseMap.get('lostOrStolenCardIndicator')!=null&&responseMap.get('lostOrStolenCardIndicator')!=''){
            objAccount.irregularReportDeceasedIndicator__c = responseMap.get('lostOrStolenCardIndicator').equalsIgnoreCase('Y')?'Yes':'No';
        }
        if(responseMap.get('irregularReportManualFileIndicator')!=null&&responseMap.get('irregularReportManualFileIndicator')!=''&&creditReportMap.get('Irregular Report Manual File'+responseMap.get('irregularReportManualFileIndicator'))!=null){
            objAccount.irregularReportManualFileIndicator__c = creditReportMap.get('Irregular Report Manual File'+responseMap.get('irregularReportManualFileIndicator'));
        }
        if(responseMap.get('lostOrStolenCardIndicator')!=null&&responseMap.get('lostOrStolenCardIndicator')!=''){
            objAccount.lostOrStolenCardIndicator__c = responseMap.get('lostOrStolenCardIndicator').equalsIgnoreCase('Y')?'Yes':'No';
        }
        if(responseMap.get('nameMismatchIndicator')!=null&&responseMap.get('nameMismatchIndicator')!=''){
            objAccount.nameMismatchIndicator__c = responseMap.get('nameMismatchIndicator').equalsIgnoreCase('Y')?'Yes':'No';
        }
        if(responseMap.get('securityFrozenFileIndicator')!=null&&responseMap.get('securityFrozenFileIndicator')!=''){
            objAccount.securityFrozenFileIndicator__c = responseMap.get('securityFrozenFileIndicator').equalsIgnoreCase('Y')?'Yes':'No';
        }
        if(responseMap.get('securityOfacIndicator')!=null&&responseMap.get('securityOfacIndicator')!=''&&creditReportMap.get('OFAC Security'+responseMap.get('securityOfacIndicator'))!=null){
            objAccount.securityOfacIndicator__c = creditReportMap.get('OFAC Security'+responseMap.get('securityOfacIndicator'));
        }
        if(responseMap.get('securityReportIndicator')!=null&&responseMap.get('securityReportIndicator')!=''&&creditReportMap.get('Security Report'+responseMap.get('securityReportIndicator'))!=null){
            objAccount.securityReportIndicator__c = creditReportMap.get('Security Report'+responseMap.get('securityReportIndicator'));
        }
        if(responseMap.get('ssnVariationIndicator')!=null&&responseMap.get('ssnVariationIndicator')!=''&&creditReportMap.get('SSN/SIN Variation'+responseMap.get('ssnVariationIndicator'))!=null){
            objAccount.ssnVariationIndicator__c = creditReportMap.get('SSN/SIN Variation'+responseMap.get('ssnVariationIndicator'));
        }
        if(responseMap.get('thinFileIndicator')!=null&&responseMap.get('thinFileIndicator')!=''){
            objAccount.thinFileIndicator__c = responseMap.get('thinFileIndicator').equalsIgnoreCase('Y')?'Yes':'No';
        }
        return objAccount;
    }
    /**
    * @description Add Characteristics to Account
    * @author  Pritam Roy | 02-22-2024 
    * @param objAccount 
    * @param responseMap 
    * @param creditReportMap 
    * @return Account 
    **/
    private static Account addCharacteristicsToAccount(Account objAccount,Map<String,String> responseMap,Map<String,String> creditReportMap){
        if(responseMap.get('avgMosInFileTLRptd0To2Mos')!=null&&responseMap.get('avgMosInFileTLRptd0To2Mos')!=''&&Integer.valueOf(responseMap.get('avgMosInFileTLRptd0To2Mos'))>=0&&Integer.valueOf(responseMap.get('avgMosInFileTLRptd0To2Mos'))<=999){
            objAccount.avgMosInFileTLRptd0To2Mos__c = responseMap.get('avgMosInFileTLRptd0To2Mos');
        }else if(responseMap.get('avgMosInFileTLRptd0To2Mos')!=null&&responseMap.get('avgMosInFileTLRptd0To2Mos')!=''&&creditReportMap.get('Avg. Months in File Trade'+responseMap.get('avgMosInFileTLRptd0To2Mos'))!=null){ 
            objAccount.avgMosInFileTLRptd0To2Mos__c = creditReportMap.get('Avg. Months in File Trade'+responseMap.get('avgMosInFileTLRptd0To2Mos'));
        }
        if(responseMap.get('highestUtilOnBankNatlRevTL')!=null&&responseMap.get('highestUtilOnBankNatlRevTL')!=''&&Integer.valueOf(responseMap.get('highestUtilOnBankNatlRevTL'))>=0&&Integer.valueOf(responseMap.get('highestUtilOnBankNatlRevTL'))<=999){
            objAccount.highestUtilOnBankNatlRevTL__c = responseMap.get('highestUtilOnBankNatlRevTL');
        }else if(responseMap.get('highestUtilOnBankNatlRevTL')!=null&&responseMap.get('highestUtilOnBankNatlRevTL')!=''&&creditReportMap.get('Highest Utilization Bank'+responseMap.get('highestUtilOnBankNatlRevTL'))!=null){    
            objAccount.highestUtilOnBankNatlRevTL__c = creditReportMap.get('Highest Utilization Bank'+responseMap.get('highestUtilOnBankNatlRevTL'));
        }
        if(responseMap.get('maxDelqPR0To11Mos')!=null&&responseMap.get('maxDelqPR0To11Mos')!=''&&Integer.valueOf(responseMap.get('maxDelqPR0To11Mos'))>=9&&Integer.valueOf(responseMap.get('maxDelqPR0To11Mos'))<=999){
            objAccount.maxDelqPR0To11Mos__c = responseMap.get('maxDelqPR0To11Mos');
        }else if(responseMap.get('maxDelqPR0To11Mos')!=null&&responseMap.get('maxDelqPR0To11Mos')!=''&&creditReportMap.get('Maximum Delinquency Public Records'+responseMap.get('maxDelqPR0To11Mos'))!=null){    
            objAccount.maxDelqPR0To11Mos__c = creditReportMap.get('Maximum Delinquency Public Records'+responseMap.get('maxDelqPR0To11Mos'));
        }
        if(responseMap.get('mosSncOldestBankNatlRevOpenTLOpnd')!=null&&responseMap.get('mosSncOldestBankNatlRevOpenTLOpnd')!=''&&Integer.valueOf(responseMap.get('mosSncOldestBankNatlRevOpenTLOpnd'))>=0&&Integer.valueOf(responseMap.get('mosSncOldestBankNatlRevOpenTLOpnd'))<=1200){
            objAccount.mosSncOldestBankNatlRevOpenTLOpnd__c = responseMap.get('mosSncOldestBankNatlRevOpenTLOpnd');
        }else if(responseMap.get('mosSncOldestBankNatlRevOpenTLOpnd')!=null&&responseMap.get('mosSncOldestBankNatlRevOpenTLOpnd')!=''&&creditReportMap.get('Months Since OldBnk TL Open'+responseMap.get('mosSncOldestBankNatlRevOpenTLOpnd'))!=null){ 
            objAccount.mosSncOldestBankNatlRevOpenTLOpnd__c = creditReportMap.get('Months Since OldBnk TL Open'+responseMap.get('mosSncOldestBankNatlRevOpenTLOpnd'));
        }
        if(responseMap.get('numTL30pDaysEverDerogPR')!=null&&responseMap.get('numTL30pDaysEverDerogPR')!=''&&Integer.valueOf(responseMap.get('numTL30pDaysEverDerogPR'))>=0&&Integer.valueOf(responseMap.get('numTL30pDaysEverDerogPR'))<=999){
            objAccount.numTL30pDaysEverDerogPR__c = responseMap.get('numTL30pDaysEverDerogPR');
        }
        if(responseMap.get('numTL60pDaysEverDerogPR')!=null&&responseMap.get('numTL60pDaysEverDerogPR')!=''&&Integer.valueOf(responseMap.get('numTL60pDaysEverDerogPR'))>=0&&Integer.valueOf(responseMap.get('numTL60pDaysEverDerogPR'))<=999){
            objAccount.numTL60pDaysEverDerogPR__c = responseMap.get('numTL60pDaysEverDerogPR');
        }
        if(responseMap.get('numTL90pDaysEverDerogPR')!=null&&responseMap.get('numTL90pDaysEverDerogPR')!=''&&Integer.valueOf(responseMap.get('numTL90pDaysEverDerogPR'))>=0&&Integer.valueOf(responseMap.get('numTL90pDaysEverDerogPR'))<=999){
            objAccount.numTL90pDaysEverDerogPR__c = responseMap.get('numTL90pDaysEverDerogPR');
        }
        if(responseMap.get('numBankNatlRevTL90PctRptd0To2Mos')!=null&&responseMap.get('numBankNatlRevTL90PctRptd0To2Mos')!=''&&Integer.valueOf(responseMap.get('numBankNatlRevTL90PctRptd0To2Mos'))>=0&&Integer.valueOf(responseMap.get('numBankNatlRevTL90PctRptd0To2Mos'))<=999){
            objAccount.numBankNatlRevTL90PctRptd0To2Mos__c = responseMap.get('numBankNatlRevTL90PctRptd0To2Mos');
        }else if(responseMap.get('numBankNatlRevTL90PctRptd0To2Mos')!=null&&responseMap.get('numBankNatlRevTL90PctRptd0To2Mos')!=''&&creditReportMap.get('National Revolving TL Balance 90'+responseMap.get('numBankNatlRevTL90PctRptd0To2Mos'))!=null){  
            objAccount.numBankNatlRevTL90PctRptd0To2Mos__c = creditReportMap.get('National Revolving TL Balance 90'+responseMap.get('numBankNatlRevTL90PctRptd0To2Mos'));
        }
        if(responseMap.get('numBankNatlRevTLWBal75PctAmt')!=null&&responseMap.get('numBankNatlRevTLWBal75PctAmt')!=''&&Integer.valueOf(responseMap.get('numBankNatlRevTLWBal75PctAmt'))>=0&&Integer.valueOf(responseMap.get('numBankNatlRevTLWBal75PctAmt'))<=999){
            objAccount.numBankNatlRevTLWBal75PctAmt__c = responseMap.get('numBankNatlRevTLWBal75PctAmt');
        }else if(responseMap.get('numBankNatlRevTLWBal75PctAmt')!=null&&responseMap.get('numBankNatlRevTLWBal75PctAmt')!=''&&creditReportMap.get('National Revolving TL Bal>=75'+responseMap.get('numBankNatlRevTLWBal75PctAmt'))!=null){  
            objAccount.numBankNatlRevTLWBal75PctAmt__c = creditReportMap.get('National Revolving TL Bal>=75'+responseMap.get('numBankNatlRevTLWBal75PctAmt'));
        }
        if(responseMap.get('lowestRatingRevOpen')!=null&&responseMap.get('lowestRatingRevOpen')!=''){
            objAccount.lowestRatingRevOpen__c = responseMap.get('lowestRatingRevOpen');
        }
        if(responseMap.get('avgMosInFile')!=null&&responseMap.get('avgMosInFile')!=''&&Integer.valueOf(responseMap.get('avgMosInFile'))>=0&&Integer.valueOf(responseMap.get('avgMosInFile'))<=999){
            objAccount.avgMosInFile__c = responseMap.get('avgMosInFile');
        }else if(responseMap.get('avgMosInFile')!=null&&responseMap.get('avgMosInFile')!=''&&creditReportMap.get('Avg. Months in File'+responseMap.get('avgMosInFile'))!=null){
            objAccount.avgMosInFile__c = creditReportMap.get('Avg. Months in File'+responseMap.get('avgMosInFile'));
        }
        if(responseMap.get('lowestRating')!=null&&responseMap.get('lowestRating')!=''&&creditReportMap.get('Lowest Rating at Credit Bureau'+responseMap.get('lowestRating'))!=null){
            objAccount.lowestRating__c = creditReportMap.get('Lowest Rating at Credit Bureau'+responseMap.get('lowestRating'));
        }
        if(responseMap.get('lowestRatingIL')!=null&&responseMap.get('lowestRatingIL')!=''&&creditReportMap.get('Lowest Rating Installment TL'+responseMap.get('lowestRatingIL'))!=null){
            objAccount.lowestRatingIL__c = creditReportMap.get('Lowest Rating Installment TL'+responseMap.get('lowestRatingIL'));
        }
        if(responseMap.get('lowestRatingOpndLast12Mos')!=null&&responseMap.get('lowestRatingOpndLast12Mos')!=''&&creditReportMap.get('Lowest Rating Opened Last 12'+responseMap.get('lowestRatingOpndLast12Mos'))!=null){
            objAccount.lowestRatingOpndLast12Mos__c = creditReportMap.get('Lowest Rating Opened Last 12'+responseMap.get('lowestRatingOpndLast12Mos'));
        }
        if(responseMap.get('lowestRatingOpndLast24Mos')!=null&&responseMap.get('lowestRatingOpndLast24Mos')!=''&&creditReportMap.get('Lowest Rating Opened Last 24'+responseMap.get('lowestRatingOpndLast24Mos'))!=null){
            objAccount.lowestRatingOpndLast24Mos__c = creditReportMap.get('Lowest Rating Opened Last 24'+responseMap.get('lowestRatingOpndLast24Mos'));
        }
        if(responseMap.get('lowestRatingOpndLast36Mos')!=null&&responseMap.get('lowestRatingOpndLast36Mos')!=''&&creditReportMap.get('Lowest Rating Opened Last 36'+responseMap.get('lowestRatingOpndLast36Mos'))!=null){
            objAccount.lowestRatingOpndLast36Mos__c = creditReportMap.get('Lowest Rating Opened Last 36'+responseMap.get('lowestRatingOpndLast36Mos'));
        }
        if(responseMap.get('maxDelqEver')!=null&&responseMap.get('maxDelqEver')!=''&&Integer.valueOf(responseMap.get('maxDelqEver'))==1||responseMap.get('maxDelqEver')!=null&&responseMap.get('maxDelqEver')!=null&&responseMap.get('maxDelqEver')!=''&&(Integer.valueOf(responseMap.get('maxDelqEver'))>=10&&Integer.valueOf(responseMap.get('maxDelqEver'))<=999)){
            objAccount.maxDelqEver__c = responseMap.get('maxDelqEver');
        }else if(responseMap.get('maxDelqEver')!=null&&responseMap.get('maxDelqEver')!=''&&creditReportMap.get('Maximum Delinquency Ever'+responseMap.get('maxDelqEver'))!=null){
            objAccount.maxDelqEver__c = creditReportMap.get('Maximum Delinquency Ever'+responseMap.get('maxDelqEver'));
        }
        if(responseMap.get('mosSncMostRcnt30pDelq')!=null&&responseMap.get('mosSncMostRcnt30pDelq')!=''&&Integer.valueOf(responseMap.get('mosSncMostRcnt30pDelq'))>=0&&Integer.valueOf(responseMap.get('mosSncMostRcnt30pDelq'))<=1200){
            objAccount.mosSncMostRcnt30pDelq__c = responseMap.get('mosSncMostRcnt30pDelq');
        }else if(responseMap.get('mosSncMostRcnt30pDelq')!=null&&responseMap.get('mosSncMostRcnt30pDelq')!=''&&creditReportMap.get('Months Since Most Recent 30+'+responseMap.get('mosSncMostRcnt30pDelq'))!=null){
            objAccount.mosSncMostRcnt30pDelq__c = creditReportMap.get('Months Since Most Recent 30+'+responseMap.get('mosSncMostRcnt30pDelq'));
        }
        if(responseMap.get('mosSncMostRcnt60pDelq')!=null&&responseMap.get('mosSncMostRcnt60pDelq')!=''&&Integer.valueOf(responseMap.get('mosSncMostRcnt60pDelq'))>=0&&Integer.valueOf(responseMap.get('mosSncMostRcnt60pDelq'))<=1200){
            objAccount.mosSncMostRcnt60pDelq__c = responseMap.get('mosSncMostRcnt60pDelq');
        }else if(responseMap.get('mosSncMostRcnt60pDelq')!=null&&responseMap.get('mosSncMostRcnt60pDelq')!=''&&creditReportMap.get('Months Since Most Recent 60+'+responseMap.get('mosSncMostRcnt60pDelq'))!=null){
            objAccount.mosSncMostRcnt60pDelq__c = creditReportMap.get('Months Since Most Recent 60+'+responseMap.get('mosSncMostRcnt60pDelq'));
        }
        if(responseMap.get('mosSncMostRcntDtOpnd')!=null&&responseMap.get('mosSncMostRcntDtOpnd')!=''&&Integer.valueOf(responseMap.get('mosSncMostRcntDtOpnd'))>=0&&Integer.valueOf(responseMap.get('mosSncMostRcntDtOpnd'))<=1200){
            objAccount.mosSncMostRcntDtOpnd__c = responseMap.get('mosSncMostRcntDtOpnd');
        }else if(responseMap.get('mosSncMostRcntDtOpnd')!=null&&responseMap.get('mosSncMostRcntDtOpnd')!=''&&creditReportMap.get('Months Since Most Recent Date'+responseMap.get('mosSncMostRcntDtOpnd'))!=null){
            objAccount.mosSncMostRcntDtOpnd__c = creditReportMap.get('Months Since Most Recent Date'+responseMap.get('mosSncMostRcntDtOpnd'));
        }
        if(responseMap.get('mosSncMostRcntFinTLOpnd')!=null&&responseMap.get('mosSncMostRcntFinTLOpnd')!=''&&Integer.valueOf(responseMap.get('mosSncMostRcntFinTLOpnd'))>=0&&Integer.valueOf(responseMap.get('mosSncMostRcntFinTLOpnd'))<=1200){
            objAccount.mosSncMostRcntFinTLOpnd__c = responseMap.get('mosSncMostRcntFinTLOpnd');
        }else if(responseMap.get('mosSncMostRcntFinTLOpnd')!=null&&responseMap.get('mosSncMostRcntFinTLOpnd')!=''&&creditReportMap.get('Months Since Most Recent Finance TL'+responseMap.get('mosSncMostRcntFinTLOpnd'))!=null){
            objAccount.mosSncMostRcntFinTLOpnd__c = creditReportMap.get('Months Since Most Recent Finance TL'+responseMap.get('mosSncMostRcntFinTLOpnd'));
        }
        if(responseMap.get('mosSncMostRcntInq')!=null&&responseMap.get('mosSncMostRcntInq')!=''&&Integer.valueOf(responseMap.get('mosSncMostRcntInq'))>=0&&Integer.valueOf(responseMap.get('mosSncMostRcntInq'))<=1200){
            objAccount.mosSncMostRcntInq__c = responseMap.get('mosSncMostRcntInq');
        }else if(responseMap.get('mosSncMostRcntInq')!=null&&responseMap.get('mosSncMostRcntInq')!=''&&creditReportMap.get('Months Since Most Recent Inquiry'+responseMap.get('mosSncMostRcntInq'))!=null){
            objAccount.mosSncMostRcntInq__c = creditReportMap.get('Months Since Most Recent Inquiry'+responseMap.get('mosSncMostRcntInq'));
        }
        if(responseMap.get('mosSncOldestDtOpnd')!=null&&responseMap.get('mosSncOldestDtOpnd')!=''&&Integer.valueOf(responseMap.get('mosSncOldestDtOpnd'))>=0&&Integer.valueOf(responseMap.get('mosSncOldestDtOpnd'))<=1200){
            objAccount.mosSncOldestDtOpnd__c = responseMap.get('mosSncOldestDtOpnd');
        }else if(responseMap.get('mosSncOldestDtOpnd')!=null&&responseMap.get('mosSncOldestDtOpnd')!=''&&creditReportMap.get('Months Since Oldest Date'+responseMap.get('mosSncOldestDtOpnd'))!=null){
            objAccount.mosSncOldestDtOpnd__c = creditReportMap.get('Months Since Oldest Date'+responseMap.get('mosSncOldestDtOpnd'));
        }
        if(responseMap.get('netFrctIL')!=null&&responseMap.get('netFrctIL')!=''&&Integer.valueOf(responseMap.get('netFrctIL'))>=0&&Integer.valueOf(responseMap.get('netFrctIL'))<=999){
            objAccount.netFrctIL__c = responseMap.get('netFrctIL');
        }else if(responseMap.get('netFrctIL')!=null&&responseMap.get('netFrctIL')!=''&&creditReportMap.get('Net Fraction Installment Burden'+responseMap.get('netFrctIL'))!=null){
            objAccount.netFrctIL__c = creditReportMap.get('Net Fraction Installment Burden'+responseMap.get('netFrctIL'));
        }
        if(responseMap.get('netFrctMtg')!=null&&responseMap.get('netFrctMtg')!=''&&Integer.valueOf(responseMap.get('netFrctMtg'))>=0&&Integer.valueOf(responseMap.get('netFrctMtg'))<=999){
            objAccount.netFrctMtg__c = responseMap.get('netFrctMtg');
        }else if(responseMap.get('netFrctMtg')!=null&&responseMap.get('netFrctMtg')!=''&&creditReportMap.get('Net Fraction Mortgage Burden'+responseMap.get('netFrctMtg'))!=null){
            objAccount.netFrctMtg__c = creditReportMap.get('Net Fraction Mortgage Burden'+responseMap.get('netFrctMtg'));
        }
        if(responseMap.get('netFrctRev')!=null&&responseMap.get('netFrctRev')!=''&&Integer.valueOf(responseMap.get('netFrctRev'))>=0&&Integer.valueOf(responseMap.get('netFrctRev'))<=999){
            objAccount.netFrctRev__c = responseMap.get('netFrctRev');
        }else if(responseMap.get('netFrctRev')!=null&&responseMap.get('netFrctRev')!=''&&creditReportMap.get('Net Fraction Revolving Burden'+responseMap.get('netFrctRev'))!=null){
            objAccount.netFrctRev__c = creditReportMap.get('Net Fraction Revolving Burden'+responseMap.get('netFrctRev'));
        }
        if(responseMap.get('numCollection')!=null&&responseMap.get('numCollection')!=''&&Integer.valueOf(responseMap.get('numCollection'))>=0&&Integer.valueOf(responseMap.get('numCollection'))<=999){
            objAccount.numCollection__c = responseMap.get('numCollection');
        }
        if(responseMap.get('numDaysInq0to11MosExclLast30Days')!=null&&responseMap.get('numDaysInq0to11MosExclLast30Days')!=''&&Integer.valueOf(responseMap.get('numDaysInq0to11MosExclLast30Days'))>=0&&Integer.valueOf(responseMap.get('numDaysInq0to11MosExclLast30Days'))<=999){
            objAccount.numDaysInq0to11MosExclLast30Days__c = responseMap.get('numDaysInq0to11MosExclLast30Days');
        }
        if(responseMap.get('numFinTL')!=null&&responseMap.get('numFinTL')!=''&&Integer.valueOf(responseMap.get('numFinTL'))>=0&&Integer.valueOf(responseMap.get('numFinTL'))<=999){
            objAccount.numFinTL__c = responseMap.get('numFinTL');
        }
        if(responseMap.get('numInq0to11MosExclLast30Days')!=null&&responseMap.get('numInq0to11MosExclLast30Days')!=''&&Integer.valueOf(responseMap.get('numInq0to11MosExclLast30Days'))>=0&&Integer.valueOf(responseMap.get('numInq0to11MosExclLast30Days'))<=999){
            objAccount.numInq0to11MosExclLast30Days__c = responseMap.get('numInq0to11MosExclLast30Days');
        }
        if(responseMap.get('numInq0to5MosExclLast14Days')!=null&&responseMap.get('numInq0to5MosExclLast14Days')!=''&&Integer.valueOf(responseMap.get('numInq0to5MosExclLast14Days'))>=0&&Integer.valueOf(responseMap.get('numInq0to5MosExclLast14Days'))<=999){
            objAccount.numInq0to5MosExclLast14Days__c = responseMap.get('numInq0to5MosExclLast14Days');
        }
        if(responseMap.get('numInq0to5MosExclLast7Days')!=null&&responseMap.get('numInq0to5MosExclLast7Days')!=''&&Integer.valueOf(responseMap.get('numInq0to5MosExclLast7Days'))>=0&&Integer.valueOf(responseMap.get('numInq0to5MosExclLast7Days'))<=999){
            objAccount.numInq0to5MosExclLast7Days__c = responseMap.get('numInq0to5MosExclLast7Days');
        }
        if(responseMap.get('numPR')!=null&&responseMap.get('numPR')!=''&&Integer.valueOf(responseMap.get('numPR'))>=0&&Integer.valueOf(responseMap.get('numPR'))<=999){
            objAccount.numPR__c = responseMap.get('numPR');
        }
        if(responseMap.get('numRevOpenTLWBal')!=null&&responseMap.get('numRevOpenTLWBal')!=''&&Integer.valueOf(responseMap.get('numRevOpenTLWBal'))>=0&&Integer.valueOf(responseMap.get('numRevOpenTLWBal'))<=999){
            objAccount.numRevOpenTLWBal__c = responseMap.get('numRevOpenTLWBal');
        }else if(responseMap.get('numRevOpenTLWBal')!=null&&responseMap.get('numRevOpenTLWBal')!=''&&creditReportMap.get('Revolving Open End Trade Lines'+responseMap.get('numRevOpenTLWBal'))!=null){
            objAccount.numRevOpenTLWBal__c = creditReportMap.get('Revolving Open End Trade Lines'+responseMap.get('numRevOpenTLWBal'));
        }
        if(responseMap.get('numRevTL30pDaysEver')!=null&&responseMap.get('numRevTL30pDaysEver')!=''&&Integer.valueOf(responseMap.get('numRevTL30pDaysEver'))>=0&&Integer.valueOf(responseMap.get('numRevTL30pDaysEver'))<=999){
            objAccount.numRevTL30pDaysEver__c = responseMap.get('numRevTL30pDaysEver');
        }else if(responseMap.get('numRevTL30pDaysEver')!=null&&responseMap.get('numRevTL30pDaysEver')!=''&&creditReportMap.get('Revolving Trade Lines 30+ Ever'+responseMap.get('numRevTL30pDaysEver'))!=null){
            objAccount.numRevTL30pDaysEver__c = creditReportMap.get('Revolving Trade Lines 30+ Ever'+responseMap.get('numRevTL30pDaysEver'));
        }
        if(responseMap.get('numRevTLWBal50PctAmt')!=null&&responseMap.get('numRevTLWBal50PctAmt')!=''&&Integer.valueOf(responseMap.get('numRevTLWBal50PctAmt'))>=0&&Integer.valueOf(responseMap.get('numRevTLWBal50PctAmt'))<=999){
            objAccount.numRevTLWBal50PctAmt__c = responseMap.get('numRevTLWBal50PctAmt');
        }else if(responseMap.get('numRevTLWBal50PctAmt')!=null&&responseMap.get('numRevTLWBal50PctAmt')!=''&&creditReportMap.get('Revolving Trade Lines Bal>=50'+responseMap.get('numRevTLWBal50PctAmt'))!=null){
            objAccount.numRevTLWBal50PctAmt__c = creditReportMap.get('Revolving Trade Lines Bal>=50'+responseMap.get('numRevTLWBal50PctAmt'));
        }
        if(responseMap.get('numTL')!=null&&responseMap.get('numTL')!=''&&Integer.valueOf(responseMap.get('numTL'))>=0&&Integer.valueOf(responseMap.get('numTL'))<=999){
            objAccount.numTL__c = responseMap.get('numTL');
        }
        if(responseMap.get('numTLOpnd3MosAndNotGT2x30Days')!=null&&responseMap.get('numTLOpnd3MosAndNotGT2x30Days')!=''&&Integer.valueOf(responseMap.get('numTLOpnd3MosAndNotGT2x30Days'))>=0&&Integer.valueOf(responseMap.get('numTLOpnd3MosAndNotGT2x30Days'))<=999){
            objAccount.numTLOpnd3MosAndNotGT2x30Days__c = responseMap.get('numTLOpnd3MosAndNotGT2x30Days');
        }
        if(responseMap.get('pctTLNeverDelq')!=null&&responseMap.get('pctTLNeverDelq')!=''&&Decimal.valueOf(responseMap.get('pctTLNeverDelq'))>=0&&Decimal.valueOf(responseMap.get('pctTLNeverDelq'))<=100){
            objAccount.pctTLNeverDelq__c = responseMap.get('pctTLNeverDelq');
        }else if(responseMap.get('pctTLNeverDelq')!=null&&responseMap.get('pctTLNeverDelq')!=''&&creditReportMap.get('Trade Lines Never Delinquent'+responseMap.get('pctTLNeverDelq'))!=null){
            objAccount.pctTLNeverDelq__c = creditReportMap.get('Trade Lines Never Delinquent'+responseMap.get('pctTLNeverDelq'));
        }
        if(responseMap.get('pctTLNowCurr')!=null&&responseMap.get('pctTLNowCurr')!=''&&Decimal.valueOf(responseMap.get('pctTLNowCurr'))>=0&&Decimal.valueOf(responseMap.get('pctTLNowCurr'))<=100){
            objAccount.pctTLNowCurr__c = responseMap.get('pctTLNowCurr');
        }else if(responseMap.get('pctTLNowCurr')!=null&&responseMap.get('pctTLNowCurr')!=''&&creditReportMap.get('Trade Lines Now Current'+responseMap.get('pctTLNowCurr'))!=null){
            objAccount.pctTLNowCurr__c = creditReportMap.get('Trade Lines Now Current'+responseMap.get('pctTLNowCurr'));
        }
        if(responseMap.get('totBal')!=null&&responseMap.get('totBal')!=''&&Decimal.valueOf(responseMap.get('totBal'))>=0&&Decimal.valueOf(responseMap.get('totBal'))<=9999999){
            objAccount.totBal__c = responseMap.get('totBal');
        }else if(responseMap.get('totBal')!=null&&responseMap.get('totBal')!=''&&creditReportMap.get('Total Trade Line Balance'+responseMap.get('totBal'))!=null){
            objAccount.totBal__c = creditReportMap.get('Total Trade Line Balance'+responseMap.get('totBal'));
        }
        return objAccount;
    }
    /**
    * @description Add Credit Bureau Info to Business
    * @author  Pritam Roy | 02-22-2024 
    * @param objAccountToUpdateBusiness 
    * @param businessInfo 
    * @param creditReportMap 
    * @return Account 
    **/
    private static Account addCreditBureauInfoToBusiness(Account objAccountToUpdateBusiness,Dom.XmlNode businessInfo,Map<String,String> creditReportMap){
        List<String> responseSbssBusiness = new List<String>();
        List<String> responseBk10Business = new List<String>();
        if(businessInfo!=null){
            Dom.XmlNode decisionDataNode = businessInfo.getChildElement('decisionData',null);
            if(decisionDataNode!=null){
                Dom.XmlNode scoringListForBusiness = decisionDataNode.getChildElement('scoringList',null);
                if(scoringListForBusiness!=null){
                    List<Dom.XmlNode> listOfScoringForBusiness = scoringListForBusiness.getChildElements();
                    if(!listOfScoringForBusiness.isEmpty()){
                        for(Dom.XmlNode node : listOfScoringForBusiness){
                            if(node!=null){
                                if(node.getAttribute('type', null)==ConstantValues.SBSS_SCORE){
                                    objAccountToUpdateBusiness.SBSS70_Score__c = node.getChildElement('totalScore',null).getText();
                                    responseSbssBusiness = parseReasonCode(node.getChildElement('modelReasonList',null));
                                    if(!responseSbssBusiness.isEmpty()&&responseSbssBusiness.size()>0&&responseSbssBusiness[0]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseSbssBusiness[0])!=null){
                                        objAccountToUpdateBusiness.Model_Reason_1__c = responseSbssBusiness[0] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseSbssBusiness[0]);
                                    }else if(!responseSbssBusiness.isEmpty()&&responseSbssBusiness.size()>0&&responseSbssBusiness[0]!=null){
                                        objAccountToUpdateBusiness.Model_Reason_1__c = responseSbssBusiness[0] + ' : No Model Found';
                                    }else{
                                        objAccountToUpdateBusiness.Model_Reason_1__c = ' : No Model Found';
                                    }
                                    if(!responseSbssBusiness.isEmpty()&&responseSbssBusiness.size()>1&&responseSbssBusiness[1]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseSbssBusiness[1])!=null){
                                        objAccountToUpdateBusiness.Model_Reason_2__c = responseSbssBusiness[1] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseSbssBusiness[1]);
                                    }else if(!responseSbssBusiness.isEmpty()&&responseSbssBusiness.size()>1&&responseSbssBusiness[1]!=null){
                                        objAccountToUpdateBusiness.Model_Reason_2__c = responseSbssBusiness[1] + ' : No Model Found';
                                    }else{
                                        objAccountToUpdateBusiness.Model_Reason_2__c = ' : No Model Found';
                                    }
                                    if(!responseSbssBusiness.isEmpty()&&responseSbssBusiness.size()>2&&responseSbssBusiness[2]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseSbssBusiness[2])!=null){
                                        objAccountToUpdateBusiness.Model_Reason_3__c = responseSbssBusiness[2] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseSbssBusiness[2]);
                                    }else if(!responseSbssBusiness.isEmpty()&&responseSbssBusiness.size()>2&&responseSbssBusiness[2]!=null){
                                        objAccountToUpdateBusiness.Model_Reason_3__c = responseSbssBusiness[2] + ' : No Model Found';
                                    }else{
                                        objAccountToUpdateBusiness.Model_Reason_3__c = ' : No Model Found';
                                    }
                                    if(!responseSbssBusiness.isEmpty()&&responseSbssBusiness.size()>3&&responseSbssBusiness[3]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseSbssBusiness[3])!=null){
                                        objAccountToUpdateBusiness.Model_Reason_4__c = responseSbssBusiness[3] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseSbssBusiness[3]);
                                    }else if(!responseSbssBusiness.isEmpty()&&responseSbssBusiness.size()>3&&responseSbssBusiness[3]!=null){
                                        objAccountToUpdateBusiness.Model_Reason_4__c = responseSbssBusiness[3] + ' : No Model Found';
                                    }else{
                                        objAccountToUpdateBusiness.Model_Reason_4__c = ' : No Model Found';
                                    }
                                }else{
                                    objAccountToUpdateBusiness.BK10_Score__c = node.getChildElement('totalScore',null).getText();
                                    responseBk10Business = parseReasonCode(node.getChildElement('modelReasonList',null));
                                    if(!responseBk10Business.isEmpty()&&responseBk10Business.size()>0&&responseBk10Business[0]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseBk10Business[0])!=null){
                                        objAccountToUpdateBusiness.Model_Reason_Bk_1__c = responseBk10Business[0] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseBk10Business[0]);
                                    }else if(!responseBk10Business.isEmpty()&&responseBk10Business.size()>0&&responseBk10Business[0]!=null){
                                        objAccountToUpdateBusiness.Model_Reason_Bk_1__c = responseBk10Business[0] + ' : No Model Found';
                                    }else{
                                        objAccountToUpdateBusiness.Model_Reason_Bk_1__c = ' : No Model Found';
                                    }
                                    if(!responseBk10Business.isEmpty()&&responseBk10Business.size()>1&&responseBk10Business[1]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseBk10Business[1])!=null){
                                        objAccountToUpdateBusiness.Model_Reason_Bk_2__c = responseBk10Business[1] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseBk10Business[1]);
                                    }else if(!responseBk10Business.isEmpty()&&responseBk10Business.size()>1&&responseBk10Business[1]!=null){
                                        objAccountToUpdateBusiness.Model_Reason_Bk_2__c = responseBk10Business[1] + ' : No Model Found';
                                    }else{
                                        objAccountToUpdateBusiness.Model_Reason_Bk_2__c = ' : No Model Found';
                                    }
                                    if(!responseBk10Business.isEmpty()&&responseBk10Business.size()>2&&responseBk10Business[2]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseBk10Business[2])!=null){
                                        objAccountToUpdateBusiness.Model_Reason_Bk_3__c = responseBk10Business[2] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseBk10Business[2]);
                                    }else if(!responseBk10Business.isEmpty()&&responseBk10Business.size()>2&&responseBk10Business[2]!=null){
                                        objAccountToUpdateBusiness.Model_Reason_Bk_3__c = responseBk10Business[2] + ' : No Model Found';
                                    }else{
                                        objAccountToUpdateBusiness.Model_Reason_Bk_3__c = ' : No Model Found';
                                    }
                                    if(!responseBk10Business.isEmpty()&&responseBk10Business.size()>3&&responseBk10Business[3]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseBk10Business[3])!=null){
                                        objAccountToUpdateBusiness.Model_Reason_Bk_4__c = responseBk10Business[3] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseBk10Business[3]);
                                    }else if(!responseBk10Business.isEmpty()&&responseBk10Business.size()>3&&responseBk10Business[3]!=null){
                                        objAccountToUpdateBusiness.Model_Reason_Bk_4__c = responseBk10Business[3] + ' : No Model Found';
                                    }else{
                                        objAccountToUpdateBusiness.Model_Reason_Bk_4__c = ' : No Model Found';
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return objAccountToUpdateBusiness;
    }
    /**
    * @description Clear credit bureau info
    * @author  Pritam Roy | 02-22-2024 
    * @param objAccount 
    * @return Account 
    **/
    private static Account clearCreditBureauInfo(Account objAccount){
        objAccount.Score_1__c = '';
        objAccount.Score_2__c = '';
        objAccount.totBal__c = '';
        objAccount.AbnormalReportIndicator__c = '';
        objAccount.addressMismatchIndicator__c = '';
        objAccount.aliasIndicator__c = '';
        objAccount.bankruptcyOnFileIndicator__c = '';
        objAccount.consumerStatementIndicator__c = '';
        objAccount.contactSubscriberIndicator__c = '';
        objAccount.creditCounselingIndicator__c = '';
        objAccount.disputedAccountIndicator__c = '';
        objAccount.fileVariationIndicator__c = '';
        objAccount.irregularReportDeceasedIndicator__c = '';
        objAccount.irregularReportManualFileIndicator__c = '';
        objAccount.lostOrStolenCardIndicator__c = '';
        objAccount.nameMismatchIndicator__c = '';
        objAccount.securityFrozenFileIndicator__c = '';
        objAccount.securityOfacIndicator__c = '';
        objAccount.securityReportIndicator__c = '';
        objAccount.ssnVariationIndicator__c = '';
        objAccount.thinFileIndicator__c = '';
        objAccount.avgMosInFileTLRptd0To2Mos__c = '';
        objAccount.highestUtilOnBankNatlRevTL__c = '';
        objAccount.maxDelqPR0To11Mos__c = '';
        objAccount.mosSncOldestBankNatlRevOpenTLOpnd__c = '';
        objAccount.numTL30pDaysEverDerogPR__c = '';
        objAccount.numTL60pDaysEverDerogPR__c = '';
        objAccount.numTL90pDaysEverDerogPR__c = '';
        objAccount.numBankNatlRevTL90PctRptd0To2Mos__c = '';
        objAccount.numBankNatlRevTLWBal75PctAmt__c = '';
        objAccount.lowestRatingRevOpen__c = '';
        objAccount.avgMosInFile__c = '';
        objAccount.lowestRating__c = '';
        objAccount.lowestRatingIL__c = '';
        objAccount.lowestRatingOpndLast12Mos__c = '';
        objAccount.lowestRatingOpndLast24Mos__c = '';
        objAccount.lowestRatingOpndLast36Mos__c = '';
        objAccount.maxDelqEver__c = '';
        objAccount.mosSncMostRcnt30pDelq__c = '';
        objAccount.mosSncMostRcnt60pDelq__c = '';
        objAccount.mosSncMostRcntDtOpnd__c = '';
        objAccount.mosSncMostRcntFinTLOpnd__c = '';
        objAccount.mosSncMostRcntInq__c = '';
        objAccount.mosSncOldestDtOpnd__c = '';
        objAccount.netFrctIL__c = '';
        objAccount.netFrctMtg__c = '';
        objAccount.netFrctRev__c = '';
        objAccount.numCollection__c = '';
        objAccount.numDaysInq0to11MosExclLast30Days__c = '';
        objAccount.numFinTL__c = '';
        objAccount.numInq0to11MosExclLast30Days__c = '';
        objAccount.numInq0to5MosExclLast14Days__c = '';
        objAccount.numInq0to5MosExclLast7Days__c = '';
        objAccount.numPR__c = '';
        objAccount.numRevOpenTLWBal__c = '';
        objAccount.numRevTL30pDaysEver__c = '';
        objAccount.numRevTLWBal50PctAmt__c = '';
        objAccount.numTL__c = '';
        objAccount.numTLOpnd3MosAndNotGT2x30Days__c = '';
        objAccount.pctTLNeverDelq__c = '';
        objAccount.pctTLNowCurr__c = '';
        objAccount.Model_Reason_1__c = ' : No Model Found';
        objAccount.Model_Reason_2__c = ' : No Model Found';
        objAccount.Model_Reason_3__c = ' : No Model Found';
        objAccount.Model_Reason_4__c = ' : No Model Found';
        objAccount.Model_Reason_Bk_1__c = ' : No Model Found';
        objAccount.Model_Reason_Bk_2__c = ' : No Model Found';
        objAccount.Model_Reason_Bk_3__c = ' : No Model Found';
        objAccount.Model_Reason_Bk_4__c = ' : No Model Found';
        return objAccount;
    }
    /**
    * @description Add reason code to account
    * @author  Pritam Roy | 02-22-2024 
    * @param objAccount 
    * @param decisionData1 
    * @param creditReportMap 
    * @return Account 
    **/
    private static Account addReasonCodeToAccount(Account objAccount,Dom.XmlNode decisionData1,Map<String,String> creditReportMap){
        List<String> responseSbssList = new List<String>();
        List<String> responseBk10List = new List<String>();
        if(decisionData1!=null){
            Dom.XmlNode scoringList = decisionData1.getChildElement('scoringList',null);
            if(scoringList!=null){
                List<Dom.XmlNode> listOfScoring = scoringList.getChildElements();
                if(!listOfScoring.isEmpty()){
                    if(listOfScoring.size() > 0&&listOfScoring[0].getChildElement('totalScore',null).getText()!=null&&listOfScoring[0].getChildElement('modelReasonList',null)!=null&&listOfScoring[0].getAttribute('type',null) == ConstantValues.SBSS_SCORE){
                        objAccount.SBSS70_Score__c = listOfScoring[0].getChildElement('totalScore',null).getText();
                        responseSbssList = parseReasonCode(listOfScoring[0].getChildElement('modelReasonList',null));
                        if(!responseSbssList.isEmpty()&&responseSbssList.size()>0&&responseSbssList[0]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseSbssList[0])!=null){
                            objAccount.Model_Reason_1__c = responseSbssList[0] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseSbssList[0]);
                        }else if(!responseSbssList.isEmpty()&&responseSbssList.size()>0&&responseSbssList[0]!=null){ 
                            objAccount.Model_Reason_1__c = responseSbssList[0] + ' : No Model Found';
                        }else{
                            objAccount.Model_Reason_1__c = ' : No Model Found';
                        }
                        if(!responseSbssList.isEmpty()&&responseSbssList.size()>1&&responseSbssList[1]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseSbssList[1])!=null){
                            objAccount.Model_Reason_2__c = responseSbssList[1] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseSbssList[1]);
                        }else if(!responseSbssList.isEmpty()&&responseSbssList.size()>1&&responseSbssList[1]!=null){ 
                            objAccount.Model_Reason_2__c = responseSbssList[1] + ' : No Model Found';
                        }else{
                            objAccount.Model_Reason_2__c = ' : No Model Found';
                        }
                        if(!responseSbssList.isEmpty()&&responseSbssList.size()>2&&responseSbssList[2]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseSbssList[2])!=null){
                            objAccount.Model_Reason_3__c = responseSbssList[2] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseSbssList[2]);
                        }else if(!responseSbssList.isEmpty()&&responseSbssList.size()>2&&responseSbssList[2]!=null){ 
                            objAccount.Model_Reason_3__c = responseSbssList[2] + ' : No Model Found';
                        }else{
                            objAccount.Model_Reason_3__c = ' : No Model Found';
                        }
                        if(!responseSbssList.isEmpty()&&responseSbssList.size()>3&&responseSbssList[3]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseSbssList[3])!=null){
                            objAccount.Model_Reason_4__c = responseSbssList[3] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseSbssList[3]);
                        }else if(!responseSbssList.isEmpty()&&responseSbssList.size()>3&&responseSbssList[3]!=null){ 
                            objAccount.Model_Reason_4__c = responseSbssList[3] + ' : No Model Found';
                        }else{
                            objAccount.Model_Reason_4__c = ' : No Model Found';
                        }
                    }
                    if(listOfScoring.size() > 1&&listOfScoring[1].getChildElement('totalScore',null).getText()!=null&&listOfScoring[1].getChildElement('modelReasonList',null)!=null&&listOfScoring[1].getAttribute('type',null) == 'BK10'){
                        objAccount.BK10_Score__c = listOfScoring[1].getChildElement('totalScore',null).getText();
                        responseBk10List = parseReasonCode(listOfScoring[1].getChildElement('modelReasonList',null));
                        if(!responseBk10List.isEmpty()&&responseBk10List.size()>0&&responseBk10List[0]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseBk10List[0])!=null){
                            objAccount.Model_Reason_Bk_1__c = responseBk10List[0] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseBk10List[0]);
                        }else if(!responseBk10List.isEmpty()&&responseBk10List.size()>0&&responseBk10List[0]!=null){
                            objAccount.Model_Reason_Bk_1__c = responseBk10List[0] + ' : No Model Found';
                        }else{
                            objAccount.Model_Reason_Bk_1__c = ' : No Model Found';
                        }
                        if(!responseBk10List.isEmpty()&&responseBk10List.size()>1&&responseBk10List[1]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseBk10List[1])!=null){
                            objAccount.Model_Reason_Bk_2__c = responseBk10List[1] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseBk10List[1]);
                        }else if(!responseBk10List.isEmpty()&&responseBk10List.size()>1&&responseBk10List[1]!=null){
                            objAccount.Model_Reason_Bk_2__c = responseBk10List[1] + ' : No Model Found';
                        }else{
                            objAccount.Model_Reason_Bk_2__c = ' : No Model Found';
                        }
                        if(!responseBk10List.isEmpty()&&responseBk10List.size()>2&&responseBk10List[2]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseBk10List[2])!=null){
                            objAccount.Model_Reason_Bk_3__c = responseBk10List[2] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseBk10List[2]);
                        }else if(!responseBk10List.isEmpty()&&responseBk10List.size()>2&&responseBk10List[2]!=null){
                            objAccount.Model_Reason_Bk_3__c = responseBk10List[2] + ' : No Model Found';
                        }else{
                            objAccount.Model_Reason_Bk_3__c = ' : No Model Found';
                        }
                        if(!responseBk10List.isEmpty()&&responseBk10List.size()>3&&responseBk10List[3]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseBk10List[3])!=null){
                            objAccount.Model_Reason_Bk_4__c = responseBk10List[3] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseBk10List[3]);
                        }else if(!responseBk10List.isEmpty()&&responseBk10List.size()>3&&responseBk10List[3]!=null){
                            objAccount.Model_Reason_Bk_4__c = responseBk10List[3] + ' : No Model Found';
                        }else{
                            objAccount.Model_Reason_Bk_4__c = ' : No Model Found';
                        }
                    } 
                    if(listOfScoring.size() >1&&listOfScoring[1].getChildElement('totalScore',null).getText()!=null&&listOfScoring[1].getChildElement('modelReasonList',null)!=null&&listOfScoring[1].getAttribute('type',null) == ConstantValues.SBSS_SCORE){
                        objAccount.SBSS70_Score__c = listOfScoring[1].getChildElement('totalScore',null).getText();
                        responseSbssList = parseReasonCode(listOfScoring[1].getChildElement('modelReasonList',null));
                        
                        if(!responseSbssList.isEmpty()&&responseSbssList.size()>0&&responseSbssList[0]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseSbssList[0])!=null){
                            objAccount.Model_Reason_1__c = responseSbssList[0] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseSbssList[0]);
                        }else if(!responseSbssList.isEmpty()&&responseSbssList.size()>0&&responseSbssList[0]!=null){
                            objAccount.Model_Reason_1__c = responseSbssList[0] + ' : No Model Found';
                        }else{
                            objAccount.Model_Reason_1__c = ' : No Model Found';
                        }
                        if(!responseSbssList.isEmpty()&&responseSbssList.size()>1&&responseSbssList[1]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseSbssList[1])!=null){
                            objAccount.Model_Reason_2__c = responseSbssList[1] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseSbssList[1]);
                        }else if(!responseSbssList.isEmpty()&&responseSbssList.size()>1&&responseSbssList[1]!=null){
                            objAccount.Model_Reason_2__c = responseSbssList[1] + ' : No Model Found';
                        }else{
                            objAccount.Model_Reason_2__c = ' : No Model Found';
                        }
                        if(!responseSbssList.isEmpty()&&responseSbssList.size()>2&&responseSbssList[2]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseSbssList[2])!=null){
                            objAccount.Model_Reason_3__c = responseSbssList[2] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseSbssList[2]);
                        }else if(!responseSbssList.isEmpty()&&responseSbssList.size()>2&&responseSbssList[2]!=null){
                            objAccount.Model_Reason_3__c = responseSbssList[2] + ' : No Model Found';
                        }else{
                            objAccount.Model_Reason_3__c = ' : No Model Found';
                        }
                        if(!responseSbssList.isEmpty()&&responseSbssList.size()>3&&responseSbssList[3]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseSbssList[3])!=null){
                            objAccount.Model_Reason_4__c = responseSbssList[3] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseSbssList[3]);
                        }else if(!responseSbssList.isEmpty()&&responseSbssList.size()>3&&responseSbssList[3]!=null){
                            objAccount.Model_Reason_4__c = responseSbssList[3] + ' : No Model Found';
                        }else{
                            objAccount.Model_Reason_4__c = ' : No Model Found';
                        }
                    }                                
                    if(listOfScoring.size() >0&&listOfScoring[0].getChildElement('totalScore',null).getText()!=null&&listOfScoring[0].getChildElement('modelReasonList',null)!=null&& listOfScoring[0].getAttribute('type',null) == 'BK10'){
                        objAccount.BK10_Score__c = listOfScoring[0].getChildElement('totalScore',null).getText();
                        responseBk10List = parseReasonCode(listOfScoring[0].getChildElement('modelReasonList',null));
                        if(!responseBk10List.isEmpty()&&responseBk10List.size()>0&&responseBk10List[0]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseBk10List[0])!=null){
                            objAccount.Model_Reason_Bk_1__c = responseBk10List[0] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseBk10List[0]);
                        }else if(!responseBk10List.isEmpty()&&responseBk10List.size()>0&&responseBk10List[0]!=null){
                            objAccount.Model_Reason_Bk_1__c = responseBk10List[0] + ' : No Model Found';
                        }else{
                            objAccount.Model_Reason_Bk_1__c = ' : No Model Found';
                        }
                        if(!responseBk10List.isEmpty()&&responseBk10List.size()>1&&responseBk10List[1]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseBk10List[1])!=null){
                            objAccount.Model_Reason_Bk_2__c = responseBk10List[1] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseBk10List[1]);
                        }else if(!responseBk10List.isEmpty()&&responseBk10List.size()>1&&responseBk10List[1]!=null){
                            objAccount.Model_Reason_Bk_2__c = responseBk10List[1] + ' : No Model Found';
                        }else{
                            objAccount.Model_Reason_Bk_2__c = ' : No Model Found';
                        }
                        if(!responseBk10List.isEmpty()&&responseBk10List.size()>2&&responseBk10List[2]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseBk10List[2])!=null){
                            objAccount.Model_Reason_Bk_3__c = responseBk10List[2] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseBk10List[2]);
                        }else if(!responseBk10List.isEmpty()&&responseBk10List.size()>2&&responseBk10List[2]!=null){
                            objAccount.Model_Reason_Bk_3__c = responseBk10List[2] + ' : No Model Found';
                        }else{
                            objAccount.Model_Reason_Bk_3__c = ' : No Model Found';
                        }
                        if(!responseBk10List.isEmpty()&&responseBk10List.size()>3&&responseBk10List[3]!=null&&creditReportMap.get('Business Scoring Reason Code'+responseBk10List[3])!=null){
                            objAccount.Model_Reason_Bk_4__c = responseBk10List[3] + ' : ' + creditReportMap.get('Business Scoring Reason Code'+responseBk10List[3]);
                        }else if(!responseBk10List.isEmpty()&&responseBk10List.size()>3&&responseBk10List[3]!=null){
                            objAccount.Model_Reason_Bk_4__c = responseBk10List[3] + ' : No Model Found';
                        }else{
                            objAccount.Model_Reason_Bk_4__c = ' : No Model Found';
                        }
                    }
                }
            }
        }
        return objAccount;
    }
    /**
    * @description Create credit bureau report
    * @author  Pritam Roy | 02-22-2024 
    * @param response 
    * @param applicationId 
    **/
    public static void createCreditBureauReport(String response,String applicationId){
        Map<String, clcommon__Party__c> partyMap = new Map<String, clcommon__Party__c>();
        List<clcommon__Party__c> partyList = new List<clcommon__Party__c>();
        List<Account> objAccountToUpdateList = new List<Account>();
        List<clcommon__Party__c> scoredPartyList = new List<clcommon__Party__c>();
        List<Account> scoredAccountList = new List<Account>();
        List<Id> scoredAccountIds = new List<Id>();
        List<FICOCreditReportMapping__mdt> creditReportMappingList = new List<FICOCreditReportMapping__mdt>();
        Map<String,String> creditReportMap = new Map<String,String>();
        List<String> responseScoreList;
        String borrowerAccountId;
        String borrowerPartyId;
        String applicantLegalEntity;
        String responseMsg = '';
        String refinedResponse = '';
        Integer principalCount = 1;
        Blob objBlob = Blob.valueOf(response.replace('&lt;','<').replace('&gt;','>').replace('<?xml version="1.0" encoding="UTF-8"?>', '').replace('SOAP-ENV','SOAP'));
        Attachment objAttachment = new Attachment();
        objAttachment.Body = objBlob;
        objAttachment.ParentId = applicationId;
        objAttachment.Name = ConstantValues.RESPONSE_ATTACHMENT_NAME + '.xml';
        //Adding XML Response to Attachment
        if(Attachment.SObjectType.getDescribe(SObjectDescribeOptions.FULL).isCreateable()){
            Database.insert(objAttachment, true);
        }
        Database.insert(new clcommon__Log__c(Name = 'FICO - Raw Response' ,
                    clcommon__Message__c = 'FICO - Raw Response' 
                    + response,
                    clcommon__Time__c = System.Now()), false); 
        Logger.info('FICO - Raw Response' 
                    + response);
        //savepoint
        SavePoint dbSavePoint = Database.setSavepoint();
        try{
            String firstCData = '';
            String secondCData = '';
            DOM.Document xmlDocument = new DOM.Document();
            Integer emptyPrintImage = response.indexOf('printImage/');
            Integer cdataStart = response.indexOf('![CDATA['); 
            Integer cdataEnd = response.indexOf(']]'); 
            if(emptyPrintImage != -1 && cdataEnd != -1 && (emptyPrintImage - cdataEnd) < 0){
                if (cdataStart != -1 && cdataEnd != -1) {
                    secondCData = response.substring(cdataStart + 9, cdataEnd).replace('<=',' LESS THAN EQUAL TO ').replace('>=',' GREATER THAN EQUAL TO ').replace(' <',' LESS THAN').replace('> ','GREATER THAN ').replace('<',' LESS THAN ').replace('>',' GREATER THAN ');
                }
            }else{
                if (cdataStart != -1 && cdataEnd != -1) {
                    firstCData = response.substring(cdataStart + 9, cdataEnd).replace('<=',' LESS THAN EQUAL TO ').replace('>=',' GREATER THAN EQUAL TO ').replace(' <',' LESS THAN').replace('> ','GREATER THAN ').replace('<',' LESS THAN ').replace('>',' GREATER THAN ');
                }
                cdataStart = response.indexOf('![CDATA[',cdataStart + 1);
                cdataEnd = response.indexOf(']]',cdataEnd + 1); 
                if (cdataStart != -1 && cdataEnd != -1) {
                    secondCData = response.substring(cdataStart + 9, cdataEnd).replace('<=',' LESS THAN EQUAL TO ').replace('>=',' GREATER THAN EQUAL TO ').replace(' <',' LESS THAN').replace('> ','GREATER THAN ').replace('<',' LESS THAN ').replace('>',' GREATER THAN ');
                }
            }
            refinedResponse = response.replace('&lt;','<').replace('&gt;','>').replace('<?xml version="1.0" encoding="UTF-8"?>', '').replace('SOAP-ENV','SOAP');

            Database.insert(new clcommon__Log__c(Name = 'FICO - Refined Response' ,
                    clcommon__Message__c = 'FICO - Refined Response' 
                    + refinedResponse,
                    clcommon__Time__c = System.Now()), false); 
            Logger.info('FICO - Refined Response' 
                    + refinedResponse);
            //Initialisation of parsing
            xmlDocument.load(refinedResponse);
            Dom.XMlNode root = xmlDocument.getRootElement();
            Dom.XMLNode body = root.getChildElement('Body',root.getNamespace());
            Dom.XMLNode obtainDecisionDataResponse  = body.getChildElement('ObtainDecisionDataResponse','http://www.liquidCredit.com/');
            Dom.XMLNode obtainDecisionDataResult  = obtainDecisionDataResponse.getChildElement('ObtainDecisionDataResult','http://www.liquidCredit.com/');
            Dom.XmlNode filiquidCredit = obtainDecisionDataResult.getChildElement('FI_LiquidCredit',null);
            Dom.XmlNode principalList = filiquidCredit.getChildElement('principal_list',null);
            List<User> loggedInPortalUser = new List<User>();
            loggedInPortalUser = [SELECT Id,
                                    Profile.Name,
                                    ContactId,
                                    AccountId
                                FROM USER
                                WHERE Id = :UserInfo.getUserId()
                                AND Profile.Name IN (:PortalConstants.FIELD_STAFF_AGENT,:PortalConstants.CERTIFIED_LENDER ,:PortalConstants.CERTIFIED_LENDER_PLUS)];
        
            List<Dom.XMLNode> childNodePrincipalList = principalList.getChildElements();
            List<String> ssnList = new List<String>();
            for(Dom.XmlNode node : childNodePrincipalList){
                String ssn = node.getChildElement('SSN',null).getText();
                ssnList.add(ssn);
            }
            //fetching custom metadata
            if(FICOCreditReportMapping__mdt.SObjectType.getDescribe(SObjectDescribeOptions.FULL).isAccessible()){
                creditReportMappingList = [SELECT Id,
                                                Display_Message__c,
                                                Response_Codes__c,
                                                Response_Fields__c
                                            FROM FICOCreditReportMapping__mdt];
                                            
            }
            if(creditReportMappingList.isEmpty()){
                throw new CustomException('Mapping Data not Found');
            }
            if(creditReportMappingList!=null){
                for(FICOCreditReportMapping__mdt report : creditReportMappingList){
                    creditReportMap.put(report.Response_Fields__c+report.Response_Codes__c,report.Display_Message__c);
                }
            }                            
            if(applicationId!=null){
                if(clcommon__Party__c.SObjectType.getDescribe(SObjectDescribeOptions.FULL).isAccessible()){
                    if(loggedInPortalUser.size()>0){
                        scoredPartyList = [SELECT id,
                                                clcommon__Account__c,
                                                clcommon__Account__r.Fico_Document_Generated__c,
                                                clcommon__Account__r.FICO_Recorded_On__c 
                                                FROM clcommon__Party__c 
                                            WHERE genesis__Application__c = :applicationId
                                            AND (clcommon__Party_Types__c = :PortalConstants.BORROWER_PARTY_NAME OR
                                            clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME)
                                            AND clcommon__Account__c != null 
                                            AND clcommon__Account__r.Fico_Document_Generated__c = true
                                            AND clcommon__Account__r.FICO_Recorded_On__c != LAST_N_DAYS:182];
                        }
                        else{
                            scoredPartyList = [SELECT id,
                                                    clcommon__Account__c,
                                                    clcommon__Account__r.Fico_Document_Generated__c,
                                                    clcommon__Account__r.FICO_Recorded_On__c,
                                                    clcommon__Account__r.clcommon__Legal_Entity_Type__r.name
                                                    FROM clcommon__Party__c 
                                                WHERE genesis__Application__c = :applicationId
                                                AND (clcommon__Party_Types__c = :PortalConstants.BORROWER_PARTY_NAME OR
                                                clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME)
                                                AND clcommon__Account__c != null 
                                                AND clcommon__Account__r.Fico_Document_Generated__c = true
                                                AND (clcommon__Contact__r.genesis__SSN__c IN: ssnList OR clcommon__Account__r.clcommon__Legal_Entity_Type__r.name != :PortalConstants.SOLE_PROP_ENTITY)];
                            
                    }
                }
                if(!scoredPartyList.isEmpty()){
                    for(clcommon__Party__c objIndividualParty : scoredPartyList){
                        scoredAccountIds.add(objIndividualParty.clcommon__Account__c);
                    }
                    scoredAccountList=[SELECT Id,
                                            Fico_Document_Generated__c 
                                        FROM ACCOUNT 
                                        WHERE ID In:scoredAccountIds 
                                        WITH SECURITY_ENFORCED];
                    for(Account acc:scoredAccountList){
                        acc.Fico_Document_Generated__c = false;
                    }
                    //If fico scored greater than 182 days update party to regenerate document
                    if(Account.SObjectType.getDescribe(SObjectDescribeOptions.FULL).isUpdateable()){
                        Database.update(scoredAccountList, true);
                    }
                }
                if(clcommon__Party__c.SObjectType.getDescribe(SObjectDescribeOptions.FULL).isAccessible()){    
                    partyList =    [SELECT  Name, 
                                            Id,
                                            clcommon__Account__r.Fico_Document_Generated__c, 
                                            clcommon__Type__r.Name,
                                            clcommon__Contact__c,
                                            clcommon__Contact__r.genesis__SSN__c, 
                                            clcommon__Account__c,
                                            clcommon__Party_Types__c,
                                            clcommon__Account__r.clcommon__Legal_Entity_Type__r.name,
                                            clcommon__Account__r.message_text__c,
                                            clcommon__Account__r.Score_1__c,
                                            clcommon__Account__r.Score_2__c,
                                            clcommon__Account__r.SBSS70_Score__c,
                                            clcommon__Account__r.BK10_Score__c,
                                            clcommon__Account__r.AbnormalReportIndicator__c,
                                            clcommon__Account__r.addressMismatchIndicator__c,
                                            clcommon__Account__r.aliasIndicator__c,
                                            clcommon__Account__r.bankruptcyOnFileIndicator__c,
                                            clcommon__Account__r.consumerStatementIndicator__c,
                                            clcommon__Account__r.contactSubscriberIndicator__c,
                                            clcommon__Account__r.creditCounselingIndicator__c,
                                            clcommon__Account__r.disputedAccountIndicator__c,
                                            clcommon__Account__r.fileVariationIndicator__c,
                                            clcommon__Account__r.irregularReportDeceasedIndicator__c,
                                            clcommon__Account__r.irregularReportManualFileIndicator__c,
                                            clcommon__Account__r.lostOrStolenCardIndicator__c,
                                            clcommon__Account__r.nameMismatchIndicator__c,
                                            clcommon__Account__r.securityFrozenFileIndicator__c,
                                            clcommon__Account__r.securityOfacIndicator__c,
                                            clcommon__Account__r.securityReportIndicator__c,
                                            clcommon__Account__r.ssnVariationIndicator__c,
                                            clcommon__Account__r.thinFileIndicator__c,
                                            clcommon__Account__r.avgMosInFileTLRptd0To2Mos__c,
                                            clcommon__Account__r.highestUtilOnBankNatlRevTL__c,
                                            clcommon__Account__r.maxDelqPR0To11Mos__c,
                                            clcommon__Account__r.mosSncOldestBankNatlRevOpenTLOpnd__c,
                                            clcommon__Account__r.numTL30pDaysEverDerogPR__c,
                                            clcommon__Account__r.numTL60pDaysEverDerogPR__c,
                                            clcommon__Account__r.numTL90pDaysEverDerogPR__c,
                                            clcommon__Account__r.numBankNatlRevTL90PctRptd0To2Mos__c,
                                            clcommon__Account__r.numBankNatlRevTLWBal75PctAmt__c,
                                            clcommon__Account__r.lowestRatingRevOpen__c,
                                            clcommon__Account__r.avgMosInFile__c,
                                            clcommon__Account__r.lowestRating__c,
                                            clcommon__Account__r.lowestRatingIL__c,
                                            clcommon__Account__r.lowestRatingOpndLast12Mos__c,
                                            clcommon__Account__r.lowestRatingOpndLast24Mos__c,
                                            clcommon__Account__r.lowestRatingOpndLast36Mos__c,
                                            clcommon__Account__r.maxDelqEver__c,
                                            clcommon__Account__r.mosSncMostRcnt30pDelq__c,
                                            clcommon__Account__r.mosSncMostRcnt60pDelq__c,
                                            clcommon__Account__r.mosSncMostRcntDtOpnd__c,
                                            clcommon__Account__r.mosSncMostRcntFinTLOpnd__c,
                                            clcommon__Account__r.mosSncMostRcntInq__c,
                                            clcommon__Account__r.mosSncOldestDtOpnd__c,
                                            clcommon__Account__r.netFrctIL__c,
                                            clcommon__Account__r.netFrctMtg__c,
                                            clcommon__Account__r.netFrctRev__c,
                                            clcommon__Account__r.numCollection__c,
                                            clcommon__Account__r.numDaysInq0to11MosExclLast30Days__c,
                                            clcommon__Account__r.numFinTL__c,
                                            clcommon__Account__r.numInq0to11MosExclLast30Days__c,
                                            clcommon__Account__r.numInq0to5MosExclLast14Days__c,
                                            clcommon__Account__r.numInq0to5MosExclLast7Days__c,
                                            clcommon__Account__r.numPR__c,
                                            clcommon__Account__r.numRevOpenTLWBal__c,
                                            clcommon__Account__r.numRevTL30pDaysEver__c,
                                            clcommon__Account__r.numRevTLWBal50PctAmt__c,
                                            clcommon__Account__r.numTL__c,
                                            clcommon__Account__r.numTLOpnd3MosAndNotGT2x30Days__c,
                                            clcommon__Account__r.pctTLNeverDelq__c,
                                            clcommon__Account__r.pctTLNowCurr__c,
                                            clcommon__Account__r.totBal__c,
                                            clcommon__Account__r.Model_Reason_1__c,
                                            clcommon__Account__r.Model_Reason_2__c,
                                            clcommon__Account__r.Model_Reason_3__c,
                                            clcommon__Account__r.Model_Reason_4__c,
                                            clcommon__Account__r.Model_Reason_Bk_1__c,
                                            clcommon__Account__r.Model_Reason_Bk_2__c,
                                            clcommon__Account__r.Model_Reason_Bk_3__c,
                                            clcommon__Account__r.Model_Reason_Bk_4__c,
                                            clcommon__Account__r.Reason_Code_1__c,
                                            clcommon__Account__r.Reason_Code_2__c,
                                            clcommon__Account__r.Reason_Code_3__c,
                                            clcommon__Account__r.Reason_Code_4__c,
                                            clcommon__Account__r.Message__c
                                    FROM clcommon__Party__c 
                                    WHERE genesis__Application__c = :applicationId
                                    AND (clcommon__Party_Types__c = :PortalConstants.BORROWER_PARTY_NAME OR
                                    clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME)
                                    AND clcommon__Account__c != null];
                }
            }
            if(partyList.isEmpty()){
                throw new CustomException('Party List is Empty');
            }
            for(clcommon__Party__c objIndividualParty : partyList){
                if(objIndividualParty.clcommon__Contact__c != null &&
                    objIndividualParty.clcommon__Contact__r.genesis__SSN__c != null){
                        partyMap.put(objIndividualParty.clcommon__Contact__r.genesis__SSN__c,objIndividualParty);
                }
                if(objIndividualParty.clcommon__Party_Types__c == PortalConstants.BORROWER_PARTY_NAME){
                    borrowerAccountId = objIndividualParty.clcommon__Account__c;
                    borrowerPartyId = objIndividualParty.Id;
                    applicantLegalEntity = objIndividualParty.clcommon__Account__r.clcommon__Legal_Entity_Type__r.name;
                }
            }
            Dom.XmlNode responseMsgList = filiquidCredit.getChildElement('response_message_list', null);
            if(responseMsgList!=null){
                List<Dom.XmlNode> messageInfoList = responseMsgList.getChildElements();
                for(Dom.XmlNode node : messageInfoList){
                    Dom.XmlNode messageText = node.getChildElement('message_text', null);
                    responseMsg += messageText.getText() + '\n';
                }
            }
            if(principalList!=null){
                List<Dom.XMLNode> childNodeOfPrincipalList = principalList.getChildElements();
                List<Account> clearAccountList =new List<Account>();
                for(Dom.XmlNode node : childNodeOfPrincipalList){
                    Account objAccount;
                    clcommon__Party__c objPartyToParse;
                    if(node!=null){
                        String ssn = node.getChildElement('SSN',null).getText();
                        if(partyMap.get(ssn) != null){
                            objPartyToParse = partyMap.get(ssn);
                            objAccount = new Account(Id = objPartyToParse.clcommon__Account__c);
                            objAccount = clearCreditBureauInfo(objAccount);
                            clearAccountList.add(objAccount);
                        }
                    }
                }
                if(Account.SObjectType.getDescribe(SObjectDescribeOptions.FULL).isCreateable()
                    ||Account.SObjectType.getDescribe(SObjectDescribeOptions.FULL).isUpdateable()){
                    //Clearing the previous fico data when score is regenerated
                    Database.upsert(clearAccountList, false);
                }
                //Parsing for multiple principal
                for(Dom.XmlNode node : childNodeOfPrincipalList){
                    String score1 = '';
                    String score2 = '';
                    String printImageText = '';
                    String refinedPrintImageText = '';
                    clcommon__Party__c objPartyToParse;
                    Account objAccount;
                    Map<String,String> responseMap = new Map<String,String>();
                    Map<String,String> responseIndicatorMap = new Map<String,String>();
                    Map<String,String> responseCharacteristicsMap = new Map<String,String>();

                    if(node!=null){
                        Dom.XmlNode dataSourceList = node.getChildElement('dataSourceList', null);
                        if(dataSourceList!=null){
                            Dom.XmlNode dataSource = dataSourceList.getChildElement('dataSource',null);
                            if(dataSource!=null){
                                Dom.XmlNode responseTag = dataSource.getChildElement('response', null);
                                if(responseTag!=null){
                                    Dom.XmlNode printImage = responseTag.getChildElement('printImage',null);
                                    if(printImage!=null){
                                        printImageText = (principalCount == 1)? firstCData.replaceAll('([ \t]*\n){3,}', '\n\n') : secondCData.replaceAll('([ \t]*\n){3,}', '\n\n');
                                        if(!String.isBlank(printImageText)){
                                            refinedPrintImageText = printImageText.substring(printImageText.indexOf('PAGE'));
                                        }   
                                        principalCount++;
                                    }
                                }
                            }
                        }
                        
                        Dom.XmlNode decisionData = node.getChildElement('decisionData',null);
                        if(decisionData!=null){
                            Dom.XmlNode dataSourceAnalysisList = decisionData.getChildElement('dataSourceAnalysisList',null);
                            if(dataSourceAnalysisList!=null){
                                Dom.XmlNode dataSourceAnalysis = dataSourceAnalysisList.getChildElement('dataSourceAnalysis',null);
                                if(dataSourceAnalysis!=null){    
                                    //Parsing Indicators
                                    Dom.XmlNode indicators = dataSourceAnalysis.getChildElement('indicators',null);
                                    responseIndicatorMap = parseIndicators(indicators);//1
                                    //Parsing Characteristics
                                    Dom.XmlNode characteristics = dataSourceAnalysis.getChildElement('characteristics', null);
                                    responseCharacteristicsMap = parseCharacteristics(characteristics);//2

                                    Dom.XmlNode scoreNode1 = dataSourceAnalysis.getChildElement('score1',null);
                                    if(scoreNode1!=null){
                                        score1 = scoreNode1.getAttribute('Score',null);
                                        responseScoreList = parseReasonCode(scoreNode1);
                                        if(responseScoreList.size()>0&&responseScoreList[0]!=null){
                                            responseMap.put('ReasonCode1',responseScoreList[0]);
                                        }
                                        if(responseScoreList.size()>1&&responseScoreList[1]!=null){
                                            responseMap.put('ReasonCode2',responseScoreList[1]);
                                        }
                                        if(responseScoreList.size()>2&&responseScoreList[2]!=null){
                                            responseMap.put('ReasonCode3',responseScoreList[2]);
                                        }
                                        if(responseScoreList.size()>3&&responseScoreList[3]!=null){
                                            responseMap.put('ReasonCode4',responseScoreList[3]);
                                        }   
                                    }
                                    Dom.XmlNode scoreNode2 = dataSourceAnalysis.getChildElement('score2',null);
                                    if(scoreNode2!=null){
                                        score2 = scoreNode2.getAttribute('Score',null);
                                    }
                                }
                            }
                        }
                        //getting the ssn for a particular principal from the response and storing it in a string
                        String ssn = node.getChildElement('SSN',null).getText();
                        //Checking whether the principal inside the map have the same ssn as coming in the response
                        if(partyMap.get(ssn) != null){
                            objPartyToParse = partyMap.get(ssn);
                            objAccount = new Account(Id = objPartyToParse.clcommon__Account__c);
                            objAccount.FICO_Recorded_On__c = System.now();
                            objAccount.Score_1__c = score1;
                            objAccount.Score_2__c = score2;
                            //Indicators
                            objAccount = addIndicatorsToAccount(objAccount, responseIndicatorMap, creditReportMap);
                            //Characteristics
                            objAccount = addCharacteristicsToAccount(objAccount, responseCharacteristicsMap, creditReportMap);
                            
                            objAccount.message_text__c = responseMsg;
                            if(responseMap.get('ReasonCode1')!=null&&responseMap.get('ReasonCode1')!=''){
                                if(creditReportMap.get('Experian Score Factors'+responseMap.get('ReasonCode1'))!=null){
                                    objAccount.Reason_Code_1__c	= responseMap.get('ReasonCode1') + ' : ' + creditReportMap.get('Experian Score Factors'+responseMap.get('ReasonCode1'));
                                }else{
                                    objAccount.Reason_Code_1__c	= responseMap.get('ReasonCode1') + ' : No Model Found';
                                }
                            }else{
                                objAccount.Reason_Code_1__c	= ': No Model Found'; 
                            }
                            if(responseMap.get('ReasonCode2')!=null&&responseMap.get('ReasonCode2')!=''){
                                if(creditReportMap.get('Experian Score Factors'+responseMap.get('ReasonCode2'))!=null){
                                    objAccount.Reason_Code_2__c	= responseMap.get('ReasonCode2') + ' : ' + creditReportMap.get('Experian Score Factors'+responseMap.get('ReasonCode2'));
                                }else{
                                    objAccount.Reason_Code_2__c	= responseMap.get('ReasonCode2') + ' : No Model Found';
                                }
                            }else{
                                objAccount.Reason_Code_2__c = ': No Model Found';
                            }
                            if(responseMap.get('ReasonCode3')!=null&&responseMap.get('ReasonCode3')!=''){
                                if(creditReportMap.get('Experian Score Factors'+responseMap.get('ReasonCode3'))!=null){
                                    objAccount.Reason_Code_3__c	= responseMap.get('ReasonCode3') + ' : ' + creditReportMap.get('Experian Score Factors'+responseMap.get('ReasonCode3'));
                                }else{
                                    objAccount.Reason_Code_3__c	= responseMap.get('ReasonCode3') + ' : No Model Found';
                                }
                            }else{
                                objAccount.Reason_Code_3__c = ': No Model Found';
                            }
                            if(responseMap.get('ReasonCode4')!=null&&responseMap.get('ReasonCode4')!=''){
                                if(creditReportMap.get('Experian Score Factors'+responseMap.get('ReasonCode4'))!=null){
                                    objAccount.Reason_Code_4__c	= responseMap.get('ReasonCode4') + ' : ' + creditReportMap.get('Experian Score Factors'+responseMap.get('ReasonCode4'));
                                }else{
                                    objAccount.Reason_Code_4__c	= responseMap.get('ReasonCode4') + ' : No Model Found';
                                }
                            }else{
                                objAccount.Reason_Code_4__c = ': No Model Found';
                            }    
                            objAccount.Message__c =  refinedPrintImageText;
                            
                            Dom.XmlNode decisionData1= node.getChildElement('decisionData',null);
                            objAccount = addReasonCodeToAccount(objAccount,decisionData1,creditReportMap);
                            objAccount.Fico_Document_Generated__c=true;
                            
                        }
                        if(objPartyToParse != null){
                            objAccountToUpdateList.add(objAccount);
                            
                        }
                    }   
                }
                //parsing the response for the business associated with the application
                if(applicantLegalEntity != PortalConstants.SOLE_PROP_ENTITY){
                    Account objAccountToUpdateBusiness;
                    if(borrowerAccountId != null){
                        objAccountToUpdateBusiness = new Account(Id = borrowerAccountId);
                    }
                    objAccountToUpdateBusiness.Model_Reason_1__c = ' : No Model Found';
                    objAccountToUpdateBusiness.Model_Reason_2__c = ' : No Model Found';
                    objAccountToUpdateBusiness.Model_Reason_3__c = ' : No Model Found';
                    objAccountToUpdateBusiness.Model_Reason_4__c = ' : No Model Found';
                    objAccountToUpdateBusiness.Model_Reason_Bk_1__c = ' : No Model Found';
                    objAccountToUpdateBusiness.Model_Reason_Bk_2__c = ' : No Model Found';
                    objAccountToUpdateBusiness.Model_Reason_Bk_3__c = ' : No Model Found';
                    objAccountToUpdateBusiness.Model_Reason_Bk_4__c = ' : No Model Found';
                    if(Account.SObjectType.getDescribe(SObjectDescribeOptions.FULL).isCreateable()
                        ||Account.SObjectType.getDescribe(SObjectDescribeOptions.FULL).isUpdateable()){
                        //Clearing previous fico data when score is regenerated
                        Database.upsert(objAccountToUpdateBusiness, true);
                    }
                    objAccountToUpdateBusiness.message_text__c = responseMsg;
                    objAccountToUpdateBusiness.FICO_Recorded_On__c = System.now();
                    Dom.XmlNode businessInfo = filiquidCredit.getChildElement('business_info',null);
                    objAccountToUpdateBusiness = addCreditBureauInfoToBusiness(objAccountToUpdateBusiness, businessInfo, creditReportMap);
                    objAccountToUpdateBusiness.Fico_Document_Generated__c = true;   
                    objAccountToUpdateList.add(objAccountToUpdateBusiness);
                   
                }
                //Adding the all the parties that need to get their score fields populate in a list and upserting the scores in party level
                if(Account.SObjectType.getDescribe(SObjectDescribeOptions.FULL).isCreateable()
                    ||Account.SObjectType.getDescribe(SObjectDescribeOptions.FULL).isUpdateable()){
                    Database.upsert(objAccountToUpdateList, false);
                   
                }
            }
        }
        catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            PortalHelper.saveExceptionLog(objCustomException, ConstantValues.RESPONSE_PARSER_EXCEPTION);
        }
        catch (Exception objCustomException) {
            Database.rollback(dbSavePoint);
            PortalHelper.saveExceptionLog(objCustomException, ConstantValues.RESPONSE_PARSER_EXCEPTION);
        }
    }
}