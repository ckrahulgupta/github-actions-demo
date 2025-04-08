/**
 * @description       : 
 * @author            : Tuhin Bhunia
 * @group             : 
 * @last modified on  : 04-08-2025
 * @last modified by  : Rahul Gorai
**/
public inherited sharing class PortalReportsHandler {
    
    private static final Map<String, Object> MONTH_MAP = new Map<String,Object>{
        PortalConstants.JANUARY => PortalConstants.ONE_VALUE,
        PortalConstants.FEBRUARY => PortalConstants.TWO_VALUE,
        PortalConstants.MARCH => PortalConstants.THREE_VALUE,
        PortalConstants.APRIL => PortalConstants.FOUR_VALUE,
        PortalConstants.MAY => PortalConstants.FIVE_VALUE,
        PortalConstants.JUNE => PortalConstants.SIX_VALUE,
        PortalConstants.JULY => PortalConstants.SEVEN_VALUE,
        PortalConstants.AUGUST => PortalConstants.EIGHT_VALUE,
        PortalConstants.SEPTEMBER => PortalConstants.NINE_VALUE,
        PortalConstants.OCTOBER => PortalConstants.TEN_VALUE,
        PortalConstants.NOVEMBER => PortalConstants.ELEVEN_VALUE,
        PortalConstants.DECEMBER => PortalConstants.TWELVE_VALUE
    };

    /**
    * @description 
    * @author Rahul Gupta | 03-19-2024 
    * @param inputResultList 
    * @return List<clcommon.PortalCustomRemoteActionRecord> 
    **/
    public static List<clcommon.PortalCustomRemoteActionRecord> getResponseDataFromList(List<Map<String, Object>> inputResultList){
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        for (Map<String, Object> result : inputResultList) {
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(result));
        }
        return responseData;
    }


    /**
    * @description 
    * @author Rahul Gupta | 03-19-2024 
    * @param inputResultList 
    * @return List<clcommon.PortalCustomRemoteActionRecord> 
    **/
    public static List<clcommon.PortalCustomRemoteActionRecord> getResponseDataFromList(List<genesis__Application_Fee_Payment__c> inputResultList){
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        for (genesis__Application_Fee_Payment__c result : inputResultList) {
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(result));
        }
        return responseData;
    }
    

    /**
    * @description 
    * @author Rahul Gupta | 03-19-2024 
    * @param inputResultList 
    * @return List<clcommon.PortalCustomRemoteActionRecord> 
    **/
    public static List<clcommon.PortalCustomRemoteActionRecord> getResponseDataFromList(List<genesis__Applications__c> inputResultList){
        List<clcommon.PortalCustomRemoteActionRecord> responseData = new List<clcommon.PortalCustomRemoteActionRecord>();
        for (genesis__Applications__c result : inputResultList) {
            responseData.add(new clcommon.PortalCustomRemoteActionRecord(result));
        }
        return responseData;
    }

    /**
    * @description - method to get the active loan report - gets called from export api only
    * @author Sk Minsar | 11-13-2023 
    * @param reportFilter 
    * @return List<genesis__Applications__c> 
    **/
    public static List<genesis__Applications__c> getActiveLoanReport(String reportFilter) {
        return [SELECT Id,
                        Certified_Lender__r.Name, 
                        Sales_Agent__r.Name, 
                        genesis__Credit_Rating__r.Name, 
                        Note_Date__c,
                        genesis__Loan_Amount__c,
                        genesis__Maturity_Date__c,
                        genesis__Status__c,
                        genesis__Account__r.Name,
                        Current_Principal_Balance__c,
                        genesis__Loan_Number__c,
                        genesis__Interest_Rate__c,
                        Total_Interest__c,
                        Total_Interest_Per_Diem__c,
                        Total_Fees__c,
                        Crop_Year__c,
                        Internal_Reference_Code__c,
                        Unique_Identifier__c,
                        Guarantee__c,
                        Available__c,
                        Reserved_Amount__c,
                        Past_Due_Amount__c,
                        CreatedDate
                        FROM genesis__Applications__c
                        WHERE Dealer_Name__c = :PortalReportsHelper.getDealerAccountId()
                        AND Crop_Year__c = :reportFilter
                        AND genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS];
    }

    /**
    * @description - Method to get the eom active loan report
    * @author Sk Minsar | 11-13-2023 
    * @param reportFilter 
    * @return List<Map<String, Object>> 
    **/
    public static List<Map<String, Object>> getEndOfMonthActiveLoanReport(String reportFilter) {
        Integer month = System.today().month();
        Integer year = System.today().year();
        List<genesis__Application_Fee_Payment__c> appFeePaymentList;
        Set<Id> applicationIds = new Set<Id>();
        List<Map<String, Object>> childLoanList = new List<Map<String, Object>>();

        if (!String.isBlank(reportFilter)) {
            month = (Integer) MONTH_MAP.get(reportFilter.split(' ')[PortalConstants.ZERO_VALUE]);
            year = Integer.valueOf(reportFilter.split(' ')[PortalConstants.ONE_VALUE]);
            appFeePaymentList = [SELECT Id,
                                            genesis__Application__r.Certified_Lender__r.Name, 
                                            genesis__Application__r.Sales_Agent__r.Name, 
                                            genesis__Application__r.genesis__Credit_Rating__r.Name, 
                                            genesis__Application__r.Note_Date__c,
                                            Pricing_Detail__r.Loan_Number__c,
                                            genesis__Application__r.genesis__Loan_Number__c,
                                            genesis__Application__r.genesis__Loan_Amount__c,
                                            genesis__Application__r.genesis__Maturity_Date__c,
                                            genesis__Application__r.genesis__Status__c,
                                            genesis__Application__r.genesis__Account__r.Name,
                                            genesis__Application__r.Current_Principal_Balance__c,
                                            genesis__Application__r.Total_Interest__c,
                                            genesis__Application__r.Total_Interest_Per_Diem__c,
                                            genesis__Application__r.Total_Fees__c,
                                            genesis__Application__c,
                                            genesis__Application__r.Pricing_Count__c,
                                            Pricing_Detail__r.genesis__Application__c,
                                            Pricing_Detail__r.genesis__Interest_Rate__c,
                                            Pricing_Detail__r.Principal_Advanced__c,
                                            Interest_Earned__c,
                                            Principal_Balance__c,
                                            Per_Diem__c,
                                            Fees__c,
                                            Interest_Rate__c,
                                            Pricing_Detail__r.Interest_Per_Diem__c,
                                            Pricing_Detail__r.Fees__c,
                                            Pricing_Detail__c,
                                            Past_Due_Balance__c,
                                            Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c,
                                            genesis__Application__r.Crop_Year__c,
                                            genesis__Application__r.Internal_Reference_Code__c,
                                            genesis__Application__r.Unique_Identifier__c,
                                            genesis__Application__r.Guarantee__c,
                                            genesis__Application__r.Available__c,
                                            genesis__Application__r.Reserved_Amount__c,
                                            genesis__Application__r.Past_Due_Amount__c,
                                            genesis__Application__r.CreatedDate
                                            FROM genesis__Application_Fee_Payment__c
                                            WHERE genesis__Application__r.Dealer_Name__c = :PortalReportsHelper.getDealerAccountId()
                                            AND Month__c = :month
                                            AND Year__c = :year
                                            AND Record_Type__c = :PortalConstants.ACTIVE_LOAN_DAILY
                                            AND genesis__Application__r.genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS];

            for (genesis__Application_Fee_Payment__c objApplicationFeePayment : appFeePaymentList) {
                applicationIds.add(objApplicationFeePayment.Pricing_Detail__r.genesis__Application__c);
            }
             childLoanList = PortalReportsHelper.getChildLoanList(appFeePaymentList);

        } 
        return childLoanList;
    }

   
    /**
    * @description - Method to get the rate change notification report
    * @author Sk Minsar | 11-13-2023 
    * @return List<Map<String, Object>> 
    **/
    public static List<Map<String, Object>> getRateChangeNotificationReport() {
        
        List<String> loanNumberList = new List<String>();
        List<Map<String, Object>> resultList = new List<Map<String, Object>>();
        Map<Object, Map<String, List<genesis__Application_Pricing_Detail__c>>> objApplicationPricingMap = 
        new Map<Object, Map<String, List<genesis__Application_Pricing_Detail__c>>>();
        Map<Id, clcommon__party__c> appIdToPartyMap = new Map<Id, clcommon__party__c>();

        List<AggregateResult> results = [SELECT Loan_Number__c 
                                                FROM genesis__Application_Pricing_Detail__c 
                                                WHERE genesis__Application__r.Dealer_Name__r.Id = :PortalReportsHelper.getDealerAccountId()
                                                GROUP BY Loan_Number__c 
                                                HAVING COUNT(Id) > 1];

        for (AggregateResult result : results) {
            // if (result.get('Loan_Number__c') != null) {
            //     loanNumberList.add(String.valueOf(result.get('Loan_Number__c')));
            // }
            loanNumberList.add(PortalReportsHelper.getString(result.get('Loan_Number__c')));
        }

        List<genesis__Application_Pricing_Detail__c> objApplicationPricingList = [SELECT genesis__Rate_Card_Setup_Detail__r.Start_Date__c, 
                                                                                        genesis__Rate_Card_Setup_Detail__r.End_Date__c, 
                                                                                        genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c,
                                                                                        genesis__Application__r.genesis__Account__r.Name,
                                                                                        genesis__Application__r.genesis__Loan_Number__c,
                                                                                        genesis__Application__r.genesis__Maturity_Date__c,
                                                                                        genesis__Application__r.Certified_Lender__r.Name,
                                                                                        genesis__Application__r.Internal_Reference_Code__c,
                                                                                        genesis__Application__r.Unique_Identifier__c,
                                                                                        genesis__Application__r.Sales_Agent__r.Name,
                                                                                        genesis__Application__r.genesis__Account__r.clcommon__Email__c,
                                                                                        Loan_Number__c,
                                                                                        genesis__Enabled_Flag__c,
                                                                                        genesis__Application__c 
                                                                                        FROM genesis__Application_Pricing_Detail__c 
                                                                                        WHERE genesis__Application__r.Dealer_Name__r.Id = :PortalReportsHelper.getDealerAccountId()
                                                                                        AND Loan_Number__c IN :loanNumberList];

        List<clcommon__Party__c> objPartyList = [SELECT Id, Mobile_Number__c,
                                                        Street__c,
                                                        City__c,
                                                        State__c,
                                                        Postal_Code__c,
                                                        genesis__Application__c
                                                        FROM clcommon__party__c
                                                        WHERE clcommon__type__r.name =: PortalConstants.BORROWER_PARTY_NAME
                                                        AND genesis__Application__r.Dealer_Name__c =: PortalReportsHelper.getDealerAccountId()
                                                        AND genesis__Application__r.genesis__Status__c =: PortalConstants.ACTIVE_APPLICATION_STATUS];

        for(clcommon__party__c eachParty : objPartyList){
            appIdToPartyMap.put(eachParty.genesis__Application__c, eachParty);
        }
                                                        
        for (genesis__Application_Pricing_Detail__c objApplicationPricing : objApplicationPricingList) {
            List<genesis__Application_Pricing_Detail__c> subTrancheList;
            Map<String, List<genesis__Application_Pricing_Detail__c>> innerMap;
            
            String isEnabled = String.valueOf(objApplicationPricing.genesis__Enabled_Flag__c);
            
            if (objApplicationPricingMap.containsKey(objApplicationPricing.Loan_Number__c)) {
                // if the loan number key is present in the map already
                innerMap = objApplicationPricingMap.get(objApplicationPricing.Loan_Number__c);
                
                if (!innerMap.containsKey(isEnabled)) {
                    // add the String key
                    subTrancheList = new List<genesis__Application_Pricing_Detail__c>();
                    subTrancheList.add(objApplicationPricing);
                    innerMap.put(isEnabled, subTrancheList);
                } else {
                    subTrancheList = innerMap.get(isEnabled);
                    subTrancheList.add(objApplicationPricing);
                    innerMap.put(isEnabled, subTrancheList);
                }
            } else {
                innerMap = new Map<String, List<genesis__Application_Pricing_Detail__c>>();
                subTrancheList = new List<genesis__Application_Pricing_Detail__c>();
                subTrancheList.add(objApplicationPricing);
                innerMap.put(isEnabled, subTrancheList);
            }
            
            objApplicationPricingMap.put(objApplicationPricing.Loan_Number__c, innerMap);
              
        }
        resultList = PortalReportsHelper.getResultList(objApplicationPricingMap, appIdToPartyMap);
        return resultList;
    }

    /**
    * @description - Method to get the end of year report
    * @author Sk Minsar | 11-13-2023 
    * @param reportFilter 
    * @return List<Map<String, Object>> 
    **/
    public static List<Map<String, Object>> getEndOfYearReport(String reportFilter) {

        List<Map<String, Object>> applicationDataList = new List<Map<String, Object>>();
        Map<String, Map<String, Object>> resultMap = new Map<String, Map<String, Object>>();
        Set<Id> applicationIds = new Set<Id>();
        Integer year = System.today().year();
        Map<Id, clcommon__party__c> appIdToPartyMap = new Map<Id, clcommon__party__c>();

        if (!String.isBlank(reportFilter)) {
            year = Integer.valueOf(reportFilter);
            List<AggregateResult> resultList = [SELECT Pricing_Detail__r.genesis__Application__c,
                                                        SUM(Interest_Paid__c) Total_Interest
                                                        FROM genesis__Application_Fee_Payment__c
                                                        WHERE genesis__Application__r.Dealer_Name__c = :PortalReportsHelper.getDealerAccountId()
                                                        AND Month__c = 0
                                                        AND Year__c = :year
                                                        AND Record_Type__c = :PortalConstants.ACTIVE_LOAN_DAILY
                                                        GROUP BY Pricing_Detail__r.genesis__Application__c
                                                        HAVING SUM(Interest_Paid__c) > 0];

            for (AggregateResult aggegateResult : resultList) {
                Map<String, Object> applicationData = new Map<String, Object>();
                applicationData.put(PortalConstants.KEY_INTEREST, ((Decimal) aggegateResult.get('Total_Interest')).setScale(2));
                applicationIds.add((Id) aggegateResult.get('genesis__Application__c'));
                resultMap.put((String) aggegateResult.get('genesis__Application__c'), applicationData);
            }

            List<genesis__Applications__c> objApplicationList = [SELECT Id,
                                                                        genesis__Loan_Number__c,
                                                                        genesis__Loan_Amount__c,
                                                                        genesis__Maturity_Date__c,
                                                                        Certified_Lender__r.Name,
                                                                        Sales_Agent__r.Name,
                                                                        genesis__Status__c,
                                                                        genesis__Account__r.Name,
                                                                        Current_Principal_Balance__c,
                                                                        Crop_Year__c,
                                                                        Internal_Reference_Code__c,
                                                                        Unique_Identifier__c,
                                                                        Guarantee__c,
                                                                        Available__c,
                                                                        Reserved_Amount__c,
                                                                        CreatedDate
                                                                    FROM genesis__Applications__c
                                                                    WHERE Id IN :applicationIds];
            List<clcommon__Party__c> objPartyList = [SELECT Id, Mobile_Number__c,
                                                            Street__c,
                                                            City__c,
                                                            State__c,
                                                            Postal_Code__c,
                                                            genesis__Application__c
                                                    FROM clcommon__party__c
                                                    WHERE genesis__Application__c IN :applicationIds
                                                    AND clcommon__type__r.name =: PortalConstants.BORROWER_PARTY_NAME];
            
            for(clcommon__party__c eachParty : objPartyList){
                appIdToPartyMap.put(eachParty.genesis__Application__c, eachParty);
            }

            clcommon__party__c objParty;
            for (genesis__Applications__c objApplication : objApplicationList) {
                if(appIdToPartyMap.containsKey(objApplication.Id)){
                    objParty = appIdToPartyMap.get(objApplication.Id);
                }
                if (resultMap.get(objApplication.Id) != null && objParty != null) {
                    Map<String, Object> applicationData = resultMap.get(objApplication.Id);
                    applicationData.put(PortalConstants.KEY_LOAN_NUMBER, objApplication.genesis__Loan_Number__c);
                    applicationData.put(PortalConstants.KEY_LOAN_AMOUNT, objApplication.genesis__Loan_Amount__c);
                    applicationData.put(PortalConstants.KEY_MATURITY_DATE, objApplication.genesis__Maturity_Date__c);
                    applicationData.put(PortalConstants.KEY_CERTIFIED_LENDER, objApplication.Certified_Lender__r.Name);
                    applicationData.put(PortalConstants.KEY_SALES_AGENT, objApplication.Sales_Agent__r.Name);
                    applicationData.put(PortalConstants.KEY_GROWER_NAME, objApplication.genesis__Account__r.Name);
                    applicationData.put(PortalConstants.KEY_PRINCIPAL_BALANCE, objApplication.Current_Principal_Balance__c);
                    applicationData.put(PortalConstants.KEY_CROP_YEAR, objApplication.Crop_Year__c);
                    applicationData.put(PortalConstants.KEY_IRC_SHORT_FORM, objApplication.Internal_Reference_Code__c);
                    applicationData.put(PortalConstants.KEY_UNIQUE_IDENTIFIER, objApplication.Unique_Identifier__c);
                    applicationData.put(PortalConstants.KEY_GUARANTY, objApplication.Guarantee__c);
                    applicationData.put(PortalConstants.KEY_CITY, objParty.City__c);
                    applicationData.put(PortalConstants.KEY_STATE, objParty.State__c);
                    applicationData.put(PortalConstants.KEY_STREET, objParty.Street__c);
                    applicationData.put(PortalConstants.KEY_ZIP, objParty.Postal_Code__c);
                    applicationData.put(PortalConstants.KEY_CREATED_DATE, objApplication.CreatedDate);

                    applicationDataList.add(applicationData);
                }
            }
        }
        return applicationDataList;
    }

    /**
    * @description - Method to get the online users report
    * @author Sk Minsar | 11-13-2023 
    * @return List<Map<String, Object>> 
    **/
    public static List<Map<String, Object>> getOnlineUsersReport() {

        List<Map<String, Object>> resultList = new List<Map<String,Object>>();
        Map<String, Object> responseMap;

        List<AggregateResult> onlineUsers = [SELECT clcommon__Contact__r.Account.Name, 
                                                    COUNT(genesis__Application__r.Loan_Id__c) loanCount, 
                                                    Mobile_Number__c, 
                                                    clcommon__Contact__r.Email,
                                                    genesis__Application__r.Unique_Identifier__c
                                                    FROM clcommon__Party__c 
                                                    WHERE clcommon__Type__r.Name = :PortalConstants.BORROWER_PARTY_NAME
                                                    AND genesis__Application__r.Dealer_Name__c = :PortalReportsHelper.getDealerAccountId()
                                                    GROUP BY clcommon__Contact__c, 
                                                    clcommon__Contact__r.Email, 
                                                    clcommon__Contact__r.Account.Name,
                                                    Mobile_Number__c,
                                                    genesis__Application__r.Unique_Identifier__c
                                                    LIMIT 1000];
        
        for(AggregateResult onlineUser: onlineUsers) {
            responseMap = new Map<String, Object>();
            responseMap.put(PortalConstants.KEY_NAME, onlineUser.get('Name'));
            responseMap.put(PortalConstants.KEY_EMAIL, onlineUser.get('Email'));
            responseMap.put(PortalConstants.KEY_PHONE, onlineUser.get('Mobile_Number__c'));
            responseMap.put(PortalConstants.KEY_UNIQUE_IDENTIFIER, onlineUser.get('Unique_Identifier__c'));
            
            // if ((Integer)(onlineUser.get('loanCount')) > PortalConstants.ZERO_VALUE) {
            //     responseMap.put(PortalConstants.KEY_HAS_ACTIVE_LOAN, 'Yes');
            // } else {
            //     responseMap.put(PortalConstants.KEY_HAS_ACTIVE_LOAN, 'No');
            // }
            responseMap.put(PortalConstants.KEY_HAS_ACTIVE_LOAN, PortalReportsHelper.hasActiveLoan((Integer)(onlineUser.get('loanCount'))));
            resultList.add(responseMap);
        }
        return resultList;
    }

    /**
    * @description - Method to get the current crop year report
    * @author Sk Minsar | 11-13-2023 
    * @return List<genesis__Applications__c> 
    **/
    public static List<genesis__Applications__c> getCurrentCropYearReport() {

        Integer year = System.today().year();
        Integer month = System.today().month();

        if (month >= PortalConstants.SIX_VALUE) {
            year += PortalConstants.ONE_VALUE;
        }

        return [SELECT Id,
                        genesis__Loan_Number__c,
                        genesis__Loan_Amount__c,
                        Loan_Id__c,
                        genesis__Maturity_Date__c,
                        genesis__Status__c,
                        genesis__Account__r.Name,
                        genesis__Credit_Rating__r.Name,
                        Crop_Year__c,
                        Internal_Reference_Code__c,
                        Unique_Identifier__c,
                        Guarantee__c,
                        CreatedDate,
                        Certified_Lender__r.Name,
                        Sales_Agent__r.Name,
                        Dealer_Name__r.CIF_Number__c
                        FROM genesis__Applications__c
                        WHERE Dealer_Name__c = :PortalReportsHelper.getDealerAccountId()
                        AND Crop_Year__c = :String.valueOf(year)];
    }

    /**
    * @description - Method to get the prior crop year report
    * @author Sk Minsar | 11-13-2023 
    * @return List<genesis__Applications__c> 
    **/
    public static List<genesis__Applications__c> getPriorCropYearReport() {

        Integer month = System.today().month();
        Integer year = System.today().year();

        if (month < PortalConstants.SIX_VALUE) {
            year -= PortalConstants.ONE_VALUE;
        }

        return [SELECT Id,
                        genesis__Loan_Number__c,
                        genesis__Loan_Amount__c,
                        Loan_Id__c,
                        genesis__Maturity_Date__c,
                        genesis__Status__c,
                        genesis__Account__r.Name,
                        genesis__Credit_Rating__r.Name,
                        Crop_Year__c,
                        Internal_Reference_Code__c,
                        Unique_Identifier__c,
                        Guarantee__c,
                        CreatedDate,
                        Certified_Lender__r.Name,
                        Sales_Agent__r.Name,
                        Dealer_Name__r.CIF_Number__c
                        FROM genesis__Applications__c
                        WHERE Dealer_Name__c = :PortalReportsHelper.getDealerAccountId()
                        AND Crop_Year__c = :String.valueOf(year)];
    }

    /**
    * @description - Method to get the subsidy accrual report
    * @author Sk Minsar | 11-13-2023 
    * @param reportFilter 
    * @return List<genesis__Application_Fee_Payment__c> 
    **/
    public static List<genesis__Application_Fee_Payment__c> getSubsidyAccrualReport(String reportFilter) {

        Integer month = System.today().month();
        Integer year = System.today().year();

        if (!String.isBlank(reportFilter)) {
            month = (Integer) MONTH_MAP.get(reportFilter.split(' ')[PortalConstants.ZERO_VALUE]);
            year = Integer.valueOf(reportFilter.split(' ')[PortalConstants.ONE_VALUE]);

        } 

        List<genesis__Application_Fee_Payment__c> resultList = [
                    SELECT Id,
                            Pricing_Detail__r.Loan_Number__c,
                            genesis__Application__r.genesis__Loan_Amount__c,
                            genesis__Application__r.genesis__Maturity_Date__c,
                            genesis__Application__r.Certified_Lender__r.Name,
                            genesis__Application__r.Sales_Agent__r.Name,
                            genesis__Application__r.genesis__Status__c,
                            genesis__Application__r.genesis__Account__r.Name,
                            genesis__Application__r.Dealer_Name__r.BillingCity,
                            genesis__Application__r.Dealer_Name__r.BillingState,
                            Pricing_Detail__r.genesis__Interest_Rate__c,
                            Pricing_Detail__r.Principal_Advanced__c,
                            Pricing_Detail__r.Dealer_Interest_Accrued__c,
                            Pricing_Detail__r.Dealer_Interest_Per_Diem__c,
                            Pricing_Detail__r.Interest_Per_Diem__c,
                            Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c,
                            Dealer_Monthly_Interest__c,
                            Interest_Earned__c,
                            Principal_Balance__c,
                            genesis__Application__r.Crop_Year__c,
                            genesis__Application__r.Internal_Reference_Code__c,
                            genesis__Application__r.Unique_Identifier__c,
                            genesis__Application__r.Guarantee__c,
                            genesis__Application__r.Available__c,
                            genesis__Application__r.Reserved_Amount__c,
                            Pricing_Detail__r.CreatedDate
                    FROM genesis__Application_Fee_Payment__c
                    WHERE genesis__Application__r.Dealer_Name__c = :PortalReportsHelper.getDealerAccountId()
                    AND Record_Type__c = :PortalConstants.PARTICIPANT_DAILY
                    AND Month__c = :month
                    AND Year__c = :year
                    AND ((genesis__Application__r.genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                        AND Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer_Subsidy__c > 0)

                        OR (Dealer_Monthly_Interest__c < 0)) 
                ];

        for (Integer iterator = PortalConstants.ZERO_VALUE; iterator < resultList.size(); ++iterator) {
            if (resultList[iterator].Interest_Earned__c != null && resultList[iterator].Interest_Earned__c < PortalConstants.ZERO_VALUE) {
                resultList[iterator].Interest_Earned__c = -PortalConstants.ONE_VALUE * resultList[iterator].Interest_Earned__c;
            }

            if (resultList[iterator].Dealer_Monthly_Interest__c != null && resultList[iterator].Dealer_Monthly_Interest__c < PortalConstants.ZERO_VALUE) {
                resultList[iterator].Dealer_Monthly_Interest__c = -PortalConstants.ONE_VALUE * resultList[iterator].Dealer_Monthly_Interest__c;
            }
        }

        return resultList;
         
    }

    /**
    * @description - Method to get the premium accrual report
    * @author Sk Minsar | 11-13-2023 
    * @param reportFilter 
    * @return List<genesis__Application_Fee_Payment__c> 
    **/
    public static List<genesis__Application_Fee_Payment__c> getPremiumAccrualReport(String reportFilter) {

        Integer month = System.today().month();
        Integer year = System.today().year();

        if (!String.isBlank(reportFilter)) {
            month = (Integer) MONTH_MAP.get(reportFilter.split(' ')[PortalConstants.ZERO_VALUE]);
            year = Integer.valueOf(reportFilter.split(' ')[PortalConstants.ONE_VALUE]);
        } 

        List<genesis__Application_Fee_Payment__c> resultList = [
                    SELECT Id,
                            Pricing_Detail__r.Loan_Number__c,
                            genesis__Application__r.genesis__Loan_Amount__c,
                            genesis__Application__r.genesis__Maturity_Date__c,
                            genesis__Application__r.Certified_Lender__r.Name,
                            genesis__Application__r.Sales_Agent__r.Name,
                            genesis__Application__r.genesis__Status__c,
                            genesis__Application__r.genesis__Account__r.Name,
                            genesis__Application__r.Dealer_Name__r.BillingCity,
                            genesis__Application__r.Dealer_Name__r.BillingState,
                            Pricing_Detail__r.genesis__Interest_Rate__c,
                            Pricing_Detail__r.Principal_Advanced__c,
                            Pricing_Detail__r.Dealer_Interest_Accrued__c,
                            Pricing_Detail__r.Dealer_Interest_Per_Diem__c,
                            Pricing_Detail__r.Interest_Per_Diem__c,
                            Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c,
                            Dealer_Monthly_Interest__c,
                            Interest_Earned__c,
                            Principal_Balance__c,
                            genesis__Application__r.Crop_Year__c,
                            genesis__Application__r.Internal_Reference_Code__c,
                            genesis__Application__r.Unique_Identifier__c,
                            genesis__Application__r.Guarantee__c,
                            genesis__Application__r.Available__c,
                            genesis__Application__r.Reserved_Amount__c,
                            Pricing_Detail__r.CreatedDate
                    FROM genesis__Application_Fee_Payment__c
                    WHERE genesis__Application__r.Dealer_Name__c = :PortalReportsHelper.getDealerAccountId()
                    AND Record_Type__c = :PortalConstants.PARTICIPANT_DAILY
                    AND Month__c = :month
                    AND Year__c = :year
                    AND ((genesis__Application__r.genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS
                        AND Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer__c > 0)

                        OR (Dealer_Monthly_Interest__c > 0))
                ];

        for (Integer iterator = PortalConstants.ZERO_VALUE; iterator < resultList.size(); ++iterator) {
            if (resultList[iterator].Interest_Earned__c != null && resultList[iterator].Interest_Earned__c < PortalConstants.ZERO_VALUE) {
                resultList[iterator].Interest_Earned__c = -PortalConstants.ONE_VALUE * resultList[iterator].Interest_Earned__c;
            }

            if (resultList[iterator].Dealer_Monthly_Interest__c != null && resultList[iterator].Dealer_Monthly_Interest__c < PortalConstants.ZERO_VALUE) {
                resultList[iterator].Dealer_Monthly_Interest__c = -PortalConstants.ONE_VALUE * resultList[iterator].Dealer_Monthly_Interest__c;
            }
        }

        return resultList;

        
    }

    /**
    * @description - Method to get the loan account report
    * @author Sk Minsar | 11-13-2023 
    * @param reportFilter 
    * @return List<Map<String, Object>> 
    **/
    public static List<Map<String, Object>> getLoanAccountReport(String reportFilter) {
        List<genesis__Application_Pricing_Detail__c> objApplicationPricingList;
        List<genesis__Applications__c> objApplicationList;

        List<Map<String, Object>> loanAccountList = new List<Map<String, Object>>();
        List<Map<String, Object>> commitmentLoanList = new List<Map<String, Object>>();

        objApplicationPricingList = [SELECT Id,
                                            genesis__Application__r.Certified_Lender__r.Name, 
                                            genesis__Application__r.Sales_Agent__r.Name, 
                                            genesis__Application__r.genesis__Credit_Rating__r.Name, 
                                            genesis__Application__r.Note_Date__c,
                                            Loan_Number__c,
                                            genesis__Application__r.genesis__Loan_Amount__c,
                                            genesis__Application__r.genesis__Maturity_Date__c,
                                            genesis__Application__r.genesis__Status__c,
                                            genesis__Application__r.genesis__Account__r.Name,
                                            genesis__Interest_Rate__c,
                                            Principal_Advanced__c,
                                            Accrued_Interest__c,
                                            Interest_Per_Diem__c,
                                            Fees__c,
                                            genesis__Rate_Card_Setup_Detail__r.Description__c,
                                            genesis__Application__r.Crop_Year__c,
                                            genesis__Application__r.Internal_Reference_Code__c,
                                            genesis__Application__r.Unique_Identifier__c,
                                            genesis__Application__r.Guarantee__c,
                                            genesis__Application__r.Available__c,
                                            genesis__Application__r.Reserved_Amount__c,
                                            genesis__Application__r.CreatedDate,
                                            genesis__Application__r.Pricing_Count__c
                                            FROM genesis__Application_Pricing_Detail__c
                                            WHERE genesis__Application__r.Dealer_Name__c = :PortalReportsHelper.getDealerAccountId()
                                            AND genesis__Enabled_Flag__c = true
                                            AND genesis__Application__r.Crop_Year__c = :reportFilter
                                            AND genesis__Application__r.genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS];

        objApplicationList = [SELECT Id,
                                    Certified_Lender__r.Name, 
                                    Sales_Agent__r.Name, 
                                    genesis__Credit_Rating__r.Name, 
                                    Note_Date__c,
                                    genesis__Loan_Amount__c,
                                    genesis__Maturity_Date__c,
                                    genesis__Status__c,
                                    genesis__Account__r.Name,
                                    Current_Principal_Balance__c,
                                    Total_Interest__c,
                                    Total_Interest_Per_Diem__c,
                                    Total_Fees__c,
                                    genesis__Loan_Number__c,
                                    Crop_Year__c,
                                    Internal_Reference_Code__c,
                                    Unique_Identifier__c,
                                    Guarantee__c,
                                    Available__c,
                                    Reserved_Amount__c,
                                    CreatedDate,
                                    Pricing_Count__c
                                    FROM genesis__Applications__c
                                    WHERE Dealer_Name__c = :PortalReportsHelper.getDealerAccountId()
                                    AND Crop_Year__c = :reportFilter
                                    AND genesis__Status__c = :PortalConstants.ACTIVE_APPLICATION_STATUS];

        loanAccountList = PortalReportsHelper.getLoanAccountList(objApplicationPricingList);
        commitmentLoanList = PortalReportsHelper.getCommitmentLoanList(objApplicationList);
        loanAccountList.addAll(commitmentLoanList);
        return loanAccountList;
    }

    /**
    * @description - Method to get the ach batch history report
    * @author Sk Minsar | 11-13-2023 
    * @param batchId 
    * @return List<genesis__funding_transaction__c> 
    **/
    public static List<genesis__funding_transaction__c> getACHBatchHistoryReport(String batchId) {
        return [SELECT Id, 
                        Pricing_Detail__r.genesis__Application__r.genesis__Account__r.Name, 
                        Loan_Number__c, 
                        Draft_Number__c, 
                        genesis__Amount__c, 
                        Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c, 
                        genesis__Reference__c, 
                        Pricing_Detail__r.genesis__Application__r.Crop_Year__c,
                        Pricing_Detail__r.genesis__Application__r.Internal_Reference_Code__c
                        FROM genesis__funding_transaction__c
                        WHERE Batch__c = :batchId
                        AND Pricing_Detail__r.genesis__Application__r.Dealer_Name__r.Id = :PortalReportsHelper.getDealerAccountId()
                        AND genesis__Payment_Mode__r.Name = :ConstantValues.ACH];
    }

    /**
    * @description - Method to get the draft history report
    * @author Sk Minsar | 11-13-2023 
    * @return List<genesis__funding_transaction__c> 
    **/
    public static List<genesis__funding_transaction__c> getDraftHistoryReport() {
        return [SELECT Id, 
                        Pricing_Detail__r.genesis__Application__r.genesis__Account__r.Name, 
                        Loan_Number__c, 
                        Draft_Number__c, 
                        genesis__Amount__c, 
                        Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c, 
                        CreatedDate, 
                        Pricing_Detail__r.genesis__Application__r.Crop_Year__c
                        FROM genesis__funding_transaction__c
                        WHERE Pricing_Detail__r.genesis__Application__r.Dealer_Name__r.Id = :PortalReportsHelper.getDealerAccountId()
                        AND genesis__Payment_Mode__r.Name = :ConstantValues.DRAFT
                        AND (genesis__Cleared__c = true OR Posted_to_NLS__c = true)];
    }
}