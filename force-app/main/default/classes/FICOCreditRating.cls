/**
 * @description       : Stores the constant values required for FICO
 * @author            :  Subham Nandi
 * @group             : 
 * @last modified on  : 03-07-2025
 * @last modified by  : Kabir Pramanik
**/

global without sharing class FICOCreditRating {


    /**
    * @description : Check Evergreen Business Status
    * @author  Pritam Roy | 05-29-2024 
    * @param appToUpdateList
    * @param creditRatingMap
    * @return List<genesis__Applications__c> 
    **/
    private static List<genesis__Applications__c> markEvergreenBusinessStatus(List<genesis__Applications__c> appToUpdateList,Map<String, Id> creditRatingMap){
        if(appToUpdateList[0].genesis__Credit_Rating__c == creditRatingMap.get(ConstantValues.CREDIT_RATE_2)){ 
            if(appToUpdateList[0].Evergreen_Tier_Two_Business_Info_Status__c == PortalConstants.EVERGREEN_BIZ_STATUS_IN_ELIGIBLE){
                appToUpdateList[0].Evergreen_Tier_Two_Business_Info_Status__c = PortalConstants.EVERGREEN_BIZ_STATUS_PENDING;
            }
        }
        if(appToUpdateList[0].genesis__Credit_Rating__c != creditRatingMap.get(ConstantValues.CREDIT_RATE_4)){
            appToUpdateList[0].Stage__c = PortalConstants.SCORE_CREDIT_REFERENCE;
        }
        else{
            appToUpdateList[0].genesis__Status__c = PortalConstants.NEW_ENTERED_APPLICATION_STATUS;
            appToUpdateList[0].Is_Evergreen__c = false;
            appToUpdateList[0].Stage__c = PortalConstants.APPLICANT_SIGNATURE;
        }
        return appToUpdateList;
    }
    /**
    * @description This method is a part of the flow when an application is submitted, It categorises it
    * @author Subham Nandi | 14-01-2022 
    * @param applicationId 
    **/
    global static void ficoCreditRatingMatrix(String applicationId) {
        SavePoint dbSavePoint = Database.setSavepoint();
        try {
            List<genesis__Applications__c> objApplicationToUpdateList = new List<genesis__Applications__c>();
            //List<genesis__Credit_Rating_Matrix__c> objCreditRatingTiersLists = new List<genesis__Credit_Rating_Matrix__c>();
            Integer ficoScore = 0;
            Integer sbssScore = 0;
            Decimal loanAmount = 0;
            Decimal netWorth;
            List<genesis__Credit_Rating_Matrix__c> objCreditRatingTiersLists = [SELECT  Id, 
                                                                                        Name 
                                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                                ORDER BY Name ASC
                                                                                LIMIT 4];
            if(objCreditRatingTiersLists == null || objCreditRatingTiersLists.size() == 0){
                throw new CustomException(ConstantValues.CREDIT_RATING_EXCEPTION);
            }
            Map<String, Id> creditRatingMap = new Map<String ,Id>();
            for(genesis__Credit_Rating_Matrix__c objTier : objCreditRatingTiersLists){
                creditRatingMap.put(objTier.Name,objTier.Id);
            }
            if(applicationId != null){
                if(genesis__Applications__c.SObjectType.getDescribe().isAccessible()){
                    objApplicationToUpdateList =   [SELECT  Id, 
                                                            genesis__Credit_Rating__c, 
                                                            genesis__Credit_Rating__r.Name,
                                                            genesis__Loan_Amount__c,
                                                            FICO_Score__c,
                                                            SBSS_70_Score__c,
                                                            Net_Worth__c, 
                                                            genesis__Status__c,
                                                            Dealer_Name__r.genesis__Business_Information__r.Customised_Loan_Limit__c,
                                                            Evergreen_Tier_Two_Business_Info_Status__c,
                                                            Is_Evergreen__c,
                                                            (SELECT Id,
                                                                    clcommon__Account__r.Score_1__c, 
                                                                    clcommon__Account__r.SBSS70_Score__c  
                                                            FROM genesis__Parties__r 
                                                            WHERE 
                                                            (clcommon__Party_Types__c = :ConstantValues.PRINCIPAL_PARTY OR clcommon__Party_Types__c = :ConstantValues.BORROWER_PARTY) AND 
                                                            clcommon__Account__r.SBSS70_Score__c != null AND
                                                            clcommon__Account__r.SBSS70_Score__c < :ConstantValues.MAXIMUM_ELIGIBLE_SBSS AND
                                                            clcommon__Account__r.Score_1__c != null AND 
                                                            clcommon__Account__r.Score_1__c < :ConstantValues.MAXIMUM_ELIGIBLE_FICO
                                                            ORDER BY clcommon__Account__r.Score_1__c DESC LIMIT 1)
                                                    FROM genesis__Applications__c 
                                                    WHERE Id = :applicationId];
                    if(!objApplicationToUpdateList.isEmpty() 
                                && (objApplicationToUpdateList[ConstantValues.ZERO_VALUE].genesis__Status__c == ConstantValues.ACTIVE
                                || objApplicationToUpdateList[ConstantValues.ZERO_VALUE].genesis__Status__c == ConstantValues.PENDING_APPROVAL_APPLICATION_STATUS)) {
                        return;                       
                    }
                    if(objApplicationToUpdateList.size() > 0 &&
                        objApplicationToUpdateList[0].FICO_Score__c == null &&
                        objApplicationToUpdateList[0].SBSS_70_Score__c == null &&
                        objApplicationToUpdateList[0].Net_Worth__c == null){
                            //Scoring the application when the callout is not made and there are parties with existing scores
                            for(clcommon__party__c objParty : objApplicationToUpdateList[0].genesis__Parties__r){
                                objApplicationToUpdateList[0].FICO_Score__c = objParty.clcommon__Account__r.Score_1__c;
                                objApplicationToUpdateList[0].SBSS_70_Score__c = objParty.clcommon__Account__r.SBSS70_Score__c;
                            }
                            //query the maximum networth from all the borrower or the principal party
                            List<clcommon__Party__c> objPartyForMaxNetworth = [SELECT  Id, 
                                                                                        Net_Worth__c,
                                                                                        clcommon__account__r.clcommon__Legal_Entity_Type__r.name 
                                                                                FROM clcommon__Party__c 
                                                                                WHERE genesis__Application__c = :applicationId AND
                                                                                Net_Worth__c != null AND
                                                                                (clcommon__Party_Types__c = :ConstantValues.PRINCIPAL_PARTY OR clcommon__Party_Types__c = :ConstantValues.BORROWER_PARTY)
                                                                                AND clcommon__account__r.clcommon__Legal_Entity_Type__r.name !=: PortalConstants.INDIVIDUAL_ENTITY
                                                                                ORDER BY Net_Worth__c  DESC
                                                                                LIMIT 1];
                            if(objPartyForMaxNetworth.size() > 0){
                                objApplicationToUpdateList[0].Net_Worth__c = String.valueOf(objPartyForMaxNetworth[0].Net_Worth__c);
                                
                            }
                            Database.update(objApplicationToUpdateList,true);
                    }
                }
            }
            if(objApplicationToUpdateList==null || objApplicationToUpdateList.size()==0){
                throw new CustomException(ConstantValues.CREDIT_RATING_EXCEPTION);
            }
            if(objApplicationToUpdateList[0].FICO_Score__c != null){
                ficoScore = integer.valueOf(objApplicationToUpdateList[0].FICO_Score__c);
            }
            if(objApplicationToUpdateList[0].SBSS_70_Score__c != null){
                sbssScore = integer.valueOf(objApplicationToUpdateList[0].SBSS_70_Score__c);
            }
            if(objApplicationToUpdateList[0].genesis__Loan_Amount__c != null){
                loanAmount = objApplicationToUpdateList[0].genesis__Loan_Amount__c;
            }
            if(objApplicationToUpdateList[0].Net_Worth__c != null){
                netWorth = Decimal.valueOf(objApplicationToUpdateList[0].Net_Worth__c);
            }
            
            //Categorising the appplication into different Tiers depending upon the ficoScore, sbssScore and Networth
            if(ficoScore > Integer.valueOf( ConstantValues.FICO_MIN_TIER_1) 
                && ficoScore <= Integer.valueOf(ConstantValues.FICO_MAX_TIER_1)
                && sbssScore > Integer.valueOf(ConstantValues.SBSS_MIN_TIER_1) 
                && netWorth >= 4*loanAmount){
                objApplicationToUpdateList[0].genesis__Credit_Rating__c = creditRatingMap.get(ConstantValues.CREDIT_RATE_1);
                objApplicationToUpdateList[0].genesis__Status__c = ConstantValues.SCORECARD_GENERATED;
                objApplicationToUpdateList[0].Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_1);

            }
            else if(ficoScore > Integer.valueOf(ConstantValues.FICO_MIN_TIER_2) 
                    && ficoScore <= Integer.valueOf(ConstantValues.FICO_MAX_TIER_1)
                    && sbssScore > Integer.valueOf(ConstantValues.SBSS_MIN_TIER_2) 
                    && netWorth>=loanAmount){
                objApplicationToUpdateList[0].genesis__Credit_Rating__c = creditRatingMap.get(ConstantValues.CREDIT_RATE_2);
                objApplicationToUpdateList[0].genesis__Status__c = ConstantValues.SCORECARD_GENERATED;
                objApplicationToUpdateList[0].Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_2);
            }
            //Condition Check for Tier 3
            else if((ficoScore > Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) 
                        && sbssScore > Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3) 
                        && netWorth>0)
                    //If Score is more than 899 - Credit Bureau is Locked
                    ||  (ficoScore > Integer.valueOf(ConstantValues.FICO_MAX_TIER_1))
                    //If no Score is Returned
                    ||  (ficoScore == 0 && sbssScore == 0 && netWorth>0)){
                objApplicationToUpdateList[0].genesis__Credit_Rating__c = creditRatingMap.get(ConstantValues.CREDIT_RATE_3);
                objApplicationToUpdateList[0].genesis__Status__c = ConstantValues.SCORECARD_GENERATED;
                objApplicationToUpdateList[0].Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_3);
                objApplicationToUpdateList[0].Additional_Information_Needed__c = true;
            }
            //Condition Check for Tier 4
            else if((ficoScore <= Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) &&
                    ficoScore > 0 ) 
                    ||
                    (sbssScore <= Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3) &&
                    sbssScore > 0 )
                    ||
                    netWorth <= 0){
                        objApplicationToUpdateList[0].genesis__Credit_Rating__c = creditRatingMap.get(ConstantValues.CREDIT_RATE_4);
                        objApplicationToUpdateList[0].genesis__Status__c = ConstantValues.SCORECARD_GENERATED;
                        objApplicationToUpdateList[0].Additional_Information_Needed__c = true;
                        if(objApplicationToUpdateList[0].Dealer_Name__c != null &&
                            objApplicationToUpdateList[0].Dealer_Name__r.genesis__Business_Information__c != null &&
                            objApplicationToUpdateList[0].Dealer_Name__r.genesis__Business_Information__r.Customised_Loan_Limit__c > 0 && 
                            objApplicationToUpdateList[0].Dealer_Name__r.genesis__Business_Information__r.Customised_Loan_Limit__c != null){
                                //Dealer can customise
                                objApplicationToUpdateList[0].Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_4);
                        }
                        else{
                            objApplicationToUpdateList[0].Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_1);
                        }
                
            }
            else{
                objApplicationToUpdateList[0].genesis__Credit_Rating__c = creditRatingMap.get(ConstantValues.CREDIT_RATE_3);
                objApplicationToUpdateList[0].genesis__Status__c = ConstantValues.SCORECARD_GENERATED;
                objApplicationToUpdateList[0].Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_3);
                objApplicationToUpdateList[0].Additional_Information_Needed__c = true;
            }

            //Evergreen Checks------------------------------------------------------------------------------------------
            if(objApplicationToUpdateList[0].Is_Evergreen__c == true){
                objApplicationToUpdateList = markEvergreenBusinessStatus(objApplicationToUpdateList,creditRatingMap);
            }
            //Evergreen Checks------------------------------------------------------------------------------------------
            if(genesis__Applications__c.SObjectType.getDescribe().isUpdateable()){
                Database.update(objApplicationToUpdateList, true);
            }

        }
        catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            PortalHelper.saveExceptionLog(objCustomException, ConstantValues.CREDIT_RATING_EXCEPTION);
        }
        catch (Exception objException) {
            Database.rollback(dbSavePoint);
            PortalHelper.saveExceptionLog(objException, ConstantValues.CREDIT_RATING_EXCEPTION);
        }
    }

    /**
    * @description Whenever a new party is scored, we need to call the credit rating to re-evaluate the application tier
    * @author Subham Nandi | 24-01-2022 
    * @param applicationId 
    **/
    webservice static void scoreTheApplication(String applicationId){
        SavePoint dbSavePoint = Database.setSavepoint();
        try {
            Integer ficoScore = 0;
            Integer sbssScore = 0;
            Decimal loanAmount = 0;
            Decimal netWorth;
            //List<genesis__Applications__c> objApplicationToUpdateList = new List<genesis__Applications__c>();
            //List<clcommon__Party__c> objPrincipalPartyList = new List<clcommon__Party__c>();
            //List<genesis__Credit_Rating_Matrix__c> objCreditRatingTiersLists = new List<genesis__Credit_Rating_Matrix__c>();
            List<clcommon__party__c> partyObjForMaxNetWorthList = new List<clcommon__party__c>();
            List<genesis__Credit_Rating_Matrix__c> objCreditRatingTiersLists = [SELECT  Id, 
                                                                                        Name 
                                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                                ORDER BY Name ASC
                                                                                LIMIT 4];
            if(objCreditRatingTiersLists == null || objCreditRatingTiersLists.size() == 0){
                throw new CustomException(ConstantValues.CREDIT_RATING_EXCEPTION);
            }
            Map<String, Id> creditRatingMap = new Map<String ,Id>();
            for(genesis__Credit_Rating_Matrix__c objTier : objCreditRatingTiersLists){
                creditRatingMap.put(objTier.Name,objTier.Id);
            }
            List<genesis__Applications__c> objApplicationToUpdateList = [SELECT Id,
                                                                                Is_Evergreen__c,
                                                                                Evergreen_Tier_Two_Business_Info_Status__c,
                                                                                (SELECT Id,
                                                                                        clcommon__Account__r.Score_1__c, 
                                                                                        clcommon__Account__r.SBSS70_Score__c  
                                                                                FROM genesis__Parties__r 
                                                                                WHERE (clcommon__Party_Types__c = :ConstantValues.PRINCIPAL_PARTY OR 
                                                                                        clcommon__Party_Types__c = :ConstantValues.BORROWER_PARTY) AND 
                                                                                clcommon__Account__r.SBSS70_Score__c != null AND
                                                                                clcommon__Account__r.SBSS70_Score__c < :ConstantValues.MAXIMUM_ELIGIBLE_SBSS AND
                                                                                clcommon__Account__r.Score_1__c != null AND 
                                                                                clcommon__Account__r.Score_1__c < :ConstantValues.MAXIMUM_ELIGIBLE_FICO
                                                                                ORDER BY clcommon__Account__r.Score_1__c DESC LIMIT 1),
                                                                                genesis__Loan_Amount__c,
                                                                                genesis__Status__c,
                                                                                genesis__Credit_Rating__c,
                                                                                genesis__Credit_Rating__r.Name,
                                                                                Dealer_Name__r.genesis__Business_Information__r.Customised_Loan_Limit__c
                                                                        FROM genesis__Applications__c 
                                                                        WHERE Id = :applicationId];
            if(objApplicationToUpdateList.size() == 0 || objApplicationToUpdateList == null){
                throw new CustomException(ConstantValues.CREDIT_RATING_EXCEPTION);
            }
            //storing the maximum score on the application
            if(objApplicationToUpdateList.size() > 0){
                for(clcommon__party__c objParty : objApplicationToUpdateList[0].genesis__Parties__r){
                    objApplicationToUpdateList[0].FICO_Score__c = objParty.clcommon__Account__r.Score_1__c;
                    objApplicationToUpdateList[0].SBSS_70_Score__c = objParty.clcommon__Account__r.SBSS70_Score__c;
                    ficoScore = Integer.valueOf(objParty.clcommon__Account__r.Score_1__c);
                    sbssScore = Integer.valueOf(objParty.clcommon__Account__r.SBSS70_Score__c);
                }
            }
            partyObjForMaxNetWorthList =   [SELECT  Id, 
                                                    Net_Worth__c,
                                                    clcommon__account__r.clcommon__Legal_Entity_Type__r.name 
                                            FROM clcommon__Party__c 
                                            WHERE genesis__Application__c = :applicationId AND 
                                            Net_Worth__c != null AND 
                                            (clcommon__Party_Types__c = :ConstantValues.PRINCIPAL_PARTY OR clcommon__Party_Types__c = :ConstantValues.BORROWER_PARTY)
                                            AND clcommon__account__r.clcommon__Legal_Entity_Type__r.name !=: PortalConstants.INDIVIDUAL_ENTITY
                                            ORDER BY Net_Worth__c DESC];
            if(partyObjForMaxNetWorthList.size() > 0 && partyObjForMaxNetWorthList[0].Net_Worth__c != null){
                objApplicationToUpdateList[0].Net_Worth__c = String.valueOf(partyObjForMaxNetWorthList[0].Net_Worth__c);
                netWorth = Decimal.valueOf(objApplicationToUpdateList[0].Net_Worth__c );
            }
            if(objApplicationToUpdateList[0].genesis__Loan_Amount__c != null){
                loanAmount = objApplicationToUpdateList[0].genesis__Loan_Amount__c;
            }
            //Categorising the appplication into different Tiers depending upon the ficoScore, sbssScore and Networth
            if(ficoScore > Integer.valueOf( ConstantValues.FICO_MIN_TIER_1) //739
                && ficoScore <= Integer.valueOf(ConstantValues.FICO_MAX_TIER_1)//899
                && sbssScore > Integer.valueOf(ConstantValues.SBSS_MIN_TIER_1) //199
                && netWorth >= 4*loanAmount){
                objApplicationToUpdateList[0].genesis__Credit_Rating__c = creditRatingMap.get(ConstantValues.CREDIT_RATE_1);
                objApplicationToUpdateList[0].Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_1);

            }
            else if(ficoScore > Integer.valueOf(ConstantValues.FICO_MIN_TIER_2) //669
                    && ficoScore <= Integer.valueOf(ConstantValues.FICO_MAX_TIER_1)//899
                    && sbssScore > Integer.valueOf(ConstantValues.SBSS_MIN_TIER_2) //159
                    && netWorth>=loanAmount){
                objApplicationToUpdateList[0].genesis__Credit_Rating__c = creditRatingMap.get(ConstantValues.CREDIT_RATE_2);
                objApplicationToUpdateList[0].Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_2);
            }
            else if((ficoScore > Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) //599
                        && sbssScore > Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3) //149
                        && netWorth>0)
                    || (ficoScore > Integer.valueOf(ConstantValues.FICO_MAX_TIER_1))){//899
                objApplicationToUpdateList[0].genesis__Credit_Rating__c = creditRatingMap.get(ConstantValues.CREDIT_RATE_3);
                objApplicationToUpdateList[0].Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_3);
                objApplicationToUpdateList[0].Additional_Information_Needed__c = true;
            }
            else if((ficoScore <= Integer.valueOf(ConstantValues.FICO_MIN_TIER_3) &&//599
                    ficoScore > 0 ) 
                    ||
                    (sbssScore <= Integer.valueOf(ConstantValues.SBSS_MIN_TIER_3) && //149
                    sbssScore > 0 )
                    ||
                    netWorth <= 0){
                objApplicationToUpdateList[0].genesis__Credit_Rating__c = creditRatingMap.get(ConstantValues.CREDIT_RATE_4);
                objApplicationToUpdateList[0].Additional_Information_Needed__c = true;
                if(objApplicationToUpdateList[0].Dealer_Name__c != null &&
                    objApplicationToUpdateList[0].Dealer_Name__r.genesis__Business_Information__c != null &&
                    objApplicationToUpdateList[0].Dealer_Name__r.genesis__Business_Information__r.Customised_Loan_Limit__c > 0 && 
                    objApplicationToUpdateList[0].Dealer_Name__r.genesis__Business_Information__r.Customised_Loan_Limit__c != null){
                        //Dealer can customise
                        objApplicationToUpdateList[0].Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_4);
                }
                else{
                    objApplicationToUpdateList[0].Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_1);
                }
                
            }
            else{
                objApplicationToUpdateList[0].genesis__Credit_Rating__c = creditRatingMap.get(ConstantValues.CREDIT_RATE_3);
                objApplicationToUpdateList[0].Guarantee__c = Integer.valueOf(ConstantValues.GUARANTEE_FOR_TIER_3);
                objApplicationToUpdateList[0].Additional_Information_Needed__c = true;
            }
            if(objApplicationToUpdateList[0].genesis__Status__c != ConstantValues.ACTIVE && objApplicationToUpdateList[0].genesis__Status__c != ConstantValues.CLOSED && objApplicationToUpdateList[0].genesis__Status__c != ConstantValues.PENDING_APPROVAL_APPLICATION_STATUS){
                objApplicationToUpdateList[0].genesis__Status__c = ConstantValues.SCORECARD_GENERATED;
            }
            //Evergreen Checks------------------------------------------------------------------------------------------
            if(objApplicationToUpdateList[0].Is_Evergreen__c == true){
                objApplicationToUpdateList = markEvergreenBusinessStatus(objApplicationToUpdateList,creditRatingMap);
            }
            //Evergreen Checks------------------------------------------------------------------------------------------
            Database.upsert(objApplicationToUpdateList[0], false);
            
            
        }
        catch (CustomException objCustomException) {
            Database.rollback(dbSavePoint);
            PortalHelper.saveExceptionLog(objCustomException, ConstantValues.CREDIT_RATING_EXCEPTION);
        }
        catch (Exception objException) {
            Database.rollback(dbSavePoint);
            PortalHelper.saveExceptionLog(objException, ConstantValues.CREDIT_RATING_EXCEPTION);
        }
        
    }

}