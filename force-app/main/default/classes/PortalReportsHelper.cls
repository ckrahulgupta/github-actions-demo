/**
 * @description       : This class is a helper class for portal report classes 
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 04-08-2025
 * @last modified by  : Rahul Gorai
**/

public inherited sharing class PortalReportsHelper {

    private static final Integer DAYS_AHEAD_RATE_CHANGE = Integer.ValueOf(System.Label.DaysAheadRateChange);

    private static final String PDF_HTML_START = '<html style="-webkit-print-color-adjust: exact;"><head></head><body> <h1 align="center" style="font-size: 15pt;">';
    private static final String PDF_HEADING_END = '</h1>';
    private static final String PDF_HTML_TR_START = '<tr>';
    private static final String PDF_HTML_TR_END = '</tr>';
    private static final String PDF_HTML_TD_START = '<td>';
    private static final String PDF_HTML_TD_END = '</td>';
    private static final String PDF_HTML_TD_START_END = '<td></td>';
    private static final String PDF_HTML_END = '</table></body></html>';
    private static final String PDF_END = '</html>';
    private static final String PDF_LINE_BREAK = '<br>';
    private static final String PDF_TABLE_START = '<table border="1" cellpadding="3" style="font-size: 9pt;"><tbody>';
    private static final String PDF_TABLE_END = '</tbody></table>';
    private static final String PDF_TABLE_HEADING = '<tr align="center" bgcolor="#7b925f" style="font-weight: bold; ">';

    /**
    * @description - method to get the dealer account id
    * @author Sk Minsar | 11-13-2023 
    * @return String 
    **/
    public static String getDealerAccountId() {
        List<User> dealerAccountId = new List<User>();
            dealerAccountId = [SELECT Account.ParentId
                                    FROM User 
                                    WHERE Id = :UserInfo.getUserId()
                                    LIMIT 1];
        if (dealerAccountId.isEmpty()) {
            throw new CustomException(PortalConstants.USER_NOT_AUTHORISED);
        } else {
            return dealerAccountId[PortalConstants.ZERO_VALUE].Account.ParentId;
        }
    }

    /**
    * @description - Purpose of this method is to convert attribute into string and check the null values
    * @author Sk Minsar | 10-12-2023 
    * @param cellData 
    * @return String 
    **/
    public static String getString(Object cellData){
        return (cellData != null) ? String.valueOf(cellData): null;
    }

    /**
    * @description - Purpose of this method is to convert attribute into string and check the null values
    * @author Sk Minsar | 10-16-2023 
    * @param firstCheck 
    * @param cellData 
    * @return String 
    **/
    public static String getString(Object firstCheck, Object cellData){
        if(firstCheck!= null && 
                cellData !=null){
                        return String.valueOf(cellData);
                }
        return null;
    }

    /**
    * @description - Purpose of this method is to convert attribute into string and check the null values
    * @author Sk Minsar | 10-16-2023 
    * @param firstCheck 
    * @param secondCheck 
    * @param cellData 
    * @return String 
    **/
    public static String getString(Object firstCheck, Object secondCheck, Object cellData){
        if(firstCheck!= null && 
            secondCheck != null && 
                cellData !=null){
                        return String.valueOf(cellData);
                }
        return null;
    }

   
    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param inputdate 
    * @return String 
    **/
    public static String getformatedDate(Object inputdate){
        if(inputdate!=null){
            Datetime parsedDate = (Datetime)(inputdate);
            return String.valueOf(date.newInstance(parsedDate.yearGmt(), parsedDate.monthGmt(), parsedDate.dayGmt()));
        }
        return null;
    }

    /**
    * @description : This method is specifically used in PortalExportPendingACHReportAPI to get the Formatted date
    * @author Tuhin Bhunia | 01-30-2025 
    * @param inputdate 
    * @return String 
    **/
    public static String getFormattedDate(Object inputdate){
        if(inputdate!=null){
            Datetime parsedDate = (Datetime)(inputdate);
            return String.valueOf(date.newInstance(parsedDate.yearGmt(), parsedDate.monthGmt(), parsedDate.dayGmt()).format());
        }
        return null;
    }

    /**
    * @description - Purpose of this method is to format the dates
    * @author Sk Minsar | 10-16-2023 
    * @param firstCheck 
    * @param inputdate 
    * @return String 
    **/
    public static String getformatedDate(Object firstCheck, Object inputdate){
        if(firstCheck!=null &&
                inputdate!=null){
                    Datetime parsedDate = (Datetime)(inputdate);
                    return String.valueOf(date.newInstance(parsedDate.yearGmt(), parsedDate.monthGmt(), parsedDate.dayGmt()));
        }
        return null;
    }

    /**
    * @description - Purpose of this method is to format the dates
    * @author Sk Minsar | 10-16-2023 
    * @param firstCheck 
    * @param secondCheck 
    * @param inputdate 
    * @return String 
    **/
    public static String getformatedDate(Object firstCheck, Object secondCheck, Object inputdate){
        if(firstCheck!=null &&
            secondCheck!=null &&
                inputdate!=null){
                    Datetime parsedDate = (Datetime)(inputdate);
                    return String.valueOf(date.newInstance(parsedDate.yearGmt(), parsedDate.monthGmt(), parsedDate.dayGmt()));
        }
        return null;
    }

    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param cellData 
    * @return String 
    **/
    public static String createPDFTableRow(Object cellData) {
        String cellString = (cellData == null) ? 
                        PDF_HTML_TD_START_END : 
                        PDF_HTML_TD_START 
                            + String.valueOf(cellData) 
                            + PDF_HTML_TD_END;
        return cellString;
    }
    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param objList 
    **/
    public static void checkAndThrowExceptionIfListEmpty(List<Object> objList) {
        if (objList.isEmpty()) {
            throw new CustomException(PortalConstants.NO_DATA_TO_EXPORT);
        }
    }
    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param request 
    **/
    public static void reportAndExportTypeMissingThrowException(Map<String, Object> request){
        if (request.get(PortalConstants.KEY_REPORT_TYPE) == null || request.get(PortalConstants.KEY_EXPORT_TYPE) == null) {
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }
    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param request 
    **/
    public static void exportAndDataTypeMissingThrowException(Map<String, Object> request){
        if (String.isBlank((String) request.get(PortalConstants.KEY_EXPORT_TYPE)) ||
                String.isBlank((String) request.get(PortalConstants.KEY_DATA_TYPE))) {
                throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
            }
    }
    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param request 
    **/
    public static void reportTypeMissingThrowException(Map<String, Object> request){
        if (String.isBlank((String)request.get(PortalConstants.KEY_REPORT_TYPE))) {
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }
    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param request 
    **/
    public static void requiredParameterMissingThrowException(Map<String, Object> request){
        if (request.get(PortalConstants.KEY_BATCH_ID) == null) {
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }

    /**
    * @description - This method Roundup the input value upto 2 places 
    * @author Sk Minsar | 11-03-2023 
    * @param value 
    * @return Object 
    **/
    private static Decimal getRoundedValue(Decimal value){
        return (value!=null) ? value.setScale(2): PortalConstants.ZERO_VALUE;
    }
    

    /**
    * @description - method to get the next subtranche
    * @author Sk Minsar | 11-13-2023 
    * @param currentSubtranche 
    * @param inActiveSubtranches 
    * @return genesis__Application_Pricing_Detail__c 
    **/
    private static genesis__Application_Pricing_Detail__c getNextSubtranche(genesis__Application_Pricing_Detail__c currentSubtranche, 
                                                                            List<genesis__Application_Pricing_Detail__c> inActiveSubtranches) {
        
        genesis__Application_Pricing_Detail__c nextSubtranche;

        Integer minDaysBetween = 999999;
        Integer currentDaysBetween;
        Object currentRate = currentSubtranche.genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c;
        Object newRate;

        for (genesis__Application_Pricing_Detail__c inActiveSubtranche : inActiveSubtranches) {
            currentDaysBetween = currentSubtranche.genesis__Rate_Card_Setup_Detail__r.End_Date__c.daysBetween(inActiveSubtranche.genesis__Rate_Card_Setup_Detail__r.Start_Date__c);

            newRate = inActiveSubtranche.genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c;

            if (currentDaysBetween >= PortalConstants.ZERO_VALUE && currentDaysBetween <= DAYS_AHEAD_RATE_CHANGE && currentRate != newRate && currentDaysBetween < minDaysBetween) {
                minDaysBetween = currentDaysBetween;
                nextSubtranche = inActiveSubtranche;
            }
        }
        return nextSubtranche;
    }

    /**
    * @description - method for portalreportsAPI getOnlineUsersReport
    * @author Sk Minsar | 11-13-2023 
    * @param loanCount 
    * @return String 
    **/
    public Static String hasActiveLoan(Integer loanCount){
        if(loanCount>PortalConstants.ZERO_VALUE){
            return 'Yes';
        }
        return 'No';
    }
   
    /**
    * @description - method to generate a childLoanList
    * @author Sk Minsar | 11-13-2023 
    * @param objFeePaymentList 
    * @return List<Map<String, Object>> 
    **/
    public static List<Map<String, Object>> getChildLoanList(List<genesis__Application_Fee_Payment__c> objFeePaymentList){
        List<Map<String, Object>> childLoanList = new List<Map<String, Object>>();

         for (genesis__Application_Fee_Payment__c objApplicationFeePayment : objFeePaymentList) {
            Map<String, Object> objMap = new Map<String, Object>();
            objMap.put(PortalConstants.KEY_LOAN_ID, objApplicationFeePayment.Id);
            if (objApplicationFeePayment.Pricing_Detail__c != null) {
                // child loan
                objMap.put(PortalConstants.KEY_LOAN_NUMBER, objApplicationFeePayment.Pricing_Detail__r.Loan_Number__c);
                objMap.put(PortalConstants.KEY_INTEREST_RATE, objApplicationFeePayment.Interest_Rate__c);
                objMap.put(PortalConstants.KEY_PRINCIPAL, objApplicationFeePayment.Principal_Balance__c);

                objMap.put(PortalConstants.KEY_PER_DIEM, getRoundedValue(objApplicationFeePayment.Per_Diem__c));

                objMap.put(PortalConstants.KEY_FEES, objApplicationFeePayment.Fees__c);

                objMap.put(PortalConstants.KEY_INTEREST, getRoundedValue(objApplicationFeePayment.Interest_Earned__c));
                objMap.put(PortalConstants.KEY_LOAN_AMOUNT, PortalConstants.ZERO_VALUE);
                objMap.put(PortalConstants.KEY_AVAILABLE, PortalConstants.ZERO_VALUE);
                objMap.put(PortalConstants.KEY_RESERVED, PortalConstants.ZERO_VALUE);

                // for single rate loans
                if (objApplicationFeePayment.genesis__Application__r.Pricing_Count__c == PortalConstants.ONE_VALUE) {
                    objMap.put(PortalConstants.KEY_LOAN_AMOUNT, objApplicationFeePayment.genesis__Application__r.genesis__Loan_Amount__c);
                    objMap.put(PortalConstants.KEY_AVAILABLE, objApplicationFeePayment.genesis__Application__r.Available__c);
                    objMap.put(PortalConstants.KEY_RESERVED, objApplicationFeePayment.genesis__Application__r.Reserved_Amount__c);
                }
            } else {
                // parent loan
                objMap.put(PortalConstants.KEY_LOAN_NUMBER, objApplicationFeePayment.genesis__Application__r.genesis__Loan_Number__c);
                objMap.put(PortalConstants.KEY_PRINCIPAL, PortalConstants.ZERO_VALUE);
                objMap.put(PortalConstants.KEY_PER_DIEM, PortalConstants.ZERO_VALUE);
                objMap.put(PortalConstants.KEY_FEES, PortalConstants.ZERO_VALUE);
                objMap.put(PortalConstants.KEY_INTEREST, PortalConstants.ZERO_VALUE);
                objMap.put(PortalConstants.KEY_LOAN_AMOUNT, objApplicationFeePayment.genesis__Application__r.genesis__Loan_Amount__c);
                objMap.put(PortalConstants.KEY_AVAILABLE, objApplicationFeePayment.genesis__Application__r.Available__c);
                objMap.put(PortalConstants.KEY_RESERVED, objApplicationFeePayment.genesis__Application__r.Reserved_Amount__c);
            }

            objMap.put(PortalConstants.KEY_MATURITY_DATE, objApplicationFeePayment.genesis__Application__r.genesis__Maturity_Date__c);
            objMap.put(PortalConstants.KEY_CERTIFIED_LENDER, objApplicationFeePayment.genesis__Application__r.Certified_Lender__r.Name);
            objMap.put(PortalConstants.KEY_SALES_AGENT, objApplicationFeePayment.genesis__Application__r.Sales_Agent__r.Name);
            objMap.put(PortalConstants.KEY_CREDIT_RATING, objApplicationFeePayment.genesis__Application__r.genesis__Credit_Rating__r.Name);
            objMap.put(PortalConstants.KEY_NOTE_DATE, objApplicationFeePayment.genesis__Application__r.Note_Date__c);
            objMap.put(PortalConstants.KEY_STATUS, objApplicationFeePayment.genesis__Application__r.genesis__Status__c);
            objMap.put(PortalConstants.KEY_GROWER_NAME, objApplicationFeePayment.genesis__Application__r.genesis__Account__r.Name);
            objMap.put(PortalConstants.KEY_PURPOSE, objApplicationFeePayment.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c);
            objMap.put(PortalConstants.KEY_CROP_YEAR, objApplicationFeePayment.genesis__Application__r.Crop_Year__c);
            objMap.put(PortalConstants.KEY_IRC_SHORT_FORM, objApplicationFeePayment.genesis__Application__r.Internal_Reference_Code__c);
            objMap.put(PortalConstants.KEY_GROWMARK_UNIQUE_IDENTIFIER, objApplicationFeePayment.genesis__Application__r.Growmark_Unique_Identifier__c);
            objMap.put(PortalConstants.KEY_GUARANTY, objApplicationFeePayment.genesis__Application__r.Guarantee__c);
            objMap.put(PortalConstants.KEY_PAST_DUE, objApplicationFeePayment.Past_Due_Balance__c);
            objMap.put(PortalConstants.KEY_CREATED_DATE, objApplicationFeePayment.genesis__Application__r.CreatedDate);
        
            childLoanList.add(objMap);
        }
        return childLoanList;
    }

    /**
    * @description - method to generate a result list
    * @author Sk Minsar | 11-13-2023 
    * @param objApplicationPricingMap 
    * @param appIdToPartyMap 
    * @return List<Map<String, Object>> 
    **/
    public static List<Map<String, Object>> getResultList(Map<Object, Map<String, List<genesis__Application_Pricing_Detail__c>>> objApplicationPricingMap, 
                                                            Map<Id, clcommon__party__c> appIdToPartyMap){
        List<Map<String, Object>> resultList = new List<Map<String, Object>>();
        Date today = System.today();
        for (Object loanNumber : objApplicationPricingMap.keySet()) {
            List<genesis__Application_Pricing_Detail__c> activeSubtranches = objApplicationPricingMap.get(loanNumber).get('true');
            List<genesis__Application_Pricing_Detail__c> inActiveSubtranches = objApplicationPricingMap.get(loanNumber).get('false');

            if (activeSubtranches != null && activeSubtranches.size() == PortalConstants.ONE_VALUE) {

                genesis__Application_Pricing_Detail__c nextSubtranche = getNextSubtranche(activeSubtranches[PortalConstants.ZERO_VALUE], inActiveSubtranches);
                clcommon__party__c nextSubtrancheParty = new clcommon__party__c();
                if(nextSubtranche != null && nextSubtranche.genesis__Application__c != null){
                    nextSubtrancheParty = appIdToPartyMap.get(nextSubtranche.genesis__Application__c);
                }
                if (nextSubtrancheParty != null && nextSubtranche != null && today.addDays(DAYS_AHEAD_RATE_CHANGE) > activeSubtranches[PortalConstants.ZERO_VALUE].genesis__Rate_Card_Setup_Detail__r.End_Date__c) {
                    
                    Map<String, Object> resultMap = new Map<String, Object>();
                    resultMap.put(PortalConstants.KEY_CURRENT_RATE, activeSubtranches[PortalConstants.ZERO_VALUE].genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c);
                    resultMap.put(PortalConstants.KEY_NEW_RATE, nextSubtranche.genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c);
                    resultMap.put(PortalConstants.KEY_EFFECTIVE_DATE, nextSubtranche.genesis__Rate_Card_Setup_Detail__r.Start_Date__c);
                    resultMap.put(PortalConstants.KEY_GROWER_NAME, nextSubtranche.genesis__Application__r.genesis__Account__r.Name);
                    resultMap.put(PortalConstants.KEY_LOAN_NUMBER, nextSubtranche.Loan_Number__c);
                    resultMap.put(PortalConstants.KEY_MATURITY_DATE, nextSubtranche.genesis__Application__r.genesis__Maturity_Date__c);
                    resultMap.put(PortalConstants.KEY_CERTIFIED_LENDER, nextSubtranche.genesis__Application__r.Certified_Lender__r.Name);
                    resultMap.put(PortalConstants.KEY_IRC_SHORT_FORM, nextSubtranche.genesis__Application__r.Internal_Reference_Code__c);
                    resultMap.put(PortalConstants.KEY_UNIQUE_IDENTIFIER, nextSubtranche.genesis__Application__r.Growmark_Unique_Identifier__c);
                    resultMap.put(PortalConstants.KEY_SALES_AGENT, nextSubtranche.genesis__Application__r.Sales_Agent__r.Name);
                    resultMap.put(PortalConstants.KEY_EMAIL_ID, nextSubtranche.genesis__Application__r.genesis__Account__r.clcommon__Email__c);
                    resultMap.put(PortalConstants.KEY_MOBILE_PHONE, nextSubtrancheParty.Mobile_Number__c);
                    resultMap.put(PortalConstants.KEY_ADDRESS, nextSubtrancheParty.Street__c);
                    resultMap.put(PortalConstants.KEY_CITY, nextSubtrancheParty.City__c);
                    resultMap.put(PortalConstants.KEY_STATE, nextSubtrancheParty.State__c);
                    resultMap.put(PortalConstants.KEY_ZIP, nextSubtrancheParty.Postal_Code__c);

                    resultList.add(resultMap);
                }
            }
        }
        return resultList;
    }

    /**
    * @description - method to create a commitment loan list
    * @author Sk Minsar | 11-13-2023 
    * @param objApplicationList 
    * @return List<Map<String, Object>> 
    **/
    public static List<Map<String, Object>> getCommitmentLoanList(List<genesis__Applications__c> objApplicationList){
        List<Map<String, Object>> commitmentLoanList = new List<Map<String, Object>>();

        for (genesis__Applications__c objApplication : objApplicationList) {

            if (objApplication.Pricing_Count__c == PortalConstants.ONE_VALUE) {
                continue;
            }
            Map<String, Object> objMap = new Map<String, Object>();

            objMap.put(PortalConstants.KEY_LOAN_ID, objApplication.Id);
            objMap.put(PortalConstants.KEY_LOAN_NUMBER, objApplication.genesis__Loan_Number__c);
            objMap.put(PortalConstants.KEY_LOAN_AMOUNT, objApplication.genesis__Loan_Amount__c);
            objMap.put(PortalConstants.KEY_MATURITY_DATE, objApplication.genesis__Maturity_Date__c);
            objMap.put(PortalConstants.KEY_STATUS, objApplication.genesis__Status__c);
            objMap.put(PortalConstants.KEY_GROWER_NAME, objApplication.genesis__Account__r.Name);
            objMap.put(PortalConstants.KEY_CERTIFIED_LENDER, objApplication.Certified_Lender__r.Name);
            objMap.put(PortalConstants.KEY_SALES_AGENT, objApplication.Sales_Agent__r.Name);
            objMap.put(PortalConstants.KEY_CREDIT_RATING, objApplication.genesis__Credit_Rating__r.Name);
            objMap.put(PortalConstants.KEY_NOTE_DATE, objApplication.Note_Date__c);
            objMap.put(PortalConstants.KEY_PRINCIPAL, PortalConstants.ZERO_VALUE);
            objMap.put(PortalConstants.KEY_INTEREST, PortalConstants.ZERO_VALUE);
            objMap.put(PortalConstants.KEY_PER_DIEM, PortalConstants.ZERO_VALUE);
            objMap.put(PortalConstants.KEY_FEES, PortalConstants.ZERO_VALUE);

            objMap.put(PortalConstants.KEY_CROP_YEAR, objApplication.Crop_Year__c);
            objMap.put(PortalConstants.KEY_IRC_SHORT_FORM, objApplication.Internal_Reference_Code__c);
            objMap.put(PortalConstants.KEY_GROWMARK_UNIQUE_IDENTIFIER, objApplication.Growmark_Unique_Identifier__c);

            objMap.put(PortalConstants.KEY_GUARANTY, objApplication.Guarantee__c);
            objMap.put(PortalConstants.KEY_AVAILABLE, objApplication.Available__c);
            objMap.put(PortalConstants.KEY_RESERVED, objApplication.Reserved_Amount__c);
            objMap.put(PortalConstants.KEY_CREATED_DATE, objApplication.CreatedDate);
            
            commitmentLoanList.add(objMap);
        }
        return commitmentLoanList;

        
    }

    /**
    * @description - method to create a loan account list
    * @author Sk Minsar | 11-13-2023 
    * @param objApplicationPricingList 
    * @return List<Map<String, Object>> 
    **/
    public static List<Map<String, Object>> getLoanAccountList(List<genesis__Application_Pricing_Detail__c> objApplicationPricingList){
        List<Map<String, Object>> loanAccountList = new List<Map<String, Object>>();

        for (genesis__Application_Pricing_Detail__c objApplicationPricing : objApplicationPricingList) {
            Map<String, Object> objMap = new Map<String, Object>();

            objMap.put(PortalConstants.KEY_LOAN_ID, objApplicationPricing.Id);
            objMap.put(PortalConstants.KEY_LOAN_NUMBER, objApplicationPricing.Loan_Number__c);
            objMap.put(PortalConstants.KEY_LOAN_AMOUNT, PortalConstants.ZERO_VALUE);
            objMap.put(PortalConstants.KEY_MATURITY_DATE, objApplicationPricing.genesis__Application__r.genesis__Maturity_Date__c);
            objMap.put(PortalConstants.KEY_STATUS, objApplicationPricing.genesis__Application__r.genesis__Status__c);
            objMap.put(PortalConstants.KEY_GROWER_NAME, objApplicationPricing.genesis__Application__r.genesis__Account__r.Name);
            objMap.put(PortalConstants.KEY_CERTIFIED_LENDER, objApplicationPricing.genesis__Application__r.Certified_Lender__r.Name);
            objMap.put(PortalConstants.KEY_SALES_AGENT, objApplicationPricing.genesis__Application__r.Sales_Agent__r.Name);
            objMap.put(PortalConstants.KEY_CREDIT_RATING, objApplicationPricing.genesis__Application__r.genesis__Credit_Rating__r.Name);
            objMap.put(PortalConstants.KEY_NOTE_DATE, objApplicationPricing.genesis__Application__r.Note_Date__c);
            objMap.put(PortalConstants.KEY_INTEREST_RATE, objApplicationPricing.genesis__Interest_Rate__c);
            objMap.put(PortalConstants.KEY_PRINCIPAL, objApplicationPricing.Principal_Advanced__c);
            objMap.put(PortalConstants.KEY_INTEREST, objApplicationPricing.Accrued_Interest__c);


            objMap.put(PortalConstants.KEY_PER_DIEM, getRoundedValue(objApplicationPricing.Interest_Per_Diem__c));

            objMap.put(PortalConstants.KEY_FEES, objApplicationPricing.Fees__c);
            objMap.put(PortalConstants.KEY_PURPOSE, objApplicationPricing.genesis__Rate_Card_Setup_Detail__r.Description__c);
            objMap.put(PortalConstants.KEY_CROP_YEAR, objApplicationPricing.genesis__Application__r.Crop_Year__c);
            objMap.put(PortalConstants.KEY_IRC_SHORT_FORM, objApplicationPricing.genesis__Application__r.Internal_Reference_Code__c);
            objMap.put(PortalConstants.KEY_GROWMARK_UNIQUE_IDENTIFIER, objApplicationPricing.genesis__Application__r.Growmark_Unique_Identifier__c);
            objMap.put(PortalConstants.KEY_GUARANTY, objApplicationPricing.genesis__Application__r.Guarantee__c);
            objMap.put(PortalConstants.KEY_AVAILABLE, PortalConstants.ZERO_VALUE);
            objMap.put(PortalConstants.KEY_RESERVED, PortalConstants.ZERO_VALUE);
            objMap.put(PortalConstants.KEY_CREATED_DATE, objApplicationPricing.genesis__Application__r.CreatedDate);

            if (objApplicationPricing.genesis__Application__r.Pricing_Count__c == PortalConstants.ONE_VALUE) {
                objMap.put(PortalConstants.KEY_AVAILABLE, objApplicationPricing.genesis__Application__r.Available__c);
                objMap.put(PortalConstants.KEY_RESERVED, objApplicationPricing.genesis__Application__r.Reserved_Amount__c);
                objMap.put(PortalConstants.KEY_LOAN_AMOUNT, objApplicationPricing.genesis__Application__r.genesis__Loan_Amount__c);
            }
            
            loanAccountList.add(objMap);
        }
        
        return loanAccountList;
    }

    /**
    * @description - method to create a csv table row
    * @author Sk Minsar | 11-13-2023 
    * @param cellData 
    * @return String 
    **/
    public static String createCSVTableRow(Object cellData) {
        String cellString = (cellData == null) ? 
                        PortalConstants.COMMA_STRING : 
                '\"' + String.valueOf(cellData).replace('\"', '\"\"') + '\"' + PortalConstants.COMMA_STRING;
    
        return cellString;
    }


    /**
    * @description - method to create table for active loan report
    * @author Sk Minsar | 11-13-2023 
    * @param objApplicationList 
    * @return String 
    **/
    public static String createTableForExportActiveLoanReport(List<genesis__Applications__c> objApplicationList){
        String tableData='';
        String tableRow = '';
        
        // looping through the parties and crafting the csv table from the application data
        for (genesis__Applications__c objApplication : objApplicationList) {
            tableRow = createCSVTableRow(String.valueOf(objApplication.genesis__Account__r.name))
                            + createCSVTableRow(objApplication.genesis__Loan_Number__c)
                            + createCSVTableRow(objApplication.Crop_Year__c)
                            + createCSVTableRow(getformatedDate(objApplication.genesis__Maturity_Date__c))
                            + createCSVTableRow(getString(objApplication.Certified_Lender__r.Name))
                            + createCSVTableRow(getString(objApplication.Sales_Agent__r.Name))
                            + createCSVTableRow(getString(objApplication.genesis__Credit_Rating__r.Name))
                            + createCSVTableRow(getformatedDate(objApplication.Note_Date__c))
                            + createCSVTableRow(objApplication.genesis__Interest_Rate__c)
                            + createCSVTableRow(objApplication.genesis__Loan_Amount__c)
                            + createCSVTableRow(objApplication.Current_Principal_Balance__c)
                            + createCSVTableRow(objApplication.Total_Interest__c)
                            + createCSVTableRow(objApplication.Total_Fees__c)
                            + createCSVTableRow(objApplication.Total_Interest_Per_Diem__c)
                            + createCSVTableRow(objApplication.Available__c)
                            + createCSVTableRow(objApplication.Reserved_Amount__c)
                            + createCSVTableRow(objApplication.Past_Due_Amount__c)
                            + createCSVTableRow(objApplication.Guarantee__c)
                            + createCSVTableRow(getString(objApplication.Internal_Reference_Code__c))
                            + createCSVTableRow(getformatedDate(objApplication.CreatedDate));

            tableData += tableRow.removeEnd(PortalConstants.COMMA_STRING) + '\n';
        }
        return tableData;
    }
    /**
    * @description - create the table for end of year report
    * @author Sk Minsar | 11-13-2023 
    * @param objApplicationList 
    * @return String 
    **/
    public static String createTableForEndOfYearReport(List<Map<String, Object>> objApplicationList){
        String tableData='';
        String tableRow = '';
        
        // looping through the parties and crafting the csv table from the application data
        for (Map<String, Object> objApplication : objApplicationList) {
            tableRow = createCSVTableRow(String.valueOf(objApplication.get(PortalConstants.KEY_GROWER_NAME)))
                            + createCSVTableRow(objApplication.get(PortalConstants.KEY_LOAN_NUMBER))
                            + createCSVTableRow(objApplication.get(PortalConstants.KEY_INTEREST))
                            + createCSVTableRow(getString(objApplication.get(PortalConstants.KEY_CERTIFIED_LENDER)))
                            + createCSVTableRow(getString(objApplication.get(PortalConstants.KEY_SALES_AGENT)))
                            + createCSVTableRow(getString(objApplication.get(PortalConstants.KEY_STREET)))
                            + createCSVTableRow(getString(objApplication.get(PortalConstants.KEY_CITY)))
                            + createCSVTableRow(getString(objApplication.get(PortalConstants.KEY_STATE)))
                            + createCSVTableRow(objApplication.get(PortalConstants.KEY_ZIP))
                            + createCSVTableRow(getString(objApplication.get(PortalConstants.KEY_IRC_SHORT_FORM)))
                            + createCSVTableRow(getformatedDate(objApplication.get(PortalConstants.KEY_CREATED_DATE)));
                            
            tableData += tableRow.removeEnd(PortalConstants.COMMA_STRING) + '\n';
        }
        return tableData;
    }

    /**
    * @description - method to create table for end of month loan report
    * @author Sk Minsar | 11-13-2023 
    * @param resultList 
    * @return String 
    **/
    public static String createTableForEndOfMonthActiveLoanReport(List<Map<String, Object>> resultList){
        String tableData='';
        String tableRow = '';
        
        // looping through the parties and crafting the csv table from the application data
        for (Map<String, Object> result : resultList) {
        
            tableRow = createCSVTableRow(String.valueOf(result.get(PortalConstants.KEY_GROWER_NAME)))
                            + createCSVTableRow(result.get(PortalConstants.KEY_LOAN_NUMBER))
                            + createCSVTableRow(result.get(PortalConstants.KEY_CROP_YEAR))
                            + createCSVTableRow(getString(result.get(PortalConstants.KEY_PURPOSE)))
                            + createCSVTableRow(getformatedDate(result.get(PortalConstants.KEY_MATURITY_DATE)))
                            + createCSVTableRow(getString(result.get(PortalConstants.KEY_CERTIFIED_LENDER)))
                            + createCSVTableRow(getString(result.get(PortalConstants.KEY_SALES_AGENT)))
                            + createCSVTableRow(getString(result.get(PortalConstants.KEY_CREDIT_RATING)))
                            + createCSVTableRow(getformatedDate(result.get(PortalConstants.KEY_NOTE_DATE)))
                            + createCSVTableRow(result.get(PortalConstants.KEY_INTEREST_RATE))
                            + createCSVTableRow(result.get(PortalConstants.KEY_LOAN_AMOUNT))
                            + createCSVTableRow(result.get(PortalConstants.KEY_PRINCIPAL))
                            + createCSVTableRow(result.get(PortalConstants.KEY_INTEREST))
                            + createCSVTableRow(result.get(PortalConstants.KEY_FEES))
                            + createCSVTableRow(result.get(PortalConstants.KEY_PER_DIEM))
                            + createCSVTableRow(result.get(PortalConstants.KEY_AVAILABLE))
                            + createCSVTableRow(result.get(PortalConstants.KEY_RESERVED))
                            + createCSVTableRow(result.get(PortalConstants.KEY_PAST_DUE))
                            + createCSVTableRow(result.get(PortalConstants.KEY_GUARANTY))
                            + createCSVTableRow(getString(result.get(PortalConstants.KEY_IRC_SHORT_FORM)))
                            + createCSVTableRow(getformatedDate(result.get(PortalConstants.KEY_CREATED_DATE)));

            tableData += tableRow.removeEnd(PortalConstants.COMMA_STRING) + '\n';
        }
        return tableData;
    }

    /**
    * @description - method to create table for current crop year report
    * @author Sk Minsar | 11-13-2023 
    * @param objApplicationList 
    * @return String 
    **/
    public static String createTableForCurrentCropYearReport(List<genesis__Applications__c> objApplicationList){
        String tableData='';
        String tableRow = '';
        
        // looping through the parties and crafting the csv table from the application data
        for (genesis__Applications__c objApplication : objApplicationList) {
            tableRow = createCSVTableRow(String.valueOf(objApplication.genesis__Account__r.name))
                            + createCSVTableRow(objApplication.Crop_Year__c)
                            + createCSVTableRow(getString(objApplication.Certified_Lender__c, objApplication.Certified_Lender__r.Name))
                            + createCSVTableRow(objApplication.genesis__Loan_Amount__c)
                            + createCSVTableRow(objApplication.genesis__Status__c)
                            + createCSVTableRow(getString(objApplication.Internal_Reference_Code__c))
                            + createCSVTableRow(getString(objApplication.Sales_Agent__c, objApplication.Sales_Agent__r.Name))
                            + createCSVTableRow(getformatedDate(objApplication.CreatedDate));

            tableData += tableRow.removeEnd(PortalConstants.COMMA_STRING) + '\n';
        }
        return tableData;
    }

    /**
    * @description -  method to create table for prior crop year report
    * @author Sk Minsar | 11-13-2023 
    * @param objApplicationList 
    * @return String 
    **/
    public static String createTableForPriorCropYearReport(List<genesis__Applications__c> objApplicationList){
        String tableData='';
        String tableRow = '';
        
        // looping through the parties and crafting the csv table from the application data
        for (genesis__Applications__c objApplication : objApplicationList) {
            tableRow = createCSVTableRow(String.valueOf(objApplication.genesis__Account__r.name))
                            + createCSVTableRow(objApplication.Crop_Year__c)
                            + createCSVTableRow(getString(objApplication.Certified_Lender__c, objApplication.Certified_Lender__r.Name))
                            + createCSVTableRow(objApplication.genesis__Loan_Amount__c)
                            + createCSVTableRow(objApplication.genesis__Status__c)
                            + createCSVTableRow(getString(objApplication.Internal_Reference_Code__c))
                            + createCSVTableRow(getString(objApplication.Sales_Agent__c, objApplication.Sales_Agent__r.Name))
                            + createCSVTableRow(getformatedDate(objApplication.CreatedDate));

            tableData += tableRow.removeEnd(PortalConstants.COMMA_STRING) + '\n';
        }
        return tableData;
    }

    
    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param onlineUserList 
    * @return String 
    **/
    public static String createTableForOnlineUsersReport(List<Map<String, Object>> onlineUserList){
        String tableData='';
        String tableRow = '';
        
        // looping through the parties and crafting the csv table from the application data
        for (Map<String, Object> onlineUser : onlineUserList) {
            tableRow = createCSVTableRow(String.valueOf(onlineUser.get(PortalConstants.KEY_NAME)))
                            + createCSVTableRow(onlineUser.get(PortalConstants.KEY_PHONE))
                            + createCSVTableRow(getString(onlineUser.get(PortalConstants.KEY_EMAIL)))
                            + createCSVTableRow(onlineUser.get(PortalConstants.KEY_HAS_ACTIVE_LOAN))
                            + createCSVTableRow(onlineUser.get(PortalConstants.KEY_UNIQUE_IDENTIFIER));

            tableData += tableRow.removeEnd(PortalConstants.COMMA_STRING) + '\n';
        }
        return tableData;
    }
    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param onlineUserList 
    * @return String 
    **/
    public static String createTableForGMKOnlineUsersReport(List<Map<String, Object>> onlineUserList){
        String tableData='';
        String tableRow = '';
        
        // looping through the parties and crafting the csv table from the application data
        for (Map<String, Object> onlineUser : onlineUserList) {
            tableRow = createCSVTableRow(String.valueOf(onlineUser.get(PortalConstants.KEY_NAME)))
                            + createCSVTableRow(onlineUser.get(PortalConstants.KEY_PHONE))
                            + createCSVTableRow(getString(onlineUser.get(PortalConstants.KEY_EMAIL)))
                            + createCSVTableRow(onlineUser.get(PortalConstants.KEY_HAS_ACTIVE_LOAN))
                            + createCSVTableRow(onlineUser.get(PortalConstants.KEY_UNIQUE_IDENTIFIER));

            tableData += tableRow.removeEnd(PortalConstants.COMMA_STRING) + '\n';
        }
        return tableData;
    }

    /**
    * @description - method to create table for subsidy accrual report
    * @author Sk Minsar | 11-13-2023 
    * @param objFeePaymentList 
    * @return String 
    **/
    public static String createTableForSubsidyAccrualReport(List<genesis__Application_Fee_Payment__c> objFeePaymentList){
        String tableData='';
        String tableRow = '';
        
        // looping through the parties and crafting the csv table from the application data
        for (genesis__Application_Fee_Payment__c objApplicationFeePayment : objFeePaymentList) {
            tableRow = createCSVTableRow(objApplicationFeePayment.Pricing_Detail__r.Loan_Number__c)
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Dealer_Name__c, objApplicationFeePayment.genesis__Application__r.Dealer_Name__r.BillingCity))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Dealer_Name__c, objApplicationFeePayment.genesis__Application__r.Dealer_Name__r.BillingState))
                            + createCSVTableRow(objApplicationFeePayment.Principal_Balance__c)
                            + createCSVTableRow(objApplicationFeePayment.Dealer_Monthly_Interest__c)
                            + createCSVTableRow(objApplicationFeePayment.Interest_Earned__c.setScale(2))
                            + createCSVTableRow(objApplicationFeePayment.genesis__Application__r.Crop_Year__c)
                            + createCSVTableRow(getString(objApplicationFeePayment.Pricing_Detail__c, objApplicationFeePayment.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__c, objApplicationFeePayment.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c))
                            + createCSVTableRow(objApplicationFeePayment.genesis__Application__r.genesis__Account__r.name)
                            + createCSVTableRow(getformatedDate(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.genesis__Maturity_Date__c))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c , objApplicationFeePayment.genesis__Application__r.Certified_Lender__r.Name))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Sales_Agent__r.Name))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c , objApplicationFeePayment.genesis__Application__r.Internal_Reference_Code__c))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Unique_Identifier__c))
                            + createCSVTableRow(getformatedDate(objApplicationFeePayment.Pricing_Detail__c, objApplicationFeePayment.Pricing_Detail__r.CreatedDate));

            tableData += tableRow.removeEnd(PortalConstants.COMMA_STRING) + '\n';
        }
        return tableData;
    }
    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param objFeePaymentList 
    * @return String 
    **/
    public static String createTableForGMKSubsidyAccrualReport(List<genesis__Application_Fee_Payment__c> objFeePaymentList){
        String tableData='';
        String tableRow = '';
        
        // looping through the parties and crafting the csv table from the application data
        for (genesis__Application_Fee_Payment__c objApplicationFeePayment : objFeePaymentList) {
            tableRow = createCSVTableRow(objApplicationFeePayment.Pricing_Detail__r.Loan_Number__c)
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Dealer_Name__c, objApplicationFeePayment.genesis__Application__r.Dealer_Name__r.BillingCity))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Dealer_Name__c, objApplicationFeePayment.genesis__Application__r.Dealer_Name__r.BillingState))
                            + createCSVTableRow(objApplicationFeePayment.Principal_Balance__c)
                            + createCSVTableRow(objApplicationFeePayment.Dealer_Monthly_Interest__c)
                            + createCSVTableRow(objApplicationFeePayment.Interest_Earned__c.setScale(2))
                            + createCSVTableRow(objApplicationFeePayment.genesis__Application__r.Crop_Year__c)
                            + createCSVTableRow(getString(objApplicationFeePayment.Pricing_Detail__c, objApplicationFeePayment.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__c, objApplicationFeePayment.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c))
                            + createCSVTableRow(objApplicationFeePayment.genesis__Application__r.genesis__Account__r.name)
                            + createCSVTableRow(getformatedDate(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.genesis__Maturity_Date__c))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Certified_Lender__r.Name))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c , objApplicationFeePayment.genesis__Application__r.Sales_Agent__r.Name))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Internal_Reference_Code__c))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Unique_Identifier__c))
                            + createCSVTableRow(getformatedDate(objApplicationFeePayment.Pricing_Detail__c, objApplicationFeePayment.Pricing_Detail__r.CreatedDate));

            tableData += tableRow.removeEnd(PortalConstants.COMMA_STRING) + '\n';
        }
        return tableData;
    }


    /**
    * @description - method to create table for premium accrual report
    * @author Sk Minsar | 11-13-2023 
    * @param objFeePaymentList 
    * @return String 
    **/
    public static String createTableForPremiumAccrualReport(List<genesis__Application_Fee_Payment__c> objFeePaymentList){
        String tableData='';
        String tableRow = '';
        
        // looping through the parties and crafting the csv table from the application data
        for (genesis__Application_Fee_Payment__c objApplicationFeePayment : objFeePaymentList) {
            tableRow = createCSVTableRow(objApplicationFeePayment.Pricing_Detail__r.Loan_Number__c)
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Dealer_Name__c, objApplicationFeePayment.genesis__Application__r.Dealer_Name__r.BillingCity))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Dealer_Name__c, objApplicationFeePayment.genesis__Application__r.Dealer_Name__r.BillingState))
                            + createCSVTableRow(objApplicationFeePayment.Principal_Balance__c)
                            + createCSVTableRow(objApplicationFeePayment.Dealer_Monthly_Interest__c)
                            + createCSVTableRow(objApplicationFeePayment.Interest_Earned__c.setScale(2))
                            + createCSVTableRow(objApplicationFeePayment.genesis__Application__r.Crop_Year__c)
                            + createCSVTableRow(getString(objApplicationFeePayment.Pricing_Detail__c, objApplicationFeePayment.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__c, objApplicationFeePayment.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c))
                            + createCSVTableRow(objApplicationFeePayment.genesis__Application__r.genesis__Account__r.name)
                            + createCSVTableRow(getformatedDate(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.genesis__Maturity_Date__c))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Certified_Lender__r.Name))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Sales_Agent__r.Name))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Internal_Reference_Code__c))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Unique_Identifier__c ))
                            + createCSVTableRow(getformatedDate(objApplicationFeePayment.Pricing_Detail__c, objApplicationFeePayment.Pricing_Detail__r.CreatedDate));

            tableData += tableRow.removeEnd(PortalConstants.COMMA_STRING) + '\n';
        }
        return tableData;
    }
    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param objFeePaymentList 
    * @return String 
    **/
    public static String createTableForGMKPremiumAccrualReport(List<genesis__Application_Fee_Payment__c> objFeePaymentList){
        String tableData='';
        String tableRow = '';
        
        // looping through the parties and crafting the csv table from the application data
        for (genesis__Application_Fee_Payment__c objApplicationFeePayment : objFeePaymentList) {
            tableRow = createCSVTableRow(objApplicationFeePayment.Pricing_Detail__r.Loan_Number__c)
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Dealer_Name__c, objApplicationFeePayment.genesis__Application__r.Dealer_Name__r.BillingCity))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Dealer_Name__c, objApplicationFeePayment.genesis__Application__r.Dealer_Name__r.BillingState))
                            + createCSVTableRow(objApplicationFeePayment.Principal_Balance__c)
                            + createCSVTableRow(objApplicationFeePayment.Dealer_Monthly_Interest__c)
                            + createCSVTableRow(objApplicationFeePayment.Interest_Earned__c.setScale(2))
                            + createCSVTableRow(objApplicationFeePayment.genesis__Application__r.Crop_Year__c)
                            + createCSVTableRow(getString(objApplicationFeePayment.Pricing_Detail__c, objApplicationFeePayment.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__c, objApplicationFeePayment.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c))
                            + createCSVTableRow(objApplicationFeePayment.genesis__Application__r.genesis__Account__r.name)
                            + createCSVTableRow(getformatedDate(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.genesis__Maturity_Date__c))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c , objApplicationFeePayment.genesis__Application__r.Certified_Lender__r.Name))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Sales_Agent__r.Name))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c , objApplicationFeePayment.genesis__Application__r.Internal_Reference_Code__c))
                            + createCSVTableRow(getString(objApplicationFeePayment.genesis__Application__c, objApplicationFeePayment.genesis__Application__r.Unique_Identifier__c ))
                            + createCSVTableRow(getformatedDate(objApplicationFeePayment.Pricing_Detail__c, objApplicationFeePayment.Pricing_Detail__r.CreatedDate));

            tableData += tableRow.removeEnd(PortalConstants.COMMA_STRING) + '\n';
        }

        return tableData;
    }

    /**
    * @description - method to create table for loan accrual report
    * @author Sk Minsar | 11-13-2023 
    * @param resultList 
    * @return String 
    **/
    public static String createTableForLoanAccrualReport(List<Map<String, Object>> resultList){
        String tableData='';
        String tableRow = '';
        
        // looping through the parties and crafting the csv table from the application data
        for (Map<String, Object> result : resultList) {
            tableRow = createCSVTableRow(String.valueOf(result.get(PortalConstants.KEY_GROWER_NAME)))
                            + createCSVTableRow(result.get(PortalConstants.KEY_LOAN_NUMBER))
                            + createCSVTableRow(result.get(PortalConstants.KEY_CROP_YEAR))
                            + createCSVTableRow(getString(result.get(PortalConstants.KEY_PURPOSE)))
                            + createCSVTableRow(getformatedDate(result.get(PortalConstants.KEY_MATURITY_DATE)))
                            + createCSVTableRow(getString(result.get(PortalConstants.KEY_CERTIFIED_LENDER)))
                            + createCSVTableRow(getString(result.get(PortalConstants.KEY_SALES_AGENT)))
                            + createCSVTableRow(getString(result.get(PortalConstants.KEY_CREDIT_RATING)))
                            + createCSVTableRow(getformatedDate(result.get(PortalConstants.KEY_NOTE_DATE)))
                            + createCSVTableRow(result.get(PortalConstants.KEY_INTEREST_RATE))
                            + createCSVTableRow(result.get(PortalConstants.KEY_LOAN_AMOUNT))
                            + createCSVTableRow(result.get(PortalConstants.KEY_PRINCIPAL))
                            + createCSVTableRow(result.get(PortalConstants.KEY_INTEREST))
                            + createCSVTableRow(result.get(PortalConstants.KEY_FEES))
                            + createCSVTableRow(result.get(PortalConstants.KEY_PER_DIEM))
                            + createCSVTableRow(result.get(PortalConstants.KEY_AVAILABLE))
                            + createCSVTableRow(result.get(PortalConstants.KEY_RESERVED))
                            + createCSVTableRow(result.get(PortalConstants.KEY_GUARANTY))
                            + createCSVTableRow(getString(result.get(PortalConstants.KEY_IRC_SHORT_FORM)))
                            + createCSVTableRow(getformatedDate(result.get(PortalConstants.KEY_CREATED_DATE)));

            tableData += tableRow.removeEnd(PortalConstants.COMMA_STRING) + '\n';
        }
        return tableData;
    }

    /**
    * @description - method to create table for loan accrual report
    * @author Sk Minsar | 11-13-2023 
    * @param resultList 
    * @return String 
    **/
    public static String createTableForGMKLoanAccrualReport(List<Map<String, Object>> resultList){
        String tableData='';
        String tableRow = '';
        
        for (Map<String, Object> result : resultList) {
            tableRow = createCSVTableRow(String.valueOf(result.get(PortalConstants.KEY_GROWER_NAME)))
                            + createCSVTableRow(result.get(PortalConstants.KEY_LOAN_NUMBER))
                            + createCSVTableRow(result.get(PortalConstants.KEY_CROP_YEAR))
                            + createCSVTableRow(getString(result.get(PortalConstants.KEY_PURPOSE)))
                            + createCSVTableRow(getformatedDate(result.get(PortalConstants.KEY_MATURITY_DATE)))
                            + createCSVTableRow(getString(result.get(PortalConstants.KEY_CERTIFIED_LENDER)))
                            + createCSVTableRow(getString(result.get(PortalConstants.KEY_SALES_AGENT)))
                            + createCSVTableRow(getString(result.get(PortalConstants.KEY_CREDIT_RATING)))
                            + createCSVTableRow(getformatedDate(result.get(PortalConstants.KEY_NOTE_DATE)))
                            + createCSVTableRow(result.get(PortalConstants.KEY_INTEREST_RATE))
                            + createCSVTableRow(result.get(PortalConstants.KEY_LOAN_AMOUNT))
                            + createCSVTableRow(result.get(PortalConstants.KEY_PRINCIPAL))
                            + createCSVTableRow(result.get(PortalConstants.KEY_INTEREST))
                            + createCSVTableRow(result.get(PortalConstants.KEY_FEES))
                            + createCSVTableRow(result.get(PortalConstants.KEY_PER_DIEM))
                            + createCSVTableRow(result.get(PortalConstants.KEY_AVAILABLE))
                            + createCSVTableRow(result.get(PortalConstants.KEY_RESERVED))
                            + createCSVTableRow(result.get(PortalConstants.KEY_GUARANTY))
                            + createCSVTableRow(getString(result.get(PortalConstants.KEY_IRC_SHORT_FORM)))
                            + createCSVTableRow(getString(result.get(PortalConstants.KEY_GROWMARK_UNIQUE_IDENTIFIER)))
                            + createCSVTableRow(getformatedDate(result.get(PortalConstants.KEY_CREATED_DATE)));

            tableData += tableRow.removeEnd(PortalConstants.COMMA_STRING) + '\n';
        }
        return tableData;
    }

    /**
    * @description - method to create table for rate change notification report
    * @author Sk Minsar | 11-13-2023 
    * @param rateChangeList 
    * @return String 
    **/
    public static String createTableForRateChangeNotificationReport(List<Map<String, Object>> rateChangeList){
        String tableData='';
        String tableRow = '';

        // looping through the parties and crafting the csv table from the application data
        for (Map<String, Object> rateChange : rateChangeList) {
            tableRow = createCSVTableRow(String.valueOf(rateChange.get(PortalConstants.KEY_GROWER_NAME)))
                            + createCSVTableRow(rateChange.get(PortalConstants.KEY_LOAN_NUMBER))
                            + createCSVTableRow(getformatedDate(rateChange.get(PortalConstants.KEY_MATURITY_DATE)))
                            + createCSVTableRow(getString(rateChange.get(PortalConstants.KEY_CERTIFIED_LENDER)))
                            + createCSVTableRow(getString(rateChange.get(PortalConstants.KEY_IRC_SHORT_FORM)))
                            + createCSVTableRow(getString(rateChange.get(PortalConstants.KEY_ADDRESS)))
                            + createCSVTableRow(getString(rateChange.get(PortalConstants.KEY_CITY)))
                            + createCSVTableRow(getString(rateChange.get(PortalConstants.KEY_STATE)))
                            + createCSVTableRow(rateChange.get(PortalConstants.KEY_ZIP))
                            + createCSVTableRow(getString(rateChange.get(PortalConstants.KEY_EMAIL_ID)))
                            + createCSVTableRow(rateChange.get(PortalConstants.KEY_MOBILE_PHONE))
                            + createCSVTableRow(rateChange.get(PortalConstants.KEY_CURRENT_RATE))
                            + createCSVTableRow(rateChange.get(PortalConstants.KEY_NEW_RATE))
                            + createCSVTableRow(getString(rateChange.get(PortalConstants.KEY_SALES_AGENT)))
                            + createCSVTableRow(getformatedDate(rateChange.get(PortalConstants.KEY_EFFECTIVE_DATE)));

            tableData += tableRow.removeEnd(PortalConstants.COMMA_STRING) + '\n';
        }
        return tableData;
    }

    /**
    * @description - method to create table for Product Return Summary Report
    * @author Sk Minsar | 11-13-2023 
    * @param productReturnList 
    * @return String 
    **/
    public static String createTableForProductReturnSummaryReport(List<Map<String, Object>> productReturnList){

        String tableData='';
        String tableRow = '';

        // looping through the funding transaction list and crafting the csv table from the funding transactions data
        for(Map<String, Object> productReturnMap : productReturnList){

            tableRow = createCSVTableRow(productReturnMap.get(PortalConstants.KEY_GROWER_NAME))
                        + createCSVTableRow(productReturnMap.get(PortalConstants.KEY_LOAN_NUMBER))
                        + createCSVTableRow(productReturnMap.get(PortalConstants.KEY_DESCRIPTION))
                        + createCSVTableRow(productReturnMap.get(PortalConstants.KEY_CROP_YEAR))
                        + createCSVTableRow(productReturnMap.get(PortalConstants.KEY_AMOUNT))
                        + createCSVTableRow(productReturnMap.get(PortalConstants.KEY_PURPOSE))
                        + createCSVTableRow(productReturnMap.get(PortalConstants.KEY_CREATED_DATE))
                        + createCSVTableRow(productReturnMap.get(PortalConstants.KEY_CREATED_BY))
                        + createCSVTableRow(productReturnMap.get(PortalConstants.KEY_UNIQUE_IDENTIFIER));

            tableData += tableRow.removeEnd(PortalConstants.COMMA_STRING) + '\n';
        }
        return tableData;
    }

    /**
    * @description 
    * @author Sk Minsar | 11-13-2023 
    * @param fundingTransactionList 
    * @return List<Map<String, Object>> 
    **/
    public static List<Map<String, Object>> getProductReturnSummaryList(List<genesis__Funding_Transaction__c> fundingTransactionList){

        List<Map<String, Object>> productReturnList = new List<Map<String, Object>>();
        String createdDate = null;

        for(genesis__Funding_Transaction__c objFundingTransaction : fundingTransactionList){

            Map<String, Object> objProductReturnMap = new Map<String, Object>();
            Datetime createdDateDT = (Datetime)(objFundingTransaction.CreatedDate);
            createdDate = String.valueOf(date.newInstance(createdDateDT.yearGmt(), createdDateDT.monthGmt(), createdDateDT.dayGmt()));

            objProductReturnMap.put(PortalConstants.KEY_GROWER_NAME, objFundingTransaction.Pricing_Detail__r.genesis__Application__r.genesis__Account__r.Name);
            objProductReturnMap.put(PortalConstants.KEY_LOAN_NUMBER, objFundingTransaction.Pricing_Detail__r.Loan_Number__c);
            objProductReturnMap.put(PortalConstants.KEY_DESCRIPTION, objFundingTransaction.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c);
            objProductReturnMap.put(PortalConstants.KEY_CROP_YEAR, objFundingTransaction.Pricing_Detail__r.genesis__Application__r.Crop_Year__c);
            objProductReturnMap.put(PortalConstants.KEY_UNIQUE_IDENTIFIER, objFundingTransaction.Pricing_Detail__r.genesis__Application__r.Unique_Identifier__c);
            objProductReturnMap.put(PortalConstants.KEY_AMOUNT, objFundingTransaction.genesis__Amount__c);
            objProductReturnMap.put(PortalConstants.KEY_PURPOSE, objFundingTransaction.genesis__Reference__c);
            objProductReturnMap.put(PortalConstants.KEY_CREATED_DATE, createdDate);
            objProductReturnMap.put(PortalConstants.KEY_CREATED_BY, objFundingTransaction.CreatedBy.Account.Name);

            productReturnList.add(objProductReturnMap);
        }
        return productReturnList;
    }
    
    /**
    * @description - Check if the required parameters are missing
    * @author Sk Minsar | 12-15-2024 
    * @param request 
    * @param param 
    **/
    public static void checkRequestBody(Map<String, Object> request, String param){
        if(request.get(param)== null){
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }
    
    /**
    * @description - check if the required parameters are missing
    * @author Sk Minsar | 12-15-2024 
    * @param request 
    * @param paymentParam 
    **/
    public static void checkRequestParam( Map<String, Object> request,String paymentParam){
        if (!request.containsKey(paymentParam)) {
            throw new CustomException(PortalConstants.REQUIRED_PARAMETERS_MISSING);
        }
    }
}